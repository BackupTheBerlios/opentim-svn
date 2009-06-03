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
  #define MSG001  "Correspondance "
  static MSG003 := "SignalÇtique "
  static MSG_PAREDIT := "SignalÇtique particuliers"
  * #define MSG004  "SignalÇtique Fournisseurs"
  #define MSG005  "Groupes d'articles"
  static MSG006 := "SignalÇtique Articles"
  * #define MSG007  "Paie"
  * #define MSG008  "Journal opÇrations diverses "
  static MSG009 := "Comptes gÇnÇraux"
  #define MSG010  "Liste des journaux "
  * #define MSG011  "Codes TVA"
  * #define MSG012  "CatÇgories fiscales"
  * #define MSG013  "Liste des rÇgimes TVA"
  #define MSG014  "Configuration Devises"
  * #define MSG015  "DiffÇrences de paiement"
  #define MSG016  "Agenda personnel..."
  * #define MSG017  "Programmes externes"
  #define MSG018  "SignalÇtique Tarifs"
  * #define MSG019  "Codes profession"
  #define MSG021  "Gestion des pÇriodes"
  * #define MSG022  "Mouvements comptables"
  #define MSG023  "Correspondance tiers"
  #define MSG025  "Modes de paiement"
  #define MSG026  "DÇclaration T.V.A."
  #define MSG027  "Liste des codes postaux"
  * #define MSG028  "DegrÇs de rappel"
  #define MSG029  "Agenda public"
  #define MSG030  "Agenda "
  #define MSG031  "Feuilles de calcul"
  #define MSG032  "Champs de la feuille de calcul "
  #define MSG033  " : aperáu global"
  * #define MSG034  "Configuration Phases de commande"
  #define MSG035  " : conditions spÇciales"
  #define MSG036  "Substituts d'article "
  * #define MSG037  "Instructions d'imputation"
  #define MSG038  "Masques et blocs de texte"
  * #define MSG039  "Instructions de facturation"
  * #define MSG040  "Configuration Etapes de rendez-vous"
  static MSG_CTG := "Historique centralisÇ "
  static MSG_QTS := "QuantitÇs en stock "
#else
  #define MSG001  "Korrespondenz "
  static MSG003 := "Stammdaten "
  static MSG_PAREDIT := "Stammdaten Partner"
  * #define MSG004  "Stammdaten Lieferanten"
  #define MSG005  "Artikelgruppen"
  static MSG006 := "Stammdaten Artikel"
  * #define MSG007  "Konfigurierung Journale"
  * #define MSG008  "Sonstige Buchungen "
  static MSG009 := "Generalkonten"
  #define MSG010  "Journale "
  * #define MSG011  "MWSt-Codes"
  * #define MSG012  "Steuerkategorien"
  * #define MSG013  "MWSt-Regimes"
  #define MSG014  "Konfigurieren WÑhrungen"
  * #define MSG015  "Zahlungsdifferenzen"
  #define MSG016  "persînliche Termine..."
  * #define MSG017  "Externe Programme"
  #define MSG018  "Stammdaten Tarife"
  * #define MSG019  "Berufsgruppen"
  #define MSG021  "Buchungsperioden"
  #define MSG022  "Haushaltsartikel"
  #define MSG023  "Drittkorrespondenz"
  #define MSG025  "Zahlarten"
  #define MSG026  "MWSt-ErklÑrung"
  #define MSG027  "Postleitzahlen"
  * #define MSG028  "Bewegungen Partnerkonten"
  #define MSG029  "ôffentliches Agenda"
  #define MSG030  "Agenda "
  #define MSG031  "Berechnungstabellen"
  #define MSG032  "Felder der Berechnungstabelle "
  #define MSG033  " : öbersicht"
  * #define MSG034  "Konfigurierung Bestellphasen"
  #define MSG035  " : Sonderbedinungen"
  #define MSG036  "Artikel-Substitute "
  * #define MSG037  "Buchungsanweisungen"
  #define MSG038  "Dokumentmasken und Textblîcke"
  * #define MSG039  "Fakturierungsanweisungen"
  * #define MSG040  "Konfigurierung Termin-Etappen"
  static MSG_CTG := "Sammelhistorik "
  static MSG_QTS := "LagerbestÑnde "
#endif


#ifdef DEF_TRA
static scTraIdJnl := NIL
#endif

*#ifdef DEF_PFS
*
*static snPfsMontD := 0
*static snPfsMontC := 0
*
*#endif DEF_PFS

#ifdef DEF_ART

FUNCTION ArtPage(cIdArt,cIdQry)
* local cIdQry := "ART"
open area oArt(), oPar(), oGra(), oAcf()
  if cIdArt != NIL
    seek cIdArt
  endif
  if cIdQry == NIL
    cIdQry := "ART"
    #ifdef DEF_GRA
      if ! empty(ART->iGra)
        seek ART->iGra in GRA
        if empty(GRA->IdQry)
          cIdQry := "ARTGRA"
        else
          cIdQry := "ART" + trim(GRA->IdQry)
        endif
      endif
    #endif DEF_GRA
  endif
  edit data oArt() full noskip query (cIdQry) title (MSG006)
close area
SetMnuDone()
RETURN .t.

#endif DEF_ART


#ifdef DEF_VNA

FUNCTION VnaVnlEdit(cTitle)
local a
local b := oVnl()
SetMnuDone()
RETURN .f. if ( a := ArtVnlInit()) == NIL
default cTitle to "OpÇrations qui suivent "+VNA->IdJnl+VNA->IdDoc+VNA->Line
open area b, oVen(), oPar(), oArt(), oGen()
  ddSetOrder(3)
  edit data b key VNL->Match ;
    value    VNA->IdJnl+VNA->IdDoc+VNA->Line        ;
    start    bottom                 ;
    mode     show  ;
    query ("VNLVNA") ;
    title (cTitle)
close area
VnlRestore(a)
RETURN .t.



#endif DEF_VNA

#ifdef DEF_VEN

**
**
FUNCTION ArtVnlEdit(cIdArt,cTitle)
local a
local b := oVnl(DocStatClosed())
cIdArt := padr(cIdArt,LenObjet())
RETURN SetMnuDone() if ( a := ArtVnlInit()) == NIL
#ifdef LG_GERMAN
  default cTitle to "Fakturierung " + trim(SayIdArt(cIdArt))
#else
  default cTitle to "Facturation " + trim(SayIdArt(cIdArt))
#endif
open area b, oVen(DocStatClosed()), oPar(), oArt(), oGen()
  ddSetOrder(ORD_VNL_ART)
  edit data b key FIELD->IdArt ;
    value    cIdArt        ;
    start    bottom                 ;
    mode     show  ;
    query ("VNLART") ;
    title (cTitle)
close area
VnlRestore(a)
RETURN SetMnuDone()

**
** ArtVnlWait() -
**
FUNCTION ArtVnlWait(wwin)
local cIdArt := padr(FIELD->IdArt,LenObjet())
local b := oVnl(DocStatClosed())
local a
RETURN NIL if ( a := ArtVnlInit()) == NIL
open area b, oVen(DocStatClosed()), oPar(), oArt(), oGen()
  ddSetOrder(ORD_VNL_ART)
  edit data b key    FIELD->IdArt ;
              value  cIdArt       ;
              start  bottom       ;
              mode   wait  ;
              query  ("VNLART") ;
              window wwin
close area
VnlRestore(a)
RETURN NIL

#endif DEF_VEN

FUNCTION ParPage(cId,cIdQry,nMode,cTitle)
local prt
default nMode to DDMODE_EDIT
open area oPar(), oPlz(), oNat()
  if cId != NIL
    seek cId
  endif
  if (prt := PrtLocate(PAR->IdPrt)) != NIL
    default cIdQry to ("PAR" + prt[PRT_IDQRY])
    default cTitle to (MSG003 +  trim(prt[PRT_NAME]))
    edit data oPar() ;
              full ;
              noskip ;
              mode (nMode) ;
              query (cIdQry) ;
              create {||DDCREATE_FAIL} ;
              title (cTitle)
  else
    SetMsg(PAR->IdPrt+MsgPrtExist())
  endif
close area
RETURN MnuDone()

#ifdef DEF_GEN

FUNCTION GenPage(cId)
local b := oGen()
open area b
  if cId != NIL
    seek cId
  endif
  edit data b ;
            full ;
            noskip ;
            query "GEN" ;
            title (MSG003 + MSG009)
close area
RETURN MnuDone()

#endif DEF_GEN

#ifdef DEF_PRJ

FUNCTION PrjPage(cId)
local b := oPrj()
open area b, oPar()
  if cId != NIL
    seek cId
  endif
  edit data b ;
            full ;
            noskip ;
            query "PRJ" ;
            title ("Project "+alltrim(cId))
close area
RETURN MnuDone()

#endif DEF_GEN

FUNCTION DbfPage(ad,cId,cIdQry,cTitle)
begin sequence
  if ! AreaOpen( ad, .f. ) ; break ; endif
    seek cId
    ddEdit( ad[1],.t.,  ;
            NIL,      ;
            NIL,     ;
            NIL,  ;
            NIL,  ;
            {},  ;
            NIL, ;
            NIL, NIL, cIdQry, ;
            NIL, NIL,    ;
            NIL, .t. , NIL, ;
            cTitle, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL, .f.;
           )


  AreaClose()
end sequence
RETURN MnuDone()



#ifdef DEF_JNL

**
** DocPage()
**
FUNCTION DocPage(cIdJnl,cIdDoc)
local jnl := JnlLocate(cIdJnl)
local b
RETURN MnuDone() if jnl == NIL
#ifdef DEF_KVK
  if jnl[JNL_ALIAS] == JNLALIAS_KVK
    b := oKvk()
    ** Ñhnlich wie KvkEdit() :
    open area b, oPar(), oPlz(), oNat()
      seek cIdJnl + cIdDoc
      seek KVK->IdPar in PAR
      edit data b ;
        key KVK->IdJnl + KVK->IdDoc ;
        value cIdJnl + cIdDoc ;
        create   {||DDCREATE_FAIL} ;
        query ("KVK"+jnl[JNL_IDDBV]) ;
        mode edit  ;
        noskip ;
        full ;
        title (cIdJnl + " " + cIdDoc)
    close area
    RETURN MnuDone()
  endif
#endif DEF_KVK
#ifdef DEF_VEN
  if jnl[JNL_ALIAS] == "VEN"
    b := oVen()
    ** Ñhnlich wie VenEdit() :
    open area b, oPar(), oPlz(), oNat(), oPrj()
      seek cIdJnl + cIdDoc
      seek VEN->IdPar in PAR
      edit data b ;
        key VEN->IdJnl + VEN->IdDoc ;
        value cIdJnl + cIdDoc ;
        create   {||DDCREATE_FAIL} ;
        query ("VEN"+jnl[JNL_IDDBV]) ;
        mode edit  ;
        noskip ;
        full ;
        title (cIdJnl + " " + cIdDoc)
    close area
    RETURN MnuDone()
  endif
