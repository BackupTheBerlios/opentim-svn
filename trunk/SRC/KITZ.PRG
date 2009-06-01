** Copyright (c) 2003-2009 Luc Saffre
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

* Die Felder Mont und Mont2 in KRL und KRG haben einen schlechten Namen.
* Mont hieáe besser Prix, und Mont2 ist der Anteil des Patienten an diesem
* Preis. Der Anteil KK ist komplexer: sie bernimmt in Phase den
* kompletten Restbetrag. Aber in Phase C (das ist nicht ganz logisch)
* ist Mont momentan immer leer. Eigentlich msste ich drei Felder haben:
* Preis, AnteilKK und AnteilKind (und in Phase B und C ist Preis nicht
* gleich AnteilKK+AnteilKind, sondern es bleibt ein unfakturierbarer
* Rest.
*

#include "TIM.CH"
#include "DEFDATA.CH"

#ifdef DEF_KITZ

#define ETAT_NEW     " "
#define ETAT_CLOSED  "*"
#define ETAT_FILLING "-"


#define LEN_IDDIS 3
#define LEN_IDSES 5
#define LEN_IDKTG 4

FUNCTION oSes
static b := NIL
if b != NIL ; RETURN b ; endif
define data b              ;
       name SES
ddIndex b on  SES->IdSes format {|x| padl(x,LEN_IDSES)}
ddIndex b on  dtos(SES->Date)+SES->Von+SES->Raum
ddIndex b on  SES->IdPar+dtos(SES->Date)+SES->Von+SES->Bis
ddIndex b on  SES->IdPar2+dtos(SES->Date)+SES->Von+SES->Bis
ddIndex b on  SES->IdKrg+dtos(SES->Date)+SES->Von+SES->Bis
ddFld IdSes    ,C,  LEN_IDSES,0 when .f.
ddFld Date     ,D,  8,0 when empty(SES->Etat)
ddFld Von      ,C,  5,0 postedit {|x|gettime(x)} when empty(SES->Etat)
ddFld Bis      ,C,  5,0 postedit {|x|gettime(x)} when empty(SES->Etat)
// IdPar : T : Therapeut
ddFld IdPar    ,C, LenIdPar(),0  picture PIC_ID ;
  pick PickPar("T", SES->IdPar) ;
  postedit {|x| GetIdPar( x,"T" ) } ;
  when empty(SES->Etat)
// IdPar2 : P : Patienten
ddFld IdPar2    ,C, LenIdPar(),0  picture PIC_ID ;
  pick PickPar("P", SES->IdPar2) ;
  postedit {|x| GetIdPar( x,"P" ) } ;
  when empty(SES->Etat)
ddFld Type     ,C,  1,0 picture PIC_ID ;
  pick {|x| PickDbcCode("SESTYPE.DBC",x)} ;
  when empty(SES->Etat)
ddFld Etat     ,C,  1,0 picture PIC_ID ;
  pick {|x| PickDbcCode("SESETAT.DBC",x)} ;
  when empty(SES->IdKrg)
ddFld Raum     ,C, 20,0 
ddFld IdDis    ,C,  LEN_IDDIS,0 pick PickDis(SES->IdDis) when empty(SES->Etat)
ddFld IdPrj    ,C,  LenIdPrj(),0 pick DbfPick(;
    {oPrj(),oPar()},;
    "Protokolle pro Kind",;
    "PRJPICKP", SES->IdPrj, ".t.",;
    SES->IdPar2,"PRJ->IdPar2";
  ) valid ph_refresh() postedit {|x|padl(trim(x),LenIdPrj())} ;
  when empty(SES->Etat)
ddAddField("Gruppe","C",1,0,"!","",NIL,NIL,NIL,;
  {|x|PickDbcCode("JANEIN.DBC",x,"Gruppe?")},{||empty(SES->Etat)})
ddAddField("Was","C",3,0,"@k@!","",NIL,NIL,NIL,;
  {|x|PickDbcCode("WAS.DBC",x,"Was?")},{||empty(SES->Etat)})
ddFld IdKrg    ,C,  LenIdDoc(),0 when USRATTR_E $ UsrAttrib()
ddFld GCount ,N,  2,0 when .f.
ddAddField("Warn","C",1,0,"!","",NIL,NIL,NIL,;
  {|x|PickDbcCode("SESWARN.DBC",x,"Warnungen ignorieren?")})
// ddFld Phase    ,C,  1,0 picture PIC_ID ;
//  pick {|x| PickDbcCode("PHASE.DBC",x)} ;
//  when empty(SES->IdKrg)
// action b key K_ENTER   prompt MnuInhalt() block IvtIvlEdit()
ddEndDef()
RETURN b


* FUNCTION SesCanEdit
* RETURN empty(SES->IdKrg)

FUNCTION OnSesGruppe()
local nRecno := recno()
** called from SESPOST.ACT (called from SES.DEF)
local aRecNos := {}
local i
local nCount := 0
local lOkay := _SesGrpCheck(aRecNos,@nCount)
if empty(SES->Gruppe)
  SES->GCount := 0
else
  SES->GCount := nCount // len(aRecNos)+1
endif
if len(aRecNos) > 0
  for i := 1 to len(aRecNos)
    goto (aRecNos[i])
    if ddRecLock()
      SES->GCount := nCount // len(aRecNos)+1
      unlock record
    else
      SendConsole("record lock failed while setting SES->GCount")
    endif
  next i
  goto (nRecNo)
  ddRefreshAll()
endif
RETURN .f. if empty(SES->Warn) .and. ! lOkay
RETURN .t.

FUNCTION SesGrpMembers()
local aRecNos := {}
local nCount := 0
local i
local s := ""
// RETURN s if !
_SesGrpCheck(aRecNos,@nCount)
RETURN s if len(aRecNos) == 0
open area oSes(),oPar()
  for i := 1 to len(aRecNos)
    goto (aRecNos[i])
    seek SES->IdPar2 in PAR
    if i == 1
      s += trim(PAR->Vorname)
    elseif i == len(aRecNos)
      s += " und " + trim(PAR->Vorname)
    else
      s += ", " + trim(PAR->Vorname)
    endif
  next i
close area
RETURN s


FUNCTION SesRecTest()
** called by SesTest()
local aRecNos := {}
local nCount := 0
local lOkay
RETURN !SetMsg("Ungltige Patientennummer!") if !ParExist(SES->IdPar2)
RETURN !SetMsg("Ungltige Therapeutennummer!") if !ParExist(SES->IdPar)
lOkay := _SesGrpCheck(aRecNos,@nCount)
// RETURN .f. if nCount == NIL
if empty(SES->Gruppe) .and. SES->GCount != 0
  RETURN ! SetMsg("GCount "+ntrim(SES->GCount)+" msste 0 sein")
endif
if SES->GCount != nCount
  RETURN ! SetMsg("GCount "+ntrim(SES->GCount)+" msste "+ntrim(nCount)+" sein")
endif
RETURN lOkay if empty(SES->Warn)
RETURN .t.

STATIC FUNCTION _SesGrpCheck(aRecNos,nCount)
** fills aRecNos for OnSesGruppe() with all other group members who need
** their GCount updated
** return NIL if conflict
** set @nCount to # of paying group members
local dDate := SES->Date
local nRecno := recno()
// local aRecNos := {}
local cIdPar := SES->IdPar
local cIdPar2 := SES->IdPar2
local cVon := SES->Von
local cBis := SES->Bis
local cWas := SES->Was
local cGruppe:=SES->Gruppe
local cEtat:=SES->Etat
local lOkay:=.f.
* local nCount := 0
local nKind := 0
local nQteKind := 0
if nCount != 0
  raise("Oops, nCount == "+utos(nCount))
endif
open area oSes()
  lOkay:=.t.
  ddSetOrder(2) // Date+Von+Bis
  softseek dtos(dDate)
  do while !eof().and.SES->Date==dDate
    if SES->IdPar2==cIdPar2.and.SES->Etat$"PF "
      // z.b. Kind 0.30 und EG 1.00
      if empty(SES->Was)
        nKind += 1
      endif
      nQteKind += t2hours(TimeDiff(SES->Von,SES->Bis))
    endif
    if SES->Gruppe==cGruppe.and.!empty(cGruppe);
         .and.SES->Was==cWas;
         .and.SES->Von==cVon;
         .and.SES->Bis==cBis // .and.SES->IdPar2!=cIdPar2
      if SES->IdPar==cIdPar
        if recno() != nRecNo
          aadd(aRecNos,recno())
        endif
        if SES->Etat$"PF"
          nCount += 1
        endif
      endif
    elseif recno() != nRecno.and.SES->Etat$"PF ".and.cEtat$"PF "
      if SES->IdPar==cIdPar.or.(SES->IdPar2==cIdPar2.and.SES->Was==cWas)
        if SES->Bis!=cVon.and.inrange(SES->Bis,cVon,cBis)
          SetMsg("Sitzung "+ltrim(SES->IdSes)+" am "+dtoc(SES->Date)+" endet sp„ter als "+alltrim(cVon)+"!")
          lOkay:=.f.
        elseif SES->Von!=cBis.and.inrange(SES->Von,cVon,cBis)
          SetMsg("Sitzung "+ltrim(SES->IdSes)+" am "+dtoc(SES->Date)+" beginnt frher als "+alltrim(cBis)+"!")
          lOkay:=.f.
        endif
      endif
    endif
    skip
  enddo
close area
if nKind > 2
  SetMsg(trim(ParName(cIdPar2))+" : mehr als 2 Sitzungen am "+dtoc(SES->Date)+"!")
  lOkay := .f.
endif
if nKind > 0 .and. nQteKind < 1 .and. !SES->Etat $ "U "
  SetMsg("Kind hat mindestens 1 unfakturierbare Sitzung weil Gesamtdauer < 1 Stunde.")
  lOkay := .f.
endif
RETURN lOkay
* RETURN NIL if ! lOkay
* RETURN nCount


* FUNCTION oKtg // Kontingente
* static b := NIL
* if b != NIL ; RETURN b ; endif
* define data b              ;
*        name KTG
* ddIndex b on  KTG->Date1
* ddFld Date1    ,D, 8,0
* ddFld Date2    ,D, 8,0
* ddFld QteA ,C, 8,0 postedit {|x|gettime(x)}
* ddFld QteB ,C, 8,0 postedit {|x|gettime(x)}
* ddFld NumTests ,N, 6,0
* * ddFld IdKtg    ,C,  LEN_IDKTG,0
* * ddFld SesType  ,C,  1,0 picture PIC_ID ;
* *       pick {|x| PickDbcCode("SESTYPE.DBC",x)}
* * ddFld Suffix   ,C, 1,0
* ddEndDef()
* RETURN b

#define ORD_KTG_2 2

FUNCTION oKtg // Kontingente
static b := NIL
if b != NIL ; RETURN b ; endif
define data b              ;
       name KTG ;
       create KtgCreate()
ddIndex b on  KTG->IdKtg
ddIndex b on  dtos(KTG->Date1)+KTG->Phase  // ORD_KTG_2
ddFld IdKtg    ,C,  LEN_IDKTG,0
ddFld Date1    ,D, 8,0 when empty(KTG->Etat)
ddFld Date2    ,D, 8,0 when empty(KTG->Etat)
ddFld Phase    ,C,  1,0 picture PIC_ID ;
      pick {|x| PickDbcCode("PHASE.DBC",x)} ;
      when empty(KTG->Etat)
ddFld QteInit  ,C, 8,0 postedit {|x|gettime(x)} when empty(KTG->Etat)
ddFld QteRest  ,C, 8,0 postedit {|x|gettime(x)}
ddFld TstInit  ,C, 8,0 postedit {|x|gettime(x)} when empty(KTG->Etat)
ddFld TstRest  ,C, 8,0 postedit {|x|gettime(x)}
ddFld Faktor   ,C, 3,0 postedit {|x|getnum(x)} when empty(KTG->Etat)
ddFld Etat     ,C,  1,0 picture PIC_ID ;
  pick {|x| PickDbcCode("KTGETAT.DBC",x)}
ddEndDef()
RETURN b

FUNCTION KtgCreate()
local cIdKtg := DbfAutoInc(oKtg())
local a := CopyRec()
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(a)
KTG->IdKtg := cIdKtg
KTG->Phase := NextStr(KTG->Phase)
RETURN DDCREATE_DONE


FUNCTION PickKtg(cStart)
RETURN DbfPick( ;
  {oKtg()},;
  "Auswahl Kontingent", ;
  "KTGPICK",;
  cStart,;
  NIL,NIL,NIL,;
  "KTG->IdKtg";
)



FUNCTION oDis
static b := NIL
if b != NIL ; RETURN b ; endif
define data b              ;
       name DIS
ddIndex b on  DIS->IdDis
ddIndex b on  DIS->IdPar+DIS->IdDis
ddFld IdDis    ,C,  LEN_IDDIS,0
// IdPar : T : Therapeut
ddFld IdPar    ,C, LenIdPar(),0  picture PIC_ID ;
  pick PickPar("T", SES->IdPar) ;
  postedit {|x| GetIdPar( x,"T" ) } 
ddFld Name     ,C, 40,0
ddFld Raum     ,C, 20,0 
ddEndDef()
RETURN b

FUNCTION DisName(cIdDis)
RETURN DbfPeek(oDis(),cIdDis,"DIS->Name","")

FUNCTION oLdj // "Link between DIS and PRJ"
static b := NIL
if b != NIL ; RETURN b ; endif
define data b              ;
       name LDJ
ddIndex b on  LDJ->IdPrj+LDJ->IdDis
ddIndex b on  LDJ->IdDis+LDJ->IdPrj
ddIndex b on  LDJ->IdPar+LDJ->IdPrj
ddFld IdPrj    ,C,  LenIdPrj(),0 picture PIC_ID ;
  pick PickPrj(LDJ->IdPrj)
ddFld IdDis    ,C,  LEN_IDDIS,0 pick PickDis(LDJ->IdDis)
// IdPar : T : Therapeut
ddFld IdPar    ,C, LenIdPar(),0  picture PIC_ID ;
  pick PickPar("T", LDJ->IdPar) ;
  postedit {|x| GetIdPar( x,"T" ) } 
// ddFld Raum     ,C, 20,0
ddEndDef()
RETURN b


**
** KRG : Kitz-Rechnungen
**
FUNCTION oKrg
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name KRG ;
              wait {|msk| KrgKrlWait(msk)} ;
              predelete KrgPreDelete() ;
              postedit KrgPostEdit() ;
              editprint KrgPrint()
ddIndex b on  KRG->IdKrg format {|x|padl(x,LenIdDoc())}
ddIndex b on  KRG->IdPar1+dtos(KRG->Date)
ddIndex b on  KRG->IdPar4+dtos(KRG->Date)+KRG->Periode+KRG->IdKrg
*
ddFld IdKrg    ,C, LenIdDoc(),0  picture PIC_ID when .f.
ddFld Date     ,D, 8,0  when empty(KRG->Etat)
ddFld Periode , C, LEN_PERIODE,0 picture PIC_ID ;
                   pick PickPer(KRG->Periode,"KRG") ;
                   when empty(KRG->Etat)
ddFld IdPar1   ,C, LenIdPar(),0  picture PIC_ID ;
                   pick PickPar("K",KRG->IdPar1) ;
                   when empty(KRG->Etat)
ddFld IdPar2   ,C, LenIdPar(),0  GET_PAD ;
                   pick PickPar("P",KRG->IdPar2) ;
                   when empty(KRG->Etat)
ddFld Mont1    ,T, LenMont(),0 when .f.
ddFld Mont2    ,T, LenMont(),0 when .f.
ddFld IdPrj1   ,C, LenIdPrj(),0  picture PIC_ID ;
                   pick PickPrj(KRG->IdPrj1) ;
                   when empty(KRG->Etat)
ddFld IdPrj2   ,C, LenIdPrj(),0  picture PIC_ID ;
                   pick PickPrj(KRG->IdPrj2) ;
                   when empty(KRG->Etat)
ddFld IdPar4   ,C, LenIdPar(),0  picture PIC_ID ;
                   pick PickPar("K",KRG->IdPar4) ;
                   when empty(KRG->Etat)
ddFld DaysT    ,C, 60,0  picture "@k@s20" when .f. // not used
ddFld Etat     ,C,  1,0 picture PIC_ID ;
  pick {|x| PickDbcCode("KRGETAT.DBC",x)}
ddFld IdPar3   ,C, LenIdPar(),0  GET_PAD ;
                   pick PickPar("E",KRG->IdPar3)
ddFld Count    ,N,  2,0 when .f.
ddFld Vipo    ,C,1,0 picture "!" ;
              pick PickDbcCode("JANEIN.DBC",KRG->Vipo,"VIPO?") ;
              when empty(KRG->Etat)
ddFld Mont1T   ,T, LenMont(),0 when .f.
ddFld Mont2T   ,T, LenMont(),0 when .f.
ddFld CountT   ,N,  2,0 when .f.
ddFld MontKrm  ,T, LenMont(),0 
ddFld QteKrm   ,C, 5,0 postedit {|x|gettime(x)}
*
action b key K_ENTER   prompt MnuInhalt() ;
                       block KrgKrlEdit()
ddEndDef()
RETURN b

#define ORD_KRL_2 2

** KRL : Kitz-Rechnungslinien
**
FUNCTION oKrl
static b := NIL
if b != NIL ; RETURN b ; endif
define data b               ;
  name KRL ;
  postedit KrlPostEdit() ;
  preedit indexord()!=1.or.KRG->Etat==ETAT_NEW
ddIndex b on  KRL->IdKrg+KRL->IdArt+KRL->IdKtg+dtos(KRL->Date)
ddIndex b on  KRL->IdKtg+dtos(KRL->Date) // ORD_KRL_2
ddFld IdKrg    ,C, LenIdDoc(),0  picture PIC_ID when .f.
// ddFld Count    ,N,  2,0 when .f.
ddFld Date     ,D, 8,0 when KRG->Etat == ETAT_NEW
ddFld IdArt    ,C, LenIdArt(),0 picture PIC_ID ;
               when KRG->Etat == ETAT_NEW ;
               pick PickArt(KRL->IdArt) ;
               postedit {|x|GetIdArt(x)} ;
               valid KrlArtValidate()
ddFld Mont    ,T, LenMont(),0 when KRG->Etat == ETAT_NEW
// ddFld Qte     ,C, LenQte(),0 postedit {|x|gettime(x)}
// ddFld SesType  ,C,  1,0 picture PIC_ID ;
//   pick {|x| PickDbcCode("SESTYPE.DBC",x)}
// ddFld Days    ,C, 60,0  picture "@k@s20"
ddFld Mont2   ,T, LenMont(),0 when KRG->Etat == ETAT_NEW
ddFld IdKtg   ,C, LEN_IDKTG,0 pick {|x| PickKtg(x)}
ddEndDef()
RETURN b


FUNCTION KrlTime()
local cQte
if left(KRL->IdArt,1) == "T"
  cQte := substr(trim(KRL->IdArt),2)
else
  cQte := trim(KRL->IdArt)
endif
* if right(cQte,1) > "9"
*   cQte := left(cQte,len(cQte)-1)
* endif
RETURN val(cQte) // * KRL->Count)


FUNCTION KrgPreDelete()
local lOkay := .f.
local cQte
RETURN ConfirmDelete() if empty(KRG->IdKrg)
RETURN .f. if ! ConfirmDelete()
open area oKrl(), oKtg()
  lOkay := .t.
  softseek KRG->IdKrg
  do while !eof() .and. KRL->IdKrg == KRG->IdKrg
    if ddRecLock()
      if !empty(KRL->IdKtg).and.trim(KRL->IdKtg)!=KTG_DG
        select KTG
        seek KRL->IdKtg
        if eof()
          SetMsg(KRL->IdKtg+" : ungltiges Kontingent")
          lOkay := .f.
        elseif ddRecLock()
          cQte := h2time(KrlTime())
          if left(KRL->IdArt,1) == "T"
            KTG->TstRest := padl(timeadd(KTG->TstRest,cQte),8)
          endif
          KTG->QteRest := padl(timeadd(KTG->QteRest,cQte),8)
          unlock record
        else
          lOkay := .f.
        endif
        select KRL
      endif
      delete
      unlock record
    else
      lOkay := .f.
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
open area oSes()
  lOkay := .t.
  ddSetOrder(5) // SES->IdKrg+...
  softseek KRG->IdKrg
  do while !eof() .and. SES->IdKrg == KRG->IdKrg
    if ddRecLock()
      SES->IdKrg := ""
      unlock record
    else
      lOkay := .f.
    endif
    softseek KRG->IdKrg
  enddo
close area
RETURN lOkay

FUNCTION ArtKrlPrix(dDate)
RETURN ART->Prix2 if !empty(ART->DatPrix2).and.dDate>=ART->DatPrix2
RETURN ART->Prix1

* FUNCTION KrlPrix(cPeriode)
* RETURN ART->Prix2 if !empty(ART->PerPrix2).and.cPeriode>=ART->PerPrix2
* RETURN ART->Prix1


FUNCTION KrlArtValidate()
RETURN .f. if ! ArtExist(KRL->IdArt)
* KRL->Mont := KrlPrix(KRG->Date)
* KRL->Mont := KrlPrix(KRG->Periode)
RETURN .t.

FUNCTION PrjLdjEdit()
RETURN  DbfEdit(;
  {oLdj(),oDis(),oPar(),oPrj()},;
  "Disziplinen pro Protokoll : "+alltrim(PRJ->IdPrj),;
  "LDJPRJ",;
  NIL,;
  NIL,;
  PRJ->IdPrj,;
  "LDJ->IdPrj",;
  NIL;
)

FUNCTION PrjLdjWait(wwin)
local b := oLdj()
local cIdPrj := PRJ->IdPrj
open area b, oPar(), oPrj(), oDis()
  ddSetOrder(1)
  edit data b key LDJ->IdPrj ;
    value    cIdPrj             ;
    start    bottom                 ;
    mode     wait  ;
    window   wwin ;
    query    "LDJPRJ" ;
    title (alltrim(PRJ->IdPrj) + " : Disziplinen")
close area
RETURN MnuDone()

FUNCTION KrgKrlWait(wwin)
local b := oKrl()
open area b, oArt(), oPar(), oPrj()
  ddSetOrder(1)
  edit data b key KRL->IdKrg ;
    value    KRG->IdKrg             ;
    start    bottom                 ;
    mode     wait  ;
    window   wwin ;
    query    "KRLKRG" ;
    title (alltrim(KRG->IdKrg) + " : Inhalt")
close area
RETURN MnuDone()


FUNCTION PickDis(cStart)
RETURN DbfPick( ;
  {oDis(),oPar()},;
  "Auswahl Disziplin", ;
  "DISPICK",;
  cStart,;
  NIL,NIL,NIL,;
  "DIS->IdDis";
)

** wird nicht mehr benutzt
FUNCTION PrjSesScan(dDate1,dDate2,xlFilter,xlEval)
RETURN DbfScan(;
  {oSes(),oPar()},5,;
  PRJ->IdPrj+dtos(dDate1),;
  "SES->IdPrj+dtos(SES->Date)<='"+PRJ->IdPrj+dtos(dDate2)+"'",;
  xlFilter,xlEval)

** wird benutzt in PARSESP.REP
FUNCTION ParSesSum(dDate1,dDate2,xlFilter,xnValue)
if PAR->IdPrt == "P"
  RETURN DbfSum(;
    {oSes(),oPar()},xnValue,4,;
    PAR->IdPar+dtos(dDate1),;
    "SES->IdPar2+dtos(SES->Date)<='"+PAR->IdPar+dtos(dDate2)+"'",;
    xlFilter)
elseif PAR->IdPrt == "T"
  RETURN DbfSum(;
    {oSes(),oPar()},xnValue,3,;
    PAR->IdPar+dtos(dDate1),;
    "SES->IdPar+dtos(SES->Date)<='"+PAR->IdPar+dtos(dDate2)+"'",;
    xlFilter)
endif
RETURN !SetMsg(trim(ParName())+" ist weder Kind noch Therapeut!")

** wird benutzt in PARSESP.REP
FUNCTION ParNbPres(dDate1,dDate2,xlFilter)
local a := {}
local xnValue:={||iif(DictAddItem(a,SES->Date),1,0)}
if PAR->IdPrt == "P"
  RETURN DbfSum(;
    {oSes(),oPar()},xnValue,4,;
    PAR->IdPar+dtos(dDate1),;
    "SES->IdPar2+dtos(SES->Date)<='"+PAR->IdPar+dtos(dDate2)+"'",;
    xlFilter)
elseif PAR->IdPrt == "T"
  RETURN DbfSum(;
    {oSes(),oPar()},xnValue,3,;
    PAR->IdPar+dtos(dDate1),;
    "SES->IdPar+dtos(SES->Date)<='"+PAR->IdPar+dtos(dDate2)+"'",;
    xlFilter)
endif
RETURN !SetMsg(trim(ParName())+" ist weder Kind noch Therapeut!")

** wird benutzt in Druckmaske PAR:CAL-E
FUNCTION ParSesScan(dDate1,dDate2,xlFilter,xlEval)
if PAR->IdPrt == "P"
  RETURN DbfScan(;
    {oSes(),oPar()},4,;
    PAR->IdPar+dtos(dDate1),;
    "SES->IdPar2+dtos(SES->Date)<='"+PAR->IdPar+dtos(dDate2)+"'",;
    xlFilter,xlEval)
elseif PAR->IdPrt == "T"
  RETURN DbfScan(;
    {oSes(),oPar()},3,;
    PAR->IdPar+dtos(dDate1),;
    "SES->IdPar+dtos(SES->Date)<='"+PAR->IdPar+dtos(dDate2)+"'",;
    xlFilter,xlEval)
endif
RETURN !SetMsg(trim(ParName())+" ist weder Kind noch Therapeut!")

** wird benutzt in Druckmaske KRG:KRG
FUNCTION KrgKrlScan(xlFilter,xlEval)
RETURN DbfScan(;
  {oKrl(),oArt()},1,;
  KRG->IdKrg,;
  "KRL->IdKrg=='"+KRG->IdKrg+"'",;
  xlFilter,xlEval)

FUNCTION KrgKrlEdit()
local lOkay := .f.
RETURN .f. if ! ddRecLock()
DbfEdit({oKrl(),oKrg(),oArt()},;
   KRG->IdKrg,"KRLKRG",NIL,NIL,KRG->IdKrg,"KRL->IdKrg")
lOkay := KrgKrlUpdate()
unlock record
RETURN lOkay

FUNCTION KrgKrlUpdate()
local nCount := 0
local nCountT := 0
local cIdPar1 := "" // Krankenkasse
local nMont1:=0
local nMont2:=0
local nMont1T:=0
local nMont2T:=0
local lOkay := .f.
local nKrmPrix := KrgKrmPrix()
local nQteKrm := 0
* local nSK
local a
RETURN .f. if KRG->Etat != ETAT_NEW
RETURN .f. if empty(KRG->IdPrj1)
open area oKrl() // ,oArt()
  lOkay := .t.
  softseek KRG->IdKrg
  do while !eof().and.KRL->IdKrg==KRG->IdKrg
    * Dieses if ist unntz, wenn ich mich nicht irre
    if empty(KRL->IdKtg)
      SetMsg(KRL->IdKrg+" "+dtoc(KRL->Date)+" ist keinem Kontingent zugewiesen")
      lOkay := .f. // 20090526
    endif
    if left(KRL->IdArt,1) == "T"
      nMont1T += max(val(KRL->Mont),val(KRL->Mont2)) // 20070119
      nMont2T += val(KRL->Mont2)
      nCountT += 1
    else
      nMont1 += max(val(KRL->Mont),val(KRL->Mont2)) // 20070119
      nMont2 += val(KRL->Mont2)
      nCount += 1
    endif
    if !empty(KRL->IdKtg).and.trim(KRL->IdKtg)!=KTG_DG    
      nQteKrm += val(iif(left(KRL->IdArt,1)=="T",;
        substr(KRL->IdArt,2),;
        KRL->IdArt))
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
a := DbfPeek(oPrj(),KRG->IdPrj1,"{PRJ->IdPar,PRJ->IdPar3,PRJ->Vipo}",NIL)
RETURN !SetMsg(KRG->IdPrj1+" : unbekanntes Protokoll!") if a == NIL
KRG->IdPar1 := a[1]
KRG->IdPar3 := a[2]
KRG->Vipo := a[3]
KRG->Mont1 := ntom(nMont1)
KRG->Mont1T := ntom(nMont1T)
KRG->Mont2 := ntom(nMont2)
KRG->Mont2T := ntom(nMont2T)
KRG->Count := nCount
KRG->CountT := nCountT
KRG->Etat := "*"
KRG->QteKrm := h2time(nQteKrm,5)
if nKrmPrix != 0
  KRG->MontKrm := ntom(nQteKrm*nKrmPrix)
endif
RETURN KrgPostEdit()

FUNCTION KrgIsValid()
local nCount := 0
local nCountT := 0
local cIdPar1 := "" // Krankenkasse
local nMont1:=0
local nMont2:=0
local nMont1T:=0
local nMont2T:=0
local lOkay := .f.
local a
RETURN !SetMsg("Rechnung nicht fertig") if KRG->Etat != ETAT_CLOSED
open area oKrl() // ,oArt()
  lOkay := .t.
  softseek KRG->IdKrg
  do while !eof().and.KRL->IdKrg==KRG->IdKrg
    if left(KRL->IdArt,1) == "T"
      nMont1T += max(val(KRL->Mont),val(KRL->Mont2)) // 20070119
      nMont2T += val(KRL->Mont2)
      nCountT += 1
    else
      nMont1 += max(val(KRL->Mont),val(KRL->Mont2)) // 20070119
      nMont2 += val(KRL->Mont2)
      nCount += 1
    endif
    skip
  enddo
close area
a := DbfPeek(oPrj(),KRG->IdPrj1,"{PRJ->IdPar,PRJ->IdPar3,PRJ->Vipo}",NIL)
RETURN !SetMsg(KRG->IdPrj1+" : unbekanntes Protokoll!") if a == NIL
RETURN !SetMsg("KRG->Mont1 ist "+ltrim(KRG->Mont1);
  +" statt " +ltrim(ntom(nMont1))) if KRG->Mont1 != ntom(nMont1)
RETURN !SetMsg("KRG->Mont2 ist "+ltrim(KRG->Mont2);
  +" statt " +ltrim(ntom(nMont2))) if KRG->Mont2 != ntom(nMont2)
RETURN !SetMsg("KRG->Mont1T ist "+ltrim(KRG->Mont1T);
  +" statt " +ltrim(ntom(nMont1T))) if KRG->Mont1T != ntom(nMont1T)
RETURN !SetMsg("KRG->Mont2T ist "+ltrim(KRG->Mont2T);
  +" statt " +ltrim(ntom(nMont2T))) if KRG->Mont2T != ntom(nMont2T)
RETURN !SetMsg("KRG->Count ist "+ntrim(KRG->Count);
  +" statt " +ntrim(nCount)) if KRG->Count != nCount
RETURN !SetMsg("KRG->CountT ist "+ntrim(KRG->CountT);
  +" statt " +ntrim(nCountT)) if KRG->CountT != nCountT
*RETURN !SetMsg("Gesamtbetr„ge widersprechen Inhalt") if ;
*  KRG->Mont1 != ntom(nMont1) ;
*  .or.KRG->Mont1T != ntom(nMont1T);
*  .or.KRG->Mont2 != ntom(nMont2);
*  .or.KRG->Mont2T != ntom(nMont2T);
*  .or.KRG->Count != nCount;
*  .or.KRG->CountT != nCountT
RETURN lOkay

FUNCTION KrgPostEdit
local cIdPar4 := DbfPeek(oPar(),KRG->IdPar1,"PAR->IdPar2",NIL)
RETURN !SetMsg(KRG->IdPar1+" : unbekannte Krankenkasse!") if cIdPar4==NIL
if empty(cIdPar4)
  KRG->IdPar4 := KRG->IdPar1
else
  KRG->IdPar4 := cIdPar4
endif
RETURN .t.



#define NF1_DATE   1
#define NF1_TYPE   2
#define NF1_QTE    3
#define NF1_VIPO   4
#define NF1_IDART  5
#define NF1_PRIX   6
#define NF1_ALEN   6

#define NF_IDPRJ  1 // not used
#define NF_QTE    2
// #define NF_TYPE   3
#define NF_IDKTG  3
#define NF_IDART  4
#define NF_COUNT  5
#define NF_PRIX   6
#define NF_MONT2  7
#define NF_DAYS   8
#define NF_ALEN   8

#undef PNF_IDPAR
#undef PNF_TAGGED
#undef PNF_ALEN

#define PNF_TAGGED  1
#define PNF_IDPAR   2
#define PNF_PERIODE 3
#define PNF_MSG     4
#define PNF_ALEN    4

#define LEG_PNFBROWSE "[Leertaste] ausw„hlen [*] Ausw.umkehren [F10] Weiter [Escape] Abbrechen"

#define SESETAT_F "F"

FUNCTION KrgAuto(dDate,cIdKrg)
local nCount := 0
local i
local cIdPrt := "P"
local cPeriode
local a := {}
local aRecNos
local aNF1
local aPrj
local lOkay := .f.
local aActions := {}
local cTitle := "Fakturierbar (bis "+MemPer2 +") am "+dtoc(dDate)
MsgDisplay(cTitle + ": " + MsgWorking())
open area oPar()
  lOkay := .t.
  ddSetOrder(2)
  softseek cIdPrt
  do while lOkay.and.!eof().and.PAR->IdPrt==cIdPrt
    cPeriode:=""
    do while lOkay .and. cPeriode!=NIL .and. cPeriode<=MemPer2
      MsgDisplay(cPeriode+" : "+ParName())
      if TaskInter() ; lOkay := .f. ; exit ; endif
      aRecNos := {}
      aNF1 := {}
      aPrj := {}
      cPeriode := Nf1Suggest(aNF1,PAR->IdPar,aRecNos,aPrj,dDate,cPeriode)
      if cPeriode == NIL
        aadd(a, { .f., PAR->IdPar, "!", SetMsg() }) // PNF_ALEN
      else
        if len(aNf1) > 0
          aadd(a, { .t., PAR->IdPar, cPeriode, "" }) // PNF_ALEN
        endif
        cPeriode := NextPeriode(cPeriode)
      endif
      SetMsg("")
    enddo
    skip
  enddo
close area
RETURN .f. if ! lOkay
aadd(aActions, { asc("*"), {|| ;
  PnfInvert(a) ;
} } )
aadd(aActions, { K_SPACE , {|m| ;
  m[PNF_TAGGED] := iif(empty(m[PNF_MSG]),!m[PNF_TAGGED],.f.), ;
  K_DOWN ;
} } )
open area oPar()
  browse array a using {|m| ;
      iif(m[PNF_TAGGED],"X"," ");
      +" "+padr(ParName(m[PNF_IDPAR]),20);
      +" "+iif(m[PNF_PERIODE]==MemPer2,space(4),m[PNF_PERIODE]);
      +" "+padr(m[PNF_MSG],40);
    } ;
    title (cTitle) ;
    legend (LEG_PNFBROWSE) ;
    actions (aActions) ;
    delete {||.f.}
  if lastchoice() == 0
    lOkay := .f.
  else
    for i := 1 to len(a)
      if a[i][PNF_TAGGED]
        seek a[i][PNF_IDPAR]
        if _ParKrgAuto(dDate,a[i][PNF_PERIODE],.f.,cIdKrg) < 0
          lOkay := .f.
          exit
        endif
        nCount += 1
        if !empty(cIdKrg)
          cIdKrg := NextNum(cIdKrg,NIL," ")
        endif
        MsgDisplay(SetMsg())
      endif
    next i
  endif
close area
SetMsg(ntrim(nCount)+" Rechnungen wurden vorbereitet")
RETURN .f. if ! lOkay
// RETURN .f. if ! Confirm("Jetzt nur noch DistKtg() starten",MsgContinue())
RETURN DistKtg()


STATIC FUNCTION PnfInvert(a)
local i
for i := 1 to len(a)
  if empty(a[i][PNF_MSG])
    a[i][PNF_TAGGED] := ! a[i][PNF_TAGGED]
  else
    a[i][PNF_TAGGED] := .f.
  endif
next i
RETURN K_ALT_F5


** -1 : Abbruch oder Fehler
** 0 : nichts zu fakturieren
** 1 : eine Rechnung wurde erstellt
STATIC FUNCTION _ParKrgAuto(dDate,cPer1,lDlg,cIdKrg)
local cIdArt
* local cIdKrg
local i
local lOkay := .f.
local nf
local aRecNos := {}
local aNF1 := {}
local aNF
local aPrj := {}
local cPeriode := Nf1Suggest(aNF1,PAR->IdPar,aRecNos,aPrj,dDate,cPer1)
RETURN 0 if cPeriode == NIL
if len(aNf1) == 0
  SetMsg(trim(ParName()) + " : nichts zu fakturieren im "+PerName(cPeriode))
  RETURN 0
endif
if len(aPrj) == 0
  SetMsg(trim(ParName()) + " ("+PerName(cPeriode)+") : aPrj ist leer!?")
  RETURN -1
endif
if lDlg
  RETURN -1 if ! Confirm(;
    "Rechnung "+trim(PerName(cPeriode)) ;
    +" fr "+trim(ParName()) ;
    +" erstellen (J/N)?")
endif
if empty(cIdKrg)
  cIdKrg := DbfAutoInc(oKrg())
endif
open area oKrg(), oSes(), oPrj()
  seek cIdKrg
  if !eof()
    SetMsg(cIdKrg+" : Rechnungsnummer existiert bereits!")
  elseif !PrjExist(aPrj[1])
    SetMsg(trim(ParName()) + " : "+aPrj[1]+" : ungltige Protokollnummer")
  else
    if dbAddRec()
      KRG->IdKrg := cIdKrg
      KRG->Etat := ETAT_NEW
      KRG->Date := dDate
      KRG->Periode := cPeriode
      KRG->IdPar2 := PAR->IdPar
      KRG->IdPrj1 := aPrj[1]
      if len(aPrj) > 1
        KRG->IdPrj2 := aPrj[2]
      endif
      * aNF := Nf2suggest(aNF1)
      open area oKrl(), oArt()
        lOkay := .t.
        for i := 1 to len(aNF1)
          nf := aNF1[i]
          if dbAddRec()
            KRL->IdKrg := cIdKrg
            KRL->IdArt := nf[NF1_IDART]
            // KRL->Qte   := h2time(nf[NF1_QTE])
            KRL->Date := nf[NF1_DATE]
            //KRL->Mont := nf[NF1_PRIX]
            if aNF1[i][NF1_VIPO] == "X"
              KRL->Mont2 := ""
            else
              KRL->Mont2 := ArtField(;
                padr("SK",LenIdArt()),;
                {||ArtKrlPrix(KRL->Date)})
            endif
            if PRJ->Zentrum == "D"
              KRL->IdKtg := KTG_DG
              * KRL->Mont := ArtKrlPrix(KRL->Date)
              KRL->Mont := ArtField(;
                KRL->IdArt,;
                {||ArtKrlPrix(KRL->Date)})
            endif
            unlock record
          else
            lOkay := .f.
          endif
        next i
      close area
      * KrgKrlUpdate()
      dbcommit()
      unlock record
    endif
  endif
close area
RETURN -1 if ! lOkay
open area oSes()
  for i := 1 to len(aRecNos)
    goto aRecNos[i]
    if ddRecLock()
      SES->IdKrg := cIdKrg
      unlock record
    else
      lOkay := .f.
    endif
  next i
close area
RETURN -1 if ! lOkay
SetMsg("Rechnung "+ltrim(cIdKrg)+" wurde erstellt.")
RETURN 1 if ! lDlg
RETURN 1 if DbfPeek(oKrg(),cIdKrg,'KrgPrint("KRG")',.f.)
SetMsg("Internal error during _ParKrgAuto()")
RETURN -1

STATIC FUNCTION DistKtg()
local lOkay := .f.
local nQte, cQte
local nCount := 0
local nKrlCount := 0
local nKtgCount := 0
local nKrgCount := 0
local nTodo
open area oKtg(),oArt()
  ddSetOrder(ORD_KTG_2)
  lOkay := .t.
  go top
  do while lOkay .and. ! eof()
    if TaskInter() ; lOkay := .f. ; exit ; endif
    if KTG->Etat != ETAT_CLOSED // .and. t2hours(KTG->QteRest) > 0
      nCount := 0
      nTodo := 0
      if ddRecLock()
        open area oKrl()
          ddSetOrder(ORD_KRL_2)
          go top
          do while lOkay .and. !eof() .and. empty(KRL->IdKtg)
            // MsgDisp2(dtoc(KRL->Date))
            if TaskInter() ; lOkay := .f. ; exit ; endif
            nQte := KrlTime()
            if inrange(KRL->Date,KTG->Date1,KTG->Date2);
              .and.(empty(KTG->QteInit).or.t2hours(KTG->QteRest)>=nQte) ;
              .and.(empty(KTG->TstInit);
                  .or.left(KRL->IdArt,1)!="T".or.t2hours(KTG->TstRest)>=nQte)
              if ddRecLock()
                if ArtExist(KRL->IdArt)
                  cQte := h2time(nQte)
                  KTG->QteRest := padl(timesubt(KTG->QteRest,cQte),8)
                  if left(KRL->IdArt,1) == "T"
                    KTG->TstRest := padl(timesubt(KTG->TstRest,cQte),8)
                  endif
                  KRL->IdKtg := KTG->IdKtg
                  KRL->Mont := ArtKrlPrix(KRL->Date)
                  if KTG->Faktor != "100"
                    KRL->Mont := ntom(val(KRL->Mont)*val(KTG->Faktor)/100)
                  endif
                  nCount += 1
                  MsgDisplay("Kontingent "+alltrim(KTG->IdKtg)+" : "+ntrim(nCount)+" Einheiten")
                  unlock record
                  go top
                else
                  lOkay := .f.
                endif
              else
                lOkay := .f.
              endif
            else
              skip
              nTodo += 1
            endif
          enddo
        close area
        unlock record
      else
        lOkay := .f.
      endif
      if nCount > 0
        nKrlCount += nCount
        nKtgCount += 1
      endif
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
open area oKrg()
  go top
  do while lOkay.and.!eof()
    if KRG->Etat == ETAT_NEW
      if ddRecLock()
        if KrgKrlUpdate()
          KRG->Etat := ETAT_CLOSED
          nKrgCount += 1
        else
          SetMsg("Rechnung "+ltrim(KRG->IdKrg)+": "+SetMsg())
          lOkay := .f.
        endif
        unlock record
      else
        lOkay := .f.
      endif
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
SetMsg(ntrim(nKrgCount)+" Rechnungen erstellt (";
 +ntrim(nKrlCount)+" Einheiten zugewiesen)." )
if nTodo > 0
  Warning(ntrim(nTodo) + ;
    " Forfaits konnten keinem Kontingent zugewiesen werden!",;
    "Stammdaten Kontingente prfen und dann neu fakturieren!")
endif
RETURN lOkay

* 20060516
*
* KRL->Phase statt SES->Phase.
*
* Aber wie ermittle ich dann die bereits verbrauchten Stunden? Dazu
* brauche ich ein weiteres neues Feld KRL->IdKtg, sowie ein KTG->TestsUsed
* und ein KTG->QteUsed. Und dann muss ich beim L”schen einer KRG auch
* diese Z„hler zurcksetzen. Und die Sache Integrit„tstest nachprfen.
* Beim Generieren der Rechnung muss ich dann fr jede erstellte KRL deren
* KTG ermitteln. Nein, NfSuggest() sollte das schon tun. Oder wie? Kann
* sein, dass mitten im Monat das Kontingent wechselt, aber das erste
* Kontingent noch in Phase A war, also bleibt die Phase die Gleiche. Nicht
* das Kontingent ist entscheidend, sondern die Phase. Also k”nnten zwei
* Sitzungen mit der gleichen Phase aber verschiedenen Kontingenten in
* einer KRL stehen. Also geht das KRL->IdKtg nicht. Mist.


FUNCTION KtgPop(dDate,nQte,cType)
local nSelect := select()
local lFound := .f.
select KTG
  ddSetOrder(ORD_KTG_2)
  go top // softseek dtos(dDate)
  do while !eof() .and. KTG->Date2 <= dDate
    skip
  enddo
  do while !eof() .and. KTG->Date1 <= dDate
    if KTG->Date2 >= dDate ;
      .and. (empty(KTG->QteInit).or.t2hours(KTG->QteRest) >= nQte) ;
      .and. (empty(KTG->TstInit).or.empty(cType);
             .or.t2hours(KTG->TstRest) >= nQte)
      if ddRecLock()
        KTG->QteRest := h2time(t2hours(KTG->QteRest)-nQte,8)
        lFound := .t.
        if !empty(cType)
          KTG->TstRest := h2time(t2hours(KTG->TstRest)-nQte,8)
          // KTG->TstRest := KTG->TstRest - 1
        endif
        unlock record
      endif
      exit
    else
      skip
    endif
  enddo
select (nSelect)
RETURN lFound

FUNCTION KtgIsValid()
local lOkay := .t.
local cQte
local cQteRest := KTG->QteInit
local cTstRest := KTG->TstInit
local cMsg := ""
open area oKrl()
  ddSetOrder(ORD_KRL_2)
  softseek KTG->IdKtg
  do while !eof().and.KRL->IdKtg == KTG->IdKtg
    cQte := h2time(KrlTime())
    cQteRest := timesubt(cQteRest,cQte)
    if left(KRL->IdArt,1) == "T"
      cTstRest := timesubt(cTstRest,cQte)
    endif
    skip
  enddo
  if ltrim(KTG->QteRest) != ltrim(cQteRest)
    cMsg+="Rest steht auf "+ ltrim(KTG->QteRest) +" statt "+cQteRest
    lOkay := .f.
  endif
  if ltrim(KTG->TstRest) != ltrim(cTstRest)
    if !empty(cMsg)
      cMsg += CR_LF + space(8)
    endif
    cMsg+="Rest (Bilanz) steht auf "+ ltrim(KTG->TstRest) +" statt "+cTstRest
    lOkay := .f.
  endif
  if !lOkay
    SetMsg(cMsg)
  endif
close area
RETURN lOkay


STATIC FUNCTION NF1Suggest(aNF1,cIdPar,aRecNos,aPrj,dDate,cPer1)
* local aNF1 := {}
local cPeriode := cPer1
* local dDate
local i, j, cIdArt, cPrix
local nQte
local nf
local lOkay := .f.
local cSesPer
**
** Lauf durch SES, um aNF1 zu fllen :
open area oSes(), oPar(), oPrj()
  lOkay := .t.
  ddSetOrder(4) // SES->IdPar2+dtos(SES->Date)...
  softseek cIdPar
  do while lOkay .and. ! eof() .and. SES->IdPar2 == cIdPar
    if empty(SES->IdKrg).and.SES->Etat==SESETAT_F
      cSesPer := PerActive(SES->Date)
      if cSesPer >= cPer1
        if cSesPer > MemPer2
          exit
        * elseif empty(cPeriode) .or. len(aNF1) == 0
        elseif len(aNF1) == 0
          cPeriode := cSesPer
        elseif cSesPer != cPeriode
          exit
        endif
        if PrjExist(SES->IdPrj)
          if empty(PRJ->Antrag2)
            SetMsg("Protokoll "+alltrim(SES->IdPrj)+" noch nicht genehmigt")
            lOkay := .f.
          elseif PRJ->Antrag2 > dDate
            SetMsg("Protokoll "+alltrim(SES->IdPrj)+" noch nicht genehmigt am "+dtoc(dDate))
            lOkay := .f.
          else
            DictAddItem(aPrj,SES->IdPrj)
            if len(aPrj) > 2
              SetMsg("Rechnung mit mehr als zwei Protokollen!")
              lOkay := .f.
            else
              aadd(aRecNos,recno())
              nQte := t2hours(TimeDiff(SES->Von,SES->Bis))
              if SES->GCount != 0
                nQte /= SES->GCount
              endif
              ** Ein Kind k”nnte an einem Tag zuerst 1 normale, dann
              ** eine Test, dann wieder eine normale Sitzung haben
              nf := NIL
              for i := 1 to len(aNF1)
                if aNF1[i][NF1_DATE] == SES->Date
                  if aNF1[i][NF1_TYPE] == SES->Type
                    nf := aNF1[i]
                    exit
                  endif
                endif
              next i
              if nf == NIL
                nf := array(NF_ALEN)
                nf[NF1_DATE] := SES->Date
                nf[NF1_TYPE] := SES->Type
                nf[NF1_QTE] := nQte
                nf[NF1_VIPO] := PRJ->Vipo
                aadd(aNF1,nf)
              else
                nf[NF1_QTE] += nQte
              endif
            endif
          endif
        else
          lOkay := .f.
        endif
      endif
    endif
    skip
  enddo
close area
RETURN NIL if ! lOkay
lOkay := .f.
open area oArt(), oKtg()
  lOkay := .t.
  for i := 1 to len(aNF1)
    cIdArt := trim(aNF1[i][NF1_TYPE]) + qte2art(aNF1[i][NF1_QTE])
    cIdArt := padr(cIdArt,LenIdArt())
    if ArtExist(cIdArt)
      aNF1[i][NF1_IDART] := cIdArt
      aNF1[i][NF1_PRIX] := ArtKrlPrix(aNF1[i][NF1_DATE])
    else
      lOkay := .f.
      exit
    endif
  next i
close area
RETURN NIL if ! lOkay
RETURN cPeriode

*STATIC FUNCTION Nf2Suggest(aNf1)
*local aNF := {}
*local lOkay := .f.
*local i, j, cIdArt, cPrix
*local nf
*open area oArt(), oKtg()
*  lOkay := .t.
*  for i := 1 to len(aNF1)
*    * cIdArt := trim(aNF1[i][NF1_TYPE]) + qte2art(aNF1[i][NF1_QTE])
*    * cIdArt := padr(cIdArt,LenIdArt())
*    * if ArtExist(cIdArt)
*    *   * cPrix := KrlPrix(aNF1[i][NF1_DATE])
*    *   cPrix := ArtKrlPrix(aNF1[i][NF1_DATE])
*    * else
*    *   lOkay := .f.
*    *   exit
*    * endif
*    cPrix := aNF1[i][NF1_PRIX]
*    if KtgPop(aNF1[i][NF1_DATE],aNF1[i][NF1_QTE],aNF1[i][NF1_TYPE])
*      if KTG->Faktor != "100"
*        cPrix := ntom(val(cPrix)*val(KTG->Faktor)/100)
*      endif
*      nf := NIL
*      for j := 1 to len(aNF)
*        if aNF[j][NF_IDART] == aNF1[i][NF1_IDART] ;
*            .and. aNF[j][NF_IDKTG] == KTG->IdKtg ;
*            .and. aNF[j][NF_PRIX] == cPrix
*          nf := aNf[j]
*          exit
*        endif
*      next j
*      if nf == NIL
*        nf := array(NF_ALEN)
*        nf[NF_IDART] := aNF1[i][NF1_IDART] // cIdArt
*        * nf[NF_TYPE] := aNF1[i][NF1_TYPE]
*        nf[NF_IDKTG] := KTG->IdKtg
*        nf[NF_PRIX] := cPrix
*        if aNF1[i][NF1_VIPO] == "X"
*          nf[NF_MONT2] := ""
*        else
*          nf[NF_MONT2] := ArtField(padr("SK",LenIdArt()),;
*             {||ArtKrlPrix(aNF1[i][NF1_DATE])})
*        endif
*        nf[NF_COUNT] := 1
*        nf[NF_DAYS] := strtran(str(day(aNF1[i][NF1_DATE]),2)," ","0")
*        aadd(aNF,nf)
*      else
*        nf[NF_COUNT] += 1
*        nf[NF_DAYS] := nf[NF_DAYS]+", ";
*                       + strtran(str(day(aNF1[i][NF1_DATE]),2)," ","0")
*      endif
*    else
*      SetMsg("KtgPop() failed!")
*      lOkay := .f.
*    endif
*  next i
*close area
*if ! lOkay
*  SendConsole(;
*    "Problem beim Erstellen von KRG "+ltrim(KRG->IdKrg)+": "+SetMsg())
*  KRG->Etat := "!"
*endif
*RETURN aNF





FUNCTION qte2art(nQte)
// local nQte := nf[NF_QTE]
RETURN "0.25" if nQte < 0.33
RETURN "0.33" if nQte < 0.50
RETURN "0.50" if nQte < 0.66
RETURN "0.66" if nQte < 0.75
RETURN "0.75" if nQte < 1.00
RETURN "1.00" if nQte < 1.25
RETURN "1.25" if nQte < 1.33
RETURN "1.33" if nQte < 1.50
RETURN "1.50" if nQte < 1.66
RETURN "1.66" if nQte < 1.75
RETURN "1.75" if nQte < 2.00
RETURN "2.00"
// RETURN strtran(str(nf[NF_QTE],4,2)," ","0")

* bis 20070206
* FUNCTION qte2art(nQte)
* // local nQte := nf[NF_QTE]
* RETURN "0.25" if nQte <= 0.29
* RETURN "0.33" if nQte <= 0.39
* RETURN "0.50" if nQte <= 0.58
* RETURN "0.66" if nQte <= 0.70
* RETURN "0.75" if nQte <= 0.88
* RETURN "1.00" if nQte <= 1.12
* RETURN "1.25" if nQte <= 1.29
* RETURN "1.33" if nQte <= 1.39
* RETURN "1.50" if nQte <= 1.58
* RETURN "1.66" if nQte <= 1.70
* RETURN "1.75" if nQte <= 1.88
* RETURN "2.00"
* // RETURN strtran(str(nf[NF_QTE],4,2)," ","0")

FUNCTION KrlPostEdit()
RETURN .f. if ! ArtExist(KRL->IdArt)
* KRL->Mont1 := ART->Prix1
* KRL->Mont2 := ART->Prix2
RETURN .t.

#define TPLTYPE_KRG "KRG"

**
** KrgPrint()
**
FUNCTION KrgPrint(cIdTpl)
static scIdTpl
local tpl
default cIdTpl to PickTpl( ;
  TPLTYPE_KRG, scIdTpl, MemLang1, ;
  NIL, "Rechnung drucken" ;
)
RETURN .f. if cIdTpl == NIL
if (tpl := TplValue(TPLTYPE_KRG,cIdTpl,{||TplInfo()})) == NIL
  SetMsg(TPLTYPE_KRG+"/"+cIdTpl + MsgTplExist())
  // Warning(cIdTpl + " : unbekannte Druckmaske")
  RETURN .f.
endif
SetDlgTitle(tpl[TPL_NAME])
open area oPar()
  if OpenPrinter( ;
      tpl[TPL_IDOPT],NIL,tpl[TPL_WIDTH], ;
      NIL,NIL,NIL,tpl[TPL_IDDLG] ;
    )
    p_MsgDisplay(tpl[TPL_NAME])
    scIdTpl := tpl[TPL_IDTPL]
    TplParse(tpl[TPL_MEMO])
    ClosePrinter()
  endif
close area
SetMnuDone()
RETURN .t.

*#define KK_ID  1
*#define KK_QTE 2
*#define KK_PHASE 3
*#define KK_ALEN 3
*
*FUNCTION SesSetPhase()
*local lOkay := .f.
**local aTest
**local aNorm
** local a
*local nTests
*local cQte
** local nQte := 0
** local nQteT := 0
*local cPhase := "A"
*local nSkip := 0
*open area oKtg(), oSes()
*  ddSetOrder 2 in SES
*  lOkay := .t.
*  go top
*  do while lOkay .and. !eof()
*    cPhase := "A"
*    nTests := 0
*    // nQte := 0
*    cQte := "      0:00"
*    // aNorm := { "N", 0, "A" } // KK_ALEN
*    // aTest := { "T", 0, "A" } // KK_ALEN
*    select SES
*    softseek dtos(KTG->Date1)
*    do while lOkay.and.!eof().and.SES->Date<=KTG->Date2
*      MsgDisplay(dtoc(SES->Date)+" "+cPhase)
*      if TaskInter() ; lOkay := .f. ; exit ; endif
*      if SES->Etat == "F"
*        if nSkip == 0
*          cQte := TimeAdd(cQte,TimeDiff(SES->Von,SES->Bis))
*          // nQte += qton(TimeDiff(SES->Von,SES->Bis))
*          if t2hours(cQte) <= t2hours(KTG->QteA)
*            cPhase := "A"
*          elseif t2hours(cQte) <= t2hours(KTG->QteB)
*            cPhase := "B"
*          else
*            cPhase := "C"
*          endif
*          if SES->Type == "T"
*            nTests += 1
*            if nTests > KTG->NumTests
*              cPhase := "C"
*            endif
*          endif
*          if SES->GCount > 0
*            nSkip := SES->GCount-1
*          endif
*        else
*          nSkip -= 1
*        endif
*      else
*        cPhase := " "
*      endif
*      if SES->Phase != cPhase
*        if ddRecLock()
*          SES->Phase := cPhase
*          unlock record
*        else
*          lOkay := .f.
*        endif
*      endif
*      skip
*    enddo
*    select KTG
*    skip
*  enddo
*close area
*RETURN lOkay

FUNCTION KtgExist(cIdKtg)
RETURN .t. if KTG->IdKtg == cIdKtg
seek cIdKtg in KTG
if ! (eof() in KTG)
  RETURN .t.
endif
RETURN !SetMsg(cIdKtg+" : ungltige Kontingentnummer!")

FUNCTION KrgCol(n,cSesType)
local cInami
local lOkay := .t.
local nCount := 0
local nMont
local nMont2
local cIdArt
local cMont
local cIdKtg
local xlFilter
if empty(cSesType)
  xlFilter := 'left(KRL->IdArt,1)!="T"'
else
  xlFilter := 'left(KRL->IdArt,1)=="'+cSesType+'"'
endif
** n = 1 : "Die Pseudocodenummer der Nomenklatur"
** n = 2 : Anzahl oder Datum
** n = 3 : Sitzungspreis
** n = 4 : Sitzungspreis Anteil KK
** n = 5 : Sitzungspreis Anteil Patient
open area oKrl(),oArt(),oKtg(), oPrj()
  softseek KRG->IdKrg
  do while lOkay .and. !eof().and.KRL->IdKrg==KRG->IdKrg
    *if trim(KRL->IdKtg) == KTG_DG
    *  skip
    *else
      if ArtExist(KRL->IdArt)
        cIdKtg := KRL->IdKtg
        cIdArt := KRL->IdArt
        cMont  := KRL->Mont
        nCount := 0 // Anzahl Sitzungen
        nMont := 0 // Gesamtpreis der Sitzungen (KK+Kind)
        nMont2 := 0 // Anteil Patient
        do while lOkay .and. !eof() .and. KRL->IdKrg==KRG->IdKrg ;
                       .and. KRL->IdArt == cIdArt ;
                       .and. KRL->Mont  == cMont  ;
                       .and. KRL->IdKtg == cIdKtg
          if &xlFilter
            nCount += 1
            if !empty(KRL->Mont)
              nMont += val(KRL->Mont) - val(KRL->Mont2)
            endif
            nMont2 += val(KRL->Mont2)
            if n == 1
              if trim(KRL->IdKtg) != KTG_DG
                if nCount == 1
                  if KtgExist(KRL->IdKtg)
                    seek KRG->IdPrj1 in PRJ
                    if left(KRL->IdArt,1)=="T".and.trim(PRJ->Type)!="?";
                      .and.!empty(KRG->IdPrj2)
                      seek KRG->IdPrj2 in PRJ
                    endif
                    * if left(KRL->IdArt,1)=="T"
                    *   seek KRG->IdPrj2 in PRJ
                    * else
                    *   seek KRG->IdPrj1 in PRJ
                    * endif
                    cInami := xparse("ART->INAMI"+PRJ->Zentrum+KTG->Phase)
                    if cInami == NIL
                      lOkay := .f.
                      SetMsg("ART->INAMI"+PRJ->Zentrum+KTG->Phase;
                        +" : ungltige Kombination fr INAMI-Code")
                    else
                      toStream( xparse("ART->INAMI"+PRJ->Zentrum+KTG->Phase) )
                    endif
                  endif
                endif
              endif
            elseif n == 2
              if nCount > 1
                toStream(", ")
              endif
              toStream( ntrim(day(KRL->Date)) )
            endif
          endif
          skip
        enddo
        if nCount > 0
          if n == 3
            toStream( ltrim(ntomf((nMont+nMont2)/nCount)) )
          elseif n == 4
            toStream( ltrim(ntomf(nMont)) )
          elseif n == 5
            toStream( ltrim(ntomf(nMont2)) )
          endif
          toStream("\par ")
        endif
      else
        lOkay := .f.
      endif
    * endif
  enddo
  if empty(cSesType) .and. !empty(KRG->MontKrm)
    if n == 1
      toStream( "783.871 " )
    elseif n == 2
      toStream( alltrim(KRG->QteKrm) + " Stunden "  )
    elseif n == 4
      toStream( ltrim(ntomf(val(KRG->MontKrm)))+" " )
    endif
  endif
close area
RETURN lOkay

FUNCTION KrgTot4() // Total zu Lasten der KK
RETURN val(KRG->Mont1)+val(KRG->Mont1T);
  -val(KRG->Mont2)-val(KRG->Mont2T);
  +val(KRG->MontKrm)

FUNCTION KrgTot5() // Total zu Lasten des Patienten
RETURN val(KRG->Mont2)+val(KRG->Mont2T)

FUNCTION KrgTot6() // Total Total
RETURN val(KRG->Mont1)+val(KRG->Mont1T)+val(KRG->MontKrm)

/*

  Make a copy of all sessions in period dDate1-dDate2 (only those
  satisfying xlFilter if specified), moving them to dDate3.

*/
FUNCTION SesClone(dDate1,dDate2,dDate3,nNum,xlFilter)
local lOkay := .f.
local a := {}
local i, j
local cIdSes
local nOffset := dDate3-dDate1
default xlFilter to ".t."
open area oSes()
  lOkay := .t.
  ddSetOrder(2) // Date+Von+Bis
  softseek dtos(dDate1)
  do while !eof() .and. SES->Date <= dDate2
    if &xlFilter
      aadd(a, CopyRec())
    endif
    skip
  enddo
  if len(a)== 0
    SetMsg("Keine Sitzungen gefunden im Datumsbereich ";
      +dtoc(dDate1)+"-"+dtoc(dDate2))
  elseif Confirm(ntrim(len(a))+" Sitzungen werden kopiert")
    for j := 1 to nNum
      nOffset := dDate3-dDate1
      for i := 1 to len(a)
        cIdSes := DbfAutoInc(oSes())
        if dbAddRec()
          PasteRec(a[i])
          SES->IdSes := cIdSes
          SES->Date += nOffset
          unlock record
        else
          lOkay := .f.
        endif
      next i
      dDate3 += (dDate2-dDate1+1)
    next j
  endif
close area
RETURN lOkay

#endif DEF_KITZ

#ifdef DEF_VEN

FUNCTION VenIsOpen()
RETURN VEN->Etat != DocStatClosed()

#endif

FUNCTION mapto(x,a1,a2,u)
local i
for i := 1 to len(a1)
  RETURN a2[i] if a1[i] == x
next i
RETURN u

