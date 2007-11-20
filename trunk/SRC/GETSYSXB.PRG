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

** Based on GETSYS.PRG included with Alaska Xbase++ compiler

#include "lib.ch"
* #include "inkey.ch"
#include "natmsg.ch"

#ifdef LG_FRENCH
  #define MSG001 "Votre code d'installation est limitÇ jusqu'au "
  *static MSG_F1 := "[F1] dans un champ marquÇ  = liste de sÇlection"
#endif
#ifdef LG_GERMAN
  #define MSG001 "Ihr Installations-Code ist zeitlich begrenzt bis zum "
  *static MSG_F1 := "[F1] in einem mit  markierten Feld = Auswahlliste"
#endif
#ifdef LG_EN
  #define MSG001 "Your installation code is limited until "
  *static MSG_F1 := "Hint: press [F1] in fields marked with "
#endif

// Undo key for Inkey()
#define  K_UNDO           K_CTRL_U
#define CTRL_END_SPECIAL
     

static saMsk := NIL  // 19980422
static scLastGet :=  ""
* static scFldBuffer :=  ""

STATIC soStatus                       // Object for status variables

*****************************************************************************
* Input routine for Get data entry screens
*****************************************************************************
FUNCTION ReadModal( getList, nPos, aReadKeys, msk )
   local nSaveCursor := setcursor()
   local uOldValue
   local aMskSave := saMsk
   LOCAL oGet, i
   * local bF1Key
   * local bCtrlIns
   * local bAltIns
   local nLastPos

   IF Empty( GetList )
      // Compatibility/ No Get object available
      SetPos( MAXROW() - 1, 0 )        
      RETURN 0
   ENDIF

   * default aReadKeys to {}
   saMsk := msk

   soStatus := ReadStatus()

   // Save status variables, assign current Getlist array
   soStatus:save()
   soStatus:getList  := getList
   soStatus:procName := ProcName(1)
   soStatus:procLine := ProcLine(1)

   *bF1Key := SetKey(K_F1,{|n,l,v,g|GetDoPick(g)})
   *bCtrlIns := SetKey(K_CTRL_INS, {|n,l,v,g|clipboard(trim(g:buffer))})
   *bAltIns := SetKey(K_ALT_INS,{|n,l,v,g|GetPasteBuffer()})

   ** F1-Indikatoren anzeigen :
   if len(getList) > 1
     for i := 1 to len(getList)
       * if getList[i]:cargo == NIL ; raise(getList[i]:name+" get:cargo is NIL") ; endif
       if getList[i]:cargo[AG_PICKBLK] != NIL
         if getList[i]:preBlock == NIL .or. eval(getList[i]:preBlock)
           * @ getList[i]:row, getList[i]:col - 1 say ""
           * @ getList[i]:row, getList[i]:col - 1 say ""
           * 20070831 @ getList[i]:row, getList[i]:col - 1 say chr(18)
           @ getList[i]:row, getList[i]:col - 1 say SetPickIndicator()
           * if empty(SetMsg())
           *   * SetMsg(utrp(;
           *   *   "Hint: press [F1] in fields marked with ",;
           *   *   "[F1] dans un champ marquÇ  = liste de sÇlection",;
           *   *   "[F1] in einem mit  markierten Feld = Auswahlliste",;
           *   * ))
           *   // SetMsg(MSG_F1) //  "[F1] in einem mit  markierten Feld = Auswahlliste")
           * endif
         endif
       endif
     next i
   endif

   // Get first Get object
   soStatus:settle( nPos )

   setcursor( if(readinsert(), SC_INSERT, SC_NORMAL) )   // (Luc)

   DO WHILE soStatus:thisPos <> 0

      // Post active Get
      soStatus:postActiveGet()
      oGet := soStatus:activeGet
      uOldValue := oGet:varGet()

      // Input via user defined Get reader
      IF Valtype( oGet:reader ) == "B" 
         Eval( oGet:reader, oGet )     
      ELSEIF soStatus:useAppEvent
          // Input via AppEvent()
         GetEventReader( oGet )
      ELSE
         // Input via Inkey()
         GetReader( oGet )
      ENDIF

      if oGet:cargo[AG_AFTER] != NIL
        eval(oGet:cargo[AG_AFTER],uOldValue)
      endif

      // Get next Get object
      soStatus:settle()
   ENDDO

   ** F1-Indikatoren wieder lîschen:
   if len(getList) > 1
     for i := 1 to len(getList)
       if getList[i]:cargo[AG_PICKBLK] != NIL
         if getList[i]:preBlock == NIL .or. eval(getList[i]:preBlock)
           @ getList[i]:row, getList[i]:col - 1 say " "
         endif
       endif
     next i
   endif

   nLastPos := soStatus:lastPos
   // Restore status variables
   soStatus:Restore()
   saMsk := aMskSave

   // Compatibility
   SetPos( MAXROW() - 1, 0 )
   setcursor( nSaveCursor )

   *SetKey(K_F1,bF1Key)
   *SetKey(K_CTRL_INS,bCtrlIns)
   *SetKey(K_ALT_INS,bAltIns)

   * RETURN soStatus:updated
   RETURN nLastPos

