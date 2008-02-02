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
* static MSG001 := ""

**
** PROCEDURE_SECTION  - (...grins)
**

#ifdef DEF_IMPTIM205

#ifdef LG_FRENCH
  #define IDCTR_E "A" // "Einkauf" oder "Achat"
  #define IDCTR_V "V" // "Verkauf" oder "Vente"
  *
  #define IDPRT_K "C"
  #define IDPRT_L "F"
#else
  #define IDCTR_E "E" // "Einkauf" oder "Achat"
  #define IDCTR_V "V" // "Verkauf" oder "Vente"
  *
  #define IDPRT_K "K"
  #define IDPRT_L "L"
#endif

FUNCTION Upgrade(cPath)
local jnl
local cLine
local cMatch
local nCount
local lZap := .f.
* static cMvt := BUTTON_OFF
static cTax := BUTTON_OFF
static cPar := BUTTON_OFF
static cGen := BUTTON_OFF
static cAch := BUTTON_OFF
static cFin := BUTTON_OFF
static cTrm := BUTTON_OFF
static cMsg := BUTTON_OFF
static cArt := BUTTON_OFF
* static cPath := NIL
* local cMvt := if(file(DbPath() + "\mvt300.ind"),BUTTON_OFF,BUTTON_ON)
* local cAch := if(file(DbPath() + "\ach300.ind"),BUTTON_OFF,BUTTON_ON)
* local cJnl := if(file(DbPath() + "\jnl300.ind"),BUTTON_OFF,BUTTON_ON)
* local cVnm := if(file(DbPath() + "\vnm300.ind"),BUTTON_OFF,BUTTON_ON)
* local cTxt := if(file(DbPath() + "\txt300.ind"),BUTTON_OFF,BUTTON_ON)
#ifdef DEF_205
  default cPath to "C:\TIM205"
  open window "TIM 2.05 importieren" size 11,60
#else
  default cPath to "C:\TIM210"
  open window "TIM 2.10 importieren" size 12,60
#endif
cPath := padr(cPath,50)
say "Pfad : "
get cPath picture PIC_ID
WinCr()
@ row(), col() get cPar checkbox
say " Kunden & Lieferanten importieren"
WinCr()
* @ row(), col() get cMvt checkbox
* say " MVT und MVP importieren"
* WinCr()
#ifdef DEF_210
  @ row(), col() get cTax checkbox
  say " TAX importieren"
  WinCr()
#endif DEF_210
@ row(), col() get cGen checkbox
say " Generalkonten"
WinCr()
@ row(), col() get cArt checkbox
say " Artikel GRA und ART nach GRA, ART und ACF"
WinCr()
@ row(), col() get cAch checkbox
say " Import VEN, ACH, VNL & ACL"
WinCr()
@ row(), col() get cFin checkbox
say " Import FIN, OPD, FNL und ODL"
WinCr()
@ row(), col() get cTrm checkbox
say " Agenda"
WinCr()
@ row(), col() get cMsg checkbox
say " Korrespondenz"
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC

*if cMvt == BUTTON_ON
*  MsgDisplay("MVT into MVP and MVT...")
*  ddCloseAll()
*  open area oMvp() exclusive
*    zap
*  close area
*  open area oMvt() exclusive
*    zap
*  close area
*  ddCloseAll()
*  open area oMvp(), oMvt()
*    select 0
*    use (cPath + "\MVT.DBF") alias MVT205
*    go top
*    do while ! eof()
*      * if PerIsClosed(NewPeriode(MVT205->Periode),MVT205->IdJnl)
*        if MVT205->CptType == "G"
*          select MVT
*          if ! empty(MVT205->cMontD)
*            if dbAddRec()
*              MVT->IdGen   := NewIdGen(MVT205->Compte)
*              MVT->IdJnl   := MVT205->IdJnl
*              MVT->Periode := NewPeriode(MVT205->Periode)
*              MVT->IdDoc   := NewIdDoc(MVT205->IdDoc,MVT205->IdJnl)
*              MVT->Date    := MVT205->Date
*              MVT->Line    := MVT205->Line
*              MVT->DC      := DC_DEBIT
*              MVT->Mont    := MVT205->cMontD
*              unlock record
*            endif
*          elseif ! empty(MVT205->cMontC)
*            if dbAddRec()
*              MVT->IdGen   := NewIdGen(MVT205->Compte)
*              MVT->IdJnl   := MVT205->IdJnl
*              MVT->Periode := NewPeriode(MVT205->Periode)
*              MVT->IdDoc   := NewIdDoc(MVT205->IdDoc,MVT205->IdJnl)
*              MVT->Date    := MVT205->Date
*              MVT->Line    := MVT205->Line
*              MVT->DC      := DC_CREDIT
*              MVT->Mont    := MVT205->cMontC
*              unlock record
*            endif
*          endif
*          select MVT205
*        else
*          select MVP
*          if ! empty(MVT205->cMontD)
*            if dbAddRec()
*              MVP->IdPar   := ParNewId(NewCptType(MVT205->CptType),MVT205->Compte)
*              MVP->Match   := MVT205->Match
*              MVP->IdJnl   := MVT205->IdJnl
*              MVP->Periode := NewPeriode(MVT205->Periode)
*              MVP->IdDoc   := NewIdDoc(MVT205->IdDoc,MVT205->IdJnl)
*              MVP->Date    := MVT205->Date
*              MVP->Line    := MVT205->Line
*              if MVT205->CptType == "F"
*                MVP->IdCtr := IDCTR_E
*              else
*                MVP->IdCtr := IDCTR_V
*              endif
*              MVP->DC := DC_DEBIT
*              MVP->Mont := MVT205->cMontD
*              if empty(MVP->Match)
*                MVP->Match := MVP->IdJnl + MVP->IdDoc
*              endif
*              unlock record
*            endif
*          elseif ! empty(MVT205->cMontC)
*            if dbAddRec()
*              MVP->IdPar   := ParNewId(NewCptType(MVT205->CptType),MVT205->Compte)
*              MVP->Match   := MVT205->Match
*              MVP->IdJnl   := MVT205->IdJnl
*              MVP->Periode := NewPeriode(MVT205->Periode)
*              MVP->IdDoc   := NewIdDoc(MVT205->IdDoc,MVT205->IdJnl)
*              MVP->Date    := MVT205->Date
*              MVP->Line    := MVT205->Line
*              MVP->DC := DC_CREDIT
*              MVP->Mont := MVT205->cMontC
*              if MVT205->CptType == "F"
*                MVP->IdCtr := IDCTR_E
*              else
*                MVP->IdCtr := IDCTR_V
*              endif
*              if empty(MVP->Match)
*                MVP->Match := MVP->IdJnl + MVP->IdDoc
*              endif
*              unlock record
*            endif
*          endif
*          select MVT205
*        endif
*      * endif
*      if TaskInter() ; exit ; endif
*      MsgDisp2(ntrim0(100*recno()/lastrec()) + "%")
*      skip
*    enddo
*  close area
*endif

#ifdef DEF_210

if cTax == BUTTON_ON
  MsgDisplay("importing TAX ...")
  ddCloseAll()
  open area oTax() exclusive
    zap
  close area
  ddCloseAll()
  open area oTax()
    select 0
    use (cPath + "\TAX.DBF") alias TAX205
    go top
    do while ! eof()
      if TaskInter() ; exit ; endif
      if left(TAX205->GenAch,1) != "*"
        select TAX
        if dbAddRec()
          TAX->IdCtr  := IDCTR_E
          TAX->IdTax  := NewIdTax(IDCTR_E,TAX205->IdTax)
          TAX->IdGen  := TAX205->GenAch
          TAX->Taux   := TAX205->Taux
          TAX->Libell := TAX205->Libell
          TAX->Attrib   := TAX205->Attrib
          TAX->GenTiers := TAX205->Tiers
          TAX->Memo1    := TAX205->Memo1
          TAX->Memo2    := TAX205->Memo2
          TAX->Memo3    := TAX205->Memo3
        else
          exit
        endif
        select TAX205
      endif
      skip
    enddo
    go top
    do while ! eof()
      if TaskInter() ; exit ; endif
      if left(TAX205->GenVen,1) != "*"
        select TAX
        if dbAddRec()
          TAX->IdCtr  := IDCTR_V
          TAX->IdTax  := NewIdTax(IDCTR_V,TAX205->IdTax)
          TAX->IdGen  := TAX205->GenVen
          TAX->Taux   := TAX205->Taux
          TAX->Libell := TAX205->Libell
          TAX->Attrib   := TAX205->Attrib
          TAX->GenTiers := TAX205->Tiers
          TAX->Memo1    := TAX205->Memo1
          TAX->Memo2    := TAX205->Memo2
          TAX->Memo3    := TAX205->Memo3
        else
          exit
        endif
        select TAX205
      endif
      skip
    enddo
  close area
endif

#endif DEF_210

**
** CLI und FOU nach PAR
**
if cPar == BUTTON_ON
  if Confirm("Bestehende Partner vorher l”schen (J/N) ?")
    ddCloseAll()
    open area oPar() exclusive
      go top
      delete for PAR->IdPrt != "D"
      * pack
    close area
  endif
  ddCloseAll()
  if ddConvertDbf(oPar())
    if ddIndex(oPar())
      ParImport(cPath,"CLI")
      ParImport(cPath,"FOU")
    endif
  endif
endif

**
** GEN : Generalkonten
**
if cGen == BUTTON_ON
  MsgDisplay("Importing GEN...")
  ddCloseAll()
  open area oGen() exclusive
    zap
    select 0
    use (cPath + "\CFR.DBF") alias CFR205
    go top
    do while ! eof()
      select GEN
      append blank
      GEN->IdGen    := CFR205->IdCfr
      GEN->Libell1  := CFR205->Libell1
      GEN->Libell2  := CFR205->Libell2
      * GEN->IdCat    := CFR205->IdCat
      if len(trim(GEN->IdGen)) == LenIdGen()
        if left(GEN->IdGen,3) $ "600;601;602;603;604;605;608"
          GEN->IdClj    := "81"
          GEN->IdCtr    := IDCTR_E
        elseif left(GEN->IdGen,2) == "61"
          GEN->IdClj    := "82"
          GEN->IdCtr    := IDCTR_E
        elseif left(GEN->IdGen,2) == "62"
          GEN->IdClj    := "82"
          GEN->IdCtr    := IDCTR_E
        elseif left(GEN->IdGen,2) == "64"
          GEN->IdClj    := "82"
          GEN->IdCtr    := IDCTR_E
        elseif left(GEN->IdGen,2) == "65"
          GEN->IdClj    := "82"
          GEN->IdCtr    := IDCTR_E
        elseif left(GEN->IdGen,2) $ "20;21;22;23;24;25;26;27"
          GEN->IdClj    := "83"
          GEN->IdCtr    := IDCTR_E
        elseif GEN->IdGen == "400000"
          GEN->IdCtr    := IDCTR_V
          GEN->Attrib   := "H"
        elseif GEN->IdGen == "440000"
          GEN->IdCtr    := IDCTR_E
          GEN->Attrib   := "H"
        elseif left(GEN->IdGen,3) == "451"
          GEN->IdCtr    := IDCTR_E
          GEN->Attrib   := "H"
        elseif GEN->IdGen == "411000"
          GEN->IdCtr    := IDCTR_E
          GEN->Attrib   := "H"
        elseif GEN->IdGen == "451000"
          GEN->IdCtr    := IDCTR_V
          GEN->Attrib   := "H"
        endif
        * if left(GEN->IdGen,1) $ "7"
        *   GEN->DC       := DC_CREDIT
        * else
        *   GEN->DC       := DC_DEBIT
        * endif
      endif
      select CFR205
      skip
    enddo
    select CFR205
    use
  close area
