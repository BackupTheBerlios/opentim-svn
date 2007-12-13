** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2007 Luc Saffre
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

#include "Tim.ch"
#include "defdata.ch"

*#ifdef DEF_PXT
*static scPrtList := "S"
*#endif

#ifdef DEF_DCL

#define JNLTYPE_C "C"
#define JNLTYPE_A "A"

#define LEN_IDDCF 6

FUNCTION LenIdDcf()
RETURN LEN_IDDCF



FUNCTION PickJnlType(cStart,cTitle)
local a := {}
aadd(a, JNLTYPE_C + " : " + utr("Cash and bank journals"))
aadd(a, JNLTYPE_A + " : " + utr("All accounting journals"))
default cTitle to utr("Select journal type")
RETURN ArrayPick( a, cTitle, cStart, 1, "JNLTYPE" )




**
** DCL : Declarations
**
FUNCTION oDcl()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b    ;
  name DCL            ;
  create RecCreate()   ;
  editprint ActExec("DCLPRINT") ;
  wait {|x| DclWait(x)}
ddIndex b on DCL->IdDcl
ddFld IdDcl   ,C, 3,0 picture PIC_ID
ddFld Name1   ,C,70,0 picture "@K@S40"
ddFld Name2   ,C,70,0 picture "@K@S40"
ddFld Name3   ,C,70,0 picture "@K@S40"
ddFld Attrib  ,C, 4,0  picture PIC_ID ;
                       pick PickDbcAttr("DCLATTR.DBC",DCF->Attrib)
ddFld JnlType ,C, 1,0 picture "@k@!" ;
                      pick PickJnlType(DCL->JnlType)
action b key K_ENTER   prompt NIL block DclDcfEdit(DCL->IdDcl)
ddEndDef()
RETURN b

FUNCTION DclDcfEdit(cIdBil)
cIdBil := trim(cIdBil)
RETURN DbfEdit( ;
  {oDcf(),oBil()},trim(DCL->Name1),"DCFDCL",;
  NIL,NIL,cIdBil,NIL;
)

FUNCTION DclWait() ; RETURN NIL

**
** DCF : Declaration Fields
**
FUNCTION oDcf()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b    ;
  name DCF            ;
  create RecCreate()   ;
  editprint ActExec("DCFPRINT") ;
  wait {|x| DcfWait(x)}
ddIndex b on DCF->IdDcl+DCF->IdDcf
ddFld IdDcf   ,C, LEN_IDDCF,0 picture PIC_ID
ddFld DC      ,C, 1,0  picture PIC_ID ;
                       valid empty(DCF->DC).or.DcValidate(DCF->DC)
ddFld Attrib  ,C, 4,0  picture PIC_ID ;
                       pick PickDbcAttr("DCFATTR.DBC",DCF->Attrib)
ddFld Name1   ,C,70,0 picture "@K@S40"
ddFld Name2   ,C,70,0 picture "@K@S40"
ddFld Name3   ,C,70,0 picture "@K@S40"
ddFld Type    ,C, 2,0 picture "@k@!" ;
                      pick PickDbcCode("DCFTYPE.DBC",DCF->Type)
ddFld DclSel  ,C, LEN_IDDCF,0 picture PIC_ID ;
                      pick PickDbcCode("DCLSEL.DBC",DCF->DclSel)
ddFld IdDcl   ,C, 3,0 picture PIC_ID
ddFld CljList ,C,20,0 picture "@k@!@s5" ;
                      pick PickClj(space(LenIdCtr()),DCF->CljList)
ddFld IdBil   ,C, LenIdBil(),0 picture PIC_ID ;
                  pick DbfPick( ;
                    {oBil()},;
                    DCF->IdDcf + " : Bilanzposten", ;
                    "BILPICK", ;
                    DCF->IdBil,;
                    NIL,NIL,NIL, ;
                    "BIL->IdBil",;
                  )
action b key K_ENTER   prompt "General accounts [Enter]" ;
         block BilGenEdit(DCF->IdBil)
ddEndDef()
RETURN b

FUNCTION DcfWait() ; RETURN NIL

FUNCTION DcfName()
RETURN LngExpr("DCF->Name")
// RETURN DcfField(NIL, {|| LngExpr("DCF->Name") } )

FUNCTION DcfField(cIdDcf,bField)
if cIdDcf != NIL
  if DCF->IdDcf != cIdDcf
    seek cIdDcf in DCF
  endif
