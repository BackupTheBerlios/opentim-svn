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

#ifdef DEF_ANA
  static snMvaSum := 0
  static snMvaMust := 0
  static scDC
  static snDecPos
#endif DEF_ANA

#ifdef DEF_VEN

#ifdef DEF_MEMOR

static snBarHeight  := 4    // in 6/72 inch
static snBlackWidth := 1    // in 1/72 inch
static snSpaceWidth := 1    // in 1/72 inch

#endif DEF_MEMOR

#ifdef LG_FRENCH
  * #define MSG008  "Prix de vente infÇrieur au prix d'achat !"
  * #define MSG010  " : stock insuffisant !"
  static MSG012 := "Objet : obligatoire."
  #define MSG014  " n'existe pas dans la langue du document."
  * #define MSG015  "Compte gÇnÇral : obligatoire."
  #define MSG017  " : code invalide."
  #define MSG018  " : code T.V.A. non permis ou invalide !"
  #define MSG019  "Encodez le prix unitaire hors T.V.A."
  #define MSG020  "Encodez le prix unitaire T.V.A. comprise."
  #define MSG021  " : imputation non permise."
  #define MSG034  "TolÇrance maximale : "
  static MSG_WRN026 := " : compte gÇnÇral invalide pour  "
  static MSG_WRN050 := " : montant dÇpasse la tolÇrance TVA !"
  * static MSG_WRN051 := "Ce code TVA n'est pas tolÇrant !"
  #ifdef DEF_ACF
    static MSG_ARTACF := "Adapter prix signalÇtique"
    static LEG_ARTAFC := "[Sh-F4] SignalÇtique [F5] Facturation [F10] Confirmer [Esc] Abandon"
  #endif DEF_ACF
#endif
#ifdef LG_GERMAN
  * #define MSG008  "Verkaufspreis liegt unter Einkaufspreis !"
  * #define MSG010  " : Bestand unzureichend !"
  static MSG012 := "Objekt : darf nicht leer sein."
  #define MSG014  " existiert nicht in der Sprache des Dokuments."
  * #define MSG015  "Konto : darf nicht leer sein."
  #define MSG017  " : ungÅltige Vorgangsart."
  #define MSG018  " : unerlaubter oder falscher MWSt-Kode !"
  #define MSG019  "Geben Sie den Einzelpreis NETTO (ohne MWSt) ein !"
  #define MSG020  "Geben Sie den Einzelpreis BRUTTO (mit MWSt) ein !"
  #define MSG021  " : unerlaubte Buchung."
  #define MSG034  "Maximale Toleranz : "
  static MSG_WRN026 := " : ungÅltiges Generalkonto fÅr "
  static MSG_WRN050 := " : Betrag Åberschreitet MWSt-Toleranz !"
  * static MSG_WRN051 := "MWSt-Betrag darf nur bei toleranten MWSt-Codes geÑndert werden !"
  #ifdef DEF_ACF
    static MSG_ARTACF := "Artikelpreise anpassen"
    static LEG_ARTAFC := "[Sh-F4] Stammdaten [F5] Fakturierung [F10] BestÑtigen [Esc] Abbrechen"
  #endif DEF_ACF
#endif
#ifdef LG_EN
  #define MSG017  " : invalid item code"
  static MSG_WRN026 := " : invalid general account for "
  static MSG_WRN050 := " : amount exceeds the tolerance !"
  #ifdef DEF_ACF
    static MSG_ARTACF := "Artikelpreise anpassen"
    static LEG_ARTAFC := "[Sh-F4] Stammdaten [F5] Fakturierung [F10] BestÑtigen [Esc] Abbrechen"
  #endif DEF_ACF
#endif


static scOldValue
static slHasModules
static slHasAqt
static slHasTotals
static slPuTvac   := .f.
static snVenMont  := 0
static snSumBase  := 0
static snSumTaxe  := 0
static snTaxDecPos  := 0
static saJnl      := NIL
static slIsTotal  := .t.
static saDev      := NIL
static saReg      := NIL
* static snCours    := NIL
static scIntra    := "   "
static saIpr := NIL
static saIpb  // wird von VnlFirstCheck() gesetzt und nachtrÑglich
              // noch mal von verschiedenen anderen Funktionen benutzt.
static slIsVariante := .f.
static slLastVarLine := .f.

#ifdef DEF_SER
  static snSerMust := 0
  static snSerSum  := 0
  static snSerQteMust  := 0
  static snSerQteSum   := 0
#endif DEF_SER


#ifdef DEF_REMISE
  static saRemise := {}
  #define REMISE_IDRGA 1
  #define REMISE_QTE   2
  #define REMISE_ALEN  2
#endif DEF_REMISE



FUNCTION VnlSave()
RETURN {        ;
  snVenMont   , ;
  snSumBase   , ;
  snSumTaxe   , ;
  snTaxDecPos , ;
  saJnl       , ;
  slIsTotal   , ;
  saDev       , ;
  saReg       , ;
  scIntra     , ;
  saIpr       , ;
  slPuTvac,     ;
  slHasTotals,  ;
  slHasModules,  ;
  slIsVariante, ;
  SetDevise(),   ;
  TplLang(), ;
  slHasAqt ;
}

FUNCTION VnlRestore(a)
snVenMont   := a[1]
snSumBase   := a[2]
snSumTaxe   := a[3]
snTaxDecPos := a[4]
saJnl       := a[5]
slIsTotal   := a[6]
saDev       := a[7]
saReg       := a[8]
* snCours     := a[9]
scIntra     := a[9]
saIpr       := a[10]
slPuTvac    := a[11]
slHasTotals := a[12]
slHasModules := a[13]
slIsVariante := a[14]
SetDevise(a[15])
SetTplLang(a[16])
slHasAqt := a[17]
RETURN .t.


FUNCTION VnlNtom(n)
* RETURN space(LenMont()) if abs(n) < DEF_ALMOST_NULL // 0.0001
RETURN ntom(n,saDev[DEV_DECPOS])

FUNCTION VnlDecPos() ; RETURN saDev[DEV_DECPOS]

** Setzt interne Variablen zu Beginn des EDIT DATA auf VNL
** Gibt in einem den Query zurÅck, der zu benutzen ist.
**
FUNCTION VenVnlInit(jnl)
local a := VnlSave()
local nat
RETURN NIL if ! ParExist(VEN->IdPar)
#ifdef DEF_INTRA
  * if ! NatExist(PAR->Pays)
  *   SetMsg(PAR->Pays + MsgNatExist())
  *   RETURN NIL
  * endif
  scIntra := NatField(PAR->Pays,"Intra") // nat[NAT_INTRA]
#endif DEF_INTRA
if (saDev := DevLocate(VEN->IdDev)) == NIL
  SetMsg(VEN->IdDev + MsgDevExist())
  RETURN NIL
endif
#ifdef DEF_TAX
  if (saReg := RegLocate(VEN->IdReg)) == NIL
    SetMsg(VEN->IdReg + MsgRegExist())
    RETURN NIL
  endif
#endif DEF_TAX
if empty(VEN->Mont)
  slIsTotal := .f.
else
  slIsTotal := (JNLATTR_T $ jnl[JNL_ATTRIB])
endif
snVenMont   := val(VEN->Mont)
* snCours     := val(VEN->Cours)
saJnl    := jnl
snSumBase := 0
snSumTaxe := 0
snTaxDecPos := max(saDev[DEV_DECPOS],jnl[JNL_TAXDECPOS])
#ifdef DEF_REMISE
  saRemise := {}
#endif DEF_REMISE
saIpr := IprLocate( ;
  saJnl[JNL_IDCTR], PAR->IdPrt, PAR->IdPgp, saDev[DEV_IDDEV] ;
)
if saIpr == NIL
  SetMsg(MsgIprFail())
  RETURN NIL
endif
slPuTvac := (IPRATTR_C $ saIpr[IPR_ATTRIB])
slHasTotals := .f.
slHasModules := .f.
slHasAqt := .f.
slIsVariante := .f.
SetDevise(DevDefault(VEN->Periode))
SetTplLang(PAR->Langue)
RETURN a

**
** ArtVnlInit()
**
FUNCTION ArtVnlInit()
local a := VnlSave()
if (saDev := DevLocate(DevDefault(PerActive()))) == NIL
  RETURN NIL
endif
saJnl := NIL
RETURN a

FUNCTION VnlIdCtr()
RETURN JnlIdCtr(FIELD->IdJnl) if saJnl == NIL // indexord() == ORD_VNL_DOC
RETURN saJnl[JNL_IDCTR]

FUNCTION MsgIprFail()
local cMsg := trim(PrtName(PAR->IdPrt)) + " & "
cMsg += CtrName(saJnl[JNL_IDCTR])
#ifdef LG_GERMAN
cMsg += " : kein Basispreis " + saDev[DEV_IDDEV]
cMsg += ' fÅr Preisgruppe "'
#endif
#ifdef LG_FRENCH
cMsg += " : aucun prix de base en " + saDev[DEV_IDDEV]
cMsg += ' pour le groupe "'
#endif
#ifdef LG_EN
cMsg += " : no base price in " + saDev[DEV_IDDEV]
cMsg += ' for partner group  "'
#endif
cMsg += PAR->IdPgp + '"!'
RETURN cMsg


#endif DEF_VEN

#ifdef DEF_TAX

**
** GsbVnlTvac() - Get/Set block for virtual field VNL->_TVAC
**
FUNCTION GsbVnlTvac(x)
local tax := TaxLocate(VnlIdCtr(),FIELD->IdTax,.f.,VEN->Date)
local nMont
if x != NIL
  if tax == NIL
    // 20041104 : (zu testen) jetzt kann man TVAC auch eingeben, wenn
    // Zeile noch nicht existiert.
    RETURN NIL if ! VnlFirstCheck(VnlIdCtr())
    if empty(FIELD->IdTax)
      VnlSetIdTax()
    endif
    tax := TaxLocate(VnlIdCtr(),FIELD->IdTax,.f.,VEN->Date)
    RETURN NIL if tax == NIL
  endif
  x := strtran(x,",",".")
  if empty(tax[TAX_GENTIERS])
    nMont := netto(val(x),tax[TAX_TAUX])
  else // cocontractant und intracom: TVAC = HTVA
    nMont := val(x) 
  endif
  if slPuTvac
    FIELD->cMont := nToTax(nMont)
  else
    FIELD->cMont := VnlNtom(nMont)
  endif
  if empty(tax[TAX_GENTIERS])
    FIELD->MontT := nToTax(val(x)-val(FIELD->cMont))
  else // cocontractant und intracom: TVAC = HTVA, aber MTVA trotzdem != 0
    FIELD->MontT := nToTax(val(x)*tax[TAX_TAUX]/100)
  endif
  #ifdef DEF_ART
    if IsArtCode(FIELD->Code)
      ** 20041104 : (Nols) bei Eingabe von TVAC soll TIM Qte berechnen.
      ** 20061229 : bei PAC wurde VNL->Code nicht auf F gesetzt, wenn
      ** man den Preis TVAC manuell geÑndert hatte
      if !empty(FIELD->PrixU).or.!empty(FIELD->Qte)
        if empty(FIELD->Qte)
          if slPuTvac
            FIELD->Qte := ntoq(val(x)/val(FIELd->PrixU),ART->QteForm)
          else
            FIELD->Qte := ntoq(val(FIELD->cMont)/val(FIELD->PrixU),ART->QteForm)
          endif
        else
          if slPuTvac
            FIELD->PrixU := ntom(val(x)/qton(FIELD->Qte),VnlPuDecPos())
          else
            FIELD->PrixU := ntom(val(FIELD->cMont)/qton(FIELD->Qte),;
                              VnlPuDecPos())
            #ifdef DEF_PROVI
              FIELD->PrixPU  := FIELD->PrixU
            #endif DEF_PROVI
            if VNL->Code == LNCODE_ART
              VNL->Code := LNCODE_ARTFIXE
            endif
          endif
        #ifdef DEF_ACF
          VnlAcfUpdate()
        #endif DEF_ACF
        endif
      endif
    endif
  #endif DEF_ART
  RETURN NIL
endif
if eof() .or. bof() // 20071106, 20070801
  RETURN VnlNtom(snVenMont - (snSumBase + snSumTaxe)) if slIsTotal
  RETURN VnlNtom(snSumBase + snSumTaxe)
endif
RETURN space(LenMont()) if tax == NIL // ... was soll man da machen...
// in der folgenden Zeile mÅsste eigentlich auch noch TaxDecPos
// berÅcksichtigt werden.  Aber bisher hat sich niemand beklagt...
RETURN VnlNtom(VnlTvac()) if empty(tax[TAX_GENTIERS])
** bei intracom und vertragspartner wÑre der bruttobetrag hier nur
** irritierend...
RETURN space(LenMont())

#else

FUNCTION GsbVnlTvac(x)
RETURN VNL->cMont if x == NIL
VNL->cMont := x
RETURN NIL

#endif DEF_TAX

#ifdef DEF_VEN

**
** GsbVnlMont() - Get-Set-Block for virtual field FIELD->_TVAC
**
FUNCTION GsbVnlMont(x)
local tax
if x != NIL
  // [971106] fÅr cMont wurde snTaxDecPos nicht berÅcksichtigt
  x := strtran(x,",",".")
  if slPuTvac // TIMATTR_C $ MemAttrib
    FIELD->cMont := nToTax(val(x))
  else
    FIELD->cMont := VnlNtom(val(x))
  endif
  #ifdef DEF_TAX
  VnlSetTaxe()
  #endif DEF_TAX
  * FIELD->MontT := ""
  #ifdef DEF_ART
    if IsArtCode(FIELD->Code)
      if ! empty(FIELD->Qte + FIELD->PrixU)
                          #ifdef DEF_TAX
        if slPuTvac
          if (tax := TaxLocate(VnlIdCtr(),FIELD->IdTax,.f.,VEN->Date)) != NIL
            FIELD->PrixU := ntom( ;
              brutto(val(x),tax[TAX_TAUX])/qton1(FIELD->Qte), ;
              VnlPuDecPos() ;
            )
          endif
        else
                          #endif
          FIELD->PrixU := ntom( ;
            val(x)/qton1(FIELD->Qte), ;
            VnlPuDecPos() ;
          )
                          #ifdef DEF_TAX
        endif
                          #endif
      #ifdef DEF_PROVI // 19990714
        FIELD->PrixPU  := FIELD->PrixU
      #endif DEF_PROVI
      endif
      #ifdef DEF_ACF
        VnlAcfUpdate()
      #endif DEF_ACF
    endif
  #endif DEF_ART
  #ifdef DEF_SER
    VnlSerUpdate()
  #endif DEF_SER
  RETURN NIL
