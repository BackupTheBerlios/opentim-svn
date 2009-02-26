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

**
** STATIC_SECTION global static variables
**

#ifdef DEF_TRA

**
** TraTrlEdit() -
**
FUNCTION TraTrlEdit()
local b := oTrl()
local cIdDoc := TRA->IdDoc
local cMsg
local nCount := 0
local nMont := 0
local jnl := JnlLocate(TRA->IdJnl)
* local jnl := JnlLocate(SYSJNL_TRA)
RETURN !Warning(TRA->IdJnl + MsgJnlExist()) if jnl == NIL
RETURN .f. if ! ddRecLock()
ddEditChange(.f.)
do while ! AppTerminate()
  open area b, oPar(), oBud()
    softseek TRA->IdJnl + TRA->IdDoc
    edit data b ;
      key TRA->IdJnl+TRL->IdDoc ;
      value    jnl[JNL_IDJNL]+cIdDoc             ;
      create   {||TrlCreate( jnl,cIdDoc )} ;
      start    bottom                 ;
      mode     edit  ;
      query ("TRL" + jnl[JNL_IDDBV]) ;
      title ("Transaktion " + jnl[JNL_IDJNL] + " " + cIdDoc)
  close area
  if TRA->Etat == TRASTAT_CLOSED
    exit
  elseif ddLastkey() == K_F10
    TRA->Etat := TRASTAT_OPEN
    open area b
      softseek TRA->IdJnl+TRA->IdDoc
      do while ! eof() .and. TRL->IdDoc == TRA->IdDoc ;
                       .and. TRL->IdJnl == TRA->IdJnl
        nCount++
        if TRL->DC == jnl[JNL_DC]
          nMont += TrlMont(TRA->IdDev)
        else
          nMont -= TrlMont(TRA->IdDev) // val(TRL->Mont)
        endif
        skip
      enddo
    close area
    TRA->Mont := ntom(nMont,DevDecPos(TRA->IdDev))
    ddRefreshCurrent()
    if nCount == 0
      TRA->Etat := TRASTAT_NEW
    elseif Confirm( ;
      MsgIdJnlDoc() + MsgClose(), NIL, MSG_YES, "WRN011" ;
    )
      if TraDlgClose() // 19980513 != .f.  // siehe auch ImpDlgClose
        commit
        exit
      endif
    else
      exit
    endif
  else
    TRA->Etat := TRASTAT_NEW
    * ddEditChange(.t.)
    exit
  endif
enddo
unlock record
RETURN MnuDone()

FUNCTION TrlMont(cIdDev)
RETURN val(TRL->Mont) if DevDefault(TRL->Periode) == cIdDev
RETURN val(TRL->MontDev) if TRL->IdDev == cIdDev
RETURN Db2Dev(cIdDev,TRL->Periode,val(TRL->Mont))
//  / val(DevCours(cIdDev,TRL->Periode))


FUNCTION TraDlgClose()
local jnl := JnlLocate(TRA->IdJnl)
RETURN !Warning(TRA->IdJnl + MsgJnlExist()) if jnl == NIL
RETURN .f. if ! ddRecLock()
if TRA->Etat == TRASTAT_OPEN
  if TraClose(jnl)
    TRA->Etat := TRASTAT_CLOSED
    ddRefreshCurrent()
    if JNLATTR_I $ jnl[JNL_ATTRIB]
      TraPrint()
    endif
  endif
elseif TRA->Etat == TRASTAT_CLOSED
  if USRATTR_E $ UsrAttrib()
    if Confirm( ;
      "Kassentransaktion entregistrieren.",;
      MsgSure(), MSG_NO,"WRN002" ;
    )
      TRA->Etat := TRASTAT_OPEN
      ddRefreshCurrent()
    endif
  endif
endif
unlock record
RETURN .t. // MnuDone() 19980513


**
** TrlCreate()
**
FUNCTION TrlCreate(jnl,cIdDoc)
local cLine
local nReturn
local nOrder := indexord()
RETURN DDCREATE_FAIL if ! TraPreEdit()
if eof() // 20070801 recno() == lastrec() + 1
  nReturn := DDCREATE_EDIT
else
  nReturn := DDCREATE_REFRESH
endif
ddSetOrder(1)
ddGoBottom(.f.)
cLine  := NextNum(TRL->Line)
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
TRL->IdJnl   := jnl[JNL_IDJNL]
TRL->IdDoc   := cIdDoc
TRL->Line    := cLine
TRL->Periode := PerActive()
TRL->Etat    := TRLSTAT_NEW
// TRL->Date2   := TRA->Date2
* TRL->Match := padr("TRA",LenIdJnl()) + cIdDoc + cLine
dbcommit()
* unlock record 19980430
RETURN nReturn

FUNCTION TrlJnlValidate()
local jnl
if (jnl := JnlLocate(TRL->IdJnl2)) == NIL
  SetMsg(TRL->IdJnl2 + MsgJnlExist())
  RETURN .f.
endif
if ! TrlJnlIsAllowed(TRL->IdJnl,jnl,TRL->DC)
  SetMsg(TRL->IdJnl2 + " : ungÅltiges Journal")
  RETURN .f.
endif
if ! empty(jnl[JNL_IDDEV])
  if jnl[JNL_IDDEV] == DevDefault(TRL->Periode)
    TRL->IdDev   := ""
    TRL->MontDev := ""
  else
    TRL->IdDev   := jnl[JNL_IDDEV]
    RETURN .f. if ! TrlIdDevValidate()
  endif
endif
if empty(TRL->IdDev) .and. TRA->IdDev != DevDefault(TRL->Periode)
  TRL->IdDev := TRA->IdDev
  RETURN .f. if ! TrlIdDevValidate()
endif
if empty(jnl[JNL_IDCDC])
  if empty(TRL->Date2) // 19990729
    TRL->Date2 := TRA->Date2
  endif
else
  TRL->Date2 := ctod("") // wenn es kein ZAU ist
endif
RETURN .t.

FUNCTION MsgTrtExist()
RETURN " : unbekannte Transaktionsart !"

**
** TrlPostEdit()
**
FUNCTION TrlPostEdit()
local jnl
local trt
RETURN .f. if ! ParExist(TrlIdPar())
if !empty(TRL->IdPar2)
  RETURN .f. if ! ParExist(TRL->IdPar2)
endif
if empty(TRL->Compte1)
  TRL->Compte1 := TrlCompte() // PAR->Compte1
