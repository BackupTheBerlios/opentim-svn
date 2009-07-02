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

* #define RPR_IDTAC  1
* #define RPR_QTE    2
* #define RPR_PREST  3
* #define RPR_DEPL   4
* #define RPR_AUTRES 5

* #define RAP_IDDGR  1
* #define RAP_OUVERT 2
* #define RAP_FRAIS  3

#ifdef LG_FRENCH
  #define MSG002  "Rapport de prestation"
  #define MSG003  " : analyse des paiements..."
  #define MSG004  " : rien … imprimer"
  * #define MSG005  "S‚lection masque pour lettre de rappel"
  #define MSG006  "S‚lection mailing"
  #define MSG009  "~Statistique achat/vente  "
  #define MSG010  "Liste ~g‚n‚rique          "
  #define MSG011  "R‚capitulatif ~inventaires"
  #define MSG012  "~Mailing                  "
  #define MSG013  "Rapports de ~prestations  "
  #define MSG014  "R‚capitulatif pre~stations"
  #define MSG015  "~Rappels de paiement      "
  #define MSG016  "Clients : Imprimer liste"
  #define MSG019  "R‚capitulatif ‚ch‚~ances  "
  #define MSG027  " : masque de document non trouv‚ !"
  #define MSG028  "Fournisseurs : Imprimer liste"
  #define MSG029  "Codes postaux : liste"
  #define MSG060  "~Etiquette             "
  #define MSG061  "~Mailing               "
  #define MSG062  "Rapport de ~prestations"
  #define MSG063  "~Factures ‚chues       "
  #define MSG064  "~Historique du compte  "
  #define MSG065  "Imprimer Client"
  #define MSG066  "R‚capitulatif prestations"
  #define MSG067  "R‚capitulatif rappels"
  #define MSG068  " imprimer document(s) de rappel"
  #define MSG069  "Masque "
  #define MSG070  " mentionner les frais de prestation"
  #define MSG071  " mentionner frais de d‚placement et autres"
  #define MSG072  " mentionner les commentaires"
  #define MSG073  "Uniquement les rendez-vous … l'‚tat "
  #define MSG074  " d‚tail de chaque rendez-vous"
  #define MSG075  " r‚capitulatif par client"
  #define MSG076  " seulement pour "
  * #define MSG077  "~Proposition paiements "
  #define MSG078  "Imprimer Fournisseur"
  * #define MSG100 "InsŠre bloc de texte"
  * #define MSG101 "Nom 1 (+ allocution)"
  * #define MSG102 "Nom 2"
  * #define MSG109 NIL
  * #define MSG110 "Localit‚ & code postal"
  * #define MSG111 "M‚mo client (fournisseur)"
  * #define MSG112 "M‚mo document"
  #define MSG113  "~Statistique              "
  static MSG114 := "Liste d‚taill‚e des rues (O/N) ?"
  static MSG_PARPRINT := "Partner drucken"
  static MSG_GENPRINT := "Generalkonto drucken"
#else
  #define MSG002  "Dienstleistungsbericht"
  #define MSG003  " : Zahlungen durchsuchen..."
  #define MSG004  " : nichts zu drucken"
  * #define MSG005  "Auswahl Dokumentmaske fr Mahnbrief"
  #define MSG006  "Auswahl Serienbrief"
  * #define MSG008  "Zusammenfassung"
  #define MSG009  "~Statistik Einkauf/Verkauf  "
  #define MSG010  "~Bildschirmliste            "
  #define MSG011  "šbersicht ~Inventuren       "
  #define MSG012  "~Serienbrief                "
  #define MSG013  "~Dienstleistungsberichte    "
  #define MSG014  "šbersicht D~ienstleistungen "
  #define MSG015  "~Mahnbriefe                 "
  #define MSG016  "Kunden : Liste drucken"
  #define MSG019  "šbersicht ~offene Rechnungen"
  #define MSG027  " : Dokumentmaske nicht gefunden !"
  #define MSG028  "Lieferanten : Liste drucken"
  #define MSG029  "Postleitzahlen : Liste"
  #define MSG060  "~Einzel-Etikett            "
  #define MSG061  "~Serienbrief               "
  #define MSG062  "~Dienstleistungsbericht    "
  #define MSG063  "O~ffene Rechnungen         "
  #define MSG064  "~Historik Kontenbewegungen "
  #define MSG065  "Kunde : drucken"
  #define MSG066  "šbersicht Dienstleistungen"
  #define MSG067  "šbersicht Mahnbriefe"
  #define MSG068  " Mahnung(en) drucken"
  #define MSG069  "Maske "
  #define MSG070  " Dienstleistungskosten angeben"
  #define MSG071  " Fahrt- und Sonstige Kosten angeben"
  #define MSG072  " Kommentare angeben"
  #define MSG073  "Nur Termine mit Status "
  #define MSG074  " detaillierte Liste der Termine"
  #define MSG075  " Zusammenfassung pro Kunde"
  #define MSG076  " nur fr "
  * #define MSG077  "~Offene Rechnungen         "
  #define MSG078  "Lieferant : drucken"
  * #define MSG100 "Textblock einfgen"
  * #define MSG101 "Name 1 mit Anrede"
  * #define MSG102 "Name 2"
  * #define MSG109 "Straáe"
  * #define MSG110 "Postleitzahl und Ort"
  * #define MSG111 "Memo-Feld (Kunde/Lieferant)"
  * #define MSG112 "Memo-Feld (Dokument)"
  #define MSG113  "~Statistik                  "
  static MSG114 := "Straáennamen ebenfalls drucken (J/N) ?"
  static MSG_PARPRINT := "Partner drucken"
  static MSG_GENPRINT := "Generalkonto drucken"
#endif

#ifdef DEF_HOLZ
  static snCurrentCls := 0
  static saCls        := {}
  static scPrjStmText := ""
#endif DEF_HOLZ

#ifdef DEF_TRA
  static saTrl := {}
  static snTrlIndex := 0
#endif DEF_TRA

static snParDebit  := 0
static snParCredit := 0
static sdRapDate   := NIL

#ifdef DEF_GEN
  static snGenDebit  := 0
  static snGenCredit := 0
#endif DEF_GEN

  static saTrmSum  := {}
  static snTrmSumItem := 0

#ifdef DEF_PRESTO
  static sdTrmDate := NIL
  * static scTrmFilter := ".t."
  static sdTrmDate1
  static sdTrmDate2
#endif


* static scIdGra    := NIL
* static snMarge    := 0
static saMvt := {}
* static saMva := {}

#ifdef DEF_VEN
  static snVnlNum := 1
  static slIsTitle := .t.
#endif DEF_VEN

#ifdef DEF_CTS

static snCtsMont  := 0
* static snCtsMontR := 0
static snCtsQte   := 0

#endif DEF_CTS

#ifdef DEF_CTP

static snCtpUmsatz  := 0
static snCtpDebit   := 0
static snCtpCredit  := 0

#endif DEF_CTP

**
** TxtRead()
**
*FUNCTION TxtRead( cType, cIdTxt, cLangue, lWarn, nWidth, cIdOpt )
*local cReturn := ""
*cIdTxt := padr(cIdTxt,LenIdTpl())
*default lWarn to .t.
*open area oTxt()
*seek cType + cIdTxt + cLangue
*if found()
*  cReturn := TXT->Texte
*else
*  seek cType + cIdTxt + MemLang1
*  if found()
*    cReturn := TXT->Texte
*  else
*    if lWarn
*      Warning("Textblock " + cType + " " + cIdTxt + "-" + cLangue + ;
*      MsgNotFound() )
*    endif
*  endif
*endif
*if nWidth != NIL
*  nWidth := TXT->Largeur
*endif
*if cIdOpt != NIL
*  cIdOpt := trim(TXT->IdOpt)
*endif
*close area
*RETURN hardcr(cReturn)


**
** PlzString()
**
FUNCTION PlzString(cPays,cCP,cZipCode)
local cLoc := ""
RETURN trim(NatName(cPays)) if empty(cCP)
#ifndef DEF_WWW
if cPays != MemPays
  cLoc += trim1(nat2iso(cPays)," - ")
endif
#endif DEF_WWW
default cZipCode to left(cCp,7)
cLoc += trim1(cZipCode) + PlzName(cPays,cCp)
RETURN trim(cLoc)


#ifdef DEF_VEN

FUNCTION VenPrint(cIdTpl,cPreview)
local jnl := JnlLocate(VEN->IdJnl)
RETURN .f. if ! ddRecLock()
  VenDoPrint(jnl,cIdTpl,cPreview)
  * if ! VenDoPrint(jnl,cIdTpl,cPreview)
  *   Warning(SetMsg())
  * endif
  ddRefreshCurrent()
unlock record
RETURN MnuDone()


**
**
FUNCTION VenDoPrint(jnl,cIdTpl,cPreview,lDlg)
local aSaveMvt := saMvt
local nSaveDevise := SetDevise()
local ifc
local tpl
local lOkay := .f.
local a
RETURN .f. if jnl == NIL
default lDlg to .t.
if (ifc := IfcLocate(jnl[JNL_IDCTR],VEN->IdJnl,VEN->IdMfc)) == NIL
  SetMsg(VEN->IdJnl + " & " + VEN->IdMfc + MsgIfcFail(), NIL, "WRN024" )
  RETURN .f.
endif
RETURN .f. if (a := VenVnlInit(jnl)) == NIL
* seek VEN->IdPar in PAR
SetTplLang(PAR->Langue)
saMvt := {}
SetDevise(VEN->IdDev)
if empty(jnl[JNL_IDTPT])
  lOkay := ActExec("VENPRINT") // fprint(cFilename)
else
  if empty(cIdTpl)
    if IFCATTR_P $ ifc[IFC_ATTRIB] .or. USRATTR_E $ UsrAttrib()
      cIdTpl := PickTpl( ;
        jnl[JNL_IDTPT],VenIdTpl(ifc),PAR->Langue,NIL, ;
        MsgPickTpl() + MsgIdJnlDoc() ;
      )
    else
      cIdTpl := VenIdTpl(ifc)
    endif
  endif
  if cIdTpl == NIL
    lOkay := .f.
  elseif (tpl := TplValue(jnl[JNL_IDTPT],cIdTpl,{||TplInfo()})) == NIL
    lOkay := .f.
  else
    SetDlgTitle(tpl[TPL_NAME])
    if OpenPrinter( ;
      tpl[TPL_IDOPT],cPreview,tpl[TPL_WIDTH], ;
      NIL,NIL,{||VenPrePrint()},tpl[TPL_IDDLG],lDlg;
    )
      p_MsgDisplay(MsgIdJnlDoc() + " " + ParName())
      TplParse(hardcr(tpl[TPL_MEMO]))
      ClosePrinter()
      lOkay := (LstError() == PRN_DONE)
    endif
  endif
endif
if lOkay
  VEN->Attrib := strtran(trim(VEN->Attrib),VENATTR_P) + VENATTR_P
  MnuDone()
  // lOkay := .t.
endif
SetDevise(nSaveDevise)
saMvt := aSaveMvt
VnlRestore(a)
RETURN lOkay


**
** VenPrintF()
**
*FUNCTION VenPrintf(cFilename)
*local jnl := JnlLocate(VEN->IdJnl)
*local aSaveMvt := saMvt
*local nSaveDevise := SetDevise()
*local ifc
*local lOkay := .f.
*local a
*RETURN .f. if jnl == NIL
*if (ifc := IfcLocate(jnl[JNL_IDCTR],VEN->IdJnl,VEN->IdMfc)) == NIL
*  Warning(VEN->IdJnl + " & " + VEN->IdMfc + MsgIfcFail(), NIL, "WRN024" )
*  RETURN .f.
*endif
*if (a := VenVnlInit(jnl)) == NIL
*  Warning(MsgIdJnldoc()+" : "+SetMsg())
*  RETURN .f.
*endif
** seek VEN->IdPar in PAR
*SetTplLang(PAR->Langue)
*saMvt := {}
*SetDevise(VEN->IdDev)
*lOkay := fprint(cFilename)
*SetDevise(nSaveDevise)
*saMvt := aSaveMvt
*VnlRestore(a)
*RETURN lOkay


**
** VenIdTpl()
**
FUNCTION VenIdTpl(ifc)
local jnl := JnlLocate(VEN->IdJnl)
RETURN NIL if jnl == NIL
RETURN jnl[JNL_IDTPL] if ifc == NIL
RETURN jnl[JNL_IDTPL] if empty(ifc[IFC_IDTPL])
RETURN ifc[IFC_IDTPL]

**
** VnlDescript()
**
FUNCTION VnlDescript(cFormat,xcText,lRtfMode)
local cLine := ""
local cText
* local cLibell
default lRtfMode to .f.
cFormat := upper(cFormat)
#ifdef DEF_ART
  * RETURN NIL if ! VnlRefExist()
  RETURN "!VnlRefExist()" if ! VnlRefExist()
#endif DEF_ART
#ifdef DEF_ART
  if "M" $ cFormat .and. ARTATTR_B $ ART->Attrib
    if ! empty(ART->Memo1)
      * TplParse(softcr(ArtMemo(TplLang())) + CR_LF)
      cLine += softcr(ArtMemo(TplLang())) + CR_LF
    endif
  endif
#endif DEF_ART
if "B" $ cFormat
  if ! empty(FIELD->Memo)
    cLine += softcr(FIELD->Memo) + CR_LF
  endif
elseif ! "A" $ cFormat
  cLine += softcr(FIELD->Memo)
endif
* if FIELD->Code != LNCODE_ART .and. FIELD->Code != LNCODE_ARTFIXE
*   scIdGra := NIL
*   * snMarge := 0
* endif
#ifdef DEF_ART
  if "Q" $ cFormat
    if ! empty(FIELD->Qte)
      #ifdef DEF_UNT
        cLine += ltrim(komma(FIELD->Qte)) + VnlUntName(TplLang())
      #else
        cLine += ltrim(komma(FIELD->Qte))
        if IsArtCode(FIELD->Code)
          cLine += trim(" " + ART->IdUnt)
        endif
      #endif
    endif
  endif
#endif DEF_ART
if empty(FIELD->Desig)
  cLine += trim(VnlObjName(PAR->Langue))
else
  cLine += trim(FIELD->Desig)
endif
* cLine += trim(VnlLibell())
#ifdef DEF_VNLATTR
  if VNLATTR_U $ FIELD->Attrib
    if lRtfMode
      cLine := "{\ul " + cLine + "}"
    else
      cLine += CR_LF + repl("Ä",len(cLine))
    endif
  endif
