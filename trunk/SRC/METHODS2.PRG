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
**  Table of contents :
**
**  LOOP_METHODS
**  POSTEDIT_METHODS
**  OTHER_METHODS
**

#ifdef LG_FRENCH
  * #define MSG001  " : r‚gime T.V.A. invalide !"
  * #define MSG003  " : cat‚gorie invalide !"
  #define MSG005  "Tapez O pour archiver la p‚riode "
  #define MSG006  "Tapez O pour d‚sarchiver la p‚riode "
  #define MSG009  "Nom 1 : obligatoire"
  #define MSG019  "G‚n‚ration calendrier"
  #define MSG020  "G‚n‚rer jours ouvrables … partir du"
  #define MSG021  " jusqu'au"
  #define MSG022  "Tapez O pour supprimer les rendez-vous inutilis‚s :"
  #define MSG023  " rendez-vous ont ‚t‚ supprim‚s."
  #define MSG024  "!!! ACTION NON REVERSIBLE !!!"
  #define MSG025  "Cl“turer d‚finitivement les p‚riodes suivantes :"
  #define MSG026  "Cl“ture de p‚riode refus‚e"
  #define MSG027  "O pour supprimer tous les documents des p‚riodes sp‚cifi‚es !"
  #define MSG028  "Format num‚rique quantit‚"
  #define MSG029  "Unit‚ de livraison       "
  #define MSG030  "Poids unitaire Net       "
  #define MSG031  "               Brut      "
  #define MSG032  "Stock actuel "
  #define MSG034  "Code douane "
  #define MSG035  " : pr‚fixe ou format invalide !"
  #define MSG036  "Nø T.V.A. invalide !"
  #define MSG037 "P.A. moyen   "
  #define MSG038 "dernier P.A. "
  static MSG039 := "Cr‚er inventiare au "
  static MSG040 := "(Il n'y a pas d'inventiare ouvert)"
#else
  * #define MSG001  " : ungltiges MWSt-Regime !"
  * #define MSG003  " : ungltige Kategorie !"
  #define MSG005  "J um folgende Periode zu archivieren : "
  #define MSG006  "J um folgende Periode zu entarchivieren "
  #define MSG009  "Name 1 : darf nicht leer sein"
  #define MSG019  "Kalender generieren"
  #define MSG020  "Wochentage generieren vom"
  #define MSG021  " bis zum"
  #define MSG022  "J um unbenutzte Termine zu l”schen :"
  #define MSG023  " unbenutzte Termine wurden gel”scht."
  #define MSG024  "!!! UNWIDERRUFLICHE AKTION !!!"
  #define MSG025  "Folgende Perioden definitiv abschlieáen : "
  #define MSG026  "Die Periode kann nicht abgeschlossen werden"
  #define MSG027  "J um alle Dokumente der angegebenen Perioden zu l”schen :"
  #define MSG028  "Format Mengenangaben"
  #define MSG029  "Liefereinheit       "
  #define MSG030  "Gewicht (Kg) Netto  "
  #define MSG031  "            Brutto  "
  #define MSG032  "Aktueller Bestand "
  #define MSG034  "Zoll-Kode "
  #define MSG035  " : Format bzw. Vorwahl ungltig !"
  #define MSG036  "Ungltige MWSt-Nummer !"
  #define MSG037 "Mittel-EK  "
  #define MSG038 "Letzter EK "
  static MSG039 := "Inventur-Eintrag erstellen am "
  static MSG040 := "(Keine offene Inventur vorhanden)"
#endif

**
**  LOOP_METHODS
**

#ifdef DEF_VEN

**
** VenScan()
**
FUNCTION VenScan( bAction )
local lReturn := .f.
local cIdJnl := VEN->IdJnl
local cIdDoc := VEN->IdDoc
local nRecNo := recno()
open area oVnl(VEN->Etat)
  lReturn := .t.
  softseek cIdJnl + cIdDoc
  do while ! eof() .and. FIELD->IdJnl == cIdJnl ;
                   .and. FIELD->IdDoc == cIdDoc ;
                   .and. lReturn
    lReturn := eval(bAction)
    skip
  enddo
close area
goto nRecNo
RETURN lReturn


#endif DEF_VEN

*#ifdef DEF_COMPTA
*
***
*** DocMvtLoop() - loop through MVT slaves of a Document
***
*FUNCTION DocMvtLoop(cIdJnl, cIdDoc, bAction)
*local nSelect := select()
*local lReturn := .T.
*select MVT
*ddSetOrder ORD_MVT_DOC
*softseek cIdJnl + cIdDoc
*do while ! eof() .and. MVT->IdJnl == cIdJnl .and. MVT->IdDoc == cIdDoc ;
*                .and. lReturn
*  lReturn := eval(bAction)
*  skip
*enddo
*select (nSelect)
*RETURN lReturn
*
*#endif DEF_COMPTA

**
**
**  POSTEDIT_METHODS
**
**


#ifdef DEF_JNL

**
** JnlPostEdit
**
FUNCTION JnlPostEdit
local cIdGen
local lOkay
if JNL->Alias == "SYS"
  * RETURN .t. if JNL->IdJnl == padr(SYSJNL_TRM,LenIdJnl())
  * RETURN .t. if JNL->IdJnl == SYSJNL_TRA
  SetMsg(JNL->IdJnl + " : ungltiger Name fr Systemjournal !")
  RETURN .f.
endif
#ifdef DEF_VEN
  if JNL->Alias == JNLALIAS_VEN
    #ifdef DEF_GEN
      JNL->IdGen := ""
    #endif DEF_GEN
    RETURN .f. if ! CtrExist(JNL->IdCtr)
    if ! empty(JNL->IdDev)
      RETURN .f. if ! DevExist(JNL->IdDev)
    endif
    RETURN .t.
  endif
#endif DEF_VEN
#ifdef DEF_KVK
  if JNL->Alias == JNLALIAS_KVK
    RETURN .t.
  endif
#endif DEF_KVK
#ifdef DEF_TRA
  if JNL->Alias == JNLALIAS_TRA
    RETURN .t.
  endif
#endif DEF_TRA
#ifdef DEF_FIN
  if JNL->Alias == JNLALIAS_FIN
    * JNL->IdCtr := CPTTYPE_GEN
    * if ! JNL->DC $ DC_DEBIT + DC_CREDIT
    *   JNL->DC := DC_DEBIT
    * endif
    * if empty(JNL->IdGen)
    *   cIdGen := PickGen("55","Gegenkonto fr Journal " + JNL->IdJnl + " :")
    *   if cIdGen != NIL
    *     JNL->IdGen := cIdGen
    *   endif
    * endif
    * JNL->IdGen := padr(trim(JNL->IdGen),LenIdGen(),"0")
    if ! empty(JNL->IdGen)
      lOkay := .f.
      open area oGen()
        if GenExist(JNL->IdGen)
          if empty(JNL->Libell)
            JNL->Libell := GEN->Libell1
          endif
          lOkay := .t.
        endif
      close area
      RETURN .f. if ! lOkay
    endif
    RETURN DevExist(JNL->IdDev)
  endif
