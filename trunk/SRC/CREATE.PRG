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

#ifdef DEF_PRJ
  static scIdPrj := NIL
#endif DEF_PRJ

#ifdef DEF_HOLZ
  static scStmAttrib := ""
  static scIdArt := NIL
#endif DEF_HOLZ

* #ifdef DEF_DTL
* static scIdDto := NIL
* #endif

#ifdef LG_FRENCH
  #define MSG001  "Cr‚ation groupe d'articles"
  #define MSG002  "Aucune p‚riode active ! Configurez d'abord les p‚riodes !"
  #define MSG033  "S‚lection document du journal "
  #define MSG047  "S‚lection document du client "
  #define MSG048  "S‚lection Module de "
  #define MSG049  "Copier modules : uniquement dans document vide !"
  #define TIM050  "Cr‚ation rendez-vous"
  * static TIM051 := " recopier l'enregistrement courant"
  #define TIM052  "Recopier : "
  #define TIM056  "S‚lection partenaire pour le document … cr‚er"
  #define TIM059  "Date "
  #define TIM061  " Ech‚ance"
  #define TIM062  "Remarque "
  #define TIM068  "Document Nø "
  #define MSG073  "S‚lection document du fournisseur "
  #define TIM080  "Ce module n'existe pas."
  #define TIM081  " : Identification non valide !"
  #define TIM082  "Cr‚ation Compte G‚n‚ral"
  static TIM083 := "Identification "
  #define TIM084  "Libell‚ "
  #define TIM085  "Cat‚gorie "
  #define TIM086  "Libell‚ : obligatoire."
  * #define TIM087  "Cette identification existe d‚j…."
  #define TIM088  "D‚signation : obligatoire."
  #define TIM089  "Cr‚ation journal"
  #define TIM090  "Cr‚ation Tarif"
  #define TIM091  "Cr‚ation Code profession"
  * #define TIM092  "Allocution"
  static TIM093  := "Cr‚ation Partenaire"
  * #define TIM094  "Firme"
  * #define TIM096  "Cr‚ation Fournisseur"
  * #define TIM097  "Cr‚ation extrait "
  #define TIM098  "Ce document existe d‚j…."
  #define TIM099  "Cette p‚riode existe d‚j…."
  * #define TIM100  "Ajouter Bloc de texte"
  * #define TIM102  "D‚signation "
  #define TIM103  "Largeur "
  * #define TIM104  "recopier texte nø"
  *#define TIM105  "Ancien solde"
  *#define TIM106  "Nouveau solde"
  #define TIM107  "Cr‚ation article"
  #define TIM109  "Groupe     "
  #define MSG110  "Cr‚ation code postal"
  #define MSG111  "Pays "
  #define MSG112  "Code postal "
  #define MSG113  "Commune     "
  #define MSG114 " Ce code postal existe d‚j…."
  static MSG_ASKCOPY := "Copier l'enregistrement courant (O/N) ?"
  static MSG_IDGEN := "Nø de compte "
#endif

#ifdef LG_GERMAN
  #define MSG001  "Artikelgruppe erstellen"
  #define MSG002  "Keine Buchungsperiode aktiv !"
  #define MSG033  "Auswahl Dokument aus Journal "
  #define MSG047  "Auswahl Dokument des Partners "
  #define MSG048  "Auswahl Modul aus "
  #define MSG049  "Module kopieren : nur m”glich in leeren Dokumenten !"
  #define TIM050  "Termin erstellen"
  * static TIM051 := " aktuellen Record kopieren"
  #define TIM052  "Kopieren : "
  #define TIM056  "Auswahl Partner fr das zu erstellende Dokument"
  * #define TIM057  " aktuellen Termin kopieren"
  * #define TIM058  " fr den Kunde n "
  #define TIM059  "Datum "
  #define TIM061  " Verfalltag"
  #define TIM062  "Bemerkung "
  #define TIM068  "Dokument Nr. "
  #define MSG073  "Auswahl Dokument des Lieferanten "
  #define TIM081  " : ungltige Identifizierungsnummer !"
  #define TIM082  "Generalkonto erstellen"
  static TIM083 := "Identifikation "
  #define TIM084  "Beschreibung "
  #define TIM085  "Kategorie "
  #define TIM086  "Beschreibung : darf nicht leer sein."
  * #define TIM087  "Diese Nummer existiert schon !"
  #define TIM088  "Beschreibung : darf nicht leer sein."
  #define TIM089  "Journal einfgen"
  #define TIM090  "Tarif einfgen"
  #define TIM091  "Berufscode einfgen"
  static TIM093  := "Partner erstellen"
  * #define TIM096  "Lieferanten einfgen"
  * #define TIM097  "Kassenauszug erstellen "
  #define TIM098  "Dieses Dokument existiert schon."
  #define TIM099  "Diese Periode existiert schon."
  * #define TIM100  "Textblock einfgen"
  * #define TIM102  "Bezeichnung "
  #define TIM103  "Breite "
  * #define TIM104  "bestehenden Text kopieren :"
  *#define TIM105  "Alter Saldo "
  *#define TIM106  "Neuer Saldo "
  #define TIM107  "Artikel erstellen"
  #define TIM109  "Gruppe     "
  #define MSG110  "Neue Postleitzahl erfassen"
  #define MSG111  "Land "
  #define MSG112  "PLZ  "
  #define MSG113  "Ort  "
  #define MSG114  "Diese Postleitzahl exisitert bereits !"
  static MSG_ASKCOPY := "Aktuellen Record kopieren (J/N) ?"
  static MSG_IDGEN := "Kontonummer "
#endif

#ifdef LG_EN
  #define MSG001  "Create product group"
  #define MSG002  "There is no active booking period!"
  #define MSG033  "Select document from journal "
  #define MSG047  "Select document from partner "
  #define TIM050  "Create Entry"
  #define TIM056  "Select partner for the document to create"
  #define TIM059  "Date "
  #define TIM081  " : invalid ID !"
  #define TIM082  "Create General Account"
  static TIM083 := "Identification "
  #define TIM084  "Description "
  #define TIM086  "Description : field cannot be empty"
  #define TIM089  "Create Journal"
  #define TIM090  "Create Tariff "
  #define TIM091  "Create profession"
  static TIM093  := "Create Partner"
  #define TIM107  "Create Product"
  #define MSG110  "Create new Zip code"
  #define MSG111  "Country "
  #define MSG112  "Zip  "
  #define MSG113  "City  "
  #define MSG114  "This Zip code exists already!"
  static MSG_IDGEN := "Account # "
#endif


//
// Creation Methods
//
// They perform an APPEND BLANK and set default initial values.
// They must NOT do a refreshAll(), because the current-record-pointer must
// remain positioned on the current record !
//
//  !! When they are called, SET FILTER TO has been disabled ,
//  !! index order has been set to 1 and the whole file has been locked
//

#ifdef DEF_VEN

**
**
FUNCTION VenDocCreate( jnl, cIdDoc, cIdPar )
local ad := oVen()
local cPeriode := PerActive()
local cIdPrj := ""
RETURN DDCREATE_FAIL if cPeriode == NIL
* nicht n”tig (19980424) :
* if jnl == NIL
*   RETURN NIL if (jnl := PickJnl( ;
*     JNLALIAS_VEN,VEN->IdJnl,NIL,"Dokument erstellen") ;
*   ) == NIL
* endif
if cIdPar == NIL .and. JNLATTR_P $ jnl[JNL_ATTRIB]
  cIdPar := PickPar( ;
    CtrPrtList(jnl[JNL_IDCTR]), ;
    VEN->IdPar, ;
    TIM056 ;
  )
  RETURN DDCREATE_FAIL if cIdPar == NIL
endif
#ifdef DEF_PRJ
  if JNLATTR_J $ jnl[JNL_ATTRIB] // JnlAttrib(cIdJnl)
    RETURN DDCREATE_FAIL if (cIdPrj := PickPrj()) == NIL
  endif
#endif
* seek jnl[JNL_IDJNL] + cIdDoc
if ! IsNewId(jnl[JNL_IDJNL] + cIdDoc)
  Warning( ;
    jnl[JNL_IDJNL] + " " + cIdDoc + MsgIdExist(), ;
    NIL, ;
    "WRN036" ;
  )
  RETURN DDCREATE_FAIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
VEN->IdJnl  := jnl[JNL_IDJNL] // cIdJnl
VEN->IdDoc  := cIdDoc
VEN->Attrib := jnl[JNL_DOCATTR]
VEN->DC     := jnl[JNL_DC]
VEN->Date   := UserDate()
VEN->Periode := cPeriode
VEN->Etat   := DocStatNew()
VEN->Auteur := UserId()
#ifdef DEF_PRJ
  VEN->IdPrj := cIdPrj
#endif DEF_PRJ
if cIdPar != NIL
  VEN->IdPar  := cIdPar
  if ! VenParValidate()
    VEN->IdPar := ""
  endif
endif
* OnVenCreate()
dbcommit()
* unlock record
RETURN DDCREATE_FULL

**
** VnlCopy()
**
FUNCTION VnlCopy()
local jnl
local aVen
local cJnlDest := VEN->IdJnl
local cDocDest := VEN->IdDoc
return .f. if ! VenPreEdit()
RETURN NIL if (jnl := PickJnl( ;
  JNLALIAS_VEN,VEN->IdJnl,NIL,MsgDocCopy() ;
)) == NIL
aVen := VenSelect(jnl,VEN->IdPar,VEN->IdDoc,VEN->IdJnl)
RETURN .f. if aVen == NIL
VenCopy(aVen,cJnlDest,cDocDest) // [VEN_IDJNL],aVen[VEN_IDDOC])
if empty(VEN->NB1)
  VEN->NB1  := aVen[VEN_REMARQ]
endif
if empty(VEN->Memo)
  VEN->Memo := aVen[VEN_MEMO]
endif
ddSetUpdated(.t.)
ddGoBottom(.t.)
RETURN SetMnuDone()

FUNCTION MsgDocCopy()
#ifdef LG_GERMAN
  RETURN "Dokument kopieren..."
#else
  RETURN "Recopier un document existant..."
#endif

**
** VenCopy()
**
FUNCTION VenCopy(aVen,cIdJnl,cIdDoc) // cIdJnlSource,cIdDocSource)
local cLine
local i
local n
local aVnl := aVen[VEN_AVNL]
local nMult := 1
if !empty(VEN->Mont)
  nMult := val(VEN->Mont) / val(aVen[VEN_MONT])
endif
open area oVnl(DocStatOpen())
  KeyGoBottom(cIdJnl+cIdDoc,"FIELD->IdJnl+FIELD->IdDoc")
  cLine := NextNum(FIELD->Line)
  for i := 1 to len(aVnl)
    if dbAddRec()
      PasteRec(aVnl[i])
      FIELD->IdJnl := cIdJnl
      FIELD->IdDoc := cIdDoc
      FIELD->Line := cLine
      if nMult != 1
        n := val(GsbVnlTvac()) * nMult
        GsbVnlTvac(VnlNtom(n))
      endif
      cLine := NextNum(cLine)
      dbcommit() // 960314
      ddAfter()
      unlock record
    else
      exit
    endif
  next i
close area
RETURN NIL

**
** L„sst ein Dokument ausw„hlen und gibt Information in einem Array
** zurck.
**
STATIC FUNCTION VenSelect(jnl,cIdPar,cIdDoc,cIdJnl)
local a := NIL
local b := oVen()
cIdPar := PickPar( ;
  CtrPrtList(jnl[JNL_IDCTR]), ;
  cIdPar, ;
  MSG047 +"..." ;
)
RETURN NIL if cIdPar == NIL // [961031]
open area b, oPar()
  ddSetOrder(ORD_VEN_PAR)
  edit data b ;
            key      VEN->IdPar + VEN->IdJnl ;
            value    cIdPar + jnl[JNL_IDJNL] ;
            mode     pick                         ;
            create   {|| DDCREATE_FAIL } ;
            filter "VEN->IdJnl+VEN->IdDoc != '" + cIdJnl+cIdDoc + "'" ;
            query    "VENPAR" ;
            start bottom ;
            title (MSG047 + cIdPar)
  if ddLastReq() == DDEDIT_SELECT
    a := array(VEN_ALEN)
    a[VEN_IDJNL]  := VEN->IdJnl
    a[VEN_IDDOC]  := VEN->IdDoc
    a[VEN_REMARQ] := VEN->NB1
    a[VEN_MEMO]   := VEN->Memo
    a[VEN_MONT]   := VEN->Mont
    a[VEN_AVNL]   := {}
    open area oVnl(VEN->Etat)
      softseek VEN->IdJnl + VEN->IdDoc
      do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                       .and. FIELD->IdJnl == VEN->IdJnl
        aadd(a[VEN_AVNL], CopyRec())
        skip
      enddo
    close area
  endif
