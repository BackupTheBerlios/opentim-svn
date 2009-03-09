.. _topics_vcs:

Virements à Communication Structurée (VCS)
==========================================

Übersicht für Datenbankverwalter
--------------------------------

- Funktion :func:`hst2vcs` wird in der Druckmaske einer Forderung benutzt, um eine strukturierte Mitteilung im Format 123/1234/123456
  einzufügen, die der Kunde bei Zahlung angeben soll.
  
- Eintrag :configcmd:`VcsJournals` in der :xfile:`TIM.INI`, um die
  Journale (und deren Reihenfolge) festzulegen, die VCS-Nummern generieren können. 
  
- Der Dialog :xfile:`IMLVCS.DLG` wird beim
  Erfassen eines Kontoauszugs aufgerufen, um eine "Zahlung mit strukturierter Mitteilung" zu erfassen. Wenn
  der Benutzer dann eine gültige VCS-Nummer angibt (deren Forderungsbuchung existiert), wird eine neue IML-Zeile erstellt, deren Partner, Betrag, Match usw. aus der Forderung kommen.
  Also ein :func:`ddAddSpecial` in der :xfile:`IML.DEF` hinzufügen.
  
- Um in Ansichten (MVI, HST, IML oder FNL) 
  die VCS-Nummer anzuzeigen, kann man eine virtuelle Kolonne hinzuzufügen::

    ╔═════════ create virtual column ════════════╗
    ║ header CVS-Nummer                          ║
    ║ block  padr(hst2vcs(IdJnl,IdDoc,Line),14)  ║
    ╚════════════════════════════════════════════╝
  

Struktur der VCS-Nummer
-----------------------
    
Eine Buchung wird in TIM durch 
:attr:`HST.IdJnl` + :attr:`HST.IdDoc` + :attr:`HST.Line` 
identifiziert (Primärschlüssel).

Eine von von TIM generierte VCS-Nummer ist wie folgt konstruiert:

   ===== ================================================
   Pos.  Bedeutung
   ===== ================================================
   1     Nummer des Journals in :configcmd:`VcsJournals`
   2-7   :attr:`HST.IdDoc` 
   8-10  :attr:`HST.Line`
   11-12 Prüfziffer
   ===== ================================================
   
N.B. Falls :configcmd:`FixY2K` gesetzt ist, müsste und könnte ein "A" 
oder "B" am Anfang von :attr:`HST.IdDoc` 
automatisch durch "0" bzw. "1" ersetzt werden. Aber dieser Fall ist 
noch nicht implementiert. VCS wird zur 
Zeit eigentlich nur unter der Bedingung unterstützt, dass die Dokumente 
in :configcmd:`VcsJournals` reine Nummern (ohne Buchstaben) haben. 


Funktionen
----------

.. function:: hst2vcs(cIdJnl,cIdDoc,CLine)

   Konvertiert den angegebenen Primärschlüssel einer Buchung
   in eine formatierte VCS-Nummer.
   
.. function:: vcs2hst(cVcsText)

   Konvertiert die angegebene VCS-Nummer (mit oder
   ohne formatierenden "/") in den Primärschlüssel der betreffenden 
   Buchung.
   Wenn das fehlschlägt, wird :func:`SetMsg` gesetzt und ein leerer String
   zurückgegeben.
   
.. function:: ImlVcsCreate(cVcsText)

   Erstellt eine neue Zeile in :class:`IML`, deren Inhalt aus der
   durch `cVcsText` identifizierten Buchung übernommen wurde.
   
   Wird aus :xfile:`IMLVCS.DLG` gerufen.
   
.. function:: VcsValidate(x)

   Gibt ``.t.`` zurück, wenn ``x`` eine gültige VCS-Nummer ist.
   Ansonsten wird :func:`SetMsg` gesetzt.
   
.. function:: hst2nb(cIdJnl,cIdDoc,cLine)

   Formatiert den angegeben Primärschlüssel entweder als VCS-Nummer 
   oder als klassische Referenz. ``cLine`` darf leer sein.

Konfigurationsbefehle
---------------------
   
.. configcmd:: VcsJournals

   Eine durch Leerzeichen getrennte Liste aller Journalnamen, die
   VCS-Nummern erzeugen können. 
   Es sind maximal 10 Journale möglich.
   Wohlgemerkt: es geht hier um die Ausgangsrechnungen oder
   Forderungen, nicht um die Bankjournale, die VCS-Zahlungen empfangen
   können.
      
   Die Reihenfolge sollte nach einmal begonnenem VCS-Betrieb nicht mehr
   geändert werden, weil :func:`hst2vcs` und :func:`vcs2hst` die
   Reihenfolge nutzen.

   Beispiel::
   
     VcsJournals FFO1 FFO2

Dateien
-------

.. xfile:: IMLVCS.DLG

   Startet einen Dialog im Stil::

     ╔════════ Zahlung mit VCS erfassen ════════╗
     ║ Strukturierte Mitteilung     /    /      ║
     ╚══════════════════════════════════════════╝
     
   und ruft dann :func:`ImlVcsCreate` auf, um die Buchung zu 
   übernehmen.
   
   **Mögliche Fehlermeldungen:**
   
   ``(Alt-V geht nur auf der letzten Zeile.)``
      Wenn man den Dialog auch anderswo erlauben würde, würde die
      VCS-Buchung vor der aktuellen Zeile eingefügt, was wahrscheinlich
      nicht das ist, was der Benutzer will.
      
   ``Länge VCS-Nummer muss 12+2 sein.``
      Die angegebene VCS-Nummer ist ungültig. 
   
   ``Ungültige Prüfziffer in VCS-Nummer.``
      Die angegebene VCS-Nummer ist ungültig. 
      
   ``Kein VCS-Journal.`` 
      Die erste Position entspricht keinem :configcmd:`VcsJournals`. 
      
   ``Buchung nicht gefunden!``
      Die VCS-Nummer ist zwar an sich korrekt, aber es gibt keine
      entsprechende Buchung in der Datenbank.
   


.. xfile:: IML.DEF

   In die Datei IML.DEF muss ungefähr folgender neuer Eintrag kommen::

    ddAddSpecial(\
      {||DlgExec("IMLVCS")},\
      "Zahlung mit VCS erfassen    [Alt-V]",\
      303,\
      {||IMP->IdJnl$"CCB ,CCA ".and.IMP->Etat!=DocStatClosed()}\
    )
    
.. xfile:: 20090115.TST

   A test suite that tests VCS-related funtions.
   See :srcref:`DLM/TESTS/20090115.TST`

    