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

static snShouldRebuild := 0.95
static snTestCount
static scTestTitle
static slTestTried
static slTestOkay
static snErrCount
* static nErrCount
static scNoTest
static snLogFile := -1
static snWarnings
static snTestsTried
static snTestsRequested
static snRecCount
static saTests

static MSG_DUP_REF := " : duplicate primary key"

#ifdef LG_FRENCH
  static MSG010 := " : cl“ture invalide !"
  static MSG_CTGEDIT := "Historique mensuel comptes g‚n‚raux"
  static MSG_CTP := "Historique mensuel comptes particuliers"
  * static MSG_MVP := "Historique comptes particuliers"
  static MSG077 := "Test d'int‚grit‚"
  * static MSG084 := "Test d'int‚grit‚, partie "
  static MSG085 := "Historique mensuel T.V.A."
  static MSG091 := "Reconstruction des mouvements comptables"
  static MSG092 := "V‚rification des lettrages"
  static MSG094 := " documents ont ‚t‚ r‚organis‚s. "
  static MSG099 := " erreurs."
  * static MSG_BACKUP := "Avez-vous fait un backup de votre base de donn‚es (O/N) ?"
  * static MSG_CHECKIT := " … v‚rifier : "
  static MSG_NOTCLOSED := " (document non cl“tur‚)"
  #ifdef DEF_ANA
    static MSG_CTA := "Hist.mensuel analytiques"
  #endif
  #ifdef DEF_MVS
    static MSG_MVSEDIT  := "Historique stock"
  #endif DEF_MVS
  #ifdef DEF_CTS
    static MSG_CTS := "Historique mensuel articles"
  #endif DEF_CTS
  static MSG_STK := "Stocks"
  * #ifdef DEF_TRA
  *   static MSG_TRTEDIT := "Types de transaction"
  * #endif DEF_TRA
  static MsgRebuild := "Reconstruire Historique mensuel"
  * static MSG_ADMIN  := "Menu administrateur"
  * static MSG_EXPERT := "Menu expert"
  * #ifdef DEF_ART
  *   static MSG_LAGER := "GESTION DE STOCK"
  * #endif DEF_ART
  * #ifdef DEF_ACF
  *   static MSG_ACF := "Partnerpreise"
  * #endif DEF_ACF

#endif LG_FRENCH

#ifdef LG_GERMAN
  static MSG010 := " : Registrierung ungltig !"
  static MSG_CTGEDIT := "Sammelhistorik Generalkonten"
  static MSG_CTP := "Sammelhistorik Partnerkonten"
  * static MSG_MVP := "Historik Partnerkonten"
  static MSG077 := "Integrit„tstest"
  * static MSG084 := "Integrit„tstest Teil "
  static MSG085 := "Sammelhistorik Mehrwertsteuer"
  static MSG091 := "Kontenbewegungen rekonstruieren"
  static MSG092 := "Lettrierungen prfen"
  static MSG094 := " Dokumente wurden reorganisiert. "
  static MSG099 := " Fehler."
  * static MSG_BACKUP := "Haben Sie ein Backup Ihrer Datenbank (J/N) ?"
  * static MSG_CHECKIT := " zu prfen : "
  static MSG_NOTCLOSED := " (Dokument nicht registriert)"
  #ifdef DEF_ANA
    static MSG_CTA := "Sammelhistorik Analysekonten"
  #endif
  #ifdef DEF_MVS
    static MSG_MVSEDIT  := "Lagerhistorik"
  #endif
  #ifdef DEF_CTS
    static MSG_CTS := "Sammelhistorik Artikel"
  #endif DEF_CTS
  * static MSG_STK := "Stocks"
  * #ifdef DEF_TRA
  *   static MSG_TRTEDIT := "Transaktionsarten"
  * #endif DEF_TRA
  static MsgRebuild := "Sammelhistorik rekonstruieren"
  * static MSG_ADMIN  := "Verwaltermen"
  * static MSG_EXPERT := "Expertenmen"
  * #ifdef DEF_ART
  *   static MSG_LAGER := "LAGERVERWALTUNG"
  * #endif DEF_ART
  #ifdef DEF_ACF
    static MSG_ACF := "Partnerpreise"
  #endif DEF_ACF

#endif

#ifdef LG_EN
  static MSG010 := " : Registrierung ungltig !"
  static MSG_CTGEDIT := "Sammelhistorik Generalkonten"
  static MSG_CTP := "Sammelhistorik Partnerkonten"
  static MSG077 := "Integrity Test"
  static MSG085 := "Monthly Summary V.A.T."
  static MSG091 := "Rebuild General Ledger history"
  static MSG092 := "Check General Ledger matches"
  static MSG094 := " documents have been rebooked. "
  static MSG099 := " error(s)."
  static MSG_NOTCLOSED := " (document not booked)"
  #ifdef DEF_ANA
    static MSG_CTA := "Sammelhistorik Analysekonten"
  #endif
  #ifdef DEF_MVS
    static MSG_MVSEDIT  := "Lagerhistorik"
  #endif
  #ifdef DEF_CTS
    static MSG_CTS := "Sammelhistorik Artikel"
  #endif DEF_CTS
  static MsgRebuild := "Rebuild monthly summaries"
  #ifdef DEF_ACF
    static MSG_ACF := "Partnerpreise"
  #endif DEF_ACF

#endif



* #define WRN_ALIAS 1
#define WRN_TEST  1
#define WRN_MSG   2
#define WRN_ALEN  2

*#define TST_TAGGED 1
*#define TST_BLOCK  2
*#define TST_NAME   3
*#define TST_ALEN   3

#define TST_NAME   1
#define TST_TITLE  2
#define TST_BLOCK  3
#define TST_ALEN   3


FUNCTION itinit() // called from AppReadDbi()
* default lDlg to .t.
local a := {}
#ifdef DEF_GEN
  aadd(a, {  "GenTest", "Generalkonten", {|x| GenTest(x)    } } )
#endif DEF_GEN
#ifdef DEF_ART
  aadd(a, {  "ArtTest", "Artikel", {|x| ArtTest(x)    } } )
#endif DEF_ART
#ifdef DEF_PRJ
  aadd(a, {  "PrjTest", "Projekte", {|x| PrjTest(x)    } } )
#endif DEF_PRJ
#ifdef DEF_PRB
  aadd(a, { "PprTest", "Themenzuweisungen", ;
            {|x| DbfTest(oPpr(),"PPR->IdPar+'/'+alltrim(PPR->IdPrb)")};
  })

#endif DEF_PRB
#ifdef DEF_DLS
  aadd(a, {  "DlsTest", "Dienstleistungen", {|x| DlsTest(x)    } } )
#endif DEF_DLS
#ifdef DEF_DLP
  aadd(a, {  "DlpTest", "Anwesenheiten", {|x| DlpTest(x)    } } )
#endif DEF_DLP
#ifdef DEF_KITZ
  aadd(a, {  "SesTest", "Sitzungen", {|x| SesTest(x)    } } )
  aadd(a, {  "KtgTest", "Kontingente", {|x| KtgTest(x)    } } )
  aadd(a, {  "KrgTest", "Rechnungen", {|x| KrgTest(x)    } } )
  aadd(a, {  "KrlTest", "Rechnungen Inhalt", {|x| KrlTest(x)    } } )
#endif DEF_KITZ
#ifdef DEF_PLS
  aadd(a, {  "MbrTest", "Mitgliedschaften", {|x| MbrTest(x)    } } )
#endif DEF_PLS
#ifdef DEF_ODS
  aadd(a, {  "OdlTest", "Lagerdokumente Inhalt", {|x| OdlTest(x)    } } )
#endif DEF_ODS
#ifdef DEF_LNK
  aadd(a, {  "LniTest", "Links", {|x| LniTest(x)    } } )
#endif DEF_LNK
#ifdef DEF_IMP
  aadd(a, {"BudTest",    "Haushaltsartikel", {|x| BudTest(x)    } } )
  aadd(a, {"MviTest",    "Buchungen", ;
    {|x| MviTest("ChkPeriode(MVI->Periode)==0")    } } )
  aadd(a, {"MviDupTest", "Doppelte Buchungen", ;
    {|x| MviDupTest("ChkPeriode(MVI->Periode)==0")    } } )
  aadd(a, {"MviCtbTest", "Buchungen und CTB", ;
    {|x| MviCtbTest("ChkPeriode(MVI->Periode)==0") } } )
  aadd(a, {"CtbBudTest", "Artikel und CTB", ;
    {|x| CtbBudTest(;
    "inrange(left(CTB->Periode,2),left(MemPer1,2),left(MemPer2,2))";
    )}})
  aadd(a, {"ImpImlTest", "Buchungsdokumente", ;
    {|x| ImpImlTest("ChkPeriode(IMP->Periode)==0") } } )
  aadd(a, {"ImlTest",    "Buchungsdokumente Inhalt", ;
    {|x| ImlTest("ChkPeriode(IMP->Periode)==0") } } )
#endif DEF_IMP
#ifdef DEF_TRA
  aadd(a, {  "TraTest", "Kassentransaktionen", {|x| TraTest(x)    } } )
#endif DEF_TRA
#ifdef DEF_VEN
  aadd(a, {  "VenTest", "Fakturationsdokumente", {|| VenTest("ChkPeriode(VEN->Periode)==0") } } )
  aadd(a, {  "VnlTest", "Fakturationsdokumente Inhalt", {|| VnlTest()    } } )
#endif DEF_VEN
#ifdef DEF_VNA
  aadd(a, {  "VnaTest", "Fakturationsoperationen", ;
    {|| VnaTest("ChkPeriode(VNA->Periode)==0") } } )
#endif DEF_VNA
#ifdef DEF_FIN
  aadd(a, {  "FinTest", "Finanzdokumente", {|x| FinTest(x)    } } )
  aadd(a, {  "FnlTest", "Finanzdokumente Inhalt", {|x| FnlTest(x)    } } )
#endif DEF_FIN
  aadd(a, {  "ParTest", "Partnerstammdaten", {|x| ParTest(x)    } } )
#ifdef DEF_HST
  aadd(a, {  "HstTest", "Historik Buchhaltung", {|x| HstTest(x)    } } )
#endif DEF_HST
#ifdef DEF_ALA
  aadd(a, {  "AlaTest", "Artikelkomponenten", {|x| AlaTest(x)    } } )
#endif DEF_ALA
#ifdef DEF_ACF
  aadd(a, {  "AcfTest", "Partnerpreise", {|x| AcfTest(x)    } } )
#endif DEF_ACF
#ifdef DEF_SER
  aadd(a, {  "SerTest", "Seriennummern", {|x| SerTest(x)    } } )
#endif DEF_SER
***
*if lDlg .and. len(a) == 0
*  browse array a using {|x| ;
*                         if(x[TST_TAGGED],BUTTON_ON,BUTTON_OFF) + " " + ;
*                         padr(x[TST_NAME],15) ;
*                       } ;
*                 space {|x|x[TST_TAGGED] := ! x[TST_TAGGED]} ;
*                 help "TIMTEST"
*  RETURN .f. if lastkey() == K_ESC
*endif
*RETURN a
saTests := a
RETURN .t.

FUNCTION SetTest(cName,bBlock)
local i
for i := 1 to len(saTests)
  if saTests[i][TST_NAME] == cName
    saTests[i][TST_BLOCK] := bBlock
    RETURN .t.
  endif
next i
RETURN !SetMsg(cName+" : unknown test.")

FUNCTION PickTstList(cList)
local i
local lAll := .t.
if empty(cList)
  cList := ""
  for i := 1 to len(saTests)
    cList += saTests[i][TST_NAME] + " "
  next i
endif
cList := PickAttrib(saTests,"Tests",cList," ")
RETURN NIL if cList == NIL
for i := 1 to len(saTests)
  if ! saTests[i][TST_NAME] $ cList
    lAll := .f.
    exit
  endif
next i
RETURN space(len(cList)) if lAll
RETURN cList

*FUNCTION PickTstList(cStart)
*local lAll := .t.
*local i
*local s := ""
*for := 1 to len(saTests)
*  saTests[i][TST_TAGGED] := saTests[i][TST_NAME] $ cStart
*next i
*browse array saTests using {|x| ;
*                       if(x[TST_TAGGED],BUTTON_ON,BUTTON_OFF) + " " + ;
*                       padr(x[TST_NAME],15) ;
*                     } ;
*               space {|x|x[TST_TAGGED] := ! x[TST_TAGGED]} ;
*               help "TIMTEST"
*RETURN NIL if lastkey() == K_ESC
*for := 1 to len(saTests)
*  if saTests[i][TST_TAGGED]
*    s += saTests[i][TST_NAME] + " "
*  else
*    lAll := .f.
*  endif
*next i
*RETURN space(len(cStart)) if lAll
*RETURN padr(s,len(cStart))


FUNCTION itest(cTstList,cLogFile)
local lOkay := .t.
local lComplete := .t.
local lErrors := .f.
local i
local a := saTests
local nSeconds := seconds()
* RETURN .f. if ! itinit(lDlg)
scNoTest := DlmMemoRead("NOTEST.TXT")
default cLogFile to dbpath()+"\timtest.txt"
if (snLogFile := fcreate(cLogFile)) == -1
  RETURN ! SetMsg(cLogFile+MsgDosError(ferror()))
endif
snWarnings := 0
snTestsTried := 0
// 20060516 SetDialog(.f.)
snTestsRequested := 0
default cTstList to ""
cTstList := lower(cTstList)
for i := 1 to len(a)
  if empty(cTstList) .or. lower(a[i][TST_NAME]) $ cTstList
    snTestsRequested += 1
  endif
next i
it_note(MSG077 + " " + dtocf(date())+" "+time())
for i := 1 to len(a)
  TestBegin(a[i][TST_TITLE])
  if empty(cTstList) .or. lower(a[i][TST_NAME]) $ cTstList
    * if a[i][TST_TAGGED]
    eval(a[i][TST_BLOCK])
  endif
  TestReport()
  if slTestTried
    if ! slTestOkay
      lOkay := .f.
      exit
    endif
  else
    lComplete := .f.
  endif
  if snTestCount != 0
    lErrors := .t.
  endif
next i
// 20060516 SetDialog(.t.)
ddCloseAll()
it_note(ntrim(snWarnings)+" warnings in "+ntrim(snTestsTried) ;
  + " of "+ntrim(len(saTests))+ " tests.")
it_note("Done after "+ntrim(seconds()-nSeconds)+" seconds.")
fclose(snLogFile)
** !lOkay : wenn der Test unterbrochen wurde
** !lComplete : wenn nicht alle Test angefragt wurden
** lErrors : ob Fehlermeldungen waren
if lOkay .and. lComplete
  if lErrors
    IndDelete("TIMTEST")
  else
    IndCreate("TIMTEST")
  endif
endif
RETURN lOkay


FUNCTION TimTest(cTplIni,cPreview,lDlg)
local cLogFile := dbpath()+"\timtest.txt"
default lDlg to .t.
* default lPrint to .t.
default cTplIni to "LISTE"
default cPreview to BUTTON_ON
SetTplIni(cTplIni)
SetPreview(cPreview)
setvar("TstList",space(200))
if lDlg
  RETURN .f. if ! DlgExec("TIMTEST")
endif
RETURN .f. if ! itest(trim(getvar("TstList")),cLogFile)
RETURN fprint(cLogFile,"[]",76,{|| PrintHeader(MSG077) })



FUNCTION TestBegin(cTitle)
snTestCount := 0
scTestTitle := cTitle
slTestTried := .f.
slTestOkay := .f.
RETURN .t.

FUNCTION MsgShouldRebuild() // cTitle,nCount)
local cMsg := alias() + " : " + ntrim(snRecCount) + " records. "
TestOkay()
if snRecCount / lastrec() <= snShouldRebuild .and. snRecCount != 0
  cMsg += ntrim0(100- snRecCount * 100 / lastrec()) + utrp( ;
    "% of file space would be freed by compacting.",;
    "% der Datei wrden durch Kompaktierung eingespart.",;
    "% du fichier seraient lib‚r‚s par un compactage.")
endif
it_note(cMsg)
RETURN NIL


FUNCTION TestReport()
if slTestTried
  if ! slTestOkay
    //PrintLine
    it_note(scTestTitle + MsgFailed() )
  endif
  if snTestCount == 0
    it_note(scTestTitle + " : OK") // MsgDone())
  else
    it_note(scTestTitle + " : " + ntrim(snTestCount) + " warnings")
  endif
else
  it_note(scTestTitle + " : nicht angefragt")
endif
RETURN .t.


FUNCTION TestOkay
slTestOkay := .t.
SetMsg("")
RETURN .t.

FUNCTION TestTried()
TstStatus()
// MsgDisplay(scTestTitle)
slTestTried := .t.
snTestsTried++
snRecCount := 0
RETURN .t.


FUNCTION it_note(c)
fwrite(snLogFile,c+CR_LF)
// PrintLine(c)
RETURN .t.

FUNCTION it_warning(c)
RETURN .t. if TimTestAllow(c)
RETURN .f. if c $ scNoTest
if snTestCount == 0
  // PrintLine()
  // fwrite(snLogFile,CR_LF)
  it_note("")
endif
snTestCount++
snWarnings++
it_note("["+ntrim(snWarnings)+"] "+c)
RETURN TstStatus()

