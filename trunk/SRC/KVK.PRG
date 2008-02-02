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


#ifdef DEF_KVK

* #define KVKSTAT_1      "1"
* #define KVKSTAT_2      "2"
* #define KVKSTAT_3      "3"

static scArtPrice := NIL
static saJnl      := NIL
static snKvlCount := 0
static snKvkCount := 0
static sdKvkDate1
static sdKvkDate2

**
** KVK - Kassenscheine
**
FUNCTION oKvk
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name KVK                   ;
  predelete  KvkPreDelete()     ;
  predelete  KvkPreDelete()     ;
  preedit    KvkPreEdit()    ;
  create     DDCREATE_FAIL   ;
  postedit   KvkPostEdit()   ;
  editprint  KvkDlgPrint()   ;
  wait       {|x| KvkWait(x)}
ddIndex b on KVK->IdJnl+KVK->IdDoc                   // ORD_KVK_ID
ddIndex b on dtos(KVK->Date)+KVK->Time               // ORD_KVK_DATE
ddFld IdJnl    ,C, LenIdJnl(),0  picture PIC_ID when .f.
ddFld IdDoc    ,C, LEN_IDDOC,0  picture PIC_ID when .f.
ddFld Date     ,D, 8,0 // when KVK->Etat == DocStatOpen()
ddFld IdPar    ,C, LenIdPar(),0  GET_PAD ;
                   pick PickPar( ;
                     CtrPrtList(JnlIdCtr(KVK->IdJnl)), ;
                     KVK->IdPar ;
                   ) ;
                   valid ph_refresh()
                   // when KVK->Etat == DocStatOpen()
ddFld Etat     ,C, 1,0  picture "!"  when .f.
ddFld IdUsr    ,C,LenIdUsr(),0   picture PIC_ID
                   // when KVK->Etat == DocStatOpen()
ddFld Mont     ,T, LenMont(),0 when .f.
ddFld IdZla1   ,C,LEN_IDZLA,0  picture PIC_ID ;
                pick PickZla(KVK->IdZla1,ZLA_IDZLA) ;
                valid KvkZla1Validate()
                // when KVK->Etat == DocStatClosed()
ddFld IdZla2   ,C,LEN_IDZLA,0  picture PIC_ID ;
                pick PickZla(KVK->IdZla2,ZLA_IDZLA) ;
                valid KvkZla2Validate()
                // when KVK->Etat == DocStatClosed()
ddFld Mont1    ,T, LenMont(),0 ;
                GET_DECPOS(ZlaDecPos(KVK->IdZla1,KVK->IdCtr)) ;
                valid KvkMontValidate()
                // when KVK->Etat == DocStatClosed()
ddFld Mont2    ,T, LenMont(),0 ;
                GET_DECPOS(ZlaDecPos(KVK->IdZla2,KVK->IdCtr)) ;
                valid KvkMontValidate()
                // when KVK->Etat == DocStatClosed()
ddFld IdCtr    ,C, LEN_IDCTR,0  ;
                   picture PIC_ID pick PickCtr(KVK->IdCtr) ;
                   valid CtrExist(KVK->IdCtr)
ddFld Periode , C, LEN_PERIODE,0 picture PIC_ID ;
                   pick PickPer(KVK->Periode,KVK->IdJnl)
ddFld Time    , C, 8,0 when .f.
*
action b key K_ENTER prompt NIL block KvkEnter()
action b key K_CTRL_F2 prompt MnuClose() block KvkDlgClose(.t.)
action b key K_SH_F5  prompt MnuParPage() block ParPage(KVK->IdPar)
#ifdef DEF_HST
  action b key K_F9   prompt MnuHstEdit() ;
           block ParHstEdit(KVK->IdPar)
  action b key K_CTRL_F9 prompt MnuDocHstEdit() ;
           block DocHstEdit(KVK->IdJnl,KVK->IdDoc)
  action b key K_ALT_F9  prompt MnuHstMatch() ;
           block MatchHstEdit(KVK->IdPar,KvkMatch())
#endif DEF_HST
ddEndDef()
RETURN b

FUNCTION KvkMatch()
RETURN KVK->IdJnl+KVK->IdDoc

**
** KVL - Lignes de KVK
**
FUNCTION oKvl()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name KVL ;
  preedit   KvlPreEdit() ;
  postedit  KvlPostEdit() ;
  predelete .t. //   DDDEL_NOCONFIRM
ddIndex b on KVL->IdJnl+KVL->IdDoc+KVL->Line      // ORD_KVL_DOC
ddIndex b on KVL->IdArt                           // ORD_KVL_ART
* #ifdef DEF_SER
*   ddIndex b on  KVL->IdSer // ORD_KVL_IDSER
* #endif
ddFld IdJnl    ,C, LenIdJnl(),0 when .f.
ddFld IdDoc    ,C, LEN_IDDOC,0 when .f.
ddFld Line     ,C, LEN_POS,0
ddFld IdArt    ,C, LenIdArt(),0 picture PIC_ID ;
                   pick PickArt(KVL->IdArt) ;
                   postedit {|x| GetIdArt(x) } ;
                   valid KvlArtValidate()
ddFld IdGen    ,C, LenIdGen(),0 picture PIC_ID ;
                   pick PickGen(NIL,KVL->IdGen,"!'"+GENATTR_H+"'$GEN->Attrib") ;
                   postedit {|x| GetIdGen(x) } ;
                   valid KvlGenValidate()
ddFld Match    ,C, LenIdJnl()+LEN_IDDOC,0 picture PIC_ID
ddFld NB       ,C, 30,0
ddFld DC       ,C, 1,0 picture "!" valid DcValidate(KVL->DC)
ddFld Qte      ,C, LenQte(),0 GET_NUM ;
                   valid KvlQteValidate()
ddFld PrixU    ,T, LenMont(),0 GET_MONTANT ;
                   valid KvlPuValidate()
ddFld Mont     ,T, LenMont(),0 GET_MONTANT
ddFld _Debit   ,T, LenMont(),0  GET_NUM attrib V when .t. ;
                   block {|x| GsbMontD(x) }
ddFld _Credit  ,T, LenMont(),0  GET_NUM attrib V when .t. ;
                   block {|x| GsbMontC(x) }
ddFld _Libell ,C,40,0 attrib V ;
                      when .t. block {|x| KvlLibell(x) }
#ifdef DEF_SER
ddFld IdSer    ,C, LenIdSer(),0 ;
                   postedit {|x| GetIdSer(x) } ;
                   valid KvlSerValidate() ;
                   pick PickSer(KVL->IdSer,KVL->IdArt,KVK->Date)
#else
ddFld IdSer    ,C, 0,0 attrib H
#endif DEF_SER
action b key K_SH_F4     prompt MnuArtPage() block ArtPage(KVL->IdArt)
action b key K_CTRL_RET  prompt NIL block KvlDetail()
action b key K_SH_F5      prompt MnuParPage() block ParPage(KVK->IdPar)
#ifdef DEF_VNA
  action b key K_F6   prompt MSG016 ;
           block ParVnaEdit(KVK->IdPar)
