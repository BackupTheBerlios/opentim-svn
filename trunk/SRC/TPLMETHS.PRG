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

#define TCA_ID        1
#define TCA_NAME      2
#define TCA_ALEN      2

#define TCS_ID    1
#define TCS_NAME  2
#define TCS_ALEN  2

#include "TIM.CH"
#include "DEFDATA.CH"

**
** STATIC_SECTION global static variables
**

static saTca := NIL // TCA : template code areas
static saTpt := NIL // TPT : template types
static scWarnStr := ""
* static snParDebit  := 0
* static snParCredit := 0

**
** MSG_SECTION    MSGnnn definitions
**

#ifdef LG_FRENCH
  #define MSG036  "S‚lection "
  static MSG051 := " : bloc de texte inconnu !"
  static MSG001 := "Type de texte"
#else
  #define MSG036  "Auswahl "
  static MSG051 := " : unbekannter Textblock  !"
  static MSG001 := "Textblock-Art"
#endif


**
** PROCEDURE_SECTION  - (...grins)
**
**

**
** TPL - textes Libres, Formules, Descriptions d'article
**
FUNCTION oTpl()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                   ;
  name TPL                      ;
  editprint TplPrint()        ;
  wait {|win| TplWait(win) } ;
  predelete TplPreDelete()
ddIndex b on  TPL->IdTpt+TPL->IdTpl
ddFld IdTpt   ,C, 3,0 when .f. picture PIC_ID
ddFld IdTpl   ,C, LenIdTpl(),0 picture PIC_ID ;
               when USRATTR_E $ UsrAttrib()
ddFld Name    ,C,40,0
#ifdef DEF_TPLTEXT
ddAddField("_Memo1","M",10,0,"30x3","V",{|x|FileGetSet(TplMemoFile(MemLang1))})
ddAddField("_Memo2","M",10,0,"30x3","V",{|x|FileGetSet(TplMemoFile(MemLang2))})
ddAddField("_Memo3","M",10,0,"30x3","V",{|x|FileGetSet(TplMemoFile(MemLang3))})
#else
ddFld Memo1   ,M,10,0
ddFld Memo2   ,M,10,0
ddFld Memo3   ,M,10,0
#endif
ddFld Width   ,C, 3,0 GET_NUM
ddFld IdOpt   ,C, LenIdTpl(),0 picture PIC_ID ;
                       pick PickTpl(TPLTYPE_INI,TPL->IdOpt)
ddFld Attrib  ,C, 3,0 picture PIC_ID ;
                       pick PickTplAttrib(TPL->Attrib)
ddFld IdDlg  ,C,  8,0 picture PIC_ID ;
                      pick PickQry("",".DLG",TPL->IdDlg)
ddFld Filter  ,C,80,0
action b key K_ALT_F2  prompt MsgMnuRename()  block TplRename() ;
                       when !eof() // 20070801 recno() != lastrec() + 1
action b key K_F12     prompt MnuMemoEdit() block TplMemoEdit()
action b key K_F8      prompt MnuOptEdit() ;
                       block TplValue(TPLTYPE_INI,TPL->IdOpt,{||TplMemoEdit()})
action b key K_ENTER   block TplMemoEdit()
* #ifdef DEF_ACT
*   if IsCustData("TPL") ; ActExec("TPL") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

FUNCTION TplPreDelete()
RETURN ConfirmDelete() if USRATTR_E $ UsrAttrib()
SetMsg(MsgNoAccess())
RETURN .f.

FUNCTION MnuOptEdit
#ifdef LG_FRENCH
  RETURN "~ParamŠtres imprimante     [F8]"
#else
  RETURN "~Druckparametersatz        [F8]"
#endif

* FUNCTION TplOptEdit(cIdTpl)
* RETURN TplValue(TPLTYPE_INI,cIdTpl,{||TplMemoEdit()})


FUNCTION PickTplAttrib(cStart)
local a := {}
#ifdef LG_FRENCH
  aadd(a, { TPLATTR_P, "Dialogue : P‚riode", 1 } )
#else
  aadd(a, { TPLATTR_P, "Dialog : Periode", 1 } )
#endif
RETURN PickAttrib(a, NIL, cStart )




FUNCTION TplRename()
local cType := PickTpt(TPL->IdTpt)
local nRecNo := recno()
local nRecNo2
RETURN .f. if cType == NIL
if ddSkip(1) != 1
  ddSkip(-1)
endif
nRecNo2 := recno()
goto nRecNo
if ddRecLock()
  TPL->IdTpt := cType
  unlock record
endif
goto nRecNo2
ddRefreshAll()
RETURN MnuDone()


#ifdef DEF_VEN

FUNCTION VnlPu(p)
local nPrixU
local nDecPos := max(VnlPuDecPos(),MntDecPos(FIELD->PrixU))
RETURN 0 if empty(FIELD->PrixU)
#ifdef DEF_MULT
  if empty(FIELD->Mult)
    nPrixU := val(FIELD->PrixU)
  else
    nPrixU := val(FIELD->PrixU) * val(FIELD->Mult)
  endif
#else
  nPrixU := val(FIELD->PrixU)
#endif
RETURN round(nPrixU,nDecPos)


FUNCTION VnlPuF(p)
local nPrixU
local nDecPos := max(VnlPuDecPos(),MntDecPos(FIELD->PrixU))
RETURN space(LenMntF()) if empty(FIELD->PrixU)
#ifdef DEF_VNLATTR
RETURN space(LenMntF()) if VnlHideDetail() // VNLATTR_D $ FIELD->Attrib
#endif DEF_VNLATTR
#ifdef DEF_MULT
  if empty(FIELD->Mult)
    nPrixU := val(FIELD->PrixU)
  else
    nPrixU := val(FIELD->PrixU) * val(FIELD->Mult)
  endif
