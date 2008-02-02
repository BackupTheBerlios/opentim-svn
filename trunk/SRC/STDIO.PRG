** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2008 Luc Saffre
**
** This file is part of TIM.
**
** TIM is free software: you can redistribute it and/or modify it
** under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 3 of the License, or
** (at your option) any later version.
**
** TIM is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
** License for more details.
**
** You should have received a copy of the GNU General Public License
** along with TIM. If not, see <http://www.gnu.org/licenses/>.

#include "LIB.CH"

#ifdef LG_FRENCH
  #define MSG001 "Tapez O pour interrompre le travail en cours"
  #define MSG002 "[Ctrl-F3] pour exÇcuter la macro."
#endif
#ifdef LG_GERMAN
  #define MSG001 "J um den Arbeitsvorgang zu unterbrechen :"
  #define MSG002 "Aufzeichnung beendet. [Ctrl-F3] um Macro auszufÅhren."
#endif
#ifdef LG_EN
  #define MSG001 "Okay to interrupt (Y/N) ?"
  #define MSG002 "Aufzeichnung beendet. [Ctrl-F3] um Macro auszufÅhren."
#endif

* #ifdef DEF_VIDSTR
*   #define DEF_SHOWTIME
* #endif

* #ifdef DEF_SHOWTIME
  static sbOnShowTime := {||.t.}
  static snIdleSecs := 0
* #endif


#ifndef __XPP__
static scFldBuffer :=  ""
#endif __XPP__
#ifdef DEF_ALT
  static slAltKeyPressed := .F.
#endif DEF_ALT
static scMsg := ""
static mLeg := ""
static mSta := ""
static CfgDoBeep := .f.
static saKeyStack := { }
static slTerminate := .F.
#ifdef DEF_DEBUG
static scTechLeg := 'alias() + " " + ltrim(str(recno())) + "/" + ltrim(str(lastrec()))'
#endif

static snScreenBlankDelay   := 300
static snExitDelay := 0
static slMustLoginAgain     := .f.

* #ifdef DEF_IE10
static slTrapErrors  := .t. // .f. if danger of having Internal Error 10
* static slXmlInput  := .f.
* static slRtfInput  := .f.
* #endif

#ifdef DEF_VERBOSE
static slLogVerbose := .t.
#endif

#ifdef DEF_MACROREC
  #define MMODE_IDLE   0
  #define MMODE_RECORD 1
  #define MMODE_PLAY   2
  static snMacroMode := MMODE_IDLE
  static snMacroPtr  := 0
  static snPlayDelay := -1
  static saMacro := { }
#endif

// sbWaitBlock is a Code block that will be evaluated while waiting
// for a keystroke. This block receives a parameter : the idle time in seconds.
// It must return .t. if the idle time has to be reset to 0 seconds.

* static sbWaitBlock := {|nTime| WaitBlock(nTime) }

#ifndef DEF_MACROREC
  #xtranslate MacroRecord(<nKey>) =>
#endif


#ifdef MONKEY
static slRandomKey := .F.
FUNCTION StartMonkey
slRandomKey := .T.
RETURN NIL
FUNCTION IsMonkey ; RETURN slRandomKey
#endif MONKEY


* #ifdef DEF_IE10

* ex FUNCTION SetIE10(x)
FUNCTION SetTrapErrors(x)
RETURN slTrapErrors if x == NIL
slTrapErrors := x
RETURN .t.

* FUNCTION SetXmlInput(x)
* RETURN slXmlInput if x == NIL
* slXmlInput := x
* RETURN .t.


* #endif

#ifdef DEF_VERBOSE

FUNCTION SetLogVerbose(x)
RETURN slLogVerbose if x == NIL
slLogVerbose := x
RETURN .t.

#endif

**
** PushKey()
**
FUNCTION PushKey(nKey)
aadd(saKeyStack,NIL) // will be discarded by ains()
ains(saKeyStack,1)
saKeyStack[1] := nKey
RETURN NIL

**
** SendKey()
**
FUNCTION SendKey(nKey)
aadd( saKeyStack, nKey )
RETURN .t.

FUNCTION UndoKey(nKey)
if atail(saKeyStack) == nKey
  asize(saKeyStack,len(saKeyStack) - 1)
endif
RETURN NIL

