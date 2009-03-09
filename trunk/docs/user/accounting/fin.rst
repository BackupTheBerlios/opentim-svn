Kassen- und Bankauszüge buchen
==============================

(Zu überarbeiten)

Dokumente erfassen
------------------

- Wählen Sie im Menü Journale die Journalgruppe Kassenbücher.

- Wählen Sie das Journal, in dem Sie buchen wollen. TIM zeigt die Liste aller bisher erfassten Kassenauszüge. (Solange Sie noch nichts in dem Journal gebucht haben, ist diese Liste natürlich leer.)

- Drücken Sie [Insert] um ein neues Dokument zu erstellen. Das neue Dokument erscheint in Vollbild-Ansicht.

- TIM ermittelt übrigens automatisch die Nummer des neuen Dokuments. (Nur beim ersten Dokument des Journals erscheint das Dialogfenster Journal beginnen.) Die ersten beiden Positionen der Dokumentnummern sollten das laufende Kalenderjahr enthalten.

- Geben Sie gegebenenfalls das Datum und die Buchungsperiode ein.

- Jedes Dokument in einem Kassenjournal hat einen alten Saldo (Beginnsaldo) und einen neuen Saldo (Endsaldo). Beim ersten Dokument des Journals müssen Sie den Beginnsaldo einmalig korrekt eingeben. Alle folgenden Salden berechnet TIM automatisch. Wenn also der von TIM ermittelte Endsaldo nicht mit dem Kassenauszug übereinstimmt, wissen Sie, dass ein Eingabefehler vorliegen muss.

- Die Angaben Alter Saldo und Neuer Saldo haben keinen direkten Einfluss auf die Buchhaltung, sondern dienen zur Kontrolle. Der Beginnsaldo des ersten Dokuments muss prinzipiell mit dem Saldo des entsprechenden Generalkontos überein stimmen. Ist das nicht der Fall, kommt eine Warnung im Integritätstest.

Inhalt
------

Wenn Sie den oberen Teil des Eingabefensters mit [F10] oder [Enter] beendet haben, öffnet TIM automatisch den unteren Teil. Im Dialogfenster Inhalt ist folgendes zu wissen:

- Jede Buchung geht entweder in ein Partnerkonto (P-Kto) oder in ein Generalkonto (G-Kto). Eines dieser beiden Felder ist also immer leer. * Wenn Sie ein Partnerkonto eingegeben haben (Nummer des Kunden oder Lieferanten, oder Auswahl nach Name mit F1]), dann macht TIM automatisch eine Liste von Buchungsvorschlägen, aus denen Sie die gezahlte(n) Rechnung(en) auswählen. Mit [Leertaste] können Sie mehrere Rechnungen auf einmal ankreuzen.

- Die letzte Zeile im Dialogfenster Inhalt enthält gegebenenfalls den Vermerk "(bleibt zu buchen)" oder "(Neuer Saldo)". "bleibt zu buchen" erscheint, wenn (1) Sie den Neuen Saldo im oberen Teil des Bildschirms bereits eingegeben haben, und (2) die Summe der bisherigen Buchungen einen anderen Saldo ergibt. "Neuer Saldo" erscheint, wenn das Feld "Neuer Saldo" noch leer ist. Bemerkung: dieser Text erscheint in der Kolonne "Beschreibung", die ansonsten die Bemerkung gefolgt vom Namen des Kontos anzeigt.

Match
-----

Jede Buchung hat außerdem ein Feld «Match», mit dem Sie einer oder mehreren anderen Buchung zugewiesen werden kann.

Buchungen in Partnerkonten (Kunden oder Lieferanten) sollten generell einen Match haben. Der Match weist normalerweise auf die Rechnung hin, die durch die vorliegende Zahlung beglichen wird.

Match = Journal + Rechnungsnummer

z.B. : VKR960056, EKR960125, ...

Wenn Sie für eine Zahlung nur den Match kennen, so geben Sie diesen im Feld Match ein. Im Feld Match können Sie auch [F1] drücken, um alle offenen Partnerbuchungen anzuzeigen. Wenn Sie ein Match angeben, füllt TIM automatisch die restlichen Angaben aus : Partnerkonto und Betrag. Übung : ein Kunde zahlt zwei Rechnungen gleichzeitig Kunde Meyer hat drei Rechnungen offen stehen : VKR 960018 (1.100,- BEF), VKR 960027 (2.200,- BEF) und VKR 960056 (3.300,- BEF). Sie erhalten eine Zahlung von 5.500,- BEF.

Lösungsweg

* Drücken Sie [F1] im Feld Partnerkonto und wählen Sie den Kunden Meyer aus.

* TIM zeigt das Dialogfenster Buchungsvorschläge Meyer

* Markieren Sie mit der [Leertaste] die beiden letzten Rechnungen. Beachten Sie dabei, daß TIM unten am Bildschirm jeweils die Summe der momentan markierten Buchungen anzeigt.

* Drücken Sie [Enter], um die markierten Buchungen zu übernehmen.

Teilzahlung einer Einkaufsrechnung mit Skonto
---------------------------------------------

Sie haben eine Einkaufsrechnung über 10.000,- BEF erfaßt. Nun erfassen Sie über Kasse eine An-zahlung von 5.000,- BEF und wissen zusätzlich, daß Sie 300,- BEF Skonto nehmen werden. Es blei-ben also noch 4.700,- BEF zu einem späteren Zeitpunkt zu zahlen. Wie müssen Sie vorgehen?

