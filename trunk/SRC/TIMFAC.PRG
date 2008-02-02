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

* dieses .prg wurde komplett neu geschrieben (methods3.prg)

#ifdef LG_FRENCH
  #define MSG001  "Refus‚. Le document n'est pas encod‚ correctement."
  #define MSG002  "Il faut d'abord d‚lettrer les mouvements comptables !"
  * #define MSG003  " : cl“ture refus‚e."
  * #define MSG004  " a ‚t‚ cl“tur‚."
  #define MSG005  " a ‚t‚ r‚ouvert."
  * #define MSG006  " : r‚ouverture refus‚e."
  #define MSG007  "'Ancien solde' ne correspond pas au nouveau solde de "
  #define MSG008  "'Nouveau solde' ne correspond pas … l'ancien solde de "
  #define MSG009  "Refus‚. Cette p‚riode n'est pas ouverte."
  * #define MSG015  "G‚n‚ration automatique"
  #define MSG016  " sommer quantit‚s et montants"
  #define MSG017  " : traitement en cours..."
  #define MSG023  "Attribuer commande client"
  #define MSG024  "Article "
  #define MSG025  "Stock actuel   : "
  #define MSG026  "Stock minimum  : "
  #define MSG027  "… commander    : "
  #define MSG028  "Facturation automatique"
  static MSG029 := " r‚viser chaque document g‚n‚r‚"
  static MSG030 := "Lettrage automatique..."
  #define MSG031  " : prix d'achat "
  #define MSG032  " diffŠre du signal‚tique ("
  #define MSG033  "M = modifier le signal‚tique, I = laisser inchang‚, ESC = abandonner"
  #define MSG034  " : impossible de modifier le P.A. moyen."
  #define MSG035  " : impossible de modifier P.A. & date"
  #define MSG036  " : impossible de modifier quantit‚ en stock"
  * #ifdef DEF_JNL
  *   static MSG_CONFCLOSE := " : cl“turer ce document (O/N) ?"
  * #endif DEF_JNL
#endif
#ifdef LG_GERMAN
  #define MSG001  "Verweigert. Dokument nicht fertig eingegeben."
  #define MSG002  "Buchungen des Dokuments mssen zuerst entlettriert werden !"
  * #define MSG003  " : Registrierung verweigert."
  * #define MSG004  " wurde registriert."
  #define MSG005  " wurde entregistriert."
  * #define MSG006  " : Entregistrierung verweigert."
  #define MSG007  "'Alter Saldo' nicht derselbe wie 'Neuer Saldo' in "
  #define MSG008  "'Neuer Saldo' nicht derselbe wie 'Alter Saldo' in "
  #define MSG009  "Verweigert. Die Periode ist nicht offen."
  * #define MSG015  "Automatisch Erstellen"
  #define MSG016  " Mengen und Betr„ge summieren"
  #define MSG017  " : Bearbeitung l„uft..."
  #define MSG023  "Kundenbestellung zuweisen"
  #define MSG024  "Artikel "
  #define MSG025  "Aktueller Bestand : "
  #define MSG026  "Mindestbestand    : "
  #define MSG027  "zu bestellen      : "
  #define MSG028  "Automatik-Fakturierung"
  static MSG029 := " generierte Dokumente einzeln anzeigen"
  static MSG030 := "Automatik-Lettrierung..."
  #define MSG031  " : Einkaufspreis "
  #define MSG032  " anders als bisher ("
  #define MSG033  "M = Stammdaten anpassen, I = nicht „ndern, ESC = abbrechen"
  #define MSG034  " : Mittel-EK kann nicht eingetragen werden."
  #define MSG035  " : Neuer EK kann nicht eingetragen werden."
  #define MSG036  " : Neuer Bestand kann nicht eingetragen werden."
  *#ifdef DEF_JNL
  *#endif DEF_JNL
#endif
#ifdef LG_EN
  #define MSG001  "Refused. Document entry was aborted."
  * #define MSG006  " : reopening failed."
  #define MSG007  "'Start balance' differs from 'Final balance' in "
  #define MSG008  "'Final balance' differs from 'Start balance' in "
#endif

**
** Special actions
**
**

#ifdef DEF_FIN

**
** FinDlgClose() - (D‚)cl“turer document Ventes
**
FUNCTION FinDlgClose()
local jnl := JnlLocate(FIN->IdJnl)
local aPar := {}
local aGen := {}
local aCtp := {}
local aCtg := {}
* local aMvgCtr := {}
local i
RETURN .f. if jnl == NIL
SetDevise(DevDefault(FIN->Periode))
* SetDecPos(DevDecPos(DevDefault(FIN->Periode)))
if FIN->Etat == DocStatNew()
  SetMsg(MSG001)
  RETURN .f.
