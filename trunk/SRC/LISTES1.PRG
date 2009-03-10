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
  #define MSG001  " uniquement les mouvements non lettr‚s"
  #define MSG002  " r‚organiser statistique achat/vente"
  #define MSG003  " aussi les comptes non mouvement‚s"
  #define MSG005  "Feuilles de calcul"
  static MSG006 := "Balance comptes particuliers"
  * #define MSG007  "Soldes comptes g‚n‚raux"
  * #define MSG008  "Journal centralisateur"
  #define MSG009  "Regrouper les documents de montant inf‚rieur … "
  #define MSG010  "Montants < "
  #define MSG011  "Analyse des achats..."
  #define MSG012  "Analyse des ventes..."
  * static MSG013 := "Listes mensuelles"
  * static MSG014 := "Listes annuelles"
  * #define MSG015  " : rupture de s‚quence !"
  #define MSG016  "                                                        "
  #define MSG017  "Compte                                                  "
  #define MSG018  "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   "
  * #define MSG019  "O pour continuer l'avertissement en cas de rupture :"
  #define MSG023  "ÄÄÄÄÄÄ PERIODE ÄÄÄÄÄÄ"
  #define MSG024  "     D‚bit     Cr‚dit"
  #define MSG025  "ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ"
  #define MSG026  "Liste des clients importants"
  #define MSG027  "Statistique"
  #define MSG028  "Journal "
  #define MSG029  "Liste de contr“le inventaire"
  #define MSG030  "   ÄÄÄÄ SOLDE FINAL ÄÄÄÄ"
  #define MSG031  "     D‚biteur  Cr‚diteur"
  #define MSG032  "   ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ"
  #define MSG033  "SIGNALETIQUES"
  #define MSG034  "Recherche clients semblables"
  #define MSG035  "GESTION DU STOCK"
  #define MSG036  "Statistique prestations"
  #define MSG037  "COMPTABILITE"
  #define MSG038  "Marge th‚orique"
  #define MSG039  "FACTURATION"
  * #define MSG040  "Rappels de paiement"
  #define MSG042  " … "
  #define MSG044  " sp‚cifier tous les comptes mouvement‚s"
  #define MSG045  "Jnl  NøDoc     Date D‚signation                                       prix net T        TVA  prix brut"
  #define MSG046  "ÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ Ä ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ"
  * #define MSG047  "Marge th‚orique"
  #define MSG048  "                                                         P.V.       P.A."
  #define MSG049  "Nødoc.    Date     Client Libell‚                        hors TVA   hors TVA        Marge"
  #define MSG050  "ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ"
  #define MSG051  "Impressions"
  #define MSG052  " contenu des documents"
  #define MSG053  " imputations par document"
  static MSG054  := " d‚tail de chaque document"
  * #define MSG055  "           Ä ÄÄÄÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ Ä ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ"
  * #define MSG056  "Document      Date     (cours)"
  * #define MSG057  "ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ"
  * #define MSG061  "Liste de pointage"
  #define MSG064  "uniquement le client "
  #define MSG065  "uniquement le fournisseur "
  #define MSG066  " liste d‚taill‚e"
  #define MSG067  "R‚gimes T.V.A. "
  #define MSG068  " sur disquettes"
  #define MSG069  "Chiffre d'affaires minimum "
  #define MSG070  "Tri‚ par (Chiffre/Firme) "
  #define MSG071  " avec les montants "
  #define MSG072  "Pr‚paration en cours..."
  #define MSG073  "Montant minimum "
  #define MSG074  "Statistique achat/vente"
  #define MSG075 "Ventilation par groupe d'articles :"
  #define MSG076 "Inventaire du "
  static MSG_WRN035 := " : colonne de facturier invalide "
#endif

#ifdef LG_GERMAN
  #define MSG001  " nur offene Bewegungen drucken"
  #define MSG003  " auch unbewegte Konten drucken"
  static MSG006 := "Saldenliste Partnerkonten"
  #define MSG028  "Journal "
  #define MSG029  "Prfliste Inventur"
  #define MSG042  " bis "
  static MSG054 := " Dokumente einzeln anfhren"
  * #define MSG061  "Stechliste"
  #define MSG075 "Zwischensummen pro Gruppe :"
  #define MSG076 "Inventur vom "
  static MSG_WRN035 := " : ungltige Rechnungsbuchkolonne "
#endif

#ifdef LG_EN
  #define MSG001  " nur offene Bewegungen drucken"
  #define MSG003  " auch unbewegte Konten drucken"
  static MSG006 := "Saldenliste Partnerkonten"
  #define MSG028  "Journal "
  #define MSG029  "Prfliste Inventur"
  #define MSG042  " bis "
  static MSG054 := " Dokumente einzeln anfhren"
  * #define MSG061  "Stechliste"
  #define MSG075 "Zwischensummen pro Gruppe :"
  #define MSG076 "Inventur vom "
  static MSG_WRN035 := " : ungltige Rechnungsbuchkolonne "
#endif

static sdVon := NIL
static sdBis := NIL

static snHclSubCount
static snDocCount
static slMustUnderline := .f.


#ifdef DEF_JNL

static scIdDoc := NIL  // pour test Rupture de s‚quence
static scIdJnl := NIL  // pour test Rupture de s‚quence
static scPeriode := NIL  // pour test Rupture de s‚quence
* static slRupture := .f.
static slIsLegal := .t.

#endif DEF_JNL

#ifdef DEF_VEN

static sdVnlDate1
static sdVnlDate2

static snTotBase := 0
static snTotTaxe := 0
static snSeq := 0

#endif DEF_VEN



#ifdef DEF_JNL

**
** PerText()
**
FUNCTION PerText(bCondit,cIdLng)
local cText
default cIdLng to UsrLang()
RETURN MSG058(cIdLng) if empty(MemPer1 + MemPer2)
cText := MSG059(cIdLng) + MemPer1
if MemPer2 != MemPer1
  cText += "-" + MemPer2
endif
if slIsLegal .and. JnlIsOpen(bCondit)
  cText += MSG060(cIdLng)
endif
RETURN cText

FUNCTION SetIsLegal(x)
RETURN slIsLegal if x == NIL
slIsLegal := x
RETURN .t.

FUNCTION JnlIsOpen(bCondit)
local lOpen := .F.
default bCondit to {|| JNLATTR_G $ JNL->Attrib }
open area oJnl()
  go top
  do while ! eof()
    if empty(JNL->Periode) .or. JNL->Periode < MemPer2
      if eval(bCondit)
        lOpen := .t.
      endif
    endif
    skip
  enddo
close area
RETURN lOpen

FUNCTION WrnJnlOpen(bJnlTest)
RETURN .t. if ! JnlIsOpen(bJnlTest)
RETURN Confirm( ;
  MsgJnlOpen() + MemPer2 + " !", ;
  MsgSure(), MSG_YES, "WRN027" ;
)

FUNCTION MsgJnlOpen()
#ifdef LG_GERMAN
  RETURN "Nicht alle Journale sind abgeschlossen bis "
#endif
#ifdef LG_FRENCH
  RETURN "Il y a des journaux non cl“tur‚s en p‚riode "
#endif
#ifdef LG_EN
  RETURN "Some journals aren't closed in period "
#endif


#endif DEF_JNL

#ifdef DEF_VEN

**
**  1 - Liste des clients importants
**
*FUNCTION BI_01
*static nMontMin := 10000
*static cTri     := "C"
*static cAvec    := BUTTON_ON
*local nMont
*local cTit1 := padr(MsgIdCli(),LenCompte()) + " "
*local cTit2 := repl("Ä",LenCompte()) + " "
*cTit1 += padr(MsgName(),40) + " "
*cTit2 += repl("Ä",40) + " "
*cTit1 += padl(MsgMontant(),10) + " "
*cTit2 += repl("Ä",10) + " "
*cTit1 += padl(MsgDate(),len(dtoc(UserDate())))
*cTit2 += repl("Ä",len(dtoc(UserDate())))
*open window (MSG026) size 6,42 help LCLICA
*SayGetPeriode()
*say MSG069
*@ row(), col() get nMontMin picture "##########"
*WinCR()
*say MSG070
*@ row(), col() get cTri picture "!" valid cTri $ "CF"
*WinCR()
*@ row(), col() get cAvec checkbox
*say MSG071
*ReadScr()
*close window
*RETURN NIL if nKey == K_ESC
*MsgDisplay(MSG072)
*open area oVen(), oCli()
*ddSetOrder 2 in VEN
*select 0
*dbcreate( ".\TMP", { ;
*  { "iCli" , "C",  LenCompte(), 0 } ,;
*  { "Firme", "C", 20, 0 } ,;
*  { "Mont" , "N", 10, 0 } ,;
*  { "Date" , "D",  8, 0 }  ;
*} )
*use .\TMP alias TMP
*if cTri == "C"
*  index on ( - TMP->Mont) to .\TMP
*else
*  index on upper(TMP->Firme) to .\TMP
*endif
*select CLI
*go top
*do while !eof()
*  select TMP
*  append blank
*  TMP->iCli  := CLI->iCli
*  TMP->Firme := CLI->Firme
*  select VEN
*  seek CLI->iCli
*  do while !eof() .and. VEN->IdPar == CLI->iCli
*    if VenIsFacture() .and. VEN->Etat == DocStatClosed()
*      if ChkPeriode(VEN->Periode) == 0
*        if VenIsNegative()
*          TMP->Mont -= VEN_MontD
*        else
*          TMP->Mont += VEN_MontD
*        endif
*        if empty(TMP->Date) .or. TMP->Date < VEN->Date
*          TMP->Date := VEN->Date
*        endif
*      endif
*    endif
*    skip
*  enddo
*  select CLI
*  skip
*enddo
*open printer LISTE width len(cTit2)
*SetPageHeader := {|| ;
*  PrintHeader(MSG026,PerText()), ;
*  PrintLine(cTit1) , ;
*  PrintLine(cTit2) ;
*}
*select TMP
*go top
*do while !eof() .and. LstContinue() //
*  if TMP->Mont >= nMontMin .and. TMP->Mont > 0
*    PrintLine( ;
*      TMP->iCli  + " " + ;
*      padr(CliFirme(TMP->iCli),40) + " " + ;
*      if( cAvec == BUTTON_ON , ;
*        ntomf(TMP->Mont), ;
*        space(10) ;
*      ) + " " + ;
*      dtoc( TMP->Date ) ;
*    )
*  endif
*  skip
*enddo
*use
*close printer
*ferase(".\TMP.DBF")
*ferase(".\TMP.NTX")
*close area
*RETURN NIL

#endif DEF_VEN

#ifdef DEF_ART

**
**  12 - Liste de contr“le inventaire
**
FUNCTION BI_12
local cLine
local lPrint
local cTit1 := space(LenIdArt() + 1)
local cTit2 := padr("Art.",LenIdArt() + 1)
local cTit3 := repl("Ä",LenIdArt()) + " "
local cIdGra := NIL
local aIvt := {}
local i
static dDate1 := NIL
static dDate2 := NIL
default dDate1 to ctod("")
default dDate2 to ctod("")
SetTplIni("LISTE")
open window (MSG029) size 7,60 help ARTLSTI
say "alte Inventur-Eintr„ge vom "
get dDate1
say " bis zum "
get dDate2
WinCr()
GetPreview() ; WinCr()
GetTplIni()
GetRange()
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
cTit1 += space(40)
cTit1 += " " + space(LenMont())
* cTit1 += " " + space(LenMont())
cTit2 += padr("Bezeichnung",40)
cTit2 += " " + padl("VK netto",LenMont())
* cTit2 += " " + padl("Letzter EK",LenMont())
cTit3 += repl("Ä",40)
cTit3 += " " + repl("Ä",LenMont())
* cTit3 += " " + repl("Ä",LenMont())
#ifdef DEF_IVT
  open area oIvt()
    go top
    do while ! eof()
      if empty(dDate1) .or. IVT->Date >= dDate1
        if empty(dDate2) .or. IVT->Date <= dDate2
          cTit1 += " " + padl(left(dtoc(IVT->Date),6),LenQte())
          cTit2 += " " + padl(ntrim(year(IVT->Date)),LenQte())
          cTit3 += " " + repl("Ä",LenQte())
          aadd(aIvt,IVT->Date)
        endif
      endif
      skip
    enddo
  close area
#endif DEF_IVT
cTit1 += " " + padl("Menge",LenQte())
cTit1 += "  ³  Menge"
cTit2 += " " + padl("akt.",LenQte())
cTit2 += "  ³  gez„hlt"
cTit3 += " " + repl("Ä",LenQte())
cTit3 += "  ³  ÄÄÄÄÄÄÄÄÄÄ"
open printer SetTplIni() width len(cTit3) ;
     preview SetPreview() ;
     range   SetRange() ;
     titblock {|| ;
       PrintHeader( MSG029 ), ;
       PrintLine(cTit1), ;
       PrintLine(cTit2), ;
       PrintLine(cTit3)  ;
     }
open area oArt(), oGra()
go top
do while ! eof() .and. LstContinue() //
  if TaskInter() ; exit ; endif
  if ! ARTATTR_S $ ART->Attrib
    #ifdef DEF_GRA
      if TIMATTR_G $ MemAttrib
        if cIdGra != ART->iGra
          if cIdGra == NIL
            p_eject()
          endif
          KeepTogether(4)
          seek ART->iGra in GRA
          cLine := tagged("B") + padr(ART->iGra,LenIdArt())
          cLine += " " + trim(GRA->Name1) + tagged("b")
          PrintLine()
          PrintLine(cLine)
          cIdGra := ART->iGra
        endif
      endif
    #endif DEF_GRA
    PrintLine()
    cLine := ""
    cLine += ArtIdArtF() + " "
    cLine += padr(ArtName(),40)
    cLine += " " + komma(ART->Prix1)
    #ifdef DEF_IVT
      for i := 1 to len(aIvt)
        cLine += " " + ArtIvlValue(ART->IdArt,aIvt[i],{||IVL->Qte})
      next i
    #endif DEF_IVT
    * cLine += komma(ART->PAMP) + " "
    * cLine += komma(ART->DPA) + " "
    cLine += " " + space(LenQte())  + "  ³  .........."
    KeepTogether(2)
    PrintLine( cLine )
    * space(73+LenIdArt()) + "³  ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" )
  endif
  skip
enddo
close area
close printer
RETURN NIL


#endif DEF_ART


#ifdef DEF_IVT


FUNCTION ArtIvlValue(cIdArt,dDate,bValue)
local uReturn := NIL
open area oIvl()
  ddSetOrder(ORD_IVL_ART)
  seek ART->IdArt + dtos(dDate)
  uReturn := eval(bValue)
close area
RETURN uReturn


**
** Inventaire
**
FUNCTION IvtPrint()
local cLine
local i
local nMont := 0
* local nDPA  := 0
local cTit1 := padr(MsgIdArt(MemLang1),LenIdArt() + 1)
local cTit2 := repl("Ä",LenIdArt()) + " "
local aGrp := {}
local cIdGra := NIL
static scTotGrp := BUTTON_ON
cTit1 += padr(MsgDesig(MemLang1),40) + " "
cTit2 += repl("Ä",40)               + " "
cTit1 += padr(MsgMenge(MemLang1),LenQte()) + " "
cTit2 += repl("Ä",LenQte())             + " "
cTit1 += padl(MsgPU(MemLang1),10)       + " "
cTit2 += repl("Ä",10)                   + " "
cTit1 += padl("Total",10)
cTit2 += repl("Ä",10)
open printer "LISTE" width len(cTit2) ;
TitBlock {|| ;
  PrintHeader( MSG076 + dtoc(IVT->Date)), ;
  PrintLine(cTit1), ;
  PrintLine(cTit2) ;
}
open area oIvl(), oArt(), oGra()
  softseek dtos(IVT->Date)
  do while !eof() .and. IVL->Date == IVT->Date .and. LstContinue()
    if TaskInter() ; exit ; endif
    seek IVL->IdArt in ART
    if p_LinesLeft() < 2
      PrintLine()
      PrintLine( padr(MsgRep1(MemLang1),60+LenIdArt()) + ntom(nMont))
      p_Eject()
      PrintLine( padr(MsgRep2(MemLang1),60+LenIdArt()) + ntom(nMont))
      PrintLine()
    endif
    #ifdef DEF_GRA
      if TIMATTR_G $ MemAttrib
        if cIdGra != ART->iGra
          KeepTogether(4)
          seek ART->iGra in GRA
          cLine := padr(ART->iGra,LenIdArt())
          cLine += " " + GRA->Name1
          PrintLine()
          PrintLine(cLine)
          cIdGra := ART->iGra
        endif
      endif
    #endif DEF_GRA
    cLine := IVL->IdArt + " "
    cLine += padr(ArtName(),40) + " "
    cLine += komma(IVL->Qte) + " "
    if TIMATTR_D $ MemAttrib
      cLine += komma(IVL->DPA) + " "
      cLine += komma(ntom(val(IVL->DPA) * val(IVL->Qte)))
      nMont += val(IVL->DPA) * qton(IVL->Qte)
      IvtAddGrp( ;
        aGrp, ;
        ART->iGra, ;
        val(IVL->DPA)*qton(IVL->Qte) ;
      )
    else
      cLine += komma(IVL->PAMP) + " "
      cLine += ntom(val(IVL->PAMP) * val(IVL->Qte))
      nMont += val(IVL->PAMP) * qton(IVL->Qte)
      IvtAddGrp( ;
        aGrp, ;
        ART->iGra, ;
        val(IVL->PAMP)*qton(IVL->Qte) ;
      )
    endif
    PrintLine(cLine)
    * nPamp += val(IVL->PAMP) * qton(IVL->Qte)
    * nDPA  += val(IVL->DPA)  * qton(IVL->Qte)
    skip
  enddo
