** ADL.PRG : DEF_ADR : ADR, ADL und ADM (Adressenlisten)

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

#ifdef DEF_ADR


#ifdef LG_FRENCH
  #define MSG041 " : Info-Eintr„ge"
  #define MSG042 " : membres"
#else
  #define MSG041 " ist Mitglied in :"
  #define MSG042 " : Mitglieder"
#endif


**
** ADL - Listes de partenaires - Informationskategorien
**
FUNCTION oAdl()
static b
if b != NIL ; RETURN b ; endif
define data b name ADL ;
       preDelete AdlPreDelete() ;
       preedit AdlPreEdit() ;
       editprint TptDlgPrint(TPLTYPE_ADL,NIL,"Liste drucken mit Maske...") ;
       wait {|x| AdlWait(x)}
ddIndex b on  ADL->IdAdl
ddFld IdAdl   ,C, LenIdAdl(),0 picture PIC_ID
ddFld Name    ,C,50,0
ddFld Attrib  ,C, 3,0 picture PIC_ID ;
              pick PickDbcAttr("ADLATTR.DBC",ADL->Attrib)
ddFld Memo    ,M,10,0
ddFld IdPrt   ,C,LEN_IDPRT,0 picture PIC_ID ;
                             pick PickPrt(NIL,NIL,ADL->IdPrt,PRT_ID)
ddFld AdrFilter ,C,50,0
action b key K_F12   prompt MnuMemoEdit() block AdlMemoEdit()
action b key K_ENTER prompt MnuInhalt() block AdlAdmEdit(ADL->IdAdl)
ddEndDef()
RETURN b

**
** ADM - Info-Eintr„ge
**
FUNCTION oAdm()
static b
if b != NIL ; RETURN b ; endif
define data b name ADM ;
            postedit AdmPostEdit() ;
            preedit AdmPreEdit()
ddIndex b on ADM->IdAdl+ADM->Pos           // ORD_ADM_ADL
ddIndex b on ADM->IdAdr+ADM->IdAdl   // ORD_ADM_ADR
ddFld IdAdl    ,C, LenIdAdl(),0 picture PIC_ID ;
                   pick PickAdl(ADM->IdAdl)
ddFld IdAdr    ,C, LenIdAdr(),0 picture PIC_ID ;
                   pick PickAdr(ADM->IdAdr) ;
                   postedit {|x|GetIdAdr(x,ADL->IdPrt)}
ddFld Pos      ,C, 4,0 GET_NUM
action b key K_SH_F5 prompt MnuParPage() ;
                     block AdrPage(ADM->IdAdr)
action b key K_ENTER block AdrPage(ADM->IdAdr) ;
                     when indexord() == ORD_ADM_ADL
ddEndDef()
RETURN b

FUNCTION AdmPreEdit
RETURN .t. if ! AdlExist(ADM->IdAdl)
RETURN AdlPreEdit()

FUNCTION AdlPreEdit
if ADLATTR_R $ ADL->Attrib
  SetMsg(trim(ADL->IdAdl) + " : Adressenliste ist schreibgeschtzt !")
  RETURN .f.
endif
RETURN .t.

FUNCTION AdmPostEdit
RETURN .t.

FUNCTION AdlName(cId)
if cId != NIL
  if ADL->IdAdl != cId
    seek cId in ADL
  endif
endif
RETURN ADL->Name


**
** AdlEdit()
**
FUNCTION AdlEdit(cTitle)
local b := oAdl()
default cTitle to "Informationskategorien"
open area b, oAdr(), oPlz()
  edit data b ;
            start top ;
            query "ADL" ;
            create {||RecCreate()} ;
            mode find ;
            title (cTitle)
close area
RETURN .f.


**
** AdlAdmEdit()
**
FUNCTION AdlAdmEdit(cIdAdl)
local b := oAdm()
open area b, oAdr(), oAdl(), oPlz()
  ddSetOrder(ORD_ADM_ADL)
  edit data b key ADM->IdAdl ;
              value cIdAdl ;
              create {||AdmCreate(cIdAdl)} ;
              mode find ;
              start top ;
              query "ADMADL" ;
              title (trim(ADL->Name) + MSG042)
close area
RETURN .f.


