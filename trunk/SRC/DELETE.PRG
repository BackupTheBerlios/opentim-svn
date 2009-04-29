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
** STATIC_SECTION global static variables
**

**
** MSG_SECTION    MSGnnn definitions
**
#ifdef LG_FRENCH
  #define MSG_ART_DELETE " : supprimer cet article (O/N) ?"
  #define MSG_GRA_DELETE " : supprimer ce groupe d'articles (O/N) ?"
  #define MSG001  "Action refus‚e. La p‚riode est cl“tur‚e."
  #define MSG002  "Action refus‚e. Ce type d'activit‚ est utilis‚ dans un rendez-vous"
  * #define MSG003  "Action refus‚e. Ce partenaire possŠde des documents."
  * #define MSG004  "Action refus‚e. Ce fournisseur possŠde des documents achat."
  * #define MSG005  "Action refus‚e. Il existe des articles dans ce groupe."
  #define MSG006  "Tapez O pour supprimer cet inventaire"
  #define MSG007  "Action refus‚e. Supprimez d'abord les paiements."
  * #define MSG008  "Tapez O pour supprimer le document "
  * #define MSG009  "Tapez O pour supprimer le module "
  * #define MSG010  " :"
  static MSG011 := "Refus‚. Utilis‚ dans le document "
  #define MSG012  "Refus‚. Il existe des documents dans le journal "
#endif

#ifdef LG_GERMAN
  #define MSG_ART_DELETE " : Artikel l”schen (J/N) ?"
  #define MSG_GRA_DELETE " : Artikelgruppe l”schen (J/N) ?"
  * #define MSG001  "Verweigert. Periode ist abgeschlossen."
  * #define MSG002  "Verweigert. Dienstleistung benutzt in einem Termin."
  #define MSG005  "Verweigert. Artikel wird in Buchungen benutzt."
  #define MSG006  "J um Inventur zu l”schen :"
  * #define MSG007  "Verweigert. Es existieren Zahlungen zu diesem Dokument."
  static MSG011 := "Verweigert. Wird benutzt in Dokument "
  #define MSG012  "Verweigert. Es existieren Dokumente im Journal "
#endif

#ifdef LG_EN
  #define MSG_ART_DELETE " : Artikel l”schen (J/N) ?"
  #define MSG_GRA_DELETE " : Artikelgruppe l”schen (J/N) ?"
  #define MSG005  "Verweigert. Artikel wird in Buchungen benutzt."
  static MSG011 := "Verweigert. Wird benutzt in Dokument "
  #define MSG012  "Verweigert. Es existieren Dokumente im Journal "
#endif


**
** PROCEDURE_SECTION  - (...grins)
**


FUNCTION ParPreDelete(cIdPar)
RETURN ConfirmDelete() if empty(cIdPar)
if IsArchive(oPar())
  ** wenn PAR selber in einem Archiv steht, dann interessieren uns die
  ** anderen Archive nicht
  RETURN .f. if ! ParCanDelete(cIdPar)
else
  ** wenn es Archive gibt und PAR gemeinsam ist, dann muss jedes Archiv
  ** getestet werden, ob es was gegen das L”schen hat.
  RETURN .f. if ! ArcEval({||ParCanDelete(cIdPar)})
endif
RETURN .f. if ! Confirm( ;
  PAR->IdPar + " " + trim(ParName()) + " :", MsgRecDelete(), ;
  MSG_NO,"WRN012" ;
)
RETURN .t.

FUNCTION ParCanDelete(cIdPar)
local lOkay := .f.
#ifdef DEF_RUN
  open area oPos()
    lOkay := .t.
    ddSetOrder(ORD_POS_PAR)
    softseek PAR->IdPar
    if POS->IdPar == PAR->IdPar
      SetMsg("Action refus‚e. Partenaire inscrit dans au moins une course.")
      lOkay := .f.
    endif
  close area
  RETURN .f. if ! lOkay
#endif DEF_RUN
#ifdef DEF_BIBLIO
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oOut()
    ddSetOrder(ORD_OUT_PAR)
    softseek cIdPar
    if OUT->IdPar == cIdPar
      SetMsg("Verweigert. Es bestehen Ausg„nge [F6].")
    else
      lOkay := .t. // nReturn := DDDEL_NOCONFIRM
    endif
  close area
  RETURN .f. if ! lOkay // DDDEL_FAIL if nReturn == DDDEL_FAIL