******************************************************************************
* Process input
******************************************************************************
PROCEDURE GetReader( oGet )

   // Perform pre validation
   IF GetPreValidate( oGet )
      if empty(oGet:picture) .and. oGet:type != "D"
        oGet:picture := "@K"
      endif
      // Set input focus to Get object
      oGet:setFocus()

      DO WHILE oGet:exitState == GE_NOEXIT

         IF oGet:typeOut
            // No editable characters available to the right of the cursor
            oGet:exitState := GE_ENTER
         ENDIF

         // Get keyboard input
         DO WHILE oGet:exitState == GE_NOEXIT
            * GetApplyKey( oGet, Inkey(0) )
            GetApplyKey( oGet, WaitKey() )
         ENDDO

         IF ! GetPostValidate( oGet )
            // Post validation failed
            oGet:exitState:= GE_NOEXIT
         ENDIF
      ENDDO

      // Reset input focus
      oGet:killFocus()

   ENDIF

RETURN

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


*****************************************************************************
* Process keyboard input
* Note: the passed Get object must have input focus
*****************************************************************************
*PROCEDURE GetApplyKey( oGet, nKey )
*   LOCAL cChar, bKeyBlock := SetKey( nKey )
*   LOCAL nLen
*
*   DO CASE
*   // Code block is associated with a key
*   CASE bKeyBlock <> NIL
*        GetDoSetKey( bKeyBlock, oGet )
*   // Keys relevant for :exitState
*   CASE nKey == K_UP   .OR. nKey == K_SH_TAB
*        oGet:exitState := GE_UP
*
*   CASE nKey == K_DOWN .OR. nKey == K_TAB
*        oGet:exitState := GE_DOWN
*
*   CASE nKey == K_PGUP .OR. nKey == K_PGDN
*        oGet:exitState := GE_WRITE
*
*   CASE nKey == K_ENTER
*        oGet:exitState := GE_ENTER
*
*   CASE nKey == K_CTRL_HOME
*        oGet:exitState := GE_TOP
*
*   CASE nKey == K_ESC
*        IF Set(_SET_ESCAPE)
*           oGet:undo()
*           oGet:exitState := GE_ESCAPE
*        ENDIF
*
*#ifdef CTRL_END_IS_GO_BOTTOM
*
*   // Ctrl-End and Ctrl-W activate the last Get
*   CASE nKey == K_CTRL_END
*        oGet:exitState := GE_BOTTOM
*#else
*
*   // Ctrl-End and Ctrl-W terminate READ (default)
*   CASE nKey == K_CTRL_W
*        oGet:exitState := GE_WRITE
*
*#endif
*
*   // Keys for cursor movement
*   CASE nKey == K_RIGHT
*        oGet:right()
*
*   CASE nKey == K_CTRL_RIGHT
*        oGet:wordRight()
*
*   CASE nKey == K_LEFT
*        oGet:left()
*
*   CASE nKey == K_CTRL_LEFT
*        oGet:wordLeft()
*
*   CASE nKey == K_HOME
*        oGet:home()
*
*   CASE nKey == K_END
*        oGet:_end()
*
*   // Keys for editing
*   CASE nKey == K_INS
*        Set( _SET_INSERT, !Set(_SET_INSERT) )
*        DispScoreboard()
*
*   CASE nKey == K_BS
*        oGet:backSpace()
*
*   CASE nKey == K_DEL
*        oGet:delete()
*
*   CASE nKey == K_CTRL_T
*        oGet:delWordRight()
*
*   CASE nKey == K_CTRL_Y
*        oGet:delEnd()
*
*   CASE nKey == K_CTRL_BS
*        oGet:delWordLeft()
*
*   CASE nKey == K_UNDO
*        oGet:undo()
*
*   OTHERWISE
*
*      IF (nKey >= 32 .AND. nKey <= 255) .OR. (nKey == K_CTRL_U)
*         // Retrieve character
*         cChar := Chr(nKey)
*
*         IF oGet:type == "N" .AND. cChar $ ".,"
*            oGet:condClear()
*            oGet:toDecPos()
*         ELSE
*            // Transfer character to edit buffer
*            IF Set(_SET_INSERT)
*               nLen := Len( oGet:buffer )
*               oGet:insert( cChar )
*
*               IF Len(oGet:buffer) > nLen
*                  oGet:buffer := Left( oGet:buffer,nLen )
*               ENDIF
*            ELSE
*               oGet:overstrike( cChar )
*            ENDIF
*
*            // No space remaining to the right of the cursor to type
*            IF oGet:typeOut
*               IF Set(_SET_BELL)
*                  QQOut( Chr(7) )
*               ENDIF
*
*               IF ! Set(_SET_CONFIRM)
*                  oGet:exitState := GE_ENTER
*               ENDIF
*            ENDIF
*         ENDIF
*
*      ENDIF
*
*   ENDCASE
*
*RETURN