close area
PrintLine( space(60+LenIdArt()) + repl("Ä",LenMntF()))
PrintLine( padr(upper(MsgTotal()),60+LenIdArt()) + ntomf(nMont))
#ifdef DEF_GRA
  if scTotGrp == BUTTON_ON
    p_Eject()
    * KeepTogether( len(aGrp) + 3 )
    open area oGra()
      PrintLine()
      PrintLine(MSG075)
      PrintLine()
      for i := 1 to len(aGrp)
        seek aGrp[i][1] in GRA
        cLine := padr(aGrp[i][1],LenIdArt())
        cLine += " " + padr(GRA->Name1,40)
        cLine += " " + str(100 * aGrp[i][2]/nMont,5,1) + "%"
        cLine += " " + ntomf(aGrp[i][2])
        PrintLine(cLine)
      next i
    close area
  endif
#endif DEF_GRA
close printer
RETURN NIL

FUNCTION IvtAddGrp(aGrp,cIdGra,nMont)
local i
for i := 1 to len(aGrp)
  if aGrp[i][1] == cIdGra
    aGrp[i][2] += nMont
    RETURN NIL
  endif
next i
aadd(aGrp, { cIdGra, nMont } )
RETURN NIL

FUNCTION ArtIvtListe
local cIdGra := NIL
local cLine
local i
local aIvl := {}
local cTit1 := ""
local cTit2 := ""
local nCount := 0
open area oIvt()
  go top
  do while ! eof()
    aadd(aIvl,IVT->Date)
    skip
  enddo
close area
if len(aIvl) == 0
  Warning("Keine Inventuren vorhanden !")
  RETURN MnuDone()
endif
cTit1 += padr(MsgIdArt(UsrLang()),LenIdArt())
cTit2 += repl("Ä",LenIdArt())
cTit1 += " " + padr(MsgDesig(UsrLang()),30)
cTit2 += " " + repl("Ä",30)
for i := 1 to len(aIvl)
  cTit1 += " " + padl(dtoc(aIvl[i]),len(dtoc(UserDate())))
  cTit2 += " " + repl("Ä",len(dtoc(UserDate())))
next i
open printer "LIST-X" width len(cTit2) ;
             titblock {|| ;
               PrintHeader( "šbersicht Inventuren" ), ;
               PrintLine(cTit1), ;
               PrintLine(cTit2) ;
             }
open area oIvl()
  select ART
  go top
  do while ! eof() .and. LstContinue()
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    #ifdef DEF_GRA
      seek ART->iGra in GRA
      if cIdGra != ART->iGra
        KeepTogether(10)
        if cIdGra != NIL
          PrintLine()
        endif
        PrintLine(ART->iGra + " " + GRA->Name1)
        PrintLine()
        cIdGra := ART->iGra
      endif
    #endif DEF_GRA
    cLine := ART->IdArt
    cLine += " " + padr(ArtName(),30)
    for i := 1 to len(aIvl)
      seek dtos(aIvl[i]) + ART->IdArt in IVL
      if eof()
        cLine += " " + repl("_",8)
      else
        cLine += " " + padl(IVL->Qte,8)
      endif
    next i
    PrintLine(cLine)
    * PrintLine(space(LenIdArt() + 1) + ART->Remarq)
    skip
  enddo
  select IVL
close area
close printer
RETURN NIL

#endif DEF_IVT

#define BAL_IDCTR 1
#define BAL_INID  2
#define BAL_INIC  3
#define BAL_MVTD  4
#define BAL_MVTC  5



#ifdef DEF_HST

#define PT_IDGEN  1
#define PT_DEBIT  2
#define PT_CREDIT 3
#define PT_ALEN   3

**
** JnlCentral() - Journal centralisateur
**
FUNCTION JnlCentral(cTplIni,nLen,nWidth,cDetail)
local i
local j
local cLine
local nTotal
local cTit2
local cTit3
local lOkay := .f.
local nCount := 0
local aPer := {}
local aPtJnl
local aPtGen := {}
local aPtTtl := {}
local aPtTotal := {}
local cIdJnl
default nWidth to 40
default nLen to 2
default cDetail to BUTTON_OFF
default cTplIni to "LISTE"
open window (MsgJnlCentral(UsrLang())) size 9,60 help JNLCTRL
  SayGetPeriode()
  GetPreview() ; WinCr()
  SetTplIni(cTplIni)
  GetTplIni()
  GetRange()
  say "Titelkonten bis Ebene "
  get nLen picture "##"
  WinCr()
  say "Breite Bezeichnung "
  get nWidth picture "##"
  WinCr()
  get cDetail checkbox
  say " jede Periode einzeln"
  nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
RETURN .f. if ! WrnJnlOpen()
AppSaveMem()
open area oPer()
  go top
  do while ! eof()
    if ChkPeriode(PER->Periode) == 0
      DictAddItem(aPer,PER->Periode)
    endif
    skip
  enddo
close area
open printer SetTplIni() ;
     preview SetPreview() ;
     range   SetRange() ;
     titblock {|| ;
       PrintHeader(MsgJnlCentral(MemLang1) ,PerText() ), ;
       PrintLine(cTit2) ,;
       PrintLine(cTit3)  ;
     }
cTit2 := padr("Journal",nWidth)
cTit3 := repl("Ä",nWidth)
if cDetail == BUTTON_ON
  for i := 1 to len(aPer)
    cTit2 += " " + padl(aPer[i],LenMntF()*2+1)
    cTit3 += " " + repl("Ä",LenMntF()*2+1)
  next i
endif
cTit2 += " " + padl(GsbPeriode(),LenMntF()*2+1)
cTit3 += " " + repl("Ä",LenMntF()*2+1)
p_SetWidth(len(cTit3))
open area oHst(), oGen()
  lOkay := .t.
  ddSetOrder(ORD_HST_DOC)
  go top
  do while ! eof() .and. lOkay
    cIdJnl := HST->IdJnl
    aPtJnl := {}
    do while ! eof() .and. lOkay .and. HST->IdJnl == cIdJnl
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
      if TaskInter() ; lOkay := .f. ; exit ; endif
      * if empty(HST->IdPar)
        if ChkPeriode(HST->Periode) == 0
          MvtPtCollect(aPtJnl,aPer,left(HST->IdGen,nLen))
          MvtPtCollect(aPtTtl,aPer,left(HST->IdGen,nLen))
          MvtPtCollect(aPtGen,aPer,HST->IdJnl)
          MvtPtCollect(aPtTotal,aPer,NIL)
        endif
      * endif
      skip
    enddo
    if lOkay
      if nLen > 0
        PrintLine(cIdJnl + " " + JnlName(cIdJnl))
        for i := 1 to len(aPtJnl)
          cLine := space(LenIdJnl())
          cLine += " " + aPtJnl[i][PT_IDGEN]
          cLine += " " + GenName(padr(aPtJnl[i][PT_IDGEN],LenIdGen()))
          cLine := padr(cLine,nWidth) + PtLine(aPtJnl[i],aPer,cDetail)
          PrintLine(cLine)
        next i
        if len(aPtGen) > 0
          if atail(aPtGen)[PT_IDGEN] == cIdJnl
            cLine := padr(space(LenIdJnl()) + " Summe " + cIdJnl, nWidth) // padr(cIdJnl + " " + JnlName(cIdJnl),nWidth)
            cLine += PtLine(atail(aPtGen),aPer,cDetail)
            PrintLine(tagged("B")+cLine+tagged("b"))
            if nLen > 0
              PrintLine()
            endif
          endif
        endif
      elseif len(aPtGen) > 0
        if atail(aPtGen)[PT_IDGEN] == cIdJnl
          cLine := padr(cIdJnl + " " + JnlName(cIdJnl), nWidth)
          cLine += PtLine(atail(aPtGen),aPer,cDetail)
          PrintLine(cLine)
        endif
      endif
    else
      exit
    endif
  enddo
  if lOkay .and. len(aPtTotal) == 1
    cLine := padr("TOTAL",nWidth)
    cLine += PtLine(aPtTotal[1],aPer,cDetail)
    PrintLine(cLine)
    if nLen > 0
      p_Eject()
      PrintLine("Globalsummen :")
      for i := 1 to len(aPtTtl)
        cLine := aPtTtl[i][PT_IDGEN]
        cLine += " " + GenName(padr(aPtTtl[i][PT_IDGEN],LenIdGen()))
        cLine := padr(cLine,nWidth) + PtLine(aPtTtl[i],aPer,cDetail)
        PrintLine(cLine)
      next i
      cLine := padr("TOTAL",nWidth)
      cLine += PtLine(aPtTotal[1],aPer,cDetail)
      PrintLine()
      PrintLine(cLine)
    endif
  endif
close area
close printer
RETURN .f.

FUNCTION MvtPtCollect(aPt,aPer,cIdGen)
local i
local pt := NIL
for i := 1 to len(aPt)
  if cIdGen == aPt[i][PT_IDGEN]
    pt := aPt[i]
    exit
  endif
next i
if pt == NIL
  pt := array(PT_ALEN)
  pt[PT_IDGEN] := cIdGen
  pt[PT_DEBIT]  := {}
  pt[PT_CREDIT] := {}
  for i := 1 to len(aPer)
    aadd(pt[PT_DEBIT], 0)
    aadd(pt[PT_CREDIT], 0)
  next i
  i := 1
  do while i <= len(aPt)
    if aPt[i][PT_IDGEN] > cIdGen
      aadd(aPt,NIL)
      ains(aPt,i)
      aPt[i] := pt
      exit
    else
      i++
    endif
  enddo
  if i > len(aPt)
    aadd(aPt,pt)
  endif
endif
for i := 1 to len(aPer)
  if HST->Periode == aPer[i]
    if HST->DC == DC_DEBIT
      pt[PT_DEBIT][i] += val(HST->Mont)
    else
      pt[PT_CREDIT][i] += val(HST->Mont)
    endif
    exit
  endif
next i
RETURN NIL

FUNCTION PtLine(pt,aPer,cDetail)
local cLine := ""
local j
local nDebit  := 0
local nCredit := 0
for j := 1 to len(aPer)
  if cDetail == BUTTON_ON
    cLine += " " + ntomf(pt[PT_DEBIT][j])
    cLine += " " + ntomf(pt[PT_CREDIT][j])
  endif
  nDebit  += pt[PT_DEBIT][j]
  nCredit += pt[PT_CREDIT][j]
next j
cLine += " " + ntomf(nDebit)
cLine += " " + ntomf(nCredit)
RETURN cLine


#define CLN_TYPE   1
#define CLN_HEADER 2
#define CLN_EXPR   3
#define CLN_ALEN   3

**
** BalGen() - Saldenliste ("Balance") Generalkonten
**
FUNCTION BalGen(cTplIni,cTitle,nLimit,cFilter,nLibWidth)
local aCln
local aDebit
local aCredit
local aSumDebit  := {}
local aSumCredit := {}
local nWidth
local cTit1 := padr(MsgCompte(MemLang1),LenIdGen() * 2 - 1)
local cTit2 := repl("Ä",LenIdGen()*2-1)
local nCount := 0
local cIdGen
local i
local cLine
static cIdCln := NIL
static cIdGen1 := NIL
static cIdGen2 := NIL
local nLen
default cIdGen1 to space(LenIdGen())
default cIdGen2 to space(LenIdGen())
default cIdCln to padr("STD",5)
default cTplIni to "BAL"
default nLimit to 3
default nLibWidth to 30
default cFilter to ".t."
open window (cTitle) size 9,50 help BALGEN
  SayGetPeriode()
  say "Konten von "
  get cIdGen1 picture PIC_ID pick PickGen(NIL,cIdGen1)
  say " bis "
  get cIdGen2 picture PIC_ID pick PickGen(NIL,cIdGen2)
  WinCr()
  say "Titelkonten bis Ebene "
  get nLimit picture "##"
  WinCr()
  say "Format "
  get cIdCln picture PIC_ID pick PickCln("GEN",cIdCln,"Format")
  WinCr()
  GetPreview() ; WinCr()
  SetTplIni(cTplIni)
  GetTplIni()
  GetRange()
  nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
RETURN .f. if ! WrnJnlOpen()
AppSaveMem()
aCln   := ReadArray("GEN" + cIdCln + ".dbc", CLN_ALEN)
for i := 1 to len(aCln)
  aadd(aSumDebit, 0)
  aadd(aSumCredit, 0)
next i
open printer SetTplIni() ;
     preview SetPreview() ;
     range   SetRange() ;
     TitBlock {|| ;
       PrintHeader(cTitle ,PerText()), ;
       PrintLine(cTit1) ,;
       PrintLine(cTit2)  ;
     }
cTit1 += " " + padr(MsgDescript(),nLibWidth)
cTit2 += " " + repl("Ä",nLibWidth)
for i := 1 to len(aCln)
  if aCln[i][CLN_TYPE] == "S1"
    nWidth := LenMntF() + 2
  elseif aCln[i][CLN_TYPE] == "S2"
    nWidth := 2 * LenMntF() + 1
  elseif aCln[i][CLN_TYPE] == "DC"
    nWidth := 2 * LenMntF() + 1
  else
    nWidth := LenMntF()
  endif
  cTit1 += " " + padr(aCln[i][CLN_HEADER],nWidth)
  cTit2 += " " + repl("Ä",nWidth)
next i
p_SetWidth(len(cTit2))
open area oGen()
  softseek trim(cIdGen1)
  do while ! eof() .and. LstContinue()
    if ! empty(cIdGen2)
      if GEN->IdGen > cIdGen2
        exit
      endif
    endif
    if TaskInter() ; exit ; endif
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    if &cFilter
      nLen   := len(trim(GEN->IdGen))
      if nLen == LenIdGen() .or. nLen <= nLimit
        cIdGen := GEN->IdGen
        open area oCtg()
          aDebit  := {}
          aCredit := {}
          for i := 1 to len(aCln)
            aadd(aDebit, 0)
            aadd(aCredit, 0)
          next i
          softseek cIdGen
          do while ! eof() .and. CTG->IdGen == cIdGen .and. LstContinue()
            if right(CTG->Periode,1) != CHR_255
              for i := 1 to len(aCln)
                if &(aCln[i][CLN_EXPR])
                  aDebit[i]  += val(CTG->Debit)
                  aCredit[i] += val(CTG->Credit)
                  if nLen == LenIdGen()
                    aSumDebit[i]  += val(CTG->Debit)
                    aSumCredit[i] += val(CTG->Credit)
                  endif
                endif
              next i
            endif
            skip
          enddo
          for i := 1 to len(aCln)
            if aDebit[i] != 0 .or. aCredit[i] != 0
              cLine := IdStruct(GEN->IdGen,1)
              cLine += " " + padr(GenName(),nLibWidth)
              cLine += ClnLine(aCln,aDebit,aCredit)
              if nLen == LenIdGen()
                PrintLine(cLine)
              else
                PrintLine()
                PrintLine(tagged("B")+cLine+tagged("b"))
              endif
              exit
            endif
          next i
        close area
      endif
    endif
    skip
  enddo
close area
PrintLine()
cLine := padr("TOTAL",LenIdGen()*2-1)
cLine += " " + space(nLibWidth)
cLine += ClnLine(aCln,aSumDebit,aSumCredit)
PrintLine(cLine)
close printer
RETURN .f.

FUNCTION ClnLine(aCln,aDebit,aCredit)
local cLine := ""
local i
for i := 1 to len(aCln)
  if aCln[i][CLN_TYPE] == "S1"
    cLine += " " + solde1(aDebit[i],aCredit[i])
  elseif aCln[i][CLN_TYPE] == "S2"
    cLine += " " + solde2(aDebit[i],aCredit[i])
  elseif aCln[i][CLN_TYPE] == "DC"
    cLine += " " + ntomf(aDebit[i])
    cLine += " " + ntomf(aCredit[i])
  elseif aCln[i][CLN_TYPE] == "SD"
    cLine += " " + ntomf(aDebit[i] - aCredit[i])
  elseif aCln[i][CLN_TYPE] == "SC"
    cLine += " " + ntomf(aCredit[i] - aDebit[i])
  endif
next i
RETURN cLine


**
** BalPar() - Saldenliste ("Balance") Partnerkonten
**
FUNCTION BalPar(cIdCtr,cTplIni,cTitle,nPadWidth)
local cTit1
local cTit2
local aParBal := {}
local aTotBal := {}
local nCount := 0
local ctr
local cIdDev
local nDecPos := SetDevise()
* local nDecPos := SetDecPos()
local cLine
local cIdPar
static scIdDev    :=  NIL
default cTplIni to "BAL"
default cTitle to MSG006
default nPadWidth to 40 - LEN_IDDEV - 1
if cIdCtr == NIL
  cIdCtr := PickCtr(NIL,cTitle)
  RETURN .f. if (ctr := CtrLocate(cIdCtr)) == NIL
  cTitle += " " + trim(ctr[CTR_NAME])
else
  RETURN .f. if (ctr := CtrLocate(cIdCtr)) == NIL
endif
default scIdDev  to DevDefault(PerActive())
open window (cTitle) size 7,60 help BALPAR
SayGetPeriode()
GetPreview() ; WinCr()
SetTplIni(cTplIni)
GetTplIni()
GetRange()
#ifdef LG_GERMAN
  say "W„hrung "
#else
  say "Devise "
#endif
@ row(), col() get scIdDev picture PIC_ID pick PickDev(scIdDev)
#ifdef LG_GERMAN
  say " (leer = Partnerw„hrungen)"
#else
  say " (vide = devises des partenaire) "
#endif
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
RETURN .f. if ! WrnJnlOpen()
AppSaveMem()
open printer SetTplIni() ;
     preview SetPreview() ;
     range   SetRange() ;
     TitBlock {|| ;
       PrintHeader(cTitle ,PerText()), ;
       PrintLine(cTit1) ,;
       PrintLine(cTit2)  ;
     }
