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

/*
** Copied from Getsys.prg
**             Standard Clipper 5.0 GET/READ subsystem
**             Copyright (c) 1990, 1991 Nantucket Corp.
**             All rights reserved.
*/
#include "set.ch"
#include "getexit.ch"
#include "LIB.CH"

#ifdef LG_FRENCH
  #define MSG001 "Votre code d'installation est limitÇ jusqu'au "
  static MSG_F1 := "[F1] dans un champ marquÇ  = liste de sÇlection"
#endif
#ifdef LG_GERMAN
  #define MSG001 "Ihr Installations-Code ist zeitlich begrenzt bis zum "
  static MSG_F1 := "[F1] in einem mit  markierten Feld = Auswahlliste"
#endif
#ifdef LG_EN
  #define MSG001 "Your installation code is limited until "
  static MSG_F1 := "Hint: press [F1] in fields marked with "
#endif

* #define GE_BOUNCE       9

#define K_UNDO          K_CTRL_U
#define CTRL_END_SPECIAL
* #define ENTER_STOPS  // if not : ENTER goes to next field
* #define DEF_TYPEOUT  //

* static suOldValue

static saMsk := NIL  // 19980422

//
//
// state variables for active READ
//
static sbFormat           // this code block is evaluated at start of ReadModal()
static slUpdated := .f.
static slKillRead         // forces immediate exit (ESCAPE) of current get & read
static BumpTop
static BumpBot
static snLastExit := GE_ENTER
static LastPos
static ActiveGet
static ReadProcName
static ReadProcLine
static snCurGetPos
static BouncePos          // number of Get to activate if GE_BOUNCE
static FldPos             // Cursor position in currently active Get
static saGetList := NIL
static InButton
static saReadKeys
* static sad := NIL
static scLastGet :=  ""
//
// format of array used to preserve state variables
//
#define GSV_KILLREAD       1
#define GSV_BUMPTOP        2
#define GSV_BUMPBOT        3
#define GSV_LASTEXIT       4
#define GSV_LASTPOS        5
#define GSV_ACTIVEGET      6
#define GSV_READVAR        7
#define GSV_READPROCNAME   8
#define GSV_READPROCLINE   9
#define GSV_CURGETPOS     10
#define GSV_BOUNCEPOS     11
#define GSV_FLDPOS        12
#define GSV_GETLIST       13
#define GSV_INBUTTON      14
#define GSV_READKEYS      15
//
#define GSV_COUNT         15

**
** phRead ( )
** Supra-Standard modal READ on an array of GETs.
** Replaces ReadModal()
**
** RETURNS : the n¯ of the last Get that has been activated
**
FUNCTION ReadModal( aList, nStart, aReadKeys, msk )
local aMskSave := saMsk
local oGet
local savedGetSysVars
local nSaveCursor := setcursor()
local nLastPos   // Luc
* local adSave := sad
local i
local uOldValue
* local uOldValue := suOldValue
* sad := ad
if valtype(sbFormat) == T_BLOCK
  eval(sbFormat)
endif
if empty(aList)             // S87 compat.
  setpos( maxrow()-1, 0 )
  RETURN 0                    // NOTE
endif
saMsk := msk
* #ifdef __XPP__
*   ReadModal(aList) ; getList := {}
*   RETURN NIL
* #endif __XPP__
//
//
// Check for ReadKey list if any
//
#ifdef DEF_MOUSE
  if aReadKeys == NIL
    aReadKeys := { { K_MOUSE_EVENT, { || DoMouse() } } }
  else
    aadd ( aReadKeys, { K_MOUSE_EVENT, { || DoMouse() } } )
  endif
#else
  default aReadKeys to {}
#endif
savedGetSysVars := ClearGetSysVars ( aList, aReadKeys ) // preserve state vars
if nStart != NIL
  if nStart <= len(aList)
    snCurGetPos := nStart    // allow for default first field
  endif
endif
// set these for use in SET KEYs
ReadProcName := ProcName(1)
ReadProcLine := ProcLine(1)
#ifdef DEF_MOUSE
  MOUSE_MON()
#endif
* snLastExit := GE_DOWN // Falls das erste Get nicht WHEN befriedigt (Luc)
                        // ... wird aber in ClearGetSysVars gemacht.
** F1-Indikatoren anzeigen :
** siehe 20070518, 20070823
if len(aList) > 1
  for i := 1 to len(aList)
    * if aList[i]:cargo == NIL ; raise(aList[i]:name+" oGet:cargo is NIL") ; endif
    if aList[i]:cargo[AG_PICKBLK] != NIL
      if aList[i]:preBlock == NIL .or. eval(aList[i]:preBlock)
        @ aList[i]:row, aList[i]:col - 1 say SetPickIndicator()
        * 20070831 @ aList[i]:row, aList[i]:col - 1 say ""  // chr(23)
        * @ aList[i]:row, aList[i]:col - 1 say ""  // chr(18)
        if empty(SetMsg())
          SetMsg(MSG_F1) //  "[F1] in einem mit  markierten Feld = Auswahlliste")
        endif
      endif
    endif
  next i
endif
LastPos  := 0
// set initial GET to be read
snCurGetPos := Settle( aList, snCurGetPos )
setcursor( if(readinsert(), SC_INSERT, SC_NORMAL) )   // (Luc)
do while snCurGetPos != 0
   oGet := aList[snCurGetPos]
   PostActiveGet( oGet )
   uOldValue := oGet:varGet()
   if valtype(oGet:reader) == T_BLOCK
     eval(oGet:reader, oGet)                 // use custom reader block
   else
     MyGetReader(oGet)                        // use standard reader
   endif
   if oGet:exitState != GE_WHEN
     LastPos   := snCurGetPos // 19981029 war vorher eine Zeile hîher
     snLastExit  := oGet:exitState
     if oGet:cargo[AG_AFTER] != NIL
       eval(oGet:cargo[AG_AFTER],uOldValue)
     endif
   endif
   snCurGetPos := Settle( aList, snCurGetPos )
