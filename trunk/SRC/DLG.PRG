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

#define DLGGET_NAME      1
#define DLGGET_CAPTION   2
#define DLGGET_WIDTH     3
#define DLGGET_PICTURE   4
#define DLGGET_PICK      5
#define DLGGET_VALID     6
#define DLGGET_READER    7
#define DLGGET_ATTRIB    8
#define DLGGET_CAPTION2  9
#define DLGGET_POSTEDIT 10
#define DLGGET_BLOCK    11
#define DLGGET_WHEN     12
#define DLGGET_COLOR    13
#define DLGGET_HEIGHT   14
#define DLGGET_ALEN     14

#define VAR_NAME      1
#define VAR_VALUE     2
#define VAR_ALEN      2

#define ACT_KEY      1
#define ACT_BLOCK    2
#define ACT_ALEN     2

#define DLGATTR_N "N" // no new line after this field
* #define DLGATTR_R "R" // reinitialize value each time in repeated dialogs


**
** STATIC_SECTION global static variables
**
static scDlgTitle
static saDlgBefore
static saDlgAfter
static saDlgFields
static saDlgValidate
static saActions
static saDlgCache := {}
* static slIsStatic := .f.
* static scIdDlg
static saVarStack := {}
static saVars := {}
static saPersistent := {}

static scPickIndicator := chr(18)

**
** PROCEDURE_SECTION  - (...grins)
**

* FUNCTION DlgParse(cIdDlg,c)
* RETURN .t. if empty(cIdDlg)
* RETURN .f. if ! DlgExec(cIdDlg)
* c := StrParse(c)
* RETURN .t.

FUNCTION IsMemoPicture(cPic)
// z.B. : 30x4
RETURN .f. if cPic == NIL
cPic:=trim(cPic)
RETURN .f. if len(cPic) < 4
RETURN .f. if substr(cPic,3,1)!="x"
RETURN .f. if len(cPic) > 5
RETURN .t.

FUNCTION DlgExec(cIdDlg,lPermanent,nTop,nLeft,cColor,lDlg)
local bOldShowTime := SetOnShowTime()
local nFldHeight := 1
local lShowWindow := .t.
* local aReadKeys := {}
local nHeight := 2
local nWidth := 4
local i
local nWidthCollect := 0
local oGet
local aDlgFields := saDlgFields
* local lIsStatic := slIsStatic
local aDlgAfter := saDlgAfter
local aDlgValidate:= saDlgValidate
local aDlgBefore := saDlgBefore
local aActions := saActions
local lOkay := .t.
local uValue
local fld
local nKey
#ifdef DEF_GUI
  local oDlg, oXbp, x, y, dx, dy, a
  local charSize := hw2size(1,1)
#endif DEF_GUI
RETURN .f. if ! DlgLoad(cIdDlg)
default lPermanent to .f.
default lDlg to !SetBatch()
for i := 1 to len(saDlgBefore)
  if ! xparse(saDlgBefore[i])
    lOkay := .f.
    exit
  endif
