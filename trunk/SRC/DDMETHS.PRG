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
#include "dbstruct.ch"

* static saStat := { }  // only used by PushStatus() and PopStatus()

#define AS_AREA   1
#define AS_RECNO  2
#define AS_ORDER  3
#define AS_FILTER 4

#ifdef LG_FRENCH
  * #define MSG003 " : fichier bloqu‚ par un autre utilisateur."
  #define MSG004 "Nettoyage de "
  #define MSG005 " Abandon."
  #define MSG006 " enregistrements."
  #define MSG007 " n'existe pas."
  #define MSG007B "Cr‚er un fichier vide (O/N) ?"
  #define MSG008 "Reconstruction de "
  #define MSG009 "V‚rification de "
  static MSG010 := "Transcription "
  #define MSG011 "Erreur : "
  #define MSG012 " n'a pas ‚t‚ renomm‚ en "
  #define MSG013 "G‚n‚ration rapport technique..."
  #define MSG014 "Tapez O pour convertir "
  #define MSG015 " :"
#endif
#ifdef LG_GERMAN
  * #define MSG003 " : Datei durch anderen Benutzer gesperrt."
  #define MSG004 "Reinigen : "
  #define MSG005 " Abbruch."
  #define MSG006 " Datens„tze."
  #define MSG007 " existiert nicht."
  #define MSG007B "Leere Datei erstellen (J/N) ?"
  #define MSG008 "Neuindexieren "
  #define MSG009 "Tabellenstruktur berprfen "
  static MSG010 := "Umschreiben der Datei "
  #define MSG011 "Fehler : "
  #define MSG012 " wurde nicht umbenannt in "
  #define MSG013 "Internen Statusbericht schreiben..."
  #define MSG014 "Drcken Sie J um "
  #define MSG015 " zu konvertieren :"
#endif
#ifdef LG_EN
  #define MSG005 " Abbruch."
  #define MSG007 " does not exist."
  #define MSG007B "Create empty table (Y/N) ?"
  #define MSG008 "Generating index file "
  #define MSG009 "Check table structure "
  static MSG010 := "Rewriting file "
  #define MSG011 "Error : "
  #define MSG012 " could not be renamed to "
  #define MSG013 "Generating status report..."
  #define MSG014 "Are you sure you want to convert "
  #define MSG015 " ? (Y/N)"
#endif


* #ifdef DEF_NETWORK


* #else
*
* FUNCTION ddRecLock() ; RETURN .t.
* FUNCTION ddLock()    ; RETURN .t.
*
* #endif DEF_NETWORK

**
** ddPack() - PACKs a database file and rebuilds all index files.
**
*FUNCTION ddPack( ad ) // b
*local i, cName
*local nRecCount
*local cPath := ddPath(ad)
*local cLine := "PACK : " + cPath + ad[AD_NAME] + ".DBF"
*local lDone := .f.
*MsgDisplay(cLine)
*use (cPath + ad[AD_NAME]) exclusive
*do while neterr()
*  if ! Confirm(cPath + ad[AD_NAME] + MSG003, MSG002 )
*    cLine += ": " + MSG003 + MSG005
*    rpt_write(cLine)
*    RETURN .F.
*  endif
*  use (cPath + ad[AD_NAME]) exclusive
*enddo
*nRecCount := lastrec()
*pack
*cLine += ": " + str(nRecCount,5) + " --> " + ;
*         str(lastrec(),5) + MSG006
*use
*lDone := ddIndex(ad)
*rpt_write(cLine)
*RETURN lDone

**
**
**
FUNCTION ddCheck( adDbf, lConfirm )
local cPath := ddPath(adDbf)
local cName := adDbf[AD_NAME] + dbf_ext() // ".DBF"
local lContinue := .t.
local lAllowLoss := .f.
default lConfirm to .t.
RETURN ddChkStruct(adDbf,lConfirm) if file( cPath + cName )
rpt_write( cPath + cName + MSG007)
RETURN .f. if ! Confirm(cPath + cName + MSG007, MSG007B )
dbcreate( cPath + adDbf[AD_NAME], ddStructure(adDbf) )
use
RETURN ddIndex( adDbf )
* if lConfirm
*   lContinue := Confirm(cPath + cName + MSG007, MSG007B )
* endif
* if lContinue
*   dbcreate( cPath + adDbf[AD_NAME], ddStructure(adDbf) )
*   use
*   lContinue := ddIndex( adDbf )
* endif
* RETURN lContinue

