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
** Definitions
** - an Area is a set of tables
** - an Area Descriptor Array describes an area. For each table it
**   contains a Status descriptor array.
** - the Status Descriptor Array is used to save/restore the status of
**   a single table.  [TABLE_NAME] contains the tablename
**                    [2] contains "needed" status
**                    [3] recno()
**                    [4] indexord()
** - the Area Stack (saAreas) is the list of open areas. Each element
**   is an array containing [1] the select() value before the area was
**                              opened
**                          [2] the Area descriptor array (aArea)
**                          [3] the SetBreakTrap() setting
**
**
**  OPEN AREA <table list>
**     1) guarantees that :             2) does not affect :
**   - the alias is available           - recno() (if area was already open)
**   - indexord() is set to 1
**

REQUEST header
REQUEST recsize

#include "LIB.CH"

**
** "table status descriptor array" returned by ddOpen() :
**
* #define TABLE_AD   1  // ad of the table
#define TABLE_NAME   1  // alias name
#define TABLE_PATH   2  // complete path
#define TABLE_RECNO  3  // previous recno (NIL if none)
#define TABLE_ORDER  4  // previous order
// #define TABLE_ARCHIVE  5  // is it opened in archive or not?
// #define TABLE_EXCL      5
#define TABLE_RECLOCK   5 // no longer used 20020924
#define TABLE_ALEN   5

#define AREA_SELECT    1
#define AREA_TABLES    2
#define AREA_BREAKTRAP 3
#define AREA_SUFFIX    4
#define AREA_EXCL      5
#define AREA_RDONLY    6
#define AREA_RECLOCK   7
#define AREA_DESCEND   8
#define AREA_ALEN      8

#define USAGE_ALIAS  1
#define USAGE_PATH   2
#define USAGE_COUNT  3
#define USAGE_OPEN   4
// #define USAGE_RDONLY  5
#define USAGE_ALEN    4



static saKeepOpen  := {} //
static saUsages      := {} //
static saAreas := {}
* static saTables    := {}


static saRecLocks := {}
#define RL_SELECT 1
#define RL_ISLOCKED 2
#define RL_ALEN 2

* static slRecLock := .f.
* static saLockStack := {}

#ifdef LG_FRENCH
  * #define MSG001  "Le fichier "
  * static MSG002 := " : impossible d'ouvrir ce fichier, erreur DOS "
  * static MSG003 := "Tapez O pour r‚essayer l'accŠs ([Alt-F1] = Aide) :"
  * #define MSG016 "V‚rifiez plus tard l'enregistrement concern‚. D'accord ?"
  #define MSG001 " : enregistrement bloqu‚ par un autre utilisateur."
  * #define MSG002 "O pour r‚essayer l'accŠs"
#else
  * #define MSG001  "Zugriff verweigert auf Datei "
  * static MSG002 := " : Datei kann nicht ge”ffnet werden, DOS-Fehler "
  * static MSG003 := "J um erneut zu versuchen :"
  * #define MSG016 "Der betroffene Record muss nachtr„glich berprft werden. Einverstanden ?"
  #define MSG001 " : Datensatz durch anderen Benutzer gesperrt."
  * #define MSG002 "J um neu zu versuchen :"
#endif

static MSG_APPEND_FAILED := "APPEND : record lock failed"

static snDbfMaxSize := 200000000
static snDbtMaxSize :=  32000000

FUNCTION DbfMaxSize(n)
RETURN snDbfMaxSize if n == NIL
snDbfMaxSize := n
RETURN .t.

FUNCTION DbtMaxSize(n)
RETURN snDbtMaxSize if n == NIL
snDbtMaxSize := n
RETURN .t.


#ifndef __XPP__
  #xtranslate dbdescend() => .f.
#endif