#endif
#ifdef DEF_HST
  action b key K_F9   prompt MnuHStEdit() ;
           block ParHstEdit(KVK->IdPar)
#endif DEF_HST
action b key K_ENTER prompt MsgMnuDocPage() ;
                     block DocPage(KVL->IdJnl,KVL->IdDoc) ;
                     when indexord() == ORD_KVL_ART
#ifndef DEF_TAX
  ddFldRemove("IdTax")
  ddFldRemove("MontT")
  ddFldRemove("_TVAC")
#endif DEF_TAX
ddEndDef()
RETURN b

**
** ZLA - Zahlarten
**
FUNCTION oZla()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name ZLA
ddIndex b on   ZLA->IdZla
ddFld IdCtr    ,C, LEN_IDCTR,0 picture PIC_ID
ddFld IdZla    ,C, LEN_IDZLA,0 picture "!"
ddFld Name     ,C, 20,0
ddFld Name2    ,C, 0,0 attrib H
ddFld IdDev    ,C, LEN_IDDEV,0 picture PIC_ID ;
                   pick PickDev(ZLA->IdDev)
ddFld IdGen    ,C, LenIdGen(),0 picture PIC_ID ;
                   pick PickGen(NIL,ZLA->IdGen)
ddEndDef()
RETURN b


FUNCTION KvkZla1Validate
local zla   := ZlaLocate(KVK->IdZla1,KVK->IdCtr)
RETURN ph_refresh() if zla == NIL
KVK->Mont2  := ""
KVK->IdZla2 := ""
KVK->Mont1 := ntom(val(KVK->Mont) / zla[ZLA_COURS],zla[ZLA_DECPOS])
RETURN ph_refresh()

FUNCTION KvkZla2Validate
local zla := ZlaLocate(KVK->IdZla1,KVK->IdCtr)
local nMont
if zla == NIL
  KVK->Mont2 := ""
  RETURN ph_refresh()
endif
nMont := val(KVK->Mont1) * zla[ZLA_COURS]
RETURN ph_refresh() if (zla := ZlaLocate(KVK->IdZla2,KVK->IdCtr)) == NIL
KVK->Mont2 := ntom((val(KVK->Mont)-nMont) / zla[ZLA_COURS],zla[ZLA_DECPOS])
RETURN ph_refresh()

FUNCTION KvkMontValidate
local zla1 := ZlaLocate(KVK->IdZla1,KVK->IdCtr)
local zla2
RETURN ph_refresh() if zla1 == NIL
if empty(KVK->Mont1)
  KVK->Mont2  := ""
  KVK->IdZla2 := ""
  KVK->Mont1 := ntom(val(KVK->Mont) / zla1[ZLA_COURS],zla1[ZLA_DECPOS])
  RETURN ph_refresh()
endif
if empty(KVK->IdZla2)
  KVK->IdZla2 := IdZlaDefault()
endif
RETURN ph_refresh() if (zla2 := ZlaLocate(KVK->IdZla2,KVK->IdCtr)) == NIL
KVK->Mont2 := ntom( ;
  (val(KVK->Mont) - (val(KVK->Mont1) * zla1[ZLA_COURS])) / zla2[ZLA_COURS], ;
  zla2[ZLA_DECPOS] ;
)
* KVK->Mont1 := ntom(val(KVK->Mont) * zla2[ZLA_COURS],zla2[ZLA_DECPOS])
RETURN ph_refresh()

FUNCTION KvkPreDelete()
local lOkay := .f.
local jnl := JnlLocate(KVK->IdJnl)
*if ! empty(KVK->IdPar) .and. ! empty(KVK->Mont)
*  RETURN .f. if ! Confirm( ;
*    MsgIdJnlDoc() + MsgDocDelete(), ;
*    NIL, MSG_YES, "WRN003" ;
*  )
*endif
* RETURN .f. if jnl == NIL
RETURN .f. if ! DocDelete(jnl,KVK->IdDoc)
if ddRecLock()
  open area oKvl()
    lOkay := .t.
    softseek KVK->IdJnl + KVK->IdDoc
    do while ! eof() .and. KVL->IdJnl == KVK->IdJnl ;
                     .and. KVL->IdDoc == KVK->IdDoc
      if ddRecLock()
        delete
      else
        lOkay := .f.
        exit
      endif
      skip
    enddo
  close area
  unlock record
endif
RETURN lOkay
* RETURN DDDEL_NOCONFIRM


FUNCTION KvkPreEdit()
RETURN .t. if KVK->Etat == DocStatOpen()
SetMsg(MsgIdJnlDoc() + MsgIsClosed())
RETURN .f.

FUNCTION KvkPostEdit()
local jnl := JnlLocate(KVK->IdJnl)
local zla
local nMont
RETURN .f. if lastkey() == K_ESC
RETURN .f. if jnl == NIL
RETURN .f. if ! ParExist(KVK->IdPar)
RETURN .t. if KVK->Etat == DocStatClosed()
* RETURN .t. if KVK->Etat == KVKSTAT_3
if empty(KVK->Mont)
  if KvkKvlEval(jnl,{||KvkKvlEdit(jnl)})
    if ddLastKey() == K_F10
      ddEditChange(.t.)
      RETURN .f.
    endif
  endif
endif
if (zla := ZlaLocate(KVK->IdZla1,KVK->IdCtr)) == NIL
  SetMsg(KVK->IdZla1 + " : ungltige Zahlart !")
  RETURN .f.
endif
nMont := val(KVK->Mont1) * zla[ZLA_COURS]
if ! empty(KVK->IdZla2)
  if (zla := ZlaLocate(KVK->IdZla2,KVK->IdCtr)) == NIL
    SetMsg(KVK->IdZla2 + " : ungltige Zahlart !")
    RETURN .f.
  endif
  nMont += val(KVK->Mont2) * zla[ZLA_COURS]
endif
if KVK->Mont != ntom(nMont)
  Warning( ;
    "Bleibt zu zahlen : " + DevDefault(KVK->Periode) + " " + ;
    ltrim(ntom(val(KVK->Mont)-nMont)) ;
     ;
  )
  RETURN .f.
endif
KvkDlgClose(.t.)
RETURN .f. if KVK->Etat == DocStatOpen()
SendKey(K_INS)
RETURN .t.


FUNCTION KvkDlgPrint()
local jnl := JnlLocate(KVK->IdJnl)
RETURN .f. if jnl == NIL
RETURN .f. if ! ddRecLock()
KvkPrint(jnl)
unlock record
RETURN MnuDone()

**
** KvkWait()
**
FUNCTION KvkWait(wwin)
local b
local jnl := JnlLocate(KVK->IdJnl)
if nextkey() != 0
  RETURN NIL
