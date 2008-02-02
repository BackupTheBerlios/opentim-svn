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

* FUNCTION nText(nZahl,langue, lFull,nMaxDecPos)
FUNCTION nText(cZahl,langue, lFull)
local nPos
local cText
if valtype(cZahl) != "C"
  raise("nText() : " + utos(cZahl) + " must be CHAR")
endif
cZahl := alltrim(cZahl)
if (nPos := at(".",cZahl)) == 0
  cText := nTextDecPos(val(cZahl),langue, lFull)
else
  cText := nTextDecPos(val(left(cZahl,nPos-1)),langue, lFull)
  if langue == "F"
    cText += " virgule "
  elseif langue == "E"
    cText += " comma "
  else
    cText += " Komma "
  endif
  cZahl := substr(cZahl,nPos+1)
  do while left(cZahl,1) == "0"
    cText += nTextDecPos(0,langue,lFull) + " "
    cZahl := substr(cZahl,2)
  enddo
  cText += nTextDecPos(val(cZahl),langue,lFull)
endif
RETURN cText


FUNCTION nTextDecPos(nZahl,langue, lFull)
local i
default lFull to .t.
default langue to TplLang()
if lFull
  return FullTextF(nZahl) if langue == "F"
  return FullTextD(nZahl) if langue == "D"
  return FullTextN(nZahl) if langue == "N"
else
  return nTextF(nZahl) if langue == "F"
  return nTextD(nZahl) if langue == "D"
  return nTextD(nZahl) if langue == "N"
endif
return "***"

*
*
*
FUNCTION FullTextD(nZahl,lFull)
local cZahl,result,teil1,teil2,teil3
cZahl = str(nZahl,9)
cZahl = strtran(cZahl," ","0")   && (vereinfacht die Tests)
result = ""
teil1 = subs(cZahl,1,3)
teil2 = subs(cZahl,4,3)
teil3 = subs(cZahl,7,3)
if teil1 <> "000"
  result = n3TextD(teil1)
  if teil1 = "001"
    result = result + "e Million "
  else
    result = result + " Millionen "
  endi
endi
if teil2 <> "000"
  result = result + n3TextD(teil2) + "tausend"
endi
if teil3 <> "000"
  if teil3 <= "009" .and. .not. empty(result)
    result = result + " und "
  endif
  result = result + n3TextD(teil3)
endi
if empty(result)
  result = "Null"
endi
retu result


FUNCTION n3TextD (cZahl)
priv pos1,pos2,pos3,result
pos1=subs(cZahl,1,1)   && Hunderter
pos2=subs(cZahl,2,1)   && Zehner
pos3=subs(cZahl,3,1)   && Einer
result = n1TextD(pos1)
if .not.empty(result)
  result = result + "hundert"
endi
retu result + n2TextD(pos2+pos3)


FUNCTION n2TextD(cZahl)
* Zuerst ein paar Ausnahmen eliminieren...
do case
  case cZahl="11"
    retu "elf"
  case cZahl="12"
    retu "zwîlf"
  case cZahl="16"
    retu "sechzehn"  && nicht 'sechszehn' !
  case cZahl="17"
    retu "siebzehn"  && nicht 'siebenzehn' !
endc
priv pos1,pos2,result
pos1=subs(cZahl,1,1)   && Zehner
pos2=subs(cZahl,2,1)   && Einer
do case
  case pos1 = "0"
    result = ""
  case pos1 = "1"
    result = "zehn"
  case pos1 = "2"
    result = "zwanzig"
  case pos1 = "3"
    result = "drei·ig"
  case pos1 = "4"
    result = "vierzig"
  case pos1 = "5"
    result = "fÅnfzig"
  case pos1 = "6"
    result = "sechzig"
  case pos1 = "7"
    result = "siebzig"
  case pos1 = "8"
    result = "achtzig"
  case pos1 = "9"
    result = "neunzig"
  othe
    result = "?"
endc
if pos2 = "0"
  retu result
endi
if pos1 > "1"
  result = "und" + result
endi
result = n1TextD(pos2) + result
retu result


FUNCTION n1TextD(cZahl)
local result
do case
  case cZahl = "0"
    result = ""
  case cZahl = "1"
    result = "ein"
  case cZahl = "2"
    result = "zwei"
  case cZahl = "3"
    result = "drei"
  case cZahl = "4"
    result = "vier"
  case cZahl = "5"
    result = "fÅnf"
  case cZahl = "6"
    result = "sechs"
  case cZahl = "7"
    result = "sieben"
  case cZahl = "8"
    result = "acht"
  case cZahl = "9"
    result = "neun"
  othe
    result = "?"
