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

#define MENU_FAIL      0
#define MENU_DONE      1
#define MENU_LEFT      2
#define MENU_RIGHT     3

**
** Notes :
**
** If an action returns MENU_FAIL, it must restore the screen !
**

static scNormColor   := 48
static scHighColor   := 79
static scGrayColor   := 55
static scHotKeyColor := 52

static saMnu := NIL
static saBar := NIL

static snLastChoice := 0
static snRequest
static slDrop := .f.

static saActionStack := {}

FUNCTION BeginJob(c1,c2)
local c := alltrim(c1)
if c2 != NIL
  c += "|" + alltrim(c2)
endif
aadd(saActionStack,c)
if USRATTR_D $ UsrAttrib()
  rpt_write(repl("ù",len(saActionStack))+c)
endif
RETURN .t.

FUNCTION EndJob
asize(saActionStack,len(saActionStack)-1)
RETURN NIL

FUNCTION MnuJobName()
local i
local c := ""
for i := 1 to len(saActionStack)
  c += saActionStack[i] + ", "
next i
RETURN c

FUNCTION MnuItemName
local nPos
local c := atail(saActionStack)
c := substr(c,at("|",c)+1)
c := alltrim(strtran(c,"~"))
if (nPos := at("[",c)) > 0
  c := trim(left(c,nPos-1))
endif
RETURN c


FUNCTION DoEach(aBar,xlBefore)
local i,j
default xlBefore to ".t."
for i := 1 to len(aBar)
  for j := 1 to len(aBar[i][MI_SUBMENU])
    * if len( aBar[i][MI_SUBMENU] ) > 0
    if len(aBar[i][MI_SUBMENU][j][MI_PROMPT]) > 1
      BeginJob(aBar[i][MI_PROMPT],aBar[i][MI_SUBMENU][j][MI_PROMPT])
      if ! xparse(xlBefore)
        EndJob()
        RETURN .f.
      endif
      eval(aBar[i][MI_SUBMENU][j][MI_ACTION])
      EndJob()
    endif
  next j
next i
RETURN .t.


**
** hMenu() - execute a horizontal menu
**
FUNCTION hMenu(aBar,nRow,nLeft,nRight,cColor,nKey)
local nCurrent := 1
local cSaveScr := savescreen(nRow,nLeft,nRow,nRight)
local lSubMenu := .F.
local nCol := nLeft
local i,j
local nRequest   := snRequest
local cNormColor := scNormColor
local cHighColor := scHighColor
local cGrayColor := scGrayColor
local cHotKeyColor := scHotKeyColor
local bSetAltF1
snRequest := MENU_FAIL
if nKey != NIL
  for i := 1 to len(aBar)
    if aBar[i][MI_HOTKEY] == nKey
      nCurrent := i
      lSubMenu := .T.
      exit
    endif
    for j := 1 to len(aBar[i][MI_SUBMENU])
      if aBar[i][MI_SUBMENU][j][MI_HOTKEY] == nKey
        if eval(aBar[i][MI_SUBMENU][j][MI_WHEN])
          BeginJob(aBar[i][MI_PROMPT],aBar[i][MI_SUBMENU][j][MI_PROMPT])
          eval(aBar[i][MI_SUBMENU][j][MI_ACTION])
          EndJob()
          snRequest := nRequest
          RETURN .T.
        endif
      endif
    next j
  next i
  if ! lSubMenu
    snRequest := nRequest
    RETURN .F.
  endif