next i
if lOkay .and. lDlg .and. len(saDlgFields) > 0
  default scDlgTitle to cIdDlg
  nWidth := len(scDlgTitle)
  for i := 1 to len(saDlgFields)
    fld := saDlgFields[i]
    nWidthCollect += len(fld[DLGGET_CAPTION])
    nWidthCollect += len(fld[DLGGET_CAPTION2])
    if fld[DLGGET_BLOCK] != NIL
      if fld[DLGGET_WIDTH] == NIL
        uValue := eval(fld[DLGGET_BLOCK])
        if uValue == NIL
          fld[DLGGET_WIDTH] := 10 // valeur au hasard
        else
          fld[DLGGET_WIDTH] := len(transform(uValue,fld[DLGGET_PICTURE] ))
        endif
      endif
      nWidthCollect += fld[DLGGET_WIDTH]
    endif
    *if IsMemoPicture(fld[DLGGET_PICTURE])
    *  nWidthCollect += val(left(fld[DLGGET_PICTURE],2))
    *  nFldHeight := val(substr(fld[DLGGET_PICTURE],4))
    *else
    *  nFldHeight := 1
    *  if fld[DLGGET_BLOCK] != NIL
    *    uValue := eval(fld[DLGGET_BLOCK])
    *    if uValue != NIL // if fld[DLGGET_VALUE] != NIL
    *      nWidthCollect += len(transform(uValue,fld[DLGGET_PICTURE] ))
    *    endif
    *  endif
    *endif
    nWidth := max( nWidth, nWidthCollect)
    if ! DLGATTR_N $ fld[DLGGET_ATTRIB]
      nWidthCollect := 0
      nHeight += fld[DLGGET_HEIGHT]
    endif
  next i
  nWidth += 4
  do while lShowWindow
    lShowWindow := .f.
    #ifdef DEF_GUI
      oDlg := XbpDialog():new(NIL,NIL,NIL,hw2size(nHeight,nWidth))
      oDlg:title := scDlgTitle
      oDlg:taskList := .T.
      oDlg:create()
      CenterControl(oDlg)
      * dx := charSize[1]
      * dy := charSize[2]
      dx := dy := 0
      x := 0
      y := oDlg:drawingArea:currentSize()[2] - 20
      for i := 1 to len( saDlgFields)
        * Warning("Field # "+ntrim(i)+" : " + utos(fld))
        fld := saDlgFields[i]
        if !empty(fld[DLGGET_CAPTION])
          oXbp := XbpStatic():new(oDlg:drawingArea)
          oXbp:caption := fld[DLGGET_CAPTION]
          oXbp:autoSize := .t.
          * x += len(fld[DLGGET_CAPTION]) * dx
          a := oXbp:currentSize()
          dy := max(dy,a[2])
          oXbp:create(,,{x,y})
          x += a[1]
        endif
        if fld[DLGGET_BLOCK] != NIL
          oXbp := XbpSLE():new(oDlg:drawingArea,,{x,y})
          oXbp:autoTab := .T.
          oXbp:bufferLength := fld[DLGGET_WIDTH]
          oXbp:dataLink := fld[DLGGET_BLOCK]
          oXbp:autoSize := .t.
          oXbp:create()
          oXbp:setData()
          a := oXbp:currentSize()
          x += a[1]
          dy := max(dy,a[2])
          * x += fld[DLGGET_WIDTH] * dx
        endif
        if !empty(fld[DLGGET_CAPTION2])
          oXbp := XbpStatic():new(;
            oDlg:drawingArea,,{x,y})
          oXbp:caption := fld[DLGGET_CAPTION2]
          oXbp:autoSize := .t.
          oXbp:create()
          a := oXbp:currentSize()
          x += a[1]
          dy := max(dy,a[2])
          * x += len(fld[DLGGET_CAPTION2]) * dx
        endif
        if ! DLGATTR_N $ fld[DLGGET_ATTRIB]
          y -= dy * fld[DLGGET_HEIGHT]
          x := 0
          dy := 0
        endif
      next i
      * Warning("gonna show "+oDlg:title ;
      *   + " (pos: "+utos(oDlg:currentPos()) ;
      *   + ", size: "+utos(oDlg:currentSize()) +")" ;
      *   )
      oDlg:showModal()
      if oDlg:modalResult == XBP_MRESULT_CANCEL
        lOkay := .f.
      else
        for i := 1 to len(saDlgValidate)
          if ! xparse(saDlgValidate[i])
            lShowWindow := .t.
            exit
          endif
        next i
      endif
      oDlg:destroy()
    #else
      open window (scDlgTitle) size nHeight,nWidth help (cIdDlg) ;
           home (nTop),(nLeft) color (cColor) permanent (lPermanent)
      for i := 1 to len( saDlgFields)
        fld := saDlgFields[i]
        say fld[DLGGET_CAPTION]
        if fld[DLGGET_BLOCK] != NIL
          oGet := GetNew( ;
            row(),col(), ;
            fld[DLGGET_BLOCK], ;
            fld[DLGGET_NAME], ;
            fld[DLGGET_PICTURE], ;
            fld[DLGGET_COLOR] ;
          )
          * oGet fld[DLGGET_VALUE] ;
          *     picture (fld[DLGGET_PICTURE])
          oGet:cargo := array(AG_ALEN)
          oGet:cargo[AG_PICKBLK]  := fld[DLGGET_PICK]
          oGet:cargo[AG_POSTEDIT] := fld[DLGGET_POSTEDIT]
          * if fld[DLGGET_BLOCK] != NIL
          *   atail(GetList):block  := fld[DLGGET_BLOCK]
          * endif
          oGet:postBlock          := fld[DLGGET_VALID]
          oGet:preBlock           := fld[DLGGET_WHEN]
          oGet:reader             := fld[DLGGET_READER]
          aadd(GetList,oGet)
          FldDisplay(oGet) // 20051102
          // nFldHeight := FldDisplay(oGet) // 20051102
          // oGet:display()
        endif
        say fld[DLGGET_CAPTION2]
        if ! DLGATTR_N $ fld[DLGGET_ATTRIB]
          // setpos(row()+nFldHeight,WinLeft())
          WinCr()
        endif
      next i
      if lPermanent
        drop window // WinDrop()
        lOkay := .t.
      elseif !SetDialog()
        close window
        lOkay := .f.
      else
        nKey := ReadScr() // aReadKeys)
        close window
        if nKey == K_ALT_F10
          FileEdit(cIdDlg + ".DLG")
          // look for static entry and remove :
          for i := 1 to len(saDlgCache)
            if saDlgCache[i][1] == cIdDlg
              adel(saDlgCache,i)
              asize(saDlgCache,len(saDlgCache)-1)
              exit
            endif
          next i
          * scIdDlg := NIL
          lOkay := .f.
          * lShowWindow := .t.
        elseif nKey == K_ESC
          lOkay := .f.
        else
          /* 20021212 weil nKey nicht local war, ver„nderte Warning() den
          Wert von nKey wieder!
          */
          * Warning("You pressed "+ntrim(nKey))
          for i := 1 to len(saActions)
            if saActions[i][ACT_KEY] == nKey
              lShowWindow := .t.
              * Warning(utos(saActions[i][ACT_BLOCK]))
              lOkay := xeval(saActions[i][ACT_BLOCK])
              exit
            endif
          next i
          if lOkay .and. ! lShowWindow
            // so we plan to exit
            for i := 1 to len(saDlgValidate)
              if ! xparse(saDlgValidate[i])
                lShowWindow := .t.
                exit
              endif
            next i
          endif
        endif
      endif
    #endif DEF_GUI
  enddo