*****************************************************************************
* Perform pre validation (WHEN Option)
*****************************************************************************
FUNCTION GetPreValidate( oGet )
   LOCAL lUpdated, lWhen := .T.

   // Object with status variables
   soStatus := ReadStatus()

   IF Valtype( oGet:preBlock ) == "B"
      lUpdated := soStatus:updated
      lWhen    := Eval( oGet:preBlock, oGet )

      oGet:display()

      DispScoreboard()
      soStatus:updated := lUpdated
   ENDIF

   // Terminate READ
   IF soStatus:killRead
      lWhen          := .F.
      oGet:exitState := GE_ESCAPE
   ELSEIF ! lWhen
      // WHEN condition failed
      oGet:exitState := GE_WHEN
   ELSE
      // Ok, Input may be performed
      oGet:exitState := GE_NOEXIT
   ENDIF

RETURN lWhen

*****************************************************************************
* Perform post validation (VALID or RANGE option)
*****************************************************************************
FUNCTION GetPostValidate( oGet )
   LOCAL lUpdated, lValid

   RETURN .t. if oGet:exitState == GE_ESCAPE
   RETURN .t. if ! oGet:hasFocus
   if oGet:BadDate()
     oGet:Home()
     RETURN ! SetMsg(NAT_MSG_INVALID_DATE)
   endif
   RETURN .T. if ! oGet:changed

   lValid   := .T.
   soStatus := ReadStatus()

   // Edit buffer was changed, Assign value to variable
   if oGet:cargo[AG_POSTEDIT] != NIL
     oGet:buffer := eval(oGet:cargo[AG_POSTEDIT],oGet:buffer)
   endif
   oGet:_assign()
   soStatus:updated := .T.

   // Reset Get object
   oGet:Reset()                        

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

   // Is a code block available?
   IF Valtype(oGet:postBlock) == "B"   

      lUpdated := soStatus:updated
      // Summer 87 compatibility
      SetPos( oGet:row, oGet:col + Len( oGet:buffer ) )
      lValid := Eval( oGet:postBlock, oGet )
      // Summer 87 compatibility
      SetPos( oGet:row, oGet:col )     

      DispScoreboard()
      oGet:updateBuffer()
      soStatus:updated := lUpdated

      IF soStatus:killRead
         // Terminate READ
         oGet:exitState := GE_ESCAPE   
         lValid := .T.
      ENDIF
   ENDIF

