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

**
**  Table of contents :
**
**  PREEDIT_METHODS
**  (FAST) POSTEDIT_METHODS
**  LINE_METHODS
**  EXIST_METHODS
**

#ifdef LG_FRENCH
  #define MSG001  "Refus‚. Ce rendez-vous est cl“tur‚."
  #define MSG006  "Compte : obligatoire"
  #define MSG007  " : Type de compte invalide"
  #define MSG011  " : Tarif inconnu."
  #define MSG012  " : Quantit‚ < ou = 0 !"
  #define MSG013  "Client obligatoire si un montant est sp‚cifi‚ !"
  * #define MSG015  " : Cat‚gorie invalide."
  #define MSG016  " : Compte g‚n‚ral inconnu."
  * #define MSG018  " : Code TVA invalide !"
  * #define MSG025  "Devise invalide."
  * static MSG026 := "Sp‚cifiez les comptes d'imputation (ou remplissez par des '*')"
  * #define MSG027  "Tapez O pour cl“turer quand-mˆme :"
  #define MSG028  " : groupe d'articles inconnu."
  #define MSG029  " : Article inconnu."
  * #define MSG030  " : fournisseur inconnu."
  * #define MSG031  " : tarif invalide."
  #define MSG032  " : partenaire inconnu."
  * #define MSG033  " : devise invalide !"
  * static MSG034 := " : mode de paiement inconnu !"
  static MSG_READONLY := " : enregistrement prot‚g‚ en ‚criture !"
#endif
#ifdef LG_GERMAN
  #define MSG001  "Verweigert. Dieser Termin ist registriert."
  #define MSG006  "Konto : darf nicht leer sein."
  #define MSG007  " : ungltige Kontenart."
  #define MSG011  " : ungltiger Tarif."
  #define MSG012  " : Bestand < oder = 0 !"
  #define MSG013  "Feld 'Kunde' obligatorisch wenn Betrag angegeben !"
  * #define MSG015  " : ungltige Kategorie."
  #define MSG016  " : unbekanntes Generalkonto."
  * #define MSG018  " : ungltiger MWSt-Code !"
  * #define MSG025  "Ungltige W„hrung."
  * #define MSG027  "J um Dokument dennoch zu registrieren :"
  #define MSG028  " : unbekannte Artikelgruppe."
  #define MSG029  " : unbekannter Artikel."
  * #define MSG030  " : unbekannter Lieferant."
  * #define MSG031  " : unbekannter Tarif."
  #define MSG032  " : unbekannter Partner."
  * #define MSG033  " : unbekannte W„hrung !"
  * static MSG034 := " : unbekannte Zahlart !"
  static MSG_READONLY := " : dieser Record ist schreibgeschtzt !"
#endif
#ifdef LG_EN
  #define MSG001  "Refused. This meeting is closed."
  #define MSG006  "Account : cannot be empty."
  #define MSG007  " : invalid account type."
  #define MSG011  " : unknown tariff."
  #define MSG012  " : Stock less or = 0 !"
  #define MSG016  " : no such general account."
  * static MSG026 := "Geben Sie die Buchungskonten EK und VK an (bzw. '*') ! "
  * #define MSG027  "J um Dokument dennoch zu registrieren :"
  #define MSG028  " : no such product group."
  #define MSG029  " : no such product"
  #define MSG032  " : no such partner."
  * static MSG034 := " : unbekannte Zahlart !"
  static MSG_READONLY := " : record is read-only !"
#endif


static scIdPrt  := NIL
static scIdPrf  := NIL
static scExpr   := NIL

#ifdef DEF_PRESTO

**
** TrmPreEdit
**
FUNCTION TrmPreEdit(b)
RETURN .T. if ! "R" $ AgsAttrib(TRM->Etat)
SetMsg(MSG001) // modification interdite. Ce rendez-vous est cl“tur‚.")
RETURN .F.

#endif DEF_PRESTO

