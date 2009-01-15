** -*- coding: cp850 -*-
** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2009 Luc Saffre
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

request ParEdit

* #ifdef DEF_XTV
*   request XtvEdit
* #endif
#ifdef DEF_JNL
  request DocEdit
#endif

#ifdef DEF_GUI
#include "APPEVENT.CH"
#endif DEF_GUI

#ifdef DEF_VAR
  request VarEdit
#endif DEF_VAR

#ifdef LG_FRENCH
  #define MSG_VEN     "Facturation"
  #define MSG_IMP     "ComptabilitÇ Çconomique/fonctionelle"
  #define MSG_ANA     "ComptabilitÇ analytique"
  #define MSG_PRESTO  "Agenda"
  * #define MSG_FIN     "Financiers"
  #define MSG_GEN     "ComptabilitÇ gÇnÇrale"
  #define MSG_IVT     "Inventaires"
  #define MSG_VNA     "Facturationˇautomatique"
  #define MSG_STK     "Gestionˇdeˇstock"
  #define MSG_PRJ     "Gestionˇdeˇprojets"
  #define MSG_HOLZ    "ZusatzmodulˇHolzhandel"
#endif

#ifdef LG_GERMAN
  #define MSG_VEN     "Fakturierung"
  #define MSG_IMP     "îkonomisch-funktionaleˇBuchfÅhrung"
  #define MSG_ANA     "AnalytischeˇBuchfÅhrung"
  #define MSG_PRESTO  "Terminverwaltung"
  * #define MSG_FIN     "Finanzjournale"
  #define MSG_GEN     "AllgemeineˇBuchfÅhrung"
  #define MSG_IVT     "Inventuren"
  #define MSG_VNA     "Automatik-Fakturierung"
  #define MSG_STK     "Lagerverwaltung"
  #define MSG_PRJ     "Projektverwaltung"
  #define MSG_HOLZ    "ZusatzmodulˇHolzhandel"
#endif

#ifdef LG_EN
  #define MSG_VEN     "Invoicing"
  #define MSG_IMP     "îkonomisch-funktionaleˇBuchfÅhrung"
  #define MSG_ANA     "Analytic accounting"
  #define MSG_PRESTO  "Terminverwaltung"
  * #define MSG_FIN     "Financial Accounting"
  #define MSG_GEN     "General Accounting"
  #define MSG_IVT     "Inventuren"
  #define MSG_VNA     "Automatik-Fakturierung"
  #define MSG_STK     "Lagerverwaltung"
  #define MSG_PRJ     "Projektverwaltung"
  #define MSG_HOLZ    "ZusatzmodulˇHolzhandel"
#endif

static saMainMnu := NIL
static slActiveMenus := .f.

**
** Main function
**
FUNCTION Main(cParam1,cParam2,cParam3)
#ifdef DEF_GUI
  local nEvent, mp1, mp2, oXbp
#endif DEF_GUI
local cParams := ""
**
** APPLICATION STARTUP
**
#ifdef DEF_IMP
  PUBLIC MemIdCdc      := "02"
  * PUBLIC MemSaldo      := 0
  * PUBLIC MemParSalDate := ctod("")
#endif DEF_IMP
#ifdef DEF_FIN
  PUBLIC MemMatch  := padr("MAN", LenIdJnl()+LEN_IDDOC,"0")
#endif DEF_FIN
PUBLIC MemLpp      := 66    // TIM fÅr AMG
PUBLIC MemLpt      := "LPT1"
PUBLIC MemDrv      := "STD"
PUBLIC MemPays     := "B  "
PUBLIC MemPer1 := space(LEN_PERIODE)
PUBLIC MemPer2 := space(LEN_PERIODE)
PUBLIC MemAttrib := ""
#ifdef DEF_ART
  PUBLIC MemPickArtMode := "A"
  * PUBLIC MemQryArtPick := "ARTPICK"
