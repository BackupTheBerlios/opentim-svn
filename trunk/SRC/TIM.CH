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

**
**  Zuerst kommen ein paar #defines, die Åber die CUST.CH eventuell wieder
**  annulliert werden dÅrfen.
**

#define LEN_NOTVA   18
#define LEN_IDTPT    3

#define LEN_IDDOC   6
* #define LEN_IDLNG 1
#define LEN_VNLATTR 2
#define LEN_IDPLS    8
#define LEN_IDPRF    4
#define LEN_IDNAT    3
* #define LEN_IDPGP    3
* #define LEN_IDPGA    3
* #define LEN_IDUNT    2
**************** #define LEN_IDECS    3
#define LEN_IDCDS    2
#define LEN_CPTTYPE  1
#define LEN_IDPRT    1
* #define LEN_IDBUD    6
************#define LEN_IDPMV    1
*************#define LEN_PMVNAME 15
#define LEN_GRANAME 40
**********#define DEF_LNDESIG
**********#define LEN_LNDESIG 28
*********#define LEN_IDVAR  5
#define LEN_POS    3
#define LEN_IDCTR  1


* #define DEF_IMPTIM205

#include "LIB.CH"
#include "OBJECTS.CH"

** Diese DEF_s sind noch nicht fertig integriert. Stets gesetzt lassen !
#define DEF_MASQUES
* #define DEF_REMISE

memvar MemPays
#ifdef DEF_IMP
  memvar MemIdCdc
  * memvar MemSaldo
  * memvar MemParSalDate
#endif DEF_IMP
memvar MemRapLimit
memvar MemPer1
memvar MemPer2
memvar MemMatch
memvar MemAttrib
#ifdef DEF_SUB
  memvar MemSubAttrib
#endif
* memvar MemTxtPresto
* memvar MemTxtRappel
memvar MemTxtCor
memvar MemIdDev
memvar MemNoTva
memvar MemPickArtMode
* memvar MemQryArtPick
#ifdef DEF_VNA
  memvar MemVnaMont
#endif
#ifdef DEF_MVS
  memvar MemMvsPeriode
#endif

#define CHR_VERTICAL " | "

**
** Length constants
**
#define LEN_IDAGL   1
#define LEN_IDAGS   2
* #define LEN_IDCAT   2
#define LEN_IDCTA  2
#define LEN_IDCTF  2
#define LEN_IDCLJ  2
#define LEN_IDDEV   3
#define LEN_IDDGR   1
* #define LEN_IDMFC   3
* #define LEN_IDJNL   3
#define LEN_IDREG   1
#define LEN_IDTAX   3

#define LEN_LIBTAX   25
#define LEN_LIBCAT   20
#define LEN_PRTNAME  28
#define LEN_GRJNAME  25

#define LEN_LIBELL  25
#define LEN_PERIODE  4
#define LEN_YEAR     2 // Year = die ersten zwei Stellen von Periode

#define LEN_IDPRJ 6
* #define LEN_IDDTO 5
#define LEN_IDGRJ 3
#define LEN_IDCDC 2
#define LEN_IDSTK 1


**
** Picture Constants
**
#define PIC_NOTVA     "@R !!-###.###.###.!##"



**
** QUERY & ORDER constants      ----> Form "ORD_XXX_YYYYY" benutzen !
**

#define ORD_ALA_ART1  1
#define ORD_ALA_ART2  2

#define ORD_GEN_IDGEN  1
#define ORD_GEN_IDCTR  2
#define ORD_GEN_BIL    3

#define ORD_PAR_ID       1
#define ORD_PAR_PRTNAME  2
#define ORD_PAR_PLZ      3
#define ORD_PAR_TVA      4
#ifdef DEF_RUN
  #define ORD_PAR_CLB      4
#endif DEF_RUN

#define ORD_PSC_PAR1    1
#define ORD_PSC_PAR2    2

#define ORD_FNL_IDDOC  1
#define ORD_FNL_COMPTE 2

#define ORD_CTG_GEN  1
#define ORD_CTG_PER  2

#define ORD_IVL_DATE   1
#define ORD_IVL_ART    2

#define ORD_ART_ID   1
#define ORD_ART_GRA  2
#define ORD_ART_REF  3
#define ORD_ART_PAR  3

#define ORD_ACF_ART  1
#define ORD_ACF_PAR  2