**
** ddIndex() - Rebuilds all index files of a database
**
FUNCTION ddIndex( ad, lAlways )
local i
local cName
local cExpr
local cFor
local cPath := ddPath(ad)
local lDone := .f.
local nError
RETURN .t. if IsReadOnly(ad)
default lAlways to .t.
use (cPath + ad[AD_NAME]) exclusive
do while dberror()
  nError := doserror()
  if ! Confirm(cPath + ad[AD_NAME] + MsgDosError(nError), MsgRetry() )
    rpt_write(cPath + ad[AD_NAME] + MsgDosError(nError) + MSG005)
    RETURN .f.
  endif
  use (cPath + ad[AD_NAME]) exclusive
enddo
#ifdef DEF_DBF
  if UseDbe() == "DBFNTX"
    lDone := .t.
    for i := 1 to len(ad[AD_AINDEX])
      if TaskInter()
        lDone := .f.
        exit
      else
        cName := cPath + ad[AD_NAME] + ntrim(i)
        if lAlways .or. ! file( cName + ntx_ext() )
          rpt_write( MSG008 + cName + ntx_ext() + " ...", RPT_DISPLAY )
          cExpr := ad[AD_AINDEX][i][AI_EXPR]
          cFor  := ad[AD_AINDEX][i][AI_FOR]
          if empty(cFor)
            index on &cExpr to (cName)
          else
            index on &cExpr to (cName) for &cFor
          endif
        endif
      endif
    next i
  endif
#endif DEF_DBF
#ifdef DEF_FOX
  if UseDbe() == "FOXCDX"
    cName := cPath + ad[AD_NAME] + ntx_ext()
    lDone := .t.
    if lAlways .or. ! file( cName )
      rpt_write( MSG008 + cName + " ...", RPT_DISPLAY )
      for i := 1 to len(ad[AD_AINDEX])
        if TaskInter()
          lDone := .f.
          exit
        else
          cExpr := ad[AD_AINDEX][i][AI_EXPR]
          cFor  := ad[AD_AINDEX][i][AI_FOR]
          if i == 1
            if empty(cFor)
              INDEX ON &cExpr TAG (str(i)) to (cName)
            else
              INDEX ON &cExpr TAG (str(i)) to (cName) for &cFor
            endif
          else
            if empty(cFor)
              INDEX ON &cExpr TAG (str(i))
            else
              INDEX ON &cExpr TAG (str(i)) for &cFor
            endif
          endif
        endif
      next i
    endif
  endif
#endif DEF_DBFCDX
use
RETURN lDone


**
** ddChkStruct()
**
STATIC FUNCTION ddChkStruct(ad,lConfirm)
local i,j, nErr := 0, lFound
local afIs
local afMust := ddStructure(ad)
local cPath := ddPath(ad)
local nError
local cMsg
local cName := ad[AD_NAME] + dbf_ext() // ".DBF"
*
rpt_write( MSG009 + cPath + cName + "...", RPT_DISPLAY )
use (cPath + ad[AD_NAME]) exclusive // shared readonly
* do while neterr()
do while dberror()
  nError := doserror()
  cMsg := cPath + ad[AD_NAME] + MsgDosError(nError)
  RETURN .f. if ! Confirm(cMsg, MsgRetry() )
  * 20050826 gx beklagt sich, dass TIM dann mit RTE abbricht.
  * if ! Confirm(cMsg, MsgRetry() )
  *   raise(cMsg)
  *   * rpt_write("--> " + MsgDosError(nError) + MSG005 )
  *   * RETURN 1
  * endif
  use (cPath + ad[AD_NAME]) exclusive // shared readonly
