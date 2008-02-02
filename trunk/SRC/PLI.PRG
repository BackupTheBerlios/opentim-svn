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

#ifdef DEF_PLI


#ifdef LG_FRENCH
  #define MSG041 " : Info-Eintr„ge"
  #define MSG042 " : membres"
#else
  #define MSG041 " : Info-Eintr„ge"
  #define MSG042 " : Mitglieder"
#endif


#define LEN_IDPLI 2

#define PLI_IDPLS 1
#define PLI_IDPLI 2
#define PLI_NAME  3
#define PLI_ALEN  3


static saPli := NIL
static slUpdated

**
** PLS - Listes de partenaires - Informationskategorien
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
ddFld IdPls   ,C, LenIdPls(),0 picture PIC_ID
ddFld Name    ,C,50,0
ddFld Attrib  ,C, 3,0 picture PIC_ID ;
              pick PickDbcAttrib("PLSATTR.DBC",PLS->Attrib)
ddFld Memo    ,M,10,0
ddFld IdPrt   ,C,LEN_IDPRT,0 picture PIC_ID ;
                             pick PickPrt(NIL,NIL,PLS->IdPrt,PRT_ID)
ddFld _IdPls  ,C,LenIdPls()*2-1,0 attrib V ;
                                 block IdStruct(PLS->IdPls,1)
ddFld ParFilter ,C,50,0
action b key K_F12   prompt MnuMemoEdit() block PlsMemoEdit()
action b key K_ENTER prompt MnuInhalt() block PlsMbrEdit()
* #ifdef DEF_TOOLBOX
*   action b key K_ALT_F2 prompt MsgMnuRename() ;
*                         block PlsRename() ;
*                         when recno() != lastrec() + 1
* #endif
* #ifdef DEF_ACT
*   if IsCustData("PLS") ; ActExec("PLS") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

**
** MBR - Info-Eintr„ge
**
FUNCTION oMbr()
static b
if b != NIL ; RETURN b ; endif
define data b name MBR ;
            postedit MbrPostEdit() ;
            preedit MbrPreEdit()
ddIndex b on MBR->IdPls+MBR->Pos           // ORD_MBR_LSTPOS
ddIndex b on MBR->IdPar+MBR->IdPls+IdPli   // ORD_MBR_PAR
ddFld IdPls    ,C, LenIdPls(),0 picture PIC_ID ;
                   pick PickPls(MBR->IdPls)
ddFld IdPar    ,C, LenIdPar(),0 picture PIC_ID ;
                   pick PickPar(PLS->IdPrt,MBR->IdPar) ;
                   postedit {|x|GetIdPar(x,PLS->IdPrt)}
ddFld Pos      ,C, 4,0 GET_NUM
ddFld _ParName ,C,30,0 attrib V ;
                      block padr(ParName(MBR->IdPar),30)
ddFld _Liste   ,C,30,0 attrib V ;
                      block PlsName(MBR->IdPls)
ddFld Attrib   ,C, 3,0 picture PIC_ID
ddFld Remarq   ,C,LenMbrRemark(),0
ddFld _ParStreet ,C,30,0 attrib V ;
                      block padr(ParStreet(MBR->IdPar),30)
ddFld IdPli    ,C, LEN_IDPLI,0 picture PIC_ID ;
                   pick PickPli(MBR->IdPls,MBR->IdPli)
ddFld IdUsr    ,C, LenIdUsr(),0 picture PIC_ID
ddFld Date     ,D, 8,0
action b key K_SH_F5 prompt MnuParPage() ;
                     block ParPage(MBR->IdPar)
action b key K_ENTER block ParPage(MBR->IdPar) ;
                     when indexord() == ORD_MBR_LSTPOS
ddEndDef()
RETURN b

FUNCTION MbrPreEdit
RETURN .t. if ! PlsExist(MBR->IdPls)
RETURN PlsPreEdit()

FUNCTION PlsPreEdit
if PLSATTR_R $ PLS->Attrib
  SetMsg(trim(PLS->IdPls) + " : Partnerliste ist schreibgeschtzt !")
  RETURN .f.
endif
RETURN .t.

FUNCTION MbrPostEdit
MBR->IdUsr := UserId()
MBR->Date  := UserDate()
RETURN .t.

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
  set order to ORD_MBR_LSTPOS
  edit data b key MBR->IdPls ;
              value cIdPls ;
              create {||MbrCreate(cIdPls)} ;
              mode find ;
              start top ;
              query "MBRPLS" ;
              title (trim(PLS->Name) + MSG042)
              * query ORD_MBR_LSTPOS ;