**
** GenPreEdit
**
FUNCTION GenPreEdit()
if GENATTR_R $ GEN->Attrib
  SetMsg(GEN->IdGen + MSG_READONLY )
  RETURN .f.
endif
RETURN .t. if USRATTR_B $ UsrAttrib()
Warning(MsgNoAccess(),NIL,"WRN028")
RETURN .F.

#ifdef DEF_ART

**
** ArtPostEdit
**
FUNCTION ArtPostEdit
RETURN .f. if ! OnTest(oArt())
RETURN .t. if empty(ART->IdCat)
#ifdef DEF_IPB
  RETURN .f. if ! CtaExist(ART->IdCat)
#endif DEF_IPB
RETURN .t.

FUNCTION ArtPreEdit()
if ARTATTR_R $ ART->Attrib
  SetMsg(ART->IdArt + MSG_READONLY )
  RETURN .f.
endif
RETURN .t.

#endif DEF_ART


FUNCTION ParPreEdit()
* if PARATTR_R $ PAR->Attrib
*   SetMsg(trim(ParName()) + MSG_READONLY )
*   RETURN .f.
* endif
* #ifdef DEF_CONSOLE
*   SendConsole("PAR modify " + PAR->IdPar + " : " + ParName())
* #endif DEF_CONSOLE
RETURN .t.



#ifdef DEF_GEN

FUNCTION GenPostedit()
* local ctf
if ! empty(GEN->IdCtr)
  RETURN .f. if ! CtrExist(GEN->IdCtr)
endif
if len(trim(GEN->IdGen)) == LenIdGen()
  #ifdef DEF_HST
    if ! empty(GEN->IdClj)
      RETURN .f. if ! CljExist(GEN->IdCtr,GEN->IdClj)
    endif
  #endif DEF_HST
  #ifdef DEF_TAX
    if ! empty(GEN->IdTax)
      RETURN .f. if ! TaxExist(GEN->IdCtr,GEN->IdTax)
    endif
  #endif DEF_TAX
  RETURN .t.
else
  * GEN->IdClj := ""
  * #ifdef DEF_TAX
  *   GEN->IdTax := ""
  * #endif DEF_TAX
  RETURN .t.
endif
RETURN .f.

#endif DEF_GEN


FUNCTION ParMfcValidate()
RETURN .t. if empty(PAR->IdMfc)
#ifdef DEF_JNL
  RETURN .f. if ! ParIfcExist()
#endif DEF_JNL
RETURN .t.


#ifdef DEF_FIN

**
** FinPreEdit()
**
FUNCTION FinPreEdit(cId)
if cId != NIL
  if FIN->IdJnl + FIN->IdDoc != cId
    seek cId in FIN
  endif
endif
RETURN .T. if FIN->Etat == DocStatOpen()
RETURN .T. if FIN->Etat == DocStatNew()
SetMsg(MsgIdJnlDoc() + MsgIsClosed(), NIL, "WRN053")
RETURN .F.

**
** FinPostEdit()
**
FUNCTION FinPostEdit
local jnl := JnlLocate(FIN->IdJnl)
RETURN .f. if jnl == NIL
if ! CheckIdDoc(jnl,FIN->IdDoc,FIN->Periode)
  * SetMsg(MsgIdJnlDoc() + " : " + SetMsg())
  RETURN .f.
endif
if FIN->Etat == DocStatNew()
  if nKey == K_ENTER .or. nKey == K_F10 .or. nKey == K_PGDN
    FinFnlEdit()
  endif
endif
RETURN .T. // PerChkDate(FIN->Periode,FIN->Date)



**
** CptExist()
**
FUNCTION CptExist(cCptType,cCompte)
if empty(cCompte)
  SetMsg(MSG006) // "Compte : obligatoire.")
  RETURN .F.
endif
#ifdef DEF_GEN
  RETURN GenExist(cCompte) if empty(cCptType) // == CPTTYPE_GEN
