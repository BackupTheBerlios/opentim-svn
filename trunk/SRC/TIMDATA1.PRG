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

* #define DEF_CLI_B

#ifdef LG_FRENCH
  #define MSG001  "~Bestellungen erfassen         "
  #define MSG002  "~Articles/fourniseur    [Sh-F1]"
  #define MSG003  "Facturation ~automat.   [Sh-F6]"
  #define MSG004  "~Importer...                   "
  #ifdef DEF_HOLZ
    #define MSG_SETCLSTYPE  "~Klassierungsart...        [F8]"
    * #define MSG_VENSTMCOPY  "~Baumst„mme bernehmen...  [F5]"
  #endif DEF_HOLZ
  #define MSG005  "~Personnes de contact...       "
  #define MSG006  "~est personne de contact pour.."
  * #define MnuMbrEdit   "~Info-Eintr„ge          [Sh-F6]"
  * #define MnuMbrBrowse "In~fo-Editor               [F6]"
  #define MSG_RAPEDIT  "~Rappels de paiement           "
  #define MSG007  "~Documents de facturation  [F5]"
  #define MSG008  "Num‚ros de ~s‚rie          [F8]"
  #define MSG009  "Chiffre d'a~ffaires        [F2]"
  #define MSG011      "C~orrespondance         [Sh-F8]"
  #define MsgEviEdit  "E~vŠnements                [F8]"
  #define MSG012  "~Historique compte         [F9]"
  #define MSG013  "H~istorique centralis‚  [Sh-F9]"
  #define MSG_PARMV2  "Historik ~Empf„nger    [Alt-F9]"
  #define MSG_PARTRE  "~Tresoreriebuchungen    [Sh-F9]"
  * #define MSG_QTS  "~Stocks en cours     [Ctrl-F6]"
  #ifdef DEF_VNA
    #define MSG_VNA "~Propositions facturation  [F6]"
    #define MSG_VNAAUTO "Facturatø ~automatique [Alt-F6]"
  #endif
  #ifdef DEF_MVS
    #define MSG_MVS "~historique stock     [Ctrl-F6]"
  #endif DEF_MVS
  #ifdef DEF_CTS
    #define MSG_CTS "~historique mensuel     [Sh-F6]"
  #endif DEF_CTS
  #ifdef DEF_PSC
    static MSG_SWITCH := "~Richtung tauschen...      [F2]"
  #endif
  #define MSG014  "~Membre des listes...          "
  #define MSG015  "~Remplir liste...              "
  * #define MSG016  "~Historique                [F6]"
  #define MSG017  "Mise … jour stoc~k         [F9]"
  #ifdef DEF_GRA
    static MSG_GraArtEdit := "~Articles/Groupe        [Enter]"
  #endif DEF_GRA
  #define MSG019  "C~onditions sp‚ciales   [Sh-F4]"
  #define MSG020  "S~ubstituts             [Sh-F2]"
  #define MSG021  "~Inventaires            [Sh-F2]"
  #define MSG022  "Code profession inconnu"
  #define MSG023  "Identification"
  #define MSG024  "Nom 1"
  #define MSG025  "Adresse"
  * #define MSG026  "Code profession"
  * #define MSG027  "Nø T.V.A."
  #define MSG026  "Clients"
  #define MSG027  "Fournisseurs"
  #define MSG028  "Pays/C.P.   "
  #define MSG029  "Fournisseur, Nø commande"
  * #define MSG030  "Editeur de ~texte         [F12]"
  #define MSG_PIN "~Pinwand                   [F6]"
  #define MSG_STM "~Baumst„mme                [F6]"
  #ifdef DEF_ART
    static MSG031 :=  "groupe"
  #endif
  #define MSG032  "Compte/P‚riode"
  #define MSG033  "Document"
  #define MSG034  "Compte+P‚riode+Date"
  #define MSG035  "Compte+Match"
  #define MSG036  "alphab‚tique"
  #define MSG037  "P~r‚sences par client          "
  #define MSG038  "Saisi~r commande       [Alt-F6]"
  #define MSG_RpqEdit     "~Remises quantit‚          [F8]"
  #define MSG_ArtAlaEdit  "~Composants                [F9]"
#else
  #define MSG001  "~Bestellungen erfassen       "
  #define MSG002  "~Artikel pro Lieferant  [Sh-F1]"
  #define MSG003  "~Autom. Fakturierung    [Sh-F6]"
  #define MSG004  "~Importieren...                "
  #ifdef DEF_HOLZ
    #define MSG_SETCLSTYPE  "~Klassierungsart...        [F8]"
    * #define MSG_VENSTMCOPY  "~Baumst„mme bernehmen...  [F5]"
  #endif DEF_HOLZ
  #define MSG005  "Kontakt~personen...            "
  #define MSG006  "ist Kontaktperson ~fr...      "
  * #define MnuMbrEdit   "~Info-Eintr„ge          [Sh-F6]"
  * #define MnuMbrBrowse "In~fo-Editor               [F6]"
  #define MSG_RAPEDIT  "~Mahnungen                     "
  #define MSG007  "~Fakturationsdokumente     [F5]"
  #define MSG008  "~Seriennummern             [F8]"
  #define MSG009  "Umsatz ~errechnen          [F2]"
  #define MSG011      "K~orrespondenz          [Sh-F8]"
  #define MsgEviEdit  "Erei~gnisse                [F8]"
  #define MSG012  "~Historik Konto            [F9]"
  #define MSG013  "~Sammelhistorik         [Sh-F9]"
  #define MSG_PARMV2  "~Historik Empf„nger    [Alt-F9]"
  #define MSG_PARTRE  "~Tresoreriebuchungen    [Sh-F9]"
  * #define MSG_QTS "~Lagerbest„nde        [Ctrl-F6]"
  #ifdef DEF_MVS
    #define MSG_MVS "~Lagerhistorik        [Ctrl-F6]"
  #endif DEF_MVS
  #ifdef DEF_CTS
    #define MSG_CTS "Sammelh~istorik Lager   [Sh-F6]"
  #endif DEF_CTS
  #ifdef DEF_VNA
    #define MSG_VNA "~Fakturierungsvorschl„ge   [F6]"
    #define MSG_VNAAUTO "~Automatikfakturierung [Alt-F6]"
  #endif
  #ifdef DEF_PSC
    static MSG_SWITCH := "~Richtung tauschen...      [F2]"
  #endif
  #define MSG014  "~Mitgliedschaften...           "
  #define MSG015  "Liste ~fllen...               "
  * #define MSG016  "~Historik                  [F6]"
  #define MSG017  "Bestand ~korrigieren       [F9]"
  #ifdef DEF_GRA
    static MSG_GraArtEdit := "~Artikel/Gruppe         [Enter]"
  #endif DEF_GRA
  #define MSG019  "S~onderbedingungen      [Sh-F4]"
  #define MSG020  "S~ubstitute             [Sh-F2]"
  #define MSG021  "~Inventur-Eintr„ge      [Sh-F2]"
  #define MSG022  "Ungltiger Beruf-Code !"
  #define MSG023  "Id-Nummer"
  #define MSG024  "Name 1"
  #define MSG025  "Adresse"
  * #define MSG026  "Berufs-Kode"
  * #define MSG027  "MWSt-Nummer"
  #define MSG026  "Kunden"
  #define MSG027  "Lieferanten"
  #define MSG028  "Land/PLZ"
  #define MSG029  "Lieferant, Bestellnummer"
  * #define MSG030  "~Text-Editor              [F12]"
  #define MSG_PIN "~Pinwand                   [F6]"
  #define MSG_STM "~Baumst„mme                [F6]"
  #ifdef DEF_ART
    static  MSG031 :=  "Artikelgruppe"
  #endif
  #define MSG032  "Konto/Periode"
  #define MSG033  "Dokument"
  #define MSG034  "Konto+Periode+Datum"
  #define MSG035  "Konto+Match"
  #define MSG036  "alphabetisch"
  #define MSG037  "Anwesenheiten p~ro Kunde       "
  #define MSG038  "Bestellung e~rfassen   [Alt-F6]"
  #define MSG_RpqEdit     "~Mengenrabatte             [F8]"
  #define MSG_ArtAlaEdit  "~Komponenten               [F9]"
#endif


#ifdef DEF_HST
  static scAutoSatisfy := BUTTON_ON
  static sdMvpDate     := NIL
#endif DEF_HST

#ifdef DEF_ART

**
** ART - Articles
**
FUNCTION oArt(lRebuild)
static b
if lRebuild == NIL
  RETURN b if b != NIL
else
  b := NIL
endif
define data b name ART ;
              predelete ArtPreDelete(.t.) ;
              create    ArtCreate() ;
              postedit  ArtPostEdit() ;
              editprint ArtPrint() ;
              preedit   ArtPreEdit() ;
              wait {|msk| ArtWait(msk)}
              * fileprint  ArtFilePrint()
ddIndex b on  ART->IdArt text MSG023 ;
              format {|x|GetIdArt(padr(upper(x),LenIdArt()))}   // ORD_ART_ID
#ifdef DEF_GRA
  #ifdef DEF_ART_REF
    ddIndex b on  ART->iGra+RefTrunc(ART->Ref) ;
              text MSG031 ;
              format {|x|upper(x,LenIdGra())}    // ORD_ART_GRA
  #else
    ddIndex b on  ART->iGra+upper(ART->Name1) ;
              text MSG031 ;
              format {|x|upper(x,LenIdGra())}    // ORD_ART_GRA
  #endif
#endif DEF_GRA
#ifdef DEF_ART_REF
ddIndex b on  RefTrunc(ART->Ref)          text "Referenz" ;
              format {|x| RefTrunc(x) } // ORD_ART_REF
#endif DEF_ART_REF
#ifdef DEF_GRA
  ddFld iGra     ,C, LenIdGra(),0 picture PicIdGra() ;
                 pick PickGra(ART->iGra) ;
                 postedit {|x|GetIdGra(x)} ;
                 valid (empty(ART->iGra).or.GraExist(ART->iGra)).and.ph_refresh()
  ddFld _GraName ,C,LenGraName(),0 attrib V ;
                 block GraName(ART->iGra)
#else
  ddFld iGra     ,C,0,0 attrib H
  ddFld _GraName ,C,0,0 attrib H
#endif DEF_GRA
ddFld IdPga   ,C,LenIdPga(),0  picture PIC_ID ;
                              pick PickPga(ART->IdPga)
                              * valid PgaExist(ART->IdPga)
ddFld Name2   ,C,LenArtName(),0  // Langue 2
ddFld Name1   ,C,LenArtName(),0  // Langue 1
ddFld Name3   ,C,LenArtName(),0  // Langue 3
#ifdef DEF_GEN
  ddFld IdGen   ,C,LenIdGen(),0 picture PIC_ID ;
                                pick PickGen(NIL,ART->IdGen)
#else
  ddFld IdGen   ,C,0,0 attrib H
#endif
ddFld IdArt2  ,C,LenIdArt(),0 picture PIC_ID ;
                              pick PickArt(ART->IdArt2)
ddFld IdRga   ,C,LenIdRga(),0 picture PIC_ID ;
                              pick PickRga(ART->IdRga)
                              * valid RgaExist(ART->IdRga)
ddFld PrixR   ,T,LenMont(),0 GET_DECPOS(ArtPuDecPos()) ;
                             when ArtPrPreEdit() ;
                             valid ArtPrValidate().and.ph_refresh()
ddFld Ref     ,C,LenArtRef(),0
ddFld DatCrea ,D, 8,0 when .f.
ddFld DatPrix ,D, 8,0
ddFld IdCat   ,C, 2,0 picture PIC_ID ;
                      pick PickCta(ART->IdCat) ;
                      valid ArtCatValidate().and.ph_refresh()
ddFld IdCtr   ,C, LenIdCtr(),0 picture PIC_ID pick PickCtr(ART->IdCtr)
ddFld DPA     ,T,LenMont(),0 attrib C GET_MONTANT when .f.
ddFld PAMP    ,T,LenMont(),0 attrib C GET_MONTANT when .f.
* #ifdef DEF_ACF
*   ddFld _AcfPrix   ,C,LenMont(),0 attrib V block {|| ArtAcfPrix()}
* #else
  ddFld IdPar   ,C,LenIdPar(),0 ;
                   picture PIC_ID ;
                   postedit {|x|GetIdPar(x)} ;
                   valid (empty(ART->IdPar).or.ParExist(ART->IdPar)).and.ddRefreshCurrent() ;
                   pick PickPar(CtrPrtList(ART->IdCtr),ART->IdPar)
* #endif
ddFld Attrib  ,C,3,0 picture PIC_ID ;
                     pick PickDbcAttr("ARTATTR.DBC",ART->Attrib)
                     * pick PickArtAttrib(ART->Attrib)
ddFld Prix1   ,T,LenMont(),0 ;
      when ArtP1PreEdit() ;
      valid ArtP1Validate(val(ART->PrixR)).and.ph_refresh()
ddFld Prix2   ,T,LenMont(),0 GET_DECPOS(ArtPuDecPos())
ddFld Code1   ,C, 8,0
ddFld Code2   ,C, 8,0
ddFld TVAC    ,T,LenMont(),0 valid ArtTvacValidate(val(ART->PrixR)).and.ph_refresh()
* #ifdef DEF_ACF
*   ddFld _CatLib ,C,30,0 attrib H // V block CatLibell(ART->IdCat)
* #else
  ddFld RefExt   ,C, LenRefExt(),0
* #endif
ddFld Code3   ,C, 8,0
ddFld Remarq  ,C,40,0
#ifdef DEF_UNT
  ddFld IdUnt    ,C,LenIdUnt(),0 picture PIC_ID ;
                                 pick PickUnt(ART->IdUnt) ;
                                 valid ArtUntValidate()
#else
  ddFld IdUnt    ,C,LenIdUnt(),0 picture PIC_ID
#endif
ddFld _ArtName ,C,40,0 attrib V block padr(ArtName(),40)
ddFld QteForm  ,C, 1,0 picture "!" ;
                       pick PickQteForm(ART->QteForm)
#ifdef DEF_INT
  ddFld QteStat  ,C,LenQte(),0 GET_NUM
#else
  ddFld QteStat  ,C,0,0 attrib H
#endif
ddFld PoidsN   ,C, 6,0 attrib H
ddFld PoidsB   ,C, 6,0 attrib H
ddFld IdArt    ,C, LenIdArt(),0 when .f. picture PicIdArt() attrib P
#ifdef DEF_INT
  ddFld IdInt    ,C, LenIdInt(),0 picture PIC_ID ;
                     pick PickInt(ART->IdInt)
#else
  ddFld IdInt    ,C, 0,0 attrib H
#endif
ddFld Memo1    ,M, 10,0
ddFld Memo2    ,M, 10,0
ddFld Memo3    ,M, 10,0
#ifdef DEF_PROVI
  ddFld GP     ,C, 3, 0 GET_NUM
#else
  ddFld GP     ,C, 0, 0 GET_NUM attrib H
#endif DEF_PROVI

