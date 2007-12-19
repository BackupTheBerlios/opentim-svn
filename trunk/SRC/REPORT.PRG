** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2007 Luc Saffre
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


#include "lib.ch"

#ifdef DEF_REPORT

#define RPT_AREA      1
#define RPT_ORDER     2
#define RPT_START     3
#define RPT_WHILE     4
#define RPT_FILTER    5
#define RPT_GROUPS    6
#define RPT_COLUMNS   7
#define RPT_TOTALS    8
#define RPT_INDEX     9
#define RPT_ONEACH   10
#define RPT_HDR1     11
#define RPT_HDR2     12
#define RPT_HDR3     13
#define RPT_DETAIL   14
#define RPT_VALRECORD     15
#define RPT_TEXTWIDTH    16
#define RPT_TEXTCOLUMNS  17
#define RPT_NOVALUE      18
#define RPT_BEFORE       19
#define RPT_AFTER        20
#define RPT_COLSEP       21 // column separator
#define RPT_ROWSEP       22 // row separator
#define RPT_PRETTL      23
#define RPT_POSTTTL     24
#define RPT_PRINTLINE   25
#define RPT_HEADER      26
#define RPT_TOCSV       27
#define RPT_RECNOS      28
#define RPT_FORLOOP     29
#define RPT_ALEN        29


#define GRP_KEY        1
#define GRP_STOP       2
#define GRP_COUNT      3 // Anzahl der verarbeiteten Records
#define GRP_KEYVALUE   4
#define GRP_TEXT       5
#define GRP_VALUES     6
#define GRP_WHEN       7
// GRP_WHEN : ob mich irgendwelche Total dieser Gruppe mîglicherweise
// interessieren. Wenn GRP_WHEN nein sagt, werden die Totale erst gar
// nicht nach ihrer Meinung gefragt.

#define GRP_ALIGN      8
**
#define GRP_HEADER     9
** Wird ausgefÅhrt, bevor der erste Record *verarbeitet* wird
** (unabhÑngig davon, ob dieser Record gedruckt wird oder nicht)
**
#define GRP_DTLCOUNT  10 // Anzahl der effektiv ausgedruckten Records
**
#define GRP_BEFORE    11
** GRP_BEFORE wird ausgefÅhrt, bevor der erste Record *gedruckt* wird.
** Oder, wenn kein einziger Record gedruckt wird, vor dem ersten Total,
** das gedruckt wird.
**
#define GRP_AFTER     12
** Wird ausgefÅhrt, bevor das erste TOTAL der Gruppe gedruckt wird.
** Kriegt 2 Parameter mit : GRP_COUNT und GRP_DTLCOUNT
** Muss .t. oder .f. zurÅck geben.
** Wenn .f., dann werden die TOTALs nicht gedruckt.

#define GRP_DONE      13
** array of booleans indicating whether the total has been printed

#define GRP_TTLCOUNT  14 // array of record counts per total
#define GRP_FORMAT    15
  #define FORMAT_BOLD   "B"

#define GRP_AFTERTTL  16

// 20050621 mit afterTotals {||PrintLine()} kann man angeben, dass nach
// den Totals der Gruppe eine Leerzeile kommt.

#define GRP_ALEN      16

#define CLN_HEADER 1
#define CLN_WIDTH  2
#define CLN_WHEN   3 // xl die Bedingung
#define CLN_VALUE  4 // xn (ggf. der Wert, der summiert wird)
#define CLN_TEXT   5 // xc (der Text, der gedruckt wird)
#define CLN_XSUM   6
#define CLN_TYPE   7
#define CLN_DECPOS 8 // used when TYPE is N
#define CLN_ALEN   8 //

#define TTL_WHEN   1 // Ob das Total ausgedruckt wird
#define TTL_TEXT   2 // Die "öberschrift" des Totals
#define TTL_FOR    3 // Welche Records in diesem Total summiert werden
#define TTL_AFTER  4 // Wird nach Ausdruck des Totals ausgefÅhrt
#define TTL_ALEN   4 //

#define NDX_ON   1 //
#define NDX_FOR    2 //
#define NDX_NAME   3 //
#define NDX_ALEN   3 //

static rpt
static snRecCount
static snRow
static suForValue

static snTtlCurrent
static snGrpCurrent
static snClnCurrent := 0

 
FUNCTION RepPrint(cIdRep,cIdDlg,cTitle,cTplIni,cPreview)
local cOutFile := "TMP.CSV"
local rptSave := rpt
local lOkay := .t.
local fd
if cTitle != NIL
  SetDlgTitle(cTitle)
endif
if cPreview != NIL
  SetPreview(cPreview)
endif
default cTplIni to "LISTE"
if cTplIni != NIL
  SetTplIni(cTplIni)
endif
if cIdDlg != NIL
  RETURN .f. if ! DlgExec(cIdDlg)
endif
if (rpt := RptLoad(cIdRep)) == NIL
  rpt := rptSave
  RETURN .f.
endif
if rpt[RPT_TOCSV]
  if (fd := fcreate(cOutFile)) == -1
    RETURN !SetMsg(cOutFile+MsgDosError(doserror()))
  endif
  rpt[RPT_PRINTLINE] := {|cLine|fwrite(fd,dos2latin1(cLine)+CR_LF),.t.}
else
  RETURN .f. if ! OpenPrinter(SetTplIni(),SetPreview(),;
    NIL,NIL,NIL,NIL,NIL,NIL,SetAsPdf(),SetAsMail())
endif
// rpt[RPT_TOCSV] := (getvar("ToCSV")==BUTTON_ON)
lOkay := _Report(cTitle==NIL)
if rpt[RPT_TOCSV]
  fclose(fd)
  if lOkay
    AppShell("excel.bat " + cOutFile)
  endif
else
  PrnFlush()
  close printer
  if LstError() != PRN_DONE
    lOkay := .f.
  elseif p_curpage() == 0
    #ifdef LG_GERMAN
      Warning("Nichts zu drucken.")
    #endif
    #ifdef LG_FRENCH
      Warning("Rien Ö imprimer.")
    #endif
    #ifdef LG_EN
      Warning("Nothing to print.")
    #endif
  endif
endif
rpt := rptSave
RETURN lOkay

FUNCTION RepExec(cIdRep,cIdDlg,cTitle)
local rptSave := rpt
local lOkay
if cIdDlg != NIL
  if cTitle != NIL
    SetDlgTitle(cTitle)
  endif
  RETURN .f. if ! DlgExec(cIdDlg)
endif
if (rpt := RptLoad(cIdRep)) == NIL
  rpt := rptSave
  RETURN .f.
endif
// Confirm(utos(rpt[RPT_AREA]))
lOkay := _Report(cTitle==NIL)
rpt := rptSave
RETURN lOkay

FUNCTION rptgoto(aRecnos,n)
* if len(aRecnos) == 0 .or.
if n > len(aRecnos)
  goto lastrec() + 1
  snRow := 0
