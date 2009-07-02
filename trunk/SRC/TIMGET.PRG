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

#ifdef LG_FRENCH
  #define MSG001  "Chiffre d'affaires"
  #define MSG002  " : Nouveau Solde devrait ˆtre "
  #define MSG003  "Tapez O pour remplacer : "
  #define MSG005  "Instructions d'imputation : Cat‚gorie "
  #define MSG006  "Instructions d'imputation : Code TVA "
  #define MSG007  "Modules dans "
  #define MSG008  "Pr‚sences au "
  #define MSG009  "Pr‚sences"
  #define MSG010  " : commandes en cours"
  * #define MSG011  "Montant total base : incorrect."
  * #define MSG012  "Montant total T.V.A. : incorrect."
  #define MSG013  "Ventes "
  #define MSG014  "Achats "
  * #define MSG015  " du fournisseur "
  #define MSG016  "Fournisseur "
  #define MSG017  "P‚riode du"
  #define MSG018  " au"
  #define MSG019  "Montant HTVA des factures .............."
  #define MSG020  "Montant HTVA des notes de cr‚dit ......."
  #define MSG021  "Chiffre d'affaires ....................."
  #define MSG022  "                (Touche quelconque pour continuer)"
  #ifdef DEF_ANA
  static MSG023  := " : imputations analytiques"
  #endif
  #define MSG024  "Rendez-vous avec le client "
  #define MSG025  " : pr‚sences"
  #define MSG026  "Rendez-vous au tarif "
  #define MSG027  "Clients avec code profession "
  #define MSG028  "Clients de "
  #define MSG029  "Message "
  #define MSG030  "Correspondance "
  #define MSG031  "Articles du groupe "
  static MSG032 := "Historique "
  #define MSG033  "Paiements "
  #define MSG034  "Paiements sur le compte "
  #define MSG035  "Imputations "
  #define MSG036  "S‚lectionn‚ pour (d‚)lettrage : DB "
  #define MSG037  "Corriger montants totaux (O/N) ?"
  #define MSG038  "Diff‚rence : "
  #define MSG039  "Op‚rations diverses avec Match "
  static MSG040 := "Texte m‚mo "
  #define MSG041  "Articles par fournisseur : "
  * #define MSG042  "Texte du masque "
  static MSG043 := " : contenu non valide !"
#endif
#ifdef LG_GERMAN
  #define MSG002  " : Neuer Saldo sollte sein "
  #define MSG003  "J, um diesen Wert einzutragen : "
  #define MSG008  "Anwesenheiten : Woche vom "
  #ifdef DEF_ANA
  static MSG023  := " : analytische Buchungen"
  #endif
  #define MSG024  "Termine mit "
  #define MSG025  " : Anwesenheiten"
  #define MSG028  "Partner aus "
  #define MSG029  "Nachricht "
  #define MSG030  "Korrespondenz "
  #define MSG031  "Artikel der Gruppe "
  static MSG032 := "Historik "
  #define MSG035  "Buchungen "
  #define MSG038  "Differenz : "
  static MSG040 := "Memo-Text "
#endif
#ifdef LG_EN
  #define MSG002  " : new balance should be "
  #define MSG003  "Y, to accept this value : "
  #define MSG008  "Anwesenheiten : Woche vom "
  #ifdef DEF_ANA
  static MSG023  := " : analytic bookings"
  #endif
  #define MSG024  "Meetings with "
  #define MSG025  " : Anwesenheiten"
  #define MSG028  "Partners from "
  #define MSG029  "Message "
  #define MSG030  "Message "
  #define MSG031  "Products of group "
  static MSG032 := "History "
  #define MSG035  "History by document "
  #define MSG038  "difference : "
  static MSG040 := "Memo Text "
#endif


static snMontD := 0
static snMontC := 0
static snMode  := 0 // 0 = aucun, 1 = lettrage, 2 == d‚lettrage
* static scCptType := CPTTYPE_CLI
static scCompte := NIL
static scMemoLang := NIL

#ifdef DEF_JNL

FUNCTION JnlWait(wwin)
local b := oPer()
local cIdJnl := JNL->IdJnl
RETURN NIL if nextkey() != 0
RETURN NIL

#endif DEF_JNL


#ifdef DEF_PRESTO

**
** ParTrmEdit() - Rendez-vous avec un particulier
**
FUNCTION ParTrmEdit(cIdPar)
local b := oTrm()
open area b, oPar(), oTac(), oPrj()
  ddSetOrder(ORD_TRM_PAR)
  edit data b key TRM->IdPar value cIdPar ;
    create   {||TrmCreate(cIdPar,NIL)} ;
    mode find ;
    start bottom ;
    title (MSG024 + trim(ParName(cIdPar))) ;
    query "TRMPAR"
close area
RETURN .f.


**
** TacTrmEdit()
**
FUNCTION TacTrmEdit(cIdTac)
local b := oTrm()
open area b, oPar(), oTac(), oPrj()
  ddSetOrder(ORD_TRM_TACDATE)
  edit data b key TRM->IdTac value cIdTac ;
    create    {||DDCREATE_FAIL} ;
    mode find    ;
    start top ;
    query     "TRMTAC" ;
    title (trim(TAC->Name1) + " : Termine")
close area
RETURN MnuDone()

#endif DEF_PRESTO

#ifdef DEF_PSC

**
** ParPscEdit() - personnes de contact d'un partenaire
**
FUNCTION Par1PscEdit()
local b := oPsc()
local cIdPar := PAR->IdPar
open area b, oPar()
  edit data b key PSC->IdPar value cIdPar ;
    create   {||PscCreate(cIdPar)} ;
    mode edit ;
    start top ;
    query "PSCPAR1" ;
    title ( trim(ParName()) + " : Kontaktpersonen")
close area
RETURN MnuDone()

**
** ParPscEdit() - personnes de contact d'un partenaire
**
FUNCTION Par2PscEdit()
local b := oPsc()
local cIdPar := PAR->IdPar
open area b, oPar()
  ddSetOrder(ORD_PSC_PAR2)
  edit data b key PSC->IdPar2 value cIdPar ;
    create   {||PscCreate(NIL,cIdPar)} ;
    mode edit ;
    start top ;
    query "PSCPAR2" ;
    title ( trim(ParName()) + " ist Kontaktperson fr...")
close area
RETURN MnuDone()

FUNCTION ParPscExist(cIdPar2)
local lOkay := .f.
local cIdPar := PAR->IdPar
local b := oPsc()
open area b, oPar()
  softseek cIdPar
  do while ! eof() .and. PSC->IdPar1 == cIdPar
    if PSC->IdPar2 == cIdPar2
      lOkay := .t.
      exit
    endif
    skip
  enddo
close area
RETURN lOkay

#endif DEF_PSC


**
** PlzGetPar()
**
FUNCTION PlzGetPar
local b := oPar()
local cId := PLZ->Pays + PLZ->CP
*open window (MSG028 + trim(PLZ->CP) + " " + trim(PLZ->Nom)) ;
*            color (CfgBrowseColor())
open area b, oPlz(), oNat(), oClb()
  ddSetOrder(ORD_PAR_PLZ)
  edit data b key PAR->Pays + PAR->CP value cId ;
    create    {||DDCREATE_FAIL}       ;
    mode      find                ;
    query "PARPLZ" ;
    start top ;
    title (MSG028 + trim(PLZ->CP) + " " + trim(PLZ->Nom))
close area
* close window
RETURN .f.


#ifdef DEF_MSG

**
** MsgMemoEdit()
**
FUNCTION MsgMemoEdit()
local nWidth := min(76,TplValue(TPLTYPE_MSG,MSG->IdTxt,{||val(TPL->Width)},76))
RETURN MnuDone() if ! ddRecLock()
open window (MSG029 + trim(MSG->Titre) ) size 20, 80
TxtEdit( ;
  fieldblock("Texte"), ;
  WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
  ddOnPreEdit(oMsg()), nWidth ;
)
close window
unlock record
if lastkey() == K_F10
  if ! empty(MSG->IdTxt)
    MsgPrint()
  endif
endif
RETURN .f.

#endif DEF_MSG

#ifdef DEF_MEMO

**
** ParMemoEdit()
**
FUNCTION ParMemoEdit()
return MnuDone() if ! ddRecLock()
open window (MSG040 + trim(ParName())) size 20, 80
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oPar()), 76 ;
  )
close window
unlock record
RETURN .f.

#ifdef DEF_IMP

**
** BudMemoEdit()
**
FUNCTION BudMemoEdit()
return MnuDone() if ! ddRecLock()
open window (MSG040 + BUD->DC + " " + trim(SayIdBud(BUD->IdBud))) size 20, 80
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ddOnPreEdit(oBud()), 76 ;
  )
close window
unlock record
RETURN .f.

#endif DEF_IMP

#ifdef DEF_GEN

**
** GenMemoEdit()
**
FUNCTION GenMemoEdit(cTitle)
return MnuDone() if !ddRecLock()
open window (MSG040 + cTitle) size 20,80
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oGen()), 76 ;
  )
close window
unlock record
RETURN .f.

#endif DEF_GEN

#ifdef DEF_VEN

**
** VenGetMemo()
**
FUNCTION VenGetMemo(lLock)
if lLock
  RETURN MnuDone() if ! ddRecLock()
endif
open window (MSG040 + VEN->IdJnl + " " + VEN->IdDoc) size 20, 80
  SetTplLang(PAR->Langue)
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oVen()), ;
    VenTplWidth() ;
  )
close window
if lLock
  unlock record
else
  ddRefreshCurrent()
endif
RETURN .f.

**
** VnlGetMemo()
**
FUNCTION VnlGetMemo(cTitle,nHeight,nWidth,nTop,nLeft,nVnlWidth)
if TIMATTR_M $ MemAttrib
  select VEN
  VenGetMemo(.f.)
  select VNL
  RETURN MnuDone()
endif
if eof() // 20070801 recno() == lastrec() + 1
  RETURN MnuDone() if ! ddCreate()
endif
RETURN MnuDone() if ! ddRecLock()
default cTitle to MSG040 + FIELD->IdJnl + " " + FIELD->IdDoc + ":" + FIELD->Line
default nHeight to 20
default nWidth to 80
default nVnlWidth to VenTplWidth()
open window (cTitle ) ;
            size nHeight, nWidth home nTop, nLeft
  SetTplLang(PAR->Langue)
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oVnl()), ;
    nVnlWidth ;
  )
close window
if empty(VNL->IdArt)
  FIELD->IdArt := "*"
endif
ddRefreshCurrent()
unlock record
RETURN MnuDone()

#endif DEF_VEN

#endif DEF_MEMO

#ifdef DEF_PRESTO

**
** TrmMemoEdit()
**
FUNCTION TrmMemoEdit()
local nWidth := TplValue(TPLTYPE_TRM,"STD",{||val(TPL->Width)},76)
return MnuDone() if ! ddRecLock()
open window ( trim1(TRM->Texte) + dtoc(TRM->Date) + " " + TRM->Debut + "-" + TRM->Fin) ;
     size 20,80
TxtEdit( ;
  fieldblock("MemoTxt"), WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
  ddOnPreEdit(oTrm()), nWidth ;
)
unlock record
* if lastkey() == K_F10
*   TrmChgEtat()
* endif
close window
RETURN .f.

#endif DEF_PRESTO

* #ifdef DEF_PIN

* #endif DEF_PIN

#ifdef DEF_PRJ

**
** PrjMemoEdit()
**
FUNCTION PrjMemoEdit()
return MnuDone() if ! ddRecLock()
open window size 20,80
TxtEdit( ;
  fieldblock("Text"), WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
  ddOnPreEdit(oPrj()), 76 ;
)
close window
unlock record
RETURN .f.

