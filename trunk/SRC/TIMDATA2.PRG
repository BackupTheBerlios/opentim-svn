** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2007 Luc Saffre
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

#include "Tim.ch"
#include "DefData.ch"


#ifdef LG_GERMAN
  #define MSG001  "~Druckparameter „ndern     [F8]"
  #define MSG002  "~Transfer                  [F2]"
  #define MSG033  " : Ungltige Kontonummer !"
#endif
#ifdef LG_FRENCH
  #define MSG001  "~ParamŠtres imprimante     [F8]"
  #define MSG002  "~Transf‚rer                [F2]"
  #define MSG033  " : Nø de compte bancaire invalide !"
#endif
#ifdef LG_EN
  #define MSG033  " : Invalid bank account number !"
#endif


#ifdef DEF_MSG
REQUEST MsgOnTop
#endif
REQUEST descend


#ifdef DEF_PRF

**
** PRF - Codes profession
**
FUNCTION oPrf()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                  ;
  name PRF                          ;
  create PrfCreate(b)
  * viewdetail PrfGetCli(b)
  ddIndex b on PRF->IdPrf
ddFld IdPrf   ,C,LEN_IDPRF,0 picture PIC_ID when .f.
ddFld Libell  ,C,40,0
ddFld AllocF  ,C,10,0 attrib H
ddFld AllocD  ,C,10,0 attrib H
ddFld AllocN  ,C,10,0 attrib H
ddFld AllocE  ,C,10,0 attrib H
* action b key K_ENTER prompt "Partners [Enter]"  block PrfGetPar()
ddEndDef()
RETURN b

#endif DEF_PRF


#ifdef DEF_AMK

FUNCTION oAmk()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name AMK
ddEndDef()
RETURN b

#else
FUNCTION oAmk() ; RETURN NIL
#endif DEF_AMK

#ifdef DEF_MSG

**
** MSG - messages
**
**
FUNCTION oMsg()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name MSG                           ;
  editprint  MsgPrint() ;
  wait {|x|MsgWait(x)} ;
  postedit MsgPostEdit()

ddAddIndex("MSG->IdMsg","IdMsg",NIL,{|x|GetNum(padl(x,5))}) // ORD_MSG_ID
// ddIndex b on  MSG->IdMsg
ddIndex b on  MSG->IdUsr+dtos(MSG->Date)+MSG->IdMsg // ORD_MSG_USER
ddIndex b on  MSG->IdPar+dtos(MSG->Date)+MSG->IdMsg // ORD_MSG_PAR
ddAddIndex("MSG->IdPar+MSG->Top+dtos(MSG->Date)+MSG->IdMsg","Thread")
// ddIndex b on  MSG->IdPar+MsgOnTop("dtos(MSG->Date)+MSG->IdMsg",space(13))+dtos(MSG->Date)+MSG->IdMsg
#ifdef DEF_PRJ
  ddIndex b on  MSG->IdPrj+dtos(MSG->Date) // ORD_MSG_PRJ
#endif DEF_PRJ

ddFld IdUsr   ,C, LenIdUsr(),0 picture PIC_ID pick PickUsr(MSG->IdUsr)
#ifdef DEF_PRJ
  ddFld IdPrj   ,C, LenIdPrj(),0 picture PIC_ID ;
                    pick PickPrj(MSG->IdPrj)
#else
  ddFld IdPrj   ,C, 0,0 attrib H
#endif
ddFld Date    ,D, 8,0
ddFld Titre   ,C,40,0
ddAddField("IdMsg","C",5,0,"","",NIL,NIL,NIL,{|x|PickNum(x)},;
  NIL,{|x|GetNum(x)},{||"E"$UsrAttrib()})
ddFld Texte   ,M,10,0
ddFld Etat    ,C, 1,0 // seit 20060531 wieder da attrib H
ddAddField("Parent","C",5,0,"","",NIL,NIL,NIL,;
  {|x|DbfPick(;
   {oMsg(),oPar()},;
   "MSG auswahlen","MSGPICK",x,NIL,;
   NIL,NIL,;
   "MSG->IdMsg")},;
  NIL,{|x|GetNum(x)},{||"E"$UsrAttrib()};
)
ddFld Top     ,C, 5,0
ddFld IdPar   ,C, LenIdPar(),0 GET_PAD ;
               pick PickPar(NIL,MSG->IdPar)