else
  goto aRecnos[n]
  snRow := n
endif
RETURN .t.



**
**
STATIC FUNCTION _Report(lEmbedded,nLIndent)
local nForValue
local i
local j
local nRecNo
local nRecNo2
local lOkay
local lStop
local nOldLMargin := p_setlmargin()
if ! DoEvents(rpt[RPT_BEFORE])
  RETURN .f.
endif
// compute column widths :
rpt[RPT_TEXTWIDTH] := 0
rpt[RPT_TEXTCOLUMNS] := 1
if rpt[RPT_TOCSV]
  default rpt[RPT_COLSEP] to csvsep()
else
  default rpt[RPT_COLSEP] to " "
endif
for j := 1 to len(rpt[RPT_COLUMNS])
  if rpt[RPT_COLUMNS][j][CLN_VALUE] == NIL
    rpt[RPT_TEXTCOLUMNS] ++
    if rpt[RPT_COLUMNS][j][CLN_WIDTH] != NIL
      * rpt[RPT_TEXTWIDTH] += rpt[RPT_COLUMNS][j][CLN_WIDTH]
      rpt[RPT_TEXTWIDTH] += &(rpt[RPT_COLUMNS][j][CLN_WIDTH])
    endif
    if j < len(rpt[RPT_COLUMNS])
      rpt[RPT_TEXTWIDTH] += len(rpt[RPT_COLSEP])
    endif
  else
    rpt[RPT_TEXTWIDTH] -= len(rpt[RPT_COLSEP])
    exit
  endif
next j
snRecCount := 0
if rpt[RPT_TOCSV]
  eval(rpt[RPT_PRINTLINE],rpt[RPT_HDR1])
  if !empty(rpt[RPT_HDR2])
    eval(rpt[RPT_PRINTLINE],rpt[RPT_HDR2])
  endif
  if !empty(rpt[RPT_HDR3])
    eval(rpt[RPT_PRINTLINE],rpt[RPT_HDR3])
  endif
  RptTit2()
  RptTit1()
  RptTit2()
elseif lEmbedded
  if nLIndent != NIL
    p_setlmargin(nOldLMargin+nLIndent)
  endif
  RptTit1()
  RptTit2()
else
  if len(rpt[RPT_COLUMNS]) != 0
    p_SetWidth(RptWidth())
    if rpt[RPT_HEADER] != NIL
      SetPageHeader(rpt[RPT_HEADER])
    else
      SetPageHeader( {|| ;
        PrintHeader( ;
          rpt[RPT_HDR1], ;
          rpt[RPT_HDR2], ;
          rpt[RPT_HDR3]  ;
        ), ;
        RptTit1() , ;
        RptTit2()   ;
      } )
    endif
  endif
  // MsgDisplay(cTitle + "...")
endif
if rpt[RPT_FORLOOP] == NIL
  BEGIN SEQUENCE
    * 20030127
    * if ! AreaOpen(rpt[RPT_AREA],.f.,NIL,.t.) ; BREAK ; endif
    if ! AreaOpen(rpt[RPT_AREA],.f.) ; BREAK ; endif
    if rpt[RPT_RECNOS] == NIL
      if rpt[RPT_INDEX] == NIL
        ddSetOrder(rpt[RPT_ORDER])
      else
        * MsgDisplay("")
        if rpt[RPT_INDEX][NDX_FOR] == NIL
          index on &(rpt[RPT_INDEX][NDX_ON]) ;
                to (rpt[RPT_INDEX][NDX_NAME]) ;
                eval {||Purzel()}
        else
          index on &(rpt[RPT_INDEX][NDX_ON]) ;
                to (rpt[RPT_INDEX][NDX_NAME])  ;
                for &(rpt[RPT_INDEX][NDX_FOR]) ;
                eval {||Purzel()}
        endif
      endif
      softseek (rpt[RPT_START])
    else
      rptgoto(rpt[RPT_RECNOS],1)
    endif
    if (lOkay := RptSkip(rpt))
      nRecNo := recno()
      for i := 1 to len(rpt[RPT_GROUPS])
        if ! GrpReset(rpt,i)
          lOkay := Confirm(SetMsg(),MsgContinue())
        endif
      next i
    endif
    do while lOkay .and. ! eof() .and. xeval(rpt[RPT_WHILE])
      if TaskInter() ; lOkay := .f. ; exit ; endif
      ** 19990628 : headers werden in umgekehrter Reihenfolge ausgefÅhrt.
      ** Beispiel : Haushaltsplan BRF
      for i := len(rpt[RPT_GROUPS]) to 1 step -1
        if rpt[RPT_GROUPS][i][GRP_COUNT] == 0
          rpt[RPT_GROUPS][i][GRP_KEYVALUE] := xeval(rpt[RPT_GROUPS][i][GRP_KEY])
          if ! xeval(rpt[RPT_GROUPS][i][GRP_HEADER])
            lOkay := Confirm(SetMsg(),MsgContinue())
            exit
          endif
        endif
        rpt[RPT_GROUPS][i][GRP_COUNT] ++
      next i
      if ! lOkay
        exit
      endif
      if ! RecReport(rpt) .and. ! Confirm(MsgContinue())
        lOkay := .f.
        exit
      endif
      nRecNo := recno()
      if rpt[RPT_RECNOS] == NIL
        skip
      else
        rptgoto(rpt[RPT_RECNOS],snRow+1)
      endif
      lOkay := RptSkip(rpt)
      ** So. Jetzt sind wir auf dem nÑchsten Record.
      ** Mal sehen, was das an Gruppen-Unterbrechungen hervorruft...
      lStop := .f. // (Vielleicht passiert ja auch gar nichts)
      for i := 1 to len(rpt[RPT_GROUPS])
        if xeval(rpt[RPT_GROUPS][i][GRP_KEY]) != rpt[RPT_GROUPS][i][GRP_KEYVALUE]
          rpt[RPT_GROUPS][i][GRP_STOP] := .t.
          lStop := .t.
        endif
      next i
      if lStop
        ** Mindestens eine Gruppe wurde unterbrochen.
        nRecNo2 := recno()
        goto (nRecNo)
        if RptValRecord(rpt)
          GrpStop(.f.)
        else
          lOkay := Confirm(SetMsg(),MsgContinue())
          exit
        endif
        goto (nRecNo2)
        if ! eof() .and. ! RptValRecord(rpt)
          lOkay := Confirm(SetMsg(),MsgContinue())
          exit
        endif
      endif
    enddo
    if lOkay
      goto (nRecNo)
      RptValRecord(rpt)
      GrpStop(.t.)
      * for i := 1 to len(rpt[RPT_GROUPS])
      *   if rpt[RPT_GROUPS][i][GRP_DTLCOUNT] > 0 .or. xeval( ;
      *     rpt[RPT_GROUPS][i][GRP_BEFORE], ;
      *     rpt[RPT_GROUPS][i][GRP_COUNT], ;
      *   )
      *     if xeval( ;
      *       rpt[RPT_GROUPS][i][GRP_AFTER], ;
      *       rpt[RPT_GROUPS][i][GRP_COUNT], ;
      *       rpt[RPT_GROUPS][i][GRP_DTLCOUNT] ;
      *     )
      *       for j := 1 to len(rpt[RPT_TOTALS])
      *         PrintTotal(j,i)
      *       next j
      *       // TtlPrintAll(i) // sub-totals for group i
      *     endif
      *   endif
      * next i
    endif
    AreaClose()
    if rpt[RPT_INDEX] != NIL
      ddCloseAll()
    endif
    if lOkay
      lOkay := DoEvents(rpt[RPT_AFTER])
    endif
  END SEQUENCE
