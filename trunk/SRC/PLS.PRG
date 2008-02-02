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

#ifdef DEF_PLS


#ifdef LG_FRENCH
  * #define MSG041 " : Memberships"
  #define MSG042 " : membres"
#else
  * #define MSG041 " : Mitgliedschaften"
  #define MSG042 " : Mitglieder"
#endif


**
** PLS - Listes de partenaires
**
FUNCTION oPls()
static b
if b != NIL ; RETURN b ; endif
define data b name PLS ;
       preDelete PlsPreDelete() ;
       preedit PlsPreEdit() ;
       editprint TptDlgPrint(TPLTYPE_PLS,NIL,"Liste drucken mit Maske...") ;
       wait {|x| PlsWait(x)}
ddIndex b on  PLS->IdPls
ddFld IdPls   ,C, LenIdPls(),0 picture PIC_ID when .f.
ddFld Name    ,C,50,0
ddFld Attrib  ,C, 3,0 picture PIC_ID ;
              pick PickDbcAttr("PLSATTR.DBC",PLS->Attrib)
ddFld Memo    ,M,10,0
ddFld IdPrt   ,C,LEN_IDPRT,0 picture PIC_ID ;
                             pick PickPrt(NIL,NIL,PLS->IdPrt,PRT_ID)
ddFld _IdPls  ,C,LenIdPls()*2-1,0 attrib V ;
                                 block IdStruct(PLS->IdPls,1)
ddFld ParFilter ,C,50,0
action b key K_F12   prompt MnuMemoEdit() block PlsMemoEdit()
action b key K_ENTER prompt MnuInhalt() block PlsMbrEdit()
ddEndDef()
RETURN b

**
** MBR - Listenmitglieder
**
FUNCTION oMbr()
static b
if b != NIL ; RETURN b ; endif
define data b name MBR ;
            postedit MbrPostEdit() ;
            preedit MbrPreEdit() ;
            create MbrCreate()
// ddIndex b on MBR->IdPls+MBR->IdPar+MBR->IdPar2  // ORD_MBR_PLSPAR
ddIndex b on MBR->IdPls+MBR->SortText           // ORD_MBR_PLSTEXT
ddIndex b on MBR->IdPar+MBR->IdPls              // ORD_MBR_PAR
ddIndex b on MBR->IdPar2+MBR->IdPls             // ORD_MBR_PAR2
ddFld IdPls    ,C, LenIdPls(),0 picture PIC_ID ;
                   pick PickPls(MBR->IdPls) ;
                   valid MbrPlsValidate()
ddFld IdPar    ,C, LenIdPar(),0 picture PIC_ID ;
                   pick PickPar(PLS->IdPrt,MBR->IdPar) ;
                   postedit {|x|GetIdPar(x,PLS->IdPrt)} ;
                   valid MbrParValidate()
ddFld SortText ,C, 40,0
ddFld _ParName ,C,30,0 attrib V ;
                      block padr(ParName(MBR->IdPar),30)
ddFld _Liste   ,C,30,0 attrib V ;
                      block PlsName(MBR->IdPls)
ddFld Attrib   ,C, 3,0 picture PIC_ID
ddFld Remarq   ,C,LenMbrRemark(),0
ddFld _ParStreet ,C,30,0 attrib V ;
                      block padr(ParStreet(MBR->IdPar),30)
ddFld IdPar2 ,C,LenIdPar(),0 ;
             picture "@k@!" ;
             postedit {|x|GetIdPar(x,PLS->IdPrt)} ;
             pick PickMbrPar2() ;
             valid MbrPar2Validate()
ddFld IdUsr    ,C, LenIdUsr(),0 picture PIC_ID
ddFld Date     ,D, 8,0
action b key K_ENTER prompt MnuParPage() block MbrEnter()
ddPreCreate("MbrPreCreate()")
ddEndDef()
RETURN b


* Zum Fllen von PRJ->email in PAC\PRJPOST.ACT
FUNCTION ParMbrExpr(cIdPar,cIdPar2,xuExpr,uExpr)
open area oMbr(), oPar(), oPls()
  ddSetOrder(ORD_MBR_PAR)
  softseek cIdPar
  do while !eof() .and. MBR->IdPar==cIdPar
    if MBR->IdPar2==cIdPar2
      uExpr := xparse(xuExpr)
      exit
    endif
    skip
  enddo
