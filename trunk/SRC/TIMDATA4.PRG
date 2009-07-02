** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2009 Luc Saffre
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

#ifdef DEF_BIBLIO
  static MSG_DOCEDIT := "Dokumente    [Enter]"
  static MSG_RENAME  := "Umbenennen  [Alt-F2]"
#endif DEF_BIBLIO

#ifdef DEF_JNL

**
** JNL - Journaux
**
FUNCTION oJnl()
local b
* static b := NIL
* if b != NIL ; RETURN b ; endif
define data b                   ;
  name JNL                      ;
  postedit JnlPostEdit()        ;
  predelete JnlPreDelete(JNL->IdJnl)            ;
  create JnlCreate()            ;
  wait {|win| JnlWait(win) }
ddIndex b on JNL->IdJnl
ddIndex b on JNL->Seq
ddFld IdJnl   ,C, LenIdJnl(),0 when .f.
ddFld Alias   ,C, 3,0 picture PIC_ID ;
                      pick PickAlias(JNL->Alias) ;
                      when JnlIsEmpty(JNL->IdJnl)
ddFld Libell  ,C,30,0
ddFld Attrib  ,C,12,0 pick PickJnlAttrib(JNL->Attrib,JNL->Alias) ;
                      picture PIC_ID
ddFld IdTxt   ,C, LenIdTpl(),0 picture PIC_ID ;
               pick PickTpl(JNL->IdTpt,JNL->IdTxt)
#ifdef DEF_GEN
  ddFld IdGen   ,C, LenIdGen(),0 postedit {|x| GetIdGen(x) } ;
                                 pick PickCompte(JNL->IdCtr,JNL->IdGen)
#else
  ddFld IdGen   ,C, 0,0 attrib H
#endif
ddFld IdCtr ,C, LenIdCtr(),0 picture PIC_ID pick PickCtr(JNL->IdCtr)
ddFld DC      ,C, 1,0 picture PIC_ID
ddFld Seq     ,C, 3,0 postedit {|x|GetSeq(x)}
ddFld IdDev   ,C, LEN_IDDEV,0 picture PIC_ID pick PickDev(JNL->IdDev)
ddFld DocLib1 ,C,25,0
ddFld DocLib2 ,C,25,0
ddFld DocLib3 ,C,25,0
ddFld IdGrj   ,C,LEN_IDGRJ,0 picture PIC_ID pick PickGrj(JNL->IdGrj)
ddFld TaxDecPos,C, 1,0
ddFld Code    ,C, 1,0 picture PIC_ID pick JnlPickCode(JNL->Code)
ddFld IdTpt   ,C, LEN_IDTPT,0 picture PIC_ID ;
                  pick PickTpt(JNL->IdTpt)
#ifdef DEF_IMP
  ddFld IdCdc   ,C,LEN_IDCDC,0 picture PIC_ID ;
                pick PickCdc(JNL->DC,JNL->IdCdc)
#else
  ddFld IdCdc   ,C,0,0 attrib H
#endif
ddFld _GrjName,C,LEN_GRJNAME,0 attrib V ;
                  block padr(GrjName(JNL->IdGrj),LEN_GRJNAME)
ddFld DocLib1N,C,25,0
ddFld DocLib2N,C,25,0
ddFld DocLib3N,C,25,0
ddFld IdDbv   ,C, 5,0 picture PIC_ID ;
                      pick PickQry(JNL->Alias,".QRY",JNL->IdDbv)
ddFld CodeCli   ,C, 11,0 picture PIC_ID
ddFld CodeBqe   ,C, 3,0 picture PIC_ID
ddFld Compte    ,C, 14,0 picture PIC_ID ;
      postedit {|x| BqePostEdit(x) } ;
      valid BqeValidate(JNL->Compte)
ddFld DocAttr ,C,6,0 picture PIC_ID ;
                     pick JnlPickFca()
ddFld IdDoc   ,C,LEN_IDDOC,0 picture PIC_ID ;
                             pick PickDoc(JNL->IdJnl,JNL->IdDoc)
ddFld Periode ,C,LEN_PERIODE,0 when .f.
#ifdef DEF_HST
  ddFld IdHcl   ,C, 5,0 picture PIC_ID ;
                        pick PickQry(JNL->Alias,".HCL",JNL->IdHcl)
#else
  ddFld IdHcl   ,C, 0,0 attrib H
#endif DEF_HST
ddFld IdDocUntil  ,C,LEN_IDDOC,0 picture PIC_ID ;
                             pick PickDoc(JNL->IdJnl,JNL->IdDocUntil)
#ifdef DEF_ARC
  ddFld ArcPeriode ,C,LEN_PERIODE,0 picture PIC_ID ;
                      pick PickPer(JNL->ArcPeriode)
#else
  ddFld ArcPeriode ,C,0,0 attrib H
#endif DEF_ARC
ddFld SeqType   ,C, 1,0 picture PIC_ID ;
                      pick PickSeqType(JNL->SeqType)

#ifdef DEF_4LANG
  ddFld DocLib4N,C,25,0
  ddFld DocLib4 ,C,25,0
#else
  ddFld DocLib4N,C,25,0 attrib H
  ddFld DocLib4 ,C,25,0 attrib H
#endif DEF_4LANG
// ddFld IdBenef   ,C, 11,0 picture PIC_ID // Domizilierungen

* action b key K_F9 prompt "Buchungsperioden [F9]" ;
*          block JnlPerEdit(JNL->IdJnl)
* #ifndef DEF_STK
*   ddFldRemove("IdStk")  wegen JnlRefresh()
* #endif DEF_STK
ddEndDef()
RETURN b

FUNCTION JnlPickFca()
#ifdef DEF_VEN
  RETURN PickFca(JNL->DocAttr,trim(JNL->Libell)) if JNL->Alias == "VEN"
#endif DEF_VEN
RETURN NIL

**
** IFC - Fakturierungsanweisungen (instructions de facturation)
**
FUNCTION oIfc()
local b
define data b   ;
  name IFC      ;
  create SeqCreate(oIfc()) ;
  wait {|msk| IfcWait(msk) } ;
  attrib K
ddIndex b on IFC->Seq
ddFld Seq       ,C,3,0 postedit {|x|GetSeq(x)}
ddFld Text      ,C,128,0
ddFld IdJnl     ,C,LenIdJnl() ,0 picture PIC_ID  ;
                pick PickIdJnl(NIL,IFC->IdJnl, ;
                  JnlList({|j| ;
                    j[JNL_ALIAS]=="VEN".and.j[JNL_IDCTR]==IFC->IdCtr ;
                  }) ;
                )
ddFld IdCtr     ,C, LenIdCtr(),0 pick PickCtr(IFC->IdCtr) ;
                picture PIC_ID
ddFld Attrib    ,C, 15,0 picture PIC_ID pick PickIfcAttrib(IFC->Attrib)
ddFld IdReg     ,C,LEN_IDREG,0  picture PIC_ID ;
                                pick PickReg(IFC->IdReg)
ddFld Delai     ,C, 3,0 GET_NUM
ddFld IdTpl     ,C, LenIdTpl(),0 picture PIC_ID ;
                    pick PickTpl(JnlIdTpt(IFC->IdJnl),IFC->IdTpl)
ddFld IdMfc     ,C, LenIdMfc(),0 picture PIC_ID ;
                    pick PickMfc(IFC->IdMfc,IFC->Seq)
ddFld Memo1     ,M, 10,0
ddFld Memo2     ,M, 10,0
ddFld Memo3     ,M, 10,0
ddFld IdPar     ,C, LenIdPar(),0 picture PIC_ID ;
                    pick PickPar(NIL,IFC->IdPar)
#ifdef DEF_4LANG
ddFld Memo4     ,M, 10,0
#else
ddFld Memo4     ,M, 10,0 attrib H
#endif
action b key K_F12   prompt "~Text-Editor    [F12]" block IfcMemoEdit()
action b key K_ENTER block IfcMemoEdit()
ddEndDef()
RETURN b

FUNCTION IfcWait(win)
if win[WIN_WAITKEY] == 1
  memodisplay(IFC->Memo1,5,2,4,76,NIL,NIL,NIL,NIL,B_SINGLE)
  @ 4,65 say " " + trim(LngName(MemLang1)) + " "
  memodisplay(IFC->Memo2,11,2,4,76,NIL,NIL,NIL,NIL,B_SINGLE)
  @ 10,65 say " " + trim(LngName(MemLang2)) + " "
  memodisplay(IFC->Memo3,17,2,4,76,NIL,NIL,NIL,NIL,B_SINGLE)
  @ 16,65 say " " + trim(LngName(MemLang3)) + " "
endif
RETURN NIL


#ifdef DEF_IMP

**
** CDC - Codes de centralisation
**
FUNCTION oCdc()
local b
define data b   ;
  name CDC      ;
  attrib K
ddIndex b on CDC->IdCdc
ddFld IdCdc     ,C, LEN_IDCDC,0 picture PIC_ID 
ddFld IdCtr     ,C, LenIdCtr(),0 picture PIC_ID pick PickCtr(CDC->IdCtr)
ddFld DC        ,C, 1,0 picture PIC_ID
ddFld Name      ,C, 30,0
ddFld Header    ,C, LenMntF(),0
ddFld Expr      ,C, 128,0 picture "@K@S30"
ddEndDef()
RETURN b

**
** SRV -
**
FUNCTION oSrv()
local b
define data b   ;
  name SRV      ;
  attrib K
ddIndex b on SRV->IdSrv
ddFld IdSrv     ,C, 1,0 picture PIC_ID
ddFld Name      ,C, 30,0
ddFld Attrib    ,C, 3,0 picture PIC_ID pick PickSrvAttrib(SRV->Attrib)
ddFld CodTot  ,C, 2,0 picture PIC_ID pick PickGrb(NIL,SRV->CodTot)
ddFld SubBud  ,C, 2,0 picture PIC_ID pick PickSbb(SRV->SubBud)
ddFld IdBud_D ,C, LenIdBud(),0  picture PIC_ID ;
                                block {|x| GsbIdBud_D(x) } ;
                                pick PickBudSay(DC_DEBIT,SRV->IdBud_D)
ddFld IdBud_C ,C, LenIdBud(),0  picture PIC_ID ;
                                block {|x| GsbIdBud_C(x) } ;
                                pick PickBudSay(DC_CREDIT,SRV->IdBud_C)
ddEndDef()
RETURN b

FUNCTION PickSrvAttrib(cStart)
local aAttrib := {}
* #ifdef LG_FRENCH
* #else
  aadd(aAttrib, { SRVATTR_U, "Kredit bertragen          " , 1 } )
  aadd(aAttrib, { SRVATTR_K, "Vorjahresartikel erstellen " , 1 } )
* #endif
RETURN PickAttrib(aAttrib,NIL,cStart,"","SRVATTR")

FUNCTION GsbIdBud_D(x)
RETURN SayIdBud(FIELD->IdBud_D) if x == NIL
FIELD->IdBud_D := GetIdBud(x)
RETURN NIL
FUNCTION GsbIdBud_C(x)
RETURN SayIdBud(FIELD->IdBud_C) if x == NIL
FIELD->IdBud_C := GetIdBud(x)
RETURN NIL

// {|x|iif(x==NIL,SayIdBud(FIELD->IdBud),FIELD->IdBud:=GetIdBud(x))}

#endif DEF_IMP

#endif DEF_JNL

#ifdef DEF_DEV

**
** DEV - Devises
**
FUNCTION oDev()
local b
* static b := NIL
* if b != NIL ; RETURN b ; endif
define data b   ;
  name DEV      ;
  attrib K ;
  postedit DevPostEdit()
ddIndex b on DEV->IdDev
ddFld IdDev   ,C, LEN_IDDEV,0  picture PIC_ID
ddFld Libell  ,C,30,0
ddFld Cours   ,C,10,0  GET_NUM
ddFld NbDec   ,N, 1,0
ddFld Delta   ,C, 6,0  GET_NUM
ddFld Cours2  ,C,10,0  GET_NUM
ddEndDef()
RETURN b

FUNCTION DevPostEdit
* if val(DEV->Cours) == 0
*   DEV->Cours := str(1,10,2)
* endif
RETURN .t.

#endif DEF_DEV

#ifdef DEF_VAR

**
** VRT - Variantenarten
**
FUNCTION oVrt()
local b
define data b   ;
  name VRT      ;
  attrib K
  ddIndex b on VRT->IdVrt
ddFld IdVrt   ,C, 1,0  picture PIC_ID
ddFld Name    ,C,30,0 postedit {|x| ValPrompt(x)}
ddFld Start   ,C, 2,0  GET_NUM
ddFld Len     ,C, 2,0  GET_NUM
ddFld Attrib  ,C, 4,0  picture PIC_ID pick PickVrtAttrib(VRT->Attrib)
ddFld Separ1  ,C,15,0
ddFld Separ2  ,C,15,0
ddEndDef()
RETURN b

#endif DEF_VAR

#ifdef DEF_UNT

**
** UNT - unit‚s de livraison
**
FUNCTION oUnt()
local b
define data b   ;
  name UNT      ;
  attrib K
  ddIndex b on UNT->IdUnt