else
  lOkay := .t.
  suForValue := rpt[RPT_FORLOOP][1]
  for i := 1 to len(rpt[RPT_GROUPS])
    if ! GrpReset(rpt,i)
      lOkay := Confirm(SetMsg(),MsgContinue())
    endif
  next i
  do while lOkay .and. suForValue <= rpt[RPT_FORLOOP][2]
    if TaskInter() ; lOkay := .f. ; exit ; endif
    ** 19990628 : headers werden in umgekehrter Reihenfolge ausgefÅhrt.
    ** Beispiel : Haushaltsplan BRF
    for i := len(rpt[RPT_GROUPS]) to 1 step -1
      if rpt[RPT_GROUPS][i][GRP_COUNT] == 0
        rpt[RPT_GROUPS][i][GRP_KEYVALUE] := xeval(rpt[RPT_GROUPS][i][GRP_KEY])
        if ! xeval(rpt[RPT_GROUPS][i][GRP_HEADER])
          lOkay := Confirm(SetMsg(),MsgContinue())
          exit
        endif
      endif
      rpt[RPT_GROUPS][i][GRP_COUNT] ++
    next i
    if ! lOkay
      exit
    endif
    if ! RecReport(rpt) .and. ! Confirm(MsgContinue())
      lOkay := .f.
      exit
    endif
    * uForValue := suForValue
    suForValue += rpt[RPT_FORLOOP][3]
    ** So. Jetzt sind wir auf dem nÑchsten Record.
    ** Mal sehen, was das an Gruppen-Unterbrechungen hervorruft...
    lStop := .f. // (Vielleicht passiert ja auch gar nichts)
    for i := 1 to len(rpt[RPT_GROUPS])
      if xeval(rpt[RPT_GROUPS][i][GRP_KEY]) != rpt[RPT_GROUPS][i][GRP_KEYVALUE]
        rpt[RPT_GROUPS][i][GRP_STOP] := .t.
        lStop := .t.
      endif
    next i
    if lStop
      ** Mindestens eine Gruppe wurde unterbrochen.
      suForValue -= rpt[RPT_FORLOOP][3]
      if RptValRecord(rpt)
        GrpStop(.f.)
      else
        lOkay := Confirm(SetMsg(),MsgContinue())
        exit
      endif
      suForValue += rpt[RPT_FORLOOP][3]
      if suForValue <= rpt[RPT_FORLOOP][2] .and. ! RptValRecord(rpt)
        lOkay := Confirm(SetMsg(),MsgContinue())
        exit
      endif
    endif
  enddo
  if lOkay
    suForValue -= rpt[RPT_FORLOOP][3]
    RptValRecord(rpt)
    GrpStop(.t.)
  endif
  if lOkay
    lOkay := DoEvents(rpt[RPT_AFTER])
  endif
endif
if len(rpt[RPT_GROUPS]) == 0
  snRecCount := 0
else
  snRecCount := rpt[RPT_GROUPS][len(rpt[RPT_GROUPS])][GRP_COUNT]
endif
if nLIndent != NIL
  p_setlmargin(nOldLMargin)
endif
RETURN lOkay


STATIC FUNCTION RptValRecord(rpt)
local i
for i := 1 to len(rpt[RPT_VALRECORD])
  RETURN .f. if ! xeval(rpt[RPT_VALRECORD][i])
next i
RETURN .t.

FUNCTION ForValue
RETURN suForValue



FUNCTION GrpStop(lFinal)
local lOkay := .t.
local i,j
local grp
RETURN .f. if ! xeval(rpt[RPT_PRETTL])
for i := 1 to len(rpt[RPT_GROUPS])
  grp := rpt[RPT_GROUPS][i]
  if lFinal .or. grp[GRP_STOP]
    * 20030221
    if xeval( grp[GRP_WHEN], ;
              grp[GRP_COUNT],;
              grp[GRP_DTLCOUNT])
      // GRP_BEFORE is also called if there were no detail records
      // (if DtlCount > 0, then it has been already called in RecReport())
      if grp[GRP_DTLCOUNT] > 0 .or. xeval( ;
        grp[GRP_BEFORE], ;
        grp[GRP_COUNT], ;
        grp[GRP_DTLCOUNT]  ;
      )
        if xeval( ;
          grp[GRP_AFTER], ;
          grp[GRP_COUNT], ;
          grp[GRP_DTLCOUNT] ;
        )
          for j := 1 to len(rpt[RPT_TOTALS])
            PrintTotal(j,i)
          next j
          if ! xeval( ;
            grp[GRP_AFTERTTL], ;
            grp[GRP_COUNT], ;
            grp[GRP_DTLCOUNT] ;
          )
            lOkay := .f.
          endif
        endif
      endif
    endif
    if ! lFinal
      if ! GrpReset(rpt,i)
        lOkay := Confirm(SetMsg(),MsgContinue())
        exit
      endif
    endif
  endif
next i
RETURN .f. if ! lOkay
RETURN xeval(rpt[RPT_POSTTTL])