#endif DEF_ART
#ifdef DEF_SUB
  PUBLIC MemSubAttrib := space(5)
#endif
public MemTxtCor    := "FAX"
* public MemIdDev     := "BEF"
public MemNoTva     := space(14)
#ifdef DEF_VNA
  public MemVnaMont   := space(10)
#endif DEF_VNA
#ifdef DEF_MVS
  PUBLIC MemMvsPeriode := space(LEN_PERIODE)
#endif DEF_MVS
if cParam1 != NIL ; cParams += cParam1 ; endif
if cParam2 != NIL ; cParams += cParam2 ; endif
if cParam3 != NIL ; cParams += cParam3 ; endif
#ifdef __XPP__
  * SetMouse(.t.)
  * set(_SET_HANDLEEVENT,.f.)
#endif __XPP__
#ifndef __XPP__
  if ! AppInit("TIM", 4.0)
    ? SetMsg()
    quit // seit 20080318
  endif
#endif __XPP__
if ! AppMain( cParams, "TIM", 4.0)
  if ! empty(SetMsg())
    Warning(SetMsg()) // ? SetMsg() + CR_LF
  endif
  AppNormEnd()
endif
#ifdef DEF_GUI
  SetAppWindow():close := {|mp1,mp2,obj| AppNormEnd() }
  * Warning("gonna enter main loop")
  do while .T.
    nEvent := AppEvent( @mp1, @mp2, @oXbp )
    * if nEvent == xbeP_None .and. MustLogin()
    if MustLogin()
      * Warning("gonna dblogin()")
      if ! dblogin()
        * Warning("dblogin() returned .f.")
        if ! empty(SetMsg())
          Warning(SetMsg()) // ? SetMsg() + CR_LF
        endif
        AppNormEnd()
      endif
    else
      * Warning("dblogin() returned .t.")
      oXbp:handleEvent( nEvent, mp1, mp2 )
    endif
  enddo
#else
  if ! dblogin()
    if ! empty(SetMsg())
      Warning(SetMsg()) // ? SetMsg() + CR_LF
    endif
    AppNormEnd()
  endif
  * MnuLoad(UsrIdMnu())
  do while .t.
    scroll()
    SayLeg(AppLegend())
    SaySta( DbPath() )
    OnMainMenu()
    hMenu( saMainMnu, 0, 0, maxcol(), CfgMainMenuColor() )
    commit
    unlock all
    if AppTerminate()
      AppNormEnd() // AppExit()
    endif
  enddo
#endif
RETURN NIL // never reached


FUNCTION SetActiveMenus(x)
RETURN slActiveMenus if x == NIL
slActiveMenus := x
RETURN .t.


**
** MnuLoad() - build main menu
**
FUNCTION MnuLoad(cIdMnu,lActive)
local a
local cMnuName := cIdMnu
if empty(cIdMnu)
  cMnuName := "USER"
endif
default lActive to SetActiveMenus()
if lActive
  #ifdef DEF_GUI
    a := SetAppWindow():menuBar()
    do while a:delItem(1)
    enddo
  #else
    a := {}
  #endif
  RETURN .f. if ! MnuExec(a,cMnuName)
else
  a := MnuRead(cIdMnu)
  RETURN .f. if a == NIL
endif
saMainMnu := a
*if empty(cIdMnu)
*  WinSetHelp("MAIN")
*else
*  WinSetHelp(cIdMnu)
*endif
WinSetHelp(cMnuName)
RETURN SetMnuDone()

FUNCTION GetMainMenu()
RETURN saMainMnu


**
** MnuRead()
**
STATIC FUNCTION MnuRead(cIdMnu)
local a
local cMac
local cMnuName := ""
local cLine
* local cFile := DbPath() + "\MNU" + cIdMnu + ".DBC"
local cFile := "MNU" + cIdMnu + ".DBC"
local fd
local nCut
local nLine := 0
local i
local aBar := {}
if (fd := mopen(cFile)) == NIL
  Warning(SetMsg())
  RETURN NIL