close area
RETURN a


*FUNCTION VnlCollect(cIdJnl,cIdDoc)
*local aLn := {}
*open area oVnl(VEN->Etat)
*  softseek cIdJnl + cIdDoc
*  do while !eof() .and. FIELD->IdJnl == cIdJnl ;
*                  .and. FIELD->IdDoc == cIdDoc
*    LnAddLine(aLn,.t.,1)
*    skip
*  enddo
*close area
*RETURN aLn
*
*
*
*FUNCTION LnAddLine(aLn,lRemise,nQte)
*local a := array(ALN_ALEN)
*a[ALN_CODE]   := FIELD->Code
*a[ALN_ATTRIB] := FIELD->Attrib
*a[ALN_IDART]  := FIELD->IdArt
*a[ALN_QTE]    := qton1(FIELD->Qte) * nQte
*#ifdef DEF_LNDESIG
*a[ALN_DESIG]  := FIELD->Desig
*#endif
*a[ALN_PRIXU]  := FIELD->PrixU
*#ifdef DEF_TAX
*a[ALN_IDTAX]  := FIELD->IdTax
*#endif DEF_TAX
*a[ALN_MONTT]  := FIELD->MontT
*a[ALN_MONTB]  := FIELD->cMont
** a[ALN_IDBUD]  := VnlIdBud()
*    #ifdef DEF_QTESUB
*       a[ALN_QTE1] := FIELD->Qte1
*       a[ALN_QTE2] := FIELD->Qte2
*       a[ALN_QTE3] := FIELD->Qte3
*    #endif DEF_QTESUB
*aadd(aLn,a)
*RETURN .t.

#endif DEF_VEN




*FUNCTION ParIfcLocate(cIdJnl)
*local cIdMfc
*RETURN .t. if IfcLocate(cIdJnl,PAR->IdMfc,PAR->IdPrt) != NIL
*cIdMfc := PickMfc(PAR->IdMfc,cIdJnl,PAR->IdPrt,trim(ParName()))
*RETURN .f. if cIdMfc == NIL
*if PAR->(ddRecLock())
*  PAR->IdMfc := cIdMfc
*  PAR->(dbrunlock())
*endif
*RETURN .t.

**
** GenCreate()
**
*FUNCTION GenCreate(cIdGen,cLibell1)
** local cIdCat   := GEN->IdCat
*open window (TIM082) size 4,60 help GENCREA
*do while .t.
*  WinHome()
*  say TIM083
*  @ row(), col() get cIdGen picture PIC_ID
*  WinCR()
*  say TIM084
*  @ row(), col() get cLibell1
*  * WinCR()
*  * @ CSR_POS say TIM085 get cIdCat picture PIC_ID pick PickCat(cIdCat)
*  nKey := ReadScr()
*  if nKey == K_ESC
*    close window
*    RETURN DDCREATE_FAIL
*  endif
*  * if empty(cIdGen)
*  *   SetMsg(TIM081)
*  *   loop
*  * endif
*  if empty(cLibell1)
*    SetMsg(TIM086)
*    loop
*  endif
*  seek cIdGen
*  if found()
*    SetMsg(cIdGen + MsgIdExist())
*    loop
*  endif
*  exit
*enddo
*close window
**append blank
**if ddRecLock()
*RETURN DDCREATE_FAIL if ! dbAddRec()
*GEN->IdGen := cIdGen
*GEN->Libell1 := cLibell1
*dbcommit()
*unlock record
*RETURN DDCREATE_DONE

#ifdef DEF_GEN

**
** GenCreate()
**
FUNCTION GenCreate(b)
local cIdGen   := GEN->IdGen
local cLibell1 := GEN->Libell1
local cLibell2 := GEN->Libell2
local cLibell3 := GEN->Libell3
local aBuf := CopyRec()
if ! USRATTR_B $ UsrAttrib()
  Warning(MsgNoAccess())
  RETURN DDCREATE_FAIL
endif
open window (TIM082)  size 7,50 help GENCREA
do while .t. // ! AppTerminate()
  WinHome()
  say MSG_IDGEN
  get cIdGen picture PIC_ID
  WinCR()
  @ CSR_POS say TIM084 + " :"
  WinCr() ; @ CSR_POS say MemLang1 get cLibell1
  WinCr() ; @ CSR_POS say MemLang2 get cLibell2
  WinCr() ; @ CSR_POS say MemLang3 get cLibell3
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cIdGen)
  * seek cIdGen
  * if ! eof() // found()
    SetMsg(cIdGen + MsgIdExist())
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
GEN->IdGen := cIdGen
GEN->Libell1 := cLibell1
GEN->Libell2 := cLibell2
GEN->Libell3 := cLibell3
GenPostEdit()
dbcommit()
RETURN DDCREATE_DONE

#endif DEF_GEN


*#ifdef DEF_TAX
*
**
** TaxCreate()
**
*FUNCTION TaxCreate()
*local aBuf := CopyRec()
*RETURN DDCREATE_FAIL if ! dbAddRec()
*PasteRec(aBuf)
*unlock record
*ddRefreshAll()
*RETURN DDCREATE_EDIT
*
*#endif DEF_TAX

**
** SeqCreate()
**
FUNCTION SeqCreate()
local cNewSeq := FIELD->Seq
local aBuf := CopyRec()
local nOrder := indexord()
ddSetOrder(1)
if empty(cNewSeq)
  go bottom
  cNewSeq := NextNum(FIELD->Seq)
else
  ddSetOrder()
  go top
  do while ! eof()
    if FIELD->Seq >= cNewSeq
      if ddRecLock()
        FIELD->Seq := NextNum(FIELD->Seq)
        unlock record
      endif
    endif
    skip
  enddo
  ddSetOrder(nOrder)
endif
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
FIELD->Seq := cNewSeq
RETURN DDCREATE_REFRESH

#ifdef DEF_ACF

**
** AcfCreate()
**
* FUNCTION AcfCreate(cIdCtr,cIdArt,cIdPar)
FUNCTION AcfCreate(cIdArt,cIdPar)
local cNewSeq := ACF->Seq
local aBuf := CopyRec()
// local nOrder := indexord()
local nRecNo1
local nRecNo2
local nOrder := indexord()
if cIdPar == NIL
  * RETURN DDCREATE_FAIL if nOrder != ORD_ACF_ART
  ddSetOrder(ORD_ACF_ART)
  if empty(cNewSeq)
    ddGoBottom(.f.)
    cNewSeq := NextNum(ACF->Seq)
  else
    KeyGoBottom(cIdArt,"ACF->IdArt")
    do while ! bof() .and. ACF->IdArt == cIdArt ;
                     .and. ACF->Seq >= cNewSeq
      nRecNo1 := recno()
      skip -1
      if bof()
        nRecNo2 := NIL
      else
        nRecNo2 := recno()
      endif
      goto nRecNo1
      if ddRecLock()
        ACF->Seq := NextNum(ACF->Seq)
        dbcommit() // 960314
        unlock record
      endif
      if nRecNo2 == NIL
        exit
      else
        goto nRecNo2
      endif
    enddo
  endif
  ddSetOrder(nOrder)
  RETURN DDCREATE_FAIL if ! dbAddRec()
  PasteRec(aBuf)
  ACF->Seq   := cNewSeq
  ACF->IdArt := cIdArt
else
  RETURN DDCREATE_FAIL if ! dbAddRec()
  PasteRec(aBuf)
  ACF->IdPar := cIdPar
endif
ACF->Date  := UserDate()
if empty(ACF->IdCtr)
  ACF->IdCtr := AcfIdCtr()
endif
* ACF->IdCtr := AcfIdCtr()
dbcommit() // 960314
RETURN DDCREATE_REFRESH

#endif DEF_ACF

#ifdef DEF_ART


#ifdef LG_FRENCH
  #define MSG_IDART   "Nø article "
#else
  #define MSG_IDART   "Artikelnummer "
  * #define MSG_BESTAND "  Bestand "
#endif

*FUNCTION OnArtCreate(cIdArt,cIdArtSrc,cCopier)
*RETURN eval(sblOnArtCreate,cIdArt,cIdArtSrc,cCopier)
*static sblOnArtCreate := {|cIdArt,cIdArtSrc,cCopier| ;
*#ifdef DEF_ALA
*  empty(cCopier).or.AlaReplicate(cIdArtSrc,cIdArt),;
*#endif DEF_ALA
*#ifdef DEF_ACF
*  empty(cCopier).or.AcfReplicate(cIdArtSrc,cIdArt),;
*  if cCopier == BUTTON_ON
*    RETURN DDCREATE_FAIL if ! AcfReplicate(cIdArtSrc,cIdArt)
*  endif
*#endif DEF_ACF
*}
*RETURN .t.


**
** ArtCreate()
**
FUNCTION ArtCreate(cIdGra,cIdPar)
local cIdArtSrc := ART->IdArt
local cIdArt
local cCopier := BUTTON_OFF
local i
local aBuf := CopyRec()
local aStdBuf := NIL
local nOrder := indexord()
#ifdef DEF_STK
  local aStk := StkList()
#endif DEF_STK
RETURN DDCREATE_FAIL if ! PreArtCreate()
cIdArt := NextIdArt(ART->IdArt)
open window (TIM107) size 4,50 help ARTCREA
do while .t. // ! AppTerminate()
  WinHome()
  say MSG_IDART
  get cIdArt picture PicIdArt() ;
             postedit {|x|GetIdArt(x)} ;
             valid IdArtValidate(cIdArt)
  WinCr()
  get cCopier checkbox
  say MsgCopy()
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cIdArt)
    SetMsg(cIdArt + " : " + MsgIdExist() ) // TIM087)
    loop
  endif
  exit
enddo
close window
if cCopier == BUTTON_OFF
  ddSetOrder(1)
  seek ArtCopyTemplate(cIdArt) // repl("0",LenIdArt())
  if found()
    aStdBuf := CopyRec()
  endif
  ddSetOrder(nOrder)
endif
#ifdef DEF_ALA
  if cCopier == BUTTON_ON
    RETURN DDCREATE_FAIL if ! AlaReplicate(cIdArtSrc,cIdArt)
  endif
#endif DEF_ALA
#ifdef DEF_ACF
  if cCopier == BUTTON_ON
    if MustAcfReplicate()
      RETURN DDCREATE_FAIL if ! AcfReplicate(cIdArtSrc,cIdArt)
    endif
  endif
#endif DEF_ACF
RETURN DDCREATE_FAIL if ! dbAddRec()
if cCopier == BUTTON_ON
  PasteRec(aBuf)
  ART->DPA  := ""
  #ifdef DEF_STK
    for i := 1 to len(aStk)
      if aStk[i][STK_TYPE] == STKTYPE_DATE
        &("ART->" + aStk[i][STK_IDSTK]) := ctod("")
      else
        &("ART->" + aStk[i][STK_IDSTK]) := ""
      endif
    next i
  #endif DEF_STK
elseif aStdBuf != NIL
  PasteRec(aStdBuf)
  ART->Name1 := ""
  ART->Name2 := ""
  ART->Name3 := ""
  ART->Attrib := strtran(ART->Attrib,ARTATTR_H)
  ART->Attrib := strtran(ART->Attrib,ARTATTR_R)
else
  #ifdef DEF_IPB
    ART->IdCat   := IpbCatDefault()
  #endif DEF_IPB
  * ART->Suivi   := BUTTON_ON
