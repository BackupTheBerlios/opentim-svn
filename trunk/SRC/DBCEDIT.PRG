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


FUNCTION DbcEdit(cWildcard,cPath,cTitle,lEdit,lPick)
local cFileName
default cWildcard to "*.DBC"
default lEdit to .t.
default lPick to .f.
do while (cFileName := FilePick(cWildcard,cPath,cTitle,NIL,cFilename)) != NIL
  if lPick
    RETURN left(cFileName,at(".",cFileName)-1)
  else
    FileEdit(cFileName,"DBCEDIT",lEdit)
  endif
enddo
if lPick
  RETURN NIL
endif
RETURN .t.


*FUNCTION DbcEdit(cWildcard,cPath,cTitle,lEdit,lPick)
*local aDir
*local a
*local i
*static snStart := 0
*local cLine
*default cWildcard to "*.DBC"
** default cPath to DbPath()
*default lEdit to .t.
*if cPath == NIL
*  aDir := GetDlmDir(cWildcard)
*else
*  aDir := directory(cPath + "\"  + cWildcard)
*endif
*asort(aDir,,,{|x,y|x[F_NAME] < y[F_NAME]} )
*do while .t.
*  a := {}
*  for i := 1 to len(aDir)
*    cLine := FileFirstLine(aDir[i][F_NAME])
*    * cLine := FileFirstLine(cPath + "\" + aDir[i][F_NAME])
*    if ! "[hidden]" $ cLine
*      aadd(a, { aDir[i][F_NAME], cLine } )
*    endif
*  next i
*  if snStart > len(a)
*    snStart := 0
*  endif
*  browse array a ;
*               using {|x| ;
*                 padr(x[1],12) + " : " + padr(x[2],50) ;
*               } ;
*               title (cTitle) ;
*               delete {|x|DbcDelete(x[1])} ;
*               create {|x|DbcCreate(x,cPath,cTitle)} ;
*               enter {|x|DbcEnter(x,cTitle,lEdit)} ;
*               help "DBCEDIT" ;
*               start snStart
*  if lastchoice() == 0 .or. lastkey() == K_F10
*    exit
*  endif
*  snStart := lastchoice()
*enddo
*// DbResetObj()
*default lPick to .f.
*if lPick
*  RETURN NIL if lastchoice() == 0
*  RETURN left(a[lastchoice()][1],at(".",a[lastchoice()][1])-1)
*endif
*RETURN .f.

*STATIC FUNCTION DbcEnter(x,cTitle,lEdit)
** FileEdit(cPath + "\" + x[1],"DBCEDIT",lEdit)
** x[2] := FileFirstLine(cPath + "\" + x[1])
*FileEdit(x[1],"DBCEDIT",lEdit)
*x[2] := FileFirstLine(x[1])
*RETURN NIL


* FUNCTION DbcDelete(cFilename)
* RETURN FileDelete(cFilename)

STATIC FUNCTION DbcCreate(x,cNewPath,cTitle)
local cCopy := BUTTON_ON
local cFilename := if(x==NIL,"",x[1])
local cNewFilename := padr(cFilename,12)
local dbc := NIL
local cDllPath
default cNewPath to DbPath()
cNewFilename := padr(cNewPath+"\"+cFilename,160)
open window (cTitle + " : Datei erstellen") size 4,54
  say "Dateiname "
  get cNewFilename picture "@k@s40"
  WinCr()
  get cCopy checkbox
  say " als Kopie von " + cFilename
  nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
cNewFilename := trim(cNewFilename)
if file(cNewFilename)
  SetMsg(cNewFilename + " : Datei existiert bereits!")
  RETURN NIL
endif
if cCopy == BUTTON_ON
  cDllPath := GetDlmPath(cFilename)
  if cDllPath != NIL
    copy file (cDllPath) to (cNewFilename)
  endif
endif
dbc := array(2)
dbc[1] := right(cNewFilename,len(cNewFilename)-rat("\",cNewFilename))
dbc[2] := cNewFilename
RETURN dbc



FUNCTION FilePick(cWildcard,cPath,cTitle,uNotUsed,cStart)
local bcName
local cReturn
local aDir
local a
local i
* static snStart := 0
local nStart := 0
local cLine
* local nStart := 0
* default cWildcard to "*.DBC"
* default cPath to DbPath()
default cTitle to "Select " + alltrim(cWildcard)
if cStart == NIL
  cStart := ""
else
  cStart := upper(trim(cStart))
endif
* aDir := directory(cPath + "\"  + cWildcard)
if cPath == NIL
  bcName :=  {|x|FileFirstLine(x)}
  aDir := GetDlmDir(cWildcard)
else
  aDir := directory(cPath + "\"  + cWildcard)
  bcName :=  {|x|FileFirstLine(cPath+"\"+x)}
endif
asort(aDir,,,{|x,y|x[F_NAME] < y[F_NAME]} )
do while .t.
  a := {}
  for i := 1 to len(aDir)
    cLine := xeval(bcName,aDir[i][F_NAME])
    aadd(a, { aDir[i][F_NAME], cLine } )
    if aDir[i][F_NAME] == cStart
      nStart := i
    endif
  next i
  * if snStart > len(a)
  *   snStart := 0
  * endif
  browse array a ;
               using {|x| ;
                 padr(x[1],12) + " : " + padr(x[2],50) ;
               } ;
               title (cTitle) ;
               delete {|x|FileDelete(cPath + "\" + x[1])} ;
               create {|x|DbcCreate(x,cPath,cTitle)} ;
               help "FILEPICK" ;
               start nStart
  if lastchoice() == 0
    exit
  endif
  * snStart := lastchoice()
  if lastkey() == K_F10 .or. lastkey() ==  K_ENTER
    cReturn := a[lastchoice()][1]
    exit
  endif
enddo
RETURN cReturn