endif
MsgDisplay(MsgLoading(cFile))
do while (cLine := mreadline(fd)) != NIL
  nLine++
  if (nCut := at("//",cLine)) != 0
    cLine := left(cLine,nCut-1)
  endif
  if empty(cLine)
    loop
  endif
  a := ListAsArray(cLine,"|")
  if len(a) == 3 // ganz altes Format...
    aadd(a,NIL)
    aadd(a,NIL)
    a[MNU_HOTKEY] := NIL
    a[MNU_MACRO]  := a[3]
    a[MNU_ITEM]   := a[2]
    a[MNU_MENU]   := a[1]
    a[MNU_EXPR]   := ""
  elseif len(a) == 4 // altes Format...
    aadd(a,NIL)
    a[MNU_HOTKEY] := NIL
    a[MNU_MACRO]  := a[4]
    a[MNU_ITEM]   := a[3]
    a[MNU_MENU]   := a[2]
    a[MNU_EXPR]   := a[1]
  endif
  if len(a) == MNU_ALEN
    if empty(a[MNU_EXPR]) .or. &(a[MNU_EXPR])
      if cMnuName != a[MNU_MENU]
        cMnuName := a[MNU_MENU]

        define menu cMnuName in aBar
      endif
      if empty(a[MNU_ITEM])
        AddLine()
      elseif ! empty(a[MNU_MACRO])
        AddItem(a[MNU_ITEM], cblock(a[MNU_MACRO]))
        * 20070416 denn das geht in xbase nicht
        * cMac := a[MNU_MACRO]
        * * AddItem(padr(a[MNU_ITEM],LEN_MNU_X), {|| &cMac })
        * AddItem(a[MNU_ITEM], {|| &cMac })
      endif
    endif
  else
    if ! Confirm( ;
      cFile + MsgDbcError() + ntrim(nLine), ;
      MsgContinue(), MSG_YES, "WRN052" ;
    )
      exit
    endif
  endif
enddo
mclose(fd)
MsgDisplay("")
RETURN aBar


#ifdef DEF_PRESTO

**
** SayAgenda()
**
FUNCTION SayAgenda(dDate)
local nLine := 4
local cLine
RETURN .t. if nextkey() != 0
open area oTrm(), oPar(), oArt()
  softseek dtos(dDate)
  dDate := NIL
  do while nLine <= 18 .and. ! eof()
    if nextkey() != 0
      break area
    endif
    * if ! empty( TRM->User + TRM->Debut + TRM->Fin + TRM->Texte) .or. dDate != TRM->Date
    if ! AGSATTR_H $ AgsAttrib(TRM->Etat)
      if ! TRMATTR_H $ TRM->Attrib
        if TRM->Date != dDate
          @ nLine,1 say left(Jour(TRM->Date),2) + " " + ;
                   left(dtoc(TRM->Date),5)
          dDate := TRM->Date
        endif
        cLine := " " + TRM->Debut + " " + ;
                       TRM->Fin   + " " + ;
                       TRM->User  + " " + ;
                       left(TRM->Texte,40) + " " + ;
                       TRM->IdTac
          @ nLine,10 say cLine
        nLine++
        if ! empty(TRM->IdPar)
          @ nLine,32 say ParName(TRM->IdPar)
          nLine++
        endif
      endif
    endif
    skip
  enddo
close area
RETURN .t.
* if file(dbPath() + "\NEWS.TXT")
*   cLine := memoread(dbPath() + "\NEWS.TXT")
*   memodisplay(StrParse(cLine),1,0,21,80)
* else
* endif

#endif DEF_PRESTO


FUNCTION AppReset()
MskCloseAll()
DbResetObj()
oPar(.t.)          // lRebuild
#ifdef DEF_ART
  oArt(.t.)          // lRebuild
#endif
#ifdef DEF_GEN
  oGen(.t.)          // lRebuild