#endif DEF_FIN
#ifdef DEF_ODS
  if JNL->Alias == "ODS"
    JNL->IdCtr := "" // CPTTYPE_GEN
    if ! JNL->DC $ DC_DEBIT + DC_CREDIT
      JNL->DC := DC_DEBIT
    endif
    * if empty(JNL->IdGen)
    *   cIdGen := PickGen("33","Gegenkonto fr Journal " + JNL->IdJnl + " :")
    *   if cIdGen != NIL
    *     JNL->IdGen := cIdGen
    *   endif
    * endif
    #ifdef DEF_GEN
      if ! empty(JNL->IdGen)
        JNL->IdGen := padr(trim(JNL->IdGen),LenIdGen(),"0")
        lOkay := .f.
        open area oGen()
          if GenExist(JNL->IdGen)
            if empty(JNL->Libell)
              JNL->Libell := GEN->Libell1
            endif
            lOkay := .t.
          endif
        close area
        RETURN .f. if ! lOkay
      endif
    #endif
    RETURN DevExist(JNL->IdDev)
  endif
#endif DEF_ODS
#ifdef DEF_IMP
  if JNL->Alias == "IMP"
    if JNLATTR_1 $ JNL->Attrib .and. ! JNLATTR_B $ JNL->Attrib
      RETURN !SetMsg("Attribut '1' ist sinnlos ohne Attribut 'B'!")
    endif
    if ! empty(JNL->IdDev)
      RETURN .f. if ! DevExist(JNL->IdDev)
    endif
    RETURN .t.
  endif
#endif DEF_IMP
#ifdef DEF_PRE
  if JNL->Alias == "PRE"
    RETURN .t.
  endif
#endif DEF_PRE
#ifdef DEF_ANA
  if JNL->Alias == "ODA"
    JNL->IdDev := DevDefault(PerActive())
    RETURN .t.
  endif
#endif DEF_ANA
RETURN Confirm( ;
  JNL->Alias + " : ungltige Journal-Art.", ;
  MsgSure() ;
)


#endif DEF_JNL

**
** ParPostEdit()
**
FUNCTION ParPostEdit
local prt
if empty(PAR->Firme)
  SetMsg(MSG009) //  "Firme : obligatoire"
  RETURN .F.
endif
* SendConsole("PAR modify " + PAR->IdPar + " : " + ParName())
* RecSendConsole("post edit")
if (prt := PrtLocate(PAR->IdPrt)) == NIL
  SetMsg(PAR->IdPrt + MsgPrtExist() )
  RETURN .f.
endif
#ifdef DEF_TAX
  if RegLocate(PAR->IdReg) == NIL
    * PAR->IdReg := prt[PRT_IDREG]
    SetMsg(PAR->IdReg + MsgRegExist())
    RETURN .f.
  endif
#endif DEF_TAX
#ifdef DEF_DEV
if ! empty(PAR->IdDev)
  RETURN .f. if ! DevExist(PAR->IdDev)
endif
#endif DEF_DEV
#ifdef DEF_JNL
RETURN .f. if ! ParIfcExist()
#endif DEF_JNL
if ! empty(PAR->Pays)
  RETURN .f. if ! NatExist(PAR->Pays)
endif
PAR->NoTva := GetNoTva(PAR->NoTva,PAR->Pays)
// PAR->DC := prt[PRT_DC]
RETURN .t.

#ifdef LG_GERMAN
FUNCTION MsgPrtExist() ; RETURN " : ungltige Partnerart !"
#else
FUNCTION MsgPrtExist() ; RETURN " : type de compte particulier invalide !"
#endif

#ifdef DEF_JNL

FUNCTION ParIfcExist()
RETURN .t. if empty(PAR->IdMfc)
RETURN MfcExist(PAR->IdMfc) if val(PAR->IdMfc) == 0
RETURN .t.

#endif DEF_JNL


**
**
** OTHER_METHODS
**
**

#ifdef DEF_PRESTO

**
** TrmGenerate()
**
FUNCTION TrmGenerate(b)
local dFrom
local dTo
local nOrder := indexord()
local nRecNo := recno()
dFrom := UserDate() + 1
dTo   := dFrom + 30
open window (MSG019) size 3,70
@ CSR_POS say MSG020 get dFrom
@ CSR_POS say MSG021 get dTo
nKey := ReadScr()
close window
if nKey == K_ESC
  RETURN .f.
endif
do while dFrom <= dTo
  if dow(dFrom) > 1
    seek dtos(dFrom)
    if ! found()
      * append blank
      * if ddRecLock()
      if dbAddRec()
        TRM->Date := dFrom
        if dow(dFrom) == 7
          TRM->Texte := repl("±",40)
        endif
        unlock record
      else
        exit
      endif
    endif
  endif
  dFrom ++
enddo
goto nRecNo
ddRefreshAll(b)
RETURN SetMnuDone()

**
** TrmPack()
**
FUNCTION TrmPack(b)
local i := 0
local nRecNo := recno()
if ! Confirm(MSG022) // "Tapez O pour supprimer les rendez-vous inutilis‚s :")
  RETURN .f.
endif
if ! ddLock()
  goto nRecNo
  RETURN .f.
endif
go top
do while ! eof() .and. TRM->Date < UserDate()
  if empty( TRM->User + TRM->Debut + TRM->Fin + TRM->Texte )
    delete
    i++
  endif
  skip
enddo
unlock
goto nRecNo
SetMsg(ntrim(i)+ MSG023 ) // " rendez-vous ont ‚t‚ supprim‚s."
ddRefreshAll(b)
RETURN SetMnuDone()

#endif DEF_PRESTO


#ifdef DEF_IVT

**
** IvtClot()
**
FUNCTION IvtClot
local i := 0
local nPamp := 0
local nDpa  := 0
RETURN .f. if IVT->Etat == DocStatClosed()
RETURN .f. if IVT->Etat == DocStatNew()
RETURN .f. if ! Confirm("J um die Inventur zu registrieren :")
if ! Confirm( ;
  "Artikelbest„nde werden unwiderruflich ver„ndert !", ;
  MsgSure() ;
)
  RETURN .f.
