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

*#ifdef LG_FRENCH
*  #define MSG005  "Impossible d'ouvrir "
*#else
*  #define MSG005  "Fehler beim Lesen von "
*#endif


static slStepByStep := .f.

static saMemoStack // := {}

static saDlmPath
static saDlmRoots


#define MS_FILENAME  1
#define MS_MEMO      2
#define MS_POS       3
#define MS_STATIC    4
* #define MS_PREVIOUS  5
#define MS_LINE      5
#define MS_IFSTACK   6
// #define MS_PATH      7
#define MS_ALEN      6

FUNCTION DlmInit()
saMemoStack := {}
saDlmPath := {}
saDlmRoots := { AppRoot()+"\DLM" }
RETURN .t.


FUNCTION LoadDlm(cDlmName)
local nPos
* local c := DlmRoot()+"\"+cDlmName
local c, i
for i := 1 to len(saDlmRoots)
  c := saDlmRoots[i]+"\"+cDlmName
  if PathExist(c)
    AddDlmDir(c)
    if (nPos := rat("\",cDlmName)) != 0
      cDlmName := substr(cDlmName,nPos+1)
    endif
    RETURN IniLoad(AppIniCmds(), c + "\" + cDlmName + ".DLM", .t. )
  endif
next i
RETURN !SetMsg(cDlmName+" : no such DLM directory")

FUNCTION HasDlm(cIdDlm)
* local cDlmDir := DlmRoot()+"\"+cIdDlm
local i
for i := 1 to len(saDlmPath)
  RETURN .t. if right(saDlmPath[i],len(cIdDlm)) == cIdDlm
next i
RETURN .f.

FUNCTION SetDlmRoots(c)
saDlmRoots := split(c,";")
RETURN .t.

STATIC FUNCTION AddDlmDir(cDll)
aadd(saDlmPath,NIL)
ains(saDlmPath,1)
saDlmPath[1] := cDll
* aadd(saDlmPath,cDll)
RETURN .t.

FUNCTION GetDlmPath(cFilename)
local cPath
local i
* RETURN cFilename if "\" $ cFilename .and. file(cFilename)
RETURN cFilename if substr(cFilename,2,1)==":" .and. fexist(cFilename)
RETURN cFilename if left(cFilename,1)=="." .and. fexist(cFilename)
// ab hier nur noch kurze Dateinamen m”glich
// denn z.B. HasDlm("ETC\WWW") soll funktionieren
cPath := DbPath() + "\" + cFilename
RETURN cPath if file(cPath)
for i := 1 to len(saDlmPath)
  // cPath := AppPath() + "\" + saDlmPath[i] + "\" + cFilename
  cPath := saDlmPath[i] + "\" + cFilename
  RETURN cPath if file(cPath)
next i
RETURN NIL // cFilename

FUNCTION GetDlmDir(cWildCard)
local aDir1 := directory(DbPath() + "\" + cWildCard)
local aDir2
local a := {}
local i
local j
for i := 1 to len(aDir1)
  aadd(a,aDir1[i])
next i
for j := 1 to len(saDlmPath)
  // aDir2 := directory(AppPath() + "\" + saDlmPath[j] + "\" + cWildCard)
  aDir2 := directory(saDlmPath[j] + "\" + cWildCard)
  for i := 1 to len(aDir2)
    aaddRow(a,aDir2[i],F_NAME)
    * aadd(a,aDir2[i])
    * for k := 1 to len(a)

    * DictAddItem(a,aDir2[i])
  next j
next j
RETURN a


FUNCTION aaddRow(a,row,nKey)
local i
default nKey to 1
for i := 1 to len(a)
  RETURN .f. if a[i][nKey] == row[nKey]
next i
aadd(a,row)
RETURN .t.



FUNCTION mopen(cFilename,lStatic)
local a
local c
local i
local fd
local cDllPath
default lStatic to .f.
for i := 1 to len(saMemoStack)
  if saMemoStack[i][MS_FILENAME] == cFilename
    if saMemoStack[i][MS_POS] < 0
      saMemoStack[i][MS_POS] := 1
      saMemoStack[i][MS_LINE] := 0
      saMemoStack[i][MS_IFSTACK] := {.t.}
      // LogDebug("mopen("+cFilename+") : reuse #static file")
      RETURN i
    else
      * Warning(cFilename + " : file is already open !")
      * RETURN NIL
      LogDebug("mopen("+cFilename+") : (file is already open)")
    endif
  endif
next i
cDllPath := GetDlmPath(cFilename)
MsgVerbose("mopen() : " + cDllPath)
if cDllPath == NIL
  SetMsg(cFilename + MsgFileExist() )
  RETURN NIL
endif
c := memoread(cDllPath)
if len(c) == 0
  SetMsg(cDllPath + " : file is empty.")
  RETURN NIL
endif
RETURN NIL if ! ChkMemoLen(c)
* try to find an empty file handle
for i := 1 to len(saMemoStack)
  if saMemoStack[i][MS_FILENAME] == NIL
    fd := i
    exit
  endif
next i
if fd == NIL
  // create a new file handle
  a := array(MS_ALEN)
  aadd(saMemoStack, a)
  fd := len(saMemoStack)
  // LogDebug("mopen("+cFilename+") : new file handle is " +ntrim(fd) )
else
  // reuse file handle
  a := saMemoStack[fd]
  // LogDebug("mopen("+cFilename+") : reuse file handle " +ntrim(fd) )
endif
a[MS_FILENAME] := cFilename
a[MS_MEMO] := c
a[MS_POS] := 1
a[MS_LINE] := 0
a[MS_IFSTACK] := {.t.}
a[MS_STATIC] := lStatic
* a[MS_PREVIOUS] := snMemoCurrent
* snMemoCurrent := fd
RETURN fd

FUNCTION mgetline(fd)
local nPos
local nMemoPos := saMemoStack[fd][MS_POS]
local cMemo := saMemoStack[fd][MS_MEMO]
local cLine
RETURN NIL if nMemoPos < 0
if (nPos := at(CR_LF,substr(cMemo,nMemoPos))) == 0
  cLine := substr(cMemo,nMemoPos)
  nMemoPos := -1
else
  cLine := substr(cMemo,nMemoPos,nPos-1)
  nMemoPos += nPos + 1
endif
saMemoStack[fd][MS_POS] := nMemoPos
saMemoStack[fd][MS_LINE] += 1
RETURN cLine

FUNCTION mline(fd)
RETURN saMemoStack[fd][MS_LINE]

FUNCTION mrawmemo(fd)
RETURN saMemoStack[fd][MS_MEMO] // used for mparse()

FUNCTION mreadline(fd)
local cLine := mgetline(fd)
local c
local a
RETURN NIL if cLine == NIL
do while .t.
  do while right(cLine,1) == "\"
    if right(cLine,2) == "\\" // 19990713 : escaped "\"
      cLine := left(cLine,len(cLine)-1)
      exit
    elseif (c := mgetline(fd)) == NIL
      exit
    else
      cLine := left(cLine,len(cLine)-1) + ltrim(c)
    endif
  enddo
  if cLine == "#static"
    saMemoStack[fd][MS_STATIC] := .t.
    RETURN NIL if (cLine := mgetline(fd)) == NIL
  elseif left(cLine,6) == "#exec "
    if atail(saMemoStack[fd][MS_IFSTACK])
      RETURN NIL if ! & (substr(cLine,7))
      * 20030312 RETURN NIL if ! xparse(substr(cLine,7))
    endif
    RETURN NIL if (cLine := mgetline(fd)) == NIL
  elseif left(cLine,4) == "#if "
    if atail(saMemoStack[fd][MS_IFSTACK])
      aadd(saMemoStack[fd][MS_IFSTACK],xparse(substr(cLine,5)))
    else
      aadd(saMemoStack[fd][MS_IFSTACK],.f.)
    endif
    RETURN NIL if (cLine := mgetline(fd)) == NIL
  elseif left(cLine,5) == "#else"
    a := saMemoStack[fd][MS_IFSTACK]
    a[len(a)] := ! atail(a)
    * saMemoStack[fd][MS_IFSTACK][len(saMemoStack[fd][MS_IFSTACK])] ;
    *   := ! atail(saMemoStack[fd][MS_IFSTACK][n]
    RETURN NIL if (cLine := mgetline(fd)) == NIL
  elseif left(cLine,6) == "#endif"
    if len(saMemoStack[fd][MS_IFSTACK]) > 1
      asize(saMemoStack[fd][MS_IFSTACK],len(saMemoStack[fd][MS_IFSTACK])-1)
    else
      Warning("#endif : stack underflow")
    endif
    RETURN NIL if (cLine := mgetline(fd)) == NIL
  else
    if atail(saMemoStack[fd][MS_IFSTACK])
      RETURN cLine
    else
      RETURN NIL if (cLine := mgetline(fd)) == NIL
    endif
  endif
enddo
RETURN NIL // never reached

**
FUNCTION mclose(fd)
* #ifdef DEF_DEBUG
  LogDebug("mclose("+saMemoStack[fd][MS_FILENAME]+")")
* #endif DEF_DEBUG
* snMemoCurrent := saMemoStack[fd][MS_PREVIOUS]
if saMemoStack[fd][MS_STATIC]
  saMemoStack[fd][MS_POS] := -1
  RETURN NIL
endif
saMemoStack[fd][MS_MEMO] := NIL
saMemoStack[fd][MS_FILENAME] := NIL
RETURN NIL



FUNCTION KillMemoStack
local i := 1
// saMemoStack := {}
do while i <= len(saMemoStack)
  if saMemoStack[i][MS_POS]==-1 .or. saMemoStack[i][MS_FILENAME]==NIL
    adel(saMemoStack,i)
    asize(saMemoStack,len(saMemoStack)-1)
  else
    i += 1
  endif
enddo
if len(saMemoStack) > 0
  browse array saMemoStack ;
         using {|x|padr(x[MS_FILENAME],12)+padr(x[MS_MEMO],40)} ;
         width 76 ;
         title (ntrim(len(saMemoStack))+" Memo-Dateien sind weiterhin aktiv")
  // Warning("len(saMemoStack)=="+ntrim(len(saMemoStack)))
endif
RETURN .t.


* FUNCTION SetMemoStatic
* RETURN .f.

FUNCTION MemoConsole
local i
local cLine
SendConsole("saMemoStack : ")
for i := 1 to len(saMemoStack)
  cLine := ntrim(i)
  cLine += " : "
  if saMemoStack[i][MS_FILENAME] == NIL
    cLine += "NIL"
  else
    cLine += saMemoStack[i][MS_FILENAME]
    cLine += ntrim(saMemoStack[i][MS_POS])
    if saMemoStack[i][MS_STATIC]
      cLine += " (static)"
    endif
  endif
  SendConsole(cLine)
next i
RETURN .t.


FUNCTION mfilename(fd)
RETURN saMemoStack[fd][MS_FILENAME]


**
**
**
FUNCTION FileExec(cFilename,p)
local cAnswer
local lOkay := .t.
local nCut
local cLine
local fd := mopen(cFileName)
local saveArgv
local lSetBatch := SetBatch()
if fd == NIL
  Warning(SetMsg())
  RETURN .f.
endif
MsgVerbose("Executing " + mfilename(fd))
public ARGV
saveArgv := argv
ARGV := p
do while lOkay .and. (cLine := mreadline(fd)) != NIL
  if (nCut := at("//",cLine)) != 0
    cLine := left(cLine,nCut-1)
  endif
  if ! empty(cLine)
    #ifdef DEF_DEBUG
      rpt_write("  "+cLine)
    #endif
    if slStepByStep
      cAnswer := Decide("YANQ",;
        cLine+" : do it ? (Yes, No, Always, Quit)",NIL,;
        mfilename(fd)+":"+ntrim(mline(fd)))
      if cAnswer == "A"
        slStepByStep := .f.
      elseif cAnswer == "N"
        loop
      elseif empty(cAnswer) .or. cAnswer == "Q"
        lOkay := .f.
        exit
      elseif cAnswer != "Y"
        raise("invalid answer")
      endif
    endif
    if upper(left(cLine,7)) == "RETURN "
      cLine := substr(cLine,8)
      if (nCut := at(" IF ",upper(cLine))) > 0
        if xparse(substr(cLine,nCut+4))
          lOkay := xparse(left(cLine,nCut-1))
          exit
        endif
      else
        lOkay := xparse(cLine)
        exit
      endif
    else
      lOkay := xparse(cLine)
      if (lOkay == NIL)
        SendConsole("xparse syntax error : " + cLine)
        lOkay := Confirm( ;
          cFileName + " : syntax error in line " + ntrim(mline(fd)) ;
          + ":" + CR_LF ;
          + SetMsg(),;
          MsgContinue(),MSG_NO ;
        )
      endif
    endif
  endif
enddo
mclose(fd)
ARGV = saveArgv
* MsgDisplay("")
#ifdef DEF_DEBUG
  rpt_write(cFilename + " returns " + utos(lOkay))
#endif
SetBatch(lSetBatch)
RETURN lOkay



FUNCTION DlmMemoRead(cFilename)
local cDllPath := GetDlmPath(cFilename)
RETURN "" if cDllPath == NIL
//  SetMsg(cFilename + MsgFileExist() )
RETURN memoread(cDllPath)


FUNCTION StepByStep
slStepByStep := .t.
RETURN .t.

