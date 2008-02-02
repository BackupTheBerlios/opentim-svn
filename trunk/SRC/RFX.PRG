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






// XRF : extended reference
// XRT : XRF table

#ifdef DEF_RFX

request descend

static saRfxTables
static saRfxAuto

// #define XT_ALIAS 1
#define XT_AD    1
#define XT_XNAME 2
#define XT_MEMOS 3 // list of memo fields
#define XT_PICK  4 //
#define XT_ALEN  4

#define ORD_RFX_1 1
#define ORD_RFX_2 2
#define ORD_RFX_3 3




// automatic references:
// #define RFXTYPE_A "A" // [ref   (sorted by date)
#define RFXTYPE_R "R" // [ref   (sorted by date)
#define RFXTYPE_X "X" // [xe    (sorted by date)

// manual references:
#define RFXTYPE_T "T" // Tree
// #define RFXTYPE_D "D" // Tree sorted by Date
// #define RFXTYPE_S "S" // Tree sorted by Sequence
#define RFXTYPE_L "L" // transLation








FUNCTION LenIdKwd() ; RETURN 5
// #define LEN_IDKWD 5
#define LEN_KWD 30
#define MIN_KWD_LEN 3


#define KWDTYPE_I "I" // ignore
#define KWDTYPE_S "S" // substitute silently
#define KWDTYPE_R "R" // refer to

**
** KWD - Keywords
**
**
FUNCTION oKwd()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name KWD
ddIndex b on  KWD->IdLng+upper(KWD->Word)
// ddIndex b on  KWD->IdLng+upper(KWD->Word)
ddFld Word   ,C, LEN_KWD,0
ddFld Type   ,C,1,0
ddFld Word2  ,C, LEN_KWD,0
ddFld IdLng  ,C,LenIdLng(),0
ddEndDef()
RETURN b

**
** KWI - Keyword instances
**
**
FUNCTION oKwi()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name KWI
ddIndex b on  KWI->IdRfx+KWI->IdKwd
ddIndex b on  KWI->IdKwd+KWI->Pos for !empty(KWI->Pos)
ddFld IdRfx  ,C, LEN_RFX,0
ddFld Pos    ,C, 4,0 postedit {|x|GetNum(x)}
ddFld IdKwd  ,C, LenIdKwd(),0
ddEndDef()
RETURN b




**
** RFX - References eXtended
**
**
FUNCTION oRfx()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name RFX ;
       create RfxCreate() ;
       postedit RfxPostEdit() ;
       preedit RfxPreEdit()
ddIndex b on  RFX->From+RFX->Type+RFX->To  // ORD_RFX_1
ddIndex b on  RFX->To+RFX->Type+RFX->From    // ORD_RFX_2
ddIndex b on  RFX->From+RFX->Type+RFX->Seq+RFX->Sort  // ORD_RFX_3
ddFld From    ,C, LEN_RFX,0 pick PickXrf(RFX->From)
ddFld To      ,C, LEN_RFX,0 pick PickXrf(RFX->To)
ddFld Sort    ,C, 30,0
ddFld Type   ,C, 1,0 picture  PIC_ID ;
                pick PickDbcCode("RFXTYPE.DBC",RFX->Type)
ddFld Attrib  ,C, 2,0 picture  PIC_ID ;
               pick PickDbcAttr("RFXATTR.DBC",RFX->Attrib)
ddFld Seq     ,C, 3,0 postedit {|x|if(val(x)==0,x,GetNum(x))}
action b key K_ENTER  prompt "Page [Enter]" block RfxPage()
ddEndDef()
RETURN b


FUNCTION RfxCreate()
local cFrom
local cTo
if indexord()==ORD_RFX_1 .or. indexord()==ORD_RFX_3
  cFrom := left(ddKeyValue(),LEN_RFX)
  cTo := PickXrf()
  RETURN DDCREATE_FAIL if cTo == NIL
elseif indexord()==ORD_RFX_2
  cTo := left(ddKeyValue(),LEN_RFX)
  cFrom := PickXrf()
  RETURN DDCREATE_FAIL if cFrom == NIL
else
  RETURN DDCREATE_FAIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
RFX->To:=cTo
RFX->From:=cFrom
RfxPostedit()
RETURN DDCREATE_EDIT

FUNCTION RfxPreEdit()
* RETURN .f. if RFX->Type == RFXTYPE_A
* RETURN .f. if RFX->Type == RFXTYPE_R
* RETURN .f. if RFX->Type == RFXTYPE_X
RETURN .t.

FUNCTION StdRfxType(cAlias)
RETURN RFXTYPE_T
* RETURN RFXTYPE_T if cAlias $ "MSX,AUT,QUO,PRJ"
* RETURN RFXTYPE_D

FUNCTION RfxPostEdit()
local xcSort
local cSortText
if empty(RFX->Type)
  RFX->Type := StdRfxType(left(RFX->To,3))
endif
* xcSort := if(left(RFX->To,3)$"MSX,AUT,QUO,PRJ",;
*   "upper(xt_title())","descend(xt_date(),.t.)")
xcSort := if(left(RFX->To,3)$"MSX,AUT,QUO,PRJ",;
  "upper(xt_title())","xt_date()")
