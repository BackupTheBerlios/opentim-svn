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
#include "DEFDATA.CH"

**
** Table of Contents :
**
** REFRESH_METHODS - read DBF into static array
** LOCATE_METHODS  - return the identified object from static array
** VALUE_METHODS   - return one value of identified object
**
** ADD_METHODS     - add new memory object into list
**

#ifdef LG_FRENCH
  #define TIM001  "SÇlection code T.V.A."
  #define TIM002  "SÇlection CatÇgorie"
  #define TIM003  "RÇgime de facturation"
  #define TIM004  "PÇriode comptable"
  #define TIM005  "SÇlection Devise"
  #define TIM006  "DiffÇrence de paiement"
  #define TIM007  "Utilisateur"
  * #define TIM008  "Date hors pÇriode !"
  #define MSG009  " : PÇriode invalide."
  static MSG010 := " : aucune instruction d'imputation !"
  * #define MSG012  "Phase de commande"
  #define MSG013  "SÇlection journal"
  #define MSG017  " : CatÇgorie inconnue."
  * #ifdef DEF_VAR
  *   static MSG014 := " : erreur de syntaxe"
  * #endif
  #define MSG025  "SÇlection journaux"
  #ifdef DEF_TAX
    static MSG_CLJ := "code totalisateur"
  #endif DEF_TAX
#else
  #define TIM001  "Auswahl MWSt-Code"
  #define TIM002  "Steuerkategorie auswÑhlen"
  #define TIM003  "Auswahl Fakturierungsart"
  #define TIM004  "Buchungsperiode"
  #define TIM005  "Auswahl WÑhrung"
  #define TIM006  "Auswahl Zahlungsdifferenz"
  #define TIM007  "Benutzer"
  * #define TIM008  "Datum au·erhalb der Periode !"
  #define MSG009  " : unbekannte Buchungsperiode."
  static MSG010 := " : ohne Buchungsanweisung !"
  * #define MSG012  "Bestellphase"
  #define MSG013  "Auswahl Journal"
  #define MSG017  " : unbekannte Kategorie."
  * #ifdef DEF_VAR
  *   static MSG014 := " : Syntax-Fehler"
  * #endif
  #define MSG025  "Auswahl Journal(e)"
  #ifdef DEF_HST
    static MSG_CLJ := "Rechnungsbuchkolonne"
  #endif DEF_HST
#endif

#define LEN_IDPNS 1
#define LEN_IDPNA 1

#ifdef DEF_ACT
static saDbcStack := {}
#endif DEF_ACT

#ifdef DEF_RSV
  * static saTsl := NIL
  static saRst := NIL
#endif DEF_RSV

#ifdef DEF_FNA
  static saFna := NIL
#endif DEF_FNA

#ifdef DEF_RUN
  static saCat := NIL
  static saEqu := NIL
  static scCatType := ""
  static scCatList := ""
  static scSex := ""
#endif DEF_RUN

#ifdef DEF_HST
  static saClj := NIL
#endif DEF_HST

#ifdef DEF_PROVI
  static saGpr := NIL
#endif DEF_PROVI

* static saNat := NIL
static saLng := NIL
static saTlf := NIL

#ifdef DEF_DGR
  static saDgr := NIL
#endif DEF_DGR
#ifdef DEF_WWW
  static saMst := NIL
#endif DEF_WWW

#ifdef DEF_JNL
  static saJnl := NIL
  * static saPer := NIL
  static saGrj := NIL
  static saCdc := NIL
  static saIfc := NIL
#endif DEF_JNL
static saUsr := NIL
static saDif := NIL
static saPrt := NIL
static saCtr := NIL
#ifdef DEF_LGT
  static saLgt := NIL
#endif DEF_LGT
#ifdef DEF_FRF
  static saFrf := NIL
#endif DEF_FRF
#ifdef DEF_VENREMISE
  static saVnr := NIL
#endif DEF_VENREMISE
static saPra := NIL
static saMfc := NIL
static saPgp := NIL
static saIpr := NIL
static saPga := NIL
static saAlc := NIL
static saPta := NIL
#ifdef DEF_DEV
  static saDev := NIL
#endif DEF_DEV
#ifdef DEF_KVK
  static saZla := NIL
#endif DEF_KVK
#ifdef DEF_PSC
  static saPlt := NIL
#endif DEF_PSC
#ifdef DEF_ECHE
  static saEcs := NIL
#endif
#ifdef DEF_VEN
  * static saEsc := NIL
  static saFca := NIL
  * static saMdi := {}
#endif
#ifdef DEF_TAX
  static saReg := NIL
  static saTax := NIL
#endif DEF_TAX
#ifdef DEF_IPB
  static saIpb := NIL
#endif DEF_IPB
#ifdef DEF_REMISE
  static saRpp := NIL
  static saRga := NIL
#endif DEF_REMISE
#ifdef DEF_VNA
  static saTrn := NIL
#endif
#ifdef DEF_ANW
  static saAwc := NIL
#endif
#ifdef DEF_VAR
  static saVrt := NIL
#endif
#ifdef DEF_UNT
  static saUnt := NIL
#endif
#ifdef DEF_ART
  static saCta := NIL
#endif
#ifdef DEF_PRESTO
  static saAgs := NIL // agenda : status
  static saAga := NIL // agenda : lieu
#endif
#ifdef DEF_IMP
  static saSat := NIL
  static saGrb := NIL
  static saFcb := NIL
  static saSbb := NIL
  static saSrv := NIL
#endif DEF_IMP
#ifdef DEF_TRA
  static saTrt := NIL
#endif DEF_TRA
#ifdef DEF_STK
  static saStk := NIL
#endif
#ifdef DEF_VCB
  static saVcb := NIL
#endif DEF_VCB
#ifdef DEF_HOLZ
  static saCls := NIL
  static saClsType := NIL
  static snClsType := 1
  #define CLSTYPE_ID     1
  #define CLSTYPE_NAME   2
  #define CLSTYPE_ALEN   3
#endif

* #ifdef DEF_XTV
*   static saXtv := NIL
* #endif DEF_XTV

#ifdef DEF_BIBLIO
  static saOat := NIL
  static saDca := NIL
  static saDtp := NIL
  static saDst := NIL
#endif DEF_BIBLIO

#ifdef DEF_PIN
  static saPns := NIL
  static saPna := NIL
  static saPno := NIL
#endif DEF_PIN



#ifdef DEF_4LANG
  #xtranslate FIELD_MEMO4 => FIELD->Memo4
#else
  #xtranslate FIELD_MEMO4 => NIL
#endif







*#define UNT_IDUNT    1
*#define UNT_LIBELL1  2
*#define UNT_LIBELL2  3
*#define UNT_LIBELL3  4
*#define UNT_LIBELL4  5

#ifdef DEF_VEN

FUNCTION FcaRefresh
saFca := ReadArray("FCA.DBC",PRA_ALEN)
RETURN NIL

FUNCTION PickFca(cStart,cTitle)
if saFca == NIL ; FcaRefresh() ; endif
RETURN PickAttrib(saFca,cTitle + " : Attribute",cStart,"","FCA")

#endif DEF_VEN

FUNCTION PraRefresh
saPra := ReadArray("PRA.DBC",PRA_ALEN)
// aadd( saPra, { PARATTR_S, "Sammelrechnungen", 1 } )
// aadd( saPra, { PARATTR_H, "Unsichtbar      ", 1 } )
// aadd( saPra, { PARATTR_W, "Warnung         ", 1 } )
RETURN NIL

FUNCTION AlcRefresh(lEdit)
default lEdit to .f.
saAlc := ReadArray("ALC.DBC",0)
RETURN NIL

STATIC FUNCTION PgpRefresh()
saPgp := ReadArray("PGP.DBC",PGP_ALEN)
RETURN NIL

**
FUNCTION PgpLocate(cId,cIdPrt)
local i
if saPgp == NIL ; PgpRefresh() ; endif
for i := 1 to len(saPgp)
  if empty(saPgp[i][PGP_IDPRT]) .or. cIdPrt $ saPgp[i][PGP_IDPRT]
    RETURN saPgp[i] if saPgp[i][PGP_ID] == cId
  endif
next i
RETURN NIL

**
** PickPgp( [cStart] , [cIdJnl] , [cIdPrt] , [cTitle] )
**
FUNCTION PickPgp(cStart,cIdPrt)
local nStart := 0
local i
local a := {}
if saPgp == NIL ; PgpRefresh() ; endif
for i := 1 to len(saPgp)
  if cIdPrt == NIL .or. empty(saPgp[i][PGP_IDPRT]) .or. saPgp[i][PGP_IDPRT] == cIdPrt
    aadd(a, saPgp[i])
    if saPgp[i][PGP_ID] == cStart
      nStart := len(a)
    endif
  endif
next i
browse array a using {|x| ;
                      padr(x[PGP_ID],LenIdPgp()) + " " + ;
                      padr(x[PGP_NAME],40) } ;
             start nStart ;
             delete {||.f.} ;
             help "PGP" ;
             title ("Preisgruppe " + trim(PrtName(cIdPrt)))
if lastchoice() != 0
  RETURN a[LastChoice()][PGP_ID]
endif
RETURN NIL

**
FUNCTION PgpExist(cIdPgp,cIdPrt)
RETURN .t. if PgpLocate(cIdPgp,cIdPrt) != NIL
SetMsg('"' + cIdPgp + '" : unbekannte Preisgruppe fÅr ' + PrtName(cIdPrt))
RETURN .f.

**
* FUNCTION VenPgpLocate(cIdPgp,cIdPrt,cIdCtr,cIdDev)
* local i
* if saPgp == NIL ; PgpRefresh() ; endif
* for i := 1 to len(saPgp)
*   if saPgp[i][PGP_ID] == cIdPgp
*     if saPgp[i][PGP_IDCTR] == cIdCtr
*       if empty(saPgp[i][PGP_IDDEV]) .or. saPgp[i][PGP_IDDEV] == cIdDev
*         if empty(saPgp[i][PGP_IDPRT]) .or. cIdPrt $ saPgp[i][PGP_IDPRT]
*           RETURN saPgp[i]
*         endif
*       endif
*     endif
*   endif
* next i
* RETURN NIL


*FUNCTION AddMdi(cIdJnl,cIdMdi)
*** e.g. in tim.dbi:
*** do AddMdi("ACH","MDI")
*aadd(saMdi,{cIdJnl,cIdMdi})
*RETURN .t.
*
*FUNCTION VenMdiLocate()
*local i
*for i := 1 to len(saMdi)
*  if saMdi[i][1] == VEN->IdJnl
*    RETURN saMdi[i][2]
*  endif
*next i
*RETURN NIL










#ifdef DEF_VEN

STATIC FUNCTION IprRefresh()
local ipr
saIpr := {}
open area oIpr()
  go top
  do while ! eof()
    ipr := array(IPR_ALEN)
    ipr[IPR_IDCTR] := IPR->IdCtr
    ipr[IPR_IDPRT] := IPR->IdPrt
    ipr[IPR_IDPGP] := IPR->IdPgp
    ipr[IPR_IDDEV] := IPR->IdDev
    ipr[IPR_PRIXU] := trim(IPR->PrixU)
    ipr[IPR_ATTRIB] := trim(IPR->Attrib)
    aadd(saIpr,ipr)
    skip
  enddo
close area
RETURN NIL

**
** IprLocate()
**
FUNCTION IprLocate(cIdCtr,cIdPrt,cIdPgp,cIdDev)
local i
if saIpr == NIL ; IprRefresh() ; endif
for i := 1 to len(saIpr)
  if saIpr[i][IPR_IDCTR] == cIdCtr
    if empty(saIpr[i][IPR_IDPRT]) .or. saIpr[i][IPR_IDPRT] == cIdPrt
      if empty(saIpr[i][IPR_IDPGP]) .or. saIpr[i][IPR_IDPGP] == cIdPgp
        if empty(saIpr[i][IPR_IDDEV]) .or. saIpr[i][IPR_IDDEV] == cIdDev
          RETURN saIpr[i]
        endif
      endif
    endif
  endif
next i
RETURN NIL

#endif DEF_VEN

#ifdef DEF_ART

FUNCTION PgaRefresh()
saPga := ReadArray("PGA.DBC",PGA_ALEN)
RETURN NIL
**
FUNCTION PgaLocate(cId)
local i
if saPga == NIL ; PgaRefresh() ; endif
for i := 1 to len(saPga)
  RETURN saPga[i] if saPga[i][PGA_ID] == cId
next i
RETURN NIL
**
** PickPga()
**
FUNCTION PickPga(cStart,cTitle)
local nStart := 0
local i
if saPga == NIL ; PgaRefresh() ; endif
for i := 1 to len(saPga)
  if saPga[i][PGA_ID] == cStart
    nStart := i
  endif
next i
default cTitle to "Preisgruppe Artikel"
browse array saPga using {|x| ;
                         padr(x[PGA_ID],LenIdPga()) + " " + ;
                         padr(x[PGA_NAME],40) } ;
             delete {||.f.} ;
             start nStart ;
             help "PGA" ;
             title (cTitle)
if lastchoice() != 0
   RETURN saPga[LastChoice()][PGA_ID]
endif
RETURN NIL
**
FUNCTION PgaExist(cId)
RETURN .t. if PgaLocate(cId) != NIL
SetMsg(cId + " : unbekannte Preisgruppe !")
RETURN .f.
**
FUNCTION ArtPuDecPos
local pga := PgaLocate(ART->IdPga)
RETURN 2 if pga == NIL
RETURN max(val(pga[PGA_DECPOS]),DevDecPos(ArtIdDev()))

#endif DEF_ART

#ifdef DEF_REMISE

FUNCTION RgaRefresh()
saRga := ReadArray("RGA.DBC",RGA_ALEN)
RETURN NIL
**
FUNCTION RgaLocate(cId)
local i
if saRga == NIL ; RgaRefresh() ; endif
for i := 1 to len(saRga)
  RETURN saRga[i] if saRga[i][RGA_ID] == cId
next i
RETURN NIL
**
** PickRga( [cStart] , [cIdJnl] , [cIdPrt] , [cTitle] )
**
FUNCTION PickRga(cStart,cIdJnl,cIdPrt,cTitle)
local nStart := 0
local i
if saRga == NIL ; RgaRefresh() ; endif
for i := 1 to len(saRga)
  if saRga[i][RGA_ID] == cStart
    nStart := i
  endif
next i
browse array saRga using {|x| ;
                         padr(x[RGA_ID],LenIdRga()) + " " + ;
                         padr(x[RGA_NAME],40) } ;
             delete {||.f.} ;
             start nStart ;
             help "RGA" ;
             title ("Preisgruppe Artikel")
if lastchoice() != 0
   RETURN saRga[LastChoice()][RGA_ID]
endif
RETURN NIL
**
FUNCTION RgaExist(cId)
RETURN .t. if RgaLocate(cId) != NIL
SetMsg(cId + " : unbekannte Rabattgruppe !")
RETURN .f.


* **
* ** RppRefresh()
* **
* FUNCTION RppRefresh(cIdPgp)
* saRpp := {}
* open area oRpp()
*   softseek cIdPgp
*   do while ! eof() .and. RPP->IdPgp == cIdPgp
*     aadd(saRpp, {         ;
*       RPP->IdPgp,         ; // RPP_IDPGP
*       RPP->IdPga,         ; // RPP_IDPGA
*       val(RPP->Remise)    ; // RPP_REMISE
*     } )
*     skip
*   enddo
* close area
* RETURN NIL
* **
* ** RppLocate()
* **
* FUNCTION RppLocate( cIdPgp, cIdPga )
* local i
* // if saRpp == NIL ;
* RppRefresh(cIdPgp)
* // ; endif
* for i := 1 to len(saRpp)
*   if empty(saRpp[i][RPP_IDPGP]) .or. saRpp[i][RPP_IDPGP] == cIdPgp
*     if empty(saRpp[i][RPP_IDPGA]) .or. saRpp[i][RPP_IDPGA] == cIdPga
*       RETURN saRpp[i]
*     endif
*   endif
* next i
* RETURN NIL

FUNCTION RppRemise(cIdPga,cIdPgp)
local c := ""
open area oRpp()
  seek cIdPga + cIdPgp
  if eof()
    seek cIdPga + padr(left(cIdPgp,1),LenIdPgp())
  endif
  c := RPP->Remise
close area
RETURN c

**
** RpqRefresh()
**
*FUNCTION RpqRefresh()
*saRpq := {}
*open area oRpq()
*  go top
*  do while ! eof()
*    aadd(saRpq, {         ;
*      RPQ->IdRga,         ; // RPQ_IDRGA
*      RPQ->IdPgp,         ; // RPQ_IDPGP
*      RPQ->Qte,           ; // RPQ_QTE
*      val(RPQ->Remise)    ; // RPQ_REMISE
*    } )
*    skip
*  enddo
*close area
*RETURN NIL
*
***
*** RpqLocate()
***
*FUNCTION RpqLocate( cIdPgp, cIdRga, nQte )
*local i
*if saRpq == NIL ; RpqRefresh() ; endif
*for i := 1 to len(saRpq)
*  if empty(saRpq[i][RPQ_IDPGP]) .or. saRpq[i][RPQ_IDPGP] == cIdPgp
*    if empty(saRpq[i][RPQ_IDRGA]) .or. saRpq[i][RPQ_IDRGA] == cIdRga
*      if empty(saRpq[i][RPQ_QTE]) .or. nQte >= val(saRpq[i][RPQ_QTE])
*        RETURN saRpq[i]
*      endif
*    endif
*  endif
*next i
*RETURN NIL

**
** RpqRemise()
**
FUNCTION RpqRemise( cIdPgp, cIdRga, nQte )
local cRemise := ""
RETURN cRemise if empty(cIdPgp)
open area oRpq()
  softseek cIdRga + cIdPgp
  if RPQ->IdPgp == cIdPgp
    do while ! eof() .and. RPQ->IdRga == cIdRga ;
                     .and. RPQ->IdPgp == cIdPgp
      if nQte >= val(RPQ->Qte)
        cRemise := RPQ->Remise
      else
        exit
      endif
      skip
    enddo
  else
    do while ! eof() .and. RPQ->IdRga == cIdRga ;
                     .and. left(RPQ->IdPgp,1) == left(cIdPgp,1)
      if nQte >= val(RPQ->Qte)
        cRemise := RPQ->Remise
      else
        exit
      endif
      skip
    enddo
  endif
close area
RETURN cRemise

FUNCTION VnlRpqDisplay(win)
RETURN .f. if ! IsArtCode(FIELD->Code) // FIELD->Code != LNCODE_ART [960621]
RETURN .f. if ! ArtExist(FIELD->IdArt)
RETURN ArtRpqDisplay(PAR->IdPgp,win)

FUNCTION ArtRpqDisplay(cIdPgp,win)
local i
local a := {}
local cPrixU := ART->Prix1
if ! empty(ART->IdPga)
  cPrixU := ntom( ;
    val(cPrixU) * (100 - val(RppRemise(ART->IdPga,cIdPgp))) / 100, ;
    ArtPuDecPos() ;
  )
endif
open area oRpq()
  softseek ART->IdRga + cIdPgp
  if RPQ->IdPgp == cIdPgp
    do while ! eof() .and. RPQ->IdRga == ART->IdRga ;
                     .and. RPQ->IdPgp == cIdPgp
      aadd(a, {         ;
        RPQ->IdRga,         ; // RPQ_IDRGA
        RPQ->IdPgp,         ; // RPQ_IDPGP
        RPQ->Qte,           ; // RPQ_QTE
        val(RPQ->Remise)    ; // RPQ_REMISE
      } )
      skip
    enddo
  else
    do while ! eof() .and. RPQ->IdRga == ART->IdRga ;
                     .and. left(RPQ->IdPgp,1) == left(cIdPgp,1)
      aadd(a, {         ;
        RPQ->IdRga,         ; // RPQ_IDRGA
        RPQ->IdPgp,         ; // RPQ_IDPGP
        RPQ->Qte,           ; // RPQ_QTE
        val(RPQ->Remise)    ; // RPQ_REMISE
      } )
      skip
    enddo
  endif
close area
for i := 1 to win[WIN_HEIGHT]
  if i > len(a)
    if i == win[WIN_HEIGHT]
      #ifdef DEF_STK
        @ win[WIN_TOP] + i, win[WIN_LEFT] say padr(ArtQtsLine(),win[WIN_WIDTH])
      #endif DEF_STK
    else
      @ win[WIN_TOP] + i, win[WIN_LEFT] say space(win[WIN_WIDTH])
    endif
  else
    @ win[WIN_TOP] + i, win[WIN_LEFT] say padr(ArtRpqLine(a[i],cPrixU),win[WIN_WIDTH])
  endif
