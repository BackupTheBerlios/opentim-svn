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

#ifdef DEF_LIC

#define ORD_LIC_PAR 2

**
** LIC - Licences
**
FUNCTION oLic()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                           ;
  name LIC                              ;
  create LicCreate()                    ;
  postedit LicPostEdit() ;
  editprint LicPrint() ;
  wait {|x| LicWait(x) }
ddindex b on LIC->IdLic text "Nø Licence"
ddindex b on LIC->IdPar + upper(LIC->Str1) ;
             format {|x|upper(x,LenIdPar())} // ORD_LIC_PAR
ddFld IdLic   ,C,  8,0 picture PIC_ID when .f.
ddFld IdPar   ,C, LenIdPar() ,0 picture PIC_ID ;
                                pick PickPar(NIL,LIC->IdPar)
ddFld Str1    ,C, 30,0
ddFld Str2    ,C, 30,0
ddFld Str3    ,C, 30,0
ddFld Contact ,C, 30,0
ddFld Tel     ,C, 20,0
ddFld Fax     ,C, 20,0
ddFld Date    ,D,  8,0
ddFld Memo    ,M, 10,0
ddFld _ParName,C, 30,0 attrib V block padr(ParName(LIC->IdPar),30)
* ddFld IdTpl   ,C, LenIdTpl(),0 picture PIC_ID pick PickTpl(TPLTYPE_LIC,LIC->IdTpl)
action b key K_SH_F5   prompt MnuParPage() ;
                       block ParPage(LIC->IdPar)
action b key K_ENTER   block LicRelEdit(LIC->IdLic)
action b key K_F12     prompt MnuMemoEdit() ;
                       block LicMemoEdit()
ddEndDef()
RETURN b

**
** LicWait()
**
FUNCTION LicWait(wwin)
local b
local cIdLic := LIC->IdLic
if nextkey() != 0
  RETURN NIL
elseif wwin[WIN_WAITKEY] == 1 // „hnlich wie LicRelEdit()
  RETURN ClearWaitWin(wwin) if eof()
  b := oRel()
  open area b, oLic()
    edit data b key REL->IdLic value cIdLic ;
      mode     wait  ;
      window wwin ;
      start  bottom ;
      query "RELLIC"
  close area
endif
RETURN MnuDone()




FUNCTION LicPostEdit()
RETURN .f. if ! ParExist(LIC->IdPar)
if empty(LIC->Str1)
  LIC->Str1 := ParName()
endif
if empty(LIC->Str2)
  LIC->Str2 := ParStreet()
endif
if empty(LIC->Str3)
  LIC->Str3 := ParCity()
endif
RETURN .t.

FUNCTION LicPrint
seek LIC->IdPar in PAR
RETURN TptDlgPrint("LIC",PAR->Langue,"Print LICENSE document")

**
** REL - releases
**
FUNCTION oRel()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                           ;
  name REL                              ;
  editprint RelPrint() ;
  preedit  RelPreEdit() ;
  postedit RelPostEdit()
ddindex b on REL->IdLic + dtos(REL->Date)
ddindex b on REL->IdApl + dtos(REL->Date)
ddindex b on dtos(REL->Date)                // ORD_REL_DATE
ddFld Date    ,D,  8,0 when USRATTR_S $ UsrAttrib()
ddFld IdLic   ,C,  8,0 picture PIC_ID attrib R
ddFld IdApl   ,C,  8,0 picture PIC_ID
ddFld AppVer  ,N,  5,2 picture "@K"
ddFld Options ,C, 30,0 pick PickDbcAttr(trim(REL->IdApl)+".DBC",REL->Options) ;
                       picture PIC_ID