* xcSort := if(RFX->Type==RFXTYPE_D,"descend(xt_date())","upper(xt_title())")
cSortText := XrfPeek(RFX->To,xcSort,NIL)
* RETURN .t. if RFX->Type == RFXTYPE_S
* if RFX->Type == RFXTYPE_R
*   cSortText := XrfPeek(RFX->From,"descend(xt_date())",NIL)
* elseif RFX->Type == RFXTYPE_X
*   cSortText := XrfPeek(RFX->From,"descend(xt_date())",NIL)
* elseif RFX->Type == RFXTYPE_D
*   cSortText := XrfPeek(RFX->To,"descend(xt_date())",NIL)
* elseif RFX->Type == RFXTYPE_T
*   cSortText := XrfPeek(RFX->To,"upper(xt_title())",NIL)
* elseif RFX->Type == RFXTYPE_L
*   cSortText := ""
* else
*   RETURN ! SetMsg("RFX("+alltrim(RFX->From)+"-"+alltrim(RFX->To);
*     +") : invalid type "+RFX->Type)
* endif
if cSortText == NIL
  RETURN ! SetMsg("RFX("+alltrim(RFX->From)+"-"+alltrim(RFX->To);
    +") : invalid reference target")
  * RETURN ! SetMsg("RFX("+alltrim(RFX->From)+"-"+alltrim(RFX->To);
  *   +") : no SortText")
endif
*if ! empty(cSortText)
*   RFX->Sort := padl(ntrim(recno()),20)
* else
  RFX->Sort := cSortText
* endif
RETURN .t.


*FUNCTION RfxSortText(cSort)
*if alias()=="MSX"
*  RETURN descend(dtos(MSX->Date)) if cSort == "D"
*  RETURN eupper(MsxTitle())
*elseif alias()=="TPC"
*  RETURN eupper(TpcName()) if cSort == "T"
*elseif alias()=="SRC"
*  RETURN SRC->Fileref
*elseif alias()=="ART"
*  RETURN eupper(ArtName()) if cSort == "T"
*elseif alias()=="NEW"
*  RETURN descend(dtos(NEW->Date))
*elseif alias()=="PUB"
*  RETURN eupper(PUB->Title)
*elseif alias()=="AUT"
*  RETURN eupper(trim(AUT->Name)+trim(AUT->Vorname))
*elseif alias()=="PAR"
*  RETURN eupper(trim(PAR->Firme)+trim(PAR->Vorname))
*elseif alias()=="VOC"
*  RETURN VocName()
*endif
*RETURN ""

FUNCTION RfxRefName()
RETURN "" if eof()
RETURN XrfPeek(if(indexord()==2,RFX->From,RFX->To),"XrfName()","")

FUNCTION xt_ListChildren(cFormat,cType,cTitle)
BeginList(cFormat,cTitle)
RfxScanChildren(cType,;
  {||BeginItem().and.XrfPeek(RFX->To,"RfxToHtml(ListFormat())").and.EndItem()})
RETURN EndList()


FUNCTION RfxScanChildren(cType,xlEval)
local cIdRfx := RfxIdRfx()
local xlFilter := "RFX->Type=='"+cType+"'";
  +iif(alias()$"PUB,TPC,PAR","",".and.alias()$'NEW MTG'");
  +".and.(alias()!='NEW'.or.empty(NEW->Status))"
if TplLang() != "*"
  xlFilter += ".and.(!alias()$'NEW MSX'.or.FIELD->IdLng=='"+TplLang()+"')"
endif
RETURN DbfScan({oRfx()},ORD_RFX_3,;
  cIdRfx,"RFX->From=='"+cIdRfx+"'",;
  {||XrfPeek(RFX->To,xlFilter,.f.)}, xlEval,NIL,NIL,.t.)

*FUNCTION RfxScanChildren(cType,xlEval,cAliases)
*local cIdRfx := RfxIdRfx()
*// local cType:="T"
*RETURN DbfScan({oRfx()},ORD_RFX_3,cIdRfx,"RFX->From=='"+cIdRfx+"'",;
*  "RFX->Type=='"+cType+"'";
*    +iif(TplLang()=="*","",".and.XrfLang(RFX->To)==TplLang()");
*    +iif(empty(cAliases),"",".and.left(RFX->To,3)$'"+cAliases+"'"),;
*  xlEval)

FUNCTION RfxScanParents(cType,xlEval)
local cIdRfx := RfxIdRfx()
// local cType:="T"
RETURN DbfScan({oRfx()},ORD_RFX_2,cIdRfx,"RFX->To=='"+cIdRfx+"'",;
  "RFX->Type=='"+cType+"'",xlEval)

// wird in MSX->Body benutzt
FUNCTION DbfListToHtml(cFormat,a,nOrder,cStart,xlWhile,xlFilter,;
                       nMaxCount,lDescend)
RETURN .f. if ! BeginList(cFormat)
RETURN .f. if ! DbfScan(a,nOrder,cStart,xlWhile,xlFilter,;
  "BeginItem().and.RfxToHtml(ListFormat()).and.EndItem()";
  +".and.RfxACollect()",nMaxCount,NIL,lDescend)
RETURN EndList()

FUNCTION RfxACollect(cFrom,cTo)
// RfxCollect(saRfxAuto,RfxIdRfx(),RFXTYPE_A)
RETURN .t.