Lösungsweg :

* Geben Sie in einem neu erstellten Kassenauszug das Partnerkonto des Lieferanten ein. TIM zeigt die Liste mit Buchungsvorschlägen.

* Wählen Sie aus den Buchungsvorschlägen die betreffende Rechnung aus. TIM trägt die Referen-zen und den Gesamtbetrag der Rechnung in den Kassenauszug ein.

* Ändern Sie den Gesamtbetrag auf 5.000,- BEF. TIM zeigt das Dialogfenster Zahlungsdifferenz.

* Bestätigen Sie mit Enter] den gebuchten Betrag von 5.000,-. TIM zeigt das Dialogfenster Aus-wahl Zahlungsdifferenz.

* Wählen Sie die Zahlungsdifferenz Skonto aus. TIM erstellt Hilfsbuchung über 5.000,- ins Gene-ralkonto 757000 (Erhaltene Skonti) und schreibt in die erste Buchung wieder den Originalbetrag.

* Ändern Sie den Betrag der Skonto-Buchung manuell von 5.000,- auf 300,-.

* Ändern Sie den Betrag der Rechnung erneut ab, und zwar diesmal auf 5.300,- (Anzahlung + Skonto). TIM zeigt erneut das Dialogfenster Zahlungsdifferenz. Drücken Sie diesmal Escape], um keine weitere Hilfsbuchung zu erstellen.

Zahlung von einem Kunden, der keine Rechnung offen stehen hat
-------------------------------------------------------------

Nachdem Sie den Kunden in das Feld Partnerkonto eingetragen haben, öffnet TIM normalerweise das Dialogfenster Buchungsvorschläge. Ist dies nicht der Fall, bedeutet das, daß der Kunde keine offenstehenden Buchungen mehr hat.

Vorgehensweise

* Drücken Sie F9], um das Dialogfenster Historik zu öffnen. Die Liste ist erwartungsgemäß leer.

* Drücken Sie F11] und wählen Sie den Filter Alle nach Datum oder Alle nach Match aus. TIM zeigt nun alle Buchungen (nicht nur die offenen) an.

* Falls es sich um eine irrtümliche Zahlung oder eine Anzahlung handelt, geben Sie nun einfach den Betrag ein (beachten Sie ggf. das Feld D/C). Lassen Sie das Feld Match leer. TIM wird der Buchung als Match keine Rechnungsnummer, sondern die Nummer des Kassenauszugs zuwei-sen.

Zahlungsdifferenzen
-------------------

Sobald TIM den Match einer Buchung kennt, kann er für Sie ermitteln, wieviel der Kunde noch be-zahlen muss (bzw. wieviel Sie dem Lieferanten noch schulden). Dieser Betrag wird bei der Eingabe der Finanzjournale automatisch vorgeschlagen. Wenn Sie diesen Betrag ändern, fragt TIM nach dem Grund für die Zahlungsdifferenz. Je nachdem, welche Möglichkeit Sie auswählen, erstellt TIM dar-aufhin automatisch die entsprechende Hilfsbuchung.

Wenn Sie "Teilzahlung" auswählen, erstellt TIM keine Hilfsbuchung, sondern der Restbetrag bleibt im Konto des Partners offen stehen.

Die möglichen Zahlungsdifferenzen können konfiguriert werden mit dem Befehl Zahlungsdifferen-zen im Menü Konfigurierung.

In der Standardkonfiguration gibt es folgende Zahlungsdifferenzen : Bezeichnung Zentralisierung D/C Generalkonto Teilzahlung egal egal (leer) Kunden-Skonto nur Verkauf egal 65300 gewährte Skonten) Lieferanten-Skonto nur Einkauf egal 756000 erhaltene Skonten Kursgewinn egal nur C 754000 Kursgewinn Kursverlust egal nur D 654000 Kursverlust Bankunkosten egal nur D 656000 Bankunkosten Bei der Frage nach der Zahlungsdifferenz schlägt TIM immer nur die Möglichkeiten vor, die in Fra-ge kommen. Zahlungsverkehr in Fremdwährung (FW) und Grundwährung (GW)

* FW ist leer, wenn der Partner und das Journal in GW arbeiten.

* Bei einem Journal in GW steht der Betrag FW immer in der Währung des Partners.

* Bei einem Journal in FW steht der Betrag immer in der Währung des Journals.

* Ändert der Benutzer den Betrag GW oder FW einer Buchung, in der ein Partnerkonto mit Match bewegt wird, dann überprüft TIM den Betrag und fragt falls nötig nach dem Grund für die Zah-lungsdifferenz.

* Für ein gleiches Partnerkonto sollten Sie höchstens eine Fremdwährung benutzen. Also wenn Ihre Grundwährung BEF ist und ein Partner in DEM arbeitet, dann sollten Sie in dieses Part-nerkonto keine Zahlungen in NLG erfassen. Ein Partner, der in DEM arbeitet, kann natürlich ohne Probleme eine Zahlung in BEF machen.

* Rechnungen an einen Partner, der in DEM arbeitet, sollten immer in DEM ausgestellt sein.

* Das Feld Währung eines Partners sollten Sie nur ändern, wenn für das Partnerkonto keine offe-nen Buchungen mehr existieren. 