enddo
setcursor( nSaveCursor )
** F1-Indikatoren wieder lîschen :
if len(aList) > 1
  for i := 1 to len(aList)
    if aList[i]:cargo[AG_PICKBLK] != NIL
      if aList[i]:preBlock == NIL .or. eval(aList[i]:preBlock)
        @ aList[i]:row, aList[i]:col - 1 say " "
      endif
    endif
  next i
endif
/**
  ddPage() ruft ReadModal() eventuell erneut auf, mit dem gleichen nStart-Wert.
  In diesem Fall darf das zuletzt bearbeitete Get seinen exitState nicht
  behalten, sonst wÅrde dieser das nÑchste READ beenden.
  !!!
  !!! "oGet:exitState := NIL" hÑtte keine Wirkung !!! Clipper 5.2
**/
if LastPos != 0
  aList[LastPos]:exitState := GE_NOEXIT
endif
* suOldValue := uOldValue
nLastPos := LastPos // der Wert von LastPos ist ja nach Restore verloren
// restore state vars
RestoreGetSysVars(savedGetSysVars)
saMsk := aMskSave
#ifdef DEF_MOUSE
  MOUSE_MOFF ( )
#endif
// SetPos( MaxRow()-1, 0 )   // S87 compat.
* sad := adSave
RETURN nLastPos // = die letzte nicht-null-Position ...!


* #ifndef __XPP__
**
**  READER procedure for standard get objects
**
PROCEDURE MyGetReader( oGet )
#ifdef MONKEY
  static snErrCount := 0
#endif
if ! GetPreValidate(oGet)
  RETURN    // read it only if the WHEN clause is satisfied
endif
if empty(oGet:picture) .and. oGet:type != "D"
  oGet:picture := "@K"
endif
GetSetFocus ( @oGet )    // activate the GET for reading
do while oGet:exitState == GE_NOEXIT
  if oGet:typeOut        // check for initial typeout (no editable positions)
    oGet:exitState := GE_ENTER
  endif
  do while ( oGet:exitState == GE_NOEXIT )
    GetApplyKey( oGet, WaitKey() )
    * 20030211 GetApplyKey( oGet, RdKey() )
  enddo
  if ! GetPostValidate(oGet)
    oGet:exitState := GE_NOEXIT   // VALID condition not satisfied
  endif
enddo
oGet:KillFocus()   // de-activate the GET
RETURN
* #endif __XPP__


**
**  CbxReader()
**  READER procedure for CHECKBOX get objects
**
PROCEDURE CbxReader( oGet )
* local uOldValue
if ! GetPreValidate(oGet)
  RETURN    // read it only if the WHEN clause is satisfied
endif
GetSetFocus ( @oGet )    // activate the GET for reading
* uOldValue := oGet:varget()
do while oGet:exitState == GE_NOEXIT
  if oGet:typeOut        // check for initial typeout (no editable positions)
    oGet:exitState := GE_ENTER
  endif
  do while ( oGet:exitState == GE_NOEXIT )
    CbxApplyKey( oGet, WaitKey() )
    * 20030210 CbxApplyKey( oGet, RdKey() )
  enddo
  if ! GetPostValidate(oGet)
    oGet:exitState := GE_NOEXIT   // VALID condition not satisfied
  endif
enddo
oGet:KillFocus()   // de-activate the GET
RETURN


**
**  MemoReader()
**  READER procedure for multiline get objects
**  note : the picture of a memo field contains a hand-made picture string
**  of the form "40x4" (width x height)
PROCEDURE MemoReader( oGet )
local nWaitKey
local cColor := setcolor()
local nWidth  := val(left(oGet:picture,2))      // MEMO_PICTURE
local nHeight := val(substr(oGet:picture,4))    // MEMO_PICTURE
local cSaveScreen := savescreen( ;
  oGet:row, ;
  oGet:col+nWidth, ;
  oGet:row+nHeight, ;
  oGet:col+nWidth+1  ;
)
if ! GetPreValidate(oGet)
  RETURN    // read it only if the WHEN clause is satisfied
endif
setcolor(CfgWindowColor())
* GetSetFocus(oGet)
scLastGet := oGet:name
** 19990210 die folgende Schleife ist nîtig, weil wenn man bei HK
** durch eine Data-Key hierhin kommt, dann kommt diese nicht in den
** keyboard-buffer des TxtEdit() und erschien stattdessen nach
** Beenden des Editors im nÑchsten Feld...
do while (nWaitKey := PopKey()) != 0
  keyboard chr(nWaitKey)
enddo
do while oGet:exitState == GE_NOEXIT
  * if oGet:typeOut        // check for initial typeout (no editable positions)
  *   oGet:exitState := GE_ENTER
  * endif
  TxtEdit( ;
    oGet:block, ;
    oGet:row, ;
    oGet:col, ;
    oGet:row + nHeight - 1 , ;
    oGet:col + nWidth, ;
    .t., ;
    NIL, ;
    oGet:cargo[AG_PICKBLK], ;
    .t. ;
  )
  if TxtExitState() == TXT_UP
    oGet:exitState := GE_UP
  * elseif TxtExitState() == TXT_DOWN
  *   oGet:exitState := GE_DOWN
  * elseif lastkey() == K_SH_TAB
  *   oGet:exitState := GE_UP
  elseif lastkey() == K_ESC
    oGet:exitState := GE_ESCAPE
  elseif lastkey() == K_F10
    oGet:exitState := GE_WRITE
  else
    oGet:exitState := GE_DOWN
  endif
  * do while ( oGet:exitState == GE_NOEXIT )
  *   GetApplyKey( oGet, RdKey() )
  * enddo
  if ! GetPostValidate(oGet)
    oGet:exitState := GE_NOEXIT   // VALID condition not satisfied
  endif
enddo
restscreen( ;
  oGet:row, ;
  oGet:col+nWidth, ;
  oGet:row+nHeight, ;
  oGet:col+nWidth+1, ;
  cSaveScreen, ;
)
* oGet:KillFocus()   // de-activate the GET
setcolor(cColor)
RETURN




