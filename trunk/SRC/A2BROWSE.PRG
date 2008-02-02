** a2browse.prg : Browse an 2D-array using a specified code block
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

#ifdef DEF_A2BROWSE

static snLine  := 1
static saItems := NIL
static snColWidth := 3
* static scNil := NIL
* static sbBlock := NIL
* static scPosit := ""
static soBrowse

*FUNCTION a2test
*local aMatrix := {}
*local a
*local i,j
*for i := 1 to 11
*  aadd(aMatrix,{})
*  for j := 1 to 13
*    a := atail(aMatrix)
*    aadd( a, padl(ntrim(i)+","+ntrim(j),5) )
*  next j
*next i
*RETURN a2Browse(aMatrix,NIL,NIL,"test")
*
*FUNCTION a2test2
*RETURN a2browse( ;
*  Dbf2Array( ;
*    {oVna()}, ;
*    6, ;
*    dtos(DlgValue("iDate1"))+DlgValue("iTime1"), ;
*    "dtos(VNA->Date2)+VNA->Time2<='" + ;
*      dtos(DlgValue("iDate2"))+DlgValue("iTime2")+"'", ;
*    ".t.", ;
*    "val(VNA->Nr)", ;
*    "VNA->Date-DlgValue('iDate1')+1", ;
*    "VNA->IdDoc+' '+VNA->IdArt" ;
*  ), ;
*  {|i|dtoc(DlgValue("iDate1")+i-1)}, ;
*  {|i|padl("["+ntrim(a2line())+"]",5)}, ;
*  "Reservierungen ab " + dtoc(DlgValue("iDate1")), ;
*  8 ;
*)


FUNCTION Dbf2Array( ;
  aTables,nOrder, ;
  cStart,xlWhile,xlFilter, ;
  xnLine,xnColumn,xaText ;
)
local a := {}
local lOkay := .f.
local nCount := 0
default nOrder to 1
default xlFilter to ".t."
default xlWhile to ".t."
default cStart to ""
begin sequence
  * PushSequence()
  if ! AreaOpen( aTables, .f. ) ; break ; endif
  lOkay := .t.
  ddSetOrder(nOrder)
  softseek cStart
  do while ! eof() .and. xparse(xlWhile)
    MsgDisp2(ntrim0(nCount++ * 100 / lastrec()) + "%")
    if TaskInter() ; lOkay := .f.; exit ; endif
    if xparse(xlFilter)
      if ! a2collect(a, ;
        xparse(xnLine),xparse(xnColumn),xparse(xaText) ;
      )
        lOkay := .f.
        exit
      endif
    endif
    skip
  enddo
  AreaClose()
end sequence
* popSequence()
RETURN {} if ! lOkay
RETURN a


**
** nCol ist immer bekannt. nLine kann auch empty() sein und dann wird
** die erste freie Zeile genommen.
**
FUNCTION a2collect(a,nLine,nCol,aText)
local lFrei
local i,j,k
local nColCount := len(a)
local nLineCount := 0
local nColSpan := len(aText)
default nColSpan to 0
if nColCount > 0
  nLineCount := len(a[1])
endif
if nCol + nColSpan > nColCount
  for i := nColCount + 1 to nCol + nColSpan
    aadd(a, array(nLineCount))
  next i
  nColCount := nCol + nColSpan
endif
if empty(nLine)  // erste freie Zeile suchen
  for i := 1 to nLineCount
    lFrei := .t.
    for k := nCol to nCol + nColSpan
      if a[k][i] != NIL
        lFrei := .f.
      endif
    next k
    if lFrei
      for k := nCol to nCol + nColSpan - 1
        a[k][i] := aText[k-nCol+1]
      next k
      RETURN .t.
    endif
  next i
  nLine := nLineCount + 1
endif
if nLine > nLineCount
  for i := nLineCount + 1 to nLine
    for j := 1 to nColCount
      aadd(a[j],NIL)
    next j
  next i
endif
for k := nCol to nCol + nColSpan - 1
  a[k][nLine] := aText[k-nCol+1]
next k
RETURN .t.