ddFld IdTxt   ,C, LenIdTpl(),0 picture PIC_ID ;
                               pick PickTpl(TPLTYPE_MSG, MSG->IdTxt)
ddFld _Firme ,C,35,0 attrib V block padr(ParName(MSG->IdPar),35)


action b key K_F12 prompt MnuMemoEdit()  block MsgMemoEdit()
*action b key K_ENTER   block MsgMemoEdit()
ddEndDef()
RETURN b

FUNCTION MsgPostEdit
local cTop := MsgOnTop("MSG->IdMsg")
RETURN .t. if cTop == NIL
MSG->Top := cTop
RETURN .t.



FUNCTION MsgOnTop(xuExpr,uReturn)
local a := { MSG->IdMsg }
local nOrder := indexord()
local lDescend := dbdescend()
local nRecNo := recno()
RETURN uReturn if alias() != "MSG"
ddSetOrder(1)
do while !empty(MSG->Parent)
  RptWrite("MsgOnTop("+MSG->IdMsg+")")
  if ! aAddIfFirst(a, MSG->Parent)
    err_Circular(a,MSG->Parent)
    exit
  endif
  seek MSG->Parent
enddo
uReturn := &xuExpr
goto nRecNo
ddSetOrder(nOrder,lDescend)
RETURN uReturn

FUNCTION MsgLevel()
local a := { MSG->IdMsg }
local nLevel := 0
local nOrder := indexord()
local lDescend := dbdescend()
local nRecNo := recno()
RETURN 0 if alias() != "MSG"
* 20041129 RptWrite("MsgLevel("+MSG->IdMsg+")")
* if AreaOpen({oMsg()},.f.,NIL,.t.)
* open area oMsg() readonly
  ddSetOrder(1)
  do while !empty(MSG->Parent)
    if ! aAddIfFirst(a, MSG->Parent)
      err_Circular(a,MSG->Parent)
      exit
    endif
    seek MSG->Parent
    nLevel += 1
  enddo
  *AreaClose()
* endif
goto nRecNo
ddSetOrder(nOrder,lDescend)
RETURN nLevel



**
** MsgWait()
**
FUNCTION MsgWait(win)
local b
if nextkey() != 0
  RETURN NIL
elseif win[WIN_WAITKEY] == 12
  MemoDisplay(MSG->Texte, ;
    win[WIN_TOP], ;
    win[WIN_LEFT], ;
    win[WIN_HEIGHT], ;
    win[WIN_WIDTH], ;
    NIL, NIL, 250, ;
  )
endif
RETURN .f.



#endif DEF_MSG

#ifdef DEF_STS

**
** STS - Statistique de stock
**
*FUNCTION oSts(lRebuild)
** local b
*static b := NIL
*if lRebuild == .t. ; b := NIL ; RETURN NIL ; endif
*if b != NIL ; RETURN b ; endif
*define data b name STS
*ddIndex b on STS->IdArt+STS->Periode
*ddFld IdArt  ,C, LenIdArt(),0   picture PIC_ID when .f.
*ddFld Periode,C, LEN_PERIODE,0 picture PIC_ID
*ddFld QteA   ,C,  LenQte(),0
*ddFld MontA  ,C, 10,0
*ddFld QteV   ,C,  LenQte(),0
*ddFld MontV  ,C, 10,0
*ddFld _PMA   ,C, 10,0 attrib V block ntom(val(STS->MontA)/qton(STS->QteA))
*ddFld _PMV   ,C, 10,0 attrib V block ntom(val(STS->MontV)/qton(STS->QteV))
*ddFld QteS   ,C,  LenQte(),0
*ddFld MontS  ,C, 10,0
*ddFld PAMP   ,C, 10,0
**
** action b key K_ENTER prompt MSG019 block VenDetail(b,.T.)
*#ifdef DEF_STRFILES
*  #ifdef LG_GERMAN
*  #include "STSD.STR"
*  #else
*  #include "STSF.STR"
*  #endif
*#endif DEF_STRFILES
*RETURN b