#endif DEF_PRJ

#ifdef DEF_MSG

**
** ParMsgEdit()
**
FUNCTION ParMsgEdit(cIdCpt)
local b := oMsg()
SetTplLang(PAR->Langue)
open area b, oPar()
  ddSetOrder(ORD_MSG_PAR)
  edit data b ;
    key   MSG->IdPar ;
    value cIdCpt         ;
    create   {||MsgCreate(cIdCpt)} ;
    mode     find   ;
    start    bottom ;
    query "MSGPAR" ;
    title (MSG030 + ParName())
close area
RETURN MnuDone()

#ifdef DEF_PRJ

**
** PrjMsgEdit()
**
FUNCTION PrjMsgEdit(cIdPrj)
local b := oMsg()
open area b, oPar()
  ddSetOrder(ORD_MSG_PRJ)
  edit data b ;
    key   MSG->IdPrj ;
    value cIdPrj         ;
    create   {||MsgCreate(NIL,NIL,cIdPrj)} ;
    mode     find   ;
    start    bottom ;
    query "MSGPRJ" ;
    title (MSG030 + cIdPrj + " " + PrjName())
close area
RETURN MnuDone()

#endif DEF_PRJ

#endif DEF_MSG

#ifdef DEF_FIN

**
** FinFnlEdit()
**
FUNCTION FinFnlEdit()
local b := oFnl()
local cIdJnl := FIN->IdJnl
local cIdFin := FIN->IdDoc
local jnl := JnlLocate(FIN->IdJnl)
local a := FnlSave()
local cIdQry
RETURN NIL if jnl == NIL
RETURN .f. if ! ddRecLock()
if trim(jnl[JNL_IDDBV]) $ "DB,DEV"
  cIdQry := "FNL" + if(FIN->IdDev == DevDefault(FIN->Periode),"DB","DEV")
else
  cIdQry := ("FNL" + jnl[JNL_IDDBV])
endif
open area b, oPar(), oGen(), oAna()
  if (a := FinFnlInit(jnl)) == NIL
    Warning(MsgIdJnlDoc() + " : " + SetMsg())
  else
    softseek FIN->IdJnl + FIN->IdDoc
    do while ! eof() .and. FNL->IdJnl == FIN->IdJnl ;
                     .and. FNL->IdDoc == FIN->IdDoc
      FnlAfter()
      skip
    enddo
    edit data b key FNL->IdJnl + FNL->IdDoc ;
                value cIdJnl + cIdFin ;
                create    {||FnlCreate(cIdJnl,cIdFin)} ;
                preedit   FinPreEdit() ;
                before    FnlBefore() ;
                after     FnlAfter() ;
                mode edit ;
                start top ;
                query (cIdQry) ;
                title (MsgInhalt() + FIN->IdJnl + " " + FIN->IdDoc)
    if ddLastKey() == K_F10
      if FIN->Etat != DocStatClosed()
        FinFnlUpdate(jnl)
      endif
    elseif FIN->Etat != DocStatClosed()
      ddEditChange(.t.)
    endif
    FnlRestore(a)
  endif
close area
unlock record
FnlRestore(a)
ddRefreshCurrent()
if ddLastKey() == K_F10 .and. FIN->Etat == DocStatOpen()
  FinDlgClose()
  if JNLATTR_I $ jnl[JNL_ATTRIB] .and. FIN->Etat == DocStatClosed()
    FinPrint()
  endif
endif
RETURN .f.

**
** FinFnlUpdate()
**
FUNCTION FinFnlUpdate(jnl)
local nMont
local nMontDev
local nDecPos := DevDecPos(FIN->IdDev)
local cDiff
local cPeriode := FIN->Periode
if JNLATTR_P $ jnl[JNL_ATTRIB]
  open area oFnl()
    softseek FIN->IdJnl+FIN->IdDoc
    do while !eof() .and. FNL->IdDoc == FIN->IdDoc ;
                    .and. FNL->IdJnl == FIN->IdJnl
      if cPeriode > PerActive(FnlFinDate())
        cPeriode := PerActive(FnlFinDate())
      endif
      skip
    enddo
  close area
  FIN->Periode := cPeriode
endif
if JNLATTR_S $ jnl[JNL_ATTRIB]
  nMont := FinSolde2()
  if empty(FIN->Mont2)
    FIN->Mont2 := ntom(nMont,nDecPos)
  endif
  if ntom(nMont,nDecPos) == FIN->Mont2
    FIN->Etat := DocStatOpen()
  else
    cDiff := ntrim(nMont - val(FIN->Mont2))
    if Confirm( ;
      FIN->IdJnl + FIN->IdDoc + MSG002 + ;
      ntrim(nMont) + " (" + MSG038 + FIN->IdDev + ;
      " " + cDiff + ")", ;
      MSG003 ;
    )
      FIN->Mont2 := ntom(nMont,nDecPos)
      FIN->Etat := DocStatOpen()
    else
      FIN->Etat := DocStatNew()
    endif
  endif
elseif empty(jnl[JNL_IDGEN])
  if FIN->IdDev == DevDefault(FIN->Periode)
    if abs(nMont := FinSolde2()) < DevTolerance(FIN->IdDev)
      FIN->Etat := DocStatOpen()
    else
      Warning(MsgBleibt() + " : " + FIN->IdDev + " " + ntrim(nMont))
      FIN->Etat := DocStatNew()
    endif
  else
    nMont := FnlMont()
    if abs(nMont) < DevTolerance(DevDefault(FIN->Periode))
      nMontDev := FnlMontDev()
      if abs(nMontDev) < DevTolerance(FIN->IdDev)
        FIN->Etat := DocStatOpen()
      else
        Warning(MsgBleibt() + " : " + FIN->IdDev + " " + ntrim(nMontDev))
        FIN->Etat := DocStatNew()
      endif
    else
      Warning(MsgBleibt() + " : " + ;
              DevDefault(FIN->Periode) + " " + ntrim(nMont))
      FIN->Etat := DocStatNew()
    endif
  endif
elseif JNLATTR_T $ jnl[JNL_ATTRIB]
  nMont := FinSolde2()
  FIN->Mont2 := ntom(nMont,nDecPos)
  FIN->Etat := DocStatOpen()
else
  FIN->Etat := DocStatOpen()
endif
RETURN NIL


**
** FinWait()
**
FUNCTION FinWait(wwin)
local b := oFnl()
local jnl := JnlLocate(FIN->IdJnl)
local a
local cIdQry
RETURN ClearWaitWin(wwin) if jnl == NIL
if trim(jnl[JNL_IDDBV]) $ "DB,DEV"
  cIdQry := "FNL" + if(FIN->IdDev == DevDefault(FIN->Periode),"DB","DEV")
else
  cIdQry := ("FNL" + jnl[JNL_IDDBV])
endif
open area b, oPar(), oVen(), oGen(), oAna() // wie FinFnlEdit()
  if nextkey() == 0
    if (a := FinFnlInit(jnl)) != NIL
      softseek FIN->IdJnl + FIN->IdDoc
      do while ! eof() .and. FNL->IdJnl == FIN->IdJnl ;
                       .and. FNL->IdDoc == FIN->IdDoc
        FnlAfter()
        skip
      enddo
      edit data b key   FNL->IdJnl + FNL->IdDoc ;
                  value FIN->IdJnl + FIN->IdDoc ;
                  mode  wait ;
                  window wwin ;
                  start top ;
                  query (cIdQry) // "FNL" + jnl[JNL_IDDBV]
      FnlRestore(a)
    endif
  endif
close area
RETURN NIL

#endif DEF_FIN

#ifdef DEF_HST

**
** DocHstEdit() - Imputations d'un document ventes ou achats
**
FUNCTION DocHstEdit( cIdJnl, cIdDoc )
local b := oHst()
open area b, oGen(), oPar()
ddSetOrder(ORD_HST_DOC)
edit data b key HST->IdJnl+HST->IdDoc              ;
            value cIdJnl+cIdDoc                      ;
            start    bottom                          ;
            mode     find                            ;
            query    "HSTDOC" ;
            title (MSG035 + cIdJnl + " " + cIdDoc )
close area
RETURN MnuDone()


FUNCTION CptHstEdit(cCptType,cCompte)
if empty(cCptType) // == CPTTYPE_GEN
  RETURN .f. if ! GenExist(cCompte)
  RETURN GenHstEdit(left(cCompte,LenIdGen()))
endif
RETURN .f. if ! ParExist(cCompte)
RETURN ParHstEdit(left(cCompte,LenIdPar()))

**
** GenHstEdit() - Mouvements d'un compte g‚n‚ral
**
FUNCTION GenHstEdit( cIdGen )
local b := oHst()
local bFilter
open area b, oPar(), oGen(), oVen(), oFin()
  if GenExist(cIdGen)
    if GENATTR_C $ GEN->Attrib .and. ! USRATTR_C $ UsrAttrib()
      Warning(MsgNoAccess())
    else
      if GENATTR_L $ GEN->Attrib
        bFilter := "empty(HST->Satis)"
      else
        bFilter := ".t."
      endif
      ddSetOrder(ORD_HST_GENDATE)
      edit data b key HST->IdGen ;
                  value    cIdGen      ;
                  start    bottom                          ;
                  mode     find                            ;
                  query    "HSTGEND" ;
                  filter   bFilter ;
                  title (MSG032 + cIdGen + " " + trim(GenName()))
    endif
  endif
close area
RETURN .f.


**
** ParHstEdit() - Mouvements d'un compte particulier
**
FUNCTION ParHstEdit(cIdPar)
local b := oHst()
local bFilter := "empty(HST->Satis)"
open area b, oPar(), oGen(), oVen(), oFin()
  ddSetOrder(ORD_HST_PARDATE)
  edit data b key    HST->IdPar ;
              value  cIdPar     ;
              start  bottom     ;
              mode   find       ;
              query  "HSTPARD"   ;
              filter bFilter ;
              title  (MSG032 + ParName(cIdPar))
close area
RETURN .f.

**
**
FUNCTION PickHstPar(cIdPar,cStart,bReturn,xlFilter,cIdCtr)
local b := oHst()
local cReturn := NIL
* default bReturn to {||HST->IdJnl+HST->IdDoc}
default bReturn to {||HST->Match}
if cIdCtr == NIL .or. CtrLocate(cIdCtr)==NIL
  default xlFilter to "empty(HST->Satis)"
else
  default xlFilter to "empty(HST->Satis).and.HST->IdCtr=='"+cIdCtr+"'"
endif
b := oHst()
open area b, oFin(), oFnl(), oVen()
  ddSetOrder(ORD_HST_DOC)
  if empty(cIdPar)
    if JnlLocate(left(cStart,LenIdJnl())) != NIL
      softseek trim(cStart)
      edit data b mode     pick                    ;
                  query    "HSTPICK"               ;
                  title    (MSG032 + cStart)                   ;
                  filter   (xlFilter)  ;
                  key      HST->IdJnl              ;
                  value    left(cStart,LenIdJnl())
    else
      edit data b mode     pick ;
                  query    "HSTPICK"    ;
                  title    (MSG032) ;
                  filter   (xlFilter)  ;
                  start    bottom
    endif
  else
    softseek trim(cStart)
    ddSetOrder(ORD_HST_PARDATE)
    edit data b key HST->IdPar  ;
                value cIdPar  ;
                mode     pick ;
                query    "HSTPARD" ;
                filter   (xlFilter)  ;
                title (MSG032 + ParName(cIdPar))
  endif
  if ddLastReq() == DDEDIT_SELECT
    cReturn := eval(bReturn)
  endif
close area
RETURN cReturn