elseif wwin[WIN_WAITKEY] == 1 // „hnlich wie KvkKvlEdit()
  RETURN ClearWaitWin(wwin) if jnl == NIL
  b := oKvl()
  open area b, oArt(), oGen()
    edit data b key   KVL->IdJnl + KVL->IdDoc ;
                value KVK->IdJnl + KVK->IdDoc ;
                mode  wait ;
                window wwin ;
                start top ;
                query ("KVL"+jnl[JNL_IDDBV])
  close area
endif
RETURN MnuDone()


FUNCTION KvkEnter
local jnl := JnlLocate(KVK->IdJnl)
RETURN .f. if jnl == NIL
RETURN .f. if ! ddRecLock()
if KvkKvlEval(jnl,{||KvkKvlEdit(jnl)})
  if KVK->Etat == DocStatOpen()
    if ddLastKey() == K_F10
      ddEditChange(.t.)
    endif
  endif
endif
unlock record
RETURN NIL



**
** KvkKvlEval()
**
FUNCTION KvkKvlEval(jnl,bEval)
local aJnl      := saJnl
local cArtPrice := scArtPrice
RETURN .f. if ! ParExist(KVK->IdPar)
scArtPrice := PgpArtPrice(PAR->IdPgp,PAR->IdPrt,KVK->IdCtr)
if scArtPrice == NIL
  Warning( ;
    PAR->IdPgp + " : Preisgruppe Partner nicht erlaubt", ;
    "fr " + trim(PrtName(PAR->IdPrt)) + " & " + ;
    CtrName(KVK->IdCtr) ;
  )
  * scArtPrice := cArtPrice
  * RETURN .f.
  * bEval wird trotzdem ausgefhrt, aber KvlPreEdit() .f.
endif
saJnl    := jnl
eval(bEval)
scArtPrice := cArtPrice
saJnl      := aJnl
RETURN .t.



FUNCTION KvlPreEdit()
if KVK->Etat == DocStatClosed()
  SetMsg(MsgIdJnlDoc() + MsgIsClosed())
  RETURN .f.
endif
RETURN .f. if scArtPrice == NIL
RETURN .t.

FUNCTION KvlPostEdit()
if empty(KVL->Mont)
  SetMsg("(Betrag eingeben)")
  RETURN .f.
endif
RETURN .t.

#ifdef DEF_SER

FUNCTION KvlSerValidate()
local ipb
RETURN .t. if empty(KVL->IdSer)
if empty(KVL->Qte)
  KVL->Qte    := ntoq(1,"")
endif
if SerExist(KVL->IdSer)
  KVL->IdArt := SER->IdArt
  KVL->PrixU := &("SER->" + scArtPrice)
elseif Confirm(trim(KVL->IdSer) + " : neue Seriennummer erstellen (J/N) ?")
  select SER
  SerCreate(KVL->IdArt,KVK->Date,KVL->IdSer)
  select KVL
  RETURN .f. if ! SerExist(KVL->IdSer)
else
  RETURN .f.
endif
RETURN .f. if ! ArtExist(KVL->IdArt)
RETURN .f. if ! KvlIpbApply()
RETURN KvlPuValidate()

#endif DEF_SER

FUNCTION KvlArtValidate()
RETURN .t. if empty(KVL->IdArt)
RETURN .f. if ! ArtExist(KVL->IdArt)
KVL->PrixU := &("ART->" + scArtPrice)
if empty(KVL->Qte)
  KVL->Qte    := ntoq(1,"")
endif
#ifdef DEF_SER
  if ARTATTR_N $ ART->Attrib .and. PARATTR_N $ PAR->Attrib
    if empty(KVL->IdSer)
      KVL->IdSer := IdSerDefault()
    endif
    if empty(KVL->IdArt)
      seek KVL->IdSer in SER
      KVL->IdArt := SER->IdArt
    else
      select SER
      seek KVL->IdSer
      if ! eof()
        if ddRecLock()
          SER->IdArt := KVL->IdArt
          unlock record
        endif
      endif
      select KVL
    endif
    if ! KvlSerValidate()
      KVL->IdSer := ""
    endif
    RETURN .t.
  endif
#endif DEF_SER
RETURN .f. if ! KvlIpbApply()
RETURN KvlPuValidate()

FUNCTION KvlIpbApply()
local ipb
if empty(ART->IdGen)
  ... sh. 20030412
  if (ipb := IpbLocate(KVK->IdCtr,PAR->IdReg,ART->IdCat,NIL,DevDefault(KVK->Periode))) == NIL
    SetMsg(PAR->IdReg + "/" + ART->IdCat + " : ohne Buchungsanweisung !")
    RETURN .f.
  endif
  KVL->IdGen := ipb[IPB_GENBASE]
else
  KVL->IdGen := ART->IdGen
endif
RETURN .t.

FUNCTION KvlGenValidate()
RETURN .t. if empty(KVL->IdGen)
RETURN .f. if ! GenExist(KVL->IdGen)
RETURN .t.

FUNCTION KvlQteValidate()
KVL->Mont := ntom(qton1(KVL->Qte)*val(KVL->PrixU))
RETURN .t.


FUNCTION KvlPuValidate()
KVL->Mont := ntom(val(KVL->PrixU) * qton1(KVL->Qte))
#ifdef DEF_SER
  if ! empty(KVL->IdSer)
    if empty(KVL->PrixU)
      seek KVL->IdSer in SER
      KVL->PrixU := &("SER->"+scArtPrice)
    else
      select SER
      seek KVL->IdSer
      if ! eof()
        if ddRecLock()
          &("SER->" + scArtPrice) := KVL->PrixU
          unlock record
        endif
      endif
      select KVL
    endif
  endif
#endif
RETURN .t.

FUNCTION KvlDetail()              ; RETURN .f.

**
** KvkBetrieb()
**
FUNCTION KvkBetrieb(cIdJnl,cIdPar,cTitle)
local b := oKvk()
local jnl
local lOkay := .t.
RETURN NIL if (jnl := JnlLocate(cIdJnl)) == NIL
open area b, oPar()
  KeyGoBottom( jnl[JNL_IDJNL], "KVK->IdJnl")
  if ! eof()
    if KVK->Etat == DocStatOpen()
      Warning( ;
        MsgPrevDoc() + MsgNotClosed(), ;
        "Beenden Sie zun„chst den letzten Kassenschein !" ;
      )
      lOkay := .f.
    endif
  endif
  if lOkay
    SendKey(K_INS)
  endif
  edit data b mode find ;
    key   KVK->IdJnl ;
    value jnl[JNL_IDJNL] ;
    query ("KVK"+jnl[JNL_IDDBV]) ;
    create   {||DocCreate( ;
      jnl, ;
      {|cIdDoc|KvkCreate(jnl,cIdDoc,cIdPar) } ;
    )} ;
    title (cTitle) ;
    full ;
    noconfirm
