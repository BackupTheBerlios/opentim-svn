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
#ifdef DEF_LFN
#include "LFNLIB.CH"
#endif

static saMailTo := {}
static scBasePath := "."    // prefix for links : "." or


#ifdef DEF_WWW

#define ORD_TPC_PARENT 6
#define WWWATTR_C "C"

static saListStack := {}

#define ORD_MSX_ID     1
#define ORD_MSX_PARENT 2
#define ORD_MSX_REPTO  3
#define ORD_MSX_TITLE  4
#define ORD_MSX_PAR    5
#define ORD_MSX_ART    6

#define ORD_MLM_1 1
#define ORD_MLM_2 2

* #define MSTATTR_I "I"

#define MSXATTR_I "I"  // include in parent ieven if body not empty
#define MSXATTR_N "N" // activate children numbering
#define MSXATTR_M "M" // creates multiple pages
#define MSXATTR_C "C" // self-container (although body is empty)
#define MSXATTR_S "S" // single language (don't use lngsuffix())

#define MLMATTR_AST "*" // this message not numbered if included in parent
// #define MLMATTR_I "I" // include IdMsx2 into IdMsx1

#define MLMTYPE_B "B" // "[ref " in Body
#define MLMTYPE_T "T" // Tree
// #define MLMTYPE_I "I" // Include

#define LEN_MLMSEQ 8

// #define LEN_IDMLT 1

// static saRefs := {}

static scRefMode := "2"
static scWwwPath  // t:\data\luc\www\xyz
static scWwwUrl   // http://www.xyz

FUNCTION setWwwPath(c)
scWwwPath := trim(c)
RETURN .t.
FUNCTION setWwwUrl(c)
scWwwUrl := trim(c)
RETURN .t.

FUNCTION getWwwPath()
RETURN scWwwPath
FUNCTION getWwwUrl()
RETURN scWwwUrl


FUNCTION LenIdMsx() ; RETURN 6
* FUNCTION LenIdMst() ; RETURN 6

FUNCTION HtmOnDelete()
RETURN FileDelete(getWwwPath()+xt_ofile(),.t.,.t.)



FUNCTION dlref(cFilename,cTitle)
local fname := GetWwwPath() + "\dl\" + strtran(cFilename,"/","\")
#ifdef DEF_LFN
local a := lf_getfinfo(fname)
if empty(a)
  RETURN .f. if ! toStream('<strike>"')
  RETURN .f. if ! toStream(substr(cFilename,rat("/",cFilename)+1))
  RETURN .f. if ! toStream('</strike>"')
  RETURN .t.
  *RETURN !SetMsg(fname+MsgFileExist())
  *RETURN !SetMsg(fname+MsgFileExist()) if empty(a)
endif
#endif DEF_LFN
default cTitle to substr(cFilename,rat("/",cFilename)+1)
RETURN .f. if ! toStream('<a href="')
RETURN .f. if ! toStream(GetBasePath()+'/dl/'+cFilename+'">')
RETURN .f. if ! toTxtStream(cTitle)
RETURN .f. if ! toStream("</a>")
#ifdef DEF_LFN
  RETURN .f. if ! toStream(" (")
  RETURN .f. if ! toStream(dtocf(a[LFN_WRI_FDATE])+", ")
  RETURN .f. if ! toStream(ntrim(a[LFN_FSIZE]/1024)+" KB)")
#endif DEF_LFN
RETURN .t.



FUNCTION src2html(fn,title)
local s
// e.g. [src src/wxgrid.py]
fn := strtran(fn,"/","\")
if ! ":" $ fn
  fn := getvar("SrcBasePath")+fn
endif
s := lf_memoread(fn)
RETURN !SetMsg(fn+" : no such file ?") if s == NIL // ! file(fn)
if ! empty(title)
  toStream("<h2>"+dos2html(title)+"</h2>")
endif
s=latin2dos(s)
toStream("<pre>")
toStream(dos2html(s))
toStream("</pre>")
RETURN .t.






**
**
*FUNCTION oMap() oNav
*static b := NIL
*if b != NIL ; RETURN b ; endif
*define data b                        ;
*  name MAP
*ddIndex b on  MAP->IdLng+MAP->IdMap
*ddFld IdMap   ,C, 6,0
*ddFld IdXrf   ,C, LEN_RFX,0 pick PickXrf(RFX->IdXrf)
*ddFld URL     ,C,100,0
*ddFld IdLng   ,C, LenIdLng(),0 picture PIC_ID               ;
*               pick PickLng(MSX->IdLng) ;
*               valid IsLangue(MSX->IdLng)
*ddEndDef()
*RETURN b



**
** MSX - Messages eXtended
**
**
FUNCTION oMsx()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name MSX                           ;
  editprint  ActExec('MSXPRINT') ;
  create MsxCreate() ;
  predelete MsxPreDelete(MSX->IdMsx) ;
  wait {|x|MsxWait(x)}
ddIndex b on  MSX->IdMsx format {|x|padl(x,LenIdMsx())}
ddIndex b on  upper(MSX->Title) for !empty(MSX->Title)
// ddIndex b on  MSX->IdPar+dtos(MSX->Date) format {|x|GetIdPar(x)}
// ddIndex b on  MSX->IdArt+dtos(MSX->Date) format {|x|GetIdArt(x)}
ddIndex b on  MSX->Match for !empty(MSX->Match) format {|x|x}
// ddAddIndex("MSX->IdLng+MSX->MapCode+eupper(MSX->Title)","MapCode")
ddAddIndex("MSX->Parent+MSX->Seq+upper(MSX->Title)","Parent+Seq")
ddFld IdMsx   ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} attrib P
ddFld Date    ,D, 8,0
ddFld Title   ,C,100,0
ddFld SubTitle ,C,100,0
ddFld Parent  ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} ;
               pick PickMsx(MSX->Parent)
               // valid MsxValParent()
// ddFld DC      ,C, 1,0 picture PIC_ID valid DcValidate(MSX->DC)
ddFld Seq     ,C, 3,0 postedit {|x|if(val(x)==0,x,GetNum(x))}
// ddFld Sort    ,C, 1,0 picture PIC_ID PickDbcCode("MSXSORT.DBC",MSX->Sort)
ddFld Prev    ,C, LenIdMsx(),0 postedit {|x|GetNum(x)}
               // pick PickMsx(MSX->Prev)
ddFld Next    ,C, LenIdMsx(),0 postedit {|x|GetNum(x)}
               // pick PickMsx(MSX->Next)
ddFld Match   ,C,25,0
*ddFld Cont    ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} ;
*               pick PickMsx(MSX->Cont)
*
ddFld Body    ,M,10,0
*
ddFld IdPar   ,C, LenIdPar(),0 postedit {|x|GetIdPar(x)} ;
               pick PickPar(NIL,MSX->IdPar)
ddFld IdLng   ,C, LenIdLng(),0 picture PIC_ID               ;
               pick PickLng(MSX->IdLng) ;
               valid IsLangue(MSX->IdLng)
ddFld IdArt   ,C, LenIdArt(),0 postedit {|x|GetIdArt(x)} ;
               pick PickArt(MSX->IdArt)
ddFld Status  ,C, 1,0 picture  PIC_ID ;
               pick PickDbcCode("MSXSTAT.DBC",MSX->Status) ;
               valid (MSX->lastModi:=UserDate())!=NIL.and.ph_refresh()
ddFld IdMst   ,C, 6,0 picture  PIC_ID
* ddFld IdMst   ,C, LenIdMst(),0 picture  PIC_ID ;
*                pick PickMst(MSX->IdMst)
ddFld Attrib  ,C, 5,0 picture  PIC_ID ;
               pick PickDbcAttr("MSXATTR.DBC",MSX->Attrib)
ddFld lastMod ,D, 8,0
ddFld IdUsr   ,C, LenIdUsr(),0 picture PIC_ID
// ddFld RepTo   ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} ;
//               pick PickMsx(MSX->RepTo)
ddEndDef()
RETURN b


**
** MST - Message Types
**
*FUNCTION oMst()
*static b := NIL
*if b != NIL ; RETURN b ; endif
*define data b ;
*       name MST
*ddIndex b on  MST->IdMst format {|x|upper(x)}
*ddFld IdMst   ,C, LenIdMst(),0 picture PIC_ID attrib P
*ddFld Name1   ,C,40,0
*ddFld Name2   ,C,40,0
*ddFld Name3   ,C,40,0
*ddFld Attrib  ,C, 5,0 picture  PIC_ID ;
*               pick PickDbcAttr("MSTATTR.DBC",MST->Attrib)
*ddFld Sort    ,C, 1,0 picture PIC_ID pick PickDbcCode("MSXSORT.DBC",MST->Sort)
*ddFld IdTpl   ,C,12,0 pick FilePick("MSX*.HTM",NIL,NIL,NIL,MST->IdTpl)
**ddFld Memo1   ,M,10,0
**ddFld Memo2   ,M,10,0
**ddFld Memo3   ,M,10,0
*// ddFld Seq     ,C, 3,0 postedit {|x|GetNum(x)}
*ddEndDef()
*RETURN b



FUNCTION MsxTemplate
RETURN "MSX.HTM"
* FUNCTION ArtTemplate
* RETURN "ART.HTM"

FUNCTION MlmPostEdit()
* if MLMATTR_I $ MLM->Attrib
*   seek MLM->
* endif
RETURN .t.

FUNCTION MlmPreDelete()
*if MLMATTR_I $ MLM->Attrib
*  seek MLM->IdMsx2
*  ... clear MSX->Cont
*endif
RETURN .t.


FUNCTION MsxCreate()
local cIdMsx
local cCopier := BUTTON_OFF
local aBuf := CopyRec()
cIdMsx := DbfAutoInc(oMsx())
open window ("create message") size 4,50
do while .t.
  WinHome()
  say "ID: "
  get cIdMsx picture PIC_ID ;
             postedit {|x|GetNum(x)}
  WinCr()
  get cCopier checkbox
  say MsgCopy()
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cIdMsx)
  * seek cIdMsx
  * if found()
    SetMsg(cIdMsx + " : " + MsgIdExist() )
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
* MSX->DC := DC_DEBIT
MSX->Date := UserDate()
if cCopier == BUTTON_ON
  PasteRec(aBuf)
  // MSX->RepTo := cRepTo
elseif len(RecStack())>0
  PopRec()
endif
MSX->IdMsx   := cIdMsx
dbcommit()
RETURN DDCREATE_FULL



**
** MLM - Message-to-Message-Link
**
**
*FUNCTION oMlm()
*static b := NIL
*if b != NIL ; RETURN b ; endif
*define data b                        ;
*  name MLM                           ;
*  create MlmCreate() ;
*  postedit MlmPostEdit()
*ddIndex b on  MLM->IdMsx1+MLM->Type+MLM->Seq ;
*              format {|x|padr(x,LenIdMsx())}  // ORD_MLM_1
*ddIndex b on  MLM->IdMsx2+MLM->Type+MLM->Seq ;
*              format {|x|padr(x,LenIdMsx())}  // ORD_MLM_2
*// don't add new ddIndex here. Use MLM.DEF
*ddFld IdMsx1  ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} ;
*               pick PickMsx(MLM->IdMsx1)
*ddFld IdMsx2  ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} ;
*               pick PickMsx(MLM->IdMsx2)
*ddFld Seq     ,C, LEN_MLMSEQ,0 postedit {|x|if(val(x)==0,x,GetNum(x))}
** ddFld Date    ,D, 8,0
*ddFld Type   ,C, 1,0 picture  PIC_ID ;
*                pick PickDbcCode("MLMTYPE.DBC",MLM->Type)
**ddFld Type   ,C, LEN_IMLT,0 picture  PIC_ID ;
**               pick DbfPick(;
**                 {oMlt()},"select link type","MLTPICK",MLM->IdMlt,;
**                 NIL,NIL,NIL,"MLT->IdMlt";
**               )
** ddFld Attrib  ,C, 2,0 picture  PIC_ID ;
**                pick PickDbcAttr("MLMATTR.DBC",MLM->Attrib)
**action b key K_ENTER   block MsxPage(if(indexord()==2,;
**  MLM->IdMsx1,MLM->IdMsx2);
**)
*ddEndDef()
*RETURN b






FUNCTION MlmCreate()
*local cIdMsx1 := if(indexord()==ORD_MLM_1,ddKeyValue(),NIL)
*local cIdMsx2 := if(indexord()==ORD_MLM_2,ddKeyValue(),NIL)
local aBuf := CopyRec()
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
*MLM->Date := UserDate()
*if cIdMsx1 != NIL
*  MLM->IdMsx1 := cIdMsx1
*endif
*if cIdMsx2 != NIL
*  MLM->IdMsx2 := cIdMsx2
*endif
dbcommit()
RETURN DDCREATE_DONE

FUNCTION MsxExist(cIdMsx)
seek cIdMsx in MSX
if ! (eof() in MSX)
  RETURN .t.
endif
SetMsg(cIdMsx+": no such message")
RETURN .f.

*FUNCTION MstExist(cIdMst)
*seek cIdMst in MST
*RETURN .t. if ! (eof() in MST)
*SetMsg(cIdMst+": no such message type")
*RETURN .f.



FUNCTION MsxWait(wwin)
local b
local cIdMsx := MSX->IdMsx
if wwin[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH], ;
    NIL, NIL, 250, ;
  )
*elseif wwin[WIN_WAITKEY] == 1  // edit children
*  b := oMsx()
*  open area b, oArt(), oPar()
*    edit data b key    MSX->Parent ;
*                value  cIdMsx ;
*                mode wait ;
*                window wwin ;
*                start top ;
*                query "MSXMSX"
*  close area
*elseif wwin[WIN_WAITKEY] == 2  // MsxMlm1Edit() : edit Links FROM this
*  b := oMlm()
*  open area b, oMsx(), oArt(), oPar()
*    edit data b key    MLM->IdMsx1 ;
*                value  cIdMsx ;
*                mode wait ;
*                window wwin ;
*                start top ;
*                query "MLMMSX1"
*  close area
*elseif wwin[WIN_WAITKEY] == 3  // MsxMlm2Edit() : edit Links TO this
*  b := oMlm()
*  open area b, oMsx(), oArt(), oPar()
*    edit data b key    MLM->IdMsx2 ;
*                value  cIdMsx ;
*                mode wait ;
*                window wwin ;
*                start top ;
*                query "MLMMSX2"
*  close area
endif
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"MSX",cIdMsx)
#endif DEF_RFX
RETURN NIL


*FUNCTION MsxPeek(cIdMsx,bReturn,uReturn)
*open area oMsx()
*  seek cIdMsx
*  if ! eof()
*    uReturn := eval(bReturn)
*  endif
*close area
*RETURN uReturn

FUNCTION PickMsx(cStart,xuReturn)
default xuReturn to "MSX->IdMsx"
RETURN DbfPick(;
  {oMsx(),oPar(),oArt()},;
  NIL,;
  "MSXPICK",;
  cStart,;
  NIL,;
  NIL,NIL,;
  xuReturn;
)

FUNCTION PickNew(cStart,xuReturn)
default xuReturn to "NEW->IdNew"
RETURN DbfPick(;
  {oNew(),oMsx(),oPar(),oArt()},;
  NIL,;
  "NEWPICK",;
  cStart,;
  NIL,;
  NIL,NIL,;
  xuReturn;
)

*FUNCTION MsxMlmPath(cMlmType)
*local a := {}
*local cIdMsx
*open area oMlm()
*  ddSetOrder(ORD_MLM_1)
*  cIdMsx := MSX->IdMsx
*  softseek cIdMsx + cMlmType
*  do while ! eof() ;
*     .and. MLM->Type == cMlmType ;
*     .and. MLM->IdMsx1 == cIdMsx
*    cIdMsx := MLM->IdMsx2
*    if ! aAddIfFirst(a, cIdMsx)
*      err_Circular(a,cIdMsx)
*      exit
*    endif
*    softseek cIdMsx + cMlmType
*  enddo
*  ddSetOrder ORD_MLM_2
*  cIdMsx := MSX->IdMsx
*  softseek cIdMsx + cMlmType
*  do while ! eof() ;
*     .and. MLM->Type == cMlmType ;
*     .and. MLM->IdMsx2 == cIdMsx
*    cIdMsx := MLM->IdMsx1
*    if ! aAddIfFirst(a, cIdMsx)
*      err_Circular(a,cIdMsx)
*      exit
*    endif
*    softseek cIdMsx + cMlmType
*  enddo
**  ddSetOrder ORD_MLM_2
**  softseek MSX->IdMsx + cMlmType
**  do while ! eof() ;
**     .and. MLM->Type == cMlmType ;
**     .and. MLM->IdMsx2 == MSX->IdMsx
**    aadd(a, NIL)
**    ains(a, 1)
**    a[1] := MLM->IdMsx1
**    skip
**  enddo
*close area
*RETURN a
*
*FUNCTION MsxMlmList(cMlmType)
*local a := {}
*open area oMlm()
*  ddSetOrder ORD_MLM_1
*  softseek MSX->IdMsx + cMlmType
*  do while ! eof() ;
*     .and. MLM->Type == cMlmType ;
*     .and. MLM->IdMsx1 == MSX->IdMsx
*    aadd(a, MLM->IdMsx2)
*    skip
*  enddo
*  ddSetOrder ORD_MLM_2
*  softseek MSX->IdMsx + cMlmType
*  do while ! eof() ;
*     .and. MLM->Type == cMlmType ;
*     .and. MLM->IdMsx2 == MSX->IdMsx
*    aadd(a, NIL)
*    ains(a, 1)
*    a[1] := MLM->IdMsx1
*    skip
*  enddo
*close area
*RETURN a
*
*/**
*  a[1] = { comp, lang, java, applications }
*  a[2] = { comp, software, java }
***/
*FUNCTION MsxMlmUpPath(cMlmType)
*local a := {}
*open area oMlm()
*  ddSetOrder ORD_MLM_2
*  softseek MSX->IdMsx + cMlmType
*  do while ! eof() ;
*     .and. MLM->Type == cMlmType ;
*     .and. MLM->IdMsx2 == MSX->IdMsx
*    aadd(a, MsxMlmUp2Path(MLM->IdMsx1,cMlmType))
*    skip
*  enddo
*close area
*RETURN a
*
*STATIC FUNCTION MsxMlmUp2Path(cIdMsx,cMlmType)
*local a := { cIdMsx }
*local i
*open area oMlm()
*  ddSetOrder ORD_MLM_2
*  softseek cIdMsx + cMlmType
*  do while ! eof() ;
*     .and. MLM->Type == cMlmType ;
*     .and. MLM->IdMsx2 == cIdMsx
*    cIdMsx := MLM->IdMsx1
*    if !"H"$MLM->Attrib
*      if ! aAddIfFirst(a,cIdMsx)
*        err_Circular(a,cIdMsx)
*        exit
*      endif
*    endif
*    softseek cIdMsx + cMlmType
*  enddo
*close area
*RETURN a

/**
  a[1] = { comp, lang, java, applications }
  a[2] = { comp, software, java }
**/
FUNCTION ArtAlaUpPath()
local a := {}
open area oAla()
  ddSetOrder(2)
  softseek ART->IdArt
  do while ! eof() ;
     .and. ALA->IdArt2 == ART->IdArt
    aadd(a, ArtAlaUp2Path(ALA->IdArt1))
    skip
  enddo
close area
RETURN a

STATIC FUNCTION ArtAlaUp2Path(cIdArt)
local a := { cIdArt }
local i
open area oAla()
  ddSetOrder(2)
  softseek cIdArt
  do while ! eof() ;
     .and. ALA->IdArt2 == cIdArt
    cIdArt := ALA->IdArt1
    if ! aAddIfFirst(a,cIdArt)
      err_Circular(a,cIdArt)
      exit
    endif
    softseek cIdArt
  enddo
close area
RETURN a


*FUNCTION SrcUpPath()
*local a := {}
*open area oSrc()
*  do while ! eof() .and. ! empty(FIELD->Parent)
*    aadd(a, FIELD->Parent)
*    seek FIELD->Parent
*  enddo
*close area
*RETURN a



/**
  a[1] = { comp, lang, java, applications }
  a[2] = { comp, software, java }
**/
*FUNCTION TpcTltUpPath()
*local a := {}
*open area oTlt()
*  ddSetOrder 2
*  softseek TPC->IdTpc
*  do while ! eof() ;
*     .and. TLT->IdTpc2 == TPC->IdTpc
*    aadd(a, TpcTltUp2Path(TLT->IdTpc1))
*    skip
*  enddo
*close area
*RETURN a
*
*STATIC FUNCTION TpcTltUp2Path(cIdTpc)
*local a := { cIdTpc }
*local i
*open area oTlt()
*  ddSetOrder 2
*  softseek cIdTpc
*  do while ! eof() ;
*     .and. TLT->IdTpc2 == cIdTpc
*    cIdTpc := TLT->IdTpc1
*    if ! aAddIfFirst(a,cIdTpc)
*      err_Circular(a,cIdTpc)
*      exit
*    endif
*    softseek cIdTpc
*  enddo
*close area
*RETURN a



