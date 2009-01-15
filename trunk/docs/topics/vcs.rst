.. _topic_vcs:

Virements à Communication Structurée (VCS)
==========================================

Übersicht
---------

- Funktion :func:`hst2vcs`, um beim Ausdruck einer Forderung
  eine strukturierte Mitteilung im Format 123/1234/123456
  einzufügen, die der Kunde bei Zahlung angeben kann.
  
- Funktion :func:`ImlVcsFill`, die beim Erfassen eines
  Kontoauszugs aufgerufen werden kann, um eine CS zu erfassen. Wenn
  der Benutzer dann eine gültige CS angibt, wird Partner, Betrag,
  Match usw. aus der Forderung übernommen.

- Eintrag :configcmd:`VcsJournals` in der :xfile:`TIM.INI`, um die
  Journale (und deren Reihenfolge) festzulegen, die in dieser
  Datenbank VCS-Nummern generieren können. 
  
Struktur der VCS-Nummer
-----------------------
    
Eine Buchung wird durch 
:attr:`HST.IdJnl` + :attr:`HST.IdDoc` + :attr:`HST.Line` 
identifiziert.
Die daraus resultierende von TIM generierte VCS-Nummer ist wie folgt konstruiert:

   ===== ================================================
   Pos.  Bedeutung
   ===== ================================================
   1     Nummer des Journals in :configcmd:`VcsJournals`
   2-7   :attr:`MVI.IdDoc` 
   8-10  :attr:`MVI.Line`
   11-12 Prüfziffer (Modulo 97)
   ===== ================================================
   
N.B. Falls :configcmd:`FixY2K` gesetzt ist, wird ein 
"A" oder "B" am Anfang von :attr:`HST.IdDoc` 
durch "0" bzw. "1" ersetzt.
   

Funktionen
----------

.. function:: hst2vcs()

   returns a formatted communication structurée for this 
   :class:`FNL`, :class:`HST`, :class:`MVI` or :class:`IML` 
   record.
   
.. function:: vcs2csv(cVcsText)

   returns an array { :attr:`HST.IdJnl`, :attr:`IdDoc`, :attr:`Line` }
   corresponding to the cVcsText.

Konfigurationsbefehle
---------------------
   
.. configcmd:: FixY2K

   Wenn FixY2K `.t.` ist, werden in Buchungsperioden und Dokumentnummern 
   die Jahre 2000 bis 2009 durch A0 bis A9 dargestellt, 2010 bis 2019 
   durch B0 bis B9 usw. Das ist nötig, wenn die Datenbank auch Buchungen 
   aus dem vorigen Jahrtausend enthält.

.. configcmd:: VcsJournals

   Eine durch Leerzeichen getrennte Liste aller Journalnamen, die
   VCS-Nummern erzeugen können. 
   Es sind maximal 10 Journale möglich.
   Die Reihenfolge sollte nach einmal begonnenem VCS-Betrieb nicht mehr
   geändert werden, weil hst2vcs() und vcs2hst() die Reihenfolge nutzen.

   Beispiel::
   
     VcsJournals FFO1 FFO2
     
  