endif
saMnu := aBar
* do while .t.
  MnuSetColor(cColor)
  #ifdef DEF_VIDSTR
    // Confirm(ntrim(nRow)+","+ntrim(nLeft)+"...")
    ft_vidstr(nRow,nLeft,space(nRight-nLeft+1),scNormColor)
  #else
    @ nRow, nLeft say space(nRight-nLeft+1) color (scNormColor)
  #endif
  for i := 1 to len(aBar)
    aBar[i][MI_ROW]    := nRow
    aBar[i][MI_COL]    := nCol
    if len( aBar[i][MI_SUBMENU] ) > 0
      aBar[i][MI_ACTIVE] := .T.
    else
      aBar[i][MI_ACTIVE] := .F.
    endif
    nCol += len(aBar[i][MI_PROMPT])
    DispNormal(aBar[i])
  next i
  nCurrent := MnuSettleDown(aBar,nCurrent)
  do while snRequest == MENU_FAIL
    DispHigh(aBar[nCurrent])
    if lSubMenu
      vMenu( ;
        aBar[nCurrent][MI_PROMPT], ;
        aBar[nCurrent][MI_SUBMENU], ;
        aBar[nCurrent][MI_ROW] + 2, ;
        aBar[nCurrent][MI_COL], ;
        NIL, NIL, ;
        aBar[nCurrent][MI_HKCHAR] ;
      )
      if snRequest == MENU_RIGHT
        nKey     := K_RIGHT
        snRequest := MENU_FAIL
      elseif snRequest == MENU_LEFT
        nKey     := K_LEFT
        snRequest := MENU_FAIL
      elseif snRequest == MENU_FAIL
        * snRequest := MENU_FAIL
        lSubMenu := .F.
        loop
      else // snRequest is MENU_DONE
        * Warning("hMenu() exits cause snRequest is MENU_DONE")
        // snRequest := nRequest // 19990915
        exit
      endif
    else
      if AppTerminate()
        nKey := K_ESC
      else
        bSetAltF1 := SetKey(K_ALT_F1,NIL)
        nKey := WaitKeySet() // inkey(0)
        SetKey(K_ALT_F1,bSetAltF1)
      endif
    endif
    DispNormal(aBar[nCurrent])
    if nKey == K_ESC .or. nKey == K_ALT
      * Warning("hMenu() exits cause ESC")
      exit
    elseif nKey == K_ENTER .or. nKey == K_DOWN
      lSubMenu := .T.
    elseif nKey == K_HOME
      nCurrent := MnuSettleUp(aBar,1)
    elseif nKey == K_END
      nCurrent := MnuSettleDown(aBar,len(aBar))
    elseif nKey == K_RIGHT
      if nCurrent < len(aBar)
        nCurrent++
      else
        nCurrent := 1
      endif
      nCurrent := MnuSettleDown(aBar,nCurrent)
    #ifdef DEF_HELP
    elseif nKey == K_ALT_F1
      WinHelp(WinSetHelp() + "-" + aBar[nCurrent][MI_HKCHAR])
    #endif DEF_HELP
    elseif nKey == K_LEFT
      if nCurrent > 1
        nCurrent--
      else
        nCurrent := len(aBar)
      endif
      nCurrent := MnuSettleUp(aBar,nCurrent)
    elseif nKey > 32 .and. nKey < 255
      for i := 1 to len(aBar)
        if upper(aBar[i][MI_HKCHAR]) == upper(chr(nKey))
          if aBar[i][MI_ACTIVE]
            nCurrent := i
            lSubMenu := .T.
          endif
          exit
        endif
      next i
    else
      lSubMenu := .F.
    endif
  enddo
* enddo
* if snRequest != MENU_FAIL
*   Warning("hMenu() exits cause snRequest != MENU_FAIL")
* endif
restscreen(nRow,nLeft,nRow,nRight,cSaveScr)
scNormColor   := cNormColor
scHighColor   := cHighColor
scGrayColor   := cGrayColor
scHotKeyColor := cHotKeyColor
snRequest     := nRequest
RETURN .T.


**
** MnuSetColor()
**
STATIC FUNCTION MnuSetColor(cColor)
local aColor := ListAsArray(cColor,",")
  if len(aColor) == 4
    scNormColor   := ColConvert(aColor[1])
    scHighColor   := ColConvert(aColor[2])
    scGrayColor   := ColConvert(aColor[3])
    scHotKeyColor := ColConvert(aColor[4])
  endif
RETURN .t.