enddo
cMsg := ""
afIs := dbstruct()
for i := 1 to len(afMust)
  lFound := .f.
  for j := 1 to len(afIs)
    if afIs[j][DBS_NAME] == upper(afMust[i][DBS_NAME])
      lFound := .t.
      if afIs[j][DBS_LEN] != afMust[i][DBS_LEN]
        cMsg += ad[AD_NAME] + "->" + afMust[i][DBS_NAME] + ":len is " + ;
                ntrim(afIs[j][DBS_LEN]) + " instead of " + ;
                ntrim(afMust[i][DBS_LEN]) ;
                + CR_LF
        nErr ++
      elseif afIs[j][DBS_DEC] != afMust[i][DBS_DEC]
        cMsg += ad[AD_NAME] + "->" + afMust[i][DBS_NAME] + ":dec != " + ;
                ntrim(afMust[i][DBS_DEC]) ;
                + CR_LF
        nErr ++
      elseif afIs[j][DBS_TYPE] != afMust[i][DBS_TYPE]
        cMsg += ad[AD_NAME] + "->" + afMust[i][DBS_NAME] + ":type is " + ;
                afIs[j][DBS_TYPE] + " instead of " + ;
                afMust[i][DBS_TYPE] ;
                + CR_LF
        nErr ++
      endif
      exit
    endif
  next j
  if ! lFound
    cMsg += ad[AD_NAME] + "->" + afMust[i][DBS_NAME] + ;
            " : field not found" ;
            + CR_LF
    nErr++
  endif
next i
for j := 1 to len(afIs)
  lFound := .f.
  for i := 1 to len(afMust)
    if afIs[j][DBS_NAME] == upper(afMust[i][DBS_NAME])
      lFound := .t.
      exit
    endif
  next j
  if ! lFound
    cMsg += ad[AD_NAME] + "->" + afIs[j][DBS_NAME] + " : unknown field" ;
            + CR_LF
    nErr++
  endif
next i
rpt_write( cName + " contains  " + ntrim(lastrec()) + " record(s).")
use
if nErr != 0
  rpt_write( cMsg + CR_LF + "--> " + ntrim(nErr) + ;
             " structure error(s) in " + cName + "." )
  if lConfirm
    if ! Confirm(cMsg + CR_LF + MSG014 + cPath + cName + MSG015)
      rpt_write(cName + " : table has not been converted")
      RETURN .f.
    endif
  endif
  RETURN .f. if ! ddConvertDbf( ad )
  RETURN ddIndex( ad, .t. )
endif
RETURN ddIndex( ad, .f. )

FUNCTION HasMemo(fields)
local i
for i := 1 to len( fields )
  if fields[i][DBS_TYPE] == "M"
    RETURN .t.
  endif
next i
RETURN .f.

**
** ddConvertDbf()
**
FUNCTION ddConvertDbf( ad, xlFilter )
local i,j, nErr := 0
local afIs
local cOldFile  := ad[AD_NAME] + dbf_ext() // ".DBF"
*#ifdef DEF_ADS
*  local cTmpName := "_" + ad[AD_NAME]
*#else
  local cTmpName := "~" + ad[AD_NAME]
*#endif
local nRecCnt := 0
local afMust  := ddStructure(ad)
local lMemoExists := .F.
local cPath := ddPath(ad)
local nLastRec
local lStop := .f.
local lAllowLoss := .f.
local nError
local cMsg
default xlFilter to ".t."
*
SetKeepReport(.t.)
rpt_write( MSG010 + cPath + cOldFile + " :", RPT_DISPLAY )
lMemoExists := HasMemo(afMust)
select 0
dbcreate( cPath + cTmpName, afMust )
use (cPath + cTmpName) alias DBN exclusive
* 20030122
* do while neterr()
do while dberror()
  * nError := doserror()
  * if ! Confirm(cPath + cTmpName + MsgDosError(nError), MsgRetry() )
  cMsg := cPath + cTmpName + MsgDosError(doserror())
  if ! Confirm(cMsg, MsgRetry() )
    raise(cMsg)
    * rpt_write("--> " + MsgDosError(nError) + MSG005 )
    * RETURN .f.
  endif
  use (cPath + cTmpName) alias DBN exclusive
