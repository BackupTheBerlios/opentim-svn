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

**
** STATIC_SECTION global static variables
**

**
** MSG_SECTION    MSGnnn definitions
**
* static MSG001 := ""

**
** PROCEDURE_SECTION  - (...grins)
**

#ifdef DEF_INT

#ifdef LG_GERMAN
  #define MSG_INT_QTESTAT " : ohne Gewichtsangabe !"
#else
  #define MSG_INT_QTESTAT " : le poids n'est pas sp‚cifi‚  !"
#endif


#define HSI_IDINT    1
#define HSI_MONT     2
#define HSI_MONTDEV  3
#define HSI_QTE      4
#define HSI_QTESTAT  5
#define HSI_ALEN     5

* static snCours
static saDev
static saHsi


**
** CTI - centralisation intrastat
**
*FUNCTION oCti()
*static b := NIL
*if b != NIL ; RETURN b ; endif
*define data b                 ;
*  name CTI
*ddIndex b on  CTI->IdInt+CTI->Periode+CTI->IdJnl+CTI->NatCode+CTI->DC
*ddFld IdInt     ,C, LenIdInt(), 0
*ddFld Periode   ,C, LEN_PERIODE,0  picture PIC_ID ;
*                    pick PickPer(CTI->Periode)
*ddFld IdJnl     ,C, LenIdJnl(), 0 picture PIC_ID
*ddFld NatCode   ,C, LEN_IDNAT, 0 ;
*                    pick PickNat(CTI->IdNat,"Intrastat : Land",NAT_INTRA)
*ddFld DC        ,C, 1, 0 picture PIC_ID
*ddFld Qte       ,C, LenQte(), 0 GET_NUM
*ddFld QteStat   ,C, LenQte(), 0 GET_NUM
*ddFld Mont      ,C, LenMont(), 0 GET_MONTANT
*RETURN b


**
** INT - Intrastat-Codes
**
FUNCTION oInt()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                 ;
  name INT
ddIndex b on  INT->IdInt
ddFld IdInt     ,C, LenIdInt(), 0
ddFld Name      ,C, 60, 0
ddFld Code      ,C, 10, 0
ddFld QteForm   ,C, 1, 0
ddFld Attrib    ,C, 5, 0 picture PIC_ID ;
                         pick PickDbcAttr("INTATTR.DBC",INT->Attrib)
* #ifdef DEF_ACT
*   if IsCustData("INT") ; ActExec("INT") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

**
** HSI : Historik Intrastat
**
FUNCTION oHsi()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b   ;
  name HSI ;
  postedit HsiPostEdit()
ddIndex b on HSI->IdJnl+HSI->IdDoc+HSI->Line      // ORD_HSI_DOC
ddIndex b on HSI->IdJnl+HSI->IdNat+HSI->IdInt     // ORD_HSI_INT
ddIndex b on HSI->IdNat+HSI->IdInt+HSI->Region
ddFld IdJnl     ,C, LenIdJnl(),0 picture PIC_ID when .f.
ddFld IdDoc     ,C, LEN_IDDOC,0 picture PIC_ID when .f.
ddFld Line      ,C, LEN_POS,0  GET_NUM
ddFld IdInt     ,C, LenIdInt(),0 picture PIC_ID ;
                                 pick PickInt(HSI->IdInt)
ddFld Qte       ,C, LenQte(),0 GET_NUM
ddFld QteStat   ,C, LenQte(),0 GET_NUM
ddFld Mont      ,T, LenMont(),0 valid HsiMontValidate()
ddFld MontDev   ,T, LenMont(),0 valid HsiDevValidate()
ddFld Periode   ,C, LEN_PERIODE,0 picture PIC_ID ;
                    pick PickPer(HSI->Periode)
ddFld IdNat     ,C, LEN_IDNAT,0 picture PIC_ID ;
                    pick PickNat(HSI->IdNat,"Intrastat : Land")
ddFld Region    ,C, 1,0 picture PIC_ID ;
                    pick PickDbcCode("HSIREGIO.DBC",HSI->Region,"Intrastat : Region")
action b key K_ENTER prompt MsgMnuDocPage() ;
                     block DocPage(HSI->IdJnl,HSI->IdDoc)