FUNCTION DispNormal(a)
if a[MI_ACTIVE]
  * #ifdef DEF_VIDSTR
    ft_vidstr(a[MI_ROW],a[MI_COL],a[MI_PROMPT],scNormColor)
  * #else
  *   @ a[MI_ROW],a[MI_COL] say a[MI_PROMPT] color(scNormColor)
  * #endif
  if a[MI_HKPOS] != 0
    * #ifdef DEF_VIDSTR
      ft_vidstr( ;
        a[MI_ROW], ;
        a[MI_COL]+a[MI_HKPOS]-1, ;
        a[MI_HKCHAR], ;
        scHotKeyColor ;
      )
    * #else
    *   @ a[MI_ROW], a[MI_COL]+a[MI_HKPOS]-1 say a[MI_HKCHAR] ;
    *            color (scHotKeyColor)
    * #endif
  endif
else
  * #ifdef DEF_VIDSTR
    ft_vidstr(a[MI_ROW],a[MI_COL],a[MI_PROMPT],scGrayColor)
  * #else
  *   @ a[MI_ROW],a[MI_COL] say a[MI_PROMPT] color(scGrayColor)
  * #endif
endif
RETURN NIL

FUNCTION DispHigh(a)
* #ifdef DEF_VIDSTR
  ft_vidstr(a[MI_ROW],a[MI_COL],a[MI_PROMPT],scHighColor)
* #else
*   @ a[MI_ROW], a[MI_COL] say a[MI_PROMPT] color (scHighColor)
* #endif
RETURN NIL

**
** vMenu() - execute a vertival menu
**
** nRow : row number where first item should be displayed
**
STATIC FUNCTION vMenu(cMnuName,aMnu,nRow,nCol,cTitle,nCurrent,cHkChar)
local nMaxLen := 20
local lDrop := slDrop
local i
local nTop    := nRow - 1
local nLeft   := nCol - 1
local nRight
local nBottom
local cSaveScr
local nItemCount := len(aMnu)
local bSetAltF1
local uEval
default cHkChar to ""
for i := 1 to len(aMnu)
  if aMnu[i][MI_PROMPT] == NIL
    nItemCount--
  else
    nMaxLen := max(nMaxLen,len(aMnu[i][MI_PROMPT]))
  endif
next i
nRight  := nCol+nMaxLen
for i := 1 to len(aMnu)
  if aMnu[i][MI_PROMPT] != NIL .and. aMnu[i][MI_PROMPT] != "-"
    aMnu[i][MI_PROMPT] := padr(aMnu[i][MI_PROMPT],nMaxLen)
  endif
next i
nBottom := nRow + nItemCount
**
** horizontal adjustment
**
if nLeft < 0
  nRight -= nLeft
  nLeft := 0
  nCol := 1
elseif nRight > maxcol()
  nLeft += ( maxcol() - nRight )
  nRight := maxcol()
  nCol := nLeft + 1
endif                                                        
**
** vertical adjustment
**
if nBottom > maxrow() - 3
  nTop -= (nBottom - (maxrow() - 3))
  nRow := nTop + 1
  nBottom := maxrow() - 3
endif
cSaveScr := savescreen(nTop,nLeft,nBottom,nRight)
slDrop := .f.
* ft_vidstr(nTop,nLeft,"Ú" + repl("Ä",len(aMnu[1][MI_PROMPT])) + "¿",scNormColor)
ft_vidstr(nTop,nLeft,"Ú" + repl("Ä",nMaxLen) + "¿",scNormColor)
if cTitle != NIL
  ft_vidstr(nTop,int((nLeft+nRight-len(cTitle))/2)," " + cTitle + " ",scNormColor)
endif
for i := 1 to len(aMnu) // nItemCount
  if aMnu[i][MI_PROMPT] == NIL
    aMnu[i][MI_ACTIVE] := .F.
    aMnu[i][MI_HKCHAR] := ""
  elseif aMnu[i][MI_PROMPT] == "-"
    aMnu[i][MI_ROW] := nRow
    aMnu[i][MI_COL] := nCol
    ft_vidstr(nRow,nLeft,"Ã" + repl("Ä",nMaxLen) + "´",scNormColor)
    aMnu[i][MI_ACTIVE] := .F.
    nRow++                      
  else
    aMnu[i][MI_ROW] := nRow
    aMnu[i][MI_COL] := nCol
    ft_vidstr(nRow,nLeft ,"³",scNormColor)
    ft_vidstr(nRow,nRight,"³",scNormColor)
    aMnu[i][MI_ACTIVE] := eval(aMnu[i][MI_WHEN])
    DispNormal(aMnu[i])
    nRow++
  endif
