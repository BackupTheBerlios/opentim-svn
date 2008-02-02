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

** Based on GETSYSX.PRG included with Alaska Xbase++ compiler

#include "APPEVENT.CH"

#define _FORCE_KILL_GET                // Active Get will always be exited
                                       // by a mouse click ->
                                       // :undo() if GetPostValidate()
                                       // fails

******************************************************************************
* Get reader for AppEvent()
******************************************************************************
PROCEDURE GetEventReader( oGet )
   LOCAL nEvent
   LOCAL mp1 := NIL, mp2 :=NIL, obj := NIL

   /*
    * Perform pre validation
    */
   IF GetPreValidate( oGet )     
      /* Set input focus to Get object */
      oGet:setFocus()                  

      IF LastAppEvent( @mp1, @mp2 ) == xbeM_LbClick
         oGet:pos := Max( 1, oGet:posInBuffer( mp1[1], mp1[2] ) )
         oGet:display()
      ENDIF
      #ifdef XPPMOUSE
      FlushKeystack()
      #endif XPPMOUSE

      DO WHILE oGet:exitState == GE_NOEXIT

         /*
          * No editable characters to the right of the cursor
          */
         IF oGet:typeOut
            oGet:exitState := GE_ENTER
         ENDIF
         /* Read event queue */
         DO WHILE oGet:exitState == GE_NOEXIT
            nEvent := AppEvent( @mp1, @mp2, @obj , 0 )
            GetHandleEvent( oGet, nEvent, mp1, mp2, obj )
         ENDDO

         IF ! GetPostValidate( oGet )
            /* Post validation failed */
            oGet:exitState:= GE_NOEXIT 
         ENDIF
      ENDDO

      /* Reset input focus */
      oGet:killFocus()

   ENDIF

RETURN

