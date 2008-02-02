** ALS.PRG : DEF_ALS : Artikellisten

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

#ifdef DEF_ALS


#define MSG041 " geh”rt zu :"
#define MSG042 " : Artikel pro Liste"


**
** ALS - Listes d'articles
**
FUNCTION oAls()
static b
if b != NIL ; RETURN b ; endif
define data b name ALS ;
       preDelete AlsPreDelete() ;
       preedit AlsPreEdit() ;
       editprint TptDlgPrint(TPLTYPE_ALS,NIL,"Liste drucken mit Maske...") ;
       wait {|x| AlsWait(x)}
ddIndex b on  ALS->IdAls
ddFld IdAls   ,C, LenIdAls(),0 picture PIC_ID
ddFld Name    ,C,50,0
ddFld Attrib  ,C, 3,0 picture PIC_ID ;
              pick PickDbcAttr("ALSATTR.DBC",ALS->Attrib)
ddFld Memo    ,M,10,0
ddFld ArtFilter ,C,50,0
action b key K_F12   prompt MnuMemoEdit() block AlsMemoEdit()
action b key K_ENTER prompt MnuInhalt() block AlsAlmEdit()
* #ifdef DEF_TOOLBOX
*   action b key K_ALT_F2 prompt MsgMnuRename() ;
*                         block AlsRename() ;
*                         when recno() != lastrec() + 1
* #endif
* #ifdef DEF_ACT
*   if IsCustData("ALS") ; ActExec("ALS") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

**
** ALM - Article List Memberships
**
FUNCTION oAlm()
static b
if b != NIL ; RETURN b ; endif
define data b name ALM ;
            preedit AlmPreEdit()
ddIndex b on ALM->IdAls+ALM->IdArt         // ORD_ALM_ALS
ddIndex b on ALM->IdArt+ALM->IdAls         // ORD_ALM_ART
ddFld IdAls    ,C, LenIdAls(),0 picture PIC_ID ;
                   pick PickAls(ALM->IdAls)
ddFld IdArt    ,C, LenIdArt(),0 picture PIC_ID ;
                   pick PickArt(ALM->IdArt) ;
                   postedit {|x|GetIdArt(x,ALS->IdPrt)}
* ddFld Pos      ,C, 4,0 GET_NUM
ddFld Attrib   ,C, 3,0 picture PIC_ID
action b key K_SH_F4 prompt MnuArtPage() ;
                     block ArtPage(ALM->IdArt)
action b key K_ENTER block ArtPage(ALM->IdArt) ;
                     when indexord() == ORD_ALM_ALS
ddEndDef()
RETURN b

FUNCTION AlmPreEdit
RETURN .t. if ! AlsExist(ALM->IdAls)
RETURN AlsPreEdit()

FUNCTION AlsPreEdit
if ALSATTR_R $ ALS->Attrib
  SetMsg(trim(ALS->IdAls) + " : Artikelliste ist schreibgeschtzt !")
  RETURN .f.
endif
RETURN .t.

FUNCTION AlsName(cId)
if cId != NIL
  if ALS->IdAls != cId
    seek cId in ALS
  endif
endif
RETURN ALS->Name


**
** AlsEdit()
**
FUNCTION AlsEdit(cTitle)
local b := oAls()
default cTitle to "Artikellisten"
open area b, oArt(), oPlz()
  edit data b ;
            start top ;
            query "ALS" ;
            create {||RecCreate()} ;
            mode find ;
            title (cTitle)
close area
RETURN .f.


**
** AlsAlmEdit()
**
FUNCTION AlsAlmEdit()
local b := oAlm()
local cIdAls := ALS->IdAls
open area b, oArt(), oAls()
  ddSetOrder(ORD_ALM_ALS)
  edit data b key ALM->IdAls ;
              value cIdAls ;
              create {||AlmCreate(cIdAls)} ;
              mode find ;
              start top ;
              query "ALMALS" ;
              title (trim(ALS->Name) + MSG042)
close area
RETURN .f.


**
** ArtAlmEdit()
**
FUNCTION ArtAlmEdit(cIdArt,cTitle)
local b := oAlm()
default cTitle to (trim(ArtName()) + MSG041)
open area b, oArt(), oAls()
  ddSetOrder(ORD_ALM_ART)
  edit data b key ALM->IdArt ;
              value cIdArt ;
              create {||AlmCreate(NIL,cIdArt)} ;
              mode edit ;
              start top ;
              query "ALMART" ;
              title (cTitle)
close area
RETURN .f.


**
** AlmCreate()
**
FUNCTION AlmCreate(cIdAls,cIdArt)
* local cNewSeq := ALM->Pos
local nRecNo
local nRecNo2
local cIdPli
if cIdAls == NIL
  cIdAls := PickAls(ALM->IdAls)
  RETURN DDCREATE_FAIL if cIdAls == NIL
endif
RETURN DDCREATE_FAIL if ! AlsExist(cIdAls)
RETURN DDCREATE_FAIL if ! AlsPreEdit()
if cIdArt == NIL
  cIdArt := PickArt(ALM->IdArt)
  RETURN DDCREATE_FAIL if cIdArt == NIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