STATIC FUNCTION RptLoad(cIdRpt) // cFileName)
local a := {}
local j
* local ttl
DlgDefault("ToCSV",BUTTON_OFF)
rpt := array(RPT_ALEN)
rpt[RPT_ORDER]   := 1
rpt[RPT_TOTALS]  := {}
rpt[RPT_COLUMNS] := {}
rpt[RPT_GROUPS]  := {}
rpt[RPT_VALRECORD]  := {}
rpt[RPT_ONEACH]  := {||.t.}
rpt[RPT_FILTER]  := {}
rpt[RPT_BEFORE]  := {}
rpt[RPT_AFTER]   := {}
rpt[RPT_RECNOS]  := NIL
rpt[RPT_FORLOOP]  := NIL
rpt[RPT_PRINTLINE]   := {|cLine|PrintLine(cLine)}
rpt[RPT_TOCSV]   := getvar("ToCSV") == BUTTON_ON
rpt[RPT_WHILE]   := {||.t.}
rpt[RPT_DETAIL]  := {||.t.}
rpt[RPT_START]   := ""
rpt[RPT_COLSEP]  := NIL
rpt[RPT_ROWSEP]  := ""
rpt[RPT_PRETTL]  := {||.t.}
rpt[RPT_POSTTTL]  := {||.t.}
rpt[RPT_NOVALUE] := {|| Confirm( ;
  "RecReport() : no column to print record !", ;
  MsgContinue() ;
) }
aadd(a, { "initialize" ,{|x| xparse(x) } } )
* aadd(a, { "initialize" ,{|x| RepInit(x) } } )
aadd(a, { "area" ,      {|x| (rpt[RPT_AREA]    := xparse(x)) != NIL } } )
aadd(a, { "order",      {|x| (rpt[RPT_ORDER]   := xparse(x)) != NIL } } )
aadd(a, { "start",      {|x| (rpt[RPT_START]   := xparse(x)) != NIL } } )
aadd(a, { "while",      {|x| (rpt[RPT_WHILE]   := xparse(x)) != NIL } } )
aadd(a, { "filter",     {|x| AddIfNotNil(rpt[RPT_FILTER],xparse(x)) } } )
aadd(a, { "header",     {|x| (rpt[RPT_HEADER]  := cblock(x)) != NIL } } )
aadd(a, { "header1",    {|x| (rpt[RPT_HDR1]    := xparse(x)) != NIL } } )
aadd(a, { "header2",    {|x| (rpt[RPT_HDR2]    := xparse(x)) != NIL } } )
aadd(a, { "header3",    {|x| (rpt[RPT_HDR3]    := xparse(x)) != NIL } } )
* aadd(a, { "pageheader", {|x| (rpt[RPT_TITBLOCK] := xparse(x)) != NIL } } )
aadd(a, { "detail",     {|x| (rpt[RPT_DETAIL]  := xparse(x)) != NIL } } )
aadd(a, { "OnNoValue",  {|x| (rpt[RPT_NOVALUE] := xparse(x)) != NIL } } )
aadd(a, { "ColSeparator",  {|x| (rpt[RPT_COLSEP] := xparse(x)) != NIL } } )
aadd(a, { "RowSeparator",  {|x| (rpt[RPT_ROWSEP] := xparse(x)) != NIL } } )
aadd(a, { "PreTotal",   {|x| (rpt[RPT_PRETTL]  := xparse(x)) != NIL } } )
aadd(a, { "PostTotal",  {|x| (rpt[RPT_POSTTTL]  := xparse(x)) != NIL } } )
aadd(a, { "ValidateRecord",   {|x| ;
                         aadd(rpt[RPT_VALRECORD],xparse(x)), ;
                         atail(rpt[RPT_VALRECORD]) != NIL ;
                        } ;
})
aadd(a, { "oneach",     {|x| (rpt[RPT_ONEACH]  := xparse(x)) != NIL } })
aadd(a, { "recnos",     {|x| (rpt[RPT_RECNOS]  := xparse(x)) != NIL } })
aadd(a, { "forloop",    {|x| (rpt[RPT_FORLOOP]  := xparse(x)) != NIL } })
aadd(a, { "group",      {|x| GrpFetch(rpt,x)} } )
aadd(a, { "column",     {|x| ClnFetch(x)} } )
aadd(a, { "total",      {|x| TtlFetch(x)} } )
aadd(a, { "index",      {|x| NdxFetch(x) } } )
aadd(a, { "before",     {|x| AddIfNotNil(rpt[RPT_BEFORE],cblock(x)) } } )
aadd(a, { "after",      {|x| AddIfNotNil(rpt[RPT_AFTER],cblock(x)) } } )
aadd(a, { "PrintLine",  {|x| (rpt[RPT_PRINTLINE]  := xparse(x)) != NIL } })
// aadd(a, { "ToCSV",      {|x| (rpt[RPT_TOCSV]  := xparse(x)) != NIL } })
RETURN NIL if ! IniLoad(a,cIdRpt+".REP")
RETURN rpt

*FUNCTION RepInit(x)
*local cMsg := StrParse(x)
*RETURN .t. if empty(cMsg)
*RETURN Confirm(cMsg,MsgContinue())

FUNCTION GrpFetch(rpt,x)
local a := {}
local grp := array(GRP_ALEN)
grp[GRP_COUNT]  := 0
grp[GRP_WHEN]   := {|nCount|nCount>1}
grp[GRP_ALIGN]  := ALIGN_LEFT
grp[GRP_FORMAT] := ""
grp[GRP_HEADER] := {||.t.}
grp[GRP_DTLCOUNT]  := 0
grp[GRP_BEFORE] := {||.t.}
grp[GRP_AFTERTTL] := {||.t.}
aadd(a, { "key",     {|x| (grp[GRP_KEY]    := xparse(x)) != NIL } })
aadd(a, { "text",    {|x| (grp[GRP_TEXT]   := xparse(x)) != NIL } })
aadd(a, { "when",    {|x| (grp[GRP_WHEN]   := xparse(x)) != NIL } })
aadd(a, { "align",   {|x| (grp[GRP_ALIGN]  := xparse(x)) != NIL } })
aadd(a, { "format",  {|x| (grp[GRP_FORMAT] := xparse(x)) != NIL } })
aadd(a, { "header",  {|x| (grp[GRP_HEADER] := xparse(x)) != NIL } })
aadd(a, { "before",  {|x| (grp[GRP_BEFORE] := xparse(x)) != NIL } })
aadd(a, { "after",   {|x| (grp[GRP_AFTER]  := xparse(x)) != NIL } })
aadd(a, { "afterTotals",   {|x| (grp[GRP_AFTERTTL]  := xparse(x)) != NIL } })
RETURN .f. if ! IniParse(a,x)
grp[GRP_ALIGN] := upper(grp[GRP_ALIGN])
grp[GRP_FORMAT] := upper(grp[GRP_FORMAT])
if grp[GRP_KEY] == NIL
  default grp[GRP_AFTER] to {||RptTit2()}
else
  * default grp[GRP_AFTER] to {|nCount|nCount>1}
  default grp[GRP_AFTER] to {||.t.}
endif
default grp[GRP_KEY]   to {||""}
aadd(rpt[RPT_GROUPS], grp)
RETURN .t.

