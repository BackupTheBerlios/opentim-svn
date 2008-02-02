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

#ifdef DEF_EVT

static saEvt := NIL
static saEvl := NIL

#ifdef LG_FRENCH
  #define MsgEviEdit  "EvŠnenments "
#else
  #define MsgEviEdit  "Ereignisse "
#endif

**
** EVT - event types
**
FUNCTION oEvt()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name EVT ;
  attrib K
ddIndex b on EVT->IdEvt
ddFld IdEvt   ,C, LEN_IDEVT,0 picture PIC_ID
ddFld Name    ,C,40,0
ddFld IdTpt   ,C, LEN_IDTPT,0 picture PIC_ID pick PickTpt(EVT->IdTpt)
ddFld IdTpl   ,C, LenIdTpl(),0 picture PIC_ID ;
                               pick PickTpl(EVT->IdTpt, EVT->IdTpl)
ddFld IdMsk   ,C, 5,0 picture PIC_ID ;
                              pick PickQry("EVI", ".MSK", EVI->IdMsk)
// FUNCTION PickQry(cRoot,cExt,cStart,cTitle,nWidth)
// ddFld Wieder  ,C,90,0
// ddFld IdTpl2  ,C, LenIdTpl(),0 picture PIC_ID ;
//                                pick PickTpl(EVT->IdTpt, EVT->IdTpl2)
ddEndDef()
RETURN b

**
** EVI - event items
**
FUNCTION oEvi()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name EVI                           ;
  editprint  EviPrint() ;
  wait {|x|EviWait(x)}
ddIndex b on  EVI->IdUsr+dtos(EVI->Date) // ORD_EVI_USR
ddIndex b on  EVI->IdPar+dtos(EVI->Date) // ORD_EVI_PAR
ddFld IdUsr   ,C, LenIdUsr(),0 picture PIC_ID
ddFld Date    ,D, 8,0
ddFld Short   ,C,40,0
ddFld Memo    ,M,10,0
ddFld IdPar   ,C, LenIdPar(),0 GET_PAD ;
               pick PickPar(NIL,EVI->IdPar)
ddFld IdEvt   ,C, LEN_IDEVT,0 picture PIC_ID ;
                              pick PickEvt(EVI->IdEvt,NIL,EVT_IDEVT)
ddFld IdTpl   ,C, LenIdTpl(),0 picture PIC_ID ;
             pick PickTpl(EvtLocate(EVI->IdEvt,EVT_IDTPT), EVI->IdTpl)
ddFld Attrib  ,C,6,0 picture PIC_ID ;
              pick PickDbcAttr("EVIATTR.DBC",EVI->Attrib)
action b key K_F12 prompt MnuMemoEdit()  ;
             block WinMemoEdit(76,dtoc(EVI->Date) + " " + trim(EVI->Short))
action b key K_ENTER ;
             block WinMemoEdit(76,dtoc(EVI->Date) + " " + trim(EVI->Short))
* #ifdef DEF_ACT
*   if IsCustData("EVI") ; ActExec("EVI") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

**
** EVL - event links
**
FUNCTION oEvl()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name EVL ;
  create SeqCreate(oEvl()) ;
  wait {|x|EvlWait(x)}
ddIndex b on  EVL->Seq
ddFld Seq      ,C, 3,0 postedit {|x|GetSeq(x)}
ddFld When     ,C,80,0
ddFld Memo     ,M,10,0
ddFld Remark   ,C,40,0
action b key K_F12 prompt MnuMemoEdit()  ;
             block WinMemoEdit(76,"after-create commands when " + trim(EVL->When))
ddEndDef()
RETURN b



**
** EvlWait()
**
FUNCTION EvlWait(win)
local b
if nextkey() != 0
  RETURN NIL
elseif win[WIN_WAITKEY] == 12
  MemoDisplay(EVL->Memo, ;
    win[WIN_TOP], ;
    win[WIN_LEFT], ;
    win[WIN_HEIGHT], ;
    win[WIN_WIDTH], ;
    NIL, NIL, 76, ;
  )
endif
RETURN .f.

**
** EviWait()
**
FUNCTION EviWait(win)
local b
if nextkey() != 0
  RETURN NIL
elseif win[WIN_WAITKEY] == 12
  MemoDisplay(EVI->Memo, ;
    win[WIN_TOP], ;
    win[WIN_LEFT], ;
    win[WIN_HEIGHT], ;
    win[WIN_WIDTH], ;
    NIL, NIL, 76, ;
  )