*FUNCTION RfxCreateIf(cType,cFrom,cTo)
*local lOkay := .f.
*open area oRfx()
*  // ORD_RFX_1 : from+type+to
*  seek padr(cFrom,LEN_RFX) + cType + padr(cTo,LEN_RFX)
*  if eof()
*    // similar to RfxCreate()
*    if dbAddRec()
*      RFX->To:=cTo
*      RFX->From:=cFrom
*      RFX->Type := cType
*      RfxPostedit()
*      unlock record
*      lOkay := .t.
*    endif
*  else
*    lOkay := .t.
*  endif
*close area
*RETURN lOkay
  

*FUNCTION RfxChildren(cType)
*local cIdRfx := RfxIdRfx()
*local a := {}
*DbfScan({oRfx()},ORD_RFX_1,cIdRfx,"RFX->From=='"+cIdRfx+"'",;
*  "RFX->Type=='"+cType+"'",{||aadd(a,RFX->To),.t.})
*RETURN a
*
** FUNCTION axscan(a,blPrefix,blSep,blEval)
*FUNCTION axscan(a,xlEval)
*local i
*RETURN .t. if len(a) == 0
*// RETURN .f. if ! eval(blPrefix)
*for i := 1 to len(a)
*  * if i > 1
*  *   RETURN .f. if ! eval(blSep)
*  * endif
*  RETURN .f. if ! eval(xlEval,a[i],i)
*next i
*RETURN .t.

STATIC FUNCTION AddRfxTable(ad,xcTitle,cMemos,bPick)
local aMemos
if cMemos == NIL
  aMemos := {}
else
  aMemos := ListAsArray(cMemos,"+")
endif
aadd(saRfxTables,{ad,xcTitle,aMemos,bPick}) // XT_ALEN
RETURN .t.

FUNCTION RfxInit()
saRfxTables := {}
AddRfxTable(oPar(), "ParName()"  , "Memo", {|x|PickPar(NIL,x)})
#ifdef DEF_WWW
  AddRfxTable(oMsx(), "MsxTitle()" , "Abstract+Body" , ;
              {|x|PickMsx(x)}   )
  AddRfxTable(oTPC(), "TpcName()"  , "Memo1+Memo2+Memo3+Memo4", ;
               {|x|PickTpc(x)} )
  AddRfxTable(oNEW(), "NewTitle()" , "Abstract+Body",;
  {|x|DbfPick({oNew()},x)}   )
#endif
#ifdef DEF_ART
  AddRfxTable(oART(), "ArtName()"  , "Memo1+Memo2+Memo3+Memo4" )
#endif
#ifdef DEF_DLS
  AddRfxTable(oDLS(), "dtos(DLS->Date)+' '+trim(DLS->NB)" , "NB+Memo" )
#endif
#ifdef DEF_LITERA
  AddRfxTable(oPUB(), "PubTitle()" , "Abstract+Body",;
  {|x|DbfPick({oPub()},x)}   )
  AddRfxTable(oQUO(), "QuoTitle()" , "Abstract+Body",;
  {|x|DbfPick({oQuo()},x)}   )
  AddRfxTable(oAUT(), "AutName()"  , "Abstract+Body",;
  {|x|DbfPick({oAut()},x)}   )
#endif
#ifdef DEF_VOC
  AddRfxTable(oVOC(), "VocName()"  , NIL                 )
#endif
#ifdef DEF_PRJ
  AddRfxTable(oPRJ(), "PrjName()" , "Abstract", {|x|PickPrj(x)}     )
#endif
AddRfxTable(oSRC(), "SrcTitle()" , "Abstract", {|x|PickSrc(x)}     )
#ifdef DEF_MTG
  AddRfxTable(oMtg(), "MtgTitle()" , "Memo1+Memo2+Memo3", {|x|PickMtg(x)}     )
#endif
#ifdef DEF_PIN
  AddRfxTable(oPin(), "xt_title()" , "NB+Memo", {|x|PickPin(x)}     )
#endif
RETURN .t.


STATIC FUNCTION XrtLocate(cAlias)
local i
for i := 1 to len(saRfxTables)
  * if cAlias == saRfxTables[i][XT_ALIAS]
  if cAlias == saRfxTables[i][XT_AD][AD_NAME]
    RETURN saRfxTables[i]
  endif
next i
RETURN NIL


FUNCTION XtExist()
RETURN alias() + " is not registered as RFX table"

FUNCTION XrfLang(cRef)
RETURN XrfPeek(cRef,"FIELD->IdLng",TplLang()) if left(cRef,3)$"NEW MSX"
RETURN TplLang()

FUNCTION XrfName()
local xt := XrtLocate(alias())
if xt != NIL
  RETURN &(xt[XT_XNAME])
endif
raise(XtExist())
RETURN NIL

FUNCTION RfxStrtran(c1,c2)
local lOkay := .f.
local xt := XrtLocate(alias())
local i
RETURN ! SetMsg(XtExist()) if xt == NIL
for i := 1 to len(xt[XT_MEMOS])
  &(xt[XT_AD][AD_NAME]+"->"+xt[XT_MEMOS][i]) := strtran(;
    &(xt[XT_AD][AD_NAME]+"->"+xt[XT_MEMOS][i]), ;
    c1,c2)
next i
RETURN .t.

FUNCTION xt_loop(blEval)
local i
for i := 1 to len(saRfxTables)
  RptWrite("xt_loop : "+saRfxTables[i][XT_AD][AD_NAME])
  if ! eval(blEval,saRfxTables[i][XT_AD][AD_NAME])
    RptWrite("xt_loop : abort")
    RETURN .f.
  endif
next i
RETURN .t.

