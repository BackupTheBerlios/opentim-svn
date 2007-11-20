** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2007 Luc Saffre
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
#include "Set.ch"
#include "Getexit.ch"
#include "Lib.ch"

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
local get
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
    * if aList[i]:cargo == NIL ; raise(aList[i]:name+" get:cargo is NIL") ; endif
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
   get := aList[snCurGetPos]
   PostActiveGet( get )
   uOldValue := get:varGet()
   if valtype(get:reader) == T_BLOCK
     eval(get:reader, get)                 // use custom reader block
   else
     MyGetReader(get)                        // use standard reader
   endif
   if get:exitState != GE_WHEN
     LastPos   := snCurGetPos // 19981029 war vorher eine Zeile hîher
     snLastExit  := get:exitState
     if get:cargo[AG_AFTER] != NIL
       eval(get:cargo[AG_AFTER],uOldValue)
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
PROCEDURE MyGetReader( get )
#ifdef MONKEY
  static snErrCount := 0
#endif
if ! GetPreValidate(get)
  RETURN    // read it only if the WHEN clause is satisfied
endif
if empty(get:picture) .and. get:type != "D"
  get:picture := "@K"
endif
GetSetFocus ( @get )    // activate the GET for reading
do while get:exitState == GE_NOEXIT
  if get:typeOut        // check for initial typeout (no editable positions)
    get:exitState := GE_ENTER
  endif
  do while ( get:exitState == GE_NOEXIT )
    GetApplyKey( get, WaitKey() )
    * 20030211 GetApplyKey( get, RdKey() )
  enddo
  if ! GetPostValidate(get)
    get:exitState := GE_NOEXIT   // VALID condition not satisfied
  endif
enddo
get:KillFocus()   // de-activate the GET
RETURN
* #endif __XPP__


**
**  CbxReader()
**  READER procedure for CHECKBOX get objects
**
PROCEDURE CbxReader( get )
* local uOldValue
if ! GetPreValidate(get)
  RETURN    // read it only if the WHEN clause is satisfied
endif
GetSetFocus ( @get )    // activate the GET for reading
* uOldValue := get:varget()
do while get:exitState == GE_NOEXIT
  if get:typeOut        // check for initial typeout (no editable positions)
    get:exitState := GE_ENTER
  endif
  do while ( get:exitState == GE_NOEXIT )
    CbxApplyKey( get, WaitKey() )
    * 20030210 CbxApplyKey( get, RdKey() )
  enddo
  if ! GetPostValidate(get)
    get:exitState := GE_NOEXIT   // VALID condition not satisfied
  endif
enddo
get:KillFocus()   // de-activate the GET
RETURN


**
**  MemoReader()
**  READER procedure for multiline get objects
**  note : the picture of a memo field contains a hand-made picture string
**  of the form "40x4" (width x height)
PROCEDURE MemoReader( get )
local nWaitKey
local cColor := setcolor()
local nWidth  := val(left(get:picture,2))      // MEMO_PICTURE
local nHeight := val(substr(get:picture,4))    // MEMO_PICTURE
local cSaveScreen := savescreen( ;
  get:row, ;
  get:col+nWidth, ;
  get:row+nHeight, ;
  get:col+nWidth+1  ;
)
if ! GetPreValidate(get)
  RETURN    // read it only if the WHEN clause is satisfied
endif
setcolor(CfgWindowColor())
* GetSetFocus(get)
scLastGet := get:name
** 19990210 die folgende Schleife ist nîtig, weil wenn man bei HK
** durch eine Data-Key hierhin kommt, dann kommt diese nicht in den
** keyboard-buffer des TxtEdit() und erschien stattdessen nach
** Beenden des Editors im nÑchsten Feld...
do while (nWaitKey := PopKey()) != 0
  keyboard chr(nWaitKey)