FUNCTION TstStatus
RETURN MsgDisplay(scTestTitle+" ("+ntrim(snWarnings)+" warnings)")

FUNCTION TestInter()
local n
RETURN .t. if TaskInter()
n := ++snRecCount * 100 / (lastrec() * snTestsRequested)
n += (snTestsTried-1) * 100 / snTestsRequested
* MsgDisp2(ntrim0(++snRecCount * 100 / (lastrec()*snTestsRequsted)) + "%" )
MsgDisp2(ntrim0(n) + "%" )
RETURN .f.


FUNCTION ErrorReport(c,lOkay,nWarnings,nDelete,nErrors)
if lOkay
  c += " done. "
else
  c += " aborted. "
endif
if nWarnings != 0
  c += ntrim(nWarnings) + " warnings. "
endif
if nDelete != 0
  c += ntrim(nDelete) + " recoverable errors."
endif
if nErrors != 0
  c += ntrim(nErrors) + " unrecoverable errors."
endif
PrintLine(c)
RETURN NIL







**
** PrintAct
**
* PrintAct(\
*   "TIMTEST",\
*   {||PrintHeader("Integrit„tstest")}, \
*   "%PC","X",80\
* )
FUNCTION PrintAct(cActName,bTitBlock,cTplIni,cPreview,nWidth)
local lOkay := .t.
default cTplIni to "LISTE"
default cPreview to BUTTON_ON
default nWidth to 76
default bTitBlock to {|| PrintHeader(cActName) }
SetTplIni(cTplIni)
SetPreview(cPreview)
snTestCount := 0
open printer SetTplIni() width (nWidth) ;
     preview SetPreview() ;
     TitBlock (bTitBlock)
  // 20060516 SetDialog(.f.)
  lOkay := ActExec(cActName)
  // 20060516 SetDialog(.t.)
  ddCloseAll()
close printer
RETURN lOkay



*#ifdef DEF_MVP
*
*FUNCTION MvpTest(cTitle)
*local cMatch
*local lOkay := .f.
*local nCount := 0
*local doc
*TestTried()
*open area oMvp(), oPar()
*  lOkay := .t.
*  go top
*  do while ! eof() .and. LstContinue()
*    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
*    if CtrLocate(MVP->IdCtr) == NIL
*      it_warning("MVP->" + MsgIdJnlDoc() + " : " + MVP->IdCtr + MsgCtrExist())
*    endif
*    if JnlLocate(MVP->IdJnl) == NIL
*      it_warning("MVP-> " + MsgIdJnlDoc() + MsgJnlExist())
*    endif
*    if ! ParExist(MVP->IdPar)
*      it_warning("MVP-> " + MsgIdJnlDoc() + " : " + SetMsg() )
*    endif
*    if ! MVP->DC $ "DC"
*      it_warning("MVP-> " + MsgIdJnlDoc() + " : D/C-Fehler" )
*    endif
*    if ! PerExist(MVP->Periode,MVP->IdJnl)
*      it_warning("MVP-> " + MsgIdJnlDoc() + " : " + MVP->Periode + " : unbekannte Periode" )
*    endif
*    if MVP->Mont != ntom(val(MVP->Mont))
*      it_warning("MVP-> " + MsgIdJnlDoc() + " : strange value " + MVP->Mont + " in MVP->Mont" )
*    endif
*    if ! empty(MVP->IdDoc)
*      if (doc := DocInfo(MVP->IdJnl,MVP->IdDoc,MVP->Line)) == NIL
*        it_warning("MVP-> " + MsgIdJnlDoc() + " : unbekanntes Dokument" )
*      else
*        if empty(doc[DOC_MATCH])
*          cMatch := MVP->IdJnl + MVP->IdDoc
*        else
*          cMatch := doc[DOC_MATCH]
*        endif
*        if MVP->Match != cMatch
*          it_warning( ;
*            "MVP-> " + MsgIdJnlDoc() + "." + MVP->Line + ;
*            " : Manuelle Lettrierung wurde nicht eingetragen" ;
*          )
*          * if cDoit == BUTTON_ON
*          *   DocSetMatch(MVP->IdJnl,MVP->IdDoc,MVP->Line,MVP->IdPar,MVP->Match)
*          * endif
*        endif
*      endif
*    endif
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    skip
*  enddo
*close area
*RETURN lOkay
*
*#endif DEF_MVP




#ifdef DEF_HST

**
** HstTest()
**
FUNCTION HstTest()
local nMont
local jnl
local lOkay := .f.
* local nCount := 0
local db
open area oHst(), oGen(), oPar(), oFin(), oVen(), oAna()
  TestTried()
  ddSetOrder(ORD_HST_DOC)
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    * MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    * if TaskInter() ; lOkay := .f. ; exit ; endif
    if ! empty(HST->IdCtr)
      if CtrLocate(HST->IdCtr) == NIL
        it_warning("HST->" + MsgIdJnlDoc() + " : " + HST->IdCtr + MsgCtrExist())
      endif
    endif
    if ! empty(HST->IdPar)
      if ! ParExist(HST->IdPar)
        it_warning("HST-> " + MsgIdJnlDoc() + " : " + SetMsg() )
      endif
    endif
    if empty(HST->IdGen)
      it_warning("HST-> " + MsgIdJnlDoc() + " : IdGen empty")
    elseif ! GenExist(HST->IdGen)
      it_warning("HST-> " + MsgIdJnlDoc() + " : " + SetMsg() )
    elseif ! HST->DC $ "DC"
      it_warning("HST-> " + MsgIdJnlDoc() +  " : weder D noch C" )
    elseif ! PerExist(HST->Periode,HST->IdJnl)
      it_warning("HST-> " + MsgIdJnlDoc() + " : " + HST->Periode + " : unbekannte Periode" )
    #ifdef DEF_ANA
      elseif !empty(HST->IdAna) .and. ! AnaExist(HST->IdAna)
        it_warning("HST-> " + MsgIdJnlDoc() + " : " + SetMsg() )
    #endif DEF_ANA
*    elseif HST->Mont != ntom(val(HST->Mont))
*      if ltrim(HST->Mont) != "0"
*        it_warning("HST-> " + MsgIdJnlDoc() + " : strange value " + HST->Mont + " in HST->Mont" )
*      endif
    endif
***********
* 2001-03-01. Rudi hat PAR->IdDev von "leer" nach EUR gesetzt. Das soll
* doch jetzt nicht im I-Test kommen. HstMont() nimmt MontDev jetzt aber
* auch nur dann, wenn das Feld nicht leer ist.
    * if ! empty(HstIdDev()) .and. empty(HST->MontDev)
    if ! empty(HST->IdDev)
      if ! DevExist(HST->IdDev)
        it_warning( ;
          "HST-> " + MsgIdJnlDoc() + "."+HST->Line + SetMsg() )
      elseif PerDevFixed(HST->Periode,HST->IdDev)
        db := DevLocate(DevDefault(HST->Periode))
        * if db == NIL // das gibts einfach nicht...
        if empty(HST->MontDev)
          it_warning( ;
            "HST-> " + MsgIdJnlDoc() + "."+HST->Line ;
            +" : MontDev ist leer !" )
        elseif ! empty(db[DEV_DELTA])
          nMont := Dev2Db(HST->IdDev,HST->Periode,val(HST->MontDev))
          if abs(val(HST->Mont) - nMont) > val(db[DEV_DELTA])
            it_warning( ;
              "HST-> " + MsgIdJnlDoc() + "."+HST->Line ;
              +" : Betrag GW ist " + HST->Mont ;
              + " statt " + ntom(nMont,db[DEV_DECPOS]))
          endif
        endif
      endif
    endif
**************
    if DocInfo(HST->IdJnl,HST->IdDoc,HST->Line) == NIL
      it_warning("HST-> " + MsgIdJnlDoc() + " : unbekanntes Dokument" )
    endif
    if (jnl := JnlLocate(HST->IdJnl)) == NIL
      it_warning("HST-> " + MsgIdJnlDoc() + MsgJnlExist())
    else
      if ! empty(jnl[JNL_IDCTR])
        if jnl[JNL_IDCTR] != GEN->IdCtr .and. ! GENATTR_T $ GEN->Attrib
          it_warning("HST-> " + MsgIdJnlDoc() +  " " + HST->IdGen + " : GEN->IdCtr != JNL->IdCtr" )
        endif
      endif
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay


* FUNCTION MaxDevDiff(cPeriode)
* local nDecPos := DevDecPos(DevDefault(cPeriode))
* RETURN 50 if nDecPos == 0
* RETURN 5


/********** HstDevTest() funktionierte sowieso nicht richtig...
**
** HstDevTest()
**
*FUNCTION HstDevTest(cTitle,lAutoFix,nTol)
*local jnl
*local lOkay := .f.
*local nCount := 0
*local doc
*local cMontDev
*default cTitle to "Fremdw„hrung prfen"
*default lAutoFix to Confirm("Fehler automatisch beheben (J/N) ?")
*default nTol to 0.1
*MsgDisplay(cTitle + "...")
*open printer "LISTE" ;
*     TitBlock {|| PrintHeader(cTitle) }
*open area oHst(), oGen(), oPar()
*  ddSetOrder ORD_HST_DOC
*  lOkay := .t.
*  go top
*  do while ! eof() .and. LstContinue()
*    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
*    if empty(HST->IdCtr)
*      if (doc := DocInfo(HST->IdJnl,HST->IdDoc,HST->Line)) == NIL
*        PrintLine("HST-> " + MsgIdJnlDoc() + " : unbekanntes Dokument" )
*      else
*        if doc[DOC_IDDEV] == DevDefault(HST->Periode)
*          ** Das Dokument war in Grundw„hrung ausgestellt.
*          ** Also ist HST->MontDev in der W„hrung des Generalkontos.
*          if empty(GEN->IdDev) .or. GEN->IdDev == DevDefault(HST->Periode)
*            ** Auch das Generalkonto ist in Grundw„hrung. Also
*            ** interessiert HST->MontDev uns nicht und soll leer sein.
*            cMontDev := space(LenMont())
*          else
*            ** Hier haben wir das Problem, dass der Wechselkurs nicht
*            ** bekannt ist. Das kommt ja normalerweise auch nicht vor.
*            if empty(HST->MontDev)
*              cMontDev := ntom( ;
*                Db2Dev(GEN->IdDev,HST->Periode,val(HST->Mont)), ;
*                DevDecPos(GEN->IdDev,HST->Periode) ;
*              )
*              * cMontDev := ntom( ;
*              *   val(HST->Mont) / val(DevCours(GEN->IdDev,HST->Periode)), ;
*              *   DevDecPos(GEN->IdDev,HST->Periode) ;
*              * )
*            else
*              cMontDev := HST->MontDev
*            endif
*          endif
*        else
*          ** Das Dokument war in einer Fremdw„hrung ausgestellt.
*          ** HST->MontDev ist also in jedem Fall diese W„hrung.
*          cMontDev := ntom( ;
*            val(HST->Mont) / doc[DOC_COURS], ;
*            DevDecPos(doc[DOC_IDDEV],HST->Periode) ;
*          )
*        endif
*        if abs(val(cMontDev) - val(HST->MontDev)) > nTol
*          if empty(HST->MontDev) .or. HST->MontDev == HST->Mont
*            if lAutoFix .and. ddRecLock()
*              PrintLine( ;
*                "HST-> " + MsgIdJnlDoc() + " " + HST->IdGen ;
*                + " : HST->MontDev wurde ersetzt durch " + ltrim(cMontDev) ;
*              )
*              HST->MontDev := cMontDev
*              unlock record
*            else
*              PrintLine( ;
*                "HST-> " + MsgIdJnlDoc() + " " + HST->IdGen ;
*                + " : HST->MontDev sollte sein " + ltrim(cMontDev) ;
*              )
*            endif
*          else
*            PrintLine( ;
*              "HST-> " + MsgIdJnlDoc() + " " + HST->IdGen ;
*              + " : HST->MontDev sollte sein " + ltrim(cMontDev) ;
*              + " anstelle von " + ltrim(HST->MontDev) ;
*            )
*          endif
*        endif
*      endif
*    endif
*    skip
*  enddo
*close area
*close printer
*RETURN .t.
***************************/

#endif DEF_HST


#ifdef DEF_GEN

FUNCTION GenTest()
local lOkay := .f.
* local nCount := 0
local cOldId := ""
local cMontDev
local dev
local nDelta
open area oGen()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    if GEN->IdGen == cOldId
      it_warning(GEN->IdGen + MSG_DUP_REF)
      * if cDoIt == BUTTON_ON
      *   if ddRecLock() ; delete ; unlock record ; endif
      * endif
    else
      cOldId := GEN->IdGen
    endif
    #ifdef DEF_MVA
      #ifndef DEF_IMP
        if ! GENATTR_Y $ GEN->Attrib
          open area oMva()
            ddSetOrder ORD_MVA_GEN
            softseek GEN->IdGen
            if ! eof() .and. MVA->IdGen == GEN->IdGen
              it_warning(GEN->IdGen + " : GENATTR_Y nicht gesetzt !")
            endif
          close area
        endif
      #endif
    #endif DEF_MVA
    #ifdef DEF_HST
      if ! empty(GEN->IdDev)
        if (dev:=DevLocate(GEN->IdDev)) == NIL
          it_warning(GEN->IdGen + " : " + GEN->IdDev + MsgDevExist())
        * rausgeholt am 2001-03-13 :
        *elseif ! empty(dev[DEV_DELTA])
        *  nDelta := val(dev[DEV_DELTA])
        *  open area oHst(), oFin(), oVen()
        *    ddSetOrder ORD_HST_GENDATE
        *    softseek GEN->IdGen
        *    do while ! eof() .and. HST->IdGen == GEN->IdGen
        *      cMontDev := ntom(HstDb2Dev(GEN->IdDev),DevDecPos(GEN->IdDev))
        *      if abs(val(HST->MontDev) - val(cMontDev)) > nDelta
        *        it_warning( ;
        *          MsgIdJnlDoc() + " : " ;
        *          + ltrim(HST->MontDev) ;
        *          + " (statt " + ltrim(cMontDev) + ") " + GEN->IdDev + ;
        *          " widerspricht " ;
        *          + ltrim(HST->Mont) + " " + DevDefault(HST->Periode) ;
        *          + " !" ;
        *        )
        *      endif
        *      skip
        *    enddo
        *  close area
        endif
      endif
    #endif DEF_HST
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#ifdef DEF_HST



**
** HstDev2Db(cIdDev)
** deprecated
**
FUNCTION HstDev2Db(cIdDev)
local cAlias := JnlAlias(HST->IdJnl)
#ifdef DEF_FIN
  if cAlias == JNLALIAS_FIN
    seek HST->IdJnl+HST->IdDoc in FIN
    RETURN FinDev2Db(val(HST->MontDev)) if FIN->IdDev == cIdDev
  endif
#endif DEF_FIN
#ifdef DEF_VEN
  if cAlias == JNLALIAS_VEN
    seek HST->IdJnl+HST->IdDoc in VEN
    RETURN VenDev2Db(val(HST->MontDev)) if VEN->IdDev == cIdDev
  endif
#endif DEF_VEN
RETURN Dev2Db(cIdDev,HST->Periode,val(HST->MontDev))
**
** HstDb2Dev(cIdDev)
** deprecated
**
FUNCTION HstDb2Dev(cIdDev)
local cAlias := JnlAlias(HST->IdJnl)
#ifdef DEF_FIN
  if cAlias == JNLALIAS_FIN
    seek HST->IdJnl+HST->IdDoc in FIN
    RETURN FinDb2Dev(val(HST->Mont)) if FIN->IdDev == cIdDev
  endif
#endif DEF_FIN
#ifdef DEF_VEN
  if cAlias == JNLALIAS_VEN
    seek HST->IdJnl+HST->IdDoc in VEN
    RETURN VenDb2Dev(val(HST->Mont)) if VEN->IdDev == cIdDev
  endif
#endif DEF_VEN
RETURN Db2Dev(cIdDev,HST->Periode,val(HST->Mont))

#endif DEF_HST

#endif DEF_GEN

#ifdef DEF_ART

FUNCTION ArtTest()
local lOkay := .f.
* local nCount := 0
local cOldId := ""
open area oArt(),oGra()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    * if TaskInter() ; lOkay := .f. ; exit ; endif
    * MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if ART->IdArt == cOldId
      it_warning("ART " + ART->IdArt + MSG_DUP_REF)
    else
      cOldId := ART->IdArt
    endif
    #ifdef DEF_GRA
      if ! empty(ART->iGra) .and. ! GraExist(ART->iGra)
        it_warning("ART " + ART->IdArt + " : " + SetMsg())
      endif
    #endif DEF_GRA
    if !OnTest(oArt())
      it_warning("ART " + ART->IdArt + " : " + SetMsg())
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_ART

#ifdef DEF_PRJ

FUNCTION PrjTest()
local lOkay := .f.
* local nCount := 0
local cOldId := ""
local cField
open area oPrj()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    * if TaskInter() ; lOkay := .f. ; exit ; endif
    * MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if PRJ->IdPrj == cOldId
      it_warning("PRJ " + PRJ->IdPrj + MSG_DUP_REF)
    else
      cOldId := PRJ->IdPrj
    endif
    #ifdef CUST_MOOR
      cField := PrjIsUpdated()
      if cField != NIL
        it_warning("PRJ " + PRJ->IdPrj + " : Projektfeld "+cField+" stimmt nicht")
      elseif PRJ->Type == "?"
        it_warning("PRJ " + " : " + SetMsg())
      endif
    #endif CUST_MOOR
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_PRJ