cTit1 := padr("Partner",nPadWidth)
cTit2 := repl("Ä",nPadWidth)
cTit1 += " " + padr(MsgSoldeI(MemLang1),LenSolde())
cTit2 += " " + repl("Ä",LenSolde())
cTit1 += " " + padc("Periode",1 + LenMntF() * 2)
cTit2 += " " + repl("Ä",1 + LenMntF() * 2)
cTit1 += " " + padr(MsgSoldeF(MemLang1),LenSolde())
cTit2 += " " + repl("Ä",LenSolde())
p_SetWidth(len(cTit2))
open area oPar(), oPlz(), oNat()
  go top
  do while ! eof() .and. LstContinue()
    if TaskInter() ; exit ; endif
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    #ifdef DEF_HST
      if empty(scIdDev)
        if empty(PAR->IdDev)
          cIdDev := DevDefault(MemPer2)
        else
          cIdDev := PAR->IdDev
        endif
      else
        cIdDev := scIdDev
      endif
      SetDevise(cIdDev)
      * SetDecPos(DevDecPos(cIdDev))
      cIdPar := PAR->IdPar
      cLine := cIdPar + " " + ParName()
      open area oHst(), oVen(), oFin(), oPar(), oGen()
        ddSetOrder(ORD_HST_PARDATE)
        aParBal := {}
        softseek cIdPar
        do while ! eof() .and. HST->IdPar == cIdPar .and. LstContinue()
          if HST->IdCtr == cIdCtr
            HstAddBal(aParBal,cIdDev)
            HstAddBal(aTotBal,cIdDev)
          endif
          skip
        enddo
        if empty(scIdDev)
          cLine := padr(cLine,nPadWidth - LEN_IDDEV - 1)
          cLine += " " + cIdDev
        else
          cLine := padr(cLine,nPadWidth)
        endif
        BalPrint( ;
          cLine, ;
          aParBal, ;
          empty(cIdCtr), ;
          nPadWidth ;
        )
      close area
    #endif DEF_HST
    skip
  enddo
close area
if ! empty(scIdDev)
  PrintLine()
  BalPrint( ;
    padr("TOTAL",nPadWidth - LEN_IDDEV - 1) + " " + scIdDev, ;
    aTotBal, ;
    empty(cIdCtr), ;
    nPadWidth ;
  )
endif
close printer
SetDevise(nDecPos)
RETURN .f.

FUNCTION HstAddBal(aBal,cIdDev,cIdCtr)
local i
local nItem
RETURN NIL if HST->Periode < PerStart(MemPer1)
if ChkPeriode(HST->Periode) < 0
  if HST->DC == DC_DEBIT
    nItem := BAL_INID
  else
    nItem := BAL_INIC
  endif
elseif ChkPeriode(HST->Periode) == 0
  if HST->DC == DC_DEBIT
    nItem := BAL_MVTD
  else
    nItem := BAL_MVTC
  endif
else
  RETURN NIL
endif
for i := 1 to len(aBal)
  * if aBal[i][BAL_IDCTR] == cIdCtr
    aBal[i][nItem] += HstMont(cIdDev)           // val(HST->Mont)
    RETURN NIL
  * endif
next i
aadd(aBal, { cIdCtr, 0, 0, 0, 0 } )
atail(aBal)[nItem] += HstMont(cIdDev)          // val(HST->Mont)
RETURN NIL

FUNCTION BalPrint(cLine,aBal,lIdCtr,nPadWidth)
local i
for i := 1 to len(aBal)
  if i != 1
    cLine := space(nPadWidth)
  endif
  if aBal[i][BAL_MVTD] != 0 .or. aBal[i][BAL_MVTC] != 0 ;
     .or. aBal[i][BAL_INID]+aBal[i][BAL_MVTD] ;
       != aBal[i][BAL_INIC]+aBal[i][BAL_MVTC]
    cLine += " " + solde(aBal[i][BAL_INID],aBal[i][BAL_INIC])
    cLine += " " + ntomf(aBal[i][BAL_MVTD])
    cLine += " " + ntomf(aBal[i][BAL_MVTC])
    cLine += " " + solde(aBal[i][BAL_INID]+aBal[i][BAL_MVTD],aBal[i][BAL_INIC]+aBal[i][BAL_MVTC])
    PrintLine(cLine)
  endif
next i
RETURN NIL


**
** HistPar() - Historique des comptes particuliers
**
FUNCTION HistPar(cIdCtr,cTplIni,cTitle,cIdFrom,nLibWidth,xcLibell)
local nWidth // := 16 + LenIdJnl() + LEN_IDDOC + LEN_LIBELL
local nTotGenD := 0
local nTotGenC := 0
local nTotalD
local nTotalC
local doc
local nIniD
local nIniC
local nMvtD
local nMvtC
local cLine
local lPrinted
local cTit1 := ""
local cTit2 := ""
local cIdPar   := NIL
local cIdDev
local i
local nDecPos := SetDevise()
* local nDecPos := SetDecPos()
* local cTitle := MsgHistPar(UsrLang())
static cLettre    := BUTTON_OFF
static cNoMvt     := BUTTON_ON
static cIdJnl := NIL
static cIdPar1 :=  NIL
static cIdPar2   :=  NIL
static scIdDev    :=  NIL
* default cIdJnl to space(30) // LenIdJnl())
local ctr
default cTitle to MsgHistPar(UsrLang())
default nLibWidth to LEN_LIBELL
default xcLibell to "HstParLibell(HST->IdJnl,HST->IdDoc,HST->Line)"
if cIdCtr == NIL
  cIdCtr := PickCtr(NIL,cTitle)
  RETURN .f. if (ctr := CtrLocate(cIdCtr)) == NIL
  cTitle += " (" + ctr[CTR_NAME] + ")"
else
  RETURN .f. if (ctr := CtrLocate(cIdCtr)) == NIL
endif
default cTplIni to "HIST"
default cIdPar1 to space(LenIdPar())
default cIdPar2   to space(LenIdPar())
default scIdDev  to DevDefault(PerActive())
open window (cTitle) size 10,60 help HISTPAR
SayGetPeriode()
GetPreview() ; WinCr()
SetTplIni(cTplIni)
GetTplIni()
GetRange()
say MsgComptes(UsrLang()) + " "
@ row(), col() get cIdPar1 picture PIC_ID ;
               postedit {|x|GetIdPar(x,ctr[CTR_PRTLIST])} ;
               pick PickPar(cIdPar1)
say MSG042
@ row(), col() get cIdPar2 picture PIC_ID ;
               postedit {|x|GetIdPar(x,ctr[CTR_PRTLIST])} ;
               pick PickPar(cIdPar2)
WinCR()
@ row(), col() get cNoMvt checkbox
say MSG003 // " aussi les comptes non mouvement‚s"
WinCR()
@ row(), col() get cLettre checkbox
say MSG001 // " uniquement les mouvements non lettr‚s"
WinCR()
#ifdef LG_GERMAN
  say "W„hrung "
#else
  say "Devise "
#endif
@ row(), col() get scIdDev picture PIC_ID pick PickDev(scIdDev)
#ifdef LG_GERMAN
  say " (leer = Partnerw„hrungen)"
#else
  say " (vide = devises des partenaire) "
#endif
* say MsgJournaux(UsrLang()) + " "
* @ row(), col() get cIdJnl picture PIC_ID pick PickJnlList(cIdJnl,"F")
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
RETURN .f. if ! WrnJnlOpen()
AppSaveMem()
open printer SetTplIni() ;
   preview SetPreview() ;
   range   SetRange() ;
   TitBlock {|| ;
     PrintHeader( ;
       cTitle, ;
       PerText() ;
     ), ;
     PrintLine(cTit1), ;
     PrintLine(cTit2)  ;
   }
cTit1 := padr(MsgCompte(MemLang1),LenIdPar())
cTit2 := repl("Ä",LenIdPar())
cTit1 += " " + padr(MsgDate(MemLang1),len(dtoc(UserDate())))
cTit2 += " " + repl("Ä",len(dtoc(UserDate())))
cTit1 += " " + padr(MsgPeriode(MemLang1),LEN_PERIODE)
cTit2 += " " + repl("Ä",LEN_PERIODE)
cTit1 += " " + padr(MsgIdDoc(MemLang1),LenIdJnl() + 1 + LEN_IDDOC)
cTit2 += " " + repl("Ä",LenIdJnl() + 1 + LEN_IDDOC)
cTit1 += " " + padr(MsgDescript(MemLang1),nLibWidth)
cTit2 += " " + repl("Ä",nLibWidth)
cTit1 += " " + padr("Match",LenIdJnl() + LEN_IDDOC) + " *"
cTit2 += " " + repl("Ä",LenIdJnl() + LEN_IDDOC) + " Ä"
* if !empty(scIdDev)
*   cTit1 += " " + padr(MsgMontDev(MemLang1),LenMont())
*   cTit2 += " " + repl("Ä",LenMont())
* endif
nWidth := len(cTit2)
cTit1 += " " + padr(MsgDebit(MemLang1),LenMntF())
cTit2 += " " + repl("Ä",LenMntF())
cTit1 += " " + padl(MsgCredit(MemLang1),LenMntF())
cTit2 += " " + repl("Ä",LenMntF())
cTit1 += " " + padl(MsgSolde(MemLang1),LenSolde())
cTit2 += " " + repl("Ä",LenSolde())
p_SetWidth(len(cTit2))
open area oHst(), oPar(), oGen(), oVen()
  ddSetOrder(ORD_HST_PARDATE)
  softseek trim(cIdPar1)
  do while ! eof() .and. LstContinue()
    seek HST->IdPar in PAR
    * cLine  := PAR->IdPar + " " + ParName()
    cIdPar := HST->IdPar
    if empty(scIdDev)
      if empty(PAR->IdDev)
        cIdDev := DevDefault(MemPer2)
      else
        cIdDev := PAR->IdDev
      endif
    else
      cIdDev := scIdDev
    endif
    SetDevise(cIdDev)
    * SetDecPos(DevDecPos(cIdDev))
    if ! empty(cIdPar2) .and. cIdPar > cIdPar2
      exit
    endif
    lPrinted := .F.
    nIniD := 0
    nIniC := 0
    nMvtD := 0
    nMvtC := 0
    do while ! eof() .and. HST->IdPar == cIdPar .and. LstContinue()
      if cLettre == BUTTON_OFF .or. empty(HST->Satis)
        if HST->IdCtr == ctr[CTR_ID]
          if HST->Periode < PerStart(MemPer1)
          elseif ChkPeriode(HST->Periode) < 0
            if HST->DC == DC_DEBIT
              nIniD += HstMont(cIdDev)
            else
              nIniC += HstMont(cIdDev)
            endif
          elseif ChkPeriode(HST->Periode) == 0
            if ! lPrinted
              KeepTogether(3)
              ** code repeated below !
              cLine := cIdPar
              cLine += " " + ParName()
              cLine := padr(cLine,nWidth)
              if nIniD > nIniC
                cLine += " " + ntomf(nIniD - nIniC)
                cLine += " " + space(LenMntF())
              else
                cLine += " " + space(LenMntF())
                cLine += " " + ntomf(nIniC - nIniD)
              endif
              PrintLine(cLine)
              lPrinted := .T.
            endif
            cLine := space(LenIdPar())
            cLine += " " + dtoc(HST->Date)
            cLine += " " + HST->Periode
            cLine += " " + HST->IdJnl
            cLine += " " + HST->IdDoc
            cLine += " " + padr( ;
              xparse(xcLibell), ;
              nLibWidth ;
            )
            * doc := DocInfo(HST->IdJnl,HST->IdDoc,HST->Line)
            * if doc == NIL
            *   cLine += " " + space(LEN_LIBELL)
            * else
            *   cLine += " " + padr(doc[DOC_LIBELL],LEN_LIBELL)
            * endif
            cLine += " " + HST->Match
            cLine += " " + HST->Satis
            * if !empty(scIdDev)
            *   cLine += " " + komma(HST->MontDev)
            * endif
            if HST->DC == DC_DEBIT
              cLine += " " + ntomf(HstMont(cIdDev)) + " " + space(LenMntF())
              nMvtD += HstMont(cIdDev)
            else
              cLine += " " + space(LenMntF()) + " " + ntomf(HstMont(cIdDev))
              nMvtC += HstMont(cIdDev)
            endif
            PrintLine(cLine)
          endif
        endif
      endif
      if TaskInter() ; LstError(PRN_ABORT) ; endif
      skip
    enddo
    if ! lPrinted
      if nIniD != nIniC .and. cNoMvt == BUTTON_ON
        ** code repeated from above !
        cLine := cIdPar
        cLine += " " + ParName()
        cLine := padr(cLine,nWidth)
        if nIniD > nIniC
          cLine += " " + ntomf(nIniD - nIniC)
          cLine += " " + space(LenMntF())
        else
          cLine += " " + space(LenMntF())
          cLine += " " + ntomf(nIniC - nIniD)
        endif
        PrintLine(cLine)
        lPrinted := .T.
      endif
    endif
    if lPrinted
      PrintLine( space(nWidth) + " " + repl("Ä",LenMntF() * 2 + 1) )
      nTotalD := 0
      nTotalC := 0
      if nIniD > nIniC
        nTotalD += nIniD - nIniC
      else
        nTotalC += nIniC - nIniD
      endif
      nTotalD += nMvtD
      nTotalC += nMvtC
      nTotGenD += nTotalD
      nTotGenC += nTotalC
      cLine := space(LenIdPar()) + " " + upper(MsgTotal())
      if empty(scIdDev)
        cLine := padr(cLine,nWidth - LEN_IDDEV - 1)
        cLine += " " + cIdDev
      else
        cLine := padr(cLine,nWidth)
      endif
      cLine += " " + ntomf(nTotalD) + " " + ntomf(nTotalC)
      cLine += " " + solde(nIniD+nMvtD,nIniC+nMvtC)
      PrintLine(cLine)
      PrintLine(repl("Ä",p_cpl())) // 19990714
      * PrintLine()
    endif
  enddo
  if ! empty(scIdDev)
    PrintLine()
    cLine := padr(upper(MsgTotal()),nWidth - LEN_IDDEV - 1)
    cLine += " " + scIdDev
    cLine += " " + ntomf(nTotGenD) + " " + ntomf(nTotGenC)
    cLine += " " + solde(nTotGenD,nTotGenC)
    PrintLine(cLine)
  endif
close area
close printer
SetDevise(nDecPos)
RETURN .f.


#define HG_ID      1
#define HG_DEBIT   2
#define HG_CREDIT  3
#define HG_PERIODE 4
#define HG_DATE    5
* #define HG_DEVDEBIT   6
* #define HG_DEVCREDIT  7
#define HG_ALEN    5

**
** HistGen() - Historique des comptes g‚n‚raux
**
FUNCTION HistGen(cTplIni,cTitle,cIdFrom,nLibWidth,xcLibell)
local nWidth // := 16 + LenIdJnl() + LEN_IDDOC + LEN_LIBELL
local a
local nTotIniD := 0
local nTotIniC := 0
local nTotalD
local nTotalC
local doc
local nIniD
local nIniC
local nMvtD
local nMvtC
* local nDevIniD
* local nDevIniC
* local nDevMvtD
* local nDevMvtC
local cLine
local cLn
local lPrinted
local nLines
local cTit1 := ""
local cTit2 := ""
local cTit3 := ""
local cCompte   := NIL
local i
local nDecPos := SetDevise()
* local nDecPos := SetDecPos()
local cIdDev
static cNoMvt     := BUTTON_ON
static cEject     := BUTTON_OFF
static cIdJnl := NIL
static scIdFrom :=  NIL
static scIdTo   :=  NIL
* static cDevise  :=  NIL
static scIdDev    :=  NIL
default scIdFrom to space(LenCompte())
default scIdTo   to space(LenCompte())
default cTplIni to "HIST"
default nLibWidth to LEN_LIBELL
* default xcLibell to "DocPartner(HST->IdJnl,HST->IdDoc,HST->Line)"
default xcLibell to "HstGenLibell(HST->IdJnl,HST->IdDoc,HST->Line)"
* default cDevise to BUTTON_OFF
default scIdDev  to DevDefault(PerActive())
if cIdFrom  != NIL
  scIdFrom  := padr(cIdFrom,LenCompte())
  scIdTo    := padr(cIdFrom,LenCompte())
endif
default cTitle to MsgHistGen(UsrLang())
open window (cTitle) size 10,60 help HISTGEN
SayGetPeriode()
GetPreview() ; WinCr()
SetTplIni(cTplIni)
GetTplIni()
GetRange()
say MsgComptes(UsrLang()) + " "
if cIdFrom == NIL
  @ row(), col() get scIdFrom picture PIC_ID pick PickGen(NIL,scIdFrom)
  say MSG042
  @ row(), col() get scIdTo picture PIC_ID   pick PickGen(NIL,scIdTo)
  WinCR()
  @ row(), col() get cNoMvt checkbox
  say MSG003 // " aussi les comptes non mouvement‚s"
  WinCR()
  @ row(), col() get cEject checkbox
  #ifdef LG_GERMAN
  say " neue Seite fr jedes Konto"
  #else
  say " nouvelle page pour chaque compte"
  #endif
else
  say cIdFrom
endif
* WinCR()
* @ row(), col() get cDevise checkbox
* #ifdef LG_GERMAN
*   say " auch Betr„ge in Fremdw„hrung"
* #else
*   say " ‚galement les montants en devise"
* #endif
WinCR()
#ifdef LG_GERMAN
  say "W„hrung "
#else
  say "Devise "
#endif
@ row(), col() get scIdDev picture PIC_ID pick PickDev(scIdDev)
#ifdef LG_GERMAN
  say " (leer = Partnerw„hrungen)"
#else
  say " (vide = devises des partenaire) "
