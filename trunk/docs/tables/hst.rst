HST -- Buchungen
================

.. class:: HST

  .. attribute:: IdJnl
  
    Pointer to the :class:`JNL`. 
  
  .. attribute:: IdDoc
  
    Pointer to :class:`VEN`, :class:`FIN` or :class:`ODS`
    (depending on :attr:`JNL.Alias`)
    
  .. attribute:: Line
  
    Together with :attr:`HST.IdDoc` this points to the row in
    :class:`VNL`, :class:`FNL` or :class:`ODL`
    (depending on :attr:`JNL.Alias`) which caused this line.
    
    :attr:`HST.Line` may be empty if it is a result of more than 
    one line. 
    
  .. attribute:: IdTax
  
    Pointer to :class:`TAX`
  
  .. attribute:: DC
  
    Buchungsrichtung. Enthält "D" oder "C".
    
  .. attribute:: Mont
  
    Betrag in Grundwährung. 
    
  .. attribute:: MontDev
  
    Betrag in Fremdwährung.
    
  .. attribute:: IdDev
  
    Welche Fremdwährung verwendet wird. 
    Pointer to :class:`DEV`
  