elseif FIN->Etat == DocStatOpen()
  RETURN .f. if ! CheckIdDoc(jnl,FIN->IdDoc,FIN->Periode)
  *   Warning(SetMsg())
  *   RETURN .f.
  * endif
  if JNLATTR_F $ jnl[JNL_ATTRIB]
    if ! DocIsChrono(jnl)
      Warning(SetMsg())
      RETURN .f.
    endif
  endif
  RETURN .f. if ! PerSetDirty(jnl,FIN->Periode,FIN->Date,FIN->IdDoc)
  RETURN .f. if ! ddRecLock()
  if USRATTR_Y $ UsrAttrib() .or. Confirm( ;
    MsgIdJnlDoc() + MsgClose(), NIL, ;
    MSG_YES, "WRN011" ;
  )
    if FinClose(jnl,aPar,aGen,aCtp,aCtg) // ,aMvgCtr)
      FIN->Etat := DocStatClosed()
      if JNLATTR_L $ jnl[JNL_ATTRIB]
        for i := 1 to len(aPar)
          if ! ParSatisfy(aPar[i])
            exit
          endif
        next i
        for i := 1 to len(aGen)
          if ! GenSatisfy(aGen[i])
            exit
          endif
        next i
      endif
      if TIMATTR_Z $ MemAttrib
        #ifdef DEF_CTP
          CtpUpdate(aCtp)
        #endif DEF_CTP
        #ifdef DEF_CTG
          CtgUpdate(aCtg)
        #endif DEF_CTG
      endif
      SetMsg( MsgIdJnlDoc() + MsgCloseOkay())
    else
      Warning( SetMsg(), MsgIdJnlDoc() + MsgCloseFail() ) // MSG003 )
    endif
  endif
  unlock record
elseif FIN->Etat == DocStatClosed()
  RETURN .f. if ! USRATTR_S $ UsrAttrib()
  RETURN .f. if ! PreDocUndo()
  RETURN .f. if ! PerSetDirty(jnl,FIN->Periode,NIL,FIN->IdDoc)
  RETURN .f. if ! ddRecLock()
  if USRATTR_Y $ UsrAttrib() .or. Confirm( ;
    MsgIdJnlDoc() + MsgUndo(), MsgSure(), MSG_YES,"WRN002" ;
  )
    if FinUndo(jnl)
      FIN->Etat := DocStatOpen()
    else
      Warning(SetMsg(), MsgIdJnlDoc() + MsgUndoFail()) // MSG006 )
    endif
  endif
  unlock record
endif
ddRefreshCurrent()
RETURN MnuDone()

#define FNLMVP_IDCTR    1
#define FNLMVP_DC       2
#define FNLMVP_IDPAR    3
#define FNLMVP_MONT     4
#define FNLMVP_IDOP     5
#define FNLMVP_MATCH    6
#define FNLMVP_DATE     7
#define FNLMVP_MONTDEV  8


FUNCTION FnlIdAna()
#ifdef DEF_ANAFIN
RETURN FNL->IdAna if HasOption("ANA")
#endif
RETURN ""

*#else
*  #xtranslate FnlIdAna() => (NIL)

#define HST_IDCTR   1
#define HST_IDGEN   2
#define HST_IDPAR   3
#define HST_DC      4
#define HST_MONT    5
#define HST_LINE    6
#define HST_DATE    7
#define HST_MATCH   8
#define HST_MONTDEV 9
#define HST_IDDEV  10 // 20010411
#define HST_IDANA  11 // 20071022
#define HST_ALEN   11

#define MVA_IDGEN  1
#define MVA_IDANA  2
#define MVA_DATE   3
#define MVA_LINE   4
#define MVA_DC     5
#define MVA_MONT   6
#define MVA_ALEN   6