enddo
do while get:exitState == GE_NOEXIT
  * if get:typeOut        // check for initial typeout (no editable positions)
  *   get:exitState := GE_ENTER
  * endif
  TxtEdit( ;
    get:block, ;
    get:row, ;
    get:col, ;
    get:row + nHeight - 1 , ;
    get:col + nWidth, ;
    .t., ;
    NIL, ;
    get:cargo[AG_PICKBLK], ;
    .t. ;
  )
  if TxtExitState() == TXT_UP
    get:exitState := GE_UP
  * elseif TxtExitState() == TXT_DOWN
  *   get:exitState := GE_DOWN
  * elseif lastkey() == K_SH_TAB
  *   get:exitState := GE_UP
  elseif lastkey() == K_ESC
    get:exitState := GE_ESCAPE
  elseif lastkey() == K_F10
    get:exitState := GE_WRITE
  else
    get:exitState := GE_DOWN
  endif
  * do while ( get:exitState == GE_NOEXIT )
  *   GetApplyKey( get, RdKey() )
  * enddo
  if ! GetPostValidate(get)
    get:exitState := GE_NOEXIT   // VALID condition not satisfied
  endif
enddo
restscreen( ;
  get:row, ;
  get:col+nWidth, ;
  get:row+nHeight, ;
  get:col+nWidth+1, ;
  cSaveScreen, ;
)
* get:KillFocus()   // de-activate the GET
setcolor(cColor)
RETURN




**
**  ButtonReader ( )
**  READER function for buttons
**
*PROCEDURE ButtonReader( get )
*local nSaveCursor
*local key, bKeyBlock
*if ! GetPreValidate ( get )
*  RETURN
*endif
*nSaveCursor := setcursor ( SC_NONE )
*// Set the button flag
*InButton := TRUE
*// read the GET if the WHEN condition is satisfied
*GetSetFocus ( get )
*do while ( get:exitState == GE_NOEXIT )
*  // check for initial typeout (no editable positions)
*  if ( get:typeOut )
*    get:exitState := GE_ENTER
*  endif
*  do while ( get:exitState == GE_NOEXIT )
*    key := RdKey ()
*    // check for SET KEY first
*    if ( (bKeyBlock := SetKey(key)) <> NIL )
*      GetDoSetKey(bKeyBlock, get)
*    else
*      do case
*      case ( key == K_UP )     ; get:exitState := GE_UP
*      case ( key == K_SH_TAB ) ; get:exitState := GE_UP
*      case ( key == K_DOWN )   ; get:exitState := GE_DOWN
*      case ( key == K_TAB )    ; get:exitState := GE_DOWN
*      case ( key == K_ENTER ) .or. ( key == K_SPACE )
*         // disallow action if bad valid
*         if GetPostValidate(get)
*           eval ( get:cargo[AG_BUTTON] )
*         endif
*      case ( key == K_ESC )
*         if ( Set(_SET_ESCAPE) )
*            get:undo()
*            get:exitState := GE_ESCAPE
*         end
*      case ( key == K_CTRL_HOME ) ; get:exitState := GE_TOP
*#ifdef CTRL_END_SPECIAL
*         // both ^W and ^End go to the last GET
*      case (key == K_CTRL_END) ; get:exitState := GE_BOTTOM
*#else
*         // both ^W and ^End terminate the READ (the default)
*      case (key == K_CTRL_W) ; get:exitState := GE_WRITE
*#endif
*      * case (key == K_UNDO)  ; get:Undo()
*      * case (key == K_HOME)  ; get:Home()
*      * case (key == K_END)   ; get:End()
*      * case (key == K_RIGHT) ; get:Right()
*      * case (key == K_LEFT)    ; get:Left()
*      * case (key == K_CTRL_RIGHT) ; get:WordRight()
*      * case (key == K_CTRL_LEFT) ; get:WordLeft()
*      * case (key == K_BS) ; get:BackSpace()
*      * case (key == K_DEL) ; get:Delete()
*      * case (key == K_CTRL_T) ; get:DelWordRight()
*      * case (key == K_CTRL_Y) ; get:DelEnd()
*      * case (key == K_CTRL_BS) ; get:DelWordLeft()
*      otherwise
*        OtherKey(get,key)
*        * if key != K_MOUSE_EVENT .and. key != K_ALT
*        *   get:exitState := GE_WRITE
*        * endif
*      endcase
*    endif
*  enddo
*  // disallow exit if the VALID condition is not satisfied
*  if ( !GetPostValidate(get) )
*    get:exitState := GE_NOEXIT
*  endif
*enddo
*// de-activate the GET
*get:KillFocus()
*InButton := FALSE
*setcursor ( nSaveCursor )
*RETURN