endif
RETURN .f.

**
** ParEviEdit()
**
FUNCTION ParEviEdit(cIdCpt)
local b := oEvi()
SetTplLang(PAR->Langue)
open area b, oPar()
  seek cIdCpt in PAR
  ddSetOrder(ORD_EVI_PAR)
  edit data b ;
    key   EVI->IdPar ;
    value cIdCpt         ;
    create   {||EviCreate(cIdCpt)} ;
    mode     find   ;
    start    bottom ;
    query "EVIPAR" ;
    title (MsgEviEdit + ParName())
close area
RETURN MnuDone()

**
** UsrEviEdit()
**
FUNCTION UsrEviEdit(cIdUsr,xlFilter)
local b := oEvi()
default cIdUsr to UserId()
default xlFilter to ".t."
open area b, oPar()
  ddSetOrder(ORD_EVI_USR)
  edit data b ;
    key   EVI->IdUsr ;
    value cIdUsr ;
    create   {||EviCreate(NIL,cIdUsr)} ;
    mode     find   ;
    start    top ;
    query "EVIUSR" ;
    title (MsgEviEdit + cIdUsr) ;
    filter (xlFilter)
close area
RETURN MnuDone()

**
** EviCreate()
**
FUNCTION EviCreate(cIdPar,cIdUsr)
local aBuf    := CopyRec()
* local cCopier := BUTTON_OFF
local dDate   := UserDate()
static cIdEvt
static cIdTpl
default cIdEvt to EVI->IdEvt
default cIdTpl to EvtLocate(EVI->IdEvt,EVT_IDTPL)
default cIdTpl to ""
cIdEvt := padr(cIdEvt,LEN_IDEVT)
cIdTpl := padr(cIdTpl,LenIdTpl())
open window ("Ereignis erstellen") size 5,50
say "Datum "
get dDate
WinCr()
say "Kategorie "
get cIdEvt picture PIC_ID pick PickEvt(cIdEvt,NIL,EVT_IDEVT)
WinCr()
say "Ereignis "
get cIdTpl picture PIC_ID ;
           pick PickTpl( ;
             EvtLocate(cIdEvt,EVT_IDTPT), ;
             cIdTpl,NIL,NIL, ;
             "Ereignis (" + trim(EvtLocate(cIdEvt,EVT_NAME)) +")" ;
           )
* WinCr()
* @ row(), col() get cCopier checkbox
* say MsgCopy() // MSG_COPY
nKey := ReadScr()
close window
RETURN DDCREATE_FAIL if nKey == K_ESC
RETURN DDCREATE_FAIL if ! dbAddRec()
* if cCopier == BUTTON_ON
  PasteRec(aBuf)
* endif
EVI->Date   := dDate
EVI->IdUsr  := UserId()
EVI->IdEvt  := cIdEvt
EVI->IdTpl  := cIdTpl
if cIdPar != NIL
  EVI->IdPar := cIdPar
endif
* unlock record 19980430
RETURN DDCREATE_FULL


**
** EvtRefresh()
**
FUNCTION EvtRefresh()
local evt
saEvt := {}
open area oEvt()
  go top
  do while ! eof()
    evt := array(EVT_ALEN)
    evt[EVT_IDEVT]  := EVT->IdEvt
    evt[EVT_NAME]   := EVT->Name
    evt[EVT_IDTPT]  := EVT->IdTpt
    evt[EVT_IDTPL]  := EVT->IdTpl
    evt[EVT_IDMSK]  := EVT->IdMsk
    aadd(saEvt,evt)
    skip
  enddo
close area
RETURN NIL

FUNCTION EviIdMsk()
RETURN "EVI"+EvtLocate(MVI->IdEvt,EVT_IDMSK)


**
** EvtLocate()
**
FUNCTION EvtLocate(cIdEvt,nField)
local i
if saEvt == NIL ; EvtRefresh() ; endif
for i := 1 to len(saEvt)
  if saEvt[i][EVT_IDEVT] == cIdEvt
    RETURN saEvt[i] if nField == NIL
    RETURN saEvt[i][nField]
  endif
next i
RETURN NIL

