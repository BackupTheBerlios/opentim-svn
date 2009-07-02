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

#include "TIM.CH"

**
** STATIC_SECTION global static variables
**

static scIdDev

#ifdef DEF_IMP

static scPeriode := NIL
static scIdCdc


FUNCTION BudSumCompute(cYear,nLenDebug)
local lOkay := .f.
local nCount
local aCtb := {}
local i
local cLine
open area oBud(), oCtb()
  ddSetOrder(ORD_BUD_HH) // IdSbb + IdFcb
  nCount := 0
  lOkay := .t.
  go top
  do while lOkay .and. ! eof()
    MsgDisplay("Summenartikel "+cYear+" aktualisieren (Vorlauf) : " + ntrim(len(aCtb)) + " Elemente...")
    MsgDisp2(ntrim0(nCount++ / lastrec() * 100) + "%")
    if BUD->IsSum == BUTTON_ON .or. ! BUDATTR_H $ BUD->Attrib
      select CTB
      softseek BUD->DC + BUD->IdBud + trim(cYear)
      do while lOkay .and. ! eof() ;
               .and. CTB->IdBud == BUD->IdBud .and. CTB->DC == BUD->DC ;
               .and. (empty(cYear).or.CTB->Periode<=cYear)
        if TaskInter() ; lOkay := .f. ; endif
        if BUD->IsSum == BUTTON_ON
          if ddRecLock()
            delete
            unlock record
          else
            lOkay := .f.
          endif
        elseif ! empty(BUD->IdBud_s)
          CtbCollect( ;
            aCtb,BUD->DC_s,BUD->IdBud_s,CTB->Periode, ;
            CTB->IdCdc, val(CTB->Mont) ;
          )
        endif
        skip
      enddo
      select BUD
    endif
    skip
  enddo
close area
do while lOkay .and. len(aCtb) > 0
  MsgDisplay("CtbFlush " + ntrim(len(aCtb)) + " items...")
  if nLenDebug != NIL .and. len(aCtb) < nLenDebug
    for i := 1 to len(aCtb)
      cLine := "CtbFlush() : "
      cLine += aCtb[i][CTB_IDCDC]
      cLine += " " + aCtb[i][CTB_PERIODE]
      cLine += " " + aCtb[i][CTB_DC]
      cLine += " " + aCtb[i][CTB_IDBUD]
      rpt_write(cLine)
    next i
    SetKeepReport(.t.)
  endif
  if TaskInter() ; lOkay := .f. ; exit ; endif
  aCtb := CtbFlush(aCtb)
enddo
RETURN !SetMsg("BudSumCompute() failed !") if ! lOkay
RETURN .t.

FUNCTION CtbFlush(aCtb)
local aCtbSum := {}
local i
open area oBud()
  for i := 1 to len(aCtb)
    if BudExist(aCtb[i][CTB_DC],aCtb[i][CTB_IDBUD])
      if ! empty(BUD->IdBud_s)
        CtbCollect( ;
          aCtbSum,BUD->DC_s,BUD->IdBud_s,;
          aCtb[i][CTB_PERIODE], ;
          aCtb[i][CTB_IDCDC], ;
          aCtb[i][CTB_MONT] ;
        )
      endif
    else
      Warning("CtbFlush() : " + SetMsg())
    endif
  next i
close area
if ! CtbUpdate(aCtb)
  Warning("CtbUpdate() failed !")
endif
RETURN aCtbSum


#define BCL_DC      1
* #define BCL_PERIODE 2
* #define BCL_IDCDC   3
#define BCL_DIENST  2
#define BCL_HEADER  3
#define BCL_EXPR    4
#define BCL_ALEN    4

FUNCTION LstHaushalt(cType,cIdCdc)
local cSavePeriode := scPeriode
static cIdFcb := NIL
local cMitName2 := BUTTON_OFF
* local cIdCdc := "00"
local cPeriode := if( ;
  cType=="H", ;
  str(year(UserDate())+1,4), ;
  str(year(UserDate())-1,4) ;
)
static c03 := BUTTON_ON
static c04 := BUTTON_ON
static c05 := BUTTON_ON
* static c06 := BUTTON_ON
static c07 := BUTTON_ON
static c08bis := BUTTON_ON
static c09 := BUTTON_ON
static c11 := BUTTON_ON
static c12 := BUTTON_ON
static c12Detail := BUTTON_ON
* static cAnnexe := BUTTON_ON
default cIdFcb to space(5)
open window (MsgHaushalt(cType)) ;
            size  if(cType=="R",15,11),56 ;
            help  LSTHAUS
say "Haushaltsjahr "
get cPeriode
WinCr()
get c03 checkbox
say " Unterteilung (02 und) 03 "
WinCr()
get c04 checkbox
say " Unterteilung 04 "
* WinCr()
* say "Zentralisierungscode "
* get cIdCdc picture PIC_ID pick PickCdc(NIL,cIdCdc)
WinCr()
get c05 checkbox
say " Unterteilung 05"
WinCr()
get c07 checkbox
say " Unterteilung 06, 07 und 08"
if cType == "R"
  WinCr()
  get c08bis checkbox
  say " Unterteilung 8bis"
  WinCr()
  get c09 checkbox
  say " Unterteilung 9 und 10"
  WinCr()
  get c11 checkbox
  say " Unterteilung 11 (LFV)"
  WinCr()
  get c12 checkbox
  say " Unterteilung 12 (zu Åbertragen), evtl. mit "
  get c12Detail checkbox
  say " Detail"
endif
WinCr()
get cMitName2 checkbox
say " mit Bezeichnung 2 jedes Artikels"
WinCr()
say "nur Funktion "
get cIdFcb picture PIC_ID pick PickFcb(cIdFcb)
WinCr()
SetTplIni("HHRE")
GetTplIni()
GetPreview()
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
scPeriode := cPeriode
scIdCdc   := cIdCdc
SetTplLang(MemLang1)
SetDevise(DevDefault(LastPeriode(scPeriode)))
if !empty(c03+c04+c05+c07+c08bis+c09+c11+c12)
  if ! OpenPrinter(SetTplIni(),SetPreview())
    scPeriode := cSavePeriode
    RETURN .f.
  endif
  // open printer SetTplIni() preview SetPreview()
    if c03 == BUTTON_ON
      if cType == "R"
        LstHH04(cType,"02",cMitName2,cPeriode,cIdFcb)
        LstHH04(cType,"03",cMitName2,cPeriode,cIdFcb)
      else
        LstHH04(cType,"03",cMitName2,cPeriode,cIdFcb)
      endif
    endif
    if c04 == BUTTON_ON
      LstHH04(cType,"04",cMitName2,cPeriode,cIdFcb)
    endif
    if c05 == BUTTON_ON
      if cType == "H"
        LstHH05(cType,DC_CREDIT,"1",cPeriode,"Ord. Dienst : Zusammenfassung der Einnahmen")
        LstHH05(cType,DC_DEBIT ,"1",cPeriode,"Ord. Dienst : Zusammenfassung der Ausgaben")
        LstHH05(cType,DC_CREDIT,"2",cPeriode,"Au·erord. Dienst : Zusammenfassung der Einnahmen")
        LstHH05(cType,DC_DEBIT ,"2",cPeriode,"Au·erord. Dienst : Zusammenfassung der Ausgaben")
      else
        LstRe05(cType,DC_CREDIT,"1","65",cPeriode,"Ord. Dienst : Zusammenfassung der Einnahmen")
        LstRe05(cType,DC_DEBIT ,"1","75",cPeriode,"Ord. Dienst : Zusammenfassung der Ausgaben")
        LstRe05(cType,DC_CREDIT,"2","85",cPeriode,"Au·erord. Dienst : Zusammenfassung der Einnahmen")
        LstRe05(cType,DC_DEBIT ,"2","95",cPeriode,"Au·erord. Dienst : Zusammenfassung der Ausgaben")
        TplInclude("HHR",padr("R05",LenIdTpl())) ; p_eject()
      endif
    endif
    if c07 == BUTTON_ON
      if cType == "H"
        LstHH06("06","3",cPeriode,"Verwaltung der Fonds")
        LstHH06("07","3",cPeriode,"GeschÑfte fÅr Rechnung von Dritten")
        LstHH06("08","3",cPeriode,"KassengeschÑfte")
      else
        LstRe06("06","3",cPeriode,"Verwaltung der Fonds")
        LstRe06("07","3",cPeriode,"GeschÑfte fÅr Rechnung von Dritten")
        LstRe06("08","3",cPeriode,"KassengeschÑfte")
      endif
    endif
    if cType == "R"
      if c08bis == BUTTON_ON
        LstRe08bis(padr("HHT",LenIdJnl()),cPeriode)
      endif
      if c09 == BUTTON_ON
        TplInclude("HHR",padr("R09",LenIdTpl())) ; p_eject()
        TplInclude("HHR",padr("R10",LenIdTpl())) ; p_eject()
      endif
      if c11 == BUTTON_ON
        LstRe11(padr("LFV",LenIdJnl()),padr("R11",LenIdTpl()))
      endif
      if c12 == BUTTON_ON
        LstRe12("A","1","O.A. : zu Åbertragende Verpflichtungen")
        LstRe12("A","2","A.A. : zu Åbertragende Verpflichtungen")
        LstRe12("E","1","O.E. : beizutreibende RestbetrÑge")
        LstRe12("E","2","A.E. : beizutreibende RestbetrÑge")
      endif
    endif
  close printer