endif
RETURN .f. if (jnl := JnlLocate(TRL->IdJnl2)) == NIL
if ! TrlJnlIsAllowed(TRL->IdJnl,jnl,TRL->DC) // JNLATTR_C $ jnl[JNL_ATTRIB]
  SetMsg(TRL->IdJnl2 + " : ungÅltiges Journal")
  RETURN .f.
endif
if empty(TRL->Backmatch) .or. empty(TRL->Match)
  RETURN .f. if empty(TRL->IdTrt)
  if (trt := TrtLocate(TRL->IdTrt)) == NIL
    SetMsg(TRL->IdTrt + MsgTrtExist())
    RETURN .f.
  endif
  * if ! empty(trt[TRT_IDJNL])
  *   RETURN .f. if ! ParExist(TrlIdPar())
  *   if left(PAR->CptSysI,2) != "06" .and. left(PAR->CptSysI,2) != "08"
  *     Warning("System-I-Kontonummer Stammdaten : muss mit 06 oder 08 beginnen !")
  *     RETURN .f.
  *   endif
  * endif
endif
* RETURN .f. if ! PerIsOpen(TRL->Periode,TRL->IdJnl)
RETURN .f. if ! PerDateWarn(TRL->Periode,TRA->Date,jnl)
if abs(val(TRL->Mont)) < 0.001 // Tolerance(DevDecPos(DevDefault(TRL->Periode)))
  SetMsg("Betrag : darf nicht 0 sein !")
  RETURN .f.
endif
if ! empty(jnl[JNL_CODEBQE])
  if empty(TRL->Compte1)
    Warning("Kontonummer : darf nicht leer sein !")
    RETURN .f.
  endif
endif
if JNLATTR_M $ jnl[JNL_ATTRIB]
  if empty(TRL->BackMatch)
    SetMsg("RÅckbezug : erforderlich ! Buchungen mit [F5] Åbernehmen !")
    RETURN .f.
  endif
endif
if empty(jnl[JNL_IDCDC]) // es ist ein ZAU (19990729)
  if empty(TRL->Date2)
    SetMsg("Bei ZAU muss AusfÅhrungsdatum angegeben sein !")
    RETURN .f.
  endif
else
  if !empty(TRL->Date2)
    SetMsg("AusfÅhrungsdatum darf nur bei ZAU angegeben sein !")
    RETURN .f.
  endif
endif
RETURN .t.

FUNCTION TraWait(win)
local jnl := JnlLocate(TRA->IdJnl)
local b := oTrl()
local cIdDoc := TRA->IdDoc
local cIdJnl := TRA->IdJnl
RETURN ClearWaitWin(win) if jnl == NIL
open area b, oPar(), oBud()
  edit data b key TRL->IdJnl+TRL->IdDoc ;
    value    cIdJnl+cIdDoc             ;
    create   {||DDCREATE_FAIL} ;
    start    bottom                 ;
    mode     wait  ;
    window   win ;
    query ("TRL" + jnl[JNL_IDDBV]) ;
    title ("Transaktion " + cIdJnl + " " + cIdDoc)
close area
RETURN NIL

FUNCTION TrlWait(wwin)
local b := oMvi()
// local cIdPar := TrlIdPar()
local cMatch := TRL->Match
open area b, oPar(), oBud(), oImp(), oIml()
  ddSetOrder(ORD_MVI_PARMATCH)
  * edit data b key MVI->IdPar + MVI->Match
  *  value cIdPar + cMatch
  edit data b key MVI->Match ;
    value cMatch ;
    start    top                 ;
    mode     wait  ;
    window   wwin ;
    query    "MVIMAT"
close area
RETURN NIL

FUNCTION TraPreEdit
RETURN .t. if TRA->Etat == TRASTAT_OPEN
RETURN .t. if TRA->Etat == TRASTAT_NEW
SetMsg("Verweigert. Das Dokument ist registriert.")
RETURN .f.

**
**
**
FUNCTION TraPreDelete
local lOkay := .f. // nReturn := DDDEL_FAIL
* local jnl := JnlLocate(padr("TRA",LenIdJnl()))
local jnl := JnlLocate(TRA->IdJnl)
RETURN ! Warning(TRA->IdJnl + MsgJnlExist()) if jnl == NIL
* RETURN .f. if ! Confirm( ;
*   MsgIdJnlDoc() + " : Dokument lîschen (J/N) ?", ;
*   NIL, MSG_NO,"WRN003" ;
* )
RETURN .f. if ! DocDelete(jnl,TRA->IdDoc)
open area oTrl()
  lOkay := .t. // nReturn := DDDEL_NOCONFIRM
  softseek TRA->IdJnl+TRA->IdDoc
  do while !eof() .and. TRL->IdDoc == TRA->IdDoc ;
                  .and. TRL->IdJnl == TRA->IdJnl
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


FUNCTION TraPostEdit()
if ! empty(TRA->IdPar)
  RETURN .f. if ! ParExist(TRA->IdPar)
endif
if TRA->Etat == TRASTAT_NEW
  if nKey != K_ESC // nKey == K_ENTER .or. nKey == K_F10
    TraTrlEdit()
  endif
endif
if TRA->Etat == TRASTAT_NEW
  Warning(MsgIdJnlDoc()+ " : Transaktion nicht fertig eingegeben.")
  RETURN .f. if ! USRATTR_E $ UsrAttrib()
endif
RETURN .t.


FUNCTION TraParValidate()
RETURN .t. if empty(TRA->IdPar)
RETURN .f. if ! ParExist(TRA->IdPar)
RETURN .f. if ! OnParSelect()
if empty(PAR->IdDev)
  TRA->IdDev := DevDefault(PerActive())
else
  TRA->IdDev := PAR->IdDev
endif
RETURN ph_Refresh()


FUNCTION TrlParValidate()
RETURN .f. if ! ParExist(TrlIdPar())
RETURN .f. if ! OnParSelect()
TRL->Compte1 := trlCompte() // PAR->Compte1
RETURN ph_Refresh()

FUNCTION TrlPar2Validate()
if !empty(TRL->IdPar2)
  RETURN .f. if ! ParExist(TRL->IdPar2)
  RETURN .f. if ! OnParSelect()
  TRL->Compte1 := TrlCompte() // PAR->Compte1
endif
RETURN ph_Refresh()