#ifdef DEF_IMP

  #define ORD_CTB_BUD      1
  #define ORD_CTB_PERIODE  2

  #define ORD_BUD_ID 1
  #define ORD_BUD_HH 2
  #define ORD_BUD_3  3

  #define ORD_MVI_ID        1
  #define ORD_MVI_PARDATE   2
  #define ORD_MVI_BUDDATE   3
  #define ORD_MVI_PARMATCH  4
  #define ORD_MVI_BUDJNL    5
  #define ORD_MVI_PARJNL    6
  #define ORD_MVI_PRJ       7
  #define ORD_MVI_PAR2DATE  8
  #define ORD_MVI_EAMATCH   9
  #define ORD_MVI_LNK      10

  #define ORD_LNI_LNK 1
  #define ORD_LNI_DOC 2

#endif DEF_IMP

#ifdef DEF_VNA

  #define ORD_VNA_ID        1
  #define ORD_VNA_PARDATE   2
  #define ORD_VNA_ARTDATE   3
  #define ORD_VNA_ARTMATCH  4

#endif DEF_VNA

#ifdef DEF_MVS

  #define ORD_MVS_DOC    1
  * #define ORD_MVS_PAR    2
  #define ORD_MVS_ART    2
  * #define ORD_MVS_MATCH  4

#endif DEF_MVS

#define ORD_VEN_ID   1
#define ORD_VEN_PAR  2
#define ORD_VEN_PRJ  3

#define ORD_VNL_DOC  1
#define ORD_VNL_ART  2
#define ORD_VNL_IDSER  3
#define ORD_VNL_VNA  3

#define ORD_MSG_ID     1
#define ORD_MSG_USER   2
#define ORD_MSG_PAR    3
#define ORD_MSG_THREAD 4

#ifdef DEF_EVT
  #define ORD_EVT_USER 1
  #define ORD_EVT_PAR  2
#endif DEF_EVT

#ifdef DEF_PRJ
#define ORD_MSG_PRJ  3
#endif DEF_PRJ

#define ORD_IMP_ID   1

#define ORD_PLZ_NAME  2

#define ART_ORD_ID      1
#define ART_ORD_GRP     2
* #define ART_ORD_IDFOU   3

#define TRM_ORD_IDCLI  2
#define TRM_ORD_IDTAC  4

#define ORD_TRM_DATE    1
#define ORD_TRM_PAR     2
#define ORD_TRM_USER    3
#define ORD_TRM_TACDATE 4
#define ORD_TRM_PRJ     5

* #define ORD_TRM_DATE    1
* #define ORD_TRM_CLI     2
* #define ORD_TRM_FOU     3
* #define ORD_TRM_TAC     4
* #define ORD_TRM_USER    5


* #define ORD_MVT_GENDATE   1
* #define ORD_MVT_DOC       2
* #define ORD_MVT_GENMATCH  3

* #define ORD_MVP_PARDATE  1
* #define ORD_MVP_DOC      2
* #define ORD_MVP_PARMATCH 3

#define ORD_MVA_CPTDATE  1
#define ORD_MVA_DOC      2
#define ORD_MVA_GEN      3

#define ORD_MVB_CPTDATE  1
#define ORD_MVB_DOC      2

#define ORD_CMD_COMPTE  1
#define ORD_CMD_TYPE    2
#define ORD_CMD_ART     3

#ifdef DEF_PLS

// #define ORD_MBR_PLSPAR  1
#define ORD_MBR_PLSTEXT 1
#define ORD_MBR_PAR     2
#define ORD_MBR_PAR2    3

#endif

#ifdef DEF_PLI

#define ORD_MBR_LSTPOS 1
#define ORD_MBR_PAR    2

#endif

#define ORD_PIN_CODE     1
#define ORD_PIN_IDPRJ    2
* #define ORD_PIN_STATUS    2

#define ORD_VNL_IDDOC     1
* #define ORD_VNL_OBJ       2

#define ORD_ECL_IDECS  1
#define ORD_ECL_MATCH  2

#ifdef DEF_HOLZ

  #define ORD_STM_ID   1
  #define ORD_STM_PRJ  2

#endif DEF_HOLZ

#ifdef DEF_TAX

  #define ORD_CTT_PERIODE  1
  #define ORD_CTT_TAX      2

#endif DEF_TAX

#define ORD_SPC_PAR     1
#define ORD_SPC_ART     2

#define ORD_JNL_ID   1
#define ORD_JNL_SEQ  2


* #define ETAT_ERREUR  "E"
* #define ETAT_OUVERT  "N"
* #define ETAT_CLOTURE "C"

#ifdef DEF_NEWSTAT

#define DOCSTAT_NEW     " "
#define DOCSTAT_OPEN    "˘"
#define DOCSTAT_CLOSED  "˚"
#define DOCSTAT_ERROR   "?"

#else

#define DOCSTAT_NEW     "E"
#define DOCSTAT_OPEN    "N"
#define DOCSTAT_CLOSED  "C"
#define DOCSTAT_ERROR   "?"

#endif


#ifdef DEF_TRA

