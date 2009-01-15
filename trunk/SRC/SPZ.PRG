** Copyright (c) 2005-2008 Luc Saffre
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

/**

PAR : Personen : Klienten, Therapeuten, Sonstige...
DLA : Dienstleistungsarten
GRA : Kategorien
PRJ : Akten
PRB : Probleme (IdPrb, Ref, Name)
DLS : Dienstleistungen (Datum, Akte, IdPar=Therapeut, IdDla=DL-Art,...)
DLP : Klienten pro Sitzung

- 20050818 : Start Programmierung


**/

#ifdef DEF_DLS

#define PRBATTR_H "H" // nicht benutzen und nicht anzeigen
#define PRBATTR_T "T" // "Titel" (nicht benutzen, aber wohl anzeigen)

FUNCTION PickDls(cStart)
RETURN DbfPick( ;
  {oDls(),oPar(),oDla(),oArt()},;
  "Auswahl Dienstleistung", ;
  "DLSPICK",;
  cStart,;
  NIL,NIL,NIL,;
  "DLS->IdDls";
)

#ifdef DEF_MSG

FUNCTION DlsMsgTypes(nMaxLen)
local c := ""
if !empty(DLS->IdDls)
  open area oMsg()
    set order to 5
    softseek DLS->IdDls
    do while !eof() .and. MSG->IdDls == DLS->IdDls
      if ! trim(MSG->Type) $ c
        c += trim(MSG->Type) + " "
      endif
      skip
    enddo
  close area
endif  
RETURN c if nMaxLen == NIL 
RETURN padr(c,nMaxLen)

#endif DEF_MSG

FUNCTION PickDla(cStart)
RETURN DbfPick( ;
  {oDla()},;
  "Auswahl Dienstleistungsart", ;
  "DLAPICK",;
  cStart,;
  NIL,NIL,NIL,;
  "DLA->IdDla";
)

FUNCTION ParAkten /* returnt ein Array von Aktennummern, die
therapeutisch zu mir geh”ren. Darunter auch meine eigene Aktennummer,
wenn ich eine Anfrage bin. Ein Partner ist eine Anfrage, wenn es keinen
anderen Partner gibt, der fr ihn Anfrage ist.

*/
local a := { PAR->IdPar }
local lAmChild := .f.
open area oPlp()
  softseek PAR->IdPar
  do while !eof() .and. PLP->IdPar1 == PAR->IdPar
    if PLP->Type=="81-" .or. PLP->Type=="82-"
      lAmChild := .t.
    elseif PLP->Type=="81 ".or. PLP->Type=="82 "
      aadd(a,PLP->IdPar2)
    endif
    skip
  enddo
close area
RETURN {} if lAmChild
RETURN a



FUNCTION ParDlsScan(ds1,ds2,xlFilter,xlEval)
local a := ParAkten()
local i
for i := 1 to len(a)
  RETURN .f. if ! DbfScan({oDls(),oDla(),oPar()},4,;
    a[i]+ds1,;
    "DLS->IdPar+left(dtos(DLS->Date),";
      +ntrim(len(ds2));
      +")<='"+a[i]+ds2+"'",;
      xlFilter,xlEval, NIL,.f.)
next i
RETURN .t.
*RETURN DbfScan({oDls(),oDla(),oPar()},4,;
*  PAR->IdPar+ds1,;
*  "DLS->IdPar+left(dtos(DLS->Date),";
*    +ntrim(len(ds2));
*    +")<='"+PAR->IdPar+ds2+"'",;
*    xlFilter,xlEval, NIL,.f.)

FUNCTION ParDlpScan(ds1,ds2,xlFilter,xlEval)
RETURN DbfScan({oDlp(),oDls(),oPar()},2,;
  PAR->IdPar+ds1,;
  "DLP->IdPar+left(dtos(DLP->Date),";
    +ntrim(len(ds2));
    +")<='"+PAR->IdPar+ds2+"'",;
    xlFilter,xlEval,NIL,.f.)

*FUNCTION ParOnPlp(xlOnPlp)
*local cIdPar := PAR->IdPar
*local lFound := .f.
*open area oPlp(), oPar()
*  softseek cIdPar
*  do while !eof() .and. PLP->IdPar1 == cIdPar
*    if left(PLP->Type,1)=="8"
*      if ParExist(PLP->IdPar2)
*        lFound := eval(xlOnPlp)
*        exit
*      endif
*    endif
*    skip
*  enddo
*close area
*RETURN .t. if lFound
*lFound := eval(xlOnPlp)




#endif DEF_DLS

#ifdef DEF_PRB

FUNCTION oPrb
static b
RETURN b if b != NIL
define data b                 ;
       name PRB ;
       predelete PrbCanDelete().and.ConfirmDelete()
ddIndex b on PRB->IdPrb
ddIndex b on upper(PRB->Ref)
ddIndex b on upper(PRB->Name1)
ddFld IdPrb   ,C, LenIdPrb(),0  when .f. picture PIC_ID
ddFld Ref   ,C,12,0
ddFld Attrib  ,C, 5,0 picture PIC_ID ;
                      pick PickDbcAttr("PRBATTR.DBC",PRB->Attrib)
ddFld Name1 ,C,60,0 picture "@K@S25"
ddFld Name2 ,C,60,0 picture "@K@S25"
ddFld Name3 ,C,60,0 picture "@K@S25"
ddFld Type  ,C, 3,0 picture PIC_ID ;
             pick PickPrbType(PRB->Type)
ddEndDef()
RETURN b

FUNCTION oPpr()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b        ;
  name PPR           ;
  ontest PprOnTest() ;
  create PprCreate()
ddIndex b on  PPR->IdPar+PPR->Type+PPR->IdPrb ;
              format {|x|padr(x,LenIdPar())}
ddIndex b on  PPR->IdPrb+PPR->Type+PPR->IdPar ;
              format {|x|padr(x,LenIdPar())}
ddFld IdPar  ,C, LenIdPar(),0 postedit {|x|GetIdPar(x)} ;
              pick PickPar(NIL,PPR->IdPar)
ddFld IdPrb  ,C, LenIdPrb(),0 ;
               pick PickPrb(PPR->IdPrb,"!'H'$PRB->Attrib")
ddFld Type    ,C, 3,0 picture PIC_ID ;
              pick PickPrbType(PPR->Type)