*****************************************************************************
* Process events
*****************************************************************************
PROCEDURE GetHandleEvent( oGet, nEvent, mp1, mp2, obj )
   LOCAL cChar, bEventBlock, bInkeyBlock, xRet

   /* Call SetAppEvent Codeblock and use its return value. */
   IF ( bEventBlock := SetAppEvent( nEvent ) ) <> NIL
      xRet := GetDoSetEvent( bEventBlock, mp1, mp2, obj, oGet )
      IF VALTYPE ( xRet ) == "N"
         nEvent := xRet
         IF nEvent == xbeP_Keyboard
            nEvent := mp1
         ENDIF
      ELSE
         RETURN
      ENDIF
   ENDIF

   /* Compatibility: call SetKey() codeblock */
   IF nEvent < xbeB_Event .AND. ( bInkeyBlock := SetKey( LastKey() ) ) <> NIL
      GetDoSetKey( bInkeyBlock, oGet )
   ENDIF

   /*
    * Note: READ will be terminated if the event xbeP_Close occurs.
    * (this usually closes the current window). The event can be
    * retrieved again calling LastAppEvent() and appropriate action
    * can be taken.
    */

   DO CASE
   CASE nEvent == xbeP_Close
      oGet:undo()
      oGet:exitState := GE_ESCAPE

   CASE nEvent == xbe_None .OR. nEvent == xbeM_Motion

   CASE nEvent == xbeM_LbClick  .AND. ;
        obj    == SetAppWindow()
      ReadStatus():LbClick( mp1[1], mp1[2] )

   CASE nEvent > xbeB_Event     .AND. ;
        ! obj == NIL

      IF Set( _SET_HANDLEEVENT )
         obj:handleEvent( nEvent, mp1, mp2 ) 
      ENDIF

      /*
       * If CLEAR GETs is called within :handleEvent(),
       * READ must be terminated.
       */
      IF ReadStatus():killRead      
         oGet:exitState := GE_ESCAPE
      ELSE
         IF !oGet:hasFocus
            oGet:setFocus()
         ENDIF
      ENDIF

   CASE nEvent == xbeK_UP .OR. nEvent == xbeK_SH_TAB
        oGet:exitState := GE_UP

   CASE nEvent == xbeK_DOWN .OR. nEvent == xbeK_TAB
        oGet:exitState := GE_DOWN

   CASE nEvent == xbeK_PGUP .OR. nEvent == xbeK_PGDN
        oGet:exitState := GE_WRITE

   CASE nEvent == xbeK_ENTER
        oGet:exitState := GE_ENTER

   CASE nEvent == xbeK_RETURN
        oGet:exitState := GE_ENTER

   CASE nEvent == xbeK_CTRL_HOME
        oGet:exitState := GE_TOP

   CASE nEvent == xbeK_ESC
        IF Set(_SET_ESCAPE)
           oGet:undo()
           oGet:exitState := GE_ESCAPE
        ENDIF

   /* Go to last Get */
   CASE nEvent == xbeK_CTRL_END 
        oGet:exitState := GE_BOTTOM

   /* Terminate READ */
   CASE nEvent == xbeK_CTRL_W 
        oGet:exitState := GE_WRITE

   /* Cursor movement keys */
   CASE nEvent == xbeK_RIGHT
        oGet:right()

   CASE nEvent == xbeK_CTRL_RIGHT
        oGet:wordRight()

   CASE nEvent == xbeK_LEFT
        oGet:left()

   CASE nEvent == xbeK_CTRL_LEFT
        oGet:wordLeft()

   CASE nEvent == xbeK_HOME
        oGet:home()

   CASE nEvent == xbeK_END
        oGet:_end()

   /* Keys for editing */
   CASE nEvent == xbeK_INS
        Set( _SET_INSERT, !Set(_SET_INSERT) )
        DispScoreboard()

   CASE nEvent == xbeK_BS
        oGet:backSpace()

   CASE nEvent == xbeK_DEL
        oGet:delete()

   CASE nEvent == xbeK_CTRL_T
        oGet:delWordRight()

   CASE nEvent == xbeK_CTRL_Y
        oGet:delEnd()

   CASE nEvent == xbeK_CTRL_BS
        oGet:delWordLeft()

   CASE nEvent == xbeK_CTRL_U
        oGet:undo()

   ** added Luc Saffre :

   case nEvent == xbeK_F10 ; oGet:exitState := GE_WRITE
   case nEvent == xbeK_ALT_F4 ; oGet:exitState := GE_WRITE
   case nEvent == xbeK_CTRL_ENTER ; oGet:exitState := GE_WRITE
   case nEvent == xbeK_F1 ;  GetDoPick(oGet)
   case nEvent == xbeK_CTRL_INS   ; clipboard(trim(oGet:buffer))
   case nEvent == xbeK_ALT_INS  ; GetPaste(oGet,clipboard())
   case nEvent == xbeK_SH_INS  ; GetPaste(oGet,clipboard())

   OTHERWISE

      IF (nEvent >= 32 .AND. nEvent <= 255)
         /* Retrieve character */
         cChar := Chr(nEvent)

         IF oGet:type == "N" .AND. cChar $ ".,"
            oGet:condClear()
            oGet:toDecPos()
         ELSE
            /* Transfer character to edit buffer */
            IF Set(_SET_INSERT)
               oGet:insert( cChar )
            ELSE
               oGet:overstrike( cChar )
            ENDIF

            /* No room left to type to the right of the cursor */
            IF oGet:typeOut 
               IF Set(_SET_BELL)
                  QQOut( Chr(7) )
               ENDIF

               IF ! Set(_SET_CONFIRM)
                  oGet:exitState := GE_ENTER
               ENDIF
            ENDIF
         ENDIF

      ENDIF

   ENDCASE

RETURN