#endif DEF_VEN
#ifdef DEF_FIN
  if jnl[JNL_ALIAS] == "FIN"
    b := oFin()
    ** Ñhnlich wie FinEdit() :
    open area b
      seek cIdJnl + cIdDoc
      edit data b ;
        key FIN->IdJnl + FIN->IdDoc ;
        value cIdJnl + cIdDoc ;
        create   {||DDCREATE_FAIL} ;
        query ("FIN"+jnl[JNL_IDDBV]) ;
        mode edit  ;
        noskip ;
        full ;
        title (cIdJnl + " " + cIdDoc)
    close area
    RETURN MnuDone()
  endif
#endif DEF_FIN
#ifdef DEF_MVA
  if jnl[JNL_ALIAS] == "ODA"
    b := oOda()
    ** Ñhnlich wie OdaEdit() :
    open area b
      seek cIdJnl + cIdDoc
      edit data b ;
        key ODA->IdJnl + ODA->IdDoc ;
        value cIdJnl + cIdDoc ;
        create   {||DDCREATE_FAIL} ;
        query ("ODA"+jnl[JNL_IDDBV]) ;
        mode edit  ;
        noskip ;
        full ;
        title (cIdJnl + " " + cIdDoc)
    close area
    RETURN MnuDone()
  endif
#endif DEF_MVA
#ifdef DEF_IMP
  if jnl[JNL_ALIAS] == "IMP"
    b := oImp()
    ** Ñhnlich wie ImpEdit() :
    open area b, oPar(), oPlz(), oNat()
      seek cIdJnl + cIdDoc
      edit data b ;
        key IMP->IdJnl + IMP->IdDoc ;
        value cIdJnl + cIdDoc ;
        create   {||DDCREATE_FAIL} ;
        query ("IMP"+jnl[JNL_IDDBV]) ;
        mode edit  ;
        noskip ;
        full ;
        title (cIdJnl + " " + cIdDoc)
    close area
    RETURN MnuDone()
  endif
#endif DEF_IMP
#ifdef DEF_ODS
  if jnl[JNL_ALIAS] == "ODS"
    b := oOds()
    ** Ñhnlich wie OdsEdit() :
    open area b, oPar(), oPlz(), oNat()
      seek cIdJnl + cIdDoc
      edit data b ;
        key ODS->IdJnl + ODS->IdDoc ;
        value cIdJnl + cIdDoc ;
        create   {||DDCREATE_FAIL} ;
        query ("ODS"+jnl[JNL_IDDBV]) ;
        mode edit  ;
        noskip ;
        full ;
        title (cIdJnl + " " + cIdDoc)
    close area
    RETURN MnuDone()
  endif
#endif DEF_VEN
RETURN MnuDone()
              
#endif DEF_JNL

#ifdef DEF_VEN

**
** VenEdit()
**
FUNCTION VenEdit(jnl)
local b := oVen()
open area b, oPar(), oPlz(), oNat(), oPrj()
  if USRATTR_L $ UsrAttrib()
    goto (lastrec() + 1) // KeyGoBottom(jnl[JNL_IDJNL],"VEN->IdJnl",{||.t.})
    edit data b ;
      key VEN->IdJnl ;
      value jnl[JNL_IDJNL] ;
      create   {||DocCreate( jnl,{|cIdDoc| ;
        VenDocCreate(jnl,cIdDoc,NIL) ;
      })} ;
      query ("VEN"+jnl[JNL_IDDBV]) ;
      mode     find  ;
      title (MsgJournal() + jnl[JNL_IDJNL] + " : " + trim(jnl[JNL_NAME])) ;
      full
  else
    edit data b ;
      key VEN->IdJnl ;
      value jnl[JNL_IDJNL] ;
      create   {||DocCreate( ;
        jnl, ;
        {|cIdDoc|VenDocCreate(jnl,cIdDoc) } ;
      )} ;
      query ("VEN"+jnl[JNL_IDDBV]) ;
      mode     find  ;
      title (MsgJournal() + jnl[JNL_IDJNL] + " : " + trim(jnl[JNL_NAME])) ;
      start bottom
  endif
close area
RETURN MnuDone() // .f.

#endif DEF_VEN

#ifdef DEF_MVA

**
** OdaEdit()
**
FUNCTION OdaEdit(jnl)
local b := oOda()
open area b, oPar(), oGen()
  edit data b ;
    key ODA->IdJnl ;
    value jnl[JNL_IDJNL] ;
    create   {||DocCreate( ;
      jnl, ;
      {|cIdDoc|OdaCreate(jnl,cIdDoc) } ;
    )} ;
    query ("ODA"+jnl[JNL_IDDBV]) ;
    mode     find  ;
    title (MsgJournal() + jnl[JNL_IDJNL] + " : " + trim(jnl[JNL_NAME])) ;
    start bottom
close area
RETURN .f.

#endif DEF_MVA

*  #ifdef DEF_MOD
*
*  **
*  ** ModEdit()
*  **
*  FUNCTION ModEdit()
*  local b := oMod()
*  open area b, oPar()
*    edit data b ;
*      query ("MOD") ;
*      mode     find  ;
*      title ("Module") ;
*      start  bottom
*  close area
*  RETURN .f.
*
*  #endif DEF_MOD

#ifdef DEF_IMP

**
** ImpEdit()
**
FUNCTION ImpEdit(jnl)
local b := oImp()
open area b, oPar(), oBud(), oPrj()
  edit data b key IMP->IdJnl value jnl[JNL_IDJNL] ;
    create   {||ImpDlgCreate(jnl)} ;
    query ("IMP"+jnl[JNL_IDDBV]) ;
    mode     find  ;
    title (MsgJournal() + jnl[JNL_IDJNL] + " : " + trim(jnl[JNL_NAME])) ;
    start  bottom
close area
RETURN .f.

FUNCTION ImpDlgCreate(jnl)
if JNLATTR_G $ jnl[JNL_ATTRIB]
  Warning(jnl[JNL_IDJNL] + " : Journal fÅr manuelle Erfassung gesperrt !")
  RETURN DDCREATE_FAIL
endif
RETURN DocCreate( ;
 jnl, {|cIdDoc|ImpCreate(jnl,cIdDoc,NIL) } ;
)


#endif DEF_IMP

*#ifdef DEF_CMD
*
***
*** CmdEdit()
***
*FUNCTION CmdEdit(cIdJnl)
*local b := oCmd()
*open area b, oPar(), oPrj()
*  edit data b key CMD->IdJnl value cIdJnl ;
*    create   CmdCreate(cIdJnl) ;
*    query ("CMD"+JnlIdDbv(cIdJnl)) ;
*    mode     find  ;
*    title (MsgJournal() + cIdJnl + " : " + trim(JnlName(cIdJnl))) ;
*    start  bottom
*close area
*RETURN .f.
*
*#endif DEF_CMD

#ifdef DEF_CTS

FUNCTION ArtCtsEdit()
local cIdArt := ART->IdArt
local b := oCts()
open area b, oArt()
  edit data b key   CTS->IdArt ;
              value cIdArt ;
              title (MSG_CTG + trim(SayIdArt(cIdArt))) ;
              mode find ;
              query "CTSART"
close area
RETURN NIL

#endif DEF_CTS

#ifdef DEF_MVS

**
** MVS - globalsicht historik lager
**
FUNCTION MvsEdit(cTitle)
local b := oMvs()
open area b, oPar(), oArt()
  edit data b start top ;
            mode show ;
            query "MVS" ;
            title (cTitle)
close area
RETURN .f.

#endif DEF_MVS

#ifdef DEF_VNA

**
** VNA - globalsicht historik lagerverwaltung
**
FUNCTION VnaEdit(cTitle,cIdQry)
local b := oVna()
default cIdQry to "VNA"
open area b, oPar(), oArt(), oGen()
  edit data b start top mode find query (cIdQry) title (cTitle)
close area
RETURN .f.

#endif DEF_VNA

*#ifdef DEF_PRD
*
*FUNCTION ArtPrlEdit(cIdArt)
*local b := oPrl()
*open area b, oArt()
*  ddSetOrder(ORD_PRL_ART)
*  edit data b key   PRL->IdArt ;
*              value cIdArt ;
*              create DDCREATE_FAIL ;
*              title ("Zuweisungen " + trim(SayIdArt(cIdArt))) ;
*              mode edit ;
*              query "PRLART"
*close area
*RETURN NIL
*
*
*FUNCTION ArtPrdEdit(cIdArt)
*local b := oPrd()
*open area b, oArt()
*  ddSetOrder(ORD_PRD_ART)
*  edit data b key   PRD->IdArt ;
*              value cIdArt ;
*              create DDCREATE_FAIL ;
*              title ("Bons de production " + trim(SayIdArt(cIdArt))) ;
*              mode edit ;
*              query "PRDART"
*close area
*RETURN NIL
*
*
*#endif DEF_PRD


#ifdef DEF_TAX

**
** DcrEdit()
**
*FUNCTION DcrEdit()
*local b := oDcr()
*open area b
*  edit data b ;
*    mode     edit   ;
*    start    top ;
*    query "DCR" ;
*    title (MSG026)
*close area
*RETURN .f.


#endif DEF_TAX

#ifdef DEF_VAR

**
** VarEdit()
**
FUNCTION VarEdit(cIdVrt)
local b := oVar()
open area oVar()
  * open window (MSG003 + trim(VrtName(cIdVrt))) ;
  *             color (CfgBrowseColor())
  edit data b key VAR->IdVrt value cIdVrt ;
    create   {||VarCreate(cIdVrt)} ;
    query "VAR" ;
    mode     find  ;
    start  top ;
    title (MSG003 + trim(VrtName(cIdVrt)))
  * close window
close area
RETURN .f.

#endif DEF_VAR

#ifdef DEF_GEN

**
** GEN - ComptabilitÇ / Plan comptable
**
FUNCTION GenEdit()
// local b := oGen()
open area oGen(),oBil()
  edit data oGen() start top mode find query "GEN" title (MSG003 + MSG009)
close area
RETURN .f.

#endif DEF_GEN

#ifdef DEF_MSG

**
** MsgEdit()
**
FUNCTION MsgEdit(cIdUsr)
local b := oMsg()
default cIdUsr to UserId()
open area b, oPar()
  ddSetOrder(ORD_MSG_USER)
  edit data b key MSG->IdUsr value (cIdUsr) ;
    create   {||MsgCreate()}  ;
    mode     find                   ;
    start    top                    ;
    query "MSG"                         ;
    title (MSG001 + trim(cIdUsr))
