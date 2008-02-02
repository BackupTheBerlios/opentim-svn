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

#ifdef __XPP__

#include "APPEVENT.CH"

**
** TxtEdit()
**
FUNCTION TxtEdit( ;
  bMemo, ;
  nT, ;
  nL, ;
  nB, ;
  nR, ;
  lEdit, ;
  nWidth, ;
  bNotUsed, ;
  lGetMode ;
)
  LOCAL nEvent, mp1, mp2, oXbp
  LOCAL cText, oMLE
  local oAppWindow := SetAppWindow()
  local nRowCount  := nB - nT + 1
  local nColCount  := nR - nL + 1
  local nX         := nL * oAppWindow:fontWidth
  local nY         := ( MaxRow() - nB ) * oAppWindow:fontHeight
  * nX         += oAppWindow:currentPos()[1]
  * nY         += oAppWindow:currentPos()[2]

  logconsole("TxtEdit() begins")
  // Read memo into LOCAL variable
  cText := eval(bMemo)

  // Create MLE, specify position using :create() and
  // assign data code block accessing LOCAL variable
  oMLE          := XbpMLE():new()
  oMLE:wordWrap :=.t.
  if lGetMode
    oMLE:ignoreTab :=.t.
  endif
  * oMLE:dataLink := bMemo
  oMLE:dataLink := {|x| IIf( x==NIL, cText, cText := x ) }
  oMLE:create( , , {nX,nY}, { nColCount*oAppWindow:fontWidth,;
                              nRowCount*oAppWindow:fontHeight} )

  // Copy text from LOCAL variable into edit buffer
  // via :dataLink
  oMLE:setData()
  SetAppFocus(oMLE) // :setInputFocus()

  // Event loop
  nEvent := 0
  DO WHILE .t.
     nEvent := AppEvent( @mp1, @mp2, @oXbp )
     if nEvent == xbeK_ESC
       if oMLE:changed .and. ! Confirm(MSG009)
         oMLE:undo()
       endif
       snRequest := TXT_EXIT
       exit
     elseif nEvent == xbeK_F10 .or. nEvent == xbeK_F3 .or. nEvent == xbeP_Close
       snRequest := TXT_EXIT
       exit
     elseif nEvent == xbeK_TAB
       snRequest := TXT_DOWN
       exit
     elseif nEvent == xbeK_SH_TAB
       snRequest := TXT_UP
       exit
     *elseif nEvent == xbeP_Keyboard
     *  if lastkey() == K_TAB
     *    snRequest := TXT_DOWN
     *    exit
     *  elseif lastkey() == K_SH_TAB
     *    snRequest := TXT_UP
     *    exit
     *  endif
     endif
     logconsole(eventname(nEvent))
     oXbp:handleEvent( nEvent, mp1, mp2 )
  ENDDO

  oMLE:getData() // write edit buffer to dataLink

  // Write text from the LOCAL variables back to the file
  IF oMLE:changed
     eval(bMemo,cText)
  ENDIF

  oMLE:destroy()
  logconsole("TxtEdit() ends")

RETURN cText


#else

