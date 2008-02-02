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


#ifdef DEF_DGR
  static saRapDgrList
  static snDgrIndex := 0

#define ORD_RAP_PARDATE 1
#define ORD_RAP_DATE    2

#define ORD_RPL_PARDATE   1
#define ORD_RPL_PARMATCH  2

**
** RAP - rappels
**
FUNCTION oRap
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name RAP                   ;
  preDelete  RapPreDelete()     ;
  editprint  RapPrint()       ;
  wait       {|x| RapWait(x)}
ddIndex b on  RAP->IdPar+dtos(RAP->Date) // ORD_RAP_PARDATE
ddIndex b on  dtos(RAP->Date)            // ORD_PAR_DATE
ddFld Date     ,D, 8,0 when .f.
ddFld IdTpl    ,C,LenIdTpl(),0  picture PIC_ID ;
               pick PickTpl(TPLTYPE_RAP,RAP->IdTpl)
ddFld IdPar    ,C,LenIdPar(),0  picture PIC_ID ;
               pick PickPar(NIL,RAP->IdPar) ;
               when .f.
ddFld _ParName ,C,30,0  attrib V block padr(ParName(RAP->IdPar),30)
ddFld DC      ,C,1,0
ddFld Mont    ,T,LenMont(),0
ddFld IdDev   ,C,LEN_IDDEV,0 picture PIC_ID pick PickDev(RAP->IdDev)
ddFld MontDev ,T,LenMont(),0
ddFld Memo    ,M,10,0
ddFld Zinsen  ,T,LenMont(),0 GET_MONTANT
ddFld Kosten  ,T,LenMont(),0 GET_MONTANT
ddFld IdDgr   ,C,LEN_IDDGR,0 picture PIC_ID ;
               pick PickDgr(RAP->IdDgr,RAP->DC)
action b key K_ENTER prompt MnuInhalt() block RapDetail()
action b key K_SH_F5 prompt MnuParPage() block ParPage(RAP->IdPar)
action b key K_F9    prompt MnuHstEdit() block ParHstEdit(RAP->IdPar)
action b key K_F12   prompt MnuMemoEdit() block WinMemoEdit()
ddEndDef()
RETURN b

**
** RPL - Lignes de RAP
**
FUNCTION oRpl()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name RPL                            ;
  preDelete   .t. // DDDEL_NOCONFIRM
ddIndex b on  RPL->IdPar+dtos(RPL->Date)+RPL->Line  // ORD_RPL_PARDATE
ddIndex b on  RPL->IdPar+RPL->Match+dtos(RPL->Date) // ORD_RPL_PARMATCH
ddFld Date    ,D, 8,0 when .f.
ddFld Line    ,C, LEN_POS,0
ddFld IdPar    ,C, LenIdPar(),0 when .f. ;
                        pick PickPar(NIL,RPL->IdPar)
ddFld Date1   ,D,8,0
ddFld NB      ,C,40,0
ddFld Date2   ,D,8,0
ddFld DC      ,C,1,0  picture PIC_ID
ddFld Mont    ,T,LenMont(),0 GET_MONTANT
ddFld Match   ,C,LenIdJnl()+LEN_IDDOC,0 ;
              pick PickHstPar(RPL->IdPar,RPL->Match) ;
              valid RplMatchValidate()
ddFld IdDgr   ,C,LEN_IDDGR,0 picture PIC_ID ;
              pick PickDgr(RPL->IdDgr,RPL->DC)
ddFld MontDev ,T,LenMont(),0  GET_DECPOS(DevDecPos(RAP->IdDev)) ;
              valid RplDevValidate()
ddFld _MontD    ,T, LenMont(),0  GET_MONTANT attrib V ;
                    when .f. block {|x| GsbMontD(x) }
ddFld _MontC    ,T, LenMont(),0  GET_MONTANT attrib V ;
                    when .f. block {|x| GsbMontC(x) }