ddFld IdUnt   ,C, LenIdUnt(),0  picture PIC_ID
ddFld Name1   ,C,20,0
ddFld Name2   ,C,20,0
ddFld Name3   ,C,20,0
ddFld QteForm  ,C, 1,0 picture "!" ;
                       pick PickQteForm(UNT->QteForm)
ddEndDef()
RETURN b

#else

FUNCTION oUnt() ; RETURN NIL

#endif DEF_UNT

**
** CTR - comptes de centralisation
**
FUNCTION oCtr()
local b
define data b   ;
  name CTR ;
  attrib K ;
  postedit CtrPostEdit() ;
  preedit CtrPreEdit()
  * convert GenConvert()
ddIndex b on CTR->IdCtr
ddFld IdCtr   ,C, LenIdCtr(),0 picture PIC_ID
ddFld Name    ,C, 20,0
#ifdef DEF_GEN
ddFld IdGen   ,C, LenIdGen(),0 picture PIC_ID ;
                  pick PickGen(NIL,CTR->IdGen)    ;
                  postedit {|x| GetIdGen(x) }
#else
ddFld IdGen   ,C, 0,0 attrib H
#endif DEF_GEN
ddFld HstCols ,C, 10,0 picture PIC_ID ;
                  pick PickDbcAttr("HSTVEN.DBC",CTR->HstCols)
ddFld DC      ,C, 1,0 picture PIC_ID valid DcValidate(CTR->DC)
ddFld PrtList ,C, 10,0 picture PIC_ID pick PickPrtList(CTR->PrtList)
#ifdef DEF_CTRATTR
  ddFld Attrib  ,C, 4,0 picture PIC_ID ;
        pick PickDbcAttr("CTRATTR.DBC",CTR->Attrib)
#else
  ddFld Attrib  ,C, 4,0 picture PIC_ID attrib H
#endif DEF_CTRATTR
ddFld TplIni   ,C,LenIdTpl(),0 picture PIC_ID ;
                  pick PickTpl(TPLTYPE_INI,CTR->TplIni)
ddEndDef()
RETURN b

#ifdef DEF_LGT

**
** LGT - comptes de centralisation
**
... FUNCTION oLgt()
local b
define data b   ;
  name LGT ;
  create SeqCreate(oLgt()) ;
  attrib K
ddIndex b on LGT->Seq
ddFld Seq     ,C,3,0 postedit {|x|GetSeq(x)}
ddFld Name    ,C, 20,0
#ifdef DEF_GEN
ddFld IdGen   ,C, LenIdGen(),0 picture PIC_ID ;
                  pick PickGen(NIL,LGT->IdGen)    ;
                  postedit {|x| GetIdGen(x) }
#else
ddFld IdGen   ,C, 0,0 attrib H
#endif DEF_GEN
#ifdef DEF_TAX
ddFld IdTax   ,C,LEN_IDTAX,0 picture PIC_ID ;
                             pick PickTax(LGT->IdTax)
#else
ddFld IdTax   ,C,0,0 attrib H
#endif DEF_TAX
ddFld xnBase  ,C, 120,0 picture "@k@s30"
ddFld xlWhen  ,C, 120,0 picture "@k@s30"
ddEndDef()
RETURN b

#endif DEF_LGT

#ifdef DEF_FRF

**
** FRF - Frais de facturation
**
FUNCTION oFrf()
local b
define data b   ;
  name FRF ;
  create SeqCreate(oFrf()) ;
  attrib K
ddIndex b on FRF->Seq
ddFld Seq     ,C,3,0 postedit {|x|GetSeq(x)}
ddFld xlWhen  ,C, 120,0 picture "@k@s30"
#ifdef DEF_GEN
ddFld IdGen   ,C, LenIdGen(),0 picture PIC_ID ;
                  pick PickGen(NIL,FRF->IdGen)    ;
                  postedit {|x| GetIdGen(x) }
#else
ddFld IdGen   ,C, 0,0 attrib H
#endif DEF_GEN
#ifdef DEF_TAX
ddFld IdTax   ,C,LEN_IDTAX,0 picture PIC_ID ;
                             pick PickTax(FRF->IdTax)
#else
ddFld IdTax   ,C,0,0 attrib H
#endif DEF_TAX
ddFld xnBase  ,C, 120,0 picture "@k@s30"
ddFld xnTaxe  ,C, 120,0 picture "@k@s30"
ddEndDef()
RETURN b

#else

FUNCTION oFrf() ; RETURN NIL

#endif DEF_FRF

#ifdef DEF_VENREMISE

**
** VNR - D‚finitions de Remises par VEN
**
FUNCTION oVnr()
local b
define data b   ;
  name VNR ;
  create SeqCreate(oVnr()) ;
  attrib K
ddIndex b on VNR->Seq
ddFld Seq     ,C,3,0 postedit {|x|GetSeq(x)}
ddFld FldName ,C, 8,0
ddFld xlWhen  ,C, 120,0 picture "@k@s30"
ddFld xnMult  ,C, 120,0 picture "@k@s30"
ddEndDef()
RETURN b

#else

FUNCTION oVnr() ; RETURN NIL

#endif DEF_VENREMISE



#ifdef DEF_TAX

**
** TAX - Codes T.V.A.
**
FUNCTION oTax()
local b
* static b := NIL
* if b != NIL ; RETURN b ; endif
define data b   ;
  name TAX ;
  attrib K ;
  create SeqCreate() ;
  wait {|msk| TaxWait(msk) } ;
  postedit TaxPostEdit()
  * convert TaxConvert()
ddIndex b on TAX->Seq // TAX->IdCtr + TAX->IdTax
ddFld IdTax    ,C, LEN_IDTAX,0  picture PIC_ID
ddFld Libell   ,C,40,0
ddFld Taux     ,C, 6,0 GET_NUM
ddFld IdCtr    ,C, LenIdCtr(),0 picture PIC_ID pick PickCtr(TAX->IdCtr)
ddFld IdGen    ,C, LenIdGen(),0 picture PIC_ID ;
                                pick PickGen(NIL,TAX->IdGen) ;
                                postedit {|x| GetIdGen(x) }
ddFld GenTiers ,C, LenIdGen(),0 picture PIC_ID ;
                                pick PickGen(NIL,TAX->GenTiers) ;
                                postedit {|x| GetIdGen(x) }
ddFld IdClj    ,C, LEN_IDCLJ,0 picture PIC_ID ;
                               pick PickClj(TAX->IdCtr,TAX->IdClj)
ddFld Attrib   ,C, 4,0 pick PickTaxAttrib(TAX->Attrib) ;
                      picture PIC_ID
ddFld Memo1    ,M,10,0
ddFld Memo2    ,M,10,0
ddFld Memo3    ,M,10,0
ddFld Date     ,D, 8,0
ddFld Seq     ,C,3,0 postedit {|x|GetSeq(x)}
ddFld xlValid  ,C,128,0
ddFld RegList  ,C,10,0 picture PIC_ID pick PickReg(TAX->RegList)
#ifdef DEF_4LANG
  ddFld Memo4    ,M,10,0
#else
  ddFld Memo4    ,M,10,0 attrib H
#endif 
action b key K_F12   prompt "~Text-Editor         [F12]" block TaxMemoEdit()  // T
action b key K_ENTER block TaxMemoEdit()
#ifdef DEF_CTT
  action b key K_SH_F9 prompt "~Sammelhistorik [Shift-F9]" ;
                       block TaxCttEdit(TAX->IdCtr,TAX->IdTax)
#endif DEF_CTT
ddEndDef()
RETURN b

**
** TaxWait()
**
*FUNCTION TaxWait(msk)
*if nextkey() != 0
*  RETURN NIL
*elseif msk[MSK_WAITKEY] == 0
*  MemoDisplay(FIELD->Memo1,  4,2,5,76)
*  MemoDisplay(FIELD->Memo2, 10,2,5,76)
*  MemoDisplay(FIELD->Memo3,  6,2,5,76)
*endif
*RETURN NIL

FUNCTION TaxWait(win)
if win[WIN_WAITKEY] == 1
  memodisplay(TAX->Memo1,5,2,4,76,NIL,NIL,NIL,NIL,B_SINGLE)
  @ 4,65 say " " + trim(LngName(MemLang1)) + " "
  memodisplay(TAX->Memo2,11,2,4,76,NIL,NIL,NIL,NIL,B_SINGLE)
  @ 10,65 say " " + trim(LngName(MemLang2)) + " "
  memodisplay(TAX->Memo3,17,2,4,76,NIL,NIL,NIL,NIL,B_SINGLE)
  @ 16,65 say " " + trim(LngName(MemLang3)) + " "
endif
RETURN NIL




FUNCTION TaxConvert
DBN->GenTiers := DBO->CfrTiers
DBN->IdGen    := DBO->IdCfr
RETURN .t.

**
** REG - R‚gimes T.V.A.
**
FUNCTION oReg()
local b
define data b   ;
  name REG      ;
  attrib K
  ddIndex b on upper(REG->Libell)
ddFld IdReg   ,C,LEN_IDREG,0  picture PIC_ID
ddFld Libell  ,C,30,0
ddFld IdTax   ,C,LEN_IDTAX,0 picture PIC_ID ;
                             pick PickTax(REG->IdTax)
ddFld Text    ,C,80,0
ddFld Attrib  ,C,5,0 picture PIC_ID ;
                     pick PickDbcAttr("REGATTR.DBC",REG->Attrib)
ddEndDef()
RETURN b

#else

FUNCTION oReg() ; RETURN NIL // used in boss.mnu

#endif DEF_TAX

#ifdef DEF_CTT

**
** CTT - centralisation TVA
**
FUNCTION oCtt()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b   ;
  name CTT ;
  editPrint CttPrint()
ddIndex b on CTT->Periode + CTT->IdJnl + CTT->IdTax + CTT->IdCtf + CTT->DC
ddIndex b on CTT->IdCtr + CTT->IdTax + CTT->Periode + CTT->IdJnl + CTT->IdCtf + CTT->DC
ddFld IdJnl    ,C, LenIdJnl(),0  picture PIC_ID
ddFld Periode  ,C,LEN_PERIODE,0
ddFld IdTax    ,C, LEN_IDTAX,0  picture PIC_ID
ddFld IdCtf    ,C, LEN_IDCTF,0  picture PIC_ID
ddFld DC       ,C, 1,0  picture PIC_ID
ddFld _Delta   ,T,LenMont(),0  attrib V block {|x| CttDelta()}
ddFld Base     ,T,LenMont(),0  GET_MONTANT value val(CTT->Base)
ddFld Taxe     ,T,LenMont(),0  GET_MONTANT value val(CTT->Taxe)
ddFld IdCtr    ,C,LenIdCtr(),0  picture PIC_ID
ddEndDef()
RETURN b

FUNCTION CttDelta
local nMont := val(CTT->Base) * TaxTaux(JnlIdCtr(CTT->IdJnl),CTT->IdTax) / 100
RETURN str(val(CTT->Taxe) - nMont,10,2)

#endif DEF_CTT

#ifdef DEF_IPB

**
** IPB - Imputation des bases
**
FUNCTION oIpb()
local b
define data b   ;
  name IPB      ;
  create SeqCreate(oIpb()) ;
  attrib K
ddIndex b on IPB->Seq
ddFld Seq     ,C,3,0 postedit {|x|GetSeq(x)}
ddFld IdCtr   ,C, LenIdCtr(),0 picture PIC_ID pick PickCtr(IPB->IdCtr)
ddFld IdReg     ,C, 1,0 picture PIC_ID pick PickReg(IPB->IdReg)
ddFld IdCta     ,C, LEN_IDCTA,0  picture PIC_ID ;
                                 pick PickCta(IPB->IdCta)
#ifdef DEF_TAX
ddFld IdTax     ,C, LEN_IDTAX,0  picture PIC_ID ;
                    pick PickTax(IPB->IdTax,IPB->IdCtr)
#else
ddFld IdTax     ,C, 1,0
#endif DEF_TAX
ddFld GenBase   ,C, LenIdGen(),0  picture PIC_ID ;
                                  pick PickGen(NIL,IPB->GenBase) ;
                                  postedit {|x| GetIdGen(x) }
ddFld _GenName  ,C, 40,0  attrib V block padr(GenName(IPB->GenBase),40)
ddFld Attrib    ,C, 3,0  picture PIC_ID pick PickIpbAttrib(IPB->Attrib)
ddFld IdDev     ,C, LEN_IDDEV,0 picture PIC_ID pick PickDev(IPB->IdDev)
ddFld IdDma     ,C, 1,0 picture PIC_ID ;
                        pick PickDbcCode("DMA.DBC",IPB->IdDma)
ddFld xlWhen  ,C, 200,0 picture "@k@s30"
ddEndDef()
RETURN b

#endif DEF_IPB

#ifdef DEF_FIN

**
** DIF - diff‚rences de paiement
**
FUNCTION oDif()
local b
* static b := NIL
* if b != NIL ; RETURN b ; endif
define data b   ;
  name DIF      ;
  create SeqCreate(oDif()) ;
  attrib K
  ddIndex b on DIF->Seq
ddFld Seq     ,C,3,0 postedit {|x|GetSeq(x)}
ddFld Libell  ,C,30,0
ddFld IdCtr   ,C, LenIdCtr(),0 picture PIC_ID pick PickCtr(DIF->IdCtr)
ddFld IdGen   ,C, LenIdGen(),0  picture PIC_ID ;
                  pick PickGen(NIL,DIF->IdGen) ;
                  postedit {|x| GetIdGen(x) }
