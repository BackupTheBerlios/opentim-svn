** Copyright (c) 2002-2008 Luc Saffre
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

#ifdef DEF_LITERA

FUNCTION LenIdPbt() ; RETURN 3
FUNCTION LenIdAut() ; RETURN LenIdArt()

**
** PUB - Werke
**
FUNCTION oPub()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name PUB                                 ;
              wait {|w|PubWait(w)} ;
              create AutoIncCopy(b)
ddIndex b on  PUB->IdPub
ddIndex b on  upper(left(PUB->Title,120)) format {|x|upper(x)}
ddIndex b on  PUB->IdAut + PUB->Date                  // ORD_PUB_AUT
ddIndex b on  PUB->Parent + PUB->Seq                   // ORD_PUB_4
ddFld IdPub    ,C, LenIdArt(),0 when .f.
ddFld IdPar    ,C, LenIdPar(),0 pick PickPar(NIL,PUB->IdPar)
ddFld Parent    ,C, LenIdArt(),0 picture PIC_ID ;
                                postedit {|x|GetIdArt(x)} ;
                                pick DbfPick({oPub()},NIL,NIL,FIELD->Parent) ;
                                valid ph_refresh()
ddFld Seq      ,C, 3,0 postedit {|x|if(val(x)==0,x,GetNum(x))}
ddFld IdAut    ,C, LenIdAut(),0 picture PIC_ID ;
                                postedit {|x|GetIdArt(x)} ;
                                pick DbfPick({oAut()},"Autor",NIL,FIELD->IdAut) ;
                                valid ph_refresh()
ddFld IdPbt    ,C, LenIdPbt(),0 picture PIC_ID ;
               postedit {|x|GetNum(x)} ;
               pick DbfPick({oPbt()},NIL,NIL,FIELD->IdPbt) ;
               valid ph_refresh()
ddFld Title    ,C,250,0 picture "@S40"
ddFld SubTitle ,C,250,0 picture "@S40"
ddFld URL      ,C,250,0 picture "@S40"
ddFld IdLng    ,C, LenIdLng(),0 picture PIC_ID ;
               pick PickLng(FIELD->IdLng)
ddFld Param    ,C,40,0
ddFld Date     ,C, 8,0 picture PIC_ID
ddFld Abstract ,M,10,0
ddFld Body     ,M,10,0
ddFld _SuperTitle ,C,60,0 attrib V ;
      block padr(DbfPeek(oPub(),FIELD->Parent,"Title",""),60)
ddFld _AutName  ,C,60,0 attrib V ;
      block padr(DbfPeek(oAut(),FIELD->IdAut,;
                 "trim1(FIELD->Vorname)+trim(FIELD->Name)",""),60)
ddFld Super    ,C, LenIdArt(),0 // to save existing old data
ddEndDef()
RETURN b


FUNCTION PubWait(wwin)
local b
local cId := PUB->IdPub
if wwin[WIN_WAITKEY] == 2  // MsxMlm1Edit() : edit Links FROM this
  b := oPub()
  open area b
    edit data b key    PUB->Parent ;
                value  cId ;
                mode wait ;
                window wwin ;
                start top ;
                query "PUBPUB"
  close area
  RETURN NIL
endif
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"PUB",cId)
#endif DEF_RFX
RETURN NIL



**
** AUT - Auteurs
**
FUNCTION oAut()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name AUT ;
              wait {|w|AutWait(w)} ;
              create    AutoIncCopy(b)
ddIndex b on  AUT->IdAut                      // AUT_ORD_ID
ddIndex b on  upper(AUT->Name) format {|x|upper(x)}    // AUT_ORD_NAME
ddFld IdAut    ,C, LenIdAut(),0 when .f.
ddFld Name     ,C,25,0
ddFld Vorname  ,C,20,0
ddFld IdLng    ,C, LenIdLng(),0 picture PIC_ID pick PickLng(AUT->IdLng)
ddFld Born     ,C,10,0
ddFld Died     ,C,10,0
ddFld Abstract ,M,10,0
ddFld Body     ,M,10,0
ddFld URL      ,C,250,0 picture "@S40"
ddEndDef()
RETURN b


FUNCTION AutWait(wwin)
local b
local cId := AUT->IdAut
if wwin[WIN_WAITKEY] == 2  // MsxMlm1Edit() : edit Links FROM this
  b := oPub()
  open area b,oAut()
    edit data b key    PUB->IdAut ;
                value  cId ;
                mode wait ;
                window wwin ;
                start top ;
                query "PUBAUT"
  close area
  RETURN NIL