**
** a2Browse()
**
FUNCTION a2Browse( aItems, ;
                   bcColHeader, ;
                   bcRowHeader, ;
                   cTitle,                    ;
                   nColWidth, ; // cNil, ;
                   nRow, nCol, nWidth, nHeight , ;
                   nItem , lArrange, ;
                   aActions, ;
                   bIdle, ;
                   bPosit ;
)
local cMac
local uItem
local column
local nSaveItem := snLine
local aOldItems := saItems
* local bOldBlock := sbBlock
local i
local nCursor
RETURN Warning("Keine Daten zum Anzeigen") if len(aItems) == 0
saItems := aItems
default cTitle to ""
default nColWidth to 3 // cNil to "NIL"
default bcColHeader to {|i|"["+ntrim(i)+"]"}
* default bcRowHeader to {|i|"["+ntrim(snLine)+"]"}
snColWidth := nColWidth
* scNIL := cNil
nCursor := setcursor(SC_NONE)
default nItem to 1
if nItem <= 0
  nItem := 1
endif
default lArrange to .T.
snLine  := nItem
* sbBlock := bBlock
open window (cTitle) size nHeight, nWidth ;
                     home nRow,nCol
soBrowse := TBrowseNew() // row(), col(), WinEndY()-3, WinEndX() )
ddWinAdapt(soBrowse)
* soBrowse:headSep := "ƒ"
soBrowse:headSep := "¬ƒ"
* soBrowse:colSep  := "≥"
soBrowse:colSep  := " "
if bcRowHeader != NIL
  soBrowse:addColumn(TBcolumnNew( space(4), bcRowHeader ))
endif
for i := 1 to len(saItems)
  cMac := "a2item(" + ntrim(i) + ")"
  column := TBcolumnNew( eval(bcColHeader,i), cblock(cMac) )
  soBrowse:addColumn(column)
next i
soBrowse:skipBlock     := {|n| SkipItem(n) }
soBrowse:goBottomBlock := {|| snLine := len(saItems[1]) }
soBrowse:goTopBlock    := {|| snLine := 1 }
if nItem > 1
  soBrowse:rowPos := nItem
  if soBrowse:rowPos > nHeight - 2
    soBrowse:rowPos := nHeight - 2
  endif
  soBrowse:configure()
endif
SayLeg("[Esc] Beenden |")
do while .t.
  raise("a2browse : DEF_OSLIB not implemented")
  dispbegin()
  do while ( ! soBrowse:stabilize() )
    if ( nKey := inkey() ) != 0
      exit
    endif
  enddo
  dispend()
  SaySta("["+ntrim(snLine)+","+ntrim(soBrowse:colPos)+"]")
  if soBrowse:stable
    if bIdle != NIL
      eval(bIdle, soBrowse:colPos)
    endif
    nKey := WaitKeySet()
  endif
  if aActions != NIL
    for i := 1 to len(aActions)
      if aActions[i][1] == nKey
        if snLine > len(saItems[1])
          nKey := eval(aActions[i][2],NIL)
        else
          nKey := eval(aActions[i][2])
        endif
        soBrowse:refreshCurrent()
        exit
      endif
    next i
    if nKey == NIL // lFound
      loop
    endif
  endif
  * if nKey < 32 .or. nKey >= 256  // anti-condition siehe unten
  *   scPosit := ""
  * endif
  if nKey == K_ESC       ;  exit
  elseif nKey == K_F10       ;  exit
  elseif nKey == K_ALT_F5
    soBrowse:refreshAll()
  elseif nKey == K_DOWN
    if snLine < len(saItems[1])
      soBrowse:down()
    endif
  elseif nKey == K_UP
    if snLine > 1
      soBrowse:up()
    endif
  #ifdef __XPP__
  elseif nKey == K_END         ; soBrowse:_end()
  #else
  elseif nKey == K_END         ; soBrowse:end()
  #endif
  elseif nKey == K_HOME        ; soBrowse:home()
  elseif nKey == K_CTRL_HOME   ; soBrowse:panHome()
  elseif nKey == K_CTRL_END    ; soBrowse:panEnd()
  elseif nKey == K_CTRL_LEFT   ; soBrowse:panLeft()
  elseif nKey == K_CTRL_RIGHT  ; soBrowse:panRight()
  elseif nKey == K_RIGHT     ; soBrowse:right()
  elseif nKey == K_LEFT      ; soBrowse:left()
  elseif nKey == K_PGDN      ; soBrowse:pageDown()
  elseif nKey == K_PGUP      ; soBrowse:pageUp()
  elseif nKey == K_CTRL_PGDN ; soBrowse:goBottom()
  elseif nKey == K_CTRL_PGUP ; soBrowse:goTop()
  * elseif nKey == K_BS .and. ! empty(scPosit)
  *   scPosit := left(scPosit,len(scPosit)-1)
  *   SetMsg("Positionieren : " + scPosit)
  *elseif nKey == K_ALT_UP .and. lArrange
  *  if snLine > 1
  *    uItem := saItems[soBrowse:colPos][snLine]
  *    adel(saItems,snLine)
  *    ains( saItems,snLine - 1 )
  *    saItems[snLine - 1] := uItem
  *    soBrowse:up()
  *    soBrowse:refreshAll()
  *    soBrowse:forceStable()
  *  endif
  *elseif nKey == K_ALT_DOWN .and. lArrange
  *  if snLine < len(saItems)
  *    uItem := saItems[snLine]
  *    adel(saItems,snLine)
  *    snLine++
  *    ains(saItems,snLine)
  *    saItems[snLine] := uItem
  *    soBrowse:refreshAll()
  *    soBrowse:forceStable()
  *  endif
  *elseif nKey >= 32 .and. nKey < 256 // anti-condition siehe oben
  *  if snLine <= len(saItems)
  *    **
  *    ** Positionier-Modus geht davon aus, dass das array alpabetisch
  *    ** sortiert ist.
  *    scPosit += upper(chr(nKey))
  *    SetMsg("Positionieren : " + scPosit)
  *    if bPosit == NIL
  *      for i := 1 to len(saItems)
  *        if upper(left(eval(bBlock,saItems[i]),len(scPosit))) == scPosit
  *          exit
  *        endif
  *      next i
  *    else
  *      i := eval(bPosit,saItems,scPosit)
  *    endif
  *    if i > 0 .and. i != snLine .and. i <= len(saItems)
  *      snLine := i
  *      soBrowse:rowPos := i
  *      soBrowse:invalidate()
  *      soBrowse:configure()
  *      soBrowse:refreshCurrent()
  *      do while ( ! soBrowse:stabilize() ) ; enddo
  *    endif
  *  endif
  endif