* #ifdef DEF_ACT
*   if IsCustData("HSI") ; ActExec("HSI") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b


FUNCTION VenHsiInit()
RETURN .f. if (saDev := DevLocate(VEN->IdDev)) == NIL
* snCours := val(VEN->Cours)
* RETURN .f. if snCours == 0
saHsi := {}
RETURN .t.

FUNCTION HsiMontValidate
HSI->MontDev := ntom(VenDb2Dev(val(HSI->Mont)),saDev[DEV_DECPOS])
* HSI->MontDev := ntom(val(HSI->Mont) / snCours,saDev[DEV_DECPOS])
HSI->Mont    := ntom(val(HSI->Mont))
RETURN .t.

FUNCTION HsiDevValidate
HSI->Mont    := ntom(VenDev2Db(val(HSI->MontDev)))
* HSI->Mont    := ntom(val(HSI->MontDev) * snCours)
HSI->MontDev := ntom(val(HSI->MontDev),saDev[DEV_DECPOS])
RETURN .t.

FUNCTION HsiPostEdit
local nMont    := 0
local nMontDev := 0
local nQte     := 0
local nQteStat := 0
local i
if empty(HSI->Mont) .and. ! empty(HSI->IdInt)
  for i := 1 to len(saHsi)
    nQte     += saHsi[i][HSI_QTE]
    nQteStat += saHsi[i][HSI_QTESTAT]
    nMont    += saHsi[i][HSI_MONT]
    nMontDev += saHsi[i][HSI_MONTDEV]
  next i
  HSI->Qte     := ntoq(nQte,"0")
  HSI->QteStat := ntoq(nQteStat,"0")
  HSI->Mont    := ntom(nMont)
  HSI->MontDev := ntom(VenDb2Dev(nMont),saDev[DEV_DECPOS])
  * HSI->MontDev := ntom(nMont / snCours,saDev[DEV_DECPOS])
  if HSI->MontDev != ntom(nMontDev,saDev[DEV_DECPOS])
    Warning("Vorsicht : Rundungsfehler in Fremdw„hrung !")
  endif
endif
RETURN .t.

**
** HsiCreate()
**
FUNCTION HsiCreate(cIdJnl,cIdDoc,cPeriode,cIdNat)
local cLine := HSI->Line
local nCreate := DDCREATE_REFRESH
local nOrder := indexord()
ddSetOrder(1)
if eof() // 20070801 recno() == lastrec() + 1
  nCreate := DDCREATE_EDIT
endif
KeyGoBottom( cIdJnl + cIdDoc, "HSI->IdJnl+HSI->IdDoc" )
if empty(cLine)
  cLine := NextNum(HSI->Line)
else
  do while .t.
    if HSI->Line >= cLine
      if ddRecLock()
        HSI->Line := NextNum(HSI->Line)
        unlock record
      endif
    else
      exit
    endif
    skip -1
    if bof() .or. HSI->IdDoc != cIdDoc .or. HSI->IdJnl != cIdJnl
      exit
    endif
  enddo
endif
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
HSI->Line    := cLine
HSI->IdJnl   := cIdJnl
HSI->IdDoc   := cIdDoc
HSI->Periode := cPeriode
HSI->IdNat   := cIdNat
HsiPostEdit()
* unlock record
RETURN nCreate

**
** VnlHsiCollect()
**
FUNCTION VnlHsiCollect(jnl,aHsi)
local nQte     := VnlQteR() // qton1(FIELD->Qte)
local nQteStat := qton(FIELD->QteStat)
local nMont    := VenDev2Db(val(FIELD->cMont))
* local nMont    := val(FIELD->cMont) * snCours
local nMontDev := val(FIELD->cMont)
local i
local hsi
local x
RETURN .t. if empty(FIELD->IdInt)
RETURN .f. if ! IntExist(FIELD->IdInt)
if empty(FIELD->QteStat) .and. ! INTATTR_K $ INT->Attrib
  SetMsg(trim(INT->Name) + MSG_INT_QTESTAT )
  RETURN .f.
