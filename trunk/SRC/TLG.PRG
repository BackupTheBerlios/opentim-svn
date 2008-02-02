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

#ifdef DEF_TLG

static saTlg

#define ORD_TLG_PARDATE 1

**
** TLG -
**
FUNCTION oTlg
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name TLG ;
  create TlgCreate() ;
  predelete TlgPreDelete()
ddIndex b on TLG->IdPar+dtos(TLG->Date) // ORD_TLG_PARDATE
ddFld IdPar    ,C,LenIdPar(),0  picture PIC_ID ;
                                pick PickPar(NIL,TLG->IdPar)
* ddFld IdJnl    ,C, LenIdJnl(),0 picture PIC_ID pick PickIdJnl(JNLALIAS_IMP,TLG->IdJnl)
* ddFld IdDoc    ,C, LEN_IDDOC,0 pick PickDoc(TLG->IdJnl,TLG->IdDoc)
* ddFld Line     ,C, LEN_POS,0
ddFld Match    ,C,LenIdJnl()+LEN_IDDOC+LEN_POS,0
ddFld Date     ,D, 8,0
ddFld Bemerk   ,C,30,0
ddFld Mont     ,T,LenMont(),0 GET_MONTANT
ddFld IdPar2   ,C,LenIdPar(),0  picture PIC_ID ;
                                pick PickPar(NIL,TLG->IdPar2)
ddFld _Ist     ,T,LenMont(),0 attrib V block ntom(TlgSatis(TLG->Match))
ddFld _IstNZ   ,T,LenMont(),0 attrib V block ntom(TlgSatis(""))
action b key K_F5    prompt "Tilgungsplan ~generieren  [F5]" block TlgGenerate(PAR->IdPar)
ddEndDef()
RETURN b

**
** ParTlgEdit() -
**
FUNCTION ParTlgEdit(cIdPar)
local b := oTlg()
ParTlgInit(cIdPar)
open area b, oPar()
  ddSetOrder(ORD_TLG_PARDATE)
    edit data b key TLG->IdPar ;
      value    cIdPar             ;
      start    bottom             ;
      mode     find               ;
      query ("TLGPAR")           ;
      create {||TlgCreate(cIdPar)} ;
      title (ParName(cIdPar) + " : Tilgungsplan")
close area
RETURN MnuDone()


FUNCTION TlgCreate(cIdPar)
local aBuf := CopyRec()
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
if cIdPar != NIL
  TLG->IdPar := cIdPar
endif
* unlock record 19980430
ParTlgInit(cIdPar)
RETURN DDCREATE_DONE

**
** TlgGenerate()
**
FUNCTION TlgGenerate(cIdPar)
local nRest
local lLetzteRate
local aSubMont
local nSkipMonth := 1
local nCount := 0
local dDate
local dDate1 := UserDate()
local cVerteil := "P"
local nMont := 0
local cMont
local cSubMont  := space(LenMont())
local nSubMont
local nSubCount := 1
local i
local aIml
local a := {}
local b := oTlg()
local nMont2 := 0
if empty(cIdPar)
  Warning("Ja wie machen wir das denn ?")
  RETURN .f.
endif
MviSetFilter( ;
  BUTTON_ON, NIL, ;
  "FFO",space(LenIdJnl()), ;
  space(LenIdDoc()), space(LenIdDoc()), ;
  " ", NIL, ;
  space(LEN_PERIODE), ;
  cIdPar, BUTTON_OFF ;
)
RETURN .f. if (aIml := MviLnCollect( {||.t.}, .f. ) ) == NIL
RETURN .f. if len(aIml) == 0
for i := 1 to len(aIml)
  aCollect(a, { aIml[i][IML_MATCH], val(aIml[i][IML_MONT]) } )
  nMont += val(aIml[i][IML_MONT])
next i
cMont := ntom(nMont)
* if nMont == 0 2001-02-28
if abs(nMont) < Tolerance(SetDecPos()) //  == 0
  cVerteil := "G"