endif
if eof() .or. bof() // 20071106, 20070801
  RETURN VnlNtom(snVenMont - snSumBase - snSumTaxe) if slIsTotal
  RETURN VnlNtom(snSumBase)
endif
RETURN FIELD->cMont

* FUNCTION LnToDev(cMont,cIdDev)
* local nMont
* if saDev[DEV_IDDEV] == cIdDev
*   nMont := val(cMont)
*   ** sonst wÅrden DEM-Preise trotzdem immer geÑndert, weil der
*   ** Wechselkurs ja pro Dokument Ñndern kann...
* else
*   nMont := val(cMont) * val(DevCours(cIdDev)) / snCours
* endif
* RETURN ... ntoTax(nMont)


FUNCTION VnlBefore
local tax
RETURN NIL if FIELD->Code == LNCODE_TOTAL
* RETURN NIL if FIELD->Code == LNCODE_MODULE
RETURN NIL if VnlIsModDetail()
#ifdef DEF_NEWS
  RETURN NIL if FIELD->Code == LNCODE_NEWS
#endif
#ifdef DEF_TAX
  RETURN NIL if (tax := TaxLocate(saJnl[JNL_IDCTR],FIELD->IdTax,.f.,VEN->Date)) == NIL
  if empty(tax[TAX_GENTIERS])
    snSumTaxe -= round(val(FIELD->MontT),snTaxDecPos)
    * snSumTaxe -= round(val(FIELD->MontT),saDev[DEV_DECPOS])
    * snSumTaxe -= val(FIELD->MontT)
  endif
#endif DEF_TAX
snSumBase -= val(FIELD->cMont)
#ifdef DEF_REMISE
  if FIELD->Code == LNCODE_ART .or. FIELD->Code == LNCODE_ARTFIXE
    seek left(FIELD->IdArt,LenIdArt()) in ART
    VnlRemCollect(ART->IdRga,- qton1(FIELD->Qte))
  endif
#endif DEF_REMISE
RETURN NIL

FUNCTION VnlAfter
local tax
if FIELD->Code == LNCODE_TOTAL
  slHasTotals := .t.
  RETURN NIL
endif
if FIELD->Code == LNCODE_MODULE
  slHasModules := .t.
  * RETURN NIL // VnlTotRefresh()
endif
if VnlIsAqt()
  slHasAqt := .t.
endif
RETURN NIL if VnlIsModDetail()
#ifdef DEF_NEWS
  RETURN NIL if FIELD->Code == LNCODE_NEWS
#endif
#ifdef DEF_TAX
  RETURN NIL if (tax := TaxLocate(saJnl[JNL_IDCTR],FIELD->IdTax,.f.,VEN->Date)) == NIL
  if empty(tax[TAX_GENTIERS])
    snSumTaxe += round(val(FIELD->MontT),snTaxDecPos)
  endif
#endif
snSumBase += val(FIELD->cMont)
#ifdef DEF_REMISE
  if FIELD->Code == LNCODE_ART .or. FIELD->Code == LNCODE_ARTFIXE
    seek left(FIELD->IdArt,LenIdArt()) in ART
    VnlRemCollect(ART->IdRga,qton1(FIELD->Qte))
  endif
#endif DEF_REMISE
RETURN NIL

#ifdef DEF_REMISE

FUNCTION VnlRemCollect(cIdRga,nQte)
local i
local a := NIL
for i := 1 to len(saRemise)
  if saRemise[i][REMISE_IDRGA] == ART->IdRga
    a := saRemise[i]
  endif
next i
if a == NIL
  a := array(REMISE_ALEN)
  a[REMISE_IDRGA] := ART->IdRga
  a[REMISE_QTE]   := 0
  aadd(saRemise,a)
endif
a[REMISE_QTE] += nQte
RETURN NIL

#endif DEF_REMISE


FUNCTION LnIsTotal ; RETURN slIsTotal

FUNCTION VnlObjName(cIdLng)
#ifdef DEF_GEN
  RETURN GenName(left(FIELD->IdArt,LenIdGen()),cIdLng) if FIELD->Code == LNCODE_GEN
#endif DEF_GEN
#ifdef DEF_NEWS
  RETURN DbfPeek(oNew(),left(FIELD->IdArt,LenIdArt()),"NEW->Title","") if FIELD->Code == LNCODE_NEWS
#endif DEF_NEWS
#ifdef DEF_ART
  RETURN ArtName( ;
    left(FIELD->IdArt,LenIdArt()),cIdLng ;
  ) if IsArtCode(FIELD->Code)
#endif DEF_ART
RETURN "" //


*FUNCTION ObjName(cCode,cIdArt,cLangue)
*RETURN GenName(NIL,cLangue) if cCode == LNCODE_GEN
*#ifdef DEF_ART
*  RETURN ArtName(NIL,cLangue) if IsArtCode(cCode)
*#endif
*RETURN ""

FUNCTION VnlLibell(cRemarq)
if cRemarq != NIL
  FIELD->Desig := cRemarq
  RETURN NIL
endif
if eof() .or. bof() // 20071106, 20070801
  if slIsTotal
    if abs(snVenMont - (snSumBase + snSumTaxe)) > Tolerance(saDev[DEV_DECPOS])
    * if snVenMont - (snSumBase + snSumTaxe) != 0
    * if abs(snVenMont - (snSumBase + snSumTaxe)) > DEF_ALMOST_NULL // 0.0001
      RETURN padr(MsgBleibt(),40)
    endif
    RETURN space(LenVnlName())
  endif
  RETURN padr("TOTAL :",LenVnlName())
endif
RETURN FIELD->Desig if ! empty(FIELD->Desig)
#ifdef CUST_AMG
  cRemarq := padr(VnlObjName(MemLang1),LenVnlName())
#else
  cRemarq := padr(VnlObjName(PAR->Langue),LenVnlName())
#endif
if empty(cRemarq)
  cRemarq := padr(memoline(VNL->Memo,NIL,1,200),LenVnlName())
  * if !empty(cRemarq)
  *    RETURN "[F12] "+left(cRemarq,LenVnlName()-6)
  * endif
endif
RETURN cRemarq

FUNCTION LnQteForm
#ifdef DEF_ART
  RETURN ART->QteForm if IsArtCode(FIELD->Code) // FIELD->Code == LNCODE_ART
#endif
RETURN " "


**
**
FUNCTION VnlQteValidate()
local nQte
RETURN .t. if FIELD->Code == LNCODE_REMARQ
RETURN .t. if FIELD->Code == LNCODE_TOTAL
if ! VnlFirstCheck(saJnl[JNL_IDCTR])
  VNL->Qte := GetQte(VNL->Qte,"") // 20071106
  RETURN .t.
endif
RETURN .t. if ! QteValidate()
if FIELD->Code == LNCODE_MODULE
  RETURN VnlSetBase()
  * RETURN .t. if ! VnlSetBase()
  * RETURN VnlTotRefresh()
endif
#ifdef DEF_PRIXR
  FIELD->PrixR := VnlPrixR()
#endif
** [960520]
if empty(FIELD->PrixU) .and. qton1(FIELD->Qte) != 0
  RETURN VnlPuCompute()
endif
* RETURN VnlSetBase()
RETURN .t. if ! VnlSetBase()
#ifdef DEF_ALA // same code as in VnlIdValidate
  if VNL->Code == LNCODE_ART.and.!empty(VNL->Qte).and.VnlIsLinked()
    VnlModInsert(.f.)
    ddSendKey(K_ALT_F5)
  endif
#endif
RETURN .t.
* RETURN VnlTotRefresh()


FUNCTION StdQteValidate()
if FIELD->Code == LNCODE_ART .or. FIELD->Code == LNCODE_ARTFIXE
  #ifdef DEF_QTESUB
    if empty(FIELD->Qte1)
      FIELD->Qte := GetQte(FIELD->Qte,LnQteForm())
    else
      if ! empty(FIELD->Qte2)
        if ! empty(FIELD->Qte3)
          FIELD->Qte  := ntoq(val(FIELD->Qte1)*val(FIELD->Qte2)*val(FIELD->Qte3)/10000,LnQteForm())
        else
          FIELD->Qte  := ntoq(val(FIELD->Qte1)*val(FIELD->Qte2)/100,LnQteForm())
        endif
      else
        FIELD->Qte  := ntoq(val(FIELD->Qte1),LnQteForm())
      endif
    endif
  #else
    FIELD->Qte := GetQte(FIELD->Qte,LnQteForm())
  #endif DEF_QTESUB
  ** 19990805 : bisher waren die beiden folgenden Blîcke nur wenn NICHT
  ** DEF_QTESUB
  #ifdef DEF_REMISE
    if FIELD->Code == LNCODE_ART
      FIELD->PrixU := VnlPrixArt()
    endif
  #endif DEF_REMISE
  #ifdef DEF_INT
    SetQteStat()
    * if ! empty(ART->QteStat)
    *   FIELD->QteStat := ntoq( ;
    *     qton1(FIELD->Qte)*qton1(ART->QteStat), ;
    *     IntQteForm(FIELD->IdInt) ;
    *   )
    * endif
  #endif DEF_INT
else
  FIELD->Qte := GetQte(FIELD->Qte,LnQteForm())
endif
RETURN .t.




* FUNCTION VnlCours ; RETURN snCours

**
** VnlPuCompute() : StÅckpreis := Gesamt / Menge
**
FUNCTION VnlPuCompute
#ifdef DEF_TAX
  if slPuTvac
    FIELD->PrixU := ntom( ;
      (val(FIELD->cMont) + val(FIELD->MontT)) / qton1(FIELD->Qte), ;
      VnlPuDecPos() ;
    )
  else
    FIELD->PrixU := ntom( ;
      val(FIELD->cMont) / qton1(FIELD->Qte), ;
      VnlPuDecPos() ;
    )
  endif
#else
  FIELD->PrixU := ntom( ;
    val(FIELD->cMont) / qton1(FIELD->Qte), ;
    VnlPuDecPos() ;
  )
#endif DEF_TAX
      #ifdef DEF_PROVI // 19990714
        FIELD->PrixPU  := FIELD->PrixU
      #endif DEF_PROVI
RETURN .t.

FUNCTION VnlQteR()
#ifdef CUST_AGV
  RETURN qton1(VNL->QteR)
#else
  RETURN qton1(VNL->Qte)
#endif


#ifdef DEF_INT

FUNCTION SetQteStat(cQteStat)
FIELD->IdInt := VnlIntDefault()
if empty(cQteStat)
  FIELD->QteStat := ""
else
  FIELD->QteStat := ntoq( ;
    VnlQteR()*qton(cQteStat), ;
    IntQteForm(FIELD->IdInt) ;
  )
endif
RETURN .t.

#endif

**
**  nach Eingabe FIELD->IdArt oder FIELD->Code
**
FUNCTION VnlIdValidate
if empty(FIELD->Code)
  FIELD->Code := LNCODE_REMARQ
endif
if empty(FIELD->IdArt)
  if FIELD->Code == LNCODE_GEN
    FIELD->IdArt := PAR->IdGen
  elseif IsArtCode(FIELD->Code)
    FIELD->IdArt := "*"
  * else
  *   FIELD->Code := LNCODE_REMARQ
  endif
endif
if trim(FIELD->IdArt) == "#"
  FIELD->Code := LNCODE_VARIANTE
elseif FIELD->Code == LNCODE_VARIANTE
  FIELD->Code := LNCODE_ART
endif
** Wenn man in IdArt "T" eingibt, wird Code automatisch auf T gesetzt
** und umgekehrt
if ArtIsTotal(FIELD->IdArt) // trim(FIELD->IdArt) == "T"
  FIELD->Code := LNCODE_TOTAL
elseif VnlIsModule() // z.b. : "M" $ ART->Attrib
  if VNL->Code == LNCODE_MODULE
    VnlModUpdate()
  else
    VNL->Code := LNCODE_MODULE
    VnlModInsert(.t.)
  endif
  ddSendKey(K_ALT_F5)
  // VnlModValidate()
elseif FIELD->Code == LNCODE_ARTFIXE .or. FIELD->Code == LNCODE_TOTAL
  // wenn man IdArt Ñndert, darf Code nicht auf F bleiben
  // 19981116 auch "T" darf er nicht bleiben: wird immer auf "A" gesetzt
  FIELD->Code := LNCODE_ART
endif
if FIELD->Code == LNCODE_REMARQ
  FIELD->IdTax := ""
  FIELD->IdArt := ""
  FIELD->PrixU := ""
  FIELD->cMont := ""
  RETURN .t.
endif
#ifdef DEF_NEWS
  if FIELD->Code == LNCODE_NEWS
    FIELD->IdTax := ""
    FIELD->PrixU := ""
    FIELD->cMont := ""
    RETURN .t.
  endif
#endif
RETURN .t. if ! VnlFirstCheck(saJnl[JNL_IDCTR])
RETURN .f. if ! OnVnlIdValidate()
RETURN VnlTotValidate() if FIELD->Code == LNCODE_TOTAL
#ifdef DEF_TAX
  VnlSetIdTax()
  VnlSetTotal()
  VnlSetTaxe()
  RETURN .t. if ! VnlTaxCheck()