**
** FinClose()
**
FUNCTION FinClose(jnl,aPar,aGen,aCtp,aCtg)
local nMont
local aHst := {}
local aMva := {}
local lOk := .f.
local ctr
local cIdGen
local cIdPar
local cPeriode := FIN->Periode
RETURN .f. if ! FinCheckSolde()
open area oFnl(), oPar(), oGen()
  lOk := .t.
  softseek FIN->IdJnl + FIN->IdDoc
  do while lOk .and. ! eof() ;
               .and. FNL->IdDoc == FIN->IdDoc ;
               .and. FNL->IdJnl == FIN->IdJnl
    nMont := val(FNL->Mont)
    if empty(FNL->IdCtr)
      cIdPar := ""
      cIdGen := left(FNL->IdCpt,LenIdGen())
    elseif (ctr := CtrLocate(FNL->IdCtr)) != NIL
      cIdPar := left(FNL->IdCpt,LenIdPar())
      cIdGen := ctr[CTR_IDGEN]
      if ParExist(cIdPar)
        DictAddItem(aPar,cIdPar)
        #ifdef DEF_CTP
          if FNL->DC == DC_DEBIT
            CtpCollect( ;
              aCtp, FNL->IdCtr, cIdPar, ;
              cPeriode , ;
              nMont, 0 , 0 ;
            )
          else
            CtpCollect( ;
              aCtp, FNL->IdCtr, cIdPar, ;
              cPeriode, ;
              0, nMont , 0 ;
            )
          endif
        #endif DEF_CTP
      else
        lOk := .f.
      endif
    else
      lOK := .f.
    endif
    if lOK
      if GenExist(cIdGen)
        if GENATTR_L $ GEN->Attrib
          DictAddItem(aGen,cIdGen)
        endif
      else
        lOk := .f.
        exit
      endif
      aadd(aHst, { ;
        FNL->IdCtr, ;     // HST_IDCTR
        cIdGen, ;         // HST_IDGEN
        cIdPar, ;         // HST_IDPAR
        FNL->DC, ;        // HST_DC
        FNL->Mont, ;      // HST_MONT
        FNL->Line, ;      // HST_LINE
        FNL->Date,;       // HST_DATE  20030222 FnlFinDate()
        FNL->Match, ;     // HST_MATCH
        FNL->MontDev,;    // HST_MONTDEV
        FNL->IdDev,;      // HST_IDDEV
        FnlIdAna();       // HST_IDANA
      } )                 // HST_ALEN
      #ifdef DEF_ANAFIN
        if ! empty(FnlIdAna()) // FNL->IdAna)
          aadd( aMva, {    ;
            cIdGen       , ; // MVA_IDGEN
            FNL->IdAna   , ; // MVA_IDANA
            FnlFinDate() , ; // MVA_DATE
            FNL->Line    , ; // MVA_LINE
            FNL->DC      , ; // MVA_DC
            FNL->Mont      ; // MVA_MONT
          } )                // MVA_ALEN
        endif
      #endif DEF_ANAFIN
    endif
    skip
  enddo
close area
RETURN .f. if ! lOk
* RETURN .t. if ! JNLATTR_G $ jnl[JNL_ATTRIB]
RETURN .t. if ! JnlDoHst(jnl,FIN->Periode)
RETURN FinHstGenerate(aHst,jnl,aCtg,aCtp,aPar,aGen,aMva)

FUNCTION FnlFinDate
RETURN FIN->Date if empty(FNL->Date)
RETURN FNL->Date

**
** FinUndo()
**
FUNCTION FinUndo(jnl)
local lOK := .f.
local aPar := {}
local aGen := {}
local aCtp := {}
local aCtg := {}
local i
#ifdef DEF_HST
  RETURN .f. if ! HstUndo(FIN->IdJnl,FIN->IdDoc,FIN->Periode,aCtp,aCtg,aPar,aGen)
#endif DEF_HST
#ifdef DEF_MVA
#ifdef DEF_ANAFIN
  RETURN .f. if ! MvaUndo(FIN->IdJnl,FIN->IdDoc)
#endif DEF_ANAFIN
#endif DEF_MVA
if TIMATTR_Z $ MemAttrib
  #ifdef DEF_CTP
    CtpUpdate(aCtp)
  #endif DEF_CTP
  #ifdef DEF_CTG
    CtgUpdate(aCtg)
  #endif DEF_CTG
endif
if JNLATTR_L $ jnl[JNL_ATTRIB]
  for i := 1 to len(aPar)
    if ! ParSatisfy(aPar[i])
      exit
    endif
  next i
  for i := 1 to len(aGen)
    if ! GenSatisfy(aGen[i])
      exit
    endif
  next i
endif
RETURN .t.


FUNCTION FinHstGenerate(aHst,jnl,aCtg,aCtp,aPar,aGen,aMva)
local lOk := .f.
local i
local nDebit := 0
local nDevDebit := 0
local nDevDecPos // := DevDecPos(FIN->IdDev) // jnl[JNL_IDDEV])
local cIdDev // FW, die in der Gegenbuchung kommt
RETURN .f. if empty(jnl[JNL_DC])
if FIN->IdDev == DevDefault(FIN->Periode)
  cIdDev := ""
  * 20020314
  *open area oGen()
  *  seek jnl[JNL_IDGEN]
  *  if ! eof()
  *    cIdDev := GEN->IdDev
  *  endif
  *close area
  ** if empty(cIdDev)
  **   cIdDev := jnl[JNL_IDDEV]
  ** endif
  ** 20020109
  *if cIdDev == FIN->IdDev
  *  cIdDev := ""
  *endif