STATIC FUNCTION PickXrt(cStart)
local nStart := 1
local i
if !empty(cStart)
  for i := 1 to len(saRfxTables)
    if cStart == saRfxTables[i][XT_AD][AD_NAME]
      nStart := i
      exit
    endif
  next i
endif
browse array saRfxTables ;
       using {|xt|padr(xt[XT_AD][AD_NAME],30)} ;
       start nStart
RETURN NIL if lastchoice() == 0
RETURN saRfxTables[lastchoice()] // [XT_AD][AD_NAME]

FUNCTION PickXrf(cStart)
local aRef
local ad
local xrt
local cId
if ! empty(cStart)
  aRef := XrfSplit(cStart)
  if aRef != NIL
    xrt := aRef[1]
    cStart := aRef[2]
  endif
endif
if xrt == NIL
  xrt := PickXrt()
  cStart := NIL
endif
RETURN NIL if xrt ==  NIL
RETURN !SetMsg("No pick block for "+xrt[XT_AD][AD_NAME]) if xrt[XT_PICK] == NIL
cId := eval(xrt[XT_PICK],cStart)
RETURN NIL if cId ==  NIL
RETURN xrt[XT_AD][AD_NAME]+":"+alltrim(cId)

FUNCTION XrfExist(cIdXrf)
RETURN XrfPeek(cIdXrf,".t.",.f.)
* local a := XrfSplit(cIdXrf)
* RETURN .f. if a == NIL
* RETURN DbfPeek(a[1][XT_AD],a[2],".t.",.f.)


/**
  a[1] = { comp, lang, java, applications }
  a[2] = { comp, software, java }
**/
FUNCTION RfxUpPath(cMlmType)
local a := {}
local cIdRfx := RfxIdRfx()
open area oRfx()
  ddSetOrder(ORD_RFX_2)
  softseek cIdRfx + cMlmType
  do while ! eof() ;
     .and. RFX->Type == cMlmType ;
     .and. RFX->To == cIdRfx
    if !"H"$RFX->Attrib
      aadd(a, RfxUp2Path(RFX->From,cMlmType))
    endif
    skip
  enddo
close area
RETURN a

STATIC FUNCTION RfxUp2Path(cIdRfx,cMlmType)
local a := { cIdRfx }
local i
open area oRfx()
  ddSetOrder(ORD_RFX_2) // to+type
  softseek cIdRfx + cMlmType
  do while ! eof() ;
     .and. RFX->Type == cMlmType ;
     .and. RFX->To == cIdRfx
    cIdRfx := RFX->From
    if !"H"$RFX->Attrib
      if ! aAddIfFirst(a,cIdRfx)
        err_Circular(a,cIdRfx)
        exit
      endif
    endif
    softseek cIdRfx + cMlmType
  enddo
close area
RETURN a


FUNCTION XrtCanDelete
if HasRecords(oRfx(),ORD_RFX_2,"RFX->To",RfxIdRfx()) ;
  .or. HasRecords(oRfx(),ORD_RFX_1,"RFX->From",RfxIdRfx())
  RETURN !SetMsg("Cannot delete because other items refer to "+RfxIdRfx()+"!")
endif
RETURN .t.

FUNCTION XrtOnDelete
RETURN DbfDelete(NIL,NIL,{oRfx()},ORD_RFX_1,RfxIdRfx())


// RfxUpdate() calls RfxRefUpdate() and RfxKwdUpdate
FUNCTION RfxUpdate()
if alias() == "MSX"
  RETURN .f. if ! RfxRefUpdate({'Abstract','Body'})
  RETURN .f. if ! RfxKwdUpdate(MSX->IdLng,{'Title','Abstract'})
  // RETURN .f. if ! RfxKwdUpdate(MSX->IdLng,{'Title','Abstract','Body'})
elseif alias() == "TPC"
  RETURN .f. if ! RfxRefUpdate({'Memo1','Memo2','Memo3'})
  RETURN .f. if ! RfxKwdUpdate(MemLang1,{'Name1'})
elseif alias() == "SRC"
  RETURN .f. if ! RfxRefUpdate({'Abstract','Body'})
  RETURN .f. if ! RfxKwdUpdate(MemLang1,{'Name','Abstract'})
  // RETURN .f. if ! RfxKwdUpdate(MemLang1,{'Name1','Memo1'})
elseif alias() == "PRJ"
  RETURN .f. if ! RfxRefUpdate({'Abstract','Body'})
  RETURN .f. if ! RfxKwdUpdate(MemLang1,{'Name1'})
elseif alias() == "ART"
  RETURN .f. if ! RfxRefUpdate({'Memo1','Memo2','Memo3'})
  // RETURN .f. if ! RfxKwdUpdate(MemLang1,{'Memo1'})
elseif alias() == "NEW"
  RETURN .f. if ! RfxRefUpdate({'Abstract','Body'})
  RETURN .f. if ! RfxKwdUpdate(NEW->IdLng,{'Title','Abstract'})
  // RETURN .f. if ! RfxKwdUpdate(NEW->IdLng,{'Title','Abstract','Body'})
elseif alias() == "PUB"
  RETURN .f. if ! RfxRefUpdate({'Abstract','Body'})
  RETURN .f. if ! RfxKwdUpdate(PUB->IdLng,{'Title'})
  //RETURN .f. if ! RfxKwdUpdate(PUB->IdLng,{'Title','Abstract','Body'})