ALM->IdArt := cIdArt
ALM->IdAls := cIdAls
RETURN DDCREATE_REFRESH


*FUNCTION ArtAlmCollect(cIdAls,xlArtFilter,nArtOrder,cStart,xlWhile)
*local lOkay := .t.
*local nCount := 0
*local nAdded := 0
*local lFound
*default nArtOrder to 1
*default cStart to ""
*default xlWhile to ".t."
*RETURN .f. if cIdAls == NIL
*open area oArt(), oNat(), oPlz(), oAlm()
*  ddSetOrder (nArtOrder)
*  softseek cStart
*  do while lOkay .and. ! eof() .and. &xlWhile
*    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    if &xlArtFilter
*      lFound := .f.
*      select ALM
*      ddSetOrder ORD_ALM_ART
*      softseek ART->IdArt
*      do while !eof() .and. ALM->IdArt == ART->IdArt
*        if ALM->IdAls == cIdAls
*          lFound := .t.
*          exit
*        endif
*        skip
*      enddo
*      ddSetOrder ORD_ALM_ALS
*      if ! lFound
*        if AlmCreate(cIdAls,ART->IdArt) == DDCREATE_FAIL
*          lOkay := .f.
*        else
*          nAdded ++
*        endif
*      endif
*      select ART
*    endif
*    skip
*  enddo
*close area
*SetMsg(ntrim(nAdded) + " Adressen hinzugefgt zur Liste " + cIdAls)
*RETURN lOkay

FUNCTION ArtIsMember(cIdAls)
local cIdArt := ART->IdArt
local lIsMember := .f.
open area oAlm()
  ddSetOrder(ORD_ALM_ART)
  softseek cIdArt + cIdAls
  if ! eof() .and. ALM->IdArt == cIdArt
    if left(ALM->IdAls,len(cIdAls)) == cIdAls
      lIsMember := .t.
    endif
  endif
close area
RETURN lIsMember

**
**
**
FUNCTION AlsPreDelete()
local lOkay := .f. // nReturn := DDDEL_FAIL
RETURN .f. if ! Confirm( ;
  trim(ALS->IdAls) + " : Artikelliste l”schen (J/N) ?" ;
)
if ! Confirm( ;
  trim(ALS->IdAls) + ;
  " : alle Mitgliedeintragungen ebenfalls l”schen (J/N) ?" ;
)
  RETURN Confirm("Record trotzdem l”schen ?",MsgSure())
endif
open area oAlm()
  lOkay := .t.
  softseek ALS->IdAls
  do while ! eof() .and. ALM->IdAls == ALS->IdAls
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
RETURN lOkay

**
** PickAls()
**
FUNCTION PickAls( cStart, cTitle, xlFilter )
local cId := NIL
local b := oAls()
default cTitle to "Artikelliste ausw„hlen"
open area b
  * seek cIdArt in ART
  if cStart != NIL
    softseek trim(cStart)
  endif
  edit data b mode pick query "ALSPICK" title (cTitle) ;
              filter (xlFilter)
  if ddLastReq() == DDEDIT_SELECT
    cId := ALS->IdAls
  endif
close area
RETURN cId

**
** AlsMemoEdit()
**
FUNCTION AlsMemoEdit()
return MnuDone() if ! ddRecLock()
open window size 20,80
TxtEdit( ;
  fieldblock("Memo"), WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
  ddOnPreEdit(oAls()), 76 ;
)
close window
unlock record
ddRefreshCurrent()
RETURN .f.


FUNCTION AlsWait(wwin)
local b
local cIdAls := ALS->IdAls
if wwin[WIN_WAITKEY] == 12
  MemoDisplay(ALS->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
elseif wwin[WIN_WAITKEY] == 24
  b := oAlm()
  open area b, oArt(), oAls()
    edit data b key ALM->IdAls value cIdAls ;
                mode wait ;
                window wwin ;
                start top ;
                query "ALMALS"
  close area
endif
RETURN NIL


FUNCTION AlsExist(cIdAls)
local lOkay := .f.
open area oAls()
  seek cIdAls
  if ! eof()
    lOkay := .t.
  endif
close area
RETURN lOkay

FUNCTION AlsPickAttrib
local cAttrib := PickDbcAttr("ALSATTR.DBC",ALS->Attrib)
RETURN .f. if cAttrib == NIL
if ddRecLock()
  ALS->Attrib := cAttrib
  ddRefreshCurrent()
  unlock record
endif
RETURN SetMnuDone()


#endif DEF_ALS

FUNCTION MsgDevExist
#ifdef LG_GERMAN
  RETURN " : unbekannte W„hrung."
#else
  RETURN " : devise inconnue."
#endif



#ifdef DEF_HST

FUNCTION HstDate2
local doc := DocInfo(HST->IdJnl,HST->IdDoc,HST->Line)
RETURN HST->Date if doc == NIL
RETURN doc[DOC_ECHE]

#endif DEF_HST
