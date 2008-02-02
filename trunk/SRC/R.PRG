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

#include "TIM.CH"

static saGroups
static saTotals

#define GRP_XKEY     1
#define GRP_CURR     2
#define GRP_ONTOP    3
#define GRP_AFTER    4
#define GROUPS_ALEN     4

* FUNCTION r_new()
FUNCTION r_open()
local a := { saGroups, saTotals }
saGroups := {}
saTotals := {}
RETURN a


FUNCTION r_addGroup(xuKey,xuOnTop,xuAfter)
local a := array(GROUPS_ALEN)
default xuKey to {||recno()}
a[GRP_XKEY  ] := xuKey
a[GRP_CURR  ] := NIL
a[GRP_ONTOP ] := xuOnTop
a[GRP_AFTER ] := xuAfter
aadd(saGroups,a)
RETURN .t.


* FUNCTION r_exec
FUNCTION r_oneach(n,v)
local i,k,grp
for i := 1 to len(saGroups)
  grp := saGroups[i]
  k := eval(grp[GRP_XKEY],n,v)
  if grp[GRP_CURR] != k
    if grp[GRP_CURR] != NIL
      if grp[GRP_AFTER] != NIL
        RETURN .f. if ! eval(grp[GRP_AFTER],grp[GRP_CURR])
      endif
    endif
    grp[GRP_CURR] := k
    if grp[GRP_ONTOP] != NIL
      RETURN .f. if ! eval(grp[GRP_ONTOP],grp[GRP_CURR])
    endif
  endif
next i
RETURN .t.

FUNCTION r_flush()
local i,grp
for i := 1 to len(saGroups)
  grp := saGroups[i]
  if grp[GRP_CURR] != NIL
    if grp[GRP_AFTER] != NIL
      RETURN .f. if ! eval(grp[GRP_AFTER],grp[GRP_CURR])
    endif
  endif
next i
RETURN .t.

FUNCTION r_exec(a,nOrder,cStart,xlWhile,xlFilter,xlOnEach,;
  nMaxCount,lTaskInter,lDescend)
// modified copy of DbfScan()
local nCount := 0
local lOkay := .f.
default cStart to ""
default lTaskInter to .t.
* default lDescend to .f.
default xlFilter to {||.t.}
if valtype(xlFilter)=="C"
  xlFilter := cblock(xlFilter)
endif
if valtype(xlOnEach)=="C"
  xlOnEach := cblock(xlOnEach)
endif
begin sequence
  if ! AreaOpen( a, .f. ) ; break ; endif
  lOkay := .t.
  if nOrder != NIL
    ddSetOrder(nOrder,lDescend)
  endif
  if indexord() != 0
    dbsoftseek(cStart)
  else
    go top
  endif
  if len(cStart) == 0
    default xlWhile to ".t."
  else
    default xlWhile to "left(" + indexkey() + "," ;
            + ntrim(len(cStart)) + ")=='" + cStart + "'"
  endif
  do while ! eof() .and. &xlWhile
    if lTaskInter
      MsgDisp2(ntrim0(nCount * 100 / lastrec()) + "%")
      if TaskInter() ; lOkay := .f.; exit ; endif
    endif
    if xeval(xlFilter)
      nCount += 1
      if ! r_oneach(nCount)
        lOkay := .f.
        exit
      endif
      if ! xeval(xlOnEach)
        lOkay := .f.
        exit
      endif
    endif
    skip
    if nMaxCount != NIL .and. nCount > nMaxCount
      exit
    endif
  enddo
  if lOkay .and. ! r_flush()
    lOkay := .f.
  endif
  AreaClose()
end sequence
RETURN lOkay



FUNCTION r_forloop(u1,u2,uStep,xlFilter,xlOnEach,nMaxCount,lTaskInter)
local nCount := 0
local lOkay := .f.
local v := u1
default uStep to 1
default lTaskInter to .t.
default xlFilter to {||.t.}
do while v <= u2
  if lTaskInter
    MsgDisp2(ntrim0(nCount))
    if TaskInter() ; lOkay := .f.; exit ; endif
  endif
  if xeval(xlFilter,v)
    nCount += 1
    if ! r_oneach(nCount,v)
      lOkay := .f.
      exit
    endif
    if ! xeval(xlOnEach,nCount,v)
      lOkay := .f.
      exit
    endif
  endif
  v += uStep
  if nMaxCount != NIL .and. nCount > nMaxCount
    exit
  endif
enddo
if lOkay .and. ! r_flush()
  lOkay := .f.
endif
RETURN lOkay



* FUNCTION r_restore(a)
FUNCTION r_close(a)
saGroups := a[1]
saTotals := a[2]
RETURN .t.


* FUNCTION ActReport(cActFile, aArgs)
* local r := r_open()
* local lOkay := ActExec(cActFile,aArgs)
* r_close(r)
* RETURN lOkay