#endif DEF_VNLATTR
if xcText != NIL
  if !empty(cText := xparse(xcText))
    cLine += CR_LF + cText
  endif
endif
if "T" $ cFormat
  if FIELD->Code == LNCODE_TOTAL
    cLine := repl("Ä",t_cpl()) + CR_LF + cLine + CR_LF + chr(255)
  * elseif slIsTitle
  *   cLine += CR_LF + repl("Ä",len(cLine))
  endif
endif
* TplParse(cLine)
if "A" $ cFormat
  if ! empty(FIELD->Memo)
    if ! empty(cLine)
      cLine += CR_LF
    endif
    cLine += softcr(FIELD->Memo)
  endif
endif
#ifdef DEF_ART
  if "M" $ cFormat .and. ARTATTR_A $ ART->Attrib
    if ! empty(ART->Memo1)
      * TplParse(CR_LF + softcr(ArtMemo(TplLang())))
      cLine += CR_LF + softcr(ArtMemo(TplLang()))
    endif
  endif
#endif DEF_ART
* RETURN NIL // cLine // PrnStream(cLine)
RETURN cLine

FUNCTION softcr(c) ; RETURN strtran(c,chr(141)+chr(10))


FUNCTION ArtMemo(cLangue)
#ifdef DEF_4LANG
  RETURN ART->Memo4 if cLangue == MemLang4 .and. ! empty(ART->Memo4)
#endif
RETURN ART->Memo3 if cLangue == MemLang3 .and. ! empty(ART->Memo3)
RETURN ART->Memo2 if cLangue == MemLang2 .and. ! empty(ART->Memo2)
RETURN ART->Memo1

FUNCTION EvalVen(cIdJnl,cIdDoc,bEval)
local uReturn := NIL
open area oVen()
  seek cIdJnl + cIdDoc
  * if eof()
  *   Warning(cIdJnl + " " + cIdDoc + MsgNotFound(UsrLang()))
  * else
    uReturn := eval(bEval)
  * endif
close area
RETURN uReturn

* STATIC FUNCTION VnlPrint(jnl,cTpl)
* TplParse(cTpl)
* RETURN .t.

**
** VenVnlList()
**
FUNCTION VenVnlList(cParam,cFilter)
local jnl := JnlLocate(VEN->IdJnl)
local nPos
local lParse := .f.
local xaSum
* local a
if (nPos := at("/sum ",cParam)) != 0
  xaSum := alltrim(substr(cParam,nPos+5))
  * rpt_write("xaSum = " + xaSum)
  cParam := alltrim(left(cParam,nPos-1))
endif
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
if (nPos := at("/parse",cParam)) != 0
  lParse := .t.
  cParam := alltrim(left(cParam,nPos-1))
endif
RETURN NIL if jnl == NIL
default cFilter to ".t."
* RETURN NIL if (a := VenVnlInit(jnl)) == NIL
saTrmSum := {}
saMvt := {}
cParam := OhneAnf(cParam)
snVnlNum := 1
slIsTitle := .t.
open area oVnl(),oGen(),oArt(),oGra(),oVen(),oNew(),oNgr(),oVna(),oDls()
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdJnl == VEN->IdJnl ;
                   .and. FIELD->IdDoc == VEN->IdDoc
    if ! VnlVarCollect()
      Warning(MsgIdJnlDoc() + " : " + SetMsg())
      exit
    endif
    if ! VnlRefExist()
      Warning(MsgIdJnlDoc() + " : " + SetMsg())
      exit
    endif
    #ifdef DEF_ART
      if FIELD->Code == LNCODE_REMARQ
        seek padr("*",LenIdArt()) in ART
      endif
    #endif DEF_ART
    if &cFilter
      #ifdef DEF_VNLATTR
        if VNLATTR_S $ FIELD->Attrib
          p_eject()
        endif
      #endif
      if ! empty(xaSum)
        aCollect(saTrmSum,&xaSum)
      endif
      if lParse
        TplParse(StrParse(cParam))
        * VnlPrint(jnl,StrParse(cParam))
      else
        TplParse(cParam)
      endif
      if FIELD->Code == LNCODE_TOTAL
        slIsTitle := .t.
        snVnlNum++
      else
        slIsTitle := .f.
      endif
      if ! VnlMvtCollect(jnl,saMvt)
        Warning(MsgIdJnlDoc() + " : " + SetMsg())
        exit
      endif
    endif
    skip
  enddo
  #ifdef DEF_VENREMISE
    VenMvtRemise(saMvt)
  #endif
  #ifdef DEF_FRF
    VenFrfCollect(jnl,saMvt)
  #endif DEF_FRF
  VenMvtRound(saMvt,jnl)
close area
* VnlRestore(a)
RETURN NIL





FUNCTION VnlNum
RETURN ntrim(snVnlNum) if slIsTitle
RETURN ""

FUNCTION VnlMntF(p,c)
#ifdef DEF_VNLATTR
  RETURN "" if VnlHideDetail() // VNLATTR_D $ FIELD->Attrib
#endif DEF_VNLATTR
if FIELD->Code == LNCODE_TOTAL
  if "T" $ upper(p)
    c := repl("Ä",t_cpl()) + CR_LF + c + CR_LF + chr(255)
  endif
endif
RETURN c

#endif DEF_VEN

#ifdef DEF_TAX

FUNCTION TvaLook(cParam,nWhat,nSkonto)
local cCode
local nPos
local cFormat := ""
if (nPos := at("/format ",cParam)) != 0
  cFormat := alltrim(substr(cParam,nPos+8))
  cParam := left(cParam,nPos-1)
endif
if (nPos := at("/escompte ",cParam)) != 0
  nSkonto := val(alltrim(substr(cParam,nPos+10)))
  cParam := left(cParam,nPos-1)
endif
if (nPos := at("/skonto ",cParam)) != 0
  nSkonto := val(alltrim(substr(cParam,nPos+8)))
  cParam := left(cParam,nPos-1)
endif
if left(cParam,1) $ "+-*"
  cCode := ""
  cFormat := cParam
else
  cCode := cParam
endif
RETURN EscMontant(VenTvaSum(nWhat,cCode,nSkonto),cFormat)


** nWhat = 1 : base
** nWhat = 2 : taxe
** nWhat = 3 : tvac
FUNCTION VenTvaSum(nWhat,cCode,nSkonto)
local i
local lNot := ("!" $ cCode)
local nLook := 0
default nSkonto to 0
for i := 1 to len(saMvt)
  if empty(cCode) ;
     .or. (saMvt[i][MVT_TAX][TAX_IDTAX] $ cCode .and. ! lNot) ;
     .or. ((! saMvt[i][MVT_TAX][TAX_IDTAX] $ cCode) .and. lNot)
    if nWhat == 1
      if saMvt[i][MVT_ISBASE]
        nLook += (saMvt[i][MVT_MONT]) - (saMvt[i][MVT_MONT] * nSkonto / 100)
      endif
    elseif nWhat == 2
      if ! saMvt[i][MVT_ISBASE]
        nLook += saMvt[i][MVT_MONT]
      endif
    elseif nWhat == 3
      if saMvt[i][MVT_ISBASE]
        nLook += saMvt[i][MVT_MONT] - (saMvt[i][MVT_MONT] * nSkonto / 100)
      else
        nLook += saMvt[i][MVT_MONT]
      endif
    endif
  endif
next i
RETURN nLook

FUNCTION VenHtva(cIdDev,cIdTax)
local nMont := 0
local i
for i := 1 to len(saMvt)
  if saMvt[i][MVT_ISBASE]
    if empty(cIdTax) .or. saMvt[i][MVT_TAX][TAX_IDTAX] $ cIdTax
      if cIdDev == DevDefault(VEN->Periode)
        nMont += saMvt[i][MVT_MONTDB]
      elseif cIdDev == VEN->IdDev
        nMont += saMvt[i][MVT_MONT]
      else
        nMont += Db2Dev(cIdDev,VEN->Periode,saMvt[i][MVT_MONTDB])
      endif
    endif
  endif
next i
RETURN nMont

FUNCTION VenMtva(cIdDev,cIdTax)
local nMont := 0
local i
for i := 1 to len(saMvt)
  if ! saMvt[i][MVT_ISBASE]
    if empty(cIdTax) .or. saMvt[i][MVT_TAX][TAX_IDTAX] $ cIdTax
      if cIdDev == DevDefault(VEN->Periode)
        nMont += saMvt[i][MVT_MONTDB]
      elseif cIdDev == VEN->IdDev
        nMont += saMvt[i][MVT_MONT]
      else
        nMont += Db2Dev(cIdDev,VEN->Periode,saMvt[i][MVT_MONTDB])
      endif
    endif
  endif
next i
RETURN nMont


**
** TvaLines()
**
*FUNCTION TvaLines( cIdDev )
*local i
*local nMont
*local nTotBase := 0
*local nTotTva := 0
*local nTotMont := 0
*local cText := ""
*local cLine1
*local cLine2
*local cLine3
*local aTva := {}
*local cLangue := TplLang()
*KeepTogether(6)
*cLine1 := padr(MsgTauxT(cLangue),7) + "³"
*cLine2 := padr(MsgBase(cLangue),7) + "³"
*cLine3 := padr(MsgTva(cLangue),7) + "³"
*for i := 1 to len(aTva)
*  cLine1 += padl(strtran(str(TaxTaux(aTva[i][TVA_IDTAX],5,2)),".",","),10) + " "
*  cLine2 += ntomf(aTva[i][TVA_BASE]) + " "
*  cLine3 += ntomf(aTva[i][TVA_TAXE]) + " "
*next i
**cLine2 := padr(cLine2,p_cpl() - 11) + "³" + ntomf(TvaSumBase(aTva))
**cLine3 := padr(cLine3,p_cpl() - 11) + "³" + ntomf(TvaSumTaxe(aTva))
*PrintLine(cLine1)
*cLine1 := padr("ÄÄÄÄÄÄÄÅ",p_cpl() - 11,"Ä") + "Â" + repl("Ä",10)
*PrintLine(cLine1)
*PrintLine(cLine2)
*PrintLine(cLine3)
*cLine1 := padr("ÄÄÄÄÄÄÄÁ",p_cpl() - 11,"Ä") + "Á" + repl("Ä",10)
*PrintLine(cLine1)
** cLine1 := padl(MsgToPay(cLangue),LstLnWid() - 15) + " " + cIdDev + " " + ;
**           ntomf(TvaSumTaxe(aTva)+TvaSumBase(aTva))
*PrintLine(cLine1)
*RETURN NIL



**
** TvaTaxUnique()
**
*FUNCTION TvaTaxUnique(aTva)
*local i
*local j
*local lFound
*local aTvaNew := {}
*for i := 1 to len(aTva)
*  lFound := .f.
*  for j := 1 to len(aTvaNew)
*    if aTvaNew[j][TVA_IDTAX] == aTva[i][TVA_IDTAX]
*      lFound := .t.
*      exit
*    endif
*  next j
*  if ! lFound
*    aadd(aTvaNew, { ;
*      aTva[i][TVA_IDTAX] , ;
*      NIL, ;
*      NIL, ;
*      0, ;
*      0, ;
*      0, ;
*      0  ;
*    } )
*    // { cIdTax, cIdCat, cIdGen, nBase, nTaxe, nBaseDB, nTaxeDB } )
*    j := len(aTvaNew)
*  endif
*  aTvaNew[j][TVA_BASE]   += aTva[i][TVA_BASE]
*  aTvaNew[j][TVA_TAXE]   += aTva[i][TVA_TAXE]
*  aTvaNew[j][TVA_BASEDB] += aTva[i][TVA_BASEDB]
*  aTvaNew[j][TVA_TAXEDB] += aTva[i][TVA_TAXEDB]
*next i
*RETURN aTvaNew

#endif DEF_TAX

FUNCTION puf(cMont)
local nMont := val(cMont)
local nDecPos := rat(".",cMont)
RETURN space(10) if empty(cMont)
if nDecPos != 0
  nDecPos := 10 - nDecPos
endif
RETURN ntomf(nMont,nDecPos)


#ifdef DEF_MSG

**
** MsgPrint
**
FUNCTION MsgPrint(cTplType,cPickTitle)
local cIdTpl := MSG->IdTxt
RETURN .f. if ! ParExist(MSG->IdPar)
default cTplType to TPLTYPE_MSG
if cPickTitle != NIL
  cIdTpl := PickTpl(cTplType,cIdTpl,PAR->Langue,NIL, cPickTitle)
  RETURN .f. if cIdTpl == NIL
elseif empty(cIdTpl)
  RETURN !SetMsg("Kann nicht drucken weil keine Druckmaske angegeben.")
endif
open area oPlz(), oAmk(), oPxs()
  SetTplLang(PAR->Langue)
  #ifdef DEF_AMK
  seek MSG->IdMsg in AMK
  #endif DEF_AMK
  #ifdef DEF_PXT
  seek MSG->IdPar in PXS
  #endif
  PrintTemplate(cTplType,cIdTpl)
close area
RETURN MnuDone()

#endif DEF_MSG

#ifdef DEF_EVT

FUNCTION MsgEvtExist()
RETURN " : unbekannte Ereignis-Art!"

**
** EviPrint
**
FUNCTION EviPrint()
local evt := EvtLocate(EVI->IdEvt)
local cIdTpl := EVI->IdTpl
if evt == NIL
  Warning(EVI->IdEvt + MsgEvtExist())
  RETURN .f.
endif
* if empty(cIdTpl)
*   cIdTpl := evt[EVT_IDTPL]
* endif
RETURN .f. if ! ParExist(EVI->IdPar)
open area oPlz()
  SetTplLang(PAR->Langue)
  PrintTemplate(evt[EVT_IDTPT],EVI->IdTpl)
close area
RETURN MnuDone()

#endif DEF_EVT

#ifdef DEF_PRESTO

**
** TrmPrint
**
FUNCTION TrmPrint(cIdTpl)
default cIdTpl to PickTpl(TPLTYPE_TRM,"STD") // JnlIdTpl(SYSJNL_TRM))
RETURN NIL if cIdTpl == NIL
open area oPar(), oPlz(), oNat(), oTac()
  seek TRM->IdPar in PAR
  seek TRM->IdTac in TAC
  SetTplLang(PAR->Langue)
  PrintTemplate(TPLTYPE_TRM,cIdTpl)
close area
RETURN MnuDone()

#endif DEF_PRESTO

#ifdef DEF_ART

#ifdef DEF_ART_REF