next i
RETURN NIL

FUNCTION VnlRpqEdit()
RETURN .f. if ! IsArtCode(FIELD->Code) // FIELD->Code != LNCODE_ART [960621]
RETURN .f. if ! ArtExist(FIELD->IdArt)
RETURN RpqEdit(ART->IdRga,PAR->IdPgp,ART->Prix1)

**
** RpqEdit()
**
FUNCTION RpqEdit(cIdRga,cIdPgp,cPrix)
local b := oRpq()
open area b
  if cIdPgp == NIL
    edit data b ;
              create {||RpqCreate(cIdRga)} ;
              key    RPQ->IdRga ;
              value  cIdRga ;
              mode edit ;
              query "RPQRGA" ;
              title ("Mengenrabatte " + cIdRga )
  else
    edit data b ;
              create {||RpqCreate(cIdRga,cIdPgp)} ;
              key    RPQ->IdRga + RPQ->IdPgp ;
              value  cIdRga + cIdPgp ;
              mode edit ;
              query "RPQPGP" ;
              title ("Mengenrabatte " + cIdRga + "/" + cIdPgp )
  endif
close area
RETURN .f. // ArtRpqBrowse(PAR->IdPgp,win,nMode)

FUNCTION RpqArtPrix(cPeriode)
local nPrix := ArtPrix1(cPeriode)
// local nPrix := val(ART->Prix1)
if ! empty(ART->IdPga)
  nPrix -= nPrix * val(RppRemise(ART->IdPga,RPQ->IdPgp)) / 100
endif
nPrix -= (nPrix * val(RPQ->Remise)) / 100
RETURN ntom(nPrix,ArtPuDecPos())

* FUNCTION VnlRpqBrowse(win,nMode)
* RETURN .f. if VNL->Code != LNCODE_ART
* RETURN .f. if ! ArtExist(VNL->IdArt)
* RETURN ArtRpqBrowse(PAR->IdPgp,win,nMode)
*
* FUNCTION ArtRpqBrowse(cIdPgp,win,nMode)
* local i
* local a := {}
* if saRpq == NIL ; RpqRefresh() ; endif
* for i := 1 to len(saRpq)
*   if empty(saRpq[i][RPQ_IDPGP]) .or. saRpq[i][RPQ_IDPGP] == cIdPgp
*     if empty(saRpq[i][RPQ_IDRGA]) .or. saRpq[i][RPQ_IDRGA] == ART->IdRga
*       aadd(a,saRpq[i])
*     endif
*   endif
* next i
* browse array a using {|x| ArtRpqLine(x) } ;
*                window (win) ;
*                mode (nMode)
* RETURN .f.

FUNCTION ArtRpqLine(rpq,cPrixU)
local cLine := rpq[RPQ_QTE]
cLine += " : " + str(rpq[RPQ_REMISE],6) + "%"
cLine += " : " + ntomf( ;
  val(cPrixU) * ( 100 - rpq[RPQ_REMISE] ) / 100, ;
  ArtPuDecPos() ;
)
cLine += " " + DevDefault(PerActive())
RETURN cLine

#ifdef DEF_STK

FUNCTION ArtQtsLine()
local cLine := ""
local i
local aStk := StkList()
for i := 1 to len(aStk)
  cLine += aStk[i][STK_IDSTK] + "=" + ltrim(&("ART->" + aStk[i][STK_IDSTK]))
  cLine += " "
next i
* open area oQts()
*   softseek ART->IdArt
*   do while ! eof() .and. QTS->IdArt == ART->IdArt
*     cLine += QTS->IdStk + "=" + ltrim(QTS->Qte) + " "
*     skip
*   enddo
* close area
RETURN cLine

#endif DEF_STK

#else

FUNCTION PickRga  ; RETURN NIL
FUNCTION RgaExist ; RETURN .t.

#endif DEF_REMISE

#ifdef DEF_PRESTO

FUNCTION AgaRefresh
saAga := ReadArray("AGA.DBC",AGA_ALEN)
RETURN NIL

#endif DEF_PRESTO

#ifdef DEF_PSC

* FUNCTION PsaRefresh
* saPsa := ReadArray("PSA.DBC",2)
* RETURN NIL

* FUNCTION PickPsa(cStart)
* if saPsa == NIL ; PsaRefresh() ; endif
* RETURN PickAttrib(saPsa,"Pin-Attribute",cStart,"","PSA")

FUNCTION PltRefresh
saPlt := ReadArray("PLT.DBC",2)
RETURN NIL

FUNCTION PickPlt(cStart)
local i
local nStart := 0
if saPlt == NIL ; PltRefresh() ; endif
for i := 1 to len(saPlt)
  if saPlt[i][PLT_IDPLT] == cStart
    nStart := i
    exit
  endif
next i
browse array saPlt ;
             using {|plt| plt[PLT_IDPLT] + " " + ;
                          padr(plt[PLT_NAME],30) ;
                   } ;
            delete {||.f.} ;
            title ("Ansprechpartnerart") ;
            start nStart ;
            help ("PLT")
RETURN NIL if lastchoice() == 0
RETURN saPlt[lastchoice()][PLT_IDPLT]

FUNCTION PltLocate(cIdPlt)
local i
if saPlt == NIL ; PltRefresh() ; endif
for i := 1 to len(saPlt)
  RETURN saPlt[i] if saPlt[i][PLT_IDPLT] == cIdPlt
next i
RETURN NIL

FUNCTION PltName(cIdPlt)
local i
local plt := PltLocate(cIdPlt)
RETURN "" if plt == NIL
RETURN plt[PLT_NAME]



#endif DEF_PSC

#ifdef DEF_PTG

FUNCTION PtaRefresh
saPta := ReadArray("PTA.DBC",2)
RETURN NIL

FUNCTION PtaName(cId)
local i
if saPta == NIL ; PtaRefresh() ; endif
for i := 1 to len(saPta)
  RETURN saPta[i][2] if saPta[i][1] == cId
next i
RETURN ""


FUNCTION PickPtlAttrib(cStart)
if saPta == NIL ; PtaRefresh() ; endif
RETURN PickAttrib(saPta,"Attribute",cStart,"","PTLATTR")

#endif DEF_PTG

#ifdef DEF_PIN

**
** PnsRefresh()
**
FUNCTION PnsRefresh(cIdPrj)
static scIdPrj := NIL
local cPrjType
RETURN NIL if scIdPrj == cIdPrj
scIdPrj := cIdPrj
* cPrjType := PrjField(cIdPrj,{||trim(PRJ->Type)})
cPrjType := DbfPeek(oPrj(),cIdPrj,"trim(PRJ->Type)","")
if empty(cPrjType)
  cPrjType := "STD"
endif
saPns := ReadArray(cPrjType + ".PNS",PNS_ALEN)
RETURN NIL

**
** PnaRefresh()
**
FUNCTION PnaRefresh(cIdPrj)
static scIdPrj := NIL
local cPrjType
RETURN NIL if scIdPrj == cIdPrj
scIdPrj := cIdPrj
cPrjType := PrjField(cIdPrj,{||trim(PRJ->Type)})
if empty(cPrjType)
  cPrjType := "STD"
endif
saPna := ReadArray(cPrjType + ".PNA",2)
RETURN NIL

**
** PnoRefresh()
**
FUNCTION PnoRefresh(cIdPrj)
static scIdPrj := NIL
RETURN NIL if scIdPrj == cIdPrj
scIdPrj := cIdPrj
saPno := ReadArray(trim(cIdPrj) + ".PNO",2)
RETURN NIL

#endif DEF_PIN

#ifdef DEF_VAR

**
** VrtRefresh()
**
FUNCTION VrtRefresh()
saVrt := {}
open area oVrt()
  go top
  do while ! eof()
    aadd(saVrt, {   ;
      VRT->IdVrt       , ;     // VRT_IDVRT
      trim(VRT->Name)  , ;     // VRT_NAME
      val(VRT->Start)  , ;     // VRT_START
      val(VRT->Len)    , ;     // VRT_LEN
      trim(VRT->Attrib), ;     // VRT_ATTRIB
      trim(VRT->Separ1), ;     // VRT_SEPAR1
      trim(VRT->Separ2)  ;     // VRT_SEPAR2
    } )
    skip
  enddo
close area
RETURN NIL


FUNCTION VrtList
if saVrt == NIL ; VrtRefresh() ; endif
RETURN saVrt

FUNCTION VrtLocate(cId)
local i
if saVrt == NIL ; VrtRefresh() ; endif
for i := 1 to len(saVrt)
  if saVrt[i][VRT_IDVRT] == cId
    RETURN saVrt[i]
  endif
next i
RETURN NIL

FUNCTION VrtName(cId)
local vrt := VrtLocate(cId)
RETURN "" if vrt == NIL
RETURN strtran(vrt[VRT_NAME],"~")

#endif DEF_VAR

#ifdef DEF_JNL

#ifdef DEF_GEN
  #xtranslate FieldIdGen()  => (FIELD->IdGen)
#else
  #xtranslate FieldIdGen()  => (NIL)
#endif

#ifdef DEF_HST
  #xtranslate FieldIdHcl()  => trim(FIELD->IdHcl)
#else
  #xtranslate FieldIdHcl()  => (NIL)
#endif

#ifdef DEF_IMP
  #xtranslate FieldIdCdc() => (FIELD->IdCdc)
#else
  #xtranslate FieldIdCdc()  => (NIL)
#endif

**
** JnlRefresh()
**
FUNCTION JnlRefresh()
local j
saJnl := {}
* MsgDisplay(MSG001) // "Lecture des journaux...")
open area oJnl()
ddSetOrder(ORD_JNL_SEQ)
go top
do while !eof()
  j := {   ;
    JNL->IdJnl,   ;           // JNL_IDJNL
    JNL->Alias,   ;           // JNL_ALIAS
    trim(JNL->Libell),  ;     // JNL_NAME
    JNL->Attrib,  ;           // JNL_ATTRIB
    JNL->IdCtr,   ;           // JNL_IDCTR
    FieldIdGen(),   ;           // JNL_IDGEN
    JNL->DC,      ;           // JNL_DC
    JNL->IdDev,   ;             // JNL_IDDEV
    trim(JNL->DocLib1),   ;     // JNL_DOCLIB1
    trim(JNL->DocLib2),   ;     // JNL_DOCLIB2
    trim(JNL->DocLib3),   ;     // JNL_DOCLIB3
    trim(JNL->DocLib1N),   ;    // JNL_DOCLIB1N
    trim(JNL->DocLib2N),   ;    // JNL_DOCLIB2N
    trim(JNL->DocLib3N),   ;    // JNL_DOCLIB3N
    JNL->Code,   ;              // JNL_LNCODE
    JNL->IdTpt, ;             // JNL_IDTPT
    JNL->IdTxt, ;             // JNL_IDTPL
    JNL->IdGrj, ;             // JNL_IDGRJ
    FieldIdCdc(), ;           // JNL_IDCDC
    trim(JNL->IdDbv), ;       // JNL_IDDBV
    trim(JNL->CodeCli), ; // JNL_CODECLI
    JNL->Compte,  ; // JNL_COMPTE
    JNL->CodeBqe, ; // JNL_CODEBQE
    val(JNL->TaxDecPos),; // JNL_TAXDECPOS
    JNL->DocAttr,       ; // JNL_DOCATTR
    FieldIdHcl(),       ; // JNL_IDHCL
    JNL->SeqType        ; // JNL_SEQTYPE
  }                     // JNL_ALEN
  #ifdef DEF_4LANG
    aadd(j,trim(JNL->DocLib4))        // JNL_DOCLIB4
    aadd(j,trim(JNL->DocLib4N))       // JNL_DOCLIB4N
  #endif
  aadd(saJnl,j)
  skip
enddo
close area
* MsgDisplay("")
RETURN NIL

**
** JnlLocate()
**
FUNCTION JnlLocate( cIdJnl )
local i
if saJnl == NIL ; JnlRefresh() ; endif
for i := 1 to len(saJnl)
  if saJnl[i][JNL_IDJNL] == cIdJnl
    RETURN saJnl[i]
  endif
next i
RETURN NIL

FUNCTION JnlName(cId)
local jnl := JnlLocate(cId)
RETURN "" if jnl == NIL
RETURN jnl[JNL_NAME]
*
FUNCTION JnlIdGrj(cId)
local jnl := JnlLocate(cId)
RETURN space(LEN_IDGRJ) if jnl == NIL
RETURN jnl[JNL_IDGRJ]
*
#ifdef DEF_IMP
  FUNCTION JnlIdCdc(cId)
  local jnl := JnlLocate(cId)
  RETURN "" if jnl == NIL
  RETURN jnl[JNL_IDCDC]
#endif DEF_IMP
*
FUNCTION JnlIdCtr(cId)
local jnl := JnlLocate(cId)
RETURN space(1) if jnl == NIL
RETURN jnl[JNL_IDCTR]
*
FUNCTION JnlAlias(cId)
local jnl := JnlLocate(cId)
RETURN space(LenIdJnl()) if jnl == NIL
RETURN jnl[JNL_ALIAS]
*
FUNCTION JnlIdTpt(cId)
local jnl := JnlLocate(cId)
RETURN "" if jnl == NIL
RETURN jnl[JNL_IDTPT]
*
FUNCTION JnlIdTpl(cId)
local jnl := JnlLocate(cId)
RETURN "" if jnl == NIL
RETURN jnl[JNL_IDTPL]
*
**
#ifdef DEF_GEN
  FUNCTION JnlIdGen(cId)
  local jnl := JnlLocate(cId)
  RETURN space(LenIdGen()) if jnl == NIL
  RETURN jnl[JNL_IDGEN]
#endif
**
FUNCTION JnlDC(cId)
local jnl := JnlLocate(cId)
RETURN space(1) if jnl == NIL
RETURN jnl[JNL_DC]
**
FUNCTION JnlIdDev(cId)
local jnl := JnlLocate(cId)
RETURN space(LEN_IDDEV) if jnl == NIL
RETURN jnl[JNL_IDDEV]
**
FUNCTION JnlSeq(cIdJnl)
local i
if saJnl == NIL ; JnlRefresh() ; endif
for i := 1 to len(saJnl)
  if saJnl[i][JNL_IDJNL] == cIdJnl
    RETURN str(i,3)
  endif
next i
RETURN space(3)
**
FUNCTION JnlIdDbv(cId)
local jnl := JnlLocate(cId)
RETURN "" if jnl == NIL
* if empty(jnl[JNL_IDDBV])
*   RETURN "FNL" if jnl[JNL_ALIAS] == "FIN"
*   RETURN "VNL" if jnl[JNL_ALIAS] == "VEN"
* endif
RETURN jnl[JNL_IDDBV]
*
**
** JnlCode()
**
FUNCTION JnlCode(cId)
local jnl := JnlLocate(cId)
if jnl == NIL
  RETURN " "
endif
RETURN jnl[JNL_LNCODE]
*
#ifdef DEF_DEV
**
** JnlNbDec()
**
FUNCTION JnlNbDec(cId)
local jnl := JnlLocate(cId)
if jnl == NIL
  RETURN 0
endif
RETURN DevDecPos(jnl[JNL_IDDEV])

FUNCTION DevTolerance(cIdDev)
RETURN Tolerance(DevDecPos(cIdDev))

#endif DEF_DEV
*
**
** JnlAttrib()
**
FUNCTION JnlAttrib(cId)
local jnl := JnlLocate(cId)
RETURN "" if jnl == NIL
RETURN jnl[JNL_ATTRIB]
*
* FUNCTION JnlIdFlt(cId)
* local jnl := JnlLocate(cId)
* RETURN "" if jnl == NIL
* RETURN jnl[JNL_IDFLT]
*
FUNCTION JnlField(cIdJnl,nField)
local jnl := JnlLocate(cIdJnl)
RETURN "" if jnl == NIL
RETURN jnl[nField]

**
** PickJnl()
**
FUNCTION PickJnl(cAlias, cStart, a, cTitle, cHelp, nItem)
local i
local nStart
if saJnl == NIL ; JnlRefresh() ; endif
default cTitle to MSG013
default cHelp to "JNLPICK"
if a == NIL
  a := {}
  for i := 1 to len(saJnl)
    if cAlias == NIL .or. saJnl[i][JNL_ALIAS] == cAlias
      aadd(a,saJnl[i])
    endif
  next i
endif
for i := 1 to len(a)
  if a[i][JNL_IDJNL] == cStart
    nStart := i
  endif
next i
browse array a ;
             using {|jnl| jnl[JNL_IDJNL] + " " + ;
                          padr(jnl[JNL_NAME],31) + jnl[JNL_IDDEV] ;
                   } ;
             delete {||.f.} ;
             title (cTitle) ;
             start nStart ;
             help (cHelp)
RETURN NIL if lastchoice() == 0
RETURN a[lastchoice()] if nItem == NIL
RETURN a[lastchoice()][nItem]

FUNCTION PickIdJnl(cAlias, cStart, a, cTitle, cHelp)
RETURN PickJnl(cAlias, cStart, a, cTitle, cHelp, JNL_IDJNL)

**
** PickJnlList()
**
FUNCTION PickJnlList(cStart,cAttrib,cAlias)
local aPick := {}
local i
if saJnl == NIL ; JnlRefresh() ; endif
for i := 1 to len(saJnl)
  if cAttrib == NIL .or. cAttrib $ saJnl[i][JNL_ATTRIB]
    aadd( aPick, ;
      { saJnl[i][JNL_IDJNL], ;
        saJnl[i][JNL_IDJNL] + " " + saJnl[i][JNL_NAME], ;
        1 ;
      } ;
    )
  endif
next i
RETURN PickAttrib( aPick, MSG025 , cStart, " ", "JNLLIST" )

**
** JnlList() - returns a list of Journaux of specified type
**             (or of all journaux)
**
FUNCTION JnlList(bTest)
local i
local aJnl := {}
if saJnl == NIL ; JnlRefresh() ; endif
for i := 1 to len(saJnl)
  if bTest == NIL .or. eval(bTest,saJnl[i])
    aadd(aJnl, saJnl[i])
  endif
next i
RETURN aJnl

**
** GRJ
**

FUNCTION GrjRefresh
saGrj := ReadArray("GRJ.DBC",GRJ_ALEN)
RETURN NIL
         
FUNCTION GrjList()
if saGrj == NIL ; GrjRefresh() ; endif
RETURN saGrj

FUNCTION GrjLocate(cId)
local i
if saGrj == NIL ; GrjRefresh() ; endif
for i := 1 to len(saGrj)
  if saGrj[i][GRJ_ID] == cId
    RETURN saGrj[i]
  endif
next i
RETURN NIL

FUNCTION GrjName(cId)
local prt := GrjLocate(cId)
RETURN "" if prt == NIL
RETURN strtran(prt[GRJ_NAME],"~")

FUNCTION PickGrj(cStart,cTitle)
local i
local nStart := 0
if saGrj == NIL ; GrjRefresh() ; endif
default cTitle to "Journalgruppe"
for i := 1 to len(saGrj)
  if saGrj[i][GRJ_ID] == cStart
    nStart := i
  endif
next i
browse array saGrj ;
             using {|grj| ;
               grj[GRJ_ID] + " " + padr(strtran(grj[GRJ_NAME],"~"),LEN_GRJNAME) ;
             } ;
             delete {||.f.} ;
             title (cTitle) ;
             help "GRJ" ;
             start nStart
RETURN NIL if LastChoice() == 0
RETURN saGrj[LastChoice()][GRJ_ID]

FUNCTION GrjAddMenu(cMnuTitle)
local i
local aJnl
if saGrj == NIL ; GrjRefresh() ; endif
MnuAddTitle(cMnutitle)
for i := 1 to len(saGrj)
  aJnl := JnlList({|jnl|jnl[JNL_IDGRJ]==saGrj[i][GRJ_ID]})
  if len(aJnl) > 0
    MnuAddItem(saGrj[i][GRJ_NAME],;
      cblock("DocEdit('"+saGrj[i][GRJ_ID]+"',MnuItemName())"))
  endif
next i
RETURN .t.

**
** IFC
**

**
** IfcRefresh()
**