#endif
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
RETURN .f. if ! WrnJnlOpen()
AppSaveMem()
open area oGen(), oHst(), oPar(), oFin(), oVen()
  HST->(ddSetOrder(ORD_HST_GENDATE))
  open printer SetTplIni() ;
               preview  SetPreview() ;
               range    SetRange() ;
               titblock {|| ;
                 PrintHeader( ;
                   cTitle , ;
                   PerText(), cTit3 ;
                 ), ;
                 PrintLine(cTit1), ;
                 PrintLine(cTit2) ;
               }
  cTit1 := padr("Konto",LenIdGen()) + " "
  cTit2 := repl("Ä",LenIdGen()) + " "
  cTit1 += padr(MsgDate(MemLang1),len(dtoc(UserDate()))) + " "
  cTit2 += repl("Ä",len(dtoc(UserDate()))) + " "
  cTit1 += padr(MsgPeriode(MemLang1),4) + " "
  cTit2 += repl("Ä",4) + " "
  cTit1 += padr(MsgIdDoc(MemLang1),LenIdJnl() + 1 + LEN_IDDOC) + " "
  cTit2 += repl("Ä",LenIdJnl() + 1 + LEN_IDDOC) + " "
  cTit1 += padr(MsgDescript(MemLang1),nLibWidth)
  cTit2 += repl("Ä",nLibWidth)
  nWidth := len(cTit2)
  cTit1 += " " + padr(MsgDebit(MemLang1),LenMntF()) + " "
  cTit2 += " " + repl("Ä",LenMntF()) + " "
  cTit1 += padl(MsgCredit(MemLang1),LenMntF())
  cTit2 += repl("Ä",LenMntF())
  cTit1 += " " + padl(MsgSolde(MemLang1),LenSolde())
  cTit2 += " " + repl("Ä",LenSolde())
  * if cDevise == BUTTON_ON
  *   cTit1 += " " + padr(MsgDebit(MemLang1),LenMntF()) + " "
  *   cTit2 += " " + repl("Ä",LenMntF()) + " "
  *   cTit1 += padl(MsgCredit(MemLang1),LenMntF())
  *   cTit2 += repl("Ä",LenMntF())
  *   cTit1 += " " + padl(MsgSolde(MemLang1),LenSolde())
  *   cTit2 += " " + repl("Ä",LenSolde())
  * endif
  if scIdDev != DevDefault(PerActive())
    cTit3 := "Betr„ge in Fremdw„hrung " + scIdDev
  endif
  p_SetWidth(len(cTit2))
  softseek trim(scIdFrom)
  do while ! eof() .and. LstContinue()
    if TaskInter() ; LstError(PRN_ABORT) ; exit ; endif
    cLine   := GEN->IdGen + " " + GEN->Libell1
    cCompte := GEN->IdGen
    if ! empty(scIdTo) .and. cCompte > scIdTo
      exit
    endif
    lPrinted := .F.
    nLines := 0
    nIniD := 0
    nIniC := 0
    nMvtD := 0
    nMvtC := 0
    * nDevIniD := 0
    * nDevIniC := 0
    * nDevMvtD := 0
    * nDevMvtC := 0
    a := {}
    if empty(scIdDev)
      if empty(GEN->IdDev)
        cIdDev := DevDefault(MemPer2)
      else
        cIdDev := GEN->IdDev
      endif
    else
      cIdDev := scIdDev
    endif
    SetDevise(cIdDev)
    * SetDecPos(DevDecPos(cIdDev))
    select HST
    softseek cCompte
    do while ! eof() .and. HST->IdGen == cCompte .and. LstContinue()
      if TaskInter() ; LstError(PRN_ABORT) ; exit ; endif
      if HST->Periode < PerStart(MemPer1)
      elseif ChkPeriode(HST->Periode) < 0
        if HST->DC == DC_DEBIT
          nIniD += HstMont(cIdDev) // val(HST->Mont)
        else
          nIniC += HstMont(cIdDev) // val(HST->Mont)
        endif
      elseif ChkPeriode(HST->Periode) == 0
        ** code repeated below !
        if nLines == 0 // ! lPrinted
          KeepTogether(7)
          cLine   := GEN->IdGen + " " + GEN->Libell1
          cLine := padr(cLine,nWidth)
          cLine += " " + space(LenMntF()*2 +1)
          cLine += " " + solde(nIniD,nIniC)
          * if cDevise == BUTTON_ON .and. ! empty(GEN->IdDev)
          *   cLine += " " + space(LenSolde())
          *   cLine += " " + space(LenMntF()*2 +1)
          *   cLine += " " + solde(nIniD,nIniC,DevDecPos(GEN->IdDev))
          * endif
          PrintLine(cLine)
          nLines++
        endif
        ** end of code repeated below
        if HST->DC == DC_DEBIT
          nMvtD += HstMont(cIdDev) // val(HST->Mont)
          * nDevMvtD += val(HST->MontDev)
        else
          nMvtC += HstMont(cIdDev) // val(HST->Mont)
          * nDevMvtC += val(HST->MontDev)
        endif
        if GENATTR_D $ GEN->Attrib
          DcCollect(a, ;
            HST->IdJnl,HST->Periode, ;
            HST->DC, ;
            HstMont(cIdDev), ;
            HST->Date  ;
          )
        else
          cLn := space(LenIdGen())
          cLn += " " + dtoc(HST->Date)
          cLn += " " + HST->Periode
          cLn += " " + HST->IdJnl
          cLn += " " + HST->IdDoc
          cLn += " " + padr( ;
            xparse(xcLibell), ;
            nLibWidth ;
          )
          if HST->DC == DC_DEBIT
            cLn += " " + ntomf(HstMont(cIdDev))
            cLn += " " + space(LenMntF())
          else
            cLn += " " + space(LenMntF())
            cLn += " " + ntomf(HstMont(cIdDev))
          endif
          * if cDevise == BUTTON_ON .and. ! empty(GEN->IdDev)
          *   cLn += " " + space(LenSolde())
          *   if HST->DC == DC_DEBIT
          *     cLn += " " + ntomf(val(HST->MontDev),DevDecPos(GEN->IdDev))
          *     cLn += " " + space(LenMntF())
          *   else
          *     cLn += " " + space(LenMntF())
          *     cLn += " " + ntomf(val(HST->MontDev),DevDecPos(GEN->IdDev))
          *   endif
          * endif
          PrintLine(cLn)
          nLines++
        endif
      endif
      skip
    enddo
    select GEN
    ** code repeated above
    if nLines == 0
      if nIniD != nIniC .and. cNoMvt == BUTTON_ON
        cLine   := GEN->IdGen + " " + GEN->Libell1
        if empty(scIdDev)
          cLine := padr(cLine,nWidth - LEN_IDDEV - 1)
          cLine += " " + cIdDev
        else
          cLine := padr(cLine,nWidth)
        endif
        cLine += " " + space(LenMntF()*2 + 1)
        cLine += " " + solde(nIniD,nIniC)
        * if cDevise == BUTTON_ON .and. ! empty(GEN->IdDev)
        *   cLine += " " + space(LenSolde())
        *   cLine += " " + space(LenMntF()*2 +1)
        *   cLine += " " + solde(nIniD,nIniC,DevDecPos(GEN->IdDev))
        * endif
        PrintLine(cLine)
        nLines++
      endif
    endif
    ** end of code repeated above
    if len(a) > 0
      for i := 1 to len(a)
        cLine := space(LenIdGen())
        cLine += " " + dtoc(a[i][HG_DATE])
        cLine += " " + a[i][HG_PERIODE]
        cLine += " " + a[i][HG_ID]
        cLine += " " + JnlName(a[i][1])
        cLine := padr(cLine,nWidth)
        cLine += " " + ntomf(a[i][HG_DEBIT])
        cLine += " " + ntomf(a[i][HG_CREDIT])
        * if cDevise == BUTTON_ON .and. ! empty(GEN->IdDev)
        *   cLine += " " + space(LenSolde())
        *   cLine += " " + ntomf(a[i][HG_DEVDEBIT],DevDecPos(GEN->IdDev))
        *   cLine += " " + ntomf(a[i][HG_DEVCREDIT],DevDecPos(GEN->IdDev))
        * endif
        PrintLine(cLine)
        nLines++
      next i
    endif
    if nLines > 0
      nTotalD := 0
      nTotalC := 0
      if nIniD > nIniC
        nTotalD += nIniD - nIniC
      else
        nTotalC += nIniC - nIniD
      endif
      nTotalD += nMvtD
      nTotalC += nMvtC
      nTotIniD += nTotalD
      nTotIniC += nTotalC
      if nLines > 2
        PrintLine( space(nWidth) + " " + repl("Ä",2 * LenMntF() + 1) )
        cLine := padl(MsgTotal() ,nWidth)
        cLine += " " + ntomf(nMvtD) + " " + ntomf(nMvtC)
        cLine += " " + solde(nMvtD,nMvtC)
        * if cDevise == BUTTON_ON .and. ! empty(GEN->IdDev)
        *   cLine += " " + ntomf(nDevMvtD)
        *   cLine += " " + ntomf(nDevMvtC)
        *   cLine += " " + solde(nDevMvtD,nDevMvtC,DevDecPos(GEN->IdDev))
        * endif
        PrintLine(cLine)
      endif
      if nLines > 1
        if empty(scIdDev)
          cLine := padl(MsgSolde(MemLang1),nWidth - LEN_IDDEV - 1)
          cLine += " " + cIdDev
        else
          cLine := padl(MsgSolde(MemLang1),nWidth)
        endif
        cLine += " " + space(LenMntF()*2+1)
        cLine += " " + solde(nIniD+nMvtD,nIniC+nMvtC)
        * if cDevise == BUTTON_ON .and. ! empty(GEN->IdDev)
        *   cLine += " " + space(LenMntF()*2+1)
        *   cLine += " " + solde( ;
        *     nDevIniD+nDevMvtD, ;
        *     nDevIniC+nDevMvtC, ;
        *     DevDecPos(GEN->IdDev) ;
        *   )
        * endif
        PrintLine(cLine)
      endif
      * PrintLine() // 19990714
      if cEject == BUTTON_ON
        p_eject()
      else
        PrintLine(repl("Ä",p_cpl())) // 19990714
      endif
    endif
    skip
  enddo
  if ! empty(scIdDev)
    PrintLine()
    cLine := padr(upper(MsgTotal()),nWidth - LEN_IDDEV - 1)
    cLine += " " + scIdDev
    cLine += " " + ntomf(nTotIniD) + " " + ntomf(nTotIniC)
    cLine += " " + solde(nTotIniD,nTotIniC)
    PrintLine(cLine)
  endif
  close printer
close area
SetDevise(nDecPos)
RETURN .f.


STATIC FUNCTION DcCollect(a,cId,cPeriode,cDC,nMont,dDate,nMontDev)
local dca := NIL
local i
for i := 1 to len(a)
  if a[i][HG_ID] == cId
    if a[i][HG_PERIODE] == cPeriode
      dca := a[i]
      exit
    endif
  endif
next i
if dca == NIL
  dca := array(HG_ALEN)
  dca[HG_ID]     := cId
  dca[HG_PERIODE] := cPeriode
  dca[HG_DATE] := dDate
  dca[HG_DEBIT]  := 0
  dca[HG_CREDIT] := 0
  * dca[HG_DEVDEBIT]  := 0
  * dca[HG_DEVCREDIT] := 0
  aadd(a,dca)
endif
if cDC == DC_DEBIT
  dca[HG_DEBIT]  += nMont
  * dca[HG_DEVDEBIT]  += nMontDev
else
  dca[HG_CREDIT] += nMont
  * dca[HG_DEVCREDIT] += nMontDev
endif
if dca[HG_DATE] < dDate
  dca[HG_DATE] := dDate
endif
RETURN NIL

FUNCTION MsgHistGen(cLangue)
RETURN "Historik Generalkonten" if cLangue == "D"
RETURN "Historique comptes g‚n‚raux"

#endif DEF_HST

**
** JnlMatch()
**
*FUNCTION JnlMatch(cJnlListe, cIdJnl)
*local jnl
*RETURN .T. if cIdJnl $ cJnlListe
*RETURN .F. if (jnl := JnlLocate(cIdJnl) ) == NIL
*if empty(cJnlListe)
*  RETURN (! empty(jnl[JNL_DC]))
*endif
**if "*FV" $ cJnlListe
**  if JNLATTR_F $ jnl[JNL_ATTRIB] .and. ! JNLATTR_N $ jnl[JNL_ATTRIB] .and. jnl[JNL_ALIAS] == "VEN"
**    RETURN .T.
**  endif
**endif
**if "*NV" $ cJnlListe
**  if JNLATTR_F $ jnl[JNL_ATTRIB] .and. JNLATTR_N $ jnl[JNL_ATTRIB] .and. jnl[JNL_ALIAS] == "VEN"
**    RETURN .T.
**  endif
**endif
**if "*FA" $ cJnlListe
**  if JNLATTR_F $ jnl[JNL_ATTRIB] .and. ! JNLATTR_N $ jnl[JNL_ATTRIB] .and. jnl[JNL_ALIAS] == "ACH"
**    RETURN .T.
**  endif
**endif
**if "*NA" $ cJnlListe
**  if JNLATTR_F $ jnl[JNL_ATTRIB] .and. JNLATTR_N $ jnl[JNL_ATTRIB] .and. jnl[JNL_ALIAS] == "ACH"
**    RETURN .T.
**  endif
**endif
*RETURN .F.

FUNCTION IsPart(cTitre,cCode)
local cPart := trim(cTitre)
RETURN (left(cCode,len(cPart)) == cPart)

#ifdef DEF_PRESTO

**
** 40 Ventilation de l'agenda
**
*FUNCTION BI_40()
*local i
** local tDuree
*local nKey
*local lFirst
*local lFound
*static cIdCli := NIL
*static cIdFou := NIL
** static cIdJnl := NIL
*local cLine
*local cTitLine1 := padr("Code   Libell‚",46)
*local cTitLine2 := "ÄÄÄÄÄÄ " + repl("Ä",39)
*local cTotTime
*local aUser := { }
*local cDetail := " "
*default cIdCli to space(LenCompte())
*default cIdFou to space(LenCompte())
*open window (MSG036) size 6,50 help LPRESTO
*GetDateRange()
*WinCR()
*say MSG064
*@ row(), col() get cIdCli pick PickPar(NIL,cIdCli)
*WinCR()
** say MSG065
** @ row(), col() get cIdFou pick PickFou(cIdFou)
** WinCR()
*@ row(), col() get cDetail checkbox
*say MSG066 // " liste d‚taill‚e"
*nKey := ReadScr()
*close window
*if nKey == K_ESC
*  RETURN NIL
*endif
*open area oUsr()
*go top
*do while !eof()
*  if ! ("H" $ USR->Attrib)
*    aadd( aUser,{ USR->UserId, "", "000:00" } )
*    cTitLine1 += " " + padl(trim(USR->UserId), 8)
*    cTitLine2 += " ÄÄÄÄÄÄÄÄ"
*  endif
*  skip
*enddo
*close area
*cTitLine1 += " " + padl("Autres",8)
*cTitLine2 += " ÄÄÄÄÄÄÄÄ"
*aadd( aUser,{ "Autres", "", "000:00" } )
*open area oTrm(), oTac(), oPar()
*ddSetOrder 4
*open printer LISTE width len(cTitLine2) ;
*TitBlock {||                                        ;
*  PrintHeader( MSG036, DateRange() ),                    ;
*  PrintLine(cTitLine1), ;
*  PrintLine(cTitLine2)  ;
*}
*select TAC
*go top
*do while !eof() .and. LstContinue() //
*  lFirst := .T.
*  lFound := .F.
*  for i := 1 to len(aUser)
*    aUser[i][2] := "000:00"
*  next i
*  select TRM
*  softseek trim(TAC->IdTac)
*  do while !eof() .and. LstContinue() .and. IsPart(TAC->IdTac,TRM->IdTac)
*    if ChkDateRange(TRM->Date)
*      if empty(cIdCli) .or. TRM->IdPar == cIdCli
*        * if empty(cIdFou) .or. TRM->iFou == cIdFou
*          lFound := .T.
*          * tDuree := TimeDiff(TRM->Debut,TRM->Fin)
*          if cDetail == BUTTON_ON
*            if lFirst
*              PrintLine()
*              PrintLine( TAC->IdTac + " " + TAC->Libell )
*              PrintLine()
*              lFirst := .F.
*            endif
*            PrintLine( ;
*              dtoc(TRM->Date) + " " + ;
*              TRM->Debut + " " + ;
*              TRM->Fin   + " " + ;
*              TRM->User + " " + ;
*              TRM->Texte + " " + ;
*              TRM->Duree ;
*            )
*          endif
*          AddTimeArray(aUser,TRM->User,TRM->Duree)
*        * endif
*      endif
*    endif
*    skip
*  enddo
*  if lFound
*    cLine := TAC->IdTac + " " + TAC->Libell
*    lFound := .f.
*    for i := 1 to len(aUser)
*      if t2min(aUser[i][2]) == 0
*        cLine += space(9)
*      else
*        cLine += space(2) + padl(aUser[i][2],6) + " "
*        lFound := .t.
*      endif
*    next i
*    if lFound
*      PrintLine(cLine)
*    endif
*  endif
*  select TAC
*  skip
*enddo
*PrintLine()
*cLine := padr(upper(MsgTotal()),47)
*for i := 1 to len(aUser)
*  if t2min(aUser[i][3]) == 0
*    cLine += space(9)
*  else
*    cLine += space(2) + padl(aUser[i][3],6) + " "
*  endif
*next i
*PrintLine(cLine)
*close printer
*close area
*RETURN NIL

**
** AddTimeArray()
**
*FUNCTION AddTimeArray(aTime,cUser,tDuree)
*local i
*for i := 1 to len(aTime)
*  if trim(aTime[i][1]) == trim(cUser) .or. i == len(aTime)
*    aTime[i][2] := TimeAdd(aTime[i][2],tDuree,6)
*    aTime[i][3] := TimeAdd(aTime[i][3],tDuree,6)
*    RETURN NIL
*  endif
*next i
*RETURN NIL