**
** PickHstGen()
**
FUNCTION PickHstGen(cIdGen,cStart,bReturn,xlFilter)
local b := oHst()
local cReturn := NIL
default bReturn to {||HST->IdJnl+HST->IdDoc}
default xlFilter to "empty(HST->Satis)"
b := oHst()
open area b, oFin(), oFnl(), oVen(), oPar()
  ddSetOrder(ORD_HST_DOC)
  if empty(cIdGen)
    if JnlLocate(left(cStart,LenIdJnl())) != NIL
      softseek trim(cStart)
      edit data b mode     pick                    ;
                  query    "HSTPICK"               ;
                  title    (MSG032 + cStart)                   ;
                  filter   (xlFilter)  ;
                  key      HST->IdJnl              ;
                  value    left(cStart,LenIdJnl())
    else
      edit data b mode     pick ;
                  query    "HSTPICK"    ;
                  title    (MSG032) ;
                  filter   (xlFilter)  ;
                  start    bottom
    endif
  else
    softseek trim(cStart)
    ddSetOrder(ORD_HST_GENDATE)
    edit data b key HST->IdGen  ;
                value cIdGen  ;
                mode     pick ;
                query    "HSTGEND" ;
                filter   (xlFilter)  ;
                title (MSG032 + cIdGen + " "+GenName(cIdGen))
  endif
  if ddLastReq() == DDEDIT_SELECT
    cReturn := eval(bReturn)
  endif
close area
RETURN cReturn

#endif DEF_HST



#ifdef DEF_IMP

* FUNCTION ParMvpEdit(cIdPar)
* RETURN ParMviEdit(cIdPar)

**
** BudWait() - Mouvements d'un compte particulier
**
FUNCTION BudWait(wwin)
local b
local cIdCtr := BUD->DC
local cIdBud := BUD->IdBud
if wwin[WIN_WAITKEY] == 9 // if snBudWaitKey == K_SH_F9
  b := oMvi()
  open area b, oBud(), oPar()
    ddSetOrder(ORD_MVI_BUDDATE)
    edit data b key MVI->DC+MVI->IdBud ;
                value   cIdCtr+cIdBud     ;
                start bottom ;
                mode     wait                            ;
                window wwin ;
                query    "MVIBUD" ;
                title (MSG032 + cIdCtr + "-" + SayIdBud(cIdBud))
  close area
