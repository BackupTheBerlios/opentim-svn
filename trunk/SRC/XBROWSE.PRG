** Copyright (c) 2007 Luc Saffre
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


// Graphic browser for databases 
// In the example, the user defined function GuiBrowseDB() is 
// programmed. It assigns all navigation code blocks to an  
// XbpBrowse object which are necessary to browse a database. 
// Table columns are created within a FOR..NEXT loop. 
// The browser is displayed in the event loop.

#include "LIB.CH"
#include "APPEVENT.CH"
#include "common.ch"

#pragma Library( "XppUi2.lib" )


PROCEDURE AppSys

// Desktop remains application window

RETURN





PROCEDURE Main

   LOCAL nEvent, mp1, mp2, oXbp, oBrowse, cField, i



   USE Customer NEW



   // Create a hidden dialog window

   oXbp := GuiStdDialog( "Standard GUI Browser for DBF" )



   // Create browser in the window

   oBrowse := GuiBrowseDb( oXbp:drawingArea )



   // Add columns for all fields of the database

   FOR i:=1 TO FCount()

      cField := FieldName( i )

      oBrowse:addColumn( FieldBlock(cField), , cField )

   NEXT



   // The browser always fills the entire window after :resize()

   oXbp:drawingArea:resize := ;

      {|mp1,mp2,obj| obj:childList()[1]:setSize(mp2) }



   oXbp:show()

   oBrowse:show()

   SetAppFocus( oBrowse )



   DO WHILE nEvent <> xbeP_Close

      nEvent := AppEvent( @mp1, @mp2, @oXbp )

      oXbp:handleEvent( nEvent, mp1, mp2 )

   ENDDO

RETURN





******************************************************************

* Create a GUI browser with navigation code blocks for a database

******************************************************************

FUNCTION GuiBrowseDB( oParent, aPos, aSize )

   LOCAL oBrowse



   oBrowse := XbpBrowse():new( oParent,, aPos, aSize ):create()



   // Navigation code blocks for the browser

   oBrowse:skipBlock     := {|n| DbSkipper(n) }

   oBrowse:goTopBlock    := {| | DbGoTop()    }

   oBrowse:goBottomBlock := {| | DbGoBottom() }

   oBrowse:phyPosBlock   := {| | Recno()      }



   // Navigation code blocks for the vertical scroll bar

   oBrowse:posBlock      := {| | DbPosition()    }

   oBrowse:goPosBlock    := {|n| DbGoPosition(n) }

   oBrowse:lastPosBlock  := {| | 100             }

   oBrowse:firstPosBlock := {| | 0               }



RETURN oBrowse





******************************************************************

* Create a hidden dialog window

******************************************************************

FUNCTION GuiStdDialog( cTitle )

   LOCAL oDlg



   DEFAULT cTitle TO "Standard Dialog Window"



   oDlg          := XbpDialog():new( ,,{10,10}, {600,400},, .F. )

   oDlg:icon     := 1

   oDlg:taskList := .T.

   oDlg:title    := cTitle

   oDlg:create()

   oDlg:drawingArea:setFontCompoundName( "8.Helv" )



RETURN oDlg