#endif DEF_PRESTO

#ifdef DEF_VEN

**
** altes Dateiformat (bis Januar 1999)
** siehe install.hlp 199902.hlp : 19990217
**
FUNCTION VenTvaListe( ;
  lTaxe,cIdCtr,xlParFilter,nMontMin,cTitle,cIdTpl,nOrder, ;
  cFileName, cTplIni, xlVenFilter ;
)
local cDC := CtrDC(cIdCtr)
local jnl
local nCount := 0
local cIdPar
local cLine
local i
local aMvt
local nParBase := 0
local nParTaxe := 0
local cMin
local cTit1 := "Nø "
local cTit2 := "ÄÄÄ"
local nPad
local fd
local cDoFile := BUTTON_OFF
static cIdDev
local a
local bCondit := {|| ;
  JNL->Alias == "VEN" ;
  .and. JNL->IdCtr == cIdCtr ;
  .and. JNLATTR_G $ JNL->Attrib ;
}
default xlVenFilter to ".t."
default xlParFilter to ".t."
default cFileName to dbPath() + "\TVA*.TXT"
cFileName := TmpConvert(cFileName)
default nMontMin to 0
default nOrder to ORD_PAR_ID
default cTplIni to "LISTE"
default cIdDev to DevDefault(PerActive())
* default cAttrib to ""
cMin := ntom(nMontMin)
snTotBase := 0
snTotTaxe := 0
snSeq  := 0
cFileName := padr(cFileName,128)
* MsgTvaListe(UsrLang()) + " " + cAttrib) ;
open window (cTitle) size 9,50 help TVALST
say "Mindestbetrag "
get cMin GET_MONTANT
WinCr()
get cDoFile checkbox
say " auf Diskette "
get cFileName picture "@K@S30"
WinCr()
SayGetPeriode()
say "W„hrung "
get cIdDev picture "@k@!" pick PickDev(cIdDev)
WinCr()
GetPreview() ; WinCr()
SetTplIni(cTplIni)
GetTplIni()
GetRange()
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
RETURN .f. if ! WrnJnlOpen(bCondit)
cFileName := trim(cFileName)
if cDoFile == BUTTON_ON
  if (fd := fcreate(cFileName)) == -1
    Warning(cFileName + MsgDosError(ferror()))
    RETURN .f.
  endif
  cLine := repl("0",6)
  cLine += padr(MemName1,32)
  cLine += padr(MemName2,24)
  cLine += padr(MemName3,28)
  cLine += space(1)
  cLine += substr(TvaTrim(MemNoTva),3,9)
  cLine += space(28)
  fwrite(fd,cLine + CR_LF)
endif
open printer (SetTplIni()) ;
             preview  SetPreview() ;
             range    SetRange() ;
             titblock {|| ;
               PrintHeader(cTitle, "("+cIdDev+")", PerText(bCondit) ), ;
               PrintLine(cTit1),;
               PrintLine(cTit2) ;
             }
cTit1 += " " + padr(MsgTva02(MemLang1),40)
cTit2 += " " + repl("Ä",40)
cTit1 += " " + padr(MsgTva03(MemLang1),18)
cTit2 += " " + repl("Ä",18)
nPad := len(cTit2)
cTit1 += " " + padl(MsgUmsatz(MemLang1),LenMntF())
cTit2 += " " + repl("Ä",LenMntF())
if lTaxe // cAttrib == TAXATTR_A
  cTit1 += " " + padl(MsgTva(MemLang1),LenMntF())
  cTit2 += " " + repl("Ä",LenMntF())
endif
p_SetWidth(len(cTit2))
open area oPar(), oPlz(), oNat()
  ddSetOrder(nOrder)
  go top
  do while ! eof() .and. LstContinue()
    MsgDisp2(ntrim0(100 * nCount++ / lastrec(),5,0) + "%")
    if TaskInter() ; exit ; endif
    if &xlParFilter // cIdReg == NIL .or. PAR->IdReg $ cIdReg
      cIdPar := PAR->IdPar
      nParBase := 0
      nParTaxe := 0
      open area oVen(), oPar(), oGen(), oArt()
        ddSetOrder(ORD_VEN_PAR)
        softseek cIdPar
        do while ! eof() .and. LstContinue() .and. VEN->IdPar == cIdPar
          if &xlVenFilter
            if ChkPeriode(VEN->Periode) == 0
              if (jnl := JnlLocate(VEN->IdJnl)) != NIL
                if jnl[JNL_IDCTR] == cIdCtr
                  if JNLATTR_G $ jnl[JNL_ATTRIB]
                    if (a := VenVnlInit(jnl)) == NIL
                      Warning(MsgIdJnlDoc() + " : " + SetMsg())
                    else
                      aMvt := {}
                      open area oVnl(VEN->Etat)
                        softseek VEN->IdJnl + VEN->IdDoc
                        do while ! eof() ;
                                 .and. FIELD->IdJnl == VEN->IdJnl ;
                                 .and. FIELD->IdDoc == VEN->IdDoc
                          if ! VnlVarCollect()
                            Warning(MsgIdJnlDoc()+" : " + SetMsg())
                          endif
                          VnlMvtCollect(jnl,aMvt)
                          skip
                        enddo
                        #ifdef DEF_VENREMISE
                          VenMvtRemise(aMvt)
                        #endif
                        #ifdef DEF_FRF
                          if ! VenFrfCollect(jnl,aMvt)
                            Warning(MsgIdJnlDoc()+" : " + SetMsg())
                          endif
                        #endif DEF_FRF
                        VenMvtRound(aMvt,jnl)
                      close area
                      for i := 1 to len(aMvt)
                        if aMvt[i][MVT_ISBASE]
                          if VEN->DC == cDC
                            nParBase += Db2Dev(cIdDev,VEN->Periode,aMvt[i][MVT_MONTDB])
                          else
                            nParBase -= Db2Dev(cIdDev,VEN->Periode,aMvt[i][MVT_MONTDB])
                          endif
                        else
                          if VEN->DC == cDC
                            nParTaxe += Db2Dev(cIdDev,VEN->Periode,aMvt[i][MVT_MONTDB])
                          else
                            nParTaxe -= Db2Dev(cIdDev,VEN->Periode,aMvt[i][MVT_MONTDB])
                          endif
                        endif
                      next i
                      VnlRestore(a)
                    endif
                  endif
                endif
              else
                Warning(MsgIdJnlDoc() + MsgJnlExist())
              endif
            endif
          endif
          skip
        enddo
      close area
      if nParBase != 0
        if empty(cMin) ;
          .or. (!empty(cMin) .and. val(cMin)>0 .and. (abs(nParBase)>=val(cMin))) ;
          .or. (!empty(cMin) .and. val(cMin)<0 .and. (abs(nParBase)<-val(cMin)))
          if p_LinesLeft() < 4
            PrintLine()
            cLine := space(3) + " " + padr("šBERTRAG",40)
            cLine += " " + space(len(PAR->NoTva))
            cLine += " " + ntomf(snTotBase,DevDecPos(cIdDev))
            if lTaxe // cAttrib == TAXATTR_A
              cLine += " " + ntomf(snTotTaxe,DevDecPos(cIdDev))
            endif
            PrintLine(cLine)
            p_Eject()
            cLine := space(3) + " " + padr("šBERTRAG",40)
            cLine += " " + space(len(PAR->NoTva))
            cLine += " " + ntomf(snTotBase,DevDecPos(cIdDev))
            if lTaxe // cAttrib == TAXATTR_A
              cLine += " " + ntomf(snTotTaxe,DevDecPos(cIdDev))
            endif
            PrintLine(cLine)
            PrintLine()
          endif
          snSeq++
          cLine := str(snSeq,3,0)
          cLine += " " + padr(cIdPar + " " + ParName(),40)
          cLine += " " + PAR->NoTva
          cLine += " " + ntomf(nParBase,DevDecPos(cIdDev))
          if lTaxe // cAttrib == TAXATTR_A
            cLine += " " + ntomf(nParTaxe,DevDecPos(cIdDev))
          endif
          PrintLine(cLine)
          cLine := space(3)
          cLine += " " + padr(ParStreet(),40)
          PrintLine(cLine)
          cLine := space(3)
          cLine += " " + padr(ParCity(),40)
          PrintLine(cLine)
          if cDoFile == BUTTON_ON
            cLine := spacezero(snSeq,6,0)
            cLine += padr(ParName(),32)
            cLine += padr(ParStreet(),24)
            cLine += left(PAR->CP,4)
            cLine += padr(PLZ->Nom,24)
            cLine += " "
            cLine += substr(TvaTrim(PAR->NoTva),3,9)
            cLine += spacezero(nParBase,10,DevDecPos(cIdDev))
            cLine += spacezero(nParTaxe,10,DevDecPos(cIdDev))
            cLine += space(8)
            fwrite(fd,cLine + CR_LF)
          endif
          snTotBase += nParBase
          snTotTaxe += nParTaxe
        endif
      endif
    endif
    skip
  enddo
  PrintLine()
  cLine := padr("Total",nPad)
  cLine += " " + ntomf(snTotBase,DevDecPos(cIdDev))
  if lTaxe // cAttrib == TAXATTR_A
    cLine += " " + ntomf(snTotTaxe,DevDecPos(cIdDev))
  endif
  PrintLine(cLine)
close area
if cIdTpl != NIL
  SetPageHeader({||NIL})
  p_eject()
  TplInclude(TPLTYPE_INC,cIdTpl)
endif
close printer
if cDoFile == BUTTON_ON
  cLine := repl("9",6)
  cLine += spacezero(snTotBase,16,DevDecPos(cIdDev))
  cLine += spacezero(snTotTaxe,16,DevDecPos(cIdDev))
  cLine += space(24)
  cLine += space(4)
  cLine += space(24)
  cLine += space(1)
  cLine += substr(TvaTrim(MemNoTva),3,9)
  fwrite(fd,cLine + CR_LF)
  fclose(fd)
endif
RETURN .f.


**
** DoVenTvaListe()
** neues Format ab 2003
** listing annuel clients assujettis
** selon minfin/Brocure_cl_fr_0203.doc
** http://fiscus.fgov.be/interfaoiffr/BTWlijst725/inleiding.htm
**
**  if lTaxe : clients_fr-supmagn.pdf
**  else : intra_fr-supmagn.pdf
FUNCTION DoVenTvaliste( ;
  lTaxe,cIdCtr,cTitle,nMontMin, ;
  xlParFilter,xlVenFilter, ;
  cBegleit, ;
  nOrder, ;
  cDoFile,cFilename)
local cDC := CtrDC(cIdCtr)
local jnl
local nCount := 0
local a
local cIdPar
local i
local aMvt
local nParBase := 0
local nParTaxe := 0
local cTit1 := "Nø "
local cTit2 := "ÄÄÄ"
local nPad
local cLine
local fd
local lOkay := .t.
local n27or28
// local nDecPos := DevDecPos(DevDefault(MemPer1))
local bCondit := {|| ;
  JNL->Alias == "VEN" ;
  .and. JNL->IdCtr == cIdCtr ;
  .and. JNLATTR_G $ JNL->Attrib ;
}
local cZeitraum
if pnQuarter(MemPer1) == pnQuarter(MemPer2) ;
     .and. pnYear(MemPer1) == pnYear(MemPer2)
  cZeitraum := str(pnQuarter(MemPer2),1) + str(pnYear(MemPer2),4)
else
  cZeitraum := str(pnYear(MemPer2),4)
  if ! lTaxe
    RETURN !Warning("Relev‚ intracommunautaire : un trimestre … la fois!")
  endif
endif
RETURN .f. if ! WrnJnlOpen(bCondit)
if lTaxe
  n27or28 := 27
else
  n27or28 := 28
endif
// default cIdDev to DevDefault(MemPer1)
if cDoFile == BUTTON_ON
  *if lTaxe
  *  *Warning( ;
  *  *  "Das Format fr die Liste der belgischen" + ;
  *  *  " MWSt-pflichtigen Kunden auf Diskette" + ;
  *  *  " wird noch nicht untersttzt.")
  *  cDoFile := BUTTON_OFF
  *endif
  if len(trim(TvaTrim(MemNoTva))) != 11
    Warning('"' + MemNoTva + '" : ungltige MWSt-Nummer des Deklaranten !')
    cDoFile := BUTTON_OFF
  endif
endif
default nOrder to ORD_PAR_ID
default xlVenFilter to ".t."
default xlParFilter to ".t."
snTotBase := 0
snTotTaxe := 0
snSeq  := 0
if cDoFile == BUTTON_ON
  if (fd := fcreate(cFileName)) == -1
    Warning(cFileName + MsgDosError(ferror()))
    RETURN .f.
  endif
  cLine := repl("0",6)                      // pos 1-6
  cLine += padr(MemName1,32)                // pos 7-38
  cLine += padr(MemName2,24)                // pos 39-62
  cLine += padr(MemName3,n27or28)           // pos 63-89
  cLine += trim(TvaTrim(MemNoTva))          // pos 90-100
  if lTaxe
    cLine += space(20)                        // pos 101-120
  else
    cLine += space(17)                        // pos 101-120
  endif
  if !lTaxe
    cLine += cZeitraum // trimestre + ann‚e (TAAAA)
  endif
  if SetDevise() $ "BEF,BF "
    cLine += "B"                            // pos 124
  elseif SetDevise() == "EUR"
    cLine += "E"
  else
    Warning( ;
      'Kein Dateiformat definiert fr W„hrung "' + ;
      SetDevise() +'"' ;
    )
  endif
  if lTaxe
    cLine += cZeitraum                        // pos 122-125
    cLine += space(3)                         // pos 125-129
  else
    cLine += space(4)
  endif
  fwrite(fd,cLine + CR_LF)
endif
OpenPrinter(SetTplIni(),SetPreview(),NIL,{|| ;
    PrintHeader(cTitle, "("+SetDevise()+")", PerText(bCondit) ), ;
    PrintLine(cTit1),;
    PrintLine(cTit2) }, SetRange(),NIL,NIL,NIL,SetAsPdf())
*open printer (SetTplIni()) ;
*             preview  SetPreview() ;
*             range    SetRange() ;
*             titblock {|| ;
*               PrintHeader(cTitle, "("+SetDevise()+")", PerText(bCondit) ), ;
*               PrintLine(cTit1),;
*               PrintLine(cTit2) ;
*             }
cTit1 += " " + padr(MsgTva02(MemLang1),40)
cTit2 += " " + repl("Ä",40)
cTit1 += " " + padr(MsgTva03(MemLang1),18)
cTit2 += " " + repl("Ä",18)
nPad := len(cTit2)
cTit1 += " " + padl(MsgUmsatz(MemLang1),LenMntF())
cTit2 += " " + repl("Ä",LenMntF())
if lTaxe // cAttrib == TAXATTR_A
  cTit1 += " " + padl(MsgTva(MemLang1),LenMntF())
  cTit2 += " " + repl("Ä",LenMntF())