#endif DEF_TAX
#ifdef DEF_ART
  // 20030219
  if FIELD->Code == LNCODE_ART .or. FIELD->Code == LNCODE_MODULE
    FIELD->PrixU := ""
    // FIELD->PrixU muss zuerst geleert werden, weil VnlPuDecPos()
    // auch MntDecPos(VNL->PrixU) berÅcksichtigt
    FIELD->PrixU := VnlPrixArt()
    #ifdef DEF_PRIXR
      FIELD->PrixR := VnlPrixR()
    #endif DEF_PRIXR
    #ifdef DEF_INT
      if REGATTR_I $ saReg[REG_ATTRIB] // .and. JNLATTR_I $ saJnl[JNL_ATTRIB]
        SetQteStat(ART->QteStat)
      endif
    #endif DEF_INT
    #ifdef DEF_PROVI
      FIELD->IdPga   := ART->IdPga
      FIELD->GP      := GprDefault(ART->GP) // ,VEN->Auteur)
      FIELD->PrixPU  := FIELD->PrixU
      FIELD->PrixPL  := FIELD->PrixU
      FIELD->PrixL   := FIELD->PrixU
    #endif DEF_PROVI
    // 20030219
    VnlSetBase()
    *  VnlTotRefresh()
  endif
#endif DEF_ART
#ifdef DEF_INT
  if FIELD->Code == LNCODE_GEN
    if REGATTR_I $ saReg[REG_ATTRIB] // .and. JNLATTR_I $ saJnl[JNL_ATTRIB]
      SetQteStat("")
      * FIELD->IdInt := repl("?",LenIdInt())
      * FIELD->QteStat := ntoq( ;
      *   qton1(FIELD->Qte)*qton(ART->QteStat), ;
      *   IntQteForm(FIELD->IdInt) ;
      * )
    endif
  endif
#endif DEF_INT
#ifdef DEF_ALA // same code as in VnlQteValidate
  if FIELD->Code == LNCODE_ART.and.!empty(VNL->Qte).and.VnlIsLinked()
    VnlModInsert(.f.)
    ddSendKey(K_ALT_F5)
  endif
#endif
RETURN VnlAqtValidate() if VnlIsAqt()
RETURN .T.



* #ifdef DEF_ALA
* FUNCTION VnlIsLinked()
* RETURN HasRecords(oAla(),1,"ALA->IdArt1",VNL->IdArt)
* #endif


**
** wird auch aus VenVnlGenerate() gerufen
**
FUNCTION VnlTotValidate()
local cIdJnl := FIELD->IdJnl
local cIdDoc := FIELD->IdDoc
local cIdArt := FIELD->IdArt
local nRecNo := recno()
local nQte := 0
local nMont := 0
local nTaxe := 0
local nQteStat := 0
#ifdef DEF_PRIXR
local nPrixR := 0
#endif DEF_PRIXR
#ifdef DEF_QTESUB
  local nQte1 := 0
  local nQte2 := 0
  local nQte3 := 0
#endif DEF_QTESUB
skip -1
do while ! bof() .and. FIELD->IdDoc == cIdDoc ;
                 .and. FIELD->IdJnl == cIdJnl
  if FIELD->Code == LNCODE_TOTAL
    if FIELD->IdArt == cIdArt
      exit
    endif
  elseif FIELD->Code == LNCODE_VARIANTE .or. VnlTotBegin()
    exit
  elseif ! VnlIsModDetail()
    nQte  += qton(FIELD->Qte)
    #ifdef DEF_INT
      nQteStat  += qton(FIELD->QteStat)
    #endif
    #ifdef DEF_PRIXR
      nPrixR += val(FIELD->PrixR) * qton1(FIELD->Qte)
    #endif DEF_PRIXR
    nMont += val(FIELD->cMont)
    nTaxe += val(FIELD->MontT)
    #ifdef DEF_QTESUB
      nQte1 += qton(FIELD->Qte1)
      nQte2 += qton(FIELD->Qte2) * qton(FIELD->Qte1)
      nQte3 += qton(FIELD->Qte3) * qton(FIELD->Qte1)
    #endif DEF_QTESUB
  endif
  skip -1
enddo
goto nRecNo
FIELD->PrixU := ""
FIELD->cMont := VnlNtom(nMont)
#ifdef DEF_TAX
  VnlSetIdTax()
  FIELD->MontT := ntotax(nTaxe)
#endif DEF_TAX
#ifdef DEF_PRIXR
  FIELD->PrixR := ntom(nPrixR,VnlPuDecPos())
#endif DEF_PRIXR
#ifdef DEF_QTESUB
  FIELD->Qte1 := str(nQte1,LenQte(),0)
  FIELD->Qte2 := str(nQte2,LenQte(),1)
  FIELD->Qte3 := str(nQte3,LenQte(),1)
#endif DEF_QTESUB
if empty(FIELD->Desig)
  #ifdef DEF_ART
    FIELD->Desig := trim(ArtName(NIL,PAR->Langue)) // "Total"
  #else
    FIELD->Desig := "Total"
  #endif DEF_ART
endif
if TIMATTR_T $ MemAttrib
  FIELD->Qte := ntoq(nQte,LnQteForm())
endif
// RETURN VnlTotFill(nQte,nQteStat)
RETURN .t.

// generate vnl lines from ALA
STATIC FUNCTION VnlModInsert(lHidden)
local i
local a := {}
local cIdArt := left(VNL->IdArt,LenIdArt())
local nRecNo := recno()
local nQte := qton1(VNL->Qte)
#ifdef DEF_ALA
  open area oAla()
    softseek cIdArt
    do while ! eof() .and. ALA->IdArt1 == cIdArt
      aadd(a, { ;
        ALA->NB, nQte*qton1(ALA->Qte), ALA->IdArt2, ALA->Prix1, ALA->PrixR ;
      })
      skip
    enddo
  close area
  unlock record // neu 20061011
  for i := 1 to len(a)
    // cDesig,cQte,cCode,cIdArt,cPrixU,cVnlAttrib,cPrixR ;
    VnlInsert( ;
      a[i][1], ; // Bemerkung
      a[i][2], ; // Menge
      LNCODE_ART, ; // FIELD->Code
      a[i][3], ; // IdArt
      a[i][4], ; // ALA->Prix1
      if(lHidden,VNLATTR_H,""), ; // VNL->Attrib
      a[i][5]  ; // ALA->PrixR
    )
  next i
  goto nRecNo
  RETURN .t. if ! ddRecLock()
  RETURN .f. if ! VnlFirstCheck(saJnl[JNL_IDCTR])
  // removed 20061011: goto nRecNo
#endif DEF_ALA
RETURN .t.


**
**
**
FUNCTION VnlModUpdate()
local nCount := 0
local cIdJnl := FIELD->IdJnl
local cIdDoc := FIELD->IdDoc
local nRecNo := recno()
local nQte := 0
local nMont := 0
local nTaxe := 0
* local nPrixU := 0
#ifdef DEF_PRIXR
local nPrixR := 0
#endif DEF_PRIXR
#ifdef DEF_QTESUB
  local nQte1 := 0
  local nQte2 := 0
  local nQte3 := 0
#endif DEF_QTESUB
skip
do while ! eof() .and. FIELD->IdDoc == cIdDoc ;
                 .and. FIELD->IdJnl == cIdJnl ;
                 .and. FIELD->Code != LNCODE_MODULE ;
                 .and. VnlIsModDetail()
  nQte  += qton(FIELD->Qte)
  #ifdef DEF_PRIXR
    nPrixR += val(FIELD->PrixR) * qton1(FIELD->Qte)
  #endif DEF_PRIXR
  nMont += val(FIELD->cMont)
  nTaxe += val(FIELD->MontT)
  #ifdef DEF_QTESUB
    nQte1 += qton(FIELD->Qte1)
    nQte2 += qton(FIELD->Qte2) * qton(FIELD->Qte1)
    nQte3 += qton(FIELD->Qte3) * qton(FIELD->Qte1)
  #endif DEF_QTESUB
  skip
  nCount++
enddo
goto nRecNo
* if DoAlaDetail()
  if DoModPrix1() // VK von Modulen
    FIELD->PrixU := VnlNtom(nMont)
    #ifdef DEF_PROVI // 19990714
      FIELD->PrixPU  := FIELD->PrixU
    #endif DEF_PROVI
  endif
  #ifdef DEF_PRIXR
    FIELD->PrixR := ntom(nPrixR,VnlPuDecPos())
  #endif DEF_PRIXR
  #ifdef DEF_TAX
    VnlSetIdTax()
  #endif DEF_TAX
  RETURN .t. if ! VnlSetBase()
  #ifdef DEF_QTESUB
    FIELD->Qte1 := str(nQte1,LenQte(),0)
    FIELD->Qte2 := str(nQte2,LenQte(),1)
    FIELD->Qte3 := str(nQte3,LenQte(),1)
  #endif DEF_QTESUB
*else
*  #ifdef DEF_TAX
*    VnlSetIdTax()
*  #endif DEF_TAX
*  RETURN .t. if ! VnlSetBase()
*endif
#ifdef DEF_ART
  if empty(FIELD->Desig)
    FIELD->Desig := trim(ArtName(NIL,PAR->Langue))
  endif
#endif DEF_ART
unlock record
* VnlTotRefresh()
RETURN .t.


FUNCTION VnlAqtValidate()
local cIdJnl := FIELD->IdJnl
local cIdDoc := FIELD->IdDoc
local cIdArt := FIELD->IdArt
local nRecNo := recno()
local nQte := 0
local nMont := 0
local nTaxe := 0
local nQteStat := 0
#ifdef DEF_PRIXR
local nPrixR := 0
#endif DEF_PRIXR
#ifdef DEF_QTESUB
  local nQte1 := 0
  local nQte2 := 0
  local nQte3 := 0
#endif DEF_QTESUB
skip -1
do while ! bof() .and. FIELD->IdDoc == cIdDoc ;
                 .and. FIELD->IdJnl == cIdJnl
  if FIELD->Code == LNCODE_TOTAL
      exit
  elseif FIELD->IdArt == cIdArt
    exit
  elseif FIELD->Code == LNCODE_VARIANTE .or. VnlTotBegin()
    exit
  elseif ! VnlIsModDetail()
    nQte  += VnlQteR() // qton(FIELD->Qte)
    #ifdef DEF_INT
      nQteStat  += qton(FIELD->QteStat)
    #endif
    #ifdef DEF_PRIXR
      nPrixR += val(FIELD->PrixR) * qton1(FIELD->Qte)
    #endif DEF_PRIXR
    nMont += val(FIELD->cMont)
    nTaxe += val(FIELD->MontT)
  endif
  skip -1
enddo
goto nRecNo
* FIELD->PrixU := ""
* FIELD->cMont := VnlNtom(nMont)
* #ifdef DEF_TAX
*   VnlSetIdTax()
*   FIELD->MontT := ntotax(nTaxe)
* #endif DEF_TAX
* #ifdef DEF_PRIXR
*   FIELD->PrixR := ntom(nPrixR,VnlPuDecPos())
* #endif DEF_PRIXR
* #ifdef DEF_QTESUB
*   FIELD->Qte1 := str(nQte1,LenQte(),0)
*   FIELD->Qte2 := str(nQte2,LenQte(),1)
*   FIELD->Qte3 := str(nQte3,LenQte(),1)
* #endif DEF_QTESUB
* if empty(FIELD->Desig)
*   #ifdef DEF_ART
*     FIELD->Desig := trim(ArtName(NIL,PAR->Langue)) // "Total"
*   #else
*     FIELD->Desig := "Total"
*   #endif DEF_ART
* endif
RETURN .f. if ! VnlAqtFill(nQte,nQteStat)
RETURN VnlQteValidate()



**
** VnlTotRefresh() wird aufgerufen, wenn der Benutzer ein Feld
** FIELD->Mult oder FIELD->Qte oder FIELD->PrixU oder... bearbeitet hat.
** Aktualisiert alle *anderen* M- und T-Zeilen
**
FUNCTION VnlTotRefresh
local nRecNo := recno()
local lLocked := a_islock()
local cIdJnl := FIELD->IdJnl
local cIdDoc := FIELD->IdDoc
if slHasTotals
  MsgDisplay(MsgWorking())
  do while ! eof() .and. FIELD->IdDoc == cIdDoc ;
                   .and. FIELD->IdJnl == cIdJnl
    if TaskInter() ; exit ; endif
    if FIELD->Code == LNCODE_TOTAL .and. recno() != nRecNo
      if VnlFirstCheck(saJnl[JNL_IDCTR])
        if ddRecLock()
          VnlTotValidate()
          unlock record
        endif
      endif
      exit
    endif
    skip
  enddo
  goto nRecNo
endif
if slHasAqt
  MsgDisplay(MsgWorking())
  do while ! eof() .and. FIELD->IdDoc == cIdDoc ;
                   .and. FIELD->IdJnl == cIdJnl
    if TaskInter() ; exit ; endif
    if VnlIsAqt() .and. recno() != nRecNo
      if VnlFirstCheck(saJnl[JNL_IDCTR])
        if ddRecLock()
          VnlAqtValidate()
          unlock record
        endif
      endif
      exit
    endif
    skip
  enddo
  goto nRecNo
endif
if slHasModules .and. VnlIsModDetail()
  MsgDisplay(MsgWorking())
  skip -1
  do while ! bof() .and. FIELD->IdDoc == cIdDoc ;
                   .and. FIELD->IdJnl == cIdJnl
    if TaskInter() ; exit ; endif
    if FIELD->Code == LNCODE_MODULE .and. recno() != nRecNo
      if VnlFirstCheck(saJnl[JNL_IDCTR])
        if ddRecLock()
          VnlModUpdate()
          unlock record
        endif
      endif
      exit
    endif
    skip -1
  enddo
  goto nRecNo
endif
if lLocked.and. !ddRecLock()
  Warning("VnlTotRefresh() failed to restore record lock")
endif
ddSendKey(K_ALT_F5)
RETURN .t.

#ifdef DEF_ART

STATIC FUNCTION VnlPrixArt
local cPrixU := VnlAcfPrix( ;
  padr(FIELD->IdArt,LenIdArt()), ;
  saJnl[JNL_IDCTR], ;
  VEN->IdPar, ;
  VEN->IdDev ;
)
local nQte   := qton1(FIELD->Qte)
#ifdef DEF_REMISE
  local i
  local rpp
  local cRpqRemise