FUNCTION IfcRefresh()
saIfc := {}
open area oIfc()
  go top
  do while ! eof()
      * IFC->PrtList,       ; // IFC_PRTLIST
    aadd(saIfc, {         ;
      IFC->IdCtr,         ; // IFC_IDCTR
      IFC->IdJnl  ,       ; // IFC_IDJNL
      trim(IFC->Attrib),  ; // IFC_ATTRIB
      IFC->Delai,         ; // IFC_DELAI
      IFC->IdTpl,         ; // IFC_IDTPL
      IFC->Memo1,         ; // IFC_MEMO1
      IFC->Memo2,         ; // IFC_MEMO2
      IFC->Memo3,         ; // IFC_MEMO3
      IFC->IdMfc,         ; // IFC_IDMFC
      IFC->IdReg,         ; // IFC_IDREG
      trim(IFC->Text),    ; // IFC_TEXT
      IFC->IdPar,         ; // IFC_IDPAR
      FIELD_MEMO4           ; // IFC_MEMO4
    } )
    skip
  enddo
close area
RETURN NIL

**
** IfcLocate()
**
FUNCTION IfcLocate( cIdCtr, cIdJnl, cIdMfc ) // , cIdPrt )
local i
if saIfc == NIL ; IfcRefresh() ; endif
for i := 1 to len(saIfc)
  if empty(cIdCtr) .or. saIfc[i][IFC_IDCTR] == cIdCtr
    if (left(saIfc[i][IFC_IDMFC],1)==IDMFC_ANY) .or. empty(saIfc[i][IFC_IDMFC]) .or. saIfc[i][IFC_IDMFC] == cIdMfc
      if empty(cIdJnl) .or. empty(saIfc[i][IFC_IDJNL]) .or. saIfc[i][IFC_IDJNL] == cIdJnl
        RETURN saIfc[i]
      endif
    endif
  endif
next i
RETURN NIL

FUNCTION ParMfcDefault(cIdJnl)
local jnl := JnlLocate(cIdJnl)
local i
RETURN PAR->IdMfc if jnl == NIL
RETURN PAR->IdMfc if IfcLocate(jnl[JNL_IDCTR],cIdJnl,PAR->IdMfc) != NIL
for i := 1 to len(saIfc)
  if saIfc[i][IFC_IDCTR] == jnl[JNL_IDCTR]
    if empty(saIfc[i][IFC_IDJNL]) .or. saIfc[i][IFC_IDJNL] == cIdJnl
      if ! empty(saIfc[i][IFC_IDMFC])
        RETURN saIfc[i][IFC_IDMFC]
      endif
    endif
  endif
next i
Warning(cIdJnl + utrMfcFail(),NIL,"WRN037")
RETURN space(LenIdMfc())

STATIC FUNCTION utrMfcFail()
#ifdef LG_GERMAN
RETURN " : keine Zahlart mîglich !"
#endif
#ifdef LG_FRENCH
RETURN " : aucun mode de facturation !"
#endif
#ifdef LG_EN
RETURN " : no payment method found !"
#endif


* FUNCTION IfcDate2( cIdJnl, cIdMfc, dDate )
* local ifc := IfcLocate(JnlIdCtr(cIdJnl),cIdJnl,cIdMfc)
* RETURN dDate if ifc == NIL
* dDate += val(ifc[IFC_DELAI])
* if IFCATTR_M $ ifc[IFC_ATTRIB]
*   dDate := LastOfMonth(dDate)
* endif
* RETURN dDate


**
** IFC
**
*FUNCTION IfcValue( cIdJnl, cIdMfc, nValue )
*local i
*local ifc := IfcLocate(cIdJnl,cIdMfc)
*RETURN NIL if ifc == NIL
*RETURN ifc[nValue]

#endif DEF_JNL

#ifdef DEF_IMP

**
** CDC
**
FUNCTION CdcRefresh()
saCdc := {}
open area oCdc()
  go top
  do while ! eof()
    aadd(saCdc, {        ;
      CDC->IdCdc ,       ; // CDC_IDCDC
      CDC->DC    ,       ; // CDC_DC
      CDC->Name  ,       ; // CDC_NAME
      CDC->Header ,      ; // CDC_HEADER
      trim(CDC->Expr)    ; // CDC_EXPR
    } )
    skip
  enddo
close area
RETURN NIL
**
FUNCTION CdcList(cDC,bFilter)
local i
local a := {}
if saCdc == NIL ; CdcRefresh() ; endif
for i := 1 to len(saCdc)
  if cDC == NIL .or. saCdc[i][CDC_DC] == cDC
    if bFilter == NIL .or. eval(bFilter,saCdc[i])
      aadd(a,saCdc[i])
    endif
  endif
next i
RETURN a
**
FUNCTION CdcHeader(cDC,cIdCdc)
local o := CdcLocate(cDC,cIdCdc)
RETURN space(LenMntF()) if o == NIL
RETURN o[CDC_HEADER]
**
FUNCTION CdcExpr(cDC,cIdCdc)
local o := CdcLocate(cDC,cIdCdc)
RETURN "" if o == NIL
RETURN o[CDC_EXPR]
**
FUNCTION CdcLocate(cDC,cId)
local i
if saCdc == NIL ; CdcRefresh() ; endif
for i := 1 to len(saCdc)
  if saCdc[i][CDC_IDCDC] == cId
    if saCdc[i][CDC_DC] == cDC
      RETURN saCdc[i]
    endif
  endif
next i
RETURN NIL
**
FUNCTION PickCdc(cDC,cStart,cTitle)
local i
local nStart := 0
local a := {}
if saCdc == NIL ; CdcRefresh() ; endif
default cTitle to "Zentralisierungs-Code"
for i := 1 to len(saCdc)
  if empty(cDC) .or. saCdc[i][CDC_DC] == cDC
    aadd(a, saCdc[i])
    if saCdc[i][CDC_IDCDC] == cStart
      nStart := len(a)
    endif
  endif
next i
browse array a ;
             using {|cdc| ;
               cdc[CDC_IDCDC] + " " + cdc[CDC_NAME] ;
             } ;
             delete {||.f.} ;
             title (cTitle) ;
             help "CDC" ;
             start nStart
RETURN NIL if LastChoice() == 0
RETURN a[LastChoice()][CDC_IDCDC]

#endif DEF_IMP

#ifdef DEF_ECHE

**
** EcsRefresh()
**
FUNCTION EcsRefresh()
saEcs := {}
open area oEcs()
  go top
  do while ! eof()
    aadd(saEcs, {   ;
      ECS->IdEcs   , ;     // ECS_IDECS
      ECS->Name    , ;     // ECS_NAME
      ECS->IdJnl   , ;     // ECS_IDJNL
      ECS->CptType , ;     // ECS_CPTTYPE
      ECS->Duree   , ;     // ECS_DUREE
      ECS->IdTxt   , ;     // ECS_IDTXT
      ECS->DC        ;     // ECS_DC
    } )
    skip
  enddo
close area
RETURN NIL


#endif DEF_ECHE

#ifdef DEF_TAX

**
** TaxRefresh()
**
FUNCTION TaxRefresh()
saTax := {}
open area oTax()
go top
do while !eof()
  aadd(saTax, {        ;
    TAX->IdTax,                         ; // TAX_IDTAX
    TAX->Libell,                        ; // TAX_LIBELL
    val(TAX->Taux),                     ; // TAX_TAUX
    TAX->IdCtr  ,                       ; // TAX_IDCTR
    trim(TAX->Attrib),                  ; // TAX_ATTRIB
    TAX->IdGen,                         ; // TAX_IDGEN
    TAX->GenTiers,                      ; // TAX_GENTIERS
    TAX->Memo1,                         ; // TAX_MEMO1
    TAX->Memo2,                         ; // TAX_MEMO2
    TAX->Memo3,                         ; // TAX_MEMO3
    TAX->Date,                          ; // TAX_DATE
    trim(TAX->xlValid),                 ; // TAX_VALID
    trim(TAX->RegList),                 ; // TAX_REGLIST
    FIELD_MEMO4                         ; // TAX_MEMO4
  } )
  skip
enddo
close area
RETURN NIL

* TAX->IdClj,        ;      // TAX_IDCLJ


**
** TaxLocate()
**
FUNCTION TaxLocate( cIdCtr, cId, lMsg, dDate )
local i
if saTax == NIL ; TaxRefresh() ; endif
for i := 1 to len(saTax)
  if saTax[i][TAX_IDCTR] == cIdCtr
    if saTax[i][TAX_IDTAX] == cId
      if dDate == NIL .or. saTax[i][TAX_DATE] <= dDate
        RETURN saTax[i]
      endif
    endif
  endif
next i
if lMsg
  SetMsg('"' + cId + '"' + MsgTaxExist(cIdCtr))
endif
RETURN NIL

FUNCTION MsgTaxExist(cIdCtr)
#ifdef LG_GERMAN
  RETURN " : ungÅltiger MWSt-Code fÅr " + trim(CtrName(cIdCtr)) + " !"
#else
  RETURN " : Code TVA invalide pour " + trim(CtrName(cIdCtr)) + " !"
#endif

FUNCTION TaxExist(cIdCtr,cId)
RETURN (TaxLocate(cIdCtr,cId,.t.,UserDate()) != NIL)

*FUNCTION TaxLibell(cIdCtr,cId)
*local tax := TaxLocate(cIdCtr,cId,.f.)
*if tax == NIL ; RETURN space(LEN_LIBTAX) ; endif
*RETURN tax[TAX_LIBELL]

FUNCTION TaxTaux( cIdCtr, cIdTax, dDate )
local tax := TaxLocate(cIdCtr,cIdTax,.f.,dDate)
RETURN 0 if tax == NIL
RETURN tax[TAX_TAUX]

FUNCTION TaxMemo( cIdCtr, cIdTax, cLangue, dDate )
local tax := TaxLocate(cIdCtr,cIdTax,.f.,dDate)
local cMemo := ""
RETURN "" if tax == NIL
if cLangue == MemLang3
  cMemo := tax[TAX_MEMO3]
elseif cLangue == MemLang2
  cMemo := tax[TAX_MEMO2]
#ifdef DEF_4LANG  
elseif cLangue == MemLang4
  cMemo := tax[TAX_MEMO4]
#endif  
endif
if empty(cMemo)
  cMemo := tax[TAX_MEMO1]
endif
RETURN cMemo

* FUNCTION TaxAttrib( cIdCtr, cIdTax, dDate )
* local tax := TaxLocate(cIdCtr,cIdTax,.f.,dDate)
* RETURN "" if tax == NIL
* RETURN tax[TAX_ATTRIB]

**
** PickTax()
**
FUNCTION PickTax(cStart,cIdCtr,dDate)
local i
local nStart := 0
local a := {}
if saTax == NIL ; TaxRefresh() ; endif
for i := 1 to len(saTax)
  if cIdCtr == NIL .or. saTax[i][TAX_IDCTR] == cIdCtr
    if dDate == NIL .or. saTax[i][TAX_DATE] <= dDate
      aadd(a,saTax[i])
      if saTax[i][TAX_IDTAX] == cStart
        nStart := len(a)
      endif
    endif
  endif
next i
browse array a using {|tax| ;
                       tax[TAX_IDTAX] + " " + ;
                       tax[TAX_LIBELL] + " " +;
                       tax[TAX_IDGEN]  + " " +;
                       tax[TAX_GENTIERS]  ;
                     } ;
               delete {||.f.} ;
               title TIM001 ;
               start nStart ;
               help "TAX"
RETURN NIL if lastchoice() == 0
RETURN a[lastchoice()][TAX_IDTAX]

FUNCTION TaxList
if saTax == NIL ; TaxRefresh() ; endif
RETURN saTax

FUNCTION PickTaxList(cStart)
local aPick := {}
local i
if saTax == NIL ; TaxRefresh() ; endif
for i := 1 to len(saTax)
  aadd( aPick, { ;
        saTax[i][TAX_IDTAX], ;
        saTax[i][TAX_LIBELL], ;
        1 ;
    } ;
  )
next i
RETURN PickAttrib( aPick, TIM001, cStart )

**
** RegRefresh()
**
FUNCTION RegRefresh()
saReg := {}
open area oReg()
go top
do while !eof()
  aadd(saReg, {   ;
    REG->IdReg,   ;   // REG_IDREG
    REG->Libell,  ;   // REG_LIBELL
    REG->IdTax,   ;   // REG_IDTAX
    REG->Attrib,  ;   // REG_ATTRIB
    trim(REG->Text) ; // REG_TEXT
  } )
  skip
enddo
close area
RETURN NIL

**
** RegLocate()
**
FUNCTION RegLocate( cId )
local i
if saReg == NIL ; RegRefresh() ; endif
for i := 1 to len(saReg)
  if saReg[i][REG_IDREG] == cId
    * if empty(saReg[i][REG_IDCTR]) .or. saReg[i][REG_IDCTR] == cIdCtr
      RETURN saReg[i]
    * endif
  endif
next i
RETURN NIL // { "" , "" , 0 }


FUNCTION RegIdTax(cId)
local reg := RegLocate(cId)
RETURN "" if reg == NIL
RETURN reg[REG_IDTAX]


FUNCTION RegAttrib(cId)
local reg := RegLocate(cId)
RETURN "" if reg == NIL
RETURN reg[REG_ATTRIB]



FUNCTION RegText(cIdReg)
local reg := RegLocate(cIdReg)
RETURN "" if reg == NIL
RETURN "" if empty(reg[REG_TEXT])
RETURN xparse(reg[REG_TEXT])



**
** PickReg()
**
FUNCTION PickReg(cStart)
local cReturn
local aLib := {}
local i
if saReg == NIL ; RegRefresh() ; endif
for i := 1 to len(saReg)
  aadd( aLib, ;
        saReg[i][REG_IDREG] + " " + ;
        saReg[i][REG_LIBELL] ;
  )
next i
RETURN ArrayPick( aLib, "MWSt-Regime", cStart,LEN_IDREG,"REG")

FUNCTION IdRegValidate(cIdReg)
if RegLocate(cIdReg) == NIL
  SetMsg(cIdReg + MsgRegExist())
  RETURN .f.
endif
RETURN ph_refresh()

#else

* FUNCTION TaxAttrib ; RETURN NIL

#endif DEF_TAX

#ifdef DEF_DEV

**
** DevRefresh()
**
FUNCTION DevRefresh()
saDev := {}
open area oDev()
go top
do while !eof()
  aadd(saDev, {   ;
    DEV->IdDev,   ;
    DEV->Libell,  ;
    DEV->Cours , ;        // DEV_COURS
    DEV->NbDec , ;        // DEV_DECPOS
    DEV->Cours2, ;        // DEV_COURS2
    DEV->Delta    ;       // DEV_DELTA
  } )                     // DEV_ALEN
  skip
enddo
close area
RETURN NIL

#endif DEF_DEV

#ifdef DEF_FIN

**
** DifRefresh()
**
FUNCTION DifRefresh()
saDif := {}
open area oDif()
go top
do while !eof()
  aadd(saDif, {   ;
    DIF->IdCtr,   ;        // DIF_IDCTR
    DIF->DC   ,   ;        // DIF_DC
    DIF->Libell,  ;        // DIF_NAME
    DIF->IdGen    ;        // DIF_IDGEN
  } ) // DIF_ALEN
  skip
enddo
close area
RETURN NIL

**
** TmvRefresh()
**
*FUNCTION TmvRefresh()
*saTmv := {}
*open area oTmv()
*go top
*do while !eof()
*  aadd(saTmv, {   ;
*    TMV->IdJnl,   ;    // TMV_IDJNL
*    TMV->CptType, ;    // TMV_CPTTYPE
*    TMV->IdPmv1,  ;    // TMV_IDPMV1
*    TMV->IdPmv2,  ;    // TMV_IDPMV2
*    TMV->Attrib   ;    // TMV_ATTRIB
*  } )
*  skip
*enddo
*close area
*RETURN NIL

#endif DEF_FIN

#ifdef DEF_ANW

**
** AwcRefresh()
**
FUNCTION AwcRefresh()
saAwc := {}
open area oAwc()
go top
do while ! eof()
  aadd( saAwc, { ;
    AWC->IdAwc , ;
    AWC->Desig ,  ;
    AWC->PrixV,  ;
    AWC->PrixA   ;
  } )
  skip
enddo
close area
RETURN NIL

#endif DEF_ANW

#ifdef DEF_IPB

**
** IPB
**

**
** IpbRefresh()
**
FUNCTION IpbRefresh()
saIpb := {}
open area oIpb()
  go top
  do while !eof()
    aadd( saIpb, { ;
      IPB->IdCtr , ;        // IPB_IDCTR
      IPB->IdReg   , ;
      IPB->IdCta   , ;
      IPB->IdTax   , ;      // IPB_IDTAX
      IPB->GenBase , ;      // IPB_GENBASE
      trim(IPB->Attrib), ;      // IPB_ATTRIB
      IPB->IdDev,    ;      // IPB_IDDEV
      IPB->IdDma,    ;      // IPB_IDDMA
      trim(IPB->xlWhen) ;    // IPB_WHEN
    } )                    // IPB_ALEN
    * 20020314b, 20030412
    skip
  enddo
close area
RETURN NIL

FUNCTION IpbLocate(cIdCtr,cIdReg,cIdCat,cIdTax,cIdDev)
local i
local tax
if saIpb == NIL ; IpbRefresh() ; endif
for i := 1 to len(saIpb)
  if saIpb[i][IPB_IDCTR] == cIdCtr
    if empty(saIpb[i][IPB_IDDEV]) .or. saIpb[i][IPB_IDDEV] == cIdDev
      if cIdReg == NIL .or. empty(saIpb[i][IPB_IDREG]) .or. saIpb[i][IPB_IDREG] == cIdReg
        if cIdCat == NIL .or. empty(saIpb[i][IPB_IDCAT]) .or. saIpb[i][IPB_IDCAT] == cIdCat
          if empty(saIpb[i][IPB_IDDMA]) .or. saIpb[i][IPB_IDDMA] == ART->IdDma
            if empty(cIdTax) .or. empty(saIpb[i][IPB_IDTAX]) .or. saIpb[i][IPB_IDTAX] == cIdTax
              if empty(saIpb[i][IPB_WHEN]) .or. &(saIpb[i][IPB_WHEN])
                #ifdef DEF_TAX
                  RETURN saIpb[i] if empty(saIpb[i][IPB_IDTAX])
                  tax := TaxLocate(cIdCtr,saIpb[i][IPB_IDTAX],.f.,NIL)
                  RETURN saIpb[i] if tax == NIL  // will generate error
                                                 // message afterwards
                  RETURN saIpb[i] if empty(tax[TAX_VALID])
                  RETURN saIpb[i] if &(tax[TAX_VALID])
                  // TAX->xlValid ist also nicht einverstanden
                  SetMsg("") // sonst irritierende Fehlermeldung
                #else
                  RETURN saIpb[i]
                #endif
                *  if IPBATTR_E $ saIpb[i][IPB_ATTRIB]
                *    SetMsg( ;
                *      cIdCtr + "/" + cIdReg + "/" + cIdCat + "/" + cIdTax ;
                *      + MsgExpertOnly() ;
                *    )
                *    if USRATTR_E $ UsrAttrib()
                *      RETURN saIpb[i]
                *    else
                *      RETURN NIL
                *    endif
                *  else
                *    RETURN saIpb[i]
                *  endif
              endif
            endif
          endif
        endif
      endif
    endif
  endif
next i
RETURN NIL

#ifdef DEF_TAX
FUNCTION IpbTaux(cIdCat)
local i
if saIpb == NIL ; IpbRefresh() ; endif
for i := 1 to len(saIpb)
  if empty(saIpb[i][IPB_IDREG])
    if saIpb[i][IPB_IDCAT] == cIdCat
      RETURN TaxTaux(saIpb[i][IPB_IDCTR],saIpb[i][IPB_IDTAX],UserDate())
    endif
  endif
next i
RETURN 0
#endif

#endif DEF_IPB

#ifdef DEF_ART

**
** CTA - catÇgories d'articles
**

FUNCTION CtaRefresh()
saCta := ReadArray("CTA.DBC",CTA_ALEN)
RETURN NIL

FUNCTION CtaLocate( cId )
local i
if saCta == NIL ; CtaRefresh() ; endif
for i := 1 to len(saCta)
  if saCta[i][CTA_IDCTA] == cId
    RETURN saCta[i]
  endif
next i
RETURN NIL

FUNCTION CtaName( cId )
local cta := CtaLocate(cId)
RETURN "" if cta == NIL
RETURN cta[CTA_NAME]

FUNCTION CtaExist(cId)
RETURN .T. if CtaLocate(cId) != NIL
SetMsg(cId + MSG017 )
RETURN .F.