#define TRASTAT_NEW           "E"
#define TRASTAT_OPEN          "N"
#define TRASTAT_CLOSED        "C"

#define TRLSTAT_NEW           "N"
#define TRLSTAT_CTL           "Z"
#define TRLSTAT_STORNIERT     "S"
#define TRLSTAT_CTL_STORNIERT "X"

#endif DEF_TRA

#define CPTTYPE_GEN " "

#define LNCODE_ART       "A"
#define LNCODE_NEWS      "N"
#define LNCODE_ARTFIXE   "F"
#define LNCODE_REMARQ    "R"
#define LNCODE_GEN       "G"
#define LNCODE_PREST     "P"
#define LNCODE_TOTAL     "T"
#define LNCODE_VARIANTE  "#"
#define LNCODE_MODULE    "M"
* #define LNCODE_DOC    "D"

* #define PSTAT_OPEN "N"
* #define PSTAT_CLOT "C"
* #define PSTAT_ARCH "A"

#ifndef DEF_ART
  #xtranslate oArt() => NIL
#endif

#ifndef DEF_INT
  #xtranslate oInt() => NIL
  #xtranslate oHsi() => NIL
#endif

#ifndef DEF_EVT
  #xtranslate oEvt() => NIL
  #xtranslate oEvi() => NIL
  #xtranslate oEvl() => NIL
#endif

* #ifndef DEF_ANA
*   #xtranslate oAna() => NIL
* #endif

#ifndef DEF_HST
  #xtranslate oHst() => NIL
#endif

#ifndef DEF_PIN
  #xtranslate oPin() => NIL
#endif

#ifndef DEF_PRIXR
  #xtranslate VnlPRValidate() => NIL
#endif

#ifndef DEF_GRA
  #xtranslate oGra() => NIL
#endif

#ifndef DEF_NEWS
  #xtranslate oNew() => NIL
  #xtranslate oNgr() => NIL
#endif

#ifndef DEF_PSC
  #xtranslate oPsc() => NIL
#endif

#ifndef DEF_BIL
  #xtranslate oBil() => NIL
#endif

#ifndef DEF_FIN
  #xtranslate oFin() => NIL
  * #xtranslate oFnl() => NIL
  #xtranslate oDif() => NIL
#endif

#ifndef DEF_MVP
  #xtranslate oMvp() => NIL
#endif

* #ifndef DEF_ACF
*   #xtranslate oAcf() => NIL
* #endif

#ifndef DEF_ALA
  #xtranslate oAla() => NIL
#endif

#ifndef DEF_TAX
  #xtranslate oTax() => NIL
  // #xtranslate oReg() => NIL
  #xtranslate oDcl() => NIL
  #xtranslate oCtt() => NIL
#endif

#ifndef DEF_IMP
  // #xtranslate oBud() => NIL
  #xtranslate oMvb() => NIL
  #xtranslate BudName([<x>]) => NIL
  #xtranslate PickBud([<x>]) => NIL
  #xtranslate PickBud([<x>],[<y>]) => NIL
  #xtranslate GsbIdBud([<x>]) => NIL
  #xtranslate LenIdBud() => 0
#endif

#ifndef DEF_IVT
  #xtranslate oIvt() => NIL
  #xtranslate oIvl() => NIL
#endif

#ifndef DEF_PTG
  #xtranslate oPtg() => NIL
  #xtranslate oPtl() => NIL
#endif

#ifndef DEF_PRESTO
  #xtranslate oTrm() => NIL
  #xtranslate oTac() => NIL
#endif

#ifndef DEF_VNA
  #xtranslate oVna() => NIL
  #xtranslate oTrn() => NIL
#endif DEF_VNA

#ifndef DEF_MVS
  #xtranslate oMvs() => NIL
#endif DEF_MVS

#ifndef DEF_CTS
  #xtranslate oCts() => NIL
#endif DEF_CTS

#ifndef DEF_STS
  #xtranslate oSts() => NIL
#endif

#ifndef DEF_SPC
  #xtranslate oSpc() => NIL
#endif

#ifndef DEF_MASQUES
  #xtranslate oTxt() => NIL
#endif

#ifndef DEF_VEN
  #xtranslate oVen() => NIL
  #xtranslate oVnl() => NIL
#endif

#ifndef DEF_FAC
  #xtranslate oFac() => NIL
  #xtranslate oFcl() => NIL
  #xtranslate oFct() => NIL
#endif

#ifndef DEF_MSG
  #xtranslate oMsg() => NIL
#endif

#ifdef DEF_TAX
  #xtranslate VnlIdTax() => (FIELD->IdTax)
  #xtranslate VnlTaxe() => val(FIELD->MontT)
  #xtranslate ParIdReg() => (PAR->IdReg)