elseif wwin[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
elseif wwin[WIN_WAITKEY] == 3
  b := oCtb()
  open area b, oBud()
    edit data b key      CTB->DC+CTB->IdBud ;
                value    cIdCtr+cIdBud     ;
                start    bottom ;
                mode     wait                            ;
                window   wwin ;
                query    ("CTBBUD")
  close area
elseif wwin[WIN_WAITKEY] == 12
  MemoDisplay(BUD->Memo, ;
     wwin[WIN_TOP], ;
     wwin[WIN_LEFT], ;
     wwin[WIN_HEIGHT], ;
     wwin[WIN_WIDTH] ;
  )
endif
RETURN NIL

#endif DEF_IMP


#ifdef DEF_ANA
#ifdef DEF_TAX

FUNCTION VnlTaxAna()
local cIdCtr
local tax
RETURN .t. if TIMATTR_C $ MemAttrib
tax := TaxLocate(JnlIdCtr(VNL->IdJnl),VNL->IdTax)
RETURN .f. if tax == NIL
RETURN .t. if empty(tax[TAX_IDGEN])
RETURN .f.

#endif DEF_TAX
#endif DEF_ANA


#ifdef DEF_MVA

**
** AnaMvaEdit()
**
FUNCTION AnaMvaEdit(cIdAna)
local b := oMva()
MvaInit()
open area b, oAna(), oGen(), oPar()
  ddSetOrder(ORD_MVA_CPTDATE)
  edit data b key MVA->IdAna ;
              value    cIdAna      ;
              start    bottom                          ;
              mode     show                            ;
              query    "MVAANA" ;
              title (MSG032 + cIdAna + " " + trim(AnaName(cIdAna)))
close area
RETURN .f.


**
** GenMvaEdit()
**
FUNCTION GenMvaEdit(cIdGen)
local b := oMva()
MvaInit()
open area b, oAna(), oGen(), oPar()
  ddSetOrder(ORD_MVA_GEN)
  edit data b key MVA->IdGen ;
              value    cIdGen      ;
              start    bottom                          ;
              mode     show                            ;
              query    "MVAGEN" ;
              title (MSG032 + trim(GenName(cIdGen)))
close area
RETURN .f.

#ifdef DEF_IMP

**
** BudMvaEdit()
**
FUNCTION BudMvaEdit(cDC,cIdBud)
local b := oMva()
MvaInit()
open area b, oAna(), oGen(), oBud(), oPar()
  ddSetOrder(ORD_MVA_GEN)
  edit data b key MVA->DC+MVA->IdBud ;
              value    cDC+cIdBud      ;
              start    bottom                          ;
              mode     show                            ;
              query    "MVABUD" ;
              title (MSG032 + trim(BudName(cDC,cIdBud)))
close area
RETURN .f.

#endif DEF_IMP



#ifdef DEF_VEN

* **
* ** VnlMvaEdit()
* **
* FUNCTION VnlMvaEdit()
* local b := oMva()
* local nMode := DDMODE_SHOW
* local cIdJnl := VEN->IdJnl
* local cIdDoc := VEN->IdDoc
* local cLine  := FIELD->Line
* local cIdGen := left(FIELD->IdArt,LenIdGen())
* * local cIdGen := GEN->IdGen
* local nMont
* RETURN VenMvaEdit() if FIELD->Code != LNCODE_GEN
* if VEN->IdJnl + VEN->IdDoc != cIdJnl + cIdDoc
*   seek cIdJnl + cIdDoc in VEN
* endif
* if VEN->Etat != DocStatClosed() // .or. USRATTR_S $ UsrAttrib()
*   nMode := DDMODE_EDIT
* endif
* RETURN .f. if ! GenExist(cIdGen)
* if ! GENATTR_Y $ GEN->Attrib
*   RETURN !SetMsg(cIdGen + " : Generalkonto wird nicht analytisch verteilt !")
* endif
* nMont := VenDev2Db(val(FIELD->cMont))
* #ifdef DEF_TAX
*   if VnlTaxAna()
*     nMont += VenDev2Db(val(FIELD->MontT))
*   endif
* #endif
* MvaInit(cIdJnl,cIdDoc,FIELD->Line,VEN->DC,nMont,VEN->Periode)
* open area b, oAna(), oGen()
*   ddSetOrder(ORD_MVA_DOC)
*   edit data b key      MVA->IdJnl + MVA->IdDoc + MVA->Line ;
*               value    cIdJnl + cIdDoc + cLine     ;
*               start    top                  ;
*               create   {|| MvaCreate( ;
*                 cIdJnl,cIdDoc,cIdGen,cLine, ;
*                 VEN->Date, VEN->Periode ;
*               )} ;
*               before   MvaBefore() ;
*               after    MvaAfter() ;
*               mode     nMode                           ;
*               query    "MVAVNL" ;
*               title    (cIdJnl + " " + cIdDoc + " " + cLine + MSG023)
* close area
* RETURN .f.


**
** VenMvaEdit()
**
FUNCTION VenMvaEdit()
local b := oMva()
local nMode := DDMODE_SHOW
local cIdJnl := VEN->IdJnl
local cLine
local cIdGen
local cIdDoc := VEN->IdDoc
local nMont := 0
local nMontT := 0
if VEN->Etat != DocStatClosed() // .or. USRATTR_S $ UsrAttrib()
  nMode := DDMODE_EDIT
endif
open area oVnl(VEN->Etat),oGen()
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdJnl == VEN->IdJnl ;
                   .and. FIELD->IdDoc == VEN->IdDoc
    if FIELD->Code == LNCODE_GEN
      cIdGen := left(FIELD->IdArt,LenIdGen())
      cLine  := FIELD->Line
      if GenExist(cIdGen) .and. GENATTR_Y $ GEN->Attrib
        nMont += VenDev2Db(val(FIELD->cMont))
        #ifdef DEF_TAX
          if VnlTaxAna()
            nMont += VenDev2Db(val(FIELD->MontT))
          endif
        #endif
      endif
    endif
    skip
  enddo
close area
MvaInit(cIdJnl,cIdDoc,NIL,VEN->DC,nMont,VEN->Periode)
open area b, oAna(), oGen()
  ddSetOrder(ORD_MVA_DOC)
  edit data b key      MVA->IdJnl + MVA->IdDoc ;
              value    cIdJnl + cIdDoc    ;
              start    top                  ;
              create   {|| MvaCreate( ;
                cIdJnl,cIdDoc,cIdGen,cLine, ;
                VEN->Date, VEN->Periode ;
              )} ;
              before   MvaBefore() ;
              after    MvaAfter() ;
              mode     nMode                           ;
              query    "MVAVEN" ;
              title    (cIdJnl + " " + cIdDoc + " " + MSG023)
close area
RETURN .f.

#endif DEF_VEN


#ifdef DEF_IMP

**
** ImlMvaEdit()
**
FUNCTION ImlMvaEdit()
local b := oMva()
local nMode := DDMODE_SHOW
local cIdJnl := IMP->IdJnl
local cIdDoc := IMP->IdDoc
local cLine  := FIELD->Line
local cDC    := IML->DC
local cIdBud := IML->IdBud
local nMont
// RETURN ImpMvaEdit() if FIELD->Code != LNCODE_GEN
if ! JNLATTR_Y $ JnlAttrib(cIdJnl)
  RETURN !SetMsg(cIdJnl + " : Journal wird nicht analytisch verteilt !")
endif
if IMP->IdJnl + IMP->IdDoc != cIdJnl + cIdDoc
  seek cIdJnl + cIdDoc in IMP
endif
if IMP->Etat != DocStatClosed()
  nMode := DDMODE_EDIT
endif
RETURN .f. if ! BudExist(IML->DC,IML->IdBud)
* cIdGen := BUD->IdGen
* RETURN .f. if ! GenExist(cIdGen)
if ! BUDATTR_Y $ BUD->Attrib
  RETURN !SetMsg(trim(SayIdBud(cIdBud)) + " : Artikel wird nicht analytisch verteilt !")
endif
nMont := val(IML->Mont) // *ImpCours()
MvaInit(cIdJnl,cIdDoc,IML->Line,IML->DC,nMont,IMP->Periode)
open area b, oAna(), oGen()
  ddSetOrder(ORD_MVA_DOC)
  edit data b key      MVA->IdJnl + MVA->IdDoc + MVA->Line ;
              value    cIdJnl + cIdDoc + cLine     ;
              start    top                  ;
              create   {|| MvaCreate( ;
                cIdJnl,cIdDoc,cIdBud,cLine, ;
                IMP->Date1, IMP->Periode, cDC ;
              )} ;
              before   MvaBefore() ;
              after    MvaAfter() ;
              mode     nMode                           ;
              query    "MVAIML" ;
              title    (cIdJnl + " " + cIdDoc + " " + cLine + MSG023)
close area
RETURN .f.

**
** ImpMvaEdit()
**
*FUNCTION ImpMvaEdit()
*local b := oMva()
*local nMode := DDMODE_SHOW
*local cIdJnl := IMP->IdJnl
*local cLine
*local cIdBud
*local cIdDoc := IMP->IdDoc
*local nMont := 0
*if ! JNLATTR_Y $ JnlAttrib(cIdJnl)
*  RETURN !SetMsg(cIdJnl + " : Journal wird nicht analytisch verteilt !")
*endif
*if IMP->Etat != DocStatClosed() // .or. USRATTR_S $ UsrAttrib()
*  nMode := DDMODE_EDIT
*endif
*open area oIml(), oBud(), oGen()
*  softseek IMP->IdJnl + IMP->IdDoc
*  do while ! eof() .and. FIELD->IdJnl == IMP->IdJnl ;
*                   .and. FIELD->IdDoc == IMP->IdDoc
*    cLine  := IML->Line
*    if BudExist(IML->DC,IML->IdBud) .and. BUDATTR_Y $ BUD->Attrib
*      nMont += val(FIELD->Mont)
*    endif
*    skip
*  enddo
*close area
*MvaInit(cIdJnl,cIdDoc,NIL,JnlDC(cIdJnl),ImpDev2Db(nMont))
*open area b, oAna(), oGen()
*  ddSetOrder(ORD_MVA_DOC)
*  edit data b key      MVA->IdJnl + MVA->IdDoc ;
*              value    cIdJnl + cIdDoc    ;
*              start    top                  ;
*              create   {|| MvaCreate( ;
*                cIdJnl,cIdDoc,cIdBud,cLine, ;
*                IMP->Date1, IMP->Periode ;
*              )} ;
*              before   MvaBefore() ;
*              after    MvaAfter() ;
*              mode     nMode                           ;
*              query    "MVAIMP" ;
*              title    (cIdJnl + " " + cIdDoc + " " + MSG023)
*close area
*RETURN .f.

FUNCTION ImpCours
if val(IMP->Cours) == 0
  Warning("val(IMP->Cours) == 0 !")
  RETURN 1
endif
RETURN val(IMP->Cours)

#endif DEF_IMP

**
** OdaMvaEdit()
**
FUNCTION OdaMvaEdit() // cIdJnl,cIdDoc,cIdGen,dDate,cPeriode,nMode)
local b := oMva()
local nMode := DDMODE_SHOW
local cIdGen
RETURN .f. if ! ddRecLock()
if ODA->Etat != DocStatClosed()
  nMode := DDMODE_EDIT
endif
MvaInit(ODA->IdJnl,ODA->IdDoc,NIL,DC_DEBIT,0,ODA->Periode)
open area b, oAna(), oGen(), oBud()
  #ifdef DEF_IMP
    cIdGen := ODA->IdGen
  #else
    cIdGen := ODA->IdBud
  #endif
  ddSetOrder(ORD_MVA_DOC)
  edit data b key      MVA->IdJnl + MVA->IdDoc ;
              value    ODA->IdJnl + ODA->IdDoc  ;
              start    top                  ;
              create   {|| MvaCreate( ;
                ODA->IdJnl,ODA->IdDoc,cIdGen, NIL, ;
                ODA->Date, ODA->Periode ;
              )} ;
              before   MvaBefore() ;
              after    MvaAfter() ;
              mode     nMode                           ;
              query    "MVAODA" ;
              title    (ODA->IdJnl + " " + ODA->IdDoc + MSG023)
close area
if ddLastKey() == K_F10
  OdaDlgClose(.t.)
endif
unlock record
RETURN .f.

**
** OdaWait()
**
FUNCTION OdaWait(wwin)
local b := oMva()
* if wwin[WIN_WAITKEY] == 9
  b := oMva()
  open area b, oAna(), oGen(), oBud(), oPar()
    ddSetOrder(ORD_MVA_DOC)
    edit data b key   MVA->IdJnl + MVA->IdDoc ;
                value ODA->IdJnl + ODA->IdDoc ;
                mode     wait           ;
                window wwin ;
                query    "MVAODA"
  close area
* endif
RETURN NIL

#endif DEF_MVA

#ifdef DEF_ANA

**
** AnaWait()
**
FUNCTION AnaWait(wwin)
#ifdef DEF_MVA
  local b := oMva()
  if wwin[WIN_WAITKEY] == 9       // wie AnaMvaEdit()
    b := oMva()
    open area b, oAna(), oGen(), oBud(), oPar()
      ddSetOrder(ORD_MVA_CPTDATE)
      edit data b key MVA->IdAna ;
                  value   ANA->IdAna      ;
                  mode     wait           ;
                  window wwin ;
                  query    "MVAANA" ;
                  start bottom
    close area
  elseif wwin[WIN_WAITKEY] == 3  // wie AnaCtaEdit()
    b := oCta()
    open area b, oAna()
      edit data b key CTA->IdAna ;
                  value   ANA->IdAna      ;
                  mode     wait           ;
                  window   wwin ;
                  query    "CTAANA"   ;
                  start bottom
    close area
  endif
#endif DEF_MVA
RETURN NIL

#endif DEF_ANA


#ifdef DEF_GRA

**
** GraArtEdit()
**
FUNCTION GraArtEdit(xlFilter)
local ciGra := GRA->iGra
local b := oArt()
local cIdQry
default xlFilter to ArtFilter()
if empty(GRA->IdQry)
  cIdQry := "ARTGRA"
else
  cIdQry := "ART" + trim(GRA->IdQry)
endif
open area b, oGra(), oPar(), oAcf()
  ddSetOrder(ORD_ART_GRA)
  edit data b ;
       key      ART->iGra ;
       value    ciGra ;
       mode     find                   ;
       create   {||ArtCreate(ciGra,NIL) }      ;
       start    top                    ;
       query    (cIdQry) ;
       filter  (xlFilter) ;
       title (MSG031 + ciGra + " " + trim(GRA->Name1))
close area
RETURN .f.

#endif DEF_GRA


***
*** ParGetArt()
***
*FUNCTION ParGetArt()
*local cIdPar := PAR->IdPar
*local ad := oArt()
** open window (MSG041 + trim(ParName())) color (CfgBrowseColor())
*open area ad, oGra(), oPar()
*  ddSetOrder(ART_ORD_IDFOU)
*  edit data ad key ART->IdPar value cIdPar ;
*    mode     find                   ;
*    create   ArtCreate(NIL,cIdPar)  ;
*    start    top                    ;
*    query    "ARTPAR" ;
*    append ;
*    title (MSG041 + trim(ParName()))
*close area
** close window
*RETURN .f.

#ifdef DEF_IVT

**
** IvtIvlEdit()
**
FUNCTION IvtIvlEdit()
local nPamp := 0
local nDpa := 0
local dDate := IVT->Date
local nCount := 0
* local cId := IVT->IdIvt
local b   := oIvl()
open area oIvl(), oArt(), oGra()
  *open window (MsgInhalt() + "Inventur vom " + dtoc(dDate)) ;
  *            size 18,80 ;
  *            color (CfgWindowColor())
  edit data b key dtos(IVL->Date) value dtos(dDate) ;
              create {||IvlCreate(dDate)} ;
              start top  ;
              mode  find ;
              query "IVLIVT" ;
              title (MsgInhalt() + "Inventur vom " + dtoc(dDate))
  * close window
  if IVT->Etat != DocStatClosed()
    if ddSetUpdated() .or. IVT->Etat == DocStatNew()
      MsgDisplay("Berechnung l„uft...")
      select IVL
      softseek dtos(dDate)
      do while IVL->Date == dDate .and. !eof()
        nPamp += qton(IVL->Qte) * val(IVL->PAMP)
        nDpa  += qton(IVL->Qte) * val(IVL->DPA)
        nCount++
        skip
      enddo
      select IVT
      if ddRecLock()
        IVT->PAMP    := ntom(nPamp)
        IVT->DPA     := ntom(nDpa)
        IVT->Etat    := DocStatOpen()
        IVT->Nbre    := str(nCount,5,0)
        unlock record
      endif
      ddRefreshCurrent()
    endif
  endif
close area
RETURN MnuDone()

**
** ArtIvlEdit()
**
FUNCTION ArtIvlEdit()
local cIdArt := ART->IdArt
local b := oIvl()
return MnuDone() if ! ddRecLock()
open area b, oIvt(), oGra()
  ddSetOrder(ORD_IVL_ART)
  edit data b key IVL->IdArt value cIdArt ;
              create {||DDCREATE_FAIL} ;
              start top  ;
              mode  find ;
              query "IVLART" ;
              title (trim(SayIdArt(cIdArt)) + " : Inventur-Eintr„ge")
close area
unlock record
RETURN MnuDone()

#endif DEF_IVT


#ifdef DEF_STS

**
** ArtStsEdit()
**
FUNCTION ArtStsEdit()
local cIdArt := ART->IdArt
local b := oSts()
open area b
  edit data b key STS->IdArt value cIdArt ;
    mode     show                   ;
    start    bottom ;
    query "STS" ;
    title (trim(ArtIdArtF()) + " " + trim(ART->Name1))
close area
RETURN .f.

#endif DEF_STS

#ifdef DEF_ACF

FUNCTION MsgAcfEdit()
#ifdef LG_FRENCH
RETURN " : prix partenaires"
#else
RETURN " : Partnerpreise"
#endif

**
** ArtAcfEdit()
**
FUNCTION ArtAcfEdit(cIdPar,cIdQry,xlAfter)
local lOkay := .t.
local cIdArt := ART->IdArt
local b := oAcf()
default cIdQry to "ACFART"
default xlAfter to "ArtDlgPrix()"
RETURN .f. if ! ddRecLock()
open area b, oPar(), oArt()
  edit data b ;
    key   ACF->IdArt ;
    value cIdArt ;
    create {||AcfCreate(cIdArt,cIdPar)} ; // AcfCreate(ART->IdCtr,cIdArt,cIdPar)} ;
    mode     edit                   ;
    start    top ;
    query cIdQry ;
    title (trim(ArtIdArtF()) + " " + trim(ART->Name1) + MsgAcfEdit() )
close area
* if ddLastKey() != K_ESC
if xlAfter != NIL
  lOkay := xparse(xlAfter) // ArtDlgPrix()
endif
unlock record
RETURN lOkay

**
** ParAcfEdit()
**
FUNCTION ParAcfEdit(cIdPar)
local b := oAcf()
open area b, oPar(), oArt()
  ddSetOrder(ORD_ACF_PAR)
  edit data b ;
    key ACF->IdPar ;
    value cIdPar ;
    create {||AcfCreate(NIL,cIdPar)} ; // AcfCreate(PrtIdCtr(PAR->IdPrt),NIL,cIdPar)} ;
    mode     find  ;
    start    top   ;
    query "ACFPAR" ;
    title (trim(ParName()) + MsgAcfEdit())
close area
RETURN .f.

*FUNCTION ParIdCtrDefault
*RETURN left(CtrPrtList(PAR->IdPrt),1)

#else

#ifdef DEF_ART

**
** ParArtEdit()
**
FUNCTION ParArtEdit(cIdPar)
local b := oArt()
open area b, oPar(), oGra()
  ddSetOrder(ORD_ART_PAR)
  edit data b ;
    key ART->IdPar ;
    value cIdPar ;
    create {||ArtCreate(NIL,cIdPar)} ;
    mode     find  ;
    start    top   ;
    query "ARTPAR" ;
    title (trim(ParName()) + MsgArtParEdit() )
close area
RETURN .f.

FUNCTION MsgArtParEdit()
#ifdef LG_GERMAN
  RETURN " : Artikel pro Lieferant"
#else
  RETURN " : Articles par fournisseur"
#endif

#endif DEF_ART

#endif DEF_ACF

#ifdef DEF_ANW

**
** ParGetAnw() - Anwesenheiten pro Partner
**
FUNCTION ParGetAnw()
local b := oAnw()
local ciCli := PAR->IdPar
* open window (trim(ParName()) + MSG025) size 15,50
open area b, oPar()
  ddSetOrder(2)
  edit data b key ANW->IdPar value ciCli ;
    create   {||AnwCreate(ciCli,NIL)} ;
    mode find ;
    start bottom ;
    query "ANWPAR" ;
    title (trim(ParName()) + MSG025)
    * query 2
close area
* close window
RETURN .f.

**
** AnwEdit() - Anwesenheiten global nach Datum
**
FUNCTION AnwEdit()
local b := oAnw()
local dDate := UserDate()
* static dDate := NIL
* default dDate to UserDate()
* open window MSG009 size 3,50
* say MSG008
* get dDate
* nKey := ReadScr()
* close window
* RETURN .f. if nKey == K_ESC
do while dow(dDate) != 1
  dDate--
enddo
* open window (MSG008 + dtoc(dDate)) color (CfgBrowseColor())
open area b, oPar()
  edit data b key dtos(ANW->Date) value dtos(dDate) ;
    create   {||AnwCreate(NIL,dDate)} ;
    mode find ;
    start bottom ;
    query "ANWDATE" ;
    title (MSG008 + dtoc(dDate))
    * query 1
close area
* close window
RETURN .f.


FUNCTION AnwPostEdit
do while dow(ANW->Date) != 1
  ANW->Date--
enddo
RETURN .T.


**
** AwcEdit() -
**
*FUNCTION AwcEdit()
*local b := oAwc()
*open window ("Konfigurierung Anwesenheits-Codes") size 10,60
*open area b
*  edit data b ;
*    mode edit ;
*    start top ;
*    append
*close area
*close window
*AwcRefresh()
*RETURN .f.


#endif DEF_ANW

**
** ParWait()
**
FUNCTION ParWait(cIdPar,wwin)
local b
local cCptType
if nextkey() != 0
  RETURN NIL
                                                  #ifdef DEF_MEMO
elseif wwin[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH], ;
    NIL, NIL, StdMemoWidth() ;
  )
                                                 #endif DEF_MEMO
                                                      #ifdef DEF_ACF
