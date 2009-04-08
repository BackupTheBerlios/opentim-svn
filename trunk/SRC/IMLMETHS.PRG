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

#ifdef DEF_IMP
  // ImpImlInit()
  static saJnl
  static saDev
  static snCours
  static snMont  := 0       // neuer Saldo (GW)
  static snMontDev  := 0    // neuer Saldo (FW)
  * static snMont2  := 0
  static snImlCount := 0    // Anzahl Buchungen
  * static saImpJnl := NIL


  * LstHaushalt()
  * static scIdCdc

#endif DEF_IMP

**
** MSG_SECTION    MSGnnn definitions
**
  static MSG_ABBRECHEN := " : Eingabe abbrechen (J/N) ?"

**
** PROCEDURE_SECTION  - (...grins)
**


#ifdef DEF_IMP

FUNCTION ImlSave()
RETURN {      ;
  snMont,     ;
  snMontDev,  ;
  snImlCount, ;
  saJnl,      ;
  saDev,      ;
  snCours,    ;
  SetDevise() ;
}

FUNCTION ImlRestore(a)
snMont     := a[1]
snMontDev  := a[2]
snImlCount := a[3]
saJnl      := a[4]
saDev      := a[5]
snCours    := a[6]
SetDevise(a[7])
RETURN NIL

FUNCTION ImpImlInit(jnl)
local a := ImlSave()
saJnl       := jnl
if IMP->IdDev == DevDefault(IMP->Periode)
  snMont      := val(IMP->Mont1)
  snMontDev   := 0
else
  snMont      := 0
  snMontDev   := val(IMP->Mont1)
endif
snImlCount := 0
snCours := val(IMP->Cours)
if (saDev := DevLocate(IMP->IdDev)) == NIL
  SetMsg(MsgDevExist())
  RETURN NIL
endif
RETURN NIL if snCours == 0
RETURN NIL if ! SetDevise(DevDefault(IMP->Periode))
RETURN a

**
** ImpImlEdit() -
**
FUNCTION ImpImlEdit()
local b := oIml()
local cIdJnl := IMP->IdJnl
local cIdDoc := IMP->IdDoc
local cMsg
local jnl := JnlLocate(IMP->IdJnl)
local a
RETURN .f. if jnl == NIL
RETURN .f. if ! ddRecLock()
if (a := ImpImlInit(jnl)) != NIL
  do while ! AppTerminate()
    open area b, oPar(), oBud(), oGen()
      * snMont2 := val(IMP->Mont1)
      * snImlCount := 0
      * saImpJnl      := jnl
      softseek IMP->IdJnl + IMP->IdDoc
      do while IML->IdJnl + IML->IdDoc == IMP->IdJnl + IMP->IdDoc
        ImlAfter()
        Purzel()
        skip
      enddo
      edit data b key IML->IdJnl + IML->IdDoc ;
        value    cIdJnl + cIdDoc             ;
        create   {||ImlCreate( cIdJnl, cIdDoc ) } ;
        before   ImlBefore() ;
        after    ImlAfter() ;
        start    bottom                 ;
        mode     edit  ;
        query ("IML"+jnl[JNL_IDDBV]) ;
        title ("Inhalt " + cIdJnl + " " + cIdDoc)
    close area
    if IMP->Etat == DocStatClosed() .or. IMP->Etat == DocStatError()
      exit
    else
      if ddLastKey() == K_F10
        if snImlCount != 0
          if CheckImpSumme(jnl, snMont)
            IMP->Etat  := DocStatOpen()
            IMP->Mont2 := ntom(ImpSolde2(),DevDecPos(IMP->IdDev),len(IMP->Mont2))
            ** ab hier zusÑtzlicher sicherheits-test...
              if IMP->IdDev == DevDefault(IMP->Periode)
                snMont      := val(IMP->Mont1)
                snMontDev   := 0
              else
                snMont      := 0
                snMontDev   := val(IMP->Mont1)
              endif
              snImlCount := 0
              open area b
                softseek IMP->IdJnl + IMP->IdDoc
                do while ! eof() .and. IML->IdJnl + IML->IdDoc == IMP->IdJnl + IMP->IdDoc
                  * snImlCount += 1
                  ImlAfter()
                  Purzel()
                  skip
                enddo
              close area
              if IMP->Mont2 != ntom(ImpSolde2(),DevDecPos(IMP->IdDev),len(IMP->Mont2))
                ddRefreshCurrent()
                cMsg := "Anomalie " + IMP->IdJnl + IMP->IdDoc + " : " + ltrim(IMP->Mont2)
                cMsg += " <> " + ltrim(ntom(ImpSolde2(),DevDecPos(IMP->IdDev))) + " !"
                Warning(cMsg)
                SendConsole(cMsg)
                IMP->Mont2 := ntom(ImpSolde2(),DevDecPos(IMP->IdDev),len(IMP->Mont2))
              endif
            ** bis hier zusÑtzlicher sicherheits-test...
            snMont := 0
            snMontDev := 0  // 19981223
            * snMont2 := 0
            ddRefreshCurrent()
            if Confirm( ;
              MsgIdJnlDoc() + MsgClose(), NIL, MSG_YES ;
            )
              if ImpDlgClose(jnl) // 19980513 != .f.
                commit
                exit
              endif
            endif
          endif
        else
          Warning("Sie haben keine Buchungen eingegeben !")
        endif
      else
        if snImlCount != 0 .and. snMont != 0
          if Confirm( ;
            MsgIdJnlDoc() + MSG_ABBRECHEN, NIL, ;
            MSG_NO,"WRN006" ;
          )
            IMP->Etat := DocStatOpen()
            exit
          endif
        else
          exit
        endif
      endif
    endif
  enddo
  ImlRestore(a)
else
  Warning(SetMsg())
endif
unlock record
RETURN MnuDone()

**
FUNCTION ImpTestMont2(jnl)
**
** macht ungefÑhr das gleiche wie der zusÑtzliche Sicherheits-Test
** aber eben im IntegritÑtstest
**
local nMont
local nMontDev
local nImlCount := 0
local cMont2
local cMsg
if IMP->IdDev == DevDefault(IMP->Periode)
  nMont      := val(IMP->Mont1)
  nMontDev   := 0
else
  nMont      := 0
  nMontDev   := val(IMP->Mont1)
endif
open area oIml()
  softseek IMP->IdJnl + IMP->IdDoc
  do while ! eof() .and. IML->IdJnl + IML->IdDoc == IMP->IdJnl + IMP->IdDoc
    * ungefÑhr wie ImlAfter()
    snImlCount += 1
    if IML->DC == jnl[JNL_DC] // JnlDC(IML->IdJnl)
      nMont    += val(IML->Mont)
      nMontDev += val(IML->MontDev)
    else
      nMont    -= val(IML->Mont)
      nMontDev -= val(IML->MontDev)
    endif
    Purzel()
    skip
  enddo
close area
if IMP->IdDev == DevDefault(IMP->Periode)
  cMont2 := ntom(nMont,DevDecPos(IMP->IdDev),len(IMP->Mont2))
else
  cMont2 := ntom(nMontDev,DevDecPos(IMP->IdDev),len(IMP->Mont2))
endif
RETURN .t. if IMP->Mont2 == cMont2
RETURN .t. if abs(val(IMP->Mont2)) == abs(val(cMont2)) // 19990421
cMsg := "Anomalie : IMP->Mont2 " + ltrim(IMP->Mont2)
cMsg += " <> " + ltrim(cMont2) + " !"
SetMsg(cMsg)
RETURN .f.


**
** CheckImpSumme()
** FÅr manche Dokumente, z.B. REG, darf die Summe (IMP->Mont2) nicht 0
** sein...
** funktioniert das noch? 19980618
**
FUNCTION CheckImpSumme(jnl, nImlSum)
RETURN .t. if JNLATTR_S $ jnl[JNL_ATTRIB]
RETURN .t. if nImlSum != 0
RETURN .t. if JNLATTR_E $ jnl[JNL_ATTRIB]
Warning("Summe darf nicht Null sein !")
RETURN .f.

**
** ImpCreate()
**
FUNCTION ImpCreate(jnl, cIdDoc) // cIdJnl)
local cPeriode 
local cIdPar := ""
local cIdBud := ""
local cIdTrt
local aSolde
local nOrder := indexord()
RETURN DDCREATE_FAIL if jnl == NIL
if ddRequest() == DDEDIT_BROWSE
  cPeriode := PickPer(NIL,jnl[JNL_IDJNL],UserDate())
  RETURN DDCREATE_FAIL if cPeriode == NIL
else
  cPeriode := IMP->Periode
endif
if JNLATTR_P $ jnl[JNL_ATTRIB]
  RETURN DDCREATE_FAIL if (cIdPar := PickPar(NIL)) == NIL
endif
if JNLATTR_B $ jnl[JNL_ATTRIB]
  if JNLATTR_1 $ jnl[JNL_ATTRIB]
    RETURN DDCREATE_FAIL if (cIdTrt := PickTrt("",jnl[JNL_DC])) == NIL
    cIdBud := TrtIdBud(cIdTrt)
    RETURN DDCREATE_FAIL if empty(cIdBud)
  else
    RETURN DDCREATE_FAIL if (cIdBud := PickBud(jnl[JNL_DC])) == NIL
  endif
  RETURN DDCREATE_FAIL if ! ValIdBud(jnl[JNL_DC],cIdBud)
endif
ddSetOrder(1)
KeyGoBottom( jnl[JNL_IDJNL], "IMP->IdJnl" )
ddSetOrder(nOrder)
if ! eof() .and. IMP->Etat != DocStatClosed()
  RETURN DDCREATE_FAIL if ! Confirm( ;
    MsgPrevDoc() + MsgNotClosed(), MsgDocCreate(), ;
    MSG_NO,"WRN001" ;
  )