FUNCTION PopKey()
RETURN 0 if len(saKeyStack) == 0
nKey := saKeyStack[1]
adel(saKeyStack,1)
asize( saKeyStack, len(saKeyStack) - 1 )
if nKey == K_ALT_F4
  AppTerminate(.t.)
  RETURN K_ESC
endif
RETURN nKey


FUNCTION KillKeyStack
saKeyStack := { }
RETURN NIL

#ifdef XPPMOUSE
FUNCTION FlushKeyStack
local i
for i := 1 to len(saKeystack)
  PostAppEvent(saKeystack[i])
next i
saKeyStack := {}
RETURN NIL
#endif XPPMOUSE


**
** WaitBlock() - Standard wait-block function
**
*FUNCTION WaitBlock( nTime )
*@ 0,72 say time()
*if CfgScreenBlankDelay() == 0
*  RETURN .F.
*endif
*if nTime > CfgScreenBlankDelay()
*  ScreenBlank(.f.)   // will always return .t.
*  RETURN .T.
*endif
*RETURN .F. // never reached


**
** ResetWaitBlock()
**
* FUNCTION ResetWaitBlock()
* sbWaitBlock := {|nTime| WaitBlock(nTime) }
* RETURN NIL


**
** SetWaitBlock()
**
* FUNCTION SetWaitBlock( bBlock )
* local bOldBlock
* if bBlock != NIL
*   sbWaitBlock := bBlock
* endif
* RETURN bOldBlock


#ifdef __XPP__
#include "APPEVENT.CH"
FUNCTION ft_alt()
RETURN AppKeyState(xbeK_ALT) == APPKEY_DOWN

#endif
**
** WaitKey()
**
** Returns K_ALT if Alt-Key was pressed & released (without any other key)
** Wenn nSeconds 0 ist, wird bOnIdle ignoriert
**
FUNCTION WaitKey(nSeconds,bOnIdle)
local bKeyBlock
local nIdleStart := NIL
// local nIdleSecs := NIL
local nRow, nCol
local nUserKey
#ifdef MONKEY
  static snKeyCode := NIL
#endif
RETURN PopKey() if len(saKeyStack) != 0
#ifdef DEF_MACROREC
  if snMacroMode == MMODE_PLAY .and. nSeconds == NIL
    if snPlayDelay != -1
      nRow := row()
      nCol := col()
      MsgDisplay(scMsg)
      setpos( nRow, nCol )
      if (nUserKey := inkey(snPlayDelay)) == 0
        if set(_SET_BELL) ; tone(150,1) ; endif
      endif
      if nUserKey == K_ESC
        snMacroMode := MMODE_IDLE
        * saKeyStack := { }
        snPlayDelay := 0
        snIdleSecs := 0
        RETURN 0
      endif
      if nUserKey == K_ALT_F4
        snIdleSecs := 0
        snMacroMode := MMODE_IDLE
        * saKeyStack := { }
        AppTerminate(.t.)
        RETURN K_ESC
      endif
    endif
    snMacroPtr++
    if snMacroPtr > len(saMacro)
      snMacroMode := MMODE_IDLE
    else
      nKey := saMacro[snMacroPtr] // das war der ddBrowse-K_DOWN-bug !
      snIdleSecs := 0
      RETURN saMacro[snMacroPtr]
    endif
  endif
#endif
if AppTerminate()
  snIdleSecs := 0
  RETURN K_ESC
endif
if nextkey() != 0
  #ifdef DEF_ALLKEY
    nKey := allkey()
  #else
    nKey := inkey(0.1)
  #endif
  MacroRecord(nKey)
  snIdleSecs := 0
  RETURN nKey
endif
if nSeconds != NIL // Wenn Aufruf "WaitKey(0)" : nicht warten
  RETURN 0
endif
nRow := row()
nCol := col()
#ifdef DEF_DEBUG
  if empty(scTechLeg)
    SayLeg()
  else
    SayLeg(xparse(scTechLeg))
  endif
  * if len(saWatch) > 0
  *   DispWatch()
  * endif
#endif
MsgDisplay(scMsg)
scMsg := "" // 20030114
#ifdef DEF_MACROREC
  if snMacroMode == MMODE_RECORD
    @ maxrow()-2,maxcol()-11 say str(len(saMacro),5,0) + " RECORD" color (CfgMessageColor())
  endif