#else
  #xtranslate VnlIdTax() => space(LEN_IDTAX)
  #xtranslate VnlTaxe() => 0
  #xtranslate LnBrutto([<x>]) => NIL
  #xtranslate ParIdReg() => NIL
  #xtranslate PickReg([<x>]) => NIL
#endif

#ifndef DEF_PRJ
  #xtranslate PickPrj(<any>) => NIL
  * #xtranslate oPrj() => NIL
#endif

* #ifndef DEF_PLS
*   #xtranslate oPls() => NIL
*   #xtranslate oMbr() => NIL
* #endif

#ifndef DEF_GEN
  #xtranslate oGen() => NIL
#endif

* #xtranslate TimIsCompta() => ("F" $ DbOptions())
* #xtranslate TimIsStock()  => ("S" $ DbOptions())
* #xtranslate TimIsMail()   => ("M" $ DbOptions())

* #ifdef DEF_PRESTO
*   #xtranslate TimIsPresto() => ("P" $ DbOptions())
* #endif

* #ifdef DEF_CMD
*   #xtranslate TimIsCmd() => ("B" $ DbOptions())
* #endif



** ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
** ≥ #define Combination checks ≥
** ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

**
** normalerweise soll immer DEF_CLI_A gesetzt sein.
**
**

#ifndef DEF_CLI_B
  #define DEF_CLI_A
#endif

#ifndef DEF_FOU_B
  #define DEF_FOU_A
#endif



**
** Wenn keine kundenspezifische Artikelvariante definiert ist,
** wird DEF_ART_A als Standard angenommen
**
* #ifdef DEF_ART
*   #ifndef DEF_ART_B
*     #define DEF_ART_A
*   #endif
* #endif

#ifdef DEF_PIN
  #ifndef DEF_PRJ
    #error "Unerlaubte #define-Kombination : PIN ohne PRJ"
  #endif
#endif

#ifdef DEF_HOLZ
  #ifndef DEF_PRJ
    #error "Unerlaubte #define-Kombination : HOLZ ohne PRJ"
  #endif
#endif

** ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
** ≥ TIM-spezifische Pseudo-Funktionen       ≥
** ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
**

* #xtranslate VenIsLivraison()  => ( "L" $ VEN->Attrib )
* #xtranslate JnlIsTiers(<cId>) => ("T" $ JnlAttrib(<cId>))

#xtranslate PadId(<cId>) => str(val(<cId>),len(<cId>))

#xtranslate VenName() => (VEN->IdJnl + VEN->IdDoc)

* #xtranslate VEN_MontD  => (val(VEN->cMontB) + val(VEN->cMontT))
* #xtranslate ACH_MontD  => (val(ACH->cMontB) + val(ACH->cMontT))

#xtranslate VenCours() => val(VEN->Cours)


#ifdef DEF_ART_A
  * #define LEN_IDARTF LEN_IDART
  * #define LEN_REFEXT 20
  #xtranslate ArtIdFou() => (ART->IdFou)
  #xtranslate ArtRefExt() => (ART->RefExt)
  #xtranslate ArtIdArt() => (ART->IdArt)
#endif

*#ifdef DEF_ART_B
*  #undef  LEN_IDART
*  #define LEN_IDVAR1  3
*  #define LEN_IDVAR2  2
*  #define LEN_ARTNAME 20
*  * #define LEN_REFEXT  20
*  #define LEN_IDART  (LEN_COMPTE + LEN_REFEXT + LEN_IDVAR1 + LEN_IDVAR2)
*  * #define LEN_IDARTF (LEN_IDART+3)
*  #define VAR_IDLST1 10
*  #define VAR_IDLST2 11
*  #xtranslate ArtIdArt() ;
*              => ;
*              (ART->IdFou + ART->RefExt + ART->IdVar1 + ART->IdVar2)
*#endif

#ifdef DEF_ART
  #define DEF_ART_OR_PRESTO
#else
  #ifdef DEF_PRESTO
    #define DEF_ART_OR_PRESTO
  #endif
#endif