endif
aSolde := { IMP->IdDev, IMP->Mont2 }
* cMont2 := IMP->Mont2
* cIdDev := IMP->IdDev
if ! IsNewId(jnl[JNL_IDJNL] + cIdDoc)
  Warning(jnl[JNL_IDJNL] + cIdDoc + MsgDocExist(),NIL,"WRN014")
  RETURN DDCREATE_FAIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
IMP->IdJnl   := jnl[JNL_IDJNL]
IMP->IdDoc   := cIdDoc
IMP->Periode := cPeriode
IMP->Date1   := UserDate()
IMP->Date2   := UserDate()
IMP->IdUsr   := UserId()
IMP->IdBud   := cIdBud
ImpBudValidate(JnlDC(IMP->IdJnl))
if empty(jnl[JNL_IDDEV])
  IMP->IdDev := DevDefault(IMP->Periode)
else
  IMP->IdDev   := jnl[JNL_IDDEV]
endif
if ! empty(cIdPar)
  IMP->IdPar   := cIdPar
  if ImpPar1Validate()
    IMP->Compte1 := PAR->Compte1
    if empty(jnl[JNL_IDDEV]) .and. ! empty(PAR->IdDev)
      IMP->IdDev := PAR->IdDev
    endif
  else
    IMP->IdPar := ""
  endif
  * if ParExist(cIdPar)
  *   if OnParSelect()
  *     IMP->Compte1 := PAR->Compte1
  *   else
  *     IMP->IdPar := ""
  *   endif
  * endif
endif
if empty(IMP->IdDev)
  IMP->IdDev := DevDefault(IMP->Periode)
endif
IMP->Etat := DocStatNew()
ImpDevValidate()
ImpSetMont1(jnl,aSolde)
RETURN DDCREATE_FULL

FUNCTION ImpSetMont1(jnl,aSolde)
local nMont2Db
local cIdDev := aSolde[1]
local cMont2 := aSolde[2]
RETURN NIL if ! JNLATTR_S $ jnl[JNL_ATTRIB]
if IMP->IdDev == cIdDev
  IMP->Mont1 := cMont2
else
  nMont2Db := Dev2Db(cIdDev,IMP->Periode,val(cMont2))
  IMP->Mont1 := ntom(;
    Db2Dev(IMP->IdDev,IMP->Periode,nMont2Db),;
    DevDecPos(IMP->IdDev);
  )
  Warning(MsgIdJnlDoc() + " : SaldenÅbertrag wurde konvertiert von " ;
    + cIdDev + " nach " + IMP->IdDev)
endif
RETURN NIL


**
** ImlCreate()
**
FUNCTION ImlCreate(cIdJnl,cIdDoc,xlOnCreate)
local cLine
local nReturn
local lOkay := .t.
local nOrder := indexord()
* local lRefresh := (recno() != lastrec() + 1)
RETURN DDCREATE_FAIL if ! ImpPreEdit()
if eof() // 20070801 recno() == lastrec() + 1
  nReturn := DDCREATE_EDIT
else
  nReturn := DDCREATE_REFRESH
endif
ddSetOrder(1)
ddGoBottom(.f.)
cLine  := NextNum(IML->Line)
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
IML->IdJnl   := cIdJnl
IML->IdDoc   := cIdDoc
IML->Line    := cLine
IML->IdBud   := IMP->IdBud
IML->IdPar   := IMP->IdPar
IML->IdPrj   := IMP->IdPrj
IML->IdPar2  := IMP->IdPar2
IML->Date    := UserDate()
IML->Match   := IML->IdJnl + IML->IdDoc + IML->Line
IML->DC      := saJnl[JNL_DC] // JnlDC(cIdJnl)
IML->NB1     := IMP->NB1
IML->NB2     := IMP->NB2
if xlOnCreate != NIL
  lOkay := xparse(xlOnCreate)
else
  dbcommit()
endif
ImlPostEdit()
* unlock record 19980430
RETURN DDCREATE_FAIL if ! lOkay
RETURN nReturn

**
** ImlPostEdit()
**
FUNCTION ImlPostEdit()
if empty(IML->Mont)
  if ! empty(IMP->Mont2)
    IML->Mont := ntom(val(IMP->Mont2)-snMont)
  endif
endif
RETURN .f. if ! ParExist(IML->IdPar)
if empty(IML->IdBud) .and. IML->DC == PrtDC(PAR->IdPrt)
  IML->IdBud := PAR->IdBud
endif
* [960605] Datei,PrÅfen fand keinen falschen Eintrag in IdPar2
if ! empty(IML->IdPar2)
  RETURN .f. if ! ParExist(IML->IdPar2)
endif
if empty(IMP->Compte1)
  if empty(IML->Compte1)
    // IML->Compte1 := PAR->Compte1
    IML->Compte1 := ImlCompte()
  endif
else
  IML->Compte1 := IMP->Compte1
endif
if ! empty(saJnl[JNL_CODEBQE])
  if empty(IML->Compte1)
    Warning("Kontonummer : darf nicht leer sein !")
    RETURN .f.
  endif
endif
if empty(IML->IdBud)
  * SetMsg("Artikel : ")
  RETURN .f.
endif
RETURN .f. if ! BudExist(IML->DC,IML->IdBud)
if val(IML->Mont) == 0
  SetMsg("Betrag : darf nicht 0 sein !")
  RETURN .f.
endif
if JNLATTR_M $ saJnl[JNL_ATTRIB] // JnlAttrib(IML->IdJnl)
  if empty(IML->BackMatch)
    SetMsg("RÅckbezug : erforderlich ! Buchungen mit [F5] Åbernehmen !")
    RETURN .f.
  endif
endif
RETURN .f. if ! PrjBudValidate(IML->DC)
if ! empty(IML->IdPrj)
  RETURN .f. if ! PrjExist(IML->IdPrj)
endif
#ifdef DEF_MVA
  if JNLATTR_Y $ saJnl[JNL_ATTRIB]
    * RETURN .f. if ! GenExist(BUD->IdGen)
    if ! empty(IML->Mont) .and. BUDATTR_Y $ BUD->Attrib
      ImlMvaEdit()
    endif
  endif
#endif DEF_MVA
RETURN .t.


FUNCTION PrjBudValidate(cDC)
RETURN .t. if empty(FIELD->IdBud)
RETURN .t. if ! BudExist(cDC,FIELD->IdBud)
if empty(FIELD->IdPrj)
  FIELD->IdPrj := BUD->IdPrj
endif
if ! empty(FIELD->IdPrj)  // 20000927
  RETURN .f. if ! PrjExist(FIELD->IdPrj)
endif
if ! empty(BUD->IdPrj)
 if left(FIELD->IdPrj,len(trim(BUD->IdPrj))) != trim(BUD->IdPrj)
   RETURN .f. if ! Confirm( ;
     trim(FIELD->IdPrj) + " : ungÅltige Projektwurzel !", ;
     MsgSure(), MSG_NO ;
   )
 endif
endif
RETURN .t.



FUNCTION GsbImlDebit(x)
if x == NIL
  RETURN space(LenMont()) if FIELD->DC == DC_CREDIT
  RETURN FIELD->Mont
endif
FIELD->DC := DC_DEBIT
FIELD->Mont := x
RETURN NIL
   
FUNCTION GsbImlCredit(x)
if x == NIL
  RETURN space(LenMont()) if FIELD->DC == DC_DEBIT
  RETURN FIELD->Mont
endif
FIELD->DC := DC_CREDIT
FIELD->Mont := x
RETURN NIL


FUNCTION GsbMviDebit(x)
*if x == NIL
  RETURN space(LenMont()) if MVI->DC == DC_CREDIT
  RETURN MVI->Mont
*endif
*MVI->DC := DC_DEBIT
*MVI->Mont := x
*RETURN NIL
   
FUNCTION GsbMviCredit(x)
* if x == NIL
  RETURN space(LenMont()) if MVI->DC == DC_DEBIT
  RETURN MVI->Mont
*endif
*MVI->DC := DC_CREDIT
*MVI->Mont := x
*RETURN NIL


FUNCTION ImlLibell(cRemarq)
if cRemarq != NIL
  IML->NB1 := cRemarq
  RETURN NIL
endif
if eof() // 20070801 recno() == lastrec() + 1 // .and. slImlEdit
  RETURN padr(MsgBleibt()+":",40) if ! empty(IMP->Mont2)
  RETURN padr("TOTAL :",40)
endif
RETURN IML->NB1 if ! empty(IML->NB1)
if ! empty(IML->IdBud)
  RETURN padr(BudName(IML->DC,IML->IdBud),40)
endif
RETURN space(40)

FUNCTION ImlBefore
snImlCount -= 1
if IML->DC == saJnl[JNL_DC] // JnlDC(IML->IdJnl)
  snMont    -= val(IML->Mont)
  snMontDev -= val(IML->MontDev)
  * snMont2 -= val(IML->Mont)
else
  snMont    += val(IML->Mont)
  snMontDev += val(IML->MontDev)
  * snMont2 += val(IML->Mont)
endif
RETURN NIL

FUNCTION ImlAfter
snImlCount += 1
if IML->DC == saJnl[JNL_DC] // JnlDC(IML->IdJnl)
  snMont    += val(IML->Mont)
  snMontDev += val(IML->MontDev)
  * snMont2 += val(IML->Mont)
else
  snMont    -= val(IML->Mont)
  snMontDev -= val(IML->MontDev)
  * snMont2 -= val(IML->Mont)
endif
RETURN NIL

FUNCTION ImlMont(x)
if x == NIL
  if eof() // 20070801 recno() == lastrec() + 1
    RETURN space(LenMont()) if IMP->IdDev != DevDefault(IMP->Periode)
    if empty(IMP->Mont2)
      RETURN ntom(val(IMP->Mont1) + snMont) // neuer Saldo / Summe
    else
      RETURN ntom(val(IMP->Mont2) - (val(IMP->Mont1) + snMont)) // bleibt zu buchen
    endif
  endif
  RETURN IML->Mont
