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

** Note: this is a modified version of Alaska's APPSYS.PRG
** (Copyright Alaska Software, (c) 1997-2006. All rights reserved.)

#include "LIB.CH"
#include "XBP.CH"
#include "RSC.CH"

* #define DEF_ROWS       43
* #define DEF_COLS       100
* #define DEF_FONTHEIGHT 16
* #define DEF_FONTWIDTH   9

static snRows := 25
static snCols := 80
static snFontWidth := 9
static snFontHeight := 16
#ifdef __OS2__
static scFontName := "System VIO"
#endif
#ifdef __WIN32__
// static scFontName := "Alaska Crt"
static scFontName := "Lucida Console" // no box characters ?
// "Courier New"
#endif
static slFullScreen := .f.
static saPos
static soFullFont := NIL
static soFont
static snFullBottom := 25
static snFullDelta:= 2


FUNCTION SetWinFont(cFontName,nWidth,nHeight)
if nWidth != NIL ; snFontWidth := nWidth ; endif
if nHeight!= NIL ; snFontHeight := nHeight ; endif
if cFontName != NIL ; scFontName := cFontName ; endif
RETURN .t.

FUNCTION SetWinDimension(nCols,nRows,nFullBottom,nFullDelta)
if nCols != NIL ; snCols := nCols  ; endif
if nRows != NIL ; snRows := nRows ; endif
if nFullBottom != NIL ; snFullBottom := nFullBottom ; endif
if nFullDelta != NIL ; snFullDelta:= nFullDelta ; endif
RETURN .t.

FUNCTION GetWinFont()
RETURN soFullFont if slFullScreen
RETURN soFont


FUNCTION SelectFont()
local oFont
local oFontDlg := XbpFontDialog():new()  // Create object
// configure font dialog
oFontDlg:familyName := soFont:familyName
oFontDlg:fixedOnly := .t.
oFontDlg:create()                  // Request dialog
oFont := oFontDlg:display()        // Activate dialog
if oFont != NIL
  * soFont := oFont
  soFont := XbpFont():new()
  soFont:familyName := oFont:familyName
  soFont:height     := oFont:height
  soFont:width      := oFont:width
  soFont:codepage := 255 // OEM
  soFont:create()
  SetAppWindow():setFont(soFont)
endif
RETURN .t.

FUNCTION MoveWindow(nX,nY)
local oCrt := SetAppWindow()
local aPos := oCrt:currentPos()
aPos[1] += nX
aPos[2] += nY
oCrt:setPos(aPos)
RETURN .t.

FUNCTION AltEnter()
local oCrt := SetAppWindow()
local aSizeDesktop    := AppDesktop():currentSize()
if slFullScreen
  slFullScreen := .f.
  oCrt:setFont(soFont)
  oCrt:setPos(saPos)
else
  saPos := oCrt:currentPos()
  if soFullFont == NIL
    soFullFont := XbpFont():new()              // Create XbpFont object
    * soFullFont:familyName := soFont:familyName
    soFullFont:familyName := oCrt:fontName
    soFullFont:height     := int((aSizeDesktop[2]-snFullBottom-snFullDelta) / snRows)
    soFullFont:width      := int((aSizeDesktop[1]-snFullDelta) / snCols)
    soFullFont:codePage   := 255 // OEM
    soFullFont:create()                        // Create font
  endif
  oCrt:setFont(soFullFont)
  oCrt:setPos({0,snFullBottom})
  slFullScreen := .t.
endif
* oCrt:show()
SetMsg(oCrt:fontName+" "+ntrim(oCrt:setFont():width);
                    +"x"+ntrim(oCrt:setFont():height);
                    +iif(slFullScreen," (full)"," (windowed)"))
RETURN .t.


****************************************************************************
* Function AppSys() to create default output devices
****************************************************************************
PROCEDURE AppSys()

  LOCAL oCrt, nAppType := AppType()
  LOCAL aSizeDesktop, aPos
  * local oBmp

  SetDialog(.f.)
  if ! AppInit("TIM", 4.0)
    MsgBox(SetMsg(),"Error during AppInit():")
    quit // 20080318
  endif
  SetDialog(.t.)