#else
  nPrixU := val(FIELD->PrixU)
#endif
RETURN ntomf(nPrixU,nDecPos)

#endif DEF_VEN


FUNCTION AppTcsEval(cIdTca,cIdTcs,p,c)
// local c := "{" + cIdTca + " " + cIdTcs + "}" // default return value
local cMac
local doc
if cIdTca == "par"
      if cIdTcs == "name1"     ; c := trim(ParName())
  elseif cIdTcs == "name2"     ; c := trim(PAR->Name2)
  elseif cIdTcs == "street"    ; c := ParStreet()
  elseif cIdTcs == "city"      ; c := ParCity() // PlzString(PAR->Pays,PAR->CP)
  elseif cIdTcs == "memo"      ; c := TplParse(hardcr(PAR->Memo))
  #ifdef DEF_HST
    elseif cIdTcs == "hstlist"   ; c := ParHstList(p)
  #endif DEF_HST
  #ifdef DEF_JNL
    elseif cIdTcs == "hstdebit"  ; c := ntomf(ParDebit())
    elseif cIdTcs == "hstcredit" ; c := ntomf(ParCredit())
    elseif cIdTcs == "hstsolde"  ; c := ParSolde(upper(p))
  #endif DEF_JNL
  elseif cIdTcs == "list"      ; c := TimParList(p)
  #ifdef DEF_PSC
    elseif cIdTcs == "contact"   ; c := PscName(PAR->IdPar,p)
    elseif cIdTcs == "psclist"   ; c := ParPscList(p)
  #endif
  endif
#ifdef DEF_RUN
  elseif cIdTca == "ral"
        if cIdTcs == "poslist1"     ; c := RalPosList(ORD_POS_POS,p)
    elseif cIdTcs == "poslist2"     ; c := RalPosList(ORD_POS_TIME,p)
    elseif cIdTcs == "poslist3"     ; c := RalPosList(ORD_POS_CAT_TIME,p)
    elseif cIdTcs == "poslist5"     ; c := RalPosList(ORD_POS_RAL_PAR,p)
    elseif cIdTcs == "clblist"      ; c := RalClbList(p)
    elseif cIdTcs == "equlist"      ; c := RalEquList(p)
    elseif cIdTcs == "catposlist"   ; c := CatPosList(p)
    endif
  elseif cIdTca == "pos"
        if cIdTcs == "time"         ; c := POS->Time
    elseif cIdTcs == "catplace"     ; c := PosPlace(p)
    elseif cIdTcs == "parseek"      ; ParExist(POS->IdPar) ; c := NIL
    endif
#endif DEF_RUN
* #ifdef DEF_PLI
* elseif cIdTca == "pls"
*       if cIdTcs == "memo"      ; c := TplParse(hardcr(PLS->Memo))
*   elseif cIdTcs == "mbrlist"   ; c := PlsMbrList(p)
*   endif
* #endif DEF_PLI
#ifdef DEF_ODS
elseif cIdTca == "ods"
      if cIdTcs == "memo"      ; c := TplParse(hardcr(ODS->Memo))
  elseif cIdTcs == "odllist"   ; c := OdsOdlList(p)
  endif
#endif DEF_ODS
#ifdef DEF_HST
elseif cIdTca == "gen"
      if cIdTcs == "hstlist"    ; c := GenHstList(p)
  elseif cIdTcs == "hstdebit"   ; c := GenDebit()
  elseif cIdTcs == "hstcredit"  ; c := GenCredit()
  elseif cIdTcs == "hstsolde"   ; c := GenSolde(upper(p))
  endif
#endif DEF_HST
#ifdef DEF_JNL
  elseif cIdTca == "jnl"
    if cIdTcs == "compte"
      c := trim(JnlField(IMP->IdJnl,JNL_COMPTE))
    endif
#endif DEF_JNL
#ifdef DEF_CTT
  elseif cIdTca == "ctt"
    if cIdTcs == "base"
      c := ntomf(CttValue(1,p))
    elseif cIdTcs == "taxe"
      c := ntomf(CttValue(2,p))
    elseif cIdTcs == "list"
      c := CttList(p)
    endif
#endif DEF_CTT
#ifdef DEF_CTG
  elseif cIdTca == "ctg"
        if cIdTcs == "d"       ; c := ntomf(CtgValue(DC_DEBIT,p))
    elseif cIdTcs == "c"       ; c := ntomf(CtgValue(DC_CREDIT,p))
    elseif cIdTcs == "sd"      ; c := ntomf(CtgValue("S"+DC_DEBIT,p))
    elseif cIdTcs == "sc"      ; c := ntomf(CtgValue("S"+DC_CREDIT,p))
    endif
#endif DEF_CTG
#ifdef DEF_VEN
elseif cIdTca == "ven"
      if cIdTcs == "docname"
          c := JnlDocLib(VEN->IdJnl,VEN->IdDoc,VEN->DC)
  elseif cIdTcs == "partner"     ; c := SetPar(VEN->IdPar,VEN->IdPar2,p)
  #ifdef DEF_TAX
  * elseif cIdTcs == "tot_htva"    ; c := TvaLook(p,1)
  * elseif cIdTcs == "tot_mtva"    ; c := TvaLook(p,2)
  * elseif cIdTcs == "tot_tvac"    ; c := TvaLook(p,3)
  elseif cIdTcs == "htva"        ; c := TvaLook(p,1)
  elseif cIdTcs == "mtva"        ; c := TvaLook(p,2)
  elseif cIdTcs == "tvac"        ; c := TvaLook(p,3)
  #endif DEF_TAX
  elseif cIdTcs == "date"
    if val(p) == 0
      c := dtocf(VEN->Date,p)
    else
      c := dtocf(VEN->Date+val(p))
    endif
  elseif cIdTcs == "date2"      ; c := dtocf(VEN->DatEch+val(p))
  elseif cIdTcs == "vnllist"    ; c := VenVnlList(p)
  elseif cIdTcs == "ifcname"    ; c := MfcName(VEN->IdMfc,TplLang())
  #ifdef DEF_HOLZ
  elseif cIdTcs == "stmlist"   ; c := VenStmList(VEN->IdJnl,VEN->IdDoc,p)
  #endif
  elseif cIdTcs == "memo"      ; c := TplParse(hardcr(VEN->Memo))
  elseif cIdTcs == "memo_ifc"  ; c := TplParse(VenIfcMemo(p))
  #ifdef DEF_TAX
  * elseif cIdTcs == "memo_tax"  ; c := VenTaxMemo(p)
  elseif cIdTcs == "memo_tax"  ; c := VenTaxMemo()
  #endif DEF_TAX
  elseif cIdTcs == "username"  ; c := Auteur(VEN->Auteur,TplLang())
  elseif cIdTcs == "usertitle" ; c := Fonction(VEN->Auteur,TplLang())
  endif