#ifdef DEF_DLS

FUNCTION DlsTest()
local lOkay := .f.
* local nCount := 0
local cOldId := ""
open area oDls(), oDla(), oPar()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if DLS->IdDls == cOldId
      it_warning("DLS " + DLS->IdDls + MSG_DUP_REF)
    else
      cOldId := DLS->IdDls
    endif
    if ! DlsTestRec()
      it_warning("DLS " + DLS->IdDls + " : " + SetMsg())
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_DLS

#ifdef DEF_DLP

FUNCTION DlpTest()
local lOkay := .f.
* local nCount := 0
local cOldId := ""
open area oDlp(), oPar(), oDls()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if DlpIsValid()
      if DLP->IdDls+DLP->IdPar == cOldId
        it_warning("DLP " + DLP->IdDls +","+DLP->IdPar + MSG_DUP_REF)
      else
        cOldId := DLP->IdDls+DLP->IdPar
      endif
    else
      it_warning("DLP " + DLP->IdDls +","+DLP->IdPar + " : " + SetMsg())
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_DLP

#ifdef DEF_KITZ

FUNCTION SesTest()
local lOkay := .f.
* local nCount := 0
local cOldId := ""
local cField
open area oSes(), oPar()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if SES->IdSes == cOldId
      it_warning("SES " + SES->IdSes + MSG_DUP_REF)
    else
      cOldId := SES->IdSes
    endif
    if ! SesRecTest()
      it_warning("SES:" + alltrim(SES->IdSes) + " : " + SetMsg())
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

FUNCTION KtgTest()
local lOkay := .f.
* local nCount := 0
local cOldId := ""
open area oKtg()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if KTG->IdKtg == cOldId
      it_warning("KTG " + ltrim(KTG->IdKtg) + MSG_DUP_REF)
    else
      cOldId := KTG->IdKtg
      if ! KtgIsValid()
        it_warning("KTG " + ltrim(KTG->IdKtg) + " : " + SetMsg())
      endif
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

FUNCTION KrgTest()
local lOkay := .f.
* local nCount := 0
local cOldId := ""
* default ucTitle to "KrgTest()"
* scTestTitle := ucTitle
open area oKrg()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof()
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if TestInter() ; lOkay := .f. ; exit ; endif
    if KRG->IdKrg == cOldId
      it_warning("KRG " + ltrim(KRG->IdKrg) + MSG_DUP_REF)
    else
      cOldId := KRG->IdKrg
      if ! KrgIsValid()
        it_warning("KRG " + ltrim(KRG->IdKrg) + " : " + SetMsg())
      endif
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

FUNCTION KrlTest()
local lOkay  := .f.
* local nCount := 0
* default ucTitle to "KrlTest()"
* scTestTitle := ucTitle
open area oKrl(), oKrg()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    seek KRL->IdKrg in KRG
    if eof() in KRG
      it_warning( "KRL-> " + alltrim(KRL->IdKrg) + " : lost record" )
    endif
    skip
    *if TaskInter() ; lOkay := .f. ; exit ; endif
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay


#endif DEF_KITZ

#ifdef DEF_PLS

FUNCTION MbrTest()
local lOkay := .f.
* local nCount := 0
local cOldId := ""
open area oMbr(), oPar(), oPls()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if ! MbrRecTest()
      it_warning("MBR:" + MbrMsgKey()+ " : " + SetMsg())
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_PLS

#ifdef DEF_IMP

FUNCTION BudTest()
local lOkay := .f.
* local nCount := 0
local cOldId := ""
open area oBud()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if BUD->IdBud == cOldId
      it_warning("BUD " + BUD->IdBud + MSG_DUP_REF)
    else
      cOldId := BUD->IdBud
    endif
    if ddRecLock()
      if ! BudPostEdit()
        it_warning("BUD " + BUD->IdBud + SetMsg())
      endif
      unlock record
    else
      it_warning("BUD " + ntrim(recno()) + " : record lock failed")
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_BUD

FUNCTION ParTest()
local lOkay := .f.
* local nCount := 0
local cOldId := NIL
local b := oPar()
open area b, oPlz(), oNat()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if cOldId != NIL .and. PAR->IdPar == cOldId
      it_warning("PAR->" + PAR->IdPar + MSG_DUP_REF)
    endif
    cOldId := PAR->IdPar
    if ! empty(PAR->Pays)
      if ! NatExist(PAR->Pays)
        it_warning("PAR->" + PAR->IdPar + " : " + SetMsg())
      endif
    endif
    if ! empty(PAR->CP)
      if ! PlzExist(PAR->Pays,PAR->CP)
        it_warning("PAR->" + PAR->IdPar + " : " + SetMsg())
      endif
    endif
    if ! DoEvents(b[AD_ONTEST])
      it_warning(alias()+":"+alltrim(PAR->IdPar)+ " : " + SetMsg())
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#ifdef DEF_ALA

FUNCTION AlaTest()
local lOkay := .f.
* local nCount := 0
open area oAla(), oArt()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if ! ArtExist(ALA->IdArt1)
        it_warning("ALA->" + alltrim(ALA->IdArt1) + "-" ;
          + alltrim(ALA->IdArt2) + " : " + SetMsg())
    endif
    if ! ArtExist(ALA->IdArt2)
        it_warning("ALA->" + alltrim(ALA->IdArt1) + "-" ;
          + alltrim(ALA->IdArt2) + " : " + SetMsg())
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay


#endif DEF_ALA

#ifdef DEF_ACF

FUNCTION AcfTest()
local lOkay := .f.
* local nCount := 0
local b:=oAcf()
open area b, oArt(), oPar()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if ! ArtExist(ACF->IdArt);
      .or.!ParExist(ACF->IdPar);
      .or.!DoEvents(b[AD_ONTEST])
        it_warning("ACF->" + alltrim(ACF->IdArt) + "/" ;
          + alltrim(ACF->IdPar) + " : " + SetMsg())
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay


#endif DEF_ACF

#ifdef DEF_SER

FUNCTION SerTest()
local lOkay := .f.
* local nCount := 0
local cOldId := NIL
open area oSer(), oArt()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if cOldId != NIL
      if SER->IdSer == cOldId
        it_warning("SER->" + SER->IdSer + MSG_DUP_REF)
      elseif SER->IdSer != NextId(cOldId)
        it_warning("SER->" + SER->IdSer + MsgRupture())
      endif
    endif
    cOldId := SER->IdSer
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_SER


#ifdef DEF_ODS

FUNCTION OdlTest()
local cMatch
local lOkay := .f.
* local nCount := 0
local doc
open area oOdl(), oArt()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    *MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if JnlLocate(ODL->IdJnl) == NIL
      it_warning("ODL-> " + MsgIdJnlDoc() + MsgJnlExist())
    endif
    if ! ArtExist(ODL->IdArt)
      it_warning("ODL-> " + MsgIdJnlDoc() + " : " + SetMsg() )
    endif
    *if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_ODS


#ifdef DEF_VEN

FUNCTION VenTest(xlFilter)
local cPeriode
local cIdDoc
local cIdJnl
local lOkay := .f.
* local nCount := 0
local aWrn := ReadArray("VEN.WRN",WRN_ALEN)
local b := oVen()
local jnl
default xlFilter to ".t."
RuptInit()
open area b, oPar(), oPrj()
  TestTried()
  lOkay := .t.
  go top
  cPeriode := ""
  cIdJnl := ""
  cIdDoc := ""
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    if &xlFilter
      if VEN->IdJnl == cIdJnl
        if VEN->IdDoc == cIdDoc
          it_warning(MsgIdJnlDoc() + MSG_DUP_REF)
        endif
      endif
      if ! VenRecTest()
        it_warning(MsgIdJnlDoc() + " : " + SetMsg())
      elseif ! DoEvents(b[AD_ONTEST])
        it_warning(MsgIdJnlDoc() + " : " + SetMsg())
      else
        WrnExec(aWrn)
      endif
      cPeriode := VEN->Periode
      cIdJnl   := VEN->IdJnl
      cIdDoc   := VEN->IdDoc
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

FUNCTION MsgFixed()
#ifdef LG_GERMAN
RETURN "(wird repariert)"
#else
RETURN "(correction automatique)"
#endif

FUNCTION VenRecTest
local nDecPos
#ifdef DEF_VENREMISE
  local lRepair := .t. // NIL
  local aVnr
#endif DEF_VENREMISE
local jnl
local aMvt := {}
local aCtp := {}
local aCtg := {}
local aCts := {}
local aMvs := {}
local nMont := 0
local nSK := 0
local nGenMont
local nParMont
local nMontDev := 0
local nMustDebit := 0
local nHstCount := 0
local i
local lOkay := .f.
local nDebit := 0
local nCredit := 0
local a
local cIdJnl
local cIdDoc
local cDC
local nHstMont
local cIdDev
local ifc
if (jnl := JnlLocate(VEN->IdJnl)) == NIL
  SetMsg(VEN->IdJnl + MsgJnlExist())
  RETURN .f.
endif
RETURN .f. if ! RuptCheck(jnl,VEN->IdDoc,VEN->Periode)
if VEN->Etat != DocStatClosed()
  SetMsg(MsgIdJnlDoc() + MSG_NOTCLOSED)
  RETURN .f.
endif
if (ifc := IfcLocate(jnl[JNL_IDCTR],VEN->IdJnl,VEN->IdMfc)) == NIL
  SetMsg(VEN->IdJnl + " & " + VEN->IdMfc + MsgIfcFail(), NIL, "WRN024" )
  RETURN .f.
endif
RETURN .f. if (a := VenVnlInit(jnl)) == NIL
open area oVnl(VEN->Etat), oGen(), oArt(), oNew(), oVna()
  lOkay := .t.
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                   .and. FIELD->IdJnl == VEN->IdJnl ;
                   .and. lOkay
    if FIELD->Code == LNCODE_REMARQ
      lOkay := .t.
    * 20040116 if !VnlValidate()
    * elseif !VnlFirstCheck(jnl[JNL_IDCTR])
    *   lOkay := .f.
    * #ifdef DEF_TAX
    * elseif !VnlTaxCheck()
    *   lOkay := .f.
    * #endif DEF_TAX
    elseif ! VnlMvtCollect( jnl, aMvt )
      lOkay := .f.
    elseif ! VnlVarCollect()
      lOkay := .f.
    #ifdef DEF_TAX
      #ifdef DEF_GEN
        elseif GENATTR_F $ GEN->Attrib
          if GEN->IdTax != FIELD->IdTax
            SetMsg(GEN->IdGen + MsgGenIdTax() + FIELD->IdTax)
            lOkay := .f.
          endif
      #endif DEF_GEN
    #endif DEF_TAX
    elseif FIELD->Code == LNCODE_ART .or. FIELD->Code == LNCODE_ARTFIXE
      #ifdef DEF_MVS
        if ! VnlMvsCollect(jnl,aMvs)
          lOkay := .f.
        endif
      #endif DEF_MVS
      #ifdef DEF_CTS
        if ! VnlCtsCollect(jnl,aCts,VEN->DC)
          lOkay := .f.
        endif
      #endif DEF_CTS
    endif
    skip
  enddo
close area
if lOkay
  #ifdef DEF_VENREMISE
    aVnr := VenMvtRemise(aMvt)
  #endif
  #ifdef DEF_FRF
    VenFrfCollect(jnl,aMvt)
  #endif DEF_FRF
  VenMvtRound(aMvt,jnl)
  nDecPos := DevDecPos(VEN->IdDev)
  #ifdef DEF_VENREMISE
    if ! JNLATTR_T $ jnl[JNL_ATTRIB]
      for i := 1 to len(aVnr)
        if VEN->&(aVnr[i][VNR_FLDNAME]) != ntom(aVnr[i][VNR_MONT],nDecPos)
          it_warning(MsgIdJnlDoc() ;
          + " : " + aVnr[i][VNR_FLDNAME] ;
          + " enth„lt " ;
          + VEN->&(aVnr[i][VNR_FLDNAME]) ;
          + " statt " ;
          + ntom(aVnr[i][VNR_MONT],nDecPos) ;
          + " ! "+ MsgFixed() ;
          )
          // default lRepair to Confirm("Fehler korrigieren (J/N)")
          if lRepair
            if ddRecLock()
              VEN->&(aVnr[i][VNR_FLDNAME]) := ntom(aVnr[i][VNR_MONT],nDecPos)
              unlock record
            endif
          endif
        endif
      next i
    endif
  #endif
  
  for i := 1 to len(aMvt)
    if aMvt[i][MVT_ISBASE]
      nMontDev += aMvt[i][MVT_MONT]
      nMont  += aMvt[i][MVT_MONTDB]
      nSK    += aMvt[i][MVT_SK]
      nMustDebit += aMvt[i][MVT_MONTDB]
                                          #ifdef DEF_TAX
    else
      if empty(aMvt[i][MVT_TAX][TAX_GENTIERS])
        nMontDev += aMvt[i][MVT_MONT]
        nMont  += aMvt[i][MVT_MONTDB]
      endif
      nMustDebit += aMvt[i][MVT_MONTDB]
                                          #endif DEF_TAX
    endif
  next i
  // 20070830 if VEN->Mont != ntom(nMontDev,nDecPos)
  if abs(val(VEN->Mont)-nMontDev) > (0.1 ** nDecPos) + (0.1 ** (nDecPos+1))
    it_warning(MsgIdJnlDoc() ;
    + " : "+ utr("Document total","Gesamtbetrag","Total du document") + " (" ;
    + ltrim(VEN->Mont) ;
    + ") " + utrWider() + utr(" content ("," Inhalt ("," contenu (") ;
    + ntrim(nMontDev) ;
    +")!")
  endif
  #ifdef DEF_PRIXR
    if VEN->SK != ntom(nSK,nDecPos)
      if ddRecLock()
        VEN->SK := ntom(nSK,nDecPos)
        unlock record
      else
        it_warning(MsgIdJnlDoc() + " : reclock() failed. VEN->SK wrong.")
      endif
    endif
  #endif DEF_PRIXR
  #ifdef DEF_HST
    * if JNLATTR_G $ jnl[JNL_ATTRIB]
    if JnlDoHst(jnl,VEN->Periode)
      nGenMont := 0
      nParMont := 0
      cIdJnl := VEN->IdJnl
      cIdDoc := VEN->IdDoc
      cDC    := VEN->DC
      * cIdDev := VEN->IdDev
      open area oHst(), oVen(), oGen(), oPar()
        ddSetOrder(ORD_HST_DOC)
        softseek cIdJnl + cIdDoc
        do while ! eof() .and. HST->IdDoc == cIdDoc ;
                         .and. HST->IdJnl == cIdJnl
          if HST->DC == cDC
            nDebit += val(HST->Mont)
          else
            nCredit += val(HST->Mont)
          endif
          // nHstMont := HstMont(cIdDev)
          if empty(HST->IdCtr)
            if HST->DC == cDC
              nGenMont -= val(HST->Mont)
              * nGenMont -= nHstMont // val(HST->Mont)
            else
              nGenMont += val(HST->Mont)
              * nGenMont += nHstMont // val(HST->Mont)
            endif
          else
            if HST->DC == cDC
              nParMont += val(HST->Mont)
              * nParMont += nHstMont // val(HST->Mont)
            else
              nParMont -= val(HST->Mont)
              * nParMont -= nHstMont // val(HST->Mont)
            endif
          endif
          nHstCount++
          skip
        enddo
      close area
      // 20070830 if abs(nDebit - nCredit) > Tolerance(SetDecPos())
      if abs(nDebit - nCredit) > 0.1 ** SetDecPos() + (0.1 ** (nDecPos+1))
        it_warning( ;
          MsgIdJnlDoc() ;
          + " : Debit (" ;
          + ntrim(nDebit) ;
          + ") " + utrWider() + " Kredit (" ;
          + ntrim(nCredit) ;
          +") !";
        )
      endif
      if IFCATTR_E $ ifc[IFC_ATTRIB]
        if abs(nParMont) > Tolerance(SetDecPos())
          it_warning( ;
            MsgIdJnlDoc() + ;
            " : Saldo Partnerkonten nicht Null : " ;
            + ntrim(nParMont);
          )
        endif
      else
        // 20070830 if abs(nParMont - nMont) > Tolerance(SetDecPos())
        if abs(nParMont - nMont) > 0.1 ** SetDecPos()+(0.1**(nDecPos+1))
          it_warning( ;
            MsgIdJnlDoc() + ;
            " : Inhalt (" ;
            + ntrim(nMont);
            +") " + utrWider() + " Partnerhistorik (" ;
            + ntrim(nParMont);
            +") !" ;
          )
        endif
      endif
      if IFCATTR_E $ ifc[IFC_ATTRIB]
        if abs(nGenMont) > Tolerance(SetDecPos())
          it_warning( ;
            MsgIdJnlDoc() + ;
            " : Saldo Generalkonten nicht Null : " ;
            + ntrim(nGenMont);
          )
        endif
      else
        // 20070830 if abs(nGenMont - nMont) > Tolerance(SetDecPos())
        if abs(nGenMont - nMont) > 0.1**SetDecPos()+(0.1**(nDecPos+1))

          it_warning( ;
            MsgIdJnlDoc() + ;
            " : Inhalt (" ;
            + ntrim(nMont) ;
            + ") "+utrWider()+" "+utrHistorik()+" (" ;
            + ntrim(nGenMont) ;
            +") !" ;
          )
        endif
      endif
      if nHstCount == 0 .and. len(aMvt) != 0
        it_warning( ;
          MsgIdJnlDoc() + " : keine Buchungen in Historik !" ;
        )
      endif
    endif
  #endif DEF_HST
  * #ifdef DEF_ANA
  *   if ! VenMvaTest()
  *     it_warning(MsgIdJnlDoc() + " : " + SetMsg() )
  *   endif
  * #endif DEF_ANA