#ifdef DEF_GUI

  soFont := XbpFont():new()
  soFont:familyName   := scFontName
  soFont:width      := snFontWidth
  soFont:height     := snFontHeight
  soFont:codePage   := 255 // OEM
  soFont:fixed      := .t.
  soFont:create()

  // Compute window position (center window
  // on the Desktop)
  aSizeDesktop    := AppDesktop():currentSize()
  aPos            := { (aSizeDesktop[1]-(snCols * soFont:width))  /2, ;
                       (aSizeDesktop[2]-(snRows * soFont:height)) /2  }

  oCrt := XbpDialog():New(NIL,NIL,aPos,;
    { snCols*soFont:width, snRows*soFont:height } )
  oCrt:setTitle(AppName())
  oCrt:icon       := RES_ICON_LOGO
  oCrt:clipChildren := .t.
  oCrt:create()

  SetAppWindow ( oCrt )
  oCrt:setFont(soFont)
  oCrt:show()
  SetKey(422,{||AltEnter()})

#else

  DO CASE 

    // PM Mode: create an XbpCrt instance
    CASE nAppType == APPTYPE_PM

      soFont := XbpFont():new()
      soFont:familyName   := scFontName
      #ifdef __OS2__
      soFont:familyName   := "System VIO"
      #endif
      #ifdef __WIN32__
      * soFont:familyName   := "Alaska Crt"
      * soFont:familyName   := "Lucida Console" // no box characters
      * soFont:familyName   := "Courier"
      #endif
      soFont:width      := snFontWidth
      soFont:height     := snFontHeight
      soFont:codePage   := 255 // OEM
      soFont:fixed      := .t.
      soFont:create()


      // Compute window position (center window 
      // on the Desktop)
      aSizeDesktop    := AppDesktop():currentSize()
      aPos            := { (aSizeDesktop[1]-(snCols * soFont:width))  /2, ;
                           (aSizeDesktop[2]-(snRows * soFont:height)) /2  }

      // Create XbpCRT object
      oCrt := XbpCrt():New ( NIL, NIL, aPos, snRows, snCols, AppName(),.f. )
      * oCrt:FontWidth  := snFontWidth
      * oCrt:FontHeight := snFontHeight
      * oCrt:title      := AppName()
      oCrt:icon       := RES_ICON_LOGO
      oCrt:Create()

      // Init Presentation Space
      oCrt:PresSpace()

      * oBmp := XbpBitmap():new():create(oCrt:presSpace())
      * oBmp:loadFile("TIM.ICO")
      * oCrt:icon       := oBmp

      // XbpCrt gets active window and output device
      SetAppWindow ( oCrt )
      oCrt:setFont(soFont)
      * oCrt:close := { || AppNormEnd() }
      oCrt:show()
      * soFont := oCrt:setFont()
      SetKey(422,{||AltEnter()})
      * SetKey(408,{||MoveWindow(0,1)}) // K_ALT_UP
      * SetKey(416,{||MoveWindow(0,-1)}) // K_ALT_DOWN
      * SetKey(413,{||MoveWindow(1,0)}) // K_ALT_RIGHT
      * SetKey(411,{||MoveWindow(-1,0)}) // K_ALT_LEFT
      * SetKey(407,{||AltHome()})
      * SetKey(415,{||AltEnd()})
      SetMsg(oCrt:fontName+" "+ntrim(oCrt:setFont():width);
                    +"x"+ntrim(oCrt:setFont():height))

    // VIO or NOVIO Mode: create a RootCrt instance
    CASE nAppType == APPTYPE_VIO .OR. nAppType == APPTYPE_NOVIO

      // Create RootCrt object
      //
      // The IVar :CreateBuffer determines the behaviour of the RootCrt
      // when it is created in a shell window.
      //
      //   :CreateBuffer == .T. : The RootCrt will create a new
      //                          screen buffer with the same size
      //                          as the console window. This causes
      //                          the effect that outputs with
      //                          OutStd() or printf() wont be
      //                          displayed.
      //   :CreateBuffer == .F. : The RootCrt will use the screen 
      //                          buffer of the window where it runs
      //                          in.
      oCrt := RootCrt():New()
      oCrt:CreateBuffer := .T.
      oCrt:Create()

      // RootCrt gets active window and output device
      SetAppWindow ( oCrt )

  ENDCASE