elseif cIdTca == "vnl"
      if cIdTcs == "qt"         ; c := komma(FIELD->Qte)
  elseif cIdTcs == "descript"   ; c := VnlDescript(p) // FIELD->Desig
  * elseif cIdTcs == "pu"         ; c := VnlMntF(p,ntomf(VnlPuMult()))
  elseif cIdTcs == "pu"         ; c := VnlPuF(p)
  elseif cIdTcs == "htva"       ; c := VnlMntF(p,mtomf(FIELD->cMont))
  elseif cIdTcs == "mtva"       ; c := VnlMntF(p,mtomf(FIELD->MontT))
  elseif cIdTcs == "tvac"       ; c := VnlMntF(p,ntomf(val(FIELD->cMont)+val(FIELD->MontT)))
  elseif cIdTcs == "memo"       ; c := TplParse(hardcr(FIELD->Memo))
  elseif cIdTcs == "date"
    if empty(FIELD->Date)
      c := ""
    else
      c := dtocf(FIELD->Date+val(p))
    endif
  endif
#endif DEF_VEN
#ifdef DEF_IMP
elseif cIdTca == "imp"
      if cIdTcs == "docname"
          c := JnlDocLib(IMP->IdJnl,IMP->IdDoc)
  elseif cIdTcs == "partner"   ; c := SetPar(IMP->IdPar,IMP->IdPar2,p)
  elseif cIdTcs == "date"      ; c := dtocf(IMP->Date1+val(p))
  elseif cIdTcs == "date2"     ; c := dtocf(IMP->Date2+val(p))
  elseif cIdTcs == "imldate"   ; c := dtocf(ImpImlField({||IML->Date}))
  elseif cIdTcs == "imlmatch"  ; c := ImpImlField( {||IML->Match} )
  elseif cIdTcs == "imllist"   ; c := ImpImlList(p)
  elseif cIdTcs == "memo"      ; c := TplParse(hardcr(IMP->Memo))
  elseif cIdTcs == "idbud"     ; c := trim(SayIdBud(IMP->IdBud))
  elseif cIdTcs == "username"  ; c := Auteur(IMP->IdUsr,TplLang())
  elseif cIdTcs == "usertitle" ; c := Fonction(IMP->IdUsr,TplLang())
  #ifdef DEF_INTERBNK
  elseif cIdTcs == "sysifile"  ; c := ImpSysiFile(p)
  #endif DEF_INTERBNK
  endif
elseif cIdTca == "iml"
      if cIdTcs == "match"
          c := JnlDocLib( ;
                 left(IML->Match,LenIdJnl()), ;
                 right(IML->Match,LEN_IDDOC) ;
               )
  elseif cIdTcs == "partner"   ; c := SetPar(IML->IdPar,IML->IdPar2,p)
  elseif cIdTcs == "date"      ; c := dtocf(IML->Date+val(p))
  elseif cIdTcs == "idbud"     ; c := trim(SayIdBud(IML->IdBud))
  endif
#endif DEF_IMP
#ifdef DEF_TRA
elseif cIdTca == "tra"
  if cIdTcs == "montant"   ; c := EscMontant(TraMont(),p)
  elseif cIdTcs == "idjnl"   ; c := TraIdJnl(p)
  elseif cIdTcs == "trllist" ; c := TraTrlList(p)
  elseif cIdTcs == "partner" ; c := TraSetPartner(p)
  endif
elseif cIdTca == "trl"
  if cIdTcs == "partner"   ; c := SetPar(TrlIdPar(),TRL->IdPar2,p)
  endif
#endif DEF_IMP
elseif cIdTca == "tim"
  if cIdTcs == "otifile"  ; Warning("{tim otifile} ersetzen durch {= OtiFile()}") // ; c := OtiFile()
  * #ifdef DEF_ART
  * #endif DEF_ART
  endif
#ifdef DEF_HST
elseif cIdTca == "hst"
      if cIdTcs == "debit"   ; c := HstParMont(DC_DEBIT)
  elseif cIdTcs == "credit"  ; c := HstParMont(DC_CREDIT)
  elseif cIdTcs == "docname"
          c := JnlDocLib(HST->IdJnl,HST->IdDoc,HST->DC)
  elseif cIdTcs == "remark"
          RETURN HstDocName(HST->IdJnl,HST->IdDoc,HST->Line)
          * doc := DocInfo(HST->IdJnl,HST->IdDoc,HST->Line)
          * if doc == NIL
          *   c := ""
          * else
          *   c := trim(doc[DOC_LIBELL])
          * endif
  elseif cIdTcs == "date2"
          doc := DocInfo(HST->IdJnl,HST->IdDoc,HST->Line)
          if doc == NIL
            c := ""
          else
            c := dtocf(doc[DOC_ECHE])
          endif
  elseif cIdTcs == "matchname"
          c := JnlDocLib( ;
                 left(HST->Match,LenIdJnl()), ;
                 right(HST->Match,LEN_IDDOC), HST->DC ;
               )
  endif
