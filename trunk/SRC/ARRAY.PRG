not used

/***
*
*  Array.prg
*  Sample user-defined functions for manipulating arrays
*  Copyright, Nantucket Corporation, 1990
*
*  NOTE: compile with /n/w/a/m
*/

#include "inkey.ch"


/***
*  ABrowse( <aArray>, <nTop>, <nLeft>, <nBottom>, <nRight> ) --> value
*
*  Browse a 2-dimensional array using TBrowse object and return the value
*  of the highlighted array element.

// Authors  : Jake Jacob & Fleming Ho

FUNCTION ABrowse
   PARAMETERS aArray, nT, nL, nB, nR

   LOCAL o			// TBrowse object
   LOCAL k			// used in o:SkipBlock
   LOCAL nKey := 0	// keystroke holder

   PRIVATE n := 1	// browse row subscript holder
   PRIVATE nACol	// browse column subscript


   nT := IF( nT == NIL, 0, nT )
   nL := IF( nL == NIL, 0, nL )
   nB := IF( nB == NIL, 0, nB )
   nR := IF( nR == NIL, 0, nR )

   SetCursor( 0 )

   // Create the TBrowse object
   o := TBrowseNew( nT, nL, nB, nR )

   // Initialize the TBrowse blocks

   // Note: during browse, the current row subscript is maintained
   // by the blocks in private n

   o:SkipBlock := ;
	  { |x| ;
		 k := IF(ABS(x) >= IF(x >= 0, LEN(aArray) - n, n - 1), ;
				 IF(x >= 0, LEN(aArray) - n, 1 - n), ;
				 x), ;
		 n += k, ;
		 k ;
	  }

   o:GoTopBlock := { || n := 1 }
   o:GoBottomBlock := { || n := LEN(aArray) }

   // Create TBColumn objects,
   // Initialize data retrieval blocks, and
   // Add to TBrowse object
   FOR nACol = 1 TO LEN( aArray[1] )
	  o:AddColumn( TBColumnNew( "", ABlock("aArray[n]", nACol) ) )
   NEXT

   // Start the event handler loop
   DO WHILE nKey <> K_ESC .AND. nKey <> K_RETURN

      nKey := 0

      // Start the stabilization loop
      DO WHILE .NOT. o:Stabilize()
         #ifdef DEF_ALLKEY
           nKey := ALLKEY()
         #else
           nKey := INKEY()
         #endif
         IF nKey <> 0
            EXIT
         ENDIF
      ENDDO

      IF nKey == 0
         #ifdef DEF_ALLKEY
         nKey := ALLKEY()
         #else
         nKey := INKEY(0)
         #endif
      ENDIF

      // Process the directional keys
      IF o:Stable

         DO CASE
         CASE ( nKey == K_DOWN )
            o:Down()
         CASE ( nKey == K_UP )
            o:Up()
         CASE ( nKey == K_RIGHT )
            o:Right()
         CASE ( nKey == K_LEFT )
            o:Left()
         CASE ( nKey == K_PGDN )
            o:Right()
            o:Down()
         CASE ( nKey == K_PGUP )
            o:Right()
            o:Up()
         CASE ( nKey == K_HOME )
            o:Left()
            o:Up()
         CASE ( nKey == K_END )
            o:Left()
            o:Down()
         ENDCASE
      ENDIF
   ENDDO

   SetCursor( 1 )

   RETURN IF( nKey == K_RETURN, aArray[ n, o:ColPos ], NIL )

*/


/***
*  ABlock( <cName>, <nSubx> ) -> bABlock
*
*  Given an array name and subscript, return a set-get block for the
*  array element indicated.
*
*  NOTE: array must be macro-able, i.e. not a LOCAL or STATIC variable
*
*  NOTE: ABlock() may be used to make blocks for multi-dimensional arrays
*  by providing a subscripted array expression as cName:
*
*	  // to make a set-get block for a[i]
*	  b := ABlock( "a", i )
*
*	  // to make a set-get block for a[i][j]
*	  b :=- ABlock( "a[i]", j )
*/

FUNCTION ABlock( cName, nSubx )
LOCAL cAXpr
cAXpr := cName + "[" + LTRIM(STR(nSubx)) + "]"
RETURN &( "{ |p| IF(PCOUNT()==0, " + cAXpr + "," + cAXpr + ":=p) }" )







/***
*  Amax( <aArray> ) --> nPos
*  Return the subscript of the array element with the highest value.
*/

/* CAUTION: need other types of error checking for this function */

FUNCTION Amax( aArray )
LOCAL nLen, nPos, expLast, nElement
DO CASE

// Invalid argument
CASE VALTYPE( aArray ) <> "A" ; RETURN NIL

// Empty argument
CASE EMPTY( aArray )  ; RETURN 0

// Valid, non-empty argument
OTHERWISE
   nLen := LEN( aArray )
   nPos := 1
   expLast := aArray[1]
   FOR nElement := 2 TO nLen
      IF aArray[nElement] > expLast
         nPos := nElement
         expLast := aArray[nElement]
      ENDIF
   NEXT
   RETURN nPos
ENDCASE
RETURN 0


/***
*  Amin( <aArray> ) --> nPos
*  Return the subscript of the array element with the lowest value.
*/

FUNCTION Amin( aArray )
LOCAL nLen, nPos, expLast, nElement
DO CASE
CASE VALTYPE( aArray ) <> "A" ;  RETURN NIL   // Invalid argument
CASE EMPTY( aArray ) ;  RETURN 0              // Empty argument
OTHERWISE
  nLen := LEN( aArray )
  nPos := 1
  expLast := aArray[1]
  FOR nElement := 2 TO nLen
    IF aArray[nElement] < expLast
      nPos := nElement
      expLast := aArray[nElement]
    ENDIF
  NEXT
  RETURN nPos
ENDCASE
RETURN 0


/***
*  AComp( <aArray>, <bComp>, [<nStart>], [<nStop>] ) --> valueElement
*  Compares all elements of aArray using the bComp block from nStart to
*  nStop (if specified, otherwise entire array) and returns the result.
*  Several sample blocks are provided in Array.ch.
*/
FUNCTION AComp( aArray, bComp, nStart, nStop )
LOCAL value := aArray[1]
AEVAL( aArray, {|x| value := IIF( EVAL(bComp, x, value), x, value )}, ;
       nStart, nStop )
RETURN( value )


/***
*  Dimensions( <aArray> ) --> aDims
*  Return an array of numeric values describing the dimensions of a
*  nested or multi-dimensional array, assuming the array has uniform
*  dimensions.
*/

*FUNCTION Dimensions( aArray )
*   LOCAL aDims := {}
*   DO WHILE ( VALTYPE(aArray) == "A" )
*      AADD( aDims, LEN(aArray) )
*      aArray := aArray[1]
*   ENDDO
*   RETURN (aDims)