enddo
* 20030122
select 0
use (cPath + cOldFile) alias DBO exclusive
* do while neterr()
do while dberror()
  * nError := doserror()
  * if ! Confirm(cPath + cOldFile + MsgDosError(nError), MsgRetry() )
  cMsg := cPath + cOldFile + MsgDosError(doserror())
  if ! Confirm(cMsg, MsgRetry() )
    raise(cMsg)
    * rpt_write("--> " + MsgDosError(nError) + MSG005 )
    * RETURN .f.
  endif
  use (cPath + cOldFile) alias DBO exclusive
enddo
nLastRec := lastrec()
*
afIs := dbstruct()
* MsgDisplay(MSG010 + ad[AD_NAME] + "...")
* MsgDisplay(MSG010 + cPath + cOldFile + "...")
go top
do while ! eof() .and. ! lStop
  if &xlFilter
    select DBN
    append blank
    nRecCnt ++
    MsgDisp2(ntrim(DBO->(recno()))+"/"+ntrim(nLastRec))
    for i = 1 to len(afMust)
      for j = 1 to len(afIs)
        if        afIs[j][DBS_NAME] == upper(afMust[i][DBS_NAME]) ;
            .and. afIs[j][DBS_TYPE] == afMust[i][DBS_TYPE]
          if afIs[j][DBS_LEN] > afMust[i][DBS_LEN]
            if lAllowLoss .or. Confirm( ;
              MsgAllowLoss( ;
                ad[AD_NAME] + "->" + afMust[i][DBS_NAME] ;
              ) + CR_LF + ;
                ntrim(afIs[j][DBS_LEN]) + " wird " + ;
                ntrim(afMust[i][DBS_LEN]), ;
              MsgSure(), MSG_NO ;
            )
              lAllowLoss := .t.
            else
              rpt_write( ;
                "  " + MsgAllowLoss( ;
                  ad[AD_NAME] + "->" + afMust[i][DBS_NAME] ;
                ) ;
              )
              lStop := .t.
              exit
            endif
          endif
          DBN->&(afIs[j][DBS_NAME]) := DBO->&(afMust[i][DBS_NAME])
          exit
        endif
      next j
    next i
    if ad[AD_CONVERT] != NIL
      if ! eval(ad[AD_CONVERT])
        lStop := .t.
      endif
    endif
    select DBO
  endif
  if TaskInter()
    lStop := .t.
  endif
  skip
enddo
select DBN
use
select DBO
use
if lStop
  rpt_write( "  --> aborted")
  RETURN .f.
endif
rpt_write( "  --> " + ntrim(nRecCnt)+" /"+ntrim(nLastRec) + " records have been rebuilt." )
if file( cPath + ad[AD_NAME]+".OLD")
  ferase( cPath + ad[AD_NAME]+".OLD")
endif
if file( cPath + ad[AD_NAME]+".OLT")
  ferase( cPath + ad[AD_NAME]+".OLT")
endif
if ! ddRename( cPath + ad[AD_NAME] + dbf_ext() , ;
              cPath + ad[AD_NAME] + ".OLD" )
  RETURN .F.
endif
if ! ddRename( cPath + cTmpName + dbf_ext() , ;
              cPath + ad[AD_NAME] + dbf_ext() )
  RETURN .F.
endif
if lMemoExists
  if file(cPath + ad[AD_NAME] + dbt_ext())
    ddRename( cPath + ad[AD_NAME] + dbt_ext() , ;
              cPath + ad[AD_NAME] + ".OLT" )
  endif
  if ! ddRename( cPath + cTmpName + dbt_ext() , ;
                cPath + ad[AD_NAME] + dbt_ext() )
    RETURN .F.
  endif
endif
RETURN .T.

FUNCTION MsgAllowLoss(cName)
#ifdef LG_GERMAN
RETURN "Achtung : m”glicher Datenverlust in " + cName
#endif
#ifdef LG_FRENCH
RETURN "Attention : danger de perte de donn‚es dans " + cName
#endif
#ifdef LG_EN
RETURN "Warning : possible data loss in " + cName
#endif

