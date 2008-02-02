** ABROWSE.PRG : Browse an array using a specified code block

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

static snItem  := 1
static saItems := NIL
* static sbBlock := NIL
static snLastChoice := 0
// static slUpdated := .f.
static snLastKey := 0
static scPosit := ""

static MSG001 := "OK to delete element nø "


**
** aBrowse()
**
FUNCTION aBrowse( aItems, bBlock, nItem , lArrange, ;
                  bCreate, bDelete,                 ;
                  cTitle, bEnter,                   ;
                  bSpace, aHot, cHelp, aActions, cLegend , ;
                  nRow, nCol, lWrap, nWidth, bIdle, aExit, ;
                  win, nMode, bPosit, lPermanent, nFrame, ;
                  lArrowExit, lUpdated ;
)
#ifdef DEF_GUI
  local oDlg, oListBox
#else
  local nSaveItem := snItem
  local aOldItems := saItems
  * local bOldBlock := sbBlock
  local nCursor
  local column
  local b
#endif
local uItem
local nHeight := len(aItems) + 2
local i
default aExit to {}
default nMode to ABMODE_EDIT
default lPermanent to .f.
default lArrowExit to .f.
saItems := aItems
default lUpdated to .f.
default cTitle to "Select"
if len(saItems) == 0 // if array contains no element, create the first one
  snLastChoice := 0
  if bCreate == NIL
    // slUpdated := .f.
    Warning(cTitle + " : " + utr(;
      "Nothing to select from !",;
      "Auswahlliste leer !",;
      "la liste est vide !"))
    RETURN 0
  endif
endif
default nItem to 1
if nItem <= 0
  nItem := 1
endif
default lWrap to .f.
default lArrange to .T.
default nFrame to DBLFRAME
snItem  := nItem
* sbBlock := bBlock
if win == NIL
  if nHeight < 10 .and. bCreate != NIL
    nHeight := 10
  endif
  if nHeight > 18
    nHeight := 18
  endif
  if nRow != NIL
    if nRow + nHeight + 3 > maxrow()
      nHeight := maxrow() - nRow - 3
    endif
  endif
  if nWidth == NIL
    nWidth  := len(cTitle) // eval( bBlock, saItems[1] ) )
    for i := 1 to len(saItems)
      * if len( eval( bBlock, saItems[i] ) ) > nWidth
      nWidth := max( nWidth, len( eval( bBlock, saItems[i], i ) ) )
      * endif
    next i
    nWidth := min(nWidth,maxcol()-4)
    * nWidth := min(nWidth,76)
  endif
else
  nHeight := win[WIN_HEIGHT]
  nWidth  := win[WIN_WIDTH]
  nRow    := win[WIN_TOP]
  nCol    := win[WIN_LEFT]
endif
#ifdef DEF_GUI
  * oDlg := XbpDialog():new(NIL,NIL,tl2pos(nRow,nCol),hw2size(nHeight,nWidth))
  oDlg := XbpDialog():new(NIL,NIL,NIL,hw2size(nHeight,nWidth))
  oDlg:title := cTitle
  oDlg:create()
  CenterControl(oDlg)
  oListBox := XbpListbox():new(oDlg:drawingArea,NIL,NIL,;
    oDlg:drawingArea:currentSize())
  oListBox:markMode := XBPLISTBOX_MM_SINGLE
  for i := 1 to len(aItems)
    oListBox:addItem( eval(bBlock,aItems[i],i) )
    // LogConsole(eval(bBlock,aItems[i]))
  next i
  oListBox:ItemSelected := {|uNIL1, uNIL2, self| ;
    oDlg:modalResult := iif(len(self:getData()) == 1, ;
      self:getData()[1], 0)}
  oListBox:create()
  RETURN oDlg:showModal()