#endif
setpos( nRow, nCol )
do while nextkey() == 0
  #ifdef __XPP__
    sleep(5)
  #endif
  #ifdef DEF_OSLIB
    ol_Yield()
  #endif
  #ifdef DEF_ALT
    if ft_alt()
      slAltKeyPressed := .T.
    else
      if slAltKeyPressed
        slAltKeyPressed := .F. // 930830
        MacroRecord(K_ALT)
        snIdleSecs := 0
        RETURN K_ALT
      endif
    endif
  #endif
  * #ifdef DEF_SHOWTIME
    if mSta != NIL // .and. nSeconds == NIL raus am 20061108
      if nIdleStart == NIL
        nIdleStart := seconds()
      elseif seconds() - nIdleStart > 1
        snIdleSecs += seconds() - nIdleStart
        ft_vidstr(maxrow(),1,time())
        eval(sbOnShowTime,snIdleSecs)
        if snExitDelay != 0
          if snIdleSecs > snExitDelay
            rpt_write("Automatic exit after "+ntrim(snIdleSecs)+" idle seconds.")
            AppNormEnd()
            * AppNormEnd(NIL,;
            *   "Ihre TIM-Sitzung wurde nach ";
            *   +ntrim0(snExitDelay/60)+" inaktiven Minuten"+CR_LF;
            *   +"automatisch beendet, um die Datenbank zu entlasten.")
            // AppTerminate(.t.)
            // RETURN K_ESC
          elseif snIdleSecs+20 > snExitDelay
            MsgDisplay("Diese TIM-Sitzung wird automatisch beendet in ";
              +ntrim(snExitDelay-snIdleSecs)+" Sekunden !!!")
          endif
        endif
        if bOnIdle != NIL
          eval(bOnIdle)
          ft_vidstr(maxrow(),1,time())
          ** sonst sieht in waiting.act die Uhr aus als ticke sie
          ** unregelmÑ·ig, weil das ddRefreshAll() doch einen merklichen
          ** Teil der Wartesekunde braucht.
        endif
        nIdleStart := seconds()
      endif
    endif
  * #endif
enddo
snIdleSecs := 0
#ifdef DEF_ALLKEY
  nKey := allkey()
#else
  nKey := inkey()
#endif
#ifdef DEF_ALT
  slAltKeyPressed := .F. // 930830
  ** [970909] Wenn man mit [Alt-F6] ein Dialogfenster aufruft und
  ** die Alt-Taste ein bisschen zu lange gedrÅckt hÑlt, dann wurde das
  ** beim Loslassen als ein weiterer Tastendruck interpretiert.
  if nKey != K_ALT_DOWN .and. nKey != K_ALT_UP
    do while ft_alt()
      #ifdef __XPP__
      sleep(10)
      #endif
      #ifdef DEF_OSLIB
      ol_Yield()
      #endif
      if nextkey() != 0
        exit // slAltKeyPressed := .t.
      endif
    enddo
  endif
#endif DEF_ALT
#ifdef DEF_MACROREC
  if nKey == K_SH_F3
    StartRecorder()
    RETURN 0
  elseif nKey == K_CTRL_F3
    ExecMacro()
    RETURN 0
  elseif nKey == K_ALT_F3
    LoadMacro()
    RETURN 0
  endif
#endif DEF_MACROREC
// 20030114 scMsg := ""
#ifdef DEF_MACROREC
  MacroRecord(nKey)
#endif
#ifdef DEF_DEBUG
  if nKey == K_ALT_F7
    open window "Watch" size 3,64
    scTechLeg := padr(scTechLeg,120)
    @ row(), col() get scTechLeg picture "@K@S60"
    ReadScr()
    close window
    scTechLeg := trim(scTechLeg)
    RETURN 0
  endif
#endif
if nKey == K_ALT_F4
  AppTerminate(.t.)
  RETURN K_ESC
endif
RETURN nKey



**
** WaitKeySet() --> nKey
** WaitKey(), but with SET KEYs activated
**
**
FUNCTION WaitKeySet(nSeconds,bOnIdle)
local nKey
local bKeyBlock
do while .t.
  nKey := WaitKey(nSeconds,bOnIdle)
  if (bKeyBlock := setkey(nKey)) != NIL
    eval( bKeyBlock, PROCNAME(2), PROCLINE(2) )
    #ifdef DEF_ALT
      slAltKeyPressed := .F.
    #endif
  else
    RETURN nKey
  endif
enddo
RETURN NIL // never reached


FUNCTION SayMsg(cMsg)
if cMsg != NIL
  scMsg := cMsg
  MsgDisplay( cMsg )