#endif DEF_HST
#ifdef DEF_CTP
  elseif cIdTca == "ctp"
        if cIdTcs == "debit"  ; c := CtpDebit()
    elseif cIdTcs == "credit" ; c := CtpCredit()
    elseif cIdTcs == "solde"  ; c := CtpSolde()
    elseif cIdTcs == "list"   ; c := CtpList(p)
    endif
#endif DEF_CTP
#ifdef DEF_FIN
elseif cIdTca == "fin"
      if cIdTcs == "docname"
          c := JnlDocLib(FIN->IdJnl,FIN->IdDoc)
  elseif cIdTcs == "fnllist"    ; c := FinFnlList(p)
  #ifdef DEF_INTERBNK
    elseif cIdTcs == "otifile"  ; c := FinOtiFile(p)
  #endif DEF_INTERBNK
  endif
elseif cIdTca == "fnl"
  if cIdTcs == "matchname"
          c := JnlDocLib( ;
                 left(FNL->Match,LenIdJnl()), ;
                 right(FNL->Match,LEN_IDDOC) ;
               )
                                                 #ifdef DEF_VEN
  elseif cIdTcs == "par2expr" ; FnlPar2Expr(p)
                                                 #endif DEF_VEN
  endif
#endif DEF_FIN
#ifdef DEF_KVK
elseif cIdTca == "kvk"
      if cIdTcs == "docname"
          c := JnlDocLib(KVK->IdJnl,KVK->IdDoc)
  elseif cIdTcs == "kvllist"    ; c := KvkKvlList(p)
  endif
#endif DEF_KVK
#ifdef DEF_ART
  elseif cIdTca == "art"
        if cIdTcs == "id"         ; c := ArtIdArtF()
    #ifdef DEF_ART_REF
    elseif cIdTcs == "list"       ; c := ArtList(p)
    #endif DEF_ART_REF
    #ifdef DEF_ALA
    elseif cIdTcs == "alalist"    ; c := ArtAlaList(p)
    #endif DEF_ALA
    #ifdef DEF_ACF
    elseif cIdTcs == "acflist"    ; c := ArtAcfList(p)
    #endif DEF_ACF
    elseif cIdTcs == "list"       ; c := TimArtList(p)
    endif
#endif DEF_ART
#ifdef DEF_GRA
  elseif cIdTca == "gra"
        if cIdTcs == "artlist"    ; c := GraArtList(p)
    endif
#endif DEF_GRA
#ifdef DEF_CTS
  elseif cIdTca == "cts"
        if cIdTcs == "qty"      ; c := CtsValue(1,p)
    elseif cIdTcs == "list"     ; c := CtsList(p)
    elseif cIdTcs == "montant"  ; c := CtsValue(2,p)
    endif
#endif DEF_CTS
#ifdef DEF_PRJ
elseif cIdTca == "prj"
      if cIdTcs == "name1"      ; c := PRJ->Name1
  elseif cIdTcs == "name2"      ; c := PRJ->Name2
  elseif cIdTcs == "name3"      ; c := PRJ->Name3
  elseif cIdTcs == "date1"      ; c := dtocf(PRJ->Date1)
  elseif cIdTcs == "date2"      ; c := dtocf(PRJ->Date2)
  elseif cIdTcs == "id"         ; c := PRJ->IdPrj
  elseif cIdTcs == "memo"       ; c := TplParse(hardcr(PRJ->Text))
  #ifdef DEF_VEN
  elseif cIdTcs == "doclist"    ; c := PrjListDoc(p)
  #endif DEF_VEN
  elseif cIdTcs == "list"       ; c := PrjList(p)
  #ifdef DEF_HOLZ
    elseif cIdTcs == "stmlist"    ; c := PrjStmList(NIL,p)
    elseif cIdTcs == "clslist"    ; c := PrjClsList(p)
  #endif
  #ifdef DEF_PIN
    elseif cIdTcs == "pinlist"    ; c := PrjPinList(p)
  #endif
  endif
#endif DEF_PRJ
#ifdef DEF_HOLZ
elseif cIdTca == "cls"
      if cIdTcs == "idart"      ; c := ClsItem(CLSLIST_IDART)
  elseif cIdTcs == "idcls"      ; c := ClsItem(CLSLIST_IDCLS)
  elseif cIdTcs == "clsname"    ; c := ClsName(ClsItem(CLSLIST_IDCLS))
  elseif cIdTcs == "qt"         ; c := ntoq(ClsItem(CLSLIST_MENGE),ART->QteForm)
  elseif cIdTcs == "count"      ; c := ntrim(ClsItem(CLSLIST_COUNT))
  endif
#endif DEF_HOLZ
#ifdef DEF_PIN
elseif cIdTca == "pin"
  if cIdTcs == "list"           ; c := PinList(p)
  elseif cIdTcs == "memo"       ; c := hardcr(PIN->Memo)
  endif
#endif DEF_PIN
#ifdef DEF_MSG
elseif cIdTca == "msg"
      if cIdTcs == "title"      ; c := MSG->Titre
  elseif cIdTcs == "date"       ; c := dtocf(MSG->Date)
  elseif cIdTcs == "memo"       ; c := TplParse(hardcr(MSG->Texte))
  endif
#endif DEF_MSG
#ifdef DEF_EVT
elseif cIdTca == "evt"
      if cIdTcs == "memo"       ; c := TplParse(hardcr(EVT->Memo))
  endif