endif
if ddRecLock()
  MsgDisplay(MsgWorking())
  open area oArt(), oIvl()
    if ddLock()
      select IVL
      softseek dtos(IVT->Date)
      do while ! eof() .and. IVL->Date == IVT->Date
        seek IVL->IdArt in ART
        if ! eof() in ART
          nPamp += qton(IVL->Qte) * val(IVL->PAMP)
          nDpa  += qton(IVL->Qte) * val(IVL->DPA)
          ART->cStkP := IVL->Qte
          ART->PAMP  := IVL->PAMP
          ART->DPA   := IVL->DPA
          i++
        endif
        skip
      enddo
      IVT->PAMP    := ntom(nPamp)
      IVT->DPA     := ntom(nDpa)
      IVT->Etat    := DocStatClosed()
      select ART
      unlock
    endif
  close area
endif
ddRefreshCurrent()
SetMsg(ntrim(i) + " Artikel wurden aktualisiert.")
RETURN MnuDone()


FUNCTION IvtRound(dDate)
local cFaktor := padr("1.000",10)
local cRound  := space(10)
local nDpa
local nPamp
RETURN .f. if ! IvtPreEdit()
open window ("Preise anpassen") size 4,50 help IVTROUND
say "Faktor : "
@ row(), col() get cFaktor GET_NUM
WinCr()
say "Aufrunden auf "
@ row(), col() get cRound GET_NUM
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
RETURN .f. if ! ddRecLock()
MsgDisplay(MsgWorking())
open area oIvl()
  softseek dtos(IVT->Date)
  do while ! eof() .and. IVL->Date == IVT->Date .and. ! TaskInter()
    nDpa  := val(IVL->DPA)
    nPamp := val(IVL->PAMP)
    if ! empty(cFaktor)
      nDpa  *= val(cFaktor)
      nPamp *= val(cFaktor)
    endif
    if ddRecLock()
      IVL->DPA  := ntom(sround(nDpa,val(cRound)))
      IVL->PAMP := ntom(sround(nPamp,val(cRound)))
      unlock record
    endif
    skip
  enddo
close area
IVT->Etat := DocStatNew()
unlock record
IvtIvlEdit()
RETURN MnuDone()

**
** wird benutzt fr vfield in VOLLMAR ART.MSK
**
FUNCTION sround(nValue,nRound)
RETURN nValue if nRound == 0
nValue := nValue / nRound
nValue := int(nValue + 0.999)
nValue *= nRound
RETURN nValue

#endif DEF_IVT

#ifdef DEF_ART

**
** ArtZusatz
**
*FUNCTION ArtZusatz
*local nHeight := 6
*local dDate   := NIL
*local cQte := ART->cStkP
** #ifdef DEF_INTRA
**   nHeight += 3
** #endif
*#ifdef DEF_IVT
*  open area oIvt()
*    go bottom
*    do while ! bof()
*      if IVT->Etat != DocStatClosed()
*        if ddReclock()
*          dDate := IVT->Date
*          IVT->Etat := DocStatNew()
*          unlock record
*          exit
*        endif
*      endif
*      skip -1
*    enddo
*  close area
*#endif DEF_IVT
*if ddRecLock()
*  open window size nHeight,46 // home 10,33
*  say MSG032
*  if dDate == NIL
*    say cQte
*  else
*    @ row(), col() get cQte postedit {|x| ntoq(qton(x),ART->QteForm) }
*  endif
*  WinCr()
*  say MSG037
*  @ row(), col() get ART->PAMP GET_MONTANT
*  WinCr()
*  say MSG038
*  @ row(), col() get ART->DPA GET_MONTANT
*  WinCr()
*  if dDate == NIL
*    say MSG040
*  else
*    say MSG039 + dtoc(dDate)
*  endif
*  * #ifdef DEF_INTRA
*  *   WinCr()
*  *   say MSG030
*  *   @ row(), col() get ART->PoidsN GET_NUM
*  *   WinCr()
*  *   say MSG031
*  *   @ row(), col() get ART->PoidsB GET_NUM
*  *   WinCr()
*  *   say MSG034
*  *   @ row(), col() get ART->IdInt picture PIC_ID
*  * #endif
*  nKey := ReadScr()
*  close window
*  if nKey != K_ESC .and. dDate != NIL // .and. ART->cStkP != cQte
*    ART->cStkP := cQte
*    #ifdef DEF_IVT
*    open area oIvl()
*      seek dtos(dDate) + ART->IdArt
*      if eof()
*        * append blank
*        if ! dbAddRec()
*          BREAK AREA
*        endif
*      endif
*      if ddRecLock()
*        IVL->IdArt := ART->IdArt
*        IVL->Date  := dDate
*        IVL->Qte   := cQte
*        IvlValPrix()
*        unlock record
*      endif
*    close area
*    #endif DEF_IVT
*  endif
*  unlock record
*endif
*RETURN .f.


#endif DEF_ART


FUNCTION ParPlzValidate()
local lReturn := .F.
local cPays := FIELD->Pays
local cCP   := FIELD->CP
RETURN .t. if empty(FIELD->Pays)
RETURN .t. if empty(FIELD->CP)
RETURN .f. if ! NatExist(FIELD->Pays)
seek cPays + cCP in PLZ
if eof() in PLZ
  RETURN !SetMsg("Unbekannte PLZ/Ort !") if IsReadOnly(oPlz())
  open area oPlz()
    if PlzCreate(cPays,cCP) != DDCREATE_FAIL
      cCP   := PLZ->CP
      cPays := PLZ->Pays
      lReturn := .t.
    endif
  close area
  FIELD->CP   := cCP
  FIELD->Pays := cPays
else
  lReturn := .t.
endif
ph_Refresh()
RETURN lReturn

**
** TelPostEdit()
**
FUNCTION TelPostEdit(cTel,cIdNat,cIdPlz)
local cPrefix
local cOld := cTel
* local nat := NatLocate(cIdNat)
local tlf
RETURN cTel if empty(cTel)
RETURN cTel if "." $ cTel
if PLZ->Pays + PLZ->CP != cIdNat + cIdPlz
  seek cIdNat + cIdPlz in PLZ
endif
if (tlf := TlfLocate(PLZ->Format)) == NIL
  #ifdef LG_FRENCH
    SetMsg("(Pas de contr“le du nø de t‚l‚phone)")
  #else
    SetMsg("(Keine Kontrolle der Telefonnummer)")
  #endif
  RETURN cTel
endif
cPrefix := trim(PLZ->Prefix)
cTel := strtran(cTel," ")
cTel := strtran(cTel,"/")
* cTel := strtran(cTel,".")
if left(cTel,len(cPrefix)) != cPrefix
  cTel := cPrefix + cTel
endif
if len(cTel) < val(tlf[TLF_MINLEN])
  Warning( trim(cOld) + MSG035 ) //  " : pr‚fixe ou format invalide !"
  RETURN cOld
endif
if len(cTel) > val(tlf[TLF_MAXLEN])
  Warning( trim(cOld) + MSG035 ) //  " : pr‚fixe ou format invalide !"
  RETURN cOld