#endif
RETURN ParExist(cCompte) if CtrLocate(cCptType) != NIL
SetMsg(cCptType + MSG007)
RETURN .F.

#endif DEF_FIN

#ifdef DEF_ODS

**
** OdsPreEdit()
**
FUNCTION OdsPreEdit
RETURN .T. if ODS->Etat == DocStatOpen()
RETURN .T. if ODS->Etat == DocStatNew()
Warning(MsgIdJnlDoc() + MsgIsClosed(), NIL, "WRN053")
RETURN .F.

**
** OdsPostEdit()
**
FUNCTION OdsPostEdit
if ODS->Etat == DocStatNew()
  if nKey == K_ENTER .or. nKey == K_F10 .or. nKey == K_PGDN
    OdsOdlEdit()
  endif
endif
RETURN .T.

#endif DEF_ODS



#ifdef DEF_IVT

**
** IvtPreEdit()
**
FUNCTION IvtPreEdit(dDate)
if dDate != NIL
  if IVT->Date != dDate
    seek dtos(dDate) in IVT
    if eof() in IVT
      Warning("Anomalie : Keine Inventur vorhanden am " + dtoc(dDate))
      RETURN .T.
    endif
  endif
endif
if IVT->Etat == DocStatClosed()
  SetMsg("IVT" + MsgIsClosed())
  RETURN .F.
endif
RETURN .T.


**
** IvlPostEdit()
**
FUNCTION IvlPostEdit()
RETURN .F. if ! ArtExist(IVL->IdArt)
IvlValPrix()
#ifdef DEF_GRA
  seek ART->iGra in GRA
  SetMsg(GRA->Name1)
#endif DEF_GRA
if val(IVL->Qte) <= 0
  Warning(IVL->IdArt + MSG012 )
endif
RETURN .T.

FUNCTION IvtSetDirty(dDate)
open area oIvt()
  seek dtos(IVL->Date)
  if eof()
    Warning("Anomalie : Keine Inventur vorhanden am " + dtoc(dDate))
  else
    if ddRecLock()
      IVT->Etat := DocStatNew()
      unlock record
    endif
  endif
close area
RETURN NIL


#endif DEF_IVT

#ifdef DEF_PRESTO

**
** TrmPostEdit
**
FUNCTION TrmPostEdit()
local c
* if empty(TRM->Attrib)
*   if (c := PickAga(TRM->Attrib) ) == NIL
*     TRM->Attrib := "-"
*   else
*     TRM->Attrib := c
*   endif
* endif
if ! empty(TRM->IdPar)
  RETURN .f. if ! ParExist(TRM->IdPar)
endif
#ifdef DEF_PRJ
  if ! empty(TRM->IdPrj)
    RETURN .f. if ! PrjExist(TRM->IdPrj)
  endif
#endif DEF_PRJ
if ! empty(TRM->IdTac)
  RETURN .f. if ! TacExist(TRM->IdTac)
endif
RETURN .t.
*if TrmDuree()
*  * if empty(TRM->Etat)
*  *   TRM->Etat := ASTAT_PREVU
*  * endif
*  if val(TRM->Presta) != 0
*    if empty(TRM->IdPar)
*      SetMsg(MSG013) // "Client obligatoire si un tarif est sp‚cifi‚ !")
*      RETURN .F.
*    endif
*    RETURN ParExist(TRM->IdPar)
*  endif
*  RETURN .T.
*endif
*RETURN .F.

FUNCTION TrmTimeValidate
if ! empty(TRM->Fin) .and. ! empty(TRM->Debut)
  TRM->Duree := padl(TimeDiff(TRM->Debut,TRM->Fin),6)
endif
RETURN ph_refresh()

#endif DEF_PRESTO

**
** EXIST_METHODS
**
**

#ifdef DEF_GEN

**
** GenExist()
**
FUNCTION GenExist( cId )
if GEN->IdGen == cId .and. ! eof() in GEN
  RETURN .t. // ! see 20071112