endif
IML->Mont := x
RETURN NIL

FUNCTION ImlMontDev(x)
if x == NIL
  if eof() // 20070801 recno() == lastrec() + 1
    RETURN space(LenMont()) if IMP->IdDev == DevDefault(IMP->Periode)
    if empty(IMP->Mont2)
      RETURN ntom( ;
        val(IMP->Mont1) + snMontDev, ;
        saDev[DEV_DECPOS] ;
      ) // neuer Saldo / Summe
    else
      RETURN ntom( ;
        val(IMP->Mont2) - (val(IMP->Mont1) + snMontDev), ;
        saDev[DEV_DECPOS] ;
      ) // bleibt zu buchen
    endif
  endif
  RETURN IML->MontDev
endif
IML->MontDev := x
RETURN NIL

**
** ImpDlgClose()
**
FUNCTION ImpDlgClose(jnl)
local a
local aCtb := {}
local aImlSuite := {}
local aMvi := {}
local lOkay := .f.
// local jnl := JnlLocate(IMP->IdJnl)
local nMont
local aMviUpdate := {}
local aLines := {}
local i
if jnl == NIL
  Warning("ImpDlgClose() : jnl == NIL")
  RETURN .f.
endif
if IMP->Etat == DocStatNew()
  Warning( ;
    "Dokument ist nicht fertig eingegeben.", ;
    MsgIdJnlDoc() + MsgCloseFail() ;
  )
** Wenn Dokument (ganz oder halb) registriert ist : entregistrieren
elseif IMP->Etat == DocStatError() .or. IMP->Etat == DocStatClosed()
  RETURN .f. if ! USRATTR_S $ UsrAttrib()
  RETURN .f. if ! Confirm( ;
    MsgIdJnlDoc() + MsgUndo(), MsgSure(), MSG_NO,"WRN002" ;
  )
  RETURN .f. if ! PerSetDirty(jnl,IMP->Periode,UserDate(),IMP->IdDoc)
  open area oIml()
    lOkay := .t.
    softseek IMP->IdJnl + IMP->IdDoc
    if ! eof()
      if ! empty(IML->IdIml)
        lOkay := .f.
      endif
    endif
  close area
  if ! lOkay
    Warning(;
      IMP->IdJnl + " " + IMP->IdDoc + ;
      " wurde bereits definitiv ausgedruckt.", ;
      MsgUndoFail() ;
    )
    RETURN .f.
  endif
  open area oMvi()
    lOkay := .t.
    softseek IMP->IdJnl + IMP->IdDoc
    do while ! eof() .and. MVI->IdDoc == IMP->IdDoc ;
                     .and. MVI->IdJnl == IMP->IdJnl
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
  if lOkay
    IMP->Etat := DocStatOpen()
    SetMsg("Dokument wurde entregistriert.")
  endif
else // registrieren
  RETURN .f. if ! PerSetDirty(jnl,IMP->Periode,UserDate(),IMP->IdDoc) // ,IMP->Date1)
  #ifdef DEF_ANA
    RETURN .f. if ! ImpMvaTest()
  #endif DEF_ANA
  if (a := ImpImlInit(jnl)) != NIL
    if ImpPreClose(jnl,aImlSuite,aCtb,aMvi,aMviUpdate)
      if ImpMviScan(jnl,aMvi,aImlSuite,aMviUpdate,aCtb)
        if CtbChkAvail(aCtb,jnl)
          if ImpChkSuite(jnl,aImlSuite)
            * 20021211 if ddRecLock()
              if OnImpClose()
                IMP->Etat := DocStatError() // neu 20011123
                commit // neu 20011123
                if ImpMviGenerate(jnl,aMvi,aMviUpdate)
                  if ImpGenSuite(aImlSuite,aCtb,;
                    IMP->Periode,IMP->Date2,aLines;
                  )
                    aImlSuite := {}
                    IMP->Etat := DocStatClosed()
                    SetMsg(IMP->IdJnl + " " + IMP->IdDoc + MsgCloseOkay())
                    * 20021211 unlock record
                    commit
                  else
                    SendConsole("ImpGenSuite() failed")
                  endif
                  for i := 1 to len(aLines)
                    Warning(aLines[i],NIL,"WRN015")
                  next i
                  **
                  if ! CtbUpdate(aCtb)
                    SendConsole("CtbUpdate() failed")
                  else
                    * 20030523
                    *if ! empty(jnl[JNL_CODEBQE])
                    *  if ! ImpWriteOti(jnl)
                    *    SendConsole("ImpWriteOti() failed")
                    *  endif
                    *endif
                    if JNLATTR_I $ jnl[JNL_ATTRIB]
                      ImpPrint(jnl[JNL_IDTPL])
                    endif
                  endif
                else
                  Warning(SetMsg(),MsgIdJnlDoc()+MsgCloseFail())
                endif
              endif
            * 20021211 endif
          else
            // Neu seit 19980702
            Warning(SetMsg(),MsgIdJnlDoc()+MsgCloseFail())
          endif
        else
          Warning(SetMsg(),MsgIdJnlDoc()+MsgCloseFail())
        endif
      else
        Warning(SetMsg(),MsgIdJnlDoc()+MsgCloseFail())
      endif
    else
      Warning(SetMsg(),MsgIdJnlDoc()+MsgCloseFail())
    endif
    ImlRestore(a)
  else
    Warning(SetMsg(),MsgIdJnlDoc()+MsgCloseFail())
  endif
  #ifdef DEF_PURZEL
  PurzelStop()
  #endif
endif
ddRefreshCurrent()
RETURN .t. // MnuDone() 19980513


* 20030523
* FUNCTION ImpDlgWriteOti
* local jnl := JnlLocate(IMP->IdJnl)
* RETURN .f. if jnl == NIL
* RETURN .f. if empty(jnl[JNL_CODEBQE])
* if ! ImpWriteOti(jnl)
*   Warning("ImpWriteOti() failed")
* endif
* RETURN MnuDone()


**
** CtbChkAvail() : Kreditkontrolle
**
FUNCTION CtbChkAvail(aCtb,jnl)
local i
RETURN .t. if JNLATTR_T $ jnl[JNL_ATTRIB]
for i := 1 to len(aCtb)
  RETURN .f. if ! BudChkAvail( ;
    aCtb[i][CTB_DC],aCtb[i][CTB_IDBUD], ;
    aCtb[i][CTB_PERIODE], aCtb[i][CTB_MONT] ;
  )
next i
RETURN .t.

**
** ImpChkSuite()
**
FUNCTION ImpChkSuite(jnl,aImlSuite)
local i
local jnlAppend
local cPeriode := PerPerCtr(IMP->Periode)
local aChk := {}
#define CHK_DC    1
#define CHK_IDBUD 2
#define CHK_MONT  3
#define CHK_JNL   4
#define CHK_ALEN  4
RETURN .t. if len(aImlSuite) == 0
for i := 1 to len(aImlSuite)
  ChkCollect(aChk,aImlSuite[i])
next i
for i := 1 to len(aChk)
  * [960514] RETURN .f. if (jnlAppend := SatJnlOver(jnl,aChk[i][CHK_DC])) == NIL
  if ! JNLATTR_T $ aChk[i][CHK_JNL][JNL_ATTRIB]
    RETURN .f. if ! BudChkAvail( ;
      aChk[i][CHK_DC], ;
      aChk[i][CHK_IDBUD], ;
      cPeriode , ;
      aChk[i][CHK_MONT]), ;
      ;
    )
  endif
next i
RETURN .t.

FUNCTION ChkCollect(aChk,iml)
local i
local chk := NIL
for i := 1 to len(aChk)
  if aChk[i][CHK_DC] == iml[IML_DC]
    if aChk[i][CHK_IDBUD] == iml[IML_IDBUD]
      if aChk[i][CHK_JNL][JNL_IDJNL] == iml[IML_JNL][JNL_IDJNL]
        chk := aChk[i]
        exit
      endif
    endif
  endif
next i
if chk == NIL
  chk := array(CHK_ALEN)
  chk[CHK_DC]    := iml[IML_DC]
  chk[CHK_IDBUD] := iml[IML_IDBUD]
  chk[CHK_MONT]  := val(iml[IML_MONT])
  chk[CHK_JNL]   := iml[IML_JNL] // JnlLocate(iml[IML_IDJNL])
  aadd(aChk,chk)
else
  chk[CHK_MONT]  += val(iml[IML_MONT])
endif
RETURN NIL

**
** BudChkAvail()
**
FUNCTION BudChkAvail(cDC, cIdBud,cPeriode,nMont)
local cMsg
seek cDC + cIdBud in BUD
// 20000511 if ! BUDATTR_T $ BUD->Attrib
RETURN .t. if BudIsTolerant(cPeriode)
  if BudAvail(cDC,cIdBud,cPeriode,MemIdCdc) < nMont
    cMsg := cDC + "-" + trim(SayIdBud(cIdBud))
    cMsg += " : Kredit unzureichend !"
    if USRATTR_E $ UsrAttrib()
      RETURN .t. if Confirm(cMsg, MsgSure(), MSG_NO, "WRN009" )
      SetMsg(cMsg)
      RETURN .f.
    else
      SetMsg(cMsg)
      RETURN .f.
    endif
  endif
// endif
RETURN .t.



**
** ImpGenSuite() before 20021206
**
*FUNCTION ImpGenSuite(jnl,aImlSuite,aCtb)
*local i
*local lOkay := .t.
*local a := {}
*local aLines := {}
*RETURN .t. if len(aImlSuite) == 0
*for i := 1 to len(aImlSuite)
*  if DocCreate(aImlSuite[i][IML_JNL], {|cIdDoc| ImpAppend( ;
*    aImlSuite[i][IML_JNL], cIdDoc, { aImlSuite[i] }, aCtb, ;
*    IMP->Periode, IMP->Date2, IMP->Date2, a, aLines ;
*  ) } ) != DDCREATE_DONE
*    lOkay := .f.
*  endif
*next i
*for i := 1 to len(aLines)
*  Warning(aLines[i],NIL,"WRN015")
*next i
*if len(a) > 0
*  Warning("Anomalie : ImpGenSuite() : len(a) > 0 !")
*endif
*RETURN lOkay