**
** ddRename()
**
FUNCTION ddRename(cOldName,cNewName)
do while frename(cOldName,cNewName) == -1
  RETURN .F. if ! Confirm( ;
    MSG011 + cOldName + MSG012 + cNewName, ;
    MsgRetry() ;
  )
enddo
RETURN .T.


**
** ddStructure() - Returns a structure array
**
FUNCTION ddStructure( ad, cAttrib )
local aStruct := { }
local i
local oGet
for i := 1 to len( ad[AD_FIELDS] )
  oGet := ad[AD_FIELDS][i]
  if (! "V" $ oGet[AG_ATTRIB]) .and. (! "H" $ oGet[AG_ATTRIB])
    if empty(cAttrib) .or. cAttrib $ oGet[AG_ATTRIB]
        aadd( aStruct, { oGet[AG_NAME], ;
                         type2dbf(oGet[AG_TYPE]), ;
                         oGet[AG_LEN], ;
                         oGet[AG_DEC] ;
                       } ;
            )
    endif
  endif
next i
RETURN aStruct

FUNCTION type2dbf(cType)
RETURN "C" if cType == GTYPE_LOGICAL
RETURN "C" if cType == GTYPE_AMOUNT
if cType == GTYPE_PWD
  * #ifdef DEF_ADS
  *   RETURN "X" if UseAdsDbe()
  * #endif
  RETURN "C"
endif
RETURN "C" if cType == GTYPE_QTY
RETURN cType


**
** ddReport()
**
FUNCTION ddReport
local i
local j
local nTotDbf := 0
local nTotNtx := 0
local nSelect := select()
* local aList := ddDataList()
local cLine
* local lNeeded
* raus am 20070327 MsgDisplay(MSG013) // falls RTE vor appsys.prg
rpt_write( "User directory : " + curdir() , RPT_URGENT )
rpt_write( "Data directory : " + DbPath() , RPT_URGENT )
rpt_write("  List of open database files :")
rpt_write("  Area Alias    Index key                    Order #Ntx RecNo" )
for i := 1 to 250
  dbSelectArea(i)
  if !empty(alias())
    j := 0
    do while .t.
      if empty(indexkey(j+1))
        exit
      endif
      j++
    enddo
    nTotDbf ++
    nTotNtx += j
    cLine := " " + if( nSelect == i, "* ", "  ") +  str(i,3)
    cLine += " " + padr(alias(),8)
    cLine += " " + padr(indexkey(),30)
    cLine += " " + str(indexord(),3)
    cLine += " " + str(j,4)
    cLine += " " + ntrim(recno()) + "/" + ntrim(lastrec())
    ** for j := 1 to len(aList)
    **   if aList[j][AD_NAME] == alias()
    **     if aList[j][AD_NEEDED]
    **       cLine += " Y"
    **     else
    **       cLine += " N"
    **     endif
    **   endif
    ** next i
    ** cLine += " *"
    rpt_write(cLine)
    if ! empty(dbfilter())
      rpt_write(space(7) + "Filter : " + dbfilter() )
    endif
    j := 1
    do while .t.
      if empty(dbRelation(j))
        exit
      endif
      rpt_write("   -> relation : " + dbRelation(j) )
      j++
    enddo
  endif
next i
rpt_write("  Total : " + ntrim(nTotDbf) + " open database files." )
rpt_write("          " + ntrim(nTotNtx) + " open index files." )
rpt_write("")
** rpt_write(ntrim(len(aList)) + " data dictionaries in use :")
** cLine := ""
** for i := 1 to len(aList)
**   cLine +=  aList[i][AD_NAME]
**   if i != len(aList)
**     cLine += ","
**   endif
** next i
** rpt_write( cLine )
SetKeepReport(.T.)
select (nSelect)
AreaReport()
WinReport()
RETURN NIL


#ifdef DEF_XFER