FUNCTION ArtList(cParam)
local cFilter := ""
local nPos
local cRef1 := space(LenArtRef())
local cRef2 := space(LenArtRef())
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
cFilter := padr(cFilter,128)
open window ("Artikelliste") size 5,50
say "Referenz "
get cRef1
say " bis "
get cRef2
WinCr()
say "Filter "
get cFilter picture "@K@S30"
nKey := ReadScr()
close window
if nKey == K_ESC
  LstError(PRN_ABORT)
  RETURN NIL
endif
cFilter := trim(cFilter)
cRef1 := trim(RefTrunc(cRef1))
cRef2 := trim(RefTrunc(cRef2))
open area oArt()
  ddSetOrder(ORD_ART_REF)
  softseek cRef1
  do while ! eof() .and. LstContinue()
    if ! empty(cRef2)
      if left(RefTrunc(ART->Ref),len(cRef2)) > cRef2
        exit
      endif
    endif
    if ! ARTATTR_H $ ART->Attrib
      if empty(cFilter) .or. &cFilter
        TplParse(OhneAnf(cParam))
      endif
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_ART_REF


#endif DEF_ART

FUNCTION TptPrint(cIdTpt,cIdLng,cTitle)
static scIdTpl
local tpl
local tpt := TptLocate(cIdTpt)
SetTplLang(cIdLng)
RETURN ActExec(cIdTpt+"PRINT") if tpt == NIL
tpl := PickTpl( ;
  cIdTpt,scIdTpl, cIdLng, ;
  {|| TplInfo() }, cTitle ;
)
RETURN NIL if tpl == NIL
SetDlgTitle(tpl[TPL_NAME])
if OpenPrinter( ;
    tpl[TPL_IDOPT],NIL,tpl[TPL_WIDTH], ;
    NIL,NIL,NIL,tpl[TPL_IDDLG] ;
  )
  p_MsgDisplay(tpl[TPL_NAME])
  scIdTpl := tpl[TPL_IDTPL]
  TplParse(tpl[TPL_MEMO])
  ClosePrinter()
endif
RETURN MnuDone()

#ifdef DEF_HST

**
** HstPrint()
**
FUNCTION HstPrint
local x
#ifdef DEF_GEN
if empty(HST->IdCtr)
  open area oGen()
    seek HST->IdGen
    if ! eof()
      x := GenPrint()
    endif
  close area
endif
#endif
if ! empty(HST->IdCtr)
  open area oPar(), oPlz(), oNat()
    seek HST->IdPar
    if ! eof()
      x := ParPrint()
    endif
  close area
endif
RETURN x

#endif DEF_HST


**
** ParPrint()
**
FUNCTION ParPrint
local lOkay
sdRapDate := UserDate()
open area oPar()
  lOkay := TptPrint(TPLTYPE_PAR,PAR->Langue,MSG_PARPRINT)
close area
RETURN lOkay


#ifdef DEF_GEN

**
** GenPrint()
**
FUNCTION GenPrint
static scIdTpl
local tpl := PickTpl( ;
  TPLTYPE_GEN, scIdTpl, MemLang1, ;
  {|| TplInfo() }, MSG_GENPRINT ;
)
#ifdef DEF_HST
  if tpl == NIL
    HistGen("HIST","Historik " + GEN->IdGen, GEN->IdGen)
    RETURN .f.
  endif
#endif DEF_HST
SetDlgTitle(tpl[TPL_NAME])
snGenDebit  := 0
snGenCredit := 0
scIdTpl := tpl[TPL_IDTPL]
if OpenPrinter( ;
    tpl[TPL_IDOPT],NIL,tpl[TPL_WIDTH],;
    NIL,NIL,NIL,tpl[TPL_IDDLG] ;
  )
  p_MsgDisplay(tpl[TPL_NAME])
  scIdTpl := tpl[TPL_IDTPL]
  TplParse(tpl[TPL_MEMO])
  ClosePrinter()
endif
RETURN MnuDone()

#endif DEF_GEN

#ifdef DEF_JNL

**
** ParHstList()
**
FUNCTION ParHstList(cParam)
local cFilter := NIL
local nMont
local doc
local nPos
local xaSum
if (nPos := at("/sum ",cParam)) != 0
  xaSum := alltrim(substr(cParam,nPos+5))
  cParam := alltrim(left(cParam,nPos-1))
endif
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
saTrmSum := {}
snParDebit  := 0
snParCredit := 0
#ifdef DEF_HST
  open area oHst(), oVen(), oFin(), oPar()
    default cFilter to "empty(HST->Satis)"
    ddSetOrder(ORD_HST_PARDATE)
    * 20040913 ddSetOrder(ORD_HST_PARMATCH)
    softseek PAR->IdPar
    do while HST->IdPar == PAR->IdPar .and. ! eof() .and. LstContinue()
      if empty(cFilter) .or. (&cFilter)
        TplParse(OhneAnf(cParam))
        nMont := HstMont(SetDevise())
        * if empty(PAR->IdDev) .or. PAR->IdDev == DevDefault(HST->Periode)
        *   nMont := val(HST->Mont)
        * else
        *   nMont := val(HST->MontDev)
        * endif
        if HST->DC == DC_DEBIT
          snParDebit  += nMont
        else
          snParCredit += nMont
        endif
        if ! empty(xaSum)
          aCollect(saTrmSum,&xaSum)
        endif
      endif
      skip
    enddo
  close area
#endif DEF_HST
#ifdef DEF_IMP
  open area oMvi(), oImp(), oPar()
    * default cFilter to "empty(MVI->)"
    ddSetOrder(ORD_MVI_PARDATE)
    softseek PAR->IdPar
    do while MVI->IdPar == PAR->IdPar .and. ! eof() .and. LstContinue()
      if empty(cFilter) .or. (&cFilter)
        if ! empty(sdRapDate)
          if (doc := DocInfo(MVI->IdJnl,MVI->IdDoc,MVI->Line)) != NIL
            if doc[DOC_ECHE] > sdRapDate
              skip
              loop
            endif
          endif
        endif
        TplParse(OhneAnf(cParam))
        * if PAR->IdDev == DevDefault()
          nMont := val(MVI->Mont)
        * else
        *   nMont := val(MVI->MontDev)
        * endif
        if MVI->DC == DC_DEBIT
          snParDebit  += nMont
        else
          snParCredit += nMont
        endif
      endif
      skip
    enddo
  close area
#endif DEF_IMP
RETURN NIL

FUNCTION ParSolde(cDC)
*local nDecPos
*if ! empty(PAR->IdDev)
*  nDecPos := DevDecPos(PAR->IdDev)
*endif
if cDC == DC_DEBIT
  RETURN ntomf(snParDebit - snParCredit) if snParDebit > snParCredit
  RETURN space(LenMntF())
endif
RETURN ntomf(snParCredit - snParDebit) if snParCredit > snParDebit
RETURN space(LenMntF())

FUNCTION ParDebit() // cIdDev)
RETURN snParDebit // if empty(PAR->IdDev) .or. PAR->IdDev == DevDefault(PerActive())

FUNCTION ParCredit()
RETURN snParCredit // if empty(PAR->IdDev) .or. PAR->IdDev == DevDefault(PerActive())

FUNCTION HstText()
local jnl := JnlLocate(HST->IdJnl)
local cText
RETURN "" if jnl == NIL
if jnl[JNL_ALIAS] == "FIN"
  if HST->DC == DC_DEBIT
    cText := MsgUnsere(TplLang())
  else
    cText := MsgIhre(TplLang())
  endif
elseif jnl[JNL_ALIAS] == JNLALIAS_VEN
  if HST->IdCtr == "V"
    cText := MsgUnsere(TplLang())
  else
    cText := MsgIhre(TplLang())
  endif
endif
cText += " " + trim(JnlDocLib(HST->IdJnl,HST->IdDoc,HST->DC,TplLang()))
RETURN cText

FUNCTION MsgUnsere(cIdLng)
RETURN "UNSERE" if cIdLng == "D"
RETURN "ONZE" if cIdLng == "N"
RETURN "NOTRE"

FUNCTION MsgIhre(cIdLng)
RETURN "IHRE" if cIdLng == "D"
RETURN "UW" if cIdLng == "N"
RETURN "VOTRE"

#endif DEF_JNL

#ifdef DEF_ART

**
** TimArtList()
**
FUNCTION TimArtList(cParam)
local nPos
local nOrder := 1
local cFilter := '! "H" $ ART->Attrib'
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
if (nPos := at("/order ",cParam)) != 0
  nOrder := val(alltrim(substr(cParam,nPos+7)))
  cParam := alltrim(left(cParam,nPos-1))
endif
open area oArt(), oGra()
  ddSetOrder(nOrder)
  go top
  do while ! eof() .and. LstContinue()
    if TaskInter() ; exit ; endif
    if (&cFilter)
      TplParse(OhneAnf(cParam))
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_ART

#ifdef DEF_CTS

**
** CtsList()
**
FUNCTION CtsList(cParam)
local nPos
local cFilter := ".t."
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
snCtsMont  := 0
* snCtsMontR := 0
snCtsQte   := 0
open area oCts(), oArt()
  go top
  do while ! eof() .and. LstContinue()
    if ChkPeriode(CTS->Periode) == 0
      seek CTS->IdArt in ART
      if &cFilter
        TplParse(OhneAnf(cParam))
        snCtsQte   += qton(CTS->Qte)
        snCtsMont  += val(CTS->Mont)
        * snCtsMontR += val(CTS->MontR)
      endif
    endif
    skip
  enddo
close area
RETURN NIL

FUNCTION CtsSumQte     ; RETURN ntoq(snCtsQte," ")
FUNCTION CtsSumMontant ; RETURN ntomf(snCtsMont)
* FUNCTION CtsSumRevient ; RETURN ntomf(snCtsMontR)

#endif DEF_CTS

#ifdef DEF_CTP

**
** CtpList()
**
FUNCTION CtpList(cParam)
local nPos
local cFilter := ".t."
local nCount := 0
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
snCtpUmsatz  := 0
snCtpDebit   := 0
snCtpCredit  := 0
open area oCtp(), oPar()
  go top
  do while ! eof() .and. LstContinue()
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%" )
    if ChkPeriode(CTP->Periode) == 0
      seek CTP->IdPar in PAR
      if &cFilter
        TplParse(OhneAnf(cParam))
        snCtpUmsatz += val(CTP->Umsatz)
        snCtpDebit  += val(CTP->Debit)
        snCtpCredit += val(CTP->Credit)
      endif
    endif
    skip
  enddo
close area
RETURN NIL

FUNCTION CtpUmsatz ; RETURN ntomf(snCtpUmsatz)
FUNCTION CtpDebit  ; RETURN ntomf(snCtpDebit)
FUNCTION CtpCredit ; RETURN ntomf(snCtpCredit)
FUNCTION CtpSolde  ; RETURN solde(snCtpDebit,snCtpCredit)


#endif DEF_CTP

#ifdef DEF_HST

#ifdef DEF_GEN

**
** GenHstList()
**
FUNCTION GenHstList(cParam)
local nPos
local cFilter := ""
local nMont
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
open area oHst(), oGen(), oPar(), oVen(), oFin()
  ddSetOrder(ORD_HST_GENDATE)
  softseek GEN->IdGen
  do while HST->IdGen == GEN->IdGen .and. ! eof() .and. LstContinue()
    if empty(cFilter) .or. (&cFilter)
      TplParse(OhneAnf(cParam))
      if HST->DC == DC_DEBIT
        snGenDebit  += val(HST->Mont)
      else
        snGenCredit += val(HST->Mont)
      endif
    endif
    skip
  enddo
close area
RETURN NIL


FUNCTION GenSolde(cDC)
if cDC == DC_DEBIT
  RETURN ntomf(snGenDebit - snGenCredit) if snGenDebit > snGenCredit
  RETURN space(LenMntF())
endif
RETURN ntomf(snGenCredit - snGenDebit) if snGenCredit > snGenDebit
RETURN space(LenMntF())

FUNCTION GenDebit()  ; RETURN ntomf(snGenDebit)
FUNCTION GenCredit() ; RETURN ntomf(snGenCredit)

#endif DEF_GEN

#endif DEF_HST


**
** TimParList()
**
FUNCTION TimParList(cParam)
local nPos
local nOrder := 1
local cFilter := '! "H" $ PAR->Attrib'
local nCount := 0
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
if (nPos := at("/order ",cParam)) != 0
  nOrder := val(alltrim(substr(cParam,nPos+7)))
  cParam := alltrim(left(cParam,nPos-1))
endif
open area oPar(), oPlz(), oNat()
  ddSetOrder(nOrder)
  go top
  do while ! eof() .and. LstContinue()
    if TaskInter() ; exit ; endif
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%" )
    if (&cFilter)
      TplParse(OhneAnf(cParam))
    endif
    skip
  enddo
close area
RETURN NIL



#ifdef DEF_FIN

**
** FinPrint()
**
FUNCTION FinPrint()
local jnl := JnlLocate(FIN->IdJnl)
RETURN NIL if jnl == NIL
open area oPar(), oPlz(), oNat()
  SetTplLang(MemLang1)
  if empty(jnl[JNL_IDTPT])
    ActExec("FINPRINT")
  else
    PrintTemplate(jnl[JNL_IDTPT],jnl[JNL_IDTPL])
  endif
close area
RETURN MnuDone()

#endif DEF_FIN

#ifdef DEF_ANA

**
** OdaPrint()
**
FUNCTION OdaPrint()
local jnl := JnlLocate(ODA->IdJnl)
RETURN NIL if jnl == NIL
open area oPar(), oPlz(), oNat()
  SetTplLang(MemLang1)
  PrintTemplate(jnl[JNL_IDTPT],jnl[JNL_IDTPL])
close area
RETURN MnuDone()

#endif DEF_ANA

#ifdef DEF_ODS

**
** OdsPrint()
**
FUNCTION OdsPrint()
local jnl := JnlLocate(ODS->IdJnl)
RETURN NIL if jnl == NIL
RETURN NIL if empty(jnl[JNL_IDTPL])
SetTplLang(MemLang1)
PrintTemplate(jnl[JNL_IDTPT],jnl[JNL_IDTPL])
RETURN MnuDone()

**
** OdsOdlList()
**
FUNCTION OdsOdlList(cParam)
local cFilter := ""
local nPos
local cIdOds := ODS->IdOds
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
open area oOdl(), oPar()
  ddSetOrder(ORD_ODL_DOC)
  softseek cIdOds
  do while ODS->IdOds == cIdOds .and. ! eof() .and. LstContinue()
    if empty(cFilter) .or. (&cFilter)
      seek ODS->IdArt in ART
      TplParse(OhneAnf(cParam))
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_ODS