#endif DEF_BIBLIO
#ifdef DEF_VEN
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oVen()
    ddSetOrder(ORD_VEN_PAR)
    softseek cIdPar
    if VEN->IdPar != cIdPar
      lOkay := .t. // nReturn := DDDEL_NOCONFIRM
    else
      SetMsg(MSG011 + VEN->IdJnl + " " + VEN->IdDoc)
    endif
  close area
  RETURN .f. if ! lOkay // DDDEL_FAIL if nReturn == DDDEL_FAIL
#endif DEF_VEN
#ifdef DEF_HST
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oHst()
    ddSetOrder(ORD_HST_PARDATE)
    softseek cIdPar
    if HST->IdPar == cIdPar
      SetMsg(MSG011 + MsgIdJnlDoc())
    else
      lOkay := .t. // nReturn := DDDEL_NOCONFIRM
    endif
  close area
  RETURN .f. if ! lOkay // DDDEL_FAIL if nReturn == DDDEL_FAIL
#endif DEF_HST
#ifdef DEF_PLP
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oPlp()
    softseek cIdPar
    if PLP->IdPar1 == cIdPar
      SetMsg("Zuerst Beziehungen l”schen, dann den Partner!")
    else
      lOkay := .t. // nReturn := DDDEL_NOCONFIRM
    endif
  close area
  RETURN .f. if ! lOkay
#endif DEF_PLP
#ifdef DEF_PLS
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oMbr()
    lOkay := .t.
    ddSetOrder(ORD_MBR_PAR)
    softseek cIdPar
    if !bof() .and. !eof() .and. MBR->IdPar == cIdPar
      SetMsg("Zuerst Mitgliedschaften l”schen, dann den Partner!")
      lOkay := .f.
    endif
    ddSetOrder(ORD_MBR_PAR2)
    softseek cIdPar
    if !bof() .and. !eof() .and. MBR->IdPar2 == cIdPar
      SetMsg("Zuerst Sekund„rmitgliedschaften l”schen, dann den Partner!")
      lOkay := .f. // nReturn := DDDEL_NOCONFIRM
    endif
  close area
  RETURN .f. if ! lOkay
#endif DEF_PLS
#ifdef DEF_PRB
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oPpr()
    softseek cIdPar
    if PPR->IdPar == cIdPar
      SetMsg("Zuerst Themen l”schen, dann die Akte!")
    else
      lOkay := .t. // nReturn := DDDEL_NOCONFIRM
    endif
  close area
  RETURN .f. if ! lOkay
#endif DEF_PRB
#ifdef DEF_KITZ
  if HasRecords(oSes(),3,"SES->IdPar",cIdPar)
    RETURN !SetMsg("Zuerst Sitzungen l”schen, dann den Therapeuten!")
  endif
  if HasRecords(oSes(),4,"SES->IdPar2",cIdPar)
    RETURN !SetMsg("Zuerst Sitzungen l”schen, dann den Patienten!")
  endif
#endif DEF_KITZ
#ifdef DEF_ACF
  if HasRecords(oAcf(),ORD_ACF_PAR,"ACF->IdPar",cIdPar)
    RETURN !SetMsg(;
      "Zuerst Sonderpreise l”schen, dann den Partner!") if ;
      !Confirm(trim(ParName()) + " : Sonderpreise l”schen?")
    RETURN .f. if !DbfDelete(NIL,NIL,{oAcf()},;
      ORD_ACF_PAR,PAR->IdPar,"ACF->IdPar=='"+PAR->IdPar+"'")
  endif
#endif DEF_ACF
#ifdef DEF_DLS
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oDls()
    ddSetOrder(ORD_DLS_PARDATE)
    softseek cIdPar
    if DLS->IdPar == cIdPar
      SetMsg("Zuerst Dienstleistungen l”schen, dann die Akte!")
    else
      lOkay := .t. // nReturn := DDDEL_NOCONFIRM
    endif
  close area
  RETURN .f. if ! lOkay
#endif DEF_DLS
#ifdef DEF_DLP
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oDlp()
    ddSetOrder(ORD_DLP_PARDATE)
    softseek cIdPar
    if DLP->IdPar == cIdPar
      SetMsg("Zuerst Anwesenheiten l”schen, dann die Akte!")
    else
      lOkay := .t. // nReturn := DDDEL_NOCONFIRM
    endif
  close area
  RETURN .f. if ! lOkay