else
  MsgDisplay( scMsg )
  scMsg := ""
endif
RETURN NIL


FUNCTION SetMsg(cMsg)
RETURN scMsg if cMsg == NIL
scMsg := cMsg
RETURN .t.

FUNCTION SetSta(msg)
if msg != NIL ; mSta := msg ; endif
RETURN mSta

FUNCTION SetLeg(leg)
if leg != NIL ; mLeg := leg ; endif
RETURN mLeg


**
** SaySta()
**
FUNCTION SaySta(s)
if s != NIL ; mSta := s ; endif
StaDisplay(mSta)
RETURN NIL

**
** SayLeg()
**
FUNCTION SayLeg(s)
if s != NIL
  mLeg := s
endif
LegDisplay(mLeg)
RETURN NIL


**
** ReadScr()
**
FUNCTION ReadScr(aReadKeys)
local nCursor := setcursor(if(readinsert(),SC_INSERT,SC_NORMAL))
SaySta()
SayLeg()
ReadModal(GetList,NIL,aReadKeys)
GetList := {}
* read
setcursor(nCursor)
nKey := lastkey()
RptLogDetail()
RETURN K_ESC if AppTerminate()
RETURN nKey


FUNCTION KbdBuffer(c)
default c to ""
keyboard (c)
RETURN .t.

**
** TaskInter()
**
FUNCTION TaskInter(cMsg,lNoConfirm) // [960620] lReport)
local lDlg
* 20030822 : bei EH war TIM jetzt total langsam
* #ifdef DEF_OSLIB
*   ol_Yield()
* #endif
if memory(0) < 200
  raise("memory(0) returned only "+ntrim(memory(0)))
endif
do while nextkey() != 0
  if nextkey() == K_ESC .or. nextkey() == K_ALT_F4 // [960620]
    default lNoConfirm to .f.
    RETURN .t. if lNoConfirm // 20071002
    keyboard ""
    lDlg := SetDialog(.t.)
    RETURN .t. if Confirm(MSG001,cMsg,MSG_NO,"WRN047")
    SetDialog(lDlg)
  else
  #ifdef DEF_ALLKEY
    SendKey(allkey())
    bla
  #else
    SendKey( inkey() )
  #endif
  endif
enddo
#ifdef DEF_PURZEL
  Purzel()
#endif
RETURN .f.

**
** AppStop()
**
** 1. SET KEY K_ALT_F4 to AppStop()
** 2. if AppTerminate() in : oMenu, ddEdit
**
* FUNCTION AppStop(cProc,nLine)
* slTerminate := .T.
* RETURN NIL

**
** AppTerminate()
**
FUNCTION AppTerminate(lNew)
if lNew != NIL
  slTerminate := lNew
endif
RETURN slTerminate

* FUNCTION SetScreenBlankDelay(x)
* snScreenBlankDelay := val(x)
* RETURN .t.

FUNCTION SetExitDelay(x)
snExitDelay := x
RETURN .t.

FUNCTION SetMustLoginAgain(x)
slMustLoginAgain   := ctol(x)
RETURN .t.

*FUNCTION WaitBlock( nCount )
*if snExitDelay != 0 .and. nCount > snExitDelay
*  // AppTerminate(.t.)
*  rpt_write("Automatic exit after "+ntrim(snExitDelay)+" idle seconds.")
*  AppNormEnd()
*endif
** 20021206 : raus mit ScreenBlank()
**if snScreenBlankDelay != 0 .and. nCount > snScreenBlankDelay
**  ScreenBlank()
**  #ifdef DEF_LOGIN
**    if ! empty(UserID())
**      if slMustLoginAgain
**        Logout(.F.)
**        if ! Login()
**          slTerminate := .T. // AppNormEnd()
**        endif
**      endif
**    endif
**  #endif
**  RETURN .T.
**endif
** end 20021206
*#ifdef DEF_SHOWTIME
*  if mSta != NIL
*    ft_vidstr(maxrow(),1,time())
*  endif
*#endif
*RETURN .F.


**
** Purzel()
**
FUNCTION Purzel
#ifdef DEF_VIDSTR
  static cPurzel := "|"
  if cPurzel == "|"
    cPurzel := "/"
  elseif cPurzel == "/"
    cPurzel := "-"
  elseif cPurzel == "-"
    cPurzel := "\"
  elseif cPurzel == "\"
    cPurzel := "|"
  endif
  ft_vidstr(0,79,cPurzel)