ddFld HWID    ,C, 10,0 picture PIC_ID // pick PickHwi(REL->HWID,REL->IdLic)
ddFld Remarq  ,C, 30,0
ddFld _Instal ,C, 15,0 attrib V block InstF(RelInstall())
ddFld Limit   ,D,  8,0
* ddFld IdTxt   ,C, LenIdTpl(),0 picture PIC_ID ;
*                        pick PickTpl(TPLTYPE_REL,REL->IdTxt)
ddFld Attrib  ,C,  4,0 picture PIC_ID ;
                       pick PickDbcAttr("RELATTR.DBC",REL->Attrib)
ddFld Text    ,M, 10,0
ddFld _Titre  ,C, 40,0 attrib V block padr(REL->Text,30)
action b key K_SH_F5   prompt MnuParPage() block ParPage(LIC->IdPar)
action b key K_F12     prompt MnuMemoEdit() block RelMemoEdit()
* action b key K_F5      prompt "Write *.mrk file       [F5]" ;
*                        block RelWriteMrk()
ddEndDef()
RETURN b

FUNCTION RelPrint
seek REL->IdLic in LIC
seek LIC->IdPar in PAR
RETURN TptDlgPrint("REL",PAR->Langue,"Print RELEASE document")

FUNCTION RelPreEdit()
RETURN .t. if REL->Date >= UserDate()
SetMsg("Modification refus‚e ! [Ins] pour cr‚er un nouveau release.")
* RETURN .t. if USRATTR_S $ UsrAttrib()
RETURN .f.

**
** LicMemoEdit()
**
FUNCTION LicMemoEdit()
return .f. if ! ddRecLock()
open window ( "Licence memo " + LIC->IdLic ) size 20, 80
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oLic()), 76 ;
  )
close window
unlock record
RETURN .f.

**
** RelMemoEdit()
**
FUNCTION RelMemoEdit()
return .f. if ! ddRecLock()
open window ( "RELEASE memo " + REL->IdLic + " " + dtoc(REL->Date)) size 20, 80
  TxtEdit( ;
    fieldblock("Memo"), ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oRel()), 76 ;
  )
close window
unlock record
RETURN .f.

FUNCTION RelPostEdit
local lReturn := .t.
if REL->IdLic != LIC->IdLic
  seek REL->IdLic in LIC
  if eof() in LIC
    SetMsg(REL->IdLic + " : Nø de licence invalide !")
    RETURN .F.
  endif
endif
RETURN .T. if empty(REL->HWID)
*if REL->HWID != HWI->HWID
*  select HWI
*  seek REL->HWID
*  if eof()
*    if HwiCreate(REL->IdLic,REL->HWID) == DDCREATE_FAIL
*      Warning("HWID : n'existe pas !")
*    endif
*  elseif HWI->IdLic != REL->IdLic .and. ! empty(HWI->IdLic)
*    Warning(REL->HWID + " : d‚j… utilis‚ pour la licence " + HWI->IdLic)
*  endif
*  select REL
*endif
* if empty(REL->Remarq)
*   REL->Remarq := HWI->NameI
* endif
RETURN lReturn

**
** PickHwi()
**
*FUNCTION PickHwi(cStart,cIdLic)
*local cId := NIL
*local b :=  oHwi()
** open window "Select Hardware ID" size 10,80
*open area b
*  softseek trim(cStart)
*  if empty(cIdLic)
*    edit data b mode pick ;
*         create HwiCreate(cIdLic) ;
*         title "Select Hardwar-ID"
*  else
*    ddSetOrder(2)
*    edit data b    ;
*         key HWI->IdLic value cIdLic ;
*         mode pick ;
*         create HwiCreate(cIdLic) ;
*         title "Select Hardwar-ID"
*  endif
*  if ddLastReq() == DDEDIT_EXIT
*    cId := HWI->HWID
*  endif
*close area
** close window
*RETURN cId

**
** PickLic()
**
FUNCTION PickLic(cStart)
local cId := NIL
local b :=  oLic()
open area b
  softseek trim(cStart)
  edit data b mode pick ;
            title "Select License"
  if ddLastReq() == DDEDIT_EXIT
    cId := LIC->IdLic
  endif