#endif DEF_DLP
#ifdef DEF_IMP
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oMvi()
    ddSetOrder(ORD_MVI_PARDATE)
    softseek cIdPar
    if MVI->IdPar != cIdPar
      lOkay := .t. // nReturn := DDDEL_NOCONFIRM
    else
      SetMsg(MSG011 + MVI->IdJnl + " " + MVI->IdDoc)
    endif
  close area
  RETURN .f. if ! lOkay // DDDEL_FAIL if nReturn == DDDEL_FAIL
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oMvi()
    ddSetOrder(ORD_MVI_PAR2DATE)
    softseek cIdPar
    if MVI->IdPar2 != cIdPar
      lOkay := .t. // nReturn := DDDEL_NOCONFIRM
    else
      SetMsg(MSG011 + MVI->IdJnl + " " + MVI->IdDoc)
    endif
  close area
  RETURN .f. if ! lOkay // DDDEL_FAIL if nReturn == DDDEL_FAIL
#endif DEF_IMP
RETURN .t.


FUNCTION utrJnlDelete()
#ifdef LG_GERMAN
RETURN " : Journal l”schen (J/N) ?"
#endif
#ifdef LG_FRENCH
RETURN " : supprimer Journal (O/N) ?"
#endif
#ifdef LG_EN
RETURN " : delete this journal (Y/N) ?"
#endif

**
**
**
FUNCTION JnlPreDelete(cIdJnl)
local lOkay := .f.
if ! USRATTR_B $ UsrAttrib()
  SetMsg(MsgNoAccess())
  RETURN .f.
endif
if !empty(cIdJnl) .and. !JnlIsEmpty(cIdJnl)
  SetMsg(MSG012 + cIdJnl)
  RETURN .f.
endif
RETURN Confirm( ;
  cIdJnl + utrJnlDelete(), NIL, MSG_YES, "JNLDELE" ;
)

FUNCTION JnlIsEmpty(cIdJnl)
local nReturn := .t.
#ifdef DEF_VEN
  if JNL->Alias == "VEN"
    nReturn := .f.
    open area oVen()
      softseek cIdJnl
      if VEN->IdJnl != cIdJnl
        nReturn := .t.
      endif
    close area
  endif
#endif DEF_VEN
#ifdef DEF_FIN
  if JNL->Alias == "FIN"
    nReturn := .f.
    open area oFin()
      softseek cIdJnl
      if FIN->IdJnl != cIdJnl
        nReturn := .t.
      endif
    close area
  endif
#endif DEF_FIN
#ifdef DEF_IMP
  if JNL->Alias == "IMP"
    nReturn := .f.
    open area oImp()
      softseek cIdJnl
      if IMP->IdJnl != cIdJnl
        nReturn := .t.
      endif
    close area
  endif
#endif DEF_IMP
RETURN nReturn

#ifdef DEF_GEN

**
**
**
FUNCTION GenPreDelete(cIdGen)
local lOkay := .f.
* if ! USRATTR_B $ UsrAttrib()
*   Warning(MsgNoAccess())
*   RETURN .f. // DDDEL_FAIL
* endif
#ifdef DEF_HST
  open area oHst()
    ddSetOrder(ORD_HST_GENDATE)
    softseek cIdGen
    if HST->IdGen == cIdGen
      Warning(MSG011 + HST->IdJnl + " " + HST->IdDoc)
    else
      lOkay := .t.
    endif
  close area
  RETURN .f. if ! lOkay
#endif DEF_HST
#ifdef DEF_VEN
  cIdGen := padr(cIdGen,LenObjet())
  open area oVnl(DocStatClosed())
    lOkay := .t.
    ddSetOrder(ORD_VNL_ART)
    seek cIdGen
    do while ! eof() .and. left(FIELD->IdArt,LenIdGen()) == cIdGen
      if FIELD->Code == LNCODE_GEN
        SetMsg(MSG011 + FIELD->IdJnl + " " + FIELD->IdDoc)
        lOkay := .f.
      endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_VEN
RETURN ConfirmDelete() // DDDEL_CONFIRM

#endif DEF_GEN

#ifdef DEF_ART

**
** ArtPreDelete()
**
FUNCTION ArtPreDelete(lConfirm)
local lOkay := .f.
local cId := ART->IdArt
default lConfirm to .t.
RETURN ConfirmDelete() if empty(cId)
MsgDisplay(MsgWorking())
if ArtIsUsed(cId)
  SetMsg(MsgIsUsed())
  RETURN .f.
endif
if lConfirm
  RETURN .f. if ! Confirm( ;
    trim(ART->IdArt) + MSG_ART_DELETE ;
  )