**
** AdrAdmEdit()
**
FUNCTION AdrAdmEdit(cIdAdr)
local b := oAdm()
open area b, oAdr(), oAdl(), oPlz()
  ddSetOrder(ORD_ADM_ADR)
  edit data b key ADM->IdAdr ;
              value cIdAdr ;
              create {||AdmCreate(NIL,cIdAdr)} ;
              mode edit ;
              start top ;
              query "ADMADR" ;
              title (AdrName() + MSG041)
close area
RETURN .f.


**
** AdmCreate()
**
FUNCTION AdmCreate(cIdAdl,cIdAdr)
local cNewSeq := ADM->Pos
local nRecNo
local nRecNo2
local nOrder := indexord()
if cIdAdl == NIL
  RETURN DDCREATE_FAIL if ! dbAddRec()
  ADM->IdAdr := cIdAdr
  AdmPostEdit()
  RETURN DDCREATE_REFRESH
else
  RETURN DDCREATE_FAIL if ! AdlExist(cIdAdl)
  RETURN DDCREATE_FAIL if ! AdlPreEdit()
endif
if empty(cNewSeq)
  ddSetOrder(1)
  // set order is ORD_ADM_ADL
  KeyGoBottom(cIdAdl,"ADM->IdAdl")
  cNewSeq := NextNum(ADM->Pos)
  ddSetOrder(nOrder)
  RETURN DDCREATE_FAIL if ! dbAddRec()
  ADM->Pos   := cNewSeq
  ADM->IdAdl := cIdAdl
  AdmPostEdit()
  if cIdAdr != NIL ; ADM->IdAdr := cIdAdr ; endif
  RETURN DDCREATE_EDIT
endif
ddSetOrder(1)
// set order is ORD_ADM_ADL
KeyGoBottom(cIdAdl,"ADM->IdAdl")
do while ! eof() .and. ADM->IdAdl == cIdAdl .and. ADM->Pos >= cNewSeq
  nRecNo := recno()
  skip -1
  if bof()
    nRecNo2 := lastrec() + 1
  else
    nRecNo2 := recno()
  endif
  goto nRecNo
  if ddRecLock()
    ADM->Pos := NextNum(ADM->Pos)
    unlock record
  else
    exit
  endif
  goto nRecNo2
enddo
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
ADM->Pos   := cNewSeq
ADM->IdAdl := cIdAdl
AdmPostEdit()
if cIdAdr != NIL ; ADM->IdAdr := cIdAdr ; endif
* unlock record // 19980430
RETURN DDCREATE_REFRESH


FUNCTION AdrIsMember(cIdAdl)
local cIdAdr := ADR->IdAdr
local lIsMember := .f.
open area oAdm()
  ddSetOrder(ORD_ADM_ADR)
  softseek cIdAdr + cIdAdl
  if ! eof() .and. ADM->IdAdr == cIdAdr
    if left(ADM->IdAdl,len(cIdAdl)) == cIdAdl
      lIsMember := .t.
    endif
  endif
close area
RETURN lIsMember

**
**
**
FUNCTION AdlPreDelete()
local lOkay := .f. // nReturn := DDDEL_FAIL
RETURN .f. if ! Confirm( ;
  trim(ADL->IdAdl) + " : Adressenliste l”schen (J/N) ?" ;
)
if ! Confirm( ;
  trim(ADL->IdAdl) + ;
  " : alle Mitgliedeintragungen ebenfalls l”schen (J/N) ?" ;
)
  RETURN Confirm("Record trotzdem l”schen ?",MsgSure())
endif
open area oAdm()
  lOkay := .t.
  softseek ADL->IdAdl
  do while ! eof() .and. ADM->IdAdl == ADL->IdAdl
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
** PickAdl()
**
FUNCTION PickAdl( cStart, cTitle, xlFilter )
local cId := NIL
local b := oAdl()
default cTitle to "Liste ausw„hlen"
open area b
  * seek cIdAdr in ADR
  if cStart != NIL
    softseek trim(cStart)
  endif
  edit data b mode pick query "ADLPICK" title (cTitle) ;
              filter (xlFilter)
  if ddLastReq() == DDEDIT_SELECT
    cId := ADL->IdAdl
  endif
close area
RETURN cId

**
** AdlMemoEdit()
**
FUNCTION AdlMemoEdit()
return MnuDone() if ! ddRecLock()
open window size 20,80
TxtEdit( ;
  fieldblock("Memo"), WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
  ddOnPreEdit(oAdl()), 76 ;
)
close window
unlock record
ddRefreshCurrent()
RETURN .f.


