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


*#ifdef DEF_CMD
*
*FUNCTION MsgRecap(cLangue)
*RETURN "GESAMTBETRéGE :" if cLangue == "D"
*RETURN "MONTANTS TOTAUX :"
*
*FUNCTION MsgVom(cLangue)
*RETURN " vom " if cLangue == "D"
*RETURN " du "
*
*#endif

* #ifdef DEF_RAPPEL

* FUNCTION MsgRapListe(cLangue)
* RETURN "Offene Rechnungen" if cLangue == "D"
* RETURN "Factures Çchues"

* #endif

FUNCTION MsgTaxOnly(cLangue)
RETURN "Nur Dokumente mit Mwst-Code " if cLangue == "D"
RETURN "Documents utilisant code TVA "

FUNCTION MsgJnlCentral(cLangue)
RETURN "Hauptjournal" if cLangue == "D"
RETURN "Journal centralisateur"

* #ifdef DEF_COMPTA

FUNCTION MsgSolde(cLangue)
RETURN "Saldo" if cLangue == "D"
RETURN "Solde"

FUNCTION MsgPeriode(cLangue)
RETURN "Periode" if cLangue == "D"
RETURN "PÇriode"

FUNCTION MsgSoldeI(cLangue)
RETURN "Beginnsaldo" if cLangue == "D"
RETURN "Opening balance" if cLangue == "E"
RETURN "Solde initial"

FUNCTION MsgSoldeF(cLangue)
RETURN "Endsaldo" if cLangue == "D"
RETURN "Closing balance" if cLangue == "E"
RETURN "Solde final"

FUNCTION MsgCompte(cLangue)
RETURN "Konto" if cLangue == "D"
RETURN "Compte"

FUNCTION MsgComptes(cLangue)
RETURN "Konten" if cLangue == "D"
RETURN "Comptes"

FUNCTION MsgCours(cLangue)
RETURN "(Kurs)" if cLangue == "D"
RETURN "(Cours)"

* #endif DEF_COMPTA

FUNCTION MsgDevise(cLangue)
RETURN "WÑhrung" if cLangue == "D"
RETURN "Devise"

FUNCTION MsgDesig(cLangue)
RETURN "Bezeichnung" if cLangue == "D"
RETURN "DÇsignation"

FUNCTION MsgBilan(cLangue)
if cLangue == "D"
  RETURN "Bilanz"
endif
RETURN "Bilan"

FUNCTION MsgRep1(cLangue)
if cLangue == "D"
  RETURN "zu Åbertragen"
endif
RETURN "Ö reporter"

FUNCTION MsgRep2(cLangue)
if cLangue == "D"
  RETURN "öbertrag vorige Seite"
endif
RETURN "report page prÇcÇdente"

* FUNCTION MsgHisto(cLangue)
* RETURN "Historik " if cLangue == "D"
* RETURN "Historique "

FUNCTION MsgHistPar(cLangue)
RETURN "Historik Partnerkonten" if cLangue == "D"
RETURN "Historique comptes particuliers"

FUNCTION MsgTvaListe(cLangue)
RETURN "Kundenumsatzliste MWSt" if cLangue == "D"
RETURN "Liste des clients assujettis"

FUNCTION MsgTva02(cLangue)
RETURN "Name und Anschrift des Kunden" if cLangue == "D"
RETURN "Nom et adresse du client"

FUNCTION MsgTva03(cLangue)
RETURN "MWSt-Nr." if cLangue == "D"
RETURN "N¯TVA"

FUNCTION MsgUmsatz(cLangue)
RETURN "Umsatz" if cLangue == "D"
RETURN "Montant"

FUNCTION MsgJournaux(cLangue)
RETURN "Journale" if cLangue == "D"
RETURN "Journals" if cLangue == "E"
RETURN "Journaux"

#ifdef DEF_VEN

FUNCTION MsgVenListe(cLangue)
RETURN "RechnungsbÅcher" if cLangue == "D"
RETURN "Facturiers"

#endif DEF_VEN

#ifdef DEF_FIN

FUNCTION MsgFinListe()
#ifdef LG_GERMAN
RETURN "KassenbÅcher"
#else
RETURN "Journaux de caisse"
#endif

#endif DEF_FIN

FUNCTION MsgCptType(cCptType,cLangue)
if cLangue == "D"
  RETURN "Generalkonten" if empty(cCptType) //  == CPTTYPE_GEN
  RETURN trim(CtrName(cCptType)) + "-Konten"