#endif DEF_EVT
#ifdef DEF_PRESTO
elseif cIdTca == "trm"
      if cIdTcs == "title"      ; c := TRM->Texte
  elseif cIdTcs == "date"       ; c := dtocf(TRM->Date)
  elseif cIdTcs == "memo"       ; c := TplParse(hardcr(TRM->MemoTxt))
  endif
#endif DEF_PRESTO
#ifdef DEF_WWW
elseif cIdTca == "fileref"
  c := fileref(cIdTcs,p)
elseif cIdTca == "ref"
  c := ref2html(cIdTcs,p)
elseif cIdTca == "xe"
  c := xe2html(cIdTcs,p)
elseif cIdTca == "item"
  c := item2html(cIdTcs,p)
elseif cIdTca == "img"
  c := pic2html(cIdTcs,p)
elseif cIdTca == "pic"
  c := pic2html(cIdTcs,p)
elseif cIdTca == "btn"
  c := btn2html(cIdTcs,p)
  * c := ActExec("IMG",{cIdTcs,p})
elseif cIdTca == "logo"
  c := logo2html(cIdTcs,p)
elseif cIdTca == "src"
  c := src2html(cIdTcs,p)
  // c := ActExec("SRC",{cIdTcs,p})
elseif cIdTca == "url"
  c := url2html(cIdTcs,p)
  ** c := ActExec("URL",{cIdTcs,p})
#endif DEF_WWW
endif
RETURN c

* FUNCTION MvgMont(cDC)
* RETURN ntomf(val(MVT->Mont)) if MVT->DC == cDC
* RETURN space(LenMntF())


FUNCTION SetPar(cIdPar1,cIdPar2,p)
if p == "2"
  if empty(cIdPar2)
    seek cIdPar1 in PAR
  else
    seek cIdPar2 in PAR
  endif
else
  seek cIdPar1 in PAR
endif
RETURN NIL

#ifdef DEF_FIN

#ifdef DEF_VEN

FUNCTION FnlPar2Expr(cMac)
RETURN "" if empty(FNL->Match)
RETURN ParField( ;
  VenField(FNL->Match,{|| VenIdPar2() }), ;
  {|| xparse(cMac) } ;
)

FUNCTION VenIdPar2()
RETURN VEN->IdPar if empty(VEN->IdPar2)
RETURN VEN->IdPar2

#endif DEF_VEN

#ifdef DEF_HST

FUNCTION HstParMont(cDC)
if HST->DC == cDC
  RETURN ntomf(HstMont(SetDevise())) // if empty(PAR->IdDev) .or. PAR->IdDev == DevDefault(HST->Periode)
  // RETURN ntomf(val(HST->MontDev),DevDecPos(PAR->IdDev))
endif
RETURN space(LenMntF())

#endif DEF_HST

#endif DEF_FIN

**
** mtomf() - convert "montant" to "montant format‚"
**           aber wenn z.B. "Gratis" da steht, dann unver„ndert.
**           und wenn mehr Dezimalstellen als normal, dann auch...
**
FUNCTION mtomf(cMont)
local nMont := val(cMont)
local nDecPos
RETURN cMont if nMont == 0
nDecPos := MntDecPos(cMont)
RETURN ntomf(nMont,nDecPos)


FUNCTION TcaRefresh()
saTca := ReadArray("TCA.DBC",TCA_ALEN)
RETURN NIL

FUNCTION TptRefresh()
saTpt := ReadArray("TPT.DBC",TPT_ALEN)
RETURN NIL


FUNCTION TptLocate(cTplType)
local i
if saTpt == NIL ; TptRefresh() ; endif
for i := 1 to len(saTpt)
  RETURN saTpt[i] if saTpt[i][TPT_ID] == cTplType
next i
RETURN NIL

FUNCTION TptName(cTplType)
local tpt := TptLocate(cTplType)
RETURN "" if tpt == NIL
RETURN tpt[TPT_NAME]



*FUNCTION PickTcs()
*static nTca := 0
*static nTcs := 0
*static aTcs := {}
*local cString := ""
*local cParam := NIL
*local i
*local cIdTca
*local cIdTcs
*if saTca == NIL ; TcaRefresh() ; endif
*browse array saTca ;
*             using {|tca| tca[TCA_ID] + " " + padr(tca[TCA_NAME],40)} ;
*             delete {|| .f.} ;
*             start nTca ;
*             help "TCAPICK"
*RETURN NIL if lastchoice() == 0
*cIdTca := trim(saTca[lastchoice()][TCA_ID])
*if nTca != lastchoice()
*  nTca := lastchoice()
*  nTcs := 0
*  aTcs := ReadArray(upper(cIdTca) + ".TCS",TCS_ALEN,NIL,DbPath())
*endif
*if nTcs > len(aTcs) ; nTcs := 0 ; endif
*browse array aTcs ;
*             using {|tcs| tcs[TCS_ID] + padr(tcs[TCS_NAME],50) } ;
*             delete {||.f.} ;
*             start nTcs ;
*             help "TCSPICK"
*RETURN NIL if lastchoice() == 0
*nTcs := lastchoice()
*cIdTcs := trim(aTcs[nTcs][TCS_ID])
*cParam := PickTcsParam(cIdTca,cIdTcs)
*RETURN NIL if cParam == NIL
*cString := cIdTcs
*if ! empty(cParam)
*  cString += " " + cParam
*endif
*RETURN "{" + (cString) + "}"

**
** TplValue()
**
FUNCTION TplValue(cTplType,cIdTpl,bValue,uValue)
// local uValue := NIL
local b := oTpl()
local nPos
cIdTpl := alltrim(cIdTpl)
if (nPos := at("%",cIdTpl)) != 0
  * cIdTpl := left(cIdTpl,nPos-1) + getenv(substr(cIdTpl,nPos+1))
  cIdTpl := left(cIdTpl,nPos-1) + getvar(substr(cIdTpl,nPos+1))
