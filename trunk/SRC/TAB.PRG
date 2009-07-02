** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2009 Luc Saffre
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

#define TF_WIDTH    1
#define TF_HEADER   2
#define TF_FORMAT   3
#define TF_TPL      4
#define TF_BUFFER   5
#define TF_LCOUNT   6
#define TF_MRGL     7
* #define TF_MINHEIGHT  7
#define TF_ALEN     8

#ifdef DEF_PRINT


**
** STATIC_SECTION global static variables
**
* static saTabBuffer := {}
static saTabCols   := {}
static snCurColumn := 0
static scTabAttr   := ""
static saTabStack  := {}
static snCpl := 0  // vorheriger cpl-Wert (nur nîtig zum automatischen
                   // Errechnen der "variablen Kolonnenbreite" p_TabBegin)
static scSeparator  := "≥ƒ≈"
static snCellHeight := 0
static snSpaceBetween := 1


**
** MSG_SECTION    MSGnnn definitions
**
* static MSG001 := "Fehler : "
static MSG_NOT_ACTIVE := " : no table is active !"

**
** PROCEDURE_SECTION  - (...grins)
**


**
** {tab define [ <cSep> ]}
** {tab define "≥ƒ+"}
** {tab define "|-+"}
**
FUNCTION p_TabDefine(cParam)
if ColCount() == 0 ; p_SetColumns("1") ; endif
// p_SetColumns("1")  [960610]
PushTable()
snCpl := t_cpl()
** set new table definition
* saTabBuffer := {}
saTabCols   := {}
snCurColumn := 0
scSeparator := OhneAnf(cParam)
* scTabAttr   := cParam
RETURN NIL

**
** {tab begin}
**
FUNCTION p_TabBegin()
local i
local nTotWidth := 0
local nCol := NIL
if len(saTabCols) == 0
  Warning("{tab begin} : no columns defined !")
  RETURN NIL
endif
**
** *eine* Kolonne darf width == 0 haben, das heisst dann "variable breite"
**
for i := 1 to len(saTabCols)
  if saTabCols[i][TF_WIDTH] == 0
    nCol := i
  else
    nTotWidth += saTabCols[i][TF_WIDTH]
  endif
  if i < len(saTabCols)
    nTotWidth += snSpaceBetween // len(scSeparator)
  endif
next i
if nCol != NIL
  saTabCols[nCol][TF_WIDTH] := snCpl - nTotWidth
endif
snCurColumn := 0
RETURN NIL

**
** {tab end}
**
FUNCTION p_TabEnd
RETURN NIL if len(saTabStack) == 0
* TabFlush() // normalerweise ist das hier nicht nîtig ...
p_SetColumns("off")
PopTable()
RETURN NIL

**
** {tab column <Format> <Header> <cTemplate>}
** z.B. {tab column R6 "Menge" "{vnl qt}"}
**
FUNCTION p_TabColumn(cParam)
local cAlign := ALIGN_LEFT + ALIGN_TOP
local nPos
local nWidth
local cHeader := ""
local cTpl := ""
local i := 1
local cMac
if (nPos := at("/if ",cParam)) != 0
  cMac := substr(cParam,nPos+4)
  RETURN NIL if ! (&cMac)
  cParam := trim(left(cParam,nPos-1))
endif
for i := 1 to len(cParam)
  if substr(cParam,i,1) $ "0123456789"
    cAlign := upper(left(cParam,i-1))
    cParam := substr(cParam,i)
    exit
  endif
next i
nPos := at(" ",cParam)
if nPos == 0
  nWidth := val(cParam)
else
  nWidth := val(left(cParam,nPos))
  cParam := substr(cParam,nPos+1)
  RETURN TplWarning() if (nPos := at('"',cParam)) == 0
  cParam := substr(cParam,nPos+1)
  RETURN TplWarning(cParam) if (nPos := at('"',cParam)) == 0
  cHeader := left(cParam,nPos-1)
  cParam := substr(cParam,nPos+1)
  RETURN TplWarning(cParam) if (nPos := at('"',cParam)) == 0
  cParam := substr(cParam,nPos+1)
  RETURN TplWarning(cParam) if (nPos := at('"',cParam)) == 0
  cTpl   := left(cParam,nPos-1)