else
  cIdDev := FIN->IdDev
endif
nDevDecPos := DevDecPos(cIdDev)
open area oHst(), oPar()
  lOk := .t.
  for i := 1 to len(aHst)
    if ! empty(aHst[i][HST_IDPAR])
      if ! ParExist(aHst[i][HST_IDPAR])
        lOk := .f.
        exit
      endif
    endif
    if dbAddRec()
      HST->IdCtr   := aHst[i][HST_IDCTR]
      #ifdef DEF_CTRATTR
        if CTRATTR_L $ CtrAttrib(HST->IdCtr)
          HST->Satis := "*"
        endif
      #endif DEF_CTRATTR
      HST->IdGen   := aHst[i][HST_IDGEN]
      HST->IdPar   := aHst[i][HST_IDPAR]
      HST->IdJnl   := FIN->IdJnl
      HST->IdDoc   := FIN->IdDoc
      if JNLATTR_P $ jnl[JNL_ATTRIB] .and. ! empty(aHst[i][HST_DATE])
        HST->Periode := PerActive(aHst[i][HST_DATE])
      else
        HST->Periode := FIN->Periode
      endif
      if empty(aHst[i][HST_DATE])
        HST->Date    := FIN->Date
      else
        HST->Date    := aHst[i][HST_DATE]
      endif
      HST->Line    := aHst[i][HST_LINE]
      if empty(aHst[i][HST_MATCH])
        if empty(aHst[i][HST_DATE])
          if JNLATTR_M $ jnl[JNL_ATTRIB]
            HST->Match   := FIN->IdJnl + FIN->IdDoc
          else
            HST->Match   := right(dtos(FIN->Date),6) + HST->Line
          endif
        else
          HST->Match   := right(dtos(aHst[i][HST_DATE]),6)+HST->Line
        endif
      else
        HST->Match   := aHst[i][HST_MATCH]
      endif
      HST->DC      := aHst[i][HST_DC]
      HST->Mont    := aHst[i][HST_MONT]
      HST->MontDev := aHst[i][HST_MONTDEV]
      HST->IdDev   := aHst[i][HST_IDDEV]
      #ifdef DEF_ANA
      HST->IdAna   := aHst[i][HST_IDANA]
      #endif DEF_ANA
      ** [971230]
      * if PAR->IdDev != DevDefault()
      *   if jnl[JNL_IDDEV] == PAR->IdDev .or. jnl[JNL_IDDEV] == DevDefault()
      *     HST->MontDev := aHst[i][HST_MONTDEV]
      *   else
      *     HST->MontDev := ntom( ;
      *       val(aHst[i][HST_MONT]) / val(DevCours(PAR->IdDev)), ;
      *       DevDecPos(PAR->IdDev) ;
      *     )
      *   endif
      * endif
      if HST->DC == DC_DEBIT
        nDebit += val(HST->Mont)
        nDevDebit += val(HST->MontDev)
        CtgCollect( ;
          aCtg,;
          HST->IdGen, ;
          HST->Periode, ;
          val(HST->Mont), 0 ;
        )
      else
        nDebit -= val(HST->Mont)
        nDevDebit -= val(HST->MontDev)
        CtgCollect( ;
          aCtg,;
          HST->IdGen, ;
          HST->Periode, ;
          0, val(HST->Mont) ;
        )
      endif
      unlock record
      #ifdef DEF_FNA
        if ! HstFnaGenerate(aCtg)
          lOK := .f.
          exit
        endif
      #endif DEF_FNA
    else
      lOK := .f.
      exit
    endif
  next i