close area
RETURN uExpr

FUNCTION PickMbrPar2()
* #ifdef DEF_PLP
*   RETURN ParPlpPick(MBR->IdPar,MsgZuHaenden())
* #endif DEF_PLP
RETURN PickPar(NIL,MBR->IdPar2)

FUNCTION MbrEnter()
// RETURN .f. if empty(MBR->IdPar).or.empty(MBR->IdPls)
// RETURN ParPage(MBR->IdPar) if indexord() == ORD_MBR_PLSPAR
if indexord() == ORD_MBR_PAR .and. !empty(MBR->IdPar2)
  RETURN ParPage(MBR->IdPar2)
endif
if !empty(MBR->IdPar)
  RETURN ParPage(MBR->IdPar) if indexord() == ORD_MBR_PLSTEXT
  RETURN ParPage(MBR->IdPar) if indexord() == ORD_MBR_PAR2
endif
RETURN .f.

FUNCTION MsgPlsExist(cIdPls)
RETURN cIdPls+" : no such partner list"

FUNCTION MbrPreCreate
local cIdPls
* if indexord() == ORD_MBR_PLSPAR .or. indexord() == ORD_MBR_PLSTEXT
if indexord() == ORD_MBR_PLSTEXT
  cIdPls := left(ddKeyValue(),LenIdPls())
  RETURN !SetMsg(MsgPlsExist(cIdPls)) if ! PlsExist(cIdPls)
  RETURN PlsPreEdit()
endif
RETURN .t.

FUNCTION MbrPreEdit
RETURN .t. if ! PlsExist(MBR->IdPls)
RETURN PlsPreEdit()

FUNCTION PlsPreEdit
if PLSATTR_R $ PLS->Attrib
  RETURN !SetMsg(trim(PLS->IdPls) + " : Partnerliste ist schreibgeschtzt !")
endif
RETURN .t.

STATIC FUNCTION ParPlpPick(cIdPar,cTitle,xlPlpFilter,xcPlpText)
local a := {}
default xlPlpFilter to ".t."
default xcPlpText to 'trim(ParName(PLP->IdPar2))+" ("+trim(PlpText())+")"'
open area oPlp(),oPar()
  softseek cIdPar
  do while !eof() .and. PLP->IdPar1==cIdPar
    if &xlPlpFilter
      aadd(a, { PLP->IdPar2, &xcPlpText } )
    endif
    skip
  enddo
close area
* RETURN NIL if len(a) == 0
open area oPar(), oPlz(),oNat()
  cIdPar := ArrayPick(a,cTitle,;
    NIL,NIL,NIL,NIL,NIL,NIL,{|x|padr(x[2],60)})
close area
RETURN NIL if cIdPar == NIL
RETURN cIdPar[1]


FUNCTION MbrPlsValidate()
// Denn wenn man vom Partner aus die MBR ”ffnet, dort Insert drckt und
// eine read-only Liste ausw„hlt, dann soll TIM das nicht zulassen.
// Und bei bestehenden Mitgliedschaften wird der folgende Code ja nicht
// aufgerufen.
RETURN .t. if empty(MBR->IdPls)
RETURN !SetMsg(MsgPlsExist(MBR->IdPls)) if ! PlsExist(MBR->IdPls)
RETURN !SetMsg("read-only") if !PlsPreEdit()
RETURN .t.

FUNCTION MsgZuHaenden()
RETURN "zu H„nden"

FUNCTION MbrParValidate()
local cIdPar
RETURN .t. if !empty(MBR->IdPar2)
* if (cIdPar := ParPlpPick(MBR->IdPar,MsgZuHaenden())) != NIL
*   MBR->IdPar2:=cIdPar
* endif
RETURN .t.

FUNCTION MbrPar2Validate()
local cIdPar
RETURN .t. if !empty(MBR->IdPar)
RETURN .t. if empty(MBR->IdPar2)
* if (cIdPar := ParPlpPick(MBR->IdPar2,"Empf„nger")) != NIL
*   MBR->IdPar:=cIdPar
* endif
RETURN .t.

FUNCTION MbrPostEdit
RETURN .f. if ! MbrRecTest()
MBR->SortText:=upper(ParName())
RETURN .t.

