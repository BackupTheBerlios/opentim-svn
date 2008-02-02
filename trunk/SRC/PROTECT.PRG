** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2008 Luc Saffre
**
** This file is part of TIM.
**
** TIM is free software: you can redistribute it and/or modify it
** under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 3 of the License, or
** (at your option) any later version.
**
** TIM is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
** License for more details.
**
** You should have received a copy of the GNU General Public License
** along with TIM. If not, see <http://www.gnu.org/licenses/>.

#include "LIB.CH"

#ifdef DEF_BRAND

* **
* ** Hardware identifier (based on BIOS date)
* **
* ** Returns a string of 8 *alphabetic* *uppercase* *chars*
* **
* FUNCTION HWId1
* local cReturn := ""
* #ifdef DEF_NANFOR
*   cReturn += chr( 65 + ((ft_peek(65535, 5) *  2) % 25) )
*   cReturn += chr( 65 + ((ft_peek(65535, 6) *  3) % 25) )
*   cReturn += chr( 65 + ((ft_peek(65535, 7) *  5) % 25) )
*   cReturn += chr( 65 + ((ft_peek(65535, 8) *  6) % 25) )
*   cReturn += chr( 65 + ((ft_peek(65535, 9) *  9) % 25) )
*   cReturn += chr( 65 + ((ft_peek(65535,10) * 11) % 25) )
*   cReturn += chr( 65 + ((ft_peek(65535,11) * 13) % 25) )
*   cReturn += chr( 65 + ((ft_peek(65535,12) * 15) % 25) )
*   RETURN cReturn
* #else
*   RETURN "DEMO    "
* #endif

* **
* ** Hardware identifier (based on BIOS date and boot disk size)
* **
* ** Returns a string of 8 *alphabetic* *uppercase* *chars*
* **
* FUNCTION HWId2
* #ifdef DEF_NANFOR
*   local cReturn := ""
*   local c := left(CfgBootDisk(),1)
*   local nDskSize := ft_dsksize(c)
*   cReturn += chr( 65 + ((nDskSize + ft_peek(65535, 5) *  2) % 25) )
*   cReturn += chr( 65 + ((ft_peek(65535, 6) *  3) % 25) )
*   cReturn += chr( 65 + ((nDskSize + ft_peek(65535, 7) *  5) % 25) )
*   cReturn += chr( 65 + ((ft_peek(65535, 8) *  6) % 25) )
*   cReturn += chr( 65 + ((nDskSize + ft_peek(65535, 9) *  9) % 25) )
*   cReturn += chr( 65 + ((ft_peek(65535,10) * 11) % 25) )
*   cReturn += chr( 65 + ((nDskSize + ft_peek(65535,11) * 13) % 25) )
*   cReturn += chr( 65 + ((ft_peek(65535,12) * 15) % 25) )
*   RETURN cReturn
* #else
*   RETURN "DEMO    "
* #endif

**
** Hardware identifier (based on BIOS date and boot disk volserial)
**
** Returns a string of 8 *alphabetic* *uppercase* *chars* 
**
*FUNCTION HWId3
*local cReturn := ""
*#ifdef DEF_CTOOLS
*  local cVolSer := volserial(left(CfgBootDisk(),1))
*  RETURN cVolSer
*#else
*  RETURN "DEMO    "
*#endif

#endif

**
** STOK()
**
** For each string in aStr there will be tree positions in the resulting key
**
FUNCTION stok( aStr, cAppName, nAppVer, dLimit, cHWId )
local cKey := ""
local i,j
local nSum
local aSum := { }
for i := 1 to len(aStr)
  aStr[i] := strtran(aStr[i]," ") + cAppName + cHWId // spaces are ignored
  nSum := 0
  for j := 1 to len(aStr[i])
    nSum += ( asc(subst(aStr[i],j,1)) * j * nAppVer + day(dLimit))
  next j
  nSum += year(dLimit)
  nSum -= month(dLimit)
  aadd( aSum, nSum )
next i
for i := 1 to len(aSum)
  if i > 1
    nSum := aSum[i] + aSum[i-1]
  else
    nSum := aSum[i] + atail(aSum)
  endif
  nSum := nSum % 1000
  cKey += strtran( str(nSum,3), " ", "0" )
next i
RETURN cKey


* 1. In <BRAND>.EXE : compute an Install Code out of
*           - 3 Strings, AppName, AppVer (= stok)
*           - Limit Date
*
* 2. In AppInit() :
*   A. Compute a Limit Date out of
*          - 3 Strings, AppName, AppVer (= stok)
*          - Install Code
*   B. Check Install Code against Strings
*

**
** Converts date to prefix
**
FUNCTION dtop(dDate)
local nDay := day(dDate)
local nMonth := month(dDate)
local nYear := year(dDate)
local cPos1
local cPos2
local cPos3
if nDay > 25
  cPos3 := chr(nDay+22)     // 26 -> "0", ... 31 -> "5"
else
  cPos3 := chr(nDay+65)     // 0 -> "A", ... , 25 -> "Z"
endif
cPos1 := chr( nMonth + (nDay % 14) + 65 )
if nYear == 0
  cPos2 := cPos1
else
  cPos2 := chr( nYear - 1990 + (nMonth % 3) + 65 )
endif
RETURN (cPos1 + cPos2 + cPos3)

**
** Converts prefix to date
**
FUNCTION ptod(cPrefix)
local nDay
local nMonth
local nYear
local cPos1 := substr(cPrefix,1,1)
local cPos2 := substr(cPrefix,2,1)
local cPos3 := substr(cPrefix,3,1)
if cPos3 >= "A"
  nDay := asc(cPos3) - 65     // "A" -> 0, ..., "Z" -> 25
else
  nDay := asc(cPos3) - 22
endif
nMonth := int( asc(cPos1) - 65 - (nDay % 14))
if nMonth == 0
  RETURN ctod("")
else
  nYear := int( 1990 + asc(cPos2) - (nMonth % 3) - 65 )
endif
RETURN ctod( ntrim(nDay) + "/" + ntrim(nMonth) + "/" + ntrim(nYear) )