#endif DEF_STS

#ifdef DEF_SUB

**
** SUB - Substituts d'articles
**
FUNCTION oSub(lRebuild)
* local b
static b := NIL
if lRebuild == .t. ; b := NIL ; RETURN NIL ; endif
if b != NIL ; RETURN b ; endif
define data b name SUB
  ddIndex b on  SUB->IdArt1
ddFld IdArt1  ,C, LenIdArt(),0 picture PIC_ID when .f.
ddFld IdArt2  ,C, LenIdArt(),0 picture  PIC_ID ;
                      pick PickArt(SUB->IdArt2)
ddFld Qte     ,C, 6,0 GET_NUM
ddFld _Desig  ,C,40,0 attrib V block ArtName(SUB->IdArt2)
*#ifdef DEF_STRFILES
*  #ifdef LG_GERMAN
*  #include "SUBD.STR"
*  #else
*  #include "SUBF.STR"
*  #endif
*#endif DEF_STRFILES
ddEndDef()
RETURN b

#endif DEF_SUB


#ifdef DEF_ANW

**
** ANW - Anwesenheiten
**
FUNCTION oAnw()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                  ;
  name ANW                          ;
  postedit AnwPostEdit()
  ddIndex b on dtos(ANW->Date)
  ddIndex b on ANW->IdPar + dtos(ANW->Date)
  ddFld Date    ,D, 8,0
  ddFld IdPar   ,C, LenIdPar(),0 picture PIC_ID                        ;
                                 pick PickPar(NIL,ANW->IdPar)
  ddFld _Libell ,C,20,0 attrib V ;
                        block padr(ParName(ANW->IdPar),20)
  ddFld A1      ,C, 4,0 picture PIC_ID pick PickAwcList(ANW->A1)
  ddFld A2      ,C, 4,0 picture PIC_ID pick PickAwcList(ANW->A2)
  ddFld A3      ,C, 4,0 picture PIC_ID pick PickAwcList(ANW->A3)
  ddFld A4      ,C, 4,0 picture PIC_ID pick PickAwcList(ANW->A4)
  ddFld A5      ,C, 4,0 picture PIC_ID pick PickAwcList(ANW->A5)
  ddFld A6      ,C, 4,0 picture PIC_ID pick PickAwcList(ANW->A6)
  ddFld A7      ,C, 4,0 picture PIC_ID pick PickAwcList(ANW->A7)
*
ddEndDef()
RETURN b


**
** AWC - Anwesenheits-Codes
**
FUNCTION oAwc()
local b
* static b := NIL
* if b != NIL ; RETURN b ; endif
define data b                  ;
  name AWC
  ddIndex b on AWC->IdAwc
  ddFld IdAwc   ,C, 1,0 picture PIC_ID
  ddFld Desig   ,C,30,0
  ddFld PrixV   ,C,10,0 GET_MONTANT
  ddFld PrixA   ,C,10,0 GET_MONTANT
*
ddEndDef()
RETURN b

#endif DEF_ANW


#ifdef DEF_IBAN

// DOC : http://www.ecbs.org/Download/EBS204_V3.1.PDF

FUNCTION LenIdBic() ; RETURN 12
* FUNCTION LenIBAN() ; RETURN 34
FUNCTION LenBqe() ; RETURN 47 // 12+1+34

**
** BIC - Bank Identifier Code (=Code SWIFT)
**
FUNCTION oBic()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                  ;
  name BIC
ddIndex b on BIC->IdBic
ddFld IdBic   ,C,LenIdBic(),0 picture PIC_ID
ddFld Name    ,C,40,0
ddFld IdNat   ,C,LEN_IDNAT,0 picture PIC_ID pick {|x|PickNat(x)}
ddEndDef()
RETURN b

FUNCTION PickBic(cStart,cIdNat)
local xlFilter
if cIdNat != NIL
  xlFilter := "BIC->IdNat=='"+cIdNat+"'"
endif
RETURN DbfPick({oBic()},;
  "Select Bank Identifier Code","BICPICK",cStart,xlFilter)