/**
ImpGenSuite(aImlSuite,aCtb)
jnl : das Journal des auslîsenden Dokuments
aImlSuite : die Folgebuchungen, die gemacht werden mÅssen
aCtb : Kollektor fÅr Aktualisierungen in der CTB

20021206 :
Wenn ein ZAU mit vielen IMLs erfasst wird, von denen viele *nicht*
Åbernommen wurden (also Match und Backmatch leer), und wenn JNLATTR_K
(Automatikjournal kollektiv buchen) gesetzt ist, dann werden diese
Buchungen hier in aImpSuite gesammelt (und .t. zurÅck gegeben). Return
.t. bedeutet : diese IML habe ich mir im aImpSuite gemerkt, also kein
eigenes Dokument dafÅr erzeugen.

Siehe auch CtlGenSuite()

**/

**
** ImpGenSuite() after 20021206
**
FUNCTION ImpGenSuite(aImlSuite,aCtb,cPeriode,dDate,aLines)
local i
local lOkay := .t.
local a := {}
* local aLines := {}
local aImpSuite := {}
RETURN .t. if len(aImlSuite) == 0
// Dokumente mit Einzelbuchung generieren
for i := 1 to len(aImlSuite)
  if ! ImpCollSuite(aImpSuite,aImlSuite[i])
    if DocCreate(aImlSuite[i][IML_JNL], {|cIdDoc| ImpAppend( ;
      aImlSuite[i][IML_JNL], cIdDoc, { aImlSuite[i] }, aCtb, ;
      cPeriode, dDate, dDate, a, aLines ;
    ) } ) != DDCREATE_DONE
      lOkay := .f.
    endif
  endif
next i
// Dokumente mit Sammelbuchungen generieren
for i := 1 to len(aImpSuite)
  if DocCreate(aImpSuite[i][IMP_JNL], {|cIdDoc| ImpAppend( ;
    aImpSuite[i][IMP_JNL], cIdDoc, aImpSuite[i][IMP_AIML] , aCtb, ;
    cPeriode, dDate, dDate, a, aLines ;
  ) } ) != DDCREATE_DONE
    lOkay := .f.
  endif
next i
if len(a) > 0
  Warning("Anomalie : ImpGenSuite() : len(a) > 0 !")
  // die automatischen Folgebuchungen wollen ihrerseits wiederum
  // Folgebuchungen machen. Das geht aber wohl nicht.
endif
RETURN lOkay

STATIC FUNCTION ImpCollSuite(aImpSuite,aIml)
local a
local i
* RETURN .f. if ! empty(aIml[IML_MATCH])
* RETURN .f. if ! empty(aIml[IML_BACKMATCH])
// IML_BACKMATCH fÅr Folgebuchungen ist nie leer.
RETURN .f. if ! JNLATTR_Z $ aIml[IML_JNL][JNL_ATTRIB]
for i := 1 to len(aImpSuite)
  if aImpSuite[i][IMP_JNL][JNL_IDJNL] == aIml[IML_JNL][JNL_IDJNL]
    if (! JNLATTR_B $ aImpSuite[i][IMP_JNL][JNL_ATTRIB]) .or. ;
       (aImpSuite[i][IMP_IDBUD] == aIml[IML_IDBUD] ;
       .and. aImpSuite[i][IMP_DC] == aIml[IML_DC])
      if (! JNLATTR_P $ aImpSuite[i][IMP_JNL][JNL_ATTRIB]) .or. ;
        aImpSuite[i][IMP_IDPAR] == aIml[IML_IDPAR]
        aadd(aImpSuite[i][IMP_AIML],aIml)
        RETURN .t.
      endif
    endif
  endif
next i
a := array(IMP_ALEN)
a[IMP_JNL]   := aIml[IML_JNL]
a[IMP_IDPAR] := aIml[IML_IDPAR]
a[IMP_IDBUD] := aIml[IML_IDBUD]
a[IMP_DC]    := aIml[IML_DC]
a[IMP_AIML]  := { aIml }
aadd(aImpSuite,a)
RETURN .t.



**
** ImpAppend() : ABE/EBE automatisch generieren
**
FUNCTION ImpAppend( ;
  jnl,cIdDoc,aIml,aCtb, ;
  cPeriode,dDate1,dDate2,aImlSuite, ;
  aLines, dDate3, cMemo ;
)
local nReturn := DDCREATE_FAIL
local i
local nMont := 0
local nMontTmp
local aMviUpdate := {}
local cIdPar2 := NIL
local cLine := "001"
* local cMont2
local aMvi := {}
local a
local aSolde
* RETURN DDCREATE_FAIL if jnl == NIL
RETURN DDCREATE_FAIL if ! PerSetDirty(jnl,cPeriode,UserDate(),cIdDoc)
open area oImp()
  KeyGoBottom( jnl[JNL_IDJNL], "IMP->IdJnl" )
  aSolde := { IMP->IdDev, IMP->Mont2 }
  * cMont2 := IMP->Mont2
  seek jnl[JNL_IDJNL] + cIdDoc
  if eof()
    if dbAddRec()
      IMP->IdJnl   := jnl[JNL_IDJNL]
      IMP->IdDoc   := cIdDoc
      IMP->Periode := cPeriode
      if JNLATTR_B $ jnl[JNL_ATTRIB] .or. len(aIml) == 1
        IMP->IdBud := aIml[1][IML_IDBUD]
      endif
      if JNLATTR_P $ jnl[JNL_ATTRIB] .or. len(aIml) == 1
        IMP->IdPar  := aIml[1][IML_IDPAR ]
        * IMP->IdPar2 := aIml[1][IML_IDPAR2]
      endif
      IMP->Date1 := dDate1
      IMP->Date2 := dDate2
      if dDate3 != NIL
        IMP->Date3 := dDate3 // [970703]
      endif
      IMP->Etat  := DocStatOpen()
      IMP->IdUsr := UserId()
      if empty(jnl[JNL_IDDEV])
        IMP->IdDev := DevDefault(IMP->Periode)
      else
        IMP->IdDev := jnl[JNL_IDDEV]
      endif
      ImpDevValidate()
      if cMemo != NIL
        IMP->Memo  := cMemo
      endif
      nReturn := DDCREATE_ERROR
      if (a := ImpImlInit(jnl)) != NIL
        open area oIml()
          nReturn := DDCREATE_DONE
          for i := 1 to len(aIml)
            if dbAddRec()
              IML->IdJnl       := jnl[JNL_IDJNL]
              IML->IdDoc       := cIdDoc
              IML->Line        := cLine
              IML->IdPar       := aIml[i][IML_IDPAR    ]
              IML->NB1         := aIml[i][IML_NB1      ]
              IML->Mont        := aIml[i][IML_MONT     ]
              IML->MontDev     := aIml[i][IML_MONTDEV  ] // 20011221
              IML->Date        := aIml[i][IML_DATE     ]
              * IML->Date3       := aIml[i][IML_DATE3    ]
              IML->IdBud       := aIml[i][IML_IDBUD    ]
              IML->BackMatch   := aIml[i][IML_BACKMATCH]
              if empty(aIml[i][IML_MATCH])
                IML->Match       := jnl[JNL_IDJNL] + cIdDoc + cLine
              else
                IML->Match       := aIml[i][IML_MATCH    ]
              endif
              IML->EaMatch     := aIml[i][IML_EAMATCH  ]
              IML->IdPar2      := aIml[i][IML_IDPAR2   ]
              default cIdPar2 to IML->IdPar2
              if IML->IdPar2 != cIdPar2
                cIdPar2 := ""
              endif
              IML->IdPrj       := aIml[i][IML_IDPRJ    ]
              IML->NB2         := aIml[i][IML_NB2      ]
              IML->Compte1     := aIml[i][IML_COMPTE1  ]
              IML->DC          := aIml[i][IML_DC       ]
              cLine := NextNum(cLine)
              // 20011221 : Summe Dokument evt. nicht in GW!
              if IMP->IdDev == DevDefault(IMP->Periode)
                nMontTmp := val(IML->Mont)
              else
                nMontTmp := val(IML->MontDev)
              endif
              if IML->DC == jnl[JNL_DC]
                nMont += nMontTmp
              else
                nMont -= nMontTmp
              endif
              // lOkay := .t.
              unlock record
            else
              nReturn := DDCREATE_ERROR
              exit
            endif
          next i
        close area
        if cIdPar2 != NIL
          IMP->IdPar2 := cIdPar2
        endif
        if nReturn == DDCREATE_DONE // lOkay
          if JNLATTR_S $ jnl[JNL_ATTRIB]
            ImpSetMont1(jnl,aSolde) // IMP->Mont1 := cMont2
            IMP->Mont2 := ntom( ;
              val(IMP->Mont1) + nMont, ;
              DevDecPos(IMP->IdDev), ;
              len(IMP->Mont2);
            )
          else
            IMP->Mont2 := ntom(nMont, DevDecPos(IMP->IdDev), len(IMP->Mont2))
          endif
          nReturn := DDCREATE_ERROR
          * lOkay := .f.
          if ImpPreClose(jnl,aImlSuite,aCtb,aMvi,aMviUpdate)
            if ImpMviScan(jnl,aMvi,aImlSuite,aMviUpdate,aCtb)
              if OnImpClose()
                IMP->Etat := DocStatError() // neu 20011123
                commit // neu 20011123
                if ImpMviGenerate(jnl,aMvi,aMviUpdate)
                  commit // neu 20011123
                  IMP->Etat := DocStatClosed()
                  * 20030523
                  * if ! empty(jnl[JNL_CODEBQE])
                  *   if ! ImpWriteOti(jnl)
                  *     SendConsole("ImpWriteOti() failed")
                  *   endif
                  * endif
                  // if cPrint == BUTTON_ON .or. JNLATTR_I $ jnl[JNL_ATTRIB]
                  if JNLATTR_I $ jnl[JNL_ATTRIB]
                    ImpPrint(jnl[JNL_IDTPL])
                  endif
                  nReturn := DDCREATE_DONE
                else
                  aadd( aLines, ;
                    jnl[JNL_IDJNL] + " " + cIdDoc + " : ImpMviGenerate() failed !" ;
                  )
                endif
              endif
            else
              aadd( aLines, ;
                jnl[JNL_IDJNL] + " " + cIdDoc + " : " + SetMsg() ;
              )
                ** 20021203 jnl[JNL_IDJNL] + " " + cIdDoc + " : ImpMviScan() failed !" ;
            endif
          else
            aadd( aLines, ;
              jnl[JNL_IDJNL] + " " + cIdDoc + " : " + SetMsg() ;
            )
          endif
        else
          aadd( aLines, ;
            jnl[JNL_IDJNL] + " " + cIdDoc + " : IML->dbAddRec() failed !" ;
          )
        endif
        ImlRestore(a)
      endif
      unlock record
    else
      aadd( aLines, ;
        jnl[JNL_IDJNL] + " " + cIdDoc + " : dbAddRec() failed !" ;
      )
    endif
  else
    aadd( aLines, ;
      jnl[JNL_IDJNL] + " " + cIdDoc + MsgDocExist() ;
    )
    nReturn := DDCREATE_FAIL
  endif