**
** AreaOpen() - Open an area
**
** - Make sure that each specified table is opened
** - Save status of each table in order to restore it later by AreaClose()
** - Add area to stack
**
** If successful, the FIRST specified database will be selected.
**
FUNCTION AreaOpen( aData, lExcl, cSuffix, lRdOnly)
local i
local oTable
local aTables := {}
local nSelect := select()
local nOrder
local nRecNo
local lDescend := .f.
default lRdOnly to IsReadOnly(aData[1])
default cSuffix to ""
if used()
  nOrder := indexord()
  nRecNo := recno()
  #ifdef __XPP__
    lDescend := dbdescend()
  #endif __XPP__
endif
**
** Ich brauche kein "default lExcl to ..." zu machen, weil AreaOpen()
** immer ber #command OPEN AREA aufgerufen wird. Wenn keine Klauses
** EXCLUSIVE angegeben ist, ist lExcl also durch den Pr„prozessor schon auf
** .f. gesetzt.
**
#ifndef DEF_NETWORK
  lExcl := .T.
#endif
for i := len(aData) to 1 step -1 // 20020924
  if aData[i] != NIL
    if (oTable := ddOpen( aData[i], lExcl, lRdOnly, cSuffix)) == NIL
      for i := 1 to len(aTables)
        if ! ddClose(aTables[i],lExcl,lRdOnly,cSuffix)
          Warning(SetMsg())
        endif
      next i
      if nOrder != NIL
        select (nSelect)
        ddSetOrder(nOrder)
        goto nRecNo
      endif
      RETURN .F.
    endif
    aadd(aTables, oTable )
  endif
next i
LogDebug("AreaOpen("+atail(aTables)[TABLE_NAME]+")")
aadd( saAreas, { ;
  nSelect, ;        // AREA_SELECT
  aTables, ;        // AREA_TABLES
  SetBreakTrap(), ; // AREA_BREAKTRAP
  cSuffix, ;        // AREA_SUFFIX
  lExcl, ;          // AREA_EXCL
  lRdOnly, ;        // AREA_RDONLY
  get_islocked(nSelect), ;  // AREA_RECLOCK
  lDescend ;        // AREA_DESCEND
} )                 // AREA_ALEN
set_islocked(select(),.f.)
#ifdef __XPP__
dbsetdescend(.f.)
#endif
RETURN .T.




**
** AreaClose()
**
** Jede einzelne Datei, die der Area angeh”rte, muss im Prinzip ihren
** vorherigen Status wiederhergestellt kriegen.
**
FUNCTION AreaClose
local area := atail(saAreas)
local i
LogDebug("AreaClose("+atail(area[AREA_TABLES])[TABLE_NAME]+")")
if get_islocked(select())
* if slRecLock // a_islock()
  raise(atail(area[AREA_TABLES])[TABLE_NAME]+" : record lock still active")
endif
* local oTable
* local cLine  := "AreaClose() : {"
* for i := len(area[AREA_TABLES]) to 1 step -1
*   cLine += area[AREA_TABLES][i][TABLE_NAME]
* next i
* cLine += "}"
* rpt_write(cLine)
for i := 1 to len( area[AREA_TABLES] )
  if ! ddClose(area[AREA_TABLES][i], ;
    area[AREA_EXCL],;
    area[AREA_RDONLY],;
    area[AREA_SUFFIX];
  )
    // Warning(SetMsg())
    raise(SetMsg())
  endif
  * a_poplock() // undo the previous a_pushlock() 20020924
next i
select (area[AREA_SELECT])
* 20030321 SetBreakTrap(area[AREA_BREAKTRAP])
* a_poplock() // area[AREA_RECLOCK]
if area[AREA_RECLOCK]
  LogDebug("AreaClose() : restore lock in "+alias())
  if ! ddRecLock()
     if Confirm("(Nur fr Experten) Fehler ignorieren (J/N)",NIL,MSG_NO)
       SendConsole("FEHLER IGNORIEREN")
     else
       * raise(atail(area[AREA_TABLES])[TABLE_NAME] ;
       * + " : restoring record lock failed")
       raise(alias() + " : restoring record lock failed")
     endif
   endif