**
**  ButtonReader ( )
**  READER function for buttons
**
*PROCEDURE ButtonReader( oGet )
*local nSaveCursor
*local key, bKeyBlock
*if ! GetPreValidate ( oGet )
*  RETURN
*endif
*nSaveCursor := setcursor ( SC_NONE )
*// Set the button flag
*InButton := TRUE
*// read the GET if the WHEN condition is satisfied
*GetSetFocus ( oGet )
*do while ( oGet:exitState == GE_NOEXIT )
*  // check for initial typeout (no editable positions)
*  if ( oGet:typeOut )
*    oGet:exitState := GE_ENTER
*  endif
*  do while ( oGet:exitState == GE_NOEXIT )
*    key := RdKey ()
*    // check for SET KEY first
*    if ( (bKeyBlock := SetKey(key)) <> NIL )
*      GetDoSetKey(bKeyBlock, oGet)
*    else
*      do case
*      case ( key == K_UP )     ; oGet:exitState := GE_UP
*      case ( key == K_SH_TAB ) ; oGet:exitState := GE_UP
*      case ( key == K_DOWN )   ; oGet:exitState := GE_DOWN
*      case ( key == K_TAB )    ; oGet:exitState := GE_DOWN
*      case ( key == K_ENTER ) .or. ( key == K_SPACE )
*         // disallow action if bad valid
*         if GetPostValidate(oGet)
*           eval ( oGet:cargo[AG_BUTTON] )
*         endif
*      case ( key == K_ESC )
*         if ( Set(_SET_ESCAPE) )
*            oGet:undo()
*            oGet:exitState := GE_ESCAPE
*         end
*      case ( key == K_CTRL_HOME ) ; oGet:exitState := GE_TOP
*#ifdef CTRL_END_SPECIAL
*         // both ^W and ^End go to the last GET
*      case (key == K_CTRL_END) ; oGet:exitState := GE_BOTTOM
*#else
*         // both ^W and ^End terminate the READ (the default)
*      case (key == K_CTRL_W) ; oGet:exitState := GE_WRITE
*#endif
*      * case (key == K_UNDO)  ; oGet:Undo()
*      * case (key == K_HOME)  ; oGet:Home()
*      * case (key == K_END)   ; oGet:End()
*      * case (key == K_RIGHT) ; oGet:Right()
*      * case (key == K_LEFT)    ; oGet:Left()
*      * case (key == K_CTRL_RIGHT) ; oGet:WordRight()
*      * case (key == K_CTRL_LEFT) ; oGet:WordLeft()
*      * case (key == K_BS) ; oGet:BackSpace()
*      * case (key == K_DEL) ; oGet:Delete()
*      * case (key == K_CTRL_T) ; oGet:DelWordRight()
*      * case (key == K_CTRL_Y) ; oGet:DelEnd()
*      * case (key == K_CTRL_BS) ; oGet:DelWordLeft()
*      otherwise
*        OtherKey(oGet,key)
*        * if key != K_MOUSE_EVENT .and. key != K_ALT
*        *   oGet:exitState := GE_WRITE
*        * endif
*      endcase
*    endif
*  enddo
*  // disallow exit if the VALID condition is not satisfied
*  if ( !GetPostValidate(oGet) )
*    oGet:exitState := GE_NOEXIT
*  endif
*enddo
*// de-activate the GET
*oGet:KillFocus()
*InButton := FALSE
*setcursor ( nSaveCursor )
*RETURN


* #ifndef __XPP__
**
** Apply a single Inkey() keystroke to a (focussed) GET.
**
PROCEDURE GetApplyKey(oGet, key)
local cKey
local bKeyBlock
// check for SET KEY first
if (bKeyBlock := SetKey(key)) <> NIL
  GetDoSetKey(bKeyBlock, oGet)
  RETURN                                                   // NOTE
endif
do case
case ( key == K_UP )     ; oGet:exitState := GE_UP
case ( key == K_SH_TAB ) ; oGet:exitState := GE_UP
case ( key == K_DOWN )   ; oGet:exitState := GE_DOWN
case ( key == K_TAB )    ; oGet:exitState := GE_DOWN
case ( key == K_CTRL_INS )  ; clipboard(trim(oGet:buffer))
case ( key == K_ALT_INS )
  GetPaste(oGet,clipboard())
  * GetPasteBuffer()
  * keyboard clipboard()
  * oGet:insert(clipboard())
case ( key == K_ENTER )
  oGet:exitState := GE_ENTER
case (key == K_F1) ; GetDoPick(oGet)
case ( key == K_ESC )
  if set(_SET_ESCAPE)
    oGet:undo()
    oGet:exitState := GE_ESCAPE
  endif
case ( key == K_CTRL_HOME ) ; oGet:exitState := GE_TOP
#ifdef CTRL_END_SPECIAL  // both ^W and ^End go to the last GET
   case (key == K_CTRL_END) ; oGet:exitState := GE_BOTTOM
#endif
case (key == K_INS)
  if readinsert( !readinsert() )
    setcursor(SC_NORMAL)
  else
    setcursor(SC_INSERT)
  endif
case (key == K_UNDO)       ; oGet:Undo()
case (key == K_HOME)       ; oGet:Home()
#ifdef __XPP__
  case (key == K_END)        ; oGet:_end()
#else
  case (key == K_END)        ; oGet:End()
