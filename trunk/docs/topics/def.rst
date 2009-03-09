Data Definition functions
=========================

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
   
.. function:: ddAddField( cName, cType, nLen, nDec, ;
                     cPicture, cAttrib, ;
                     bBlock, nHandle, ;
                     blValid, bPickBlock, bPreBlock, ;
                     bPostEdit, ;
                     bAfter, bPseudo)
                     
   Add a data field to the table. 
   The field may be virtual (if `nHandle` is NIL)