endif
#ifdef __XPP__
  if used()
    dbSetDescend(area[AREA_DESCEND])
  endif
#endif
asize( saAreas, len(saAreas) - 1 )
RETURN .t.



STATIC FUNCTION LocateUsage(cAlias,cPath,lRdOnly)
local i
local usage
for i := 1 to len(saUsages)
  RETURN saUsages[i] if saUsages[i][USAGE_ALIAS] == cAlias
next i
usage := { ;
  cAlias, ; // USAGE_ALIAS
  cPath, ;  // USAGE_PATH
  0, ;      // USAGE_COUNT
  .f. ;     // USAGE_OPEN
}           // USAGE_ALEN
aadd(saUsages,usage)
RETURN usage


/*******

 Make sure that the specified table is open.
 If the table is already used by some other area, save its status to a
 status descriptor array to be used when the new area is closed.
 Return NIL if operation failed.

*******/
STATIC FUNCTION ddOpen( ad, lExcl, lRdOnly, cSuffix)
local table
local i
local lFound
local cAlias  := ad[AD_NAME] + cSuffix
local cPath := ddPath(ad)
local usage := LocateUsage(cAlias,cPath,lRdOnly)
// dbcommit() // 20070918
usage[USAGE_COUNT] += 1
if usage[USAGE_OPEN]
  if usage[USAGE_COUNT] == 1
    /*
    if this is the first one who really needs the table, then we must
    remove it from saKeepOpen.
    */
    lFound := .f.
    for i := 1 to len(saKeepOpen)
      if saKeepOpen[i][USAGE_ALIAS] == usage[USAGE_ALIAS]
        adel(saKeepOpen,i)
        asize(saKeepOpen,len(saKeepOpen)-1)
        lFound := .t.
        exit
      endif
    next i
    if ! lFound
      Warning("ddOpen() : lFound")
    endif
  endif
  select (cAlias)
  table := { ;
    cAlias, ;             // TABLE_NAME
    usage[USAGE_PATH], ;  // TABLE_PATH
    recno(), ;            // TABLE_RECNO
    indexord() ,;         // TABLE_ORDER
    get_islocked(select()) ;   // slRecLock   ;        // TABLE_RECLOCK
  }                       // TABLE_ALEN
  if usage[USAGE_PATH] == cPath
    ddSetOrder(1)
    * rpt_write(usage[USAGE_ALIAS]+" : was open")
    RETURN table
  endif
  LogDebug("StopUse because " ;
    + usage[USAGE_PATH]+usage[USAGE_ALIAS];
    + " needed in " + cPath)
  // since we need this alias in another path, we must close it first in
  // the old path
  RETURN .f. if ! StopUse(usage)
endif
usage[USAGE_PATH] := cPath
default table to { ;
  cAlias,  ;  // TABLE_NAME
  cPath,   ;  // TABLE_PATH
  NIL,     ;  // TABLE_RECNO
  NIL,     ;  // TABLE_ORDER
  .f.      ;  // TABLE_RECLOCK
}             // TABLE_ALEN
RETURN NIL if ! BeginUse(usage,ad,lExcl,lRdOnly,cSuffix)
RETURN table