endif
VnlRestore(a)
RETURN lOkay


FUNCTION VnlTest()
local jnl
local lOkay     := .f.
* local nCount := 0
local cIdJnl
local cIdDoc
local tax
local b := oVnl(DocStatClosed())
open area b, oVen(), oGen(), oArt(), oPar()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    cIdJnl := FIELD->IdJnl
    cIdDoc := FIELD->IdDoc
    seek cIdJnl + cIdDoc in VEN
    if eof() in VEN
      it_warning( ;
        alias() + "-> " + MsgIdJnlDoc() + "." + FIELD->Line + " : " ;
        + " lost record" ;
      )
    * 20060828 : raus mit folgenden drei Tests, denn das wird doch in
    * VenVnlTest() geprft
    *else
    *  #ifdef DEF_GEN
    *    if FIELD->Code == LNCODE_GEN
    *      if ! GenExist(left(FIELD->IdArt,LenIdGen()))
    *        it_warning( ;
    *          alias() + "-> " + MsgIdJnlDoc() + "." + FIELD->Line + " : " ;
    *          + SetMsg() ;
    *        )
    *      elseif GenCtrExist(GEN->IdGen) .and. ! OnGenCtrExist(GEN->IdGen,VEN->Periode,VEN->IdJnl)
    *        it_warning( ;
    *          alias() + "-> " + MsgIdJnlDoc() + "." + FIELD->Line + " : " ;
    *          + SetMsg() ;
    *        )
    *      elseif GenJnlExist(GEN->IdGen) .and. ! OnGenJnlExist(GEN->IdGen,VEN->Periode,VEN->IdJnl)
    *        it_warning( ;
    *          alias() + "-> " + MsgIdJnlDoc() + "." + FIELD->Line + " : " ;
    *          + SetMsg() ;
    *        )
    *      endif
    *    endif
    *  #endif DEF_GEN
    endif
    * if ! DoEvents(b[AD_ONPOSTEDIT])
    if ! DoEvents(b[AD_ONTEST])
      it_warning(MsgIdJnlDoc() + " : " + SetMsg())
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

*FUNCTION VenMvtTest(cTitle)
*local lOkay     := .f.
*local nCount := 0
*local nMontDoc
*local nDebit
*local nCredit
*local nParMont
*local jnl
*local nMvtCount
*MsgDisplay(scTestTitle)
*open area oVen(), oHst()
*  lOkay := .t.
*  ddSetOrder ORD_HST_DOC in HST
*  go top
*  do while ! eof() .and. LstContinue()
*    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
*    if VEN->Etat == DocStatClosed()
*      if JNLATTR_G $ JnlAttrib(VEN->IdJnl)
*        nDebit  := 0
*        nCredit := 0
*        nParMont := 0
*        nMvtCount := 0
*        select HST
*        softseek VEN->IdJnl + VEN->IdDoc
*        do while ! eof() .and. HST->IdDoc == VEN->IdDoc ;
*                         .and. HST->IdJnl == VEN->IdJnl
*          if ! empty(HST->IdCtr)
*            if HST->DC == VEN->DC
*              nParMont += val(HST->Mont)
*            else
*              nParMont -= val(HST->Mont)
*            endif
*          endif
*          if HST->DC == VEN->DC
*            nDebit  += val(HST->Mont)
*          else
*            nCredit += val(HST->Mont)
*          endif
*          nMvtCount ++
*          skip
*        enddo
*        select VEN
*        if nDebit != nCredit
*          it_warning( ;
*            MsgIdJnlDoc() + MSG_CHECKIT + ;
*            ntrim(nDebit) + " <> " + ntrim(nCredit) ;
*          )
*        elseif ntom(nParMont) != ntom(val(VEN->Mont) * val(VEN->Cours))
*          it_warning( ;
*            MsgIdJnlDoc() + " : Dokumentbetrag widerspricht Partner-Historik !" ;
*          )
*        elseif nMvtCount == 0
*          it_warning( ;
*            MsgIdJnlDoc() + MSG_CHECKIT + ;
*            " keine Buchungen" ;
*          )
*        endif
*      endif
*    else
*      it_warning(MsgIdJnlDoc() + MSG_NOTCLOSED)
*    endif
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    skip
*  enddo
*close area
*RETURN lOkay

FUNCTION utrWider
#ifdef LG_GERMAN
RETURN "widerspricht"
#endif
#ifdef LG_FRENCH
RETURN "en d‚saccord avec"
#endif
#ifdef LG_EN
RETURN "differs from"
#endif

#endif DEF_VEN

#ifdef DEF_FIN

*FUNCTION MsgMont1
*#ifdef LG_GERMAN
*RETURN "Beginnsaldo"
*#endif
*#ifdef LG_FRENCH
*RETURN "solde initial"
*#endif
*#ifdef LG_EN
*RETURN "opening balance"
*#endif

FUNCTION utrHistorik
#ifdef LG_GERMAN
RETURN "Historik"
#endif
#ifdef LG_FRENCH
RETURN "historique"
#endif
#ifdef LG_EN
RETURN "history"
#endif

FUNCTION FinTest() // xlCheckSolde)
local cIdGen
local cPeriode
local cFinPeriode
local cIdDoc
local cIdJnl
local lOkay     := .f.
* local nCount := 0
local nMontDoc
local nMvtCount
local nFnlCount
local nDebit
local nCredit
local nSolde
* local nSoldeDev
local cMont1
local jnl
local aMva := {}
local cIdDev
local nSolde1
* local cOldId := ""
* default xlChecksolde to ".t."
RuptInit()
open area oFin(), oHst(), oFnl(), oGen()
  TestTried()
  lOkay := .t.
  go top
  cIdJnl   := ""
  cIdDoc   := ""
  cPeriode := ""
  do while ! eof() // .and. LstContinue()
    aMva := {}
    if TestInter() ; lOkay := .f. ; exit ; endif
    * MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if FIN->IdJnl == cIdJnl
      if FIN->IdDoc == cIdDoc
        it_warning(MsgIdJnlDoc() + MSG_DUP_REF)
      elseif jnl != NIL .and. JNLATTR_S $ jnl[JNL_ATTRIB] .and. JnlDoHst(jnl,FIN->Periode)
        if FIN->IdDev == cIdDev
          if abs(val(FIN->Mont1)-nSolde1) > DevTolerance(cIdDev)
            it_warning(MsgIdJnlDoc() + " : Beginnsaldo " ;
                                  + ltrim(FIN->Mont1) ;
                                  + " statt " ;
                                  + ltrim(ntom(nSolde1)) ;
            )
          endif
        else
          nSolde1 := val(FIN->Mont1)
          cIdDev := FIN->IdDev
        endif
      endif
    else
      if (jnl := JnlLocate(FIN->IdJnl)) == NIL
        it_warning("FIN-> " + MsgIdJnlDoc() + MsgJnlExist() )
      else
        cPeriode := space(LEN_PERIODE)
        if JnlDoHst(jnl,FIN->Periode) // after 20051102
          cIdDev := FIN->IdDev
          nSolde1 := val(FIN->Mont1)
        else
          nSolde1 := 0
          cIdDev := NIL
        endif
      endif
    endif
    if jnl != NIL .and. JnlDoHst(jnl,FIN->Periode)
      if ! RuptCheck(jnl,FIN->IdDoc,FIN->Periode)
        it_warning(SetMsg())
      endif
      if FIN->Etat != DocStatClosed()
        it_warning(MsgIdJnlDoc() + MSG_NOTCLOSED)
      else
        nDebit  := 0
        nCredit := 0
        nMvtCount := 0
        select HST
        ddSetOrder(ORD_HST_DOC)
        softseek FIN->IdJnl + FIN->IdDoc
        do while ! eof() .and. HST->IdDoc == FIN->IdDoc ;
                         .and. HST->IdJnl == FIN->IdJnl
          if HST->DC == jnl[JNL_DC]
            nDebit  += val(HST->Mont)
          else
            nCredit += val(HST->Mont)
          endif
          nMvtCount ++
          skip
        enddo
        nMontDoc := val(FIN->Mont1)
        nFnlCount := 0
        select FNL
        softseek FIN->IdJnl + FIN->IdDoc
        do while ! eof() .and. FNL->IdDoc == FIN->IdDoc ;
                         .and. FNL->IdJnl == FIN->IdJnl
          * if jnl[JNL_IDDEV] == DevDefault(FIN->Periode)
          if FIN->IdDev == DevDefault(FIN->Periode)
            if FNL->DC == jnl[JNL_DC]
              nMontDoc -= val(FNL->Mont)
            else
              nMontDoc += val(FNL->Mont)
            endif
          else
            if FNL->DC == jnl[JNL_DC]
              nMontDoc -= val(FNL->MontDev)
            else
              nMontDoc += val(FNL->MontDev)
            endif
          endif
          nFnlCount ++
          #ifdef DEF_ANAFIN
            if ! empty(FnlIdAna()) // empty(FNL->IdAna)
              if empty(FNL->IdCtr)
                cIdGen := left(FNL->IdCpt,LenIdGen())
              else
                cIdGen := CtrIdGen(FNL->IdCtr)
              endif
              aCollect(aMva, { ;
                cIdGen, ;
                val(FNL->Mont)*if(FNL->DC==jnl[JNL_DC],1,-1) ;
              } )
            endif
          #endif DEF_ANAFIN
          skip
        enddo
        select FIN
        if abs(nDebit - nCredit) > DevTolerance(cIdDev)
          it_warning( ;
            MsgIdJnlDoc() + ;
            + " : Debit (" ;
            + ntrim(nDebit) ;
            + ") "+utrWider()+" Kredit (" ;
            + ntrim(nCredit) ;
            + ") !" ;
          )
        endif
        if nMvtCount == 0
          if nFnlCount != 0
            it_warning( ;
              MsgIdJnlDoc() + " keine Buchungen !" ;
            )
          endif
        endif
        if JNLATTR_S $ jnl[JNL_ATTRIB]
          if abs(nMontDoc - val(FIN->Mont2)) > DevTolerance(FIN->IdDev)
            it_warning( ;
              MsgIdJnlDoc() + ;
              " : Endsaldo "  + ltrim(FIN->Mont2) + ;
              " statt " + ntrim(nMontDoc) ;
            )
          endif
          nSolde1 := nMontDoc
        endif
        #ifdef DEF_MVA
        #ifdef DEF_ANAFIN
          if ! DocMvaTest(FIN->IdJnl,FIN->IdDoc,aMva,jnl[JNL_DC],FIN->Periode)
            it_warning(MsgIdJnlDoc() + " : " + SetMsg())
          endif
        #endif DEF_ANAFIN
        #endif DEF_MVA
      endif
      if CheckFinSolde()
        if FIN->Periode > cPeriode
          if ! empty(jnl[JNL_IDGEN])
            if JNLATTR_S $ jnl[JNL_ATTRIB]
              cIdDev := FIN->IdDev
              * GenSolde(FIN->Periode,...)
              cFinPeriode := FIN->Periode
              nSolde := 0
              // nSoldeDev := 0
              open area oHst(), oFin(), oVen()
                ddSetOrder(ORD_HST_GENDATE)
                softseek jnl[JNL_IDGEN] + trim(PerStart(cFinPeriode))
                do while ! eof() .and. HST->IdGen == jnl[JNL_IDGEN] ;
                                 .and. HST->Periode < cFinPeriode
                  if HST->DC == jnl[JNL_DC]
                    nSolde    += HstMont(cIdDev)
                  else
                    nSolde    -= HstMont(cIdDev)
                  endif
                  skip
                enddo
              close area
              cMont1 := ntom(nSolde,DevDecPos(cIdDev))
              * if FIN->IdDev == DevDefault(FIN->Periode)
              *   cMont1 := ntom(nSolde,DevDecPos(FIN->IdDev))
              * else
              *   cMont1 := ntom(nSoldeDev,DevDecPos(FIN->IdDev))
              * endif
              if abs(val(FIN->Mont1)) - abs(val(cMont1)) > FinTolerance()
                it_warning( ;
                  MsgIdJnlDoc() ;
                  + " : " + MsgSoldeI(UsrLang()) + " (" ;
                  + ltrim(FIN->Mont1) ;
                  + ") " + utrWider() + " " + utrHistorik() + " (" ;
                  + ltrim(cMont1) ;
                  +") !" ;
                )
                it_warning( ;
                  space(len(MsgIdJnlDoc())+3) ;
                  + "(" ;
                  + jnl[JNL_IDGEN] ;
                  + utr(" starts in "," beginnt in ", " commence en ") ;
                  + cFinPeriode ;
                  + utr(" with "," mit "," avec ") ;
                  + ltrim(cMont1) ;
                  + " " + cIdDev ;
                  + " (Differenz = " ;
                  + ltrim(ntom(val(cMont1)-val(FIN->Mont1),DevDecPos(cIdDev))) ;
                  + ")" ;
                )
              endif
            endif
          endif
        elseif FIN->Periode < cPeriode
          if JNLATTR_F $ jnl[JNL_ATTRIB]
            it_warning( ;
              MsgIdJnlDoc() + " : Buchungsperiode „lter als im Dokument davor !" ;
            )
          endif
        endif
      endif // CheckFinSolde()
    endif // jnl != NIL
    * if TaskInter() ; lOkay := .f. ; exit ; endif
    cPeriode := FIN->Periode
    cIdJnl   := FIN->IdJnl
    cIdDoc   := FIN->IdDoc
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

FUNCTION FnlTest()
local lOkay  := .f.
* local nCount := 0
open area oFnl(), oFin(), oGen()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    * MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    seek FNL->IdJnl + FNL->IdDoc in FIN
    if eof() in FIN
      it_warning( "FNL-> " + MsgIdJnlDoc() + " : lost record" )
    elseif empty(FNL->IdCtr) // == CPTTYPE_GEN
      if ! GenExist(left(FNL->IdCpt,LenIdGen()))
        it_warning( "FNL-> " + MsgIdJnlDoc() + "." + FNL->Line + " : " + SetMsg())
      elseif GenCtrExist(GEN->IdGen) .and. ! OnGenCtrExist(GEN->IdGen,FIN->Periode,FIN->IdJnl)
        it_warning( "FNL-> " + MsgIdJnlDoc() + "." + FNL->Line + " : " + SetMsg())
      elseif GenJnlExist(GEN->IdGen) .and. ! OnGenJnlExist(GEN->IdGen,FIN->Periode,FIN->IdJnl)
        it_warning( "FNL-> " + MsgIdJnlDoc() + "." + FNL->Line + " : " + SetMsg())
      endif
    endif
    skip
    * if TaskInter() ; lOkay := .f. ; exit ; endif
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_FIN







#ifdef DEF_IMP

**
**
**
FUNCTION MviTest(xlFilter)
local lOkay := .f.
* local nCount := 0
local cPeriode
local cIdPar
local jnl
local aWrn := ReadArray("MVI.WRN",WRN_ALEN)
default xlFilter to ".t."
open area oMvi(), oPar(), oBud(), oImp(), oIml()
  TestTried()
  lOkay := .t.
  ddSetOrder(ORD_MVI_PARMATCH)
  go top
  cPeriode  := MVI->Periode
  // cIdPar    := MVI->IdPar + MVI->Match
  cIdPar    := MVI->Match
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    * MsgDisp2(ntrim0(++nCount * 50 / lastrec()) + "%" )
    if &xlFilter
      if (jnl := JnlLocate(MVI->IdJnl)) == NIL
        it_warning("MVI-> " + MsgIdJnlDoc() + MsgJnlExist())
        * nErrors++
      elseif ! ParExist(MVI->IdPar)
        it_warning("MVI-> " + MsgIdJnlDoc() + " : " + SetMsg() )
        * nErrors++
      elseif ! ParExist(MVI->IdPar2)
        it_warning("MVI-> " + MsgIdJnlDoc() + " : " + SetMsg() )
        * nErrors++
      elseif ! BudExist(MVI->DC,MVI->IdBud)
        it_warning("MVI-> " + MsgIdJnlDoc() + " : " + SetMsg() )
        * nErrors++
      elseif ! PerExist(MVI->Periode,MVI->IdJnl)
        it_warning("MVI-> " + MsgIdJnlDoc() + " : " + MVI->Periode + " : unbekannte Periode" )
        * nErrors++
      elseif MVI->Mont != ntom(val(MVI->Mont),DevDecPos(DevDefault(MVI->Periode)))
        it_warning("MVI-> " + MsgIdJnlDoc() + "." + MVI->Line ;
          + ' : strange value "' + MVI->Mont + '"')
        * nErrors++
      else
        seek MVI->IdJnl + MVI->IdDoc in IMP
        if eof() in IMP
          it_warning("MVI-> " + MsgIdJnlDoc() + " : unbekanntes Dokument" )
        else
          seek MVI->IdJnl + MVI->IdDoc + MVI->Line in IML
          if eof() in IML
            it_warning("MVI-> " + MsgIdJnlDoc() + MVI->Line + " : ohne IML-Record" )
          elseif IML->Mont != MVI->Mont
            it_warning(MsgIdJnlDoc() + MVI->Line + " : MVI->Mont != IML->Mont" )
          elseif IML->IdPar != MVI->IdPar
            it_warning(MsgIdJnlDoc() + MVI->Line + " : MVI->IdPar != IML->IdPar" )
          elseif empty(IML->IdPar2)
            if MVI->IdPar2 != IML->IdPar
              it_warning(MsgIdJnlDoc() + MVI->Line + " : MVI->IdPar2 != IML->IdPar" )
            endif
          elseif IML->IdPar2 != MVI->IdPar2
            it_warning(MsgIdJnlDoc() + MVI->Line + " : MVI->IdPar2 != IML->IdPar2" )
          elseif IML->IdBud != MVI->IdBud
            it_warning(MsgIdJnlDoc() + MVI->Line + " : MVI->IdBud != IML->IdBud" )
          else
            WrnExec(aWrn)
          endif
        endif
      endif
      if MVI->Match == cIdPar
        if left(cPeriode,LEN_YEAR) != left(MVI->Periode,LEN_YEAR)
          it_warning(MVI->IdPar + " " + MsgIdJnlDoc() + " " + MVI->Line + " : verschiedene Rechnungsjahre")
        endif
      else
        cPeriode  := MVI->Periode
        cIdPar    := MVI->Match
      endif
    endif
    * if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
  * if lOkay ; MsgShouldRebuild(scTestTitle,nCount) ; endif
  if lOkay ; TestOkay() ; endif