endif
RETURN p_AddColumn(nWidth,cAlign,cHeader,cTpl)

FUNCTION p_AddColumn(nWidth,cAlign,cHeader,cTpl,bnLeftIndent)
local a := array(TF_ALEN)
default bnLeftIndent to {|| 0 }
a[TF_WIDTH]  := nWidth
a[TF_FORMAT] := cAlign
a[TF_HEADER] := cHeader
a[TF_TPL]    := cTpl
a[TF_BUFFER] := ""
a[TF_MRGL]   := bnLeftIndent
aadd(saTabCols,a)
* aadd(saTabBuffer,"")
* 20021111 RETURN NIL
RETURN .t.


**
** TabStream() fÑngt in PrnStream() den Stream ab, falls eine Tabelle
** aktiv ist.
** Merke auch : TabStream() hat keinerlei Macht Åber PrintLine()
**
FUNCTION TabStream(cStream)
RETURN .f. if snCurColumn == 0        // no table active
saTabCols[snCurColumn][TF_BUFFER] += cStream
RETURN .t.

**
** {tab exec}
**
FUNCTION p_TabExec()
local cAlign := p_Align()
PrnFlush()
RETURN TplWarning(MSG_NOT_ACTIVE) if len(saTabCols) == 0
for snCurColumn := 1 to len(saTabCols)
  p_Align(saTabCols[snCurColumn][TF_FORMAT])
  TplParse( saTabCols[snCurColumn][TF_TPL] )
  PrnFlush()
next snCurColumn
snCurColumn := 0
TabFlush()
p_Align(cAlign)
RETURN .t.

**
** TabFlush()
** entleert den TabBuffer nach PrnStream(). Dazu mÅssen die Kolonnen
** in ihre einzelnen Zeilen zerlegt werden.
** Diese werden natÅrlich nicht in den ganz normalen PrnStream()
** reingeschickt, denn sonst wÅrden sie ja erneut von der
** Tabelle abgefangen...
**
FUNCTION TabFlush()
local nPos
local i
local cLine
local cSubLine
local lFound := .t.
* local aTabBuffer := saTabBuffer
local aTabCols   := saTabCols
local cTabAttr   := scTabAttr
local cSeparator := scSeparator
local cAlign     := p_Align()
local nHeight    := 0
local nCurColumn := snCurColumn
* local nCurColumn
* if ! RtfMode()
  for i := 1 to len(saTabCols)
    ms_wrap(saTabCols[i])
    nHeight := max(saTabCols[i][TF_LCOUNT],nHeight)
  next i
  * for i := 1 to len(saTabCols)
  * next i
  if snCellHeight != 0
    nHeight := snCellHeight
  endif
  for i := 1 to len(saTabCols)
    do while saTabCols[i][TF_LCOUNT] < nHeight
      if ALIGN_BOTTOM $ saTabCols[i][TF_FORMAT]
        saTabCols[i][TF_BUFFER] := CR_LF + saTabCols[i][TF_BUFFER]
      else
        saTabCols[i][TF_BUFFER] := saTabCols[i][TF_BUFFER] + CR_LF
      endif
      saTabCols[i][TF_LCOUNT] ++
    enddo
  next i
* endif
do while lFound // solange in mindestens einer Kolonne noch was drin war
  lFound := .f.
  cLine := ""
  for i := 1 to len(saTabCols)
    nPos := at(CR_LF,saTabCols[i][TF_BUFFER])
    cSubLine := space(eval(saTabCols[i][TF_MRGL]))
    if nPos == 0
      if len(saTabCols[i][TF_BUFFER]) > 0
        cSubLine += saTabCols[i][TF_BUFFER]
        saTabCols[i][TF_BUFFER] := ""
        lFound := .t.
      * else
      *   cSubLine := "" // space(saTabCols[i][TF_WIDTH])
      endif
    else
      cSubLine += left(saTabCols[i][TF_BUFFER],nPos-1)
      saTabCols[i][TF_BUFFER] := substr(saTabCols[i][TF_BUFFER],nPos+2)
      lFound := .t.
    endif
    cSubLine := padr(cSubLine,saTabCols[i][TF_WIDTH])
    cLine += cSubLine
    if i < len(saTabCols)
      cLine += padc(left(scSeparator,1),snSpaceBetween)
    endif
  next i
  if lFound
    * PopTable()
    * PrnStream(cLine + CR_LF)
    * PushTable()
    PrintLine(cLine)
    saTabCols   := aTabCols
    scTabAttr   := cTabAttr
    scSeparator := cSeparator
    snCurColumn := nCurColumn
    p_Align(cAlign)
  endif
