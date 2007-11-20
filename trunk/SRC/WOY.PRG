/*
 * File......: WOY.PRG
 * Author....: Forest Belt, Computer Diagnostic Services, Inc.
 * Date......: $Date:   15 Aug 1991 23:03:18  $
 * Revision..: $Revision:   1.2  $
 * Log file..: $Logfile:   E:/nanfor/src/woy.prv  $
 *
 * This is an original work by Forest Belt and is placed in the
 * public domain.
 */


**  $DESCRIPTION$
**     Considers a full week as starting on Sunday, ending on Saturday.
**     First week of year (week 1) may start on any day, and thus
**       contain any number of days.
**     Final week of year (week 53) may contain any number of days.
**     Handles dates with CENTURY ON|OFF, to allow for 21st century.
**     Date validation must be external to this function.
 
FUNCTION FT_WOY(dInDate)
LOCAL nDayOffset
local nYear := year(dInDate)
local dFirst := ntod(year(dInDate),1,1)
do while dow(dFirst) != 1 // Sunday
  dFirst--
enddo
nDayOffset := dInDate - dFirst
// find number of days in first week of year
* nFirstDays := 8 - dow(ntod(year(dInDate),1,1))
* nDayOffset := dInDate - ntod(year(dInDate),1,1) - nFirstDays + 1
RETURN int(nDayOffset/7) + 1

** new 20041206
**
FUNCTION ls_woy(dInDate)
LOCAL nDayOffset
local nYear := year(dInDate)
local dFirst := ntod(year(dInDate),1,4)
do while dow(dFirst) != 2 // Sunday
  dFirst--
enddo
nDayOffset := dInDate - dFirst
if nDayOffset < 0
  RETURN ls_woy(dFirst-7)
endif
RETURN str(int(nDayOffset/7) + 1,2)+"/"+str(nYear,4,0)


**
** ntod() - numeric to date format
**
FUNCTION ntod(y,m,d)
#ifdef LG_FRENCH
  RETURN ctod(str(d,2)+"/"+str(m,2)+"/"+str(y,4))
#else
  RETURN ctod(str(d,2)+"."+str(m,2)+"."+str(y,4))
#endif

FUNCTION SkipMonth(d,n)
local nMonat := month(d) + n
local nJahr := year(d)
local nTag := day(d)
do while nMonat > 12
  nMonat -= 12
  nJahr ++
enddo
do while nMonat < 1
  nMonat += 12
  nJahr --
enddo
d := ctod("")
do while empty(d)
  d := ntod(nJahr,nMonat,nTag)
  nTag --
enddo
RETURN d




/* $DOC$
 *  $FUNCNAME$
 *     FT_DOY()
 *  $CATEGORY$
 *     Date/Time
 *  $ONELINER$
 *     Find number of day within year
 *  $SYNTAX$
 *     FT_DOY( <dDate> ) -> <nResult>
 *  $ARGUMENTS$
 *     <dDate> is a date in the form "mm/dd/yy" or "mm/dd/yyyy"
 *  $RETURNS$
 *     Return numeric position of day within the year.
 *     Return NIL if parameter does not conform.
 *  $DESCRIPTION$
 *     Finds the day number, considering 01/01 as day 1
 *     Handles dates with CENTURY ON|OFF, to allow for 21st century.
 *     Date validation must be external to this function.
 *  $EXAMPLES$
 *     These code fragments find the day number, given a date.
 *
 *     // literal character date
 *     dDate  := CTOD("01/01/91")
 *     nDayNum := FT_DOY(dDate)              // result:  1
 *
 *     // presume DOS date to be 01/06/91
 *     nDayNum := FT_DOY(DATE())             // result:  6
 *
 *     // date input
 *     cDate  := SPACE(8)
 *     @ 4,10 get cDate PICT "##/##/##"      // input 07/04/91
 *     READ
 *     nDayNum := FT_DOY(CTOD(cDate))        // result: 185
 *
 *     // last day of year
 *     nDayNum := FT_DOY(CTOD("12/31/91"))    // result: 365
 *
 *     For a demonstration of this function, compile and link the
 *     program WOY.PRG in the Nanforum Toolkit source code.
 *  $END$
 */
 
*FUNCTION FT_DOY(dInDate)
*  LOCAL nDayNum, cCentury
*  IF VALTYPE(dInDate) != "D"
*     nDayNum := NIL
*  ELSE
*     // resolve century issue
*     IF LEN( DTOC( dInDate) ) > 8                  // CENTURY is on
*     cCentury := SUBSTR( DTOC( dInDate) ,7 ,4)
*     ELSE
*     cCentury := SUBSTR( DTOC( dInDate) ,7 ,2)
*     END
*     // calculate
*     nDayNum := (dInDate - CTOD ("01/01/" + cCentury)) + 1
*  END
*RETURN (nDayNum)