#endif DEF_GUI

RETURN

FUNCTION hw2size(nHeight,nWidth)
RETURN { nWidth * soFont:width, nHeight * soFont:height }

FUNCTION tl2pos(nTop,nLeft)
local aSizeDesktop := AppDesktop():currentSize()
local a
* LogConsole("tl2pos("+utos(nTop)+","+utos(nLeft)+")")
default nTop to maxrow() / 5
default nLeft to maxcol() / 5
a := { nLeft * soFont:width, ;
  aSizeDesktop[2] - nTop * soFont:height }
* LogConsole("tl2pos("+utos(nTop)+","+utos(nLeft)+") -> "+utos(a))
RETURN a




#ifdef DEF_GUI

FUNCTION WinOpen( cTitle, ;
                  nTop, nLeft, ;
                  nHeight, nWidth, ;
                  lPerm, cColor, nBox, cHelp,;
                  cLeg )
local aPos
local oDlg
local aSizeDesktop    := AppDesktop():currentSize()
if empty(nHeight)
  nHeight := aSizeDesktop[2]-(snRows * soFont:height)/2
else
  nHeight *= soFont:height
endif
if empty(nWidth)
  nWidth  := aSizeDesktop[1]-(snCols * soFont:width)/2
else
  nWidth *= soFont:width
endif
aPos := { (aSizeDesktop[1]-nWidth)/2,(aSizeDesktop[2]-nHeight)/2  }
oDlg := XbpDialog():New(NIL,NIL,aPos, { nWidth, nHeight } )
oDlg:setTitle(AppName())
oDlg:create()
oDlg:showModal()
Warning("open window: "+cTitle)
RETURN .t.

FUNCTION maxrow ; RETURN snRows
FUNCTION maxcol ; RETURN snCols

FUNCTION WinClose
RETURN .t.

FUNCTION WinTop() ; raise("NotImplemented") ; RETURN NIL
FUNCTION WinLeft() ; raise("NotImplemented") ; RETURN NIL

FUNCTION Confirm(cMemo,txt2,cAnswer,cHelp,aKeys,cTitle,nTop)
LOCAL nButton := 0
if txt2 != NIL ; cMemo += CR_LF + txt2 ; endif
nButton := ConfirmBox( NIL, cMemo, cTitle, XBPMB_YESNO , ;
                      XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )

RETURN (nButton == XBPMB_RET_YES)

FUNCTION Warning(cMemo,txt2,cHelp,lConsole,cTitle,lCenter)
if txt2 != NIL ; cMemo += CR_LF + txt2 ; endif
RETURN .t. if SetBatch()
MsgBox(cMemo,cTitle)
RETURN .t.

FUNCTION Decide(cValid,txt1,txt2,cTitle) ; raise("NotImplemented") ; RETURN NIL
FUNCTION WinCR() ; RETURN NIL
FUNCTION WinHome ; RETURN NIL
FUNCTION WinEndX ; RETURN NIL
FUNCTION WinEndY ; RETURN NIL
FUNCTION WinIsFull ; RETURN NIL
FUNCTION WinDrop ; RETURN NIL
FUNCTION WinDisp2(cText) ; RETURN NIL
FUNCTION WinSetHelp(cHelp) ; RETURN NIL
FUNCTION WinTitle() ; RETURN SetAppWindow():getTitle()



#endif DEF_GUI

// EOF
