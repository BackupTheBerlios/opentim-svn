/*

 source: http://www.artfulsoftware.com/trigPrg.htm

  aa_trig.prg

    Sin()
    Cos()
    ASin()
    ACos()
    GeoDist()     --> distance between two points in radians
    GeoDistKM()   --> ditto in Km



  If the latitudes of the two points are l1 and l2 and the longitudes are
  L1 and L2, the differences are



    dl = l2 - l1
    dL = L2 - L1



  and a fairly accurate formula for the distance in radians is

    d = 2 asin(sqrt(sin(dl/2)^2 + cos(l1) * cos(l2) * sin(dL/2)^2 ) )

 */




#include "LIB.CH"

#ifdef DEF_TRIG

*#xcommand DEFAULT <foo> TO <bar> => ;
*
*          IF <foo> == NIL ; <foo> := <bar> ; ENDIF



#define PI              3.14159

#define KM_PER_RADIAN   111 * 180 / PI

#define GEO_PRECISION   .001

#define FACTORIAL_MAX   21        // Max Clipper can handle is 21



// #define STEPLIST







*#ifdef DEBUG
*
*  PROC TEST( a, b )
*
*  Local nTmp
*
*  Set Alte On
*
*  Set Alte To trigOut
*
*  ? "Radians", Val( a )
*
*  ? nTmp := Sin( Val( a ), val( b ) )
*
*  ? Cos( Val( a ), val( b ) )
*
*  ? "asin", aSin( nTmp, Val( b ) )
*
*  ? "asin( .707 )", asin( .707, .000001 )
*
*  ? "Distance in Km from McComb, MS to LA, CA:", GeoDistKM( 40, 49, 25, 2 )
*
*  Set Alte off
*
*  Set Alte To
*
*#endif





/*
  Sin(x) = x - x^3/3! + x^5/5! - x^7/7! + ...
 */
Function Sin( nRads, nPrecision )
Local nRet := nRads
Local lNeg := .T.
Local nNum := nRads
Local nDen := 1
Local nPrv := nRet
Local i, nTmp
default nPrecision to 0.001
For i := 3 To FACTORIAL_MAX Step 2
   nNum := nRads * nRads * nNum
   nDen := i * ( i - 1 ) * nDen
   nTmp := nNum / nDen
   nPrv := nRet
   If lNeg
      nRet -= nTmp
   Else
      nRet += nTmp
   EndIf
   If Abs( nPrv - nRet ) < nPrecision ; Exit ; Endif
   lNeg := !lNeg
   #ifdef STEPLIST
     ? i, nNum, nDen, Str( nTmp, 20, 18 ), nRet
   #endif
Next
// If nRet < 1 ; nRet := -1 ; ElseIf nRet > 1 ; nRet := 1 ; EndIf
Return nRet







/*
  Cos( x ) = x - x^2/2! + x^4/4! - x^6/6 + ...
          or Sqrt( 1 - Sinìx )
 */
Function Cos( nRads, nPrecision )
Local nSin := Sin( nRads, nPrecision )
// Return If( Abs( nSin ) >= 1, 0, ( 1 - ( nSin * nSin ) )  ^.5 )
Return ( 1 - ( nSin * nSin ) )  ^.5







/*
  ASin( nSin, nPrecision )
        1 * x^3   1 * 3 * x^5   1 * 3 * 5 * x^7
    x + ------- + ----------- + --------------- + ...   ( |x| < 1 )
        2 * 3     2 * 4 * 5     2 * 4 * 6 * 7
 */
Function ASin( nSin, nPrecision )
Local nRet := 0
Local i, j, nNum, nDen, nTmp
If nSin > 0
   If Abs( 1 - nSin ) > nPrecision
      j := 1
      nRet := nSin
      nNum := nSin
      For i := 3 To 99 Step 2
         j *= ( i - 1 )
         nDen := j * i
         nNum *= ( ( i - 2 ) * nSin * nSin )
         nTmp := nNum / nDen
         nRet += nTmp
         #ifdef STEPLIST
           ? "nNum, nDen, nTmp, nRet: ", nNum, nDen, nTmp, nRet
         #endif
         If nTmp < nPrecision ; Exit ; EndIf
      Next
   Else
      nRet := 3.14159 / 2
   EndIf
EndIf
Return nRet


Function ACos( nRads, nPrecision )
Return ( PI / 2 ) - aSin( nRads, nPrecision )


Function GeoDist( lat1, lat2, long1, long2, nPrecision )
Local dlat, dLong
Default nPrecision To GEO_PRECISION
lat1  := lat1 * PI / 180
lat2  := lat2 * PI / 180
long1 := long1 * PI / 180
long2 := long2 * PI / 180
dlat  := lat2 - lat1
dLong := long2 - long1
Return 2 * ASin( SqRt( ( Sin( dLat/2, nPrecision ) ) ^ 2 + ;
                   Cos( lat1, nPrecision ) *         ;
                   Cos( lat2, nPrecision ) *         ;
                   ( Sin( dLong/2, nPrecision ) ) ^ 2  ;
                 ), nPrecision )







Function GeoDistKm( lat1, lat2, long1, long2 )
Return GeoDist( lat1, lat2, long1, long2 ) * KM_PER_RADIAN

#else

PROC trig_dummy ; RETURN
#endif DEF_TRIG