*** War die zu schlieáende DBF vor diesem AREA schon (fr ein anderes
*** Area) n”tig ? Dann darf sie ja nicht geschlossen werden, sondern
*** ihr Status muss wiederhergestellt werden.
*** Schade brigens, dass man in Clipper den reclock()-Status nicht
*** speichern und wiederherstellen kann... (m”glich seit 20020917)
***
** restore previous state of this table
STATIC FUNCTION ddClose(oTable,lExcl,lRdOnly,cSuffix)
local i
local usage := LocateUsage(oTable[TABLE_NAME],oTable[TABLE_PATH],lRdOnly)
RETURN !SetMsg("ddClose() : usage was not open") if ! usage[USAGE_OPEN]
usage[USAGE_COUNT] -= 1
if usage[USAGE_COUNT] == 0
  ** alias is no longer needed
  if CfgKeepOpenFiles() == 0
    LogDebug("StopUse because KeepOpenFiles is 0")
    RETURN StopUse(usage)
  elseif len(saKeepOpen) >= CfgKeepOpenFiles()
    **
    ** Falls schon zuviele unntze Dateien offen sind, wird die erste
    ** DBF aus saKeepOpen geschlossen. Das ist dann ja die DBF, die
    ** schon am l„ngsten unntz rumh„ngt.
    **
    LogDebug("StopUse because len(saKeepOpen)>"+ntrim(CfgKeepOpenFiles()))
    RETURN .f. if ! StopUse(saKeepOpen[1])
    adel(saKeepOpen,1)
    saKeepOpen[len(saKeepOpen)] := usage
  else
    aadd(saKeepOpen,usage)
    * rpt_write(usage[USAGE_ALIAS]+" : keep open")
  endif
  RETURN .t.
endif
if usage[USAGE_PATH] != oTable[TABLE_PATH]
  ** this can only happen if archive.prg is used
  if usage[USAGE_COUNT] != 0
    Warning("Gonna close " + usage[USAGE_ALIAS])
  endif
  LogDebug("StopUse because " ;
    + usage[USAGE_PATH] + " != " + oTable[TABLE_PATH])
  RETURN .f. if ! StopUse(usage)
  usage[USAGE_PATH] := oTable[TABLE_PATH]
  RETURN .f. if ! BeginUse(;
    usage, ;
    GetTableDef(oTable[TABLE_NAME]),;
    lExcl, lRdOnly, cSuffix;
  )
endif
if oTable[TABLE_RECNO] != NIL
  select (usage[USAGE_ALIAS]) // (oTable[TABLE_NAME])
  goto oTable[TABLE_RECNO]
  set order to (oTable[TABLE_ORDER])
endif
RETURN .t.


STATIC FUNCTION BeginUse(usage,ad,lExcl,lRdOnly,cSuffix)
local cMsg
local cAlias := ad[AD_NAME] + cSuffix
local cPath  := usage[USAGE_PATH]
if !lRdOnly.and.IsReadOnly(ad)
  lRdOnly := .t.
endif
LogDebug("BeginUse() "+cAlias)
if usage[USAGE_OPEN]
  Warning(usage[USAGE_ALIAS] + " : was already open")
endif
select 0
if !empty(cSuffix)
  dbcreate(cPath + cAlias, ddStructure(ad))
  use
endif
if fsize(cPath+cAlias+dbf_ext()) > snDbfMaxSize
  cMsg := cPath + cAlias +dbf_ext()+" : file is bigger than 200 MB"
  if ! Confirm(cMsg,MsgContinue())
    raise(cMsg)
  endif
endif
if HasMemo(ddStructure(ad)) // [AD_FIELDS]))
  if fsize(cPath+cAlias+dbt_ext()) > snDbtMaxSize
    cMsg := cPath + cAlias +dbt_ext()+" : file is bigger than 32 MB"
    if ! Confirm(cMsg,MsgContinue())
      raise(cMsg)
    endif
  endif
endif
DbUseArea( , , cPath + cAlias, NIL , ! lExcl, lRdOnly )
* do while neterr()
do while dberror()
  cMsg := cAlias + MsgDosError()
  if ! Confirm( ;
    cMsg, MsgRetry(), NIL, "WRNOPEN" ;
  )
    raise(cMsg)
  endif
  DbUseArea( , , cPath + cAlias, NIL , ! lExcl, lRdOnly )
enddo
if empty(cSuffix)
  if ! openindex(ad,cPath,cAlias)
    IndCreate("DBCHECK",SetMsg())
    IndCreate("INDEX",SetMsg())
    raise(SetMsg())
  endif
endif
usage[USAGE_OPEN] := .t.
// usage[USAGE_RDONLY] := lRdOnly
RETURN .t.