elseif wwin[WIN_WAITKEY] == 18 // wie ParAcfEdit()
  b := oAcf()
  open area b, oPar(), oArt()
    ddSetOrder(ORD_ACF_PAR)
    edit data b key    ACF->IdPar ;
                value  cIdPar ;
                mode wait ;
                start top ;
                window wwin ;
                query "ACFPAR"
  close area
                                                      #endif DEF_ACF
                                                 #ifdef DEF_VNA
elseif wwin[WIN_WAITKEY] == 6  // wie ParVnaEdit()
  b := oVna()
  open area b, oArt(), oPar()
    ddSetOrder(ORD_VNA_PARDATE)
    edit data b ;
      key VNA->IdPar ;
      value cIdPar ;
      mode wait ;
      window wwin ;
      start top ;
      filter "empty(VNA->Satis)" ;
      query     "VNAPARD"
  close area
                                                  #endif DEF_VNA
                                                 #ifdef DEF_PRESTO
elseif wwin[WIN_WAITKEY] == 8
  b := oTrm()
  open area b, oPar(), oArt()
    ddSetOrder(ORD_TRM_PAR)
    edit data b key TRM->IdPar value cIdPar ;
                mode wait ;
                window wwin ;
                start bottom ;
                query "TRMPAR"
  close area
                                                  #endif DEF_PRESTO
                                                 #ifdef DEF_PRJ
elseif wwin[WIN_WAITKEY] == 28 // CUST Delbrassine
  b := oPrj()
  open area b, oPar(), oPlz()
    // ddSetOrder(ORD_TRM_PAR)
    edit data b key PRJ->IdPar2 value cIdPar ;
                mode wait ;
                window wwin ;
                start top ;
                query "PRJPAR2"
  close area
                                                  #endif DEF_PRJ
                                                 #ifdef DEF_PSC
elseif wwin[WIN_WAITKEY] == 4
  b := oPsc()
  open area b, oPar()
    edit data b key PSC->IdPar value cIdPar ;
                mode wait ;
                window wwin ;
                start top ;
                query "PSCPAR1"
  close area
elseif wwin[WIN_WAITKEY] == 14
  b := oPsc()
  open area b, oPar()
    edit data b key PSC->IdPar2 value cIdPar ;
                mode wait ;
                window wwin ;
                start top ;
                query "PSCPAR2"
  close area
                                                  #endif DEF_PSC
                                                 #ifdef DEF_PLP
elseif wwin[WIN_WAITKEY] == 4
  b := oPlp()
  open area b, oPar()
    edit data b key PLP->IdPar1 value cIdPar ;
                mode wait ;
                window wwin ;
                start top ;
                query "PLPPAR1"
  close area
elseif wwin[WIN_WAITKEY] == 14
  b := oPlp()
  open area b, oPar()
    edit data b key PLP->IdPar2 value cIdPar ;
                mode wait ;
                window wwin ;
                start top ;
                query "PLPPAR2"
  close area
                                                  #endif DEF_PLP
                                                 #ifdef DEF_PRB
elseif wwin[WIN_WAITKEY] == 42
  b := oPpr()
  open area b, oPar(), oPrb()
    edit data b key PPR->IdPar value cIdPar ;
                mode wait ;
                window wwin ;
                start top ;
                query "PPRPAR"
  close area
                                                  #endif DEF_PRB
                                                 #ifdef DEF_PLS
elseif wwin[WIN_WAITKEY] == 24    // ParMbrEdit() primary memberships
  b := oMbr()
  open area b, oPar(), oPls()
    // ddSetOrder ORD_MBR_PAR
    edit data b key MBR->IdPar value cIdPar ;
                mode wait ;
                window wwin ;
                start top ;
                query "MBRPAR"
  close area
elseif wwin[WIN_WAITKEY] == 34    // secondary memberships
  b := oMbr()
  open area b, oPar(), oPls()
    edit data b key MBR->IdPar2 value cIdPar ;
                mode wait ;
                window wwin ;
                start top ;
                query "MBRPAR2"
  close area
                                                  #endif DEF_PLS
                                                  #ifdef DEF_CTP
elseif wwin[WIN_WAITKEY] == 3
  b := oCtp()
  open area b
    edit data b key CTP->IdPar value cIdPar ;
                mode wait ;
                window wwin ;
                start bottom ;
                query "CTPPAR"
  close area
                                                  #endif DEF_CTP
                                                  #ifdef DEF_HST
elseif wwin[WIN_WAITKEY] == 9  // wie ParHstEdit()
  b := oHst()
  open area b, oPar(), oGen(), oVen(), oFin(), oFnl()
    ddSetOrder(ORD_HST_PARDATE)
    edit data b key      HST->IdPar ;
                value    cIdPar      ;
                start    bottom                          ;
                mode     wait                            ;
                filter   "empty(HST->Satis)" ;
                window   wwin ;
                query    "HSTPARD"
  close area
                                                  #endif DEF_HST
                                                  #ifdef DEF_IMP
elseif wwin[WIN_WAITKEY] == 9 // siehe ParMviEdit()
  b := oMvi()
  open area b, oPar(), oBud(), oImp()
    ddSetOrder(ORD_MVI_PARDATE)
    edit data b key      MVI->IdPar ;
                value    cIdPar      ;
                start    bottom                          ;
                mode     wait                            ;
                filter   "!empty(MVI->MontUs).and.JnlIdCdc(MVI->IdJnl)=='" ;
                          + MemIdCdc + "'" ;
                window   wwin ;
                query    "MVIPAR02"
  close area
elseif wwin[WIN_WAITKEY] == 19 // siehe ParMviEdit()
  b := oMvi()
  open area b, oPar(), oBud(), oImp()
    ddSetOrder(ORD_MVI_PARDATE)
    edit data b key      MVI->IdPar ;
                value    cIdPar      ;
                start    bottom                          ;
                mode     wait                            ;
                filter   "JnlIdGrj(MVI->IdJnl) == 'TRE'" ;
                window   wwin ;
                query    "MVIPAR02"
  close area
                                                  #endif DEF_IMP
                                                  #ifdef DEF_VEN
elseif wwin[WIN_WAITKEY] == 5 // snParWaitKey == K_F5
    b := oVen()
    open area b, oPar()
      ddSetOrder(ORD_VEN_PAR)
      edit data b key VEN->IdPar  ;
                  value    cIdPar   ;
                  start    bottom ;
                  mode     wait ;
                  window   wwin ;
                  query    "VENPAR"
    close area
elseif wwin[WIN_WAITKEY] == 15 // snParWaitKey == K_F5
    b := oVen()
    open area b, oPar()
      ddSetOrder(ORD_VEN_PAR)
      edit data b key VEN->IdPar  ;
                  value    cIdPar   ;
                  start    bottom ;
                  mode     wait ;
                  window   wwin ;
                  query    "VENPARD"
    close area
                                                  #endif DEF_VEN
                                                  #ifdef DEF_PIN
elseif wwin[WIN_WAITKEY] == 38 // CUST PAC
    b := oPin()
    open area b, oPar(), oPrj()
      edit data b key PIN->IdPar  ;
                  value    cIdPar   ;
                  start    bottom ;
                  filter   "PIN->IdPns!='C'" ;
                  mode     wait ;
                  window   wwin ;
                  query    "PINPAR"
    close area
                                                  #endif DEF_PIN
else
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"PAR",cIdPar)
#endif DEF_RFX
endif
RETURN NIL

#ifdef DEF_GEN

**
** GenWait()
**
FUNCTION GenWait(wwin)
local b
local cIdGen := GEN->IdGen
if nextkey() != 0
  RETURN NIL
                                                  #ifdef DEF_HST
elseif wwin[WIN_WAITKEY] == 3
  if GENATTR_C $ GEN->Attrib .and. ! USRATTR_C $ UsrAttrib()
    cIdGen := space(LenIdGen())
  endif
  b := oCtg()
  open area b
    edit data b key CTG->IdGen value cIdGen ;
                mode wait ;
                window wwin ;
                start bottom ;
                query "CTGGEN"
  close area
elseif wwin[WIN_WAITKEY] == 9 // snParWaitKey == K_SH_F9
  if GENATTR_C $ GEN->Attrib .and. ! USRATTR_C $ UsrAttrib()
    cIdGen := space(LenIdGen())
  endif
  b := oHst()
  open area b, oPar(), oGen(), oVen(), oFin(), oFnl()
    ddSetOrder(ORD_HST_GENDATE)
    edit data b key HST->IdGen ;
                value    cIdGen      ;
                start    bottom                          ;
                mode     wait                            ;
                window wwin ;
                query    "HSTGEND"
  close area
                                                  #endif DEF_HST
                                                  #ifdef DEF_MEMO