endif

**
** ART : Artikel
**
if cArt == BUTTON_ON
  ddCloseAll()
  MsgDisplay("Importing ART & TAC into ART and ACF...")
  open area oArt(), oAcf() exclusive
    zap
    #ifdef DEF_ACF
      select ACF
      zap
    #endif DEF_ACF
    select 0
    use (cPath + "\TXT.DBF") alias TXT205
    index on TXT205->Type + TXT205->IdTxt + TXT205->Langue to TMP
    select 0
    use (cPath + "\ART.DBF") alias ART205
    go top
    nCount := 0
    do while ! eof() .and. ! TaskInter()
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      select ART
      append blank
      ART->IdArt := ART205->IdArt
      ART->iGra  := ART205->iGra
      ART->Name1 := ART205->DesigF
      ART->Name2 := ART205->DesigD
      ART->Name3 := ART205->DesigN
      ART->IdCat := NewIdCat(ART205->IdCat)
      ART->Prix1 := ART205->cPrixL
      // ART->Prix2 := ART205->cPrixL // Basispreis
      ART->TVAC  := ART205->PrixT
      ART->IdUnt := ART205->IdUnt
      ART->QteForm := ART205->QteForm
      ART->DPA    := ART205->DPA
      ART->PrixR  := ART205->PAMP
      ART->Remarq := ART205->Remarq
      ART->DatCrea := ART205->DatCrea
      ART->IdPga   := "0"
      #ifdef DEF_210
        ART->DatPrix := ART205->DatPrix
        ART->Memo1   := ART205->Memo1
        ART->Memo2   := ART205->Memo2
        ART->Memo3   := ART205->Memo3
        * ART->Frist   := ART205->Frist
        ART->Remarq  := ART205->DesigN
      #endif DEF_210
      * if ! empty(ART205->IdTxt)
      *   seek "A" + ART205->IdTxt + "F" in TXT205
      *   if ! eof() in TXT205
      *     ART->Memo1 := TXT205->Texte
      *   endif
      *   seek "A" + ART205->IdTxt + "D" in TXT205
      *   if ! eof() in TXT205
      *     ART->Memo2 := TXT205->Texte
      *   endif
      *   seek "A" + ART205->IdTxt + "E" in TXT205
      *   if ! eof() in TXT205
      *     ART->Memo3 := TXT205->Texte
      *   endif
      * endif
      if ART205->Suivi == BUTTON_OFF
        ART->Attrib := trim(ART->Attrib) + ARTATTR_S
      endif
      #ifdef DEF_205
        if ART205->Statut == "1"
          ART->Attrib := trim(ART->Attrib) + ARTATTR_M
        elseif ART205->Statut == "3"
          ART->Attrib := trim(ART->Attrib) + ARTATTR_H
        endif
      #endif DEF_205
      if ! empty(ART205->IdFou + ART205->RefExt + ART205->cPrixA)
        #ifdef DEF_ACF
          select ACF
          append blank
          ACF->IdArt  := ART205->IdArt
          ACF->IdPar  := ParNewId(IDCTR_E,ART205->IdFou)
          ACF->Prix   := ART205->cPrixA
          ACF->AcfRef := ART205->RefExt
          ACF->Date   := ART205->DatPrix
          ACF->IdDev  := "BEF"
          ACF->IdCtr  := IDCTR_E
        #else
          ART->IdPar   := ART205->IdFou
          ART->RefExt  := ART205->RefExt
        #endif DEF_ACF
      endif
      select ART205
      skip
    enddo
    select ART205
    use
    select TXT205
    use
    delete file TMP.NTX
    select 0
    use (cPath + "\TAC.DBF") alias TAC205
    go top
    nCount := 0
    do while ! eof() .and. ! TaskInter()
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      select ART
      append blank
      ART->IdArt := TAC205->IdTac
      ART->iGra  := "TAC"
      ART->Name1 := TAC205->Libell
      ART->Name2 := TAC205->Libell2
      ART->IdCat := NewIdCat(TAC205->IdCat)
      ART->Prix1 := TAC205->Tarif
      ART->QteForm := TAC205->QteForm
      ART->DatCrea := UserDate()
      ART->Attrib := trim(ART->Attrib) + ARTATTR_S
      select TAC205
      skip
    enddo
    use
  close area
  MsgDisplay("Importing GRA into GRA...")
  open area oGra() exclusive
    nCount := 0
    zap
    select 0
    use (cPath + "\GRA.DBF") alias GRA205
    go top
    do while ! eof()
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      select GRA
      append blank
      GRA->iGra  := GRA205->iGra
      GRA->Name1 := GRA205->DesigF
      GRA->Name2 := GRA205->DesigD
      GRA->Name3 := GRA205->DesigN
      select GRA205
      skip
    enddo
    select GRA205
    use
  close area
endif

**
** ACH, VEN, ACL, VNL
**
if cAch == BUTTON_ON
  ddCloseAll()
  open area oVen(), oPar() exclusive
    nCount := 0
    MsgDisplay("Importing ACH into VEN...")
    if lZap
      zap
    endif
    select 0
    use (cPath + "\ACH")
    go top
    select ACH
    do while ! eof() .and. ! TaskInter()
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      select VEN
      seek ACH->Type + ACH->iAch
      if eof()
        append blank
        VEN->IdJnl  := ACH->Type
        VEN->IdDoc  := ACH->iAch
        VEN->IdPar := ParNewId(IDCTR_E,ACH->iFou)
        seek VEN->IdPar in PAR
        VEN->Date  := ACH->Date
        VEN->DatEch := ACH->DatEch
        VEN->Periode := NewPeriode(ACH->Periode)
        VEN->NB1     := ACH->Remarq
        VEN->DC      := JnlDC(VEN->IdJnl)
        VEN->Etat    := ACH->Etat
        VEN->Auteur  := ACH->Auteur
        VEN->Match   := ACH->Match
        VEN->Attrib  := ACH->Attrib
        VEN->IdMfc   := NewIdMfc(PAR->IdMfc)
        VEN->Memo    := ACH->Memo
        VEN->IdDev   := ACH->IdDev
        VEN->IdReg   := ACH->IdReg
        VEN->Cours   := ACH->Cours
        VEN->Mont    := ntom(val(ACH->cMontB) + val(ACH->cMontT),DevDecPos(VEN->IdDev))
        * #ifdef DEF_PRIXR
        * VEN->MontB   := ACH->cMontB
        * #endif DEF_PRIXR
      endif
      select ACH
      skip
    enddo
    if Confirm("Import VEN ?")
      MsgDisplay("Importing VEN into VEN...")
      nCount := 0
      use
      use (cPath + "\VEN") alias ACH
      go top
      do while ! eof() .and. ! TaskInter()
        MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
        select VEN
        seek ACH->Type + ACH->iVen
        if eof()
          append blank
          VEN->IdJnl  := ACH->Type
          VEN->IdDoc  := ACH->iVen
          VEN->IdPar := ParNewId(IDCTR_V,ACH->iCli)
          seek VEN->IdPar in PAR
          VEN->IdReg   := ACH->IdReg
          VEN->Date  := ACH->Date
          VEN->DatEch := ACH->DatEch
          VEN->Periode := NewPeriode(ACH->Periode)
          VEN->NB1     := ACH->Desig
          VEN->DC      := JnlDC(VEN->IdJnl)
          VEN->Etat    := ACH->Etat
          VEN->Auteur  := ACH->Auteur
          * VEN->Match   := ACH->Match
          VEN->Match  := left(ACH->Match,3) + NewIdDoc(substr(ACH->Match,4),left(ACH->Match,3))
          VEN->Attrib  := ACH->Attrib
          VEN->IdMfc   := NewIdMfc(ACH->ModPai)
          VEN->Memo    := ACH->Memo
          VEN->IdDev   := ACH->IdDev
          VEN->Cours   := ACH->Cours
          VEN->Mont    := ntom(val(ACH->cMontB) + val(ACH->cMontT),DevDecPos(VEN->IdDev))
          * #ifdef DEF_PRIXR
          *   VEN->MontB   := ACH->cMontB
          * #endif DEF_PRIXR
        endif
        select ACH
        skip
      enddo
    endif
    use
  close area
  ddCloseAll()
  open area oVnl(), oPar(), oVen(), oArt(), oGen() exclusive
    if lZap
      zap
    endif
    select 0
    use (cPath + "\ACL.DBF")
    nCount := 0
    MsgDisplay("Importing ACL.DBF...")
    go top
    do while ! eof() .and. ! TaskInter()
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      select VNL
      softseek ACL->IdJnl+ACL->IdDoc
      if eof() .or. VNL->IdJnl+VNL->IdDoc != ACL->IdJnl+ACL->IdDoc
        append blank
        VNL->IdJnl  := ACL->IdJnl
        VNL->IdDoc  := ACL->IdDoc
        VNL->Qte    := ACL->Qte
        VNL->Code   := NewVnlCode(ACL->Code,ACL->IdJnl)
        if VNL->Code == LNCODE_GEN
          VNL->IdArt  := NewIdGen(ACL->IdArt)
        else
          VNL->IdArt  := ACL->IdArt
        endif
        VNL->Desig  := ACL->Desig
        VNL->cMont  := ACL->cMont
        VNL->IdTax  := NewIdTax(IDCTR_E,ACL->IdTax)
        VNL->Memo   := ACL->Memo
        VNL->MontT  := ACL->MontT
        VNL->PrixU  := ACL->PrixU
        * if cGen == BUTTON_ON
          VnlGenUpgrade(IDCTR_E)
          * if ! VnlGenUpgrade(IDCTR_E)
          *   select ACL
          *   exit
          * endif
        * endif
      endif
      select ACL
      skip
    enddo
    use
    if Confirm("Import VNL ?")
      nCount := 0
      MsgDisplay("Importing VNL.DBF using VNM.DBF...")
      *** use (cPath + "\VNM.DBF") alias VNM
      *** index on VNM->IdJnl+VNM->IdDoc+VNM->IdVnm to VNM1
      *** select 0
      use (cPath + "\VNL.DBF") alias VNL205
      go top
      do while ! eof() .and. ! TaskInter()
        MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
        select VNL
        softseek VNL->IdJnl+VNL->IdDoc
        if eof() .or. VNL->IdJnl+VNL->IdDoc != VNL->IdJnl+VNL->IdDoc
          append blank
          VNL->IdJnl  := VNL205->IdJnl
          VNL->IdDoc  := VNL205->IdDoc
          seek VNL->IdJnl + VNL->IdDoc in VEN
          *** seek VNL205->IdJnl + VNL205->IdDoc + VNL205->IdVnm in VNM
          *** if eof() in VNM
            VNL->Qte    := VNL205->Qte
            VNL->cMont  := VNL205->cMont
            VNL->MontT  := VNL205->MontT
          *** elseif qton1(VNM->Qte) == 1
          ***   VNL->Qte    := VNL205->Qte
          ***   VNL->cMont  := VNL205->cMont
          ***   VNL->MontT  := VNL205->MontT
          *** else
          ***   VNL->Qte    := str(qton1(VNL205->Qte) * qton1(VNM->Qte),6,2)
          ***   VNL->cMont  := ntom(val(VNL205->cMont) * qton1(VNM->Qte),DevDecPos(VEN->IdDev))
          ***   VNL->MontT  := ntom(val(VNL205->MontT) * qton1(VNM->Qte),DevDecPos(VEN->IdDev))
          *** endif
          VNL->PrixU  := VNL205->PrixU
          * if VEN->IdDev == DevDefault()
          *   VNL->PrixR  := VNL205->cPrixA
          * else
          *   VNL->PrixR  := str(val(VNL205->cPrixA)/val(VEN->Cours),10,0)
          * endif
          VNL->Code   := NewVnlCode(VNL205->Code,VNL205->IdJnl)
          if VNL->Code == LNCODE_GEN
            VNL->IdArt  := NewIdGen(VNL205->IdArt)
          else
            VNL->IdArt  := VNL205->IdArt
          endif
          VNL->Desig  := VNL205->Desig
          VNL->IdTax  := NewIdTax(IDCTR_V,VNL205->IdTax)
          VNL->Memo   := VNL205->Memo
          * if cGen == BUTTON_ON
            VnlGenUpgrade(IDCTR_V)
            * if ! VnlGenUpgrade(IDCTR_V)
            *   select VNL205
            *   exit
            * endif
          * endif
        endif
        select VNL205
        skip
      enddo
    endif
    use
    *** select VNM
    *** use
    *** delete file VNM1.NTX
  close area
  ddCloseAll()