#define JNLATTR_A "A"  // dokument registrieren wenn F10
#define JNLATTR_B "B"  // bibliothek-journal
#define JNLATTR_C "C"  // p.u. tvac
#define JNLATTR_D "D"  // dialog kassen-ein/ausgang
#define JNLATTR_E "E"  //
#define JNLATTR_F "F"  // Buchungsrichtung forcieren
#define JNLATTR_G "G"  // generalkonten bewegen
#define JNLATTR_H "H"  //
#define JNLATTR_I "I"  // analysekonten ignorieren
#define JNLATTR_J "J"  // dokumente einem projekt zuweisen
#define JNLATTR_K "K"  // format-attrib ebenfalls kopieren
#define JNLATTR_L "L"  // automatisch lettrieren
#define JNLATTR_M "M"
#define JNLATTR_N "N"  // negativ (umgekehrte Buchungsrichtung)
#define JNLATTR_O "O"  // manuelle Nummerierung
#define JNLATTR_P "P"  // frage zahlart
#define JNLATTR_Q "Q"  // stk-Felder aktualisieren
#define JNLATTR_R "R"  // "journal de report" / "Dialogfenster 'Partnerpreis'"
#define JNLATTR_S "S"  //
#define JNLATTR_T "T"  //
#define JNLATTR_U "U"  // öberbefriedigung verbieten
#define JNLATTR_V "V"  //
#define JNLATTR_W "W"  // öberbefriedigung bei öbernahme verweigern
#define JNLATTR_X "X"  //   Stornierungsjournal
#define JNLATTR_Y "Y"  // Analytisch verteilen
#define JNLATTR_Z "Z"  // Folgedokumente zusammenlegen
#define JNLATTR_1 "1"  // 

#define VENATTR_C "C"  // p.u. tvac
#define VENATTR_P "P"  // has been printed
#define VENATTR_A "A"  // Auto-Fakturierung unterdrÅcken
#define VENATTR_T "T"  // contient des sous-totaux

#define VNLATTR_U "U"  // soulignÇ
#define VNLATTR_D "D"  // Preis nicht zeigen
#define VNLATTR_S "S"  //
#define VNLATTR_H "H"  //
#define VNLATTR_F "F"  //

#define TAXATTR_T "T"  // toleranter MWSt-Code
#define TAXATTR_R "R"  // Gesamtbetrag runden
#define TAXATTR_A "A"  // liste des clients assujettis
#define TAXATTR_I "I"  // liste des clients assujettis intracom

* #define ESCATTR_D "D"  // dialog kassen-ein/ausgang
* #define ESCATTR_E "E"  // dialog zahlungsauftrÑge

#define ARTATTR_D "D"  // volumen nach durchmesser rechnen
#define ARTATTR_H "H"  // hidden
#define ARTATTR_T "T"  // temporaire
#define ARTATTR_A "A"  // print memo after
#define ARTATTR_B "B"  // print memo before
#define ARTATTR_S "S"  //
#define ARTATTR_M "M"  // muster
#define ARTATTR_R "R"  // read-only
#define ARTATTR_N "N"  // mit Seriennummern

#define IFCATTR_M "M"  // datum 2 bis monatsende verlÑngern
#define IFCATTR_W "W"  // Datum 2 bis nach dem Wochenende verlÑngern
#define IFCATTR_D "D"  // Lieferscheine angeben bei AF
#define IFCATTR_R "R"  // match-dokumente als bemerkung generieren
#define IFCATTR_H "H"
#define IFCATTR_C "C" // dialog barzahlung
#define IFCATTR_I "I"
#define IFCATTR_P "P"  // picktpl()
#define IFCATTR_U "U"
#define IFCATTR_A "A"
#define IFCATTR_G "G" // Generalkonten Automatisch fakturieren
#define IFCATTR_S "S" // selbstbefriedigend (braucht nicht befriedigt zu werden)
#define IFCATTR_X "X" // AF-VorschlÑge ohne Dialog Åbernehmen
#define IFCATTR_N "N" // AF : Negativen Gesamtbetrag zulassen
#define IFCATTR_B "B" // AF : RÅckbezug auf Ursprungsdokument
#define IFCATTR_F "F" // AF : RÅckbezug auf Ursprungsdokument
#define IFCATTR_E "E" // Extourne automatique (Nols)


#define TPLTYPE_MOD  "MOD"
* #ifdef DEF_OBJ
*   #define TPLTYPE_OBJ  "OBJ"
* #endif DEF_OBJ
#ifdef DEF_PLS
  #define TPLTYPE_PLS  "PLS"
#endif DEF_PLS
#ifdef DEF_PLI
  #define TPLTYPE_PLS  "PLS"
#endif DEF_PLI
#ifdef DEF_TRA
  #define TPLTYPE_TRA  "TRA"
  #define TPLTYPE_TRL  "TRL"
#endif DEF_TRA
#ifdef DEF_IMP
  #define TPLTYPE_IMP  "IMP"
  #define SRVATTR_U "U"
  #define SRVATTR_K "K"
#endif DEF_IMP
#ifdef DEF_EVT
  #define TPLTYPE_EVT  "EVT"