endif
RETURN eval(bField)

FUNCTION DcfHasValue()
RETURN .t. if !empty(DCF->Type)
* RETURN .t. if !empty(DCF->DclSel)
* RETURN .t. if !empty(DCF->CljList)
RETURN .f.


FUNCTION DclJnlFilter()
local aJnl
local i
local c := ""
if DCL->JnlType == JNLTYPE_C
  aJnl := JnlList(;
    {|jnl|jnl[JNL_ALIAS]==JNLALIAS_FIN.and.!empty(jnl[JNL_IDGEN])})
  for i := 1 to len(aJnl)
    c+=aJnl[i][JNL_IDJNL]+","
  next i
  RETURN 'HST->IdJnl$"'+c+'"'
  * RETURN 'HST->IdJnl$"'+c+',REP"'
elseif DCL->JnlType == JNLTYPE_A
  RETURN ".t."
  * aJnl := JnlList({|jnl|JNLATTR_G $ jnl[JNL_ATTRIB]})
  * for i := 1 to len(aJnl)
  *   c+=aJnl[i][JNL_IDJNL]+","
  * next i
  * RETURN 'HST->IdJnl$"'+c+'"'
endif
RETURN raise("Bad DCL->JnlType")

FUNCTION DcfHstFilter()
RETURN "HST->DC=='D'" if DCF->Type == "MD"
RETURN "HST->DC=='C'" if DCF->Type == "MC"
RETURN ".t."

*if DCF->JnlType == JNLTYPE_C
*   jnl:= JnlLocate(HST->IdJnl)
*   if jnl[JNL_ALIAS] == JNLALIAS_FIN
*     RETURN .t. if !empty(jnl[JNL_IDGEN])
*   endif
*   RETURN .f.
* endif
* RETURN .t.

FUNCTION DcfGenFilter()
RETURN "left(GEN->IdBil,"+ntrim(len(trim(DCF->IdBil)))+")=='"+trim(DCF->IdBil)+"'"
* if !empty(DCF->DclSel)
*   RETURN "GEN->DclSel$'"+trim(DCF->DclSel)+"'"
* endif
* if !empty(DCF->CljList)
*   RETURN "GEN->IdClj$'"+trim(DCF->CljList)+"'"
*   // RETURN .t. if GEN->IdClj $ DCF->CljList
* endif
* RETURN ".f."

FUNCTION DcfValExpr()
RETURN "if(HST->DC=='"+DCF->DC;
  +"',val(HST->Mont),if(DCF->Type=='MX',0,-val(HST->Mont)))"

FUNCTION DcfValues(r1,r2,r3)
local xlGenFilter := DcfGenFilter()
local xlHstFilter := DclJnlFilter()+".and."+DcfHstFilter()
local cStop
local cStart
local a
local lOkay := .t.
local aPer1 := {}
local aPer2 := {}
local i
local aSaldo1 := {}
local aDebit := {}
local aCredit := {}
local nMont
RETURN {0,0,0} if empty(DCF->Type)
SetPeriode(r1)
aadd(aPer1,MemPer1)
aadd(aPer2,MemPer2)
aadd(aSaldo1,0)
aadd(aCredit,0)
aadd(aDebit,0)
cStart:=MemPer1
cStop:=MemPer2
if !empty(r2)
  SetPeriode(r2)
  aadd(aPer1,MemPer1)
  aadd(aPer2,MemPer2)
  aadd(aSaldo1,0)
  aadd(aCredit,0)
  aadd(aDebit,0)
  if MemPer2 > cStop ; cStop:=MemPer2 ; endif
  if MemPer1 < cStart ; cStart:=MemPer1 ; endif
  *cStop:=max(cStop,MemPer2)
endif
if !empty(r3)
  SetPeriode(r3)
  aadd(aPer1,MemPer1)
  aadd(aPer2,MemPer2)
  aadd(aSaldo1,0)
  aadd(aCredit,0)
  aadd(aDebit,0)
  if MemPer2 > cStop ; cStop:=MemPer2 ; endif
  if MemPer1 < cStart ; cStart:=MemPer1 ; endif