#endif DEF_REMISE
#ifdef DEF_TAX
  local tax
#endif DEF_TAX
#ifdef DEF_REMISE
  for i := 1 to len(saRemise)
    if saRemise[i][REMISE_IDRGA] == ART->IdRga
      nQte += saRemise[i][REMISE_QTE]
    endif
  next i
  cRpqRemise := RpqRemise(PAR->IdPgp,ART->IdRga,nQte)
  if ! empty(ART->IdPga)
    cPrixU := ntom( ;
      val(cPrixU) * (100 - val(RppRemise(ART->IdPga,PAR->IdPgp))) / 100, ;
      VnlPuDecPos() ;
    )
  endif
  if ! empty(cRpqRemise)
    cPrixU := ntom( ;
      val(cPrixU) * (100 - val(cRpqRemise)) / 100, ;
      VnlPuDecPos() ;
    )
  endif
#endif DEF_REMISE
RETURN FIELD->PrixU if empty(cPrixU)
* #ifdef DEF_TAX
*   if TIMATTR_C $ MemAttrib // VEN->Attrib
*     RETURN "" if (tax := TaxLocate(saJnl[JNL_IDCTR],FIELD->IdTax,.f.,VEN->Date)) == NIL
*     RETURN ntom( ;
*       brutto( val(cPrixU), tax[TAX_TAUX]), ;
*       VnlPuDecPos() ;
*     )
*   endif
* #endif
RETURN cPrixU

STATIC FUNCTION VnlIprPrix() // cIdArt,cIdPar)
local nPrix
RETURN 0 if empty(saIpr[IPR_PRIXU])
nPrix := xparse(saIpr[IPR_PRIXU])
if empty(saIpr[IPR_IDDEV])
  * nPrix := nPrix / snCours
  if ArtIdDev() != VEN->IdDev
    nPrix := Dev2Db(ArtIdDev(),VEN->Periode,nPrix)
    nPrix := VenDb2Dev(nPrix)
  endif
* wenn nicht leer ist, dann ist es ja sowieso == VEN->IdDev
endif
RETURN nPrix

FUNCTION VenDb2Dev(nMont)
RETURN nMont if VEN->IdDev == DevDefault(VEN->Periode)
RETURN Db2Dev(VEN->IdDev,VEN->Periode,nMont) if empty(VEN->Cours)
RETURN nMont * val(VEN->Cours) if VEN->Periode >= PerToggle()
RETURN nMont / val(VEN->Cours)

FUNCTION VenDev2Db(nMont)
RETURN nMont if VEN->IdDev == DevDefault(VEN->Periode)
RETURN Dev2Db(VEN->IdDev,VEN->Periode,nMont) if empty(VEN->Cours)
RETURN nMont / val(VEN->Cours) if VEN->Periode >= PerToggle()
RETURN nMont * val(VEN->Cours)

static FUNCTION VnlAcfPrix(cIdArt,cIdCtr,cIdPar,cIdDev)
/*
  returns unit price (if necessary converted to cIdDev)
*/
local nPrix := 0
local cQte := FIELD->Qte
#ifdef DEF_ACF
  #ifdef DEF_ACFIPR
    open area oAcf()
      softseek cIdArt
      do while ! eof() .and. ACF->IdArt == cIdArt
        if ACF->IdCtr == cIdCtr
          * if ACF->IdDev == cIdDev
            if empty(ACF->IdPar) .or. ACF->IdPar == cIdPar
              exit
            endif
          * endif
        endif
        skip
      enddo
      if ACF->IdArt != cIdArt
        goto lastrec()+1
      endif
      nPrix := VnlIprPrix()
    close area
  #else
    nPrix := VnlIprPrix()
    open area oAcf()
      softseek cIdArt
      do while ! eof() .and. ACF->IdArt == cIdArt
        if ACF->IdCtr == cIdCtr
          if ACF->IdDev == cIdDev
            if empty(ACF->IdPar) .or. ACF->IdPar == cIdPar
              nPrix := val(ACF->Prix)
              if empty(cQte)
                cQte  := ACF->Packing
              endif
            endif
          endif
        endif
        skip
      enddo
    close area
    FIELD->Qte := cQte
  #endif DEF_ACF
#else
  nPrix := VnlIprPrix()
#endif DEF_ACF
RETURN ntom(nPrix,VnlPuDecPos())



#ifdef DEF_REMISE

** ArtPgpPrix
**
FUNCTION ArtPgpPrix(cIdPgp,cField)
* default cField to scArtPrice
* default cField to "Prix1"
RETURN &("ART->" + cField) if empty(ART->IdPga)
RETURN ntom( ;
  val(&("ART->" + cField)) * (100 - val(RppRemise(ART->IdPga,cIdPgp))) / 100, ;
  ArtPuDecPos() ;
)

#endif DEF_REMISE


FUNCTION ArtPrixRpp(cIdPgp,cIdDev)
local rpp
local cPrixU := ntom(VnlIprPrix(),VnlPuDecPos())
#ifdef DEF_REMISE
  if ! empty(ART->IdPga)
    cPrixU := ntom( ;
      val(cPrixU) * (100 - val(RppRemise(ART->IdPga,cIdPgp))) / 100, ;
      ArtPuDecPos() ;
    )
  endif
#endif DEF_REMISE
RETURN cPrixU


#endif DEF_ART

#ifdef DEF_ALA

STATIC FUNCTION VnlInsert( ;
  cDesig,nQte,cCode,cIdArt,cPrixU,cVnlAttrib,cPrixR ;
)
RETURN .f. if VnlCreate( ;
  FIELD->IdJnl,FIELD->IdDoc,NextNum(FIELD->Line) ;
) == DDCREATE_FAIL
default cCode to LNCODE_ART
default cIdArt to "*"
FIELD->Code  := cCode
FIELD->IdArt := cIdArt
FIELD->Desig := cDesig
FIELD->PrixU := cPrixU
#ifdef DEF_VNLATTR
  default cVnlAttrib to ""
  FIELD->Attrib := cVnlAttrib
#endif DEF_VNLATTR
#ifdef DEF_PRIXR
  default cPrixR to ""
  FIELD->PrixR := cPrixR
#endif DEF_PRIXR
VnlIdValidate()
FIELD->Qte   := ntoq(nQte,ART->QteForm)
VnlQteValidate()
VnlValidate()
* VnlPostEdit()
VnlAfter()
unlock record
RETURN .t.

#endif DEF_ALA

FUNCTION VnlGenValidate()
RETURN .t.



**
** VnlPuValidate() - fÅr VNL
**
FUNCTION VnlPuValidate()
local cPrixU
FIELD->PrixU := strtran(FIELD->PrixU,",",".")
RETURN .t. if FIELD->Code == LNCODE_REMARQ
RETURN .f. if ! VnlFirstCheck(saJnl[JNL_IDCTR])
#ifdef DEF_TAX
RETURN .f. if ! VnlTaxCheck()
#endif DEF_TAX
if FIELD->Code == LNCODE_GEN
  if val(FIELD->PrixU) != 0
    FIELD->PrixU := ntom(val(FIELD->PrixU),saDev[DEV_DECPOS])
  endif
                                                 #ifdef DEF_ART
elseif FIELD->Code == LNCODE_ART
  if empty(FIELD->PrixU)
    FIELD->PrixU := VnlPrixArt()
  else
    FIELD->Code := LNCODE_ARTFIXE
    if val(FIELD->PrixU) != 0
      FIELD->PrixU := ntom(val(FIELD->PrixU),VnlPuDecPos())
      #ifdef DEF_ACF
        VnlAcfUpdate()
      #endif DEF_ACF
      #ifdef DEF_SER
        VnlSerUpdate()
      #endif DEF_SER
    endif
  endif
elseif FIELD->Code == LNCODE_ARTFIXE
  if empty(FIELD->PrixU)
    FIELD->PrixU := VnlPrixArt()
    FIELD->Code  := LNCODE_ART
  elseif val(FIELD->PrixU) != 0
    FIELD->PrixU := ntom(val(FIELD->PrixU),VnlPuDecPos())
    #ifdef DEF_ACF
      VnlAcfUpdate()
    #endif DEF_ACF
    #ifdef DEF_SER
      VnlSerUpdate()
    #endif DEF_SER
  endif
elseif val(FIELD->PrixU) != 0
  FIELD->PrixU := ntom(val(FIELD->PrixU),VnlPuDecPos())
#endif DEF_ART
endif
#ifdef DEF_PROVI
  FIELD->PrixPU  := FIELD->PrixU
#endif DEF_PROVI
RETURN .t. if empty(FIELD->PrixU)
RETURN VnlSetBase()
* RETURN .t. if ! VnlSetBase()
* RETURN VnlTotRefresh()

#ifdef DEF_ACF

FUNCTION VnlAcfUpdate()
local cIdArt := left(FIELD->IdArt,LenIdArt())
local lFound := .f.
local lOkay  := .f.
local cQte := FIELD->Qte
local cMarge
* local cPrixR
* RETURN NIL if ! JNLATTR_R $ saJnl[JNL_ATTRIB]
RETURN NIL if !DoVnlAcfUpdate()
open area oAcf()
  lOkay := .t.
  softseek cIdArt
  do while lOkay .and. ! eof() .and. ACF->IdArt == cIdArt
    if ACF->IdDev == VEN->IdDev
      if ACF->IdCtr == saJnl[JNL_IDCTR]
        if empty(ACF->IdPar) .or. ACF->IdPar == VEN->IdPar
          if qton1(cQte) >= qton1(ACF->Packing)
            if ddRecLock()
              lFound := .t.
              if empty(ACF->IdPar)
                ACF->IdPar := VEN->IdPar
              endif
              ACF->Date := VEN->Date
              ACF->Prix := VNL->PrixU
            else
              lOkay := .f.
            endif
            exit
          endif
        endif
      endif
    endif
    skip
  enddo
  if lOkay .and. ! lFound
    if dbAddRec()
      ACF->IdArt   := cIdArt
      ACF->IdPar   := VEN->IdPar
      ACF->Date    := VEN->Date
      ACF->IdDev   := VEN->IdDev
      ACF->Prix    := VNL->PrixU
      * if ARTATTR_Q $ ART->Attrib
      *   ACF->Packing := FIELD->Qte
      * endif
      * ACF->AcfRef  := FIELD->Desig
      ACF->IdCtr   := saJnl[JNL_IDCTR]
    else
      lOkay := .f.
    endif
  endif
  if lOkay
    lOkay := OnVnlAcfUpdate()
    unlock record
  endif
close area
RETURN NIL if ! lOkay
FIELD->Code  := LNCODE_ART
FIELD->PrixU := VnlPrixArt()
RETURN NIL

FUNCTION OnVnlAcfUpdate()
RETURN ActExec("ACFPRIX") // ,VNL->PrixU)
*RETURN AcfPrix(VNL->PrixU)
// wurde sowieso (glaube ich) nur bei PAC benutzt

FUNCTION AcfPrix(cAcfPrix)
local lOkay := .t.
* local cAcfPrix := FIELD->PrixU
select ART
if ddRecLock()
  * cAcfRef := ACF->AcfRef
  do while ! AppTerminate()
    open window (MSG_ARTACF) size 13,64 help "ARTACF" ;
                legend (LEG_ARTAFC)
    say ART->IdArt + " " + ART->Name1
    WinCr()
    say ParName()
    WinCr()
    say space(20) + padr("Bisher:",LenMont()) + "   " + padr("Neu:",LenMont())
    WinCr()
    say repl("ƒ",20) + repl("ƒ",LenMont()) + "ƒ¬ƒ" + repl("ƒ",LenMont())
    WinCr()
    if empty(ACF->Packing)
      say padr("StÅckpreis EK",20)
    else
      say padr("EK per " + alltrim(ACF->Packing),20)
    endif
    say ACF->Prix + " ≥ " + cAcfPrix
    if ACF->IdDev != DevDefault(PerActive())
      say " = " + DevDefault(PerActive()) + " " + ltrim(ntom( ;
        VenDev2Db(val(cAcfPrix)) ;
      ))
        **** val(cAcfPrix) * snCours ;
    endif
    * #ifdef DEF_PRIXR
    WinCr()
    say padr("Selbstkostenpreis",20) + ART->PrixR + " ≥ "
    get ART->PrixR GET_DECPOS(ArtPuDecPos())
    * #endif DEF_PRIXR
    WinCr()
    say padr("StÅckpreis",20) + ART->Prix1 + " ≥ "
    get ART->Prix1 valid ArtP1Validate(val(ART->PrixR))
    say " "
    aadd(GetList, GetNew(row(),col(),{||marge(val(ART->PrixR),val(ART->Prix1))}))
    atail(GetList):cargo := array(AG_ALEN)
    atail(GetList):preBlock := {||.f.}
    atail(GetList):display()
    * get cMarge when .f.
    * .. cMarge := marge(val(ART->PrixR),val(ART->Prix1))
    WinCr()
    say padr("VK inkl. MWSt.",20) + ART->TVAC + " ≥ "
    get ART->TVAC valid ArtTvacValidate(val(ART->PrixR))
    WinCr()
    say padr("Datum",20) + padl(dtoc(ACF->Date),LenMont()) + " ≥ "
    get ACF->Date
    WinCr()
    WinCr()
    say "Bestellnummer "
    get ACF->AcfRef picture "@K@S20"
    nKey := ReadScr()
    close window
    if nKey == K_F5
      ArtVnlEdit()
    elseif nKey == K_SH_F4
      ArtPage(ACF->IdArt)
    elseif nKey == K_ESC
      lOkay := .f.
      exit
    else
      ACF->Prix  := cAcfPrix
      * ART->PrixR := cPrixR
      exit
    endif
  enddo
  unlock record
else
  lOkay := .f.
endif
select ACF
RETURN lOkay


#endif DEF_ACF

* FUNCTION ArtPrice(cIdArt,cIdDev,cIdCtr,cIdPar)
* RETURN "ArtPrice()"

