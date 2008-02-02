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

#include "TIM.CH"
#include "DEFDATA.CH"

#ifdef DEF_LNK

#define LNKATTR_D "D"

**
** LNK -
**
FUNCTION oLnk
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name LNK ;
  create LnkCreate() ;
  predelete LnkPreDelete() ;
  wait       {|x| LnkWait(x,LNK->IdLnk) }
ddIndex b on LNK->IdLnk
ddFld IdLnk    ,C, LenIdJnl()+LEN_IDDOC+LEN_POS,0 picture PIC_ID
ddFld Name     ,C,30,0
ddFld Memo     ,M,10,0
ddFld Attrib   ,C, 5,0 picture PIC_ID pick PickLnkAttrib(LNK->Attrib)
action b key K_F12 prompt MnuMemoEdit() block WinMemoEdit(76,trim(LNK->Name))
action b block LnkLniEdit(LNK->IdLnk) key K_ENTER
*#ifdef DEF_ACT
*  if IsCustData("LNK") ; ActExec("LNK") ; endif
*#endif DEF_ACT
ddEndDef()
RETURN b

**
** LNI -
**
FUNCTION oLni
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name LNI ;
  create LniCreate(LNI->IdLnk) ;
  wait       {|x| LnkLniWait(x,LNI->IdLnk) }
ddIndex b on LNI->IdLnk+dtos(LNI->Date)                  // ORD_LNI_LNK
ddIndex b on LNI->IdJnl+LNI->IdDoc+LNI->Line+LNI->IdLnk  // ORD_LNI_DOC
ddFld IdLnk    ,C, LenIdJnl()+LEN_IDDOC+LEN_POS,0 picture PIC_ID
ddFld IdJnl    ,C, LenIdJnl(),0 picture PIC_ID pick PickIdJnl("IMP",LNI->IdJnl)
ddFld IdDoc    ,C, LEN_IDDOC,0 pick PickDoc(LNI->IdJnl,LNI->IdDoc)
ddFld Line     ,C, LEN_POS,0
ddFld Date     ,D, 8,0
action b block DocPage(LNI->IdJnl,LNI->IdDoc) ;
         prompt MsgMnuDocPage() ;
         key K_ENTER ;
         when indexord() == ORD_LNI_LNK
action b block LnkLniEdit(LNI->IdLnk) ;
         prompt MnuInhalt() ;
         key K_ENTER ;
         when indexord() == ORD_LNI_DOC
*#ifdef DEF_ACT
*  if IsCustData("LNI") ; ActExec("LNI") ; endif
*#endif DEF_ACT
ddEndDef()
RETURN b


*FUNCTION LniEnter()
*local a := CurMsk(MSK_WAITWINLIST)
*local win
*if a != NIL
*  if len(a) > 0
*    win := a[1]
*    RETURN LnkLniEdit(LNI->IdLnk) if win[WIN_WAITKEY] == 1
*  endif
*endif
* RETURN DocPage(LNI->IdJnl,LNI->IdDoc)

FUNCTION MviLniCollect(cIdLnk,cName)
// local cIdPar := MVI->IdPar
local cMatch := MVI->Match
open area oMvi()
  ddSetOrder(ORD_MVI_PARMATCH)
  // softseek cIdPar + cMatch
  softseek cMatch
  * do while ! eof() .and. MVI->IdPar == cIdPar ;
  *                  .and. MVI->Match == cMatch
  do while ! eof() .and. MVI->Match == cMatch
    LniCollect(cIdLnk,MVI->IdJnl,MVI->IdDoc,MVI->Line,MVI->Date,cName)
    skip
  enddo
close area
RETURN NIL


FUNCTION LniCollect(cIdLnk,cIdJnl,cIdDoc,cLine,dDate,cName)
local i
default cLine to padl("1",LEN_POS,"0")
default dDate to UserDate()
open area oLnk()
  seek cIdLnk
  if eof()
    if dbAddRec()
      LNK->IdLnk := cIdLnk
      LNK->Name := "(šbertrag)"
      LNK->Attrib := LNKATTR_D
      unlock record
    else
      SendHotLine("ddRecLock() LNK.DBF in LniCollect() failed")
    endif
  endif