endif
cId := left(cId,LenIdArt())
#ifdef DEF_ACF
  lOkay := .f.
  open area oAcf()
    lOkay := .t.
    ddSetOrder(ORD_ACF_ART)
    softseek cId
    do while ! eof() .and. ACF->IdArt == cId // .and. ! empty(cId)
      if ddRecLock()
        delete
        unlock record
      else
        lOkay := .f.
        exit
      endif
      softseek cId
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_ACF
#ifdef DEF_ALA
  lOkay := .f.
  open area oAla()
    lOkay := .t.
    ddSetOrder(ORD_ALA_ART1)
    softseek cId
    do while ! eof() .and. ALA->IdArt1 == cId // .and. ! empty(cId)
      if ddRecLock()
        delete
        unlock record
      else
        lOkay := .f.
        exit
      endif
      softseek cId
    enddo
    ddSetOrder(ORD_ALA_ART2)
    softseek cId
    do while ! eof() .and. ALA->IdArt2 == cId
      if ddRecLock()
        delete
        unlock record
      else
        lOkay := .f.
        exit
      endif
      softseek cId
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_ALA
RETURN .t.


FUNCTION ArtIsUsed(cId)
local lIsUsed := .f.
#ifdef DEF_VEN
  lIsUsed := .t.
  open area oVnl(DocStatClosed())
    lIsUsed := .f.
    ddSetOrder(ORD_VNL_ART)
    cId := padr(cId,LenObjet())
    softseek cId
    do while ! eof() .and. FIELD->IdArt == cId
      if IsArtCode(FIELD->Code)
        lIsUsed := .t.
        exit
      endif
      skip
    enddo
  close area
  RETURN .t. if lIsUsed
#endif DEF_VEN
#ifdef DEF_VNLALT
  lIsUsed := .t.
  open area oVnl(DocStatNew())
    lIsUsed := .f.
    ddSetOrder(ORD_VNL_ART)
    cId := padr(cId,LenObjet())
    softseek cId
    do while ! eof() .and. FIELD->IdArt == cId
      if IsArtCode(FIELD->Code)
        lIsUsed := .t.
        exit
      endif
      skip
    enddo
  close area
  RETURN .t. if lIsUsed
#endif DEF_VNLALT
#ifdef DEF_ODS
  lIsUsed := .t.
  open area oOdl()
    cId := padr(cId,LenIdArt())
    ddSetOrder(ORD_ODL_ART)
    softseek cId
    if eof() .or. ODL->IdArt != cId
      lIsUsed := .f.
    * else
    *   SetMsg(MSG011 + ODL->IdJnl + " " + ODL->IdDoc)
    endif
  close area
  RETURN .t. if lIsUsed
#endif DEF_ODS
RETURN .f.

FUNCTION MsgIsUsed()
#ifdef LG_GERMAN
  RETURN "Dieser Datensatz wird in anderen Tabellen benutzt."
#else
  RETURN "Cet enregistrement est utilis‚ dans d'autres tables."
#endif

**
** Wird benutzt im TIM fr AMG // siehe auch GraBatchDelete()
**
*FUNCTION ArtBatchDelete(xlArtFilter,cMsgWorking,lConfirm,cWarning,cMsgFinal)
*local nCount := 0
*local nDeleted := 0
*local lOkay := .f.
*if cWarning != NIL
*  RETURN .f. if ! Confirm(cWarning,MsgSure(),MSG_NO)
*endif
** default lConfirm to .t. // Confirm("Jeden einzelnen Artikel best„tigen (J/N) ?")
*if cMsgWorking != NIL
*  MsgDisplay(cMsgWorking)
*endif
*open area oArt()
*  lOkay := .t.
*  ddSetOrder(0)
*  * set index to
*  go top
*  do while ! eof()
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
*    if &xlArtFilter
*      if ddRecLock()
*        if ArtDelete(ART->IdArt,lConfirm) == DDDEL_NOCONFIRM
*          nDeleted++
*          delete
*        endif
*        unlock record
*      else
*        exit
*      endif
*    endif
*    skip
*  enddo
*close area
*if cMsgFinal != NIL
*  Warning(ntrim(nDeleted) + cMsgFinal)
*endif
*RETURN lOkay

#endif DEF_ART


#ifdef DEF_GRA

**
** GraPreDelete()
**
FUNCTION GraPreDelete(lConfirm)
local cId := GRA->iGra
local lOkay := .f.
default lConfirm to .t.
RETURN ConfirmDelete() if empty(cId)
MsgDisplay(MsgWorking())
if GraIsUsed(cId)
  SetMsg(MsgIsUsed())
  RETURN .f.
endif
RETURN .t. if ! lConfirm
RETURN Confirm(trim(GRA->iGra) + MSG_GRA_DELETE)


FUNCTION GraIsUsed(cId)
local lIsUsed := .f.
#ifdef DEF_ART
  lIsUsed := .t.
  open area oArt()
    ddSetOrder(ORD_ART_GRA)
    softseek cId
    if eof() .or. ART->iGra != cId
      lIsUsed := .f.
    endif
  close area