action b key K_ENTER   block ParPage(PPR->IdPar) ;
         when indexord()!=1
ddEndDef()
RETURN b


FUNCTION PickPrbType(x)
RETURN PickDbcCode("PRBTYPE.DBC",x,"Themenbereich")

FUNCTION PprOnTest()
local cPrbAttrib := DbfPeek(oPrb(),PPR->IdPrb,"PRB->Attrib",NIL)
local cParAttrib := DbfPeek(oPar(),PPR->IdPar,"PAR->Attrib",NIL)
RETURN !SetMsg(PPR->IdPrb+" : ungltige Referenz in PPR->IdPrb") ;
  if cPrbAttrib == NIL
RETURN !SetMsg(MsgParExist(PPR->IdPar)) if cParAttrib == NIL
if ! PARATTR_H $ cParAttrib
  if PRBATTR_H $ cPrbAttrib.or.PRBATTR_T $ cPrbAttrib
    RETURN !SetMsg(DbfPeek(oPrb(),PPR->IdPrb,;
      "trim1(PRB->Ref)+trim(PRB->Name1)","");
      +" : Thema bitte nicht benutzen!")
  endif
endif
RETURN .t.


FUNCTION PprCreate()
local aBuf := CopyRec()
local x
if indexord() == 1
  x := PickPrb(PPR->IdPrb)
  RETURN DDCREATE_FAIL if x == NIL
  RETURN DDCREATE_FAIL if ! dbAddRec()
  PasteRec(aBuf)
  PPR->IdPar := ddKeyValue()
  PPR->IdPrb := x
  dbcommit()
  RETURN DDCREATE_REFRESH
elseif indexord() == 2
  x := PickPar(NIL,PPR->IdPar)
  RETURN DDCREATE_FAIL if x == NIL
  RETURN DDCREATE_FAIL if ! dbAddRec()
  PasteRec(aBuf)
  PPR->IdPrb := ddKeyValue()
  PPR->IdPar := x
  dbcommit()
  RETURN DDCREATE_REFRESH
else
  SetMsg("Cannot PprCreate() for indexor() "+ntrim(indexord()))
endif
RETURN DDCREATE_FAIL
// RETURN DDCREATE_FULL





FUNCTION PickPrb(cStart,xlFilter)
RETURN DbfPick( ;
  {oPrb()},;
  "Auswahl Thema", ;
  "PRBPICK",;
  cStart,;
  xlFilter,NIL,NIL,;
  "PRB->IdPrb";
)

FUNCTION LenIdPrb ; RETURN 4

FUNCTION ParPrbList()
local a := {}
RETURN "?" if ! ParPrbScan(NIL,{||;
  aadd(a,trim1(PRB->Ref)+trim(PRB->Name1)),.t.})
RETURN join(a,", ")

FUNCTION ParPrbScan(xlFilter,xlEval)
RETURN DbfScan({oPpr(),oPrb()},1,;
  PAR->IdPar,"PPR->IdPar=='"+PAR->IdPar+"'",;
  xlFilter,{||DbfPeek(oPrb(),PPR->IdPrb,xlEval,.f.)},NIL,.f.)



// called from PRBSTAT.EXP and PARSTAT.EXP
FUNCTION PrbParScan(xlFilter,xlEval)
// default xlFilter to "ParExist(PPR->IdPar)"
RETURN DbfScan({oPpr(),oPar()},2,;
  PRB->IdPrb,"PPR->IdPrb=='"+PRB->IdPrb+"'",;
  xlFilter,{||DbfPeek(oPar(),PPR->IdPar,xlEval,.f.)},NIL,.f.)
* local lOkay := .f.
* default xlParFilter to {||.t.}
* open area oPpr(), oPar()
*   lOkay := .t.
*   ddSetOrder 2
*   do while lOkay.and.!eof().and.PPR->IdPrb == PRB->IdPrb
*     if ParExist(PPR->IdPar)
*       if eval(xlParFilter)
*         if ! eval(xlOnPar)
*           lOkay := .f.
*         endif
*       endif
*     endif
*   enddo
* close area
* RETURN lOkay

FUNCTION PrbDlsScan(ds1,ds2,xlFilter,xlEval)
RETURN PrbParScan(NIL,{||ParDlsScan(ds1,ds2,xlFilter,xlEval)})

FUNCTION PrbDlpScan(ds1,ds2,xlFilter,xlEval)
RETURN PrbParScan(NIL,{||ParDlpScan(ds1,ds2,xlFilter,xlEval)})

FUNCTION PrbCanDelete()
local lOkay := .f.
local cId := PRB->IdPrb
MsgDisplay(MsgWorking())
lOkay := .f.
open area oPpr()
  ddSetOrder(2)
  softseek cId
  if PPR->IdPrb == cId
    SetMsg("Zuerst Aktenzuweisungen l”schen, dann das Thema!")
  else
    lOkay := .t. // nReturn := DDDEL_NOCONFIRM
  endif
close area
RETURN lOkay





#else

FUNCTION oPpr() ; RETURN NIL

#endif DEF_PRB

FUNCTION ParParCount
RETURN DbfSum({oPar()},"1",4,PAR->IdPar2,"PAR->IdPar2=='"+PAR->IdPar2+"'")


#ifdef DEF_DLS

FUNCTION ParLastDate
local d := PAR->Date1
d := max(d,DbfOnBottom(oDls(),4,"DLS->Date",d,PAR->IdPar,"IdPar"))
d := max(d,DbfOnBottom(oDlp(),2,"DLP->Date",d,PAR->IdPar,"IdPar"))
RETURN d

FUNCTION oDla
static b
RETURN b if b != NIL
define data b                 ;
       name DLA
ddIndex b on DLA->IdDla
ddIndex b on upper(DLA->Ref)
ddIndex b on upper(DLA->Name1)
ddFld IdDla   ,C, LenIdDla(),0  when .f. picture PIC_ID
ddFld Ref   ,C,12,0
ddFld Attrib  ,C, 5,0 picture PIC_ID ;
                      pick PickDbcAttr("DLAATTR.DBC",DLA->Attrib)
ddFld Name1 ,C,60,0 picture "@K@S25"
ddFld Name2 ,C,60,0 picture "@K@S25"
ddFld Name3 ,C,60,0 picture "@K@S25"
ddFld Zahlart  ,C,  1,0 picture PIC_ID ;
      pick {|x| PickDbcCode("DLSZAHL.DBC",x)}