*****************************************************************************
* Code block is associated with an event - execute it
*****************************************************************************
FUNCTION GetDoSetEvent( bEventBlock, mp1, mp2, obj, oGet )
   LOCAL oStatus, lUpdated, xRet, nPos

   oStatus := ReadStatus()

   IF oGet:changed  
      /* Assign value before execution of code block */
      nPos := oGet:pos
      oGet:_assign()
      lUpdated := oStatus:updated

      IF ! GetPostValidate( oGet )
         /* undo the _assign() when postvalidation fails */
         oGet:undo()
         oGet:_assign()
         IF Set(_SET_BELL)
            /* Indicate that something went wrong */
            QQOut( Chr(7) )
         ENDIF
      ELSE
         lUpdated := .T.
      ENDIF
      oGet:pos := nPos
      oStatus:updated := lUpdated
   ENDIF

   lUpdated := oStatus:updated

   xRet := Eval( bEventBlock, mp1, mp2, obj, oGet )

   DispScoreboard()
   oGet:updateBuffer()

   oStatus:updated := lUpdated

   IF oStatus:killRead
      /* Terminate READ */
      oGet:exitState := GE_ESCAPE
   ENDIF

RETURN xRet

*****************************************************************************
* Retrieve the last Get object that had focus
*****************************************************************************
FUNCTION GetLastActive()
RETURN ReadStatus():lastActiveGet

*****************************************************************************
* Remove input focus from active Get object
*****************************************************************************
FUNCTION GetKillActive()
   LOCAL oGet, lKilled := .T., lUpdated

   oGet     := ReadStatus():activeGet

   IF oGet <> NIL
      lUpdated := ReadStatus():updated
      IF oGet:changed
         oGet:_assign()
         lUpdated := .T.
      ENDIF

      #ifdef _FORCE_KILL_GET
      /* Allways remove input focus */

        IF ! GetPostValidate( oGet ) 
            /*
             * Postvalidation failed: Get original value
             * and assign it
             */
            oGet:undo() 
            oGet:_assign() 
            oGet:exitState := GE_WHEN
            lUpdated       := ReadStatus():updated
         ENDIF

         ReadStatus():updated := lUpdated
         oGet:killFocus()

      #else


        IF  oGet:postBlock <> NIL .AND. ! GetPostValidate( oGet )
           /*
            * Get has invalid data so prevent exiting
            */
           lKilled        := .F. 
           oGet:exitState := GE_NOEXIT
           Tone(1000,1)

        ENDIF

      #endif
   ENDIF

RETURN lKilled

*****************************************************************************
* Retrieve current GetList array
*****************************************************************************
FUNCTION GetList()
RETURN ReadStatus():getList

*****************************************************************************
* Retrieve position of active Get in current GetList array
*****************************************************************************
FUNCTION GetListPos()
RETURN ReadStatus():thisPos

*****************************************************************************
* Compatibility: Toggle between Inkey() and AppEvent()
*****************************************************************************
FUNCTION GetEnableEvents( lOnOff )
LOCAL lCurrent := ReadStatus():useAppEvent

   IF Valtype( lOnOff ) == "L"
      ReadStatus():useAppEvent := lOnOff
   ENDIF
RETURN lCurrent

*****************************************************************************
* Left mouse click
* Move cursor to mouse pointer
*****************************************************************************
PROCEDURE GetToMousePos( oGet, nMouseCol )
   LOCAL nOffSet := Max(0,oGet:pos - oGet:width)

   IF oGet:hasFocus
      oGet:pos := nOffSet + nMouseCol - oGet:col + 1
      oGet:display()
   ENDIF
RETURN


*****************************************************************************
* Class to monitor READ status variables
*    The class object contains the current state variables.
*    Instances of the class contain saved state variables in case of
*    nested READs
*****************************************************************************
CLASS ReadStatus
   EXPORTED:
   CLASS VAR updated , killRead , lastStatus
   CLASS VAR hitTop  , hitBottom, lastExitState
   CLASS VAR lastPos , thisPos  , nextPos
   CLASS VAR getList , activeGet, lastActiveGet
   CLASS VAR procName, procLine , readVar
   CLASS VAR useAppEvent

   VAR lKillRead, lHitTop   , lHitBottom
   VAR aGetList , oActiveGet, oLastActiveGet
   VAR nLastExitState, nThisPos, nLastPos
   VAR cProcName, nProcLine , cReadVar

   CLASS METHOD initClass
   CLASS METHOD settle, save, restore, postActiveGet, LbClick
