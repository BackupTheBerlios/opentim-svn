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

.. function:: ImlPrint()

  blablablabl

.. function:: PickPrfList()

  blablablabl

.. function:: PickPrf()

  blablablabl

.. function:: runbg()

  blablablabl
  
  
  
  

.. file:: RUNBG.LOG

  Log file created on each :func:`runbg` call which contains the stdout and stderr of the process. 

.. file:: AUSLAND.DBC

  blablablabl

.. file:: DLM/SPRL/TOTAL.INC

  To be included by the invoice template using ``[=fparse("TOTAL.INC")]``.
  See :srcref:`DLM/SPRL/TOTAL.INC`.
  