endif

**
** FIN, Fnl, OPD, ODL
**
if cFin == BUTTON_ON
  MsgDisplay("Importing FIN from FIN and OPD...")
  ddCloseAll()
  open area oFin() exclusive
    zap
    select 0
    use (cPath + "\FIN") alias FIN205
    go top
    nCount := 0
    do while ! eof() .and. ! TaskInter()
      MsgDisp2("FIN " + ntrim0(100 * nCount++ / lastrec()) + "%")
      if (jnl := JnlLocate(FIN205->IdJnl)) == NIL
        Warning(FIN205->IdJnl + MsgJnlExist())
        exit
      else
        select FIN
        append blank
        FIN->IdJnl   := FIN205->IdJnl
        FIN->IdDoc   := NewIdDoc(FIN205->IdFin,FIN->IdJnl)
        FIN->Date    := FIN205->Date
        FIN->Periode := NewPeriode(FIN205->Periode)
        if empty(jnl[JNL_IDDEV])
          FIN->IdDev   := DevDefault(FIN->Periode)
        else
          FIN->IdDev   := jnl[JNL_IDDEV]
        endif
        FIN->Remarq  := FIN205->Remarq
        FIN->Etat    := FIN205->Etat
        FIN->Cours   := FIN205->Cours
        FIN->Mont1   := FIN205->Mont1
        FIN->Mont2   := FIN205->Mont2
        select FIN205
      endif
      skip
    enddo
    use (cPath + "\OPD") alias OPD205
    go top
    nCount := 0
    do while ! eof() .and. ! TaskInter()
      MsgDisp2("OPD " + ntrim0(100 * nCount++ / lastrec()) + "%")
      if (jnl := JnlLocate(OPD205->IdJnl)) == NIL
        Warning(OPD205->IdJnl + MsgJnlExist())
        exit
      else
        select FIN
        append blank
        FIN->IdJnl   := OPD205->IdJnl
        FIN->IdDoc   := NewIdDoc(OPD205->IdDoc,FIN->IdJnl)
        FIN->Date    := OPD205->Date
        FIN->Periode := NewPeriode(OPD205->Periode)
        FIN->Remarq  := OPD205->Libell
        FIN->Etat    := OPD205->Etat
        FIN->Cours   := padl("1",LenMont())
        if empty(jnl[JNL_IDDEV])
          FIN->IdDev   := DevDefault(FIN->Periode)
        else
          FIN->IdDev   := jnl[JNL_IDDEV]
        endif
        select OPD205
      endif
      skip
    enddo
    use
  close area
  MsgDisplay("Importing FNL from FNL and ODL...")
  ddCloseAll()
  open area oFnl(), oFin(), oPar(), oGen() exclusive
    zap
    select 0
    use (cPath + "\FNL.DBF") alias FNL205
    index on FNL205->IdJnl + FNL205->IdFin + FNL205->IdOp to TMP
    nCount := 0
    go top
    cLine  := "*"
    cMatch := "*"
    do while ! eof() .and. ! TaskInter()
      MsgDisp2("FNL " + ntrim0(100 * nCount++ / lastrec()) + "%")
      if (jnl := JnlLocate(FNL205->IdJnl)) == NIL
        Warning(FNL205->IdJnl + MsgJnlExist())
        exit
      else
        select FNL
        append blank
        FNL->IdJnl  := FNL205->IdJnl
        FNL->IdDoc  := NewIdDoc(FNL205->IdFin,FNL->IdJnl)
        if FNL205->IdJnl + FNL205->IdFin == cMatch
          cLine := NextId(cLine)
        else
          cMatch := FNL205->IdJnl + FNL205->IdFin
          cLine := "001"
        endif
        FNL->Line   := cLine
        * FNL->Line   := FNL205->IdOp
        FNL->Date   := FNL205->Date
        FNL->Match  := left(FNL205->Match,3) + NewIdDoc(substr(FNL205->Match,4),left(FNL205->Match,3))
        if "-" $ FNL205->cMont
          FNL->DC := jnl[JNL_DC]
          FNL->Mont := strtran(FNL205->cMont,"-"," ")
        else
          FNL->DC := DcInvert(jnl[JNL_DC])
          FNL->Mont := FNL205->cMont
        endif
        if FNL205->CptType == "G"
          FNL->IdCpt := FNL205->Compte
          if trim(FNL205->Libell) != trim(GenName(FNL->IdCpt))
            FNL->Libell := FNL205->Libell
          endif
        else
          FNL->IdCtr := NewCptType(FNL205->CptType)
          FNL->IdCpt := ParNewId(FNL->IdCtr,FNL205->Compte)
          if trim(FNL205->Libell) != trim(ParName(FNL->IdCpt))
            FNL->Libell := FNL205->Libell
          endif
        endif
        * if jnl[JNL_IDDEV] != DevDefault(FIN->Periode)
        seek FNL->IdJnl + FNL->IdDoc in FIN
        if FIN->IdDev != DevDefault(FIN->Periode)
          FNL->MontDev := FNL->Mont
          FNL->Mont := ntom(val(FNL->Mont) * val(FIN->Cours))
        endif
        select FNL205
      endif
      skip
    enddo
    use (cPath + "\ODL.DBF") alias ODL205
    index on ODL205->IdJnl + ODL205->IdDoc to TMP
    cLine  := "*"
    cMatch := "*"
    nCount := 0
    go top
    do while ! eof() .and. ! TaskInter()
      MsgDisp2("ODL " + ntrim0(100 * nCount++ / lastrec()) + "%")
      if (jnl := JnlLocate(ODL205->IdJnl)) == NIL
        Warning(ODL205->IdJnl + MsgJnlExist())
        exit
      else
        select FNL
        append blank
        FNL->IdJnl  := ODL205->IdJnl
        FNL->IdDoc  := NewIdDoc(ODL205->IdDoc,FNL->IdJnl)
        if ODL205->IdJnl + ODL205->IdDoc == cMatch
          cLine := NextId(cLine)
        else
          cMatch := ODL205->IdJnl + ODL205->IdDoc
          cLine := "001"
        endif
        FNL->Line   := cLine
        // FNL->Line   := ODL205->IdOp
        // FNL->Date   := ODL205->Date
        FNL->Match  := left(ODL205->Match,3) + NewIdDoc(substr(ODL205->Match,4),left(ODL205->Match,3))
        * FNL->Match  := ODL205->Match
        * FNL->Libell := ODL205->Libell
        if empty(ODL205->cMontD)
          FNL->DC := DC_CREDIT
          FNL->Mont := ODL205->cMontC
        else
          FNL->DC := DC_DEBIT
          FNL->Mont := ODL205->cMontD
        endif
        * if "-" ODL205->cMont
        *   FNL->DC := DcInvert(jnl[JNL_DC])
        *   FNL->Mont := strtran(ODL205->cMont,"-"," ")
        * else
        *   FNL->DC := jnl[JNL_DC]
        *   FNL->Mont := ODL205->cMont
        * endif
        if ODL205->CptType == "G"
          FNL->IdCpt := ODL205->Compte
          if trim(ODL205->Libell) != trim(GenName(FNL->IdCpt))
            FNL->Libell := ODL205->Libell
          endif
        else
          FNL->IdCtr := NewCptType(ODL205->CptType)
          FNL->IdCpt := ParNewId(FNL->IdCtr,ODL205->Compte)
          if trim(ODL205->Libell) != trim(ParName(FNL->IdCpt))
            FNL->Libell := ODL205->Libell
          endif
        endif
        * if jnl[JNL_IDDEV] != DevDefault()
        *   FNL->MontDev := FNL->Mont
        *   seek FNL->IdJnl + FNL->IdDoc in FIN
        *   FNL->Mont := ntom(val(FNL->Mont) * val(FIN->Cours))
        * endif
        select ODL205
      endif
      skip
    enddo
    use
  close area
  ddCloseAll()
endif

#ifdef DEF_PRESTO

**
** TRM : Agenda
**
if cTrm == BUTTON_ON
  ddCloseAll()
  open area oTrm() exclusive
    zap
    select 0
    use (cPath + "\TAC.DBF") alias TAC205
    index on TAC205->IdTac to TMP
    select 0
    use (cPath + "\TRM.DBF") alias TRM205
    go top
    do while ! eof()
      * if ! empty(TRM->User)
        select TRM
        append blank
        TRM->Date   := TRM205->Date
        TRM->Debut  := TRM205->Debut
        TRM->Duree  := TRM205->Duree
        TRM->Fin    := TRM205->Fin
        TRM->Texte  := TRM205->Texte
        TRM->User   := TRM205->User
        TRM->Attrib := TRM205->Lieu
        TRM->IdTac  := TRM205->IdTac
        #ifdef CUST_REUL            // fr Reul PRESTO
          TRM->Autres := TRM205->Autres
          TRM->Km     := alltrim(TRM205->Deplac)
        #endif CUST_REUL
        if empty(TRM205->iCli)
          TRM->IdPar  := ParNewId(IDCTR_E,TRM205->iFou)
        else
          TRM->IdPar  := ParNewId(IDCTR_V,TRM205->iCli)
        endif
        if ! empty(TRM205->MemoTxt)
          TRM->MemoTxt  := TRM205->MemoTxt
        endif
        TRM->Etat     := TRM205->Etat
        select TRM205
      * endif
      skip
    enddo
    select TAC205
    use
    delete file TMP.NTX
    select TRM205
    use
  close area
endif

#endif DEF_PRESTO