FUNCTION ClnFetch(x)
local a := {}
local cln := array(CLN_ALEN)
local i
local c
* cln[CLN_XSUM] := {|x|ntomf(x)}
cln[CLN_WHEN] := {||.t.}
aadd(a, { "header", {|x| (cln[CLN_HEADER] := ListAsArray( ;
  xparse(x),";" ;
)) != NIL } })
* aadd(a, { "width",  {|x| (cln[CLN_WIDTH]  := xparse(x)) != NIL } })
aadd(a, { "width",  {|x| (cln[CLN_WIDTH]  := x) != NIL } })
aadd(a, { "text",   {|x| (cln[CLN_TEXT]   := xparse(x)) != NIL } })
aadd(a, { "value",  {|x| (cln[CLN_VALUE]  := xparse(x)) != NIL } })
aadd(a, { "when",   {|x| (cln[CLN_WHEN]   := xparse(x)) != NIL } })
** when : ein Codeblock, der .t. oder .f. zurÅckgibt. Wenn .t., dann
** wird der Text gedruckt und die eventuelle Value ins Total dieser
** Kolonne summiert, ansonsten wird space(width) gedruckt und Value gar
** nicht erst ermittelt.
** Der Codeblock der when-Klauseln fÅr total sowie column kriegt
** immer einen Parameter mit :
** nGroup (Nummer der aktuellen Gruppe) :
** nGroup = -1 beim Ausdruck auf einem Detail-Record
**           0 beim Ausdruck des Gesamt-Totals
**           n beim Ausdruck des Unter-Totals von Gruppe n
aadd(a, { "xsum",   {|x| (cln[CLN_XSUM]   := xparse(x)) != NIL } })
aadd(a, { "type",   {|x| (cln[CLN_TYPE]   := xparse(x)) != NIL } })
aadd(a, { "decpos",   {|x| (cln[CLN_DECPOS]   := xparse(x)) != NIL } })
* aadd(a, { "group",  {|x| (cln[CLN_GROUP]  := xparse(x)) != NIL } })
* aadd(a, { "align",  {|x| (cln[CLN_ALIGN]  := xparse(x)) != NIL } })
RETURN .f. if ! IniParse(a,x)
if cln[CLN_TYPE] == NIL
  if cln[CLN_VALUE] == NIL
    cln[CLN_TYPE] := GTYPE_CHAR
  else
    * cln[CLN_TYPE] := GTYPE_NUMERIC
    cln[CLN_TYPE] := GTYPE_AMOUNT
  endif
endif
// default cln[CLN_DECPOS] to DevDecPos()
if rpt[RPT_TOCSV]
  default cln[CLN_WIDTH] to "LenMont()"
  * default cln[CLN_TEXT] to &("{|x|ntom(x,"+ntrim(cln[CLN_DECPOS]);
  *   +","+cln[CLN_WIDTH])}
  if cln[CLN_TEXT] == NIL
    c := "{|x|komma(ntom(x,"+ntrim(cln[CLN_DECPOS])+","+cln[CLN_WIDTH]+"))}"
    cln[CLN_TEXT] := &c
    * if cln[CLN_VALUE] != NIL
    *   c := "{|x|val2csv('"+GTYPE_AMOUNT+"',ntomf(x,cln[CLN_DECPOS],"+cln[CLN_WIDTH]+")}"
    *   cln[CLN_TEXT] := &c
    * endif
  endif
elseif cln[CLN_VALUE] != NIL
  default cln[CLN_WIDTH] to "LenMntF()"
  * default cln[CLN_WIDTH] to LenMntF()
  * default cln[CLN_TEXT] to {|x|ntomf(x,cln[CLN_DECPOS],cln[CLN_WIDTH])}
  if cln[CLN_TEXT] == NIL
    c := "{|x|ntomf(x,"+ntrim(cln[CLN_DECPOS])+","+cln[CLN_WIDTH]+")}"
    cln[CLN_TEXT] := &c
  endif
endif
default cln[CLN_XSUM] to cln[CLN_TEXT]
default cln[CLN_XSUM] to {|x|ntomf(x)}
aadd(rpt[RPT_COLUMNS], cln)
RETURN .t.

FUNCTION RptAddColumn(acHeader,nWidth,bWhen,bValue,bText,bxSum,;
                      cType,nDecPos)
local cln := array(CLN_ALEN)
cln[CLN_HEADER] := acHeader
* cln[CLN_WIDTH] := nWidth
cln[CLN_WIDTH] := utos(nWidth)
cln[CLN_WHEN] := bWhen
cln[CLN_VALUE] := bValue
cln[CLN_TEXT] := bText
cln[CLN_XSUM] := bxSum
cln[CLN_TYPE] := cType
cln[CLN_DECPOS] := nDecPos
// default cln[CLN_DECPOS] to DevDecPos()
if rpt[RPT_TOCSV]
  * default cln[CLN_TEXT] to {|x|val2csv(cType,x)}
  default cln[CLN_TEXT] to {|x|ntom(x)}
elseif cln[CLN_VALUE] != NIL
  default cln[CLN_TEXT] to {|x|ntomf(x)}
  default cln[CLN_WIDTH] to "LenMntF()"
  * default cln[CLN_WIDTH] to LenMntF()
endif
default cln[CLN_XSUM] to cln[CLN_TEXT]
// default cln[CLN_XSUM] to {|x|ntomf(x)}
default cln[CLN_WHEN] to {||.t.}
aadd(rpt[RPT_COLUMNS], cln)
RETURN .t.

FUNCTION TtlFetch(x)
local a := {}
local ttl := array(TTL_ALEN)
local i
ttl[TTL_TEXT]  := {|x|" ("+ltrim(str(x))+" records)"}
ttl[TTL_WHEN]  := {||.t.}
ttl[TTL_FOR]   := {||.t.}
ttl[TTL_AFTER] := {||.t.}
* ttl[TTL_DONE]  := .f.
* ttl[TTL_GROUP] := 0
aadd(a, { "for",   {|x| (ttl[TTL_FOR]    := xparse(x)) != NIL } })
aadd(a, { "after", {|x| (ttl[TTL_AFTER]  := xparse(x)) != NIL } })
aadd(a, { "text",  {|x| (ttl[TTL_TEXT]   := xparse(x)) != NIL } })
aadd(a, { "when",  {|x| (ttl[TTL_WHEN]   := xparse(x)) != NIL } })
RETURN .f. if ! IniParse(a,x)
aadd(rpt[RPT_TOTALS], ttl)
RETURN .t.

FUNCTION RptAddTotal(bcText,blFor,blWhen,blAfter)
local ttl := array(TTL_ALEN)
default bcText to  {|x|" ("+ltrim(str(x))+" records)"}
default blFor to {||.t.}
default blWhen to {||.t.}
default blAfter to {||.t.}
ttl[TTL_TEXT] := bcText
ttl[TTL_FOR] := blFor
ttl[TTL_WHEN] := blWhen
ttl[TTL_AFTER] := blAfter
aadd(rpt[RPT_TOTALS], ttl)
RETURN .t.

FUNCTION NdxFetch(x)
local a := {}
local ndx := array(NDX_ALEN)
local i
ndx[NDX_NAME]  := "TMP"
aadd(a, { "for",   {|x| (ndx[NDX_FOR]   := xparse(x)) != NIL } })
aadd(a, { "name",  {|x| (ndx[NDX_NAME]  := xparse(x)) != NIL } })
aadd(a, { "on",    {|x| (ndx[NDX_ON]    := xparse(x)) != NIL } })
RETURN .f. if ! IniParse(a,x)
RETURN .f. if ndx[NDX_ON] == NIL
rpt[RPT_INDEX] := ndx
RETURN .t.

