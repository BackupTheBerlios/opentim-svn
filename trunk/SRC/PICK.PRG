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
  #define MSG001  "Format quantitÇ"
  #define MSG002  "Type de journal"
  #define MSG003  "Langue"
  #define MSG004  "Bilan"
  #define MSG005  "Type de compte"
  #define MSG006  "Code de ligne"
  static MSG007 := "Attributs"
  #define MSG008  "SÇlection programme externe"
  #define MSG009  "Format document"
  #define MSG010  "Journal comptable                  "
  #define MSG012  "Journal Ö direction inversÇe       "
  #define MSG013  "Encodage P.U. TVA comprise p.dÇfaut"
  #define MSG014  "Documents modulaires par dÇfaut    "
  #define MSG015  "Confirmer mode de paiement /clìture"
  * #define MSG016  "Document modulaire (O/N) ?"
  #define MSG017  "Document livrant (O/N) ?"
  #define MSG018  "clìturÇ   "
  #define MSG019  "ouvert    "
  #define MSG020  "Ö encoder "
  #define MSG021  "Factures achat       "
  #define MSG022  "Notes de crÇdit achat"
  #define MSG023  "Factures vente       "
  #define MSG024  "Notes de crÇdit vente"
  #define MSG026  "SÇlection "
  *#define MSG027  "SÇlection Fournisseur"
  #define MSG028  "SÇlection Code postal (Commune)"
  #define MSG029  "SÇlection Groupe d'articles"
  #define MSG030  "SÇlection Article"
  #define MSG031  "SÇlection Article du groupe "
  * #define MSG032  "SÇlection document match"
  * #define MSG033  "Demander 'Document livrant'          "
  #define MSG034  "SÇlection compte gÇnÇral"
  #define MSG035  "SÇlection Masque de document"
  #define MSG037  "SÇlection Document Achats"
  * #define MSG038  "Imprimer le document si [F10]      "
  #define MSG039  "Lettrage automatique               "
  #define MSG040  "O"
  #define MSG041  "Encodage des montants totaux"
  static MSG042  := "Imprimer documents si [F10]        "
  #define MSG043  "Regrouper mouvements comptes gÇnÇraux"
  #define MSG044  "Confidentiel"
  #define MSG045  "Mouvementer comptes gÇnÇraux"
  #define MSG046  "Copier les attributs de format     "
  #define MSG047  "Documents temporaires              "
  #define MSG048  "SÇlection partenaire Ö la crÇation"
  #define MSG049  "Attributs de facturation"
  #define MSG050  "Activer les codes de masque suivants :"
  #define MSG051  "Avec fenàtre de dialogue PIECES"
  static MSG052 := "clìturer rendez-vous"
  #define MSG053  "SÇlection projet Ö la crÇation"
  * #define MSG054  "Ignorer champs mÇmo en copiant     "
  static MSG055 := "Masque pour "
  static MSG056 := "Contrìle ancien/nouveau solde"
  #define MSG057  "Solde ÇquilibrÇ par document       "
  #define MSG058  "Utiliser le document comme match   "
  #define MSG059  "Article Ö la crÇation des documents"
  #define MSG060  "T.V.A. dÇductible                  "
  static MSG_PICKDOC := "SÇlection document : "
  * #ifdef DEF_FIN
  *   static MSG_JNLA_R := "Journal de report"
  * #endif DEF_FIN
  #ifdef DEF_STK
    static MSG_JNLA_Q := "peut modifier les compteurs de stock"
  #endif DEF_STK
  #ifdef DEF_MVS
    static MSG_JNLA_S := "modifie l'historique stock"
  #endif DEF_MVS
  #ifdef DEF_HST
    static MSG_JNLA_U := "Ne pas modifier Match apräs lettrage manuel"
  #endif DEF_HST
  #ifdef DEF_VEN
    static MSG_JNLA_F := "forcer la saisie chronologique"
  #endif DEF_VEN
  static MSG_JNLA_O := "NumÇrotation manuelle"
  #ifdef DEF_CTS
    static MSG_JNLA_M := "modifie historique mensuel stock"
  #endif DEF_CTS
#endif

#ifdef LG_GERMAN
  #define MSG001  "Mengenformat"
  #define MSG002  "Journal-Art"
  * #define MSG003  "Sprache"
  * #define MSG004  "Bilanz"
  * #define MSG005  "Kontenart"
  * #define MSG006  "Vorgangsart"
  static MSG007 := "Attribute"
  * #define MSG008  "Auswahl externes Programm"
  * #define MSG009  "Dokumentformat"
  * #define MSG010  "Buchhaltungs-Journal                 "
  * #define MSG012  "Invertiertes Journal                 "
  * #define MSG013  "Einzelpreise stmg. brutto            "
  * #define MSG014  "Frage Modular bei Dokumenterstellung "
  #define MSG015  "Zahlart bestÑtigen vor Registrieren"
  * #define MSG016  "Modulares Dokument (J/N) ?"
  * #define MSG017  "Lieferndes Dokument (J/N) ?"
  #define MSG018  "registriert"
  #define MSG019  "offen      "
  #define MSG020  "einzugeben "
  * #define MSG021  "Rechnungen Einkauf   "
  * #define MSG022  "Gutschriften Einkauf "
  * #define MSG023  "Rechnungen Verkauf   "
  * #define MSG024  "Gutschriften Verkauf "
  #define MSG026  "Auswahl "
  *#define MSG027  "Auswahl Lieferant"
  #define MSG028  "Auswahl Postleitzahl/Ort"
  #define MSG029  "Auswahl Artikelgruppe"
  #define MSG030  "Auswahl Artikel"
  #define MSG031  "Auswahl Artikel der Gruppe "
  * #define MSG032  "Auswahl Match-Dokument"
  * #define MSG033  "Frage 'Lieferndes Dokument'          "
  #define MSG034  "Auswahl Generalkonto"
  * #define MSG035  "Auswahl Dokumentmaske"
  * #define MSG037  "Auswahl Einkaufsdokument"
  * #define MSG038  "Dokument drucken wenn [F10]          "
  * #define MSG039  "Automatisch lettrieren               "
  * #define MSG040  "J"
  #define MSG041  "GesamtbetrÑge eingeben"
  static MSG042 := "Dokument drucken wenn [F10]          "
  #define MSG043  "Inhalt kollektiv buchen"
  * #define MSG044  "Vertraulich"
  #define MSG045  "Generalkonten bewegen          "
  * #define MSG046  "Format-Attribute ebenfalls kopieren  "
  * #define MSG047  "TemporÑre Dokumente (AufrÑumen)      "
  #define MSG048  "Partner zuweisen beim Erstellen"
  #define MSG049  "Fakturierungs-Attribute"
  * #define MSG050  "Folgende Maskenbefehle aktivieren :"
  #define MSG051  "Dialogfenster StÅckliste anzeigen"
  static MSG052 := "Termin registrieren"
  #define MSG053  "Projekt zuweisen beim Erstellen"
  * #define MSG054  "Memofelder bei Kopie nicht Åbernehmen"
  * static MSG055 := "Druckmaske fÅr "
  static MSG056 := "Kontrolle Alter/Neuer Saldo"
  #define MSG057  "Saldo pro Dokument auszugleichen     "
  * #define MSG058  "Dokument als Match verwenden         "
  #define MSG059  "Haushaltsartikel beim Erstellen Dok."
  #define MSG060  "Abz. MWSt in MWSt-ErklÑrung          "
  static MSG_PICKDOC := "Auswahl Dokument : "
  * #ifdef DEF_FIN
  *   static MSG_JNLA_R := "öbertragsjournal"
  * #endif DEF_FIN
  #ifdef DEF_STK
    static MSG_JNLA_Q := "Artikel-Bestands-ZÑhler anpassen"
  #endif DEF_STK
  #ifdef DEF_MVS
    static MSG_JNLA_S := "Lagerhistorik bewegen"
  #endif DEF_MVS
  #ifdef DEF_HST
    static MSG_JNLA_U := "Match bei manueller Lettrierung nicht verÑndern"
  #endif DEF_HST
  #ifdef DEF_VEN
    static MSG_JNLA_F := "Chronologische Erfassung forcieren"
  #endif DEF_VEN
  * static MSG_JNLA_O := "manuelle Nummerierung"
  #ifdef DEF_CTS
    static MSG_JNLA_M := "Sammelhistorik Lager aktualisieren"
  #endif DEF_CTS
#endif

#ifdef LG_EN
  #define MSG001  "Quantity format"
  #define MSG002  "Type of journal"
  static MSG007 := "Attributes"
  #define MSG015  "Confirm payment mode before closing"
  #define MSG018  "closed     "
  #define MSG019  "open       "
  #define MSG020  "open (new) "
  #define MSG026  "Select "
  #define MSG028  "Select City"
  #define MSG029  "Select Product group"
  #define MSG030  "Select Product"
  #define MSG031  "Select product of group "
  #define MSG034  "Select general account"
  #define MSG041  "Document Total entered by the user"
  static MSG042 := "Print document when [F10]            "
  #define MSG043  "Collective booking"
  #define MSG045  "Create General ledger transact."
  #define MSG048  "Select partner before creating "
  #define MSG049  "Fakturierungs-Attribute"
  #define MSG051  "Dialogfenster StÅckliste anzeigen"
  static MSG052 := "Termin registrieren"
  #define MSG053  "Projekt zuweisen beim Erstellen"
  static MSG056 := "Check old/new balance      "
  #define MSG057  "Saldo pro Dokument auszugleichen     "
  #define MSG059  "Haushaltsartikel beim Erstellen Dok."
  #define MSG060  "Abz. MWSt in MWSt-ErklÑrung          "
  static MSG_PICKDOC := "Select Document : "
  #ifdef DEF_STK
    static MSG_JNLA_Q := "Artikel-Bestands-ZÑhler anpassen"
  #endif DEF_STK
  #ifdef DEF_MVS
    static MSG_JNLA_S := "Lagerhistorik bewegen"
  #endif DEF_MVS
  #ifdef DEF_HST
    static MSG_JNLA_U := "Match bei manueller Lettrierung nicht verÑndern"
  #endif DEF_HST
  #ifdef DEF_VEN
    static MSG_JNLA_F := "Chronologische Erfassung forcieren"
  #endif DEF_VEN
  * static MSG_JNLA_O := "manuelle Nummerierung"
  #ifdef DEF_CTS
    static MSG_JNLA_M := "Sammelhistorik Lager aktualisieren"
  #endif DEF_CTS
#endif


static saQteForm := { ;
  "0 99999" ,     ;
  "1 999.9" ,     ;
  "2 99.99" ,     ;
  "3 9.999" ,     ;
  ": hh:mm"       ;
}

*static saAlloD := {       ;
*  "Frau             " , ;
*  "Frl.             " , ;
*  "Herrn            " , ;
*  "Familie          "   ;
*}

*static saLangue := { ;
*  "F Franáais  " , ;
*  "D Deutsch   " , ;
*  "N Nederlands" , ;
*  "E English   "   ;
*}

**
**  ARRAYPICK_METHODS
**
**

FUNCTION PickQteForm(cStart)
RETURN ArrayPick( saQteForm, MSG001 , cStart, 1, "QTEFORM")

FUNCTION PickAlias(cStart,cTitle)
local aAlias := {}
#ifdef LG_GERMAN
  #ifdef DEF_KVK
    aadd(aAlias, "KVK : Kassenscheine          " )
  #endif DEF_KVK
  #ifdef DEF_PRE
    aadd(aAlias, "PRE : Dienstleistungsscheine " )
  #endif DEF_PRE
  #ifdef DEF_VEN
    aadd(aAlias, "VEN : Fakturationsjournal    " )
  #endif DEF_VEN
  #ifdef DEF_FIN
    aadd(aAlias, "FIN : Kassen- o. Bankjournal " )
  #endif DEF_FIN
  #ifdef DEF_IMP
    aadd(aAlias, "IMP : Haushaltsbuchungen     " )
  #endif DEF_IMP
  #ifdef DEF_TRA
    aadd(aAlias, "TRA : Transaktionen          " )
  #endif DEF_TRA
  #ifdef DEF_ODS
    aadd(aAlias, "ODS : Diverse Buchungen Lager" )
  #endif DEF_ODS
  #ifdef DEF_ANA
    aadd(aAlias, "ODA : Diverse Buchungen ANA  " )
  #endif DEF_ANA
  aadd(aAlias, "SYS Systemjournal          " )
