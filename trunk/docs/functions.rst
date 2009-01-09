Global functions
================

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
   

.. function:: ImpPrint()

  blablablabl

  
Printing
--------
  
.. function:: PrintTemplate(cTplType,cIdTpl,cPreview,bTitBlock,;
   bPrePrint,cIdOpt,lDlg,lAsPdf,lAsMail)  
   
   Locates the specified :class:`TPL` and parses it to the printer
   (using PrnStream())
   
   
.. function:: PrintAct(cActName,bTitBlock,cTplIni,cPreview,nWidth)

   Opens the printer stream, then executes the specified .act file
   inside this print job.
   
   

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