close area
RETURN .f.

**
** KvkEdit()
**
FUNCTION KvkEdit(cDate,cTitle,cIdQry)
local b := oKvk()
local nLen
default cDate to dtos(UserDate())
default cIdQry to "KVKDATE"
nLen := len(cDate)
open area b, oPar()
  ddSetOrder(ORD_KVK_DATE)
  edit data b mode find ;
    key   ( "left(dtos(KVK->Date),"+ntrim(nLen)+")" ) ;
    value cDate ;
    query (cIdQry) ;
    create {||DDCREATE_FAIL} ;
    title (cTitle) ;
    noconfirm
close area
RETURN .f.

**
** KvkCreate()
**
FUNCTION KvkCreate( jnl, cIdDoc, cIdPar )
local nOrder := indexord()
ddSetOrder(1)
KeyGoBottom( jnl[JNL_IDJNL], "KVK->IdJnl" )
ddSetOrder(nOrder)
if ! eof()
  if KVK->Etat == DocStatOpen()
    RETURN DDCREATE_FAIL if ! Confirm( ;
      MsgPrevDoc() + MsgNotClosed(), MsgDocCreate(), ;
      MSG_NO, "WRN018" ;
    )
  endif
endif
if empty(cIdPar)
  RETURN DDCREATE_FAIL if (cIdPar := PickPar( ;
    CtrPrtList(jnl[JNL_IDCTR]), KVK->IdPar, ;
    jnl[JNL_IDJNL] + " " + cIdDoc + " erstellen fr :";
  )) == NIL
endif
if ! IsNewId(jnl[JNL_IDJNL] + cIdDoc)
* seek jnl[JNL_IDJNL] + cIdDoc
* if ! eof()
  Warning( ;
    jnl[JNL_IDJNL] + " " + cIdDoc + MsgDocExist(), ;
    NIL, "WRN014" ;
  )
  RETURN DDCREATE_FAIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
KVK->IdDoc    := cIdDoc
KVK->IdJnl    := jnl[JNL_IDJNL]
KVK->IdCtr    := jnl[JNL_IDCTR]
KVK->Date     := UserDate()
KVK->Time     := time()
KVK->Etat     := DocStatOpen()
KVK->Periode  := PerActive()
* if cIdPar != NIL
  KVK->IdPar := cIdPar
* endif
dbcommit()
if KvkKvlEval(jnl,{||KvkKvlEdit(jnl)})
endif
* unlock record
RETURN DDCREATE_FULL


**
** KvlCreate()
**
FUNCTION KvlCreate(jnl,cIdDoc)
local nCreate := DDCREATE_REFRESH
local cIdArt
local cLine := KVL->Line
local ctr := CtrLocate(KVK->IdCtr)
local nOrder := indexord()
RETURN DDCREATE_FAIL if ctr == NIL
RETURN DDCREATE_FAIL if ! KvkPreEdit()
if eof() // 20070801 recno() == lastrec() + 1
  nCreate := DDCREATE_EDIT
endif
ddSetOrder(1)
KeyGoBottom( jnl[JNL_IDJNL] + cIdDoc, "KVL->IdJnl+KVL->IdDoc" )
if empty(cLine)
  cLine := NextNum(KVL->Line)
else
  do while .t.
    if KVL->Line >= cLine
      if ddRecLock()
        KVL->Line := NextNum(KVL->Line)
        unlock record
      endif
    else
      exit
    endif
    skip -1
    if bof() .or. KVL->IdDoc != cIdDoc .or. KVL->IdJnl != jnl[JNL_IDJNL]
      exit
    endif
  enddo
endif
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
KVL->Line   := cLine
KVL->IdJnl  := jnl[JNL_IDJNL]
KVL->IdDoc  := cIdDoc
KVL->DC     := ctr[CTR_DC]
* unlock record 19980430
RETURN nCreate



**
** KvkKvlEdit()
**
FUNCTION KvkKvlEdit(jnl)
local cIdJnl := KVK->IdJnl
local cIdDoc := KVK->IdDoc
local b := oKvl()
local aMatch := ParHstTag(KVK->IdPar,"PARCASH")
local lOkay := .t.
local i
local cLine
local nMont
if KVK->Etat == DocStatOpen()
  if len(aMatch) > 0
    lOkay := .f.
    open area oKvl()
      lOkay := .t.
      KeyGoBottom( ;
        cIdJnl + cIdDoc, ;
        "KVL->IdJnl+KVL->IdDoc" ;
      )
      cLine := NextNum(KVL->Line)
      for i := 1 to len(aMatch)
        if aMatch[i][MATCH_IDCTR] == jnl[JNL_IDCTR]
          if dbAddRec()
            KVL->IdJnl := cIdJnl
            KVL->IdDoc := cIdDoc
            KVL->Line  := cLine
            KVL->Match := aMatch[i][MATCH_MATCH]
            KVL->NB    := aMatch[i][MATCH_LIBELL]
            if empty(KVL->NB)
              KVL->NB := aMatch[i][MATCH_MATCH]
            endif
            nMont := aMatch[i][MATCH_MONTD] - aMatch[i][MATCH_MONTC]
            if nMont > 0
              KVL->DC   := DC_DEBIT
              KVL->Mont := ntom(nMont)
            else
              KVL->DC   := DC_CREDIT
              KVL->Mont := ntom(-nMont)
            endif
            unlock record
            cLine := NextNum(cLine)
          else
            lOkay := .f.
            exit
          endif
        endif
      next i
    close area
  endif
endif
RETURN .f. if ! lOkay
open area b, oArt(), oGen(), oSer()
  edit data b       ;
            key    KVL->IdJnl + KVL->IdDoc ;
            value  cIdJnl + cIdDoc  ;
            create {||KvlCreate(jnl,cIdDoc)} ;
            before KvlBefore() ;
            after  KvlAfter() ;
            start top  ;
            mode   edit ;
            query  ("KVL" + jnl[JNL_IDCTR] ) ;
            title (MsgInhalt() + cIdJnl + " " + cIdDoc)
  nMont := 0
  softseek KVK->IdJnl + KVK->IdDoc
  do while ! eof() .and. KVL->IdJnl == KVK->IdJnl ;
                   .and. KVL->IdDoc == KVK->IdDoc
    if KVL->DC == jnl[JNL_DC]
      nMont += val(KVL->Mont)
    else
      nMont -= val(KVL->Mont)
    endif
    skip
  enddo
close area
KVK->Mont   := ntom(nMont)
KVK->IdZla1 := IdZlaDefault()
KvkZla1Validate()
RETURN .f.

FUNCTION KvlBefore() ; RETURN NIL
FUNCTION KvlAfter()  ; RETURN NIL