endif
ART->IdArt   := cIdArt
ART->DatCrea := UserDate()
if cIdGra != NIL
  ART->iGra    := cIdGra
endif
if cIdPar != NIL
  ART->IdPar    := cIdPar
endif
dbcommit()
* unlock record
RETURN DDCREATE_FULL

#ifdef DEF_ALA

FUNCTION AlaReplicate(cIdArtSrc,cIdArt)
local nRecNo
local aBuf
local lOkay := .f.
open area oAla()
  lOkay := .t.
  softseek cIdArtSrc
  do while ! eof() .and. ALA->IdArt1 == cIdArtSrc
    aBuf := CopyRec()
    nRecNo := recno()
    if dbAddRec()
      PasteRec(aBuf)
      ALA->IdArt1 := cIdArt
      unlock record
    else
      lOkay := .f.
      exit
    endif
    goto nRecNo
    skip
  enddo
close area
RETURN lOkay

#endif DEF_ALA

#ifdef DEF_ACF

FUNCTION AcfReplicate(cIdArtSrc,cIdArt)
local nRecNo
local aBuf
local lOkay := .f.
open area oAcf()
  lOkay := .t.
  softseek cIdArtSrc
  do while ! eof() .and. ACF->IdArt == cIdArtSrc
    aBuf := CopyRec()
    nRecNo := recno()
    if dbAddRec()
      PasteRec(aBuf)
      ACF->IdArt := cIdArt
      unlock record
    else
      lOkay := .f.
      exit
    endif
    goto nRecNo
    skip
  enddo
close area
RETURN lOkay

#endif DEF_ACF

**
** NextIdArt().
** Siehe auch Next_IdArt() in admin.prg
**
*FUNCTION NextIdArt(cIdArt)
*cIdArt := trim(cIdArt)
*RETURN cIdArt if len(cIdArt) == LenIdArt()
*open area oArt()
*  if len(cIdArt) == 0
*    softseek repl("9",LenIdArt())
*    if ART->IdArt > repl("9",LenIdArt())
*      skip -1
*    endif
*  else
*    KeyGoBottom( cIdArt, "left(ART->IdArt,"+ntrim(len(cIdArt))+")" )
*  endif
*  if left(ART->IdArt,len(cIdArt)) == cIdArt
*    if val(substr(ART->IdArt,len(cIdArt) + 1 )) != 0
*      cIdArt := cIdArt + NextId(substr(ART->IdArt,len(cIdArt) + 1 ))
*    endif
*  else
*    // neu [19980210]
*    cIdArt := cIdArt + NextId(repl("0",LenIdArt()-len(cIdArt)))
*  endif
*close area
*RETURN padr(cIdArt,LenIdArt())


**
** ART->order() ist auf 1 (IdArt)
**
*FUNCTION ValGra(cIdGra,cIdArt)
*if TIMATTR_G $ MemAttrib
*  softseek (cIdGra+"A")
*  skip -1
*  if left(ART->IdArt,len(cIdGra)) != cIdGra
*    goto lastrec() + 1
*  endif
*  cIdArt := NextNum(substr(ART->IdArt,len(cIdGra)+1))
*else
*  cIdArt := NextNum(cIdArt)
*endif
*RETURN .T.


#endif DEF_ART

#ifdef DEF_GRA

**
** GraCreate()
**
FUNCTION GraCreate(cIdCfn)
local ciGra := NextIdGra(GRA->iGra)
local cName1 := GRA->Name1
local cName2 := GRA->Name2
local cName3 := GRA->Name3
* local cAttrib := GRA->Attrib
open window (MSG001) size 7,46 help GRACREA
do while .t. // ! AppTerminate()
  WinHome()
  say TIM083
  get ciGra picture PicIdGra() ;
            postedit {|x|GetIdGra(x)} ;
            valid IdGraValidate(ciGra)
  * say " Attribute "
  * get cAttrib picture PIC_ID pick GraPickAttrib(cAttrib)
  WinCR()
  @ CSR_POS say TIM084 + " :"
  WinCr() ; @ CSR_POS say MemLang1 get cName1
  WinCr() ; @ CSR_POS say MemLang2 get cName2
  WinCr() ; @ CSR_POS say MemLang3 get cName3
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  * if empty(ciGra)
  *   SetMsg(ciGra + TIM081)
  *   loop
  * endif
  if ! IsNewId(ciGra)
  * seek ciGra
  * if ! eof() // found()
    SetMsg(ciGra + MsgIdExist())
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
GRA->iGra   := ciGra
GRA->Name1 := cName1
GRA->Name2 := cName2
GRA->Name3 := cName3
* #ifdef DEF_CFN
*   if cIdCfn != NIL
*     GRA->IdCfn := cIdCfn
*   endif
* #endif DEF_CFN
dbcommit()
* unlock record
RETURN DDCREATE_DONE


#endif DEF_GRA


#ifdef DEF_PRESTO

**
** TacCreate()
**
FUNCTION TacCreate()
local cIdTac
if val(TAC->IdTac) == 0
  cIdTac := space(len(TAC->IdTac))
else
  cIdTac := NextId(TAC->IdTac)
endif
open window (TIM090) size 3,40 help TACCREA
do while .t.
  WinHome()
  say TIM083
  @ row(), col() get cIdTac picture PIC_ID
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cIdTac)
  * seek cIdTac
  * if found()
    SetMsg(cIdTac + MsgIdExist())
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
TAC->IdTac := cIdTac
* unlock record 19980430
RETURN DDCREATE_FULL

**
** TrmCreate()
**
FUNCTION TrmCreate( cIdPar, cIdArt, cIdUsr, cIdAgs )
local dDate := TRM->Date
local cCopier  := BUTTON_OFF
local aBuf := CopyRec()
if empty(dDate) .and. empty(TRM->User)
  dDate := UserDate()
else
  open window (TIM050) size 4,50
  say TIM059
  // say Jour(dDate) // TIM059
  @ row(), col() get dDate
  WinCR()
  @ row(), col() get cCopier checkbox
  say MsgCopy() // MSG_COPY
  nKey := ReadScr()
  close window
  if nKey == K_ESC
    RETURN DDCREATE_FAIL
  endif
endif
*append blank
*if ddRecLock()
RETURN DDCREATE_FAIL if ! dbAddRec()
if cCopier == BUTTON_ON
  PasteRec(aBuf)
else
  TRM->User := UserId()
endif
TRM->Date := dDate // date()
if cIdPar != NIL
  TRM->IdPar := cIdPar
endif
if cIdArt != NIL
  TRM->IdTac := cIdArt
endif
if cIdAgs != NIL
  TRM->Etat := cIdAgs
endif
if cIdUsr != NIL
  TRM->User := cIdUsr
endif
dbcommit() // 960314
* unlock record 19980430
RETURN DDCREATE_FULL

#endif  DEF_PRESTO

**
** PrfCreate()
**
FUNCTION PrfCreate(b)
local cIdPrf  := space(len(PRF->IdPrf ))
local cLibell := space(len(PRF->Libell))
* local cAllocF := space(len(PRF->AllocF))
* local cAllocD := space(len(PRF->AllocD))
open window (TIM091)  size 6,70 help PRFCREA
do while .t.
  WinHome()
  say TIM083
  @ row(), col() get cIdPrf picture PIC_ID
  WinCR()
  say TIM084
  @ row(), col() get cLibell
  * WinCR()
  * @ CSR_POS say TIM092 + " F" get cAllocF
  * WinCR()
  * @ CSR_POS say space(len(TIM092)) + " D" get cAllocD
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if empty(cIdPrf)
    SetMsg(cIdPrf + TIM081)
    loop
  endif
  if empty(cLibell)
    SetMsg(TIM086) // Libell‚ : obligatoire.
    loop
  endif
  if ! IsNewId(cIdPrf)
  * seek cIdPrf
  * if found()
    SetMsg(cIdPrf + MsgIdExist())
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
PRF->IdPrf := cIdPrf
PRF->Libell := cLibell
* unlock record 19980430
RETURN DDCREATE_DONE


FUNCTION StdNextIdPar(cIdPrt)
local nRecNo := recno()
local nOrder := indexord()
local prt
local cId
if cIdPrt == NIL
  RETURN DbfNextId(oPar(),"",LenIdPar())
endif
prt := PrtLocate(cIdPrt)
// RETURN DDCREATE_FAIL if prt == NIL
if prt == NIL
  RETURN DbfNextId(oPar(),"",LenIdPar())
endif
ddSetOrder(1)
softseek prt[PRT_LASTID]
skip -1
cId := NextId(PAR->IdPar)
if cId < prt[PRT_FIRSTID]
  cId := padr(prt[PRT_FIRSTID],LenIdPar())
endif
ddSetOrder(nOrder)
goto nRecno
RETURN cId


**
** ParCreate()
**
FUNCTION ParCreate()
local nOrder := indexord()
local aBuf     := CopyRec()
local cId
local cCopier  := BUTTON_OFF
local aStdBuf  := NIL
local cFrom    := PAR->IdPar
local prt
local cIdPrt := if(nOrder==2,left(ddKeyValue(),LEN_IDPRT),NIL)
prt := PrtLocate(cIdPrt)
cId := NextIdPar(cIdPrt)
open window (TIM093) size 4,40 help PARCREA
do while .t.
  WinHome()
  @ CSR_POS say TIM083 get cId picture PIC_ID ;
            postedit {|x|GetIdPar(x)} ;
            valid IdParValidate(cId)
  WinCR()
  @ row(), col() get cCopier checkbox
  say MsgCopy() // MSG_COPY
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if empty(cId)
    SetMsg(cId + TIM081) // Identification : obligatoire.
    loop
  endif
  if ! IsNewId(cId)
    SetMsg(cId + MsgIdExist())
    loop
  endif
  exit
enddo
close window
if cCopier == BUTTON_OFF
  ddSetOrder(1)
  seek repl("0",LenIdPar())
  if found()
    aStdBuf := CopyRec()
  endif
  ddSetOrder(nOrder)
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
if cCopier == BUTTON_ON
  PasteRec(aBuf)
elseif aStdBuf != NIL
  PasteRec(aStdBuf)
  PAR->Attrib := strtran(PAR->Attrib,PARATTR_H)
  PAR->Firme  := ""
else
  PAR->Pays    := MemPays
  * PAR->IdDev   := DevDefault(PerActive())
  PAR->Langue  := MemLang1
  #ifdef DEF_TAX
    if prt != NIL
      PAR->IdReg   := prt[PRT_IDREG]
    endif
  #endif DEF_TAX
endif
#ifdef DEF_TAX
  if empty(PAR->IdReg)
    if prt != NIL
      PAR->IdReg := prt[PRT_IDREG]
    endif
  endif
#endif DEF_TAX
if cIdPrt != NIL
  if prt != NIL
    PAR->IdPrt   := prt[PRT_ID]
  endif
endif
PAR->IdPar   := cId
PAR->DatCrea := UserDate()
#ifdef DEF_HST
   PAR->MvpDate := ctod("")
#endif DEF_HST
PAR->Debit   := ""
PAR->Credit  := ""
dbcommit()
* unlock record 19980430
* #ifdef DEF_CONSOLE
*   SendConsole("PAR create " + cId)
* #endif DEF_CONSOLE
RETURN DDCREATE_FULL


#ifdef DEF_FIN

**
** FinCreate()
**
FUNCTION FinCreate( jnl, cIdDoc, cPeriode ) // , aLn, cLibell )
local cSolde1
local nOrder := indexord()
default cPeriode to PerActive() // PickPer(jnl[JNL_IDJNL],UserDate())
RETURN DDCREATE_FAIL if cPeriode == NIL
ddSetOrder(1)
KeyGoBottom( jnl[JNL_IDJNL], "FIN->IdJnl" )
ddSetOrder(nOrder)
if ! eof() .and. FIN->Etat != DocStatClosed()
  RETURN DDCREATE_FAIL if ! Confirm( ;
    MsgPrevDoc() + MsgNotClosed(), MsgDocCreate(), ;
    MSG_NO, "WRN018" ;
)
endif
cSolde1 := FIN->Mont2
if ! IsNewId(jnl[JNL_IDJNL] + cIdDoc)
* seek jnl[JNL_IDJNL] + cIdDoc
* if ! eof()
  Warning( ;
    jnl[JNL_IDJNL] + " " + cIdDoc + MsgDocExist(), ;
    NIL, "WRN014" ;
  )
  RETURN DDCREATE_FAIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