**
** PickCta()
**
FUNCTION PickCta(cStart)
local cReturn
local aLib := {}
local i
if saCta == NIL ; CtaRefresh() ; endif
for i := 1 to len(saCta)
  aadd( aLib, ;
        saCta[i][CTA_IDCTA] + " " + ;
        saCta[i][CTA_NAME] ;
  )
next i
RETURN ArrayPick( aLib, TIM002, cStart, LEN_IDCTA, "CTA")


#ifdef DEF_TAX
FUNCTION CtaTaux(cIdCta)
static scIdCta
static snTaux := 0
local cta
RETURN snTaux if cIdCta == scIdCta
cta := CtaLocate(cIdCta)
RETURN 0 if cta == NIL
#ifdef DEF_IPB
  snTaux := IpbTaux(cIdCta)
#endif
RETURN snTaux // cta[CTA_TAUX]
#else
FUNCTION CtaTaux(cIdCta)
RETURN 0
#endif DEF_TAX

#endif DEF_ART


**
** CtrRefresh()
**
FUNCTION CtrRefresh()
local a
saCtr := {}
open area oCtr()
go top
do while ! eof()
  a := array(CTR_ALEN)
  a[CTR_ID]       := CTR->IdCtr
  a[CTR_NAME]     := trim(CTR->Name)
  #ifdef DEF_GEN
    a[CTR_IDGEN]  := FieldIdGen()
  #endif
  a[CTR_PRTLIST]  := trim(CTR->PrtList)
  a[CTR_DC]       := CTR->DC
  #ifdef DEF_CTRATTR
    a[CTR_ATTRIB] := trim(CTR->Attrib)
  #endif DEF_CTRATTR
  a[CTR_HSTCOLS]  := trim(CTR->HstCols)
  a[CTR_TPLINI]   := trim(CTR->TplIni)
  aadd( saCtr, a )
  skip
enddo
close area
RETURN NIL

FUNCTION CtrLocate(cId)
local i
if saCtr == NIL ; CtrRefresh() ; endif
for i := 1 to len(saCtr)
  if saCtr[i][CTR_ID] == cId
    RETURN saCtr[i]
  endif
next i
RETURN NIL

FUNCTION GenCtrExist(cIdGen)
local i
if saCtr == NIL ; CtrRefresh() ; endif
for i := 1 to len(saCtr)
  if saCtr[i][CTR_IDGEN] == cIdGen
    RETURN .t.
  endif
next i
RETURN .f.

#ifdef DEF_JNL

FUNCTION GenJnlExist(cIdGen)
local i
if saJnl == NIL ; JnlRefresh() ; endif
for i := 1 to len(saJnl)
  RETURN .t. if saJnl[i][JNL_IDGEN] == cIdGen
next i
RETURN .f.

#endif DEF_JNL


FUNCTION CtrName(cId)
local prt
if len(cId) > LenIdCtr()
  RETURN CtrName(left(cId,LenIdCtr()))+", "+CtrName(substr(cId,LenIdCtr()+1))
endif
prt := CtrLocate(cId)
RETURN "" if prt == NIL
RETURN prt[CTR_NAME]
**
FUNCTION CtrIdGen(cId)
local prt := CtrLocate(cId)
RETURN "" if prt == NIL
RETURN prt[CTR_IDGEN]
**
FUNCTION CtrDC(cId)
local prt := CtrLocate(cId)
RETURN "" if prt == NIL
RETURN prt[CTR_DC]
**
* FUNCTION CtrIdTxt(cId)
* local prt := CtrLocate(cId)
* RETURN "LISTE" if prt == NIL
* RETURN "LISTE" if empty(prt[CTR_IDTXT])
* RETURN prt[CTR_IDTXT]
**
FUNCTION CtrPrtList(cId)
local prt := CtrLocate(cId)
RETURN "" if prt == NIL
RETURN prt[CTR_PRTLIST]

FUNCTION CtrHstCols(cId)
local ctr := CtrLocate(cId)
RETURN "" if ctr == NIL
RETURN ctr[CTR_HSTCOLS]

FUNCTION CtrTplIni(cId)
local ctr := CtrLocate(cId)
RETURN "" if ctr == NIL
RETURN ctr[CTR_TPLINI]

#ifdef DEF_CTRATTR
  FUNCTION CtrAttrib(cId)
  local prt := CtrLocate(cId)
  RETURN "" if prt == NIL
  RETURN prt[CTR_ATTRIB]
#endif DEF_CTRATTR

FUNCTION CtrExist(cId)
RETURN .t. if CtrLocate(cId) != NIL
SetMsg(cId + MsgCtrExist())
RETURN .f.

FUNCTION CtrList()
if saCtr == NIL ; CtrRefresh() ; endif
RETURN saCtr

FUNCTION PickCtr(cStart,cTitle)
local nStart := 0
local i
default cTitle to "Zentralisierungsart"
if saCtr == NIL ; CtrRefresh() ; endif
for i := 1 to len(saCtr)
  if saCtr[i][CTR_ID] == cStart
    nStart := i
  endif
next i
browse array saCtr ;
             using {|ctr| ;
               ctr[CTR_ID] + " " + padr(strtran(ctr[CTR_NAME],"~"),25) ;
             } ;
             delete {||.f.} ;
             title (cTitle) ;
             start nStart ;
             help "CTR"
RETURN NIL if LastChoice() == 0
RETURN saCtr[LastChoice()][CTR_ID]


#ifdef DEF_JNL

**
** PickSeqType()
**
FUNCTION PickSeqType(cStart,cTitle)
local nStart := 0
local i
local a := {}
aadd(a, { SEQTYPE_M, "Manuell               " } )
aadd(a, { SEQTYPE_Y, "pro Kalenderjahr      " } )
aadd(a, { SEQTYPE_E, "par exercice comptable" } )
aadd(a, { SEQTYPE_C, "durchlaufend          " } )
default cTitle to "Nummerierungsart"
for i := 1 to len(a)
  if a[i][1] == cStart
    nStart := i
  endif
next i
browse array a ;
             using {|x| x[1] + " " + x[2] } ;
             delete {||.f.} ;
             title (cTitle) ;
             start nStart ;
             help "SEQTYPE"
RETURN NIL if LastChoice() == 0
RETURN a[LastChoice()][1]

#endif DEF_JNL

**
** UsrRefresh()
**
FUNCTION UsrRefresh()
local a
saUsr := {}
open area oUsr()
  go top
  do while !eof()
    a := array(USR_ALEN)
    a[USR_IDUSR]  := USR->UserId
    a[USR_NAME]   := USR->Name
    a[USR_ATTRIB] := trim(USR->Attrib)
    aadd( saUsr, a)
    skip
  enddo
close area
RETURN NIL

#ifdef DEF_PRESTO

**
** AgsRefresh()
**
FUNCTION AgsRefresh()
saAgs := {}
open area oAgs()
  go top
  do while ! eof()
    if empty(AGS->User) .or. AGS->User == UserId()
      aadd(saAgs, {        ;
        AGS->IdAgs  ,      ;  // AGS_IDAGS
        AGS->Desig ,     ;    // AGS_DESIG
        AGS->Attrib,      ;   // AGS_ATTRIB
        AGS->IdTpl,       ;   // AGS_IDTPL
        AGS->Next         ;   // AGS_NEXT
      } )
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_PRESTO

#ifdef DEF_UNT

**
** UntRefresh()
**
FUNCTION UntRefresh()
saUnt := {}
open area oUnt()
  go top
  do while ! eof()
    aadd(saUnt, {          ;
      UNT->IdUnt  ,        ;
      trim(UNT->Name1) ,   ;
      trim(UNT->Name2) ,   ;
      trim(UNT->Name3) ,   ;
      trim(UNT->QteForm)   ;
    } )
    skip
  enddo
close area
RETURN NIL

#endif DEF_UNT

**
** LOCATE_METHODS
**
** Return specified object as record array
** Decide whether the static array has to be read first
**

#ifdef DEF_UNT

**
** UntLocate()
**
FUNCTION UntLocate( cIdUnt )
local i
if saUnt == NIL ; UntRefresh() ; endif
for i := 1 to len(saUnt)
  if saUnt[i][UNT_IDUNT] == cIdUnt
    RETURN saUnt[i]
  endif
next i
RETURN NIL

#endif DEF_UNT


#ifdef DEF_ANW

**
** AwcLocate()
**
FUNCTION AwcLocate( cId )
local i
if saAwc == NIL ; AwcRefresh() ; endif
for i := 1 to len(saAwc)
  if saAwc[i][AWC_IDAWC] == cId
    RETURN saAwc[i]
  endif
next i
RETURN NIL

#endif DEF_ANW


#ifdef DEF_FIN

**
** DifLocate()
**
*FUNCTION DifLocate( cId )
*local i
*if saDif == NIL ; DifRefresh() ; endif
*for i := 1 to len(saDif)
*  if saDif[i][DIF_IDDIF] == cId
*    RETURN saDif[i]
*  endif
*next i
*RETURN NIL // { "" , "" , 0 }

#endif DEF_FIN

#ifdef DEF_ECHE

**
** EcsLocate()
**
FUNCTION EcsLocate( cId )
local i
if saEcs == NIL ; EcsRefresh() ; endif
for i := 1 to len(saEcs)
  RETURN saEcs[i] if saEcs[i][ECS_IDECS] == cId
next i
RETURN NIL

#endif DEF_ECHE

#ifdef DEF_DEV

**
** DevLocate()
**
FUNCTION DevLocate( cId )
local i
if saDev == NIL ; DevRefresh() ; endif
for i := 1 to len(saDev)
  if saDev[i][DEV_IDDEV] == cId
    RETURN saDev[i]
  endif
next i
* SetMsg( cId + " : Devise invalide." )
RETURN NIL

#endif DEF_DEV

**
**  VALUE_METHODS
**
**  Return a value of identified object
**

#ifdef DEF_PIN


FUNCTION PnsName(cIdPrj,cId)
local pns := PnsLocate(cIdPrj,cId)
RETURN "" if pns == NIL
RETURN pns[PNS_NAME]

FUNCTION PnsLocate(cIdPrj,cId)
local i
PnsRefresh(cIdPrj)
for i := 1 to len(saPns)
  if saPns[i][1] == cId
    RETURN saPns[i]
  endif
next i
RETURN NIL

#endif DEF_PIN

*FUNCTION GrpName(cId)
*local i
*cId := trim(cId)
*if saGrp == NIL ; GrpRefresh() ; endif
*for i := 1 to len(saGrp)
*  if saGrp[i][GRP_ID] == cId
*    RETURN strtran(saGrp[i][GRP_NAME],"~")
*  endif
*next i
*RETURN ""

FUNCTION PraName(cId)
local i
if saPra == NIL ; PraRefresh() ; endif
for i := 1 to len(saPra)
  if saPra[i][PRA_ID] == cId
    RETURN saPra[i][PRA_NAME]
  endif
next i
RETURN ""

*#ifdef DEF_COMPTA
*
*FUNCTION PmvName(cId)
*local i
*if saPmv == NIL ; PmvRefresh() ; endif
*for i := 1 to len(saPmv)
*  if saPmv[i][PMV_ID] == cId
*    RETURN saPmv[i][PMV_NAME]
*  endif
*next i
*RETURN ""
*
*#endif DEF_COMPTA

#ifdef DEF_PRESTO

* FUNCTION StaText(cEtat)
* local i
* for i := 1 to len(saSta)
*   if saSta[i][1] == cEtat
*     RETURN saSta[i][2]
*   endif
* next i
* RETURN space(10)

FUNCTION AgsLocate(cId)
local i
if saAgs == NIL ; AgsRefresh() ; endif
for i := 1 to len(saAgs)
  RETURN saAgs[i] if saAgs[i][AGS_IDAGS] == cId
next i
RETURN NIL

FUNCTION AgsDesig(cId)
local i
if saAgs == NIL ; AgsRefresh() ; endif
for i := 1 to len(saAgs)
  if saAgs[i][AGS_IDAGS] == cId
    RETURN saAgs[i][AGS_DESIG]
  endif
next i
RETURN space(20)

FUNCTION AgsAttrib(cId)
local i
if saAgs == NIL ; AgsRefresh() ; endif
for i := 1 to len(saAgs)
  if saAgs[i][AGS_IDAGS] == cId
    RETURN saAgs[i][AGS_ATTRIB]
  endif
next i
RETURN ""

FUNCTION AgsNext(cId)
local i
if saAgs == NIL ; AgsRefresh() ; endif
for i := 1 to len(saAgs)
  if saAgs[i][AGS_IDAGS] == cId
    RETURN cId if empty(saAgs[i][AGS_NEXT])
    RETURN saAgs[i][AGS_NEXT]
  endif
next i
RETURN space(LEN_IDAGS)

#endif DEF_PRESTO

#ifdef DEF_ECHE

**
** ECS
**
FUNCTION EcsName( cId )
local a := EcsLocate( cId )
RETURN "" if a == NIL
RETURN strtran(a[ECS_NAME],"~")
**
FUNCTION EcsDuree( cId )
local a := EcsLocate( cId )
RETURN 0 if a == NIL
RETURN val(a[ECS_DUREE])
**
FUNCTION EcsIdJnl( cId )
local a := EcsLocate( cId )
RETURN "" if a == NIL
RETURN a[ECS_IDJNL]
**
FUNCTION EcsCptType( cId )
local a := EcsLocate( cId )
RETURN "" if a == NIL
RETURN a[ECS_CPTTYPE]
**
FUNCTION EcsDC( cId )
local a := EcsLocate( cId )
RETURN " " if a == NIL
RETURN a[ECS_DC]
**

#endif DEF_ECHE

#ifdef DEF_DEV

**
** DEV
**
FUNCTION DevCours( cId, cPeriode )
local dev := DevLocate(cId)
RETURN "1" if dev == NIL
RETURN dev[DEV_COURS2] if cPeriode >= PerToggle()
* RETURN dev[DEV_COURS2] if DevToggle(cPeriode)
RETURN dev[DEV_COURS]
**
FUNCTION DevName( cId )
local dev := DevLocate(cId)
RETURN cId if dev == NIL
RETURN dev[DEV_LIBELL]
**
FUNCTION DevDecPos( cId )
local dev := DevLocate(cId)
RETURN 0 if dev == NIL
RETURN dev[DEV_DECPOS]

* FUNCTION DevDelta(cId)
* local dev := DevLocate(cId)
* RETURN 0 if dev == NIL
* RETURN val(dev[DEV_DELTA])
**
* FUNCTION DevIdJnl( cId )
* local dev := DevLocate(cId)
* RETURN "" if dev == NIL
* RETURN dev[DEV_IDJNL]


/****************

Test-Beispiele fÅr Dev2Db() und Db2Dev() :

Konfigurationsdaten :
1. WÑhrungen
BEF≥         1≥   40.3399
DEM≥ 20.625463≥   1.95583
EUR≥   40.3399≥         1
USD≥        35≥      0.88

2. TIM.DBI :
DevToggle {|cPeriode|cPeriode>="0100"}



{=ntom(Dev2Db("BEF","0001",100))} = 100
{=ntom(Dev2Db("BEF","0101",100))} = 100


*****************/

**
** Dev2Db()
**
FUNCTION Dev2Db(cIdDev,cPeriode,nMont)
local dev := DevLocate(cIdDev)
local db := DevLocate(DevDefault(cPeriode))
RETURN nMont if dev == NIL .or. db == NIL .or. db[DEV_IDDEV] == cIdDev
if PerDevFixed(cPeriode,cIdDev)
  nMont := round(nMont * val(db[DEV_COURS2]),2)
  nMont := nMont / val(dev[DEV_COURS2])
else
  // nMont := nMont * val(DevCours(cIdDev,cPeriode))
  if cPeriode >= PerToggle()
  * if DevToggle(cPeriode)
    nMont := nMont / val(dev[DEV_COURS2])
  else
    nMont := nMont * val(dev[DEV_COURS])
  endif
endif
RETURN nMont

**
** Db2Dev()
**
FUNCTION Db2Dev(cIdDev,cPeriode,nMont)
local dev := DevLocate(cIdDev)
local db := DevLocate(DevDefault(cPeriode))
RETURN nMont if dev == NIL .or. db == NIL .or. db[DEV_IDDEV] == cIdDev
if PerDevFixed(cPeriode,cIdDev)
  nMont := round(nMont * val(dev[DEV_COURS2]),2)
  nMont := nMont / val(db[DEV_COURS2])
else
  if cPeriode >= PerToggle()
  * if DevToggle(cPeriode)
    nMont := nMont * val(dev[DEV_COURS2])
  else
    nMont := nMont / val(dev[DEV_COURS])
  endif
  // nMont := nMont / val(DevCours(cIdDev,cPeriode))
endif
RETURN nMont

FUNCTION DocDevCours(cIdDev,cPeriode)
RETURN "" if PerDevFixed(cPeriode,cIdDev)
RETURN DevCours(cIdDev,cPeriode)

#endif DEF_DEV

**
** SwapValues()
**
FUNCTION SwapValues( u1, u2 )
local uTmp := u1
u1 := u2
u2 := uTmp
RETURN NIL


**
** ElemInsert()
**
** mvts are sorted by value of first element of aItem
**
FUNCTION ElemInsert( aList, aItem )
local i
for i := 1 to len( aList )
  if aList[i][1] > aItem[1]
    aadd( aList, NIL )
    ains( aList, i )
    aList[i] := aItem
    RETURN NIL
  endif
next i
aadd( aList, aItem )
RETURN NIL



#ifdef DEF_PRESTO

**
** PickSta()
**
* FUNCTION PickSta(cStart)
* local cReturn
* local aLib := {}
* local i
* for i := 2 to len(saSta)
*   aadd( aLib, ;
*         saSta[i][1] + " " + ;
*         saSta[i][2] ;
*   )
* next i
* RETURN ArrayPick( aLib, "Status", cStart,1)

FUNCTION PickAgs(cStart,cTitle)
local nStart := 0
local i
if saAgs == NIL ; AgsRefresh() ; endif
if cStart != NIL
  for i := 1 to len(saAgs)
    if saAgs[i][AGS_IDAGS] == cStart
      nStart := i
    endif
  next i
endif
browse array saAgs using {|x| x[AGS_IDAGS] + " " + x[AGS_DESIG] } ;
             delete {||.f.} ;
             start nStart ;
             help "AGS" ;
             title (cTitle)
RETURN NIL if lastchoice() == 0
RETURN saAgs[lastchoice()]

#endif DEF_PRESTO

#ifdef DEF_UNT

FUNCTION PickUnt(cStart,cTitle)
local nStart := 0
local i
if saUnt == NIL ; UntRefresh() ; endif
if cStart != NIL
  for i := 1 to len(saUnt)
    if saUnt[i][UNT_IDUNT] == cStart
      nStart := i
    endif
  next i
endif
browse array saUnt using {|x| x[UNT_IDUNT] + " " + padr(x[UNT_NAME1],20) } ;
             delete {||.f.} ;
             start nStart ;
             help "UNT" ;
             title (cTitle)
RETURN NIL if lastchoice() == 0
RETURN saUnt[lastchoice()][UNT_IDUNT]

#endif DEF_UNT

#ifdef DEF_DEV
**
** PickDev()
**
FUNCTION PickDev(cStart)
local cReturn
local aLib := {}
local i
if saDev == NIL ; DevRefresh() ; endif
for i := 1 to len(saDev)
  aadd( aLib, ;
        saDev[i][DEV_IDDEV] + " " + ;
        saDev[i][DEV_LIBELL] + " " + ;
        saDev[i][DEV_COURS] ;
  )
next i
RETURN ArrayPick( aLib, TIM005, cStart, LEN_IDDEV, "DEVPICK")

#else

FUNCTION PickDev()
RETURN NIL


#endif DEF_DEV

#ifdef DEF_FIN

**
** PickDif()
**
FUNCTION PickDif(cIdCtr,cDC,nMont) // cStart)
local a := {}
local i
if nMont > 0 ; cDC := DcInvert(cDC) ; endif
if saDif == NIL ; DifRefresh() ; endif
for i := 1 to len(saDif)
  if empty(saDif[i][DIF_IDCTR]) .or. saDif[i][DIF_IDCTR]== cIdCtr
    if empty(saDif[i][DIF_DC]) .or. saDif[i][DIF_DC]== cDC
      aadd(a, saDif[i])
    endif
  endif
next i
RETURN NIL if len(a) == 0
browse array a using {|dif| padr(dif[DIF_NAME],30) } ;
             delete {||.f.} ;
             help "DIF" ;
             title (TIM006)