next i
* ft_vidstr(nBottom,nLeft,"À" + repl("Ä",len(aMnu[1][MI_PROMPT])) + "Ù",scNormColor)
ft_vidstr(nBottom,nLeft,"À" + repl("Ä",nMaxLen) + "Ù",scNormColor)
default nCurrent to 1
nCurrent := MnuSettleDown(aMnu,nCurrent)
snLastChoice := 0
do while snRequest == MENU_FAIL
  DispHigh(aMnu[nCurrent])
  if AppTerminate()
    nKey := K_ESC
  else
    bSetAltF1 := SetKey(K_ALT_F1,NIL)
    nKey := WaitKeySet() // inkey(0)
    SetKey(K_ALT_F1,bSetAltF1)
  endif
  if nKey == K_ESC // .or. AppTerminate()
    exit
  elseif nKey == K_RIGHT
    snRequest := MENU_RIGHT
  elseif nKey == K_LEFT
    snRequest := MENU_LEFT
  #ifdef DEF_HELP
  elseif nKey == K_ALT_F1
    WinHelp(WinSetHelp() + "-" + cHkChar)
  #endif DEF_HELP
  elseif nKey == K_UP
    DispNormal(aMnu[nCurrent])
    if nCurrent > 1
      nCurrent--
    else
      nCurrent := len(aMnu) // nItemCount
    endif
    nCurrent := MnuSettleUp(aMnu,nCurrent)
  elseif nKey == K_DOWN
    DispNormal(aMnu[nCurrent])
    if nCurrent < len(aMnu) // nItemCount // len(aMnu)
      nCurrent++
    else
      nCurrent := 1
    endif
    nCurrent := MnuSettleDown(aMnu,nCurrent)
  elseif nKey == K_END .or. nKey == K_PGDN
    DispNormal(aMnu[nCurrent])
    nCurrent := len(aMnu) // nItemcount // n(aMnu)
    nCurrent := MnuSettleUp(aMnu,nCurrent)
  elseif nKey == K_HOME .or. nKey == K_PGUP
    DispNormal(aMnu[nCurrent])
    nCurrent := 1
    nCurrent := MnuSettleDown(aMnu,nCurrent)
  elseif nKey == K_ENTER
    snLastChoice := nCurrent
    BeginJob(cMnuName,aMnu[nCurrent][MI_PROMPT])
    eval(aMnu[nCurrent][MI_ACTION])
    EndJob()
    // snRequest := nRequest // 19990915
  elseif nKey > 32 .and. nKey < 255
    DispNormal(aMnu[nCurrent])
    for i := 1 to len(aMnu) // nItemcount // len(aMnu)
      if upper(aMnu[i][MI_HKCHAR]) == upper(chr(nKey))
        if aMnu[i][MI_ACTIVE]
          nCurrent := i
          snLastChoice := nCurrent
          DispHigh(aMnu[nCurrent])
          BeginJob(cMnuName,aMnu[nCurrent][MI_PROMPT])
          eval(aMnu[nCurrent][MI_ACTION])
          EndJob()
          // snRequest := nRequest // 19990915
        endif
        exit
      endif
    next i
  else
    DispNormal(aMnu[nCurrent])
    for i := 1 to len(aMnu) // nItemcount
      if aMnu[i][MI_HOTKEY] == nKey
        if aMnu[i][MI_ACTIVE]
          nCurrent := i
          snLastChoice := nCurrent
          DispHigh(aMnu[nCurrent])
          BeginJob(cMnuName,aMnu[nCurrent][MI_PROMPT])
          eval(aMnu[nCurrent][MI_ACTION])
          EndJob()
        endif
        exit
      endif
    next i
  endif
enddo
if ! slDrop
  restscreen(nTop,nLeft,nBottom,nRight,cSaveScr)
endif
slDrop := lDrop
RETURN NIL

FUNCTION MnuDrop()
slDrop := .t.
RETURN .t.