#endif DEF_VIDSTR
RETURN .t.

#ifdef DEF_PURZEL

PROCEDURE PurzelStop
ft_vidstr(0,79," ")
RETURN

#endif

#ifdef DEF_MACROREC

FUNCTION WriteMacro()
local i
local fd
local scName := NIL
default scName to space(8)
open window "Write macro" size 3,50
say "Name "
@ row(), col() get scName picture PIC_ID
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
RETURN NIL if (fd := fcreate(trim(scName) + ".MAC")) == -1
for i := 1 to len(saMacro)
  fwrite(fd, ntrim(saMacro[i]) + CR_LF)
next i
fclose(fd)
RETURN NIL

FUNCTION LoadMacro(cFile)
local i
local aDir
local fd
local aLib := {}
local cLine
if cFile == NIL
  aDir := directory("*.MAC")
  for i := 1 to len(aDir)
    aadd(aLib,strtran(aDir[i][1],".MAC"))
  next i
  RETURN NIL if (cFile := ArrayPick(aLib,"load macro")) == NIL
endif
RETURN NIL if (fd := fopen(trim(cFile)+".MAC")) == -1
saMacro := {}
snMacroPtr := 0
do while (cLine := freadline(fd)) != NIL
  aadd(saMacro, val(cLine))
enddo
fclose(fd)
RETURN NIL

FUNCTION StartRecorder()
if snMacroMode == MMODE_RECORD
  ** asize( saMacro, len(saMacro) - 1 ) // delete final Shift-F3 key
  * slRecord := .f.
  snMacroMode := MMODE_IDLE
  WriteMacro()
  SetMsg(MSG002)
else
  saMacro := { }
  snMacroMode := MMODE_RECORD
  * slRecord := .t.
endif
RETURN NIL


**
** ExecMacro()
**
FUNCTION ExecMacro     // Executed by Ctrl-F3
if snMacroMode == MMODE_IDLE
  snMacroPtr := 0
  snMacroMode := MMODE_PLAY
endif
RETURN NIL


FUNCTION IsMacro ; RETURN (snMacroMode == MMODE_RECORD) // slRecord

FUNCTION SetPlayDelay(n)
snPlayDelay := n
RETURN NIL


FUNCTION MacroRecord(nKey)
if snMacroMode == MMODE_RECORD
  aadd(saMacro,nKey)
endif
RETURN NIL

#endif DEF_MACROREC

*#ifndef DEF_VIDSTR
*
*** Geht nicht wegen Bildschirmfarben. ft_vidstr() hat den Vorteil, dass
*** die Farbattribute fÅr den Ausgabestring nicht verÑndert werden.
*
*FUNCTION ls_vidstr(nRow,nCol,cStr)
*local nOldRow := row()
*local nOldCol := col()
*devpos(nRow,nCol)
*devout(cStr)
*devpos(nOldRow,nOldCol)
*RETURN NIL
*
*#endif

* FUNCTION EvalExpr(cExpr)
* local c
* local e
* local lBreakTrap := SetBreakTrap()
* c := cExpr + " : " + type(cExpr)
* SetBreakTrap(.t.)
*   begin sequence
*     if valtype(cExpr) == "C" /// type() oder valtype() that's the question
*       c := &cExpr
*     elseif valtype(cExpr) $ "NDL"
*       c := trim(padr(&cExpr,250))
*     endif
*   recover using e
*     Warning(left(c,70) + " :",ErrorMessage(e))
*     c += " -> " + ErrorMessage(e)
*   end sequence
* SetBreakTrap(lBreakTrap)
* RETURN c


/**
20010528:
**/
FUNCTION xparse(cExpr)
local u := NIL
local e
local lBreakTrap := SetBreakTrap()
#ifdef DEF_DEBUG
  if valtype(cExpr) == "C"
    ** rpt_write("xparse() (" + ntrim(len(cExpr)) + " chars) " + cExpr)
    rpt_write("xparse() " + cExpr)
  else
    Warning("xparse() : argument error")
  endif
#endif
#ifdef DEF_GPF
  e := len(cExpr)
  if e > 280
    RETURN NIL if ! Confirm(;
      cExpr + " : expression length is " + ntrim(e),;
      MsgSure();
    )
  endif