ddFld IdArt   ,C, LenIdArt(),0 picture PIC_ID pick {|x|PickArt(x)}
ddEndDef()
RETURN b

FUNCTION DlaName(cId)
if cId != NIL .and. cId != DLA->IdDla
  seek cId in DLA
endif
RETURN trim(LngExpr("DLA->Name",TplLang()))



FUNCTION LenIdDls() ; RETURN 6

// #define LEN_IDDLS 6

// #define DLAATTR_D "D" // Direkte DL
#define DLAATTR_A "A" // Anwesenheiten automatisch fllen
#define DLAATTR_E "E" // Einzelberatung (max. 1 Anwesender)

#define IDPRT_P "P"
// #define DLASTAT_S "S" // Stattgefunden


FUNCTION oDls
static b := NIL
if b != NIL ; RETURN b ; endif
define data b              ;
       name DLS ;
       wait {|x| DlsWait(x)} ;
       predelete DlsPredelete() ;
       postedit DlsPostEdit()
ddIndex b on  DLS->IdDls format {|x|padl(x,LenIdDls())}
ddIndex b on  dtos(DLS->Date)+DLS->Von+DLS->Bis
ddIndex b on  DLS->IdUsr+dtos(DLS->Date)+DLS->Von+DLS->Bis // ORD_DLS_USRDATE
ddIndex b on  DLS->IdPar+dtos(DLS->Date)+DLS->Von+DLS->Bis // ORD_DLS_PARDATE
ddFld IdDls    ,C,  LenIdDls(),0 when .f.
ddFld Date     ,D,  8,0 when DlsCanEdit()
ddFld Von      ,Q,  5,0 postedit {|x|GetTime(x)} when DlsCanEdit()
ddFld Bis      ,Q,  5,0 postedit {|x|GetTime(x)} when DlsCanEdit()
// IdPar : T : Therapeut
ddFld IdUsr    ,C, LenIdUsr(),0  picture PIC_ID ;
      when USRATTR_S $ UsrAttrib().and.DlsCanEdit() ;
      pick PickUsr(DLS->IdUsr)
ddFld IdDla    ,C, LenIdDla(),0  picture PIC_ID ;
      pick PickDla(DLS->IdDla) ;
      postedit {|x| GetNum(x) } ;
      when DlsCanEdit()
      * valid DlaExist(DLS->IdDla).and.(;
      *   empty(DLA->Zahlart).or.(DLS->Zahlart:=DLA->Zahlart)!=NIL);
      *   .and.ph_refresh()
ddFld Etat     ,C,  1,0 picture PIC_ID ;
      pick {|x| PickDbcCode("DLSETAT.DBC",x,"Status")} ;
      valid ph_refresh() ;
      when DLS->IdUsr==UserId().or.USRATTR_S$UsrAttrib()
ddFld NB       ,C, 60,0 when DlsCanEdit()
ddFld Zahlart  ,C,  1,0 picture PIC_ID ;
      pick {|x| PickDbcCode("DLSZAHL.DBC",x)} ;
      when DlsCanEdit()
ddFld IdPar    ,C, LenIdPar(),0  picture PIC_ID ;
      pick PickPar(NIL, DLS->IdPar) ;
      postedit {|x| GetIdPar( x ) } ;
      valid ph_refresh() ;
      when DlsCanEdit()
*ddFld x_IdPrj  ,C,  LenIdPrj(),0 pick DbfPick(;
*    {oPrj(),oPar()},;
*    "Akte von "+trim(ParName(DLS->IdPar)),;
*    "PRJPICKT", DLS->IdPrj, ".t.",;
*    DLS->IdPar,"PRJ->IdPar";
*  ) valid ph_refresh() postedit {|x|padl(trim(x),LenIdPrj())} ;
*  when DlsCanEdit()
// ddFld RgDatum   ,D,  8,0 when DlsCanRechnung()
ddFld QuitNr    ,C, 6,0 ;
      postedit {|x| GetNum(x) } ;
      when DlsCanEdit()
ddFld Kassiert  ,T, LenMont(),0 when DlsCanRechnung() GET_MONTANT
ddFld Mont      ,T, LenMont(),0 when DlsCanRechnung() GET_MONTANT
ddFld Memo      ,M, 10,0 when DlsCanEdit()
*ddFld IdPar2   ,C, LenIdPar(),0  picture PIC_ID ;
*      pick PickPar(NIL, DLS->IdPar) ;
*      postedit {|x| GetIdPar( x ) } ;
*      valid ph_refresh() ;
*      when DlsCanRechnung()
#ifdef DEF_DLP
  * action b key K_ENTER   prompt MnuInhalt() ;
  *                        block DlsDlpEdit()
  action b key K_F8      prompt "Anwesenheiten pro Sitzung [F8]" ;
                         block DlsDlpEdit()
#endif DEF_DLP
ddEndDef()
RETURN b


FUNCTION DlsExpr(cIdDls,x)
if DLS->IdDls != cIdDls
  seek cIdDls in DLS
endif
RETURN &x

#ifdef DEF_PIN

FUNCTION DlsZahlart
local c
RETURN DLS->Zahlart if !empty(DLS->Zahlart) 
if !empty(DLS->IdPin)
  c := DbfPeek(oPin(),DLS->IdPin,"PIN->Zahlart","")
  RETURN c if !empty(c)
endif
if !empty(DLS->IdPrj)
  c := DbfPeek(oPrj(),DLS->IdPrj,"PRJ->Zahlart","")
  RETURN c if !empty(c)
endif
RETURN " "

#endif

FUNCTION DlsCanEdit
RETURN .t. if empty(DLS->IdUsr)
// RETURN .t. if USRATTR_B $ UsrAttrib()
// Sekret„rinnen drfen Termine der Therapeuten eingeben
// aber Therapeuten nur ihre eigenen Termine
// Therapeuten haben "C" gesetzt, Sekret„rinnen nicht
// USRATTR_C
// USRATTR_S
if DLS->IdUsr!=UserId()
  RETURN .f. if ! USRATTR_S $ UsrAttrib()
endif
RETURN .t.
// RETURN empty(DLS->Etat)
// RETURN empty(DLS->Date).or.DLS->Date>=UserDate()-7.or.USRATTR_E$UsrAttrib()