close area
* RETURN .f. if ! lOkay
RETURN lOkay

FUNCTION MviDupTest(xlFilter)
local lOkay := .f.
local cId
default xlFilter to ".t."
open area oMvi()
  TestTried()
  lOkay := .t.
  ddSetOrder(ORD_MVI_ID)
  go top
  cId := NIL
  do while ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    * MsgDisp2(ntrim0(++nCount * 50 / lastrec()) + "%" )
    if &xlFilter
      if cId == MVI->IdJnl + MVI->IdDoc + MVI->Line
        it_warning("MVI:"+ntrim(recno()) + ":" + MsgIdJnlDoc() + " : duplicate id")
      else
        cId := MVI->IdJnl + MVI->IdDoc + MVI->Line
      endif
    endif
    * if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

FUNCTION ImpImlTest(xlFilter)
local lOkay := .f.
* local nCount := 0
local jnl
local aWrn := ReadArray("IMPIML.WRN",WRN_ALEN)
default xlFilter to ".t."
SetDialog(.f.)
open area oImp(), oIml(), oMvi()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    * MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if &xlFilter
      if (jnl := JnlLocate(IMP->IdJnl)) == NIL
        it_warning("IMP-> " + MsgIdJnlDoc() + MsgJnlExist())
      elseif ! PerExist(IMP->Periode,IMP->IdJnl)
        it_warning("IMP-> " + MsgIdJnlDoc() + " : " + IMP->Periode + " : unbekannte Periode" )
      elseif IMP->Etat != DocStatClosed()
        it_warning("IMP-> " + MsgIdJnlDoc() + " : nicht registriert" )
      elseif ! ImpPreClose(jnl,{},{},{},{})
        it_warning("IMP-> " + MsgIdJnlDoc() + " : " + SetMsg())
        * it_warning("IMP-> " + MsgIdJnlDoc() + " : ImpPreClose() failed" )
      elseif ! ImpTestMont2(jnl)
        it_warning("IMP-> " + MsgIdJnlDoc() + " : " + SetMsg())
      else
        WrnExec(aWrn)
      endif
    endif
    * if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
SetDialog(.t.)
* ErrorReport(cLine,lOkay,nWarnings,nDelete,nErrors)
RETURN lOkay


FUNCTION ImlTest(xlFilter)
local lOkay := .f.
* local nCount := 0
default xlFilter to ".t."
open area oIml(), oImp(), oMvi()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    * MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    seek IML->IdJnl+IML->IdDoc in IMP
    if eof() in IMP
      it_warning("IML-> " + MsgIdJnlDoc() + "." + IML->Line ;
        + " : no IMP record")
    elseif &xlFilter
      if IMP->Etat==DocStatClosed()
        seek IML->IdJnl+IML->IdDoc+IML->Line in MVI
        if eof() in MVI
          it_warning("IML-> " + MsgIdJnlDoc() + "." + IML->Line ;
            + " : no MVI record")
        endif
      endif
    endif
    * if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

**
**
**
FUNCTION MviCtbTest(xlMviFilter)
local lOkay := .f.
local a
local ai
local nMontUs
local aMontUs
local aiMontUs
local i,j
local jnl
local cDC
local cIdBud
* local nCount := 0
default xlMviFilter to ".t."
* local nMontCtb
open area oMvi(), oCtb()
  TestTried()
  lOkay := .t.
  ddSetOrder(ORD_MVI_BUDDATE)
  go top
  do while lOkay .and. ! eof()
    cDC    := MVI->DC
    cIdBud := MVI->IdBud
    * nMontCtb := 0
    a := {}
    aMontUs := {}
    do while lOkay .and. MVI->IdBud == cIdBud ;
                   .and. MVI->DC == cDC .and. ! eof()
      if TestInter() ; lOkay := .f. ; exit ; endif
      * MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
      if &xlMviFilter
        if (jnl := JnlLocate(MVI->IdJnl)) != NIL
          if jnl[JNL_IDCDC] != "00"
            if ! empty(MVI->MontCtb)
              ai := NIL
              for i := 1 to len(a)
                if a[i][1] == jnl[JNL_IDCDC]
                  if a[i][2] == PerPerCtr(MVI->Periode)
                    ai := a[i]
                    exit
                  endif
                endif
              next i
              if ai == NIL
                ai := array(3)
                ai[1] := jnl[JNL_IDCDC]
                ai[2] := PerPerCtr(MVI->Periode)
                ai[3] := 0
                aadd(a, ai)
              endif
              if JNLATTR_N $ jnl[JNL_ATTRIB]
                ai[3]          -= val(MVI->MontCtb)
              else
                ai[3]          += val(MVI->MontCtb)
              endif
            endif
          endif
          if jnl[JNL_IDCDC] == "02"
            aiMontUs := NIL
            for j := 1 to len(aMontUs)
              if aMontUs[j][1] == PerPerCtr(MVI->Periode)
                aiMontUs := aMontUs[j]
              endif
            next j
            if aiMontUs == NIL
              aiMontUs := array(2)
              aiMontUs[1] := PerPerCtr(MVI->Periode)
              aiMontUs[2] := 0 // Summe aus MVI->MontUs
              // aiMontUs[3] := 0 // (02 - 03) aus CTB
              aadd(aMontUs,aiMontUs)
            endif
            if JNLATTR_N $ jnl[JNL_ATTRIB]
              aiMontUs[2]  -= val(MVI->MontUs)
            else
              aiMontUs[2]  += val(MVI->MontUs)
            endif
          endif
        endif
      endif
      * if TaskInter() ; lOkay := .f. ; exit ; endif
      skip
    enddo
    if lOkay
      TestOkay()
      for i := 1 to len(a)
        *if a[i][1] == "02"
        *  for j := 1 to len(aMontUs)
        *    if aMontUs[j][1] == a[i][2] // RJ
        *      aMontUs[j][3] += a[i][3]
        *    endif
        *  next j
        *endif
        *if a[i][1] == "03"
        *  for j := 1 to len(aMontUs)
        *    if aMontUs[j][1] == a[i][2] // RJ
        *      aMontUs[j][3] -= a[i][3]
        *    endif
        *  next j
        *endif
        seek cDC + cIdBud + a[i][2] + a[i][1] in CTB
        if eof() in CTB
          it_warning( ;
            cDC + "-" + trim(SayIdBud(cIdBud)) ;
            + " " + a[i][2] + " " + a[i][1] ;
            + " : eof() in CTB !" ;
          )
        elseif abs(val(CTB->Mont)-a[i][3]) > Tolerance(SetDecPos())
          it_warning( ;
            cDC + "-" + trim(SayIdBud(cIdBud)) ;
            + " " + CTB->Periode + " " + CTB->IdCdc ;
            + " : " + ltrim(CTB->Mont) + " (CTB->Mont) != " ;
            + ntrim(a[i][3]) + " (ä MVI->MontCtb)" ;
          )
        endif
      next i
      for j := 1 to len(aMontUs)
        seek cDC + cIdBud + aMontUs[j][1] + "02" in CTB
        nMontUs := val(CTB->Mont)
        seek cDC + cIdBud + aMontUs[j][1] + "03" in CTB
        nMontUs -= val(CTB->Mont)
        seek cDC + cIdBud + aMontUs[j][1] + "04" in CTB
        nMontUs += val(CTB->Mont)
        seek cDC + cIdBud + aMontUs[j][1] + "05" in CTB
        nMontUs -= val(CTB->Mont)
        if abs(aMontUs[j][2] - nMontUs) > Tolerance(SetDecPos())
          it_warning( ;
            cDC + "-" + trim(SayIdBud(cIdBud)) ;
            + " " + aMontUs[j][1] ;
            + " : offene MVI 02 != CTB (02 -03 +04 -05) : " ;
            + ntrim(aMontUs[j][2]) ;
            + " != " + ntrim(nMontUs) ;
          )
        endif
      next j
    endif
  enddo
close area
RETURN lOkay

*FUNCTION c970321(cIdJnl)
*open area oImp(), oIml()
*  softseek cIdJnl
*  do while ! eof() .and. IMP->IdJnl == cIdJnl
*    if empty(IMP->IdPar)
*      if ddRecLock()
*        softseek cIdJnl + IMP->IdDoc in IML
*        if IML->IdDoc == IMP->IdDoc .and. IML->IdJnl == cIdJnl
*          SendConsole(MsgIdJnlDoc() + " : IMP->IdPar := " + IML->IdPar)
*          IMP->IdPar := IML->IdPar
*        endif
*        unlock record
*      endif
*    endif
*    skip
*  enddo
*close area
*RETURN MnuDone()

**
**
**
FUNCTION CtbBudTest(xlFilter)
local lOkay := .f.
local cDC
local cIdBud
local cYear
local nMont02
local nMont03
* local nCount := 0
local lDoTest
* local nMontCtb
default xlFilter to ".t."
open area oCtb()
  TestTried()
  lOkay := .t.
  ddSetOrder(ORD_CTB_BUD)
  go top
  do while ! eof() .and. LstContinue()
    cDC    := CTB->DC
    cIdBud := CTB->IdBud
    cYear  := CTB->Periode
    nMont02 := 0
    nMont03 := 0
    lDoTest := .t.
    do while CTB->Periode == cYear ;
             .and. CTB->IdBud == cIdBud .and. CTB->DC == cDC ;
             .and. ! eof() ;
             .and. LstContinue()
      if TestInter() ; lOkay := .f. ; exit ; endif
      * MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
      if &xlFilter
        if CTB->IdCdc == "02"
          nMont02 += val(CTB->Mont)
        elseif CTB->IdCdc == "03"
          nMont03 += val(CTB->Mont)
        endif
      else
        lDoTest := .f.
      endif
      * if TaskInter() ; lOkay := .f. ; LstError(PRN_ABORT) ; endif
      skip
    enddo
    if lDoTest .and. nMont03 > nMont02
      it_warning( ;
        cDC + "-" + trim(SayIdBud(cIdBud)) ;
        + " " + cYear ;
        + " : " + ntrim(nMont03) + " (ä 03) - " ;
        + ntrim(nMont02) + " (ä 02) = " + ntrim(nMont03-nMont02) ;
      )
    endif
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_IMP

#ifdef DEF_TRA

FUNCTION TraTest()
local lOkay := .f.
* local nCount := 0
open area oTra()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    * MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if TRA->Etat != TRASTAT_CLOSED
      it_warning("TRA " + TRA->IdDoc + " : nicht registriert" )
    endif
    * if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_TRA


#ifdef DEF_LNK

FUNCTION LniTest()
local lOkay := .f.
* local nCount := 0
open area oLni(), oLnk()
  TestTried()
  lOkay := .t.
  go top
  do while ! eof() // .and. LstContinue()
    if TestInter() ; lOkay := .f. ; exit ; endif
    * MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    select LNK
    seek LNI->IdLnk
    if eof()
      if dbAddRec()
        LNK->IdLnk := LNI->IdLnk
        unlock record
        it_warning(LNI->IdLnk + " : LNK created")
      else
        it_warning(LNI->IdLnk + " : LNK create failed")
      endif
    endif
    select LNI
    * if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

#endif DEF_LNK

#ifdef DEF_TAX

*FUNCTION TaxTest(cTitle)
*local i
*local lOkay := .f.
*MsgDisplay(scTestTitle)
*open area oTax(), oGen()
*  lOkay := .t.
*  go top
*  do while ! eof()
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    #ifdef DEF_GEN
*      if ! GenIsHidden(TAX->IdGen)
*        it_warning("TAX->" + TAX->IdCtr + "-" + TAX->IdTax + " : " + SetMsg())
*      endif
*      if ! GenIsHidden(TAX->GenTiers)
*        it_warning("TAX->" + TAX->IdCtr + "-" + TAX->IdTax + " : " + SetMsg())
*      endif
*    #endif DEF_GEN
*    skip
*  enddo
*close area
*RETURN lOkay

#endif DEF_TAX

*#ifdef DEF_JNL
*
*FUNCTION JnlTest(a)
*local i
*local lOkay := .f.
*MsgDisplay(a[TST_NAME])
*open area oJnl()
*  lOkay := .t.
*  go top
*  do while ! eof()
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    #ifdef DEF_FIN
*      if JNL->Alias == JNLALIAS_FIN
*        if JNLATTR_S $ JNL->Attrib
*          if ! JnlFinTest(JNL->IdJnl,JNL->IdGen,JNL->DC,JNL->IdDev)
*            lOkay := .f.
*            exit
*          endif
*        endif
*      endif
*    #endif DEF_FIN
*    skip
*  enddo
*close area
*RETURN lOkay
*
*
*#endif DEF_JNL
*
*#ifdef DEF_FIN
*
*FUNCTION JnlFinTest(cIdJnl,cIdGen,cDC,cIdDev)
*local lOkay := .t.
*local cPeriode := NIL
*local nSolde   := 0
*local xnMont := "val(HST->Mont)"
*if cIdDev != DevDefault()
*  xnMont := "val(HST->MontDev)"
*else
*endif
*open area oHst(), oFin()
*  ddSetOrder ORD_HST_GENDATE
*  softseek cIdJnl in FIN
*  softseek cIdGen
*  do while lOkay .and. ! eof() .and. HST->IdGen == cIdGen
*    nSolde := 0
*    cPeriode := HST->Periode
*    do while HST->Periode == cPeriode .and. lOkay .and. ! eof() ;
*             .and. HST->IdGen == cIdGen
*      if TaskInter() ; lOkay := .f. ; exit ; endif
*      if HST->DC == cDC
*        nSolde += &xnMont
*      else
*        nSolde -= &xnMont
*      endif
*      skip
*    enddo
*    select FIN
*    do while lOkay .and. FIN->Periode <= cPeriode ;
*                   .and. ! eof() ;
*                   .and. FIN->IdJnl == cIdJnl
*      skip
*    enddo
*    if FIN->IdJnl == cIdJnl .and. lOkay .and. ! eof() ;
*                            .and. FIN->Periode > cPeriode
*      if val(FIN->Mont1) != nSolde
*        it_warning( ;
*          cIdGen + " : Endsaldo Periode " + cPeriode ;
*          + " widerspricht Beginnsaldo in " + MsgIdJnlDoc() ;
*        )
*      endif
*    endif
*    select HST
*  enddo
*close area
*RETURN lOkay
*
*#endif DEF_FIN




FUNCTION WrnExec(aWrn)
local i
for i := 1 to len(aWrn)
  * if aWrn[i][WRN_ALIAS] == cAlias
    if &(aWrn[i][WRN_TEST])
      it_warning(&(aWrn[i][WRN_MSG]))
    endif
  * endif
next i
RETURN NIL


**
** Rebuild()
**
FUNCTION Rebuild(lDlg,cTplIni,cPreview)
local cCtsRebuild := BUTTON_ON
local cLettre     := BUTTON_ON
local cCtp := BUTTON_ON
local cCtt := BUTTON_ON
local cCtgRebuild := BUTTON_ON
local cCtaRebuild := BUTTON_ON
local nHeight := 10
local lOkay := .t.
default lDlg to .t.
default cTplIni to "LISTE"
default cPreview to BUTTON_ON
SetTplIni(cTplIni)
SetPreview(cPreview)
if lDlg
  #ifdef DEF_ANA
    nHeight++
  #endif DEF_ANA
  open window (MsgRebuild) size nHeight,60 help REBUILD
  #ifdef DEF_HST
    @ row(), col() get cLettre checkbox
    say " " + MSG092
    WinCr()
  #endif DEF_HST
  #ifdef DEF_CTS
    @ row(), col() get cCtsRebuild checkbox
    say " " + MSG_CTS
    WinCr()
  #endif DEF_CTS
  #ifdef DEF_MVA
    @ row(), col() get cCtaRebuild checkbox
    say " " + MSG_CTA
    WinCr()
  #endif DEF_MVA
  #ifdef DEF_CTP
    @ row(), col() get cCtp checkbox
    say " " + MSG_CTP
    WinCr()
  #endif DEF_CTP
  #ifdef DEF_CTT
    @ row(), col() get cCtt checkbox
    say " " + MSG085
    WinCr()
  #endif DEF_CTT
  #ifdef DEF_CTG
    @ row(), col() get cCtgRebuild checkbox
    say " " + MSG_CTGEDIT
    WinCr()
  #endif DEF_CTG
  say MsgLstCtrl()
  WinCr()
  GetPreview() ; WinCr()
  GetTplIni()
  nKey := ReadScr()
  close window
  RETURN .f. if nKey == K_ESC