elseif alias() == "DLS"
  RETURN .f. if ! RfxRefUpdate({'Memo'})
  RETURN .f. if ! RfxKwdUpdate("D",{'NB',"Memo"})
elseif alias() == "PIN"
  RETURN .f. if ! RfxRefUpdate({'Memo'})
  RETURN .f. if ! RfxKwdUpdate("D",{'Short',"Memo"})
elseif alias() == "MTG"
  RETURN .f. if ! RfxRefUpdate({'Abstract1','Body1'})
elseif alias() == "AUT"
  RETURN .f. if ! RfxRefUpdate({'Abstract','Body'})
  // RETURN .f. if ! RfxKwdUpdate(MemLang1,{'Name'})
  // RETURN .f. if ! RfxKwdUpdate(MemLang1,{'Name','Abstract','Body'})
elseif alias() == "QUO"
  RETURN .f. if ! RfxRefUpdate({'Abstract','Body'})
  // RETURN .f. if ! RfxKwdUpdate(QUO->IdLng,{'Abstract','Body'})
else
  RETURN !SetMsg(alias()+": RfxUpdate() not defined!")
endif
RETURN .t.

*FUNCTION MsxRfxUpdate()
*local a := MemoRefs(MSX->Abstract+CR_LF+MSX->Body)
*RETURN RfxUpdate("MSX:"+alltrim(MSX->IdMsx),a)
*
*FUNCTION ArtRfxUpdate()
*local a := MemoRefs(ART->Memo1+CR_LF+ART->Memo2+CR_LF+ART->Memo3)
*RETURN RfxUpdate("ART:"+alltrim(ART->IdArt),a)
*
*FUNCTION NewRfxUpdate()
*local a := MemoRefs(NEW->Abstract+CR_LF+NEW->Body)
*RETURN RfxUpdate("NEW:"+alltrim(NEW->IdNew),a)

#define RFX_REF  1
#define RFX_TYPE 2
#define RFX_ALEN 2

FUNCTION RfxIdRfx()
RETURN padr(alias()+":#"+ntrim(recno()),LEN_RFX) if alias()=="KWI"
RETURN padr(alias()+":"+alltrim(&("FIELD->id"+alias())),LEN_RFX)

STATIC FUNCTION RfxRefUpdate(aFields) // rfxkwdupdate
local aCreate := {}
local lFound
local i
* local aCreate
local lOkay := .f.
local cFrom := RfxIdRfx()
local c
for i := 1 to len(aFields)
  c := &(aFields[i])
  AddMemoRefs(aCreate,c,"[ref",RFXTYPE_R)
  AddMemoRefs(aCreate,c,"[xe",RFXTYPE_R)
  AddMemoRefs(aCreate,c,"[item",RFXTYPE_R)
  * AddMemoRefs(a,c,"[xe",RFXTYPE_X)
next i
* aCreate := aclone(a)
open area oRfx()
  ddSetOrder(ORD_RFX_2) // to+type+from
  * ddSetOrder ORD_RFX_1
  lOkay := .t.
  softseek cFrom
  do while lOkay .and. ! eof() .and. RFX->To == cFrom
  * do while lOkay .and. ! eof() .and. RFX->From == cFrom
    if RFX->Type == RFXTYPE_R .or. RFX->Type == RFXTYPE_X
      lFound := .f.
      for i := 1 to len(aCreate)
        if aCreate[i][RFX_REF] == trim(RFX->From) ;
           .and. aCreate[i][RFX_TYPE] == trim(RFX->Type)
          lFound := .t.
          aRemove(aCreate,{|i|;
            i[RFX_REF] == trim(RFX->From);
            .and.i[RFX_TYPE] == trim(RFX->Type);
          })
          // UPDATE existing record from array item
          if ddRecLock()
            if ! RfxPostEdit()
              lOkay := .f.
            endif
            unlock record
          endif
          exit
        endif
      next i
      if !lFound
        // DELETE existing record because not found
        if ddRecLock()
          delete
          unlock record
        else
          lOkay := .f.
        endif
      endif
    endif
    skip
  enddo
  if lOkay
    for i := 1 to len(aCreate)
      if dbAddRec()
        RFX->To   := cFrom
        RFX->From := aCreate[i][RFX_REF]
        RFX->Type := aCreate[i][RFX_TYPE]
        if ! RfxPostEdit()
          lOkay := .f.
        endif
        unlock record
      else
        lOkay := .f.
        exit
      endif
    next i
  endif
close area
RETURN lOkay

FUNCTION XrfSplit(cRef)
local xrt
RETURN NIL if empty(cRef)
xrt := XrtLocate(left(cRef,3))
RETURN NIL if xrt == NIL
RETURN { xrt, padl(alltrim(substr(cRef,5)),6) }

FUNCTION RfxPage()
local cRef := if(indexord()==2,RFX->From,RFX->To)
local aRef := XrfSplit(cRef)
RETURN MsxPage(aRef[2]) if aRef[1][XT_AD][AD_NAME] == "MSX"
RETURN ArtPage(aRef[2]) if aRef[1][XT_AD][AD_NAME] == "ART"
RETURN ParPage(aRef[2]) if aRef[1][XT_AD][AD_NAME] == "PAR"
RETURN NewPage(aRef[2]) if aRef[1][XT_AD][AD_NAME] == "NEW"
RETURN PrjPage(aRef[2]) if aRef[1][XT_AD][AD_NAME] == "PRJ"
RETURN TpcPage(aRef[2]) if aRef[1][XT_AD][AD_NAME] == "TPC"
RETURN SrcPage(aRef[2]) if aRef[1][XT_AD][AD_NAME] == "SRC"
#ifdef DEF_MTG
RETURN MtgPage(aRef[2]) if aRef[1][XT_AD][AD_NAME] == "MTG"
#endif
RETURN !SetMsg(cRef+": RfxPage() failed ("+utos(aRef)+")")