ddFld GenDeb  ,C, LenIdGen(),0
ddFld GenCre  ,C, LenIdGen(),0
ddFld DC      ,C, 1,0 picture PIC_ID
ddEndDef()
RETURN b

#endif DEF_FIN

*#ifdef DEF_SHELL
*
***
*** BAT - Commandes DOS
***
*FUNCTION oBat()
*local b
** static b := NIL
** if b != NIL ; RETURN b ; endif
*define data b   ;
*  name BAT
*  ddIndex b on upper(BAT->Libell)
*ddFld Libell  ,C,30,0
*ddFld FileName,C,30,0  picture PIC_ID
*#ifdef DEF_STRFILES
*  #ifdef LG_GERMAN
*  #include "BATD.STR"
*  #else
*  #include "BATF.STR"
*  #endif
*#endif DEF_STRFILES
*RETURN b
*
*#endif DEF_SHELL


*#ifdef DEF_RAPPEL
*
***
*** DGR - Degr‚s de rappel
***
*FUNCTION oDgr()
*local b
** static b := NIL
** if b != NIL ; RETURN b ; endif
*define data b name DGR
*ddIndex b on DGR->IdDgr
*ddFld IdDgr   ,C,LEN_IDDGR,0  picture PIC_ID
*ddFld Libell1 ,C,44,0  picture "@K@S30" // width 30
*ddFld Libell2 ,C,44,0  picture "@K@S30" // width 30
*ddFld Retard  ,C, 5,0  GET_NUM
*ddFld Taux    ,C, 5,0  GET_NUM
*ddFld MontMin ,C,10,0  GET_MONTANT
*ddFld Attrib  ,C, 3,0  picture PIC_ID
*ddFld Header  ,C,10,0
*ddFld Inter   ,C, 5,0  GET_NUM
*#ifdef DEF_STRFILES
*  #ifdef LG_GERMAN
*  #include "DGRD.STR"
*  #else
*  #include "DGRF.STR"
*  #endif
*#endif DEF_STRFILES
*RETURN b
*
*#endif


#ifdef DEF_SPC

**
** SPC - Conditions sp‚ciales
**
FUNCTION oSpc(lRebuild)
static b := NIL
if lRebuild == .t. ; b := NIL ; RETURN NIL ; endif
if b != NIL ; RETURN b ; endif
define data b name SPC ;
              postedit SpcPostEdit()
ddIndex b on  SPC->IdPar+dtos(SPC->Date) // ORD_SPC_PAR
ddIndex b on  SPC->IdArt+dtos(SPC->Date) // ORD_SPC_ART
ddFld IdPar   ,C, LenIdPar(),0 GET_PAD  ;
                      pick PickPar(NIL,SPC->IdPar)
ddFld IdArt   ,C, LenIdArt(),0 picture  PIC_ID ;
                      pick PickArt(SPC->IdArt)
ddFld _Desig  ,C,40,0 attrib V block ArtName(SPC->IdArt)
ddFld _Firme  ,C,40,0 attrib V ;
                      block padr(ParName(SPC->IdPar),40)
ddFld PrixU   ,C,10,0 GET_MONTANT
ddFld PrixT   ,C,10,0 GET_MONTANT
ddFld IdCtr   ,C, LenIdCtr(),0 picture PIC_ID pick PickCtr(SPC->IdCtr)
ddFld Date    ,D, 8,0
ddFld Remarq  ,C,30,0
ddEndDef()
RETURN b

#endif DEF_SPC

#ifdef DEF_GEN

**
** CTG - Centralisation comptes g‚n‚raux
**
FUNCTION oCtg()
static b := NIL
RETURN b if b != NIL
define data b name CTG
ddIndex b on CTG->IdGen+CTG->Periode // ORD_CTG_GEN
ddIndex b on CTG->Periode+CTG->IdGen // ORD_CTG_PER
ddFld IdGen   ,C,LenIdGen(),0 picture PIC_ID
ddFld Periode ,C,LEN_PERIODE,0 picture PIC_ID
ddFld Debit   ,T,LenMont(),0 ;
                 value val(CTG->Debit)
ddFld Credit  ,T,LenMont(),0 value val(CTG->Credit)
ddFld _Solde  ,T,LenMntF()+2,0 attrib V ;
                 block solde1( ;
                   val(CTG->Debit),val(CTG->Credit), ;
                   DevDecPos(DevDefault(CTG->Periode)) ;
                   )
ddFld _GenName,C,40,0 attrib V block padr(GenName(CTG->IdGen),40)
ddEndDef()
RETURN b

#endif DEF_GEN

#ifdef DEF_CTP

**
** CTP - Centralisation comptes particuliers
**
FUNCTION oCtp()
static b := NIL
RETURN b if b != NIL
define data b name CTP
ddIndex b on CTP->IdPar+CTP->Periode+CTP->IdCtr
ddFld IdCtr   ,C,LenIdCtr(),0 picture PIC_ID
ddFld IdPar   ,C,LenIdPar(),0 picture PIC_ID
ddFld Periode ,C,LEN_PERIODE,0 picture PIC_ID
ddFld Debit   ,T,LenMont(),0
ddFld Credit  ,T,LenMont(),0
ddFld _Solde  ,C,LenMntF()+2,0 attrib V ;
                 block solde1( ;
                   val(CTP->Debit),val(CTP->Credit), ;
                   DevDecPos(DevDefault(CTP->Periode)) ;
                   )
ddFld Umsatz  ,T,LenMont(),0
ddFld _ParName ,C,30,0 attrib V block padr(ParName(CTP->IdPar),30)
ddFld _ParPgp  ,C,LenIdPgp(),0 attrib V ;
                               block ParField(CTP->IdPar,{||PAR->IdPgp})
* #ifdef DEF_ACT
*   if IsCustData("CTP") ; ActExec("CTP") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

**
** ParCtpSum() : z.B. PAR002.REP (Gute Kunden)
**
FUNCTION ParCtpSum(cIdPar,xnValue,cIdCtr)
local nSum := 0
open area oCtp()
  softseek cIdPar + MemPer1
  do while ! eof() .and. CTP->IdPar == cIdPar ;
                   .and. CTP->Periode <= MemPer2
    if right(CTP->Periode,1) != CHR_255 .and. CTP->IdCtr == cIdCtr
      if ChkPeriode(CTP->Periode) == 0
        nSum += &xnValue
      endif
    endif
    skip
  enddo
close area
RETURN nSum

#endif DEF_CTP

#ifdef DEF_MVA

**
** CTA - Centralisation comptes analytiques
**
FUNCTION oCta()
static b := NIL
RETURN b if b != NIL
define data b name CTA
ddIndex b on CTA->IdAna+CTA->Periode // +CTA->IdJnl // ORD_CTA_ANA
ddFld AnaName ,C,40,0 attrib V block AnaName(CTA->IdAna)
ddFld IdAna   ,C,LenIdAna(),0 picture PIC_ID
ddFld Periode ,C,LEN_PERIODE,0 picture PIC_ID
ddFld Debit   ,T,LenMont(),0
ddFld Credit  ,T,LenMont(),0
ddFld _Solde  ,C,LenMntF(),0 attrib V ;
                 block solde1( ;
                   val(CTA->Debit),val(CTA->Credit), ;
                   DevDecPos(DevDefault(CTA->Periode)) ;
                   )
ddEndDef()
RETURN b

#endif DEF_MVA


FUNCTION CtrConvert()
DBN->IdCtr := DBO->CptType
RETURN .t.

*FUNCTION IpbConvert()
*DBN->IdCtr    := DBO->CptType
*DBN->GenBase  := DBO->CtrBase
** DBN->GenTaxe  := DBO->CtrTaxe
** DBN->GenTiers := DBO->CtrTiers
*RETURN .t.

FUNCTION JnlConvert()
DBN->IdCtr := DBO->CptType
DBN->IdGen := DBO->IdCfr
RETURN .t.



#ifdef DEF_REMISE

**
** RPP - Propositions de Remise par Partenaire
**
FUNCTION oRpp()
local b
define data b   ;
  name RPP      ;
  create RppCreate()
ddIndex b on RPP->IdPga+RPP->IdPgp
ddFld Seq     ,C,3,0 postedit {|x|GetSeq(x)} attrib H
ddFld IdPgp     ,C, LenIdPgp(),0 picture PIC_ID ;
                    pick PickPgp(RPP->IdPgp)
ddFld IdPga     ,C, LenIdPga(),0 picture PIC_ID ;
                    pick PickPga(RPP->IdPga)
ddFld Remise    ,C, 5,0 GET_NUM
ddEndDef()
RETURN b

FUNCTION RppCreate(cIdPgp)
local aBuf := CopyRec()
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
if cIdPgp != NIL ; RPP->IdPgp := cIdPgp ; endif
* unlock record 19980430
RETURN DDCREATE_DONE

**
** RPQ - Propositions de Remise par Quantit‚
**
FUNCTION oRpq()
local b
define data b   ;
  name RPQ      ;
  create RpqCreate()
ddIndex b on RPQ->IdRga+RPQ->IdPgp+RPQ->Seq
ddFld Seq     ,C,3,0 postedit {|x|GetSeq(x)}
ddFld IdRga     ,C, LenIdRga(),0 picture PIC_ID pick PickRga(RPQ->IdRga)
ddFld IdPgp     ,C, LenIdPgp(),0 picture PIC_ID pick PickPgp(RPQ->IdPgp)
ddFld Qte       ,C, LenQte(),0 GET_NUM
ddFld Remise    ,C, 5,0 GET_NUM
ddFld _ArtPrix  ,T, LenMont(),0 attrib V block RpqArtPrix()
ddEndDef()
RETURN b

FUNCTION RpqCreate(cIdRga,cIdPgp)
local aBuf := CopyRec()
* RETURN DDCREATE_FAIL if SeqCreate(oRpq()) == DDCREATE_FAIL
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
if cIdRga != NIL ; RPQ->IdRga := cIdRga ; endif
if cIdPgp != NIL ; RPQ->IdPgp := cIdPgp ; endif
* unlock record 19980430
* endif
RETURN DDCREATE_DONE

#endif DEF_REMISE

#ifdef DEF_BIBLIO

#ifdef LG_FRENCH
  #define MSG001  "Editeur de ~texte [F12]"
#else
  #define MSG001  "~Text-Editor        [F12]"
  #define MSG003  "~Verweise bearbeiten [F5]"
  #define MSG004  "~Zuweisungen...      [F6]"
  #define MSG005  "~Vollbild         [Enter]"
  #define MSG006  "~Ausg„nge            [F8]"
#endif

**
** OBJ - Dokumente
**
FUNCTION oObj()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name OBJ                                 ;
              predelete    ObjPreDelete() ;
              preedit   UsrPreEdit() ;
              postedit  ObjPostEdit() ;
              editprint TptDlgPrint(TPLTYPE_OBJ,NIL,"Dokumentangaben drucken") ;
              create    ObjCreate() ;
              wait {|w|ObjWait(w)}
ddIndex b on  OBJ->IdDtp + OBJ->IdObj         // DOC_ORD_ID
ddIndex b on  OBJ->IdAut + OBJ->Written       // DOC_ORD_AUT
ddIndex b on  OBJ->IdRub + OBJ->Place         // DOC_ORD_RUB
ddIndex b on  OBJ->IdGrp + OBJ->Written       // DOC_ORD_GRP
ddFld IdObj    ,C, LenIdArt(),0 when .f.
ddFld IdRub    ,C, LenIdRub(),0 pick RubPick(OBJ->IdRub) ;
                               valid ObjRubValidate()
ddFld IdAut    ,C, LEN_IDAUT,0 picture PIC_ID ;
                               pick AutPick(OBJ->IdAut) ;
                               valid ph_refresh()
ddFld IdDtp    ,C, LEN_IDDTP,0 picture PIC_ID when .f.
ddFld Name     ,C,60,0 picture "@S30"
ddFld Langue   ,C, 3,0 picture PIC_ID pick PickLng(OBJ->Langue)
ddFld Format1  ,C,4,0
ddFld NbPages ,C,4,0 GET_NUM
ddFld Attrib  ,C,10,0 picture PIC_ID pick PickDca(OBJ->Attrib)
ddFld Written ,C, 8,0 picture PIC_ID
ddFld LastUp  ,D, 8,0 when .f.
ddFld Format2  ,C,4,0
ddFld Memo    ,M,10,0
ddFld _Autor  ,C,LEN_AUTNAME,0 attrib V block AutName(OBJ->IdAut)
ddFld _Rubrik ,C,LEN_RUBNAME,0 attrib V block RubName(OBJ->IdRub)
ddFld _DocTyp ,C,LEN_DTPNAME,0 attrib V ;
                 block padr(DtpTitel(OBJ->IdDtp),LEN_DTPTITEL)
ddFld IdGrp   ,C,LEN_IDGRP,0   pick GrpPick(OBJ->IdGrp) ;
                               when indexord() != DOC_ORD_GRP ;
                               valid ph_refresh()