FUNCTION RptSkip(rpt)
do while ! eof()
  RETURN .f. if TaskInter()
  * RETURN .f.
  if ! xeval(rpt[RPT_WHILE])
    goto lastrec() + 1
    RETURN .t.
  endif
  if ! RptValRecord(rpt)
    RETURN .f. if ! Confirm(SetMsg(),MsgContinue()))
  endif
  RETURN .t. if DoEvents(rpt[RPT_FILTER])
  MsgDisp2(ntrim0(100*snRecCount++/lastrec())+"%")
  skip
enddo
RETURN .t.

FUNCTION RepRecCount()
RETURN snRecCount

* STATIC FUNCTION TtlPrintAll(nGroup)
* local i
* for i := 1 to len(rpt[RPT_TOTALS])
*   PrintTotal(i,nGroup)
* next i
* RETURN NIL

FUNCTION PrintTotal(nTotal,nGroup)
local cText
local cLine
local j
local ttl := rpt[RPT_TOTALS][nTotal]
local grp := rpt[RPT_GROUPS][nGroup]
RETURN .t. if grp[GRP_TEXT] == NIL
RETURN .t. if grp[GRP_COUNT] == 0
snTtlCurrent := nTotal
snGrpCurrent := nGroup
RETURN .t. if rpt[RPT_TOTALS][nTotal][TTL_TEXT] == NIL
RETURN .t. if grp[GRP_DONE][nTotal]
* 20030221
* grp[GRP_DONE][nTotal] := .t.
* Wenn das WHEN des Totals den Ausdruck verhindert, dann soll dieses
* Total auch spÑter nicht ausgedruckt werden.
* Beispiel HSTPAR.REP : Beginnsaldo von unbewegten Partnern
RETURN .t. if ! xeval( ;
  rpt[RPT_TOTALS][nTotal][TTL_WHEN], ;
  grp[GRP_TTLCOUNT][nTotal], ;
  grp[GRP_DTLCOUNT] ;
)
cLine := trim1(xeval(grp[GRP_TEXT],grp[GRP_COUNT]))
cLine += xeval( ;
  rpt[RPT_TOTALS][nTotal][TTL_TEXT],;
  grp[GRP_TTLCOUNT][nTotal];
)
* cLine += xeval(rpt[RPT_TOTALS][nTotal][TTL_TEXT],grp[GRP_COUNT])
if rpt[RPT_TOCSV]
  for j := 2 to rpt[RPT_TEXTCOLUMNS]
    cLine += rpt[RPT_COLSEP]
  next j
else
  if ALIGN_LEFT $ grp[GRP_ALIGN]
    cLine := padr(cLine,rpt[RPT_TEXTWIDTH])
  else
    cLine := padl(cLine,rpt[RPT_TEXTWIDTH])
  endif
  cLine += rpt[RPT_COLSEP]
endif
for j := rpt[RPT_TEXTCOLUMNS] to len(rpt[RPT_COLUMNS])
  if rpt[RPT_COLUMNS][j][CLN_VALUE] == NIL .and. rpt[RPT_COLUMNS][j][CLN_WIDTH] != NIL
    cLine += space(&(rpt[RPT_COLUMNS][j][CLN_WIDTH]))
    * 20070414 cLine += space(rpt[RPT_COLUMNS][j][CLN_WIDTH])
  else
    snClnCurrent := j
    if rpt[RPT_TOCSV]
      cText := val2csv(GTYPE_NUMERIC,grp[GRP_VALUES][nTotal][j], ;
      " in column "+ntrim(j),rpt[RPT_COLUMNS][j][CLN_DECPOS])
    else
      cText := xeval( ;
        rpt[RPT_COLUMNS][j][CLN_XSUM], ;
        grp[GRP_VALUES][nTotal][j], ;
        nTotal ;
      )
    endif
    cLine += cText
  endif
  if j < len(rpt[RPT_COLUMNS])
    cLine += rpt[RPT_COLSEP]
  endif
next j
snClnCurrent := 0
if FORMAT_BOLD $ grp[GRP_FORMAT]
  cLine := Tagged("B") + cLine + Tagged("b")
endif
RETURN .f. if ! eval(rpt[RPT_PRINTLINE],cLine)
* PrintLine(cLine)
RETURN .f. if ! xeval( ;
  rpt[RPT_TOTALS][nTotal][TTL_AFTER], ;
  nGroup ;
)
* 20030221 war hier dann doch nicht
grp[GRP_DONE][nTotal] := .t.
RETURN .t.

** Wird benutzt in Historik Generalkonten, um fÅr die Ermittlung der
** Beginn- und Endsalden auf die Kolonne "links von mir" (nOffset = -1)
** oder "rechts von mir" (nOffset=1) zuzugreifen.
FUNCTION ClnSum(nOffset)
RETURN rpt[RPT_GROUPS][snGrpCurrent][GRP_VALUES] ;
       [snTtlCurrent][snClnCurrent+nOffset]


static FUNCTION GrpReset(rpt,nGroup)
local i
local j
rpt[RPT_GROUPS][nGroup][GRP_STOP] := .f.
rpt[RPT_GROUPS][nGroup][GRP_COUNT] := 0
rpt[RPT_GROUPS][nGroup][GRP_DTLCOUNT] := 0
rpt[RPT_GROUPS][nGroup][GRP_VALUES] := {}
rpt[RPT_GROUPS][nGroup][GRP_DONE] := {}
rpt[RPT_GROUPS][nGroup][GRP_TTLCOUNT] := {}
for i := 1 to len(rpt[RPT_TOTALS])
  aadd(rpt[RPT_GROUPS][nGroup][GRP_TTLCOUNT], 0)
  aadd(rpt[RPT_GROUPS][nGroup][GRP_DONE], .f.)
  aadd(rpt[RPT_GROUPS][nGroup][GRP_VALUES], {})
  for j := 1 to len(rpt[RPT_COLUMNS])
    aadd(rpt[RPT_GROUPS][nGroup][GRP_VALUES][i], 0)
  next j
next i
RETURN .t.

FUNCTION RptTit1()
local c
local i
local j
local nTitHeight := 0
for j := 1 to len(rpt[RPT_COLUMNS])
  nTitHeight := max(nTitHeight,len(rpt[RPT_COLUMNS][j][CLN_HEADER]))