close area
RETURN nReturn // lOkay


**
** ImpPreClose() (vorher ImpClose())
**
FUNCTION ImpPreClose(jnl,aImlSuite,aCtb,aMvi,aMviUpdate)
local lOkay := .f.
local nCount := 0
local aCta := {}
RETURN .f. if ! ImpCheckSolde(jnl)
#ifdef DEF_ANA
  RETURN .f. if ! OdaPreClose( ;
    aCta,IMP->IdJnl,IMP->IdDoc,IMP->IdPar,IMP->Periode ;
  )
#endif DEF_ANA
open area oIml(), oBud()
  lOkay := .t.
  softseek IMP->IdJnl + IMP->IdDoc
  do while ! eof() .and. IML->IdDoc == IMP->IdDoc ;
                   .and. IML->IdJnl == IMP->IdJnl
    if ! empty(jnl[JNL_CODEBQE])
      if empty(IML->Compte1)
        SetMsg("Position " + IML->Line + " : Kontonummer darf nicht leer sein !")
        lOkay := .f.
        exit
      endif
    endif
    if JNLATTR_F $ jnl[JNL_ATTRIB]
      if IML->DC != jnl[JNL_DC]
        SetMsg( ;
          IML->Line + ;
          " : " + IML->DC + "-Buchungen nicht erlaubt in " + ;
          jnl[JNL_IDJNL] + " !" ;
        )
        lOkay := .f.
        exit
      endif
    endif
    if JNLATTR_B $ jnl[JNL_ATTRIB]
      if IML->IdBud != IMP->IdBud
        SetMsg( ;
          IML->Line + ;
          " : falscher Artikel " + trim(SayIdBud(IML->IdBud)) ;
        )
        lOkay := .f.
        exit
      endif
    endif
    if JNLATTR_P $ jnl[JNL_ATTRIB]
      if IML->IdPar != IMP->IdPar
        SetMsg( ;
          IML->Line + ;
          " : falscher Partner " + IML->IdPar ;
        )
        lOkay := .f.
        exit
      endif
    endif
    if ! ImlMviCollect(aMvi)
      lOkay := .f.
      exit
    endif
    if ! PreImlClose()
      lOkay := .f.
      exit
    endif
    nCount++
    skip
  enddo
close area
RETURN .f. if ! lOkay
if nCount == 0
  SendConsole("ImpPreClose() : nCount war 0 !")
  SetMsg("Keine Buchungen.")
  RETURN .f.
endif
RETURN .t.
// [19980415] RETURN ImpMviScan(jnl,aMvi,aImlSuite,aMviUpdate,aCtb)


#define UPDATE_RECNO   1
#define UPDATE_MONTUS  2
#define UPDATE_ALEN    2