close area
RETURN .f.


**
** ParMbrEdit()
**
FUNCTION ParMbrEdit(cIdPar)
local b := oMbr()
open area b, oPar(), oPls()
  set order to ORD_MBR_PAR
  edit data b key MBR->IdPar ;
              value cIdPar ;
              create {||MbrCreate(NIL,cIdPar)} ;
              mode edit ;
              start top ;
              query "MBRPAR" ;
              title (trim(ParName()) + MSG041)
close area
RETURN .f.


**
** MbrCreate()
**
FUNCTION MbrCreate(cIdPls,cIdPar)
local cNewSeq := MBR->Pos
local nRecNo
local nRecNo2
local cIdPli
local nOrder := indexord()
if cIdPls == NIL
  RETURN DDCREATE_FAIL if ! dbAddRec()
  MBR->IdPar := cIdPar
  MbrPostEdit()
  RETURN DDCREATE_REFRESH
else
  RETURN DDCREATE_FAIL if ! PlsExist(cIdPls)
  RETURN DDCREATE_FAIL if ! PlsPreEdit()
endif
if empty(cNewSeq)
  set order to 1
  KeyGoBottom(cIdPls,"MBR->IdPls")
  cNewSeq := NextNum(MBR->Pos)
  set order to (nOrder)
  RETURN DDCREATE_FAIL if ! dbAddRec()
  MBR->Pos   := cNewSeq
  MBR->IdPls := cIdPls
  MbrPostEdit()
  if cIdPar != NIL ; MBR->IdPar := cIdPar ; endif
  * unlock record // 19980430
  RETURN DDCREATE_EDIT
endif
set order to 1
// set order is ORD_MBR_LSTPOS
KeyGoBottom(cIdPls,"MBR->IdPls")
do while ! eof() .and. MBR->IdPls == cIdPls .and. MBR->Pos >= cNewSeq
  nRecNo := recno()
  skip -1
  if bof()
    nRecNo2 := lastrec() + 1
  else
    nRecNo2 := recno()
  endif
  goto nRecNo
  if ddRecLock()
    MBR->Pos := NextNum(MBR->Pos)
    unlock record
  else
    exit
  endif
  goto nRecNo2