close area
RETURN cId

FUNCTION LicRelEdit(cIdLic)
local b := oRel()
open area b, oLic()
  edit data b key REL->IdLic value cIdLic ;
    create   {||RelCreate(cIdLic)}  ;
    mode     find  ;
    start  bottom ;
    query "RELLIC" ;
    title ("Releases for license " + trim(cIdLic) )
close area
RETURN NIL

FUNCTION ParLicEdit(cIdPar)
local b := oLic()
open area b, oPar()
  ddSetOrder(ORD_LIC_PAR)
  edit data b key LIC->IdPar value cIdPar ;
    create   {||LicCreate(cIdPar)}  ;
    mode     find  ;
    start  bottom ;
    query "LICPAR" ;
    title (trim(ParName()) + " : Licences")
close area
RETURN NIL

**
**
**
FUNCTION RelCreate(cIdLic)
local aBuf := CopyRec()
RETURN DDCREATE_FAIL if ! dbAddRec()
* append blank
* RETURN DDCREATE_FAIL if ! ddRecLock()
PasteRec(aBuf)
if cIdLic != NIL
  REL->IdLic := cIdLic
endif
REL->Date  := UserDate()
REL->Limit := SkipMonth(UserDate(),3)
* unlock record 19980430
* endif
* ddRefreshAll()
* RETURN DDCREATE_DONE
RETURN DDCREATE_REFRESH


**
** LicCreate
**
FUNCTION LicCreate(cIdPar)
local cIdLic := space(len(LIC->IdLic))
do while .t.
  open window "Cr‚ation Licence" size 3,40
  @ CSR_POS say "Nø Licence" get cIdLic picture PIC_ID
  nKey := ReadScr()
  close window
  if nKey == K_ESC
    RETURN DDCREATE_FAIL
  endif
  if empty(cIdLic)
    SetMsg("Nø Licence : obligatoire.")
    loop
  endif
  if ! IsNewId(cIdLic)
  * seek cIdLic
  * if !eof()
    SetMsg("Existe d‚j…!")
    loop
  endif
  exit
enddo
RETURN DDCREATE_FAIL if ! dbAddRec()
* 19980430
* append blank
* if ddRecLock()
  LIC->IdLic := cIdLic
  if cIdPar != NIL
    LIC->IdPar := cIdPar
  endif
*   unlock record
* endif
RETURN DDCREATE_FULL

FUNCTION RelInstall()
if LIC->IdLic != REL->IdLic
  seek REL->IdLic in LIC
endif
RETURN dtop(REL->Limit) + stok( ;
  { ;
    LIC->Str1, ;
    LIC->Str2, ;
    LIC->Str3  ;
  } , ;
  trim(REL->IdApl) + trim(REL->Options), ;
  REL->AppVer, REL->Limit, left(REL->HWID,8) ;
)

FUNCTION InstF(cInstall)
RETURN transform(cInstall,"@R XXX-XXX.XXX.XXX")