#endif DEF_ART
RETURN lIsUsed

#endif DEF_GRA




#ifdef DEF_IVT

**
**
**
FUNCTION IvtPreDelete()
local lOkay := .f. // nReturn := DDDEL_FAIL
RETURN .f. if ! Confirm(MSG006)
open area oIvl()
  lOkay := .t. // nReturn := DDDEL_NOCONFIRM
  softseek dtos(IVT->Date)
  do while ! eof() .and. IVL->Date == IVT->Date
    if ddRecLock()
      delete
      unlock record
    else
      lOkay := .f. // nReturn := DDDEL_FAIL
      exit
    endif
    if TaskInter()
      lOkay := .f. // nReturn := DDDEL_FAIL
      exit
    endif
    skip
  enddo
close area
RETURN lOkay // nReturn

* FUNCTION IvlDelete()
* IvtSetDirty(IVL->Date)
* RETURN DDDEL_NOCONFIRM

#endif DEF_IVT

#ifdef DEF_GRA

**
** Wird benutzt im TIM fr AMG
**
*FUNCTION GraBatchDelete(xlFilter,cMsgWorking,lConfirm,cWarning,cMsgFinal)
*local nCount := 0
*local nDeleted := 0
*local lMayDelete
*local lOkay := .f.
*if cWarning != NIL
*  RETURN .f. if ! Confirm(cWarning,MsgSure(),MSG_NO)
*endif
*if cMsgWorking != NIL
*  MsgDisplay(cMsgWorking)
*endif
*open area oGra(), oArt()
*  lOkay := .t.
*  ddSetOrder ORD_ART_GRA in ART
*  ddSetOrder()
*  go top
*  do while ! eof()
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
*    lMayDelete := .f.
*    select ART
*    softseek GRA->iGra
*    if eof() .or. ART->iGra != GRA->iGra
*      lMayDelete := .t.
*    endif
*    select GRA
*    if lMayDelete .and. &xlFilter
*      if ddRecLock()
*        if (!lConfirm) .or. Confirm( ;
*          trim(GRA->iGra) + " " + trim(GRA->Name1), ;
*          MsgRecDelete(), MSG_NO ;
*        )
*          nDeleted++
*          delete
*        endif
*        unlock record
*      else
*        exit
*      endif
*    endif
*    skip
*  enddo
*close area
*if cMsgFinal != NIL
*  Warning(ntrim(nDeleted) + cMsgFinal)
*endif
*RETURN lOkay


#endif DEF_GRA

#ifdef DEF_FIN

**
**
**
FUNCTION FinPreDelete()
local lOkay := .f. // nReturn := DDDEL_FAIL
local jnl := JnlLocate(FIN->IdJnl)
if jnl == NIL
  Warning(FIN->IdJnl + MsgJnlExist())
  RETURN .f. if ! USRATTR_S $ UsrAttrib()
  RETURN ConfirmDelete()
endif
RETURN .f. if ! FinPreEdit()
* RETURN .f. if ! Confirm( ;
*   FIN->IdJnl + " " + FIN->IdDoc + MsgDocDelete(), ;
*   NIL, MSG_YES, "WRN003" ;
* )
RETURN .f. if ! DocDelete(jnl,FIN->IdDoc)
open area oFnl()
  lOkay := .t. // nReturn := DDDEL_NOCONFIRM
  seek FIN->IdJnl + FIN->IdDoc
  do while ! eof() .and. ;
           FNL->IdJnl + FNL->IdDoc == FIN->IdJnl + FIN->IdDoc
    if ddRecLock()
      delete
      unlock record
    else
      lOkay := .f. // nReturn := DDDEL_FAIL
      exit
    endif
    skip
  enddo
close area
RETURN lOkay // nReturn

#endif DEF_FIN


#ifdef DEF_ODS

**
**
**
FUNCTION OdsPreDelete()
local lOkay := .f. // nReturn := DDDEL_FAIL
local jnl := JnlLocate(ODS->IdJnl)
* RETURN .f. if ! Confirm( ;
*   MsgIdJnlDoc() + MsgDocDelete(), ;
*   NIL, MSG_YES, "WRN003" ;
* )
RETURN .f. if ! DocDelete(jnl,ODS->IdDoc)
open area oOdl()
  lOkay := .t. // nReturn := DDDEL_NOCONFIRM
  seek ODS->IdJnl + ODS->IdDoc
  do while ! eof() .and. ;
           ODL->IdJnl + ODL->IdDoc == ODS->IdJnl + ODS->IdDoc
    if ddRecLock()
      delete
      unlock record
    else
      lOkay := .f. // nReturn := DDDEL_FAIL
      exit
    endif
    skip
  enddo