endif
// RETURN .t. if ! JNLATTR_G $ jnl[JNL_ATTRIB]
RETURN .t. if ! JNLATTR_I $ jnl[JNL_ATTRIB]
if VEN->DC != jnl[JNL_DC]
  nMont    := - nMont
  nMontDev := - nMontDev
  nQte     := - nQte
  nQteStat := - nQteStat
endif
for i := 1 to len(aHsi)
  if aHsi[i][HSI_IDINT] == FIELD->IdInt
    hsi := aHsi[i]
  endif
next i
if hsi == NIL
  hsi := array(HSI_ALEN)
  hsi[HSI_IDINT]   := FIELD->IdInt
  hsi[HSI_QTE]     := nQte
  hsi[HSI_QTESTAT] := nQteStat
  hsi[HSI_MONT]    := nMont
  hsi[HSI_MONTDEV] := nMontDev
  aadd(aHsi,hsi)
else
  hsi[HSI_QTE]     += nQte
  hsi[HSI_QTESTAT] += nQteStat
  hsi[HSI_MONT]    += nMont
  hsi[HSI_MONTDEV] += nMontDev
endif
RETURN .t.

**
** VenHsiEdit()
**
FUNCTION VenHsiEdit()
local cIdJnl := VEN->IdJnl
local cIdDoc := VEN->IdDoc
local cPeriode := VEN->Periode
local jnl := JnlLocate(cIdJnl)
local aHsi := {}
local lOkay := .f.
local a
RETURN .f. if ! VenHsiInit()
if (a := VenVnlInit(jnl)) == NIL
  Warning(MsgIdJnlDoc() + " : " + SetMsg())
  RETURN .f.
endif
open area oVnl(VEN->Etat), oGen(), oArt(), oInt(), oVna()
  lOkay := .t.
  softseek cIdJnl + cIdDoc
  do while ! eof() .and. FIELD->IdDoc == cIdDoc ;
                   .and. FIELD->IdJnl == cIdJnl
    if FIELD->Code != LNCODE_REMARQ ;
       .and. FIELD->Code != LNCODE_TOTAL ;
       .and. FIELD->Code != LNCODE_MODULE
      if VnlFirstCheck(jnl[JNL_IDCTR])
        if ! VnlHsiCollect(jnl,aHsi)
          lOkay := .f.
          exit
        endif
      endif
    endif
    skip
  enddo
close area
if lOkay .or. Confirm(SetMsg(),MsgSure(),MSG_NO)
  iVenHsiEdit(jnl,aHsi)
endif
VnlRestore(a)
RETURN .t.

FUNCTION iVenHsiEdit(jnl,aHsi)
local lFound := .f.
local i
local cLine := space(LEN_POS)
local cIdJnl := VEN->IdJnl
local cIdDoc := VEN->IdDoc
local cPeriode := VEN->Periode
local b := oHsi()
local lOkay := .f.
local cIdNat
RETURN .f. if ! VenHsiInit()
RETURN .f. if jnl == NIL
cIdNat := PAR->Pays
saHsi := aHsi
open area b
  ddSetOrder(ORD_HSI_DOC)
  softseek cIdJnl + cIdDoc
  do while ! eof() .and. HSI->IdDoc == cIdDoc ;
                   .and. HSI->IdJnl == cIdJnl
    lFound := .t.
    HsiAfter()
    skip
  enddo
  if ! lFound
    for i := 1 to len(saHsi)
      if dbAddRec()
        cLine := NextNum(cLine)
        HSI->IdJnl   := VEN->IdJnl
        HSI->IdDoc   := VEN->IdDoc
        HSI->Line    := cLine
        HSI->Periode := VEN->Periode
        HSI->IdNat   := cIdNat
        HSI->IdInt   := saHsi[i][HSI_IDINT]
        HSI->QteStat := ntoq(saHsi[i][HSI_QTESTAT],IntQteForm(saHsi[i][HSI_IDINT]))
        HSI->Qte     := ntoq(saHsi[i][HSI_QTE],IntQteForm(saHsi[i][HSI_IDINT]))
        HSI->Mont    := ntom(saHsi[i][HSI_MONT])
        HSI->MontDev := ntom(saHsi[i][HSI_MONTDEV],saDev[DEV_DECPOS])
        DoEvents(b[AD_ONCREATE],b[AD_NAME]+":onCreate")
        unlock record
      else
        exit
      endif
    next
  endif
  edit data b key      HSI->IdJnl + HSI->IdDoc ;
              value    cIdJnl + cIdDoc    ;
              start    top                  ;
              create   {|| HsiCreate( ;
                cIdJnl,cIdDoc,cPeriode,cIdNat ;
              ) } ;
              before   HsiBefore() ;
              after    HsiAfter() ;
              query    "HSIVEN" ;
              title    (cIdJnl + " " + cIdDoc + " : Intrastat")