enddo
* snCurColumn := 0 // warum hatte ich das vorher rauskommentiert...?
RETURN NIL

**
** TabHeader()
**
FUNCTION TabHeader()
local nPos
local i
local cLine
local cSubLine
local lFound := .t.
local aHdrBuffer := {}
local aLines := {}
local nExtra
RETURN aLines if len(saTabCols) == 0
for i := 1 to len(saTabCols)
  cLine := strtran(saTabCols[i][TF_HEADER],";",CR_LF)
  aadd(aHdrBuffer,cLine)
next i
do while lFound // solange in mindestens einer Kolonne noch was drin war
  lFound := .f.
  cLine := ""
  for i := 1 to len(aHdrBuffer)
    nPos := at(CR_LF,aHdrBuffer[i])
    if nPos == 0
      if len(aHdrBuffer[i]) > 0
        cSubLine := aHdrBuffer[i]
        aHdrBuffer[i] := ""
        lFound := .t.
      else
        cSubLine := ""
      endif
    else
      cSubLine := left(aHdrBuffer[i],nPos-1)
      aHdrBuffer[i] := substr(aHdrBuffer[i],nPos+2)
      lFound := .t.
    endif
    nExtra := len(cSubline) - len(TextUnFormat(cSubLine))
    if ALIGN_RIGHT $ saTabCols[i][TF_FORMAT]
      cSubLine := padl(cSubLine,saTabCols[i][TF_WIDTH] + nExtra)
    else
      cSubLine := padr(cSubLine,saTabCols[i][TF_WIDTH] + nExtra)
    endif
    cLine += cSubLine
    if i < len(aHdrBuffer)
      cLine += padc(left(scSeparator,1),snSpaceBetween)
    endif
  next i
  if lFound
    aadd(aLines,padr(cLine,p_cpl()))
  endif
enddo
RETURN aLines if len(aLines) == 0
cLine := ""
for i := 1 to len(saTabCols)
  cLine += repl(substr(scSeparator,2,1),saTabCols[i][TF_WIDTH])
  if i < len(saTabCols)
    cLine += padc( ;
      substr(scSeparator,3,1),snSpaceBetween, ;
      substr(scSeparator,2,1) ;
    )
  endif
next i
* if empty(cLine)
*   aadd(aLines,"")
* else
  aadd(aLines,padr(cLine,p_cpl()))
* endif
RETURN aLines

**
** PushTable() - save current table definition to stack
**
FUNCTION PushTable()
aadd( saTabStack, ;
      { ;
        saTabCols, ;
        scTabAttr, ;
        p_Align(), ;
        scSeparator, ;
        snCpl, ;
        snCurColumn ;
      } )
RETURN NIL


**
** PopTable() - restore last table definition from stack
**
FUNCTION PopTable()
saTabCols   := atail(saTabStack)[1]
scTabAttr   := atail(saTabStack)[2]
p_Align(atail(saTabStack)[3])
scSeparator := atail(saTabStack)[4]
snCpl       := atail(saTabStack)[5]
snCurColumn := atail(saTabStack)[6]
asize(saTabStack,len(saTabStack)-1)
RETURN NIL

**
** t_cpl() - chars per line (inside a table)
**
FUNCTION t_cpl()
RETURN p_cpl() if snCurColumn == 0
RETURN saTabCols[snCurColumn][TF_WIDTH]
* RETURN snCpl
** RETURN saTabCols[snCurColumn][TF_WIDTH]

