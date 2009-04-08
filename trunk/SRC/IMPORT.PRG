** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2009 Luc Saffre
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
* #include "DIRECTRY.CH"
#include "dbstruct.ch"

** request eac_allo
request i_plz

#ifndef __XPP__
REQUEST DBFNTX
#endif


memvar i_line
memvar i_count
memvar i_fields

#define FLD_NAME     1
#define FLD_EXPR     2
#define FLD_TYPE     3
        #define FLDTYPE_UPDATE   1
        #define FLDTYPE_NEW      2
        #define FLDTYPE_DISPLAY  3
        // #define FLDTYPE_GET      4
        // #define FLDTYPE_GET      4
#define FLD_ALEN     3

* InputFile     C:\IMPORT\STOCKF*.TXT
* LineValidate  len(i_Line) == 92
* SeekKey       substr(i_line,10,6)
* FieldNew    ART->iGra    substr(i_line,12,3)
* FieldUpdate ART->cPrixA  str(val(substr(i_line,12,3)*20.5),10,0)

#ifdef DEF_IMPORT

#define ACTION_Y "Y"
#define ACTION_N "N"
#define ACTION_A "A"
#define ACTION_Q "Q"

**
** STATIC_SECTION global static variables
**

static snRecCount
static snLoop
static saFields
static saRules
static saRecBefore
static saRecAfter
static scInputFile
static scUserLevel
static scOutputFile
static scSeekKey := NIL
static scDelim := NIL
static slCsv := .f.
* static scRecDelim := NIL
static snSeekOrder
static snFixedWidth := NIL
static sxOnSuccess := NIL
static slNoAppend
static slConfirm := .t.
static slAppend := .f.
static slNoTitles
static scAction := ACTION_Y
static scHeader := NIL
static scTrailer := NIL
static saCvtList
static saOnNew

**
** MSG_SECTION    MSGnnn definitions
**
* static MSG001 := ""
#ifdef LG_FRENCH
  static MSG001 := " : Filtres d'importation :"
#else
  static MSG001 := " : Importfilter"
#endif

**
** PROCEDURE_SECTION  - (...grins)
**


FUNCTION DbfImport(ad,cFilename,lDlg,lSimul,lLog)
local fd
local aDir
local i
local cTitle := FltRead(ad[AD_NAME],"IMP","IMPORT",cFilename)
local lOkay := .f.
local cTit1 := ""
local cTit2 := ""
default lDlg to .t.
default lSimul to .f.
default lLog to .f.
RETURN .f. if cTitle == NIL
if lDlg
  RETURN .f. if scInputFile == NIL
  scInputFile := padr(scInputFile,120)
  open window ("Import : " + cTitle) size 3,60
  @ row(), col() get scInputFile picture "@K@S56"
  nKey := ReadScr()
  close window
  RETURN .f. if nKey == K_ESC
  scInputFile := trim(scInputFile)
endif
if lLog
  for i := 1 to len(saFields)
    cTit1 += saFields[i][FLD_NAME] + " "
    cTit2 += repl("-",len(saFields[i][FLD_NAME])) + " "
  next i
  RETURN .f. if ! OpenPrinter(SetTplIni(),SetPreview(),len(cTit2),;
    {|| ;
      PrintHeader(cTitle,if(lSimul,"Simulation","Datenabgleich")), ;
      PrintLine(cTit1), ;
      PrintLine(cTit2) ;
    } ;
  )
endif
if ! "\" $ scInputFile
  scInputFile := AppRoot() + "\TEMP\" + scInputFile