FUNCTION TrlMontValidate()
local nMont := val(TRL->Mont)
TRL->Mont := ntom(nMont,DevDecPos(DevDefault(TRL->Periode)))
RETURN .f. if ! MaxMontConfirm( ;
  TRL->IdJnl, ;
  TRL->IdJnl2, ;
  DevDefault(TRL->Periode), ;
  nMont, ;
  TRL->Periode ;
)
RETURN .t. if empty(TRL->IdDev)
if empty(TRL->IdDev)
  TRL->MontDev := ""
  RETURN .t.
endif
RETURN .f. if ! DevExist(TRL->IdDev)
TRL->MontDev := ntom( ;
  Db2Dev(TRL->IdDev,TRL->Periode,val(TRL->Mont)), ;
  DevDecPos(TRL->IdDev) ;
)
RETURN .t.

FUNCTION TrlIdDevValidate()
if empty(TRL->IdDev)
  TRL->MontDev := ""
else
  TRL->MontDev := ntom( ;
    Db2Dev(TRL->IdDev,TRL->Periode,val(TRL->Mont)), ;
    DevDecPos(TRL->IdDev) ;
  )
endif
RETURN .t.

FUNCTION TrlDevValidate()
local dev := DevLocate(TRL->IdDev,TRL->Periode)
RETURN .f. if dev == NIL
TRL->Mont := ntom( ;
  Dev2Db(TRL->IdDev,TRL->Periode,val(TRL->MontDev)), ;
  DevDecPos(DevDefault(TRL->Periode)) ;
)
TRL->MontDev := ntom(val(TRL->MontDev),dev[DEV_DECPOS])
RETURN .f. if ! MaxMontConfirm( ;
  TRL->IdJnl, ;
  TRL->IdJnl2, ;
  TRL->IdDev, ;
  val(TRL->MontDev), ;
  TRL->Periode ;
)
RETURN .t.


**
** TrlCopy()
**
FUNCTION TrlCopy()
local aLn
local aTag
local cIdDoc := TRA->IdDoc
local cIdJnl := TRA->IdJnl
local b := oTrl()
local i
local jnlDest
* local cIdJnl
* local cFltText := ""
RETURN MnuDone() if ! TraPreEdit()
RETURN !Warning("öbernehmen : nur in TRA !") if empty(TRA->IdPar)
if ddRecStat() == RS_INVALID
  Warning("Lîschen Sie zuerst den aktuellen Record !")
  RETURN MnuDone()
endif
jnlDest := PickJnl( ;
  "IMP", ;
  NIL, ;
  JnlList({|jnl| TrlJnlIsAllowed(TRA->IdJnl,jnl)}) ;
)
RETURN NIL if jnlDest == NIL
MviSetFilter( ;
  BUTTON_ON, JnlList({|jnl| JnlSatisfies(jnl,jnlDest)}), ;
  space(LEN_IDGRJ),space(LenIdJnl()), ;
  space(LenIdDoc()), space(LenIdDoc()), ;
  " ", NIL, ;
  space(LEN_PERIODE), ;
  TRA->IdPar, BUTTON_ON ;
)
RETURN .f. if (aLn := MviLnCollect( ;
  {|| PerDateWarn(MVI->Periode,TRA->Date,jnlDest) }, ;
  .f. ;
) ) == NIL
RETURN .f. if len(aLn) == 0
TrlGenerate(aLn,jnlDest[JNL_IDJNL],cIdJnl,cIdDoc)
ddSetUpdated(.t.) // b[AD_UPDATED] := .t.
ddGoBottom(.t.)
RETURN MnuDone()


FUNCTION TraStorn
static scStart := NIL
local b := oTrl()
open area b, oPar(), oTra()
  if scStart != NIL .and. left(scStart,LenIdJnl()) == TraEditJnl()
    seek scStart
  else
    softseek TraEditJnl()
  endif
  do while ! AppTerminate()
    edit data b query "TRLPICK" ;
                key TRL->IdJnl value TraEditJnl() ;
                mode pick ;
                create {||DDCREATE_FAIL} ;
                preedit .f. ;
                filter "TRL->Etat != '" + TRLSTAT_CTL +"'" ;
                title "Nichtzentralisierte Buchung stornieren"
    if ddLastKey() == K_ENTER
      scStart := TRL->IdJnl + TRL->IdDoc + TRL->Line
      if ddRecLock()
        if TRL->Etat == TRLSTAT_NEW
          TRL->Etat := TRLSTAT_STORNIERT
        elseif TRL->Etat == TRLSTAT_STORNIERT
          TRL->Etat := TRLSTAT_NEW
        endif
        unlock record
      endif
    else
      exit
    endif
  enddo
close area
RETURN MnuDone()

#define CTL_JNL     1
#define CTL_PERIODE 2
#define CTL_DC      3
#define CTL_IDBUD   4
#define CTL_IDPAR   5
#define CTL_AIML    6
#define CTL_IDDOC   7
#define CTL_OKAY    8
#define CTL_SYSI    9
#define CTL_DATE2  10 // AusfÅhrungsdatum des ZAU, 19990729
#define CTL_ALEN   10

FUNCTION TrlIdPar()
RETURN TRA->IdPar if empty(TRL->IdPar)
RETURN TRL->IdPar