elseif cLangue == "F"
  RETURN "Comptes gÇnÇraux" if empty(cCptType) //  == CPTTYPE_GEN
  RETURN "Comptes " + trim(CtrName(cCptType))
endif
RETURN ""

FUNCTION MsgCentral(cLangue)
RETURN "ZENTRALISIERUNG " if cLangue == "D"
RETURN "CENTRALISATION "

FUNCTION MsgTotal(cLangue)
default cLangue to MemLang1 // UsrLang()
RETURN "Summe" if cLangue == "D"
RETURN "Total" if cLangue == "E"
RETURN "Total"

FUNCTION MSG058(cLangue)
default cLangue to MemLang1 // UsrLang()
RETURN "Alle Perioden" if cLangue == "D"
RETURN "All Periods" if cLangue == "E"
RETURN "Toutes les pÇriodes"

FUNCTION MSG059(cLangue)
default cLangue to MemLang1 // UsrLang()
RETURN "Period " if cLangue == "E"
RETURN "Periode " if cLangue == "D"
RETURN "PÇriode "

FUNCTION MSG060(cLangue)
default cLangue to MemLang1 // UsrLang()
RETURN " (nicht abgeschlossen)" if cLangue == "D"
RETURN " (not closed)" if cLangue == "E"
RETURN " (ouverte)"

FUNCTION MSG062(cLangue)
default cLangue to MemLang1 // UsrLang()
if cLangue == "D"
  RETURN "Periode vom"
endif
RETURN "PÇriode du"

FUNCTION MSG063(cLangue)
default cLangue to MemLang1 // UsrLang()
if cLangue == "D"
  RETURN " bis zum"
endif
RETURN " au"

FUNCTION MsgGratis(cLangue)
do case
case cLangue == "D" ; RETURN "GRATIS"
case cLangue == "N" ; RETURN "GRATIS"
case cLangue == "E" ; RETURN "FREE"
otherwise           ; RETURN "GRATUIT"
endcase
RETURN NIL

FUNCTION MsgToPay(cLangue)
do case
case cLangue == "D" ; RETURN "ZU ZAHLEN :"
case cLangue == "E" ; RETURN "TO PAY :"
otherwise           ; RETURN "A PAYER :"
endcase
RETURN NIL


FUNCTION MsgTotPoids(cLangue)
do case
case cLangue == "D" ; RETURN "Gesamtgewicht :"
case cLangue == "E" ; RETURN "Total weight :"
case cLangue == "N" ; RETURN "Totaal gewicht :"
otherwise           ; RETURN "Poids total :"
endcase
RETURN NIL


FUNCTION MsgDouane(cLangue)
do case
case cLangue == "D" ; RETURN "Zoll-Nummer :"
otherwise           ; RETURN "Code douane :"
endcase
RETURN NIL