FUNCTION DlsCanRechnung
RETURN .t.

FUNCTION DlsWait(wwin)
local b
local cIdDls := DLS->IdDls
// confirm("DlsWait()")
#ifdef DEF_DLP
  if wwin[WIN_WAITKEY] == 1
    b := oDlp()
    open area b, oDls(), oPar(), oPlz()
      ddSetOrder(1)
      edit data b key    DLP->IdDls ;
                  value  cIdDls ;
                  mode wait ;
                  window wwin ;
                  start top ;
                  query "DLPDLS"
    close area
  endif
#endif DEF_DLP
#ifdef DEF_MSG
  if wwin[WIN_WAITKEY] == 2
    b := oMsg()
    open area b, oDls(), oPar(), oPlz()
      ddSetOrder(5) // MSG->IdDls+dtos(MSG->Date)
      edit data b key    MSG->IdDls ;
                  value  cIdDls ;
                  mode wait ;
                  window wwin ;
                  start top ;
                  query "MSGDLS"
    close area
  endif
#endif DEF_MSG
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,alias(),DLS->IdDls)
#endif DEF_RFX
RETURN NIL

FUNCTION MsgDlaExist(cId)
RETURN '"' + cId + '" : unbekannte Dienstleistungsart!'

FUNCTION DlsIsValid()
RETURN !SetMsg(MsgDlaExist(DLS->IdDla)) if ! DlaExist(DLS->IdDla)
RETURN !SetMsg(MsgParExist(DLS->IdPar)) if ! ParExist(DLS->IdPar)
RETURN !SetMsg(MsgUsrExist(DLS->IdUsr)) if ! DbfPeek(oUsr(),DLS->IdUsr,".t.",.f.)
// RETURN !SetMsg(MsgDlaExist(DLS->IdDla)) if ! DbfPeek(oDla(),DLS->IdDla,".t.",.f.)
// RETURN !SetMsg(MsgParExist(DLS->IdPar)) if ! DbfPeek(oPar(),DLS->IdPar,".t.",.f.)
// RETURN .f. if !ParExist(DLS->IdPar)
RETURN !SetMsg('"'+DLS->Etat+'": ungltiger Status!') ;
  if empty(DbcText("DLSETAT.DBC",DLS->Etat))
RETURN !SetMsg('"'+DLS->Zahlart+'": ungltige Zahlart!') ;
  if empty(DbcText("DLSZAHL.DBC",DLS->Zahlart))
RETURN .t.

FUNCTION DlsPostEdit()
*local fld
*local cStand
#ifdef DEF_DLP
RETURN .f. if ! DlsDlpFill()
RETURN .f. if ! DlsDlpUpdate()
#endif DEF_DLP
RETURN .t.
* RETURN .t. if !empty(DLS->Etat)
* cStand := PickDbcCode("DLSETAT.DBC",NIL,"Zustand des Eintrags")
* RETURN .t. if cStand == NIL
* DLS->Etat := cStand
* fld:=FldLocate(oDls(),"Etat")
* RETURN .t. if fld:postBlock == NIL
* RETURN eval(fld:postBlock)

* FUNCTION DlsOnEtat()
* if !empty(DLS->Etat)
*   if ! empty(DLA->IdArt)
*     RETURN .f. if ! ArtExist(DLA->IdArt)
*     // field DLS->Mont may not exist in a DB if every DLA->IdArt is empty
*     DLS->Mont := ntom(DlsMont())
*   endif
*   RETURN .t.
* endif

FUNCTION DlsTestRec()
#ifdef DEF_DLP
RETURN .f. if ! DlsDlpTest()
#endif DEF_DLP
RETURN .t.

#ifdef DEF_DLP

FUNCTION oDlp
static b := NIL
if b != NIL ; RETURN b ; endif
define data b              ;
       name DLP ;
       create  DlpCreate() ;
       postedit DlpIsValid() ;
       predelete DlpCanDelete().and.ConfirmDelete()
ddIndex b on  DLP->IdDls+DLP->Line
ddIndex b on  DLP->IdPar+dtos(DLP->Date)+DLP->IdDls // ORD_DLP_PARDATE
ddFld IdDls    ,C,  LenIdDls(),0 when .f.
ddFld IdPar    ,C, LenIdPar(),0  picture PIC_ID ;
  pick PickPar(IDPRT_P, DLP->IdPar) ;
  postedit {|x| GetIdPar( x,IDPRT_P ) } ;
  when DlpCanEdit()
ddFld Line    ,C, 3,0 GET_PAD when DlpCanEdit()
// ld Seq     ,C, 3,0 postedit {|x|if(val(x)==0,x,GetNum(x))}
ddFld Date    ,D,  8,0 when DlpCanEdit()
ddFld Etat     ,C,  1,0 picture PIC_ID ;
      pick {|x| PickDbcCode("DLPETAT.DBC",x,"Status")} ;
      valid ph_refresh() ;
      when DlpCanEdit()
ddFld Zahlart  ,C,  1,0 picture PIC_ID ;
      pick {|x| PickDbcCode("DLSZAHL.DBC",x)} ;
      when DlpCanEdit()
action b key K_CTRL_RET block DlpEnter()
ddEndDef()
RETURN b


FUNCTION DlpIsValid()
RETURN !SetMsg(MsgParExist(DLP->IdPar)) if ! ParExist(DLP->IdPar)
RETURN !SetMsg(DLP->IdPar+" : keine Person!") if ! PAR->IdPrt $ "PRSZ"
RETURN .f. if ! DlsExist(DLP->IdDls)
RETURN .t.

STATIC FUNCTION DlsDlpSuggest()
local a := {}
// RETURN a if ! DLA->Etat != DLASTAT_S
RETURN a if ! DLAATTR_A $ DLA->Attrib
if PAR->IdPrt==IDPRT_P
  aadd(a,PAR->IdPar)
  RETURN a if DLAATTR_E $ DLA->Attrib
endif
open area oPlp(), oPar()
  softseek DLS->IdPar
  do while ! eof().and.PLP->IdPar1 == DLS->IdPar
    if ParExist(PLP->IdPar2).and.PAR->IdPrt==IDPRT_P
      aadd(a,PLP->IdPar2)
    endif
    skip
  enddo
close area
RETURN a