endif
if empty(cIdTpl)
  cIdTpl := padr("STD",LenIdTpl())
else
  cIdTpl := padr(cIdTpl,LenIdTpl())
endif
open area b
  seek cTplType + cIdTpl + TplLang()
  if eof()
    seek cTplType + cIdTpl + MemLang1
  endif
  if !eof()
    // Warning(cTplType + " " + cIdTpl + MSG051)
    uValue := eval(bValue)
  endif
  // [960710] : wenn Textblock nicht existiert, trotzdem nicht NIL
  // [20060321] : wenn Textblock nicht existiert: return uValue
close area
RETURN uValue
 
**
** TplExist()
**
FUNCTION TplExist(cTplType,cIdTpl)
local lExist := .f.
cIdTpl := padr(cIdTpl,LenIdTpl())
open area oTpl()
  seek cTplType + cIdTpl + MemLang1
  if ! eof()
    lExist := .t.
  endif
close area
RETURN lExist
 

**
** PrintTemplate()
**
** locates specified tpl and parses it to printer (using PrnStream())
**
FUNCTION PrintTemplate(cTplType,cIdTpl,cPreview,bTitBlock,;
  bPrePrint,cIdOpt,lDlg,lAsPdf,lAsMail)
local tpl
if (tpl := TplValue(cTplType,cIdTpl,{|| TplInfo()})) == NIL
  SetMsg(cTplType+":"+cIdTpl+" : unbekannte Druckmaske!")
  RETURN .f.
endif
default cIdOpt to tpl[TPL_IDOPT]
RETURN .f. if ! OpenPrinter( ;
  cIdOpt,cPreview, ;
  tpl[TPL_WIDTH],bTitBlock, ;
  NIL,bPrePrint,tpl[TPL_IDDLG], lDlg, lAsPdf, lAsMail ;
)
  p_MsgDisplay(tpl[TPL_NAME])
  TplParse(hardcr(tpl[TPL_MEMO]))
ClosePrinter()
RETURN (LstError() == PRN_DONE)


**
** TplInclude()
**
FUNCTION TplInclude(cIdTpt,cIdTpl)
local tpl
local nPos
cIdTpl := trim(cIdTpl)
if (nPos := at(" ",cIdTpl)) != 0
  cIdTpt := left(cIdTpl,nPos-1)
  cIdTpl := alltrim(substr(cIdTpl,nPos+1))
endif
RETURN .t. if empty(cIdTpl)
cIdTpl := trim(cIdTpl)
if (tpl := TplValue(cIdTpt,cIdTpl,{|| TplInfo()})) == NIL
  SetMsg(cIdTpt+":"+cIdTpl+" : unbekannte Druckmaske!")
  RETURN .f.
endif
RETURN NIL if empty(tpl[TPL_MEMO])
if !empty(tpl[TPL_IDOPT])
  RETURN .f. if ! PpsExec(tpl[TPL_IDOPT])
endif
if !empty(tpl[TPL_WIDTH])
  p_SetWidth(tpl[TPL_WIDTH])
endif
// RETURN .f. if ! PrnPrepare()
RETURN TplParse(hardcr(tpl[TPL_MEMO]))


FUNCTION TplConfig(cTitle)
if saTpt == NIL ; TptRefresh() ; endif
default cTitle to MSG001
browse array saTpt ;
             using {|tpt| padr(tpt[TPT_ID] + " " + tpt[TPT_NAME],50) } ;
             enter {|tpt| TptEnter(tpt) } ;
             delete {||.f.} ;
             title (cTitle) ;
             help "TPT"
RETURN .f.

FUNCTION TptEnter(tpt)
RETURN NIL if tpt == NIL
RETURN TplEdit(tpt, tpt[TPT_NAME])

FUNCTION PickTpt(cStart)
local nStart := 0
local i
if saTpt == NIL ; TptRefresh() ; endif
for i := 1 to len(saTpt)
  if saTpt[i][TPT_ID] == cStart
    nStart := i
  endif
next i
browse array saTpt ;
             using {|tpt| ;
               padr(tpt[TPT_ID] + " " + tpt[TPT_NAME],40) ;
             } ;
             start nStart ;
             delete {||.f.} ;
             title (MSG001) ;
             help "TPT"
RETURN NIL if lastchoice() == 0
RETURN saTpt[lastchoice()][TPT_ID]

*FUNCTION PickTcsParam(cIdTca,cIdTcs)
*local c := ""
** alert(cIdTca + " " + cIdTcs)
*if cIdTca == "set"
*      if cIdTcs == "set driver"  ; c := PickDrv()
*  elseif cIdTcs == "set font"    ; c := PickFnt()
*  elseif cIdTcs == "set outport" ; c := PickPort()
*  elseif cIdTcs == "set special" ; c := PickDrvSpecial()
*  elseif cIdTcs == "set header"  ; c := PickTpl(TPLTYPE_HDR,NIL,NIL,{||trim(TPL->IdTpl)})
*  endif
*elseif cIdTca == "etc"
*      if cIdTcs == "etc include" ; c := PickTpl(TPLTYPE_INC,NIL,NIL,{||trim(TPL->IdTpl)})
*  elseif cIdTcs == "etc nextjob" ; c := PickTpl(TPLTYPE_INI,NIL,NIL,{||trim(TPL->IdTpl)})
*  endif
*endif
*RETURN c

*FUNCTION p_DlgPeriode
*local dlg := array(DLG_ALEN)
*dlg[DLG_CHECKBOX] := .f.
*dlg[DLG_CAPTION] := "Periode"
*dlg[DLG_GET] := GetNew( row(),col(), ;
*  {|x| GsbPeriode(x) }, ;
*  NIL, PIC_ID ;
*)
*dlg[DLG_GET]:cargo := array(AG_ALEN)
*p_AddDlg(dlg)
*RETURN NIL