#endif
case (key == K_RIGHT)      ; oGet:Right()
case (key == K_LEFT)       ; oGet:Left()
case (key == K_CTRL_RIGHT) ; oGet:WordRight()
case (key == K_CTRL_LEFT)  ; oGet:WordLeft()
case (key == K_BS)         ; oGet:BackSpace()
case (key == K_DEL)        ; oGet:Delete()
case (key == K_CTRL_T)     ; oGet:DelWordRight()
case (key == K_CTRL_Y)     ; oGet:DelEnd()
case (key == K_CTRL_BS)    ; oGet:DelWordLeft()
otherwise
  if key >= 32 .and. key <= 255
    cKey := chr(key)
    if (oGet:type == T_NUMERIC .and. (cKey == "." .or. cKey == ","))
      oGet:ToDecPos()
    else
      if oGet:type == T_DATE
        if empty(oGet:VarGet())
          * .and. (empty(ptod(MrkInstall)).or.UserDate()<=ptod(MrkInstall))
          oGet:VarPut(UserDate())
          oGet:updateBuffer()
        endif
        if cKey == "+"
          oGet:changed := .t.
          oGet:VarPut(oGet:VarGet() + 1)
          oGet:updateBuffer()
          RETURN
        elseif cKey == "-"
          oGet:changed := .t.
          oGet:VarPut(oGet:VarGet() - 1)
          oGet:updateBuffer()
          RETURN 
        elseif cKey == " "
          oGet:changed := .t.
          oGet:VarPut(ctod(""))
          oGet:updateBuffer()
          RETURN 
        endif
      endif
      if Set(_SET_INSERT)
        oGet:Insert(cKey)
      else
        oGet:Overstrike(cKey)
      endif
      if oGet:typeOut
        if ! Set(_SET_CONFIRM)
          oGet:exitState := GE_ENTER
        else
          Alarm()
        endif
      endif
    endif
  else
    OtherKey(oGet,key)
  endif
endcase
RETURN
* #endif __XPP__

* FUNCTION clipboard(cText)
* *if ! ol_WinCBPaste(cText)
*   scFldBuffer := cText
* *endif
* SetMsg('"'+cText+'"')
* RETURN NIL
*
* FUNCTION GetPasteBuffer()
* *local cText := ol_WinCBCopy()
* *SetMsg("Alt-Ins")
* *if empty(cText)
*   keyboard scFldBuffer
* *else
* *  keyboard scFldBuffer
* *endif
* RETURN NIL

STATIC PROCEDURE OtherKey(oGet,key)
local i
if key != K_MOUSE_EVENT .and. key != K_ALT
  * for i := 1 to len(saGetList)
  *   if saGetList[i]:cargo[AG_HOTKEY] == key
  *     BouncePos := i
  *     oGet:exitState := GE_BOUNCE
  *     RETURN
  *   endif
  * next i
  oGet:exitState := GE_WRITE
endif
RETURN

**
**  CbxApplyKey()
**  Apply a single Inkey() keystroke to a (focussed) CHECKBOX oGet.
**
PROCEDURE CbxApplyKey(oGet, key)
local cKey
local bKeyBlock
// check for SET KEY first
if ( (bKeyBlock := SetKey(key)) <> NIL )
  GetDoSetKey(bKeyBlock, oGet)
  RETURN                                                             // NOTE
endif
do case
case ( key == K_UP )     ; oGet:exitState := GE_UP
case ( key == K_SH_TAB ) ; oGet:exitState := GE_UP
case ( key == K_DOWN )   ; oGet:exitState := GE_DOWN
case ( key == K_TAB )    ; oGet:exitState := GE_DOWN
#ifdef ENTER_STOPS
  * case ( key == K_ENTER )  ; oGet:exitState := GE_WRITE // GE_ENTER
#else
  case ( key == K_ENTER )  ; oGet:exitState := GE_ENTER
#endif
case (key == K_F1) ; GetDoPick(oGet)
case ( key == K_ESC )
  if set(_SET_ESCAPE)
    oGet:undo()
    oGet:exitState := GE_ESCAPE
  endif
* case ( key == K_PGUP )      ; oGet:exitState := GE_WRITE
* case ( key == K_PGDN )      ; oGet:exitState := GE_WRITE
case ( key == K_CTRL_HOME ) ; oGet:exitState := GE_TOP
#ifdef CTRL_END_SPECIAL  // both ^W and ^End go to the last GET
   case (key == K_CTRL_END) ; oGet:exitState := GE_BOTTOM
* #else                    // both ^W and ^End terminate the READ (the default)
*    case (key == K_CTRL_W) ;   oGet:exitState := GE_WRITE
#endif
case (key == K_INS)
  oGet:varPut(BUTTON_ON)
  oGet:updateBuffer()
case (key == K_DEL)
  oGet:varPut(BUTTON_OFF)
  oGet:updateBuffer()
  * Set( _SET_INSERT, !Set(_SET_INSERT) )
  * ShowScoreboard()
case (key == K_CTRL_Y)     ; oGet:DelEnd()
case (key == K_UNDO)       ; oGet:Undo()
otherwise
  if key >= 32 .and. key <= 255
    if empty( oGet:buffer )
      oGet:varPut(BUTTON_ON)
    else
      oGet:varPut(BUTTON_OFF)
    endif
    oGet:updateBuffer()
  else
    OtherKey(oGet,key)
    * if key != K_MOUSE_EVENT .and. key != K_ALT
    *   oGet:exitState := GE_WRITE
    * endif
  endif
endcase
RETURN


#ifndef __XPP__
**
** GetPreValidate()
** Test entry condition (WHEN clause) for a GET.
**
FUNCTION GetPreValidate(oGet)
local saveUpdated
local lWhen := .t.
* RETURN .f. if IsReadOnly()
* Nein : ph_read() wird ja gar nicht aufgerufen, wenn Daten nicht
* bearbeitet werden dÅrfen. Aber selbst in einer read-only Datebank
* kînnen z.B. Dialogfenster bearbeitet werden. Logisch.
if oGet:preBlock != NIL
  saveUpdated := slUpdated
  lWhen := eval(oGet:preBlock, oGet)
  #ifdef DEF_WRITE
    if USRATTR_W $ UsrAttrib()
      lWhen := .t.
    endif
  #endif DEF_WRITE
  * oGet:Display()       ausgeklammert weil nicht nîtig bei mir...
  * ShowScoreBoard()
  slUpdated := saveUpdated