action b key K_F9     prompt MnuHstEdit() block ParHstEdit(RAP->IdPar)
action b key K_SH_F5  prompt MnuParPage() block ParPage(RAP->IdPar)
action b key K_ENTER  block DocPage(left(RAP->Match,LenIdJnl()),right(RAP->Match,LEN_IDDOC))
action b key K_F12    prompt MnuMemoEdit() block RplMemoEdit()
ddEndDef()
RETURN b

FUNCTION RplMemoEdit()
select RAP
WinMemoEdit()
select RPL
RETURN MnuDone()

FUNCTION RplDevValidate
RPL->MontDev := ntom(val(RPL->MontDev),DevDecPos(RAP->IdDev))
RETURN .t.

FUNCTION RplMatchValidate
RETURN .t.

FUNCTION oDgr()
local b
define data b   ;
  name DGR      ;
  attrib K
ddIndex b on DGR->IdDgr
ddFld IdDgr     ,C, LEN_IDDGR,0 picture PIC_ID
ddFld DC        ,C, 1,0 picture PIC_ID
ddFld Days      ,C, 4,0 GET_NUM
ddFld Attrib    ,C, 4,0 picture PIC_ID
ddFld IdTpl     ,C, LenIdTpl(),0 picture PIC_ID ;
                pick PickTpl(TPLTYPE_RAP,DGR->IdTpl)
ddFld Name1     ,C, 40,0
ddFld Name2     ,C, 40,0
ddFld Name3     ,C, 40,0
ddFld Zinsen    ,C, 60,0
ddFld Kosten    ,T, LenMont(),0 GET_MONTANT
ddEndDef()
RETURN b

FUNCTION RapPreDelete()
local lOkay := .f. // nReturn := DDDEL_FAIL
local dDate  := RAP->Date
local cIdPar := RAP->IdPar
local nRecNo
RETURN .f. if ! Confirm( ;
  "Mahnung " + trim(ParName()) + " vom " + dtoc(RAP->Date),;
  MsgDocDelete(), MSG_YES, "WRN003" ;
)
open area oRpl()
  lOkay := .t. // nReturn := DDDEL_NOCONFIRM
  softseek cIdPar + dtos(dDate)
  do while ! eof() .and. RPL->IdPar == cIdPar .and. RPL->Date == RPL->Date
    if ddRecLock()
      delete
      unlock record
    else
      lOkay := .f. // nReturn := DDDEL_FAIL
      exit
    endif
    skip
  enddo
close area
RETURN lOkay // nReturn

**
** RapDetail()
**
FUNCTION RapDetail()
return MnuDone() if ! ParExist(RAP->IdPar)
return MnuDone() if ! ddRecLock()
if RapRplEdit()
  ddRefreshCurrent()
  if ddLastKey() == K_F10
    RapPrint()
  endif
endif
unlock record
RETURN MnuDone()

**
** RapWait()
**
FUNCTION RapWait(wwin)
local b
if nextkey() != 0
  RETURN NIL
elseif wwin[WIN_WAITKEY] == 1
  RETURN RapRplWait(wwin)