#ifdef DEF_IVT
  action b key K_SH_F2   prompt MSG021 ;
           block ArtIvlEdit()
#endif DEF_IVT
#ifdef DEF_SUB
  action b key K_SH_F2   prompt MSG020 ;
           block ArtSubEdit(ART->IdArt)
#endif
* #ifdef DEF_TOOLBOX
*   action b key K_ALT_F2 prompt MsgMnuRename() ;
*                         block DlgArtRename() ;
*                         when recno() != lastrec() + 1
* #endif
#ifdef DEF_SPC
  action b key K_SH_F4   prompt MSG019 ;                 // O
           block ArtSpcEdit(ART->IdArt)
#endif
#ifdef DEF_VEN
  action b key K_F5 ;
           prompt MSG007 ;
           block ArtVnlEdit(ART->IdArt)
#endif
* #ifdef DEF_VNA
*   action b key K_F6   prompt MSG_VNA ;
*            block ArtVnaEdit(ART->IdArt)
* #endif DEF_VNA
#ifdef DEF_MVS
  action b key K_CTRL_F6  prompt MSG_MVS ;
           block ArtMvsEdit(ART->IdArt)
#endif DEF_MVS
#ifdef DEF_CTS
  action b key K_SH_F6 prompt MSG_CTS ;
           block ArtCtsEdit(ART->IdArt)
#endif DEF_CTS
* #ifdef DEF_ACF
*   action b key K_SH_F2 prompt MnuAcfEdit()  block ArtAcfEdit()
* #endif DEF_ACF
action b key K_ALT_F7 prompt MsgMnuAttrib() block ArtPickAttrib()
#ifdef DEF_REMISE
  action b key K_F8 prompt MSG_RpqEdit ;
                    block RpqEdit(ART->IdRga,NIL,ART->Prix1)
#endif
* #ifdef DEF_PRESTO
*   action b key K_F8 prompt MnuTrmEdit() block ArtTrmEdit(ART->IdArt)
* #endif
#ifdef DEF_SER
  action b key K_F8 prompt MSG008 block ArtSerEdit(ART->IdArt)
#endif
* #ifdef DEF_PRD
*   action b key K_F9    prompt "~ArtPrdEdit    [F9]" ;
*            block ArtPrdEdit(ART->IdArt)
*   action b key K_SH_F9 prompt "~ArtPrlEdit  [Sh-F9]" ;
*            block ArtPrlEdit(ART->IdArt)
* #endif DEF_PRD
* #ifdef DEF_ALA
*   action b key K_F9 prompt MSG_ArtAlaEdit   ;
*            block ArtAlaEdit(ART->IdArt)
* #endif DEF_ALA
* #ifdef DEF_STOCK
* action b key K_F9   prompt MSG017 block ArtZusatz() ;
*                     when USRATTR_B $ UsrAttrib()   // K
* #endif
action b key K_F12 prompt MnuMemoEdit() block ArtMemoEdit()  // T
* 20020116 action b key K_ENTER prompt NIL  block ArtDetail()
#ifdef DEF_IMPCUBIC
    action b prompt MSG004 block ArtImport()             // I
#endif
*
*
**
#ifndef DEF_REMISE
  ddFldRemove("IdRga")
#endif
#ifndef DEF_IDART2
  ddFldRemove("IdArt2")
#endif
#ifdef DEF_MONOLANG
  ddFldRemove("Name2")
  ddFldRemove("Name3")
  ddFldRemove("Memo2")
  ddFldRemove("Memo3")
#endif
#ifndef DEF_ART_REF
  ddFldRemove("Ref")
#endif
* #ifndef DEF_PRIXR
*   ddFldRemove("PrixR")
* #endif
ddEndDef()
* #ifdef DEF_ACT
*   if IsCustData("ART") ; ActExec("ART") ; endif
* #endif DEF_ACT
RETURN b

#ifdef DEF_UNT

FUNCTION ArtUntValidate
local cQteForm := UntQteForm(ART->IdUnt)
RETURN .t. if empty(cQteForm)
ART->QteForm := cQteForm
RETURN ph_refresh()

#endif DEF_UNT


FUNCTION ArtP1PreEdit()
#ifdef DEF_GRAREMISE
  RETURN .f. if val(GRA->Remise) > 0
#endif DEF_GRAREMISE
RETURN .t.

FUNCTION ArtPrPreEdit()
#ifdef DEF_GRAREMISE
  RETURN .f. if val(GRA->Remise) < 0
#endif DEF_GRAREMISE
RETURN .t.

FUNCTION ArtPrValidate()
local nRemise
* local cIdPga
ART->DatPrix := UserDate()
if "-" $ ART->PrixR
  ART->PrixR := ntom( ;
    val(ART->Prix1) * (1 + val(ART->PrixR) / 100), ;
    ArtPuDecPos() ;
  )
* elseif MntDecPos(ART->PrixR) > ArtPuDecPos()
*   if (cIdPga := PickPga(ART->IdPga)) != NIL
*     ART->IdPga := cIdPga
*   endif
endif
#ifdef DEF_GRAREMISE
  if (nRemise := val(GRA->Remise)) > 0
    ART->Prix1 := ntom( ;
      mton(ART->PrixR) * (1 + nRemise / 100), ;
      ArtPuDecPos() ;
    )
    RETURN ArtP1Validate()
  endif
#endif DEF_GRAREMISE
RETURN .t.

FUNCTION ArtP1Validate(nBase)
local nRemise
local nTaux := CtaTaux(ART->IdCat)
* local cIdPga
ART->DatPrix := UserDate()
if nBase != NIL .and. "+" $ ART->Prix1
  ART->Prix1 := ntom(nBase * (1 + mton(ART->Prix1) / 100),ArtPuDecPos())
* elseif MntDecPos(ART->Prix1) > ArtPuDecPos()
*   if (cIdPga := PickPga(ART->IdPga)) != NIL
*     ART->IdPga := cIdPga
*   endif
else
  ART->Prix1 := ntom(mton(ART->Prix1),ArtPuDecPos())
endif
ART->TVAC := ntom(val(ART->Prix1) * (100 + nTaux) / 100,ArtPuDecPos())
#ifdef DEF_GRAREMISE
  if (nRemise := val(GRA->Remise)) < 0
    ART->PrixR := ntom(val(ART->Prix1) * (1 + nRemise / 100),ArtPuDecPos())
  endif
#endif DEF_GRAREMISE
// 20010514 ph_refresh()
RETURN .t.

FUNCTION ArtTVACValidate(nBase)
local nTaux := CtaTaux(ART->IdCat)
if empty(ART->TVAC)
  ART->TVAC := ntom(val(ART->Prix1) * (100 + nTaux) / 100,ArtPuDecPos())
else
  if "+" $ ART->TVAC .and. nBase != NIL
    ART->TVAC := ntom(nBase * (1 + val(ART->TVAC) / 100))
  else
    ART->TVAC := ntom(mton(ART->TVAC),ArtPuDecPos())
  endif
  ART->Prix1 := ntom(val(ART->TVAC) * 100 / (100 + nTaux),ArtPuDecPos())
endif
ART->DatPrix := UserDate()
// 20010514 ph_refresh()
RETURN .t.

FUNCTION ArtCatValidate
RETURN ArtTvacValidate(val(ART->PrixR)) if TIMATTR_C $ MemAttrib
RETURN ArtP1Validate(val(ART->PrixR))

**
** GsbIdArt() - Get-Set-Block for field IdBud
**
FUNCTION GsbIdArt(x)
RETURN SayIdArt(FIELD->IdArt) if x == NIL
FIELD->IdArt := GetIdArt(x)
RETURN NIL

FUNCTION SayIdArt(cIdArt) ; RETURN cIdArt

#ifdef DEF_VEN

FUNCTION ArtVnlSum(cIdArt,xlFilter,xnValue)
local nValue := 0
open area oVnl(),oVen()
  ddSetOrder(ORD_VNL_ART)
  softseek cIdArt
  do while ! eof() .and. VNL->IdArt == cIdArt
    if IsArtCode(VNL->Code)
      seek VNL->IdJnl+VNL->IdDoc in VEN
      if !eof() in VEN
        if &xlFilter
          nValue += &xnValue
        endif
      endif
    endif
    skip
  enddo
close area
RETURN nValue

#endif DEF_CTS

#ifdef DEF_CTS

FUNCTION ArtCtsSum(cIdArt,xlFilter,xnValue)
local nValue := 0
open area oCts()
  softseek cIdArt
  do while ! eof() .and. CTS->IdArt == cIdArt
    if &xlFilter
      nValue += &xnValue
    endif
    skip
  enddo
close area
RETURN nValue

#endif DEF_CTS


#ifdef DEF_ODS

FUNCTION ArtOdlSum(cIdArt,xlFilter,xnValue)
local nValue := 0
open area oOdl(), oOds()
  ddSetOrder(ORD_ODL_ART)
  softseek cIdArt
  do while ! eof() .and. ODL->IdArt == cIdArt
    seek ODL->IdJnl+ODL->IdDoc in ODS
    if &xlFilter
      nValue += &xnValue
    endif
    skip
  enddo
close area
RETURN nValue

#endif DEF_ODS

#endif DEF_ART



#ifdef DEF_GRA

**
** GRA - Groupes d'articles
**
FUNCTION oGra(lRebuild)
static b
if lRebuild == NIL
  RETURN b if b != NIL
else
  b := NIL
endif
define data b    ;
  name GRA            ;
  editprint  GraPrint() ;
  create GraCreate()   ;
  predelete GraPreDelete() ;
  preedit GraPreEdit() ;
  wait {|win| GraWait(win)}
  * fileprint  GraList()
ddIndex b on GRA->iGra format {|x|GetIdGra(x)}
ddFld iGra    ,C, LenIdGra(),0  when .f. picture PicIdGra()
#ifdef DEF_GRAREMISE
  ddFld Remise   ,C,5,0 GET_NUM
#else
  ddFld Remise   ,C,0,0 attrib H
#endif
ddFld Name1   ,C,LenGraName(),0
ddFld Name2   ,C,LenGraName(),0
ddFld Name3   ,C,LenGraName(),0
ddFld Attrib  ,C, 4,0  picture PIC_ID ;
                       pick PickDbcAttr("GRAATTR.DBC",GRA->Attrib)
                       * pick GraPickAttrib(GRA->Attrib)
ddFld IdQry   ,C, 5,0  picture PIC_ID ;
                       pick PickQry("ART",".QRY",GRA->IdQry)
action b key K_ENTER   prompt MSG_GraArtEdit block GraArtEdit()
* #ifdef DEF_TOOLBOX
*   action b key K_ALT_F2 prompt MsgMnuRename() ;
*                         block GraRename() ;
*                         when recno() != lastrec() + 1
* #endif
#ifdef DEF_MONOLANG
  ddFldRemove("Name2")
  ddFldRemove("Name3")
#endif
ddEndDef()
* #ifdef DEF_ACT
*   if IsCustData("GRA") ; ActExec("GRA") ; endif
* #endif DEF_ACT
RETURN b

#else

FUNCTION oGra ; RETURN NIL

#endif DEF_GRA

#ifdef DEF_VAR

**
** VAR - Artikelvarianten
**
FUNCTION oVar()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b    ;
  name VAR
ddIndex b on VAR->IdVrt + VAR->IdVar
ddFld IdVrt   ,C, 1,0  picture PIC_ID
ddFld IdVar   ,C, LEN_IDVAR,0  picture PIC_ID
ddFld Name1   ,C,40,0
ddEndDef()
RETURN b

#endif DEF_VAR

#ifdef DEF_ACF

**
** ACF - Partnerpreise
**
FUNCTION oAcf()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name ACF                                 ;
              postedit   AcfPostEdit()
ddIndex b on  ACF->IdArt+ACF->Seq     // ORD_ACF_ART
ddIndex b on  ACF->IdPar+ACF->AcfRef  // ORD_ACF_PAR
ddFld IdArt    ,C, LenIdArt(),0 picture PicIdArt()
ddFld Seq      ,C, 3,0 postedit {|x|GetSeq(x)}
ddFld IdPar   ,C, LenIdPar(),0 picture PIC_ID ;
              postedit {|x|GetIdPar(x)} ;
              pick PickPar(CtrPrtList(ACF->IdCtr),ACF->IdPar)
ddFld Remarq  ,C,40,0
ddFld AcfRef  ,C,LenRefExt(),0
ddFld Date    ,D, 8,0
ddFld Prix    ,T,LenMont(),0 GET_DECPOS(AcfDecPos())
ddFld Packing  ,C, 6,0 GET_NUM
ddFld _ParName  ,C, 30,0 attrib V block padr(ParName(ACF->IdPar),30)
ddFld IdDev    ,C, LEN_IDDEV,0 picture PIC_ID ;
                               pick PickDev(ACF->IdDev)
ddFld _PrixCmp  ,T, LenMont(),0 attrib V when .t. ;
                block {|x| AcfPrixCmp(x) }
ddFld IdCtr    ,C, LenIdCtr(),0 picture PIC_ID pick PickCtr(ACF->IdCtr)
ddFld _ArtName ,C,40,0 attrib V block padr(ArtName(ACF->IdArt),40)
ddFld _ArtPrix ,T,LenMont(),0 attrib V ;
                              block ArtField(ACF->IdArt,{||ART->Prix1})
action b key K_SH_F4      prompt "Stammdaten ~Artikel [Shift-F4]" ;
                          block ArtPage(ACF->IdArt) ;
                          when indexord() != ORD_ACF_ART
action b key K_ENTER      block ArtPage(ACF->IdArt) ;
                          when indexord() != ORD_ACF_ART
action b key K_SH_F5      prompt MnuParPage() ;
                          block ParPage(ACF->IdPar) ;
                          when indexord() != ORD_ACF_PAR
action b key K_ENTER      block ParPage(ACF->IdPar) ;
                          when indexord() != ORD_ACF_PAR
* action b key K_F9 prompt "" block ArtAcfEdit()
* #ifdef DEF_ACT
*   if IsCustData("ACF") ; ActExec("ACF") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

FUNCTION AcfDecPos
RETURN max(DevDecPos(ACF->IdDev),ArtPuDecPos())

FUNCTION AcfPrixCmp(x)
local nPrix
local nPacking
if x == NIL
  nPrix := val(ACF->Prix)
  if ACF->IdDev!=ArtIdDev()
    nPrix := Dev2Db(ACF->IdDev,PerActive(),nPrix)
    nPrix := Db2Dev(ArtIdDev(),PerActive(),nPrix)
  endif
  nPacking := qton(ACF->Packing)
  if nPacking != 0
    nPrix := nPrix / nPacking
  endif
  RETURN ntom(nPrix,ArtPuDecPos())
endif
RETURN NIL if empty(x)
nPrix := val(x)
nPacking := qton(ACF->Packing)
if ACF->IdDev!=ArtIdDev()
  nPrix := Dev2Db(ArtIdDev(),PerActive(),nPrix)
  nPrix := Db2Dev(ACF->IdDev,PerActive(),nPrix)
endif
if nPacking != 0
  nPrix := nPrix * nPacking