* FUNCTION RfxExist(cFrom,cTo)
* local lExist := .f.
* open area oRfx()
*   // ORD_RFX_1
*   seek padr(cFrom,LEN_RFX) + padr(cTo,LEN_RFX)
*   lExist := ! eof()
* close area
* RETURN lExist


FUNCTION XrfPeek(cRef,xuReturn,uReturn)
local aRef := XrfSplit(cRef)
RETURN uReturn if aRef == NIL
RETURN DbfPeek(aRef[1][XT_AD],aRef[2],xuReturn,uReturn)

FUNCTION RfxEditFrom(cRef,cTitle)
default cRef to alias()+":"+alltrim(&("FIELD->id"+alias()))
default cTitle to cRef
cRef := padr(cRef,LEN_RFX)
RETURN DbfEdit({;
  oRfx(),oMsx(),oArt(),oVoc(),oPar(),oNew(),;
  oAut(),oQuo(),oPub(),oTpc(),oSrc();
},"RXF from "+cTitle,"RFXFROM",NIL,".t.",cRef,"RFX->From")

FUNCTION RfxEditTo(cRef,cTitle)
default cRef to alias()+":"+alltrim(&("FIELD->id"+alias()))
default cTitle to cRef
cRef := padr(cRef,LEN_RFX)
RETURN DbfEdit({;
  oRfx(),oMsx(),oArt(),oVoc(),oPar(),oNew(),;
  oAut(),oQuo(),oPub(),oTpc(),oSrc();
},"RFX to "+cTitle,"RFXTO",NIL,".t.",cRef,"RFX->To")


STATIC FUNCTION AddMemoRefs(a,c,cTag,cType,aKwd) // ,cPrefix)
local cRfxTo
local nPos
local nPos2
do while (nPos := at(cTag,c)) != 0
  c := substr(c,nPos+len(cTag))
  if left(c,1) == " " .or. left(c,1) == chr(141)
    c := substr(c,2)
  elseif left(c,2) == CR_LF
    c := substr(c,3)
  else
    Warning('(debug) AddMemoRefs() : "'+left(c,10)+'"')
    loop
  endif
  nPos2 := at("]",c)
  if nPos2 == 0
    exit
  endif
  cRfxTo := left(c,nPos2-1)
  // c := substr(c,nPos+1)
  * so, jetzt haben wir ihn
  cRfxTo := strtran(cRfxTo,CR_LF," ")
  cRfxTo := strtran(cRfxTo,chr(141)," ")
  nPos := at(" ",cRfxTo)
  if nPos > 0
    cRfxTo := upper(left(cRfxTo,nPos-1))
    RfxCollect(a,cRfxTo,cType)
  else
    RfxCollect(a,cRfxTo,cType)
  endif
enddo
RETURN NIL

FUNCTION RfxCollect(a,cRef,cType)
local i
for i := 1 to len(a)
  if a[i][RFX_TYPE] == cType .and. a[i][RFX_REF] == cRef
    RETURN .f.
  endif
next i
aadd(a,{cRef,cType}) // RFX_ALEN
RETURN .t.

FUNCTION RfxListToStream(cTo,cPrefix,cPostfix,xlFilter)
local nCount := 0
default xlFilter to ".t." // RFX->Type=='X'",;
RETURN .f. if ! DbfScan(;
  {oRfx(),oArt(),oMsx(),oVoc(),oPar(),oNew(),oPub(),oAut(),oQuo()},;
  ORD_RFX_3,;
  padr(cTo,10),;
  NIL,;
  xlFilter,;
  {|| toStream(cPrefix),;
      cPrefix := ", ",;
      nCount+= 1,;
      RfxRefToStream(RFX->From,NIL,"R");
  }, NIL)
if nCount !=0
  toStream(cPostfix)
endif
RETURN .t.

FUNCTION RfxList2ToStream(cTo,cPrefix,cPostfix,xlFilter)
local nCount := 0
default xlFilter to ".t." // RFX->Type=='X'",;
RETURN .f. if ! DbfScan(;
  {oRfx(),oArt(),oMsx(),oVoc(),oPar(),oNew(),oPub(),oAut(),oQuo()},;
  ORD_RFX_2,;
  padr(cTo,10),;
  NIL,;
  xlFilter,;
  {|| toStream(cPrefix),;
      cPrefix := ", ",;
      nCount+= 1,;
      RfxRefToStream(RFX->From,NIL,"R");
  }, NIL)
if nCount !=0
  toStream(cPostfix)
endif
RETURN .t.


FUNCTION DoRfxWait(wwin,cAlias,cId)
local b
if wwin[WIN_WAITKEY] == 61  // RefEditFrom
  b := oRfx()
  open area b, oMsx(), oArt(), oPar(), oVoc(), oPub(), oDls(), oPin()
    edit data b key    RFX->From ;
                value  padr(cAlias+":"+alltrim(cId),LEN_RFX) ;
                mode wait ;
                headers .f. ;
                window wwin ;
                start top ;
                query "RFXFROM"
  close area
  RETURN .t.
