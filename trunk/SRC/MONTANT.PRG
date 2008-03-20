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

static snDec    :=  0
static snLenMont  := 10 // am Bildschirm
static snLenMntF  := 10 // formatiert ausgedruckt
static scSetSolde := "1"
static slZero := .t.
static slNo00 := .f.

FUNCTION ntom(nVal,nDec,nLenMont)
default nLenMont to snLenMont
default nDec to snDec
RETURN space(nLenMont) if abs(nVal) < Tolerance(nDec)
RETURN _str(nVal,nLenMont,nDec)

FUNCTION ntom0(nVal,nDec,nLenMont)
default nLenMont to snLenMont
default nDec to snDec
RETURN _str(nVal,nLenMont,nDec)

STATIC FUNCTION _str(nVal,nWidth,nDec)
local r := str(nVal,nWidth,nDec)
do while left(r,1) == "*" .and. nDec > 0 ;
  .and. right(str(nVal,nWidth+nDec+1,nDec),1) == "0"
  nDec -= 1
  r := str(nVal,nWidth,nDec)
enddo
RETURN r

/**
  Wenn 0 Nachkommastellen : -> 0.5
  Wenn 2 Nachkommastellen : -> 0.005
**/
FUNCTION Tolerance(nDecPos)
RETURN 0.5 / (10 ** nDecPos)

** workaround for floating point numeric precision
FUNCTION is0(nMont)
RETURN abs(nMont) < Tolerance(snDec)



**
** ntomf() - Numeric to Montant (formatted)
**
FUNCTION ntomf(nVal,nDec,nWidth)
local cStr
local cPict
* local lMinus := (nVal < 0)
default nDec to snDec
default nWidth to snLenMntF
RETURN space(nWidth) if ! slZero .and. abs(nVal) < Tolerance(nDec)
cPict := "@R" + repl(" ###",int(nWidth/3)+1)
if nDec > 0
  cPict += "." + repl("#",nDec)
endif
cStr := ltrim(transform(abs(nVal),cPict))
cStr := strtran(cStr,".",",")
cStr := strtran(cStr," ",".")
* if lMinus
if nVal < 0 .and. abs(nVal) > Tolerance(nDec)
  cStr := "-" + cStr
endif
if slNo00 .and. right(cStr,3) == ",00"
  * cStr := left(cStr,len(cStr)-3)
  cStr := left(cStr,len(cStr)-2) + "-"
endif
if len(cStr) > nWidth
  cStr := strtran(cStr,".")
  if len(cStr) > nWidth
    cStr := repl("*",nWidth) // +cStr
    * Warning( ;
    *   cStr + " : Åbergro·er Betrag mit {set montant " + ;
    *   SetMntFormat() + "} !" ;
    * )
  endif
endif
RETURN padl(cStr,nWidth)

FUNCTION SetDecPos(nNew)
if nNew != NIL
  snDec := nNew
  RETURN .t.
endif
RETURN snDec

FUNCTION Solde(d,c,nDecPos)
RETURN solde2(d,c,nDecPos) if scSetSolde == "2"
RETURN solde1(d,c,nDecPos)

FUNCTION DcSolde(cDC,nSolde,nDecPos)
if nSolde < 0
  nSolde := - nSolde
  cDC := DcInvert(cDC)
endif
RETURN solde(nSolde,0,nDecPos) if cDC == DC_DEBIT
RETURN solde(0,nSolde,nDecPos)



FUNCTION solde1(d,c,nDecPos)
RETURN (ntomf(d - c,nDecPos) + " " + DC_DEBIT) if d > c
RETURN (ntomf(c - d,nDecPos) + "  ") if d == c
RETURN (ntomf(c - d,nDecPos) + " " + DC_CREDIT)

FUNCTION solde2(d,c,nDecPos)
if RptToCsv()
  RETURN val2csv("N",d - c,NIL,nDecPos) + csvsep() if d > c
  RETURN csvsep() + val2csv("N",c - d,NIL,nDecPos)
endif
RETURN ntomf(d - c,nDecPos) + space(snLenMntF + 1) if d > c
RETURN space(snLenMntF + 1) + ntomf(c - d,nDecPos)


FUNCTION saldo(n1,n2)
RETURN ntomf(n1 - n2) if n1 > n2
RETURN space(snLenMntF)

FUNCTION Remise(cPA,cPV)
local n := val(cPV) - val(cPA)
RETURN 100 * n / val(cPV)
// RETURN str(n,6,2) + "%"

FUNCTION Marge(nPA,nPV)
RETURN space(7) if nPA == 0
RETURN str(100 * (nPV - nPA) / nPA, 6, 2) + "%"

FUNCTION GetMont(cMont,nDecPos)
default nDecPos to snDec
RETURN GetNum(cMont,nDecPos,nDecPos)

FUNCTION SetLenMont(n)
snLenMont := n
RETURN .t.

FUNCTION LenMont ; RETURN snLenMont
FUNCTION LenMntF ; RETURN snLenMntF

FUNCTION LenSolde
RETURN 2 * snLenMntF + 1 if scSetSolde == "2"
RETURN snLenMntF + 2

FUNCTION SetMntFormat(cFormat)
local cReturn := ""
if cFormat == NIL
  if slZero
    cReturn += "Z"
  else
    cReturn += "S"
  endif
  if slNo00
    cReturn += "N"
  endif
  RETURN cReturn + ntrim(snLenMntF)
endif
cFormat := upper(cFormat)
if "N" $ cFormat
  cFormat := strtran(cFormat,"N")
  slNo00 := .T.
else
  slNo00 := .f.
endif
if "Z" $ cFormat
  slZero := .t.
  cFormat := strtran(cFormat,"Z")
elseif "S" $ cFormat
  cFormat := strtran(cFormat,"S")
  slZero := .f.
endif
snLenMntF := val(cFormat)
if snLenMntF == 0
  Warning( cFormat + " : invalid width setting")
  snLenMntF := 10
  RETURN .f.
endif
RETURN .t.

FUNCTION SetSolde(cFormat)
RETURN scSetSolde if cFormat == NIL
* if ! cFormat $ "12"
*   Warning( cFormat + " : invalid {set solde} !")
*   RETURN .f.
* endif
scSetSolde := cFormat
RETURN .t.

FUNCTION komma(cMont) ; RETURN strtran(cMont,".",",")

FUNCTION mton(cMont)
cMont := strtran(cMont,",",".")
RETURN val(cMont)

FUNCTION MntDecPos(cMont)
local nDec  := at(".",cMont)
if nDec != 0
  nDec  := len(cMont) - nDec
endif
RETURN nDec

FUNCTION SoldeD(nDebit,nCredit)
RETURN space(LenMntF()) if nDebit < nCredit
RETURN ntomf(nDebit-nCredit)

FUNCTION SoldeC(nDebit,nCredit)
RETURN space(LenMntF()) if nCredit < nDebit
RETURN ntomf(nCredit-nDebit)

FUNCTION DcInvert(cDC)
RETURN DC_DEBIT if cDC == DC_CREDIT
RETURN DC_CREDIT


