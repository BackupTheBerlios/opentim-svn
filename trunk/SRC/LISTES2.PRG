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
  #define MSG001  " uniquement les mouvements non lettrÇs"
  #define MSG003  " aussi les comptes non mouvementÇs"
  static MSG006 := "Balance comptes particuliers"
  * #define MSG007  "Soldes comptes gÇnÇraux"
  * #define MSG008  "Journal centralisateur"
  #define MSG009  "Regrouper les documents de montant infÇrieur Ö "
  #define MSG010  "Montants < "
  #define MSG011  "Analyse des achats..."
  #define MSG012  "Analyse des ventes..."
  * static MSG013 := "Listes mensuelles"
  * static MSG014 := "Listes annuelles"
  * #define MSG015  " : rupture de sÇquence !"
  #define MSG016  "                                                        "
  #define MSG017  "Compte                                                  "
  #define MSG018  "ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ   "
  * #define MSG019  "O pour continuer l'avertissement en cas de rupture :"
  #define MSG023  "ƒƒƒƒƒƒ PERIODE ƒƒƒƒƒƒ"
  #define MSG024  "     DÇbit     CrÇdit"
  #define MSG025  "ƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ"
  #define MSG026  "Liste des clients importants"
  #define MSG027  "Statistique"
  #define MSG028  "Journal "
  #define MSG029  "Liste de contrìle inventaire"
  #define MSG030  "   ƒƒƒƒ SOLDE FINAL ƒƒƒƒ"
  #define MSG031  "     DÇbiteur  CrÇditeur"
  #define MSG032  "   ƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ"
  #define MSG033  "SIGNALETIQUES"
  #define MSG034  "Recherche clients semblables"
  #define MSG035  "GESTION DU STOCK"
  #define MSG036  "Statistique prestations"
  #define MSG037  "COMPTABILITE"
  #define MSG038  "Marge thÇorique"
  #define MSG039  "FACTURATION"
  * #define MSG040  "Rappels de paiement"
  #define MSG042  " Ö "
  #define MSG044  " spÇcifier tous les comptes mouvementÇs"
  #define MSG045  "Jnl  N¯Doc     Date DÇsignation                                       prix net T        TVA  prix brut"
  #define MSG046  "ƒƒƒ ƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ ƒ ƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ"
  * #define MSG047  "Marge thÇorique"
  #define MSG048  "                                                         P.V.       P.A."
  #define MSG049  "N¯doc.    Date     Client LibellÇ                        hors TVA   hors TVA        Marge"
  #define MSG050  "ƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ"
  #define MSG051  "Impressions"
  #define MSG052  " contenu des documents"
  #define MSG053  " imputations par document"
  static MSG054  := " dÇtail de chaque document"
  * #define MSG055  "           ƒ ƒƒƒƒƒƒ ƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ ƒ ƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ"
  * #define MSG056  "Document      Date     (cours)"
  * #define MSG057  "ƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ"
  * #define MSG061  "Liste de pointage"
  #define MSG064  "uniquement le client "
  #define MSG065  "uniquement le fournisseur "
  #define MSG066  " liste dÇtaillÇe"
  #define MSG067  "RÇgimes T.V.A. "
  #define MSG068  " sur disquettes"
  #define MSG069  "Chiffre d'affaires minimum "
  #define MSG070  "TriÇ par (Chiffre/Firme) "
  #define MSG071  " avec les montants "
  #define MSG072  "PrÇparation en cours..."
  #define MSG073  "Montant minimum "
  #define MSG074  "Statistique achat/vente"
  #define MSG075 "Ventilation par groupe d'articles :"
  #define MSG076 "Inventaire du "
  static MSG_WRN035 := " : colonne de facturier invalide "
#endif

#ifdef LG_GERMAN
  #define MSG001  " nur offene Bewegungen drucken"
  static MSG006 := "Saldenliste Partnerkonten"
  #define MSG028  "Journal "
  #define MSG042  " bis "
  static MSG054 := " Dokumente einzeln anfÅhren"
#endif

#ifdef LG_EN
  #define MSG001  " nur offene Bewegungen drucken"
  static MSG006 := "Saldenliste Partnerkonten"
  #define MSG028  "Journal "
  #define MSG042  " bis "
  static MSG054 := " Dokumente einzeln anfÅhren"
#endif

static sdVon := NIL
static sdBis := NIL

static snHclSubCount
static snDocCount
static slMustUnderline := .f.


#ifdef DEF_JNL

static scIdDoc := NIL  // pour test Rupture de sÇquence
static scIdJnl := NIL  // pour test Rupture de sÇquence
static slRupture := .f.

#endif DEF_JNL

#ifdef DEF_VEN

static sdVnlDate1
static sdVnlDate2

static snTotBase := 0
static snTotTaxe := 0
static snSeq := 0

#endif DEF_VEN

#ifdef DEF_IMP

#define TMP_PERIODE   1
#define TMP_SERVICE   2
#define TMP_DEBIT     3
#define TMP_CREDIT    4
* #define TMP_DC        5
#define TMP_OLDDEBIT  5
#define TMP_OLDCREDIT 6
#define TMP_IDJNL     7
#define TMP_IDDEV     8
#define TMP_ALEN      8

