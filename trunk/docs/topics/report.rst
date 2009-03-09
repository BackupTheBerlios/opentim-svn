Der Reportgenerator
===================


Report properties
-----------------

.. cmacro:: RPT_AREA     
.. cmacro:: RPT_ORDER    
.. cmacro:: RPT_START    
.. cmacro:: RPT_WHILE    
.. cmacro:: RPT_FILTER   
.. cmacro:: RPT_GROUPS   
.. cmacro:: RPT_COLUMNS  
.. cmacro:: RPT_TOTALS   
.. cmacro:: RPT_INDEX    
.. cmacro:: RPT_ONEACH   
.. cmacro:: RPT_HDR1     
.. cmacro:: RPT_HDR2     
.. cmacro:: RPT_HDR3     
.. cmacro:: RPT_DETAIL   
.. cmacro:: RPT_VALRECORD    
.. cmacro:: RPT_TEXTWIDTH    
.. cmacro:: RPT_TEXTCOLUMNS  
.. cmacro:: RPT_NOVALUE      
.. cmacro:: RPT_BEFORE       
.. cmacro:: RPT_AFTER        

.. cmacro:: RPT_COLSEP       
   column separator
   
.. cmacro:: RPT_ROWSEP      
   row separator
   
.. cmacro:: RPT_PRETTL      
.. cmacro:: RPT_POSTTTL     
.. cmacro:: RPT_PRINTLINE   
.. cmacro:: RPT_HEADER      
.. cmacro:: RPT_TOCSV       
.. cmacro:: RPT_RECNOS      
.. cmacro:: RPT_FORLOOP     
.. cmacro:: RPT_LINES       
.. cmacro:: RPT_TOHTML      

Report Groups
-------------

.. cmacro:: GRP_KEY      

.. cmacro:: GRP_STOP    

.. cmacro:: GRP_COUNT   
   Anzahl der verarbeiteten Records
.. cmacro:: GRP_KEYVALUE 

.. cmacro:: GRP_TEXT     

.. cmacro:: GRP_VALUES  

.. cmacro:: GRP_WHEN       

   ob mich irgendwelche Total dieser Gruppe möglicherweise
   interessieren. Wenn GRP_WHEN nein sagt, werden die Totale erst gar
   nicht nach ihrer Meinung gefragt.

.. cmacro:: GRP_ALIGN     

.. cmacro:: GRP_HEADER    

   Wird ausgeführt, bevor der erste Record *verarbeitet* wird
   (unabhängig davon, ob dieser Record gedruckt wird oder nicht).
 
.. cmacro:: GRP_BEFORE   

   Wird ausgeführt, bevor der erste Record *gedruckt* wird.
   Oder, wenn kein einziger Record gedruckt wird, vor dem ersten Total,
   das gedruckt wird.

.. cmacro:: GRP_DTLCOUNT 

   Anzahl der effektiv ausgedruckten Records

.. cmacro:: GRP_AFTER    

   Wird ausgeführt, bevor das erste TOTAL der Gruppe gedruckt wird.
   Kriegt 2 Parameter mit : GRP_COUNT und GRP_DTLCOUNT
   Muss .t. oder .f. zurück geben.
   Wenn .f., dann werden die TOTALs nicht gedruckt.

.. cmacro:: GRP_DONE     

   array of booleans indicating whether the total has been printed

.. cmacro:: GRP_TTLCOUNT 

   array of record counts per total
   
.. cmacro:: GRP_FORMAT
.. cmacro:: FORMAT_BOLD

.. cmacro:: GRP_AFTERTTL 

   20050621 : 
   mit ``afterTotals {||PrintLine()}`` kann man angeben, dass nach
   den Totals der Gruppe eine Leerzeile kommt.

.. cmacro:: GRP_STARTED   


Report Columns
--------------

.. cmacro:: CLN_HEADER
.. cmacro:: CLN_WIDTH 

.. cmacro:: CLN_WHEN  
   xl die Bedingung
 
.. cmacro:: CLN_VALUE  

   xn (ggf. der Wert, der summiert wird)
  
.. cmacro:: CLN_TEXT   

   xc (der Text, der gedruckt wird)
   
.. cmacro:: CLN_XSUM
  
.. cmacro:: CLN_TYPE 

.. cmacro:: CLN_DECPOS 

   used when TYPE is N

.. cmacro:: TTL_WHEN   

   Ob das Total ausgedruckt wird
   
.. cmacro:: TTL_TEXT   

   Die "Überschrift" des Totals
   
.. cmacro:: TTL_FOR    

   Welche Records in diesem Total summiert werden
   
.. cmacro:: TTL_AFTER  

   Wird nach Ausdruck des Totals ausgeführt
   



Funktionen
----------

.. function:: RepPrint(cIdRep,cIdDlg,cTitle,cTplIni,cPreview,lToCsv)

   Druckt einen Report.
  
  
.. function:: _rupture(lFinal) 
   
   Called when a group key has changed.
   Prints GRP_HEADER and executes GRP_BEFORE if needed.
   Prints the cached RPT_LINES.
   