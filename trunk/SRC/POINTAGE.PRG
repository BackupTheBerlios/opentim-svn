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
#include "DEFDATA.CH"

#ifdef DEF_PTG

#define LEN_IDRES 8

static saPtlBuf := NIL


**
** RES - Resources
**
FUNCTION oRes()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                  ;
  name RES                          ;
  editprint PtlListe(RES->IdRes)
  ddIndex b on RES->IdRes
  ddFld IdRes  ,C, LEN_IDRES,0 picture PIC_ID
  ddFld Nom1   ,C,30,0
  ddFld Nom2   ,C,30,0
  ddFld Nom3   ,C,30,0
  ddFld QteW   ,C, 6,0 picture PIC_MONTANT postedit {|x| GetTime(x) }
  ddFld QteM   ,C, 6,0 picture PIC_MONTANT postedit {|x| GetTime(x) }
*
action b key K_ENTER prompt "Pointage [Enter]" ;
                     block ResPtlEdit()
ddEndDef()
RETURN b

**
** PTL - Lignes de pointages
**
FUNCTION oPtl()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                  ;
  name PTL                          ;
  postedit PtlPostEdit() ;
  fileprint PtlListe(PTL->IdRes)
  ddIndex b on PTL->IdRes + dtos(PTL->Date)+PTL->Qte1
  ddIndex b on dtos(PTL->Date)+PTL->Qte1
  * ddIndex b on PTL->IdTac + dtos(PTL->Date)
  ddFld IdJnl  ,C, 3,0 attrib H picture PIC_ID
  ddFld IdDoc  ,C, 6,0 attrib H picture PIC_ID
  ddFld _Jour  ,C, 3,0 attrib V block padr(Jour(PTL->Date),2)
  ddFld Date   ,D, 8,0
  ddFld Attrib ,C, 4,0 picture PIC_ID pick PickPtlAttrib(PTL->Attrib)
  ddFld Qte1   ,C, 6,0 picture PIC_MONTANT ;
                       postedit {|x| GetTime(x) }
  ddFld Qte2   ,C, 6,0 picture PIC_MONTANT   ;
                       postedit {|x| GetTime(x) }
  ddFld Qte    ,C, 6,0 picture PIC_MONTANT  ;
                       postedit {|x| GetTime(x) }
  ddFld Remarq ,C,30,0
  ddFld QteP   ,C, 6,0 picture PIC_MONTANT   ;
                       postedit {|x| GetTime(x) }
  ddFld IdRes  ,C, LEN_IDRES,0 picture PIC_ID when .f.
  ddFld Type   ,C, 2,0 picture PIC_ID ;
                       pick PickDbcCode("PTLTYPE.DBC",PTL->Type)
ddEndDef()
RETURN b


FUNCTION ResPtlEdit(cPeriode)
local cIdRes := RES->IdRes
local b := oPtl()
local nLen
default cPeriode to ""
nLen := len(cPeriode)
saPtlBuf := NIL
open area b
  edit data b key "PTL->IdRes+left(dtos(PTL->Date),"+ntrim(nLen)+")" ;
              value cIdRes + cPeriode ;
              create   {||PtlCreate(cIdRes)} ;
              mode     edit  ;
              query "PTLRES" ;
              start  bottom ;
              title ("Pointages " + trim(cIdRes) + ;
                trims(cPeriode," (in ",")"))
close area
RETURN .f.

FUNCTION PtlEdit(cPeriode,lToday)
local b := oPtl()
local nLen
default cPeriode to ""
nLen := len(cPeriode)
saPtlBuf := NIL
open area b
  edit data b key "left(dtos(PTL->Date),"+ntrim(nLen)+")" ;
              value cPeriode ;
              create   {||PtlCreate(NIL,lToday)} ;
              mode     edit  ;
              query "PTL" ;
              start  bottom ;
              title ("Pointages " + cPeriode)
close area
RETURN .f.

**
** ResEdit()
**
FUNCTION ResEdit()
local b := oRes()
open area b
  edit data b mode find  ;
              start  top     ;
              query "RES" ;
              title ("Resources")
close area
RETURN .f.

FUNCTION PickRes(x)
RETURN DbfPick(;
  {oRes()},;
  utr("Select ressource","Auswahl Ressource","Choix ressource"),;
  "RESPICK",;
  x,;
  NIL,NIL,NIL,;
  "RES->IdRes";
)


FUNCTION PtlPostedit()
if empty(PTL->Qte1) .or. empty(PTL->Qte2)
else
  PTL->Qte := ntoq( ;
    t2hours(PTL->Qte2) - ;
    t2hours(PTL->Qte1) - t2hours(PTL->QteP) , ":" ;
  )
endif
saPtlBuf := CopyRec()
RETURN .T.


**
**
**
FUNCTION PtlCreate(cIdRes,lToday) // cIdJnl,cIdDoc)
local dDate := PTL->Date
local lEOF := eof() // 20070801 recno() == lastrec()+1
if ! lEOF
  saPtlBuf := CopyRec()
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
if saPtlBuf != NIL
  PasteRec(saPtlBuf)