**
** ImpMviScan() - der Befriedigungs-Algorithmus
**
FUNCTION ImpMviScan(jnl,aMvi,aImlSuite,aUpdate,aCtb)
local lOkay := .f.
local i
local nMontUs  // unbefriedigter Betrag
local nMontPs  // Befriedigungspotential
local nMontAbe // Wieviel automatische Folgebuchung ?
local nMontCtb // zu zentralisierender Betrag
local nMontUsCtb // Ctb-Betrag der befriedigten Buchungen
local nMont    // unbefriedigter Betrag der einzelnen MVIs
local a
local cPeriode := PerPerCtr(IMP->Periode)
local nUbp     // un-befriedigungs-potential
local cBackmatch
local jnlAppend
* local cIdJnl := jnl[JNL_IDJNL]
local sat
open area oMvi()
  ddSetOrder(ORD_MVI_PARMATCH)
  lOkay := .t.
  for i := 1 to len(aMvi)
    if TaskInter() ; lOkay := .f. ; exit ; endif
    nMontUs := val(aMvi[i][MVI_MONT])
    nMontPs := val(aMvi[i][MVI_MONT])
    nMontAbe := val(aMvi[i][MVI_MONT])
    nMontUsCtb := 0 // val(aMvi[i][MVI_MONT])
    nMontCtb := val(aMvi[i][MVI_MONT])
    cBackmatch := NIL
    nUbp := 0
    * KeyGoBottom( ;
    *   aMvi[i][MVI_IDPAR] + aMvi[i][MVI_MATCH], ;
    *   "MVI->IdPar+MVI->Match" ;
    * )
    KeyGoBottom( ;
      aMvi[i][MVI_MATCH], ;
      "MVI->Match" ;
    )
    ** [960610] Das while stieg bisher auch dann schon aus, wenn nMontPs
    ** 0 geworden war. Das darf es aber nicht.
    ** Damit ein durch ZANU abgesetzter ZAU die AAW wieder entfriedigt
    ** wird.
    ** Siehe timtest.doc
    ** Seit 19991124 ORD_MVI_PARMATCH nur noch Match, nicht mehr IdPar
    do while ! bof() .and. MVI->Match == aMvi[i][MVI_MATCH] ;
                     .and. ! eof()
      ** 19991124 :
      ** JNLATTR_V wird fÅr Kreditreservierungen benutzt.
      **
      if MVI->IdPar == aMvi[i][MVI_IDPAR] ;
         .or. JNLATTR_V $  JnlAttrib(MVI->IdJnl)
        **
        ** [960521] Hier ist man zwar verfÅhrt, auch auf
        ** "if empty(MVI->MontUs)" zu testen. Aber das gÑbe Probleme
        ** a) wenn eine befriedigte Buchung Åbernommen wurde und
        **    entfriedigt werden soll.
        ** b) auch sowieso ist MVI->MontUs hier mîglicherweise noch nicht
        **    aktualisiert worden. Wir mÅssen also auf a[UPDATE_MONTUS]
        **    schauen.
        ** Doof ist nur, dass (seit heute) auch fÅr records, an denen sich
        ** nichts Ñndert, ein aadd() ins aUpdate gemacht wird. Aber
        ** wahrscheinlich stîrt das nicht.
        if (sat := SatLocate(JnlLocate(MVI->IdJnl),jnl)) != NIL
          if MVI->IdJnl+MVI->IdDoc+MVI->Line == aMvi[i][MVI_BACKMATCH] .or. ! SATATTR_M $ sat[SAT_ATTRIB]
            a := MviAddUpdate(aUpdate)
            // nMont : "um wieviel hier jetzt befriedigt wird"
            nMont := min(a[UPDATE_MONTUS],nMontPs)
            if nMont != 0
              nMontPs  -= nMont
              if SATATTR_N $ sat[SAT_ATTRIB]
                nMontCtb -= nMont
              endif
              **
              ** [960521] Testbeispiele fÅr nUbp :
              ** a) REG 1000,- ; AAW 1000,- ; AAB 1000,-
              ** b) AAW 1000,- ; KAS 1000,- ; KAS -1000,- (Annulierung)
              ** Durch die KAS -1000,- mu· die AAW entfriedigt werden !
              **
              if SATATTR_X $ sat[SAT_ATTRIB] // Backmatch entfriedigen
                cBackmatch := MVI->BackMatch
                nUbp := nMont
              endif
              if SATATTR_S $ sat[SAT_ATTRIB]
                nMontUs  -= nMont
              endif
              // aber wenn "ccb befriedigt ffo" ?
              * if ! empty(JnlIdCdc(MVI->IdJnl))
              *   nMontAbe -= nMont
              * elseif ! empty(MVI->Backmatch)
              *   nMontAbe -= nMont
              * endif
              ** [960514] Ein Automatikdokument wird in Journalen mit
              ** Attribut A nur dann erstellt, wenn ...
              **
              ** Warum zweimal negativ: z.B. wenn ein CCB einen ZCB
              ** Åberbefriedigt. Also ich habe 1000 in Auftrag gegeben, es
              ** werden aber 2000 vom Konto abgebucht.
              * if ! empty(MVI->Backmatch)
                nMontAbe -= nMont
              * endif
              nMontUsCtb += min(nMont,val(MVI->MontCtb))
              if ! SATATTR_P $ sat[SAT_ATTRIB]
                a[UPDATE_MONTUS] -= nMont
              endif
              if SATATTR_U $ sat[SAT_ATTRIB]
                CtbCollect( ;
                  aCtb, aMvi[i][MVI_DC], aMvi[i][MVI_IDBUD], ;
                  cPeriode, JnlIdCdc(MVI->IdJnl), ;
                  - nMont ;
                )
              endif
            endif // nMont != 0
          endif // BackMatch
        endif // sat != NIL
        if nUbp > 0 // .and. cBackMatch != NIL (unnîtig)
          if MVI->IdJnl + MVI->IdDoc + MVI->Line == cBackmatch
            a := MviAddUpdate(aUpdate)
            nUbp := min(nUbp,val(MVI->Mont) - a[UPDATE_MONTUS])
            a[UPDATE_MONTUS] += nUbp
            exit                // [960612]
            ** [960612] Der Loop wird seit [960610] ja noch nicht beendet,
            ** wenn das nMontPs auf 0 gesunken ist.
            ** Weil es nÑmlich noch ein nUbp
            ** geben kînnte. Dieses nUbp ist hier aber ebenfalls
            ** aufgebraucht. Also exit.
          endif
        endif
      endif
      skip -1
    enddo
    seek aMvi[i][MVI_DC] + aMvi[i][MVI_IDBUD] in BUD
    if abs(nMontAbe) > 0.001
      // [19971203]
      if JNLATTR_U $ jnl[JNL_ATTRIB] .and. ! empty(aMvi[i][MVI_BACKMATCH])
        * SetMsg(MsgIdJnlDoc() + " : öberbefriedigung verweigert.")
        SetMsg(aMvi[i][MVI_BACKMATCH] + " : öberbefriedigung (" ;
          + ltrim(ntomf(nMontAbe)) + ") verweigert.")
        lOkay := .f.
        exit
      endif
      if JNLATTR_A $ jnl[JNL_ATTRIB]
        if ! empty(BUD->IdJnl) // BUDATTR_A $ BUD->Attrib
          if (jnlAppend := JnlLocate(BUD->IdJnl)) != NIL
            a := array(IML_ALEN)
            a[IML_IDPAR     ] := aMvi[i][MVI_IDPAR     ]
            a[IML_NB1       ] := aMvi[i][MVI_NB1       ]
            a[IML_MONT      ] := ntom(nMontAbe)
            a[IML_MONTDEV   ] := ""
            a[IML_DATE      ] := UserDate()
            a[IML_IDBUD     ] := aMvi[i][MVI_IDBUD     ]
            a[IML_BACKMATCH ] := IMP->IdJnl + IMP->IdDoc + aMvi[i][MVI_LINE]
            a[IML_MATCH     ] := aMvi[i][MVI_MATCH     ]
            a[IML_EAMATCH   ] := aMvi[i][MVI_EAMATCH   ]
            a[IML_IDPAR2    ] := aMvi[i][MVI_IDPAR2    ]
            a[IML_IDPRJ     ] := aMvi[i][MVI_IDPRJ     ]
            a[IML_NB2       ] := aMvi[i][MVI_NB2       ]
            a[IML_COMPTE1   ] := aMvi[i][MVI_COMPTE1   ]
            a[IML_DC        ] := aMvi[i][MVI_DC]
            a[IML_JNL       ] := jnlAppend // BUD->IdJnl
            aadd(aImlSuite,a)
            ** [960423] die folgende Zeile ersetzt das Attribut
            ** "Schlusslicht-Journal". Das war sowieso nicht anwendbar fÅr
            ** automatisch generierte FFOs und AAWs. Also mussten wir
            ** einen besseren Weg finden.
            ** Denn "der Weg ist das Ziel". [martin luther king?]
            nMontUs := nMontAbe
            * nMontPs := 0 // wenn die ABE oder EBE dann spÑter doch nicht
            *              // erstellt werden kînnte, dann wÑre das hier
            *              // natÅrlich falsch...
            *              // fÅr Journale mit Attribut A muss also
            *              // obligatorisch auch ein SAT-Eintrag bestehen...
          endif
        endif
      endif
    endif
    **
    ** Wenn eine TRE-Buchung normalerweise durch ABE/EBE befriedigt wÅrde,
    ** diese ABE/EBE aber aufgrund des speziellen HH-Artikels *nicht*
    ** erstellt werden wird, dann wird die Buchung hier trotzdem befriedigt
    **
    ** [960610] Aber wenn bei einer ZAU-Buchung das gleiche passiert,
    ** dann muss die Buchung unbefriedigt stehen bleiben (weil ja noch
    ** eine TRE-Buchung folgen wird, die sich darauf bezieht).
    ** FÅr TRE-Buchungen ist jnl[JNL_IDCDC] leer. Aber vielleicht ist
    ** blo· ein zufÑlliger Zusammenhang? Jedenfalls klappt dat.
    **
    if JNLATTR_A $ jnl[JNL_ATTRIB] .and. ! empty(jnl[JNL_IDCDC])
      if empty(BUD->IdJnl)
        nMontUs := 0
      endif
    endif
    ** [War vor Kassentim gÅltig]
    ** Jetzt haben wir aber eine ABE, die ja normalerweise dazu bestimmt
    ** ist, einen CCB zu befriedigen. Sie wird normalerweise dadurch
    ** selbstbefriedigt. Nur wenn der CCB sich bereits auf einen ZAU bezog,
    ** dann ist dieser CCB ja schon befriedigt. Und dann wird die ABE nicht
    ** mehr selbstbefriedigt.
    ** Eine ABE/EBE, die niemanden zum selbstbefriedigen gefunden hat, ist
    ** trotzdem befriedigt. Das nennt man ein SCHLUSSLICHT-Journal.
    ** [960521] Wir tun es jetzt wieder rein fÅr Journal HHö
    if JNLATTR_L $ jnl[JNL_ATTRIB]
      nMontUs := 0
    endif
    aMvi[i][MVI_MONTUS]  := ntom(nMontUs)
    * if JNLATTR_U $ jnl[JNL_ATTRIB] .and. nMontPs < 0
    *   lOkay := .f.
    *   SetMsg("öberbefriedigung nicht erlaubt !")
    if empty(jnl[JNL_IDCDC])
      aMvi[i][MVI_MONTCTB] := ""
    * elseif JNLATTR_U $ jnl[JNL_ATTRIB]
    *   CtbCollect( ;
    *     aCtb, aMvi[i][MVI_DC], aMvi[i][MVI_IDBUD], ;
    *     cPeriode, jnl[JNL_IDCDC], ;
    *     nMontPs ;
    *   )
    *   aMvi[i][MVI_MONTCTB] := ntom(nMontPs)
    elseif JNLATTR_X $ jnl[JNL_ATTRIB]
      /**************************************************************
      [970814] bisher war es so: Journale mit Attribut N
      (ent-)zentralisieren hîchstens das, was die von ihnen
      befriedigten Buchungen zentralisiert hatten. Solche Journale
      waren ja auch nur dazu da, um bestehende Buchungen obligatorisch
      zu befriedigen (Journalattribut M war immer gesetzt). Aber
      jetzt haben wir neuerdings das Journal GUT, das auch ohne
      Backmatch kommen darf. Deshalb muss in den folgenden zwei
      Zeilen nicht blo· "nMontUsCtb", sondern "nMontUsCtb+nMontUs" kommen.
      Dadurch ist auch das bisherige Fehlverhalten im folgenden
      (freilich unlogischem) Beispiel behoben:
        1) REG   500   (MontCtb = 500)
        2) ARE  1000   MontCtb bisher nur -500, jetzt -1000
      Oder :
        1) REG    300  (MontCtb = 300)
        2) ARE   1000  (MontCtb = 300 + 700 = 1000)
        und insbesondere :
        1) BST    300  (MontCtb = 300)
        2) REG    300  (MontCtb = 0)
        3) ARE   1000  (MontCtb = 0 + 700 = 700)  (!)
      ****************************************************************/
      if JNLATTR_N $ jnl[JNL_ATTRIB]
        CtbCollect( ;
          aCtb, aMvi[i][MVI_DC], aMvi[i][MVI_IDBUD], ;
          cPeriode, jnl[JNL_IDCDC], ;
          -(nMontUsCtb+nMontUs) ;
        )
      else
        CtbCollect( ;
          aCtb, aMvi[i][MVI_DC], aMvi[i][MVI_IDBUD], ;
          cPeriode, jnl[JNL_IDCDC], ;
          (nMontUsCtb+nMontUs) ;
        )
      endif
      ** MVI->MontCtb wird *nicht* negativiert
      ** (das wei· der Benutzer ja, dass ARE, GUT & Co. negativ sind)
      aMvi[i][MVI_MONTCTB] := ntom(nMontUsCtb+nMontUs)
    else
      if JNLATTR_N $ jnl[JNL_ATTRIB]
        CtbCollect( ;
          aCtb, aMvi[i][MVI_DC], aMvi[i][MVI_IDBUD], ;
          cPeriode, jnl[JNL_IDCDC], ;
          - nMontCtb ;
        )
      else
        CtbCollect( ;
          aCtb, aMvi[i][MVI_DC], aMvi[i][MVI_IDBUD], ;
          cPeriode, jnl[JNL_IDCDC], ;
          nMontCtb ;
        )
      endif
      aMvi[i][MVI_MONTCTB] := ntom(nMontCtb) // aMvi[i][MVI_MONT]
    endif
  next i
close area
RETURN lOkay

FUNCTION MviAddUpdate(aUpdate)
local a
local i
for i := 1 to len(aUpdate)
  RETURN aUpdate[i] if aUpdate[i][UPDATE_RECNO] == recno()
next i
a := array(UPDATE_ALEN)
a[UPDATE_RECNO]  := recno()
a[UPDATE_MONTUS] := val(MVI->MontUs)
aadd(aUpdate,a)
RETURN a



**
** CtbCollect()
**
FUNCTION CtbCollect( ;
 aCtb, cIdCtr, cIdBud, ;
 cPeriode, cIdCdc, ;
 nMont ;
)
local i
local ctb := NIL
for i := 1 to len(aCtb)
  if aCtb[i][CTB_IDCDC] == cIdCdc // jnl[JNL_IDCDC] [960905]
    if aCtb[i][CTB_PERIODE] == cPeriode
      if aCtb[i][CTB_DC] == cIdCtr
        if aCtb[i][CTB_IDBUD] == cIdBud
          ctb := aCtb[i]
        endif
      endif
    endif
  endif