FIN->IdDoc    := cIdDoc
FIN->IdJnl    := jnl[JNL_IDJNL]
FIN->Date     := UserDate()
FIN->Periode  := cPeriode
if empty(jnl[JNL_IDDEV]) .or. JNLATTR_B $ jnl[JNL_ATTRIB]
  FIN->IdDev    := DevDefault(FIN->Periode)
else
  FIN->IdDev    := jnl[JNL_IDDEV]
endif
DocDevValidate()
* FIN->Cours    := DocDevCours(FIN->IdDev,FIN->Periode)
* FIN->Etat     := DocStatNew()
if JNLATTR_S $ jnl[JNL_ATTRIB]
  FIN->Mont1    := cSolde1
endif
dbcommit()
* unlock record
RETURN DDCREATE_FULL

#endif DEF_FIN

#ifdef DEF_ODS

FUNCTION ParOdsCreate(cIdPar,jnl)
RETURN DocCreate( jnl, {|cIdDoc| OdsCreate(jnl,cIdDoc,cIdPar) } )

**
** OdsCreate()
**
FUNCTION OdsCreate( jnl, cIdDoc, cIdPar )
local cPeriode := PerActive() // PickPer(jnl[JNL_IDJNL],UserDate())
local nOrder := indexord()
RETURN DDCREATE_FAIL if cPeriode == NIL
ddSetOrder(1)
KeyGoBottom( jnl[JNL_IDJNL], "ODS->IdJnl" )
ddSetOrder(nOrder)
if ! eof() .and. ODS->Etat != DocStatClosed()
  RETURN DDCREATE_FAIL if ! Confirm( ;
    MsgPrevDoc() + MsgNotClosed(), MsgDocCreate(), ;
    MSG_NO, "WRN018" ;
)
endif
if ! IsNewId(jnl[JNL_IDJNL] + cIdDoc)
* seek jnl[JNL_IDJNL] + cIdDoc
* if ! eof()
  Warning( ;
    jnl[JNL_IDJNL] + " " + cIdDoc + MsgDocExist(), ;
    NIL, "WRN014" ;
  )
  RETURN DDCREATE_FAIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
ODS->IdDoc    := cIdDoc
ODS->IdJnl    := jnl[JNL_IDJNL]
ODS->Date     := UserDate()
ODS->Periode  := cPeriode
ODS->Etat     := DocStatNew()
if cIdPar != NIL
  ODS->IdPar    := cIdPar
endif
dbcommit()
* unlock record 19980430
RETURN DDCREATE_FULL

*FUNCTION ArtOdsAppend(cIdJnl)
*local jnl := JnlLocate(cIdJnl)
*
***
*** OdsAppend()
***
*FUNCTION OdsAppend( jnl, cIdDoc, cIdPar )
*local cPeriode := PerActive() // PickPer(jnl[JNL_IDJNL],UserDate())
*local nOrder := indexord()
*RETURN DDCREATE_FAIL if cPeriode == NIL
*ddSetOrder(1)
*KeyGoBottom( jnl[JNL_IDJNL], "ODS->IdJnl" )
*ddSetOrder(nOrder)
*if ! eof() .and. ODS->Etat != DocStatClosed()
*  RETURN DDCREATE_FAIL if ! Confirm( ;
*    MsgPrevDoc() + MsgNotClosed(), MsgDocCreate(), ;
*    MSG_NO, "WRN018" ;
*)
*endif
*if ! IsNewId(jnl[JNL_IDJNL] + cIdDoc)
** seek jnl[JNL_IDJNL] + cIdDoc
** if ! eof()
*  Warning( ;
*    jnl[JNL_IDJNL] + " " + cIdDoc + MsgDocExist(), ;
*    NIL, "WRN014" ;
*  )
*  RETURN DDCREATE_FAIL
*endif
*RETURN DDCREATE_FAIL if ! dbAddRec()
*ODS->IdDoc    := cIdDoc
*ODS->IdJnl    := jnl[JNL_IDJNL]
*ODS->Date     := UserDate()
*ODS->Periode  := cPeriode
*ODS->Etat     := DocStatNew()
*if cIdPar != NIL
*  ODS->IdPar    := cIdPar
*endif
*dbcommit()
** unlock record 19980430
*RETURN DDCREATE_FULL

#endif DEF_ODS

*#ifdef DEF_SHT
*
***
*** BalCreate()
***
*FUNCTION BalCreate(cIdSht)
*RETURN DDCREATE_FAIL if ! dbAddRec()
*BAL->IdSht := cIdSht
** unlock record
*RETURN DDCREATE_EDIT
*
*#endif DEF_SHT

#ifdef DEF_IVT

**
** IVT
**
FUNCTION IvtCreate()
local dDate := UserDate()
local cId
local cComplet := BUTTON_OFF
local cAlways  := BUTTON_OFF
local nOrder := indexord()
ddSetOrder(1)
open window "Inventur erstellen" size 5,40 help INVCREA
do while .t.
  say "Datum "
  @ row(), col() get dDate
  WinCr()
  @ row(), col() get cComplet checkbox
  say " automatisch generieren"
  WinCr()
  say "   "
  @ row(), col() get cAlways checkbox when cComplet == BUTTON_ON
  say " auch Artikel ohne Bestand"
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  seek dtos(dDate)
  if eof()
    exit
  else
    SetMsg("Eine Inventur besteht bereits am " + dtoc(dDate))
  endif
enddo
close window
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
IVT->Etat := DocStatNew()
IVT->Date := dDate
if cComplet == BUTTON_ON
  IvtIvlGenerate(dDate,cAlways)
endif
IvtIvlEdit()
dbcommit()
* unlock record
RETURN DDCREATE_DONE

FUNCTION IvtIvlGenerate(dDate,cAlways)
local nQte
local nPamp
local lAppend
local nCount := 0
MsgDisplay("Inventur wird generiert...")
open area oArt(), oMvs(), oIvl()
  go top
  do while ! eof() .and. ! TaskInter()
    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if ! ARTATTR_S $ ART->Attrib
      nQte   := 0
      nPamp  := 0
      if cAlways == BUTTON_OFF
        select MVS
        softseek ART->IdArt
        do while ! eof() .and. MVS->IdArt == ART->IdArt
          if MVS->Date <= dDate
            if MVS->DC == DC_CREDIT
              nQte   += qton(MVS->Qte)
              nPamp  += val(MVS->Mont)
            else
              nQte   -= qton(MVS->Qte)
              nPamp  -= val(MVS->Mont)
            endif
          endif
          skip
        enddo
        lAppend := (nQte != 0)
        select ART
      else
        lAppend := .t.
      endif
      if lAppend
        select IVL
        if dbAddRec()
          IVL->Date  := dDate
          IVL->IdArt := ART->IdArt
          IVL->Qte   := ntoq(nQte,ART->QteForm)
          if nQte != 0
            IVL->PAMP  := ntom(nPamp / nQte)
          endif
          unlock record
        else
          exit
        endif
        select ART
      endif
    endif
    skip
  enddo
close area
RETURN NIL


FUNCTION IvlValPrix
local nQte  := 0
local nPamp := 0
if empty(IVL->Qte) .or. empty(IVL->PAMP)
  open area oMvs()
    softseek IVL->IdArt
    do while ! eof() .and. MVS->IdArt == IVL->IdArt
      if MVS->Date <= IVL->Date
        if MVS->DC == DC_CREDIT
          nQte   += qton(MVS->Qte)
          nPamp  += val(MVS->Mont)
        else
          nQte   -= qton(MVS->Qte)
          nPamp  -= val(MVS->Mont)
        endif
      endif
      skip
    enddo
  close area
  if empty(IVL->Qte)
    IVL->Qte := ntoq(nQte,ART->QteForm)
  endif
  if empty(IVL->PAMP)
    IVL->PAMP := ntom(nPamp / nQte)
  endif
endif
RETURN NIL

**
** IvlCreate()
**
FUNCTION IvlCreate(dDate)
if ! IvtPreEdit()
  RETURN DDCREATE_FAIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
IVL->Date := dDate
dbcommit() // 960314
* unlock record
RETURN DDCREATE_EDIT

#endif DEF_IVT


/*********** PEROLD

**
** PerCreate()
**
*FUNCTION PerCreate(b)
*local cPeriode
*local lOK := .F.
*local dDateD
*local dDateF
** local nRecNo := recno()
** go bottom
*cPeriode := NextNum(PER->Periode)
*dDateD := PER->DateF + 1
*dDateF := SkipMonth(dDateD,1) - 1
*open window "Ouverture de p‚riode comptable"  size 5,60 help PERCREA
*do while .t.
*  WinHome()
*  say TIM083
*  @ row(), col() get cPeriode picture PIC_ID
*  WinCr()
*  say TIM059 + " de d‚but "
*  @ row(), col() get dDateD
*  WinCr()
*  say space(len(TIM059)) + "      fin "
*  @ row(), col() get dDateF
*  WinCr()
*  nKey := ReadScr()
*  if nKey == K_ESC
*    close window
*    * goto nRecNo
*    RETURN DDCREATE_FAIL
*  endif
*  if empty(cPeriode)
*    SetMsg(cPeriode + TIM081) // Identification : obligatoire.
*    loop
*  endif
*  seek cPeriode
*  if ! eof()
*    SetMsg(cPeriode + MsgIdExist())
*    loop
*  endif
*  exit
*enddo
*close window
*RETURN DDCREATE_FAIL if ! dbAddRec()
*PER->Periode := cPeriode
*PER->Etat    := PSTAT_OPEN //  DocStatOpen()
*PER->DateD   := dDateD
*PER->DateF   := dDateF
** unlock record
*RETURN DDCREATE_DONE
*
*PEROLD ***********/


**
** PLZ
**
FUNCTION PlzCreate(cPays,cCP)
local cNom := PLZ->Nom
local nReturn := DDCREATE_FAIL
if HasDlm("ZIP")
  RETURN DDCREATE_FAIL if ! dbAddRec()
  RETURN DDCREATE_DONE
endif
open window (MSG110) size 5,45 help PLZCREA
do while .t.
  WinHome()
  @ row(), col() say MSG111 get cPays picture PIC_ID ;
                            pick PickNat(cPays) ;
                            valid NatValidate(cPays)
  WinCr()
  @ row(), col() say MSG112 get cCP picture PIC_ID
  WinCr()
  @ row(), col() say MSG113 get cNom
  nKey := ReadScr()
  if nKey == K_ESC
    exit
  endif
  * seek cPays + cCP
  * if eof()
  if ! IsNewId(cPays + cCP)
    SetMsg(MSG114) // "Ce code postal existe d‚j….")
    loop
  endif
  if dbAddRec()
    PLZ->Pays := cPays
    PLZ->CP   := cCp
    PLZ->Nom  := cNom
    PLZ->Format := NatField(cPays,"IdTlf")
    dbcommit()
    unlock record
    nReturn := DDCREATE_REFRESH
    exit
  endif
enddo
close window
RETURN nReturn


#ifdef DEF_FIN

**
** FnlCopy()
**
FUNCTION FnlCopy()
local aLn
local cJnlDest := FIN->IdJnl
local cDocDest := FIN->IdDoc
RETURN .f. if ! FinPreEdit()
aLn := FinSelect(FIN->IdJnl)
RETURN .f. if aLn == NIL
FnlGenerate(aLn,cJnlDest,cDocDest)
ddSetUpdated(.t.) // oFnl()[AD_UPDATED] := .t.
ddGoBottom(.t.)
RETURN MnuDone()