endif
if c12Detail == BUTTON_ON .and. cType == "R"
  if ! OpenPrinter(SetTplIni(),SetPreview())
    scPeriode := cSavePeriode
    RETURN .f.
  endif
  // open printer SetTplIni() preview SetPreview()
  Re12Detail(.f.,"A",cPeriode,;
    "BUD->Service=='1'.and.BUD->IsSum==' '.and.!'H'$BUD->Attrib",;
    "Db2Dev(SetDevise(),MVI->Periode,val(MVI->MontUs))",;
    "O.A. : zu Åbertragende Verpflichtungen";
  )
  Re12Detail(.f.,"A",cPeriode,;
    "BUD->Service=='2'.and.BUD->IsSum==' '.and.!'H'$BUD->Attrib",;
    "Db2Dev(SetDevise(),MVI->Periode,val(MVI->MontUs))",;
    "A.A. : zu Åbertragende Verpflichtungen")
  Re12Detail(.f.,"E",cPeriode,;
    "BUD->Service=='1'.and.BUD->IsSum==' '.and.!'H'$BUD->Attrib",;
    "Db2Dev(SetDevise(),MVI->Periode,val(MVI->MontUs))",;
    "O.E. : beizutreibende RestbetrÑge")
  Re12Detail(.f.,"E",cPeriode,;
    "BUD->Service=='2'.and.BUD->IsSum==' '.and.!'H'$BUD->Attrib",;
    "Db2Dev(SetDevise(),MVI->Periode,val(MVI->MontUs))",;
    "A.E. : beizutreibende RestbetrÑge")
  close printer
endif
scPeriode := cSavePeriode
RETURN .t.

FUNCTION LstHH04(cType,cIdSbb,cMitName2,cPeriode,cIdFcb)
local nCount := 0
local aFcbSum
local aSbbSum := {}
local aBcl 
local fcb
local i
local cLine
local lOkay := .f.
local cIdGrbD
local cIdGrbC
* static dDate := NIL
* default dDate to UserDate()
RETURN NIL if len( (aBcl := ReadArray(cType + cPeriode + "-" + cIdSbb + ".DBC", BCL_ALEN) ) ) == 0
open area oBud(), oCtb()
  lOkay := .t.
  ddSetOrder(ORD_BUD_HH)
  softseek cIdSbb + trim(cIdFcb)
  do while lOkay .and. ! eof() .and. BUD->SubBud == cIdSbb
    if TaskInter() ; lOkay := .f. ; exit ; endif
    if ! empty(cIdFcb) .and. BUD->IdFcb > cIdFcb
      SndLine(cType,NIL,NIL,"",aBcl,fcb,cIdSbb)
      exit
    endif
    if (fcb := FcbLocate(BUD->IdFcb)) == NIL
      Warning(BUD->IdFcb + " : unbekannte HH-Funktion !")
      skip
      loop
    endif
    aFcbSum := {}
    cIdGrbD := ""
    cIdGrbC := ""
    do while lOkay .and. ! eof() .and. BUD->SubBud == cIdSbb ;
                                 .and. BUD->IdFcb == fcb[FCB_IDFCB]
      MsgDisp2(ntrim0(nCount++ / lastrec() * 100) + "%")
      if ! BUDATTR_H $ BUD->Attrib
        if BUD->DC == DC_DEBIT
          if cIdGrbD != BUD->CodTot
            cLine := padr(BUD->CodTot,18)
            cLine += " " + GrbName(BUD->CodTot)
            cLine := "{B}" + cLine + "{b}"
            SndLine(cType,BUD->GrbPos,BUD->DC,cLine,aBcl,fcb,cIdSbb)
            SndLine(cType,BUD->GrbPos,BUD->DC,"",aBcl,fcb,cIdSbb)
            cIdGrbD := BUD->CodTot
          endif
        else
          if cIdGrbC != BUD->CodTot
            cLine := padr(BUD->CodTot,18)
            cLine += " " + GrbName(BUD->CodTot)
            cLine := "{B}" + cLine + "{b}"
            SndLine(cType,BUD->GrbPos,BUD->DC,cLine,aBcl,fcb,cIdSbb)
            SndLine(cType,BUD->GrbPos,BUD->DC,"",aBcl,fcb,cIdSbb)
            cIdGrbC := BUD->CodTot
          endif
        endif
        cLine := SayIdBud(BUD->IdBud)
        cLine += " " + BUD->Name1
        for i := 1 to len(aBcl)
          if aBcl[i][BCL_DC] == BUD->DC 
            if empty(aBcl[i][BCL_DIENST]) .or. BUD->Service == aBcl[i][BCL_DIENST]
              cLine += " " + ntomf(&(aBcl[i][BCL_EXPR]))
            endif
          endif
        next i
        if BUD->IsSum == BUTTON_ON
          cLine := "{B}{U}" + cLine + "{u}{b}"
        endif
        SndLine(cType,BUD->GrbPos,BUD->DC,cLine,aBcl,fcb,cIdSbb)
        if cMitName2 == BUTTON_ON
          cLine := space(18)
          cLine += " " + BUD->Name2
          if BUD->IsSum == BUTTON_ON
            cLine := "{S}" + cLine + "{s}"
          endif
          SndLine(cType,BUD->GrbPos,BUD->DC,cLine,aBcl,fcb,cIdSbb)
        endif
        if BUD->IsSum == BUTTON_ON
          SndLine(cType,BUD->GrbPos,BUD->DC,"",aBcl,fcb,cIdSbb)
        endif
      endif
      skip
    enddo
    ** Seitensprung nach jeder Funktion
    ** [mal kucken was das gibt...]
    do while SndLine(cType,NIL,NIL,"",aBcl,fcb,cIdSbb) // buffer leeren
    enddo
    * p_eject()
  enddo
close area
RETURN NIL

#define LINE_GRBPOS 1
#define LINE_D      2
#define LINE_C      3
#define LINE_ALEN   3

#define TOP_MARGIN  11

**
** SndLine()
** Wenn cDC == NIL gibt SndLine() zurÅck, ob noch was im Buffer ist
**
FUNCTION SndLine(cType,cGrbPos,cDC,cLine,aBcl,fcb,cIdSbb)
static aLines := {}
static nCountD := 0
static nCountC := 0
local nToPrint
local i
local line := NIL
local cTit1
local cTit2
local lEmpty := .t.
**
**
if cDC == NIL
  nToPrint := max(nCountD,nCountC)
  if nToPrint == 0
    ** Anfang 19980408
    aLines := {}
    nCountD := 0
    nCountC := 0
    ** Ende 19980408
    RETURN .f.
  endif
  **
  for i := 1 to nToPrint
    if ! empty(aLines[i][LINE_C])
      lEmpty := .f.
      exit
    elseif ! empty(aLines[i][LINE_D])
      lEmpty := .f.
      exit
    endif
  next i
  if lEmpty
    aLines := {}
    nCountD := 0
    nCountC := 0
    RETURN .f.
  endif
else
  for i := 1 to len(aLines)
    if aLines[i][LINE_GRBPOS] == cGrbPos
      if cDC == DC_DEBIT
        if aLines[i][LINE_D] == NIL
          aLines[i][LINE_D] := cLine
          nCountD++
          RETURN NIL
        endif
      else
        if aLines[i][LINE_C] == NIL
          aLines[i][LINE_C] := cLine
          nCountC++
          RETURN NIL
        endif
      endif
    elseif aLines[i][LINE_GRBPOS] < cGrbPos
      if cDC == DC_DEBIT
        if aLines[i][LINE_D] == NIL
          aLines[i][LINE_D] := ""
          nCountD++
        endif
      else
        if aLines[i][LINE_C] == NIL
          aLines[i][LINE_C] := ""
          nCountC++
        endif
      endif
    endif
  next i
  line := array(LINE_ALEN)
  line[LINE_GRBPOS] := cGrbPos
  if cDC == DC_DEBIT
    line[LINE_D] := cLine
    line[LINE_C] := NIL
    nCountD++
  else
    line[LINE_C] := cLine
    line[LINE_D] := NIL
    nCountC++
  endif
  aadd(aLines,line)
  nToPrint := min(nCountD,nCountC)
  ** NEU [19980408]
  **
  * if nToPrint == 0
  *   nToPrint := max(nCountD,nCountC)
  * endif
  ** ENDE [19980408]
  RETURN NIL if nToPrint < p_LinesLeft() - TOP_MARGIN
endif
if nToPrint > p_LinesLeft() - TOP_MARGIN
  nToPrint := p_LinesLeft() - TOP_MARGIN
