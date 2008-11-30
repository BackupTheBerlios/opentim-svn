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

static saRecStack := {}

* static saBuf := NIL

**
** CopyRec() - Copies the current record to a buffer array.
**             Returns pointer to this array.
**             The previous buffer contents is lost, except if the calling
**             module retained it.
**
FUNCTION CopyRec(cAlias)
local i, cName
local aBuf
RETURN {} if eof()
default cAlias to "FIELD"
aBuf := array(fcount())
for i = 1 to fcount()
  cName := cAlias + "->" + fieldname(i)
  aBuf[i] := &cName
next i
RETURN aBuf


**
** PasteRec() - Copies the contents of buffer array to current record.
**              If aBuf is not specified, the static buffer is used.
**            ! The buffer must have the same structure as the current record !
**              Exceptions :
**              The record can contain more fields than the buffer
**              These additional fields will not be affected.
**
FUNCTION PasteRec( aBuf, aFldList )
local i, cName
RETURN .f. if len(aBuf) > fcount()
for i = 1 to len(aBuf)
  cName := fieldname(i)
  if aFldList == NIL .or. ascan(aFldList,cName) != 0
    FIELD->&cName := aBuf[i]
  endif
next i
RETURN .t.



#ifdef DEF_CONSOLE

FUNCTION RecConsole(aBuf)
local i, cName
local lFound := .f.
local cMsg := alias() + "(" + ntrim(recno()) + ") modified :"
for i = 1 to fcount()
  cName := fieldname(i)
  if FIELD->&cName != aBuf[i]
    cMsg += CR_LF + space(25) + padr(cName ,10) + " : "
    cMsg += trim(padr(aBuf[i],30)) + " -> "
    cMsg += trim(padr(FIELD->&cName,30))
    lFound := .t.
  endif
next i
RETURN .t. if ! lFound
RETURN LogConsole(cMsg)

#endif DEF_CONSOLE

**
** RecCompare() - Compares the current record with buffer contents.
** Returns .t. if every field is equal.
** You must have called CopyRec() before calling RecCompare().
**
FUNCTION RecCompare( aBuf )
local i
local cName
for i := 1 to fcount()
  cName := fieldname(i)
  RETURN .f. if aBuf[i] != FIELD->&cName
next i
RETURN .t.

FUNCTION RecStack() ; RETURN saRecStack

FUNCTION PushRec()
aadd(saRecStack, { alias(), CopyRec() })
SetMsg(ntrim(len(saRecStack))+" on stack")
RETURN SetMnuDone()

FUNCTION PopRec()
local a
*local aPopTable
RETURN !SetMsg("record stack is empty!") if len(saRecStack) ==0
// RETURN .f. if ! Confirm("Paste Record from Stack",MsgSure())
a := atail(saRecStack)
* RETURN .f. if ! ddRecLock()
if alias() == a[1]
  PasteRec(a[2])
else
  * aPopTable := saPopTable
  * saPopTable := GetTable(a[2])
  if ! ActExec(a[1]+"2"+alias(),a[2])
    Warning(SetMsg())
  endif
  *saPopTable := aPopTable
endif
* unlock record
asize(saRecStack,len(saRecStack)-1)
SetMsg(ntrim(len(saRecStack))+" on stack")
RETURN SetMnuDone()

FUNCTION PopField(cName)
local a := atail(saRecStack)
local oTable := GetTable(a[1])
local i
local n := 0
local ag
for i := 1 to len(oTable[AD_FIELDS])
  ag := oTable[AD_FIELDS][i]
  if ! FLDATTR_H $ ag[AG_ATTRIB] .and. ! FLDATTR_V $ ag[AG_ATTRIB]
    n += 1
    RETURN a[2][n] if ag[AG_NAME] == cName
  endif
next i
SetMsg(cName+" : no such field in " + oTable[AD_NAME])
RETURN NIL

FUNCTION GetTable(cAlias)
local x := "o"+cAlias+"()"
RETURN xparse(x)