*FUNCTION TabLIndent()
*local i
*local nIndent := 0
** RETURN 0 if snCurColumn == 0
*for i := 1 to snCurColumn - 1
*  nIndent += saTabCols[i][TF_WIDTH]
*next i
*RETURN nIndent
*
*FUNCTION TabRIndent()
*local i
*local nIndent := 0
*RETURN 0 if snCurColumn == 0
*for i := len(saTabCols) to snCurColumn + 1 step -1
*  nIndent += saTabCols[i][TF_WIDTH]
*next i
*RETURN nIndent


#else

* FUNCTION t_cpl() ; RETURN p_cpl()
FUNCTION TabStream() ; RETURN .f.

#endif DEF_PRINT



FUNCTION ms_wrap(ms)
local nPos
local nPos2
* local nLen
* local nPad
local i
local cStream := ""
local nLineCount := 0 // 960708 (vorher 1)
local nWidth := ms[TF_WIDTH] - eval(ms[TF_MRGL])
local cBuffer := TextUnformat(ms[TF_BUFFER])
do while len(cBuffer) > 0
  if (nPos := at(CR_LF,cBuffer)) == 0
    nPos := len(cBuffer) + 1
  endif
  if nPos - 1 <= nWidth // ms[TF_WIDTH]
    nPos2 := nPos + 2
    cStream += left(cBuffer,nPos+1)
  else
    // donc nPos > nWidth
    // nPos2 := nPos + 1
    for i := nWidth to 1 step -1
      if substr(cBuffer,i,1) == " "
        nPos := i
        nPos2 := i+1
        exit
      elseif substr(cBuffer,i,1) == "-" ;
             .and. substr(cBuffer,i+1,1) != "-"
        nPos  := i+1
        nPos2 := i+1
        exit
      endif
    next i
    if nPos > nWidth
      nPos := nWidth + 1
      nPos2 := nPos
    endif
    cStream += left(cBuffer,nPos-1) + CR_LF
  endif
  nLineCount += 1
  cBuffer := substr(cBuffer,nPos2)
enddo
ms[TF_BUFFER] := cStream
ms[TF_LCOUNT] := nLineCount // mlcount(cStream,250)
RETURN NIL


/*** before 20090702

FUNCTION ms_wrap(ms)
local nPos
local nPos2
* local nLen
* local nPad
local i
local cStream := ""
local nLineCount := 0 // 960708 (vorher 1)
local nWidth := ms[TF_WIDTH] - eval(ms[TF_MRGL])
ms[TF_BUFFER] := TextUnformat(ms[TF_BUFFER])
do while len(ms[TF_BUFFER]) > 0
  if (nPos := at(CR_LF,ms[TF_BUFFER])) == 0
    nPos := len(ms[TF_BUFFER]) + 1
  endif
  if nPos - 1 <= nWidth // ms[TF_WIDTH]
    nPos2 := nPos + 2
    cStream += left(ms[TF_BUFFER],nPos+1)
    nLineCount ++     // neu 960708
  else
    nPos2 := nPos + 1
    for i := nWidth to 1 step -1
      if substr(ms[TF_BUFFER],i,1) == " "
        nPos := i
        nPos2 := i+1
        exit
      elseif substr(ms[TF_BUFFER],i,1) == "-" ;
             .and. substr(ms[TF_BUFFER],i+1,1) != "-"
        nPos  := i+1
        nPos2 := i+1
        exit
      endif
    next i
    if nPos > nWidth
      nPos := nWidth
    endif
    cStream += left(ms[TF_BUFFER],nPos-1) + CR_LF
    nLineCount ++
  endif
  ms[TF_BUFFER] := substr(ms[TF_BUFFER],nPos2)
enddo
ms[TF_BUFFER] := cStream
ms[TF_LCOUNT] := nLineCount // mlcount(cStream,250)
RETURN NIL

***/

FUNCTION p_TabHeight(n)
snCellHeight := n
RETURN NIL

FUNCTION p_TabSpace(n)
snSpaceBetween := n
RETURN NIL