next j
for i := 1 to nTitHeight
  c := ""
  for j := 1 to len(rpt[RPT_COLUMNS])
    if i <= len(rpt[RPT_COLUMNS][j][CLN_HEADER])
      * if rpt[RPT_COLUMNS][j][CLN_WIDTH] == 0
      if rpt[RPT_COLUMNS][j][CLN_WIDTH] == NIL
        c += rpt[RPT_COLUMNS][j][CLN_HEADER][i]
      elseif rpt[RPT_COLUMNS][j][CLN_VALUE] == NIL
        c += padr( ;
          rpt[RPT_COLUMNS][j][CLN_HEADER][i], ;
          &(rpt[RPT_COLUMNS][j][CLN_WIDTH]) ;
        )
      else
        c += padl( ;
          rpt[RPT_COLUMNS][j][CLN_HEADER][i], ;
          &(rpt[RPT_COLUMNS][j][CLN_WIDTH]) ;
        )
      endif
    else
       c += space(&(rpt[RPT_COLUMNS][j][CLN_WIDTH]))
    endif
    if j < len(rpt[RPT_COLUMNS]) ; c += rpt[RPT_COLSEP] ; endif
  next j
  RETURN .f. if ! eval(rpt[RPT_PRINTLINE],c)
  * PrintLine(c)
next i
RETURN .t.


FUNCTION RptTit2()
local c := ""
local i
for i := 1 to len(rpt[RPT_COLUMNS])
  if rpt[RPT_COLUMNS][i][CLN_WIDTH] != NIL
    c += repl("ƒ",&(rpt[RPT_COLUMNS][i][CLN_WIDTH]))
  endif
  if i < len(rpt[RPT_COLUMNS]) ; c += rpt[RPT_COLSEP] ; endif
next i
RETURN .f. if ! eval(rpt[RPT_PRINTLINE],c)
* PrintLine(c)
RETURN .t.

FUNCTION RptWidth()
local nWidth := 0
local i
for i := 1 to len(rpt[RPT_COLUMNS])
  if rpt[RPT_COLUMNS][i][CLN_WIDTH] != NIL
    nWidth += &(rpt[RPT_COLUMNS][i][CLN_WIDTH])
  endif
  if i < len(rpt[RPT_COLUMNS]) ; nWidth += len(rpt[RPT_COLSEP]) ; endif
next i
RETURN nWidth


FUNCTION RptTit3()
local c := ""
local i
for i := 1 to len(rpt[RPT_COLUMNS])
  if rpt[RPT_COLUMNS][i][CLN_WIDTH] != NIL
    if rpt[RPT_COLUMNS][i][CLN_VALUE] == NIL
      c += space(&(rpt[RPT_COLUMNS][i][CLN_WIDTH]))
    else
      c += repl("ƒ",&(rpt[RPT_COLUMNS][i][CLN_WIDTH]))
    endif
  endif
  if i < len(rpt[RPT_COLUMNS]) ; c += rpt[RPT_COLSEP] ; endif
next i
RETURN .f. if ! eval(rpt[RPT_PRINTLINE],c)
* PrintLine(c)
RETURN .t.

**
** RecReport() - executed on each line to collect values & print detail
**
STATIC FUNCTION RecReport(rpt)
local i,j,k
local nValue
local lFound := .f.
local cLine := ""
local lDetail := xeval(rpt[RPT_DETAIL])
local cln, grp
local cText
RETURN .f. if ! xeval(rpt[RPT_ONEACH])
RETURN .t. if len(rpt[RPT_COLUMNS]) == 0
if lDetail
  ** GRP_BEFORE wird erst vor dem Verarbeiten
  ** des ersten Records ausgefÅhrt, der effektiv ausgedruckt wird.
  for k := 1 to len(rpt[RPT_GROUPS])
    grp := rpt[RPT_GROUPS][k]
    grp[GRP_DTLCOUNT] += 1
    if grp[GRP_DTLCOUNT] == 1
      if xeval( grp[GRP_WHEN], ;
                grp[GRP_COUNT],;
                grp[GRP_DTLCOUNT])
        RETURN .f. if ! xeval( ;
          grp[GRP_BEFORE], ;
          grp[GRP_COUNT], ;
          grp[GRP_DTLCOUNT] ;
        )
      endif
    endif
  next k
endif
for i := 1 to len(rpt[RPT_COLUMNS])
  if lDetail .and. i > 1
    cLine += rpt[RPT_COLSEP]
  endif
  cln := rpt[RPT_COLUMNS][i]
  if xeval(cln[CLN_WHEN],0)
    if cln[CLN_VALUE] == NIL
      nValue := NIL
    else
      nValue := xeval(cln[CLN_VALUE])
      default nValue to 0 // 20070516
      for j := 1 to len(rpt[RPT_TOTALS])
        if xeval(rpt[RPT_TOTALS][j][TTL_FOR])
          for k := 1 to len(rpt[RPT_GROUPS])
            rpt[RPT_GROUPS][k][GRP_VALUES][j][i] += nValue
            // rpt[RPT_GROUPS][k][GRP_TTLCOUNT][j] ++
          next k
        endif
      next j
      lFound := .t.
    endif
    if lDetail
      * cLine += xeval(rpt[RPT_COLUMNS][i][CLN_TEXT],nValue)
      cText := xeval(cln[CLN_TEXT],nValue)
    endif
  else
    cText := space(&(cln[CLN_WIDTH]))
  endif
  if lDetail
    if rpt[RPT_TOCSV]
      cText := val2csv(cln[CLN_TYPE],cText," in column "+ntrim(i))
    elseif cln[CLN_WIDTH] != NIL
      if cln[CLN_VALUE] == NIL
        // class Text
        cText := padl(cText,&(cln[CLN_WIDTH]))
      else
        // class Number
        cText := padr(cText,&(cln[CLN_WIDTH]))
      endif
    endif
    cLine += cText
  endif
next i
if ! lFound
  RETURN .f. if ! xeval(rpt[RPT_NOVALUE])
endif
for j := 1 to len(rpt[RPT_TOTALS])
  if xeval(rpt[RPT_TOTALS][j][TTL_FOR]) // 20020620b
    for k := 1 to len(rpt[RPT_GROUPS])
      rpt[RPT_GROUPS][k][GRP_TTLCOUNT][j] ++
    next k
  endif
next j
RETURN .t. if ! lDetail
cLine += rpt[RPT_ROWSEP]
// PrintLine(cLine)
RETURN .f. if ! xeval(rpt[RPT_PRINTLINE],cLine)
RETURN .t.

* FUNCTION RptGrpCount(nGroup) ; RETURN RptCount(nGroup)

FUNCTION RptCount(nGroup)
RETURN 0 if nGroup <= 0 .or. nGroup > len(rpt[RPT_GROUPS])
RETURN rpt[RPT_GROUPS][nGroup][GRP_COUNT]

FUNCTION IsFirst(nGroup,lOfPrinted)
default lOfPrinted to .t.
if lOfPrinted
  RETURN (rpt[RPT_GROUPS][nGroup][GRP_DTLCOUNT] == 1)
endif
RETURN (rpt[RPT_GROUPS][nGroup][GRP_COUNT] == 1)