ddFld _Gruppe ,C,LEN_GRPNAME,0 attrib V ;
                      block padr(GrpName(OBJ->IdGrp),LEN_GRPNAME)
ddFld Place    ,C,6,0
ddFld Name2    ,C,60,0 picture "@S30"
ddFld IdUsr    ,C,LenIdUsr(),0 picture PIC_ID
action b key K_F5     prompt MSG003 ;
                      block ObjRefEdit(OBJ->IdDtp,OBJ->IdObj)
* action b key K_F6     prompt MSG004 block DocZusatz()
action b key K_ALT_F2 prompt MSG_RENAME block ObjRename()
action b key K_F12    prompt MSG001 block ObjMemoEdit()
action b key K_F8     prompt MSG006 block ObjOutEdit(OBJ->IdDtp,OBJ->IdObj)
* #ifdef DEF_ACT
*   if IsCustData("OBJ") ; ActExec("OBJ") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

FUNCTION ObjRubValidate()
if ! empty(OBJ->IdRub)
  RETURN .f. if ! RubExist(OBJ->IdRub)
endif
RETURN ph_refresh()

* FUNCTION DocIdDocF(cIdDtp,cIdDoc)
* local dtp := DtpLocate(cIdDtp)
* local cId := ""
* RETURN cIdDoc if dtp == NIL
* if dtp[DTP_LENPRE] > 0
*   cId += left(cIdDoc,dtp[DTP_LENPRE]) + "-"
* endif
* cId += substr( ;
*   cIdDoc, ;
*   dtp[DTP_LENPRE]+1, ;
*   LEN_IDDOC-dtp[DTP_LENPRE]-dtp[DTP_LENSUF] ;
* )
* if dtp[DTP_LENSUF] > 0
*   cId += "." + right(cIdDoc,dtp[DTP_LENSUF])
* endif
* RETURN cId


**
** AUT - Auteurs
**
FUNCTION oAut()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name AUT                                 ;
              preedit   UsrPreEdit() ;
              editprint TptDlgPrint("AUT",NIL,"Autor drucken") ;
              create    AutCreate() ;
              predelete    AutPreDelete() ;
              wait      {|w| AutWait(w) }

ddIndex b on  AUT->IdAut                      // AUT_ORD_ID
ddIndex b on  upper(AUT->Name) format {|x|upper(x)}    // AUT_ORD_NAME
ddFld IdAut    ,C, LEN_IDAUT,0 when .f.
ddFld Name     ,C,25,0
ddFld Vorname  ,C,20,0
ddFld Langue   ,C, 3,0 picture PIC_ID pick PickLng(AUT->Langue)
ddFld Born    ,C,10,0
ddFld Died    ,C,10,0
ddFld Bemerk  ,C,40,0
ddFld Memo    ,M,10,0
action b key K_F12 prompt MSG001 block AutTxtEdit()
action b key K_ENTER prompt MSG_DOCEDIT block AutObjEdit(AUT->IdAut)
ddEndDef()
RETURN b

**
** RUB - Rubriken
**
FUNCTION oRub()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name RUB                                 ;
              preedit   UsrPreEdit() ;
              editprint TptDlgPrint("RUB",NIL,"Rubrik drucken") ;
              create    RubCreate()  ;
              wait      {|w| AutWait(w) }
ddIndex b on  RUB->IdRub
ddIndex b on  RUB->Regal+RUB->IdRub
ddFld IdRubS   ,C,LenIdRub()*2-1,0 attrib V ;
                                  block IdStruct(RUB->IdRub,1)
ddFld Name     ,C,40,0
ddFld IdRub    ,C, LenIdRub(),0 when .f.
ddFld Regal    ,C, 6,0 picture PIC_ID
ddFld Bemerk   ,C,60,0
ddFld Memo     ,M,10,0
action b key K_ENTER  prompt MSG_DOCEDIT block RubObjEdit(RUB->IdRub)
action b key K_ALT_F2 prompt MSG_RENAME  block RubRename()
action b key K_F12 prompt MSG001 block RubTxtEdit()
* #ifdef DEF_ACT
*   if IsCustData("RUB") ; ActExec("RUB") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

**
** DTP - Dokument-Arten
**
FUNCTION oDtp()
local b
define data b name DTP ;
            preedit   UsrPreEdit() ;
            create DtpCreate()
ddIndex b on  DTP->Seq
ddFld IdDtp    ,C, LEN_IDDTP,0 picture PIC_ID
ddFld Name     ,C, LEN_DTPNAME,0 postedit {|x| ValPrompt(x) }
ddFld Titel    ,C, LEN_DTPTITEL,0
ddFld Attrib   ,C, 6,0 picture PIC_ID pick PickDtpAttrib(DTP->Attrib)
ddFld LenPre   ,C, 2,0 GET_NUM
ddFld LenSuf   ,C, 2,0 GET_NUM
ddFld Seq     ,C,3,0 postedit {|x|GetSeq(x)}
ddEndDef()
RETURN b

**
** RTP - Referenz-Arten
**
* FUNCTION oRtp()
* local b
* define data b name RTP
* ddIndex b on  RTP->IdRtp
* ddFld IdRtp    ,C, LEN_IDRTP,0 picture PIC_ID when .f.
* ddFld Name     ,C,LEN_RTPNAME,0
* ddFld IdDtp    ,C,15,0 picture PIC_ID pick DtpPick(RTP->IdDtp)
* ddFld Titel    ,C,LEN_RTPTITEL,0
* #ifdef LG_GERMAN
* #include "RTPD.STR"
* #else
* #include "RTPF.STR"
* #endif
* RETURN b

**
** GRP - Interessengruppen
**
FUNCTION oGrp()
local b
define data b name GRP ;
            preedit   UsrPreEdit() ;
            create GrpCreate()
ddIndex b on  GRP->IdGrp
ddIndex b on  upper(GRP->Name)
ddFld IdGrp    ,C,LEN_IDGRP,0 picture PIC_ID when .f.
ddFld Name     ,C,LEN_GRPNAME,0
ddFld Bemerk   ,C,40,0
action b key K_ENTER prompt MSG_DOCEDIT block GrpObjEdit(GRP->IdGrp)
*#ifdef LG_GERMAN
*#include "GRPD.STR"
*#else
*#include "GRPF.STR"
*#endif
ddEndDef()
RETURN b


**
** NTS - Notizen (Stichworte,...)
**
FUNCTION oNts()
local b
define data b name NTS ;
            preedit   UsrPreEdit() ;
            preDelete    NtsPreDelete() ;
            wait NtsWait()
            * queries 2
ddIndex b on  NTS->IdNts              // ORD_NTS_ID
ddIndex b on  upper(NTS->Name)        // ORD_NTS_NAME
ddFld IdNts    ,C,LenIdNts(),0 picture PIC_ID when .f.
ddFld Name     ,C,LEN_NTSNAME,0
ddFld Memo     ,M,10,0
ddFld Date     ,D, 8,0
action b key K_F5  prompt MSG003 block NtsRefEdit(NTS->IdNts)
action b key K_F12 prompt MSG001 block NtsTxtEdit()
ddEndDef()
RETURN b


**
** REF - Referenzen
**
FUNCTION oRef()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name REF                                 ;
              preDelete .t. // DDDEL_NOCONFIRM
              * queries 2
ddIndex b on  REF->IdDtp+REF->IdObj
ddIndex b on  REF->IdNts
ddFld IdDtp    ,C, LEN_IDDTP,0
ddFld IdObj    ,C, LenIdArt(),0
ddFld IdNts    ,C, LenIdNts(),0
ddFld _ObjName ,C, 60,0 attrib V ;
                   block padr(ObjExtName(REF->IdDtp,REF->IdObj),60)
ddFld _RefName ,C, LEN_NTSNAME,0 attrib V ;
                   block padr(NtsName(REF->IdNts),LEN_NTSNAME)
action b key K_F12   prompt MSG001 block RefTxtEdit()
action b key K_ENTER prompt MSG005 block ObjPage(REF->IdDtp,REF->IdObj)
ddEndDef()
RETURN b


*FUNCTION DocTitel(cId)
*if OBJ->IdDtp + OBJ->IdDoc != cId
*  seek cId in OBJ
*endif
*RETURN OBJ->Name
*
*FUNCTION DocAutor(cId)
*if OBJ->IdDtp + OBJ->IdDoc != cId
*  seek cId in OBJ
*endif
*RETURN AutName(OBJ->IdAut)
*
*FUNCTION DocDtp(cId)
*if OBJ->IdDtp + OBJ->IdDoc != cId
*  seek cId in OBJ
*endif
*RETURN DtpName(OBJ->IdDtp)

FUNCTION RubName(cId)
if cId != NIL
  if RUB->IdRub != cId
    seek cId in RUB
  endif
endif
RETURN left(RUB->Name,LEN_RUBNAME)

FUNCTION AutName(cId)
if cId != NIL
  if AUT->IdAut != cId
    seek cId in AUT
  endif
endif
RETURN padr(trim1(AUT->Vorname) + AUT->Name,LEN_AUTNAME)

FUNCTION AutLangue(cId)
if AUT->IdAut != cId
  seek cId in AUT
endif
RETURN AUT->Langue

**
** ObjPostEdit()
**
FUNCTION ObjPostEdit()
if ! empty(OBJ->IdRub)
  RETURN .f. if ! RubExist(OBJ->IdRub)
endif
RETURN .t.

FUNCTION RubExist(cIdRub)
RETURN .t. if RUB->IdRub == cIdRub
seek cIdRub in RUB
RETURN .t. if RUB->IdRub == cIdRub
SetMsg(cIdRub + " : unbekannte Rubrik !")
RETURN .f.

* FUNCTION DocZusatz
* RETURN .f. if ! ddRecLock()
* DocPickZusatz()
* unlock
* RETURN MnuDone()

**
** DocPickZusatz
**
*FUNCTION DocPickZusatz()
*local cIdAut
*local cIdRub
*local cIdDtp
*local cIdGrp
*local cIdDst
*local cAttrib := DtpAttrib(OBJ->IdDtp)
*if DTPATTR_A $ cAttrib .and. indexord() != DOC_ORD_AUT
*  if(cIdAut := AutPick(OBJ->IdAut)) != NIL ; OBJ->IdAut := cIdAut ; endif
*endif
*if DTPATTR_R $ cAttrib .and. indexord() != DOC_ORD_RUB
*  if(cIdRub := RubPick(OBJ->IdRub)) != NIL ; OBJ->IdRub := cIdRub ; endif
*endif
*if DTPATTR_G $ cAttrib .and. indexord() != DOC_ORD_GRP
*  if(cIdGrp := GrpPick(OBJ->IdGrp)) != NIL ; OBJ->IdGrp := cIdGrp ; endif
*endif
** if empty(OBJ->IdDst) ;
**    .or. (DTPATTR_B $ cAttrib .and. indexord() != DOC_ORD_DST)
**   if (cIdDst := PickDst(OBJ->IdDst)) != NIL
**     OBJ->LastUp := UserDate()
**     OBJ->IdDst  := cIdDst
**     OBJ->IdUsr  := UserId()
**   endif
** endif
*RETURN MnuDone()

FUNCTION ObjPreDelete()
local cId := OBJ->IdDtp + OBJ->IdObj
local lOkay := .f. // nReturn := DDDEL_FAIL
RETURN .f. if ! Confirm( ;
  "J um " + DtpTitel(OBJ->IdDtp) ;
  + " '" + trim(OBJ->Name) + "' zu l”schen :" ;
)
open area oRef()
  lOkay := .t. // nReturn := DDDEL_NOCONFIRM
  ddSetOrder(ORD_REF_DOC)
  softseek cId
  do while ! eof() .and. REF->IdDtp + REF->IdObj == cId
    if ddRecLock()
      delete
      softseek cId
    else
      lOkay := .f. // nReturn := DDDEL_FAIL
      exit
    endif
  enddo
close area
RETURN lOkay // nReturn



FUNCTION NtsPreDelete()
local cId := NTS->IdNts
local lOkay := .f. // nReturn := DDDEL_FAIL
RETURN .f. if ! Confirm( ;
  "J um Stichwort '" + trim(NTS->Name) + "' zu l”schen :" ;
)
open area oRef()
  lOkay := .t. // nReturn := DDDEL_NOCONFIRM
  ddSetOrder(ORD_REF_NTS)
  softseek cId
  do while ! eof() .and. REF->IdNts == cId
    if ddRecLock()
      delete
      softseek cId
    else
      lOkay := .f. // nReturn := DDDEL_FAIL
      exit
    endif
  enddo
close area
RETURN lOkay // nReturn



FUNCTION NtsWait
local i := 0
local cMemo := ""
if ! empty(NTS->Memo)
  cMemo += NTS->Memo + CR_LF
endif
cMemo += "Verweist auf Dokumente : "
open area oRef(), oObj(), oAut()
  ddSetOrder(ORD_REF_NTS)
  softseek NTS->IdNts
  do while REF->IdNts == NTS->IdNts
    i++
    cMemo += ObjExtName(REF->IdDtp,REF->IdObj) + ', '
    skip
  enddo
close area
if i == 0
  cMemo += "(keine)"
endif
MemoDisplay(cMemo,7,2,15,76)
RETURN NIL