FUNCTION MsxIsContainer()
* RETURN .t. if !empty(MSX->MapCode)
RETURN .t. if !empty(MSX->Match)
RETURN .t. if !empty(MSX->Body) .and. ! MSXATTR_I $ MSX->Attrib
RETURN .t. if MSXATTR_C $ MSX->Attrib
* RETURN .t. if HasRecords(oRfx(),1,"RFX->From",RfxIdRfx())
RETURN .f.
*
FUNCTION MsxHasMore()
RETURN .t. if !empty(MSX->Body)
RETURN .t. if MSXATTR_C $ MSX->Attrib
RETURN .f.


FUNCTION NewIsContainer()
RETURN .f. if !empty(NEW->Status)
RETURN .t.
*
FUNCTION NewHasMore()
RETURN .t. if !empty(NEW->Body)
// RETURN .t. if HasRecords(oNew(),4,"NEW->RefTo",RfxIdRfx())
// RETURN .t. if HasRecords(oRfx(),1,RfxIdRfx()+RFXTYPE_T,"RFX->From+RFX->Type")
// RETURN .t. if HasRecords(oRfx(),1,"RFX->From",RfxIdRfx())
RETURN .f.

FUNCTION NgrIsContainer()
RETURN .t.
*
FUNCTION PrjIsContainer()
RETURN .t.
*
FUNCTION ArtIsContainer()
RETURN .t. if !empty(ART->Match)
RETURN .t. if !empty(ART->Memo1)
RETURN .t. if MSXATTR_C $ ART->Attrib
RETURN HasRecords(oAla(),1,"IdArt1",ART->IdArt)
*
FUNCTION SrcIsContainer()
RETURN .t.
*
FUNCTION TpcIsContainer()
RETURN .t. if !empty(TPC->Label)
RETURN .t. if MSXATTR_C $ TPC->Attrib
RETURN .t. if HasRecords(oTpc(),ORD_TPC_PARENT,"Parent",TPC->IdTpc)
RETURN .t. if HasRecords(oRfx(),1,"RFX->From",RfxIdRfx())
RETURN .f.
*
FUNCTION PubIsContainer()
RETURN .t. if !empty(PUB->Body)
RETURN .t. if HasRecords(oQuo(),ORD_QUO_PUB,"QUO->IdPub",PUB->IdPub)
RETURN .t. if HasRecords(oRfx(),1,"RFX->From",RfxIdRfx())
RETURN .f.
*
FUNCTION AutIsContainer()
RETURN .t.
* RETURN .t. if !empty(AUT->Body)
* RETURN .t. if HasRecords(oPub(),ORD_PUB_AUT,"PUB->IdAut",AUT->IdAut)
* RETURN .f.
*
FUNCTION QuoIsContainer()
RETURN .t. if !empty(QUO->Body)
RETURN .t. if empty(QUO->IdAut)
RETURN .f.
*


*FUNCTION ArtHasChildren
*local lHasChildren := .f.
*open area oAla()
*  softseek ART->IdArt
*  if ALA->IdArt1 == ART->IdArt
*    lHasChildren := .t.
*  endif
*close area
*RETURN lHasChildren

FUNCTION MsxOnContainer(xuReturn,uReturn)
RETURN OnContainer({||MsxIsContainer()},xuReturn,uReturn)

FUNCTION NewOnContainer(xuReturn,uReturn)
RETURN OnContainer({||NewIsContainer()},xuReturn,uReturn)

FUNCTION OnContainer(xlTop,xuReturn,uReturn,blOnEach)
local nRecNo := recno()
local nOrder := indexord()
local a := {}
default blOnEach to {||.t.}
ddSetOrder(1)
do while !eof()
  if eval(xlTop)
    uReturn := xparse(xuReturn)
    goto nRecNo
    ddSetOrder(nOrder)
    RETURN uReturn
  endif
  if !DictAddItem(a,FIELD->Parent)
    goto nRecNo
    ddSetOrder(nOrder)
    Warning(RfxIdRfx()+" : circular reference!")
    RETURN uReturn
  endif
  seek FIELD->Parent
  if !eof() .and. ! eval(blOnEach)
    goto nRecNo
    ddSetOrder(nOrder)
    RETURN uReturn
  endif
enddo
SetMsg("Top not found!")
goto nRecNo
ddSetOrder(nOrder)
RETURN uReturn

** FUNCTION MsxOnContainer(xuReturn,uReturn)
**local cIdMsxParent
**RETURN xparse(xuReturn) if MsxIsContainer()
**cIdMsxParent := DbfPeek(oMlm(),MSX->IdMsx+"T","MLM->IdMsx1","",ORD_MLM_2)
**// a := MsxMlmUpPath(MLMTYPE_T)
**// if len(a) == 0
**if empty(cIdMsxParent)
**  * if empty(MSX->Match)
**  *   Warning(MSX->IdMsx+" : no parent, but body is empty")
**  * endif
**  RETURN xparse(xuReturn)
**endif
**RETURN DbfPeek(;
**  oMsx(),cIdMsxParent, ;
**  {||MsxOnContainer(xuReturn,uReturn)},;
**  uReturn;
**)

*
FUNCTION ArtOnContainer(xuReturn,uReturn)
local cIdParent
RETURN xparse(xuReturn) if ArtIsContainer()
cIdParent := DbfPeek(oAla(),ART->IdArt,"ALA->IdArt1","",ORD_MLM_2)
* 20021121 wieso denn das?
RETURN uReturn if empty(cIdParent)
* if empty(cIdParent)
*   RETURN xparse(xuReturn)
* endif
RETURN DbfPeek(;
  oArt(),cIdParent, ;
  {||ArtOnContainer(xuReturn,uReturn)},;
  uReturn;
)
*
FUNCTION TpcOnContainer(xuReturn,uReturn)
RETURN uReturn if !TpcIsContainer()
RETURN xparse(xuReturn)
*local cIdParent
*RETURN xparse(xuReturn) if TpcIsContainer()
*cIdParent := DbfPeek(oTlt(),TPC->IdTpc,"TLT->IdTpc1","",2)
*RETURN uReturn if empty(cIdParent)
*RETURN DbfPeek(;
*  oTpc(),cIdParent, ;
*  {||TpcOnContainer(xuReturn,uReturn)},;
*  uReturn;
*)

/**
unlogisch ist, dass der pathsep *nachher* und der nodesep *vorher*
gemacht wird...
**/
*FUNCTION MsxMlmUpScan(cMlmType,xlOnEach,xlNodeSep,xlPathSep,nMaxCount)
*local i
*local j
*local a  := MsxMlmUpPath(cMlmType)
*local lOkay := .f.
*if nMaxCount == NIL .or. nMaxCount > len(a)
*  nMaxCount := len(a)
*endif
*open area oMsx()
*  lOkay := .t.
*  for j := 1 to nMaxCount
*    for i := len(a[j]) to 1 step -1
*      seek a[j][i]
*      if ! xparse(xlOnEach)
*        lOkay := .f.
*        exit
*      endif
*      if i > 1
*        if ! xparse(xlNodeSep)
*          lOkay := .f.
*          exit
*        endif
*      endif
*    next i
*    if j < nMaxCount
*      if ! xparse(xlPathSep)
*        lOkay := .f.
*        exit
*      endif
*    endif
*  next j
*close area
*RETURN lOkay

FUNCTION RfxUpScan(cMlmType,xlOnEach,xlNodeSep,xlPathSep,nMaxCount)
local i
local j
local a  := RfxUpPath(cMlmType)
local lOkay := .f.
if nMaxCount == NIL .or. nMaxCount > len(a)
  nMaxCount := len(a)
endif
lOkay := .t.
for j := 1 to nMaxCount
  for i := len(a[j]) to 1 step -1
    if ! XrfPeek(a[j][i],xlOnEach,.f.)
      lOkay := .f.
      exit
    endif
    if i > 1
      if ! xparse(xlNodeSep)
        lOkay := .f.
        exit
      endif
    endif
  next i
  if j < nMaxCount
    if ! xparse(xlPathSep)
      lOkay := .f.
      exit
    endif
  endif
next j
RETURN lOkay

FUNCTION ArtAlaUpScan(xlOnEach,xlNodeSep,xlPathSep,nMaxCount)
local i
local j
local a  := ArtAlaUpPath()
local lOkay := .f.
if nMaxCount == NIL .or. nMaxCount > len(a)
  nMaxCount := len(a)
endif
open area oArt()
  lOkay := .t.
  for j := 1 to nMaxCount
    for i := len(a[j]) to 1 step -1
      seek a[j][i]
      if ! xparse(xlOnEach)
        lOkay := .f.
        exit
      endif
      if i > 1
        if ! xparse(xlNodeSep)
          lOkay := .f.
          exit
        endif
      endif
    next i
    if j < nMaxCount
      if ! xparse(xlPathSep)
        lOkay := .f.
        exit
      endif
    endif
  next j
close area
RETURN lOkay

*FUNCTION SrcUpScan(xlOnEach,xlNodeSep)
*local i
*local a  := SrcUpPath()
*local lOkay := .f.
*open area oSrc()
*  lOkay := .t.
*  for i := len(a) to 1 step -1
*    seek a[i]
*    if ! xparse(xlOnEach)
*      lOkay := .f.
*      exit
*    endif
*    if i > 1
*      if ! xparse(xlNodeSep)
*        lOkay := .f.
*        exit
*      endif
*    endif
*  next i
*close area
*RETURN lOkay

*FUNCTION TpcTltUpScan(xlOnEach,xlNodeSep,xlPathSep,nMaxCount)
*local i
*local j
*local a  := TpcTltUpPath()
*local lOkay := .f.
*if nMaxCount == NIL .or. nMaxCount > len(a)
*  nMaxCount := len(a)
*endif
*open area oTpc()
*  lOkay := .t.
*  for j := 1 to nMaxCount
*    for i := len(a[j]) to 1 step -1
*      seek a[j][i]
*      if ! xparse(xlOnEach)
*        lOkay := .f.
*        exit
*      endif
*      if i > 1
*        if ! xparse(xlNodeSep)
*          lOkay := .f.
*          exit
*        endif
*      endif
*    next i
*    if j < nMaxCount
*      if ! xparse(xlPathSep)
*        lOkay := .f.
*        exit
*      endif
*    endif
*  next j
*close area
*RETURN lOkay

* FUNCTION MsxBackRef(cMlmType,xuEval,uOnEof)
* RETURN DbfPeek(oMlm(),MSX->IdMsx+cMlmType,xuEval,uOnEof,2)

**
** loop through my direct children and tell them their places
**
*FUNCTION MsxValChildren()
*local lOkay := .f.
*local nRecno
*local cNext
*** the first child's Prev field will be empty :
*local cPrev  := ""
*** this is where my children will be contained :
** local cParent := if(MSXATTR_I $ MSX->Attrib,MSX->Cont,MSX->Parent)
*local cCont := if(empty(MSX->Cont),MSX->IdMsx,MSX->Cont)
*local cIdMsx := MSX->IdMsx
*open area oMlm(), oMsx()
*  lOkay := .t.
*  * ddSetOrder ORD_MSX_PARENT
*  softseek cIdMsx
*  * do while lOkay .and. MSX->Parent == cIdMsx .and. ! eof()
*  do while lOkay .and. MLM->IdMsx1 == cIdMsx .and. ! eof()
*    if MlmInclude() // MLMATTR_I $ MLM->Attrib
*      skip
*      if ! eof() .and. MLM->IdMsx1 == cIdMsx
*        cNext := MLM->IdMsx2
*      else
*        cNext := ""
*      endif
*      skip -1
*      select MSX
*        seek MLM->IdMsx2
*        if eof()
*          lOkay := .f.
*          exit
*        elseif ddRecLock()
*          MSX->Prev := cPrev
*          MSX->Next := cNext
*          MSX->Cont := cCont
*          * MSX->Parent := cParent
*          unlock record
*          MsxValChildren()
*        else
*          lOkay := .f.
*          exit
*        endif
*      select MLM
*      * cPrev := MSX->IdMsx
*      cPrev := MLM->IdMsx2
*    endif
*    skip
*  enddo
*close area
*RETURN lOkay

FUNCTION MsxPage(cIdMsx,cIdQry)
open area oMsx(), oMsx(), oPar()
  if cIdMsx != NIL
    seek cIdMsx
  endif
  if cIdQry == NIL
    cIdQry := "MSX"
  endif
  edit data oMsx() full noskip query (cIdQry)
close area
RETURN SetMnuDone()

FUNCTION MsxTitle(cIdMsx)
local cTitle
if cIdMsx != NIL
  seek cIdMsx in MSX
endif
if eof() in MSX
  RETURN ""
endif
if empty(MSX->Title)
  cTitle := trim1(strtran(left(MSX->Body,60),CR_LF," "),"...")
else
  cTitle := trim(MSX->Title) + " " + trims(MSX->SubTitle,"(",")")
endif
* cTitle += trims(alltrim(MSX->Parent),"(in ",")")
RETURN cTitle

* FUNCTION Mlm
* RETURN if(indexord()==2,MLM->IdMsx1,MLM->IdMsx1)

*FUNCTION MsxMlmSum(cType,xnExpr)
*local nSum := DbfSum(;
*  {oMlm(),oMsx(),oArt(),oPar()},;
*  xnExpr,ORD_MLM_1,MSX->IdMsx+cType,;
*  "MLM->IdMsx1+MLM->Type=='"+MSX->IdMsx+cType+"'";
*)
*RETURN nSum if ! cType $ "S,L"
*RETURN nSum + DbfSum(;
*  {oMlm(),oMsx(),oArt(),oPar()},;
*  xnExpr,ORD_MLM_2,MSX->IdMsx+cType,;
*  "MLM->IdMsx2+MLM->Type=='"+MSX->IdMsx+cType+"'";
*)
*
*FUNCTION MsxMlmScan(cType,xlEval)
*local a := MsxMlmList(cType)
*local i
*local lOkay := .f.
*if valtype(xlEval)=="C"
*  xlEval := cblock(xlEval)
*endif
*open area oMsx(), oPar(), oArt()
*  lOkay := .t.
*  for i := 1 to len(a)
*    seek a[i]
*    if eof() .or. ! xeval(xlEval)
*      lOkay := .f.
*      exit
*    endif
*  next i
*close area
*RETURN lOkay

* #ifdef DEF_LFN
#define HTMLEXT ".html"
* #else
* #define HTMLEXT ".HTM"
* #endif