close area
RETURN .f.

#endif DEF_MSG

**
** PlzEdit() - Codes postaux
**
FUNCTION PlzEdit
local b := oNat()
open area b
  edit data b mode find  ;
    query   "NATPICK" ;
    start   top ;
    title   (MSG027)
close area
*local nat := PickNat(NIL,MSG027)
*local b := oPlz()
*RETURN .f. if nat == NIL
*open area b
*  ddSetOrder(ORD_PLZ_NAME)
*  edit data b mode find  ;
*    key     PLZ->Pays ;
*    value   nat[NAT_IDNAT] ;
*    create  {||PlzCreate(nat[NAT_IDNAT],PLZ->CP)} ;
*    query   "PLZNAT" ;
*    start   top ;
*    title   (MSG027 + " " + trim(nat[NAT_NAME]))
*close area
RETURN .t.


**
** PrtParEdit() - SignalÇtique partenaires
**
FUNCTION PrtParEdit(cIdPrt,cIdQry,cTitle,nOrder,cFilter)
local b := oPar()
local prt := PrtLocate(cIdPrt)
if prt == NIL
  RETURN !SetMsg(cIdPrt+MsgPrtExist())
endif
if cIdQry == NIL
  cIdQry := "PAR" + prt[PRT_IDQRY]
else
  cIdQry := "PAR" + cIdQry
endif
default cTitle to MSG_PAREDIT + " : " + trim(prt[PRT_NAME])
default cFilter to "!'H'$PAR->Attrib"
default nOrder to ORD_PAR_PRTNAME
open area b, oPlz(), oNat(), oClb()
  ddSetOrder(nOrder)
  ParSetFilter(cFilter)
  if empty(cIdPrt) .or. trim(cIdPrt) == "*"
    edit data  b ;
         mode  find ;
         start top ;
         query (cIdQry) ;
         filter "ParEvalFilter()" ;
         title (cTitle)
  else
    edit data  b ;
         key   PAR->IdPrt ;
         value cIdPrt ;
         mode  find ;
         start top ;
         query (cIdQry) ;
         filter "ParEvalFilter()" ;
         title (cTitle)
  endif
close area
RETURN .f.

**
** ParEdit() - SignalÇtique particuliers
**
FUNCTION ParEdit(cIdQry,cTitle,nOrder,cFilter)
local b := oPar()
default cTitle to MSG_PAREDIT
default cFilter to "!'H'$PAR->Attrib"
default nOrder to ORD_PAR_ID
if cIdQry == NIL
  cIdQry := "PAR"
else
  cIdQry := "PAR" + cIdQry
endif
open area b, oPlz(), oNat(), oClb()
  ParSetFilter(cFilter)
  ddSetOrder(nOrder)
  edit data b ;  // create {||ParCreate(NIL)} ;
       mode  find ;
       start top ;
       query (cIdQry) ;
       filter "ParEvalFilter()" ;
       title (cTitle)
close area
RETURN .f.

* FUNCTION ParPickOrder(b)
* local cIdPrt := PickPrt(PAR->IdPrt)
* RETURN PickOrder(b) if cIdPrt == NIL
* ddSetKeyValue(cIdPrt)
* RETURN ORD_PAR_PRTNAME


#ifdef DEF_ART

**
** ArtEdit() - Liste de tous les articles
**
FUNCTION ArtEdit(cIdQry,cTitle,xlFilter)
local b := oArt()
default cTitle to MSG006
default xlFilter to ArtFilter()
* default xlFilter to "!'" + ARTATTR_H + "'$ART->Attrib"
default cIdQry to "ART"
open area b, oPar(), oGra(), oAcf(), oGen()
  edit data b ;
       create {||ArtCreate()} ;
       mode find ;
       query (cIdQry) ;
       start top ;
       title (cTitle) ;
       filter (xlFilter)
close area
RETURN .f.

#endif DEF_ART

#ifdef DEF_GRA

**
** GraEdit()
**
FUNCTION GraEdit(xcKeyBlock,cKeyValue)
local b := oGra()
open area b
  edit data b key (xcKeyBlock) ;
              value (cKeyValue) ;
              mode find query "GRA" title (MSG005)
close area
RETURN .f.

*#ifdef DEF_CFN
*
***
*** CfnGraEdit()
***
*FUNCTION CfnGraEdit(cIdCfn)
*RETURN .f. if cIdCfn == NIL
*open area oGra()
*  edit data b key GRA->IdCfn ;
*              value (cIdCfn) ;
*              mode find ;
*              create GraCreate(cIdCfn) ;
*              query "GRACFN" ;
*              title (MSG005)
*close area
*RETURN .f.
*
*#endif DEF_CFN

#endif DEF_GRA



#ifdef DEF_IVT

**
** IvtEdit()
**
FUNCTION IvtEdit()
local b := oIvt()
open area b
  edit data b ;
    mode     find   ;
    start    bottom ;
    query "IVT" ;
    title (MsgIvtEdit())
close area
RETURN .f.

FUNCTION MsgIvtEdit
#ifdef LG_GERMAN
  RETURN "Inventuren"
#else
  RETURN "Inventaires"
#endif

#endif DEF_IVT

#ifdef DEF_FIN

**
** FIN - Journaux financiers
**
FUNCTION FinEdit(jnl)
local b := oFin()
open area b
  if USRATTR_L $ UsrAttrib()
    goto lastrec() + 1
    edit data b mode find ;
      key FIN->IdJnl value jnl[JNL_IDJNL] ;
      query ("FIN"+jnl[JNL_IDDBV]) ;
      create   {||DocCreate( ;
        jnl, ;
        {|cIdDoc|FinCreate(jnl,cIdDoc) } ;
      )} ;
      title (MsgJournal() + jnl[JNL_IDJNL] + " : " + jnl[JNL_NAME]) ;
      full
  else
    edit data b mode find start bottom ;
      key FIN->IdJnl value jnl[JNL_IDJNL] ;
      query ("FIN"+jnl[JNL_IDDBV]) ;
      create   {|| DocCreate( ;
        jnl, ;
        {|cIdDoc|FinCreate(jnl,cIdDoc) } ;
      ) } ;
      title (MsgJournal() + jnl[JNL_IDJNL] + " : " + jnl[JNL_NAME])
  endif
close area
RETURN .f.

#endif DEF_FIN

#ifdef DEF_ODS

**
** ODS -
**
FUNCTION OdsEdit(jnl)
local b := oOds()
open area b, oPar()
  edit data b mode find start bottom ;
    key ODS->IdJnl value jnl[JNL_IDJNL] ;
    query ("ODS"+jnl[JNL_IDDBV]) ;
    create   {|| DocCreate( ;
      jnl, ;
      {|cIdDoc|OdsCreate(jnl,cIdDoc) } ;
    )} ;
    title (MsgJournal() + jnl[JNL_IDJNL] + " : " + jnl[JNL_NAME])
close area
RETURN .f.

#endif DEF_ODS


**
** MVT - Mouvements
**
* FUNCTION MvtEdit(cTitle)
* local b := oMvt()
* open area b, oGen(), oPar()
*   edit data b ;
*             start top ;
*             mode  show ;
*             query "MVT" ;
*             title (cTitle)
* close area
* RETURN .f.

#ifdef DEF_CTG

**
** CTG
**
FUNCTION CtgEdit(cTitle)
local b := oCtg()
open area b, oGen()
  edit data b start top mode show query "CTG" title (cTitle)
close area
RETURN .f.

#endif DEF_CTG


*#ifdef DEF_SHT
*
***
*** SHT - Feuilles de calcul
***
*FUNCTION ShtEdit()
*local b := oSht()
*open area b
*  edit data b ;
*            mode pick ;
*            query "SHT" ;
*            start top ;
*            title (MSG031)
*  if ddLastReq(b) == DDEDIT_SELECT
*    ShtPrint()
*  endif
*close area
*RETURN .f.
*
***
*** ShtBalEdit()
***
*FUNCTION ShtBalEdit()
*local b := oBal()
*local cIdSht := SHT->IdSht
*  open area b
*    edit data b key BAL->IdSht value cIdSht ;
*                create {||BalCreate(cIdSht)} ;
*                mode edit ;
*                start top ;
*                query "BAL" ;
*                title (MSG032+cIdSht)
*  close area
*RETURN .f.
*
*#endif DEF_SHT


#ifdef DEF_SUB

**
**
**
FUNCTION ArtSubEdit(cIdArt)
local ad := oSub()
* open window (MSG036 + trim(ArtName(cIdArt))) size 10,60
  open area ad, oArt()
    edit data ad key SUB->IdArt1 value cIdArt ;
                create {||SubCreate(cIdArt)} ;
                query "SUB" ;
                mode edit ;
                start top ;
                title (MSG036 + trim(ArtName(cIdArt)))
  close area
* close window
RETURN .f.

#endif DEF_SUB

#ifdef DEF_PRJ

**
** PrjEdit()
**
FUNCTION PrjEdit()
local b := oPrj()
open area b, oPar()
  edit data b ;
            start top ;
            mode find ;
            query "PRJ" ;
            title ("Projekte")
close area
RETURN .f.

#endif DEF_PRJ

#ifdef DEF_PIN

**
** PrjPinEdit()
**
FUNCTION PrjPinEdit()
local b := oPin()
local cIdPrj := PRJ->IdPrj
open area b, oPrj()
  ddSetOrder(ORD_PIN_IDPRJ)
  edit data b key PIN->IdPrj ;
              value cIdPrj ;
              create {||PinCreate(cIdPrj)} ;
              mode find ;
              start bottom ;
              query "PINPRJ" ;
              title (trim(PRJ->Name1) + " : Pinwand")
              * query ORD_PIN_IDPRJ ;
close area
RETURN .f.

**
** PinEdit()
**
FUNCTION PinEdit()
local b := oPin()
open area b, oPrj()
  ddSetOrder(ORD_PIN_CODE)
  edit data b create {||PinCreate(NIL)} ;
              mode find ;
              start bottom ;
              query "PIN" ;
              title ("Pinwand")
close area
RETURN .f.

#endif DEF_PIN


#ifdef DEF_HOLZ

**
** StmEdit()
**
FUNCTION StmEdit()
local b := oStm()
open area b, oArt()
  ddSetOrder(ORD_STM_ID)
  edit data b create {||StmCreate()} ;
              mode find ;
              start top ;
              query "STM" ;
              title ("Stammdaten BaumstÑmme")
close area
RETURN .f.

**
** PrjStmEdit()
**
FUNCTION PrjStmEdit()
local b := oStm()
local cIdPrj := PRJ->IdPrj
open area b, oArt(), oPar()
  ddSetOrder(ORD_STM_PRJ)
  edit data b key STM->IdPrj ;
              value cIdPrj ;
              create {||StmCreate(NIL,NIL,cIdPrj)} ;
              mode find ;
              start bottom ;
              query "STMPRJ" ;
              title (trim(PRJ->Name1) + " : Holzliste")