STATIC FUNCTION openindex(ad,cPath,cAlias)
local cMsg
local i
#ifdef DEF_FOX
  if UseDbe() == "FOXCDX"
    OrdListAdd( cPath + cAlias )
    do while dberror()
      cMsg := cPath + cAlias + ntx_ext() + MsgDosError()
      RETURN !SetMsg(cMsg) if ! Confirm( cMsg, MsgRetry(), NIL, "WRNOPEN" )
      OrdListAdd( cPath + cAlias )
    enddo
    RETURN .t.
  endif
#endif DEF_FOX
#ifdef DEF_DBF
  for i := 1 to len(ad[AD_AINDEX])
    OrdListAdd( cPath + cAlias + ntrim(i) )
    do while dberror()
      cMsg := cPath + cAlias + ntrim(i) + ntx_ext() + MsgDosError()
      RETURN !SetMsg(cMsg) if ! Confirm( cMsg, MsgRetry(), NIL, "WRNOPEN" )
      OrdListAdd( cPath + cAlias + ntrim(i) )
    enddo
  next i
  RETURN .t.
#endif DEF_DBF
raise("no dbe found")
RETURN .f.



FUNCTION StopUse(u)
select (u[USAGE_ALIAS])
use
* u[USAGE_COUNT] -= 1
u[USAGE_OPEN] := .f.
LogDebug(u[USAGE_PATH] + u[USAGE_ALIAS]+" : StopUse")
RETURN .t.

FUNCTION AddRecTo(cSuffix)
local cAlias := alias()+cSuffix
local nSelect := select()
local aBuf := CopyRec()
local lOkay := .f.
select (cAlias)
if dbAddRec()
  PasteRec(aBuf)
  lOkay := .t.
  unlock record
endif
select (nSelect)
RETURN lOkay

FUNCTION AddRecFrom(cSuffix)
local cAlias := alias()+cSuffix
local nSelect := select()
local lOkay := .f.
local aBuf
select (cAlias)
aBuf := CopyRec()
select (nSelect)
if dbAddRec()
  PasteRec(aBuf)
  lOkay := .t.
  unlock record
endif
RETURN lOkay

/**
example: dbAddFrom(oIml(),"_") :
- open IML
- append each record in IML_ to IML (IML_ must have been opened before)
- close IML

**/
FUNCTION dbAddFrom(ad,cSuffix)
local aBuf
local lOkay := .t.
local nCount := 0
RETURN .f. if ! AreaOpen({ad},.f.)
select (ad[AD_NAME]+cSuffix)
go top
do while lOkay .and. !eof()
  MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
  aBuf := CopyRec()
  select (ad[AD_NAME])
  if dbAddRec()
    PasteRec(aBuf)
    unlock record
  else
    lOkay := .f.
  endif
  select (ad[AD_NAME]+cSuffix)
  skip
enddo
select (ad[AD_NAME])
AreaClose()
RETURN lOkay

**
** ddCloseAll() - closes all unneeded dbfs
**
FUNCTION ddCloseAll()
local i
local nSelect := select()
LogDebug("ddCloseAll()")
for i := 1 to len(saKeepOpen)
  if ! StopUse(saKeepOpen[i])
    Warning("ddCloseAll() : " + SetMsg())
  endif
next i
saKeepOpen := {}
select (nSelect)
RETURN .t.


*FUNCTION SetArchive(cArchive)
*scArchive := cArchive
*local i,j
*local x
*local aTables
*local area,table
*
*for i := 1 to len(saAreas)
*  area := saAreas[i]
*  for j := 1 to len(area[AREA_TABLES])
*    table := area[AREA_TABLES][i]
*    if table[TABLE_PATH] == DbPath()
*      select (table[TABLE_NAME])
*      use
*      ...
*    endif
*  next j
*next i
*
*ddCloseAll()
*if len(saAreas) != 0
*  SetMsg("saAreas is not empty")
*  RETURN .f.
*endif
*rpt_write("SetDatabase : " + cIdDos)
*LogClose()
*RETURN .f. if ! AppReadIni()
*RETURN .f. if ! OpenData(cIdDos)
*aTables := AppDataList()
*for i := 1 to len(aTables)
*  x := "o" + aTables[i][AD_NAME] + "(.t.)"
*  if &x == NIL
*    RETURN ! SetMsg(x + " : internal rebuild failed")
*  endif
*next i
RETURN .t.