#ifdef DEF_VEN

FUNCTION VenIfcMemo()
RETURN IfcMemo(VEN->IdJnl,VEN->IdMfc)

FUNCTION IfcMemo(cIdJnl,cIdMfc)
local cMemo := ""
local ifc := IfcLocate(JnlIdCtr(cIdJnl),cIdJnl,cIdMfc)
RETURN NIL if ifc == NIL
#ifdef DEF_4LANG
  RETURN ifc[IFC_MEMO4] if TplLang() == MemLang4 ;
                    .and. ! empty(ifc[IFC_MEMO4])
#endif
if TplLang() == MemLang3
  cMemo := ifc[IFC_MEMO3]
elseif TplLang() == MemLang2
  cMemo := ifc[IFC_MEMO2]
endif
if empty(cMemo)
  cMemo := ifc[IFC_MEMO1]
endif
RETURN cMemo

* FUNCTION VenMemoJnl(cIdJnl,p,l)
* default p to ""
* PrintTemplate(TPLTYPE_JNL,padr(cIdJnl+"-"+upper(p),LenIdTpl()))
* RETURN NIL

#endif DEF_VEN

#ifdef DEF_TAX

FUNCTION VenTaxMemo(xlEval)
local cMemo
local cIdCtr := JnlIdCtr(VEN->IdJnl)
default xlEval to {|| ;
  cMemo := LngExpr("TAX->Memo",TplLang()),;
  empty(cMemo).or.TplParse(cMemo) ;
}
RETURN VenTaxLoop(xlEval)

FUNCTION VenTaxLoop(xlEval)
local cIdCtr := JnlIdCtr(VEN->IdJnl)
local i
local lOkay := .t.
local aTax := {}
for i := 1 to len(saMvt)
  DictAddItem(aTax,saMvt[i][MVT_TAX][TAX_IDTAX])
next i
open area oTax()
  go top
  do while lOkay .and. !eof()
    if TAX->IdCtr == cIdCtr
      if empty(TAX->Date) .or. VEN->Date <= TAX->Date
        if ascan(aTax,TAX->IdTax) != 0
          lOkay := eval(xlEval)
        endif
      endif
    endif
    skip
  enddo
close area
RETURN lOkay

* FUNCTION VenTaxMemo(p)
* local cMemo
* local cIdCtr := JnlIdCtr(VEN->IdJnl)
* local xlEval := {|cIdTax| ;
*   cMemo := TaxMemo(cIdCtr,cIdTax,TplLang(),VEN->Date),;
*   empty(cMemo).or.TplParse(cMemo) ;
* }
* RETURN VenTaxLoop(xlEval)
*
* FUNCTION VenTaxLoop(xlEval)
* local i
* local aTax := {}
* for i := 1 to len(saMvt)
*   DictAddItem(aTax,saMvt[i][MVT_TAX][TAX_IDTAX])
* next i
* for i := 1 to len(aTax)
*   RETURN .f. if ! xeval(xlEval,aTax[i])
* next i
* RETURN .t.

#endif DEF_TAX

FUNCTION EscMontant(nMont,cParam)
local lText := .f.
local lFull := .f.
local lNoAlign := .f.
cParam := upper(cParam)
if "TEXT" $ cParam
  lText := .t.
  cParam := alltrim(strtran(cParam,"TEXT"))
endif
if "NOALIGN" $ cParam
  lNoAlign := .t.
  cParam := alltrim(strtran(cParam,"NOALIGN"))
endif
if "FULL" $ cParam
  lFull := .t.
  cParam := alltrim(strtran(cParam,"FULL"))
endif
if ! empty(cParam)
  if right(cParam,1) == "%"
    cParam := strtran(cParam,"%")
    nMont += ( nMont * val(cParam) / 100 )
  elseif left(cParam,1) == "*"
    nMont *= val(substr(cParam,2))
  elseif left(cParam,1) $ "+-"
    nMont += val(cParam)
  endif
endif
* 20020108 : RETURN nText(nMont,TplLang(),lFull,SetDecPos()) if lText
RETURN nText(ntom(nMont),TplLang(),lFull) if lText
RETURN ltrim(ntomf(nMont)) if lNoAlign
RETURN ntomf(nMont)


#ifdef DEF_MASQUES

**
** ParMailPrint()
**
*FUNCTION ParMailPrint()
*if slAskPrinter
*  scMasque := PickTpl(TPLTYPE_PAR,NIL,MSG006)
*  RETURN .f. if scMasque == NIL
*endif
*TimTplInit(PAR->Langue)
*ParTplAdd()
*PrintTemplate(TPLTYPE_PAR,scMasque,PAR->Langue)
*slAskPrinter := .F.
*RETURN MnuDone()

#endif DEF_MASQUES


#ifdef DEF_HOLZ

*FUNCTION PrjPrint
*static dDate := NIL
*local cLine
*local nMenge := 0
*default dDate to UserDate()
*open window ("Holzliste drucken") size 3,50
*say "Datum : "
*@ row(), col() get dDate
*nKey := ReadScr()
*close window
*RETURN .f. if nKey == K_ESC
*open printer LISTE width 80
*PrintLine("Lieferung vom " + dtocf(dDate))
*open area oStm()
*softseek PRJ->IdPrj
*do while STM->IdPrj == PRJ->IdPrj .and. ! eof() .and. LstContinue()
*  cLine := STM->IdStm
*  cLine += "        " + STM->Laenge
*  cLine += " " + STM->Durchm
*  cLine += "         " + STM->Menge
*  nMenge += val(STM->Menge)
*  PrintLine(cLine)
*  skip
*enddo
*close area
*PrintLine(padl("T O T A L  : ",40) + str(nMenge,10,3))
*close printer
*RETURN MnuDone()

#endif DEF_HOLZ

#ifdef DEF_PIN

*FUNCTION PrjPrint(cIdPrj)
*static dDate1 := NIL
*static dDate2 := NIL
*static scPin := BUTTON_ON
*local cLine
** local nMenge := 0
*default dDate1 to UserDate()
*default dDate2 to UserDate()
*default cIdPrj to space(LEN_IDPRJ)
*open window ("Projekt drucken") size 5,50
*say "Vom "
*@ row(), col() get dDate1 when scPin == BUTTON_ON
*say " bis zum "
*@ row(), col() get dDate2 when scPin == BUTTON_ON
*WinCr()
*say "Nur Projekt "
*@ row(), col() get cIdPrj picture PIC_ID pick PickPrj(cIdPrj)
*#ifdef DEF_PIN
*  WinCr()
*  @ row(), col() get scPin checkbox
* say " Pinwand-Eintr„ge"
*#endif DEF_PIN
*nKey := ReadScr()
*close window
*RETURN .f. if nKey == K_ESC
*open printer LISTE width 80 ;
*TitBlock {|| ;
*  PrintHeader("Projekt " + trim(PRJ->Name1)) ;
*}
*#ifdef DEF_PIN
*  if scPin == BUTTON_ON
*    open area oPin(), oPrj()
*    go top
*    do while ! eof() .and. LstContinue()
*      if empty(cIdPrj) .or. PIN->IdPrj == cIdPrj
*        if empty(dDate1) .or. PIN->Date >= dDate1
*          if empty(dDate2) .or. PIN->Date <= dDate2
*            if empty(cIdPrj)
*              seek PIN->IdPrj in PRJ
*              PrintLine(PRJ->Name1)
*            endif
*            cLine := dtocf(PIN->Date) + " --- " + PinAttrText(PIN->Attrib)
*            PrintLine(cLine)
*            TplParse(PIN->Text)
*          endif
*        endif
*      endif
*      skip
*    enddo
*    close area
*    * PrintLine(padl("T O T A L  : ",40) + str(nMenge,10,3))
*  endif
*#endif DEF_PIN
*close printer
*RETURN MnuDone()


#endif DEF_PIN

#ifdef DEF_HOLZ

FUNCTION VenStmList(cIdJnl,cIdDoc,cParam)
open area oStm(), oArt()
  ddSetOrder(StmOrder(cIdJnl)) // ORD_STM_DOC
  softseek cIdDoc
  do while ! eof() .and. ! TaskInter() ;
                   .and. &("STM->"+cIdJnl+"IdDoc") == cIdDoc
    seek STM->IdArt in ART
    TplParse(OhneAnf(cParam))
    skip
  enddo
close area
RETURN NIL

#endif DEF_HOLZ

#ifdef DEF_PRJ

**
** PrjPrint()
**
FUNCTION PrjPrint(cIdTpl)
static scIdTpl
local tpl
default cIdTpl to PickTpl( ;
  TPLTYPE_PRJ, scIdTpl, MemLang1, ;
  NIL, "Projekt drucken" ;
)
RETURN .f. if cIdTpl == NIL
if (tpl := TplValue(TPLTYPE_PRJ,cIdTpl,{||TplInfo()})) == NIL
  Warning(cIdTpl + " : unbekannte Druckmaske")
  RETURN .f.
endif
SetDlgTitle(tpl[TPL_NAME])
if OpenPrinter( ;
    tpl[TPL_IDOPT],NIL,tpl[TPL_WIDTH], ;
    NIL,NIL,NIL,tpl[TPL_IDDLG] ;
  )
  p_MsgDisplay(tpl[TPL_NAME])
  scIdTpl := tpl[TPL_IDTPL]
  TplParse(tpl[TPL_MEMO])
  ClosePrinter()
endif
RETURN MnuDone()

**
** PrjListe()
**
FUNCTION PrjListe
static scIdTpl
SetTplLang(MemLang1)
scIdTpl := PickTpl(TPLTYPE_PRJ,scIdTpl)
RETURN .f. if scIdTpl == NIL
ddScan({|| PrintTemplate(TPLTYPE_PRJ,scIdTpl) })
RETURN MnuDone()


#ifdef DEF_VEN

FUNCTION PrjListDoc(p)
local cLine
local a := {}
local i
open area oVen()
  ddSetOrder(ORD_VEN_PRJ)
  softseek PRJ->IdPrj
  do while VEN->IdPrj == PRJ->IdPrj .and. ! eof()
    if empty(p) .or. VEN->IdJnl $ p
      cLine := VEN->IdJnl
      cLine += " " + VEN->IdDoc
      cLine += " " + dtocf(VEN->Date)
      cLine += " " + padr(ParName(VEN->IdPar),30)
      cLine += " " + ntomf(VenDev2Db(val(VEN->Mont)))
      * cLine += " " + ntomf(val(VEN->Mont) * val(VEN->Cours))
      aCollect(a,{ ;
        VEN->IdJnl, ;
        VenDev2Db(val(VEN->cMontB)), ;
        VenDev2Db(val(VEN->cMontT)) ;
      } )
      * aCollect(a,{ ;
      *   VEN->IdJnl, ;
      *   val(VEN->cMontB)*val(VEN->Cours), ;
      *   val(VEN->cMontT)*val(VEN->Cours) ;
      * } )
      PrintLine(cLine)
    endif
    skip
  enddo
close area
PrintLine()
for i := 1 to len(a)
  PrintLine( ;
    padr("TOTAL " + JnlName(a[i][1]),51) ;
    + " " + ntomf(a[i][2]) ;
    + " " + ntomf(a[i][3]) ;
    + " " + ntomf(a[i][2] + a[i][3]) ;
  )
next i
RETURN NIL

#endif DEF_VEN

#endif DEF_PRJ



#ifdef DEF_IMP

**
** ImpPrint()
**
FUNCTION ImpPrint(cIdTpl)
local jnl := JnlLocate(IMP->IdJnl)
* local cLangue := MemLang1
local cIdPrj 
RETURN .f. if jnl == NIL
default cIdTpl to PickTpl(jnl[JNL_IDTPT],jnl[JNL_IDTPL])
RETURN .f. if cIdTpl == NIL
open area oPar(), oPlz(), oNat(), oBud(), oPrj()
  if empty(IMP->IdPar2)
    seek IMP->IdPar in PAR
  else
    seek IMP->IdPar2 in PAR
  endif
  * cLangue := PAR->Langue
  SetTplLang(PAR->Langue)
  seek IMP->IdPar in PAR
  seek (jnl[JNL_DC] + IMP->IdBud) in BUD
  #ifdef DEF_PRJ
    if empty(IMP->IdPrj)
      open area oIml()
        softseek IMP->IdJnl+IMP->IdDoc
        do while empty(cIdPrj) .and. !eof() ;
          .and. IMP->IdDoc==IMP->IdDoc.and. IML->IdJnl==IMP->IdJnl
          cIdPrj := IML->IdPrj 
          skip
        enddo
      close area
      seek cIdPrj in PRJ
    else
      seek IMP->IdPrj in PRJ
    endif
  #endif
  PrintTemplate(jnl[JNL_IDTPT],cIdTpl)
close area
RETURN MnuDone()

**
** Called from 
** - FFOIML.DLG in a DbfScan() loop (with print stream already open)
** - IMLPRINT.DLG (called from IML.DEF after F7 on an IML row)
FUNCTION ImlPrint(cIdTpt,cIdTpl)
local lOkay := .f.
// sendconsole("ImlPrint()"+cIdTpt+","+cIdTpl)
open area oPar(), oPlz(), oNat(), oBud(), oPrj()
  if empty(IML->IdPar2)
    seek IML->IdPar in PAR
  else
    seek IML->IdPar2 in PAR
  endif
  SetTplLang(PAR->Langue)
  seek IML->IdPar in PAR
  seek (IML->DC+IML->IdBud) in BUD
  #ifdef DEF_PRJ
    seek IML->IdPrj in PRJ
  #endif
  if LstContinue() // print stream already open
    p_PageNum(0)
    lOkay := TplInclude(cIdTpt,cIdTpl)
    p_eject(.t.)
  else
    lOkay := PrintTemplate(cIdTpt,cIdTpl)
    // ,SetPreview(),NIL,NIL,;
    // SetTplIni(),.t.,SetAsPdf(),SetAsMail())
  endif
close area
RETURN lOkay



**
** ImpImlList()
**
FUNCTION ImpImlList(cParam)
open area oIml(), oPar(), oBud()
  softseek IMP->IdJnl + IMP->IdDoc
  do while ! eof() .and. IML->IdJnl == IMP->IdJnl ;
                   .and. IML->IdDoc == IMP->IdDoc
    seek IML->IdPar in PAR
    seek (IML->DC + IML->IdBud) in BUD
    TplParse(OhneAnf(cParam))
    skip
  enddo