endif
**
SetPageHeader({|| PrintHeader( ;
  MsgHaushalt(cType) + " " + scPeriode, ;
  "Unterteilung " + cIdSbb, ;
  "Funktion " + trim(fcb[FCB_IDFCB]) + " : " + fcb[FCB_NAME] ;
) })
**
cTit1 := padr("Artikel",18)
cTit2 := repl("ƒ",18)
cTit1 += " " + padr("EINNAHMEN",40)
cTit2 += " " + repl("ƒ",40)
for i := 1 to len(aBcl)
  if aBcl[i][BCL_DC] == DC_CREDIT
    cTit1 += " " + padr(aBcl[i][BCL_HEADER],LenMntF())
    cTit2 += " " + repl("ƒ",LenMntF())
  endif
next i
p_SetWidth(len(cTit2))
PrintLine(cTit1)
PrintLine(cTit2)
if p_linesleft() < nToPrint ; Warning("Paf! Seitensprung !") ; endif
for i := 1 to nToPrint
  if aLines[i][LINE_C] == NIL
    PrintLine()
  else
    PrintLine(aLines[i][LINE_C])
  endif
next i
p_Eject()
p_MrgMirror()
**
cTit1 := padr("Artikel",18)
cTit2 := repl("ƒ",18)
cTit1 += " " + padr("AUSGABEN",40)
cTit2 += " " + repl("ƒ",40)
for i := 1 to len(aBcl)
  if aBcl[i][BCL_DC] == DC_DEBIT
    cTit1 += " " + padr(aBcl[i][BCL_HEADER],LenMntF())
    cTit2 += " " + repl("ƒ",LenMntF())
  endif
next i
p_SetWidth(len(cTit2))
PrintLine(cTit1)
PrintLine(cTit2)
if p_linesleft() < nToPrint ; Warning("Paf! Seitensprung !") ; endif
for i := 1 to nToPrint
  if aLines[i][LINE_D] == NIL
    PrintLine()
  else
    PrintLine(aLines[i][LINE_D])
  endif
next i
p_Eject()
p_MrgMirror()
** gedruckte aLines[i] wieder freigeben
for i := 1 to nToPrint
  adel(aLines,1)
next i
asize(aLines,len(aLines)-nToPrint)
if nCountD > nToPrint ; nCountD -= nToPrint ; else ; nCountD := 0 ; endif
if nCountC > nToPrint ; nCountC -= nToPrint ; else ; nCountC := 0 ; endif
if len(aLines) == 0
  nCountD := nCountC := 0
  RETURN .f.
endif
RETURN .t.

FUNCTION MsgHaushalt(cType)
RETURN "Rechnung" if cType == "R"
RETURN "Haushalt"

FUNCTION LstHH05(cType,cDC,cDienst,cPeriode,cTitle)
local aGrb := GrbList()
local aFcb := FcbList()
local i,j
local a := {}
local cLine
local cTit1 := padr("Funktionen",40)
local cTit2 := space(40)
local cTit3 := repl("ƒ",40)
local aSum := {}
local lPrint
local nMont
* local nFcbSum
local lFound
local cIdTpl := padr(cType + "05" + cDC + cDienst,LenIdTpl())
local nWidth := TplValue("HHR",cIdTpl,{||val(TPL->Width)},76)
for j := 1 to len(aGrb)
  if aGrb[j][GRB_DC] == cDC .and. aGrb[j][GRB_DIENST] == cDienst
    cTit1 += " " + padl(aGrb[j][GRB_HEADER],LenMntF())
    cTit2 += " " + padc("Gruppe " + aGrb[j][GRB_IDGRB],LenMntF())
    cTit3 += " " + repl("ƒ",LenMntF())
  endif
  aadd(aSum,0)
next j
if nWidth < len(cTit3)
  Warning("HHR " + trim(cIdTpl) + " : Mindestbreite sollte sein : " + ntrim(len(cTit3)))
endif
* cTit1 += " " + padl("FcbSum",LenMntF())
* cTit2 += " " + repl("ƒ",LenMntF())
p_SetWidth(nWidth) // len(cTit3))
SetPageHeader({|| PrintHeader( ;
  MsgHaushalt(cType) + " " + cPeriode, ;
  "Unterteilung 05", ;
  cTitle ;
) })
PrintLine(cTit1)
PrintLine(cTit2)
PrintLine(cTit3)
open area oBud(), oCtb()
  ddSetOrder(ORD_BUD_3) // Service+IsSum+IdFcb+IdGrb
  for i := 1 to len(aFcb)
    * nFcbSum := 0
    lPrint := .f.
    cLine := aFcb[i][FCB_IDFCB]
    cLine += " " + aFcb[i][FCB_NAME]
    cLine := padr(cLine,40)
    for j := 1 to len(aGrb)
      if aGrb[j][GRB_DC] == cDC .and. aGrb[j][GRB_DIENST] == cDienst
        lFound := .f.
        softseek cDienst + BUTTON_ON + aFcb[i][FCB_IDFCB] + aGrb[j][GRB_IDGRB]
        do while ! eof() .and. BUD->Service == cDienst ;
                         .and. BUD->IsSum == BUTTON_ON ;
                         .and. BUD->IdFcb == aFcb[i][FCB_IDFCB] ;
                         .and. BUD->CodTot == aGrb[j][GRB_IDGRB]
          if BUD->DC == cDC
            if ! BUDATTR_H $ BUD->Attrib
              seek BUD->DC + BUD->IdBud + cPeriode + scIdCdc in CTB
              if ! eof() in CTB
                lFound := .t.
                nMont := Db2Dev(SetDevise(),LastPeriode(cPeriode),val(CTB->Mont))
                cLine += " " + ntomf(nMont)
                aSum[j] += nMont
                * nFcbSum += val(CTB->Mont)
                exit
              endif
            endif
          endif
          skip
        enddo
        if lFound
          lPrint := .t.
        else
          cLine += " " + space(LenMntF())
        endif
      endif
    next j
    if lPrint
      PrintLine(cLine)
    endif
  next i
close area
PrintLine(repl("ƒ",p_cpl()))
cLine := "999   Gesamtbetrag"
cLine := padr(cLine,40)
for j := 1 to len(aGrb)
  if aGrb[j][GRB_DC] == cDC .and. aGrb[j][GRB_DIENST] == cDienst
    cLine += " " + ntomf(aSum[j])
  endif
next j
PrintLine(cLine)
PrintLine(repl("ƒ",p_cpl()))
* PrintTemplate("HHR",padr("HH05"+cDC+cDienst,LenIdTpl()))
TplInclude("HHR",padr(cIdTpl,LenIdTpl()))
p_eject()
RETURN NIL


FUNCTION LstRe05(cType,cDC,cDienst,cIdGrb,cPeriode,cTitle)
local aFcb := FcbList()
local i,j
local a := {}
local cLine
local cTit1 := padr("Funktionen",50)
local cTit2 := space(50)
local cTit3 := repl("ƒ",50)
local aSum := {}
local lPrint
local nMont
* local nFcbSum
local lFound
local cIdTpl := padr("R05"+cDC+cDienst,LenIdTpl())
local nWidth := TplValue("HHR",cIdTpl,{||val(TPL->Width)},76)
local aBcl
RETURN NIL if len( (aBcl := ReadArray(cType + cPeriode + "-05.DBC", BCL_ALEN) ) ) == 0
for j := 1 to len(aBcl)
  if aBcl[j][BCL_DC] == cDC
    if empty(aBcl[j][BCL_DIENST]) .or. aBcl[j][BCL_DIENST] == cDienst
      cTit1 += " " + padl(hdr1(aBcl[j][BCL_HEADER]),LenMntF())
      cTit2 += " " + padl(hdr2(aBcl[j][BCL_HEADER]),LenMntF())
      cTit3 += " " + repl("ƒ",LenMntF())
    endif
  endif
  aadd(aSum,0)
next j
if nWidth < len(cTit3)
  Warning("HHR " + trim(cIdTpl) + " : Mindestbreite sollte sein : " + ntrim(len(cTit3)))
endif
p_SetWidth(nWidth) // len(cTit3))
SetPageHeader({|| PrintHeader( ;
  MsgHaushalt(cType) + " " + cPeriode, ;
  "Unterteilung 05", ;
  cTitle ;
) })
PrintLine(cTit1)
PrintLine(cTit2)
PrintLine(cTit3)
open area oBud(), oCtb()
  ddSetOrder(ORD_BUD_3) // Service+IsSum+IdFcb+IdGrb
  for i := 1 to len(aFcb)
    lPrint := .f.
    cLine := aFcb[i][FCB_IDFCB]
    cLine += " " + aFcb[i][FCB_NAME]
    cLine := padr(cLine,50)
    for j := 1 to len(aBcl)
      if aBcl[j][BCL_DC] == cDC
        if empty(aBcl[j][BCL_DIENST]) .or. aBcl[j][BCL_DIENST] == cDienst
          KeyGoBottom( ;
            cDienst+BUTTON_ON+aFcb[i][FCB_IDFCB]+cIdGrb, ;
            "BUD->Service+BUD->IsSum+BUD->IdFcb+BUD->CodTot" ;
          )
          nMont := &(aBcl[j][BCL_EXPR])
          cLine += " " + ntomf(nMont)
          aSum[j] += nMont
          if nMont != 0
            lPrint := .t.
          endif
        endif
      endif
    next j
    if lPrint
      PrintLine(cLine)
    endif
  next i