endif
open window ("Tilgungsplan generieren") size 10,60 help "TLGGENE"
do while .t.
  WinHome()
  say "Gesamtbetrag "
  get cMont GET_MONTANT
  WinCr()
  say "Erste FÑlligkeit am "
  get dDate1
  WinCr()
  say "weitere FÑlligkeiten alle "
  get nSkipMonth picture "##"
  say " Monate"
  WinCr()
  say "max. Ratenbetrag : "
  get cSubMont GET_MONTANT ;
  valid ValSubMont(val(cSubMont),val(cMont),@nSubCount)
  WinCr()
  say "Anzahl Raten "
  get nSubCount picture "##" valid ValSubCount(nSubCount,val(cMont),@cSubMont)
  if len(a) > 1
    WinCr()
    say ntrim(len(a)) + " Buchungen wurden markiert"
    WinCr()
    say "Verteilung : "
    get cVerteil picture "!"
    say " (P/E/G)"
  endif
  if (nKey := ReadScr()) != K_ESC
    if abs(val(cMont)) < Tolerance(SetDecPos()) //  == 0
    * if val(cMont) == 0 // 2001-02-28
      SetMsg("Gesamtbetrag darf nicht leer sein !")
      loop
    endif
    if abs(val(cSubMont)) < Tolerance(SetDecPos()) //  == 0
    * if val(cSubMont) == 0
      SetMsg("Ratenbetrag darf nicht leer sein !")
      loop
    endif
  endif
  exit
enddo
close window
RETURN NIL if nKey == K_ESC
/***
 nMont ist der Betrag, der eigentlich offen ist
 val(cMont) ist der Gesamtbetrag des Tilgungsplans
***/
if nMont == 0 .or. cVerteil == "G"
  a := { { "", val(cMont) } }
*elseif nMont != val(cMont)
*  for i := 1 to len(a)
*    a[i][2] := val(ntom(a[i][2] * val(cMont) / nMont))
*    nMont2 += a[i][2]
*  next i
*  * atail(a)[2] += (val(cMont) - nMont2)
endif
** nMont2 wird jetzt benutzt, um den (noch) zu verteilenden Gesamtbetrag
** festzuhalten.
nMont2 := 0
for i := 1 to len(a)
  if dbAddRec()
    TLG->Match  := a[i][1]
    TLG->IdPar  := cIdPar
    TLG->Date   := UserDate()
    TLG->Bemerk := "Tilgungsplan : " + ltrim(ntom(a[i][2])) + " BEF"
    unlock record
    nCount++
    nMont2 += a[i][2]
  else
    exit
  endif
next i
dDate := dDate1
do while nMont2 > 0
  nSubMont := min(nMont2,val(cSubMont))
  ** nSubMont ist das Potential der vorliegenden Rate.
  do while nMont2 > 0 .and. nSubMont > 0
    aSubMont := {}
    lLetzteRate := .f.
    nRest := nSubMont
    for i := 1 to len(a)
      if i == len(a)
        aadd( aSubMont, nRest )
      elseif cVerteil == "E"
        aadd( aSubMont, val(ntom(nSubMont / len(a))))
      elseif cVerteil == "P"
        aadd( aSubMont, val(ntom(nSubMont * a[i][2] / nMont2)))
      else
        aadd( aSubMont, val(ntom(nMont2)))
      endif
      if aSubMont[i] > a[i][2]
        aSubMont[i] := a[i][2]
        lLetzteRate := .t.
      endif
      nRest -= aSubMont[i]
    next i
    **
    ** Soweit die "normale" Aufteilung der Rate auf die verschiedenen
    ** Forderungen. Wenn jedoch eine der Forderungen den ihr zustehenden
    ** Anteil nicht mehr nîtig hat (weil sie mittlerweile abbezahlt ist),
    ** dann muss dieser Betrag auf die noch offenen Forderungen verteilt
    ** werden. Wir wollen ja nicht weniger erwarten als man uns zugesagt
    ** hat...
    **
    ** Wenn dies also die letzte Rate fÅr mindestens eine der
    ** Forderungen ist, dann dÅrfen jetzt zuerst einmal nur diese
    ** EintrÑge gemacht werden. Anschlie·end muss das verbleibende
    ** Ratenpotential neu verteilt werden
    for i := 1 to len(a)
      if lLetzteRate
        if aSubMont[i] < a[i][2]
          loop
        endif
      endif
      if a[i][2] > 0
        if dbAddRec()
          TLG->Match  := a[i][1]
          TLG->IdPar  := cIdPar
          TLG->IdPar2 := cIdPar
          TLG->Date   := dDate
          TLG->Mont   := ntom(aSubMont[i])
          a[i][2] -= aSubMont[i]
          nSubMont -= aSubMont[i]
          nMont2   -= aSubMont[i]
          unlock record
          nCount++
        else
          exit
        endif
      endif
    next i
    **
    ** Jetzt kînnen wir die abbezahlten Forderungen vergessen. Wir
    ** *mÅssen* sie sogar vergessen, weil bei E-Verteilung deren Anzahl
    ** (len(a)) fÅr die Verteilung des Ratenpotentials benutzt wird !
    **
    i := 1
    do while i <= len(a)
      if a[i][2] == 0
        adel(a,i)
        asize(a,len(a)-1)
      else
        i++
      endif
    enddo
    * nMont2 -= nSubMont
  enddo
  dDate := SkipMonth(dDate,nSkipMonth)