FUNCTION ObjWait(wwin)
local i := 0
local cIdDtp := OBJ->IdDtp
local cIdObj := OBJ->IdObj
local cMemo := ""
if wwin[WIN_WAITKEY] == 12
  if ! empty(OBJ->Memo)
    cMemo += OBJ->Memo + CR_LF
  endif
  cMemo += "Verweise : "
  open area oRef(), oNts()
    softseek cIdDtp + cIdObj
    do while REF->IdDtp == cIdDtp .and. REF->IdObj == cIdObj
      i++
      cMemo += NtsName(REF->IdNts) + ', '
      skip
    enddo
  close area
  if i == 0
    cMemo += "(keine)"
  endif
* MemoDisplay(cMemo,10,2,12,76)
  MemoDisplay(cMemo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
endif
RETURN NIL

FUNCTION AutWait(wwin)
if wwin[WIN_WAITKEY] == 12
  MemoDisplay(FIELD->Memo, ;
    wwin[WIN_TOP], ;
    wwin[WIN_LEFT], ;
    wwin[WIN_HEIGHT], ;
    wwin[WIN_WIDTH] ;
  )
endif
RETURN NIL

FUNCTION UsrPreEdit()
RETURN .t. if ! USRATTR_L $ UsrAttrib()
SetMsg(trim(UserId()) + " : Žnderungen nicht erlaubt !")
RETURN .f.

FUNCTION ObjPage(cIdDtp,cIdObj)
local b := oObj()
open area b, oRub(), oAut()
  seek cIdDtp + cIdObj
  edit data b title (cIdDtp + cIdObj) ;
              full ;
              noskip ;
              query "OBJDTP"
close area
RETURN MnuDone()

**
** OUT - Ausg„nge
**
FUNCTION oOut()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name OUT                                 ;
              preedit   UsrPreEdit()
ddIndex b on  OUT->IdPar+dtos(OUT->Date) // ORD_AUT_PAR
ddIndex b on  OUT->IdDtp+OUT->IdObj+dtos(OUT->Date) // ORD_AUT_DOC
ddFld IdPar   ,C, LenIdPar(),0 when .f.
ddFld IdDtp   ,C, LEN_IDDTP,0 when .f.
ddFld IdObj   ,C, LenIdArt(),0 when .f.
ddFld Date    ,D, 8,0
ddFld Back    ,D, 8,0
ddFld Memo    ,M,10,0
ddFld _ObjName ,C, 50,0 attrib V ;
                   block padr(ObjExtName(OUT->IdDtp,OUT->IdObj),50)
ddFld Attrib , C,5,0 picture PIC_ID pick PickOat(OUT->Attrib)
action b key K_F12 prompt MSG001 block OutTxtEdit()
ddEndDef()
RETURN b

#endif DEF_BIBLIO

#ifdef DEF_VEN
#ifdef DEF_ART

**
** IPR
**
FUNCTION oIpr()
local b
define data b   ;
  name IPR      ;
  create SeqCreate(oIpr()) ;
  attrib K
ddIndex b on IPR->Seq
ddFld Seq     ,C,3,0 postedit {|x|GetSeq(x)}
ddFld IdCtr     ,C, LenIdCtr(),0 picture PIC_ID ;
                                 pick PickCtr(IPR->IdCtr)
ddFld IdPrt     ,C,LEN_IDPRT,0   picture PIC_ID ;
                                 pick PickPrt(NIL,NIL,IPR->IdPrt,PRT_ID)
ddFld IdPgp     ,C, LenIdPgp(),0 picture PIC_ID ;
                                 pick PickPgp(IPR->IdPgp)
ddFld IdDev     ,C, LEN_IDDEV,0  picture PIC_ID ;
                                 pick PickDev(IPR->IdDev)
ddFld PrixU     ,C, 128,0
ddFld Attrib    ,C, 3,0          picture PIC_ID ;
                                 pick PickIprAttrib(IPR->Attrib)
ddEndDef()
RETURN b

#endif DEF_ART
#endif DEF_VEN


#ifdef DEF_CFN

FUNCTION LenIdCfn() ; RETURN 1

***
*** CFN
***
*FUNCTION oCfn()
*local b
*define data b   ;
*  name CFN
*ddIndex b on CFN->IdCfn
*ddFld IdCfn     ,C, LenIdCfn(),0 picture PIC_ID
*ddFld IdPar     ,C, LenIdPar(),0 GET_PAD  ;
*                    pick PickPar(NIL,CFN->IdPar)
*ddFld Attrib    ,C, 3,0       picture PIC_ID
*RETURN b
*
*FUNCTION CfnIdPar(cIdCfn)
*RETURN DbfPeek(oCfn(),cIdCfn,"CFN->IdPar",space(LenIdPar()))

#define ORD_PAR_IDCFN 5

FUNCTION CfnExist(cIdCfn)
local lOkay := .f.
if empty(cIdCfn)
  SetMsg("Code fournisseur : obligatoire !")
  RETURN .f.
endif
open area oPar()
  ddSetOrder(ORD_PAR_IDCFN)
  seek cIdCfn
  if eof()
    SetMsg(cIdCfn + " : code fournisseur inconnu !")
  else
    lOkay := .t.
  endif
close area
RETURN lOkay

FUNCTION ParCfnValidate(cIdCfn)
local lOkay := .f.
local nRecNo := recno()
open area oPar()
  lOkay := .t.
  ddSetOrder(ORD_PAR_IDCFN)
  softseek cIdCfn
  do while PAR->IdCfn == cIdCfn .and. ! eof()
    if recno() != nRecNo
      SetMsg( ;
        cIdCfn + ;
        " : code fournisseur d‚j… utilis‚ pour " + ;
        trim(ParName()) ;
      )
      lOkay := .f.
    endif
    skip
  enddo
close area
RETURN lOkay

FUNCTION PickCfn(cStart,cTitle)
RETURN DbfPick( ;
  {oPar(),oPlz(),oNat()}, ;
  cTitle, ;
  "PARCFN", ;
  cStart, ;
  NIL,NIL,NIL, ;
  "PAR->IdCfn", {||DDCREATE_FAIL} ;
)

FUNCTION CfnField(cIdCfn,xuReturn)
local cName
open area oPar()
  ddSetOrder(ORD_PAR_IDCFN)
  seek cIdCfn
  cName := &xuReturn
close area
RETURN cName

#endif DEF_CFN

#ifdef DEF_MVA

**
** ODA - Documents OD analytiques
**
FUNCTION oOda()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                 ;
  name ODA                    ;
  preedit    OdaPreEdit()     ;
  postedit   OdaPostEdit()    ;
  predelete     OdaPreDelete()      ;
  editprint  OdaPrint()       ;
  wait       {|x| OdaWait(x)}
ddIndex b on  ODA->IdJnl+ODA->IdDoc
ddFld IdJnl   ,C, LenIdJnl(),0  when .f.
ddFld IdDoc   ,C, LenIdDoc(),0  when .f.
ddFld Date    ,D,  8,0
ddFld IdGen   ,C, LenIdGen(),0 picture PIC_ID pick PickGen(NIL,ODA->IdGen)
ddFld Remarq  ,C, 30,0
ddFld Etat    ,C,  1,0  when .f. picture "!"
ddFld _Status  , C,10,0 attrib V block EtatText(ODA->Etat)
ddFld Periode ,C,  LEN_PERIODE,0  picture PIC_ID ;
                   pick PickPer(ODA->Periode,ODA->IdJnl)
ddFld IdPar   ,C, LenIdPar(),0  GET_PAD ;
                        pick PickPar( ;
                          NIL, ;
                          ODA->IdPar)
action b key K_ENTER   prompt MnuInhalt() block OdaMvaEdit()
action b key K_CTRL_F2 prompt MnuClose() ;
                       block TryRecLock({||OdaDlgClose(.t.)})
ddEndDef()
RETURN b

#endif DEF_MVA

#ifdef DEF_FIN

**
** FIN - Documents financiers
**
FUNCTION oFin()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                 ;
  name FIN                    ; // 20070525  preedit    FinPreEdit()     ;
  postedit   FinPostEdit()    ;
  predelete     FinPreDelete()      ;
  editprint  FinPrint()       ;
  wait       {|x| FinWait(x)}
  * convert    FinConvert() ;
ddIndex b on  FIN->IdJnl+FIN->IdDoc ;
              format {|x|left(x,LenIdJnl())+ ;
                GetIdDoc( ;
                  substr(x,LenIdJnl()+1), ;
                  JnlLocate(left(x,LenIdJnl())) ;
                ) ;
              }            // ORD_VEN_ID
ddFld IdJnl   ,C, LenIdJnl(),0  when .f.
ddFld IdDoc   ,C, LenIdDoc(),0  when .f.
ddFld Date    ,D,  8,0 valid DocDateValidate() when FinPreEdit()
ddFld Remarq  ,C, 30,0
ddFld _Status  , C,10,0 attrib V block EtatText(FIN->Etat)
ddFld Cours   ,C, 10,0  GET_NUM ;
      when FinPreEdit().and.!PerDevFixed(FIN->Periode,FIN->IdDev) ;
      valid CoursValidate(JnlIdDev(FIN->IdJnl))
ddFld Etat    ,C,  1,0  when .f. picture "!"
ddFld Periode ,C,  LEN_PERIODE,0  picture PIC_ID ;
                   when FinPreEdit() ;
                   pick PickPer(FIN->Periode,FIN->IdJnl) ;
                   valid DocPerValidate()
ddFld Mont1   ,T, LenMont(),0  valid FinMont1Validate() ;
                               when FinPreEdit() ;
                               pick PickNum(FIN->Mont1)
ddFld Mont2   ,T, LenMont(),0  valid FinMont2Validate() ;
                               when FinPreEdit() ;
                               pick PickNum(FIN->Mont2)
ddFld IdDev   ,C, LEN_IDDEV ,0  picture PIC_ID ;
                                when FinPreEdit() ;
                                pick PickDev(FIN->IdDev) ;
                                valid DocDevValidate().and.ddRefreshCurrent()
action b key K_ENTER   prompt MnuInhalt() block FinFnlEdit()
action b key K_CTRL_F2 prompt MnuClose() block FinDlgClose()
action b key K_CTRL_F5 prompt NIL block FinReset(FIN->IdJnl,FIN->IdDoc)
action b key K_CTRL_F9 prompt MnuDocHstEdit() block DocHstEdit(FIN->IdJnl,FIN->IdDoc)
action b key K_F9 prompt MnuHstEdit() ;
         block GenHstEdit(JnlField(FIN->IdJnl,JNL_IDGEN))
* #ifdef DEF_TOOLBOX
*   action b key K_ALT_F2 block FinRename() ;
*                         when USRATTR_E $ UsrAttrib()
* #endif
ddEndDef()
RETURN b

FUNCTION FinMont1Validate()
local nDecPos := DevDecPos(FIN->IdDev)
if FIN->Etat == DocStatOpen()
  FIN->Etat := DocStatNew()
endif
FIN->Mont1 := GetNum(FIN->Mont1,nDecPos,nDecPos)
RETURN .t.

FUNCTION FinMont2Validate()
local nDecPos := DevDecPos(FIN->IdDev)
if FIN->Etat == DocStatOpen()
  FIN->Etat := DocStatNew()
endif
* FIN->Mont2 := ntom(val(FIN->Mont2),DevDecPos(JnlIdDev(FIN->IdJnl)))
FIN->Mont2 := GetNum(FIN->Mont2,nDecPos,nDecPos)
RETURN .t.


**
** FNL - D‚tail journaux financiers
**
FUNCTION oFnl()
* local b
static b := NIL
RETURN b if b != NIL
define data b           ;
  name FNL                   ;
  postedit FnlPostEdit() ;
  preDelete .t. // DDDEL_NOCONFIRM
ddIndex b on FNL->IdJnl+FNL->IdDoc+FNL->Line
ddIndex b on FNL->IdCtr+FNL->IdCpt
ddFld IdJnl  ,C, LenIdJnl(),0  when .f.
ddFld IdDoc  ,C, LenIdDoc(),0  when .f.
ddFld Line   ,C, LEN_POS,0 postedit {|x|GetId(x,3,0)}
ddFld Date   ,D,  8,0
ddFld _IdPar ,C, LenIdPar(),0  ;
                 picture PIC_ID attrib V ;
                 block {|x| GsbFnlIdPar(x) } ;
                 valid FnlParValidate() ;
                 when .t. ;
                 pick FnlPickPar()
ddFld IdCtr ,C,  LenIdCtr(),0  picture PIC_ID  ;
                 pick PickCtr(FNL->IdCtr) ;
                 valid FnlCtrValidate()
ddFld IdCpt ,C,  LenCompte(),0  picture PIC_ID
ddFld _CptName ,C, 30,0 attrib V ;
                        block padr(CptName(FNL->IdCtr,FNL->IdCpt),30)
ddFld Libell ,C, LenFnlName(),0  valid NB2Validate(FNL->Libell)
ddFld _IdGen ,C, LenIdGen(),0  ;
                 picture PIC_ID attrib V ;
                 block {|x| GsbFnlIdGen(x) } ;
                 valid FnlGenValidate() ;
                 pick PickGen(NIL,FNL->IdCpt,"!'"+GENATTR_H+"'$GEN->Attrib") ;
                 when .t.
ddFld Mont   ,T, LenMont(),0  GET_MONTANT ;
                       valid FnlMontValidate()
ddFld _Debit ,T, LenMont(),0 GET_DECPOS(DevDecPos(DevDefault(FIN->Periode))) ;
                             attrib V ;
                             when .t. ;
                             valid FnlMontValidate() ;
                             block {|x| GsbFnlMont(DC_DEBIT,x) }
ddFld _Credit,T, LenMont(),0  GET_DECPOS(DevDecPos(DevDefault(FIN->Periode))) ;
                              attrib V ;
                              when .t. ;
                              valid FnlMontValidate() ;
                              block {|x| GsbFnlMont(DC_CREDIT,x) }
ddFld Match  ,C,LenIdJnl()+LEN_IDDOC,0 ;
                       picture PIC_ID ;
                       pick FnlPickMatch() ;
                       valid FnlMatchValidate()
ddFld _Libell ,C, LenFnlName(),0 attrib V when .t. ;
                       block {|x|GsbFnlLibell(x)}
ddFld DC      ,C, 1,0  picture PIC_ID valid DcValidate(FNL->DC)
ddFld MontDev ,T, LenMont(),0 ;
                       pick PickNum(FNL->MontDev) ;
                       valid FnlMDValidate()
#ifdef DEF_ANAFIN
  ddFld IdAna     ,C, LenIdAna(),0 picture PIC_ID ;
                    block {|x| GsbIdAna(x) } ;
                    pick PickAna(FNL->IdAna)
#else
  ddFld IdAna     ,C, 0,0 attrib H
#endif
ddFld _DevDebit ,T, LenMont(),0  GET_DECPOS(FnlDevDecPos()) attrib V ;
                    when .t. ;
                    valid FnlMDValidate() ;
                    block {|x| GsbFnlDev(DC_DEBIT,x) }
ddFld _DevCredit,T, LenMont(),0  GET_DECPOS(FnlDevDecPos()) attrib V ;
                    when .t. ;
                    valid FnlMDValidate() ;
                    block {|x| GsbFnlDev(DC_CREDIT,x) }
ddFld IdDev    ,C, LEN_IDDEV,0 picture PIC_ID ;
                   pick PickDev(FNL->IdDev) ;
                   valid FnlDevValidate() ;
                   when FnlDevPreEdit()
action b key K_F5      prompt MnuDocCopy() block FnlCopy()
action b key K_SH_F5   prompt MnuParPage() block FnlParPage(FNL->IdCpt) ;
                                     when ! empty(FNL->IdCpt)
#ifdef DEF_HST
  action b key K_F9   prompt MnuHstEdit() ;
           block CptHstEdit(FNL->IdCtr,FNL->IdCpt)
#endif DEF_HST
ddEndDef()
RETURN b


FUNCTION FnlCtrValidate()
local ctr
RETURN .t. if empty(FNL->IdCtr)
if (ctr := CtrLocate(FNL->IdCtr)) == NIL
  SetMsg(FNL->IdCtr + MsgCtrExist())
  RETURN .f.
endif
* if empty(FNL->IdCpt)
*   FNL->IdCpt := ctr[CTR_IDPAR]
* endif
RETURN .t.


FUNCTION FnlParPage()
if empty(FNL->IdCtr) //  == CPTTYPE_GEN
  GenPage(left(FNL->IdCpt,LenIdGen()))
else
  ParPage(left(FNL->IdCpt,LenIdPar()))
endif
RETURN MnuDone()

FUNCTION FnlPickMatch
local a := NIL
local bReturn := {||{ HST->Match, HST->IdCtr, HST->IdGen,HST->IdPar}}
if empty(FNL->IdCtr)
  a := PickHstGen(left(FNL->IdCpt,LenIdGen()),FNL->Match,bReturn)
else
  a := PickHstPar(left(FNL->IdCpt,LenIdPar()),FNL->Match,bReturn,NIL,FNL->IdCtr)
endif
RETURN NIL if a == NIL
FNL->IdCtr := a[2]
if empty(a[2])
  FNL->IdCpt := a[3]
else
  FNL->IdCpt := a[4]
endif
FNL->Mont := ""
FNL->MontDev := ""
FNL->IdDev := ""
RETURN a[1]

FUNCTION FnlPickPar
local cIdPrt := trim(FNL->IdCpt)
local cIdPar := left(FNL->IdCpt,LenIdPar())
if len(cIdPrt) == 1
  cIdPar := NIL
else
  cIdPrt := NIL
endif
RETURN PickPar(cIdPrt,FNL->IdCpt)


FUNCTION FnlConvert()
DBN->Line  := right(DBO->IdOp,LEN_POS)
DBN->IdCtr := DBO->CptType
RETURN .t.

#else

FUNCTION oFnl() ; RETURN NIL

#endif DEF_FIN

**
** NAT
**
FUNCTION oNat()
local b
define data b   ;
  name NAT
ddIndex b on NAT->IdNat
ddFld IdNat     ,C,LEN_IDNAT,0 picture PIC_ID
ddFld Name      ,C,40,0
ddFld Intra     ,C, 3,0 picture PIC_ID
ddFld IdLng     ,C, LenIdLng(),0 pick PickLng(NAT->IdLng) ;
                picture PIC_ID
ddFld IdTlf     ,C, 1,0 pick PickTlf(NAT->IdTlf) ;
                picture PIC_ID
ddFld TelPrefix ,C, 6,0
ddFld TvaPrefix ,C, 3,0 picture PIC_ID
ddFld IdDev     ,C,LEN_IDDEV ,0 picture PIC_ID  ;
                pick PickDev(NAT->IdDev)
ddFld TvaPict   ,C,25,0
ddFld Attrib    ,C, 5,0 picture PIC_ID ;
                pick PickDbcAttr("NATATTR.DBC",NAT->Attrib)
ddFld IdReg     ,C,LEN_IDREG,0  picture PIC_ID ;
                                pick PickReg(NAT->IdReg)
ddFld IsoCode   ,C, 2,0 picture PIC_ID
action b key K_ENTER   block NatPlzEdit(NAT->IdNat)
ddEndDef()
RETURN b



FUNCTION NatExist(cId)
if NAT->IdNat == cId .and. ! (eof() in NAT)
  RETURN .t.
endif
seek cId in NAT
if eof() in NAT
  SetMsg(cId + MsgNatExist())
  RETURN .f.
endif
RETURN .t.

FUNCTION MsgNatExist()
#ifdef LG_FRENCH
  RETURN " : Pays inconnu !"
#else
  RETURN " : unbekanntes Land !"
#endif



FUNCTION NatIdDev(cIdNat)
RETURN NatField(cIdNat,"IdDev")

FUNCTION NatIntra(cIdNat)
RETURN NatField(cIdNat,"Intra")

FUNCTION Nat2iso(cIdNat)
cIdNat := alltrim(cIdNat)
RETURN "BE" if cIdNat == "B"
RETURN "DE" if cIdNat == "D"
RETURN "FR" if cIdNat == "F"
RETURN "LU" if cIdNat == "L"
RETURN "NL" if cIdNat == "NL"
RETURN "EE" if cIdNat == "EE"
RETURN NatCountry(padr(cIdNat,3))


/*
 returns the ISO 2-letter country code
*/
FUNCTION NatCountry(cIdNat)
RETURN NatField(cIdNat,"if(empty(NAT->IsoCode),NAT->IdNat,NAT->IsoCode)")

FUNCTION NatName(cIdNat)
RETURN NatField(cIdNat,"NAT->Name")

FUNCTION NatField(cIdNat,xuField)
local uReturn // := ""
open area oNat()
  seek cIdNat
  uReturn := &xuField
close area
RETURN uReturn


FUNCTION PickNat(cStart,cTitle,xuReturn)
default cTitle to "Auswahl Land"
default xuReturn to "NAT->IdNat"
RETURN DbfPick({oNat()},cTitle,"NATPICK",cStart,NIL,NIL,NIL,xuReturn)


**
** PickNat()
**
*FUNCTION PickNat( cStart, cTitle )
*local cIdNat := NIL
*local b := oNat()
*local nStart := 1 // DDSTART_TOP
*default cStart to ""
*default cTitle to "Auswahl Land"
*open area b
*  softseek trim(cStart)
*    edit data   b ;
*         mode   pick ;
*         query  ("NATPICK") ;
*         title  (cTitle)
*  if ddLastReq() == DDEDIT_SELECT
*    cIdNat := NAT->IdNat
*  endif
*close area
*RETURN cIdNat





#ifdef DEF_RUN

**
** CAT
**
FUNCTION oCat()
local b
define data b   ;
  name CAT ;
  create DupRecord()
ddIndex b on CAT->IdCty+CAT->Seq
ddFld IdCty     ,C,LenIdCty(),0 picture PIC_ID
ddFld Seq       ,C,3,0 postedit {|x|GetSeq(x)}
ddFld IdCat     ,C,LenIdCat(),0 picture PIC_ID
ddFld Sex       ,C, 1,0 picture PIC_ID
ddFld MaxAge    ,C,3,0 GET_NUM
ddFld Name      ,C,40,0
ddFld Header    ,C,120,0 picture "@k@s30"
ddEndDef()
RETURN b

* FUNCTION GetSeq(x)
* local nLen := len(x)
* RETURN x if val(x) == 0
* RETURN padl(alltrim(x),nLen,"0")

**
** DupRecord()
**
FUNCTION DupRecord()
local aBuf := CopyRec()
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
RETURN DDCREATE_REFRESH


**
** CTY
**
FUNCTION oCty()
local b
define data b   ;
  name CTY ;
  create CtyCreate()
ddIndex b on CTY->IdCty
ddFld IdCty     ,C,LenIdCty(),0 picture PIC_ID
ddFld Name      ,C,40,0
ddFld Header    ,C,10,0
ddFld Footer    ,C,10,0
action b prompt "~Cat‚gories par Type " ;
         block CtyCatEdit(CTY->IdCty) ;
         key K_ENTER
ddEndDef()
RETURN b

FUNCTION CtyCreate()
local a := {}
local i
local cIdCty := CTY->IdCty
local cIdCtyOld := CTY->IdCty
open window "Nouveau systŠme de cat‚gories" size 4,50
do while .t. // ! AppTerminate()
  WinHome()
  say "Identification : "
  get cIdCty picture PIC_ID
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cIdCty)
  * seek cIdCty
  * if found()
    SetMsg(cIdCty + " : " + MsgIdExist() )
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
CTY->IdCty := cIdCty
open area oCat()
  softseek cIdCtyOld
  do while ! eof() .and. CAT->IdCty == cIdCtyOld
    aadd(a,CopyRec())
    skip
  enddo
  for i := 1 to len(a)
    if dbAddRec()
      PasteRec(a[i])
      CAT->IdCty := cIdCty
      unlock record
    else
      exit
    endif
  next i