next i
* if JNLATTR_N $ jnl[JNL_ATTRIB]        [960905]
*   nMont := - nMont
* endif
if ctb == NIL
  ctb := array(CTB_ALEN)
  ctb[CTB_PERIODE] := cPeriode
  ctb[CTB_IDCDC]   := cIdCdc // jnl[JNL_IDCDC]
  ctb[CTB_DC]      := cIdCtr
  ctb[CTB_IDBUD]   := cIdBud
  ctb[CTB_MONT]    := nMont
  aadd(aCtb, ctb)
else
  ctb[CTB_MONT]  += nMont
endif
RETURN NIL


FUNCTION ImpMviGenerate(jnl,aMvi,aUpdate)
local i
local lOkay := .f.
open area oMvi()
  lOkay := .t.
  for i := 1 to len(aMvi)
    if dbAddRec()
      MVI->IdJnl     := IMP->IdJnl
      MVI->IdDoc     := IMP->IdDoc
      MVI->Periode   := IMP->Periode
      MVI->Date1     := IMP->Date1
      MVI->Date2     := IMP->Date2
      MVI->Line      := aMvi[i][MVI_LINE     ]
      MVI->IdPar     := aMvi[i][MVI_IDPAR    ]
      MVI->NB1       := aMvi[i][MVI_NB1      ]
      MVI->Mont      := aMvi[i][MVI_MONT     ]
      MVI->Date      := aMvi[i][MVI_DATE     ]
      MVI->DC        := aMvi[i][MVI_DC       ]
      MVI->IdBud     := aMvi[i][MVI_IDBUD    ]
      MVI->BackMatch := aMvi[i][MVI_BACKMATCH]
      MVI->Match     := aMvi[i][MVI_MATCH    ]
      MVI->EaMatch   := aMvi[i][MVI_EAMATCH  ]
      if empty(aMvi[i][MVI_IDPAR2])
        MVI->IdPar2    := aMvi[i][MVI_IDPAR    ]
      else
        MVI->IdPar2    := aMvi[i][MVI_IDPAR2   ]
      endif
      MVI->IdPrj     := aMvi[i][MVI_IDPRJ    ]
      MVI->NB2       := aMvi[i][MVI_NB2      ]
      MVI->Compte1   := aMvi[i][MVI_COMPTE1  ]
      MVI->MontUs    := aMvi[i][MVI_MONTUS   ]
      MVI->MontCtb   := aMvi[i][MVI_MONTCTB  ]
      if ! OnMviGenerate()
        SendConsole(MsgIdJnlDoc()+" : OnMviGenerate() failed !")
      endif
      unlock record
    else
      lOkay := .f.
      exit
    endif
  next i
  for i := 1 to len(aUpdate)
    goto aUpdate[i][UPDATE_RECNO]
    if ddRecLock()
      MVI->MontUs := ntom(aUpdate[i][UPDATE_MONTUS])
      unlock record
    else
      lOkay := .f.
    endif
  next i
close area
RETURN lOkay


FUNCTION ImlMviCollect(aMvi)
local a := array(MVI_ALEN)
* RETURN .f. if TaskInter()
a[MVI_LINE     ] := IML->Line
a[MVI_IDPAR    ] := IML->IdPar
a[MVI_NB1      ] := IML->NB1
a[MVI_DATE     ] := IML->Date
a[MVI_IDBUD    ] := IML->IdBud
a[MVI_BACKMATCH] := IML->BackMatch
a[MVI_MATCH    ] := IML->Match
a[MVI_EAMATCH  ] := IML->EaMatch
a[MVI_IDPAR2   ] := IML->IdPar2
a[MVI_IDPRJ    ] := IML->IdPrj
a[MVI_NB2      ] := IML->NB2
a[MVI_COMPTE1  ] := IML->Compte1
a[MVI_DC       ] := IML->DC
* if JNLATTR_N $ jnl[JNL_ATTRIB]
*   a[MVI_MONT     ] := ntom(-val(IML->Mont))
* else
  a[MVI_MONT     ] := IML->Mont
* endif
aadd(aMvi,a)
* RETURN .f. if TaskInter()
RETURN .t.

**
** CtbUpdate()
**
FUNCTION CtbUpdate(aCtb)
local i
local lOkay := .f.
open area oCtb()
  lOkay := .t.
  for i := 1 to len(aCtb)
    Purzel()
    seek aCtb[i][CTB_DC] + aCtb[i][CTB_IDBUD] + aCtb[i][CTB_PERIODE] + aCtb[i][CTB_IDCDC]
    if eof()
      if dbAddRec()
        CTB->DC      := aCtb[i][CTB_DC]
        CTB->IdCdc   := aCtb[i][CTB_IDCDC]
        CTB->IdBud   := aCtb[i][CTB_IDBUD]
        CTB->Periode := aCtb[i][CTB_PERIODE]
        CTB->IdCdc   := aCtb[i][CTB_IDCDC]
        CTB->Mont    := ntom(;
          aCtb[i][CTB_MONT],;
          DevDecPos(DevDefault(LastPeriode(aCtb[i][CTB_PERIODE]))),;
          len(CTB->Mont);
        )
        unlock record
      else
        lOkay := .f.
        exit
      endif
    elseif ddRecLock()
      CTB->Mont    := ntom(;
        val(CTB->Mont)  + aCtb[i][CTB_MONT],;
        DevDecPos(DevDefault(LastPeriode(aCtb[i][CTB_PERIODE]))),;
        len(CTB->Mont);
      )
      unlock record
    else
      lOkay := .f.
      exit
    endif
  next i
close area
RETURN lOkay

**
** ImpGetMemo()
**
FUNCTION ImpGetMemo(lLock)
if lLock
  RETURN MnuDone() if ! ddRecLock()
else
  select IMP
endif
open window ("Memo-Text " + IMP->IdJnl + " " + IMP->IdDoc) size 20, 80
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ddOnPreEdit(oImp()), 76 ;
  )
close window
    * TplValue(TPLTYPE_IMP,JnlIdTpl(IMP->IdJnl),{||TXT->Largeur}) ;
if lLock
  unlock record
else
  select IML
endif
RETURN .f.


FUNCTION ImpWait(win)
local b := oIml()
local cIdJnl := IMP->IdJnl
local cIdDoc := IMP->IdDoc
local a
local jnl := JnlLocate(IMP->IdJnl)
RETURN ClearWaitWin(win) if jnl == NIL
RETURN NIL if nextkey() != 0
if (a := ImpImlInit(jnl)) != NIL
  open area b, oPar(), oBud()
    softseek IMP->IdJnl + IMP->IdDoc
    do while IML->IdJnl + IML->IdDoc == IMP->IdJnl + IMP->IdDoc
      ImlAfter()
      Purzel()
      skip
    enddo
    edit data b key IML->IdJnl + IML->IdDoc ;
      value    cIdJnl + cIdDoc             ;
      create   {||DDCREATE_FAIL} ;
      start    bottom                 ;
      mode     wait  ;
      window   win ;
      query ("IML"+JnlIdDbv(cIdJnl)) ;
      title ("Inhalt " + cIdJnl + " " + cIdDoc)
  close area
  ImlRestore(a)
endif
RETURN NIL

FUNCTION ImpPreEdit
if IMP->Etat == DocStatClosed() .or. IMP->Etat == DocStatError()
  SetMsg("Verweigert. Das Dokument ist registriert.")
  RETURN .f.
endif
RETURN .t.

FUNCTION ImlPreEdit
if IMP->IdJnl!=IML->IdJnl.or.IMP->IdDoc!=IML->IdDoc
  seek IML->IdJnl+IML->IdDoc in IMP
  if eof() in IMP
    RETURN USRATTR_S $ UsrAttrib()
  endif
endif
if IMP->Etat == DocStatClosed() .or. IMP->Etat == DocStatError()
  SetMsg("Verweigert. Das Dokument ist registriert.")
  RETURN .f.
endif
RETURN .T.

FUNCTION MviPreDelete
RETURN .f. if ! USRATTR_W $ UsrAttrib()
RETURN !SetMsg("Lîschen verweigert weil IML-Record existiert.") ;
  if DbfPeek(oIml(),MVI->IdJnl+MVI->IdDoc+MVI->Line,".t.",.f.)
RETURN ConfirmDelete()

**
**
**
FUNCTION ImpPreDelete
local lOkay := .f. // nReturn := DDDEL_FAIL
local jnl := JnlLocate(IMP->IdJnl)
RETURN .f. if ! DocDelete(jnl,IMP->IdDoc)
open area oIml()
  lOkay := .t. // nReturn := DDDEL_NOCONFIRM
  softseek IMP->IdJnl + IMP->IdDoc
  do while IML->IdJnl + IML->IdDoc == IMP->IdJnl + IMP->IdDoc
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
#ifdef DEF_MVA
  RETURN .f. if ! lOkay
  lOkay := .f. // nReturn := DDDEL_FAIL
  open area oMva()
    ddSetOrder(ORD_MVA_DOC)
    lOkay := .t. // nReturn := DDDEL_NOCONFIRM
    softseek IMP->IdJnl + IMP->IdDoc
    do while ! eof() .and. MVA->IdJnl + MVA->IdDoc == IMP->IdJnl + IMP->IdDoc
      if ddRecLock()
        delete
        unlock record
      else
        lOkay := .f.
      endif
      skip
    enddo
  close area
#endif DEF_MVA
RETURN lOkay // nReturn


FUNCTION ImpPostEdit()
if (! empty(IMP->IdBud)) .or. JNLATTR_B $ JnlAttrib(IMP->IdJnl)
  RETURN .f. if ! BudExist(JnlDC(IMP->IdJnl),IMP->IdBud)
  if empty(IMP->IdPrj)
    IMP->IdPrj := BUD->IdPrj
  endif
  * RETURN .f. if ! PrjBudValidate(JnlDc(IMP->IdJnl))
