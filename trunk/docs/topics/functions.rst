Global functions
================

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


.. function:: fprint(cFilename,cCmdTags,nWidth,bPageHeader,;
                     cRange, bPrePrint, cIdDlg, lDlg, lAsPdf, 
                     lAsMail)
                     
   Open a printer stream and parse the specified file, then 
   close the printer.

   

Process managment
-----------------

.. function:: runbg(cProgram,cParams,lAsync,lBackground,lLog)

   Runs the specified `cProgram` (which must be the complete 
   name including path of an existing executable file) with 
   the specified `cParams` in a system shell as a background 
   process.

   - `lAsync` : set this to ``.t.`` if you don't want TIM to wait for the process 
     to exit.
   - `lBackground` : set this to ``.f.`` if you want to appear the process's 
     window in front of TIM.
   - `lLog` : set this to ``.f.`` if you don't want to write a :xfile:`RUNBG.LOG`.

  
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