close area
RETURN lOkay // nReturn

#endif DEF_ODS


*#ifdef DEF_PRD
*
***
*** PrdDelete() - delete record and all related VNL records
***
***
*FUNCTION PrdDelete()
*local nReturn := DDDEL_FAIL
*RETURN DDDEL_FAIL if ! Confirm(MsgIdJnlDoc() + " l”schen (J/N) ?" )
*open area oPrl()
*  nReturn := DDDEL_NOCONFIRM
*  seek PRD->IdJnl + PRD->IdDoc
*  do while ! eof() .and. PRL->IdDoc == PRD->IdDoc ;
*                   .and. PRL->IdJnl == PRD->IdJnl
*    if ddRecLock()
*      delete
*      unlock record
*    else
*      nReturn := DDDEL_FAIL
*      exit
*    endif
*    skip
*  enddo
*close area
*RETURN nReturn
*
*#endif DEF_PRD


#ifdef DEF_MVA

**
**
**
FUNCTION OdaPreDelete()
local lOkay := .f. // nReturn := DDDEL_FAIL
local jnl := JnlLocate(ODA->IdJnl)
*RETURN .f. if ! Confirm( ;
*  MsgIdJnlDoc() + MsgDocDelete(), ;
*  NIL, MSG_YES, "WRN003" ;
*)
RETURN .f. if ! DocDelete(jnl,ODA->IdDoc)
open area oMva()
  ddSetOrder(ORD_MVA_DOC)
  lOkay := .t. // nReturn := DDDEL_NOCONFIRM
  seek ODA->IdJnl + ODA->IdDoc
  do while ! eof() .and. ;
           MVA->IdJnl + MVA->IdDoc == ODA->IdJnl + ODA->IdDoc
    if ddRecLock()
      delete
      unlock record
    else
      lOkay := .f. // nReturn := DDDEL_FAIL
      exit
    endif
    skip
  enddo
close area
RETURN lOkay // nReturn

#endif DEF_MVA


#ifdef DEF_IMP

**
**
**
FUNCTION BudPreDelete()
RETURN .f. if ! ArcEval({||BudCanDelete()})
RETURN .f. if ! Confirm( ;
  BUD->DC + "-" + trim(SayIdBud(BUD->IdBud)) + " :", ;
  MsgRecDelete(), MSG_NO,"WRN012" ;
)
SendConsole( ;
  "BUD delete " + BUD->DC + "-" + trim(SayIdBud(BUD->IdBud)) ;
)
RETURN .t. // DDDEL_NOCONFIRM

FUNCTION BudCanDelete()
local lOkay := .f.
open area oMvi()
  ddSetOrder(ORD_MVI_BUDDATE)
  softseek BUD->DC+BUD->IdBud
  if BUD->DC+BUD->IdBud != MVI->DC+MVI->IdBud
    lOkay := .t.
  else
    SetMsg(MSG005)
  endif
close area
RETURN lOkay


#endif DEF_IMP

#ifdef DEF_ANA

**
**
**
FUNCTION AnaPreDelete()
local lOkay := .f. // nReturn := DDDEL_FAIL
#ifdef DEF_HST
  open area oHst()
    ddSetOrder(ORD_HST_ANA)
    softseek ANA->IdAna
    if HST->IdAna != ANA->IdAna
      lOkay := .t. // nReturn := DDDEL_CONFIRM
    else
      SetMsg("Verweigert. Es existieren Buchungen in dieses Konto !")
    endif
  close area
#endif DEF_HST
#ifdef DEF_MVA
  open area oMva()
    softseek ANA->IdAna
    if MVA->IdAna != ANA->IdAna
      lOkay := .t. // nReturn := DDDEL_CONFIRM
    else
      SetMsg("Verweigert. Es existieren Buchungen in dieses Konto !")
    endif
  close area
#endif DEF_MVA
RETURN lOkay // nReturn

#endif DEF_ANA

#ifdef DEF_PRJ




FUNCTION PrjPreDelete
local lOkay := .f.
local nCount := 0
#ifdef DEF_RFX
  RETURN .f. if ! XrtCanDelete()
#endif DEF_RFX
RETURN .f. if ! Confirm( ;
  PRJ->IdPrj + " :", MsgRecDelete(), ;
  MSG_NO, ;
)
#ifdef DEF_HOLZ
  RETURN .f. if ! Confirm( ;
    "Alle Baumst„mme aus " + PRJ->IdPrj + " werden gel”scht !", ;
    MsgSure(), MSG_NO, ;
  )