endc
retu result




*
*
*
FUNCTION FullTextN(nZahl,lFull)
local result := ""
local cZahl := strtran(str(nZahl,9)," ","0")   && (vereinfacht die Tests)
local teil1 := subs(cZahl,1,3)
local teil2 := subs(cZahl,4,3)
local teil3 := subs(cZahl,7,3)
if teil1 <> "000"
  result = n3TextN(teil1)
  if teil1 = "001"
    result = result + " millioen "
  else
    result = result + " millioenen "
  endi
endi
if teil2 <> "000"
  result = result + n3TextN(teil2) + "duizend"
endi
if teil3 <> "000"
  if teil3 <= "009" .and. .not. empty(result)
    result = result + " en "
  endif
  result = result + n3TextN(teil3)
endi
if empty(result)
  result = "Null"
endi
retu result


FUNCTION n3TextN(cZahl)
priv pos1,pos2,pos3,result
pos1=subs(cZahl,1,1)   && Hunderter
pos2=subs(cZahl,2,1)   && Zehner
pos3=subs(cZahl,3,1)   && Einer
result = n1TextN(pos1)
if .not.empty(result)
  result = result + "honderd"
endi
retu result + n2TextN(pos2+pos3)


FUNCTION n2TextN(cZahl)
local pos1,pos2,result
* Zuerst ein paar Ausnahmen eliminieren...
RETURN "elf" if cZahl == "11"
RETURN "twaalf" if cZahl == "12"
RETURN "dertien" if cZahl == "12"
pos1=subs(cZahl,1,1)   && Zehner
pos2=subs(cZahl,2,1)   && Einer
do case
  case pos1 = "0"
    result = ""
  case pos1 = "1"
    result = "tien"
  case pos1 = "2"
    result = "twintig"
  case pos1 = "3"
    result = "dertig"
  case pos1 = "4"
    result = "veertig"
  case pos1 = "5"
    result = "fijftig"
  case pos1 = "6"
    result = "zestig"
  case pos1 = "7"
    result = "zeventig"
  case pos1 = "8"
    result = "tachtig"
  case pos1 = "9"
    result = "negentig"
  othe
    result = "?"
endc
RETURN result if pos2 == "0"
if pos1 > "1"
  result = "en" + result
endi
result = n1TextN(pos2) + result
retu result


FUNCTION n1TextN(cZahl)
local result
do case
  case cZahl = "0"
    result = ""
  case cZahl = "1"
    result = "een"
  case cZahl = "2"
    result = "twee"
  case cZahl = "3"
    result = "drie"
  case cZahl = "4"
    result = "vier"
  case cZahl = "5"
    result = "vijf"
  case cZahl = "6"
    result = "zes"
  case cZahl = "7"
    result = "zeven"
  case cZahl = "8"
    result = "acht"
  case cZahl = "9"
    result = "negen"
  othe
    result = "?"
endc
retu result




*
*
*
FUNCTION FullTextF(nZahl,lFull)
local cZahl,result,teil1,teil2,teil3
cZahl = str(nZahl,9)
cZahl = strtran(cZahl," ","0")   && (vereinfacht die Tests)
result = ""
teil1 = subs(cZahl,1,3)
teil2 = subs(cZahl,4,3)
teil3 = subs(cZahl,7,3)
if teil1 <> "000"
  result = n3TextF(teil1)
  if teil1 = "001"
    result = result + " million, "
  else
    result = result + " millions, "
  endi
endi
if teil2 <> "000"
  if teil2 = "001"
    result = result + " mille "
  else
    result = result + n3TextF(teil2) + " mille "
  endif
endi
if teil3 <> "000"
  *if teil3 <= "009" .and. .not.empty(result)
  *  result = result + " et "
  *endi
  result = result + n3TextF(teil3)
endi
if empty(result)
  result = "zÇro"
endi
retu result


FUNCTION n3TextF (cZahl)
local pos1,pos2,pos3,result
pos1=subs(cZahl,1,1)   && Hunderter
pos2=subs(cZahl,2,1)   && Zehner
pos3=subs(cZahl,3,1)   && Einer
if pos1 == "1"
  result = "cent "