elseif wwin[WIN_WAITKEY] == 60  // RefEditTo
  b := oRfx()
  open area b, oMsx(), oArt(), oPar(), oVoc(),oPub(), oDls(), oPin()
    edit data b key    RFX->To ;
                value  padr(cAlias+":"+alltrim(cId),LEN_RFX) ;
                headers .f. ;
                mode wait ;
                window wwin ;
                start top ;
                query "RFXTO"
  close area
  RETURN .t.
endif
RETURN .f.


FUNCTION HtmlMake(lUnusedBabel)
local c := alias()+"IsContainer()"
local lOkay
if ! &c
  RETURN !Warning("This item has no own HTML page")
endif
RETURN .f. if ! DlgExec('WWW')
lOkay := Rfx2Html()
DrvLoad() // sonst werden Sonderzeichen in EinfÅgetexten,
          // z.B. [ref ...], im Rest der Sitzung ebenfalls ersetzt
RETURN .f. if ! lOkay
RETURN .t. if ! Confirm("Open file "+getvar("Outfile")+"? (Y/N)")
RETURN OpenUrl("file://"+getvar("Outfile"))
* RETURN AppShell('start '+getvar("Outfile"),NIL,NIL,.t.)

FUNCTION Rfx2Html
* saRfxAuto := {}
RETURN ActExec(alias()+'2HTM')
* RETURN .f. if ! ActExec(alias()+'2HTM')
* RETURN RfxAutoMake(RfxIdRfx(),saRfxAuto)


*FUNCTION RfxAutoMake(cFrom,aCreate)
*// algorithm copied from RfxRefUpdate(), but..
*local lFound
*local i
*local lOkay := .f.
*local c
*open area oRfx()
*  ddSetOrder ORD_RFX_1 // from+type+to
*  lOkay := .t.
*  softseek cFrom
*  do while lOkay .and. ! eof() .and. RFX->From == cFrom
*    if RFX->Type == RFXTYPE_A
*      lFound := .f.
*      for i := 1 to len(aCreate)
*        if aCreate[i][RFX_REF] == trim(RFX->To) ;
*           .and. aCreate[i][RFX_TYPE] == trim(RFX->Type)
*          lFound := .t.
*          aRemove(aCreate,{|i|;
*            i[RFX_REF] == trim(RFX->To);
*            .and.i[RFX_TYPE] == trim(RFX->Type);
*          })
*          // UPDATE existing record from array item
*          if ddRecLock()
*            if ! RfxPostEdit()
*              lOkay := .f.
*            endif
*            unlock record
*          endif
*          exit
*        endif
*      next i
*      if !lFound
*        // DELETE existing record because not found
*        if ddRecLock()
*          delete
*          unlock record
*        else
*          lOkay := .f.
*        endif
*      endif
*    endif
*    skip
*  enddo
*  if lOkay
*    for i := 1 to len(aCreate)
*      if dbAddRec()
*        RFX->From := cFrom
*        RFX->To   := aCreate[i][RFX_REF]
*        RFX->Type := aCreate[i][RFX_TYPE]
*        if ! RfxPostEdit()
*          lOkay := .f.
*        endif
*        unlock record
*      else
*        lOkay := .f.
*        exit
*      endif
*    next i
*  endif
*close area
*RETURN lOkay


FUNCTION RfxRefToStream(cRef,cTitle,cUnusedType)
local lOkay := .t.
local aRef := XrfSplit(cRef)
local xcTitle
local xuReturn
* local cSaveRefMode := scRefMode
RETURN .f. if aRef == NIL
if cTitle != NIL
  RETURN .t. if cTitle == "" // [MSX:123] = invisible reference to MSX:123
  RETURN .t. if left(cTitle,1) == "*" // [TPC:123] = invisible reference to MSX:123
  if !empty(cTitle)
    * 20021127 xcTitle := MemoToSql(cTitle)
    * 20030514 xcTitle := utor(notags(cTitle))
    xcTitle := utor(cTitle)
  endif
endif
* if cType == "X"        // [xe bla]
*  scRefMode := "0"
* else                   // [ref bla]
*   scRefMode := "2"
* endif
if aRef[1][XT_AD][AD_NAME] == "MSX"
  xuReturn := {||MsxRefToStream(xcTitle)}
elseif aRef[1][XT_AD][AD_NAME] == "ART"
  xuReturn := {||ArtRefToStream(xcTitle)}
elseif aRef[1][XT_AD][AD_NAME] == "TPC"
  xuReturn := {||TpcRefToStream(xcTitle)}
elseif aRef[1][XT_AD][AD_NAME] == "PAR"
  xuReturn := {||ParRefToStream(xcTitle)}
elseif aRef[1][XT_AD][AD_NAME] == "PRJ"
  xuReturn := {||PrjRefToStream(xcTitle)}
elseif aRef[1][XT_AD][AD_NAME] == "SRC"
  xuReturn := {||SrcRefToStream(xcTitle)}
elseif aRef[1][XT_AD][AD_NAME] == "NEW"
  xuReturn := {||NewRefToStream(xcTitle)}
#ifdef DEF_VOC
elseif aRef[1][XT_AD][AD_NAME] == "VOC"
  xuReturn := {||VocRefToStream(xcTitle)}