#else
  #ifdef DEF_KVK
    aadd(aAlias, "KVK : Bons de caisse " )
  #endif DEF_KVK
  #ifdef DEF_PRE
    aadd(aAlias, "PRE : Prestations    " )
  #endif DEF_PRE
  #ifdef DEF_VEN
    aadd(aAlias, "VEN : Facturation    " )
  #endif DEF_VEN
  #ifdef DEF_FIN
    aadd(aAlias, "FIN : Financiers     " )
  #endif DEF_FIN
  #ifdef DEF_IMP
    aadd(aAlias, "IMP : Imputations    " )
  #endif DEF_IMP
  #ifdef DEF_TRA
    aadd(aAlias, "TRA : Transactions   " )
  #endif DEF_TRA
  #ifdef DEF_ODS
    aadd(aAlias, "ODS : O.D. Stock     " )
  #endif DEF_ODS
  #ifdef DEF_ANA
    aadd(aAlias, "ODA : OD's analytiques" )
  #endif DEF_ANA
  aadd(aAlias, "SYS Journal systäme" )
#endif
default cTitle to MSG002
RETURN ArrayPick( aAlias, cTitle, cStart, 3, "JNLTYPE" )

*FUNCTION PickLangue(cStart)
*RETURN ArrayPick(saLangue,MSG003,cStart,1,"LANGUE")

*FUNCTION PickAllo(cLangue)
*local cAllo := NIL
*if cLangue == "D"
*  cAllo := ArrayPick( saAlloD, "Anrede")
*elseif cLangue == "F"
*  cAllo := ArrayPick( saAlloF, "Allocution")
*endif
*if cAllo != NIL
*  keyboard trim(cAllo)
*endif
*RETURN NIL

* FUNCTION PickCtr(cStart)
* RETURN ArrayPick( saCptType, MSG005, cStart, 1 ,"IdCtr")


FUNCTION JnlPickCode(cStart)
#ifdef DEF_VEN
  RETURN PickVnlCode(cStart)  if JNL->Alias == "VEN"
#endif
#ifdef DEF_FIN
  RETURN PickCtr(cStart) if JNL->Alias = "FIN"
#endif
RETURN NIL

**
** PickLnCode()
**
*FUNCTION PickLnCode(cStart)
*static saLib := NIL
*if saLib == NIL
*  #ifdef LG_FRENCH
*    saLib := {                 ;
*      "G compte GÇnÇral ",     ;
*      "R Remarque       "      ;
*    }
*    #ifdef DEF_ART
*      aadd( saLib, "A Article        " )
*    #endif
*    #ifdef DEF_PRESTO
*      aadd( saLib, "P Prestation     " )
*    #endif
*    aadd( saLib, LNCODE_TOTAL + " Sous-total     " )
*  #endif
*  #ifdef LG_GERMAN
*    saLib := {                 ;
*      "G Gegenkonto      ",     ;
*      "R Bemerkung       "      ;
*    }
*    #ifdef DEF_ART
*      aadd( saLib, "A Artikel        " )
*    #endif
*    #ifdef DEF_PRESTO
*      aadd( saLib, "P Dienstleistung " )
*    #endif
*    aadd( saLib, LNCODE_TOTAL + " Zwischensumme  " )
*  #endif
*endif
*RETURN Arraypick(saLib, MSG006, cStart, 1,"LNCODE")

FUNCTION PickVnlCode(cStart)
local a := {}
local i
local nStart := 0
#ifdef LG_GERMAN
  #ifdef DEF_ART
  aadd(a,  LNCODE_ART       + " Artikel          "  )
  aadd(a,  LNCODE_ARTFIXE   + " Artikel Festpreis"  )
  aadd(a,  LNCODE_VARIANTE  + " Variante         "  )
  #endif DEF_ART             +
  aadd(a,  LNCODE_GEN       + " Generalkonto     "  )
  aadd(a,  LNCODE_REMARQ    + " Bemerkung        "  )
  aadd(a,  LNCODE_TOTAL     + " Zwischensumme    "  )
  aadd(a,  LNCODE_MODULE    + " Modul            "  )
#else
  #ifdef DEF_ART
  aadd(a,  LNCODE_ART       + " Article          "  )
  aadd(a,  LNCODE_ARTFIXE   + " Article prix fixe"  )
  aadd(a,  LNCODE_VARIANTE  + " Variante         "  )
  #endif DEF_ART             +
  aadd(a,  LNCODE_GEN       + " compte gÇnÇral   "  )
  aadd(a,  LNCODE_REMARQ    + " Remarque         "  )
  aadd(a,  LNCODE_TOTAL     + " sous-total       "  )
  aadd(a,  LNCODE_MODULE    + " module           "  )
#endif
#ifdef DEF_NEWS
  aadd(a,  LNCODE_NEWS      + " News Item        "  )
#endif
for i := 1 to len(a)
  if left(a[i],1) == cStart
    nStart := i
  endif
next i
browse array a ;
             using {|x| x } ;
             title ("Vorgangsart") ;
             delete .f. ;
             help "VNLCODE" ;
             start nStart
RETURN NIL if lastchoice() == 0
RETURN left(a[lastchoice()],1)


**
**  LIB_METHODS
**
**

* FUNCTION LibCptType(cId) ; RETURN ArrayLib(saCptType,cId,2)
* FUNCTION LibClasse(cId)  ; RETURN ArrayLib(saClasse,cId,2)
* FUNCTION LibModPai(cId)  ; RETURN ArrayLib(saModPai,cId,2)
* FUNCTION LibLangue(cId)  ; RETURN ArrayLib(saLangue,cId,2)
* FUNCTION LibQteForm(cId) ; RETURN ArrayLib(saQteForm,cId,2)

*FUNCTION ArrayLib(a,cId,nCut)
*local i
*for i := 1 to len(a)
*  if a[i] = cId
*    RETURN right(a[i],len(a[i])-nCut)
*  endif
*next i
*RETURN ""



**
**
** PICKATTRIB_METHODS
**

#ifdef DEF_JNL

**
** PickDocAttrib()  - sh. auch VenIniAttrib()
**
*FUNCTION PickDocAttrib(cStart,cIdJnl)
*local aAttrib := {}
*local cReturn := NIL
*aadd(aAttrib, { VENATTR_C, "P.U. TVAC    ", 1 } )
*if len(aAttrib) == 0
*  RETURN NIL
*endif
*cReturn := PickAttrib( aAttrib, MSG007, cStart, "", "DOCATTR" )
*RETURN NIL if cReturn == NIL
*RETURN cReturn

