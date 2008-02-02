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

static scMainMenuColor      := "N/BG,W+/R,W/BG,R/BG"
static scEditMenuColor      := "N/W,W+/R,N+/W,R/W"
static scMessageColor       := "W+/B"
static scLegendColor        := "N/W"
static scStatusColor        := "N/BG"
static scBrowseColor        := "W/B,N/W,N/N,N/N,W/R"
static scWindowColor        := "N/W,W/N+,N/N,N/N,W/N+"
static scFullScreenColor    := "W/B,N/W,N/N,W+/BG,N/W+"
static scTextColor          := "W/B,N/W,,,N/W+"
static scWaitColor          := NIL // "N/W,W/N+,N/N,N/N,W/N+"
static scHelpColor          := NIL // "N/W,W/N+,N/N,N/N,W/N+"

FUNCTION CfgMainMenuColor   ; RETURN scMainMenuColor
FUNCTION CfgEditMenuColor   ; RETURN scEditMenuColor
FUNCTION CfgBrowseColor     ; RETURN scBrowseColor
FUNCTION CfgMessageColor    ; RETURN scMessageColor
FUNCTION CfgLegendColor     ; RETURN scLegendColor
FUNCTION CfgStatusColor     ; RETURN scStatusColor
FUNCTION CfgWindowColor     ; RETURN scWindowColor
FUNCTION CfgWaitColor       ; RETURN scWaitColor
FUNCTION CfgHelpColor       ; RETURN scHelpColor
FUNCTION CfgFullScreenColor ; RETURN scFullScreenColor
FUNCTION CfgTextColor       ; RETURN scTextColor


#ifndef DEF_GUI

**
**  LoadColor() (= ColRead() bis zum 19990702)
**
**
FUNCTION LoadColor(cFileName)
static a
* static scColorSet := ""
* RETURN scColorSet if cFileName == NIL
if a == NIL
  a := {}
  aadd(a,{ "MainMenuColor"   , {|x| scMainMenuColor   := x,.t. } })
  aadd(a,{ "EditMenuColor"   , {|x| scEditMenuColor   := x,.t. } })
  aadd(a,{ "BrowseColor"     , {|x| scBrowseColor     := x,.t. } })
  aadd(a,{ "MessageColor"    , {|x| scMessageColor    := x,.t. } })
  aadd(a,{ "LegendColor"     , {|x| scLegendColor     := x,.t. } })
  aadd(a,{ "StatusColor"     , {|x| scStatusColor     := x,.t. } })
  aadd(a,{ "WindowColor"     , {|x| scWindowColor     := x,.t. } })
  aadd(a,{ "WaitColor"       , {|x| scWaitColor       := x,.t. } })
  aadd(a,{ "HelpColor"       , {|x| scHelpColor       := x,.t. } })
  aadd(a,{ "FullScreenColor" , {|x| scFullScreenColor := x,.t. } })
  aadd(a,{ "TextColor"       , {|x| scTextColor       := x,.t. } })
endif
* scColorSet := cFileName
if at(".", cFileName) == 0
  cFileName += ".COL"
endif
IniLoad(a, cFileName, .F. )
* IniLoad(a, cFileName, .F. )
default scWaitColor to scWindowColor
default scHelpColor to scWindowColor
if ! WinLoadColor() // returns .f. if no active window
  setcolor( scTextColor )
endif
RETURN .T.

#endif

**
** MsgDisplay()
**
FUNCTION MsgDisplay(cMsg)
#ifndef DEF_GUI
@ maxrow()-2,0 say padr(cMsg,maxcol()+1) color (scMessageColor)
#endif
#ifdef DEF_VERBOSE
  if SetLogVerbose()
    if ! empty(cMsg)
      rpt_write(cMsg)
    endif
  endif
#endif
RETURN .t.

FUNCTION MsgDisp2(cMsg,nLen)
#ifndef DEF_GUI
default nLen to 10
@ maxrow()-2,(maxcol()+1-nLen) say padl(cMsg,nLen) color (scMessageColor)
#endif
RETURN .t.

* FUNCTION LegDisplay(cLeg)
* local cHelp := " ³ " + WinSetHelp() + " "
* @ 23,0 say padc(cLeg,80-len(cHelp)) + cHelp color (scLegendColor)
* RETURN NIL

FUNCTION LegDisplay(cLeg)
#ifndef DEF_GUI
local cHelp := " ³ " + WinSetHelp() + " "
local nPos := 0
local nLen := 0
local nPos2 := 1
cLeg := padc(cLeg,maxcol()+1-len(cHelp))
@ maxrow()-1,0 say cLeg + cHelp color (scLegendColor)
do while (nPos := at("[",substr(cLeg,nPos2))) > 0
  if (nLen := at("]",substr(cLeg,nPos2 + nPos - 1))) > 0
    ** nLen++
    @ maxrow()-1, nPos2 + nPos - 2 say substr(cLeg,nPos2+nPos-1,nLen) color "R/W"
    nPos2 += (nPos + nLen)
  else
    exit
  endif
enddo
#endif DEF_GUI
RETURN NIL



FUNCTION LegDisp2(cLeg)
#ifndef DEF_GUI
@ maxrow()-1,maxcol()-7 say padr(cLeg,8) color (scLegendColor)
#endif DEF_GUI
RETURN NIL

FUNCTION StaDisplay(cSta)
#ifndef DEF_GUI
local c := " " + time()
if UserDate() != NIL
  c += " " + dtoc(UserDate()) + " ³ "
endif
if ! empty(UserId())
  c += trim(UserId()) + "/" + ArcName() + " ³ "
endif
@ maxrow(),0 say padr(c + cSta,maxcol()+1) color (scStatusColor)
#endif DEF_GUI
RETURN NIL

FUNCTION StaDisp2(cLeg)
#ifndef DEF_GUI
cLeg := "    ³ " + cLeg
@ maxrow(),maxcol()-len(cLeg) say cLeg color (scStatusColor)
#endif DEF_GUI
RETURN NIL




**
** ColConvert
**
FUNCTION ColConvert(cColor)
#ifdef DEF_VIDSTR
static aConvert := { "N", "B", "G", "BG", "R", "RB", "GR", "W" }
local nSlash
local i
local nAttrib := 0
if "+" $ cColor
  nAttrib += 8
  cColor := strtran(cColor,"+")
endif
nSlash := at("/",cColor)
for i := 1 to len(aConvert)
  if left(cColor,nSlash - 1) == aConvert[i]
    nAttrib += i - 1
  endif
next i
for i := 1 to len(aConvert)
  if substr(cColor,nSlash + 1) == aConvert[i]
    nAttrib += (i - 1) * 16
  endif
next i
RETURN nAttrib
#else
  RETURN cColor
#endif