#endif DEF_EVT
#define TPLTYPE_GEN  "GEN"
#define TPLTYPE_PAR  "PAR"
#define TPLTYPE_ART  "ART"
#define TPLTYPE_GRA  "GRA"
#define TPLTYPE_VEN  "VEN"
#define TPLTYPE_TRM  "TRM"
#define TPLTYPE_MSG  "MSG"
#define TPLTYPE_PRJ  "PRJ"
#define TPLTYPE_TRN  "TRN"
#define TPLTYPE_DTL  "DTL"
#define TPLTYPE_MVP  "MVP"
#define TPLTYPE_LST  "LST"
#define TPLTYPE_SYS  "SYS"
#ifdef DEF_DGR
#define TPLTYPE_RAP  "RAP"
#endif DEF_DGR

#define PAMODE_G "G"   // via artikelgruppe
// #define PAMODE_P "P"   // via lieferant
#define PAMODE_A "A"   // alle Artikel

#define GRAATTR_R "R"
#define GRAATTR_H "H"
// #define GRAATTR_N "N"
// #define GRAATTR_E "E"

#define TIMATTR_D "D" // dernier p.a. statt mittel-ek
#define TIMATTR_N "N"
#define TIMATTR_P "P"
#define TIMATTR_S "S"
#define TIMATTR_M "M"
#define TIMATTR_T "T"
#define TIMATTR_F "F"
#define TIMATTR_C "C"  // pu tvac
* #define TIMATTR_L "L" // automatisch lettrieren
#define TIMATTR_Z "Z" // automatisch zentralisieren
#define TIMATTR_G "G" // gruppen-id in artikelnummer enthalten
#define TIMATTR_A "A" // buchungsvorschlÑge ankreuzen

#define VRTATTR_S "S" // suffix
#define VRTATTR_P "P" // prefix

#ifdef DEF_IMP

#define BUDATTR_T "T"
#define BUDATTR_H "H"
#define BUDATTR_S "S"
#define BUDATTR_W "W"
#ifdef DEF_ANA
  #define BUDATTR_Y "Y"
#endif DEF_ANA

#define SATATTR_S "S"
#define SATATTR_P "P"
#define SATATTR_U "U"
#define SATATTR_N "N"
#define SATATTR_X "X"
#define SATATTR_M "M"

#endif DEF_IMP

* #define CPTATTR_LTR "*"

* #define RCTATTR_U "U"

* #define PERATTR_A "A"

#define TRLATTR_P "P"

#define PARATTR_H "H" // hidden
#define PARATTR_W "W" // warnung
#define PARATTR_S "S" // sammelrechnungen unterdrÅcken
#define PARATTR_A "A" // automatik-fakturierung unterdrÅcken
#define PARATTR_M "M" // Kontoauszug nur manuell
#define PARATTR_R "R" // read-only
#define PARATTR_N "N" // Seriennummer vergeben
#define PARATTR_2 "2" // ZahlungsempfÑnger
#define PARATTR_X "X" // nicht exportieren

#define MODATTR_D "D"

#define CTBATTR_PLUS  "+"
#define CTBATTR_MINUS "-"

#define GENATTR_L "L"
#define GENATTR_D "D"
#define GENATTR_C "C"
#define GENATTR_H "H"
#define GENATTR_F "F"
#define GENATTR_R "R"
#define GENATTR_Y "Y" // analytisch aufteilen
#define GENATTR_T "T" // E und V tolerieren
#define GENATTR_M "M" // GenJnlExist
#ifdef DEF_INT
  #define GENATTR_I "I" // Intrastat
#endif DEF_INT

// #define RAP_LIMIT  0.1

#define ANAATTR_D "D"

* #define TRNATTR_L "L"
#define TRNATTR_R "R"
#define TRNATTR_I "I"
#define TRNATTR_A "A"
#define TRNATTR_Z "Z"
#define TRNATTR_C "C"  // kollektiv befriedigen
#define TRNATTR_X "X"  //
#define TRNATTR_P "P"  // permanent
#define TRNATTR_U "U"  // StÅckpreise wohl neu rechnen
#define TRNATTR_D "D"  // Datum ignorieren
#define TRNATTR_M "M"  // Manuell
#define TRNATTR_1 "1"  // Maximal 1 VnaMatch pro Dokument

#define CLJATTR_B "B"
#define CLJATTR_T "T"

#ifdef DEF_HOLZ
  #define STMATTR_D "D" // Durchmesser
  #define STMATTR_K "K" // Kleinholz
  #define STMATTR_H "H" // unsichtbar
#endif DEF_HOLZ

#ifdef DEF_PRESTO

  #define AGSATTR_A "A"
  #define AGSATTR_H "H"
  #define AGSATTR_R "R"
  #define AGSATTR_I "I"

  #define TRMATTR_H "H"

#endif DEF_PRESTO

* #define IND_VEN "VEN"
* #define IND_FIN "FIN"

#define VNLRESET_PU     "U"
#define VNLRESET_TAX    "T"