close area
RETURN DDCREATE_REFRESH









FUNCTION CtyCatEdit(cIdCty)
RETURN DbfEdit( ;
  {oCat()}, ;
  "Cat‚gories par Type "+trim(cIdCty), ;
  "CATCTY", ;
  NIL,NIL, ;
  cIdCty,"CAT->IdCty" ;
)

**
** CLB
**
FUNCTION oClb()
local b
define data b   ;
  name CLB
ddIndex b on CLB->IdClb
ddIndex b on upper(CLB->Name) format {|x|upper(x)}
ddFld IdClb     ,C,LenIdClb(),0 picture PIC_ID
ddFld Name      ,C,40,0
ddEndDef()
RETURN b

**
** RAL - rallies
**
FUNCTION oRal()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b             ;
  name RAL                  ;
  wait {|x|RalWait(x)} ;
  editprint  RalPrint() ;
  predelete RalPreDelete()
ddIndex b on RAL->IdRal
ddFld IdRal   ,C, LenIdRal(),0  when .f. picture PIC_ID
ddFld Name1   ,C,30,0
ddFld Name2   ,C,30,0
ddFld Date    ,D, 8,0
ddFld Status  ,C, 1,0 when .f.
ddFld IdTpl   ,C,LenIdTpl(),0 picture PIC_ID ;
                              pick PickTpl(TPLTYPE_RAL,RAL->IdTpl)
ddFld CatType ,C, 5,0 picture PIC_ID ;
                      pick PickCty(RAL->CatType)
                      * pick PickQry("CAT",".DBC",RAL->CatType)
ddFld StartTime   ,C,8,0 postedit {|x|GetRunTime(x)}
action b prompt "~Contenu              [Enter]" ;
         key    K_ENTER ;
         block  RalPosEdit()
action b prompt "~inscriptions/placements [F2]" ;
         key    K_F2 ;
         block  RalClose()
ddEndDef()
RETURN b

FUNCTION RalWait(wwin)
local b
local cIdRal := RAL->IdRal
if wwin[WIN_WAITKEY] == 1
  b := oPos()
  open area b, oPar(), oPlz(), oNat(), oClb()
    ddSetOrder(ORD_POS_POS)
    edit data b ;
         key POS->IdRal ;
         value cIdRal ;
         mode  wait ;
         window wwin ;
         start top ;
         query "POS-"+RAL->Status+iif(RAL->Status=="I",RAL->RalType,"")
  close area
endif
RETURN NIL