endif
if lOkay
  for i := 1 to len(saDlgAfter)
    if ! xparse(saDlgAfter[i])
      lOkay := .f.
      exit
    endif
  next i
endif
saDlgFields  := aDlgFields
saDlgAfter   := aDlgAfter
saDlgValidate := aDlgValidate
saDlgBefore  := aDlgBefore
saActions    := aActions
* slIsStatic   := lIsStatic
SetOnShowTime(bOldShowTime)
RETURN lOkay

/**
N.B. Hier sieht man deutlich, dass eine Kopie des aktuellen Werts der
lokalen Variablen i im Codeblock gespeichert wird.
**/
FUNCTION DlgBlock(cName)
local i
* local cMac
for i := 1 to len(saVars)
  if saVars[i][VAR_NAME] == cName
    RETURN {|x|if(x==NIL,saVars[i][VAR_VALUE],saVars[i][VAR_VALUE]:=x)}
  endif
next i
RETURN {|x|if(x==NIL,DlgValue(cName),DlgDefine(cName,x))}

FUNCTION DlgDoPick(dlgget)
local c
RETURN NIL if empty(dlgget[DLGGET_PICK])
c := StrParse(dlgget[DLGGET_PICK])
RETURN &c


**
** DlgLoad()
**
STATIC FUNCTION DlgLoad(cIdDlg)
local cFileName
local a := {}
local lIsStatic := .f.
local i
for i := 1 to len(saDlgCache)
  if saDlgCache[i][1] == cIdDlg
    saDlgFields   := saDlgCache[i][2]
    saDlgBefore   := saDlgCache[i][3]
    saDlgAfter    := saDlgCache[i][4]
    saActions     := saDlgCache[i][5]
    saDlgValidate := saDlgCache[i][6]
    RETURN .t.
  endif