close area
RETURN .f.

**
** VenStmEdit()
**
FUNCTION VenStmEdit()
local cIdJnl := VEN->IdJnl
local cIdDoc := VEN->IdDoc
local cIdPrj := VEN->IdPrj
local b := oStm()
local aLn
open area b, oArt()
  ddSetOrder(StmOrder(cIdJnl)) // bis 19980722 : ORD_STM_DOC
  edit data b key &("STM->"+cIdJnl+"IdDoc") ;
              value cIdDoc ;
              create {||StmCreate(cIdJnl,cIdDoc,cIdPrj)} ;
              mode edit ;
              start bottom ;
              query ("STM"+cIdJnl) ;
              title (cIdJnl + " " + cIdDoc + " : StÅckliste")
close area
RETURN .f. if nKey == K_ESC
if VEN->Etat == DocStatNew()
  aLn := VenStmCollect()
  open area oVnl(VEN->Etat)
    VnlGenerate(aLn,VEN->IdJnl,VEN->IdDoc) // ,.t.)
  close area
endif
RETURN .t.

FUNCTION StmOrder(cIdJnl)
local nOrder := ORD_STM_PRJ
local aJnl := JnlList({|jnl|JNLATTR_D $ jnl[JNL_ATTRIB]})
local i
for i := 1 to len(aJnl)
  nOrder++
  RETURN nOrder if aJnl[i][JNL_IDJNL] == cIdJnl
next i
RETURN NIL



**
** VenStmCollect() - array fÅr INHALT laut StÅckliste
**
FUNCTION VenStmCollect() // cIdJnl,cIdDoc)
local a
local aLn := {}
local aCls := {}
local i
local cIdJnl := VEN->IdJnl
open area oStm(), oArt()
  ddSetOrder(StmOrder(cIdJnl)) // bis 19980722 : ORD_STM_DOC
  softseek VEN->IdDoc
  do while ! eof() .and. &("STM->"+cIdJnl+"IdDoc") == VEN->IdDoc
    StmClsCollect(aCls)
    skip
  enddo
close area
asort( ;
  aCls, ;
  NIL, ;
  NIL, ;
  {|x,y| ;
    x[CLSLIST_IDART]+x[CLSLIST_IDCLS] ;
      < y[CLSLIST_IDART] + y[CLSLIST_IDCLS] ;
  } ;
)
for i := 1 to len(aCls)
  a := array(ALN_ALEN)
  a[ALN_IDART]  := aCls[i][CLSLIST_IDART] // idart
  a[ALN_QTE]    := aCls[i][CLSLIST_MENGE]
  a[ALN_CODE]   := LNCODE_ART
  a[ALN_DESIG]  := ClsName(aCls[i][CLSLIST_IDCLS])
  a[ALN_PRIXU]  := ""
  a[ALN_MONTB]  := ""
  a[ALN_IDTAX]  := ""
  a[ALN_MONTT]  := ""
  a[ALN_ATTRIB] := ""
  aadd(aLn,a)
next i
RETURN aLn

**
** VnlGenerate()
**
** generates 0 to n lines in VNL using contents of aLn
**
FUNCTION VnlGenerate(aLn,cIdJnl,cIdDoc) // ,lRefresh)
local cLine
local i
RETURN NIL if aLn == NIL
* default lRefresh to .f.
MsgDisplay(cIdJnl + " " + cIdDoc + MsgGenerating() )
KeyGoBottom( cIdJnl+cIdDoc, "FIELD->IdJnl+FIELD->IdDoc" )
cLine := NextNum(FIELD->Line)
for i := 1 to len(aLn)
  if dbAddRec()
    FIELD->IdJnl  := cIdJnl
    FIELD->IdDoc  := cIdDoc
    FIELD->Line   := cLine
    FIELD->Code   := aLn[i][ALN_CODE]
    #ifdef DEF_VNLATTR
    FIELD->Attrib := aLn[i][ALN_ATTRIB]
    #endif DEF_VNLATTR
    FIELD->IdArt  := aLn[i][ALN_IDART]
    if VnlRefExist()
      FIELD->Qte    := ntoq(aLn[i][ALN_QTE],LnQteForm())
    else
      FIELD->Qte := repl("?",LenQte())
    endif
    * #ifdef DEF_LNDESIG
    FIELD->Desig  := aLn[i][ALN_DESIG]
    * #endif
    FIELD->PrixU  := aLn[i][ALN_PRIXU]
    #ifdef DEF_TAX
    FIELD->IdTax  := aLn[i][ALN_IDTAX]
    #endif DEF_TAX
    FIELD->MontT  := aLn[i][ALN_MONTT]
    FIELD->cMont  := aLn[i][ALN_MONTB]
    #ifdef DEF_QTESUB
      FIELD->Qte1   := aLn[i][ALN_QTE1]
      FIELD->Qte2   := aLn[i][ALN_QTE2]
      FIELD->Qte3   := aLn[i][ALN_QTE3]
    #endif DEF_QTESUB
    * if lRefresh
      VnlIdValidate()
    * endif
    VnlPostEdit()
    * VnlAfter()
    dbcommit()
    unlock record
  else
    exit
  endif
  cLine := NextNum(cLine)
next i
ddSetUpdated(.t.)
* oVnl()[AD_UPDATED] := .t.
RETURN NIL

FUNCTION StmClsCollect(aCls)
local a := NIL
local i
for i := 1 to len(aCls)
  if aCls[i][CLSLIST_IDART] == STM->IdArt
    if aCls[i][CLSLIST_IDCLS] == STM->IdCls
      a := aCls[i]
      exit
    endif
  endif
next i
if a == NIL
  a := array(CLSLIST_ALEN)
  a[CLSLIST_IDART]  := STM->IdArt
  a[CLSLIST_IDCLS]  := STM->IdCls
  a[CLSLIST_MENGE]  := val(STM->Menge)
  a[CLSLIST_COUNT]  := 1
  aadd(aCls,a)
else
  a[CLSLIST_MENGE] += val(STM->Menge)
  a[CLSLIST_COUNT] += 1
endif
RETURN NIL

**
** StmDtlEdit()
**
*FUNCTION StmDtlEdit(cIdStm)
*local b := oDtl()
*b[AD_POSTEDIT] := {|| DtlPostEdit(STM->IdPrj) }
*open area b, oStm(), oPar()
*  ddSetOrder(ORD_DTL_STM)
*  edit data b key DTL->IdDto ;
*              value cIdStm ;
*              create DtlCreate(NIL,NIL,cIdStm) ;
*              mode find ;
*              query "DTLSTM" ;
*              start top ;
*              title (ltrim(cIdStm) + " : Dokumente")
*              * query ORD_DTL_STM ;
*close area
*RETURN .f.

#endif DEF_HOLZ


#ifdef DEF_PRESTO

**
** TRM
**
FUNCTION TrmEdit(cIdUsr,cTitle,xlFilter)
local b := oTrm()
local dDate := UserDate()
default cTitle to MSG029
if empty(cIdUsr)
  default xlFilter to ".t."
else
  cIdUsr := trim(cIdUsr)
  default xlFilter to "empty(TRM->User).or.'" + cIdUsr + "'$TRM->User"
endif
open area b, oPar(), oTac(), oPrj()
  ddSetOrder(ORD_TRM_DATE)
  softseek dtos(dDate+1)
  skip -1
  do while ! bof() .and. ! &xlFilter
    skip -1
  enddo
  edit data b                   ;
    create    {||TrmCreate()}  ;
    mode      find ;
    query     "TRMDATE" ;
    title     (cTitle) ;
    filter    (xlFilter)
close area
RETURN .f.

**
** TacEdit() - SignalÇtique Tarifs
**
*FUNCTION TacEdit()
*local b := oTac()
** open window (MSG018) color (CfgBrowseColor())
*  open area b
*  edit data b  start top mode find ;
*            query "TAC" ;
*            title (MSG018)
*  close area
** close window
*RETURN .f.

#endif DEF_PRESTO

#ifdef DEF_PRF

**
** Codes profession
**
FUNCTION PrfEdit(cTitle)
local b := oPrf()
open area b
  edit data b ;
            start  top ;
            mode   find ;
            query "PRF" ;
            title  (cTitle)
close area
RETURN .f.

#endif DEF_PRF

#ifdef DEF_SPC

**
** ParSpcEdit()
**
FUNCTION ParSpcEdit(cIdPar)
local b := oSpc()
local cTitle := trim(ParName()) + MSG035
open area b, oArt(), oPar()
  ddSetOrder(ORD_SPC_PAR)
  edit data b key SPC->IdPar value cIdPar ;
    create    {||SpcCreate(cIdPar,NIL)} ;
    start     top ;
    mode      edit  ;
    query     "SPCPAR" ;
    title (cTitle)
close area
RETURN .f.

**
** ArtSpcEdit()
**
FUNCTION ArtSpcEdit(cIdArt)
local b := oSpc()
local cTitle := cIdArt + MSG035
open area b, oPar(), oArt()
  ddSetOrder(ORD_SPC_ART)
  edit data b key SPC->IdArt value cIdArt;
    create    {||SpcCreate(NIL,cIdArt)} ;
    start     bottom ;
    mode      edit  ;
    query     "SPCART" ;
    title (cTitle)
close area
RETURN .f.

#endif DEF_SPC

**
** JNL - Liste des journaux
**
*FUNCTION JnlEdit()
*local b := oJnl()
*open area b
*  ddSetOrder(2)
*  open window (MSG007) color (CfgBrowseColor())
*  edit data b start top mode edit
*  if b[AD_UPDATED]
*    JnlRefresh()
*  endif
*  close window
*close area
*RETURN .f.



**
** CAT
**
*FUNCTION CatEdit()
*local b := oCat()
*open area b
*  open window (MSG012) size 10,60 // color (CfgBrowseColor())
*  edit data b start top mode find
*  if b[AD_UPDATED]
*    CatRefresh()
*  endif
*  close window
*close area
*RETURN .f.