endif
cTel := transform(cTel,tlf[TLF_PICTURE])
*if PLZ->Format == "1"
*  cTel := transform(cTel,"@R !!/!!!.!!.!!!!!")
*elseif PLZ->Format == "2"
*  cTel := transform(cTel,"@R !!!/!!.!!.!!!!!")
*elseif PLZ->Format == "3"
*  cTel := transform(cTel,"@R !!!/!!!.!!!!!!!")
*elseif PLZ->Format == "4"
*  cTel := transform(cTel,"@R !!/!!! !! !!!!!")
*elseif PLZ->Format == "5"
*  cTel := transform(cTel,"@R !!!/!! !! !!!!!")
*elseif PLZ->Format == "6"
*  cTel := transform(cTel,"@R !!!/!!! !!!!!!!")
*endif
*if ! empty(cPrefix)
*  if left(cTel,len(cPrefix)) != cPrefix
*    Warning( trim(cOld) + MSG035 ) //  " : pr‚fixe invalide !"
*    RETURN cOld
*  endif
*endif
RETURN cTel

**
** NB2Validate()
**
FUNCTION NB2Validate(x)
if IsCommStruct(x)
  SetMsg("Best„tigung : " + trim(x) + " ist eine strukturierte Mitteilung.")
endif
RETURN .t.

FUNCTION IsCommStruct(x)
x := strtran(x," ")
RETURN .f. if substr(x,4,1) != "/"
RETURN .f. if substr(x,9,1) != "/"
x := strtran(x,"/")
RETURN .f. if len(x) != 12
RETURN .f. if val(x) == 0
if val(left(x,10)) % 97 == 0
  RETURN .t. if val(right(x,2)) == 97
elseif val(right(x,2)) == val(left(x,10)) % 97
  RETURN .t.
endif
RETURN .f.

**
** GetNoTva()
**
FUNCTION GetNoTva(cNoTva,cIdNat)
local c
local cTvaPrefix := NatField(cIdNat,"trim(TvaPrefix)")
local cTvaPict 
* local nat := NatLocate(cIdNat)
default cNoTva to ""
RETURN padr(cNoTva,LEN_NOTVA) if empty(cNoTva)
if !isdigit(cNoTva)
  cTvaPrefix := left(cNoTva,2)
  cNoTva := substr(cNoTva,3)
endif
* if val(left(cNoTva,2)) != 0
*   cNoTva := cTvaPrefix + cNoTva
* endif
cNoTva := strtran(cNoTva," ")
cNoTva := strtran(cNoTva,".")
cNoTva := strtran(cNoTva,"-")
if cTvaPrefix == "BE"
  if len(cNoTva) == 9
    RETURN cTvaPrefix+"-0"+transform(cNoTva,"@R 999.999.999")
  elseif len(cNoTva) == 10
    RETURN cTvaPrefix+"-"+transform(cNoTva,"@R 9999.999.999")
  endif
  RETURN cTvaPrefix+"-"+cNoTva
endif
cNoTva := cTvaPrefix + cNoTva
cTvaPict := NatField(cIdNat,"TvaPict")
RETURN padr(cNoTva,LEN_NOTVA) if empty(cTvaPict)
RETURN padr(transform(cNoTva,cTvaPict),LEN_NOTVA)

**
** ValNoTva()
**
FUNCTION ValNoTva(cNoTva)
local n
RETURN .t. if empty(cNoTva)
cNoTva := trim(strtran(cNoTva,"."))
cNoTva := strtran(cNoTva,"-")
if left(cNoTva,2) == "BE"
  * 20041002 : 10stellige Unternehmensnummer
  cNoTva := substr(cNoTva,3)
  n := val(left(cNoTva,len(cNoTva)-2)) % 97
  RETURN .t. if 97 - val(right(cNoTva,2)) == n
  RETURN Confirm(MSG036,MsgSure())
elseif left(cNoTva,2) == "LU"
  n := val(substr(cNoTva,3,6)) - val(substr(cNoTva,9,2))
  RETURN .T. if n % 89 == 0
  RETURN Confirm(MSG036,MsgSure())
endif
RETURN .t.

***
***
***
*FUNCTION VenChkMarge(cIdJnl)
*local nRecNo := recno()
*local lContinue := .t.
*static cToler := NIL
*default cToler to space(10)
*open window ("Actualiser marges") size 4,42
*SayGetPeriode()
*say "Tol‚rance ñ " ; get cToler GET_MONTANT
*ReadScr()
*close window
*if nKey == K_ESC ; RETURN .f. ; endif
*go top
*do while !eof() .and. lContinue
*  if ChkPeriode(VEN->Periode) == 0 .and. VEN->IdJnl == cIdJnl ;
*                                   .and. VEN->Etat == DocStatClosed()
*    if ddRecLock()
*      if TaskInter()
*        exit
*      endif
*      open area oVnm(), oVnl(), oArt()
*        snPrixA := 0
*        lContinue := VenScan( {|nQte| VnlChkMar(nQte,val(cToler)) })
*        if lContinue
*          VEN->cPrixA := ntom(snPrixA)
*        endif
*      close area
*      unlock
*    endif
*  endif
*  skip
*enddo
*goto nRecNo
*RETURN MnuDone()
*
*FUNCTION VnlChkMar(nQte,nToler)
*local cPAMP
*if VNL->Code == LNCODE_ART
*  seek VNl->IdArt in ART
*  if empty(ART->PAMP) .or. qton(ART->cStkP) == 0 .or. ART->Suivi == BUTTON_OFF
*    cPAMP := ART->Prix2
*  else
*    cPAMP := ART->PAMP
*  endif
*  if abs( val(VNL->cPrixA) - val(cPAMP) ) > val(nToler)
*    open window ("Actualiser marge") size 8,60
*    say VNL->IdJnl + " " + VNL->IdDoc + " " + dtoc(VEN->Date)
*    WinCr()
*    say VEN->NB1
*    WinCr()
*    say ART->IdArt + " " + ART->DesigE
*    WinCr()
*    say "P.A. enregistr‚ : "
*    ReadScr()
*    close window
*    if nKey == K_ESC
*      RETURN .f.
*    endif
*  endif
*  snPrixA += nQte *
*endif
*RETURN .T.


**
** DesigGen()
**
*FUNCTION DesigGen(cLangue)
*local cDesig := ""
*do case
*case cLangue == MemLang1 ;  cDesig := GEN->Libell1
*case cLangue == MemLang2 ;  cDesig := GEN->Libell2
*endcase
*if empty(cDesig)
*  cDesig := GEN->Libell1
*endif
*RETURN trim(cDesig)


