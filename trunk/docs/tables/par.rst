Partners
========

.. class:: PAR

  A Partner is a person or organisation that can be used as recipient of invoices, with contact information (name, postal address, phone numbers, ...) 

  .. attribute:: IdPar
  
    blablabl
  
  .. attribute:: Firme
  
    blablabl
    
  .. attribute:: Name2
  
    blablabl
    
  .. attribute:: Attrib
  
    Attributes for this partner.
  
  .. attribute:: Compte1
  
    Bank Account Number. 
    See :doc:`../topics/iban`.
  

Partnerattribute 
----------------

Stored in field :attr:`PAR.Attrib`.
The allowed attributes are defined in :xfile:`PARATTR.DBC`. 
Some attributes have a hard-coded meaning:
    
.. data:: PARATTR_!
  
  blabla
  
.. data:: PARATTR_H
  
  Marks this is partner as hidden. That is, it will be filtered
  away in normal views.
  