#ifdef DEF_ECHE
*
**
** EclEdit()
**
*FUNCTION EclEdit(cIdEcs)
*local b := oEcl()
*open area oEcl(), oPar(), oGen()
*  *open window (trim(EcsName(cIdEcs))) ;
*  *            color (CfgBrowseColor())
*  edit data b key ECL->IdEcs value cIdEcs ;
*    create   EclCreate(cIdEcs) ;
*    mode     find  ;
*    append              ;
*    start  bottom ;
*    query "ECL" ;
*    title (trim(EcsName(cIdEcs)))
*  * close window
*close area
*RETURN .f.
*
***
*** DocEclEdit()
***
*FUNCTION DocEclEdit() // cMatch,cCptType,cIdPar,nMont)
*local b := oEcl()
*local cMatch := VEN->IdJnl + VEN->IdDoc
*local cCptType := JnlIdCtr(VEN->IdJnl)
*local cIdPar := VEN->IdPar
*open area oEcl()
*  ddSetOrder(ORD_ECL_MATCH)
*  * open window ("ZahlungsauftrÑge " + cMatch) size 10,74 help ECL
*  softseek cMatch
*  if ECL->Match != cMatch
*    EclCreate(NIL,cMatch,cCptType,cIdPar)
*  endif
*  edit data b key ECL->Match value cMatch ;
*    create   EclCreate(NIL,cMatch,cCptType,cIdPar) ;
*    mode     find  ;
*    append              ;
*    start  bottom ;
*    query "ECLMATCH" ;
*    title ("ZahlungsauftrÑge " + cMatch)
*  * close window
*close area
*RETURN .f.
*
#endif DEF_ECHE

#ifdef DEF_IMP

**
** BudEdit()
**
FUNCTION BudEdit(cDC,cTitle)
local b := oBud()
cTitle := strtran(cTitle,"~")
if empty(cDC)
  open area b
    edit data b ;
      query ("BUD") ;
      create {||BudCreate(NIL)} ;
      mode  find  ;
      start  top ;
      title (cTitle)
  close area
else
  open area b
    edit data b ;
      key BUD->DC ;
      value cDC ;
      query ("BUD" + cDC) ;
      create {||BudCreate(cDC)} ;
      mode  find  ;
      start  bottom ;
      title (cTitle)
  close area
endif
RETURN .f.

FUNCTION BudPage(cDC,cIdBud)
RETURN MnuDone() if empty(cDC)
RETURN MnuDone() if empty(cIdBud)
open area oBud()
  if cDC != NIL
    seek cDC + cIdBud
  endif
  edit data oBud() full noskip query ("BUD" + cDC) title (MSG022)
close area
RETURN MnuDone()

#endif DEF_IMP

#ifdef DEF_ANA

**
** AnaEdit()
**
FUNCTION AnaEdit()
local b := oAna()
open area b, oPar()
  edit data b ;
    query "ANA" ;
    mode  find  ;
    start  top ;
    title ("Stammdaten Analysekonten")
close area
RETURN .f.

#endif DEF_ANA

#ifdef DEF_MVA

**
** MVA - Mouvements comptes analytiques
**
FUNCTION MvaEdit(cTitle)
local b := oMva()
open area b, oPar(), oAna(), oGen()
  edit data b start top mode show query "MVA" title (cTitle)
close area
RETURN .f.

FUNCTION AnaCtaEdit()
local cIdAna := ANA->IdAna
local b := oCta()
open area b, oAna()
  edit data b key   CTA->IdAna ;
              value cIdAna ;
              title (MSG_CTG + trim(cIdAna)) ;
              mode show ;
              query "CTAANA"
close area
RETURN NIL

#endif DEF_MVA

#ifdef DEF_JNL

FUNCTION DocEdit(cIdGrj,cTitle)
local cIdJnl
local i
local nStart := 1
local jnl
local a := JnlList( ;
  {|jnl| ;
    jnl[JNL_IDGRJ] == cIdGrj ;
  } ;
)
* .and. (USRATTR_C $ UsrAttrib() .or. ! JNLATTR_C $ jnl[JNL_ATTRIB]) ;
* default cTitle to "Dokumente erfassen"
do while nStart != 0
  if len(a) > 1
    browse array a ;
                 using {|jnl| jnl[JNL_IDJNL] + " " + ;
                              padr(jnl[JNL_NAME],30) ;
                       } ;
                title (MsgJournaux(UsrLang()) + " " + cTitle) ;
                help "DOCEDIT" ;
                start nStart ;
                delete {||.f.} ;
                arrowexit .t.
    RETURN .f. if lastchoice() == 0
    nStart := lastchoice()
    jnl := a[nStart] // [JNL_IDJNL]
  elseif len(a) == 1
    jnl := a[1] // [JNL_IDJNL]
    nStart := 0
  else
    Warning(cIdGrj + utr(" : no journal in this group",;
                         " : keine Journale in dieser Gruppe",;
                         " : aucun journal dans ce groupe"))
    exit
  endif
  #ifdef DEF_VEN
    if jnl[JNL_ALIAS] == "VEN"
      VenEdit(jnl)
    endif
  #endif DEF_VEN
  #ifdef DEF_MVA
    if jnl[JNL_ALIAS] == "ODA"
      OdaEdit(jnl)
    endif
  #endif DEF_MVA
  #ifdef DEF_ODS
    if jnl[JNL_ALIAS] == "ODS"
      OdsEdit(jnl)
    endif
  #endif DEF_ODS
  #ifdef DEF_FIN
    if jnl[JNL_ALIAS] == "FIN"
      FinEdit(jnl)
    endif
  #endif DEF_FIN
  #ifdef DEF_IMP
    if jnl[JNL_ALIAS] == "IMP"
      ImpEdit(jnl)
    endif
  #endif DEF_IMP
  #ifdef DEF_PRE
    if jnl[JNL_ALIAS] == "PRE"
      PreEdit(jnl)
    endif
  #endif DEF_PRE
  * #ifdef DEF_KVK
  *   if jnl[JNL_ALIAS] == "KVK"
  *     KvkEdit(jnl)
  *   endif
  * #endif DEF_VEN
enddo
RETURN .f.

#endif DEF_JNL

#ifdef DEF_GEN

FUNCTION GenCtgEdit()
local cIdGen := GEN->IdGen
local b := oCtg()
if GENATTR_C $ GEN->Attrib .and. ! USRATTR_C $ UsrAttrib()
  Warning(MsgNoAccess(),NIL,"WRN028")
  RETURN .f.
endif
open area b, oBud()
  edit data b key   CTG->IdGen ;
              value cIdGen ;
              title (MSG_CTG + trim(cIdGen)) ;
              mode show ;
              query "CTGGEN" ;
              start bottom
close area
RETURN NIL


#endif DEF_GEN


#ifdef DEF_CTP

FUNCTION ParCtpEdit(cIdPAr)
local b := oCtp()
open area b, oBud()
  edit data b key   CTP->IdPar ;
              value cIdPar ;
              title (MSG_CTG + trim(ParName())) ;
              mode show ;
              query "CTPPAR" ;
              start bottom
close area
RETURN NIL

**
** CTP
**
FUNCTION CtpEdit(cTitle)
local b := oCtp()
open area b, oPar()
  edit data b start top mode show query "CTP" title (cTitle)
close area
RETURN .f.

**
** MVP
**
*FUNCTION MvpEdit(cTitle)
*local b := oMvp()
*open area b, oPar()
*  edit data b start top mode show query "MVP" title (cTitle)
*close area
*RETURN .f.

#endif DEF_CTP

#ifdef DEF_HST

**
** JnlHstEdit()
**
FUNCTION JnlHstEdit(cTitle,xlFilter)
local b := oHst()
local nChoice := 1
local a := JnlList({|jnl| JNLATTR_G $ jnl[JNL_ATTRIB]})
static scIdJnl := NIL
local cIdJnl
default xlFilter to "empty(HST->Satis).and.!empty(HST->IdPar)"
do while (cIdJnl := PickIdJnl(NIL,scIdJnl,a,cTitle,"HSTJNL")) != NIL
  scIdJnl := cIdJnl
  open area b, oPar(), oGen()
    ddSetOrder(ORD_HST_DOC)
    edit data b ;
              key   HST->IdJnl ;
              value cIdJnl ;
              start top ;
              mode find ;
              filter (xlFilter) ;
              query "HSTJNL" ;
              title (cTitle + " : " + cIdJnl)
  close area
enddo
RETURN .f.

#endif DEF_HST

#ifdef DEF_ACF

**
** ACF -
**
FUNCTION AcfEdit(cTitle)
* local cTitle := "Artikel-PreisvorschlÑge"
local b := oAcf()
open area b, oPar(), oArt()
  edit data b start top mode find query "ACF" title (cTitle)
close area
RETURN .f.

#endif DEF_ACF

#ifdef DEF_CTS

**
** Cts -
**
FUNCTION CtsEdit
local cTitle := "Sammelhistorik Artikel"
local b := oCts()
open area b, oArt()
  edit data b start top mode find query "CTS" title (cTitle)
close area
RETURN .f.

#endif DEF_CTS

#ifdef DEF_JNL

**
** JnlPerEdit()
**
*FUNCTION JnlPerEdit(cIdJnl)
*local b := oPer()
*open area b
*  edit data b key PER->IdJnl value cIdJnl ;
*    query ("PERJNL") ;
*    mode     find  ;
*    title (cIdJnl + " : Buchungsperioden" ) ;
*    start  bottom
*close area
*RETURN .f.

#endif DEF_JNL

#ifdef DEF_TRA

**
** TrtEdit()
**
FUNCTION TrtEdit(cTitle)
local b := oTrt()
open area b, oBud()
  edit data b ;
    create {||SeqCreate(b)} ;
    query "TRT" ;
    mode     find  ;
    title (cTitle) ;
    start  top
  * if ddSetUpdated() // b[AD_UPDATED]
    TrtRefresh()
  * endif
close area
RETURN .f.

**
** TraEdit()
**
FUNCTION TraEdit(cIdJnl)
local b := oTra()
local jnl := JnlLocate(cIdJnl)
if cIdJnl == NIL
  RETURN !Warning("TraEdit(cIdJnl) : cIdJnl is NIL !")
endif
RETURN !Warning(cIdJnl+MsgJnlExist()) if jnl == NIL
scTraIdJnl := cIdJnl
open area b, oPar()
  goto (lastrec() + 1) //  bottom
  edit data b ;
    key TRA->IdJnl value cIdJnl ;
    create   {|| DocCreate( ;
      jnl, ;
      {|cIdDoc|TraCreate(jnl,cIdDoc) } ;
    )} ;
    query ("TRA"+jnl[JNL_IDDBV]) ;
    mode  find  ;
    title (trim(jnl[JNL_NAME])) ;
    full
close area
scTraIdJnl := NIL
RETURN .f.

FUNCTION TraEditJnl
RETURN scTraIdJnl

**
** TrlEdit()
**
FUNCTION TrlEdit()
local b := oTrl()
open area b, oTra(), oPar()
  edit data b ;
    query ("TRL") ;
    mode  find  ;
    title ("Globalsicht Kassentransaktionen")
close area
RETURN .f.

#endif DEF_TRA


#ifdef DEF_IMP