endif
seek cId in GEN
if eof() in GEN
  SetMsg(cId + MSG016) // "Compte g‚n‚ral " + cId + " : inconnu." )
  RETURN .F.
endif
RETURN .T.

#endif DEF_GEN

#ifdef DEF_BIL

**
** BilExist()
**
FUNCTION BilExist( cId )
if BIL->IdBil == cId .and. ! eof() in BIL
  RETURN .t.
endif
seek cId in BIL
if eof() in BIL
  #ifdef LG_GERMAN
  SetMsg(cId + " : unbekannter Bilanzposten !")
  #endif
  #ifdef LG_FRENCH
  SetMsg(cId + " : compte de bilan inconnu !")
  #endif
  #ifdef LG_EN
  SetMsg(cId + " : no such balance account !")
  #endif
  RETURN .f.
endif
RETURN .t.

#endif DEF_BIL


#ifdef DEF_GRA

**
** GraExist()
**
FUNCTION GraExist( cId )
if GRA->iGra == cId .and. ! eof() in GRA
  RETURN .T.
endif
seek cId in GRA
if eof() in GRA
  SetMsg(cId + MSG028) // " : groupe d'articles inconnu." )
  RETURN .F.
endif
RETURN .T.

FUNCTION GraPreEdit()
if GRAATTR_R $ GRA->Attrib
  SetMsg(GRA->iGra + MSG_READONLY )
  RETURN .f.
endif
RETURN .t.

#endif DEF_GRA

#ifdef DEF_ART

FUNCTION ArtExist(cId)
if ART->IdArt == cId .and. ! eof() in ART
  RETURN .T.
endif
seek cId in ART
if eof() in ART
  SetMsg(cId + MSG029 )
  RETURN .F.
endif
RETURN .T.

#endif DEF_ART

#ifdef DEF_IMP

FUNCTION BudExist(cIdCtr,cIdBud)
if BUD->DC == cIdCtr .and. BUD->IdBud == cIdBud .and. ! eof() in BUD
  RETURN .T.
endif
seek cIdCtr + cIdBud in BUD
if eof() in BUD
  SetMsg(cIdCtr + "-" + SayIdBud(cIdBud) + MSG029 ) // " Article inconnu." )
  RETURN .F.
endif
RETURN .T.

#endif DEF_IMP


#ifdef DEF_ANA

FUNCTION AnaExist(cId)
if (ANA->IdAna == cId) .and. ! eof() in ANA
  RETURN .t.
endif
seek cId in ANA
if eof() in ANA
  SetMsg(cId + " : unbekanntes Analysekonto.")
  RETURN .F.
endif
RETURN .T.

#endif DEF_ANA


FUNCTION MsgParExist(cId)
RETURN cId + MSG032

FUNCTION MsgTplExist(cId)
default cId to ""
RETURN cId + " : unbekannte Druckmaske."

FUNCTION ParExist(cId)
if PAR->IdPar == cId .and. ! (eof() in PAR)
  RETURN .t. // 20071112
endif
seek cId in PAR
if eof() in PAR
  SetMsg(MsgParExist(cId)) // + MSG032)
  RETURN .f.
endif
RETURN .t.

FUNCTION PlzExist(cIdNat,cIdPlz)
if PLZ->Pays+PLZ->CP == cIdNat+cIdPlz .and. ! eof() in PLZ
  RETURN .t.
endif
seek cIdNat+cIdPlz in PLZ
if eof() in PLZ
  SetMsg(trim(cIdNat) + "-" + trim(cIdPlz) + MsgPlzExist())
  RETURN .f.
endif
RETURN .t.

FUNCTION MsgPlzExist()
#ifdef LG_FRENCH
  RETURN " : Code postal inconnu !"
#else
  RETURN " : unbekannte Postleitzahl !"
#endif


#ifdef DEF_PRJ

FUNCTION PrjExist(cId)
if PRJ->IdPrj == cId .and. ! (eof() in PRJ)
  RETURN .t.