FUNCTION KvlLibell(x)
if x != NIL
  KVL->NB := x
  if empty(KVL->IdArt)
    KVL->IdArt := "*"
  endif
  RETURN NIL
endif
* if recno() == lastrec() + 1
*   RETURN padr("bleibt zu buchen :",40) if slIsTotal
*   RETURN padr("TOTAL :",40)
* endif
RETURN KVL->NB if ! empty(KVL->NB)
RETURN padr(KvlObjName(),30)

FUNCTION KvlObjName()
RETURN GenName(KVL->IdGen,PAR->Langue) if empty(KVL->IdArt)
#ifdef DEF_ART
  RETURN ArtName(KVL->IdArt,PAR->Langue)
#endif DEF_ART
RETURN ""


**
** KvkDlgClose()
**
FUNCTION KvkDlgClose(lRefresh)
local jnl := JnlLocate(KVK->IdJnl)
RETURN .f. if jnl == NIL
if KVK->Etat == DocStatOpen()
  if JNLATTR_F $ jnl[JNL_ATTRIB]
    if ! KvkIsChrono()
      Warning(SetMsg())
      RETURN .f.
    endif
  endif
  if ! USRATTR_Y $ UsrAttrib()
    if lRefresh
      ddRefreshCurrent()
    endif
    if ! Confirm( ;
      MsgIdJnlDoc() + MsgClose(), NIL, ;
      MSG_YES, "WRN011" ;
    )
      RETURN .f.
    endif
  endif
  if KvkClose(jnl)
    KVK->Etat := DocStatClosed()
    SetMsg( MsgIdJnlDoc() + MsgCloseOkay() )
    if JNLATTR_I $ jnl[JNL_ATTRIB]
      if lRefresh
        ddRefreshCurrent()
        if KVK->Etat == DocStatClosed()
          KvkPrint(jnl)
        endif
      endif
    endif
    if JNLATTR_L $ jnl[JNL_ATTRIB]
      ParSatisfy(KVK->IdPar)
    endif
  else
    Warning( SetMsg() , MsgIdJnlDoc() + MsgCloseFail() )
  endif
elseif KVK->Etat == DocStatClosed()
  RETURN .f. if ! USRATTR_S $ UsrAttrib()
  if ! USRATTR_Y $ UsrAttrib()
    if ! Confirm( ;
      MsgIdJnlDoc() + MsgUndo(), MsgSure(), MSG_YES,"WRN002" ;
    )
      RETURN .f.
    endif
  endif
  if KvkUndo(jnl)
    KVK->Etat := DocStatOpen()
    SetMsg( MsgIdJnlDoc() + MsgUndoDone() )
  else
    Warning(MsgIdJnlDoc() + MsgUndoFail())
  endif
  ddRefreshCurrent()
endif
RETURN MnuDone()

**
** KvkClose()
**
FUNCTION KvkClose(jnl)
local aMvs := {}
local aCts := {}
local aQts := {}
local aMvg := {}
local aCtp := {}
local aCtg := {}
RETURN .f. if ! KvkKvlEval(jnl,{|| ;
  KvlPreClose(jnl,aMvs,aCts,aQts,aMvg) ;
} )
#ifdef DEF_HST
  if JNLATTR_G $ jnl[JNL_ATTRIB]
    RETURN .f. if ! KvkHstGenerate( jnl, aMvg, aCtp, aCtg )
  endif
#endif DEF_HST
#ifdef DEF_MVS
  if JNLATTR_S $ jnl[JNL_ATTRIB]
    RETURN .f. if ! KvkMvsGenerate( jnl, aMvs )
  endif
#endif DEF_MVS
#ifdef DEF_CTS
  RETURN .f. if ! CtsUpdate(aCts)
#endif DEF_CTS
#ifdef DEF_STK
  RETURN .f. if ! QtsUpdate(aQts,KVK->Date)
#endif DEF_STK
#ifdef DEF_CTP
  RETURN .f. if ! CtpUpdate(aCtp)
#endif DEF_CTP
#ifdef DEF_CTG
  RETURN .f. if ! CtgUpdate(aCtg)
#endif DEF_CTG
RETURN .t.


**
** KvkUndo()
**
FUNCTION KvkUndo(jnl)
local aMvs := {}
local aCts := {}
local aQts := {}
local aMvg := {}
local aCtp := {}
local aCtg := {}
local aPar := {}
local aGen := {}
RETURN .f. if ! KvkKvlEval(jnl,{|| ;
  KvlPreUndo(jnl,aMvs,aCts,aQts,aMvg) ;
} )
#ifdef DEF_HST
  if JNLATTR_G $ jnl[JNL_ATTRIB]
    RETURN .f. if ! HstUndo(KVK->IdJnl,KVK->IdDoc,KVK->Periode,aCtp,aCtg,aPar,aGen)
  endif
#endif DEF_HST
*#ifdef DEF_MVS
*  if JNLATTR_S $ jnl[JNL_ATTRIB]
*    RETURN .f. if ! KvkMvsGenerate( jnl, aMvs )
*  endif
*#endif DEF_MVS
*#ifdef DEF_CTS
*  RETURN .f. if ! CtsUpdate(aCts)
*#endif DEF_CTS
#ifdef DEF_STK
  RETURN .f. if ! QtsUpdate(aQts,KVK->Date)
#endif DEF_STK
#ifdef DEF_CTP
  RETURN .f. if ! CtpUpdate(aCtp)
#endif DEF_CTP
#ifdef DEF_CTG
  RETURN .f. if ! CtgUpdate(aCtg)
#endif DEF_CTG
if JNLATTR_L $ jnl[JNL_ATTRIB]
  ParSatisfy(KVK->IdPar)
endif
RETURN .t.


FUNCTION KvkIsChrono() // jnl)
local nRecNo   := recno()
local cIdJnl   := KVK->IdJnl
local cIdDoc   := KVK->IdDoc
local dDate    := KVK->Date
local cPeriode := KVK->Periode
local lOkay := .t.
local nOrder := indexord()
ddSetOrder(ORD_KVK_ID)
skip -1
if ! bof() .and. KVK->IdJnl == cIdJnl
  if dDate < KVK->Date
    SetMsg("Datumfolge " + dtoc(dDate) + "-" + dtoc(KVK->Date) + MsgNotAllowed())
    lOkay := .f.
  elseif KVK->Etat != DocStatClosed()
    SetMsg(MsgPrevDoc() + MsgNotClosed())
    lOkay := .f.
  elseif cIdDoc != NextNum(KVK->IdDoc)
    if PerYear(cPeriode) == PerYear(KVK->Periode)
      SetMsg("Nummernfolge " + cIdDoc + "-" + KVK->IdDoc + MsgNotAllowed())
      lOkay := .f.
    endif
  endif
endif
ddSetOrder(nOrder)
goto nRecNo
RETURN lOkay