endif
p_SetWidth(len(cTit2))
open area oPar(), oPlz(), oNat()
  ddSetOrder(nOrder)
  go top
  do while ! eof() .and. lOkay
    // ! LstContinue()
    MsgDisp2(ntrim0(100 * nCount++ / lastrec(),5,0) + "%")
    if TaskInter() ; lOkay := .f. ; exit ; endif
    if &xlParFilter
      cIdPar := PAR->IdPar
      nParBase := 0
      nParTaxe := 0
      open area oVen(), oPar(), oGen(), oArt()
        ddSetOrder(ORD_VEN_PAR)
        softseek cIdPar
        do while ! eof() .and. lOkay .and. VEN->IdPar == cIdPar
          if &xlVenFilter
            if ChkPeriode(VEN->Periode) == 0
              if (jnl := JnlLocate(VEN->IdJnl)) == NIL
                Warning(MsgIdJnlDoc() + MsgJnlExist())
                * lOkay := .f.
              else
                if jnl[JNL_IDCTR] == cIdCtr
                  if JNLATTR_G $ jnl[JNL_ATTRIB]
                    if (a := VenVnlInit(jnl)) == NIL
                      lOkay := .f.
                      Warning(MsgIdJnlDoc() + " : " + SetMsg())
                    else
                      aMvt := {}
                      open area oVnl(VEN->Etat)
                        softseek VEN->IdJnl + VEN->IdDoc
                        do while lOkay .and. ! eof() ;
                                 .and. FIELD->IdJnl == VEN->IdJnl ;
                                 .and. FIELD->IdDoc == VEN->IdDoc
                          if ! VnlVarCollect()
                            Warning(MsgIdJnlDoc()+" : " + SetMsg())
                            lOkay := .f.
                          endif
                          VnlMvtCollect(jnl,aMvt)
                          skip
                        enddo
                        #ifdef DEF_VENREMISE
                          VenMvtRemise(aMvt)
                        #endif
                        #ifdef DEF_FRF
                          if ! VenFrfCollect(jnl,aMvt)
                            Warning(MsgIdJnlDoc()+" : " + SetMsg())
                            lOkay := .f.
                          endif
                        #endif DEF_FRF
                        VenMvtRound(aMvt,jnl)
                      close area
                      VnlRestore(a)
                      for i := 1 to len(aMvt)
                        if aMvt[i][MVT_ISBASE]
                          if VEN->DC == cDC
                            nParBase += Db2Dev(SetDevise(),VEN->Periode,aMvt[i][MVT_MONTDB])
                          else
                            nParBase -= Db2Dev(SetDevise(),VEN->Periode,aMvt[i][MVT_MONTDB])
                          endif
                        else
                          if VEN->DC == cDC
                            nParTaxe += Db2Dev(SetDevise(),VEN->Periode,aMvt[i][MVT_MONTDB])
                          else
                            nParTaxe -= Db2Dev(SetDevise(),VEN->Periode,aMvt[i][MVT_MONTDB])
                          endif
                        endif
                        * if VEN->DC == cDC
                        *   nParBase += Db2Dev(SetDevise(),VEN->Periode,aMvt[i][MVT_BASEDB])
                        *   nParTaxe += Db2Dev(SetDevise(),VEN->Periode,aMvt[i][MVT_TAXEDB])
                        * else
                        *   nParBase -= Db2Dev(SetDevise(),VEN->Periode,aMvt[i][MVT_BASEDB])
                        *   nParTaxe -= Db2Dev(SetDevise(),VEN->Periode,aMvt[i][MVT_TAXEDB])
                        * endif
                      next i
                    endif
                  endif
                endif
              endif
            endif
          endif
          skip
        enddo
      close area
      if nParBase != 0
        if nMontMin == NIL ;
          .or. ( nMontMin > 0 .and. abs(nParBase) >= nMontMin  ) ;
          .or. ( nMontMin < 0 .and. abs(nParBase) <  -nMontMin )
          if p_LinesLeft() < 4
            PrintLine()
            cLine := space(3) + " " + padr("šBERTRAG",40)
            cLine += " " + space(len(PAR->NoTva))
            cLine += " " + ntomf(snTotBase)
            if lTaxe // cAttrib == TAXATTR_A
              cLine += " " + ntomf(snTotTaxe)
            endif
            PrintLine(cLine)
            p_Eject()
            cLine := space(3) + " " + padr("šBERTRAG",40)
            cLine += " " + space(len(PAR->NoTva))
            cLine += " " + ntomf(snTotBase)
            if lTaxe
              cLine += " " + ntomf(snTotTaxe)
            endif
            PrintLine(cLine)
            PrintLine()
          endif
          snSeq++
          cLine := str(snSeq,3,0)
          cLine += " " + padr(cIdPar + " " + ParName(),40)
          cLine += " " + PAR->NoTva
          cLine += " " + ntomf(nParBase)
          if lTaxe // cAttrib == TAXATTR_A
            cLine += " " + ntomf(nParTaxe)
          endif
          PrintLine(cLine)
          cLine := space(3)
          cLine += " " + padr(ParStreet(),40)
          PrintLine(cLine)
          cLine := space(3)
          cLine += " " + padr(ParCity(),40)
          PrintLine(cLine)
          * 20040315: Warnung nur noch wenn Datei erstellt wird
          *if lTaxe .and. len(trim(TvaTrim(PAR->NoTva))) != 11
          *   Warning(PAR->IdPar + " " +trim(ParName())+" : ungltige belgische MWSt-Nummer")
          *   * lOkay := .f.
          *endif
          if cDoFile == BUTTON_ON
            cLine := spacezero(snSeq,6,0)
            cLine += padr(ParName(),32)
            cLine += padr(ParStreet(),24)
            cLine += padr(ParCity(),n27or28)
            * cLine += left(PAR->CP,4)
            * cLine += padr(PLZ->Nom,23)
            if lTaxe // liste des clients assujettis
              if len(trim(TvaTrim(PAR->NoTva))) != 11
                Warning(PAR->IdPar + " " +trim(ParName())+" : ungltige belgische MWSt-Nummer")
                lOkay := .f.
              endif
              cLine += padr(TvaTrim(PAR->NoTva),11)
              cLine += spacezero(nParBase,10,SetDecPos())
              cLine += spacezero(nParTaxe,10,SetDecPos())
              cLine += space(8)
            else // innergemeinschaftliche Kunden
              cLine += padr(TvaTrim(PAR->NoTva),14)
              cLine += " " // (Code)
              cLine += spacezero(nParBase,13,SetDecPos())
              cLine += space(5) // Zeitraum falls anders
              cLine += space(5) // frei
            endif
            fwrite(fd,cLine + CR_LF)
          endif
          snTotBase += nParBase
          snTotTaxe += nParTaxe
        endif
      endif
    endif
    skip
  enddo
  PrintLine()
  cLine := padr("Total",nPad)
  cLine += " " + ntomf(snTotBase)
  if lTaxe
    cLine += " " + ntomf(snTotTaxe)
  endif
  PrintLine(cLine)
close area
if lOkay .and. !empty(cBegleit)
  SetPageHeader({||NIL})
  p_eject()
  fparse(cBegleit,NIL,"[]")
  // TplInclude(TPLTYPE_INC,cIdTpl)
endif
close printer
if cDoFile == BUTTON_ON
  if lOkay
    cLine := repl("9",6)
    if lTaxe
      cLine += spacezero(snTotBase,16,SetDecPos())
      cLine += spacezero(snTotTaxe,16,SetDecPos())
      cLine += space(51)
      cLine += TvaTrim(MemNoTva)
      cLine += space(28)
    else
      cLine += space(84)
      cLine += TvaTrim(MemNoTva)
      cLine += space(4)
      cLine += spacezero(snTotBase,13,SetDecPos())
      cLine += spacezero(snSeq,6,0)
      cLine += space(4)
    endif
    // cLine += space(4)
    fwrite(fd,cLine + CR_LF)
  endif
  fclose(fd)
endif
RETURN lOkay


FUNCTION TvaTrim(c)
local r := strtran(strtran(strtran(c,"."),"-")," ")
/** raus am 20080215
if left(r,2) == "BE".and.len(r) == 12
  r:= "BE" + substr(r,4)
endif
**/
RETURN r

FUNCTION TvaBase     ; RETURN snTotBase
FUNCTION TvaTaxe     ; RETURN snTotTaxe
FUNCTION TvaParCount ; RETURN snSeq


// used by VATLIST.XML and VATINTRA.XML
FUNCTION ParVatList(cIdCtr,cRegimes)
local i
local lOkay := .f.
local jnl
local aMvt
local a
local nParBase := 0
local nParTaxe := 0
local cIdPar := PAR->IdPar
local cIdDev := DevDefault(MemPer1)
local cDC := CtrDC(cIdCtr)
open area oVen(), oPar(), oGen(), oArt()
  lOkay := .t.
  ddSetOrder(ORD_VEN_PAR)
  softseek cIdPar
  do while lOkay .and. ! eof() .and. LstContinue() .and. VEN->IdPar == cIdPar
    if VEN->IdReg$cRegimes
      if ChkPeriode(VEN->Periode) == 0
        if (jnl := JnlLocate(VEN->IdJnl)) != NIL
          if jnl[JNL_IDCTR] == cIdCtr
            if JNLATTR_G $ jnl[JNL_ATTRIB]
              if (a := VenVnlInit(jnl)) == NIL
                SetMsg(MsgIdJnlDoc() + " : " + SetMsg())
                lOkay := .f.
              else
                aMvt := {}
                open area oVnl(VEN->Etat)
                  softseek VEN->IdJnl + VEN->IdDoc
                  do while ! eof() ;
                           .and. FIELD->IdJnl == VEN->IdJnl ;
                           .and. FIELD->IdDoc == VEN->IdDoc
                    if ! VnlVarCollect()
                      SetMsg(MsgIdJnlDoc()+" : " + SetMsg())
                      lOkay := .f.
                    endif
                    VnlMvtCollect(jnl,aMvt)
                    skip
                  enddo
                  #ifdef DEF_VENREMISE
                    VenMvtRemise(aMvt)
                  #endif
                  #ifdef DEF_FRF
                    if ! VenFrfCollect(jnl,aMvt)
                      SetMsg(MsgIdJnlDoc()+" : " + SetMsg())
                      lOkay := .f.
                    endif
                  #endif DEF_FRF
                  VenMvtRound(aMvt,jnl)
                close area
                for i := 1 to len(aMvt)
                  if aMvt[i][MVT_ISBASE]
                    if VEN->DC == cDC
                      nParBase += Db2Dev(cIdDev,VEN->Periode,aMvt[i][MVT_MONTDB])
                    else
                      nParBase -= Db2Dev(cIdDev,VEN->Periode,aMvt[i][MVT_MONTDB])
                    endif
                  else
                    if VEN->DC == cDC
                      nParTaxe += Db2Dev(cIdDev,VEN->Periode,aMvt[i][MVT_MONTDB])
                    else
                      nParTaxe -= Db2Dev(cIdDev,VEN->Periode,aMvt[i][MVT_MONTDB])
                    endif
                  endif
                next i
                VnlRestore(a)
              endif
            endif
          endif
        else
          SetMsg(MsgIdJnlDoc() + MsgJnlExist())
          lOkay := .f.
        endif
      endif
    endif
    skip
  enddo
close area
setvar("MontB",nParBase)
setvar("MontT",nParTaxe)
RETURN lOkay


#endif DEF_VEN

#ifdef DEF_FIN

**
** FinListe()
**
FUNCTION FinListe(cTplIni)
local i
* static cPrintDoc := BUTTON_ON
* static cPerClose := BUTTON_OFF
static cIdJnl := NIL
static cIdGrj := NIL
local aJnl := JnlList({|j|j[JNL_ALIAS] == "FIN"})
static cIdDoc1
static cIdDoc2
default cIdDoc1 to space(LenIdDoc())
default cIdDoc2 to space(LenIdDoc())
default cIdJnl to space(LenIdJnl())
default cIdGrj to space(LEN_IDGRJ)
default cTplIni to "LISTE"
open window (MsgFinListe()) size 8,40 help FINLISTE
say "Journal "
get cIdJnl picture PIC_ID ;
           pick PickIdJnl( ;
             NIL,cIdJnl, ;
             aJnl ;
           )
WinCr()
SayGetPeriode()
GetPreview() ; WinCr()
say "Dokumente von "
get cIdDoc1 picture PIC_ID pick PickDoc(cIdJnl,cIdDoc1)
say " bis "
get cIdDoc2 picture PIC_ID pick PickDoc(cIdJnl,cIdDoc2)
WinCr()
SetTplIni(cTplIni)
GetTplIni()
GetRange()
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
if empty(cIdJnl)
  RETURN .f. if ! WrnJnlOpen({|| ;
    JNLATTR_G $ JNL->Attrib .and. JNL->Alias == JNLALIAS_FIN ;
  })
else
  RETURN .f. if ! WrnJnlOpen({|| ;
    JNL->IdJnl == cIdJnl ;
  })
endif
for i := 1 to len(aJnl)
  if JnlMatch(aJnl[i],cIdJnl,cIdGrj)
    if aJnl[i][JNL_ALIAS] == "FIN"
      if ! FinJnlPrint( aJnl[i], cIdDoc1, cIdDoc2)
        exit
      endif
    endif
  endif
next i
RETURN .f.

#endif DEF_FIN

#ifdef DEF_IMP

**
** ImpListe()
**
FUNCTION ImpListe(cPeriode)
local i
local nHeight := 10
local cIdTax
local aTmpTot := {}
local aJnlTot := {}
local aTmpJnl := {}
local aTmpGrj := {}
static cPrintDoc := BUTTON_ON
* static cPerClose := BUTTON_OFF
static cIdJnl := NIL
static cIdGrj := NIL
local aJnl := JnlList()
static cIdDoc1
static cIdDoc2
default cIdDoc1 to space(LenIdDoc())
default cIdDoc2 to space(LenIdDoc())
default cIdJnl to space(LenIdJnl())
default cIdGrj to space(LEN_IDGRJ)
default cPeriode to space(LEN_PERIODE)
open window (MsgJournaux(UsrLang())) size nHeight,60 help JNLPRINT
say "Journalgruppe "
get cIdGrj picture PIC_ID  pick PickGrj(cIdGrj)
say " Journal "
get cIdJnl picture PIC_ID ;
           pick PickIdJnl( ;
             NIL,cIdJnl, ;
             JnlList({|j|empty(cIdGrj).or.j[JNL_IDGRJ]==cIdGrj}) ;
           )
WinCr()
SayGetPeriode()
GetPreview() ; WinCr()
say "Dokumente von "
get cIdDoc1 picture PIC_ID pick PickDoc(cIdJnl,cIdDoc1)
say " bis "
get cIdDoc2 picture PIC_ID pick PickDoc(cIdJnl,cIdDoc2)
WinCr()
SetTplIni("LISTE")
GetTplIni()
GetRange()
@ row(), col() get cPrintDoc checkbox
say MSG054
WinCr()
say "Zusammenfassung ab RJ "
get cPeriode picture "####"
say " (leer = alle)"
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
AppSaveMem()
open printer SetTplIni() ;
     preview SetPreview() ;
     range   SetRange()
for i := 1 to len(aJnl)
  if aJnl[i][JNL_ALIAS] == "IMP"
    if empty(cIdGrj) .or. aJnl[i][JNL_IDGRJ] == cIdGrj
      if empty(cIdJnl) .or. aJnl[i][JNL_IDJNL] == cIdJnl
      // if JnlMatch(aJnl[i],cIdJnl,cIdGrj)
        if ! ImpJnlPrint( ;
          aJnl[i], cPrintDoc, cIdDoc1, cIdDoc2, ;
          aTmpTot,aJnlTot,aTmpJnl,aTmpGrj ;
        )
          exit
        endif
      endif
    endif
  endif
next i
PrintLine()
ImpJnlTotal(aTmpJnl,aJnlTot,aTmpTot,aTmpGrj,cPeriode)
close printer
RETURN .f.

#endif DEF_IMP

#ifdef DEF_HST

#ifdef DEF_VEN

**
** Facturiers
**
FUNCTION VenListe(cTplIni)
local i
local nHeight := 9
local cIdTax
local aTmpTot := {}
local aTmpJnl := {}
local aTmpGrj := {}
static cPrintDoc := BUTTON_ON
* static cPerClose := BUTTON_OFF
static cIdJnl := NIL
static cIdGrj := NIL
local aJnl := JnlList({|j|j[JNL_ALIAS] == "VEN" .and. JNLATTR_G $ j[JNL_ATTRIB]})
static cIdDoc1
static cIdDoc2
default cIdDoc1 to space(LenIdDoc())
default cIdDoc2 to space(LenIdDoc())
default cIdJnl to space(LenIdJnl())
default cIdGrj to space(LEN_IDGRJ)
default cTplIni to "LISTEX"
open window (MsgVenListe(UsrLang())) size nHeight,40 help VENLISTE
say "Journal "
get cIdJnl picture PIC_ID ;
           pick PickIdJnl( ;
             NIL,cIdJnl, ;
             aJnl ;
           )
WinCr()
SayGetPeriode()
GetPreview() ; WinCr()
say "Dokumente von "
get cIdDoc1 picture PIC_ID pick PickDoc(cIdJnl,cIdDoc1)
say " bis "
get cIdDoc2 picture PIC_ID pick PickDoc(cIdJnl,cIdDoc2)
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
  RETURN .f. if ! WrnJnlOpen({|| ;
    JNLATTR_G $ JNL->Attrib .and. JNL->Alias == JNLALIAS_VEN ;
  })
else
  RETURN .f. if ! WrnJnlOpen({|| ;
    JNL->IdJnl == cIdJnl ;
  })
endif
for i := 1 to len(aJnl)
  if JnlMatch(aJnl[i],cIdJnl,cIdGrj)
    if JNLATTR_G $ aJnl[i][JNL_ATTRIB]
      if ! VenJnlPrint( aJnl[i], cPrintDoc, cIdDoc1, cIdDoc2)
        exit
      endif
    endif
  endif
next i
RETURN .f.

**
** VenJnlPrint()  - imprimer un journal
**
FUNCTION VenJnlPrint(jnl, cPrintDoc, cIdDoc1, cIdDoc2 )
local i
local lFound
local j
local cLine
local aTva := {}
local tax
local nMont
local nMontDev := 0
local nMontDevN := 0
local aMvtDoc
local aTotal := {}
local aTotalN := {}
local cTit1
local cTit2
local nPadDevise
local nPadDC
local lOkay := .t.
local nPad
local aClj := CljList(jnl)
local bJnlTest := {||JNL->IdJnl == jnl[JNL_IDJNL]}
open printer SetTplIni() ;
     preview SetPreview() ;
     range   SetRange()
cTit1 := padr(MsgIdDoc(MemLang1),LenIdJnl()+1+LEN_IDDOC)
cTit2 := repl("Ä",LenIdJnl()+1+LEN_IDDOC)
cTit1 += " " + padl("Datum",len(dtoc(UserDate())))
cTit2 += " " + repl("Ä",len(dtoc(UserDate())))
nPad := len(cTit2)
cTit1 += " " + padr("Konto",LenCompte()+1+LenLstVen() )
cTit2 += " " + repl("Ä",LenCompte()+1+LenLstVen())
cTit1 += " " + padl("Betrag Dok.",LenMont())
cTit2 += " " + repl("Ä",LenMont())
for i := 1 to len(aClj)
  cTit1 += " " + padl(aClj[i][CLJ_HEADER],LenMntF())
  cTit2 += " " + repl("Ä",LenMntF())
  aadd(aTotal, 0)
  aadd(aTotalN, 0)