endif
seek cId in PRJ
if eof() in PRJ
  SetMsg(cId + " : unbekanntes Projekt !" )
  RETURN .F.
endif
RETURN .T.

#endif DEF_PRJ

#ifdef DEF_DEV

FUNCTION CoursValidate(cIdDev)
RETURN .t. if ! DevExist(cIdDev)
if empty(FIELD->Cours)
  FIELD->Cours  := DocDevCours(cIdDev,FIELD->Periode)
endif
RETURN .T.

FUNCTION DevExist(cId)
if DevLocate(cId) == NIL
  SetMsg(cID + MsgDevExist()) // MSG033 ) // " : devise invalide." )
  RETURN .F.
endif
RETURN .T.

#endif DEF_DEV


FUNCTION qSum(cQte1,cQte2)
local nSum := qton1(cQte1) + qton1(cQte2)
local nDec := max(MntDecPos(cQte1),MntDecPos(cQte2))
* RETURN "" if empty(cQte1+cQte2)
RETURN ntoq(nSum,":") if ":" $ cQte1 + cQte2
RETURN str(nSum,len(cQte1),nDec)

#ifdef DEF_HOLZ

* FUNCTION StmVerkauf
* static sdDate := NIL
* default sdDate to UserDate()
* open window ("Verkauf") size 3,50
* say "Datum "
* @ row(), col() get sdDate
* nKey := ReadScr()
* close window
* RETURN MnuDone() if nKey == K_ESC
* if ddRecLock()
*   STM->Verkauf := sdDate
*   unlock record
*   ddRefreshCurrent()
* endif
* RETURN MnuDone()

#endif DEF_HOLZ

FUNCTION ValPrompt(cPrompt)
RETURN cPrompt if "~" $ cPrompt
RETURN "~" + left(cPrompt,len(cPrompt)-1)

FUNCTION CtrPostEdit()
* if empty(PRT->CptType)
*   SetMsg("ID : darf nicht leer sein !")
*   RETURN .f.
* endif
RETURN .t.

FUNCTION CtrPreEdit()
local lOkay := .f.
RETURN .t. // lOkay


#ifdef DEF_SPC

*FUNCTION SpcPostEdit
*local cIdDev
*RETURN .f. if ! ArtExist(SPC->IdArt)
*if empty(SPC->IdPar)
*  cIdDev := DevDefault(PerActive())
*else
*  RETURN .f. if ! ParExist(SPC->IdPar)
*  cIdDev := PAR->IdDev
*endif
*SPC->PrixU := ntom(val(SPC->PrixU),DevDecPos(cIdDev))
*SPC->PrixT := ntom(val(SPC->PrixT),DevDecPos(cIdDev))
*RETURN .t.

*FUNCTION SpcPuValidate
*local cIdDev
*local ipb
*local cIdTax
*RETURN .f. if ! ArtExist(SPC->IdArt)
*if empty(SPC->IdPar)
*  cIdDev := DevDefault()
*else
*  RETURN .f. if ! ParExist(SPC->IdPar)
*  cIdDev := PAR->IdDev
*endif
*cIdTax := RegIdTax(PAR->IdReg)
*if empty(cIdTax)
*  ipb := IpbLocate(SPC->IdCtr,PAR->IdReg,ART->IdCat))
*RETURN .f. if ipb == NIL
*open area oGen()
*  if GenExist(ipb[IPB_GENBASE])
*SPC->PrixT := ntom(val(SPC->PrixT),DevDecPos(PAR->IdDev))


#endif DEF_SPC

#ifdef DEF_ACF

FUNCTION AcfPostEdit
if empty(ACF->IdDev)
  if ParExist(ACF->IdPar)
    if empty(PAR->IdDev)
      ACF->IdDev := DevDefault(PerActive())
    else
      ACF->IdDev := PAR->IdDev
    endif
  endif