FUNCTION PickIfcAttrib(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  aadd(aAttrib, { IFCATTR_M, "EchÇance fin de mois                " , 1 } )
  aadd(aAttrib, { IFCATTR_W, "prolonger ÇchÇance si week-end      " , 1 } )
  aadd(aAttrib, { IFCATTR_I, "Imprimer document si [F10]          " , 1 } )
  aadd(aAttrib, { IFCATTR_P, "Demander masque d'impression        " , 1 } )
  * aadd(aAttrib, { IFCATTR_C, "Dialogue 'paiement comptant'        " , 1 } )
  aadd(aAttrib, { IFCATTR_E, "Extourne automatique                " , 1 } )
  aadd(aAttrib, { IFCATTR_U, "FA : ne pas recalculer prix unitaire" , 1 } )
  #ifdef DEF_VNA
  aadd(aAttrib, { IFCATTR_A, "Facturation automatique             " , 1 } )
  * aadd(aAttrib, { IFCATTR_G, "Facturation automatique cptes gÇn.  " , 1 } )
  aadd(aAttrib, { IFCATTR_D, "FA : mentionner bons de livr.       " , 1 } )
  aadd(aAttrib, { IFCATTR_R, "FA : Lignes de sÇparation           " , 1 } )
  aadd(aAttrib, { IFCATTR_S, "FA : pas besoin de satisfaire       " , 1 } )
  aadd(aAttrib, { IFCATTR_X, "FA : ne pas confirmer les proposit¯ " , 1 } )
  aadd(aAttrib, { IFCATTR_N, "Accepter un montant total nÇgativ   " , 1 } )
  aadd(aAttrib, { IFCATTR_B, "FA : reprendre Match du doc.original" , 1 } )
  aadd(aAttrib, { IFCATTR_F, "FA : Çditer d'abord l'en-tàte       " , 1 } )
  #endif DEF_VNA
  aadd(aAttrib, { IFCATTR_H, "invisible                           " , 1 } )
#else
  aadd(aAttrib, { IFCATTR_M, "Zahlungsziel Monatsende               " , 1 } )
  aadd(aAttrib, { IFCATTR_W, "Zahlungsziel nicht auf Wochenende     " , 1 } )
  aadd(aAttrib, { IFCATTR_I, "Dokument drucken wenn [F10]           " , 1 } )
  aadd(aAttrib, { IFCATTR_P, "Druckmaske auswÑhlen                  " , 1 } )
  * aadd(aAttrib, { IFCATTR_C, "Dialog 'Barzahlung'                   " , 1 } )
  aadd(aAttrib, { IFCATTR_E, "Automatische Gegenbuchung             " , 1 } )
  aadd(aAttrib, { IFCATTR_U, "StÅckpreise nicht neu rechnen bei AF  " , 1 } )
  #ifdef DEF_VNA
  aadd(aAttrib, { IFCATTR_A, "Automatik-Fakturierung                " , 1 } )
  * aadd(aAttrib, { IFCATTR_G, "Automatik-Fakturierung Generalkonten  " , 1 } )
  aadd(aAttrib, { IFCATTR_D, "Lieferscheine angeben bei AF          " , 1 } )
  aadd(aAttrib, { IFCATTR_R, "Leerzeilen generieren bei AF          " , 1 } )
  aadd(aAttrib, { IFCATTR_S, "braucht nicht befriedigt zu werden    " , 1 } )
  aadd(aAttrib, { IFCATTR_X, "AF-VorschlÑge o. Dialog Åbernehmen    " , 1 } )
  aadd(aAttrib, { IFCATTR_N, "Negativen Gesamtbetrag zulassen       " , 1 } )
  aadd(aAttrib, { IFCATTR_B, "RÅckbezug auf Ursprungsdokument bei AF" , 1 } )
  aadd(aAttrib, { IFCATTR_F, "zuerst Vollbild bearbeiten bei AF     " , 1 } )
  #endif DEF_VNA
  aadd(aAttrib, { IFCATTR_H, "Unsichtbar                            " , 1 } )
#endif
RETURN PickAttrib(aAttrib,MSG049,cStart,"","IFCATTR")

FUNCTION PickIpbAttrib(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  aadd(aAttrib, { IPBATTR_E, "rÇservÇ Ö l'expert               " , 1 } )
#else
  aadd(aAttrib, { IPBATTR_E, "nur fÅr Experten                    " , 1 } )
#endif
RETURN PickAttrib(aAttrib,NIL,cStart,"","IPBATTR")



**
** JnlDocLib()
**
FUNCTION JnlDocLib(cIdJnl,cIdDoc,cDC,cLangue)
local cLibDoc :=  ""
local jnl := JnlLocate(cIdJnl)
RETURN "" if jnl == NIL
default cLangue to TplLang()
default cDC to jnl[JNL_DC]
if cDC == jnl[JNL_DC]
  if cLangue == MemLang1
    cLibDoc := jnl[JNL_DOCLIB1]
  elseif cLangue == MemLang2
    cLibDoc := jnl[JNL_DOCLIB2]
  elseif cLangue == MemLang3
    cLibDoc := jnl[JNL_DOCLIB3]
  #ifdef DEF_4LANG
  elseif cLangue == MemLang4
    cLibDoc := jnl[JNL_DOCLIB4]
  #endif
  endif
  if empty(cLibDoc)
    cLibDoc := jnl[JNL_DOCLIB1]
  endif
else
  if cLangue == MemLang1
    cLibDoc := jnl[JNL_DOCLIB1N]
  elseif cLangue == MemLang2
    cLibDoc := jnl[JNL_DOCLIB2N]
  elseif cLangue == MemLang3
    cLibDoc := jnl[JNL_DOCLIB3N]
  #ifdef DEF_4LANG
  elseif cLangue == MemLang4
    cLibDoc := jnl[JNL_DOCLIB4N]
  #endif
  endif
  if empty(cLibDoc)
    cLibDoc := jnl[JNL_DOCLIB1N]
  endif
endif
if left(cLibDoc,1) == "="
  cLibDoc := xparse(substr(cLibDoc,2))
else
  cLibDoc := strtran(cLibDoc,"{id}",cIdDoc)
endif
RETURN cLibDoc


#endif DEF_JNL


#ifdef DEF_VEN

FUNCTION PickIprAttrib(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  aadd(aAttrib, { IPRATTR_C, "Prix unitaire TVA comprise                       ", 1 } )
  #ifdef DEF_PRIXR
  aadd(aAttrib, { IPRATTR_R, "Ne pas avertir si prix unitaire < prix de revient", 1 } )
  #endif DEF_PRIXR
#else
  aadd(aAttrib, { IPRATTR_C, "StÅckpreis inklusive MWSt                        " , 1 } )
  #ifdef DEF_PRIXR
  aadd(aAttrib, { IPRATTR_R, "Keine Warnung wenn StÅckpreis < Selbstkostenpreis" , 1 } )
  #endif DEF_PRIXR
#endif
RETURN PickAttrib(aAttrib,NIL,cStart,"","IPR")

#endif DEF_VEN

*FUNCTION PickTxtAttrib(cStart)
*local aAttrib := {}
*#ifdef LG_FRENCH
*  aadd(aAttrib, { "C", "SignalÇtique Clients     ", 1 } )
*  aadd(aAttrib, { "F", "SignalÇtique Fournisseurs", 1 } )
*  aadd(aAttrib, { "A", "SignalÇtique Articles    ", 1 } )
*  aadd(aAttrib, { "V", "Documents vente          ", 1 } )
*  aadd(aAttrib, { "E", "Documents achat          ", 1 } )
*  aadd(aAttrib, { "R", "Rappels de paiement      ", 1 } )
*  aadd(aAttrib, { "P", "Prestations              ", 1 } )
*  aadd(aAttrib, { "M", "Mailbox                  ", 1 } )
*#else
*  aadd(aAttrib, { "C", "Stammdaten Kunden     ", 1 } )
*  aadd(aAttrib, { "F", "Stammdaten Lieferanten", 1 } )
*  aadd(aAttrib, { "A", "Stammdaten Artikel    ", 1 } )
*  aadd(aAttrib, { "V", "Dokumente Verkauf     ", 1 } )
*  aadd(aAttrib, { "E", "Dokumente Einkauf     ", 1 } )
*  aadd(aAttrib, { "R", "Mahnbriefe            ", 1 } )
*  aadd(aAttrib, { "P", "Dienstleistungen      ", 1 } )
*  aadd(aAttrib, { "M", "Mailbox               ", 1 } )
*#endif
*RETURN PickAttrib(aAttrib,MSG050,cStart,"","TXTATTR")

#ifdef DEF_TAX

FUNCTION PickTaxAttrib(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  * aadd(aAttrib, { TAXATTR_R, "arrondir par document            ", 1 } )
  aadd(aAttrib, { TAXATTR_T, "Code tolÇrant                    ", 1 } )
  * aadd(aAttrib, { TAXATTR_A, "Liste TVA des clients assujettis ", 1 } )
  * aadd(aAttrib, { TAXATTR_I, "Liste TVA des clients intracom   ", 1 } )
#else
  * aadd(aAttrib, { TAXATTR_R, "BetrÑge pro Dokument runden      ", 1 } )
  aadd(aAttrib, { TAXATTR_T, "toleranter MWSt-Code               ", 1 } )
  * aadd(aAttrib, { TAXATTR_A, "Umsatzliste Mwst-pflichtige Kunden ", 1 } )
  * aadd(aAttrib, { TAXATTR_I, "Umsatzliste Intracom-Kunden        ", 1 } )
#endif
RETURN PickAttrib(aAttrib,NIL,cStart,"","TAXATTR")

#endif DEF_TAX

FUNCTION PickGenAttrib(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  aadd(aAttrib, { GENATTR_C, "confidentiel                 ", 1 } )
  aadd(aAttrib, { GENATTR_D, "pas de dÇtail dans historique", 1 } )
  aadd(aAttrib, { GENATTR_F, "forcer le code T.V.A.        ", 1 } )
  aadd(aAttrib, { GENATTR_H, "invisible                    ", 1 } )
  aadd(aAttrib, { GENATTR_L, "lettrage                     ", 1 } )
  aadd(aAttrib, { GENATTR_R, "protÇgÇ en Çcriture          ", 1 } )
  aadd(aAttrib, { GENATTR_T, "tolÇrer achat ET vente       ", 1 } )
  aadd(aAttrib, { GENATTR_M, "tolÇrer imputation manuelle  ", 1 } )
  * #ifdef DEF_INT
  * aadd(aAttrib, { GENATTR_I, "ventilation intrastat        ", 1 } )
  * #endif DEF_INT
  #ifdef DEF_ANA
  aadd(aAttrib, { GENATTR_Y, "ventilation analytique       ", 1 } )
  #endif DEF_ANA
#else
  aadd(aAttrib, { GENATTR_C, "vertraulich                   ", 1 } )
  aadd(aAttrib, { GENATTR_D, "ohne Detail in Historik       ", 1 } )
  aadd(aAttrib, { GENATTR_F, "MWSt-Code forcieren           ", 1 } )
  aadd(aAttrib, { GENATTR_H, "unsichtbar                    ", 1 } )
  aadd(aAttrib, { GENATTR_L, "Lettrieren                    ", 1 } )
  aadd(aAttrib, { GENATTR_R, "SchreibgeschÅtzt              ", 1 } )
  aadd(aAttrib, { GENATTR_T, "Einkauf UND Verkauf tolerieren", 1 } )
  aadd(aAttrib, { GENATTR_M, "Manuelle Buchungen tolerieren", 1 } )
  * #ifdef DEF_INT
  * aadd(aAttrib, { GENATTR_I, "Intrastat-Angaben erfassen   ", 1 } )
  * #endif DEF_INT
  #ifdef DEF_ANA
  aadd(aAttrib, { GENATTR_Y, "analYtisch aufteilen          ", 1 } )
  #endif DEF_ANA
#endif
RETURN PickAttrib(aAttrib,NIL,cStart,"","GENATTR")



#ifdef DEF_IMP

FUNCTION PickSatAttr(cStart)
local aAttrib := {}
aadd(aAttrib, { SATATTR_S, "Selbstbefriedigt                             ", 1 } )
aadd(aAttrib, { SATATTR_P, "Permanent (bleibt offen)                     ", 1 } )
aadd(aAttrib, { SATATTR_U, "befriedigten Betrag wieder ent-zentralisieren", 1 } )
aadd(aAttrib, { SATATTR_N, "befriedigten Betrag nicht zentralisieren     ", 1 } )
aadd(aAttrib, { SATATTR_X, "Backmatch entfriedigen                       ", 1 } )
aadd(aAttrib, { SATATTR_M, "Backmatch muss Åbereinstimmen                ", 1 } )
RETURN PickAttrib(aAttrib,NIL,cStart,"","SATATTR")

#endif DEF_IMP

#ifdef DEF_PRESTO

FUNCTION PickAgsAttrib(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  aadd(aAttrib, { AGSATTR_H, "ne pas afficher das le menu principal", 1 } )
  aadd(aAttrib, { AGSATTR_R, "Interdire les modifications          ", 1 } )
  * aadd(aAttrib, { AGSATTR_A, "Facturation automatique              ", 1 } )
  aadd(aAttrib, { AGSATTR_I, "Imprimer document                    ", 1 } )
#else
  aadd(aAttrib, { AGSATTR_H, "nicht anzeigen im HauptmenÅ ", 1 } )
  * aadd(aAttrib, { AGSATTR_A, "Automatik-Fakturierung      ", 1 } )
  aadd(aAttrib, { AGSATTR_R, "énderungen verweigern       ", 1 } )
  aadd(aAttrib, { AGSATTR_I, "Dokument drucken            ", 1 } )
#endif
RETURN PickAttrib(aAttrib,NIL,cStart,"","AGSATTR")

#endif DEF_PRESTO

#ifdef DEF_ECHE

FUNCTION PickEcsAttrib(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  aadd(aAttrib, { "+", "Ö recevoir  ", 1 } )
  aadd(aAttrib, { "-", "Ö payer     ", 1 } )
#else
  aadd(aAttrib, { "+", "zu erhalten ", 1 } )
  aadd(aAttrib, { "-", "zu zahlen   ", 1 } )
#endif
RETURN PickAttrib(aAttrib,NIL,cStart,"","ECSATTR")

#endif DEF_ECHE

#ifdef DEF_VAR

FUNCTION PickVrtAttrib(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  aadd(aAttrib, { VRTATTR_P, "prÇfixe dÇsignation", 1 } )
  aadd(aAttrib, { VRTATTR_S, "suffixe dÇsignation", 1 } )
#else
  aadd(aAttrib, { VRTATTR_P, "Vor Artikelbez. setzen   ", 1 } )
  aadd(aAttrib, { VRTATTR_S, "Hinter Artikelbez. setzen", 1 } )
#endif
RETURN PickAttrib(aAttrib,NIL,cStart,"","VRTATTR")

#endif DEF_VAR

*#ifdef DEF_PFS
*
*FUNCTION PickPfsAttrib(cStart)
*local aAttrib := {}
*#ifdef LG_FRENCH
*  aadd(aAttrib, { "R", "manuel (ne pas recalculer)", 1 } )
*#else
*  aadd(aAttrib, { "R", "manuell (nicht neu rechnen)", 1 } )
*#endif
*RETURN PickAttrib(aAttrib,MSG007,cStart,"","PFSATTR")
*
*#endif DEF_PFS

*#ifdef DEF_SHT
*
*FUNCTION PickBalAttrib(cStart)
*local aAttrib := {}
*#ifdef LG_FRENCH
*  aadd(aAttrib, { "M", "DÇtailler chaque compte mouvementÇ", 1 } )
*  aadd(aAttrib, { "A", "DÇtailler comptes non mouvementÇs ", 1 } )
*  aadd(aAttrib, { "H", "Imprimer titre du champ           ", 1 } )
*  aadd(aAttrib, { "T", "Imprimer total du champ           ", 1 } )
*  aadd(aAttrib, { "D", "Solde dÇbiteur                    ", 1 } )
*  aadd(aAttrib, { "C", "Solde crÇditeur                   ", 1 } )
*  aadd(aAttrib, { "%", "RÇsultat en %                     ", 1 } )
*#else
*  aadd(aAttrib, { "M", "Bewegte Konten detaillieren       ", 1 } )
*  aadd(aAttrib, { "A", "auch unbewegte Konten detaillieren", 1 } )
*  aadd(aAttrib, { "H", "Feldtitel drucken                 ", 1 } )
*  aadd(aAttrib, { "T", "Feldsumme drucken                 ", 1 } )
*  aadd(aAttrib, { "D", "Saldo normalerweise DB            ", 1 } )
*  aadd(aAttrib, { "C", "Saldo normalerweise CR            ", 1 } )
*  aadd(aAttrib, { "%", "Resultat in %                     ", 1 } )
*#endif
*RETURN PickAttrib(aAttrib,NIL,cStart,"","BALATTR")
*
*FUNCTION PickShtAttrib(cStart)
*local aAttrib := {}
*#ifdef LG_FRENCH
*  aadd(aAttrib, { "I", "Colonne 'Solde initial' (D et C)   ", 1 } )
*  aadd(aAttrib, { "P", "Colonne 'Mouvements de la pÇriode' ", 1 } )
*  aadd(aAttrib, { "F", "Colonne 'Solde final' (D et C)     ", 1 } )
*  aadd(aAttrib, { "S", "Colonne 'Solde' (D ou C)           ", 1 } )
*  aadd(aAttrib, { "E", "Ignorer le solde initial           ", 1 } )
*#else
*  aadd(aAttrib, { "I", "Kolonne 'Beginnsaldo' (D und C) ", 1 } )
*  aadd(aAttrib, { "P", "Kolonne 'Kontenbewegungen'      ", 1 } )
*  aadd(aAttrib, { "F", "Kolonne 'Endsaldo' (D und C)    ", 1 } )
*  aadd(aAttrib, { "S", "Kolonne 'Saldo' (D oder C)      ", 1 } )
*  aadd(aAttrib, { "E", "Beginnsalden ignorieren         ", 1 } )
*#endif
*RETURN PickAttrib(aAttrib,NIL,cStart,"","SHTATTR")
*
*#endif DEF_SHT

#ifdef DEF_JNL

**
** PickJnlAttrib()
**
FUNCTION PickJnlAttrib(cStart,cAlias)
local aAttrib := {}
#ifdef DEF_VEN
  if cAlias == "VEN"
    #ifdef DEF_HST
      aadd(aAttrib, { JNLATTR_L, padr(MsgSatis(),50) , 1 } )
      aadd(aAttrib, { JNLATTR_G, padr(MSG045,50) , 1 } )
      aadd(aAttrib, { JNLATTR_U, padr(MSG_JNLA_U,50) , 1 } )
    #endif DEF_HST
    #ifdef DEF_PRJ
      aadd(aAttrib, { JNLATTR_J, padr(MSG053,50) , 1 } )
    #endif DEF_PRJ
    #ifdef DEF_HOLZ
      aadd(aAttrib, { JNLATTR_D, padr(MSG051,50) , 1 } )
    #endif DEF_HOLZ
    aadd(aAttrib, { JNLATTR_F, padr(MSG_JNLA_F,50) , 1 } )
    * aadd(aAttrib, { JNLATTR_O, padr(MSG_JNLA_O,50) , 1 } )
    aadd(aAttrib, { JNLATTR_P, padr(MSG048,50) , 1 } )
    aadd(aAttrib, { JNLATTR_T, padr(MSG041,50) , 1 } )
    aadd(aAttrib, { JNLATTR_E, padr(MSG015,50) , 1 } )
    aadd(aAttrib, { JNLATTR_K, padr(MSG043,50) , 1 } )
    aadd(aAttrib, { JNLATTR_C, padr("StÅckpreise inkl. MWSt.",50) , 1 } )
    #ifdef DEF_MVS
      aadd(aAttrib, { JNLATTR_S, padr(MSG_JNLA_S,50) , 1 } )
      aadd(aAttrib, { JNLATTR_V, padr("Lagerbestand valorisieren",50) , 1 } )
    #endif DEF_MVS
    #ifdef DEF_CTS
      aadd(aAttrib, { JNLATTR_M, padr(MSG_JNLA_M,50) , 1 } )
    #endif DEF_CTS
    #ifdef DEF_INT
      aadd(aAttrib, { JNLATTR_I, padr("Instrastat",50) , 1 } )
    #endif DEF_INT
    #ifdef DEF_STK
      aadd(aAttrib, { JNLATTR_Q, padr(MSG_JNLA_Q,50) , 1 } )
    #endif DEF_STK
    aadd(aAttrib, { JNLATTR_R, padr("Buchung im Monat nach Buchungsperiode",50) , 1 } )
    * #ifdef DEF_ACF
    *   aadd(aAttrib, { JNLATTR_R, padr("Partnerpreise aktualisieren",50) , 1 } )
    * #endif DEF_ACF
    #ifdef DEF_RSV
      aadd(aAttrib, { JNLATTR_R, padr("Reservierungen eintragen'",50) , 1 } )
    #endif DEF_RSV
    #ifdef DEF_VNA
      aadd(aAttrib, { JNLATTR_A, padr("kann FakturierungsvorschlÑge befriedigen",50) , 1 } )
    #endif DEF_VNA
    #ifdef DEF_ANA
      aadd(aAttrib, { JNLATTR_Y, padr("Analytisch verteilen",50) , 1 } )
    #endif DEF_ANA
  endif
#endif DEF_VEN
#ifdef DEF_FIN
  if cAlias == "FIN"
    aadd(aAttrib, { JNLATTR_L, padr(MsgSatis(),50) , 1 } )
    aadd(aAttrib, { JNLATTR_I, padr(MSG042,50) , 1 } )
    aadd(aAttrib, { JNLATTR_S, padr(MSG056,50) , 1 } )
    * aadd(aAttrib, { JNLATTR_E, padr(MSG057,50) , 1 } )
    aadd(aAttrib, { JNLATTR_D, padr(MSG060,50) , 1 } )
    aadd(aAttrib, { JNLATTR_T, padr(MSG041,50) , 1 } )
    * aadd(aAttrib, { JNLATTR_C, padr(MSG044,50) , 1 } )
    * aadd(aAttrib, { JNLATTR_R, padr(MSG_JNLA_R,50) , 1 } )
    #ifdef DEF_HST
      aadd(aAttrib, { JNLATTR_G, padr(MSG045,50) , 1 } )
      aadd(aAttrib, { JNLATTR_U, padr(MSG_JNLA_U,50) , 1 } )
    #endif DEF_HST
    aadd(aAttrib, { JNLATTR_K, padr(MSG043,50) , 1 } )
    aadd(aAttrib, { JNLATTR_F, padr(MSG_JNLA_F,50) , 1 } )
    * aadd(aAttrib, { JNLATTR_O, padr(MSG_JNLA_O,50) , 1 } )
    #ifdef DEF_ANAFIN
      aadd(aAttrib, { JNLATTR_Y, padr("Analytisch verteilen",50) , 1 } )
    #endif DEF_ANAFIN
    aadd(aAttrib, { JNLATTR_B, padr("Neu erstellte Dokumente in GrundwÑhrung",50) , 1 } )
    aadd(aAttrib, { JNLATTR_P, padr("Buchungsperiode pro Transaktion",50) , 1 } )
    aadd(aAttrib, { JNLATTR_A, padr("Datum pro Transaktion",50) , 1 } )
    aadd(aAttrib, { JNLATTR_R, padr("Buchung im Monat nach Buchungsperiode",50) , 1 } )
    aadd(aAttrib, { JNLATTR_M, padr("Dokumentnummer als Match wenn Datum leer",50) , 1 } )
  endif
#endif DEF_FIN
#ifdef DEF_ODS
  if cAlias == "ODS"
    #ifdef DEF_MVS
    aadd(aAttrib, { JNLATTR_S, padr(MSG_JNLA_S,50) , 1 } )
    aadd(aAttrib, { JNLATTR_V, padr("Lagerbestand valorisieren",50) , 1 } )
    #endif DEF_MVS
    #ifdef DEF_STK
    aadd(aAttrib, { JNLATTR_Q, padr(MSG_JNLA_Q,50) , 1 } )
    #endif DEF_STK
    #ifdef DEF_CTS
      aadd(aAttrib, { JNLATTR_M, padr(MSG_JNLA_M,50) , 1 } )
    #endif DEF_CTS
  endif
#endif DEF_ODS
#ifdef DEF_KVK
  if cAlias == JNLALIAS_KVK
    aadd(aAttrib, { JNLATTR_F, padr(MSG_JNLA_F,50) , 1 } )
    aadd(aAttrib, { JNLATTR_G, padr(MSG045,50) , 1 } )
    aadd(aAttrib, { JNLATTR_I, padr(MSG042,50) , 1 } )
    #ifdef DEF_HST
    aadd(aAttrib, { JNLATTR_L, padr(MsgSatis(),50) , 1 } )
    #endif DEF_HST
    #ifdef DEF_CTS
      aadd(aAttrib, { JNLATTR_M, padr(MSG_JNLA_M,50) , 1 } )
    #endif DEF_CTS
    #ifdef DEF_STK
    aadd(aAttrib, { JNLATTR_Q, padr(MSG_JNLA_Q,50) , 1 } )
    #endif DEF_STK
    #ifdef DEF_MVS
    aadd(aAttrib, { JNLATTR_S, padr(MSG_JNLA_S,50) , 1 } )
    aadd(aAttrib, { JNLATTR_V, padr("Lagerbestand valorisieren",50) , 1 } )
    #endif DEF_MVS
  endif
#endif DEF_ODS
#ifdef DEF_IMP
  if cAlias == "IMP"
    aadd(aAttrib, { JNLATTR_A, padr("EBE/ABE automatisch erstellen",50) , 1 } )
    aadd(aAttrib, { JNLATTR_B, padr(MSG059,50) , 1 } )
    * aadd(aAttrib, { JNLATTR_C, padr("KassenbetriebfÑhig",50) , 1 } )
    aadd(aAttrib, { JNLATTR_E, padr(MSG057,50) , 1 } )
    aadd(aAttrib, { JNLATTR_F, padr("Buchungsrichtung forcieren",50) , 1 } )
    aadd(aAttrib, { JNLATTR_G, padr("Gesperrt fÅr manuelle Erfassung",50) , 1 } )
    aadd(aAttrib, { JNLATTR_I, padr(MSG042,50) , 1 } )
    aadd(aAttrib, { JNLATTR_K, padr("im Kassenjournal anfÅhren",50) , 1 } )
    aadd(aAttrib, { JNLATTR_L, padr("Schlu·licht-Jnl (immer befriedigt)",50) , 1 } )
    aadd(aAttrib, { JNLATTR_M, padr("Backmatch erforderlich",50) , 1 } )
    aadd(aAttrib, { JNLATTR_N, padr("Negativ (umgekehrte Buchungsrichtung)",50) , 1 } )
    aadd(aAttrib, { JNLATTR_P, padr(MSG048,50) , 1 } )
    aadd(aAttrib, { JNLATTR_R, padr("Buchung im Monat nach Buchungsperiode",50) , 1 } )
    aadd(aAttrib, { JNLATTR_S, padr(MSG056,50) , 1 } )
    aadd(aAttrib, { JNLATTR_T, padr("KreditÅberschreitungen tolerieren",50) , 1 } )
    aadd(aAttrib, { JNLATTR_U, padr("öberbefriedigung bei öbernahme verweigern",50) , 1 } )
    aadd(aAttrib, { JNLATTR_V, padr("Kann durch anderen Partner befriedigt werden",50) , 1 } )
    aadd(aAttrib, { JNLATTR_X, padr("Stornierungs-Journal (spez. Zentral.)",50) , 1 } )
    aadd(aAttrib, { JNLATTR_Y, padr("Analytisch verteilen",50) , 1 } )
    aadd(aAttrib, { JNLATTR_Z, padr("Folgedokumente zusammenlegen",50) , 1 } )
    aadd(aAttrib, { JNLATTR_1, padr("Artikel auswÑhlen via TRT statt direkt",50) , 1 } )
  endif
#endif DEF_IMP
#ifdef DEF_TRA
  if cAlias == "TRA"
    aadd(aAttrib, { JNLATTR_I, padr(MSG042,50) , 1 } )
    aadd(aAttrib, { JNLATTR_F, padr("Buchungsrichtung forcieren",50) , 1 } )
  endif
#endif DEF_TRA
RETURN PickAttrib(aAttrib,MSG007,cStart,"","JNLATTR")

#endif DEF_JNL

**
** TacPickAttr()
**
FUNCTION TacPickAttr(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  aadd(aAttrib, { "H", "invisibles dans l'Çcran principal" , 1 } )
  aadd(aAttrib, { "U", "personnelles                     " , 1 } )
  aadd(aAttrib, { "I", "pour usage interne               " , 1 } )
#else
  aadd(aAttrib, { "H", "unsichtbar im Hauptbildschirm" , 1 } )
  aadd(aAttrib, { "U", "persînlich                   " , 1 } )
  aadd(aAttrib, { "I", "fÅr internen Gebrauch        " , 1 } )
#endif
RETURN PickAttrib(aAttrib,MSG007,cStart,"","TACATTR")

**
** EscPickAttrib()
**
FUNCTION EscPickAttrib(cStart)
local aAttrib := {}
#ifdef LG_GERMAN
  aadd(aAttrib, { "A", "Anzahlungen im voraus      " , 1 } )
  aadd(aAttrib, { "D", "Dialog 'Kassen-Ein/Ausgang'" , 1 } )
  aadd(aAttrib, { "M", "Monatsende                 " , 1 } )
  aadd(aAttrib, { "E", "Dialog 'ZahlungsauftrÑge'  " , 1 } )
#else
  aadd(aAttrib, { "A", "Paiements anticipÇs            " , 1 } )
  aadd(aAttrib, { "D", "Dialogue 'EntrÇe/sortie caisse'" , 1 } )
  aadd(aAttrib, { "M", "Fin de mois                    " , 1 } )
  aadd(aAttrib, { "E", "Dialogue 'Ordres de paiement'  " , 1 } )
#endif
RETURN PickAttrib(aAttrib,MSG007,cStart,"","ESCATTR")


#ifdef DEF_PIN

**
** PinPickAttrib()
**
*FUNCTION PinPickAttrib(cStart)
*local aAttrib := {}
*aadd(aAttrib, { "H", "Hidden" , 1 } )
*aadd(aAttrib, { "S", "Subtle" , 1 } )
*aadd(aAttrib, { "J", "Jargon" , 1 } )
*RETURN PickAttrib(aAttrib,MSG007,cStart,"","PINATTR")


#endif DEF_PIN

**
** PickPar()
**
FUNCTION PickPar( cPrtList, cStart, cTitle, xuReturn ) // , bPreSelect )
local uReturn := NIL // local cIdPar := NIL
local b := oPar()
local prt
local nStart := 1 // DDSTART_TOP
default cStart to ""
default xuReturn to "PAR->IdPar"
if len(trim(cStart)) == LEN_IDPRT
  prt := PrtLocate(trim(cStart))
  cStart := ""
endif
* default prt to PrtLocate(padr("*",LEN_IDPRT))
if prt == NIL
  RETURN NIL if (prt := PickPrt(cPrtList,cTitle)) == NIL
endif
default cTitle to MSG026 + trim(prt[PRT_NAME])
default cStart to ""
open area b, oPlz(), oNat(), oClb()
  if empty(prt[PRT_ID]) .or. prt[PRT_ID] == padr("*",LEN_IDPRT)
    if ! empty(cStart)
      softseek trim(cStart)
      nStart := 0
    endif
    edit data   b ;
         mode   pick ;
         start  (nStart) ;
         query  ("PAR" + prt[PRT_IDQRY_PICK]) ;
         filter "!'"+PARATTR_H+"'$PAR->Attrib" ;
         title  (cTitle)
  else
    if empty(cStart)
      ddSetOrder(ORD_PAR_PRTNAME)
      softseek prt[PRT_ID] // cIdPrt
    else
      softseek trim(cStart)
      ddSetOrder(ORD_PAR_PRTNAME)
    endif
    edit data   b ;
         key    PAR->IdPrt ;
         value  prt[PRT_ID] ; // create {|| ParCreate(prt[PRT_ID]) } ;
         mode   pick ;
         query  ("PAR" + prt[PRT_IDQRY_PICK]) ;
         filter "!'"+PARATTR_H+"'$PAR->Attrib" ;
         title  (cTitle)
  endif
  if ddLastReq() == DDEDIT_SELECT
    * cIdPar := PAR->IdPar
    uReturn := &xuReturn
  endif
close area
RETURN uReturn

FUNCTION StdGetIdPar(x,cPrtList)
local prt
if val(x) == 0
  RETURN x if len(alltrim(x)) == LenIdPar()
  if val(substr(x,LEN_IDPRT+1)) != 0
    // "L1    " --> "L00001" (z.B. bei HK)
    // aber nicht aus "LANCE " "L0ANCE" machen
    prt := PrtLocate(upper(left(x,LEN_IDPRT)))
    RETURN x if prt == NIL
    x := upper(left(x,LEN_IDPRT)) ;
      + padl(alltrim(substr(x,2)),LenIdPar()-LEN_IDPRT,"0")
  endif
  RETURN x
endif
x := trim(x)
if cPrtList != NIL .and.  len(x) < LenIdPar()
  if (prt := PrtLocate(left(cPrtList,LEN_IDPRT))) != NIL
    RETURN left(prt[PRT_FIRSTID],LEN_IDPRT) + padl(x,LenIdPar()-LEN_IDPRT,"0")
  endif
endif
RETURN padl(x,LenIdPar(),"0")

**
** PickStreet()
**
FUNCTION PickStreet( cIdNat, cIdPlz, cStart )
local b := oPar()
local cStreet := NIL
open area b, oPlz(), oNat()
  ddSetOrder(ORD_PAR_PLZ)
  softseek cIdNat + cIdPlz + upper(trim(cStart))
  edit data   b ;
       key    PAR->Pays + PAR->CP ;
       value  cIdNat + cIdPlz ;
       create {|| DDCREATE_FAIL } ;
       mode   pick ;
       query  ("PARRUE") ;
       title  ("Auswahl Stra·e " + trim(cIdNat) + "-" + trim(cIdPlz))
  if ddLastReq() == DDEDIT_SELECT
    cStreet := PAR->Rue
  endif
close area
RETURN cStreet


#ifdef DEF_PRJ

**
** PickPrj()
**
FUNCTION PickPrj( cStart, cTitle )
local cId := NIL
local b := oPrj()
default cTitle to "zuweisen zu Projekt..."
open area b
  if cStart != NIL
    softseek trim(cStart)
  endif
  * open window (cTitle) size 10,70 help PICKPRJ
  edit data b mode pick query "PRJPICK" title (cTitle)
  * close window
  if ddLastReq() == DDEDIT_SELECT
    cId := PRJ->IdPrj
  endif
close area
RETURN cId

* FUNCTION DocPickPrj
* local cIdPrj := PickPrj(FIELD->IdPrj)
* RETURN .f. if cIdPrj == NIL
* MemIdPrj := cIdPrj
* if ddRecLock()
*   FIELD->IdPrj := cIdPrj
*   unlock
*   ddRefreshCurrent()
* endif
* RETURN MnuDone()

#endif DEF_PRJ

**
** PickPlz()
**
FUNCTION PickPlz( cPays, cStart )
local cId := NIL
local b := oPlz()
if empty(cPays)
  cPays := MemPays
endif
open area b
  if empty(cStart)
    ddSetOrder(2)
    go top
  else
    ddSetOrder(1)
    softseek cPays + cStart
    ddSetOrder(2)
  endif
  edit data b ;
    key PLZ->Pays ;
    value cPays ;
    mode pick ;
    create {|| PlzCreate(cPays,PLZ->CP)} ;
    query "PLZPICK" ;
    title MSG028
  if ddLastReq() == DDEDIT_SELECT
    cId := PLZ->CP
  endif
close area
RETURN cId

*FUNCTION AdrPickPlz()
*local cId := PickPlz(FIELD->Pays,FIELD->CP)
*RETURN NIL if cId == NIL
*FIELD->Pays := left(cId,3)
*RETURN right(cId,8)



FUNCTION PickDoc(cIdJnl,cStart,xuReturn)
local b
local cIdDoc := NIL
default xuReturn to "FIELD->IdDoc"
#ifdef DEF_VEN
  if JnlAlias(cIdJnl) == "VEN"
    b := oVen()
    open area b, oPar()
        softseek cIdJnl + cStart
        edit data b ;
                  key      VEN->IdJnl value cIdJnl ;
                  mode     pick                         ;
                  create   {|| DDCREATE_FAIL } ;
                  query    "VENPICK" ;
                  title (MSG_PICKDOC + cIdJnl)
      if ddLastReq() == DDEDIT_SELECT
        cIdDoc := &xuReturn // VEN->IdDoc
      endif
    close area
  endif
#endif DEF_VEN
#ifdef DEF_IMP
  if JnlAlias(cIdJnl) == "IMP"
    b := oImp()
    open area b, oPar(), oBud()
        softseek cIdJnl + cStart
        edit data b ;
                  key      IMP->IdJnl value cIdJnl ;
                  mode     pick                         ;
                  create   {|| DDCREATE_FAIL } ;
                  query    "IMPPICK" ;
                  title (MSG_PICKDOC + cIdJnl)
      if ddLastReq() == DDEDIT_SELECT
        cIdDoc := IMP->IdDoc
      endif
    close area
  endif
#endif DEF_IMP
#ifdef DEF_FIN
  if JnlAlias(cIdJnl) == "FIN"
    b := oFin()
    open area b
        softseek cIdJnl + cStart
        edit data b ;
                  key      FIN->IdJnl value cIdJnl ;
                  mode     pick                         ;
                  create   {|| DDCREATE_FAIL} ;
                  query    "FINPICK" ;
                  title (MSG_PICKDOC + cIdJnl)
      if ddLastReq() == DDEDIT_SELECT
        cIdDoc := FIN->IdDoc
      endif
    close area
  endif
#endif DEF_FIN
#ifdef DEF_ODS
  if JnlAlias(cIdJnl) == "ODS"
    b := oOds()
    open area b, oPar()
        softseek cIdJnl + cStart
        edit data b ;
                  key      ODS->IdJnl value cIdJnl ;
                  mode     pick                         ;
                  create   {|| DDCREATE_FAIL} ;
                  query    "ODSPICK" ;
                  title (MSG_PICKDOC + cIdJnl)
      if ddLastReq() == DDEDIT_SELECT
        cIdDoc := ODS->IdDoc
      endif
    close area
  endif
#endif DEF_FIN
#ifdef DEF_KVK
  if JnlAlias(cIdJnl) == JNLALIAS_KVK
    b := oKvk()
    open area b, oPar()
        softseek cIdJnl + cStart
        edit data b ;
                  key      KVK->IdJnl value cIdJnl ;
                  mode     pick                         ;
                  create   {|| DDCREATE_FAIL} ;
                  query    "KVKPICK" ;
                  title (MSG_PICKDOC + cIdJnl)
      if ddLastReq() == DDEDIT_SELECT
        cIdDoc := KVK->IdDoc
      endif
    close area
  endif
#endif DEF_KVK
RETURN cIdDoc


#ifdef DEF_SUB

**
** LnPickSub()
**
FUNCTION LnPickSub()
local cIdArt := NIL
if (cIdArt := PickSub(FIELD->IdArt)) != NIL
  if ddRecLock()
    FIELD->Code  := LNCODE_ART
    FIELD->IdArt := cIdArt
    ddUpdate("IdArt")
    unlock record
  endif
endif
RETURN MnuDone()

**
**
**
FUNCTION PickSub(cIdArt)
local ad := oSub()
local cIdArt2 := NIL
* open window (cIdArt + " : Substitute") size 10,60 help PICKSUB
  open area ad, oArt()
    edit data ad key SUB->IdArt1 value cIdArt ;
                create {|| SubCreate(cIdArt) } ;
                mode pick ;
                start top ;
                query "SUBPICK" ;
                title (cIdArt + " : Substitute")
    if ddLastReq() == DDEDIT_SELECT
      cIdArt2 := SUB->IdArt2
    endif
  close area
*close window
RETURN cIdArt2

#endif DEF_SUB

#ifdef DEF_GRA

**
** PickGra()
**
FUNCTION PickGra(cStart)
local ciGra := NIL
local b := oGra()
open area b
  if ! empty(cStart)
    ddSetOrder(1)
    softseek cStart // go top
    ddSetOrder(2)
  else
    ddSetOrder(2)
    go top
  endif
  edit data b mode pick query "GRAPICK" title (MSG029)
  if ddLastReq() == DDEDIT_SELECT
    ciGra := GRA->iGra
  endif
close area
RETURN ciGra

#else

FUNCTION PickGra ; RETURN NIL

#endif DEF_GRA

#ifdef DEF_VEN

**
** VnlPickArt() -- fÅr VNL *und* VNA
**
FUNCTION VnlPickArt()
if FIELD->Code == LNCODE_GEN
  if .t.
    RETURN PickGen( ;
      NIL, ;
      left(FIELD->IdArt,LenIdGen()), ;
      "!'"+GENATTR_H+"'$GEN->Attrib" ;
    )
  else
    RETURN PickGen( ;
      JnlIdCtr(FIELD->IdJnl), ;
      left(FIELD->IdArt,LenIdGen()), ;
      "!'"+GENATTR_H+"'$GEN->Attrib" ;
    )
  endif
endif
#ifdef DEF_ART
  if IsArtCode(FIELD->Code)
    * if MemPickArtMode == PAMODE_P
    *   RETURN ParArtPick(cIdPar,trim(FIELD->IdArt),JnlIdCtr(FIELD->IdJnl))
    * endif
    RETURN PickArt(left(FIELD->IdArt,LenIdArt()))
  endif
#endif
#ifdef DEF_NEWS
  if FIELD->Code == LNCODE_NEWS
    RETURN DbfPick({oNew()},left(FIELD->IdArt,LenIdArt()))
  endif
#endif
RETURN NIL

#endif DEF_VEN

#ifdef DEF_ART

**
** PickArt()
**
FUNCTION PickArt(cStart,cUnused,bReturn,cRefStart)
local cReturn := NIL
local b
local cIdGra := ""
local cIdQry := "ARTPICK"
static scIdGra := ""
* local nStart
default bReturn to {|| ART->IdArt }
default cStart to space(LenIdArt())
#ifdef DEF_GRA
  if MemPickArtMode == PAMODE_G
    if len(trim(cStart)) > LenIdGra()
      open area oArt()
        seek cStart
        cIdGra := ART->iGra
      close area
    else
      cIdGra := left(cStart,LenIdGra())
    endif
    b := oGra()
    open area b
      seek cIdGra
      if eof()
        softseek scIdGra
        edit data b mode pick ;
                    query "GRAPICK" ;
                    title (MSG029)
        if ddLastReq() == DDEDIT_SELECT
          cIdGra := GRA->iGra
          cIdQry := GraIdQry()
          scIdGra := cIdGra
        else
          cIdGra := NIL
        endif
      else
        cIdGra  := left(cStart,LenIdGra())
        cIdQry  := GraIdQry()
        scIdGra := GRA->iGra
      endif
    close area
    if ! empty(cIdGra)
      b := oArt()
      open area b, oGra(), oAcf()
        ddSetOrder(ART_ORD_GRP)
        if ART->iGra != cIdGra
          softseek cIdGra
        endif
        edit data b key ART->iGra value cIdGra    ;
                  mode     pick                  ;
                  create   {|| ArtCreate(cIdGra) }    ;
                  query (cIdQry) ;
                  title (MSG031 + cIdGra) ;
                  filter "!'"+ARTATTR_H+"'$ART->Attrib"
        if ddLastReq() == DDEDIT_SELECT
          cReturn := eval(bReturn) // ART->IdArt
        endif
      close area
      RETURN cReturn
    endif
  endif
#endif DEF_GRA
b := oArt()
open area b, oPar(), oGra(), oAcf()
  if cRefStart == NIL
    ddSetOrder(ART_ORD_ID)
    softseek trim(cStart)
  else
    ddSetOrder(ORD_ART_REF)
    softseek trim(cRefStart)
  endif
  edit data b ;
    mode pick ;
    query "ARTPICK"    ;
    create   {|| ArtCreate() }     ;
    title (MSG030) ;
    filter "!'" + ARTATTR_H + "'$ART->Attrib"
  if ddLastReq() == DDEDIT_SELECT
    cReturn := eval(bReturn) // ART->IdArt
  endif
close area
RETURN cReturn


**
FUNCTION ParArtPick(cIdPar,cStart,cIdCtr)
**
** Auswahl Artikel wenn Lieferant bekannt ist.
** Wenn DEF_ACF (Partnerpreise) verwendet wird, dann stehen die
** Partnerzuweisungen ja in einer separaten Datei, weil es mehrere pro
** Artikel geben kann. Ansonsten wird einfach nur die ART mit
** ARTPAR.QRY geîffnet.
**
local b
local cReturn
local nStart := 0
#ifdef DEF_ACF
  b := oAcf()
  open area b, oArt(), oPar()
    ddSetOrder(ORD_ACF_PAR)
    softseek cIdPar + cStart
    edit data b key ACF->IdPar value cIdPar   ;
              mode     pick                  ;
              create   {|| AcfCreate(NIL,cIdPar) } ; // AcfCreate(cIdCtr,NIL,cIdPar) }  ;
              query "ACFPAR" ;
              title (trim(ParName()) + MsgAcfEdit())
    if ddLastReq() == DDEDIT_SELECT
      cReturn := ACF->IdArt
    endif
  close area
#else
  // Ñhnlich wie ParArtEdit()
  b := oArt()
  open area b, oPar(), oGra()
    seek cStart
    if eof() .or. ART->IdPar != cIdPar
      nStart := 1 // DDSTART_TOP
    endif
    ddSetOrder(ORD_ART_PAR)
    edit data b key ART->IdPar value cIdPar   ;
              mode     pick                  ;
              create {||ArtCreate(NIL,cIdPar)} ;
              start nStart ;
              query "ARTPAR" ;
              title (trim(ParName()) + MsgArtParEdit() )
    if ddLastReq() == DDEDIT_SELECT
      cReturn := ART->IdArt
    endif
  close area
#endif DEF_ACF
RETURN cReturn


#endif DEF_ART

#ifdef DEF_ART_REF

**
**
FUNCTION VnlPickRef(cIdQry)
**
local cReturn := NIL
local b := oArt()
local cStart := trim(ART->Ref)
local cIdArt := FIELD->IdArt
default cIdQry to "ARTPICK"
open area b, oPar(), oGra(), oAcf()
  ddSetOrder(ORD_ART_REF)
  softseek trim(cStart)
  edit data b ;
    mode pick ;
    query (cIdQry)    ;
    create   {|| ArtCreate() }     ;
    title (MSG030) ;
    filter "!'" + ARTATTR_H + "'$ART->Attrib"
  if ddLastReq() == DDEDIT_SELECT
    cIdArt  := ART->IdArt
    cReturn := ART->Ref
  endif
close area
if cIdArt != NIL
  FIELD->Code  := LNCODE_ART
  FIELD->IdArt := cIdArt
endif
RETURN cReturn

#endif DEF_ART_REF


#ifdef DEF_GRA

FUNCTION GraIdQry
RETURN "ARTGRA" if empty(GRA->IdQry)
RETURN "ART" + trim(GRA->IdQry)

#endif DEF_GRA



#ifdef DEF_GEN

**
** PickGen()
**
FUNCTION PickGen(cIdCtr,cStart,bFilter)
local cId := NIL
local b := oGen()
default bFilter to ".t."
open area b
  if cStart != NIL
    softseek cStart
    do while ! eof() .and. ! &bFilter
      skip
    enddo
  endif
  if cIdCtr == NIL
    edit data b mode pick query "GENPICK" title (MSG034)
  else
    ddSetOrder(ORD_GEN_IDCTR)
    edit data b mode   pick ;
                key    GEN->IdCtr ;
                value  cIdCtr ;
                query  "GENPICKC" ;
                title  (MSG034 + " " + trim(CtrName(cIdCtr))) ;
                filter (bFilter)
  endif
  if ddLastReq() == DDEDIT_SELECT
    cId := GEN->IdGen
  endif
close area
RETURN cId

#else

FUNCTION PickGen ; RETURN NIL

#endif DEF_GEN

#ifdef DEF_PRESTO

**
** PickTac()
**
FUNCTION PickTac(cStart)
local cId := NIL
local b := oTac()
* local nStart := 1 // top
open area b
  default cStart to ""
  softseek cStart
  edit data b mode     pick                     ;
              query "TACPICK" ;
              title "Auswahl Tarif"
  if ddLastReq(b) == DDEDIT_SELECT
    cId := TAC->IdTac
  endif
close area
RETURN cId


#endif DEF_PRESTO

#ifdef DEF_PRF

**
** PickPrf()
**
FUNCTION PickPrf(cStart)
local cId := NIL
local b := oPrf()
open area b
  if cStart != NIL
    softseek cStart
  endif
  edit data b mode pick query "PRF" ;
            title "Auswahl Berufsgruppe"
  if ddLastReq(b) == DDEDIT_SELECT
    cId := PRF->IdPrf
  endif
close area
RETURN cId

FUNCTION PickPrfList(cStart)
local a := {}
RETURN NIL if !DbfScan({oPrf()},1,NIL,NIL,".t.",;
  {||aadd(a,{trim(PRF->IdPrf),PRF->Libell,.f.}),.t.})
RETURN PickAttrib(a,"Auswahl Berufsgruppe(n)",cStart," ")

#else

FUNCTION PickPrf ; RETURN NIL

#endif DEF_PRF

**
** TxtType()
**
*FUNCTION TxtType(cType)
*#ifdef LG_FRENCH
*  do case
*  case cType == TXTTYPE_ART    ; RETURN "Description d'article"
*  case cType == TXTTYPE_MASQUE ; RETURN "Masque de document"
*  case cType == TXTTYPE_BLOCK  ; RETURN "Bloc de texte"
*  endcase
*#else
*  do case
*  case cType == TXTTYPE_ART    ; RETURN "Artikelbeschreibung"
*  case cType == TXTTYPE_MASQUE ; RETURN "Dokumentmaske"
*  case cType == TXTTYPE_BLOCK  ; RETURN "Textblock"
*  endcase
*#endif
*RETURN "..."


**
** AchDocument()
**
*FUNCTION AchDocument(cLangue)
*local cLibDoc :=  ""
*local jnl := JnlLocate(ACH->Type)
*if jnl != NIL
*  if cLangue == MemLang1
*    cLibDoc := jnl[JNL_LIBDOC1]
*  elseif cLangue == MemLang2
*    cLibDoc := jnl[JNL_LIBDOC2]
*  elseif cLangue == MemLang3
*    cLibDoc := jnl[JNL_LIBDOC3]
*  else
*    cLibDoc := jnl[JNL_LIBDOC4]
*  endif
*  if empty(cLibDoc)
*    cLibDoc := jnl[JNL_LIBDOC1]
*  endif
*  cLibDoc := strtran(cLibDoc,"{IdDoc}",ACH->iAch)
*endif
*RETURN cLibDoc



FUNCTION RapDocument(cLangue)
if cLangue == "F"     ; RETURN "EXTRAIT DE COMPTE"
elseif cLangue == "D" ; RETURN "KONTO-AUSZUG"
endif
RETURN ""


**
** TrmDocument()
**
FUNCTION TrmDocument(cLangue)
do case
case cLangue == "D" ; RETURN "Arbeitsbericht"
case cLangue == "F" ; RETURN "Rapport d'intervention"
otherwise           ; RETURN "Service report"
endcase
RETURN ""

**
** PickCompte()
**
FUNCTION PickCompte( cIdCtr, cStart)
RETURN PickGen(NIL,cStart) if empty(cIdCtr) // == CPTTYPE_GEN
RETURN PickPar(CtrPrtList(cIdCtr),cStart)


#ifdef DEF_JNL

**
** VenIniAttrib()
**
*FUNCTION VenIniAttrib(jnl)
*local cReturn := ""
*if TIMATTR_C $ MemAttrib // jnl[JNL_ATTRIB]
*  cReturn += VENATTR_C
*endif
*RETURN cReturn

**
** DocInfo() - (alle Dateien mÅssen offen sein)
**
FUNCTION DocInfo(cIdJnl,cIdDoc,cLine,bReturn)
local cAlias := JnlAlias(cIdJnl)
local doc := NIL // array(DOC_ALEN)
#ifdef DEF_VEN
  if cAlias == "VEN"
    open area oVen()
      seek cIdJnl + cIdDoc
      if ! eof()
        doc := array(DOC_ALEN)
        doc[DOC_DATE]    := VEN->Date
        doc[DOC_ECHE]    := VEN->DatEch
        * 20050228 doc[DOC_LIBELL]  := VEN->NB1
        doc[DOC_LIBELL]  := VenDocLibell()
        doc[DOC_IDPAR]   := VEN->IdPar
        doc[DOC_ETAT]    := VEN->Etat
        doc[DOC_IDDEV]   := VEN->IdDev
        * doc[DOC_COURS]   := val(VEN->Cours)
        doc[DOC_MONT]    := val(VEN->Mont) // VEN_MontD
        doc[DOC_DC]      := VEN->DC
        #ifdef DEF_HST
          doc[DOC_MATCH]   := VenMatch() // VEN->Match
        #else
          doc[DOC_MATCH]   := VEN->IdJnl+VEN->IdDoc
        #endif DEF_HST
        doc[DOC_NB]      := ""
        doc[DOC_IDANA]   := ""
        doc[DOC_MEMO]    := VEN->Memo
        if cLine != NIL
          open area oVnl(VEN->Etat)
            seek cIdJnl + cIdDoc + cLine
            if ! empty(FIELD->Desig)
              doc[DOC_NB]  := FIELD->Desig
            endif
          close area
        endif
      endif
    close area
    RETURN doc
  endif
#endif DEF_VEN
#ifdef DEF_FIN
  if cAlias == "FIN"
    open area oFin(), oFnl()
      seek cIdJnl + cIdDoc
      if ! eof()
        doc := array(DOC_ALEN)
        default cLine to space(LEN_POS)
        seek cIdJnl + cIdDoc + cLine in FNL
        if empty(FNL->Date)
          doc[DOC_DATE]    := FIN->Date
          doc[DOC_ECHE]    := FIN->Date
        else
          doc[DOC_DATE]    := FNL->Date
          doc[DOC_ECHE]    := FNL->Date
        endif
        if empty(FNL->IdCtr)
          doc[DOC_IDPAR]  := space(LenIdPar())
        else
          doc[DOC_IDPAR]  := FNL->IdCpt
        endif
        * seit 19980409 :
        doc[DOC_NB]      := FNL->Libell
        doc[DOC_LIBELL]  := FIN->Remarq
        * bis 19980409 :
        * if empty(FNL->Libell)
        *   doc[DOC_LIBELL]  := FIN->Remarq
        * else
        *   doc[DOC_LIBELL]  := FNL->Libell
        * endif
        doc[DOC_ETAT]    := FIN->Etat
        doc[DOC_IDDEV]   := FIN->IdDev // JnlIdDev(FIN->IdJnl)
        * doc[DOC_COURS]   := val(FIN->Cours)
        doc[DOC_MONT]    := val(FNL->Mont)
        doc[DOC_DC]      := FNL->DC
        if empty(FNL->Match)
          if empty(FNL->Date)
            doc[DOC_MATCH]  := FNL->IdJnl+FNL->IdDoc
          else
            doc[DOC_MATCH]  := right(dtos(FNL->Date),6)+FNL->Line
          endif
        else
          doc[DOC_MATCH]   := FNL->Match
        endif
        #ifdef DEF_ANAFIN
          doc[DOC_IDANA]   := trim(FnlIdAna()) // FNL->IdAna)
        #else
          doc[DOC_IDANA]   := ""
        #endif
      endif
    close area
    RETURN doc
  endif
#endif DEF_FIN
#ifdef DEF_IMP
  * if cAlias == "IMP"
    open area oImp(), oIml()
      seek cIdJnl + cIdDoc
      * if ! eof()
        * if bReturn == NIL
          doc := array(DOC_ALEN)
          if cLine != NIL
            seek cIdJnl + cIdDoc + cLine in IML
            doc[DOC_LIBELL] := IML->NB1
          else
            doc[DOC_LIBELL] := IMP->NB1
          endif
          doc[DOC_DATE]   := IMP->Date1
          doc[DOC_ECHE]   := IMP->Date2
          doc[DOC_IDPAR]  := IML->IdPar
          doc[DOC_ETAT]   := IMP->Etat
          doc[DOC_IDDEV]  := DevDefault(IMP->Periode)
          * doc[DOC_COURS]  := "1"
          doc[DOC_MONT]    := val(IML->Mont)
          doc[DOC_DC]      := IML->DC
          doc[DOC_MATCH]   := IML->Match
          doc[DOC_IDANA]   := ""
          doc[DOC_NB]      := ""
        *else
        *  if cLine != NIL
        *    seek cIdJnl + cIdDoc + cLine in IML
        *  endif
        *  doc := &(bReturn)
        * endif
      * endif
    close area
    RETURN doc
  * endif
#endif DEF_IMP
#ifdef DEF_ODS
  if cAlias == "ODS"
    open area oOds(), oOdl()
      seek cIdJnl + cIdDoc
      if ! eof()
        doc := array(DOC_ALEN)
        default cLine to space(LEN_POS)
        seek cIdJnl + cIdDoc + cLine in ODL
        doc[DOC_DATE]    := ODS->Date
        doc[DOC_ECHE]    := ODS->Date
        doc[DOC_IDPAR]   := ODS->IdPar
        if empty(ODL->Remarq)
          doc[DOC_LIBELL]  := ODS->Remarq
        else
          doc[DOC_LIBELL]  := ODL->Remarq
        endif
        doc[DOC_ETAT]    := ODS->Etat
        doc[DOC_IDDEV]   := JnlIdDev(ODS->IdJnl)
        * doc[DOC_COURS]   := 1
        doc[DOC_MONT]    := 0
        doc[DOC_DC]      := NIL
        doc[DOC_MATCH]   := NIL
        doc[DOC_IDANA]   := ""
        doc[DOC_NB]   := ""
      endif
    close area
    RETURN doc
  endif
#endif DEF_ODS
#ifdef DEF_MVA
  if cAlias == JNLALIAS_ODA
    open area oOda()
      seek cIdJnl + cIdDoc
      if ! eof()
        doc := array(DOC_ALEN)
        doc[DOC_DATE]    := ODA->Date
        doc[DOC_ECHE]    := ODA->Date
        doc[DOC_IDPAR]   := ODA->IdPar
        doc[DOC_LIBELL]  := ODA->Remarq
        doc[DOC_NB]      := "" // ODA->Remarq
        doc[DOC_ETAT]    := ODA->Etat
        doc[DOC_IDDEV]   := JnlIdDev(cIdJnl)
        * doc[DOC_COURS]   := 1
        doc[DOC_MONT]    := 0
        doc[DOC_DC]      := NIL
        doc[DOC_MATCH]   := NIL
        doc[DOC_IDANA]   := ""
      endif
    close area
    RETURN doc
  endif
#endif DEF_MVA
* Warning(cIdJnl + " " + cIdDoc + "." + cLine + " : DocInfo() failed !")
RETURN doc

#endif DEF_JNL

**
FUNCTION EtatText(cEtat)
if cEtat == DocStatClosed()
  RETURN MSG018
elseif cEtat == DocStatOpen()
  RETURN MSG019
elseif cEtat == DocStatNew()
  RETURN MSG020
endif
RETURN "          "


#ifdef DEF_IMP

FUNCTION LniMviField(cMac)
local uReturn
* open area oMvi()
  seek LNI->IdJnl + LNI->IdDoc + LNI->Line in MVI
  uReturn := &cMac
* close area
RETURN uReturn

#endif DEF_IMP

**
** AddAttrib()
**
FUNCTION AddAttrib(cStart,cNew,cDelim)
local nLen := len(cStart)
default cDelim to " "
if cNew == NIL
  RETURN NIL
endif
cStart := trim(cStart)
if !empty(cStart)
  cStart += cDelim
endif
RETURN padr(cStart + cNew,nLen)


*#ifdef DEF_SHELL
*
***
*** PickBat()
***
*FUNCTION PickBat()
*local b := oBat()
*local cName := NIL
*local cTitle := NIL
** local nCursor
*open area b
*  * open window (MSG008) size 10,35 help PICKBAT
*  edit data b ;
*    mode     pick                   ;
*    start    top                    ;
*    query "BAT" ;
*    title (MSG008)
*    * query 2 ;
*  * close window
*  if ddLastReq(b) == DDEDIT_SELECT
*    cName := trim(BAT->FileName)
*    cTitle := trim(BAT->Libell)
*  endif
*close area
*if cName != NIL
*  AppShell(cName,cTitle)
*endif
*RETURN .f.
*
*#endif

*FUNCTION JnlTypeDesig(cAlias)
*local i
*for i := 1 to len(saAlias)
*  if left(saAlias[i],3) == cAlias
*    RETURN trim(substr(saAlias[i],5))
*  endif
*next i
*RETURN ""

#ifdef DEF_SUB

FUNCTION PickSubAttrib(cStart)
local a := {}
#ifdef LG_FRENCH
  aadd(a, { "A", "Adapter le stock des substituts", 1 } )
#else
  aadd(a, { "A", "Bestand der Substitute anpassen", 1 } )
#endif
RETURN PickAttrib(a, NIL, cStart )

#endif

#ifdef DEF_ART

*FUNCTION PickArtAttrib(cStart)
*local a := {}
*#ifdef LG_FRENCH
*  #ifdef DEF_IVT
*    aadd(a, { ARTATTR_T, "Article temporaire             ", 1 } )
*    aadd(a, { ARTATTR_M, "Çchantillon                    ", 1 } )
*  #endif DEF_IVT
*  #ifdef DEF_HOLZ
*  aadd(a, { ARTATTR_D, "Calcul du volume par diamätre  ", 1 } )
*  #endif
*  #ifdef DEF_VEN
*    aadd(a, { ARTATTR_S, "Sans suivi de stock            ", 1 } )
*    aadd(a, { ARTATTR_H, "invisible                      ", 1 } )
*    aadd(a, { ARTATTR_B, "Imprimer mÇmo avant dÇsignation", 1 } )
*    aadd(a, { ARTATTR_A, "Imprimer mÇmo apräs dÇsignation", 1 } )
*  #endif DEF_VEN
*    aadd(a, { ARTATTR_R, "protÇgÇ en Çcriture            ", 1 } )
*  #ifdef DEF_SER
*    aadd(a, { ARTATTR_N, "N¯ de sÇrie                    ", 1 } )
*  #endif DEF_SER
*#else
*  #ifdef DEF_IVT
*    aadd(a, { ARTATTR_T, "TemporÑr-Artikel                 ", 1 } )
*    aadd(a, { ARTATTR_M, "Muster                           ", 1 } )
*  #endif DEF_IVT
*  #ifdef DEF_HOLZ
*    aadd(a, { ARTATTR_D, "Volumen nach Durchmesser rechnen ", 1 } )
*  #endif
*  #ifdef DEF_VEN
*    aadd(a, { ARTATTR_S, "ohne Lagerbestand                ", 1 } )
*    aadd(a, { ARTATTR_H, "Unsichtbar (hidden)              ", 1 } )
*    aadd(a, { ARTATTR_B, "Memotext vor Bezeichnung drucken ", 1 } )
*    aadd(a, { ARTATTR_A, "Memotext nach Bezeichnung drucken", 1 } )
*  #endif DEF_VEN
*    aadd(a, { ARTATTR_R, "SchreibgeschÅtzt (read-only)     ", 1 } )
*  #ifdef DEF_SER
*    aadd(a, { ARTATTR_N, "mit Seriennummer                 ", 1 } )
*  #endif DEF_SER
*#endif
*RETURN PickAttrib(a, "Artikel-Attribute", cStart, NIL, "ARTATTR" )

#endif DEF_ART

#ifdef DEF_ART_REF

FUNCTION RefTrunc(x)
local nLen := len(x)
x := strtran(x," ")
x := strtran(x,"-")
x := strtran(x,".")
x := strtran(x,"!")
x := strtran(x,"#")
x := strtran(x,"/")
RETURN padr(upper(x),nLen)

#endif DEF_ART_REF

*FUNCTION PickTelFormat(cStart)
*#ifdef LG_FRENCH
*  RETURN ArrayPick( { ;
*    "  (format libre)" , ;
*    "1 99/999.99.99  " , ;
*    "2 999/99.99.99  " , ;
*    "3 999/999.999   " , ;
*    "4 99/999 99 99  " , ;
*    "5 999/99 99 99  " , ;
*    "6 999/999 999   "   ;
*  } ,"Format TÇlÇphone",cStart,1)
*#else
*  RETURN ArrayPick( { ;
*    "  (Freiformat) " , ;
*    "1 99/999.99.99 " , ;
*    "2 999/99.99.99 " , ;
*    "3 999/999.999  " , ;
*    "4 99/999 99 99  " , ;
*    "5 999/99 99 99  " , ;
*    "6 999/999 999   "   ;
*  } ,"Format Telefonnr.",cStart,1)
*#endif

#ifdef DEF_PRESTO

**
** TrmDlgClose()
**
FUNCTION TrmDlgClose()
* local jnl := JnlLocate(SYSJNL_TRM)
local ags
local nRecOld := recno()
local nRecNew := NIL
* if jnl == NIL
*   Warning("Journal " + SYSJNL_TRM + " muss zuerst definiert werden !")
*   RETURN .f.
* endif
if indexord() == ORD_TRM_USER
  if ddSkip(1) != 1
    ddSkip(-1)
  endif
  nRecNew := recno()
  goto nRecOld
endif
RETURN .f. if (ags := PickAgs(AgsNext(TRM->Etat),MSG052)) == NIL
* #ifdef DEF_ART
*   RETURN .f. if ! ArtExist(TRM->IdArt)
* #endif DEF_ART
RETURN .f. if ! ddRecLock()
if AGSATTR_I $ ags[AGS_ATTRIB]
  TrmPrint(ags[AGS_IDTPL])
endif
* #ifdef DEF_VNA
*   if AGSATTR_A $ ags[AGS_ATTRIB]
*     if DocCreate( jnl,{|cIdDoc| ;
*       TrmVnaCreate(jnl,cIdDoc) ;
*     }) != DDCREATE_DONE
*       Warning("TrmVnaCreate() failed !")
*     endif
*   endif
* #endif
TRM->Etat := ags[AGS_IDAGS]
unlock record
if nRecNew == NIL
  ddRefreshCurrent()
else
  goto nRecNew
  ddRefreshAll()
endif
RETURN MnuDone()

*FUNCTION TrmChgUser()
*local cStart := PickUsr(TRM->User)
*local nRecOld := recno()
*local nRecNew := NIL
*RETURN .f. if cStart == NIL
*if indexord() == ORD_TRM_USER
*  if ddSkip(1) != 1
*    ddSkip(-1)
*  endif
*  nRecNew := recno()
*  goto nRecOld
*endif
*RETURN .f. if ! ddRecLock()
*TRM->User := cStart
*TRM->Etat := ""
*unlock record
*if nRecNew == NIL
*  ddRefreshCurrent()
*else
*  goto nRecNew
*  ddRefreshAll()
*endif
*RETURN MnuDone()

#endif DEF_PRESTO

#ifdef DEF_HOLZ

**
** PickDto()
**
FUNCTION PickDto(cIdJnl,cIdPrj)
local b := oStm()
local cReturn := NIL
open area b
  * open window ("Auswahl EinzelstÅck") size 10,78 help STM
  edit data b create   DDCREATE_FAIL ;
              mode     pick ;
              start    top ;
              query "STM" ;
              title ("Auswahl EinzelstÅck")
  * close window
  if ddLastReq() == DDEDIT_SELECT
    cReturn := STM->IdStm
  endif
close area
RETURN cReturn 

#endif DEF_HOLZ

*FUNCTION TplPickTpl
*local cId := PickTpl(TPLTYPE_INI,TXT->IdOpt,NIL,NIL,"Initialisierung")
*RETURN MnuDone() if cId == NIL
*if ddRecLock()
*  TXT->IdOpt := cId
*  unlock record
*  ddRefreshCurrent()
*endif
*RETURN MnuDone()

**
** PickTimAttrib()
**
FUNCTION PickTimAttrib(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  * aadd(aAttrib, { TIMATTR_N, "Clients/fournisseurs triÇs par numÇro     " , 1 } )
  aadd(aAttrib, { TIMATTR_C, "prix unitaires TVA comprise               " , 1 } )
  aadd(aAttrib, { TIMATTR_P, "pas de padding pour n¯ article            " , 1 } )
  aadd(aAttrib, { TIMATTR_Z, "Centraliser par document                  " , 1 } )
  #ifdef DEF_SUB
  aadd(aAttrib, { TIMATTR_S, "Modifier stock des articles substitut     " , 1 } )
  #endif DEF_SUB
  #ifdef DEF_VEN
    aadd(aAttrib, { TIMATTR_M, "pas de textes mÇmo par ligne de document  " , 1 } )
    aadd(aAttrib, { TIMATTR_T, "Sous-totaux Çgalement pour les quantitÇs  " , 1 } )
  #endif DEF_VEN
  aadd(aAttrib, { TIMATTR_F, "demander fournisseur Ö la crÇation article" , 1 } )
  aadd(aAttrib, { TIMATTR_G, "n¯articles commencent par id. du groupe   " , 1 } )
  aadd(aAttrib, { TIMATTR_A, "activer les propositions                  " , 1 } )
  #ifdef DEF_IVT
    aadd(aAttrib, { TIMATTR_D, "Imprimer DPA au lieu du PAMP inventiares  " , 1 } )
  #endif DEF_IVT
#else
  * aadd(aAttrib, { TIMATTR_N, "Kunden/Lieferanten nach Nummer sortiert" , 1 } )
  aadd(aAttrib, { TIMATTR_P, "padding fÅr Artikelnummer unterlassen    " , 1 } )
  aadd(aAttrib, { TIMATTR_C, "StÅckpreise inkl. Mehrwertsteuer       " , 1 } )
  aadd(aAttrib, { TIMATTR_Z, "Sammelhistorik aktualisieren           " , 1 } )
  #ifdef DEF_SUB
  aadd(aAttrib, { TIMATTR_S, "Bestand Ñndern fÅr Substitut-Artikel   " , 1 } )
  #endif DEF_SUB
  #ifdef DEF_VEN
    aadd(aAttrib, { TIMATTR_M, "keine Memo-Texte pro Dokument-Zeile    " , 1 } )
    aadd(aAttrib, { TIMATTR_T, "Zwischensummen ebenfalls fÅr Menge     " , 1 } )
  #endif DEF_VEN
  aadd(aAttrib, { TIMATTR_F, "Lieferant fragen bei neuen Artikeln    " , 1 } )
  aadd(aAttrib, { TIMATTR_G, "Artikelnummern beginnen mit Gruppen-ID " , 1 } )
  aadd(aAttrib, { TIMATTR_A, "BuchungsvorschlÑge ankreuzen           " , 1 } )
  #ifdef DEF_IVT
  aadd(aAttrib, { TIMATTR_D, "Inventuren : Letzter EK statt Mittel-EK" , 1 } )
  #endif DEF_IVT
#endif
RETURN PickAttrib(aAttrib,MSG007,cStart,"","TIMATTR")

#ifdef DEF_IMP

**
** PickBudAttrib()
**
*FUNCTION PickBudAttrib(cStart)
*local aAttrib := {}
*aadd(aAttrib, { BUDATTR_T, "KreditÅberschreitungen tolerieren         " , 1 } )
*aadd(aAttrib, { BUDATTR_H, "nicht berÅcksichtigen in Rechnung/Haushalt" , 1 } )
*aadd(aAttrib, { BUDATTR_W, "Warnung beim Benutzen                     " , 1 } )
*#ifdef DEF_ANA
*  aadd(aAttrib, { BUDATTR_Y, "Analytisch verteilen                      " , 1 } )
*#endif
*RETURN PickAttrib(aAttrib,MSG007,cStart,"","BUDATTR")

**
** PickBud()
**
FUNCTION PickBud( cIdCtr, cStart, cTitle )
local cId := NIL
local b := oBud()
RETURN NIL if cIdCtr == NIL
default cTitle to "Auswahl Haushalts-Artikel " + cIdCtr
open area b
  if cStart != NIL
    softseek cIdCtr + trim(cStart)
  endif
  edit data b ;
       key BUD->DC ;
       value cIdCtr ;
       create {|| BudCreate(cIdCtr) } ;
       mode pick ;
       query "BUDPICK" title (cTitle)
  if ddLastReq() == DDEDIT_SELECT
    * cId := SayIdBud(BUD->IdBud) warum dat denn
    cId := BUD->IdBud
  endif
close area
RETURN cId

#endif DEF_IMP

#ifdef DEF_ANA

**
** PickAna()
**
FUNCTION PickAna( cStart, cTitle )
local cId := NIL
local b := oAna()
default cTitle to "Auswahl Analysekonto"
open area b
  if cStart != NIL
    softseek trim(cStart)
  endif
  edit data b ;
       mode pick ;
       query "ANAPICK" title (cTitle)
  if ddLastReq() == DDEDIT_SELECT
    cId := ANA->IdAna
  endif
close area
RETURN cId

#endif DEF_ANA

*#ifdef DEF_MOD
*
*FUNCTION PickModAttrib(cStart)
*local aAttrib := {}
*#ifdef LG_FRENCH
*  aadd(aAttrib, { MODATTR_D, "Contenu dÇtaillÇ", 1 } )
*#else
*  aadd(aAttrib, { MODATTR_D, "Detaillierter Inhalt", 1 } )
*#endif
*RETURN PickAttrib(aAttrib,NIL,cStart,"","MODATTR")
*
*#endif DEF_MOD

#ifdef DEF_VNA

FUNCTION PickTrnAttr(cStart)
local aAttrib := {}
aadd(aAttrib, { TRNATTR_I, "D befriedigt C, C befriedigt D         ", 1 } )
aadd(aAttrib, { TRNATTR_X, "VorschlÑge ankreuzen                   ", 1 } )
aadd(aAttrib, { TRNATTR_P, "Vorschlag permanent (bleibt offen)     ", 1 } )
aadd(aAttrib, { TRNATTR_A, "Automatik-Fakturierung                 ", 1 } )
aadd(aAttrib, { TRNATTR_R, "RÅckbefriedigend                       ", 1 } )
aadd(aAttrib, { TRNATTR_U, "StÅckpreise immer neu rechnen          ", 1 } )
aadd(aAttrib, { TRNATTR_D, "Datum ignorieren                       ", 1 } )
aadd(aAttrib, { TRNATTR_M, "Manuell (nicht vorschlagen)            ", 1 } )
aadd(aAttrib, { TRNATTR_1, "maximal 1 VnaMatch pro Dokument        ", 1 } )
* aadd(aAttrib, { TRNATTR_L, "Letztes Dokument (statt Match) notieren", 1 } )
RETURN PickAttrib(aAttrib,NIL,cStart,"","TRNATTR")

#endif DEF_VNA


#ifdef DEF_VEN

FUNCTION VenPickAttrib
* local cAttrib := PickVenAttrib(VEN->Attrib)
local cAttrib := PickFca(VEN->Attrib,MsgIdJnlDoc())
RETURN .f. if cAttrib == NIL
if ddRecLock()
  VEN->Attrib := cAttrib
  ddRefreshCurrent()
  unlock record
endif
RETURN MnuDone()

FUNCTION VnlPickAttrib
* local cAttrib := PickVenAttrib(VEN->Attrib)
local cAttrib := PickFca(VEN->Attrib,MsgIdJnlDoc())
RETURN .f. if cAttrib == NIL
VEN->Attrib := cAttrib
RETURN MnuDone()

#endif DEF_VEN

#ifdef DEF_ART

FUNCTION ArtPickAttrib
local cAttrib := PickDbcAttr("ARTATTR.DBC",ART->Attrib)
RETURN .f. if cAttrib == NIL
if ddRecLock()
  ART->Attrib := cAttrib
  ddPostEdit()
  ddRefreshCurrent()
  unlock record
endif
RETURN MnuDone()

#endif DEF_ART


#ifdef DEF_GRA

FUNCTION GraPickAttrib
local cAttrib := PickDbcAttr("GRAATTR.DBC",GRA->Attrib)
RETURN .f. if cAttrib == NIL
if ddRecLock()
  GRA->Attrib := cAttrib
  ddRefreshCurrent()
  unlock record
endif
RETURN SetMnuDone()


***
*** GraPickAttrib()
***
*FUNCTION GraPickAttrib(cStart)
*local aAttrib := {}
*#ifdef LG_FRENCH
*  aadd(aAttrib, { GRAATTR_H, "ne pas imprimer dÇsignation de groupe  " , 1 } )
*  aadd(aAttrib, { GRAATTR_N, "nouvelle ligne apräs la dÇsignation    " , 1 } )
*  aadd(aAttrib, { GRAATTR_E, "rÇpÇter dÇsignation pour chaque article" , 1 } )
*#else
*  aadd(aAttrib, { GRAATTR_H, "Gruppenbezeichnung nicht drucken         " , 1 } )
*  aadd(aAttrib, { GRAATTR_N, "Neue Zeile nach Gruppenbezeichnung       " , 1 } )
*  aadd(aAttrib, { GRAATTR_E, "Gruppenbez. fÅr jeden Artikel wiederholen" , 1 } )
*#endif
*RETURN PickAttrib(aAttrib,MSG007,cStart,"","GRAATTR")

#endif DEF_GRA


#ifdef DEF_GEN

FUNCTION GenPickAttrib
local cAttrib := PickGenAttrib(GEN->Attrib)
RETURN .f. if cAttrib == NIL
if ddRecLock()
  GEN->Attrib := cAttrib
  ddRefreshCurrent()
  unlock record
endif
RETURN MnuDone()

#endif DEF_GEN



FUNCTION ParPickAttrib
local cAttrib := PickPra(PAR->Attrib)
RETURN .f. if cAttrib == NIL
if ddRecLock()
  PAR->Attrib := cAttrib
  ddRefreshCurrent()
  unlock record
endif
RETURN MnuDone()


#ifdef DEF_ALA

FUNCTION AlaPickAttrib
local cAttrib := PickDbcAttr("ARTATTR.DBC",ART->Attrib)
RETURN .f. if cAttrib == NIL
ART->Attrib := cAttrib
RETURN MnuDone()

#endif DEF_ALA

#ifdef DEF_IMP

FUNCTION BudPickAttrib
// local cAttrib := PickBudAttrib("BUDATTR.DBC",BUD->Attrib)
local cAttrib := PickDbcAttr("BUDATTR.DBC",BUD->Attrib)
RETURN .f. if cAttrib == NIL
if ddRecLock()
  BUD->Attrib := cAttrib
  ddRefreshCurrent()
  unlock record
endif
RETURN MnuDone()

#endif DEF_IMP


#ifdef DEF_BIBLIO


FUNCTION PickDtpAttrib(cStart)
local a := {}
aadd(a,{DTPATTR_A, "Autor fragen            "})
aadd(a,{DTPATTR_R, "Rubrik fragen           "})
aadd(a,{DTPATTR_G, "Verlag fragen           "})
aadd(a,{DTPATTR_B, "Bearbeitungsphase fragen"})
aadd(a,{DTPATTR_D, "Dokumentart angeben     "})
RETURN PickAttrib(a,NIL,cStart)


**
** AutPick()
**
FUNCTION AutPick( cStart )
local cId := NIL
local b := oAut()
open area b
  if empty(cStart)
    ddSetOrder(AUT_ORD_NAME)
    go top
  else
    ddSetOrder(AUT_ORD_ID)
    softseek trim(cStart)
    ddSetOrder(AUT_ORD_NAME)
  endif
  edit data b mode pick title "Auswahl Autor" query "AUTPICK"
  if ddLastReq() == DDEDIT_SELECT
    cId := AUT->IdAut
  endif
close area
RETURN cId


**
** RubPick()
**
FUNCTION RubPick( cStart )
local cId := NIL
local b := oRub()
open area b
  if ! empty(cStart)
    softseek trim(cStart)
  endif
  edit data b mode pick title "Auswahl Rubrik" query "RUBPICK"
  if ddLastReq() == DDEDIT_SELECT
    cId := RUB->IdRub
  endif
close area
RETURN cId



**
** GrpPick()
**
FUNCTION GrpPick( cStart )
local cId := NIL
local b := oGrp()
open area b
  softseek trim(cStart)
  edit data b mode pick title "Auswahl Verlag" query "GRPPICK"
  if ddLastReq() == DDEDIT_SELECT
    cId := GRP->IdGrp
  endif
close area
RETURN cId



**
** ObjPick()
**
FUNCTION ObjPick(cTitle,cStart,cIdDtp)
local cId := NIL
local b := oObj()
open area b, oAut(), oRub()
  ddSetOrder(DOC_ORD_ID)
  edit data b key OBJ->IdDtp value cIdDtp ;
              create {|| ObjCreate(NIL,NIL,cIdDtp) } ;
              mode   pick  ;
              start top ;
              title (cTitle) ;
              query "OBJPICK"
  if ddLastReq() == DDEDIT_SELECT
    cId := OBJ->IdDoc
  endif
close area
RETURN cId

**
** PickNts()
**
FUNCTION PickNts(cTitle)
local cId := NIL
local b := oNts()
open area b
  ddSetOrder(ORD_NTS_NAME)
  edit data b create {|| NtsCreate() } ;
              mode   pick  ;
              start top ;
              title (cTitle) ;
              query "NTSNAME"
  if ddLastReq() == DDEDIT_SELECT
    cId := NTS->IdNts
  endif
close area
RETURN cId


#endif DEF_BIBLIO

#ifdef DEF_SER

**
** PickSer()
**
FUNCTION PickSer(cStart,cIdArt,dDate)
local cId := NIL
local b := oSer()
local cTitle := "Auswahl Seriennummer"
open area b, oArt()
  if ! empty(cStart)
    softseek trim(cStart)
  else
    go top
  endif
  edit data b create {|| SerCreate(cIdArt,dDate) } ;
              mode   pick  ;
              title (cTitle) ;
              query "SERPICK"
  if ddLastReq() == DDEDIT_SELECT
    cId := SER->IdSer
  endif
close area
RETURN cId

#endif DEF_SER

FUNCTION MsgSatis
#ifdef LG_FRENCH
  RETURN "VÇrifier lettrages"
#else
  RETURN "Lettrierung prÅfen"
#endif