close area
RETURN .f. if ! lOK
if abs(nDebit) > DevTolerance(FIN->IdDev)
  if JNLATTR_K $ jnl[JNL_ATTRIB]
    lOK := .f.
    open area oHst()
      lOK := .t.
      if dbAddRec()
        HST->IdGen   := jnl[JNL_IDGEN]
        HST->IdJnl   := FIN->IdJnl
        HST->IdDoc   := FIN->IdDoc
        HST->Line    := repl(CHR_255,LEN_POS)
        HST->Periode := FIN->Periode
        HST->Date    := FIN->Date
        HST->Match   := FIN->IdJnl + FIN->IdDoc
        if nDebit > 0
          HST->DC      := DC_CREDIT
          HST->Mont    := ntom(nDebit)
          * if jnl[JNL_IDDEV] != DevDefault(HST->Periode)
          if ! empty(cIdDev)
            HST->MontDev := ntom(nDevDebit,nDevDecPos)
            HST->IdDev := cIdDev
          endif
          CtgCollect( ;
            aCtg,HST->IdGen, ;
            HST->Periode, ;
            0, nDebit ;
          )
        else
          HST->DC      := DC_DEBIT
          HST->Mont    := ntom(-nDebit)
          * if jnl[JNL_IDDEV] != DevDefault(HST->Periode)
          * if FIN->IdDev != DevDefault(HST->Periode)
          if ! empty(cIdDev)
            HST->MontDev := ntom(-nDevDebit,nDevDecPos)
            HST->IdDev := cIdDev
          endif
          CtgCollect( ;
            aCtg,HST->IdGen, ;
            HST->Periode, ;
            -nDebit, 0 ;
          )
        endif
        unlock record
      else
        lOK := .f.
      endif
      commit
    close area
  else
    lOK := .f.
    open area oHst()
      lOK := .t.
      for i := 1 to len(aHst)
        if dbAddRec()
          HST->IdJnl   := FIN->IdJnl
          HST->IdDoc   := FIN->IdDoc
          HST->Line    := aHst[i][HST_LINE]
          HST->DC      := DcInvert(aHst[i][HST_DC])
          HST->Mont    := aHst[i][HST_MONT]
          HST->MontDev := aHst[i][HST_MONTDEV] // 971230
          HST->IdDev   := aHst[i][HST_IDDEV]
          HST->IdGen   := jnl[JNL_IDGEN]
          * HST->IdPar   := aHst[i][HST_IDPAR]
          * HST->IdCtr   := aHst[i][HST_IDCTR]
          HST->Periode := FIN->Periode
          if JNLATTR_P $ jnl[JNL_ATTRIB] .and. ! empty(aHst[i][HST_DATE])
            HST->Periode := PerActive(aHst[i][HST_DATE])
          else
            if empty(aHst[i][HST_DATE])
              HST->Date    := FIN->Date
            else
              HST->Date    := aHst[i][HST_DATE]
            endif
          endif
          HST->Match   := FIN->IdJnl + FIN->IdDoc
          if HST->DC == DC_DEBIT
            CtgCollect( ;
              aCtg,HST->IdGen, ;
              HST->Periode, ;
              val(HST->Mont), 0 ;
            )
          else
            CtgCollect( ;
              aCtg,HST->IdGen, ;
              HST->Periode, ;
              0,val(HST->Mont) ;
            )
          endif
          unlock record
        else
          lOK := .f.
        endif
      next i
      commit
    close area
    RETURN .f. if ! lOK
  endif
endif
#ifdef DEF_MVA
#ifdef DEF_ANAFIN
  RETURN .f. if ! MvaGenerate(aMva,FIN->IdJnl,FIN->IdDoc,FIN->Periode)
#endif DEF_ANAFIN
#endif DEF_MVA
RETURN lOk


#ifdef DEF_MVA

FUNCTION MvaUndo(cIdJnl,cIdDoc)
local lOK := .f.
open area oMva()
  ddSetOrder(ORD_MVA_DOC)
  lOk := .t.
  softseek cIdJnl+cIdDoc
  do while lOK .and. !eof() ;
           .and. MVA->IdJnl==cIdJnl;
           .and. MVA->IdDoc == cIdDoc
    if ddReclock()
      delete
      unlock record
    else
      lOK:=.f.
    endif
    skip
  enddo
close area
RETURN lOK

FUNCTION MvaGenerate(aMva,cIdJnl,cIdDoc,cPeriode)
local lOK := .f.
local i
open area oMva()
  lOk := .t.
  for i := 1 to len(aMva)
    if dbAddRec()
      MVA->IdGen   := aMva[i][MVA_IDGEN]
      MVA->IdAna   := aMva[i][MVA_IDANA]
      MVA->IdJnl   := cIdJnl
      MVA->IdDoc   := cIdDoc
      MVA->Periode := cPeriode
      MVA->Date    := aMva[i][MVA_DATE]
      MVA->Line    := aMva[i][MVA_LINE]
      MVA->DC      := aMva[i][MVA_DC]
      MVA->Mont    := aMva[i][MVA_MONT]
      unlock record
    else
      lOK := .f.
      exit
    endif
  next i
close area
RETURN lOK

#endif DEF_MVA


#ifdef DEF_FNA