endif
cStart := PerStart(cStart)
open area oGen()
  ddSetOrder(ORD_GEN_BIL)
  softseek trim(DCF->IdBil)
  do while lOkay .and. !eof().and.&xlGenFilter
    open area oHst(),oGen(),oPar(),oVen(),oFin()
      ddSetOrder(3)
      softseek GEN->IdGen+cStart
      do while lOkay .and. !eof().and.HST->IdGen==GEN->IdGen ;
                     .and.HST->Periode<=cStop
        if &(xlHstFilter)
          nMont := HstMont(SetDevise())
          if HST->DC != DCF->DC
            nMont := -nMont
          endif
          for i := 1 to len(aPer1)
            if HST->Periode < aPer1[i]
              aSaldo1[i] += nMont
            elseif HST->Periode <= aPer2[i]
              if HST->DC == DC_DEBIT
                aDebit[i] += nMont
              else
                aCredit[i] += nMont
              endif
            else
            endif
          next i
        endif
        skip
      enddo
    close area
    skip
  enddo
close area
if left(DCF->Type,1) == "I"
  if DCF->Type == "I+"  // initial Saldo if > 0
    for i := 1 to len(aSaldo1)
      if aSaldo1[i] < 0
        aSaldo1[i] := 0
      endif
    next i
  endif
  RETURN aSaldo1
endif
RETURN aDebit if DCF->Type == "MD"
RETURN aCredit if DCF->Type == "MC"
a := {}
if DCF->Type == "M "
  for i := 1 to len(aPer1)
    aadd(a, aDebit[i]+aCredit[i])
  next i
  RETURN a
elseif left(DCF->Type,1) == "F"
  for i := 1 to len(aPer1)
    aadd(a, aSaldo1[i]+aDebit[i]+aCredit[i])
    * if DCF->DC==DC_DEBIT
    *   aadd(a, aSaldo1[i]+aDebit[i]-aCredit[i])
    * else
    *   aadd(a, aSaldo1[i]+aCredit[i]-aDebit[i])
    * endif
  next i
  if DCF->Type == "F+"  // final Saldo if > 0
    for i := 1 to len(a)
      if a[i] < 0
        a[i] := 0
      endif
    next i
  endif
  RETURN a
endif
RETURN NIL


**
** DcfExist()
**
FUNCTION DcfExist( cId )
if DCF->IdDcf == cId .and. ! eof() in DCF
  RETURN .t.
endif
seek cId in DCF
if eof() in DCF
  #ifdef LG_GERMAN
  SetMsg(cId + " : unbekannter Cash-Flow-Posten !")
  #endif
  #ifdef LG_FRENCH
  SetMsg(cId + " : compte de cashflow inconnu !")
  #endif
  #ifdef LG_EN
  SetMsg(cId + " : no such cash-flow field !")
  #endif
  RETURN .f.
endif
RETURN .t.



#endif DEF_DCL

#ifdef DEF_PXT


**
** PXS : Parter eXtension Sozialsekretariat
**
FUNCTION oPxs()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b    ;
  name PXS            ;
  predelete PxtPreDelete(); // predelete DbfPeek(oPar(),PXS->IdPar,"ParPxtTable()",NIL)==NIL ;
  create PxtCreate() ;
  wait {|wwin|PxtWait(PXS->IdPar,wwin)}
ddIndex b on PXS->IdPar
ddIndex b on PXS->IdPrt+upper(PXS->Name)
ddFld IdPar   ,C, LenIdPar(),0 picture PIC_ID when .f.
ddFld Name    ,C,LenParName(),0 picture "@K@S30" when .f.
// N.B.: IdPrt muss in der PXS.DEF definiert werden.
ddEndDef()
RETURN b

FUNCTION PxtTables()
RETURN { oPxs() }

FUNCTION PxtPreDelete
RETURN ConfirmDelete() if DbfPeek(oPar(),PXS->IdPar,"ParPxtTable()",NIL)==NIL
RETURN !SetMsg(alias()+" wird automatisch mit dem Partner gel”scht.")


FUNCTION ParPxtTable
RETURN if(PAR->IdPrt$"SZI",oPxs(),NIL)

FUNCTION PxtSync()
MsgDisplay("PxtSync() l„uft...")
RETURN DbfScan(;
  {oPar()},1,NIL,NIL,;
  NIL,; // "PAR->IdPrt$'"+scPrtList+"'",;
  {||ParPxtUpdate()};
 )