next i
p_SetWidth(len(cTit2))
SetPageHeader( {|| ;
  PrintHeader( ;
    MSG028 + jnl[JNL_IDJNL] + " : " + jnl[JNL_NAME], ;
    PerText(bJnlTest) ;
  ), ;
  PrintLine(cTit1) , ;
  PrintLine(cTit2)   ;
} )
RuptInit()
MsgDisplay(jnl[JNL_IDJNL] + " " + JnlName(jnl[JNL_IDJNL]))
open area oVen(), oPar(), oGen(), oHst(), oVen()
  HST->(ddSetOrder(ORD_HST_DOC))
  softseek jnl[JNL_IDJNL] + trim(cIdDoc1)
  do while ! eof() .and. VEN->IdJnl == jnl[JNL_IDJNL]
    if TaskInter() ; lOkay := .f. ; exit ; endif
    if ! empty(cIdDoc2) .and. VEN->IdDoc > cIdDoc2 ; exit ; endif
    if ChkPeriode(VEN->Periode) == 0
      i := 0
      if ! RuptCheck(jnl,VEN->IdDoc,VEN->Periode)
        Warning(SetMsg())
      endif
      KeepBlockBegin()
      seek VEN->IdPar in PAR
      seek CtrIdGen(jnl[JNL_IDCTR]) in GEN
      select HST
      softseek VEN->IdJnl + VEN->IdDoc
      do while lOkay .and. ! eof() .and. HST->IdDoc == VEN->IdDoc ;
                           .and. HST->IdJnl == VEN->IdJnl
        if ! empty(HST->IdPar)
          cLine := VEN->IdJnl
          cLine += " " + VEN->IdDoc
          cLine += " " + dtoc(VEN->Date)
          cLine += " " + padr(VEN->IdPar + " " + ParName(),LenCompte()-1+LenLstVen())
          cLine += " " + VEN->IdReg
          cLine += " " + komma(VEN->Mont)
          if HST->DC == VEN->DC
            nMont := val(HST->Mont)
          else
            nMont := - val(HST->Mont)
          endif
          lFound := .f.
          if VEN->DC == jnl[JNL_DC]
            nMontDev += val(VEN->Mont)
            for j := 1 to len(aClj)
              if GEN->IdClj == aClj[j][CLJ_IDCLJ]
                cLine += " " + ntomf(nMont)
                aTotal[j] += nMont
                lFound := .t.
              else
                cLine += " " + space(LenMntF())
              endif
            next j
          else
            nMontDevN += val(VEN->Mont)
            for j := 1 to len(aClj)
              if GEN->IdClj == aClj[j][CLJ_IDCLJ]
                cLine += " " + ntomf(-nMont)
                aTotalN[j] += nMont
                lFound := .t.
              else
                cLine += " " + space(LenMntF())
              endif
            next j
          endif
          if ! lFound
            if ! Confirm( ;
              GEN->IdGen + MSG_WRN035 + GEN->IdClj, ;
              MsgContinue(), ;
              MSG_YES, "WRN035" ;
            )
              lOkay := .f.
            endif
          endif
          if cPrintDoc == BUTTON_ON
            PrintLine(cLine)
          endif
        else
          seek HST->IdGen in GEN
          cLine := space(nPad - LEN_IDCTF)
          cLine += GEN->IdClj
          cLine += " " + padr(HST->IdGen,LenCompte())
          cLine += " " + padr(GEN->Libell1,LenLstVen())
          cLine += " " + space(LenMont())
          if HST->DC == VEN->DC
            nMont := - val(HST->Mont)
          else
            nMont := val(HST->Mont)
          endif
          lFound := .f.
          if VEN->DC == jnl[JNL_DC]
            for j := 1 to len(aClj)
              if GEN->IdClj == aClj[j][CLJ_IDCLJ]
                cLine += " " + ntomf(nMont)
                aTotal[j] += nMont
                lFound := .t.
              else
                cLine += " " + space(LenMntF())
              endif
            next j
          else
            for j := 1 to len(aClj)
              if GEN->IdClj == aClj[j][CLJ_IDCLJ]
                cLine += " " + ntomf(-nMont)
                aTotalN[j] += nMont
                lFound := .t.
              else
                cLine += " " + space(LenMntF())
              endif
            next j
          endif
          if ! lFound
            if ! Confirm( ;
              GEN->IdGen + MSG_WRN035 + GEN->IdClj, ;
              MsgContinue(), ;
              MSG_YES, "WRN035" ;
            )
              lOkay := .f.
            endif
          endif
          if cPrintDoc == BUTTON_ON
            PrintLine(cLine)
          endif
        endif
        skip
      enddo
      select VEN
      KeepBlockEnd()
    endif
    skip
  enddo
close area
if lOkay
  PrintLine()
  cLine := padr("RECHNUNGEN",nPad)
  cLine += " " + space(LenCompte())
  cLine += " " + space(LenLstVen())
  if empty(jnl[JNL_IDDEV])
    cLine += " " + space(LenMont())
  else
    cLine += " " + komma(ntom(nMontDev,DevDecPos(jnl[JNL_IDDEV])))
  endif
  for i := 1 to len(aTotal)
    cLine += " " + ntomf(aTotal[i])
  next i
  PrintLine(cLine)
  cLine := padr("GUTSCHRIFTEN",nPad)
  cLine += " " + space(LenCompte())
  cLine += " " + space(LenLstVen())
  if empty(jnl[JNL_IDDEV])
    cLine += " " + space(LenMont())
  else
    cLine += " " + komma(ntom(nMontDevN,DevDecPos(jnl[JNL_IDDEV])))
  endif
  for i := 1 to len(aTotalN)
    cLine += " " + ntomf(aTotalN[i])
  next i
  PrintLine(cLine)
  PrintLine()
  cLine := padr("TOTAL",nPad)
  cLine += " " + space(LenCompte())
  cLine += " " + space(LenLstVen())
  if empty(jnl[JNL_IDDEV])
    cLine += " " + space(LenMont())
  else
    cLine += " " + komma(ntom(nMontDev-nMontDevN,DevDecPos(jnl[JNL_IDDEV])))
  endif
  for i := 1 to len(aTotal)
    cLine += " " + ntomf(aTotal[i] - aTotalN[i])
  next i
  PrintLine(cLine)
endif
close printer
RETURN lOkay

#endif DEF_VEN

#ifdef DEF_FIN

**
** FinJnlPrint()  - imprimer un journal
**
FUNCTION FinJnlPrint(jnl, cIdDoc1, cIdDoc2 )
local cLine
local lFirst
local nDebit := 0
local nCredit := 0
local nDocDebit
local nDocCredit
local cTit1
local cTit2
local nPadDC
local lOkay := .t.
local bJnlTest := {||JNL->IdJnl == jnl[JNL_IDJNL]}
open printer SetTplIni() ;
     preview SetPreview() ;
     range   SetRange()
cTit1 := padr(MsgIdDoc(MemLang1),LenIdJnl()+1+LEN_IDDOC)
cTit2 := repl("Ä",LenIdJnl()+1+LEN_IDDOC)
cTit1 += " " + padr(MsgDate(MemLang1),len(dtoc(UserDate())))
cTit2 += " " + repl("Ä",len(dtoc(UserDate())))
cTit1 += " " + padr(MsgCompte(MemLang1),LenCompte() + 2)
cTit2 += " " + repl("Ä",LenCompte() + 2)
cTit1 += " " + padr(MsgDescript(MemLang1),30)
cTit2 += " " + repl("Ä",30)
nPadDc := len(cTit2)
cTit1 += " " + padl(MsgDebit(MemLang1),LenMntF())
cTit2 += " " + repl("Ä",LenMntF())
cTit1 += " " + padl(MsgCredit(MemLang1),LenMntF())
cTit2 += " " + repl("Ä",LenMntF())
cTit1 += " " + padl(MsgMontDev(MemLang1),LenMont())
cTit2 += " " + repl("Ä",LenMont())
cTit1 += " " + padr("Match",LenIdJnl() + LEN_IDDOC)
cTit2 += " " + repl("Ä",LenIdJnl() + LEN_IDDOC)
p_SetWidth(len(cTit2))
SetPageHeader( {|| ;
  PrintHeader( ;
    MSG028 + jnl[JNL_IDJNL] + " : " + jnl[JNL_NAME], ;
    PerText(bJnlTest) ;
  ), ;
  PrintLine(cTit1) , ;
  PrintLine(cTit2)   ;
} )
RuptInit()
MsgDisplay(jnl[JNL_IDJNL] + " " + JnlName(jnl[JNL_IDJNL]))
open area oFin(), oFnl(), oPar(), oGen()
  softseek jnl[JNL_IDJNL] + trim(cIdDoc1)
  do while ! eof() .and. FIN->IdJnl == jnl[JNL_IDJNL] .and. LstContinue()
    if TaskInter() ; lOkay := .f. ; exit ; endif
    if ! empty(cIdDoc2) .and. FIN->IdDoc > cIdDoc2 ; exit ; endif
    MsgDisp2(FIN->IdJnl + " " + FIN->IdDoc)
    if ChkPeriode(FIN->Periode) == 0
      if FIN->Etat == DocStatClosed()
        if ! RuptCheck(jnl,FIN->IdDoc,FIN->Periode)
          Warning(SetMsg())
        endif
        lFirst := .t.
        nDocDebit := 0
        nDocCredit := 0
        select FNL
        softseek FIN->IdJnl + FIN->IdDoc
        do while !eof() .and. LstContinue() ;
          .and. FNL->IdDoc == FIN->IdDoc ;
          .and. FNL->IdJnl == FIN->IdJnl
          if lFirst
            cLine := FIN->IdJnl + " " + FIN->IdDoc
            lFirst := .f.
          else
            cLine := space( LenIdJnl() + LEN_IDDOC + 1 )
          endif
          cLine += " " + dtoc(FnlFinDate()) // FNL->Date)
          cLine += " " + FNL->IdCtr
          cLine += " " + FNL->IdCpt
          * 970317 cLine += " " + GsbFnlLibell()
          if empty(FNL->Libell)
            cLine += " " + padr(CptName(FNL->IdCtr,FNL->IdCpt),LenFnlName())
          else
            cLine += " " + FNL->Libell
          endif
          if FNL->DC == DC_DEBIT
            cLine += " " + ntomf(val(FNL->Mont))
            cLine += " " + space(LenMntF())
            nDocDebit += val(FNL->Mont)
          else
            cLine += " " + space(LenMntF())
            cLine += " " + ntomf(val(FNL->Mont))
            nDocCredit += val(FNL->Mont)
          endif
          cLine += " " + komma(FNL->MontDev)
          cLine += " " + FNL->Match
          PrintLine(cLine)
          skip
        enddo
        select FIN
        if empty(jnl[JNL_IDGEN])
          nDebit  += nDocDebit
          nCredit += nDocCredit
        else
          nDebit  += nDocDebit + nDocCredit
          nCredit += nDocCredit + nDocDebit
          cLine := space( LenIdJnl() + LEN_IDDOC + 1 )
          cLine += " " + dtoc(FIN->Date)
          cLine += "   " + jnl[JNL_IDGEN]
          cLine += " " + ltrim(komma(FIN->Mont1))
          cLine += " -> " + ltrim(komma(FIN->Mont2))
          * if jnl[JNL_IDDEV] != DevDefault(FIN->Periode)
          if FIN->IdDev != DevDefault(FIN->Periode)
            cLine += " *" + ltrim(FIN->Cours)
          endif
          cLine := padr(cLine,nPadDc)
          cLine += " " + solde2(nDocCredit,nDocDebit)
          ** im Grunde simuliere ich hier also die Ausgleichsbuchung
          PrintLine(cLine)
        endif
        PrintLine()
      endif
    endif
    skip
  enddo
  PrintLine()
  cLine := "TOTAL"
  cLine := padr(cLine,nPadDc)
  cLine += " " + ntomf(nDebit)
  cLine += " " + ntomf(nCredit)
  PrintLine(cLine)
close area
close printer
RETURN lOkay

#endif DEF_FIN

#endif DEF_HST


FUNCTION PrjMatch(cIdPrjAsked,cIdPrj)
RETURN .t. if empty(cIdPrjAsked)
cIdPrjAsked := trim(cIdPrjAsked)
RETURN .t. if left(cIdPrj,len(cIdPrjAsked)) == cIdPrjAsked
RETURN .f.


FUNCTION GetDateRange
local dBis
default sdVon to FirstOfMonth(UserDate())
default sdBis to LastOfMonth(UserDate())
@ CSR_POS say MSG062(UsrLang()) get sdVon // pick PickDate(sdVon)
@ CSR_POS say MSG063(UsrLang()) get sdBis // pick PickDate(sdBis)
RETURN NIL

FUNCTION SetDateRange(d1,d2)
sdVon := d1
sdBis := d2
RETURN NIL


FUNCTION ChkDateRange(dDate)
if empty(sdVon) .or. dDate >= sdVon
  if empty(sdBis) .or. dDate <= sdBis
    RETURN .T.
  endif
endif
RETURN .F.

FUNCTION MsgDateRange()
RETURN MSG062() + " " + dtoc(sdVon) + MSG063() + " "+ dtoc(sdBis)

FUNCTION DateRng1() ; RETURN sdVon
FUNCTION DateRng2() ; RETURN sdBis

#ifdef DEF_VEN

***
*** Statist()
***
*FUNCTION Statist()
*local nMont := 0
*local nMontB := 0
*local cTit1 := ""
*local cTit2 := ""
*local nPad
*static cIdCli := NIL
** static cIdFou := NIL
*static cIdArt1 := NIL
*static cIdArt2 := NIL
*static cIdGen1 := NIL
*static cIdGen2 := NIL
*static cIdJnl := NIL
*default cIdJnl  to space(30)
*default cIdGen1 to space(LenIdGen())
*default cIdGen2 to space(LenIdGen())
*default cIdArt1 to space(LenIdArt())
*default cIdArt2 to space(LenIdArt())
*default cIdCli  to space(LenIdPar())
*cTit1 += padr(MsgIdDoc(),LenIdJnl() + 1 + LEN_IDDOC) + " "
*cTit2 += repl("Ä",LenIdJnl() + 1 + LEN_IDDOC) + " "
*cTit1 += "V" + " "
*cTit2 += "Ä" + " "
*cTit1 += padr("Art.",LenIdArt()) + " "
*cTit2 += repl("Ä",LenIdArt()) + " "
*cTit1 += padl(MsgMenge(),LenQte()) + " "
*cTit2 += repl("Ä",LenQte()) + " "
*cTit1 += padr(MsgDesig(MemLang1),40) + " "
*cTit2 += repl("Ä",40) + " "
*nPad := len(cTit2)
*cTit1 += padl(MsgNetto(),10) + " "
*cTit2 += repl("Ä",10) + " "
*cTit1 += padl(MsgBrutto(),10) + " "
*cTit2 += repl("Ä",10)
*open window (MSG027) size 9,50 help LSTAT
*SayGetPeriode()
*GetDateRange()
*WinCr()
*say MsgJournaux(UsrLang())
*@ row(), col() get cIdJnl picture PIC_ID pick PickJnlList(cIdJnl,"F")
*WinCr()
*@ CSR_POS say "nur Partner  " get cIdCli ;
*          picture PIC_ID pick PickPar(NIL,cIdCli)
*WinCr()
** @ CSR_POS say "nur Lieferant" get cIdFou ;
**           picture PIC_ID pick PickFou(cIdFou)
** WinCr()
*@ CSR_POS say "Konten" get cIdGen1 ;
*          picture PIC_ID pick PickGen(cIdGen1)
*@ CSR_POS say " bis" get cIdGen2 ;
*          picture PIC_ID pick PickGen(cIdGen2)
*#ifdef DEF_ART
*  WinCr()
*  @ CSR_POS say "Artikel" get cIdArt1 ;
*            picture PIC_ID pick PickArt(cIdArt1)
*  @ CSR_POS say " bis" get cIdArt2 ;
*            picture PIC_ID pick PickArt(cIdArt2)
*#endif
*nKey := ReadScr()
*close window
*if nKey == K_ESC
*  RETURN NIL
*endif
*open printer LISTE width len(cTit2) ;
*TitBlock {|| ;
*  PrintHeader(MSG027) , ;
*  PrintLine(cTit1) , ;
*  PrintLine(cTit2)   ;
*}
*** Ventes
*MsgDisplay(MSG012)
*open area oVen(), oVnl(), oArt(), oGen()
*go top
*do while !eof() .and. LstContinue()
*  if VEN->Etat == DocStatClosed()
*    if ChkDateRange(VEN->Date)
*      if ChkPeriode(VEN->Periode) == 0
*        if JnlMatch(cIdJnl,VEN->IdJnl)
*          if empty(cIdCli) .or. VEN->IdPar == cIdCli
*            VenScan(1, ;
*              {|nQte| ;
*              VnlPrint(cIdGen1,cIdGen2,cIdArt1,cIdArt2,;
*                @nMont,@nMontB,val(VEN->Cours);
*              ) ;
*            } )
*          endif
*        endif
*      endif
*    endif
*  endif
*  skip
*enddo
*close area
*PrintLine(padr(upper(MsgTotal()),nPad) + ntomf(nMont) + " " + ntomf(nMontB))
*close printer
*RETURN NIL
*
***
*** VnlPrint()
***
*FUNCTION VnlPrint(cIdGen1,cIdGen2,cIdArt1,cIdArt2,nMont,nMontB,nCours)
*local lOk := .F.
*local cLine
*if VNL->Code == LNCODE_ART
*  if empty(cIdArt1) .or. VNL->IdArt >= cIdArt1
*    if empty(cIdArt2) .or. VNL->IdArt <= cIdArt2
*      lOk := .T.
*    endif
*  endif
*elseif VNL->Code == LNCODE_GEN
*  if empty(cIdGen1) .or. VNL->IdArt >= cIdGen1
*    if empty(cIdGen2) .or. VNL->IdArt <= cIdGen2
*      lOk := .T.
*    endif
*  endif
*endif
*if lOk
*  cLine := VNL->IdJnl + " "
*  cLine += VNL->IdDoc + " "
*  cLine +=  VNL->Code + " "
*  cLine +=  VNL->IdArt + " "
*  cLine +=  komma(VNL->Qte) + " "
*  cLine +=  VnlLibell() + " "
*  cLine +=  ntomf(val(VNL->cMont) * nCours) + " "
*  cLine +=  ntoTax(LnTvaC() * nCours)
*  PrintLine(cLine)
*  nMont  += val(VNL->cMont) * nCours
*  nMontB += LnTVAC() * nCours
*endif
*RETURN .T.

#endif DEF_VEN

#ifdef DEF_JNL