close area
RETURN MnuDone()


FUNCTION HsiBefore
local i
for i := 1 to len(saHsi)
  if HSI->IdInt == saHsi[i][HSI_IDINT]
    saHsi[i][HSI_MONT]    += val(HSI->Mont)
    saHsi[i][HSI_MONTDEV] += val(HSI->MontDev)
    saHsi[i][HSI_QTE]     += qton(HSI->Qte)
    saHsi[i][HSI_QTESTAT] += qton(HSI->QteStat)
    RETURN NIL
  endif
next i
RETURN NIL


FUNCTION HsiAfter
local i
local hsi
for i := 1 to len(saHsi)
  if HSI->IdInt == saHsi[i][HSI_IDINT]
    saHsi[i][HSI_MONT]    -= val(HSI->Mont)
    saHsi[i][HSI_MONTDEV] -= val(HSI->MontDev)
    saHsi[i][HSI_QTE]     -= qton(HSI->Qte)
    saHsi[i][HSI_QTESTAT] -= qton(HSI->QteStat)
    RETURN NIL
  endif
next i
hsi := array(HSI_ALEN)
hsi[HSI_MONT]    := - val(HSI->Mont)
hsi[HSI_MONTDEV] := - val(HSI->MontDev)
hsi[HSI_QTE]     := - qton(HSI->Qte)
hsi[HSI_QTESTAT] := - qton(HSI->QteStat)
RETURN NIL

FUNCTION IntQteForm(cIdInt)
local cQteForm := ""
open area oInt()
  seek cIdInt
  cQteForm := INT->QteForm
close area
RETURN cQteForm


FUNCTION PickInt(cStart)
RETURN DbfPick( ;
  {oInt()},;
  "Auswahl Zollnummer", ;
  "INTPICK",;
  cStart,;
  NIL,NIL,NIL,;
  "INT->IdInt",;
)

FUNCTION IntExist(cIdInt)
if INT->IdInt == cIdInt .and. ! eof() in INT
  RETURN .t.
endif
seek cIdInt in INT
if ! (eof() in INT)
  RETURN .t.
endif
SetMsg(cIdInt + " : unbekannte Zollnummer !")
RETURN .f.

#endif DEF_INT

FUNCTION DictAddItem(aDict,uValue)
local i
for i := 1 to len(aDict)
  RETURN .f. if aDict[i] == uValue
next i
aadd(aDict, uValue)
RETURN .t.


FUNCTION arrayscan(a,b)
local i
for i := 1 to len(a)
  RETURN .f. if ! eval(b,a[i],i)
next i
RETURN .t.

FUNCTION LngLoop(b)
local cLang := TplLang()
SetTplLang(MemLang1)
RETURN .f. if ! eval(b)
if ! empty(MemLang2)
  SetTplLang(MemLang2)
  RETURN .f. if ! eval(b)
  if ! empty(MemLang3)
    SetTplLang(MemLang3)
    RETURN .f. if ! eval(b)
    #ifdef DEF_4LANG
    if ! empty(MemLang4)
      SetTplLang(MemLang4)
      RETURN .f. if ! eval(b)
    endif
    #endif
  endif
endif
SetTplLang(cLang)
RETURN .t.

FUNCTION Lng2iso(cIdLng)
RETURN "en" if cIdLng == "E"
RETURN "de" if cIdLng == "D"
RETURN "fr" if cIdLng == "F"
RETURN "et" if cIdLng == "K"
RETURN "nl" if cIdLng == "N"
RETURN cIdLng