endif
if empty(PTL->Date)
  PTL->Date := UserDate()
elseif lEOF
  default lToday to .f.
  if ! lToday
    PTL->Date := PTL->Date + 1
  endif
endif
if !empty(cIdRes)
  PTL->IdRes  := cIdRes
endif
PtlPostEdit()
* ddRefreshAll()
* RETURN DDCREATE_EDIT
RETURN DDCREATE_REFRESH


FUNCTION DateFilter(d,cDows,cWOM,cEvenWeeks,cOddWeeks)
local nWom
local nWoy := val(left(ls_woy(d),2))
RETURN .f. if empty(cEvenWeeks) .and. nWoy/2 == int(nWoy/2)
RETURN .f. if empty(cOddWeeks) .and. nWoy/2 != int(nWoy/2)
RETURN .f. if empty(substr(cDows,dow(d),1))
if !empty(cWOM)
  nWom=val(cWom)
  if nWom > 0
    RETURN .f. if wom(d) != nWom
  else
    RETURN .f. if 1 + wom(d) - wom(LastOfMonth(d)) != nWom
  endif
endif
RETURN .t.

FUNCTION DateLoop(dVon,dBis,cDows,cWOM,cEvenWeeks,cOddWeeks,blEval)
local lOkay := .t.
local d
for d := dVon to dBis
  if DateFilter(d,cDows,cWOM,cEvenWeeks,cOddWeeks)
    if ! eval(blEval,d)
      lOkay := .f.
      exit
    endif
  endif
next d
RETURN lOkay

FUNCTION PtlGenerate(cIdRes,cType,cQte1,cQte2,;
                     dVon,dBis,cDows,cWOM,cEvenWeeks,cOddWeeks)
RETURN DateLoop(dVon,dBis,cDows,cWOM,cEvenWeeks,cOddWeeks,;
       {|d|PtlAddRec(d,cIdRes,cType,cQte1,cQte2)})


FUNCTION PtlAddRec(d,cIdRes,cType,cQte1,cQte2)
RETURN .f. if ! dbAddRec()
PTL->IdRes  := cIdRes
PTL->Date := d
PTL->Type := cType
PTL->Qte1 := cQte1
PTL->Qte2 := cQte2
if empty(PTL->Qte1) .or. empty(PTL->Qte2)
else
  PTL->Qte := ntoq( ;
    t2hours(PTL->Qte2) - ;
    t2hours(PTL->Qte1) - t2hours(PTL->QteP) , ":" ;
  )
endif
unlock record
RETURN .t.

FUNCTION TrmPtlText(dDate,cIdRes)
local s:=""
DbfScan({oPtl()},1,padr(cIdRes,LEN_IDRES)+dtos(dDate),NIL,NIL,;
  {||s+=timetrim(trim(PTL->Qte1))+"-"+timetrim(trim(PTL->Qte2));
    +" "+trim(PTL->Type)+crlf(),.t.})
RETURN s


**
** PtlListe()
**
FUNCTION PtlListe(cIdRes)
local cLine
local nWeek  := NIL
local nMonth := NIL
* local nTotW := 0
* local nTotM := 0
* local nTotSup := 0
local cTotW := "0:00"
local cTotM := "0:00"
local cTotSup := "0:00"
local cTit1 := "Date         D괷ut    Fin  Pause  Dur괻"
local cTit2 := "컴컴컴컴컴� 컴컴컴 컴컴컴 컴컴컴 컴컴컴"
local nPadDuree := len(cTit2) - 6
local aAttrStat := {}
local i
cTit1 += " Attr"
cTit2 += " 컴컴"
cTit1 += " Remarque                        "
cTit2 += " 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴"
open window ("Liste de pointage") size 3,50
  GetDateRange()
  nKey := ReadScr()