#endif DEF_HOLZ
#ifdef DEF_WWW
  RETURN .f. if ! HtmOnDelete()
#endif
#ifdef DEF_RFX
  RETURN .f. if ! XrtOnDelete()
#endif DEF_RFX
#ifdef DEF_HOLZ
  open area oStm()
    lOkay := .t.
    ddSetOrder(ORD_STM_PRJ)
    softseek PRJ->IdPrj
    do while ! eof() .and. STM->IdPrj == PRJ->IdPrj
      if ddRecLock()
        delete
        nCount++
      else
        lOkay := .f.
        exit
      endif
      skip
    enddo
  close area
  Warning(ntrim(nCount) + " Baumst„mme wurden gel”scht.")
  RETURN .f. if ! lOkay
#endif DEF_HOLZ
RETURN .t. // DDDEL_NOCONFIRM

#endif DEF_PRJ

**
**
**
*FUNCTION PerPreDelete
*local cPeriode := PER->Periode
*RETURN .f. if ! ConfirmDelete()
*RETURN .t. if ! Confirm( ;
*  "Sollen auch alle Buchungen gel”scht werden (J/N) ?", ;
*  NIL, MSG_NO ;
*)
*RETURN .f. if ! Confirm( ;
*  "ALLE DATEN AUS PERIODE " + cPeriode + " WERDEN GEL™SCHT !", ;
*  MsgSure(), MSG_NO ;
*)

#ifdef DEF_JNL

**
** DelPerRange() (nicht PerDelRange()...)
**
FUNCTION DelPerRange(xlVenFilter)
local lOkay := .f.
RETURN .f. if ! Confirm( ;
  "ALLE DATEN AUS PERIODE " + PerText() + " WERDEN GEL™SCHT !", ;
  MsgSure(), MSG_NO ;
)
#ifdef DEF_VEN
  default xlVenFilter to ".t."
  open area oVen()
    MsgDisplay("VEN.DBF and VNL.DBF...")
    lOkay := .t.
    go top
    do while lOkay .and. ! eof()
      if ChkPeriode(VEN->Periode) == 0 // == cPeriode
        if xparse(xlVenFilter)
          if ddRecLock()
            open area oVnl(VEN->Etat) // select VNL
              softseek VEN->IdJnl+VEN->IdDoc
              do while lOkay .and. ! eof() .and. FIELD->IdJnl == VEN->IdJnl ;
                             .and. FIELD->IdDoc == VEN->IdDoc
                if ddRecLock()
                  delete
                  unlock record
                else
                  lOkay := .f.
                endif
                if TaskInter() ; lOkay := .f. ; endif
                skip
              enddo
            close area
            delete
            unlock record
          else
            lOkay := .f.
          endif
        endif
      endif
      if TaskInter() ; lOkay := .f. ; endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_VEN
#ifdef DEF_FIN
  open area oFin(), oFnl()
    MsgDisplay("FIN.DBF and FNL.DBF...")
    lOkay := .t.
    go top
    do while lOkay .and. ! eof()
      if ChkPeriode(FIN->Periode) == 0 // == cPeriode
        if ddRecLock()
          select FNL
          softseek FIN->IdJnl+FIN->IdDoc
          do while lOkay .and. ! eof() .and. FNL->IdJnl == FIN->IdJnl ;
                         .and. FNL->IdDoc == FIN->IdDoc
            if ddRecLock()
              delete
              unlock record
            else
              lOkay := .f.
            endif
            if TaskInter() ; lOkay := .f. ; endif
            skip
          enddo
          select FIN
          delete
          unlock record
        else
          lOkay := .f.
        endif
      endif
      if TaskInter() ; lOkay := .f. ; endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_FIN
#ifdef DEF_HST
  lOkay := .f.
  open area oHst()
    MsgDisplay("HST.DBF...")
    lOkay := .t.
    go top
    do while lOkay .and. ! eof()
      if ChkPeriode(HST->Periode) == 0 // == cPeriode
        if ddRecLock()
          delete
          unlock record
        else
          lOkay := .f.
        endif
      endif
      if TaskInter() ; lOkay := .f. ; endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_HST
#ifdef DEF_INT
  lOkay := .f.
  open area oHsi()
    MsgDisplay("HSI.DBF...")
    lOkay := .t.
    go top
    do while lOkay .and. ! eof()
      if ChkPeriode(HSI->Periode) == 0
        if ddRecLock()
          delete
          unlock record
        else
          lOkay := .f.
        endif
      endif
      if TaskInter() ; lOkay := .f. ; endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_INT