enddo
set order to (nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
MBR->Pos   := cNewSeq
MBR->IdPls := cIdPls
MbrPostEdit()
if cIdPar != NIL ; MBR->IdPar := cIdPar ; endif
* unlock record // 19980430
RETURN DDCREATE_REFRESH


*FUNCTION ParMbrCollect(cIdPls,xlParFilter,nParOrder,cStart,xlWhile)
*local lOkay := .t.
*local nCount := 0
*local nAdded := 0
*local lFound
*default nParOrder to 1
*default cStart to ""
*default xlWhile to ".t."
*RETURN .f. if cIdPls == NIL
*open area oPar(), oNat(), oPlz(), oMbr()
*  set order to (nParOrder)
*  softseek cStart
*  do while lOkay .and. ! eof() .and. &xlWhile
*    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    if &xlParFilter
*      lFound := .f.
*      select MBR
*      set order to ORD_MBR_PAR
*      softseek PAR->IdPar
*      do while !eof() .and. MBR->IdPar == PAR->IdPar
*        if MBR->IdPls == cIdPls
*          lFound := .t.
*          exit
*        endif
*        skip
*      enddo
*      set order to ORD_MBR_LSTPOS
*      if ! lFound
*        if MbrCreate(cIdPls,PAR->IdPar) == DDCREATE_FAIL
*          lOkay := .f.
*        else
*          nAdded ++
*        endif
*      endif
*      select PAR
*    endif
*    skip
*  enddo
*close area
*SetMsg(ntrim(nAdded) + " Adressen hinzugefgt zur Liste " + cIdPls)
*RETURN lOkay

*FUNCTION ParMakeList(bcIdPar)
*local nPos := 0
*local cIdPls := PickPls(NIL,"")
*local lOK := .f.
*open area oMbr()
*  softseek cIdPls
*  if MBR->IdPls != cIdPls
*    lOk := .t.
*  endif
*close area
*if lOk
*  ddScan( {|| MbrAddToList(cIdPls,bcIdPar,++nPos) } )
*  MsgDisplay( ;
*    ntrim(nPos) + ;
*    " membres ont ‚t‚ ajout‚s … la liste " + trim(cIdPls) + "." ;
*  )
*else
*  Warning(cIdPls + " : cette liste n'est pas vide !")
*endif
*RETURN MnuDone()
*
*FUNCTION MbrAddToList(cIdPls,bcIdPar,nPos)
*local cPos := str(nPos,4)
*local lSuccess := .f.
*open area oMbr()
*  if MbrCreate(cIdPls,eval(bcIdPar),cPos) != DDCREATE_FAIL
*    lSuccess := .t.
*  endif
*close area
*RETURN lSuccess


**
** PlsPrint()
**
*FUNCTION PlsPrint
*static scIdTpl
*local a := PickTpl( ;
*  TPLTYPE_ART,scIdTpl, MemLang1, ;
*  {|| TplInfo() }, "Artikelstammdaten drucken" ;
*)
*RETURN NIL if a == NIL
*if OpenPrinter(a[TPL_IDOPT],a[TPL_WIDTH])
*  scIdTpl := a[TPL_IDTPL]
*  TplParse(a[TPL_MEMO])
*  ClosePrinter()
*endif
*RETURN MnuDone()

**
** PlsMbrList()
**
FUNCTION PlsMbrList(cParam)
local cFilter := ""
local nPos
local cIdPls := PLS->IdPls
if (nPos := at("/filter ",cParam)) != 0
  cFilter := alltrim(substr(cParam,nPos+8))
  cParam := alltrim(left(cParam,nPos-1))
endif
open area oMbr(), oPls(), oPar()
  softseek cIdPls
  do while MBR->IdPls == cIdPls .and. ! eof() .and. LstContinue()
    seek MBR->IdPar in PAR
    if empty(cFilter) .or. (&cFilter)
      TplParse(OhneAnf(cParam))
    endif
    skip
  enddo
close area
RETURN NIL

FUNCTION ParIsMember(cIdPls)
local cIdPar := PAR->IdPar
local lIsMember := .f.
open area oMbr()
  set order to ORD_MBR_PAR
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
  trim(PLS->IdPls) + " : Partnerliste l”schen (J/N) ?" ;
)
if ! Confirm( ;
  trim(PLS->IdPls) + ;
  " : alle Mitgliedeintragungen ebenfalls l”schen (J/N) ?" ;
)
  RETURN Confirm("Record trotzdem l”schen ?",MsgSure())
endif
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
local cId := NIL
local b := oPls()
default cTitle to "Liste ausw„hlen"
open area b
  * seek cIdPar in PAR
  if cStart != NIL
    softseek trim(cStart)
  endif
  edit data b mode pick query "PLSPICK" title (cTitle) ;
              filter (xlFilter)
       * filter ("empty(PLS->ParFilter).or.xparse(trim(PLS->ParFilter))")
  if ddLastReq() == DDEDIT_SELECT
    cId := PLS->IdPls
  endif
close area
RETURN cId

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


FUNCTION PliRefresh
saPli := ReadArray("PLI.DBC",PLI_ALEN)
RETURN NIL

FUNCTION PliLocate(cIdPls,cIdPli)
local i
if saPli == NIL ; PliRefresh() ; endif
for i := 1 to len(saPli)
  if saPli[i][PLI_IDPLS] == cIdPls
    RETURN saPli[i] if saPli[i][PLI_IDPLI] == cIdPli
  endif
next i
RETURN NIL

**
** PliExist()
**
FUNCTION PliExist(cIdPls,cIdPli)
RETURN .t. if PliLocate(cIdPls,cIdPli) != NIL
SetMsg(cIdPli + MsgPliExist() + trim(PlsName(cIdPls)))
RETURN .f.

FUNCTION MsgPliExist
RETURN " : unerlaubtes Feld fr Kategorie "


FUNCTION PliName(cIdPls,cIdPli)
local pli := PliLocate(cIdPls,cIdPli)
RETURN "" if pli == NIL
RETURN pli[PLI_NAME]


FUNCTION PickPli(cIdPls,cIdPli)
local nStart := 0
local i
local aPli := {}
if saPli == NIL ; PliRefresh() ; endif
for i := 1 to len(saPli)
  if empty(cIdPls) .or. saPli[i][PLI_IDPLS] == cIdPls
    aadd(aPli, saPli[i])
    if saPli[i][PLI_IDPLI] == cIdPli
      nStart := len(aPli)
    endif
  endif