#endif DEF_VOC
#ifdef DEF_MTG
elseif aRef[1][XT_AD][AD_NAME] == "MTG"
  xuReturn := {||MtgRefToStream(xcTitle)}
#endif DEF_MTG
#ifdef DEF_LITERA
elseif aRef[1][XT_AD][AD_NAME] == "AUT"
  xuReturn := {||AutRefToStream(xcTitle)}
elseif aRef[1][XT_AD][AD_NAME] == "PUB"
  xuReturn := {||PubRefToStream(xcTitle)}
#endif DEF_LITERA
elseif aRef[1][XT_AD][AD_NAME] == "QUO"
  xuReturn := {||QuoRefToStream(xcTitle)}
else
  SetMsg(aRef[1][XT_AD][AD_NAME]+" : don't know how to do")
  lOkay := .f.
  *default cTitle to ""
  *RETURN toStream(cRef+ " " + DrvCvtString(cTitle))
endif
if lOkay
  lOkay := DbfPeek(aRef[1][XT_AD],aRef[2],xuReturn,.f.)
endif
* scRefMode := cSaveRefMode
RETURN lOkay







STATIC FUNCTION RfxKwdUpdate(cIdLng,aFields)
local a
local i := 1
local lOkay := .f.
local cPos
local aKwd := {}
// local cIdRfx := padr(alias()+":"+alltrim(&("FIELD->id"+alias())),LEN_RFX)
local cIdRfx := RfxIdRfx()
for i := 1 to len(aFields)
  KwdParse(cIdLng,aKwd,&(aFields[i]))
next i
// default xcKeywords to "trim(MsxTitle())"
// a := Memo2Words(&cText)
// a := Memo2Words(&xcKeywords)
open area oKwi()
  lOkay := .t.
  ddSetOrder(1)
  softseek cIdRfx // MSX->IdMsx
  do while ! eof() .and. KWI->IdRfx == cIdRfx // MSX->IdMsx
    if ddRecLock()
      KWI->Pos := ""
      unlock record
    endif
    skip
  enddo
  for i := 1 to len(aKwd)
    seek cIdRfx+aKwd[i]
    // seek cIdRfx+padr(aKwd[i],LEN_KWD)
    cPos := str(i,4,0)
    if eof()
      if dbAddRec()
        KWI->IdKwd := aKwd[i]
        KWI->Pos := cPos
        KWI->IdRfx := cIdRfx
        unlock record
      else
        lOkay := .f.
        exit
      endif
    elseif KWI->Pos < cPos
      if ddRecLock()
        KWI->Pos := cPos
        unlock record
      endif
    endif
  next i
close area
RETURN lOkay

STATIC FUNCTION KwdCollect(cIdLng,aKwd,cWord)
local nRecNo := NIL
// cWord := eupper(cWord)
RETURN .t. if len(cWord) <= MIN_KWD_LEN
open area oKwd()
  seek cIdLng+padr(upper(cWord),LEN_KWD)
  if eof()
    if dbAddRec()
      KWD->IdLng := cIdLng
      KWD->Word := cWord
      nRecNo := recno()
      unlock record
    else
      raise("dbAddRec() failed")
    endif
  elseif KWD->Type == KWDTYPE_S
    seek cIdLng+upper(KWD->Word2)
    nRecNo := recno()
  elseif KWD->Type != KWDTYPE_I
    nRecNo := recno()
  endif
close area
RETURN .t. if nRecNo == NIL
aadd(aKwd,str(nRecNo,LenIdKwd(),0))
RETURN .t.

STATIC FUNCTION KwdParse(cIdLng,aKwd,c)
local a := {}
local i := 1
local cWord
local cDelim := "`ÔÆØ .;,/:ç<>#()!?⁄ƒø≥¿Ÿ…Õª∫»º0123456789ˇ[]_&=+*'|{}" + '"'
c := strtran(c,CR_LF," ")
c := strtran(c,chr(9)," ")
c := strtran(c,chr(10)," ")  // importiert aus linux...
c := strtran(c,"~")
do while i <= len(c)
  if substr(c,i,1) $ cDelim
    cWord := left(c,i-1)
    c := substr(c,i+1)
    KwdCollect(cIdLng,aKwd,cWord)
    i := 1
  else
    ++i
  endif
enddo
KwdCollect(cIdLng,aKwd,c)
* if i > MIN_KWD_LEN
*   aadd(aKwd,c)
* endif
RETURN a

* FUNCTION Memo2Words(c,cDelim)
* local a := {}
* local i := 1
* local cWord
* default cDelim to " .;,/:ç<>#()!?⁄ƒø≥¿Ÿ…Õª∫»º0123456789ˇ[]_&=+*'|{}" + '"'
* c := strtran(c,CR_LF," ")
* c := strtran(c,chr(9)," ")
* c := strtran(c,chr(10)," ")  // importiert aus linux...
* c := strtran(c,"~")
* do while i <= len(c)
*   if substr(c,i,1) $ cDelim
*     cWord := left(c,i-1)
*     c := substr(c,i+1)
*     if len(cWord) >= MIN_KWD_LEN
*       aadd(a,cWord)
*     endif
*     i := 1
*   else
*     ++i
*   endif
* enddo
* if i > MIN_KWD_LEN
*   aadd(a,c)
* endif
* RETURN a

FUNCTION HasRfx() ; RETURN .t.

#else

FUNCTION oRfx() ; RETURN NIL
FUNCTION HasRfx() ; RETURN .f.

#endif DEF_RFX