FUNCTION PickCty(cStart)
RETURN DbfPick({oCty()},"Choix Type de Cat‚gories","CTYPICK",cStart)

/*
I : saisir inscriptions
T : saisir temps
P : no longer used
C : classement fait
*/
FUNCTION RalClose
local lRetour := .f.
local cMsg
local cIdRal := RAL->IdRal
local nNonArri := 0 // inscrits mais non arriv‚s
local nNonInsc := 0 // arriv‚s mais non inscrits
local nArrives := 0 // arriv‚es
local nDoubles := 0 // arriv‚es doubles
local aDoubles := {}
local i
RETURN .f. if ! ddRecLock()
if RAL->Status == RALSTAT_I
  open area oPos(), oArr()
    ddSetOrder(1) // idral+idpos
    ARR->(ddSetOrder(2)) // idral+idpos
    ** set order to 2 in ARR // idral+idpos
    softseek cIdRal
    do while ! eof() .and. POS->IdRal == cIdRal .and. ! TaskInter()
      seek cIdRal+POS->IdPos in ARR
      if eof() in ARR
        nNonArri += 1
      elseif ddRecLock()
        * POS->Time := RunTimeDiff(RAL->StartTime,ARR->Time)
        POS->Time := ""
        unlock record
      endif
      skip
    enddo
  close area
  open area oArr(), oPos()
    ddSetOrder(1) // idral+time
    POS->(ddSetOrder(1)) // idral+idpos
    * set order to 1 in POS // idral+idpos
    softseek cIdRal
    do while ! eof() .and. ARR->IdRal == cIdRal .and. ! TaskInter()
      nArrives += 1
      select POS
      seek cIdRal+ARR->IdPos
      if eof() in POS
        nNonInsc += 1
      elseif ! empty(POS->Time)
        nDoubles += 1
        if len(aDoubles) < 5
          aadd(aDoubles,POS->IdPos)
        endif
      else
        if ddRecLock()
          POS->Time := strtran(RunTimeDiff(RAL->StartTime,ARR->Time),":",".")
          unlock record
        endif
      endif
      select ARR
      skip
    enddo
  close area
  if nArrives == 0
    RAL->Status := RALSTAT_T
    if RAL->RalType=="2"
      RalSetC()
    endif
  else
    cMsg := ntrim(nArrives) + " arriv‚es"
    if nNonInsc != 0
      cMsg += CR_LF + ntrim(nNonInsc) + " arriv‚es sans inscription!"
    endif
    if nDoubles != 0
      cMsg += CR_LF + ntrim(nDoubles) + " arriv‚es doubles! ( "
      for i := 1 to len(aDoubles)
        cMsg += aDoubles[i] + " "
      next i
      if len(aDoubles) == 5
        cMsg += "..."
      endif
      cMsg += ")"
    endif
    if nNonArri != 0
      cMsg += CR_LF + ntrim(nNonArri) + " inscriptions non arriv‚es"
    endif
    if Confirm(cMsg,"Course termin‚e?",if(nDoubles+nNonInsc+nNonArri==0,"O","N"))
      RAL->Status := RALSTAT_T
    endif
  endif
elseif RAL->Status == RALSTAT_T
  RalSetC()
elseif RAL->Status == RALSTAT_C
  lRetour := .t.
endif
if lRetour .and. Confirm("Retour … l'‚tat 'inscriptions'",MsgSure())
  open area oPos()
    ddSetOrder(1)
    softseek cIdRal
    do while ! eof() .and. POS->IdRal == cIdRal .and. ! TaskInter()
      if ddRecLock()
        if trim(POS->Time) == "X"
          POS->Time := ""
        endif
        POS->CatPlace := ""
        POS->Place := ""
        unlock record
        skip
      endif
    enddo
  close area
  RAL->Status := RALSTAT_I
endif
ddRefreshCurrent()
unlock record
RETURN .t.



FUNCTION RalSetC()
local nNoTime := 0 // inscriptions sans temps
local cIdRal := RAL->IdRal
local nRecNo
local nRecNo2
local nPlace
local nCatPlace
local cIdCat
open area oPos()
  ddSetOrder(ORD_POS_TIME)
  softseek cIdRal
  nPlace := 1
  do while ! eof() .and. POS->IdRal == cIdRal .and. ! TaskInter()
    nRecNo := recno()
    skip
    nRecNo2 := recno()
    goto nRecNo
    if ddRecLock()
      if empty(POS->Time)
        POS->Time := "X"
        nNoTime+=1
      elseif trim(POS->Time) == "X"
        nNoTime+=1
      else
        POS->Place := str(nPlace,4)
        nPlace ++
      endif
      unlock record
    endif
    goto nRecNo2
  enddo
  * if nNoTime == 0
    ddSetOrder(ORD_POS_CAT_TIME)
    softseek cIdRal
    do while ! eof() .and. POS->IdRal == cIdRal .and. ! TaskInter()
      cIdCat := POS->IdCat
      nCatPlace := 1
      do while ! eof() .and. POS->IdRal == cIdRal ;
                       .and. POS->IdCat == cIdCat ;
                       .and. ! TaskInter()
        if trim(POS->Time) != "X"
          if ddRecLock()
            POS->CatPlace := str(nCatPlace,4)
            unlock record
          endif
          nCatPlace ++
        endif
        skip
      enddo
    enddo
  * endif
close area
* if nNoTime == 0
RAL->Status := RALSTAT_C
SetMsg("Classement fait")
* else
*   SetMsg("Il reste "+ntrim(nNoTime)+" inscriptions sans temps.")
*   lRetour := .t.
* endif
RETURN .t.


**
** POS - positions
**
FUNCTION oPos()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b             ;
  name POS                  ;
  editprint PosPrint() ;
  postedit  PosPostEdit()
ddIndex b on POS->IdRal+POS->IdPos+POS->Time  ;
        format {|x|left(x,LenIdRal())+padl(trim(substr(x,LenIdRal()+1)),4,"0")}  // ORD_POS_POS
ddIndex b on POS->IdRal + POS->Time                // ORD_POS_TIME
ddIndex b on POS->IdRal + POS->IdCat + POS->Time   // ORD_POS_CAT_TIME
ddIndex b on POS->IdPar + POS->IdRal               // ORD_POS_PAR
ddIndex b on POS->IdRal + POS->IdPar               // ORD_POS_RAL_PAR
ddFld IdRal   ,C, LenIdRal(),0  when .f. picture PIC_ID
ddFld IdPos   ,C, 4,0 postedit {|x|GetIdPos(x)}
ddFld IdPar   ,C,LenIdPar(),0 picture PIC_ID pick PickPar(POS->IdPar)
ddFld IdCat   ,C,LenIdCat(),0 picture PIC_ID pick PosPickCat()
ddFld Time    ,C,8,0 postedit {|x|GetRunTime(x)}
ddFld Place   ,C,4,0
ddFld _ParName   ,C,40,0 attrib V block padr(ParName(POS->IdPar),40)
ddFld IdClb   ,C,LenIdClb(),0 picture PIC_ID pick PickClb(POS->IdClb)
ddFld IdEqu   ,C,LenIdEqu(),0 picture PIC_ID pick PickEqu(POS->IdEqu)
* ddFld _IdClb     ,C,LenIdClb(),0 attrib V when .t. ;
*                  block {|x| PosIdClb(x) } ;
*                  picture PIC_ID
* ddFld _IdEqu     ,C,LenIdEqu(),0 attrib V ;
*                  block ParField(POS->IdPar,{||PAR->IdEqu})
ddFld _CatName   ,C,20,0 attrib V ;
                 block padr(CatName(POS->IdCat),20)
ddFld _Age    ,C,3,0 attrib V block str( ;
                        Age( ;
                          ParField(POS->IdPar,{||PAR->Birth}), ;
                          RAL->Date ;
                        ), 3,0 ;
                      )
ddFld CatPlace   ,C,4,0
ddFld Paye    ,C,1,0 picture PIC_ID
ddFld _ClbName   ,C,40,0 attrib V when .t. ;
                 block {|x|GsbPosClbName(x)} ;
                 pick {|x|PosClbPick(x)}
action b prompt "~Signal‚tique coureur  [Ctrl-Enter]" ;
         key    K_CTRL_RET ;
         block  ParPage(POS->IdPar)
action b prompt "~Recopier positions            [F5]" ;
         key    K_F5 ;
         block  PosRalCopy()
action b prompt "R‚~initialiser cat‚gories [Ctrl-F5]" ;
         key    K_CTRL_F5 ;
         block  PosReset(RAL->IdRal)
ddEndDef()
RETURN b

FUNCTION GetIdPos(x)
RETURN x if val(x) == 0
RETURN padl(trim(x),4,"0")


FUNCTION GsbPosClbName(x)
local cIdClb
RETURN ClbExpr(POS->IdClb,"CLB->Name") if x == NIL
DlgDefine("ClbName",x)
x := eupper(trim(x))
cIdClb := DbfIdFromName( ;
  x,oClb(),2, ;
  "left(upper(CLB->Name),"+ntrim(len(x))+")=='"+x+"'", ;
  "CLB->Name+' '+CLB->IdClb","CLB->IdClb" ;
)
if cIdClb != NIL
  POS->IdClb := cIdClb
endif
RETURN NIL

FUNCTION PosClbPick(cStart)
* local cIdClb := DbfIdFromName( ;
*   eupper(cStart),oClb(),2, ;
*   "eupper(CLB->Name)=='"+eupper(cStart)+"'", ;
*   "CLB->Name+' '+CLB->IdClb", ;
*   "CLB->IdClb", .f. ;
* )
local cIdClb := PickClb(POS->IdClb)
RETURN NIL if cIdClb == NIL
POS->IdClb := cIdClb
RETURN ClbExpr(cIdClb,"CLB->Name")


FUNCTION GetRunTime(x)
RETURN "X" if alltrim(x) == "x"
x := strtran(x,",",".")
x := strtran(x,":",".")
RETURN padl(trim(x),len(x))


FUNCTION PosReset(cIdRal)
RETURN .f. if ! Confirm( ;
  "R‚initialiser les cat‚gories", ;
  "Etes-vous certain (O/N) ?" ;
)
open area oPos(), oPar()
  ddSetOrder(ORD_POS_POS) // alles nur nicht IdCat
  softseek cIdRal
  do while ! eof() .and. POS->IdRal == cIdRal
    if TaskInter() ; exit ; endif
    seek POS->IdPar in PAR
    if ddRecLock()
      POS->IdCat := ParCatDefault(RAL->Date)
      unlock record
    else
      exit
    endif
    skip
  enddo
close area
ddRefreshAll()
RETURN .t.

FUNCTION ParPosExist(cIdRal)
local cIdPar := PAR->IdPar
local lFound := .f.
open area oPos()
  ddSetOrder(ORD_POS_PAR)
  softseek cIdPar + cIdRal
  if POS->IdPar == cIdPar
    if left(POS->IdRal,len(cIdRal)) == cIdRal
      lFound := .t.
    endif
  endif
close area
RETURN lFound

FUNCTION ParPosField(cIdRal,cMac)
local cIdPar := PAR->IdPar
local uReturn
open area oPos()
  ddSetOrder(ORD_POS_PAR)
  seek cIdPar + cIdRal
  * if ! eof()
    uReturn := &cMac
  * endif
close area
RETURN uReturn


FUNCTION PosRalCopy
local a := {}
local cIdRal1 := RAL->IdRal
local i
* local cIdPos
static cIdRal2 := NIL
cIdRal2 := PickRal(cIdRal2,"recopier inscriptions de la course...")
RETURN .f. if cIdRal2 == NIL
* KeyGoBottom(cIdRal,"POS->IdRal",{||.t.})
open area oPos()
  ddSetOrder(ORD_POS_POS)
  softseek cIdRal2
  do while ! eof() .and. POS->IdRal == cIdRal2
    if TaskInter() ; exit ; endif
    aadd(a, CopyRec())
    skip
  enddo
close area
if Confirm("OK pour ins‚rer " + ntrim(len(a)) + " positions de " + cIdRal2 + " (O/N) ?")
  for i := 1 to len(a)
    if TaskInter() ; exit ; endif
    if dbAddRec()
      PasteRec(a[i])
      POS->IdRal := cIdRal1
      if ParExist(POS->IdPar)
        POS->IdCat := ParCatDefault(RAL->Date)
      endif
      unlock record
    else
      exit
    endif
  next i
endif
ddRefreshAll()
RETURN .t.


**
** ARR - arrivals
**
FUNCTION oArr()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b             ;
  name ARR
ddIndex b on ARR->IdRal+ARR->Time
ddIndex b on ARR->IdRal+ARR->IdPos
ddFld IdRal   ,C, LenIdRal(),0  when .f. picture PIC_ID
ddFld Time    ,C,8,0 postedit {|x|GetRunTime(x)}
ddFld IdPos   ,C, 4,0 postedit {|x|GetIdPos(x)}
ddEndDef()
RETURN b



#endif DEF_RUN

#ifdef DEF_FAB

**
** FAB - fabricants
**
FUNCTION oFab()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b             ;
  name FAB
ddIndex b on FAB->IdFab
ddFld IdFab   ,C, LenIdFab(),0  when .f. picture PIC_ID
ddFld Name    ,C,30,0
ddEndDef()
RETURN b