RETURN lValid

*****************************************************************************
* Code block is associated with a key - execute it
*****************************************************************************
FUNCTION GetDoSetKey( bKeyBlock, oGet )
   LOCAL lUpdated, xRet, nPos

   soStatus := ReadStatus()

   IF oGet:changed
      nPos := oGet:pos
      // Assign value before execution
      // of code block
      oGet:_assign()
      lUpdated := soStatus:updated
      // undo the _assign() when postvalidation fails
      IF ! GetPostValidate( oGet )
         oGet:undo()
         oGet:_assign()
         IF Set(_SET_BELL)
            // Indicate that something went wrong
            QQOut( Chr(7) )
         ENDIF
      ELSE
         lUpdated := .T.
      ENDIF
      oGet:pos := nPos
      soStatus:updated := lUpdated
   ENDIF

   lUpdated := soStatus:updated

   xRet := Eval( bKeyBlock, soStatus:procName, ;
                            soStatus:procLine, ;
                            soStatus:readVar , ;
                            oGet               )

   DispScoreboard()
   oGet:updateBuffer()

   soStatus:updated := lUpdated

   IF soStatus:killRead
      // Terminate READ
      oGet:exitState := GE_ESCAPE
   ENDIF

RETURN xRet

*****************************************************************************
* set/get active Get object
*****************************************************************************
FUNCTION GetActive( oGet )
   LOCAL oPrevious := ReadStatus():activeGet

   IF PCount() > 0
      IF oGet == NIL
         ReadStatus():activeGet := NIL
      ELSEIF oGet:hasFocus
         ReadStatus():activeGet := oGet
      ELSEIF oPrevious <> NIL
         // Active Get looses focus, new Get receives focus
         oPrevious:exitState := GE_LASTGET
         ReadStatus():lastActiveGet := oGet
      ENDIF
   ENDIF
RETURN oPrevious

******************************************************************************
** Get Updated status
******************************************************************************
FUNCTION Updated()
RETURN ReadStatus():updated

******************************************************************************
** set/get ReadExit status
******************************************************************************
FUNCTION ReadExit( lOnOff )
RETURN IIf( lOnOff == NIL, ;
            Set( _SET_EXIT ), ;
            Set( _SET_EXIT, lOnOff ) )

******************************************************************************
** set/get ReadInsert status
******************************************************************************
FUNCTION ReadInsert( lOnOff )
RETURN IIf( lOnOff == NIL, ;
            Set( _SET_INSERT ), ;
            Set( _SET_INSERT, lOnOff ) )

