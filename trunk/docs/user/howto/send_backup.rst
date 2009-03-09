Datenbank per E-Mail verschicken
================================

Die Anweisungen in diesem Artikel gehen davon aus, dass Ihre Datenbank "meier" heißt und Ihr TIM im Ordner `C:\TIM` installiert ist. Beim Abtippen der Beispiele müssen Sie diese Angaben natürlich jeweils ersetzen.


dbback oder mkdist?
-------------------

Es gibt die alte und die neue Methode. Die alte Methode verwendet den Befehl ``dbback.bat``, die neue den Befehl ``mkdist.bat``.

dbback benötigt das Archivierungsprogramm :file:`arj.exe`, das keine freie Software ist und ein proprietäres Datenformat benutzt. mkdist dagegen verwendet als Archivierungsprogramm :file:`zip.exe`, eine freie Software.
  
dbback kann ein Backup zu Floppy-Disks machen und die Archivdatei falls nötig auf mehrere Disketten verteilen. mkdist kann das nicht.

mkdist macht immer nur eine Datei der Datenbank, die mit einem Passwort verschlüsselt ist. 
Deshalb eignet sich mkdist besser für den Versand per E-Mail.

Archivdatei erstellen mit mkdist
--------------------------------

*Anweisungen:*

  #. Öffnen Sie ein DOS-Fenster und geben Sie dort folgende Befehle ein::

      c:
      cd \tim
      mkdist meier
      
     Die erste Rückfrage kann lauten::
      
      C:\TIM\dist\*.*, Are you sure (Y/N)?
      
     Antworten Sie mit Y (bzw. J oder O falls Ihr Windows Deutsch oder Französisch spricht).
    
  #. Eventuell (ältere Versionen tun es nicht) fragt er Sie nun nach einem Passwort,
     mit dem die zu Archivdatei verschlüsselt werden soll::
  
      Enter password:
      
     Also Sie selber müssen sich dieses Passwort ausdenken und es mir mitteilen. Theoretisch sollten Sie das
     nicht per Mail, sondern telefonisch oder per Skype tun. Falls Sie aber nicht allzu besorgt sind, dass
     jemand Sie ausspionieren will (und es irgendwie schafft, unseren E-Mail-Dialog abzuhören), dann schlage ich
     vor, dass Sie einfach "1234" als Passwort nehmen.
    
     Achtung, wenn Sie das von Ihnen gewählte Passwort eintippen, 
     zeigt er Ihnen nicht wie gewohnt beim Tippen statt der Buchstaben kleine Sternchen an, sondern es sieht aus
     als sei er blockiert. Aber tippen Sie Ihr Passwort ohne Tippfehler ein und beenden Sie mit :kbd:`ENTER`.
     Dann müsste kommen::
      
      Verify password:
      
     Hier sollen Sie also das gleiche Passwort nochmal eintippen, genau so blind wie beim ersten Mal. 
     Das ist um sicherzustellen dass Sie sich nicht vertippt haben.
    
  #. Das Programm beginnt zu arbeiten und endet wie folgt::
  
        adding: ARJ.EXE (deflated 37%)
        adding: Q.EXE (deflated 32%)
        adding: INSTALL.BAT (deflated 44%)
        adding: TIM.ICO (deflated 79%)
        adding: README.TXT (deflated 53%)
      C:unzip.exe
      1 File(s) copied
  
*Mögliche Probleme:*
  
  #. ::
  
      'C:\TIM\zip' is not recognized as an internal or external command, operable program or batch file.
      FEHLER : Datei konnte nicht komprimiert werden
      
     Das bedeutet, dass das Programm zip noch gar nicht oder nicht korrekt installiert 
     ist auf Ihrem Rechner. Kontaktieren Sie mich für weitere Anweisungen.
    

Archivdatei erstellen mit dbback
--------------------------------