**
** MSG : Agenda
**
if cMsg == BUTTON_ON
  ddCloseAll()
  open area oMsg() exclusive
    zap
  close area
  ddCloseAll()
  open area oMsg()
    select 0
    use (cPath + "\MSG.DBF") alias MSG205
    go top
    do while ! eof()
      select MSG
      if TaskInter() ; exit ; endif
      if dbAddRec()
        MSG->IdUsr  := MSG205->IdUsrT
        MSG->Date   := MSG205->Date
        MSG->Titre  := MSG205->Titre
        MSG->Texte  := MSG205->Texte
        MSG->IdPar := ParNewId(NewCptType(MSG205->CptType),MSG205->Compte)
        MSG->IdTxt    := MSG205->IdTxt
        unlock record
      endif
      select MSG205
      skip
    enddo
    select MSG205
    use
  close area
endif

RETURN NIL


FUNCTION VnlGenUpgrade(cIdCtr)
local ipb
RETURN .t. if VNL->Code == LNCODE_REMARQ
seek VNL->IdJnl + VNL->IdDoc in VEN
if ! eof() in VEN
  seek VEN->IdPar in PAR
  if ! eof() in PAR
    if IsArtCode(VNL->Code)
      if ArtExist(VNL->IdArt)
        if (ipb := IpbLocate(cIdCtr,PAR->IdReg,ART->IdCat,VNL->IdTax,VEN->IdDev)) == NIL
          SendConsole( ;
            cIdCtr+ "/" + PAR->IdReg + "/" + ART->IdCat + "/" + VNL->IdTax + " : ohne Buchungsanweisung !" ;
          )
          RETURN .t.
        endif
        RETURN .f. if ! GenExist(ipb[IPB_GENBASE])
        if empty(GEN->IdCtr)
          GEN->IdCtr := cIdCtr
        endif
        if empty(GEN->IdTax)
          GEN->IdTax := VNL->IdTax
        endif
      endif
    elseif VNL->Code == LNCODE_GEN
      RETURN .f. if ! GenExist(VNL->IdArt)
      if empty(GEN->IdCtr)
        GEN->IdCtr := cIdCtr
        * GEN->IdCtr := JnlIdCtr(VNL->IdJnl)
      endif
      if empty(GEN->IdTax)
        GEN->IdTax := VNL->IdTax
      endif
    endif
  endif
endif
RETURN .t.



*FUNCTION VnmUpgrade()
*local cIdJnlLib := "MOD"
*local nRecNo
*local nRecNoVnl
*local cIdJnl
*local cIdDoc
*local cIdDev
*local cCours
*local cNewIdDoc
*local cTitre
*local cMontB
*local cMontT
*local cQte
*local nCount := 0
*local nRecCount := 0
*ddCloseAll()
*MsgDisplay("Index VNM...")
*use (DbPath() + "\VNM.DBF")
*index on VNM->IdJnl + VNM->IdDoc + VNM->IdVnm to VNM1
*MsgDisplay("Module importieren nach Journal " + cIdJnlLib + "...")
*ddCloseAll()
*open area oVen(), oVnl() exclusive
*  nRecCount := lastrec()
*  go top
*  do while ! eof() .and. ! TaskInter()
*    if VEN->IdJnl != cIdJnlLib
*      MsgDisp2(str(nCount++ * 100 / nRecCount,5,1) + "%")
*      if "M" $ VEN->Attrib
*        nRecNo := recno()
*        cIdJnl := VEN->IdJnl
*        cIdDoc := VEN->IdDoc
*        cIdDev := VEN->IdDev
*        cCours := VEN->Cours
*        select VNM
*        softseek cIdJnl + cIdDoc
*        do while VNM->IdJnl == cIdJnl .and. VNM->IdDoc == cIdDoc
*          cTitre := VNM->Desig
*          cMontB := VNM->cMontB
*          cMontT := VNM->cMontT
*          cQte   := VNM->Qte
*          select VEN
*          KeyGoBottom( cIdJnlLib, {|| VEN->IdJnl + VEN->IdDoc })
*          cNewIdDoc := NextId(VEN->IdDoc)
*          append blank
*          VEN->IdJnl   := cIdJnlLib
*          VEN->IdDoc   := cNewIdDoc
*          VEN->NB1  := cTitre
*          VEN->IdDev  := cIdDev
*          SetDecPos(DevDecPos(cIdDev))
*          VEN->Cours  := cCours
*          VEN->Mont   := ntom(val(cMontB) + val(cMontT))
*          * VEN->cMontB := cMontB
*          * VEN->cMontT := cMontT
*          select VNL
*          softseek cIdJnl + cIdDoc + VNM->IdVnm
*          do while VNL->IdJnl + VNL->IdDoc + VNL->IdVnm == cIdJnl + cIdDoc + VNM->IdVnm
*            skip
*            nRecNoVnl := recno()
*            skip -1
*            VNL->IdJnl := cIdJnlLib
*            VNL->IdDoc := cNewIdDoc
*            VNL->Line  := "0" + VNM->IdVnm
*            goto nRecNoVnl
*          enddo
*          append blank
*          VNL->IdJnl := cIdJnl
*          VNL->IdDoc := cIdDoc
*          VNL->IdVnm := VNM->IdVnm
*          VNL->Desig := cTitre
*          VNL->Code  := LNCODE_DOC
*          VNL->IdArt := cNewIdDoc
*          VNL->Qte   := cQte
*          VNL->PrixU := cMontB
*          VNL->cMont := ntom(val(cMontB) * qton(cQte))
*          VNL->MontT := ntom(val(cMontT) * qton(cQte))
*          select VNM
*          skip
*        enddo
*        select VEN
*        goto nRecNo
*      endif
*    endif
*    skip
*  enddo
*  WriteInd("vnm300")
*  SetDecPos(DevDecPos(DevDefault()))
*close area
*ddCloseAll()
*use
*RETURN NIL
*
*FUNCTION TxtUpgrade
*open area oTxt()
*  go top
*  do while ! eof()
*    if TXT->Type == "F  "  // TXTTYPE_MASQUE
*      TXT->Type := TPLTYPE_VEN
*    elseif TXT->Type == "T  "  // TXTTYPE_BLOCK
*      TXT->Type := TPLTYPE_INC
*    elseif TXT->Type == "A  "  // TXTTYPE_ART
*      TXT->Type := TPLTYPE_ADC
*    endif
*    skip
*  enddo
*  WriteInd("txt300")
*close area
*RETURN NIL

**
** ParImport() - import clients & fournisseurs from TIM 2.05
**
FUNCTION ParImport(cPath,cAlias)
local cFile
local nCount := 0
local lOverwrite := .t.
local cIdPar
local lOkay := .t.
cFile := trim(cPath) + "\" + cAlias + ".DBF"
if ! file(cFile)
  Warning(cFile + " : Datei nicht gefunden !")
  RETURN .f.
endif
ddCloseAll()
open area oPar()
  ddSetOrder(ORD_PAR_ID)
  select 0
  use (cFile) alias IMPORT
  go top
  do while ! eof() .and. lOkay
    if TaskInter() ; exit ; endif
    if cAlias == "CLI"
      cIdPar   := ParNewId(IDCTR_V,IMPORT->iCli)
    else
      cIdPar   := ParNewId(IDCTR_E,IMPORT->iFou)
    endif
    MsgDisplay(cIdPar + " " + IMPORT->Firme)
    MsgDisp2(ntrim0(100*nCount++/lastrec()) + "%")
    select PAR
    seek cIdPar
    if eof()
      if dbAddRec()
        PAR->IdPar   := cIdPar
        lOverwrite := .t.
      else
        lOkay := .f.
        exit
      endif
    * elseif ddRecLock()
    *   lOverwrite := Confirm( cAlias + " " + ;
    *                   cIdPar + " " + ;
    *                   trim(IMPORT->Firme) + " berschreiben ?")
    else
      lOverwrite := .f.
    endif
    if lOverwrite
      PAR->DatCrea  := IMPORT->DatCrea
      PAR->Firme    := IMPORT->Firme
      PAR->Memo     := IMPORT->Memo
      if cAlias == "CLI"
        #ifdef DEF_205
        if IMPORT->Statut == "1"       // prospect
          PAR->Attrib := "P"
        elseif IMPORT->Statut == "2"   // prospect actif
          PAR->Attrib := "C"           // contact
        elseif IMPORT->Statut == "3"   // client actif
          PAR->Attrib := "C"           // contact
        elseif IMPORT->Statut == "4"   // ancien client
          PAR->Attrib := "H"           // hidden
        endif
        #endif DEF_205
        // PAR->IdPrt := "K"
        PAR->Name2    := IMPORT->Activite
        * PAR->RueNum   := IMPORT->RueNum
        * PAR->RueBte   := IMPORT->RueBte
        PAR->Compte1  := IMPORT->Compte
        PAR->Compte2  := IMPORT->Compte2
        PAR->Tel      := IMPORT->Tel
        PAR->Fax      := IMPORT->Fax
        * PAR->Remise   := IMPORT->Remise
        PAR->IdPrt    := IDPRT_K // + IMPORT->Statut
        // PAR->DC       := PrtDC(PAR->IdPrt)
        * PAR->Mailing  := IMPORT->Mailing
        PAR->Prof     := IMPORT->Prof
        PAR->Code1    := IMPORT->Code1
        PAR->Code2    := IMPORT->Code2
        PAR->Code3    := IMPORT->Code3
        PAR->NB1      := IMPORT->NB1
        PAR->NB2      := IMPORT->NB2
        #ifdef DEF_205
          PscImport(cIdPar,IMPORT->Nom1,IMPORT->Fct1,IMPORT->Tel1)
          PscImport(cIdPar,IMPORT->Nom2,IMPORT->Fct2,IMPORT->Tel2)
        #endif DEF_205
      else
        // PAR->IdPrt := "L"
        #ifdef DEF_205
        if IMPORT->Statut == "1"
          PAR->Attrib := "A"
        elseif IMPORT->Statut == "3"
          PAR->Attrib := "H"
        endif
        #endif DEF_205
        PAR->Compte1  := IMPORT->Compte1
        PAR->Compte2  := IMPORT->Compte2
        PAR->Name2    := IMPORT->Groupes
        PAR->Tel      := IMPORT->Fax2
        PAR->Fax      := IMPORT->Fax1
        PAR->IdPrt    := IDPRT_L // "F" // + IMPORT->Statut
        // PAR->DC       := PrtDC(PAR->IdPrt)
        #ifdef DEF_205
          PscImport(cIdPar,IMPORT->Nom1,IMPORT->Fct1,IMPORT->Tel1)
          PscImport(cIdPar,IMPORT->Nom2,IMPORT->Fct2,IMPORT->Tel2)
          PscImport(cIdPar,IMPORT->Nom3,IMPORT->Fct3,IMPORT->Tel3)
          PscImport(cIdPar,IMPORT->Nom4,IMPORT->Fct4,IMPORT->Tel4)
          PscImport(cIdPar,IMPORT->Nom5,IMPORT->Fct5,IMPORT->Tel5)
        #endif DEF_205
      endif
      PAR->Rue      := IMPORT->Rue
      PAR->CP       := IMPORT->CP
      PAR->Pays     := IMPORT->Pays
      PAR->NoTVA    := GetNoTva(IMPORT->NoTVA,PAR->Pays)
      * PAR->Attrib   := IMPORT->Attrib
      PAR->IdMfc   := NewIdMfc(IMPORT->ModPai)
      PAR->Langue   := IMPORT->Langue
      * PAR->Statut   := IMPORT->Statut
      PAR->IdReg    := IMPORT->IdReg
      PAR->Allo     := IMPORT->Allo
      PAR->IdDev    := IMPORT->IdDev
      * if empty(PAR->IdDev)
      *   PAR->IdDev := DevDefault(PerActive())
      * endif
    endif
    unlock record
    select IMPORT
    skip
  enddo
  use
  select PAR
  dbcommit()