**
** MnuSettleUp()
**
STATIC FUNCTION MnuSettleUp(aMnu,nCurrent)
local i
if ! aMnu[nCurrent][MI_ACTIVE]
  for i := nCurrent to 1 step -1
    if aMnu[i][MI_ACTIVE]
      nCurrent := i
      exit
    endif
  next i
  if ! aMnu[nCurrent][MI_ACTIVE]
    for i := len(aMnu) to nCurrent step -1
      if aMnu[i][MI_ACTIVE]
        nCurrent := i
        exit
      endif
    next i
  endif
endif
RETURN nCurrent

**
** MnuSettleDown()
**
STATIC FUNCTION MnuSettleDown(aMnu,nCurrent)
local i
if ! aMnu[nCurrent][MI_ACTIVE]
  for i := nCurrent to len(aMnu)
    if aMnu[i][MI_ACTIVE]
      nCurrent := i
      exit
    endif
  next i
  if ! aMnu[nCurrent][MI_ACTIVE]
    for i := 1 to nCurrent - 1
      if aMnu[i][MI_ACTIVE]
        nCurrent := i
        exit
      endif
    next i
  endif
endif
RETURN nCurrent


STATIC FUNCTION ctokey(c)
local nKey := asc(upper(c))
local nAltKey
static saRegAltKeys := { { 65, K_ALT_A }, ;
                         { 66, K_ALT_B }, ;
                         { 67, K_ALT_C }, ;
                         { 68, K_ALT_D }, ;
                         { 69, K_ALT_E }, ;
                         { 70, K_ALT_F }, ;
                         { 71, K_ALT_G }, ;
                         { 72, K_ALT_H }, ;
                         { 73, K_ALT_I }, ;
                         { 74, K_ALT_J }, ;
                         { 75, K_ALT_K }, ;
                         { 76, K_ALT_L }, ;
                         { 77, K_ALT_M }, ;
                         { 78, K_ALT_N }, ;
                         { 79, K_ALT_O }, ;
                         { 80, K_ALT_P }, ;
                         { 81, K_ALT_Q }, ;
                         { 82, K_ALT_R }, ;
                         { 83, K_ALT_S }, ;
                         { 84, K_ALT_T }, ;
                         { 85, K_ALT_U }, ;
                         { 86, K_ALT_V }, ;
                         { 87, K_ALT_W }, ;
                         { 88, K_ALT_X }, ;
                         { 89, K_ALT_Y }, ;
                         { 90, K_ALT_Z } }
nAltKey := ASCAN( saRegAltKeys, {|x| x[1] == nKey} )
RETURN( IIF( nAltKey > 0, saRegAltKeys[nAltKey][2], NIL ) )


**
** AddItem()
**
FUNCTION AddItem(cPrompt,bAction,nHotKey,bWhen,aMnu)
local a := array(MI_ALEN)
default bWhen to {||.t.}
if cPrompt != NIL
  cPrompt := " " + cPrompt + " "
  a[MI_PROMPT] := strtran(cPrompt,"~")
  a[MI_HKPOS]  := at("~",cPrompt)
  if a[MI_HKPOS]  == 0
    a[MI_HKCHAR] := left(a[MI_PROMPT],1)
  else
    a[MI_HKCHAR] := substr(a[MI_PROMPT],a[MI_HKPOS],1)
  endif
endif
a[MI_HOTKEY] := nHotKey
a[MI_ACTION] := bAction
a[MI_WHEN]   := bWhen
if aMnu == NIL
  aadd( saMnu, a )
else
  aadd( aMnu, a )
endif
RETURN NIL


**
** AddLine()
**
FUNCTION AddLine(aMnu)
local a := array(MI_ALEN)
a[MI_PROMPT] := "-"
a[MI_HKCHAR] := ""
default aMnu to saMnu
if len(aMnu) > 0
  if atail(aMnu)[MI_PROMPT] != "-"
    aadd( aMnu, a )
  endif
endif
RETURN NIL

FUNCTION AddMenu(aBar,cPrompt,aItems)
local a := array(MI_ALEN)
cPrompt := " " + cPrompt + " "
a[MI_PROMPT]  := strtran(cPrompt,"~")
a[MI_HKPOS]   := at("~",cPrompt)
a[MI_HKCHAR]  := substr(a[MI_PROMPT],a[MI_HKPOS],1)
a[MI_HOTKEY]  := ctokey(a[MI_HKCHAR])
if aItems != NIL
  a[MI_SUBMENU] := aItems