FUNCTION AdlWait(wwin)
local b
local cIdAdl := ADL->IdAdl
if wwin[WIN_WAITKEY] == 12
  MemoDisplay(ADL->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
elseif wwin[WIN_WAITKEY] == 24
  b := oAdm()
  open area b, oAdr(), oAdl()
    edit data b key ADM->IdAdl value cIdAdl ;
                mode wait ;
                window wwin ;
                start top ;
                query "ADMADL"
  close area
endif
RETURN NIL


FUNCTION AdlExist(cIdAdl)
local lOkay := .f.
open area oAdl()
  seek cIdAdl
  if ! eof()
    lOkay := .t.
  endif
close area
RETURN lOkay

FUNCTION AdlPickAttrib
local cAttrib := PickDbcAttr("ADLATTR.DBC",ADL->Attrib)
RETURN .f. if cAttrib == NIL
if ddRecLock()
  ADL->Attrib := cAttrib
  ddRefreshCurrent()
  unlock record
endif
RETURN SetMnuDone()

**
** AdrWait()
**
FUNCTION AdrWait(wwin)
local cIdAdr := ADR->IdAdr
local b
if nextkey() != 0
  RETURN NIL
                                                  #ifdef DEF_MEMO
elseif wwin[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH], ;
    NIL, NIL, StdMemoWidth() ;
  )
                                                 #endif DEF_MEMO
elseif wwin[WIN_WAITKEY] == 24    // wie AdrAdmEdit()
  b := oAdm()
  open area b, oAdr(), oAdl(), oPlz()
    ddSetOrder(ORD_ADM_ADR)
    edit data b key ADM->IdAdr value cIdAdr ;
                mode wait ;
                window wwin ;
                start top ;
                query "ADMADR"
  close area
endif
RETURN NIL

FUNCTION AdrName(cIdAdr)
if cIdAdr != NIL
  if ADR->IdAdr != cIdAdr
    seek cIdAdr in ADR
  endif
endif
RETURN trim1(ADR->Name)+trim(ADR->Vorname)

**
** ADR - Adressen (sh. CUST_CPAS)
**
FUNCTION oAdr()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                  ;
  name ADR ;
  wait {|x| AdrWait(x)}
  ddIndex b on ADR->IdAdr
ddFld IdAdr   ,C,LenIdAdr(),0 picture PIC_ID when .f.
ddEndDef()
RETURN b

FUNCTION AdrPage(cId,cIdQry,nMode,cTitle)
default nMode to DDMODE_EDIT
open area oAdr(), oPlz(), oNat()
  if cId != NIL
    seek cId
  endif
  default cIdQry to ("ADR")
  default cTitle to ("Adressen")
  edit data oAdr() ;
            full ;
            noskip ;
            mode (nMode) ;
            query (cIdQry) ;
            create {||DDCREATE_FAIL} ;
            title (cTitle)
close area
RETURN MnuDone()



FUNCTION PickAdr(cIdAdr)
RETURN DbfPick({oAdr(),oPlz()},"Adresse ausw„hlen","ADRPICK",cIdAdr)

FUNCTION LenIdAdr()
RETURN 6

FUNCTION GetIdAdr(c)
RETURN GetId(c,LenIdAdr(),0)

#endif DEF_ADR



FUNCTION Str2Rue(c)
local a := Rue2Array(c)
RETURN a[1]

FUNCTION Str2RueNum(c)
local a := Rue2Array(c)
RETURN a[2]

FUNCTION Str2RueBte(c)
local a := Rue2Array(c)
RETURN a[3]

FUNCTION Rue2Array(c)
local i
local cRue
local cNum
local cBte
local nLen
local a
c := trim(c)
nLen := len(c)

i := 1
do while i <= nLen .and. !substr(c,i,1)$"0123456789"
  ++i
enddo
cRue := left(c,i-1)
c := substr(c,i)

nLen := len(c)
i := 1
do while i <= nLen .and. substr(c,i,1)$"0123456789"
  ++i
enddo
cNum := left(c,i-1)
c := substr(c,i)

cBte = c

do while len(cBte) > 5
  a := Rue2Array(cBte)
  cRue += cNum + a[1]
  cNum := a[2]
  cBte := a[3]
enddo

RETURN {cRue, cNum, cBte}