******************************************************************************
** set/get KillRead status (-> see #command CLEAR GETS)
******************************************************************************
FUNCTION ReadKill( lKillRead )
   LOCAL lCurrent := ReadStatus():killRead

   IF Valtype( lKillRead ) == "L"
      ReadStatus():killRead := lKillRead
   ENDIF
RETURN lCurrent

*****************************************************************************
* set/get Updated status
*****************************************************************************
FUNCTION ReadUpdated( lUpdated )
   LOCAL lCurrent := ReadStatus():updated

   IF Valtype( lUpdated ) == "L"
      ReadStatus():updated := lUpdated
   ENDIF
RETURN lCurrent

*****************************************************************************
* set/get name of current GET or MENU TO variable
*****************************************************************************
FUNCTION ReadVar( cReadVar )
   LOCAL cCurrent := ReadStatus():readVar

   IF Valtype( cReadVar ) == "C"
      ReadStatus():readVar := cReadVar
   ENDIF
RETURN cCurrent
/////////////////////////////////////////////////////////////////////////////
//
//  If you need ScoreBoard, here it is !
//
/////////////////////////////////////////////////////////////////////////////

// #defines for SCOREBOARD
// #defines fÅr SCOREBOARD
#define SCORE_ROW      0
// here a incompatibility, instead of 60
#define SCORE_COL      50
#define SCORE_BLOCK    ;
         {|nRow,nCol,xMsg| ;
            SetPos( SCORE_ROW, SCORE_COL ), ;
            DispOut( IIf( Valtype(xMsg)=="N", ;
                          NationMsg(xMsg), xMsg ) ;
                   ), ;
            SetPos(nRow,nCol) ;
         }

*****************************************************************************
* Display scoreboard
*****************************************************************************
PROCEDURE DispScoreboard()
   IF Set( _SET_SCOREBOARD )
      Eval( SCORE_BLOCK, Row(), Col(), ;
            IIf( Set(_SET_INSERT), NAT_MSG_INSERT_ON, NAT_MSG_INSERT_OFF) ;
          )
   ENDIF
RETURN

******************************************************************************
** Display invalid date
******************************************************************************
STATIC PROCEDURE InvalidDate()
   SetMsg(NAT_MSG_INVALID_DATE)
   *IF Set( _SET_SCOREBOARD )
   *   Eval( SCORE_BLOCK, Row(), Col(), NAT_MSG_INVALID_DATE )
   *
   *   INKEY( 0 )
   *
   *   Eval( SCORE_BLOCK, Row(), Col(), ;
   *         Space( Len( NationMsg(NAT_MSG_INVALID_DATE) ) ) )
   *ENDIF
RETURN

*****************************************************************************
* Check if value lies within a valid range
*****************************************************************************
FUNCTION RangeCheck( oGet, xLow, xHigh )
   LOCAL lReturn := .T., xValue, cMsg

   IF oGet:changed
      xValue := oGet:varGet()

      IF xValue < xLow .OR. xValue > xHigh
         lReturn := .F.

         IF Set( _SET_SCOREBOARD )

            cMsg := NationMsg(NAT_MSG_RANGE_LOW)  + ;
                    LTrim( Transform(xLow, "") )  + ;
                    NationMsg(NAT_MSG_RANGE_HIGH) + ;
                    LTrim( Transform(xHigh, "") )

            Eval( SCORE_BLOCK, Row(), Col(), cMsg )

            INKEY( 0 )

            Eval( SCORE_BLOCK, Row(), Col(), Space( Len(cMsg) ) )

         ENDIF

      ENDIF

   ENDIF
RETURN lReturn

PROCEDURE CbxReader( get )
* local uOldValue
if ! GetPreValidate(get)
  RETURN    // read it only if the WHEN clause is satisfied
endif
get:setFocus()
* GetSetFocus ( @get )    // activate the GET for reading
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
* get:setFocus()
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


FUNCTION GetDoPick(get)
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
  soStatus:updated := .t.
endif
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
  * if len(soStatus:getList) == 1
  *   get:exitState := GE_ENTER
  * elseif len(soStatus:getList) == 1
  if len(soStatus:getList) == 1 .or. soStatus:thisPos < len(soStatus:getList)
    get:exitState := GE_ENTER
    // 19980701 get:exitState := GE_DOWN
  * else
  *   for i := snCurGetPos to len(soStatus:getList)
  *     get:exitState := GE_DOWN
  *   next i
    nKey := K_ENTER
  endif
else
  get:display() // sonst ist evtl Cursor nicht mehr da.
endif
RETURN NIL


FUNCTION ph_Refresh()
local i
local nRow := row()
local nCol := col()
if soStatus != NIL
  for i := 1 to len(soStatus:getList)
    soStatus:getList[i]:updateBuffer()
    FldDisplay(soStatus:getList[i])
    * soStatus:getList[i]:display()
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
local g := soStatus:getList[i]
FldDisplay(g)
setpos(nRow,nCol)
RETURN .t.

FUNCTION LastGet(cNew)
if cNew != NIL
  scLastGet := cNew
endif
RETURN scLastGet

STATIC PROCEDURE OtherKey(get,key)
if key != K_MOUSE_EVENT .and. key != K_ALT
  get:exitState := GE_WRITE
endif
RETURN




// EOF