next i
* cFileName := DbPath() + "\" + cIdDlg + ".DLG"
* sbDlgTitle   := {|| NIL}
saDlgBefore  := {}
saDlgAfter   := {}
saDlgValidate := {}
saDlgFields  := {}
saActions    := {}
aadd(a, { "title",  {|x| aadd(saDlgBefore,"SetDlgTitle("+x+")"),.t.} } )
aadd(a, { "before", {|x| aadd(saDlgBefore,x), .t.                  } } )
aadd(a, { "after",  {|x| aadd(saDlgAfter,x), .t.                   } } )
aadd(a, { "validate",  {|x| aadd(saDlgValidate,x), .t.                   } } )
aadd(a, { "field",  {|x| FldFetch(x)                               } } )
aadd(a, { "action", {|x| ActFetch(x)                               } } )
aadd(a, { "static", {|x| (lIsStatic := xparse(x)) != NIL           } } )
RETURN .f. if ! IniLoad(a,cIdDlg+".DLG") // cFileName)
if lIsStatic
  aadd(saDlgCache, { ;
    cIdDlg, ;
    saDlgFields, ;
    saDlgBefore, ;
    saDlgAfter, ;
    saActions, ;
    saDlgValidate ;
  })
endif
* scIdDlg := cIdDlg
RETURN .t.


**
**  FldFetch()
**  get   <nFldHandle> <nRow> <nCol> [...]
**
static FUNCTION FldFetch(cLine)
local a := {}
local fld := array(DLGGET_ALEN)
local i
local uValue
local uDefault
fld[DLGGET_VALID]    := {||.t.}
fld[DLGGET_WHEN ]    := {||.t.}
// fld[DLGGET_READER]   := {|g|MyGetReader(g)}
fld[DLGGET_CAPTION]  := ""
fld[DLGGET_CAPTION2] := ""
fld[DLGGET_ATTRIB]   := ""
fld[DLGGET_PICTURE]  := ""
* aadd(a, { "name",     {|x| (fld[DLGGET_NAME]     := lower(xparse(x))) != NIL }})
aadd(a, { "name",     {|x| (fld[DLGGET_NAME]     := xparse(x)) != NIL }})
aadd(a, { "caption",  {|x| (fld[DLGGET_CAPTION]  := xparse(x)) != NIL }})
aadd(a, { "caption2", {|x| (fld[DLGGET_CAPTION2] := xparse(x)) != NIL }})
aadd(a, { "value",    {|x| (uValue                  := xparse(x)) != NIL }})
aadd(a, { "default",  {|x| (uDefault                := xparse(x)) != NIL }})
aadd(a, { "picture",  {|x| (fld[DLGGET_PICTURE]  := xparse(x)) != NIL }})
aadd(a, { "valid"   , {|x| (fld[DLGGET_VALID]    := xparse(x)) != NIL }})
aadd(a, { "when",     {|x| (fld[DLGGET_WHEN]     := xparse(x)) != NIL }})
aadd(a, { "pick",     {|x| (fld[DLGGET_PICK]     := xparse(x)) != NIL }})
aadd(a, { "reader",   {|x| (fld[DLGGET_READER]   := xparse(x)) != NIL }})
aadd(a, { "attrib",   {|x| (fld[DLGGET_ATTRIB]   := xparse(x)) != NIL }})
aadd(a, { "postedit", {|x| (fld[DLGGET_POSTEDIT] := xparse(x)) != NIL }})
aadd(a, { "block",    {|x| (fld[DLGGET_BLOCK]    := xparse(x)) != NIL }})
aadd(a, { "color",    {|x| (fld[DLGGET_COLOR]    := xparse(x)) != NIL }})
RETURN .f. if ! IniParse(a,cLine)
if fld[DLGGET_BLOCK] == NIL
  if fld[DLGGET_NAME] == NIL
    fld[DLGGET_BLOCK] := NIL
    // fld[DLGGET_BLOCK] := {||NIL}
    // caption-only fields
  else
    if uValue != NIL
      DlgDefine(fld[DLGGET_NAME],uValue)
    elseif uDefault != NIL
      DlgDefault(fld[DLGGET_NAME],uDefault)
    endif
    fld[DLGGET_BLOCK] := DlgBlock(fld[DLGGET_NAME])
  endif