FUNCTION RuptInit() // cIdJnl)
scIdDoc   := NIL
scIdJnl   := NIL
scPeriode := NIL
RETURN NIL

FUNCTION RuptCheck(jnl,cIdDoc,cPeriode)
local lOkay := .t.
RETURN .t. if jnl[JNL_SEQTYPE] == SEQTYPE_M
RETURN .t. if ! JNLATTR_G $ jnl[JNL_ATTRIB]
RETURN .t. if NoCheckRupture()
if jnl[JNL_IDJNL] != scIdJnl
  scIdJnl   := jnl[JNL_IDJNL]
else
  if cIdDoc != NIL
    if cIdDoc != JnlNextIdDoc(jnl[JNL_SEQTYPE],scIdDoc,scPeriode)
      if (jnl[JNL_SEQTYPE] == SEQTYPE_E ;
          .and. left(cPeriode,2) != left(scPeriode,2) ) ;
        .or. ;
        ( jnl[JNL_SEQTYPE] == SEQTYPE_Y ;
          .and. year(PerDate1(cPeriode)) != year(PerDate1(scPeriode)) ;
        )
        // Sequenzbruch erlaubt beim Wechsel des Rechnungs- bzw. Kalenderjahres
      else
        SetMsg( ;
          scIdJnl + " " + scIdDoc + " -> " + cIdDoc + MsgRupture() ;
        )
        lOkay := .f.
      endif
    endif
  endif
endif
scIdDoc   := cIdDoc
scPeriode := cPeriode
RETURN lOkay

#endif DEF_JNL

*#ifdef DEF_STS
*
*#define STS_IDART 1
*#define STS_PAMP  2
*#define STS_QTEV  3
*#define STS_MONTV 4
*
*
***
*** ArtStsListe()
***
*FUNCTION ArtStsListe(lGrp)
*local cTit1 := padr("NøArt",LenIdArt()) + " " + padr("D‚signation",40)
*local cTit2 := repl("Ä",LenIdArt())     + " " + repl("Ä",40)
*local nMontV := 0
*local nMarge := 0
*local nCount := 0
*local cLine
*local nPad
*static cCalcul := BUTTON_ON
*cTit1 += " " + padl("QteV",6)
*cTit2 += " " + repl("Ä",6)
*cTit1 += " " + padl("PUV",10)
*cTit2 += " " + repl("Ä",10)
*nPad := len(cTit2)
*cTit1 += " " + padl("C.A.",10)
*cTit2 += " " + repl("Ä",10)
*cTit1 += " " + padl("Marge",10)
*cTit2 += " " + repl("Ä",10)
*cTit1 += " " + padl("%",7)
*cTit2 += " " + repl("Ä",7)
*open window (MSG074) size 4,60
*SayGetPeriode()
*@ row(), col() get cCalcul checkbox
*say MSG002
*nKey := ReadScr()
*close window
*RETURN .f. if nKey == K_ESC
*if cCalcul == BUTTON_ON
*  StsRebuild()
*endif
*open printer "LISTE" width len(cTit2) ;
*TitBlock {|| ;
*  PrintHeader(MSG074, PerText() ), ;
*  PrintLine(cTit1) ,;
*  PrintLine(cTit2)  ;
*}
*if lGrp
*  ddScan( {|| GrpStsPrint(@nCount,@nMontV,@nMarge,nPad) } )
*else
*  ddScan( {|| ArtStsPrint(@nCount,@nMontV,@nMarge) } )
*endif
*PrintLine()
*cLine := padr(ntrim(nCount) + " articles",nPad)
*cLine += " " + ntom(nMontV)
*cLine += " " + ntom(nMarge)
*PrintLine(cLine)
*close printer
*RETURN MnuDone()
*
*FUNCTION ArtStsPrint(nCount,nTotMontV,nTotMarge)
*local cLine := ArtIdArtF() + " " + ART->Name1
*local nQteA := 0
*local nQteV := 0
*local nMontA := 0
*local nMontV := 0
*local nMarge := 0
*local lFound := .f.
*open area oSts()
*  softseek ART->IdArt
*  do while !eof() .and. STS->IdArt == ART->IdArt
*    if ChkPeriode(STS->Periode) == 0 .and. qton(STS->QteV) != 0
*      nQteV += qton(STS->QteV)
*      nMontV += val(STS->MontV)
*      nMarge += val(STS->MontV) - qton(STS->QteV) * val(STS->PAMP)
*      lFound := .t.
*    endif
*    skip
*  enddo
*  if lFound
*    cLine += " " + ntoq(nQteV,ART->QteForm)
*    cLine += " " + ntom(nMontV/nQteV)
*    cLine += " " + ntom(nMontV)
*    cLine += " " + ntom(nMarge)
*    cLine += " " + str(100 * nMarge/nMontV,6,2) + "%"
*    PrintLine(cLine)
*    nTotMarge += nMarge
*    nTotMontV += nMontV
*    nCount++
*  endif
*close area
*RETURN .T.
*
*FUNCTION GrpStsPrint(nCount,nMontV,nMarge,nPad)
*local cLine
*local ngCount := 0
*local ngMontV := 0
*local ngMarge := 0
*open area oArt()
*  ddSetOrder ART_ORD_GRP
*  softseek GRA->iGra
*  do while !eof() .and. ART->iGra == GRA->iGra
*    ArtStsPrint(@ngCount,@ngMontV,@ngMarge)
*    skip
*  enddo
*close area
*if ngCount > 0
*  PrintLine()
*  cLine := padr(GRA->iGra + " : " + ntrim(ngCount) + " articles",nPad)
*  cLine += " " + ntom(ngMontV)
*  cLine += " " + ntom(ngMarge)
*  PrintLine(cLine)
*  nCount += ngCount
*  nMontV += ngMontV
*  nMarge += ngMarge
*endif
*RETURN .T.
*
*#endif DEF_STS

#ifdef DEF_ANW

FUNCTION AnwList()
local cTit2 := ""
open printer "LISTE" width len(cTit2)
open area oAnw()
  go top
  do while ! eof()
    PrintLine()
    skip
  enddo
close area
close printer
RETURN NIL
#endif DEF_ANW


#ifdef DEF_VEN

FUNCTION VenBatch(cIdJnl,dDate,cIdDoc1,cIdDoc2,cEvery)
* local a
local jnl
default cEvery to BUTTON_OFF
default cIdJnl to space(LenIdJnl())
default cIdDoc1 to space(LenIdDoc())
default cIdDoc2 to space(LenIdDoc())
default dDate to ctod("")
open window (MsgVenBatch()) size 6,60 help "VENBATCH"
say "Dokumente "
get cIdJnl picture PIC_ID ;
           pick PickIdJnl(NIL,cIdJnl, ;
             JnlList({|j|j[JNL_ALIAS]=="VEN"}) ;
           )
say " "
get cIdDoc1 picture PIC_ID pick PickDoc(cIdJnl,cIdDoc1)
say " bis "
get cIdDoc2 picture PIC_ID pick PickDoc(cIdJnl,cIdDoc2)
WinCr()
say "Datum "
get dDate
WinCr()
get cEvery checkbox
say " auch Dokumente, die bereits gedruckt wurden"
WinCr()
GetPreview()
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
open area oVen(), oPar(), oPlz(), oNat()
  softseek cIdJnl + trim(cIdDoc1)
  do while ! eof() .and. VEN->IdJnl == cIdJnl
    if TaskInter() ; exit ; endif
    if ! empty(cIdDoc2)
      if VEN->IdDoc > cIdDoc2 ; exit ; endif
    endif
    if VEN->Etat == DocStatClosed()
      if cEvery == BUTTON_ON .or. ! VENATTR_P $ VEN->Attrib
        if empty(dDate) .or. VEN->Date == dDate
          if (jnl := JnlLocate(VEN->IdJnl)) != NIL
            if ddRecLock()
              VenDoPrint(jnl,VenIdTpl(IfcLocate()),SetPreview(),.t.)
              unlock record
              if LstError() != PRN_DONE
                if Confirm(MsgStopBatch())
                  exit
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    skip
  enddo
close area
RETURN .f.

FUNCTION MsgStopBatch()
#ifdef LG_GERMAN
RETURN "Bearbeitung abbrechen (J/N) ?"
#else
RETURN "Interrompre le traitement (O/N) ?"
#endif

FUNCTION MsgVenBatch()
#ifdef LG_GERMAN
RETURN "Rechnungen drucken"
#else
RETURN "Imprimer factures"
#endif

#endif DEF_VEN

#ifdef DEF_MVA

#ifdef DEF_HST // nicht im ™SHZ

**
** HistAna() - Historique des comptes g‚n‚raux
**
FUNCTION HistAna(cIdHcl,cTitle,cIdFrom,cTplIni)
* local nPad
local cLine
local nIdDoc
local cTit1 := ""
local cTit2 := ""
local cIdAna   := NIL
local aHcl := ReadArray(cIdHcl+".HCL",HCL_ALEN)
local aTtl := ReadArray(cIdHcl+".TTL",TTL_ALEN)
local aTtlValues
local aAnaValues
* local aIniValues
local lOkay := .f.
* local nDocLines
* local nIniLines
static cNoMvt     := BUTTON_ON
static cIdJnl := NIL
static scIdFrom :=  NIL
static scIdTo   :=  NIL
default scIdFrom to space(LenIdAna())
default scIdTo   to space(LenIdAna())
default cTplIni to cIdHcl
default cTitle to MsgHistAna(UsrLang())
if cIdFrom  != NIL
  scIdFrom  := padr(cIdFrom,LenIdAna())
  scIdTo    := padr(cIdFrom,LenIdAna())
endif
open window (cTitle) size 8,60 help HISTANA
SayGetPeriode()
GetPreview() ; WinCr()
SetTplIni(cTplIni)
GetTplIni()
GetRange()
say MsgComptes(UsrLang()) + " "
if cIdFrom == NIL
  @ row(), col() get scIdFrom picture PIC_ID pick PickAna(scIdFrom)
  say MSG042
  @ row(), col() get scIdTo picture PIC_ID   pick PickAna(scIdTo)
  WinCR()
  @ row(), col() get cNoMvt checkbox
  say MSG003 // " aussi les comptes non mouvement‚s"
else
  say cIdFrom
endif
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
open printer (cTplIni) ;
     preview SetPreview() ;
     range   SetRange()
* cTit1 += padr("Konto",LenIdAna())
* cTit2 += repl("Ä",LenIdAna())
* cTit1 += " " + padr("Name",30)
* cTit2 += " " + repl("Ä",30)
* nPad := len(cTit2)
ClnInit(aHcl,aTtl)
aTtlValues := TtlInit(aHcl,aTtl)
cTit1 := ClnTit1(aHcl,aTtl,aTtlValues)
cTit2 := ClnTit2(aHcl,aTtl,aTtlValues)
p_SetWidth(len(cTit2))
SetPageHeader( {|| ;
  PrintHeader( ;
    cTitle, ;
    PerText({||.f.}) ;
  ), ;
  PrintLine(cTit1) , ;
  PrintLine(cTit2)   ;
} )
open area oMva(), oAna(), oPar(), oGen()
  ddSetOrder(ORD_MVA_CPTDATE)
  softseek trim(scIdFrom)
  lOkay := .t.
  do while lOkay .and. ! eof()
    if TaskInter() ; lOkay := .f. ; exit ; endif
    cIdAna := MVA->IdAna
    seek MVA->IdAna in ANA
    if ! empty(scIdTo) .and. cIdAna > scIdTo
      exit
    endif
    snHclSubCount := 0 // nDocLines
    * nIniLines := 0
    * aIniValues := TtlInit(aHcl,aTtl)
    aAnaValues := TtlInit(aHcl,aTtl)
    do while lOkay .and. ! eof() .and. MVA->IdAna == cIdAna
      seek MVA->IdGen in GEN
      if MVA->Periode < PerStart(MemPer1)
      elseif ChkPeriode(MVA->Periode) < 0
        * nIniLines++
        * if ! ClnEval(aHcl,aTtl,aIniValues,NIL,.f.)
        *   lOkay := .f.
        * elseif ! ClnEval(aHcl,aTtl,aAnaValues,NIL,.f.)
        *   lOkay := .f.
        * endif
      elseif ChkPeriode(MVA->Periode) == 0
        * if nIniLines > 0
        *   ClnTotal(aHcl,aTtl,aIniValues,nPad,"Beginnsaldo")
        * endif
        snHclSubCount++ // nDocLines++
        // und was, wenn ANAATTR_D $ ANA->Attrib ...??!
        * if nDocLines == 1
        *   cLine := MVA->IdAna
        *   cLine += " " + padr(ANA->Name1,30)
        *   PrintLine()
        * else
        *   cLine := space(LenIdAna()+1+30)
        * endif
        cLine += " "
        if ! ClnEval(aHcl,aTtl,{ aAnaValues },cLine,.t.)
          lOkay := .f.
        endif
      endif
      skip
    enddo
    ClnTotal(aHcl,aTtl,aAnaValues,space(LenIdAna()) + " " + MsgTotal() + " " + AnaName(cIdAna))
  enddo
close area
PrintLine()
ClnTotal(aHcl,aTtl,aTtlValues)
close printer
RETURN NIL

**
** BalAna() - Saldenliste ("Balance") Anaeralkonten
**
FUNCTION BalAna(cTplIni,cTitle)
local cTit1 := padr("Konto",40)
local cTit2 := repl("Ä",40)
local aAnaBal
local aTotBal := { NIL, 0, 0, 0, 0 }
local nCount := 0
local cIdAna
static cIdAna1 := NIL
static cIdAna2 := NIL
local nLen
* IndRemove()
default cTplIni to "BAL"
default cIdAna1 to space(LenIdAna())
default cIdAna2 to space(LenIdAna())
default cTitle to MsgBalAna(MemLang1)
open window (cTitle) size 7,50 help BALANA
  say "Konten von "
  get cIdAna1 picture PIC_ID pick PickAna(cIdAna1)
  say " bis "
  get cIdAna2 picture PIC_ID pick PickAna(cIdAna2)
  WinCr()
  SayGetPeriode()
  GetPreview() ; WinCr()
  SetTplIni(cTplIni)
  GetTplIni()
  GetRange()
  nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
RETURN NIL if ! WrnJnlOpen()
open printer SetTplIni() width len(cTit2) ;
     preview SetPreview() ;
     range   SetRange() ;
     TitBlock {|| ;
       PrintHeader(cTitle ,PerText()), ;
       PrintLine(cTit1) ,;
       PrintLine(cTit2)  ;
     }
cTit1 += " " + padr(MsgSoldeI(MemLang1),LenMntF())
cTit2 += " " + repl("Ä",LenMntF())
cTit1 += " " + padc("Periode",1 + LenMntF() * 2)
cTit2 += " " + repl("Ä",1 + LenMntF() * 2)
cTit1 += " " + padr(MsgSoldeF(MemLang1),LenMntF())
cTit2 += " " + repl("Ä",LenMntF())
p_SetWidth(len(cTit2))
open area oAna()
  softseek trim(cIdAna1)
  do while ! eof() .and. LstContinue()
    if ! empty(cIdAna2)
      if ANA->IdAna > cIdAna2
        exit
      endif
    endif
    if TaskInter() ; exit ; endif
    MsgDisp2(ntrim0(100 * nCount++ / lastrec(),5,0) + "%")
    nLen   := len(trim(ANA->IdAna))
    cIdAna := ANA->IdAna
    open area oCta()
      aAnaBal := { NIL, 0, 0, 0, 0 }
      softseek cIdAna
      do while ! eof() .and. CTA->IdAna == cIdAna
        CtaAddBal(aAnaBal)
        if nLen == LenIdAna()
          CtaAddBal(aTotBal)
        endif
        skip
      enddo
      BalAnaPrint( ;
        IdStruct(ANA->IdAna,1) + " " + AnaName(), ;
        aAnaBal, ;
        (nLen < LenIdAna()) ;
      )
    close area
    skip
  enddo
close area
BalAnaPrint("TOTAL",aTotBal,.t.) // ,DC_DEBIT)
close printer
RETURN NIL

FUNCTION CtaAddBal(aBal)
RETURN NIL if right(CTA->Periode,1) == CHR_255
RETURN NIL if MVA->Periode < PerStart(MemPer1)
if ChkPeriode(CTA->Periode) < 0
  aBal[BAL_INID] += val(CTA->Debit)
  aBal[BAL_INIC] += val(CTA->Credit)
elseif ChkPeriode(CTA->Periode) == 0
  aBal[BAL_MVTD] += val(CTA->Debit)
  aBal[BAL_MVTC] += val(CTA->Credit)
endif
RETURN NIL

FUNCTION BalAnaPrint(cLine,bal,lSkipLine) // ,cDC)
if bal[BAL_INID] == 0
  if bal[BAL_INIC] == 0
    if bal[BAL_MVTD] == 0
      if bal[BAL_MVTC] == 0
        RETURN NIL
      endif
    endif
  endif
endif
cLine := padr(cLine,40)
cLine += " " + solde(Bal[BAL_INID],Bal[BAL_INIC])
cLine += " " + ntomf(Bal[BAL_MVTD])
cLine += " " + ntomf(Bal[BAL_MVTC])
cLine += " " + solde(Bal[BAL_INID]+Bal[BAL_MVTD],Bal[BAL_INIC]+Bal[BAL_MVTC])
if lSkipLine
  PrintLine()
  PrintLine(cLine)
else
  PrintLine(tagged("B") + cLine + tagged("b"))
endif
RETURN NIL


FUNCTION MsgHistAna(cLangue)
RETURN "Historik Analysekonten" if cLangue == "D"
RETURN "Historique comptes analytiques"

FUNCTION MsgBalAna(cLangue)
RETURN "Saldenliste Analysekonten" if cLangue == "D"
RETURN "Balance comptes analytiques"

#endif DEF_HST

#endif DEF_MVA