endif
* open printer SetTplIni() width 76 ;
*              preview SetPreview() ;
*              TitBlock {|| PrintHeader(MsgRebuild) }
* if ! LstContinue()
*   close printer
*   RETURN .f.
* endif
SetKeepReport(.t.)
snErrCount := 0
#ifdef DEF_HST
  if cLettre == BUTTON_ON
    MsgDisplay(MSG092 + "...")
    rpt_write(MSG092 + "...")
    if HstSatisfy()
      rpt_write(MSG092 + MsgDone())
    else
      lOkay := .f.
      rpt_write(MSG092 + MsgFailed())
    endif
  endif
#endif DEF_HST
#ifdef DEF_CTS
  if cCtsRebuild == BUTTON_ON
    rpt_write(MSG_CTS + "...")
    MsgDisplay(MSG_CTS + "...")
    if CtsRebuild()
      rpt_write(MSG_CTS + MsgDone())
    else
      lOkay := .f.
      rpt_write(MSG_CTS + MsgFailed())
    endif
  endif
#endif DEF_CTS
#ifdef DEF_MVA
  if cCtaRebuild == BUTTON_ON
    MsgDisplay(MSG_CTA + "...")
    rpt_write(MSG_CTA + "...")
    if CtaRebuild()
      rpt_write(MSG_CTA + MsgDone())
    else
      lOkay := .f.
      rpt_write(MSG_CTA + MsgFailed())
    endif
  endif
#endif DEF_MVA
#ifdef DEF_CTP
  if cCtp == BUTTON_ON
    MsgDisplay(MSG_CTP + "...")
    rpt_write(MSG_CTP + "...")
    if CtpRebuild()
      rpt_write(MSG_CTP + MsgDone())
    else
      lOkay := .f.
      rpt_write(MSG_CTP + MsgFailed())
    endif
  endif
#endif DEF_CTP
#ifdef DEF_CTT
  if ! empty(cCtt)
    MsgDisplay(MSG085 + "...")
    rpt_write(MSG085 + "...")
    if CttRebuild(cCtp)
      rpt_write(MSG085 + MsgDone())
    else
      lOkay := .f.
      rpt_write(MSG085 + MsgFailed())
    endif
  endif
#endif DEF_CTT
#ifdef DEF_CTG
  if cCtgRebuild == BUTTON_ON
    MsgDisplay(MSG_CTGEDIT + "...")
    rpt_write(MSG_CTGEDIT + "...")
    if CtgRebuild()
      rpt_write(MSG_CTGEDIT + MsgDone())
    else
      lOkay := .f.
      rpt_write(MSG_CTGEDIT + MsgFailed())
    endif
  endif
#endif DEF_CTG
* ClosePrinter(.t.)
ddCloseAll()
if ! lOkay
  Warning(MsgRebuild + MsgFailed(), SetMsg())
  IndCreate("REBUILD",MsgRebuild + MsgFailed())
  RETURN .f.
endif
if snErrCount != 0
  Warning( ;
    MsgRebuild + MsgErrorsFound(snErrCount), ;
    MsgLookRpt() ;
  )
  IndCreate("REBUILD",MsgRebuild + MsgErrorsFound(snErrCount))
  RETURN .f.
endif
IndDelete("REBUILD")
RETURN .t.



#ifdef LG_GERMAN
FUNCTION MsgErrorsFound(nCount) ; RETURN " : " + ntrim(nCount) + " Fehler sind aufgetreten."
FUNCTION MsgFailed  ; RETURN " : Vorgang schlug fehl."
FUNCTION MsgAbort   ; RETURN "Vorgang wurde unterbrochen."
FUNCTION MsgDone    ; RETURN " : Vorgang beendet."
FUNCTION MsgLstCtrl ; RETURN "Kontrollliste :"
#endif

#ifdef LG_FRENCH
FUNCTION MsgErrorsFound(nCount) ; RETURN " : Il y a eu " + ntrim(nCount) + " erreurs."
FUNCTION MsgFailed  ; RETURN " : le traitement a ‚chou‚."
FUNCTION MsgAbort   ; RETURN " : le traitement a ‚t‚ interrompu."
FUNCTION MsgDone    ; RETURN " : traitement termin‚."
FUNCTION MsgLstCtrl ; RETURN "Liste de contr“le :"
#endif

#ifdef LG_EN
FUNCTION MsgErrorsFound(nCount) ; RETURN " : There were " + ntrim(nCount) + " errors."
FUNCTION MsgFailed  ; RETURN " : failed."
FUNCTION MsgAbort   ; RETURN " : has been aborted."
FUNCTION MsgDone    ; RETURN " : done."
FUNCTION MsgLstCtrl ; RETURN "Report :"
#endif

#ifdef DEF_MVS

**
** MvsRebuild()
**
STATIC FUNCTION MvsRebuild(cIdJnl)
local jnl
local i
local nDocCount := 0
local nErrCount := 0
local lOkay := .f.
local nCount := 0
ddCloseAll()
open area oMvs()
  lOkay := .t.
  go top
  nCount := 0
  do while ! eof()
    if TaskInter() ; lOkay := .f. ; exit ; endif
    MsgDisp2("MVS " + ntrim0(100 * nCount++ / lastrec()) + "%")
    if empty(cIdJnl) .or. MVS->IdJnl $ cIdJnl
      * if MVS->Periode > MemMvsPeriode
        if ChkPeriode(MVS->Periode) == 0
          if ddRecLock()
            delete
            unlock record
          endif
        endif
      * endif
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
ddCloseAll()
RETURN .f. if ! ddConvertDbf(oMvs())
RETURN .f. if ! ddIndex(oMvs())
lOkay := .f.
open area oArt(), oGen(), oPar()
  #ifdef DEF_VEN
    * 19980724 open area oVen(), oVnl() exclusive
    open area oVen() exclusive
      nCount := 0
      lOkay := .t.
      go top
      do while ! eof() .and. lOkay // LstContinue()
        MsgDisp2("VEN " + ntrim0(100 * nCount++ / lastrec()) + "%")
        if VEN->Etat == DocStatClosed()
          if empty(cIdJnl) .or. VEN->IdJnl $ cIdJnl
            if ChkPeriode(VEN->Periode) == 0
              * if VEN->Periode > MemMvsPeriode
                if (jnl := JnlLocate(VEN->IdJnl)) == NIL
                  rpt_write(MsgIdJnlDoc() + MsgJnlExist())
                elseif JNLATTR_S $ jnl[JNL_ATTRIB]
                  SetMsg(MSG010)
                  if ! VenMvsRebuild(jnl)
                    rpt_write(MsgIdJnlDoc() + " : " + SetMsg())
                    nErrCount++
                  endif
                  nDocCount++
                endif
              * endif
            endif
          endif
        endif
        if TaskInter() ; lOkay := .f. ; exit ; endif
        skip
      enddo
    close area
    ddCloseAll()
  #endif DEF_VEN
  #ifdef DEF_ODS
    open area oOds(), oOdl() exclusive
      nCount := 0
      lOkay := .t.
      go top
      do while ! eof() .and. lOkay // LstContinue()
        MsgDisp2("ODS " + ntrim0(100 * nCount++ / lastrec()) + "%")
        if ODS->Etat == DocStatClosed()
          if empty(cIdJnl) .or. ODS->IdJnl $ cIdJnl
            * if ODS->Periode > MemMvsPeriode
              if ChkPeriode(ODS->Periode) == 0
                if (jnl := JnlLocate(ODS->IdJnl)) == NIL
                  rpt_write(MsgIdJnlDoc() + MsgJnlExist())
                elseif JNLATTR_S $ jnl[JNL_ATTRIB]
                  SetMsg(MSG010)
                  if ! OdsMvsRebuild(jnl)
                    rpt_write(MsgIdJnlDoc() + " : " + SetMsg())
                    nErrCount++
                  endif
                  nDocCount++
                endif
              endif
            * endif
          endif
        endif
        if TaskInter() ; lOkay := .f. ; exit ; endif
        skip
      enddo
    close area
    ddCloseAll()
  #endif DEF_ODS
close area
rpt_write(ntrim(nDocCount) + MSG094 + ntrim(nErrCount) + MSG099 )
snErrCount += nErrCount
ddCloseAll()
RETURN lOkay // LstContinue()

#endif DEF_MVS

#ifdef DEF_CTS

**
** CtsRebuild()
**
FUNCTION CtsRebuild
local jnl
local nDocCount := 0
local nErrCount := 0
local lOK := .f.
local nCount := 0
ddCloseAll()
#ifdef DEF_ARC
  open area oCts(), oJnl()
    lOk := .t.
    ddSetOrder()
    go top
    do while ! eof()
      MsgDisp2("(1) "+ntrim0(100 * nCount++ / lastrec()) + "%")
      if TaskInter() ; lOk := .f. ; exit ; endif
      seek CTS->IdJnl in JNL
      if CTS->Periode > JNL->ArcPeriode
        if ddRecLock()
          delete
          unlock record
        else
          lOK := .f.
          exit
        endif
      endif
      skip
    enddo
  close area
#else
  open area oCts() exclusive
    lOk := .t.
    zap
  close area
#endif
RETURN .f. if ! lOk
ddCloseAll()
lOK := .f.
nCount := 0
open area oArt(), oGen(), oPar()
  #ifdef DEF_VEN
    open area oVen() exclusive
      nCount := 0
      lOk := .t.
      go top
      do while ! eof() .and. lOk // LstContinue()
        MsgDisp2("(2) "+ntrim0(100 * nCount++ / lastrec()) + "%")
        if VEN->Etat == DocStatClosed()
          if (jnl := JnlLocate(VEN->IdJnl)) == NIL
            rpt_write(MsgIdJnlDoc() + MsgJnlExist())
          elseif JNLATTR_M $ jnl[JNL_ATTRIB]
            if ! VenCtsRebuild(jnl)
              rpt_write(MsgIdJnlDoc() + " : " + SetMsg())
              nErrCount++
            endif
            nDocCount++
          endif
        endif
        if TaskInter() ; lOk := .f. ; exit ; endif
        skip
      enddo
    close area
    ddCloseAll()
  #endif DEF_VEN
  #ifdef DEF_ODS
    open area oOds(), oOdl() exclusive
      nCount := 0
      lOk := .t.
      go top
      do while ! eof() .and. lOk
        MsgDisp2("(3) "+ntrim0(100 * nCount++ / lastrec()) + "%")
        if ODS->Etat == DocStatClosed()
          if (jnl := JnlLocate(ODS->IdJnl)) == NIL
            rpt_write(MsgIdJnlDoc() + MsgJnlExist())
          elseif JNLATTR_M $ jnl[JNL_ATTRIB]
            * SetMsg(MSG010)
            if ! OdsCtsRebuild(jnl)
              rpt_write(MsgIdJnlDoc() + " : " + SetMsg())
              nErrCount++
            endif
            nDocCount++
          endif
        endif
        if TaskInter() ; lOk := .f. ; exit ; endif
        skip
      enddo
    close area
    ddCloseAll()
  #endif DEF_ODS
close area
rpt_write(ntrim(nDocCount) + MSG094 + ntrim(nErrCount) + MSG099 )
snErrCount += nErrCount
ddCloseAll()
RETURN lOk

#endif DEF_CTS

#ifdef DEF_HST

**
** HstSatisfy() - V‚rification des lettrages...
**
FUNCTION HstSatisfy(dDate)
local lOkay := .t.
open area oPar()
  go top
  do while lOkay .and. ! eof()
    lOkay := ParSatisfy(PAR->IdPar,dDate)
    skip
  enddo
close area
RETURN .f. if ! lOkay
#ifdef DEF_GEN
  open area oGen()
    go top
    do while lOkay .and. ! eof()
      if GENATTR_L $ GEN->Attrib
        lOkay := GenSatisfy(GEN->IdGen,dDate)
      endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_GEN
RETURN lOkay

#endif DEF_HST



#ifdef DEF_CTG

#define CTG_PERIODE  1
#define CTG_IDGEN    2
#define CTG_DEBIT    3
#define CTG_CREDIT   4
#define CTG_ALEN     4

**
** CtgRebuild() - Zentralisieren Historik
**
FUNCTION CtgRebuild()
local nCount := 0
local lOkay := .f.
local cIdJnl
local cIdGen
local aCtg
* local aCtp
local i
ddCloseAll()
open area oCtg() exclusive
  zap
  lOkay := .t.
close area
ddCloseAll()
RETURN .f. if ! lOkay
open area oHst() exclusive
  ddSetOrder(ORD_HST_GENDATE)
  lOkay := .t.
  nCount := 0
  go top
  do while ! eof() .and. lOkay
    cIdGen := HST->IdGen
    aCtg := {}
    do while ! eof() .and. lOkay .and. HST->IdGen == cIdGen
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      if TaskInter() ; lOkay := .f. ; exit ; endif
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
      skip
    enddo
    if ! lOkay ; exit ; endif
    lOkay := CtgUpdate(aCtg)
  enddo
close area
ddCloseAll()
RETURN lOkay

FUNCTION CtgCollect(aCtg,cIdGen,cPeriode,nDebit,nCredit)
local i
local ctg := NIL
for i := 1 to len(aCtg)
  if aCtg[i][CTG_IDGEN] == cIdGen
    if aCtg[i][CTG_PERIODE] == cPeriode
      ctg := aCtg[i]
    endif
  endif
next i
if ctg == NIL
  ctg := array(CTG_ALEN)
  ctg[CTG_PERIODE] := cPeriode
  ctg[CTG_IDGEN]   := cIdGen
  ctg[CTG_DEBIT]   := nDebit
  ctg[CTG_CREDIT]  := nCredit
  aadd( aCtg, ctg )
else
  ctg[CTG_DEBIT]  += nDebit
  ctg[CTG_CREDIT] += nCredit
endif
RETURN NIL

**
** CtgUpdate()
**
FUNCTION CtgUpdate(aCtg)
local i
local lOkay := .f.
local nDecPos // := DevDecPos(DevDefault(cPeriode))
open area oCtg()
  lOkay := .t.
  for i := 1 to len(aCtg)
    nDecPos := DevDecPos(DevDefault(aCtg[i][CTG_PERIODE]))
    if ! CtgItmUpdate( ;
      aCtg[i][CTG_IDGEN], ;
      aCtg[i][CTG_PERIODE], ;
      aCtg[i][CTG_DEBIT], ;
      aCtg[i][CTG_CREDIT], nDecPos ;
    )
      lOkay := .f.
      exit
    elseif ! CtgItmUpdate( ;
      aCtg[i][CTG_IDGEN], ;
      PerYear(aCtg[i][CTG_PERIODE]), ;
      aCtg[i][CTG_DEBIT], ;
      aCtg[i][CTG_CREDIT], nDecPos ;
    )
      lOkay := .f.
      exit
    elseif TaskInter()
      lOkay := .f.
      exit
    endif
  next i
close area
RETURN lOkay

STATIC FUNCTION CtgItmUpdate(cIdGen,cPeriode,nDebit,nCredit,nDecPos)
local i
RETURN .f. if ! CtgRecUpdate(cIdGen,cPeriode,nDebit,nCredit,nDecPos)
for i := 1 to LenIdGenHeader()
  RETURN .f. if ! CtgRecUpdate(padr(left(cIdGen,i),LenIdGen()),cPeriode,nDebit,nCredit,nDecPos)
next i
RETURN .t.

STATIC FUNCTION CtgRecUpdate(cIdGen,cPeriode,nDebit,nCredit,nDecPos)
seek cIdGen + cPeriode
if eof()
  if dbAddRec()
    CTG->IdGen   := cIdGen
    CTG->Periode := cPeriode
    CTG->Debit   := ntom(nDebit,nDecPos)
    CTG->Credit  := ntom(nCredit,nDecPos)
    unlock record
  else
    RETURN .f.
  endif
elseif ddRecLock()
  CTG->Debit   := ntom(val(CTG->Debit)  + nDebit,nDecPos)
  CTG->Credit  := ntom(val(CTG->Credit) + nCredit,nDecPos)
  unlock record
else
  RETURN .f.
endif
RETURN .t.

#endif DEF_CTG