endif
* if ! empty(IMP->IdPrj)
*   RETURN .f. if ! PrjExist(IMP->IdPrj)
* endif
if (! empty(IMP->IdPar)) .or. JNLATTR_P $ JnlAttrib(IMP->IdJnl)
  RETURN .f. if ! ParExist(IMP->IdPar)
  if empty(IMP->Compte1)
    IMP->Compte1 := PAR->Compte1
  endif
  * if empty(IMP->Date3)
  *   IMP->Date3 := IfcDate2(IMP->IdJnl,PAR->IdMfc,IMP->Date1)
  * endif
endif
if ! empty(IMP->IdPar2)
  RETURN .f. if ! ParExist(IMP->IdPar2)
  if empty(IMP->Compte1)
    IMP->Compte1 := PAR->Compte1
  endif
endif
if IMP->Etat == DocStatNew()
  * 19980716 : Wenn das letzte Feld mit [F1] ausgewÑhlt worden war,
  * ging ImpImlEdit() nicht los...
  * if nKey == K_ENTER .or. nKey == K_F10
  if nKey == K_ENTER .or. nKey == K_F10
  * if nKey != K_ESC
    ImpImlEdit()
  endif
endif
if IMP->Etat == DocStatNew()
  SetMsg(MsgIdJnlDoc() + " : Dokument ist nicht fertig eingegeben.")
  RETURN .f. if ! USRATTR_E $ UsrAttrib()
endif
RETURN .t.


FUNCTION ImlSumme
local nSum := 0
ddScan({|| nSum += DcValue(DC_DEBIT), .t.})
RETURN nSum

FUNCTION ImlBudAvail
* local jnl
RETURN space(LenMntF()) if ! BudExist(IML->DC,IML->IdBud)
* RETURN space(LenMntF()) if (jnl := JnlLocate(IML->IdJnl)) == NIL
RETURN ntomf(BudAvail( ;
  IML->DC,IML->IdBud,;
  PerPerCtr(IMP->Periode), ;
  MemIdCdc ;
))

FUNCTION CtbBudAvail
RETURN (BudAvail( ;
  CTB->DC,CTB->IdBud,;
  CTB->Periode, ;
  CTB->IdCdc ;
))


FUNCTION PerPerCtr(cPeriode)
local nYear
RETURN "200" + substr(cPeriode,2,1) if left(cPeriode,1) == "A"
RETURN "201" + substr(cPeriode,2,1) if left(cPeriode,1) == "B"
RETURN "20" + left(cPeriode,2) if set(_SET_EPOCH) >= 2000
RETURN "19" + left(cPeriode,2)

FUNCTION ImpSolde2
RETURN snMont if IMP->IdDev == DevDefault(IMP->Periode)
RETURN snMontDev

**
** ImpDevValidate() : fields VEN->IdDev
**
FUNCTION ImpDevValidate()
if empty(IMP->IdDev)
  IMP->IdDev  := PAR->IdDev
  if empty(IMP->IdDev)
    IMP->IdDev  := JnlIdDev(IMP->IdJnl)
  endif
  if empty(IMP->IdDev)
    IMP->IdDev  := DevDefault(IMP->Periode)
  endif
endif
RETURN .f. if ! DevExist(IMP->IdDev)
IMP->Cours := DevCours(IMP->IdDev,IMP->Periode)
ddRefreshCurrent()
RETURN .t.


FUNCTION ImlDevDecPos() ; RETURN saDev[DEV_DECPOS]

FUNCTION GsbImlDev(cDC,x)
local nMont
if x == NIL
  if eof() // 20070801 recno() == lastrec() + 1
    RETURN space(LenMont()) if IMP->IdDev == DevDefault(IMP->Periode)
    if JNLATTR_S $ saJnl[JNL_ATTRIB] .and. ! empty(IMP->Mont2)
      nMont := val(IMP->Mont2) - snMontDev     // msg_bleibt
      if saJnl[JNL_DC] != cDC
        RETURN space(LenMont()) if nMont < 0
        RETURN ntom(nMont,saDev[DEV_DECPOS])
      else
        RETURN ntom(-nMont,saDev[DEV_DECPOS]) if nMont < 0
        RETURN space(LenMont())
      endif
    else
      nMont := snMontDev
      if saJnl[JNL_DC] == cDC
        RETURN space(LenMont()) if nMont < 0
        RETURN ntom(nMont,saDev[DEV_DECPOS])
      else
        RETURN ntom(-nMont,saDev[DEV_DECPOS]) if nMont < 0
        RETURN space(LenMont())
      endif
    endif
  endif
  RETURN space(LenMont()) if IML->DC != cDC
  RETURN IML->MontDev
endif
IML->DC := cDC
IML->MontDev := x
RETURN NIL

**
** ImlMontValidate() --
**
FUNCTION ImlMontValidate
local nMontDev
local nDecPos  := saDev[DEV_DECPOS]
local dev
* RETURN .f. if ! ImlSetMont() // (ggf. fÅllen falls leer)
RETURN .f. if ! NumValidate(IML->Mont)
if saDev[DEV_IDDEV] == DevDefault(IMP->Periode)
  if ParExist(IML->IdPar) .and. ! empty(PAR->IdDev)
    if PAR->IdDev != DevDefault(IMP->Periode)
      nMontDev := Db2Dev(PAR->IdDev,IMP->Periode,val(IML->Mont))
      * 20010523 nMontDev := val(IML->Mont) / val(DevCours(PAR->IdDev,IMP->Periode))
      nDecPos := DevDecPos(PAR->IdDev)
    endif
  endif
else
  nMontDev := Db2Dev(saDev[DEV_IDDEV],IMP->Periode,val(IML->Mont))
  * 20010523 nMontDev := val(IML->Mont) / snCours
endif
if nMontDev == NIL
  IML->MontDev := ""
else
  IML->MontDev := ntom( nMontDev, nDecPos )
endif
RETURN .t. // FnlDifCheck()

**
** ImlDevValidate()
**
FUNCTION ImlDevValidate
local nMont
local nDecPos  := saDev[DEV_DECPOS]
local nMontDev := val(IML->MontDev)
if saDev[DEV_IDDEV] == DevDefault(IMP->Periode)
  if ParExist(IML->IdPar) .and. ! empty(PAR->IdDev)
    if PAR->IdDev != DevDefault(IMP->Periode)
      nMont := Dev2Db(PAR->IdDev,IMP->Periode,nMontDev)
      nDecPos := DevDecPos(PAR->IdDev)
    endif
  endif
else
  nMont := Dev2Db(IMP->IdDev,IMP->Periode,nMontDev)
  * IML->Mont := ntom( val(IML->MontDev) * snCours )
  // IML->Mont := ntom( val(IML->MontDev) * snCours )
endif
if nMont == NIL
  IML->MontDev := ""
else
  IML->MontDev := ntom(nMontDev,nDecPos)
  if IML->Mont != ntom(nMont)
    if ! USRATTR_E $ UsrAttrib() .or. Confirm("Betrag GW anpassen?")
      IML->Mont := ntom(nMont)
    endif
  endif
endif
RETURN .t.

FUNCTION ImpPerValidate
local jnl := JnlLocate(IMP->IdJnl)
local per := PerLocate(IMP->Periode)
if per == NIL
  SetMsg(IMP->Periode + MsgPerExist())
  RETURN .f.
endif
if jnl == NIL
  SetMsg(IMP->IdJnl + MsgJnlExist())
  RETURN .f.
endif
if ! PerChkDate(per,UserDate(),jnl)
  SetMsg(MsgPerClosed(IMP->Periode,UserDate(),IMP->IdJnl))
  RETURN .f.
endif
if empty(jnl[JNL_IDDEV])
  IMP->IdDev := DevDefault(IMP->Periode)
else
  IMP->IdDev := jnl[JNL_IDDEV]
endif
RETURN ImpDevValidate()




#endif DEF_IMP

FUNCTION ParValidate(cIdPar) // ValIdPar(cIdPar)
RETURN .t. if empty(cIdPar)
RETURN .f. if ! ParExist(cIdPar)
RETURN .f. if ! OnParSelect()
#ifdef DEF_IMP
  if empty(FIELD->IdPar2)
    cIdPar := FIELD->IdPar
  else
    cIdPar := FIELD->IdPar2
  endif
  seek cIdPar in PAR
  // 20080703 FIELD->Compte1 := PAR->Compte1
  FIELD->Compte1 := ImlCompte()
#endif DEF_IMP
RETURN .t. // ph_Refresh()


#ifdef DEF_VCB

FUNCTION BudVcbUpdate()
local aVcb := VcbList()
local i
local aSum := array(len(aVcb))
local nCount := 0
local cDC
local cIdBud
local cMac
open area oCtb(), oBud()
  go top
  do while ! eof()
    MsgDisp2(ntrim0(nCount++ / lastrec() * 100) + "%")
    if TaskInter() ; exit ; endif
    cDC := BUD->DC
    cIdBud := BUD->IdBud
    for i := 1 to len(aVcb)
      aSum[i] := 0
    next i
    do while ! eof() .and. CTB->IdBud == cIdBud ;
                     .and. CTB->DC == cDC
      for i := 1 to len(aVcb)
        if &(aVcb[i][VCB_EXPR])
          aSum[i] += val(CTB->Mont)
        endif
      next i
      skip
    enddo
    select BUD
    seek cDC + cIdBud
    if eof()
      Warning(cIdBud + " : Artikel nicht gefunden !")
    elseif ddRecLock()
      for i := 1 to len(aVcb)
        cMac := "BUD->" + aVcb[i][VCB_IDVCB]
        &(cMac) := ntom(aSum[i])
      next i
      unlock record
    endif
    select CTB
    skip
  enddo
close area
RETURN NIL

#endif DEF_VCB