**
** DesigTac()
**
*FUNCTION DesigTac(cLangue)
*local cDesig := ""
*do case
*case cLangue == MemLang1 ;  cDesig := TAC->Libell
*case cLangue == MemLang2 ;  cDesig := TAC->Libell2
*endcase
*if empty(cDesig)
*  cDesig := TAC->Libell
*endif
*RETURN trim(cDesig)


#ifdef DEF_GRA

**
** DesigGra()
**
FUNCTION DesigGra(cLangue)
local cDesig := ""
#ifndef DEF_MONOLANG
  if cLangue == MemLang2  ;  cDesig := GRA->Name2
  elseif cLangue == MemLang3  ;  cDesig := GRA->Name3
  endif
#endif DEF_MONOLANG
if empty(cDesig)
  cDesig := GRA->Name1
endif
RETURN trim(cDesig)

#endif DEF_GRA

*#ifdef DEF_ART
*
***
*** ValPrixA() und ValPrixL()
***
*FUNCTION ValPrixL()
*local n
*local tax := NIL
*if ! empty(ART->Prix1)
*  if "+" $ ART->Prix1
*    n := val(ART->Prix2)
*    n += ( n * val(ART->Prix1) / 100 )
*    ART->Prix1 := ntom(n,MntDecPos(ART->Prix2))
*  endif
*endif
*ART->Prix3 := ntom( ;
*                brutto(val(ART->Prix1), 20.5 ) , ;
*                MntDecPos(ART->Prix1) ;
*              )
*ph_refresh()
*RETURN .T.
***
*FUNCTION ValPrixT()
*local n
*if empty(ART->Prix3)
*  ART->Prix3 := ntom( ;
*                  brutto( val(ART->Prix1), 20.5 ), ;
*                  MntDecPos(ART->Prix1) ;
*                )
*else
*  * ART->Prix3 := strtran(ART->Prix3,",",".")
*  if "+" $ ART->Prix3
*    n := val(ART->Prix2)
*    n += ( n * val(ART->Prix3) / 100 )
*    ART->Prix3 := ntom(n,MntDecPos(ART->Prix2))
*  endif
*  ART->Prix1  := ntom( ;
*                    netto( val(ART->Prix3), 20.5 ), ;
*                    MntDecPos(ART->Prix3) ;
*                  )
*endif
*ph_refresh()
*RETURN .T.
***
*FUNCTION ValPrixA()
*local n
** ART->Prix2 := strtran(ART->Prix2,",",".")
*if ! empty(ART->Prix2)
*  if "-" $ ART->Prix2
*    n := val(ART->Prix1)
*    n += ( n * val(ART->Prix2) / 100 )
*    ART->Prix2 := ntom(n,MntDecPos(ART->Prix1))
*  endif
*endif
** #ifdef DEF_ART_A
**   ART->DatPrix := UserDate()
** #endif
*ph_refresh()
*RETURN .T.
***
*
*#endif DEF_ART

#ifdef DEF_IMPCOMPAC

**
** CliImport() - import clients from COMPAC 6.7
**
*FUNCTION CliImport
*local fd := fopen(dbPath() + "\mcli.dat")
*local cLine
*local cId
*RETURN MnuDone() if fd == -1
*if ddLock()
*  do while (cLine := freadline(fd)) != NIL
*    if TaskInter()
*      exit
*    endif
*    cId := "0" + substr(cLine,1,5)
*    seek cId
*    if eof()
*      append blank
*      CLI->iCli     := cId
*      CLI->DatCrea := UserDate()
*    endif
*    CLI->Firme    := substr(cLine,9,30)
*    MsgDisplay(CLI->Firme)
*    CLI->Activite := substr(cLine,39,15)
*    CLI->Rue      := substr(cLine,54,30)
*    CLI->Pays     := substr(cLine,84,1)
*    CLI->CP       := substr(cLine,86,5)
*    if trim(CLI->Pays) $ "0123456789"
*      CLI->Pays   := "B"
*      CLI->CP     := substr(cLine,84,5)
*    endif
*    CLI->NoTva    := substr(cLine,119,14)
*    if left(CLI->NoTva,2) == "BE" .or. left(CLI->NoTva,4) == "INCO"
*      CLI->IdReg := "A"
*    elseif left(CLi->NoTva,2) == "DE"
*      CLI->IdReg := "I"
*    else
*      CLI->IdReg := "N"
*    endif
*    CLI->Tel      := substr(cLine,133,12)
*    CLI->Fax      := substr(cLine,145,12)
*    CLI->Langue   := substr(cLine,157,1)
*    if CLI->Langue  == "1"
*      CLI->Langue := "F"
*    elseif CLI->Langue  == "2"
*      CLI->Langue := "D"
*    endif
*    CLI->IdDev    := " " + substr(cLine,158,2)
*    if CLI->IdDev  == "  1" .or. CLI->IdDev  == "  0"
*      CLI->IdDev  := "" // "BEF"
*    elseif CLI->IdDev  == "  2"
*      CLI->IdDev  := "DEM"
*    endif
*    CLI->NB1      := "Imputation : " + substr(cLine,160,6)
*    CLI->NB2      := "Mode paiement : " + substr(cLine,168,4)
*    CLI->Compte   := strtran(substr(cLine,183,14),"-")
*  enddo
*  unlock
*endif
*fclose(fd)
*RETURN MnuDone()

**
** FouImport() - import fournisseurs from COMPAC 6.7 (Welsch)
**
*FUNCTION FouImport
*local fd := fopen(dbPath() + "\mfou.dat")
*local cLine
*local cId
*RETURN MnuDone() if fd == -1
*if ddLock()
*  do while (cLine := freadline(fd)) != NIL
*    if TaskInter()
*      exit
*    endif
*    cId := "0" + substr(cLine,1,5)
*    seek cId
*    if eof()
*      append blank
*      FOU->iFou     := cId
*      FOU->DatCrea := UserDate()
*    endif
*    FOU->Firme    := substr(cLine,9,30)
*    MsgDisplay(FOU->Firme)
*    FOU->Groupes  := substr(cLine,39,15)
*    FOU->Rue      := substr(cLine,54,30)
*    FOU->Pays     := substr(cLine,84,1)
*    FOU->CP       := substr(cLine,86,5)
*    if trim(FOU->Pays) $ "0123456789"
*      FOU->Pays   := "B"
*      FOU->CP     := substr(cLine,84,5)
*    endif
*    FOU->NoTva    := substr(cLine,119,14)
*    if left(FOU->NoTva,2) == "BE" .or. left(FOU->NoTva,4) == "INCO"
*      FOU->IdReg := "A"
*    elseif left(FOU->NoTva,2) == "DE"
*      FOU->IdReg := "I"
*    else
*      FOU->IdReg := "N"
*    endif
*    FOU->Fax2     := substr(cLine,133,12)
*    FOU->Fax1     := substr(cLine,145,12)
*    FOU->Langue   := substr(cLine,157,1)
*    if FOU->Langue  == "1"
*      FOU->Langue := "F"
*    elseif FOU->Langue  == "2"
*      FOU->Langue := "D"
*    endif
*    FOU->IdDev    := " " + substr(cLine,158,2)
*    if FOU->IdDev  == "  1" .or. FOU->IdDev  == "  0"
*      FOU->IdDev  := "" // "BEF"
*    elseif FOU->IdDev  == "  2"
*      FOU->IdDev  := "DEM"
*    endif
*    * FOU->Code1    := "Imputation : " + substr(cLine,160,6)
*    * FOU->NB2      := "Mode paiement : " + substr(cLine,168,4)
*    FOU->Compte1  := strtran(substr(cLine,183,14),"-")
*  enddo
*  unlock
*endif
*fclose(fd)
*RETURN MnuDone()