endif
ACF->Prix := ntom(nPrix,AcfDecPos())
RETURN NIL

FUNCTION ArtAcfPrix
softseek ART->IdArt in ACF
RETURN space(LenMont()) if ACF->IdArt != ART->IdArt
RETURN AcfPrixCmp()

FUNCTION ArtAcfDate(cIdArt,cIdCtr) // used in ACFPRIX.ACT bei PAC
local dDate := ctod("")
open area oAcf()
  ddSetOrder(3) // ACF->IdArt+descend(dtos(ACF->Date)) bei PAC
  softseek cIdArt
  do while !eof().and.ACF->IdArt==cIdArt
    if ACF->IdCtr==cIdCtr
      dDate:=ACF->Date
      exit
    endif
    skip
  enddo
close area
RETURN dDate

FUNCTION VnlAcfTouch() // used in PAC\TIM.DBI OnvnlClose
** update ACF->Date if
local lOkay :=.f.
local cIdArt := padr(VNL->IdArt,LenIdArt())
local cIdCtr := JnlIdCtr(VNL->IdJnl)
open area oAcf()
  lOkay :=.t.
  softseek cIdArt
  do while !eof().and.ACF->IdArt==cIdArt
    if ACF->IdCtr==cIdCtr
      if ACF->IdPar==VEN->IdPar
        if ACF->IdDev==VEN->IdDev
          if ACF->Date <= VEN->Date
            if ddRecLock()
              ACF->Date:=VEN->Date
              ACF->Prix:=VNL->PrixU
              unlock record
              exit
            else
              lOkay :=.f.
            endif
          endif
        endif
      endif
    endif
    skip
  enddo
close area
RETURN lOkay

#else

FUNCTION oAcf() ; RETURN NIL

#endif DEF_ACF


#ifdef DEF_AGR

**
** AGM - Artikelgruppenmitglieder
**
FUNCTION oAgm()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name AGM                                 ;
              postedit   AgmPostEdit()
ddIndex b on  AGM->IdArt+AGM->Seq     // ORD_AGM_ART
ddIndex b on  AGM->IdAgr+AGM->AgmRef  // ORD_AGM_AGR
ddFld IdArt    ,C, LenIdArt(),0
ddFld IdAgr   ,C, LenIdAgr(),0 picture PIC_ID ;
                               pick PickAgr(NIL,AGM->IdAgr)
ddFld _AgrName  ,C, 30,0 attrib V block padr(AgrName(AGM->IdAgr),30)
ddFld _ArtName ,C,40,0 attrib V block padr(ArtName(AGM->IdArt),40)
action b key K_SH_F4      prompt "Stammdaten ~Artikel [Shift-F4]" ;
                          block ArtPage(AGM->IdArt) ;
                          when indexord() != ORD_AGM_ART
action b key K_ENTER      block ArtPage(AGM->IdArt) ;
                          when indexord() != ORD_AGM_ART
action b key K_SH_F5      prompt MnuParPage() ;
                          block ParPage(AGM->IdPar) ;
                          when indexord() != ORD_AGM_PAR
action b key K_ENTER      block ParPage(AGM->IdPar) ;
                          when indexord() != ORD_AGM_PAR
ddEndDef()
RETURN b

#endif DEF_AGR

#ifdef DEF_GEN

**
** GEN - Comptes g‚n‚raux ( anciennement "Centres de frais")
**
FUNCTION oGen(lRebuild)
static b
if lRebuild == NIL
  RETURN b if b != NIL
else
  b := NIL
endif
define data b                 ;
       name GEN               ;
       create GenCreate(GEN->IdGen,GEN->Libell1)    ;
       wait {|x| GenWait(x)}         ;
       editprint GenPrint() ;
       postedit   GenPostedit() ;
       preedit   GenPreEdit() ;
       predelete GenPreDelete( GEN->IdGen )
ddIndex b on GEN->IdGen                   // ORD_GEN_IDGEN
ddIndex b on GEN->IdCtr + GEN->IdGen      // ORD_GEN_IDCTR
#ifdef DEF_BIL
ddIndex b on GEN->IdBil + GEN->IdGen for !empty(GEN->IdBil) 
  // ORD_GEN_BIL
#endif DEF_BIL
ddFld IdGen   ,C, LenIdGen(),0  when .f. picture PIC_ID
#ifdef DEF_TAX
ddFld IdTax   ,C, LEN_IDTAX,0 picture PIC_ID ;
                      pick PickTax(GEN->IdTax,GEN->IdCtr,UserDate()) ;
                      when USRATTR_B $ UsrAttrib()
#else
ddFld IdTax   ,C, 0,0 attrib H
#endif
ddFld IdCat   ,C, LEN_IDCTF,0  picture PIC_ID
                       * pick PickCtf(GEN->IdCtr,GEN->IdCat)
ddFld Attrib  ,C, 5,0 picture PIC_ID ;
                      pick PickGenAttrib(GEN->Attrib) ;
                      when USRATTR_B $ UsrAttrib()
ddFld _IdGen  ,C,LenIdGen()*2-1,0 attrib V ;
                                  block IdStruct(GEN->IdGen,1)
ddFld Libell1 ,C,LenGenName(),0 picture "@K@S25" ;
                      when USRATTR_B $ UsrAttrib()
ddFld Libell2 ,C,LenGenName(),0 picture "@K@S25" ;
                      when USRATTR_B $ UsrAttrib()
ddFld Memo    ,M,10,0
ddFld IdCtr   ,C,LenIdCtr(),0 picture PIC_ID ;
                     pick PickCtr(GEN->IdCtr) ;
                     when USRATTR_B $ UsrAttrib()
ddFld Libell3 ,C,LenGenName(),0 picture "@K@S25" ;
                      when USRATTR_B $ UsrAttrib()
ddFld IdClj    ,C, LEN_IDCLJ,0 picture PIC_ID ;
                               pick PickClj(GEN->IdCtr,GEN->IdClj) ;
                               when USRATTR_B $ UsrAttrib()
#ifdef DEF_BIL
  ddFld IdBil   ,C, LenIdBil(),0 picture PIC_ID ;
                    pick DbfPick( ;
                      {oBil()},;
                      GEN->IdGen + " : Bilanzposten", ;
                      "BILPICK", ;
                      GEN->IdBil,;
                      NIL,NIL,NIL, ;
                      "BIL->IdBil",;
                    ) ;
                    when USRATTR_B $ UsrAttrib()
#endif DEF_BIL
ddFld IdDev    ,C, LEN_IDDEV,0 picture PIC_ID ;
                               pick PickDev(GEN->IdDev)
* #ifdef DEF_4LANG
* ddFld Libell4 ,C,LenGenName(),0 picture "@K@S25" ;
*                       when USRATTR_B $ UsrAttrib()
* #endif
* #ifdef DEF_VEN
*   action b key    K_F5   ;
*            prompt MSG007 ;
*            block  ArtGetDoc(LNCODE_GEN, GEN->IdGen)
* #endif
#ifdef DEF_VEN
  action b key K_F5 ;
           prompt MSG007 ;
           block ArtVnlEdit(GEN->IdGen)
#endif
#ifdef DEF_HST
  action b key    K_F9 ;
           prompt MSG012 ;
           block  GenHstEdit(GEN->IdGen)
#endif DEF_HST
#ifdef DEF_CTG
  action b key K_SH_F9 prompt MSG013 block GenCtgEdit()
#endif DEF_CTG
* #ifdef DEF_TOOLBOX
*   action b key    K_ALT_F2 ;
*            prompt MsgMnuRename()  ;
*            block GenRename() ;
*                         when recno() != lastrec() + 1
* #endif
#ifdef DEF_MEMO
  action b key   K_F12 prompt MnuMemoEdit() ;
           block GenMemoEdit(trim(GEN->Libell1))
#endif
#ifdef DEF_MVA
  action b key    K_CTRL_F9 ;
           prompt "Historik anal~ytisch  [Ctrl-F9]" ;
           block  GenMvaEdit(GEN->IdGen)
#endif DEF_MVA
#ifdef DEF_IMPCUBIC
    action b prompt MSG004 block GenImport()
#endif
action b key K_ALT_F7 prompt MsgMnuAttrib() block GenPickAttrib()
* #ifdef DEF_ACT
*   if IsCustData("GEN") ; ActExec("GEN") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

#else

FUNCTION oGen
RETURN NIL

#endif DEF_GEN

FUNCTION GetIdGen(x)
RETURN x if empty(x)
RETURN padr(trim(x),LenIdGen(),"0")


#ifdef DEF_CFL

#define CFL_NAME  1
#define CFL_TYPE  2
#define CFL_LEN   3
#define CFL_DEC   4
#define CFL_ALEN  4

FUNCTION CflList(cAlias)
local aCfl := {}
local a := ReadArray("CFL.DBC",CFL_ALEN + 1)
local i
local cfl
for i := 1 to len(a)
  if a[i][1] == cAlias
    cfl := array(CFL_ALEN)
    cfl[CFL_NAME] := trim(a[i][CFL_NAME + 1])
    cfl[CFL_TYPE] := a[i][CFL_TYPE + 1]
    cfl[CFL_LEN]  := val(a[i][CFL_LEN + 1])
    cfl[CFL_DEC]  := val(a[i][CFL_DEC + 1])
    aadd(aCfl, cfl)
  endif
next i
RETURN aCfl

#endif DEF_CFL


**
** PAR - comptes particuliers
**
FUNCTION oPar(lRebuild)
static b := NIL
if lRebuild == NIL
  RETURN b if b != NIL
else
  b := NIL
endif
define data b             ;
  name PAR                  ;
  predelete  ParPreDelete(PAR->IdPar)                ;
  create     ParCreate() ;
  preedit    ParPreEdit() ;
  postedit   ParPostEdit()              ;
  wait       {|x| ParWait(PAR->IdPar,x)} ;
  editprint  ParPrint() ;
  pickflt    ParPickFilter()
ddIndex b on PAR->IdPar text MSG023 format {|x| GetIdPar(x) }
ddIndex b on PAR->IdPrt+upper(PAR->Firme) ;
             text MSG024 ;
             format {|x| eupper(x,LEN_IDPRT) } // ORD_PAR_PRTNAME
ddIndex b on PAR->Pays+PAR->CP+upper(PAR->Rue)+PAR->RueNum  ;
             text MSG025 ;
             format {|x| eupper(x,LEN_IDNAT+8) }
* ddIndex b on PAR->NoTva text "MWSt-Nummer"
ddFld IdPar   ,C, LenIdPar(),0  when .f. picture PIC_ID
#ifdef DEF_VEN
  ddFld IdGen   ,C, LenIdGen(),0 pick PickGen(NIL,PAR->IdGen) ;
                    postedit {|x| GetIdGen(x) }
#else
  ddFld IdGen   ,C, 0,0 attrib H
#endif
ddFld Firme   ,C,LenParName(),0
ddFld Name2   ,C,LenParName(),0
ddFld Rue     ,C,LenParName(),0 picture "@K@S23" ;
                      pick PickStreet(PAR->Pays,PAR->CP,PAR->Rue)
ddFld CP      ,C, 8,0 valid ParPlzValidate() ;
                      picture PIC_ID  ;
                      pick PickPlz(PAR->Pays,PAR->CP)
ddFld IdPrt   ,C,LEN_IDPRT,0 picture PIC_ID ;
                             pick PickPrt(NIL,NIL,PAR->IdPrt,PRT_ID)
ddFld Pays    ,C, LEN_IDNAT,0 valid ParPlzValidate() ;
                      picture PIC_ID ;
                      pick PickNat(PAR->Pays) // ,NIL,NAT_IDNAT)
ddFld Tel     ,C,LenTel(),0 postedit {|x| TelPostEdit(x,PAR->Pays,PAR->CP) }
ddFld Fax     ,C,LenTel(),0 postedit {|x| TelPostEdit(x,PAR->Pays,PAR->CP) }
ddFld Compte1 ,C,15,0 postedit {|x| BqePostEdit(x) } ;
                      valid BqeValidate(PAR->Compte1)
ddFld NoTVA   ,C,LEN_NOTVA,0 picture PIC_ID ;
                      postedit {|x| GetNoTva(x,PAR->Pays) } ;
                      valid ValNoTva(PAR->NoTva)
ddFld Compte3 ,C,25,0
ddFld IdPgp   ,C,LenIdPgp(),0 picture PIC_ID ;
                             pick PickPgp(PAR->IdPgp,PAR->IdPrt) ;
                             valid PgpExist(PAR->IdPgp,PAR->IdPrt)
ddFld Birth   ,D, 8,0 valid ph_refresh()
ddFld _Age    ,C, 4,0 attrib V block str(Age(PAR->Birth),4,0)
ddFld Debit   ,T,LenMont(),0 when .f. value val(PAR->Debit)
ddFld Credit  ,T,LenMont(),0 when .f. value val(PAR->Credit)
ddFld Attrib  ,C, LenParAttrib(),0 picture PIC_ID pick PickPra(PAR->Attrib)
#ifdef DEF_JNL
  ddFld IdMfc   ,C, LenIdMfc(),0 picture PIC_ID ;
                 pick PickMfc(PAR->IdMfc,trim(ParName())) ;
                 valid ParMfcValidate(PAR->IdMfc)
#else
  ddFld IdMfc   ,C, LenIdMfc(),0 picture PIC_ID
#endif
ddFld Langue  ,C, LenIdLng(),0 picture PIC_ID               ;
                      pick PickLng(PAR->Langue) ;
                      valid IsLangue(PAR->Langue)
ddFld IdBud     ,C, LenIdBud(),0 picture PIC_ID ;
                    block {|x| GsbIdBud(x) } ;
                    pick PickBud(PickCtr(),PAR->IdBud)
ddFld _xxxx   ,C,35,0 attrib H
ddFld Prof    ,C,LEN_IDPRF,0 picture PIC_ID ;
                      pick PickPrf(PAR->Prof)
ddFld Code1   ,C, 12,0 picture PIC_ID
ddFld Code2   ,C, 12,0 picture PIC_ID
ddFld Code3   ,C, 12,0 picture PIC_ID
ddFld DatCrea ,D, 8,0 when .f.
#ifdef DEF_TAX
  ddFld IdReg   ,C,LEN_IDREG,0 picture PIC_ID ;
                               pick PickReg(PAR->IdReg) ;
                               valid IdRegValidate(PAR->IdReg)
#else
  ddFld IdReg   ,C,0,0 attrib H
#endif
ddFld _xxx    ,C, 6,0 attrib H
ddFld _PlzNom ,C,26,0 attrib V ;
                      block padr(PlzName(PAR->Pays,PAR->CP),26)
* ddFld _PlzNom ,C,26,0 attrib V ;
*                       block padr(ParCity(),26)
ddFld Allo    ,C,35,0 pick PickAlc()
ddFld _Name   ,C,40,0 attrib V block padr(ParName(),40)
ddFld NB1     ,C,60,0 picture "@K@S42"
ddFld NB2     ,C,60,0 picture "@K@S42"
ddFld IdDev    , C, LEN_IDDEV,0 picture PIC_ID ;
               pick PickDev(PAR->IdDev) ;
               when empty(PAR->Debit+PAR->Credit)
