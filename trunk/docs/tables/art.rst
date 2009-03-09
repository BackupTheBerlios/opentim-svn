ART (Artikelstammdaten - Products)
==================================

.. class:: ART

  Artikelstammdaten 

  .. attribute:: IdArt
  
    Product ID. Primary key.
  
  .. attribute:: Name1
  
    blablabl
    
  .. attribute:: Attrib
  
    Attributes for this product. 
      
.. function:: PickArt()

  Let the user select a product id from a list.
  
  
Artikelattribute 
----------------
Stored in field :attr:`ART.Attrib`.
The allowed attributes are defined in :xfile:`ARTATTR.DBC`. 
Some attributes have a hard-coded meaning:
    
.. data:: ARTATTR_S
  
  Marks this is product as non-physical (no stock)
  
.. data:: ARTATTR_H
  
  Marks this is product as hidden. That is, it will be filtered
  away in normal views.
  
