The template parser
===================



Parser commands
---------------

.. parsercmd:: img

  Syntax: ``[img LOCATION PARAMS]``

  Inserts the specified picture when rendering this to HTML.


.. parsercmd:: etc if

  Syntax: ``[etc if CONDITION]``
  
  Marks the beginning of a conditional block. The CONDITION (in Clipper syntax) ist evaluated during parsing and the content of the block is parsed only if this returns ``.t.``.
  
  
.. parsercmd:: etc endif

  Syntax: ``[etc endif]``
  
  Marks the end of a conditional block. 
  


.. parsercmd:: set paperheight
.. parsercmd:: set paperwidth  
.. parsercmd:: set marginleft  
.. parsercmd:: set marginright
.. parsercmd:: set margintop  
.. parsercmd:: set marginbottom