**
** VnlSetBase() - Gesamtbetrag neu rechnen (nach Eingabe PrixU oder Qte)
**
FUNCTION VnlSetBase()
local nQte := VnlQteBase() // qton1(FIELD->Qte)
local nPrixU := val(FIELD->PrixU)
local nBase := nPrixU * nQte
local nBrutto
#ifdef DEF_MULT
  if ! empty(FIELD->Mult)
    nPrixU *= val(FIELD->Mult)
    nBase  := nPrixU * nQte
  endif
#endif DEF_MULT
#ifdef DEF_TAX
  if slPuTvac // TIMATTR_C $ MemAttrib
    nBrutto := nBase
    nBase   := netto(nBase, TaxTaux(saJnl[JNL_IDCTR],FIELD->IdTax,VEN->Date))
    FIELD->MontT := ntoTax(nBrutto-nBase)
    FIELD->cMont := nToTax(nBase)
  else
    FIELD->cMont := VnlNtom(nBase)
    VnlSetTotal()
    VnlSetTaxe()
    * FIELD->MontT := ""
  endif
#else
  FIELD->cMont := VnlNtom(nBase)
#endif DEF_TAX
#ifdef DEF_MULT
  // Spezieller Test : prÅfen, ob p.u. x qte = cMont
  // Wenn VnlDecPos() = 0 ist und ein Artikel 1,- BEF kostet, aber durch
  // VNL->Mult verÑndert wird, dann kînnen Nachkommastellenfehler
  // kommen.
  nPrixU := round(nPrixU,VnlPuDecPos())
  if VnlNtom(nPrixU * nQte) != FIELD->cMont
    if VnlPuDecPos() == 0
      VNL->PrixU := ntom(val(VNL->PrixU),2)
    else
      OnVnlRoundError()
    endif
  endif
#endif DEF_MULT
#ifdef DEF_PRIXR
  if !empty(VNL->PrixR).and.val(FIELD->PrixR) > nPrixU .and. ! IPRATTR_R $ saIpr[IPR_ATTRIB]
    Warning( ;
      ltrim(ntom(nPrixU,VnlPuDecPos())) + MsgPrixR() ;
    )
  endif
#endif DEF_PRIXR
RETURN .t.

#ifdef DEF_PRIXR

FUNCTION MsgPrixR()
#ifdef LG_FRENCH
  RETURN " : prix infÇrieur au prix de revient !"
#else
  RETURN " : Preis unter Selbstkostenpreis !"
#endif

#endif DEF_PRIXR


FUNCTION ntoTax(nMont)
local nTaxDecPos := snTaxDecPos
local cMont := ntom(nMont,snTaxDecPos)
do while nTaxDecPos > 0 .and. left(cMont,1)=="*"
  nTaxDecPos--
  cMont := ntom(nMont,nTaxDecPos)
enddo
RETURN cMont

* FUNCTION VnlDecPos
* RETURN snTaxDecPos

FUNCTION VnlTaxDecPos ; RETURN snTaxDecPos

FUNCTION VnlValidate()
RETURN .t. if FIELD->Code == LNCODE_REMARQ
if empty(FIELD->IdArt)
  RETURN .f. if ! VnlIdValidate()
else
  RETURN .f. if ! VnlFirstCheck(saJnl[JNL_IDCTR])
endif
#ifdef DEF_ANA
  if GENATTR_Y $ GEN->Attrib .and. empty(VnlIdAna())
    VNL->IdAna := GEN->IdAna
  endif
#endif DEF_ANA
#ifdef DEF_ANA
  RETURN .f. if ! JnlAnaCheck(saJnl,VnlIdAna())
#endif
#ifdef DEF_NEWS
  RETURN .t. if FIELD->Code == LNCODE_NEWS
#endif
#ifdef DEF_TAX
RETURN VnlTaxCheck()
#endif DEF_TAX
RETURN .t.


FUNCTION VnlPostEdit()
RETURN .f. if ! VnlValidate()
if slIsTotal .and. empty(VNL->cMont)
   GsbVnlTvac(ntom(snVenMont - snSumBase - snSumTaxe))
endif
* #ifdef DEF_ANA
*   if !empty(VNL->cMont).and.GENATTR_Y $ GEN->Attrib
*     RETURN !SetMsg("IdAna is empty") if empty(VnlIdAna())
*   endif
* #endif DEF_ANA
* #ifdef DEF_ANA
*   if FIELD->Code == LNCODE_GEN .and. ! empty(FIELD->cMont) .and. GENATTR_Y $ GEN->Attrib
*     VnlMvaEdit()
*   endif
* #endif DEF_ANA
if VNL->Code == LNCODE_MODULE
  VnlModUpdate()
endif
if VnlValue() != scOldValue
* #ifdef DEF_PRIXR
*   if scOldValue != FIELD->cMont + FIELD->MontT + FIELD->PrixR
* #else
*   if scOldValue != FIELD->cMont + FIELD->MontT
* #endif
  VnlTotRefresh()
endif
RETURN .t.

**
** VnlSetTvac() setzt cMont und/oder MontT wenn sie leer sind
** ! vorher VnlFirstCheck() !
**
FUNCTION VnlSetTotal()
#ifdef DEF_TAX
  local tax
  if slIsTotal .and. empty(FIELD->MontT + FIELD->cMont)
    RETURN .f. if (tax := TaxLocate(saJnl[JNL_IDCTR],FIELD->IdTax,.t.,VEN->Date)) == NIL
    if empty(tax[TAX_GENTIERS])
      FIELD->cMont := VnlNtom(netto(snVenMont - (snSumBase + snSumTaxe),tax[TAX_TAUX]))
      FIELD->MontT := ntoTax(snVenMont - snSumBase - snSumTaxe - val(FIELD->cMont))
    else
      FIELD->cMont := VnlNtom(snVenMont - snSumBase - snSumTaxe)
    endif
  endif
#else
  if slIsTotal .and. empty(FIELD->cMont)
    FIELD->cMont := VnlNtom(snVenMont - snSumBase - snSumTaxe)
  endif
#endif DEF_TAX
RETURN .T.



*
*#ifdef DEF_ART
*  if FIELD->Code == LNCODE_ART
*    FIELD->cPrixA := ArtPamp()
*    #ifdef DEF_STOCK
*      if qton1(FIELD->Qte) > qton(ART->cStkP)
*        if LastGet() == "IdArt" .or. LastGet() == "Code" .or. LastGet() == "Qte"
*          if VenIsLivraison() .and. ART->Suivi == BUTTON_ON
*            Warning(FIELD->IdArt + MSG010)
*          endif
*        endif
*      endif
*    #endif
*    if "C" $ UsrAttrib()
*      if qton1(FIELD->Qte) > 0 .and. val(FIELD->cMont) > 0
*        if val(FIELD->cMont) * snCours < val(FIELD->cPrixA) * qton1(FIELD->Qte)
*          Warning(MSG008)
*        endif
*      endif
*    endif
*  endif
*#endif DEF_ART
*RETURN .t.

#ifdef DEF_GEN

FUNCTION StdArtIdGen(cIdCtr)
RETURN ART->IdGen if cIdCtr == "V"
if empty(cIdCtr)
  raise("cIdCtr is empty")
endif
* RETURN "" if !HasField(oArt(),"IdGen"+cIdCtr)
RETURN &("ART->IdGen"+cIdCtr)

* #else
* FUNCTION ArtIdGen()
* RETURN ""
#endif

#ifdef DEF_TAX
FUNCTION VenIdReg() ; RETURN VEN->IdReg
#else
FUNCTION VenIdReg() ; RETURN ""
#endif DEF_TAX

**
**
**
FUNCTION VnlFirstCheck(cIdCtr)
local lOkay := .f.
local cIdGen
* IdGen
RETURN .f. if ! ParExist(VEN->IdPar)
#ifdef DEF_GEN
  if FIELD->Code == LNCODE_GEN
    saIpb := NIL
    RETURN .f. if ! GenExist(left(FIELD->IdArt,LenIdGen()))
    if GenCtrExist(GEN->IdGen)
      RETURN .f. if ! OnGenCtrExist(GEN->IdGen,VEN->Periode,VEN->IdJnl)
    endif
    if GenJnlExist(GEN->IdGen)
      RETURN .f. if ! OnGenJnlExist(GEN->IdGen,VEN->Periode,VEN->IdJnl)
    endif
    lOkay := .t.
  endif
#endif DEF_GEN
#ifdef DEF_NEWS
  if FIELD->Code == LNCODE_NEWS
    saIpb := NIL
    RETURN NewExist(left(FIELD->IdArt,LenIdArt()))
  endif
#endif DEF_NEWS
#ifdef DEF_ART
  if IsArtCode(FIELD->Code)
    RETURN .f. if ! ArtExist(FIELD->IdArt)
    #ifdef DEF_IPB
      if (saIpb := IpbLocate( ;
        cIdCtr, ;
        VenIdReg(), ;
        ART->IdCat, ;
        VnlIdTax(), ;
        VEN->IdDev ;
      )) == NIL
        SetMsg( ;
          cIdCtr + "/" + ;
          VenIdReg() + "/" + ;
          ART->IdCat + "/" + ;
          VnlIdTax() + "/" + ;
          VEN->IdDev + MsgIpbFail() ;
        )
        RETURN .f.
      endif
      #ifdef DEF_GEN
        cIdGen := ArtIdGen(cIdCtr)
        if empty(cIdGen)
          cIdGen := saIpb[IPB_GENBASE]
        endif
        RETURN .f. if ! GenExist(cIdGen)
      #endif DEF_GEN
    #else
      cIdGen := ArtIdGen(cIdCtr)
      RETURN .f. if ! GenExist(cIdGen)
    #endif
    lOkay := .t.
  endif
#endif DEF_ART
if ! lOkay
  SetMsg(FIELD->Code + MSG017 ) // " : ungÅltige Vorgangsart !")
  RETURN .F.
endif
#ifdef DEF_GEN
  if GEN->IdCtr != cIdCtr .and. ! GENATTR_T $ GEN->Attrib
    SetMsg(GEN->IdGen + MSG_WRN026 + FIELD->IdJnl)
    RETURN .f.
  endif
  if empty(GEN->IdClj)
    SetMsg(GEN->IdGen + MSG_WRN026 + FIELD->IdJnl)
    RETURN .f.
  endif
#endif DEF_GEN
#ifdef DEF_VNA
  if !empty(VNL->Match)
    seek VNL->Match in VNA
    if (eof() in VNA) 
      RETURN !SetMsg(VNL->Match+" : rÇfÇrence de suite invalide!")
    * elseif VNA->IdArt != VNL->IdArt 
    *   RETURN !SetMsg(VNL->Match+"/"+VNL->IdArt+" : rÇfÇrence de suite invalide!")
    endif
    if VnaTrnLocate(saJnl) == NIL
      RETURN !SetMsg(VNA->IdJnl+"/"+VNL->IdJnl+" : sans instruction de suite!")
    endif
  endif
#endif DEF_VNA
RETURN .t.

#ifdef DEF_NEWS

FUNCTION NewExist(cId)
seek cId in NEW
if ! eof() in NEW
  RETURN .t.
endif
RETURN ! SetMsg(cId+" : no such news item")

#endif

FUNCTION MsgIpbFail()
#ifdef LG_FRENCH
  RETURN " : sans instruction d'imputation !"
#endif
#ifdef LG_GERMAN
  RETURN " : ohne Buchungsanweisung !"
#endif
#ifdef LG_EN
  RETURN " : without General Ledger Rule !"
#endif

* #endif coucou



**
**
FUNCTION VnlCreate(cIdJnl,cIdDoc,cLine)
local nCreate := DDCREATE_REFRESH
local nOrder := indexord()
local a,i
RETURN DDCREATE_FAIL if ! VenPreEdit()
if eof() .or. bof() // 20071106, 20070801
  nCreate := DDCREATE_EDIT
endif
ddSetOrder(1)
if empty(cLine)
  KeyGoBottom( cIdJnl + cIdDoc, "FIELD->IdJnl+FIELD->IdDoc" )
  cLine := NextNum(FIELD->Line)
else
  a:={}
  softseek cIdJnl+cIdDoc+cLine
  do while ! eof() .and. FIELD->IdDoc==cIdDoc .and. FIELD->IdJnl==cIdJnl
    aadd(a,recno())
    skip
  enddo
  for i := 1 to len(a)
    goto a[i]
    if ddRecLock()
      FIELD->Line := NextNum(FIELD->Line)
      unlock record
    endif
  next i
endif
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
FIELD->Line   := cLine
FIELD->IdJnl  := cIdJnl
FIELD->IdDoc  := cIdDoc
FIELD->Code   := JnlCode(cIdJnl)
RETURN nCreate




FUNCTION GsbVnlIdArt(x)
if x == NIL
  #ifdef DEF_ART
    RETURN SayIdArt(FIELD->IdArt) if IsArtCode(FIELD->Code) // FIELD->Code == LNCODE_ART
  #endif DEF_ART
  RETURN FIELD->IdArt
endif
if FIELD->Code == LNCODE_GEN
  FIELD->IdArt := GetIdGen(x)
                                         #ifdef DEF_ART
elseif IsArtCode(FIELD->Code) // FIELD->Code == LNCODE_ART
  FIELD->IdArt := GetIdArt(x)
                                         #endif DEF_ART
                                         #ifdef DEF_NEWS
elseif FIELD->Code == LNCODE_NEWS
  FIELD->IdArt := GetIdArt(x)
                                         #endif DEF_NEWS
else
  FIELD->IdArt := x
endif
RETURN NIL


#endif DEF_VEN

#ifdef DEF_MVA

FUNCTION MvaInit(cIdJnl,cIdDoc,cLine,cDC,nMont,cPeriode)
if cIdJnl == NIL
  snMvaMust := 0
  snMvaSum  := 0
  snDecPos  := 2
  RETURN NIL