close area
PrintLine(repl("ƒ",p_cpl()))
cLine := "999   Gesamtbetrag lf. Jahr"
cLine := padr(cLine,50)
for j := 1 to len(aBcl)
  if aBcl[j][BCL_DC] == cDC
    if empty(aBcl[j][BCL_DIENST]) .or. aBcl[j][BCL_DIENST] == cDienst
      cLine += " " + ntomf(aSum[j])
    endif
  endif
next j
PrintLine(cLine)
PrintLine(repl("ƒ",p_cpl()))
TplInclude("HHR",cIdTpl)
p_eject()
RETURN NIL


**
** CtbVal() wird im HHR-Template benutzt ! z.B. {=CtbVal(...)}
**
FUNCTION CtbVal(cDC,cIdBud,cPeriode,cIdCdc)
local nPos
local nValue := 0
default cPeriode to scPeriode
default cIdCdc to scIdCdc
cIdBud := GetIdBud(cIdBud)
open area oBud()
  if BudExist(cDC,cIdBud)
    open area oCtb()
      nValue := CtbMont(cDC,cIdBud,cPeriode,cIdCdc)
      * seek cDC + cIdBud + cPeriode + cIdCdc
      * nValue := val(CTB->Mont)
    close area
  else
    Warning(SetMsg())
  endif
close area
RETURN nValue

FUNCTION LstHH06(cIdSbb,cDienst,cPeriode,cTitle,cIdCdc)
local a := {}
local cLine
local cTit1 := padr("Funktionen",40)
local cTit2 := ""
local cTit3 := ""
local cIdBud := "*"
local lOkay := .t.
local aSum := {}
local lPrint := .t.
local lFound
local cPrevPer := str(val(cPeriode)-1,LEN_PERIODE,0)
local nTot1 := 0
local nTot2 := 0
local nTot3 := 0
local nTot4 := 0
cTit1 := padr("Artikel",18)
cTit2 := space(18)
cTit3 := repl("ƒ",18)
cTit1 += " " + padr("SCHéTZUNGEN",40)
cTit2 += " " + space(40)
cTit3 += " " + repl("ƒ",40)
cTit1 += " " + padc(cPrevPer,LenMntF()*2+1)
cTit2 += " " + padc("Einnahmen",LenMntF())
cTit3 += " " + repl("ƒ",LenMntF())
cTit2 += " " + padc("Ausgaben",LenMntF())
cTit3 += " " + repl("ƒ",LenMntF())
cTit1 += " " + padc(cPeriode,LenMntF()*2+1)
cTit2 += " " + padc("Einnahmen",LenMntF())
cTit3 += " " + repl("ƒ",LenMntF())
cTit2 += " " + padc("Ausgaben",LenMntF())
cTit3 += " " + repl("ƒ",LenMntF())
p_SetWidth(len(cTit3))
SetPageHeader({|| PrintHeader( ;
    "Haushalt " + cPeriode, ;
    "Unterteilung " + cIdSbb, ;
    cTitle ;
  ) , ;
  PrintLine(cTit1) , ;
  PrintLine(cTit2) , ;
  PrintLine(cTit3)   ;
})
open area oBud(), oCtb()
  ddSetOrder(ORD_BUD_HH)
  softseek cIdSbb
  do while lOkay .and. ! eof() .and. BUD->SubBud == cIdSbb
    if TaskInter() ; lOkay := .f. ; exit ; endif
    if BUD->IdBud != cIdBud
      cIdBud := BUD->IdBud
      cLine := SayIdBud(BUD->IdBud)
      cLine += " " + padr(BUD->Name1,40)
      seek "E" + cIdBud + cPrevPer + "01" in CTB
        if BUDATTR_H $ BUD->Attrib ; lPrint := .f. ; endif
        if BUD->IsSum == BUTTON_ON
          nTot1 += Db2Dev(SetDevise(),LastPeriode(CTB->Periode),val(CTB->Mont))
          * nTot1 += val(CTB->Mont)
        endif
        cLine += " " + ntomf(Db2Dev(SetDevise(),LastPeriode(CTB->Periode),val(CTB->Mont)))
        * cLine += " " + ntomf(val(CTB->Mont))
      seek "A" + cIdBud + cPrevPer + "01" in CTB
        if BUDATTR_H $ BUD->Attrib ; lPrint := .f. ; endif
        if BUD->IsSum == BUTTON_ON
          nTot2 += Db2Dev(SetDevise(),LastPeriode(CTB->Periode),val(CTB->Mont))
          * nTot2 += val(CTB->Mont)
        endif
        cLine += " " + ntomf(Db2Dev(SetDevise(),LastPeriode(CTB->Periode),val(CTB->Mont)))
        * cLine += " " + ntomf(val(CTB->Mont))
      seek "E" + cIdBud + cPeriode + "00" in CTB
        if BUDATTR_H $ BUD->Attrib ; lPrint := .f. ; endif
        if BUD->IsSum == BUTTON_ON
          nTot3 += Db2Dev(SetDevise(),LastPeriode(CTB->Periode),val(CTB->Mont))
          * nTot3 += val(CTB->Mont)
        endif
        cLine += " " + ntomf(Db2Dev(SetDevise(),LastPeriode(CTB->Periode),val(CTB->Mont)))
      seek "A" + cIdBud + cPeriode + "00" in CTB
        if BUDATTR_H $ BUD->Attrib ; lPrint := .f. ; endif
        if BUD->IsSum == BUTTON_ON
          nTot4 += Db2Dev(SetDevise(),LastPeriode(CTB->Periode),val(CTB->Mont))
          * nTot4 += val(CTB->Mont)
        endif
        cLine += " " + ntomf(Db2Dev(SetDevise(),LastPeriode(CTB->Periode),val(CTB->Mont)))
      if lPrint
        if BUD->IsSum == BUTTON_ON
          cLine := "{S}" + cLine + "{s}"
        endif
        PrintLine(cLine)
        if BUD->IsSum == BUTTON_ON
          PrintLine()
        endif
      endif
    endif
    skip
  enddo
close area
PrintLine(repl("ƒ",p_cpl()))
cLine := space(18)
cLine += " " + padr("Gesamtbetrag",40)
cLine += " " + ntomf(nTot1)
cLine += " " + ntomf(nTot2)
cLine += " " + ntomf(nTot3)
cLine += " " + ntomf(nTot4)
// PrintLine(cLine)
PrintLine("{B}"+cLine+"{b}")
p_eject()
RETURN NIL

FUNCTION LstRe06(cIdSbb,cDienst,cPeriode,cTitle)
local cLine
local cTit1 := padr("Artikel",18+1+40)
local cTit2 := space(18+1+40)
local cTit3 := repl("ƒ",18+1+40)
local cIdBud := "*"
local lOkay := .t.
local aSum := {}
local lPrint
local lFound
local cPrevPer := str(val(cPeriode)-1,LEN_PERIODE,0)
local aBcl
local i
local nMont
RETURN NIL if len( (aBcl := ReadArray( ;
  "R" + cPeriode + "-" + cIdSbb + ".DBC", BCL_ALEN ;
) ) ) == 0
for i := 1 to len(aBcl)
  if empty(aBcl[i][BCL_DC])
    if empty(aBcl[i][BCL_DIENST]) .or. aBcl[i][BCL_DIENST] == cDienst
      cTit1 += " " + padl(hdr1(aBcl[i][BCL_HEADER]),LenMntF())
      cTit2 += " " + padl(hdr2(aBcl[i][BCL_HEADER]),LenMntF())
      cTit3 += " " + repl("ƒ",LenMntF())
    endif
  else
    Warning("BCL_DC muss leer sein !")
  endif
  aadd(aSum,0)
next i
p_SetWidth(len(cTit3))
SetPageHeader({|| PrintHeader( ;
    MsgHaushalt("R") + " " + cPeriode, ;
    "Unterteilung " + cIdSbb, ;
    cTitle ;
  ) , ;
  PrintLine(cTit1) , ;
  PrintLine(cTit2) , ;
  PrintLine(cTit3)   ;
})
open area oBud(), oCtb()
  ddSetOrder(ORD_BUD_HH)
  softseek cIdSbb
  do while lOkay .and. ! eof() .and. BUD->SubBud == cIdSbb
    if TaskInter() ; lOkay := .f. ; exit ; endif
    if BUD->IdBud != cIdBud
      cIdBud := BUD->IdBud
      cLine := SayIdBud(BUD->IdBud)
      cLine += " " + padr(BUD->Name1,40)
      for i := 1 to len(aBcl)
        if empty(aBcl[i][BCL_DC])
          if empty(aBcl[i][BCL_DIENST]) .or. aBcl[i][BCL_DIENST] == cDienst
            nMont := &(aBcl[i][BCL_EXPR])
            cLine += " " + ntomf(nMont)
            if BUD->IsSum == BUTTON_OFF
              aSum[i] += nMont
            endif
            if nMont != 0
              lPrint := .t.
            endif
          endif
        endif
      next
      if BUD->IsSum == BUTTON_ON
        cLine := "{S}" + cLine + "{s}"
      endif
      PrintLine(cLine)
      if BUD->IsSum == BUTTON_ON
        PrintLine()
      endif
    endif
    skip
  enddo