ENDCLASS

*****************************************************************************
* Initialize class object
*****************************************************************************
CLASS METHOD ReadStatus:initClass()
   ::updated       := ;
   ::killRead      := ;
   ::hitTop        := ;
   ::hitBottom     := .F.
   ::useAppEvent   := SetMouse()
   ::procName      := ;
   ::readVar       := ""
   ::procLine      := ;
   ::lastExitState := ;
   ::lastPos       := ;
   ::thisPos       := ;
   ::nextPos       := 0
   ::getList       := {}
   ::lastStatus    := {}
RETURN self

*****************************************************************************
* Save READ status variables and reset to default values
* Compatibility: The Updated status is not saved
*****************************************************************************
CLASS METHOD ReadStatus:Save()
   LOCAL oStatus

   /* Create new instance to save current status variables */
   oStatus                := ::new() 
   oStatus:lKillRead      := ::killRead
   oStatus:lHitTop        := ::hitTop
   oStatus:lHitBottom     := ::hitBottom
   oStatus:cProcName      := ::procName
   oStatus:nProcLine      := ::procLine
   oStatus:nLastExitState := ::lastExitState
   oStatus:nLastPos       := ::lastPos
   oStatus:nThisPos       := ::thisPos
   oStatus:aGetList       := ::getList
   oStatus:cReadVar       := ::readVar
   oStatus:oActiveGet     := ::activeGet
   oStatus:oLastActiveGet := ::lastActiveGet

   AAdd(::lastStatus, oStatus)

   ::updated              := ;
   ::killRead             := ;
   ::hitTop               := ;
   ::hitBottom            := .F.
   ::lastExitState        := ;
   ::nextPos              := ;
   ::thisPos              := ;
   ::lastPos              := ;
   ::procLine             := 0
   ::procName             := ;
   ::readVar              := ""
   ::activeGet            := ;
   ::lastActiveGet        := NIL

RETURN self

*****************************************************************************
* Restore saved READ status variables
* Compatibility: The Updated status is not restored
*****************************************************************************
CLASS METHOD ReadStatus:Restore()
   LOCAL oStatus
   IF ! Empty(::lastStatus)
      oStatus         := ATail(::lastStatus)
      ::killRead      := oStatus:lKillRead
      ::hitTop        := oStatus:lHitTop
      ::hitBottom     := oStatus:lHitBottom
      ::lastExitState := oStatus:nLastExitState
      ::procName      := oStatus:cProcName
      ::readVar       := oStatus:cReadVar
      ::procLine      := oStatus:nProcLine
      ::getList       := oStatus:aGetList
      ::lastPos       := oStatus:nLastPos
      ::thisPos       := oStatus:nThisPos
      ::activeGet     := oStatus:oActiveGet
      ::lastActiveGet := oStatus:oLastActiveGet
      ASize(::lastStatus, Len(::lastStatus)-1 )
   ENDIF
RETURN self