* FUNCTION HtmFilename(cIdLng) // see also XxxHtmTarget
* FUNCTION xt_ofile(cIdLng)
* local c := xt_url(cIdLng)
* RETURN strtran(c,"/","\")

FUNCTION msx_url()
RETURN MsxOnContainer("msx_url()","/oops"+HTMLEXT) +"#"+MsxLabel() if ! MsxIsContainer()
RETURN "/"+MsxLabel()+HTMLEXT
* default cIdLng to SetTplLang()
* if MSX->IdLng == cIdLng .or. MSX->IdLng == "*"
*   RETURN "/"+MsxLabel(cIdLng)+HTMLEXT
* endif
* RETURN "/"+MsxLabel()+HTMLEXT if MSX->IdLng == cIdLng
FUNCTION src_url(cIdLng)
RETURN "/src/"+alltrim(SRC->IdSrc)+HTMLEXT
FUNCTION new_url(cIdLng)
RETURN "/news/"+alltrim(NEW->IdNew)+HTMLEXT
FUNCTION ngr_url(cIdLng)
*RETURN "/news/"+alltrim(NGR->IdNgr)+HTMLEXT
RETURN NIL if empty(NGR->IdMsx)
RETURN DbfPeek(oMsx(),NGR->IdMsx,"msx_url()",.f.)
FUNCTION pub_url(cIdLng)
RETURN "/biblio/"+alltrim(PUB->IdPub)+HTMLEXT
FUNCTION aut_url(cIdLng)
RETURN "/persons/"+alltrim(AUT->IdAut)+HTMLEXT
FUNCTION quo_url(cIdLng)
RETURN "/quotes/"+alltrim(QUO->IdQuo)+HTMLEXT
FUNCTION par_url(cIdLng)
RETURN "/contacts/"+ParLabel()+HTMLEXT
FUNCTION prj_url(cIdLng)
RETURN "/projects/"+PrjLabel()+HTMLEXT
FUNCTION tpc_url(cIdLng)
RETURN "/topics/"+TpcLabel()+lngsuffix(cIdLng)+HTMLEXT
* RETURN "/topics/"+lng2iso(cIdLng)+"/"+TpcLabel()+HTMLEXT if alias() == "TPC"
FUNCTION art_url(cIdLng)
RETURN "/products/"+ArtLabel()+lngsuffix(cIdLng)+HTMLEXT
FUNCTION mtg_url(cIdLng)
RETURN "/meetings/"+alltrim(MTG->IdMtg)+lngsuffix(cIdLng)+HTMLEXT
FUNCTION voc_url(cIdLng)
RETURN "/voc/index"+HTMLEXT+"#"+VocLabel()

* FUNCTION xt_ofile(cIdLng) // see also XxxHtmTarget
* RETURN "\"+MsxLabel()+HTMLEXT if alias() == "MSX"
* RETURN "\src\"+alltrim(SRC->IdSrc)+HTMLEXT if alias() == "SRC"
* RETURN "\news\"+alltrim(NEW->IdNew)+HTMLEXT if alias() == "NEW"
* RETURN "\news\"+alltrim(NGR->IdNgr)+HTMLEXT if alias() == "NGR"
* RETURN "\biblio\"+alltrim(PUB->IdPub)+HTMLEXT if alias() == "PUB"
* RETURN "\persons\"+alltrim(AUT->IdAut)+HTMLEXT if alias() == "AUT"
* RETURN "\quotes\"+alltrim(QUO->IdQuo)+HTMLEXT if alias() == "QUO"
* RETURN "\projects\"+PrjLabel()+HTMLEXT if alias() == "PRJ"
* default cIdLng to TplLang()
* RETURN "\topics\"+TpcLabel()+lngsuffix(cIdLng)+HTMLEXT if alias() == "TPC"
* * RETURN "\topics\"+lng2iso(cIdLng)+"\"+TpcLabel()+HTMLEXT if alias() == "TPC"
* RETURN "\products\"+lower(cIdLng)+"\"+ArtLabel()+HTMLEXT if alias() == "ART"
* RETURN "\meetings\"+alltrim(MTG->IdMtg)+lngsuffix(cIdLng)+HTMLEXT if alias() == "ART"
* * Warning(alias()+" : HtmFilename() failed")
* SetMsg(alias()+" : xt_ofile() failed")
* RETURN NIL

FUNCTION xt_url()
RETURN &(alias()+"_url()")

FUNCTION xt_ofile()
RETURN strtran(xt_url(),"/","\")

*FUNCTION MsxHtmTarget()
*RETURN "/"+MsxLabel()+HTMLEXT if MsxIsContainer()
*RETURN MsxOnContainer("MsxHtmTarget()","/oops"+HTMLEXT)+"#"+MsxLabel()
*
*STATIC FUNCTION ArtHtmTarget()
*local cDir := getBasePath()+"/products/"+lower(TplLang())+"/"
*local cContainer := ArtOnContainer("ArtLabel()",NIL)
*if cContainer==NIL
*  // ART has no own HTM page
*  RETURN trim(ART->URL) if !empty(ART->URL)
*  RETURN NIL
*elseif cContainer==ArtLabel()
*  // ART is his own container
*  RETURN cDir+ArtLabel()+HTMLEXT
*endif
*// ART is contained as child in another ART
*// 20030110 this is not a reason to have a target
*// 20031008 : no use anymore to speculate since [xe bla]
*// RETURN cDir+cContainer+".htm#"+ArtLabel()
*RETURN cDir+cContainer+HTMLEXT+"#"+ArtLabel()
*// RETURN NIL
**
*STATIC FUNCTION TpcHtmTarget()
*local cDir
*local cContainer
*RETURN getBasePath()+DbfPeek(oMsx(),TPC->IdMsx,"MsxHtmTarget()",NIL) if !empty(TPC->IdMsx)
*cDir := getBasePath()+"/topics/"+lng2iso(TplLang())+"/"
*cContainer := TpcOnContainer("TpcLabel()",NIL)
*if cContainer==NIL
*  RETURN trim(TPC->URL) if !empty(TPC->URL)
*  RETURN NIL
*elseif cContainer==TpcLabel()
*  // TPC is his own container
*  RETURN cDir+TpcLabel()+HTMLEXT
*endif
*RETURN cDir+cContainer+HTMLEXT+"#"+TpcLabel()
*// RETURN cDir+cContainer+".htm#"+TpcLabel()
*// RETURN NIL
**
*FUNCTION VocHtmTarget()
*RETURN "/voc/index"+HTMLEXT+"#"+VocLabel()
*//
*FUNCTION SrcHtmTarget()
*RETURN "/src/"+alltrim(SRC->IdSrc)+HTMLEXT
**
*STATIC FUNCTION ParHtmTarget()
*// RETURN trim(PAR->URL) if ! empty(PAR->URL)
*RETURN "/par/"+ParLabel()+HTMLEXT
**
*STATIC FUNCTION PrjHtmTarget()
*RETURN "/projects/"+PrjLabel()+HTMLEXT
**
*STATIC FUNCTION NewHtmTarget()
*RETURN "/news/"+alltrim(NEW->IdNew)+HTMLEXT if NewIsContainer()
*RETURN NIL
*// RETURN "/news/"+lower(NEW->IdLng)+"/"+left(dtos(NEW->Date),6)+HTMLEXT
**
*FUNCTION NgrHtmTarget()
*// RETURN "/news/"+alltrim(NGR->IdNgr)+HTMLEXT
*RETURN NIL if empty(NGR->IdMsx)
*RETURN DbfPeek(oMsx(),NGR->IdMsx,"MsxHtmTarget()",NIL)
**
*STATIC FUNCTION PubHtmTarget()
*local cDir := getBasePath()+"/biblio/"
*if PubIsContainer()
*  RETURN cDir+alltrim(PUB->IdPub)+HTMLEXT
*elseif ! empty(PUB->URL)
*  RETURN trim(PUB->URL)
*endif
*RETURN cDir+lower(TplLang())+"/"+ntrim(asc(left(eupper(PubTitle()),1)))+HTMLEXT
*// RETURN NIL
**
*STATIC FUNCTION AutHtmTarget()
*RETURN getBasePath()+"/persons/"+alltrim(AUT->IdAut)+HTMLEXT if AutIsContainer()
*RETURN trim(AUT->URL) if ! empty(AUT->URL)
*// RETURN NIL
*RETURN getBasePath()+"/persons/"+lower(TplLang())+;
*  "/"+ntrim(asc(left(eupper(AUT->Name),1)))+HTMLEXT
**
*STATIC FUNCTION QuoHtmTarget()
*if QuoIsContainer()
*  RETURN getBasePath()+"/quotes/"+alltrim(QUO->IdQuo)+HTMLEXT
*elseif ! empty(QUO->URL)
*  RETURN trim(QUO->URL)
*endif
*RETURN NIL
* seek QUO->IdAut in AUT
* RETURN AutHtmTarget()


* FUNCTION MsxBasePath()
* RETURN getBasePath() if empty(MSX->IdPar)
* RETURN getWwwUrl()


* FUNCTION SetRefMode(x)
* if x == NIL
*   RETURN scRefMode
* endif
* scRefMode := x
* RETURN .t.

FUNCTION MsxRefToHtml(xcTitle)
local c
local cTitle
default xcTitle to "trim(MsxTitle())"
* xcTitle := strtran(xcTitle,CR_LF," ")
cTitle := DrvCvtString(xparse(xcTitle))
RETURN "" if empty(cTitle)
// RETURN '<u>'+cTitle+'</u>' if scRefMode == "0"
c := '<a href="'+getBasePath()
c += msx_url()
c += '">' + cTitle
c += '</a>'
RETURN c
*
FUNCTION ArtRefToStream(xcTitle)
local cTitle
local cTarget := art_url() // ArtHtmTarget()
* 20030519 default xcTitle to "notags(trim(ArtName(NIL,TplLang())))"
default xcTitle to "trim(ArtName(NIL,TplLang()))"
cTitle := DrvCvtString(xparse(xcTitle))
*if scRefMode == "0" .or. cTarget == NIL .or. ! ArtIsContainer()
*  toStream('<em>')
*  toStream(cTitle)
*  toStream('</em>')
*else
  toStream('<a href="'+getBasePath())
  toStream(cTarget)
  // toStream('" CLASS="topic')
  if scRefMode == "1"
    toStream('" TITLE=')
    toStream(c2html(cTitle))
    toStream('>')
    toStream(alltrim(ART->IdArt))
  else
    toStream('">')
    toStream(cTitle)
  endif
  toStream('</a>')
*endif
RETURN .t.
*
FUNCTION TpcRefToHtml(xcTitle)
local c
local cTitle
* local cTarget := tpc_url() // TpcHtmTarget()
default xcTitle to "trim(TpcName())"
cTitle := xparse(xcTitle)
if empty(cTitle).or.left(cTitle,1)=="@"
  cTitle := trim(TpcName())
endif
cTitle := DrvCvtString(cTitle)
c := '<a href="'+getBasePath() + tpc_url()
c += '" class="topic">'
c += cTitle
c += '</a>'
RETURN c
*
FUNCTION SrcRefToHtml(xcTitle)
local c
local cTitle
* local cTarget := SrcHtmTarget()
default xcTitle to "trim(SrcTitle())"
cTitle := DrvCvtString(xparse(xcTitle))
RETURN '<tt>'+cTitle+'</tt>' if scRefMode == "0"
c := '<tt><a href="'+getBasePath()
c += src_url() // SrcHtmTarget()
c += '">'
c += cTitle
c += '</a></tt>'
RETURN c

*
FUNCTION ParRefToStream(xcTitle)
local cTitle
default xcTitle to "trim(ParName())"
cTitle := DrvCvtString(xparse(xcTitle))
*if scRefMode == "0"
*  toStream('<u>')
*  toStream(cTitle)
*  toStream('</u>')
*else
  toStream('<a href="'+getBasePath())
  toStream(par_url())
  toStream('" class="partner">')
  toStream(cTitle)
  toStream('</a>')
*endif
RETURN .t.
*
FUNCTION PrjRefToHtml(xcTitle)
local c
local cTitle
// default xcTitle to "trim(PrjName())"
default xcTitle to "'#'+alltrim(PRJ->IdPrj)+' : '+trim(PRJ->Name1)"
cTitle := DrvCvtString(xparse(xcTitle))
RETURN '<u>'+cTitle+'</u>' if scRefMode == "0"
c := '<a href="'+getBasePath()
c += prj_url()
c += '" class="project">'
c += cTitle
c += '</a>'
RETURN c
*
FUNCTION TpcRefToStream(xcTitle)
RETURN toStream(TpcRefToHtml(xcTitle))

FUNCTION PrjRefToStream(xcTitle)
RETURN toStream(PrjRefToHtml(xcTitle))

FUNCTION SrcRefToStream(xcTitle)
RETURN toStream(SrcRefToHtml(xcTitle))

FUNCTION PubRefToStream(xcTitle)
RETURN toStream(PubRefToHtml(xcTitle))

FUNCTION MsxRefToStream(xcTitle)
RETURN toStream(MsxRefToHtml(xcTitle))

FUNCTION NewRefToStream(xcTitle)
RETURN toStream(NewRefToHtml(xcTitle))

FUNCTION NewRefToHtml(xcTitle)
local c
local cTitle
local cUrl := new_url() // NewHtmTarget()
default xcTitle to "trim(NewTitle())"
cTitle := DrvCvtString(xparse(xcTitle))
default cTitle to RfxIdRfx()
RETURN '<u>'+cTitle+'</u>' if scRefMode == "0"
RETURN '<u>'+cTitle+'</u>' if cUrl == NIL
c := '<a href="'+getBasePath()
c += cUrl
c += '" class="news">'
c += cTitle
c += '</a>'
RETURN c
*
FUNCTION NgrRefToStream(xcTitle,cRefMode)
local cTitle
local cTarget := ngr_url() // NgrHtmTarget()
default xcTitle to "trim(NGR->Title)"
* default cRefMode to scRefMode
cTitle := DrvCvtString(xparse(xcTitle))
* if cRefMode == "0" .or. cTarget == NIL
if cTarget == NIL
  toStream('<u>')
  toStream(cTitle)
  toStream('</u>')
else
  toStream('<a href="'+getBasePath())
  toStream(cTarget)
  * if cRefMode == "1"
  *   toStream('" TITLE=')
  *   toStream(c2html(cTitle))
  *   toStream('>')
  *   toStream(alltrim(NGR->IdNgr))
  * else
    toStream('">')
    toStream(cTitle)
  * endif
  toStream('</a>')
endif
RETURN .t.
*
FUNCTION VocRefToStream(xcTitle)
default xcTitle to "trim(VocName(TplLang()))"
toStream('<a href="'+getBasePath())
// toStream(VocHtmTarget())
toStream(voc_url())
toStream('">')
toStream(DrvCvtString(xparse(xcTitle)))
RETURN toStream('</a>')

#ifdef DEF_LITERA

FUNCTION PubTitle()
RETURN trim(PUB->Title)+trims(left(PUB->Date,4)," (",")")

FUNCTION QuoTitle()
local c := ""
RETURN alltrim(QUO->Ref) if !empty(QUO->Ref)
* raus am 20070511 weil PUB nicht immer ge”ffnet wird
* if ! empty(QUO->IdPub)
*   seek QUO->IdPub in PUB
*   c := "in: "+trim(PubTitle())
* endif
* if !empty(QUO->Place)
*   c := trim1(QUO->Place) + c
* endif
* RETURN c if !empty(c)
RETURN "["+alltrim(QUO->IdQuo)+"]"

FUNCTION AutName(cIdAut)
if cIdAut != NIL
  seek cIdAut in AUT
endif
RETURN trim1(AUT->Vorname)+trim(AUT->Name)



FUNCTION PubRefToHtml(xcTitle)
local cTitle
local cTarget := pub_url() // PubHtmTarget()
default xcTitle to "trim(PubTitle())"
cTitle := DrvCvtString(xparse(xcTitle))
RETURN '<em>'+cTitle+'</em>' if cTarget == NIL
RETURN '<a href="'+getBasePath()+cTarget+'">'+cTitle+'</a>'

FUNCTION AutRefToStream(xcTitle)
local cTitle
local cTarget := aut_url() // AutHtmTarget()
default xcTitle to "trim(AutName())"
cTitle := DrvCvtString(xparse(xcTitle))
*if scRefMode == "0" .or. cTarget == NIL
*  toStream('<em>')
*  toStream(cTitle)
*  toStream('</em>')
*else
  toStream('<a href="'+getBasePath())
  toStream(cTarget)
  toStream('" class="persons">')
  toStream(cTitle)
  toStream('</a>')
*endif
RETURN .t.

FUNCTION QuoRefToStream(xcTitle)
local cTitle
local cTarget := quo_url() // QuoHtmTarget()
default xcTitle to "trim(QuoTitle())"
cTitle := DrvCvtString(xparse(xcTitle))
if scRefMode == "0" .or. cTarget == NIL
  toStream('<em>')
  toStream(cTitle)
  toStream('</em>')
else
  toStream('<a href="'+getBasePath())
  toStream(cTarget)
  toStream('">')
  toStream(cTitle)
  toStream('</a>')
endif
RETURN .t.

#endif DEF_LITERA

FUNCTION VocName(cIdVoc,cIdLng)
local cWord
local x
if cIdVoc != NIL
  seek cIdVoc in VOC
endif
if (eof() in VOC)
  RETURN ""
endif
default cIdLng to MemLang1
cIdLng:=lng2iso(cIdLng)
cWord := VocWord(cIdLng)
x:=DbcText("VOCTYP"+cIdLng+".DBC",&("VOC->Type"+cIdLng),3)
RETURN trim(cWord) if empty(x)
// x := xparse(x)
RETURN eval(x,trim(cWord))
* RETURN trim(VOC->Estnisch)+" ("+trim(VOC->Deutsch)+")"

FUNCTION VocWord(cIdLng)
RETURN VOC->Deutsch if cIdLng == "de"
RETURN VOC->Estnisch if cIdLng == "et"
RETURN VOC->Francais if cIdLng == "fr"
RETURN VOC->English if cIdLng == "en"
RETURN NIL


* In SiteMenu() wird MsxLabel() in einem LngLoop aufgerufen() und soll
* dann auf die šbersetzung der aktuellen MSX nach SetTplLang() verweisen.
*
FUNCTION MsxLabel(cIdLng)
RETURN ltrim(MSX->IdMsx) if empty(MSX->Match)
RETURN lower(trim(MSX->Match)) if MSX->IdLng == "*".or.MSXATTR_S $ MSX->Attrib
default cIdLng to SetTplLang()
RETURN lower(trim(MSX->Match)) if cIdLng==MemLang1 .or. cIdLng == "*"
RETURN lower(trim(MSX->Match)) + lngsuffix(cIdLng)
* RETURN if(empty(MSX->Match),ltrim(MSX->IdMsx),lower(trim(MSX->Match)))
*
FUNCTION ArtLabel()
RETURN if(empty(ART->Match),alltrim(ART->IdArt),lower(trim(ART->Match)))
*
FUNCTION TpcLabel()
RETURN if(empty(TPC->Label),alltrim(TPC->IdTpc),lower(trim(TPC->Label)))
*
FUNCTION VocLabel()
RETURN alltrim(VOC->IdVoc)
*
FUNCTION NewLabel()
RETURN alltrim(NEW->IdNew)
*
FUNCTION ParLabel()
RETURN alltrim(lower(PAR->IdPar))

FUNCTION PrjLabel()
RETURN alltrim(PRJ->IdPrj)


FUNCTION MsxPreDelete(cIdMsx)
* local lOkay := .f.
local cRef
RETURN ConfirmDelete() if empty(cIdMsx)
#ifdef DEF_RFX
  RETURN .f. if ! XrtCanDelete()
#endif DEF_RFX
RETURN .f. if ! Confirm( ;
  MSX->IdMsx + " " + trim(MsxTitle()) + " :", MsgRecDelete(), ;
  MSG_NO ;
)
RETURN .f. if ! HtmOnDelete()
*open area oMlm()
*  lOkay := .t.
*  ddSetOrder ORD_MLM_1
*  softseek cIdMsx
*  do while ! eof() .and. MLM->IdMsx1 == cIdMsx
*    if ddRecLock()
*      delete
*      unlock record
*    else
*      lOkay := .f.
*    endif
*    skip
*  enddo
*  ddSetOrder ORD_MLM_2
*  softseek cIdMsx
*  do while ! eof() .and. MLM->IdMsx2 == cIdMsx
*    if ddRecLock()
*      delete
*      unlock record
*    else
*      lOkay := .f.
*    endif
*    skip
*  enddo
*close area
*RETURN .f. if ! lOkay
#ifdef DEF_RFX
  RETURN .f. if ! XrtOnDelete()
#endif DEF_RFX
RETURN .t.


*FUNCTION MyLevel(cXrfParent)
*local cRfxType := RFXTYPE_T
*local cIdRfx := RfxIdRfx()
*local nLevel := -1
*local n
*RETURN 0 if cXrfParent == cIdRfx
*open area oRfx()
*  ddSetOrder ORD_RFX_2
*  softseek cIdRfx + cRfxType
*  do while ! eof() ;
*     .and. RFX->Type == cRfxType ;
*     .and. RFX->To == cIdRfx
*    n := MyLevel(cXrfParent)
*    if n != -1
*      nLevel := n + 1
*      exit
*    endif
*  enddo
*close area
*RETURN nLevel


* FUNCTION MsxParent(nMaxLen)
* * local s := StrParse('[=MsxMlmUpScan("T","toStream(trim(MSX->Title))","toStream(chr(46))",".f.",1)]')
* local s := StrParse('[=RfxUpScan("T","toStream(trim(MSX->Title))","toStream(chr(46))",".f.",1)]')
* RETURN padr(s,nMaxLen) if len(s) <= nMaxLen
* RETURN "..."+right(s,nMaxLen-3)

FUNCTION ArtParent(nMaxLen)
local s := StrParse(;
  '[=ArtAlaUpScan("toStream(trim(ART->Name1))",';
  +'"toStream(chr(46))",".f.",1)]')
RETURN padr(s,nMaxLen) if len(s) <= nMaxLen
RETURN "..."+right(s,nMaxLen-3)

*FUNCTION TpcParent(nMaxLen)
*local s := StrParse(;
*  '[=TpcTltUpScan("toStream(trim(TPC->Name1))",';
*  +'"toStream(chr(46))",".f.",1)]')
*RETURN padr(s,nMaxLen) if len(s) <= nMaxLen
*RETURN "..."+right(s,nMaxLen-3)

*FUNCTION SrcParent(nMaxLen)
*local s := ""
*open area oSrc()
*  seek FIELD->Parent
*  do while ! eof() // empty(FIELD->Parent)
*    if empty(s)
*      s := trim(SrcTitle())
*    else
*      s := trim(SrcTitle()) + "ú" + s
*    endif
*    if len(s) > nMaxLen
*      s := "..."+right(s,nMaxLen-3)
*      exit
*      * goto lastrec()+1
*    elseif empty(FIELD->Parent)
*      exit
*      * goto lastrec()+1
*    else
*      seek FIELD->Parent
*    endif
*  enddo
*close area
*RETURN padr(s,nMaxLen)


FUNCTION SrcParent(nMaxLen)
RETURN TreeParent(oSrc(),{||trim(SrcTitle())},nMaxLen)

FUNCTION TpcParent(nMaxLen)
RETURN TreeParent(oTpc(),{||trim(TpcName())},nMaxLen)

FUNCTION MsxParent(nMaxLen)
RETURN TreeParent(oMsx(),{||trim(MsxTitle())},nMaxLen)

FUNCTION NewParent(nMaxLen)
RETURN TreeParent(oNew(),{||trim(NewTitle())},nMaxLen)

FUNCTION TreeParent(b,xcTitle,nMaxLen)
local s := ""
open area b
  * do while ! eof() // empty(FIELD->Parent)
  do while !eof() .and. ! empty(FIELD->Parent)
    seek FIELD->Parent
    if empty(s)
      s := eval(xcTitle)
    else
      s := eval(xcTitle) + "ú" + s
    endif
    if len(s) > nMaxLen
      s := "..."+right(s,nMaxLen-3)
      exit
    elseif empty(FIELD->Parent)
      exit
    * else
    *   seek FIELD->Parent
    endif
  enddo
close area
RETURN padr(s,nMaxLen)

#ifdef DEF_VOC

FUNCTION oVlm()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name VLM
  // create VlmCreate()
ddIndex b on  VLM->IdVoc+VLM->Seq ;
              format {|x|padr(x,LEN_IDVOC)}
ddIndex b on  VLM->IdMsx+VLM->Seq ;
              format {|x|padr(x,LenIdMsx())}  // ORD_MLM_2
ddFld IdVoc  ,C, LEN_IDVOC,0 postedit {|x|GetNum(x)} ;
              pick DbfPick({oVoc()},NIL,"VOCPICK",VLM->IdVoc,NIL,NIL,NIL,"VOC->IdVoc")
ddFld IdMsx  ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} ;
              pick PickMsx(VLM->IdMsx)
ddFld Seq    ,C, LEN_MLMSEQ,0 postedit {|x|if(val(x)==0,x,GetNum(x))}
ddEndDef()
RETURN b

FUNCTION LenIdVoc()
RETURN LEN_IDVOC


#endif DEF_VOC

#endif DEF_WWW




#ifdef DEF_VEN

** Ich will nMont, der in der W„hrung des Dokuments ist, in die W„hrung
** cIdDev konvertieren.
**
FUNCTION VenMont2Dev(cIdDev,nMont)
RETURN nMont if VEN->IdDev == cIdDev
nMont := VenDev2Db(nMont)
RETURN nMont if cIdDev == DevDefault(VEN->Periode)
RETURN Db2Dev(cIdDev,VEN->Periode,nMont)

** Ich habe einen Betrag in cIdDev und m”chte ihn in der W„hrung dieses
** Dokuments haben.
**
FUNCTION VenDev2Mont(cIdDev,nMont)
RETURN nMont if VEN->IdDev == cIdDev
RETURN VenDb2Dev(nMont) if cIdDev == DevDefault(VEN->Periode)
nMont := Dev2Db(cIdDev,VEN->Periode,nMont)
RETURN VenDb2Dev(nMont)


FUNCTION VenClean
local lOkay := .f.
#ifdef DEF_VNA
  open area oVna()
    lOkay := .t.
    ddSetOrder(ORD_VNA_ID)
    softseek VEN->IdJnl + VEN->IdDoc
    do while ! eof() .and. VNA->IdDoc == VEN->IdDoc .and. VNA->IdJnl == VEN->IdJnl
      if ddRecLock()
        delete
        unlock record
      else
        lOkay := .f.
        exit
      endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_VNA
open area oVnl(VEN->Etat)
  lOkay := .t.
  softseek VEN->IdJnl + VEN->IdDoc
  do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc .and. FIELD->IdJnl == VEN->IdJnl
    if ddRecLock()
      delete
      unlock record
    else
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
if ddRecLock()
  delete
  unlock record
  RETURN .t.
endif
RETURN .f.


#endif DEF_VEN

#ifdef DEF_PLP

#define LEN_PLPTYPE 3

**
** PLP -
**
**
FUNCTION oPlp()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name PLP                           ;
  create PlpCreate()
ddIndex b on  PLP->IdPar1+PLP->Type+PLP->Seq ;
              format {|x|padr(x,LenIdPar())}
ddIndex b on  PLP->IdPar2+PLP->Type+PLP->IdPar1 ;
              format {|x|padr(x,LenIdPar())}
ddFld IdPar1  ,C, LenIdPar(),0 postedit {|x|GetIdPar(x)} ;
               pick PickPar(NIL,PLP->IdPar1)
ddFld IdPar2  ,C, LenIdPar(),0 postedit {|x|GetIdPar(x)} ;
               pick PickPar(NIL,PLP->IdPar2)
ddFld Seq     ,C, 3,0 postedit {|x|GetNum(x)}
ddFld Type    ,C, LEN_PLPTYPE,0 picture PIC_ID ;
              pick PickPlpType(PLP->Type,PLP->IdPar1,PLP->IdPar2)
action b key K_ENTER   block ParPage(if(indexord()==2,;
  PLP->IdPar1,PLP->IdPar2);
)
ddEndDef()
RETURN b


FUNCTION PickPlpType(x,cIdPar1,cIdPar2)
local cIdPrt1 := DbfPeek(oPar(),cIdPar1,"PAR->IdPrt","?")
local cIdPrt2 := DbfPeek(oPar(),cIdPar2,"PAR->IdPrt","?")
RETURN PickDbcCode("PLPTYPE.DBC",x,"Beziehungsart",;
  NIL,{|x|(empty(x[6]).or.cIdPrt1$x[6]).and.(;
    empty(x[7]).or.cIdPrt2$x[7])},NIL,PlpSexi(cIdPar2))

FUNCTION PlpSexi(cIdPar)
local cSexe := ParSexe(cIdPar)
RETURN if(cSexe=="M",4,if(cSexe=="W",5,2))

FUNCTION PlpText
RETURN DbcText("PLPTYPE.DBC",PLP->Type,PlpSexi(PLP->IdPar1)) ;
  if right(PLP->Type,1)=="-"
RETURN DbcText("PLPTYPE.DBC",PLP->Type,PlpSexi(PLP->IdPar2))



FUNCTION PlpCreate()
local cIdPar1 := if(indexord()==ORD_PLP_1,ddKeyValue(),NIL)
local cIdPar2 := if(indexord()==ORD_PLP_2,ddKeyValue(),NIL)
local aBuf := CopyRec()
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
// PLP->Date := UserDate()
if cIdPar1 != NIL
  PLP->IdPar1 := cIdPar1
endif
if cIdPar2 != NIL
  PLP->IdPar2 := cIdPar2
endif
dbcommit()
RETURN DDCREATE_DONE
// RETURN DDCREATE_FULL


FUNCTION PlpExist(cId1,cId2,cType)
local lExist := .f.
open area oPlp()
  softseek cId1
  do while !eof().and.PLP->IdPar1==cId1
    if PLP->IdPar2==cId2
      if empty(cType).or.PLP->Type==cType
        lExist:=.t.
        exit
      endif
    endif
    skip
  enddo
close area
RETURN lExist
* default cType to " "
* RETURN DbfPeek(oPlp(),cId2+cType+cId1,".t.",.f.,2)
* RETURN HasRecords(oPlp(),cId2+cType+cId1,".t.",.f.,2)

#define APT_IDPAR 1
#define APT_TYPE  2
#define APT_FOUND 3
#define APT_ALEN  3


FUNCTION ParPlpPropagate(cIdPar)
local a := {}
local i
local lFound
local lOkay := .f.
local n1:=0
local n2:=0
local n3:=0
open area oPlp()
  lOkay := .t.
  softseek cIdPar
  do while !eof().and.PLP->IdPar1==cIdPar
    aadd(a,{ PLP->IdPar2, PltInvert(PLP->Type), .f. }) // APT_ALEN
    n1+=1
    skip
  enddo
  ddSetOrder(2)
  softseek cIdPar
  do while !eof() .and. PLP->IdPar2 == cIdPar
    lFound:=.f.
    for i := 1 to len(a)
      if !a[i][APT_FOUND] .and. a[i][APT_IDPAR]==PLP->IdPar1 ;
          .and.a[i][APT_TYPE]==PLP->Type
        a[i][APT_FOUND] := .t.
        lFound := .t.
        exit
      endif
    next i
    if !lFound
      if ddRecLock()
        delete
        n2 += 1
        unlock record
      else
        lOkay := .f.
        exit
      endif
    endif
    skip
  enddo
  if lOkay
    for i := 1 to len(a)
      if ! a[i][APT_FOUND]
        seek a[i][APT_IDPAR]+cIdPar+a[i][APT_TYPE]
        if dbAddRec()
          PLP->IdPar1:=a[i][APT_IDPAR]
          PLP->IdPar2:=cIdPar
          PLP->Type:=a[i][APT_TYPE]
          n3+=1
          unlock record
        else
          lOkay := .f.
          exit
        endif
      endif
    next i
  endif
close area
SetMsg(ntrim(n1)+" links, "+ntrim(n2)+" deleted, "+ntrim(n3)+" added")
RETURN lOkay

FUNCTION PltInvert(cIdPlt)
RETURN DbcText("PLPTYPE.DBC",cIdPlt,3)

#endif DEF_PLP

#ifdef DEF_VOC

**
**
**
FUNCTION oVoc()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                   ;
  name VOC ;
  wait {|x|VocWait(x)}
ddIndex b on  VOC->IdVoc
ddFld IdVoc   ,C, LEN_IDVOC,0 when USRATTR_E $ UsrAttrib() picture PIC_ID
ddEndDef()
RETURN b

FUNCTION oVlv()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                   ;
  name VLV ;
  postedit VlvPostEdit() ;
  create  VlvCreate()
ddIndex b on  VLV->IdVoc1+VLV->Sort
ddIndex b on  VLV->IdVoc2+VLV->IdVoc1
ddFld IdVoc1  ,C, LEN_IDVOC,0 picture PIC_ID pick PickVoc(VLV->IdVoc1)
ddFld IdVoc2  ,C, LEN_IDVOC,0 picture PIC_ID pick PickVoc(VLV->IdVoc2)
ddFld Sort    ,C, 20,0
ddEndDef()
RETURN b

FUNCTION PickVoc(cStart)
RETURN DbfPick({oVoc()},"Select VOC","VOCPICK",cStart,NIL,NIL,NIL,"VOC->IdVoc")



FUNCTION VlvCreate()
RETURN DDCREATE_FAIL if ! dbAddRec()
if indexord()==2
  VLV->IdVoc2:=ddKeyValue()
else
  VLV->IdVoc1:=ddKeyValue()
endif
* unlock record // dbunlock()
RETURN DDCREATE_EDIT

FUNCTION VlvPostEdit()
local cSortText := DbfPeek(oVoc(),VLV->IdVoc2,"upper(VOC->Estnisch)",NIL)
// 20040725 local cSortText := DbfPeek(oVoc(),VLV->IdVoc2,"eupper(VOC->Estnisch)",NIL)
RETURN .f. if cSortText == NIL
if ! empty(cSortText)
  VLV->Sort := cSortText
endif
RETURN .t.




FUNCTION VocWait(wwin)
local b
local cIdVoc := VOC->IdVoc
#ifdef DEF_WWW
  if wwin[WIN_WAITKEY] == 1  // VocVlmEdit()
    b := oVlm()
    open area b, oVoc(), oMsx(), oArt(), oPar()
      edit data b key    VLM->IdVoc ;
                  value  cIdVoc ;
                  mode wait ;
                  window wwin ;
                  start top ;
                  query "VLMVOC"
    close area
  elseif wwin[WIN_WAITKEY] == 12
    b := oVlv()
    open area b, oVoc()
      edit data b key    VLV->IdVoc1 ;
                  value  cIdVoc ;
                  mode wait ;
                  window wwin ;
                  start top ;
                  query "VLVVOC1"
    close area
  elseif wwin[WIN_WAITKEY] == 13
    b := oVlv()
    open area b, oVoc()
      edit data b key    VLV->IdVoc2 ;
                  value  cIdVoc ;
                  mode wait ;
                  window wwin ;
                  start top ;
                  query "VLVVOC2"
    close area
  *                                              #ifdef DEF_RFX
  *elseif wwin[WIN_WAITKEY] == 22
  *  b := oRfx()
  *  open area b, oMsx(), oArt(), oPar(), oVoc()
  *    edit data b key    RFX->From ;
  *                value  padr("VOC:"+alltrim(cIdVoc),LEN_RFX) ;
  *                mode wait ;
  *                window wwin ;
  *                start top ;
  *                query "RFXFROM"
  *  close area
  *elseif wwin[WIN_WAITKEY] == 23  // RefEditTo
  *  b := oRfx()
  *  open area b, oMsx(), oArt(), oPar(), oVoc()
  *    edit data b key    RFX->To ;
  *                value  padr("VOC:"+alltrim(cIdVoc),LEN_RFX) ;
  *                mode wait ;
  *                window wwin ;
  *                start top ;
  *                query "RFXTO"
  *  close area
  *                                              #endif DEF_RFX
  endif
#endif DEF_WWW
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"VOC",cIdVoc)
#endif DEF_RFX
RETURN NIL