else
  a[MI_SUBMENU] := {}
endif
saMnu := a[MI_SUBMENU]
if aBar != NIL
  aadd( aBar, a )
endif
RETURN a


*FUNCTION sm_Exec(aMnu,nTop,nLeft,cTitle,cColor,nStart,cHelp)
*local cNormColor := scNormColor
*local cHighColor := scHighColor
*local cGrayColor := scGrayColor
*local cHotKeyColor := scHotKeyColor
*local cSaveHelp := WinSetHelp()
*local nRequest   := snRequest
*WinSetHelp(cHelp)
*if cColor != NIL
*  MnuSetColor(cColor)
*endif
*if nTop == NIL
*  nTop := int( (maxrow() - len(aMnu)) / 2 )
*endif
*if nLeft == NIL
*  nLeft := int( (maxcol() - len(aMnu[1][MI_PROMPT])) / 2 )
*endif
*vMenu(aMnu,nTop,nLeft,cTitle,nStart)
*scNormColor   := cNormColor
*scHighColor   := cHighColor
*scGrayColor   := cGrayColor
*scHotKeyColor := cHotKeyColor
*WinSetHelp(cSaveHelp)
*snRequest   := nRequest
*RETURN NIL

FUNCTION MnuLastChoice ; RETURN snLastChoice

FUNCTION SetMnuDone
* Warning("SetMnuDone()")
snRequest := MENU_DONE
RETURN .t.

FUNCTION MnuDone
RETURN (snRequest == MENU_DONE)
// RETURN .t.

* FUNCTION u2mnu(u)
* if valtype(u) == "L"
*   RETURN MENU_DONE if u
*   RETURN MENU_FAIL
* endif
* default u to MENU_FAIL
* RETURN u

*FUNCTION MnuWrite(cFileName)
*local m := ""
*local i, j
*for i := 1 to len(saMnu)
*  for j := 1 to len(saMnu[i][MI_SUBMENU])
*    m += "|" + saMnu[i][MI_PROMPT] + "|"
*    if saMnu[i][MI_SUBMENU][j][MI_PROMPT] == NIL
*      m += ""
*    else
*      m += saMnu[i][MI_SUBMENU][j][MI_PROMPT]
*    endif
*    m += "|" + CR_LF
*  next j
*next i
*RETURN memowrit(cFileName,m)


**
** mnu-Dateien
**
FUNCTION MnuExec(aBar,cMnuName)
local aSaveBar := saBar
local lOkay
saBar := aBar
lOkay := FileExec(cMnuName+".MNU")
saBar := aSaveBar
RETURN lOkay


**
** Funktionen zur Verwendung in mnu-Dateien
**
FUNCTION MnuAddTitle(cPrompt)
#ifdef DEF_GUI
LOCAL oSubMenu
#endif
RETURN .f. if saBar == NIL
#ifdef DEF_GUI
oSubMenu := XbpMenu():new(saBar)
oSubMenu:title := cPrompt
oSubMenu:create()
saBar:addItem({ oSubMenu, NIL })
#else
AddMenu(saBar,cPrompt)
#endif
RETURN .t.

FUNCTION MnuAddItem(cPrompt,bAction,nHotKey,bWhen)
#ifdef DEF_GUI
local oMenu := saBar:getItem(saBar:numItems())[1]
oMenu:addItem( { cPrompt, bAction })
#else
local a := atail(saBar)
* RETURN .f. if saBar == NIL
AddItem(cPrompt,bAction,nHotKey,bWhen,a[MI_SUBMENU])
#endif
RETURN .t.

FUNCTION MnuAddSep()
#ifdef DEF_GUI
local oMenu := saBar:getItem(saBar:numItems())[1]
oMenu:addItem( {NIL, NIL, XBPMENUBAR_MIS_SEPARATOR, 0} )
#else
local a := atail(saBar)
AddLine(a[MI_SUBMENU])
#endif
RETURN .t.


