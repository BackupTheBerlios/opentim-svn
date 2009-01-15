Global functions
================


Internationalization
--------------------

.. function:: tr(en,de,fr,nl,et)

   Return one of the up to 5 parameters, depending on :func:`TplLang`.
   The first 3 parameters are mandatory (but may be empty strings),
   `nl` and `et` are optional. This function is used in
   internationalized (multi-lingual) print templates.
  
.. function:: TplLang()

   Returns a one-character language code representing for the document
   being printed or parsed.
   
    =============== =========
    one-letter code ISO2 code
    =============== =========
    D               de
    F               fr
    E               en
    N               nl
    K               et
    =============== =========
   

  
Printing
--------
  
.. function:: PrintTemplate(cTplType,cIdTpl,cPreview,bTitBlock,;
   bPrePrint,cIdOpt,lDlg,lAsPdf,lAsMail)  
   
   Locates the specified :class:`TPL` and parses it to the printer
   (using PrnStream())
   
   
.. function:: PrintAct(cActName,bTitBlock,cTplIni,cPreview,nWidth)

   Opens the printer stream, then executes the specified .act file
   inside this print job.
   
.. function:: p_MrgMirror()

   Mirror the right and left margin (exchange their values)
   
.. function:: p_SetLMargin(nInches)

   Set left margin in inches.
   
.. function:: p_SetWidth(nApsWidth)

   Set the line width by selecting a font size so that at least
   nApsWidth characters fit onto a line.

.. function:: PpsExec(cTplIni) 

   

Process managment
-----------------

.. function:: runbg()

  blablablabl
  
Global settings
---------------
  
.. function:: SetMont2CSV(bBlock)

  blablabla
  
  
Date functions
--------------

.. function:: SkipMonth(dDate,nSkip)

.. function:: FirstOfMonth(dDate)

   Return the first day of the month of `dDate` as a DATE object.
   
   Example: 
     FirstOfMonth(ctod("2008-12-24")) --> ctod("2008-12-01")

.. function:: LastOfMonth(dDate)

   Return the last day of the month of `dDate` as a DATE object.
   
   Example: 
     LastOfMonth(ctod("2008-12-24")) --> ctod("2008-12-31")


Data Definition functions
-------------------------

These functions may be used in :xfile:`*.def` files.

.. function:: ddPrintRecord(bBlock)

   Define or replace the codeblock to be run when user hits :kbd:`F7`
   on a row.
   
.. function:: ddOnTest(xcExpression)   

   Add a validity test condition. This will be tested when editing a
   row and in the integrity test. If it returns `.f.`, then it should
   also call :func:`SetMsg` to inform the user about what is wrong.
   
.. function:: ddAddSpecial(bBlock,cMenuLabel,nHotKey,blWhen)

   Add a menu entry to the "Special" menu when editing data records of
   this table.
   
.. function:: ddAddField(...)

   blablabla
   
   
Static Modules   
--------------
   
.. module:: DEF_MVI

   blablabla
   
   