next i
browse array aPli ;
             using {|x| x[PLI_IDPLI] + " " + padr(x[PLI_NAME],50) } ;
             title (PlsName(cIdPls)) ;
             delete {||.f.} ;
             start nStart ;
             help "PLI"
RETURN NIL if lastchoice() == 0
RETURN aPli[lastchoice()][PLI_IDPLI]


#define PLS_IDPLS    1
#define PLS_NAME     2
#define PLS_TAGGED   3
#define PLS_MBRLIST  4
* #define PLS_UPDATED  5
#define PLS_ALEN     4

#define MBR_IDPLI   1
#define MBR_PLINAME 2
#define MBR_REMARK  3
#define MBR_TAGGED  4
#define MBR_UPDATED 5
#define MBR_ALEN    5


**
** ParMbrBrowse() : Info-Editor
**
FUNCTION ParMbrBrowse(cIdPar)
local aPls := {}
local i
local j
local a
local mbr
local lOkay := .f.
local lFound
local aPlsActions := {}
if saPli == NIL ; PliRefresh() ; endif
* RETURN NIL if ! ParExist(cIdPar)
open area oPls()
  go top
  do while ! eof()
    if empty(PLS->ParFilter) .or. xparse(PLS->ParFilter) // EvalExpr(PLS->ParFilter)
      a := array(PLS_ALEN)
      a[PLS_IDPLS]   := PLS->IdPls
      a[PLS_NAME]    := PLS->Name
      a[PLS_TAGGED]  := .f.
      a[PLS_MBRLIST] := {}
      for i := 1 to len(saPli)
        if saPli[i][PLI_IDPLS] == PLS->IdPls
          mbr := array(MBR_ALEN)
          mbr[MBR_IDPLI]   := saPli[i][PLI_IDPLI]
          mbr[MBR_PLINAME] := saPli[i][PLI_NAME]
          mbr[MBR_REMARK]  := space(LenMbrRemark())
          mbr[MBR_TAGGED]  := .f.
          mbr[MBR_UPDATED] := .f.
          aadd(a[PLS_MBRLIST],mbr)
        endif
      next i
      aadd(aPls,a)
    endif
    skip
  enddo
close area
if len(aPls) == 0
  Warning("Keine Info-Kategorien definiert fr " + trim(ParName()))
  RETURN MnuDone()
endif
open area oMbr()
  lOkay := .t.
  set order to ORD_MBR_PAR
  softseek cIdPar
  do while lOkay .and. MBR->IdPar == cIdPar .and. ! eof()
    lFound := .f.
    for i := 1 to len(aPls)
      if MBR->IdPls == aPls[i][PLS_IDPLS]
        for j := 1 to len(aPls[i][PLS_MBRLIST])
          if MBR->IdPli == aPls[i][PLS_MBRLIST][j][MBR_IDPLI]
            lFound := .t.
            if aPls[i][PLS_MBRLIST][j][MBR_TAGGED]
              Warning("Doppelter Eintrag")
              lOkay := .f.
            else
              aPls[i][PLS_TAGGED] := .t.
              aPls[i][PLS_MBRLIST][j][MBR_TAGGED]  := .t.
              aPls[i][PLS_MBRLIST][j][MBR_REMARK]  := MBR->Remarq
              aPls[i][PLS_MBRLIST][j][MBR_IDPLI]   := MBR->IdPli
              aPls[i][PLS_MBRLIST][j][MBR_PLINAME] := PliName(MBR->IdPls,MBR->IdPli)
              exit
            endif
          endif
        next j
      endif
    next i
    if ! lFound
      Warning( ;
        MBR->IdPls + " " + MBR->IdPli + " : ungltiger Eintrag !", ;
        "Benutzen Sie [F4], i zum Bearbeiten !" ;
      )
      lOkay := .f.
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
slUpdated := .f.
open window (ParName() + " : Info-Editor") size 21,78 home 1,2
  aadd(aPlsActions,{ K_ENTER, {|pls|PlsMbrBrowse(pls,ABMODE_EDIT,trim(ParName())+" : "+trim(pls[PLS_NAME]),{ 20, 72, 1, 2, 0 } )} } )
  browse array aPls ;
               using {|pls|if(pls[PLS_TAGGED],BUTTON_ON,BUTTON_OFF)+" "+padr(pls[PLS_NAME],40)} ;
               permanent .t. ;
               delete {||.f.} ;
               idle {|pls|PlsMbrBrowse(pls,ABMODE_WAIT,NIL,{ 10, 74, 11, 3, 0 } )} ;
               exit { K_TAB } ;
               actions aPlsActions ;
               window { 8, 72, 2, 2, 0 }