ddFld Memo    ,M,10,0
ddFld Compte2 ,C,15,0 postedit {|x| BqePostEdit(x) } ;
                      valid BqeValidate(PAR->Compte2)
ddFld RueNum  ,C, 4,0 GET_NUM
ddFld RueBte  ,C, 6,0
ddFld _Rue    ,C,30,0 attrib V block padr(ParStreet(),30)
#ifdef DEF_HST
  ddFld MvpDate ,D, 8,0
#else
  ddFld MvpDate ,D, 8,0 attrib H
#endif DEF_HST
*#ifdef DEF_RUN
*  ddFld IdCat   ,C,LenIdCat(),0 picture PIC_ID pick PosPickCat()
*  ddFld IdClb   ,C,LenIdClb(),0 picture PIC_ID pick PickClb(POS->IdClb)
*  ddFld IdEqu   ,C,LenIdEqu(),0 picture PIC_ID pick PickEqu(POS->IdEqu)
* #ifdef DEF_TOOLBOX
*#else
*#endif
*   action b key K_ALT_F2 prompt MsgMnuRename() block ParRename() ;
*                         when recno() != lastrec() + 1
* #endif DEF_TOOLBOX
#ifdef DEF_SPC
  action b key K_SH_F4   prompt MSG019 ;
           block ParSpcEdit(PAR->IdPar)
#endif
* #ifdef DEF_VEN
*   action b key K_F5 prompt MSG007 block ParVenEdit(PAR->IdPar)
* #endif
#ifdef DEF_VNA
  * action b key K_F6   prompt MSG_VNA ;
  *          block ParVnaEdit(PAR->IdPar)
  * action b key K_ALT_F6   prompt MSG_VNAAUTO ;
  *          block ParVnaAuto(PAR->IdPar)
#endif DEF_VNA
* #ifdef DEF_ACF
*   action b key K_SH_F2 prompt MnuAcfEdit() block ParAcfEdit(PAR->IdPar)
* *#else
*  #ifdef DEF_ART
*    action b key K_ALT_F6 prompt MnuAcfEdit() block ParArtEdit(PAR->IdPar)
*  #endif DEF_ART
* #endif DEF_ACF
* #ifdef DEF_MVS
*   action b key K_CTRL_F6   prompt MSG_MVS ;
*            block ParMvsEdit(PAR->IdPar)
* #endif DEF_MVS
action b key K_ALT_F7 prompt MsgMnuAttrib() block ParPickAttrib()
* F8 raus seit 20041203:
* #ifdef DEF_PRESTO
*   action b key K_F8  prompt MnuTrmEdit() block ParTrmEdit(PAR->IdPar)
* #endif
* #ifdef DEF_MSG
*   action b key K_SH_F8 prompt MSG011 ;
*            block ParMsgEdit(PAR->IdPar)
* #endif
#ifdef DEF_EVT
  action b key K_F8 prompt MsgEviEdit ;
           block ParEviEdit(PAR->IdPar)
#endif
#ifdef DEF_IMP
  action b key K_F9     prompt MSG012     block ParMviEdit(PAR->IdPar)
  action b key K_ALT_F9 prompt MSG_PARMV2 block ParMv2Edit(PAR->IdPar)
  action b key K_SH_F9  prompt MSG_PARTRE ;
           block ParMviEdit( ;
             PAR->IdPar, ;
             trim(ParName()) + " : Tresoreriebuchungen", ;
             "JnlIdGrj(MVI->IdJnl)=='TRE'", ;
             NIL ;
           )
#endif DEF_IMP
#ifdef DEF_HST
  action b key K_F9 prompt MSG012 ;
           block ParHstEdit(PAR->IdPar) ;
           when USRATTR_C $ UsrAttrib()
#endif DEF_HST
#ifdef DEF_TLG
  action b key NIL prompt "Tilgungs~plan                  " ;
           block ParTlgEdit(PAR->IdPar)
#endif DEF_TLG
#ifdef DEF_TIL
  action b key NIL prompt "Tilgungs~pl„ne                 " ;
           block ParTilEdit(PAR->IdPar)
#endif DEF_TIL
#ifdef DEF_CTP
  action b key K_SH_F9 prompt MSG013 ;
           block  ParCtpEdit(PAR->IdPar) ;
           when USRATTR_C $ UsrAttrib()
#endif DEF_CTP
#ifdef DEF_MEMO
  action b key K_F12 prompt MnuMemoEdit() block ParMemoEdit()
#endif
#ifdef DEF_PSC
  action b key NIL     prompt MSG005 block Par1PscEdit()
  action b key NIL     prompt MSG006 block Par2PscEdit()
#endif
* #ifdef DEF_PLS
*   action b key K_SH_F6 prompt MnuMbrEdit block ParMbrEdit(PAR->IdPar)
*   action b key K_F6    prompt MnuMbrBrowse block ParMbrBrowse(PAR->IdPar)
* #endif DEF_PLS
#ifdef DEF_ANW
  action b key NIL       prompt MSG037 block CliGetAnw()
#endif
action b key K_ENTER prompt NIL  block ParDetail()
#ifdef DEF_DGR
  action b key NIL   prompt MSG_RAPEDIT block ParRapEdit(PAR->IdPar)
#endif DEF_DGR
#ifdef DEF_LIC
  action b key NIL prompt MsgLicEdit() ;
           block ParLicEdit(PAR->IdPar)
#endif DEF_LIC
#ifndef DEF_MEMO
  ddFldRemove("Memo")
#endif
#ifndef DEF_IMP
  ddFldRemove("IdBud")
#endif
#ifndef DEF_BIRTH
  ddFldRemove("Birth")
  ddFldRemove("_Age")
#endif DEF_BIRTH
* #ifdef DEF_ACT
*   if IsCustData("PAR") ; ActExec("PAR") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

#xtranslate LenMnuItem() => 31

FUNCTION MsgLicEdit() ; RETURN padr("~Licences",LenMnuItem())


FUNCTION NatValidate(cIdNat)
RETURN .t. if empty(cIdNat)
RETURN NatExist(cIdNat)

FUNCTION ParStreet(cIdPar)
// 20070921 sleep(5)
RETURN ParField(cIdPar,{||trim1(PAR->Rue) + ltrim(PAR->RueNum) + " " + trim(PAR->RueBte)})

#ifdef DEF_PRESTO

**
** TAC - Types d'activit‚
**
FUNCTION oTac()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b              ;
  name TAC                      ;
  predelete TacPreDelete()         ;
  create   TacCreate()
ddIndex b on TAC->IdTac
ddFld IdTac   ,C, LenIdArt(),0 when .f.
ddFld Name1   ,C,40,0 picture "@K@S30" // width 30
ddFld Name2   ,C,40,0 picture "@K@S30" // width 30
ddFld Name3   ,C,40,0 picture "@K@S30" // width 30
ddFld Tarif   ,T,LenMont(),0 GET_MONTANT
ddFld Attrib  ,C, 4,0 picture PIC_ID pick TacPickAttr(TAC->Attrib)
#ifdef DEF_MEMO
  ddFld Memo    ,M,10,0
#else
  ddFld Memo    ,M,10,0 attrib H
#endif
action b key K_F8 prompt MnuTrmEdit() block TacTrmEdit(TAC->IdTac)
#ifdef DEF_MEMO
  action b key K_F12 prompt MnuMemoEdit() ;
             block WinMemoEdit(76,TAC->IdTac + " " + TacName())
#endif
* #ifdef DEF_ACT
*   if IsCustData("TAC") ; ActExec("TAC") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

**
** TacDelete()
**
FUNCTION TacPreDelete()
local lOkay := .f. // nReturn := DDDEL_FAIL
RETURN ConfirmDelete() if empty(TAC->IdTac)
open area oTrm()
  ddSetOrder(ORD_TRM_TACDATE)
  softseek TAC->IdTac
  if TRM->IdTac != TAC->IdTac
    lOkay := .t. // nReturn := DDDEL_CONFIRM
  else
    SetMsg("Verweigert.")
  endif
close area
RETURN lOkay // nReturn

#endif DEF_PRESTO

**
** ChkProf()
**
*FUNCTION ChkProf(cProf)
*local lRet := .f.
*RETURN .T. if empty(cProf)
*open area oPrf()
*  seek cProf
*  if eof()
*    SetMsg(MSG022) // "Code profession inconnu.")
*  else
*    lRet := .t.
*  endif
*close area
*RETURN lRet

**
** PLZ - Codes postaux & communes
**
FUNCTION oPlz()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name PLZ
            // fileprint PlzListe() 19990915
ddIndex b on PLZ->Pays+PLZ->CP          text MSG028
ddIndex b on PLZ->Pays+upper(PLZ->Nom) ;
          text MSG036 ;
          format {|x|eupper(x,LEN_IDNAT)}
ddFld Pays    ,C, LEN_IDNAT,0  picture PIC_ID ;
                               pick PickNat(PLZ->Pays) ;
                               valid NatValidate(PLZ->Pays)
ddFld CP      ,C, 8,0  picture PIC_ID
ddFld Nom     ,C,28,0
ddFld Format  ,C, 1,0  pick PickTlf(PLZ->Format)
ddFld Prefix  ,C, 6,0
action b key K_ENTER prompt "~Partner     [Enter]" block PlzGetPar()
ddEndDef()
RETURN b

#ifdef DEF_LOC

FUNCTION oLoc() // Geographical Locations 
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name LOC
ddIndex b on LOC->IdLoc
ddIndex b on eupper(LOC->Name) format {|x|eupper(x)}
ddFld IdLoc   ,C, 6,0 // postedit {|x|GetNum(x)} attrib P
ddFld Name    ,C,40,0
ddFld Lati    ,Q,10,0 GET_DECPOS(6)
ddFld Long    ,Q,10,0 GET_DECPOS(6)
ddFld x       ,Q,10,0 
ddFld y       ,Q,10,0 
action b key K_ALT_W prompt "~Google maps     [Alt-W]" ;
  block OpenUrl("http://maps.google.com/maps?ll=";
    +alltrim(LOC->Lati)+","+alltrim(LOC->Long)+"&spn="+LocSpn())
// http://mapki.com/wiki/Google_Map_Parameters
// http://maps.google.com/maps?f=q&hl=de&geocode=&q=estland&ie=UTF8&
// http://maps.google.com/maps?ll=58.765574,24.265527&spn=0.003288,0.011759&t=h&z=17
// http://maps.google.com/maps?ll=58.765574,24.265527&spn=0.001644,0.005879&z=18
// http://maps.google.com/maps?f=q&hl=de&geocode=&q=tallinn&ie=UTF8&ll=59.438879,24.754429&spn=0.051584,0.188141&t=h&z=13&iwloc=addr
// http://maps.google.com/maps?ll=59.438879,24.754429&spn=0.051584,0.188141
ddEndDef()
RETURN b

FUNCTION LocSpn
/*
Erdumfang ist ca. 40075 Km.
40000 Km -> 360 Grad
1 Meter -> 360 / 40.000.000 Grad
*/
local x:=iif(empty(LOC->x),1,val(LOC->x))
local y:=iif(empty(LOC->y),1,val(LOC->y))
RETURN alltrim(str(x*360/40000000,20,6))+","+alltrim(str(y*360/40000000,20,6))

#endif DEF_LOC

#ifdef DEF_JNL

FUNCTION DocName(cIdJnl,cIdDoc,cLine)
local doc := DocInfo(cIdJnl,cIdDoc,cLine)
RETURN space(30) if doc == NIL
RETURN padr(doc[DOC_LIBELL],30)

#endif DEF_JNL

#ifdef DEF_GEN

**
** MVT - mouvements comptes g‚n‚raux
**
*FUNCTION oMvt()
** local b
*static b := NIL
*if b != NIL ; RETURN b ; endif
*define data b   ;
*  name MVT             ;
*  create DDCREATE_FAIL ;
*  delete DDDEL_FAIL
*ddIndex b on MVT->IdGen+MVT->Periode+dtos(MVT->Date) ;
*        text MSG034                                   // ORD_MVT_GENDATE
*ddIndex b on MVT->IdJnl+MVT->IdDoc+MVT->Periode    ;
*        text MSG033                                   // ORD_MVT_DOC
*ddIndex b on MVT->IdGen+MVT->Match+dtos(MVT->Date)    // ORD_MVT_GENMATCH
*ddFld IdGen     ,C, LenIdGen(),0 when .f.
*ddFld IdJnl     ,C, LenIdJnl(),0 picture PIC_ID when .f.
*ddFld IdDoc     ,C, LEN_IDDOC,0 picture PIC_ID when .f.
*ddFld Date      ,D, 8,0 when .f.
*ddFld _Compte   ,C, 30,0 attrib V ;
*                         block padr(GenName(MVT->IdGen),30)
*ddFld _Document ,C, 30,0 attrib V ;
*                         block HstDocName(MVT->IdJnl,MVT->IdDoc,MVT->Line)
*ddFld Periode   ,C, LEN_PERIODE,0 when .f.
*ddFld Mont      ,C, 10,0 when .f.
*ddFld Line      ,C, LEN_POS,0 when .f.
*ddFld DC        ,C, 1,0 when .f.
*ddFld _Debit ,C, LenMont(),0  GET_MONTANT attrib V ;
*                       block {|x| GsbMontD(x) }    ;
*                       value if(MVT->DC == DC_DEBIT,val(MVT->Mont),0)
*ddFld _Credit,C, LenMont(),0  GET_MONTANT attrib V ;
*                       block {|x| GsbMontC(x) } ;
*                       value if(MVT->DC == DC_CREDIT,val(MVT->Mont),0)
*ddFld _ParOrNb ,C,30,0 attrib V ;
*                       block DocPartner(MVT->IdJnl,MVT->IdDoc,MVT->Line)
*ddFld Match     ,C, LenIdJnl()+LEN_IDDOC,0 ;
*                    picture PIC_ID ;
*                    pick  PickMvt(MVT->IdGen,MVT->Match) ;
*                    valid MvtMatchValidate()
*ddFld Satis     ,C, 1,0 when .f.
*action b key K_ENTER prompt MsgMnuDocPage() ;
*                     block DocPage(MVT->IdJnl,MVT->IdDoc)
*action b key K_CTRL_F5  prompt "~Lettrierung      [Ctrl-F5]"    ;
*                        block MvtGenSatisfy()
*#ifdef DEF_ACT
*  if IsCustData("MVT") ; ActExec("MVT") ; endif
*#endif DEF_ACT
*RETURN b