**
** ImpJnlPrint()
**
FUNCTION ImpJnlPrint( ;
  jnl,cPrintDoc,cIdDoc1,cIdDoc2, ;
  aTmpTot,aJnlTot,aTmpJnl,aTmpGrj ;
)
local cTit1
local cTit2
local cLine
local i
local nRecNo
local nRecNo2
local nMont
local aSum := {}
local dDate := UserDate()
local lOkay := .t.
cTit1 := padr("Beleg Nr.",LenIdJnl() + LenIdDoc() + 5)
cTit2 := repl("ƒ",LenIdJnl() + LenIdDoc() + 5)
cTit1 += " " + padr("BuchDat",len(dtoc(UserDate())))
cTit2 += " " + repl("ƒ",len(dtoc(UserDate())))
cTit1 += " " + padr("BelDat",len(dtoc(UserDate())))
cTit2 += " " + repl("ƒ",len(dtoc(UserDate())))
cTit1 += " " + padr("Partner/EmpfÑnger",35)
cTit2 += " " + repl("ƒ",35)
cTit1 += " " + padr("Gegenstand/Ext.Ref.",20)
cTit2 += " " + repl("ƒ",20)
cTit1 += " " + padr("Artikel",20)
cTit2 += " " + repl("ƒ",20)
cTit1 += " " + padr("D",1)
cTit2 += " " + repl("ƒ",1)
cTit1 += " " + padr("Bezug",LenIdJnl()+LenIdDoc()+LEN_POS)
cTit2 += " " + repl("ƒ",LenIdJnl()+LenIdDoc()+LEN_POS)
cTit1 += " " + padr("RÅckbezug",LenIdJnl()+LenIdDoc()+LEN_POS)
cTit2 += " " + repl("ƒ",LenIdJnl()+LenIdDoc()+LEN_POS)
cTit1 += " " + padr("Per.",4)
cTit2 += " " + repl("ƒ",4)
cTit1 += " " + padr("Einnahmen",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
cTit1 += " " + padr("Ausgaben",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
cTit1 += " " + padr("Nr.KasJnl",LenIdIml())
cTit2 += " " + repl("ƒ",LenIdIml())
p_SetWidth(len(cTit2))
ddCloseAll()
open area oMvi(), oPar(), oBud(), oImp(), oIml()
SetPageHeader( {|| ;
  PrintHeader( ;
    "Journal " + jnl[JNL_IDJNL] + " : " + trim(jnl[JNL_NAME]),;
    PerText({||.f.}) ;
  ), ;
  PrintLine(cTit1) ,;
  PrintLine(cTit2)  ;
})
softseek jnl[JNL_IDJNL] + trim(cIdDoc1)
do while ! eof() .and. MVI->IdJnl == jnl[JNL_IDJNL]
  if TaskInter() ; lOkay := .f. ; exit ; endif
  if ! empty(cIdDoc2) .and. MVI->IdDoc > cIdDoc2 ; exit ; endif
  Purzel()
  if BudExist(MVI->DC,MVI->IdBud)
    nMont := val(MVI->Mont)
    if ChkPeriode(MVI->Periode) < 0
      TmpCollect( ;
        aTmpTot,NIL,;
        PerPerCtr(MVI->Periode), ;
        NIL,MVI->DC,0, nMont ;
      )
      TmpCollect( ;
        aTmpJnl,jnl[JNL_IDJNL],;
        NIL, ;
        NIL,MVI->DC,0, nMont, ;
        jnl[JNL_IDDEV] ;
      )
      TmpCollect( ;
        aJnlTot,NIL,;
        PerPerCtr(MVI->Periode), ;
        NIL,MVI->DC,0, nMont, ;
        jnl[JNL_IDDEV] ;
      )
      TmpCollect( ;
        aTmpGrj,jnl[JNL_IDGRJ],;
        PerPerCtr(MVI->Periode), ;
        BUD->Service,MVI->DC,0, val(MVI->Mont) ;
      )
    elseif ChkPeriode(MVI->Periode) == 0
      if cPrintDoc == BUTTON_ON
        cLine := MVI->IdJnl + " " + MVI->IdDoc + " " + MVI->Line
        cLine += " " + dtoc(MVI->Date)
        cLine += " " + dtoc(MVI->Date2)
        cLine += " " + padr(MVI->IdPar + " " + ParField(MVI->IdPar,{||PAR->Firme}),35)
        cLine += " " + padr(MVI->NB1,20)
        cLine += " " + MVI->DC
        cLine += " " + SayIdBud(MVI->IdBud)
        cLine += " " + BUD->Service
        cLine += " " + MVI->Match
        cLine += " " + MVI->BackMatch
        cLine += " " + MVI->Periode
        if MVI->DC == DC_DEBIT
          cLine += " " + space(LenMntF())
          cLine += " " + ntomf(nMont)
        else
          cLine += " " + ntomf(nMont)
          cLine += " " + space(LenMntF())
        endif
        seek MVI->IdJnl + MVI->IdDoc + MVI->Line in IML
        cLine += " " + IML->IdIml
        PrintLine(cLine)
        cLine := space(LenIdJnl() + LenIdDoc() + 23)
        cLine += " " + padr(MVI->IdPar2 + " " + ParField(MVI->IdPar2,{||PAR->Firme}),35)
        cLine += " " + padr(MVI->NB2,20)
        PrintLine(cLine)
      endif
      TmpCollect( ;
        aTmpTot,NIL,;
        PerPerCtr(MVI->Periode), ;
        NIL,MVI->DC,nMont,0 ;
      )
      TmpCollect( ;
        aTmpJnl,jnl[JNL_IDJNL],;
        NIL, ;
        NIL,MVI->DC,nMont,0, ;
        jnl[JNL_IDDEV] ;
      )
      TmpCollect( ;
        aJnlTot,NIL,;
        PerPerCtr(MVI->Periode), ;
        NIL,MVI->DC, nMont, 0, ;
        jnl[JNL_IDDEV] ;
      )
      TmpCollect( ;
        aTmpGrj,jnl[JNL_IDGRJ],;
        PerPerCtr(MVI->Periode), ;
        BUD->Service,MVI->DC, val(MVI->Mont), 0 ;
      )
    endif
  else
    if ! Confirm(MsgIdJnlDoc() + " : " + SetMsg(),MsgContinue())
      lOkay := .f.
      exit
    endif
  endif
  skip
enddo
*PrintLine()
*cLine := "Jnl "
*cLine += " " + padl("Saldo ltz",LenMont())
*cLine += " " + padl("Einnahmen",LenMont())
*cLine += " " + padl("Ausgaben",LenMont())
*cLine += " " + padl("Saldo",LenMont())
*PrintLine(cLine)
*cLine := "    "
*cLine += " " + padl("def. Ausd.",LenMont())
*cLine += " " + padl("Ausdruck",LenMont())
*cLine += " " + padl("Ausdruck",LenMont())
*cLine += " " + padl("neu",LenMont())
*PrintLine(cLine)
*PrintLine(repl("ƒ",len(cLine)))
*for i := 1 to len(aTmpJnl)
*  * cLine := aTmpJnl[i][TMP_IDJNL]
*  cLine := space(LEN_PERIODE)
*  cLine += " " + ntomf(  ;
*    aTmpJnl[i][TMP_OLDCREDIT] - ;
*    aTmpJnl[i][TMP_OLDDEBIT] ;
*  )
*  cLine += " " + ntomf(aTmpJnl[i][TMP_CREDIT])
*  cLine += " " + ntomf(aTmpJnl[i][TMP_DEBIT])
*  cLine += " " + ntomf( ;
*    (aTmpJnl[i][TMP_OLDCREDIT]+aTmpJnl[i][TMP_CREDIT]) ;
*    - (aTmpJnl[i][TMP_OLDDEBIT]+aTmpJnl[i][TMP_DEBIT]) ;
*  )
*  PrintLine(cLine)
*next i
*PrintLine(repl("ƒ",len(cLine)))
*for i := 1 to len(aTmpTot)
*  * cLine := space(LenIdJnl())
*  * cLine += " " + ntomf(  ;
*  cLine := aTmpTot[i][TMP_PERIODE]
*  cLine += " " + ntomf( ;
*    aTmpTot[i][TMP_OLDCREDIT] - ;
*    aTmpTot[i][TMP_OLDDEBIT] ;
*  )
*  cLine += " " + ntomf(aTmpTot[i][TMP_CREDIT])
*  cLine += " " + ntomf(aTmpTot[i][TMP_DEBIT])
*  cLine += " " + ntomf( ;
*    (aTmpTot[i][TMP_OLDCREDIT]+aTmpTot[i][TMP_CREDIT]) ;
*    - (aTmpTot[i][TMP_OLDDEBIT]+aTmpTot[i][TMP_DEBIT]) ;
*  )
*  PrintLine(cLine)
*next i
*PrintLine()
close area
* close printer
ddCloseAll()
delete file (".\MVITMP"+ntx_ext())
RETURN lOkay

**
** ImlJournal() - Kassenjournal
**
FUNCTION ImlJournal(cPeriode,nArchive)
local cFinal := BUTTON_OFF
local cIdIml
local cTit1 := padr("BuchDat",len(dtoc(UserDate())))
local cTit2 := repl("ƒ",len(dtoc(UserDate())))
local cLine
local aTmpTot := {}
local aTmpJnl := {}
local aJnlTot := {}
local aTmpGrj := {}
local jnl
local nRecNo
local nRecNo2
local nMont
local nMontDev
local nCount := 0
local aSum := {}
local dDate  := UserDate()
local dDate2 := ctod("")
local cIdIml2 := space(LenIdIml())
local cHeader1 := ""
local cHeader2 := "Bis "
local lOkay := .f.
local nSaveArchive
default cPeriode to space(LEN_PERIODE)
open window ("Kassenjournal") size 9,50 help "KASJNL"
say "Bis zum "
get dDate
say " einschlie·lich"
WinCr()
get cFinal checkbox
say " definitiver Ausdruck"
WinCr()
say "-> auch bereits gedruckte ab dem "
get dDate2
WinCr()
say "->  nur bereits gedruckte ab Nr. "
get cIdIml2 picture PIC_ID
WinCr()
say "Zusammenfassung ab RJ "
get cPeriode picture "####"
say " (leer = alle)"
WinCr()
SetTplIni("XLISTE")
GetTplIni()
GetPreview(BUTTON_ON)
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
ddCloseAll()
if cFinal == BUTTON_ON
  RETURN NIL if ! LockData("Kassenjournal")
endif
if nArchive != NIL
  nSaveArchive := SetArchive()
  SetArchive(nArchive)
  // CODE COPIED FROM BELOW
  open area oIml(),oBud(),oImp()
    lOkay := .t.
    MsgDisplay("Beginnsalden (Archiv " + ArcName(nArchive) + ") errechnen...")
    index on IML->IdIml + dtos(IML->Date) to .\IMLTMP
    softseek repl("0",LenIdIml()) // erster bereits abgeschlossener Record
    do while ! eof()
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      Purzel()
      if BudExist(IML->DC,IML->IdBud)
        if (jnl := JnlLocate(IML->IdJnl) ) != NIL
          if JNLATTR_K $ jnl[JNL_ATTRIB]
            if empty(dDate2) .or. IML->Date >= dDate2
              seek IML->IdJnl + IML->IdDoc in IMP
              if eof() in IMP
                SendHotLine("IMP->(eof()) in ImlJournal()")
              elseif IMP->Etat != DocStatClosed()
                * Warning("IMP->Etat != DocStatClosed()",NIL,NIL,.t.)
                Warning(MsgIdJnlDoc() + MsgNotClosed(),NIL,NIL,.t.)
              else
                nMont := val(IML->Mont)
                if DevDefault(IMP->Periode) == IMP->IdDev
                  nMontDev := val(IML->Mont)
                else
                  nMontDev := val(IML->MontDev)
                endif
                TmpCollect( ;
                  aTmpTot,NIL,;
                  PerPerCtr(IMP->Periode), ;
                  NIL,IML->DC,0, nMont ;
                )
                TmpCollect( ;
                  aTmpJnl,jnl[JNL_IDJNL],;
                  NIL, ;
                  NIL,IML->DC,0, nMontDev, ;
                  IMP->IdDev ;
                )
                TmpCollect( ;
                  aJnlTot,NIL,;
                  PerPerCtr(IMP->Periode), ;
                  NIL,IML->DC,0,nMontDev, ;
                  IMP->IdDev;
                )
                TmpCollect( ;
                  aTmpGrj,jnl[JNL_IDGRJ],;
                  PerPerCtr(IMP->Periode), ;
                  BUD->Service,IML->DC,0, nMont ;
                )
              endif
            endif
          else
            lOkay := .f.
            if ! Confirm("Anomalie : JNLATTR_K in ImlJournal()", MsgContinue())
              exit
            endif
          endif
        else
          lOkay := .f.
          if ! Confirm("Anomalie : JnlLocate() in ImlJournal()", MsgContinue())
            exit
          endif
        endif
      else
        lOkay := .f.
        if ! Confirm("Anomalie : BudExist() in ImlJournal()", MsgContinue())
          exit
        endif
      endif
      skip
    enddo
    // END OF COPIED CODE
  close area
  SetArchive(nSaveArchive)
  ddCloseAll()
  nCount := 0
endif
open area oIml(), oPar(), oBud(), oImp() exclusive
  lOkay := .t.
  MsgDisplay("Beginnsalden errechnen...")
  index on IML->IdIml + dtos(IML->Date) to .\IMLTMP
  go bottom
  cIdIml := ImlNextId()
  if cFinal == BUTTON_ON
    SendConsole("Definitiver Ausdruck Kassenjournal ab Nummer " + cIdIml)
  endif
  * go top
  softseek repl("0",LenIdIml()) // erster bereits abgeschlossener Record
  do while ! eof()
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    Purzel()
    if BudExist(IML->DC,IML->IdBud)
      if (jnl := JnlLocate(IML->IdJnl) ) != NIL
        if JNLATTR_K $ jnl[JNL_ATTRIB]
          if empty(dDate2) .or. IML->Date >= dDate2
            seek IML->IdJnl + IML->IdDoc in IMP
            if eof() in IMP
              SendHotLine("IMP->(eof()) in ImlJournal()")
            elseif IMP->Etat != DocStatClosed()
              * Warning("IMP->Etat != DocStatClosed()",NIL,NIL,.t.)
              Warning(MsgIdJnlDoc() + MsgNotClosed(),NIL,NIL,.t.)
            else
              nMont := val(IML->Mont)
              if DevDefault(IMP->Periode) == IMP->IdDev
                nMontDev := val(IML->Mont)
              else
                nMontDev := val(IML->MontDev)
              endif
              TmpCollect( ;
                aTmpTot,NIL,;
                PerPerCtr(IMP->Periode), ;
                NIL,IML->DC,0, nMont ;
              )
              TmpCollect( ;
                aTmpJnl,jnl[JNL_IDJNL],;
                NIL, ;
                NIL,IML->DC,0, nMontDev, ;
                IMP->IdDev ;
              )
              TmpCollect( ;
                aJnlTot,NIL,;
                PerPerCtr(IMP->Periode), ;
                NIL,IML->DC,0,nMontDev, ;
                IMP->IdDev;
              )
              TmpCollect( ;
                aTmpGrj,jnl[JNL_IDGRJ],;
                PerPerCtr(IMP->Periode), ;
                BUD->Service,IML->DC,0, nMont ;
              )
            endif
          endif
        else
          lOkay := .f.
          if ! Confirm("Anomalie : JNLATTR_K in ImlJournal()", MsgContinue())
            exit
          endif
        endif
      else
        lOkay := .f.
        if ! Confirm("Anomalie : JnlLocate() in ImlJournal()", MsgContinue())
          exit
        endif
      endif
    else
      lOkay := .f.
      if ! Confirm("Anomalie : BudExist() in ImlJournal()", MsgContinue())
        exit
      endif
    endif
    skip
  enddo
  if cFinal == BUTTON_ON .and. ! lOkay
    Warning("Abbruch : Anomalie beim Errechnen der Beginnsalden !")
    break area
  endif
  if cFinal == BUTTON_ON
    cHeader1 := "DEFINITIVER AUSDRUCK"
  endif
  cHeader2 += "zum " + dtocf(dDate) + " einschlie·lich"
  open printer SetTplIni() ;
  preview SetPreview() ;
  TitBlock {|| ;
    PrintHeader("Kassenjournal", cHeader1, cHeader2 ), ;
    PrintLine(cTit1) ,;
    PrintLine(cTit2)  ;
  }
  cTit1 += " " + padr("BelDat",len(dtoc(UserDate())))
  cTit2 += " " + repl("ƒ",len(dtoc(UserDate())))
  cTit1 += " " + padr("Partner/EmpfÑnger",35)
  cTit2 += " " + repl("ƒ",35)
  cTit1 += " " + padr("Gegenstand/Ext.Ref.",20)
  cTit2 += " " + repl("ƒ",20)
  cTit1 += " " + padr("Artikel",20)
  cTit2 += " " + repl("ƒ",20)
  cTit1 += " " + padr("D",1)
  cTit2 += " " + repl("ƒ",1)
  cTit1 += " " + padr("Bezug",LenIdJnl()+LenIdDoc()+LEN_POS)
  cTit2 += " " + repl("ƒ",LenIdJnl()+LenIdDoc()+LEN_POS)
  cTit1 += " " + padr("RÅckbezug",LenIdJnl()+LenIdDoc()+LEN_POS)
  cTit2 += " " + repl("ƒ",LenIdJnl()+LenIdDoc()+LEN_POS)
  cTit1 += " " + padr("Per.",4)
  cTit2 += " " + repl("ƒ",4)
  cTit1 += " " + padr("GW",LEN_IDDEV)
  cTit2 += " " + repl("ƒ",LEN_IDDEV)
  cTit1 += " " + padr("Einnahmen GW",LenMntF())
  cTit2 += " " + repl("ƒ",LenMntF())
  cTit1 += " " + padr("Ausgaben GW",LenMntF())
  cTit2 += " " + repl("ƒ",LenMntF())
  cTit1 += " " + padr("Betrag FW",LenMntF())
  cTit2 += " " + repl("ƒ",LenMntF())
  cTit1 += " " + padr("TRE Belegnr.",LenIdJnl() + LenIdDoc() + 5)
  cTit2 += " " + repl("ƒ",LenIdJnl() + LenIdDoc() + 5)
  cTit1 += " " + padr("Nummer",LenIdIml())
  cTit2 += " " + repl("ƒ",LenIdIml())
  p_setwidth(len(cTit2))
  go top
  nCount := 0
  do while !eof() .and. LstContinue()
  * 20070801 do while (recno() <= lastrec()) .and. LstContinue()
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    if TaskInter() ; exit ; endif
    nRecNo := recno()
    skip
    nRecNo2 := recno()
    goto nRecNo
    if empty(dDate) .or. IML->Date <= dDate
      if BudExist(IML->DC,IML->IdBud)
        if (jnl := JnlLocate(IML->IdJnl) ) != NIL
          if JNLATTR_K $ jnl[JNL_ATTRIB]
            if ( empty(IML->IdIml) .and. empty(cIdIml2) ) ;
               .or. ( ! empty(dDate2) .and. IML->Date >= dDate2  ) ;
               .or. ( ! empty(cIdIml2) .and. IML->IdIml >= cIdIml2 )
              seek IML->IdJnl + IML->IdDoc in IMP
              if eof() in IMP
                SendHotLine("IMP->(eof()) in ImlJournal()")
              elseif IMP->Etat != DocStatClosed()
                Warning(MsgIdJnlDoc() + MsgNotClosed(),NIL,NIL,.t.)
              else
                if cFinal == BUTTON_ON .and. empty(IML->IdIml)
                  IML->IdIml := cIdIml
                  cIdIml := ImlNextId()
                endif
                nMont := val(IML->Mont)
                if DevDefault(IMP->Periode) == IMP->IdDev
                  nMontDev := val(IML->Mont)
                else
                  nMontDev := val(IML->MontDev)
                endif
                cLine := dtoc(IML->Date)
                cLine += " " + dtoc(IMP->Date2)
                cLine += " " + padr(IML->IdPar + " " + ParField(IML->IdPar,{||PAR->Firme}),35)
                cLine += " " + padr(IML->NB1,20)
                cLine += " " + IML->DC
                cLine += " " + SayIdBud(IML->IdBud)
                cLine += " " + BUD->Service
                cLine += " " + IML->Match
                cLine += " " + IML->BackMatch
                cLine += " " + IMP->Periode
                cLine += " " + DevDefault(IMP->Periode)
                if IML->DC == DC_DEBIT
                  cLine += " " + space(LenMntF())
                  cLine += " " + ntomf(nMont,DevDecPos(DevDefault(IMP->Periode)))
                else
                  cLine += " " + ntomf(nMont,DevDecPos(DevDefault(IMP->Periode)))
                  cLine += " " + space(LenMntF())
                endif
                if DevDefault(IMP->Periode) == IMP->IdDev
                  cLine += " " + space(LenMntF())
                else
                  cLine += " " + ntomf(nMontDev,DevDecPos(IMP->IdDev))
                endif
                cLine += " " + IML->IdJnl + " " + IML->IdDoc + " " + IML->Line
                cLine += " " + IML->IdIml
                PrintLine(cLine)
                cLine := space(17)
                cLine += " " + padr(IML->IdPar2 + " " + ParField(IML->IdPar2,{||PAR->Firme}),35)
                cLine += " " + padr(IML->NB2,20)
                PrintLine(cLine)
                TmpCollect( ;
                  aTmpTot,NIL,;
                  PerPerCtr(IMP->Periode), ;
                  NIL,IML->DC,nMont,0 ;
                )
                TmpCollect( ;
                  aTmpJnl,jnl[JNL_IDJNL],;
                  NIL, ;
                  NIL,IML->DC,nMontDev,0, ;
                  IMP->IdDev;
                )
                TmpCollect( ;
                  aJnlTot,NIL,;
                  PerPerCtr(IMP->Periode), ;
                  NIL,IML->DC,nMontDev,0, ;
                  IMP->IdDev;
                )
                TmpCollect( ;
                  aTmpGrj,jnl[JNL_IDGRJ],;
                  PerPerCtr(IMP->Periode), ;
                  BUD->Service,IML->DC,nMont,0 ;
                )
              endif
            endif
          endif
        else
          PrintLine(IML->IdJnl + " " + IML->IdDoc + MsgJnlExist())
        endif
      else
        PrintLine(IML->DC + " " + IML->IdBud + " : unbekannter Artikel !")
      endif
    endif
    goto nRecNo2
  enddo
  * PrintLine()
  p_Eject()
  * SetMntFormat("S14") // ... dann doch nicht am 19990323
  ImpJnlTotal(aTmpJnl,aJnlTot,aTmpTot,aTmpGrj,cPeriode)
  close printer
close area
ddCloseAll()
if cFinal == BUTTON_ON
  UnlockData()
endif
delete file (".\IMLTMP"+ntx_ext())
RETURN NIL

FUNCTION ImlNextId
if empty(IML->IdIml)
  RETURN padr("A",LenIdIml()-1,"0") + "1"
endif
if right(IML->IdIml,LenIdIml()-1) == repl("9",LenIdIml()-1)
  RETURN padr(chr(asc(left(IML->IdIml,1))+1),LenIdIml()-1,"0") + "1"
endif
RETURN NextId(IML->IdIml)


FUNCTION TmpCollect( ;
  aTmp,cIdGrj,;
  cPeriode,cService, ;
  cDC,nMont,nOldMont, ;
  cIdDev ;
)
local a := NIL
local i
for i := 1 to len(aTmp)
  if aTmp[i][TMP_IDJNL] == cIdGrj
    if aTmp[i][TMP_PERIODE] == cPeriode
      if aTmp[i][TMP_SERVICE] == cService
        if aTmp[i][TMP_IDDEV] == cIdDev
          a := aTmp[i]
        endif
      endif
    endif
  endif
next i
if a == NIL
  a := array(TMP_ALEN)
  a[TMP_PERIODE] := cPeriode
  a[TMP_IDJNL]   := cIdGrj
  a[TMP_IDDEV]      := cIdDev
  a[TMP_SERVICE] := cService
  a[TMP_DEBIT]   := 0
  a[TMP_CREDIT]  := 0
  a[TMP_OLDDEBIT]   := 0
  a[TMP_OLDCREDIT]  := 0
  aadd(aTmp, a)
endif
if cDC == DC_DEBIT
  a[TMP_DEBIT]    += nMont
  a[TMP_OLDDEBIT] += nOldMont
else
  a[TMP_CREDIT]    += nMont
  a[TMP_OLDCREDIT] += nOldMont
endif
RETURN NIL

FUNCTION ImpJnlTotal(aTmpJnl,aJnlTot,aTmpTot,aTmpGrj,cPeriode)
local dev
local cLine
local i
local jnl
local nDecPos := 0
cLine := padr("Journal",30)
cLine += " " + padr("WÑ",LEN_IDDEV)
cLine += " " + padl("Saldo ltz.",LenMntF())
cLine += " " + padl("Einnahmen",LenMntF())
cLine += " " + padl("Ausgaben",LenMntF())
cLine += " " + padl("Saldo",LenMntF())
PrintLine(cLine)
* erste Summentabelle
cLine := space(30)
cLine += " " + space(LEN_IDDEV)
cLine += " " + padl("def. Ausd.",LenMntF())
cLine += " " + padl("Ausdruck",LenMntF())
cLine += " " + padl("Ausdruck",LenMntF())
cLine += " " + padl("neu",LenMntF())
PrintLine(cLine)
PrintLine(repl("ƒ",len(cLine)))
for i := 1 to len(aTmpJnl)
  if (jnl := JnlLocate(aTmpJnl[i][TMP_IDJNL])) == NIL
    Warning(aTmpJnl[i][TMP_IDJNL] + MsgJnlExist())
  else
    nDecPos := DevDecPos(aTmpJnl[i][TMP_IDDEV])
    if abs(aTmpJnl[i][TMP_OLDCREDIT]-aTmpJnl[i][TMP_OLDDEBIT]) ;
         > Tolerance(nDecPos) ;
       .or. abs(aTmpJnl[i][TMP_DEBIT]) > Tolerance(nDecPos) ;
       .or. abs(aTmpJnl[i][TMP_CREDIT]) > Tolerance(nDecPos)
      cLine := padr(aTmpJnl[i][TMP_IDJNL] + " " + jnl[JNL_NAME],30)
      * cLine += " " + jnl[JNL_IDDEV]
      * nDecPos := DevDecPos(jnl[JNL_IDDEV])
      cLine += " " + aTmpJnl[i][TMP_IDDEV]
      cLine += " " + ntomf(  ;
        aTmpJnl[i][TMP_OLDCREDIT] - ;
        aTmpJnl[i][TMP_OLDDEBIT], ;
        nDecPos ;
      )
      cLine += " " + ntomf(aTmpJnl[i][TMP_CREDIT],nDecPos)
      cLine += " " + ntomf(aTmpJnl[i][TMP_DEBIT],nDecPos)
      cLine += " " + ntomf( ;
        (aTmpJnl[i][TMP_OLDCREDIT]+aTmpJnl[i][TMP_CREDIT]) ;
        - (aTmpJnl[i][TMP_OLDDEBIT]+aTmpJnl[i][TMP_DEBIT]), ;
        nDecPos ;
      )
      PrintLine(cLine)
      *aacollect(aTotJnl, ;
      *  aTmpJnl[i][TMP_IDDEV], ;
      *  { ;
      *    aTmpJnl[i][TMP_OLDDEBIT],  ;
      *    aTmpJnl[i][TMP_OLDCREDIT], ;
      *    aTmpJnl[i][TMP_DEBIT],     ;
      *    aTmpJnl[i][TMP_CREDIT]     ;
      *  };
      *)
    endif
  endif
next i
PrintLine(repl("ƒ",len(cLine)))
* summen der ersten summentabelle
*for i := 1 to len(aTotJnl)
*  dev := DevLocate(right(aTotJnl[i][1],LEN_IDDEV))
*  if dev == NIL
*    PrintLine(right(aTotJnl[i][1],LEN_IDDEV)+MsgDevExist())
*  else
*    nDecPos := dev[DEV_DECPOS]
*    cLine := padr("Gesamtsumme Salden",30)
*    * cLine := padr(left(aTotJnl[i][1],LEN_PERIODE),30)
*    cLine += " " + right(aTotJnl[i][1],LEN_IDDEV)
*    cLine += " " + ntomf(  ;
*      aTotJnl[i][2][2] - ;
*      aTotJnl[i][2][1], ;
*      nDecPos ;
*    )
*    cLine += " " + ntomf(aTotJnl[i][2][4],nDecPos)
*    cLine += " " + ntomf(aTotJnl[i][2][3],nDecPos)
*    cLine += " " + ntomf( ;
*      (aTotJnl[i][2][2]+aTotJnl[i][2][4]) ;
*      - (aTotJnl[i][2][1]+aTotJnl[i][2][3]), ;
*      nDecPos ;
*    )
*    PrintLine(cLine)
*  endif
*next i
*for i := 1 to len(aTmpTot)
*  nDecPos := DevDecPos(DevDefault(LastPeriode(aTmpTot[i][TMP_PERIODE])))
*  cLine := padr(aTmpTot[i][TMP_PERIODE],30)
*  cLine += " " + DevDefault(LastPeriode(aTmpTot[i][TMP_PERIODE]))
*  cLine += " " + ntomf(  ;
*    aTmpTot[i][TMP_OLDCREDIT] - ;
*    aTmpTot[i][TMP_OLDDEBIT], ;
*    nDecPos ;
*  )
*  cLine += " " + ntomf(aTmpTot[i][TMP_CREDIT],nDecPos)
*  cLine += " " + ntomf(aTmpTot[i][TMP_DEBIT],nDecPos)
*  cLine += " " + ntomf( ;
*    (aTmpTot[i][TMP_OLDCREDIT]+aTmpTot[i][TMP_CREDIT]) ;
*    - (aTmpTot[i][TMP_OLDDEBIT]+aTmpTot[i][TMP_DEBIT]), ;
*    nDecPos ;
*  )
*  PrintLine(cLine)
*next i
for i := 1 to len(aJnlTot)
  nDecPos := DevDecPos(aJnlTot[i][TMP_IDDEV])
  cLine := padr(aJnlTot[i][TMP_PERIODE],30)
  cLine += " " + aJnlTot[i][TMP_IDDEV]
  cLine += " " + ntomf(  ;
    aJnlTot[i][TMP_OLDCREDIT] - ;
    aJnlTot[i][TMP_OLDDEBIT], ;
    nDecPos ;
  )
  cLine += " " + ntomf(aJnlTot[i][TMP_CREDIT],nDecPos)
  cLine += " " + ntomf(aJnlTot[i][TMP_DEBIT],nDecPos)
  cLine += " " + ntomf( ;
    (aJnlTot[i][TMP_OLDCREDIT]+aJnlTot[i][TMP_CREDIT]) ;
    - (aJnlTot[i][TMP_OLDDEBIT]+aJnlTot[i][TMP_DEBIT]), ;
    nDecPos ;
  )
  PrintLine(cLine)
next i
PrintLine()
PrintLine()
PrintLine()
* zweite summentabelle
cLine := " "
cLine += " " + space(LEN_PERIODE)
cLine += " " + space(LenIdJnl())
cLine += " " + padc("Saldo ltz.",LenMntF() * 2 + 1)
cLine += " " + padc("",LenMntF() * 2 + 1)
cLine += " " + padc("",LenMntF() * 2 + 1)
PrintLine(cLine)
cLine := " "
cLine += " " + space(LEN_PERIODE)
cLine += " " + space(LenIdJnl())
cLine += " " + padc("def. Ausd.",LenMntF() * 2 + 1)
cLine += " " + padc("Ausdruck",LenMntF() * 2 + 1)
cLine += " " + padc("neuer Saldo",LenMntF() * 2 + 1)
PrintLine(cLine)
cLine := "D"
cLine += " " + "RJ  "
cLine += " " + "Jnl "
cLine += " " + padl("Einnahmen",LenMntF())
cLine += " " + padl("Ausgaben",LenMntF())
cLine += " | " + padl("Einnahmen",LenMntF())
cLine += " " + padl("Ausgaben",LenMntF())
cLine += " | " + padl("Einnahmen",LenMntF())
cLine += " " + padl("Ausgaben",LenMntF())
* cLine += " | " + padl("Stand",LenMntF())
PrintLine(cLine)
for i := 1 to len(aTmpGrj)
  if empty(cPeriode) .or. aTmpGrj[i][TMP_PERIODE] >= cPeriode
    nDecPos := DevDecPos(DevDefault(LastPeriode(aTmpGrj[i][TMP_PERIODE])))
    cLine := aTmpGrj[i][TMP_SERVICE]
    cLine += " " + aTmpGrj[i][TMP_PERIODE]
    cLine += " " + padr(aTmpGrj[i][TMP_IDJNL],LenIdJnl())
    cLine += " " + ntomf(aTmpGrj[i][TMP_OLDCREDIT],nDecPos)
    cLine += " " + ntomf(aTmpGrj[i][TMP_OLDDEBIT],nDecPos)
    cLine += " | " + ntomf(aTmpGrj[i][TMP_CREDIT],nDecPos)
    cLine += " " + ntomf(aTmpGrj[i][TMP_DEBIT],nDecPos)
    cLine += " | " + ntomf(aTmpGrj[i][TMP_OLDCREDIT]+aTmpGrj[i][TMP_CREDIT],nDecPos)
    cLine += " " + ntomf(aTmpGrj[i][TMP_OLDDEBIT]+aTmpGrj[i][TMP_DEBIT],nDecPos)
    PrintLine(cLine)
  endif
next i
* summen der zweiten summentabelle
PrintLine(repl("ƒ",len(cLine)))
for i := 1 to len(aTmpTot)
  if empty(cPeriode) .or. aTmpTot[i][TMP_PERIODE] >= cPeriode
    nDecPos := DevDecPos(DevDefault(LastPeriode(aTmpTot[i][TMP_PERIODE])))
    cLine := " "
    cLine += " " + aTmpTot[i][TMP_PERIODE]
    cLine += " " + space(LenIdJnl())
    cLine += " " + ntomf(aTmpTot[i][TMP_OLDCREDIT],nDecPos)
    cLine += " " + ntomf(aTmpTot[i][TMP_OLDDEBIT],nDecPos)
    cLine += " | " + ntomf(aTmpTot[i][TMP_CREDIT],nDecPos)
    cLine += " " + ntomf(aTmpTot[i][TMP_DEBIT],nDecPos)
    cLine += " | " + ntomf(aTmpTot[i][TMP_OLDCREDIT]+aTmpTot[i][TMP_CREDIT],nDecPos)
    cLine += " " + ntomf( ;
      aTmpTot[i][TMP_OLDDEBIT]+aTmpTot[i][TMP_DEBIT],;
      nDecPos;
    )
    PrintLine(cLine)
  endif
next i
RETURN NIL


FUNCTION aacollect(a, uKey, aItems)
local i
local p
for i := 1 to len(a)
  if a[i][1] == uKey
    p := a[i]
    exit
  endif
next i
if p == NIL
  p := {uKey,aItems}
  aadd(a,p)
  RETURN NIL
endif
for i := 1 to len(aItems)
  p[2][i] += aItems[i]
next i
RETURN NIL


#define MVISUM_IDCDC  1
#define MVISUM_MONT   2
#define MVISUM_MONTCTB 3
#define MVISUM_DC      4
#define MVISUM_4MONT   5
#define MVISUM_ALEN    5


#define ASUM_IDJNL   1
#define ASUM_MVISUM  2

FUNCTION Hauptbuch(cIdCtr,cTplIni)
local nBudAvail
* local cIdMvi
local cTit1 := padr("BuchDat",len(dtoc(UserDate())))
local cTit2 := repl("ƒ",len(dtoc(UserDate())))
local nCount := 0
local cLine
local cFormFeed := BUTTON_OFF
local i, j, k
local lFound
local nRecNo
local nRecNo2
local nMont
local cIdBud := NIL
local cIdBud1 := space(18)
local cIdBud2 := space(18)
local nPad
local a := {}
local aSum
local aTotal := {}
local aTotal4 := {}
local aSumCtb := {}
local cDetail := BUTTON_ON
local cHeader := "(alle Artikel)"
local cPerCtr
* local cIdCtr := NIL
local aCdc := CdcList(cIdCtr)
local aMviSum := {}
local aSumCtbAvail := {}
local aSumCtbMont  := {}
default cTplIni to "XLISTE"
do while .t.
  open window ("Hauptbuch " + DcName(cIdCtr)) size 8,60 ;
                                              help ("HAUPT"+cIdCtr)
  SayGetPeriode()
  say "Artikel von "
  get cIdBud1 picture PIC_ID pick PickBudSay(cIdCtr,cIdBud1) ;
                             postedit {|x| SayIdBud(GetIdBud(x))}
  say " bis "
  get cIdBud2 picture PIC_ID pick PickBudSay(cIdCtr,cIdBud2) ;
                             postedit {|x| SayIdBud(GetIdBud(x))}
  WinCr()
  GetPreview() ; WinCr()
  SetTplIni(cTplIni)
  GetTplIni()
  get cDetail checkbox
  say " Buchungen detaillieren"
  WinCr()
  get cFormFeed checkbox
  say " Seitensprung nach jedem Artikel"
  nKey := ReadScr()
  close window
  RETURN NIL if nKey == K_ESC
  if empty(MemPer1) .or. empty(MemPer2)
    SetMsg("Periode : darf nicht leer sein !")
    loop
  endif
  cPerCtr := PerPerCtr(MemPer1)
  if PerPerCtr(MemPer2) != cPerCtr
    SetMsg(MemPer1 + " und " + MemPer2 + " mÅssen im gleichen Rechnungsjahr sein !")
    loop
  endif
  exit
enddo
if ! empty(cIdBud1 + cIdBud2)
  cHeader := "Artikel von " + trim(cIdBud1) + " bis " + trim(cIdBud2)
endif
cIdBud1 := GetIdBud(cIdBud1)
cIdBud2 := GetIdBud(cIdBud2)
ddCloseAll()
open area oMvi(), oPar(), oBud(), oIml() // exclusive
  ddSetOrder(ORD_MVI_BUDDATE)
  softseek cIdCtr + trim(cIdBud1)
  open printer SetTplIni() preview SetPreview() ;
  titblock {|| ;
    PrintHeader( ;
      "Hauptbuch " + DcName(cIdCtr), ;
      PerText({||.f.}), ;
      cHeader, ;
      {||PrintLine(padl(trim(SayIdBud(MVI->IdBud)),p_cpl()))} ;
    ), ;
    PrintLine(cTit1) ,;
    PrintLine(cTit2)  ;
  }
  cTit1 += " " + padr("BelDat",len(dtoc(UserDate())))
  cTit2 += " " + repl("ƒ",len(dtoc(UserDate())))
  cTit1 += " " + padr("Partner/EmpfÑnger",35)
  cTit2 += " " + repl("ƒ",35)
  cTit1 += " " + padr("Gegenstand/Ext.Ref.",20)
  cTit2 += " " + repl("ƒ",20)
  cTit1 += " " + padr("Bezug/RÅckbzg",LenIdJnl() + LenIdDoc() + LEN_POS)
  cTit2 += " " + repl("ƒ",LenIdJnl() + LenIdDoc() + LEN_POS)
  cTit1 += " " + padr("Per.",LEN_PERIODE)
  cTit2 += " " + repl("ƒ",LEN_PERIODE)
  cTit1 += " " + padr("Jnl/Belegnr.",LenIdJnl() + LenIdDoc() + 2 + LEN_POS)
  cTit2 += " " + repl("ƒ",LenIdJnl() + LenIdDoc() + 2 + LEN_POS)
  cTit1 += " " + padr("Nummer",LenIdIml())
  cTit2 += " " + repl("ƒ",LenIdIml())
  nPad := len(cTit1)
  for i := 1 to len(aCdc)
    cTit1 += " " + padr(aCdc[i][CDC_HEADER],LenMntF())
    cTit2 += " " + repl("ƒ",LenMntF())
    aadd(aTotal,0)
    aadd(aTotal4,0)
    aadd(aSumCtb,0)
    aadd(aSumCtbAvail,0)
    aadd(aSumCtbMont,0)
  next i
  cTit1 += " " + padr("(zu Åbertr.)",LenMntF())
  cTit2 += " " + repl("ƒ",LenMntF())
  p_setwidth(len(cTit2))
  do while ! eof() .and. LstContinue() .and. MVI->DC == cIdCtr
    if ! empty(cIdBud2)
      if MVI->IdBud > cIdBud2
        exit
      endif
    endif
    a := {}
    cIdBud := MVI->IdBud
    seek MVI->DC + MVI->IdBud in BUD
    PrintLine()
    PrintLine( ;
      "{B}" + MVI->DC + "-" + SayIdBud(MVI->IdBud) + " " + ;
      trim(BudName()) + "(" + BUD->Service + "){b}";
    )
    do while ! eof() .and. MVI->IdBud == cIdBud ;
                     .and. MVI->DC == cIdCtr ;
                     .and. LstContinue()
      if TaskInter() ; LstError(PRN_ABORT) ; exit ; endif
      if ! empty(JnlIdCdc(MVI->IdJnl))
        MviSumCollect(a,aCdc,cDetail)
      endif
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      skip
    enddo
    if len(a) > 0
      aSum := {}
      for i := 1 to len(aCdc)
        aadd(aSum,0)
      next i
      if cDetail == BUTTON_ON
        PrintLine()
      endif
      if cDetail == BUTTON_ON
        cLine := padl("Summierung der Buchungen in den Journalen :",nPad)
        PrintLine(cLine)
      endif
      for k := 1 to len(a)
        * cLine := a[k][ASUM_IDJNL] + " " + JnlName(a[k][ASUM_IDJNL])
        cLine := JnlName(a[k][ASUM_IDJNL]) + " " + a[k][ASUM_IDJNL]
        cLine := padl(cLine,nPad)
        aMviSum := a[k][ASUM_MVISUM]
        for i := 1 to len(aCdc)
          lFound := .f.
          for j := 1 to len(aMviSum)
            if aMviSum[j][MVISUM_IDCDC] == aCdc[i][CDC_IDCDC]
              if aMviSum[j][MVISUM_DC] == aCdc[i][CDC_DC]
                cLine += " " + ntomf(aMviSum[j][MVISUM_MONT])
                lFound := .t.
                aSum[i]    += aMviSum[j][MVISUM_MONT]
                aTotal[i]  += aMviSum[j][MVISUM_MONT]
                aTotal4[i] += aMviSum[j][MVISUM_4MONT]
                aSumCtb[i] += aMviSum[j][MVISUM_MONTCTB]
                exit
              endif
            endif
          next i
          if ! lFound
            cLine += " " + space(LenMntF())
          endif
        next i
        if cDetail == BUTTON_ON
          PrintLine(cLine)
        endif
      next k
      if cDetail == BUTTON_ON
        cLine := padl("Rechnerische Summe der Buchungen",nPad)
        for i := 1 to len(aCdc)
          cLine += " " + ntomf(aSum[i])
        next i
        PrintLine(cLine)
        PrintLine()
      endif
    endif
    open area oCtb()
      if cIdCtr == DC_DEBIT
        cLine := padl("Stand Haushalt-Zahlungsverpflichtungen-Ausgaben (alle Perioden)",nPad)
      else
        cLine := padl("Stand Haushalt-Anrechte-Einnahmen (alle Perioden)",nPad)
      endif
      for i := 1 to len(aCdc)
        seek cIdCtr + cIdBud + cPerCtr + aCdc[i][CDC_IDCDC]
        cLine += " " + ntomf(val(CTB->Mont))
        aSumCtbMont[i] += val(CTB->Mont)
      next i
      PrintLine(cLine)
      cLine := padl("Saldo",nPad)
      for i := 1 to len(aCdc)
        nBudAvail := BudAvail(cIdCtr,cIdBud,cPerCtr,aCdc[i][CDC_IDCDC])
        * seek cIdCtr + cIdBud + cPerCtr + aCdc[i][CDC_IDCDC]
        cLine += " " + ntomf(nBudAvail)
        * cLine += " " + ntomf(CtbBudAvail())
        * aSumCtbAvail[i] += CtbBudAvail()
        aSumCtbAvail[i] += nBudAvail
      next i
      cLine += " " + ntomf( ;
        CtbMont(cIdCtr,cIdBud,cPerCtr,"02") ;
        - CtbMont(cIdCtr,cIdBud,cPerCtr,"03") ;
        + CtbMont(cIdCtr,cIdBud,cPerCtr,"04") ;
      )
      PrintLine(cLine)
    close area
    if cFormFeed == BUTTON_ON
      p_Eject()
    endif
  enddo
  if cDetail == BUTTON_ON
    PrintLine()
    cLine := padl("Rechnerische Summe der Buchungen",nPad)
    for i := 1 to len(aCdc)
      cLine += " " + ntomf(aTotal[i])
    next i
    PrintLine(cLine)
    cLine := padl("Rechnerische Summe der Buchungen ohne Dienst 4",nPad)
    for i := 1 to len(aCdc)
      cLine += " " + ntomf(aTotal4[i])
    next i
    PrintLine(cLine)
  endif
  PrintLine()
  cLine := padl("Summe Hauptbuchsummen (CtbMont())",nPad)
  for i := 1 to len(aCdc)
    cLine += " " + ntomf(aSumCtbMont[i])
  next i
  PrintLine(cLine)
  cLine := padl("Summe Hauptbuchsalden (CtbBudAvail())",nPad)
  for i := 1 to len(aCdc)
    cLine += " " + ntomf(aSumCtbAvail[i])
  next i
  PrintLine(cLine)
  cLine := padl("Summe Buchungen (MVI->MontCtb)",nPad)
  for i := 1 to len(aCdc)
    cLine += " " + ntomf(aSumCtb[i])
  next i
  PrintLine(cLine)
  close printer
close area
RETURN NIL

FUNCTION MviSumCollect(aSum,aCdc,cDetail)
local cLine
local jnl
local nMont
local nMontCtb
local i
local a := NIL
local aMviSum := NIL
if ChkPeriode(MVI->Periode) == 0
  if (jnl := JnlLocate(MVI->IdJnl) ) != NIL
    for i := 1 to len(aSum)
      if aSum[i][ASUM_IDJNL] == jnl[JNL_IDJNL]
        aMviSum := aSum[i][ASUM_MVISUM]
      endif
    next i
    if aMviSum == NIL
      aMviSum := {}
      aadd(aSum, { jnl[JNL_IDJNL], aMviSum } )
    endif
    nMont    := val(MVI->Mont)
    nMontCtb := val(MVI->MontCtb)
    if JNLATTR_N $ jnl[JNL_ATTRIB]
      nMont := - nMont
      nMontCtb := - nMontCtb
    endif
    for i := 1 to len(aMviSum)
      if aMviSum[i][MVISUM_IDCDC] == jnl[JNL_IDCDC]
        if aMviSum[i][MVISUM_DC] == MVI->DC
          a := aMviSum[i]
        endif
      endif
    next i
    if a == NIL
      a := array(MVISUM_ALEN)
      a[MVISUM_DC]      := MVI->DC
      a[MVISUM_IDCDC]   := jnl[JNL_IDCDC]
      a[MVISUM_MONT]    := 0
      a[MVISUM_4MONT]   := 0
      a[MVISUM_MONTCTB] := 0
      aadd(aMviSum, a)
    endif
    a[MVISUM_MONT]    += nMont
    a[MVISUM_MONTCTB] += nMontCtb
    if BUD->Service != "4"
      a[MVISUM_4MONT] += nMont
    endif
    if cDetail == BUTTON_ON
      cLine := dtoc(MVI->Date)
      cLine += " " + dtoc(MVI->Date2)
      cLine += " " + padr(MVI->IdPar + " " + ParField(MVI->IdPar,{||PAR->Firme}),35)
      * cLine += " " + padr(MVI->IdPar + " " + ParName(MVI->IdPar),35)
      cLine += " " + padr(MVI->NB1,20)
      cLine += " " + MVI->Match
      cLine += " " + MVI->Periode
      cLine += " " + MVI->IdJnl
      cLine += " " + MVI->IdDoc
      cLine += " " + MVI->Line
      seek MVI->IdJnl + MVI->IdDoc + MVI->Line in IML
      cLine += " " + IML->IdIml
      for i := 1 to len(aCdc)
        if aCdc[i][CDC_IDCDC] == jnl[JNL_IDCDC] .and. aCdc[i][CDC_DC] == MVI->DC
          cLine += " " + ntomf(nMont)
        else
          cLine += " " + space(LenMntF())
        endif
      next i
      PrintLine(cLine)
      cLine := space(17) // + LenIdJnl()+LenIdDoc())
      cLine += " " + padr(MVI->IdPar2 + " " + ParField(MVI->IdPar2,{||PAR->Firme}),35)
      cLine += " " + padr(MVI->NB2,20)
      cLine += " " + MVI->BackMatch
      PrintLine(cLine)
    endif
  endif
endif
RETURN NIL

FUNCTION DcName(cDC)
RETURN "Ausgaben" if cDC == DC_DEBIT
RETURN "Einnahmen"

FUNCTION BudEnvListe(cIdCtr,nBreak,cFilter)
local nMont01mod
local nEnv01mod
local jnl
local nTotMontReg
local nMontReg
local nMont01
local nMont02
local nEnvMont01
local nEnvMont02
local cIdEnv
local nPad := 60
local cTit1 := padr("Artikel",nPad)
local cTit2 := repl("ƒ",nPad)
local nCount := 0
local cLine
local cBudResp := space(1)
local cIdBud1 := space(18)
local cIdBud2 := space(18)
local cHeader := "(alle Artikel)"
local cPerCtr := str(year(UserDate()),4,0)
* local cIdCtr := NIL
local aCdc := CdcList(cIdCtr)
local aMviSum := {}
static cMitREG := BUTTON_OFF
static cMitMod := BUTTON_ON
default cFilter to ".t."
open window ("Kreditkontrolle " + DcName(cIdCtr)) size 9,60 ;
                                              help ("BUDENV"+cIdCtr)
  say "Rechnungsjahr "
  get cPerCtr
  WinCr()
  say "Artikel von "
  get cIdBud1 picture PIC_ID pick PickBudSay(cIdCtr,cIdBud1) ;
                             postedit {|x| SayIdBud(GetIdBud(x))}
  say " bis "
  get cIdBud2 picture PIC_ID pick PickBudSay(cIdCtr,cIdBud2) ;
                             postedit {|x| SayIdBud(GetIdBud(x))}
  WinCr()
  say "Budgetverantwortlicher "
  get cBudResp picture "@k@!" pick PickDbcCode("BUDRESP.DBC",cBudResp)
  WinCr()
  get cMitREG checkbox
  say " mit Summen REG"
  WinCr()
  get cMitMod checkbox
  say " mit HH-Modifizierern"
  WinCr()
  SetTplIni("LISTE")
  GetTplIni()
  GetPreview()
  nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
if ! empty(cIdBud1 + cIdBud2)
  cHeader := "Artikel von " + trim(cIdBud1) + " bis " + trim(cIdBud2)
endif
cIdBud1 := GetIdBud(cIdBud1)
cIdBud2 := GetIdBud(cIdBud2)
open printer SetTplIni() preview SetPreview() ;
TitBlock {|| ;
  PrintHeader( ;
    "Kreditkontrolle " + DcName(cIdCtr) + " " + cPerCtr, ;
     "Budgetverantwortlicher : " + ;
       if(empty(cBudResp),"alle",trim(DbcText("BUDRESP.DBC",cBudResp))), ;
     cHeader ), ;
  PrintLine(cTit1) ,;
  PrintLine(cTit2)  ;
}
if cMitMod == BUTTON_ON
  cTit1 += " " + padr("mod",10)
  cTit2 += " " + repl("ƒ",10)
endif
cTit1 += " " + padr("Haushalt",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
cTit1 += " " + padr("mod.HH",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
cTit1 += " " + padr("Verpfl.",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
if cMitREG == BUTTON_ON
  cTit1 += " " + padr("REG",LenMntF())
  cTit2 += " " + repl("ƒ",LenMntF())
endif
cTit1 += " " + padr("VerfÅgbar",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
cTit1 += " " + padr("mod.Verf.",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
cTit1 += " " + padr("",7)
cTit2 += " " + repl("ƒ",7)
p_setwidth(len(cTit2))
ddCloseAll()
open area oBud(), oCtb()
  softseek cIdCtr + trim(cIdBud1)
  do while ! eof() .and. LstContinue() .and. BUD->DC == cIdCtr
    if ! empty(cIdBud2)
      if BUD->IdBud > cIdBud2
        exit
      endif
    endif
    cIdEnv := left(BUD->IdBud,nBreak)
    nEnvMont01 := 0
    nEnv01mod := 0
    nEnvMont02 := 0
    nTotMontReg := 0
    do while ! eof() .and. LstContinue() .and. BUD->DC == cIdCtr ;
                     .and. left(BUD->IdBud,nBreak) == cIdEnv
      if TaskInter() ; LstError(PRN_ABORT) ; exit ; endif
      if &(cFilter)
        if empty(cBudResp).or.BUD->BudResp == cBudResp
          seek cIdCtr + BUD->IdBud + cPerCtr + "01" in CTB
          nMont01 := val(CTB->Mont)
          nMont01mod := BudAvail(cIdCtr,BUD->IdBud,cPerCtr,"01")
          nEnvMont01 += nMont01
          nEnv01mod  += nMont01mod
          seek cIdCtr + BUD->IdBud + cPerCtr + "02" in CTB
          nMont02 := val(CTB->Mont)
          nEnvMont02 += nMont02
          cLine := trim(SayIdBud(BUD->IdBud))
          cLine += " " + BUD->Name1
          cLine := padr(cLine,nPad)
          if cMitMod == BUTTON_ON
            cLine += " " + xparse("BUD->Mod"+cPerCtr)
          endif
          cLine += " " + ntomf(nMont01)
          cLine += " " + ntomf(nMont01mod)
          cLine += " " + ntomf(nMont02)
          if cMitREG == BUTTON_ON
            nMontReg := 0
            open area oMvi()
              ddSetOrder(3) // MVI_ORD_BUDDATE
              softseek BUD->DC+BUD->IdBud
              do while ! eof() .and. MVI->IdBud == BUD->IdBud ;
                               .and. MVI->DC == BUD->DC
                if TaskInter() ; LstError(PRN_ABORT) ; exit ; endif
                if PerPerCtr(MVI->Periode) == cPerCtr
                  if (jnl := JnlLocate(MVI->IdJnl)) != NIL
                    if jnl[JNL_IDGRJ] == "REG"
                      if JNLATTR_N $ jnl[JNL_ATTRIB]
                        nMontReg -= val(MVI->Mont)
                      else
                        nMontReg += val(MVI->Mont)
                      endif
                    endif
                  endif
                endif
                skip
              enddo
            close area
            cLine += " " + ntomf(nMontReg)
            nTotMontReg += nMontReg
          endif
          cLine += " " + ntomf(nMont01-nMont02)
          cLine += " " + ntomf(nMont01mod-nMont02)
          if nMont01 != 0
            if (nMont02 > nMont01)
              cLine += " !"
            elseif (nMont01-nMont02)/nMont01 <= 0.05
              cLine += " *"
            endif
          endif
          if nMont01 != 0 .or. nMont02 != 0
            PrintLine(cLine)
          endif
        endif
      endif
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      skip
    enddo
    if nEnvMont01 != 0 .or. nEnvMont02 != 0
      cLine := space(nPad)
      if cMitMod == BUTTON_ON
        cLine += " " + repl("ƒ",10)
      endif
      cLine += " " + repl("ƒ",LenMntF())
      cLine += " " + repl("ƒ",LenMntF())
      cLine += " " + repl("ƒ",LenMntF())
      if cMitREG == BUTTON_ON
        cLine += " " + repl("ƒ",LenMntF())
      endif
      cLine += " " + repl("ƒ",LenMntF())
      cLine += " " + repl("ƒ",LenMntF())
      PrintLine(cLine) // space(nPad+1) + repl("ƒ",2+LenMntF()*3))
      cLine := trim(SayIdBud(cIdEnv))
      if right(cLine,1) == "/"
        cLine := left(cLine,len(cLine)-1)
      endif
      cLine := padr(cLine,nPad)
      if cMitMod == BUTTON_ON
        cLine += " " + space(10)
      endif
      cLine += " " + ntomf(nEnvMont01)
      cLine += " " + ntomf(nEnv01mod)
      cLine += " " + ntomf(nEnvMont02)
      if cMitREG == BUTTON_ON
        cLine += " " + ntomf(nTotMontReg)
      endif
      cLine += " " + ntomf(nEnvMont01-nEnvMont02)
      cLine += " " + ntomf(nEnv01mod-nEnvMont02)
      if nEnvMont01 != 0
        cLine += " " + str(100*(nEnvMont01-nEnvMont02)/nEnvMont01,4,0) + "%"
        if (nEnvMont02 > nEnvMont01)
          cLine += " !"
        elseif (nEnvMont01-nEnvMont02)/nEnvMont01 <= 0.05
          cLine += " *"
        endif
      endif
      PrintLine(cLine)
      PrintLine()
    endif
  enddo
close area
close printer
RETURN NIL

FUNCTION BudMviListe(cIdCtr,cTplIni,cTitle)
local cTit1 := padr("BuchDat",len(dtoc(UserDate())))
local cTit2 := repl("ƒ",len(dtoc(UserDate())))
local nCount := 0
local cLine
* local cFormFeed := BUTTON_OFF
local i, j, k
local lFound
local nRecNo
local nRecNo2
local cIdBud := NIL
local cIdBud1 := space(18)
local cIdBud2 := space(18)
local nPad
local a := {}
local aSum
local aTotal := {}
local aTotal4 := {}
local cDetail  := BUTTON_ON
local cAuchSat := BUTTON_OFF
local cHeader := "(alle Artikel)"
local cPerCtr
local aCdc := CdcList(cIdCtr)
local aMviSum := {}
local jnl
local nMont
local nSum
local nSumUs
default cTplIni to "XLISTE"
default cTitle to "Offene Posten " + DcName(cIdCtr)
do while .t.
  open window (cTitle) size 8,60 help ("MVIUS"+cIdCtr)
  SayGetPeriode()
  say "Artikel von "
  get cIdBud1 picture PIC_ID pick PickBudSay(cIdCtr,cIdBud1) ;
                             postedit {|x| SayIdBud(GetIdBud(x))}
  say " bis "
  get cIdBud2 picture PIC_ID pick PickBudSay(cIdCtr,cIdBud2) ;
                             postedit {|x| SayIdBud(GetIdBud(x))}
  WinCr()
  SetTplIni(cTplIni)
  GetTplIni()
  GetPreview() ; WinCr()
  get cDetail checkbox
  say " Buchungen detaillieren"
  WinCr()
  get cAuchSat checkbox
  say " auch befriedigte Bewegungen"
  nKey := ReadScr()
  close window
  RETURN NIL if nKey == K_ESC
  if empty(MemPer1) .or. empty(MemPer2)
    SetMsg("Periode : darf nicht leer sein !")
    loop
  endif
  cPerCtr := PerPerCtr(MemPer1)
  if PerPerCtr(MemPer2) != cPerCtr
    SetMsg(MemPer1 + " und " + MemPer2 + " mÅssen im gleichen Rechnungsjahr sein !")
    loop
  endif
  exit
enddo
if ! empty(cIdBud1 + cIdBud2)
  cHeader := "Artikel von " + trim(cIdBud1) + " bis " + trim(cIdBud2)
endif
cIdBud1 := GetIdBud(cIdBud1)
cIdBud2 := GetIdBud(cIdBud2)
ddCloseAll()
open area oMvi(), oPar(), oBud(), oIml() // exclusive
  ddSetOrder(ORD_MVI_BUDDATE)
  softseek cIdCtr + trim(cIdBud1)
  open printer SetTplIni() ;
  preview SetPreview() ;
  TitBlock {|| ;
    PrintHeader( ;
      "Hauptbuch " + DcName(cIdCtr), ;
      PerText({||.f.}), ;
      cHeader,;
      {||padl(trim(SayIdBud(MVI->IdBud)),p_cpl())} ;
    ), ;
    PrintLine(cTit1) ,;
    PrintLine(cTit2)  ;
  }
  cTit1 += " " + padr("BelDat",len(dtoc(UserDate())))
  cTit2 += " " + repl("ƒ",len(dtoc(UserDate())))
  cTit1 += " " + padr("Partner/EmpfÑnger",35)
  cTit2 += " " + repl("ƒ",35)
  cTit1 += " " + padr("Gegenstand/Ext.Ref.",20)
  cTit2 += " " + repl("ƒ",20)
  cTit1 += " " + padr("Bezug/RÅckbzg",LenIdJnl() + LenIdDoc() + LEN_POS)
  cTit2 += " " + repl("ƒ",LenIdJnl() + LenIdDoc() + LEN_POS)
  cTit1 += " " + padr("Per.",LEN_PERIODE)
  cTit2 += " " + repl("ƒ",LEN_PERIODE)
  cTit1 += " " + padr("Jnl/Belegnr.",LenIdJnl() + LenIdDoc() + 2 + LEN_POS)
  cTit2 += " " + repl("ƒ",LenIdJnl() + LenIdDoc() + 2 + LEN_POS)
  cTit1 += " " + padr("Nummer",LenIdIml())
  cTit2 += " " + repl("ƒ",LenIdIml())
  nPad := len(cTit1)
  if cIdCtr == DC_DEBIT
    cTit1 += " " + padr("Verpfl.",LenMntF())
    cTit2 += " " + repl("ƒ",LenMntF())
    cTit1 += " " + padr("Bezahlt",LenMntF())
    cTit2 += " " + repl("ƒ",LenMntF())
  else
    cTit1 += " " + padr("Anrecht",LenMntF())
    cTit2 += " " + repl("ƒ",LenMntF())
    cTit1 += " " + padr("Kassiert",LenMntF())
    cTit2 += " " + repl("ƒ",LenMntF())
  endif
  cTit1 += " " + padr("Rest",LenMntF())
  cTit2 += " " + repl("ƒ",LenMntF())
  p_setwidth(len(cTit2))
  do while ! eof() .and. LstContinue() .and. MVI->DC == cIdCtr
    if ! empty(cIdBud2)
      if MVI->IdBud > cIdBud2
        exit
      endif
    endif
    nSum   := 0
    nSumUs := 0
    a := {}
    cIdBud := MVI->IdBud
    seek MVI->DC + MVI->IdBud in BUD
    PrintLine()
    PrintLine( ;
      "{B}" + MVI->DC + "-" + SayIdBud(MVI->IdBud) + " " + ;
      trim(BudName()) + "(" + BUD->Service + "){b}";
    )
    do while ! eof() .and. MVI->IdBud == cIdBud ;
                     .and. MVI->DC == cIdCtr ;
                     .and. LstContinue()
      if TaskInter() ; LstError(PRN_ABORT) ; exit ; endif
      if ! empty(JnlIdCdc(MVI->IdJnl))
        if ! empty(MVI->MontUs) .or. cAuchSat == BUTTON_ON
          if ChkPeriode(MVI->Periode) == 0
            if (jnl := JnlLocate(MVI->IdJnl) ) != NIL
              nMont := val(MVI->Mont)
              if JNLATTR_N $ jnl[JNL_ATTRIB]
                nMont := - nMont
              endif
              if cDetail == BUTTON_ON
                cLine := dtoc(MVI->Date)
                cLine += " " + dtoc(MVI->Date2)
                cLine += " " + padr(MVI->IdPar + " " + ParField(MVI->IdPar,{||PAR->Firme}),35)
                cLine += " " + padr(MVI->NB1,20)
                cLine += " " + MVI->Match
                cLine += " " + MVI->Periode
                cLine += " " + MVI->IdJnl
                cLine += " " + MVI->IdDoc
                cLine += " " + MVI->Line
                seek MVI->IdJnl + MVI->IdDoc + MVI->Line in IML
                cLine += " " + IML->IdIml
                cLine += " " + ntomf(val(MVI->Mont))
                cLine += " " + ntomf(val(MVI->Mont) - val(MVI->MontUs))
                cLine += " " + ntomf(val(MVI->MontUs))
                if MVI->DC == jnl[JNL_DC]
                  nSum   += val(MVI->Mont)
                  nSumUs += val(MVI->MontUs)
                else
                  nSum   -= val(MVI->Mont)
                  nSumUs -= val(MVI->MontUs)
                endif
                PrintLine(cLine)
                cLine := space(17) // + LenIdJnl()+LenIdDoc())
                cLine += " " + padr(MVI->IdPar2 + " " + ParField(MVI->IdPar2,{||PAR->Firme}),35)
                cLine += " " + padr(MVI->NB2,20)
                cLine += " " + MVI->BackMatch
                PrintLine(cLine)
              endif
            endif
          endif
        endif
      endif
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      skip
    enddo
    if cDetail == BUTTON_ON
      PrintLine()
    endif
    *cLine := padl("Summierung der Buchungen in den Journalen :",nPad)
    *PrintLine(cLine)
    *for k := 1 to len(a)
    *  * cLine := a[k][ASUM_IDJNL] + " " + JnlName(a[k][ASUM_IDJNL])
    *  cLine := JnlName(a[k][ASUM_IDJNL]) + " " + a[k][ASUM_IDJNL]
    *  cLine := padl(cLine,nPad)
    *  aMviSum := a[k][ASUM_MVISUM]
    *  for i := 1 to len(aCdc)
    *    lFound := .f.
    *    for j := 1 to len(aMviSum)
    *      if aMviSum[j][MVISUM_IDCDC] == aCdc[i][CDC_IDCDC]
    *        if aMviSum[j][MVISUM_DC] == aCdc[i][CDC_DC]
    *          cLine += " " + ntomf(aMviSum[j][MVISUM_MONT])
    *          lFound := .t.
    *          aSum[i]   += aMviSum[j][MVISUM_MONT]
    *          aTotal[i] += aMviSum[j][MVISUM_MONT]
    *          aTotal4[i] += aMviSum[j][MVISUM_4MONT]
    *          exit
    *        endif
    *      endif
    *    next i
    *    if ! lFound
    *      cLine += " " + space(LenMntF())
    *    endif
    *  next i
    *  if cDetail == BUTTON_ON
    *    PrintLine(cLine)
    *  endif
    *next k
    *if cDetail == BUTTON_ON
    *  cLine := padl("Rechnerische Summe der Buchungen",nPad)
    *  for i := 1 to len(aCdc)
    *    cLine += " " + ntomf(aSum[i])
    *  next i
    *  PrintLine(cLine)
    *  PrintLine()
    *endif
    *open area oCtb()
    *  if cIdCtr == DC_DEBIT
    *    cLine := padl("Stand Haushalt-Zahlungsverpflichtungen-Ausgaben (alle Perioden)",nPad)
    *  else
    *    cLine := padl("Stand Haushalt-Anrechte-Einnahmen (alle Perioden)",nPad)
    *  endif
    *  for i := 1 to len(aCdc)
    *    seek cIdCtr + cIdBud + cPerCtr + aCdc[i][CDC_IDCDC]
    *    cLine += " " + ntomf(val(CTB->Mont))
    *  next i
    *  PrintLine(cLine)
    *  cLine := padl("Saldo",nPad)
    *  for i := 1 to len(aCdc)
    *    seek cIdCtr + cIdBud + cPerCtr + aCdc[i][CDC_IDCDC]
    *    cLine += " " + CtbBudAvail() // ntomf(val(CTB->Mont))
    *  next i
    *  PrintLine(cLine)
    *close area
    * if cFormFeed == BUTTON_ON
    *   p_Eject()
    * endif
  enddo
  *PrintLine()
  *cLine := padl("GESAMT-SUMME",nPad)
  *for i := 1 to len(aCdc)
  *  cLine += " " + ntomf(aTotal[i])
  *next i
  *PrintLine(cLine)
  *cLine := padl("GESAMT-SUMME OHNE DIENST 4",nPad)
  *for i := 1 to len(aCdc)
  *  cLine += " " + ntomf(aTotal4[i])
  *next i
  *PrintLine(cLine)
  close printer
close area
RETURN NIL


#endif DEF_IMP

#ifdef DEF_JNL

FUNCTION JnlMatch(jnl,cIdJnl,cIdGrj,aJnl)
RETURN .f. if jnl == NIL
if ! empty(cIdGrj)
  RETURN .f. if jnl[JNL_IDGRJ] != cIdGrj
endif
if aJnl != NIL
  RETURN .f. if ! JnlIsInList(jnl[JNL_IDJNL],aJnl)
endif
RETURN .t. if empty(cIdJnl)
cIdJnl := trim(cIdJnl)
RETURN .t. if left(jnl[JNL_IDJNL],len(cIdJnl)) == cIdJnl
RETURN .f.

FUNCTION JnlIsInList(cIdJnl,aJnl)
local i
* [970909] (FFO befriedigt FFO in [F5])
* Eine FFO kann nÑmlich absolut kein anderes Journal befriedigen, also
* ist saJnl ein leeres array
* RETURN .t. if len(aJnl) == 0
for i := 1 to len(aJnl)
  RETURN .t. if aJnl[i][JNL_IDJNL] == cIdJnl
next i
RETURN .f.



**
** JnlClean() - hie· bis zum 19980630 Aufraeumen()
**
FUNCTION JnlClean(cIdGrj,cIdJnl,cTitle,xlJnlFilter)
local nCount := 0
local jnl
local cLine
local cNoDelete := BUTTON_ON
local cPeriode := space(LEN_PERIODE)
local lOkay := .f.
local nDocCount := 0
default xlJnlFilter to "JNL->Alias=='VEN'.and.!'G'$JNL->Attrib"
default cIdGrj to space(LEN_IDGRJ)
default cIdJnl to space(LenIdJnl())
#ifdef LG_GERMAN
  default cTitle to "AufrÑumen"
#else
  default cTitle to "Nettoyage"
#endif
open window (cTitle) size 8,60 help JNLCLEAN
say "Journalgruppe "
get cIdGrj picture PIC_ID  pick PickGrj(cIdGrj)
say "Journal "
get cIdJnl picture PIC_ID ;
           pick DbfPick( ;
             {oJnl()}, ;
             cTitle, ;
             "JNLPICK",;
             xlJnlFilter, ;
             NIL,NIL,"JNL->IdJnl" ;
           )
           * pick PickIdJnl( ;
           *   NIL,cIdJnl, ;
           *   JnlList({|j|empty(cIdGrj).or.j[JNL_IDGRJ]==cIdGrj}) ;
           * )
WinCr()
* say "Dokumente von "
* get cIdDoc1 picture PIC_ID pick PickDoc(cIdJnl,cIdDoc1)
* say " bis "
* get cIdDoc2 picture PIC_ID pick PickDoc(cIdJnl,cIdDoc2)
* WinCr()
* SayGetPeriode()
say "Bis einschlie·lich Periode "
get cPeriode picture PIC_ID ;
             pick PickPer(cPeriode) ;
             valid PerExist(cPeriode)
WinCr()
get cNoDelete checkbox
say " nur Liste drucken (nichts lîschen)"
WinCr()
GetPreview() ; WinCr()
SetTplIni("LISTE")
GetTplIni()
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
open area oJnl()
  lOkay := .t.
  go top
  do while ! eof()
    if (jnl := JnlLocate(JNL->IdJnl)) != NIL
      if JnlMatch(jnl,cIdJnl,cIdGrj)
        * if JNLATTR_G $ jnl[JNL_ATTRIB]
        if JnlDoHst(jnl)
          Warning( ;
            JNL->IdJnl + " : bewegt Generalkonten.", ;
            "AufrÑumen verweigert." ;
          )
          lOkay := .f.
        endif
      endif
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
if cNoDelete == BUTTON_OFF
  RETURN .f. if ! Confirm( ;
    "Die angegebenen Dokumente werden unwiderruflich gelîscht !", ;
    MsgSure() ;
  )
endif
open printer SetTplIni() ;
     preview SetPreview() ;
     titblock {|| ;
       PrintHeader( ;
         cTitle , ;
         PerText() ;
       ) ;
     }
#ifdef DEF_VEN
  lOkay := .f.
  open area oVen()
    lOkay := .t.
    if empty(cIdJnl)
      go top
    else
      softseek cIdJnl
    endif
    do while ! eof()
      if ! empty(cIdJnl) .and. VEN->IdJnl > cIdJnl
        exit
      endif
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      if VEN->Periode <= cPeriode
        if (jnl := JnlLocate(VEN->IdJnl)) != NIL
          if JnlMatch(jnl,cIdJnl,cIdGrj)
            * if empty(cIdGrj) .or. jnl[JNL_IDGRJ] == cIdGrj
              * if empty(cIdDoc1) .or. VEN->IdDoc >= cIdDoc1
                * if empty(cIdDoc2) .or. VEN->IdDoc <= cIdDoc2
                  if VenCanDelete()
                    cLine := VEN->IdJnl + " " + VEN->IdDoc
                    if cNoDelete == BUTTON_OFF
                      if VenClean()
                        cLine += " wurde gelîscht."
                        nDocCount++
                      else
                        cLine += " konnte nicht gelîscht werden."
                      endif
                    else
                      cLine += " wÑre gelîscht worden."
                    endif
                    PrintLine(cLine)
                  endif
                * endif
              * endif
            * endif
          endif
        endif
      endif
      skip
    enddo
  close area
#endif DEF_VEN
RETURN .f. if ! lOkay
PrintLine(ntrim(nDocCount) + " Dokumente wurden gelîscht.")
#ifdef DEF_ARC
  if cNoDelete == BUTTON_OFF
    open area oJnl()
      go top
      do while ! eof()
        if (jnl := JnlLocate(JNL->IdJnl)) != NIL
          if JnlMatch(jnl,cIdJnl,cIdGrj)
            if JNL->ArcPeriode < cPeriode
              if ddRecLock()
                JNL->ArcPeriode := cPeriode
                unlock record
              else
                PrintLine(cIdJnl + " : ddRecLock() failed !")
              endif
            endif
          endif
        endif
        skip
      enddo
    close area
  endif
#endif DEF_ARC
close printer
RETURN lOkay

#endif DEF_JNL

#ifdef DEF_VEN

FUNCTION VenCanDelete
local lOkay := .f.
#ifdef DEF_VNA
  open area oVna()
    lOkay := .t.
    ddSetOrder(ORD_VNA_ID)
    softseek VEN->IdJnl + VEN->IdDoc
    do while ! eof() .and. VNA->IdDoc == VEN->IdDoc .and. VNA->IdJnl == VEN->IdJnl
      if empty(VNA->Satis)
        lOkay := .f.
        exit
      endif
      skip
    enddo
  close area
#else
  lOkay := .t.
#endif DEF_VNA
RETURN lOkay

#endif DEF_VEN


#ifdef DEF_MVS

#define MS_IDJNL  1
#define MS_QD     2
#define MS_QC     3
#define MS_VD     4
#define MS_VC     5
#define MS_QR     6
#define MS_VR     7
#define MS_ALEN   7

**
** HistArt() - Historique stock
**
FUNCTION HistArt(cIdFrom)
local ms
local nWidth // := 16 + LenIdJnl() + LEN_IDDOC + LEN_LIBELL
local nCount := 0
local cLine
local nLines
local cTit1 := ""
local cTit2 := ""
local cIdArt   := NIL
local i
local aSumArt
local aSum := {}
local aJnl := JnlList({|j|JNLATTR_S $ j[JNL_ATTRIB]})
static cValue := BUTTON_ON
static cRest  := BUTTON_OFF
static cIdJnl := NIL
static scIdFrom :=  NIL
static scIdTo   :=  NIL
static cJnlSum  :=  NIL
static cJnlList :=  NIL
* static cDetail  :=  NIL
default scIdFrom to space(LenIdArt())
default scIdTo   to space(LenIdArt())
default cJnlSum  to BUTTON_ON
default cJnlList  to space(20)
* default cDetail to BUTTON_ON
if cIdFrom  != NIL
  scIdFrom  := padr(cIdFrom,LenIdArt())
  scIdTo    := padr(cIdFrom,LenIdArt())
endif
open window (MsgHistArt()) size 11,60 help HISTART
SayGetPeriode()
GetPreview() ; WinCr()
SetTplIni("HIST")
GetTplIni()
GetRange()
say "Artikel von "
if cIdFrom == NIL
  @ row(), col() get scIdFrom picture PIC_ID pick PickArt(scIdFrom)
  say MSG042
  @ row(), col() get scIdTo picture PIC_ID   pick PickArt(scIdTo)
else
  say cIdFrom
endif
WinCr()
@ row(), col() get cValue checkbox
say " valorisiert"
WinCR()
@ row(), col() get cRest checkbox
say " Restlagerwert"
* WinCR()
* get cDetail checkbox
* say " jede Bewegung detaillieren"
WinCr()
get cJnlSum checkbox
say " Summen pro Journal"
WinCr()
say "ausschlie·lich Journale "
get cJnlList picture PIC_ID
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
RETURN NIL if ! WrnJnlOpen()
open area oArt(), oMvs(), oPar()
  MVS->(ddSetOrder(ORD_MVS_ART))
  open printer SetTplIni() ;
               preview  SetPreview() ;
               range    SetRange() ;
               titblock {|| ;
                 PrintHeader( ;
                   MsgHistArt() + " " , ;
                   PerText() ;
                 ), ;
                 PrintLine(cTit1), ;
                 PrintLine(cTit2)  ;
               }
  cTit1 := padr("Art.Nr",LenIdArt()) + " "
  cTit2 := repl("ƒ",LenIdArt()) + " "
  cTit1 += padr(MsgPeriode(MemLang1),4) + " "
  cTit2 += repl("ƒ",4) + " "
  cTit1 += padr(MsgDate(MemLang1),len(dtoc(UserDate()))) + " "
  cTit2 += repl("ƒ",len(dtoc(UserDate()))) + " "
  cTit1 += padr(MsgIdDoc(MemLang1),LenIdJnl() + 1 + LEN_IDDOC) + " "
  cTit2 += repl("ƒ",LenIdJnl() + 1 + LEN_IDDOC) + " "
  cTit1 += padr(MsgDescript(MemLang1),LEN_LIBELL)
  cTit2 += repl("ƒ",LEN_LIBELL)
  nWidth := len(cTit2)
  cTit1 += " " + padr("Aus",LenQte())
  cTit2 += " " + repl("ƒ",LenQte())
  cTit1 += " " + padr("Ein",LenQte())
  cTit2 += " " + repl("ƒ",LenQte())
  if cValue == BUTTON_ON .or. cRest == BUTTON_ON
    cTit1 += " " + padr("StÅckpreis",LenMont())
    cTit2 += " " + repl("ƒ",LenMont())
  endif
  if cValue == BUTTON_ON
    * cTit1 += " " + padr(MsgDebit(MemLang1),LenMntF())
    * cTit2 += " " + repl("ƒ",LenMntF())
    cTit1 += " " + padl("Wert",LenMntF())
    cTit2 += " " + repl("ƒ",LenMntF())
    * cTit1 += " " + padl(MsgSolde(MemLang1),LenSolde())
    * cTit2 += " " + repl("ƒ",LenSolde())
  endif
  if cRest == BUTTON_ON
    cTit1 += " " + padr("Rest",LenQte())
    cTit2 += " " + repl("ƒ",LenQte())
    cTit1 += " " + padr("Restwert",LenMont())
    cTit2 += " " + repl("ƒ",LenMont())
  endif
  p_SetWidth(len(cTit2))
  softseek trim(scIdFrom)
  do while ! eof() .and. LstContinue()
    if TaskInter() ; exit ; endif
    cLine   := ART->IdArt + " " + ART->Name1
    cIdArt := ART->IdArt
    if ! empty(scIdTo) .and. cIdArt > scIdTo
      exit
    endif
    nLines := 0
    aSumArt := {}
    select MVS
    softseek cIdArt
    do while ! eof() .and. MVS->IdArt == cIdArt .and. LstContinue()
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      if ! ARTATTR_S $ ART->Attrib
        if empty(cJnlList) .or. MVS->IdJnl $ cJnlList
          if ChkPeriode(MVS->Periode) < 0
            MvsSumCollect(aSumArt,"T")
            MvsSumCollect(aSumArt,"I")
            MvsSumCollect(aSum,"T")
          elseif ChkPeriode(MVS->Periode) == 0
            MvsSumCollect(aSumArt,"T")
            MvsSumCollect(aSumArt,MVS->IdJnl)
            MvsSumCollect(aSum,"T")
            ** code repeated below !
            if nLines == 0
              KeepTogether(7)
              cLine   := ART->IdArt + " " + ART->Name1
              cLine := padr(cLine,nWidth)
              if (ms := MsLook(aSumArt,"I")) != NIL
                cLine += MsLine(ms,cValue,cRest)
              endif
              PrintLine(cLine)
              nLines++
            endif
            ** end of code repeated below
            cLine := space(LenIdArt())
            cLine += " " + dtoc(MVS->Date)
            cLine += " " + MVS->Periode
            cLine += " " + MVS->IdJnl
            cLine += " " + MVS->IdDoc
            cLine += " " + ParName(MVS->IdPar)
            cLine := padr(cLine,nWidth)
            if MVS->DC == DC_DEBIT
              cLine += " " + komma(MVS->Qte)
              cLine += " " + space(LenQte())
              if cValue == BUTTON_ON
                cLine += " " + komma(ntom(val(MVS->Mont)/qton(MVS->Qte),ArtPuDecPos()))
                cLine += " " + ntomf(-val(MVS->Mont))
                * cLine += " " + space(LenMntF())
              endif
            else
              cLine += " " + space(LenQte())
              cLine += " " + komma(MVS->Qte)
              if cValue == BUTTON_ON
                cLine += " " + komma(ntom(val(MVS->Mont)/qton(MVS->Qte),ArtPuDecPos()))
                * cLine += " " + space(LenMntF())
                cLine += " " + ntomf(val(MVS->Mont))
              endif
            endif
            if cRest == BUTTON_ON
              cLine += " " + komma(MVS->QteVal)
              cLine += " " + ntomf(qton(MVS->QteVal) * val(MVS->Mont)/qton(MVS->Qte),ArtPuDecPos())
            endif
            PrintLine(cLine)
            nLines++
          endif
        endif
      endif
      skip
    enddo
    select ART
    ** code repeated above
    if nLines == 0
      if (ms := MsLook(aSumArt,"I")) != NIL
        KeepTogether(7)
        cLine   := ART->IdArt + " " + ART->Name1
        cLine := padr(cLine,nWidth)
        cLine += MsLine(ms,cValue,cRest)
        PrintLine(cLine)
        nLines++
      endif
    endif
    ** end of code repeated above
    if nLines > 0
      if nLines > 2
        if cValue == BUTTON_ON
          PrintLine( space(nWidth) + " " + repl("ƒ",2*LenQte() +  LenMont() + 2*LenMntF() + 4) )
        else
          PrintLine( space(nWidth) + " " + repl("ƒ",2 * LenQte() + 1) )
        endif
        for i := 1 to len(aJnl)
          if (ms := MsLook(aSumArt,aJnl[i][JNL_IDJNL])) != NIL
            cLine := padl(aJnl[i][JNL_IDJNL] ,nWidth)
            cLine += MsLine(ms,cValue,cRest)
            PrintLine(cLine)
          endif
        next i
        if (ms := MsLook(aSumArt,"T")) != NIL
          cLine := padl("Bestand " + trim(ART->IdArt) + " " + trim(ART->Name1),nWidth)
          ** éhnlich wie MsLine() :
          * if ms[MS_QD] > ms[MS_QC]
          *   cLine += " " + komma(ntoq(ms[MS_QD]-ms[MS_QC],ART->QteForm))
          *   cLine += " " + space(LenQte())
          * else
            cLine += " " + space(LenQte())
            cLine += " " + komma(ntoq(ms[MS_QC]-ms[MS_QD],ART->QteForm))
          * endif
          if cValue == BUTTON_ON .or. cRest == BUTTON_ON
            cLine += " " + space(LenMont())
            if cValue == BUTTON_ON
              cLine += " " + ntomf(ms[MS_VC] - ms[MS_VD])
            endif
            if cRest == BUTTON_ON
              cLine += " " + komma(ntoq(ms[MS_QR],ART->QteForm))
              cLine += " " + ntomf(ms[MS_VR])
            endif
          endif
          PrintLine(cLine)
        endif
      endif
      PrintLine()
    endif
    skip
  enddo
  if cValue == BUTTON_ON .or. cRest == BUTTON_ON
    PrintLine()
    if (ms := MsLook(aSum,"T")) != NIL
      cLine := padr(upper(MsgTotal()),nWidth)
      ** éhnlich wie MsLine() :
      cLine += " " + space(LenQte())
      cLine += " " + space(LenQte())
      cLine += " " + space(LenMont())
      if cValue == BUTTON_ON
        cLine += " " + ntomf(ms[MS_VC]-ms[MS_VD])
      endif
      if cRest == BUTTON_ON
        cLine += " " + space(LenQte())
        cLine += " " + ntomf(ms[MS_VR])
      endif
      PrintLine(cLine)
    endif
  endif
  close printer
close area
RETURN NIL

FUNCTION MvsSumCollect(a,cIdJnl)
local i
local ms := NIL
for i := 1 to len(a)
  if a[i][MS_IDJNL] == cIdJnl // MVS->IdJnl
    ms := a[i]
  endif
next i
if ms == NIL
  ms := array(MS_ALEN)
  ms[MS_IDJNL] := cIdJnl // MVS->IdJnl
  ms[MS_QD] := 0
  ms[MS_QC] := 0
  ms[MS_VD] := 0
  ms[MS_VC] := 0
  ms[MS_VR] := 0
  ms[MS_QR] := 0
  aadd(a,ms)
endif
if MVS->DC == DC_DEBIT
  ms[MS_QD] += qton(MVS->Qte)
  ms[MS_VD] += val(MVS->Mont)
  ms[MS_QR] -= qton(MVS->QteVal)
  if qton(MVS->Qte) != 0
  *   Warning("MVS->Qte == 0 !")
  * else
    ms[MS_VR] -= qton(MVS->QteVal) * val(MVS->Mont) / qton(MVS->Qte)
  endif
else
  ms[MS_QC] += qton(MVS->Qte)
  ms[MS_VC] += val(MVS->Mont)
  ms[MS_QR] += qton(MVS->QteVal)
  if qton(MVS->Qte) != 0
  *   Warning("MVS->Qte == 0 !")
  * else
    ms[MS_VR] += qton(MVS->QteVal) * val(MVS->Mont) / qton(MVS->Qte)
  endif
endif
RETURN NIL

FUNCTION MsLook(a,cIdJnl)
local i
local cLine := ""
for i := 1 to len(a)
  if a[i][MS_IDJNL] == cIdJnl
    RETURN a[i]
  endif
next i
RETURN NIL


FUNCTION MsLine(ms,cValue,cRest)
local i
local cLine := ""
if ms[MS_QD] > ms[MS_QC]
  cLine += " " + komma(ntoq(ms[MS_QD]-ms[MS_QC],ART->QteForm))
  cLine += " " + space(LenQte())
else
  cLine += " " + space(LenQte())
  cLine += " " + komma(ntoq(ms[MS_QC]-ms[MS_QD],ART->QteForm))
endif
if cValue == BUTTON_ON .or. cRest == BUTTON_ON
  cLine += " " + space(LenMont()) // StÅckwert
  if cValue == BUTTON_ON
    cLine += " " + ntomf(ms[MS_VC]-ms[MS_VD])
  endif
  if cRest == BUTTON_ON
    cLine += " " + komma(ntoq(ms[MS_QR],ART->QteForm))
    cLine += " " + ntomf(ms[MS_VR])
  endif
endif
RETURN cLine


FUNCTION MsgHistArt()
#ifdef LG_GERMAN
  RETURN "Lagerhistorik"
#else
  RETURN "Historique stock"
#endif

FUNCTION MsgBalArt()
#ifdef LG_GERMAN
  RETURN "Lagerwertliste"
#else
  RETURN "Stock comptable"
#endif

FUNCTION MsgMvsValorise()
#ifdef LG_GERMAN
  RETURN "Lagerhistorik auswerten"
#else
  RETURN "Valoriser historique stock"
#endif

**
** MvsValorise()
**
FUNCTION MvsValorise(cIdArt1)
local lOkay := .t.
local nCount := 0
local nQteStock
local nValStock
local nQte
local nMont
static cOverwrite
local cIdArt
default cIdArt1 to ""
default cOverwrite to BUTTON_ON
open window (MsgMvsValorise(UsrLang())) size 4,50 help MVSVAL
* SayGetPeriode()
get cOverwrite checkbox
say " bestehende Wertungen neu rechnen"
WinCr()
say "Aktive Periode(n) : " + MemMvsPeriode // 970407
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
GsbPeriode(MemMvsPeriode) // 970407
open area oMvs()
  ddSetOrder(ORD_MVS_ART)
  softseek cIdArt1
  do while lOkay .and. ! eof()
    if ! empty(cIdArt1)
      if MVS->IdArt != cIdArt1
        exit
      endif
    endif
    cIdArt := MVS->IdArt
    nQteStock := 0
    nValStock := 0
    do while lOkay .and. MVS->IdArt == cIdArt .and. ! eof()
      if TaskInter() ; lOkay := .f. ; exit ; endif
      MsgDisp2(ntrim0(50 * nCount++ / lastrec()) + "%")
      if empty(MVS->Mont)
        if ChkPeriode(MVS->Periode) < 0
        * if MVS->Periode <= MemMvsPeriode // 970407
          Warning(MsgIdJnlDoc() + " : unvalorisierte Buchung vor " + MVS->Periode + " !")
          lOkay := .f.
        endif
      else
        * if MVS->Periode > MemMvsPeriode
        if ChkPeriode(MVS->Periode) == 0 // 970407
          if cOverwrite == BUTTON_ON .and. ! JNLATTR_V $ JnlAttrib(MVS->IdJnl)
            if ddRecLock()
              MVS->Mont   := ""
              unlock record
            else
              lOkay := .f.
            endif
          endif
        endif
      endif
      if ! empty(MVS->Mont)
        if ChkPeriode(MVS->Periode) == 0
          nQte  := qton(MVS->Qte) - qton(MVS->QteVal)
          if MVS->DC == DC_DEBIT
            ** valorisierter Ausgang
            nQteStock -= nQte
            nValStock -= nQte * val(MVS->Mont) / qton(MVS->Qte)
          else
            ** valorisierter Eingang
            nQteStock += nQte
            nValStock += nQte * val(MVS->Mont) / qton(MVS->Qte)
          endif
        endif
      endif
      skip
    enddo
    softseek cIdArt
    do while lOkay .and. MVS->IdArt == cIdArt .and. ! eof()
      if TaskInter() ; lOkay := .f. ; exit ; endif
      MsgDisp2(ntrim0(50 * nCount++ / lastrec()) + "%")
      if empty(MVS->Mont)
        if ChkPeriode(MVS->Periode) == 0 // 970407
        * if MVS->Periode > MemMvsPeriode
          if nQteStock != 0
            nQte  := qton(MVS->Qte)
            nMont := (nValStock / nQteStock) * nQte
            if MVS->DC == DC_DEBIT
              ** zu valorisierender Ausgang
              if nQteStock - nQte >= - 0.001
                if ddRecLock()
                  MVS->Mont   := ntom(nMont)
                  nQteStock -= nQte
                  nValStock -= nMont
                  unlock record
                else
                  lOkay := .f.
                endif
              endif
            else
              ** zu valorisierender Eingang
              if ddRecLock()
                MVS->Mont := ntom(nMont)
                nQteStock += nQte
                nValStock += nMont
                unlock record
              else
                lOkay := .f.
              endif
            endif
          endif
        endif
      endif
      skip
    enddo
  enddo
close area
ddMustScan(.t.)
RETURN MnuDone()

#define MVSBAL_QPD  1
#define MVSBAL_VPD  2
#define MVSBAL_QPC  3
#define MVSBAL_VPC  4
#define MVSBAL_QI   5
#define MVSBAL_VI   6
#define MVSBAL_ALEN 6

**
** BalArt() - Saldenliste ("Balance") Partnerkonten
**
FUNCTION BalArt()
local cTit1 := space(40)
local cTit2 := padr("Artikel",40)
local cTit3 := repl("ƒ",40)
local nCount := 0
local cIdArt
local cLine
local cTitle := MSG006
local aArt
local aTot := { 0, 0, 0, 0, 0, 0 } // MVSBAL_ALEN
static cIdArt1
static cIdArt2
default cIdArt1 to space(LenIdArt())
default cIdArt2 to space(LenIdArt())
open window (MsgBalArt()) size 7,60 help BALART
say "Artikel von "
get cIdArt1 picture PIC_ID pick PickArt(cIdArt1)
say " bis "
get cIdArt2 picture PIC_ID pick PickArt(cIdArt2)
WinCr()
SayGetPeriode()
GetPreview() ; WinCr()
SetTplIni("BAL")
GetTplIni()
GetRange()
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
RETURN NIL if ! WrnJnlOpen()
open printer SetTplIni() ;
     preview SetPreview() ;
     range   SetRange() ;
     TitBlock {|| ;
       PrintHeader(MsgBalArt() ,PerText()), ;
       PrintLine(cTit1) ,;
       PrintLine(cTit2) ,;
       PrintLine(cTit3)  ;
     }
cTit1 += " " + padc("Anfangsbestand",LenQte() + 1 + LenMntF())
cTit2 += " " + padl("Menge",LenQte())
cTit2 += " " + padl("Wert",LenMntF())
cTit3 += " " + repl("ƒ",LenQte() + 1 + LenMntF())
cTit1 += " " + padc("EingÑnge",LenQte() + 1 + LenMntF())
cTit2 += " " + padl("Menge",LenQte())
cTit2 += " " + padl("Wert",LenMntF())
cTit3 += " " + repl("ƒ",LenQte() + 1 + LenMntF())
cTit1 += " " + padc("AusgÑnge",LenQte() + 1 + LenMntF())
cTit2 += " " + padl("Menge",LenQte())
cTit2 += " " + padl("Wert",LenMntF())
cTit3 += " " + repl("ƒ",LenQte() + 1 + LenMntF())
cTit1 += " " + padc("Endbestand",LenQte() + 1 + LenMntF())
cTit2 += " " + padl("Menge",LenQte())
cTit2 += " " + padl("Wert",LenMntF())
cTit3 += " " + repl("ƒ",LenQte() + 1 + LenMntF())
p_SetWidth(len(cTit3))
open area oMvs(), oArt()
  ddSetOrder(ORD_MVS_ART)
  softseek trim(cIdArt1)
  do while ! eof() .and. LstContinue()
    if TaskInter() ; exit ; endif
    if ! empty(cIdArt2)
      if MVS->IdArt > cIdArt2
        exit
      endif
    endif
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    cIdArt := MVS->IdArt
    aArt := { 0, 0, 0, 0, 0, 0 } // MVSBAL_ALEN
    do while ! eof() .and. MVS->IdArt == cIdArt
      MvsAddBal(aArt)
      MvsAddBal(aTot)
      skip
    enddo
    seek cIdArt in ART
    cLine := cIdArt
    cLine += " " + ART->Name1
    cLine := padr(cLine,40)
    cLine += " " + ntoq(aArt[MVSBAL_QI], ART->QteForm)
    cLine += " " + ntomf(aArt[MVSBAL_VI])
    cLine += " " + ntoq(aArt[MVSBAL_QPC], ART->QteForm)
    cLine += " " + ntomf(aArt[MVSBAL_VPC])
    cLine += " " + ntoq(aArt[MVSBAL_QPD], ART->QteForm)
    cLine += " " + ntomf(aArt[MVSBAL_VPD])
    cLine += " " + ntoq(aArt[MVSBAL_QI] + aArt[MVSBAL_QPC] - aArt[MVSBAL_QPD], ART->QteForm)
    cLine += " " + ntomf(aArt[MVSBAL_VI] + aArt[MVSBAL_VPC] - aArt[MVSBAL_VPD])
    if aArt[MVSBAL_QI] + aArt[MVSBAL_QPC] - aArt[MVSBAL_QPD] != 0
      PrintLine(cLine)
    elseif aArt[MVSBAL_VI] + aArt[MVSBAL_VPC] - aArt[MVSBAL_VPD] != 0
      PrintLine(cLine)
    elseif aArt[MVSBAL_VPC] != 0 .or. aArt[MVSBAL_VPD] != 0
      PrintLine(cLine)
    elseif aArt[MVSBAL_QPC] != 0 .or. aArt[MVSBAL_QPD] != 0
      PrintLine(cLine)
    endif
  enddo
close area
PrintLine()
cLine := "SUMME"
if ! empty(cIdArt1 + cIdArt2)
  cLine += " (Artikel " + trim(cIdArt1) + " bis " + trim(cIdArt2) + ")"
endif
cLine := padr(cLine,40)
cLine += " " + space(LenQte())
cLine += " " + ntomf(aTot[MVSBAL_VI])
cLine += " " + space(LenQte())
cLine += " " + ntomf(aTot[MVSBAL_VPC])
cLine += " " + space(LenQte())
cLine += " " + ntomf(aTot[MVSBAL_VPD])
cLine += " " + space(LenQte())
cLine += " " + ntomf(aTot[MVSBAL_VI] + aTot[MVSBAL_VPC] - aTot[MVSBAL_VPD])
PrintLine(cLine)
close printer
RETURN NIL

FUNCTION MvsAddBal(bal)
if ChkPeriode(MVS->Periode) < 0
  if MVS->DC == DC_DEBIT
    bal[MVSBAL_QI] -= qton(MVS->Qte)
    bal[MVSBAL_VI] -= val(MVS->Mont)
  else
    bal[MVSBAL_QI] += qton(MVS->Qte)
    bal[MVSBAL_VI] += val(MVS->Mont)
  endif
elseif ChkPeriode(MVS->Periode) == 0
  if MVS->DC == DC_DEBIT
    bal[MVSBAL_QPD] += qton(MVS->Qte)
    bal[MVSBAL_VPD] += val(MVS->Mont)
  else
    bal[MVSBAL_QPC] += qton(MVS->Qte)
    bal[MVSBAL_VPC] += val(MVS->Mont)
  endif
endif
RETURN NIL

#endif DEF_MVS

#ifdef DEF_IMP

**
** HistPar() - Historique des comptes particuliers
**
FUNCTION HistPar(cColumns,cTplIni)
local jnl
local cTit1 := padr("BuchDat",len(dtoc(UserDate())))
local cTit2 := repl("ƒ",len(dtoc(UserDate())))
local nPad
local doc
local aParSum := {}
local aSum := {}
local lFound
* local nSumAuftr := 0
* local nIniD
* local nIniC
* local nMvtD
* local nMvtC
local cLine
local lPrinted
local cIdPar   := NIL
local i
local aCdc := CdcList(NIL,{|x|x[CDC_DC] + x[CDC_IDCDC] $ cColumns})
* local cIdCtr := PickCtr(NIL,MsgHistPar(UsrLang()))
local cTitle := MsgHistPar(UsrLang())
static cLettre    := BUTTON_OFF
static cIdJnl := NIL
static cIdPar1 :=  NIL
static cIdPar2   :=  NIL
default cIdPar1 to space(LenIdPar())
default cIdPar2   to space(LenIdPar())
default cTplIni to "HIST"
open window (cTitle) size 8,60 help HISTPAR
SayGetPeriode()
GetPreview() ; WinCr()
SetTplIni(cTplIni)
GetTplIni()
GetRange()
say MsgComptes(UsrLang()) + " "
@ row(), col() get cIdPar1 picture PIC_ID ;
               postedit {|x|GetIdPar(x)} ;
               pick PickPar(cIdPar1)
say MSG042
@ row(), col() get cIdPar2 picture PIC_ID ;
               postedit {|x|GetIdPar(x)} ;
               pick PickPar(cIdPar2)
WinCR()
@ row(), col() get cLettre checkbox
say MSG001 // " uniquement les mouvements non lettrÇs"
WinCR()
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
open printer SetTplIni() ;
   preview SetPreview() ;
   range   SetRange() ;
   TitBlock {|| ;
     PrintHeader( ;
       cTitle, ;
       PerText({||.f.}), ;
       NIL, ;
       {||PrintLine(padl(MVI->IdPar,p_cpl()))} ;
     ), ;
     PrintLine(cTit1), ;
     PrintLine(cTit2)  ;
   }
** [970410] "eher wie in Hauptbuch()"
cTit1 += " " + padr("BelDat",len(dtoc(UserDate())))
cTit2 += " " + repl("ƒ",len(dtoc(UserDate())))
cTit1 += " " + padr("Artikel",20)
cTit2 += " " + repl("ƒ",20)
cTit1 += " " + padr("Gegenstand/Ext.Ref.",20)
cTit2 += " " + repl("ƒ",20)
cTit1 += " " + padr("Bezug/RÅckbzg",LenIdJnl() + LenIdDoc() + LEN_POS)
cTit2 += " " + repl("ƒ",LenIdJnl() + LenIdDoc() + LEN_POS)
cTit1 += " " + padr("Per.",LEN_PERIODE)
cTit2 += " " + repl("ƒ",LEN_PERIODE)
cTit1 += " " + padr("Jnl/Belegnr.",LenIdJnl() + LenIdDoc() + 2 + LEN_POS)
cTit2 += " " + repl("ƒ",LenIdJnl() + LenIdDoc() + 2 + LEN_POS)
cTit1 += " " + padr("Nummer",LenIdIml())
cTit2 += " " + repl("ƒ",LenIdIml())
nPad := len(cTit1)
for i := 1 to len(aCdc)
  cTit1 += " " + padr(aCdc[i][CDC_HEADER],LenMntF())
  cTit2 += " " + repl("ƒ",LenMntF())
  aadd(aParSum,0)
  aadd(aSum,0)
next i
cTit1 += " " + padr("AuftrÑge",LenMntF())
cTit2 += " " + repl("ƒ",LenMntF())
  aadd(aParSum,0)
  aadd(aSum,0)
p_setwidth(len(cTit2))
open area oMvi(), oPar(), oIml()
  ddSetOrder(ORD_MVI_PARDATE)
  softseek trim(cIdPar1)
  do while ! eof() .and. LstContinue()
    cIdPar := MVI->IdPar
    if ! empty(cIdPar2) .and. cIdPar > cIdPar2
      exit
    endif
    seek MVI->IdPar in PAR
    lPrinted := .F.
    for i := 1 to len(aParSum)
      aParSum[i] := 0
    next i
    select MVI
    softseek cIdPar
    do while ! eof() .and. MVI->IdPar == cIdPar .and. LstContinue()
      if cLettre == BUTTON_OFF .or. ! empty(MVI->MontUs)
        if ChkPeriode(MVI->Periode) == 0
          if (jnl := JnlLocate(MVI->IdJnl)) != NIL
            if ! lPrinted
              ** code repeated below !
              cLine := cIdPar
              cLine += " : " + ParName()
              PrintLine()
              PrintLine("{B}" + cLine + "{b}")
              lPrinted := .T.
            endif
            * if cDetail == BUTTON_ON
              cLine := dtoc(MVI->Date)
              cLine += " " + dtoc(MVI->Date2)
              cLine += " " + MVI->DC + "-" + SayIdBud(MVI->IdBud)
              cLine += " " + padr(MVI->NB1,20)
              cLine += " " + MVI->Match
              cLine += " " + MVI->Periode
              cLine += " " + MVI->IdJnl
              cLine += " " + MVI->IdDoc
              cLine += " " + MVI->Line
              seek MVI->IdJnl + MVI->IdDoc + MVI->Line in IML
              cLine += " " + IML->IdIml
              lFound := .f.
              for i := 1 to len(aCdc)
                if aCdc[i][CDC_IDCDC] == jnl[JNL_IDCDC] .and. aCdc[i][CDC_DC] == MVI->DC
                  cLine += " " + ntomf(val(MVI->Mont))
                  aParSum[i] += val(MVI->Mont)
                  lFound := .t.
                else
                  cLine += " " + space(LenMntF())
                endif
              next i
              if ! lFound
                cLine += " " + ntomf(val(MVI->Mont))
                aParSum[len(aParSum)] += val(MVI->Mont)
              endif
              PrintLine(cLine)
              cLine := space(17) // + LenIdJnl()+LenIdDoc())
              * cLine += " " + padr(MVI->IdPar2 + " " + ParField(MVI->IdPar2,{||PAR->Firme}),35)
              cLine += " " + padr(MVI->NB2,20)
              cLine += " " + MVI->BackMatch
              PrintLine(cLine)
            * endif
          endif
        endif
      endif
      if TaskInter() ; LstError(PRN_ABORT) ; endif
      skip
    enddo
    if lPrinted
      cLine := MsgTotal() + " " + ParName(cIdPar)
      cLine := padr(cLine,nPad)
      for i := 1 to len(aParSum)
        cLine += " " + ntomf(aParSum[i])
        aSum[i] += aParSum[i]
      next i
      PrintLine(cLine)
    endif
  enddo
  cLine := padr(MsgTotal(),nPad)
  for i := 1 to len(aSum)
    cLine += " " + ntomf(aSum[i])
  next i
  PrintLine()
  PrintLine(cLine)
close area
close printer
RETURN .f.

#endif DEF_IMP


#ifdef DEF_GEN

**
** GenExport() - Saldenliste ("Balance") Generalkonten
**
FUNCTION GenExport(cTitle,cFileName,xlGenFilter)
local fd
local nDebit
local nCredit
local nCount := 0
local i
local cLine
local cInit := BUTTON_ON
static cIdGen1 := NIL
static cIdGen2 := NIL
default cIdGen1 to space(LenIdGen())
default cIdGen2 to space(LenIdGen())
default xlGenFilter to ".t."
cFileName := padr(cFileName,80)
open window (cTitle) size 6,50 help GENEXPOR
  SayGetPeriode()
  say "Konten von "
  get cIdGen1 picture PIC_ID pick PickGen(NIL,cIdGen1)
  say " bis "
  get cIdGen2 picture PIC_ID pick PickGen(NIL,cIdGen2)
  WinCr()
  say "Dateiname  "
  get cFileName picture "@k@!@s35"
  WinCr()
  get cInit checkbox
  say " Beginnsalden berÅcksichtigen"
  nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
AppSaveMem()
cFileName := trim(cFileName)
if file(cFileName)
  RETURN .f. if ! Confirm(cFilename + MsgOverwrite())
endif
if (fd := fcreate(cFileName)) == -1
  Warning(cFilename + MsgDosError(ferror()))
  RETURN .f.
endif
MsgDisplay(cTitle + " (" + cFilename + ")...")
open area oGen()
  softseek trim(cIdGen1)
  do while ! eof()
    if ! empty(cIdGen2)
      if GEN->IdGen > cIdGen2
        exit
      endif
    endif
    if TaskInter() ; exit ; endif
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    if &xlGenFilter
      if len(trim(GEN->IdGen)) == LenIdGen()
        open area oCtg()
          nDebit  := 0
          nCredit := 0
          softseek GEN->IdGen
          do while ! eof() .and. CTG->IdGen == GEN->IdGen
            if (cInit == BUTTON_ON .and. ChkPeriode(CTG->Periode)<=0) ;
              .or. ChkPeriode(CTG->Periode) == 0
              if right(CTG->Periode,1) != CHR_255
                nDebit  += val(CTG->Debit)
                nCredit += val(CTG->Credit)
              endif
            endif
            skip
          enddo
          cLine := padr(GEN->IdGen,10)
          cLine += padl(ntrim(nDebit),11,"0")
          cLine += padl(ntrim(nCredit),11,"0")
          cLine += padr(GEN->Libell1,30)
          fwrite(fd,cLine + CR_LF)
        close area
      endif
    endif
    skip
  enddo
close area
fclose(fd)
MsgDisplay("")
RETURN MnuDone()

#endif DEF_GEN

#ifdef DEF_HST

**
** HistJnl()
**
FUNCTION HistJnl(cTitle,cTplIni)
local i
static cPrintDoc := BUTTON_ON
static cIdJnl := NIL
static cIdGrj := NIL
local aJnl := JnlList({|j|!empty(j[JNL_IDHCL])})
static cIdDoc1
static cIdDoc2
default cIdDoc1 to space(LenIdDoc())
default cIdDoc2 to space(LenIdDoc())
default cIdJnl to space(LenIdJnl())
default cIdGrj to space(LEN_IDGRJ)
default cTplIni to "LISTE"
open window (cTitle) size 9,40 help HISTJNL
say "Journal "
get cIdJnl picture PIC_ID ;
           pick PickIdJnl( ;
             NIL,cIdJnl, ;
             aJnl ;
           ) ;
           valid (cIdGrj:=JnlIdGrj(cIdJnl)) != NIL .and. ph_refresh()
#ifdef LG_GERMAN
say " Gruppe "
#else
say " Groupe "
#endif
get cIdGrj picture PIC_ID ;
           pick PickGrj(cIdGrj) ;
           when empty(cIdJnl)
WinCr()
SayGetPeriode()
GetPreview() ; WinCr()
#ifdef LG_GERMAN
say "Dokumente von "
#else
say "Documents de "
#endif
get cIdDoc1 picture PIC_ID ;
            pick PickDoc(cIdJnl,cIdDoc1) ;
            when !empty(cIdJnl)
#ifdef LG_GERMAN
say " bis "
#else
say " Ö "
#endif
get cIdDoc2 picture PIC_ID ;
            pick PickDoc(cIdJnl,cIdDoc2) ;
            when !empty(cIdJnl)
WinCr()
SetTplIni(cTplIni)
GetTplIni()
GetRange()
@ row(), col() get cPrintDoc checkbox
say MSG054
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
if empty(cIdJnl)
  RETURN .f. if ! WrnJnlOpen({|| JNLATTR_G $ JNL->Attrib })
else
  RETURN .f. if ! WrnJnlOpen({|| JNL->IdJnl == cIdJnl })
endif
AppSaveMem()
for i := 1 to len(aJnl)
  if JnlMatch(aJnl[i],cIdJnl,cIdGrj)
    if ! HstJnlPrint( aJnl[i], cPrintDoc==BUTTON_ON, cIdDoc1, cIdDoc2)
      exit
    endif
  endif
next i
RETURN .f.


**
** HstJnlPrint()  - imprimer un journal
**
FUNCTION HstJnlPrint(jnl, lPrintDoc, cIdDoc1, cIdDoc2 )
* local nDocCount := 0
* local nDocLines
local dDocDate
local i
local j
local cLine
local cIdDoc
local cTit1
local cTit2
local lOkay := .t.
local lFound
local bJnlTest := {||JNL->IdJnl == jnl[JNL_IDJNL]}
local aHcl := ReadArray(jnl[JNL_ALIAS]+jnl[JNL_IDHCL]+".HCL",HCL_ALEN)
local aTtl := ReadArray(jnl[JNL_ALIAS]+jnl[JNL_IDHCL]+".TTL",TTL_ALEN)
local aTtlValues := {}
local cTplIni := SetTplIni()
if TplExist(TPLTYPE_INI,jnl[JNL_ALIAS]+jnl[JNL_IDHCL])
  cTplIni := jnl[JNL_ALIAS]+jnl[JNL_IDHCL]
endif
* saHstGenList := {}
open printer (cTplIni) ;
     preview SetPreview() ;
     range   SetRange()
open area oJnl()
  seek jnl[JNL_IDJNL]
  ClnInit(aHcl,aTtl)
close area
snDocCount := 0
aTtlValues := TtlInit(aHcl,aTtl)
cTit1 := ClnTit1(aHcl,aTtl,aTtlValues)
cTit2 := ClnTit2(aHcl,aTtl,aTtlValues)
p_SetWidth(len(cTit2))
SetPageHeader( {|| ;
  PrintHeader( ;
    MSG028 + jnl[JNL_IDJNL] + " : " + jnl[JNL_NAME], ;
    PerText(bJnlTest) ;
  ), ;
  PrintLine(cTit1) , ;
  PrintLine(cTit2)   ;
} )
RuptInit(jnl[JNL_IDJNL])
MsgDisplay(jnl[JNL_IDJNL] + " " + JnlName(jnl[JNL_IDJNL]))
open area oHst(), oPar(), oGen(), oVen(), oFin()
  ddSetOrder(ORD_HST_DOC)
  softseek jnl[JNL_IDJNL] + trim(cIdDoc1)
  do while lOkay .and. ! eof() .and. HST->IdJnl == jnl[JNL_IDJNL]
    if TaskInter() ; lOkay := .f. ; exit ; endif
    if ! empty(cIdDoc2) .and. HST->IdDoc > cIdDoc2 ; exit ; endif
    if ChkPeriode(HST->Periode) == 0
      if ! RuptCheck(jnl,HST->IdDoc,HST->Periode)
        if ! Confirm(SetMsg(),MsgContinue())
          lOkay := .f.
          exit
        endif
      endif
      cIdDoc := HST->IdDoc
      snHclSubCount := 0 // nDocLines := 0
      dDocDate  := HST->Date
      KeepBlockBegin()
      IsSame()
      do while lOkay .and. ! eof() ;
                     .and. HST->IdJnl == jnl[JNL_IDJNL] ;
                     .and. HST->IdDoc == cIdDoc
        snHclSubCount++ // nDocLines++
        * DictAddItem(saHstGenList,HST->IdGen)
        seek HST->IdPar in PAR
        seek HST->IdGen in GEN
        #ifdef DEF_FIN
          if jnl[JNL_ALIAS] == JNLALIAS_FIN
            seek HST->IdJnl + HST->IdDoc in FIN
          endif
        #endif DEF_FIN
        #ifdef DEF_VEN
          if jnl[JNL_ALIAS] == JNLALIAS_VEN
            seek HST->IdJnl + HST->IdDoc in VEN
          endif
        #endif DEF_VEN
        *if nDocLines == 1
        *  cLine := HST->IdDoc
        *  cLine += " " + dtoc(HST->Date)
        *else
        *  cLine := space(LEN_IDDOC)
        *  if HST->Date == dDocDate
        *    cLine += " " + space(8)
        *  else
        *    cLine += " " + dtoc(HST->Date)
        *  endif
        *endif
        *if empty(HST->IdPar)
        *  cLine += " " + "G" + " " + padr(HST->IdGen,LenCompte())
        *else
        *  cLine += " " + HST->IdCtr + " " + padr(HST->IdPar,LenCompte())
        *endif
        *cLine += " "
        if ! ClnEval(aHcl,aTtl,{aTtlValues},NIL,lPrintDoc)
          lOkay := .f.
        endif
        skip
      enddo
      KeepBlockEnd()
      if snHclSubCount > 0 // nDocLines > 0
        snDocCount++
      endif
    else
      skip
    endif
  enddo
close area
if lOkay .and. snDocCount > 0
  PrintLine(cTit2)
  PrintLine()
  cLine := jnl[JNL_NAME] + " " + PerText(bJnlTest) + " : "
  cLine += ntrim(snDocCount) + " Dokument"
  if snDocCount > 1
    cLine += "e"
  endif
  PrintLine(cLine)
  PrintLine()
  ClnTotal(aHcl,aTtl,aTtlValues)
endif
close printer
RETURN lOkay


FUNCTION IsSame(uValue)
static suLastValue := NIL
if uValue == NIL
  suLastValue := NIL
  RETURN .t.
endif
RETURN .f. if suLastValue == NIL
RETURN .t. if suLastValue == uValue
suLastValue := uValue
RETURN .f.


**
** HstDateListe("Haupt-Kassenbuch","HSTDATE")
**
*FUNCTION HstDateListe(cTitle,cIdHcl)
*static dDate1
*static dDate2
*default dDate1 to UserDate()
*default dDate2 to UserDate()
*open window (cTitle) size 4,max(40,len(cTitle))
*SayGetPeriode()
*WinCr()
*say "Datum : vom "
*get dDate1
*say " bis zum "
*get dDate2
*nKey := ReadScr()
*close window
*RETURN NIL if nKey == K_ESC
*DbfReport( ;
*  cTitle, ;
*  dtocf(dDate1) + "-" + dtocf(dDate2),;
*  PerText(),;
*  cIdHcl, ;
*  { oHst(),oPar(),oGen(),oVen(),oFin() }, ;
*  ORD_HST_DATE, ;
*  MemPer1 + dtos(dDate1), ;
*  "HST->Date<=dDate2", ;
*  ".t.", ;
*  "HST->Date", "dtocf(HST->Date)", ;
*  "GenExist(IdGen).and.(empty(IdPar).or.ParExist(IdPar)).and.DocExist(IdJnl,IdDoc)" ;
*)
*RETURN NIL



**
** DbfReport()
**
FUNCTION DbfReport( ;
  cHeader1, ;
  cHeader2, ;
  cHeader3, ;
  cIdHcl, ;
  adTables, ;
  nOrder, ;
  cStart, ;
  xlWhile, ;
  xlFilter,  ;
  xuSubKey,  ;
  xcSubText, ;
  xlPrepare, ;
  xlDetail  ;
)
local cKey
local uSubKey
local cSubText
local dDocDate
local i
local j
local cLine
local cIdDoc
local cTit1
local cTit2
local lOkay := .t.
local aHcl := ReadArray(cIdHcl+".HCL",HCL_ALEN)
local aTtl := ReadArray(cIdHcl+".TTL",TTL_ALEN)
local aTtlValues
local aSubValues
local cTplIni := SetTplIni()
default xuSubKey to "''"
default xcSubText to "''"
default xlDetail to ".t."
default xlWhile to ".t."
default cStart to ""
if TplExist(TPLTYPE_INI,cIdHcl)
  cTplIni := cIdHcl
endif
open printer (cTplIni) ;
     preview SetPreview() ;
     range   SetRange()
ClnInit(aHcl,aTtl)
snDocCount := 0
aTtlValues := TtlInit(aHcl,aTtl)
cTit1 := ClnTit1(aHcl,aTtl)
cTit2 := ClnTit2(aHcl,aTtl)
p_SetWidth(len(cTit2))
SetPageHeader( {|| ;
  PrintHeader( ;
    cHeader1, ;
    cHeader2, ;
    cHeader3  ;
  ), ;
  PrintLine(cTit1) , ;
  PrintLine(cTit2)   ;
} )
BEGIN SEQUENCE
  if ! AreaOpen(adTables) ; BREAK ; endif
  ddSetOrder(nOrder)
  softseek cStart
  do while lOkay .and. ! eof() .and. &xlWhile
    if TaskInter() ; lOkay := .f. ; exit ; endif
    uSubKey  := &xuSubKey
    cSubText := &xcSubText
    snHclSubCount := 0
    aSubValues := TtlInit(aHcl,aTtl)
    * if !empty(cSubText)
    *   KeepBlockBegin()
    * endif
    do while lOkay .and. ! eof() ;
                   .and. &xlWhile ;
                   .and. &xuSubKey == uSubKey
      * snHclSubCount++ [971021]
      if &xlPrepare .or. Confirm(SetMsg(),MsgContinue())
        if &xlFilter
          snHclSubCount++
          if ! ClnEval(aHcl,aTtl,{ aTtlValues, aSubValues },NIL,&xlDetail)
            lOkay := .f.
          endif
        endif
      else
        lOkay := .f.
        exit
      endif
      skip
    enddo
    if snHclSubCount > 0
      snDocCount++
      if ! empty(cSubText)
        * KeepBlockEnd()
        ClnTotal(aHcl,aTtl,aSubValues,cSubText)
      endif
    endif
  enddo
  AreaClose()
END SEQUENCE
if lOkay .and. snDocCount > 0
  PrintLine(cTit2)
  PrintLine()
  ClnTotal(aHcl,aTtl,aTtlValues)
endif
close printer
RETURN lOkay


FUNCTION HclSubCount ; RETURN snHclSubCount
FUNCTION HclIsFirst  ; RETURN (snHclSubCount == 1)
FUNCTION HclDocCount ; RETURN snDocCount

FUNCTION ClnInit(aHcl,aTtl) // ,aTtlValues)
local i,j
for j := 1 to len(aTtl)
  // aadd(aTtlValues, {})
  if ! empty(aTtl[j][TTL_HEADER])
    aTtl[j][TTL_HEADER] := &(aTtl[j][TTL_HEADER])
  endif
  aTtl[j][TTL_WHEN]   := &(aTtl[j][TTL_WHEN])
next j
for i := 1 to len(aHcl)
  aHcl[i][HCL_WIDTH]    := &(aHcl[i][HCL_WIDTH])
  if empty(aHcl[i][HCL_XCSUM])
    aHcl[i][HCL_XCSUM]  := "ntomf(nSum)"
  endif
  // aHcl[i][HCL_WHEN]  := &(aHcl[i][HCL_WHEN])
  * for j := 1 to len(aTtl)
  *   aadd(aTtlValues[j], 0)
  * next j
next i
slMustUnderline := .f.
RETURN NIL



FUNCTION TtlInit(aHcl,aTtl)
local i,j
local aValues := {}
IsSame() // suHclIsSame := NIL
for j := 1 to len(aTtl)
  aadd(aValues, {})
  for i := 1 to len(aHcl)
    aadd(aValues[j], 0)
  next i
next j
RETURN aValues



FUNCTION ClnTit1(aHcl,aTtl)
local c := ""
local i
for i := 1 to len(aHcl)
  if empty(aHcl[i][HCL_VALUE])
    c += padr(aHcl[i][HCL_HEADER],aHcl[i][HCL_WIDTH])
  else
    c += padl(aHcl[i][HCL_HEADER],aHcl[i][HCL_WIDTH])
  endif
  if i < len(aHcl) ; c += " " ; endif
next i
RETURN c


FUNCTION ClnTit2(aHcl,aTtl)
local c := ""
local i
for i := 1 to len(aHcl)
  c += repl("ƒ",aHcl[i][HCL_WIDTH])
  if i < len(aHcl) ; c += " " ; endif
next i
RETURN c


FUNCTION ClnTit3(aHcl,aTtl)
local c := ""
local i
for i := 1 to len(aHcl)
  if empty(aHcl[i][HCL_VALUE])
    c += space(aHcl[i][HCL_WIDTH])
  else
    c += repl("ƒ",aHcl[i][HCL_WIDTH])
  endif
  if i < len(aHcl) ; c += " " ; endif
next i
RETURN c

**
** ClnEval() - executed on each line to collect values & print detail
**
FUNCTION ClnEval(aHcl,aTtl,aaTtlValues,cLine,lDetail,bWarn)
local i,j,k
local nValue
local lFound := .f.
default cLine to ""
default bWarn to {|| MsgIdJnlDoc() + " : " + FIELD->IdGen }
for i := 1 to len(aHcl)
  if i > 1
    cLine += " "
  endif
  if &(aHcl[i][HCL_WHEN])
    cLine += padr(&(aHcl[i][HCL_TEXT]),aHcl[i][HCL_WIDTH])
    if ! empty(aHcl[i][HCL_VALUE])
      lFound := .t.
      nValue := &(aHcl[i][HCL_VALUE])
      for j := 1 to len(aTtl)
        if &(aTtl[j][TTL_WHEN])
          for k := 1 to len(aaTtlValues)
            aaTtlValues[k][j][i] += nValue
          next k
        endif
      next j
    endif
  else
    cLine += space(aHcl[i][HCL_WIDTH])
  endif
next i
if ! lFound
  if bWarn != NIL
    RETURN .f. if ! Confirm( ;
      eval(bWarn) + " konnte keiner Kolonne zugewiesen werden !", ;
      MsgContinue() ;
    )
  endif
endif
if lDetail
  PrintLine(cLine)
  slMustUnderline := .t.
endif
RETURN .t.


**
** ClnTotal()
**
FUNCTION ClnTotal(aHcl,aTtl,aTtlValues,cHdrTotal)
local nPadWidth   := 0
local nPadColumns := 1
local i,j
local cLine
local aTotal := {}
local nLines := 0
default cHdrTotal to MsgTotal()
for i := 1 to len(aHcl)
  aadd(aTotal, 0)
next i
**
** Der Platz unter der ersten Gruppe von Kolonnen, die *keine* Summe
** haben, ist fÅr den (Zwischen-)Summentext verfÅgbar :
**
for i := 1 to len(aHcl)
  if empty(aHcl[i][HCL_VALUE])
    nPadColumns++
    nPadWidth += aHcl[i][HCL_WIDTH] + 1
  else
    exit
  endif
next i
for j := 1 to len(aTtl)
  cLine := padr(aTtl[j][TTL_HEADER],nPadWidth)
  for i := nPadColumns to len(aHcl)
    if i > nPadColumns
      cLine += " "
    endif
    if empty(aHcl[i][HCL_VALUE])
      cLine += space(aHcl[i][HCL_WIDTH])
    else
      cLine += &(strtran(aHcl[i][HCL_XCSUM],"nSum",ntrim(aTtlValues[j][i])))
      aTotal[i] += aTtlValues[j][i]
    endif
  next i
  if ! empty(aTtl[j][TTL_HEADER])
    if nLines == 0
    * if slMustUnderline // nLines == 0
      PrintLine(ClnTit3(aHcl,aTtl))
    endif
    PrintLine(cLine)
    nLines++
  endif
next j
if nLines == 0 .or. nLines > 1
  * if nLines > 1
    PrintLine(ClnTit3(aHcl,aTtl))
  * endif
  cLine := padr(cHdrTotal,nPadWidth)
  for i := nPadColumns to len(aHcl)
    if i > nPadColumns
      cLine += " "
    endif
    if empty(aHcl[i][HCL_VALUE])
      cLine += space(aHcl[i][HCL_WIDTH])
    else
      cLine += &(strtran(aHcl[i][HCL_XCSUM],"nSum",ntrim(aTotal[i])))
    endif
  next i
  PrintLine(cLine)
endif
RETURN NIL

**
**
**
*FUNCTION ClnSubTotal(aHcl,aTtl,aTtlValues,cLine)
*local i,j
*local aTotal := {}
*for i := 1 to len(aHcl)
*  aadd(aTotal, 0)
*next i
*for j := 1 to len(aTtl)
*  for i := 1 to len(aHcl)
*    if ! empty(aHcl[i][HCL_VALUE])
*      aTotal[i] += aTtlValues[j][i]
*    endif
*  next i
*next j
** if len(aTtl) > 1
*  * cLine := padr(cLine,nPad)
*  for i := 1 to len(aHcl)
*    if empty(aHcl[i][HCL_VALUE])
*      cLine += " " + space(aHcl[i][HCL_WIDTH])
*    else
*      cLine += " " + &(strtran(aHcl[i][HCL_XCSUM],"nSum",ntrim(aTotal[i])))
*    endif
*  next i
*  PrintLine(cLine)
** endif
*RETURN NIL

**
**
**
FUNCTION HstIsLast()
local cIdJnl := HST->IdJnl
local cIdDoc := HST->IdDoc
local nRecNo := recno()
local lIsLast := .t.
skip
if HST->IdDoc == cIdDoc .and. HST->IdJnl == cIdJnl .and. ! eof()
  lIsLast := .f.
endif
goto nRecNo
RETURN lIsLast


#endif DEF_HST

#ifdef DEF_BIL

**
** BilReport()
**
FUNCTION BilReport(cTplIni,cTitle,cIdHcl,cStart,xlWhile)
local xlFilter
local ctr
static cNoMvt     := BUTTON_ON
static cLettre    := BUTTON_OFF
static cIdJnl := NIL
default cIdHcl to "BIL"
default cTplIni to cIdHcl
default cTitle to "Bilanz"
open window (cTitle) size 9,60 help (cIdHcl)
SayGetPeriode()
GetPreview() ; WinCr()
SetTplIni(cTplIni)
GetTplIni()
GetRange()
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
xlFilter := "len(trim(GEN->IdGen))==LenIdGen()"
DbfReport( ;
  cTitle, ;
  PerText(),;
  NIL,;
  cIdHcl, ;
  { oGen(), oBil() }, ;
  ORD_GEN_BIL, ;
  cStart, ;
  xlWhile, ;
  xlFilter, ;
  "GEN->IdBil", ;
  "MsgTotal()+' '+GEN->IdBil+' '+trim(BilName(GEN->IdBil))", ;
  "BilExist(GEN->IdBil)", ;
  ".t." ;
)
RETURN NIL

FUNCTION BilGenSum
static nRecNo
static snSum
if nRecNo != NIL
  if recno() == nRecNo
    RETURN snSum
  endif
endif
nRecNo := recno()
snSum := GenCtgSum(GEN->IdGen,"ChkPeriode(CTG->Periode)==0",if(BIL->DC==DC_DEBIT,"val(Debit)","val(Credit)"))
RETURN snSum

FUNCTION BilSolde(cPerRange)
local nMont := 0
RETURN 0 if empty(BIL->DC)
GsbPeriode(cPerRange)
open area oGen()
  ddSetOrder(ORD_GEN_BIL)
  softseek BIL->IdBil
  do while ! eof() .and. GEN->IdBil == BIL->IdBil
    nMont += GenCtgMont("S"+BIL->DC,GEN->IdGen)
    skip
  enddo
close area
RETURN nMont

FUNCTION SayPeriode(cPeriode)
local nYear  := val(left(cPeriode,LEN_YEAR))
if nYear == 0
  ** Y2K : "A005" = Mai 2000, "A105" = Mai 2001
  nYear := 2000 + val(substr(cPeriode,2,1))
  nYear += (asc(left(cPeriode,1))-65) * 10
else
  nYear += 1900
endif
RETURN str(nYear,4) if right(cPeriode,1) == CHR_255
RETURN str(nYear,4) + "." + right(cPeriode,LEN_PERIODE-LEN_YEAR)

#endif DEF_BIL

#ifdef DEF_HST

*#ifdef DEF_ART
*
***
*** HclVnlArt()
***
*FUNCTION HclVnlArt(cTplIni,cTitle,cIdHcl,xlArtFilter,xlVnlFilter)
*local nCount := 0
*local bWarn := {|| MsgIdJnlDoc() + "." + VNL->Line }
*local nVnlCount
*local cLine
*local cTit1 := ""
*local cTit2 := ""
*local lOkay := .f.
*local aHcl := ReadArray(cIdHcl+".HCL",HCL_ALEN)
*local aTtl := ReadArray(cIdHcl+".TTL",TTL_ALEN)
*local aTtlValues := {}
*local aArtValues := {}
*default sdVnlDate1 to UserDate()
*default sdVnlDate2 to UserDate()
*default cTplIni to "LISTEX"
*open window (cTitle) size 5,50 help VNLLISTE
*say "Dokumente vom "
*get sdVnlDate1
*say " bis zum "
*get sdVnlDate2
*WinCr()
*GetPreview()
*WinCr()
*SetTplIni(cTplIni)
*GetTplIni()
*nKey := ReadScr()
*close window
*RETURN NIL if nKey == K_ESC
*open printer SetTplIni() ;
*     preview SetPreview()
*ClnInit(aHcl,aTtl)
*aTtlValues := TtlInit(aHcl,aTtl)
*cTit1 := ClnTit1(aHcl,aTtl,aTtlValues)
*cTit2 := ClnTit2(aHcl,aTtl,aTtlValues)
*p_SetWidth(len(cTit2))
*SetPageHeader( {|| ;
*  PrintHeader( ;
*    cTitle, ;
*    dtocf(sdVnlDate1)+if(sdVnlDate1==sdVnlDate2,""," - "+dtocf(sdVnlDate2)) ;
*  ), ;
*  PrintLine(cTit1) , ;
*  PrintLine(cTit2)   ;
*} )
*open area oArt(), oVnl(), oVen()
*  ddSetOrder ORD_VNL_ART in VNL
*  lOkay := .t.
*  go top
*  do while lOkay .and. ! eof()
*    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    if &xlArtFilter
*      aArtValues := TtlInit(aHcl,aTtl)
*      nVnlCount := 0
*      select VNL
*      softseek ART->IdArt
*      do while lOkay .and. ! eof() ;
*                     .and. VNL->IdArt == ART->IdArt
*        if TaskInter() ; lOkay := .f. ; exit ; endif
*        seek VNL->IdJnl+VNL->IdDoc in VEN
*        if empty(sdVnlDate1) .or. VEN->Date >= sdVnlDate1
*          if empty(sdVnlDate2) .or. VEN->Date <= sdVnlDate2
*            if &xlVnlFilter
*              nVnlCount++
*              if ! ClnEval(aHcl,aTtl,{ aTtlValues, aArtValues },NIL,.f.,bWarn)
*                lOkay := .f.
*              endif
*            endif
*          endif
*        endif
*        skip
*      enddo
*      select ART
*      if nVnlCount > 0
*        * ClnSubTotal(aHcl,aTtl,aArtValues,ART->IdArt +" " + ArtName())
*        ClnTotal(aHcl,aTtl,aArtValues,ART->IdArt +" " + ArtName())
*      endif
*    endif
*    skip
*  enddo
*close area
*if lOkay
*  PrintLine()
*  ClnTotal(aHcl,aTtl,aTtlValues) // ,NIL) // nPad)
*endif
*close printer
*RETURN MnuDone()
*
*#endif DEF_ART

#endif DEF_HST

#ifdef DEF_JNL

FUNCTION DocExist(cIdJnl,cIdDoc)
local jnl := JnlLocate(cIdJnl)
local lOkay := .f.
RETURN .f. if jnl == NIL
#ifdef DEF_FIN
  if jnl[JNL_ALIAS] == JNLALIAS_FIN
    seek cIdJnl + cIdDoc in FIN
    if ! eof() in FIN
      lOkay := .t.
    endif
  endif
#endif DEF_FIN
#ifdef DEF_VEN
  if jnl[JNL_ALIAS] == JNLALIAS_VEN
    seek cIdJnl + cIdDoc in VEN
    if ! eof() in VEN
      lOkay := .t.
    endif
  endif
#endif DEF_VEN
#ifdef DEF_IMP
  if jnl[JNL_ALIAS] == JNLALIAS_IMP
    seek cIdJnl + cIdDoc in IMP
    if ! eof() in IMP
      lOkay := .t.
    endif
  endif
#endif DEF_IMP
#ifdef DEF_ANA
  if jnl[JNL_ALIAS] == JNLALIAS_ODA
    seek cIdJnl + cIdDoc in ODA
    if ! eof() in ODA
      lOkay := .t.
    endif
  endif
#endif DEF_ANA
RETURN .t. if lOkay
#ifdef LG_GERMAN
SetMsg(cIdJnl + " " + cIdDoc + " : unbekanntes Dokument !")
#endif
#ifdef LG_FRENCH
SetMsg(cIdJnl + " " + cIdDoc + " : ce document n'existe pas !")
#endif
#ifdef LG_EN
SetMsg(cIdJnl + " " + cIdDoc + " : no such document !")
#endif
RETURN .f.

#endif DEF_JNL

FUNCTION DbfExist(cAlias,cKey,cMsg)
local lOkay
seek (cKey) in (cAlias)
lOkay := (! eof() in (cAlias))
RETURN .t. if lOkay
RETURN .f. if cMsg == NIL
SetMsg(cMsg)
RETURN .f.