FUNCTION RptValue(nGroup,nTotal,nColumn)
RETURN rpt[RPT_GROUPS][nGroup][GRP_VALUES][nTotal][nColumn]

**
** DbfDelete()
**
FUNCTION DbfDelete(cTitle,xcWarning,adTables,nOrder,cStart,xlWhile,xlFilter)
local cAnswer := "N" // Y, A, Q
local lOkay := .f.
local nCount := 0
local nDeleted := 0
if cTitle != NIL
  RETURN .f. if ! Confirm(cTitle,MsgSure(),MSG_NO)
  MsgDisplay(cTitle + "...")
endif
default nOrder to 1
default cStart to ""
* default xlWhile to ".t."
default xlFilter to ".t."
if xcWarning == NIL
  cAnswer := "A"
endif
BEGIN SEQUENCE
  if ! AreaOpen(adTables,.f.) ; BREAK ; endif
  lOkay := .t.
  ddSetOrder(nOrder)
  default xlWhile to "left("+indexkey()+","+ntrim(len(cStart))+")=='"+cStart+"'"
  softseek (cStart)
  do while lOkay .and. ! eof() .and. cAnswer != "Q" .and. &xlWhile
    if TaskInter() ; lOkay := .f. ; exit ; endif
    MsgDisp2(ntrim0(100*(nCount++/lastrec()))+"%")
    if &xlFilter
      if ddRecLock()
        if cAnswer != "A"
          cAnswer := Decide("YNAQ",&xcWarning,"Yes, No, Always, Quit ?")
        endif
        if cAnswer $ "YA"
          nDeleted++
          delete
        endif
        unlock record
      else
        lOkay := .f.
      endif
    endif
    skip
  enddo
  AreaClose()
END SEQUENCE
if cTitle != NIL
  Warning(cTitle + " :",ntrim(nDeleted) + " DatensÑtze wurden gelîscht.")
endif
* RETURN .f. if ! lOkay
* RETURN
SetMnuDone()
RETURN lOkay

/*
  19990820. In der Intrastat-ErklÑrung wird ohne detail gearbeitet, d.h.
  die scheinbaren Detail-Zeilen sind in Wirklichkeit schon
  Zwischensummen. Diese Zwischensummen sollen da sein, aber die
  Gesamtsumme soll in manchen Kolonnen nicht stehen. Dort wird dann im
  xsum=... auf RptTotal() getestet...
*/
FUNCTION RptGroup() ; RETURN snGrpCurrent
FUNCTION RptTotal() ; RETURN snTtlCurrent


#endif DEF_REPORT

**
**  IniLoad()
**
FUNCTION IniLoad(aItems, cFileName, lMsg )
local lFound
local fd, i
local cMsg
local cLine, nCut
local cKeyWord
* local nLine := 0
local lOkay := .t.
* if ! "\" $ cFileName
*   cFileName := dbPath() + "\" + cFileName
* endif
* default lMsg to .t.
* #ifdef DEF_VERBOSE
  * if lMsg
    MsgVerbose(MsgLoading(cFileName) )
  * endif
  * rpt_write(MsgLoading(cFileName))
* #endif
RETURN .f. if (fd := mopen(cFileName)) == NIL
// wenn DLM\STD\STD.INI nicht existiert, dann soll keine Warnung kommen
do while lOkay .and. (cLine := mreadline(fd)) != NIL
  * nLine++
  cLine := alltrim(cLine)
  nCut := at( "//", cLine )
  if nCut != 0
    cLine := trim(left( cLine, nCut - 1 ))
  endif
  if ! empty(cLine)
    if left(cLine,9)=="#include "
      if ! IniLoad(aItems,xparse(substr(cLine,10)),lMsg)
        lOkay := .f.
      endif
    else
      * rpt_write(cLine)
      cLine += " " // falls das Keyword alleine da steht...
      lFound := .f.
      for i := 1 to len(aItems)
        *cKeyWord := upper(alltrim(aItems[i][INI_KEYWORD])) + " "
        *if upper(left( cLine, len(cKeyWord))) == cKeyWord
        cKeyWord := aItems[i][INI_KEYWORD] + " "
        if left( cLine, len(cKeyWord)) == cKeyWord
          lFound := .t.
          // cLine :=
          lOkay := eval( ;
            aItems[i][INI_BLOCK], ;
            alltrim(substr(cLine,len(cKeyWord))) ;
          )
          if valtype(lOkay) != "L"
            lOkay := Confirm( ;
              cLine + " : return value must be LOGICAL!",;
              MsgContinue())
          endif
          exit
        endif
      next i
      if ! lFound
        * cMsg := cFileName + "(" + ntrim(nLine)
        cMsg := cFileName + "(" + ntrim(mline(fd))
        cMsg += + ') : unknown keyword "'
        cMsg += cLine + '"'
        if len(cMsg) > 74
          cMsg := trim(left(cMsg,70)) +'..."'
        endif
        lOkay := Confirm(cMsg, MsgContinue())
      elseif ! lOkay // neu 20070302
        cMsg := cFileName + "(" + ntrim(mline(fd))
        cMsg += + ') : invalid value ' + substr(cLine,len(cKeyWord))
        cMsg += " for "+cKeyword
        if !empty(SetMsg())
          cMsg += "(" + SetMsg() + ")"
        endif
        SetMsg(cMsg)
      endif
    endif
  endif
enddo
mclose(fd)
#ifdef DEF_VERBOSE
  * if lMsg
    MsgVerbose("")
  * endif
#endif
RETURN lOkay

FUNCTION IniParse(a,x)
local i
local nPos
local nLastPos := 0
local nKeyWord
do while .t.
  nLastPos := 0
  nKeyWord := NIL
  for i := 1 to len(a)
    if (nPos := rat(a[i][INI_KEYWORD] + "=",x)) > nLastPos
      nLastPos := nPos
      nKeyWord := i
    endif
  next i
  if nKeyWord == NIL
    exit
  else
    if eval(a[nKeyWord][INI_BLOCK],alltrim(substr(x,nLastPos+len(a[nKeyWord][INI_KEYWORD])+1)))
      x := alltrim(left(x,nLastPos-1))
    else
      Warning( ;
        alltrim(substr(x,nLastPos+len(a[nKeyWord][INI_KEYWORD])+1)) + " :" , ;
        "UngÅltige Angabe fÅr " + a[nKeyWord][INI_KEYWORD] + "= !" ;
      )
      exit
    endif
  endif
enddo
if ! empty(x)
  Warning(x + " : Fehler bei IniParse() !")
  RETURN .f.
endif
RETURN .t.


FUNCTION MsgContinue()
#ifdef LG_FRENCH
  RETURN "Continuer le traitement (O/N) ?"
#endif
#ifdef LG_GERMAN
  RETURN "Arbeitsvorgang fortsetzen (J/N) ?"
#endif
#ifdef LG_EN
  RETURN "Continue (Y/N) ?"
#endif