endif
snMvaMust := nMont
snMvaSum  := 0
scDC      := cDC
snDecPos  := DevDecPos(DevDefault(cPeriode))
open area oMva()
  ddSetOrder(ORD_MVA_DOC)
  if cLine == NIL
    softseek cIdJnl + cIdDoc
    do while ! eof() .and. MVA->IdJnl == cIdJnl ;
                     .and. MVA->IdDoc == cIdDoc
      if MVA->DC == cDC
        snMvaSum += val(MVA->Mont)
      else
        snMvaSum -= val(MVA->Mont)
      endif
      skip
    enddo
  else
    softseek cIdJnl + cIdDoc + cLine
    do while MVA->IdJnl == cIdJnl .and. MVA->IdDoc == cIdDoc ;
                                  .and. MVA->Line  == cLine ;
                                  .and. ! eof()
      if MVA->DC == cDC
        snMvaSum += val(MVA->Mont)
      else
        snMvaSum -= val(MVA->Mont)
      endif
      skip
    enddo
  endif
close area
RETURN NIL

FUNCTION MvaBefore
if MVA->DC == scDC // JnlDC(MVA->IdJnl)
  snMvaSum -= val(MVA->Mont)
else
  snMvaSum += val(MVA->Mont)
endif
RETURN NIL

FUNCTION MvaAfter
if MVA->DC == scDC // JnlDC(MVA->IdJnl)
  snMvaSum += val(MVA->Mont)
else
  snMvaSum -= val(MVA->Mont)
endif
RETURN NIL

FUNCTION MvaMust
RETURN ntom(snMvaMust-snMvaSum,snDecPos)


FUNCTION GsbMvaLibell(x)
if x == NIL
  if eof() .or. bof() // 20071106, 20070801
    RETURN padr(MsgBleibt(),30) ;
      if abs(snMvaMust-snMvaSum) > Tolerance(snDecPos)
    RETURN space(30)
  endif
  RETURN padr(trim1(MVA->Remarq) + AnaName(MVA->IdAna),30)
endif
MVA->Remarq := x
RETURN NIL



FUNCTION MvaPostEdit
local jnl
RETURN .f. if ! AnaExist(MVA->IdAna)
#ifdef DEF_IMP
  RETURN .f. if ! BudExist(MVA->DC,MVA->IdBud)
#else
  RETURN .f. if ! GenExist(MVA->IdGen)
#endif
if empty(MVA->Mont)
  #ifdef DEF_IMP
    MVA->Mont := MvaMust()
  #else
    MVA->Mont := MvaMust()
    MVA->DC   := scDC
  #endif
endif
RETURN .t.

**
** MvaCreate()
**
FUNCTION MvaCreate(cIdJnl,cIdDoc,cIdGen,cLine,dDate,cPeriode)
local nCreate := DDCREATE_REFRESH
local nOrder := indexord()
if eof() .or. bof() // 20071106, 20070801
  nCreate := DDCREATE_EDIT
endif
if cLine == NIL
  ddSetOrder(1)
  cLine := MVA->Line
  KeyGoBottom( cIdJnl + cIdDoc, "MVA->IdJnl+MVA->IdDoc" )
  if empty(cLine)
    cLine := NextNum(MVA->Line)
  else
    do while .t.
      if MVA->Line >= cLine
        if ddRecLock()
          MVA->Line := NextNum(MVA->Line)
          unlock record
        endif
      else
        exit
      endif
      skip -1
      if bof() .or. MVA->IdDoc != cIdDoc .or. MVA->IdJnl != cIdJnl
        exit
      endif
    enddo
  endif
  ddSetOrder(nOrder)
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
MVA->IdJnl    := cIdJnl
MVA->IdDoc    := cIdDoc
MVA->Line     := cLine
MVA->Date     := dDate
MVA->Periode  := cPeriode
if cIdGen != NIL
  #ifdef DEF_IMP
    MVA->IdBud := cIdGen
    MVA->DC    := scDC
  #else
    MVA->IdGen := cIdGen
  #endif
endif
* unlock record 19980430
RETURN nCreate

#endif DEF_MVA

#ifdef DEF_VEN

FUNCTION VnlRefExt
local cRef := ""
#ifdef DEF_ACF
  if IsArtCode(FIELD->Code)
    RETURN ArtAcfRef(left(FIELD->IdArt,LenIdArt()),VEN->IdPar)
  endif
#endif DEF_ACF
RETURN cRef

**
** VnlResetAll()
**
FUNCTION VnlResetAll
local cOptions
local nRecNo := recno()
RETURN .f. if ! VenPreEdit()
RETURN .f. if (cOptions :=  PickResetOptions()) == NIL
if ! ddScan( {|| VnlReset(cOptions)} )
  Warning(SetMsg())
endif
VnlTotRefresh()
if nRecNo == lastrec() + 1
  ddGoBottom(.t.)
else
  ddRefreshAll(oVnl())
endif
ddSetUpdated(.t.) // oVnl()[AD_UPDATED] := .T.
RETURN SetMnuDone()

FUNCTION PickResetOptions()
static cOptions := "RUT"
local aOptions := {}
#ifdef LG_FRENCH
  * aadd(aOptions, { VNLRESET_REMISE, "Remises       " } )
  aadd(aOptions, { VNLRESET_PU    , "prix Unitaires" } )
  aadd(aOptions, { VNLRESET_TAX   , "Codes TVA     " } )
#else
  * aadd(aOptions, { VNLRESET_REMISE, "ErmÑ·igungen " } )
  aadd(aOptions, { VNLRESET_PU    , "StÅckpreise  " } )
  aadd(aOptions, { VNLRESET_TAX   , "MWSt-Codes   " } )
#endif
RETURN PickAttrib(aOptions,MsgVnlReset(),cOptions,"","VNLRESET")

FUNCTION MsgVnlReset()
#ifdef LG_GERMAN
RETURN "Preise neu rechnen"
#else
RETURN "Recalculer prix"
#endif

**
** Wird nach Automatikfakturierung benutzt
**
FUNCTION VenVnlReset(cOptions)
local lOkay := .f.
open area oVnl(VEN->Etat), oArt(), oGen()
  lOkay := .t.
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                   .and. FIELD->IdJnl == VEN->IdJnl
    if ! VnlReset(cOptions)
      lOkay := .f.
    endif
    skip
  enddo
close area
RETURN lOkay






#ifdef DEF_ACF

FUNCTION ArtAcfRef(cIdArt,cIdPar)
local cRef := ""
open area oAcf()
  ddSetOrder(ORD_ACF_ART)
  softseek cIdArt
  do while ! eof() .and. ACF->IdArt == cIdArt
    if ACF->IdPar == cIdPar
      cRef := trim(ACF->AcfRef)
      exit
    endif
    skip
  enddo
close area
RETURN cRef

#endif DEF_ACF


**
** VnlReset()
**
FUNCTION VnlReset(cOptions)
local lOkay
local cIdArt := left(FIELD->IdArt,LenIdArt())
RETURN .t. if FIELD->Code == LNCODE_REMARQ
RETURN .f. if ! ddRecLock()
if VNLRESET_PU $ cOptions
  if FIELD->Code == LNCODE_ART
    seek cIdArt in ART
    if ! empty(VnlIprPrix())
      VnlBefore()
      FIELD->PrixU := "" // Damit VnlPuDecPos() nicht die alte
                         // Nachkommastellenzahl nimmt
      #ifdef DEF_PRIXR
        // Ñhnlich wie VnlPrValidate()
        // FIELD->PrixR := ntom(VenDb2Dev(val(ART->PrixR)),VnlPuDecPos())
        FIELD->PrixR := ntom(VenDb2Dev(ArtPrixR(VEN->Periode)),VnlPuDecPos())
      #endif
        // Ñhnlich wie VnlPuValidate()
      FIELD->PrixU := VnlPrixArt()
      VnlSetBase()
      VnlAfter()
    endif
  endif
endif
#ifdef DEF_TAX
  if VNLRESET_TAX $ cOptions
    VnlBefore()
    VnlTaxReset() // saJnl[JNL_IDCTR])
    VnlAfter()
  endif
#endif
* lOkay := VnlPostEdit()
lOkay := VnlValidate()
unlock record
RETURN lOkay

#ifdef DEF_MVS

**
** VnlMvsCollect()
**
FUNCTION VnlMvsCollect(jnl,aMvs)
local nQte   := qton1(FIELD->Qte)
local nMont  := round(VenDev2Db(val(FIELD->cMont)),SetDecPos())
* local nMont  := round(val(FIELD->cMont) * snCours,SetDecPos())
local a := array(MVS_ALEN)
RETURN .t. if ARTATTR_S $ ART->Attrib
a[MVS_IDART] := left(FIELD->IdArt,LenIdArt())
a[MVS_QTE  ] := ntoq(qton1(FIELD->Qte),ART->QteForm)
a[MVS_LINE ] := FIELD->Line
if JNLATTR_V $ jnl[JNL_ATTRIB]
  a[MVS_MONT ] := ntom(nMont)
else
  a[MVS_MONT ] := ""
endif
a[MVS_DC   ] := VEN->DC
aadd(aMvs,a)
RETURN .t.

#endif DEF_MVS

#ifdef DEF_CTS

* 20030313
* FUNCTION VnlCtsUndo(jnl,aCts)
* local nAnz   := VnlAnzahl()
* local nQte   := qton1(FIELD->Qte)
* local nMont  := round(VenDev2Db(val(FIELD->cMont)),SetDecPos())
* if VEN->DC == jnl[JNL_DC]
*   nMont  := - nMont
*   nQte   := - nQte
*   nAnz   := - nAnz
* endif
* RETURN CtsCollect( ;
*   aCts,left(FIELD->IdArt,LenIdArt()),;
*   jnl, VEN->Periode, ;
*   nAnz, nQte, nMont, scIntra;
* )

**
**
FUNCTION VnlCtsCollect(jnl,aCts,cDC)
local nAnz   := VnlAnzahl()
local nQte   := qton1(FIELD->Qte)
local nMont  := round(VenDev2Db(val(FIELD->cMont)),SetDecPos())
#ifdef DEF_VENREMISE
  if !empty(VEN->Remise)
    nMont := round(nMont * (100-val(VEN->Remise)) / 100,SetDecPos())
  endif
#endif
if cDC != jnl[JNL_DC]
  nMont  := - nMont
  nQte   := - nQte
  nAnz   := - nAnz
endif
RETURN CtsCollect( ;
  aCts,left(FIELD->IdArt,LenIdArt()),;
  jnl, VEN->Periode, ;
  nAnz, nQte, nMont, scIntra ;
)

**
** CtsCollect()
**
FUNCTION CtsCollect( ;
 aCts, cIdArt, ;
 jnl, cPeriode, ;
 nAnz, nQte, nMont, cIntra ;
)
local i
local cts := NIL
for i := 1 to len(aCts)
  if aCts[i][CTS_IDJNL] == jnl[JNL_IDJNL]
    if aCts[i][CTS_PERIODE] == cPeriode
      if aCts[i][CTS_INTRA] == cIntra
        if aCts[i][CTS_IDART] == cIdArt
          cts := aCts[i]
        endif
      endif
    endif
  endif
next i
if cts == NIL
  cts := array(CTS_ALEN)
  cts[CTS_PERIODE] := cPeriode
  cts[CTS_INTRA]   := cIntra
  cts[CTS_IDJNL]   := jnl[JNL_IDJNL]
  cts[CTS_IDART]   := cIdArt
  cts[CTS_MONT]    := nMont
  cts[CTS_QTE]     := nQte
  cts[CTS_ANZ]     := nAnz
  cts[CTS_QTEFORM] := ART->QteForm
  aadd(aCts, cts)
else
  cts[CTS_MONT]  += nMont
  cts[CTS_QTE]   += nQte
  cts[CTS_ANZ]   += nAnz
endif
RETURN .t.

#endif DEF_CTS


#ifdef DEF_PRIXR

FUNCTION VnlPRValidate
local nPrixR
if empty(FIELD->PrixR) .and. IsArtCode(FIELD->Code)
  seek left(FIELD->IdArt,LenIdArt()) in ART
  // nPrixR := VenDb2Dev(val(ART->PrixR))
  nPrixR := VenDb2Dev(ArtPrixR(VEN->Periode))
  * nPrixR := val(ART->PrixR) / snCours
else
  nPrixR := val(FIELD->PrixR)
endif
FIELD->PrixR := ntom(nPrixR,VnlPuDecPos())
RETURN .t.
* RETURN VnlTotRefresh()

#endif DEF_PRIXR


#ifdef DEF_PROVI

FUNCTION VnlPlValidate()
FIELD->PrixPL := FIELD->PrixL
ddMustScan(.t.)
RETURN .t.

#endif DEF_PROVI

FUNCTION VnlPuDecPos
local nDecPos := max(saDev[DEV_DECPOS],MntDecPos(trim(FIELD->PrixU)))
#ifdef DEF_ART
  nDecPos := max(nDecPos,ArtPuDecPos())
#endif
RETURN nDecPos

FUNCTION VnlVenPrint()
RETURN .f. if ! VenVnlUpdate(saJnl)
RETURN VenDoPrint(saJnl)

FUNCTION VnlRefExist() // cCode,cIdArt)
RETURN .t. if FIELD->Code == LNCODE_REMARQ
#ifdef DEF_GEN
  RETURN GenExist( left(FIELD->IdArt,LenIdGen()) ) if FIELD->Code == LNCODE_GEN
#endif DEF_GEN
#ifdef DEF_NEWS
  if FIELD->Code == LNCODE_NEWS
    RETURN NewExist(left(FIELD->IdArt,LenIdArt()))
  endif
#endif DEF_GEN
#ifdef DEF_ART
  RETURN ArtExist(left(FIELD->IdArt,LenIdArt())) if IsArtCode(FIELD->Code)
  RETURN ArtExist(left(FIELD->IdArt,LenIdArt())) if FIELD->Code == LNCODE_TOTAL
  RETURN ArtExist(left(FIELD->IdArt,LenIdArt())) if FIELD->Code == LNCODE_MODULE
#endif DEF_ART
RETURN .f.

FUNCTION VnlIsVar() ; RETURN slIsVariante

FUNCTION VnlVarCollect
if FIELD->Code == LNCODE_VARIANTE
  RETURN .f. if ! OnVnlVarCollect()
  slIsVariante := .t.
  slLastVarLine := .f.
  RETURN .t.
