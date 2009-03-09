:staticmod:`DEF_IMP` -- Öffentlich-rechtliche Buchhaltung
=========================================================

.. staticmod:: DEF_IMP 

Definiert die Tabellen :class:`IMP`, :class:`IML` und :class:`MVI`.

=====================  ==========================
Öffentlich-rechtliche  Allgemeine 
=====================  ==========================
:class:`IMP`           :class:`VEN`, :class:`FIN`
:class:`IML`           :class:`VNL`, :class:`FNL`
:class:`MVI`           :class:`HST`
=====================  ==========================


.. function:: ImlGenerate(aIml,cIdJnl,cIdDoc)

   Generates :class:`IML` records from an array.
   Called from :func:`ImlCopy`.
   The array may be constructed using :func:`MviImlCollect`.
   
   
   
.. function:: ImlCopy()   


.. function:: MviLnCollect(bPreCollect,lIdPar)

   Loops over MVI according to the current MVI filter options and calls
   :func:`MviImlCollect` on each found record.

   Called from :func:`ImlCopy`, :func:`TrlCopy`, :func:`LniCreate`

.. function:: MviImlCollect(aIml,lTestAttrV)

   Adds the information of the current :class:`MVI` record as an array
   item to `aIml`.
   
   Called from :func:`MviLnCollect`. 