#endif
#ifdef DEF_GRA
  oGra(.t.)
#endif
#ifdef DEF_VEN
  oVen(.t.)
  oVnl(DocStatClosed(), .t.)
  oVnl(DocStatNew(), .t.)
#endif
#ifdef DEF_IVT
  oIvl(.t.)
#endif
#ifdef DEF_STS
  oSts(.t.)
#endif
#ifdef DEF_HOLZ
  oStm(.t.)
#endif
#ifdef DEF_SUB
  oSub(.t.)
#endif
RETURN NIL

FUNCTION AppRefresh(cIdMnu,lActive)
default cIdMnu to UsrIdMnu()
AppReset()
RETURN MnuLoad(cIdMnu,lActive)

*FUNCTION TimOptions
*local aOpt := {}
*#ifdef LG_GERMAN
*  * #ifdef DEF_VEN
*  *   aadd(aOpt, { "N", "Fakturierung Einkauf/Verkauf ", 1 } )
*  * #endif
*  * #ifdef DEF_COMPTA
*    aadd(aOpt, { "F", "Finanzbuchhaltung            ", 1 } )
*  * #endif
*  #ifdef DEF_ART
*    aadd(aOpt, { "S", "Artikel- und Lagerverwaltung ", 1 } )
*  #endif
*  #ifdef DEF_VNA
*    aadd(aOpt, { "B", "Lagerverwaltung              ", 1 } )
*  #endif
*  #ifdef DEF_MSG
*    aadd(aOpt, { "M", "Mailbox & Korrespondenz      ", 1 } )
*  #endif
*  #ifdef DEF_PRESTO
*    aadd(aOpt, { "P", "Dienstleistungen & Agenda    ", 1 } )
*  #endif
*  #ifdef DEF_FIDU
*    aadd(aOpt, { "D", "Externe Datenbanken          ", 1 } )
*  #endif
*    aadd(aOpt, { "+", "Sonder-Anpassungen           ", 1 } )
*#endif
*#ifdef LG_FRENCH
*  * #ifdef DEF_VEN
*  *   aadd(aOpt, { "N", "Facturation (achats/ventes)     ", 1 } )
*  * #endif
*  * #ifdef DEF_COMPTA
*    aadd(aOpt, { "F", "Financiers & comptabilitÇ       ", 1 } )
*  * #endif
*  #ifdef DEF_ART
*    aadd(aOpt, { "S", "Gestion d'Articles/Stock        ", 1 } )
*  #endif
*  #ifdef DEF_VNA
*    aadd(aOpt, { "B", "Suivi des commandes & livraisons", 1 } )
*  #endif
*  #ifdef DEF_MSG
*    aadd(aOpt, { "M", "Mailbox & Correspondance        ", 1 } )
*  #endif
*  #ifdef DEF_PRESTO
*    aadd(aOpt, { "P", "Prestations & Agenda            ", 1 } )
*  #endif
*  #ifdef DEF_FIDU
*    aadd(aOpt, { "D", "Dossiers externes               ", 1 } )
*  #endif
*    aadd(aOpt, { "+", "Modules personnalisÇs           ", 1 } )
*#endif
*RETURN aOpt

* FUNCTION AppStatus
* RETURN PerActive() + " ≥"

*FUNCTION t19980216
*local dDate
*open area oPar(), oMvi()
*  go top
*  do while ! eof()
*    if TaskInter() ; exit ; endif
*    dDate := ctod("")
*    select MVI
*      ddSetOrder ORD_MVI_PARDATE
*      softseek PAR->IdPar
*      do while ! eof() .and. MVI->IdPar == PAR->IdPar
*        dDate := MVI->Date
*        skip
*      enddo
*      ddSetOrder ORD_MVI_PAR2DATE
*      softseek PAR->IdPar
*      do while ! eof() .and. MVI->IdPar2 == PAR->IdPar
*        dDate := max(dDate,MVI->Date)
*        skip
*      enddo
*    select PAR
*    if ddRecLock()
*      PAR->ImpDate := dDate
*      unlock record
*    endif
*    skip
*  enddo
*close area
*RETURN MnuDone()