FUNCTION GetTableDef(cAlias)
* RETURN xparse("o" + cAlias + "()")
local i
local aTables := AppDataList()
* local ad
for i := 1 to len(aTables)
  if aTables[i] != NIL .and. aTables[i][AD_NAME] == cAlias
    RETURN aTables[i]
  endif
next i
RETURN NIL
* // create new table descriptor:
* ad := ddDeclare(cAlias)
* RETURN NIL if ! AddTableDef(ad)
* RETURN ad


*FUNCTION AddTableDef(ad)
*local i
*local ad
*for i := 1 to len(saTables)
*  if saTables[i][AD_NAME] == cAlias
*    RETURN ! SetMsg(ad[AD_NAME] + " : duplicate table definition.")
*  endif
*next i
*aadd(saTables,ad)
*if IsCustData(ad[AD_NAME])
*  RETURN .f. if ! DefExec(ad[AD_NAME])
*endif
*RETURN .t.

FUNCTION AreaReport()
local i,j
local usage
local area
local cLine
rpt_write("area usage:")
for i := 1 to len(saUsages)
  usage := saUsages[i]
  cLine := padl(usage[USAGE_ALIAS],3)
  cLine += " " + str(usage[USAGE_COUNT],3,0)
  cLine += " " + utos(usage[USAGE_OPEN])
  cLine += " " + usage[USAGE_PATH]
  rpt_write(cLine)
next i
rpt_write("KeepOpen areas :")
for i := 1 to len(saKeepOpen)
  usage := saKeepOpen[i]
  cLine := padl(usage[USAGE_ALIAS],3)
  cLine += " " + str(usage[USAGE_COUNT],3,0)
  cLine += " " + utos(usage[USAGE_OPEN])
  cLine += " " + usage[USAGE_PATH]
  rpt_write(cLine)
next i
rpt_write("active areas:")
for i := 1 to len(saAreas)
  area := saAreas[i]
  cLine := str(area[AREA_SELECT],3,0)
  cLine += " {"
  for j := 1 to len(area[AREA_TABLES])
    if j > 1
      cLine += ","
    endif
    cLine += area[AREA_TABLES][j][TABLE_NAME]
  next j
  cLine += "}"
  cLine += alltrim(area[AREA_SUFFIX])
  if area[AREA_EXCL]
    cLine += " (excl)"
  endif
  if area[AREA_RDONLY]
    cLine += " (rdonly)"
  endif
  if area[AREA_RECLOCK]
    cLine += " (reclock)"
  endif
  if area[AREA_BREAKTRAP]
    cLine += " (breaktrap)"
  endif
  rpt_write(cLine)
next i
RETURN .t.



** Clipper 5.2 doesn't support multiple record lock
** my simulation is to restore at least the status (locked/not) when
** restoring the TABLE_RECNO.
**
** slRecLock


STATIC FUNCTION get_islocked(nSelect)
local i
for i := 1 to len(saRecLocks)
  if saRecLocks[i][RL_SELECT] == nSelect
    RETURN saRecLocks[i][RL_ISLOCKED]
  endif
next i
RETURN .f.

STATIC FUNCTION set_islocked(nSelect,lIsLocked)
local i
local rl
for i := 1 to len(saRecLocks)
  if saRecLocks[i][RL_SELECT] == nSelect
    RETURN saRecLocks[i][RL_ISLOCKED] if lIsLocked == NIL
    saRecLocks[i][RL_ISLOCKED] := lIsLocked
    RETURN NIL
  endif