FUNCTION PickEvt(cStart,cTitle,nField)
local i
local nStart := 0
if saEvt == NIL ; EvtRefresh() ; endif
default cTitle to "Ereigniskategorie"
for i := 1 to len(saEvt)
  if saEvt[i][EVT_IDEVT] == cStart
    nStart := i
  endif
next i
browse array saEvt ;
             using {|x| ;
               x[EVT_IDEVT] + " " + x[EVT_NAME] ;
             } ;
             delete {||.f.} ;
             title (cTitle) ;
             help "EVT" ;
             start nStart
RETURN NIL if LastChoice() == 0
RETURN saEvt[LastChoice()][nField] if nField != NIL
RETURN saEvt[LastChoice()]


#define EVL_WHEN  1
#define EVL_ACMD  2
#define EVL_ALEN  2

**
** EvlRefresh()
**
FUNCTION EvlRefresh()
local evl
local i
local cLine
saEvl := {}
open area oEvl()
  go top
  do while ! eof()
    evl := array(EVL_ALEN)
    evl[EVL_WHEN]  := trim(EVL->When)
    evl[EVL_ACMD]  := {}
    for i := 1 to mlcount(EVL->Memo,76)
      cLine := memoline(EVL->Memo,76,i)
      if ! empty(cLine)
        if left(cLine,2) != "//"
          aadd(evl[EVL_ACMD],trim(cLine))
        endif
      endif
    next i
    aadd(saEvl,evl)
    skip
  enddo
close area
RETURN NIL


FUNCTION EvlApply(cIdUsr,xlEviFilter,lDebug)
local lOkay := .f.
local aBuf
local i
local j
local nCount := 0
local uResult
default lDebug to .f.
default cIdUsr to UserId()
default xlEviFilter to ".t."
if saEvl == NIL ; EvlRefresh() ; endif
open area oEvi(), oPar()
  lOkay := .t.
  go top
  softseek cIdUsr
  do while lOkay .and. ! eof() .and. EVI->IdUsr == cIdUsr
    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if TaskInter() ; lOkay := .f. ; exit ; endif
    seek EVI->IdPar in PAR
    if &xlEviFilter
      for i := 1 to len(saEvl)
        if &(saEvl[i][EVL_WHEN])
          aBuf := CopyRec()
          if dbAddRec()
            PasteRec(aBuf)
            EVI->Date := UserDate()
            for j := 1 to len(saEvl[i][EVL_ACMD])
              uResult := xparse(saEvl[i][EVL_ACMD][j])
              if lDebug
                Warning(uResult)
              endif
            next j
            unlock record
          else
            lOkay := .f.
          endif
        endif
      next i
    endif
    skip
  enddo
close area
RETURN MnuDone()


#endif DEF_EVT

FUNCTION TryRecLock(bTry)
local uReturn := .f.
if ddRecLock()
  uReturn := eval(bTry)
  unlock record
endif
RETURN uReturn

#ifdef __XPP__
** only available in __XPP__ because name is too long for Clipper

** http://tim.saffre-rumma.ee/src/22.html
FUNCTION TryRecLockM(aAliases,bTry)
local uReturn := .f.
local aLocked := {}
local i
local lOkay := .t.
for i := 1 to len(aAliases)
  select (aAliases[i])
  if ddRecLock()
    aadd(aLocked,alias())
  else
    lOkay := .f.
    exit
  endif
next i
if lOkay
  uReturn := eval(bTry)
endif
for i := 1 to len(aLocked)
  select (aLocked[i])
  unlock record
next i
RETURN uReturn

#endif __XPP__


#ifdef DEF_JNL // die sind n„mlich auch fr DEF_MVI n”tig

#ifdef DEF_CTP