* #ifndef __XPP__
**
** Apply a single Inkey() keystroke to a (focussed) GET.
**
PROCEDURE GetApplyKey(get, key)
local cKey
local bKeyBlock
// check for SET KEY first
if (bKeyBlock := SetKey(key)) <> NIL
  GetDoSetKey(bKeyBlock, get)
  RETURN                                                   // NOTE
endif
do case
case ( key == K_UP )     ; get:exitState := GE_UP
case ( key == K_SH_TAB ) ; get:exitState := GE_UP
case ( key == K_DOWN )   ; get:exitState := GE_DOWN
case ( key == K_TAB )    ; get:exitState := GE_DOWN
case ( key == K_CTRL_INS )  ; clipboard(trim(get:buffer))
case ( key == K_ALT_INS )
  GetPaste(get,clipboard())
  * GetPasteBuffer()
  * keyboard clipboard()
  * get:insert(clipboard())
case ( key == K_ENTER )
  get:exitState := GE_ENTER
case (key == K_F1) ; GetDoPick(get)
case ( key == K_ESC )
  if set(_SET_ESCAPE)
    get:undo()
    get:exitState := GE_ESCAPE
  endif
case ( key == K_CTRL_HOME ) ; get:exitState := GE_TOP
#ifdef CTRL_END_SPECIAL  // both ^W and ^End go to the last GET
   case (key == K_CTRL_END) ; get:exitState := GE_BOTTOM
#endif
case (key == K_INS)
  if readinsert( !readinsert() )
    setcursor(SC_NORMAL)
  else
    setcursor(SC_INSERT)
  endif
case (key == K_UNDO)       ; get:Undo()
case (key == K_HOME)       ; get:Home()
#ifdef __XPP__
  case (key == K_END)        ; get:_end()
#else
  case (key == K_END)        ; get:End()
#endif
case (key == K_RIGHT)      ; get:Right()
case (key == K_LEFT)       ; get:Left()
case (key == K_CTRL_RIGHT) ; get:WordRight()
case (key == K_CTRL_LEFT)  ; get:WordLeft()
case (key == K_BS)         ; get:BackSpace()
case (key == K_DEL)        ; get:Delete()
case (key == K_CTRL_T)     ; get:DelWordRight()
case (key == K_CTRL_Y)     ; get:DelEnd()
case (key == K_CTRL_BS)    ; get:DelWordLeft()
otherwise
  if key >= 32 .and. key <= 255
    cKey := chr(key)
    if (get:type == T_NUMERIC .and. (cKey == "." .or. cKey == ","))
      get:ToDecPos()
    else
      if get:type == T_DATE
        if empty(get:VarGet())
          * .and. (empty(ptod(MrkInstall)).or.UserDate()<=ptod(MrkInstall))
          get:VarPut(UserDate())
          get:updateBuffer()
        endif
        if cKey == "+"
          get:changed := .t.
          get:VarPut(get:VarGet() + 1)
          get:updateBuffer()
          RETURN
        elseif cKey == "-"
          get:changed := .t.
          get:VarPut(get:VarGet() - 1)
          get:updateBuffer()
          RETURN 
        elseif cKey == " "
          get:changed := .t.
          get:VarPut(ctod(""))
          get:updateBuffer()
          RETURN 
        endif
      endif
      if Set(_SET_INSERT)
        get:Insert(cKey)
      else
        get:Overstrike(cKey)
      endif
      if get:typeOut
        if ! Set(_SET_CONFIRM)
          get:exitState := GE_ENTER
        else
          Alarm()
        endif
      endif
    endif
  else
    OtherKey(get,key)
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

STATIC PROCEDURE OtherKey(get,key)
local i
if key != K_MOUSE_EVENT .and. key != K_ALT
  * for i := 1 to len(saGetList)
  *   if saGetList[i]:cargo[AG_HOTKEY] == key
  *     BouncePos := i
  *     get:exitState := GE_BOUNCE
  *     RETURN
  *   endif
  * next i
  get:exitState := GE_WRITE
endif
RETURN

**
**  CbxApplyKey()
**  Apply a single Inkey() keystroke to a (focussed) CHECKBOX get.
**
PROCEDURE CbxApplyKey(get, key)
local cKey
local bKeyBlock
// check for SET KEY first
if ( (bKeyBlock := SetKey(key)) <> NIL )
  GetDoSetKey(bKeyBlock, get)
  RETURN                                                             // NOTE