FUNCTION KvlIdSer()
#ifdef DEF_SER
RETURN KVL->IdSer
#else
RETURN ""
#endif

**
** KvlPreClose()
**
FUNCTION KvlPreClose(jnl,aMvs,aCts,aQts,aMvg)
local lOkay := .f.
open area oKvl(), oGen(), oArt()
  lOkay := .t.
  softseek KVK->IdJnl + KVK->IdDoc
  do while ! eof() .and. KVL->IdDoc == KVK->IdDoc ;
                   .and. KVL->IdJnl == KVK->IdJnl
    if ! KvlMvgCollect(jnl,aMvg)
      lOkay := .f.
      exit
    endif
    if ! empty(KVL->IdArt)
      if ! ArtExist(KVL->IdArt)
        lOkay := .f.
        exit
      endif
      #ifdef DEF_MVS
        if JNLATTR_S $ jnl[JNL_ATTRIB]
          if ! KvlMvsCollect(jnl,aMvs)
            lOkay := .f.
            exit
          endif
        endif
      #endif DEF_MVS
      #ifdef DEF_CTS
        if JNLATTR_M $ jnl[JNL_ATTRIB]
          if ! KvlCtsCollect(jnl,aCts)
            lOkay := .f.
            exit
          endif
        endif
      #endif DEF_CTS
      #ifdef DEF_STK
        if JNLATTR_Q $ jnl[JNL_ATTRIB]
          KvlQtsCollect( ;
            KVL->IdArt, ;
            qton1(KVL->Qte), ;
            aQts, ;
            KVL->DC, KvlIdSer(), val(KVL->Mont) ;
          )
        endif
      #endif DEF_STK
      * #ifdef DEF_SER
      *   if ! empty(KVL->IdSer)
      *     KvlSerCollect(aSer)
      *   endif
      * #endif DEF_SER
    endif
    skip
  enddo
close area
RETURN lOkay



**
** KvlPreUndo()
**
FUNCTION KvlPreUndo(jnl,aMvs,aCts,aQts,aMvg)
local lOkay := .f.
open area oKvl(), oGen(), oArt()
  lOkay := .t.
  softseek KVK->IdJnl + KVK->IdDoc
  do while ! eof() .and. KVL->IdDoc == KVK->IdDoc ;
                   .and. KVL->IdJnl == KVK->IdJnl
    if ! empty(KVL->IdArt)
      if ! ArtExist(KVL->IdArt)
        lOkay := .f.
        exit
      endif
      *#ifdef DEF_MVS
      *  if JNLATTR_S $ jnl[JNL_ATTRIB]
      *    if ! KvlMvsCollect(jnl,aMvs)
      *      lOkay := .f.
      *      exit
      *    endif
      *  endif
      *#endif DEF_MVS
      *#ifdef DEF_CTS
      *  if JNLATTR_M $ jnl[JNL_ATTRIB]
      *    if ! KvlCtsCollect(jnl,aCts)
      *      lOkay := .f.
      *      exit
      *    endif
      *  endif
      *#endif DEF_CTS
      #ifdef DEF_STK
        if JNLATTR_Q $ jnl[JNL_ATTRIB]
          KvlQtsCollect( ;
            KVL->IdArt, ;
            -qton1(KVL->Qte), ;
            aQts, ;
            KVL->DC, KvlIdSer(), val(KVL->Mont) ;
          )
        endif
      #endif DEF_STK
    endif
    skip
  enddo
close area
RETURN lOkay



**
** KvlMvgCollect()
**
FUNCTION KvlMvgCollect(jnl,aMvg)
local kvl
local i
local tax
local nBase
local nTaxe := 0
local ven
local vnl
local cIdGen
RETURN .t. if empty(KVL->IdGen)
RETURN .f. if ! GenExist(KVL->IdGen)
if (tax := TaxLocate(KVK->IdCtr,GEN->IdTax,.f.)) == NIL
  SetMsg( ;
    MsgIdJnlDoc() + " : " + KVL->IdGen + ;
    " : Generalkonto ohne MWSt-Code fr " + CtrName(KVK->IdCtr) ;
  )
  RETURN .f.
endif
nBase := round(netto(val(KVL->Mont),tax[TAX_TAUX]),SetDecPos())
nTaxe := val(KVL->Mont) - nBase
MvgCollect( ;
  aMvg, KVL->IdGen, ;
  KVK->Date, KVK->Periode, ;
  jnl, ;
  DcInvert(KVL->DC), nBase, "", GEN->IdTax, 0, "" ;
)
if nTaxe != 0
  if empty(tax[TAX_IDGEN])
    cIdGen := KVL->IdGen
  else
    cIdGen := tax[TAX_IDGEN]
  endif
  MvgCollect( ;
    aMvg, cIdGen, ;
    KVK->Date, KVK->Periode, ;
    jnl, ;
    DcInvert(KVL->DC), nTaxe, "", "", 0, "" ;
  )
  if ! empty(tax[TAX_GENTIERS])
    MvgCollect( ;
      aMvg, tax[TAX_GENTIERS], ;
      KVK->Date, KVK->Periode, ;
      jnl, ;
      KVL->DC, nTaxe, "", "", 0, "" ;
    )
  endif
endif
RETURN .t.