** remove leading and trailing "s
FUNCTION OhneAnf(c)
RETURN c if left(c,1) != '"'
c := substr(c,2)
c := left(c,len(c)-1)
RETURN c


#ifdef DEF_FIN

**
** FinFnlList()
**
FUNCTION FinFnlList(cParam)
open area oFnl(), oGen(), oPar()
  softseek FIN->IdJnl + FIN->IdDoc
  do while ! eof() .and. FNL->IdJnl == FIN->IdJnl ;
                   .and. FNL->IdDoc == FIN->IdDoc
    if empty(FNL->IdCtr)
      seek left(FNL->IdCpt,LenIdGen()) in GEN
    else
      seek left(FNL->IdCpt,LenIdPar()) in PAR
    endif
    TplParse(OhneAnf(cParam))
    skip
  enddo
close area
RETURN NIL

#endif DEF_FIN


**
** PickTpl()
**
FUNCTION PickTpl( cIdTpt, cStart, cLangue, bResult, cTitle, cHelp )
local uReturn := NIL
local tpt
local b := oTpl()
local cIdQry
local cOldLng := SetTplLang()
if cIdTpt == TPLTYPE_INI .and. SetActivePps()
  if !empty(cStart)
    cStart := trim(cStart)+".PPS"
  endif
  cStart := FilePick("*.PPS",NIL,NIL,NIL,cStart)
  RETURN NIL if cStart == NIL
  cStart := strtran(cStart,".PPS","")
  RETURN padr(cStart,LenIdTpl())
endif
if (tpt := TptLocate(cIdTpt))== NIL
  Warning(cIdTpt + MsgTptExist() ) // " : unbekannte Textblock-Art !")
  RETURN NIL
endif
default bResult to {||TPL->IdTpl}
if cLangue != NIL
  SetTplLang(cLangue)
endif
if left(tpt[TPT_IDQRY],1) == "="
  cIdQry := xparse(substr(tpt[TPT_IDQRY],2))
else
  cIdQry := "TPL" + tpt[TPT_IDQRY]
endif
open area b
    default cStart to ""
    default cTitle to "Druckmaske " + tpt[TPT_NAME]
    softseek cIdTpt + trim(cStart)
    edit data b key     TPL->IdTpt ;
                value   cIdTpt ;
                create  {||TplCreate(cIdTpt)} ;
                query   (cIdQry) ;
                mode    pick ;
                filter  "empty(TPL->Filter).or.ctol(trim(TPL->Filter))" ;
                title   (cTitle) ;
                help    (cHelp)
    if ddLastReq() == DDEDIT_SELECT
      uReturn := eval(bResult)
    endif
close area
if cLangue != NIL
  SetTplLang(cOldLng )
endif
RETURN uReturn

FUNCTION MsgTptExist()
#ifdef LG_GERMAN
  RETURN " : unbekannte Textblock-Art !"
#else
  RETURN " : type de masque non d‚fini !"
#endif

FUNCTION TplInfo
local a := array(TPL_ALEN)
a[TPL_IDTPL]  := TPL->IdTpl
a[TPL_WIDTH]  := val(TPL->Width)
a[TPL_IDOPT]  := TPL->IdOpt
a[TPL_NAME ]  := trim(TPL->Name)
a[TPL_ATTRIB] := TPL->Attrib
a[TPL_MEMO ]  := TplMemo()
a[TPL_IDDLG]  := trim(TPL->IdDlg)
RETURN a


#ifdef DEF_TPLTEXT

FUNCTION TplMemoFile(cIdLng)
RETURN DbPath()+"\TPL\"+trim(TPL->IdTpt)+trim(TPL->IdTpl)+trim(cIdLng)+".TPL"

FUNCTION TplMemo
local c := ""
if TplLang() == MemLang3
  c := memoread(TplMemoFile(MemLang3))
  RETURN c if ! empty(c)
elseif TplLang() == MemLang2
  c := memoread(TplMemoFile(MemLang2))
  RETURN c if ! empty(c)
endif
RETURN memoread(TplMemoFile(MemLang1))

#else

FUNCTION TplMemo
RETURN TPL->Memo3 if TplLang() == MemLang3 .and. ! empty(TPL->Memo3)
RETURN TPL->Memo2 if TplLang() == MemLang2 .and. ! empty(TPL->Memo2)
RETURN TPL->Memo1

#endif DEF_TPLTEXT


**
** BlkPick()
**
FUNCTION BlkPick()
local cTexte := NIL
local tpt := TptLocate(TPLTYPE_BLK)
local b := oTpl()
local cIdQry
static cStart := ""
RETURN NIL if tpt == NIL
if left(tpt[TPT_IDQRY],1) == "="
  cIdQry := xparse(substr(tpt[TPT_IDQRY],2))
else
  cIdQry := "TPL" + tpt[TPT_IDQRY]
endif
open area b
  softseek TPLTYPE_BLK + cStart
  if TPL->IdTpt != TPLTYPE_BLK
    goto lastrec() + 1
  endif
  edit data b key     TPL->IdTpt ;
              value   TPLTYPE_BLK ;
              create  {||TplCreate(TPLTYPE_BLK)} ;
              query   (cIdQry) ;
              mode    pick ;
              title (MSG036 + tpt[TPT_NAME])
  if ddLastReq() == DDEDIT_SELECT
    cStart := TPL->IdTpl
    if empty(TPL->IdDlg).or.DlgExec(TPL->IdDlg)
      cTexte := StrParse(TplMemo())
      if empty(cTexte)
        cTexte := trim(TPL->Name)
      endif
    endif
  endif
close area
RETURN cTexte

**
** TplEdit()
**
FUNCTION TplEdit(tpt,cTitle)
local b := oTpl()
local cIdQry
if left(tpt[TPT_IDQRY],1) == "="
  cIdQry := xparse(substr(tpt[TPT_IDQRY],2))