endif
if slKillRead
  lWhen := .f.
  oGet:exitState := GE_ESCAPE           // provokes ReadModal() exit
elseif ! lWhen
  oGet:exitState := GE_WHEN             // indicates failure
else
  oGet:exitState := GE_NOEXIT           // prepares for editing
endif
RETURN (lWhen)
#endif __XPP__


**
** GetDoPick()
**
STATIC FUNCTION GetDoPick(oGet)
local uNewVal
RETURN NIL if oGet:cargo == NIL
if oGet:cargo[AG_PICKBLK] == NIL .and. oGet:type != T_DATE
  RETURN NIL
endif
if oGet:changed
  #ifdef __XPP__
    oGet:_assign()
  #else
    oGet:Assign()
  #endif
  slUpdated := .t.
endif
* #ifdef MONKEY
*   SendKey(K_ENTER)
* #endif
if oGet:type == T_DATE
  uNewVal := PickDate(oGet:varGet())
else
  uNewVal := eval(oGet:cargo[AG_PICKBLK],oGet:buffer,oGet:row,oGet:col)
  * uNewVal := eval(oGet:cargo[AG_PICKBLK],oGet:varGet(),oGet:row,oGet:col)
endif
if uNewVal != NIL
  oGet:varPut(uNewVal) // unerklÑrter bug bei PickStreet() nach ParCreate
  * eval(oGet:block,uNewVal) // das geht nicht in DlgExec() (via array)
  oGet:updateBuffer()
  oGet:changed := .t.
  * if len(saGetList) == 1
  *   oGet:exitState := GE_ENTER
  * elseif len(saGetList) == 1
  if len(saGetList) == 1 .or. snCurGetPos < len(saGetList)
    oGet:exitState := GE_ENTER
    // 19980701 oGet:exitState := GE_DOWN
  * else
  *   for i := snCurGetPos to len(saGetList)
  *     oGet:exitState := GE_DOWN
  *   next i
    nKey := K_ENTER
  endif
  /*
  19980716 : Wenn Irene im vorletzten Feld der Bildschirmmaske mit [F1]
  eine andere Kontonummer ausgewÑhlt hatte (das letzte Feld war
  read-only) und das Feld dann mit Enter verlie·, dann kam ging in
  ImpPostEdit() die ImpImlEdit() nicht los. Weil hier nKey auf 0 gesetzt
  worden war. Und weil hier nicht nachgeschaut wird, ob denn die
  folgenden Felder read-only sind.
  */
  * slUpdated := .t.
  * oGet:reset() // Versuchsweise raus. NÅtzt nix.
else
  oGet:display() // sonst ist evtl Cursor nicht mehr da.
endif
RETURN NIL


#ifndef __XPP__
**
** GetPostValidate()
** Test VALID clause for a GET
**
** NOTE: bad dates are rejected in such a way as to preserve edit buffer.
**
FUNCTION GetPostValidate(oGet)
local saveUpdated
local lValid := .t.
local i
local aTrig
if oGet:exitState == GE_ESCAPE
  RETURN .t.
endif
if oGet:BadDate()
  oGet:Home()
  RETURN .f.
endif
if ! oGet:changed
  RETURN .T.
endif
//
// if editing occurred, assign the new value to the variable
//
if oGet:cargo[AG_POSTEDIT] != NIL
  oGet:buffer := eval(oGet:cargo[AG_POSTEDIT],oGet:buffer)
endif
**
**
#ifdef __XPP__
  oGet:_assign()
#else
  oGet:Assign()
#endif
slUpdated := .t.
* if oGet:type == T_DATE .and. ! empty(oGet:varGet())
*   if year(oGet:varGet()) < set(_SET_EPOCH) // Shift2000()
*     oGet:varPut(SkipJahr(oGet:varGet(),100))
*   endif
* endif
oGet:Reset()    // reform edit buffer, set cursor to home position, redisplay
if oGet:postBlock <> NIL   // check VALID clause if specified
  saveUpdated := slUpdated
  * setpos( oGet:row, oGet:col + len(oGet:buffer) )   // Summer '87 compatibility
  lValid := eval(oGet:postBlock, oGet)
  * setpos( oGet:row, oGet:col )                     // reset compat. pos
  * ShowScoreBoard()
  oGet:updateBuffer()
  slUpdated := saveUpdated
  if slKillRead
    oGet:exitState := GE_ESCAPE                  // provokes ReadModal() exit
    lValid := .t.
  endif
endif
#ifdef DEF_BRAND
  if oGet:Type == T_DATE
    if ! empty(ptod(MrkInstall))
      if oGet:VarGet() > ptod(MrkInstall)
        SetMsg(MSG001 + dtoc(ptod(MrkInstall)))
        RETURN .F.
      endif
    endif
  endif
#endif
RETURN lValid
#endif __XPP__


FUNCTION ph_Refresh()
local i
local nRow := row()
local nCol := col()
if saGetList != NIL
  for i := 1 to len(saGetList)
    saGetList[i]:updateBuffer()
    FldDisplay(saGetList[i])
    * saGetList[i]:display()
  next i
endif
if saMsk != NIL
  MskSayAgain(saMsk)
  * 19980422 : Wenn ph_refresh() in der valid-Klausel eines dlg-Felds
  * aufgerufen wird, dann verursachte dieses MskSayAgain() entweder
  * Bildschirmstîrungen (das Dialogfenster wurde Åberschrieben) oder sogar
  * einen RTE (wenn vorher zufÑllig keine MSK aktiv war). Edy hatte diesen
  * Bug bei einer Demo (aber Bill Gates hatte einige Tage zuvor ja auch
  * einen berÅhmt gewordenen Demo-Effekt gehabt...)
endif
setpos(nRow,nCol)
RETURN .t.

FUNCTION ph_FldRefresh(i)
local nRow := row()
local nCol := col()
local g := saGetList[i]
FldDisplay(g)
setpos(nRow,nCol)
RETURN .t.


