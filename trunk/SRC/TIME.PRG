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

**
** dToText()
**
FUNCTION dToText(dDate,cLangue)
local cDate := ntrim(day(dDate))
RETURN "" if empty(dDate)
if cLangue == "F"
  cDate += " "
elseif cLangue == "D"
  cDate += ". "
endif
cDate += MonthName(month(dDate),cLangue) + " "
cDate += ntrim(year(dDate))
RETURN cDate

**
** dToMonth()
**
FUNCTION MonthName(nMonth,cLangue)
* local nMonth := month(dDate)
static aMonthF := { "janvier", "f‚vrier", "mars", "avril", "mai", "juin", "juillet", "ao–t", "septembre", "octobre", "novembre", "d‚cembre" }
static aMonthD := { "Januar", "Februar", "M„rz", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember" }
static aMonthN := { "januari", "februar", "maart", "april", "mei", "juni", "juli", "augustus", "September", "oktober", "november", "december" }
static aMonthE := { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
static aMonthK := { ;
  "jaanuar", "veebruar", "m„rts", ;
  "aprill", "mai", "juuni", ;
  "juuli", "august", "september", ;
  "oktoober", "november", "detsember" ;
}
default cLangue to TplLang()
RETURN "?" if nMonth < 1 .or. nMonth > 12
RETURN aMonthF[nMonth] if cLangue == "F"
RETURN aMonthD[nMonth] if cLangue == "D"
RETURN aMonthN[nMonth] if cLangue == "N"
RETURN aMonthK[nMonth] if cLangue == "K"
RETURN aMonthE[nMonth]


**
** TrimBegin()
**
FUNCTION TrimBegin( dDate )
if month(dDate) <  4 ; RETURN ntod(year(dDate),1,1) ; endif
if month(dDate) <  7 ; RETURN ntod(year(dDate),4,1) ; endif
if month(dDate) < 10 ; RETURN ntod(year(dDate),7,1) ; endif
RETURN ntod(year(dDate),10,1)

**
** TrimEnd()
**
FUNCTION TrimEnd( dDate )
if month(dDate) <  4 ; RETURN ctod("31/03/" + ntrim(year(dDate))) ; endif
if month(dDate) <  7 ; RETURN ctod("30/06/" + ntrim(year(dDate))) ; endif
if month(dDate) < 10 ; RETURN ctod("30/09/" + ntrim(year(dDate))) ; endif
RETURN ctod("31/12/" + ntrim(year(dDate)))

FUNCTION ArrSkip(n,nPos,nLen)
if n > 0
  if nPos + n > nLen
    n := nLen - nPos
  endif
elseif n < 0
  if nPos + n < 1
    n := 1 - nPos
  endif
endif
nPos += n
RETURN n

**
** TimeDiff()
**
** Dur‚e entre c1 (d‚but) et c2 (fin). Achtung: also c2 - c1
**
FUNCTION TimeDiff(c1,c2,nLen)
local nHeures
local nMinutes
default nLen to max(len(c1),len(c2)) // 5
* confirm(c1+","+c2)
if empty(c1) .or. empty(c2)
  RETURN space(nLen)
endif
nHeures  := val(left(c2,len(c2)-3)) - val(left(c1,len(c1)-3))
nMinutes := val(right(c2,2)) - val(right(c1,2))
if nMinutes < 0
  nHeures -= 1
  nMinutes += 60
endif
if nMinutes > 59 .or. nMinutes < 0
  RETURN space(nLen)
endif
if nHeures == 0 .and. nMinutes == 0
  RETURN space(nLen)
endif
if nHeures < 0
  nHeures += 24
endif
RETURN padl(ltrim(str(nHeures)) + ":" + strtran( str(nMinutes,2), " ", "0" ),nLen)


**
** RunTimeDiff()
**
** Dur‚e entre c1 (d‚but) et c2 (fin)
**
FUNCTION RunTimeDiff(c1,c2)
local nHeures
local nMinutes
local nSecondes
local nLen := 8
nHeures  := val(left(c2,2)) - val(left(c1,2))
nMinutes := val(substr(c2,4,2)) - val(substr(c1,4,2))
nSecondes := val(right(c2,2)) - val(right(c1,2))
if nSecondes < 0
  nMinutes -= 1
  nSecondes += 60
endif
if nMinutes < 0
  nHeures -= 1
  nMinutes += 60
endif
if nSecondes > 59 .or. nSecondes < 0
  RETURN space(nLen)
endif
if nMinutes > 59 .or. nMinutes < 0
  RETURN space(nLen)
endif
if nHeures == 0 .and. nMinutes == 0 .and. nSecondes == 0
  RETURN space(nLen)
endif
* if nHeures < 0
*   nHeures += 24
* endif
RETURN padl(;
  ltrim(str(nHeures)) + "." ;
  + strtran( str(nMinutes,2), " ", "0" ) + ".";
  + strtran( str(nSecondes,2), " ", "0" ),;
  nLen)

FUNCTION RunTimeAdd(c1,c2)
local nHeures
local nMinutes
local nSecondes
local nLen := 8
nHeures  := val(left(c2,2)) + val(left(c1,2))
nMinutes := val(substr(c2,4,2)) + val(substr(c1,4,2))
nSecondes := val(right(c2,2)) + val(right(c1,2))
if nSecondes >= 60
  nMinutes += 1
  nSecondes -= 60
endif
if nMinutes >= 60
  nHeures += 1
  nMinutes -= 60
endif
if nSecondes > 59 .or. nSecondes < 0
  RETURN space(nLen)
endif
if nMinutes > 59 .or. nMinutes < 0
  RETURN space(nLen)
endif
if nHeures == 0 .and. nMinutes == 0 .and. nSecondes == 0
  RETURN space(nLen)
endif
* if nHeures < 0
*   nHeures += 24
* endif
RETURN padl(;
  ltrim(str(nHeures)) + "." ;
  + strtran( str(nMinutes,2), " ", "0" ) + ".";
  + strtran( str(nSecondes,2), " ", "0" ),;
  nLen)


**
** TimeAdd()
**
** Additionne les dur‚es c1 et c2
**
** La longueur du string peut varier !
**
FUNCTION TimeAdd(c1,c2)
local nHeures
local nMinutes
local nSeconds
RETURN c2 if empty(c1)
RETURN c1 if empty(c2)
nHeures  := val(left(c1,len(c1)-3)) + val(left(c2,len(c2)-3))
nMinutes := val(right(c1,2)) + val(right(c2,2))
if nMinutes > 59
  nHeures += 1
  nMinutes -= 60
endif
RETURN "" if nMinutes > 59 .or. nMinutes < 0
RETURN ltrim(str(nHeures)) + ":" + strtran( str(nMinutes,2), " ", "0" )

**
** TimeSubt()
**
** dur‚e c1 - dur‚e c2
**
FUNCTION TimeSubt(c1,c2)
local cTime
local nHeures
local nMinutes
RETURN c1 if empty(c2)
c2 := ltrim(c2)
if empty(c1)
  if left(c2,1) == "-"
    RETURN substr(c2,2)
  else
    RETURN "-" + c2
  endif
endif
c1 := ltrim(c1)
nHeures  := val(left(c1,len(c1)-3)) - val(left(c2,len(c2)-3))
nMinutes := val(right(c1,2)) - val(right(c2,2))
if nMinutes < 0
  nHeures -= 1
  nMinutes += 60
endif
RETURN "*****" if nMinutes > 59 .or. nMinutes < 0
RETURN ltrim(str(nHeures)) + ":" + strtran( str(nMinutes,2), " ", "0" )


**
** T2Min()
**
FUNCTION T2Min(c1)
local nHeures
local nMinutes
local lMinus := .f.
if empty(c1) ; RETURN 0 ; endif
c1 := alltrim(c1)
if left(c1,1) == "-"
  lMinus := .t.
  c1 := substr(c1,2)
endif
nHeures  := val(left(c1,len(c1)-3))
nMinutes := val(right(c1,2))
RETURN 0 if nMinutes > 59 .or. nMinutes < 0
RETURN iif(lMinus,-1,1) * (nMinutes + (nHeures * 60))

FUNCTION downint(n)
RETURN int(n) if n > 0
RETURN n if int(n) == n
RETURN int(n) - 1


**
** t2Hours()
** t2hours("-1:30") returned -0.5
**
FUNCTION t2Hours(cTime)
local nHeures
local nMinutes
local lMinus := .f.
RETURN 0 if empty(cTime)
cTime := alltrim(cTime)
if left(cTime,1) == "-"
  lMinus := .t.
  cTime := substr(cTime,2)
endif
nHeures  := val(substr(cTime,1,len(cTime)-3))
nMinutes := val(right(cTime,2))
RETURN 0 if nMinutes > 59 .or. nMinutes < 0
// RETURN nHeures - (nMinutes / 60) if nHeures < 0
RETURN iif(lMinus,-1,1) * (nHeures + (nMinutes / 60))


**
** min2t()
**
FUNCTION min2t(nMinutes)
local lMinus := (nMinutes < 0)
local nHeures
nMinutes := abs(nMinutes)
nHeures := int(nMinutes/60)
nMinutes -= (nHeures * 60)
RETURN iif(lMinus,"-","") + ntrim0(nHeures) + ":" + strtran(str(nMinutes,2)," ","0")

**
** h2Time()
**
**
FUNCTION h2time(nHours,nLen)
local s
local nMinutes
local lMinus := (nHours < 0)
nHours := abs(nHours)
nMinutes := round( (nHours-int(nHours)) * 60, 0 )
nHours := int(nHours)
if nMinutes > 59
  // not very beautyful, but TIM gave 3:60 as a valid time...
  nHours += 1
  nMinutes -= 60
endif
s := ntrim(nHours) + ":" + strtran( str(nMinutes,2), " ", "0" )
if lMinus
  s := "-" + s
endif
default nLen to 5
RETURN repl("*",nLen) if len(s) > nLen
RETURN padl(s,nLen)

FUNCTION FirstOfYear(d) ; RETURN ntod(year(d),1,1)
FUNCTION LastOfYear(d) ; RETURN ntod(year(d)+1,1,1) - 1


FUNCTION GetQte(x,cFmt)
RETURN GetTime(x,.t.) if cFmt == ":"
RETURN GetNum(x,val(cFmt))

FUNCTION GetTime(x,lDuration)
/**
 Formatter for a time field.
 If len(x) is 5, then it is formatted as a daytime indication with
 leading "0" (ex.: 01:30 o'clock), otherwise it is formatted as a
 duration without leading "0" (ex.: 1:30 hours). You can force it to
 return a duration also when len(x) is 5 by specifying lDuration .t.

**/
local nLen
local nHours
local nMinutes
local lMinus := .f.
local a
RETURN x if empty(x)
nLen := len(x)
x := alltrim(x)
if left(x,1)=="-"
  x := substr(x,2)
  lMinus := .t.
endif
// x := strtran(x,":")
// x := strtran(x,".")
// x := strtran(x,",")
x := strtran(x,":",",")
x := strtran(x,".",",")
if "," $ x
  a := split(x,",")
  if len(a) == 2
    nHours := val(a[1])
    nMinutes := val(a[2])
    if nMinutes < 6 .and. len(a[2]) == 1
      nMinutes := nMinutes * 10
    endif
    x := NIL
  else
    x := strtran(x,",")
  endif
endif
if x != NIL
  if len(x) <= 2
    nHours := val(x)
    nMinutes := 0
  elseif len(x) == 3
    nHours := val(left(x,1))
    nMinutes := val(right(x,2))
  else
    nHours := val(left(x,len(x)-2))
    nMinutes := val(right(x,2))
  endif
endif
if lMinus
  RETURN padl("-"+ntrim(nHours),nLen-3) + ":" + strtran(str(nMinutes,2)," ","0")
elseif nLen == 5 .and. lDuration != .t.
  RETURN padl(ntrim(nHours),nLen-3,"0") + ":" + strtran(str(nMinutes,2)," ","0")
endif
RETURN str(nHours,nLen-3,0) + ":" + strtran(str(nMinutes,2)," ","0")

**
** Convertir Quantit‚ en Num‚rique
**
FUNCTION qton(cVal)
local nVal := 0
// local lSave := SetBreakTrap()
RETURN 0 if empty(cVal)
RETURN t2Hours(trim(cVal)) if ":" $ cVal
if "%" $ cVal
  RETURN val(strtran(cVal,"%")) / 100
endif
RETURN val(cVal)
// 20000928
// nVal := xparse(cVal)
// RETURN 0 if valtype(nVal) != "N"
// RETURN nVal

* SetBreakTrap(.t.)
* begin sequence
*   nVal := &cVal
* * recover using e
* end sequence
* SetBreakTrap(lSave)
*RETURN nVal
** RETURN &cVal if valtype(cVal) == "N" // [960621] statt val()
** RETURN 0 // [960621] statt val()

FUNCTION ntoq1(nVal,cFmt,nLen)
default nLen to LenQte()
RETURN space(nLen) if nVal == 0
RETURN ntoq(nVal,cFmt,nLen)

**
** convert numeric value do "internal" representation
**
FUNCTION ntoq(nVal,cFmt,nLen)
local nDec
local cReturn
default nLen to LenQte()
RETURN h2time(nVal,nLen) if cFmt == ":"
nDec := val(cFmt)
RETURN str(nVal,nLen) if nDec == 0
**
** Jetzt kommt es: die automatische Nachkommastellenreduzierung bei
** Overflow einer Mengenangabe. Besser etwas Pr„zision verlieren
** als den gesamten Wert...!
**
cReturn := str(nVal,nLen,nDec)
do while left(cReturn,1) == "*" .and. nDec > 0
  nDec--
  cReturn := str(nVal,nLen,nDec)
enddo
RETURN cReturn

FUNCTION Age(dBirth,dToday)
local d
local nAge
default dToday to UserDate()
nAge := year(dToday) - year(dBirth)
d := ntod(year(dToday),month(dBirth),day(dBirth)) // geburtstag dieses jahr
if d > dToday
  nAge--
endif
RETURN nAge


#ifndef __XHARBOUR__

FUNCTION stod(cDate)
local nYear := val(left(cDate,4))
local nMonth := val(substr(cDate,5,2))
local nDay := val(right(cDate,2))
RETURN ntod(nYear,nMonth,nDay)

#endif