close area
PrintLine(repl("ƒ",p_cpl()))
cLine := "999   Gesamtbetrag"
cLine := padr(cLine,18+1+40)
for i := 1 to len(aBcl)
  if empty(aBcl[i][BCL_DC])
    if empty(aBcl[i][BCL_DIENST]) .or. aBcl[i][BCL_DIENST] == cDienst
      cLine += " " + ntomf(aSum[i])
    endif
  endif
next i
PrintLine("{B}"+cLine+"{b}")
p_eject()
RETURN NIL


FUNCTION LstRe08bis(cIdJnl,cPeriode)
local cLine
local cIdFcb
local lPrinted
local cGruppe
local cTit1 := ""
local cTit2 := ""
local nSumFcb
local nPad
local nSumGruppe
local nMont
cTit1 := padr("Artikel",18)
cTit2 := repl("ƒ",18)
cTit1 += " " + padr("Bezeichnung",40)
cTit2 += " " + repl("ƒ",40)
cTit1 += " " + padr("Dok.Nr.",LenIdDoc()+LenIdJnl()+2+LEN_POS)
cTit2 += " " + repl("ƒ",LenIdDoc()+LenIdJnl()+2+LEN_POS)
nPad := len(cTit2)
cTit1 += " " + padl("Betrag",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
p_SetWidth(len(cTit2))
SetPageHeader({|| PrintHeader( ;
    "Rechnung " + scPeriode, ;
    "Unterteilung 08bis", ;
    "Interne Kreditanpassungen" ;
  ) , ;
  PrintLine(cTit1) , ;
  PrintLine(cTit2)   ;
})
open area oMvi(), oBud()
  ddSetOrder(ORD_MVI_BUDDATE)
  go top
  do while LstContinue() .and. ! eof()
    cIdFcb := substr(MVI->IdBud,3,5)
    nSumFcb := 0
    do while LstContinue() .and. ! eof() ;
             .and. cIdFcb == substr(MVI->IdBud,3,5)
      cGruppe := substr(MVI->IdBud,3+5,2)
      nSumGruppe := 0
      lPrinted := .f.
      do while LstContinue() .and. ! eof() ;
               .and. cIdFcb == substr(MVI->IdBud,3,5) ;
               .and. cGruppe == substr(MVI->IdBud,3+5,2)
        if TaskInter() ; LstError(PRN_ABORT) ; exit ; endif
        if PerPerCtr(MVI->Periode) == cPeriode
          if MVI->IdJnl == cIdJnl
            if ! lPrinted
              PrintLine("Funktion " + trim(cIdFcb) + ", Kreditgruppe " + cGruppe)
            endif
            lPrinted := .t.
            cLine := SayIdBud(MVI->IdBud)
            cLine += " " + BudName(MVI->DC,MVI->IdBud)
            cLine += " " + MVI->IdJnl + " " + MVI->IdDoc + "." + MVI->Line
            nMont := Db2Dev(SetDevise(),MVI->Periode,val(MVI->Mont))
            cLine += " " + ntomf(nMont)
            nSumFcb += nMont
            nSumGruppe += nMont // val(MVI->Mont)
            PrintLine(cLine)
          endif
        endif
        skip
      enddo
      if lPrinted
        cLine := padr("‰ Kreditgruppe " + cGruppe,nPad)
        cLine += " " + str(nSumGruppe,LenMntF())
        PrintLine(cLine)
        PrintLine()
      endif
    enddo
    * if nSumFcb != 0
    *   cLine := padr("Summe " + cIdFcb,50+LenIdJnl()+LenIdDoc())
    *   cLine += " " + ntomf(nSumFcb)
    *   PrintLine(cLine)
    * endif
  enddo
close area
p_eject()
RETURN NIL

FUNCTION LstRe11(cIdJnl,cIdTpl)
local nPad
local cTit1 := ""
* local cTit2 := ""
local cTit3 := ""
* local cDC
* local cIdBud
local cLine
local nMont
local nMviMont
local nTotMont := 0
cTit1 := padr("Artikel",18)
* cTit2 := space(18)
cTit3 := repl("ƒ",18)
*
cTit1 += " " + padr("Partner",LenIdPar())
* cTit2 += " " + space(LenIdPar())
cTit3 += " " + repl("ƒ",LenIdPar())
*
nPad := len(cTit3)
*
cTit1 += " " + padl("Betrag",LenMntF())
* cTit2 += " " + padl("",LenMntF())
cTit3 += " " + repl("ƒ",LenMntF())
*
cTit1 += " " + padr("Grund",30)
* cTit2 += " " + space(30)
cTit3 += " " + repl("ƒ",30)
*
cTit1 += " " + padr("Dok.Nr.",LenIdDoc()+LenIdJnl()+1)
* cTit2 += " " + space(LenIdDoc()+LenIdJnl()+1)
cTit3 += " " + repl("ƒ",LenIdDoc()+LenIdJnl()+1)
*
p_SetWidth(len(cTit3))
SetPageHeader({|| PrintHeader( ;
    "Rechnung " + scPeriode, ;
    "Unterteilung 11", ;
    "Liste der uneintreibbaren Anrechte" ;
  ) , ;
  PrintLine(cTit1) , ;
  PrintLine(cTit3)   ;
})
open area oBud()
  go top
  do while ! eof() .and. LstContinue()
    nMont  := 0
    open area oMvi(), oImp()
      ddSetOrder(ORD_MVI_BUDJNL)
      softseek BUD->DC + BUD->IdBud + cIdJnl
      do while ! eof() .and. MVI->IdBud == BUD->IdBud ;
                       .and. MVI->DC == BUD->DC ;
                       .and. MVI->IdJnl == cIdJnl ;
                       .and. LstContinue()
        if PerPerCtr(MVI->Periode) == scPeriode
          nMviMont := Db2Dev(SetDevise(),MVI->Periode,val(MVI->Mont))
          seek MVI->IdJnl + MVI->IdDoc in IMP
          cLine := padr(SayIdBud(MVI->IdBud),18)
          cLine += " " + MVI->IdPar
          cLine += " " + ntomf(nMviMont)
          cLine += " " + padr("Beschluss des Sozialhilferats",30)
          * cLine += " " + IMP->NB1
          cLine += " " + trim(MVI->IdJnl)
          cLine += " " + MVI->IdDoc
          PrintLine(cLine)
          nMont += nMviMont
        endif
        if TaskInter() ; LstError(PRN_ABORT) ; exit ; endif
        skip
      enddo
    close area
    if nMont != 0
      cLine := "Summe " + trim(SayIdBud(BUD->IdBud)) + " :"
      cLine := padr(cLine,nPad)
      cLine += " " + ntomf(nMont)
      PrintLine(space(nPad) + " " + repl("ƒ",LenMntF()))
      PrintLine(cLine)
      PrintLine()
      nTotMont += nMont
    endif
    skip
  enddo
  cLine := "Gesamtsumme "
  cLine := padr(cLine,nPad)
  cLine += " " + ntomf(nTotMont)
  PrintLine(space(nPad) + " " + repl("ƒ",LenMntF()))
  PrintLine(cLine)
close area
TplInclude("HHR",cIdTpl)
p_eject()
RETURN NIL


FUNCTION LstRe12(cDC,cDienst,cTitle)
* local lPrint
local aSum := {}
local aBcl
local i
local cLine
local nMont
local cTit1
local cTit2
local cTit3
RETURN NIL if ! LstContinue()
RETURN NIL if len( (aBcl := ReadArray( ;
  "RE12.DBC", BCL_ALEN, NIL, NIL, ;
  {|x| x[BCL_DC] == cDC .and. x[BCL_DIENST] == cDienst } ;
) ) ) == 0
cTit1 := padr("Artikel",18+1+40)
cTit2 := space(18+1+40)
cTit3 := repl("ƒ",18+1+40)
for i := 1 to len(aBcl)
  * if aBcl[i][BCL_DC] == cDC
    * if empty(aBcl[i][BCL_DIENST]) .or. aBcl[i][BCL_DIENST] == cDienst
      cTit1 += " " + padl(hdr1(aBcl[i][BCL_HEADER]),LenMntF())
      cTit2 += " " + padl(hdr2(aBcl[i][BCL_HEADER]),LenMntF())
      cTit3 += " " + repl("ƒ",LenMntF())
    * endif
  * endif
  aadd(aSum,0)
next i
p_SetWidth(len(cTit3))
SetPageHeader({|| ;
  PrintHeader( ;
    MsgHaushalt("R") + " " + scPeriode, ;
    "Unterteilung 12", ;
    cTitle ;
  ), ;
  PrintLine(cTit1), ;
  PrintLine(cTit2), ;
  PrintLine(cTit3) ;
} )
open area oBud(), oCtb()
  softseek cDC
  do while ! eof() .and. BUD->DC == cDC .and. LstContinue()
    if BUD->Service == cDienst
      if BUD->IsSum == BUTTON_OFF
        if ! BUDATTR_H $ BUD->Attrib
          if &(atail(aBcl)[BCL_EXPR]) != 0
            cLine := padr(SayIdBud(BUD->IdBud),18)
            cLine += " " + BUD->Name1
            for i := 1 to len(aBcl)
              nMont := &(aBcl[i][BCL_EXPR])
              cLine += " " + ntomf(nMont)
              aSum[i] += nMont
            next i
            PrintLine(cLine)
          endif
        endif
      endif
    endif
    skip
  enddo
close area
PrintLine(repl("ƒ",p_cpl()))
cLine := "999   Gesamtbetrag"
cLine := padr(cLine,18+1+40)
for i := 1 to len(aBcl)
  cLine += " " + ntomf(aSum[i])
next i
PrintLine(cLine)
TplInclude("HHR",padr("R12"+cDC,LenIdTpl()))
p_eject()
RETURN NIL

FUNCTION Re12Detail(lDlg,cDC,cPeriode,cxBudFilter,cxSum,cTitle)
local lPrinted
local aSum := {}
local aBudSum := {}
local aBcl
local i
local cLine
local cBudLine
local nMont
local nPad
local cTit1
local cTit2
local aCdc := CdcList(cDC,{|x|x[CDC_IDCDC] == MemIdCdc })
local jnl
local cIdBud1 := space(LenIdBud())
local cIdBud2 := space(LenIdBud())
*if lDlg
*  cIdBud1 := SayIdBud(trim(cIdBud1))
*  cIdBud2 := SayIdBud(trim(cIdBud2))
*  cxSum := padr(cxSum,120)
*  cxBudFilter := padr(cxBudFilter,120)
*  open window (cTitle) size 11,62 help CDCMVILI
*  SayGetPeriode()
*  say "Artikel von "
*  get cDC picture PIC_ID valid DcValidate(cDC)
*  say " "
*  get cIdBud1 picture PIC_ID pick PickBudSay(cDC,cIdBud1) ;
*                             postedit {|x| SayIdBud(GetIdBud(x))}
*  say "    bis "
*  get cIdBud2 picture PIC_ID pick PickBudSay(cDC,cIdBud2) ;
*                             postedit {|x| SayIdBud(GetIdBud(x))}
*  WinCr()
*  say "cxSum       "
*  get cxSum picture "@k@s30"
*  WinCr()
*  say "cxBudFilter "
*  get cxBudFilter picture "@k@s30"
*  WinCr()
*  SetTplIni("LISTE")
*  GetTplIni()
*  GetPreview()
*  nKey := ReadScr()
*  close window
*  RETURN .f. if nKey == K_ESC
*  cIdBud1 := GetIdBud(cIdBud1)
*  cIdBud2 := GetIdBud(cIdBud2)
*  cxSum := trim(cxSum)
*  cxBudFilter := trim(cxBudFilter)
*endif
RETURN NIL if ! LstContinue()
cTit1 := padr("Datum",len(dtoc(UserDate())))
cTit2 := repl("ƒ",len(dtoc(UserDate())))
cTit1 += " " + padr("Dokument",LenIdJnl()+LEN_IDDOC+LEN_POS+2)
cTit2 += " " + repl("ƒ",LenIdJnl()+LEN_IDDOC+LEN_POS+2)
cTit1 += " " + padr("Partner",LenIdPar())
cTit2 += " " + repl("ƒ",LenIdPar())
nPad := len(cTit2)
for i := 1 to len(aCdc)
  cTit1 += " " + padl(aCdc[i][CDC_HEADER],LenMntF())
  cTit2 += " " + repl("ƒ",LenMntF())
  aadd(aSum,0)
  aadd(aBudSum,0)
next i
p_SetWidth(100)
* p_SetWidth(len(cTit2))
SetPageHeader({|| ;
  PrintHeader( ;
    MsgHaushalt("R") + " " + scPeriode, ;
    "Unterteilung 12 (Detail)", ;
    cTitle ;
  ), ;
  PrintLine(cTit1), ;
  PrintLine(cTit2) ;
} )
open area oBud(), oMvi()
  softseek cDC + trim(cIdBud1)
  MVI->(ddSetOrder(ORD_MVI_BUDDATE))
  // 20070814 set order to ORD_MVI_BUDDATE in MVI
  do while LstContinue() .and. ! eof() .and. BUD->DC == cDC
    if ! empty(cIdBud2)
      if MVI->IdBud > cIdBud2
        exit
      endif
    endif
    if &cxBudFilter
      for i := 1 to len(aCdc)
        aBudSum[i] := 0
      next i
      lPrinted := .f.
      select MVI
      softseek BUD->DC + BUD->IdBud
      do while LstContinue() .and. ! eof() ;
                             .and. MVI->IdBud == BUD->IdBud ;
                             .and. MVI->DC == BUD->DC
        if PerPerCtr(MVI->Periode) == cPeriode
        * if ChkPeriode(MVI->Periode) == 0
          if (jnl := JnlLocate(MVI->IdJnl)) != NIL
            if ! empty(jnl[JNL_IDCDC])
              nMont := &cxSum
              if JNLATTR_N $ jnl[JNL_ATTRIB]
                nMont := - nMont
              endif
              if nMont != 0
                if ! lPrinted
                  cLine := padr(SayIdBud(BUD->IdBud),18)
                  cLine += " " + trim(FcbName(BUD->IdFcb))
                  cLine += " : " + trim(BUD->Name1)
                  PrintLine()
                  PrintLine("{B}"+cLine+"{b}")
                  PrintLine()
                  lPrinted := .t.
                endif
                cLine := dtoc(MVI->Date)
                cLine += " " + MVI->IdJnl
                cLine += " " + MVI->IdDoc
                cLine += "." + MVI->Line
                cLine += " " + MVI->IdPar
                for i := 1 to len(aCdc)
                  if aCdc[i][CDC_IDCDC] == jnl[JNL_IDCDC]
                    cLine   += " " + ntomf(nMont)
                    aBudSum[i] += nMont
                  else
                    cLine += " " + space(LenMntF())
                  endif
                next i
                PrintLine(cLine)
              endif
            endif
          endif
        endif
        if TaskInter() ; LstError(PRN_ABORT) ; exit ; endif
        skip
      enddo
      select BUD
      if lPrinted
        PrintLine(space(nPad+1) + repl("ƒ",(LenMntF()+1)*len(aCdc)-1))
        cLine := "Gesamt " + trim(SayIdBud(BUD->IdBud))
        cLine := padr(cLine,nPad)
        for i := 1 to len(aCdc)
          cLine += " " + ntomf(aBudSum[i])
          aSum[i] += aBudSum[i]
        next i
        PrintLine(cLine)
      endif
    endif
    skip
  enddo
close area
PrintLine(repl("ƒ",p_cpl()))
cLine := "999   Gesamtbetrag"
cLine := padr(cLine,nPad)
for i := 1 to len(aCdc)
  cLine += " " + ntomf(aSum[i])
next i
PrintLine(cLine)
TplInclude("HHR",padr("R12D"+cDC,LenIdTpl()))
p_eject()
RETURN NIL




FUNCTION hdr1(c)
local nPos := at(";",c)
RETURN c if nPos == 0
RETURN left(c,nPos-1)

FUNCTION hdr2(c)
local nPos := at(";",c)
RETURN "" if nPos == 0
RETURN substr(c,nPos+1)



**
** ImpAuto() - Jahresabschluss und öbertrag
**
FUNCTION ImpAuto(lDebug)
local lToggle := .f.
local grb
local fd
local cLine
local aImlSuite := {}
local aLines := {}
local aCtb      := {}
local aLni
local aBuf
local i
local nMont
local nMviCount
local srv
local aIml := {}
local cIdDoc
local cDC
local cIdBud
local cIdLnk
static MSG_CLOSE := "Jahresabschluss und öbertrag"
local nCount := 0
local lOkay := .f.
static cDoit := BUTTON_OFF
local jnlClose
local jnlHH
local jnlReport
local cTit1 := ""
local cTit2 := ""
local cName
static cIdCtr
static cPeriode1
static cPeriode2
static cIdJnlClo
static cIdJnlHH
static cIdBud1
static cIdBud2
default cIdCtr to space(1)
default cIdBud1 to space(LenIdBud())
default cIdBud2 to space(LenIdBud())
default cPeriode1 to str(year(UserDate())-1901,LEN_YEAR) + "99"
default cPeriode2 to str(year(UserDate())-1900,LEN_YEAR) + "00"
default cIdJnlClo to padr("CLO",LenIdJnl())
default cIdJnlHH  to padr("HHö",LenIdJnl())
default lDebug to .f.
cIdBud1 := SayIdBud(trim(cIdBud1))
cIdBud2 := SayIdBud(trim(cIdBud2))
if file(DbPath() + "\IMPAUTO.ERR")
  Warning( ;
    "Diese Funktion ist momentan gesperrt !", ;
    "(zuerst die IMPAUTO.ERR lîschen)" ;
  )
  RETURN .f.
endif
do while .t.
  open window (MSG_CLOSE) size 11,62 help IMPAUTO
  SayGetPeriode()
  say "Artikel von "
  get cIdCtr picture PIC_ID valid DcValidate(cIdCtr)
  say " "
  get cIdBud1 picture PIC_ID pick PickBudSay(cIdCtr,cIdBud1) ;
                             postedit {|x| SayIdBud(GetIdBud(x))}
  say "    bis "
  get cIdBud2 picture PIC_ID pick PickBudSay(cIdCtr,cIdBud2) ;
                             postedit {|x| SayIdBud(GetIdBud(x))}
  WinCr()
  get cDoit checkbox
  say " Dokumente erstellen : "
  WinCr()
  say "Abschlussdokumente in Periode "
  get cPeriode1 picture PIC_ID pick PickPer(cPeriode1)
  say ", Journal "
  get cIdJnlClo picture PIC_ID pick PickIdJnl("IMP",cIdJnlClo)
  WinCr()
  say "öbertragdokumente in Periode "
  get cPeriode2 picture PIC_ID pick PickPer(cPeriode2)
  WinCr()
  say "Haushaltsdokument in Journal "
  get cIdJnlHH picture PIC_ID pick PickIdJnl("IMP",cIdJnlHH)
  WinCr()
  SetTplIni("LISTE")
  GetTplIni()
  GetPreview()
  nKey := ReadScr()
  close window
  RETURN .f. if nKey == K_ESC
  if ! JnlExist(cIdJnlClo)
    Warning(SetMsg())
    loop
  endif
  if ! JnlExist(cIdJnlHH)
    Warning(SetMsg())
    loop
  endif
  if DevDefault(cPeriode1) != DevDefault(cPeriode2)
    if ! Confirm( "Also Konvertierung " + ;
      DevDefault(cPeriode1) +"/"+ DevDefault(cPeriode2) + ".",;
      MsgSure())
      loop
    endif
    lToggle := .t.
  endif
  exit
enddo
if !lDebug .or. Warning(;
  "Wir sind im Debug-Modus, also kommen mehr Meldungen")
endif
RETURN .f. if (jnlClose := JnlLocate(cIdJnlClo)) == NIL
RETURN .f. if (jnlHH := JnlLocate(cIdJnlHH)) == NIL
cName := "öbertrag " + cPeriode1 + "-" + cPeriode2
cIdBud1 := GetIdBud(cIdBud1)
cIdBud2 := GetIdBud(cIdBud2)
if cDoit == BUTTON_ON
  RETURN .f. if ! Confirm( ;
    "HABEN SIE EIN BACKUP DER DATENBANK (J/N) ?", ;
    NIL, MSG_NO ;
  )
endif
if (fd := fcreate(DbPath() + "\IMPAUTO.ERR")) == -1
  Warning("IMPAUTO.ERR " + MsgDosError(ferror()))
  RETURN .f.
endif
if ! LockData(MSG_CLOSE)
  fclose(fd)
  RETURN .f.
endif
if cDoit == BUTTON_ON
  SendConsole("ImpAuto() wurde DEFINITV gestartet.")
endif
SendConsole(DbPath() + "\IMPAUTO.ERR wurde erstellt")
* cTit1 += padr("Artikel",19)
cTit1 += padr("Dokument",LenIdJnl() + LEN_IDDOC + 1)
cTit1 += " " + padr("Peri",LEN_PERIODE)
cTit1 += " " + padl("offen",LenMont())
if cDoit == BUTTON_ON
  cTit1 += " " + "erstellte Dokumente :"
else
  cTit1 += " " + "(Beanstandungen)"
endif
* cTit2 += repl("ƒ",19)
cTit2 += repl("ƒ",LenIdJnl() + LEN_IDDOC + 1)
cTit2 += " " + repl("ƒ",LEN_PERIODE)
cTit2 += " " + repl("ƒ",LenMont())
cTit2 += " " + repl("ƒ",70)
open area oMvi(), oBud(), oImp()
  ddSetOrder(ORD_MVI_BUDDATE)
  if empty(cIdCtr)
    go bottom
  else
    KeyGoBottom(cIdCtr+trim(cIdBud2),"MVI->DC+MVI->IdBud")
  endif
  lOkay := .t.
  do while lOkay .and. ! bof() .and. ! eof()
    if ! empty(cIdCtr)
      if MVI->DC != cIdCtr
        exit
      endif
    endif
    if ! empty(cIdBud1)
      if MVI->IdBud < cIdBud1
        exit
      endif
    endif
    cDC    := MVI->DC
    cIdBud := MVI->IdBud
    nMont := 0
    nMviCount := 0
    if BudExist(MVI->DC,MVI->IdBud)
      if (srv := SrvLocate(BUD->Service)) != NIL
        fwrite(fd, MVI->DC + "-" + trim(SayIdBud(MVI->IdBud)))
        fwrite(fd, " : " + trim(BUD->Name1))
        fwrite(fd, " (" + BUD->CodTot)
        fwrite(fd, "/" + BUD->SubBud + ")")
        fwrite(fd, CR_LF)
        do while ! bof() .and. MVI->IdBud == cIdBud .and. MVI->DC == cDC
          MsgDisp2(ntrim0(nCount++ / lastrec() * 100) + "%")
          if ! empty(MVI->MontUs)
            if ChkPeriode(MVI->Periode) == 0
              nMont += val(MVI->MontUs)
              nMviCount ++
              cIdLnk := MVI->Match
              aLines := {}
                * MVI->DC + "-" + SayIdBud(MVI->IdBud) + ;
              fwrite(fd, ;
                padr(MsgIdJnlDoc(),LenIdJnl() + LEN_IDDOC + 1) + " " + ;
                MVI->Periode + " " + MVI->MontUs ;
              )
              if JnlIdCdc(MVI->IdJnl) != MemIdCdc
                fwrite(fd, " ! " + MVI->IdJnl + ;
                  " zentralisiert nicht nach " + MemIdCdc ;
                )
              else
                aIml := {}
                MviImlCollect(aIml,.f.)
                if len(aIml) == 1
                  if cDoit == BUTTON_ON
                    if (jnlReport := JnlLocate(MVI->IdJnl)) != NIL
                      #ifdef DEF_LNK
                      MviLniCollect(cIdLnk,cName)
                      #endif
                      open area oImp(), oIml()
                        aIml[1][IML_DATE] := UserDate()
                        **
                        ** zuerst das Abschlussdokument
                        **
                        aImlSuite := {}
                        aCtb      := {}
                        if DocCreate(jnlClose, ;
                          {|x| cIdDoc := x, ;
                          ImpAppend( jnlClose,x,aIml,aCtb, ;
                            cPeriode1, UserDate(), UserDate(), ;
                            aImlSuite, aLines ;
                          ) ;
                        } ) == DDCREATE_DONE
                          fwrite(fd, ;
                            " " + jnlClose[JNL_IDJNL] + " " + cIdDoc ;
                          )
                          #ifdef DEF_LNK
                            LniCollect( ;
                              cIdLnk, ;
                              jnlClose[JNL_IDJNL], ;
                              cIdDoc, ;
                              NIL,NIL,cName ;
                            )
                          #endif
                        endif
                        if ! CtbUpdate(aCtb)
                          aadd(aLines, ;
                            jnlClose[JNL_IDJNL] +  " " + cIdDoc ;
                            + " : CtbUpdate() failed !" ;
                          )
                        endif

                        **
                        ** dann evtl. den Vorjahresartikel erstellen...
                        ** "Eierlegen"
                        open area oBud()
                          if SRVATTR_K $ srv[SRV_ATTRIB]
                            seek aIml[1][IML_DC] + ;
                              NewIdBud(aIml[1][IML_IDBUD],cPeriode1)
                            if eof()
                              seek aIml[1][IML_DC] + aIml[1][IML_IDBUD]
                              if eof()
                                aadd(aLines, ;
                                  " ! Artikel " + ;
                                  aIml[1][IML_DC] + aIml[1][IML_IDBUD] + ;
                                  " existiert nicht !")
                              else
                                aBuf := CopyRec()
                                if dbAddRec()
                                  PasteRec(aBuf)
                                  BUD->IdBud := NewIdBud(;
                                    aIml[1][IML_IDBUD],cPeriode1)
                                  BUD->DatCrea  := UserDate()
                                  BUD->IdFcb := "000"
                                  if ! empty(srv[SRV_CODTOT])
                                    BUD->CodTot := srv[SRV_CODTOT]
                                    if (grb := GrbLocate(;
                                        BUD->CodTot)) == NIL
                                      Warning( ;
                                        SayIdBud(BUD->IdBud) ;
                                        + " : " + srv[SRV_CODTOT] ;
                                        + " : BUD->CodTot falsch !" ;
                                      )
                                    else
                                      BUD->GrbPos := grb[GRB_POS]
                                    endif
                                  endif
                                  if ! empty(srv[SRV_SUBBUD])
                                    BUD->SubBud  := srv[SRV_SUBBUD]
                                  endif
                                  if BUD->DC == DC_DEBIT
                                    BUD->IdBud_S   := srv[SRV_IDBUD_D]
                                  else
                                    BUD->IdBud_S   := srv[SRV_IDBUD_C]
                                  endif
                                  unlock record
                                endif
                              endif
                            elseif ddRecLock()
                              if ! empty(srv[SRV_CODTOT])
                                BUD->CodTot := srv[SRV_CODTOT]
                              endif
                              if ! empty(srv[SRV_SUBBUD])
                                BUD->SubBud  := srv[SRV_SUBBUD]
                              endif
                              * if BUD->DC == DC_DEBIT
                              *   BUD->IdBud_S   := srv[SRV_IDBUD_D]
                              * else
                              *   BUD->IdBud_S   := srv[SRV_IDBUD_C]
                              * endif
                              unlock record
                            else
                              fwrite(fd, ;
                                BUD->IdBud + " : ddRecLock() failed" ;
                              )
                            endif
                            aIml[1][IML_IDBUD] := ;
                              NewIdBud(aIml[1][IML_IDBUD],cPeriode1)
                          endif
                        close area
                        aIml[1][IML_PERIODE] := cPeriode2
                        aIml[1][IML_MATCH]   := ""

                        ** Konvertierung BEF/EUR
                        ** Wiedererîffnung HH und Journal: die beiden
                        ** mÅssen evtl. von BEF nach EUR konvertiert werden

                        if lToggle
                          aIml[1][IML_MONT] := ntom(;
                            Db2Dev(;
                              DevDefault(cPeriode2),;
                              cPeriode1,;
                              val(aIml[1][IML_MONT])),;
                            DevDecPos(DevDefault(cPeriode2));
                          )
                          // 20011221 : und was ist mit IML_MONTDEV ?
                        endif

                        **
                        ** Wiedererîffnung Haushalt
                        **
                        if SRVATTR_U $ srv[SRV_ATTRIB]
                          aImlSuite := {}
                          aCtb      := {}
                          if DocCreate(jnlHH, ;
                            {|x| cIdDoc := x, ;
                            ImpAppend( ;
                              jnlHH,x,aIml,aCtb, ;
                              cPeriode2, UserDate(), UserDate(), aImlSuite, ;
                              aLines ;
                            ) ;
                          } ) == DDCREATE_DONE
                            fwrite(fd, ;
                              " " + jnlHH[JNL_IDJNL] + " " + cIdDoc  ;
                            )
                            aIml[1][IML_MATCH] := jnlHH[JNL_IDJNL] + cIdDoc + padl("1",LEN_POS,"0")
                            #ifdef DEF_LNK
                              LniCollect( ;
                                cIdLnk,jnlHH[JNL_IDJNL],cIdDoc,;
                                NIL,NIL,cName ;
                              )
                            #endif
                          endif
                          if ! CtbUpdate(aCtb)
                            aadd(aLines, ;
                              jnlHH[JNL_IDJNL] +  " " + cIdDoc ;
                              + " : CtbUpdate() failed !" ;
                            )
                          endif
                        endif

                        **
                        ** Wiedererîffnung Journal
                        **
                        aImlSuite := {}
                        aCtb      := {}
                        if DocCreate(jnlReport, ;
                          {|x| cIdDoc := x, ;
                          ImpAppend( ;
                            jnlReport,x,aIml,aCtb, ;
                            cPeriode2, MVI->Date1, MVI->Date2, aImlSuite, ;
                            aLines, MviDate3(), MviMemo() ;
                          ) ;
                        } ) == DDCREATE_DONE
                          fwrite(fd, ;
                            " " + jnlReport[JNL_IDJNL] + " " + cIdDoc ;
                          )
                          #ifdef DEF_LNK
                            LniCollect( ;
                              cIdLnk,jnlReport[JNL_IDJNL],cIdDoc, ;
                                NIL,NIL,cName ;
                            )
                          #endif
                        endif
                        if ! CtbUpdate(aCtb)
                          aadd(aLines, ;
                            jnlReport[JNL_IDJNL] +  " " + cIdDoc ;
                            + " : CtbUpdate() failed !" ;
                          )
                        endif
                      close area
                    else
                      Warning("Das kann nicht sein...")
                    endif
                  endif
                else
                  Warning("len(aIml) != 1 : Das kann wirklich nicht sein...")
                endif
              endif
              fwrite(fd, CR_LF )
              for i := 1 to len(aLines)
                fwrite(fd,aLines[i] + CR_LF)
              next i
            endif
          endif
          skip -1
        enddo
        if nMviCount > 0
          open area oBud()
            seek cDC + cIdBud
            fwrite(fd,cDC+"-"+trim(SayIdBud(cIdBud)))
            fwrite(fd, " : " + trim(BUD->Name1))
            fwrite(fd, " (" + BUD->CodTot)
            fwrite(fd, "/" + BUD->SubBud)
            fwrite(fd,") Gesamtbetrag = " + ltrim(ntom(nMont)))
            fwrite(fd, CR_LF)
            fwrite(fd, CR_LF )
          close area
        endif
      else
        fwrite(fd, SayIdBud(BUD->IdBud) + " : falscher Dienst !"+CR_LF)
        lOkay := .f.
      endif
    else
      fwrite(fd, MVI->IdJnl+MVI->IdDoc+MVI->Line;
        +": unbekannter Artikel "+SayIdBud(MVI->IdBud) + " !"+CR_LF)
      lOkay := .f.
    endif
  enddo
close area
UnlockData()
if !lDebug .or. Confirm("Beanstandungen drucken (J/N)?")
  fseek(fd,0)
  open printer SetTplIni() preview SetPreview() ;
       width len(cTit2) ;
       titblock {|| PrintHeader( ;
           MSG_CLOSE + " " + cPeriode1 + " -> " + cPeriode2, ;
           PerText({||.f.}), ;
         ), ;
         PrintLine(cTit1), ;
         PrintLine(cTit2)  ;
       }
  do while (cLine := freadline(fd)) != NIL
    PrintLine(cLine)
  enddo
  close printer
endif
fclose(fd)
if cDoIt == BUTTON_OFF
  if !lDebug .or. Confirm("IMAUTO.ERR lîschen (J/N)?")
    delete file (DbPath() + "\IMPAUTO.ERR")
  endif
endif
RETURN MnuDone()


FUNCTION NewIdBud(cIdBud,cPeriode)
RETURN cIdBud if ! empty(left(cIdBud,LEN_YEAR))
RETURN left(cPeriode,LEN_YEAR) + substr(cIdBud,LEN_YEAR+1)

FUNCTION LstPeriode(nOffset)
RETURN scPeriode if nOffset == NIL
RETURN str(val(scPeriode)+nOffset,len(scPeriode))

FUNCTION ImpImlField(bField)
local u := NIL
open area oIml()
  softseek IMP->IdJnl + IMP->IdDoc
  if IML->IdJnl + IML->IdDoc != IMP->IdJnl + IMP->IdDoc
    goto lastrec() + 1
  endif
  u := eval(bField)
close area
RETURN u

#endif DEF_IMP


**
** DcValidate()
**
FUNCTION DcValidate(cDC,jnl,nRow,nCol)
if cDC == DC_DEBIT .or. cDC == DC_CREDIT
  if jnl != NIL
    if cDC == jnl[JNL_DC]
      @ nRow, nCol say padr(jnl[JNL_DOCLIB1],25)
    else
      @ nRow, nCol say padr(jnl[JNL_DOCLIB1N],25)
    endif
  endif
  RETURN .t.
endif
#ifdef DEF_IMP
  SetMsg(cDC + " : ungÅltige Buchungsrichtung ! Geben Sie 'A' oder 'E' ein.")
#else
  SetMsg(cDC + " : ungÅltige Buchungsrichtung ! Geben Sie 'D' oder 'C' ein.")
#endif
RETURN .f.

#ifdef DEF_DEV

FUNCTION SetDevise(cIdDev)
local dev
RETURN scIdDev if cIdDev == NIL
dev := DevLocate(cIdDev)
if dev == NIL
  SetMsg(cIdDev + MsgDevExist())
  RETURN .f.
endif
scIdDev := cIdDev
SetDecPos(dev[DEV_DECPOS]) // DevDecPos(cIdDev))
RETURN .t.

#endif DEF_DEV