else
  cIdQry := "TPL" + tpt[TPT_IDQRY]
endif
open area b
  edit data b key TPL->IdTpt value tpt[TPT_ID] ;
    create    {||TplCreate(tpt[TPT_ID])} ;
    start     top ;
    mode      find ;
    query     (cIdQry) ;
    title (cTitle)
close area
RETURN .f.

**
** TplWait()
**
FUNCTION TplWait(win)
local b
if nextkey() != 0
  RETURN NIL
elseif win[WIN_WAITKEY] == 12
  MemoDisplay(TplMemo(), ;
    win[WIN_TOP], ;
    win[WIN_LEFT], ;
    win[WIN_HEIGHT], ;
    win[WIN_WIDTH], ;
    NIL, NIL, 250, ;
  )
endif
RETURN .f.


**
** TplCreate()
**
FUNCTION TplCreate(cIdTpt,cIdTpl,cName)
local aBuf    := CopyRec()
local cCopier := BUTTON_OFF
#ifdef DEF_TPLTEXT
local aMemos := { ;
  memoread(TplMemoFile(MemLang1)), ;
  memoread(TplMemoFile(MemLang2)), ;
  memoread(TplMemoFile(MemLang3)) }
#endif DEF_TPLTEXT
default cName to TPL->Name
default cIdTpl to TPL->IdTpl
open window ("Textblock erstellen") size 5,60 help TPLCREA
do while .t.
  WinHome()
  say "Identifikation "
  @ row(), col() get cIdTpl picture PIC_ID
  WinCr()
  say "Bezeichnung "
  @ row(), col() get cName
  WinCR()
  @ row(), col() get cCopier checkbox
  say MsgCopy()
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cIdTpt + cIdTpl)
    SetMsg(MsgIdExist()) // Cette identification existe d‚j….
    loop
  endif
  exit
enddo
close window
RETURN DDCREATE_FAIL if ! dbAddRec()
if cCopier == BUTTON_ON
  PasteRec(aBuf)
  #ifdef DEF_TPLTEXT
    memowrit(TplMemoFile(MemLang1),aMemos[1])
    if ! empty(aMemos[2])
      memowrit(TplMemoFile(MemLang2),aMemos[2])
    endif
    if ! empty(aMemos[3])
      memowrit(TplMemoFile(MemLang3),aMemos[3])
    endif
  #endif DEF_TPLTEXT
endif
TPL->IdTpt   := cIdTpt
TPL->IdTpl   := cIdTpl
TPL->Name    := cName
if empty(TPL->Width)
  TPL->Width := " 76"
endif
RETURN DDCREATE_DONE


#ifdef DEF_TPLTEXT

FUNCTION TplMemoEdit()
local cFilename
static cIdLng
if TPL->IdTpt == TPLTYPE_INI
  SetTplLang(MemLang1)
else
  RETURN .f. if (cIdLng := PickLng(cIdLng,MemLang1+MemLang2+MemLang3)) == NIL
  SetTplLang(cIdLng)
endif
cFilename := TplMemoFile(TplLang())
if ! file(cFilename)
  memowrit(cFilename,"")
endif
RETURN FileEdit(cFilename)

#else

FUNCTION TplMemoEdit()
local nHeight := 20
local nWidth  := 80
local cDlmPath
local cTitle
static cIdLng
local bFldBlock
if TPL->IdTpt == TPLTYPE_INI
  if SetActivePps()
    RETURN FileEdit(trim(TPL->IdTpl)+".PPS")
    * cDlmPath := GetDlmPath(trim(TPL->IdTpl)+".PPS")
    * if cDlmPath == NIL
    *   Warning(SetMsg())
    *   RETURN .f.
    * endif
    * bFldBlock := {|x| FileGetSet(cDllPath,x) }
  endif
  bFldBlock := fieldblock("Memo1")
  SetTplLang(MemLang1)
  nHeight := 12
  nWidth  := 60
else
  RETURN .f. if (cIdLng := PickLng(cIdLng,MemLang1+MemLang2+MemLang3)) == NIL
  if cIdLng == MemLang3
    bFldBlock := fieldblock("Memo3")
    SetTplLang(MemLang3)
  elseif cIdLng == MemLang2
    bFldBlock := fieldblock("Memo2")
    SetTplLang(MemLang2)
  elseif cIdLng == MemLang1
    bFldBlock := fieldblock("Memo1")
    SetTplLang(MemLang1)
  else
    RETURN .f.
  endif
endif
RETURN MnuDone() if ! ddRecLock()
if TPL->IdTpt == TPLTYPE_BLK
  if empty(eval(bFldBlock))
    eval(bFldBlock, trim(TPL->Name))
  endif
endif
open window (TPL->IdTpt + "-Druckmaske " + trim(TPL->IdTpl) + ;
          " (" + TplLang() + ")" ) ;
     size nHeight,nWidth
  TxtEdit( ;
    bFldBlock, ;
    WinTop(), WinLeft() , WinEndY(), WinEndX(), ;
    ddOnPreEdit(oTpl()), 250  ; // ,  {|| PickTcs(TPL->IdTpt)} ;
  )
close window
unlock record
RETURN .f.

#endif DEF_TPLTEXT

**
** TplPrint
**
FUNCTION TplPrint()
local i
local cTexte := TplMemo()
SetMnuDone()
RETURN .f. if ! OpenPrinter(TPL->IdOpt,NIL,val(TPL->Width))
* open printer (TPL->IdOpt) width val(TPL->Width)
for i := 1 to mlcount(cTexte, val(TPL->Width))
  PrintLine(memoline(cTexte, val(TPL->Width), i ))
next i
close printer
RETURN .t. // SetMnuDone()