**
** CtpUpdate()
**
FUNCTION CtpUpdate(aCtp,lPar2,nDecPos)
local i
local lOkay := .f.
local nDbDecPos
  open area oCtp()
    lOkay := .t.
    for i := 1 to len(aCtp)
      nDbDecPos := DevDecPos(DevDefault(aCtp[i][CTP_PERIODE]))
      seek aCtp[i][CTP_IDPAR] + aCtp[i][CTP_PERIODE] + aCtp[i][CTP_IDCTR]
      if eof()
        if dbAddRec()
          CTP->IdPar   := aCtp[i][CTP_IDPAR]
          CTP->Periode := aCtp[i][CTP_PERIODE]
          CTP->Debit   := ntom(aCtp[i][CTP_DEBIT],nDbDecPos)
          CTP->Credit  := ntom(aCtp[i][CTP_CREDIT],nDbDecPos)
          CTP->Umsatz  := ntom(aCtp[i][CTP_UMSATZ],nDbDecPos)
          CTP->IdCtr   := aCtp[i][CTP_IDCTR]
          unlock record
        else
          lOkay := .f.
          exit
        endif
      elseif ddRecLock()
        CTP->Debit   := ntom(val(CTP->Debit)  + aCtp[i][CTP_DEBIT],nDbDecPos)
        CTP->Credit  := ntom(val(CTP->Credit) + aCtp[i][CTP_CREDIT],nDbDecPos)
        CTP->Umsatz  := ntom(val(CTP->Umsatz) + aCtp[i][CTP_UMSATZ],nDbDecPos)
        unlock record
      else
        lOkay := .f.
        exit
      endif
    next i
  close area
  RETURN .f. if ! lOkay
* #ifdef DEF_IMP
*   open area oPar()
*     lOkay := .t.
*     for i := 1 to len(aCtp)
*       if right(aCtp[i][CTP_PERIODE],1) == CHR_255
*         if ParExist(aCtp[i][CTP_IDPAR])
*           if ddRecLock()
*             if lPar2
*               PAR->Debit2  := ntom(val(PAR->Debit2) +aCtp[i][CTP_DEBIT],nDecPos)
*               PAR->Credit2 := ntom(val(PAR->Credit2)+aCtp[i][CTP_CREDIT],nDecPos)
*             else
*               PAR->Debit   := ntom(val(PAR->Debit)+aCtp[i][CTP_DEBIT],nDecPos)
*               PAR->Credit  := ntom(val(PAR->Credit)+aCtp[i][CTP_CREDIT],nDecPos)
*             endif
*             unlock record
*           else
*             lOkay := .f.
*           endif
*         else
*           lOkay := .f.
*         endif
*       endif
*     next i
*   close area
* #endif DEF_IMP
RETURN lOkay


**
** CtpCollect
**
FUNCTION CtpCollect(aCtp,cIdCtr,cIdPar,cPeriode,nDebit,nCredit,nUmsatz)
local i
local ctp1 := NIL
local ctp2 := NIL
for i := 1 to len(aCtp)
  if aCtp[i][CTP_IDPAR] == cIdPar
    if aCtp[i][CTP_IDCTR] == cIdCtr
      if aCtp[i][CTP_PERIODE] == cPeriode
        ctp1 := aCtp[i]
      endif
    endif
  endif
next i
if ctp1 == NIL
  ctp1 := array(CTP_ALEN)
  ctp1[CTP_PERIODE] := cPeriode
  ctp1[CTP_IDPAR]   := cIdPar
  ctp1[CTP_IDCTR]   := cIdCtr
  ctp1[CTP_DEBIT]   := nDebit
  ctp1[CTP_CREDIT]  := nCredit
  ctp1[CTP_UMSATZ]  := nUmsatz
  aadd( aCtp, ctp1 )
else
  ctp1[CTP_DEBIT]  += nDebit
  ctp1[CTP_CREDIT] += nCredit
  ctp1[CTP_UMSATZ] += nUmsatz
endif
for i := 1 to len(aCtp)
  if aCtp[i][CTP_IDPAR] == cIdPar
    if aCtp[i][CTP_IDCTR] == cIdCtr
      if aCtp[i][CTP_PERIODE] == PerYear(cPeriode)
        ctp2 := aCtp[i]
      endif
    endif
  endif
next i
if ctp2 == NIL
  ctp2 := array(CTP_ALEN)
  ctp2[CTP_PERIODE] := PerYear(cPeriode)
  ctp2[CTP_IDPAR]   := cIdPar
  ctp2[CTP_IDCTR]   := cIdCtr
  ctp2[CTP_DEBIT]   := nDebit
  ctp2[CTP_CREDIT]  := nCredit
  ctp2[CTP_UMSATZ]  := nUmsatz
  aadd( aCtp, ctp2 )
else
  ctp2[CTP_DEBIT]  += nDebit
  ctp2[CTP_CREDIT] += nCredit
  ctp2[CTP_UMSATZ] += nUmsatz
endif
RETURN NIL

#endif DEF_CTP

#endif DEF_JNL