STATIC FUNCTION DlsDlpTest()
local a
RETURN .f. if ! DlsIsValid()
a := DlsDlpSuggest()
RETURN .t. if HasRecords(oDlp(),1,"DLP->IdDls",DLS->IdDls)
* if HasRecords(oDlp(),1,"DLP->IdDls",DLS->IdDls)
*   RETURN .t. if len(a) != 0
*   RETURN !SetMsg("Unerwartete Anwesenheiten !")
* endif
RETURN .t. if len(a) == 0
RETURN !SetMsg("Anwesenheiten fehlen !")

STATIC FUNCTION DlsDlpFill()
local a
local i
local lOkay := .t.
RETURN .f. if ! DlsIsValid()
if PARATTR_H $ PAR->Attrib
  PAR->(TryRecLock({||PAR->Attrib:=strtran(trim(PAR->Attrib),PARATTR_H)}))
endif
RETURN .t. if HasRecords(oDlp(),1,"DLP->IdDls",DLS->IdDls)
a := DlsDlpSuggest()
open area oDlp()
  for i := 1 to len(a)
    if dbAddRec()
      DLP->IdDls:=DLS->IdDls
      DLP->Date := DLS->Date
      DLP->IdPar:=a[i]
      DLP->Line:=padl(ntrim(i),3,"0")
      unlock record
    else
      lOkay := .f.
      exit
    endif
  next i
close area
RETURN lOkay




FUNCTION DlpEnter()
if indexord() == ORD_DLP_PARDATE
  RETURN DbfPage({oDls(),oDla(),oPar(),oArt()},DLP->IdDls)
elseif indexord() == 1
  RETURN ParPage(DLP->IdPar)
endif
RETURN .f.



FUNCTION DlpCanDelete()
RETURN .f. if eof()
RETURN .t. if empty(DLP->IdDls)
RETURN .t. if empty(DLP->IdPar)
RETURN .f. if indexord()!=1
RETURN .f. if DLP->IdDls!=DLS->IdDls
RETURN .t. if empty(DLS->IdUsr)
if DLS->IdUsr!=UserId()
  RETURN .f. if ! USRATTR_S $ UsrAttrib()
endif
RETURN .t. // DlsCanEdit()

FUNCTION DlpCanEdit()
RETURN .f. if indexord()!=1
RETURN .f. if empty(DLP->IdDls)
RETURN .f. if DLP->IdDls!=DLS->IdDls
RETURN .t. if empty(DLS->IdUsr)
if DLS->IdUsr!=UserId()
  RETURN .f. if ! USRATTR_S $ UsrAttrib()
endif
RETURN .t. // DlsCanEdit()

FUNCTION DlpCreate()
local cIdDls := left(ddKeyValue(),LenIdDls())
local cLine := DLP->Line
local nCreate := DDCREATE_REFRESH
local nOrder := indexord()
RETURN DDCREATE_FAIL if indexord()!=1
if DLS->IdUsr!=UserId()
  RETURN DDCREATE_FAIL if ! USRATTR_S $ UsrAttrib()
endif
ddSetOrder(1)
if eof() // 20070801 recno() == lastrec() + 1
  nCreate := DDCREATE_EDIT
endif
KeyGoBottom( cIdDls, "DLP->IdDls" )
if empty(cLine)
  cLine := NextNum(DLP->Line)
else
  do while .t.
    if DLP->Line >= cLine
      if ddRecLock()
        DLP->Line := NextNum(DLP->Line)
        unlock record
      endif
    else
      exit
    endif
    skip -1
    if bof() .or. DLP->IdDls != cIdDls
      exit
    endif
  enddo
endif
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
DLP->IdDls := cIdDls
DLP->Line  := cLine
DLP->Date  := DLS->Date
RETURN nCreate






FUNCTION DlsDlpUpdate()
local lOkay := .f.
local nCount := 0
open area oDlp()
  lOkay := .t.
  softseek DLS->IdDls
  do while !eof().and.DLP->IdDls==DLS->IdDls
    if DLP->Date != DLS->Date
      if ddRecLock()
        DLP->Date := DLS->Date
        unlock record
      else
        lOkay := .f.
      endif
    endif
    nCount += 1
    skip
  enddo
close area
RETURN lOkay

FUNCTION DlsDlpEdit()
RETURN .f. if ! DlsDlpFill()
DbfEdit(;
  {oDlp(),oPar()},;
  "Anwesenheiten "+alltrim(DLS->IdDls),;
  "DLPDLS",;
  NIL,; // DDMODE_FIND,;
  NIL,;
  DLS->IdDls,;
  "DLP->IdDls",;
  NIL;
)
RETURN .f. if ! DlsDlpFill()
RETURN DlsDlpUpdate()

#else

FUNCTION oDlp() ; RETURN NIL

#endif DEF_DLP


FUNCTION DlaExist(cId)
if DLA->IdDla == cId .and. ! eof() in DLA
  RETURN .t.
endif
seek cId in DLA
if eof() in DLA
  RETURN ! SetMsg(cId + " : unbekannte Dienstleistungsart" )
endif
RETURN .t.

FUNCTION DlsExist(cId)
if DLS->IdDls == cId .and. ! eof() in DLS
  RETURN .t.
endif
seek cId in DLS
if eof() in DLS
  RETURN ! SetMsg(cId + " : unbekannte Dienstleistung" )
endif
RETURN .t.

FUNCTION DlsPreDelete(lConfirm)
local lOkay := .f.
local cId := DLS->IdDls
default lConfirm to .t.
if lConfirm
  RETURN .f. if ! ConfirmDelete()
endif
#ifdef DEF_DLP
  MsgDisplay(MsgWorking())
  lOkay := .f.
  open area oDlp()
    lOkay := .t.
    ddSetOrder(1)
    softseek cId
    do while ! eof() .and. DLP->IdDls == cId
      if ddRecLock()
        delete
        unlock record
      else
        lOkay := .f.
        exit
      endif
      softseek cId
    enddo
  close area
  RETURN .f. if ! lOkay
#endif DEF_DLP
RETURN .t.



FUNCTION LenIdDla ; RETURN 3

#else

FUNCTION oDls() ; RETURN NIL
FUNCTION oDla() ; RETURN NIL

#endif DEF_DLS

#ifdef DEF_LPJ

