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

**
** fparse.exe, a successor for btp2bat.exe
** derived from TplParse(), 17.06.1998
**
#include "LIB.CH"
#include "error.ch"

static slBreakTrap := .f.
static slActive := .t.
static saVars := {}
static scProgramPath

/**********

 1.01 : 19980714 : SetBreakTrap()

**********/

REQUEST FILE

FUNCTION fparse(cInFiles,cOutExt,par1,par2)
* local cParam := p1 + " " + p2 + " " + p3 + " " + p4
local aDir := directory(cInFiles)
local i
local n := 0
? "FPARSE Version 1.01 (c) P.A.C. Systems Eupen"
if empty(cInFiles)
  ? "Syntax : FPARSE <input-files> <output-extension> [p1] [p2]"
  RETURN NIL
endif
if len(aDir) == 0
  ? cInFiles + " : no input file(s) found. Game over."
  RETURN NIL
endif
if empty(cOutExt)
  ? "No extension for output files specified. Game over."
  RETURN NIL
endif
default par1 to ""
public p1 := par1
default par2 to ""
public p2 := par2
ErrorBlock( {|e| MyError(e)} )
scProgramPath := ft_default() + ":\" + curdir()
for i := 1 to len(aDir)
  if ! DoParse(aDir[i][1],cOutExt)
    exit
  endif
  n++
next i
? ltrim(str(n)) + " files have been processed."
?
RETURN NIL


FUNCTION DoParse(cInFile,cOutExt)
local lOkay
local cOutFile := left(cInFile,rat(".",cInFile)) + cOutExt
local cMemo := memoread(cInFile)
local cMark1 := "{"
local cMark2 := "}"
local nPos1
local nPos2
local nLen
local cRetVal
local i,j
local cChar
local cOldChar
local cNewMemo := ""
if upper(cInFile) == upper(cOutFile)
  ? "input file same as output file."
  RETURN .f.
endif
if empty(cMemo)
  ? cInFile + " : could not read file or file is empty"
  RETURN .f.
endif
cMemo := strtran(cMemo,"\"+CR_LF) // seit [970327], sh. unten...
do while (nPos1 := at(cMark1,cMemo)) != 0
  **
  ** zun„chst wird das Stck bis *vor* den ersten "{" unver„ndert
  ** bernommen :
  **
  if slActive
    cNewMemo += left(cMemo,nPos1-1)
  endif
  cMemo := substr(cMemo,nPos1)
  **
  ** Jetzt muss ich die schlieáende "}" ausfindig machen. Das ist
  ** nicht unbedingt die n„chste. {}-Codes sollen ja erstens
  ** ineinandergeschachtelt sein drfen, und zweitens soll "\" als
  ** Escape-Zeichen dienen
  **
  nPos2 := 0         // nPos2 : Position des schliessenden "}"
                     // 0  : noch nicht gefunden
                     // -1 : sogar noch einen weiteren ”ffnenden "{"
                     //      gefunden (also den n„chsten schliessenden
                     //      nicht nehmen.
                     // > 0 : nPos2 enth„lt die gesuchte Position
  i := 2
  nLen := len(cMemo) // weil cMemo recht lang sein k”nnte...
                     // keine Beweise, ob das dadurch schneller geht.
  do while nPos2 <= 0 .and. i <= nLen
    cOldChar := cChar
    cChar := substr(cMemo,i,1)
    if cChar == cMark1 .and. cOldChar != "\"
      nPos2 --  // einen nesting-level rauf schalten
    elseif cChar == cMark2 .and. cOldChar != "\"
      nPos2++
      if nPos2 > 0
        nPos2 := i
        exit
      endif
    endif
    i++
  enddo
  if nPos2 == 0 // keine schliessende "}" gefunden...
    cRetVal := cMemo
    nPos2 := len(cMemo)
  else
    **
    ** nPos1 wird jetzt benutzt, um eventuelle Befehlsparameter zu
    ** identifizieren.
    cRetVal := NIL
    if substr(cMemo,2,4) == "#if "
      slActive := xparse(substr(cMemo,6,nPos2-6))
    elseif substr(cMemo,2,5) == "#else"
      slActive := ! slActive
    elseif substr(cMemo,2,6) == "#endif"
      slActive := .t.
    elseif substr(cMemo,2,8) == "#assert "
      // ? cOutFile + " : #assert " + substr(cMemo,10,nPos2-10)
      if (lOkay := xparse(substr(cMemo,10,nPos2-10))) == NIL
        ? cOutFile + " : #assert syntax error. Game over."
        RETURN .f.
      endif
      if ! lOkay
        ? cOutFile + " : the following condition failed :"
        ? "#assert " + substr(cMemo,10,nPos2-10)
        RETURN .f.
      endif
    elseif substr(cMemo,2,1) != "*"
      cRetVal := xparse(substr(cMemo,2,nPos2-2))
    endif
  endif
  cMemo := substr(cMemo,nPos2+1)
  if cRetVal == NIL
    if left(cMemo,2) == CR_LF
      cMemo := substr(cMemo,3)
    endif
  elseif slActive
    cNewMemo += cRetVal
  endif
enddo
if slActive
  cNewMemo += cMemo
endif
? cOutFile + "..."
memowrit(cOutFile,cNewMemo)
RETURN .t.

FUNCTION xparse(cExpr)
local u := NIL
local e
local lBreak := SetBreakTrap()
SetBreakTrap(.t.)
  begin sequence
    u := &cExpr
  recover using e
    ? cExpr + " : " + ErrorMessage(e)
    * u := cExpr + " : " + ErrorMessage(e)
  end sequence
SetBreakTrap(lBreak)
RETURN u

FUNCTION SetBreakTrap(l)
RETURN slBreakTrap if l == NIL
slBreakTrap := l
RETURN .t.



/***
*       MyError()
*/
STATIC FUNCTION MyError(e)
local cMemo
local i, cMessage, aOptions, nChoice
if ( e:genCode == EG_ZERODIV ) // by default, division by zero yields zero
  return (0)
endif
//
// for "too many files open" error, set NETERR() and subsystem default
* if ( e:genCode == EG_OPEN .and. e:osCode == 4 .and. e:canDefault )
*   SetMsg("Too many files open.")
*   NetErr(.t.)
*   RETURN (.f.)                                           // NOTE
* endif
//
// for network open error, set NETERR() and subsystem default
if ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )
  NetErr(.t.)
  RETURN (.f.)                                            // NOTE