#ifndef __XPP__
**
** GetDoSetKey()
** Process SET KEY during editing.
**
PROCEDURE GetDoSetKey(keyBlock, oGet)
local saveUpdated
// if editing has occurred, assign variable
if ( oGet:changed )
  #ifdef __XPP__
    oGet:_assign()
  #else
    oGet:Assign()
  #endif
  slUpdated := .t.
endif
saveUpdated := slUpdated
eval(keyBlock, ReadProcName, ReadProcLine, ReadVar())
* ShowScoreboard()
oGet:UpdateBuffer()
slUpdated := saveUpdated
if slKillRead
  oGet:exitState := GE_ESCAPE              // provokes ReadModal() exit
endif
RETURN
#endif __XPP__



// PTH Additional services

**
** GetGotoFld ( newfld )
** Hop right to a new field
**
FUNCTION GetGotoFld ( newfld )
BouncePos := newFld
ActiveGet:exitState := GE_BOUNCE
RETURN newFld

#ifdef DEF_MOUSE

//
// DoMouse ( )
// will be called upon each mouse click
//
FUNCTION DoMouse ( )
LOCAL MouseFld
LOCAL m_row, m_col, m_but
//
// oGet mouse position
mouse_mchk (@m_row, @m_col, @m_but)
//
// check for button 1
if ( m_but == 1 )
  // Find out what field I am dealing with (if any)
  MouseFld := ascan ( saGetList, ;
    { |fld| fld:row == m_row .and. ;
            fld:col <= m_col .and. ;
            fld:col+len(transform(fld:varGet,fld:picture)) > m_col } )
  if ( MouseFld != 0 )
    if ( snCurGetPos == MouseFld ) .and. ( InButton == TRUE )
       keyboard ( chr ( K_SPACE ) )
    endif
    * if another field
      GetGotoFld ( MouseFld )
      FldPos := -1
    * else
    *   FldPos := m_col - saGetList[MouseFld]:col + 1
    * endif
  * else
  *   tone ( 1000 )
  endif
* elseif ( m_but == 2 )
*   ActiveGet:exitState := GE_ESCAPE
* elseif ( m_but == 3 ) .or. ( m_but == 4 )
*   ActiveGet:exitState := GE_WRITE
* else
*   tone ( 5000 )
endif
RETURN NIL

#endif

#ifdef __XPP__

FUNCTION GetSetFocus ( oGet )
oGet:setFocus()
RETURN NIL

#else
//
// GetSetFocus ( oGet )
//
// Simple function which will set the current focus
// AND cursor position within the field (for better mouse support)
//
FUNCTION GetSetFocus ( oGet )
oGet:SetFocus()
if FldPos != -1
  if len( transform( oGet:varGet, oGet:picture ))  >  FldPos
    oGet:pos := FldPos
    #ifdef DEF_MOUSE
      MOUSE_OFF ( )
    #endif
    * FldDisplay(oGet)
    oGet:Display()
    #ifdef DEF_MOUSE
      MOUSE_ON ( )
    #endif
  endif
endif
FldPos := -1
scLastGet := oGet:name
RETURN NIL

#endif

FUNCTION LastGet(cNew)
if cNew != NIL
  scLastGet := cNew
endif
RETURN scLastGet


/***
*  YNReader ( )
*  READER function for buttons
*/
* PROCEDURE YNReader( oGet )
* local old_cursor := setcursor ( SC_NONE )
* local key, bKeyBlock
* // Set the button flag
* InButton := TRUE
* // read the GET if the WHEN condition is satisfied
* if ( GetPreValidate ( oGet ) )
*    GetSetFocus ( oGet )
*    do while ( oGet:exitState == GE_NOEXIT )
*      // check for initial typeout (no editable positions)
*      if ( oGet:typeOut )
*        oGet:exitState := GE_ENTER
*      endif
*      do while ( oGet:exitState == GE_NOEXIT )
*        key := RdKey ()
*        // check for SET KEY first
*        if ( (bKeyBlock := SetKey(key)) <> NIL )
*          GetDoSetKey(bKeyBlock, oGet)
*        else
*          do case
*          case ( key == K_UP )     ; oGet:exitState := GE_UP
*          case ( key == K_SH_TAB ) ; oGet:exitState := GE_UP
*          case ( key == K_DOWN )   ; oGet:exitState := GE_DOWN
*          case ( key == K_TAB )    ; oGet:exitState := GE_DOWN
*          case ( key == K_ENTER )  ; oGet:exitState := GE_WRITE // GE_ENTER
*          case ( key == K_ESC )
*            if ( Set(_SET_ESCAPE) )
*              oGet:undo()
*              oGet:exitState := GE_ESCAPE
*            endif
*          case ( key == K_PGUP )      ; oGet:exitState := GE_WRITE
*          case ( key == K_PGDN )      ; oGet:exitState := GE_WRITE
*          case ( key == K_CTRL_HOME ) ; oGet:exitState := GE_TOP
* #ifdef CTRL_END_SPECIAL
*             // both ^W and ^End go to the last GET
*             case (key == K_CTRL_END) ; oGet:exitState := GE_BOTTOM
* #else
*             // both ^W and ^End terminate the READ (the default)
*             case (key == K_CTRL_W) ; oGet:exitState := GE_WRITE
* #endif
*          case (key == K_INS)
*             Set( _SET_INSERT, !Set(_SET_INSERT) )
*             ShowScoreboard()
*          case (key == K_UNDO)       ; oGet:Undo()
*          case (key == K_HOME)       ; oGet:Home()
*          case (key == K_END)        ; oGet:End()
*          case (key == K_RIGHT)      ; oGet:Right()
*          case (key == K_LEFT)       ; oGet:Left()
*          case (key == K_CTRL_RIGHT) ; oGet:WordRight()
*          case (key == K_CTRL_LEFT)  ; oGet:WordLeft()
*          case (key == K_BS)         ; oGet:BackSpace()
*          case (key == K_DEL)        ; oGet:Delete()
*          case (key == K_CTRL_T)     ; oGet:DelWordRight()
*          case (key == K_CTRL_Y)     ; oGet:DelEnd()
*          case (key == K_CTRL_BS)    ; oGet:DelWordLeft()
*          case ( key == K_SPACE )
*            oGet:varPut ( !oGet:varGet ( ) )
*            oGet:updateBuffer ( )
*          case ( key == K_UPPER_Y ) .or. ( key == K_LOWER_Y ) .or. ;
*               ( key == K_UPPER_T ) .or. ( key == K_LOWER_T ) .or. ;
*               ( key == K_PLUS ) .or.    ( key == K_EQUAL )
*             oGet:varPut ( TRUE )
*             oGet:updateBuffer ( )
*          case ( key == K_UPPER_N ) .or. ( key == K_LOWER_N ) .or. ;
*               ( key == K_UPPER_F ) .or. ( key == K_LOWER_F ) .or. ;
*               ( key == K_MINUS ) .or.   ( key == K_BAR )
*             oGet:varPut ( FALSE )
*             oGet:updateBuffer ( )
*          endcase
*        endif
*      enddo
*      // disallow exit if the VALID condition is not satisfied
*      if ( !GetPostValidate(oGet) )
*        oGet:exitState := GE_NOEXIT
*      endif
*    enddo
*    // de-activate the GET
*    oGet:KillFocus()
* endif
* InButton := FALSE
* setcursor ( old_cursor )
* RETURN