endif
do case
case ( key == K_UP )     ; get:exitState := GE_UP
case ( key == K_SH_TAB ) ; get:exitState := GE_UP
case ( key == K_DOWN )   ; get:exitState := GE_DOWN
case ( key == K_TAB )    ; get:exitState := GE_DOWN
#ifdef ENTER_STOPS
  * case ( key == K_ENTER )  ; get:exitState := GE_WRITE // GE_ENTER
#else
  case ( key == K_ENTER )  ; get:exitState := GE_ENTER
#endif
case (key == K_F1) ; GetDoPick(get)
case ( key == K_ESC )
  if set(_SET_ESCAPE)
    get:undo()
    get:exitState := GE_ESCAPE
  endif
* case ( key == K_PGUP )      ; get:exitState := GE_WRITE
* case ( key == K_PGDN )      ; get:exitState := GE_WRITE
case ( key == K_CTRL_HOME ) ; get:exitState := GE_TOP
#ifdef CTRL_END_SPECIAL  // both ^W and ^End go to the last GET
   case (key == K_CTRL_END) ; get:exitState := GE_BOTTOM
* #else                    // both ^W and ^End terminate the READ (the default)
*    case (key == K_CTRL_W) ;   get:exitState := GE_WRITE
#endif
case (key == K_INS)
  get:varPut(BUTTON_ON)
  get:updateBuffer()
case (key == K_DEL)
  get:varPut(BUTTON_OFF)
  get:updateBuffer()
  * Set( _SET_INSERT, !Set(_SET_INSERT) )
  * ShowScoreboard()
case (key == K_CTRL_Y)     ; get:DelEnd()
case (key == K_UNDO)       ; get:Undo()
otherwise
  if key >= 32 .and. key <= 255
    if empty( get:buffer )
      get:varPut(BUTTON_ON)
    else
      get:varPut(BUTTON_OFF)
    endif
    get:updateBuffer()
  else
    OtherKey(get,key)
    * if key != K_MOUSE_EVENT .and. key != K_ALT
    *   get:exitState := GE_WRITE
    * endif
  endif
endcase
RETURN


#ifndef __XPP__
**
** GetPreValidate()
** Test entry condition (WHEN clause) for a GET.
**
FUNCTION GetPreValidate(get)
local saveUpdated
local lWhen := .t.
* RETURN .f. if IsReadOnly()
* Nein : ph_read() wird ja gar nicht aufgerufen, wenn Daten nicht
* bearbeitet werden dÅrfen. Aber selbst in einer read-only Datebank
* kînnen z.B. Dialogfenster bearbeitet werden. Logisch.
if get:preBlock != NIL
  saveUpdated := slUpdated
  lWhen := eval(get:preBlock, get)
  #ifdef DEF_WRITE
    if USRATTR_W $ UsrAttrib()
      lWhen := .t.
    endif
  #endif DEF_WRITE
  * get:Display()       ausgeklammert weil nicht nîtig bei mir...
  * ShowScoreBoard()
  slUpdated := saveUpdated
endif
if slKillRead
  lWhen := .f.
  get:exitState := GE_ESCAPE           // provokes ReadModal() exit
elseif ! lWhen
  get:exitState := GE_WHEN             // indicates failure
else
  get:exitState := GE_NOEXIT           // prepares for editing
endif
RETURN (lWhen)
#endif __XPP__


**
** GetDoPick()
**
STATIC FUNCTION GetDoPick(get)
local uNewVal
RETURN NIL if get:cargo == NIL
if get:cargo[AG_PICKBLK] == NIL .and. get:type != T_DATE
  RETURN NIL
endif
if get:changed
  #ifdef __XPP__
    get:_assign()
  #else
    get:Assign()
  #endif
  slUpdated := .t.
endif
* #ifdef MONKEY
*   SendKey(K_ENTER)
* #endif
if get:type == T_DATE
  uNewVal := PickDate(get:varGet())
else
  uNewVal := eval(get:cargo[AG_PICKBLK],get:buffer,get:row,get:col)
  * uNewVal := eval(get:cargo[AG_PICKBLK],get:varGet(),get:row,get:col)
