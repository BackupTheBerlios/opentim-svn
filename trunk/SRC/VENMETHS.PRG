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
  static MSG_VNAPICK := " : recopier imputations"
#else
  #ifdef DEF_VNA
    static MSG_VNAPICK   := " : Buchungen bernehmen"
    * static MSG_ABBRECHEN := " : Eingabe abbrechen (J/N) ?"
  #endif DEF_VNA
  #ifdef DEF_HOLZ
    static LEG_STMTAG := "[Leertaste] Ausw„hlen [*] Umkehren [Escape] Abbrechen [Enter] Weiter"
    static MSG_STMCOPY := "Baumst„mme bernehmen"
  #endif DEF_HOLZ
#endif

static scIdJnl := ""
static saAboUpdate
static saAfterClose

**
** PROCEDURE_SECTION  - (...grins)
**


#ifdef DEF_VEN

#define MSG_DEV_JNL " : unerlaubte W„hrung im Journal "

**
** VenPreEdit()
**
FUNCTION VenPreEdit(cMsg)
RETURN .t. if VEN->Etat == DocStatOpen()
RETURN .t. if VEN->Etat == DocStatNew()
SetMsg(VEN->IdJnl + " " + VEN->IdDoc + MsgIsClosed(), cMsg,"WRN053")
RETURN .F.

**
** VenPostEdit()
**
FUNCTION VenPostEdit
local cIdDev := JnlIdDev(VEN->IdJnl)
local jnl := JnlLocate(VEN->IdJnl)
RETURN .f. if jnl == NIL
RETURN .f. if ! ParExist(VEN->IdPar)
if ! empty(cIdDev)
  if VEN->IdDev != cIdDev
    RETURN ! SetMsg(VEN->IdDev + MSG_DEV_JNL + VEN->IdJnl,NIL,"WRN029")
    * Warning(VEN->IdDev + MSG_DEV_JNL + VEN->IdJnl,NIL,"WRN029")
    * RETURN .f.
  endif
endif
RETURN .f. if ! CheckIdDoc(jnl,VEN->IdDoc,VEN->Periode)
*   Warning(MsgIdJnlDoc() + " : " + SetMsg())
*   RETURN .f.
* endif
if !empty(PAR->IdDev) .and. PAR->IdDev != DevDefault(VEN->Periode)
  if VEN->IdDev != PAR->IdDev .and. VEN->IdDev != DevDefault(VEN->Periode)
    RETURN Confirm( ;
      VEN->IdDev + " : ungltige W„hrung fr " + trim(ParName()), ;
      MsgSure(), MSG_NO, "WRN030" ;
    )
  endif
endif
* RETURN .f. if ! OnVenPostEdit()
* if VEN->Etat == DocStatNew()
*   if nKey == K_ENTER .or. nKey == K_F10 .or. nKey == K_PGDN
*     VenDetail()
*   endif
* endif
RETURN .t. // OnVenPostEdit() jetzt in AD_ONPOSTEDIT

FUNCTION VenSetEtat(cEtat)
if VEN->Etat != DocStatClosed()  // W„re nur n”tig wegen WRITE...!
  VEN->Etat := cEtat
  ddRefreshCurrent() // ph_refresh()
endif
RETURN .T.

**
** VenParValidate() : field VEN->IdPar
**
FUNCTION VenParValidate(jnl,ifc,lRefresh,cIdMfc)
local cIdDev := VEN->IdDev
RETURN .f. if ! ParExist(VEN->IdPar)
RETURN .f. if ! OnParSelect()
#ifdef DEF_TAX
VEN->IdReg := PAR->IdReg
#endif
default cIdMfc to VenMfcDefault()
* if cIdMfc == NIL .and. DoParMfcDefault()
*   cIdMfc := ParMfcDefault(VEN->IdJnl)
* endif
if cIdMfc != NIL
  VEN->IdMfc := cIdMfc
  VenMfcValidate(jnl,ifc,.f.)
endif
if empty(VEN->Mont)
  if empty(PAR->IdDev)
    VEN->IdDev := JnlIdDev(VEN->IdJnl)
    if empty(VEN->IdDev)
      VEN->IdDev := DevDefault(VEN->Periode)
    endif
  else
    VEN->IdDev := PAR->IdDev
  endif
  if VEN->IdDev != cIdDev
    VenDevValidate()
  endif
endif
RETURN .f. if ! OnVenParValidate()
default lRefresh to .t.
if lRefresh
  ddRefreshCurrent()
endif
RETURN .t.

FUNCTION VenPar2Validate()
RETURN .t. if empty(VEN->IdPar2)
RETURN .f. if ! ParExist(VEN->IdPar2)
ddRefreshCurrent() // ph_refresh()
RETURN .t.

**
**
FUNCTION VenMatchValidate()
local nMont := 0
local nMontDev := 0
local cDC := VEN->DC
local cMatch := VEN->Match
local cIdPar := VEN->IdPar
local cIdDev := VEN->IdDev
RETURN .t. if empty(VEN->Match)
* RETURN .t. if !empty(VEN->Mont)
open area oHst(), oPar(), oGen(), oFin(), oVen()
  ddSetOrder(ORD_HST_PARMATCH)
  seek cIdPar + cMatch
  do while HST->IdPar+HST->Match == cIdPar+cMatch
    if HST->DC == cDC
      nMont    -= HstMont(cIdDev)
    else
      nMont    += HstMont(cIdDev)
    endif
    skip
  enddo
close area
VEN->Mont := ntom(nMont)
RETURN .t.

FUNCTION VenMfcValidate(jnl,ifc,lRefresh)
local dDate := VEN->Date
default jnl to JnlLocate(VEN->IdJnl)
default lRefresh to .f.
RETURN .t. if jnl == NIL
default ifc to IfcLocate(jnl[JNL_IDCTR],VEN->IdJnl,VEN->IdMfc)
if ifc == NIL
  SetMsg(VEN->IdJnl + " & " + VEN->IdMfc + MsgIfcFail(), NIL, "WRN024" )
  RETURN .f.
endif
if ! empty(ifc[IFC_DELAI])
  if left(ifc[IFC_IDMFC],1) == IDMFC_ANY
    dDate += val(VEN->IdMfc)
  else
    dDate += val(ifc[IFC_DELAI])
    if IFCATTR_M $ ifc[IFC_ATTRIB]
      dDate := LastOfMonth(dDate)
    endif
  endif
  if IFCATTR_W $ ifc[IFC_ATTRIB]
    do while dow(dDate) == 1 .or. dow(dDate) == 7
      dDate++
    enddo
  endif
  VEN->DatEch  := dDate
endif
if ! empty(ifc[IFC_IDREG])
  VEN->IdReg := ifc[IFC_IDREG]
endif
if lRefresh
  ddRefreshCurrent()
endif
RETURN .t.

**
** VenValDate() : fields VEN->Date, VEN->Periode, VEN->IdMfc
**
FUNCTION VenValDate()
RETURN .f. if ! DocDateValidate(PAR->IdDev)
RETURN .t. if ! VenMfcValidate(NIL,NIL,.t.)
RETURN .t.

**
** VenDevValidate() : fields VEN->IdDev
**
FUNCTION VenDevValidate()
local lOkay := .f.
local lConfirm := .t.
local jnl
local a
if empty(VEN->IdDev)
  VEN->IdDev  := PAR->IdDev
  if empty(VEN->IdDev)
    VEN->IdDev  := JnlIdDev(VEN->IdJnl)
  endif
  if empty(VEN->IdDev)
    VEN->IdDev  := DevDefault(VEN->Periode)
  endif
endif
RETURN .f. if ! DocDevValidate()
if (jnl := JnlLocate(VEN->IdJnl)) != NIL
  if (a := VenVnlInit(jnl)) != NIL
    open area oVnl(DocStatOpen()), oArt(), oGen(), oVna()
      lOkay := .t.
      softseek VEN->IdJnl + VEN->IdDoc
      do while lOkay .and. !eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                                  .and. FIELD->IdJnl == VEN->IdJnl
        if TaskInter() ; lOkay := .f. ; exit ; endif
        if lConfirm
          if Confirm(MsgDevValidate())
            lConfirm := .f.
          else
            lOkay := .f.
            exit
          endif
        endif
        if ! VnlReset(VNLRESET_PU)
          lOkay := .f.
          exit
        endif
        skip
      enddo
    close area
    if lOkay
      VenVnlUpdate(jnl)
    endif
    VnlRestore(a)
  endif
endif
RETURN ddRefreshCurrent() // ph_refresh()

FUNCTION MsgDevValidate()
#ifdef LG_GERMAN
  RETURN "Artikelpreise im Dokument neu rechnen (J/N) ?"
#else
  RETURN "Recalculer les prix dans le document (O/N) ?"
#endif
RETURN .t.

* delete current VEN without confirmation
* wird benutzt im SPZ, wenn deie Abrechnung abgebrochen wird
FUNCTION VenKill()
RETURN .f. if ! VenPreDelete(.f.)
RETURN .f. if ! ddRecLock()
delete
unlock record
RETURN .t.

**
**
FUNCTION VenPreDelete(lConfirm)
local lOkay := .f. // nReturn := DDDEL_FAIL
local cIdJnl := VEN->IdJnl
local cIdDoc := VEN->IdDoc
local nRecNo
local jnl := JnlLocate(VEN->IdJnl)
if jnl == NIL
  RETURN .f. if ! USRATTR_E $ UsrAttrib()
  RETURN ConfirmDelete()
endif
RETURN .f. if ! VenPreEdit()
RETURN .f. if ! DocDelete(jnl,VEN->IdDoc,lConfirm)
#ifdef DEF_HOLZ
  open area oStm()
    ddSetOrder(StmOrder(cIdJnl))
    softseek cIdDoc
    do while ! eof() .and. &("STM->"+cIdJnl+"IdDoc") == cIdDoc
      skip
      nRecNo := recno()
      skip -1
      if ddRecLock()
        &("STM->"+cIdJnl+"IdDoc") := ""
        &("STM->"+cIdJnl+"Line") := ""
        unlock record
      endif
      goto nRecNo
    enddo
  close area
#endif DEF_HOLZ
open area oVnl(VEN->Etat)
  lOkay := .t. // nReturn := DDDEL_NOCONFIRM
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdJnl + FIELD->IdDoc == VEN->IdJnl + VEN->IdDoc
    if ddRecLock()
      delete
      unlock record
    else
      lOkay := .f. // nReturn := DDDEL_FAIL
    endif
    skip
  enddo
close area
#ifdef DEF_MVA
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oMva()
    ddSetOrder ORD_MVA_DOC
    lOkay := .t. // nReturn := DDDEL_NOCONFIRM
    softseek VEN->IdJnl + VEN->IdDoc
    do while ! eof() .and. MVA->IdJnl + MVA->IdDoc == VEN->IdJnl + VEN->IdDoc
      if ddRecLock()
        delete
        unlock record
      else
        lOkay := .f. // nReturn := DDDEL_FAIL
      endif
      skip
    enddo
  close area
#endif DEF_MVA
RETURN lOkay // nReturn

**
** VenDetail()
**
FUNCTION VenDetail()
local jnl := JnlLocate(VEN->IdJnl)
local ifc
local a
RETURN .f. if jnl == NIL
if ! RecIsValid()
  ddEditChange(.t.)
  RETURN .f.
endif
if (ifc := IfcLocate(jnl[JNL_IDCTR],VEN->IdJnl,VEN->IdMfc)) == NIL
  Warning(VEN->IdJnl + " & " + VEN->IdMfc + MsgIfcFail() )
  RETURN .f. // SetMnuDone()
endif
RETURN .f. if ! ddRecLock()
if (a := VenVnlInit(jnl)) == NIL
  Warning(MsgIdJnlDoc() + " : " + SetMsg())
else
  #ifdef DEF_HOLZ   // [971204] VenStmEdit() wurde bisher vor dem
                    // VenVnlInit() aufgerufen und PAR wurde zu Fuá
                    // positioniert...
    if JNLATTR_D $ jnl[JNL_ATTRIB]
      VenStmEdit()
    endif
  #endif DEF_HOLZ
  if VenVnlEdit(jnl,ifc)
    if VEN->Etat != DocStatClosed()
      if VenVnlUpdate(jnl)
        VEN->Etat := DocStatOpen()
        if nextkey() == 0
          ddRefreshCurrent()
        endif
        if ddLastKey() == K_F10
          VenDlgClose(jnl,.t.)
        endif
      else
        VEN->Etat := DocStatNew()
        if nextkey() == 0
          ddRefreshCurrent()
        endif
      endif
    endif
  elseif VEN->Etat != DocStatClosed()
    VEN->Etat := DocStatNew()
    ddEditChange(.t.)
  endif
  VnlRestore(a)
  // SetMnuDone() 19990915
endif
unlock record
RETURN .t.

**
** VenVnlEdit() - siehe auch VenVnlWait()
**
FUNCTION VenVnlEdit(jnl,ifc)
local lHasRecords := .f.
local cIdJnl := VEN->IdJnl
local cIdDoc := VEN->IdDoc
local b := oVnl(VEN->Etat)
local a := VnlSave()
* local xlVnaFilter := ".t."
* #ifdef DEF_VNA
*   local xlVnaFilter := VnaCopyFilter()
*   * local lVnaSuggest := .t.
* #else
*   local xlVnaFilter := ".t."
* #endif DEF_VNA
open area b, oArt(), oGen(), oSpc(), oVen(), oGra(), oNew(), oVna(), oDls(), oAna()
  softseek cIdJnl + cIdDoc
  do while ! eof() .and. FIELD->IdJnl == cIdJnl ;
                   .and. FIELD->IdDoc == cIdDoc
    lHasRecords := .t.
    * #ifdef DEF_VNA
    *   if !empty(VNL->Match)
    *     lVnaSuggest := .f.
    *   endif
    * #endif DEF_VNA
    VnlAfter()
    skip
  enddo
  if VEN->Etat == DocStatNew() .and. ! lHasRecords
    VnlFill(jnl,ifc) // ,xlVnaFilter)
  endif
  edit data b       ;
            key    FIELD->IdJnl + FIELD->IdDoc ;
            value  cIdJnl + cIdDoc  ;
            create {||VnlCreate(cIdJnl,cIdDoc,FIELD->Line)} ;
            before VnlBefore() ;
            after  VnlAfter() ;
            start top  ;
            mode   edit ;
            query  ("VNL" + jnl[JNL_IDDBV]) ;
            title (MsgInhalt() + cIdJnl + " " + cIdDoc)
close area
VnlRestore(a)
RETURN .t. if ddLastKey() == K_F10
RETURN .f.

#ifdef DEF_VNA

STATIC FUNCTION has_selected(a)
local i
for i := 1 to len(a)
  RETURN .t. if a[i][VNA_TAGGED]
next i
RETURN .f.

#endif DEF_VNA

STATIC FUNCTION VnlFill(jnl,ifc,xlVnaCopyFilter)
local aPnf := {}
local aVna
local pnf := NIL
local cNB1 := ""
#ifdef DEF_VNA
  if JNLATTR_A $ jnl[JNL_ATTRIB]
    RETURN .f. if ! PnfCollect(aPnf,jnl,VEN->IdPar,VEN->IdPar,VEN->Date) // ,xlVnaFilter)
    RETURN .f. if len(aPnf) == 0
    if len(aPnf) == 1 .or. IFCATTR_X $ ifc[IFC_ATTRIB] 
      // no ParPnfPick dialog
      pnf := aPnf[1]
      RETURN .f. if !VnaTag( ;
          pnf[PNF_AVNA],;
          pnf[PNF_IDPAR],;
          trim(ParName(pnf[PNF_IDPAR])) + " : " + MsgVnaTag(), ;
          jnl[JNL_IDJNL];
        )
    else
      do while .t.
        pnf := ParPnfPick(aPnf,pnf,;
          "R‚f‚rences externes "+trim(ParName()))
        RETURN .f. if pnf == NIL
        if VnaTag( ;
          pnf[PNF_AVNA],;
          pnf[PNF_IDPAR],;
          trims(pnf[PNF_MATCH]," (",")") + " : " + MsgVnaTag(), ;
          jnl[JNL_IDJNL];
        )
          if has_selected(pnf[PNF_AVNA])
            cNB1 := pnf[PNF_MATCH]
            exit
          else
            SetMsg("You must select at least one detail line...")
          endif
        endif
      enddo
    endif
    if !empty(cNB1)
      VEN->NB1 := cNB1
    endif
    RETURN .f. if ! VenVnlGenerate(pnf[PNF_AVNA],jnl,ifc,VEN->DC)
    if ! IFCATTR_U $ ifc[IFC_ATTRIB]
      RETURN .f. if ! VenVnlReset(VNLRESET_PU)
    endif
    RETURN .t.
  endif
#endif DEF_VNA
if JNLATTR_T $ jnl[JNL_ATTRIB].and.!empty(VEN->Mont)
  if !empty(PAR->IdGen)
    aVna := {}
    NafCollect(aVna,;
      NIL,NIL,NIL,ctod(""),;
      PAR->IdGen,LNCODE_GEN,"","","","",.t.,"","","","","",;
      VEN->DC,.f.,NIL,NIL,NIL,VEN->Mont)
    VenVnlGenerate(aVna,jnl,ifc,VEN->DC)
  endif
endif
RETURN .t.

*FUNCTION VenMdiFill(jnl,ifc)
*local aVna := {}
*local cIdMdi := VenMdiLocate()
*local cIdDoc
*local nMult := 1
*local a
*RETURN .f. if cIdMdi == NIL
*RETURN .f. if ! HasRecords(oVen(),ORD_VEN_PAR,;
*  "VEN->IdPar+VEN->IdJnl",VEN->IdPar+cIdMdi)
**
*a := DbfPick({oVen(),oPar()},;
*  tr("Select a booking template",;
*  "Buchungsvorlage ausw„hlen",;
*  "S‚lection modŠle d'imputation"),;
*  "VENMDI",NIL,NIL,VEN->IdPar+cIdMdi,"VEN->IdPar+VEN->IdJnl",;
*  "{VEN->IdDoc,val(VEN->Mont)}")
*RETURN .f. if a== NIL
*cIdDoc := a[1]
*if !empty(VEN->Mont)
*  nMult := val(VEN->Mont)/a[2]
*endif
*open area oVnl()
*  softseek cIdMdi+cIdDoc
*  do while !eof() .and. VNL->IdDoc==cIdDoc .and. VNL->IdJnl==cIdMdi
*    NafCollect(aVna,;
*      NIL,NIL,NIL,ctod(""),;
*      VNL->IdArt,VNL->Code,VNL->Qte,VNL->Desig,VNL->Memo,VNL->PrixU,;
*      .t.,"","","","",VNL->Attrib,;
*      VEN->DC,.f.,NIL,NIL,NIL,ntom(VnlTvac()*nMult))
*    skip
*  enddo
*close area
*RETURN VenVnlGenerate(aVna,jnl,ifc,VEN->DC)