FUNCTION MbrMsgKey()
RETURN alltrim(MBR->IdPls)+"("+alltrim(MBR->IdPar)+","+alltrim(MBR->IdPar2)


FUNCTION MbrRecTest()
// ! MbrPostEdit() relies on the fact that after MbrRecTest() PAR is
// positionated on MBR->IdPar
local n
RETURN !SetMsg(MsgPlsExist(MBR->IdPls)) if ! PlsExist(MBR->IdPls)
n := DbfSum({oMbr()},"1",1,MBR->IdPls+MBR->IdPar+MBR->IdPar2)
if n > 1
  RETURN !SetMsg("Duplicate membership "+MbrMsgKey())
endif
if ! empty(MBR->IdPar2)
  RETURN !SetMsg("IdPar2=IdPar") if MBR->IdPar2==MBR->IdPar
  RETURN .f. if ! ParExist(MBR->IdPar2)
endif
RETURN ParExist(MBR->IdPar)


* FUNCTION MbrAdresse()
* if empty(MBR->IdPar2)
*   RETURN DbfPeek(oPar(),MBR->IdPar,"trim1(ParStreet(),', ')+ParCity()","")
* endif
* RETURN DbfPeek(oPar(),MBR->IdPar2,;
*   "trim1(trim1(PAR->Allo)+trim1(PAR->Vorname)+PAR->Firme,', ')"+;
*   "+trim1(ParStreet(),', ')+ParCity()",;
*   "")


FUNCTION PlsName(cId)
if cId != NIL
  if PLS->IdPls != cId
    seek cId in PLS
  endif
endif
RETURN PLS->Name


**
** PlsEdit()
**
FUNCTION PlsEdit(cTitle)
local b := oPls()
default cTitle to "Informationskategorien"
open area b, oPar(), oPlz()
  edit data b ;
            start top ;
            query "PLS" ;
            create {||RecCreate()} ;
            mode find ;
            title (cTitle)
close area
RETURN .f.


**
** PlsMbrEdit()
**
FUNCTION PlsMbrEdit()
local b := oMbr()
local cIdPls := PLS->IdPls
open area b, oPar(), oPls()
  ddSetOrder(ORD_MBR_PLSTEXT)
  edit data b key MBR->IdPls ;
              value cIdPls ;
              mode find ;
              start top ;
              query "MBRPLS" ;
              title (trim(PLS->Name) + MSG042)
close area
RETURN .f.


**
** ParMbrEdit()
**
FUNCTION ParMbrEdit(cIdPar)
local b := oMbr()
open area b, oPar(), oPls()
  ddSetOrder(ORD_MBR_PAR)
  edit data b key MBR->IdPar ;
              value cIdPar ; // create {||MbrCreate(NIL,cIdPar)} ;
              mode find ;
              start top ;
              query "MBRPAR" ;
              title (trim(ParName())+" : "+MnuItemName())
close area
RETURN .f.

FUNCTION ParMbr2Edit(cIdPar)
RETURN DbfEdit(;
  {oMbr(),oPls(),oPar(),oPlz(),oNat()},;
  ltrim(PAR->IdPar)+" : "+MnuItemName(),"MBRPAR2",;
  NIL,;
  NIL,;
  PAR->IdPar,;
  "MBR->IdPar2",;
  NIL)

FUNCTION PlsIsVisible(cIdPls)
RETURN .t. if empty(cIdPls)
RETURN len(trim(cIdPls))!=LenIdPls().or.asc(left(cIdPls,1))>58


**
** MbrCreate()
**
FUNCTION MbrCreate() // cIdPls,cIdPar)
local nOrder := indexord()
* if nOrder == ORD_MBR_PLSPAR .or. nOrder == ORD_MBR_PLSTEXT
*   default cIdPar to PickPar()
*   RETURN DDCREATE_FAIL if cIdPar == NIL
*   default cIdPls to left(ddKeyValue(),LenIdPls())
* else
*   default cIdPls to PickPls()
*   RETURN DDCREATE_FAIL if cIdPls == NIL
*   default cIdPar to left(ddKeyValue(),LenIdPar())
* endif
* if MbrExist(cIdPls,cIdPar)
*   SetMsg("Already member of this list")
*   RETURN DDCREATE_FAIL
* endif
RETURN DDCREATE_FAIL if ! dbAddRec()
* if nOrder == ORD_MBR_PLSPAR .or. nOrder == ORD_MBR_PLSTEXT
if nOrder == ORD_MBR_PLSTEXT
  MBR->IdPls := left(ddKeyValue(),LenIdPls())
