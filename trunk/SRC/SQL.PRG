** Copyright (c) 2004-2008 Luc Saffre
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

** created 2004-02-05

#include "LIB.CH"
#include "dbstruct.ch"

#ifdef DEF_SQLEXPORT
static saSqlConvert := {}
#endif DEF_SQLEXPORT


#ifdef DEF_SQLEXPORT

#define SQLCVT_TYPE 1
#define SQLCVT_EXPR 2
#define SQLCVT_NAME 3

FUNCTION SqlInit()
saSqlConvert := {}
RETURN .t.

FUNCTION SqlCreateDb(fd,cAliases)
local a := AppDataList()
local i
* if cActInit != NIL
*   RETURN .f. if ! ActExec(cActInit)
* endif
for i := 1 to len(a)
  if empty(cAliases) .or. a[i][AD_NAME] $ cAliases
    RETURN .f. if ! SqlCreateTable(fd,a[i])
  endif
next i
RETURN .t.

FUNCTION AddSqlConvert(cAlias,cFldName,cType,cExpr,cNewFldname)
default cNewFldName to cFldName
aadd(saSqlConvert, { cAlias, cFldName, cType, cExpr,cNewFldName } )
RETURN .t.


FUNCTION SqlCreateTable(fd,ad)
* FUNCTION SqlCreateTable(ad,cSqlFile,lOverwrite)
local a
local cAlias := ad[AD_NAME]
* local fd
local lOkay := .t.
local i
local cField
local aFields := {}
local aSql
local aDbfFields
local cSep
* default lOverwrite to .f.
* default cSqlFile to AppPath()+"\temp\"+cAlias+".SQL"
* if !lOverwrite .and. file(cSqlFile)
*   RETURN .f. if ! Confirm(cSqlFile + MsgOverwrite())
* endif
* if (fd := fcreate(cSqlFile)) == -1
*   SetMsg(cSqlFile + MsgDosError(ferror()))
*   RETURN .f.
* endif
* MsgDisplay("Writing " + cSqlFile + "...")
MsgDisplay("CREATE TABLE " + cAlias + "...")
open area ad
  fwrite(fd, "PRAGMA synchronous=OFF;" + CR_LF)
  fwrite(fd, "CREATE TABLE " + cAlias + " (" + CR_LF)
  aDbfFields := ddStructure(ad) // dbstruct()
  cSep := "  "
  for i := 1 to len(aDbfFields)
    if (a := SqlConvert(cAlias,aDbfFields[i][DBS_NAME])) != NIL
      if ! empty(a[SQLCVT_EXPR])
        fwrite(fd,cSep + a[SQLCVT_NAME] + " " + a[SQLCVT_TYPE])
        aadd(aFields,a[SQLCVT_EXPR])
      endif
    else
      * fwrite(fd, "  " + aDbfFields[i][DBS_NAME] + " " )
      fwrite(fd, cSep + name2sql(aDbfFields[i][DBS_NAME]) + " " )
      if aDbfFields[i][DBS_TYPE] == "C"
        fwrite(fd,"CHAR(" + ntrim(aDbfFields[i][DBS_LEN]) + ")")
        aadd(aFields, ;
          "MemoToSql(trim(" + cAlias + "->" + aDbfFields[i][DBS_NAME] ;
          + "))" ;
        )
      elseif aDbfFields[i][DBS_TYPE] == "D"
        fwrite(fd,"DATE")
        aadd(aFields, ;
          "DateToSql("+cAlias+"->"+aDbfFields[i][DBS_NAME]+")" ;
        )
      elseif aDbfFields[i][DBS_TYPE] == "N"
        fwrite(fd,"DECIMAL("+ ;
          ntrim(aDbfFields[i][DBS_LEN]) + "," + ;
          ntrim(aDbfFields[i][DBS_DEC]) + ;
        ")")
        aadd(aFields, ;
          "ltrim(str("+cAlias+"->"+aDbfFields[i][DBS_NAME]+"," ;
          +ntrim(aDbfFields[i][DBS_LEN])+",";
          +ntrim(aDbfFields[i][DBS_DEC])+"))" ;
        )
      elseif aDbfFields[i][DBS_TYPE] == "L"
        fwrite(fd,'ENUM("y","n")')
        aadd(aFields, ;
          "chr(34)+if(" ;
          + cAlias + "->" + aDbfFields[i][DBS_NAME]  ;
          + ",'y','n')+chr(34)" ;
        )
      elseif aDbfFields[i][DBS_TYPE] == "M"
        fwrite(fd,'TEXT')
        aadd(aFields, ;
          "MemoToSql("+cAlias+"->"+aDbfFields[i][DBS_NAME]+")" ;
        )
      endif
    endif
    cSep := "," + CR_LF + "  "
    * if i == len(aDbfFields)
    *   fwrite(fd,CR_LF)
    * else
    *   fwrite(fd,"," + CR_LF)
    * endif
  next i
  cSep := "," + CR_LF + "  PRIMARY KEY (" + CR_LF
  for i := 1 to len(ad[AD_FIELDS])
    if "P" $ ad[AD_FIELDS][i][AG_ATTRIB]
      fwrite(fd, cSep + ad[AD_FIELDS][i][AG_NAME])
      cSep := ","
    endif
  next i
  if cSep == ","
    fwrite(fd, ")" + CR_LF)
  endif

  fwrite(fd, ");" + CR_LF)
  fwrite(fd, "BEGIN TRANSACTION;" + CR_LF)
  go top
  do while ! eof()
    if TaskInter()
      lOkay := .f.
      exit
    endif
    fwrite(fd, "INSERT INTO " + cAlias + " VALUES (")
    for i := 1 to len(aFields)
      fwrite(fd,xparse(aFields[i]))
      if i < len(aFields)
        fwrite(fd,",")
      endif
    next i
    fwrite(fd, ");" + CR_LF)
    skip
  enddo
  // fwrite(fd, "COMMIT;" + CR_LF)
  fwrite(fd, "END TRANSACTION;" + CR_LF)
close area
// fclose(fd)
RETURN lOkay



STATIC FUNCTION SqlConvert(cAlias,cFldName)
local i
for i := 1 to len(saSqlConvert)
  if saSqlConvert[i][1] == cAlias .and. saSqlConvert[i][2] == cFldName
    RETURN { saSqlConvert[i][3], saSqlConvert[i][4], saSqlConvert[i][5]}
  endif
next i
RETURN NIL

STATIC FUNCTION name2sql(cName)
RETURN "_Limit" if upper(cName)=="LIMIT"
RETURN "_From" if upper(cName)=="FROM"
RETURN cName

#endif DEF_SQLEXPORT

FUNCTION DateToSql(d)
RETURN "NULL" if empty(d)
* RETURN dtocf(d,"'yyyy-mm-dd'")
RETURN dtos(d)

FUNCTION MemoToSql(c)
return "NULL" if empty(c)
c := trim(strtran(c,chr(141)," "))
* c := DrvCvtString(c)
c := strtran(c,'"','""')
RETURN '"'+c+'"'
*RETURN '"'+c+'"' if ! '"' $ c
*RETURN "'"+c+"'" if ! "'" $ c
*RETURN '"MemoToSql() failed"'