close area
RETURN NIL


#endif DEF_IMP

#ifdef DEF_TRA

#define TRL_IDJNL   1
#define TRL_IDPAR2  2
#define TRL_MONT    3
#define TRL_ALEN    3

FUNCTION TraClose(jnlDoc)
local jnl
local lOkay := .f.
saTrl := {}
open area oTrl(), oMvi()
  lOkay := .t.
  softseek TRA->IdJnl + TRA->IdDoc
  do while lOkay .and. ! eof() .and. TRL->IdDoc == TRA->IdDoc ;
                 .and. TRL->IdJnl == TRA->IdJnl
    if ! PerDateWarn(TRL->Periode,TRA->Date,jnlDoc)
      lOkay := .f.
      exit
    endif
    if ! PerSetDirty(jnlDoc,TRL->Periode,TRA->Date,TRA->IdDoc)
      lOkay := .f.
      exit
    endif
    ** neu 20000228
    if !empty(TRL->Backmatch)
      seek TRL->Backmatch in MVI
      if left(TRL->Periode,LEN_YEAR) != left(MVI->Periode,LEN_YEAR)
        SetMsg(TRL->Line + " : falsches Rechnungsjahr Rckbezug !")
        lOkay := .f.
        exit
      endif
    endif
    *if JnlLocate(TrtIdJnl(TRL->IdTrt)) != NIL
    *  if ParExist(TrlIdPar())
    *    if empty(PAR->CptSysI)
    *      SetMsg(trim(ParName())+" : CptSysI darf nicht leer sein !")
    *      lOkay := .f.
    *    endif
    *  else
    *    lOkay := .f.
    *  endif
    *endif
    // added 2001-03-15 :
    if (jnl := JnlLocate(TRL->IdJnl2)) == NIL
      SetMsg(TRL->IdJnl2+MsgJnlExist())
      lOkay := .f.
      exit
    endif
    if ! PerSetDirty(jnl,TRL->Periode,TRA->Date,TRA->IdDoc)
      lOkay := .f.
      exit
    endif
    if ! PreTrlClose()
      lOkay := .f.
      exit
    endif
    if ! TplExist(TPLTYPE_TRL,TRL->IdJnl2)
      TrlCollect()
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
RETURN TrlSumConfirm()

FUNCTION PerDateWarn(cPeriode,dDate,jnl)
local per := PerLocate(cPeriode)
if per == NIL
  SetMsg(cPeriode + MsgPerExist() )
  RETURN .f.
endif
RETURN .t. if PerChkDate(per,dDate,jnl)
SetMsg(MsgPerClosed(cPeriode,dDate,jnl[JNL_IDJNL]))
RETURN .f.



**
** TraPrint()
**
FUNCTION TraPrint()
local cScheck := TRA->Scheck
local i
local cName := space(LenParName())
local nDevise := SetDevise()
* local nDecPos := SetDecPos()
local jnl := JnlLocate(TRA->IdJnl)
if ! empty(jnl[JNL_IDTPL])
  open area oPar(), oPlz(), oNat(), oBud(), oPrj()
    PrintTemplate(jnl[JNL_IDTPT],jnl[JNL_IDTPL])
  close area
else
  saTrl := {}
  open area oTrl(), oPar(), oBud()
    softseek TRA->IdJnl+TRA->IdDoc
    do while ! eof() .and. TRL->IdDoc == TRA->IdDoc ;
                     .and. TRL->IdJnl == TRA->IdJnl
      if !empty(TRA->IdPar) .and. TplExist(TPLTYPE_TRL,TRL->IdJnl2)
        if ! TRLATTR_P $ TRL->Attrib
          TrlPrint()
        endif
      else
        TrlCollect()
      endif
      skip
    enddo
  close area
  if len(saTrl) > 0 .and. !empty(TRA->IdPar)
    if empty(TRA->Scheck)
      * RETURN NIL if ! TrlSumConfirm()
      open window ("Scheck drucken") size 4,60 help SCHECK
      say "Schecknummer "
      get cScheck
      WinCr()
      say "(anderer Empf„nger "
      get cName
      say ")"
      nKey := ReadScr()
      close window
      RETURN NIL if nKey == K_ESC
      DlgDefine("name",cName)
    endif
    if ddRecLock()
      TRA->Scheck := cScheck
      open area oPar(), oPlz(), oNat(), oBud()
        seek TRA->IdPar in PAR
        SetTplLang(PAR->Langue)
        for snTrlIndex := 1 to len(saTrl)
          SetDevise(JnlIdDev(saTrl[snTrlIndex][TRL_IDJNL]))
          PrintTemplate(TPLTYPE_TRA,saTrl[snTrlIndex][TRL_IDJNL])
          if LstError() == PRN_DONE
            open area oTrl()
              softseek TRA->IdJnl + TRA->IdDoc
              do while ! eof() .and. TRL->IdJnl == TRA->IdJnl ;
                               .and. TRL->IdDoc == TRA->IdDoc
                if TRL->IdJnl2 == saTrl[snTrlIndex][TRL_IDJNL]
                  if TRL->IdPar2 == saTrl[snTrlIndex][TRL_IDPAR2]
                    if ddRecLock()
                      TRL->Attrib := strtran(trim(TRL->Attrib),TRLATTR_P) + TRLATTR_P
                      unlock record
                    endif
                  endif
                endif
                skip
              enddo
            close area
          endif
        next i
      close area
      unlock record
    endif
  endif
endif
SetDevise(nDevise)
RETURN MnuDone()

FUNCTION TrlSumConfirm()
local i
* local lOkay := .t.
for i := 1 to len(saTrl)
  RETURN .f. if ! MaxMontConfirm( ;
    TRA->IdJnl, ;
    saTrl[i][TRL_IDJNL], ;
    JnlIdDev(saTrl[i][TRL_IDJNL]), ;
    saTrl[i][TRL_MONT], ;
    PerActive(),;
    "Scheckbetrag" ;
  )
next i
RETURN .t.

FUNCTION MaxMontConfirm(cIdJnl,cIdJnl2,cIdDev,nMont,cPeriode,cTitle)
local cMont := space(LenMont())
local nMontBEF
RETURN .t. if ! MaxMontOverflow(cIdJnl,cIdJnl2,cIdDev,nMont,cPeriode)
default cTitle to "Betrag"
open window ("Best„tigung " + cTitle) size 4,46
say "WIE war doch gleich der Betrag, bitte ?"
WinCr()
say cTitle + " : " + cIdDev + " "
get cMont GET_DECPOS(DevDecPos(cIdDev))
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
if val(cMont) == nMont
  if cIdDev != "BEF" .and. dtos(UserDate()) < "20020701"
    nMontBEF := Dev2Db(cIdDev,PerActive(),nMont)
    nMontBEF := Db2Dev("BEF",PerActive(),nMontBEF)
    RETURN .f. if ! Confirm(ltrim(ntomf(nMont,DevDecPos(cIdDev))) +;
      " sind " + ltrim(ntomf(nMontBEF,0)) + " BEF!",;
      MsgSure(),"N")
  endif
  SendConsole(MsgIdJnlDoc() + " : MaxMontConfirm()")
  RETURN .t.
endif
Warning("Da stimmt was nicht. Prfen Sie noch mal nach !")
RETURN .f.

FUNCTION TraSetPartner(cParam)
if cParam == "1"
  seek TRA->IdPar in PAR
elseif cParam == "2"
  seek saTrl[snTrlIndex][TRL_IDPAR2] in PAR
endif
RETURN NIL

FUNCTION TrlCollect()
local i
local jnl := JnlLocate(TRL->IdJnl2)
local nMont
RETURN NIL if jnl == NIL
RETURN NIL if TRLATTR_P $ TRL->Attrib
nMont := TrlMont(jnl[JNL_IDDEV])
for i := 1 to len(saTrl)
  if saTrl[i][TRL_IDJNL] == TRL->IdJnl2
    if saTrl[i][TRL_IDPAR2] == TRL->IdPar2
      if TRL->DC == jnl[JNL_DC]
        saTrl[i][TRL_MONT] += nMont // TrlMont(TRA->IdDev)
      else
        saTrl[i][TRL_MONT] -= nMont // TrlMont(TRA->IdDev)
      endif
      RETURN NIL
    endif
  endif
next i
if TRL->DC == jnl[JNL_DC]
  aadd(saTrl, { TRL->IdJnl2, TRL->IdPar2, nMont } ) // TRL_ALEN
else
  aadd(saTrl, { TRL->IdJnl2, TRL->IdPar2, - nMont } ) // TRL_ALEN
endif
RETURN NIL

**
** TraTrlList()
**
FUNCTION TraTrlList(cParam)
local jnl := JnlLocate(TRA->IdJnl)
open area oTrl(), oPar(), oBud()
  softseek TRA->IdJnl+TRA->IdDoc
  do while ! eof() .and. TRL->IdDoc == TRA->IdDoc ;
                   .and. TRL->IdJnl == TRA->IdJnl
    if (!empty(jnl[JNL_IDTPL])) .or. TRL->IdJnl2 == saTrl[snTrlIndex][TRL_IDJNL]
      * seek (TRL->DC + TRL->IdBud) in BUD
      TplParse(OhneAnf(cParam))
    endif
    skip
  enddo
close area
RETURN NIL


**
** TraMontant()
**
FUNCTION TraMont()
RETURN 0 if snTrlIndex == 0
RETURN saTrl[snTrlIndex][TRL_MONT]

* RETURN EscMontant(saTrl[snTrlIndex][TRL_MONT],cParam)

FUNCTION TraIdJnl
RETURN "" if snTrlIndex == 0
RETURN saTrl[snTrlIndex][TRL_IDJNL]


FUNCTION TrlDlgPrint
TrlPrint()
ddRefreshCurrent()
RETURN .f.


**
** TrlPrint()
**
FUNCTION TrlPrint()
local cIdTpl := padr(TRL->IdJnl2,LenIdTpl())
local nDecPos := SetDevise()
seek TrlIdPar() in PAR
SetTplLang(PAR->Langue)
RETURN .f. if ! SetDevise(DevDefault(TRL->Periode))
if ddRecLock()
  PrintTemplate(TPLTYPE_TRL,cIdTpl)
  if LstError() == PRN_DONE
    TRL->Attrib := strtran(trim(TRL->Attrib),TRLATTR_P) + TRLATTR_P
  endif
  unlock record
endif
SetDevise(nDecPos )
RETURN MnuDone()

#endif DEF_TRA


FUNCTION HstAuto(cIdPrt,cIdTpl)
local nMont
local lFound
static cMontMin := NIL
local cIdPar1 := space(LenIdPar())
local cIdPar2 := space(LenIdPar())
local cConfirm := BUTTON_ON
local doc
local nCount := 0
local prt
default cIdTpl to "STD"
cIdTpl := padr(cIdTpl,LenIdTpl())
default cIdPrt to PickPrt(NIL,MsgHstAuto() + "...",NIL,PRT_ID,"HSTAUTO")
RETURN .f. if (prt := PrtLocate(cIdPrt)) == NIL
default cMontMin to space(LenMont())
default sdRapDate to UserDate()
open window (MsgHstAuto() + " " + trim(strtran(prt[PRT_NAME],"~"))) ;
            size 8,50 help "HSTAUTO"
GetPreview() ; WinCr()
say "Datum "
get sdRapDate
// say " (leer = alle offenen Buchungen)"
WinCr()
say "Nur Partner "
get cIdPar1 picture PIC_ID pick PickPar(cIdPrt,cIdPar1) ;
                           postedit {|x|GetIdPar(x)}
say " bis "
get cIdPar2 picture PIC_ID pick PickPar(cIdPrt,cIdPar2) ;
                           postedit {|x|GetIdPar(x)}
WinCr()
say "Mindestbetrag : "
get cMontMin GET_MONTANT
* get nMinDebit picture "###.##"
* say " Kredit "
* get nMinCredit picture "###.##"
WinCr()
say "Druckmaske "
get cIdTpl picture PIC_ID pick PickTpl(TPLTYPE_PAR,cIdTpl)
WinCr()
get cConfirm checkbox
say " Dokumente einzeln best„tigen"
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
open area oPar(), oPlz(), oNat()
  softseek trim(cIdPar1)
  do while ! eof()
    MsgDisplay(ParName())
    if PAR->IdPrt == cIdPrt
      MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%" )
      if ! empty(cIdPar2) .and. PAR->IdPar > cIdPar2
        exit
      endif
      if TaskInter() ; exit ; endif
      * nDebit  := 0
      * nCredit := 0
      nMont := 0
      lFound := .f.
      #ifdef DEF_HST
        open area oHst()
          ddSetOrder(ORD_HST_PARDATE)
          softseek PAR->IdPar
          do while ! eof() .and. HST->IdPar == PAR->IdPar
            if empty(HST->Satis)
              if ! empty(sdRapDate)
                if (doc := DocInfo(HST->IdJnl,HST->IdDoc,HST->Line)) != NIL
                  if doc[DOC_ECHE] > sdRapDate
                    skip
                    loop
                  endif
                endif
              endif
              if HST->DC == prt[PRT_DC] // [960717] PAR->DC // DC_DEBIT
                nMont  += val(HST->Mont)
              else
                nMont += val(HST->Mont)
              endif
              lFound := .t.
            endif
            skip
          enddo
        close area
      #endif DEF_HST
      #ifdef DEF_IMP
        open area oMvi()
          ddSetOrder(ORD_MVI_PARDATE)
          softseek PAR->IdPar
          do while ! eof() .and. MVI->IdPar == PAR->IdPar
            if ! empty(MVI->MontUs)
              if ! empty(sdRapDate)
                if (doc := DocInfo(MVI->IdJnl,MVI->IdDoc,MVI->Line)) != NIL
                  if doc[DOC_ECHE] > sdRapDate
                    loop
                  endif
                endif
              endif
              if MVI->DC == prt[PRT_DC] // PAR->DC // DC_DEBIT
                nMont  += val(MVI->Mont)
              else
                nMont += val(MVI->Mont)
              endif
              lFound := .t.
            endif
            skip
          enddo
        close area
      #endif DEF_IMP
      select PAR
      * if nDebit > nMinDebit .or. nCredit > nMinCredit
      if lFound
        if nMont > val(cMontMin)
          if ! PARATTR_M $ PAR->Attrib
            // Hier wie ParPrint()
            if cConfirm == BUTTON_OFF .or. Confirm( ;
              "Kontoauszug fr " + trim(ParName()) , ;
              "Dokument drucken (J/N) ?", ;
              MSG_YES, "WRN013" ;
            )
              SetTplLang(PAR->Langue)
              PrintTemplate(TPLTYPE_PAR,cIdTpl,SetPreview())
            endif
          endif
        endif
      endif
    endif
    skip
  enddo