endif
if FIELD->Code == LNCODE_TOTAL
  slLastVarLine := .t.
elseif slLastVarLine
  slLastVarLine := .f.
  slIsVariante := .f.
else
  slLastVarLine := .f.
endif
RETURN .t.

FUNCTION VnlPreDelete()
if USRATTR_E $ UsrAttrib()
  RETURN ConfirmDelete() if ! JnlExist(VNL->IdJnl)
endif
RETURN .f. if indexord() != 1
RETURN .f. if ! VenIsOpen()
RETURN .f. if ! PreVnlDelete()
if FIELD->Code == LNCODE_VARIANTE
  RETURN .f. if ! VnlVarDelete()
endif
RETURN .t.

**
** Sonderfall : wenn man den ersten Record einer Variante lîscht,
** werden alle Records dieser Varinate gelîscht.
**
FUNCTION VnlVarDelete()
local aRecNo := {}
local nRecNo := recno()
local cIdJnl := FIELD->IdJnl
local cIdDoc := FIELD->IdDoc
local i
local lOkay := .t.
skip
do while ! eof() .and. FIELD->IdDoc==cIdDoc .and. FIELD->IdJnl==cIdJnl
  if FIELD->Code == LNCODE_VARIANTE
    exit
  endif
  aadd(aRecNo, recno())
  if FIELD->Code == LNCODE_TOTAL
    exit
  endif
  skip
enddo
goto nRecNo
RETURN .t. if len(aRecNo) == 0
RETURN .f. if ! Confirm( ;
  MsgVarDelete(len(aRecNo)+1), MsgSure(), MSG_NO, ;
)
for i := 1 to len(aRecNo)
  goto aRecNo[i]
  if ddRecLock()
    VnlBefore()
    delete
    unlock record
  else
    lOkay := .f.
  endif
next i
goto nRecNo
ddSendKey(K_ALT_F5)
RETURN lOkay


FUNCTION MsgVarDelete(nCount)
#ifdef LG_FRENCH
RETURN "Le contenu de la variante (" + ;
  ntrim(nCount) + " lignes) sera supprimÇ !"
#else
RETURN "Der gesamte Inhalt der Variante (" + ;
  ntrim(nCount) + " Zeilen) wird gelîscht !"
#endif

FUNCTION VnlPreEdit()
RETURN .f. if indexord() != 1
RETURN .f. if ! VenIsOpen()
scOldValue := VnlValue()
RETURN .t.

FUNCTION VnlValue()
// scOldValue := FIELD->cMont + FIELD->MontT
local c := FIELD->cMont
#ifdef DEF_TAX
  c += FIELD->MontT
#endif
#ifdef DEF_PRIXR
  c += FIELD->PrixR
#endif
RETURN c


**
** VenVnlScan()
** Erweitert ddScan() im Dialogfenster Inhalt, so dass im
** blAction mit VnlIsVar() gearbeitet werden kann.
** Wird benutzt Åber die VNL.DEF :
** ddSumScan( { |blAction,xlFilter| VenVnlScan(blAction,xlFilter) } )
** oder besser (damit auch in der VNLART.ARY Summen erscheinen):
** ddSumScan( { |blAction,xlFilter| iif(indexord()==1,\
**               VenVnlScan(blAction,xlFilter),ddScan(blAction,xlFilter)} } )
**
FUNCTION VenVnlScan(blAction)
local lOkay:= .f.
local nRecNo := recno()
local lIsVariante := slIsVariante
local lLastVarLine := slLastVarLine
slIsVariante  := .f.
slLastVarLine := .f.
* RETURN .f. if ! VenVnlInit(jnl)
// raus am 20041021 RETURN ddScan(blAction) if indexord() != 1 // z.B. bei ArtVnlEdit()
// wieder rein am 20051215 weil sonst in VNLART.QRY keine Summen kommen
// RETURN ddScan(blAction) if indexord() == ORD_VNL_ART
// RETURN ddScan(blAction) if left(indexkey(),25)!="FIELD->IdJnl+FIELD->IdDoc"
// 20060208 : wieder raus, weil VnlVnlScan() bei AGV in TOTAL.INC
// aufgerufen wird, um die Mengen eines VKL zu ermitteln, und da ist VNL
// anfangs gar nicht aktiv. Damit VNLART.QRY Summen anzeigt, muss eben
// immer in der
open area oVnl(VEN->Etat), oGen(), oArt(), oVna(), oDls()
  lOkay := .t.
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                   .and. FIELD->IdJnl == VEN->IdJnl
    if ! VnlVarCollect()
      lOkay := .f.
      exit
    endif
    if ! eval(blAction)
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
goto nRecNo
slIsVariante := lIsVariante
slLastVarLine := lLastVarLine
RETURN lOkay

FUNCTION VenVnlFind(xlFilter)
local lOkay:= .f.
open area oVnl(VEN->Etat), oGen(), oArt(), oVna(), oDls()
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                   .and. FIELD->IdJnl == VEN->IdJnl
    if &(xlFilter)
      lOkay := .t.
      exit
    endif
    skip
  enddo
close area
RETURN lOkay


#else

FUNCTION VnlDummy ; RETURN NIL

#endif DEF_VEN


#ifdef DEF_SER

*FUNCTION SerInit(cIdJnl,cIdDoc,cLine,nMont,nQte)
*if cIdJnl == NIL
*  snSerMust := 0
*  snSerSum  := 0
*  snSerQteMust  := 0
*  snSerQteSum   := 0
*  RETURN NIL
*endif
*snSerMust := nMont
*snSerSum  := 0
*snSerQteMust  := nQte
*snSerQteSum   := 0
*open area oSer()
*  ddSetOrder(ORD_SER_DOC)
*  if cLine == NIL
*    softseek cIdJnl + cIdDoc
*    do while ! eof() .and. SER->IdJnl == cIdJnl ;
*                     .and. SER->IdDoc == cIdDoc
*      snSerSum += val(SER->Mont)
*      snSerQteSum += 1
*      skip
*    enddo
*  else
*    softseek cIdJnl + cIdDoc + cLine
*    do while SER->IdJnl == cIdJnl .and. SER->IdDoc == cIdDoc ;
*                                  .and. SER->Line  == cLine ;
*                                  .and. ! eof()
*      snSerSum    += val(SER->Mont)
*      snSerQteSum += 1
*      skip
*    enddo
*  endif
*close area
*RETURN NIL
*
*FUNCTION SerBefore
*snSerSum    -= val(SER->Mont)
*snSerQteSum -= 1
*RETURN NIL
*
*FUNCTION SerAfter
*snSerSum    += val(SER->Mont)
*snSerQteSum += 1
*RETURN NIL
*
*FUNCTION SerMust
*RETURN space(LenMont()) if snSerQteMust - snSerQteSum == 0
*RETURN ntom( (snSerMust-snSerSum) / (snSerQteMust - snSerQteSum) )
*

FUNCTION SerPostEdit
RETURN .f. if ! ArtExist(SER->IdArt)
* if empty(SER->Mont)
*   SER->Mont := SerMust()
* endif
RETURN .t.

FUNCTION VnlSerValidate()
local cPrixU
RETURN .t. if empty(FIELD->IdSer)
open area oSer()
  seek FIELD->IdSer
  if eof()
    if Confirm(FIELD->IdSer + " : neue Seriennummer erstellen (J/N) ?")
      if dbAddRec()
        SER->IdArt := FIELD->IdArt
        SER->IdSer := FIELD->IdSer
        unlock record
      endif
    endif
  else
    seek SER->IdArt in ART
    FIELD->IdArt := SER->IdArt
    FIELD->Code  := LNCODE_ART
    cPrixU := ntom(VnlIprPrix(),VnlPuDecPos())
    if ! empty(cPrixU)
      if saDev[DEV_IDDEV] == DevDefault(PerActive())
        FIELD->PrixU := cPrixU
      else
        FIELD->PrixU := ntom(VenDb2Dev(val(cPrixU)), VnlPuDecPos())
        * FIELD->PrixU := ntom(val(cPrixU) / snCours, VnlPuDecPos())
      endif
      VnlSetBase()
    endif
  endif
close area
RETURN .t.

FUNCTION VnlSerUpdate()
RETURN NIL if empty(FIELD->IdSer)
RETURN NIL if empty(FIELD->PrixU)
open area oSer()
  seek FIELD->IdSer
  if eof()
    Warning(FIELD->IdSer + " : Seriennummer existiert nicht !")
  else
    SetMsg("VnlSerUpdate() ist nicht fertig !")
  * elseif ddRecLock()
  *   if saDev[DEV_IDDEV] == DevDefault()
  *     &("SER->" + saPgp[PGP_PRIX]) := FIELD->PrixU
  *   else
  *     &("SER->"+saPgp[PGP_PRIX]) := ntom(val(FIELD->PrixU) * snCours, VnlPuDecPos())
  *   endif
  *   unlock record
  endif
close area
RETURN NIL

#endif DEF_SER

#ifdef DEF_PROVI

**
** VnlBonus() wird einzig bei HK benutzt
**
FUNCTION VnlBonus(nModRab)
local n
local nMaxRab
local pga := PgaLocate(FIELD->IdPga)
local nPrixPL
local nMinPrix
local nPrix
local nBonus := 0
local nVerlust1
local nVerlust2
local nTaux := TaxTaux("V",FIELD->IdTax)
RETURN 0 if pga == NIL
nMaxRab := val(pga[PGA_NAME]) + nModRab
nPrixPL := VenDev2Db(val(FIELD->PrixPL) * qton1(FIELD->Qte))
* nPrixPL := val(FIELD->PrixPL) * qton1(FIELD->Qte) * val(VEN->Cours)
nMinPrix := nPrixPL - (nPrixPL * nMaxRab / 100)
nPrix := VenDev2Db(val(FIELD->PrixPU) * qton1(FIELD->Qte))
* nPrix := val(FIELD->PrixPU) * qton1(FIELD->Qte) * val(VEN->Cours)
nPrixPL  := netto(nPrixPL ,nTaux)
nMinPrix := netto(nMinPrix,nTaux)
nPrix    := netto(nPrix   ,nTaux)
if nPrix > nMinPrix
  nBonus += (nPrix-nMinPrix) * 0.2
  if nPrix > nPrixPL // wow! sogar Åber Preis verkauft
    nBonus += (nPrix-nPrixPL) * 0.3
  endif
elseif nPrix < nMinPrix
  if nMaxRab == 0
    // PGA "Z" hei·t : jede Mark unter nPrixPL wird voll vom Bonus
    // abgezogen
    nBonus -= (nPrixPL - nPrix)
  else
    * Die ersten 10% unterm Mindestpreis werden mit 20% vom Bonus
    * abgezogen. Jede weitere Mark mit 50%.
    // nVerlust := nMinPrix - nPrix
    // z.B. : nPrixPL = 1000 (PG = X)
    //        nMinPrix = 1000 - X% = 900
    //        nPrix = 800
    // nVerlust1 = (nMinPrix - (nMinPrix * 0.9)) = 90
    // nVerlust2 = (nMinPrix * 0.9) - nPrix = 10
    * nVerlust1 := (nMinPrix - (nMinPrix * 0.9))
    * nVerlust2 := (nMinPrix * 0.9) - nPrix
    nVerlust1 := min( (nMinPrix * 0.1), (nMinPrix - nPrix))
    nVerlust2 := (nMinPrix - nPrix) - nVerlust1
    nBonus -= (nVerlust1) * 0.2
    nBonus -= (nVerlust2) * 0.5
  endif
endif
RETURN nBonus

#endif DEF_PROVI

#ifdef DEF_TAX

FUNCTION GsbVnlTaxe(x)
local tax 
if x == NIL
  RETURN FIELD->MontT if ! (eof().or.bof()) // 20071106, 20070801
  RETURN space(LenMont()) if slIsTotal
  RETURN nToTax(snSumTaxe)
endif
RETURN NIL if (tax := TaxLocate(saJnl[JNL_IDCTR],FIELD->IdTax,.t.,VEN->Date)) == NIL
if empty(x)
  FIELD->MontT := ntoTax(val(FIELD->cMont) * tax[TAX_TAUX] / 100)
else
  * FIELD->MontT := GetNum(x)
  FIELD->MontT := ntoTax(mton(x))
endif
*elseif TAXATTR_T $ tax[TAX_ATTRIB]
*  FIELD->MontT := GetNum(x)
*elseif VenDev2Db(abs(val(cMontT) - val(x))) <= TOL_TVA
** elseif snCours * abs(val(cMontT) - val(x)) <= TOL_TVA
*  FIELD->MontT := GetNum(x)
*else
*  Warning(trim(x) + MSG_WRN050,NIL,"WRN050")
*endif
RETURN NIL


FUNCTION MsgGenIdTax
#ifdef LG_GERMAN
  RETURN " : Konto nicht erlaubt mit MWSt.-Code "
#else
  RETURN " : compte gÇnÇral interdit avec code T.V.A. "
#endif

FUNCTION VnlTaxValidate
RETURN .t. if FIELD->Code == LNCODE_REMARQ
RETURN .f. if ! VnlFirstCheck(saJnl[JNL_IDCTR])
if empty(FIELD->IdTax)
  VnlSetIdTax()
endif
RETURN .f. if ! VnlSetTaxe()
RETURN .f. if ! VnlTaxCheck()
RETURN .T.


FUNCTION VnlTaxReset()
FIELD->IdTax := "" // sonst gibt IpbLocate() .f. zurÅck, wenn man ein
                 // Dokument mit IM-Codes auf MWSt-Regime A gesetzt
                 // hatte und VenRegValidate() ausgefÅhrt wird.
RETURN .t. if FIELD->Code == LNCODE_REMARQ
RETURN .f. if ! VnlFirstCheck(saJnl[JNL_IDCTR])
VnlSetIdTax()
RETURN .f. if ! VnlSetTaxe()
RETURN VnlTaxCheck()