**
** FinSelect()
**
** L„sst ein Dokument ausw„hlen und gibt Information in einem Array
** zurck.
**
FUNCTION FinSelect(cIdJnl)
local a := NIL
local b := oFin()
RETURN NIL if (cIdJnl := PickIdJnl("FIN",cIdJnl)) == NIL
open area b
  edit data b ;
            key FIN->IdJnl value cIdJnl ;
            mode     pick                         ;
            start    bottom                       ;
            create   {|| DDCREATE_FAIL }          ;
            query    "FIN" ;
            title (MSG033 + cIdJnl)
  if ddLastReq() == DDEDIT_SELECT
    a := FnlCollect(FIN->IdJnl,FIN->IdDoc)
  endif
close area
RETURN a

FUNCTION FnlCollect(cIdJnl,cIdDoc)
local aLn := {}
local a
open area oFnl()
  softseek cIdJnl + cIdDoc
  do while ! eof() .and. FNL->IdJnl == cIdJnl ;
                   .and. FNL->IdDoc == cIdDoc
    a := array(FNL_ALEN)
    a[FNL_CPTTYPE] := FNL->IdCtr
    a[FNL_COMPTE]  := FNL->IdCpt
    a[FNL_LIBELL]  := FNL->Libell
    a[FNL_MONT]    := FNL->Mont
    a[FNL_MONTDEV] := FNL->MontDev
    a[FNL_IDDEV]   := FNL->IdDev
    a[FNL_DC]      := FNL->DC
    a[FNL_MATCH]   := FNL->Match
    #ifdef DEF_ANAFIN
    a[FNL_IDANA]   := FnlIdAna() // FNL->IdAna
    #endif DEF_ANAFIN
    aadd(aLn,a)
    skip
  enddo
close area
RETURN aLn

**
** FnlGenerate()
**
** generates 0 to n lines in FNL using contents of aLn
**
FUNCTION FnlGenerate(aLn,cIdJnl,cIdDoc)
local i
local cIdOp
RETURN .f. if aLn == NIL
MsgDisplay(cIdJnl + " " + cIdDoc + MsgGenerating() )
KeyGoBottom(cIdJnl + cIdDoc, "FNL->IdJnl+FNL->IdDoc" )
cIdOp := NextId(FNL->Line)
for i := 1 to len(aLn)
  if dbAddRec()
    FNL->IdJnl   := cIdJnl
    FNL->IdDoc   := cIdDoc
    FNL->Line    := cIdOp
    FNL->IdCtr   := aLn[i][FNL_CPTTYPE]
    FNL->IdCpt   := aLn[i][FNL_COMPTE]
    FNL->Libell  := aLn[i][FNL_LIBELL]
    FNL->Mont    := aLn[i][FNL_MONT]
    FNL->MontDev := aLn[i][FNL_MONTDEV]
    FNL->IdDev   := aLn[i][FNL_IDDEV]
    FNL->DC      := aLn[i][FNL_DC]
    FNL->Match   := aLn[i][FNL_MATCH]
    if !empty(aLn[i][FNL_DATE])
      FNL->Date   := aLn[i][FNL_DATE]
    endif
    #ifdef DEF_ANAFIN
      if HasOption("ANA")
        FNL->IdAna := aLn[i][FNL_IDANA]
      endif
    #endif DEF_ANAFIN
    FnlPostEdit()
    FnlAfter()
    unlock record
  else
    exit
  endif
  cIdOp := NextId(cIdOp)
next i
ddSetUpdated(.t.)
RETURN .t.

#endif DEF_FIN

#ifdef DEF_MSG

**
** MsgCreate()
**
FUNCTION MsgCreate(cIdPar,cIdUsr,cIdPrj)
local aBuf    := CopyRec()
local cCopier := BUTTON_OFF
local dDate   := UserDate()
local cIdTpl  := if(eof(),MemTxtCor,MSG->IdTxt)
open window ("Korrespondenz erstellen") size 5,50
say "Datum "
get dDate
WinCr()
@ row(), col() say "Dokumentmaske "
@ row(), col() get cIdTpl picture PIC_ID ;
               pick PickTpl(TPLTYPE_MSG,cIdTpl)
WinCr()
@ row(), col() get cCopier checkbox
say MsgCopy() // MSG_COPY
nKey := ReadScr()
close window
RETURN DDCREATE_FAIL if nKey == K_ESC
RETURN DDCREATE_FAIL if ! dbAddRec()
if cCopier == BUTTON_ON
  PasteRec(aBuf)
endif
MSG->IdTxt  := cIdTpl
MSG->Date   := dDate
MSG->IdUsr  := UserId()
if cIdPar != NIL
  MSG->IdPar := cIdPar
endif
if cIdUsr != NIL
  MSG->IdUsr := cIdUsr
endif
#ifdef DEF_PRJ
  if cIdPrj != NIL
    MSG->IdPrj := cIdPrj
  endif
#endif DEF_PRJ
RETURN DDCREATE_FULL if CurQry(QRY_IDMSK) != NIL
RETURN DDCREATE_REFRESH

#endif DEF_MSG

#ifdef DEF_SPC

**
** SpcCreate()
**
FUNCTION SpcCreate(cIdPar,cIdArt)
RETURN DDCREATE_FAIL if ! dbAddRec()
if cIdPar != NIL ; SPC->IdPar  := cIdPar ; endif
if cIdArt != NIL ; SPC->IdArt  := cIdArt ; endif
SPC->Date  := UserDate()
* unlock record
RETURN DDCREATE_EDIT

#endif DEF_SPC

#ifdef DEF_SUB

**
** SubCreate()
**
FUNCTION SubCreate(cIdArt)
RETURN DDCREATE_FAIL if ! dbAddRec()
SUB->IdArt1  := cIdArt
* unlock record
RETURN DDCREATE_EDIT

#endif DEF_SUB

#ifdef DEF_ANW

**
** AnwCreate()
**
FUNCTION AnwCreate(cIdPar,dDate)
RETURN DDCREATE_FAIL if ! dbAddRec()
if cIdPar != NIL
  ANW->IdPar := cIdPar
endif
if dDate != NIL
  ANW->Date := dDate
endif
* unlock record
RETURN DDCREATE_EDIT

#endif DEF_ANW

#ifdef DEF_PIN

**
** PinCreate()
**
FUNCTION PinCreate(cIdPrj)
local cCode := PIN->Code
RETURN DDCREATE_FAIL if ! dbAddRec()
if cIdPrj != NIL
  PIN->IdPrj := cIdPrj
endif
PIN->Date := UserDate()
PIN->Code := cCode
* unlock record
RETURN DDCREATE_EDIT

#endif DEF_PIN

#ifdef DEF_HOLZ

**
** StmCreate()
**
FUNCTION StmCreate(cIdJnl,cIdDoc,cIdPrj)
local cIdStm := STM->IdStm
local cLine := NIL
if cIdJnl != NIL
  open area oStm()
    ddSetOrder(StmOrder(cIdJnl)) // ORD_STM_DOC
    KeyGoBottom( ;
      cIdDoc, ;
      "STM->"+cIdJnl+"IdDoc" ;
    )
    cLine := NextNum(&("STM->"+cIdJnl+"Line"))
  close area
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
* if saBuf != NIL
*   PasteRec(saBuf)
* endif
if empty(cIdStm)
  STM->IdStm := NextIdStm()
endif
if cIdJnl != NIL
  * STM->IdJnl := cIdJnl
  * STM->IdDoc := cIdDoc
  &("STM->"+cIdJnl+"IdDoc") := cIdDoc
  &("STM->"+cIdJnl+"Line") := cLine
  * STM->Line  := cLine
endif
if empty(cIdPrj)
  if scIdPrj != NIL ; STM->IdPrj := scIdPrj ; endif
else
  STM->IdPrj := cIdPrj
endif
if scIdArt != NIL ; STM->IdArt := scIdArt ; endif
STM->Attrib := scStmAttrib
if ! empty(OnStmCreate())
  ActExec(OnStmCreate())
endif
* unlock record
RETURN DDCREATE_REFRESH

FUNCTION NextIdStm(cNew)
static scIdStm := NIL
if scIdStm == NIL
  open area oStm()
    go bottom
    scIdStm := STM->IdStm
  close area
endif
if cNew == NIL
  scIdStm := str(val(scIdStm)+1,LenIdStm())
  RETURN scIdStm
endif
scIdStm := cNew // str(val(scIdStm)+1,LenIdStm())
RETURN NIL

FUNCTION StmPostEdit()
if empty(STM->IdStm)
  STM->IdStm := NextIdStm()
else
  NextIdStm(STM->IdStm)
endif
scIdPrj := STM->IdPrj
scIdArt := STM->IdArt
scStmAttrib := STM->Attrib
* saBuf := CopyRec()
RETURN ArtExist(STM->IdArt)

* FUNCTION DtlPostEdit(cIdPrj)
* RETURN .f. if empty(DTL->IdDto)
* RETURN DtlStmExist(cIdPrj)

* FUNCTION DtlStmExist(cIdPrj)
* RETURN .t. if StmExist(DTL->IdDto)
* open area oStm()
*   StmCreate(cIdPrj,DTL->IdDto)
* close area
* RETURN .t.


#endif DEF_HOLZ

#ifdef DEF_DTL

**
** DtlCreate()
**
*FUNCTION DtlCreate(cIdJnl,cIdDoc,cIdDto)
*static scIdDoc := NIL
*static scIdJnl := NIL
*if cIdJnl == NIL
*  cIdJnl := PickJnl("VEN",scIdJnl)
*  RETURN DDCREATE_FAIL if cIdJnl == NIL
*  scIdJnl := cIdJnl
*endif
*if cIdDoc == NIL
*  cIdDoc := PickDoc(cIdJnl,scIdDoc)
*  RETURN DDCREATE_FAIL if cIdDoc == NIL
*  scIdDoc := cIdDoc
*endif
*RETURN DDCREATE_FAIL if ! dbAddRec()
*DTL->IdJnl := cIdJnl
*DTL->IdDoc := cIdDoc
*if cIdDto == NIL
*  default scIdDto to LastIdDto() // space(LEN_IDDTO)
*  cIdDto := NextId(scIdDto) // str(val(scIdDto),LEN_IDDTO,0)
*endif
*DTL->IdDto := cIdDto
*scIdDto := DTL->IdDto
*unlock record
*RETURN DDCREATE_EDIT

* FUNCTION DtlValIdDto
* if ! empty(DTL->IdDto)
*   scIdDto := DTL->IdDto
* endif
* RETURN .t.

#endif DEF_DTL

#ifdef DEF_PSC

**
** PscCreate()
**
FUNCTION PscCreate(cIdPar,cIdPar2)
local cPos
local nOrder := indexord()
ddSetOrder(1)
ddGoBottom(.f.)
cPos := NextNum(PSC->Seq)
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
if cIdPar != NIL  ; PSC->IdPar := cIdPar ; endif
if cIdPar2 != NIL ; PSC->IdPar2 := cIdPar2 ; endif
PSC->Seq   := cPos
* unlock record
* ddRefreshAll()
* RETURN DDCREATE_EDIT
RETURN DDCREATE_REFRESH

#endif DEF_PSC

#ifdef DEF_ECHE

**
** EclCreate()
**
*FUNCTION EclCreate(cIdEcs,cMatch,cCptType,cIdCpt)
*local aBuf := CopyRec()
*default cIdEcs to PickEcs("Zahlungsauftrag erstellen...",cCptType)
*RETURN DDCREATE_FAIL if cIdEcs == NIL
*if cCptType == NIL
*  RETURN DDCREATE_FAIL if (cCptType := PickCtr()) == NIL
*endif
*if cIdCpt == NIL
*  RETURN DDCREATE_FAIL if (cIdCpt := PickCompte(cCptType)) == NIL
*endif
*RETURN DDCREATE_FAIL if ! dbAddRec()
*ECL->IdEcs := cIdEcs
*ECL->Date := UserDate() + EcsDuree(cIdEcs)
*ECL->IdCpt := cIdCpt
*if cMatch   != NIL ; ECL->Match := cMatch ; endif
*EclPostEdit()
** unlock record
** ddRefreshAll()
*RETURN DDCREATE_REFRESH

#endif DEF_ECHE

#ifdef DEF_IMP