**
**  RdKey()
**
* 20030211
*FUNCTION RdKey()
*local retval := WaitKey()
*local nKeyPos := ascan ( saReadKeys, { |elem| elem[1] == retval } )
*local bKeyBlock, KeyType, nFldPos
*if nKeyPos != 0
*   bKeyBlock := saReadKeys[nKeyPos][2]
*   KeyType  := valtype (bKeyBlock)
*   do case
*   case ( KeyType == T_NUMERIC )
*      GetGotoFld ( bKeyBlock )
*   case ( KeyType == T_BLOCK )
*      eval (bKeyBlock, ActiveGet, saGetList )
*   case ( KeyType == T_CHARACTER )
*      nFldPos := ascan ( saGetList, { |g| g:name == bKeyBlock } )
*      if ( nFldPos != 0 )
*         GetGotoFld ( nFldPos )
*      endif
*   endcase
*endif
*RETURN retval


/**************************
*
*	READ services
*
*/


**
**  Settle()
**
**  Returns new position in array of Get objects, based on
**    - current position
**    - exitState of Get object at current position
**
**  Notes : Return value of 0 indicates termination of READ
**          exitState of old Get is transferred to new Get (because ...?)
**
static FUNCTION Settle(aList, nPos)
local nExitState
if nPos == 0
  nExitState := GE_ENTER
else
  nExitState := aList[nPos]:exitState
  if nExitState == NIL      // only if phRead() was called with a startup field
    * snLastExit  := GE_DOWN
    nExitState := GE_NOEXIT
    // nExitState := GE_NOEXIT oder GE_DOWN ...?
    RETURN nPos
  endif
endif
if nExitState == GE_ESCAPE .or. nExitState == GE_WRITE
  RETURN 0
endif
if nExitState == GE_WHEN
  nExitState := snLastExit  // re-use last exitState, do not disturb state info
else
  // LastPos := nPos        // reset state info
  BumpTop := .f.
  BumpBot := .f.
endif
do case
case ( nExitState == GE_UP )    ;  nPos --
case ( nExitState == GE_DOWN )  ;  nPos ++
case ( nExitState == GE_ENTER ) ;  nPos ++
case ( nExitState == GE_TOP )
  nPos := 1
  BumpTop := .T.
  nExitState := GE_DOWN
case ( nExitState == GE_BOTTOM )
  nPos := len(aList)
  BumpBot := .T.
  nExitState := GE_UP // falls das letzte Get z.B. durch WHEN desaktiviert wÑre
case ( nExitState == GE_BOUNCE )
  nPos := BouncePos
  nExitState := GE_DOWN
endcase
snLastExit := nExitState
//
//   bounce
//
if nPos == 0                         // bumped top
  if ! readexit() .and. ! BumpBot
    * if set ( _SET_WRAP )
      nPos := len(aList)
      nExitState := GE_UP
    * else
    *   BumpTop := TRUE
    *   nPos := LastPos
    *   nExitState := GE_DOWN
    * endif
  endif
elseif nPos > len(aList)          // bumped bottom
  nPos := 0
  if nExitState == GE_ENTER        // neu Luc 921130
    nExitState := GE_WRITE         // neu Luc 921130
  else
    if len(aList) > 1             // one-field screens exit quickly (Luc)
      if ! ReadExit() .and. !BumpTop
        nPos := 1
        nExitState := GE_DOWN
      endif
    endif
  endif
endif
//
if nPos != 0
  aList[nPos]:exitState := nExitState
endif
RETURN nPos


**
**  PostActiveGet()
**  Post active GET for ReadVar(), GetActive().
**
static PROCEDURE PostActiveGet(oGet)
GetActive( oGet )
ReadVar( GetReadVar(oGet) )
* ShowScoreBoard()
RETURN



/*
**  ClearGetSysVars ( NewList, NewKeys )
**       Save and clear READ state variables. Return array of saved values.
**
**       NOTE: 'slUpdated' status is cleared but not saved (S87 compat.).
*/
static FUNCTION ClearGetSysVars ( NewList, NewKeys )
local saved[ GSV_COUNT ]
saved[GSV_KILLREAD]     := slKillRead       ; slKillRead := .f.
saved[GSV_BUMPTOP]      := BumpTop          ; BumpTop := .f.
saved[GSV_BUMPBOT]      := BumpBot          ; BumpBot := .f.
saved[GSV_LASTEXIT]     := snLastExit       ; snLastExit := GE_ENTER
saved[GSV_LASTPOS]      := LastPos          ; LastPos := 0
saved[GSV_ACTIVEGET]    := GetActive( NIL )
saved[GSV_READVAR]      := ReadVar( "" )
saved[GSV_READPROCNAME] := ReadProcName     ; ReadProcName := ""
saved[GSV_READPROCLINE] := ReadProcLine     ; ReadProcLine := 0
saved[GSV_CURGETPOS]    := snCurGetPos        ; snCurGetPos := 0
saved[GSV_BOUNCEPOS]    := BouncePos        ; BouncePos := 0
saved[GSV_FLDPOS]       := FldPos           ; FldPos := -1
saved[GSV_GETLIST]      := saGetList        ; saGetList := NewList
saved[GSV_INBUTTON]     := InButton         ; InButton := FALSE
saved[GSV_READKEYS]     := saReadKeys       ; saReadKeys := NewKeys
slUpdated := .f.
RETURN saved