enddo
for i := 1 to len(a)
  if dbAddRec()
    TLG->Match  := a[i][1]
    TLG->IdPar  := cIdPar
    TLG->Date   := ctod("31.12.2999")
    TLG->Bemerk := "(nach letzter Rate)"
    unlock record
    nCount++
  else
    exit
  endif
next i
SetMsg(ntrim(nCount) + " EintrÑge wurden erzeugt.")
ddSetUpdated(.t.) // b[AD_UPDATED] := .t.
ddGoBottom(.t.)
ParTlgInit(cIdPar)
RETURN NIL

STATIC FUNCTION ValSubCount(nRaten,nMont,cSubMont)
if nRaten == 0
  SetMsg("Mindestens 1 Rate erforderlich !")
  RETURN .f.
endif
cSubMont := ntom(int(nMont / nRaten) + 1)
RETURN ph_refresh()

STATIC FUNCTION ValSubMont(nSubMont,nMont,nRaten)
if nSubMont == 0
  SetMsg("Ratenbetrag darf doch nicht Null sein, Mensch !")
  RETURN .f.
endif
nRaten := int(nMont / nSubMont) + 1
RETURN ph_refresh()


**
**
**
FUNCTION TlgPreDelete
local lOkay := .f.
local cIdPar := TLG->IdPar
local cMatch := TLG->Match
local cRecOnly    := BUTTON_OFF
local cMatchOnly  := BUTTON_ON
local cEverything := BUTTON_OFF
open window ("Tilgungsplan lîschen") size 5,50
get cRecOnly checkbox
say " nur aktuellen Record"
WinCr()
get cMatchOnly checkbox
say " alle FÑlligkeiten fÅr " + cMatch
WinCr()
get cEverything checkbox
say " gesamter Tilgungsplan"
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
RETURN .t. if cRecOnly == BUTTON_ON
RETURN .f. if ! Confirm( ;
  "Tilgungsplan wird gelîscht !", ;
  MsgSure() ;
)
open area oTlg()
  lOkay := .t.
  softseek cIdPar
  do while ! eof() .and. TLG->IdPar == cIdPar
    if cEverything == BUTTON_ON .or. TLG->Match == cMatch
      if ddRecLock()
        delete
        unlock record
      else
        lOkay := .f.
        exit
      endif
    endif
    skip
  enddo
close area
ParTlgInit(cIdPar)
ddGoTop()
SetMsg("Tilgungsplan wurde gelîscht !")
RETURN .f. // DDDEL_NODELETE

#define TLG_MATCH 1
#define TLG_LIST  2
#define TLG_ALEN  2

#define TLGLIST_DATE 1
#define TLGLIST_MONT 2
#define TLGLIST_ALEN 2

FUNCTION ParTlgInit(cIdPar)
local a
local tlglist
local xlMviFilter := "JnlIdGrj(MVI->IdJnl)=='TRE'"
local i
saTlg := {}
open area oTlg()
  softseek cIdPar
  do while ! eof() .and. TLG->IdPar == cIdPar
    a := NIL
    for i := 1 to len(saTlg)
      if saTlg[i][TLG_MATCH] == TLG->Match
        a := saTlg[i]
        exit
      endif
    next i
    if a == NIL
      a := array(TLG_ALEN)
      a[TLG_MATCH] := trim(TLG->Match)
      a[TLG_LIST]  := {}
      aadd(saTlg,a)
    endif
    skip
  enddo
close area
open area oMvi()
  ddSetOrder(ORD_MVI_PARDATE)
  softseek cIdPar
  do while ! eof() .and. MVI->IdPar == cIdPar
    if &xlMviFilter
      a := NIL
      for i := 1 to len(saTlg)
        if empty(saTlg[i][TLG_MATCH]) .or. MVI->Match == saTlg[i][TLG_MATCH]
          a := saTlg[i]
          exit
        endif
      next i
      if a == NIL
        a := array(TLG_ALEN)
        a[TLG_MATCH] := ""
        a[TLG_LIST]  := {}
        aadd(saTlg,a)
      endif
      tlglist := array(TLGLIST_ALEN)
      tlglist[TLGLIST_DATE] := MVI->Date2
      if MVI->DC == DC_CREDIT
        tlglist[TLGLIST_MONT] := val(MVI->Mont)
      else
        tlglist[TLGLIST_MONT] := - val(MVI->Mont)
      endif
      aadd(a[TLG_LIST],tlglist)
    endif
    skip
  enddo