#define PERSTAT_CLOSED "C"
#define PERSTAT_OPEN   "O"
#define PERSTAT_DIRTY  "D"

* #define SYSJNL_TRM    "TRM"
* #define SYSJNL_TRA    (padr("TRA",LenIdJnl()))

#ifdef DEF_PRD

  #define ORD_PRD_DOC 1
  #define ORD_PRD_ART 2

  #define ORD_PRL_DOC 1
  #define ORD_PRL_ART 2

#endif DEF_PRD

#ifdef DEF_ODS

  #define ORD_ODS_DOC 1
  #define ORD_ODS_PAR 2

  #define ORD_ODL_DOC 1
  #define ORD_ODL_ART 2

#endif DEF_ODS

#define TOL_TVA   5

#ifndef DEF_IMP
  #xtranslate ParPickFilter() => NIL
#endif

#define TPLATTR_P "P"

#ifdef DEF_BIBLIO

  * #define LEN_IDNTS  5
  * #define LEN_IDDOC  5
  #define LEN_IDRUB  4
  #define LEN_IDAUT  6
  #define LEN_IDDTP  1
  #define LEN_IDDST  1
  #define LEN_IDRTP  2
  #define LEN_IDGRP  6

  #define LEN_GRPNAME  30
  #define LEN_RTPNAME  15
  #define LEN_DTPNAME  20
  #define LEN_AUTNAME  30
  #define LEN_RUBNAME  40
  #define LEN_DSTNAME  20
  #define LEN_NTSNAME  40

  #define LEN_DTPTITEL 15

  #define AUT_ORD_ID     1
  #define AUT_ORD_NAME   2

  #define ORD_NTS_ID     1
  #define ORD_NTS_NAME   2

  #define ORD_REF_DOC    1
  #define ORD_REF_NTS    2

  #define DOC_ORD_ID     1
  #define DOC_ORD_AUT    2
  #define DOC_ORD_RUB    3
  #define DOC_ORD_GRP    4
  #define DOC_ORD_DST    5        // art + titel

  #define ORD_ADR_ID      1
  #define ORD_ADR_NAME    2

  #define ORD_OUT_PAR    1
  #define ORD_OUT_DOC    2


  #define DTP_ID     1
  #define DTP_NAME   2
  #define DTP_TITEL  3
  #define DTP_ATTRIB 4
  #define DTP_LENPRE 5
  #define DTP_LENSUF 6

  #define RTP_ID    1
  #define RTP_NAME  2
  #define RTP_IDDTP 3
  #define RTP_TITEL 4

  #define DST_ID    1
  #define DST_NAME  2
  #define DST_ALEN  2

  *************#define OAT_ID    1
  **************#define OAT_NAME  2
  **************#define OAT_ALEN  2

  *************#define DCA_ID    1
  ************#define DCA_NAME  2
  ************#define DCA_ALEN  2

  ***********#define DTPATTR_B "B" // Dokumentart anzeigen
  *#define DTPATTR_G "G" // Dokumentart anzeigen
  *#define DTPATTR_R "R" // Dokumentart anzeigen
  *#define DTPATTR_A "A" // Dokumentart anzeigen
  ***********#define DTPATTR_D "D" // Dokumentart anzeigen

  #define TPLTYPE_OBJ "OBJ"

#endif DEF_BIBLIO

#ifndef DEF_VNLATTR
  #xtranslate PickVnlAttrib(<x>) => NIL
#endif DEF_VNLATTR


#ifdef DEF_SER
  #define ORD_SER_ID      1
  #define ORD_SER_ART     2
  #xtranslate VnlIdSer() => FIELD->IdSer
  #xtranslate OdlIdSer() => ODL->IdSer
#else
  #xtranslate oSer() => NIL
  #xtranslate VnlIdSer() => NIL
  #xtranslate OdlIdSer() => NIL
#endif DEF_SER

#define JNLALIAS_VEN "VEN"
#define JNLALIAS_FIN "FIN"
#define JNLALIAS_ODS "ODS"
#ifdef DEF_ANA
  #define JNLALIAS_ODA "ODA"
#endif DEF_ANA
#define JNLALIAS_IMP "IMP"
#define JNLALIAS_TRA "TRA"


#ifdef DEF_KVK

  #define JNLALIAS_KVK "KVK"
  #define LEN_IDZLA 1

  #define ORD_KVL_DOC  1
  #define ORD_KVL_ART  2

  #define ORD_KVK_ID   1
  #define ORD_KVK_DATE 2

#endif DEF_KVK

*#xtranslate IsArtCode(<cCode>) => ( ;
*  <cCode> == LNCODE_ART ;
*  .or. <cCode> == LNCODE_ARTFIXE ;
*  .or. <cCode> == LNCODE_TOTAL ;
*  .or. <cCode> == LNCODE_MODULE ;
*  .or. <cCode> == LNCODE_VARIANTE ;
*)