#endif

#ifdef DEF_IMPCUBIC

**
** CliImport() - import clients from CUBIC
**
*FUNCTION CliImport
*static cFile := NIL
*local fd
*local nPos
*local i
*local cLine
*local cId
*default cFile to "C:\CUBIC\04\SCLI04.DBF"
*cFile := padr(cFile,30)
*open window "Import Kunden CUBIC" size 3,50
*say "Dateiname "
*@ row(), col() get cFile picture PIC_ID
*nKey := ReadScr()
*close window
*RETURN NIL if nKey == K_ESC
*cFile := trim(cFile)
*if ! file(cFile)
*  Warning(cFile + " : Datei nicht gefunden !")
*  RETURN MnuDone()
*endif
*open area oCli()
*  ddSetOrder 1
*  if ddLock()
*    select 0
*    use (cFile) alias IMPORT
*    do while ! eof()
*      if TaskInter()
*        exit
*      endif
*      select CLI
*      seek padr(IMPORT->C_NUMERO,LenIdPar())
*      if eof()
*        append blank
*        CLI->iCli    := IMPORT->C_NUMERO
*        CLI->DatCrea := UserDate()
*      endif
*      CLI->Firme    := IMPORT->C_NOM1
*      MsgDisplay(CLI->Firme)
*      CLI->Activite := IMPORT->C_NOM2
*      CLI->Rue      := IMPORT->C_ADRESSE
*      nPos := 0
*      for i := 1 to 5
*        if substr(IMPORT->C_LOCALITE,i,1) $ "0123456789"
*          nPos := i
*          exit
*        endif
*      next i
*      if nPos > 1
*        CLI->Pays     := left(IMPORT->C_LOCALITE,1)
*        CLI->CP       := subst(IMPORT->C_LOCALITE,nPos,4)
*      else
*        CLI->Pays     := "B" // MemPays
*        CLI->CP       := left(IMPORT->C_LOCALITE,4)
*      endif
*      * CLI->CP       := substr(IMPORT->C_LOCALITE,3,4)
*      * if trim(CLI->Pays) $ "0123456789"
*      *   CLI->Pays   := "B"
*      *   CLI->CP     := left(IMPORT->C_LOCALITE,4)
*      * endif
*      * CLI->IdReg    := IMPORT->C_REGIME
*      CLI->IdReg    := left(IMPORT->C_NUMTVA,1)
*      CLI->NoTva    := "BE" + substr(IMPORT->C_NUMTVA,2)
*      * CLI->NoTva    := IMPORT->C_NUMTVA
*      CLI->Tel      := IMPORT->C_NUMTEL
*      CLI->Langue   := IMPORT->C_LAN
*      if empty(CLI->Langue)
*        CLI->Langue := "D"
*      endif
*      CLI->IdDev    := IMPORT->C_DEV
*      * CLI->NB1      :=
*      * CLI->NB2      :=
*      CLI->Compte   := strtran(IMPORT->C_NUMBQE,"-")
*      select IMPORT
*      skip
*    enddo
*    use
*    select CLI
*    unlock
*    ddRefreshAll()
*  endif
*close area
*RETURN MnuDone()

**
** FouImport() - import clients from CUBIC
**
*FUNCTION FouImport
*static cFile := NIL
*local fd
*local nPos
*local i
*local cLine
*local cId
*default cFile to "C:\CUBIC\04\SFOU04.DBF"
*cFile := padr(cFile,30)
*open window "Import Lieferanten CUBIC" size 3,50
*say "Dateiname "
*@ row(), col() get cFile picture PIC_ID
*nKey := ReadScr()
*close window
*RETURN NIL if nKey == K_ESC
*cFile := trim(cFile)
*if ! file(cFile)
*  Warning(cFile + " : Datei nicht gefunden !")
*  RETURN MnuDone()
*endif
*open area oFou()
*  ddSetOrder 1
*  if ddLock()
*    select 0
*    use (cFile) alias IMPORT
*    do while ! eof()
*      if TaskInter()
*        exit
*      endif
*      select FOU
*      seek padr(IMPORT->F_NUMERO,LEN_COMPTE)
*      if eof()
*        append blank
*        FOU->iFou    := IMPORT->F_NUMERO
*        FOU->DatCrea := UserDate()
*      endif
*      FOU->Firme    := IMPORT->F_NOM1
*      MsgDisplay(FOU->Firme)
*      FOU->Groupes  := IMPORT->F_NOM2
*      FOU->Rue      := IMPORT->F_ADRESSE
*      nPos := 0
*      for i := 1 to 5
*        if substr(IMPORT->F_LOCALITE,i,1) $ "0123456789"
*          nPos := i
*          exit
*        endif
*      next i
*      if nPos > 1
*        FOU->Pays     := left(IMPORT->F_LOCALITE,1)
*        FOU->CP       := subst(IMPORT->F_LOCALITE,nPos,4)
*      else
*        FOU->Pays     := "B" // MemPays
*        FOU->CP       := left(IMPORT->F_LOCALITE,4)
*      endif
*      * FOU->CP       := substr(IMPORT->F_LOCALITE,3,4)
*      * if trim(FOU->Pays) $ "0123456789"
*      *   FOU->Pays   := "B"
*      *   FOU->CP     := left(IMPORT->F_LOCALITE,4)
*      * endif
*      * FOU->IdReg    := IMPORT->F_REGIME
*      FOU->IdReg    := left(IMPORT->F_NUMTVA,1)
*      FOU->NoTva    := "BE" + substr(IMPORT->F_NUMTVA,2)
*      * FOU->NoTva    := IMPORT->F_NUMTVA
*      FOU->Fax2     := IMPORT->F_NUMTEL
*      FOU->Langue   := IMPORT->F_LAN
*      if empty(FOU->Langue)
*        FOU->Langue := "D"
*      endif
*      FOU->IdDev    := IMPORT->F_DEV
*      FOU->Compte1  := strtran(IMPORT->F_NUMBQE,"-")
*      select IMPORT
*      skip
*    enddo
*    use
*    select FOU
*    unlock
*    ddRefreshAll()
*  endif
*close area
*RETURN MnuDone()