**
** BudCreate()
**
FUNCTION BudCreate(cIdCtr)
local cId    := SayIdBud(BUD->IdBud)
* local cIdCtr := BUD->IdCtr
local aBuf := CopyRec()
default cIdCtr to BUD->DC
if BUD->IsSum == BUTTON_ON
  if UsrLevel() > "B"
    SetMsg("Summenartikel drfen nicht kopiert werden !")
    RETURN DDCREATE_FAIL
  endif
endif
open window ("Einfgen Haushaltsartikel") size 3,70 help BUDCREA
do while  ! AppTerminate()
  WinHome()
  say TIM083
  @ row(), col() say cIdCtr // picture PIC_ID pick PickCtr(cIdCtr)
  @ row(), col() + 1 get cId picture PIC_ID
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  cId := GetIdBud(cId)
  * if ! ValIdBud(cIdCtr,cId)
  *   loop
  * endif
  if ! IsNewId(cIdCtr+cID)
  * seek cIdCtr + cId
  * if found()
    SetMsg(cIdCtr + "-" + SayIdBud(cId) + MsgIdExist())
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
BUD->DC      := cIdCtr
BUD->IdBud   := cId
BUD->DatCrea := UserDate()
dbcommit()
* unlock record
SendConsole("BUD create " + cIdCtr + "-" + SayIdBud(cId))
RETURN DDCREATE_FULL

#endif DEF_IMP

#ifdef DEF_ANA

**
** AnaCreate()
**
FUNCTION AnaCreate()
local cID := ANA->IdAna
local aBuf := CopyRec()
open window ("Einfgen Analysekonto") size 3,70 help ANACREA
do while  ! AppTerminate()
  WinHome()
  say TIM083
  @ row(), col() get cId picture PIC_ID
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cId)
  * seek cId
  * if found()
    SetMsg(cId + MsgIdExist())
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
ANA->IdAna  := cID
dbcommit()
* unlock record
RETURN DDCREATE_DONE

#endif DEF_ANA

#ifdef DEF_VAR

FUNCTION VarCreate(cIdVrt)
local aBuf := CopyRec()
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
VAR->IdVrt := cIdVrt
* unlock record
ddRefreshAll()
RETURN DDCREATE_EDIT

#endif DEF_VAR

#ifdef DEF_PRJ

FUNCTION PrjValidate(cIdPrj,cName)
local lOkay := .f.
RETURN .t. if empty(cIdPrj)
open area oPrj()
  seek cIdPrj
  if eof() // 20070801 recno() == lastrec() + 1
    if Confirm(cIdPrj + " : Projekt erstellen (J/N) ?",NIL,MSG_YES)
      if PrjCreate(cIdPrj,cName)  != DDCREATE_FAIL
        lOkay := .t.
      endif
    endif
  else
    lOkay := .t.
  endif
close area
RETURN lOkay

FUNCTION PrjCreate(cIdPrj,cName1)
local aBuf
if cIdPrj == NIL .or. cName1 == NIL
  aBuf := CopyRec()
  default cName1 to PRJ->Name1
  default cIdPrj to PRJ->IdPrj
  cName1 := padr(cName1,30)
  cIdPrj := padr(cIdPrj,LenIdPrj())
  #ifdef LG_GERMAN
  open window ("Projekt einfgen") size 4,50
  #else
  open window ("Cr‚ation dossier") size 4,50
  #endif
  do while .t.
    WinHome()
    @ row(), col() say TIM083 get cIdPrj picture PIC_ID
    WinCr()
    @ row(), col() say TIM084 get cName1
    nKey := ReadScr()
    if nKey == K_ESC
      cIdPrj := NIL
      exit
    endif
    if ! IsNewId(cIdPrj)
    * seek cIdPrj
    * if ! eof()
      SetMsg(cIdPrj + MsgIdExist())
      loop
    endif
    exit
  enddo
  close window
endif
RETURN DDCREATE_FAIL if cIdPrj == NIL
RETURN DDCREATE_FAIL if ! dbAddRec()
if aBuf != NIL
  PasteRec(aBuf)
endif
PRJ->IdPrj := cIdPrj
PRJ->Name1 := cName1
* unlock record
RETURN DDCREATE_DONE

#else

FUNCTION PrjValidate() ; RETURN .t.

#endif DEF_PRJ


#ifdef DEF_IMP

#ifdef DEF_VCS

FUNCTION ImlVcsCreate(cVcs)
local aIml := {}
local cIdMvi := vcs2hst(cVcs)
local u
RETURN .f. if cIdMvi == NIL
u := DbfPeek(oMvi(),cIdMvi,{||ImpMviPreCollect().and.MviImlCollect(aIml,.f.)},NIL)
if u == NIL
  RETURN !SetMsg(cVcs+" ("+cIdMvi+") : Buchung nicht gefunden!") 
endif
RETURN .f. if ! u
ImlGenerate(aIml,IMP->IdJnl,IMP->IdDoc)
RETURN .t.

#endif DEF_VCS

**
FUNCTION ImlGenerate(aIml,cIdJnl,cIdDoc) // ,cIdPar,cIdPar2)
local i
local cLine
RETURN NIL if aIml == NIL
MsgDisplay(cIdJnl + " " + cIdDoc + MsgGenerating() )
KeyGoBottom(cIdJnl + cIdDoc, "IML->IdJnl+IML->IdDoc" )
cLine := NextNum(IML->Line)
for i := 1 to len(aIml)
  if dbAddRec()
    IML->IdJnl       := cIdJnl
    IML->IdDoc       := cIdDoc
    IML->Line        := cLine
    if aIml[i][IML_IDPAR] != NIL
      IML->IdPar       := aIml[i][IML_IDPAR    ]
      IML->IdPar2      := aIml[i][IML_IDPAR2   ]
    else
      IML->IdPar       := IMP->IdPar
      IML->IdPar2      := IMP->IdPar2
    endif
    IML->NB1         := aIml[i][IML_NB1      ]
    IML->Mont        := aIml[i][IML_MONT     ]
    IML->MontDev     := aIml[i][IML_MONTDEV  ] // 20011221
    ImlMontValidate()
    IML->Date        := UserDate() // aIml[i][IML_DATE     ]
    IML->IdBud       := aIml[i][IML_IDBUD    ]
    IML->BackMatch   := aIml[i][IML_BACKMATCH]
    if empty(aIml[i][IML_MATCH])
      IML->Match       := cIdJnl + cIdDoc + cLine
    else
      IML->Match       := aIml[i][IML_MATCH    ]
    endif
    IML->EaMatch     := aIml[i][IML_EAMATCH  ]
    IML->IdPrj       := aIml[i][IML_IDPRJ    ]
    IML->NB2         := aIml[i][IML_NB2      ]
    IML->Compte1     := aIml[i][IML_COMPTE1  ]
    IML->DC          := aIml[i][IML_DC       ]
    unlock record
  else
    exit
  endif
  cLine := NextNum(cLine)
  ImlAfter()
next i
ddSetUpdated(.t.) // oIml()[AD_UPDATED] := .t.
RETURN NIL

#endif DEF_IMP

#ifdef DEF_TRA


**
** TraCreate()
**
FUNCTION TraCreate(jnl,cIdDoc)
local nOrder := indexord()
ddSetOrder(1)
KeyGoBottom( jnl[JNL_IDJNL], "TRA->IdJnl" )
ddSetOrder(nOrder)
if ! eof() .and. TRA->Etat != TRASTAT_CLOSED
  Warning( MsgPrevDoc() + MsgNotClosed() )
  RETURN DDCREATE_FAIL if ! "E" $ UsrAttrib()
  RETURN DDCREATE_FAIL if ! Confirm( ;
    MsgPrevDoc() + MsgNotClosed(), MsgDocCreate(), ;
    MSG_NO, "WRN018" ;
  )
endif
if ! IsNewId(jnl[JNL_IDJNL] + cIdDoc)
  Warning( ;
    jnl[JNL_IDJNL] + " " + cIdDoc + MsgIdExist(), ;
    NIL, ;
    "WRN036" ;
  )
  RETURN DDCREATE_FAIL
endif

RETURN DDCREATE_FAIL if ! dbAddRec()
TRA->IdJnl := jnl[JNL_IDJNL]
TRA->IdDoc := cIdDoc
TRA->Date  := UserDate()
TRA->Etat  := TRASTAT_NEW
TRA->Date2 := UserDate()
TRA->IdDev := jnl[JNL_IDDEV]
TRA->IdUsr := UserId()
RETURN DDCREATE_FULL

**
** TrlGenerate()
**
** generates 0 to n lines in TRL using contents of aIml
**
FUNCTION TrlGenerate(aIml,cIdJnl2,cIdJnl,cIdDoc)
local i
local cLine
RETURN NIL if aIml == NIL
MsgDisplay(cIdJnl + " " + cIdDoc + MsgGenerating() )
KeyGoBottom(cIdJnl+cIdDoc, "TRL->IdJnl+TRL->IdDoc" )
cLine := NextNum(TRL->Line)
for i := 1 to len(aIml)
  if dbAddRec()
    TRL->IdJnl       := cIdJnl
    TRL->IdDoc       := cIdDoc
    TRL->Line        := cLine
    TRL->IdJnl2       := cIdJnl2
    cLine := NextNum(cLine)
    TRL->IdPar2      := aIml[i][IML_IDPAR2   ]
    // IML->IdPar       := aIml[i][IML_IDPAR    ]
    TRL->NB1         := aIml[i][IML_NB1      ]
    * if TRL->IdJnl == "SOZ "
    *   TRL->NB2         := aIml[i][IML_NB1      ]
    * endif
    TRL->Mont        := aIml[i][IML_MONT     ]
    * TRL->MontDev     := aIml[i][IML_MONTDEV  ] // 20011221
    * wird immer neu berechnet
    // IML->Date        := UserDate() // aIml[i][IML_DATE     ]
    TRL->BackMatch   := aIml[i][IML_BACKMATCH]
    TRL->Match       := aIml[i][IML_MATCH    ]
    // TRL->IdPrj       := aIml[i][IML_IDPRJ    ]
    TRL->Compte1     := aIml[i][IML_COMPTE1  ]
    TRL->DC          := aIml[i][IML_DC       ]
    TRL->IdBud       := aIml[i][IML_IDBUD    ]
    TRL->Periode     := PerActive()
    if left(TRL->Periode,LEN_YEAR) > left(aIml[i][IML_PERIODE],LEN_YEAR)
      // nein, das RJ darf nicht wechseln.
      TRL->Periode := left(aIml[i][IML_PERIODE],LEN_YEAR) +"13"
      // cPerActive := left(cPeriode,LEN_YEAR)
      // cPerActive += strtran(str(month(dDate)+12,LEN_PERIODE-LEN_YEAR)," ","0")
    elseif left(TRL->Periode,LEN_YEAR) < left(aIml[i][IML_PERIODE],LEN_YEAR)
      * TRL->Periode := left(aIml[i][IML_PERIODE],LEN_YEAR) +"01"
      TRL->Periode := aIml[i][IML_PERIODE]
    endif
    TRL->IdTrt       := TrtDefault(TRL->DC,TRL->IdBud)
    TRL->Etat        := TRLSTAT_NEW
    TRL->IdDev       := JnlIdDev(cIdJnl)
    if TRL->IdDev == DevDefault(TRL->Periode)
      TRL->IdDev := ""
    endif
    if empty(TRL->IdDev)
      TRL->IdDev := TRA->IdDev
    endif
    if TRL->IdDev == DevDefault(TRL->Periode)
      TRL->IdDev := ""
    endif
    if ! empty(TRL->IdDev)
      TRL->MontDev := ntom( ;
        val(TRL->Mont) / val(DevCours(TRL->IdDev,TRL->Periode)), ;
        DevDecPos(TRL->IdDev) ;
      )
    endif
    unlock record
  else
    exit
  endif
  // ImlAfter()
next i
* oTrl()[AD_UPDATED] := .t.
RETURN NIL



#endif DEF_TRA


#ifdef DEF_ALA

FUNCTION AlaCreate(cIdArt)
local cLine := ALA->Line
local nCreate := DDCREATE_REFRESH
local nOrder := indexord()
ddSetOrder(1)
if eof() // 20070801 recno() == lastrec() + 1
  nCreate := DDCREATE_EDIT