elseif uValue != NIL // fld[DLGGET_VALUE] != NIL
  eval(fld[DLGGET_BLOCK],uValue) // fld[DLGGET_VALUE])
endif
if IsMemoPicture(fld[DLGGET_PICTURE])
  fld[DLGGET_WIDTH] := val(left(fld[DLGGET_PICTURE],2))
  fld[DLGGET_HEIGHT] := val(substr(fld[DLGGET_PICTURE],4))
  fld[DLGGET_READER]   := {|g|MemoReader(g)}
else
  fld[DLGGET_HEIGHT] := 1
  fld[DLGGET_WIDTH] := NIL
  * if fld[DLGGET_READER] == NIL
  *   if valtype(eval(fld[DLGGET_BLOCK])) == GTYPE_LOGICAL
  *     fld[DLGGET_READER]   := {|g|CbxReader(g)}
  *   endif
  * endif
endif
aadd( saDlgFields, fld )
RETURN .t.


**
**  ActFetch()
**  get   <nFldHandle> <nRow> <nCol> [...]
**
static FUNCTION ActFetch(cLine)
local a := {}
local act := array(ACT_ALEN)
aadd(a, { "key",     {|x| (act[ACT_KEY]  := xparse(x)) != NIL }})
aadd(a, { "block",   {|x| (act[ACT_BLOCK] := xparse(x)) != NIL }})
RETURN .f. if ! IniParse(a,cLine)
if act[ACT_BLOCK] == NIL
  RETURN ! SetMsg("action requires block")
endif
if act[ACT_KEY] == NIL
  RETURN ! SetMsg("action requires key")
endif
aadd( saActions, act )
RETURN .t.


*FUNCTION GetValue(cKey,uDefault)
*local i
*for i := 1 to len(saVars)
*  if saVars[i][1] == cKey
*    RETURN saVars[i][2]
*  endif
*next i
*RETURN uDefault if uDefault != NIL
*Warning(cKey + " : undefined dictionary entry !")
*RETURN NIL
*
*FUNCTION SetValue(cKey,uValue)
*local i
*for i := 1 to len(saVars)
*  if saVars[i][1] == cKey
*    saVars[i][2] := uValue
*    RETURN .t.
*  endif
*next i
*aadd(saVars,{ cKey, uValue })
*RETURN .t.

FUNCTION DlgValBrowse(cTitle,cIdHlp)
browse array saVars ;
             using {|x| padr(x[VAR_NAME],10) + padr(x[VAR_VALUE],60)} ;
             title (cTitle) ;
             help (cIdHlp)
RETURN NIL

* 20021212 FUNCTION DlgStackBrowse()
FUNCTION ShowDlgChache()
browse array saDlgCache ;
             using {|x| padr(x[1],10)} ;
             title ("saDlgCache")
RETURN NIL

FUNCTION SetDlgTitle(cTitle)
RETURN scDlgTitle if cTitle == NIL
scDlgTitle := cTitle
RETURN .t.

FUNCTION DlgTitle ; RETURN scDlgTitle

FUNCTION DlgValue(cName,lWarn)
RETURN GetVar(cName,lWarn)

FUNCTION DlgDefine(cName,uValue)
RETURN SetVar(cName,uValue)


STATIC FUNCTION VarLocate(cName)
local i
for i := 1 to len(saVars)
  RETURN saVars[i] if saVars[i][VAR_NAME] == cName
next i
RETURN NIL