#define DGRATTR_M "M" // wird nur manuell gesetzt

#ifdef DEF_HST

#define ORD_HST_PARDATE   1
#define ORD_HST_PARMATCH  2
#define ORD_HST_GENDATE   3
#define ORD_HST_GENMATCH  4
#define ORD_HST_DOC       5
#define ORD_HST_ANA       9
* #define ORD_HST_DATE      6

#endif DEF_HST

#ifdef DEF_EVT

#define LEN_IDEVT 3

#define ORD_EVI_USR  1
#define ORD_EVI_PAR  2

#define EVTSTAT_NEW      "1"
#define EVTSTAT_WORK     "2"
#define EVTSTAT_WAIT     "3"
#define EVTSTAT_CLOSED   "4"

#define EVIATTR_A "A" // abgeschlossen 
#define EVIATTR_W "W" // Wiedervorlage wurde gemacht

#endif DEF_EVT

#define IDMFC_ANY "*"

#ifdef DEF_INT
  #define ORD_HSI_DOC 1
#endif DEF_INT

#define IPRATTR_C "C"  // StÅckpreis inkl. MWSt.
#define IPRATTR_R "R"  // Warnung wenn StÅckpreis < Selbstkostenpreis

#define PLSATTR_R "R" // read-only

#define INTATTR_K "K" // Gewichtsangabe optional

#ifdef DEF_TAX
#define REGATTR_I "I"  // Intrastat-Angaben erfassen
#define REGATTR_A "A"  //
#endif DEF_TAX

#ifdef DEF_CTRATTR
#define CTRATTR_L "L" // nicht lettrieren
#endif DEF_CTRATTR


#ifdef DEF_RUN

  #define ORD_POS_POS    1
  #define ORD_POS_TIME   2
  #define ORD_POS_CAT_TIME   3
  #define ORD_POS_PAR    4
  #define ORD_POS_RAL_PAR    5

  * #define LEN_IDLNG      2

  #define RALSTAT_I  "I"
  #define RALSTAT_T  "T"
  #define RALSTAT_P  "P"
  #define RALSTAT_C  "C"

  #define TPLTYPE_RAL "RAL"
  #define TPLTYPE_POS "POS"
  * #define TPLTYPE_PAR "PAR"


  #define RALTYPE_1 "1"

  #define RALTYPE_2 "2" //

  ** 1 Klassisch, Jogging, TIM schlÑgt Dossardnummer selber vor.

  ** 2 Cross (neu 20061209): TIM schlÑgt POS->IdPos nicht vor und speichert
  ** POS->IdPos in PAR->IdPos (Lizenznummer) wenn angegeben.,



#else
  #xtranslate oClb() => NIL
#endif DEF_RUN

#define DEF_ALMOST_NULL  0.0001

#ifdef DEF_ADR

#define ORD_ADM_ADL 1
#define ORD_ADM_ADR 2
#define ADLATTR_R "R"
#define TPLTYPE_ADL "ADL"

#endif DEF_ADR


#ifdef DEF_PLP

#define ORD_PLP_1 1
#define ORD_PLP_2 2

#else
  #xtranslate oPlp() => NIL
#endif DEF_PLP

#ifdef DEF_WWW
#define ORD_NEW_DATE 2
#define ORD_NEW_NGR 3
#endif DEF_WWW

#ifdef DEF_LITERA
// #define ORD_PUB_3 3
#define ORD_PUB_AUT 3
#define ORD_PUB_4 4
#define ORD_QUO_AUT 2
#define ORD_QUO_PUB 3
#else
  #xtranslate oPub() => NIL
  #ifndef DEF_BIBLIO
    #xtranslate oAut() => NIL
  #endif
  #xtranslate oQuo() => NIL
#endif DEF_LITERA


#ifdef DEF_DLS
#define ORD_DLP_PARDATE 2
#define ORD_DLS_USRDATE 3
#define ORD_DLS_PARDATE 4
#endif DEF_DLS


#define NAFATTR_I "I" // Show IdArt in VnaTag()
#define NAFATTR_D "D" // Show ArtName() in VnaTag()
#define NAFATTR_S "S" // Show "Situation du stock" in VnaTag()

#ifdef DEF_KITZ
#define KTG_DG "*"
#endif DEF_KITZ

#define PNF_TAGGED  1
#define PNF_IDPAR   2
#define PNF_MATCH   3
#define PNF_AVNA    4
#define PNF_MONT    5
#define PNF_IDDEV   6
#define PNF_IDJNL   7 // of first document
#define PNF_IDDOC   8 // of first document
#define PNF_DATE    9 // of first document
#define PNF_ALEN    9