*FUNCTION RelWriteMrk
* local cPath := trim(LIC->Path)
*local cName := trim(left(REL->HWID,8)) + ".MRK"
*public MrkStr1    := LIC->Str1
*public MrkStr2    := LIC->Str2
*public MrkStr3    := LIC->Str3
*public MrkIdLic   := LIC->IdLic
*public MrkOptions := REL->Options
*public MrkInstall := RelInstall()
*default scPath to trim(LIC->Path)
*do while .t.
*  scPath := padr(scPath,50)
*  open window ("Write " + cName) size 3,65
*  say "Path : "
*  get scPath picture PIC_ID
*  nKey := ReadScr()
*  close window
*  RETURN .f. if nKey == K_ESC
*  scPath := trim(scPath)
*  if ! PathExist(scPath)
*    loop
*  endif
*  if file(scPath + "\" + cName)
*    if ! Confirm("OK to overwrite " + cName + " ?")
*      loop // RETURN .f.
*    endif
*  endif
*  save to (scPath + "\" + cName) all like Mrk*
*  SetMsg(scPath + "\" + cName + " has been written.")
*  exit
*enddo
*RETURN MnuDone()



#endif DEF_LIC

**
** TptDlgPrint()
**
FUNCTION TptDlgPrint(cIdTpt,cIdLng,cTitle,cPreview)
static scIdTpl
local tpl
default cIdLng to MemLang1
tpl := PickTpl( ;
  cIdTpt,scIdTpl, cIdLng, ;
  {|| TplInfo() }, cTitle ;
)
RETURN NIL if tpl == NIL
SetDlgTitle(tpl[TPL_NAME])
* if ! empty(tpl[TPL_IDDLG])
*   RETURN NIL if ! DlgExec(tpl[TPL_IDDLG])
*   cPreview := DlgValue("preview",.f.)
* endif
if OpenPrinter(tpl[TPL_IDOPT],cPreview, ;
    tpl[TPL_WIDTH],NIL,NIL,NIL, ;
    tpl[TPL_IDDLG] ;
  )
  scIdTpl := tpl[TPL_IDTPL]
  p_MsgDisplay(tpl[TPL_NAME])
  TplParse(hardcr(tpl[TPL_MEMO]))
  ClosePrinter()
endif
RETURN MnuDone()

#ifdef DEF_JNL

**
** TplDlgPrint()
**
FUNCTION TplDlgPrint(cIdTpt,cIdTpl,cJnlTest)
local bTitBlock
local cTitle := TptName(cIdTpt)
local nHeight := 4
local nWidth  := 40
* local cTplIni
static scIdTpl := NIL
local tpl
if cIdTpl == NIL
  tpl := PickTpl(cIdTpt,scIdTpl,MemLang1,{||TplInfo()},cTitle)
else
  tpl := TplValue(cIdTpt,cIdTpl,{||TplInfo()})
endif
RETURN NIL if tpl == NIL
if ! empty(tpl[TPL_IDOPT])
  SetTplIni(tpl[TPL_IDOPT])
endif
if empty(tpl[TPL_IDDLG])
  scIdTpl := tpl[TPL_IDTPL] // cIdTpl
  if TPLATTR_P $ tpl[TPL_ATTRIB]
    nHeight ++
  endif
  nWidth := max(nWidth,len(tpl[TPL_NAME])+6)
  open window (tpl[TPL_NAME]) size nHeight,nWidth ;
              help (trim(tpl[TPL_IDTPL]))
  if TPLATTR_P $ tpl[TPL_ATTRIB]
    SayGetPeriode()
  endif
  GetPreview()
  WinCr()
  GetTplIni()
  nKey := ReadScr()
  close window
  RETURN NIL if nKey == K_ESC
else
  SetDlgTitle(tpl[TPL_NAME])
  RETURN .f. if ! DlgExec(tpl[TPL_IDDLG])
endif
if TPLATTR_P $ tpl[TPL_ATTRIB]
  if cJnlTest == NIL
    bTitBlock := {|| ;
      PrintHeader( tpl[TPL_NAME], PerText() ) ;
    }
  else
      RETURN NIL if ! WrnJnlOpen({||&cJnlTest})
      bTitBlock := {|| ;
        PrintHeader( tpl[TPL_NAME], PerText( cblock(cJnlTest) ) ) ;
      }
  endif
  AppSaveMem()
else
bTitBlock := {|| ;
  PrintHeader( tpl[TPL_NAME] ) ;
}
endif
if OpenPrinter(SetTplIni(),SetPreview(),tpl[TPL_WIDTH],bTitBlock)
  p_MsgDisplay(tpl[TPL_NAME])
  TplParse(hardcr(tpl[TPL_MEMO]))
  ClosePrinter()
endif
RETURN NIL

#endif DEF_JNL