*****************************************************************************
* Find the position of the next Get object in oStatus:getList.
* It depends on the active Get and its :exitState
*****************************************************************************
CLASS METHOD ReadStatus:Settle( nPos )
   LOCAL nExitState

   IF Valtype( nPos ) != "N" .OR. nPos < 1 .OR. ( nPos > ::lastPos .AND. ::lastPos > 0 )
      nPos := ::thisPos
   ENDIF

   IF nPos == 0
      nExitState := GE_DOWN
   ELSE
      nExitState := ::getList[ nPos ]:exitState
      IF nExitState == NIL
         nExitState := GE_NOEXIT
      ENDIF
   ENDIF

   IF nExitState == GE_ESCAPE .OR. ;
      nExitState == GE_WRITE
      ::thisPos := 0
      /* Terminate READ */
      RETURN self
   ENDIF

   IF nExitState == GE_WHEN
      /* WHEN condition failed: Use prior ExitState */
      nExitState := ::lastExitState
      IF nExitState == GE_LASTGET
         /*
          * The WHEN condition failed for the last GET. 
          * Choose next GET.
          */
         nExitState := GE_DOWN
      ENDIF
   ELSE
      /* Reset status */
      ::lastPos   := nPos
      ::hitTop    := ;
      ::hitBottom := .F.
   ENDIF

   ::thisPos := nPos

   DO CASE  
   CASE nExitState == GE_MOUSE
      /* Position of next Get object */
      ::thisPos := ::nextPos
      ::nextPos := 0

   CASE nExitState == GE_UP 
      /* Previous Get object */
      ::thisPos--

   CASE nExitState == GE_DOWN .OR. nExitState == GE_ENTER
      /* Next Get object */
      ::thisPos++

   CASE nExitState == GE_TOP 
      /* First Get object */
      ::thisPos  := 1
      ::hitTop   := .T.
      nExitState := GE_DOWN

   CASE nExitState == GE_BOTTOM 
      /* Last Get object */
      ::thisPos  := Len( ::getList )
      ::hitBottom:= .T.
      nExitState := GE_UP

   CASE nExitState == GE_LASTGET
      /* Last Get object that had focus */
      ::thisPos  := AScan( ::getList, ::lastActiveGet )

   ENDCASE

   IF ::thisPos < 1
      /* Exited from first Get upwards */
      IF ! ReadExit() .AND. ;
         ! ::hitBottom

         ::hitTop  := .T.
         ::thisPos  := ::lastPos
         nExitState:= GE_DOWN
      ENDIF

   ELSEIF ::thisPos > Len( ::getList )
      /* Exited from last Get downwards */
      IF ! ReadExit() .AND. ;
         ! ( nExitState == GE_ENTER ) .AND. ;
         ! ::hitTop

         ::hitBottom:= .T.
         ::thisPos  := ::lastPos
         nExitState := GE_UP
      ELSE
         /* Terminate READ */
         ::thisPos := 0
      ENDIF
   ENDIF

   /* Save last exit state */
   ::lastExitState := nExitState
   IF ::thisPos <> 0
      ::getList[ ::thisPos ]:exitState := nExitState
   ENDIF

RETURN self

*****************************************************************************
* Determine active Get object                  (-> GetActive() )
* Determine name of variable to be edited      (-> ReadVar() )
*****************************************************************************
CLASS METHOD ReadStatus:PostActiveGet()

   IF ! ::lastActiveGet == ::getList[ ::thisPos ]
      ::lastActiveGet := ::activeGet
   ENDIF

   ::activeGet := ::getList[ ::thisPos ]
   ::readVar   := GetVarName( ::activeGet )

   IF ::lastActiveGet == NIL
      /* the very first Get */
      ::lastActiveGet := ::activeGet
   ENDIF

   DispScoreboard()
RETURN self

*****************************************************************************
* Get the name of variable that is the subject of the GET
*****************************************************************************
STATIC FUNCTION GetVarName( oGet )
RETURN IIf( oGet:name==NIL, "", Upper(oGet:name) )

*****************************************************************************
* Left mouse click
* Find out which Get object was clicked
*****************************************************************************
CLASS METHOD ReadStatus:LbClick( nMouseRow, nMouseCol )
   LOCAL nPos, nLen := Len(::getList)

   IF ( nPos := ::activeGet:posInBuffer( nMouseRow, nMouseCol ) ) <> 0
      ::activeGet:pos := nPos
      ::activeGet:display()
   ELSE
      ::nextPos := 0

      FOR nPos := 1 TO nLen
         IF ::getList[nPos]:posInBuffer( nMouseRow, nMouseCol ) <> 0
            ::nextPos := nPos
            EXIT
         ENDIF
      NEXT

      IF ::nextPos <> 0
         ::activeGet:exitState := GE_MOUSE
      ENDIF
   ENDIF

RETURN self