* FUNCTION VenDlsFill(jnl,ifc)
* local aVna := {}
* local cIdMdi := VenMdiLocate()
* local cIdDoc
* local nMult := 1
* local a
* RETURN .f. if !DlgExec("PARAUTO")
* RETURN .f. if a== NIL
* cIdDoc := a[1]
* aVna := UsrDlsCollect()
* aVna := ParDlsCollect()
* RETURN VenVnlGenerate(aVna,jnl,ifc,VEN->DC)

* FUNCTION VenVnlFill(bCollect,jnl,ifc,xlVnaFilter)
* RETURN VenVnlGenerate(aVna,jnl,ifc,VEN->DC)


**
** VenWait()
**
FUNCTION VenWait(wwin)
local b
local cIdJnl := VEN->IdJnl
local cIdDoc := VEN->IdDoc
if nextkey() != 0
  RETURN NIL
elseif wwin[WIN_WAITKEY] == 1
  RETURN VenVnlWait(cIdJnl,cIdDoc,wwin)
                                                  #ifdef DEF_VNA
elseif wwin[WIN_WAITKEY] == 12
  RETURN VenVenWait(wwin)
                                                  #endif DEF_VNA
                                                  #ifdef DEF_MEMO
elseif wwin[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
                                                  #endif DEF_MEMO
endif
RETURN .f.


FUNCTION VenPrePrint()
local nSelect := select()
RETURN .t. if VEN->Etat == DocStatClosed()
select VEN
VenClose(.f.,.t.)
select (nSelect)
RETURN .t. if VEN->Etat == DocStatClosed()
RETURN Confirm(MsgIdJnlDoc() + MsgNotClosed(),;
  utr("Print it anyway (Y/N)?","Trotzdem drucken (J/N)?","Imprimer quand-mˆme (O/N)?"))
*Warning(MsgIdJnlDoc() + MsgNotClosed())
*RETURN .f.

**
** VnlWait()
**
FUNCTION VnlWait(win)
local b
if nextkey() != 0
  RETURN NIL
                                                  #ifdef DEF_REMISE
elseif win[WIN_WAITKEY] == 7
  VnlRpqDisplay(win)
                                                  #endif DEF_REMISE
                                                  #ifdef DEF_MEMO
elseif win[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Memo, ;
    win[WIN_TOP], ;
    win[WIN_LEFT], ;
    win[WIN_HEIGHT], ;
    win[WIN_WIDTH] ;
  )
                                                  #endif DEF_MEMO
endif
RETURN .f.



**
** VenVnlWait() - siehe auch VenVnlEdit()
**
FUNCTION VenVnlWait(cIdJnl,cIdDoc,wwin)
local b := oVnl(VEN->Etat)
local jnl := JnlLocate(VEN->IdJnl)
local a
RETURN ClearWaitWin(wwin) if jnl == NIL
RETURN NIL if empty(VEN->IdPar)
RETURN NIL if (a := VenVnlInit(jnl)) == NIL
open area b, oArt(), oGen(), oVen(), oBud(), oVna(), oDls()
  softseek cIdJnl + cIdDoc
  do while ! eof() .and. FIELD->IdJnl == cIdJnl ;
                   .and. FIELD->IdDoc == cIdDoc
    VnlAfter()
    skip
  enddo
  edit data b  ;
            key FIELD->IdJnl + FIELD->IdDoc ;
            value cIdJnl + cIdDoc ;
            mode wait   ;
            window wwin ;
            start top ;
            query ("VNL"+ jnl[JNL_IDDBV])
close area
VnlRestore(a)
RETURN NIL


**
** ParVenEdit() - Documents vente d'un client
**
FUNCTION ParVenEdit(cIdPar)
local b
local a := JnlList({|j|IsJnlParEdit(j)})
local jnl
do while (jnl := PickJnl(NIL,scIdJnl,a,trim(ParName()) + " : Fakturation")) != NIL
  #ifdef DEF_VEN
    if jnl[JNL_ALIAS] == JNLALIAS_VEN
      b := oVen()
      scIdJnl := jnl[JNL_IDJNL]
      open area b, oPar()
        ddSetOrder(ORD_VEN_PAR)
        edit data b key VEN->IdPar + VEN->IdJnl  ;
          value    cIdPar + jnl[JNL_IDJNL]        ;
          start    bottom                 ;
          mode     find  ;
          query    ("VEN" + jnl[JNL_IDDBV]) ;
          create   {|| DocCreate( jnl, {|cIdDoc| VenDocCreate(jnl,cIdDoc,cIdPar) } ) } ;
          title (trim(ParName()) + " : " + jnl[JNL_IDJNL] + " " + jnl[JNL_NAME])
      close area
    endif
  #endif DEF_VEN
  #ifdef DEF_ODS
    if jnl[JNL_ALIAS] == JNLALIAS_ODS
      b := oOds()
      scIdJnl := jnl[JNL_IDJNL]
      open area b, oPar()
        ddSetOrder(ORD_ODS_PAR)
        edit data b key ODS->IdPar + ODS->IdJnl  ;
          value    cIdPar + jnl[JNL_IDJNL]        ;
          start    bottom                 ;
          mode     find  ;
          query    ("ODS" + jnl[JNL_IDDBV]) ;
          create   {||ParOdsCreate(cIdPar,jnl)} ;
          title (trim(ParName()) + " : " + jnl[JNL_IDJNL] + " " + jnl[JNL_NAME])
      close area
    endif
  #endif DEF_ODS
enddo
RETURN MnuDone()

FUNCTION IsJnlParEdit(jnl)
if jnl[JNL_ALIAS] == JNLALIAS_VEN
  RETURN (PAR->IdPrt $ CtrPrtList(jnl[JNL_IDCTR]))
endif
#ifdef DEF_ODS
  RETURN .t. if jnl[JNL_ALIAS] == JNLALIAS_ODS
#endif
RETURN .f.


* FUNCTION ParVenCreate(cIdPar,jnl)
* RETURN DocCreate( jnl, {|cIdDoc| VenCreate(jnl,cIdDoc,cIdPar) } )

FUNCTION VenCreate(cIdPar,cIdJnl,cTitle)
local jnl
if cTitle != NIL
  jnl := PickJnl(JNLALIAS_VEN,VEN->IdJnl,NIL,cTitle)
else
  jnl := JnlLocate(cIdJnl)
endif
RETURN DDCREATE_FAIL if jnl == NIL
RETURN DocCreate( jnl, {|cIdDoc| VenDocCreate(jnl,cIdDoc,cIdPar) } )

FUNCTION VenClose(lRefresh,lConfirm)
local a
local jnl := JnlLocate(VEN->IdJnl)
local lOkay := .f.
if (a := VenVnlInit(jnl)) != NIL
  lOkay := VenDlgClose(jnl,lRefresh,lConfirm)
  VnlRestore(a)
else
  Warning(MsgIdJnlDoc() + " : " + SetMsg())
endif
// SetMnuDone()
RETURN lOkay

FUNCTION MsgSetError()
RETURN "Mark this document as broken (Y/N) ?"

FUNCTION VenDlgClose(jnl,lRefresh,lDlg)
local cIdMfc := VEN->IdMfc
local ifc
RETURN .f. if jnl == NIL
default lRefresh to .t.
default lDlg to lRefresh
if VEN->Etat == DocStatError()
  if USRATTR_E $ UsrAttrib()
    RETURN .f. if ! Confirm( ;
      MsgIdJnlDoc() + ;
      ": Dokument wurde nicht korrekt registriert.", ;
      MsgSure() ;
    )
    VEN->Etat := DocStatNew()
    SendConsole(MsgIdJnlDoc() + " : " + MsgDocStatError() + " removed.")
  else
    #ifdef LG_GERMAN
    SetMsg("Benachrichtigen Sie Ihren Systemverwalter !")
    #endif
    #ifdef LG_FRENCH
    SetMsg("Veuillez contacter votre administrateur TIM !")
    #endif
    #ifdef LG_EN
    SetMsg("Please contact your TIM administrator !")
    #endif
    RETURN .f.
  endif
endif
if VEN->Etat == DocStatNew()
  if VenVnlUpdate(jnl)
    VEN->Etat := DocStatOpen()
  endif
endif
if VEN->Etat == DocStatOpen()
  if lDlg
    // ignore DocIsChrono() when closing in batch mode
    RETURN .f. if ! CheckIdDoc(jnl,VEN->IdDoc,VEN->Periode)
    if JNLATTR_F $ jnl[JNL_ATTRIB]
      if ! DocIsChrono(jnl)
        Warning(SetMsg(),MsgIdJnlDoc()+MsgCloseFail())
        RETURN .f.
      endif
    endif
  endif
  if lDlg .and. JNLATTR_E $ jnl[JNL_ATTRIB]
    if (cIdMfc := PickIfc(cIdMfc,VEN->IdJnl,VEN->IdJnl + " " + VEN->IdDoc)) == NIL
      RETURN .f.
    endif
  endif
  if (ifc := IfcLocate(jnl[JNL_IDCTR],VEN->IdJnl,cIdMfc)) == NIL
    if lDlg
      Warning( ;
        VEN->IdJnl + " & " + cIdMfc + MsgIfcFail(), ;
        MsgIdJnlDoc() + MsgCloseFail(), "WRN024" )
    endif
    RETURN .f.
  endif
  RETURN .f. if ! PerSetDirty(jnl,VEN->Periode,VEN->Date,VEN->IdDoc,lDlg)
  VEN->IdMfc := cIdMfc
  **
  RETURN .f. if ! OnVenClose()
  ** Fr die Best„tigung muss die vorher gew„hlte Zahlart natrlich
  ** schon am Bildschirm sichtbar sein. Sonst wundert sich der Benutzer...
  if lDlg // ! USRATTR_Y $ UsrAttrib()
    if lRefresh .and. nextkey() == 0
      ddRefreshCurrent()
    endif
    if ! Confirm( ;
      MsgIdJnlDoc() + MsgClose(), NIL, ;
      MSG_YES, "WRN011" ;
    )
      RETURN .f.
    endif
  endif
  if VenDoClose(jnl,ifc,lRefresh) // ,aCtp,aCtg,aHsi,aCta)
    SetMsg( VEN->IdJnl + " " + VEN->IdDoc + MsgCloseOkay() )
  elseif lDlg
    Warning( SetMsg(), MsgIdJnlDoc() + MsgCloseFail() )
  endif
elseif VEN->Etat == DocStatClosed()
  RETURN !SetMsg(MsgNoAccess()) if ! USRATTR_S $ UsrAttrib()
  if ! PreDocUndo()
    RETURN .f.
  endif
  if ! PerSetDirty(jnl,VEN->Periode,NIL,VEN->IdDoc,lDlg)
    RETURN .f.
  endif
  ifc := IfcLocate(jnl[JNL_IDCTR],VEN->IdJnl,VEN->IdMfc)
  * if USRATTR_Y $ UsrAttrib() .or. Confirm( ;
  if !lDlg .or. Confirm( ;
    MsgIdJnlDoc() + MsgUndo(), MsgSure(), MSG_YES,"WRN002" ;
  )
      if ! OnVenClose()
        * if Confirm(MsgIdJnlDoc()+": "+SetMsg(),MsgSetError())
        *   VEN->Etat := DocStatError()
        * endif
        RETURN .f.
      endif
      if VenUndo(jnl,ifc,lDlg) // ,aCtp,aCtg,aCta)
        SetMsg( MsgIdJnlDoc() + MsgUndoDone() )
      else
        if lDlg
          Warning(SetMsg(),MsgIdJnlDoc() + MsgUndoFail())
        endif
      endif
  endif
  if lRefresh .and. nextkey() == 0
    ddRefreshCurrent()
  endif
endif
RETURN .t.

FUNCTION MsgDocStatError() ; RETURN " : DocStatError()"

FUNCTION MustAboUpdate(cMatch) // called by OnVnlClose for PAC
DictAddItem(saAboUpdate,cMatch)
RETURN .t.

FUNCTION MustAfterClose(blEvent) // called by OnVnlClose for PAC
RETURN .t. if blEvent == NIL
aadd(saAfterClose,blEvent)
RETURN .t.


**
** called from VenDlgClose()
**             ParVenAppend()
**
FUNCTION VenDoClose(jnl,ifc,lDlg,cPreview)
local aCtp := {}
local aCtg := {}
local aHsi := {}
local aCta := {}
local aVna := {}
// local aVnaUpdate := {}
local aMva := {}
local aMvs := {}
local aCts := {}
local aQts := {}
local aMvt := {}
local aVnl := {}
local aAfter := {}
local lOkay
local i
saAboUpdate := {}
saAfterClose := {}
RETURN .f. if ! VenPreClose(jnl,ifc,aMvt,aMvs,aCts,aQts,;
                            aVna,aHsi,aVnl,aMva,aAfter)
*#ifdef DEF_ANA
*  MvaGenerate(aMva,VEN->IdJnl,VEN->IdDoc,VEN->Periode)
*  RETURN .f. if ! OdaPreClose( ;
*    aCta,VEN->IdJnl,VEN->IdDoc,VEN->IdPar,VEN->Periode ;
*  )
*#endif DEF_ANA
#ifdef DEF_VNA
  RETURN .f. if ! VnaScan(jnl,aVna,.f.)
  * aVna := VnaScan(jnl,aVna,.f.) // ,aVnaUpdate)
  * RETURN .f. if aVna == NIL
#endif DEF_VNA
** ab jetzt wird's ernst... jetzt gibt es kein zurck mehr...
** (falls wohl, wird DocStatError() gesetzt)
*#ifdef DEF_VNLALT
*  lOkay := .f.
*  open area oVnl(DocStatClosed())
*    lOkay := .t.
*    for i := 1 to len(aVnl)
*      if dbAddRec()
*        PasteRec(aVnl[i])
*        unlock record
*      else
*        lOkay := .f.
*        exit
*      endif
*    next i
*  close area
*  if ! lOkay
*    VEN->Etat := DocStatError()
*    SendConsole(MsgIdJnlDoc() + MsgDocStatError())
*    RETURN .f.
*  endif
*#endif DEF_VNLALT
#ifdef DEF_GEN
  * if len(aMvt) == 0 .and. JNLATTR_G $ jnl[JNL_ATTRIB]
  if len(aMvt) == 0 .and. JnlDoHst(jnl,VEN->Periode)
    * MsgIdJnlDoc() + MsgNoDetail()ÿ
    RETURN .f. if ! Confirm( ;
      MsgIdJnlDoc() + utrp(;
        " : document is empty !",;
        " : Dokument enth„lt keine Buchungen !",;
        " : ce document ne contient aucune imputation !"),;
      MsgSure() ;
    )
  endif
  #ifdef DEF_VENREMISE
    VenMvtRemise(aMvt,jnl)
  #endif
  #ifdef DEF_FRF
    RETURN .f. if ! VenFrfCollect(jnl,aMvt)
  #endif DEF_FRF
  VenMvtRound(aMvt,jnl)
  * #ifdef DEF_ANA
  *   RETURN .f. if ! VenMvaTest()
  * #endif DEF_ANA
  if ! VenHstGenerate( ;
    jnl, ifc, aMvt, aCtp, aCtg, .f. ;
  )
    VEN->Etat := DocStatError()
    SendConsole(MsgIdJnlDoc() + MsgDocStatError())
    RETURN .f.
  endif
#endif DEF_GEN
* if IFCATTR_E $ ifc[IFC_ATTRIB]
  #ifdef DEF_VNA
    if ! VenVnaGenerate( jnl, ifc, aVna )
    * if ! VenVnaGenerate( jnl, ifc, aVna, aVnaUpdate )
      VEN->Etat := DocStatError()
      SendConsole(MsgIdJnlDoc() + MsgDocStatError())
      RETURN .f.
    endif
  #endif DEF_VNA
  #ifdef DEF_MVS
    if JNLATTR_S $ jnl[JNL_ATTRIB]
      if ! VenMvsGenerate( jnl, aMvs )
        VEN->Etat := DocStatError()
        SendConsole(MsgIdJnlDoc() + MsgDocStatError())
        RETURN .f.
      endif
    endif
  #endif DEF_MVS
  #ifdef DEF_CTS
    if ! CtsUpdate(aCts)
      VEN->Etat := DocStatError()
      SendConsole(MsgIdJnlDoc() + MsgDocStatError())
      RETURN .f.
    endif
  #endif DEF_CTS
  #ifdef DEF_STK
    if ! QtsUpdate(aQts,VEN->Date)
      VEN->Etat := DocStatError()
      SendConsole(MsgIdJnlDoc() + MsgDocStatError())
      RETURN .f.
    endif
  #endif DEF_STK
  #ifdef DEF_CTT
    * if JNLATTR_G $ jnl[JNL_ATTRIB]
    if JnlDoHst(jnl,VEN->Periode)
      if ! VenCttUpdate(jnl,aMvt)
        VEN->Etat := DocStatError()
        SendConsole(MsgIdJnlDoc() + MsgDocStatError())
        RETURN .f.
      endif
    endif
  #endif DEF_CTT
  // Beispiel:
  // OnVnlClose : returns NIL or an expression to be executed when
  // document has been closed
  // OnVnlClose iif(!IsArtCode(VNL->Code).or.empty(ART->Months),\
  //      NIL,\
  //      "AboUpdate('"+left(VNL->Match,9)+"','ABO',val(ART->Months))")
  for i := 1 to len(aAfter)
    if ! xparse(aAfter[i])
      VEN->Etat := DocStatError()
      SendConsole(MsgIdJnlDoc() + MsgDocStatError())
      RETURN .f.
    endif
  next i
* endif
for i := 1 to len(saAboUpdate)
  AboUpdate(saAboUpdate[i],VEN->Date)
next i
// 20060824 der Code ab hier wurde bisher vom Caller gemacht (doppelt
// (aber nur fast) von
VEN->Etat := DocStatClosed()
AfterVenClose()
if TIMATTR_Z $ MemAttrib
  #ifdef DEF_CTP
    CtpUpdate(aCtp) // ,NIL,nDbDecPos)
  #endif DEF_CTP
  #ifdef DEF_CTG
    CtgUpdate(aCtg)
  #endif DEF_CTG
  #ifdef DEF_MVA
    CtaUpdate(aCta)
  #endif DEF_MVA
endif
#ifdef DEF_RSV
  if ! VenRsiGenerate(jnl)
    VEN->Etat := DocStatError()
    SendConsole(MsgIdJnlDoc() + " : VenRsiGenerate() failed.")
  endif
#endif DEF_RSV
#ifdef DEF_INT
  if len(aHsi) > 0
    iVenHsiEdit(jnl,aHsi)
  endif
#endif DEF_INT
if VEN->Etat == DocStatClosed()
  if lDlg // .and. nextkey() == 0
    ddRefreshCurrent()
  endif
  if IFCATTR_I $ ifc[IFC_ATTRIB]
    VenDoPrint(jnl,VenIdTpl(ifc),cPreview,lDlg)
  endif
endif
#ifdef DEF_HST
  if JNLATTR_L $ jnl[JNL_ATTRIB]
    ParSatisfy(VEN->IdPar)
  endif
#endif DEF_HST
for i := 1 to len(saAfterClose)
  if ! xparse(saAfterClose[i])
    exit
  endif
next i
dbcommit()
RETURN .t.


FUNCTION AboUpdate(cMatch,dDate)
RETURN .t. if empty(cMatch)
* RETURN .t. if left(cMatch,LenIdJnl()) != cIdJnl
RETURN !SetMsg(cMatch+" : invalid Match") if ! DbfPeek(;
  oVen(),cMatch,{||_AboUpdate(dDate)},.f.)
RETURN .t.

FUNCTION _AboUpdate(dDate)
local nMonths := iif(left(VEN->Cycle,1)=="M",;
                 1,iif(left(VEN->Cycle,1)=="A",12,0))
RETURN .t. if nMonths == 0
RETURN .t. if dDate < VEN->DatEch // Neuregistrieren frhere Rechnung
RETURN .t. if VEN->DatEch >= SkipMonth(dDate,nMonths)
RETURN .f. if ! ddRecLock()
VEN->DatEch := SkipMonth(VEN->DatEch,nMonths)
unlock record
RETURN .t.



**
** VenHstRebuild() called from Rebuild()
**
FUNCTION VenHstRebuild(jnl)
local aMva := {}
local aMvs := {}
local aCts := {}
local aQts := {}
local aVna := {}
local aMvt := {}
local aCtp := {}
local aCtg := {}
local aHsi := {}
local lOkay := .t.
local aAfter := {}
local a
local aVnl := {}
local ifc := IfcLocate(jnl[JNL_IDCTR],VEN->IdJnl,VEN->IdMfc)
if ifc == NIL
  SetMsg(VEN->IdJnl + " & " + VEN->IdMfc + MsgIfcFail())
  RETURN .f.
endif
RETURN .f. if (a := VenVnlInit(jnl)) == NIL
if ! VenPreClose(jnl,ifc,aMvt,aMvs,aCts,aQts,aVna,aHsi,aVnl,aMva,aAfter)
  lOkay := .f.
else
  #ifdef DEF_GEN
    #ifdef DEF_VENREMISE
      VenMvtRemise(aMvt,jnl)
    #endif
    #ifdef DEF_FRF
      RETURN .f. if ! VenFrfCollect(jnl,aMvt)
    #endif DEF_FRF
    VenMvtRound(aMvt,jnl)
    if ! VenHstGenerate( ;
      jnl, ifc, aMvt, aCtp, aCtg, .f. ;
    )
      lOkay := .f.
    endif
  #endif DEF_GEN
endif
VnlRestore(a)
RETURN lOkay

#ifdef DEF_MVS

**
** VenMvsRebuild()
**
FUNCTION VenMvsRebuild(jnl)
local aMva := {}
local aMvs := {}
local aCts := {}
local aHsi := {}
local aQts := {}
local aVna := {}
local aMvt := {}
local aVnl := {}
local aAfter := {}
* local aSer := {}
local lOkay := .t.
local a
local ifc := IfcLocate(jnl[JNL_IDCTR],VEN->IdJnl,VEN->IdMfc)
if ifc == NIL
  SetMsg(VEN->IdJnl + " & " + VEN->IdMfc + MsgIfcFail())
  RETURN .f.
endif
RETURN .f. if (a := VenVnlInit(jnl)) == NIL
if JNLATTR_S $ jnl[JNL_ATTRIB]
  if ! VenPreClose(jnl,ifc,aMvt,aMvs,aCts,aQts,aVna,aHsi,aVnl,aMva,aAfter)
    lOkay := .f.
  elseif ! VenMvsGenerate( jnl, aMvs )
    lOkay := .f.
  endif
endif
VnlRestore(a)
RETURN lOkay

#endif DEF_MVS

#ifdef DEF_CTS

**
** VenCtsRebuild() called from Rebuild()
**
FUNCTION VenCtsRebuild(jnl)
local aMva := {}
local aMvs := {}
local aCts := {}
local aQts := {}
local aVna := {}
local aMvt := {}
local aHsi := {}
local aVnl := {}
local aAfter := {}
local lOkay := .t.
local a
local ifc := IfcLocate(jnl[JNL_IDCTR],VEN->IdJnl,VEN->IdMfc)
if ifc == NIL
  SetMsg(VEN->IdJnl + " & " + VEN->IdMfc + MsgIfcFail())
  RETURN .f.
endif
#ifdef DEF_ARC
  seek VEN->IdJnl in JNL
  if VEN->Periode <= JNL->ArcPeriode
    SetMsg(MsgArcPeriode())
    RETURN .f.
  endif
#endif DEF_ARC
RETURN .f. if (a := VenVnlInit(jnl)) == NIL
if ! VenPreClose(jnl,ifc,aMvt,aMvs,aCts,aQts,aVna,aHsi,aVnl,aMva,aAfter)
  lOkay := .f.
elseif ! CtsUpdate(aCts)
  lOkay := .f.
endif
VnlRestore(a)
RETURN lOkay

#endif DEF_CTS

FUNCTION MsgArcPeriode() ; RETURN "Dokument ignorieren weil archiviert"


#ifdef DEF_GEN
  #xtranslate GenIdGen() => (GEN->IdGen)
#else
  #xtranslate GenIdGen() => ("")
#endif

* #ifdef DEF_TAX
*   #xtranslate VnlIdTax() => (FIELD->IdTax)
* #else
*   #xtranslate VnlIdTax() => ("")
* #endif

**
**
STATIC FUNCTION VenPreClose(jnl,ifc,aMvt,aMvs,aCts,aQts,;
                            aVna,aHsi,aVnl,aMva,aAfter)
local x
local lOkay := .f.
#ifdef DEF_INT
  RETURN .f. if ! VenHsiInit()
#endif DEF_INT
open area oVnl(VEN->Etat), oGen(), oArt(), oInt(), oVna()
  lOkay := .t.
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                   .and. FIELD->IdJnl == VEN->IdJnl
    if ! VnlVarCollect()
      lOkay := .f.
      exit
    endif
    if ! VnlMvtCollect(jnl,aMvt)
      lOkay := .f.
      exit
    endif
    #ifdef DEF_ANA
    if ! VnlMvaCollect(jnl,aMva)
      lOkay := .f.
      exit
    endif
    #endif
    if ! VnlIsVar()
      if ! IFCATTR_E $ ifc[IFC_ATTRIB]
        #ifdef DEF_VNA
          if PreVnaCollect()
            if ! VnlVnaCollect(jnl,aVna)
              lOkay := .f.
              exit
            endif
          endif
        #endif DEF_VNA
        if FIELD->Code == LNCODE_ART .or. FIELD->Code == LNCODE_ARTFIXE
          #ifdef DEF_MVS
            if JNLATTR_S $ jnl[JNL_ATTRIB]
              if ! VnlMvsCollect(jnl,aMvs)
                lOkay := .f.
                exit
              endif
            endif
          #endif DEF_MVS
          #ifdef DEF_CTS
            if JNLATTR_M $ jnl[JNL_ATTRIB]
              if ! VnlCtsCollect(jnl,aCts,VEN->DC)
                lOkay := .f.
                exit
              endif
            endif
          #endif DEF_CTS
          #ifdef DEF_STK
            if JNLATTR_Q $ jnl[JNL_ATTRIB]
              VnlQtsCollect( ;
                left(FIELD->IdArt,LenIdArt()), ;
                qton1(FIELD->Qte),aQts, ;
                VEN->DC, VnlIdSer(), VenDev2Db(val(FIELD->cMont)) ;
              )
            endif
          #endif DEF_STK
        endif
      endif
      #ifdef DEF_INT
        if ! VnlHsiCollect(jnl,aHsi)
          lOkay := .f.
          exit
        endif
      #endif DEF_INT
    endif
    if ! OnTest(oVnl()).or.!VnlPreClose()
      lOkay := .f.
      exit
    endif
    aadd(aVnl,CopyRec())
    OnVnlClose(aAfter)
    * x := OnVnlClose()
    * if x != NIL
    *   aadd(aAfter,x)
    * endif
    skip
  enddo
close area
RETURN lOkay


**
**
FUNCTION VnlMvtCollect(jnl,aMvt)
local nSK := 0
local lgt
RETURN .t. if FIELD->Code == LNCODE_REMARQ
RETURN .t. if FIELD->Code == LNCODE_NEWS
* RETURN .t. if FIELD->Code == LNCODE_MODULE
RETURN .f. if ! VnlFirstCheck(jnl[JNL_IDCTR])
RETURN .t. if FIELD->Code == LNCODE_TOTAL
RETURN .t. if VnlIsVar()
RETURN .t. if VnlIsModDetail() 
#ifdef DEF_TAX
  RETURN .f. if ! VnlTaxCheck()
#endif DEF_TAX
#ifdef DEF_PRIXR
  nSK := qton1(VNL->Qte)*val(VNL->PrixR)
#endif DEF_PRIXR
RETURN .f. if ! MvtCollect( ;
  jnl, aMvt, ;
  GenIdGen(), ;
  VnlIdTax(), ;
  val(FIELD->cMont),;
  VnlTaxe(), ;
  FIELD->Line, nSK, VnlIdAna() ;
)
#ifdef DEF_LGT
  if FIELD->Code == LNCODE_ART .or. FIELD->Code == LNCODE_ARTFIXE
    RETURN .t. if (lgt := LgtLocate()) == NIL
    RETURN .f. if ! MvtCollect( ;
      jnl, aMvt, ;
      lgt[LGT_IDGEN],;
      lgt[LGT_IDTAX] ,;
      &(lgt[LGT_XNBASE]), 0, FIELD->Line, nSK, VnlIdAna()  ;
    )
  endif
#endif DEF_LGT
RETURN .t.


#ifdef DEF_ANA

**
**
FUNCTION VnlMvaCollect(jnl,aMva)
RETURN .t. if FIELD->Code == LNCODE_REMARQ
RETURN .t. if FIELD->Code == LNCODE_NEWS
* RETURN .t. if FIELD->Code == LNCODE_MODULE
RETURN .f. if ! VnlFirstCheck(jnl[JNL_IDCTR])
RETURN .t. if FIELD->Code == LNCODE_TOTAL
RETURN .t. if VnlIsVar()
RETURN .t. if VnlIsModDetail() 
#ifdef DEF_TAX
  RETURN .f. if ! VnlTaxCheck()
#endif DEF_TAX
if ! empty(VnlIdAna())
  aadd( aMva, {    ;
    GenIdGen()   , ; // MVA_IDGEN
    VnlIdAna()   , ; // MVA_IDANA
    VnlVenDate() , ; // MVA_DATE
    VNL->Line    , ; // MVA_LINE
    VEN->DC      , ; // MVA_DC
    VNL->cMont     ; // MVA_MONT
  } )                // MVA_ALEN
endif
RETURN .t.

#endif DEF_ANA


#ifdef DEF_FRF

**
** VenFrfCollect()
**
FUNCTION VenFrfCollect(jnl,aMvt)
local frf := FrfLocate()
RETURN .t. if frf == NIL
RETURN .f. if ! MvtCollect( ;
  jnl, aMvt, ;
  frf[FRF_IDGEN], ;
  frf[FRF_IDTAX], ;
  xparse(frf[FRF_XNBASE]),;
  xparse(frf[FRF_XNTAXE]), "999", 0, "" ;
)
RETURN .t. // VenMvtRound(aMvt,jnl) // .t.

#endif DEF_FRF

STATIC FUNCTION MvtCollect(jnl,aMvt,cIdGen,cIdTax,;
  nMont,nMontT,cLine,nSK,cIdAna)
local tax := NIL
* local cLine := FIELD->Line
#ifdef DEF_TAX
  RETURN .f. if (tax := TaxLocate( ;
    jnl[JNL_IDCTR], ;
    cIdTax,.t., ;
    VEN->Date ;
  )) == NIL
#endif DEF_TAX
MvtColl2(.t.,jnl,aMvt,cIdGen,tax,nMont,cLine,nSK,cIdAna)
MvtColl2(.f.,jnl,aMvt,cIdGen,tax,nMontT,cLine,0,cIdAna)
RETURN .t.

STATIC FUNCTION MvtColl2(lBase,jnl,aMvt,cIdGen,tax,nMont,cLine,nSK,cIdAna)
local i
RETURN .t. if nMont == 0
if JNLATTR_K $ jnl[JNL_ATTRIB]
  for i := 1 to len(aMvt)
    if aMvt[i][MVT_IDGEN] == cIdGen
      if aMvt[i][MVT_TAX] == tax
        if aMvt[i][MVT_IDANA] == cIdAna
          if aMvt[i][MVT_ISBASE] == lBase
            aMvt[i][MVT_MONT] += nMont
            aMvt[i][MVT_SK] += nSK
            RETURN .t.
          endif
        endif
      endif
    endif
  next i
endif
aadd(aMvt, { ;
  cIdGen, ; // MVT_IDGEN
  lBase, ;  // MVT_ISBASE
  cLine, ;  // MVT_LINE
  tax, ;    // MVT_TAX
  nMont, ;  // MVT_MONT
  0, ;      // MVT_MONTDB
  nSK,;     // MVT_SK
  cIdAna ;  // MVT_IDANA
} )         // MVT_ALEN
RETURN .t.

* #define TVA_TAX   1
* #define TVA_BASE  2
* #define TVA_TAXE  3
* #define TVA_IDGEN 4
* #define TVA_ALEN  4

#ifdef DEF_GEN

**
** VenHstGenerate()
**
STATIC FUNCTION VenHstGenerate(;
  jnl, ifc, ;
  aMvt, aCtp, aCtg, ;
  lTest )
local lOk := .f.
local cIdTax
local i
local nSum := 0
local aTva := {}
local aMvg := {}
local cPeriode := VEN->Periode // PerPerCtr(VEN->Periode,VEN->IdJnl)
local nUmsatz
local cIdGen
* RETURN .t. if ! JNLATTR_G $ jnl[JNL_ATTRIB]
RETURN .t. if ! JnlDoHst(jnl,VEN->Periode)
nUmsatz := VenMvtUmsatz(aMvt)
for i := 1 to len(aMvt)
  #ifdef DEF_TAX
    cIdTax:=aMvt[i][MVT_TAX][TAX_IDTAX]
  #else
    cIdTax:=""
  #endif
  if aMvt[i][MVT_ISBASE]
    MvgCollect( ;
      aMvg, ;
      aMvt[i][MVT_IDGEN], ;
      VEN->Date,VEN->Periode,jnl,;
      DcInvert(VEN->DC), ;
      aMvt[i][MVT_MONTDB], ;
      aMvt[i][MVT_LINE], ;
      cIdTax, ;
      aMvt[i][MVT_MONT],;
      aMvt[i][MVT_IDANA] ;
    )
    nSum += aMvt[i][MVT_MONTDB]
  endif
  #ifdef DEF_TAX
    if ! aMvt[i][MVT_ISBASE]
      if empty(aMvt[i][MVT_TAX][TAX_IDGEN])
        cIdGen   := aMvt[i][MVT_IDGEN]
      else
        cIdGen   := aMvt[i][MVT_TAX][TAX_IDGEN]
      endif
      MvgCollect( ;
        aMvg, cIdGen, ;
        VEN->Date,VEN->Periode,jnl, ;
        DcInvert(VEN->DC), ;
        aMvt[i][MVT_MONTDB], ;
        aMvt[i][MVT_LINE], ;
        "", ;
        aMvt[i][MVT_MONT], ;
        aMvt[i][MVT_IDANA] ;
      )
      if empty(aMvt[i][MVT_TAX][TAX_GENTIERS])
        nSum += aMvt[i][MVT_MONTDB]
      else
        MvgCollect( ;
          aMvg, aMvt[i][MVT_TAX][TAX_GENTIERS], ;
          VEN->Date,VEN->Periode,jnl,;
          VEN->DC, ;
          aMvt[i][MVT_MONTDB], ;
          aMvt[i][MVT_LINE], ;
          "", ;
          aMvt[i][MVT_MONT], ;
          aMvt[i][MVT_IDANA] ;
        )
      endif
    endif
  #endif DEF_TAX
next i
open area oHst()
  if VenHstGen2(jnl,VEN->IdPar,aMvg,.f.,aCtg,aCtp,nSum,nUmsatz)
    * ddSetOrder(ORD_HST_DOC)
    if IFCATTR_E $ ifc[IFC_ATTRIB]
      ** alles umgekehrt verdoppeln
      lOK := VenHstGen2(jnl,ifc[IFC_IDPAR],aMvg,.t.,aCtg,aCtp,nSum,-nUmsatz)
    else
      if empty(ifc[IFC_IDPAR])
        lOK := .t.
      else
        if VenHstGen3(jnl,VEN->IdPar,aMvg,.t.,aCtg,aCtp,nSum,0)
          lOK := VenHstGen3(jnl,ifc[IFC_IDPAR],aMvg,.f.,aCtg,aCtp,nSum,0)
        else
          lOK := .f.
        endif
      endif
    endif
  endif
  dbcommit()
close area
RETURN lOK

**
** second part of VenHstGenerate. Usually called once.
** Called a second time only in the exceptional case IFCATTR_E
**
STATIC FUNCTION VenHstGen2(jnl,cIdPar,aMvg,lExtra,aCtg,aCtp,nSum,nUmsatz)
local nDevDecPos := DevDecPos(VEN->IdDev)
local i
local lOK := .t.
local cIdDev := VEN->IdDev
if VEN->IdDev == DevDefault(VEN->Periode)
  cIdDev := ""
endif
for i := 1 to len(aMvg)
  if aMvg[i][MVG_MONT] != 0
    if dbAddRec()
      HST->IdJnl   := VEN->IdJnl
      HST->IdDoc   := VEN->IdDoc
      HST->Line    := aMvg[i][MVG_LINE]
      HST->IdGen   := aMvg[i][MVG_IDGEN]
      #ifdef DEF_ANA
      HST->IdAna   := aMvg[i][MVG_IDANA]
      #endif DEF_ANA
      HST->Periode := aMvg[i][MVG_PERIODE]
      HST->Date    := aMvg[i][MVG_DATE]
      #ifdef DEF_TAX
      HST->IdTax   := aMvg[i][MVG_IDTAX]
      #endif
      HST->Match   := VenMatch()
      if aMvg[i][MVG_MONT] < 0
        HST->DC      := DcInvert(aMvg[i][MVG_DC])
        HST->Mont    := ntom(-aMvg[i][MVG_MONT])
        if ! empty(cIdDev)
          HST->MontDev := ntom(-aMvg[i][MVG_MONTDEV],nDevDecPos)
          HST->IdDev   := cIdDev
        endif
      else
        HST->DC      := aMvg[i][MVG_DC]
        HST->Mont    := ntom(aMvg[i][MVG_MONT])
        if ! empty(cIdDev)
          HST->MontDev := ntom(aMvg[i][MVG_MONTDEV],nDevDecPos)
          HST->IdDev   := cIdDev
        endif
      endif
      if lExtra
        HST->DC := DcInvert(HST->DC)
      endif
      #ifdef DEF_CTG
        HstCtgCollect(aCtg)
      #endif DEF_CTG
      unlock record
    else
      lOk := .f.
      exit
    endif
  endif
next i
if lOK
  * jetzt die Gegenbuchung aufs Partnerkonto
  VenHstGen3(jnl,cIdPar,aMvg,lExtra,aCtg,aCtp,nSum,nUmsatz)
endif
RETURN lOk

STATIC FUNCTION VenHstGen3(jnl,cIdPar,aMvg,lExtra,aCtg,aCtp,nSum,nUmsatz)
local cIdDev := VEN->IdDev
if VEN->IdDev == DevDefault(VEN->Periode)
  cIdDev := ""
endif
RETURN .f. if ! dbAddRec()
HST->IdCtr   := jnl[JNL_IDCTR]
#ifdef DEF_CTRATTR
  if CTRATTR_L $ CtrAttrib(HST->IdCtr)
    HST->Satis := "*"
  endif
#endif DEF_CTRATTR
HST->IdGen   := CtrIdGen(jnl[JNL_IDCTR])
if empty(cIdPar)
  HST->IdPar   := VEN->IdPar
else
  HST->IdPar   := cIdPar
endif
HST->IdJnl   := VEN->IdJnl
HST->IdDoc   := VEN->IdDoc
HST->Periode := VEN->Periode
HST->Date    := VEN->Date
HST->Match   := VenMatch()
HST->Mont    := ntom(nSum)
HST->DC := VEN->DC
if empty(cIdDev)
  if !empty(PAR->IdDev) ;
     .and. PAR->IdDev != DevDefault(VEN->Periode)
    HST->MontDev := ntom( ;
      Db2Dev(PAR->IdDev,HST->Periode,nSum), ;
      DevDecPos(PAR->IdDev) ;
    )
    HST->IdDev := PAR->IdDev
  endif
else
  HST->MontDev := VEN->Mont
  HST->IdDev := cIdDev
endif
if lExtra
  HST->DC := DcInvert(HST->DC)
endif
#ifdef DEF_CTP
if HST->DC == DC_DEBIT
  CtpCollect( ;
    aCtp, HST->IdCtr, HST->IdPar, ;
    HST->Periode, ;
    val(HST->Mont), 0, nUmsatz ;
  )
else
  CtpCollect( ;
    aCtp, HST->IdCtr, HST->IdPar, ;
    HST->Periode, ;
    0, val(HST->Mont), nUmsatz ;
  )
endif
#endif DEF_CTP
#ifdef DEF_CTG
  HstCtgCollect(aCtg)
#endif DEF_CTG
unlock record
RETURN .t.


**
** MvgCollect()
**
FUNCTION MvgCollect( ;
  aMvg,cIdGen, ;
  dDate, cPeriode,jnl, ;
  cDC, nMont, cLine, cIdTax, ;
  nMontDev, cIdAna ;
)
local mvg := NIL
local i
if JNLATTR_K $ jnl[JNL_ATTRIB]
  for i := 1 to len(aMvg)
    if aMvg[i][MVG_IDGEN] == cIdGen .and. aMvg[i][MVG_IDANA] == cIdAna
      if aMvg[i][MVG_PERIODE] == cPeriode
        * if aMvg[i][MVG_IDJNL] == cIdJnl
          if aMvg[i][MVG_DC] == cDC
            * if aMvg[i][MVG_LINE] == cLine
              if aMvg[i][MVG_IDTAX] == cIdTax
                mvg := aMvg[i]
                mvg[MVG_MONT] += nMont
                mvg[MVG_MONTDEV] += nMontDev
                if mvg[MVG_DATE] < dDate
                  mvg[MVG_DATE]    := dDate
                endif
                RETURN NIL
              endif
            * endif
          endif
        * endif
      endif
    endif
  next i
endif
mvg := array(MVG_ALEN)
mvg[MVG_IDGEN]   := cIdGen
mvg[MVG_IDANA]   := cIdAna
* mvg[MVG_IDJNL]   := cIdJnl
mvg[MVG_PERIODE] := cPeriode
mvg[MVG_DC]      := cDC
mvg[MVG_MONT]    := nMont
mvg[MVG_MONTDEV] := nMontDev
mvg[MVG_DATE]    := dDate
mvg[MVG_LINE]    := cLine
mvg[MVG_IDTAX]   := cIdTax
aadd(aMvg,mvg)
RETURN NIL

#endif DEF_GEN

*FUNCTION MsgNoDetail()
*#ifdef LG_GERMAN
*  RETURN " : Dokument enth„lt keine Buchungen !"
*#endif
*#ifdef LG_FRENCH
*  RETURN " : ce document ne contient aucune imputation !"
*#endif
*#ifdef LG_EN
*  RETURN " : document is empty !"
*#endif



* #ifdef DEF_TAX
*
* FUNCTION TvaAdd(aTva,tax,nBase,nTaxe,cIdGen)
* local i
* for i := 1 to len(aTva)
*   if aTva[i][TVA_TAX][TAX_IDTAX] == tax[TAX_IDTAX]
*     if (! empty(aTva[i][TVA_TAX][TAX_IDGEN])) .or. aTva[i][TVA_IDGEN] == cIdGen
*       aTva[i][TVA_BASE] += nBase
*       aTva[i][TVA_TAXE] += nTaxe
*       RETURN NIL
*     endif
*   endif
* next i
* aadd(aTva, { tax, nBase, nTaxe, cIdGen }) // TVA_ALEN
* RETURN NIL
*
* #endif DEF_TAX

FUNCTION MsgRecCompare()
#ifdef LG_GERMAN
  RETURN "Die zwischengespeicherten Daten des Dokuments werden gel”scht !"
#else
  RETURN "Les donn‚es interm‚diaires du document seront ‚cras‚es !"
#endif

**
**
STATIC FUNCTION VenUndo(jnl,ifc,lDlg) // ,aCtp,aCtg,aCta)
local trn, nQtePs
local aCtp := {}
local aCtg := {}
local aCta := {}
local aVna := {}
local cMsg
local lOkay := .f.
local cPeriode := VEN->Periode
local aCts := {}
local aQts := {}
local aMvt := {}
local nUmsatz := 0
local i
local aPar := {}
local aGen := {}
local b
* #ifdef DEF_VNLALT
*   local aVnl := {}
* #endif DEF_VNLALT
open area oVnl(VEN->Etat), oGen(), oArt(), oVna()
  lOkay := .t.
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdJnl == VEN->IdJnl ;
                   .and. FIELD->IdDoc == VEN->IdDoc
    if ! VnlVarCollect()
      lOkay := .f.
      exit
    endif
    if ! VnlMvtCollect(jnl,aMvt)
      lOkay := .f.
      exit
    endif
    #ifdef DEF_ART
      if ! VnlIsVar() .and. ;
         (FIELD->Code==LNCODE_ART .or. FIELD->Code==LNCODE_ARTFIXE)
        if ifc == NIL .or. ! IFCATTR_E $ ifc[IFC_ATTRIB]
          #ifdef DEF_CTS
            if JNLATTR_M $ jnl[JNL_ATTRIB]
              * if ! VnlCtsUndo(jnl,aCts)
              if ! VnlCtsCollect(jnl,aCts,DcInvert(VEN->DC))
                lOkay := .f.
                exit
              endif
            endif
          #endif DEF_CTS
          #ifdef DEF_STK
            if JNLATTR_Q $ jnl[JNL_ATTRIB]
              VnlQtsCollect( ;
                left(FIELD->IdArt,LenIdArt()), ;
                -qton1(FIELD->Qte), ;
                aQts, ;
                VEN->DC, VnlIdSer(), ;
                VenDev2Db(-val(FIELD->cMont));
              )
            endif
          #endif DEF_STK
          #ifdef DEF_VNA
            if ! empty(VNL->Match) // PreVnaCollect()
              if ! VnlVnaCollect(jnl,aVna)
                lOkay := .f.
                exit
              endif
            endif
          #endif DEF_VNA
        endif
      endif
    #endif DEF_ART
    * #ifdef DEF_VNLALT
    *   aadd(aVnl,CopyRec())
    * #endif DEF_VNLALT
    skip
  enddo
close area
if ! lOkay
  SendConsole(MsgIdJnlDoc() + MsgDocStatError())
  VEN->Etat := DocStatError()
  RETURN .f.
endif
#ifdef DEF_VNA
  // ... if ! JNLATTR_S $
  lOkay := .f.
  open area oVna()
    lOkay := .t.
    softseek VEN->IdJnl + VEN->IdDoc
    do while ! eof() .and. VNA->IdDoc == VEN->IdDoc ;
                     .and. VNA->IdJnl == VEN->IdJnl
      if ! PreVnaUndo()
        lOkay := .f.
      endif
      Purzel()
      skip
    enddo
  close area
  if lDlg
    if ! lOkay .and. USRATTR_E $ UsrAttrib()
      lOkay := Confirm(SetMsg()+CR_LF+;
      "Only reply 'Yes' if you know what you do!", MsgSure(),MSG_NO)
    endif
    RETURN .f. if ! lOkay
  else
    lOkay := .t. // ignore PreVnaUndo() vetos when running in batch mode
  endif
#endif DEF_VNA
**
** So. Jetzt geht es los.
**
*#ifdef DEF_VNLALT
*  ** Nachprfen, ob die Records in VNLNEW noch bereinstimmen...
*  open area oVnl(DocStatOpen())
*    lOkay := .t.
*    i := 0
*    softseek VEN->IdJnl+VEN->IdDoc
*    do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
*                     .and. FIELD->IdJnl == VEN->IdJnl
*      i++
*      if i > len(aVnl)
*        exit
*      endif
*      if ! RecCompare(aVnl[i])
*        lOkay := .f.
*      endif
*      skip
*    enddo
*  close area
*  if len(aVnl) != i .or. ! lOkay
*    ** eine Warnung ist nur n”tig, wenn VNLPRE andere Daten enth„lt.
*    ** Wenn sie keine Daten enth„lt, dann ist es ja okay.
*    if i != 0
*      RETURN .f. if ! Confirm( ;
*        MsgRecCompare(), MsgSure() ;
*      )
*    endif
*    ** Alles in der Zwischendatei durch die Daten aus der definitiven
*    ** Datei ersetzen
*    lOkay := .f.
*    open area oVnl(DocStatOpen())
*      lOkay := .t.
*      if i > 0
*        ** Zuerst die Zwischendaten l”schen
*        softseek VEN->IdJnl+VEN->IdDoc
*        do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
*                         .and. FIELD->IdJnl == VEN->IdJnl
*          if ddRecLock()
*            delete
*            unlock record
*          else
*            lOkay := .f.
*          endif
*          skip
*        enddo
*      endif
*      if lOkay
*        for i := 1 to len(aVnl)
*          if dbAddRec()
*            PasteRec(aVnl[i])
*            unlock record
*          else
*            lOkay := .t.
*          endif
*        next i
*      endif
*    close area
*    if ! lOkay
*      VEN->Etat := DocStatError()
*      SendConsole(MsgIdJnlDoc() + MsgDocStatError())
*      RETURN .f.
*    endif
*  endif
*#endif DEF_VNLALT
#ifdef DEF_MVS
  lOkay := .f.
  open area oMvs()
    lOkay := .t.
    softseek VEN->IdJnl + VEN->IdDoc
    do while ! eof() .and. MVS->IdDoc == VEN->IdDoc ;
                     .and. MVS->IdJnl == VEN->IdJnl
      if ddReclock()
        delete
        unlock record
      else
        lOkay := .f.
      endif
      Purzel()
      skip
    enddo
  close area
  if ! lOkay
    VEN->Etat := DocStatError()
    SendConsole(MsgIdJnlDoc() + MsgDocStatError())
    RETURN .f.
  endif
#endif DEF_MVS
#ifdef DEF_VNA
  if ! VnaScan(jnl,aVna,.t.)
  *endif
  * b := oVna()
  *lOkay := .f.
  *open area b
  *  lOkay := .t.
  *  for i := 1 to len(aVna)
  *    seek aVna[i][VNA_MATCH]
  *    if ! eof() .and. aVna[i][VNA_IDART] == VNA->IdArt
  *      if (trn := VnaTrnLocate(jnl)) != NIL
  *        if ! TRNATTR_P $ trn[TRN_ATTRIB]
  *          nQtePs  := qton1(aVna[i][VNA_QTE])
  *          if VNA->DC != aVna[i][VNA_DC]
  *            nQtePs *= -1
  *          endif
  *          if TRNATTR_I $ trn[TRN_ATTRIB]
  *            nQtePs *= -1
  *          endif
  *          nQtePs := qton1(VNA->QteUs) + nQtePs
  *          if ddRecLock()
  *            VNA->QteUs := ntoq(;
  *              nQtePs, aVna[i][VNA_QTEFORM] ;
  *            )
  *            if empty(VNA->QteUs)
  *              VNA->Satis := "*"
  *            else
  *              VNA->Satis := " "
  *            endif
  *            unlock record
  *          else
  *            lOkay := .f.
  *            exit
  *          endif
  *        endif
  *      endif
  *    else
  *      SetMsg(aVna[i][VNA_MATCH]+"/"+aVna[i][VNA_IDART]+" : no such VNA!")
  *      lOkay := .f.
  *      exit
  *    endif
  *  next i
  *close area
  *if ! lOkay
    VEN->Etat := DocStatError()
    SendConsole(MsgIdJnlDoc() + MsgDocStatError())
    RETURN .f.
  endif
  lOkay := .f.
  b:= oVna()
  open area b
    lOkay := .t.
    softseek VEN->IdJnl + VEN->IdDoc
    do while ! eof() .and. VNA->IdDoc == VEN->IdDoc ;
                     .and. VNA->IdJnl == VEN->IdJnl
      if ddReclock()
        if DoEvents(b[AD_ONDELETE],"VenUndo()")
          delete
        else
          lOkay := .f.
        endif
        unlock record
      else
        lOkay := .f.
      endif
      Purzel()
      skip
    enddo
  close area
  if ! lOkay
    VEN->Etat := DocStatError()
    SendConsole(MsgIdJnlDoc() + MsgDocStatError())
    RETURN .f.
  endif
#endif DEF_VNA
*#ifdef DEF_VNLALT
*  lOkay := .f.
*  open area oVnl(DocStatClosed())
*    lOkay := .t.
*    softseek VEN->IdJnl + VEN->IdDoc
*    do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
*                     .and. FIELD->IdJnl == VEN->IdJnl
*      if ddReclock()
*        delete
*        unlock record
*      else
*        lOkay := .f.
*      endif
*      Purzel()
*      skip
*    enddo
*  close area
*  if ! lOkay
*    VEN->Etat := DocStatError()
*    SendConsole(MsgIdJnlDoc() + MsgDocStatError())
*    RETURN .f.
*  endif
*#endif DEF_VNLALT
#ifdef DEF_HST
  if ! HstUndo( ;
    VEN->IdJnl,VEN->IdDoc, ;
    VEN->Periode,aCtp,aCtg,aPar,aGen ;
  )
    VEN->Etat := DocStatError()
    SendConsole(MsgIdJnlDoc() + MsgDocStatError())
    RETURN .f.
  endif
#endif DEF_HST
#ifdef DEF_CTT
  * if JNLATTR_G $ jnl[JNL_ATTRIB]
  if JnlDoHst(jnl,VEN->Periode)
    for i := 1 to len(aMvt)
      aMvt[i][MVT_MONTDB] := - aMvt[i][MVT_MONTDB]
      aMvt[i][MVT_MONT] := - aMvt[i][MVT_MONT]
      * aMvt[i][MVT_TAXEDB] := - aMvt[i][MVT_TAXEDB]
      * aMvt[i][MVT_BASEDB] := - aMvt[i][MVT_BASEDB]
      * aMvt[i][MVT_TAXE]   := - aMvt[i][MVT_TAXE]
      * aMvt[i][MVT_BASE]   := - aMvt[i][MVT_BASE]
    next i
    #ifdef DEF_VENREMISE
      VenMvtRemise(aMvt)
    #endif
    #ifdef DEF_FRF
      RETURN .f. if ! VenFrfCollect(jnl,aMvt)
    #endif DEF_FRF
    VenMvtRound(aMvt,jnl)
    nUmsatz := VenMvtUmsatz(aMvt)
    if ! VenCttUpdate(jnl,aMvt)
      VEN->Etat := DocStatError()
      SendConsole(MsgIdJnlDoc() + MsgDocStatError())
      RETURN .f.
    endif
    // 20020507 Die Warnung "len(aCtp) == ..." kam unsinnigerweise
    // - wenn IFCATTR_E gesetzt ist
    // - wenn keine Partnerbuchungen existierten
    for i := 1 to len(aCtp)
      aCtp[i][CTP_UMSATZ] := nUmsatz
    next i
    * if len(aCtp) == 2 // warum stand hier vorher eine 2 ???
    *  aCtp[1][CTP_UMSATZ] := nUmsatz
    *  aCtp[2][CTP_UMSATZ] := nUmsatz
    *else
    *  Warning("len(aCtp) == " + ntrim(len(aCtp)))
    *endif
  endif
#endif DEF_CTT
#ifdef DEF_INT
  lOkay := .f.
  open area oHsi()
    lOkay := .t.
    ddSetOrder(ORD_HSI_DOC)
    softseek VEN->IdJnl + VEN->IdDoc
    do while ! eof() .and. HSI->IdJnl + HSI->IdDoc == VEN->IdJnl + VEN->IdDoc
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
  if ! lOkay
    VEN->Etat := DocStatError()
    SendConsole(MsgIdJnlDoc() + MsgDocStatError())
    RETURN .f.
  endif
#endif DEF_INT
#ifdef DEF_CTS
  if ! CtsUpdate(aCts)
    VEN->Etat := DocStatError()
    SendConsole(MsgIdJnlDoc() + MsgDocStatError())
    RETURN .f.
  endif
#endif DEF_CTS
#ifdef DEF_STK
  if ! QtsUpdate(aQts,VEN->Date)
    VEN->Etat := DocStatError()
    SendConsole(MsgIdJnlDoc() + MsgDocStatError())
    RETURN .f.
  endif
#endif DEF_STK
#ifdef DEF_MVA
  if ! OdaUndo(VEN->IdJnl,VEN->IdDoc,aCta)
    VEN->Etat := DocStatError()
    SendConsole(MsgIdJnlDoc() + MsgDocStatError())
    RETURN .f.
  endif
  RETURN .f. if ! MvaUndo(VEN->IdJnl,VEN->IdDoc)
#endif DEF_MVA
** 20060824 der folgende Code wurde bisher vom Caller gemacht
VEN->Etat := DocStatOpen()
if TIMATTR_Z $ MemAttrib // jnl[JNL_ATTRIB]
  #ifdef DEF_CTP
    CtpUpdate(aCtp) // ,NIL,nDbDecPos)
  #endif DEF_CTP
  #ifdef DEF_CTG
    CtgUpdate(aCtg)
  #endif DEF_CTG
  #ifdef DEF_MVA
    CtaUpdate(aCta)
  #endif DEF_MVA
endif
#ifdef DEF_HST
  if JNLATTR_L $ jnl[JNL_ATTRIB]
    ParSatisfy(VEN->IdPar)
  endif
#endif DEF_HST
#ifdef DEF_RSV
  if ! VenRsiUndo(jnl)
    VEN->Etat := DocStatError()
    SendConsole(MsgIdJnlDoc() + " : VenRsiUndo() failed.")
  endif
#endif DEF_RSV
AfterVenClose()
RETURN .t.

FUNCTION MsgVnaUndo
#ifdef LG_GERMAN
  RETURN MsgIdJnlDoc() + " : Fakturierungsvorschl„ge gehen verloren !"
#else
  RETURN MsgIdJnlDoc() + " : les propositions de facturation seront perdues !"
#endif

FUNCTION VenCours
if val(VEN->Cours) == 0
  Warning("val(VEN->Cours) == 0 !")
  RETURN 1
endif
RETURN val(VEN->Cours)


* FUNCTION VenMatch
* #ifdef DEF_HST
*   RETURN VEN->Match if ! empty(VEN->Match)
* #endif DEF_HST
* RETURN VEN->IdJnl + VEN->IdDoc

#define UPDATE_RECNO   1
#define UPDATE_QTEUS   2
#define UPDATE_ALEN    2

#ifdef DEF_VNA
  

**
** der vereinfachte Befriedigungs-Algorithmus fr Fakturierungsvorschl„ge
** seit 20060824 kann jede VNL nur eine einzige VNA befriedigen.
**
**
STATIC FUNCTION VnaScan(jnl,aVna,lUndo)
local lOkay := .f.
local i
local nQtePs  // Befriedigungspotential
* local nQteR   // rckbefriedigte Menge
* local nQte    // wieviel hier jetzt befriedigt wird
local trn
* local cDC
* local aVna
RETURN .t. if ! JNLATTR_A $ jnl[JNL_ATTRIB]
open area oVna()
  lOkay := .t.
  for i := 1 to len(aVna)
    if TaskInter() ; lOkay := .f. ; exit ; endif
    nQtePs  := qton1(aVna[i][VNA_QTE])
    aVna[i][VNA_QTEUS] := aVna[i][VNA_QTE]
    if !empty(aVna[i][VNA_MATCH])
      seek aVna[i][VNA_MATCH]
      if ! eof() .and. aVna[i][VNA_IDART] == VNA->IdArt
        if (trn := VnaTrnLocate(jnl)) != NIL
          if ddRecLock()
            if TRNATTR_I $ trn[TRN_ATTRIB]
              nQtePs *= -1
            endif
            if lUndo
              nQtePs *= -1
            endif
            if VNA->DC != aVna[i][VNA_DC]
              nQtePs *= -1
            endif
            if TRNATTR_R $ trn[TRN_ATTRIB]
              aVna[i][VNA_QTEUS] := ntoq(0,aVna[i][VNA_QTEFORM])
              aVna[i][VNA_QTE] := ntoq(0,aVna[i][VNA_QTEFORM])
            endif
            if ! TRNATTR_P $ trn[TRN_ATTRIB]
              VNA->QteUs := ntoq(;
                qton1(VNA->QteUs) - nQtePs, ;
                aVna[i][VNA_QTEFORM] ;
              )
            endif
            if qton1(VNA->QteUs) == 0
              VNA->Satis := "*"
            elseif qton1(VNA->QteUs) < 0
              VNA->Satis := " " // before 20081124 : "*"
            else
              VNA->Satis := " "
            endif
            unlock record
          else
            lOkay := .f.
            exit
          endif
        endif
      else
        SetMsg(aVna[i][VNA_MATCH]+"/"+aVna[i][VNA_IDART]+" : no such VNA!")
        lOkay := .f.
        exit
      endif
    endif
    * if nQteR != 0
    *   aVna[i][VNA_QTEUS] := ntoq(qton1(aVna[i][VNA_QTE])+nQteR,aVna[i][VNA_QTEFORM])
    * endif
  next i
close area
RETURN lOkay
* RETURN NIL if ! lOkay
* RETURN aVna

* **
* ** bis 20060824 Befriedigungs-Algorithmus fr Fakturierungsvorschl„ge
* **
* STATIC FUNCTION VnaScan(jnl,aVnaOri,aUpdate)
* local lOkay := .f.
* local i
* local nQtePs  // Befriedigungspotential
* local nQteR   // rckbefriedigte Menge
* local nQte    // wieviel hier jetzt befriedigt wird
* local a
* local trn
* local cDC
* local aVna
* RETURN aVnaOri if ! JNLATTR_A $ jnl[JNL_ATTRIB]
* aVna := VnaCompress(aVnaOri)
* open area oVna()
*   ddSetOrder(ORD_VNA_ARTMATCH)
*   lOkay := .t.
*   for i := 1 to len(aVna)
*     if TaskInter() ; lOkay := .f. ; exit ; endif
*     nQtePs  := qton1(aVna[i][VNA_QTE])
*     aVna[i][VNA_QTEUS] := aVna[i][VNA_QTE]
*     nQteR  := 0 // qton1(aVna[i][VNA_QTE])
*     KeyGoBottom( ;
*       aVna[i][VNA_IDART] + aVna[i][VNA_MATCH], ;
*       "VNA->IdArt+VNA->Match" ;
*     )
*     do while ! bof() .and. VNA->IdArt == aVna[i][VNA_IDART] ;
*                      .and. VNA->Match == aVna[i][VNA_MATCH]  ;
*                      .and. ! eof()
*       if empty(VNA->Satis)
*         if (trn := VnaTrnLocate(jnl)) != NIL
*           if TRNATTR_I $ trn[TRN_ATTRIB]
*             cDC := DcInvert(VNA->DC)
*           else
*             cDC := VNA->DC
*           endif
*           if nQtePs > 0
*             if cDC == aVna[i][VNA_DC]
*               if (nQte := qton1(VNA->QteUs)) > 0
*                 ** z.B. positive VKR befriedigt positiven VKL
*                 nQte := min(nQte,nQtePs)
*                 nQtePs -= nQte
*                 if TRNATTR_R $ trn[TRN_ATTRIB]
*                   nQteR -= nQte
*                 endif
*                 if ! TRNATTR_P $ trn[TRN_ATTRIB]
*                   a := array(UPDATE_ALEN)
*                   a[UPDATE_RECNO] := recno()
*                   a[UPDATE_QTEUS] := ntoq( ;
*                     qton1(VNA->QteUs) - nQte, ;
*                     aVna[i][VNA_QTEFORM] ;
*                   )
*                   aadd(aUpdate,a)
*                 endif
*               endif
*             else
*               if (nQte := qton1(VNA->QteUs)) < 0
*                 ** z.B. positive VKR befriedigt negativen invers-VKL
*                 nQte := min(-nQte,nQtePs)
*                 nQtePs -= nQte
*                 if TRNATTR_R $ trn[TRN_ATTRIB]
*                   nQteR -= nQte
*                 endif
*                 if ! TRNATTR_P $ trn[TRN_ATTRIB]
*                   a := array(UPDATE_ALEN)
*                   a[UPDATE_RECNO] := recno()
*                   a[UPDATE_QTEUS] := ntoq( ;
*                     qton1(VNA->QteUs) + nQte, ;
*                     aVna[i][VNA_QTEFORM] ;
*                   )
*                   aadd(aUpdate,a)
*                 endif
*               endif
*             endif
*           elseif nQtePs < 0
*             if cDC == aVna[i][VNA_DC]
*               if (nQte := qton1(VNA->QteUs)) < 0
*                 nQte := min(-nQte,-nQtePs)
*                 nQtePs += nQte
*                 if TRNATTR_R $ trn[TRN_ATTRIB]
*                   nQteR += nQte
*                 endif
*                 if ! TRNATTR_P $ trn[TRN_ATTRIB]
*                   a := array(UPDATE_ALEN)
*                   a[UPDATE_RECNO] := recno()
*                   a[UPDATE_QTEUS] := ntoq( ;
*                     qton1(VNA->QteUs) + nQte, ;
*                     aVna[i][VNA_QTEFORM] ;
*                   )
*                   aadd(aUpdate,a)
*                 endif
*               endif
*             else
*               if (nQte := qton1(VNA->QteUs)) > 0
*                 ** z.B. eine negative Gutschrift befriedigt einen VKL
*                 nQte := min(nQte,-nQtePs)
*                 nQtePs += nQte
*                 if TRNATTR_R $ trn[TRN_ATTRIB]
*                   nQteR += nQte
*                 endif
*                 if ! TRNATTR_P $ trn[TRN_ATTRIB]
*                   a := array(UPDATE_ALEN)
*                   a[UPDATE_RECNO] := recno()
*                   a[UPDATE_QTEUS] := ntoq( ;
*                     qton1(VNA->QteUs) - nQte, ;
*                     aVna[i][VNA_QTEFORM] ;
*                   )
*                   aadd(aUpdate,a)
*                 endif
*               endif
*             endif
*           else
*             exit
*           endif
*         endif
*       endif
*       skip -1
*     enddo
*     if nQteR != 0
*       aVna[i][VNA_QTEUS] := ntoq(qton1(aVna[i][VNA_QTE])+nQteR,aVna[i][VNA_QTEFORM])
*     endif
*   next i
* close area
* RETURN NIL if ! lOkay
* RETURN aVna

FUNCTION PsMin(nQtePs,nQte)
RETURN min(nQtePs,nQte) if nQtePs > 0
RETURN - min(-nQtePs,-nQte)

FUNCTION absmin(n1,n2)
RETURN n2 if abs(n1) > abs(n2)
RETURN n1

**
** VenVnaGenerate()
**
* FUNCTION VenVnaGenerate(jnl,ifc,aVna,aUpdate)
STATIC FUNCTION VenVnaGenerate(jnl,ifc,aVna)
local i
local lOkay := .f.
RETURN .t. if ! IFCATTR_A $ ifc[IFC_ATTRIB]
open area oVna(), oArt(), oPar(), oVnl(DocStatOpen())
  lOkay := .t.
  for i := 1 to len(aVna)
    if qton1(aVna[i][VNA_QTEUS]) != 0
      if dbAddRec()
        VNA->IdJnl     := VEN->IdJnl
        VNA->IdDoc     := VEN->IdDoc
        VNA->IdPar     := VEN->IdPar
        VNA->Periode   := VEN->Periode
        VNA->NB1       := aVna[i][VNA_NB1      ]
        VNA->Code      := aVna[i][VNA_CODE     ]
        VNA->Memo      := aVna[i][VNA_MEMO     ]
        VNA->Date      := VEN->Date
        VNA->IdArt     := aVna[i][VNA_IDART    ]
        VNA->Line      := aVna[i][VNA_LINE     ]
        // 20060824 VNA->Match     := aVna[i][VNA_MATCH    ]
        VNA->PrixU     := aVna[i][VNA_PRIXU    ]
        // VNA->Mont      := aVna[i][VNA_MONT     ]
        VNA->DC        := aVna[i][VNA_DC       ] // VEN->DC
        VNA->Qte       := aVna[i][VNA_QTE      ]
        ** [971026] Seltsam, VNA->QteForm wurde bisher gar nicht
        ** abgespeichert. Dass sich da niemand drber beschwert hatte...
        VNA->QteForm   := aVna[i][VNA_QTEFORM  ]
        #ifdef DEF_INT
          VNA->QteStat := aVna[i][VNA_QTESTAT  ]
          VNA->IdInt   := aVna[i][VNA_IDINT    ]
        #endif DEF_INT
        #ifdef DEF_PROVI
          VNA->PrixL := aVna[i][VNA_PRIXL]
        #endif DEF_PROVI
        #ifdef DEF_VNLATTR
          VNA->Attrib := aVna[i][VNA_ATTRIB]
        #endif DEF_VNLATTR
        if IFCATTR_S $ ifc[IFC_ATTRIB]
          VNA->Satis     := "*"
        else
          VNA->QteUs := aVna[i][VNA_QTEUS]
          if qton1(VNA->QteUs) == 0
            VNA->Satis := "*"
          endif
        endif
        #ifdef DEF_VNAGENERATE
          VNL->(dbgoto(aVna[i][VNA_RECNO]))
        #endif
        if ! OnVnaGenerate()
          lOkay := .f.
        endif
        unlock record
      else
        lOkay := .f.
        exit
      endif
      if ! lOkay
        exit
      endif
    endif
  next i
close area
RETURN lOkay


**
**
*STATIC FUNCTION VnlVnaCopy(jnl,ifc,xlVnaFilter)
*local aVna := VnaSuggest(VEN->IdPar,jnl,VEN->Date,xlVnaFilter)
*RETURN .f. if len(aVna) == 0
*if ! IFCATTR_X $ ifc[IFC_ATTRIB]
*  RETURN .f. if ! VnaTag( ;
*    aVna,;
*    VEN->IdPar,;
*    VEN->IdJnl + " " + VEN->IdDoc + " : Fakturierungsvorschl„ge", ;
*    VEN->IdJnl;
*  )
*endif
*RETURN VenVnlGenerate(aVna,jnl,ifc,VEN->DC)

**
** VnlVnaCollect()
**
STATIC FUNCTION VnlVnaCollect(jnl,aVna)
local trn
local a
local n := VnlVnaCount() // 19990812  sh. Worriken
local i
for i := 1 to n
  a := array(VNA_ALEN)
  a[VNA_CODE     ] := FIELD->Code
  a[VNA_NB1      ] := FIELD->Desig
  a[VNA_IDART    ] := left(FIELD->IdArt,LenIdArt())
  if n == 1
    a[VNA_QTE      ] := FIELD->Qte
    a[VNA_QTEUS    ] := FIELD->Qte
  else
    a[VNA_QTE      ] := ""
    a[VNA_QTEUS    ] := ""
  endif
  a[VNA_PRIXU    ] := FIELD->PrixU
  a[VNA_MATCH    ] := VNL->Match // VnlVnaMatch()
  a[VNA_LINE     ] := VNL->Line
  a[VNA_MEMO     ] := FIELD->Memo
  a[VNA_SATIS    ] := ""
  a[VNA_DC       ] := VEN->DC
  #ifdef DEF_VNAGENERATE
    a[VNA_RECNO    ] := recno()
  #endif
  #ifdef DEF_PROVI
    a[VNA_PRIXL    ] := FIELD->PrixL
  #endif DEF_PROVI
  #ifdef DEF_VNLATTR
    a[VNA_ATTRIB   ] := FIELD->Attrib
  #endif DEF_VNLATTR
  #ifdef DEF_INT
    a[VNA_IDINT    ] := FIELD->IdInt
    a[VNA_QTESTAT  ] := FIELD->QteStat
  #endif DEF_INT
  if IsArtCode(FIELD->Code)
    a[VNA_QTEFORM  ] := ART->QteForm
  else
    a[VNA_QTEFORM  ] := " "
  endif
  aadd(aVna,a)
next i
RETURN .t.

*STATIC FUNCTION VnaCompress(aVna)
*** 20041025 hat jemand ne Ahnung, wann das n”tig ist?
*** siehe Mails an EH fr einen Fall mit mehreren Eintr„gen fr den
*** gleichen Match
*local aVnaNew := {}
*local i
*for i := 1 to len(aVna)
*  VnaAdd(aVnaNew,aVna[i])
*next i
*RETURN aVnaNew
*
*STATIC FUNCTION VnaAdd(aVna,a)
*local i
*local nQte
*local nQteUs
*for i := 1 to len(aVna)
*  if aVna[i][VNA_CODE] == a[VNA_CODE] ;
*    .and. aVna[i][VNA_IDART] == a[VNA_IDART] ;
*    .and. aVna[i][VNA_MATCH] == a[VNA_MATCH]
*    if aVna[i][VNA_DC] == a[VNA_DC]
*      nQte := qton1(aVna[i][VNA_QTE]) + qton1(a[VNA_QTE])
*      nQteUs := qton1(aVna[i][VNA_QTEUS]) + qton1(a[VNA_QTEUS])
*    else
*      nQte := qton1(aVna[i][VNA_QTE]) - qton1(a[VNA_QTE])
*      nQteUs := qton1(aVna[i][VNA_QTEUS]) - qton1(a[VNA_QTEUS])
*    endif
*    aVna[i][VNA_QTE] := ntoq(nQte,a[VNA_QTEFORM])
*    aVna[i][VNA_QTEUS] := ntoq(nQteUs,a[VNA_QTEFORM])
*    RETURN NIL
*  endif
*next i
*aadd(aVna,a)
*RETURN NIL


#endif DEF_VNA


**
** VenVnlUpdate()
**
** Setzt VEN->Mont
** (und ggf VEN->MontT und VEN->MontR) entsprechend den Werten im Inhalt
** des Dokuments.
**
FUNCTION VenVnlUpdate(jnl)
local aMvt   := {}
local nHTVA := 0
local nMTVA := 0
local nMontR := 0
local i
local nMontDoc
local nDecPos := DevDecPos(VEN->IdDev)
local lOkay:= .f.
local aVnr
local nSK := 0
* default jnl to JnlLocate(VEN->IdJnl)
* RETURN .f. if ! VenVnlInit(jnl)
open area oVnl(VEN->Etat), oGen(), oArt(), oNew(), oVna(), oDls()
  lOkay := .t.
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                   .and. FIELD->IdJnl == VEN->IdJnl
    if ! VnlVarCollect()
      lOkay := .f.
      exit
    endif
    if ! VnlMvtCollect(jnl,aMvt)
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
#ifdef DEF_VENREMISE
  // nMontR enth„lt den Betrag htva *vor* Anwendung der Erm„áigung
  // und ohne die Betr„ge aus DEF_FRF
  * for j := 1 to len(aVnr)
  *   for i := 1 to len(aMvt)
  *     nMontR += aMvt[i][MVT_BASE]
  *   next i
    aVnr := VenMvtRemise(aMvt)
  * next j
#endif
#ifdef DEF_FRF
  RETURN .f. if ! VenFrfCollect(jnl,aMvt)
#endif DEF_FRF
VenMvtRound(aMvt,jnl)
for i := 1 to len(aMvt)
  * nHTVA += round(aMvt[i][MVT_BASE],nDecPos)

  if aMvt[i][MVT_ISBASE]
    nHTVA += round(aMvt[i][MVT_MONT],nDecPos)
    nSK += aMvt[i][MVT_SK]
                                 #ifdef DEF_TAX
  else
    if empty(aMvt[i][MVT_TAX][TAX_GENTIERS])
      nMTVA += aMvt[i][MVT_MONT]
    endif
                                 #endif DEF_TAX
  endif
next i
nMontDoc := nHTVA + nMTVA
if JNLATTR_T $ jnl[JNL_ATTRIB] .and. ! empty(VEN->Mont)
  if VEN->Mont != ntom(nMontDoc,nDecPos)
    RETURN .f. if ! Confirm( ;
      MsgIdJnlDoc() + " : Inhalt stimmt nicht berein mit Gesamtbetrag !", ;
      "Gesamtbetrag " + ;
      ltrim(ntom(nMontDoc,nDecPos)) + ;
      " eintragen (J/N) ?", MSG_NO ;
    )
  endif
endif
VEN->Mont  := ntom(nMontDoc,nDecPos)
* 20061020 : Wenn DEF_VENREMISE, dann wurden bei JNLATTR_T die VNR nicht
* angewendet. Und insbesondere VEN->MontT (wenn keine VNR).
#ifdef DEF_VENREMISE
  VEN->MontT := ntom(nMTVA,nDecPos)
  * VEN->MontR := ntom(nMontR,nDecPos)
  for i := 1 to len(aVnr)
    VEN->&(aVnr[i][VNR_FLDNAME]) := ntom(aVnr[i][VNR_MONT],nDecPos)
  next i
#endif
#ifdef DEF_PRIXR
  VEN->SK := ntom(nSK,nDecPos)
#endif DEF_PRIXR
RETURN .t.

**
** VenMontDb()
** wird nur fr VEN->_MontDb benutzt [19980414]
**
FUNCTION VenMontDb()
local aMvt   := {}
local nHTVA := 0
local nMTVA := 0
local i
* local nDecPos := DevDecPos(VEN->IdDev)
local lOkay:= .f.
local jnl := JnlLocate(VEN->IdJnl)
local a
RETURN space(LenMont()) if eof()
RETURN space(LenMont()) if (a:= VenVnlInit(jnl)) == NIL
open area oVnl(VEN->Etat), oGen(), oArt(), oNew(), oVna()
  lOkay := .t.
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                   .and. FIELD->IdJnl == VEN->IdJnl
    if ! VnlVarCollect()
      lOkay := .f.
      exit
    endif
    if ! VnlMvtCollect(jnl,aMvt)
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
if lOkay
  #ifdef DEF_VENREMISE
    VenMvtRemise(aMvt)
  #endif
  #ifdef DEF_FRF
    VenFrfCollect(jnl,aMvt)
  #endif DEF_FRF
  VenMvtRound(aMvt,jnl)
  for i := 1 to len(aMvt)
    if aMvt[i][MVT_ISBASE]
      nHTVA += aMvt[i][MVT_MONTDB]
                     #ifdef DEF_TAX
    else
      if empty(aMvt[i][MVT_TAX][TAX_GENTIERS])
        nMTVA += aMvt[i][MVT_MONTDB]
      endif
                     #endif DEF_TAX
    endif
  next i
endif
VnlRestore(a)
RETURN ntom(nHTVA + nMTVA) // ,nDecPos)

**
** VenMvtRound()
**
FUNCTION VenMvtRound( aMvt, jnl )
local i
local nDevDecPos := DevDecPos(VEN->IdDev)
local nDbDecPos := DevDecPos(DevDefault(VEN->Periode))
* local nCours := val(VEN->Cours)
* local nTaxDecPos := max(nDevDecPos,jnl[JNL_TAXDECPOS])
for i := 1 to len(aMvt)
  aMvt[i][MVT_MONT]   := round(aMvt[i][MVT_MONT],nDevDecPos)
  aMvt[i][MVT_MONTDB] := round(VenDev2Db(aMvt[i][MVT_MONT]),nDbDecPos)
next i
RETURN .t. // NIL // nUmsatz


**
**
FUNCTION VenMvtUmsatz(aMvt)
local i
local nUmsatz := 0
for i := 1 to len(aMvt)
  if aMvt[i][MVT_ISBASE]
    nUmsatz += aMvt[i][MVT_MONTDB]
  endif
next i
if VEN->DC != PrtDC(PAR->IdPrt)
  nUmsatz := - nUmsatz
endif
RETURN nUmsatz


#ifdef DEF_VENREMISE

**
** VenMvtRemise()
**
/**
  Bei EH muss VEN->MontR auch dann ausgefllt sein, wenn VEN->Remise
  leer ist, weil sonst MontS nicht stimmt. VNR_XLWHEN muss bei EH
  also immer auf .t. stehen. Was zur Folge hat, dass die Gesamtbetr„ge
  jedesmal nochmal gerundet werden.
**/
FUNCTION VenMvtRemise( aMvt )
local i
local j
local nDevDecPos
local nDbDecPos
local nCours
local nRemise // := VenRemise()
local aVnr := VenVnrLoad()
local lWhen
RETURN {} if len(aVnr) == 0
nDevDecPos := DevDecPos(VEN->IdDev)
nDbDecPos := DevDecPos(DevDefault(VEN->Periode))
for j := 1 to len(aVnr)
  RETURN {} if (lWhen := xparse(aVnr[j][VNR_XLWHEN])) == NIL
  RETURN {} if (nRemise := xparse(aVnr[j][VNR_XNMULT])) == NIL
  for i := 1 to len(aMvt)
    // VNR_MONT : Betrag *vor* Anwendung der betreffenden Remise
    if aMvt[i][MVT_ISBASE]
      aVnr[j][VNR_MONT] += aMvt[i][MVT_MONT]
    endif
    if lWhen
      aMvt[i][MVT_MONT]   := round(aMvt[i][MVT_MONT]*nRemise,nDevDecPos)
      aMvt[i][MVT_MONTDB] := round(VenDev2Db(aMvt[i][MVT_MONT]),nDbDecPos)
      * aMvt[i][MVT_BASE]   := round(aMvt[i][MVT_BASE]*nRemise,nDevDecPos)
      * aMvt[i][MVT_BASEDB] := round(VenDev2Db(aMvt[i][MVT_BASE]),nDbDecPos)
      * aMvt[i][MVT_TAXE]   := round(aMvt[i][MVT_BASE]*aMvt[i][MVT_TAX][TAX_TAUX]/100,nDevDecPos)
      * aMvt[i][MVT_TAXEDB] := round(aMvt[i][MVT_BASEDB]*aMvt[i][MVT_TAX][TAX_TAUX]/100,nDbDecPos)
    endif
  next i
next j
RETURN aVnr


#endif DEF_VENREMISE

**
** VenCarry().
** Bei HK mssen die Felder IdMfc, Auteur,... vom Auftrag in die
** Rechnung bernommen werden.
**
FUNCTION VenCarry(aFields)
local cMatch := VEN->Match
local aValues := NIL
local i
RETURN .t. if empty(cMatch)
open area oVen()
  seek cMatch
  if ! eof()
    aValues := {}
    for i := 1 to len(aFields)
      aadd(aValues,&("VEN->"+aFields[i]))
    next i
  endif
close area
RETURN .f. if aValues == NIL
for i := 1 to len(aFields)
  &("VEN->"+aFields[i]) := aValues[i]
next i
RETURN .t.

FUNCTION MsgIfcFail
#ifdef LG_GERMAN
  RETURN " : ohne Fakturierungsanweisung !"
#endif
#ifdef LG_FRENCH
  RETURN " : sans instruction de facturation !"
#endif
#ifdef LG_EN
  RETURN " : no possible Billing Rule !"
#endif

#ifdef DEF_STK

**
** VnlQtsCollect()
**
FUNCTION VnlQtsCollect(cIdArt,nQte,aQts,cDC,cIdSer,nMont)
local i
local aStk := StkList()
RETURN NIL if ARTATTR_S $ ART->Attrib
for i := 1 to len(aStk)
  if &(aStk[i][STK_EXPR])
    if aStk[i][STK_DC] == cDC
      QtsCollect(aQts,cIdArt,aStk[i],nQte,cIdSer,nMont)
    else
      QtsCollect(aQts,cIdArt,aStk[i],-nQte,cIdSer,-nMont)
    endif
  endif
next i
RETURN NIL

**
** QtsCollect()
**
FUNCTION QtsCollect( ;
 aQts, cIdArt, ;
 stk, nQte, cIdSer, nMont ;
)
local i
local qts := NIL
for i := 1 to len(aQts)
  if aQts[i][QTS_STK][STK_IDSTK] == stk[STK_IDSTK]
    if aQts[i][QTS_IDART] == cIdArt
      if aQts[i][QTS_IDSER] == cIdSer
        qts := aQts[i]
      endif
    endif
  endif
next i
if qts == NIL
  qts := array(QTS_ALEN)
  qts[QTS_STK]     := stk // [STK_IDSTK]
  * qts[QTS_TYPE]    := stk[STK_TYPE]
  qts[QTS_IDART]   := cIdArt
  qts[QTS_IDSER]   := cIdSer
  qts[QTS_QTE]     := nQte
  qts[QTS_MONT]    := nMont
  aadd(aQts, qts)
else
  qts[QTS_QTE]   += nQte
  qts[QTS_MONT]  += nMont
endif
if ! empty(stk[STK_XUVALUE])
  RETURN .f. if (qts[QTS_VALUE]:=xparse(stk[STK_XUVALUE])) == NIL
endif
RETURN .t.

**
** QtsUpdate()
**
FUNCTION QtsUpdate(aQts,dDate)
local i
local lOkay := .f.
local cMac
open area oArt()
  lOkay := .t.
  for i := 1 to len(aQts)
    Purzel()
    seek aQts[i][QTS_IDART]
    if ! eof()
      if ddRecLock()
        cMac := "ART->" + aQts[i][QTS_STK][STK_IDSTK]
        if aQts[i][QTS_STK][STK_TYPE] == STKTYPE_QTE
          &cMac := ntoq(qton(&cMac) + aQts[i][QTS_QTE],ART->QteForm)
        elseif aQts[i][QTS_STK][STK_TYPE] == STKTYPE_DATE
          &cMac := dDate
        elseif aQts[i][QTS_STK][STK_TYPE] == STKTYPE_PU
          if aQts[i][QTS_QTE] != 0
            &cMac := ntom(aQts[i][QTS_MONT] / aQts[i][QTS_QTE])
          endif
        elseif aQts[i][QTS_STK][STK_TYPE] == STKTYPE_LAST
          &cMac := aQts[i][QTS_VALUE]
        endif
        unlock record
      endif
    endif
  next i
close area
#ifdef DEF_SER
  open area oSer(), oArt()
    lOkay := .t.
    for i := 1 to len(aQts)
      Purzel()
      if ! empty(aQts[i][QTS_IDSER])
        if ArtExist(aQts[i][QTS_IDART])
          if SerExist(aQts[i][QTS_IDSER])
            if ddRecLock()
              cMac := "SER->" + aQts[i][QTS_STK][STK_IDSTK]
              if aQts[i][QTS_STK][STK_TYPE] == STKTYPE_QTE
                &cMac := ntoq(qton(&cMac) + aQts[i][QTS_QTE],ART->QteForm)
              elseif aQts[i][QTS_STK][STK_TYPE] == STKTYPE_DATE
                &cMac := dDate
              elseif aQts[i][QTS_STK][STK_TYPE] == STKTYPE_PU
                if aQts[i][QTS_QTE] != 0
                  &cMac := ntom(aQts[i][QTS_MONT] / aQts[i][QTS_QTE])
                endif
              endif
              unlock record
            else
              lOkay := .f.
              exit
            endif
          else
            lOkay := .f.
            exit
          endif
        else
          lOkay := .f.
          exit
        endif
      endif
    next i
  close area
#endif DEF_SER
RETURN lOkay

FUNCTION MsgStkReset
RETURN "Lagerbest„nde neu rechnen"

**
** StkReset()
**
FUNCTION StkReset(dDate,cIdJnl,dDate2)
local i
local lOkay := .f.
local lDoit := .t.
* local cIdJnl := space(10)
* local cPeriode := space(LEN_PERIODE)
* local dDate := ctod("")
* local cMac
* local aStk := StkList()
local nCount := 0
local aQts
local aJnl
* local cAdditive := BUTTON_OFF
* local jnl
default dDate2 to ctod("")
*open window (MsgStkReset()) size 5,50 help STKRESET
*say "Ab Datum "
*get dDate // cPeriode picture PIC_ID pick PickPer(cPeriode)
*WinCr()
*say "Nur folgende Journale "
*get cIdJnl picture PIC_ID
*WinCr()
*get cAdditive checkbox
*say " additiv"
*nKey := ReadScr()
*close window
*RETURN NIL if nKey == K_ESC
*RETURN NIL if ! Confirm( ;
*  MsgStkReset() + " : " + MsgSure(),NIL,MSG_NO,"STKRESET" ;
*)
* SendConsole("START : " + MsgStkReset())
*MsgDisplay(MsgStkReset() + "...")
*if cAdditive == BUTTON_OFF
*  open area oArt()
*    lOkay := .t.
*    go top
*    do while ! eof()
*      if TaskInter() ; lOkay := .f. ; exit ; endif
*      MsgDisp2("(1) " + ntrim0(++nCount * 100 / lastrec()) + "%" )
*      if ddRecLock()
*        for i := 1 to len(aStk)
*          cMac := "ART->" + aStk[i][STK_IDSTK]
*          if aStk[i][STK_TYPE] == STKTYPE_DATE
*            if &cMac >= dDate
*              &cMac := ctod("")
*            endif
*          else
*            &cMac := ""
*          endif
*        next i
*        unlock record
*      else
*        lOkay := .f.
*        exit
*      endif
*      skip
*    enddo
*  close area
*  RETURN NIL if ! lOkay
*endif
#ifdef DEF_ODS
  lOkay := .f.
  aJnl := JnlList({|j| j[JNL_ALIAS] == "ODS" .and. JNLATTR_Q $ j[JNL_ATTRIB] })
  open area oOds(), oArt()
    lOkay := .t.
    nCount := 0
    for i := 1 to len(aJnl)
      * MsgDisplay(aJnl[i][JNL_IDJNL] + "...")
      if empty(cIdJnl) .or. aJnl[i][JNL_IDJNL] $ cIdJnl
        softseek aJnl[i][JNL_IDJNL]
        do while ! eof() .and. ODS->IdJnl == aJnl[i][JNL_IDJNL]
          MsgDisp2("(3) " + ntrim0(++nCount * 100 / lastrec()) + "%" )
          * if ODS->Periode >= cPeriode
          if empty(dDate) .or. ODS->Date >= dDate
          if empty(dDate2) .or. ODS->Date <= dDate2
            if ODS->Etat == DocStatClosed()
              aQts := {}
              open area oOdl()
                softseek ODS->IdJnl + ODS->IdDoc
                do while ! eof() .and. ODL->IdDoc == ODS->IdDoc ;
                                 .and. ODL->IdJnl == ODS->IdJnl
                  if ArtExist(ODL->IdArt)
                    VnlQtsCollect( ;
                      ODL->IdArt, ;
                      qton(ODL->Qte), ;
                      aQts, ;
                      ODL->DC, OdlIdSer(), val(ODL->Mont) ;
                    )
                  else
                    lOkay := Confirm( ;
                      MsgIdJnlDoc() + " : " + SetMsg(), ;
                      MsgContinue() ;
                    )
                  endif
                  if TaskInter() ; lOkay := .f. ; exit ; endif
                  skip
                enddo
              close area
              QtsUpdate(aQts,ODS->Date)
            endif
          endif
          endif
          if ! lOkay .or. TaskInter() ; lOkay := .f. ; exit ; endif
          skip
        enddo
      endif
      if ! lOkay .or. TaskInter() ; lOkay := .f. ; exit ; endif
    next i
  close area
  RETURN .f. if ! lOkay
#endif DEF_ODS
#ifdef DEF_VEN
  aJnl := JnlList({|j| j[JNL_ALIAS] == "VEN" .and. JNLATTR_Q $ j[JNL_ATTRIB]})
  open area oVen(), oArt(), oPar(), oVna()
    lOkay := .t.
    nCount := 0
    for i := 1 to len(aJnl)
      if empty(cIdJnl) .or. aJnl[i][JNL_IDJNL] $ cIdJnl
        softseek aJnl[i][JNL_IDJNL]
        do while ! eof() .and. VEN->IdJnl == aJnl[i][JNL_IDJNL]
          MsgDisp2("(2) " + ntrim0(++nCount * 100 / lastrec()) + "%" )
          if empty(dDate) .or. VEN->Date >= dDate
          if empty(dDate2) .or. VEN->Date <= dDate2
            if VEN->Etat == DocStatClosed()
              seek VEN->IdPar in PAR
              aQts := {}
              open area oVnl(VEN->Etat)
                softseek VEN->IdJnl + VEN->IdDoc
                do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                                 .and. FIELD->IdJnl == VEN->IdJnl
                  if FIELD->Code == LNCODE_ART .or. FIELD->Code == LNCODE_ARTFIXE
                    if ArtExist(left(FIELD->IdArt,LenIdArt()))
                      #ifdef DEF_VNA
                        seek VNL->IdJnl+VNL->IdDoc+VNL->Line in VNA
                        if eof() in VNA
                          lDoit := .t.
                        else
                          lDoit := VNA->Satis != VNASATIS_D
                        endif
                      #endif DEF_VNA
                      if lDoit
                        VnlQtsCollect( ;
                          left(FIELD->IdArt,LenIdArt()), ;
                          qton1(FIELD->Qte), ;
                          aQts, ;
                          VEN->DC, VnlIdSer(), ;
                          VenDev2Db(val(FIELD->cMont)) ;
                        )
                      endif
                    else
                      lOkay := Confirm( ;
                        MsgIdJnlDoc() + " : " + SetMsg(), ;
                        MsgContinue() ;
                      )
                    endif
                  endif
                  if TaskInter() ; lOkay := .f. ; exit ; endif
                  skip
                enddo
              close area
              QtsUpdate(aQts,VEN->Date)
            endif
          endif
          endif
          if ! lOkay .or. TaskInter() ; lOkay := .f. ; exit ; endif
          skip
        enddo
      endif
      if ! lOkay .or. TaskInter() ; lOkay := .f. ; exit ; endif
    next i
  close area
  RETURN .f. if ! lOkay
#endif DEF_VEN
*#ifdef DEF_PRD
*  aJnl := JnlList({|j| j[JNL_ALIAS] == "PRD" })
*  open area oPrd(), oArt()
*    nCount := 0
*    for i := 1 to len(aJnl)
*      if empty(cIdJnl) .or. aJnl[i][JNL_IDJNL] $ cIdJnl
*        softseek aJnl[i][JNL_IDJNL]
*        do while ! eof() .and. PRD->IdJnl == aJnl[i][JNL_IDJNL]
*          MsgDisp2("(4) " + ntrim0(++nCount * 100 / lastrec()) + "%" )
*          * if PRD->Periode >= cPeriode
*          if empty(dDate) .or. PRD->Date >= dDate
*            if PRD->Etat == DocStatClosed()
*              * if (jnl := JnlLocate(PRD->IdJnl)) != NIL
*                aQts := {}
*                open area oOdl()
*                  softseek PRD->IdJnl + PRD->IdDoc
*                  do while ! eof() .and. PRL->IdDoc == PRD->IdDoc ;
*                                   .and. PRL->IdJnl == PRD->IdJnl
*                    if ArtExist(PRL->IdArt)
*                      VnlQtsCollect( ;
*                        PRL->IdArt, ;
*                        qton1(PRL->Qte), ;
*                        aQts, ;
*                        aJnl[i][JNL_DC] ;
*                      )
*                    else
*                      lOkay := .f.
*                      exit
*                    endif
*                    if TaskInter() ; lOkay := .f. ; exit ; endif
*                    skip
*                  enddo
*                close area
*                QtsUpdate(aQts)
*              * endif
*            endif
*          endif
*          if ! lOkay .or. TaskInter() ; lOkay := .f. ; exit ; endif
*          skip
*        enddo
*      endif
*      if ! lOkay .or. TaskInter() ; lOkay := .f. ; exit ; endif
*    next i
*  close area
*  RETURN NIL if ! lOkay
*#endif DEF_PRD
* SendConsole("END : " + MsgStkReset())
RETURN lOkay

#endif DEF_STK

#ifdef DEF_HOLZ

FUNCTION VenStmCopy(cIdPrj,xlStmFilter)
local cLine
local aTagActions := {}
local aStm := {}
local i
local cIdJnl := VEN->IdJnl
local cIdDoc := VEN->IdDoc
default xlStmFilter to "empty(STM->" + cIdJnl + "IdDoc)"
default cIdPrj to VEN->IdPrj
KeyGoBottom(cIdDoc, indexkey() ) // "STM->IdJnl+STM->IdDoc" )
cLine := NextNum(&("STM->"+cIdJnl+"Line"))
open area oStm()
  ddSetOrder(ORD_STM_PRJ)
  if empty(cIdPrj)
    go top
  else
    softseek cIdPrj
  endif
  do while ! eof()
    if TaskInter() ; exit ; endif
    if ! empty(cIdPrj) .and. STM->IdPrj != cIdPrj
      exit
    endif
    * if &("empty(STM->"+cIdJnl+"IdDoc)")
    if &xlStmFilter
      * if ! STMATTR_H $ STM->Attrib
        if len(aStm) < 3900
          aadd(aStm, { recno(), .f.})
          MsgDisplay(ntrim(len(aStm)) + " Baumst„mme gefunden...")
        else
          Warning(;
            "Mehr als 4000 Eintr„ge !",;
            "Es werden nicht alle angezeigt !" ;
          )
          exit
        endif
      * endif
    endif
    skip
  enddo
close area
* if len(aStm) == 0
*   Warning("Keine Baumst„mme zu bernehmen !")
*   RETURN MnuDone()
* endif
SetMsg(ntrim(len(aStm)) + " Baumst„mme gefunden.")
aadd(aTagActions, { K_SPACE, {|tag| StmToggle(tag) } } )
aadd(aTagActions, { asc("*"), {|| StmInvert(aStm) } } )
open area oStm()
  browse array aStm using {|stm| StmLine(stm) } ;
                    actions aTagActions ;
                    help "STMTAG" ;
                    delete .f. ;
                    legend (LEG_STMTAG) ;
                    title (MSG_STMCOPY) ;
                    posit {|a,x| StmPosit(a,x) }
close area
RETURN .f. if lastchoice() == 0
for i := 1 to len(aStm)
  if aStm[i][2]
    goto aStm[i][1]
    if ddRecLock()
      if PreStmCopy()
        // STM->IdJnl := VEN->IdJnl
        &("STM->"+cIdJnl+"IdDoc") := VEN->IdDoc
        &("STM->"+cIdJnl+"Line") := cLine
        // STM->Line  := cLine
      endif
      unlock record
    endif
    cLine := NextNum(cLine)
  endif
next i
ddGoBottom(.t.)
RETURN .t.

STATIC FUNCTION StmLine(stm)
local cLine := if(stm[2],BUTTON_ON,BUTTON_OFF)
goto stm[1]
cLine += " " + STM->IdStm
cLine += " " + STM->Laenge
cLine += " " + STM->Umfang
cLine += " " + STM->Durchm
cLine += " " + STM->Menge
cLine += " " + STM->IdPrj
cLine += " " + STM->IdCls
cLine += " " + STM->Attrib
cLine += " " + STM->Faeller // Achtung nur bei POHLEN vorhanden
cLine += " " + trim1(STM->Bemerk)
cLine += " " + STM->IdArt
RETURN padr(cLine,76)

STATIC FUNCTION StmToggle(tag)
tag[2] := ! tag[2]
RETURN K_DOWN

STATIC FUNCTION StmInvert(aTag)
local i
for i := 1 to len(aTag)
  aTag[i][2] := ! aTag[i][2]
next i
RETURN K_ALT_F5

FUNCTION StmPosit(a,x)
local i
x := GetIdStm(x)
for i := 1 to len(a)
  goto a[i][1]
  RETURN i if STM->IdStm == x
next i
RETURN 0

FUNCTION VenStmSort(nOrder)
local cIdJnl := VEN->IdJnl
local cIdDoc := VEN->IdDoc
local cLine := space(LEN_POS)
local lOkay := .f.
default nOrder to ORD_STM_ID
MsgDisplay("Baumst„mme sortieren : "+MsgWorking())
open area oStm()
  lOkay := .t.
  ddSetOrder(nOrder)
  go top
  do while lOkay .and. ! eof()
    if TaskInter()
      lOkay := .f.
      exit
    endif
    if &("STM->"+cIdJnl+"IdDoc") == cIdDoc
      if ddRecLock()
        cLine := NextNum(cLine)
        &("STM->"+cIdJnl+"Line") := cLine
      else
        lOkay := .f.
      endif
    endif
    skip
  enddo
close area
RETURN .t.

#endif DEF_HOLZ

#endif DEF_VEN

#ifdef DEF_HST

**
**  HstUndo()
**
FUNCTION HstUndo(cIdJnl,cIdDoc,cPeriode,aCtp,aCtg,aPar,aGen)
local lOkay := .f.
open area oHst(), oGen()
  lOkay := .t.
  ddSetOrder(ORD_HST_DOC)
  softseek cIdJnl + cIdDoc
  do while ! eof() .and. HST->IdJnl == cIdJnl ;
                   .and. HST->IdDoc == cIdDoc
    if ddRecLock()
      if ! empty(HST->IdPar)
        DictAddItem(aPar, HST->IdPar)
        #ifdef DEF_CTP
          if HST->DC == DC_DEBIT
            CtpCollect( ;
              aCtp, HST->IdCtr, HST->IdPar, ;
              cPeriode, ;
              - val(HST->Mont), 0, 0 ;
            )
          else
            CtpCollect( ;
              aCtp, HST->IdCtr, HST->IdPar, ;
              cPeriode, ;
              0, - val(HST->Mont), 0 ;
            )
          endif
        #endif DEF_CTP
      endif
      if GenExist(HST->IdGen)
        if GENATTR_L $ GEN->Attrib
          DictAddItem(aGen, HST->IdGen)
        endif
        #ifdef DEF_CTG
          if HST->DC == DC_DEBIT
            CtgCollect( ;
              aCtg,HST->IdGen, ;
              cPeriode, ;
              - val(HST->Mont), 0 ;
            )
          else
            CtgCollect( ;
              aCtg,HST->IdGen, ;
              cPeriode, ;
              0, - val(HST->Mont) ;
            )
          endif
        #endif DEF_CTG
      elseif ! Confirm(SetMsg(),MsgContinue())
        lOkay := .f.
        unlock record
        exit
      endif
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

#endif DEF_HST


#ifdef DEF_JNL

FUNCTION DocIsChrono(jnl)
local nRecNo   := recno()
local cIdJnl   := FIELD->IdJnl
local cIdDoc   := FIELD->IdDoc
local cPeriode := FIELD->Periode
local dDate    := FIELD->Date
local lOkay := .t.
local nOrder := indexord()
ddSetOrder(1) // ORD_VEN_ID
skip -1
if ! bof() .and. FIELD->IdJnl == cIdJnl
  if FIELD->Periode > cPeriode
    SetMsg( ;
      "Periodenfolge " + FIELD->Periode + " -> " + ;
      cPeriode + MsgNotAllowed() ;
    )
    lOkay := .f.
  elseif dDate < FIELD->Date
    SetMsg( ;
      "Datumfolge " + dtoc(FIELD->Date) + " -> " + ;
      dtoc(dDate) + MsgNotAllowed() ;
    )
    lOkay := .f.
  elseif FIELD->Etat != DocStatClosed()
    SetMsg(MsgPrevDoc() + MsgNotClosed())
    lOkay := .f.
  elseif jnl[JNL_SEQTYPE]==SEQTYPE_E .or. jnl[JNL_SEQTYPE]==SEQTYPE_Y
    if substr(cIdDoc,3) != NextNum(substr(FIELD->IdDoc,3))
      if PerYear(cPeriode) == PerYear(FIELD->Periode)
        SetMsg( ;
          "Nummernfolge " + FIELD->IdDoc + " -> " + cIdDoc + ;
          MsgNotAllowed() ;
        )
        lOkay := .f.
      endif
    endif
  endif
endif
ddSetOrder(nOrder)
goto nRecNo
RETURN lOkay

FUNCTION MsgCheckIdDoc()
#ifdef LG_FRENCH
  RETURN " : nø de document invalide pour p‚riode "
#endif
#ifdef LG_GERMAN
  RETURN " : ungltige Dokumentnummer fr Periode "
#endif
#ifdef LG_EN
  RETURN " : invalid document number for Period "
#endif

FUNCTION MsgNotAllowed()
#ifdef LG_FRENCH
  RETURN " : non permis !"
#else
  RETURN " : nicht erlaubt !"
#endif

#endif DEF_JNL



*#ifdef DEF_PRD
*
***
*** PrdDlgClose()
***
*FUNCTION PrdDlgClose()
*local jnl := JnlLocate(PRD->IdJnl)
*RETURN .f. if jnl == NIL
*if PRD->Etat == DocStatNew()
*  SetMsg("Registrieren verweigert. Dokument nicht fertig eingegeben.")
*  RETURN .f.
*elseif PRD->Etat == DocStatOpen()
*  RETURN .f. if ! ddRecLock()
*  ddRefreshCurrent()
*  if USRATTR_Y $ UsrAttrib() .or. Confirm( ;
*    MsgIdJnlDoc() + MsgClose(), NIL, ;
*    MSG_YES, "WRN011" ;
*  )
*    if PrdClose(jnl)
*      PRD->Etat := DocStatClosed()
*      SetMsg( MsgIdJnlDoc() + MsgCloseOkay() )
*      ddRefreshCurrent()
*    else
*      Warning( MsgIdJnlDoc() + MsgCloseFail() )
*    endif
*  endif
*  unlock record
*elseif PRD->Etat == DocStatClosed()
*  RETURN .f. if ! USRATTR_S $ UsrAttrib()
*  RETURN .f. if ! ddRecLock()
*  if USRATTR_Y $ UsrAttrib() .or. Confirm( ;
*    MsgIdJnlDoc() + MsgUndo(), MsgSure(), MSG_YES,"WRN002" ;
*  )
*    if PrdUndo(jnl)
*      PRD->Etat := DocStatOpen()
*      SetMsg( MsgIdJnlDoc() + MsgUndoDone() )
*    else
*      Warning(MsgIdJnlDoc() + MsgUndoFail())
*    endif
*  endif
*  ddRefreshCurrent()
*  unlock record
*endif
*RETURN MnuDone()
*
***
*** PrdClose() called from PrdDlgClose()
***
*FUNCTION PrdClose(jnl)
*local aQts := {}
*RETURN .f. if ! ArtExist(PRD->IdArt)
*RETURN .f. if ! PrdPreClose(jnl,aQts)
*#ifdef DEF_STK
*  RETURN .f. if ! QtsUpdate(aQts) // ,PRD->DC)
*#endif DEF_STK
*RETURN .t.
*
***
*** PrdUndo()
***
*FUNCTION PrdUndo(jnl)
*local aQts := {}
*local lOkay := .f.
*RETURN .f. if ! ArtExist(PRD->IdArt)
*open area oPrl(), oArt()
*  lOkay := .t.
*  softseek PRD->IdJnl + PRD->IdDoc
*  do while ! eof() .and. PRL->IdDoc == PRD->IdDoc ;
*                   .and. PRL->IdJnl == PRD->IdJnl
*    if ! ArtExist(PRL->IdArt)
*      lOkay := .f.
*      exit
*    endif
*    #ifdef DEF_STK
*      if JNLATTR_Q $ jnl[JNL_ATTRIB]
*        VnlQtsCollect(PRL->IdArt,-qton1(PRL->Qte),aQts,jnl[JNL_DC])
*      endif
*    #endif DEF_STK
*    skip
*  enddo
*close area
*RETURN .f. if ! lOkay
*#ifdef DEF_STK
*  RETURN .f. if ! QtsUpdate(aQts) // ,PRD->DC)
*#endif DEF_STK
*RETURN .t.
*
***
*** PrdPreClose()
***
*FUNCTION PrdPreClose(jnl,aQts)
*local lOkay := .f.
*open area oPrl(), oArt()
*  lOkay := .t.
*  softseek PRD->IdJnl + PRD->IdDoc
*  do while ! eof() .and. PRL->IdDoc == PRD->IdDoc ;
*                   .and. PRL->IdJnl == PRD->IdJnl
*    if ! ArtExist(PRL->IdArt)
*      lOkay := .f.
*      exit
*    endif
*    #ifdef DEF_STK
*      if JNLATTR_Q $ jnl[JNL_ATTRIB]
*        VnlQtsCollect(PRL->IdArt,qton1(PRL->Qte),aQts,jnl[JNL_DC])
*      endif
*    #endif DEF_STK
*    skip
*  enddo
*close area
*RETURN lOkay
*
*#endif DEF_PRD


#ifdef DEF_MVS

FUNCTION VenMvsGenerate(jnl,aMvs)
local i
local lOkay := .f.
open area oMvs()
  lOkay := .t.
  for i := 1 to len(aMvs)
    if dbAddRec()
      MVS->IdJnl     := VEN->IdJnl
      MVS->IdDoc     := VEN->IdDoc
      MVS->IdPar     := VEN->IdPar
      MVS->Periode   := VEN->Periode
      MVS->Date      := VEN->Date
      MVS->IdArt     := aMvs[i][MVS_IDART]
      MVS->Mont      := aMvs[i][MVS_MONT ]
      MVS->DC        := aMvs[i][MVS_DC   ]
      MVS->Qte       := aMvs[i][MVS_QTE  ]
      MVS->Line      := aMvs[i][MVS_LINE ]
      * if JNLATTR_V $ jnl[JNL_ATTRIB]
      *   MVS->QteVal    := aMvs[i][MVS_QTE  ]
      * endif
      unlock record
    else
      lOkay := .f.
      exit
    endif
  next i
close area
RETURN lOkay

#endif DEF_MVS

#ifdef DEF_ODS

**
** OdsDlgClose()
**
FUNCTION OdsDlgClose()
local jnl := JnlLocate(ODS->IdJnl)
local cDevise := SetDevise()
RETURN .f. if jnl == NIL
SetDevise(DevDefault(ODS->Periode))
if ODS->Etat == DocStatNew()
  SetMsg("Registrieren verweigert. Dokument nicht fertig eingegeben.")
  RETURN .f.
elseif ODS->Etat == DocStatOpen()
  RETURN .f. if ! ddRecLock()
  if USRATTR_Y $ UsrAttrib() .or. Confirm( ;
    MsgIdJnlDoc() + MsgClose(), NIL, ;
    MSG_YES, "WRN011" ;
  )
    if nextkey() == 0
      ddRefreshCurrent()
    endif
    if OdsClose(jnl)
      ODS->Etat := DocStatClosed()
      SetMsg( MsgIdJnlDoc() + MsgCloseOkay() )
      if nextkey() == 0
        ddRefreshCurrent()
      endif
    else
      Warning( SetMsg(), MsgIdJnlDoc() + MsgCloseFail() )
    endif
  endif
  unlock record
elseif ODS->Etat == DocStatClosed()
  RETURN .f. if ! USRATTR_S $ UsrAttrib()
  RETURN .f. if ! ddRecLock()
  if USRATTR_Y $ UsrAttrib() .or. Confirm( ;
    MsgIdJnlDoc() + MsgUndo(), MsgSure(), MSG_YES,"WRN002" ;
  )
    if OdsUndo(jnl)
      ODS->Etat := DocStatOpen()
      SetMsg( MsgIdJnlDoc() + MsgUndoDone() )
    else
      Warning(SetMsg(),MsgIdJnlDoc() + MsgUndoFail())
    endif
    if nextkey() == 0
      ddRefreshCurrent()
    endif
  endif
  unlock record
endif
SetDevise(cDevise)
RETURN MnuDone()

**
** OdsClose()
**
FUNCTION OdsClose(jnl)
local aQts := {}
local aMvs := {}
local aCts := {}
RETURN .f. if ! OdsPreClose(jnl,aQts,aCts,aMvs)
#ifdef DEF_STK
  RETURN .f. if ! QtsUpdate(aQts,ODS->Date)
#endif DEF_STK
#ifdef DEF_MVS
  RETURN .f. if ! OdsMvsGenerate(jnl,aMvs)
#endif DEF_MVS
#ifdef DEF_CTS
  RETURN .f. if ! CtsUpdate(aCts)
#endif DEF_CTS
RETURN .t.

**
** OdsMvsRebuild() called from Rebuild()
**
FUNCTION OdsMvsRebuild(jnl)
local aMvs := {}
local aCts := {}
local aQts := {}
RETURN .f. if ! OdsPreClose(jnl,aQts,aCts,aMvs)
#ifdef DEF_MVS
  RETURN .f. if ! OdsMvsGenerate( jnl, aMvs )
#endif DEF_MVS
RETURN .t.

**
** OdsUndo()
**
FUNCTION OdsUndo(jnl)
local aQts := {}
* local aMvs := {}
local aCts := {}
local lOkay := .f.
open area oOdl(), oArt()
  lOkay := .t.
  softseek ODS->IdJnl + ODS->IdDoc
  do while ! eof() .and. ODL->IdDoc == ODS->IdDoc ;
                   .and. ODL->IdJnl == ODS->IdJnl
    if ! ArtExist(ODL->IdArt)
      lOkay := .f.
      exit
    endif
    #ifdef DEF_STK
      if JNLATTR_Q $ jnl[JNL_ATTRIB]
        VnlQtsCollect(ODL->IdArt,-qton(ODL->Qte),aQts,ODL->DC,OdlIdSer(),-val(ODL->Mont))
      endif
    #endif DEF_STK
    * #ifdef DEF_MVS
    *   if JNLATTR_S $ jnl[JNL_ATTRIB]
    *     OdlMvsCollect(jnl,aMvs)
    *   endif
    * #endif DEF_MVS
    #ifdef DEF_CTS
      if JNLATTR_M $ jnl[JNL_ATTRIB]
        * 20030313 OdlCtsUndo(jnl,aCts)
        OdlCtsCollect(jnl,aCts,DcInvert(ODL->DC))
      endif
    #endif DEF_CTS
    skip
  enddo
close area
RETURN .f. if ! lOkay
#ifdef DEF_STK
  RETURN .f. if ! QtsUpdate(aQts,ODS->Date)
#endif DEF_STK
#ifdef DEF_MVS
  open area oMvs()
    lOkay := .t.
    softseek ODS->IdJnl + ODS->IdDoc
    do while ! eof() .and. MVS->IdDoc == ODS->IdDoc ;
                     .and. MVS->IdJnl == ODS->IdJnl
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
#endif DEF_MVS
#ifdef DEF_CTS
  RETURN .f. if ! CtsUpdate(aCts)
#endif DEF_CTS
RETURN lOkay

**
** OdsPreClose()
**
FUNCTION OdsPreClose(jnl,aQts,aCts,aMvs)
local lOkay := .f.
open area oOdl(), oArt()
  lOkay := .t.
  softseek ODS->IdJnl + ODS->IdDoc
  do while ! eof() .and. ODL->IdDoc == ODS->IdDoc ;
                   .and. ODL->IdJnl == ODS->IdJnl
    if ! ArtExist(ODL->IdArt)
      lOkay := .f.
      exit
    endif
    #ifdef DEF_STK
      if JNLATTR_Q $ jnl[JNL_ATTRIB]
        VnlQtsCollect(ODL->IdArt,qton(ODL->Qte),aQts,ODL->DC,OdlIdSer(),val(ODL->Mont))
      endif
    #endif DEF_STK
    #ifdef DEF_MVS
      if JNLATTR_S $ jnl[JNL_ATTRIB]
        OdlMvsCollect(jnl,aMvs)
      endif
    #endif DEF_MVS
    #ifdef DEF_CTS
      if JNLATTR_M $ jnl[JNL_ATTRIB]
        OdlCtsCollect(jnl,aCts,ODL->DC)
      endif
    #endif DEF_CTS
    if ! OnOdlPreClose()
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
RETURN lOkay

#ifdef DEF_MVS

FUNCTION OdlMvsCollect(jnl,aMvs)
local a := array(MVS_ALEN)
a[MVS_IDART] := ODL->IdArt
a[MVS_DC   ] := ODL->DC
a[MVS_QTE  ] := ODL->Qte
a[MVS_MONT ] := ODL->Mont
a[MVS_LINE ] := ODL->Line
aadd(aMvs,a)
RETURN NIL

FUNCTION OdsMvsGenerate(jnl,aMvs)
local i
local lOkay := .f.
open area oMvs()
  lOkay := .t.
  for i := 1 to len(aMvs)
    if dbAddRec()
      MVS->IdJnl     := ODS->IdJnl
      MVS->IdDoc     := ODS->IdDoc
      MVS->IdPar     := ODS->IdPar
      MVS->Periode   := ODS->Periode
      MVS->Date      := ODS->Date
      MVS->IdArt     := aMvs[i][MVS_IDART]
      MVS->Mont      := aMvs[i][MVS_MONT ]
      MVS->DC        := aMvs[i][MVS_DC   ]
      MVS->Qte       := aMvs[i][MVS_QTE  ]
      MVS->Line      := aMvs[i][MVS_LINE ]
      * if JNLATTR_V $ jnl[JNL_ATTRIB]
      *   MVS->QteVal    := aMvs[i][MVS_QTE  ]
      * endif
      unlock record
    else
      lOkay := .f.
      exit
    endif
  next i
close area
RETURN lOkay

#endif DEF_MVS

#ifdef DEF_CTS

**
** OdsCtsRebuild() called from Rebuild()
**
FUNCTION OdsCtsRebuild(jnl)
local aMvs := {}
local aCts := {}
local aQts := {}
RETURN .f. if ! OdsPreClose(jnl,aQts,aCts,aMvs)
RETURN .f. if ! CtsUpdate(aCts)
RETURN .t.


*
* FUNCTION OdlCtsUndo(jnl,aCts)
* local nQte   := qton(ODL->Qte)
* local nMont  := val(ODL->Mont)
* if ODL->DC == jnl[JNL_DC]
*   nMont  := - nMont
*   nQte   := - nQte
* endif
* RETURN CtsCollect( ;
*   aCts,ODL->IdArt,;
*   jnl, ODS->Periode, ;
*   nQte, nMont, space(3);
* )

**
** OdlCtsCollect()
**
FUNCTION OdlCtsCollect(jnl,aCts,cDC)
local nAnz   := VnlAnzahl()
local nQte   := qton(ODL->Qte)
local nMont  := val(ODL->Mont)
* 20030313 if ODL->DC != jnl[JNL_DC]
if cDC != jnl[JNL_DC]
  nMont  := - nMont
  nQte   := - nQte
  nAnz   := - nAnz
endif
RETURN CtsCollect( ;
  aCts,ODL->IdArt,;
  jnl, ODS->Periode, ;
  nAnz, nQte, nMont, space(3) ;
)

#endif DEF_CTS


#endif DEF_ODS


#ifdef DEF_CTG

FUNCTION HstCtgCollect(aCtg)
if HST->DC == DC_DEBIT
  CtgCollect( ;
    aCtg, ;
    HST->IdGen, ;
    HST->Periode, ;
    val(HST->Mont), 0 ;
  )
else
  CtgCollect( ;
    aCtg, ;
    HST->IdGen, ;
    HST->Periode, ;
    0, val(HST->Mont) ;
  )
endif
RETURN NIL


#endif DEF_CTG

#ifdef DEF_MVA

**
** OdaDlgClose()
**
FUNCTION OdaDlgClose(lRefresh)
local jnl := JnlLocate(ODA->IdJnl)
local aCta := {}
RETURN .f. if jnl == NIL
if ODA->Etat == DocStatNew()
  ODA->Etat := DocStatOpen() // ts ts ts... einfach so...
endif
if ODA->Etat == DocStatOpen()
  RETURN .f. if ! CheckIdDoc(jnl,ODA->IdDoc,ODA->Periode)
  *   Warning(SetMsg())
  *   RETURN .f.
  * endif
  if JNLATTR_F $ jnl[JNL_ATTRIB]
    if ! DocIsChrono(jnl)
      Warning(SetMsg())
      RETURN .f.
    endif
  endif
  RETURN .f. if ! PerSetDirty(jnl,ODA->Periode,ODA->Date,ODA->IdDoc)
  ** Fr die Best„tigung muss die vorher gew„hlte Zahlart natrlich
  ** schon am Bildschirm sichtbar sein. Sonst wundert sich der Benutzer...
  if ! USRATTR_Y $ UsrAttrib()
    if lRefresh .and. nextkey() == 0
      ddRefreshCurrent()
    endif
    if ! Confirm( ;
      MsgIdJnlDoc() + MsgClose(), NIL, ;
      MSG_YES, "WRN011" ;
    )
      RETURN .f.
    endif
  endif
  if OdaPreClose(aCta,ODA->IdJnl,ODA->IdDoc,ODA->IdPar,ODA->Periode)
    ODA->Etat := DocStatClosed()
    SetMsg( ODA->IdJnl + " " + ODA->IdDoc + MsgCloseOkay() )
    if lRefresh .and. nextkey() == 0
      ddRefreshCurrent()
    endif
    if TIMATTR_Z $ MemAttrib
      CtaUpdate(aCta)
    endif
    dbcommit()
  else
    Warning( SetMsg(), MsgIdJnlDoc() + MsgCloseFail() )
  endif
elseif ODA->Etat == DocStatClosed()
  RETURN .f. if ! USRATTR_S $ UsrAttrib()
  RETURN .f. if ! PreDocUndo()
  RETURN .f. if ! PerSetDirty(jnl,ODA->Periode,NIL,ODA->IdDoc)
  if USRATTR_Y $ UsrAttrib() .or. Confirm( ;
    MsgIdJnlDoc() + MsgUndo(), MsgSure(), MSG_YES,"WRN002" ;
  )
    if OdaUndo(ODA->IdJnl,ODA->IdDoc,aCta) // ,aMvgCtr)
      ODA->Etat := DocStatOpen()
      if TIMATTR_Z $ MemAttrib // jnl[JNL_ATTRIB]
        CtaUpdate(aCta)
      endif
      SetMsg( MsgIdJnlDoc() + MsgUndoDone() )
    else
      Warning(SetMsg(),MsgIdJnlDoc() + MsgUndoFail())
    endif
  endif
  if lRefresh .and. nextkey() == 0
    ddRefreshCurrent()
  endif
endif
RETURN MnuDone()

**
** OdaPreClose()
**
FUNCTION OdaPreClose(aCta,cIdJnl,cIdDoc,cIdPar,cPeriode)
local lOkay := .f.
* RETURN .f. if ! ParExist(cIdPar)
open area oMva(), oAna()
  lOkay := .t.
  ddSetOrder(ORD_MVA_DOC)
  softseek cIdJnl + cIdDoc
  do while ! eof() .and. MVA->IdDoc == cIdDoc ;
                   .and. MVA->IdJnl == cIdJnl
    if MVA->Periode != cPeriode
      if ddRecLock()
        MVA->Periode := cPeriode
        unlock record
      else
        lOkay := .f.
        exit
      endif
    endif
    if ! AnaExist(MVA->IdAna)
      lOkay := .f.
      exit
    endif
    if ! CtaCollect(aCta,MVA->Periode,val(MVA->Mont))
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
RETURN lOkay


**
** OdaUndo()
**
FUNCTION OdaUndo(cIdJnl,cIdDoc,aCta)
local lOkay := .f.
open area oMva(), oGen(), oAna()
  lOkay := .t.
  ddSetOrder(ORD_MVA_DOC)
  softseek cIdJnl + cIdDoc
  do while ! eof() .and. MVA->IdDoc == cIdDoc ;
                   .and. MVA->IdJnl == cIdJnl
    if ! CtaCollect(aCta,MVA->Periode,-val(MVA->Mont))
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
RETURN lOkay

#define CTY_IDANA    1
#define CTY_PERIODE  2
#define CTY_DEBIT    3
#define CTY_CREDIT   4
#define CTY_ALEN     4


FUNCTION CtaCollect(aCta,cPeriode,nMont)
local cta := NIL
local i
for i := 1 to len(aCta)
  if aCta[i][CTY_IDANA] == MVA->IdAna
    if aCta[i][CTY_PERIODE] == cPeriode
      cta := aCta[i]
    endif
  endif
next i
if cta == NIL
  cta := array(CTY_ALEN)
  cta[CTY_IDANA]   := MVA->IdAna
  cta[CTY_PERIODE] := cPeriode
  cta[CTY_DEBIT]   := 0
  cta[CTY_CREDIT]  := 0
  aadd(aCta,cta)
endif
if MVA->DC == DC_DEBIT
  cta[CTY_DEBIT] += nMont
else
  cta[CTY_CREDIT] += nMont
endif
**
** und jetzt noch mal dasselbe fr die Jahressummen...
cta := NIL
cPeriode := PerYear(cPeriode)
for i := 1 to len(aCta)
  if aCta[i][CTY_IDANA] == MVA->IdAna
    if aCta[i][CTY_PERIODE] == cPeriode
      cta := aCta[i]
    endif
  endif
next i
if cta == NIL
  cta := array(CTY_ALEN)
  cta[CTY_IDANA]   := MVA->IdAna
  cta[CTY_PERIODE] := cPeriode
  cta[CTY_DEBIT]   := 0
  cta[CTY_CREDIT]  := 0
  aadd(aCta,cta)
endif
if MVA->DC == DC_DEBIT
  cta[CTY_DEBIT] += nMont
else
  cta[CTY_CREDIT] += nMont
endif
RETURN .t.

**
** CtaUpdate()
**
FUNCTION CtaUpdate(aCta)
local i
local lOkay := .f.
open area oCta()
  lOkay := .t.
  for i := 1 to len(aCta)
    seek aCta[i][CTY_IDANA] + aCta[i][CTY_PERIODE]
    if eof()
      if dbAddRec()
        CTA->IdAna   := aCta[i][CTY_IDANA]
        CTA->Periode := aCta[i][CTY_PERIODE]
        CTA->Debit   := ntom(aCta[i][CTY_DEBIT])
        CTA->Credit  := ntom(aCta[i][CTY_CREDIT])
        unlock record
      else
        lOkay := .f.
        exit
      endif
    elseif ddRecLock()
      CTA->Debit   := ntom(val(CTA->Debit)  + aCta[i][CTY_DEBIT])
      CTA->Credit  := ntom(val(CTA->Credit) + aCta[i][CTY_CREDIT])
      unlock record
    else
      lOkay := .f.
      exit
    endif
  next i
close area
RETURN lOkay


#endif DEF_MVA



FUNCTION pick(xDestination,xuPick)
local uPick := &xuPick
RETURN .f. if uPick == NIL
&(xDestination) := uPick
RETURN .t.


* #ifdef DEF_HOLZ

#ifdef DEF_PRESTO

#ifdef DEF_VEN

// Terminplaner Rocatec


FUNCTION TrmVenList(dDate,cIdJnl,xlFilter,nOrder)
local c := ""
local nCount := 0
default nOrder to 4
RETURN SetMsg() if ! DbfScan(;
  {oVen(),oPar()},nOrder,cIdJnl+dtos(dDate),NIL,;
  xlFilter,{||nCount += 1, .t.};
)
RETURN c if nCount == 0
RETURN SetMsg() if ! DbfScan(;
  {oVen(),oPar()},nOrder,cIdJnl+dtos(dDate),NIL,;
  xlFilter,{||c += TrmOnVen(nCount), .t.};
)
RETURN c

STATIC FUNCTION TrmOnVen(nCount)
if nCount == 1
  RETURN ;
    timetrim(VEN->Time1)+"-"+timetrim(VEN->Time2)+" " ;
    + trim1(VEN->VnaMatch) ;
    + VEN->Etat+CR_LF;
    + trim1(ParName(VEN->IdPar),", ");
    + trim1(VEN->NB1)
endif
RETURN timetrim(VEN->Time1)+"-"+timetrim(VEN->Time2)+" " + trim(VEN->NB1)+CR_LF

FUNCTION TrmVenLst2(dDate,cIdJnl,xlFilter,nOrder)
local c := ""
default nOrder to 4
RETURN SetMsg() if ! DbfScan(;
  {oVen(),oPar()},nOrder,cIdJnl+dtos(dDate),;
  NIL,;
  xlFilter,{|| ;
    c += timetrim(VEN->Time1)+"-"+timetrim(VEN->Time2)+" " ;
    + trim(ParName(VEN->IdPar2))+CR_LF,;
    .t.};
)
RETURN c



#endif DEF_VEN

#endif DEF_PRESTO

FUNCTION OnTest(ad)
RETURN DoEvents(ad[AD_ONTEST])