endif
if uNewVal != NIL
  get:varPut(uNewVal) // unerklÑrter bug bei PickStreet() nach ParCreate
  * eval(get:block,uNewVal) // das geht nicht in DlgExec() (via array)
  get:updateBuffer()
  get:changed := .t.
  * if len(saGetList) == 1
  *   get:exitState := GE_ENTER
  * elseif len(saGetList) == 1
  if len(saGetList) == 1 .or. snCurGetPos < len(saGetList)
    get:exitState := GE_ENTER
    // 19980701 get:exitState := GE_DOWN
  * else
  *   for i := snCurGetPos to len(saGetList)
  *     get:exitState := GE_DOWN
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
  * get:reset() // Versuchsweise raus. NÅtzt nix.
else
  get:display() // sonst ist evtl Cursor nicht mehr da.
endif
RETURN NIL


#ifndef __XPP__
**
** GetPostValidate()
** Test VALID clause for a GET
**
** NOTE: bad dates are rejected in such a way as to preserve edit buffer.
**
FUNCTION GetPostValidate(get)
local saveUpdated
local lValid := .t.
local i
local aTrig
if get:exitState == GE_ESCAPE
  RETURN .t.
endif
if get:BadDate()
  get:Home()
  RETURN .f.
endif
if ! get:changed
  RETURN .T.
endif
//
// if editing occurred, assign the new value to the variable
//
if get:cargo[AG_POSTEDIT] != NIL
  get:buffer := eval(get:cargo[AG_POSTEDIT],get:buffer)
endif
**
**
#ifdef __XPP__
  get:_assign()
#else
  get:Assign()
#endif
slUpdated := .t.
* if get:type == T_DATE .and. ! empty(get:varGet())
*   if year(get:varGet()) < set(_SET_EPOCH) // Shift2000()
*     get:varPut(SkipJahr(get:varGet(),100))
*   endif
* endif
get:Reset()    // reform edit buffer, set cursor to home position, redisplay
if get:postBlock <> NIL   // check VALID clause if specified
  saveUpdated := slUpdated
  * setpos( get:row, get:col + len(get:buffer) )   // Summer '87 compatibility
  lValid := eval(get:postBlock, get)
  * setpos( get:row, get:col )                     // reset compat. pos
  * ShowScoreBoard()
  get:updateBuffer()
  slUpdated := saveUpdated
  if slKillRead
    get:exitState := GE_ESCAPE                  // provokes ReadModal() exit
    lValid := .t.
  endif
endif
#ifdef DEF_BRAND
  if get:Type == T_DATE
    if ! empty(ptod(MrkInstall))
      if get:VarGet() > ptod(MrkInstall)
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
PROCEDURE GetDoSetKey(keyBlock, get)
local saveUpdated
// if editing has occurred, assign variable
if ( get:changed )
  #ifdef __XPP__
    get:_assign()
  #else
    get:Assign()
  #endif
  slUpdated := .t.
endif
saveUpdated := slUpdated
eval(keyBlock, ReadProcName, ReadProcLine, ReadVar())
* ShowScoreboard()
get:UpdateBuffer()
slUpdated := saveUpdated
if slKillRead
  get:exitState := GE_ESCAPE              // provokes ReadModal() exit
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
// get mouse position
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

FUNCTION GetSetFocus ( get )
get:setFocus()
RETURN NIL

#else
//
// GetSetFocus ( get )
//
// Simple function which will set the current focus
// AND cursor position within the field (for better mouse support)
//
FUNCTION GetSetFocus ( get )
get:SetFocus()
if FldPos != -1
  if len( transform( get:varGet, get:picture ))  >  FldPos
    get:pos := FldPos
    #ifdef DEF_MOUSE
      MOUSE_OFF ( )
    #endif
    * FldDisplay(get)
    get:Display()
    #ifdef DEF_MOUSE
      MOUSE_ON ( )
    #endif
  endif