endif
RETURN .f. if ! ArtExist(ACF->IdArt)
if !empty(ACF->Packing)
  ACF->Packing := ntoq(qton(ACF->Packing),ART->QteForm)
endif
if empty(ACF->Date)
  ACF->Date := UserDate()
endif
RETURN .t.

#endif DEF_ACF

FUNCTION ParSetFilter(cExpr)
RETURN scExpr if cExpr == NIL
scExpr := cExpr
scIdPrt := NIL
scIdPrf := NIL
RETURN NIL

FUNCTION ParFltText
local cFltText := ""
if ! empty(scIdPrt) ; cFltText += scIdPrt + " " ; endif
if ! empty(scIdPrf) ; cFltText += trim(scIdPrf) + " " ; endif
cFltText += scExpr
RETURN cFltText

FUNCTION ParEvalFilter
if empty(scIdPrf) .or. PAR->Prof == scIdPrf
  if empty(scIdPrt) .or. PAR->IdPrt == scIdPrt
    if empty(scExpr) .or. &scExpr
      RETURN .t.
    endif
  endif
endif
RETURN .f.


#ifdef DEF_IMP

FUNCTION ParPickFilter()
RETURN NIL if ! ParGetFilter()
RETURN ddSetFilter("ParEvalFilter()", ParFltText())

FUNCTION ParGetFilter()
local bFilter := NIL
default scIdPrt    to space(LEN_IDPRT)
default scIdPrf    to space(LEN_IDPRF)
if scExpr == NIL
  scExpr := space(128)
else
  scExpr := padr(scExpr,128)
endif
open window ("Partnerfilter") size 5,40 help PARFILT
say "Nur Partnerart "
@ CSR_POS get scIdPrt ;
          picture PIC_ID pick PickPrt(scIdPrt,NIL,scIdPrt,PRT_ID)
WinCr()
say "Nur Berufsgruppe "
@ CSR_POS get scIdPrf ;
          picture PIC_ID pick PickPrf(scIdPrf)
WinCr()
say "Sonstige "
get scExpr picture "@K@S27"
nKey := ReadScr()
close window
scExpr := trim(scExpr)
RETURN .f. if nKey == K_ESC
RETURN .t.

#endif DEF_IMP

#ifdef DEF_TAX

FUNCTION TaxPostEdit()
#ifdef DEF_GEN
  if ! empty(TAX->IdGen)
    RETURN .f. if ! GenExist(TAX->IdGen)
    if GEN->IdCtr != TAX->IdCtr
      SetMsg(TAX->IdGen + " : " + GEN->IdCtr + MsgCtrExist())
    endif
  endif
  if ! empty(TAX->GenTiers)
    RETURN .f. if ! GenExist(TAX->GenTiers)
    if GEN->IdCtr != TAX->IdCtr
      SetMsg(TAX->GenTiers + " : " + GEN->IdCtr + MsgCtrExist())
    endif
  endif
#endif DEF_GEN
RETURN .t.

#endif DEF_TAX

#ifdef DEF_MVA

**
** OdaPreEdit()
**
FUNCTION OdaPreEdit()
RETURN .T. if ODA->Etat == DocStatOpen()
RETURN .T. if ODA->Etat == DocStatNew()
Warning(MsgIdJnlDoc() + MsgIsClosed(), NIL, "WRN053")
RETURN .F.

FUNCTION OdaPostEdit()
RETURN .f. if ! GenExist(ODA->IdGen)
if ODA->Etat == DocStatNew()
  OdaMvaEdit()
endif
RETURN .t.


#endif DEF_MVA

#ifdef DEF_IMP

FUNCTION BudPreEdit()
if PARATTR_R $ BUD->Attrib
  SetMsg(BUD->DC + "-" + trim(SayIdBud(BUD->IdBud)) + MSG_READONLY )
  RETURN .f.
endif
SendConsole("BUD modify " + BUD->DC + "-" + trim(SayIdBud(BUD->IdBud)) )
RETURN .t.