#else
  nCursor := setcursor(SC_NONE)
  if nMode == ABMODE_WAIT
    open window (cTitle) size  nHeight, nWidth  ;
                         home  nRow,nCol ;
                         frame NOFRAME ;
                         permanent .t. ;
                         color (CfgWaitColor())
  else
    open window (cTitle) size nHeight, nWidth + 4 ;
                         help (cHelp) ;
                         frame (nFrame) ;
                         home nRow,nCol ;
                         permanent (lPermanent)
  endif
  b := TBrowseNew( row(), col(), WinEndY(), WinEndX() )
  column := TBcolumnNew( "", {|| ;
            if( ;
              snItem > len(saItems), ;
              space(nWidth), ;
              padr( eval(bBlock,saItems[snItem],snItem), nWidth ) ;
            ) } ;
  )
  b:addColumn(column)
  if bCreate == NIL
    *column := TBcolumnNew( "", {|| ;
    *            padr( eval(sbBlock, saItems[snItem]), nWidth ) ;
    *          } )
    *b:addColumn(column)
    b:skipBlock     := {|n| SkipItem(n,.f.) }
    b:goBottomBlock := {|| snItem := len(saItems) }
  else
    *column := TBcolumnNew( "", {|| ;
    *          if( ;
    *            snItem > len(saItems), ;
    *            space(nWidth), ;
    *            padr( eval(sbBlock, saItems[snItem]), nWidth ) ;
    *          ) } ;
    *)
    *b:addColumn(column)
    b:skipBlock     := {|n| SkipItem(n,.t.) }
    b:goBottomBlock := {|| snItem := max(1,len(saItems)) }
  endif
  b:goTopBlock    := {|| snItem := 1 }
  if nItem > 1
    #ifdef __XPP__
    b:forceStable()
    #endif __XPP__
    b:rowPos := nItem
    if b:rowPos > nHeight - 2
      b:rowPos := nHeight - 2
    endif
    #ifdef __XPP__
      b:forceStable()
    #endif __XPP__
    b:configure()
  endif
  if nMode == ABMODE_WAIT
    b:autoLite := .f.
  else
    if cLegend != NIL
      SayLeg(cLegend)
    elseif lArrange
      SayLeg("[Alt-] [Alt-] to change order [Escape] Exit")
    endif
  endif
  do while .t.
    dispbegin()
    do while ( ! b:stabilize() )
      // 20030205
      if nextkey() != 0
        exit
      endif
      * #ifdef def_ALLKEY
      *   if ( nKey := allkey() ) != 0
      * #else
      *   if ( nKey := inkey() ) != 0
      * #endif
      *   exit
      * endif
    enddo
    dispend()
    if nMode == ABMODE_WAIT
      exit
    endif
    if b:stable
      if bIdle != NIL
        eval(bIdle, saItems[snItem])
      endif
      if ! SetDialog()
        snItem := 0
        // exit
        RETURN 0
      endif
    endif
    nKey := WaitKeySet()
    if aActions != NIL
      for i := 1 to len(aActions)
        if aActions[i][1] == nKey
          if snItem > len(saItems)
            nKey := eval(aActions[i][2],NIL,snItem)
          else
            nKey := eval(aActions[i][2],saItems[snItem],snItem)
          endif
          b:refreshCurrent()
          exit
        endif
      next i
      if nKey == NIL // lFound
        loop
      endif
    endif
    if ascan(aExit,nKey) != 0
      exit
    endif
    if nKey < 32 .or. nKey >= 256  // anti-condition siehe unten
      scPosit := ""
    endif
    if nKey == K_DEL
      if bDelete == NIL
        if Confirm(MSG001 + ntrim(snItem))
          lUpdated := .t.
          adel( saItems, snItem )
          asize( saItems, len(saItems) - 1 )
          b:refreshAll()
        endif
      elseif eval(bDelete,saItems[snItem])
        lUpdated := .t.
        adel( saItems, snItem )
        asize( saItems, len(saItems) - 1 )
        if len(saItems) == 0 .and. bCreate == NIL
          snItem := 0
          exit
        else
          b:refreshAll()
        endif
      endif
    elseif nKey == K_INS
      if ItemCreate(b,bCreate)
        lUpdated := .t.
        if b:rowPos < b:rowCount
          SetRowPos(b,b:rowPos+1)
          * b:rowPos += 1
          * b:configure()
        endif
        b:refreshAll()
      endif
    elseif nKey == K_ESC       ;  exit
    elseif nKey == K_RIGHT .and. lArrowExit    ;  exit
    elseif nKey == K_LEFT  .and. lArrowExit    ;  exit
    elseif nKey == K_F10       ;  exit
    elseif nKey == K_RETURN
      if snItem > len(saItems)
        if ItemCreate(b,bCreate)
          lUpdated := .t.
          b:refreshAll()
        endif
      else
        if bEnter != NIL
          eval(bEnter,saItems[snItem],snItem)
          b:refreshCurrent()
        else
          exit
        endif
      endif
    elseif nKey == K_SPACE .and. bSpace != NIL
      #ifdef __XPP__
        b:forceStable()
      #endif
      eval(bSpace,saItems[snItem],snItem)
      #ifdef __XPP__
        b:refreshAll()
        b:forceStable()
      #else
        b:refreshCurrent()
      #endif
    elseif nKey == K_ALT_F5
      b:refreshAll()
    elseif nKey == K_DOWN
      if snItem == len(saItems) .and. bCreate == NIL
        if lWrap
          b:goTop()
        endif
      else
        b:down()
      endif
    elseif nKey == K_UP
      if snItem == 1
        if lWrap
          b:goBottom()
        endif
      else
        b:up()
      endif
    elseif nKey == K_PGDN      ; b:pageDown()
    elseif nKey == K_PGUP      ; b:pageUp()
    elseif nKey == K_CTRL_PGDN ; b:goBottom()
    elseif nKey == K_END       ; b:goBottom()
    elseif nKey == K_CTRL_PGUP ; b:goTop()
    elseif nKey == K_HOME      ; b:goTop()
    elseif nKey == K_BS .and. ! empty(scPosit)
      scPosit := left(scPosit,len(scPosit)-1)
      SetMsg("Positionieren : " + scPosit)
    elseif nKey == K_ALT_UP .and. lArrange
      #ifdef __XPP__
        b:forceStable()
      #endif
      if snItem > 1
        lUpdated := .t.
        uItem := saItems[snItem]
        adel(saItems,snItem)
        ains( saItems,snItem - 1 )
        saItems[snItem - 1] := uItem
        b:up()
        b:forceStable()
        b:refreshAll()
      endif
    elseif nKey == K_ALT_DOWN .and. lArrange
      if snItem < len(saItems)
        lUpdated := .t.
        uItem := saItems[snItem]
        adel(saItems,snItem)
        snItem++
        ains(saItems,snItem)
        saItems[snItem] := uItem
        b:refreshAll()
        b:forceStable()
      endif
    elseif nKey >= 32 .and. nKey < 256 // anti-condition siehe oben
      if aHot == NIL
        if snItem > len(saItems)
          if ItemCreate(b,bCreate)
            lUpdated := .t.
            b:refreshAll()
          endif
        else
          **
          ** Positionier-Modus geht davon aus, dass das array alpabetisch
          ** sortiert ist.
          scPosit += upper(chr(nKey))
          SetMsg("Positionieren : " + scPosit)
          if bPosit == NIL
            for i := 1 to len(saItems)
              if upper(left(eval(bBlock,saItems[i],i),len(scPosit))) == scPosit
                exit
              endif
            next i
          else
            i := eval(bPosit,saItems,scPosit)
          endif
          if i > 0 .and. i != snItem .and. i <= len(saItems)
            snItem := i
            if i > b:rowCount
              SetRowPos(b,b:rowCount)
            else
              SetRowPos(b,i)
            endif
          endif
        endif
      else
        for i := 1 to len(aHot)
          if upper(chr(nKey)) == aHot[i]
            snItem   := i
            if bSpace != NIL
              eval(bSpace,saItems[snItem],snItem)
            endif
            SetRowPos(b,i)
            exit
          endif
        next i
      endif
    endif
  enddo
  close window
  if nKey == K_ESC
    snItem := 0
  endif
  if nKey == K_RIGHT .or. nKey == K_LEFT
    snItem := 0
  endif
  snLastChoice := snItem
  snLastKey := nKey
  snItem  := nSaveItem
  saItems := aOldItems
  * sbBlock := bOldBlock
  setcursor(nCursor)
  RETURN snItem