/**************
Beispiel :

1) Eingabe Kontoauszug 1/3 :

  Kto   Dossier      Aus      Ein   Bemerkung
  4700  XY        80.000            Drittgeld zurck an Partner
  4701  XY        20.000            Drittgeld an Honorar

2) Konfigurierung : FNA.DBF :
   IdGen  Expr           IdGen1  IdGen2
   4701   IdJnl=="1/3"   4700    7000

3) Beim Registrieren werden auáer den normalen Buchungen noch zwei
zus„tzliche automatische Buchungen (x) erstellt, die eine
Hin-und-Zurck-Kopie der Buchung in 4701 sind :

                                    ÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ
 --> 5501 Journal "1/3"                     ³ 100.000
     4700 Drittgeld E/A              80.000 ³
     4701 Drittgeled an Honorar      20.000 ³
                                            ³
 (x) 7000 Umsatz Honorar                    ³  20.000
 (x) 4700 Drittgeld E/A              20.000 ³
                                            ³

**************/

**
** FNA - Imputation des bases
**
FUNCTION oFna()
local b
define data b   ;
  name FNA      ;
  attrib K
ddIndex b on FNA->IdGen
ddFld IdGen     ,C, LenIdGen(),0  picture PIC_ID ;
                                  pick PickGen(NIL,FNA->IdGen) ;
                                  postedit {|x| GetIdGen(x) }
ddFld Expr      ,C, 100,0  picture "@k@s30"
ddFld IdGen1    ,C, LenIdGen(),0  picture PIC_ID ;
                                  pick PickGen(NIL,FNA->IdGen1) ;
                                  postedit {|x| GetIdGen(x) }
ddFld IdGen2    ,C, LenIdGen(),0  picture PIC_ID ;
                                  pick PickGen(NIL,FNA->IdGen2) ;
                                  postedit {|x| GetIdGen(x) }
ddEndDef()
RETURN b



FUNCTION HstFnaGenerate(aCtg)
local aBuf := CopyRec()
local fna := FnaLocate(HST->IdGen)
RETURN .t. if fna == NIL
RETURN .f. if ! dbAddRec()
PasteRec(aBuf)
HST->IdGen := fna[FNA_IDGEN1]
HstCtgCollect(aCtg)
unlock record
RETURN .f. if ! dbAddRec()
PasteRec(aBuf)
HST->IdGen := fna[FNA_IDGEN2]
HST->DC    := DcInvert(HST->DC)
HstCtgCollect(aCtg)
unlock record
RETURN .t.


* FUNCTION HstCtgCollect(aCtg)
* RETURN CtgCollect(aCtg, ;
*   HST->IdGen, ;
*   HST->Periode, ;
*   val(HST->Mont), 0 ;
* ) if HST->DC == DC_DEBIT
* RETURN CtgCollect(aCtg,HST->IdGen,HST->Periode,0,val(HST->Mont))


#endif DEF_FNA


**
** FinCheckSolde
**
STATIC FUNCTION FinCheckSolde
local mMont1 := FIN->Mont1
local mMont2 := FIN->Mont2
local nRecNo := recno()
local cIdJnl := FIN->IdJnl
local cIdDoc := FIN->IdDoc
local cIdDev := FIN->IdDev
RETURN .t. if ! (JNLATTR_S $ JnlAttrib(FIN->IdJnl))
skip - 1
if FIN->IdJnl == cIdJnl .and. FIN->IdDev == cIdDev .and. NextNum(FIN->IdDoc) == cIdDoc
  if FIN->Mont2 != mMont1
    Warning(MSG007 + FIN->IdJnl + " " + FIN->IdDoc + " !")
    goto nRecNo
    RETURN .F.
  endif
endif
goto nRecNo
skip
if FIN->IdJnl == cIdJnl .and. FIN->IdDev == cIdDev .and. FIN->IdDoc == NextNum(cIdDoc)
  if FIN->Mont1 != mMont2
    Warning(MSG008 + FIN->IdJnl + " " + FIN->IdDoc + " !")
    goto nRecNo
    RETURN .F.
  endif
endif
goto nRecNo
RETURN .T.

#endif DEF_FIN

#ifdef DEF_IMP

**
** ImpCheckSolde
**
FUNCTION ImpCheckSolde(jnl)
* local cMont1 := IMP->Mont1
* local cMont2 := IMP->Mont2
local nRecNo := recno()
local cIdJnl := IMP->IdJnl
local cIdDoc := IMP->IdDoc
local aMont1 := { IMP->IdDev, val(IMP->Mont1) }
local aMont2 := { IMP->IdDev, val(IMP->Mont2) }
local nDiff
RETURN .t. if ! (JNLATTR_S $ jnl[JNL_ATTRIB])
skip - 1
if IMP->IdJnl == cIdJnl .and. NextNum(IMP->IdDoc) == cIdDoc // .and. IMP->Etat == DocStatClosed()
  * IMP n-1 : Mont2 = 50.29 EUR
  * IMP n   : Mont1 = 2029 BEF
  * 50.29 * 40.3399 = 2029
  * 2029 / 40.3399 = 50.30 (Diff = 0.01)
  nDiff := MontDiff({ IMP->IdDev, val(IMP->Mont2) }, aMont1, IMP->Periode)
  if abs(nDiff) > DevTolerance(aMont1[1])
    nDiff := MontDiff(aMont1, { IMP->IdDev, val(IMP->Mont2) }, IMP->Periode)
    if abs(nDiff) > DevTolerance(IMP->IdDev)
      SetMsg(ntrim(nDiff) + MSG007 + IMP->IdJnl + " " + IMP->IdDoc + " !")
      goto nRecNo
      RETURN .F.
    endif
  endif