**
** KvkHstGenerate()
**
FUNCTION KvkHstGenerate(jnl, aMvg, aCtp, aCtg )
local lOk := .f.
local i
local nSum := 0
local cPeriode := KVK->Periode
local cIdGen
open area oHst()
  lOk := .t.
  for i := 1 to len(aMvg)
    if aMvg[i][MVG_MONT] != 0
      if dbAddRec()
        HST->IdGen   := aMvg[i][MVG_IDGEN]
        #ifdef DEF_ANA
        HST->IdAna   := aMvg[i][MVG_IDANA]
        #endif
        HST->IdJnl   := KVK->IdJnl
        HST->IdDoc   := KVK->IdDoc
        HST->Periode := aMvg[i][MVG_PERIODE]
        HST->Date    := aMvg[i][MVG_DATE]
        // HST->Line    := aMvg[i][MVG_LINE]
        HST->IdTax   := aMvg[i][MVG_IDTAX]
        HST->Match   := KvkMatch() // aMvg[i][MVG_MATCH]
        if aMvg[i][MVG_MONT] < 0
          HST->DC      := DcInvert(aMvg[i][MVG_DC])
          HST->Mont    := ntom(-aMvg[i][MVG_MONT])
          * HST->MontDev := ntom(-aMvg[i][MVG_MONTDEV])
        else
          HST->DC      := aMvg[i][MVG_DC]
          HST->Mont    := ntom(aMvg[i][MVG_MONT])
          * HST->MontDev := ntom(aMvg[i][MVG_MONTDEV])
        endif
        if aMvg[i][MVG_DC] == jnl[JNL_DC]
          nSum -= aMvg[i][MVG_MONT]
        else
          nSum += aMvg[i][MVG_MONT]
        endif
        #ifdef DEF_CTG
          HstCtgCollect(aCtg)
        #endif DEF_CTG
        unlock record
      else
        lOk := .f.
        exit
      endif
    endif
  next i
  if ! lOK ; break area ; endif
  if nSum != val(KVK->Mont)
    lOk := .f.
    * Warning("(Anzahlung oder Begleichung)")
    open area oKvl()
      lOk := .t.
      softseek KVK->IdJnl + KVK->IdDoc
      do while ! eof() .and. KVL->IdDoc == KVK->IdDoc ;
                       .and. KVL->IdJnl == KVK->IdJnl
        if empty(KVL->IdGen)
          select HST
          if dbAddRec()
            HST->IdCtr   := KVK->IdCtr
            #ifdef DEF_CTRATTR
              ...
            #endif DEF_CTRATTR
            HST->IdGen   := CtrIdGen(KVK->IdCtr)
            HST->IdPar   := KVK->IdPar
            HST->IdJnl   := KVK->IdJnl
            HST->IdDoc   := KVK->IdDoc
            HST->Periode := KVK->Periode
            HST->Date    := KVK->Date
            // HST->Line    := KVL->Line
            if empty(KVL->Match)
              HST->Match   := KvkMatch()
            else
              HST->Match   := KVL->Match
            endif
            HST->DC      := DcInvert(KVL->DC)
            HST->Mont    := KVL->Mont
            if KVL->DC == jnl[JNL_DC]
              nSum += val(KVL->Mont)
            else
              nSum -= val(KVL->Mont)
            endif
            #ifdef DEF_CTG
              HstCtgCollect(aCtg)
            #endif DEF_CTG
            unlock record
          else
            lOk := .f.
            exit
          endif
          select KVL
        endif
        skip
      enddo
    close area
  endif
  if ! lOK ; break area ; endif
  if nSum != 0
    if dbAddRec()
      HST->IdCtr   := KVK->IdCtr
      HST->IdGen   := CtrIdGen(KVK->IdCtr)
      HST->IdPar   := KVK->IdPar
      HST->IdJnl   := KVK->IdJnl
      HST->IdDoc   := KVK->IdDoc
      HST->Periode := KVK->Periode
      HST->Date    := KVK->Date
      HST->Match   := KvkMatch()
      if nSum > 0
        HST->Mont    := ntom(nSum)
        HST->DC      := jnl[JNL_DC]
      else
        HST->Mont    := ntom(-nSum)
        HST->DC      := DcInvert(jnl[JNL_DC])
      endif
      #ifdef DEF_CTP
        HstCtpCollect(aCtp)
      #endif DEF_CTP
      #ifdef DEF_CTG
        HstCtgCollect(aCtg)
      #endif DEF_CTG
      unlock record
    else
      lOk := .f.
      break area
    endif
  endif
  if ! ZlaHstAppend(jnl,KVK->IdZla1,KVK->Mont1,aCtg,aCtp)
    lOk := .f.
    break area
  endif
  if ! ZlaHstAppend(jnl,KVK->IdZla2,KVK->Mont2,aCtg,aCtp)
    lOk := .f.
    break area
  endif
  dbcommit()
close area
RETURN lOk


FUNCTION ZlaHstAppend(jnl,cIdZla,cMont,aCtg,aCtp)
local zla := ZlaLocate(cIdZla,KVK->IdCtr)
local nMont
RETURN .t. if empty(cMont)
if zla == NIL
  SetMsg(cIdZla + " : unbekannte Zahlart")
  RETURN .f.
endif
RETURN .t. if empty(zla[ZLA_IDGEN])
if zla[ZLA_IDDEV] == DevDefault(KVK->Periode)
  nMont    := val(cMont)
else
  nMont    := val(cMont)*zla[ZLA_COURS]
endif
** die erste Buchung geht ins Generalkonto (z.B. 570000)
RETURN .f. if ! dbAddRec()
HST->IdGen   := zla[ZLA_IDGEN]
HST->IdJnl   := KVK->IdJnl
HST->IdDoc   := KVK->IdDoc
HST->Periode := KVK->Periode
HST->Date    := KVK->Date
HST->Match   := KvkMatch()
if nMont > 0
  HST->DC      := jnl[JNL_DC]
  HST->Mont    := ntom(nMont)
else
  HST->DC      := DcInvert(jnl[JNL_DC])
  HST->Mont    := ntom(-nMont)
endif
if zla[ZLA_IDDEV] != DevDefault(KVK->Periode)
  HST->MontDev := cMont
  HST->IdDev := zla[ZLA_IDDEV]
endif
#ifdef DEF_CTG
  HstCtgCollect(aCtg)
#endif DEF_CTG
unlock record
** die zweite Buchung geht ins Partnerkonto
RETURN .f. if ! dbAddRec()
HST->IdCtr   := KVK->IdCtr
HST->IdGen   := CtrIdGen(KVK->IdCtr)
HST->IdPar   := KVK->IdPar
HST->IdJnl   := KVK->IdJnl
HST->IdDoc   := KVK->IdDoc
HST->Periode := KVK->Periode
HST->Date    := KVK->Date
HST->Match   := KvkMatch()
if nMont > 0
  HST->DC      := DcInvert(jnl[JNL_DC])
  HST->Mont    := ntom(nMont)
else
  HST->DC      := jnl[JNL_DC]
  HST->Mont    := ntom(-nMont)
endif
if !empty(PAR->IdDev) .and. PAR->IdDev != DevDefault(KVK->Periode)
  if PAR->IdDev == zla[ZLA_IDDEV]
    HST->MontDev := cMont
    HST->IdDev := PAR->IdDev
  else
    Warning("HST->MontDev")
    * HST->MontDev := ntom( ;
    *   val(cMont) * zla[ZLA_COURS] / val(DevCours(PAR->IdDev,HST->Periode)), ;
    *   DevDecPos(PAR->IdDev) ;
    * )
  endif
endif
#ifdef DEF_CTP
  HstCtpCollect(aCtp)
#endif DEF_CTP
#ifdef DEF_CTG
  HstCtgCollect(aCtg)
#endif DEF_CTG
unlock record
RETURN .t.




#ifdef DEF_MVS
FUNCTION KvlMvsCollect(jnl,aMvs) ; RETURN .t.
FUNCTION KvkMvsGenerate( jnl, aMvs ) ; RETURN .t.
#endif DEF_MVS

#ifdef DEF_CTS
FUNCTION KvlCtsCollect(jnl,aCts) ; RETURN .t.
#endif DEF_CTS

#ifdef DEF_STK