FUNCTION ValIdBic(cIdBic)
RETURN .t. if empty(cIdBic)
Confirm(utos(cIdBic))
RETURN .t. if DbfPeek(oBic(),cIdBic,".t.",.f.)
RETURN ! SetMsg(MsgBicExist(cIdBic))

FUNCTION MsgBicExist(cIdBic)
RETURN cIdBic + " : no such Bank Identifier Code!"


FUNCTION BicCountry(cIdBic)
RETURN DbfPeek(oBic(),padr(cIdBic,LenIdBic()),"NatCountry(BIC->IdNat)",NIL)

FUNCTION BqePostEdit(x)
local r := BqeParse(x)
RETURN x if r == NIL
* if r == NIL
*   RETURN x if Confirm(SetMsg(),MsgSure())
*   RETURN space(len(x))
* endif
RETURN r


FUNCTION BqeValidate(x)
RETURN (BqeParse(x) != NIL)

FUNCTION IsIBAN(x)
RETURN ":" $ x
* RETURN ! left(x,1) $ "0123456789"


/*
  returns (1) the correctly formatted BIC:IBAN string or (2) NIL.
  If NIL, then SetMsg() contains the explanation
*/
STATIC FUNCTION BqeParse(x)
* local lIsIBAN // whether it is a domestic (.f.) or an IBAN number
local nSplit
local cCountry
local cIdBic
local cIBAN
local cBBAN := NIL // Basic Bank Account Number
RETURN x if empty(x)
x := strtran(x," ")
x := strtran(x,"-")
x := strtran(x,".")
nSplit := at(":",x)
* lIsIBAN := ! left(x,1) $ "0123456789"
if nSplit == 0 // also eine Inlands-Kontonummer
  * if ! IsIBAN(x) // also eine Inlands-Kontonummer
  if MemPays == "B  "
    RETURN BqeBeParse(x)
  else
    // No validation of domestic bank account number
    RETURN x
  endif
endif
cIdBic := upper(left(x,nSplit-1))
cIBAN  := upper(strtran(substr(x,nSplit+1)," "))
if (cCountry := BicCountry(cIdBic)) == NIL
  SetMsg(MsgBicExist(cIdBic))
  RETURN NIL
endif
if !empty(cCountry) .and. left(cIBAN,2) != cCountry
  SetMsg(trim(cIBAN) + " : IBAN must start with '"+cCountry+"' !")
  RETURN NIL
endif
RETURN NIL if ! ChkIBAN34(cIBAN)
cBBAN := substr(cIBAN,5) // Basic Bank Account Number
if cCountry == "BE"
  cBBAN := BqeBeParse(cBBAN)
else
  // currently no other national validation algorithms supported
endif
RETURN NIL if cBBAN == NIL
x := cIdBic+":"
do while len(cIBAN) > 0
  x += left(cIBAN,4)+" "
  cIBAN := substr(cIBAN,5)
enddo
RETURN trim(x)
* RETURN cIdBic + ":" + left(cIBAN,4)+" "+cBBAN
* RETURN left(x,4)+" "+cBBAN