#. Machen Sie zunächst ein normales Backup auf Diskette. Falls TIM
   nicht automatisch danach fragt und Sie kein eigenes Icon dafür
   haben, dann geben Sie in einem DOS-Fenster folgende Befehle ein::

      c:
      cd \tim
      dbback meier
      
#.  `dbback` beginnt wie folgt::

      ┌──────────────────────────────────────────────────
      │ SICHERHEITSKOPIE meier nach A:
      └──────────────────────────────────────────────────
      Vorgang starten [J,N]?
      
    Antworten Sie hier "J". Dann beginnt das Programm zu arbeiten und 
    endet irgendwann mit der nächsten Frage::
      
      (...)
      Adding    CDC.DBF                      47.6%
      Adding    ARTMOD.MSK                   50.8%
      Adding    VENEKR.MSK                   53.5%
      Adding    REBUILD.IND                  93.3%
      Adding    HST.DBF                      16.1%
         231 file(s) with      1 longnames
      Creating archive  : C:\TIM\backup\meier.A01
      Adding    HST.DBF                    starting at position 2061382   16.7%
           1 file(s)
      Kopie .\backup\meier.ARJ nach Diskette
      Diskette bereit [J,N]?      
      
    Hier können Sie N antworten (evtl. mehrmals)::
  
      Kopie .\backup\meier.ARJ nach Diskette
      Diskette bereit [J,N]?N
      Kopie .\backup\meier.A01 nach Diskette
      Diskette bereit [J,N]?N
      ┌──────────────────────────────────────────────────────
      │ Sicherheitskopie erfolgreich beendet
      └──────────────────────────────────────────────────────
      Press any key to continue . . .
    
    Jetzt haben Sie zwar kein Backup auf Diskette, aber die Archivdateien wurden erstellt, 
    das genügt zum Verschicken per E-Mail. 


E-Mail abschicken
-----------------

Egal ob Sie mit dbback oder mit mkdist gearbeitet haben, starten Sie nun Ihr E-Mail-Programm 
und schreiben Sie eine E-Mail an mich: 

   - Im Betreff und Text der Nachricht schreiben Sie z.B. : "Backup TIM".
   
   - Im Text können Sie gegebenenfalls Ihr Problem nochmal erklären.
   
   - Fügen Sie Ihrer Mail als Anlage die soeben erstellte(n) Archivdatei(en) bei. 
     Welche das genau sind, lesen Sie bitte im folgenden Abschnitt. 
     
     
Welche Dateien muss ich verschicken?
------------------------------------

- Falls Sie mit `mkdist` arbeiten, stehen die Archivdateien im Ordner ``C:\TIM\DIST``. 
  Normalerweise brauche ich nur Ihre Datenbank. Die steht in der Datei :file:`MEIER.ZIP`.
  
- Falls Sie mit `dbback` arbeiten, stehen die Archivdateien im Ordner ``C:\TIM\BACKUP``
  und ich brauche davon normalerweise nur die Datei MEIER.ARJ. Achtung, wenn Ihr Backup mehr als eine Diskette braucht, steht der Inhalt der zweiten Diskette in einer Datei MEIER.A01, der Inhalt der dritten Diskette in MEIER.A02, usw..., diese Dateien brauche ich dann unbedingt ebenfalls. 
  
  Das "Programm" steht in einer Datei :file:`TIM4.ARJ` (oder :file:`_TIM4.ARJ`, :file:`TIM220D.ARJ` oder :file:`TIM300.ARJ` je nach Version).
  Die "Standard-Module" (gibt es erst seit Januar 2002) stehen in einer Datei :file:`DLM.ARJ`.
  Sofern ich das nicht extra angefragt habe, brauche ich diese Dateien nicht.
  
  Falls Sie mir mehrere Dateien zuschicken müssen, sollten Sie jede Datei in einer eigenen Mail verschicken. Sie brauchen aber nicht für jede Mail einzeln online zu gehen, sondern bereiten Sie alle Mails vor, und dann erst klicken Sie auf «Senden und empfangen», um online zu gehen.
  