**
** KvlQtsCollect()
**
FUNCTION KvlQtsCollect(cIdArt,nQte,aQts,cDC,cIdSer,nMont)
local i
local aStk := StkList()
RETURN NIL if ARTATTR_S $ ART->Attrib
for i := 1 to len(aStk)
  if &(aStk[i][STK_EXPR])
    if aStk[i][STK_DC] == cDC
      QtsCollect(aQts,cIdArt,aStk[i],nQte,cIdSer,nMont)
    else
      QtsCollect(aQts,cIdArt,aStk[i],-nQte,cIdSer,-nMont)
    endif
  endif
next i
RETURN NIL


#endif DEF_STK

**
** KvkPrint()
**
FUNCTION KvkPrint(jnl)
RETURN NIL if empty(jnl[JNL_IDTPL])
open area oPar(), oPlz(), oNat()
  SetTplLang(MemLang1)
  PrintTemplate(jnl[JNL_IDTPT],jnl[JNL_IDTPL])
close area
RETURN MnuDone()


**
** KvkListe()
**
FUNCTION KvkListe(cTplIni,cTitle,cIdHcl,cIdTpl)
local nPad
local nCount := 0
local cLine
local cTit1 := ""
local cTit2 := ""
* local cTit3 := ""
local lOkay := .f.
local aHcl := ReadArray(cIdHcl+".HCL",HCL_ALEN)
local aTtl := ReadArray(cIdHcl+".TTL",TTL_ALEN)
local aTtlValues := {}
local bWarn := {|| MsgIdJnlDoc() + "." + KVL->Line }
default sdKvkDate1 to UserDate()
default sdKvkDate2 to UserDate()
default cTplIni to "LISTEX"
open window (cTitle) size 5,50 help KVKLISTE
say "Kassenscheine vom "
get sdKvkDate1
say " bis zum "
get sdKvkDate2
WinCr()
GetPreview()
WinCr()
SetTplIni(cTplIni)
GetTplIni()
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
snKvkCount := 0
open printer SetTplIni() ;
     preview SetPreview()
ClnInit(aHcl,aTtl)
aTtlValues := TtlInit(aHcl,aTtl)
... das muss noch angepasst werden [sh. neues 971008]
cTit1 := padr("Dokument",LenIdJnl()+1+LEN_IDDOC)
cTit2 := repl("Ä",LenIdJnl()+1+LEN_IDDOC)
* cTit1 += " " + "Z"
* cTit2 += " " + "Ä"
cTit1 += " " + padr("Partner",30)
cTit2 += " " + repl("Ä",30)
nPad  := len(cTit2)
cTit1 += " " + ClnTit1(aHcl,aTtl,aTtlValues)
cTit2 += " " + ClnTit2(aHcl,aTtl,aTtlValues)
* cTit3 += " " + ClnTit3(aHcl,aTtl,aTtlValues)
p_SetWidth(len(cTit2))
SetPageHeader( {|| ;
  PrintHeader( ;
    cTitle, ;
    dtocf(sdKvkDate1)+if(sdKvkDate1==sdKvkDate2,""," - "+dtocf(sdKvkDate2)) ;
  ), ;
  PrintLine(cTit1) , ;
  PrintLine(cTit2)   ;
} )
open area oKvk(), oKvl(), oArt(), oGen(), oPar()
  ddSetOrder(ORD_KVK_DATE)
  lOkay := .t.
  softseek dtos(sdKvkDate1)
  do while ! eof() .and. KVK->Date <= sdKvkDate2
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    if TaskInter() ; lOkay := .f. ; exit ; endif
    seek KVK->IdPar in PAR
    snKvlCount := 0
    snKvkCount++
    select KVL
    softseek KVK->IdJnl + KVK->IdDoc
    do while lOkay .and. ! eof() ;
                   .and. KVL->IdJnl == KVK->IdJnl ;
                   .and. KVL->IdDoc == KVK->IdDoc
      seek KVL->IdGen in GEN
      seek KVL->IdArt in ART
      snKvlCount++
      ... das muss noch angepasst werden [sh. neues 971008]
      if snKvlCount == 1
        cLine := MsgIdJnlDoc()
        * cLine += " " + KVK->IdCtr
        cLine += " " + padr(KVK->IdPar+" "+ParName(KVK->IdPar),30)
      else
        cLine := space(nPad)
      endif
      cLine += " "
      if ! ClnEval(aHcl,aTtl,{aTtlValues},cLine,.t.,bWarn)
        lOkay := .f.
      endif
      skip
    enddo
    select KVK
    skip
  enddo
close area
if lOkay
  PrintLine()
  ClnTotal(aHcl,aTtl,aTtlValues) // ,nPad)
endif
if cIdTpl != NIL
  PrintTemplate(TPLTYPE_LST,cIdTpl)
endif
close printer
RETURN MnuDone()

FUNCTION KvkZlaSum(cIdZla)
local n := 0
if KVK->IdZla1 == cIdZla
  n += val(KVK->Mont1)
endif
if KVK->IdZla2 == cIdZla
  n += val(KVK->Mont2)
endif
RETURN n

FUNCTION KvlCount ; RETURN snKvlCount
FUNCTION KvkCount ; RETURN snKvkCount
FUNCTION KvkDate1 ; RETURN sdKvkDate1
FUNCTION KvkDate2 ; RETURN sdKvkDate2

FUNCTION KvlIsLast
local lIsLast := .t.
local nRecNo := recno()
local cIdJnl := KVL->IdJnl
local cIdDoc := KVL->IdDoc
skip
if ! eof()
  if KVL->IdDoc == cIdDoc
    if KVL->IdJnl == cIdJnl
      lIsLast := .f.
    endif
  endif
endif
goto (nRecNo)
RETURN lIsLast


**
** KvkKvlList()
**
FUNCTION KvkKvlList(cParam)
local jnl := JnlLocate(KVK->IdJnl)
open area oKvl(), oGen(), oArt(), oSer()
  softseek KVK->IdJnl + KVK->IdDoc
  do while ! eof() .and. KVL->IdJnl == KVK->IdJnl ;
                   .and. KVL->IdDoc == KVK->IdDoc
    seek KVL->IdArt in Art
    seek KVL->IdGen in GEN
    TplParse(OhneAnf(cParam))
    skip
  enddo
close area
RETURN NIL

#endif DEF_KVK

#ifdef DEF_CTP

FUNCTION HstCtpCollect(aCtp)
local nMont := val(HST->Mont)
* local nUmsatz ...?
* RETURN NIL if ! GenExist(HST->IdGen)
if HST->DC == DC_DEBIT
  CtpCollect( ;
    aCtp, HST->IdCtr, HST->IdPar, ;
    HST->Periode, ;
    nMont, 0, 0 ;
  )
else
  CtpCollect( ;
    aCtp, HST->IdCtr, HST->IdPar, ;
    HST->Periode, ;
    0, nMont, 0 ;
  )
endif
RETURN NIL

#endif DEF_CTP

FUNCTION DcValue(cDC)
RETURN val(FIELD->Mont) if FIELD->DC == cDC
RETURN - val(FIELD->Mont)