FUNCTION MsgTvaI(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "MWSt.Intr."
case cLangue == "E" ; RETURN "VAT intra"
case cLangue == "N" ; RETURN "BTW intra"
otherwise           ; RETURN "TVA intra"
endcase
RETURN NIL

FUNCTION MsgTva(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "MWSt."
case cLangue == "E" ; RETURN "VAT"
case cLangue == "N" ; RETURN "BTW"
otherwise           ; RETURN "T.V.A."
endcase
RETURN NIL

FUNCTION MsgBase(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "Wert"
case cLangue == "N" ; RETURN "Basis"
otherwise           ; RETURN "Base"
endcase
RETURN NIL


FUNCTION MsgDebit(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "Debit"
case cLangue == "N" ; RETURN "Debet"
otherwise           ; RETURN "DÇbit"
endcase
RETURN NIL

FUNCTION MsgCredit(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "Kredit"
case cLangue == "N" ; RETURN "Kredit"
otherwise           ; RETURN "CrÇdit"
endcase
RETURN NIL



FUNCTION MsgTauxT(cLangue)
do case
case cLangue == "D" ; RETURN "%-Satz"
case cLangue == "N" ; RETURN "%"
otherwise           ; RETURN "Taux"
endcase
RETURN NIL

FUNCTION MsgRemise(cLangue) // MSG013(cLangue)
RETURN "% Erm." if cLangue == "D"
RETURN "% Red." if cLangue == "N"
RETURN "% Rem."

FUNCTION MsgMenge(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "Menge"
case cLangue == "N" ; RETURN "Aant."
otherwise           ; RETURN "QtÇ."
endcase
RETURN NIL

FUNCTION MsgDescript(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "Beschreibung"
case cLangue == "N" ; RETURN "Omschrijving"
otherwise           ; RETURN "Description"
endcase
RETURN NIL

FUNCTION MsgPU(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "StÅckpreis"
case cLangue == "N" ; RETURN "Eenh.Prijs"
otherwise           ; RETURN "Prix unit."
endcase
RETURN NIL

FUNCTION MsgUnit(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "LE"
case cLangue == "N" ; RETURN "LE"
otherwise           ; RETURN "UL"
endcase
RETURN NIL

FUNCTION MsgNetto(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "ohne MWSt"
case cLangue == "N" ; RETURN "Netto"
otherwise           ; RETURN "hors TVA"
endcase
RETURN NIL

FUNCTION MsgTvaTaux(cLangue)
do case
case cLangue == "D" ; RETURN "%MWSt"
case cLangue == "N" ; RETURN " %BTW"
otherwise           ; RETURN " %TVA"
endcase
RETURN NIL

FUNCTION MsgBrutto(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "MWSt inkl."
case cLangue == "N" ; RETURN "BTW inbeg."
otherwise           ; RETURN "TVAC"
endcase
RETURN NIL

FUNCTION MsgIntra(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "Gewicht N/B"
case cLangue == "N" ; RETURN "Kg Netto/Brutto"
otherwise           ; RETURN "Poids net/brut"
endcase
RETURN NIL

FUNCTION MsgMontant(cLangue)
RETURN "Betrag" if cLangue == "D"
RETURN "Bedrag" if cLangue == "N"
RETURN "Amount" if cLangue == "E"
RETURN "Montant"

FUNCTION MsgMontDev(cLangue)
RETURN "Betrag FW" if cLangue == "D"
RETURN "Mont.Dev."

FUNCTION MsgDate(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "Datum"
otherwise           ; RETURN "Date"
endcase
RETURN NIL

FUNCTION MsgIdDoc(cLangue)
default cLangue to MemLang1 // UsrLang()
RETURN "N¯Doc." if cLangue == "F"
RETURN "Dok.Nr"

FUNCTION MsgIdJnlDoc
RETURN trim(FIELD->IdJnl) + " " + FIELD->IdDoc

FUNCTION MsgIdCli(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "Ku-Nr"
case cLangue == "N" ; RETURN "Kl-Nr"
otherwise           ; RETURN "N¯Cli"
endcase
RETURN NIL

FUNCTION MsgName(cLangue)
default cLangue to MemLang1 // UsrLang()
do case
case cLangue == "D" ; RETURN "Name"
case cLangue == "E" ; RETURN "Name"
case cLangue == "N" ; RETURN "Naam"
otherwise           ; RETURN "Nom"
endcase
RETURN NIL

FUNCTION MSG017(cLangue)
do case
case cLangue == "D" ; RETURN ", d.h. "
otherwise           ; RETURN ", soit "
endcase
RETURN NIL

FUNCTION MSG018(cLangue)
do case
case cLangue == "D" ; RETURN "Zahlung "
otherwise           ; RETURN "Paiement "
endcase
RETURN NIL

* FUNCTION MSG019(cLangue)
* do case
* case cLangue == "D" ; RETURN "Zahlung bei Lieferung"
* otherwise           ; RETURN "paiement lors de la livraison"
* endcase
* RETURN NIL

FUNCTION MSG020(cLangue)
do case
case cLangue == "D" ; RETURN "bis zum "
otherwise           ; RETURN "jusqu'au "
endcase
RETURN NIL

FUNCTION MSG021(cLangue)
do case
case cLangue == "D" ; RETURN "innerhalb von "
otherwise           ; RETURN "dans les "
endcase
RETURN NIL

FUNCTION MSG022(cLangue)
do case
case cLangue == "D" ; RETURN "Barzahlung"
otherwise           ; RETURN "paiement au comptant"
endcase
RETURN NIL

* FUNCTION MSG023(cLangue)
FUNCTION MsgTagen(cLangue)
do case
case cLangue == "D" ; RETURN " Tagen"
otherwise           ; RETURN " jours"
endcase
RETURN NIL

FUNCTION MSG024(cLangue)
do case
case cLangue == "D" ; RETURN "Skonto "
otherwise           ; RETURN "escompte de "
endcase
RETURN NIL

FUNCTION MSG025(cLangue)
RETURN "Gewicht netto " if cLangue == "D"
RETURN "Poids net "

FUNCTION MSG026(cLangue)
do case
case cLangue == "D" ; RETURN "Gewicht brutto "
otherwise           ; RETURN "Poids brut "
endcase
RETURN NIL

* FUNCTION MsgNotFound()
* #ifdef LG_GERMAN
*   RETURN " : nicht gefunden !"
* #else
*   RETURN " : pas trouvÇ !"
* #endif

FUNCTION MsgIdArt(cLangue)
RETURN "Art.Nr." if cLangue == "D"
RETURN "N¯ Art."

*#ifdef DEF_STOCK
*
*FUNCTION MsgDpa(cLangue)
*RETURN "Letzter EK" if cLangue == "D"
*RETURN "DPA"
*
*FUNCTION MsgPamp(cLangue)
*RETURN "Mittel-EK" if cLangue == "D"
*RETURN "PA moyen"
*
*#endif DEF_STOCK

#ifdef DEF_JNL

FUNCTION MsgPrevDoc
#ifdef LG_GERMAN
  RETURN "Das vorige Dokument (" + MsgIdJnlDoc() + ")"
#endif
#ifdef LG_FRENCH
  RETURN "Le document prÇcÇdent (" + MsgIdJnlDoc() + ")"
#endif
#ifdef LG_EN
  RETURN "The previous document (" + MsgIdJnlDoc() + ")"
#endif

FUNCTION MsgNotClosed
#ifdef LG_GERMAN
  RETURN " ist nicht registriert."
#endif
#ifdef LG_FRENCH
  RETURN " n'est pas clìturÇ."
#endif
#ifdef LG_EN
  RETURN " is not closed."
#endif

FUNCTION MsgDocCreate
#ifdef LG_GERMAN
  RETURN "Neues Dokument erstellen (J/N) ?"
#endif
#ifdef LG_FRENCH
  RETURN "CrÇer un nouveau document (O/N) ?"
#endif
#ifdef LG_EN
  RETURN "Really create a new document (Y/N) ?"
#endif


FUNCTION MsgCloseFail
#ifdef LG_GERMAN
  RETURN " : Registrieren verweigert"
#endif
#ifdef LG_FRENCH
  RETURN " : clìture refusÇe"
#endif
#ifdef LG_EN
  RETURN " : registration failed"
#endif

FUNCTION MsgCloseOkay
#ifdef LG_GERMAN
  RETURN " wurde registriert."
#endif
#ifdef LG_FRENCH
  RETURN " a ÇtÇ clìturÇ."
#endif
#ifdef LG_EN
  RETURN " : has been closed"
#endif

FUNCTION MsgUndoFail
#ifdef LG_GERMAN
  RETURN " : Entregistrierung verweigert"
#endif
#ifdef LG_FRENCH
  RETURN " : rÇouverture refusÇe"
#endif
#ifdef LG_EN
  RETURN " : reopening failed"
#endif

FUNCTION MsgUndoDone
#ifdef LG_GERMAN
  RETURN " wurde entregistriert"
#endif
#ifdef LG_FRENCH
  RETURN " a ÇtÇ dÇclìturÇ"
#endif
#ifdef LG_EN
  RETURN " : has been repoened"
#endif

FUNCTION MsgPerNotOpen
RETURN " : diese Periode ist nicht offen !"

FUNCTION MsgDocDelete()
#ifdef LG_GERMAN
RETURN " : Dokument lîschen (J/N) ?"
#endif
#ifdef LG_FRENCH
RETURN " : Supprimer ce document (O/N) ?"
#endif
#ifdef LG_EN
RETURN " : Delete this document (Y/N) ?"
#endif

#endif DEF_JNL

FUNCTION MsgCtrExist()
#ifdef LG_GERMAN
RETURN " : ungÅltige Zentralisierungsart !"
#endif
#ifdef LG_FRENCH
RETURN " : code centralisation invalide !"
#endif
#ifdef LG_EN
RETURN " : invalid centralization code !"
#endif


FUNCTION MsgMnuSer
RETURN "~StÅckliste                  [F8]"


FUNCTION MsgMnuRename
#ifdef LG_FRENCH
  RETURN "Re~nommer              [Alt-F2]"
#endif
#ifdef LG_GERMAN
  RETURN "Umbe~nennen            [Alt-F2]"
#endif
#ifdef LG_EN
  RETURN "Re~name (new id)       [Alt-F2]"
#endif


* FUNCTION MnuRename
* #ifdef LG_FRENCH
*   RETURN "~Renommer              [Alt-F2]"
* #else
*   RETURN "~Umbenennen            [Alt-F2]"
* #endif

FUNCTION MnuMemoEdit
#ifdef LG_FRENCH
  RETURN "~Editeur de texte         [F12]"
#else
  RETURN "Text-~Editor              [F12]"
#endif

FUNCTION MnuHstEdit() // MSG002
#ifdef LG_FRENCH
  RETURN "~Historique compte         [F9]"
#endif
#ifdef LG_GERMAN
  RETURN "~Historik Konto            [F9]"
#endif
#ifdef LG_EN
  RETURN "~History by account        [F9]"
#endif

FUNCTION MnuArtPage() // MSG020
#ifdef LG_FRENCH
  RETURN "SignalÇtique ~Article   [Sh-F4]"
#else
  RETURN "Stammdaten ~Artikel  [Shift-F4]"
#endif





FUNCTION MnuParPage()
#ifdef LG_FRENCH
  RETURN "SignalÇt. Partenaire [Shift-F5]"
#else
  RETURN "Stammdaten ~Partner  [Shift-F5]"
#endif

FUNCTION MnuAcfEdit()
#ifdef LG_FRENCH
  RETURN "~Prix partenaires       [Sh-F2]"
#else
  RETURN "~Partnerpreise          [Sh-F2]"
#endif

FUNCTION MnuInhalt()
#ifdef LG_FRENCH
  RETURN "C~ontenu                [Enter]"
#else
  RETURN "~Inhalt                 [Enter]"
#endif

FUNCTION MnuClose()
#ifdef LG_FRENCH
  RETURN "Clìtu~rer             [Ctrl-F2]"
#else
  RETURN "~Registrieren         [Ctrl-F2]"
#endif

FUNCTION MsgMnuDocPage()
#ifdef LG_FRENCH
  RETURN "~Document               [Enter]"
#else
  RETURN "~Dokument               [Enter]"
#endif

FUNCTION MsgMnuAttrib
#ifdef LG_FRENCH
  RETURN "~Attributs             [Alt-F7]"
#else
  RETURN "~Attribute setzen      [Alt-F7]"
#endif



#ifdef DEF_HST

FUNCTION MnuHstMatch()
#ifdef LG_FRENCH
  RETURN "~Historique /match     [Alt-F9]"
#else
  RETURN "Historik /~Match       [Alt-F9]"
#endif

FUNCTION MnuDocHstEdit()
#ifdef LG_FRENCH
  RETURN "~Imputations document [Ctrl-F9]"
#else
  RETURN "~Buchungen /Dokument  [Ctrl-F9]"
#endif


#endif DEF_HST

#ifdef DEF_PRESTO

FUNCTION MnuTrmEdit()
  RETURN "A~genda                    [F8]"

#endif DEF_PRESTO


FUNCTION MnuDocCopy()
#ifdef LG_FRENCH
RETURN "Recopier ~document exist. [F5]"
#else
RETURN "Dokument ~kopieren         [F5]"
#endif



FUNCTION MsgCopy
#ifdef LG_FRENCH
  RETURN " recopier l'enregistrement courant"
#else
  RETURN " aktuellen Record kopieren"
#endif

FUNCTION MsgIdExist()
#ifdef LG_FRENCH
RETURN " : cette identification existe dÇjÖ !"
#endif
#ifdef LG_GERMAN
RETURN " : diese Identifizierung existiert bereits !"
#endif
#ifdef LG_EN
  RETURN " : identification exists already !"
#endif

#ifdef LG_FRENCH
  FUNCTION MsgIsClosed ; RETURN " : ce document est clìturÇ."
#endif
#ifdef LG_GERMAN
  FUNCTION MsgIsClosed ; RETURN " : Dokument ist registriert."
#endif
#ifdef LG_EN
  FUNCTION MsgIsClosed ; RETURN " : document is closed."
#endif

FUNCTION MsgDontUse
#ifdef LG_GERMAN
RETURN " : Generalkonto nicht manuell benutzen !"
#endif
#ifdef LG_FRENCH
RETURN " : compte interdit pour utilisation manuelle !"
#endif
#ifdef LG_EN
RETURN " : don't use this account manually !"
#endif

FUNCTION WrnNotHidden
RETURN " : Attribut H nicht gesetzt !"

#ifdef DEF_TAX

FUNCTION MsgRegExist()
#ifdef LG_GERMAN
RETURN " : ungÅltiges MWSt-Regime !"
#endif
#ifdef LG_FRENCH
RETURN " : rÇgime TVA invalide !"
#endif
#ifdef LG_EN
RETURN " : invalid VAT regime !"
#endif

#endif DEF_TAX


FUNCTION MsgPickTpl()
#ifdef LG_GERMAN
RETURN "WÑhlen Sie eine Maske zum Drucken von "
#endif
#ifdef LG_FRENCH
RETURN "Choisissez un masque pour imprimer "
#endif
#ifdef LG_EN
RETURN "Select a template for printing "
#endif