close area
ddMustScan()
RETURN NIL

**
** TlgSatis() wird in virtuellen Feldern benutzt
**
FUNCTION TlgSatis(cMatch)
local cIdPar := TLG->IdPar
local i
local j
local nSum := 0
local nRecNo := recno()
local dBefore := NIL
local dAfter := NIL
local lNormal := .f.
skip -1
do while ! bof() .and. TLG->IdPar == cIdPar
  if TLG->Match == cMatch .or. empty(cMatch)
    if dBefore == NIL
      dBefore := TLG->Date
      skip -1
    else
      lNormal := .t.
      exit
    endif
  else
    skip -1
  endif
enddo
goto (nRecNo)
skip
do while ! eof() .and. TLG->IdPar == cIdPar
  if TLG->Match == cMatch .or. empty(cMatch)
    dAfter := TLG->Date
    exit
  else
    skip
  endif
enddo
goto (nRecNo)
if dAfter == NIL .and. empty(cMatch)
  RETURN 0
endif
for i := 1 to len(saTlg)
  if saTlg[i][TLG_MATCH] == cMatch
    if dBefore == NIL // es ist der erste Eintrag fÅr diesen Match im Plan
      for j := 1 to len(saTlg[i][TLG_LIST])
        if saTlg[i][TLG_LIST][j][TLGLIST_DATE] < TLG->Date
          nSum += saTlg[i][TLG_LIST][j][TLGLIST_MONT]
        else
          * exit
        endif
      next j
    elseif lNormal
      for j := 1 to len(saTlg[i][TLG_LIST])
        if saTlg[i][TLG_LIST][j][TLGLIST_DATE] > dBefore
          if saTlg[i][TLG_LIST][j][TLGLIST_DATE] <= TLG->Date
            nSum += saTlg[i][TLG_LIST][j][TLGLIST_MONT]
          else
            * exit
          endif
        endif
      next j
    else // es ist der *zweite* Eintrag
      for j := 1 to len(saTlg[i][TLG_LIST])
        if saTlg[i][TLG_LIST][j][TLGLIST_DATE] >= dBefore
          if saTlg[i][TLG_LIST][j][TLGLIST_DATE] <= TLG->Date
            nSum += saTlg[i][TLG_LIST][j][TLGLIST_MONT]
          else
            * exit
          endif
        endif
      next j
    endif
    exit
  endif
next i
RETURN nSum

#endif DEF_TLG

#ifdef DEF_GEN

FUNCTION SwapLng(c1,c2)
RETURN .f. if ! Confirm( ;
  "Language swap " + c1 + "<->" + c2 + " !", MsgSure(), MSG_NO ;
)
RETURN .f. if ! DbfSwapLng(oGen(),"Libell",c1,c2)
#ifdef DEF_ART
  * RETURN .f. if ! DbfSwapLng(oArt(),"Name",c1,c2)
  * RETURN .f. if ! DbfSwapLng(oArt(),"Memo",c1,c2)
#endif DEF_ART
#ifdef DEF_UNT
  RETURN .f. if ! DbfSwapLng(oUnt(),"Name",c1,c2)
#endif DEF_UNT
#ifdef DEF_JNL
  RETURN .f. if ! DbfSwapLng(oJnl(),"DocLib",c1,c2)
  RETURN .f. if ! DbfSwapLng(oJnl(),"DocLib",c1,c2,"N")
#endif DEF_JNL
#ifdef DEF_GRA
  * RETURN .f. if ! DbfSwapLng(oGra(),"Name",c1,c2)
#endif DEF_GRA
RETURN .f. if ! DbfSwapLng(oTpl(),"Memo",c1,c2)
RETURN .f. if ! DbfSwapLng(oIfc(),"Memo",c1,c2)
#ifdef DEF_TAX
  RETURN .f. if ! DbfSwapLng(oTax(),"Memo",c1,c2)
#endif DEF_TAX
Warning("Language Swap : success")
RETURN MnuDone()

#endif DEF_GEN

FUNCTION DbfSwapLng(b,cName,c1,c2,cSuffix)
local lOkay := .t.
default cSuffix to ""
open area b
  go top
  do while ! eof()
    if TaskInter() ; lOkay := .f. ; exit ; endif
    if ddRecLock()
      SwapFields(cName+c1+cSuffix,cName+c2+cSuffix)
      unlock record
    else
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
RETURN lOkay


FUNCTION SwapFields(xf1,xf2)
local u := &("FIELD->"+xf1)
&("FIELD->"+xf1) := &("FIELD->"+xf2)
&("FIELD->"+xf2) := u
RETURN .t.