endif
//
// for lock error during APPEND BLANK, set NETERR() and subsystem default
if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )
  NetErr(.t.)
  RETURN (.f.)                                           // NOTE
endif
//
// build error message
cMessage := ErrorMessage(e)
//
// build options array
if slBreakTrap
  break(e)
else
  aOptions := { MSG_QUIT }
endif
if (e:canRetry)
  AAdd(aOptions, MSG_RETRY)
endif
if (e:canDefault)
  AAdd(aOptions, MSG_DEFAULT)
endif
//
// put up alert box
//
nChoice := 0
while ( nChoice == 0 )
  if ( empty(e:osCode) )
    nChoice := Alert( cMessage, aOptions )
  else
    nChoice := Alert( cMessage + "; (DOS Error " ;
               + ntrim(e:osCode) + ")", aOptions )
  endif
  if ( nChoice == NIL )
    exit
  endif
enddo
//
if ! empty(e:osCode)
  cMessage += " (DOS Error " + ntrim(e:osCode) + ") "
endif
if ( !Empty(nChoice) )          // do as instructed
  if ( aOptions[nChoice] == MSG_RETRY )
    return (.t.)
  elseif ( aOptions[nChoice] == MSG_DEFAULT )
    return (.f.)
  endif
endif
//
// display message and traceback
i := 2
while ( !empty(ProcName(i)) )
  ? "Called from " + trim(ProcName(i)) + "(" + ntrim(procline(i)) + ")"
  i++
enddo
errorlevel(3)
quit
RETURN NIL // never reached

/***
*       ErrorMessage()
*/
FUNCTION ErrorMessage(e)
local cMessage
// start error message
cMessage := if( e:severity > ES_WARNING, "Error ", "Warning " )
// add subsystem name if available
if ( ValType(e:subSystem) == "C" )
  cMessage += e:subSystem()
else
  cMessage += "???"
endif
// add subsystem's error code if available
if ( ValType(e:subCode) == "N" )
  cMessage += ("/" + ntrim(e:subCode))
else
  cMessage += "/???"
endif
// add error description if available
if ( ValType(e:description) == "C" )
  cMessage += ("  " + e:description)
endif
// add either filename or operation
if ( !Empty(e:filename) )
  cMessage += (": " + e:filename)
elseif ( !Empty(e:operation) )
  cMessage += (": " + e:operation)
endif
RETURN (cMessage)


FUNCTION drive
RETURN left(scProgramPath,at(":",scProgramPath))

FUNCTION path
RETURN scProgramPath

FUNCTION AskValue(cId,cPrompt)
local i
local cValue
for i := 1 to len(saVars)
  if saVars[i][1] == cId
    RETURN saVars[i][2]
  endif
next i
accept cPrompt to cValue
aadd(saVars,{ cId, cValue })
RETURN cValue