FUNCTION oLpj // "Link between PAR and PRJ"
static b := NIL
if b != NIL ; RETURN b ; endif
define data b              ;
       name LPJ ;
       create LpjCreate()
ddIndex b on  LPJ->IdPrj+LPJ->Line
ddIndex b on  LPJ->IdPar+LPJ->IdPrj
ddFld IdPrj    ,C,  LenIdPrj(),0 picture PIC_ID ;
  pick PickPrj(LPJ->IdPrj)
ddFld Line     ,C, 3 ,0
ddFld IdPar    ,C, LenIdPar(),0  picture PIC_ID ;
  pick PickPar(NIL, LPJ->IdPar) ;
  postedit {|x| GetIdPar( x,"T" ) } 
ddEndDef()
RETURN b

FUNCTION LpjCreate()
local cIdPrj := left(ddKeyValue(),LenIdPrj())
local cLine := LPJ->Line
local nCreate := DDCREATE_REFRESH
local nOrder := indexord()
RETURN DDCREATE_FAIL if indexord() != 1
ddSetOrder(1)
if eof() // 20070801 recno() == lastrec() + 1
  nCreate := DDCREATE_EDIT
endif
KeyGoBottom( cIdPrj, "LPJ->IdPrj" )
if empty(cLine)
  cLine := NextNum(LPJ->Line)
else
  do while .t.
    if LPJ->Line >= cLine
      if ddRecLock()
        LPJ->Line := NextNum(LPJ->Line)
        unlock record
      endif
    else
      exit
    endif
    skip -1
    if bof() .or. LPJ->IdPrj != cIdPrj
      exit
    endif
  enddo
endif
ddSetOrder(nOrder)
RETURN DDCREATE_FAIL if ! dbAddRec()
LPJ->IdPrj := cIdPrj
LPJ->Line  := cLine
RETURN nCreate






FUNCTION PrjLpjEdit()
RETURN  DbfEdit(;
  {oLpj(),oPar(),oPrj()},;
  "Akteure in Akte : "+alltrim(PRJ->IdPrj),;
  "LPJPRJ",;
  NIL,;
  NIL,;
  PRJ->IdPrj,;
  "LPJ->IdPrj",;
  NIL;
)

FUNCTION PrjLpjWait(wwin)
local b := oLpj()
local cIdPrj := PRJ->IdPrj
open area b, oPar(), oPrj()
  ddSetOrder(1)
  edit data b key LPJ->IdPrj ;
    value    cIdPrj             ;
    start    bottom                 ;
    mode     wait  ;
    window   wwin ;
    query    "LPJPRJ" ;
    title (alltrim(PRJ->IdPrj) + " : Akteure")
close area
RETURN MnuDone()


#endif DEF_LPJ


#ifdef DEF_DRG

**
** DRG : Dienstleistungsrechnungen
**
FUNCTION oDrg
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name DRG ;
              wait {|msk| DrgDrlWait(msk)} ;
              predelete DrgPreDelete() ;
              postedit DrgPostEdit() ;
              editprint DrgPrint()
ddIndex b on  DRG->IdJnl+DRG->IdDoc
ddIndex b on  DRG->IdPar1+dtos(DRG->Date)
ddIndex b on  DRG->IdPar4+dtos(DRG->Date)+DRG->Periode+DRG->IdDrg
*
ddFld IdJnl    ,C, LenIdJnl(),0  picture PIC_ID when .f.
ddFld IdDoc    ,C, LenIdDoc(),0  picture PIC_ID when .f.
ddFld Date     ,D, 8,0  when empty(DRG->Etat)
ddFld Periode , C, LEN_PERIODE,0 picture PIC_ID ;
                   pick PickPer(DRG->Periode,"DRG") ;
                   when empty(DRG->Etat)
ddFld IdUsr    ,C, LenIdUsr(),0  picture PIC_ID ;
               when USRATTR_S $ UsrAttrib().and.DrgCanEdit() ;
               pick PickUsr(DRG->IdUsr)
ddFld IdPar   ,C, LenIdPar(),0  picture PIC_ID ;
                  pick PickPar(NIL,DRG->IdPar) ;
                  when DrgCanEdit()
ddFld IdPar2   ,C, LenIdPar(),0  GET_PAD ;
                   pick PickPar("P",DRG->IdPar2) ;
                   when empty(DRG->Etat)
ddFld Mont    ,T, LenMont(),0 when .f.
ddFld Etat     ,C,  1,0 picture PIC_ID pick {|x| PickEtat(x)}
*
action b key K_ENTER   prompt MnuInhalt() ;
                       block DrgDrlEdit()
ddEndDef()
RETURN b


FUNCTION DrgCanEdit
RETURN .f. if DRG->Etat == DocStatClosed()
RETURN .t. if empty(DRG->IdUsr)
if DLG->IdUsr!=UserId()
  RETURN .f. if ! USRATTR_S $ UsrAttrib()
endif
RETURN .t.

#define ORD_DRL_DLS 2

**
** DRL : DRG Lines
**
FUNCTION oDrl
static b := NIL
if b != NIL ; RETURN b ; endif
define data b               ;
  name DRL ;
  postedit DrlPostEdit() ;
  preedit indexord()!=1.or.DRG->Etat==DocStatClosed()
ddIndex b on  DRL->IdJnl+DRL->IdDoc+DRL->Line
ddIndex b on  DRL->IdDls // ORD_DRL_DLS
ddFld IdJnl    ,C, LenIdJnl(),0  picture PIC_ID when .f.
ddFld IdDoc    ,C, LenIdDoc(),0  picture PIC_ID when .f.
ddFld Line    ,C, LEN_POS,0 when DRG->Etat != DocStatClosed()
ddFld IdDls   ,C, LenIdDls(),0 pick {|x| PickDls(x)}
ddFld IdGen    ,C, LenIdGen(),0 picture PIC_ID ;
               when DRG->Etat != DocStatClosed();
               pick PickGen(DRL->IdGen) ;
               postedit {|x|GetIdArt(x)} ;
               valid DrlArtValidate()
ddFld Mont    ,T, LenMont(),0 when DRG->Etat == ETAT_NEW
ddEndDef()
RETURN b