**
** ddImport()
**
** check if there is an import file to be imported.
** open import file with alias IMPORT
** loop through IMPORT file and import fields
**
** bKey : a Code block that returns a string used as primary key
**        this Code Block knows that an alias IMPORT exists
**
FUNCTION ddImport(ad,bKey,bPost)
local cAlias := ad[AD_NAME]
local cImportFile := dbPath() + "\IMPORT\X" + cAlias + dbf_ext()
local aStruct := ddStructure(ad,"X") // only fields with attribute "X"
local i
local cFld
local nSelect := select()
local cImpKey
local nOld := 0
local nNew := 0
RETURN .f. if ! file(cImportFile)
RETURN .f. if ! Confirm("Drcken Sie J um " + cAlias + " zu importieren : ")
MsgDisplay( "Importiere " + cImportFile + "..." )
return .f. if ! ddLock()
select 0
use (cImportFile) alias IMPORT
do while ! eof()
  nOld++
  select (nSelect)
  if bPost != NIL
    if eval(bPost)
      nNew++
    endif
  else
    cImpKey := eval(bKey)
    seek cImpKey
    if eof()
      append blank
      nNew++
    endif
    for i := 1 to len(aStruct)
      cFld := aStruct[i][DBS_NAME]
      (cAlias)->&(cFld) := IMPORT->&(cFld)
    next i
  endif
  select IMPORT
  MsgDisp2(ntrim(nNew) + "/" + ntrim(nOld))
  skip
enddo
use
erase (cImportFile)
select (nSelect)
unlock
rpt_write( ;
  cAlias + " : " + ntrim(nOld) + " Records importiert, davon " + ;
  ntrim(nNew) + " neue.", ;
  RPT_DISPLAY ;
)
SetKeepReport(.t.)
RETURN .t.

**
** ddExport()
**
** check if there is a dbf to be imported.
** eval() bBlock once on each record in IMPORT
**
FUNCTION ddExport(ad,bBlock)
local cAlias := ad[AD_NAME]
local aStruct := ddStructure(ad,"X") // only fields with attribute "X"
local i
local nRecTotal  := 0
local nRecExport := 0
local cFld
default bBlock to {||.t.}
if OpenExport(ad)
  go top
  do while !eof() .and. ! TaskInter()
    if eval(bBlock)
      select EXPORT
      append blank
      for i := 1 to len(aStruct)
        cFld := aStruct[i][DBS_NAME]
        EXPORT->&cFld := (cAlias)->&cFld
      next i
      select (cAlias)
      nRecExport++
    endif
    nRecTotal++
    MsgDisp2(ntrim(nRecExport) + "/" + ntrim(nRecTotal))
    skip
  enddo
  CloseExport()
endif
select (cAlias)
rpt_write( ;
  cAlias + " : " + ntrim(nRecExport) + " Records von " + ;
  ntrim(nRecTotal) + " wurden exportiert.", ;
  RPT_DISPLAY ;
)
* SetKeepReport(.t.)
RETURN .T.

**
** OpenExport()
**
** check if there is a dbf to be imported.
** EXPORT does NOT become current work area !
**
FUNCTION OpenExport(ad)
local cAlias := ad[AD_NAME]
local cExportFile := dbPath() + "\EXPORT\X" + cAlias + dbf_ext()
local aStruct := ddStructure(ad,"X") // only fields with attribute "X"
local nSelect := select()
if file(cExportFile)
  if ! Confirm(cExportFile + " berschreiben (J/N) ?")
    RETURN .F.
  endif
endif
MsgDisplay( "Exportiere " + cExportFile + "..." )
select 0
dbcreate(cExportFile,aStruct)
if ! file(cExportFile)
  Warning("Fehler beim Erstellen von " + cExportFile)
  select (nSelect)
  RETURN .f.
endif
use (cExportFile) alias EXPORT exclusive
select (nSelect)
RETURN .t.


**
** CloseExport()
**
** closes EXPORT alias
** ? Does NOT return to original work area (the one before open export)
**
FUNCTION CloseExport
EXPORT->(dbclosearea())
* use
RETURN .T.

#endif // DEF_XFER

*FUNCTION DebugWait(cTitle)
*local i
*MsgDisplay(cTitle+"...")
*for i := 1 to 5000
*  MsgDisp2(ntrim0(i/50)+"%")
*next i
*RETURN NIL