elseif wwin[WIN_WAITKEY] == 12 // snParWaitKey == K_F12
  MemoDisplay(FIELD->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
  * MemoDisplay(FIELD->Memo,GEN_WAIT_HOME,GEN_WAIT_SIZE)
                                                  #endif DEF_MEMO
endif
RETURN NIL

#endif DEF_GEN

#ifdef DEF_GRA

**
** GraWait()
**
FUNCTION GraWait(wwin)
local b
local cIdGra := GRA->iGra
local cIdQry
if nextkey() != 0
  RETURN NIL
elseif wwin[WIN_WAITKEY] == 1
  if empty(GRA->IdQry)
    cIdQry := "ARTGRA"
  else
    cIdQry := "ART" + trim(GRA->IdQry)
  endif
  b := oArt()
  open area b
    ddSetOrder(ORD_ART_GRA)
    edit data b key    ART->iGra ;
                value  cIdGra ;
                mode   wait ;
                window wwin ;
                start  top ;
                filter  "!'"+ARTATTR_H+"' $ ART->Attrib" ;
                query "ARTGRA"
  close area
endif
RETURN NIL


#endif DEF_GRA



#ifdef DEF_PRESTO

FUNCTION TrmWait(wwin)
local nWidth := TplValue(TPLTYPE_TRM,"STD",{||val(TPL->Width)},76)
MemoDisplay( ;
  FIELD->MemoTxt, ;
  wwin[WIN_TOP], ;
  wwin[WIN_LEFT], ;
  wwin[WIN_HEIGHT], ;
  wwin[WIN_WIDTH], ;
  NIL, NIL, nWidth ;
)
* MemoDisplay(AgaText(TRM->Attrib) + CR_LF + FIELD->MemoTxt,12,1,9,78)
RETURN NIL

#endif DEF_PRESTO

#ifdef DEF_PIN

FUNCTION PinWait(wwin)
local b
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,alias(),PIN->IdPin)
#endif DEF_RFX
if wwin[WIN_WAITKEY] == 12
  MemoDisplay(PIN->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
                                                  #ifdef DEF_VEN
elseif wwin[WIN_WAITKEY] == 5
    b := oVen()
    open area b, oPar(),oPrj()
      edit data b key VEN->IdPin  ;
                  value    PIN->IdPin ;
                  start    bottom ;
                  mode     wait ;
                  window   wwin ;
                  query    "VENPIN"
    close area
                                                  #endif DEF_VEN
endif
RETURN NIL

#endif DEF_PIN

#ifdef DEF_VEN

FUNCTION VenTplWidth
local cIdTpt := JnlIdTpt(VEN->IdJnl)
local nWidth
RETURN 76 if empty(cIdTpt)
nWidth := TplValue(cIdTpt,VenIdTpl(),{||val(TPL->Width)},76)
RETURN 76 if nWidth <= 40
RETURN nWidth

#endif DEF_VEN

#ifdef DEF_PRJ

FUNCTION PrjWait(wwin)
local b
local cIdPrj := PRJ->IdPrj
RETURN NIL if nextkey() != 0
if wwin[WIN_WAITKEY] == 2       // wie PrjPrjEdit()
  b := oPrj()
  open area b, oPar()
    ddSetOrder(5)
    edit data b key    PRJ->Parent ;
                value  cIdPrj ;
                mode wait ;
                window wwin ;
                query "PRJPRJ"
  close area
  RETURN NIL
endif
#ifdef DEF_VEN
  if wwin[WIN_WAITKEY] == 5       // wie PrjVenEdit()
    b := oVen()
    open area b, oPar()
      ddSetOrder(ORD_VEN_PRJ)
      edit data b key    VEN->IdPrj ;
                  value  cIdPrj ;
                  mode wait ;
                  window wwin ;
                  query "VENPRJ"
    close area
    RETURN NIL
  endif
#endif DEF_VEN
#ifdef DEF_PIN
  if wwin[WIN_WAITKEY] == 6       // wie PrjPinEdit()
    b := oPin()
    open area b
      ddSetOrder(ORD_PIN_IDPRJ)
      edit data b key PIN->IdPrj ;
                  value cIdPrj ;
                  start bottom ;
                  query "PINPRJ" ;
                  mode wait ;
                  window wwin
    close area
    RETURN NIL
  endif
#endif DEF_VEN
#ifdef DEF_IMP
  if wwin[WIN_WAITKEY] == 9
    RETURN PrjMviWait(wwin)
  endif
#endif DEF_IMP
#ifdef DEF_KITZ
  if wwin[WIN_WAITKEY] == 1
    RETURN PrjLdjWait(wwin)
  endif
#endif DEF_KITZ
#ifdef DEF_LPJ
  if wwin[WIN_WAITKEY] == 1
    RETURN PrjLpjWait(wwin)
  endif
#endif DEF_LPJ
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"PRJ",PRJ->IdPrj)
#endif DEF_RFX
if wwin[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Text, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
endif
RETURN NIL

#ifdef DEF_VEN

**
** PrjVenEdit() - Documents vente d'un client
**
FUNCTION PrjVenEdit()
local b := oVen()
local cIdPrj := PRJ->IdPrj
* snPrjWaitKey := K_F5
open area b, oPar()
  ddSetOrder(ORD_VEN_PRJ)
  edit data b key VEN->IdPrj ;
    value    cIdPrj             ;
    create   {||DDCREATE_FAIL} ;
    start    bottom                 ;
    mode     find  ;
    query    "VENPRJ" ;
    title (trim1(PRJ->IdPrj) + trim(PRJ->Name1) + " : Rechnungen")
close area
RETURN MnuDone()

#endif DEF_VEN

#ifdef DEF_IMP

**
** PrjMviEdit()
**
FUNCTION PrjMviEdit()
local b := oMvi()
local cIdPrj := PRJ->IdPrj
local a := MviSaveFilter()
open area b, oPar(), oBud(), oImp()
  MviSetFilter()
  ddSetOrder(ORD_MVI_PRJ)
  edit data b key MVI->IdPrj ;
    value    cIdPrj             ;
    start    bottom                 ;
    mode     find  ;
    query    "MVIPRJ" ;
    title (trim1(PRJ->IdPrj) + trim(PRJ->Name1) + " : Buchungen")
close area
MviRestFilter(a)
RETURN MnuDone()

**
** PrjMviWait()
**
FUNCTION PrjMviWait(wwin)
local b := oMvi()
local cIdPrj := PRJ->IdPrj
open area b, oPar(), oBud(), oImp()
  ddSetOrder(ORD_MVI_PRJ)
  edit data b key MVI->IdPrj ;
    value    cIdPrj             ;
    start    bottom                 ;
    mode     wait  ;
    window   wwin ;
    query    "MVIPRJ" ;
    title (trim1(PRJ->IdPrj) + trim(PRJ->Name1) + " : Buchungen")
close area
RETURN MnuDone()

**
** MatchMviEdit()
**
FUNCTION MatchMviEdit(cIdPar,cMatch)
local b := oMvi()
local a := MviSaveFilter()
open area b, oPar(), oBud(), oImp(), oIml()
  MviSetFilter()
  ddSetOrder(ORD_MVI_PARMATCH)
  * edit data b key MVI->IdPar + MVI->Match
  *   value    cIdPar + cMatch
  edit data b key MVI->Match ;
    value    cMatch             ;
    start    top                 ;
    mode     find  ;
    query    "MVIMAT" ;
    title (cMatch + " : Buchungen/Match")
close area
MviRestFilter(a)
RETURN MnuDone()

**
** EaMviEdit()
**
FUNCTION EaMviEdit(cIdPar,cMatch)
local b := oMvi()
local a := MviSaveFilter()
open area b, oPar(), oBud(), oImp()
  MviSetFilter()
  ddSetOrder(ORD_MVI_EAMATCH)
  edit data b key MVI->IdPar + MVI->EaMatch ;
    value    cIdPar + cMatch             ;
    start    top                 ;
    mode     find  ;
    query    "MVIPAREA" ;
    title (cIdPar + cMatch + " : Buchungen/EA-Match")
close area
MviRestFilter(a)
RETURN MnuDone()

FUNCTION ImlWait(wwin)
local b := oMvi()
// local cIdPar := IML->IdPar
local cMatch := IML->Match
open area b, oPar(), oBud(), oImp(), oIml()
  ddSetOrder(ORD_MVI_PARMATCH)
  * edit data b key MVI->IdPar + MVI->Match
  *   value cIdPar + cMatch
  edit data b key MVI->Match ;
    value cMatch ;
    start    top                 ;
    mode     wait  ;
    window   wwin ;
    query    "MVIMAT"
close area
RETURN NIL

FUNCTION MviWait(wwin)
local b := oMvi()
// local cIdPar := MVI->IdPar
local cMatch := MVI->Match
open area b, oPar(), oBud(), oImp(), oIml()
  ddSetOrder(ORD_MVI_PARMATCH)
  * edit data b key MVI->IdPar + MVI->Match
  *   value cIdPar + cMatch
  edit data b key MVI->Match ;
    value cMatch ;
    start    top                 ;
    mode     wait  ;
    window   wwin ;
    query    "MVIMAT"
close area
RETURN NIL


#endif DEF_IMP

#endif DEF_PRJ

#ifdef DEF_VNA

**
** MatchVnaEdit()
**
*FUNCTION MatchVnaEdit(cIdArt,cMatch)
*local b := oVna()
*open area b, oPar(), oArt()
*  ddSetOrder ORD_VNA_ARTMATCH
*  edit data b key VNA->IdArt + VNA->Match ;
*    value    cIdArt + cMatch             ;
*    start    top                 ;
*    mode     find  ;
*    query    "VNAMATCH" ;
*    title (cIdArt + "/" + cMatch + " : Buchungen")
*close area
*RETURN MnuDone()

FUNCTION VnaWait(wwin)
local b := oVna()
local cMatch := VNA->IdArt + VNA->Match
if wwin[WIN_WAITKEY] == 12
  MemoDisplay(VNA->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
*else
*  open area b, oPar(), oArt()
*    ddSetOrder ORD_VNA_ARTMATCH
*    edit data b key VNA->IdArt + VNA->Match ;
*      value cMatch ;
*      start    top                 ;
*      mode     wait  ;
*      window   wwin ;
*      query    "VNAMATCH"
*  close area
endif
RETURN NIL


**
** VnaMemoEdit()
**
FUNCTION VnaMemoEdit()
return MnuDone() if ! ddRecLock()
open window ("Text-Editor") size 20,80
TxtEdit( ;
  fieldblock("Memo"), WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
  ddOnPreEdit(oVna()), 76 ;
)
unlock record
close window
RETURN .f.

#endif DEF_VNA



*  #ifdef DEF_MOD
*
*  **
*  ** ModMdlEdit() -
*  **
*  FUNCTION ModMdlEdit()
*  local b := oIml()
*  local cIdMod := MOD->IdMod
*  RETURN .f. if ! ddRecLock()
*  open area b, oArt(), oGen()
*    snMdlSum := 0
*    ddSetOrder ORD_MDL_ID
*    softseek cIdMod
*    do while MDL->IdMod == cIdMod
*      snMdlSum += val(MDL->Mont)
*      skip
*    enddo
*    edit data b key MDL->IdMod ;
*      value    cIdMod              ;
*      create   MdlCreate( cIdMod ) ;
*      start    bottom                 ;
*      mode     edit  ;
*      append ;
*      query ("MDL") ;
*      title ("Inhalt " + cIdMod)
*    if MOD->Etat != DocStatClosed()
*      MOD->Mont := ntom(snMdlSum)
*    endif
*  close area
*  RETURN MnuDone()
*
*  #endif DEF_MOD

*#ifdef DEF_COMPTA
*
*#define MARK_IDLE 1
*#define MARK_MARK 2
*#define MARK_UNDO 3
*
*static aRecNo
*static nDebit
*static nCredit
*static snMarkMode
*
*FUNCTION MvpMarkSatis(lInit)
*if lInit
*  aRecNo := {}
*  nDebit := 0
*  nCredit := 0
*  snMarkMode := MARK_IDLE
*  RETURN NIL
*endif
*if MVP->Satis == " "
*  if snMarkMode == MARK_MARK .or. snMarkMode == MARK_IDLE
*    snMarkMode := MARK_MARK
*    if DictAddItem(aRecNo, recno())
*      if MVP->DC == DC_DEBIT
*        nDebit += val(MVP->Mont)
*      else
*        nCredit += val(MVP->Mont)
*      endif
*    elseif DictDelItem(aRecNo, recno())
*      if MVP->DC == DC_DEBIT
*        nDebit  -= val(MVP->Mont)
*      else
*        nCredit -= val(MVP->Mont)
*      endif
*    endif
*  endif
*else
*  if snMarkMode == MARK_UNDO .or. snMarkMode == MARK_IDLE
*    snMarkMode := MARK_UNDO
*    if DictAddItem(aRecNo, recno())
*      if MVP->DC == DC_DEBIT
*        nDebit += val(MVP->Mont)
*      else
*        nCredit += val(MVP->Mont)
*      endif
*    elseif DictDelItem(aRecNo, recno())
*      if MVP->DC == DC_DEBIT
*        nDebit  -= val(MVP->Mont)
*      else
*        nCredit -= val(MVP->Mont)
*      endif
*    endif
*  endif
*endif
*if len(aRecNo) > 0
*  SetMsg( ;
*    ntrim(len(aRecNo)) + " records : " + ;
*    ntrim(nDebit) + " - " + ;
*    ntrim(nCredit) + " = " + ;
*    ntrim(nDebit - nCredit) ;
*  )
*  if abs(nDebit - nCredit) < 0.0001
*    for i := 1 to len(aRecNo)
*      goto aRecNo[i]
*      if ddRecLock()
*        if snMarkMode == MARK_MARK
*          MVP->Satis := "*"
*        else
*          MVP->Satis := " "
*        endif
*        unlock
*      endif
*    next i
*  endif
*endif
*RETURN NIL
*
*#endif DEF_COMPTA

*#ifdef DEF_PRD
*
*FUNCTION PrdPrlEdit()
*local cIdJnl := PRD->IdJnl
*local cIdDoc := PRD->IdDoc
*local jnl    := JnlLocate(cIdJnl)
*local b := oPrl()
*RETURN MnuDone() if jnl == NIL
*RETURN MnuDone() if ! ArtExist(PRD->IdArt)
*RETURN MnuDone() if ! ddRecLock()
*open area b, oArt()
*  edit data b key    PRL->IdJnl + PRL->IdDoc ;
*              value  cIdJnl + cIdDoc ;
*              query  ("PRL" + jnl[JNL_IDDBV]) ;
*              create PrlCreate(cIdJnl,cIdDoc) ;
*              title  (cIdJnl + " " + cIdDoc + " : Inhalt")
*close area
*unlock record
*RETURN MnuDone()
*
*#endif DEF_PRD

#ifdef DEF_ART

FUNCTION ArtWait(wwin)
local b
local cIdArt := ART->IdArt
if wwin[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Memo1, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH], ;
    NIL, NIL, 250, ;
  )
                                                      #ifdef DEF_IVT
elseif wwin[WIN_WAITKEY] == 2
  b := oIvl()
  open area b, oArt()
    ddSetOrder(ORD_IVL_ART)
    edit data b key    IVL->IdArt ;
                value  cIdArt ;
                mode wait ;
                window wwin ;
                query "IVLART"
  close area
                                                      #endif DEF_IVT
                                                      #ifdef DEF_VEN
elseif wwin[WIN_WAITKEY] == 5 ; ArtVnlWait(wwin)
                                                      #endif DEF_VEN
                                                      #ifdef DEF_VNA
elseif wwin[WIN_WAITKEY] == 6  // wie ArtVnaEdit()
  b := oVna()
  open area b, oArt()
    edit data b key    VNA->IdArt ;
                value  cIdArt ;
                mode wait ;
                window wwin ;
                start top ;
                query "VNAARTD"
  close area
                                                      #endif DEF_VNA
                                                      #ifdef DEF_ACF
elseif wwin[WIN_WAITKEY] == 8 // wie ArtAcfEdit()
  b := oAcf()
  open area b, oPar(), oArt()
    ddSetOrder(ORD_ACF_ART)
    edit data b key    ACF->IdArt ;
                value  cIdArt ;
                mode wait ;
                start top ;
                window wwin ;
                query "ACFART"
  close area
                                                      #endif DEF_ACF
                                                      #ifdef DEF_ALA
elseif wwin[WIN_WAITKEY] == 9 // wie ArtAlaEdit()
  b := oAla()
  open area b, oArt()
    ddSetOrder(ORD_ALA_ART1)
    edit data b key    ALA->IdArt1 ;
                value  cIdArt ;
                mode wait ;
                window wwin ;
                query "ALAART"
  close area
elseif wwin[WIN_WAITKEY] == 19 // wie ArtAlaEdit()
  b := oAla()
  open area b, oArt()
    ddSetOrder(ORD_ALA_ART2)
    edit data b key    ALA->IdArt2 ;
                value  cIdArt ;
                mode wait ;
                window wwin ;
                query "ALAART2"
  close area
                                                      #endif DEF_ALA
                                                      #ifdef DEF_TREE
elseif wwin[WIN_WAITKEY] == 49 // Luc privat
  b := oArt()
  open area b, oGra()
    edit data b key    ART->Parent ;
                value  cIdArt ;
                mode wait ;
                window wwin ;
                query "ARTART"
  close area
                                                      #endif DEF_TREE
                                                      #ifdef DEF_CTS
elseif wwin[WIN_WAITKEY] == 3
  b := oCts()
  open area b, oArt()
    edit data b key    CTS->IdArt ;
                value  cIdArt ;
                mode wait ;
                start bottom ;
                window wwin ;
                query "CTSART"
  close area
                                                      #endif DEF_CTS
                                                 #ifdef DEF_ALS
elseif wwin[WIN_WAITKEY] == 24    // wie ArtAlmEdit()
  b := oAlm()
  open area b, oArt(), oAls()
    ddSetOrder(ORD_ALM_ART)
    edit data b key ALM->IdArt value cIdArt ;
                mode wait ;
                window wwin ;
                start top ;
                query "ALMART"
  close area
                                                  #endif DEF_ALS
                                                      #ifdef DEF_MVS
elseif wwin[WIN_WAITKEY] == 26
  b := oMvs()
  open area b, oArt()
    edit data b key    MVS->IdArt ;
                value  cIdArt ;
                start bottom ;
                mode wait ;
                window wwin ;
                query "MVSART"
  close area
                                                      #endif DEF_MVS
*                                                     #ifdef DEF_PRD
*elseif wwin[WIN_WAITKEY] == 4
*  b := oMdl()
*  open area b, oArt()
*    edit data b key    MDL->IdArt ;
*                value  cIdArt ;
*                mode wait ;
*                window wwin ;
*                query "MDLART"
*  close area
*                                                     #endif DEF_PRD
                                                      #ifdef DEF_REMISE
elseif wwin[WIN_WAITKEY] == 7
  b := oRpq()
  open area b
    edit data b key    RPQ->IdRga ;
                value  ART->IdRga ;
                mode wait ;
                window wwin ;
                query "RPQRGA"
  close area
                                                      #endif DEF_REMISE
endif
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"ART",cIdArt)
#endif DEF_RFX
RETURN NIL