FUNCTION DrgPreDelete()
local lOkay := .f.
RETURN ConfirmDelete() if empty(DRG->IdDoc) .or. empty(DRG->IdJnl)
RETURN .f. if ! ConfirmDelete()
open area oDrl(), oKtg()
  lOkay := .t.
  softseek DRG->IdDoc
  do while !eof() .and. DRL->IdDoc == DRG->IdDoc ;
                  .and. DRL->IdJnl == DRG->IdJnl
    if ddRecLock()
      delete
      unlock record
    else
      lOkay := .f.
    endif
    skip
  enddo
close area
RETURN lOkay

FUNCTION DrlPostEdit()
RETURN .f. if ! DlsExist(DRL->IdDls)
RETURN .f. if ! GenExist(DRL->IdGen)
RETURN .t.

FUNCTION DrgPostEdit()
RETURN .f. if ! ParExist(DRL->IdPar)
RETURN .f. if ! ParExist(DRL->IdPar2)
RETURN .t.

FUNCTION DrgDrlEdit()
local lOkay := .f.
RETURN .f. if ! ddRecLock()
DbfEdit({oDrl(),oDrg(),oArt()},;
   DRG->IdDrg,"DRLDRG",NIL,NIL,;
   DRG->IdJnl+DRG->IdDoc,"DRL->IdJnl+DRL->IdDoc")
lOkay := DrgDrlUpdate()
unlock record
RETURN lOkay

FUNCTION DrgDrlUpdate()
local nMont:=0
local lOkay := .f.
RETURN .f. if DRG->Etat == DocStatClosed()
open area oDrl()
  lOkay := .t.
  softseek DRG->IdJnl+DRG->IdDoc
  do while !eof().and.DRL->IdJnl==DRG->IdJnl.and.DRL->IdDoc==DRG->IdDoc
    nMont += val(DRL->Mont)
    skip
  enddo
close area
RETURN .f. if ! lOkay
DRG->Mont := ntom(nMont)
RETURN DrgPostEdit()



#endif DEF_DRG

#ifdef DEF_DLS

* Wird nur im SPZ benutzt
* FUNCTION ParDlsCollect(jnl,dDate1,dDate2,lTagged,xlDlsFilter)
FUNCTION Par2Naf(jnl,dDate1,dDate2,lTagged,xlDlsFilter)
local aNaf := {}
local xcRemark := "trim(DLA->Name1)"
xcRemark += "+iif(DLS->Etat=='V',' (verpasst)','')"
xcRemark += "+iif(empty(DLS->QuitNr),'',' ('+alltrim(DLS->QuitNr)+')')"
xcRemark += "+' am '+dtocf(DLS->Date)"
xcRemark += "+' mit '+trim(UsrName(DLS->IdUsr))"
default lTagged to .t.
* default xlDlsFilter to ".t."
RETURN aNaf if left(PAR->Tarif,1)!="1".and.!right(PAR->IdPgp,1)$"123"
RETURN NIL if ! ParDls2Naf(aNaf,jnl,dDate1,dDate2,lTagged,xlDlsFilter,;
  xcRemark,"''","''","''","DLS->Mont",;
  ".f.",{||"(VNL->IdDls:='"+DLS->IdDls+"')!=NIL"})
RETURN NIL if ! _ParDlpCollect(aNaf,jnl,dDate1,dDate2,lTagged,xlDlsFilter)
RETURN aNaf

* wird indirekt im SPZ und direkt bei PAC benutzt
FUNCTION ParDls2Naf(aNaf,jnl,dDate1,dDate2,lTagged,xlDlsFilter,;
                    xcDesig,xcMemo,xcQte,xcPrixU,xcMont,;
                    xlUpdate,bxlAfter)
local lOkay := .f.
default bxlAfter to {||".t."} // a codeblock that will be executed on
// DLS and which returns the expresstion to be evaluated on VNL (!)
// return .f. if ! Confirm(xcRemark)
open area oDls(), oDla(), oArt(), oPar()
  lOkay := .t.
  ddSetOrder(ORD_DLS_PARDATE)
  if dDate1 == NIL
    softseek PAR->IdPar
  else
    softseek PAR->IdPar+dtos(dDate1)
  endif
  do while lOkay .and.!eof().and.DLS->IdPar==PAR->IdPar ;
                 .and.DLS->Date<=dDate2
    seek DLS->IdDla in DLA
    if !empty(DLA->IdArt)
      seek DLA->IdArt in ART
      * if DLS->Zahlart=="R".and.!empty(DLS->Mont)
        if &xlDlsFilter
          NafCollect(aNaf,;
            "DLS",;
            DLS->IdDls,;
            "000",;
            DLS->Date,;
            DLA->IdArt,;
            LNCODE_ART,;
            &xcQte,; // "",; // ntoq(1,ART->QteForm),;
            &xcDesig,;
            &xcMemo,;
            &xcPrixU,; // "",; // DLS->Mont,;
            lTagged,;
            ART->QteForm,;
            NIL,;
            if(HasInt(),ART->IdInt,NIL),;   // #ifdef DEF_INT
            NIL,;   // #ifdef DEF_PROVI
            "",;  // #ifdef DEF_VNLATTR
            jnl[JNL_DC],;
            &xlUpdate,; // .f.,;
            &xcMont,;
            "",;
            eval(bxlAfter);
          )
        endif
      * endif
    endif
    skip
  enddo
close area
RETURN lOkay

         // "(VNL->Date:=ctod('"+dtoc(DLS->Date)+"'))!=NIL";