next i
RETURN .f. if lIsLocked == NIL
rl := array(RL_ALEN)
rl[RL_SELECT] := nSelect
rl[RL_ISLOCKED] := lIsLocked
aadd(saRecLocks,rl)
RETURN NIL

FUNCTION dberror()
RETURN .t. if neterr()
#ifdef DEF_ADS
  RETURN .t. if ax_error() != 0
#endif
RETURN .f.



STATIC FUNCTION a_addrec
dbappend() // same as append blank
RETURN .f. if dberror()
set_islocked(select(),.t.)
// slRecLock := .t.
LogDebug("a_addrec("+alias()+"/"+ntrim(recno())+") : slRecLock := .t.")
RETURN .t.

STATIC FUNCTION a_reclock
RETURN .f. if ! rlock()
set_islocked(select(),.t.)
// slRecLock := .t.
LogDebug("a_reclock("+alias()+"/"+ntrim(recno())+") : slRecLock := .t.")
RETURN .t.

FUNCTION a_runlock
dbunlock()
set_islocked(select(),.f.)
// slRecLock := .f.
LogDebug("a_runlock("+alias()+"/"+ntrim(recno())+") : slRecLock := .f.")
RETURN .t.

FUNCTION a_islock
RETURN set_islocked(select())
*RETURN slRecLock

*FUNCTION a_pushlock
*aadd(saLockStack,slRecLock)
*slRecLock := .f.
*RETURN NIL
*
*FUNCTION a_poplock
*slRecLock := atail(saLockStack)
*asize(saLockStack,len(saLockStack)-1)
*RETURN NIL



**
** ddRecLock
**
FUNCTION ddRecLock() //
local cMsg
* 20020917 RETURN .f. if recno() == lastrec() + 1
* 20020109 RETURN .t. if dbrlock(recno())
* RETURN .t. if rlock()
RETURN .t. if a_reclock()
do while .t.
  *if cMsg != NIL
  *  SetMsg(cMsg)
  *endif
  cMsg := alias() + " " + ntrim(recno()) + MSG001
  if ! Confirm(cMsg,MsgRetry())
    * if cMsg == NIL .or. Confirm(cMsg,MSG016)
      SendConsole(cMsg)
      // trim(alias()) +  " " + ntrim(recno()) + MSG001)
      *if cMsg != NIL
      *  SendConsole(cMsg)
      *endif
      LstError(PRN_ABORT)
      RETURN .F.
    * endif
  endif
  * RETURN .t. if dbrlock(recno())
  * RETURN .t. if rlock()
  RETURN .t. if a_reclock()
enddo
RETURN NIL // never reached


FUNCTION dbAddRec
local nCount := 0
RETURN .t. if a_addrec()
do while .t.
  do while nCount < 15
    RETURN .t. if a_addrec()
    nCount++
  enddo
  // SendConsole(alias() + " " + MSG_APPEND_FAILED)
  if ! Confirm(alias() + " " + MSG_APPEND_FAILED,MsgRetry())
    SendConsole(alias() + " " + MSG_APPEND_FAILED)
    RETURN .f.
  endif
  nCount := 0
enddo
RETURN .t.

FUNCTION dbDelRec
RETURN .f. if ! ddRecLock()
dbdelete()
unlock record
RETURN .t.

**
** ddLock
**
FUNCTION ddLock
local nError
RETURN .t. if flock()
do while .t.
  nError := doserror()
  if ! Confirm(alias() + MsgDosError(nError), MsgRetry() )
    * rpt_write(alias() + MSG003)
    LstError(PRN_ABORT)
    RETURN .F.
  endif
  RETURN .T. if flock()
enddo
RETURN NIL // never reached

FUNCTION ddSetOrder(nOrder,lDescend)
default nOrder to 0
default lDescend to .f.
dbsetorder(nOrder)
#ifdef __XPP__
dbsetdescend(lDescend)
#endif
RETURN NIL