RETURN NIL if lastchoice() == 0
RETURN a[lastchoice()]

#endif DEF_FIN

**
** PickUnt()
**
* FUNCTION PickUnt(cStart)
* local cReturn
* local aLib := {}
* local i
* for i := 1 to len(saUnt)
*   aadd( aLib, ;
*         saUnt[i][UNT_IDUNT] + " " + ;
*         saUnt[i][UNT_LIBELL1] ;
*   )
* next i
* RETURN ArrayPick( aLib, "Unit", cStart, LEN_IDUNT, "UNT")

#ifdef DEF_PIN

FUNCTION PickPns(cIdPrj,cStart)
local nStart := 0
local i
PnsRefresh(cIdPrj)
if cStart != NIL
  for i := 1 to len(saPns)
    if saPns[i][PNS_ID] == cStart
      nStart := i
    endif
  next i
endif
browse array saPns using {|x| x[PNS_ID] + " " + padr(x[PNS_NAME],40) } ;
             delete {||.f.} ;
             start nStart ;
             help "PNS" ;
             title ("Pin-Status")
RETURN NIL if lastchoice() == 0
RETURN saPns[lastchoice()][PNS_ID]

FUNCTION PickPna(cIdPrj,cStart)
PnaRefresh(cIdPrj)
RETURN PickAttrib(saPna,cIdPrj + " : Attribute",cStart,"","PNA")

FUNCTION PickPno(cIdPrj,cStart)
PnoRefresh(cIdPrj)
RETURN PickAttrib(saPno,cIdPrj + " : Optionen",cStart,"","PNO")

*FUNCTION PnaName(cId)
*local i
*if saPna == NIL ; PnaRefresh() ; endif
*for i := 1 to len(saPna)
*  RETURN saPna[i][2] if cId == saPna[i][1]
*next i
*RETURN ""
*
*FUNCTION PnaText(cAttrib)
*local i
*local cText := ""
*cAttrib := trim(cAttrib)
*if saPna == NIL ; PnaRefresh() ; endif
*for i := 1 to len(cAttrib)
*  cText += PnaName(subst(cAttrib,i,1)) + ". "
*next i
*RETURN cText

#endif DEF_PIN


FUNCTION PickPra(cStart)
if saPra == NIL ; PraRefresh() ; endif
RETURN PickAttrib(saPra,"Partner-Attribute",cStart,"","PRA")



#ifdef DEF_PRESTO

FUNCTION PickAga(cStart)
if saAga == NIL ; AgaRefresh() ; endif
RETURN PickAttrib(saAga,"Termin-Attribute",cStart,"","AGA")

FUNCTION AgaName(cId)
local i
if saAga == NIL ; AgaRefresh() ; endif
for i := 1 to len(saAga)
  RETURN saAga[i][AGA_NAME] if cId == saAga[i][AGA_ID]
next i
RETURN ""

FUNCTION AgaText(cAttrib)
local i
local cText := ""
cAttrib := trim(cAttrib)
if saAga == NIL ; AgaRefresh() ; endif
for i := 1 to len(cAttrib)
  cText += AgaName(subst(cAttrib,i,1)) + ". "
next i
RETURN cText

#endif DEF_PRESTO

*FUNCTION PickGrp(cStart)
*local nStart := 0
*local i
*if saGrp == NIL ; GrpRefresh() ; endif
*cStart := trim(cStart)
*for i := 1 to len(saGrp)
*  if saGrp[i][GRP_ID] == cStart
*    nStart := i
*    exit
*  endif
*next i
*browse array saGrp using {|grp| ;
*                          padr(grp[GRP_ID],LEN_IDGRP) + " " ;
*                          + padr(strtran(grp[GRP_NAME],"~"),40) ;
*                        } ;
*             start nStart ;
*             help "GRP" ;
*             title "Partnergruppe zuweisen"
*if LastChoice() != 0
*   RETURN saGrp[LastChoice()][1]
*endif
*RETURN NIL


FUNCTION PickAlc()
if saAlc == NIL ; AlcRefresh() ; endif
browse array saAlc using {|x| padr(x,35) } ;
             delete {||.f.} ;
             help "ALC" ;
             title "Anrede (VorschlÑge)"
if LastChoice() != 0
   RETURN saAlc[LastChoice()]
endif
RETURN NIL


**
** PickUsr()
**
FUNCTION PickUsr(cStart,cTitle)
local cReturn
local a := {}
local i
local nStart := 0
if saUsr == NIL ; UsrRefresh() ; endif
for i := 1 to len(saUsr)
  if ! USRATTR_H $ saUsr[i][USR_ATTRIB]
    aadd(a, saUsr[i])
    if saUsr[i][USR_IDUSR] == cStart
      nStart := len(a)
    endif
  endif
next i
default cTitle to TIM007
browse array a ;
             using {|x| x[USR_IDUSR] + " " + x[USR_NAME] } ;
             title (cTitle) ;
             help "USRPICK" ;
             start nStart
RETURN NIL if LastChoice() == 0
RETURN a[lastchoice()][USR_IDUSR]


#ifdef DEF_ANW

FUNCTION PickAwcList(cStart)
local aPick := {}
local i
if saAwc == NIL ; AwcRefresh() ; endif
for i := 1 to len(saAwc)
  aadd( aPick, { ;
        saAwc[i][AWC_IDAWC], ;
        saAwc[i][AWC_DESIG], ;
        1 ;
    } ;
  )
next i
RETURN PickAttrib( aPick, "Auswahl Anwesenheits-Codes", cStart )

#endif DEF_ANW

*#ifdef DEF_COMPTA
*
*FUNCTION TmvList(cIdJnl)
*local i
*local a := {}
*if saTmv == NIL ; TmvRefresh() ; endif
*for i := 1 to len(saTmv)
*  if saTmv[i][TMV_IDJNL] == cIdJnl
*    aadd(a, saTmv[i])
*  endif
*next i
*RETURN a
*
*#endif DEF_COMPTA

#ifdef DEF_VAR

*FUNCTION PickVarItem(nLstId,cStart)
*local i
*local nStart := 0
*local nList := LstPointer(nLstId)
*RETURN NIL if nList == 0
*if ! empty(cStart)
*  for i := 1 to len(saVar[nList][VAR_ITEMS])
*    if saVar[nList][VAR_ITEMS][i][VITEM_ID] == cStart
*      nStart := i
*    endif
*  next i
*endif
*browse array saVar[nList][VAR_ITEMS] ;
*             using {|x| padr(x[VITEM_NAME],saVar[nList][VAR_LEN_NAME]) } ;
*             title (saVar[nList][VAR_LSTNAME]) ;
*             help "PICKVAR" ;
*             start nStart
*RETURN NIL if LastChoice() == 0
*RETURN saVar[nList][VAR_ITEMS][LastChoice()][VITEM_ID]

#endif DEF_VAR

* FUNCTION PickGrpList(cStart)
* local aPick := {}
* local i
* if saGrp == NIL ; GrpRefresh() ; endif
* for i := 1 to len(saGrp)
*   aadd( aPick, { saGrp[i][1], saGrp[i][2] , 1 } )
* next i
* RETURN PickAttrib( aPick, "Partnergruppe" , cStart, " ", "GRP" )

#ifdef DEF_ECHE

**
** EcsList()
**
FUNCTION EcsList()
if saEcs == NIL ; EcsRefresh() ; endif
RETURN saEcs

**
** PickEcs()
**
FUNCTION PickEcs(cStart, cCptType, cTitle)
local aEcs
local aLib := {}
local i
default cTitle to "Zahlungsauftragsarten"
aEcs := EcsList()
for i := 1 to len(aEcs)
  if cCptType == NIL .or. cCptType == aEcs[i][ECS_CPTTYPE]
  * if cAttrib == NIL .or. cAttrib $ aEcs[i][ECS_ATTRIB]
    aadd( aLib, aEcs[i][ECS_IDECS] + " " + strtran(aEcs[i][ECS_NAME],"~") )
  endif
next i
RETURN ArrayPick( aLib, cTitle, cStart, LEN_IDECS, "ECS")

#endif DEF_ECHE

FUNCTION PrtRefresh
saPrt := ReadArray("PRT.DBC",PRT_ALEN)
RETURN NIL


FUNCTION PickPrt(cPrtList,cTitle,cStart,nPrtField,cHelp)
local a := {}
local i
local nStart := 0
if saPrt == NIL ; PrtRefresh() ; endif
default cTitle to "Partnerart"
default cHelp to "PRT"
if empty(cPrtList)
  a := saPrt
else
  for i := 1 to len(saPrt)
    if saPrt[i][PRT_ID] $ cPrtList
      aadd(a, saPrt[i])
    endif
  next i
endif
if len(a) == 1
  RETURN a[1] if nPrtField == NIL
  RETURN a[1][nPrtField]
endif
if len(a) == 0
  a := saPrt
endif
for i := 1 to len(a)
  if a[i][PRT_ID] == cStart
    nStart := i
  endif
next i
browse array a ;
             using {|prt| ;
               prt[PRT_ID] + " " + prt[PRT_NAME] ;
             } ;
             delete {||.f.} ;
             title (cTitle) ;
             help  (cHelp) ;
             start nStart
RETURN NIL if LastChoice() == 0
RETURN a[LastChoice()] if nPrtField == NIL
RETURN a[LastChoice()][nPrtField]

FUNCTION PickPrtList(cStart,cTitle)
local a := {}
local i
local nStart := 0
if saPrt == NIL ; PrtRefresh() ; endif
default cTitle to "Partnerart"
for i := 1 to len(saPrt)
  aadd(a, { saPrt[i][PRT_ID], strtran(saPrt[i][PRT_NAME],"~") })
next i
RETURN PickAttrib(a, cTitle, cStart, "", "PRTLIST" )

* FUNCTION GrpList()
* if saGrp == NIL ; GrpRefresh() ; endif
* RETURN saGrp

FUNCTION PrtList()
if saPrt == NIL ; PrtRefresh() ; endif
RETURN saPrt

FUNCTION PrtLocate(cId)
local i
if saPrt == NIL ; PrtRefresh() ; endif
for i := 1 to len(saPrt)
  if saPrt[i][PRT_ID] == cId
    RETURN saPrt[i]
  endif
next i
RETURN NIL

FUNCTION PrtName(cId)
local prt := PrtLocate(cId)
RETURN "" if prt == NIL
RETURN prt[PRT_NAME]

FUNCTION PrtIdCtr(cId)
local prt := PrtLocate(cId)
RETURN "" if prt == NIL
RETURN prt[PRT_IDCTR]

FUNCTION PrtDC(cId)
local prt := PrtLocate(cId)
RETURN "" if prt == NIL
RETURN prt[PRT_DC]

#ifdef DEF_UNT

FUNCTION UntName(cId,cLangue)
local unt := UntLocate(cId)
RETURN "" if unt == NIL
default cLangue to TplLang()
RETURN unt[UNT_NAME2] if cLangue == MemLang2
RETURN unt[UNT_NAME3] if cLangue == MemLang3
RETURN unt[UNT_NAME1]

FUNCTION UntQteForm(cId)
local unt := UntLocate(cId)
RETURN " " if unt == NIL
RETURN unt[UNT_QTEFORM]


FUNCTION VnlUntName(cLangue)
local cIdUnt := NIL
#ifdef DEF_ART
  if IsArtCode(FIELD->Code)
    cIdUnt := ART->IdUnt
  endif
#endif
#ifdef DEF_PRESTO
  if IsArtCode(FIELD->Code)
    cIdUnt := ART->IdUnt
  endif
#endif
* RETURN " " if empty(cIdUnt)
RETURN " " + trim1(UntName(cIdUnt,cLangue)) //  + " "

#endif DEF_UNT

#ifdef DEF_JNL

**
** MFC - modes de facturation
**
FUNCTION MfcRefresh()
saMfc := ReadArray("MFC.DBC",MFC_ALEN)
RETURN NIL
**
** MfcLocate()
**
FUNCTION MfcLocate(cId)
local i
if saMfc == NIL ; MfcRefresh() ; endif
for i := 1 to len(saMfc)
  RETURN saMfc[i] if saMfc[i][MFC_ID] == cId
next i
RETURN NIL

**
** PickMfc()
**
FUNCTION PickMfc(cStart,cTitle)
local nStart := 0
local i
* #ifdef LG_GERMAN
* default cTitle to "Zahlart"
* #else
* default cTitle to "Mode de paiement"
* #endif
default cTitle to ""
cTitle += MsgPickMfc()
* cStart := trim(cStart)
if saMfc == NIL ; MfcRefresh() ; endif
for i := 1 to len(saMfc)
  if saMfc[i][MFC_ID] == cStart
    nStart := i
  endif
next i
browse array saMfc using {|mfc| ;
                         mfc[MFC_ID] + " " + ;
                         mfc[MFC_NAME1] } ;
             start nStart ;
             delete {||.f.} ;
             help "MFC" ;
             title (cTitle)
if lastchoice() != 0
   RETURN saMfc[lastchoice()][MFC_ID]
endif
RETURN NIL

FUNCTION MfcName(cIdMfc,cIdLng)
local mfc := MfcLocate(cIdMfc)
RETURN cIdMfc if mfc == NIL
#ifdef DEF_4LANG
RETURN mfc[MFC_NAME4] if cIdLng == MemLang4 .and. ! empty(mfc[MFC_NAME4])
#endif
RETURN mfc[MFC_NAME3] if cIdLng == MemLang3 .and. ! empty(mfc[MFC_NAME3])
RETURN mfc[MFC_NAME2] if cIdLng == MemLang2 .and. ! empty(mfc[MFC_NAME2])
RETURN mfc[MFC_NAME1]

FUNCTION MfcExist(cId)
RETURN .t. if MfcLocate(cId) != NIL
SetMsg(cId + " : ungÅltige Zahlart")
RETURN .f.


#endif DEF_JNL

#ifdef DEF_JNL

**
** PickIfc( [cStart] , [cIdJnl] , [cIdPrt] , [cTitle] )
**
FUNCTION PickIfc(cStart,cIdJnl,cTitle)
local nStart := 0
local i
local aMfc := {}
local cIdCtr := JnlIdCtr(cIdJnl)
local ifc
* cStart := trim(cStart)
if saMfc == NIL ; MfcRefresh() ; endif
for i := 1 to len(saMfc)
  if (ifc := IfcLocate(cIdCtr,cIdJnl,saMfc[i][MFC_ID])) != NIL
    if ! IFCATTR_H $ ifc[IFC_ATTRIB]
      aadd(aMfc,saMfc[i])
      if saMfc[i][MFC_ID] == cStart
        nStart := len(aMfc)
      endif
    endif
  endif
next i
browse array aMfc using {|mfc| ;
                         padr(mfc[MFC_ID],LenIdMfc()) + " " + ;
                         mfc[MFC_NAME1] } ;
             start nStart ;
             delete {||.f.} ;
             help "MFC" ;
             title (cTitle + MsgPickMfc())
if LastChoice() != 0
   RETURN aMfc[LastChoice()][MFC_ID]
endif
RETURN NIL

#ifdef LG_GERMAN
FUNCTION MsgPickMfc() ; RETURN " : Zahlart"
#else
FUNCTION MsgPickMfc() ; RETURN " : mode de paiement"
#endif

#endif DEF_JNL


#ifdef DEF_IMP
              
**
** SatRefresh()
**
FUNCTION SatRefresh()
saSat := {}
open area oSat()
  go top
  do while ! eof()
    aadd(saSat, {         ;
      SAT->DC    ,        ; // SAT_DC
      SAT->IdJnl1 ,       ; // SAT_IDJNL1
      SAT->IdGrj1 ,       ; // SAT_IDGRJ1
      SAT->IdJnl2 ,       ; // SAT_IDJNL2
      SAT->IdGrj2 ,       ; // SAT_IDGRJ2
      trim(SAT->Attrib),  ; // SAT_ATTRIB
      trim(SAT->Filter)   ; // SAT_FILTER
    } )
    skip
  enddo
close area
RETURN NIL


FUNCTION SatLocate(jnl1,jnl2)
local i
local cMac
RETURN NIL if JNLATTR_L $ jnl1[JNL_ATTRIB]
if saSat == NIL ; SatRefresh() ; endif
for i := 1 to len(saSat)
  if saSat[i][SAT_IDGRJ1] == jnl1[JNL_IDGRJ]
    if empty(saSat[i][SAT_IDJNL1]) .or. saSat[i][SAT_IDJNL1] == jnl1[JNL_IDJNL]
      if saSat[i][SAT_IDGRJ2] == jnl2[JNL_IDGRJ]
        if empty(saSat[i][SAT_IDJNL2]) .or. saSat[i][SAT_IDJNL2] == jnl2[JNL_IDJNL]
          cMac := saSat[i][SAT_FILTER]
          if empty(cMac) .or. eval(&(cMac),jnl1[JNL_IDJNL],jnl2[JNL_IDJNL])
            RETURN saSat[i]
          endif
        endif
      endif
    endif
  endif
next i
RETURN NIL


**
** SrvRefresh()
**
FUNCTION SrvRefresh()
saSrv := {}
open area oSrv()
  go top
  do while ! eof()
    aadd(saSrv, {         ;
      SRV->IdSrv  ,       ; // SRV_IDSRV
      SRV->Name ,         ; // SRV_NAME
      trim(SRV->Attrib),  ; // SRV_ATTRIB
      SRV->CodTot ,       ; // SRV_CODTOT
      SRV->SubBud ,       ; // SRV_SUBBUD
      SRV->IdBud_D ,      ; // SRV_IDBUD_D
      SRV->IdBud_C        ; // SRV_IDBUD_C
    } )
    skip
  enddo
close area
RETURN NIL


FUNCTION SrvValue(cIdSrv,i,uFail)
local srv := SrvLocate(cIdSrv)
RETURN uFail if srv == NIL
RETURN srv[i]

FUNCTION SrvLocate(cIdSrv)
local i
if saSrv == NIL ; SrvRefresh() ; endif
for i := 1 to len(saSrv)
  if saSrv[i][SRV_IDSRV] == cIdSrv
    RETURN saSrv[i]
  endif
next i
RETURN NIL

FUNCTION PickSrv(cStart,cTitle)
local i
local nStart := 0
local a := {}
if saSrv == NIL ; SrvRefresh() ; endif
default cTitle to "Dienst"
for i := 1 to len(saSrv)
  aadd(a, saSrv[i])
  if saSrv[i][SRV_IDSRV] == cStart
    nStart := len(a)
  endif
next i
browse array a ;
             using {|x| ;
               x[SRV_IDSRV] + " " + x[SRV_NAME] ;
             } ;
             title (cTitle) ;
             help "SRV" ;
             start nStart
RETURN NIL if LastChoice() == 0
RETURN a[LastChoice()][SRV_IDSRV]



#endif DEF_IMP


#ifdef DEF_IPB

FUNCTION IpbCatDefault
local i
if saIpb == NIL ; IpbRefresh() ; endif
for i := 1 to len(saIpb)
  RETURN saIpb[i][IPB_IDCAT] if ! empty(saIpb[i][IPB_IDCAT])
next i
RETURN ""

#endif DEF_IPB

#ifdef DEF_VNA
              
**
** TrnRefresh()
**
FUNCTION TrnRefresh()
local a
saTrn := {}
open area oTrn()
  go top
  do while ! eof()
    a := array(TRN_ALEN)
    a[TRN_DC    ] := TRN->DC
    a[TRN_IDJNL1] := TRN->IdJnl1
    a[TRN_IDGRJ1] := TRN->IdGrj1
    a[TRN_IDJNL2] := TRN->IdJnl2
    a[TRN_IDGRJ2] := TRN->IdGrj2
    a[TRN_ATTRIB] := trim(TRN->Attrib)
    #ifdef DEF_CARRY
      a[TRN_CARRY ] := trim(TRN->Carry)
    #endif DEF_CARRY
    aadd(saTrn,a)
    skip
  enddo
close area
RETURN NIL


**
** VnaTrnLocate() ermittelt die trn, die den aktuellen VNA-Record
**                durch ein Dokument aus jnl2 befriedigen kann
**
FUNCTION VnaTrnLocate(jnl2)
RETURN TrnLocate(jnl2,VNA->IdJnl,VNA->DC)