endif
FldPos := -1
scLastGet := get:name
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
* PROCEDURE YNReader( get )
* local old_cursor := setcursor ( SC_NONE )
* local key, bKeyBlock
* // Set the button flag
* InButton := TRUE
* // read the GET if the WHEN condition is satisfied
* if ( GetPreValidate ( get ) )
*    GetSetFocus ( get )
*    do while ( get:exitState == GE_NOEXIT )
*      // check for initial typeout (no editable positions)
*      if ( get:typeOut )
*        get:exitState := GE_ENTER
*      endif
*      do while ( get:exitState == GE_NOEXIT )
*        key := RdKey ()
*        // check for SET KEY first
*        if ( (bKeyBlock := SetKey(key)) <> NIL )
*          GetDoSetKey(bKeyBlock, get)
*        else
*          do case
*          case ( key == K_UP )     ; get:exitState := GE_UP
*          case ( key == K_SH_TAB ) ; get:exitState := GE_UP
*          case ( key == K_DOWN )   ; get:exitState := GE_DOWN
*          case ( key == K_TAB )    ; get:exitState := GE_DOWN
*          case ( key == K_ENTER )  ; get:exitState := GE_WRITE // GE_ENTER
*          case ( key == K_ESC )
*            if ( Set(_SET_ESCAPE) )
*              get:undo()
*              get:exitState := GE_ESCAPE
*            endif
*          case ( key == K_PGUP )      ; get:exitState := GE_WRITE
*          case ( key == K_PGDN )      ; get:exitState := GE_WRITE
*          case ( key == K_CTRL_HOME ) ; get:exitState := GE_TOP
* #ifdef CTRL_END_SPECIAL
*             // both ^W and ^End go to the last GET
*             case (key == K_CTRL_END) ; get:exitState := GE_BOTTOM
* #else
*             // both ^W and ^End terminate the READ (the default)
*             case (key == K_CTRL_W) ; get:exitState := GE_WRITE
* #endif
*          case (key == K_INS)
*             Set( _SET_INSERT, !Set(_SET_INSERT) )
*             ShowScoreboard()
*          case (key == K_UNDO)       ; get:Undo()
*          case (key == K_HOME)       ; get:Home()
*          case (key == K_END)        ; get:End()
*          case (key == K_RIGHT)      ; get:Right()
*          case (key == K_LEFT)       ; get:Left()
*          case (key == K_CTRL_RIGHT) ; get:WordRight()
*          case (key == K_CTRL_LEFT)  ; get:WordLeft()
*          case (key == K_BS)         ; get:BackSpace()
*          case (key == K_DEL)        ; get:Delete()
*          case (key == K_CTRL_T)     ; get:DelWordRight()
*          case (key == K_CTRL_Y)     ; get:DelEnd()
*          case (key == K_CTRL_BS)    ; get:DelWordLeft()
*          case ( key == K_SPACE )
*            get:varPut ( !get:varGet ( ) )
*            get:updateBuffer ( )
*          case ( key == K_UPPER_Y ) .or. ( key == K_LOWER_Y ) .or. ;
*               ( key == K_UPPER_T ) .or. ( key == K_LOWER_T ) .or. ;
*               ( key == K_PLUS ) .or.    ( key == K_EQUAL )
*             get:varPut ( TRUE )
*             get:updateBuffer ( )
*          case ( key == K_UPPER_N ) .or. ( key == K_LOWER_N ) .or. ;
*               ( key == K_UPPER_F ) .or. ( key == K_LOWER_F ) .or. ;
*               ( key == K_MINUS ) .or.   ( key == K_BAR )
*             get:varPut ( FALSE )
*             get:updateBuffer ( )
*          endcase
*        endif
*      enddo
*      // disallow exit if the VALID condition is not satisfied
*      if ( !GetPostValidate(get) )
*        get:exitState := GE_NOEXIT
*      endif
*    enddo
*    // de-activate the GET
*    get:KillFocus()
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
static PROCEDURE PostActiveGet(get)
GetActive( get )
ReadVar( GetReadVar(get) )
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
static FUNCTION GetReadVar(get)
local cName := upper(get:name)
//#ifdef SUBSCRIPT_IN_READVAR
local i
/***
*       The following code includes subscripts in the name returned by
*       this function, if the get variable is an array element.
*
*       Subscripts are retrieved from the get:subscript instance variable.
*
*       NOTE: incompatible with Summer 87
*/
if ( get:subscript <> NIL )
  for i := 1 to len(get:subscript)
    cName += "[" + ltrim(str(get:subscript[i])) + "]"
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
FUNCTION RangeCheck(get, junk, lo, hi)
local cMsg, nRow, nCol
local xValue
if ( !get:changed )
  return (.t.)
endif
xValue := get:VarGet()
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