endif
KeyGoBottom( cIdArt, "ALA->IdArt1" )
if empty(cLine)
  cLine := NextNum(ALA->Line)
else
  do while .t.
    if ALA->Line >= cLine
      if ddRecLock()
        ALA->Line := NextNum(ALA->Line)
        unlock record
      endif
    else
      exit
    endif
    skip -1
    if bof() .or. ALA->IdArt1 != cIdArt
      exit
    endif
  enddo
endif
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
ALA->IdArt1 := cIdArt
ALA->Line  := cLine
* unlock record
RETURN nCreate

#endif DEF_ALA


#ifdef DEF_ODS

FUNCTION OdlCreate(cIdJnl,cIdDoc) // wie VnlCreate() und PrlCreate()
local cLine := ODL->Line
local nCreate := DDCREATE_REFRESH
local nOrder := indexord()
RETURN DDCREATE_FAIL if ! OdsPreEdit()
ddSetOrder(1)
if eof() // 20070801 recno() == lastrec() + 1
  nCreate := DDCREATE_EDIT
endif
KeyGoBottom( cIdJnl + cIdDoc, "ODL->IdJnl+ODL->IdDoc" )
if empty(cLine)
  cLine := NextNum(ODL->Line)
else
  do while .t.
    if ODL->Line >= cLine
      if ddRecLock()
        ODL->Line := NextNum(ODL->Line)
        unlock record
      endif
    else
      exit
    endif
    skip -1
    if bof() .or. ODL->IdDoc != cIdDoc .or. ODL->IdJnl != cIdJnl
      exit
    endif
  enddo
endif
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
ODL->IdJnl := cIdJnl
ODL->IdDoc := cIdDoc
ODL->Line  := cLine
* unlock record
RETURN nCreate

#endif DEF_ODS

* FUNCTION IfcCreate
* local cMemo1 := IFC->Memo1
* local cMemo2 := IFC->Memo2
* local cMemo3 := IFC->Memo3
* RETURN DDCREATE_FAIL if SeqCreate() == DDCREATE_FAIL

#ifdef DEF_ANA

**
** OdaCreate()
**
FUNCTION OdaCreate( jnl, cIdDoc ) // , aLn, cLibell )
local cPeriode := PerActive() // PickPer(jnl[JNL_IDJNL],UserDate())
local nOrder := indexord()
RETURN DDCREATE_FAIL if cPeriode == NIL
ddSetOrder(1)
KeyGoBottom( jnl[JNL_IDJNL], "ODA->IdJnl" )
ddSetOrder(nOrder)
if ! eof() .and. ODA->Etat != DocStatClosed()
  RETURN DDCREATE_FAIL if ! Confirm( ;
    MsgPrevDoc() + MsgNotClosed(), MsgDocCreate(), ;
    MSG_NO, "WRN018" ;
)
endif
if ! IsNewId(jnl[JNL_IDJNL] + cIdDoc)
* seek jnl[JNL_IDJNL] + cIdDoc
* if ! eof()
  Warning( ;
    jnl[JNL_IDJNL] + " " + cIdDoc + MsgDocExist(), ;
    NIL, "WRN014" ;
  )
  RETURN DDCREATE_FAIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
ODA->IdDoc    := cIdDoc
ODA->IdJnl    := jnl[JNL_IDJNL]
ODA->Date     := UserDate()
ODA->Periode  := cPeriode
ODA->Etat     := DocStatNew()
dbcommit()
* unlock record
RETURN DDCREATE_FULL

#endif DEF_ANA

#ifdef DEF_BIBLIO

**
** AutCreate()
**
FUNCTION AutCreate()
local cId
static cCopier := BUTTON_OFF
local aBuf     := CopyRec()
local nOrder := indexord()
ddSetOrder(1)
softseek "A"
do while val(AUT->IdAut) == 0
  skip -1
  if bof()
    exit
  endif
enddo
ddSetOrder(nOrder)
cId := NextNum(AUT->IdAut)
RETURN DDCREATE_FAIL if ! dbAddRec()
AUT->IdAut  := cId
dbcommit()
SetMsg("Neuer Autor.")
RETURN DDCREATE_FULL


**
** ObjCreate()
**
FUNCTION ObjCreate(cIdAut,cIdRub,cIdDtp,cIdGrp,cIdDst)
local cNewIdObj
local cOldId := OBJ->IdDtp + OBJ->IdObj
local i
static cCopier := BUTTON_OFF
local aBuf     := CopyRec()
local dtp
local cId1
local cId2
local cId3
local cWritten := OBJ->Written
local cLangue := OBJ->Langue
local lOkay := .f.
local nOrder := indexord()
if cIdDtp == NIL
  cIdDtp := ObjDtpPick(OBJ->IdDtp)
  RETURN DDCREATE_FAIL if cIdDtp == NIL
endif
dtp := DtpLocate(cIdDtp)
cId1 := left(OBJ->IdObj,dtp[DTP_LENPRE])
ddSetOrder(1)
KeyGoBottom( cIdDtp + cId1, ;
  "OBJ->IdDtp+left(OBJ->IdObj," + ntrim(dtp[DTP_LENPRE]) + ")" ;
)
cId2 := NextId( substr( ;
  OBJ->IdObj, ;
  dtp[DTP_LENPRE]+1, ;
  LenIdArt()-dtp[DTP_LENSUF]-dtp[DTP_LENPRE]) ;
)
cId3 := space(dtp[DTP_LENSUF])
open window (strtran(dtp[DTP_TITEL],"~") + " erstellen") size 5,40
open area oObj()
  do while ! lOkay
    WinHome()
    say "Nummer "
    get cId1 picture PIC_ID
    if len(cId1) > 0
      say " - "
    endif
    get cId2 picture PIC_ID
    if len(cId3) > 0
      say " . "
    endif
    get cId3 picture PIC_ID
    WinCR()
    get cCopier checkbox
    say MsgCopy() // MSG_COPY
    nKey := ReadScr()
    if nKey == K_ESC
      exit
    endif
    cNewIdObj := cId1 + cId2 + cId3
    if empty(cNewIdObj)
      SetMsg(cNewIdObj + TIM081 )
      loop
    endif
    seek cIdDtp + cNewIdObj
    if eof()
      lOkay := .t.
    else
      SetMsg(strtran(dtp[DTP_TITEL],"~") + " " + cNewIdObj + MsgIdExist())
    endif
  enddo
close area
close window
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! lOkay
RETURN DDCREATE_FAIL if ! dbAddRec()
if cCopier == BUTTON_ON
  PasteRec(aBuf)
  MsgDisplay("Referenzen werden kopiert...")
  open area oRef()
    aBuf := {}
    softseek cOldId
    do while REF->IdDtp + REF->IdObj == cOldId
      aadd(aBuf, CopyRec())
      skip
    enddo
    for i := 1 to len(aBuf)
      if dbAddRec()
        PasteRec(aBuf[i])
        REF->IdObj := cNewIdObj
        REF->IdDtp := cIdDtp
      else
        exit
      endif
    next i
  close area
else
  OBJ->Written := cWritten
  OBJ->Langue  := cLangue
endif
OBJ->IdObj  := cNewIdObj
if cIdAut != NIL
  OBJ->IdAut  := cIdAut
  OBJ->Langue := AutLangue(cIdAut)
endif
OBJ->IdDtp := cIdDtp
if cIdRub != NIL ;  OBJ->IdRub  := cIdRub ; endif
if cIdGrp != NIL ;  OBJ->IdGrp  := cIdGrp ; endif
*if cIdDst == NIL
 * OBJ->IdDst := ""
*else
*  OBJ->IdDst  := cIdDst
*endif
*OBJ->LastUp := UserDate()
dbcommit()
RETURN DDCREATE_FULL


**
** ObjRename()
**
FUNCTION ObjRename()
local cNewIdObj
local cOldId := OBJ->IdDtp + OBJ->IdObj
local dtp := DtpLocate(RefDtpPick(OBJ->IdDtp,"Dokument umbenennen in ein..."))
local cId1
local cId2
local cId3
local nRecNo
local lOkay := .f.
RETURN NIL if dtp == NIL
cId1 := left(OBJ->IdObj,dtp[DTP_LENPRE])
cId2 := substr( ;
  OBJ->IdObj, ;
  dtp[DTP_LENPRE]+1, ;
  LenIdArt()-dtp[DTP_LENSUF]-dtp[DTP_LENPRE] ;
)
cId3 := right(OBJ->IdObj,dtp[DTP_LENSUF])
open window (strtran(dtp[DTP_TITEL],"~") + " umbenennen") size 5,40
open area oObj()
  do while ! lOkay
    WinHome()
    say "Neue Nummer "
    get cId1 picture PIC_ID
    if len(cId1) > 0
      say " - "
    endif
    get cId2 picture PIC_ID
    if len(cId3) > 0
      say " . "
    endif
    get cId3 picture PIC_ID
    nKey := ReadScr()
    if nKey == K_ESC
      exit
    endif
    cNewIdObj := cId1 + cId2 + cId3
    if empty(cNewIdObj)
      SetMsg(cNewIdObj + MSG002 )
      loop
    endif
    seek dtp[DTP_ID] + cNewIdObj
    if eof()
      lOkay := .t.
    else
      SetMsg(strtran(dtp[DTP_TITEL],"~") + " " + cNewIdObj + MsgIdExist())
    endif
  enddo
close area
close window
RETURN NIL if ! lOkay
if ddRecLock()
  MsgDisplay("Referenzen werden umgeleitet...")
  open area oRef()
    softseek cOldId
    do while ! eof() .and. REF->IdDtp + REF->IdObj == cOldId
      skip
      nRecNo := recno()
      skip -1
      if ddRecLock()
        REF->IdObj := cNewIdObj
        REF->IdDtp := dtp[DTP_ID]
        unlock
      endif
      goto nRecNo
    enddo
  close area
  OBJ->IdObj := cNewIdObj
  OBJ->IdDtp := dtp[DTP_ID]
  dbcommit()
  unlock
  ddRefreshAll()
endif
RETURN MnuDone()


**
** RubCreate()
**
FUNCTION RubCreate()
local cId    := RUB->IdRub
local aBuf := CopyRec()
open window ("Rubrik erstellen") size 5,40
do while .T.
  WinHome()
  say "ID "
  get cId picture PIC_ID
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cId)
  * seek cId
  * if ! eof()
    SetMsg(cId + MsgIdExist())
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
RUB->IdRub  := cId
dbcommit()
RETURN DDCREATE_REFRESH



**
** GrpCreate()
**
FUNCTION GrpCreate()
local cId := space(LEN_IDGRP)
open window ("Verlag erstellen") size 5,40
do while .T.
  WinHome()
  say "ID "
  get cId picture PIC_ID
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cId)
  * seek cId
  * if ! eof()
    SetMsg(cId + MsgIdExist())
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
GRP->IdGrp  := cId
dbcommit()
RETURN DDCREATE_REFRESH



**
** DtpCreate()
**
FUNCTION DtpCreate()
local aBuf := CopyRec()
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
dbcommit()
RETURN DDCREATE_EDIT



**
** NtsCreate()
**
FUNCTION NtsCreate()
local cId
local cName := space(LEN_NTSNAME)
* local cName := space(LEN_NTSNAME)
go bottom
cId := NextId(NTS->IdNts)
open window ("Neues Stichwort einfgen") size 3,LEN_NTSNAME + 4
do while .T.
  WinHome()
  get cName
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cId)
  * seek cId
  * if ! eof()
    SetMsg(cId + MsgIdExist())
    go bottom
    cId := NextId(NTS->IdNts)
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
NTS->IdNts  := cId
NTS->Date := UserDate()
NTS->Name   := cName
dbcommit()
RETURN DDCREATE_DONE



FUNCTION RefCreate(cIdDtp,cIdObj,cIdNts)
static scIdDtp := NIL
default cIdDtp to RefDtpPick(scIdDtp)
RETURN DDCREATE_FAIL if cIdDtp == NIL
scIdDtp := cIdDtp
default cIdObj to ObjPick("Verweis erstellen zu...",NIL,cIdDtp)
RETURN DDCREATE_FAIL if cIdObj == NIL
default cIdNts to PickNts("Verweis erstellen zu...")
RETURN DDCREATE_FAIL if cIdNts == NIL
RETURN DDCREATE_FAIL if ! dbAddRec()
REF->IdDtp := cIdDtp
REF->IdObj := cIdObj
REF->IdNts := cIdNts
RETURN DDCREATE_DONE