enddo
close window
if nKey == K_ESC
  snLine := 0
endif
snLine  := nSaveItem
saItems := aOldItems
* sbBlock := bOldBlock
setcursor(nCursor)
RETURN .t. // snLine

FUNCTION a2line
RETURN snLine


FUNCTION a2item(nCol)
RETURN space(snColWidth) if snLine > len(saItems[1]) // pseudorecord
RETURN space(snColWidth) if saItems[nCol][snLine] == NIL
RETURN saItems[nCol][snLine]

**
** SkipItem() - soBrowse:skipBlock
**
STATIC FUNCTION SkipItem( n, lMayAppend )
local i := n
if snLine + n < 1
  i := 1 - snLine
  snLine := 1
else
  if snLine + n > len(saItems[1])
    i := len(saItems[1]) - snLine
    snLine := len(saItems[1])
  else
    snLine += n
  endif
endif
RETURN i

* FUNCTION a2block()
* local p := soBrowse:colPos
* local i := saItems[snLine][soBrowse:colPos]
* RETURN eval(sbBlock,i)


#endif DEF_A2BROWSE

**
**  ListAsArray( <cList>, <cDelimiter> ) --> aList
**  Convert a delimited string to an array
**
** [971124] neuer Parameter bBlock fÅr ListAsArray().
** ListAsArray(cLine,";",{|x|val(x)}) liest die Werte als Zahlen, nicht
** als Strings.
FUNCTION ListAsArray( cList, cDelimiter, bBlock) // nMaxLen )
LOCAL nPos
LOCAL aList := {}                            // Define an empty array
* default cDelimiter to ","
default bBlock to {|x|x}
do while (nPos := at(cDelimiter, cList)) != 0
  * if nMaxLen != NIL
  *   if len(aList) == nMaxLen
  *     exit
  *   endif
  * endif
  * aadd(aList, alltrim(substr(cList, 1, nPos - 1)))   // Add a new element
  aadd(aList, eval(bBlock,substr(cList, 1, nPos - 1)))   // Add a new element
  cList := substr(cList, nPos + 1)
enddo
aadd(aList, eval(bBlock,alltrim(cList)))     // Add final element
RETURN aList                                 // Return the array


FUNCTION ctoa(cText,nItems,nWidth)
local i
local a := {}
cText := padc(cText,nItems*nWidth,"-")
for i := 1 to nItems
  aadd(a, substr(cText,1+(i-1)*nWidth,nWidth))
next i
RETURN a