close area
open area oLni()
  ddSetOrder(ORD_LNI_DOC)
  seek cIdJnl + cIdDoc + cLine + cIdLnk
  if eof()
    if dbAddRec()
      LNI->IdLnk := cIdLnk
      LNI->IdJnl := cIdJnl
      LNI->IdDoc := cIdDoc
      LNI->Line  := cLine
      LNI->Date  := UserDate()
      unlock record
    else
      SendHotLine("ddRecLock() LNI.DBF in LniCollect() failed")
    endif
  endif
close area
RETURN NIL

* FUNCTION LnkGenerate(aLni,cIdJnl,cIdDoc,cLine)
* local i
* default cLine to padl("1",LEN_POS,"0")
* open area oLni()
*   for i := 1 to len(aLni)
*     if dbAddRec()
*       LNI->IdLnk := cIdJnl + cIdDoc + cLine
*       LNI->IdJnl := aLni[i][1]
*       LNI->IdDoc := aLni[i][2]
*       LNI->Line  := aLni[i][3]
*       LNI->Date  := aLni[i][4]
*     else
*       exit
*     endif
*   next i
* close area
* RETURN NIL

**
** MviLniEdit() -
**
FUNCTION MviLniEdit(cMatch)
local b := oLni()
local cIdLnk := NIL
open area b, oMvi(), oLnk()
  ddSetOrder(ORD_LNI_DOC)
  if len(cMatch) == LenIdJnl() + LEN_IDDOC
    edit data b key LNI->IdJnl + LNI->IdDoc ;
      value    cMatch             ;
      start    bottom             ;
      mode     find               ;
      query ("LNIPICK")           ;
      create {||DDCREATE_FAIL} ;
      title (cMatch + " : š-Links")
  else
    edit data b key LNI->IdJnl + LNI->IdDoc + LNI->Line ;
      value    cMatch             ;
      start    bottom             ;
      mode     find               ;
      query ("LNIPICK")           ;
      create {||DDCREATE_FAIL} ;
      title (cMatch + " : š-Links")
  endif
close area
RETURN MnuDone()


**
** LnkLniEdit() -
**
FUNCTION LnkLniEdit(cIdLnk, cTitle, bFilter, cIdQry)
local b := oLni()
default cTitle to trim(cIdLnk) + " : bergreifende Historik"
default cIdQry to "LNILNK"
open area b, oMvi(), oPar(), oBud()
  edit data b key LNI->IdLnk ;
    value    cIdLnk             ;
    start    bottom             ;
    mode     find  ;
    query (cIdQry) ;
    filter (bFilter) ;
    title (cTitle) ;
    create {||LniCreate(cIdLnk)}
close area
RETURN .f.