close window
RETURN MnuDone() if ! slUpdated
open area oMbr()
  set order to ORD_MBR_PAR
  for i := 1 to len(aPls)
    for j := 1 to len(aPls[i][PLS_MBRLIST])
      if aPls[i][PLS_MBRLIST][j][MBR_UPDATED]
        seek cIdPar + aPls[i][PLS_IDPLS] + aPls[i][PLS_MBRLIST][j][MBR_IDPLI]
        if aPls[i][PLS_MBRLIST][j][MBR_TAGGED]
          if eof()
            if dbAddRec()
              MBR->IdPar := cIdPar
              MBR->IdPls := aPls[i][PLS_IDPLS]
              MBR->IdPli := aPls[i][PLS_MBRLIST][j][MBR_IDPLI]
              MBR->Remarq := aPls[i][PLS_MBRLIST][j][MBR_REMARK]
              MbrPostEdit()
              unlock record
            else
              lOkay := .f.
            endif
          elseif ddRecLock()
            MBR->Remarq := aPls[i][PLS_MBRLIST][j][MBR_REMARK]
            MbrPostEdit()
            unlock record
          else
            lOkay := .f.
          endif
        elseif found()
          if ddRecLock()
            delete
            unlock record
          else
            lOkay := .f.
          endif
        endif
      endif
    next j
  next i
close area
if ! lOkay
  Warning("Anomalie : Problem beim Speichern der Info-Eintr„ge !")
endif
RETURN MnuDone()


FUNCTION PlsMbrBrowse(pls,nMode,cTitle,win)
local i
local aMbrActions := {}
local a
if pls == NIL
  RETURN NIL
endif
aadd(aMbrActions, { K_ENTER, {|x|MbrEdit(x)}   })
aadd(aMbrActions, { K_SPACE, {|x|MbrToggle(x)} })
browse array pls[PLS_MBRLIST] ;
             using {|mbr| ;
               if(mbr[MBR_TAGGED],BUTTON_ON,BUTTON_OFF)+" "+;
               padr(mbr[MBR_PLINAME],30)+" "+;
               padr(mbr[MBR_REMARK],LenMbrRemark()) ;
             } ;
             delete {||.f.} ;
             window (win) ;
             mode (nMode) ;
             actions aMbrActions ;
             title (cTitle)
if slUpdated .and. nMode != ABMODE_WAIT
  pls[PLS_TAGGED] := .f.
  for i := 1 to len(pls[PLS_MBRLIST])
    if pls[PLS_MBRLIST][i][MBR_TAGGED]
      pls[PLS_TAGGED] := .t.
      exit
    endif
  next i
endif
RETURN K_ALT_F5

FUNCTION MbrEdit(x)
open window (trim(x[MBR_PLINAME])) size 3,LenMbrRemark()+4
get x[MBR_REMARK]
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
x[MBR_TAGGED]  := .t.
x[MBR_UPDATED] := .t.
slUpdated := .t.
RETURN NIL



FUNCTION MbrToggle(x)
if x[MBR_TAGGED]
  if ! empty(x[MBR_REMARK])
    RETURN NIL if ! Confirm( ;
      trim(x[MBR_REMARK]) + " : Eintrag wird gel”scht !", MsgSure() ;
    )
  endif
endif
x[MBR_TAGGED] := ! x[MBR_TAGGED]
x[MBR_REMARK] := space(LenMbrRemark())
x[MBR_UPDATED] := .t.
slUpdated := .t.
RETURN K_ALT_F5




FUNCTION PlsExist(cIdPls)
local lOkay := .f.
open area oPls()
  seek cIdPls
  if ! eof()
    lOkay := .t.
  endif
close area
RETURN lOkay

FUNCTION PlsPickAttrib
local cAttrib := PickDbcAttrib("PLSATTR.DBC",PLS->Attrib)
RETURN .f. if cAttrib == NIL
if ddRecLock()
  PLS->Attrib := cAttrib
  ddRefreshCurrent()
  unlock record
endif
RETURN SetMnuDone()



#else

  #ifndef DEF_PLS

    FUNCTION oPls() ; RETURN NIL
    FUNCTION oMbr() ; RETURN NIL

  #endif DEF_PLS
#endif DEF_PLI

FUNCTION PliInit() ; RETURN .t.