* bis 20070912 :
* FUNCTION HstDocName(cIdJnl,cIdDoc,cLine)
* local doc := DocInfo(cIdJnl,cIdDoc,cLine)
* RETURN space(30) if doc == NIL
* RETURN padr(trim1(doc[DOC_LIBELL],30) if empty(doc[DOC_NB])
* RETURN padr(doc[DOC_NB],30)

FUNCTION HstDocName(cIdJnl,cIdDoc,cLine)
local doc := DocInfo(cIdJnl,cIdDoc,cLine)
RETURN cIdJnl+cIdDoc+"?" if doc == NIL
RETURN trim1(doc[DOC_LIBELL])+doc[DOC_NB]

FUNCTION DocPartner(cIdJnl,cIdDoc,cLine)
local doc
RETURN padr("(Saldo)",30) if eof()
doc := DocInfo(cIdJnl,cIdDoc,cLine)
RETURN space(30) if doc == NIL
RETURN padr(trim1(ParName(doc[DOC_IDPAR])) + doc[DOC_LIBELL],30)

FUNCTION DocParName(cIdJnl,cIdDoc,cLine)
local doc := DocInfo(cIdJnl,cIdDoc,cLine)
RETURN "" if doc == NIL
RETURN ParName(doc[DOC_IDPAR])

FUNCTION HstGenLibell(cIdJnl,cIdDoc,cLine)
local doc := DocInfo(cIdJnl,cIdDoc,cLine)
RETURN "" if doc == NIL
RETURN trim1(ParName(doc[DOC_IDPAR])) ;
       + trim1(doc[DOC_NB]) ;
       + trim(doc[DOC_LIBELL])

FUNCTION HstParLibell(cIdJnl,cIdDoc,cLine)
local doc := DocInfo(cIdJnl,cIdDoc,cLine)
RETURN "" if doc == NIL
RETURN trim1(doc[DOC_NB]) + trim(doc[DOC_LIBELL])



*FUNCTION MvtGenSatisfy()
*default sdMvpDate to ctod("")
*open window ("Lettrierung prfen") size 4,50 help GENSATIS
*say "Nur Buchungen bercksichtigen bis zum "
*get sdMvpDate
*WinCr()
*get scAutoSatisfy checkbox
*say " automatisch prfen wenn Match ver„ndert"
*nKey := ReadScr()
*close window
*RETURN .f. if nKey == K_ESC
*GenSatisfy(MVT->IdGen,sdMvpDate)
*ddRefreshAll()
*RETURN MnuDone()
*
*FUNCTION MvtMatchValidate
*local doc
*local cMatch
*if (doc := DocInfo(MVT->IdJnl,MVT->IdDoc,MVT->Line)) != NIL
*  if empty(doc[DOC_MATCH])
*    cMatch := MVT->IdJnl + MVT->IdDoc
*  else
*    cMatch := doc[DOC_MATCH]
*  endif
*  if empty(MVT->Match)
*    MVT->Match := cMatch
*  * elseif MVT->Match != cMatch
*  *   DocSetMatch(MVT->IdJnl,MVT->IdDoc,MVT->Line,MVT->IdPar,MVT->Match)
*  endif
*endif
*if scAutoSatisfy == BUTTON_ON
*  default sdMvpDate to ctod("")
*  GenSatisfy(MVT->IdGen,sdMvpDate)
*  ddRefreshAll()
*endif
*RETURN .t.

#endif DEF_GEN

#ifdef DEF_HST

**
** HST - historique comptable
**
FUNCTION oHst()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b   ;
  name HST             ;
  create DDCREATE_FAIL ;
  editprint HstPrint() ;
  predelete .f. ;
  wait   {|x| HstWait(x) }
ddIndex b on HST->IdPar+HST->Periode+dtos(HST->Date) // ORD_HST_PARDATE
ddIndex b on HST->IdPar+HST->Match+dtos(HST->Date)   // ORD_HST_PARMATCH
ddIndex b on HST->IdGen+HST->Periode+dtos(HST->Date) // ORD_HST_GENDATE
ddIndex b on HST->IdGen+HST->Match+dtos(HST->Date)   // ORD_HST_GENMATCH
ddIndex b on HST->IdJnl+HST->IdDoc+HST->Line         // ORD_HST_DOC
* ddIndex b on HST->Periode+dtos(HST->Date)            // ORD_HST_DATE
ddFld IdGen     ,C, LenIdGen(),0 when .f.
ddFld IdPar     ,C, LenIdPar(),0 when .f.
ddFld IdJnl     ,C, LenIdJnl(),0 picture PIC_ID when .f.
ddFld IdDoc     ,C, LEN_IDDOC,0 picture PIC_ID when .f.
ddFld Line      ,C, LEN_POS,0 when .f.
ddFld Date      ,D, 8,0 when .f.
ddFld _CptName  ,C, 30,0 attrib V block padr(HstCptName(),30)
ddFld _Remark   ,C, 30,0 attrib V ;
                when PerIsOpen(HST->Periode,HST->IdJnl) ;
                block {|x|GsbHstDocName(x)}
ddFld Periode   ,C, LEN_PERIODE,0 when .f.
ddFld DC        ,C, 1,0 when .f.
ddFld Mont      ,T, LenMont(),0 when .f.
ddFld MontDev   ,T, LenMont(),0 when .f.
ddFld Match     ,C, LenIdJnl()+LEN_IDDOC,0 picture PIC_ID ;
                    valid HstMatchValidate()
ddFld Satis     ,C, 1,0 when .f.
ddFld IdCtr     ,C, LenIdCtr(),0 when .f.
#ifdef DEF_TAX
  ddFld IdTax     ,C, LEN_IDTAX,0 picture PIC_ID
#else
  ddFld IdTax     ,C, 0,0  attrib H
#endif DEF_TAX
ddFld _Debit    ,T, LenMont(),0  GET_MONTANT attrib V ;
                    when .f. block {|x| GsbMontD(x) } ;
                    value if(HST->DC == DC_DEBIT,HstMont(SetDevise()),0)
ddFld _Credit   ,T, LenMont(),0  GET_MONTANT attrib V ;
                    when .f. block {|x| GsbMontC(x) } ;
                    value if(HST->DC == DC_CREDIT,HstMont(SetDevise()),0)
ddFld _MontUs   ,T, LenMont(),0  GET_MONTANT attrib V ;
                    when .f. block {|x| HstMontUs(x) }
ddFld _DocParName  ,C,30,0 attrib V ;
                    block DocPartner(HST->IdJnl,HST->IdDoc,HST->Line)
ddFld _DocName   ,C, 30,0 attrib V ;
                    block HstDocName(HST->IdJnl,HST->IdDoc,HST->Line)
ddFld IdDev    ,C, LEN_IDDEV,0 picture PIC_ID ;
                   when .f. ;
                   pick PickDev(HST->IdDev) // 20010411
action b key K_ENTER   prompt MsgMnuDocPage()    ;
                       block DocPage(HST->IdJnl,HST->IdDoc)
#ifdef DEF_FIN
*action b key K_F5      prompt "~Barzahlung                [F5]"    ;
*                       block ParCash(HST->IdPar) ;
*                       when ! empty(HST->IdPar)
#endif DEF_FIN
action b key K_CTRL_F5 prompt "~Lettrierung          [Ctrl-F5]"    ;
                       block HstParSatisfy()
action b key K_ALT_F9  prompt MnuHstMatch() ;
                       block MatchHstEdit(HST->IdPar,HST->Match)
* #ifdef DEF_ACT
*   if IsCustData("HST") ; ActExec("HST") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b


FUNCTION GsbHstDocName(x)
local b
if x == NIL
  RETURN HstDocName(HST->IdJnl,HST->IdDoc,HST->Line) if left(indexkey(),10)=="HST->IdPar"
  RETURN DocPartner(HST->IdJnl,HST->IdDoc,HST->Line)
endif
#ifdef DEF_FIN
  if JnlAlias(HST->IdJnl)==JNLALIAS_FIN
    b := {||(FNL->Libell:=x)!=NIL}
    RETURN .t. if DbfPeek(oFnl(),;
      HST->IdJnl+HST->IdDoc+HST->Line,;
      {||TryRecLock(b)},.f.)
  endif
#endif
#ifdef DEF_VEN
  if JnlAlias(HST->IdJnl)==JNLALIAS_VEN
    b := {||(VEN->NB1:=x)!=NIL}
    RETURN .t. if DbfPeek(oVen(),;
      HST->IdJnl+HST->IdDoc,;
      {||TryRecLock(b)},.f.)
  endif
#endif
RETURN ! SetMsg("Angaben wurden nicht gespeichert.")



**
** GenHstSum()
**
FUNCTION GenHstSum(cIdGen,xlHstFilter,xnValue)
local nValue := 0
open area oHst()
  ddSetOrder(ORD_HST_GENDATE)
  softseek cIdGen
  do while ! eof() .and. HST->IdGen == cIdGen
    if &xlHstFilter
      nValue += &xnValue
    endif
    skip
  enddo
close area
RETURN nValue

**
** GenCtgSum()
**
FUNCTION GenCtgSum(cIdGen,xlCtgFilter,xnValue)
local nValue := 0
open area oCtg()
  ddSetOrder(ORD_CTG_GEN)
  softseek cIdGen
  do while ! eof() .and. CTG->IdGen == cIdGen
    if &xlCtgFilter
      nValue += &xnValue
    endif
    skip
  enddo
close area
RETURN nValue

**
** DocHstSum()
**
FUNCTION DocHstSum(cIdJnl,cIdDoc,xlFilter,xnValue)
local nValue := 0
open area oHst()
  ddSetOrder(ORD_HST_DOC)
  softseek cIdJnl + cIdDoc
  do while ! eof() .and. HST->IdJnl == cIdJnl ;
                   .and. HST->IdDoc == cIdDoc
    if &xlFilter
      nValue += &xnValue
    endif
    skip
  enddo
close area
RETURN nValue



FUNCTION HstCptName()
RETURN "" if eof()
RETURN GenName(HST->IdGen) if empty(HST->IdCtr)
RETURN ParName(HST->IdPar)

* **
* ** MVP - mouvements comptes particuliers
* **
* FUNCTION oMvp()
* * local b
* static b := NIL
* if b != NIL ; RETURN b ; endif
* define data b   ;
*   name MVP             ;
*   create DDCREATE_FAIL ;
*   delete DDDEL_FAIL ;
*   wait   {|x| MvpWait(x) }
* ddIndex b on MVP->IdPar+MVP->Periode+dtos(MVP->Date)
* ddIndex b on MVP->IdJnl+MVP->IdDoc+MVP->Line       // ORD_MVP_DOC
* ddIndex b on MVP->IdPar+MVP->Match+dtos(MVP->Date) // ORD_MVP_PARMATCH
* ddFld IdPar     ,C, LenIdPar(),0 when .f.
* ddFld IdJnl     ,C, LenIdJnl(),0 picture PIC_ID when .f.
* ddFld IdDoc     ,C, LEN_IDDOC,0 picture PIC_ID when .f.
* ddFld Line      ,C, LEN_POS,0 when .f.
* ddFld Date      ,D, 8,0 when .f.
* ddFld _ParName  ,C, 30,0 attrib V block padr(ParName(MVP->IdPar),30)
* ddFld _DocName  ,C, 30,0 attrib V ;
*                          block DocName(MVP->IdJnl,MVP->IdDoc,MVP->Line)
* ddFld Periode   ,C, LEN_PERIODE,0 when .f.
* ddFld DC        ,C, 1,0 when .f.
* ddFld Mont      ,C, LenMont(),0 when .f.
* ddFld MontDev   ,C, LenMont(),0 when .f.
* ddFld Match     ,C, LenIdJnl()+LEN_IDDOC,0 picture PIC_ID ;
*                     pick  PickMvp(MVP->IdPar,MVP->Match) ;
*                     valid MvpMatchValidate()
* ddFld Satis     ,C, 1,0 when .f.
* ddFld IdCtr     ,C, 1,0 when .f.
* ddFld IdDgr     ,C, LEN_IDDGR,0  attrib H
* ddFld _Debit    ,C, LenMont(),0  GET_MONTANT attrib V ;
*                     when .f. block {|x| GsbMontD(x) } ;
*                     value if(MVP->DC == DC_DEBIT,val(MVP->Mont),0)
* ddFld _Credit   ,C, LenMont(),0  GET_MONTANT attrib V ;
*                     when .f. block {|x| GsbMontC(x) } ;
*                     value if(MVP->DC == DC_CREDIT,val(MVP->Mont),0)
* ddFld _MontUs   ,C, LenMont(),0  GET_MONTANT attrib V ;
*                     when .f. block {|x| MvpMontUs(x) }
* action b key K_ENTER prompt MsgMnuDocPage()    ;
*                      block DocPage(MVP->IdJnl,MVP->IdDoc)
* action b key K_F5    prompt "~Barzahlung            [F5]"    ;
*                      block ParCash(MVP->IdPar)
* action b key K_CTRL_F5 prompt "~Lettrierung      [Ctrl-F5]"    ;
*                        block MvpParSatisfy()
* action b key K_F9    prompt "Buchungen/~Match       [F9]"    ;
*                      block MatchMvpEdit(MVP->IdPar,MVP->Match)
* RETURN b



FUNCTION HstParSatisfy()
default sdMvpDate to ctod("")
open window (MsgSatis()) size 4,50 help HSTSATIS
say "Nur Buchungen bercksichtigen bis zum "
get sdMvpDate
WinCr()
get scAutoSatisfy checkbox
say " automatisch prfen wenn Match ver„ndert"
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
if empty(HST->IdPar)
  GenSatisfy(HST->IdGen,sdMvpDate)
else
  ParSatisfy(HST->IdPar,sdMvpDate)
endif
ddRefreshAll()
RETURN MnuDone()

FUNCTION HstMatchValidate
local doc
local cMatch
if (doc := DocInfo(HST->IdJnl,HST->IdDoc,HST->Line)) != NIL
  if empty(doc[DOC_MATCH])
    cMatch := HST->IdJnl + HST->IdDoc
  else
    cMatch := doc[DOC_MATCH]
  endif
  if empty(HST->Match)
    HST->Match := cMatch
  elseif HST->Match != cMatch
    DocSetMatch(HST->IdJnl,HST->IdDoc,HST->Line,HST->IdPar,HST->Match)
  endif
endif
if scAutoSatisfy == BUTTON_ON
  default sdMvpDate to ctod("")
  if empty(HST->IdPar)
    GenSatisfy(HST->IdGen,sdMvpDate)
  else
    ParSatisfy(HST->IdPar,sdMvpDate)
  endif
  if eof()
    ddGoTop()
  endif
  ddRefreshAll()
endif
RETURN .t.

/* wenn man ein Dokument entregistriert, dann sollen manuelle
Lettrierungen nicht verloren gehen.
   */
   
FUNCTION DocSetMatch(cIdJnl,cIdDoc,cLine,cIdPar,cMatch)
local jnl := JnlLocate(cIdJnl)
* local cAlias := JnlAlias(cIdJnl)
local lOkay := .f.
RETURN .f. if jnl == NIL
RETURN .t. if JNLATTR_U $ jnl[JNL_ATTRIB]
#ifdef DEF_VEN
  if jnl[JNL_ALIAS] == "VEN"
    open area oVen()
      seek cIdJnl + cIdDoc
      if ! eof()
        if VEN->IdPar == cIdPar
          if ddRecLock()
            if cMatch == cIdJnl + cIdDoc
              VEN->Match := ""
            else
              VEN->Match := cMatch
            endif
            lOkay := .t.
            unlock record
          endif
        endif
      endif
    close area
    RETURN NIL
  endif
#endif DEF_VEN
#ifdef DEF_FIN
  if jnl[JNL_ALIAS] == "FIN"
    open area oFnl()
      seek cIdJnl + cIdDoc + cLine
      if ! eof()
        if left(FNL->IdCpt,LenIdPar()) == cIdPar
          if ddRecLock()
            if cMatch == cIdJnl + cIdDoc
              FNL->Match := ""
            else
              FNL->Match := cMatch
            endif
            lOkay := .t.
            unlock record
          endif
        endif
      endif
    close area
    RETURN NIL
  endif
#endif DEF_FIN
RETURN NIL if lOkay
Warning( ;
  MsgIdJnlDoc() + " : Manuelle Lettrierung konnte nicht eingetragen werden", ;
  NIL, "SETMATCH" ;
)
RETURN NIL


FUNCTION MsgSetMatch(cOldMatch,cNewMatch)
RETURN MsgIdJnlDoc() + " : Match " + cOldMatch + " „ndern nach " + cNewMatch




FUNCTION HstMontUs
local cDC    := HST->DC // PrtDC(ParField(HST->IdPar,{|| PAR->IdPrt }))
local nMont  := 0
local cMatch := HST->Match
local cIdPar := HST->IdPar
local cIdGen := HST->IdGen
static slOkay := .t.
RETURN space(LenMont()) if eof()
if empty(HST->IdPar)
  if GenExist(HST->IdGen)
    if GENATTR_L $ GEN->Attrib
      open area oHst()
        ddSetOrder(ORD_HST_GENMATCH)
        softseek cIdGen + cMatch
        do while ! eof() .and. HST->IdGen == cIdGen ;
                         .and. HST->Match == cMatch ;
                         .and. slOkay
          if TaskInter() ; slOkay := .f. ; endif
          if HST->DC == cDC
            nMont += val(HST->Mont)
          else
            nMont -= val(HST->Mont)
          endif
          skip
        enddo
      close area
    endif
  endif
else
  open area oHst()
    ddSetOrder(ORD_HST_PARMATCH)
    softseek cIdPar + cMatch
    do while ! eof() .and. HST->IdPar == cIdPar ;
                     .and. HST->Match == cMatch ;
                     .and. slOkay
      if TaskInter() ; slOkay := .f. ; endif
      if HST->DC == cDC
        nMont += val(HST->Mont)
      else
        nMont -= val(HST->Mont)
      endif
      skip
    enddo
  close area
endif
RETURN ntom(nMont) if slOkay
RETURN repl("*",LenMont())


FUNCTION VenHstMont(cDC,cIdDev)
local cIdPar := VEN->IdPar
local cMatch := VenMatch()
local nMont := 0
// local cDC := CtrDC(JnlIdCtr(VEN->IdJnl))
open area oHst()
  ddSetOrder(ORD_HST_PARMATCH)
  softseek cIdPar + cMatch
  do while ! eof() .and. HST->IdPar == cIdPar ;
                   .and. HST->Match == cMatch
    if HST->DC == cDC
      nMont += HstMont(cIdDev)
    endif
    skip
  enddo
close area
RETURN nMont


FUNCTION HstMont(cIdDev)
// local dev
RETURN val(HST->Mont) if cIdDev == DevDefault(HST->Periode)
// RETURN val(HST->MontDev) if cIdDev == HstIdDev()
// 2001-03-01 : Lieferant X hatte pl”tzlich alle HST wieder offen,
// nachdem PAR->IdDev von BEF nach EUR ver„ndert worden war.
RETURN val(HST->MontDev) if cIdDev == HST->IdDev
* 20010411 RETURN val(HST->MontDev) if !empty(HST->MontDev).and.cIdDev == HstIdDev()
//
RETURN Db2Dev(cIdDev,HST->Periode,val(HST->Mont))
/*********
* RETURN 0 if (dev := DevLocate(cIdDev,HST->Periode)) == NIL
* // 2001-01-12 bei Rudi : / ersetzt durch *
* RETURN round( ;
*   val(HST->Mont) * val(dev[DEV_COURS2]), dev[DEV_DECPOS] ;
* ) if DevToggle(HST->Periode)
* RETURN round( ;
*   val(HST->Mont) / val(dev[DEV_COURS]), dev[DEV_DECPOS] ;
* )
*******/

**
** ! can move the record pointer in PAR, GEN, VEN, FIN
**
FUNCTION HstIdDev
local jnl := JnlLocate(HST->IdJnl)
local cIdDev := space(LEN_IDDEV)
RETURN cIdDev if jnl == NIL
* RETURN cIdDev if empty(HST->MontDev)
#ifdef DEF_VEN
  if jnl[JNL_ALIAS] == JNLALIAS_VEN
    cIdDev := VenField(HST->IdJnl + HST->IdDoc,{||VEN->IdDev})
  endif
#endif DEF_VEN
#ifdef DEF_FIN
  if jnl[JNL_ALIAS] == JNLALIAS_FIN
    cIdDev := FinField(HST->IdJnl + HST->IdDoc,{||FIN->IdDev})
  endif
#endif DEF_FIN
if cIdDev == DevDefault(HST->Periode)
  if empty(HST->IdCtr)
    seek HST->IdGen in GEN
    cIdDev := GEN->IdDev
  else
    seek HST->IdPar in PAR
    cIdDev := PAR->IdDev
  endif
  if empty(cIdDev)
    cIdDev := jnl[JNL_IDDEV]
  endif
  if cIdDev == DevDefault(HST->Periode)
    RETURN space(LEN_IDDEV)
  endif
endif
RETURN cIdDev


**
** HstDcMont()
** Wird benutzt in HST<EKR|VKR>.REP
**
FUNCTION HstDcMont(cDC,cIdDev)
local nMont := HstMont(cIdDev)
RETURN nMont if HST->DC == cDC
RETURN - nMont

#endif DEF_HST

#ifdef DEF_PRJ

**
** PRJ - projects
**
FUNCTION oPrj()
static b
if b != NIL ; RETURN b ; endif
define data b name PRJ ;
              wait {|x| PrjWait(x)} ;
              create PrjCreate() ;
              predelete PrjPreDelete() ;
              editprint PrjPrint()
ddIndex b on PRJ->IdPrj
ddFld IdPrj   ,C, LenIdPrj(),0 picture PIC_ID when .f.
ddFld Name1   ,C,30,0
ddFld Name2   ,C,30,0
ddFld Name3   ,C,30,0
ddFld Date1   ,D, 8,0
ddFld Date2   ,D, 8,0
ddFld Text    ,M,10,0
ddFld Type    ,C, 8,0 picture PIC_ID
#ifdef DEF_VEN
  action b key K_F5    prompt MSG007 block PrjVenEdit(PRJ->IdPrj)
#endif
#ifdef DEF_PIN
  action b key K_F6 prompt MSG_PIN block PrjPinEdit()
#endif
#ifdef DEF_HOLZ
  action b key K_F6 prompt MSG_STM block PrjStmEdit()
#endif
#ifdef DEF_MSG
  action b key K_SH_F8 prompt MSG011 ;
           block PrjMsgEdit(PRJ->IdPrj)
#endif DEF_MSG
#ifdef DEF_IMP
  action b key K_F9    prompt MSG012 block PrjMviEdit(PRJ->IdPrj)
#endif DEF_IMP
action b key K_F12   prompt MnuMemoEdit() block PrjMemoEdit()
action b key K_ENTER prompt NIL block PrjEnter()
* #ifdef DEF_ACT
*   if IsCustData("PRJ") ; ActExec("PRJ") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

FUNCTION PrjEnter
local a := CurMsk(MSK_WAITWINLIST)
local win
RETURN NIL if a == NIL
if len(a) > 0
  win := a[1]
  RETURN PrjMemoEdit() if win[WIN_WAITKEY] == 12
  RETURN PrjPrjEdit() if win[WIN_WAITKEY] == 2
  #ifdef DEF_PIN
    RETURN PrjPinEdit() if win[WIN_WAITKEY] == 6
  #endif DEF_PIN
  #ifdef DEF_VEN
    RETURN PrjVenEdit(PRJ->IdPrj) if win[WIN_WAITKEY] == 5
  #endif DEF_ACF
  #ifdef DEF_HOLZ
    RETURN PrjStmEdit(PRJ->IdPrj) if win[WIN_WAITKEY] == 5
  #endif DEF_HOLZ
  #ifdef DEF_IMP
    RETURN PrjMviEdit(PRJ->IdPrj) if win[WIN_WAITKEY] == 9
  #endif DEF_IMP
  #ifdef DEF_KITZ
    RETURN PrjLdjEdit() if win[WIN_WAITKEY] == 1
  #endif DEF_KITZ
endif
ddEditChange()
RETURN MnuDone()

FUNCTION PrjPrjEdit()
RETURN DbfEdit(;
  {oPrj(),oPar()},;
  ltrim(PRJ->IdPrj)+ " : children","PRJPRJ",;
  NIL,;
  NIL,;
  PRJ->IdPrj,;
  "PRJ->Parent",;
  ".t.";
)


#else

FUNCTION oPrj() ; RETURN NIL

#endif DEF_PRJ



#ifdef DEF_IMP

**
** BUD - Haushaltsartikel
**
FUNCTION oBud()
static b := NIL
#ifdef DEF_VCB
local aVcb := VcbList()
local i
#endif DEF_VCB
if b != NIL ; RETURN b ; endif
define data b    ;
  name BUD            ;
  attrib   "S" ;
  predelete   BudPreDelete(b) ;
  postedit BudPostEdit() ;
  preedit  BudPreEdit() ;
  wait {|x| BudWait(x)}
  * convert GenConvert() ;
ddIndex b on BUD->DC+BUD->IdBud ;
             format {|x| left(x,1)+GetIdBud(upper(substr(x,2))) }  // ORD_BUD_ID
ddIndex b on BUD->SubBud+BUD->IdFcb+BUD->GrbPos+BUD->IsSum+BUD->IdBud // ORD_BUD_HH
ddIndex b on BUD->Service+BUD->IsSum+BUD->IdFcb+BUD->CodTot // ORD_BUD_3
ddFld IdBud   ,C, LenIdBud(),0  when .f. picture PIC_ID ;
                                block {|x| GsbIdBud(x) }
ddFld Name1   ,C,40,0  // picture "@K@S30" // width 30
ddFld Name2   ,C,40,0  // picture "@K@S35" // width 35
ddFld Name3   ,C,40,0  // picture "@K@S35" // width 35
ddFld DC_s     ,C, 1,0 picture PIC_ID valid DcValidate(BUD->DC_s)
ddFld _FcbName,C,30,0  attrib V block padr(FcbName(BUD->IdFcb),30)
ddFld _GrbName,C,30,0  attrib V block padr(GrbName(BUD->CodTot),30)
ddFld GrbPos  ,C, 2,0 when .f.
ddFld Attrib  ,C, 4,0  picture PIC_ID ;
                       pick PickDbcAttr("BUDATTR.DBC",BUD->Attrib)
                       // pick PickBudAttrib(BUD->Attrib)
ddFld IdJnl   ,C, LenIdJnl(),0 picture PIC_ID ;
                               pick PickIdJnl("IMP",BUD->IdJnl)
ddFld _SrvName,C,30,0 attrib V block padr(SrvValue(BUD->Service,SRV_NAME),30)
ddFld CodTot  ,C, 2,0 picture PIC_ID ;
                      pick  PickGrb(BUD->DC,BUD->CodTot) ;
                      valid empty(BUD->CodTot).or.GrbExist(BUD->DC,BUD->CodTot)
ddFld SubBud  ,C, 2,0 picture PIC_ID pick PickSbb(BUD->SubBud)
ddFld Service ,C, 1,0 picture PIC_ID pick PickSrv(BUD->Service)
ddFld DC      ,C, 1,0 picture PIC_ID valid DcValidate(BUD->DC)
ddFld IdPrj   ,C, LenIdPrj(),0 picture PIC_ID pick PickPrj(BUD->IdPrj)
ddFld DatCrea ,D, 8,0 when .f.
ddFld IdFcb   ,C, 5,0 picture PIC_ID pick PickFcb(BUD->IdFcb)
ddFld Perc    ,C, 3,0 attrib H // GET_NUM
ddFld IdBud_s ,C, LenIdBud(),0  picture PIC_ID ;
                                block {|x| GsbIdBud_s(x) } ;
                                pick PickBudSay(BUD->DC_s,BUD->IdBud_s)
ddFld IsSum   ,C, 1,0 picture PIC_ID when UsrLevel() <= "B"
ddFld Memo    ,M,10,0
ddFld _SbbName,C,30,0 attrib V block padr(SbbName(BUD->SubBud),30)
#ifdef DEF_VCB
  for i := 1 to len(aVcb)
    ddAddField( ;
      aVcb[i][VCB_IDVCB], "C", LenMont(), 0, ;
      NIL, "", NIL, NIL, {|| .f. }, ;
      .f., NIL, NIL, NIL, NIL, NIL ;
    )
  next i
#endif DEF_VCB
* action b key    K_F9 ;
*          prompt MSG013 ;
*          block  BudCnpEdit()
#ifdef DEF_IMP
  action b key K_F9    prompt MSG012 block BudMviEdit(BUD->DC,BUD->IdBud)
  action b key K_SH_F9 prompt MSG013 block BudCtbEdit(BUD->DC,BUD->IdBud)
#endif DEF_IMP
#ifdef DEF_MEMO
  action b key K_F12 prompt MnuMemoEdit() block BudMemoEdit()
#endif
* action b key    K_F9 ;
*          prompt MSG012 ;
*          block  BudGetMvb(BUD->IdBud)
* #ifdef DEF_ACT
*   if IsCustData("BUD") ; ActExec("BUD") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

**
** GsbIdBud() - Get-Set-Block for field IdBud
**
FUNCTION GsbIdBud(x)
RETURN SayIdBud(FIELD->IdBud) if x == NIL
FIELD->IdBud := GetIdBud(x)
RETURN NIL

FUNCTION GsbIdBud_s(x)
RETURN SayIdBud(FIELD->IdBud_s) if x == NIL
FIELD->IdBud_s := GetIdBud(x)
RETURN NIL

#define LEN_IDFKT 5
#define LEN_NATURE 5
#define LEN_IDORD 3

FUNCTION GetIdBud(x)
local nPos
local cJahr  := "  " // MemJahr
local cIdFkt := space(LEN_IDFKT)
local cIdNat := space(LEN_NATURE)
local cIdOrd := space(LEN_IDORD)
local lMinus := .f.
local cDebug := x
RETURN space(LenIdBud()) if empty(x)
x := trim(x)
if substr(x,3,1) == "-" // (nPos := at("-",x)) == 3
  cJahr := left(x,2)
  x := substr(x,4)
endif
x := strtran(x,"."," ")
x := strtran(x,"/"," ")
if "-" $ x   // right(x,1) == "-"
  x := strtran(x,"-"," ")
  * x := left(x,len(x)-1)
  lMinus := .t.
endif
if len(x) > 0
  if (nPos := at(" ",x)) == 0
    cIdFkt := padr(x,LEN_IDFKT)
    x := ""
  else
    cIdFkt := padr(left(x,nPos-1),LEN_IDFKT)
    x := substr(x,nPos+1)
    if len(x) > 0
      if (nPos := at(" ",x)) == 0
        cIdNat := padr(x,LEN_NATURE)
        x := ""
      else
        cIdNat := padr(left(x,nPos-1),LEN_NATURE)
        x := substr(x,nPos+1)
        cIdOrd := padr(x,LEN_IDORD)
      endif
    endif
  endif
endif
* SetMsg( "'" + cDebug + "' wird : '" + ;
*   cJahr + cIdFkt + cIdNat + cIdOrd + if(lMinus,"-"," " + "'") ;
* )
RETURN (cJahr + cIdFkt + cIdNat + cIdOrd + if(lMinus,"-"," "))

**
** SayIdBud()
**
FUNCTION SayIdBud(cIdBud)
local cSay := ""
local lMinus := (right(cIdBud,1) == "-")
RETURN space(18) if empty(cIdBud)
if left(cIdBud,2) != "  " // MemJahr
  cSay := left(cIdBud,2) + "-"
endif
cIdBud := substr(cIdBud,3)
cSay += trim(left(cIdBud,LEN_IDFKT))
if lMinus
  cSay += "-"
else
  cSay += "/"
endif
cSay += trim(substr(cIdBud,LEN_IDFKT + 1,LEN_NATURE))
cSay += "/" + trim(substr(cIdBud,LEN_IDFKT + LEN_NATURE + 1,LEN_IDORD))
RETURN padr(cSay,18)

#else

FUNCTION oBud()
RETURN NIL

#endif DEF_IMP

#ifdef DEF_ANA

**
** ANA - Analysekonten
**
FUNCTION oAna()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b    ;
  name ANA            ;
  create AnaCreate(b)   ;
  predelete AnaPreDelete(b) ;
  wait {|x| AnaWait(x)}
ddIndex b on ANA->IdAna
ddIndex b on ANA->IdPar+upper(ANA->Name1) ;
          format {|x|eupper(x,LenIdPar())}
ddFld IdAna   ,C, LenIdAna(),0  picture PIC_ID block {|x| GsbIdAna(x) }
ddFld Name1   ,C,40,0  picture "@K@S30" // width 30
ddFld Name2   ,C,40,0  picture "@K@S30" // width 30
ddFld Attrib  ,C, 4,0  picture PIC_ID
ddFld _IdAna ,C,LenIdAna()*2-1,0 attrib V ;
                                block IdStruct(ANA->IdAna,1)
ddFld IdPar    ,C, LenIdPar(),0  GET_PAD ;
                        pick PickPar(NIL,ANA->IdPar)
#ifdef DEF_MVA
action b key K_F9    prompt MSG012 ;
         block  AnaMvaEdit(ANA->IdAna)
action b key K_SH_F9 prompt MSG013 block AnaCtaEdit()
action b key K_ENTER block AnaEnter()
#endif DEF_MVA
ddEndDef()
RETURN b

* FUNCTION GetIdAna(x)
* RETURN x if empty(x)
* RETURN padr(trim(x),LenIdAna(),"0")

FUNCTION GsbIdAna(x)
RETURN FIELD->IdAna if x == NIL
FIELD->IdAna := GetIdAna(x)
RETURN NIL

#else

FUNCTION oAna()
RETURN NIL

#endif DEF_ANA

#ifdef DEF_MVA

FUNCTION AnaEnter()
local a := CurMsk(MSK_WAITWINLIST)
local win
RETURN NIL if a == NIL
if len(a) > 0
  win := a[1]
  * RETURN AnaMemoEdit() if win[WIN_WAITKEY] == 12
  RETURN AnaMvaEdit(ANA->IdAna) if win[WIN_WAITKEY] == 9
endif
ddEditChange()
RETURN MnuDone()


**
** MVA - mouvements comptes analytiques
**
FUNCTION oMva()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b   ;
  name MVA ;
  postedit MvaPostEdit()
ddIndex b on MVA->IdAna+MVA->Periode+dtos(MVA->Date) // ORD_MVA_CPTDATE
ddIndex b on MVA->IdJnl+MVA->IdDoc+MVA->Line         // ORD_MVA_DOC
#ifdef DEF_IMP
  ddIndex b on MVA->DC+MVA->IdBud+MVA->Periode+dtos(MVA->Date)
  // ORD_MVA_BUD
#else
  ddIndex b on MVA->IdGen+MVA->Periode+dtos(MVA->Date) // ORD_MVA_GEN
#endif
ddFld IdAna     ,C, LenIdAna(),0 picture PIC_ID ;
                    block {|x| GsbIdAna(x) } ;
                    pick PickAna(MVA->IdAna)
ddFld IdJnl     ,C, LenIdJnl(),0 picture PIC_ID when .f.
ddFld IdDoc     ,C, LEN_IDDOC,0 picture PIC_ID when .f.
ddFld Remarq    ,C, 30,0
ddFld Date      ,D, 8,0
ddFld _Libell   ,C, 30,0 attrib V when .t. ;
                         block {|x|GsbMvaLibell(x)}
ddFld _DocName  ,C, 30,0 attrib V ;
                         block HstDocName(MVA->IdJnl,MVA->IdDoc,MVA->Line)
ddFld Periode   ,C, LEN_PERIODE,0 when .f.
ddFld DC        ,C, 1,0 picture PIC_ID valid DcValidate(MVA->DC)
ddFld Mont      ,T, LenMont(),0 GET_MONTANT pseudo MvaMust() ;
                                value val(MVA->Mont)
#ifdef DEF_IMP
  ddFld IdBud    ,C, LenIdBud(),0 picture PIC_ID ;
                                  block {|x| GsbIdBud(x) } ;
                                  pick PickBudSay(MVA->DC,MVA->IdBud)
                                  // valid MvaBudValidate()
#else
  ddFld IdGen     ,C, LenIdGen(),0 pick PickGen(NIL,MVA->IdGen) ;
                      postedit {|x| GetIdGen(x) }
#endif
ddFld _MontD    ,C, 10,0  GET_MONTANT attrib V ;
                          when .t. ;
                          block {|x| GsbMontD(x) } ;
                          value if(MVA->DC == DC_CREDIT,val(MVA->Mont),0)
ddFld _MontC    ,C, 10,0  GET_MONTANT attrib V ;
                          when .t. ;
                          block {|x| GsbMontC(x) } ;
                          value if(MVA->DC == DC_CREDIT,val(MVA->Mont),0)
ddFld _Partner  ,C,30,0 attrib V ;
                        block DocPartner(MVA->IdJnl,MVA->IdDoc,MVA->Line)
ddFld Line      ,C,LEN_POS,0  GET_NUM
action b key K_ENTER prompt MsgMnuDocPage() ;
                     block DocPage(MVA->IdJnl,MVA->IdDoc)
* #ifdef DEF_ACT
*   if IsCustData("MVA") ; ActExec("MVA") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

#endif DEF_MVA

#ifdef DEF_HOLZ

**
** STM - St„mme (Eintr„ge in Holzliste eines Projekts)
**
FUNCTION oStm()
local aJnl := JnlList({|jnl|JNLATTR_D $ jnl[JNL_ATTRIB]})
local i
static b
if b != NIL ; RETURN b ; endif
define data b name STM postedit StmPostEdit()
ddIndex b on  STM->IdStm format {|x| GetIdStm(x) }            // ORD_STM_ID
ddIndex b on  STM->IdPrj+STM->IdStm ;
          format {|x| ;
            upper(left(x,LenIdPrj()))+ ;
            GetIdStm(substr(x,LenIdPrj()+1)) ;
          } // ORD_STM_PRJ
for i := 1 to len(aJnl)
  ddAddIndex( ;
    "STM->"+aJnl[i][JNL_IDJNL]+"IdDoc+STM->"+aJnl[i][JNL_IDJNL]+"Line", ;
    aJnl[i][JNL_NAME] ;
  )
next i
ddFld IdPrj   ,C, LenIdPrj(),0 picture PIC_ID pick PickPrj(STM->IdPrj)
ddFld IdStm   ,C, LenIdStm(),0 postedit {|x| GetIdStm(x)}
ddFld Line    ,C, LEN_POS  ,0  GET_NUM
ddFld Laenge  ,C, 5,0 GET_NUM valid StmValMenge()
ddFld Durchm  ,C, 4,0 GET_NUM valid StmValDurchm()
ddFld Menge   ,C, LenQte(),0 GET_NUM valid StmValMenge()
ddFld Bemerk  ,C,30,0
ddFld Attrib  ,C, 3,0 picture PIC_ID ;
                      pick PickDbcAttr("STMATTR.DBC",STM->Attrib) ;
                      valid StmValMenge()
ddFld Umfang  ,C, 4,0 GET_NUM valid StmValUmfang()
ddFld IdArt   ,C, LenIdArt(),0 picture PicIdArt() ;
                              pick PickArt(STM->IdArt)
ddFld IdJnl   ,C, LenIdJnl(),0  picture PIC_ID
ddFld IdDoc   ,C, LEN_IDDOC,0  picture PIC_ID
ddFld _DocDate   ,D,8,0  attrib H // V block StmDocDate()
ddFld _DocLibell ,C,35,0 attrib H // V block StmDocRemarq()
ddFld _DocPar    ,C,35,0 attrib H // V block StmParName()
ddFld IdCls   ,C, 2,0 picture PIC_ID ;
                     pick PickCls(STM->IdCls)
ddFld _DocStatus ,C,1,0 attrib H // V block StmDocStatus()
action b key K_SH_F4      prompt "Stammdaten ~Artikel  [Shift-F4]" ;
                          block ArtPage(STM->IdArt) ;
                          when ! empty(STM->IdArt)
* action b key K_F5    prompt MSG_VENSTMCOPY block VenStmCopy() ;
*                      when indexord() != ORD_STM_ID ;
*                      .and. indexord() != ORD_STM_PRJ
action b key K_F8    prompt MSG_SETCLSTYPE block SetClsType()
ddEndDef()
RETURN b

* FUNCTION PickStmAttrib(cStart)
* local a := {}
* #ifdef LG_FRENCH
*   aadd(a, { STMATTR_D, "Calcul par diamŠtre              " , 1 } )
*   aadd(a, { STMATTR_K, "Kleinholz                        " , 1 } )
*   aadd(a, { STMATTR_H, "invisible                        " , 1 } )
* #else
*   aadd(a, { STMATTR_D, "nach Durchmesser berechnen          " , 1 } )
*   aadd(a, { STMATTR_K, "Kleinholz                           " , 1 } )
*   aadd(a, { STMATTR_H, "Unsichtbar                          " , 1 } )
* #endif
* RETURN PickAttrib(a,NIL,cStart,"","STMATTR")

FUNCTION GetIdStm(x)
RETURN padl(trim(x),LenIdStm())

* FUNCTION StmDocDate()
* local doc := DocInfo(STM->IdJnl,STM->IdDoc)
* RETURN ctod("") if doc == NIL
* RETURN doc[DOC_DATE]

* FUNCTION StmDocRemarq()
* local doc := DocInfo(STM->IdJnl,STM->IdDoc)
* RETURN space(35) if doc == NIL
* RETURN padr(doc[DOC_LIBELL],35)


*FUNCTION StmParName()
*local doc := DocInfo(STM->IdJnl,STM->IdDoc)
*RETURN space(35) if doc == NIL
*RETURN padr(ParName(doc[DOC_IDPAR]),25)

*FUNCTION StmDocStatus()
*local cStatus := " "
*open area oVen()
*  seek STM->IdJnl + STM->IdDoc
*  cStatus := VEN->Etat
*close area
*RETURN cStatus

**
** valid clause for STM->Durchm, Umfang and Laenge
**
FUNCTION StmValMenge()
local nMenge
RETURN .t. if ! ArtExist(STM->IdArt)
if STMATTR_D $ STM->Attrib
  nMenge := ( val(STM->Durchm) ** 2 ) ;
            * 0.7853981 * val(STM->Laenge) / 10000
else
  nMenge := ( val(STM->Umfang) ** 2 ) ;
            * val(STM->Laenge) / 12.56637 / 10000
endif
STM->Menge := ntoq(nMenge,ART->QteForm)
RETURN .T.

FUNCTION StmValUmfang
if empty(STM->Umfang)
  STM->Umfang := str(val(STM->Durchm) * 3.1415927,4)
else
  STM->Durchm := str(val(STM->Umfang) / 3.1415927,4)
endif
STM->IdCls := ClsDefault()
RETURN StmValMenge()

FUNCTION StmValDurchm
if empty(STM->Durchm)
  STM->Durchm := str(val(STM->Umfang) / 3.1415927,4)
else
  STM->Umfang := str(val(STM->Durchm) * 3.1415927,4)
endif
STM->IdCls := ClsDefault()
RETURN StmValMenge()

#endif DEF_HOLZ

#ifdef DEF_PSC

**
** PSC - Personnes de contact
**
FUNCTION oPsc()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name PSC ;
            postedit PscPostEdit()
ddIndex b on PSC->IdPar+PSC->Seq    // ORD_PSC_PAR1
ddIndex b on PSC->IdPar2+PSC->IdPar // ORD_PSC_PAR2
ddFld IdPar   ,C, LenIdPar(),0 picture PIC_ID ;
                               postedit {|x| GetIdPar(x)} ;
                               pick PickPar(NIL,PSC->IdPar)
ddFld Seq     ,C, 3,0 postedit {|x|GetSeq(x)}
ddFld Remarq  ,C,20,0
ddFld IdPlt   ,C, LEN_IDPLT,0 picture PIC_ID pick PickPlt(PSC->IdPlt)
ddFld IdPar2  ,C, LenIdPar(),0 picture PIC_ID ;
                               postedit {|x| GetIdPar(x)} ;
                               pick PickPar(NIL,PSC->IdPar2)
ddFld _Name1  ,C,30,0 attrib V block padr(ParName(PSC->IdPar),30)
ddFld _Tel1   ,C,18,0 attrib V block ParField(PSC->IdPar,{||PAR->Tel})
ddFld _Name2  ,C,30,0 attrib V block padr(ParName(PSC->IdPar2),30)
ddFld _Tel2   ,C,18,0 attrib V block ParField(PSC->IdPar2,{||PAR->Tel})
ddFld _PltName,C,30,0 attrib V block padr(PltName(PSC->IdPlt),30)
action b key K_F2 prompt MSG_SWITCH block PscSwitch()
* #ifdef DEF_VEN
*   action b key K_F5   prompt MSG007 block ParVenEdit(PSC->IdPar2)
* #endif
#ifdef DEF_VNA
  * action b key K_F6   prompt MSG_VNA ;
  *          block ParVnaEdit(PSC->IdPar2)
  * action b key K_ALT_F6   prompt MSG_VNAAUTO ;
  *          block ParVnaAuto(PSC->IdPar2)
#endif DEF_VNA
#ifdef DEF_PRESTO
  action b key K_F8  prompt MnuTrmEdit() block ParTrmEdit(PSC->IdPar2)
#endif
#ifdef DEF_MSG
  action b key K_SH_F8 prompt MSG011 ;
           block ParMsgEdit(PSC->IdPar2)
#endif
#ifdef DEF_HST
  action b key K_F9 prompt MSG012 ;
           block ParHstEdit(PSC->IdPar2)
#endif DEF_HST
#ifdef DEF_CTP
  action b key K_SH_F9 prompt MSG013 ;
           block  ParCtpEdit(PSC->IdPar2)
#endif DEF_CTP
action b key K_ENTER prompt NIL  block ParPage(PSC->IdPar2) ;
                                 when indexord() == ORD_PSC_PAR1
action b key K_ENTER prompt NIL  block ParPage(PSC->IdPar) ;
                                 when indexord() == ORD_PSC_PAR2
ddEndDef()
RETURN b

FUNCTION PscPostEdit
RETURN .f. if ! ParExist(PSC->IdPar)
RETURN .f. if ! ParExist(PSC->IdPar2)
RETURN .t.

FUNCTION ParIsMember(cIdPar1)
local cIdPar2 := PAR->IdPar
local lIsPsc := .f.
open area oPsc()
  ddSetOrder(ORD_PSC_PAR2)
  softseek cIdPar2 + cIdPar1
  if ! eof() .and. PSC->IdPar2 == cIdPar2
    if left(PSC->IdPar,len(cIdPar1)) == cIdPar1
      lIsPsc := .t.
    endif
  endif
close area
RETURN lIsPsc

FUNCTION PscSwitch()
local x
local nRecNo := recno()
local nRecNoNew
RETURN .f. if ! Confirm(MsgSure(),NIL,MSG_YES)
if ddSkip(1) == 1
  nRecNoNew := recno()
elseif ddSkip(-1) == -1
  nRecNoNew := recno()
endif
goto nRecNo
if ddRecLock()
  x := PSC->IdPar
  PSC->IdPar := PSC->IdPar2
  PSC->IdPar2 := x
  unlock record
endif
goto nRecNoNew
ddRefreshAll()
RETURN MnuDone()

#endif DEF_PSC

#ifdef DEF_SER

**
** SER
**
FUNCTION oSer()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b   ;
  name SER ;
  create SerCreate() ;
  postedit SerPostEdit()
ddIndex b on SER->IdSer format {|x|GetIdSer(x)}      // ORD_SER_ID
ddIndex b on SER->IdArt+SER->IdSer                   // ORD_SER_ART
ddFld IdSer     ,C, LenIdSer(),0 ;
                    postedit {|x| GetIdSer(x) } ;
                    valid {|x| SerValidate() }
ddFld IdArt     ,C, LenIdArt(),0 picture PicIdArt() ;
                    block {|x| GsbIdArt(x) } ;
                    pick PickArt(SER->IdArt)
* ddFld Qte       ,C,LenQte(),0 GET_NUM
* ddFld Date      ,D, 8,0
ddFld Prix1     ,T, LenMont(),0 GET_MONTANT
ddFld _ArtName  ,C, LenArtName(),0 attrib V ;
                    block padr(ArtName(SER->IdArt),LenArtName())
* #ifdef DEF_STK
*   StkAddFields()
* #endif DEF_STK
#ifdef DEF_VEN
  action b key K_F5   prompt MSG007 block SerVnlEdit(SER->IdSer)
#endif
* #ifdef DEF_ACT
*   if IsCustData("SER") ; ActExec("SER") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

FUNCTION SerValidate()
static scIdSer := NIL
default scIdSer to SER->IdSer
if empty(SER->IdSer)
  SER->IdSer := NextId(scIdSer)
endif
scIdSer := SER->IdSer
RETURN .t.

FUNCTION SerExist(cId)
if SER->IdSer == cId .and. ! eof() in SER
  RETURN .T.
endif
seek cId in SER
if eof() in SER
  SetMsg(cId + " : unbekannte Seriennummer !" )
  RETURN .F.
endif
RETURN .T.

FUNCTION GetIdSer(x)
if val(x) == 0
  RETURN x if val(substr(x,LenArtRoot()+1)) == 0
  RETURN left(x,LenArtRoot()) + padl(substr(x,LenArtRoot()+1),LenIdSer()-LenArtRoot(),"0")
endif
RETURN padl(trim(x),LenIdSer(),"0")

FUNCTION NextIdSer(cRoot)
local cIdSer
open area oSer()
  KeyGoBottom(cRoot,"left(SER->IdSer," + ntrim(len(cRoot)) + ")")
  if left(SER->IdSer,len(cRoot)) == cRoot .and. ! eof()
    cIdSer := NextId(SER->IdSer)
  else
    cIdSer := cRoot + padl("1",space(LenIdSer()-len(cRoot)),"0")
  endif
close area
RETURN cIdSer

#endif DEF_SER


*#ifdef DEF_STK
*
*FUNCTION StkAddFields()
*local aStk := StkList()
*local i
*for i := 1 to len(aStk)
*  if aStk[i][STK_TYPE] == STKTYPE_QTE
*    ddAddField( ;
*      aStk[i][STK_IDSTK], "C", LenQte(), 0, ;
*      "", "", ;
*      NIL, NIL, ;
*      NIL, ;
*      {|x| PickNum(x)}, ;
*      {|| USRATTR_E $ UsrAttrib() }, ;
*      {|x| GetQte(x,ART->QteForm)}, ;
*    )
*  elseif aStk[i][STK_TYPE] == STKTYPE_PU
*    ddAddField( ;
*      aStk[i][STK_IDSTK], "C", LenMont(), 0, ;
*      "", "", ;
*      NIL, NIL, ;
*      NIL, ;
*      {|x| PickNum(x)}, ;
*      {|| USRATTR_E $ UsrAttrib() }, ;
*      {|x| GetMont(x)}, ;
*    )
*  elseif aStk[i][STK_TYPE] == STKTYPE_DATE
*    ddAddField( ;
*      aStk[i][STK_IDSTK], "D", 8, 0, ;
*      "", "", ;
*      NIL, NIL, ;
*      NIL, ;
*      {|x| PickDate(x)}, ;
*      {|| USRATTR_E $ UsrAttrib() } ;
*    )
*  endif
*next i
*RETURN NIL
*
*#endif DEF_STK


#ifdef DEF_BIL

**
** BIL
**
FUNCTION oBil()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b    ;
  name BIL            ;
  create RecCreate()   ;
  wait {|x| BilWait(x)}
ddIndex b on BIL->IdBil
ddFld IdBil   ,C, LenIdBil(),0 picture PIC_ID
ddFld Name    ,C,70,0 picture "@K@S40"
ddFld DC      ,C, 1,0  picture PIC_ID ;
                       valid DcValidate(BIL->DC)
ddFld Attrib  ,C, 4,0  picture PIC_ID ;
                       pick PickDbcAttr("BILATTR.DBC",BIL->Attrib)
action b key K_ENTER   prompt "General accounts [Enter]" block BilGenEdit(BIL->IdBil)
* #ifdef DEF_ACT
*   if IsCustData("BIL") ; ActExec("BIL") ; endif
* #endif DEF_ACT
* #ifdef DEF_TOOLBOX
*   action b key K_ALT_F2 prompt MsgMnuRename() ;
*                         block BilRename() ;
*                         when recno() != lastrec() + 1
* #endif
ddEndDef()
RETURN b

**
** BilGenEdit()
**
FUNCTION BilGenEdit(cIdBil)
// cIdBil := trim(cIdBil)
RETURN DbfEdit( ;
  {oGen()},trim(BilName(cIdBil)),"BILGEN",;
  NIL,NIL,;
  trim(cIdBil),"left(GEN->IdBil,"+ntrim(len(trim(cIdBil)))+")" ;
)
*local b := oGen()
*local cTitle := trim(BIL->Name)
*open area b
*  ddSetOrder(ORD_GEN_BIL)
*  edit data b key GEN->IdBil value cIdBil ;
*              mode   find  ;
*              start  top  ;
*              query "BILGEN" ;
*              title (cTitle)
*close area
*RETURN .f.

* FUNCTION PickDbf(aDbf,bReturn,cStart,cTitle,cIdQry)
* local uReturn := NIL
* default cIdQry to aDbf[1][AD_NAME] + "PICK"
* begin sequence
*   if ! AreaOpen(aDbf,.f.) ; break ; endif
*  softseek cStart
*  edit data aDbf[1] ;
*            mode pick ;
*             title (cTitle) ;
*             query (cIdQry)
*   if ddLastReq() == DDEDIT_SELECT
*     uReturn := eval(bReturn)
*   endif
*   AreaClose()
* end sequence
* RETURN uReturn

FUNCTION BilWait() ; RETURN NIL
* FUNCTION BilRename() ; RETURN NIL

#endif DEF_BIL

#ifdef DEF_STK

FUNCTION ArtStkUpdate(cIdArt,cIdStk,nQte)
local lOkay := .f.
RETURN .t. if nQte == 0
open area oArt()
  if ArtExist(cIdArt)
    if ddRecLock()
      &("ART->"+cIdStk) := ntoq(nQte + qton(&("ART->"+cIdStk)),ART->QteForm)
      unlock record
      lOkay := .t.
    endif
  endif
close area
RETURN .t.

#endif DEF_STK

#ifdef DEF_MVS

**
** MVS - mouvements stock
**
FUNCTION oMvs
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name MVS                   ;
  create     DDCREATE_FAIL ;
  preedit    MvsPreEdit()
ddIndex b on  MVS->IdJnl+MVS->IdDoc                    // ORD_MVS_DOC
ddIndex b on  MVS->IdArt+MVS->Periode+dtos(MVS->Date)  // ORD_MVS_ART
* ddIndex b on  MVS->IdArt+MVS->Match+dtos(MVS->Date)    // ORD_MVS_MATCH
ddFld IdJnl    ,C, LenIdJnl(),0 when .f.
ddFld IdDoc    ,C, LEN_IDDOC,0  when .f.
ddFld IdArt    ,C, LenIdArt(),0 picture PicIdArt() when .f.
ddFld IdPar    ,C, LenIdPar(),0 when .f.
ddFld DC       ,C, 1,0 when .f.
ddFld Qte      ,C, LenQte(),0    when .f.
ddFld Mont     ,T, LenMont(),0 GET_MONTANT ;
                               when ! JNLATTR_V $ JnlAttrib(MVS->IdJnl)
ddFld _Debit   ,C, LenQte(),0  attrib V block {|x| GsbQteDebit(x) }
ddFld _Credit  ,C, LenQte(),0  attrib V block {|x| GsbQteCredit(x) }
ddFld Periode  , C, LEN_PERIODE,0 picture PIC_ID when .f.
ddFld Date     ,D, 8,0          when .f.
ddFld _ArtRef  ,C, LenArtRef(),0 attrib V ;
                   block ArtField(MVS->IdArt,{||ART->Ref})
ddFld _ArtName ,C, 40,0 attrib V ;
                        block padr(ArtName(MVS->IdArt),40)
ddFld _ParName ,C, 40,0 attrib V ;
                        block padr(ParName(MVS->IdPar),40)
ddFld _PrixU   ,T, LenMont(),0 attrib V ;
                        when ! JNLATTR_V $ JnlAttrib(MVS->IdJnl) ;
                        block {|x|GsbMvsPU(x)}
ddFld QteVal   ,C, LenQte(),0 valid MvsQteValidate() ;
                              when JNLATTR_V $ JnlAttrib(MVS->IdJnl)
ddFld Line     ,C, LEN_POS,0
ddFld _DocName  ,C, 30,0 attrib V ;
                         block DocName(MVS->IdJnl,MVS->IdDoc,MVS->Line)
action b key K_SH_F4   prompt MnuArtPage() block ArtPage(MVS->IdArt)
action b key K_SH_F5   prompt MnuParPage() block ParPage(MVS->IdPar)
action b key K_ENTER prompt MsgMnuDocPage() ;
                     block DocPage(MVS->IdJnl,MVS->IdDoc)
#ifndef DEF_ART_REF
  ddFldRemove("_ArtRef")
#endif DEF_ART_REF
ddEndDef()
RETURN b

FUNCTION MvsQteValidate()
RETURN .t. if ! ArtExist(MVS->IdArt)
if ! empty(MVS->QteVal)
  MVS->QteVal := ntoq(qton(MVS->QteVal),ART->QteForm)
endif
MvsValorise(MVS->IdArt)
ddRefreshAll()
RETURN .t.

FUNCTION MvsPreEdit()
* if ! empty(MemMvsPeriode)
*   if MVS->Periode <= MemMvsPeriode
*     Warning("Lagerverwaltung abgeschlossen bis Periode " + MemMvsPeriode)
*     RETURN .f.
*   endif
* endif
RETURN .t.

FUNCTION GsbMvsPU(x)
if x == NIL
  RETURN ntom(val(MVS->Mont)/qton(MVS->Qte),ArtPuDecPos())
endif
FIELD->Mont := ntom(val(x)*qton(MVS->Qte))
RETURN NIL

#endif DEF_MVS

#ifdef DEF_ART

FUNCTION GsbQteDebit(x)
if x == NIL
  RETURN FIELD->Qte if FIELD->DC == DC_DEBIT
  RETURN space(LenQte())
endif
FIELD->Qte := ntoq(qton(x),ART->QteForm)
FIELD->DC  := DC_DEBIT
RETURN NIL

FUNCTION GsbQteCredit(x)
if x == NIL
  RETURN FIELD->Qte if FIELD->DC == DC_CREDIT
  RETURN space(LenQte())
endif
FIELD->Qte := ntoq(qton(x),ART->QteForm)
FIELD->DC  := DC_CREDIT
RETURN NIL

#endif DEF_ART

#ifdef DEF_CTS

**
** CTS - centralisation MVS
**
FUNCTION oCts()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name CTS
ddIndex b on CTS->IdArt + CTS->Periode + CTS->IdJnl + CTS->Intra
ddFld IdArt    ,C, LenIdArt(),0  when .f. picture PicIdArt()
ddFld Periode  ,C, LEN_PERIODE,0 when .f.
ddFld IdJnl    ,C, LenIdJnl(),0  when .f.
ddFld Qte      ,C, LenQte(),0    when .f.
ddFld Mont     ,T, LenMont(),0   when .f. value val(CTS->Mont)
ddFld _ArtName ,C, LenArtName(),0 attrib V ;
                   block padr(ArtName(CTS->IdArt),LenArtName())
ddFld Intra    ,C, 3,0 when .f.
ddFld Anz      ,N, 6,0 when .f.
ddEndDef()
RETURN b


#endif DEF_CTS


FUNCTION ParIdDev(cPeriode)
RETURN DevDefault(cPeriode) if empty(PAR->IdDev)
RETURN PAR->IdDev