/***
*   RestoreGetSysVars()
*	Restore READ state variables from array of saved values.
*
*       NOTE: 'slUpdated' status is not restored (S87 compat.).
*/
static PROCEDURE RestoreGetSysVars(saved)
slKillRead  := saved[ GSV_KILLREAD ]
BumpTop     := saved[ GSV_BUMPTOP ]
BumpBot     := saved[ GSV_BUMPBOT ]
snLastExit    := saved[ GSV_LASTEXIT ]
LastPos     := saved[ GSV_LASTPOS ]
GetActive( saved[ GSV_ACTIVEGET ] )
ReadVar( saved[ GSV_READVAR ] )
ReadProcName := saved[ GSV_READPROCNAME ]
ReadProcLine := saved[ GSV_READPROCLINE ]
snCurGetPos    := saved[ GSV_CURGETPOS ]
BouncePos    := saved[ GSV_BOUNCEPOS ]
FldPos       := saved[ GSV_FLDPOS ]
saGetList    := saved[ GSV_GETLIST ]
InButton     := saved[ GSV_INBUTTON ]
saReadKeys   := saved[ GSV_READKEYS ]
RETURN


/***
*
*       GetReadVar()
*       Set READVAR() value from a GET.
*/
static FUNCTION GetReadVar(oGet)
local cName := upper(oGet:name)
//#ifdef SUBSCRIPT_IN_READVAR
local i
/***
*       The following code includes subscripts in the name returned by
*       this function, if the oGet variable is an array element.
*
*       Subscripts are retrieved from the oGet:subscript instance variable.
*
*       NOTE: incompatible with Summer 87
*/
if ( oGet:subscript <> NIL )
  for i := 1 to len(oGet:subscript)
    cName += "[" + ltrim(str(oGet:subscript[i])) + "]"
  next
endif
//#endif
RETURN cName


/**********************
*
*	system services
*
*/



/***
*   __SetFormat()
*       SET FORMAT service
*/
FUNCTION __SetFormat(b)
   sbFormat := if ( ValType(b) == T_BLOCK, b, NIL )
RETURN NIL


/***
*	__KillRead()
*   CLEAR GETS service
*/
PROCEDURE __KillRead()
  slKillRead := .t.
RETURN


#ifndef __XPP__
**
**       GetActive()
**
FUNCTION GetActive(g)
local oldActive := ActiveGet
if pcount() > 0
  ActiveGet := g
endif
RETURN oldActive

FUNCTION Updated()        ; RETURN slUpdated
FUNCTION ReadExit(lNew)   ; RETURN Set(_SET_EXIT, lNew)
FUNCTION ReadInsert(lNew) ; RETURN Set(_SET_INSERT, lNew)

#endif __XPP__

FUNCTION CurGetPos        ; RETURN snCurGetPos



/**********************************
*
*	wacky compatibility services
*
*/


// display coordinates for SCOREBOARD
#define SCORE_ROW		0
#define SCORE_COL		60


/***
*   ShowScoreboard()
*/
* static PROCEDURE ShowScoreboard()
* local nRow, nCol
* if ( Set(_SET_SCOREBOARD) )
*    nRow := Row()
*    nCol := Col()
*    SetPos(SCORE_ROW, SCORE_COL)
*    DispOut( if(Set(_SET_INSERT), "Ins", "   ") )
*    SetPos(nRow, nCol)
* endif
* return



/*
** DateMsg()
*/
static PROCEDURE DateMsg()
local nRow, nCol
if ( Set(_SET_SCOREBOARD) )
  nRow := Row()
  nCol := Col()
  SetPos(SCORE_ROW, SCORE_COL)
  DispOut("Invalid Date")
  SetPos(nRow, nCol)
  while ( Nextkey() == 0 )
  end
  SetPos(SCORE_ROW, SCORE_COL)
  DispOut("            ")
  SetPos(nRow, nCol)
endif
return


#ifndef __XPP__
/*
**   RangeCheck()
**
**       NOTE: unused second param for 5.00 compatibility.
*/
FUNCTION RangeCheck(oGet, junk, lo, hi)
local cMsg, nRow, nCol
local xValue
if ( !oGet:changed )
  return (.t.)
endif
xValue := oGet:VarGet()
if ( xValue >= lo .and. xValue <= hi )
        return (.t.)                                                                    // NOTE
endif
if ( Set(_SET_SCOREBOARD) )
  cMsg := "Range: " + Ltrim(Transform(lo, "")) + ;
                  " - " + Ltrim(Transform(hi, ""))
  if ( Len(cMsg) > MaxCol() )
    cMsg := Substr( cMsg, 1, MaxCol() )
  endif
  nRow := Row()
  nCol := Col()
  SetPos( SCORE_ROW, Min(60, MaxCol() - Len(cMsg)) )
  DispOut ( cMsg )
  SetPos(nRow, nCol)
  while ( NextKey() == 0 )
  end
  SetPos( SCORE_ROW, Min(60, MaxCol() - Len(cMsg)) )
  DispOut( Space(Len(cMsg)) )
  SetPos(nRow, nCol)
endif
return (.f.)
#endif __XPP__

FUNCTION LastExit
RETURN snLastExit

// EOF: PHREAD.PRG