**
** LnkWait() -
**
FUNCTION LnkWait(wwin,cIdLnk)
RETURN ClearWaitWin(wwin) if eof()
RETURN LnkLniWait(wwin,cIdLnk) if wwin[WIN_WAITKEY] == 1
if wwin[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
endif
RETURN NIL

**
** LnkLniWait() -
**
FUNCTION LnkLniWait(wwin,cIdLnk)
local b := oLni()
open area b, oMvi(), oPar(), oBud()
  edit data b key LNI->IdLnk ;
    value    cIdLnk             ;
    start    top                ;
    mode     wait  ;
    window wwin ;
    query ("LNILNK")
close area
RETURN NIL

* FUNCTION LnkName(cIdLnk)
* RETURN transform(cIdLnk,"@R !!!! !!!!!!.!!!")

FUNCTION LnkExpr(cIdLnk,xuExpr)
seek cIdLnk in LNK
RETURN xparse(xuExpr) // EvalExpr(xuExpr)


FUNCTION LnkCreate()
local cIdLnk
local cName := LNK->Name
local nOrder := indexord()
ddSetOrder(1)
KeyGoBottom("LNK","left(LNK->IdLnk,3)")
cIdLnk := NextId(LNK->IdLnk)
open window ("š-Link erstellen") size 4,50
say "Nummer    "
get cIdLnk picture PIC_ID
WinCr()
say "Bemerkung "
get cName
nKey := ReadScr()
close window
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if nKey == K_ESC
if ! IsNewId(cIdLnk)
*seek cIdLnk
*if ! eof()
  SetMsg(trim(cIdLnk) + MsgIdExist())
  RETURN DDCREATE_FAIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
LNK->IdLnk := cIdLnk
LNK->Name  := cName
LNK->Attrib  := LNKATTR_D
* unlock record 19980430
RETURN DDCREATE_DONE

FUNCTION LnkPreDelete
local lOkay := .f.
RETURN .f. if ! Confirm( ;
  trim(LNK->IdLnk) + " : wird komplett gel”scht !", ;
  MsgSure() ;
)
open area oLni()
  lOkay := .t.
  softseek LNK->IdLnk
  do while ! eof() .and. LNI->IdLnk == LNK->IdLnk
    if ddRecLock()
      delete
    else
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
RETURN lOkay

**
** LniCreate()
**
FUNCTION LniCreate(cIdLnk)
local aLn
local aTagActions := {}
local aTag
local b := oLni()
if ddRecStat() == RS_INVALID
  Warning("L”schen Sie zuerst den aktuellen Record !")
  RETURN DDCREATE_FAIL
endif
MviSetFilter( ;
  BUTTON_ON, NIL, ;
  space(LEN_IDGRJ),space(LenIdJnl()), space(LenIdDoc()), space(LenIdDoc()), ;
  NIL, NIL, ;
  NIL, ;
  NIL, NIL;
)
RETURN DDCREATE_FAIL if (aLn := MviLnCollect( ;
  {|| .t. }, ;
  .t. ;
) ) == NIL
LniGenerate(aLn,cIdLnk)
ddSetUpdated(.t.) // b[AD_UPDATED] := .t.
ddGoBottom(.t.)
RETURN DDCREATE_DONE


**
** LniGenerate()
**
** generates 0 to n lines in IML using contents of aIml
**
FUNCTION LniGenerate(aIml,cIdLnk)
local i
* local cLine
RETURN NIL if aIml == NIL
MsgDisplay(cIdLnk + MsgGenerating() )
* KeyGoBottom(cIdLnk, "LNI->IdLnk")
* cLine := NextNum(LNI->Line)
for i := 1 to len(aIml)
  if dbAddRec()
    LNI->IdLnk       := cIdLnk
    LNI->IdJnl       := left(aIml[i][IML_BACKMATCH],LenIdJnl())
    LNI->IdDoc       := substr(aIml[i][IML_BACKMATCH],LenIdJnl()+1,LEN_IDDOC)
    LNI->Line        := right(aIml[i][IML_BACKMATCH],LEN_POS)
    LNI->Date        := UserDate()
    unlock record
  else
    exit
  endif
  // ImlAfter()
next i
RETURN NIL



FUNCTION PickLnkAttrib(cStart)
local a := {}
aadd(a,{ LNKATTR_D, "Dynamisch               "})
RETURN PickAttrib(a,NIL,cStart)


**
** LnkUpdate()
**
FUNCTION LnkUpdate(cTitle)
local cIdPar
local cMatch
local lOkay := .f.
local nCount := 0
if cTitle != NIL
  MsgDisplay(cTitle + "...")
endif
open area oLnk(), oLni(), oMvi()
  ddSetOrder(ORD_MVI_ID)
  lOkay := .t.
  go top
  do while lOkay .and. ! eof()
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    if LNKATTR_D $ LNK->Attrib
      select LNI
      softseek LNI->IdLnk
      do while lOkay .and. ! eof() .and. LNI->IdLnk == LNK->IdLnk
        select MVI
        seek LNI->IdJnl + LNI->IdDoc + LNI->Line
        MviLniCollect(LNI->IdLnk)
        select LNI
        skip
      enddo
      select LNK
    endif
    if TaskInter() ; lOkay := .f. ; endif
    skip
  enddo
close area
RETURN MnuDone()


#else
FUNCTION LnkDummy ; RETURN NIL
#endif DEF_LNK