**
** BudMviEdit() -
**
FUNCTION BudMviEdit(cIdCtr,cIdBud)
local b := oMvi()
local a := MviSaveFilter()
open area b, oPar(), oBud(), oImp(), oIml()
  MviSetFilter()
  ddSetOrder(ORD_MVI_BUDDATE)
  edit data b key MVI->DC + MVI->IdBud ;
    value    cIdCtr + cIdBud        ;
    start    bottom                 ;
    mode     find  ;
    query ("MVIBUDD") ;
    filter "MviEvalFilter()" ;
    title ("Bewegungen " + cIdCtr + "-" + trim(SayIdBud(cIdBud)))
close area
MviRestFilter(a)
RETURN MnuDone()

**
** MviEdit() -
**
FUNCTION MviEdit(cDc,cTitle)
local b := oMvi()
local a := MviSaveFilter()
open area b, oPar(), oBud(), oImp(), oIml()
  MviSetFilter()
  ddSetOrder(ORD_MVI_BUDDATE)
  edit data b key MVI->DC value cDC ;
    start    bottom                 ;
    mode     find  ;
    query ("MVI") ;
    title (cTitle)
close area
MviRestFilter(a)
RETURN .f.

**
** BudCtbEdit() -
**
FUNCTION BudCtbEdit(cIdCtr,cIdBud)
local b := oCtb()
open area b, oBud()
  edit data b key CTB->DC + CTB->IdBud ;
    value    cIdCtr + cIdBud        ;
    start    bottom                 ;
    mode     find  ;
    query ("CTBBUD") ;
    title ("Sammelhistorik " + cIdCtr + "-" + trim(SayIdBud(cIdBud)))
close area
RETURN .f.

**
** ParMviEdit() -
**
FUNCTION ParMviEdit(cIdPar, cTitle, bFilter, cIdQry)
local b := oMvi()
local a := MviSaveFilter()
* MviSatisfy(cIdPar)
default bFilter to "MviEvalFilter()"
default cTitle to trim(ParName(cIdPar)) + " : Historik"
default cIdQry to "MVIPARD"
open area b, oPar(), oBud(), oImp(), oIml()
  MviSetFilter()
  * ddSetOrder(ORD_MVI_PARDATE)
  edit data b key MVI->IdPar ;
    value    cIdPar             ;
    start    bottom             ;
    mode     find  ;
    query (cIdQry) ;
    filter (bFilter) ;
    title (cTitle)
close area
MviRestFilter(a)
RETURN .f.

**
** ParMv2Edit() -
**
FUNCTION ParMv2Edit(cIdPar)
local b := oMvi()
local bFilter := "MviEvalFilter()"
local a := MviSaveFilter()
MviSetFilter()
open area b, oPar(), oBud(), oImp(), oIml()
  ddSetOrder(ORD_MVI_PAR2DATE)
  edit data b key MVI->IdPar2 ;
    value    cIdPar             ;
    start    bottom                 ;
    mode     find  ;
    query ("MVIPAR2") ;
    filter (bFilter) ;
    title ("Bewegungen " + ParName(cIdPar))
close area
MviRestFilter(a)
RETURN .f.

**
** JnlMviEdit() -
**
FUNCTION JnlMviEdit
local jnl
local nChoice := 1
local a
local b := oMvi()
local cIdGrj
local xlFilter := "MviEvalFilter()"
local aMviFilter := MviSaveFilter()
static scIdGrj := NIL
MviSetFilter()
do while (cIdGrj := PickGrj(scIdGrj,"Offene Posten")) != NIL
  scIdGrj := cIdGrj
  a := JnlList({|jnl| jnl[JNL_IDGRJ] == scIdGrj })
  nChoice := 1
  do while nChoice != 0
    if len(a) == 1
      jnl := a[nChoice]
      nChoice := 0
    else
      browse array a ;
                   using {|jnl| jnl[JNL_IDJNL] + " " + ;
                                padr(jnl[JNL_NAME],30) ;
                         } ;
                   title ("Offene Posten") ;
                   start nChoice ;
                   delete {||.f.}
      if lastchoice() == 0
        exit
      else
        nChoice := lastchoice()
        jnl := a[nChoice]
      endif
    endif
    open area b, oPar(), oBud(), oImp(), oIml()
      ddSetOrder(ORD_MVI_ID)
      edit data b key MVI->IdJnl ;
        value    jnl[JNL_IDJNL]             ;
        start    bottom                 ;
        mode     find  ;
        filter   (xlFilter) ;
        query ("MVI" + jnl[JNL_IDDBV]) ;
        title ("Offene Posten : " + jnl[JNL_IDJNL])
    close area
  enddo
enddo
MviRestFilter(aMviFilter)
RETURN .f.

#endif DEF_IMP

*#ifdef DEF_XTV
*
*FUNCTION XtvEdit(i)
*local xtv := XtvLocate(i)
*local b
*local bFilter := NIL
*local cMac := xtv[XTV_FILTER]
*if ! empty(cMac)
*  bFilter := {|| &cMac }
*endif
*if xtv[XTV_ALIAS] == "PAR"
*  b := oPar()
*  open area b, oPlz()
*    ParSetFilter(xtv[XTV_FILTER])
*    edit data b title (strtran(xtv[XTV_NAME],"~")) ;
*                query "PAR" + xtv[XTV_IDQRY] ;
*                mode find ;
*                filter {|| ParEvalFilter()} ;
*                start top
*  close area
*  RETURN .f.
*endif
*#ifdef DEF_ART
*  if xtv[XTV_ALIAS] == "ART"
*    b := oArt()
*    open area b, oGra()
*      edit data b title (strtran(xtv[XTV_NAME],"~")) ;
*                  query "ART" + xtv[XTV_IDQRY] ;
*                  mode find ;
*                  filter bFilter ;
*                  start top
*    close area
*    RETURN .f.
*  endif
*#endif DEF_ART
**#ifdef DEF_MVP
**  if xtv[XTV_ALIAS] == "MVP"
**    b := oMvp()
**    open area b, oPar()
**      edit data b title (strtran(xtv[XTV_NAME],"~")) ;
**                  query ("MVP" + xtv[XTV_IDQRY]) ;
**                  mode find ;
**                  filter bFilter ;
**                  start top
**    close area
**    RETURN .f.
**  endif
**#endif DEF_MVP
*#ifdef DEF_VNA
*  if xtv[XTV_ALIAS] == "VNA"
*    b := oVna()
*    open area b, oPar(), oArt()
*      edit data b title (strtran(xtv[XTV_NAME],"~")) ;
*                  query ("VNA" + xtv[XTV_IDQRY]) ;
*                  mode find ;
*                  filter bFilter ;
*                  start top
*    close area
*    RETURN .f.
*  endif
*#endif DEF_VNA
*RETURN .f.
*
*#endif DEF_XTV


#ifdef DEF_CTT

**
** TaxCttEdit() -
**
FUNCTION TaxCttEdit(cIdCtr,cIdTax)
local b := oCtt()
open area b
  ddSetOrder(ORD_CTT_TAX)
  edit data b key CTT->IdCtr + CTT->IdTax ;
    value    cIdCtr + cIdTax        ;
    start    top                 ;
    mode     show  ;
    query ("CTTTAX") ;
    title (cIdCtr + "-" + cIdTax + " : Historik (öbersicht)")
close area
RETURN MnuDone()


#endif DEF_CTT


#ifdef DEF_TAX

FUNCTION TaxEdit(cTitle)
local b := oTax()
open area b, oGen()
  edit data b ;
    query ("TAX") ;
    mode     find  ;
    title (cTitle) ;
    start  top
close area
TaxRefresh()
RETURN MnuDone()

#endif DEF_TAX

#ifdef DEF_IMP

*FUNCTION CtbEdit()
*local b := oCtb()
*open area b, oBud()
*  ddSetOrder(2)
*  edit data b key CTB->Periode + CTB->IdCdc ;
*              value "199502" ;
*              query "CTBEDIT" ;
*              mode edit ;
*              create CtbCreate() ;
*              title "Sonder-Eingabe 1995-02"
*close area
*RETURN MnuDone()
*
*FUNCTION CtbCreate()
*RETURN DDCREATE_FAIL if ! dbAddRec()
*CTB->Periode := "1995"
*CTB->IdCdc   := "02"
*unlock record
*RETURN DDCREATE_EDIT

#endif DEF_IMP

#ifdef DEF_ALA

FUNCTION ArtAlaEdit(cIdArt,cIdDlg)
* local cIdArt := ART->IdArt
local b := oAla()
local nPrix1 := 0
local nPrixR := 0
RETURN MnuDone() if ! ddRecLock()
open area b, oArt()
  ddSetOrder(ORD_ALA_ART1)
  edit data b key    ALA->IdArt1 ;
              value  cIdArt ;
              query  ("ALAART") ;
              create {||AlaCreate(cIdArt)} ;
              title  (cIdArt + " : Komponenten")
  if cIdDlg == NIL
    softseek cIdArt
    do while ! eof() .and. ALA->IdArt1 == cIdArt
      nPrix1 += val(ALA->Prix1)
      nPrixR += val(ALA->PrixR)
      skip
    enddo
  endif
close area
if ddLastKey() != K_ESC .and. ! ARTATTR_R $ ART->Attrib
  if cIdDlg == NIL
    ArtDlgPrix(nPrix1,nPrixR)
  else
    DlgExec(cIdDlg)
  endif
endif
unlock record
RETURN MnuDone()

FUNCTION ArtAlaSum(cIdArt,xnValue)
local b := oAla()
local nSum := 0
open area b, oArt()
  ddSetOrder(ORD_ALA_ART1)
  softseek cIdArt
  do while ! eof() .and. ALA->IdArt1 == cIdArt
    nSum += &xnValue
    skip
  enddo
close area
RETURN nSum

#define ALA_IDART2 1
#define ALA_QTE    2
#define ALA_PRIX1  3
#define ALA_PRIXR  4
#define ALA_NB     5
#define ALA_ALEN   6

FUNCTION AlaCopy()
local cIdArt1 := PickArt()
local ala
local a := {}
local i
RETURN MnuDone() if cIdArt1 == NIL
open area oAla()
  softseek cIdArt1
  do while ! eof() .and. ALA->IdArt1 == cIdArt1
    ala := array(ALA_ALEN)
    ala[ALA_IDART2] := ALA->IdArt2
    ala[ALA_QTE   ] := ALA->Qte
    ala[ALA_PRIX1 ] := ALA->Prix1
    ala[ALA_PRIXR ] := ALA->PrixR
    ala[ALA_NB    ] := ALA->NB
    aadd(a,ala)
    skip
  enddo