close area
ddCloseAll()
RETURN .t.

FUNCTION ParNewId(cCptType,cCompte)
#ifdef CUST_TRANSEX
  RETURN cCompte
#else
  RETURN cCompte if cCptType == IDCTR_V
  RETURN cCompte if empty(cCompte)
  * bei Reul jedenfalls durfte das nicht sein...
  * if right(cCompte,1) == " "
  *   RETURN IDPRT_L + left(cCompte,LenIdPar() - 1)
  * endif
  if left(cCompte,1) == "0"
    RETURN IDPRT_L + right(cCompte,LenIdPar() - 1)
  endif
  * Warning("PAR->" + cCompte + " : IdPar kann nicht konvertiert werden !")
  RETURN cCompte
#endif

FUNCTION NewCptType(cCptType)
RETURN IDCTR_E if cCptType == "L"
RETURN IDCTR_E if cCptType == "F"
RETURN IDCTR_V if cCptType == "C"
RETURN IDCTR_V if cCptType == "K"
RETURN cCptType

FUNCTION PscImport(cIdPar,cNom,cFct,cTel)
RETURN NIL if empty(cNom)
PAR->Memo += cNom + "³" + cFct + "³" + cTel + CR_LF
* open area oPsc()
*   append blank
*   PSC->IdPar  := cIdPar
*   PSC->LName  := cNom
*   PSC->Remarq := cFct
*   PSC->Tel    := cTel
* close area
RETURN NIL

*  #ifdef DEF_COMPTA
*
*  **
*  ** OpdConvert()
*  **
*  FUNCTION OpdConvert
*  if len(trim(DBN->IdDoc)) == 4
*    DBN->IdDoc := "9" + left(DBO->IdDoc,1) + "0" + substr(DBO->IdDoc,2,3)
*  endif
*  RETURN .t.
*
*  **
*  ** OdlConvert()
*  **
*  FUNCTION OdlConvert
*  if empty(DBN->IdCpt)
*    DBN->IdCpt := ParNewId(DBO->CptType,DBO->Compte)
*  endif
*  if len(trim(DBN->IdDoc)) == 4
*    DBN->IdDoc := "9" + left(DBO->IdDoc,1) + "0" + substr(DBO->IdDoc,2,3)
*  endif
*  RETURN .t.
*
*  **
*  ** FnlConvert()
*  **
*  FUNCTION FnlConvert
*  if empty(DBN->IdCpt)
*    DBN->IdCpt := ParNewId(DBO->CptType,DBO->Compte)
*  endif
*  if len(trim(DBN->IdDoc)) == 4
*    DBN->IdDoc := "9" + left(DBO->IdFin,1) + "0" + substr(DBO->IdFin,2,3)
*  endif
*  RETURN .t.
*
*  **
*  ** FinConvert()
*  **
*  FUNCTION FinConvert
*  if len(trim(DBN->IdDoc)) == 4
*    DBN->IdDoc := "9" + left(DBO->IdFin,1) + "0" + substr(DBO->IdFin,2,3)
*  endif
*  RETURN .t.
*
*  **
*  ** MvtConvert()
*  **
*  FUNCTION MvtConvert
*  if empty(DBN->IdCpt)
*    DBN->IdCpt := ParNewId(DBO->CptType,DBO->Compte)
*  endif
*  if len(trim(DBN->IdDoc)) == 4
*    DBN->IdDoc := "9" + left(DBO->IdDoc,1) + "0" + substr(DBO->IdDoc,2,3)
*  endif
*  if len(trim(DBN->Match)) == 7
*    DBN->IdDoc := left(DBO->Match,3) + "9" ;
*                  + substr(DBO->Match,4,1) + "0" ;
*                  + substr(DBO->Match,5,3)
*  endif
*  RETURN .t.
*
*
*  #endif DEF_COMPTA
*
*  **
*  ** TxtConvert()
*  **
*  FUNCTION TxtConvert
*  if DBO->Type == "A"
*    DBN->Type := "ADC"
*  elseif DBO->Type == "F"
*    DBN->Type := "VEN"
*  elseif DBO->Type == "T"
*    DBN->Type := "INC"
*  endif
*  RETURN .t.


#endif DEF_IMPTIM205