**
** TraCentral() - die Kassenzentralisierung
**
FUNCTION TraCentral(cIdJnl,lDoIt,cTitle,cLstTitle,xlTrlFilter,lTrtDocs)
local cPreview := SetPreview()
local cTplIni := SetTplIni()
local cRj
local aMaxMont := {}
* local cTitle := "Kasse zentralisieren"
local cTit1
local cTit2
local lWarning := .f.
local aCtl := {}
local lOkay := .f.
* local cIdJnl
local nJnlSum := 0
local i
local j
local cHeader
local aCtb
local aLines := {}
local aImlSuite
local cIdDoc
local cLine
local lFirst
local cIdPar
local nCount := 0
* local nKasSumme := 0
local fd
local cEaMatch
local cIdDev
local nDecPos
local cErrorLog := DbPath()+"\"+trim(cIdJnl)+"CTL.ERR"
default xlTrlFilter to ".t."
default lTrtDocs to .t.
MsgDisplay(cTitle + " : Vorlauf...")
open area oTra(), oPar()
  lOkay := .t.
  softseek cIdJnl
  do while lOkay .and. ! eof() .and. TRA->IdJnl == cIdJnl
    MsgDisp2(ntrim0(nCount++ / lastrec() * 100) + "%")
    if TRA->Etat == TRASTAT_CLOSED
      lOkay := .f.
      open area oTrl()
        lOkay := .t.
        softseek TRA->IdJnl + TRA->IdDoc
        do while lOkay .and. ! eof() .and. TRL->IdDoc == TRA->IdDoc ;
                                     .and. TRL->IdJnl == TRA->IdJnl
          if TRL->Etat == TRLSTAT_NEW
            if &xlTrlFilter
              ** Ctl2Collect() kommt vor CtlCollect(), weil sie den
              ** EaMatch ermittelt, der fÅr die eigentliche Buchung
              ** verwendet wird.
              cEaMatch := Ctl2Collect(aCtl)
              if ! CtlCollect(aCtl,cEaMatch,lTrtDocs)
                lOkay := .f.
              endif
            endif
          endif
          skip
        enddo
      close area
    elseif TRA->Etat == TRASTAT_NEW
      lOkay := Confirm( ;
        MsgIdJnlDoc() + " : Dokument ist nicht registriert.", ;
        MsgContinue(), MSG_NO, "TRACTL02",NIL,cTitle ;
      )
    else
      Warning( ;
        MsgIdJnlDoc() + " : ungÅltiger Status !", ;
        NIL, "TRACTL03" ;
      )
      lOkay := .f.
    endif
    skip
  enddo
close area
if ! lOkay
  Warning( ;
    cTitle + " : Fehler beim Vorlauf.", ;
    "Fehlerursache beheben und neu starten !", "TRACTL04" ;
  )
  RETURN .f.
endif
asort(aCtl,,,{|x,y| x[CTL_JNL][JNL_IDJNL] <= y[CTL_JNL][JNL_IDJNL]})
if lDoIt // == BUTTON_ON
  cHeader := "DEFINITIVER AUSDRUCK"
  SendConsole(trim(UserId()) + " zentralisiert "+ntrim(len(aCtl))+" Buchungen (" + cTitle + ")")
  MsgDisplay(cTitle + " : " + MsgWorking())
  open area oImp(), oIml()
    for j := 1 to 2
      for i := 1 to len(aCtl)
        if (j == 2 .and. aCtl[i][CTL_SYSI]) ;
           .or. (j == 1 .and. ! aCtl[i][CTL_SYSI])
          ** Bei SYSI oder ZCD zuerst nachschauen, ob die entsprechende
          ** TRE-Buchung okay ist.
          aImlSuite := {}
          aCtb      := {}
          if empty(aCtl[i][CTL_DATE2])
            aCtl[i][CTL_DATE2] := UserDate()
          endif
          if DocCreate(aCtl[i][CTL_JNL], ;
            {|x| cIdDoc := x, ;
            ImpAppend( ;
              aCtl[i][CTL_JNL],x,aCtl[i][CTL_AIML],aCtb, ;
              aCtl[i][CTL_PERIODE], ;
              UserDate(), aCtl[i][CTL_DATE2], aImlSuite, ;
              aLines ;
            ) ;
          } ) != DDCREATE_DONE
            aCtl[i][CTL_IDDOC] := aCtl[i][CTL_JNL][JNL_IDJNL] + " : ImpAppend() failed"
            lOkay := .f.
          * elseif ! CtlGenSuite(aCtl[i],aImlSuite,aCtb,aLines)
          elseif ! ImpGenSuite(aImlSuite, aCtb, ;
            aCtl[i][CTL_PERIODE], UserDate(), ;
            aLines)
            aCtl[i][CTL_IDDOC] := aCtl[i][CTL_JNL][JNL_IDJNL] + " : CtlGenSuite() failed"
            lOkay := .f.
          * elseif ! TrlSetEtat(aCtl[i][CTL_JNL],cIdDoc,aLines)
          *   aCtl[i][CTL_IDDOC] := cIdDoc
          *   lOkay := .f.
          else
            aCtl[i][CTL_IDDOC] := cIdDoc
            aCtl[i][CTL_OKAY]  := .t.
            RptWrite("ImpAppend " + aCtl[i][CTL_JNL][JNL_IDJNL] + cIdDoc + " : okay")
          endif
          if ! CtbUpdate(aCtb)
            aadd(aLines, ;
              aCtl[i][CTL_JNL][JNL_IDJNL] +  " " + aCtl[i][CTL_IDDOC] ;
              + " : CtbUpdate() failed !" ;
            )
          endif
        endif
      next i
      if j == 1 .and. ! lOkay
        aadd(aLines,"System-I-Dokumente wurden NICHT generiert !")
        exit
      endif
    next j
  close area
  * if ! lOkay
  *   RlbAbort()
  *   RETURN .f.
  * endif
else
  cHeader := "(Provisorischer Ausdruck)"