FUNCTION GetVar(cName,lWarn,uDefault)
local v := VarLocate(cName)
RETURN v[VAR_VALUE] if v != NIL
default lWarn to .t.
if lWarn
  if ! Confirm("DlgValue() : unknown variable " + cName + " !",MsgContinue())
    raise("DlgValue() : unknown variable " + cName + " !")
  endif
endif
RETURN uDefault

FUNCTION SetVar(cName,uValue,lPersistent)
local v := VarLocate(cName)
if v == NIL
  v := array(VAR_ALEN)
  v[VAR_NAME]     := cName
  aadd(saVars,v)
endif
v[VAR_VALUE] := uValue
if lPersistent != NIL
  if lPersistent
    aadd(saPersistent,v)
  endif
endif
RETURN .t.

FUNCTION getvara(cName,nItem,uDefault)
// uDefault used in agv\vnleti.tpl
local v := getvar(cName)
RETURN NIL if v == NIL
RETURN uDefault if nItem > len(v)
RETURN v[nItem]

FUNCTION DlgDefault(cName,uValue)
local v := VarLocate(cName)
if v != NIL
  RETURN .t.
endif
v := array(VAR_ALEN)
v[VAR_NAME]     := cName
v[VAR_VALUE]    := uValue
aadd(saVars,v)
RETURN .t.

FUNCTION DlgPlus(cName,uValue)
local v := VarLocate(cName)
if v != NIL
  v[VAR_VALUE] += uValue
  RETURN .t.
endif
RETURN .f.

FUNCTION getctr(cName)
local uValue := getvar(cName) + 1
setvar(cName,uValue)
RETURN ntrim(uValue)


/**
Collect a minimum value. Stores the value into variable cName if value
is less than the currently stored value.
**/
FUNCTION MinCollect(cName,uValue)
local v := VarLocate(cName)
RETURN .f. if v == NIL
if empty(v[VAR_VALUE]) .or. v[VAR_VALUE] > uValue
  v[VAR_VALUE] := uValue
endif
RETURN .t.
*
FUNCTION MaxCollect(cName,uValue)
local v := VarLocate(cName)
RETURN .f. if v == NIL
if empty(v[VAR_VALUE]) .or. v[VAR_VALUE] < uValue
  v[VAR_VALUE] := uValue
endif
RETURN .t.


FUNCTION DlgPush(cName)
aadd(saVarStack,DlgValue(cName,.f.))
RETURN .t.

FUNCTION DlgPop(cName)
DlgDefine(cName,atail(saVarStack))
asize(saVarStack,len(saVarStack)-1)
RETURN .t.


FUNCTION Rec2Var()
local i
for i := 1 to fcount()
  setvar(fieldname(i),&(fieldname(i)))
next i
RETURN .t.

FUNCTION Var2Rec()
local i
local v
// local c := ""
for i := 1 to fcount()
  v := VarLocate(fieldname(i))
  if v != NIL
    &(alias()+"->"+fieldname(i)) := v[VAR_VALUE]
    // c += fieldname(i) + " "
  endif
next i
RETURN .t. // Confirm("var2rec() done : " + c)


FUNCTION SaveDbVars()
// called from Logout
// writes file DBVARS.ACT to be loaded via LoadDbVars()
local fd
local i, v
local cFilename := DbPath()+"\DBVARS.ACT"
RETURN .t. if len(saPersistent) == 0
fd := fcreate(cFilename)
if fd == -1
  RETURN ! SetMsg(cFilename + MsgDosError(doserror()))
endif
fwrite(fd,"// Generated file. Don't edit!"+CR_LF)
for i := 1 to len(saPersistent)
  v := saPersistent[i]
  fwrite(fd,'setvar("'+v[VAR_NAME]+'",'+utos(v[VAR_VALUE])+')'+CR_LF)
next i
fclose(fd)
RETURN .t.

FUNCTION LoadDbVars()
// called after TIM.DBI (see OpenData())
RETURN .t. if len(saPersistent) == 0
// RETURN .t. if ! file(DbPath() + "\DBVARS.ACT")
RETURN ActExec("DBVARS")

FUNCTION SetPickIndicator(c)
RETURN scPickIndicator if c == NIL
scPickIndicator := c
RETURN .t.