**
** GenImport() - import clients from CUBIC
**
FUNCTION GenImport
static cFile := NIL
local fd
local nPos
local i
local cLine
local cId
default cFile to "C:\CUBIC\04\SGEN04.DBF"
cFile := padr(cFile,30)
open window "Import Kontenplan CUBIC" size 3,50
say "Dateiname "
@ row(), col() get cFile picture PIC_ID
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
cFile := trim(cFile)
if ! file(cFile)
  Warning(cFile + " : Datei nicht gefunden !")
  RETURN MnuDone()
endif
open area oGen()
  ddSetOrder(1)
  if ddLock()
    select 0
    use (cFile) alias IMPORT
    do while ! eof()
      if TaskInter()
        exit
      endif
      select GEN
      seek padr(IMPORT->G_NUMERO,LenIdGen())
      if eof()
        *append blank
        *if ddRecLock()
        if dbAddRec()
          GEN->IdGen   := IMPORT->G_NUMERO
          GEN->IdClj   := GenDefCat(GEN->IdGen)
          unlock record
        endif
      endif
      GEN->Libell1   := IMPORT->G_LIBELLE
      MsgDisplay(GEN->Libell1)
      select IMPORT
      skip
    enddo
    use
    select GEN
    unlock
    ddRefreshAll()
  endif
close area
RETURN MnuDone()

FUNCTION GenDefCat(cIdGen)
RETURN "  " if len(trim(cIdGen)) != LenIdGen()
RETURN "WA" if left(cIdGen,2) == "60"
RETURN "WA" if left(cIdGen,2) == "70"
RETURN "DV" if left(cIdGen,1) == "6"
RETURN "DV" if left(cIdGen,1) == "7"
RETURN "IN" if left(cIdGen,1) == "2"
RETURN "  "

**
** ArtImport() - import articles from CUBIC
**
FUNCTION ArtImport
static cFile := NIL
local fd
local nPos
local i
local cLine
local cId
default cFile to "C:\CUBIC\04\SSTO04.DBF"
cFile := padr(cFile,30)
open window "Import Artikel CUBIC" size 3,50
say "Dateiname "
@ row(), col() get cFile picture PIC_ID
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
cFile := trim(cFile)
if ! file(cFile)
  Warning(cFile + " : Datei nicht gefunden !")
  RETURN MnuDone()
endif
open area oArt()
  ddSetOrder(1)
  if ddLock()
    select 0
    use (cFile) alias IMPORT
    do while ! eof()
      if TaskInter()
        exit
      endif
      select ART
      seek padr(IMPORT->S_NUMERO,LenIdArt())
      if eof()
        *append blank
        *if ddRecLock()
        if dbAddRec()
          ART->IdArt   := IMPORT->S_NUMERO
          ART->DatCrea := UserDate()
          unlock record
        endif
      endif
      MsgDisplay(ART->IdArt)
      * ART->Suivi    := BUTTON_OFF
      #ifdef DEF_IPB
        ART->IdCat    := "81"
      #endif
      ART->Name1    := IMPORT->S_NOM1
      ART->Name2    := IMPORT->S_NOM2
      ART->iGra     := IMPORT->S_CATEG
      ART->IdUnt    := IMPORT->S_UNIT
      * ART->IdPar    := IMPORT->S_FOURN
      * ART->RefExt   := IMPORT->S_REFFOURN
      ART->Prix2   := str(IMPORT->S_PRACH,10,2)
      ART->Prix1   := str(IMPORT->S_PRVEN1,10,2)
      ValPrixL()
      ART->Remarq   := IMPORT->S_COMMENT
      select IMPORT
      skip
    enddo
    use
    select ART
    unlock
    ddRefreshAll()
  endif
close area
RETURN MnuDone()

#endif

#ifdef DEF_IMPFIAT

**
**  Import-Module FIAT (Garage Lesmeister)
**
**