endif
goto nRecNo
skip
if IMP->IdJnl == cIdJnl .and. IMP->IdDoc == NextNum(cIdDoc) // .and. IMP->Etat == DocStatClosed()
  nDiff := MontDiff(aMont2, { IMP->IdDev, val(IMP->Mont1) }, IMP->Periode)
  if abs(nDiff) > DevTolerance(IMP->IdDev)
    nDiff := MontDiff({ IMP->IdDev, val(IMP->Mont1) }, aMont2, IMP->Periode)
    if abs(nDiff) > DevTolerance(aMont2[1])
      SetMsg(ntrim(nDiff) + MSG008 + IMP->IdJnl + " " + IMP->IdDoc + " !")
      goto nRecNo
      RETURN .F.
    endif
  endif
endif
goto nRecNo
RETURN .T.

**
** Wenn W„hrung sich ge„ndert hat, dann versteht sich die Differenz
** in der W„hrung des neuen Betrags
**
FUNCTION MontDiff(aOld,aNew,cPeriode)
local n
if aOld[1] == aNew[1]
  RETURN aNew[2] - aOld[2]
endif
// alten Betrag in die W„hrung des neuen Betrags konvertieren
n := Dev2Db(aOld[1],cPeriode,aOld[2])
n := Db2Dev(aNew[1],cPeriode,n)
RETURN aNew[2] - n


#endif DEF_IMP


*FUNCTION DictFindItem(aDict,uValue)
*local i
*for i := 1 to len(aDict)
*  RETURN .t. if aDict[i] == uValue
*next i
*RETURN .t.
*
*FUNCTION DictDelItem(aDict,uValue)
*local i
*for i := 1 to len(aDict)
*  if aDict[i] == uValue
*    adel(aDict,i)
*    asize(aDict,len(aDict)-1)
*    RETURN .t.
*  endif
*next i
*RETURN .t.