close area
RETURN NIL

FUNCTION MsgHstAuto()
#ifdef LG_GERMAN
RETURN "Kontoauszge drucken"
#else
RETURN "Imprimer extraits de compte"
#endif



**
** LsyPrint()
**
*FUNCTION LsyPrint(cIdTpt) // ,cIdTpl,cTitle) [960703]
*local bTitBlock
*local cTitle := TptName(cIdTpt)
*static scIdTpl := NIL
*local cIdTpl := PickTpl(cIdTpt,scIdTpl,MemLang1,NIL,cTitle)
*RETURN NIL if cIdTpl == NIL
*cTitle := TplValue(cIdTpt,cIdTpl,{||trim(TPL->Name)})
*scIdTpl := cIdTpl
*open window (cTitle) size 4,50 help (trim(cIdTpl))
*GetPreview()
*nKey := ReadScr()
*close window
*RETURN NIL if nKey == K_ESC
*bTitBlock := {|| ;
*  PrintHeader( cTitle ) ;
*}
*PrintTemplate(cIdTpt,cIdTpl,SetPreview(),bTitBlock)
*RETURN NIL

#ifdef DEF_CTT

FUNCTION CttBase(cParam) ; RETURN CttValue(1,cParam)
FUNCTION CttTaxe(cParam) ; RETURN CttValue(2,cParam)

FUNCTION CttValue(nWhat,cParam)
local nValue := 0
local nMont
local jnl
open area oCtt()
  go top
  softseek trim(MemPer1)
  do while ! eof() // .and. LstContinue()
    if TaskInter()
      LstError(PRN_ABORT)
      exit
    endif
    if ! empty(MemPer2)
      if CTT->Periode > MemPer2
        exit
      endif
    endif
    if (jnl := JnlLocate(CTT->IdJnl)) != NIL
      if &cParam
        if nWhat == 1
          nMont := val(CTT->Base)
        else
          nMont := val(CTT->Taxe)
        endif
        ** if CTT->DC != jnl[JNL_DC] war nicht gut, denn
        ** wenn NC in einem eigenen Journal stehen,
        ** muss es ja auch gehen
        if CTT->DC != CtrDC(jnl[JNL_IDCTR])
          nMont := - nMont
        endif
        nValue += nMont
      endif
    endif
    skip
  enddo
close area
RETURN nValue

FUNCTION CttList(cParam)
local cLine
local nPos
local jnl
local cFilter := ""
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
if empty(cParam)
  cParam := "{= CTT->Periode}"
  cParam += " {= CTT->IdJnl}"
  cParam += " {= CTT->DC}"
  cParam += " {= CTT->IdCtr}"
  cParam += " {= CTT->IdTax}"
  cParam += " {= CTT->IdCtf}"
  cParam += " {= CTT->Base}"
  cParam += " {= CTT->Taxe}"
  cParam += CR_LF
endif
open area oCtt()
  go top
  do while ! eof()
    if (jnl := JnlLocate(CTT->IdJnl)) != NIL
      if ChkPeriode(CTT->Periode) == 0
        if empty(cFilter) .or. &cFilter
          TplParse(OhneAnf(cParam))
          * cLine := CTT->IdJnl
          * cLine += " " + CTT->Periode
          * cLine += " " + CTT->DC
          * cLine += " " + CTT->IdCtr
          * cLine += " " + CTT->IdTax
          * cLine += " " + CTT->IdCtf
          * cLine += " " + CTT->Base
          * cLine += " " + CTT->Taxe
          * PrintLine(cLine)
        endif
      endif
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_CTT

#ifdef DEF_GEN

**
** {ctg d}
** {ctg c}
** {ctg sd}
** {ctg sc}
**
FUNCTION CtgValue(cFormat,cParam,xlFilter)
local nDebit := 0
local nCredit := 0
local jnl
local nPos := at(" ",cParam)
local cParam1
local cIdGen1
local cIdGen2
local nLen
local cPeriode := NIL
default xlFilter to ".t."
if nPos == 0
  cParam1 := cParam
else
  cParam1 := left(cParam,nPos-1)
  cParam := substr(cParam,nPos+1)
  if (nPos := at("/periode ",cParam)) != 0
    cPeriode := substr(cParam,nPos + 9)
    cParam   := alltrim(left(cParam,nPos-1))
  endif
endif
if (nPos := at("-",cParam1)) == 0
  cIdGen1 := cIdGen2 := cParam1
else
  cIdGen1 := left(cParam1,nPos-1)
  cIdGen2 := substr(cParam1,nPos+1)
endif
if cPeriode != NIL
  GsbPeriode(cPeriode)
endif
if cIdGen1 == "*" ; cIdGen1 := space(LenIdGen()) ; endif
if cIdGen2 == "*" ; cIdGen2 := repl("9",LenIdGen()) ; endif
if len(cIdGen1) != len(cIdGen2)
  Warning(cIdGen1 + "-" + cIdGen2 + " : len1 != len2")
  RETURN 0
endif
nLen := len(cIdGen1)
open area oCtg()
  ddSetOrder(ORD_CTG_PER)
  cPeriode := MemPer1
  do while cPeriode <= MemPer2
    softseek cPeriode + trim(cIdGen1)
    do while ! eof() .and. CTG->Periode == cPeriode .and. LstContinue()
      if TaskInter() ; LstError(PRN_ABORT) ; exit ; endif
      if ! empty(cIdGen2)
        if CTG->IdGen > cIdGen2
          exit
        endif
      endif
      if len(trim(CTG->IdGen)) == nLen
        if &xlFilter
          nDebit  += val(CTG->Debit)
          nCredit += val(CTG->Credit)
        endif
      endif
      skip
    enddo
    cPeriode := NextId(cPeriode)
  enddo
close area
RETURN dcton(nDebit,nCredit,cFormat)

FUNCTION dcton(nDebit,nCredit,cFormat)
if left(cFormat,1) == "S"
  cFormat := substr(cFormat,2)
  RETURN (nDebit-nCredit) if cFormat == DC_DEBIT
  RETURN (nCredit-nDebit) if cFormat == DC_CREDIT
else
  RETURN (nDebit) if cFormat == DC_DEBIT
  RETURN (nCredit) if cFormat == DC_CREDIT
endif
Warning("Invalid DCS format " + cFormat)
RETURN 0

**
**
FUNCTION GenList(cParam)
local nDebit := 0
local nCredit := 0
local jnl
local nPos := at(" ",cParam)
local cParam1
local cIdGen1
local cIdGen2
local nLen
local cPeriode := NIL
local cFilter := ".t."
if nPos == 0
  cParam1 := cParam
else
  cParam1 := left(cParam,nPos-1)
  cParam := substr(cParam,nPos+1)
  if (nPos := at("/periode ",cParam)) != 0
    cPeriode := substr(cParam,nPos + 9)
    cParam   := alltrim(left(cParam,nPos-1))
  endif
  if (nPos := at("/filter ",cParam)) != 0
    cFilter  := substr(cParam,nPos + 8)
    cParam   := alltrim(left(cParam,nPos-1))
  endif
endif
if (nPos := at("-",cParam1)) == 0
  cIdGen1 := cIdGen2 := cParam1
else
  cIdGen1 := left(cParam1,nPos-1)
  cIdGen2 := substr(cParam1,nPos+1)
endif
if cPeriode != NIL
  GsbPeriode(cPeriode)
endif
if cIdGen1 == "*" ; cIdGen1 := space(LenIdGen()) ; endif
if cIdGen2 == "*" ; cIdGen2 := repl("9",LenIdGen()) ; endif
if len(cIdGen1) != len(cIdGen2)
  Warning(cIdGen1 + "-" + cIdGen2 + " : len1 != len2")
  RETURN NIL
endif
nLen := len(cIdGen1)
open area oGen()
  softseek trim(cIdGen1)
  do while ! eof() .and. LstContinue()
    if TaskInter() ; LstError(PRN_ABORT) ; exit ; endif
    if ! empty(cIdGen2)
      if GEN->IdGen > cIdGen2
        exit
      endif
    endif
    if &cFilter
      TplParse(cParam)
    endif
    skip
  enddo
close area
RETURN NIL

FUNCTION GenCtgMont(cFormat,cIdGen,cPer1,cPer2)
local nDebit  := 0
local nCredit := 0
default cPer1 to MemPer1
default cPer2 to MemPer2
* RETURN 0 if ! LstContinue()
open area oCtg()
  softseek cIdGen + cPer1
  do while ! eof() .and. CTG->IdGen == cIdGen ;
                   .and. CTG->Periode <= cPer2
    if ChkPeriode(CTG->Periode,cPer1,cPer2) == 0 // ... wegen der CHR_255...
      nDebit  += val(CTG->Debit)
      nCredit += val(CTG->Credit)
    endif
    skip
  enddo
close area
RETURN dcton(nDebit,nCredit,cFormat)

FUNCTION GenCtgExist(cIdGen)
local lOkay := .f.
open area oCtg()
  softseek cIdGen
  if ! eof() .and. CTG->IdGen == cIdGen
    lOkay := .t.
  endif
close area
RETURN lOkay

#endif DEF_GEN

#ifdef DEF_ART
#ifdef DEF_VEN

**
** {cts qty}
** {cts montant}
**
FUNCTION CtsValue(nWhat,cParam)
local cQteForm := " "
local nMont := 0
local nMontR := 0
local nQte  := 0
local jnl
local cParam1
local cIdArt1
local cIdArt2
local nLen
local cPeriode := NIL
local cFilter := ".t."
local nPos := at(" ",cParam)
if nPos == 0
  cParam1 := cParam
else
  cParam1 := left(cParam,nPos-1)
  cParam := substr(cParam,nPos+1)
  if (nPos := at("/periode ",cParam)) != 0
    cPeriode := substr(cParam,nPos + 9)
    cParam   := alltrim(left(cParam,nPos-1))
  endif
  if ! empty(cParam)
    cFilter := cParam
  endif
endif
if (nPos := at("-",cParam1)) == 0
  cIdArt1 := cIdArt2 := cParam1
else
  cIdArt1 := left(cParam1,nPos-1)
  cIdArt2 := substr(cParam1,nPos+1)
endif
if cPeriode != NIL
  GsbPeriode(cPeriode)
endif
if cIdArt1 == "*" ; cIdArt1 := space(LenIdArt()) ; endif
if cIdArt2 == "*" ; cIdArt2 := repl(CHR_255,LenIdArt()) ; endif
if len(cIdArt1) != len(cIdArt2)
  Warning("{cts xxxxx} : len1 != len2")
  RETURN repl("?",LenMntF())
endif
nLen := len(cIdArt1)
open area oCts()
  softseek trim(cIdArt1)
  do while ! eof()
    if CTS->IdArt > cIdArt2
      exit
    endif
    if ChkPeriode(CTS->Periode) == 0
      if &cFilter
        nMont  += val(CTS->Mont)
        * nMontR += val(CTS->MontR)
        nQte   += qton(CTS->Qte)
      endif
    endif
    skip
  enddo
close area
RETURN ntomf(nMont) if nWhat == 2
RETURN ntoq(nQte,cQteForm)


#endif DEF_VEN
#endif DEF_ART



#ifdef DEF_HOLZ

**
** PrjStmList()
**
FUNCTION PrjStmList(xlFilter,cParam)
local cFilter := ""
local nPos
local lDialog := .f.
static cIdArt
static cIdStm1
static cIdStm2
static cOhneKlein := BUTTON_OFF
static cNurKlein := BUTTON_OFF
static cOhneVerkauft := BUTTON_OFF
static cNurVerkauft := BUTTON_OFF
default cIdArt to space(LenIdart())
default xlFilter to ".t."
if (nPos := at("/dialog",cParam)) != 0
  lDialog := .t.
  cParam := alltrim(left(cParam,nPos-1))
endif
if cIdStm1 == NIL .or. ! lDialog
  cIdStm1 := space(LenIdStm())
  cIdStm2 := space(LenIdStm())
  cOhneKlein := BUTTON_OFF
  cNurKlein := BUTTON_OFF
  cOhneVerkauft := BUTTON_OFF
  cNurVerkauft := BUTTON_OFF
  cIdArt       := space(LenIdArt())
endif
if lDialog
  open window (trim(PRJ->Name1) + " : Holzliste") size 8,50
  say "Stammnummer von "
  get cIdStm1 postedit {|x| GetIdStm(x)}
  say " bis "
  get cIdStm2 postedit {|x| GetIdStm(x)}
  WinCr() ; get cOhneKlein    checkbox ; say " ohne Kleinholz"
  WinCr() ; get cNurKlein     checkbox ; say " nur Kleinholz"
  WinCr() ; get cOhneVerkauft checkbox ; say " ohne verkaufte"
  WinCr() ; get cNurVerkauft  checkbox ; say " nur verkaufte"
  WinCr() ; say "Nur Holz-Art "
  get cIdArt picture PIC_ID pick PickArt()
  nKey := ReadScr()
  close window
  if nKey == K_ESC
    LstError(PRN_ABORT)
    RETURN NIL
  endif
  if empty(cOhneKlein+cNurKlein+cOhneVerkauft+cNurVerkauft)
    scPrjStmText := "(alle)"
  else
    scPrjStmText := ""
    if cOhneKlein == BUTTON_ON
      scPrjStmText += " ohne Kleinholz "
    endif
    if cNurKlein == BUTTON_ON
      scPrjStmText += " nur Kleinholz "
    endif
    if cOhneVerkauft == BUTTON_ON
      scPrjStmText += " ohne verkaufte "
    endif
    if cNurVerkauft == BUTTON_ON
      scPrjStmText += " nur verkaufte "
    endif
    if ! empty(cIdArt)
      scPrjStmText += " nur " + trim(cIdArt)
    endif
  endif