FUNCTION ArtMemoEdit()
local cLangue := PickLng(scMemoLang,MemLang1+MemLang2+MemLang3)
RETURN .f. if cLangue == NIL
scMemoLang := cLangue
return MnuDone() if ! ddRecLock()
SetTplLang(cLangue)
open window (MSG040 + ART->IdArt + " (" + cLangue + ")" ) ;
            home 9,0 ;
            size 13, 80
  TxtEdit( ;
    fieldblock("Memo"+ntrim(LngIndex(cLangue))), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oArt()), 76, NIL, .f.  ;
  )
close window
*if cLangue == MemLang1
*  SetTplLang(MemLang1)
*  open window (MSG040 + ART->IdArt + " (" + cLangue + ")" ) ;
*              home 9,0 ;
*              size 13, 80
*    TxtEdit( ;
*      fieldblock("Memo1"), ;
*      WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
*      ddOnPreEdit(oArt()), 76, NIL, .f.  ;
*    )
*  close window
*elseif cLangue == MemLang2
*  SetTplLang(MemLang2)
*  open window (MSG040 + ART->IdArt + " (" + cLangue + ")" ) ;
*              home 9,0 ;
*              size 13, 80
*    TxtEdit( ;
*      fieldblock("Memo2"), ;
*      WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
*      ddOnPreEdit(oArt()), 76, NIL, .f.  ;
*    )
*  close window
*elseif cLangue == MemLang3
*  SetTplLang(MemLang3)
*  open window (MSG040 + ART->IdArt + " (" + cLangue + ")" ) ;
*              home 9,0 ;
*              size 13, 80
*    TxtEdit( ;
*      fieldblock("Memo3"), ;
*      WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
*      ddOnPreEdit(oArt()), 76, NIL, .f.  ;
*    )
*  close window
*endif
unlock record
RETURN MnuDone()

#endif DEF_ART

#ifdef DEF_TAX

FUNCTION TaxMemoEdit()
local cLangue := PickLng(scMemoLang) // ,MemLang1+MemLang2+MemLang3)
RETURN .f. if cLangue == NIL
scMemoLang := cLangue
return MnuDone() if ! ddRecLock()
open window (MSG040 + TAX->IdTax + " (" + cLangue + ")" ) ;
            size 13, 80
  TxtEdit( ;
    fieldblock("Memo"+ntrim(LngIndex(cLangue))), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oTax()), 250, NIL, .f.  ;
  )
close window
*if cLangue == MemLang1
*  open window (MSG040 + TAX->IdTax + " (" + cLangue + ")" ) ;
*              size 13, 80
*    TxtEdit( ;
*      fieldblock("Memo1"), ;
*      WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
*      ddOnPreEdit(oTax()), 250, {|| PickTcs()}, .f.  ;
*    )
*  close window
*elseif cLangue == MemLang2
*  open window (MSG040 + TAX->IdTax + " (" + cLangue + ")" ) ;
*              size 13, 80
*    TxtEdit( ;
*      fieldblock("Memo2"), ;
*      WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
*      ddOnPreEdit(oTax()), 250, {|| PickTcs()}, .f.  ;
*    )
*  close window
*elseif cLangue == MemLang3
*  open window (MSG040 + TAX->IdTax + " (" + cLangue + ")" ) ;
*              size 13, 80
*    TxtEdit( ;
*      fieldblock("Memo3"), ;
*      WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
*      ddOnPreEdit(oTax()), 250, {|| PickTcs()}, .f.  ;
*    )
*  close window
*endif
unlock record
ddSetUpdated(.t.)
RETURN MnuDone()

#endif DEF_TAX


#ifdef DEF_JNL

FUNCTION IfcMemoEdit()
local cLangue := PickLng(scMemoLang) // ,MemLang1+MemLang2+MemLang3)
RETURN .f. if cLangue == NIL
scMemoLang := cLangue
return MnuDone() if ! ddRecLock()
open window (MSG040 + IFC->Seq + " (" + cLangue + ")" ) size 13, 80
  TxtEdit( ;
    fieldblock("Memo"+ntrim(LngIndex(cLangue))), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oIfc()), 250, NIL, .f.  ;
  )
close window
*if cLangue == MemLang1
*  open window (MSG040 + IFC->Seq + " (" + cLangue + ")" ) ;
*              size 13, 80
*    TxtEdit( ;
*      fieldblock("Memo1"), ;
*      WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
*      ddOnPreEdit(oIfc()), 250, NIL, .f.  ;
*    )
*  close window
*elseif cLangue == MemLang2
*  open window (MSG040 + IFC->Seq + " (" + cLangue + ")" ) ;
*              size 13, 80
*    TxtEdit( ;
*      fieldblock("Memo2"), ;
*      WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
*      ddOnPreEdit(oIfc()), 250, {|| PickTcs()}, .f.  ;
*    )
*  close window
*elseif cLangue == MemLang3
*  open window (MSG040 + IFC->Seq + " (" + cLangue + ")" ) ;
*              size 13, 80
*    TxtEdit( ;
*      fieldblock("Memo3"), ;
*      WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
*      ddOnPreEdit(oIfc()), 250, {|| PickTcs()}, .f.  ;
*    )
*  close window
*endif
unlock record
RETURN MnuDone()

#endif DEF_JNL

