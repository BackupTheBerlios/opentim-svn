**
** File Name ...... : DBINIT.PRG
** Application .... : LIB
** Description .... : Database Initialization
** Copyright ...... : Luc Saffre, P.A.C. Systems, Eupen, Belgium
**
#include "LIB.CH"


static scName1 := ""
static scName2 := ""
static scName3 := ""
static scOptions := ""
static scDbPath  := NIL
static scIdDos := ""

FUNCTION dbInit(cName1,cName2,cName3,cOptions,cPath)
local cName
scName1   := cName1
scName2   := cName2
scName3   := cName3
scOptions := cOptions
* scDbPath    := AppPath() + "\" + cPath
scDbPath    := DataRoot() + "\" + cPath
scIdDos   := cPath
cName := scDbPath + "\" + ProgName()
#ifdef __XPP__
  cName += ".xbase"
#endif
cName += ".MEM"
if file(cName)
  restore from (cName) addi
endif
RETURN .T.



FUNCTION DbName1     ; RETURN scName1
FUNCTION DbName2     ; RETURN scName2
FUNCTION DbName3     ; RETURN scName3
* FUNCTION DbOptions   ; RETURN scOptions
FUNCTION DbPath      ; RETURN scDbPath
FUNCTION CfgDataBase     ; RETURN scIdDos