endif
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
saCls := {}
snCurrentCls := 0
open area oStm(), oArt()
  ddSetOrder(ORD_STM_PRJ)
  softseek PRJ->IdPrj + trim(cIdStm1)
  do while ! eof() .and. STM->IdPrj == PRJ->IdPrj
    seek STM->IdArt in ART
    if &xlFilter
    if empty(cFilter) .or. (&cFilter)
      if ! empty(cIdStm2)
        if STM->IdStm > cIdStm2
          exit
        endif
      endif
      if cNurKlein == BUTTON_OFF .or. STMATTR_K $ STM->Attrib
        if cOhneKlein == BUTTON_OFF .or. ! STMATTR_K $ STM->Attrib
          if cOhneVerkauft == BUTTON_OFF .or. STM->IdJnl != "VKL"
            if cNurVerkauft == BUTTON_OFF .or. STM->IdJnl == "VKL"
              if empty(cIdArt) .or. STM->IdArt == cIdArt
                TplParse(OhneAnf(cParam))
                StmClsCollect(saCls)
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
asort(saCls,NIL,NIL,{|x,y| x[CLSLIST_IDART]+x[CLSLIST_IDCLS] < y[CLSLIST_IDART] + y[CLSLIST_IDCLS]})
RETURN NIL

FUNCTION PrjStmText ; RETURN scPrjStmText

FUNCTION PrjClsList(cParam)
local i
open area oArt()
  for i := 1 to len(saCls)
    seek saCls[i][CLSLIST_IDART] in ART
    snCurrentCls := i
    TplParse(OhneAnf(cParam))
  next i
  snCurrentCls := 0
  if len(saCls) > 1
    seek padr("_SUM",LenIdArt()) in ART
    TplParse("{etc line}")
    TplParse(OhneAnf(cParam))
  endif
close area
RETURN NIL

FUNCTION ClsItem(nParam)
local i
local nSum := 0
if snCurrentCls == 0
  RETURN padr("_SUM",LenIdArt()) if nParam == CLSLIST_IDART
  RETURN NIL if nParam == CLSLIST_IDCLS
  for i := 1 to len(saCls)
    nSum += saCls[i][nParam]
  next i
  RETURN nSum
endif
RETURN saCls[snCurrentCls][nParam]

FUNCTION ClsQtm()
RETURN NIL if snCurrentCls == 0
RETURN NIL if saCls[snCurrentCls][CLSLIST_COUNT] == 0
RETURN ntoq(saCls[snCurrentCls][CLSLIST_MENGE]/saCls[snCurrentCls][CLSLIST_COUNT],ART->QteForm)


#endif DEF_HOLZ

#ifdef DEF_PIN

**
** PrjPinList()
**
FUNCTION PrjPinList(cParam)
local cFilter := ".t."
local nPos
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
open area oPin()
  ddSetOrder(ORD_PIN_IDPRJ)
  softseek PRJ->IdPrj
  do while PIN->IdPrj == PRJ->IdPrj .and. ! eof() .and. LstContinue()
    if empty(cFilter) .or. (&cFilter)
      TplParse(OhneAnf(cParam))
    endif
    skip
  enddo
close area
RETURN NIL


**
** PinList()
**
FUNCTION PinList(cParam)
local cFilter := ".t."
local nPos
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
open area oPin(), oPrj()
  go top
  do while ! eof() .and. LstContinue() .and. ! TaskInter()
    seek PIN->IdPrj in PRJ
    if empty(cFilter) .or. (&cFilter)
      TplParse(OhneAnf(cParam))
    endif
    skip
  enddo
close area
RETURN NIL


#endif DEF_PIN

#ifdef DEF_ART

**
** ArtPrint()
**
FUNCTION ArtPrint(cIdTpl,cPreview)
static scIdTpl
local tpl
if cIdTpl == NIL
  RETURN .f. if (tpl := PickTpl( ;
    TPLTYPE_ART,scIdTpl, MemLang1, ;
    {|| TplInfo() }, "Artikel " + ART->IdArt + " drucken" ;
  )) == NIL
  scIdTpl := tpl[TPL_IDTPL]
else
  SetTplLang(MemLang1)
  RETURN .f. if (tpl := TplValue(TPLTYPE_ART,cIdTpl,{|| TplInfo()})) == NIL
endif
SetDlgTitle(tpl[TPL_NAME])
* if ! empty(tpl[TPL_IDDLG])
*   RETURN .f. if ! DlgExec(tpl[TPL_IDDLG])
* endif
if OpenPrinter( ;
    tpl[TPL_IDOPT],cPreview,tpl[TPL_WIDTH], ;
    NIL,NIL,NIL,tpl[TPL_IDDLG] ;
  )
  p_MsgDisplay(tpl[TPL_NAME])
  TplParse(tpl[TPL_MEMO])
  ClosePrinter()
endif
RETURN .t.

#endif DEF_ART

#ifdef DEF_GRA

**
** GraPrint()
**
FUNCTION GraPrint(cTitle)
static scIdTpl
local tpl := PickTpl( ;
  TPLTYPE_GRA,scIdTpl, MemLang1, ;
  {|| TplInfo() }, cTitle ;
)
RETURN NIL if tpl == NIL
#ifdef LG_GERMAN
default cTitle to "Artikelgruppe drucken"
#else
default cTitle to "Imprimer Groupe d'articles"
#endif
SetDlgTitle(tpl[TPL_NAME])
if OpenPrinter( ;
    tpl[TPL_IDOPT],NIL,tpl[TPL_WIDTH], ;
    NIL,NIL,NIL,tpl[TPL_IDDLG] ;
  )
  scIdTpl := tpl[TPL_IDTPL]
  p_MsgDisplay(tpl[TPL_NAME])
  TplParse(tpl[TPL_MEMO])
  ClosePrinter()
endif
RETURN MnuDone()

**
** GraArtList()
**
FUNCTION GraArtList(cParam)
local cFilter := ""
local nMont
local doc
local nPos
local cIdGra := GRA->iGra
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
open area oArt()
  ddSetOrder(ORD_ART_GRA)
  softseek cIdGra
  do while ART->iGra == cIdGra .and. ! eof() .and. LstContinue()
    if empty(cFilter) .or. (&cFilter)
      TplParse(OhneAnf(cParam))
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_GRA

#ifdef DEF_PSC

**
** ParPscList()
**
FUNCTION ParPscList(cParam)
local cFilter := ""
local nMont
local doc
local nPos
local cIdPar := PAR->IdPar
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
open area oPsc(), oPar()
  ddSetOrder(ORD_PSC_PAR1)
  softseek cIdPar
  do while PSC->IdPar == cIdPar .and. ! eof() .and. LstContinue()
    if empty(cFilter) .or. (&cFilter)
      seek PSC->IdPar2 in PAR
      TplParse(OhneAnf(cParam))
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_PSC

#ifdef DEF_PRJ

**
** PrjList()
**
FUNCTION PrjList(cParam)
local nPos
local cFilter := ".t."
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
open area oPrj(), oPar(), oPlz(), oNat()
  go top
  do while ! eof() .and. LstContinue()
    seek PRJ->IdPar in PAR
    if &cFilter
      TplParse(OhneAnf(cParam))
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_PRJ

FUNCTION HstDate ; RETURN sdRapDate


#ifdef DEF_ALA

**
** ArtAlaList()
**
FUNCTION ArtAlaList(p)
local cFilter := NIL // "empty(ALA->Satis)"
local nMont
local doc
local nPos
local cIdArt := ART->IdArt
if (nPos := at("/filter ",p)) != 0
  cFilter := alltrim(substr(p,nPos+8))
  p := alltrim(left(p,nPos-1))
endif
p := OhneAnf(p)
open area oAla(), oArt(), oGra()
  ddSetOrder(ORD_ALA_ART1)
  softseek cIdArt
  do while ALA->IdArt1 == cIdArt .and. ! eof() .and. LstError() != PRN_ABORT
    if empty(cFilter) .or. (&cFilter)
      seek ALA->IdArt2 in ART
      #ifdef DEF_GRA
        seek ART->iGra in GRA
      #endif DEF_GRA
      TplParse(p)
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_ALA

#ifdef DEF_ACF

**
** ArtAcfList()
**
FUNCTION ArtAcfList(p)
local cFilter := NIL // "empty(ACF->Satis)"
local nPos
local nCount := 0
local nMaxCount := 0
local cIdArt := ART->IdArt
if (nPos := at("/count ",p)) != 0
  nMaxCount := val(substr(p,nPos+7))
  p := alltrim(left(p,nPos-1))
endif
if (nPos := at("/filter ",p)) != 0
  cFilter := alltrim(substr(p,nPos+8))
  p := alltrim(left(p,nPos-1))
endif
p := OhneAnf(p)
open area oAcf(), oPar()
  ddSetOrder(ORD_ACF_ART)
  softseek cIdArt
  do while ACF->IdArt == cIdArt .and. ! eof() .and. LstError() != PRN_ABORT
    if empty(cFilter) .or. (&cFilter)
      seek ACF->IdPar in PAR
      nCount++
      TplParse(p)
      if nMaxCount != 0 .and. nCount >= nMaxCount
        exit
      endif
    endif
    skip
  enddo
close area
RETURN NIL

**
** ArtAcfValue()
**
FUNCTION ArtAcfValue(p)
local cFilter := NIL // "empty(ACF->Satis)"
local nPos
local cIdArt := ART->IdArt
if (nPos := at("/filter ",p)) != 0
  cFilter := alltrim(substr(p,nPos+8))
  p := alltrim(left(p,nPos-1))
endif
p := OhneAnf(p)
open area oAcf(), oPar()
  ddSetOrder(ORD_ACF_ART)
  softseek cIdArt
  do while ACF->IdArt == cIdArt .and. ! eof() .and. LstContinue()
    if empty(cFilter) .or. (&cFilter)
      seek ACF->IdPar in PAR
      TplParse(p)
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_ACF

#ifdef DEF_PRESTO

FUNCTION ParTrmList(cIdPar,cParam)
local nPos
local cFilter := ".t."
local xaSum
sdTrmDate := NIL
saTrmSum := {}
if (nPos := at("/sum ",cParam)) != 0
  xaSum := alltrim(substr(cParam,nPos+5))
  cParam := alltrim(left(cParam,nPos-1))
endif
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
open area oTrm(), oPar(), oTac(), oPrj()
  ddSetOrder(ORD_TRM_PAR)
  softseek cIdPar
  do while ! eof() .and. TRM->IdPar == cIdPar .and. LstContinue()
    seek TRM->IdTac in TAC
    if TrmChkFilter() // &scTrmFilter
      if &cFilter
        if ! empty(xaSum)
          aCollect(saTrmSum,&xaSum)
        endif
        TplParse(cParam)
        sdTrmDate := TRM->Date
      endif
    endif
    skip
  enddo
close area
RETURN NIL


FUNCTION TrmChkFilter()
RETURN .f. if TRMATTR_H $ TRM->Attrib
if ! empty(sdTrmDate1)
  RETURN .f. if TRM->Date < sdTrmDate1
endif
if ! empty(sdTrmDate2)
  RETURN .f. if TRM->Date > sdTrmDate2
endif
RETURN .t.

FUNCTION TrmDate1 ; RETURN sdTrmDate1
FUNCTION TrmDate2 ; RETURN sdTrmDate2

FUNCTION TrmList(cParam)
local dDate
sdTrmDate := NIL
saTrmSum := {}
open area oTrm(), oPar(), oTac()
  softseek dtos(UserDate())
  dDate := NIL
  do while ! eof()
    TplParse(cParam)
    skip
  enddo
close area
RETURN NIL

FUNCTION TrmSameDate()
RETURN .f. if sdTrmDate == NIL
RETURN (TRM->Date == sdTrmDate)

**
** TrmDlgList()
**
FUNCTION TrmDlgList(cTitle,cIdTpl,cIdPrt)
local lFound
local lOkay := .t.
static cIdPar1
static cIdPar2
default sdTrmDate1 to SkipMonth(FirstOfMonth(UserDate()),-1)
default sdTrmDate2 to LastOfMonth(sdTrmDate1)
default cIdPar1 to space(LenIdPar())
default cIdPar2 to space(LenIdPar())
cIdTpl := padr(cIdTpl,LenIdTpl())
open window (cTitle) size 6,50
say "Prestations du "
get sdTrmDate1
say " au "
get sdTrmDate2
WinCr()
say "Clients de "
get cIdPar1 picture PIC_ID pick PickPar(cIdPrt,cIdPar1) ;
                           postedit {|x|GetIdPar(x)}
say " … "
get cIdPar2 picture PIC_ID pick PickPar(cIdPrt,cIdPar2) ;
                           postedit {|x|GetIdPar(x)}
WinCr()
say "Masque de document "
get cIdTpl picture PIC_ID pick PickTpl(TPLTYPE_PAR,cIdTpl)
WinCr()
GetPreview()
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
* scTrmFilter := "!'" + TRMATTR_H + "'$TRM->Attrib"
* if ! empty(sdTrmDate1)
*   scTrmFilter += ".and.dtos(TRM->Date)>='" + dtos(sdTrmDate1) + "'"
* endif
* if ! empty(sdTrmDate2)
*   scTrmFilter += ".and.dtos(TRM->Date)<='" + dtos(sdTrmDate2) + "'"
* endif
open area oPar(), oPlz(), oNat()
  softseek trim(cIdPar1)
  do while lOkay .and. ! eof()
    if ! empty(cIdPar2) .and. PAR->IdPar > cIdPar2
      exit
    endif
    lFound := .f.
    open area oTrm()
      ddSetOrder(ORD_TRM_PAR)
      softseek PAR->IdPar
      do while lOkay .and. ! eof() .and. TRM->IdPar == PAR->IdPar
        if TaskInter() ; lOkay := .f. ; exit ; endif
        if TrmChkFilter() // &scTrmFilter
          lFound := .t.
          exit
        endif
        skip
      enddo
    close area
    if lFound
      SetTplLang(PAR->Langue)
      PrintTemplate(TPLTYPE_PAR,cIdTpl,SetPreview())
      if LstError() == PRN_ABORT
        lOkay := .t. // Confirm(MsgContinue())
      endif
    endif
    if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
close area
RETURN MnuDone()

*FUNCTION aCollect(aSum,aItem)
*local i
*local j
*local a
*for i := 1 to len(aSum)
*  if aSum[i][1] == aItem[1]
*    a := aSum[i]
*  endif
*next i
*if a == NIL
*  a := aItem
*  aadd(aSum,aItem)
*else
*  for i := 2 to len(a)
*    a[i] += aItem[i]
*  next i
*endif
*RETURN NIL


#endif DEF_PRESTO


FUNCTION VnlSumList(cParam)
for snTrmSumItem := 1 to len(saTrmSum)
  TplParse(cParam)
next snTrmSumItem
snTrmSumItem := 0
RETURN NIL

FUNCTION VnlSumValue(nField,cKey)
local nReturn
if snTrmSumItem == 0
  for snTrmSumItem := 1 to len(saTrmSum)
    if saTrmSum[snTrmSumItem][1] == cKey
      nReturn := saTrmSum[snTrmSumItem][nField]
      snTrmSumItem := 0
      RETURN nReturn
    endif
  next snTrmSumItem
  snTrmSumItem := 0
  RETURN 0