#ifdef DEF_VEN
  RETURN lOkay if xlVenFilter != ".t."
#endif DEF_VEN
lOkay := .f.
open area oPer()
  MsgDisplay("PER.DBF...")
  lOkay := .t.
  go top
  do while lOkay .and. ! eof()
    if ChkPeriode(PER->Periode) == 0 // == cPeriode
      if ddRecLock()
        delete
        unlock record
      else
        lOkay := .f.
      endif
    endif
    if TaskInter() ; lOkay := .f. ; endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
RETURN .t.


** Robert Radermacher Beispiel fr Datei "cFilename" :
** // alt|neu
** 9901|9813
** 9902|9814
** 9903|9815
** 9904|9816
** 9905|9817
** 9906|9818
**
** PerRename()
**
* FUNCTION PerRename(cFilename)
FUNCTION PerRename(a)
* local a := ReadArray(cFilename,2)
local lOkay := .f.
local nCount
RETURN .f. if ! Confirm( ;
  "Buchungsperioden umbenennen ! (Sind alle anderen aus TIM raus ?)", ;
  MsgSure(), MSG_NO ;
)
#ifdef DEF_VEN
  nCount := 0
  lOkay := .f.
  open area oVen() exclusive
    MsgDisplay("VEN.DBF...")
    lOkay := .t.
    ddSetOrder()
    go top
    do while lOkay .and. ! eof()
      MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
      VEN->Periode := NewPeriode(a,VEN->Periode)
      if TaskInter() ; lOkay := .f. ; endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_VEN
#ifdef DEF_FIN
  nCount := 0
  lOkay := .f.
  open area oFin() exclusive
    MsgDisplay("FIN.DBF...")
    lOkay := .t.
    ddSetOrder()
    go top
    do while lOkay .and. ! eof()
      FIN->Periode := NewPeriode(a,FIN->Periode)
      if TaskInter() ; lOkay := .f. ; endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_FIN
#ifdef DEF_ODS
  nCount := 0
  lOkay := .f.
  open area oOds() exclusive
    MsgDisplay("ODS.DBF...")
    lOkay := .t.
    ddSetOrder()
    go top
    do while lOkay .and. ! eof()
      ODS->Periode := NewPeriode(a,ODS->Periode)
      if TaskInter() ; lOkay := .f. ; endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_ODS
#ifdef DEF_VNA
  nCount := 0
  lOkay := .f.
  open area oVna() exclusive
    MsgDisplay("VNA.DBF...")
    lOkay := .t.
    ddSetOrder()
    go top
    do while lOkay .and. ! eof()
      VNA->Periode := NewPeriode(a,VNA->Periode)
      if TaskInter() ; lOkay := .f. ; endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_VNA
#ifdef DEF_HST
  nCount := 0
  lOkay := .f.
  open area oHst() exclusive
    MsgDisplay("HST.DBF...")
    lOkay := .t.
    ddSetOrder()
    go top
    do while lOkay .and. ! eof()
      HST->Periode := NewPeriode(a,HST->Periode)
      if TaskInter() ; lOkay := .f. ; endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_HST
  nCount := 0
  lOkay := .f.
  open area oPer() exclusive
    MsgDisplay("PER.DBF...")
    lOkay := .t.
    ddSetOrder()
    go top
    do while lOkay .and. ! eof()
      PER->Periode := NewPeriode(a,PER->Periode)
      if TaskInter() ; lOkay := .f. ; endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
RETURN .f. if ! lOkay
RETURN .t.

STATIC FUNCTION NewPeriode(a,cPeriode)
local i
for i := 1 to len(a)
  RETURN a[i][2] if a[i][1] == cPeriode
next i
RETURN cPeriode

#endif DEF_JNL

#ifdef DEF_RUN

**
** RalPreDelete()
**
FUNCTION RalPreDelete(b)
local lOkay := .f.
RETURN .f. if ! Confirm("Supprimer toutes les inscriptions (O/N) ?")
open area oPos()
  lOkay := .t.
  softseek RAL->IdRal
  do while ! eof() .and. POS->IdRal == RAL->IdRal
    if TaskInter()
      lOkay := .f.
      exit
    endif
    if ddRecLock()
      delete
      unlock record
    else
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
RETURN lOkay

**
** ParDelete()
**
*FUNCTION ParDelete(b)
*local nReturn := DDDEL_FAIL
*RETURN DDDEL_CONFIRM if empty(PAR->IdPar)
*RETURN nReturn

#endif DEF_RUN