#endif DEF_VOC

#ifdef DEF_WWW

FUNCTION Body2Abstract()
local cAbstract
local cBody
local cSep := repl(CR_LF,2)
local nPos
RETURN .f. if ! ddRecLock()
if empty(FIELD->Abstract)
  nPos := at(cSep,FIELD->Body)
  if nPos == 0
    FIELD->Abstract := FIELD->Body
    FIELD->Body := ""
  else
    FIELD->Abstract := substr(FIELD->Body,1,nPos-1)
    FIELD->Body := substr(FIELD->Body,nPos + len(cSep))
  endif
else
  if empty(FIELD->Body)
    FIELD->Body := FIELD->Abstract
    FIELD->Abstract := ""
  else
    FIELD->Body := FIELD->Abstract+ cSep + FIELD->Body
    FIELD->Abstract := ""
  endif
endif
unlock record
SetMnuDone()
ph_refresh()
RETURN .t.


FUNCTION BeginHtmPage(cFilename,cTitle,dDate)
local c,n
* local a,i
// MsgDisplay("BeginHtmPage() "+cFilename)
if left(cFilename,len(getWwwPath()))==getwwwPath()
  c := substr(cFilename,len(getWwwPath())+2)
  n:=ft_nooccur("\",c)
  if n == 0
    SetBasePath(".")
  else
    SetBasePath(repl("../",n-1)+"..")
  endif
  *  SetBasePath( repl("../",;
  *  ft_nooccur("\",substr(cFilename,len(getWwwPath())+2))-1)+"..")
  * a := split(substr(cFilename,len(getWwwPath())),"\")
  * for i := 1 to len(a)
  *   a[i] := ".."
  * next i
  * SetBasePath(join(a,"/"))
  * RETURN .f. if ! Confirm("BeginHtmPage("+cFilename+"):",setBasePath())
  * RETURN .f. if ! Confirm("BeginHtmPage("+cFilename+"):",;
  *   "nooccur="+ntrim(ft_nooccur("\",substr(cFilename,len(getWwwPath())+2))))
else
  SetBasePath(getwwwUrl())
endif
RETURN .f. if ! BeginOfStream(cFilename,.f.,.t.)
setvar("Title",cTitle)
setvar("Date",dDate)
if ! mparse("HEAD.HTM")
  * rpt_write(SetMsg())
  * SetKeepReport(.t.)
  EndOfStream()
  RETURN Confirm(SetMsg(),MsgContinue()) // 20060130
endif
RETURN .t.

FUNCTION EndHtmPage()
if ! mparse("FOOT.HTM")
  * rpt_write(SetMsg())
  * SetKeepReport(.t.)
  EndOfStream()
  RETURN Confirm(SetMsg(),MsgContinue())
  * RETURN .f. // 20060130
endif
RETURN EndOfStream()


* **
* ** called from tops2www.act in a LngLoop()
* **
* FUNCTION Art_azMake
* local aKeys := {}
* local i
* SetBasePath("../../..")
* // first loop to collect existing keys
* RETURN .f. if ! DbfScan({oArt()},;
*   2+LngIndex(TplLang()),;
*   NIL,NIL,NIL,;
*   {||;
*     DictAddItem(aKeys,asc(left(eupper(ArtName(NIL,TplLang())),1))),;
*     .t.;
*   };
* )
* // RETURN .f. if ! Confirm("len(Keys) is "+ntrim(len(aKeys)))
* for i := 1 to len(aKeys)
*   RETURN .f. if ! ArtAzToHtml(aKeys,i)
* next i
* RETURN .t.
*
*
* STATIC FUNCTION ArtAzToHtml(aKeys,i)
* local k := aKeys[i]
* RETURN .f. if ! BeginHtmPage(;
*   getWwwPath()+"\topics\"+TplLang()+"\A-Z\"+ntrim(k)+HTMLEXT,;
*   "A-Z :"+chr(k))
* toStream('<table class="head"><tr><td><h1>')
* toTxtStream(getvar("Title"))
* toStream('</h1></td></tr></table>')
* toStream('<table class="main"><tr><td width="80%">')
* toStream('<HR NOSHADE>')
* arrayscan(aKeys,{|k|;
*   toStream( '[<a href="' + ntrim(k) + '.htm">' ;
*     + DrvCvtString(chr(k)) ;
*     + '</a>]' );
* })
* toStream('<HR NOSHADE>')
* DbfScan({oArt()},2+LngIndex(TplLang()),chr(k),NIL,;
*   NIL,{||ArtAz2ToHtml()};
* )
* toStream('</td><td class="right" width="20%">')
* if !empty(MemLang2)
*   LngLoop({||;
*   toStream('<a href="'+GetBasePath()+"/topics/"+lower(TplLang());
*     +"/a-z/"+ntrim(k)+'.htm">');
*   .and.toStream('<img src="'+GetBasePath();
*     +'/images/lang-'+lower(TplLang())+'.png" width="20" border=0></a> ');
*   })
* endif
* RETURN EndHtmPage()
*
* STATIC FUNCTION ArtAz2ToHtml()
* toStream("<br>")
* RETURN ArtRefToStream() if ArtIsContainer()
* toTxtStream(trim(ArtName(NIL,TplLang())))
* if !empty(ART->URL)
*   toStream(" &uarr;"+url2html(ART->URL))
* endif
* toHtmStream(ArtMemo(TplLang()),"ART->Memo "+ltrim(ART->IdArt))
* RETURN RfxList2ToStream("ART:"+alltrim(ART->IdArt)," (&rarr; ",")")


*FUNCTION ArtToHtml(aKeys,i)
*RETURN .f. if ! BeginHtmPage(;
*  getWwwPath()+"\topics\"+lower(TplLang())+"\"+ArtLabel()+HTMLEXT,;
*  trim(ArtName(NIL,TplLang())))
*
*toStream('<table class="head"><tr><td>')
*ArtAlaUpScan(;
*  "ArtRefToStream('trim(ArtName(NIL,TplLang()))')",;
*  "toStream(' &middot; ')",;
*  "toStream('<br>')";
*)
*toStream('<h1>')
*toTxtStream(getvar("Title"))
*toStream('</h1>')
*toStream('</td></tr></table>')
*toStream('<table class="main"><tr><td width="80%">')
*// todo... DISPLAY CHILDREN
*
*if !empty(ART->URL)
*  toStream(url2html(ART->URL,"[url]",trim(ART->URL))+" ")
*endif
*toStream(toHtml(ArtMemo(TplLang()),"ART->Memo "+ltrim(ART->IdArt)))
*
*// ...
*RETURN EndHtmPage()
*
*FUNCTION ArtSubToHtml()
*if empty(ART->Memo1).and.ArtIsContainer()
*  DlgPush("prefix")
*  DlgDefine("prefix",": ")
*  DbfScan(;
*    {oAla(),oArt()},if(;
*      ART->Sort=="S",;
*      1,;
*      if(ART->Sort=="D",4,3);
*    ),ART->IdArt,;
*    "ALA->IdArt1=='"+ART->IdArt+"'",;
*    "ArtExist(ALA->IdArt2)",;
*    {||;
*      toStream(DlgValue("prefix"));
*      .and.ArtRefToStream();
*      .and.DlgDefine("prefix",", ");
*    },NIL,.f.;
*  )
*  DlgPop("prefix")
*endif
*RETURN .t.


#define WWW_ALIAS 1 // "PUB"
#define WWW_BABEL 2 // .f.
#define WWW_AZKEY 2 // {|| asc(left(eupper(PubTitle()),1))}
#define WWW_AZDIR 3 // "biblio"
#define WWW_AZKEYFILE 4 // {|k|ntrim(k)}
#define WWW_AZKEYTEXT 5 // {|k|chr(k)}
#define WWW_AZKEYTITLE 6 // {|k|"Bibliography"}
#define WWW_AZKEYORDER 7 // 2



// 20070425   {||TplLang()+left(eupper(KWD->Word),1)},;
FUNCTION ListKwds()
RETURN AzMake({oKwd(),oTpc(),oPub(),oQuo(),oAut()},;
  {||tr("A-Z","A-Z","A-Z")},;
  {||1},;
  {||TplLang()+left(eupper(KWD->Word),1)},;
  {||MsxLabel()},;
  {|k,i|MsxLabel()+ntrim(i)},; // k2file
  {|k,i|toStream(' [';
    +url2html(MsxLabel()+iif(i==1,"",ntrim(i))+HTMLEXT,substr(k,2));
  +'] ')},; // k2text
  {|k|substr(k,2)},;
  "HasRecords(oKwi(),2,'KWI->IdKwd',str(recno(),LenIdKwd(),0))",;
  NIL,.f.,;
  TplLang(),;
  "KWD->IdLng=='"+TplLang()+"'";
  )

// 20070425 {||left(eupper(PUB->Title),1)},;
FUNCTION ListPubs()
RETURN AzMake({oPub(),oAut()},;
  {||MsxTitle()},;
  {||2},;
  {||left(eupper(PUB->Title),1)},;
  {||MsxLabel()},;
  {|k,i|MsxLabel()+ntrim(i)},; // k2file
  {|k,i|toStream(' [';
    +url2html(MsxLabel()+iif(i==1,"",ntrim(i))+HTMLEXT,k);
  +'] ')},; // k2text
  {|k|k},;
  ".t.")

// 20070425  {||left(eupper(TPC->Name1),1)},;
FUNCTION ListTpcs()
RETURN AzMake({oTpc()},;
  {||MsxTitle()},;
  {||2},;
  {||left(eupper(TPC->Name1),1)},;
  {||MsxLabel()},;
  {|k,i|MsxLabel()+ntrim(i)},; // k2file
  {|k,i|toStream(' [';
    +url2html(MsxLabel()+iif(i==1,"",ntrim(i))+HTMLEXT,k);
  +'] ')},; // k2text
  {|k|k},;
  ".t.")

FUNCTION ListAuts()
RETURN AzMake({oAut()},;
  {||MsxTitle()},;
  {||2},;
  {||left(eupper(AUT->Name),1)},;
  {||MsxLabel()},;
  {|k,i|MsxLabel()+ntrim(i)},; // k2file
  {|k,i|toStream(' [';
    +url2html(MsxLabel()+iif(i==1,"",ntrim(i))+HTMLEXT,k);
  +'] ')},; // k2text
  {|k|k},;
  ".t.")

* toStream(' [<a href="'+MsxLabel()+iif(i==1,"",ntrim(i))+HTMLEXT+'">'),;
* toTxtStream(k),;
* toStream('</a>]');

FUNCTION ListPars()
RETURN AzMake({oPar()},;
  {||MsxTitle()},;
  {||4},;
  {||left(eupper(ParName()),1)},;
  {||MsxLabel()},;
  {|k,i|MsxLabel()+ntrim(i)},; // k2file
  {|k,i|toStream(' [';
    +url2html(MsxLabel()+iif(i==1,"",ntrim(i))+HTMLEXT,k);
  +'] ')},; // k2text
  {|k|k},;
  "!'X'$PAR->Attrib")


**
** called from pubs2www.act in a LngLoop()
**
FUNCTION AzMakeBabel(aTables,xcTitle,xnOrder,xuKey,xcDir,;
                k2file,k2text,k2title,xlFilter,;
                cFormat,lReverse,cStart,xlWhile;
                )
default lReverse to .f.
RETURN LngLoop({||AzMake(aTables,xcTitle,xnOrder,xuKey,xcDir,;
                k2file,k2text,k2title,xlFilter,;
                cFormat,lReverse,;
                cStart,xlWhile)})

FUNCTION AzMake(aTables,xcTitle,xnOrder,xuKey,xcDir,;
                k2file,k2text,k2title,xlFilter,;
                cFormat,lReverse,cStart,xlWhile)
local aKeys := {}
local i
local cDir := eval(xcDir)
local k
local cBase := getWwwPath() + "\"+cDir
RETURN !SetMsg("cDir is empty!") if empty(cDir)
default lReverse to .f.
default cFormat to "br"
// first loop to collect existing keys
// MsgDisplay("AzMakeByLng() "+TplLang())
RETURN .f. if ! DbfScan(aTables,;
  eval(xnOrder),;
  cStart,xlWhile,xlFilter,;
  {||;
    DictAddItem(aKeys,eval(xuKey)),;
    .t.;
  };
)
// RETURN .f. if ! Confirm("AzMakeByLng() : len(Keys) is "+ntrim(len(aKeys)))
// SetBasePath("../..")
// SetBasePath(repl("../",ft_nooccur("\",cDir)-1)+"..")
* if lReverse
*   asort(aKeys)
* endif
for i := 1 to len(aKeys)
  RETURN .f. if ! AzKeysToHtml(aKeys,i,aTables,xcTitle,eval(xnOrder),xuKey,;
    xcDir,k2file,k2text,xlFilter,cFormat,k2title)
next i
RETURN .t.
*RETURN .t. if len(aKeys) == 0
*if lReverse
*  k := atail(aKeys)
*else
*  k := aKeys[1]
*endif
** if ! empty(cDir)
**   cBase += "\"+cDir
** endif
*RETURN CopyFile(cBase+"\"+eval(k2file,k)+HTMLEXT,cBase+HTMLEXT)


STATIC FUNCTION AzKeysToHtml(aKeys,i,aTables,xcTitle,nOrder,xuKey,;
  xcDir,k2file,k2text,xlFilter,cFormat,k2title)
local k := aKeys[i]
local c
local c2
// MsgDisplay("AzKeysToHtml() "+TplLang())
if i > 1
  c := getWwwPath()+"\"+eval(k2file,k,i)+HTMLEXT
  c2 := eval(xcTitle)+":"+eval(k2title,k)
  MsgDisplay(c)
  RETURN .f. if ! BeginHtmPage(c, c2, UserDate())
  toStream('<div id="titleArea">')
  toStream('<p class="superTitle"></p>')
  toStream('<H1>')
  toTxtStream(getvar("Title"))
  toStream('</H1>')
  toStream('</div><!-- titleArea -->')
  toStream('<div id="mainArea">')
endif
toStream('<div id="browserPanel">')
arrayscan(aKeys,k2text)
toStream('</div><!-- id="browserPanel"-->')
BeginList(cFormat)
DbfScan(aTables,nOrder,k,NIL,;
  xlFilter,;
  {||BeginItem().and.RfxToHtml(cFormat).and.EndItem()};
)
EndList()
if i > 1
  toStream('</div><!-- mainArea -->')
  RETURN .f. if ! EndHtmPage()
endif
RETURN .t.

FUNCTION RfxToHtml(cFormat)
local c := alias() + 'ToHtml("' + cFormat + '")'
if alias() == "RFX"
  raise("RfxToHtml() : alias() is RFX")
endif
RETURN xparse(c)

FUNCTION MsgMore()
RETURN tr("more","weiter","suite","verder","edasi")


#define LST_FMT    1
#define LST_TITLE  2
#define LST_ICOUNT 3
#define LST_CLASS  4
#define LST_ALEN   4


FUNCTION BeginList(cFmt,cTitle,cClass)
local a := array(LST_ALEN)
a[LST_FMT] := cFmt
a[LST_TITLE] := cTitle
a[LST_CLASS] := cClass
a[LST_ICOUNT] := 0
aadd(saListStack,a)
RETURN .t.

FUNCTION EndList()
local a
if len(saListStack) == 0
  RETURN !SetMsg("EndList() : list stack is empty !")
endif
a := atail(saListStack)
if a[LST_ICOUNT] != 0
  if a[LST_FMT] == "ul"
    toStream("</ul>")
  elseif a[LST_FMT] == "ol"
    toStream("</ol>")
  elseif a[LST_FMT] == "table"
    toStream("</table>")
  elseif a[LST_FMT] == "para"
  elseif a[LST_FMT] == "br"
  elseif a[LST_FMT] == "comma"
  else
    SetMsg(a[LST_FMT] + " : unknown list format")
    RETURN .f.
  endif
endif
asize(saListStack,len(saListStack)-1)
RETURN .t.

FUNCTION ListFormat()
local a := atail(saListStack)
RETURN a[LST_FMT]

FUNCTION BeginItem()
local a := atail(saListStack)
if a[LST_ICOUNT] == 0
  if !empty(a[LST_TITLE])
    if a[LST_FMT] == "comma"
      toTxtStream(a[LST_TITLE])
    else
      toStream("<p><b>")
      toTxtStream(a[LST_TITLE])
      toStream("</b></p>")
    endif
  endif
  if a[LST_FMT] == "ul"
    if a[LST_CLASS] == NIL
      toStream("<ul>")
    else
      toStream('<ul class="'+a[LST_CLASS]+'">')
    endif
  elseif a[LST_FMT] == "ol"
    if a[LST_CLASS] == NIL
      toStream("<ol>")
    else
      toStream('<ol class="'+a[LST_CLASS]+'">')
    endif
  elseif a[LST_FMT] == "comma"
    toStream(" : ")
  elseif a[LST_FMT] == "table"
    if a[LST_CLASS] == NIL
      toStream('<table>')
    else
      toStream('<table class="'+a[LST_CLASS]+'">')
    endif
  elseif a[LST_FMT] == "para"
    // okay
  elseif a[LST_FMT] == "br"
    // okay
  else
    SetMsg(a[LST_FMT] + " : unknown list format")
    RETURN .f.
  endif
endif
if a[LST_FMT] == "ul"
  toStream("<li>")
elseif a[LST_FMT] == "ol"
  toStream("<li>")
elseif a[LST_FMT] == "table"
  toStream("<tr>")
elseif a[LST_FMT] == "para"
  toStream("<p>")
elseif a[LST_FMT] == "br"
elseif a[LST_FMT] == "comma"
  // toStream("<br>")
else
  SetMsg(a[LST_FMT] + " : unknown list format")
  RETURN .f.
endif
a[LST_ICOUNT] += 1
RETURN .t.

FUNCTION EndItem()
local a := atail(saListStack)
if a[LST_FMT] == "ul"
  toStream("</li>")
elseif a[LST_FMT] == "ol"
  toStream("</li>")
elseif a[LST_FMT] == "table"
  toStream("</tr>")
elseif a[LST_FMT] == "comma"
  toStream(", ")
elseif a[LST_FMT] == "para"
  toStream("</p>")
elseif a[LST_FMT] == "br"
  toStream("<br>")
else
  SetMsg(a[LST_FMT] + " : unknown list format")
  RETURN .f.
endif
RETURN .t.


*FUNCTION DbfToHtml(;
*  cDir,
*  cTitle,;
*  aTables,nOrder,cStart,xlWhile,xlFilter,;
*  cFormat,nPgLen)
*local lTaskInter := .t.
*local nPage := 0
*local nPgCount
*local nRecCount := DbfSum(aTables,"1",nOrder,cStart,xlWhile,xlFilter)
**
*default nPgLen to 20
*default cFormat to "table"
**
*nPgCount := int(nRecCount/nPgLen)+1
*// ab hier modified copy of DbfScan()
*begin sequence
*  if ! AreaOpen( a, .f. ) ; break ; endif
*  lOkay := .t.
*  if nOrder != NIL
*    ddSetOrder(nOrder)
*  endif
*  if indexord() != 0
*    softseek cStart
*  else
*    go top
*  endif
*  if len(cStart) == 0
*    default xlWhile to ".t."
*  else
*    default xlWhile to "left(" + indexkey() + "," ;
*            + ntrim(len(cStart)) + ")=='" + cStart + "'"
*  endif
*  do while ! eof() .and. &xlWhile
*    if lTaskInter
*      MsgDisp2(ntrim0(nCount++ * 100 / lastrec()) + "%")
*      if TaskInter() ; lOkay := .f.; exit ; endif
*    endif
*    if xeval(xlFilter)
*      if ! xeval(xlEval)
*        lOkay := .f.
*        exit
*      endif
*    endif
*    skip
*    if nMaxCount != NIL .and. nCount > nMaxCount
*      exit
*    endif
*  enddo
*  AreaClose()
*end sequence
*  *#ifdef DEF_DEBUG
*  *  popSequence()
*  *#endif DEF_DEBUG
*
*
*RETURN DbfScan( ;
*  aTables,nOrder,cStart,xlWhile,xlFilter,;
*  {||nPage+=1,_DbfToHtml()})
*
*STATIC FUNCTION _DbfToHtml(nPgNum,nPgCount,nPgLen,
*  i,aTables,xcTitle,nOrder,xuKey,;
*  xcDir,k2file,k2text,xlFilter,cFormat,k2title)
*local k := aKeys[i]
*local c
*local i
*local cTitle
*local cFilename := getWwwPath() + eval(xcDir) + "\" +eval(k2file,k)+HTMLEXT
*local cTitle := eval(xcTitle)+" (page "+ntrim(nPgNum)+" of "+ntrim(nPgCount)+")"
*MsgDisplay(cFilename)
*RETURN .f. if ! BeginHtmPage(cFilename, cTitle, UserDate())
*toStream('<table class="head"><tr><td><p class="title">')
*toTxtStream(cTitle)
*toStream('</p></td></tr></table>')
*toStream('<table class="main"><tr><td width="80%">')
*toStream('<HR NOSHADE/>')
*for i := 1 to nPgCount
*next i
*arrayscan(aKeys,k2text)
*toStream('<HR NOSHADE/>')
*BeginList(cFormat)
*DbfScan(aTables,nOrder,k,NIL,;
*  xlFilter,;
*  {||BeginItem().and.RfxToHtml(cFormat).and.EndItem()};
*)
*EndList()
*toStream('</td><td class="right" width="20%">')
*// if lBabel.and.!empty(MemLang2)
*if !empty(MemLang2)
*  LngLoop({||;
*  toStream('<a href="';
*    + GetBasePath()+strtran(eval(xcDir),"\","/");
*    + '/index'+HTMLEXT+'">' );
*  .and.toStream('<img src="'+GetBasePath();
*    +'/images/buttons/lang-'+lower(TplLang())+'.png" width="20" border=0></a> ');
*  })
*endif
*RETURN EndHtmPage()



*STATIC FUNCTION _DbfToHtml(nPgNum,nPgCount,nPgLen,
*  i,aTables,xcTitle,nOrder,xuKey,;
*  xcDir,k2file,k2text,xlFilter,cFormat,k2title)
*local k := aKeys[i]
*local c
*local i
*local cTitle
*local cFilename := getWwwPath() + eval(xcDir) + "\" +eval(k2file,k)+HTMLEXT
*local cTitle := eval(xcTitle)+" (page "+ntrim(nPgNum)+" of "+ntrim(nPgCount)+")"
*MsgDisplay(cFilename)
*RETURN .f. if ! BeginHtmPage(cFilename, cTitle, UserDate())
*toStream('<table class="head"><tr><td><p class="title">')
*toTxtStream(cTitle)
*toStream('</p></td></tr></table>')
*toStream('<table class="main"><tr><td width="80%">')
*toStream('<HR NOSHADE/>')
*for i := 1 to nPgCount
*next i
*arrayscan(aKeys,k2text)
*toStream('<HR NOSHADE/>')
*BeginList(cFormat)
*DbfScan(aTables,nOrder,k,NIL,;
*  xlFilter,;
*  {||BeginItem().and.RfxToHtml(cFormat).and.EndItem()};
*)
*EndList()
*toStream('</td><td class="right" width="20%">')
*// if lBabel.and.!empty(MemLang2)
*if !empty(MemLang2)
*  LngLoop({||;
*  toStream('<a href="';
*    + GetBasePath()+strtran(eval(xcDir),"\","/");
*    + '/index'+HTMLEXT+'">' );
*  .and.toStream('<img src="'+GetBasePath();
*    +'/images/buttons/lang-'+lower(TplLang())+'.png" width="20" border=0></a> ');
*  })
*endif
*RETURN EndHtmPage()



FUNCTION SrcToHtml(cFormat)
if cFormat $ "br,ul,ol,para"
  SrcRefToStream() // "trim(SrcTitle())")
  * if !empty(SRC->fileref)
  *   toStream(" (")
  *   fileref(SRC->fileref)
  *   toStream(") ")
  * endif
  if !empty(SRC->type)
    toHtmStream(trims(DbcText("SRCTYPE.DBC",SRC->Type)," (",") "))
  endif
  xt_abstract(SRC->Abstract)
  *if empty(SRC->Abstract)
  *  BeginList("comma")
  *  DbfScan({oSrc()},2,SRC->IdSrc,;
  *    "SRC->Parent=='"+SRC->IdSrc+"'",;
  *    ".t.",{||BeginItem().and.SrcRefToStream().and.EndItem()},;
  *    ,NIL,.f.)
  *  EndList()
  *else
  *  toStream(" &mdash; ")
  *  toHtmStream(SRC->Abstract,"SRC->Abstract "+SRC->IdSrc)
  *endif
  RETURN .t.
endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")




#ifdef DEF_LITERA

FUNCTION PubToHtml(cFormat)
if cFormat $ "br,ul,ol,para"
  RETURN PubRefToStream() if PubIsContainer()
  toStream("<b>")
  toTxtStream(trim(PubTitle()))
  toStream("</b> ")
  if !empty(PUB->IdAut).and.indexord() != ORD_PUB_AUT
    DbfPeek(oAut(),PUB->IdAut,"toTxtStream(trim(AutName()))",.f.)
    toStream(" ")
  endif
  if !empty(PUB->Url)
    toStream(" &uarr;"+url2html(PUB->URL)+" ")
  endif
  if !empty(PUB->Abstract)
    toStream(" &mdash; ")
    toHtmStream(PUB->Abstract,"PUB->Abstract "+PUB->IdPub)
  endif
  RETURN .t.
  // RETURN RfxList2ToStream("PUB:"+alltrim(PUB->IdPub)," (&rarr; ",")")
endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")

FUNCTION AutToHtml(cFormat)
if cFormat $ "br,ul,ol,para"
  RETURN AutRefToStream() if AutIsContainer()
  toStream("<b>")
  toTxtStream(trim(AutName()))
  toStream("</b> ")
  if !empty(AUT->Url)
    toStream(" &uarr;"+url2html(AUT->URL)+" ")
  endif
  if !empty(AUT->Abstract)
    toStream(" &mdash; ")
    toHtmStream(AUT->Abstract,"AUT->Abstract")
  endif
  RETURN .t.
  // RETURN RfxList2ToStream("AUT:"+alltrim(AUT->IdAut)," (&rarr; ",")")
endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")



FUNCTION PrjToHtml(cFormat)
if cFormat $ "br,ul,ol,para"
  * RETURN PrjRefToStream() if PrjIsContainer()
  PrjRefToStream()
  * if PrjIsContainer()
  * else
  *   toTxtStream(trim(PrjName()))
  * endif
  * toTxtStream(trims(PrjName()," (",") "))
  toTxtStream(trims(DbcText("PRJSTAT.DBC",PRJ->Status)," [","] "))
  xt_abstract(PRJ->Abstract)
  // RETURN RfxList2ToStream("PRJ:"+alltrim(PRJ->IdPrj)," (&rarr; ",")")
  RETURN .t.
elseif cFormat == "table"
  toStream("<td>")
  toTxtStream(dtocf(PRJ->lastMod))
  toStream("</td>")
  toStream("<td>")
  PrjRefToStream("trim(PrjName())")
  * toTxtStream(trim(PrjName()))
  if !empty(PRJ->Abstract)
    toStream(" &mdash; ")
    toHtmStream(PRJ->Abstract,"PRJ->Abstract "+alltrim(PRJ->IdPrj))
  endif
  toStream("</td>")
  toStream("<td>")
  toTxtStream(dtocf(PRJ->Date1))
  toStream(" - ")
  toTxtStream(dtocf(PRJ->Date2))
  toStream("</td>")
  toStream("<td>")
  toTxtStream(trim(DbcText("PRJSTAT.DBC",PRJ->Status)))
  toStream("</td>")
  RETURN .t.
endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")

FUNCTION xt_abstract(cAbstract)
** wenn nur der Titel eines MSX da steht, dann soll nicht auch noch
** "weiter" dahinter stehen.
local lSayMore := .f.
local b := GetTable(alias())
local nOrder := xt_TreeIndex()
local cId := &("Id"+alias())
if empty(cAbstract)
  if nOrder != NIL
    BeginList("comma")
    DbfScan({b},nOrder,cId,NIL,NIL,{||;
      (lSayMore:=.t.)!=NIL.and.BeginItem().and.xt_RefToStream("xt_title()").and.EndItem()})
    EndList()
  endif
else
  lSayMore := .t.
  toStream(" &mdash; ")
  toHtmStream(cAbstract,RfxIdRfx()+"->xt_abstract()")
endif
RETURN lSayMore

FUNCTION xt_treeindex()
RETURN 4 if alias()=="MSX"
RETURN 3 if alias()=="NEW"
RETURN 6 if alias()=="TPC"
RETURN 5 if alias()=="PRJ"
RETURN 2 if alias()=="SRC"
RETURN NIL

* FUNCTION xt_reftohtml()
* local c := alias()+"RefToHtml("+utos(xcTitle)+")"
* RETURN &c

FUNCTION xt_RefToStream(xcTitle)
local c := alias()+"RefToStream("+utos(xcTitle)+")"
RETURN &c

FUNCTION xt_date()
if alias()=="MSX"
  RETURN dtos(MSX->Date)
elseif alias()=="TPC"
  RETURN ""
elseif alias()=="SRC"
  RETURN ""
elseif alias()=="ART"
  RETURN ""
elseif alias()=="NEW"
  RETURN dtos(NEW->Date)
elseif alias()=="PUB"
  RETURN left(PUB->Date,8)
elseif alias()=="AUT"
  RETURN left(AUT->Born,8)
elseif alias()=="PAR"
  RETURN ""
  * RETURN PAR->GebDat
  * RETURN dtos(PAR->Birth)
elseif alias()=="VOC"
  RETURN ""
endif
RETURN ""

FUNCTION xt_title()
if alias()=="MSX"
  RETURN MsxTitle()
elseif alias()=="TPC"
  RETURN TpcName()
elseif alias()=="SRC"
  RETURN SRC->Fileref
elseif alias()=="ART"
  RETURN ArtName()
elseif alias()=="NEW"
  RETURN NEW->Title
elseif alias()=="MTG"
  RETURN MtgTitle()
elseif alias()=="PUB"
  RETURN PUB->Title
elseif alias()=="QUO"
  RETURN QUO->Ref
elseif alias()=="AUT"
  RETURN trim(AUT->Name)+","+trim(AUT->Vorname)
elseif alias()=="PAR"
  RETURN trim(ParName())
elseif alias()=="VOC"
  RETURN VocName()
elseif alias()=="DLS"
  RETURN dtos(DLS->Date)+" "+trim(DLS->NB)
#ifdef DEF_PIN
elseif alias()=="PIN"
  RETURN "#"+alltrim(PIN->IdPin)+" ("+trim(PIN->Short)+")"
#endif
endif
RETURN RfxIdRfx()


FUNCTION ArtToHtml(cFormat)
if cFormat $ "br,ul,ol,para"
  RETURN ArtRefToStream() if ArtIsContainer()
  toTxtStream(trim(ArtName(NIL,TplLang())))
  if !empty(ART->URL)
    toStream(" &uarr;"+url2html(ART->URL))
  endif
  if !empty(ART->Memo1)
    toStream(" &mdash; ")
    toHtmStream(ArtMemo(TplLang()),"ArtMemo() "+ltrim(ART->IdArt))
  endif
  RETURN .t.
  // RETURN RfxList2ToStream("ART:"+alltrim(ART->IdArt)," (&rarr; ",")")
endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")

FUNCTION TpcToHtml(cFormat)
if cFormat $ "br,ul,ol,para,comma"
  RETURN TpcRefToStream() if TpcIsContainer()
  toTxtStream(trim(TpcName()))
  if ! cFormat $ "comma"
    if !empty(TPC->URL)
      toStream(" &uarr;"+url2html(TPC->URL))
    endif
    xt_abstract(LngExpr("TPC->Memo"))
  endif
  *if empty(TPC->Memo1)
  *  BeginList("comma")
  *  DbfScan({oTpc()},xt_TreeIndex(),TPC->IdTpc,NIL,NIL,{||;
  *    BeginItem().and.xt_RefToStream().and.EndItem()})
  *  EndList()
  *else
  *  toStream(" &mdash; ")
  *  toHtmStream(LngExpr("Memo"),"TpcMemo() "+ltrim(TPC->IdTpc))
  *endif
  * RETURN .f. if ! RfxListToStream("TPC:"+alltrim(TPC->IdTpc)," (&rarr; ",")")
  * RETURN RfxList2ToStream("TPC:"+alltrim(TPC->IdTpc)," (&rarr; ",")")
  RETURN .t.
endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")

FUNCTION QuoToHtml(cFormat)
if cFormat $ "br,ul,ol,para"
  RETURN QuoRefToStream() if QuoIsContainer()
  toTxtStream(trim(QuoTitle()))
  if !empty(QUO->URL)
    toStream(" &uarr;"+url2html(QUO->URL))
  endif
  if !empty(QUO->Abstract)
    toStream(" &mdash; ")
    toHtmStream(QUO->Abstract,"QUO->Abstract "+ltrim(QUO->IdQuo))
  endif
  RETURN RfxList2ToStream("QUO:"+alltrim(QUO->IdQuo)," (&rarr; ",")")
endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")

FUNCTION url2text(cURL)
local n
if left(cURL,7)=="http://"
  cUrl := substr(cUrl,8)
elseif left(cURL,7)=="mailto:"
  cUrl := substr(cUrl,8)
endif
* if (n := at("/",cUrl)) > 0
*   cUrl := left(cUrl,n-1)
* endif
RETURN cUrl

FUNCTION ParToHtml(cFormat)
if cFormat $ "br,ul,ol,para"
  ParRefToStream()
  if ! empty(PAR->Name2)
    toTxtStream(", "+trim(PAR->Name2))
  endif
  if ! empty(PAR->Tel)
    toTxtStream(", "+tr("Phone:","Tel.","T‚l.","Tel.")+trim(PAR->Tel))
  endif
  if ! empty(PAR->email)
    toTxtStream(", "+strtran(trim(PAR->email),"@"," (at) "))
  endif
  if ! empty(PAR->URL)
    toStream(" &uarr;"+url2html(PAR->URL))
  endif
  RETURN .t.
elseif cFormat $ "table"
  toStream('<tr><td valign="top">')
  ParRefToStream()
  if ! empty(PAR->Tel)
    toStream("<br/ >")
    toTxtStream(tr("Phone:","Tel.","T‚l.","Tel.")+trim(PAR->Tel))
  endif
  if ! empty(PAR->Name2)
    toStream("<br/ >")
    toTxtStream(trim(PAR->Name2))
  endif
  if ! empty(PAR->Rue)
    toStream("<br/ >")
    toTxtStream(trim(ParStreet()))
    toStream("<br/ >")
    toTxtStream(trim(ParCity()))
  endif
  if ! empty(PAR->email)
    toStream("<br/ >")
    toTxtStream(strtran(trim(PAR->email),"@"," (at) "))
  endif
  if !empty(PAR->Memo)
    toStream("<br/ >")
    toHtmStream(PAR->Memo,"PAR->Memo "+ltrim(PAR->IdPar))
  endif
  if ! empty(PAR->URL)
    toStream("<br/ >&uarr;"+url2html(PAR->URL))
  endif
  toStream('</td><td valign="top">')
  if !empty(PAR->img)
    toStream(pic2html(trim(PAR->img),'width="100"'))
  endif
  toStream('</td></tr>')
  RETURN .t.
else
  toTxtStream(trim(ParName()))
endif
RETURN .t.

FUNCTION NewToHtml(cFormat)
if cFormat $ "br,ul,ol,para"
  * RETURN NewRefToStream() if NewIsContainer()
  * if ! empty(NEW->RefType)
  *   toTxtStream(trims(RefTypeText(NEW->RefType)," (",") "))
  * endif
  if !empty(NEW->img)
    toStream('<p class="preview">')
    * toStream('<br flush="right"/>')
    * toStream(pic2html(trim(NEW->img),'width="100" align="right"'))
    * toStream(pic2html(trim(NEW->img),'width="100" style="position:relative; right:0; top:0;"'))
    * confirm(pic2html(trim(NEW->img)))
    toStream(pic2html(trim(NEW->img)))
  endif
  if empty(NEW->Title)
    NewRefToStream("alltrim(NEW->IdNew)")
    *if empty(NEW->URL)
      NewRefToStream("dtoc(NEW->Date)")
    *else
    *  toStream(url2html(NEW->URL,dtoc(NEW->Date)))
    *endif
  else
    *if empty(NEW->URL)
      NewRefToStream("trim(NEW->Title)")
    *else
    *  toStream(url2html(NEW->URL,trim(NEW->Title)))
    *endif
  endif
  toTxtStream(" (")
  if indexord() != 5 .and. ! empty(NEW->IdNgr)
    RETURN .f. if ! DbfPeek(oNgr(),NEW->IdNgr,"NgrRefToStream()",.f.)
    * NgrRefToStream('trims(NEW->IdNgr,"(",") ")')
    toTxtStream(" ")
  endif
  toTxtStream(dtocf(NEW->Date)+") ")
  if !empty(NEW->Abstract)
    toStream(" &mdash; ")
    toHtmStream(NEW->Abstract,"NEW->Abstract "+ltrim(NEW->IdNew))
  endif
  if ! empty(NEW->URL)
    toStream(" &uarr;"+url2html(NEW->URL))
  endif
  * RETURN RfxList2ToStream("NEW:"+alltrim(NEW->IdNew)," (&rarr; ",")")
  if NewHasMore()
    toStream(" ")
    NewRefToStream("MsgMore()")
  endif
  if !empty(NEW->img)
  *   toStream('<span style="clear:right;">foo</span>')
     toStream('</p>')
  endif
  RETURN .t.
elseif cFormat == "table"
  toStream("<td>")
  NewRefToStream("dtoc(NEW->Date)")
  * toTxtStream(" "+alltrim(NEW->Time))
  toStream("</td>")
  if indexord() != 4 // ORD_NEW_MSX
    toStream("<td>")
    if !empty(NEW->RefTo)
      RETURN .f. if !XrfPeek(NEW->RefTo,"RfxRefToStream(RfxIdRfx())",.f.)
    endif
    toStream("</td>")
  endif
  * if indexord() != 5 // ORD_NEW_MSX
  *   toStream("<td>")
  *   if !empty(NEW->IdMsx)
  *     * toStream(" (")
  *     RETURN .f. if !DbfPeek(oMsx(),NEW->IdMsx,"MsxRefToStream('trim(MSX->Title)')",.f.)
  *     * toStream(")")
  *   endif
  *   toStream("</td>")
  * endif
  toStream("<td>")
  if .t.
    NewRefToStream("trim(NEW->Title)")
  else
    toStream("<b>")
    toTxtStream(trim(NEW->Title))
    toStream("</b>")
  endif
  if !empty(NEW->Abstract)
    toStream(" &mdash; ")
  endif
  * if !empty(NEW->Body) // NewIsContainer()
  if NewHasMore()
    RETURN .f. if !toHtmStream(NEW->Abstract,"NEW->Abstract "+ltrim(NEW->IdNew),"0")
    toStream(" ")
    NewRefToStream("MsgMore()")
  else
    RETURN .f. if !toHtmStream(NEW->Abstract,;
      "NEW->Abstract "+ltrim(NEW->IdNew))
    if !empty(NEW->URL)
      toStream(" (&uarr;"+url2html(NEW->URL,;
        url2text(NEW->URL),trim(NEW->URL))+")")
    endif
    RETURN .f. if !RfxList2ToStream(RfxIdRfx()," (&rarr; ",")")
  endif
  toStream("</td>")
  * if indexord() != ORD_NEW_NGR
  *   seek NEW->IdNgr in NGR
  *   toStream("<td>")
  *   NgrRefToStream()
  *   toStream("</td>")
  * endif
  RETURN .t.
endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")

FUNCTION VocToHtml(cFormat)
if cFormat $ "table"
  toStream('<tr>')
  toStream('<td>') ; toTxtStream(VocName(NIL,"D")) ; toStream('</td>')
  toStream('<td>') ; toTxtStream(VocName(NIL,"K")) ; toStream('</td>')
  toStream('<td>') ; toTxtStream(VocName(NIL,"E")) ; toStream('</td>')
  toStream('<td>') ; toTxtStream(VocName(NIL,"F")) ; toStream('</td>')
  toStream('</tr>')
  RETURN .t.
endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")

FUNCTION NewParToStream()
NewRefToStream("trim(NEW->Title)")
if !empty(NEW->Abstract)
  toStream(" &mdash; ")
endif
* if !empty(NEW->Body) // NewIsContainer()
if NewHasMore()
  RETURN .f. if !toHtmStream(NEW->Abstract,"NEW->Abstract "+ltrim(NEW->IdNew),"0")
  toStream(" ")
  NewRefToStream("MsgMore()")
else
  RETURN .f. if !toHtmStream(NEW->Abstract,;
    "NEW->Abstract "+ltrim(NEW->IdNew))
  if !empty(NEW->URL)
    toStream(" (&uarr;"+url2html(NEW->URL,;
      url2text(NEW->URL),trim(NEW->URL))+")")
  endif
  RETURN .f. if !RfxList2ToStream(RfxIdRfx()," (&rarr; ",")")
endif
RETURN .t.

FUNCTION MsxToHtml(cFormat)
if cFormat $ "br,ul,ol,para"
  if empty(MSX->URL)
    if MsxIsContainer()
      MsxRefToStream("trim(MSX->Title)")
    else
      toStream("<u>")
      toTxtStream(trim(MSX->Title))
      toStream("</u>")
    endif
  else
    toStream(url2html(MSX->URL,trim(MSX->Title)))
  endif
  if !empty(MSX->SubTitle)
    toTxtStream(" ("+trim(MSX->Subtitle)+") ")
  endif
  if xt_abstract(MSX->Abstract)
    if MsxHasMore()
      toStream(" ")
      MsxRefToStream("MsgMore()")
    endif
  endif
  RETURN .t.
elseif cFormat == "table"
  toStream("<td>")
  if MsxIsContainer()
    MsxRefToStream("trim(MsxTitle())")
  else
    toStream("<u>")
    toTxtStream(trim(MSX->Title))
    toStream("</u>")
  endif
  if !empty(MSX->Abstract)
    toStream(" &mdash; ")
  endif
  if MsxHasMore()
    RETURN .f. if !toHtmStream(MSX->Abstract,"MSX->Abstract "+ltrim(MSX->IdMsx),"0")
    toStream(" ")
    MsxRefToStream("MsgMore()")
  else
    RETURN .f. if !toHtmStream(MSX->Abstract,"MSX->Abstract "+ltrim(MSX->IdMsx))
    RETURN .f. if !RfxList2ToStream("MSX:"+alltrim(MSX->IdMsx)," (&rarr; ",")")
  endif
  toStream("</td>")
  RETURN .t.
endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")

FUNCTION KwdToHtml(cFormat)
local cIdKwd
local lFirst
local lOkay
if cFormat $ "br,ul,ol,para"
  toStream("<b>")
  toTxtStream(trim(KWD->Word))
  toStream("</b>")
  cIdKwd := str(recno(),LenIdKwd(),0)
  open area oKwi()
    ddSetOrder(2)
    lOkay := .t.
    lFirst := .t.
    softseek cIdKwd
    do while lOkay .and. ! eof() .and. KWI->IdKwd == cIdKwd
      if lFirst
        toStream(" &rarr; ")
        lFirst := .t.
      else
        toStream(", ")
      endif
      if ! XrfPeek(KWI->IdRfx,"xt_reftoStream()",.f.)
      * if ! XrfPeek(KWI->IdRfx,"RfxRefToStream(KWI->IdRfx,'"+xt_title()+"','R')",.f.)
        raise("XrfPeek() failed " + KWI->IdRfx)
        lOkay := .f.
      endif
      skip
    enddo
  close area
  RETURN lOkay
endif
* if cFormat == "table"
*   toStream("<td>")
*   toTxtStream(dtocf(NEW->Date))
*   toStream("</td>")
*   toStream("<td><b>")
*   toTxtStream(trim(NEW->Title))
*   toStream("</b>")
*   if !empty(NEW->Abstract)
*     toStream(" &mdash; ")
*   endif
*   if NewIsContainer()
*     toHtmStream(NEW->Abstract,"NEW->Abstract "+ltrim(NEW->IdNew),"0")
*     toStream(" ")
*     NewRefToStream("MsgMore()")
*   else
*     toHtmStream(NEW->Abstract,"NEW->Abstract "+ltrim(NEW->IdNew))
*     RfxList2ToStream("NEW:"+alltrim(NEW->IdNew)," (&rarr; ",")")
*     if !empty(NEW->URL)
*       toStream("<p>&uarr;"+url2html(NEW->URL,NIL,trim(NEW->URL))+"")
*     endif
*   endif
*   toStream("</td>")
*   if indexord() != ORD_NEW_NGR
*     seek NEW->IdNgr in NGR
*     toStream("<td>")
*     NgrRefToStream()
*     toStream("</td>")
*   endif
*   RETURN .t.
* endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")



*  **
*  ** called from pubs2www.act in a LngLoop()
*  **
*  FUNCTION Pub_azMake
*  local aKeys := {}
*  local i
*  SetBasePath("../../..")
*  // first loop to collect existing keys
*  RETURN .f. if ! DbfScan({oPub()},;
*    2,;
*    NIL,NIL,NIL,;
*    {||;
*      DictAddItem(aKeys,asc(left(eupper(PubTitle()),1))),;
*      .t.;
*    };
*  )
*  // RETURN .f. if ! Confirm("len(Keys) is "+ntrim(len(aKeys)))
*  for i := 1 to len(aKeys)
*    RETURN .f. if ! PubAzToHtml(aKeys,i)
*  next i
*  RETURN .t.
*
*
*  STATIC FUNCTION PubAzToHtml(aKeys,i)
*  local k := aKeys[i]
*  RETURN .f. if ! BeginHtmPage(;
*    getWwwPath()+"\biblio\a-z\"+ntrim(k)+HTMLEXT,;
*    "Bibliography :"+chr(k))
*  toStream('<table class="head"><tr><td><h1>')
*  toTxtStream(getvar("Title"))
*  toStream('</h1></td></tr></table>')
*  toStream('<table class="main"><tr><td width="80%">')
*  toStream('<HR NOSHADE>')
*  arrayscan(aKeys,{|k|;
*    toStream( '[<a href="' + ntrim(k) + '.htm">' ;
*      + DrvCvtString(chr(k)) ;
*      + '</a>]' );
*  })
*  toStream('<HR NOSHADE>')
*  DbfScan({oPub()},2,chr(k),NIL,;
*    NIL,{||toStream("<br>").and.PubAz2ToHtml()};
*  )
*  toStream('</td><td class="right" width="20%">')
*  RETURN EndHtmPage()
*
*  STATIC FUNCTION PubAz2ToHtml()
*  RETURN PubRefToStream() if PubIsContainer()
*  toTxtStream(trim(PubTitle()))
*  if !empty(PUB->URL)
*    toStream(" &uarr;"+url2html(PUB->URL))
*  endif
*  toStream(toHtml(PUB->Abstract,"PUB->Memo "+ltrim(PUB->IdPub)))
*  RETURN RfxList2ToStream("PUB:"+alltrim(PUB->IdPub)," (&rarr; ",")")
*
*  **
*  ** called from pubs2www.act in a LngLoop()
*  **
*  FUNCTION Aut_azMake
*  local aKeys := {}
*  local i
*  SetBasePath("../../..")
*  // first loop to collect existing keys
*  RETURN .f. if ! DbfScan({oAut()},;
*    2,;
*    NIL,NIL,NIL,;
*    {||;
*      DictAddItem(aKeys,asc(left(eupper(AutName()),1))),;
*      .t.;
*    };
*  )
*  // RETURN .f. if ! Confirm("len(Keys) is "+ntrim(len(aKeys)))
*  for i := 1 to len(aKeys)
*    RETURN .f. if ! AutAzToHtml(aKeys,i)
*  next i
*  RETURN .t.
*
*
*  STATIC FUNCTION AutAzToHtml(aKeys,i)
*  local k := aKeys[i]
*  RETURN .f. if ! BeginHtmPage(;
*    getWwwPath()+"\people\a-z\"+ntrim(k)+HTMLEXT,;
*    "People :"+chr(k))
*  toStream('<table class="head"><tr><td><h1>')
*  toTxtStream(getvar("Title"))
*  toStream('</h1></td></tr></table>')
*  toStream('<table class="main"><tr><td width="80%">')
*  toStream('<HR NOSHADE>')
*  arrayscan(aKeys,{|k|;
*    toStream( '[<a href="' + ntrim(k) + '.htm">' ;
*      + DrvCvtString(chr(k)) ;
*      + '</a>]' );
*  })
*  toStream('<HR NOSHADE>')
*  DbfScan({oAut()},2,chr(k),NIL,;
*    NIL,{||toStream("<br>").and.AutAz2ToHtml()};
*  )
*  toStream('</td><td class="right" width="20%">')
*  RETURN EndHtmPage()
*
*  STATIC FUNCTION AutAz2ToHtml()

*RETURN AutRefToStream() if AutIsContainer()
*toTxtStream(trim(AutName()))
*if !empty(AUT->URL)
*  toStream(" &uarr;"+url2html(AUT->URL))
*endif
*toStream(toHtml(AUT->Abstract),"AUT->Abstract "+ltrim(AUT->IdAut))
*RETURN RfxList2ToStream("AUT:"+alltrim(AUT->IdAut)," (&rarr; ",")")

#endif DEF_LITERA


FUNCTION fileref(cRef,cParams,cTitle)
local s
// local fname := "t:\svnwork\lino\trunk\" + strtran(cRef,"/","\")
local fname := vol2loc(alltrim(cRef))
#ifdef DEF_LFN
  local a := lf_getfinfo(fname)
  RETURN !SetMsg(fname+MsgFileExist()) if empty(a)
#endif
* s := '<a href="' + getBasePath()+"/files/" + cRef + '"'
* s := '<a href="' + "http://lsaffre.dyndns.org/cgi-bin/viewcvs.cgi/trunk/"+ cRef + '"'
* s := '<a href="' + "http://svn.berlios.de/viewcvs/lino/trunk/" ;
*  + cRef + '?view=markup"'
s := '<a href="' + vol2url(cRef)+'"'
** example: http://svn.berlios.de/viewcvs/lino/trunk/README.txt?view=markup
if cTitle != NIL
  s += ' title="' + DrvCvtString(cTitle) + '"'
endif
s += ">"
if empty(cParams)
  cParams := cRef
endif
s += DrvCvtString(cParams) + '</a>'
RETURN toStream(s)
*RETURN s

FUNCTION ref2html(cRef,cTitle)
cTitle := strtran(cTitle,CR_LF," ")
RETURN "" if XrfPeek(cRef,{||RfxRefToStream(cRef,cTitle,"R")},.f.)
RETURN !SetMsg(cRef+" "+cTitle + " : invalid reference")

FUNCTION xe2html(cRef,cTitle)
if left(cTitle,1) == "@"
  cTitle := XrfPeek(cRef,{||xt_title()},cTitle)
endif
RETURN cTitle
* RETURN "" if XrfPeek(cRef,{||RfxRefToStream(cRef,cTitle,"X")},.f.)
* RETURN !SetMsg(cRef+" "+cTitle + " : invalid reference")

FUNCTION item2html(cRef,cTitle)
RETURN .t. if XrfPeek(cRef,;
  {||toStream("<li>").and.RfxToHtml("ul").and.toStream("</li>")},;
  .f.)
RETURN !SetMsg(cRef+" : invalid reference")


FUNCTION url2html(cUrl,cLabel,cTitle)
local s
local n
if empty(cUrl)
  RETURN '' if empty(cLabel)
  RETURN DrvCvtString(cLabel)
endif
cUrl := alltrim(cUrl)
s := '<a href="' +cUrl+'"'
if !empty(cTitle)
  s += ' title="' + DrvCvtString(cTitle) + '"'
endif
s += ">"
if empty(cLabel)
  cLabel := url2text(cUrl)
else
  cLabel := DrvCvtString(cLabel)
endif
s += cLabel
s += "</a>"
RETURN s



**
** TPC - Topics
**
FUNCTION oTpc(lRebuild)
static b
if lRebuild == NIL
  RETURN b if b != NIL
else
  b := NIL
endif
define data b name TPC ;
       editprint  ActExec('TPCPRINT') ;
       create TpcCreate() ;
       predelete TpcPreDelete(TPC->IdTpc) ;
       wait {|msk| TpcWait(msk)}
ddIndex b on  TPC->IdTpc text "ID" ;
              format {|x|GetIdTpc(padr(upper(x),LenIdTpc()))}
// 20070425
ddAddIndex("upper(TPC->Name1)","Bezeichnung1",NIL,{|x|upper(x)})
ddAddIndex("upper(TPC->Name2)","Bezeichnung2","!empty(TPC->Name2)",{|x|upper(x)})
ddAddIndex("upper(TPC->Name3)","Bezeichnung3","!empty(TPC->Name3)",{|x|upper(x)})
ddAddIndex("upper(TPC->Name4)","Bezeichnung4","!empty(TPC->Name4)",{|x|upper(x)})
ddAddIndex("TPC->Parent+TPC->Seq","by Parent") // ORD_TPC_PARENT
ddFld IdTpc   ,C, LenIdArt(),0 when .f. picture "@k@!"
ddFld Name1   ,C,LenArtName(),0
ddFld Name2   ,C,LenArtName(),0
ddFld Name3   ,C,LenArtName(),0
ddFld Attrib  ,C,3,0 picture PIC_ID ;
                     pick PickDbcAttr("TPCATTR.DBC",TPC->Attrib)
ddFld Memo1    ,M, 10,0
ddFld Memo2    ,M, 10,0
ddFld Memo3    ,M, 10,0
action b key K_ALT_F7 prompt MsgMnuAttrib() block TpcPickAttrib()
ddAddField("Label","C",8,0)
ddAddField("Sort","C",1,0,;
  "@k@!",NIL,;
  NIL,NIL,;
  {||.t.},{|x|PickDbcCode("MSXSORT.DBC",x)},{||.t.};
)
ddAddField("RfxSort","C",1,0,;
  "@k@!",NIL,;
  NIL,NIL,;
  {||.t.},{|x|PickDbcCode("MSXSORT.DBC",x)},{||.t.};
)
ddAddField("Name4","C",LenArtName(),0)
ddAddField("Memo4","M",10,0)
ddAddField("URL","C",80,0)
ddAddField("URL2","C",80,0)
ddAddField("URL3","C",80,0)
ddAddField("URL4","C",80,0)
ddAddField("IdMsx","C",LenIdMsx(),0,;
  "@k@!",NIL,;
  NIL,NIL,;
  {||.t.},{|x|PickMsx(x)},{||.t.},;
  {|x|GetNum(x)})
ddAddField("Parent","C",LenIdPar(),0,;
  "@k@!",NIL,;
  NIL,NIL,;
  {||empty(TPC->Parent).or.DbfPeek(oTpc(),TPC->Parent,".t.",.f.);
     .or.Confirm("Invalid parent",MsgSure())},;
  {|x|PickTpc(x)},;
  {||.t.},;
  {|x|if(val(x)==0,x,GetNum(x))})
ddAddField("Seq","C",3,0,;
  "@k@!",NIL,;
  NIL,NIL,;
  {||.t.},NIL,{||.t.},;
  {|x|if(val(x)==0,x,GetNum(x))})
ddEndDef()
RETURN b

FUNCTION TpcName(cIdTpc,cIdLng)
default cIdLng to TplLang()
if cIdTpc != NIL
  if TPC->IdTpc != cIdTpc
    seek cIdTpc in TPC
  endif
endif
#ifdef DEF_4LANG
RETURN TPC->Name4 if cIdLng == MemLang4 .and. ! empty(TPC->Name4)
#endif
RETURN TPC->Name3 if cIdLng == MemLang3 .and. ! empty(TPC->Name3)
RETURN TPC->Name2 if cIdLng == MemLang2 .and. ! empty(TPC->Name2)
RETURN TPC->Name1


FUNCTION TpcCreate()
local cIdMsx
local cCopier := BUTTON_OFF
local aBuf := CopyRec()
cIdMsx := DbfAutoInc(oTpc())
open window ("create topic") size 4,50
do while .t.
  WinHome()
  say "ID: "
  get cIdMsx picture PIC_ID ;
             postedit {|x|GetNum(x)}
  WinCr()
  get cCopier checkbox
  say MsgCopy()
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cIdMsx)
    SetMsg(cIdMsx + " : " + MsgIdExist() )
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
if cCopier == BUTTON_ON
  PasteRec(aBuf)
elseif len(RecStack())>0
  PopRec()
endif
TPC->IdTpc   := cIdMsx
dbcommit()
RETURN DDCREATE_FULL


FUNCTION NewPreDelete()
RETURN ConfirmDelete() if empty(NEW->IdNew)
#ifdef DEF_RFX
  RETURN .f. if ! XrtCanDelete()
#endif DEF_RFX
RETURN .f. if ! Confirm( ;
  NEW->IdNew + " " + trim(NEW->Title) + " :", MsgRecDelete(), ;
  MSG_NO ;
)
RETURN .f. if ! HtmOnDelete()
#ifdef DEF_RFX
  RETURN .f. if ! XrtOnDelete()
#endif DEF_RFX
RETURN .t.

FUNCTION TpcPreDelete(cIdTpc)
* local lOkay := .f.
local cRef
RETURN ConfirmDelete() if empty(cIdTpc)
#ifdef DEF_RFX
  RETURN .f. if ! XrtCanDelete()
  * if DbfSum({oRfx()},'1',2,padr('TPC:'+alltrim(TPC->IdTpc),LEN_RFX)) != 0
  *   RETURN !SetMsg('there are x-references to this Topic!')
  * endif
#endif DEF_RFX
RETURN .f. if ! Confirm( ;
  TPC->IdTpc + " " + trim(TpcName()) + " :", MsgRecDelete(), ;
  MSG_NO ;
)
RETURN .f. if ! HtmOnDelete()
*open area oTlt()
*  lOkay := .t.
*  ddSetOrder 1
*  softseek cIdTpc
*  do while ! eof() .and. TLT->IdTpc1 == cIdTpc
*    if ddRecLock()
*      delete
*      unlock record
*    else
*      lOkay := .f.
*    endif
*    skip
*  enddo
*  ddSetOrder 2
*  softseek cIdTpc
*  do while ! eof() .and. TLT->IdTpc2 == cIdTpc
*    if ddRecLock()
*      delete
*      unlock record
*    else
*      lOkay := .f.
*    endif
*    skip
*  enddo
*close area
*RETURN .f. if ! lOkay
#ifdef DEF_RFX
  RETURN .f. if ! XrtOnDelete()
  * RETURN .f. if ! DbfDelete(NIL,;
  *   NIL,{oRfx()},ORD_RFX_1,;
  *   padr("TPC:"+alltrim(TPC->IdTpc),LEN_RFX);
  * )
#endif DEF_RFX
RETURN .t.




FUNCTION TpcPage(cIdTpc,cIdQry)
open area oTpc()
  if cIdTpc != NIL
    seek cIdTpc
  endif
  edit data oTpc() full noskip
close area
RETURN SetMnuDone()



FUNCTION TpcPickAttrib
local cAttrib := PickDbcAttr("TPCATTR.DBC",TPC->Attrib)
RETURN .f. if cAttrib == NIL
if ddRecLock()
  TPC->Attrib := cAttrib
  ddPostEdit()
  ddRefreshCurrent()
  unlock record
endif
RETURN MnuDone()

FUNCTION TpcExist( cId )
if TPC->IdTpc == cId .and. ! eof() in TPC
  RETURN .t.
endif
seek cId in TPC
if eof() in TPC
  SetMsg(cId + " : no such topic !")
  RETURN .F.
endif
RETURN .T.


FUNCTION TpcWait(wwin)
local b
if wwin[WIN_WAITKEY] == 2  // children
  b := oTpc()
  open area b
    edit data b key    TPC->IdTpc ;
                value  TPC->Parent ;
                mode wait ;
                window wwin ;
                start top ;
                query "TPCTPC"
  close area
endif
*if wwin[WIN_WAITKEY] == 2  // children
*  b := oTlt()
*  open area b, oTpc()
*    edit data b key    TLT->IdTpc1 ;
*                value  TPC->IdTpc ;
*                mode wait ;
*                window wwin ;
*                start top ;
*                query "TLTTPC1"
*  close area
*elseif wwin[WIN_WAITKEY] == 3  // parents
*  b := oTlt()
*  open area b, oTpc()
*    edit data b key    TLT->IdTpc2 ;
*                value  TPC->IdTpc ;
*                mode wait ;
*                window wwin ;
*                start top ;
*                query "TLTTPC2"
*  close area
*endif
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"TPC",TPC->IdTpc)
#endif DEF_RFX
RETURN NIL


FUNCTION SrcWait(wwin)
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"SRC",SRC->IdSrc)
#endif DEF_RFX
RETURN NIL




**
** TLT - Topic-to-Topic Links
**
*FUNCTION oTlt()
*static b := NIL
*if b != NIL ; RETURN b ; endif
*define data b name TLT                            ;
*  postedit TltPostEdit()
*ddIndex b on  TLT->IdTpc1+TLT->Line     // ORD_TLT_ART1
*ddIndex b on  TLT->IdTpc2+TLT->IdTpc1   // ORD_TLT_ART2
*ddFld IdTpc1   ,C, LenIdTpc(),0  when indexord()!=1 ;
*                   postedit {|x|GetIdTpc(x)} ;
*                   pick PickTpc(TLT->IdTpc1) ;
*               picture  "@k@!"
*ddFld Line     ,C, LEN_POS,0 GET_NUM
*ddFld IdTpc2   ,C, LenIdTpc(),0 when indexord()!=2 ;
*               picture  "@k@!" ;
*               pick PickTpc(TLT->IdTpc2) ;
*               postedit {|x|GetIdTpc(x)}
*ddEndDef()
*RETURN b
*
*
*FUNCTION TltPostEdit()
*RETURN .f. if ! TpcExist(TLT->IdTpc2)
*RETURN .t.


FUNCTION LenIdTpc()
RETURN LenIdArt()

FUNCTION GetIdTpc(x)
RETURN GetIdArt(x)

FUNCTION PickTpc(cStart)
RETURN DbfPick({oTpc()},"Select topic","TPCPICK",cStart,NIL,NIL,NIL,"TPC->IdTpc")


FUNCTION oSrc()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name SRC ;
       wait {|msk| SrcWait(msk)}

ddIndex b on  SRC->IdSrc
ddFld IdSrc   ,C, LenIdArt(),0  when .f. ;
               postedit {|x|GetIdArt(x)} ;
               picture  "@k@!"
ddEndDef()
RETURN b

FUNCTION SrcTitle
RETURN trim(SRC->Name)

FUNCTION PickSrc(cStart,xuReturn)
default xuReturn to "SRC->IdSrc"
RETURN DbfPick(;
  {oSrc()},;
  NIL,;
  "SRCPICK",;
  cStart,;
  NIL,;
  NIL,NIL,;
  xuReturn;
)




#define ORD_NAV_2 2


** used by SiteMenu()
**
FUNCTION oNav()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name NAV ;
       wait {|msk| NavWait(msk)} ;
       postedit NavPostEdit()
ddIndex b on  NAV->IdNav
ddIndex b on  NAV->IdLng+NAV->Parent+NAV->Seq // ORD_NAV_2
// ddIndex b on  NAV->IdLng+eupper(NAV->Title)
ddFld IdNav   ,C, LenIdMsx(),0  when .f. ;
               postedit {|x|GetNum(x)} ;
               picture  "@k@!"
ddFld IdLng   ,C, LenIdLng(),0 picture PIC_ID               ;
               pick PickLng(NAV->IdLng) ;
               valid IsLangue(NAV->IdLng)
ddFld Title   ,C,40,0
ddFld Parent  ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} ;
               pick PickNav(NAV->Parent)
ddFld Seq     ,C, LEN_MLMSEQ,0 postedit {|x|if(val(x)==0,x,GetNum(x))}
ddFld IdXrf   ,C, LEN_RFX,0 pick PickXrf(NAV->IdXrf)
ddFld URL     ,C,100,0
ddEndDef()
RETURN b

FUNCTION NavTitle
RETURN trim(NAV->Title)

FUNCTION NavPostEdit
local s
if empty(NAV->Title).and.!empty(NAV->IdXrf)
  s := XrfPeek(NAV->IdXrf,{||xt_title()},NIL)
  RETURN .f. if s == NIL
  NAV->Title := s
endif
RETURN .t.


FUNCTION NavWait(wwin)
local b
local cIdNav := NAV->IdNav
if wwin[WIN_WAITKEY] == 2  // MsxMlm1Edit() : edit Links FROM this
  b := oNav()
  open area b, oMsx(), oPub(), oAut(), oTpc(), oArt(), oPar()
    edit data b key    NAV->Parent ;
                value  cIdNav ;
                mode wait ;
                window wwin ;
                start top ;
                query "NAVNAV"
  close area
endif
* #ifdef DEF_RFX
*   RETURN NIL if DoRfxWait(wwin,"NAV",NAV->IdNav)
* #endif DEF_RFX
RETURN NIL

FUNCTION PickNav(cStart,xuReturn)
default xuReturn to "NAV->IdNav"
RETURN DbfPick(;
  {oNav()},;
  NIL,;
  "NAVPICK",;
  cStart,;
  NIL,;
  NIL,NIL,;
  xuReturn;
)













**
** NEW - News
**
**
FUNCTION oNew()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name NEW                           ;
  editprint  ActExec('NEWPRINT') ;
  create AutoIncCopy(b) ;
  predelete NewPreDelete(NEW->IdNew) ;
  wait {|wwin|NewWait(wwin)}
ddIndex b on  NEW->IdNew format {|x|padl(x,LenIdPar())}
// ddIndex b on  descend(dtos(NEW->Date)+NEW->Time,.t.) ;
//               format {|x|descend(x,.t.)}
ddIndex b on  dtos(NEW->Date)+NEW->Time
// ddIndex b on  NEW->IdNgr+dtos(NEW->Date)+NEW->Time for !empty(NEW->IdNgr)
ddFld IdNew   ,C, LenIdPar(),0 postedit {|x|GetNum(x)} when .f. attrib P
ddFld Date    ,D, 8,0
ddFld Title   ,C,100,0
ddFld Abstract ,M,10,0
ddFld Body    ,M,10,0
ddFld IdLng   ,C, LenIdLng(),0 picture PIC_ID               ;
               pick PickLng(NEW->IdLng) ;
               valid IsLangue(NEW->IdLng)
ddFld lastMod ,D, 8,0
ddFld IdUsr   ,C, LenIdUsr(),0 picture PIC_ID
ddFld IdNgr   ,C, 8,0 ;
               pick DbfPick(;
                 {oNgr(),oNew()},"select newsgroup",;
                 "NGRPICK",NEW->IdNgr,;
                 NIL,NIL,NIL,"NGR->IdNgr";
               )
ddEndDef()
RETURN b

FUNCTION NewWait(wwin)
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"NEW",NEW->IdNew)
#endif DEF_RFX
RETURN NIL


#define LEN_IDNGR 8

**
** NGR - Newsgroups
**
**
FUNCTION oNgr()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name NGR                           ;
  editprint  ActExec('NGRPRINT')
ddIndex b on  NGR->IdNgr format {|x|x}
ddFld IdNgr   ,C, LEN_IDNGR,0
ddFld Title   ,C,100,0
ddFld Abstract ,M,10,0
ddFld Body    ,M,10,0
ddFld IdLng   ,C, LenIdLng(),0 picture PIC_ID               ;
               pick PickLng(NGR->IdLng) ;
               valid IsLangue(NGR->IdLng)
ddFld IdMsx  ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} ;
              pick PickMsx(NGR->IdMsx)
ddFld NewAttr  ,M,10,0
ddEndDef()
RETURN b




*FUNCTION NewCreate()
*local cIdNew
*local cCopier := BUTTON_OFF
*local aBuf := CopyRec()
*cIdNew := DbfAutoInc(oNew())
*open window ("create message") size 4,50
*do while .t.
*  WinHome()
*  say "ID: "
*  get cIdNew picture PIC_ID ;
*             postedit {|x|GetNum(x)}
*  WinCr()
*  get cCopier checkbox
*  say MsgCopy()
*  nKey := ReadScr()
*  if nKey == K_ESC
*    close window
*    RETURN DDCREATE_FAIL
*  endif
*  if ! IsNewId(cIdNew)
*    SetMsg(cIdNew + " : " + MsgIdExist() )
*    loop
*  endif
*  exit
*enddo
*close window
*RETURN DDCREATE_FAIL if ! dbAddRec()
*if cCopier == BUTTON_ON
*  PasteRec(aBuf)
*  // NEW->RepTo := cRepTo
*elseif len(RecStack()) > 0
*  PopRec()
*else
*  NEW->Date := UserDate()
*endif
*NEW->IdNew   := cIdNew
*dbcommit()
*RETURN DDCREATE_FULL

FUNCTION NgrTitle(cIdNgr)
if cIdNgr != NIL
  seek cIdNgr in NGR
endif
RETURN trim(NGR->Title)





FUNCTION NewTitle()
if empty(NEW->Title)
  RETURN dtocf(NEW->Date,"dddd, d. mmmm yyyy") if TplLang() == "D"
  RETURN dtocf(NEW->Date,"dddd d mmmm yyyy")
endif
RETURN trim(NEW->Title)+" ("+dtocf(NEW->Date)+")"

*FUNCTION NewPreDelete(cIdNew)
*local lOkay := .t.
*#ifdef DEF_RFX
*  RETURN .f. if ! XrtCanDelete()
*  * if DbfSum({oRfx()},'1',2,padr('NEW:'+alltrim(NEW->IdNew),LEN_RFX)) != 0
*  *   RETURN !SetMsg('there are RFXs!')
*  * endif
*#endif DEF_RFX
*RETURN ConfirmDelete() if empty(cIdNew)
*RETURN .f. if ! Confirm( ;
*  NEW->IdNew + " " + trim(NewTitle()) + " :", MsgRecDelete(), ;
*  MSG_NO ;
*)
*#ifdef DEF_RFX
*  RETURN .f. if ! XrtOnDelete()
*#endif DEF_RFX
*RETURN lOkay

FUNCTION NewPage(cIdNew)
open area oNew(), oNgr(), oPrj()
  if cIdNew != NIL
    seek cIdNew
  endif
  edit data oNew() full noskip query ("NEW") title (NewTitle())
close area
RETURN MnuDone()

FUNCTION SrcPage(cIdNew)
open area oSrc()
  if cIdNew != NIL
    seek cIdNew
  endif
  edit data oSrc() full noskip query ("SRC") title (SrcTitle())
close area
RETURN MnuDone()


FUNCTION RefTypeText(cRefType)
local x := DbcText("REFTYPE.DBC",cRefType,3)
RETURN "" if empty(x)
// RETURN DbcText("REFTYPE.DBC",cRefType) if empty(x)
RETURN xparse(x)

FUNCTION ListNews()
* local cDir := trim(MSX->Match)
* if MSX->IdLng != MemLang1
*   cDir += lng2iso(MSX->IdLng)
* endif
RETURN !SetMsg("Only for MSX") if alias()!="MSX"
RETURN DbfToHtml( ;
  MsxLabel(),trim(MsxTitle()),;
  {oNew()},2,NIL,NIL,;
  "empty(NEW->Status).and.NEW->IdLng==MSX->IdLng.and.!empty(NEW->Date)",;
  "ul",15,.t.)

FUNCTION ListSrcs()
RETURN !SetMsg("Only for MSX") if alias()!="MSX"
RETURN DbfToHtml( ;
  MsxLabel(),trim(MsxTitle()),;
  {oSrc()},4,MSX->IdMsx,NIL,;
  ".t.",;
  "ul",15,.t.)

FUNCTION ListNgrNews(cIdNgr)
cIdNgr := padr(cIdNgr,LEN_IDNGR)
* if MSX->IdLng != MemLang1
*   cDir += lng2iso(MSX->IdLng)
* endif
RETURN !SetMsg("Only for MSX") if alias()!="MSX"
RETURN DbfToHtml( ;
  MsxLabel(),trim(MsxTitle()),;
  {oNew(),oNgr()},5,cIdNgr,NIL,;
  "empty(NEW->Status).and.!empty(NEW->Date)",;
  "ul",15,.t.)

FUNCTION ListPlsPars(cIdPls)
// cIdPls := padr(cIdPls,LEN_IDPLS)
RETURN !SetMsg("Only for MSX") if alias()!="MSX"
RETURN DbfToHtml( ;
  MsxLabel(),trim(MsxTitle()),;
  {oPar(),oPlz(),oNat()},2,NIL,NIL,;
  "ParIsMember('"+cIdPls+"')",;
  "table",15)

FUNCTION DbfToHtml(;
  cMatch,;
  cTitle,;
  aTables,nOrder,cStart,xlWhile,xlFilter,;
  cFormat,nPgLen,lDescend)
local lTaskInter := .t.
local nPgCount
local nRecCount := DbfSum(aTables,"1",nOrder,cStart,xlWhile,xlFilter,;
                          lDescend)
local lOkay
local r := r_open()
*
default nPgLen to 10
default cFormat to "table"
RETURN !SetMsg("invalid "+cMatch) if "\" $ cMatch
*
nPgCount := int(nRecCount/nPgLen)+1
r_addGroup(;
  {|n|int(n/nPgLen)+1},;
  {|nPgNum|_before(nPgNum,cMatch,cTitle,nPgCount,cFormat)},;
  {|nPgNum|_after(nPgNum,cMatch,cTitle,nPgCount,cFormat)};
)
lOkay := r_exec(aTables,nOrder,cStart,xlWhile,xlFilter,;
  {|nPgNum|_onEach(nPgNum,cMatch,cTitle,nPgCount,cFormat)},;
  NIL,NIL,lDescend)
r_close(r)
RETURN lOkay


FUNCTION _before(nPgNum,cMatch,cTitle,nPgCount,cFormat)
local i
local cFilename
if nPgNum > 1
  cFilename := getWwwPath() + "\" + strtran(cMatch,"/","\") + ntrim(nPgNum)+HTMLEXT
  cTitle += " (page "+ntrim(nPgNum)+" of "+ntrim(nPgCount)+")"
  MsgDisplay(cFilename)
  RETURN .f. if ! BeginHtmPage(cFilename, cTitle, UserDate())
  toStream(CR_LF+'<div id="titleArea"><H1>')
  toTxtStream(cTitle)
  toStream('</H1></div>')
  toStream(CR_LF+'<div id="mainArea">')
endif
if nPgCount > 1
  toStream(CR_LF+'<div id="browserPanel">')
  * if nPgNum == 1
  *   toStream(' 1 ')
  * else
  *   toStream(' <a href="../'+cMatch+HTMLEXT+'">1</a> ')
  * endif
  for i := 1 to nPgCount
    if i == nPgNum
      toStream(' '+ntrim(i)+' ')
    * elseif nPgNum == 1
    *   toStream(' <a href="'+cMatch+ntrim(i)+HTMLEXT+'">'+ntrim(i)+'</a> ')
    else
      toStream(' <a href="'+cMatch+iif(i==1,"",ntrim(i))+HTMLEXT+'">'+ntrim(i)+'</a> ')
    endif
  next i
  toStream('</div>')
endif
if ! BeginList(cFormat)
  rpt_write(SetMsg())
  SetKeepReport(.t.)
endif
RETURN .t.

FUNCTION _after(nPgNum,cMatch,cTitle,nPgCount,cFormat)
EndList()
if nPgNum > 1
  toStream('</div>')
  RETURN EndHtmPage()
endif
RETURN .t.

FUNCTION _oneach(nPgNum,cMatch,cTitle,nPgCount,cFormat)
BeginItem()
if ! RfxToHtml(cFormat)
  rpt_write(SetMsg())
  SetKeepReport(.t.)
endif
EndItem()
RETURN .t.


FUNCTION TreeNavigator()
local b := GetTable(alias())
local cId := FIELD->Parent
local c := ""
local a := {}
open area b
  seek cId // FIELD->Parent
  do while ! eof() // .and. !empty(FIELD->Parent)
    if !DictAddItem(a,RfxIdRfx())
      Warning(RfxIdRfx()+" : circular reference!")
      exit
    endif
    if ! empty(c)
      c := " &middot; " + c
    endif
    c := &(alias()+"RefToHtml()") + c
    seek FIELD->Parent
  enddo
close area
RETURN c

*FUNCTION NewTreeNavigator()
*local cId := FIELD->Parent
*local c := ""
*open area oNew()
*  seek FIELD->Parent
*  do while ! eof() .and. !empty(FIELD->Parent)
*    if ! empty(c)
*      c := " &middot; " + c
*    endif
*    c := NewRefToHtml() + c
*    seek FIELD->Parent
*  enddo
*close area
*RETURN c
*
*FUNCTION MsxTreeNavigator()
*local cId := FIELD->Parent
*local c := ""
*open area oMsx()
*  seek FIELD->Parent
*  do while ! eof() .and. !empty(FIELD->Parent)
*    if ! empty(c)
*      c := " &middot; " + c
*    endif
*    c := MsxRefToHtml() + c
*    seek FIELD->Parent
*  enddo
*close area
*RETURN c

FUNCTION xt_trurl()
RETURN xt_url() if alias()$"MTG,TPC,MSX"
RETURN '/index'+lngsuffix()+HTMLEXT

FUNCTION SiteMenu(cMySelf,nMaxLevel)
if !empty(MemLang2)
  toStream(CR_LF+'<ul id="langSelector">')
  * LngLoop({||;
  *   toStream('<li><a href="'+GetBasePath()+xt_trurl()+'">' );
  *   .and.toStream('<img src="'+GetBasePath();
  *     +'/images/buttons/lang-'+lng2iso(TplLang());
  *     +'.png" width="20" border=0></a></li>'+CR_LF);
  * })
  LngLoop({||;
    toStream('<li><a href="'+GetBasePath()+xt_trurl()+'">' );
    .and.toStream(upper(lng2iso(TplLang()))+'</a></li>'+CR_LF);
  })
  toStream(CR_LF+'</ul>')
endif
default nMaxLevel to 2
RETURN MnuToStream(iif(TplLang()=="*",MemLang1,TplLang()),1,space(LenIdMsx()),cMySelf,nMaxLevel)

STATIC FUNCTION MnuToStream(cIdLng,nLevel,cRoot,cMySelf,nMaxLevel)
local cHREF
local nCount := 0
open area oNav()
  ddSetOrder(ORD_NAV_2)
  softseek cIdLng+cRoot
  do while ! eof() .and. FIELD->IdLng == cIdLng ;
                   .and. FIELD->Parent == cRoot
    nCount += 1
    if nCount == 1
      toStream(CR_LF+'<ul class="menu'+ntrim(nLevel)+'">')
    endif
    if FIELD->IdXrf == cMyself
      toStream(CR_LF+'<li id="selectedItem">')
    else
      toStream(CR_LF+'<li>')
    endif
    * SrcRefToStream()
    if empty(NAV->IdXrf)
      toStream(url2html(NAV->URL,trim(NAV->Title)))
    else
      RfxRefToStream(NAV->IdXrf,trim(NAV->Title))
    endif
    toStream('</li>')
    if nMaxLevel > nLevel
      MnuToStream(cIdLng,nLevel+1,FIELD->IdNav,cMyself,nMaxLevel)
    endif
    skip
  enddo
close area
if nCount > 0
  toStream('</ul>')
endif
RETURN .t.

* FUNCTION SiteMenu(nMinLevel,nDown)
* local nOldLevel := 0
* local nLevel
* local nToLevel
* local cIdMsx
* local cMapCode
* default nMinLevel to 1
* default nDown to 1
* if alias() == "MSX"
*   cIdMsx := MSX->IdMsx
*   cMapCode := MSX->MapCode
*   nToLevel := len(trim(cMapCode))
* endif
* open area oMsx()
*   ddSetOrder 4
*   softseek TplLang()
*   do while MSX->IdLng == TplLang()
*     nLevel := len(trim(MSX->MapCode))
*     if nLevel > 0
*       if nLevel <= nMinLevel ;
*         .or. (cMapCode!=NIL ;
*              .and. left(MSX->MapCode,nLevel-1) == left(cMapCode,nLevel-1))
*         if nLevel > nOldLevel
*           toStream(CR_LF+'<ul class="menu'+ntrim(nLevel)+'">')
*         elseif nLevel < nOldLevel
*           toStream('</ul>')
*         endif
*         if MSX->IdMsx == cIdMsx
*           toStream(CR_LF+'<li class="activeItem">')
*         else
*           toStream(CR_LF+'<li>')
*         endif
*         MsxRefToStream()
*         toStream('</li>')
*         nOldLevel := nLevel
*       endif
*     endif
*     skip
*   enddo
*   do while nLevel > 0
*     toStream('</ul>')
*     nLevel -= 1
*   enddo
* close area
* RETURN .t.

FUNCTION ParIsContainer()
RETURN !PARATTR_X $ PAR->Attrib

#else

FUNCTION oNews() ; RETURN NIL

#endif DEF_WWW


FUNCTION aDelIfExist(a,uItem)
local i
for i := 1 to len(a)
  if a[i] == uItem
    adel(a,i)
    asize(a,len(a)-1)
    exit
  endif
next i
RETURN .t.

FUNCTION aRemove(a,blWhat)
local i
for i := 1 to len(a)
  if eval(blWhat,a[i])
    adel(a,i)
    asize(a,len(a)-1)
    exit
  endif
next i
RETURN .t.




FUNCTION aAddIfFirst(a, uItem)
local i
for i := 1 to len(a)
  RETURN .f. if a[i] == uItem
next i
aadd(a,uItem)
RETURN .t.

FUNCTION err_Circular(a,uItem)
local s := ""
local i
for i := 1 to len(a)
  if i > 1
    s += "."
  endif
  s += ltrim(a[i])
next i
RETURN Warning(s + " : circular reference!")




/*
  convert undefined to repr() (like in Python : repr() returns an expression
  which, if evaluated, will result to the original value).
  Works currently only for CHAR
*/
FUNCTION utor(u)
if valtype(u) == "C"
  RETURN '"' + strtran(u, chr(34) ,  '"+chr(34)+"'  ) + '"'
endif
RETURN utos(u)







FUNCTION IsLangue(cLangue)
RETURN .t. if LngLocate(cLangue) != NIL
* if cLangue == MemLang1 .or. cLangue == MemLang2 .or. cLangue == MemLang3
*   RETURN .T.
* endif
SetMsg(cLangue + " : code langue invalide (voir LNG.DBC) !")
RETURN .F.

// not used
FUNCTION TreeRoot(ad)
local cId := FIELD->Parent
open area ad
  seek FIELD->Parent
  do while ! eof() .and. !empty(FIELD->Parent)
    cId := FIELD->Parent
    seek FIELD->Parent
  enddo
close area
RETURN cId

FUNCTION LngSuffix(cIdLng)
default cIdLng to TplLang()
RETURN "" if cIdLng==MemLang1 .or. cIdLng=="*"
RETURN "_"+lng2iso(cIdLng)




#ifdef DEF_MTG

**
**
FUNCTION oMtg()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name MTG ;
       wait {|msk| MtgWait(msk)} ;
       postedit MtgPostEdit()
ddIndex b on  MTG->IdMtg
ddIndex b on  dtos(MTG->Date)+MTG->Time
** ddIndex b on  descend(dtos(MTG->Date)+MTG->Time,.t.) ;
**               format {|x|descend(x,.t.)}
ddIndex b on  dtos(MTG->Date)+MTG->Time
ddFld IdMtg   ,C, LenIdMsx(),0  when .f. ;
               postedit {|x|GetNum(x)} ;
               picture  "@k@!"
ddFld Date    ,D, 8,0
ddFld Time    ,C, 5,0 postedit {|x|GetQte(x,":")}
ddFld IdPar   ,C, LenIdPar(),0 postedit {|x|GetIdPar(x)} ;
               pick PickPar(NIL,MTG->IdPar)
ddFld IdPar2  ,C, LenIdPar(),0 postedit {|x|GetIdPar(x)} ;
               pick PickPar(NIL,MTG->IdPar2)
ddFld Title1  ,C,60,0
ddFld Title2  ,C,60,0
ddFld Title3  ,C,60,0
ddFld Abstract1 ,M, 10,0
ddFld Abstract2 ,M, 10,0
ddFld Abstract3 ,M, 10,0
* ddFld Memo1    ,M, 10,0
* ddFld Memo2    ,M, 10,0
* ddFld Memo3    ,M, 10,0
* ddFld URL1     ,C, 100,0
* ddFld URL2     ,C, 100,0
* ddFld URL3     ,C, 100,0
ddFld Body1    ,M, 10,0
ddFld Body2    ,M, 10,0
ddFld Body3    ,M, 10,0
ddFld Place    ,C,60,0
*ddFld IdMsx1 ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} ;
*              pick PickMsx(MTG->IdMsx1)
*ddFld IdMsx2 ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} ;
*              pick PickMsx(MTG->IdMsx2)
*ddFld IdMsx3 ,C, LenIdMsx(),0 postedit {|x|GetNum(x)} ;
*              pick PickMsx(MTG->IdMsx3)
ddEndDef()
RETURN b

FUNCTION MtgTitle
local c
if TplLang() == "D"
  c := dtocf(MTG->Date,"dddd, d. mmmm yyyy")
else
  c := dtocf(MTG->Date,"dddd d mmmm yyyy")
endif
* if empty(MTG->Title1)
  if !empty(MTG->Time)
    c += " "+tr("at","um","…","om","kell")+" "+trim(MTG->Time) ;
         + " "+ tr("","Uhr","heures","uur","")
  endif
  if !empty(MTG->Place)
    c += " "+tr("in","in","…","in","")+" "+trim(MTG->Place)
  endif
* else
*   c += ": " + LngExpr("MTG->Title")
* endif
RETURN c

FUNCTION MtgIsContainer()
RETURN .t.

FUNCTION MtgPostEdit
if !empty(MTG->IdPar)
  RETURN .f. if ! ParExist(MTG->IdPar)
endif
if !empty(MTG->IdPar2)
  RETURN .f. if ! ParExist(MTG->IdPar2)
endif
RETURN .t.


FUNCTION MtgWait(wwin)
*local b
*local cIdMtg := MTG->IdMtg
*if wwin[WIN_WAITKEY] == 2  // MsxMlm1Edit() : edit Links FROM this
*  b := oMtg()
*  open area b, oMsx(), oPub(), oAut(), oTpc(), oArt(), oPar()
*    edit data b key    MTG->Parent ;
*                value  cIdMtg ;
*                mode wait ;
*                window wwin ;
*                start top ;
*                query "MTGMTG"
*  close area
*endif
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"MTG",MTG->IdMtg)
#endif DEF_RFX
RETURN NIL

FUNCTION PickMtg(cStart,xuReturn)
default xuReturn to "MTG->IdMtg"
RETURN DbfPick(;
  {oMtg()},;
  NIL,;
  "MTGPICK",;
  cStart,;
  NIL,;
  NIL,NIL,;
  xuReturn;
)

FUNCTION MtgPage(cIdNew)
open area oMtg(), oPar()
  if cIdNew != NIL
    seek cIdNew
  endif
  edit data oMtg() full noskip query ("MTG") title (MtgTitle())
close area
RETURN MnuDone()




FUNCTION MtgRefToHtml(xcTitle)
local c
local cTitle
default xcTitle to "trim(MtgTitle())"
cTitle := DrvCvtString(xparse(xcTitle))
c := '<a href="'+getBasePath()
c += mtg_url() // MtgHtmTarget()
c += '">'
c += cTitle
c += '</a>'
RETURN c

FUNCTION MtgRefToStream(xcTitle)
RETURN toStream(MtgRefToHtml(xcTitle))

* FUNCTION MtgHtmTarget()
* RETURN "/meetings/"+alltrim(MTG->IdMtg)+lngsuffix()+HTMLEXT

FUNCTION MtgToHtml(cFormat)
if cFormat $ "br,ul,ol,para"
  *toStream("<b>")
  *toTxtStream(dtocf(MTG->Date,;
  *  tr("dddd, d. mmmm yyyy","dddd, d. mmmm yyyy","dddd, d mmmm yyyy"))+" ")
  ** toTxtStream(MTG->Time+" ")
  *toStream("</b> ")
  *if ! empty(MTG->Place)
  *  toTxtStream(tr(" in "," in ", " … ", " in "))
  *  toTxtStream(trim1(MTG->Place))
  *endif
  *toTxtStream(": ")
  MtgRefToStream()
  * toTxtStream(trim(MtgTitle()))
  if ! empty(MTG->Abstract1)
    toStream(" &mdash; ")
    toHtmStream(LngExpr("Abstract"),"MTG->Abstract "+ltrim(MTG->IdMtg))
  endif
  RETURN .t.
elseif cFormat $ "table"
  toStream('<tr><td valign="top">')
  *toTxtStream(dtocf(MTG->Date,;
  *  tr("dddd, d. mmmm yyyy","dddd, d. mmmm yyyy","dddd, d mmmm yyyy"))+" ")
  * toTxtStream(MTG->Time+" ")
  *toStream('</td><td valign="top">')
  *toTxtStream(trim1(MTG->Place))
  *toStream('</td><td valign="top">')
  MtgRefToStream()
  toStream('</td><td valign="top">')
  if !empty(MTG->Title1)
    MtgRefToStream('LngExpr("MTG->Title")')
    toStream('<br>')
  endif
  toHtmStream(LngExpr("Abstract"),"MTG->Abstract "+ltrim(MTG->IdMtg))
  toStream('</td></tr>')
  RETURN .t.
endif
RETURN !SetMsg(utos(cFormat) + " : invalid format")

FUNCTION ListMtgComing() // coming events
RETURN !SetMsg("Only for MSX") if alias()!="MSX"
RETURN DbfToHtml( ;
  MsxLabel(),trim(MsxTitle()),;
  {oMtg(),oPar(),oPlz(),oNat()},2,dtos(UserDate()),".t.",;
  ".t.","table",15)

FUNCTION ListMtgPast() // past events
RETURN !SetMsg("Only for MSX") if alias()!="MSX"
RETURN DbfToHtml( ;
  MsxLabel(),trim(MsxTitle()),;
  {oMtg(),oPar(),oPlz(),oNat()},2,dtos(UserDate()),".t.",;
  ".t.","table",15,.t.)

*FUNCTION ListMtgPast() // past events
*RETURN !SetMsg("Only for MSX") if alias()!="MSX"
*RETURN DbfToHtml( ;
*  MsxLabel(),trim(MsxTitle()),;
*  {oMtg(),oPar(),oPlz(),oNat()},3,descend(dtos(UserDate()),.t.),".t.",;
*  ".t.","table",15)



#else

FUNCTION oMtg() ; RETURN NIL

#endif DEF_MTG


FUNCTION parse_kw(cParams,a,bArgHandler)
* (c) Luc Saffre 2005-2008
local i
local nPos
local c
local cValue
local cBefore
local lOkay := .t.
RETURN .t. if empty(cParams)
default bArgHandler to {|x|!SetMsg("Unexpected argument '"+x+"'") }
for i := 1 to len(a)
  nPos := at(a[i][1]+"=",lower(cParams))
  if nPos != 0
    cBefore := left(cParams,nPos-1)
    cParams := substr(cParams,nPos+len(a[i][1]+"="))
    if left(cParams,1) == '"'
      cParams := substr(cParams,2)
      nPos := at('"',cParams)
      if nPos != 0
        cValue:= left(cParams,nPos-1)
        cParams := substr(cParams,nPos+1)
      else
        lOkay := .f.
        SetMsg("ParseError: "+cParams)
        cParams:=""
      endif
    else
      nPos := at(" ",cParams)
      if nPos != 0
        cValue := left(cParams,nPos-1)
        cParams := substr(cParams,nPos+1)
      else
        cValue := cParams
        cParams:=""
      endif
    endif
    if lOkay
      eval(a[i][2],cValue)
    endif
    cParams := cBefore + cParams
  endif
next i
RETURN .f. if ! lOkay
if !empty(cParams)
  RETURN eval(bArgHandler,cParams)
endif
RETURN .t.

* #ifdef DEF_LFN

* FUNCTION foto2html(cName,cParams,cTitle)

FUNCTION btn2html(cName,cParams,cTitle)
local s := '<img src="' + getBasePath()
s += '/images/buttons/'
s += cName + '" '
if ! "alt=" $ cParams
  s += +'alt="' + cName+'" '
endif
if ! "width=" $ cParams
  s += +'width="30" '
endif
s += cParams + '>'
RETURN s

FUNCTION logo2html(cName,cParams,cTitle)
local s := ''
s += '<img src="' + getBasePath()
s += '/images/logos/'
s += cName + '" '
if ! "alt=" $ cParams
  s += +'alt="' + cName+'" '
endif
if ! "width=" $ cParams
  s += +'width="100" '
endif
s += cParams + '>'
RETURN s



FUNCTION setBasePath(c)
* Warning("SetBasePath("+c+")")
scBasePath := trim(c)
RETURN .t.
FUNCTION getBasePath()
RETURN scBasePath

FUNCTION toHtmStream(cMemo,cSource,cRefMode)
local lOkay
* local cSaveRefMode := scRefMode
* if cRefMode != NIL
*   scRefMode := cRefMode
* endif
// lOkay := sparse(hardcr(cMemo),cSource,.f.)
lOkay := sparse(DrvCvtString(hardcr(cMemo)),cSource,.f.)
* scRefMode := cSaveRefMode
RETURN lOkay

* FUNCTION memo2html(cFilename)
* RETURN toHtmStream(memoread(GetDlmPath(cFilename)),cFilename)


* #endif DEF_LFN

#ifdef DEF_WWW
#ifdef DEF_PRJ

FUNCTION PrjTreeUpdate
RETURN DbfScan({oPrj()},5,NIL,NIL,NIL,{||PrjTreePos()})

FUNCTION PrjTreePos
local c := alltrim(PRJ->Seq)
RETURN !SetMsg(PRJ->IdPrj+":"+SetMsg()) if ! OnContainer(;
  {||empty(PRJ->Parent)},".t.",.f.,;
  {||c := alltrim(PRJ->Seq)+"."+c,.t.})
RETURN .f. if ! ddRecLock()
PRJ->TreePos:=c
unlock record
RETURN .t.
* open area oPrj()
*   do while ! empty(PRJ->Parent)
*     seek PRJ->Parent
*     c := alltrim(PRJ->Seq)+"."+c
*   enddo
* close area
* RETURN c

#endif DEF_PRJ
#endif DEF_WWW


FUNCTION ClearMailTo
saMailTo := {}
RETURN .t.

FUNCTION AddMailTo(cAddr,cName)
local i
RETURN .t. if empty(cAddr)
if !empty(cName)
  cAddr := '"'+trim(cName)+'" <'+trim(cAddr)+">"
endif
for i := 1 to len(saMailTo)
  RETURN .t. if trim(saMailTo[i]) == trim(cAddr)
next i
aadd(saMailTo,cAddr)
RETURN .t.

FUNCTION PickMailTo(cStart)
RETURN ArrayPick(saMailTo,"mail recipient:",cStart)