**
** ArtImport() - import Articles Fiat (fichier S.I.R.A.) Lesmeister
**
*FUNCTION ArtImport
*static scPath := NIL
*local cPath := ""
*local nNew := 0
*local nOld := 0
*local fd
*local i
*local cLine
*local cId
*local aDir
*static cIdGra := NIL
*static cIdFou := NIL
*default cIdFou to space(LEN_COMPTE)
*default cIdGra to space(LenIdGra())
*default scPath to padr("\IMPORT\STOCKF*",40)
*do while .t.
*  open window "Import FIAT-Artikelstamm" size 5,56 help IMPFIAT
*  say "Dateiname "
*  @ row(), col() get scPath picture PIC_ID
*  WinCr()
*  say "Lieferant (neue Artikel) "
*  @ row(), col() get cIdFou picture PIC_ID pick PickFou(cIdFou)
*  WinCr()
*  say "Artikelgruppe "
*  @ row(), col() get cIdGra picture PIC_ID pick PickGra(cIdGra)
*  nKey := ReadScr()
*  close window
*  RETURN MnuDone() if nKey == K_ESC
*  aDir := directory(trim(scPath))
*  if len(aDir) == 0
*    SetMsg(trim(scPath) + " : Datei nicht gefunden !")
*    loop
*  endif
*  exit
*enddo
*ddCloseAll()
*open area oArt() exclusive
*  i := rat("\",scPath)
*  if i != 0
*    cPath := left(scPath,i)
*  endif
*  for i := 1 to len(aDir)
*    fd := fopen(cPath + aDir[i][1])
*    if fd == -1
*      Warning(cPath + aDir[i][1] + " : nicht gefunden !")
*    else
*      do while (cLine := freadline(fd)) != NIL
*        if TaskInter()
*          exit
*        endif
*        cId := padr(substr(cLine,3,10),LenIdArt())
*        cId := TrimLeading(cId,"0")
*        seek cId
*        if eof()
*          nNew++
*          append blank
*          ART->IdArt    := cId
*          ART->DatCrea  := UserDate()
*          ART->Name1    := substr(cLine,28,15)
*          ART->Name2    := substr(cLine,28,15)
*          ART->Name3    := substr(cLine,13,15)
*          ART->IdCat    := "WA"
*          ART->iGra     := cIdGra
*          ART->Suivi    := BUTTON_ON
*          ART->Remarq   := substr(cLine,49,1) + " " + substr(cLine,50,2) ;
*                           + substr(cLine,52,1) + " " ;
*                           + substr(cLine,53,4)
*        else
*          nOld++
*        endif
*        MsgDisplay(aDir[i][1] + " : " + ntrim(nNew) + " neue, " + ntrim(nOld) + " bekannte")
*        ART->Prix1   := ntom(val(substr(cLine,43,6)))
*        ART->Prix3    := ntom(val(substr(cLine,57,6)))
*        #ifdef DEF_ART_A
*          ART->DatPrix  := UserDate()
*        #endif
*        if empty(ART->RefExt)
*          ART->RefExt   := cId
*        endif
*        if empty(ART->IdPar)
*          ART->IdPar    := cIdFou
*        endif
*      enddo
*      fclose(fd)
*    endif
*  next i
*close area
*RETURN MnuDone()

FUNCTION TrimLeading(cId,cLead)
do while left(cId,1) == cLead
  cId := substr(cId,2) + " "
enddo
RETURN cId

* FUNCTION ArtFiatSpc
* local n := 0
* open area oArt()
*   if ddLock()
*     ddSetOrder
*     go top
*     do while ! eof() .and. ! TaskInter()
*       MsgDisplay(ART->IdArt)
*       ART->IdArt := TrimLeading(ART->IdArt,"0")
*       skip
*       n++
*     enddo
*   endif
*   MsgDisplay(ntrim(n) + " Artikel wurden angepaát." )
* close area
* RETURN MnuDone()

FUNCTION SubImport()
static scPath := NIL
local cPath := ""
local nNew := 0
local nOld := 0
local fd
local i
local cLine
local cId1
local cId2
local aDir
local lFound
static cIdFou := NIL
default cIdFou to space(LenIdPar())
default scPath to padr("\IMPORT\SUBST*",40)
do while .t.
  open window "Import Substitute FIAT" size 3,56 help IMPSUBS
  say "Dateiname "
  @ row(), col() get scPath picture PIC_ID
  nKey := ReadScr()
  close window
  RETURN MnuDone() if nKey == K_ESC
  aDir := directory(trim(scPath))
  if len(aDir) == 0
    SetMsg(trim(scPath) + " : Datei nicht gefunden !")
    loop
  endif
  exit
enddo
ddCloseAll()
open area oSub() exclusive
  i := rat("\",scPath)
  if i != 0
    cPath := left(scPath,i)
  endif
  for i := 1 to len(aDir)
    fd := fopen(cPath + aDir[i][1])
    if fd == -1
      Warning(cPath + aDir[i][1] + " : nicht gefunden !")
    else
      do while (cLine := freadline(fd)) != NIL
        if TaskInter()
          exit
        endif
        cId1 := padr(substr(cLine,1,10),LenIdArt())
        cId1 := TrimLeading(cId1,"0")
        cId2 := padr(substr(cLine,11,10),LenIdArt())
        cId2 := TrimLeading(cId2,"0")
        lFound := .f.
        softseek cId1
        do while ! eof() .and. SUB->IdArt1 == cId1
          if SUB->IdArt2 == cId2
            lFound := .t.
            exit
          endif
          skip
        enddo
        if lFound
          nOld++
        else
          nNew++
          *append blank
          *if ddRecLock()
          if dbAddRec()
            SUB->IdArt1   := cId1
            SUB->IdArt2   := cId2
          endif
        endif
        MsgDisplay(aDir[i][1] + " : " + ntrim(nNew) + " neue, " + ntrim(nOld) + " bekannte")
      enddo
      fclose(fd)
    endif
  next i
  * unlock
close area
ddCloseAll()
RETURN MnuDone()

#endif DEF_IMPFIAT


*FUNCTION CliConvRue
*local nPos
*local cRue
*local aRepl := {}
*local i
*local fd := fopen(".\REPLACE.CLI")
*local cLine
*local cWas
*local cWomit
*local cFor
*if fd != -1
*  do while (cLine := freadline(fd)) != NIL
*    cWas   := trim(left(cLine,35))
*    cWomit := trim(substr(cLine,36))
*    aadd(aRepl, { cWas, cWomit } )
*  enddo
*  browse array aRepl using {|x| padr(x[1],35) + "->" + padr(x[2],35) }
*  fclose(fd)
*endif
*RETURN MnuDone() if nKey == K_ESC
*RETURN MnuDone() if ! Confirm("replace starten (J/N) ?")
*ddCloseAll()
*open area oCli() exclusive
*  ddSetOrder 0
*  go top
*  do while ! eof()
*    cRue := trim(CLI->Rue)
*    if empty(CLI->RueNum)
*      if (nPos := rat(" ",cRue)) != 0
*        if val(substr(cRue,nPos)) != 0
*          CLI->RueNum := str(val(substr(cRue,nPos)),4)
*          cRue    := left(cRue,nPos)
*        endif
*      endif
*    endif
*    for i := 1 to len(aRepl)
*      if cRue == aRepl[i][1]
*        cRue := aRepl[i][2]
*        exit
*      endif
*    next i
*    CLI->Rue := cRue
*    skip
*  enddo
*close area
*RETURN .f.

#ifdef DEF_IMP

**
** BudPostEdit()
**
FUNCTION BudPostEdit
local grb
* SendConsole("BUD modify " + BUD->DC + "-" + SayIdBud(BUD->IdBud))
* RecSendConsole("post edit")
if ! empty(BUD->SubBud)
  BUD->SubBud := padl(alltrim(BUD->SubBud),2,"0")
  if SbbLocate(BUD->SubBud) == NIL
    SetMsg(BUD->SubBud + " : ungltige Haushaltsunterteilung !")
    RETURN .f.
  endif
endif
if ! empty(BUD->IdFcb)
  if FcbLocate(BUD->IdFcb) == NIL
    SetMsg(BUD->IdFcb + " : ungltige Haushaltsfunktion !")
    RETURN .f.
  endif
endif
if ! empty(BUD->CodTot)
  RETURN .f. if ! GrbExist(BUD->DC,BUD->CodTot)
  RETURN .f. if (grb := GrbLocate(BUD->CodTot)) == NIL
  BUD->GrbPos := grb[GRB_POS]
  * if left(grb[GRB_NAME],1) == "="
  *   BUD->IsSum := "S"
  * else
  *   BUD->IsSum := " "
  * endif
endif
if empty(BUD->DC_s)
  BUD->DC_s := BUD->DC
endif
if ! empty(BUD->IdBud_s)
  if ! BudIsSum(BUD->DC_s,BUD->IdBud_s)
    SetMsg(BUD->DC_S + "-" + trim(SayIdBud(BUD->IdBud_s)) + " ist kein Summenartikel !")
    RETURN .f.
  endif
endif
RETURN .t.

FUNCTION BudIsSum(cDC,cIdBud)
local lIsSum := .f.
open area oBud()
  seek cDC + cIdBud
  if BUD->IsSum == BUTTON_ON
    lIsSum := .t.
  endif
close area
RETURN lIsSum

#endif DEF_IMP