endif
cTit1 := padr("Tra.Nr",LenIdDoc()+LenIdJnl()+1)
cTit2 := repl("ƒ",LenIdDoc()+LenIdJnl()+1)
cTit1 += " " + padr("Datum",len(dtoc(UserDate())))
cTit2 += " " + repl("ƒ",len(dtoc(UserDate())))
cTit1 += " " + padr("Partner",25)
cTit2 += " " + repl("ƒ",25)
cTit1 += " " + padr("Jnl",LenIdJnl())
cTit2 += " " + repl("ƒ",LenIdJnl())
cTit1 += " " + padr("Artikel",18)
cTit2 += " " + repl("ƒ",18)
cTit1 += " " + padr("Einnahmen",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
cTit1 += " " + padr("Ausgaben",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
cTit1 += " " + padr("Betrag FW",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
cTit1 += " " + padr("FW",LEN_IDDEV)
cTit2 += " " + repl("ƒ",LEN_IDDEV)
cTit1 += " " + padr("Scheck",6)
cTit2 += " " + repl("ƒ",6)
cTit1 += " " + padr("P",1)
cTit2 += " " + repl("ƒ",1)
cTit1 += " " + padr("Dok.Nr",8)
cTit2 += " " + repl("ƒ",8)
if cLstTitle != NIL
  open printer (cTplIni) ;
       preview (cPreview) ;
       width len(cTit2) ;
       titblock {|| PrintHeader(cLstTitle,cHeader), ;
         PrintLine(cTit1), ;
         PrintLine(cTit2)  ;
       }
endif
open area oTra(), oPar(), oBud()
  softseek cIdJnl
  do while ! eof() .and. TRA->IdJnl == cIdJnl
    if TRA->Etat == TRASTAT_CLOSED
      SetDevise(TRA->IdDev)
      lFirst := .t. // first line of document
      cIdPar := NIL
      open area oTrl()
        softseek TRA->IdJnl + TRA->IdDoc
        do while ! eof() .and. TRL->IdDoc == TRA->IdDoc ;
                         .and. TRL->IdJnl == TRA->IdJnl
          if TRL->Etat != TRLSTAT_CTL ;
            .and. TRL->Etat != TRLSTAT_CTL_STORNIERT
            cLine := ""
            if lFirst
              cLine := TRA->IdJnl + " " + TRA->IdDoc
              cLine += " " + dtoc(TRA->Date)
              lFirst := .f.
              PrintLine()
            else
              cLine := space(LenIdDoc()+LenIdJnl()+1+len(dtoc(UserDate()))+1)
            endif
            if cIdPar != TrlIdPar()
              cLine += " " + TrlIdPar()
              cLine += " " + trim(ParName(TrlIdPar()))
              cIdPar := TrlIdPar()
            endif
            if !empty(cLine)
              PrintLine("{I}" + cLine + "{i}")
            endif
            cLine := space(LenIdDoc()+LenIdJnl()+1)
            cLine += " " + padr( ;
              TRL->Periode + " " + TRL->IdPar2 + " " + ;
              ParField(TRL->IdPar2,{||PAR->Firme}),34 ;
            )
            cLine += " " + TRL->IdJnl2
            cLine += " " + SayIdBud(TRL->IdBud)
            if TRL->DC == DC_DEBIT
              cLine += " " + space(LenMntF())
              cLine += " " + ntomf(val(TRL->Mont),DevDecPos(DevDefault(TRL->Periode)))
            else
              cLine += " " + ntomf(val(TRL->Mont),DevDecPos(DevDefault(TRL->Periode)))
              cLine += " " + space(LenMntF())
            endif
            cLine += " " + ntomf(val(TRL->MontDev),DevDecPos(TRL->IdDev))
            cLine += " " + TRL->IdDev
            if TplExist(TPLTYPE_TRL,TRL->IdJnl2)
              cLine += " " + space(len(TRA->Scheck))
            else
              cLine += " " + TRA->Scheck
            endif
            cLine += " " + TRL->Attrib
            if TRL->Etat == TRLSTAT_STORNIERT
              cLine += " " + padr("STORNIERT",8)
              if ddRecLock()
                TRL->Etat := TRLSTAT_CTL_STORNIERT
                unlock record
              else
                SendHotline( ;
                  ntrim(recno()) + " : reclock() failed : Status " + ;
                  TRLSTAT_CTL_STORNIERT ;
                )
              endif
            else
              if &xlTrlFilter
                if lDoIt
                  for i := 1 to len(aCtl)
                    if aCtl[i][CTL_PERIODE] == TRL->Periode
                      if aCtl[i][CTL_JNL][JNL_IDJNL] == TRL->IdJnl2
                        if empty(TRL->Date2) .or. TRL->Date2 == aCtl[i][CTL_DATE2]
                          if aCtl[i][CTL_OKAY]
                            cLine += " " + aCtl[i][CTL_IDDOC]
                            if ddRecLock()
                              TRL->Etat  := TRLSTAT_CTL
                              TRL->IdImp := aCtl[i][CTL_IDDOC]
                              unlock record
                            else
                              SendHotline( ;
                                ntrim(recno()) + ;
                                " : reclock() failed : Etat=" + TRLSTAT_CTL ;
                                + ", IdImp=" + aCtl[i][CTL_IDDOC] ;
                              )
                              lOkay := .f.
                            endif
                          else
                            * cLine += " " + aCtl[i][CTL_IDDOC]
                            * [960813] cLine += " " + padr("PROBLEM",LenIdDoc())
                            cLine += " " + padr("PROBLEM",LenIdDoc())
                          endif
                        endif
                      endif
                    endif
                  next i
                endif
              else
                cLine += " " + dtoc(TRL->Date2) // "WAITING"
              endif
              if MaxMontOverflow( ;
                TRL->IdJnl,TRL->IdJnl2,;
                DevDefault(TRL->Periode),;
                val(TRL->Mont),;
                TRL->Periode;
              )
                aadd(aMaxMont, ;
                  TRL->IdDoc + " : " ;
                  + ltrim(TRL->Mont) + " " + DevDefault(TRL->Periode) ;
                )
              endif
            endif
            PrintLine(cLine)
            if TRL->Etat == TRLSTAT_CTL
              seek TRL->DC + TRL->IdBud in BUD
              // 20000511 if ! BUDATTR_T $ BUD->Attrib
              cRj := PerPerCtr(TRL->Periode)
              if ! BudIsTolerant(cRj)
                if BudAvail( ;
                  TRL->DC,TRL->IdBud,;
                  cRj, MemIdCdc ;
                ) < 0
                  cLine := space(LenIdDoc())
                  cLine += " *** " + TRL->DC + "-" + trim(SayIdBud(TRL->IdBud))
                  cLine += " : KreditÅberschreitung !"
                  PrintLine("{B}"+cLine+"{b}")
                  SendConsole(cLine)
                  lWarning := .t.
                endif
              endif
            endif
            *if ! empty(TRL->IdPar2)
            *  cLine := space(LenIdDoc() + 40)
            *  cLine += " " + padr(ParName(TRL->IdPar2),30)
            *  PrintLine(cLine)
            *endif
          endif
          skip
        enddo
      close area
    endif
    skip
  enddo
close area
if cLstTitle != NIL
  PrintLine()
  PrintLine("Kontroll-Liste :")
  cLine := padr("Jnl",LenIdJnl())
  cLine += " " + padr("Per.",LEN_PERIODE)
  cLine += " " + padr("Dok.Nr",LenIdDoc())
  cLine += " " + padl("Alter Saldo",LenMntF())
  cLine += " " + padl("Bewegungen",LenMntF())
  cLine += " " + padl("Neuer Saldo",LenMntF())
  cLine += " " + padl("WÑ",LEN_IDDEV)
  cLine += " " + padr("Bemerkungen",20)
  PrintLine(cLine)
  cLine := repl("ƒ",LenIdJnl())
  cLine += " " + repl("ƒ",LEN_PERIODE)
  cLine += " " + repl("ƒ",LenIdDoc())
  cLine += " " + repl("ƒ",LenMntF())
  cLine += " " + repl("ƒ",LenMntF())
  cLine += " " + repl("ƒ",LenMntF())
  cLine += " " + repl("ƒ",LEN_IDDEV)
  cLine += " " + repl("ƒ",20)
  PrintLine(cLine)
  open area oImp()
    cIdJnl := NIL
    cIdDev := NIL
    for i := 1 to len(aCtl)
      ** start new 19981216
      if empty(aCtl[i][CTL_JNL][JNL_IDDEV])
        * cIdDev := DevDefault(aCtl[i][CTL_PERIODE])
        SetDevise(DevDefault(aCtl[i][CTL_PERIODE]))
      else
        * cIdDev := aCtl[i][CTL_JNL][JNL_IDDEV]
        SetDevise(aCtl[i][CTL_JNL][JNL_IDDEV])
      endif
      * nDecPos := DevDecPos(cIdDev)
      ** stop new 19981216
      if cIdJnl == aCtl[i][CTL_JNL][JNL_IDJNL] .and. SetDevise() == cIdDev
        cLine := space(LenIdJnl())
        * 20011121 cLine += " " + cIdDev
      else
        ** ! code repeated below !
        if cIdJnl != NIL
          cLine := space(LenIdJnl())
          cLine += " " + padr("Summe", LEN_PERIODE + 1 + LenIdDoc())
          cLine += " " + space(LenMntF())
          cLine += " " + space(LenMntF())
          cLine += " " + space(LenMntF())
          cLine += " " + cIdDev
          * cLine += " " + ntomf(nJnlSum,nDecPos)
          PrintLine(cLine)
          SendConsole(cLine)
        endif
        ** end of code repeated below
        nJnlSum := 0
        cIdJnl  := aCtl[i][CTL_JNL][JNL_IDJNL]
        cIdDev := SetDevise()
        cLine := aCtl[i][CTL_JNL][JNL_IDJNL]
      endif
      cLine += " " + aCtl[i][CTL_PERIODE]
      cLine += " " + aCtl[i][CTL_IDDOC]
      if aCtl[i][CTL_OKAY]
        seek aCtl[i][CTL_JNL][JNL_IDJNL] + aCtl[i][CTL_IDDOC]
        if JNLATTR_S $ aCtl[i][CTL_JNL][JNL_ATTRIB]
          cLine += " " + ntomf(val(IMP->Mont1)) // ,nDecPos)
          cLine += " " + ntomf(val(IMP->Mont2) - val(IMP->Mont1)) // ,nDecPos)
          cLine += " " + ntomf(val(IMP->Mont2)) // ,nDecPos)
          cLine += " " + cIdDev
        elseif ! JNLATTR_E $ aCtl[i][CTL_JNL][JNL_ATTRIB]
          cLine += " " + space(LenMntF())
          cLine += " " + ntomf(val(IMP->Mont2)) // ,nDecPos)
          cLine += " " + space(LenMntF())
          cLine += " " + cIdDev
        else
          cLine += " " + space(LenMntF())
          cLine += " " + space(LenMntF())
          cLine += " " + space(LenMntF())
          cLine += " " + cIdDev
        endif
        cLine += " " + ntrim(len(aCtl[i][CTL_AIML])) + " Buchung(en)."
        * nJnlSum += Db2Dev(cIdDev,aCtl[i][CTL_PERIODE],val(IMP->Mont2))
        * nJnlSum -= Db2Dev(cIdDev,aCtl[i][CTL_PERIODE],val(IMP->Mont1))
        nJnlSum += val(IMP->Mont2)
        nJnlSum -= val(IMP->Mont1)
      else
        cLine := "{B}" + cLine + "{b}"
      endif
      PrintLine(cLine)
      SendConsole(cLine)
    next i
    ** ! code repeated above !
    if cIdJnl != NIL
      cLine := space(LenIdJnl())
      cLine += " " + padr("Summe", LEN_PERIODE + 1 + LenIdDoc())
      cLine += " " + space(LenMntF())
      cLine += " " + ntomf(nJnlSum) // ,nDecPos)
      cLine += " " + space(LenMntF())
      cLine += " " + cIdDev
      PrintLine(cLine)
      SendConsole(cLine)
      ** Spezialcode
      * if cIdJnl == "KAS "
      *   nKasSumme := nJnlSum
      * endif
    endif
    ** end of code repeated below
  close area
  cLine := ntrim(len(aCtl)) + " Dokumente wurden erstellt"
  PrintLine(cLine)
  SendConsole(cLine)
  if len(aMaxMont) > 0
    PrintLine()
    PrintLine("Buchungen mit erstaunlich gro·em Betrag :")
    for i := 1 to len(aMaxMont)
      PrintLine(aMaxMont[i])
    next i
  endif
endif
if len(aLines) > 0
  if (fd := fcreate(cErrorLog)) == -1
    aadd(aLines, cErrorLog + MsgDosError(ferror()))
  else
    aadd(aLines, cErrorLog + " wurde erstellt")
  endif
  cLine := "Fehlermeldungen :"
  if cLstTitle != NIL
    PrintLine()
    PrintLine("{B}"+cLine+"{b}")
  endif
  SendConsole(cLine)
  for i := 1 to len(aLines)
    if cLstTitle != NIL
      PrintLine("{B}"+aLines[i]+"{b}")
    endif
    SendConsole(aLines[i])
    fwrite(fd,dtoc(UserDate()) + " " + aLines[i] + CR_LF)
  next i
  fclose(fd)
endif
if cLstTitle != NIL
  PrintLine()
  PrintLine()
  PrintLine()
  * PrintLine("Alter Kassensaldo = " + ntomf(MemSaldo))
  * PrintLine("       Bewegungen = " + ntomf(nKasSumme))
  *if lDoIt // == BUTTON_ON
  *  MemSaldo += nKasSumme
  *  PrintLine("Neuer Kassensaldo = " + ntomf(MemSaldo))
  *  AppSaveMem()
  *endif
  close printer
endif
if lWarning
  Warning("ACHTUNG : KREDITöBERSCHREITUNG(EN) !")
endif
RETURN lOkay

STATIC FUNCTION CtlCollect(aCtl,cEaMatch,lTrtDocs)
local i
local jnl := JnlLocate(TRL->IdJnl2)
local ctl := NIL
local iml
local trt
RETURN !SetMsg(TRL->IdJnl2+MsgJnlExist()) if jnl == NIL
if !empty(TRL->IdTrt)
  trt := TrtLocate(TRL->IdTrt)
  RETURN !SetMsg(TRL->IdTrt+MsgTrtExist()) if trt == NIL
  if lTrtDocs .and. !empty(trt[TRT_IDTPL])
     RETURN .f. if ! PrintTemplate(TPLTYPE_TRL,trt[TRT_IDTPL],BUTTON_OFF)
  endif
endif
for i := 1 to len(aCtl)
  if aCtl[i][CTL_JNL][JNL_IDJNL] == TRL->IdJnl2
    if aCtl[i][CTL_PERIODE] == TRL->Periode
      if (TRL->DC == aCtl[i][CTL_DC] ;
         .and. TRL->IdBud == aCtl[i][CTL_IDBUD]) ;
         .or. ! JNLATTR_B $ jnl[JNL_ATTRIB]
        if TrlIdPar() == aCtl[i][CTL_IDPAR] ;
          .or. ! JNLATTR_P $ jnl[JNL_ATTRIB]
          * if 20030813 empty(TRL->Date2) .or. TRL->Date2 == aCtl[i][CTL_DATE2]
          if TRL->Date2 == aCtl[i][CTL_DATE2]
            ctl := aCtl[i]
          endif
        endif
      endif
    endif
  endif
next i
if ctl == NIL
  ctl := array(CTL_ALEN)
  ctl[CTL_PERIODE] := TRL->Periode
  ctl[CTL_JNL]     := jnl // TRL->IdJnl
  ctl[CTL_AIML]    := {}
  ctl[CTL_OKAY]    := .f.
  ctl[CTL_SYSI]    := .f.
  ctl[CTL_IDDOC]   := "(nicht erstellt)"
  if JNLATTR_B $ jnl[JNL_ATTRIB]
    ctl[CTL_DC]      := TRL->DC
    ctl[CTL_IDBUD]   := TRL->IdBud
  else
    ctl[CTL_DC]      := NIL
    ctl[CTL_IDBUD]   := NIL
  endif
  if JNLATTR_P $ jnl[JNL_ATTRIB]
    ctl[CTL_IDPAR]   := TrlIdPar()
  else
    ctl[CTL_IDPAR]   := NIL
  endif
  ctl[CTL_DATE2]   := TRL->Date2
  aadd(aCtl, ctl)
endif
iml := array(IML_ALEN)
iml[IML_IDPAR    ] := TrlIdPar()
* iml[IML_NB1      ] := TRL->NB1 [960423]
iml[IML_NB1      ] := "[" + TRL->IdJnl + " " + TRL->IdDoc + "] " + TRL->NB1
iml[IML_DATE     ] := UserDate() // TRA->Date
iml[IML_DC       ] := TRL->DC
iml[IML_IDBUD    ] := TRL->IdBud
iml[IML_MATCH    ] := TRL->Match
iml[IML_EAMATCH  ] := cEaMatch
iml[IML_IDPAR2   ] := TRL->IdPar2
iml[IML_IDPRJ    ] := ""
// iml[IML_JNL      ] := ""
iml[IML_NB2      ] := TRL->NB2
iml[IML_COMPTE1  ] := TRL->Compte1
iml[IML_MONT     ] := TRL->Mont
iml[IML_MONTDEV  ] := TRL->MontDev
iml[IML_BACKMATCH] := TRL->BackMatch // "TRA" + TRL->IdDoc + TRL->Line
aadd(ctl[CTL_AIML],iml)
RETURN .t.


** sammelt nur die Folgebuchungen (wenn TRT->IdJnl unleer ist)
STATIC FUNCTION Ctl2Collect(aCtl)
local i
local trt := TrtLocate(TRL->IdTrt)
local jnl
local ctl := NIL
local iml := NIL
RETURN "" if trt == NIL
jnl := JnlLocate(trt[TRT_IDJNL])
RETURN "" if jnl == NIL
for i := 1 to len(aCtl)
  if aCtl[i][CTL_JNL][JNL_IDJNL] == jnl[JNL_IDJNL]
    if aCtl[i][CTL_PERIODE] == TRL->Periode
      // test 20060127
      *if (TRL->DC == aCtl[i][CTL_DC] ;
      *   .and. TRL->IdBud == aCtl[i][CTL_IDBUD]) ;
      *   .or. ! JNLATTR_B $ jnl[JNL_ATTRIB]
      *  if TrlIdPar() == aCtl[i][CTL_IDPAR] ;
      *    .or. ! JNLATTR_P $ jnl[JNL_ATTRIB]
      // end test 20060127
          if TRL->Date2 == aCtl[i][CTL_DATE2]
            ctl := aCtl[i]
          endif
      *   endif
      * endif
    endif
  endif
next i
if ctl == NIL
  ctl := array(CTL_ALEN)
  ctl[CTL_PERIODE] := TRL->Periode
  ctl[CTL_JNL]     := jnl
  ctl[CTL_AIML]    := {}
  ctl[CTL_OKAY]    := .f.
  ctl[CTL_SYSI]    := .t.
  ctl[CTL_IDDOC]   := "(nicht erstellt)"
  ctl[CTL_DC]      := NIL
  ctl[CTL_IDBUD]   := NIL
  ctl[CTL_IDPAR]   := NIL
  aadd(aCtl, ctl)
  ctl[CTL_DATE2]   := TRL->Date2
endif
for i := 1 to len(ctl[CTL_AIML])
  if ctl[CTL_AIML][i][IML_IDPAR] == TrlIdPar()
    if empty(ctl[CTL_AIML][i][IML_IDPAR2]) // [971015]
      iml := ctl[CTL_AIML][i]
      iml[IML_NB1] += "[" + TRL->IdJnl + " " + TRL->IdDoc + "] "
    endif
  endif
next i
if iml == NIL
  seek TrlIdPar() in PAR
  iml := array(IML_ALEN)
  iml[IML_IDPAR    ] := TrlIdPar()
  * iml[IML_NB1      ] := TRL->NB1 [960423]
  iml[IML_NB1      ] := "[" + TRL->IdJnl + " " + TRL->IdDoc + "] "
  iml[IML_DATE     ] := UserDate() // TRA->Date
  iml[IML_DC       ] := DcInvert(TRL->DC)
  * iml[IML_IDBUD    ] := TRL->IdBud
  iml[IML_IDBUD    ] := trt[TRT_IDBUDI]
  iml[IML_MATCH    ] := TRL->Match
  iml[IML_IDPAR2   ] := "" // TRL->IdPar2 [960514]
  iml[IML_IDPRJ    ] := ""
  // iml[IML_IDJNL    ] := ""
  iml[IML_NB2      ] := "[" + TRL->IdDoc + "] " + TRL->NB2
  * iml[IML_COMPTE1  ] := PAR->Compte1 // [960605] TRL->Compte1
  iml[IML_COMPTE1  ] := PAR->CptSysi // 19990611 am Telefon
  * iml[IML_COMPTE1  ] := TrlCompte() // 20000209
  iml[IML_MONT     ] := TRL->Mont
  iml[IML_MONTDEV  ] := TRL->MontDev  // 20011221
  iml[IML_BACKMATCH] := TRL->BackMatch // "TRA" + TRL->IdDoc + TRL->Line
  iml[IML_EAMATCH]   := TRL->IdDoc + jnl[JNL_IDJNL]
  aadd(ctl[CTL_AIML],iml)
else
  iml[IML_NB1      ] := trim1(iml[IML_NB1]) + "[" + TRL->IdDoc + "] " + TRL->NB1
  iml[IML_NB2      ] := trim1(iml[IML_NB2]) + "[" + TRL->IdDoc + "] " + TRL->NB2
  iml[IML_MONT     ] := ntom( ;
    val(iml[IML_MONT]) + val(TRL->Mont),;
    DevDecPos(DevDefault(TRL->Periode));
  )
  iml[IML_MONTDEV  ] := ntom( ;
    val(iml[IML_MONTDEV]) + val(TRL->MontDev),;
    DevDecPos(TRL->IdDev);
  )
  // 20011221
endif
RETURN iml[IML_EAMATCH]


FUNCTION TrlPerValidate()
RETURN .f. if ! PerExist(TRL->Periode)
RETURN .t. if empty(TRL->Mont+TRL->MontDev)
if MntDecPos(TRL->Mont) != DevDecPos(DevDefault(TRL->Periode))
  RETURN .f. if ! Confirm( ;
    "Neue GrundwÑhrung. BetrÑge mÅssen neu eingegeben werden", MsgSure();
  )
  TRL->Mont := ""
  TRL->MontDev := ""
endif
RETURN .t.

FUNCTION c20031020
local lContinue := .t.
local fd := fcreate("20031020.txt")
local cLine
RETURN .f. if ! Confirm("Datenreparatur 20031020 starten (J/N) ?")
ddCloseAll()
fwrite(fd,"Datenreparatur 20031020 gestartet am "+dtoc(date())+" um "+time()+CR_LF)
open area oTra(),oTrl(),oMvi(), oIml(), oJnl() exclusive
  MsgDisplay("TRA...")
  select TRA
  softseek "TRA 00"
  do while ! eof() .and. FIELD->IdJnl == "TRA ".and.left(FIELD->IdDoc,2) == "00"
    cLine := trim(alias())+chr(9)+ntrim(recno())+chr(9)+FIELD->IdDoc
    FIELD->IdDoc := "06" + right(FIELD->IdDoc,4)
    cLine += chr(9)+FIELD->IdDoc
    fwrite(fd,cLine+CR_LF)
    softseek "TRA 00"
  enddo
  MsgDisplay("TRL...")
  select TRL
  softseek "TRA 00"
  do while ! eof() .and. FIELD->IdJnl == "TRA ".and.left(FIELD->IdDoc,2) == "00"
    cLine := trim(alias())+chr(9)+ntrim(recno())+chr(9)+FIELD->IdDoc
    FIELD->IdDoc := "06" + right(FIELD->IdDoc,4)
    cLine += chr(9)+FIELD->IdDoc
    fwrite(fd,cLine+CR_LF)
    softseek "TRA 00"
  enddo
  MsgDisplay("MVI...")
  select MVI
  ddSetOrder(0)
  go top
  do while ! eof()
    * if left(FIELD->EaMatch,2) == "00" .and. right(FIELD->EaMatch,4) == "TRA "
    if left(FIELD->EaMatch,2) == "00"
      cLine := trim(alias())+chr(9)+ntrim(recno())+chr(9)+FIELD->EaMatch
      FIELD->EaMatch := "06" + substr(FIELD->EaMatch,3)
      cLine += chr(9)+FIELD->EaMatch
      fwrite(fd,cLine+CR_LF)
    endif
    skip
  enddo
  MsgDisplay("IML...")
  select IML
  ddSetOrder(0)
  go top
  do while ! eof()
    if left(FIELD->EaMatch,2) == "00"
      cLine := trim(alias())+chr(9)+ntrim(recno())+chr(9)+FIELD->EaMatch
      FIELD->EaMatch := "06" + substr(FIELD->EaMatch,3)
      cLine += chr(9)+FIELD->EaMatch
      fwrite(fd,cLine+CR_LF)
    endif
    skip
  enddo
  select JNL
  seek "TRA "
  open area oTra()
    KeyGoBottom(JNL->IdJnl,"TRA->IdJnl")
    JNL->IdDoc := TRA->IdDoc
  close area
  *ddSetOrder ORD_MVI_EAMATCH
  *softseek "00"
  *do while lContinue
  *  * ! eof() .and. left(FIELD->EaMatch,2) == "00"
  *  * lFound := .f.
  *  do while ! eof() .and. left(FIELD->EaMatch,2) == "00" ;
  *     .and. right(FIELD->EaMatch,4) != "TRA "
  *     skip
  *  enddo
  *  if ! eof() .and. left(FIELD->EaMatch,2) == "00" ;
  *    lFound := .t.
  *    if right(FIELD->EaMatch,4) != "TRA "
  *      raise "oops! das kann nicht sein!"
  *    endif
  *    FIELD->EaMatch := "06" + substr(FIELD->EaMatch,3)
  *  else
  *    exit
  *  endif
  *  softseek "00"
  *  skip
  *enddo
close area
fclose(fd)
RETURN .t.

#endif DEF_TRA

FUNCTION MsgDocExist()
#ifdef LG_GERMAN
RETURN " : Dokumentnummer ist bereits vergeben !"
#endif
#ifdef LG_FRENCH
RETURN " : ce n¯ de document est dÇjÖ utilisÇ !"
#endif
#ifdef LG_EN
RETURN " : document id already being used !"
#endif