FUNCTION AutPreDelete
local lOkay := .f. // nReturn := DDDEL_FAIL
open area oObj()
  ddSetOrder(DOC_ORD_AUT)
  softseek AUT->IdAut
  if OBJ->IdAut == AUT->IdAut
    SetMsg("Verweigert. Mindestens 1 Dokument ist diesem Autor zugewiesen.")
  else
    lOkay := .t. // nReturn := DDDEL_CONFIRM
  endif
close area
RETURN lOkay // nReturn

FUNCTION OutCreate(cIdPar,cIdDtp,cIdObj)
default cIdPar to PickPar()
RETURN DDCREATE_FAIL if cIdPar == NIL
default cIdDtp to ObjDtpPick("Titel")
RETURN DDCREATE_FAIL if cIdDtp == NIL
default cIdObj to ObjPick("Ausgang erstellen fr Dokument...",NIL,cIdDtp)
RETURN DDCREATE_FAIL if cIdObj == NIL
RETURN DDCREATE_FAIL if ! dbAddRec()
OUT->IdPar := cIdPar
OUT->IdDtp := cIdDtp
OUT->IdObj := cIdObj
OUT->Date := UserDate()
RETURN DDCREATE_DONE


#endif DEF_BIBLIO

#ifdef DEF_ODS

**
** Wird benutzt, um Inventur-OD zu generieren.
** bei PAC
**
FUNCTION OdlArtCopy(xlArtFilter,xQte,xMont,xcDC,lAlaGenerate) // cIdStk)
local jnl := JnlLocate(ODS->IdJnl)
local cLine := repl("0",LEN_POS)
local nCount := 0
local lOkay := .f.
default xlArtFilter to "!'H'$ART->Attrib.and.!'S'$ART->Attrib"
default lAlaGenerate to .f.
RETURN .f. if jnl == NIL
RETURN .f. if ! OdsPreEdit()
open area oArt()
  lOkay := .t.
  go top
  do while ! eof()
    if TaskInter()
      lOkay := .f.
      exit
    endif
    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if empty(xlArtFilter) .or. &xlArtFilter
      select ODL
      cLine := NextNum(ODL->Line)
      if dbAddRec()
        * cLine := NextNum(cLine)
        ODL->IdJnl := ODS->IdJnl
        ODL->IdDoc := ODS->IdDoc
        ODL->Line  := cLine
        ODL->IdArt := ART->IdArt
        if xcDC == NIL
          ODL->DC    := jnl[JNL_DC]
        else
          ODL->DC    := xparse(xcDC)
        endif
        ODL->Qte  := &(xQte)  // ART->Stock
        ODL->Mont := &(xMont) // ntom(val(ART->PrixR)*qton(ODL->Qte))
        unlock record
        #ifdef DEF_ALA
          if lAlaGenerate
            * 19990830 OdlIdValidate()
            if ! OdlAlaGenerate()
              lOkay := .f.
            endif
          endif
        #endif DEF_ALA
      else
        lOkay := .f.
        exit
      endif
      select ART
    endif
    skip
  enddo
close area
ddRefreshAll()
RETURN SetMnuDone()

#endif DEF_ODS

**
** RecCreate()
**
FUNCTION RecCreate()
local aBuf := CopyRec()
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
dbcommit()
RETURN DDCREATE_FULL if CurQry(QRY_IDMSK) != NIL
RETURN DDCREATE_EDIT


#ifdef DEF_VNA

FUNCTION VnaCreate(cIdJnl,cIdDoc)
local aBuf := CopyRec()
* RETURN DDCREATE_FAIL if ! PreVnaCreate()
* RETURN DDCREATE_FAIL if ! USRATTR_B $ UsrAttrib()
* if lConfirm
*  RETURN DDCREATE_FAIL if ! Confirm( ;
*    "Fakturationsvorschlag manuell erstellen.", ;
*    MsgSure() ;
*  )
* endif
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
if cIdJnl != NIL
  VNA->IdJnl := cIdJnl
  VNA->IdDoc := cIdDoc
endif
* if ! PostVnaCreate()
*   Warning(SetMsg(),"PostVnaCreate() failed.")
* endif
RETURN DDCREATE_DONE

#endif DEF_VNA


#ifdef DEF_ODS

**
** OdlCopy()
**
FUNCTION OdlCopy()
local jnl
local a
local cJnlDest := ODS->IdJnl
local cDocDest := ODS->IdDoc
return .f. if ! OdsPreEdit()
RETURN NIL if (jnl := PickJnl(JNLALIAS_ODS,ODS->IdJnl,NIL,"Dokument kopieren...")) == NIL
a := OdsSelect(jnl,ODS->IdPar,ODS->IdJnl+ODS->IdDoc)
RETURN .f. if a == NIL
OdsCopy(cJnlDest,cDocDest,a[1],a[2])
ddSetUpdated(.t.) // oOdl()[AD_UPDATED] := .t.
ddGoBottom(.t.)
RETURN MnuDone()


**
** OdsSelect()
**
** L„sst ein Dokument ausw„hlen und gibt Information in einem Array
** zurck.
**
STATIC FUNCTION OdsSelect(jnl,cIdPar,cMatch)
local a := NIL
local b := oOds()
open area b, oPar()
  edit data b ;
            key      ODS->IdJnl ;
            value    jnl[JNL_IDJNL] ;
            mode     pick                         ;
            create   {|| DDCREATE_FAIL } ;
            filter   "ODS->IdJnl+ODS->IdDoc != '" + cMatch + "'" ;
            query    "ODSPICK" ;
            start bottom ;
            title (MSG033 + cIdPar)
  if ddLastReq() == DDEDIT_SELECT
    a := array(2)
    a[1]  := ODS->IdJnl
    a[2]  := ODS->IdDoc
  endif
close area
RETURN a


**
** OdsCopy()
**
FUNCTION OdsCopy(cIdJnl,cIdDoc,cIdJnlSource,cIdDocSource)
local nRecNo
local aBuf
local cLine
open area oOdl()
  KeyGoBottom( cIdJnl + cIdDoc, "ODL->IdJnl+ODL->IdDoc" )
  cLine := NextNum(ODL->Line)
  softseek cIdJnlSource + cIdDocSource
  do while ! eof() .and. ODL->IdJnl + ODL->IdDoc == cIdJnlSource + cIdDocSource
    nRecNo := recno()
    aBuf := CopyRec()
    if dbAddRec()
      PasteRec(aBuf)
      ODL->IdJnl := cIdJnl
      ODL->IdDoc := cIdDoc
      ODL->Line := cLine
      cLine := NextNum(cLine)
      dbcommit() // 960314
      unlock record
    else
      exit
    endif
    goto nRecNo
    skip
  enddo
close area
RETURN NIL

#endif DEF_ODS

#ifdef DEF_RUN

**
** RalCreate()
**
FUNCTION RalCreate(cIdGrp)
local cId      := space(LenIdRal())
softseek "A"
skip -1
cId := NextNum(RAL->IdRal)
open window ("Ajouter signal‚tique course") size 3,40 help RALCREA
do while .t.
  WinHome()
  @ CSR_POS say "ID : " get cId GET_PAD
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cId)
  * seek cId
  * if !eof()
    SetMsg(cId + " : existe d‚j… !")
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
* append blank
* if ddRecLock()
  RAL->IdRal   := cId
  RAL->Status  := RALSTAT_I
  dbcommit()
  unlock record
* endif
RETURN DDCREATE_REFRESH

FUNCTION PosCreate(cIdRal)
local cIdPos := ""
local cIdPar := PickPar()
local nOrder := indexord()
RETURN DDCREATE_FAIL if cIdPar == NIL
if RAL->RalType == RALTYPE_1
  ddSetOrder(1)
  ddGoBottom(.f.)
  cIdPos := NextNum(POS->IdPos)
  ddSetOrder(nOrder)
endif
append blank
POS->IdRal := cIdRal
POS->IdPar := cIdPar
POS->IdPos := cIdPos
if ParExist(POS->IdPar)
  POS->IdEqu := PAR->IdEqu
  POS->IdClb := PAR->IdClb
endif
dbcommit()
ddRefreshCurrent()
RETURN DDCREATE_DONE

#endif DEF_RUN


FUNCTION GetId(x,nPadLen,nLenPrefix,cDefaultPrefix)
local nLen := len(x)
RETURN x if len(trim(x)) >= nPadLen
if val(x) == 0
  RETURN x if val(substr(x,nLenPrefix+1)) == 0
  RETURN left(x,nLenPrefix) + ;
         padl(substr(x,nLenPrefix+1),nPadLen-nLenPrefix,"0") + ;
         substr(x,nPadLen+1)
elseif cDefaultPrefix != NIL
  RETURN padr( ;
    cDefaultPrefix + padl(trim(x),nPadLen-len(cDefaultPrefix),"0") ;
    ,nLen ;
  )
endif
RETURN padr(padl(trim(x),nPadLen,"0"),nLen)


**
** DbfNextId().
**
** cRoot :
**
FUNCTION DbfNextId(b,cRoot,nLen,nOrder,xcKey,xcOnLast)
RETURN cRoot if len(cRoot) == nLen
open area b
  if nOrder != NIL
    ddSetOrder(nOrder)
  endif
  default xcKey to indexkey()
  if len(cRoot) == 0
    softseek repl("9",nLen)
    if eof() // 20021023
      go bottom
    elseif &xcKey > repl("9",nLen)
      skip -1
    endif
  else
    KeyGoBottom( cRoot, "left(" + xcKey +","+ntrim(len(cRoot))+")" )
  endif
  if xcOnLast == NIL
    if left(&xcKey,len(cRoot)) == cRoot
      if empty(cRoot) .or. val(substr(&xcKey,len(cRoot) + 1 )) != 0
        cRoot := cRoot + NextId( ;
          substr(&xcKey,len(cRoot)+1,nLen-len(cRoot) ) ;
        )
      endif
    else
      // neu [19980210]
      cRoot := cRoot + NextId(repl("0",nLen-len(cRoot)))
    endif
  else
    cRoot := xparse(xcOnLast)
  endif
close area
RETURN padr(cRoot,nLen)

**
**
FUNCTION DbfOnBottom(ad,nOrder,xcOnLast,uReturn,cKey,xlWhile,xlFilter)
open area ad
  if nOrder != NIL
    ddSetOrder(nOrder)
  endif
  if cKey == NIL
    go bottom
  else
    KeyGoBottom(cKey,xlWhile,xlFilter)
  endif
  if !eof()
    uReturn := xparse(xcOnLast)
  endif
close area
RETURN uReturn


#ifdef DEF_JNL

**
** JnlCreate()
**
FUNCTION JnlCreate()
* local cIdJnl  := space(LenIdJnl())
local cIdJnl  := JNL->IdJnl
local cAlias := JNL->Alias
local aBuf := CopyRec()
local cIdJnlCopy := JNL->IdJnl
if ! USRATTR_B $ UsrAttrib()
  Warning(MsgNoAccess())
  RETURN DDCREATE_FAIL // if NoExpert()
endif
if empty(cAlias)
  RETURN DDCREATE_FAIL if (cAlias := PickAlias(NIL,TIM089)) == NIL
endif
open window (TIM089) size 3,32 help JNLCREA
do while .t.
  WinHome()
  say TIM083
  @ row(), col() get cIdJnl picture PIC_ID
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if DbfPeek(oJnl(),cIdJnl,".t.",.f.)
  * if ! IsUnique(cIdJnl) // JnlLocate(cIdJnl) != NIL
    SetMsg(cIdJnl + MsgIdExist())
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
JNL->IdJnl  := cIdJnl
JNL->IdDoc    := ""
JNL->Periode  := ""
JNL->Alias  := cAlias
RETURN DDCREATE_DONE

#endif DEF_JNL