*FUNCTION WriteInd(cName)
*local fd
*if (fd := fcreate(DbPath() + "\" + cName + ".ind")) != -1
*  fwrite(fd,"done " + dtoc(date()) + " at " + time())
*  fclose(fd)
*endif
*RETURN NIL

*#ifdef CUST_PAC
*
*FUNCTION NewIdTax(cIdCtr,cIdTax)
*if cIdCtr == IDCTR_E
*  RETURN "A  " if cIdTax == "1"
*  RETURN "B  " if cIdTax == "B"
*  RETURN "N  " if cIdTax == "G"
*  RETURN "N  " if cIdTax == "C"
*  RETURN "N  " if cIdTax == "2"
*  RETURN "NN " if cIdTax == "H"
*  RETURN "NN " if cIdTax == "D"
*  RETURN "NN " if cIdTax == "4"
*  * RETURN "D21" if cIdTax == "G"
*  * RETURN "D20" if cIdTax == "C"
*  * RETURN "D19" if cIdTax == "2"
*  * RETURN "N21" if cIdTax == "H"
*  * RETURN "N20" if cIdTax == "D"
*  * RETURN "N19" if cIdTax == "4"
*  RETURN "NI " if cIdTax == "I"
*  RETURN "NI " if cIdTax == "E"
*  RETURN "NI " if cIdTax == "5"
*  RETURN "0  " if cIdTax == "3"
*  RETURN "C  " if cIdTax == "6"
*  RETURN "X  " if cIdTax == "9"
*elseif cIdCtr == IDCTR_V
*  RETURN "A  " if cIdTax == "1"
*  RETURN "0  " if cIdTax == "3"
*  RETURN "IS " if cIdTax == "7"
*  RETURN "NI " if cIdTax == "8"
*  RETURN "B  " if cIdTax == "B"
*  RETURN "N  " if cIdTax == "2"
*  RETURN "N  " if cIdTax == "C"
*  RETURN "N  " if cIdTax == "G"
*  * RETURN "19 " if cIdTax == "2"
*  * RETURN "20 " if cIdTax == "C"
*  * RETURN "21 " if cIdTax == "G"
*  RETURN "FBA" if cIdTax == "F"
*endif
*RETURN cIdTax
*
*FUNCTION NewIdMfc(cIdEsc)
*RETURN "BAR" if cIdEsc == "0"
*RETURN "E  " if cIdEsc == "1"
*RETURN "S3 " if cIdEsc == "2"
*RETURN "S2 " if cIdEsc == "3"
*RETURN "30 " if cIdEsc == "4"
*RETURN "ETC" if cIdEsc == "5"
*RETURN "DOM" if cIdEsc == "7"
*RETURN cIdEsc
*
*FUNCTION NewPeriode(cPeriode)
*RETURN "9513" if cPeriode == "9601"
*RETURN "9514" if cPeriode == "9602"
*RETURN "9515" if cPeriode == "9603"
*RETURN "9516" if cPeriode == "9604"
*RETURN "9517" if cPeriode == "9605"
*RETURN "9518" if cPeriode == "9606"
*RETURN cPeriode
*
*FUNCTION NewIdDoc(cIdDoc,cIdJnl)
*RETURN cIdDoc if len(trim(cIdDoc)) != 4
*RETURN left(cIdDoc,2) + "00" + substr(cIdDoc,3) if cIdJnl == "CAI"
*RETURN cIdDoc if ! cIdJnl $ "BBL;SPA;KDM;OPD;OD2;REP;SAL"
*RETURN "9" + left(cIdDoc,1) + "0" + substr(cIdDoc,2)
*
*#endif CUST_PAC

#ifdef CUST_HSB

**
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "0  " if cIdTax == "0"
  RETURN "DA " if cIdTax == "1"  // 6%
  RETURN "DB " if cIdTax == "2"  // 12%
  RETURN "DN " if cIdTax == "3"  // 20.5%
  RETURN "DN " if cIdTax == "4"  // 21%
  RETURN "NA " if cIdTax == "6"  // 6%  ND
  RETURN "NB " if cIdTax == "7"  // 12% ND
  RETURN "NN " if cIdTax == "8"  // 20.5% ND
  RETURN "NN " if cIdTax == "9"  // 21% ND
  RETURN "C  " if cIdTax == "B"
  RETURN "C  " if cIdTax == "C"
  RETURN "C  " if cIdTax == "D"
  RETURN "C  " if cIdTax == "F"
  RETURN "IM " if cIdTax == "K"
  RETURN "IM " if cIdTax == "L"
  RETURN "X  " if cIdTax == "X"
  RETURN "I15" if cIdTax == "E"
elseif cIdCtr == IDCTR_V
  RETURN "0  " if cIdTax == "0"
  RETURN "A  " if cIdTax == "1"
  RETURN "B  " if cIdTax == "2"
  RETURN "N  " if cIdTax == "3"
  RETURN "N  " if cIdTax == "4"
  RETURN "C  " if cIdTax == "A"
  RETURN "IM " if cIdTax == "I"
  RETURN "IS " if cIdTax == "J"
  RETURN "X  " if cIdTax == "X"
endif
RETURN cIdTax

FUNCTION NewIdMfc(cIdEsc)
RETURN "C  " if cIdEsc == "1"
RETURN "0  " if cIdEsc == "2"
RETURN "30 " if cIdEsc == "3"
RETURN "30M" if cIdEsc == "4"
RETURN "60 " if cIdEsc == "5"
RETURN "60M" if cIdEsc == "6"
RETURN "DOM" if cIdEsc == "7"
RETURN "S8 " if cIdEsc == "8"
RETURN "S8 " if cIdEsc == "9"
RETURN "C3 " if cIdEsc == "A"
RETURN "S30" if cIdEsc == "A"
RETURN cIdEsc

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc if len(trim(cIdDoc)) != 4
if cIdJnl == "COB"
  RETURN "9400" + right(cIdDoc,2) if left(cIdDoc,2) == "50"
  RETURN "9500" + right(cIdDoc,2) if left(cIdDoc,2) == "90"
  RETURN "9600" + right(cIdDoc,2) if left(cIdDoc,2) == "96"
elseif cIdJnl == "CAI"
  RETURN "9500" + right(cIdDoc,2) if left(cIdDoc,2) == "50"
  RETURN "9600" + right(cIdDoc,2) if left(cIdDoc,2) == "96"
elseif cIdJnl == "OPD"
  RETURN "9500" + right(cIdDoc,2) if left(cIdDoc,2) == "50"
endif
RETURN cIdDoc

#endif CUST_HSB

#ifdef CUST_BELLE

**
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "0  " if cIdTax == "0"
  RETURN "DA " if cIdTax == "1"  // 6%
  RETURN "DB " if cIdTax == "2"  // 12%
  RETURN "DN " if cIdTax == "3"  // 20.5%
  RETURN "DN " if cIdTax == "4"  // 21%
  RETURN "NA " if cIdTax == "6"  // 6%  ND
  RETURN "NB " if cIdTax == "7"  // 12% ND
  RETURN "NN " if cIdTax == "8"  // 20.5% ND
  RETURN "NN " if cIdTax == "9"  // 21% ND
  RETURN "C  " if cIdTax == "B"
  RETURN "C  " if cIdTax == "C"
  RETURN "C  " if cIdTax == "D"
  RETURN "C  " if cIdTax == "F"
  RETURN "IM " if cIdTax == "K"
  RETURN "IM " if cIdTax == "L"
  RETURN "X  " if cIdTax == "X"
  RETURN "I15" if cIdTax == "E"
elseif cIdCtr == IDCTR_V
  RETURN "0  " if cIdTax == "0"
  RETURN "A  " if cIdTax == "1"
  RETURN "B  " if cIdTax == "2"
  RETURN "N  " if cIdTax == "3"
  RETURN "N  " if cIdTax == "4"
  RETURN "C  " if cIdTax == "A"
  RETURN "IM " if cIdTax == "I"
  RETURN "IS " if cIdTax == "J"
  RETURN "X  " if cIdTax == "X"
endif
RETURN cIdTax

FUNCTION NewIdMfc(cIdEsc)
RETURN "C  " if cIdEsc == "1"
RETURN "0  " if cIdEsc == "2"
RETURN "30 " if cIdEsc == "3"
RETURN "30M" if cIdEsc == "4"
RETURN "60 " if cIdEsc == "5"
RETURN "60M" if cIdEsc == "6"
RETURN "DOM" if cIdEsc == "7"
RETURN "S8 " if cIdEsc == "8"
RETURN "S8 " if cIdEsc == "9"
RETURN "C3 " if cIdEsc == "A"
RETURN "S30" if cIdEsc == "A"
RETURN cIdEsc

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc

#endif CUST_BELLE

#ifdef CUST_REUL

**
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "0  " if cIdTax == "0"
  RETURN "A  " if cIdTax == "1"  // 6%
  RETURN "N  " if cIdTax == "2"  // 12%
  RETURN "N  " if cIdTax == "3"  // 20.5%
  RETURN "ND " if cIdTax == "4"  // nd entretien mat. rlt
  RETURN "ND " if cIdTax == "5"  // nd entretien mat. rlt
  RETURN "ND " if cIdTax == "6"  // nd entretien mat. rlt
  RETURN "ND " if cIdTax == "C"  // nd entretien mat. rlt
  RETURN "X  " if cIdTax == "7"
  RETURN "IM " if cIdTax == "8"
  RETURN "ND " if cIdTax == "9"
  RETURN "C  " if cIdTax == "A"
  RETURN "ND " if cIdTax == "I"
  RETURN "ND " if cIdTax == "N"
elseif cIdCtr == IDCTR_V
  RETURN "0  " if cIdTax == "0"
  RETURN "A  " if cIdTax == "1"
  RETURN "N  " if cIdTax == "2"
  RETURN "N  " if cIdTax == "3"
  RETURN "X  " if cIdTax == "7"
  RETURN "C  " if cIdTax == "B"
endif
RETURN cIdTax + "?"

FUNCTION NewIdMfc(cIdEsc)
RETURN "E  " if cIdEsc == "1"
RETURN "0  " if cIdEsc == "2"
RETURN "30 " if cIdEsc == "3"
RETURN "30M" if cIdEsc == "4"
RETURN "60 " if cIdEsc == "5"
RETURN "60M" if cIdEsc == "6"
RETURN "DOM" if cIdEsc == "7"
RETURN "S8 " if cIdEsc == "8"
RETURN "S8 " if cIdEsc == "9"
RETURN "C3 " if cIdEsc == "A"
RETURN "S30" if cIdEsc == "A"
RETURN cIdEsc + "?"

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc if len(trim(cIdDoc)) != 4
RETURN "9" + left(cIdDoc,1) + "0" + right(cIdDoc,3)

#endif CUST_REUL

#ifdef CUST_BOURSIE

**
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "0  " if cIdTax == "0  "
  RETURN "D6 " if cIdTax == "06 "  // 6%
  RETURN "D12" if cIdTax == "12 "  // 12%
  RETURN "D21" if cIdTax == "20 "  // 20.5%
  RETURN "D21" if cIdTax == "21 "  // 20.5%
  RETURN "D15" if cIdTax == "5  "
  RETURN "C  " if cIdTax == "EC "
  RETURN "N6 " if cIdTax == "N06"  // 6%  ND
  RETURN "N12" if cIdTax == "N12"  // 12% ND
  RETURN "N21" if cIdTax == "N20"  // 20.5% ND
  RETURN "N21" if cIdTax == "N21"  // 20.5% ND
  RETURN "IM " if cIdTax == "I06"
  RETURN "IM " if cIdTax == "I12"
  RETURN "IM " if cIdTax == "I20"
  RETURN "IM " if cIdTax == "I21"
  RETURN "X  " if cIdTax == "X  "
elseif cIdCtr == IDCTR_V
  RETURN "0  " if cIdTax == "0  "
  RETURN "6  " if cIdTax == "06 "
  RETURN "12 " if cIdTax == "12 "
  RETURN "21 " if cIdTax == "20 "
  RETURN "21 " if cIdTax == "21 "
  RETURN "15 " if cIdTax == "5  "
  RETURN "C  " if cIdTax == "VC "
  RETURN "IM " if cIdTax == "I46"
  RETURN "IS " if cIdTax == "I47"
  RETURN "X  " if cIdTax == "X  "
endif
RETURN cIdTax

FUNCTION NewIdMfc(cIdEsc)
RETURN "C  " if cIdEsc == "1"
RETURN "0  " if cIdEsc == "2"
RETURN "30 " if cIdEsc == "3"
RETURN "30M" if cIdEsc == "4"
RETURN "60 " if cIdEsc == "5"
RETURN "60M" if cIdEsc == "6"
RETURN "DOM" if cIdEsc == "7"
RETURN "S8 " if cIdEsc == "8"
RETURN "S8 " if cIdEsc == "9"
RETURN "C3 " if cIdEsc == "A"
RETURN "S30" if cIdEsc == "A"
RETURN cIdEsc

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc

#endif CUST_BOURSIE

#ifdef CUST_TRANSEX

** TRANSEX 19990317
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "0  " if cIdTax == "0  "
  RETURN "D6 " if cIdTax == "06 "  // 6%
  RETURN "D12" if cIdTax == "12 "  // 12%
  RETURN "D21" if cIdTax == "20 "  // 20.5%
  RETURN "D21" if cIdTax == "21 "  // 20.5%
  RETURN "D15" if cIdTax == "5  "
  RETURN "C  " if cIdTax == "EC "
  RETURN "N6 " if cIdTax == "N06"  // 6%  ND
  RETURN "N12" if cIdTax == "N12"  // 12% ND
  RETURN "N21" if cIdTax == "N20"  // 20.5% ND
  RETURN "N21" if cIdTax == "N21"  // 20.5% ND
  RETURN "IM " if cIdTax == "I06"
  RETURN "IM " if cIdTax == "I12"
  RETURN "IM " if cIdTax == "I20"
  RETURN "IM " if cIdTax == "I21"
  RETURN "X  " if cIdTax == "X  "
elseif cIdCtr == IDCTR_V
  RETURN "0  " if cIdTax == "0  "
  RETURN "6  " if cIdTax == "06 "
  RETURN "12 " if cIdTax == "12 "
  RETURN "21 " if cIdTax == "20 "
  RETURN "21 " if cIdTax == "21 "
  RETURN "15 " if cIdTax == "5  "
  RETURN "C  " if cIdTax == "VC "
  RETURN "IM " if cIdTax == "I46"
  RETURN "IS " if cIdTax == "I47"
  RETURN "X  " if cIdTax == "X  "
endif
RETURN cIdTax

FUNCTION NewIdMfc(cIdEsc)
RETURN "C  " if cIdEsc == "1"
RETURN "0  " if cIdEsc == "2"
RETURN "30 " if cIdEsc == "3"
RETURN "30M" if cIdEsc == "4"
RETURN "60 " if cIdEsc == "5"
RETURN "60M" if cIdEsc == "6"
RETURN "DOM" if cIdEsc == "7"
RETURN "S8 " if cIdEsc == "8"
RETURN "S8 " if cIdEsc == "9"
RETURN "C3 " if cIdEsc == "A"
RETURN "S30" if cIdEsc == "A"
RETURN cIdEsc

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc

#endif CUST_TRANSEX

#ifdef CUST_SABMA

** Sabma 15.1.97
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "0  " if cIdTax == "0  "
  RETURN "D6 " if cIdTax == "06 "  // 6%
  RETURN "D12" if cIdTax == "12 "  // 12%
  RETURN "D21" if cIdTax == "20 "  // 20.5%
  RETURN "D21" if cIdTax == "21 "  // 20.5%
  RETURN "D15" if cIdTax == "5  "
  RETURN "C  " if cIdTax == "EC "
  RETURN "N6 " if cIdTax == "N06"  // 6%  ND
  RETURN "N12" if cIdTax == "N12"  // 12% ND
  RETURN "N21" if cIdTax == "N20"  // 20.5% ND
  RETURN "N21" if cIdTax == "N21"  // 20.5% ND
  RETURN "IM " if cIdTax == "I06"
  RETURN "IM " if cIdTax == "I12"
  RETURN "IM " if cIdTax == "I20"
  RETURN "IM " if cIdTax == "I21"
  RETURN "X  " if cIdTax == "X  "
elseif cIdCtr == IDCTR_V
  RETURN "0  " if cIdTax == "0  "
  RETURN "6  " if cIdTax == "06 "
  RETURN "12 " if cIdTax == "12 "
  RETURN "21 " if cIdTax == "20 "
  RETURN "21 " if cIdTax == "21 "
  RETURN "15 " if cIdTax == "5  "
  RETURN "C  " if cIdTax == "VC "
  RETURN "IM " if cIdTax == "I46"
  RETURN "IS " if cIdTax == "I47"
  RETURN "X  " if cIdTax == "X  "
endif
RETURN cIdTax

FUNCTION NewIdMfc(cIdEsc)
RETURN "E  " if cIdEsc == "R  "
RETURN cIdEsc

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc

#endif CUST_SABMA

#ifdef CUST_GARN

**
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "D21" if cIdTax == "3"  // 20.5%
  RETURN "D6 " if cIdTax == "1"  // 6%
  RETURN "D12" if cIdTax == "2"  // 12%
  RETURN "N12" if cIdTax == "8"  // 12% ND
  RETURN "N6 " if cIdTax == "6"  // 6%  ND
  RETURN "N21" if cIdTax == "7"  // 20.5% ND
  RETURN "0  " if cIdTax == "0"
  RETURN "C  " if cIdTax == "B" // einkauf vertragspartner 6%
  RETURN "X  " if cIdTax == "X"
  RETURN "IM " if cIdTax == "K"
elseif cIdCtr == IDCTR_V
  RETURN "21 " if cIdTax == "3"
  RETURN "6  " if cIdTax == "1"
  RETURN "12 " if cIdTax == "2"
  RETURN "0  " if cIdTax == "0"
  RETURN "C  " if cIdTax == "A"
  RETURN "X  " if cIdTax == "X"
  RETURN "IM " if cIdTax == "I"
  RETURN "IS " if cIdTax == "J"
endif
RETURN cIdTax

FUNCTION NewIdMfc(cIdEsc)
RETURN "BAR" if cIdEsc == "1"
RETURN "DOM" if cIdEsc == "7"
RETURN "S2 " if cIdEsc == "8"
RETURN "21 " if cIdEsc == "9"
RETURN "E  " if cIdEsc == "2"
RETURN "30 " if cIdEsc == "3"
RETURN "30M" if cIdEsc == "4"
RETURN "60 " if cIdEsc == "5"
RETURN "60M" if cIdEsc == "6"
RETURN "10 " if cIdEsc == "0"
RETURN "14 " if cIdEsc == "A"
RETURN cIdEsc

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc if len(trim(cIdDoc)) != 4
RETURN "9" + left(cIdDoc,1) + "0" + right(cIdDoc,3)

#endif CUST_GARN

#ifdef CUST_MERVEILLE

**
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "0  " if cIdTax == "0  "
  RETURN "D6 " if cIdTax == "06 "  // 6%
  RETURN "D12" if cIdTax == "12 "  // 12%
  RETURN "D21" if cIdTax == "20 "  // 20.5%
  RETURN "D21" if cIdTax == "21 "  // 20.5%
  RETURN "D15" if cIdTax == "5  "
  RETURN "C  " if cIdTax == "EC "
  RETURN "N6 " if cIdTax == "N06"  // 6%  ND
  RETURN "N12" if cIdTax == "N12"  // 12% ND
  RETURN "N21" if cIdTax == "N20"  // 20.5% ND
  RETURN "N21" if cIdTax == "N21"  // 20.5% ND
  RETURN "IM " if cIdTax == "I06"
  RETURN "IM " if cIdTax == "I12"
  RETURN "IM " if cIdTax == "I20"
  RETURN "IM " if cIdTax == "I21"
  RETURN "X  " if cIdTax == "X  "
elseif cIdCtr == IDCTR_V
  RETURN "0  " if cIdTax == "0  "
  RETURN "6  " if cIdTax == "06 "
  RETURN "12 " if cIdTax == "12 "
  RETURN "21 " if cIdTax == "20 "
  RETURN "21 " if cIdTax == "21 "
  RETURN "15 " if cIdTax == "5  "
  RETURN "C  " if cIdTax == "VC "
  RETURN "IM " if cIdTax == "I46"
  RETURN "IS " if cIdTax == "I47"
  RETURN "X  " if cIdTax == "X  "
endif
RETURN cIdTax

FUNCTION NewIdMfc(cIdEsc)
RETURN "C  " if cIdEsc == "1"
RETURN "0  " if cIdEsc == "2"
RETURN "30 " if cIdEsc == "3"
RETURN "30M" if cIdEsc == "4"
RETURN "60 " if cIdEsc == "5"
RETURN "60M" if cIdEsc == "6"
RETURN "DOM" if cIdEsc == "7"
RETURN "S8 " if cIdEsc == "8"
RETURN "S8 " if cIdEsc == "9"
RETURN "C3 " if cIdEsc == "A"
RETURN "S30" if cIdEsc == "A"
RETURN cIdEsc

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc

#endif CUST_MERVEILLE


#ifdef CUST_DRUWID

** 22.7.97
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "0  " if cIdTax == "0  "
  RETURN "D6 " if cIdTax == "06 "  // 6%
  RETURN "D12" if cIdTax == "12 "  // 12%
  RETURN "D21" if cIdTax == "20 "  // 20.5%
  RETURN "D21" if cIdTax == "21 "  // 20.5%
  RETURN "D15" if cIdTax == "5  "
  RETURN "C  " if cIdTax == "EC "
  RETURN "N6 " if cIdTax == "N06"  // 6%  ND
  RETURN "N12" if cIdTax == "N12"  // 12% ND
  RETURN "N21" if cIdTax == "N20"  // 20.5% ND
  RETURN "N21" if cIdTax == "N21"  // 20.5% ND
  RETURN "IM " if cIdTax == "I06"
  RETURN "IM " if cIdTax == "I12"
  RETURN "IM " if cIdTax == "I20"
  RETURN "IM " if cIdTax == "I21"
  RETURN "X  " if cIdTax == "X  "
elseif cIdCtr == IDCTR_V
  RETURN "0  " if cIdTax == "0  "
  RETURN "6  " if cIdTax == "06 "
  RETURN "12 " if cIdTax == "12 "
  RETURN "21 " if cIdTax == "20 "
  RETURN "21 " if cIdTax == "21 "
  RETURN "15 " if cIdTax == "5  "
  RETURN "C  " if cIdTax == "VC "
  RETURN "IM " if cIdTax == "I46"
  RETURN "IS " if cIdTax == "I47"
  RETURN "X  " if cIdTax == "X  "
endif
RETURN cIdTax

FUNCTION NewIdMfc(cIdEsc)
RETURN "E  " if cIdEsc == "R  "
RETURN cIdEsc

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc

#endif CUST_DRUWID

#ifdef CUST_HARDT

** 1.10.97
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "0  " if cIdTax == "0  "
  RETURN "D6 " if cIdTax == "06 "  // 6%
  RETURN "D12" if cIdTax == "12 "  // 12%
  RETURN "D21" if cIdTax == "20 "  // 20.5%
  RETURN "D21" if cIdTax == "21 "  // 20.5%
  RETURN "D15" if cIdTax == "5  "
  RETURN "C  " if cIdTax == "EC "
  RETURN "N6 " if cIdTax == "N06"  // 6%  ND
  RETURN "N12" if cIdTax == "N12"  // 12% ND
  RETURN "N21" if cIdTax == "N20"  // 20.5% ND
  RETURN "N21" if cIdTax == "N21"  // 20.5% ND
  RETURN "IM " if cIdTax == "I06"
  RETURN "IM " if cIdTax == "I12"
  RETURN "IM " if cIdTax == "I20"
  RETURN "IM " if cIdTax == "I21"
  RETURN "X  " if cIdTax == "X  "
elseif cIdCtr == IDCTR_V
  RETURN "0  " if cIdTax == "0  "
  RETURN "6  " if cIdTax == "06 "
  RETURN "12 " if cIdTax == "12 "
  RETURN "21 " if cIdTax == "20 "
  RETURN "21 " if cIdTax == "21 "
  RETURN "15 " if cIdTax == "5  "
  RETURN "C  " if cIdTax == "VC "
  RETURN "IM " if cIdTax == "I46"
  RETURN "IS " if cIdTax == "I47"
  RETURN "X  " if cIdTax == "X  "
endif
RETURN cIdTax

FUNCTION NewIdMfc(cIdEsc)
RETURN "E  " if cIdEsc == "R  "
RETURN cIdEsc

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc

#endif CUST_HARDT

#ifdef CUST_EUROFENC

** 22.10.1998
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "0  " if cIdTax == "0  "
  RETURN "D6 " if cIdTax == "06 "  // 6%
  RETURN "D12" if cIdTax == "12 "  // 12%
  RETURN "D21" if cIdTax == "20 "  // 20.5%
  RETURN "D21" if cIdTax == "21 "  // 20.5%
  RETURN "D15" if cIdTax == "5  "
  RETURN "C  " if cIdTax == "EC "
  RETURN "N6 " if cIdTax == "N06"  // 6%  ND
  RETURN "N12" if cIdTax == "N12"  // 12% ND
  RETURN "N21" if cIdTax == "N20"  // 20.5% ND
  RETURN "N21" if cIdTax == "N21"  // 20.5% ND
  RETURN "IM " if cIdTax == "I06"
  RETURN "IM " if cIdTax == "I12"
  RETURN "IM " if cIdTax == "I20"
  RETURN "IM " if cIdTax == "I21"
  RETURN "X  " if cIdTax == "X  "
elseif cIdCtr == IDCTR_V
  RETURN "0  " if cIdTax == "0  "
  RETURN "6  " if cIdTax == "06 "
  RETURN "12 " if cIdTax == "12 "
  RETURN "21 " if cIdTax == "20 "
  RETURN "21 " if cIdTax == "21 "
  RETURN "15 " if cIdTax == "5  "
  RETURN "C  " if cIdTax == "VC "
  RETURN "IM " if cIdTax == "I46"
  RETURN "IS " if cIdTax == "I47"
  RETURN "X  " if cIdTax == "X  "
endif
RETURN cIdTax

FUNCTION NewIdMfc(cIdEsc)
RETURN "E  " if cIdEsc == "R  "
RETURN cIdEsc

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc

#endif CUST_EUROENC

FUNCTION NewVnlCode(cCode,cIdJnl)
if cCode $ " P"
  RETURN "A" if cIdJnl $ "LIB"
  RETURN "F"
endif
RETURN "R" if cCode == "L"
RETURN cCode

FUNCTION NewIdCat(c)
RETURN "W3" if c == "M "
RETURN "D3" if c == "S "
RETURN c

FUNCTION NewIdGen(c)
* RETURN "700000" if c == "700100"
* RETURN "700050" if c == "700120"
* RETURN "700030" if c == "700130"
* RETURN "700040" if c == "700140"
* RETURN "700000" if c == "705000"
* RETURN "700000" if c == "705100"
* RETURN "700000" if c == "705200"
RETURN c

*FUNCTION Michael
*local cPath := "C:\TIM210\MICHAEL"
*local cLine
*local cMatch
*local nCount
*local jnl
*RETURN .f. if ! Confirm("Nur fr Luc !",MsgSure(),MSG_NO)
*MsgDisplay("Importing FNL from FNL and ODL...")
*ddCloseAll()
*open area oFnl(), oFin(), oPar(), oGen() exclusive
*  select 0
*  use (cPath + "\FNL.DBF") alias FNL205
*  index on FNL205->IdJnl + FNL205->IdFin + FNL205->IdOp to TMP
*  nCount := 0
*  go top
*  cLine  := "*"
*  cMatch := "*"
*  do while ! eof() .and. ! TaskInter()
*    MsgDisp2("FNL " + ntrim0(100 * nCount++ / lastrec()) + "%")
*    if (jnl := JnlLocate(FNL205->IdJnl)) == NIL
*      Warning(FNL205->IdJnl + MsgJnlExist())
*    else
*      if FNL205->IdJnl + FNL205->IdFin == cMatch
*        cLine := NextId(cLine)
*      else
*        cMatch := FNL205->IdJnl + FNL205->IdFin
*        cLine := "001"
*      endif
*      select FNL
*      seek FNL205->IdJnl + NewIdDoc(FNL205->IdFin,FNL->IdJnl) + cLine
*      if eof()
*        append blank
*        FNL->IdJnl  := FNL205->IdJnl
*        FNL->IdDoc  := NewIdDoc(FNL205->IdFin,FNL->IdJnl)
*        FNL->Line   := cLine
*        FNL->Date   := FNL205->Date
*        FNL->Match  := left(FNL205->Match,3) + NewIdDoc(substr(FNL205->Match,4),left(FNL205->Match,3))
*        if "-" $ FNL205->cMont
*          FNL->DC := jnl[JNL_DC]
*          FNL->Mont := strtran(FNL205->cMont,"-"," ")
*        else
*          FNL->DC := DcInvert(jnl[JNL_DC])
*          FNL->Mont := FNL205->cMont
*        endif
*        if FNL205->CptType == "G"
*          FNL->IdCpt := FNL205->Compte
*          if trim(FNL205->Libell) != trim(GenName(FNL->IdCpt))
*            FNL->Libell := FNL205->Libell
*          endif
*        else
*          FNL->IdCtr := NewCptType(FNL205->CptType)
*          FNL->IdCpt := ParNewId(FNL->IdCtr,FNL205->Compte)
*          if trim(FNL205->Libell) != trim(ParName(FNL->IdCpt))
*            FNL->Libell := FNL205->Libell
*          endif
*        endif
*        if jnl[JNL_IDDEV] != DevDefault()
*          FNL->MontDev := FNL->Mont
*          seek FNL->IdJnl + FNL->IdDoc in FIN
*          FNL->Mont := ntom(val(FNL->Mont) * val(FIN->Cours))
*        endif
*      endif
*      select FNL205
*    endif
*    skip
*  enddo
*  use (cPath + "\ODL.DBF") alias ODL205
*  index on ODL205->IdJnl + ODL205->IdDoc to TMP
*  cLine  := "*"
*  cMatch := "*"
*  nCount := 0
*  go top
*  do while ! eof() .and. ! TaskInter()
*    MsgDisp2("ODL " + ntrim0(100 * nCount++ / lastrec()) + "%")
*    if (jnl := JnlLocate(ODL205->IdJnl)) == NIL
*      Warning(ODL205->IdJnl + MsgJnlExist())
*    else
*      if ODL205->IdJnl + ODL205->IdDoc == cMatch
*        cLine := NextId(cLine)
*      else
*        cMatch := ODL205->IdJnl + ODL205->IdDoc
*        cLine := "001"
*      endif
*      select FNL
*      seek ODL205->IdJnl + NewIdDoc(ODL205->IdDoc,ODL205->IdJnl) + cLine
*      if eof()
*        append blank
*        FNL->IdJnl  := ODL205->IdJnl
*        FNL->IdDoc  := NewIdDoc(ODL205->IdDoc,FNL->IdJnl)
*        FNL->Line   := cLine
*        // FNL->Line   := ODL205->IdOp
*        // FNL->Date   := ODL205->Date
*        FNL->Match  := left(ODL205->Match,3) + NewIdDoc(substr(ODL205->Match,4),left(ODL205->Match,3))
*        * FNL->Match  := ODL205->Match
*        * FNL->Libell := ODL205->Libell
*        if empty(ODL205->cMontD)
*          FNL->DC := DC_CREDIT
*          FNL->Mont := ODL205->cMontC
*        else
*          FNL->DC := DC_DEBIT
*          FNL->Mont := ODL205->cMontD
*        endif
*        * if "-" ODL205->cMont
*        *   FNL->DC := DcInvert(jnl[JNL_DC])
*        *   FNL->Mont := strtran(ODL205->cMont,"-"," ")
*        * else
*        *   FNL->DC := jnl[JNL_DC]
*        *   FNL->Mont := ODL205->cMont
*        * endif
*        if ODL205->CptType == "G"
*          FNL->IdCpt := ODL205->Compte
*          if trim(ODL205->Libell) != trim(GenName(FNL->IdCpt))
*            FNL->Libell := ODL205->Libell
*          endif
*        else
*          FNL->IdCtr := NewCptType(ODL205->CptType)
*          FNL->IdCpt := ParNewId(FNL->IdCtr,ODL205->Compte)
*          if trim(ODL205->Libell) != trim(ParName(FNL->IdCpt))
*            FNL->Libell := ODL205->Libell
*          endif
*        endif
*        * if jnl[JNL_IDDEV] != DevDefault()
*        *   FNL->MontDev := FNL->Mont
*        *   seek FNL->IdJnl + FNL->IdDoc in FIN
*        *   FNL->Mont := ntom(val(FNL->Mont) * val(FIN->Cours))
*        * endif
*      endif
*      select ODL205
*    endif
*    skip
*  enddo
*  use
*close area
*ddCloseAll()
*Warning("Fertig")
*RETURN MnuDone()


FUNCTION NewIdDev(cIdDev)
RETURN "BEF" if cIdDev == "FB"
RETURN "BEF" if cIdDev == "BF"
RETURN "FRF" if cIdDev == "FF"
RETURN "DEM" if cIdDev == "DM"
RETURN "ITL" if cIdDev == "LI"
RETURN "USD" if cIdDev == "US"
RETURN "NLG" if cIdDev == "HF"
RETURN "ATS" if cIdDev == "™S"
RETURN "DKK" if cIdDev == "DK"
RETURN "PTP" if cIdDev == "PT"
RETURN cIdDev


#ifdef CUST_MALM

** 31.01.2000
**
FUNCTION NewIdTax(cIdCtr,cIdTax)
if cIdCtr == IDCTR_E
  RETURN "0  " if cIdTax == "0  "
  RETURN "D6 " if cIdTax == "06 "  // 6%
  RETURN "D12" if cIdTax == "12 "  // 12%
  RETURN "D21" if cIdTax == "20 "  // 20.5%
  RETURN "D21" if cIdTax == "21 "  // 20.5%
  RETURN "D15" if cIdTax == "5  "
  RETURN "C  " if cIdTax == "EC "
  RETURN "N6 " if cIdTax == "N06"  // 6%  ND
  RETURN "N12" if cIdTax == "N12"  // 12% ND
  RETURN "N21" if cIdTax == "N20"  // 20.5% ND
  RETURN "N21" if cIdTax == "N21"  // 20.5% ND
  RETURN "IM " if cIdTax == "I06"
  RETURN "IM " if cIdTax == "I12"
  RETURN "IM " if cIdTax == "I20"
  RETURN "IM " if cIdTax == "I21"
  RETURN "X  " if cIdTax == "X  "
elseif cIdCtr == IDCTR_V
  RETURN "0  " if cIdTax == "0  "
  RETURN "6  " if cIdTax == "06 "
  RETURN "12 " if cIdTax == "12 "
  RETURN "21 " if cIdTax == "20 "
  RETURN "21 " if cIdTax == "21 "
  RETURN "15 " if cIdTax == "5  "
  RETURN "C  " if cIdTax == "VC "
  RETURN "IM " if cIdTax == "I46"
  RETURN "IS " if cIdTax == "I47"
  RETURN "X  " if cIdTax == "X  "
endif
RETURN cIdTax

FUNCTION NewIdMfc(cIdEsc)
RETURN "E  " if cIdEsc == "R  "
RETURN cIdEsc

FUNCTION NewPeriode(cPeriode)
RETURN cPeriode

FUNCTION NewIdDoc(cIdDoc,cIdJnl)
RETURN cIdDoc

#endif CUST_MALM

*#ifdef DEF_SPZ
*
*FUNCTION _idpar(cIdPar)
*RETURN cIdPar if empty(cIdPar)
*RETURN SetAbtlg()+left(cIdPar,1)+substr(cIdPar,3)
*
*FUNCTION _iddls(x)
*RETURN SetAbtlg()+strtran(substr(x,2)," ","0")
*
*
*FUNCTION p20061005()
*local blOnEach
*local cIdPar
*RETURN .f. if ! DbfZap(oPar())
*RETURN .f. if ! DbfZap(oDls())
*RETURN .f. if ! DbfZap(oDlp())
*RETURN .f. if ! DbfZap(oPlp())
*RETURN .f. if ! DbfZap(oPpr())
*ddCloseAll()
*
*** PAR
*blOnEach := {||;
*  PAR->IdPar:=_idpar(PAR->IdPar),;
*  PAR->IdPar2:=_idpar(PAR->IdPar2),;
*  PAR->Zahler:=_idpar(PAR->Zahler),;
*  PAR->Hausarzt:=_idpar(PAR->Hausarzt),;
*  PAR->Kkasse:=_idpar(PAR->Kkasse),;
*  .t.}
*SetAbtlg("E")
*MsgDisplay("Partnerstammdaten Eupen")
*RETURN .f. if ! DbfLoadFrom(oPar(),AppPath()+"\EUPEN\PAR",blOnEach)
*MsgDisplay("Partnerstammdaten St.Vith")
*SetAbtlg("S")
*RETURN .f. if ! DbfLoadFrom(oPar(),AppPath()+"\STVITH\PAR",blOnEach)
*
*blOnEach := {||;
*  DLS->IdDls:=_iddls(DLS->IdDls),;
*  DLS->IdPar:=_idpar(DLS->IdPar),;
*  .t.}
*SetAbtlg("E")
*RETURN .f. if ! DbfLoadFrom(oDls(),AppPath()+"\EUPEN\DLS",blOnEach)
*SetAbtlg("S")
*RETURN .f. if ! DbfLoadFrom(oDls(),AppPath()+"\STVITH\DLS",blOnEach)
*
*blOnEach := {||;
*  DLP->IdDls:=_iddls(DLP->IdDls),;
*  DLP->IdPar:=_idpar(DLP->IdPar),;
*  .t.}
*SetAbtlg("E")
*RETURN .f. if ! DbfLoadFrom(oDlp(),AppPath()+"\EUPEN\DLP",blOnEach)
*SetAbtlg("S")
*RETURN .f. if ! DbfLoadFrom(oDlp(),AppPath()+"\STVITH\DLP",blOnEach)
*
*blOnEach := {||;
*  FIELD->IdPar1:=_idpar(FIELD->IdPar1),;
*  FIELD->IdPar2:=_idpar(FIELD->IdPar2),;
*  .t.}
*SetAbtlg("E")
*RETURN .f. if ! DbfLoadFrom(oPlp(),AppPath()+"\EUPEN\PLP",blOnEach)
*SetAbtlg("S")
*RETURN .f. if ! DbfLoadFrom(oPlp(),AppPath()+"\STVITH\PLP",blOnEach)
*
*blOnEach := {||;
*  FIELD->IdPar:=_idpar(FIELD->IdPar),;
*  .t.}
*SetAbtlg("E")
*RETURN .f. if ! DbfLoadFrom(oPpr(),AppPath()+"\EUPEN\PPR",blOnEach)
*SetAbtlg("S")
*RETURN .f. if ! DbfLoadFrom(oPpr(),AppPath()+"\STVITH\PPR",blOnEach)
*RETURN .t.
*
*#endif DEF_SPZ

FUNCTION DbfLoadFrom(ad,cFile,blOnEach,blFilter)
local lOkay := .t.
local nCount := 0
local a
local nSelect
default blFilter to {||.t.}
MsgDisplay(cFile)
open area ad
  nSelect := select()
  select 0
  use (cFile) alias IMPORT
  go top
  do while ! eof() .and. lOkay
    if TaskInter() ; exit ; endif
    MsgDisp2(ntrim0(100*nCount++/lastrec()) + "%")
    if eval(blFilter)
      a := CopyRec()
      select (nSelect)
      if dbAddRec()
        PasteRec(a)
        if ! eval(blOnEach)
          lOkay := .f.
        endif
        unlock record
      else
        lOkay := .f.
      endif
      select IMPORT
    endif
    skip
  enddo
  use
  select (nSelect)
  dbcommit()
close area
RETURN lOkay