endif
open area ad
  if snSeekOrder != 0
    ddSetOrder(snSeekOrder)
  endif
  #ifdef DEF_LFN
  aDir := lf_directory(scInputFile)
  #else
  aDir := directory(scInputFile)
  #endif
  if len(aDir) == 0
    Warning(scInputFile + MsgDosError())
  else
    for i := 1 to len(aDir)
      cFileName := left(scInputFile,rat("\",scInputFile)) + aDir[i][F_NAME]
      #ifdef DEF_LFN
      do while (fd := lf_fopen(cFileName)) == -1
      #else
      do while (fd := fopen(cFileName)) == -1
      #endif
        if ! Confirm( ;
          cFileName + MsgDosError(ferror()), ;
          MsgRetry() ;
        )
          scAction := ACTION_Q
        endif
      enddo
      MsgDisplay("Importing " + cFileName + "...")
      lOkay := f_import(fd,lSimul,lLog)
      fclose(fd)
    next i
  endif
close area
if lLog
  if lOkay
    PrintLine("Ende")
  else
    PrintLine("(abort)")
  endif
  ClosePrinter()
endif
if ! lOkay
  * tune_torero()
  * else
  Warning("Import was not complete !")
endif
RETURN lOkay


**
** DbfExport()
**
FUNCTION DbfExport( ;
  adTables,nOrder,cStart,xlWhile,xlFilter,cExpFilename,nLoop,cOutFile;
)
local fd
local cMac
local i
local cTitle
local cLine := ""
local ad := adTables[1]
local lOkay := .f.
***
local aFields       := saFields
local aRules        := saRules
local aRecBefore       := saRecBefore
local aRecAfter        := saRecAfter
local cInputFile    := scInputFile
local cUserLevel    := scUserLevel
local cOutputFile   := scOutputFile
local cSeekKey      := scSeekKey
local cDelim        := scDelim
* local cRecDelim     := scRecDelim
local nSeekOrder    := snSeekOrder
local nFixedWidth   := snFixedWidth
local xOnSuccess := sxOnSuccess
local lNoAppend     := slNoAppend // keine Records hinzufÅgen
local lNoTitles     := slNoTitles
local lConfirm      := slConfirm
local lAppend       := slAppend // append to export file
local cAction       := scAction
local cHeader       := scHeader
local cTrailer      := scTrailer
local aCvtList      := saCvtList
local aOnNew := saOnNew
local nCount        := 0
***
public i_count
default cStart to ""
default xlWhile to ".t."
default xlFilter to ".t."
cTitle := FltRead(ad[AD_NAME],"EXP","EXPORT",cExpFilename)
if cOutFile != NIL
  // override setting in export filter
  scOutPutFile := cOutFile
endif
if cTitle == NIL .or. scOutputFile == NIL
  lOkay := .f.
else
  lOkay := .t.
  if "*" $ scOutputFile
    scOutputFile := padr(scOutputFile,120)
    open window ("Export : " + cTitle) size 3,60
    @ row(), col() get scOutputFile picture "@K@S56"
    nKey := ReadScr()
    close window
    if nKey == K_ESC
      lOkay := .f.
    else
      scOutputFile := trim(scOutputFile)
    endif
  endif
  if lOkay
    if ! "\" $ scOutputFile
      scOutputFile := AppRoot() + "\TEMP\" + scOutputFile
    endif
    if slConfirm .and. fexist(scOutputFile)
      if ! Confirm(scOutputFile + MsgOverwrite())
        lOkay := .f.
      endif
    endif
  endif
  if lOkay
    if fexist(scOutputFile) .and. slAppend
      #ifdef DEF_LFN
      if (fd := lf_fopen(scOutputFile,FO_WRITE)) == -1
      #else
      if (fd := fopen(scOutputFile,FO_WRITE)) == -1
      #endif
        Warning(scOutputFile + MsgDosError(ferror()))
      else
        fseek(fd,0,FS_END)
      endif
    else
      #ifdef DEF_LFN
      if (fd := lf_fcreate(scOutputFile)) == -1
      #else
      if (fd := fcreate(scOutputFile)) == -1
      #endif
        Warning(scOutputFile + MsgDosError(ferror()))
        lOkay := .f.
      endif
    endif
  endif
  if lOkay
    if nLoop == NIL
      snLoop := 1
    else
      snLoop := nLoop
    endif
    if scHeader != NIL
      fwrite(fd,CvtString(saCvtList,xparse(scHeader) + CR_LF))
    endif
    if ! slNoTitles
      for i := 1 to len(saFields)
        cLine += trim(saFields[i][FLD_NAME])
        if scDelim != NIL
          if i < len(saFields)
            cLine += xparse(scDelim)
          endif
        endif
      next i
      fwrite(fd,CvtString(saCvtList,cLine + CR_LF))
    endif
    MsgDisplay("Exporting to " + scOutputFile + "...")
    default nOrder to 1
    nCount := i_count
    i_count := 0
    snRecCount := 0
    begin sequence
      if ! AreaOpen( adTables, .f. ) ; break ; endif
      ddSetOrder(nOrder)
      softseek cStart
      lOkay := .t.
      do while lOkay .and. ! eof() .and. &xlWhile
        for i := 1 to len(saRecBefore)
          cMac := saRecBefore[i]
          if ! xparse(cMac)
            if ! Confirm( ;
              cMac + " : RecordBefore action failed !", ;
              MsgContinue() ;
            )
              lOkay := .f.
              exit
            endif
          endif
        next i
        if lOkay .and. &xlFilter
          if (lOkay := f_export(fd)) // exports one record
            for i := 1 to len(saRecAfter)
              if ! xparse(saRecAfter[i])
              * if ! xeval(saRecAfter[i])
                lOkay := Confirm( ;
                  saRecAfter[i] + " : post-export action failed !", ;
                  MsgContinue() ;
                )
              endif
            next i
          endif
        endif
        if TaskInter() ; lOkay := .f. ; exit ; endif
        skip
      enddo
      AreaClose()
    end sequence
    * ddScan({|| f_export(fd) } )
    MsgDisplay(ntrim(i_count) + " records written to " + scOutputFile)
    if scTrailer != NIL
      fwrite(fd,CvtString(saCvtList,xparse(scTrailer) + CR_LF))
    endif
    fclose(fd)
  endif
endif
if lOkay .and. sxOnSuccess != NIL
  eval(sxOnSuccess)
endif
***
saFields       := aFields
saRules        := aRules
saRecBefore       := aRecBefore
saRecAfter        := aRecAfter
scInputFile    := cInputFile
scUserLevel    := cUserLevel
scOutputFile   := cOutputFile
scSeekKey      := cSeekKey
scDelim        := cDelim
* scRecDelim     := cRecDelim
snSeekOrder    := nSeekOrder
snFixedWidth   := nFixedWidth
sxOnSuccess := xOnSuccess
slNoAppend     := lNoAppend
slNoTitles     := lNoTitles
slConfirm      := lConfirm
slAppend       := lAppend
scAction       := cAction
scHeader       := cHeader
scTrailer      := cTrailer
saCvtList      := aCvtList
saOnNew := aOnNew
i_count        := nCount
***
RETURN lOkay







FUNCTION ddModify(ad)
local fd
local i
local cTitle := FltRead(ad[AD_NAME],"MOD","REVISE")
local cLine := ""
* slOverwrite := .f.
RETURN .f. if cTitle == NIL
MsgDisplay(cTitle + "...")
public i_count
i_count := 0
ddScan({|| f_modify(ad) } )
RETURN MnuDone()


STATIC FUNCTION FltRead(cName,cExt,cHelp,cFilename)
local i
local aDir
local nChoice
local cTitle
static a := NIL
if cFilename == NIL
  aDir := GetDlmDir(cName + "*." + cExt)
  ** aDir := directory(DbPath() + "\" + cName + "*." + cExt)
  for i := 1 to len(aDir)
    aDir[i][5] := aDir[i][F_NAME] + ":" + FileFirstLine(aDir[i][F_NAME])
  next i
  browse array aDir using {|d| padr(d[5],60)} ;
                    title (cName + " : " + cHelp) ;
                    help (cHelp)
  nChoice := lastchoice()
  RETURN NIL if nChoice == 0
  cFilename := aDir[nChoice][F_NAME]
  cTitle := aDir[nChoice][5]
else
  cTitle := FileFirstLine(cFilename)
endif
if a == NIL
  a := {}
  aadd(a, { "InputFile"    , {|x| scInputFile := xparse(x), .t.} } )
  aadd(a, { "OutputFile"   , {|x| scOutputFile := xparse(x), .t. } } )
  aadd(a, { "UserAction"   , {|x| (scAction := xparse(x)) != NIL } } )
  aadd(a, { "Header"       , {|x| scHeader := x,.t. } } )
  aadd(a, { "Trailer"      , {|x| scTrailer := x,.t. } })
  aadd(a, { "NoTitles"     , {|x| slNoTitles := ctol(x),.t. } })
  aadd(a, { "Confirm"      , {|x| slConfirm := ctol(x),.t. } })
  aadd(a, { "Append"       , {|x| slAppend := ctol(x),.t. } })
  aadd(a, { "LineValidate" , {|x| aadd(saRules,x) ,.t. } })
  aadd(a, { "RecordBefore" , {|x| aadd(saRecBefore,x) ,.t. } })
  aadd(a, { "RecordAfter"  , {|x| aadd(saRecAfter,x) ,.t. } })
  * aadd(a, { "RecordAfter"  , {|x| aadd(saRecAfter,xparse(x)) ,.t. } })
  aadd(a, { "NoAppend"     , {|x| slNoAppend := ctol(x), .t. } })
  aadd(a, { "UserLevel"    , {|x| scUserLevel := x  ,.t. } })
  aadd(a, { "SeekKey"      , {|x| scSeekKey := x  ,.t. } })
  aadd(a, { "Delimiter"    , {|x| scDelim := x  ,.t. } })
  aadd(a, { "CSV"          , {|x| slCsv:= ctol(x)  ,.t. } })
  * aadd(a, { "RecordDelimiter"  , {|x| scRecDelim := x  ,.t. } })
  aadd(a, { "SeekOrder"    , {|x| snSeekOrder := val(x)  ,.t. } })
  aadd(a, { "convert"      , {|x| CvtCollect(saCvtList,x) } })
  aadd(a, { "OnNew"        , {|x| aadd(saOnNew,x),.t.}})
  aadd(a, { "FixedWidth"   , {|x| snFixedWidth := val(x), .t. } })
  aadd(a, { "FieldNew"     , {|x| AddField(x,FLDTYPE_NEW) } })
  aadd(a, { "FieldUpdate"  , {|x| AddField(x,FLDTYPE_UPDATE) } })
  aadd(a, { "FieldExport"  , {|x| AddField(x,FLDTYPE_UPDATE) } })
  aadd(a, { "FieldDisplay" , {|x| AddField(x,FLDTYPE_DISPLAY) } })
  aadd(a, { "OnSuccess"    , {|x| (sxOnSuccess := cblock(x))!=NIL } })
endif
scAction := ACTION_Y
saFields := {}
saRules := {}
saRecBefore := {}
saRecAfter  := {}
saOnNew := {}
slNoAppend  := .f.
slNoTitles  := .f.
scInputFile := ""
scDelim := NIL
* scRecDelim := NIL
scHeader := NIL
scTrailer := NIL
scSeekKey := NIL
snSeekOrder := 0
scUserLevel := ""
saCvtList := {}
* if IniLoad(a,dbPath()+"\"+cFilename,.t.)
if IniLoad(a,cFilename,.f.)
  if USRATTR_E $ UsrAttrib() .or. UsrLevel() <= scUserLevel
    RETURN cTitle
  else
    Warning("Diesen Filter dÅrfen Sie nicht benutzen !",NIL,"WRN042")
  endif
endif
RETURN NIL

*STATIC FUNCTION FltFirstLine(cName)
*RETURN FileFirstLine(cName)

*STATIC FUNCTION FileFirstLine(cName)
*local cLine
*local fd
*if (fd := fopen(cName)) != -1
*  if (cLine := freadline(fd)) != NIL
*    cLine := alltrim(substr(cLine,3))
*  endif
*  fclose(fd)
*endif
*default cLine to cName
*RETURN cLine


FUNCTION FldValue(i)
* RETURN fld2exp(saFields[i][FLD_EXPR]) if saFields[i][FLD_TYPE] == FLDTYPE_GET
RETURN xparse(saFields[i][FLD_EXPR])

STATIC FUNCTION f_import(fd,lSimul,lLog)
local uValue
local lModified
local cBefore
local cAfter
local nNew     := 0
local nUpdated := 0
local i
local cMac
local lOkay := .t.
local lNew
local nColWidth
public i_line
public i_count
public i_fields
do while scAction != ACTION_Q .and. (i_line := i_readline(fd,snFixedWidth)) != NIL
  if TaskInter() ; scAction := ACTION_Q ; exit ; endif
  if scDelim != NIL
    i_fields := ListAsArray(i_line,xparse(scDelim))
  elseif slCsv
    if empty(i_line)
      loop
    endif
    i_fields := csv2array(i_line)
    if i_fields == NIL
      RETURN .f. if ! Confirm( ;
        "csv2array() : " + SetMsg(), ;
        MsgContinue() ;
      )
      loop
    endif
  endif
  lOkay := .t.
  for i := 1 to len(saRules)
    cMac := saRules[i]
    if ! (xparse(cMac))
      lOkay := .f.
      exit
    endif
  next i
  if ! lOkay
    loop
  endif
  i_count := nNew
  if scSeekKey == NIL // jede gelesene Zeile ein neuer record
    goto (lastrec() + 1)
    nNew ++
    lNew := .t.
    if ! lSimul
      if ! ddCreate()
        RETURN .f.
      endif
    endif
  elseif scSeekKey == "*"
        lNew := .t.
        nNew ++
        if ! lSimul
          append blank
        endif
  else
    seek (xparse(scSeekKey))
    if eof() // 20070801 recno() == lastrec() + 1
      if slNoAppend
        loop
      else
        lNew := .t.
        nNew ++
        if ! lSimul
          append blank
        endif
      endif
    else
      lNew := .f.
      nUpdated ++
    endif
  endif
  if slNoAppend
    MsgDisp2(ntrim(nUpdated))
  else
    MsgDisp2(ntrim(nNew) + "+" + ntrim(nUpdated))
  endif
  for i := 1 to len(saRecBefore)
    cMac := saRecBefore[i]
    if ! xparse(cMac)
      RETURN .f. if ! Confirm( ;
        cMac + " : RecordBefore action failed !", ;
        MsgContinue() ;
      )
      loop
    endif
  next i
  i_Confirm(lNew)
  if scAction == ACTION_A .or. scAction == ACTION_Y
    lModified := .f.
    if lLog
      cBefore := ""
      cAfter  := ""
    endif
    if ! lSimul
      RETURN .f. if ! ddRecLock()
    endif
    for i := 1 to len(saFields)
      * uValue := CvtString(saCvtList,xeval(saFields[i][FLD_EXPR]))
      uValue := CvtString(saCvtList,FldValue(i))
      if lLog
        nColWidth := len(saFields[i][FLD_NAME])
        if saFields[i][FLD_TYPE] == FLDTYPE_DISPLAY
          cBefore += padr(utos(uValue),nColWidth)
          cAfter += space(nColWidth)
        else
          if &(trim(saFields[i][FLD_NAME])) == uValue
            cBefore += space(nColWidth)
            cAfter += space(nColWidth)
          else
            if (saFields[i][FLD_TYPE] == FLDTYPE_NEW .and. lNew) ;
              .or. (saFields[i][FLD_TYPE] == FLDTYPE_UPDATE)
              lModified := .t.
            endif
            cBefore += padr(utos(&(saFields[i][FLD_NAME])),nColWidth)
            cAfter += padr(utos(uValue),nColWidth)
          endif
        endif
      endif
      if saFields[i][FLD_TYPE] == FLDTYPE_NEW
        if lNew
          if ! lSimul
            &(saFields[i][FLD_NAME]) := uValue
          endif
        endif
      elseif saFields[i][FLD_TYPE] == FLDTYPE_UPDATE
        if ! lSimul
          &(trim(saFields[i][FLD_NAME])) := uValue
        endif
      endif
      if lLog
        cBefore += " "
        cAfter  += " "
      endif
    next i
    if ! lSimul
      unlock record
    endif
    if lNew
      for i := 1 to len(saOnNew)
        cMac := saOnNew[i]
        if ! xparse(cMac)
          RETURN .f. if ! Confirm( ;
            cMac + " : onNew action failed !", ;
            MsgContinue() ;
          )
        endif
      next i
    endif
    for i := 1 to len(saRecAfter)
      cMac := saRecAfter[i]
      if ! xparse(cMac)
      * if ! xeval(saRecAfter[i],lNew,lSimul)
        RETURN .f. if ! Confirm( ;
          cMac + " : post-import action failed !", ;
            MsgContinue() ;
        )
      endif
    next i
    if lLog .and. lModified
      PrintLine(repl("-",p_cpl()))
      PrintLine(cBefore)
      PrintLine(cAfter)
    endif
  elseif lNew .and. ! lSimul
    RETURN .f. if ! ddRecLock()
    delete
    unlock record
  endif
enddo
RETURN (scAction != ACTION_Q)


FUNCTION csv2array(cLine)
local a := {}
local nPos
do while .t.
  if left(cLine,1) == '"'
    cLine := substr(cLine,2)
    if (nPos := at('"',cLine)) == 0
      SetMsg('parse error : missing second " at '+ntrim(len(a)))
      RETURN NIL
    endif
    aadd(a,left(cLine,nPos-1))
    cLine := substr(cLine,nPos+1)
  elseif (nPos := at(',',cLine)) == 0
    aadd(a,cLine)
    cLine := ""
  else
    aadd(a,left(cLine,nPos-1))
    cLine := substr(cLine,nPos+1)
  endif
  RETURN a if empty(cLine)
  if .not. left(cLine,1) $ ';,'
    SetMsg(', or ; expected at '+ntrim(len(a)))
    RETURN NIL
  endif
  cLine := substr(cLine,2)
enddo
RETURN a


FUNCTION f_export(fd)
local i
local j
local cMac
* local cLine
MsgDisp2(ntrim0(snRecCount++ / lastrec() * 100) + "%")
for i := 1 to len(saRules)
  cMac := saRules[i]
  RETURN .t. if ! (&cMac)
next i
i_count++
* MsgDisp2(ntrim0(i_count / lastrec() * 100) + "%")
for j := 1 to snLoop
  * cLine := ""
  for i := 1 to len(saFields)
    * fwrite(fd,CvtString( saCvtList, xeval(saFields[i][FLD_EXPR]) ))
    fwrite(fd,CvtString( saCvtList, FldValue(i) ))
    if scDelim != NIL
      if i < len(saFields)
        fwrite(fd, xparse(scDelim))
      endif
    endif
  next i
  fwrite(fd,CR_LF)
next j
RETURN .t.


STATIC FUNCTION f_modify(ad)
local i
local cMac
local cLine := ""
MsgDisp2(ntrim0(i_count++ / lastrec() * 100) + "%")
for i := 1 to len(saRules)
  cMac := saRules[i]
  RETURN .t. if ! (&cMac)
next i
if ddRecLock()
  i_Confirm(.f.) // scSeekKey)
  if scAction == ACTION_A .or. scAction == ACTION_Y
    for i := 1 to len(saFields)
      if saFields[i][FLD_TYPE] == FLDTYPE_UPDATE
        * &(saFields[i][FLD_NAME]) := xeval(saFields[i][FLD_EXPR])
        &(saFields[i][FLD_NAME]) := FldValue(i)
      endif
    next i
  endif
  unlock record
else
  RETURN .f.
endif
RETURN (scAction != ACTION_Q)


STATIC FUNCTION AddField(cLine,nFldType)
local fld := array(FLD_ALEN)
local nPos := 0
// if left(cLine,1) == "&" 20021205
// if left(cLine,1) $ "&=" 20021205
if left(cLine,1) == "="
  nPos := at(" ",cLine)
  RETURN .f. if nPos == 0
  fld[FLD_NAME]   := xparse(substr(left(cLine,nPos-1),2))
  cLine := substr(cLine,nPos)
elseif left(cLine,1) == '"'
  nPos := at('"',substr(cLine,2))
  RETURN .f. if nPos == 0
  fld[FLD_NAME]   := substr(cLine,2,nPos-1)
  cLine := substr(cLine,nPos+2)
else
  nPos := at(" ",cLine)
  RETURN .f. if nPos == 0
  fld[FLD_NAME]   := left(cLine,nPos-1)
  cLine := substr(cLine,nPos)
endif
cLine := alltrim(cLine)
* do while substr(cLine,nPos,1) == " "
*   nPos++
* enddo
fld[FLD_EXPR]   := cLine
fld[FLD_TYPE]   := nFldType
* Warning("field '"+fld[1]+"' : '"+fld[2]+"'")
aadd(saFields,fld)
RETURN .t.

FUNCTION AddExpField(cHeader,xcExpr)
local fld := array(FLD_ALEN)
fld[FLD_NAME]   := cHeader
fld[FLD_EXPR]   := xcExpr
fld[FLD_TYPE]   := FLDTYPE_UPDATE
aadd(saFields,fld)
RETURN .t.

FUNCTION AddExpFlds(ad)
/*
  adds all fields of table ad to this filter
*/
local i
local oGet
local fld
for i := 1 to len( ad[AD_FIELDS] )
  oGet := ad[AD_FIELDS][i]
  if (! FLDATTR_V $ oGet[AG_ATTRIB]) .and. (! "H" $ oGet[AG_ATTRIB])
    fld := array(FLD_ALEN)
    fld[FLD_NAME]   := oGet[AG_NAME]
    fld[FLD_EXPR]   := "val2csv('"+oGet[AG_TYPE]+"',";
                       +ad[AD_NAME]+"->"+oGet[AG_NAME]+")"
    fld[FLD_TYPE]   := FLDTYPE_UPDATE
    aadd(saFields,fld)
  endif
next i
RETURN .t.
*

FUNCTION i_confirm(lNew)
local i
local a := {}
local aConfirm := {}
* local aAct := {}
local cLine
local nHeight := 4
local nWidth  := 50
* aadd(aActions, { 65, {|| slOverwrite := .t., NIL }})
* aadd(aActions, { 97, {|| slOverwrite := .t., NIL }})
RETURN NIL if scAction == ACTION_A // if slOverwrite
for i := 1 to len(saFields)
  if saFields[i][FLD_TYPE] == FLDTYPE_DISPLAY
    cLine := saFields[i][FLD_NAME]
    * cLine += xeval(saFields[i][FLD_EXPR])
    cLine += FldValue(i)
    nWidth := max(nWidth,len(cLine))
    aadd(a, cLine)
  * elseif saFields[i][FLD_TYPE] == FLDTYPE_UPDATE
  *   cLine := saFields[i][FLD_NAME]
  *   cLine += &(saFields[i][FLD_NAME])
  *   cLine += " -> " + &(saFields[i][FLD_EXPR])
  *   nWidth := max(nWidth,len(cLine))
  *   aadd(a, cLine)
  endif
next i
if len(a) == 0
  if scSeekKey != NIL .and. scSeekKey != "*"
    aadd(a, "SeekKey : " + xparse(scSeekKey))
  endif
endif
open window "Record update" size len(a)+3, nWidth + 4 help UPDATE
for i := 1 to len(a)
  say a[i]
  WinCr()
next i
if lNew
  say "Append this record (Yes/No/Always/Quit) ? "
else
  say "Update this record (Yes/No/Always/Quit) ? "
endif
get scAction picture "!" valid scAction $ "YNAQ"
nKey := ReadScr()
close window
if nKey == K_ESC
  scAction := ACTION_Q
endif
*RETURN .f. if lastkey() == K_ESC
*RETURN .t.
RETURN NIL


  FUNCTION eac_allo(c)
  c := upper(c)
  if left(c,1) == "D"
    RETURN "Herrn" if right(c,1) == "H"
    RETURN "Firma" if right(c,1) == "F"
    RETURN "Frau" if right(c,1) == "D"
    RETURN "Eheleute" if right(c,1) == "E"
  endif
  RETURN "Monsieur" if right(c,1) == "H"
  RETURN "Ets" if right(c,1) == "F"
  RETURN "Madame" if right(c,1) == "D"
  RETURN ""

FUNCTION i_readline(fd,nWidth)
local cLine
RETURN freadline(fd) if nWidth == NIL
cLine := freadstr(fd,nWidth)
RETURN NIL if empty(cLine)
RETURN cLine

FUNCTION strsplit(cStr,cDelim,nItem)
local a := ListAsArray(cStr,cDelim)
RETURN "" if len(a) < nItem
RETURN a[nItem]

FUNCTION i_OutputFile ; RETURN scOutputFile


FUNCTION Dbf2Ascii(cInFile,cOutFile,cFldDelim,cRecDelim)
local lOkay := .t.
local nPos
local cFldName
local cFldQuote := "" // chr(34)
local aFld
local i
local fd
local nCount := 0
local cMsg
default cFldDelim to chr(9)
default cRecDelim to chr(13)+chr(10)
if (fd := fcreate(cOutFile)) == -1
  RETURN ! SetMsg(cOutFile+MsgDosError(ferror()))
endif
ddCloseAll()
select 0
use (cInFile) via "DBFNTX" shared readonly
do while neterr()
  cMsg := cInFile + MsgDosError()
  if ! Confirm( ;
    cMsg, MsgRetry(), NIL, "WRNOPEN" ;
  )
    SendConsole(cMsg)
    LstError(PRN_ABORT)
    RETURN .f.
  endif
  use (cInFile) via "DBFNTX" shared readonly
  * DbUseArea( , "DBFNTX", cInFile, NIL , .t., .t. )
enddo
aFld := dbstruct()
for i := 1 to len(aFld)
  if aFld[i][DBS_TYPE] == "C" ;
    .or. aFld[i][DBS_TYPE] == "N" ;
    .or. aFld[i][DBS_TYPE] == "D"
    * .or. aFld[i][DBS_TYPE] == "M" 
    cFldName := aFld[i][DBS_NAME]
    fwrite(fd,cFldName)
    fwrite(fd,cFldDelim)
  endif
next i
fwrite(fd,cRecDelim)
do while ! eof()
  nCount++
  MsgDisp2(str(nCount*100/lastrec(),6,0) + "%")
  if TaskInter()
    lOkay := .f.
    exit
  endif
  for i := 1 to len(aFld)
    cFldName := aFld[i][DBS_NAME]
    if aFld[i][DBS_TYPE] == "C"
      fwrite(fd,cFldQuote + (&cFldName) + cFldQuote)
      fwrite(fd,cFldDelim)
    elseif aFld[i][DBS_TYPE] == "N"
      fwrite(fd,str(&cFldName,aFld[i][DBS_LEN],aFld[i][DBS_DEC]))
      fwrite(fd,cFldDelim)
    * elseif aFld[i][DBS_TYPE] == "M"
    *   fwrite(fd,cFldQuote + (&cFldName) + cFldQuote)
    elseif aFld[i][DBS_TYPE] == "D"
      if empty(&cFldName)
        fwrite(fd,cFldQuote + cFldQuote)
      else
        fwrite(fd,cFldQuote + dtoc(&cFldName) + cFldQuote)
      endif
      fwrite(fd,cFldDelim)
    endif
  next i
  fwrite(fd,cRecDelim)
  skip
enddo
fclose(fd)
use
RETURN lOkay

#endif DEF_IMPORT

FUNCTION i_plz(c,nWhat)
local nPos
local i := 0
local j := 0
local cPays  := "B"
local cIdPlz
local cName
c := alltrim(c)
do while i <= len(c)
  i++
  if substr(c,i+j,1) $ "0123456789"
    exit
  endif
enddo
// i : Beginn PLZ (erstes numerisches Zeichen)
RETURN c if i > len(c)
do while i+j <= len(c)
  if ! substr(c,i+j,1) $ "0123456789"
    exit
  else
    j++
  endif
enddo
// j : LÑnge Postleitzahl
if i > 1
  cPays  := upper(alltrim(strtran(left(c,i-1),"-","")))
endif
cIdPlz := substr(c,i,j)
cName := ltrim(substr(c,i+j))
if cPays == "NL"
  if empty(substr(cName,3,1))
    cIdPlz := cIdPlz + " " + left(cName,2)
    cName := substr(cName,4)
  endif
endif
*if (nPos := at(" ",cName)) != 0
*  cName := substr(cName,nPos+1)
*endif
*if (nPos := at("-",cIdPlz)) != 0
*  cPays  := alltrim(left(cIdPlz,nPos-1))
*  cIdPlz := alltrim(substr(cIdPlz,nPos+1))
*endif
RETURN padr(cPays,3)  if nWhat == 1
RETURN padr(cIdPlz,8) if nWhat == 2
RETURN cName

FUNCTION eac_mfc(cIdMfc)
** B : ab Rechnungsdatum
** A : ab Monatsende
RETURN "BAR" if upper(trim(cIdMfc)) == "B0"
RETURN "30" if upper(trim(cIdMfc)) == "B30"
RETURN "30M" if upper(trim(cIdMfc)) == "A30"
RETURN "60" if upper(trim(cIdMfc)) == "B60"
RETURN "60M" if upper(trim(cIdMfc)) == "A60"
RETURN cIdMfc