/*
  Seit DEF_VNLALT desaktiviert

FUNCTION JnlExport(cIdJnl,cPath)
local jnl := JnlLocate(cIdJnl)
local lOkay := .f.
local nDocCount := 0
RETURN NIL if jnl == NIL
default cPath to dbPath()
#ifdef DEF_FIN
  if jnl[JNL_ALIAS] == JNLALIAS_FIN
    * das ist nicht n”tig, weil ja jedesmal wieder das gesamte Journal
    * exportiert wird
    * if file(cPath + "\FIN" + cIdJnl)
    *   RETURN NIL
    *   Warning( cPath + "\FIN" + cIdJnl + dbf_ext() + " : Datei")
    * endif
    open area oFin()
      lOkay := .t.
      softseek cIdJnl
      copy to (cPath + "\FIN" + cIdJnl) ;
           while FIN->IdJnl == cIdJnl
      if doserror() != 0
        Warning(cPath + "\FIN" + cIdJnl + dbf_ext() + MsgDosError())
        lOkay := .f.
      endif
    close area
    RETURN NIL if ! lOkay
    open area oFnl()
      softseek cIdJnl
      copy to (cPath + "\FNL" + cIdJnl) ;
           while FNL->IdJnl == cIdJnl
      if doserror() != 0
        Warning(cPath + "\FNL" + cIdJnl + dbf_ext() + MsgDosError())
        lOkay := .f.
      endif
    close area
    RETURN NIL if ! lOkay
    SetMsg(cIdJnl + " : Journal wurde in Transferdateien kopiert.")
  endif
#endif DEF_FIN
#ifdef DEF_VEN
  if jnl[JNL_ALIAS] == JNLALIAS_VEN
    open area oVen()
      lOkay := .t.
      softseek cIdJnl
      copy to (cPath + "\VEN" + cIdJnl) while VEN->IdJnl == cIdJnl
      if doserror() != 0
        Warning(cPath + "\VEN" + cIdJnl + dbf_ext() + MsgDosError())
        lOkay := .f.
      endif
    close area
    RETURN NIL if ! lOkay
    open area oVnl(VEN->Etat)
      softseek cIdJnl
      copy to (cPath + "\VNL" + cIdJnl) while VNL->IdJnl == cIdJnl
      if doserror() != 0
        Warning(cPath + "\VNL" + cIdJnl + dbf_ext() + MsgDosError())
        lOkay := .f.
      endif
    close area
    RETURN NIL if ! lOkay
    SetMsg(cIdJnl + " :Journal wurde in Transferdateien kopiert.")
  endif
#endif DEF_VEN
RETURN NIL

**
** JnlImport()
**
FUNCTION JnlImport(cIdJnl,cPath)
local aBuf
local jnl := JnlLocate(cIdJnl)
local lOkay := .f.
local nDocCount := 0
local nSelect := select()
RETURN NIL if jnl == NIL
default cPath to dbPath()
#ifdef DEF_FIN
  if jnl[JNL_ALIAS] == JNLALIAS_FIN
    use (cPath + "\FNL" + cIdJnl) alias NEWFNL new
    open area oFnl()
      lOkay := .t.
      select NEWFNL
      go top
      do while lOkay .and. ! eof()
        aBuf := CopyRec()
        if TaskInter() ; lOkay := .f. ; exit ; endif
        select FNL
        seek NEWFNL->IdJnl + NEWFNL->IdDoc + NEWFNL->Line
        if eof()
          if dbAddRec()
            PasteRec(aBuf)
          else
            lOkay := .f.
          endif
        endif
        select NEWFNL
        skip
      enddo
      select FIN
    close area
    use
    select (nSelect)
    RETURN NIL if ! lOkay
    use (cPath + "\FIN" + cIdJnl) alias NEWFIN new
    open area oFin()
      lOkay := .t.
      select NEWFIN
      go top
      do while lOkay .and. ! eof()
        aBuf := CopyRec()
        if TaskInter() ; lOkay := .f. ; exit ; endif
        select FIN
        seek NEWFIN->IdJnl + NEWFIN->IdDoc
        if eof()
          if dbAddRec()
            PasteRec(aBuf)
            FIN->Etat := DocStatOpen()
            nDocCount++
          else
            lOkay := .f.
          endif
        endif
        select NEWFIN
        skip
      enddo
      select FIN
    close area
    use
    select (nSelect)
    RETURN NIL if ! lOkay
    RETURN NIL if ! Confirm( ;
      cIdJnl + " : " + ntrim(nDocCount) + ;
      "Dokumente wurden importiert.", ;
      "Transferdateien l”schen (J/N) ?" ;
    )
    delete file (cPath + "\FIN" + cIdJnl + dbf_ext())
    delete file (cPath + "\FNL" + cIdJnl + dbf_ext())
  endif
#endif DEF_FIN
#ifdef DEF_VEN
  if jnl[JNL_ALIAS] == JNLALIAS_VEN
    use (cPath + "\VNL" + cIdJnl) alias NEWVNL new
    open area oVnl(DocStatNew()) // hmm... ob das wohl immer geht?
      lOkay := .t.
      select NEWVNL
      go top
      do while lOkay .and. ! eof()
        aBuf := CopyRec()
        if TaskInter() ; lOkay := .f. ; exit ; endif
        select VNL
        seek NEWVNL->IdJnl + NEWVNL->IdDoc + NEWVNL->Line
        if eof()
          if dbAddRec()
            PasteRec(aBuf)
          else
            lOkay := .f.
          endif
        endif
        select NEWVNL
        skip
      enddo
      select VEN
    close area
    use
    select (nSelect)
    RETURN NIL if ! lOkay
    use (cPath + "\VEN" + cIdJnl) alias NEWVEN new
    open area oVen()
      lOkay := .t.
      select NEWVEN
      go top
      do while lOkay .and. ! eof()
        aBuf := CopyRec()
        if TaskInter() ; lOkay := .f. ; exit ; endif
        select VEN
        seek NEWVEN->IdJnl + NEWVEN->IdDoc
        if eof()
          if dbAddRec()
            PasteRec(aBuf)
            VEN->Etat := DocStatOpen()
            nDocCount++
          else
            lOkay := .f.
          endif
        endif
        select NEWVEN
        skip
      enddo
      select VEN
    close area
    use
    select (nSelect)
    RETURN NIL if ! lOkay
    RETURN NIL if ! Confirm( ;
      cIdJnl + " : " + ntrim(nDocCount) + ;
      "Dokumente wurden importiert.", ;
      "Transferdateien l”schen (J/N) ?" ;
    )
    delete file (cPath + "\VEN" + cIdJnl + dbf_ext())
    delete file (cPath + "\VNL" + cIdJnl + dbf_ext())
  endif
#endif DEF_VEN
RETURN NIL

seit DEF_VNLALT desaktiviert */