FUNCTION TrnLocate(jnl2,cIdJnl,cDC)
* locates the TRN that applies for a document of jnl2 satisfying a VNA
* from cIdJnl and with direction cDC
local i
local jnl1 := JnlLocate(cIdJnl)
RETURN NIL if jnl1 == NIL
if saTrn == NIL ; TrnRefresh() ; endif
for i := 1 to len(saTrn)
  if saTrn[i][TRN_IDGRJ1] == jnl1[JNL_IDGRJ]
    if empty(saTrn[i][TRN_IDJNL1]) .or. saTrn[i][TRN_IDJNL1] == jnl1[JNL_IDJNL]
      if saTrn[i][TRN_IDGRJ2] == jnl2[JNL_IDGRJ]
        if empty(saTrn[i][TRN_IDJNL2]) .or. saTrn[i][TRN_IDJNL2] == jnl2[JNL_IDJNL]
          if empty(saTrn[i][TRN_DC]) .or. saTrn[i][TRN_DC] == cDC
            RETURN saTrn[i]
          endif
        endif
      endif
    endif
  endif
next i
RETURN NIL

*FUNCTION TrnDcSatis(trn,cDC1,cDC2)
*if TRNATTR_I $ trn[TRN_ATTRIB]
*  RETURN .t. if cDC1 != cDC2
*  RETURN .f.
*endif
*RETURN .t. if cDC1 == cDC2
*RETURN .f.

*FUNCTION TrnOverflow(jnl2)
*local i
*if saTrn == NIL ; TrnRefresh() ; endif
*for i := 1 to len(saTrn)
*  if empty(saTrn[i][TRN_IDGRJ1])
*    if empty(saTrn[i][TRN_IDJNL1])
*      if saTrn[i][TRN_IDGRJ2] == jnl2[JNL_IDGRJ]
*        if empty(saTrn[i][TRN_IDJNL2]) .or. saTrn[i][TRN_IDJNL2] == jnl2[JNL_IDJNL]
*          RETURN saTrn[i]
*        endif
*      endif
*    endif
*  endif
*next i
*RETURN NIL

*FUNCTION TrnJnlOver(jnl,cIdCtr)
*local i
*if saTrn == NIL ; TrnRefresh() ; endif
*for i := 1 to len(saTrn)
*  if saTrn[i][TRN_IDGRJ1] == jnl[JNL_IDGRJ]
*    if empty(saTrn[i][TRN_IDJNL1]) .or. saTrn[i][TRN_IDJNL1] == jnl[JNL_IDJNL]
*      if saTrn[i][TRN_DC] == cIdCtr
*        if TRNATTR_A $ saTrn[i][TRN_ATTRIB]
*          RETURN JnlLocate(saTrn[i][TRN_IDJNL2])
*        endif
*      endif
*    endif
*  endif
*next i
*RETURN NIL

**
** JnlTrnExist() fÅr PickJnl() in Automatikfakturierung :
** prÅft nach, ob das betreffende Jnl Åberhaupt etwas befriedigen kînnte
**
** 960710 : wenn cIdJnl1 angegeben, werden nur die Journale akzeptiert,
**          die das angegebene cIdJnl1 befriedigen kînnen.
**          Beispiel : Bei [Alt-F6] auf einem Lieferschein kommt nur VKR
**          als zu generierendes Dokument in Frage.
FUNCTION JnlTrnExist(jnl2) // ,cIdJnl1)
local i
if saTrn == NIL ; TrnRefresh() ; endif
for i := 1 to len(saTrn)
  * if empty(cIdJnl1) .or. saTrn[i][TRN_IDJNL1] == cIdJnl1
    if TRNATTR_A $ saTrn[i][TRN_ATTRIB]
      if saTrn[i][TRN_IDGRJ2] == jnl2[JNL_IDGRJ]
        if saTrn[i][TRN_IDJNL2] == jnl2[JNL_IDJNL]
          RETURN .t.
        endif
      endif
    endif
  * endif
next i
RETURN .f.

#endif DEF_MVT


#ifdef DEF_STK

**
** STK
**
FUNCTION StkRefresh()
local i
saStk := ReadArray("STK.DBC",STK_ALEN)
for i := 1 to len(saStk)
  saStk[i][STK_IDSTK] := trim(saStk[i][STK_IDSTK])
next i
RETURN NIL
**
* FUNCTION StkHeader(cIdStk)
* local o := StkLocate(cIdStk)
* RETURN space(LenQte()) if o == NIL
* RETURN o[STK_HEADER]
**
*FUNCTION StkName(cIdStk)
*local o := StkLocate(cIdStk)
*RETURN "" if o == NIL
*RETURN o[STK_NAME]
**
*FUNCTION StkLocate(cId)
*local i
*if saStk == NIL ; StkRefresh() ; endif
*for i := 1 to len(saStk)
*  RETURN saStk[i] if saStk[i][STK_IDSTK] == cId
*next i
*RETURN NIL
**
FUNCTION StkList(cId)
if saStk == NIL ; StkRefresh() ; endif
RETURN saStk
**
FUNCTION PickStk(cStart,cTitle)
local i
local nStart := 0
local a := {}
if saStk == NIL ; StkRefresh() ; endif
default cTitle to "Stock"
for i := 1 to len(saStk)
  aadd(a, saStk[i])
  if saStk[i][STK_IDSTK] == cStart
    nStart := len(a)
  endif
next i
browse array a ;
             using {|stk| ;
               stk[STK_IDSTK] + " " + stk[STK_EXPR] ;
             } ;
             title (cTitle) ;
             help "STK" ;
             start nStart
RETURN NIL if LastChoice() == 0
RETURN a[LastChoice()][STK_IDSTK]

#endif DEF_STK


**
** LngRefresh()
**
FUNCTION LngRefresh()
saLng := ReadArray("LNG.DBC",LNG_ALEN)
RETURN NIL

FUNCTION LngLocate(cIdLng)
local i
if saLng == NIL ; LngRefresh() ; endif
for i := 1 to len(saLng)
  RETURN saLng[i] if saLng[i][LNG_ID] == cIdLng
next i
RETURN NIL



FUNCTION LngName(cIdLng)
local lng := LngLocate(cIdLng)
RETURN "" if lng == NIL
RETURN lng[LNG_NAME]

**
** PickLng()
**
FUNCTION PickLng(cStart,cLngList,cTitle)
local i
local a := {}
static nChoice := 0
#ifdef LG_GERMAN
default cTitle to "Sprache"
#else
default cTitle to "Langue"
#endif
if saLng == NIL ; LngRefresh() ; endif
for i := 1 to len(saLng)
  if empty(cLngList) .or. saLng[i][LNG_ID] $ cLngList
    aadd(a,saLng[i])
    if saLng[i][LNG_ID] == cStart
      nChoice := len(a)
    endif
  endif
next i
RETURN a[1][LNG_ID] if len(a) == 1
if nChoice > len(a)
  nChoice := 0
endif
browse array a ;
             using {|dst| padr(dst[LNG_NAME],30) } ;
             title (cTitle) ;
             delete {||.f.} ;
             start nChoice ;
             help "LNG"
RETURN NIL if lastchoice() == 0
nChoice := lastchoice()
RETURN a[nChoice][LNG_ID]

**
** TlfRefresh()
**
FUNCTION TlfRefresh()
saTlf := ReadArray("TLF.DBC",TLF_ALEN)
RETURN NIL

FUNCTION TlfLocate(cIdTlf)
local i
if saTlf == NIL ; TlfRefresh() ; endif
for i := 1 to len(saTlf)
  RETURN saTlf[i] if saTlf[i][TLF_IDTLF] == cIdTlf
next i
RETURN NIL

**
** PickTlf()
**
FUNCTION PickTlf(cStart)
local i
static nChoice := 0
if saTlf == NIL ; TlfRefresh() ; endif
for i := 1 to len(saTlf)
  if saTlf[i][TLF_IDTLF] == cStart
    nChoice := i
  endif
next i
browse array saTlf ;
             using {|x| ;
               padr(x[TLF_PICTURE] + " : " + ;
               transform("087593550",x[TLF_PICTURE]),30) ;
             } ;
             title (MsgPickTlf()) ;
             delete {||.f.} ;
             start nChoice ;
             help "TLF"
RETURN NIL if lastchoice() == 0
nChoice := lastchoice()
RETURN saTlf[nChoice][TLF_IDTLF]

FUNCTION MsgPickTlf()
#ifdef LG_GERMAN
RETURN "Telefonformat"
#else
RETURN "Format numÇros tÇlÇphone"
#endif
* #ifdef DEF_DCL

**
** DcrRefresh()
**
*FUNCTION DcrRefresh()
*saDcr := {}
*open area oDcr()
*go top
*do while !eof()
*  aadd(saDcr, {   ;
*    DCR->IdDcl,   ;           // DCR_IDDCL
*    DCR->IdCtr,   ;           // DCR_IDCTR
*    trim(DCR->Libell),  ;     // DCR_NAME
*    DCR->IdTax,   ;           // DCR_IDTAX
*    DCR->IdCat,   ;           // DCR_IDCAT
*    DCR->Attrib,  ;           // DCR_ATTRIB
*    DCR->IdJnl,   ;           // DCR_IDJNL
*    DCR->Header,  ;           // DCR_HEADER
*    DCR->DC       ;           // DCR_DC
*  } )
*  skip
*enddo
*close area
*RETURN NIL
*
***
*** DcrLocate()
***
*FUNCTION DcrLocate( ;
*  cIdDcl, ;
*  jnl, ;
*  cIdTax, ;
*  cIdCat, ;
*  cDc, ;
*  cAttrib ;
*)
*local i
*if saDcr == NIL ; DcrRefresh() ; endif
*for i := 1 to len(saDcr)
*  if saDcr[i][DCR_IDDCL] == cIdDcl
*    if saDcr[i][DCR_IDCTR] == jnl[JNL_IDCTR]
*      if empty(saDcr[i][DCR_IDTAX]) .or. saDcr[i][DCR_IDTAX] == cIdTax
*        if empty(saDcr[i][DCR_IDCAT]) .or. saDcr[i][DCR_IDCAT] == cIdCat
*          if empty(saDcr[i][DCR_DC]) .or. saDcr[i][DCR_DC] == cDc
*            if cAttrib $ saDcr[i][DCR_ATTRIB]
*              RETURN saDcr[i]
*            endif
*          endif
*        endif
*      endif
*    endif
*  endif
*next i
*RETURN NIL

#ifdef DEF_HST

FUNCTION CljRefresh
saClj := ReadArray("CLJ.DBC",CLJ_ALEN)
RETURN NIL

**
** CljList()
**
FUNCTION CljList(jnl)
local i
local aClj := {}
if saClj == NIL ; CljRefresh() ; endif
for i := 1 to len(saClj)
  if jnl[JNL_IDCTR] == saClj[i][CLJ_IDCTR]
    aadd(aClj, saClj[i])
  endif
next i
RETURN aClj

FUNCTION CljLocate(cIdCtr,cIdClj)
local i
if saClj == NIL ; CljRefresh() ; endif
for i := 1 to len(saClj)
  if saClj[i][CLJ_IDCTR] == cIdCtr
    RETURN saClj[i] if saClj[i][CLJ_IDCLJ] == cIdClj
  endif
next i
RETURN NIL

**
** CljExist()
**
FUNCTION CljExist(cIdCtr,cIdClj)
RETURN .t. if CljLocate(cIdCtr,cIdClj) != NIL
SetMsg(cIdClj + MsgCljExist() + trim(CtrName(cIdCtr)))
RETURN .f.

FUNCTION MsgCljExist
#ifdef LG_GERMAN
RETURN " : unbekannte Rechnungsbuchkolonne fÅr "
#else
RETURN " : code totalisateur invalide en "
#endif


*
*
*FUNCTION CljName(cId)
*local i
*if saClj == NIL ; CljRefresh() ; endif
*for i := 1 to len(saClj)
*  RETURN saClj[i][CLJ_NAME] if saClj[i][CLJ_IDCLJ] == cId
*next i
*RETURN ""


FUNCTION PickClj(cIdCtr,cIdClj)
local nStart := 0
local i
local aClj := {}
if saClj == NIL ; CljRefresh() ; endif
for i := 1 to len(saClj)
  if saClj[i][CLJ_IDCTR] == cIdCtr
  // if empty(cIdCtr) .or. saClj[i][CLJ_IDCTR] == cIdCtr
    aadd(aClj, saClj[i])
    if saClj[i][CLJ_IDCLJ] == cIdClj
      nStart := len(aClj)
    endif
  endif
next i
browse array aClj ;
             using {|cld| cld[CLJ_IDCLJ] + " " + padr(cld[CLJ_HEADER],40) } ;
             title (MSG_CLJ) ;
             delete {||.f.} ;
             start nStart ;
             help "CLJ"
RETURN NIL if lastchoice() == 0
RETURN aClj[lastchoice()][CLJ_IDCLJ]

#else

FUNCTION PickClj() ; RETURN NIL

#endif DEF_HST


#ifdef DEF_IMP

**
** GRB - Groupes budgÇdaires
**
FUNCTION GrbRefresh()
saGrb := ReadArray("GRB.DBC",GRB_ALEN)
RETURN NIL
**
FUNCTION GrbLocate(cId)
local i
if saGrb == NIL ; GrbRefresh() ; endif
for i := 1 to len(saGrb)
  RETURN saGrb[i] if saGrb[i][GRB_IDGRB] == cId
next i
RETURN NIL
**
FUNCTION GrbExist(cDC,cIdGrb)
local i
if saGrb == NIL ; GrbRefresh() ; endif
for i := 1 to len(saGrb)
  if saGrb[i][GRB_DC] == cDC
    RETURN .t. if saGrb[i][GRB_IDGRB] == cIdGrb
  endif
next i
SetMsg(cIdGrb + " : ungÅltige Haushaltsgruppe fÅr " + DcName(cDC))
RETURN .f.
**
FUNCTION PickGrb(cDC,cStart)
local i
local nStart := 0
local a := {}
if saGrb == NIL ; GrbRefresh() ; endif
for i := 1 to len(saGrb)
  if saGrb[i][GRB_DC] == cDC
    aadd(a, saGrb[i])
    if saGrb[i][GRB_IDGRB] == cStart
      nStart := len(a)
    endif
  endif
next i
browse array a ;
             using {|x| ;
               x[GRB_IDGRB] + " " + x[GRB_NAME] ;
             } ;
             delete {||.f.} ;
             title ("Haushaltsgruppe") ;
             help "GRB" ;
             start nStart
RETURN NIL if LastChoice() == 0
RETURN a[LastChoice()][GRB_IDGRB]
*
FUNCTION GrbName(cIdGrb)
local grb := GrbLocate(cIdGrb)
RETURN "" if grb == NIL
RETURN grb[GRB_NAME]
*
FUNCTION GrbList()
if saGrb == NIL ; GrbRefresh() ; endif
RETURN saGrb

**
** FCB - fonctions budgÇtaires
**
FUNCTION FcbRefresh()
saFcb := ReadArray("FCB.DBC",FCB_ALEN)
RETURN NIL
**
FUNCTION FcbLocate(cId)
local i
if saFcb == NIL ; FcbRefresh() ; endif
for i := 1 to len(saFcb)
  RETURN saFcb[i] if saFcb[i][FCB_IDFCB] == cId
next i
RETURN NIL
**
FUNCTION PickFcb(cStart)
local i
local nStart := 0
if saFcb == NIL ; FcbRefresh() ; endif
for i := 1 to len(saFcb)
  if saFcb[i][FCB_IDFCB] == cStart
    nStart := i
  endif
next i
browse array saFcb ;
             using {|x| ;
               x[FCB_IDFCB] + " " + x[FCB_NAME] ;
             } ;
             title ("Haushaltsfunktion") ;
             delete {||.f.} ;
             help "FCB" ;
             start (nStart)
RETURN NIL if LastChoice() == 0
RETURN saFcb[LastChoice()][FCB_IDFCB]
*
FUNCTION FcbName(cIdFcb)
local fcb := FcbLocate(cIdFcb)
RETURN "" if fcb == NIL
RETURN fcb[FCB_NAME]
*
FUNCTION FcbList()
if saFcb == NIL ; FcbRefresh() ; endif
RETURN saFcb


**
** SBB - Groupes budgÇdaires
**
FUNCTION SbbRefresh()
saSbb := ReadArray("SBB.DBC",SBB_ALEN)
RETURN NIL
**
FUNCTION SbbLocate(cId)
local i
if saSbb == NIL ; SbbRefresh() ; endif
for i := 1 to len(saSbb)
  RETURN saSbb[i] if saSbb[i][SBB_IDSBB] == cId
next i
RETURN NIL
**
FUNCTION PickSbb(cStart)
local i
local nStart := 0
if saSbb == NIL ; SbbRefresh() ; endif
for i := 1 to len(saSbb)
  if saSbb[i][SBB_IDSBB] == cStart
    nStart := i
  endif
next i
browse array saSbb ;
             using {|x| ;
               x[SBB_IDSBB] + " " + x[SBB_NAME] ;
             } ;
             delete {||.f.} ;
             title ("Haushaltsunterteilung") ;
             help "SBB" ;
             start nStart
RETURN NIL if LastChoice() == 0
RETURN saSbb[LastChoice()][SBB_IDSBB]
*
FUNCTION SbbName(cIdSbb)
local grb := SbbLocate(cIdSbb)
RETURN "" if grb == NIL
RETURN grb[SBB_NAME]


#endif DEF_IMP


#ifdef DEF_TRA

**
** TrtRefresh()
**
FUNCTION TrtRefresh()
saTrt := {}
* MsgDisplay(MSG001) // "Lecture des journaux...")
open area oTrt()
go top
do while !eof()
  aadd(saTrt, {       ;
    TRT->IdTrt,       ;     // TRT_IDTRT
    trim(TRT->Name),  ;     // TRT_NAME
    TRT->DC,          ;     // TRT_DC
    TRT->IdBud,       ;     // TRT_IDBUD
    TRT->IdJnl,       ;     // TRT_IDJNL
    trim(TRT->Expr),  ;     // TRT_EXPR
    TRT->IdBudI,      ;     // TRT_IDBUDI
    TRT->IdTpl        ;     // TRT_IDTPL
  } )                       // TRT_ALEN
  skip
enddo
close area
RETURN NIL

**
** TrtLocate()
**
FUNCTION TrtLocate( cIdTrt )
local i
if saTrt == NIL ; TrtRefresh() ; endif
for i := 1 to len(saTrt)
  if saTrt[i][TRT_IDTRT] == cIdTrt
    RETURN saTrt[i]
  endif
next i
RETURN NIL
**
FUNCTION TrtName(cId)
local trt := TrtLocate(cId)
RETURN "" if trt == NIL
RETURN trt[TRT_NAME]
**
FUNCTION TrtIdBud(cId)
local trt := TrtLocate(cId)
RETURN "" if trt == NIL
RETURN trt[TRT_IDBUD]
**
FUNCTION TrtIdJnl(cId)
local trt := TrtLocate(cId)
RETURN NIL if trt == NIL
RETURN trt[TRT_IDJNL]
**
FUNCTION TrtExist(cId)
RETURN .t. if TrtLocate(cId) != NIL
SetMsg(cId + " : unbekannte Transaktionsart !")
RETURN .f.


**
** PickTrt()
**
FUNCTION PickTrt(cStart,cDC,cIdBud) // , a, cTitle)
local i
local a := {}
local nStart
local cTitle := "Transaktionsart"
if saTrt == NIL ; TrtRefresh() ; endif
for i := 1 to len(saTrt)
  if empty(cDC) .or. saTrt[i][TRT_DC] == cDC
    if empty(cIdBud) .or. saTrt[i][TRT_IDBUD] == cIdBud
      aadd(a,saTrt[i])
    endif
  endif
next i
for i := 1 to len(a)
  if a[i][TRT_IDTRT] == cStart
    nStart := i
  endif
next i
browse array a ;
             using {|trt| trt[TRT_IDTRT] + " " + ;
                          padr(trt[TRT_NAME],30)  ;
                          + " " + trt[TRT_DC] ;
                   } ;
            title ("Transaktions-Art") ;
            start nStart ;
            delete {||.f.}
RETURN NIL if lastchoice() == 0
RETURN a[lastchoice()][TRT_IDTRT]

**
** TrtDefault()
**
FUNCTION TrtDefault(cDC,cIdBud)
local i
local a := {}
local nStart
if saTrt == NIL ; TrtRefresh() ; endif
for i := 1 to len(saTrt)
  if empty(cDC) .or. saTrt[i][TRT_DC] == cDC
    if empty(cIdBud) .or. saTrt[i][TRT_IDBUD] == cIdBud
      RETURN saTrt[i][TRT_IDTRT]
    endif
  endif