**
** VnlTaxCheck()
** - read-only
**
FUNCTION VnlTaxCheck()
local tax
local cMontT
local nBase
* if empty(FIELD->IdTax)
*   VnlSetIdTax()
* endif
#ifdef DEF_GEN
  if GENATTR_F $ GEN->Attrib
    if GEN->IdTax != FIELD->IdTax
      SetMsg(GEN->IdGen + MsgGenIdTax() + FIELD->IdTax)
      RETURN .f.
    endif
  endif
#endif DEF_GEN
tax := TaxLocate(saJnl[JNL_IDCTR],FIELD->IdTax,.t.,VEN->Date)
RETURN .f. if tax == NIL
cMontT := ntoTax(val(FIELD->cMont) * tax[TAX_TAUX] / 100)
if cMontT != FIELD->MontT
  if !TAXATTR_T $ tax[TAX_ATTRIB]
    nBase := abs(val(VNL->cMont))
    if nBase > Tolerance(snTaxDecPos)
      if abs(abs(val(cMontT)) - abs(val(VNL->MontT))) * 100 / nBase > TOL_TVA // mehr als 5%
        if ! TolerateTax()
          RETURN !SetMsg(trim(FIELD->MontT) + MSG_WRN050)
        endif
      endif
    endif
  endif
endif
RETURN .t. if ! JnlDoHst(saJnl,VEN->Periode) // JNLATTR_G $ saJnl[JNL_ATTRIB]
if ! empty(tax[TAX_REGLIST])
  if ! VEN->IdReg $ tax[TAX_REGLIST]
    #ifdef LG_GERMAN
      SetMsg( ;
        "MWSt-Code " + trim(FIELD->IdTax) + ;
        " nicht erlaubt mit MWSt-Regime " + VEN->IdReg ;
      )
    #else
      SetMsg( ;
        "Code TVA " + trim(FIELD->IdTax) + ;
        " non permis dans le rÇgime " + VEN->IdReg ;
      )
    #endif
    RETURN .f.
  endif
endif
RETURN .t. if empty(tax[TAX_VALID])
RETURN xparse(tax[TAX_VALID])

**
** VnlSetIdTax()
** - saIpb must be initialized ( =VnlFirstCheck() must be called before )
FUNCTION VnlSetIdTax()
if empty(saReg[REG_IDTAX])
  * seit 20060818:
  #ifdef DEF_GEN
    if saIpb == NIL
      FIELD->IdTax := GEN->IdTax
    elseif empty(saIpb[IPB_IDTAX])
      FIELD->IdTax := GEN->IdTax
    else
      FIELD->IdTax := saIpb[IPB_IDTAX]
    endif
  #else
    FIELD->IdTax := saIpb[IPB_IDTAX]
  #endif DEF_GEN
  * vor 20060818:
  *#ifdef DEF_GEN
  *  if empty(GEN->IdTax) .and. saIpb != NIL
  *    FIELD->IdTax := saIpb[IPB_IDTAX]
  *  else
  *    FIELD->IdTax := GEN->IdTax
  *  endif
  *#else
  *  FIELD->IdTax := saIpb[IPB_IDTAX]
  *#endif DEF_GEN
  * eob 20060818
elseif trim(saReg[REG_IDTAX]) == "!"
  FIELD->IdTax := ActExec("VNLIDTAX")
else
  FIELD->IdTax := saReg[REG_IDTAX]
endif
RETURN NIL

FUNCTION VnlPickTax()
RETURN PickTax(FIELD->IdTax,saJnl[JNL_IDCTR],VEN->Date)

FUNCTION VnlSetTaxe
local tax
RETURN .f. if (tax := TaxLocate(saJnl[JNL_IDCTR],FIELD->IdTax,.t.,VEN->Date)) == NIL
FIELD->MontT := ntoTax( val(FIELD->cMont) * tax[TAX_TAUX] / 100)
RETURN .T.

#endif DEF_TAX


#ifdef DEF_MEMOR

FUNCTION VnlMemorImport(cWildCard,cMemorId,nArtOrder)
local aDir := directory(cWildCard)
local lOkay := .f.
local i
local fd
local cPath := left(cWildCard,rat("\",cWildCard))
local cLine
local cIdArt
if empty(cMemorId)
  Warning("UngÅltiges Memor-ID !")
  RETURN .f.
endif
default nArtOrder to 1
do while .t.
  for i := 1 to len(aDir)
    if (fd := mopen(cPath + aDir[i][F_NAME])) != NIL
      if left(fd,len(cMemorId)) == cMemorId
        lOkay := .t.
        do while (cLine := mreadline(fd)) != NIL
          if ! empty(cLine)
            cIdArt := DbfPeek( ;
              oArt(), ;
              substr(cLine,7,13), ;
              "ART->IdArt", ;
              NIL, ;
              nArtOrder ;
            )
            if cIdArt == NIL
              Warning(substr(cLine,7,13) + " : unbekannter EAN-Code !")
              lOkay := .f.
            else
              goto lastrec() + 1
              if VnlCreate(VEN->IdJnl,VEN->IdDoc) != DDCREATE_FAIL
                FIELD->Code  := LNCODE_ART
                FIELD->IdArt := cIdArt
                FIELD->Qte   := padl(trim(substr(cLine,20,4)),LenQte())
                VnlIdValidate()
                VnlValidate()
                * VnlPostEdit()
                unlock record
              else
                Warning(SetMsg())
              endif
            endif
          endif
        enddo
        mclose(fd)
        if lOkay .or. Confirm( ;
          "Die Daten konnten nicht komplett Åbernommen werden.",;
          "Zwischendatei trotzdem lîschen (J/N) ?" ;
        )
          delete file (cPath + aDir[i][F_NAME])
        endif
        RETURN .t.
      else
        mclose(fd)
      endif
    endif
  next i
  if ! Confirm("Keine Dateien zum Einlesen gefunden !",MsgRetry())
    SetMsg("Dann eben nicht...")
    RETURN .f.
  endif
enddo
RETURN NIL // never reached

#endif DEF_MEMOR

#ifdef DEF_MEMOR

FUNCTION BarCode39(cText)
local cCode := ""
local n3 := int(snBarHeight / 10)    // Zehner
local n4 := snBarHeight % 10         // Einer
cCode := chr(27) + chr(16) + chr(65)
cCode += chr(8)
cCode += chr(2) + chr(0)             // Code 39
cCode += chr(n3) + chr(n4)
cCode += chr(snBlackWidth) + chr(snSpaceWidth)             //
cCode += chr(0) + chr(2)             //
cCode += chr(27) + chr(16) + chr(66)
cCode += chr(len(cText)+1)
cCode += cText + "@"
RETURN cCode


FUNCTION BarEAN13(cText)
local cCode := ""
local n3 := int(snBarHeight / 10)    // Zehner
local n4 := snBarHeight % 10         // Einer
cCode := chr(27) + chr(16) + chr(65) // Auswahl Barcode
cCode += chr(8)
cCode += chr(0) + chr(2)             // EAN 13
cCode += chr(n3) + chr(n4)
cCode += chr(0) + chr(0)             //
cCode += chr(0) + chr(2)             //
cCode += chr(27) + chr(16) + chr(66)
cCode += chr(13) // len(cText) )
cCode += padr(cText,12,"0") + "@"
RETURN cCode

* FUNCTION BarEAN8(cText) // ohne PrÅfziffer
* local cCode := ""
* local n3 := int(snBarHeight / 10)    // Zehner
* local n4 := snBarHeight % 10         // Einer
* cCode := chr(27) + chr(16) + chr(65) // Auswahl Barcode
* cCode += chr(8)
* cCode += chr(0) + chr(1)             // EAN 8
* cCode += chr(n3) + chr(n4)
* cCode += chr(0) + chr(0)             //
* cCode += chr(0) + chr(2)             //
* cCode += chr(27) + chr(16) + chr(66)
* cCode += chr(8) // len(cText) )
* cCode += padr(cText,8,"0") // + "@"
* RETURN cCode

FUNCTION Bar2auf5(cText)
local cCode := ""
local n3 := int(snBarHeight / 10)    // Zehner
local n4 := snBarHeight % 10         // Einer
cCode := chr(27) + chr(16) + chr(65) // Auswahl Barcode
cCode += chr(8)
cCode += chr(3) + chr(0)             // Interleaved 2/5
cCode += chr(n3) + chr(n4)
cCode += chr(1) + chr(1)             //
cCode += chr(0) + chr(2)             //
cCode += chr(27) + chr(16) + chr(66)
cCode += chr( len(cText) )
cCode += cText // + "@"
/*****
Ist die Anzahl der Druckdaten fÅr Interleaved 2/5 ungerade, wird 0 als
erstes Zeichen des Barcodes hinzugefÅgt.
*******/
RETURN cCode

#endif DEF_MEMOR


#ifdef DEF_MULT

FUNCTION VnlMultValidate()
* local nPrixU := val(FIELD->PrixU)
RETURN .t. if ! VnlSetBase()
* if ! empty(FIELD->Mult)
*   nPrixU := round(nPrixU * val(FIELD->Mult),VnlPuDecPos())
* endif
* if abs( ;
*      abs(nPrixU * qton1(FIELD->Qte)) - ;
*      abs(val(FIELD->cMont)) ;
*    ) > (10 ** VnlPuDecPos())
*   OnVnlRoundError()
* endif
* RETURN .t. if ! VnlTotRefresh()
RETURN .t.

#endif DEF_MULT

#ifdef DEF_IMP

FUNCTION ImpDb2Dev(nMont)
RETURN nMont if IMP->IdDev == DevDefault(IMP->Periode)
RETURN Db2Dev(IMP->IdDev,IMP->Periode,nMont) if empty(IMP->Cours)
RETURN nMont / val(IMP->Cours)

FUNCTION ImpDev2Db(nMont)
RETURN nMont if IMP->IdDev == DevDefault(IMP->Periode)
RETURN Dev2Db(IMP->IdDev,IMP->Periode,nMont) if empty(IMP->Cours)
RETURN nMont * val(IMP->Cours)


#endif DEF_IMP

#ifdef DEF_CTT

FUNCTION CttPrint(cTitle)
local uSaveDevise := SetDevise()
local nBase
local nTaxe
local nTotBase := 0
local nTotTaxe := 0
local cLine
local nPad
local cTitle2
local cTit1
default cTitle to "CttPrint()"
SetTplIni("LISTE")
open window (cTitle) size 7,60 help CTTPRINT
GetPreview() ; WinCr()
GetTplIni()
GetRange()
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
cTit1 := padl("IdDoc",LenIdJnl()+LenIdDoc()+1+4)
* cTit1 += " " + padl("IdArt",LenIdObj())
cTit1 += " D/C"
nPad := len(cTit1)
cTit1 += " " + padl("VEN->Mont",LenMont())
cTit1 += " " + padl("VEN->IdDev",3)
cTit1 += " " + padl("Base",LenMntF())
cTit1 += " " + padl("Taxe",LenMntF())

cTitle2 := CTT->DC
cTitle2 += " " + CTT->Periode
cTitle2 += " " + CTT->IdCtf
cTitle2 += " " + ltrim(CTT->Base)
cTitle2 += " " + ltrim(CTT->Taxe)
open printer SetTplIni() width len(cTit1) ;
     preview SetPreview() ;
     range   SetRange() ;
     titblock {|| ;
       PrintHeader( cTitle, cTitle2 ), ;
       PrintLine(cTit1), ;
       PrintLine("")  ;
     }
open area oVnl(), oVen(), oGen(), oArt(), oPar(), oPlz()
  softseek CTT->IdJnl
  do while ! eof() .and. VNL->IdJnl == CTT->IdJnl
    if VnlCttFilter()
      nBase := VenDev2Db(val(VNL->cMont))
      nTaxe := VenDev2Db(val(VNL->MontT))
      cLine := MsgIdJnlDoc()
      cLine += " " + VNL->Line
      cLine += "  " + VEN->DC + " "
      cLine += " " + VEN->Mont
      cLine += " " + VEN->IdDev
      cLine += " " + ntom(nBase)
      cLine += " " + ntom(nTaxe)
      nBase += nBase
      nTaxe += nTaxe
      PrintLine(cLine)
    endif
    skip
  enddo
close area
PrintLine()
PrintLine(space(nPad)+" "+ntom(nTotBase)+" "+ntom(nTotTaxe))
PrintLine(space(nPad)+" "+CTT->Base+" "+CTT->Taxe)
close printer
SetDevise(uSaveDevise)
RETURN .t.

FUNCTION VnlCttFilter()
local jnl
RETURN .f. if VNL->IdTax != CTT->IdTax
RETURN .f. if VNL->IdJnl != CTT->IdJnl
jnl := JnlLocate(VNL->IdJnl)
seek VNL->IdJnl+VNL->IdDoc in VEN
RETURN .f. if VEN->Periode != CTT->Periode
RETURN .f. if ! VnlFirstCheck(jnl[JNL_IDCTR])
#ifdef DEF_GEN
  RETURN (GEN->IdClj == CTT->IdCtf)
#endif DEF_GEN
RETURN .t.

#endif DEF_CTT

#ifdef DEF_JNL

FUNCTION JnlDoHst(jnl,cPeriode)
if cPeriode != NIL .and. HstStart() != NIL .and. cPeriode < HstStart()
  RETURN .f.
endif
RETURN JNLATTR_G $ jnl[JNL_ATTRIB]

#endif DEF_JNL

#ifdef DEF_VEN

FUNCTION VnlPrest
local nQte := 0
local cMemo := ""
local cSel
local b1
local b2
local cFilename := "VNLPREST.DBC"
// RETURN .f. if !empty(VNL->Memo)
cSel := PickDbcAttr(cFilename,"",trim(ArtName())," ")
RETURN .f. if cSel == NIL
b1 := {|x|cMemo+=trim(LngText(x[2],x[3],x[4]))+". ",nQte+=qton(x[5]),.t.}
b2 := {|x|!x[1]$cSel.or.eval(b1,x)}
RETURN .f. if !DbcLoop(cFilename,b2)
if len(cMemo) > len(VNL->Desig)
  VNL->Memo := cMemo
else
  VNL->Desig := cMemo
endif
VNL->Qte := ntoq(nQte,ART->QteForm)
RETURN VnlSetBase()

#endif DEF_VEN