endif
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"AUT",cId)
#endif DEF_RFX
RETURN NIL




**
** PBT - publication types
**
FUNCTION oPbt()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name PBT ;
              create    AutoIncCopy(b)
ddIndex b on  PBT->IdPbt
ddIndex b on  upper(PBT->Name) format {|x|upper(x)}
ddFld IdPbt    ,C, LenIdPbt(),0 when .f.
ddFld Name     ,C,40,0
ddFld SeqName  ,C,40,0
ddEndDef()
RETURN b




**
** QUO - Quotations
**
FUNCTION oQuo()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name QUO                                 ;
              wait {|w|QuoWait(w)} ;
              create AutoIncCopy(b)
ddIndex b on  QUO->IdQuo
ddIndex b on  QUO->IdAut + QUO->Date  // ORD_QUO_AUT
ddIndex b on  QUO->IdPub + upper(QUO->Place) // ORD_QUO_PUB
ddIndex b on  upper(QUO->Ref)
ddFld IdQuo    ,C, LenIdArt(),0 when .f.
ddFld IdPub    ,C, LenIdArt(),0 picture PIC_ID ;
                                postedit {|x|GetIdArt(x)} ;
                                pick DbfPick({oPub()},NIL,NIL,FIELD->IdPub) ;
                                valid ph_refresh()
ddFld IdAut    ,C, LenIdAut(),0 picture PIC_ID ;
                                postedit {|x|GetIdArt(x)} ;
                                pick DbfPick({oAut()},NIL,NIL,FIELD->IdAut) ;
                                valid ph_refresh()
ddFld Date     ,C, 8,0 picture PIC_ID
ddFld IdLng    ,C, LenIdLng(),0 picture PIC_ID pick PickLng(QUO->IdLng)
ddFld Abstract ,M,10,0
ddFld Body     ,M,10,0
ddFld _PubTitle ,C,60,0 attrib V ;
      block padr(DbfPeek(oPub(),FIELD->IdPub,"PubTitle()",""),60)
ddFld _AutName  ,C,60,0 attrib V ;
      block padr(DbfPeek(oAut(),FIELD->IdAut,"AutName()",""),60)
ddFld URL      ,C,250,0 picture "@S40"
ddFld Place    ,C,20,0
ddFld Ref      ,C,20,0
ddEndDef()
RETURN b


FUNCTION QuoWait(wwin)
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"QUO",QUO->IdQuo)
#endif DEF_RFX
RETURN NIL


FUNCTION PubUpScan(xlEval,xlSep)
local cIdPub := PUB->Parent
local lOkay := .f.
open area oPub()
  lOkay := .t.
  do while lOkay.and.!empty(cIdPub)
    seek cIdPub
    if &(xlSep)
      if ! &(xlEval)
        lOkay := .f.
      endif
    else
      lOkay := .f.
    endif
    cIdPub := PUB->Parent
  enddo
close area
RETURN lOkay

FUNCTION PubDnScan(xlEval,xlSep)
local cIdPub := PUB->IdPub
local lOkay := .f.
open area oPub()
  lOkay := .t.
  ddSetOrder(ORD_PUB_4)
  do while lOkay .and. !eof() .and. PUB->Parent == cIdPub
    if eval(xlSep)
      if ! eval(xlEval)
        lOkay := .f.
      endif
    else
      lOkay := .f.
    endif
    skip
  enddo
close area
RETURN lOkay

#endif DEF_LITERA


FUNCTION AutoIncCopy(ad,cTitle)
local cExpr := ad[AD_AINDEX][1][AI_EXPR]
local cId
local cCopier := BUTTON_OFF
local aBuf := CopyRec()
default cTitle to "create "+ad[AD_NAME]
cId := DbfAutoInc(ad)
open window (cTitle) size 4,50
do while .t.
  WinHome()
  say "ID: "
  get cId picture PIC_ID ;
          postedit {|x|GetNum(x)}
  WinCr()
  get cCopier checkbox
  say MsgCopy()
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cId)
    SetMsg(cId + " : " + MsgIdExist() )
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
&cExpr := cId
dbcommit()
RETURN DDCREATE_FULL




FUNCTION crlf() ; RETURN CR_LF