next i
RETURN space(LenIdTrt())

#endif DEF_TRA

*#ifdef DEF_XTV
*
*FUNCTION XtvRefresh
*saXtv := ReadArray("XTV.DBC",XTV_ALEN)
*RETURN NIL
*
*FUNCTION XtvLocate(i)
*if saXtv == NIL ; XtvRefresh() ; endif
*RETURN saXtv[i]
*
*FUNCTION XtvList
*if saXtv == NIL ; XtvRefresh() ; endif
*RETURN saXtv
*
*#endif DEF_XTV

#ifdef DEF_HOLZ

**
** CLS - Baumstammklassen
**
FUNCTION ClsRefresh()
local i
saCls := ReadArray("CLS.DBC",CLS_ALEN)
saClsType := {}
aadd(saClsType,{ " ", "(keine Klassierung)" }) // see CLSTYPE_ALEN
for i := 1 to len(saCls)
  ClsCollect(saCls[i],saClsType)
next i
RETURN NIL
**
FUNCTION ClsCollect(cls,aClsType)
local i
local clstype
for i := 1 to len(aClsType)
  if cls[CLS_CLSTYPE] == aClsType[i][CLSTYPE_ID]
    aClsType[i][CLSTYPE_NAME] += "," + cls[CLS_IDCLS]
    RETURN NIL
  endif
next i
clstype := array(CLSTYPE_ALEN)
clstype[CLSTYPE_ID]   := cls[CLS_CLSTYPE]
clsType[CLSTYPE_NAME] := cls[CLS_IDCLS]
aadd(aClsType,clstype)
RETURN NIL
**
** ClsLocate
**
FUNCTION ClsLocate(cId)
local i
if saCls == NIL ; ClsRefresh() ; endif
for i := 1 to len(saCls)
  RETURN saCls[i] if saCls[i][CLS_IDCLS] == cId
next i
RETURN NIL
**
FUNCTION PickCls(cStart)
local i
local nStart := 0
local a := {}
if saCls == NIL ; ClsRefresh() ; endif
for i := 1 to len(saCls)
  if saCls[i][CLS_CLSTYPE] == saClsType[snClsType][CLSTYPE_ID]
    aadd(a, saCls[i])
    if saCls[i][CLS_IDCLS] == cStart
      nStart := len(a)
    endif
  endif
next i
browse array a ;
             using {|x| ;
               x[CLS_IDCLS] + " " + x[CLS_NAME] + " (" + x[CLS_MZ] + ")";
             } ;
             delete {||.f.} ;
             title ("Klasse") ;
             help "CLS" ;
             start (nStart)
RETURN NIL if LastChoice() == 0
RETURN a[LastChoice()][CLS_IDCLS]
*
FUNCTION SetClsType()
local i
local nStart := 0
if saCls == NIL ; ClsRefresh() ; endif
browse array saClsType ;
             using {|x| ;
               x[CLSTYPE_ID] + " " + padr(x[CLSTYPE_NAME],30) ;
             } ;
             title ("Klassierungsart") ;
             delete {||.f.} ;
             help "CLSTYPE" ;
             start (snClsType)
RETURN .f. if LastChoice() == 0
snClsType := lastchoice()
RETURN MnuDone() if ! Confirm("Bestehende EintrÑge neu klassieren (J/N) ?")
ddScan({||StmReset()})
ddRefreshAll()
RETURN MnuDone()
**
FUNCTION StmReset
RETURN .f. if ! ddRecLock()
STM->IdCls := ClsDefault()
unlock record
RETURN .t.
*
FUNCTION ClsName(cIdCls)
local cls := ClsLocate(cIdCls)
RETURN cIdCls if cls == NIL
RETURN cls[CLS_NAME]
*
FUNCTION ClsMZ(cIdCls)
local cls := ClsLocate(cIdCls)
RETURN 0 if cls == NIL
RETURN val(cls[CLS_MZ])
*
FUNCTION ClsDefault
local i
if saCls == NIL ; ClsRefresh() ; endif
for i := 1 to len(saCls)
  if saCls[i][CLS_CLSTYPE] == saClsType[snClsType][CLSTYPE_ID]
    RETURN saCls[i][CLS_IDCLS] if &(saCls[i][CLS_EXPR])
  endif
next i
RETURN ""

#endif DEF_HOLZ

#ifdef DEF_VCB

**
** VCB
**
FUNCTION VcbRefresh()
local i
saVcb := ReadArray("VCB.DBC",VCB_ALEN)
for i := 1 to len(saVcb)
  saVcb[i][VCB_IDVCB] := trim(saVcb[i][VCB_IDVCB])
next i
RETURN NIL
**
FUNCTION VcbList(cId)
if saVcb == NIL ; VcbRefresh() ; endif
RETURN saVcb

#endif DEF_VCB

* RETURN .f. if ! Confirm( cFilename + " wird gelîscht !", MsgSure())
* delete file (cFilename)
* if doserror() != 0
*   SetMsg(cFilename + MsgDosError())
*   RETURN .f.
* endif
* RETURN .t.

