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

#ifdef DEF_UNITTEST

*static snFailures
*
*FUNCTION UnitTest()
*local a := {}
*local i
*local nTotFailures := 0
*
*aadd(a,"tc01()")
*
*open printer "LISTE" width 80 ;
*  TitBlock {|| ;
*    PrintHeader("Unit Tests" ) ;
*  }
*for i := 1 to len(a)
*  snFailures := 0
*  xparse(a[i])
*  if snFailures != 0
*    PrintLine(a[i]+" : " + ntrim(snFailures) + " failures.")
*    nTotFailures += snFailures
*  endif
*next i
*PrintLine(ntrim(len(a))+" tests. "+ntrim(nTotFailures)+" failures.")
*close printer
*RETURN .t.
*
*STATIC FUNCTION fail(msg)
*PrintLine(msg)
*snFailures++
*RETURN NIL

FUNCTION TstEqual(v1,v2)
local cMsg
RETURN .t. if v1 == v2
cMsg := utor(v1)+" != "+utor(v2)
if SetMsg() != NIL
  cMsg += " (" + SetMsg() + ")"
endif
RETURN ! SetMsg(cMsg)


FUNCTION RunTests() // cOutfile)
local a
local nCount := 0
local nFailures := 0
local aDir := GetDlmDir("*.tst")
local i
local lOkay := .t.
* #ifdef DEF_IE10
* local lIE10 := SetIE10()
* #endif
asort(aDir)
// open printer SetTplIni() width 120
open printer "LISTEX" width 120 ;
     preview SetPreview() ;
     range   SetRange() ;
     titblock {|| ;
       PrintHeader( "TIM Unit Tests" ) ;
     }
* SetDialog(.f.)
*#ifdef DEF_IE10
*  SetIE10(.f.)
*#endif
// Confirm("foo")
for i := 1 to len(aDir)
  a := TstExec(aDir[i][F_NAME])
  nFailures += a[2]
  nCount += a[3]
  if ! a[1]
    lOkay := .f.
    exit
  endif
next i
* #ifdef DEF_IE10
*   SetIE10(lIE10)
* #endif
PrintLine(;
  if(nFailures == 0,;
    "Successfully ran ",;
    ntrim(nFailures) + " failures during ") ;
  + ntrim(nCount) + " test cases in " ;
  + ntrim(len(aDir)) + " suites.")
close printer
* SetDialog(.t.)
RETURN lOkay


**
**
**
STATIC FUNCTION TstExec(cFilename)
local lOkay := .t.
local uReturn
local nCut
local cLine
local fd := mopen(cFilename)
local nCount := 0
local nFailures := 0
local cMsg
// cFilename += ".TST"
MsgDisplay("Running " + cFilename)
if fd == NIL
  Warning(SetMsg())
  RETURN .f.
endif
do while lOkay .and. (cLine := mreadline(fd)) != NIL
  if TaskInter() ; lOkay := .f. ; exit ; endif
  if (nCut := at("//",cLine)) != 0
    cLine := left(cLine,nCut-1)
  endif
  if ! empty(cLine)
    if left(cLine,9) == "#skip if "
      if xparse(substr(cLine,10))
        lOkay := .t.
        exit
      endif
    else
      nCount += 1
      MsgDisp2(ntrim(nCount))
      // rpt_write(cLine)
      uReturn := xparse(cLine)
      cMsg := NIL
      // Confirm(utos(lOkay))
      if uReturn == NIL
        cMsg := "syntax error  : " + SetMsg()
      elseif valtype(uReturn) != "L"
        cMsg := "invalid return value " + utos(uReturn)
      elseif !uReturn
        cMsg := "test failed : " + SetMsg()
      endif
      if cMsg != NIL
        nFailures += 1
        PrintLine(cFileName + " [" + ntrim(mline(fd)) + "] " + cLine+" :")
        PrintLine(space(len(cFilename)+1) + cMsg)
      endif
      SetMsg("")
    endif
  endif
enddo
mclose(fd)
RETURN { lOkay, nFailures, nCount }


FUNCTION tst20020917
local lOkay := .f.
local nBottom
open area oPar()
  go bottom
  if ddRecLock()
    // BOTTOM record is now locked!
    nBottom := recno()
    open area oPar()
      go top
      if ddRecLock()
        // TOP record is locked!
        unlock record
      else
        SetMsg("ddRecLock(2) failed()")
      endif
    close area
    // Gonna write to BOTTOM record !
    if nBottom != recno()
      SetMsg("recno() is different!")
    endif
    PAR->IdPar := PAR->IdPar
    lOkay := .t.  // success : BOTTOM record was still locked!
    unlock record
  else
    SetMsg("ddRecLock(1) failed()")
  endif
close area
RETURN lOkay

* FUNCTION HasUnitTest() ; RETURN .t.
*
* #else
*
* FUNCTION HasUnitTest() ; RETURN .f.

#endif DEF_UNITTEST

**
** fÅr Mengenangaben in VNL, und ACL :
**
FUNCTION qton1(cQte)
RETURN 1 if empty(cQte) .and. QteEmpty()
RETURN qton(cQte)