elseif nOrder == ORD_MBR_PAR
  MBR->IdPar := left(ddKeyValue(),LenIdPar())
elseif nOrder == ORD_MBR_PAR2
  MBR->IdPar2 := left(ddKeyValue(),LenIdPar())
endif
* MBR->IdPar := cIdPar
* MBR->IdPls := cIdPls
MBR->IdUsr := UserId()
MBR->Date  := UserDate()
* MbrPostEdit()
* MbrParValidate()
RETURN DDCREATE_REFRESH


FUNCTION ParMbrCollect(cIdPls,xlParFilter,nParOrder,cStart,xlWhile,xlPlpFilter)
local lOkay := .t.
local nCount := 0
local nAdded := 0
default nParOrder to 1
default cStart to ""
default xlWhile to ".t."
RETURN .f. if cIdPls == NIL
open area oPar(), oNat(), oPlz(), oMbr()
  ddSetOrder(nParOrder)
  softseek cStart
  do while lOkay .and. ! eof() .and. &xlWhile
    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if TaskInter() ; lOkay := .f. ; exit ; endif
    if &xlParFilter
      select MBR
      * ddSetOrder(ORD_MBR_PLSPAR)
      * seek cIdPls+PAR->IdPar
      ddSetOrder(ORD_MBR_PAR)
      seek PAR->IdPar+cIdPls
      if eof()
        if dbAddRec()
          MBR->IdPls := cIdPls
          MBR->IdPar := PAR->IdPar
          #ifdef DEF_PLP
            if xlPlpFilter!=NIL
              open area oPlp()
                softseek MBR->IdPar
                do while PLP->IdPar1==MBR->IdPar
                  if &xlPlpFilter
                    MBR->IdPar2:=PLP->IdPar2
                    exit
                  endif
                  skip
                enddo
              close area
            endif
          #endif DEF_PLP
          MbrPostEdit()
          unlock record
          nAdded++
        else
          lOkay := .t.
        endif
      endif
      select PAR
    endif
    skip
  enddo
close area
SetMsg(ntrim(nAdded) + " Adressen hinzugefgt zur Liste " + cIdPls)
RETURN lOkay

FUNCTION PlsFillFrom(cIdPlsFrom)
local lOkay := .t.
local nCount := 0
local nAdded := 0
local nRecNo
local aBuf
local cIdPls := PLS->IdPls
RETURN .t. if empty(cIdPlsFrom)
open area oMbr(),oPar()
  softseek cIdPlsFrom
  do while lOkay .and. ! eof() .and. MBR->IdPls == cIdPlsFrom
    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if TaskInter() ; lOkay := .f. ; exit ; endif
    aBuf := CopyRec()
    nRecNo := recno()
    if dbAddRec()
      PasteRec(aBuf)
      MBR->IdPls := cIdPls
      MBR->IdUsr := UserId()
      MBR->Date  := UserDate()
      MbrPostEdit()
      unlock record
      nAdded ++
    else
      lOkay := .f.
    endif
    goto (nRecNo)
    skip
  enddo
close area
SetMsg(ntrim(nAdded) + " Adressen hinzugefgt zur Liste " + cIdPls)
RETURN lOkay

**
** PlsMbrList()
**
*FUNCTION PlsMbrList(cParam)
*local cFilter := ""
*local nPos
*local cIdPls := PLS->IdPls
*if (nPos := at("/filter ",cParam)) != 0
*  cFilter := alltrim(substr(cParam,nPos+8))
*  cParam := alltrim(left(cParam,nPos-1))
*endif
*open area oMbr(), oPls(), oPar()
*  softseek cIdPls
*  do while MBR->IdPls == cIdPls .and. ! eof() .and. LstContinue()
*    seek MBR->IdPar in PAR
*    if empty(cFilter) .or. (&cFilter)
*      TplParse(OhneAnf(cParam))
*    endif
*    skip
*  enddo
*close area
*RETURN NIL