FUNCTION SetRowPos(b,i)
* RETURN .f. if i > b:rowCount
#ifdef __XPP__
  b:forceStable()
#endif
b:rowPos := i
#ifdef __XPP__
  b:forceStable()
  b:refreshAll()
#else
  *b:forceStable()
  b:invalidate()
  b:configure()
  b:refreshCurrent()
  b:forceStable()
#endif
RETURN .t.


FUNCTION ItemCreate(b,bCreate)
local uItem
RETURN .f. if bCreate == NIL
if snItem > len(saItems)
  uItem := eval( bCreate, NIL )
else
  uItem := eval( bCreate, saItems[snItem] )
endif
RETURN .f. if uItem == NIL
aadd( saItems, uItem )
snItem := len( saItems )
RETURN .t.


**
** EvalItem() - code block for column object
**
* STATIC FUNCTION EvalItem
* RETURN str(snItem,3) + " " + eval( sbBlock, saItems[snItem] )
* RETURN eval( sbBlock, saItems[snItem] )

**
** :skipBlock
**
STATIC FUNCTION SkipItem( n, lMayAppend )
local i := n
if snItem + n < 1
  i := 1 - snItem
  snItem := 1
else
  if snItem + n > len(saItems)
    if lMayAppend
      i := len(saItems) - snItem + 1
      snItem := len(saItems) + 1
    else
      i := len(saItems) - snItem
      snItem := len(saItems)
    endif
  else
    snItem += n
  endif
endif
RETURN i

#endif

FUNCTION LastChoice ; RETURN snLastChoice
FUNCTION abLastKey ; RETURN snLastKey
// FUNCTION abUpdated ; RETURN slUpdated