close area
for i := 1 to len(a)
  goto lastrec() + 1
  if ddCreate()
    if ddRecLock()
      ALA->IdArt2  := a[i][ALA_IDART2]
      ALA->Qte     := a[i][ALA_QTE   ]
      ALA->Prix1   := a[i][ALA_PRIX1 ]
      ALA->PrixR   := a[i][ALA_PRIXR ]
      ALA->NB      := a[i][ALA_NB    ]
      unlock record
    else
      exit
    endif
  else
    exit
  endif
next i
ddGoBottom(.t.)
RETURN MnuDone()

FUNCTION ArtDlgPrix(nPrix1,nPrixR)
local cPrix1 := ART->Prix1
local cPrixR := ART->PrixR
local cTVAC  := ART->TVAC
if nPrix1 != NIL
  ART->PrixR := ntom(nPrixR)
  if DoModPrix1()
    ART->Prix1 := ntom(nPrix1)
    ArtP1Validate()
  endif
  ph_refresh()
endif
open window (ART->IdArt + ": Preise aktualisieren") size 5,50 help ARTPRIX
say "Selbstkostenpreis  "
get ART->PrixR GET_MONTANT
WinCr()
say "VK                 "
get ART->Prix1 GET_DECPOS(ArtPuDecPos()) ;
               valid ArtP1Validate(val(ART->PrixR)).and.ph_refresh()
WinCr()
say "VK inkl. MWSt.     "
get ART->TVAC  GET_DECPOS(ArtPuDecPos()) ;
               valid ArtTvacValidate(val(ART->PrixR))
nKey := ReadScr()
close window
RETURN NIL if nKey != K_ESC
ART->Prix1 := cPrix1
ART->PrixR := cPrixR
ART->TVAC  := cTVAC
RETURN NIL

#endif DEF_ALA

#ifdef DEF_BIBLIO

**
**
**
FUNCTION ObjEdit()
local b := oObj()
open area b, oAut(), oRub(), oGrp()
  ddSetOrder(DOC_ORD_ID)
  edit data b ;
    mode find  ;
    query "OBJID" ;
    start top ;
    title ("Dokumente nach Nummer")
close area
RETURN .f.

**
** AutEdit()
**
FUNCTION AutEdit()
local b := oAut()
open area b
  ddSetOrder(AUT_ORD_NAME)
  * do while ! AppTerminate()
    edit data b mode find  ;
                title ("Autoren") ;
                query "AUTNAME" ;
                start top
                * query AUT_ORD_NAME ;
                * query "AUTNAME"
    * if ddLastReq() == DDEDIT_SELECT
    *   AutObjEdit(AUT->IdAut)
    * else
    *   exit
    * endif
  * enddo
close area
RETURN .f.

**
** NtsEdit()
**
FUNCTION NtsEdit()
local b := oNts()
open area b, oObj(), oAut(), oGrp()
  ddSetOrder(ORD_NTS_NAME)
  do while ! AppTerminate()
    edit data b mode pick  ;
                create {||NtsCreate()} ;
                start top ;
                title ("Stichworte") ;
                query "NTSNAME"
    if ddLastReq() == DDEDIT_SELECT
      NtsRefEdit(NTS->IdNts,trim(NTS->Name))
    else
      exit
    endif
  enddo
close area
RETURN .f.

**
** RubEdit()
**
FUNCTION RubEdit()
local b := oRub()
open area b
  * open window (MSG006) size 15,70 // color (CfgBrowseColor())
  * do while ! AppTerminate()
    edit data b mode find  ;
                start top ;
                title ("Rubriken") ;
                query "RUB"
    * if ddLastReq() == DDEDIT_SELECT
    *   RubObjEdit(RUB->IdRub)
    * else
    *   exit
    * endif
  * enddo
  * close window
close area
RETURN .f.

**
** DtpEdit()
**
FUNCTION DtpEdit()
local b := oDtp()
open area b
  edit data b mode edit  ;
              start top ;
              title "Dokument-Arten" ;
              query "DTP"
  * if ddSetUpdated() // b[AD_UPDATED]
    DtpRefresh()
  * endif
close area
RETURN .f.

**
** GrpEdit()
**
FUNCTION GrpEdit()
local b := oGrp()
open area b
  edit data b mode find  ;
              start top ;
              title "Verlage" ;
              query "GRP"
close area
RETURN .f.

**
** AutObjEdit()
**
FUNCTION AutObjEdit(cId)
local b := oObj()
open area b, oRub(), oAut(), oGrp()
  ddSetOrder(DOC_ORD_AUT)
  * open window (MSG003) size 18,76
  edit data b key OBJ->IdAut value cId ;
              create {|| ObjCreate(cId,NIL,NIL,NIL,NIL)} ;
              mode   find  ;
              start  top  ;
              query "OBJAUT" ;
              title (trim(AutName()) + " : Dokumente")
              * query DOC_ORD_AUT
  * close window
close area
RETURN .f.

**
** RubObjEdit()
**
FUNCTION RubObjEdit(cId)
local b := oOBJ()
open area b, oAut(), oGrp()
  ddSetOrder(DOC_ORD_RUB)
  * open window (MSG004)  size 18,76
  edit data b key OBJ->IdRub value cId ;
              create {||ObjCreate(NIL,cId,NIL,NIL,NIL)} ;
              mode   find  ;
              start  top   ;
              query "OBJRUB" ;
              title (trim(RubName()) + " : Dokumente")
              * query DOC_ORD_RUB
  * close window
close area
RETURN .f.


**
** DtpObjEdit()
**
FUNCTION DtpObjEdit(cId)
local b := oObj()
open area b, oAut(), oRub(), oGrp()
  ddSetOrder(DOC_ORD_ID)
  edit data b key OBJ->IdDtp value cId ;
              create {||ObjCreate(NIL,NIL,cId,NIL,NIL)} ;
              mode   find  ;
              start  bottom   ;
              title (strtran(trim(DtpName(cId)),"~")) ;
              query "OBJDTP"
close area
RETURN .f.

**
** GrpObjEdit()
**
FUNCTION GrpObjEdit(cId)
local b := oObj()
open area b, oAut(), oRub(), oGrp()
  ddSetOrder(DOC_ORD_GRP)
  edit data b key OBJ->IdGrp value cId ;
              create {||ObjCreate(NIL,NIL,NIL,cId,NIL)} ;
              mode   find  ;
              start  top   ;
              query "OBJGRP" ;
              title ("Dokumente nach Verlag")
close area
RETURN .f.

**
** ObjRefEdit()
**
FUNCTION ObjRefEdit(cIdDtp,cIdObj)
local b := oRef()
open area b, oObj(), oAut(), oRub(), oNts()
  ddSetOrder(ORD_REF_DOC) // DOC_ORD_GRP
  edit data b key   REF->IdDtp + REF->IdObj ;
              value cIdDtp + cIdObj ;
              create {||RefCreate(cIdDtp,cIdObj,NIL)} ;
              mode   find  ;
              start  top   ;
              query "REFOBJ" ;
              title (trim(DtpTitel(cIdDtp)) + " " + cIdObj + " : Verweise")
close area
RETURN .f.

**
** NtsRefEdit()
**
FUNCTION NtsRefEdit(cIdNts,cName)
local b := oRef()
open area b, oObj(), oAut()
  ddSetOrder(ORD_REF_NTS) // DOC_ORD_GRP
  * open window ("Stichwort " + cName + " : Verweise") size 18,78
  edit data b key   REF->IdNts ;
              value cIdNts ;
              create {|| RefCreate(NIL,NIL,cIdNts)} ;
              mode   find  ;
              start  top   ;
              query "REFNTS" ;
              title ("Stichwort " + cName + " : Verweise")
              * query ORD_REF_NTS
  * close window
close area
RETURN .f.

FUNCTION ObjMemoEdit()
return MnuDone() if ! ddRecLock()
if empty(OBJ->Memo)
  OBJ->Memo := memoread( ;
    DbPath() + "\DTP"+ trim(OBJ->IdDtp) + ".TXT" ;
  )
endif
open window (trim(OBJ->Name)) size 10, 80 home 12,0
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oObj()), 76  ;
  )
close window
unlock
RETURN .f.

FUNCTION AutTxtEdit()
return MnuDone() if ! ddRecLock()
open window ("Text-Editor") size 20, 80
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oAut()), 76  ;
  )
close window
unlock
RETURN .f.

FUNCTION RubTxtEdit()
return MnuDone() if ! ddRecLock()
open window ("Text-Editor") size 20, 80
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oRub()), 76  ;
  )
close window
unlock
RETURN .f.

FUNCTION OutTxtEdit()
return MnuDone() if ! ddRecLock()
open window ("Text-Editor") size 20, 80
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oOut()), 76  ;
  )
close window
unlock
RETURN .f.

FUNCTION RefTxtEdit()
select NTS
NtsTxtEdit()
select REF
RETURN .f.


FUNCTION NtsTxtEdit()
return MnuDone() if ! ddRecLock()
open window ("Memotext zu Stichwort " + trim(NTS->Name)) size 20, 80
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oNts()), 76  ;
  )
close window
unlock
RETURN .f.


#define REF_IDDOC 1
#define REF_LINE  2
* #define REF_IDRTP 2
#define REF_ALEN  2

**
** "Extended name" eines Dokuments (Art, Titel, Autor)
**
FUNCTION ObjExtName(cIdDtp,cIdObj)
local cAttrib
local c := ""
if OBJ->IdDtp + OBJ->IdObj != cIdDtp+cIdObj
  seek cIdDtp + cIdObj in OBJ
endif
cAttrib := DtpAttrib(cIdDtp)
c += trim(cIdObj)
c += " " + trim(OBJ->Name)
if DTPATTR_D $ cAttrib
  c += " [" + trim(DtpTitel(OBJ->IdDtp)) + "]"
endif
if DTPATTR_A $ cAttrib
  c += " (" + trim(AutName(OBJ->IdAut)) + ")"
endif
RETURN c

FUNCTION NtsName(cId)
if cId != NIL
  if NTS->IdNts != cId
    seek cId in NTS
  endif
endif
RETURN trim(NTS->Name)


**
** ParOutEdit()
**
FUNCTION ParOutEdit(cIdPar)
local b := oOut()
open area b, oObj(), oPar(), oAut()
  ddSetOrder(ORD_OUT_PAR)
  edit data b key OUT->IdPar value cIdPar ;
              create {||OutCreate(cIdPar)} ;
              mode   find  ;
              start  top  ;
              query "OUTPAR" ;
              title ("AusgÑnge pro Partner")
close area
RETURN .f.

**
** ObjOutEdit()
**
FUNCTION ObjOutEdit(cIdDtp,cIdObj)
local b := oOut()
open area b, oPar(), oObj()
  ddSetOrder(ORD_OUT_DOC)
  edit data b key OUT->IdDtp+OUT->IdObj value cIdDtp+cIdObj ;
              create {||OutCreate(NIL,cIdDtp,cIdObj)} ;
              mode   find  ;
              start  top  ;
              query "OUTDOC" ;
              title ("AusgÑnge pro Dokument")