#endif DEF_IMP

#ifdef DEF_JNL

FUNCTION DocDevValidate()
RETURN .f. if ! DevExist(FIELD->IdDev)
if FIELD->Etat != DocStatClosed()
  FIELD->Cours := DocDevCours(FIELD->IdDev,FIELD->Periode)
  FIELD->Etat  := DocStatNew()
endif
// ddRefreshCurrent()
RETURN .t.


FUNCTION DocDateValidate(cIdDevPar)
local cIdJnl := FIELD->IdJnl
local jnl := JnlLocate(cIdJnl)
local cPeriode := PerActive(FIELD->Date)
local nOrder := indexord()
local nRecNo := recno()
if jnl != NIL .and. jnl[JNL_ALIAS] == JNLALIAS_FIN
  if JNLATTR_R $ jnl[JNL_ATTRIB]
    cPeriode := PerActive(SkipMonth(FIELD->Date,-1))
  endif
endif
if cPeriode != FIELD->Periode // PerActive() 19981019
  if JNLATTR_G $ jnl[JNL_ATTRIB] .or. JNLATTR_F $ jnl[JNL_ATTRIB]
    ddSetOrder(1) // ORD_VEN_ID oder FIN_ORD_ID
    skip -1
    if FIELD->IdJnl == cIdJnl .and. ! bof()
      if FIELD->Periode > cPeriode
        cPeriode := FIELD->Periode
      endif
    endif
    ddSetOrder(nOrder)
    goto nRecNo
  endif
  FIELD->Periode := cPeriode
  DocPerValidate(cIdDevPar)
endif
RETURN .t.
* RETURN DocPerValidate()

FUNCTION DocPerValidate(cIdDevPar)
if empty(JnlIdDev(FIELD->IdJnl)).and.empty(cIdDevPar)
  FIELD->IdDev := DevDefault(FIELD->Periode)
  DocDevValidate()
endif
RETURN .t.

#endif DEF_JNL

#ifdef DEF_RUN

FUNCTION PosPickCat()
RETURN NIL if ! ParExist(POS->IdPar)
RETURN PickCat(PAR->Sex,POS->IdCat)

FUNCTION PosPostEdit()
RETURN .f. if ! ParExist(POS->IdPar)
if empty(POS->IdCat)
  POS->IdCat := ParCatDefault(RAL->Date)
endif
if empty(POS->IdPos)
  POS->IdPos := PAR->IdPos
elseif POS->IdPos != PAR->IdPos
  select PAR
  TryRecLock({||(PAR->IdPos:=POS->IdPos)!=NIL})
  select POS
endif
RETURN .t.

FUNCTION ClbExpr(cIdClb,xuField)
seek cIdClb in CLB
RETURN xparse(xuField)


#endif DEF_RUN


#ifdef DEF_LIC

FUNCTION LicExist(cId)
if LIC->IdLic == cId .and. ! (eof() in LIC)
  RETURN .t.
endif
seek cId in LIC
if eof() in LIC
  SetMsg(cId + " : unbekannte Lizenz")
  RETURN .f.
endif
RETURN .t.

#endif DEF_LIC

#ifdef DEF_PTG

FUNCTION ResExist(cId)
if RES->IdRes == cId .and. ! (eof() in RES)
  RETURN .t.
endif
seek cId in RES
if eof() in RES
  SetMsg(cId + " : unbekannte Ressource !")
  RETURN .f.
endif
RETURN .t.



#endif DEF_PTG

FUNCTION AttrHasOneOf(cHas,cMustHave)
local i
for i := 1 to len(cMustHave)
  RETURN .t. if substr(cMustHave,i,1) $ cHas
next i
RETURN .f.

FUNCTION AttrHasAllOf(cHas,cMustHave)
local i
for i := 1 to len(cMustHave)
  RETURN .f. if ! substr(cMustHave,i,1) $ cHas
next i
RETURN .t.