FUNCTION _ParDlpCollect(aNaf,jnl,dDate1,dDate2,lTagged,xlDlsFilter)
local lOkay := .f.
local xcRemark := "trim(DLA->Name1)"
* local xlFilter := 'DLP->Etat$"SV"'
xcRemark += "+' mit '+trim(UsrName(DLS->IdUsr))"
xcRemark += "+' am '+dtocf(DLS->Date)"
xcRemark += "+iif(DLP->Etat=='V',' (verpasst)','')"
// return .f. if ! Confirm(xcRemark)
* default lTagged to .t.
open area oDlp(), oDls(), oDla(), oArt(), oPar()
  lOkay := .t.
  ddSetOrder(ORD_DLP_PARDATE)
  softseek PAR->IdPar+dtos(dDate1)
  do while lOkay .and.!eof().and.DLP->IdPar==PAR->IdPar ;
                 .and.DLP->Date<=dDate2
    seek DLP->IdDls in DLS
    if &xlDlsFilter
    * if DLS->Zahlart=="R" // .and.!empty(DLS->Mont)
      if DLS->IdPar != DLP->IdPar
        if DbfPeek(oPar(),DLS->IdPar,"PAR->Tarif",NIL) == "99"
          seek DLS->IdDla in DLA
          if !empty(DLA->IdArt)
            if DLP->Etat$"SV"
              seek DLA->IdArt in ART
              * if &xlDlsFilter
                NafCollect(aNaf,;
                  "",;
                  "",;
                  "",;
                  DLS->Date,;
                  DLA->IdArt,;
                  LNCODE_ARTFIXE,;
                  "",; // ntoq(1,ART->QteForm),;
                  &xcRemark,;
                  "",;
                  "",; // DLS->Mont,;
                  lTagged,;
                  ART->QteForm,;
                  NIL,;
                  if(HasInt(),ART->IdInt,NIL),;   // #ifdef DEF_INT
                  NIL,;   // #ifdef DEF_PROVI
                  "",;  // #ifdef DEF_VNLATTR
                  jnl[JNL_DC],;
                  .f.,;
                  ntom(DlsArtPrix()),;
                  "",;
                  "(VNL->IdDls:='"+DLS->IdDls+"')!=NIL";
                )
              * endif
            endif
          endif
        endif
      endif
    endif
    skip
  enddo
close area
RETURN lOkay





FUNCTION UsrDlsCollect(cIdUsr,jnl,dDate1,dDate2,xlFilter,xlTagged)
local lOkay := .f.
local aNaf := {}
// local xlAfter := "(VNL->Date:=DLS->Date)!=NIL.and.(VNL->IdDls:=DLS->IdDls)!=NIL"
local xcRemark := "DLS->IdPar+' '+ParName()"
// default lTagged to .t."
open area oDls(), oDla(), oArt(), oPar()
  lOkay := .t.
  ddSetOrder(ORD_DLS_USRDATE)
  softseek cIdUsr+dtos(dDate1)
  do while lOkay .and. !eof().and.DLS->IdUsr==cIdUsr;
                 .and. DLS->Date<=dDate2
    seek DLS->IdPar in PAR
    seek DLS->IdDla in DLA
    if !empty(DLA->IdArt)
      seek DLA->IdArt in ART
      if &xlFilter
        NafCollect(aNaf,;
          "",;
          "",;
          "",;
          DLS->Date,;
          DLA->IdArt,;
          LNCODE_ART,;
          "",;
          &xcRemark,;
          "",;
          "",;
          &xlTagged,;
          ART->QteForm,;
          NIL,;
          if(HasInt(),ART->IdInt,NIL),;   // #ifdef DEF_INT
          NIL,;   // #ifdef DEF_PROVI
          "",;  // #ifdef DEF_VNLATTR
          jnl[JNL_DC],;
          .f.,;
          DLS->Kassiert,;
          "",;
          "(VNL->IdDls:='"+DLS->IdDls+"')!=NIL";
        )
      endif
    endif
    skip
  enddo
close area
RETURN aNaf


** Summe der Beitr„ge der Anwesenden
FUNCTION DlsDlpPrix(xlFilter)
local n := 0
open area oDlp(),oPar()
  softseek DLS->IdDls
  do while !eof() .and. DLP->IdDls == DLS->IdDls
    if ParExist(DLP->IdPar)
      if &xlFilter
        n += DlsArtPrix()
      endif
    endif
    skip
  enddo
close area
RETURN n

FUNCTION DlsArtPrix()
local c
if ART->IdPga=="T"
  c := "ART->Prix"+right(PAR->Tarif,1)
elseif ART->IdPga=="H"
  c := "ART->Prix"+right(PAR->IdPgp,1)
else
  RETURN 0
endif
if type(c) != "C"
  SetMsg("'"+c+"' : ungltige Formel")
  RETURN 0
endif
RETURN val(&c)

FUNCTION DlsVnlSum()
RETURN DbfSum({oVnl()},"val(VNL->cMont)",3,;
  DLS->IdDls,"VNL->IdDls=='"+DLS->IdDls+"'")

FUNCTION DlsHasVnl()
#ifdef DEF_VNA
  // bei PAC:
  RETURN HasRecords(oVnl(),3,"VNL->Match","DLS"+DLS->IdDls+"000")
#else
  RETURN HasRecords(oVnl(),3,"VNL->IdDls",DLS->IdDls)
#endif

FUNCTION DlsVnlExpr(xuExpr,uExpr)
open area oVnl(), oVen()
  ddSetOrder(3)
  seek DLS->IdDls
  if !eof()
    seek VNL->IdJnl+VNL->IdDoc in VEN
    uExpr := &xuExpr
  endif
close area
RETURN uExpr

FUNCTION ParHasDls(dDate1,dDate2,xlFilter)
local lHas := .f.
RETURN .f. if ! DbfScan(;
  {oDls(),oDla()},4,PAR->IdPar+dtos(dDate1),;
  "DLS->IdPar=='"+PAR->IdPar+"'.and.dtos(DLS->Date)<='"+dtos(dDate2)+"'",;
  xlFilter,{||lHas:=.t.},1,.f.)
RETURN lHas

FUNCTION ParHasDlp(dDate1,dDate2,xlFilter)
local lHas := .f.
if xlFilter != NIL
  xlFilter := "DlsExist(DLP->IdDls).and.("+xlFilter+")"
endif
RETURN .f. if ! DbfScan(;
  {oDlp(),oDls(),oDla()},2,PAR->IdPar+dtos(dDate1),;
  "DLP->IdPar=='"+PAR->IdPar+"'.and.dtos(DLP->Date)<='"+dtos(dDate2)+"'",;
  xlFilter,{||lHas:=.t.},1,.f.)
RETURN lHas


FUNCTION DlsMust()
RETURN 0 if DLS->Zahlart!="B"
RETURN val(DLS->Mont)+DbfSum({oDls()},;
  "iif(DLS->Zahlart$'BZ',val(DLS->Mont),0)-val(DLS->Kassiert)",;
  4,DLS->IdPar,"DLS->IdPar=='"+DLS->IdPar+"'.and.recno()!="+ntrim(recno()))



#endif DEF_DLS



FUNCTION IdStruct(cId,nStep)
RETURN padr(space((len(trim(cId))-1)*nStep)+cId,len(cId)*(nStep+1)-1)