else
  result = n1TextF(pos1)
  if .not.empty(result)
    result = result + " cent "
  endi
endi
retu result + n2TextF(pos2+pos3)


FUNCTION n2TextF(cZahl)
local pos1,pos2,result
* Zuerst ein paar Ausnahmen eliminieren...
do case
  case cZahl="11"
    retu "onze"
  case cZahl="12"
    retu "douze"
  case cZahl="13"
    retu "treize"
  case cZahl="14"
    retu "quatorze"
  case cZahl="15"
    retu "quinze"
  case cZahl="16"
    retu "seize"
*  case cZahl="17"
*    retu "dix-sept"
*  case cZahl="18"
*    retu "dix-huit"
*  case cZahl="19"
*    retu "dix-neuf"
endc
pos1=subs(cZahl,1,1)   && Zehner
pos2=subs(cZahl,2,1)   && Einer
do case
  case pos1 = "0"
    result = ""
  case pos1 = "1"
    result = "dix"
  case pos1 = "2"
    result = "vingt"
  case pos1 = "3"
    result = "trente"
  case pos1 = "4"
    result = "quarante"
  case pos1 = "5"
    result = "cinquante"
  case pos1 = "6"
    result = "soixante"
  case pos1 = "7"
    result = "septante"
  case pos1 = "8"
    result = "quatre-vingt"
  case pos1 = "9"
    result = "nonante"
  othe
    result = "?"
endc
if pos2 = "0"
  retu result
endi
if !empty(result)
  if pos2 = "1"
    result += " et "
  else
    result += "-"
  endi
endi
result += n1TextF(pos2)
retu result


FUNCTION n1TextF(cZahl)
local result
do case
  case cZahl = "0"
    result = ""
  case cZahl = "1"
    result = "un"
  case cZahl = "2"
    result = "deux"
  case cZahl = "3"
    result = "trois"
  case cZahl = "4"
    result = "quatre"
  case cZahl = "5"
    result = "cinq"
  case cZahl = "6"
    result = "six"
  case cZahl = "7"
    result = "sept"
  case cZahl = "8"
    result = "huit"
  case cZahl = "9"
    result = "neuf"
  othe
    result = "?"
endc
retu result

FUNCTION nTextD(nZahl)
local cZahl := ntrim(int(nZahl))
local i
local result := ""
for i := 1 to len(cZahl)
  if substr(cZahl,i,1) == "0"
    result += "Null"
  elseif substr(cZahl,i,1) == "1"
    result += "Eins"
  elseif substr(cZahl,i,1) == "2"
    result += "Zwei"
  elseif substr(cZahl,i,1) == "3"
    result += "Drei"
  elseif substr(cZahl,i,1) == "4"
    result += "Vier"
  elseif substr(cZahl,i,1) == "5"
    result += "FÅnf"
  elseif substr(cZahl,i,1) == "6"
    result += "Sechs"
  elseif substr(cZahl,i,1) == "7"
    result += "Sieben"
  elseif substr(cZahl,i,1) == "8"
    result += "Acht"
  elseif substr(cZahl,i,1) == "9"
    result += "Neun"
  endif
  if i < len(cZahl)
    result += " "
  endif
next i
retu result




FUNCTION nTextF(nZahl)
local cZahl := ntrim(int(nZahl))
local i
local result := ""
for i := 1 to len(cZahl)
  if substr(cZahl,i,1) == "0"
    result += "ZÇro"
  elseif substr(cZahl,i,1) == "1"
    result += "Un"
  elseif substr(cZahl,i,1) == "2"
    result += "Deux"
  elseif substr(cZahl,i,1) == "3"
    result += "Trois"
  elseif substr(cZahl,i,1) == "4"
    result += "Quatre"
  elseif substr(cZahl,i,1) == "5"
    result += "Cinq"
  elseif substr(cZahl,i,1) == "6"
    result += "Six"
  elseif substr(cZahl,i,1) == "7"
    result += "Sept"
  elseif substr(cZahl,i,1) == "8"
    result += "Huit"
  elseif substr(cZahl,i,1) == "9"
    result += "Neuf"
  endif
  if i < len(cZahl)
    result += " "
  endif
next i
retu result



FUNCTION DecPos(n,nMax)
local nDecPos := 0
default nMax to 3
do while nDecPos < nMax
  RETURN nDecPos if round(n,nDecPos) == n
  nDecPos++
enddo
RETURN nMax