elseif wwin[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
endif
RETURN .f.

**
** RapEdit()
**
FUNCTION RapEdit(cTitle)
local b := oRap()
open area b, oPar(), oPlz()
  edit data b ;
    create {||RapCreate(UserDate(),NIL)} ;
    query ("RAP") ;
    mode  find  ;
    title (cTitle);
    start  bottom
close area
RETURN .f.

**
** ParRapEdit()
**
FUNCTION ParRapEdit(cIdPar)
local b := oRap()
open area b, oPar()
  ddSetOrder(ORD_RAP_PARDATE)
  edit data b       ;
            key    RAP->IdPar ;
            value  cIdPar  ;
            create {|| RapCreate(UserDate(),cIdPar)} ;
            start top  ;
            mode   find ;
            query  ("RAPPAR") ;
            title ("Mahnungen an " + trim(ParName(cIdPar)))
close area
RETURN MnuDone()

**
** RapRplEdit()
**
FUNCTION RapRplEdit()
local dDate := RAP->Date
local cIdPar := RAP->IdPar
local b := oRpl()
* local cIdTpl := ""
open area b
  edit data b       ;
            key    RPL->IdPar + dtos(RPL->Date)  ;
            value  cIdPar + dtos(dDate)   ;
            create {||RplCreate(dDate,cIdPar)} ;
            start top  ;
            mode   edit ;
            query  ("RPLRAP") ;
            title ("Mahnung " + trim(ParName())+ " vom " + dtoc(dDate))
close area
RETURN .f. if ! RapRplUpdate()
RETURN .t. if ddLastKey() == K_F10
RETURN .f.

FUNCTION RapRplUpdate()
local nMont := 0
local nMontDev := 0
local nZinsen := 0
local cDC := NIL
local dgr
local dgrMax
local lOkay := .f.
open area oRpl()
  lOkay := .t.
  softseek RAP->IdPar + dtos(RAP->Date)
  do while ! eof() .and. RPL->IdPar == RAP->IdPar ;
                   .and. RPL->Date == RAP->Date
    if (dgr := DgrLocate(RPL->IdDgr,RPL->DC)) != NIL
      if ! DGRATTR_M $ dgr[DGR_ATTRIB]
        default dgrMax to dgr
        if dgrMax[DGR_IDDGR] < dgr[DGR_IDDGR]
          dgrMax := dgr
        endif
      endif
      default cDC to RPL->DC
      if RPL->DC == cDC
        nMont    += val(RPL->Mont)
        nMontDev += val(RPL->MontDev)
        if ! empty(dgr[DGR_ZINSEN])
          nZinsen += &(dgr[DGR_ZINSEN])
        endif
      else
        nMont    -= val(RPL->Mont)
        nMontDev -= val(RPL->MontDev)
        if ! empty(dgr[DGR_ZINSEN])
          nZinsen -= &(dgr[DGR_ZINSEN])
        endif
      endif
    endif
    skip
  enddo
close area
if nMont > 0
  RAP->DC   := cDC
  RAP->Mont := ntom(nMont)
  RAP->MontDev := ntom(nMontDev,DevDecPos(RAP->IdDev))
else
  RAP->DC   := DcInvert(cDC)
  RAP->Mont := ntom(-nMont)
  RAP->MontDev := ntom(-nMontDev,DevDecPos(RAP->IdDev))
endif
if dgrMax != NIL
  RAP->IdTpl   := dgrMax[DGR_IDTPL]
  RAP->Kosten  := dgrMax[DGR_KOSTEN]
  RAP->IdDgr   := dgrMax[DGR_IDDGR]
endif
RAP->Zinsen  := ntom(nZinsen)
RETURN lOkay


FUNCTION RapOnPrev(xuReturn,uReturn)
local nRecno := recno()
local cIdDgr := RAP->IdDgr
local cIdPar := PAR->IdPar
open area oRap()
  ddSetOrder(ORD_RAP_PARDATE)
  goto nRecno
  skip -1
  if RAP->IdPar == cIdPar .and. RAP->IdDgr <= cIdDgr
    uReturn  := &xuReturn
  endif
close area
RETURN uReturn


*FUNCTION RapTitle
*local dgrMax
*local dgr
*open area oRpl()
*  lOkay := .t.
*  softseek RAP->IdPar + dtos(RAP->Date)
*  do while ! eof() .and. RPL->IdPar == RAP->IdPar ;
*                   .and. RPL->Date == RAP->Date
*    if (dgr := DgrLocate(RPL->IdDgr,RPL->DC)) != NIL
*      default dgrMax to dgr
*      if dgrMax[DGR_IDDGR] < dgr[DGR_IDDGR]
*        dgrMax := dgr
*      endif
*    endif
*  enddo
*close area
*RETURN tr("Excerpt","Kontoauszug","Extrait de compte","Uittreksel") ;
*  if dgrMax == NIL
*RETURN trim(DgrName(dgrMax[DGR_IDDGR],RAP->DC))


**
** RapRplWait()
**
FUNCTION RapRplWait(wwin)
local dDate := RAP->Date
local cIdPar := RAP->IdPar
local b := oRpl()
open area b
  edit data b       ;
            key    dtos(RPL->Date) + RPL->IdPar ;
            value  dtos(dDate) + cIdPar  ;
            mode wait ;
            window wwin ;
            start top  ;
            query  ("RPLRAP")
close area
RETURN NIL

**
** DocRplEdit()
**
*FUNCTION MatchRplEdit(cIdPar,cMatch)
*local b := oRpl()
*open area b, oPar()
*  ddSetOrder ORD_RPL_PARMATCH
*  edit data b       ;
*            key    RPL->IdPar+RPL->Match ;
*            value  cIdPar+cMatch  ;
*            create DDCREATE_FAIL ;
*            start top  ;
*            mode   find ;
*            query  ("RPLMATCH") ;
*            title ("Mahnungen " + trim(ParName(cIdPar)) + " /" + cMatch)
*close area
*RETURN MnuDone()

FUNCTION RapGenerate(dDate,cIdPar,lDetail,lPrint)
local lOkay := .f.
default lDetail to .t.
default lPrint to .t.
open area oRap()
  if RapCreate(dDate,cIdPar) == DDCREATE_DONE
    lOkay := .t.
    unlock record
    if lDetail
      RapDetail()
    elseif lPrint
      if ! RapPrint()
        lOkay := Confirm(;
          trim(ParName())+" ("+dtoc(dDate)+") : "+;
          utr("Document has been generated but not printed!",;
             "Mahnung wurde erstellt, aber nicht gedruckt!",;
             "Rappel a ‚t‚ g‚n‚r‚ mais pas imprim‚!"),;
          MsgContinue())
      endif
    endif
  else
    lOkay := Confirm(MsgContinue())
  endif
close area
RETURN lOkay

FUNCTION MsgRapExist
#ifdef LG_GERMAN
RETURN " : hat bereits eine Mahnung erhalten am "
#else
RETURN " : a d‚j… re‡u un rappel au "
#endif

**
** RapCreate()
**
FUNCTION RapCreate(dDate,cIdPar) // ,lDetail,lPrint)
local dgr
local cLine := space(LEN_POS)
* local cIdTpl := ""
local doc
local cIdDevDefault := DevDefault(PerActive(dDate))
default cIdPar to PickPar()
RETURN DDCREATE_FAIL if cIdPar == NIL
RETURN DDCREATE_FAIL if ! ParExist(cIdPar)
if ! IsNewId(cIdPar + dtos(dDate))
  Warning( ;
    trim(ParName()) + MsgRapExist() + dtocf(dDate), ;
    NIL, "WRN014" ;
  )
  RETURN DDCREATE_FAIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
MsgDisplay("Kontoauszug generieren...")
RAP->Date  := dDate
RAP->IdPar := cIdPar
if empty(PAR->IdDev)
  RAP->IdDev := cIdDevDefault // DevDefault(PerActive(dDate))
else
  RAP->IdDev := PAR->IdDev
endif
open area oHst(), oRpl()
  ddSetOrder(ORD_HST_PARDATE)
  softseek cIdPar
  do while ! eof() .and. HST->IdPar == cIdPar
    if empty(HST->Satis)
      if (doc := DocInfo(HST->IdJnl,HST->IdDoc,HST->Line)) != NIL
        if (dgr := DgrSuggest( ;
          doc,dDate-doc[DOC_ECHE],HST->DC, ;
          OldIdDgr(cIdPar,HST->Match)) ;
        ) != NIL
          select RPL
          cLine := NextNum(cLine)
          if dbAddRec()
            RPL->IdPar   := cIdPar
            RPL->Match   := HST->Match
            RPL->Date    := dDate
            RPL->Date1   := HST->Date
            RPL->Date2   := doc[DOC_ECHE]
            RPL->NB      := doc[DOC_LIBELL]
            RPL->IdDgr   := dgr[DGR_IDDGR]
            RPL->DC      := HST->DC
            RPL->Mont    := ntom( ;
              HstMont(cIdDevDefault),;
              DevDecPos(cIdDevDefault);
            )
            if RAP->IdDev != cIdDevDefault
              RPL->MontDev    := ntom(;
                HstMont(RAP->IdDev),DevDecPos(RAP->IdDev);
              )
            endif
            * RPL->Mont    := HST->Mont
            * RPL->MontDev := HST->MontDev
            RPL->Line    := cLine
            unlock record
          endif
          select HST
        endif
      endif
    endif
    skip
  enddo
close area
RETURN DDCREATE_FAIL if ! RapRplUpdate()
// unlock record wird vom Caller gemacht
dbcommit()
* MsgDisplay("")
RETURN DDCREATE_DONE

FUNCTION ParIdDgrMax(cIdPar,dDate)
local dgr
local doc
local cIdDgr := space(LEN_IDDGR)
default dDate to UserDate()
open area oHst()
  ddSetOrder(ORD_HST_PARDATE)
  softseek cIdPar
  do while ! eof() .and. HST->IdPar == cIdPar
    if empty(HST->Satis)
      if (doc := DocInfo(HST->IdJnl,HST->IdDoc,HST->Line)) != NIL
        if (dgr := DgrSuggest( ;
          doc,dDate-doc[DOC_ECHE],HST->DC, ;
          OldIdDgr(cIdPar,HST->Match)) ;
        ) != NIL
          if dgr[DGR_IDDGR] > cIdDgr
            cIdDgr := dgr[DGR_IDDGR]
          endif
        endif
      endif
    endif
    skip
  enddo
close area
RETURN cIdDgr





FUNCTION OldIdDgr(cIdPar,cMatch)
local cIdDgr := "0"
open area oRpl()
  ddSetOrder(ORD_RPL_PARMATCH)
  softseek cIdPar + cMatch
  do while ! eof() .and. RPL->IdPar == cIdPar ;
                   .and. RPL->Match == cMatch
                   * .and. RPL->Date < dDate
    * if RPL->IdDgr > cIdDgr
      cIdDgr := RPL->IdDgr
    * endif
    skip
  enddo
close area
RETURN cIdDgr

FUNCTION RplCreate(dDate,cIdPar)
local cLine := RPL->Line
local nCreate := DDCREATE_REFRESH
local nOrder := indexord()
if eof() // 20070801 recno() == lastrec() + 1
  nCreate := DDCREATE_EDIT
endif
ddSetOrder(1)
KeyGoBottom( dtos(dDate) + cIdPar, "dtos(RPL->Date)+RPL->IdPar" )
if empty(cLine)
  cLine := NextNum(RPL->Line)
else
  do while .t.
    if RPL->Line >= cLine
      if ddRecLock()
        RPL->Line := NextNum(RPL->Line)
        unlock record
      endif
    else
      exit
    endif
    skip -1
    if bof() .or. RPL->Date != dDate .or. RPL->IdPar != cIdPar
      exit
    endif
  enddo
endif
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
RPL->Date  := dDate
RPL->IdPar := cIdPar
RPL->Line  := cLine
* unlock record // 19980430
RETURN nCreate

#define DGRLIST_IDDGR 1
#define DGRLIST_DC    2
#define DGRLIST_MONT  3
#define DGRLIST_MONTDEV  4
#define DGRLIST_ALEN  4

**
** RapPrint()
**
FUNCTION RapPrint()
MnuDone()
RETURN .f. if ! ParExist(RAP->IdPar)
SetTplLang(PAR->Langue)
RETURN PrintTemplate(TPLTYPE_RAP,RAP->IdTpl,SetPreview())
* RETURN MnuDone()


FUNCTION RapRplList(cTemplate)
saRapDgrList := {}
open area oRpl()
  softseek RAP->IdPar + dtos(RAP->Date)
  do while ! eof() .and. RPL->IdPar == RAP->IdPar ;
                   .and. RPL->Date == RAP->Date
    RplDgrCollect()
    TplParse(cTemplate)
    skip
  enddo
close area
RETURN ""

FUNCTION RplDgrCollect()
local i
local a
for i := 1 to len(saRapDgrList)
  if RPL->IdDgr == saRapDgrList[i][DGRLIST_IDDGR]
    if RPL->DC == saRapDgrList[i][DGRLIST_DC]
      saRapDgrList[i][DGRLIST_MONT]    += val(RPL->Mont)
      saRapDgrList[i][DGRLIST_MONTDEV] += val(RPL->MontDev)
    else
      saRapDgrList[i][DGRLIST_MONT] -= val(RPL->Mont)
      saRapDgrList[i][DGRLIST_MONTDEV] -= val(RPL->MontDev)
    endif
    if saRapDgrList[i][DGRLIST_MONT] < 0
      saRapDgrList[i][DGRLIST_DC]      := DcInvert(saRapDgrList[i][DGRLIST_DC])
      saRapDgrList[i][DGRLIST_MONT]    := - saRapDgrList[i][DGRLIST_MONT]
      saRapDgrList[i][DGRLIST_MONTDEV] := - saRapDgrList[i][DGRLIST_MONTDEV]
    endif
    RETURN NIL
  endif
next i
a := array(DGRLIST_ALEN)
a[DGRLIST_IDDGR] := RPL->IdDgr
a[DGRLIST_DC]    := RPL->DC
a[DGRLIST_MONT]  := val(RPL->Mont)
a[DGRLIST_MONTDEV]  := val(RPL->MontDev)
aadd(saRapDgrList, a)
RETURN NIL

FUNCTION RapDgrList(cTemplate)
for snDgrIndex := 1 to len(saRapDgrList)
  TplParse(cTemplate)
next i
RETURN NIL

FUNCTION DgrValue(nValue)
RETURN "" if snDgrIndex == 0 .or. snDgrIndex > len(saRapDgrList)
RETURN saRapDgrList[snDgrIndex][nValue]

FUNCTION HasDgr ; RETURN .t.

#else

FUNCTION HasDgr ; RETURN .f.

#endif DEF_DGR

FUNCTION aCollect(a,aItem)
local i,j
for i := 1 to len(a)
  if a[i][1] == aItem[1]
    for j := 2 to len(aItem)
      a[i][j] += aItem[j]
    next j
    RETURN NIL
  endif
next i
aadd(a, aItem )
RETURN NIL


*#ifdef DEF_PRESTO
*
***
*** PTT - Partner-Tarife
***
*FUNCTION oPtt
*static b := NIL
*if b != NIL ; RETURN b ; endif
*  define data b              ;
*  name PTT
*ddIndex b on  PTT->IdPar+PTT->IdTac
*ddFld IdTac    ,C,LenIdArt(),0  picture PIC_ID ;
*               pick PickTac(PTT->IdTac)
*ddFld IdPar    ,C,LenIdPar(),0  picture PIC_ID ;
*               pick PickPar(NIL,PTT->IdPar)
*ddEndDef()
*RETURN b
*
*FUNCTION PttPeek(cIdPar,cIdTac,xuReturn,uDefault)
*local uReturn := uDefault
*open area oPtt()
*  seek cIdPar+cIdTac
*  if ! eof()
*    uReturn := xparse(xuReturn)
*  endif
*close area
*RETURN uReturn
*
*#endif DEF_PRESTO