endif
RETURN saTrmSum[snTrmSumItem][nField]




*#ifdef DEF_BIL
*...
*
***
*** BilGenList()
***
*FUNCTION BilGenList(cParam)
*local cFilter := ""
*local nPos
*if (nPos := at("/filter ",cParam)) != 0
*  cFilter := alltrim(substr(cParam,nPos+8))
*  cParam := alltrim(left(cParam,nPos-1))
*endif
*open area oGen()
*  ddSetOrder(ORD_GEN_BIL)
*  softseek PRJ->IdPrj + trim(cIdStm1)
*  do while ! eof() .and. STM->IdPrj == PRJ->IdPrj
*    if empty(cFilter) .or. (&cFilter)
*      TplParse(OhneAnf(cParam))
*    endif
*    skip
*  enddo
*close area
*RETURN NIL

#ifdef DEF_VNA

**
** VnaList()
**
FUNCTION VnaList(nOrder,cParam)
local nPos
local cFilter := ".t."
local lParse := .f.
local xaSum
if (nPos := at("/sum ",cParam)) != 0
  xaSum := alltrim(substr(cParam,nPos+5))
  cParam := alltrim(left(cParam,nPos-1))
endif
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
if (nPos := at("/parse",cParam)) != 0
  lParse := .t.
  cParam := alltrim(left(cParam,nPos-1))
endif
default nOrder to 1
saTrmSum := {}
saMvt := {}
cParam := OhneAnf(cParam)
open area oVna(), oPar(), oArt()
  ddSetOrder(nOrder)
  go top
  do while ! eof()
    seek VNA->IdArt in ART
    seek VNA->IdPar in PAR
    if &cFilter
      if ! empty(xaSum)
        aCollect(saTrmSum,&xaSum)
      endif
      if lParse
        TplParse(StrParse(cParam))
      else
        TplParse(cParam)
      endif
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_VNA

#ifdef DEF_RUN

**
** RalPrint()
**
FUNCTION RalPrint()
local cIdTpl := PickTpl(TPLTYPE_RAL,RAL->IdTpl,NIL,NIL,"Imprimer course...")
RETURN .f. if cIdTpl == NIL
PrintTemplate(TPLTYPE_RAL,cIdTpl)
RETURN .t.

**
** PosPrint()
**
FUNCTION PosPrint()
static cIdTpl := NIL
cIdTpl := PickTpl(TPLTYPE_POS,cIdTpl,NIL,NIL,"Imprimer position...")
RETURN .f. if cIdTpl == NIL
PrintTemplate(TPLTYPE_POS,cIdTpl)
RETURN .t.

FUNCTION PosPlace(cParam)
RETURN POS->CatPlace if empty(cParam)
RETURN POS->CatPlace if POS->IdCat $ cParam
RETURN space(len(POS->CatPlace))

**
** RalPosList()
**
FUNCTION RalPosList(nOrder,cParam)
local cFilter := NIL
local nPos
static cIdPos1 := NIL
static cIdPos2 := NIL
default cIdPos1 to space(4)
default cIdPos2 to space(4)
if (nPos := at("/filter ",cParam)) != 0
 cFilter := alltrim(substr(cParam,nPos+8))
 cParam  := alltrim(left(cParam,nPos-1))
endif
if nOrder == ORD_POS_POS
  open window ("{ral poslist" + ntrim(nOrder) + "}") size 3,40
  say "Positions "
  get cIdPos1 GET_NUM
  say " … "
  get cIdPos2 GET_NUM
  nKey := ReadScr()
  close window
  RETURN NIL if nKey == K_ESC
  default cFilter to ".t."
  if empty(cIdPos1)
    if ! empty(cIdPos2)
      cFilter += ".and.val(POS->IdPos)<=" + ltrim(cIdPos2)
    endif
  else
    if empty(cIdPos2)
      cFilter += ".and.val(POS->IdPos)>=" + ltrim(cIdPos1)
    else
      cFilter += ".and.val(POS->IdPos)>=" + ltrim(cIdPos1)
      cFilter += ".and.val(POS->IdPos)<=" + ltrim(cIdPos2)
    endif
  endif
endif
open area oPos(), oPar(), oPlz(), oNat()
  ddSetOrder(nOrder)
  set relation to POS->IdPar into PAR
  if ! empty(cFilter)
    set filter to &cFilter
  endif
  softseek RAL->IdRal
  do while ! eof() .and. POS->IdRal == RAL->IdRal .and. LstContinue()
    * seek POS->IdPar in PAR
    * if empty(cFilter) .or. &cFilter
      TplParse(OhneAnf(cParam))
    * endif
    skip
  enddo
  set filter to
  set relation to
close area
RETURN NIL


**
** {ral clblist 3 /filter PAR->Sex == "F"}
** {ral clblist 5 /filter PAR->Sex == "M"}
**
**
FUNCTION RalClbList(cParam)
local i, j
local nSum := 0
local a := {}
local clb
local nCinq
local cFilter := .t.
local nCount := 0
local nPos
local cLine
if (nPos := at("/filter",cParam)) != 0
  cFilter := substr(cParam,nPos + 8)
  cParam := left(cParam,nPos-1)
endif
nCinq := val(cParam)
open area oPos(), oPar()
  ddSetOrder(ORD_POS_TIME)
  softseek RAL->IdRal
  do while ! eof() .and. POS->IdRal == RAL->IdRal .and. LstContinue()
    seek POS->IdPar in PAR
    if trim(POS->Time) != "X"
      if &cFilter
        clb := NIL
        for i := 1 to len(a)
          if a[i][1] == POS->IdClb // 970306
            if len(a[i][2]) < nCinq
              clb := a[i]
              exit
            endif
          endif
        next i
        if clb == NIL
          clb := array(3)
          clb[1] := POS->IdClb
          clb[2] := {}
          clb[3] := 0
          aadd(a, clb)
        endif
        aadd(clb[2], val(POS->Place))
        clb[3] += val(POS->Place)
      endif
    endif
    skip
  enddo
close area
asort(a,,,{|x,y| x[3] < y[3]})
for j := 1 to len(a)
  clb := a[j]
  if len(clb[2]) == nCinq .and. ! empty(clb[1])
    nCount++
    cLine := chr(9) + str(nCount,3) + chr(9) + clb[1] + " "
    for i := 1 to len(clb[2])
      cLine += ntrim(clb[2][i])
      if i < len(clb[2])
        cLine += " + "
      endif
    next i
    cLine += " = " + ntrim(clb[3])
    PrintLine(cLine)
  endif
next j
RETURN NIL

**
** {ral equlist 3 /filter PAR->Sex == "F"}
** {ral equlist 5 /filter PAR->Sex == "M"}
**
**
FUNCTION RalEquList(cParam)
local i
local nSum := 0
local a := {}
local equ
local nCinq
local cFilter := .t.
local nCount := 0
local nPos
local cLine
if (nPos := at("/filter",cParam)) != 0
  cFilter := substr(cParam,nPos + 8)
  cParam := left(cParam,nPos-1)
endif
nCinq := val(cParam)
open area oPos(), oPar()
  ddSetOrder(ORD_POS_TIME)
  softseek RAL->IdRal
  do while ! eof() .and. POS->IdRal == RAL->IdRal .and. LstContinue()
    if trim(POS->Time) != "X"
      seek POS->IdPar in PAR
      if &cFilter
        equ := NIL
        for i := 1 to len(a)
          if a[i][1] == POS->IdEqu
            equ := a[i]
            exit
          endif
        next i
        if equ == NIL
          equ := array(2)
          equ[1] := POS->IdEqu
          equ[2] := {}
          aadd(a, equ)
        endif
        aadd(equ[2], val(POS->Place))
        if len(equ[2]) == nCinq
          nSum := 0
          nCount++
          cLine := chr(9) + str(nCount,3) + chr(9) + equ[1] + " "
          for i := 1 to len(equ[2])
            cLine += ntrim(equ[2][i])
            if i < len(equ[2])
              cLine += " + "
            endif
            nSum += equ[2][i]
          next i
          cLine += " = " + ntrim(nSum)
          PrintLine(cLine)
          equ[2] := {}
        endif
      endif
    endif
    skip
  enddo
close area
RETURN NIL


**
** {ral catposlist 10 VET}
**
**
FUNCTION CatPosList(cParam)
local i
local nSum := 0
local a := {}
local equ
local nCinq
local cFilter := .t.
local nCount := 0
local nPos
local cLine
local cIdCat := ""
if (nPos := at(" ",cParam)) != 0
  cIdCat := substr(cParam,nPos + 1)
  cParam := left(cParam,nPos-1)
endif
nCinq := val(cParam)
open area oPos(), oPar(), oPlz(), oNat()
  ddSetOrder(ORD_POS_CAT_TIME)
  softseek RAL->IdRal + cIdCat
  do while ! eof() .and. POS->IdRal == RAL->IdRal ;
                   .and. POS->IdCat == cIdCat
    if trim(POS->Time) != "X"
      seek POS->IdPar in PAR
      nCount++
      if nCount > nCinq
        exit
      endif
      cLine := chr(9) + ntrim(nCount,3)
      cLine += chr(9) + trim(ParName())
      cLine += chr(9) + alltrim(POS->IdClb)
      cLine += chr(9) + alltrim(POS->IdEqu)
      cLine += chr(9) + alltrim(POS->Time)
      ToStream(cLine+CR_LF)
    endif
    skip
  enddo
close area
RETURN NIL


**
** xcId : "POS->IdClb" or "POS->IdEqu" (or something else...)
** xnValue : "val(POS->Place)"
**
FUNCTION RalGroupList(cIdRal,xcId,xnValue,nGroupSize,xlFilter,xcName)
local i, j
local nSum := 0
local a := {}
local clb
local nCount := 0
local nPos
local cLine
local lOkay := .t.
default nGroupSize to 5
default xlFilter to ".t."
open area oPos(), oPar()
  ddSetOrder(ORD_POS_TIME)
  softseek cIdRal
  do while lOkay .and. ! eof() .and. POS->IdRal == cIdRal
    if TaskInter()
      lOkay := .f.
      exit
    endif
    if trim(POS->Time) != "X"
      seek POS->IdPar in PAR
      if xparse(xlFilter) // &cFilter
        clb := NIL
        for i := 1 to len(a)
          if a[i][1] == xparse(xcId)
            if len(a[i][2]) < nGroupSize
              clb := a[i]
              exit
            endif
          endif
        next i
        if clb == NIL
          clb := array(4)
          clb[1] := xparse(xcId)      // id
          clb[2] := {}                // collector
          clb[3] := 0                 // sum
          clb[4] := {} // collector for texts
          aadd(a, clb)
        endif
        aadd(clb[2], xparse(xnValue))
        clb[3] += xparse(xnValue) // val(POS->Place)
        if xcName != NIL
          aadd(clb[4], xparse(xcName))
        endif
      endif
    endif
    skip
  enddo
close area
RETURN NIL if ! lOkay
asort(a,,,{|x,y| x[3] < y[3]})
for j := 1 to len(a)
  clb := a[j]
  if len(clb[2]) == nGroupSize .and. ! empty(clb[1])
    nCount++
    cLine := chr(9) + str(nCount,3) + chr(9) + clb[1] + " "
    for i := 1 to len(clb[2])
      cLine += ntrim(clb[2][i])
      if xcName != NIL
        cLine += clb[4][i]
      endif
      if i < len(clb[2])
        cLine += " + "
      endif
    next i
    if xcName == NIL
      cLine += " = " + ntrim(clb[3])
    else
      cLine += chr(9) + clb[1]
      cLine += chr(9) + ntrim(clb[3])
    endif
    ToStream(cLine+CR_LF)
  endif
next j
RETURN NIL




#endif DEF_RUN



**
** PlzListe()
**
* FUNCTION PlzListe
* local aMnu := {}
* menu item MSG010 block {|| ddListing(oPlz()) } ;
*                   into aMnu
* menu item MSG113 block PlzListRue() into aMnu
* sm_Exec(aMnu,5,25,MSG029 ,CfgEditMenuColor())
* RETURN .f.




*FUNCTION PlzListRue()
*local lDetail := Confirm(MSG114) // "Liste d‚taill‚e des rues (O/N) ?")
*local cTit1 := padr("Code postal",3+1+8)
*local cTit2 := repl("Ä",3+1+8)
*cTit1 += " " + padr("Commune",28)
*cTit2 += " " + repl("Ä",28)
*cTit1 += " " + padl("#recs",5)
*cTit2 += " " + repl("Ä",5)
*cTit1 += " " + padl("#rues",5)
*cTit2 += " " + repl("Ä",5)
*open printer "LISTE" width 70 ;
*  TitBlock {|| ;
*    PrintHeader("Statistique codes postaux"), ;
*    PrintLine(cTit1) , ;
*    PrintLine(cTit2)   ;
*  }
*  ddScan( {|| PlzPrintStat(lDetail), LstContinue() } )
*close printer
*RETURN MnuDone()
*
*FUNCTION PlzPrintStat(lDetail)
*local cLine
*local i
*local aRues := {}
*local nCount := 0
*open area oPar(), oPlz(), oNat()
*  ddSetOrder(ORD_PAR_PLZ)
*  softseek PLZ->Pays + PLZ->CP
*  do while PAR->CP == PLZ->CP .and. PAR->Pays == PLZ->Pays
*    AddWord(aRues,trim(PAR->Rue))
*    nCount++
*    skip
*  enddo
*close area
*cLine := PLZ->Pays
*cLine += " " + PLZ->CP
*cLine += " " + PLZ->Nom
*cLine += " " + str(nCount,5)
*cLine += " " + str(len(aRues),5)
*PrintLine(cLine)
*if lDetail
*  if len(aRues) > 0
*    asort(aRues,NIL,NIL,{|x,y| upper(x[1]) <= upper(y[1]) })
*    PrintLine()
*    for i := 1 to len(aRues)
*      PrintLine( ;
*        space(3+1+8) + ;
*        str(aRues[i][2],5) + " x " + aRues[i][1]  ;
*      )
*    next i
*    PrintLine()
*  endif
*endif
*RETURN .T.
*
*
*FUNCTION AddWord(a,c)
*local i
*for i := 1 to len(a)
*  if a[i][1] == c
*    a[i][2] ++
*    RETURN NIL
*  endif
*next i
*aadd(a, { c, 1} )
*RETURN NIL