FUNCTION SplashScreen() // TimLogo
#ifndef DEF_GUI
local i := 4
local nCol := 36
scroll()
@ 05,10 say "⁄ƒƒƒƒƒƒƒøƒøƒƒƒ¬ƒƒƒƒø"
@ 06,10 say "≥       ≥ ≥   ≥    ≥"
@ 07,10 say "¿ƒø   ⁄ƒŸ ≥   ≥    ≥"
@ 08,10 say "  ≥   ≥   ≥ ≥   ≥  ≥"
@ 09,10 say "  ¿ƒƒƒŸƒƒƒŸƒ¡ƒƒƒ¡ƒƒŸ"
@ 10,10 say " ƒƒ Time Is Money ƒƒ"
#ifdef DEF_GEN
  AddOption("GEN")
  #ifndef DEF_IMP
    @ i++,nCol say MSG_GEN
    AddMrkOption("G")
  #endif
#endif
#ifdef DEF_VEN
  @ i++,nCol say  MSG_VEN
  AddMrkOption("V")
  AddOption("VEN")
#endif
#ifdef DEF_VNA
  @ i++,nCol say MSG_VNA
  AddMrkOption("A")
  AddOption("VNA")
#endif
#ifdef DEF_FIN
  * @ i++,nCol say MSG_FIN
  AddMrkOption("F")
  AddOption("FIN")
#endif
#ifdef DEF_IMP
  @ i++,nCol say MSG_IMP
  AddMrkOption("E")
  AddOption("IMP")
#endif
#ifdef DEF_TRA
  @ i++,nCol say "Kassenbetrieb"
  AddMrkOption("K")
  AddOption("TRA")
#endif
#ifdef DEF_KVK
  @ i++,nCol say "Kassenbetrieb"
  AddMrkOption("K")
  AddOption("KVK")
#endif
#ifdef DEF_IMP
* 20010731 #ifdef DEF_PRJ
  @ i++,nCol say MSG_PRJ
  AddMrkOption("J")
#endif
#ifdef DEF_SER
  @ i++,nCol say "Seriennummern"
  AddMrkOption("N")
  AddOption("SER")
#endif
#ifdef DEF_MVS
  @ i++,nCol say MSG_STK
  AddMrkOption("S")
  AddOption("STK")
#endif
#ifdef DEF_IVT
  @ i++,nCol say MSG_IVT
  AddMrkOption("I")
#endif
#ifdef DEF_ANA
  #ifndef DEF_IMP
    @ i++,nCol say MSG_ANA
    * AddMrkOption("Y")
  #endif
#endif
#ifdef DEF_PRESTO
  @ i++,nCol say MSG_PRESTO
  AddMrkOption("P")
  AddOption("TRM")
#endif
#ifdef DEF_HOLZ
  @ i++,nCol say MSG_HOLZ
  AddMrkOption("H")
  AddOption("STM")
#endif
#ifdef DEF_FIDU
  @ i++,nCol say "Fiduciaires"
  AddMrkOption("D")
#endif
#ifdef DEF_VOC
  @ i++,nCol say  "DEF_VOC"
  AddOption("VOC")
#endif
#ifdef DEF_PRJ
  AddOption("PRJ")
#endif
#ifdef DEF_ODS
  AddOption("ODS")
#endif
#ifdef DEF_DGR
  AddOption("DGR")
#endif
#ifdef DEF_ANA
  AddOption("ANA")
#endif
#ifdef DEF_ALA
  AddOption("ALA")
#endif
#ifdef DEF_ACF
  AddOption("ACF")
#endif
* memodisplay(cStr,5,36,6,39,NIL,NIL,39)
#endif DEF_GUI
RETURN NIL