#endif DEF_GPF
* cExpr := eval(sbInputFilter,cExpr)
#ifdef __XPP__
  cExpr := strtran(cExpr,chr(141)," ")
  cExpr := strtran(cExpr,chr(13)+chr(10)," ")
#endif __XPP__
if ! slTrapErrors
  RETURN &cExpr
endif
SetBreakTrap(.t.)
  begin sequence
    u := &cExpr
  recover using e
    if valtype(cExpr) == "C"
      SetMsg(cExpr + " : " + ErrorMessage(e))
      * 20021219 Warning(cExpr + " : ",ErrorMessage(e))
    else
      * 20021219 Warning("xparse() : argument error")
      SetMsg("xparse() : " + utor(cExpr) + " is not a string!")
    endif
    u := NIL
  end sequence
SetBreakTrap(lBreakTrap)
RETURN u

* #endif DEF_IE10

FUNCTION xeval(bExpr,p1,p2,p3,p4)
local u := NIL
local e
local lBreakTrap := SetBreakTrap()
if ! slTrapErrors
* #ifdef DEF_IE10
  RETURN eval(bExpr,p1,p2,p3,p4)
endif
* #else
SetBreakTrap(.t.)
  begin sequence
    u := eval(bExpr,p1,p2,p3,p4)
  recover using e
    * 20021219 Warning("run-time error during xeval() :",ErrorMessage(e))
    SetMsg("run-time error during xeval() :",ErrorMessage(e))
    u := NIL
  end sequence
SetBreakTrap(lBreakTrap)
RETURN u
* #endif



FUNCTION sys_osname()
local c := ""
#ifdef __XPP__
  c += os(OS_FULLNAME)
#else
  #ifdef DEF_OSLIB
  if OL_IsOS2()
    c += "os2"
    // "You appear to be running " +
    // if( OL_IsOS2Win(), "in a DOS Window", "full screen" ) + "."
  endif
  if OL_IsMSWin()
    c += "win"
  endif
  if OL_IsNT()
    c += "winnt"
  endif
  c += " " + alltrim(str(OL_OsVerMaj())) + "." + alltrim(str(OL_OsVerMin()))
  #else
    c += "(n/a)"
  #endif DEF_OSLIB
#endif __XPP__
RETURN c



* #ifdef DEF_SHOWTIME

FUNCTION SetOnShowTime(b)
RETURN sbOnShowTime if b == NIL
sbOnShowTime := b
RETURN .t.

* #endif

#ifndef DEF_VIDSTR

*#ifdef __XPP__
*
*PROC ft_vidstr(r,c,t,cColor)
*DispOutAt(r,c,t)
*RETURN
*
*#else

PROC ft_vidstr(r,c,t,cColor)
local nRow:=row()
local nCol:=col()
if t != NIL
  @ r,c SAY t COLOR (cColor)
endif
setpos(nRow,nCol)
RETURN

*#endif

#endif

#ifdef __XPP__

#include "XBP.CH"

** get/set the Windows clipboard
** if x is NIL, return the current clipboard content
** if x != NIL, write x to the clipboard and return .t. or .f.
**
FUNCTION clipboard(x)
local oClipboard := XbpClipBoard():new():create()
if x == NIL
  if ! oClipBoard:open()
    SetMsg("Failed to open the clipboard fro reading.")
    RETURN NIL
  endif
  x := oClipBoard:getBuffer( XBPCLPBRD_TEXT )
  SetMsg("on clipboard:"+utos(x))
else
  if ! oClipBoard:open()
    SetMsg("Failed to open the clipboard for writing.")
    RETURN .f.
  endif
  if ! oClipBoard:clear()
    SetMsg("Failed to clear the clipboard.")
    RETURN .f.
  endif
  SetMsg("to clipboard:"+utos(x))
  x := oClipBoard:setBuffer( x, XBPCLPBRD_TEXT )
endif
oClipBoard:close()
RETURN x

#else

FUNCTION clipboard(cText)
RETURN scFldBuffer if cText == NIL
*if ! ol_WinCBPaste(cText)
  scFldBuffer := cText
*endif
SetMsg('"'+cText+'"')
RETURN NIL

#endif __XPP__

*FUNCTION GetPasteBuffer()
**local cText := ol_WinCBCopy()
**SetMsg("Alt-Ins")
**if empty(cText)
*  keyboard scFldBuffer
**else
**  keyboard scFldBuffer
**endif
*RETURN NIL