close window
RETURN MnuDone() if nKey == K_ESC
open printer "LISTE" width len(cTit2) ;
TitBlock {|| ;
  PrintHeader("Liste de pointage", ;
    if(empty(cIdRes),"alle Ressourcen",alltrim(cIdRes)),;
    MsgDateRange()) , ;
  PrintLine(cTit1) ,;
  PrintLine(cTit2)  ;
}
open area oPtl(),oRes()
  go top
  do while !eof() .and. LstContinue()
    if ChkDateRange(PTL->Date)
      if empty(cIdRes).or. PTL->IdRes == cIdRes
        seek PTL->IdRes in RES
        if ft_woy(PTL->Date) != nWeek .and. ! empty(RES->QteW)
          if nWeek != NIL
            PrintLine()
            cLine := utr("Week ","Woche ","Semaine ") + ntrim(nWeek) // code repeated below
            cLine := padr(cLine,nPadDuree) + padl(cTotW,6)
            if ! empty(RES->QteW)
              cLine += " " + ltrim(cTotSup) + " + ("
              cLine += ltrim(cTotW) + " - "
              cLine += ltrim(RES->QteW) + ") = "
              cTotSup := TimeAdd(cTotSup,TimeSubt(cTotW,RES->QteW))
              cLine += ltrim(cTotSup)
            endif
            PrintLine(cLine)
            PrintLine()
          endif
          nWeek := ft_woy(PTL->Date)
          cTotW := "0:00"
        endif
        if month(PTL->Date) != nMonth .and. ! empty(RES->QteM) // cMonthly == BUTTON_ON
          if nMonth != NIL
            PrintLine()
            cLine := utr("Month ","Monat ","Mois ") + ntrim(nMonth)
            cLine := padr(cLine,nPadDuree) + padl(cTotM,6)
            PrintLine(cLine)
            PrintLine()
          endif
          nMonth := month(PTL->Date)
          cTotM := "0:00"
        endif
        cLine := left(Jour(PTL->Date),2) + " "
        cLine += dtoc(PTL->Date) + " "
        cLine += PTL->Qte1 + " "
        cLine += PTL->Qte2 + " "
        cLine += PTL->QteP + " "
        cLine += PTL->Qte  + " "
        cLine += PTL->Attrib  + " "
        * cLine += PTL->IdTac + " "
        cLine += PTL->Remarq + " "
        PrintLine(cLine)
        cTotW := TimeAdd(cTotW,PTL->Qte)
        cTotM := TimeAdd(cTotM,PTL->Qte)
        for i := 1 to len(trim(PTL->Attrib))
          AddAttrStat(aAttrStat,substr(PTL->Attrib,i,1),PTL->Qte,PTL->Date)
        next i
      endif
    endif
    skip
  enddo
  if ! empty(cTotW) .and. ! empty(RES->QteW)
    PrintLine() 
    cLine := utr("Week ","Woche ","Semaine ") + ntrim(nWeek) // code repeated
    cLine := padr(cLine,nPadDuree) + padl(cTotW,6)
    if ! empty(RES->QteW)
      cLine += " " + ltrim(cTotSup) + " + ("
      cLine += ltrim(cTotW) + " - "
      cLine += ltrim(RES->QteW) + ") = "
      cTotSup := TimeAdd(cTotSup,TimeSubt(cTotW,RES->QteW))
      cLine += ltrim(cTotSup)
    endif
    PrintLine(cLine)
  endif
  if ! empty(cTotM) .and. ! empty(RES->QteM)
    PrintLine()
    cLine := utr("Month ","Monat ","Mois ") + ntrim(nMonth)
    * cLine := "Mois " + ntrim(nMonth)
    cLine := padr(cLine,nPadDuree) + padl(cTotM,6)
    PrintLine(cLine)
  endif
close area
if len(aAttrStat) > 0
  PrintLine()
  for i := 1 to len(aAttrStat)
    cLine := space(3)
    cLine += " " + aAttrStat[i][1]
    cLine += " " + padr(PtaName(aAttrStat[i][1]),30)
    cLine += " " + str(aAttrStat[i][2],4)
    cLine += " " + aAttrStat[i][3]
    PrintLine(cLine)
  next i
endif
close printer
* goto nRecNo
RETURN .f.

FUNCTION AddAttrStat(a,cAttrib,cQte,dDate)
local i
static sdDate
for i := 1 to len(a)
  if a[i][1] == cAttrib
    if dDate != sdDate
      a[i][2] += 1
    endif
    a[i][3] := TimeAdd(a[i][3],cQte)
    sdDate := dDate
    RETURN NIL
  endif
next i
sdDate := dDate
aadd( a, { cAttrib, 1, cQte } )
RETURN NIL

**
** PtgDetail()
**
* FUNCTION PtgDetail()
* local cIdJnl := PTG->IdJnl
* local cIdDoc := PTG->IdDoc
* local b := oPtl()
* local nQte := 0
* local cFmt := "1"
* if ":" $ JnlAttrib(PTG->IdJnl)
*   cFmt := ":"
* endif
* return MnuDone() if !ddRecLock()
* open area b, oTac()
* open window (MsgInhalt() + PTG->IdJnl + " " + PTG->IdDoc) ;
*             size 14,80 home 8,NIL ;
*             color (CfgWindowColor())
* edit data b       ;
*           key    PTL->IdJnl + PTL->IdDoc value cIdJnl + cIdDoc  ;
*           create PtlCreate(cIdJnl,cIdDoc)    ;
*           append     ;
*           start top  ;
*           mode     edit ;
*           query      1
* seek cIdJnl + cIdDoc
* do while PTL->IdDoc == cIdDoc .and. PTL->IdJnl == cIdJnl
*   * seek PTL->IdTac in TAC
*   * if "R" $ TAC->Attrib
*     nQte += qton(PTL->Qte)
*   * else
*   *   nQteB += qton(PTL->Qte)
*   * endif
*   skip
* enddo
* PTG->Qte  := ntoq(nQte,cFmt)
* close window
* close area
* RETURN .t.

#endif

FUNCTION HasPtg()
#ifdef DEF_PTG
RETURN .t.
#else
RETURN .f.
#endif


FUNCTION wom(d)
// week of month (number of week in month)
local w1 := ls_woy(FirstOfMonth(d))
local w2 := ls_woy(d)
RETURN val(left(w2,2))-val(left(w1,2))+1 if right(w1,4)==right(w2,4)
RETURN val(left(w2,2))
