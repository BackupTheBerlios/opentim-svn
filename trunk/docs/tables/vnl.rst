VNL
===

.. class:: VNL

  Lines of a Partner Document

  .. attribute:: IdJnl
  
    Pointer to the :class:`JNL`.
  
  .. attribute:: IdDoc
  
    Pointer to the :class:`VEN`.
    
  .. attribute:: IdPrj
  
    Pointer to the :class:`PRJ`.
  
 .. attribute:: _TVAC
 
    Virtual field showing the amount VAT included. 
    It is usually the sum of :attr:`VEN.cMont`
    and :attr:`VEN.MontT`. Exception: if :attr:`TAX.GenTiers` 
    is not empty.
    

.. function:: GsbVnlTvac(x)
   
   Get/Set block for virtual field :attr:`VNL._TVAC`.