FUNCTION ParDetail
local a := CurMsk(MSK_WAITWINLIST)
local win
RETURN NIL if a == NIL
if len(a) > 0
  win := a[1]
  RETURN ParMemoEdit() if win[WIN_WAITKEY] == 12
  #ifdef DEF_HST
    RETURN ParHstEdit(PAR->IdPar) if win[WIN_WAITKEY] == 9
  #endif DEF_HST
  #ifdef DEF_PSC
    RETURN Par1PscEdit() if win[WIN_WAITKEY] == 4
    RETURN Par2PscEdit() if win[WIN_WAITKEY] == 14
  #endif DEF_PSC
  * #ifdef DEF_PLS
  *   RETURN ParMbrEdit(PAR->IdPar) if win[WIN_WAITKEY] == 24
  * #endif DEF_PLS
  #ifdef DEF_MVI
    RETURN ParMviEdit( ;
      PAR->IdPar, ;
      trim(ParName()) + " : Offene Anrechte oder Verpflichtungen", ;
      "! empty(MVI->MontUs).and.JnlIdCdc(MVI->IdJnl) =='" + MemIdCdc + "'", ;
      "MVIPAR02" ;
    ) if win[WIN_WAITKEY] == 9
  #endif DEF_MVI
endif
ddEditChange()
RETURN NIL

#ifdef DEF_ART

FUNCTION ArtDetail
local a := CurMsk(MSK_WAITWINLIST)
local win
RETURN NIL if a == NIL
if len(a) > 0
  win := a[1]
  * RETURN ArtMemoEdit() if win[WIN_WAITKEY] == 12
  * #ifdef DEF_ACF
  *   RETURN ArtAcfEdit() if win[WIN_WAITKEY] == 8
  * #endif DEF_ACF
  * #ifdef DEF_ALA
  *   RETURN ArtAlaEdit(ART->IdArt) if win[WIN_WAITKEY] == 9
  * #endif DEF_ALA
endif
ddEditChange()
RETURN NIL

#endif DEF_ART

#ifdef DEF_HST

**
** HstWait()
**
FUNCTION HstWait(wwin)
local b
local cIdJnl := VEN->IdJnl
local cIdDoc := VEN->IdDoc
if nextkey() != 0
  RETURN NIL
elseif wwin[WIN_WAITKEY] == 1
  RETURN MatchHstWait(HST->IdPar,HST->Match,wwin)
endif
RETURN .f.

FUNCTION MatchHstWait(cIdPar,cMatch,wwin)  // wie MatchHstEdit()
local b := oHst()
open area b, oPar()
  ddSetOrder(ORD_HST_PARMATCH)
  edit data b  ;
            key HST->IdPar + HST->Match ;
            value cIdPar + cMatch ;
            mode wait   ;
            window wwin ;
            start top ;
            query ("HSTMATCH")
close area
RETURN NIL


FUNCTION MatchHstEdit(cIdPar,cMatch)  // wie MatchHstWait()
local b := oHst()
open area b, oPar()
  ddSetOrder(ORD_HST_PARMATCH)
  edit data b  ;
            key HST->IdPar + HST->Match ;
            value cIdPar + cMatch ;
            mode find   ;
            start top ;
            query ("HSTMATCH")
close area
RETURN NIL

#endif DEF_HST

#ifdef DEF_ODS

**
** OdsOdlEdit()
**
FUNCTION OdsOdlEdit()
local b := oOdl()
local cIdJnl := ODS->IdJnl
local cIdOds := ODS->IdDoc
local nMont := 0
local jnl := JnlLocate(ODS->IdJnl)
local cDevise := SetDevise()
RETURN NIL if jnl == NIL
return MnuDone() if ! ddRecLock()
SetDevise(DevDefault(ODS->Periode))
open area b, oArt()
  edit data b key ODL->IdJnl + ODL->IdDoc ;
              value cIdJnl + cIdOds ;
              create    {||OdlCreate(cIdJnl,cIdOds) };
              preedit   OdsPreEdit() ;
              mode edit ;
              start top ;
              query ("ODL" + jnl[JNL_IDDBV]) ;
              title (MsgInhalt() + ODS->IdJnl + " " + ODS->IdDoc)
  if ddLastKey() == K_F10
    if ODS->Etat != DocStatClosed()
      open area b
        softseek ODS->IdJnl + ODS->IdDoc
        do while ! eof() .and. ODL->IdDoc == ODS->IdDoc ;
                         .and. ODL->IdJnl == ODS->IdJnl
          if ODL->DC == jnl[JNL_DC]
            nMont += val(ODL->Mont)
          else
            nMont -= val(ODL->Mont)
          endif
          skip
        enddo
      close area
      ODS->Etat := DocStatOpen()
      ODS->Mont := ntom(nMont)
    endif
  elseif ODS->Etat != DocStatClosed()
   ddEditChange(.t.)
  endif
close area
unlock record
ddRefreshCurrent()
if ddLastKey() == K_F10 .and. ODS->Etat == DocStatOpen()
  OdsDlgClose()
  if JNLATTR_I $ jnl[JNL_ATTRIB] .and. ODS->Etat == DocStatClosed()
    OdsPrint()
  endif
endif
SetDevise(cDevise)
RETURN .f.


**
** OdsMemoEdit()
**
FUNCTION OdsMemoEdit()
return MnuDone() if ! ddRecLock()
open window (MsgIdJnlDoc() + " : Memotext") size 20,80
TxtEdit( ;
  fieldblock("Memo"), WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
  ddOnPreEdit(oOds()), 76 ;
)
unlock record
close window
RETURN .f.

**
** OdsWait()
**
FUNCTION OdsWait(wwin)
local b := oOdl()
local jnl := JnlLocate(ODS->IdJnl)
// RETURN NIL if jnl == NIL
RETURN NIL if nextkey() != 0
if wwin[WIN_WAITKEY] == 1
  RETURN ClearWaitWin(wwin) if jnl == NIL
  open area b, oArt()
    edit data b key   ODL->IdJnl + ODL->IdDoc ;
                value ODS->IdJnl + ODS->IdDoc ;
                mode  wait ;
                window wwin ;
                start top ;
                query "ODL" + jnl[JNL_IDDBV]
  close area
elseif wwin[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
endif
RETURN NIL

#endif DEF_ODS

#ifdef DEF_MVS

**
** ArtMvsEdit() -
**
FUNCTION ArtMvsEdit(cIdArt)
local b := oMvs()
open area b, oPar(), oArt()
  ddSetOrder(ORD_MVS_ART)
  edit data b key MVS->IdArt ;
    value    cIdArt        ;
    start    bottom                 ;
    mode     find  ;
    query ("MVSART") ;
    title ("Lagerhistorik " + trim(SayIdArt(cIdArt)))
close area
RETURN MnuDone()

**
** DocMvsEdit()
**
FUNCTION DocMvsEdit( cIdJnl, cIdDoc )
local b := oMvs()
open area b, oArt(), oPar()
  ddSetOrder(ORD_MVS_DOC)
  edit data b key MVS->IdJnl + MVS->IdDoc              ;
              value cIdJnl+cIdDoc                      ;
              start    bottom                          ;
              mode     find                            ;
              query    "MVSDOC" ;
              title (cIdJnl + " " + cIdDoc + " : Lagerhistorik")
close area
RETURN MnuDone()


#endif DEF_MVS

FUNCTION MsgInhalt()
#ifdef LG_FRENCH
  RETURN "Contenu de "
#else
  RETURN "Inhalt "
#endif

#ifdef DEF_SER

**
** SerVnlEdit()
**
FUNCTION SerVnlEdit(cIdSer)
local b := oVnl(DocStatClosed())
RETURN .f. if ! ArtVnlInit()
open area b, oArt(), oVen(), oPar()
  ddSetOrder(ORD_VNL_IDSER)
  edit data b key FIELD->IdSer ;
              value    cIdSer      ;
              start    top                          ;
              mode     find                            ;
              query    "VNLSER" ;
              title (cIdSer + " : Fakturationsdokumente")
close area
RETURN .f.

**
** ArtSerEdit()
**
FUNCTION ArtSerEdit(cIdArt)
local b := oSer()
* SerInit()
open area b, oArt(), oPar()
  ddSetOrder(ORD_SER_ART)
  edit data b key SER->IdArt ;
              value    cIdArt      ;
              start    bottom                          ;
              mode     find                            ;
              query    "SERART" ;
              title ( trim(ArtName(cIdArt)) + MSG_SER() )
close area
RETURN .f.

FUNCTION MSG_SER ; RETURN " : Stckliste"

**
** SerCreate()
**
FUNCTION SerCreate(cIdArt,dDate,cIdSer)
local nCreate := DDCREATE_REFRESH
default cIdSer to SER->IdSer
if eof() // 20070801 recno() == lastrec() + 1
  nCreate := DDCREATE_EDIT
endif
*if cIdDoc != NIL
*  if cLine == NIL
*    cLine := SER->Line
*    KeyGoBottom( cIdJnl + cIdDoc, {|| SER->IdJnl + SER->IdDoc } )
*    if empty(cLine)
*      cLine := NextNum(SER->Line)
*    else
*      do while .t.
*        if SER->Line >= cLine
*          if ddRecLock()
*            SER->Line := NextNum(SER->Line)
*            unlock record
*          endif
*        else
*          exit
*        endif
*        skip -1
*        if bof() .or. SER->IdDoc != cIdDoc .or. SER->IdJnl != cIdJnl
*          exit
*        endif
*      enddo
*    endif
*  endif
*endif
RETURN DDCREATE_FAIL if ! dbAddRec()
SetMsg(cIdSer + " : neue Seriennummer wurde eingetragen.")
* if cIdDoc != NIL
*   SER->IdJnl    := cIdJnl
*   SER->IdDoc    := cIdDoc
*   SER->Line     := cLine
*   SER->Date     := dDate
* else
  SER->Date     := UserDate()
* endif
SER->IdSer := cIdSer
SerValidate(cIdSer)
if cIdArt != NIL ; SER->IdArt := cIdArt ; endif
* unlock record
RETURN nCreate


#endif DEF_SER

#ifdef LG_GERMAN
FUNCTION MsgBleibt() ; RETURN "bleibt zu buchen"
#endif
#ifdef LG_FRENCH
FUNCTION MsgBleibt() ; RETURN "reste … saisir"
#endif
#ifdef LG_EN
FUNCTION MsgBleibt() ; RETURN "missing amount"
#endif


FUNCTION ClearWaitWin(wwin)
DispBox( ;
  wwin[WIN_TOP], ;
  wwin[WIN_LEFT] + 1, ;
  wwin[WIN_TOP] + wwin[WIN_HEIGHT] - 1, ;
  wwin[WIN_LEFT] + wwin[WIN_WIDTH], ;
  space(9), CfgWaitColor() ;
)
RETURN NIL

FUNCTION LngIndex(cIdLng)
RETURN 1 if cIdLng == MemLang1
RETURN 2 if cIdLng == MemLang2
RETURN 3 if cIdLng == MemLang3
#ifdef DEF_4LANG
RETURN 4 if cIdLng == MemLang4
#endif
RETURN 0

*FUNCTION ShowWait(ad,wwin)
*local i
*RETURN NIL if nextkey() != 0
*for i := 1 to len(ad[AD_]
*a :=
*elseif wwin[WIN_WAITKEY] == 1
*  if empty(GRA->IdQry)
*    cIdQry := "ARTGRA"
*  else
*    cIdQry := "ART" + trim(GRA->IdQry)
*  endif
*  b := oArt()
*  open area b
*    ddSetOrder ORD_ART_GRA
*    edit data b key    ART->iGra ;
*                value  cIdGra ;
*                mode   wait ;
*                window wwin ;
*                start  top ;
*                filter  "!'"+ARTATTR_H+"' $ ART->Attrib" ;
*                query "ARTGRA"
*  close area
*endif
*RETURN NIL