FUNCTION PickCln(cAlias,cStart,cTitle)
local aDir := directory(dbPath() + "\" + cAlias + "*.dbc" )
local a := {}
local i
local cLine
local nStart := 0
asort(aDir,,,{|x,y|x[F_NAME] < y[F_NAME]} )
for i := 1 to len(aDir)
  cLine := FileFirstLine(DbPath() + "\" + aDir[i][F_NAME])
  aadd(a, { substr(strtran(aDir[i][F_NAME],".DBC"),len(cAlias)+1), cLine } )
  if atail(a)[1] == cStart
    nStart := i
  endif
next i
browse array a ;
             using {|x| ;
               padr(x[1] + " : " + x[2],40) ;
             } ;
             title (cTitle) ;
             start nStart ;
             delete {||.f.} ;
             help "CLNPICK"
RETURN NIL if lastchoice() == 0
RETURN a[lastchoice()][1]



#ifdef DEF_BIBLIO

**
** REFRESH_METHODS
**
** Read the DBF once into static array
**

**
** DtpRefresh()
**
FUNCTION DtpRefresh()
saDtp := {}
open area oDtp()
go top
do while ! eof()
  aadd(saDtp, {    ;
    DTP->IdDtp,    ;
    DTP->Name,  ;
    trim(DTP->Titel), ;
    trim(DTP->Attrib),  ;
    val(DTP->LenPre),  ;
    val(DTP->LenSuf)  ;
  } )
  skip
enddo
close area
RETURN NIL

**
** DstRefresh()
**
FUNCTION DstRefresh()
saDst := ReadArray("DST.DBC",DST_ALEN)
RETURN NIL

#define DCA_ALEN 2
#define OAT_ALEN 2

**
** DcaRefresh()
**
FUNCTION DcaRefresh()
saDca := ReadArray("DCA.DBC",DCA_ALEN)
RETURN NIL

FUNCTION OatRefresh()
saOat := ReadArray("OAT.DBC",OAT_ALEN)
RETURN NIL

**
** LOCATE_METHODS
**
** Return specified object as record array
** Decide whether the static array has to be read first
**

**
** DtpLocate()
**
FUNCTION DtpLocate( cId )
local i
if saDtp == NIL ; DtpRefresh() ; endif
for i := 1 to len(saDtp)
  if saDtp[i][DTP_ID] == cId
    RETURN saDtp[i]
  endif
next i
RETURN NIL

**
** DstLocate()
**
FUNCTION DstLocate( cId )
local i
if saDst == NIL ; DstRefresh() ; endif
for i := 1 to len(saDst)
  if saDst[i][DST_ID] == cId
    RETURN saDst[i]
  endif
next i
RETURN NIL

**
**  VALUE_METHODS
**
**  Return a value of identified object
**

**
** DTP
**
FUNCTION DtpName( cId )
local dtp := DtpLocate(cId)
RETURN space(LEN_DTPNAME) if dtp == NIL
RETURN dtp[DTP_NAME]
**
FUNCTION DtpTitel( cId )
local dtp := DtpLocate(cId)
RETURN "" if dtp == NIL
RETURN dtp[DTP_TITEL]
**
FUNCTION DtpAttrib( cId )
local dtp := DtpLocate(cId)
RETURN "" if dtp == NIL
RETURN dtp[DTP_ATTRIB]

**
** DST
**
FUNCTION DstName( cId )
local dst := DstLocate(cId)
RETURN "" if dst == NIL
RETURN dst[DST_NAME]


**
** GRP
**
FUNCTION GrpName( cId )
if cId != NIL
  seek cId in GRP
endif
RETURN GRP->Name

**
** ObjDtpPick()
**
FUNCTION ObjDtpPick(cStart,cTitle)
local i
static nStart := 0
default cTitle to "Dokument-Art"
if saDtp == NIL ; DtpRefresh() ; endif
if cStart != NIL
  for i := 1 to len(saDtp)
    if saDtp[i][DTP_ID] == cStart
      nStart := i
    endif
  next i
endif
browse array saDtp ;
             using {|dtp| strtran(dtp[DTP_NAME],"~") } ;
             title (cTitle) ;
             start nStart
RETURN NIL if lastchoice() == 0
nStart := lastchoice()
RETURN saDtp[nStart][DTP_ID]

**
** RefDtpPick()
**
FUNCTION RefDtpPick(cStart,cTitel)
local i
static nStart := 0
default cTitel to "Verweis erstellen zu einem..."
if saDtp == NIL ; DtpRefresh() ; endif
if cStart != NIL
  for i := 1 to len(saDtp)
    if saDtp[i][DTP_ID] == cStart
      nStart := i
    endif
  next i
endif
browse array saDtp ;
             using {|dtp| strtran(dtp[DTP_TITEL],"~") } ;
             title (cTitel) ;
             start nStart
RETURN NIL if lastchoice() == 0
nStart := lastchoice()
RETURN saDtp[nStart][DTP_ID]

**
** PickDst()
**
FUNCTION PickDst(cStart)
local i
static nChoice := 0
if saDst == NIL ; DstRefresh() ; endif
for i := 1 to len(saDst)
  if saDst[i][DST_ID] == cStart
    nChoice := i
  endif
next i
browse array saDst ;
             using {|dst| padr(dst[DST_NAME],30) } ;
             title ("Bearbeitung am " + dtoc(UserDate())) ;
             start nChoice
RETURN NIL if lastchoice() == 0
nChoice := lastchoice()
RETURN saDst[nChoice][DST_ID]

FUNCTION DtpList()
if saDtp == NIL ; DtpRefresh() ; endif
RETURN saDtp

FUNCTION PickDca(cStart)
if saDca == NIL ; DcaRefresh() ; endif
RETURN PickAttrib(saDca,NIL,cStart)

FUNCTION PickOat(cStart)
if saOat == NIL ; OatRefresh() ; endif
RETURN PickAttrib(saOat,NIL,cStart)

#endif DEF_BIBLIO

#ifdef DEF_ACT

FUNCTION PickDbcAttr(cDbcName,cStart,cTitle,cDelim)
local a := DbcLoad(cDbcName)
RETURN PickAttrib(a,cTitle,cStart,cDelim)

FUNCTION PickDbcCode(cDbcName,cStart,cTitle,nWidth,;
  blFilter,aActions,nNameItem,nReturnItem)
local a := DbcLoad(cDbcName)
local i
local nChoice := 0
local b
default nWidth to 40
default nReturnItem to 1
default nNameItem to 2
if blFilter != NIL
  b := {}
  for i := 1 to len(a)
    if eval(blFilter,a[i])
      aadd(b,a[i])
      if a[i][1] == cStart
        nChoice := len(b)
      endif
    endif
  next i
  a := b
else
  for i := 1 to len(a)
    if a[i][1] == cStart
      nChoice := i
    endif
  next i
endif
browse array a ;
             using {|x| x[1] + " " + padr(x[nNameItem],nWidth) } ;
             title (cTitle) ;
             actions (aActions) ;
             start nChoice
RETURN NIL if lastchoice() == 0
RETURN a[lastchoice()][nReturnItem]

FUNCTION PickDbcString(cDbcName,cStart,cTitle,nWidth)
local a := DbcLoad(cDbcName,1)
local i
local nChoice := 0
local nPadWidth := nWidth
default nPadWidth to 40
for i := 1 to len(a)
  if trim(a[i][1]) == trim(cStart)
    nChoice := i
  endif
next i
browse array a ;
             using {|x| padr(x[1],nPadWidth) } ;
             title (cTitle) ;
             start nChoice
RETURN NIL if lastchoice() == 0
RETURN a[lastchoice()][1] if nWidth == NIL
RETURN padr(a[lastchoice()][1],nWidth)

FUNCTION DbcText(cDbcName,cId,nField)
local a := DbcLoad(cDbcName)
local i
default nField to 2
for i := 1 to len(a)
  * if empty(a[i][nField])
  *   Warning(cDbcName+": empty field "+utos(nField))
  * endif
  RETURN a[i][nField] if a[i][1] == cId
next i
// Warning(cDbcName+": no entry for "+utos(cId))
RETURN ""

FUNCTION DbcLoop(cDbcName,bBlock)
local a := DbcLoad(cDbcName)
local i
for i := 1 to len(a)
  RETURN .f. if ! eval(bBlock,a[i])
next i
RETURN .t.

FUNCTION DbcLoad(cDbcName,nItems)
local i
local a
// default nItems to 2
for i := 1 to len(saDbcStack)
  if saDbcStack[i][1] == cDbcName
    RETURN saDbcStack[i][2]
  endif
next i
a := ReadArray(cDbcName,nItems)
aadd(saDbcStack, { cDbcName, a } )
RETURN a

#endif DEF_ACT

#ifdef DEF_DGR

**
** DGR
**
FUNCTION DgrRefresh()
saDgr := {}
open area oDgr()
  go top
  do while ! eof()
    aadd(saDgr, {        ;
      DGR->IdDgr ,       ; // DGR_IDDGR
      DGR->DC    ,       ; // DGR_DC
      DGR->Days  ,       ; // DGR_DAYS
      DGR->Name1 ,       ; // DGR_NAME1
      DGR->Name2 ,       ; // DGR_NAME2
      DGR->Name3 ,       ; // DGR_NAME3
      DGR->IdTpl ,       ; // DGR_IDTPL
      trim(DGR->Attrib), ; // DGR_ATTRIB
      trim(DGR->Zinsen), ; // DGR_ZINSEN
      DGR->Kosten        ; // DGR_KOSTEN
    } )
    skip
  enddo
close area
RETURN NIL

FUNCTION DgrLocate(cIdDgr,cDC)
local i
if saDgr == NIL ; DgrRefresh() ; endif
for i := len(saDgr) to 1 step -1
  if saDgr[i][DGR_IDDGR] == cIdDgr
    if empty(saDgr[i][DGR_DC]) .or. saDgr[i][DGR_DC] == cDC
      * if empty(nDays) .or. saDgr[i][DGR_DAYS] >= nDays
        RETURN saDgr[i]
      * endif
    endif
  endif
next i
RETURN NIL

FUNCTION DgrSuggest(doc,nDays,cDC,cIdDgrOld)
local i
if saDgr == NIL ; DgrRefresh() ; endif
for i := len(saDgr) to 1 step - 1
  if ! DGRATTR_M $ saDgr[i][DGR_ATTRIB]
    if empty(saDgr[i][DGR_DC]) .or. saDgr[i][DGR_DC] == cDC
      if empty(saDgr[i][DGR_DAYS]) .or. nDays >= val(saDgr[i][DGR_DAYS])
        if saDgr[i][DGR_IDDGR] <= NextId(cIdDgrOld)
          RETURN saDgr[i]
        endif
      endif
    endif
  endif
next i
RETURN DgrLocate(cIdDgrOld,cDC)

FUNCTION DgrName(cIdDgr,cDC)
local dgr := DgrLocate(cIdDgr,cDC)
RETURN "" if dgr == NIL
RETURN dgr[DGR_NAME3] if TplLang() == MemLang3
RETURN dgr[DGR_NAME2] if TplLang() == MemLang2
RETURN dgr[DGR_NAME1]

FUNCTION PickDgr(cStart,cDC,cTitle)
local i
local nStart := 0
local a := {}
if saDgr == NIL ; DgrRefresh() ; endif
default cTitle to "Mahnungsgrad"
for i := 1 to len(saDgr)
  if empty(saDgr[i][DGR_DC]) .or. saDgr[i][DGR_DC] == cDC
    aadd(a, saDgr[i])
    if saDgr[i][DGR_IDDGR] == cStart
      nStart := len(a)
    endif
  endif
next i
browse array a ;
             using {|x| ;
               x[DGR_IDDGR] + " " + x[DGR_NAME1] ;
             } ;
             delete {||.f.} ;
             title (cTitle) ;
             help "DGR" ;
             start nStart
RETURN NIL if LastChoice() == 0
RETURN a[LastChoice()][DGR_IDDGR]


#endif DEF_DGR


*#ifdef DEF_WWW
*
***
*** MST
***
*FUNCTION MstRefresh()
*saMst := {}
*open area oMst()
*  go top
*  do while ! eof()
*    aadd(saMst, {        ;
*      MST->IdMst ,       ; // MST_IDMST
*      MST->Name1 ,       ; // MST_NAME1
*      MST->Sort  ,       ; // MST_SORT
*      trim(MST->IdTpl),  ; // MST_IDTPL
*      trim(MST->Attrib)  ; // MST_ATTRIB
*    } )                    // MST_ALEN
*    skip
*  enddo
*close area
*RETURN NIL
*
*FUNCTION MstLocate(cIdMst)
*local i
*if saMst == NIL ; MstRefresh() ; endif
*for i := 1 to len(saMst)
*  if saMst[i][MST_IDMST] == cIdMst
*    RETURN saMst[i]
*  endif
*next i
*RETURN NIL
*
*FUNCTION MstName(cIdMst)
*local mst := MstLocate(cIdMst)
*RETURN "" if mst == NIL
*RETURN mst[MST_NAME1]
*
*FUNCTION MstSort(cIdMst)
*local mst := MstLocate(cIdMst)
*RETURN "" if mst == NIL
*RETURN mst[MST_NAME1]
*
*FUNCTION MstIdTpl(cIdMst)
*local mst := MstLocate(cIdMst)
*RETURN "" if mst == NIL
*RETURN mst[MST_IDTPL]
*
*FUNCTION MstCount()
*if saMst == NIL ; MstRefresh() ; endif
*RETURN len(saMst)
*
*FUNCTION PickMst(cStart,cTitle)
*local i
*local nStart := 0
*local a := {}
*if saMst == NIL ; MstRefresh() ; endif
*default cTitle to "Message type"
*for i := 1 to len(saMst)
*  aadd(a, saMst[i])
*  if saMst[i][MST_IDMST] == cStart
*    nStart := len(a)
*  endif
*next i
*RETURN a[1][MST_IDMST] if len(a) == 1
*browse array a ;
*             using {|x| ;
*               x[MST_IDMST] + " " + x[MST_NAME1] ;
*             } ;
*             delete {||.f.} ;
*             title (cTitle) ;
*             help "MST" ;
*             start nStart
*RETURN NIL if LastChoice() == 0
*RETURN a[LastChoice()][MST_IDMST]
*
*
*#endif DEF_WWW



FUNCTION DbResetObj
#ifdef DEF_RUN
  saCat := NIL
  saEqu := NIL
  * saClb := NIL
#endif DEF_RUN
#ifdef DEF_RSV
  * saTsl := NIL
  saRst := NIL
#endif DEF_RSV
#ifdef DEF_DGR
  saDgr := NIL
#endif DEF_DGR
#ifdef DEF_WWW
  saMst := NIL
#endif DEF_WWW
#ifdef DEF_JNL
  saJnl := NIL
  PerReset()
  saGrj := NIL
  saCdc := NIL
  saIfc := NIL
#endif DEF_JNL
saUsr := NIL
saDif := NIL
#ifdef DEF_DEV
  saDev := NIL
#endif DEF_DEV
* saCtf := NIL
saPrt := NIL
saCtr := NIL
saPra := NIL
saMfc := NIL
saPgp := NIL
saPga := NIL
#ifdef DEF_ZLA
  saZla := NIL
#endif DEF_ZLA
#ifdef DEF_REMISE
  saRpp := NIL
  saRga := NIL
  * saRpq := NIL
#endif DEF_REMISE
#ifdef DEF_ECHE
  saEcs := NIL
#endif DEF_ECHE
#ifdef DEF_PSC
  saPlt := NIL
#endif DEF_PSC
#ifdef DEF_IPB
  saIpb := NIL
#endif DEF_IPB
#ifdef DEF_VEN
  * saMdi := {}
  saFca := NIL
  saIpr := NIL
#endif
#ifdef DEF_TAX
  saReg := NIL
  saTax := NIL
#endif DEF_TAX
#ifdef DEF_HST
  saClj := NIL
#endif DEF_HST
#ifdef DEF_VNA
  saTrn := NIL
#endif
#ifdef DEF_PRESTO
  saAgs := NIL
  saAga := NIL
#endif
#ifdef DEF_ANW
  saAwc := NIL
#endif
#ifdef DEF_VAR
  saVrt := NIL
#endif
#ifdef DEF_UNT
  saUnt := NIL
#endif
#ifdef DEF_ART
  saCta := NIL
#endif DEF_ART
* #ifdef DEF_XTV
*   saXtv := NIL
* #endif DEF_XTV
#ifdef DEF_HOLZ
  saCls := NIL
#endif
* saNat := NIL
saLng := NIL
saTlf := NIL
saAlc := NIL
saPta := NIL
#ifdef DEF_IMP
  saSat := NIL
  saGrb := NIL
  saFcb := NIL
  saSbb := NIL
#endif DEF_IMP
#ifdef DEF_TRA
  saTrt := NIL
#endif DEF_TRA
#ifdef DEF_STK
  saStk := NIL
#endif
#ifdef DEF_VCB
  saVcb := NIL
#endif DEF_VCB
#ifdef DEF_ACT
  saDbcStack := {}
#endif DEF_ACT
KillMemoStack()
RETURN NIL

#ifdef DEF_KVK

**
** ZlaRefresh()
**
FUNCTION ZlaRefresh()
saZla := {}
open area oZla()
go top
do while !eof()
  aadd(saZla, {   ;
    ZLA->IdZla,   ;               // ZLA_IDZLA
    ZLA->Name,   ;                // ZLA_NAME
    ZLA->IdCtr,  ;                // ZLA_IDCTR
    val(DevCours(ZLA->IdDev),PerActive()) , ; // ZLA_COURS
    DevDecPos(ZLA->IdDev),  ;     // ZLA_DECPOS
    ZLA->IdDev,             ;     // ZLA_IDDEV
    ZLA->IdGen              ;     // ZLA_IDGEN
  } )
  skip
enddo
close area
RETURN NIL

**
** ZlaLocate()
**
FUNCTION ZlaLocate(cIdZla,cIdCtr)
local i
if saZla == NIL ; ZlaRefresh() ; endif
for i := 1 to len(saZla)
  if empty(saZla[i][ZLA_IDCTR]) .or. saZla[i][ZLA_IDCTR] == cIdCtr
    if saZla[i][ZLA_IDZLA] == cIdZla
      RETURN saZla[i]
    endif
  endif
next i
RETURN NIL

FUNCTION ZlaName(cIdZla,cIdCtr)
local zla := ZlaLocate(cIdZla,cIdCtr)
RETURN space(20) if zla == NIL
RETURN zla[ZLA_NAME]

FUNCTION ZlaDecPos(cIdZla,cIdCtr)
local zla := ZlaLocate(cIdZla,cIdCtr)
RETURN 0 if zla == NIL
RETURN zla[ZLA_DECPOS]

FUNCTION PickZla(cStart,nField)
local i
local nStart := 0
local a := {}
if saZla == NIL ; ZlaRefresh() ; endif
* default cTitle to "Zahlart"
for i := 1 to len(saZla)
  * if empty(saZla[i][ZLA_IDCTR]) .or. saZla[i][ZLA_IDCTR] == cIdCtr
    aadd(a, saZla[i])
    if saZla[i][ZLA_IDZLA] == cStart
      nStart := len(a)
    endif
  * endif
next i
browse array a ;
             using {|x| ;
               x[ZLA_IDZLA] + " " + x[ZLA_NAME] ;
             } ;
             delete {||.f.} ;
             title ("Zahlart") ;
             help "ZLA" ;
             start nStart
RETURN NIL if LastChoice() == 0
RETURN a[LastChoice()][nField] if nField != NIL
RETURN a[LastChoice()]

#endif DEF_KVK


#ifdef DEF_FNA

FUNCTION FnaRefresh()
local fna
saFna := {}
open area oFna()
  go top
  do while ! eof()
    fna := array(FNA_ALEN)
    fna[FNA_IDGEN]  := FNA->IdGen
    fna[FNA_EXPR]   := trim(FNA->Expr)
    fna[FNA_IDGEN1] := FNA->IdGen1
    fna[FNA_IDGEN2] := FNA->IdGen2
    aadd(saFna,fna)
    skip
  enddo
close area
RETURN NIL

FUNCTION FnaLocate(cIdGen)
local i
if saFna == NIL ; FnaRefresh() ; endif
for i := 1 to len(saFna)
  if saFna[i][FNA_IDGEN] == cIdGen
    if empty(saFna[i][FNA_EXPR]) .or. &(saFna[i][FNA_EXPR])
      RETURN saFna[i]
    endif
  endif
next i
RETURN NIL

#endif DEF_FNA

#ifdef DEF_PROVI

#define GPR_EXPR     1
#define GPR_DEFAULT  2
#define GPR_ALEN     2

FUNCTION GprRefresh
saGpr := ReadArray("GPR.DBC",GPR_ALEN)
RETURN NIL

**
** GprDefault()
**
FUNCTION GprDefault(cDefault)
local i
if saGpr == NIL ; GprRefresh() ; endif
for i := 1 to len(saGpr)
  RETURN xparse(saGpr[i][GPR_DEFAULT]) if empty(saGpr[i][GPR_EXPR])
  RETURN xparse(saGpr[i][GPR_DEFAULT]) if xparse(saGpr[i][GPR_EXPR])
next i
RETURN cDefault

#endif DEF_PROVI

#ifdef DEF_LGT

**
** LgtRefresh()
**
FUNCTION LgtRefresh()
local a
saLgt := {}
open area oLgt()
  go top
  do while ! eof()
    a := array(LGT_ALEN)
    * a[LGT_IDLGT    ] := LGT->IdLgt
    a[LGT_XLWHEN  ] := trim(LGT->xlWhen)
    a[LGT_NAME  ] := trim(LGT->Name)
    #ifdef DEF_GEN
      a[LGT_IDGEN ] := FieldIdGen()
    #else
      a[LGT_IDGEN ] := NIL
    #endif
    a[LGT_IDTAX ] := LGT->IdTax
    a[LGT_XNBASE] := trim(LGT->xnBase)
    aadd(saLgt, a)
    skip
  enddo
close area
RETURN NIL

FUNCTION LgtLocate()
local i
if saLgt == NIL ; LgtRefresh() ; endif
for i := 1 to len(saLgt)
  if &(saLgt[i][LGT_XLWHEN]) //  == cId
    RETURN saLgt[i]
  endif
next i
RETURN NIL

*FUNCTION LgtName(cId)
*local lgt := LgtLocate(cId)
*RETURN "" if lgt == NIL
*RETURN lgt[LGT_NAME]

*FUNCTION LgtExist(cId)
*RETURN .t. if LgtLocate(cId) != NIL
*SetMsg(cId + MsgLgtExist())
*RETURN .f.

*FUNCTION MsgLgtExist()
*RETURN " : unbekannte Leergut-Art !"

*FUNCTION PickLgt(cStart,cTitle)
*local nStart := 0
*local i
*default cTitle to "Leergut"
*if saLgt == NIL ; LgtRefresh() ; endif
*for i := 1 to len(saLgt)
*  if saLgt[i][LGT_IDLGT] == cStart
*    nStart := i
*  endif
*next i
*browse array saLgt ;
*             using {|x| ;
*               x[LGT_IDLGT] + " " + padr(x[LGT_NAME],50) ;
*             } ;
*             delete {||.f.} ;
*             title (cTitle) ;
*             start nStart ;
*             help "LGT"
*RETURN NIL if LastChoice() == 0
*RETURN saLgt[LastChoice()][LGT_IDLGT]

#endif DEF_LGT

#ifdef DEF_FRF

**
** FrfRefresh()
**
FUNCTION FrfRefresh()
local a
saFrf := {}
open area oFrf()
  go top
  do while ! eof()
    a := array(FRF_ALEN)
    a[FRF_XLWHEN  ] := trim(FRF->xlWhen)
    #ifdef DEF_GEN
      a[FRF_IDGEN ] := FieldIdGen()
    #else
      a[FRF_IDGEN ] := NIL
    #endif
    a[FRF_IDTAX ] := FRF->IdTax
    a[FRF_XNBASE] := trim(FRF->xnBase)
    a[FRF_XNTAXE] := trim(FRF->xnTaxe)
    aadd(saFrf, a)
    skip
  enddo
close area
RETURN NIL

FUNCTION FrfLocate()
local i
if saFrf == NIL ; FrfRefresh() ; endif
for i := 1 to len(saFrf)
  if &(saFrf[i][FRF_XLWHEN]) //  == cId
    RETURN saFrf[i]
  endif
next i
RETURN NIL

#endif DEF_FRF





#ifdef DEF_VENREMISE

**
** VnrRefresh()
**
FUNCTION VnrRefresh()
local a
saVnr := {}
open area oVnr()
  go top
  do while ! eof()
    a := array(VNR_ALEN)
    a[VNR_FLDNAME] := trim(VNR->FldName)
    a[VNR_XLWHEN]  := trim(VNR->xlWhen)
    a[VNR_XNMULT]  := trim(VNR->xnMult)
    aadd(saVnr, a)
    skip
  enddo
close area
RETURN NIL

FUNCTION VenVnrLoad()
local i
local a := {}
if saVnr == NIL ; VnrRefresh() ; endif
for i := 1 to len(saVnr)
  * if xparse(saVnr[i][VNR_XLWHEN])
  // VEN->MontR usw. sollen *immer* den Basisbetrag enthalten, auch wenn
  // keine ErmÑ·igung angewendet wurde.
  // VNR_XLWHEN wird erst in VenMvtRemise() ausgewertet.
  // Achtung: bei bestehenden
  // Dokumente ist VEN->MontR also leer, wenn VEN->Remise leer ist. Aber
  // das ist nicht schlimm, weil dann ja keine ErmÑ·igung gedruckt wird.
  * N.B.: Wird seit 2001-01-15 in VenRecTest() korrigiert.
    saVnr[i][VNR_MONT] := 0
    aadd(a, saVnr[i])
  * endif
next i
RETURN a

#endif DEF_VENREMISE





FUNCTION LngText(c1,c2,c3,c4)
#ifdef DEF_4LANG
  RETURN c4 if TplLang() == MemLang4 .and. !empty(c4)
#endif
RETURN c2 if TplLang() == MemLang2 .and. !empty(c2)
RETURN c3 if TplLang() == MemLang3 .and. !empty(c3)
RETURN c1



#ifdef DEF_RUN

**
** REFRESH_METHODS
**
** Read the table once into static array
**

FUNCTION SetCatType(cCatType,cCatList,cSex)
RETURN scCatType if cCatType == NIL
RETURN .f. if ! CtyExist(cCatType)
RETURN .t. if scCatType == cCatType .and. scCatList == cCatList .and. scSex == cSex
scCatType := cCatType
scCatList := cCatList
scSex := cSex
saCat := NIL
RETURN .t.

FUNCTION CtyExist(cIdCty)
local lFound := .f.
open area oCty()
  seek cIdCty
  lFound := found()
close area
RETURN lFound


FUNCTION CatRefresh
local a
saCat := {}
open area oCat()
  softseek scCatType
  do while ! eof() .and. CAT->IdCty == scCatType
    if empty(scCatList) .or. CAT->IdCat $ scCatList
      if empty(scSex) .or. CAT->Sex == scSex
        a := array(CAT_ALEN)
        a[CAT_IDCAT]    := CAT->IdCat
        a[CAT_NAME]     := CAT->Name
        a[CAT_AGELIMIT] := val(CAT->MaxAge)
        a[CAT_SEX]      := CAT->Sex
        aadd(saCat,a)
      endif
    endif
    skip
  enddo
close area
RETURN NIL

* FUNCTION ClbRefresh
* saClb := ReadArray("CLB.DBC",CLB_ALEN)
* RETURN NIL

FUNCTION EquRefresh
saEqu := ReadArray("EQU.DBC",EQU_ALEN)
RETURN NIL


FUNCTION CatLocate(cId)
local i
if saCat == NIL ; CatRefresh() ; endif
for i := 1 to len(saCat)
  RETURN saCat[i] if saCat[i][CAT_IDCAT] == cId
next i
RETURN NIL

FUNCTION CatExist(cId,cCatType)
if cCatType != NIL
  SetCatType(cCatType)
endif
RETURN (CatLocate(cId) != NIL)


**
** PickCat()
**
FUNCTION PickCat(cSex,cStart)
local i
local nStart := 0
local a := {}
if saCat == NIL ; CatRefresh() ; endif
for i := 1 to len(saCat)
  if cSex == NIL .or. empty(saCat[i][CAT_SEX]) .or. saCat[i][CAT_SEX] == cSex
    aadd(a,saCat[i])
    if saCat[i][CAT_IDCAT] == cStart
      nStart := len(a)
    endif
  endif
next i
browse array a using {|tax| ;
                       tax[CAT_IDCAT] + " " + ;
                       tax[CAT_NAME] ;
                     } ;
               title ("CatÇgories " + cSex) ;
               start nStart ;
               help "CAT"
RETURN NIL if lastchoice() == 0
RETURN a[lastchoice()][CAT_IDCAT]

FUNCTION CatList
if saCat == NIL ; CatRefresh() ; endif
RETURN saCat

FUNCTION CatName(cId)
local cat := CatLocate(cId)
RETURN "" if cId == NIL
RETURN cat[CAT_NAME]

**
** PickClb()
**
*FUNCTION PickClb(cStart)
*local i
*local nStart := 0
*if saClb == NIL ; ClbRefresh() ; endif
*for i := 1 to len(saClb)
*  if saClb[i][CAT_IDCAT] == cStart
*    nStart := i
*  endif
*next i
*browse array saClb using {|tax| ;
*                       tax[CLB_IDCLB] + " " + ;
*                       padr(tax[CLB_NAME],30) ;
*                     } ;
*               title ("SÇlection Club") ;
*               start nStart ;
*               help "CLB"
*RETURN NIL if lastchoice() == 0
*RETURN saClb[lastchoice()][CLB_IDCLB]

**
** PickEqu()
**
FUNCTION PickEqu(cStart)
local i
local nStart := 0
if saEqu == NIL ; EquRefresh() ; endif
for i := 1 to len(saEqu)
  if saEqu[i][EQU_IDEQU] == cStart
    nStart := i
  endif
next i
browse array saEqu using {|tax| ;
                       tax[EQU_IDEQU] + " " + ;
                       padr(tax[EQU_NAME],30) ;
                     } ;
               title ("SÇlection Equipe") ;
               start nStart ;
               help "EQU"
RETURN NIL if lastchoice() == 0
RETURN saEqu[lastchoice()][EQU_IDEQU]

#define RALATTR_Y "Y"


FUNCTION ParCatDefault(dDate)
local nAge
local i
local cIdCat := space(LenIdCat())
if saCat == NIL ; CatRefresh() ; endif
if RALATTR_Y $ RAL->Attrib
// if AgeByYear()
  nAge := year(dDate) - year(PAR->Birth)
else
  nAge := Age(PAR->Birth,dDate+1)
endif
for i := 1 to len(saCat)
  * 20050131
  if empty(saCat[i][CAT_SEX]).or.saCat[i][CAT_SEX] == PAR->Sex
    if nAge <= saCat[i][CAT_AGELIMIT]
      cIdCat := saCat[i][CAT_IDCAT]
      exit
    endif
  endif
next i
RETURN cIdCat


FUNCTION t19991026
local aDir := directory(DbPath()+"\CAT*.DBC")
local i,j
for i := 1 to len(aDir)
  scCatType := substr(aDir[i][F_NAME],4)
  scCatType := left(scCatType,at(".",scCatType)-1)
  saCat := ReadArray("CAT" + scCatType + ".DBC",CAT_ALEN)
  open area oCat()
    for j := 1 to len(saCat)
      if dbAddRec()
        CAT->IdCty  := scCatType
        CAT->Seq    := padl(ntrim(j),3,"0")
        CAT->IdCat  := saCat[j][CAT_IDCAT]
        CAT->MaxAge := saCat[j][CAT_AGELIMIT]
        CAT->Name   := saCat[j][CAT_NAME]
        CAT->Sex    := saCat[j][CAT_SEX]
        unlock record
      endif
    next j
  close area
  open area oCty()
    if dbAddRec()
      CTY->IdCty := scCatType
      unlock record
    endif
  close area
next i
RETURN .t.


FUNCTION AddPosColumns(cCatType)
local a := {}
local i
local lFound
local cHeader
open area oCat()
  softseek cCatType
  do while ! eof() .and. CAT->IdCty == cCatType
    if empty(RAL->CatList) .or. CAT->IdCat $ RAL->CatList
      if empty(RAL->Sex) .or. CAT->Sex == RAL->Sex
        lFound := .f.
        for i := 1 to len(a)
          if a[i][1] == trim(CAT->Header)
            if !empty(a[i][2])
              a[i][2] += ","
            endif
            a[i][2] += CAT->IdCat
            lFound := .t.
            exit
          endif
        next i
        if ! lFound
          aadd(a, { trim(CAT->Header), CAT->IdCat } )
        endif
      endif
    endif
    skip
  enddo
close area
for i := 1 to len(a)
  cHeader := '"'+a[i][1]+'"'
  cHeader := strtran(cHeader,"|",chr(10))
  AddExpField( ;
    cHeader , ;
    "if(POS->IdCat$'"+a[i][2]+"',ltrim(POS->CatPlace),'')" ;
  )
next i
RETURN .t.

#endif DEF_RUN


#ifdef DEF_RSV

*FUNCTION TslRefresh()
*local tsl
*saTsl := {}
*open area oTsl()
*  go top
*  do while ! eof()
*    tsl := array(TSL_ALEN)
*    tsl[TSL_IDTSL]  := TSL->IdTsl
*    tsl[TSL_TIME1]  := TSL->Time1
*    tsl[TSL_TIME2]  := TSL->Time2
*    aadd(saTsl,tsl)
*    skip
*  enddo
*close area
*RETURN NIL
*
*FUNCTION TslIndex(cTime1,cTime2)
*local i
*if saTsl == NIL ; TslRefresh() ; endif
*for i := 1 to len(saTsl)
*  if empty(cTime1).or.saTsl[i][TSL_TIME1] >= cTime1
*    if empty(cTime2).or.saTsl[i][TSL_TIME2] >= cTime2
*      RETURN i
*    endif
*  endif
*next i
*RETURN NIL
*
*FUNCTION TslList()
*if saTsl == NIL ; TslRefresh() ; endif
*RETURN saTsl



FUNCTION RstRefresh()
local a
saRst := {}
open area oRst()
  go top
  do while ! eof()
    a := array(RST_ALEN)
    a[RST_IDRST]    := RST->IdRst
    a[RST_NAME]     := RST->Name
    aadd(saRst,a)
    skip
  enddo
close area
RETURN NIL

FUNCTION RstLocate(cIdRst)
local i
if saRst == NIL ; RstRefresh() ; endif
for i := 1 to len(saRst)
  if saRst[i][RST_IDRST] == cIdRst
    RETURN saRst[i]
  endif
next i
RETURN NIL

**
** PickRst()
**
FUNCTION PickRst(cStart,cTitle)
local nStart := 0
local i
if saRst == NIL ; RstRefresh() ; endif
for i := 1 to len(saRst)
  if saRst[i][RST_IDRST] == cStart
    nStart := i
  endif
next i
default cTitle to "Ressourcenart"
browse array saRst using {|x| ;
                         x[RST_IDRST] + " " + ;
                         padr(x[RST_NAME],40) } ;
             delete {||.f.} ;
             start nStart ;
             help "RST" ;
             title (cTitle)
if lastchoice() != 0
   RETURN saRst[LastChoice()][RST_IDRST]
endif
RETURN NIL
**
FUNCTION RstExist(cId)
RETURN .t. if RstLocate(cId) != NIL
SetMsg(cId + " : unbekannte Resourcenart !")
RETURN .f.

#endif DEF_RSV

FUNCTION MsgExpertOnly()
#ifdef LG_GERMAN
  RETURN " : nur fÅr Experten !"
#else
  RETURN " : rÇservÇ aux experts !"
#endif