*#ifdef DEF_MVP
*
***
*** MvpMvtGenerate() - Zentralisieren Partnerkonten
***
*FUNCTION MvpMvtGenerate()
*local nCount := 0
*local lOkay := .f.
*local i
*local aCtp
*local aMvg := {}
*local cIdPar
*local lFound
*local cCompte
** local jnl
***
*** Lauf 1 : MVP nach CTP summieren, dabei auch gleichzeitg MvgCollect()
***
*open area oMvp()
*  lOkay := .t.
*  ddSetOrder ORD_MVP_PARDATE
*  go top
*  nCount := 0
*  do while ! eof() .and. lOkay
*    if TaskInter() ; lOkay := .f. ; endif
*    cIdPar := MVP->IdPar
*    aCtp := {}
*    do while ! eof() .and. lOkay .and. MVP->IdPar == cIdPar
*      MsgDisp2("(1) " + ntrim0(100 * nCount++ / lastrec()) + "%")
*      if TaskInter() ; lOkay := .f. ; endif
*      if empty(cCompte := CtrIdGen(MVP->IdCtr))
*        PrintLine(MsgIdJnlDoc() + " : " + MVP->IdCtr + MsgCtrExist())
*        lOkay := .f.
*      else
*        MvgCollect( ;
*          aMvg,cCompte, ;
*          MVP->Date, MVP->Periode, MVP->IdJnl, ;
*          MVP->DC, val(MVP->Mont), "" ;
*        )
*      endif
*      skip
*    enddo
*  enddo
*close area
*RETURN .f. if ! lOkay
***
*** und jetzt werden die 400000 und 440000 aktualisiert
***
*nCount := 0
*lOkay := .f.
*open area oMvt()
*  ddSetOrder ORD_MVT_DOC // IdJnl + IdDoc + Line
*  lOkay := .t.
*  for i := 1 to len(aMvg)
*    MsgDisp2("(2) " + ntrim0(50 * i / len(aMvg)) + "%")
*    softseek aMvg[i][MVG_IDJNL]
*    do while ! eof() .and. MVT->IdJnl == aMvg[i][MVG_IDJNL] ;
*                     .and. empty(MVT->IdDoc)
*      if ddRecLock()
*        delete
*        unlock record  // "Error recovery failure, DBSKIP (0)" bei Heinen 960322
*      else
*        lOkay := .f.
*        exit  // "Error recovery failure, DBSKIP (0)" bei Heinen 960322
*      endif
*      skip
*    enddo
*  next i
*  if lOkay
*    for i := 1 to len(aMvg)
*      MsgDisp2(ntrim0(50 + 50 * i / len(aMvg)) + "%")
*      if dbAddRec()
*        MVT->IdGen   := aMvg[i][MVG_IDGEN]
*        MVT->Periode := aMvg[i][MVG_PERIODE]
*        MVT->IdJnl   := aMvg[i][MVG_IDJNL]
*        MVT->DC      := aMvg[i][MVG_DC]
*        MVT->Mont    := ntom(aMvg[i][MVG_MONT])
*        MVT->Date    := aMvg[i][MVG_DATE] // UserDate()
*        unlock record
*      else
*        lOkay := .f.
*      endif
*    next i
*  endif
*close area
*ddCloseAll()
*RETURN lOkay
*
**
** MvpMvtTest() - Zentralisieren Partnerkonten
**
*FUNCTION MvpMvtTest(cTitle)
*local nCount := 0
*local lOkay := .f.
*local i
*local aCtp
*local aMvg := {}
*local cIdPar
*local lFound
*local cCompte
*MsgDisplay(scTestTitle)
***
*** Lauf 1 : MVP nach CTP summieren, dabei auch gleichzeitg MvgCollect()
***
*open area oMvp()
*  lOkay := .t.
*  ddSetOrder ORD_MVP_PARDATE
*  go top
*  nCount := 0
*  do while ! eof() .and. lOkay
*    if TaskInter() ; lOkay := .f. ; endif
*    cIdPar := MVP->IdPar
*    aCtp := {}
*    do while ! eof() .and. lOkay .and. MVP->IdPar == cIdPar
*      MsgDisp2("(1) " + ntrim0(100 * nCount++ / lastrec()) + "%")
*      if TaskInter() ; lOkay := .f. ; endif
*      if empty(cCompte := CtrIdGen(MVP->IdCtr))
*        PrintLine(MsgIdJnlDoc() + " : " + MVP->IdCtr + MsgCtrExist())
*        lOkay := .f.
*      else
*        MvgCollect( ;
*          aMvg,cCompte, ;
*          MVP->Date, MVP->Periode, MVP->IdJnl, ;
*          MVP->DC, val(MVP->Mont), "" ;
*        )
*      endif
*      skip
*    enddo
*  enddo
*close area
*RETURN .f. if ! lOkay
***
*** und jetzt werden die 400000 und 440000 aktualisiert
***
*nCount := 0
*lOkay := .f.
*open area oMvt()
*  ddSetOrder ORD_MVT_DOC // IdJnl + IdDoc + Line
*  lOkay := .t.
*  for i := 1 to len(aMvg)
*    MsgDisp2("(2) " + ntrim0(50 * i / len(aMvg)) + "%")
*    softseek aMvg[i][MVG_IDJNL]
*    do while ! eof() .and. MVT->IdJnl == aMvg[i][MVG_IDJNL] ;
*                     .and. empty(MVT->IdDoc)
*      if ddRecLock()
*        delete
*        unlock record  // "Error recovery failure, DBSKIP (0)" bei Heinen 960322
*      else
*        lOkay := .f.
*        exit  // "Error recovery failure, DBSKIP (0)" bei Heinen 960322
*      endif
*      skip
*    enddo
*  next i
*  if lOkay
*    for i := 1 to len(aMvg)
*      MsgDisp2(ntrim0(50 + 50 * i / len(aMvg)) + "%")
*      if dbAddRec()
*        MVT->IdGen   := aMvg[i][MVG_IDGEN]
*        MVT->Periode := aMvg[i][MVG_PERIODE]
*        MVT->IdJnl   := aMvg[i][MVG_IDJNL]
*        MVT->DC      := aMvg[i][MVG_DC]
*        MVT->Mont    := ntom(aMvg[i][MVG_MONT])
*        MVT->Date    := aMvg[i][MVG_DATE] // UserDate()
*        unlock record
*      else
*        lOkay := .f.
*      endif
*    next i
*  endif
*close area
*ddCloseAll()
*RETURN lOkay
*
**
** aktualisiert MVT anhand von aMvg und sammelt nach aCtg
**
**
*FUNCTION MvgCtrUpdate(aMvg,aCtg)
*local lOkay := .f.
*local lFound
*local i
*open area oMvt()
*  ddSetOrder ORD_MVT_DOC // IdJnl + IdDoc + Line
*  lOkay := .t.
*  for i := 1 to len(aMvg)
*    lFound := .f.
*    softseek aMvg[i][MVG_IDJNL] + space(LEN_IDDOC) + aMvg[i][MVG_PERIODE]
*    do while ! eof() .and. MVT->Periode == aMvg[i][MVG_PERIODE] ;
*                     .and. MVT->IdDoc == space(LEN_IDDOC) ;
*                     .and. MVT->IdJnl == aMvg[i][MVG_IDJNL]
*      if MVT->IdGen == aMvg[i][MVG_IDGEN]
*        if MVT->DC == aMvg[i][MVG_DC]
*          if ddRecLock()
*            MVT->Mont := ntom(val(MVT->Mont) + aMvg[i][MVG_MONT])
*            if MVT->Date < aMvg[i][MVG_DATE]
*              MVT->Date := aMvg[i][MVG_DATE]
*            endif
*            lFound := .t.
*            unlock record
*          else
*            lOkay := .f.
*            exit
*          endif
*        endif
*      endif
*      skip
*    enddo
*    if ! lFound
*      if dbAddRec()
*        MVT->IdJnl := aMvg[i][MVG_IDJNL]
*        MVT->IdGen := aMvg[i][MVG_IDGEN]
*        MVT->Periode := aMvg[i][MVG_PERIODE]
*        MVT->Date  := aMvg[i][MVG_DATE ]
*        MVT->DC    := aMvg[i][MVG_DC   ]
*        MVT->Mont  := ntom(aMvg[i][MVG_MONT])
*      else
*        lOkay := .f.
*        exit
*      endif
*    endif
*    if aMvg[i][MVG_DC] == DC_DEBIT
*      CtgCollect(;
*        aCtg, aMvg[i][MVG_IDGEN], ;
*        aMvg[i][MVG_PERIODE], ;
*        aMvg[i][MVG_MONT], 0 ;
*      )
*    else
*      CtgCollect(;
*        aCtg, aMvg[i][MVG_IDGEN], ;
*        aMvg[i][MVG_PERIODE], ;
*        0, aMvg[i][MVG_MONT] ;
*      )
*    endif
*  next i
*close area
*RETURN lOkay
*
*#endif DEF_MVP


#ifdef DEF_CTP

**
** CtpRebuild() - Sammelhistorik Partnerkonten
**
FUNCTION CtpRebuild()
local nCount := 0
local lOkay := .t.
local i
local aCtp
local cIdPar
local lFound
local cCompte
* local jnl
local aCtg := {}
lOkay := .f.
ddCloseAll()
open area oCtp() exclusive
  lOkay := .t.
  zap
close area
ddCloseAll()
RETURN .f. if ! lOkay
lOkay := .f.
open area oHst()
  lOkay := .t.
  ddSetOrder(ORD_HST_PARDATE)
  // go top
  softseek "!" // also (normalerweise) der erste nicht-leere IdPar
  nCount := 0
  do while lOkay .and. ! eof()
    if TaskInter() ; lOkay := .f. ; exit ; endif
    cIdPar := HST->IdPar
    aCtp := {}
    do while ! eof() .and. lOkay .and. HST->IdPar == cIdPar
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      if TaskInter() ; lOkay := .f. ; endif
      CtpCollect( ;
        aCtp, HST->IdCtr, HST->IdPar, ;
        HST->Periode, ;
        MvpMontant(DC_DEBIT), MvpMontant(DC_CREDIT), 0 ;
      )
      skip
    enddo
    lOkay := CtpUpdate(aCtp)
  enddo
close area
ddCloseAll()
RETURN lOkay

#endif DEF_CTP

#ifdef DEF_CTT

**
** CttRebuild() - Zentralisieren MWSt.
**
FUNCTION CttRebuild(cCtp)
local nCount := 0
local lOkay := .f.
local lVenOkay := .f.
local aMvt
local jnl
local nUmsatz
local aCtp
local a
local nErrCount := 0
local nDocCount := 0
#ifdef DEF_CTP
  if cCtp == BUTTON_OFF // also wenn die CTP *nicht* rekonstruiert wurde
    ddCloseAll()
    open area oCtp() exclusive
      lOkay := .t.
      go top
      do while lOkay .and. ! eof()
        if TaskInter() ; lOkay := .f. ; endif
        CTP->Umsatz := ""
        skip
      enddo
    close area
    RETURN .f. if ! lOkay
  endif
#endif DEF_CTP
#ifdef DEF_CTT
  ddCloseAll()
  lOkay := .f.
  open area oCtt() exclusive
    lOkay := .t.
    zap
  close area
  RETURN .f. if ! lOkay
#endif DEF_CTT
ddCloseAll()
open area oVen(), oPar()
  go top
  do while ! eof() .and. lOkay
    if TaskInter() ; lOkay := .f. ; exit ; endif
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    if VEN->Etat == DocStatClosed()
      nDocCount++
      if (jnl := JnlLocate(VEN->IdJnl)) != NIL
        * if JNLATTR_G $ jnl[JNL_ATTRIB]
        if JnlDoHst(jnl,VEN->Periode)
          lVenOkay := .f.
          if (a := VenVnlInit(jnl)) == NIL
            rpt_write(MsgIdJnlDoc() + " (5) : " + SetMsg())
            lVenOkay := .f.
            nErrCount++
          else
            aMvt := {}
            aCtp := {}
            open area oVnl(VEN->Etat), oGen(), oArt(), oNew(), oVna()
              lVenOkay := .t.
              softseek VEN->IdJnl + VEN->IdDoc
              do while lOkay .and. ! eof() ;
                             .and. FIELD->IdDoc == VEN->IdDoc ;
                             .and. FIELD->IdJnl == VEN->IdJnl
                if ! VnlVarCollect()
                  rpt_write(MsgIdJnlDoc() + " (1) : " + SetMsg())
                  lVenOkay := .f.
                  nErrCount++
                endif
                if ! VnlMvtCollect( jnl, aMvt )
                  rpt_write(MsgIdJnlDoc() + " (2) : " + SetMsg())
                  lVenOkay := .f.
                  nErrCount++
                endif
                skip
              enddo
            close area
            #ifdef DEF_CTP
              #ifdef DEF_VENREMISE
                VenMvtRemise(aMvt)
              #endif
              #ifdef DEF_FRF
                VenFrfCollect(jnl,aMvt)
              #endif DEF_FRF
              VenMvtRound(aMvt,jnl)
              nUmsatz := VenMvtUmsatz(aMvt)
              CtpCollect( ;
                aCtp, jnl[JNL_IDCTR], VEN->IdPar, ;
                VEN->Periode, ;
                0, 0, nUmsatz ;
              )
            #endif DEF_CTP
            #ifdef DEF_CTT
              * if JNLATTR_G $ jnl[JNL_ATTRIB]
              if JnlDoHst(jnl,VEN->Periode)
                if ! VenCttUpdate(jnl,aMvt)
                  rpt_write(MsgIdJnlDoc() + " (3) : " + SetMsg())
                  lVenOkay := .f.
                  nErrCount++
                endif
              endif
            #endif DEF_CTT
            VnlRestore(a)
          endif
          #ifdef DEF_CTP
            if lVenOkay
              if ! CtpUpdate(aCtp)
                rpt_write(MsgIdJnlDoc() + " (4) : " + SetMsg())
                nErrCount++
              endif
            endif
          #endif DEF_CTP
        endif
      endif
    endif
    skip
  enddo
close area
rpt_write(ntrim(nDocCount) + MSG094 + ntrim(nErrCount) + MSG099 )
snErrCount += nErrCount
RETURN lOkay

**
** VenCttUpdate() ! GEN muss offen sein !
**
FUNCTION VenCttUpdate(jnl,aMvt)
local i
local lOkay := .f.
local nMont
* local nBase
* local nTaxe
local cDC := VEN->DC
local lDcInvert := "-" $ VEN->Mont
** 19991223 : EH Gutschriften Verkauf. "Manchmal weiá ich das gar
** nicht im Voraus, ob es eine Rechnung oder eine Gutschrift wird"
if lDcInvert
  cDC := DcInvert(cDC)
endif
open area oCtt(), oGen()
  lOkay := .t.
  for i := 1 to len(aMvt)
    nMont := aMvt[i][MVT_MONTDB]
    * nBase := aMvt[i][MVT_BASEDB]
    * nTaxe := aMvt[i][MVT_TAXEDB]
    if lDcInvert
      nMont := - nMont
      * nBase := - nBase
      * nTaxe := - nTaxe
    endif
    seek aMvt[i][MVT_IDGEN] in GEN
    seek VEN->Periode + ;
         VEN->IdJnl + ;
         aMvt[i][MVT_TAX][TAX_IDTAX] + ;
         GEN->IdClj + ;
         cDC
    if eof()
      if dbAddRec()
        CTT->Periode  := VEN->Periode
        CTT->IdJnl    := VEN->IdJnl
        CTT->IdTax    := aMvt[i][MVT_TAX][TAX_IDTAX]
        CTT->IdCtf    := GEN->IdClj
        CTT->DC       := cDC
        CTT->IdCtr    := jnl[JNL_IDCTR]
        if aMvt[i][MVT_ISBASE]
          CTT->Base     := ntom(nMont)
        else
          CTT->Taxe     := ntom(nMont)
        endif
        unlock record
      else
        lOkay := .f.
      endif
    elseif ddRecLock()
      if aMvt[i][MVT_ISBASE]
        CTT->Base := ntom(val(CTT->Base) + nMont)
      else
        CTT->Taxe := ntom(val(CTT->Taxe) + nMont)
      endif
      unlock record
    else
      lOkay := .f.
    endif
  next i
close area
RETURN lOkay

**
** CTT - centralisation TVA
**
FUNCTION CttEdit()
local b := oCtt()
open area b
  edit data b start top mode show query "CTT" title (MSG085)
close area
RETURN .f.

#endif DEF_CTT

#ifdef DEF_VEN

FUNCTION VenIsNC
local lIsNote := (VEN->DC != CtrDC(JnlIdCtr(VEN->IdJnl)))
* local lIsNote := (VEN->DC != JnlDC(VEN->IdJnl))
if left(ltrim(VEN->Mont),1) == "-"
  lIsNote := ! lIsNote
endif
RETURN lIsNote

#endif DEF_VEN




#ifdef DEF_HST

**
** ReClose() - Dokumente neu registrieren
**
FUNCTION ReClose(cTitle)
local cHstRebuild := BUTTON_OFF
local cMvsRebuild := BUTTON_OFF
local cCtsRebuild := BUTTON_ON
local cLettre     := BUTTON_ON
local cCtp := BUTTON_ON
local cCtt := BUTTON_ON
local cIdJnl := space(80)
* local cIdJnl := space(LenIdJnl())
local nHeight := 8
#ifdef DEF_MVS
  nHeight++
