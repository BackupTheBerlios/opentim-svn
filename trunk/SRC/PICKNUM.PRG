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

**
** PickNum() - der kleine feine Taschenrechner
**
FUNCTION PickNum(cStart,nRow,nCol)
local cExpr
local cNewExpr := cStart
local nResult
local nDec
static scStart
default scStart to space(10)
default cStart to scStart
default nRow to int(maxrow() / 2)
default nCol to int(maxcol() / 2)
cExpr := cStart
if nCol < maxcol() / 2
  nCol += 12
else
  nCol -= 34
endif
if nRow < maxrow() / 2
  nRow += 1
else
  nRow -= 3
endif
if nCol + 46 > maxcol() ; nCol := maxcol() - 46 ; endif
if nRow + 5 > maxrow() ; nRow := maxrow() - 5 ; endif
if nCol < 1 ; nCol := 1 ; endif
if nRow < 1 ; nRow := 1 ; endif
open window "Calculator" size 3,44 home nRow,nCol
do while cNewExpr != NIL
  cExpr := padr(ltrim(cExpr),40)
  WinHome()
  @ row(), col() get cExpr
  nKey := ReadScr()
  cExpr := alltrim(cExpr)
  if nKey == K_ENTER
    if type(cExpr) == "N"
      nResult  := &cExpr
      * nDec := max(nMinDec,MontDecPos(cExpr))
      nDec := 0
      do while nDec < 6
        if round(nResult * (10 ** nDec),0) == int(nResult * (10 ** nDec))
          exit
        else
          nDec++
        endif
      enddo
      cNewExpr := ltrim(str(nResult,20,nDec))
      if "." $ cNewExpr
        do while right(cNewExpr,1) == "0"
          cNewExpr := " " + left(cNewExpr,len(cNewExpr)-1)
        enddo
        if right(cNewExpr,1) == "."
          cNewExpr := " " + left(cNewExpr,len(cNewExpr)-1)
        endif
      enddo
      if val(cNewExpr) == val(cExpr)
        cNewExpr := padl(cExpr,len(cStart))
        exit
      else
        cExpr := cNewExpr
      endif
    else
      SetMsg(cExpr + " : Syntax error.")
      loop
    endif
  elseif nKey == K_F10
    exit
  elseif nKey == K_ESC
    cNewExpr := NIL
  else
    Alarm()
  endif
enddo
close window
RETURN cNewExpr
