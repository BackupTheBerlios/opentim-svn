.. index:: Lettrieren, rekonstruieren

Lettrieren
==========

Wenn ein Kunde mir eine Rechnung bezahlt, oder wenn ich einem Lieferanten eine Rechnung bezahle, dann wird die Buchung der Rechnug, die bisher offen stand, durch die Zahlung *lettriert*.

Diese Zuweisung nennt man auch Lettrierung. In den meisten Fällen lettriert TIM automatisch. Wenn z.B. ein Kunde eine Rechnung über 149,38 EUR offen stehen hat, dann macht TIM automatisch einen entsprechenden Buchungsvorschlag, sobald Sie in einem Finanzdokument dessen Namen ausgewählt haben::

  ╔══════ Buchungsvorschläge Gold Finger, Versicherung ══════╗
  ║   VKR040001 02.11.04                          149.38 EUR ║
  ╚══════════════════════════════════════════════════════════╝
  
Mehr über die Erfassung von Zahlungen im Artikel :doc:`fin`.



Partnerkonten bereinigen
------------------------

"Partnerkonten bereinigen" heißt: Rechnungen und Zahlungen einander zuweisen, so dass nur noch die offenen Buchungen übrig bleiben.



Aber was tun, wenn die Lettrierung aus irgendwelchen Gründen nicht automatisch stattgefunden hat?

Das Folgende gilt übrigens nicht nur für Kunden, sondern für alle Partnerkonten, also je nach Konfiguration auch für Lieferanten, Angestellte, Mitglieder...

Solche Fälle erkennen Sie an folgenden Symptomen:

* Der Partner steht in «Offene Posten Kunden» aber Debit und Kredit enthalten den gleichen Betrag.

* In der Historik des Partners (F9) stehen zwei oder mehrere Buchungen, die sich offensichtlich gegenseitig ausgleichen müssten.

Wenn Sie in «Offene Posten Kunden» sind, können Sie 2x Enter drücken, um die Historik des Kunden einzusehen. Das gleiche Fenster können Sie auch von den normalen Stammdaten aus mit F9 öffnen.

Prinzipiell müssen Sie einfach immer nur dafür sorgen, dass in der Historik alle Buchungen, die zusammen gehören, den gleichen «Match» haben. Das Feld «Match» ist das einzige Feld in der Historik, das Sie manuell bearbeiten können. Es hat keinen Einfluss auf die eigentliche Buchhaltung, weder Bilanz noch Saldenlisten werden dadurch beeinflusst. Eine Serie von Buchungen wird automatisch als «lettriert» markiert, wenn Summe Debit = Summe Kredit ist.

Hier einige Beipiele::

  Datum      Jnl Dok.Nr Bemerkung    Debit      Kredit     * Match
  ──────────┬───┬──────┬────────────┬──────────┬──────────┬─┬─────────
  10.12.2003│VKR│A30513│            │    750.00│          │ │VKRA30513
  11.12.2003│CBF│A30203│            │          │    700.00│ │VKRA30513
  16.12.2003│VKR│A30531│            │    -50.00│          │ │VKRA30531
            │   │      │Saldo D=    │    700.00│    700.00│ │

--> Setzen Sie manuell den Match der dritten Buchung auf "VKRA30513"::

  Datum      Jnl Dok.Nr Bemerkung    Debit      Kredit     * Match
  ──────────┬───┬──────┬────────────┬──────────┬──────────┬─┬─────────
  12.08.2002│CBF│A20138│            │          │   4000.00│ │CBFA20138
  03.09.2002│VKR│A20449│            │   5800.00│          │ │VKRA20449
  04.11.2002│ABA│A20185│            │          │   1800.00│ │VKRA20449
            │   │      │Saldo D=    │   5800.00│   5800.00│ │

--> Setzen Sie manuell den Match der ersten Buchung auf "VKRA20449".

Bereinigte Buchungen werden nicht gelöscht, sondern sind in diesem F9-Fenster per default rausgefiltert. Im Fenster F9 können Sie mit F11 verschiedene Varianten auswählen. Wählen Sie «alle nach Datum», um alle (auch die lettrierten) Buchungen anzeigen zu lassen. In dieser Ansicht erkennen Sie die lettrierten Buchungen dann an dem «*» in der entsprechenden Kolonne. 


Lettrierungen prüfen
--------------------

TIM prüft normalerweise nach dem Registrieren eines Dokuments nach, ob durch die neu entstandene Buchung in der Partnerhistorik irgend etwas beglichen wurde. Diese Option kann man allerdings abschalten für gewisse Journale mit dem Journal-Attribut L (Lettrierungen prüfen).

Beim Lettrieren durchläuft TIM alle Buchungen des Partners und prüft für jeden einzelnen Match nach, ob die Summe im Debit gleich der Summe im Kredit ist. Ist dies der Fall, erhalten alle Buchungen mit diesem Match ein Sternchen ("*") im dafür vorgesehenen Markierungsfeld. 

Lettrierungen rekonstruieren 
----------------------------

Falls Sie im ersten EUR-Jahr bereits Buchungen registriert haben, müssen
Sie zunächst die Lettrierungen nachträglich so rekonstruieren, wie sie am
31.12. des Vorjahres waren.
Dazu gibt es den Befehl "Lettrierungen rekonstruieren".

Der Befehl 
:menuselection:`Datenbank --> Lettrierungen rekonstruieren`
im 
:menuselection:`Verwaltermenü`
setzt die Sternchen in allen Buchungen so, wie sie zu einem
bestimmten Datum waren::

  ╔═════ Lettrierungen rekonstruieren ════╗
  ║ Situation vom 31.12.01 rekonstruieren ║
  ╚═══════════════════════════════════════╝

Diese Funktion wird z.B. benötigt, 

  - wenn man beim :term:`Euro-Umstieg`
    die Abschluss- und Übertragsbuchungen der 
    :term:`Partnerkonten` *nachträglich* machen will 
    (also nachdem schon Rechnungen und Zahlungen im ersten EUR-Jahr
    verbucht wurden).
    
  - wenn man eine :term:`Saldenliste Kunden` oder 
    :term:`Saldenliste Lieferanten` mit einer frühreren Situation
    drucken will.

N.B.: Wenn man :menuselection:`Sammelhistorik rekonstruieren` lässt,
dann wird
die Arbeit dieser Funktion wieder annulliert, und die Sternchen sind
wieder so wie am heutigen Tag.
Das gleiche Resultat kriegt man auch, wenn man das Datum leer lässt.

TIM beendet die Prozedur mit einer Mitteilung im Stil "Die
Lettrierungen in Ihrer Datenbank entsprechen jetzt dem Stand vom
31.12.2001".