FUNCTION MbrExist(cIdPls,cIdPar,cIdPar2)
RETURN DbfPeek(oMbr(),cIdPls+cIdPar+cIdPar2,".t.",.f.)

FUNCTION ParIsMember(cIdPls)
local cIdPar := PAR->IdPar
local lIsMember := .f.
open area oMbr()
  ddSetOrder(ORD_MBR_PAR)
  softseek cIdPar + cIdPls
  if ! eof() .and. MBR->IdPar == cIdPar
    if left(MBR->IdPls,len(cIdPls)) == cIdPls
      lIsMember := .t.
    endif
  endif
close area
RETURN lIsMember

**
**
**
FUNCTION PlsPreDelete()
local lOkay := .f. // nReturn := DDDEL_FAIL
RETURN .f. if ! Confirm( ;
  trim(PLS->IdPls) + " : Partnerliste mitsamt Mitgliedseintr„gen l”schen (J/N) ?" ;
)
* if ! Confirm( ;
*   trim(PLS->IdPls) + ;
*   " : alle Mitgliedeintragungen ebenfalls l”schen (J/N) ?" ;
* )
*   RETURN Confirm("Record trotzdem l”schen ?",MsgSure())
* endif
open area oMbr()
  lOkay := .t.
  softseek PLS->IdPls
  do while ! eof() .and. MBR->IdPls == PLS->IdPls
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
** PickPls()
**
FUNCTION PickPls( cStart, cTitle, xlFilter )
default cTitle to "Liste ausw„hlen"
RETURN DbfPick({oPls()},cTitle,"PLSPICK",cStart)

* FUNCTION PickPls( cStart, cTitle, xlFilter )
* local cId := NIL
* local b := oPls()
* default cTitle to "Liste ausw„hlen"
* open area b
*   * seek cIdPar in PAR
*   if cStart != NIL
*     softseek trim(cStart)
*   endif
*   edit data b mode pick query "PLSPICK" title (cTitle) ;
*               filter (xlFilter)
*        * filter ("empty(PLS->ParFilter).or.xparse(trim(PLS->ParFilter))")
*   if ddLastReq() == DDEDIT_SELECT
*     cId := PLS->IdPls
*   endif
* close area
* RETURN cId

**
** PlsMemoEdit()
**
FUNCTION PlsMemoEdit()
return MnuDone() if ! ddRecLock()
open window size 20,80
TxtEdit( ;
  fieldblock("Memo"), WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
  ddOnPreEdit(oPls()), 76 ;
)
close window
unlock record
ddRefreshCurrent()
RETURN .f.


FUNCTION PlsWait(wwin)
local b
local cIdPls := PLS->IdPls
if wwin[WIN_WAITKEY] == 12
  MemoDisplay(PLS->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
elseif wwin[WIN_WAITKEY] == 24
  b := oMbr()
  open area b, oPar(), oPls()
    edit data b key MBR->IdPls value cIdPls ;
                mode wait ;
                window wwin ;
                start top ;
                query "MBRPLS"
  close area
endif
RETURN NIL


*FUNCTION PlsExist(cIdPls)
*RETURN DbfPeek(oPls(),cIdPls,".t.",.f.)
** local lOkay := .f.
** open area oPls()
**   seek cIdPls
**   if ! eof()
**     lOkay := .t.
**   endif
** close area
** RETURN lOkay

FUNCTION PlsExist(cId)
if PLS->IdPls == cId .and. ! (eof() in PLS)
  RETURN .t.
endif
seek cId in PLS
if eof() in PLS
  RETURN .f.
endif
RETURN .t.



FUNCTION PlsPickAttrib
local cAttrib := PickDbcAttr("PLSATTR.DBC",PLS->Attrib)
RETURN .f. if cAttrib == NIL
if ddRecLock()
  PLS->Attrib := cAttrib
  ddRefreshCurrent()
  unlock record
endif
RETURN SetMnuDone()


*#else
*
*  #ifndef DEF_PLI
*    FUNCTION oPls() ; RETURN NIL
*    FUNCTION oMbr() ; RETURN NIL
*  #endif DEF_PLI

#endif DEF_PLS

FUNCTION MsgGenerating
#ifdef LG_FRENCH
RETURN " : g‚n‚ration en cours..."
#else
RETURN  " wird generiert..."
#endif