close area
RETURN .f.

#endif DEF_BIBLIO

FUNCTION MsgJournal()  ; RETURN "Journal "

**
** NatPlzEdit()
**
FUNCTION NatPlzEdit(cIdNat,cTitle)
local b := oPlz()
#ifdef LG_GERMAN
  default cTitle to "Postleitzahlen pro Land : " + trim(cIdNat)
#else
  default cTitle to "Codes postaux par Pays : " + trim(cIdNat)
#endif
open area b, oNat()
  ddSetOrder(ORD_PLZ_NAME)
  edit data b key PLZ->Pays value cIdNat ;
              create {||PlzCreate(cIdNat,PLZ->CP)} ;
              mode   find  ;
              start  top  ;
              query "PLZNAT" ;
              title (cTitle)
close area
RETURN .t.


#ifdef DEF_RUN
**
** RalEdit()
**
FUNCTION RalEdit()
local b := oRal()
open area b
  edit data b ;
       create {||RalCreate()} ;
       mode  find ;
       start bottom ;
       query "RAL" ;
       title ("SignalÇtique Courses")
close area
RETURN .t. // MENU_FAIL

**
** RalPosEdit()
**
FUNCTION RalPosEdit()
local b := oPos()
local cIdRal := RAL->IdRal
SetCatType(RAL->CatType,RAL->CatList,RAL->Sex)
if RAL->Status == RALSTAT_I
  open area b, oPar(), oPlz(), oNat(), oClb()
    ddSetOrder(ORD_POS_POS)
    edit data b ;
         key POS->IdRal ;
         value cIdRal ;
         create {||PosCreate(cIdRal)} ;
         mode  find ;
         start top ;
         query "POS-I"+RAL->RalType ;
         title (trim1(RAL->Name1) + dtoc(RAL->Date) + " : inscriptions")
  close area
elseif RAL->Status == RALSTAT_T
  open area b, oPar(), oPlz(), oNat(), oClb()
    ddSetOrder(ORD_POS_POS)
    edit data b ;
         key POS->IdRal ;
         value cIdRal ;
         create {||DDCREATE_FAIL} ;
         mode  find ;
         start top ;
         query "POS-T" ;
         title (trim1(RAL->Name1) + dtoc(RAL->Date) + " : encoder temps")
  close area
elseif RAL->Status == RALSTAT_P
  open area b, oPar(), oPlz(), oNat(), oClb()
    ddSetOrder(ORD_POS_TIME)
    edit data b ;
         key POS->IdRal ;
         value cIdRal ;
         create {||DDCREATE_FAIL} ;
         mode  find ;
         start top ;
         query "POS-P" ;
         title (trim1(RAL->Name1) + dtoc(RAL->Date) + " : places")
  close area
elseif RAL->Status == RALSTAT_C
  open area b, oPar(), oPlz(), oNat(), oClb()
    ddSetOrder(ORD_POS_CAT_TIME)
    edit data b ;
         key POS->IdRal ;
         value cIdRal ;
         create {||DDCREATE_FAIL} ;
         mode  find ;
         start top ;
         query "POS-C" ;
         title (trim1(RAL->Name1) + dtoc(RAL->Date) + " : places / cat.")
  close area
else
  Warning("Anomalie : RAL->Status invalide !")
endif
RETURN .t.



#endif DEF_RUN

#ifdef DEF_TREE

FUNCTION NodePath(b,cIdAls,xuNode,cSeparator,aTree)
local cMatch := "?"
local i
local c
default aTree to {}
default cSeparator to "."
if empty(cIdAls)
  RETURN ""
endif
open area b
  seek cIdAls
  if eof()
    cMatch := "??"
  elseif empty(FIELD->Parent)
    cMatch := xeval(xuNode,len(aTree))
  else
    for i := 1 to len(aTree)
      if aTree[i] == &(indexKey()) // xcKey // ALS->IdAls
        Warning(cIdAls + " : circular reference at level " +len(aTree))
        cMatch := "???"
        BREAK
      endif
    next i
    aadd(aTree, cIdAls)
    cMatch := NodePath(b,FIELD->Parent,xuNode,cSeparator,aTree)
    c := xeval(xuNode,len(aTree))
    if !empty(c)
      cMatch += cSeparator + c
    endif
  endif
close area
RETURN cMatch

*FUNCTION TreePeek(cMatch,xuReturn,uReturn)
*local aShort := ListAsArray(cMatch,".")
*local cIdAls := space(LenIdAls())
*local i
*open area oAls()
*  ddSetOrder(4) // ALS->Parent+ALS->Short
*  for i := 1 to len(aShort)
*    seek cIdAls + padr(aShort[i],8)
*    if eof()
*      uReturn := cMatch + " : invalid match. "
*      uReturn += "no item " + aShort[i]
*      uReturn += "in group " + cIdAls
*      Warning(uReturn)
*      exit
*    endif
*    cIdAls := ALS->Parent
*    uReturn := xparse(xuReturn)
*  next i
*close area
*RETURN uReturn

* FUNCTION TreeLevel(cMatch)
* local aShort := ListAsArray(cMatch,".")
* RETURN len(aShort)


#endif DEF_TREE

* das frÅhere OpenMail() :
FUNCTION mailto_timtools(cToAddr,cToName,cSubject,cBody,cAttach)
local fd
if empty(cToAddr)
  RETURN !SetMsg("E-Mail-Adresse darf nicht leer sein!")
endif
fd := fcreate("tmp.eml")
if fd == -1
  SetMsg(MsgDosError())
  RETURN .f.
endif
* fwrite(fd,"Content-Type: text/plain; charset=cp850"+CR_LF)
if empty(cToName)
  fwrite(fd,"To: " + trim(cToAddr) + CR_LF)
else
  fwrite(fd,'To: "' + trim(cToName) + '" <'+trim(cToAddr)+">" + CR_LF)
endif
if cSubject != NIL
  fwrite(fd,"Subject: " + trim(cSubject)+CR_LF)
endif
if cBody != NIL
  fwrite(fd,CR_LF)
  fwrite(fd,cBody + CR_LF)
endif
fclose(fd)
RETURN AppShell(AppPath()+"\timtools openmail tmp.eml")

FUNCTION mailto_url(cToAddr,cToName,cSubject,cBody,cAttach)
local s := "mailto:"
local cSep := "?"
if empty(cToName)
  s += quote(trim(cToAddr),"@,")
else
  s += quote('"'+dos2latin1(trim(cToName)) + '" <'+trim(cToAddr)+">","@,")
endif
if !empty(cSubject)
  s += cSep + "subject="+quote(dos2latin1(cSubject))
  cSep := "&"
endif
if !empty(cBody)
  s += cSep + "body="+quote(dos2latin1(cBody))
  cSep := "&"
endif
if !empty(cAttach)
  s += cSep + "attachment="+quote(dos2latin1(abspath(cAttach)))
  cSep := "&"
endif
RETURN s

FUNCTION mailto(cToAddr,cToName,cSubject,cBody,cAttach)
* local s := '"'+mailto_url(cToAddr,cToName,cSubject,cBody)+'"'
local s := mailto_url(cToAddr,cToName,cSubject,cBody,cAttach)
// return .f. if ! Confirm("OpenUrl() "+utos(s))
* RETURN OpenUrl(s)
RETURN AppShell("start " + s)
* RETURN CmdOpenMail(s)

FUNCTION mailto_tb(cPath,cToAddr,cToName,cSubject,cBody,cAttach)
local s := "-compose to="
if empty(cToName)
  s += quote(trim(cToAddr),"@,")
else
  s += quote('"'+dos2latin1(trim(cToName)) + '" <'+trim(cToAddr)+">","@,")
endif
if !empty(cSubject)
  s += "," + "subject="+quote(dos2latin1(cSubject))
endif
if !empty(cBody)
  s += "," + "body="+quote(dos2latin1(cBody))
endif
if !empty(cAttach)
  s += "," + "attachment="+quote(dos2latin1(fileurl(cAttach)))
endif
#ifdef __XPP__
  * RETURN .f. if ! Confirm("RunShell('"+s+"','"+cPath+"'")
  RunShell(s,cPath,.t.)
  RETURN .t.
#else
  RETURN AppShell(s)
#endif

FUNCTION fileurl(c)
RETURN "file://"+strtran(abspath(c),"\","/")

FUNCTION mailto_mso(cPath,cToAddr,cToName,cSubject,cBody,cAttach)
local s := mailto_url(cToAddr,cToName,cSubject,cBody)
if !empty(cAttach)
  s += ' /a "'+quote(dos2latin1(abspath(cAttach)))+'"'
endif
#ifdef __XPP__
  confirm(s)
  RunShell(s,cPath,.t.)
  RETURN .t.
#else
  RETURN AppShell(s)
#endif


* FUNCTION CmdOpenMail(s)
* RETURN eval(sbOpenMail,s)


FUNCTION quote(s,cExcept)
default cExcept to ""
s := strtran(s,";","%3B")
s := strtran(s,"/","%2F")
s := strtran(s,"?","%3F")
s := strtran(s,":","%3A")
if ! "@" $ cExcept ; s := strtran(s,"@","%40") ; endif
s := strtran(s,"&","%26")
s := strtran(s,"=","%3D")
s := strtran(s,"+","%2B")
s := strtran(s,"$","%24")
if ! "," $ cExcept ; s := strtran(s,",","%2C") ; endif
s := strtran(s," ","%20")
s := strtran(s,"<","%3C")
s := strtran(s,">","%3E")
s := strtran(s,CR_LF,"%0D%0A")
* s := strtran(s,chr(220),"%DC")
RETURN s

* 20070513 neue version ist in admin.prg
*FUNCTION OpenUrl(cUrl)
*local cCmd
*if ! "://" $ cURL
*  cUrl := "http://"+cUrl
*endif
*if left(cUrl,7)=="http://"
*  * #ifdef __XPP__
*  *   RunShell(cUrl,"start",.t.)
*  *   RETURN .t.
*  * #endif __XPP__
*  RETURN AppShell("start "+cUrl)
*endif
*cCmd := "start "+trim(cUrl)
** cCmd := AppPath()+"\timtools.bat openurl "+trim(cUrl)
*RETURN .f. if ! confirm(cCmd)
*RETURN AppShell(cCmd)





* FUNCTION TimTools(cCmd,cTitle)
* RETURN AppShell(AppPath()+"\lino " + cCmd,cTitle)

FUNCTION CbxValidate(x)
RETURN .t. if x $ " X"
RETURN !SetMsg("This is a checkbox. Must be empty or 'X'!")


FUNCTION CbxPick(cStart,cTitle)
RETURN ArrayPick({"  off","X on "},cTitle,cStart)