FUNCTION PickFab(cStart,cTitle)
default cTitle to "Auswahl Fabrikant"
RETURN DbfPick( ;
  {oFab()}, ;
  cTitle, ;
  "FABPICK", ;
  cStart ;
)

#endif DEF_FAB

FUNCTION DbfIdFromName(x,ad,nOrder,xlWhile,xcLine,xuReturn)
local a := {}
* local lOkay := .f.
local cId := NIL
open area ad
  ddSetOrder(nOrder)
  softseek x
  do while ! eof() .and. xparse(xlWhile)
    aadd(a, { xparse(xcLine), xparse(xuReturn)} )
    skip
  enddo
  if len(a) == 0
    if DbfCreate(ad) // eval(ad[AD_CREATE])
      cId := xparse(xuReturn)
    endif
  elseif len(a) == 1
    * lOkay := .t.
    cId := a[1][2]
  else
    browse array a using {|x|x[1]} ;
                    delete {||.f.} ;
                    title ("choisissez une des possibilit‚s :")
    if lastchoice() != 0
      cId := a[lastchoice()][2]
    endif
  endif
close area
RETURN cId


#ifdef DEF_RSV

* FUNCTION PreRsvRegister()
* RETURN (! ARTATTR_H $ ART->Attrib)

**
** TSL - Time Slices (Zeitzonen)
**
*FUNCTION oTsl()
*static b := NIL
*if b != NIL ; RETURN b ; endif
*define data b             ;
*  name TSL
*ddIndex b on TSL->IdTsl
*ddFld IdTsl  ,C,LEN_IDTSL,0 picture PIC_ID
*ddFld Time1  ,C,5,0 postedit {|x|GetQte(x,":")}
*ddFld Time2  ,C,5,0 postedit {|x|GetQte(x,":")}
*ddEndDef()
*RETURN b

**
** RSV - Reservierungen
**
FUNCTION oRsv()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b             ;
  name RSV
ddIndex b on dtos(RSV->Date)  // +RSV->IdTsl
ddFld Date   ,D, 8,0
* ddFld IdTsl  ,C,LEN_IDTSL,0 picture PIC_ID
ddEndDef()
RETURN b

**
** RSI - Reservierungs-Items
**
FUNCTION oRsi()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b             ;
  name RSI
ddIndex b on dtos(RSI->Date)+RSI->Time1 // ORD_RSI_DATE
ddIndex b on RSI->IdJnl+RSI->IdDoc      // ORD_RSI_DOC
ddIndex b on RSI->IdRst+dtos(RSI->Date)+RSI->Time1+RSI->IdRsc // ORD_RSI_RST
ddIndex b on RSI->IdRst+RSI->IdRsc+dtos(RSI->Date)+RSI->Time1 // ORD_RSI_RSC
ddFld Date   ,D, 8,0 when .f.
ddFld IdJnl  ,C,LenIdJnl(),0 picture PIC_ID when .f.
ddFld IdDoc  ,C,LEN_IDDOC,0 when .f.
ddFld Line   ,C,LEN_POS,0   when .f.
ddFld IdRst  ,C,LEN_IDRST,0 when .f.
ddFld IdRsc  ,C, LEN_IDRSC,0 postedit {|x|GetNum(x)} ;
                             pick {|x|PickRsc(RSI->IdRst,x)}
ddFld Time1  ,C,5,0 when .f. // postedit {|x|GetQte(x,":")}
ddFld Time2  ,C,5,0 when .f. // postedit {|x|GetQte(x,":")}
ddFld Qte    ,C, LenQte(),0 GET_NUM when .f.
ddEndDef()
RETURN b

**
** RSC - Ressourcen
**
FUNCTION oRsc()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b             ;
       name RSC
ddIndex b on RSC->IdRst + RSC->IdRsc
ddFld IdRst ,C, LEN_IDRST,0 picture "@k@!"
ddFld IdRsc ,C, LEN_IDRSC,0 postedit {|x|GetNum(x)}
ddFld Name  ,C,30,0
ddEndDef()
RETURN b

**
** RST - Ressource types (RscType)
**
FUNCTION oRst()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b             ;
  name RST
ddIndex b on RST->IdRst
ddFld IdRst     ,C, LEN_IDRST,0 picture "@k@!"
ddFld Name      ,C,30,0
ddEndDef()
RETURN b


**
** PickRsc()
**
FUNCTION PickRsc( cIdRst, cStart, cTitle )
local cId := NIL
local b := oRsc()
default cTitle to "Auswahl Ressource"
if empty(cIdRst)
  RETURN NIL if (cIdRst := PickRst()) == NIL
endif
open area b
  if empty(cStart)
    ddSetOrder(2)
    go top
  else
    ddSetOrder(1)
    softseek cIdRst + cStart
    ddSetOrder(2)
  endif
  edit data b ;
    key RSC->IdRst ;
    value cIdRst ;
    mode pick ;
    query "RSCPICK" ;
    title (cTitle)
  if ddLastReq() == DDEDIT_SELECT
    cId := RSC->IdRsc
  endif
close area
RETURN cId

FUNCTION VnlIdRst
RETURN "" if ! IsArtCode(VNL->Code)
RETURN "" if ! ArtExist(VNL->IdArt)
RETURN ART->IdRst


**
** VenRsiGenerate()
**
FUNCTION VenRsiGenerate(jnl)
local dDate
local lOkay := .f.
local cIdRsc
local i
RETURN .t. if ! JNLATTR_R $ jnl[JNL_ATTRIB]
open area oVnl(), oRsi(), oRsv(), oArt()
  lOkay := .t.
  softseek VEN->IdJnl + VEN->IdDoc
  do while lOkay .and. ! eof() .and. VNL->IdDoc == VEN->IdDoc ;
                               .and. VNL->IdJnl == VEN->IdJnl
    if IsArtCode(VNL->Code) .and. ArtExist(left(VNL->IdArt,LenIdArt()))
      for i := 1 to qton1(VNL->Qte)
        if empty(VNL->IdRsc)
          cIdRsc  := RscGetFree(ART->IdRst,VNL->Date1,VNL->Time1,VNL->Date2,VNL->Time2)
        else
          cIdRsc  := VNL->IdRsc
        endif
        dDate  := VNL->Date1
        select RSI
        do while dDate <= VNL->Date2
          if dbAddRec()
            RSI->Date  := dDate
            RSI->IdDoc := VNL->IdDoc
            RSI->IdJnl := VNL->IdJnl
            RSI->Line  := VNL->Line
            RSI->IdRst  := ART->IdRst
            RSI->IdRsc  := cIdRsc
            * RSI->Qte    := VNL->Qte
            if dDate == VNL->Date1
              RSI->Time1 := VNL->Time1
            endif
            if dDate == VNL->Date2
              RSI->Time2 := VNL->Time2
            else
              RSI->Time2 := repl(CHR_255,5)
            endif
            unlock record
          else
            lOkay := .f.
            exit
          endif
          if ! RsiRsvRegister(.f.)
            lOkay := .f.
            exit
          endif
          dDate++
        enddo
        select VNL
      next i
    endif
    skip
  enddo
close area
RETURN lOkay


FUNCTION RscGetFree(cIdRst,dDate1,cTime1,dDate2,cTime2)
local cIdRsc := "?"
local lOccupied
open area oRsc(), oRsi()
  * 20070814 set order to ORD_RSI_RSC in RSI
  RSI->(ddSetOrder(ORD_RSI_RSC))
  softseek cIdRst
  do while ! eof() .and. RSC->IdRst == cIdRst
    lOccupied := .f.
    select RSI
    softseek RSC->IdRst + RSC->IdRsc + dtos(dDate1) + cTime1
    do while ! eof() .and. RSI->IdRst == RSC->IdRst ;
                     .and. RSI->IdRsc == RSC->IdRsc ;
                     .and. RSI->Date <= dDate2
      * if RSI->Date == dDate1 .and. RSI->Time
        lOccupied := .t.
        exit
      * endif
      skip
    enddo
    select RSC
    if ! lOccupied
      cIdRsc := RSC->IdRsc
      exit
    endif
    skip
  enddo
close area
RETURN cIdRsc

**
** VenRsiUndo()
**
FUNCTION VenRsiUndo(jnl)
local dDate
local lOkay := .f.
open area oRsi(), oVnl(), oRsv(), oArt()
  ddSetOrder(ORD_RSI_DOC)
  lOkay := .t.
  softseek VEN->IdJnl + VEN->IdDoc
  do while lOkay .and. ! eof() .and. RSI->IdDoc == VEN->IdDoc ;
                               .and. RSI->IdJnl == VEN->IdJnl
    seek RSI->IdJnl + RSI->IdDoc + RSI->Line in VNL
    if ArtExist(left(VNL->IdArt,LenIdArt()))
      if ! RsiRsvRegister(.t.)
        lOkay := .f.
        exit
      endif
      if ddRecLock()
        delete
        unlock record
      else
        lOkay := .f.
        exit
      endif
    else
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
RETURN lOkay



FUNCTION RsiRsvRegister(lUndo)
local cMac
local cRsvColumn
local nSelect := select()
local lOkay := .t.
RETURN .t. if empty(cRsvColumn := RsiRsvColumn())
cMac := "RSV->" + cRsvColumn
select RSV
seek dtos(RSI->Date)
if eof()
  if dbAddRec()
    RSV->Date  := RSI->Date
    unlock record
  else
    lOkay := .f.
  endif
endif
if ddRecLock()
  if lUndo
    &cMac := ntoq(qton(&cMac) - qton1(RSI->Qte),ART->QteForm)
  else
    &cMac := ntoq(qton(&cMac) + qton1(RSI->Qte),ART->QteForm)
  endif
else
  lOkay := .f.
endif
select (nSelect)
RETURN lOkay


FUNCTION RscMaxQteRes(dDate1,dDate2)
local nMaxQteRes := 0
local nQteRes := 0
local dDate
* local aAlle := {}
local a
local i,j
open area oRsi()
  ddSetOrder(ORD_RSI_RSC)
  for i := dDate1 to dDate2
    a := {}
    softseek RSC->IdRst+RSC->IdRsc+dtos(i)
    do while !eof() .and. RSI->IdRst+RSI->IdRsc == RSC->IdRst+RSC->IdRsc ;
                    .and.RSI->Date == i
      for j := 1 to qton1(RSI->Qte)
        RsiFindFree(a,RSI->Time1,RSI->Time2)
      next j
      * default dDate to RSI->Date
      * if dDate == RSI->Date
      *   nQteRes += qton1(RSI->Qte)
      * else
      *   dDate := RSI->Date
      *   nMaxQteRes := max(nMaxQteRes,nQteRes)
      *   nQteRes := qton1(RSI->Qte)
      * endif
      skip
    enddo
    nMaxQteRes := max(nMaxQteRes,len(a))
    * aadd(aAlle, a}
  next i
close area
RETURN nMaxQteRes


FUNCTION RscAddColumns(dDate1,dDate2)
local i
for i := dDate1 to dDate2
  QryAddColumn( ;
    NIL, ;
    "RscRsiInfo('"+dtos(i)+"',3)", ;
    left(dtoc(i),2)+";"+substr(dtoc(i),4,2) ;
  )
next i
RETURN .t.

FUNCTION RscRsiInfo(cDate,nWidth)
local cReturn := ""
local cTime1 := space(5)
local cTime2 := repl(CHR_255,5)
local nQte := 0
local a := {}
local i
RETURN space(nWidth) if eof()
open area oRsi()
  ddSetOrder(ORD_RSI_RSC)
  softseek RSC->IdRst+RSC->IdRsc+cDate
  do while !eof() .and. ;
       RSI->IdRst+RSI->IdRsc+dtos(RSI->Date)==RSC->IdRst+RSC->IdRsc+cDate
    for i := 1 to qton1(RSI->Qte)
      RsiFindFree(a,RSI->Time1,RSI->Time2)
    next i
    * nQte += qton1(RSI->Qte)
    skip
  enddo
close area
RETURN space(nWidth) if len(a) == 0
for i := 1 to len(a)
  cTime1 := cmax(cTime1,a[i][1]) // die sp„teste Anfangszeit
  cTime2 := cmin(cTime2,a[i][2]) // die frheste Endezeit
next i
if empty(cTime1)
  cReturn += repl("Û",int(nWidth/2))
else
  cReturn += repl("²",int(nWidth/2))
endif
if len(a) > val(RSC->QteMax)
  cReturn += "!"
else
  cReturn += left(cReturn,1) // "Û"
endif
if left(cTime2,1) == CHR_255
  cReturn += repl("Û",int(nWidth/2))
else
  cReturn += repl("²",int(nWidth/2))
endif
RETURN cReturn

STATIC FUNCTION RsiFindFree(a,cTime1,cTime2)
local i
for i := 1 to len(a)
  if a[i][1] > cTime2
    a[i][1] := cTime1
    RETURN NIL
  endif
  if a[i][2] < cTime1
    a[i][2] := cTime2
    RETURN NIL
  endif
next i
aadd(a,{ cTime1, cTime2 })
RETURN NIL


FUNCTION cmin(c1,c2)
RETURN c1 if c1 <= c2
RETURN c2

FUNCTION cmax(c1,c2)
RETURN c1 if c1 >= c2
RETURN c2

#endif DEF_RSV