FUNCTION PxtCreate()
RETURN DDCREATE_FAIL if ! ActExec(alias()+"CREA")
RETURN DDCREATE_FULL
* local cIdPar := ParPick()
* RETURN DDCREATE_FAIL if cIdPar == NIL
* RETURN DDCREATE_FAIL if ! dbAddRec()
* PasteRec(aBuf)
* dbcommit()
* RETURN DDCREATE_FULL if CurQry(QRY_IDMSK) != NIL
* RETURN DDCREATE_EDIT

FUNCTION ParPxtDelete()
* to be installed as OnPreDelete event in PAR.DEF:
* ddPreDelete({||ParPxtDelete()})
local lOkay := .f.
local b := ParPxtTable()
RETURN .t. if b == NIL // ! PAR->IdPrt $ scPrtList
// RETURN .t. if ! PAR->IdPrt $ scPrtList
open area b // GetTableDef(cPxtTable) // "PX"+PAR->IdPrt)
  seek PAR->IdPar
  if eof()
    lOkay := .t.
  elseif ddRecLock()
    lOkay := .t.
    delete
    unlock record
  endif
close area
RETURN lOkay


FUNCTION ParPxtUpdate()
* to be installed as OnPostEdit event in PAR.DEF
* ddOnPostEdit({||ParPxtUpdate()})
local lOkay := .f.
// local b
local b := ParPxtTable()
RETURN .t. if b == NIL // ! PAR->IdPrt $ scPrtList
// b := GetTableDef(cPxtTable) // "PX"+PAR->IdPrt)
lOkay := .f.
open area b
  seek PAR->IdPar
  if eof()
    if dbAddRec()
      lOkay := .t.
      FIELD->IdPar := PAR->IdPar
      FIELD->IdPrt := PAR->IdPrt
      FIELD->Name := ParName()
      unlock record
    endif
  elseif ddRecLock()
    lOkay := .t.
    FIELD->Name := ParName()
    FIELD->IdPrt := PAR->IdPrt
    unlock record
  endif
close area
RETURN lOkay


FUNCTION PxtWait(cIdPar,wwin)
local b
if nextkey() != 0
  RETURN NIL
                                                 #ifdef DEF_PLP
elseif wwin[WIN_WAITKEY] == 4
  b := oPlp()
  open area b, oPar()
    edit data b key PLP->IdPar1 value cIdPar ;
                mode wait ;
                window wwin ;
                start top ;
                headers .f. ;
                query "PLPPAR1"
  close area
elseif wwin[WIN_WAITKEY] == 14
  b := oPlp()
  open area b, oPar()
    edit data b key PLP->IdPar2 value cIdPar ;
                mode wait ;
                window wwin ;
                start top ;
                headers .f. ;
                query "PLPPAR2"
  close area
                                                  #endif DEF_PLP
                                                 #ifdef DEF_PLS
elseif wwin[WIN_WAITKEY] == 24    // wie ParMbrEdit()
  b := oMbr()
  open area b, oPar(), oPls()
    ddSetOrder(ORD_MBR_PAR)
    edit data b key MBR->IdPar value cIdPar ;
                mode wait ;
                window wwin ;
                start top ;
                query "MBRPAR"
  close area
                                                  #endif DEF_PLS
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"PAR",cIdPar)
#endif DEF_RFX
endif
RETURN NIL

/**
  switches to PXT (if necessary) and execute xlEval
**/
FUNCTION ParOnPxt(xlEval,uReturn)
local b := ParPxtTable()
if alias() == b[AD_NAME]
  uReturn := xparse(xlEval)
else
  open area b, oPar()
    seek PAR->IdPar
    if ! eof()
      uReturn := xparse(xlEval)
    endif
  close area
endif
RETURN uReturn

/**
  switches to PAR (if necessary) and execute xlEval
**/
FUNCTION PxtOnPar(xlEval,uReturn)
local b := ParPxtTable()
local cIdPar := FIELD->IdPar
if alias() == "PAR"
  uReturn := xparse(xlEval)
else
  open area oPar(), b
    seek cIdPar
    if ! eof()
      uReturn := xparse(xlEval)
    endif
  close area
endif
RETURN uReturn

#else

FUNCTION oPxs ; RETURN NIL

#endif DEF_PXT


**
** WinMemoEdit()
**
FUNCTION WinMemoEdit(nWidth,cTitle)
default nWidth to 76
return MnuDone() if ! ddRecLock()
open window (cTitle) size 20,80
TxtEdit( ;
  fieldblock("Memo"), WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
  .T., nWidth ;
)
close window
unlock record
ddRefreshCurrent()
RETURN .f.