#endif
open window (cTitle) size (nHeight),50 help RECLOSE
do while .t.
  WinHome()
  say "Journale "
  @ row(), col() get cIdJnl picture "@k@!@s30" ;
                 pick PickJnlList(cIdJnl,JNLATTR_G)
  * @ row(), col() get cIdJnl picture PIC_ID ;
  *                pick PickIdJnl( ;
  *                  NIL,cIdJnl, ;
  *                  JnlList({|x|JnlDoHst(x)}) ;
  *                )
  *                *** JnlList({|x|JNLATTR_G $ x[JNL_ATTRIB]})
  * say " "
  WinCr()
  SayGetPeriode()
  @ row(), col() get cHstRebuild checkbox
  say " " + MSG091
  WinCr()
  #ifdef DEF_MVS
    @ row(), col() get cMvsRebuild checkbox
    say " " + MSG_MVSEDIT
    * say " in Periode " + MemMvsPeriode // 970407
    WinCr()
  #endif DEF_MVS
  say MsgLstCtrl() // "Kontrollliste :"
  WinCr()
  GetPreview() ; WinCr()
  SetTplIni("LISTE")
  GetTplIni()
  nKey := ReadScr()
  if nKey != K_ESC .and. cHstRebuild == BUTTON_ON
    if ! Confirm(MSG091,MsgSure(),MSG_NO)
      loop
    endif
  endif
  #ifdef DEF_MVS
    if nKey != K_ESC .and. cMvsRebuild == BUTTON_ON
      if ! Confirm("Bisherige Valorisierungen gehen verloren !",MsgSure(),MSG_NO)
        loop
      endif
    endif
  #endif DEF_MVS
  close window
  RETURN .f. if nKey == K_ESC
  exit
enddo
open printer SetTplIni() width 80 ;
             preview SetPreview() ;
             TitBlock {|| PrintHeader("ReClose()") }
if ! LstContinue()
  close printer
  RETURN .f.
endif
if cHstRebuild == BUTTON_ON
  PrintLine(MSG091 + " " + trim(cIdJnl) + " ...")
  MsgDisplay(MSG091 + "...")
  if HstRebuild(cIdJnl)
    PrintLine(MSG091 + MsgDone())
  else
    PrintLine(MSG091 + MsgFailed())
  endif
endif
#ifdef DEF_MVS
  if cMvsRebuild == BUTTON_ON
    PrintLine(MSG_MVSEDIT + " " + trim(cIdJnl) + " ...")
    MsgDisplay(MSG_MVSEDIT + "...")
    if MvsRebuild(cIdJnl)
      PrintLine(MSG_MVSEDIT + MsgDone())
    else
      PrintLine(MSG_MVSEDIT + MsgFailed())
    endif
  endif
#endif DEF_MVS
close printer
RETURN MnuDone()

**
** HstRebuild()
**
STATIC FUNCTION HstRebuild(cIdJnl)
local jnl
local aPar
local aGen
local aCtp
local aCtg
local nDocCount := 0
local nErrCount := 0
local lOK := .f.
local nCount := 0
ddCloseAll()
  lOk := .f.
  open area oHst() exclusive
    nCount := 0
    go top
    do while ! eof()
      MsgDisp2("HST " + ntrim0(100 * nCount++ / lastrec()) + "%")
      if TaskInter()
        BREAK AREA
      endif
      if empty(cIdJnl) .or. HST->IdJnl $ cIdJnl
        if ChkPeriode(HST->Periode) == 0
          if ! PerIsClosed(HST->Periode,HST->IdJnl)
            delete
          endif
        endif
      endif
      skip
    enddo
    lOK := .t.
  close area
  RETURN .f. if ! lOk
#ifdef DEF_MVA
  lOk := .f.
  open area oMva() exclusive
    nCount := 0
    go top
    do while ! eof()
      MsgDisp2("MVA " + ntrim0(100 * nCount++ / lastrec()) + "%")
      if TaskInter()
        BREAK AREA
      endif
      ** Wichtig : MVA aus VEN-Journalen wird nicht rekonstruiert, weil
      ** hier direkt in der MVA eingegeben wird.
      if JnlAlias(MVA->IdJnl) == JNLALIAS_FIN
        if empty(cIdJnl) .or. MVA->IdJnl $ cIdJnl
          if ChkPeriode(MVA->Periode) == 0
            if ! PerIsClosed(MVA->Periode,MVA->IdJnl)
              delete
            endif
          endif
        endif
      endif
      skip
    enddo
    lOK := .t.
  close area
  RETURN .f. if ! lOk
#endif DEF_MVA
ddCloseAll()
#ifdef DEF_VEN
  lOK := .f.
  open area oArt(), oGen(), oPar()
    * 19980724 open area oVen(),oVnl() exclusive
    open area oVen() exclusive
      nCount := 0
      lOk := .t.
      go top
      do while ! eof() .and. LstContinue()
        MsgDisp2("VEN " + ntrim0(100 * nCount++ / lastrec()) + "%")
        if VEN->Etat == DocStatClosed()
          if empty(cIdJnl) .or. VEN->IdJnl $ cIdJnl
            if ChkPeriode(VEN->Periode) == 0
              if ! PerIsClosed(VEN->Periode,VEN->IdJnl)
                if (jnl := JnlLocate(VEN->IdJnl)) == NIL
                  PrintLine(MsgIdJnlDoc() + MsgJnlExist())
                * elseif JNLATTR_G $ jnl[JNL_ATTRIB]
                elseif JnlDoHst(jnl,VEN->Periode)
                  SetDevise(DevDefault(VEN->Periode))
                  SetMsg(MSG010)
                  if ! VenHstRebuild(jnl)
                    PrintLine(MsgIdJnlDoc() + " : " + SetMsg())
                    nErrCount++
                  endif
                  nDocCount++
                endif
              endif
            endif
          endif
        endif
        if TaskInter() ; lOk := .f. ; exit ; endif
        skip
      enddo
    close area
    ddCloseAll()
  close area
  RETURN .f. if ! LstContinue()
  RETURN .f. if ! lOk
#endif DEF_VEN
#ifdef DEF_FIN
  lOK := .f.
  open area oFin() exclusive
    lOK := .t.
    nCount := 0
    go top
    do while ! eof()
      MsgDisp2("FIN " + ntrim0(100 * nCount++ / lastrec()) + "%")
      if FIN->Etat == DocStatClosed()
        if empty(cIdJnl) .or. FIN->IdJnl $ cIdJnl
          if ChkPeriode(FIN->Periode) == 0
            if ! PerIsClosed(FIN->Periode,FIN->IdJnl)
              aPar := {}
              aGen := {}
              aCtp := {}
              aCtg := {}
              * aMvgCtr := {}
              if (jnl := JnlLocate(FIN->IdJnl)) == NIL
                PrintLine(MsgIdJnlDoc() + MsgJnlExist())
              * else
              elseif JnlDoHst(jnl,FIN->Periode)
                SetDevise(DevDefault(FIN->Periode))
                if ! FinClose(jnl,aPar,aGen,aCtp,aCtg)
                  if empty(SetMsg())
                    PrintLine(MsgIdJnlDoc() + MSG010 )
                  else
                    PrintLine(MsgIdJnlDoc() + " : " + SetMsg())
                  endif
                  FIN->Etat := DocStatNew()
                  nErrCount++
                endif
              endif
              nDocCount++
            endif
          endif
        endif
      endif
      if TaskInter() ; lOK := .f. ; exit ; endif
      skip
    enddo
  close area
  ddCloseAll()
  RETURN .f. if ! lOk
#endif DEF_FIN
PrintLine(ntrim(nDocCount) + MSG094 + ntrim(nErrCount) + MSG099 )
ddCloseAll()
RETURN LstContinue()


#endif DEF_HST

#ifdef DEF_VNLALT

**
**  VnlClean() l”scht die unntzen VNL-Records aus der VNLPRE.DBF
**
FUNCTION VnlClean(cIdJnl)
local lOkay := .f.
local aVnl
local nCount := 0
local nDeleted := 0
local i
default cIdJnl to ""
SendConsole("VnlClean('"+cIdJnl+"')")
open area oVen()
  if empty(cIdJnl)
    go top
  else
    softseek cIdJnl
  endif
  do while ! eof()
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    if TaskInter() ; exit ; endif
    if !empty(cIdJnl) .and. VEN->IdJnl != cIdJnl
      exit
    endif
    if VEN->Etat == DocStatClosed()
      if ddRecLock()
        aVnl := {}
        open area oVnl(DocStatOpen())
          softseek VEN->IdJnl + VEN->IdDoc
          do while ! eof() .and. FIELD->IdJnl == VEN->IdJnl ;
                           .and. FIELD->IdDoc == VEN->IdDoc
            aadd(aVnl,CopyRec())
            skip
          enddo
        close area
        if len(aVnl) > 0
          i := 0
          lOkay := .f.
          open area oVnl(DocStatClosed())
            lOkay := .t.
            softseek VEN->IdJnl + VEN->IdDoc
            do while lOkay .and. ! eof() ;
                           .and. FIELD->IdJnl == VEN->IdJnl ;
                           .and. FIELD->IdDoc == VEN->IdDoc
              i++
              if i > len(aVnl)
                lOkay := .f.
              else
                lOkay := RecCompare(aVnl[i])
              endif
              skip
            enddo
          close area
          if lOkay
            open area oVnl(DocStatOpen())
              softseek VEN->IdJnl + VEN->IdDoc
              do while ! eof() .and. FIELD->IdJnl == VEN->IdJnl ;
                               .and. FIELD->IdDoc == VEN->IdDoc
                if ddRecLock()
                  delete
                  unlock record
                  nDeleted ++
                endif
                skip
              enddo
            close area
          endif
        endif
        unlock record
      endif
    endif
    skip
  enddo
close area
SetMsg(ntrim(nDeleted) + " Datens„tze wurden gel”scht.")
RETURN lOkay

#endif DEF_VNLALT


#ifdef DEF_MVA

#ifdef DEF_VEN

*FUNCTION VenMvaTest()
*local aMva := {}
*local i
*local lOkay := .f.
*local cIdGen
*local cLine
*open area oVnl(VEN->Etat),oGen()
*  lOkay := .t.
*  softseek VEN->IdJnl + VEN->IdDoc
*  do while ! eof() .and. FIELD->IdJnl == VEN->IdJnl ;
*                   .and. FIELD->IdDoc == VEN->IdDoc
*    if FIELD->Code == LNCODE_GEN
*      cIdGen := left(FIELD->IdArt,LenIdGen())
*      cLine  := FIELD->Line
*      if ! GenExist(cIdGen)
*        it_warning("MVA-> " + MsgIdJnlDoc() + " : " + SetMsg() )
*        lOkay := .f.
*      elseif GENATTR_Y $ GEN->Attrib
*        aCollect(aMva, { cIdGen, VenDev2Db(val(FIELD->cMont)) } )
*        #ifdef DEF_TAX
*          if VnlTaxAna()
*            aCollect(aMva, { cIdGen, VenDev2Db(val(FIELD->MontT)) } )
*          endif
*        #endif
*      endif
*    endif
*    skip
*  enddo
*close area
*RETURN .f. if ! lOkay
*RETURN DocMvaTest(VEN->IdJnl,VEN->IdDoc,aMva,VEN->DC,VEN->Periode)

#endif DEF_VEN

#ifdef DEF_IMP

FUNCTION ImpMvaTest()
local aMva := {}
local i
local lOkay := .f.
RETURN .t. if ! JNLATTR_Y $ JnlAttrib(IMP->IdJnl)
open area oIml(), oBud()
  lOkay := .t.
  softseek IMP->IdJnl+IMP->IdDoc
  do while IML->IdDoc == IMP->IdDoc .and. IML->IdJnl == IMP->IdJnl ;
           .and. !eof()
    if ! BudExist(IML->DC,IML->IdBud)
      it_warning("IML-> " + MsgIdJnlDoc() + " : " + SetMsg() )
      lOkay := .f.
    elseif BUDATTR_Y $ BUD->Attrib
      aCollect(aMva, { ;
        IML->DC+IML->IdBud, ;
        val(IML->Mont) ;
      } )
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
RETURN DocMvaTest(IMP->IdJnl,IMP->IdDoc,aMva,JnlDC(IMP->IdJnl),IMP->Periode)


#endif DEF_IMP

FUNCTION DocMvaTest(cIdJnl,cIdDoc,aMva,cDC,cPeriode)
local c
local i
local lFound
local lOkay := .f.
RETURN .t. if NoDocMvaCheck()
open area oMva()
  lOkay := .t.
  ddSetOrder(ORD_MVA_DOC)
  softseek cIdJnl + cIdDoc
  do while lOkay .and. ! eof() ;
                 .and. MVA->IdDoc == cIdDoc ;
                 .and. MVA->IdJnl == cIdJnl
    lFound := .f.
    if MVA->Periode != cPeriode
      it_warning("MVA-> "+MsgIdJnlDoc()+" : MVA->Periode <> " + cPeriode )
    endif
    for i := 1 to len(aMva)
      #ifdef DEF_IMP
        if aMva[i][1] == MVA->DC + MVA->IdBud
          aMva[i][2] -= val(MVA->Mont)
          lFound := .t.
          exit
        endif
      #else
        if aMva[i][1] == MVA->IdGen
          if MVA->DC == cDC
            aMva[i][2] -= val(MVA->Mont)
          else
            aMva[i][2] += val(MVA->Mont)
          endif
          lFound := .t.
          exit
        endif
      #endif
    next i
    if ! lFound
      #ifdef DEF_IMP
        SetMsg( ;
          "Analytischer Betrag " + ltrim(MVA->Mont) ;
          + " im Artikel " + SayIdBud(MVA->IdBud) ;
          + " fehlt als Buchung !" ;
        )
      #else
        SetMsg( ;
          "MVA != HST (" + MVA->IdGen + ") : " + ltrim(MVA->Mont) ;
        )
      #endif
      lOkay := .f.
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
for i := 1 to len(aMva)
  if abs(aMva[i][2]) > Tolerance(SetDecPos()) // 0.001
    #ifdef DEF_IMP
      c := SayIdBud(substr(aMva[i][1],2))
    #else
      c := aMva[i][1]
    #endif
    SetMsg( ;
      c+" wurde analytisch nicht komplett verteilt : " + ntrim(aMva[i][2]) ;
    )
    RETURN .f.
  endif
next i
RETURN .t.

#endif DEF_MVA



#ifdef DEF_VNA

FUNCTION VnaTest(xlFilter)
local lOkay := .f.
local cOldId := NIL
local nQteUs
local nQte
local nCount := 0
local b := oVna()
local jnl, trn
local bcKey := {||"VNA->"+VNA->IdJnl+VNA->IdDoc+"."+VNA->Line}
open area b, oVen(), oPar()
  lOkay := .t.
  TestTried()
  go top
  lOkay := .t.
  do while lOkay .and. ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    if cOldId != NIL .and. eval(bcKey) == cOldId
      it_warning(eval(bcKey) + MSG_DUP_REF)
    endif
    cOldId := eval(bcKey)
    if &xlFilter
      nQteUs := qton1(VNA->Qte)
      open area oVnl()
        ddSetOrder(ORD_VNL_VNA)
        softseek VNA->IdJnl+VNA->IdDoc+VNA->Line
        do while !eof() .and. ;
          VNL->Match == VNA->IdJnl+VNA->IdDoc+VNA->Line
          seek VNL->IdJnl+VNL->IdDoc in VEN
          if VEN->Etat == DocStatClosed()
            if VNL->IdArt != VNA->IdArt
              it_warning(eval(bcKey) + " : IdArt changes")
            elseif (jnl := JnlLocate(VNL->IdJnl)) == NIL
              it_warning(eval(bcKey) + " : " + SetMsg() )
            elseif (trn := VnaTrnLocate(jnl)) == NIL
              it_warning(eval(bcKey) + " : VnaTrnLocate() failed" )
            else
              nQte := qton1(VNL->Qte)
              if TRNATTR_I $ trn[TRN_ATTRIB]
                nQte *= -1
              endif
              if VNA->DC != jnl[JNL_DC]
                nQte *= -1
              endif
              if !TRNATTR_P $ trn[TRN_ATTRIB]
                nQteUs -= nQte
              endif
            endif
          endif
          skip
        enddo
      close area
      if ! DoEvents(b[AD_ONTEST])
        it_warning(eval(bcKey)+ " : " + SetMsg())
      endif
      if qton1(VNA->QteUs) != nQteUs
        if ntoq(nQteUs,VNA->QteForm) != VNA->QteUs
        it_warning(eval(bcKey)+" "+trim(ParName(VNA->IdPar))+" : QteUs is "+ltrim(VNA->QteUs);
          +" (expected "+ltrim(ntoq(nQteUs,VNA->QteForm))+")" )
        endif
      elseif qton1(VNA->QteUs) == 0 .and. empty(VNA->Satis)
        it_warning(eval(bcKey)+ " : not marked as satisfied")
      endif
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

RETURN .t.
#endif DEF_VNA


FUNCTION DbfTest(ad,xcKey)
local lOkay := .f.
local cOldId := ""
local cField
open area ad
  TestTried()
  lOkay := .t.
  go top
  do while ! eof()
    if TestInter() ; lOkay := .f. ; exit ; endif
    if &xcKey == cOldId
      it_warning(alias()+" " + cOldId + MSG_DUP_REF)
    else
      cOldId := &xcKey
    endif
    skip
  enddo
  if lOkay ; MsgShouldRebuild() ; endif
close area
RETURN lOkay