** check digits at pos 3 and 4 of a IBAN
STATIC FUNCTION ChkIBAN34(x)
local i
local x2
// Move the first four characters of the IBAN to the right of the number.
x2 := substr(x,5)+left(x,4)
// Convert the letters into numerics in accordance with the conversion
// table under 6.3.
*local x2, c
*x2 := ""
*for i := 1 to len(x)
*  c := substr(x,i,1)
*  if c $ "0123456789"
*    x2 += c
*  else
*    x2 += chr(ascii(
*  endif
*next i
for i := 65 to 90
  x2 := strtran(x2,chr(i),ntrim(i-55))
next i
// Apply MOD 97-10 (see ISO 7064). For the check digits to be correct,
// the remainder after calculating the modulus 97 must be 1.
RETURN .t. if BigMod(x2,97) == 1
* Warning(x,x2)
SetMsg(alltrim(x) + " : bad check digits (MOD 97-10 failed)")
RETURN .f.


* via http://groups.google.com/groups?dq=&hl=en&lr=&ie=UTF-8&oe=UTF-8\
*     &threadm=3EC0C56B.2BBF606%40skynet.be&prev=/groups%3Fq%3Dcomp.\
*     lang.clipper%2B%26ie%3DUTF-8%26oe%3DUTF-8%26hl%3Den%26btnG\
*     %3DGoogle%2BSearch
* Author: Marek Horodyski (m.horodyski@pzuzycie.com.pl)
Function BigMod( LiczbaAsString, modulo)
Local krok, reszta, myMod, poIle := 6, Suma := 0, rzad := 1
Local los := Len( LiczbaAsString)
Local krokow := Int( los/poIle), mnoznik := 10^poIle
For krok := 1 TO krokow
    Suma += Val( SubStr( LiczbaAsString, los - poile * krok + 1, poIle)) ;
            % modulo * rzad
    rzad :=  ( rzad * mnoznik) % modulo
next krok
If ( reszta := los % poIle) != 0
   Suma += Val( Left( LiczbaAsString, reszta)) % modulo * rzad
End
Return Suma % modulo



FUNCTION BqeBeParse(x)
x := strtran(x,"-")
if len(x) == 12
  if val(left(x,10)) % 97 == 0
    RETURN transform(x,"@R !!!-!!!!!!!-!!") if val(right(x,2)) == 97
  elseif val(right(x,2)) == val(left(x,10)) % 97
    RETURN transform(x,"@R !!!-!!!!!!!-!!")
  endif
endif
SetMsg(alltrim(x) + " : not a valid Belgian bank account number !")
RETURN NIL


#else // Klassisches Format (vor DEF_IBAN)

FUNCTION oBic() ; RETURN NIL

FUNCTION LenBqe() ; RETURN 14

FUNCTION BqePostEdit(cBqe,cPays)
local cOld := cBqe
RETURN cBqe if empty(cBqe)
if cPays == "B  " .or. IsBqe(cBqe)
  cBqe := strtran(cBqe," ")
  cBqe := strtran(cBqe,"-")
  cBqe := strtran(cBqe,".")
  if len(cBqe) == 12
    if val(left(cBqe,10)) % 97 == 0
      RETURN transform(cBqe,"@R !!!-!!!!!!!-!!") if val(right(cBqe,2)) == 97
    elseif val(right(cBqe,2)) == val(left(cBqe,10)) % 97
      RETURN transform(cBqe,"@R !!!-!!!!!!!-!!")
    endif
  endif
  RETURN cOld if Confirm(cOld + MSG033,MsgSure(),MSG_NO)
  RETURN space(len(cOld))
endif
#ifdef LG_FRENCH
  SetMsg("(Pas de contr“le du nø de compte)")
#else
  SetMsg("(Keine Kontrolle der Kontonummer)")
#endif
RETURN cOld

FUNCTION IsBqe(cBqe)
RETURN .f. if len(trim(cBqe)) != 14
RETURN .f. if ! substr(cBqe,4,1) $ "-."
RETURN .f. if ! substr(cBqe,12,1) $ "-."
RETURN .t.

FUNCTION BqeValidate(cBqe)
cBqe := strtran(cBqe," ")
cBqe := strtran(cBqe,"-")
cBqe := strtran(cBqe,".")
if val(left(cBqe,10)) % 97 == 0
  RETURN .t. if val(right(cBqe,2)) == 97
elseif val(right(cBqe,2)) == val(left(cBqe,10)) % 97
  RETURN .t.
endif
RETURN .f.

#endif DEF_IBAN

* NISS : No. d'identification de securit'e sociale

FUNCTION NissValidate(cNATREG)
local xtest := substr(cnatreg,1,6)+substr(cnatreg,8,3)
if substr(cnatreg,7,1) == "="
  xtest := "2"+xtest
endif
xtest := val(xtest)
xtest := abs((xtest-97*(int(xtest/97)))-97)
if xtest == 0
   xtest := 97
endif
if xtest<>int(val(substr(cnatreg,12,2)))
  RETURN !SetMsg("Fehlerhafte Nationalregisternummer")
endif
RETURN .t.


