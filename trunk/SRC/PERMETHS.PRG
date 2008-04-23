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

**
** STATIC_SECTION global static variables
**
* static scPerActive := NIL

static saPer := NIL

**
** MSG_SECTION    MSGnnn definitions
**
#ifdef LG_FRENCH
  * static MSG_PER_NOT_FOUND := " : p‚riode non ouverte pour le journal "
  static MSG_CHKDATE := " : date hors p‚riode "
  static MSG_NOTLAST := " n'est pas le dernier document du journal !"
  static MsgJnlStart := "Ouverture de journal"
  static MsgDocStart := "Nø du premier document "
  static MsgPerIsClosed := " : journal cl“tur‚ pour la p‚riode "
#endif
#ifdef LG_GERMAN
  static MSG_CHKDATE := " : Datum auáerhalb der Periode "
  static MSG_NOTLAST := " ist nicht das letzte Dokument des Journals !"
  static MsgJnlStart := "Journal beginnen"
  static MsgDocStart := "beginnen mit Dokumentnummer "
  static MsgPerIsClosed := " : Journal abgeschlossen fr Periode "
#endif
#ifdef LG_EN
  static MSG_CHKDATE := " : Date is outside of period "
  static MSG_NOTLAST := " is not the last document of journal !"
  static MsgJnlStart := "Start journal"
  static MsgDocStart := "start with document number "
  static MsgPerIsClosed := " : journal closed for period "
#endif


**
** PROCEDURE_SECTION  - (...grins)
**

FUNCTION MsgDocUntil
RETURN " : Journal ist gesperrt bis Nummer "

#ifdef DEF_JNL

**
** PER - Buchungsperioden
**
FUNCTION oPer()
local b
define data b                                                  ;
  name PER                                                          ;
  create  PerCreate() ;
  predelete  ConfirmDelete()
ddIndex b on  PER->Periode
ddFld Periode ,C,  LEN_PERIODE,0  picture PIC_ID when .f.
ddFld Date1   ,D,  8,0
ddFld Date2   ,D,  8,0
ddFld Name    ,C,  40,0
ddFld IdJnl   ,C, LenIdJnl(),0    when .f.
ddFld Etat    ,C,  1,0  picture PIC_ID
ddEndDef()
RETURN b


**
** DocCreate()
**
FUNCTION DocCreate(jnl,bCreate,cPeriode)
local nReturn := DDCREATE_FAIL
local nSelect := select()
local nPerSelect
local cIdDoc
local cTitle
default cPeriode to PerActive()
open area oJnl()
  seek jnl[JNL_IDJNL]
  if eof()
    SetMsg(jnl[JNL_IDJNL] + MsgJnlExist())
  elseif ddRecLock()
    cIdDoc := JnlNextIdDoc(JNL->SeqType,JNL->IdDoc,cPeriode)
    if empty(JNL->IdDoc) .or. jnl[JNL_SEQTYPE] == SEQTYPE_M
      if jnl[JNL_SEQTYPE] == SEQTYPE_M
        #ifdef LG_GERMAN
          cTitle := "Dokument erstellen"
        #else
          cTitle := "Cr‚er document"
        #endif
      else
        cTitle := MsgJnlStart
      endif
      open window (cTitle) size 4,50 help JNLSTART
      say "Journal " + JNL->IdJnl + " : " + JNL->Libell
      WinCr()
      if jnl[JNL_SEQTYPE] == SEQTYPE_M // JNLATTR_O $ jnl[JNL_ATTRIB]
        #ifdef LG_GERMAN
          say "Dokumentnummer "
        #else
          say "Nø document "
        #endif
      else
        say MsgDocStart
      endif
      get cIdDoc postedit {|x| GetIdDoc(x,jnl)} picture PIC_ID
      nKey := ReadScr()
      close window
      if nKey == K_ESC
        cIdDoc := NIL
      endif
    endif
    if cIdDoc != NIL
      nPerSelect := select()
      select (nSelect)
      nReturn := eval(bCreate,cIdDoc)
      select (nPerSelect)
      if nReturn != DDCREATE_FAIL
        JNL->IdDoc := cIdDoc
        * confirm("Erste Wartepause vor COMMIT JNL->IdDoc="+cIdDoc,MsgContinue())
        dbcommit()
      endif
    endif
    unlock record
    * confirm("Zweite Wartepause nach UNLOCK RECORD",MsgContinue())
  endif
close area
RETURN nReturn

FUNCTION JnlNextIdDoc(cSeqType,cIdDoc,cPeriode)
RETURN NextId(cIdDoc) if cSeqType == SEQTYPE_M
RETURN NextId(cIdDoc) if cSeqType == SEQTYPE_C
RETURN NextId(cIdDoc,y2p(year(PerDate1(cPeriode)))) if cSeqType == SEQTYPE_Y
* also cSeqType ist SEQTYPE_E
* if left(cIdDoc,LEN_YEAR) == left(cPeriode,LEN_YEAR)
RETURN NextId(cIdDoc,left(cPeriode,LEN_YEAR))
* endif
** Neues Rechnungsjahr beginnen:
* RETURN NextId(space(len(cIdDoc)),left(cPeriode,LEN_YEAR))


**
** DocDelete()
**
FUNCTION DocDelete(jnl,cIdDoc,lConfirm)
local lOkay := .f.
local lLast := .t.
RETURN ConfirmDelete() if jnl == NIL
default lConfirm to .t.
open area oJnl()
  seek jnl[JNL_IDJNL]
  if JNL->IdDoc == cIdDoc .or. jnl[JNL_SEQTYPE] == SEQTYPE_M
    lOkay := .t.
  * elseif JNLATTR_G $ jnl[JNL_ATTRIB]
  elseif JnlDoHst(jnl)
    Warning( ;
      jnl[JNL_IDJNL] + " " + cIdDoc + MSG_NOTLAST , ;
      NIL, "WRN016" ;
    )
    lOkay := .f.
  else
    lOkay := Confirm( ;
      jnl[JNL_IDJNL] + " " + cIdDoc + MSG_NOTLAST, ;
      MsgSure(),MSG_NO,"WRN016" ;
    )
    lLast := .f.
  endif
  if lOkay
    if ddRecLock()
      if !lConfirm.or.Confirm( ;
        jnl[JNL_IDJNL] + " " + cIdDoc + MsgDocDelete() , ;
        NIL, MSG_NO,"WRN003" ;
      )
        if lLast
          * 20031017 :
          if jnl[JNL_SEQTYPE] == SEQTYPE_M .or. jnl[JNL_SEQTYPE] == SEQTYPE_C
            JNL->IdDoc := PrevNum(cIdDoc)
            if JNL->IdDoc == repl("0",6)
              JNL->IdDoc := ""
            endif
          else
            JNL->IdDoc := left(cIdDoc,2)+PrevNum(substr(cIdDoc,3))
            if right(JNL->IdDoc,4) == repl("0",4)
              JNL->IdDoc := ""
            endif
          endif
          * JNL->IdDoc := left(cIdDoc,2)+PrevNum(substr(cIdDoc,3))
          * if right(JNL->IdDoc,4) == repl("0",4)
          *   JNL->IdDoc := ""
          * endif
          dbcommit()
        endif
        lOkay := .t.
      else
        lOkay := .f.
      endif
      unlock record
    else
      lOkay := .f.
    endif
  endif
close area
RETURN lOkay


*FUNCTION PerDefault(cIdJnl) // jnl) // ,dDate)
*local cPeriode := NIL
*local a := {}
*open area oPer()
*  softseek cIdJnl // jnl[JNL_IDJNL]
*  do while ! eof() .and. PER->IdJnl == cIdJnl // jnl[JNL_IDJNL]
*    if ! empty(PER->Date1) .and. PER->Date1 <= UserDate()
*      if ! empty(PER->Date2) .and. PER->Date2 >= UserDate()
*        if PER->Etat != PERSTAT_CLOSED
*          aadd(a, PER->Periode + " : " + dtoc(PER->Date1) + "-" + dtoc(PER->Date2))
*        endif
*      endif
*    endif
*    skip
*  enddo
*close area
*if len(a) == 0
*  Warning( ;
*    cIdJnl + " : keine Buchungsperiode aktiv am " + ;
*    dtoc(UserDate()) ;
*  )
*  RETURN NIL
*endif
*RETURN left(a[1],LEN_PERIODE) if len(a) == 1
*browse array a using {|x| x } ;
*             help "PERPICK" ;
*             start (len(a)) ;
*             title ("Buchungsperiode")
*if lastchoice() != 0
*  RETURN left(a[LastChoice()], LEN_PERIODE)
*endif
*RETURN NIL // cPeriode

FUNCTION GetIdDoc(x,jnl)
x := upper(alltrim(x))
RETURN x if len(x) == LEN_IDDOC
RETURN padl(x,LEN_IDDOC,"0") if len(x) + 2 > LEN_IDDOC
RETURN left(PerActive(),2)+padl(x,LEN_IDDOC-2,"0") if jnl == NIL
RETURN padl(x,LEN_IDDOC,"0") if jnl[JNL_SEQTYPE] == SEQTYPE_M ;
                           .or. jnl[JNL_SEQTYPE] == SEQTYPE_C
RETURN left(PerActive(),2)+padl(x,LEN_IDDOC-2,"0") ;
       if jnl[JNL_SEQTYPE] == SEQTYPE_E
RETURN left(y2p(year(PerDate1(PerActive()))),2)+padl(x,LEN_IDDOC-2,"0")

FUNCTION PerIsClosed(cPeriode,cIdJnl)
local lIsClosed := .t.
open area oJnl()
  seek cIdJnl
  if empty(JNL->Periode) .or. cPeriode >= JNL->Periode
    lIsClosed := .f.
  endif
close area
RETURN lIsClosed

FUNCTION PerIsOpen(cPeriode,cIdJnl)
local lIsOpen := .f.
open area oJnl()
  seek cIdJnl
  if cPeriode <= JNL->Periode
    SetMsg(cIdJnl + MsgPerIsClosed + cPeriode,NIL,"WRN032")
  elseif PerExist(cPeriode)
    // S(SetMsg())
  // else
    lIsOpen := .t.
  endif
close area
RETURN lIsOpen

#define PER_PERIODE 1
#define PER_DATE1   2
#define PER_DATE2   3
#define PER_NAME    4
#define PER_ALEN    4


FUNCTION PerExist(cPeriode)
RETURN .t. if PerLocate(cPeriode) != NIL
SetMsg(cPeriode + MsgPerExist())
RETURN .f.

FUNCTION PerRefresh()
local a
saPer := {}
open area oPer()
  go top
  do while ! eof()
    a := array(PER_ALEN)
    a[PER_PERIODE] := PER->Periode
    a[PER_DATE1] := PER->Date1
    a[PER_DATE2] := PER->Date2
    a[PER_NAME] := PER->Name
    aadd(saPer,a)
    skip
  enddo
close area
RETURN NIL

FUNCTION PerLocate(cPeriode)
local i
if saPer == NIL ; PerRefresh() ; endif
for i := 1 to len(saPer)
  RETURN saPer[i] if saPer[i][PER_PERIODE] == cPeriode
next i
RETURN NIL

FUNCTION MsgPerExist
#ifdef LG_GERMAN
RETURN + " : Periode nicht definiert !"
#endif
#ifdef LG_FRENCH
RETURN + " : p‚riode comptable non d‚finie !"
#endif
#ifdef LG_EN
RETURN + " : no such accounting period !"
#endif



FUNCTION PerName(cPeriode)
local per := PerLocate(cPeriode)
RETURN "" if per == NIL
RETURN per[PER_NAME]

FUNCTION PickPer(cStart,cIdJnl,dDate,cIdJnl2)
local i
local a := {}
local nStart
local cPeriode := ""
if saPer == NIL ; PerRefresh() ; endif
if cIdJnl != NIL
  open area oJnl()
    seek cIdJnl
    cPeriode := JNL->Periode //
  close area
endif
if cIdJnl2 != NIL // 2001-03-14 fr TRL->IdJnl2
  open area oJnl()
    seek cIdJnl2
    if JNL->Periode > cPeriode
      cPeriode := JNL->Periode
    endif
  close area
endif
default cStart to PerActive(dDate)
for i := 1 to len(saPer)
  if empty(cPeriode) .or. saPer[i][PER_PERIODE] > cPeriode
    if PerChkDate(saPer[i],dDate,NIL)
      aadd(a, saPer[i])
      if saPer[i][PER_PERIODE] == cStart
        nStart := len(a)
      endif
    endif
  endif
next i
* RETURN a[1] if len(a) == 1
browse array a ;
             using {|per| ;
               per[PER_PERIODE] + " " + ;
               per[PER_NAME] + " " + DevDefault(per[PER_PERIODE]);
             } ;
             title ("Buchungsperiode") ;
             help "PER" ;
             start nStart
RETURN NIL if lastchoice() == 0
RETURN a[lastchoice()][PER_PERIODE]


***
*** PickPer
***
*FUNCTION PickPer(cIdJnl,dDate,cStart)
*local a := {}
*local nStart := 0
** default dDate to UserDate()
*default cStart to PerActive()
*open area oPer()
*  if empty(cIdJnl)
*    go top
*    cIdJnl := PER->IdJnl
*  else
*    softseek cIdJnl
*  endif
*  do while ! eof() .and. PER->IdJnl == cIdJnl
*    if empty(dDate) .or. (PER->Date1 <= dDate .and. PER->Date2 >= dDate)
*      aadd(a, ;
*        PER->Periode + " : " ;
*        + dtoc(PER->Date1) + "-" + dtoc(PER->Date2) ;
*        + " " + PerName() ;
*      )
*      if PER->Periode == cStart
*        nStart := len(a)
*      endif
*    endif
*    skip
*  enddo
*close area
*if len(a) == 0
*  Warning( ;
*    cIdJnl + " : keine Buchungsperiode aktiv am " + ;
*    dtoc(dDate), NIL, "WRN031" ;
*  )
*  RETURN NIL
*elseif len(a) == 1
*  // scPerActive := left(a[1], LEN_PERIODE)
*  RETURN left(a[1], LEN_PERIODE)
*endif
*browse array a using {|x| x } ;
*             start nStart ;
*             help "PERPICK" ;
*             delete .f. ;
*             title ("Buchungsperiode")
*if lastchoice() != 0
*  * scPerActive := left(a[LastChoice()], LEN_PERIODE)
*  RETURN left(a[LastChoice()], LEN_PERIODE)
*endif
*RETURN NIL

**
** 19991220 : pnYear("9913") returns 2000
**
FUNCTION pnYear(cPeriode)
local nYear := val(left(cPeriode,LEN_YEAR))
local nMonat := val(right(cPeriode,2))
if FixY2K()
  if nYear == 0
    // "A0" wird 2000, "A1" wird 2001, "B0" wird 2010, ...
    nYear := (asc(left(cPeriode,1)) - 65) * 10 + val(substr(cPeriode,2,1))
  else
    nYear += 1900
  endif
else
  nYear += 2000
endif
do while nYear < set(_SET_EPOCH)
  nYear += 100
enddo
RETURN nYear if nMonat > 36
do while nMonat > 12
  nMonat -= 12
  nYear++
enddo
RETURN nYear

FUNCTION pnMonth(cPeriode)
local nMonth := val(right(cPeriode,2))
do while nMonth > 12
  nMonth -= 12
enddo
RETURN nMonth

FUNCTION pnQuarter(cPeriode)
local nMonth := pnMonth(cPeriode)
RETURN 1 if nMonth <= 3
RETURN 2 if nMonth <= 6
RETURN 3 if nMonth <= 9
RETURN 4

FUNCTION PerDefaultName(cPeriode)
local c := ""
local nMonth := val(right(cPeriode,2))
if nMonth == 0
  #ifdef LG_GERMAN
    c += "Er”ffnung "
  #endif
  #ifdef LG_FRENCH
    c += "Ouverture ann‚e "
  #endif
  #ifdef LG_EN
    c += "Year opening "
  #endif
  c += ntrim(pnYear(cPeriode))
elseif nMonth == 99
  #ifdef LG_GERMAN
    c += "Abschluss "
  #endif
  #ifdef LG_FRENCH
    c += "Cl“ture "
  #endif
  #ifdef LG_EN
    c += "Year closing "
  #endif
  c += ntrim(pnYear(cPeriode))
else
  do while nMonth > 12
    nMonth -= 12
  enddo
  c += MonthName(nMonth,UsrLang()) + " " + ntrim(pnYear(cPeriode))
* else
*   c += ntrim(nMonth)
*   #ifdef LG_GERMAN
*     c += ". Monat "
*   #else
*     c += "e mois "
*   #endif
*   c += ntrim(pnYear(cPeriode))
endif
RETURN padr(c,30)

FUNCTION MsgPerClosed(cPeriode,dDate,cIdJnl)
RETURN dtoc(dDate) + MSG_CHKDATE + cPeriode + " (" + cIdJnl + ") !"

**
** PerSetDirty()
**
FUNCTION PerSetDirty(jnl,cPeriode,dDate,cIdDoc,lConfirm)
local lOkay := .f.
local cIdJnl := jnl[JNL_IDJNL]
local per := PerLocate(cPeriode)
default lConfirm to .t.
if per == NIL
  RETURN .f. if ! PerAppend(cPeriode)
  PerRefresh()
  if (per := PerLocate(cPeriode)) == NIL
    SetMsg(cPeriode + MsgPerExist())
    RETURN .f.
  endif
endif
#ifdef DEF_IMP
  if ! PerChkDate(per,dDate,NIL)
    SetMsg(MsgPerClosed(cPeriode,dDate,cIdJnl))
    RETURN .f.
  endif
#else
  if ! PerChkDate(per,dDate,jnl)
    if lConfirm
      RETURN .f. if ! Confirm( ;
        MsgPerClosed(cPeriode,dDate,cIdJnl), MsgSure(), " " ;
      )
    endif
  endif
#endif
open area oJnl()
  seek cIdJnl
  if eof()
    SetMsg(cIdJnl + " : Journal nicht gefunden !",NIL,"WRN032")
  elseif JNL->Periode >= cPeriode
    SetMsg( ;
      cIdJnl + MsgPerIsClosed + cPeriode,NIL,"WRN033" ;
    )
  else
    if empty(JNL->IdDocUntil) .or. JNL->IdDocUntil < cIdDoc
      lOkay := .t.
    else
      SetMsg( ;
        cIdJnl + MsgDocUntil() + JNL->IdDocUntil,NIL,"DOCUNTIL" ;
      )
    endif
  endif
close area
RETURN lOkay

FUNCTION PerChkDate(per,dDate,jnl)
RETURN .t. if dDate == NIL
if jnl != NIL
  if JNLATTR_R $ jnl[JNL_ATTRIB]
    dDate := SkipMonth(dDate,-1)
  endif
endif
if ! empty(per[PER_DATE1])
  RETURN .f. if dDate < per[PER_DATE1]
endif
if ! empty(per[PER_DATE2])
  RETURN .f. if dDate > per[PER_DATE2]
endif
RETURN .t.

FUNCTION PerDate1(cPeriode)
local per := PerLocate(cPeriode)
RETURN UserDate() if per == NIL
RETURN per[PER_DATE1]



#ifdef LG_GERMAN
#define MSG_PER_CREATE "Buchungsperiode erstellen"
#define MSG_PERCREA1 "Buchungsbeginn "
#define MSG_PERCREA2 "Buchungsstopp "
#endif
#ifdef LG_FRENCH
#define MSG_PER_CREATE "Cr‚er p‚riode comptable"
#define MSG_PERCREA1 "Date de d‚but "
#define MSG_PERCREA2 "Date de fin "
#endif
#ifdef LG_EN
#define MSG_PER_CREATE "Create accounting period"
#define MSG_PERCREA1 "Start date "
#define MSG_PERCREA2 "End date "
#endif

FUNCTION PerAppend(cPeriode)
local lOkay := .f.
RETURN .f. if ! PrePerAppend(cPeriode)
open area oPer()
  if PerCreate(cPeriode) != DDCREATE_FAIL
    lOkay := .t.
    unlock record
  endif
close area
RETURN lOkay

**
** PerJnlClose()
** Gibt den letzten Monat im Vorjahr zurck, d.h. "9712", bzw. "9718"
** wenn PerShift() = 6 ist
** Standardwert fr
** - "bis einschlieálich Periode" in JnlClose()
** - MemPer2 in FinAuto()
**
FUNCTION PerJnlClose()
local cReturn := space(LEN_PERIODE)
open area oPer()
  KeyGoTop(left(PerActive(),2),"PER->Periode")
  skip -1
  cReturn := left(PER->Periode,2)+str(12+PerShift(),2,0)
close area
RETURN cReturn

**
** Standardwert "Dokument erstellen in Periode " in FinAuto()
**
FUNCTION PerFinAuto()
local cReturn := space(LEN_PERIODE)
open area oPer()
  KeyGoTop(left(PerActive(),2),"PER->Periode")
  skip -1
  cReturn := left(PER->Periode,2)+"99"
close area
RETURN cReturn

**
** PerCreate()
**
FUNCTION PerCreate(cPeriode)
local dDate1
local dDate2
local nReturn := DDCREATE_FAIL
local i
local cName
local nMonat
default cPeriode to NextPeriode(PER->Periode)
nMonat := val(right(cPeriode,2))
if nMonat == 0
  dDate1 := ntod(pnYear(cPeriode),1,1)
  dDate2 := ntod(pnYear(cPeriode)+1,6,30)
elseif nMonat == 99
  dDate1 := ntod(pnYear(cPeriode),12,31)
  dDate2 := ntod(pnYear(cPeriode)+1,6,30)
else
  do while nMonat > 12 // (12 + PerShift())
    nMonat -= 12
  enddo
  dDate1 := ntod(pnYear(cPeriode),nMonat,1)
  dDate2 := SkipMonth(dDate1,1) - 1
endif
cName := PerDefaultName(cPeriode)
open window MSG_PER_CREATE size 6,50 help PERCREA
do while .t.
  WinHome()
  #ifdef LG_GERMAN
    say "Krzel "
  #else
    say "Code "
  #endif
  @ row(), col() get cPeriode picture PIC_ID
  WinCr()
  say MSG_PERCREA1 // "Buchungsbeginn "
  @ row(), col() get dDate1
  WinCr()
  say MSG_PERCREA2 // "Buchungsstopp "
  @ row(), col() get dDate2
  WinCr()
  #ifdef LG_GERMAN
    say "Text"
  #else
    say "Texte"
  #endif
  get cName
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  if ! IsNewId(cPeriode)
    SetMsg(MsgIdExist())
    loop
  endif
  exit
enddo
close window
* seek cPeriode
* RETURN DDCREATE_FAIL if ! eof()
RETURN DDCREATE_FAIL if ! dbAddRec()
PER->Periode := cPeriode
PER->Date1   := dDate1
PER->Date2   := dDate2
PER->Name := cName // PerDefaultName()
RETURN DDCREATE_REFRESH

FUNCTION NextPeriode(cPeriode)
local nYear
local nMonat
RETURN PerActive() if empty(cPeriode)
nYear := pnYear(cPeriode)
nMonat := val(right(cPeriode,2))
if nMonat == 99
  nMonat := 0
  nYear += 1
endif
do while nMonat > 12
  nMonat -= 12
enddo
nMonat += 1
RETURN m2p(nYear,nMonat)
* RETURN PerActive(ntod(nYear,nMonat,1))
// RETURN NextNum(cPeriode) if left(cPeriode,1) <= "9"


**
** PerDelete()
**
*FUNCTION PerDelete()
*local cIdJnl := PER->IdJnl
*local cTous := BUTTON_OFF
*local nRecNo := recno()
*local lGoTop := .f.
*GsbPeriode(PER->Periode)
*open window ("Perioden l”schen") size 4,50 help PERDELE
*SayGetPeriode()
*get cTous checkbox
*say " fr alle Journale l”schen"
*nKey := ReadScr()
*close window
*RETURN DDDEL_FAIL if nKey == K_ESC
*RETURN DDDEL_FAIL if ! Confirm(MsgSure())
*go top
*do while ! eof()
*  if cTous == BUTTON_ON .or. PER->IdJnl == cIdJnl
*    if ChkPeriode(PER->Periode) == 0
*      if PER->Etat != PERSTAT_CLOSED
*        if ddRecLock()
*          if recno() == nRecNo
*            lGoTop := .t.
*          endif
*          delete
*        endif
*      endif
*    endif
*  endif
*  skip
*enddo
*if lGoTop
*  ddGoTop()
*else
*  ddRefreshAll()
*endif
*RETURN DDDEL_FAIL


**
** PerClose()
**
*FUNCTION PerClose(jnl) // ,cPeriode)
*local lOkay := .f.
*local cIdDoc
*MsgDisplay("")
*open area oPer()
*  softseek jnl[JNL_IDJNL] // + cPeriode
*  do while ! eof() .and. PER->IdJnl == jnl[JNL_IDJNL]
*    if ChkPeriode(PER->Periode) == 0
*      if PER->Etat == PERSTAT_OPEN .or. PER->Etat == PERSTAT_DIRTY
*        lOkay := .f.
*        cIdDoc := NIL
*        #ifdef DEF_VEN
*          if jnl[JNL_ALIAS] == "VEN"
*            open area oVen()
*              lOkay := .t.
*              softseek jnl[JNL_IDJNL]
*              do while ! eof() .and. VEN->IdJnl == jnl[JNL_IDJNL]
*                if VEN->Periode == PER->Periode
*                  if cIdDoc == NIL
*                    cIdDoc := VEN->IdDoc
*                  else
*                    cIdDoc := NextNum(cIdDoc)
*                    if VEN->IdDoc != cIdDoc
*                      Warning(MsgIdJnlDoc() + MsgRupture())
*                    endif
*                  endif
*                  if VEN->Etat != DocStatClosed()
*                    Warning(MsgIdJnlDoc() + MsgNotClosed())
*                    lOkay := .f.
*                    exit
*                  endif
*                endif
*                skip
*              enddo
*            close area
*          endif
*        #endif DEF_VEN
*        #ifdef DEF_FIN
*          if jnl[JNL_ALIAS] == "FIN"
*            open area oFin()
*              lOkay := .t.
*              softseek jnl[JNL_IDJNL]
*              do while ! eof() .and. FIN->IdJnl == jnl[JNL_IDJNL]
*                if FIN->Periode == PER->Periode
*                  if cIdDoc == NIL
*                    cIdDoc := FIN->IdDoc
*                  else
*                    cIdDoc := NextNum(cIdDoc)
*                    if FIN->IdDoc != cIdDoc
*                      Warning(MsgIdJnlDoc() + MsgRupture())
*                    endif
*                  endif
*                  if FIN->Etat != DocStatClosed()
*                    Warning(MsgIdJnlDoc() + MsgNotClosed())
*                    lOkay := .f.
*                    exit
*                  endif
*                endif
*                skip
*              enddo
*            close area
*          endif
*        #endif DEF_FIN
*        #ifdef DEF_IMP
*          if jnl[JNL_ALIAS] == "IMP"
*            open area oImp()
*              lOkay := .t.
*              softseek jnl[JNL_IDJNL]
*              do while ! eof() .and. IMP->IdJnl == jnl[JNL_IDJNL]
*                if IMP->Periode == PER->Periode
*                  if IMP->Etat != DocStatClosed()
*                    Warning(MsgIdJnlDoc() + MsgNotClosed())
*                    lOkay := .f.
*                    exit
*                  endif
*                endif
*                skip
*              enddo
*            close area
*          endif
*        #endif DEF_IMP
*        if lOkay
*          if ddRecLock()
*            if Confirm( ;
*              "Periode " + PER->Periode + " fr " + PER->IdJnl + ;
*              " wird definitiv abgeschlossen !", MsgSure(), ;
*              MSG_NO, "PERCLOSE" ;
*            )
*              PER->Etat := PERSTAT_CLOSED
*              unlock record
*            else
*              lOkay := .f.
*            endif
*          endif
*        endif
*      endif
*    endif
*    skip
*  enddo
*close area
*RETURN lOkay

FUNCTION MsgRupture()
#ifdef LG_GERMAN
RETURN " : Sequenzbruch !"
#else
RETURN " : rupture de s‚quence !"
#endif

*FUNCTION PerIsDirty()
*local lIsDirty := .f.
*open area oPer()
*  go top
*  do while ! eof()
*    if ChkPeriode(PER->Periode) == 0
*      if PER->Etat == PERSTAT_DIRTY
*        lIsDirty := .t.
*        exit
*      endif
*    endif
*    skip
*  enddo
*close area
*RETURN lIsDirty

*FUNCTION PerUnDirty()
*open area oPer()
*  go top
*  do while ! eof()
*    if PER->Etat == PERSTAT_DIRTY
*      if ddRecLock()
*        PER->Etat := PERSTAT_OPEN
*      endif
*    endif
*    skip
*  enddo
*close area
*RETURN NIL

**
** JnlClose() - Journale abschlieáen
**
FUNCTION JnlClose(cInclude,cTitle,cPeriode)
if ! IndExist("TIMTEST")
  #ifdef LG_GERMAN
    RETURN .f. if ! Confirm( ;
      "Der letzte Integrit„tstest war unvollst„ndig!",;
      "Trotzdem Journale abschlieáen (J/N)?";
    )
  #endif   
  #ifdef LG_FRENCH
    RETURN .f. if ! Confirm( ;
      "Le dernier test d'int‚grit‚ ‚tait incomplet !", ;
      "Voulez-vous n‚anmoins cl“turer des journaux (O/N) ?" ;
    )
  #endif
  #ifdef LG_EN
    RETURN .f. if ! Confirm( ;
      "The last integrity check was uncomplete !", ;
      "Are you sure you want to close any journals (Y/N) ?" ;
    )
  #endif
endif   
default cInclude to ""
default cPeriode to PerJnlClose() // space(LEN_PERIODE) // PerActive()
default cTitle to MnuItemName()
* default cExclude to ""
* #ifdef LG_GERMAN
*   default cTitle to "Journale abschlieáen"
* #else
*   default cTitle to "Cl“ture des journaux"
* #endif
cInclude := padr(cInclude,200)
* cExclude := padr(cExclude,50)
do while .t.
  open window (cTitle) size 6,54 
  #ifdef LG_GERMAN
    say "Bis einschlieálich Periode  "
  #endif
  #ifdef LG_FRENCH
    say "Jusque (y compris) p‚riode :"
  #endif
  #ifdef LG_EN
    say "Until period :"
  #endif
  get cPeriode picture PIC_ID ;
               pick PickPer(cPeriode) ;
               valid PerExist(cPeriode)
  WinCr()
  #ifdef LG_GERMAN
    say "Ausschlieálich folgende Journale abschlieáen :"
  #endif
  #ifdef LG_FRENCH
    say "Ne cl“turer que les journaux suivants :"
  #endif
  #ifdef LG_EN
    say "Close only the following journals :"
  #endif
  WinCr()
  get cInclude picture "@!@k@s50" pick PickJnlList(cInclude)
  WinCr()
  #ifdef LG_GERMAN
    say "(Leer lassen um alle Journale abzuschlieáen)"
  #endif
  #ifdef LG_FRENCH
    say "(Laisser vide pour cl“turer tous les journaux)"
  #endif
  #ifdef LG_EN
    say "(Leave empty yo close all journals)"
  #endif
   
  * say "Folgende Journale NICHT abschlieáen :"
  * WinCr()
  * get cExclude picture PIC_ID pick PickJnlList(cExclude)
  nKey := ReadScr()
  close window
  RETURN .f. if nKey == K_ESC
  if ! PerExist(cPeriode)
    loop
  endif
  exit
enddo
open area oJnl()
  go top
  do while ! eof()
    if empty(cInclude) .or. JNL->IdJnl $ cInclude
      * if ! JNL->IdJnl $ cExclude
        if JNL->Periode < cPeriode
          if ddRecLock()
            #ifdef LG_GERMAN
            if Confirm( ;
              JNL->IdJnl + " (" + trim(JNL->Libell) + ;
              ") definitiv abschlieáen bis " + cPeriode, ;
              MsgSure() ;
            )
            #endif   
            #ifdef LG_FRENCH
            if Confirm( ;
              "Cl“turer " + JNL->IdJnl + " (" + trim(JNL->Libell) + ;
              ") de maniŠre d‚finitive jusque p‚riode " + cPeriode, ;
              MsgSure() ;
            )
            #endif
            #ifdef LG_EN
            if Confirm( ;
              "Close " + JNL->IdJnl + " (" + trim(JNL->Libell) + ;
              ") definitively until period " + cPeriode, ;
              MsgSure() ;
            )
            #endif
              JNL->Periode := cPeriode
            endif
            unlock record
          endif
        endif
      * endif
    endif
    skip
  enddo
close area
RETURN MnuDone()

FUNCTION PickPerRange(cStart)
local i
local cPeriode := ""
local a := {}
local nStart := 0
local aAction := {}
if saPer == NIL ; PerRefresh() ; endif
aadd(aAction, { K_SPACE, {|p|ptoggle(p)}} )
aadd(aAction, { asc("-"), {|p|pm_begin(p)}} )
aadd(aAction, { asc("+"), {|p|pm_end(p)}} )
GsbPeriode(cStart)
for i := 1 to len(saPer)
  aadd(a, saPer[i])
next i
browse array a ;
             using {|per| isrange(per) + per[PER_PERIODE] + " " + per[PER_NAME] } ;
             title ("Buchungsperiode") ;
             actions aAction ;
             help "PER" ;
             start nStart
RETURN NIL if lastchoice() == 0
RETURN padr(MemPer1,len(cStart)) if MemPer1 == MemPer2
RETURN padr(MemPer1+"-"+MemPer2,len(cStart))

FUNCTION ptoggle(p)
if ChkPeriode(p[PER_PERIODE]) == 0
  if MemPer1 <= p[PER_PERIODE]
    MemPer1 := p[PER_PERIODE]
  else
    MemPer2 := p[PER_PERIODE]
  endif
else
  if MemPer1 <= p[PER_PERIODE]
    MemPer2 := p[PER_PERIODE]
  else
    MemPer1 := p[PER_PERIODE]
  endif
endif
RETURN K_ALT_F5

FUNCTION pm_begin(p)
* if ChkPeriode(p[PER_PERIODE]) <= 0
  MemPer1 := p[PER_PERIODE]
* else
*   MemPer2 := p[PER_PERIODE]
* endif
RETURN K_ALT_F5

FUNCTION pm_end(p)
MemPer2 := p[PER_PERIODE]
RETURN K_ALT_F5


FUNCTION isrange(p)
RETURN BUTTON_ON + " " if ChkPeriode(p[PER_PERIODE]) == 0
RETURN BUTTON_OFF + " "

FUNCTION PerReset
saPer := NIL
RETURN NIL

FUNCTION JnlDocUntil(cIdJnl,cIdDoc)
local lOkay := .f.
RETURN .f. if ! Confirm( ;
  cIdJnl + " sperren bis Dokumentnummer " + cIdDoc + " :", ;
  MsgSure(), MSG_NO, "DOCUNTIL" ;
)
open area oJnl()
  seek cIdJnl
  if ! eof()
    if JNL->IdDocUntil < cIdDoc .or. Confirm( ;
      cIdJnl + " war bisher gesperrt bis Nummer " + JNL->IdDocUntil, ;
      "Sperrung zurcknehmen (J/N) ?", MSG_NO, "DOCUNTIL" ;
    )
      if ddRecLock()
        JNL->IdDocUntil := cIdDoc
        lOkay := .t.
      endif
    endif
  endif
close area
RETURN .t. if lOkay
SetMsg(cIdJnl + " : Sperrung wurde nicht ver„ndert.")
RETURN .f.

*FUNCTION PerStart(cPeriode)
*local i
*local cStart := space(LEN_PERIODE) // ""
*if saPer == NIL ; PerRefresh() ; endif
*for i := 1 to len(saPer)
*  if saPer[i][PER_PERIODE] >= cPeriode
*    RETURN cStart
*  elseif right(saPer[i][PER_PERIODE],2) == "00"
*    cStart := saPer[i][PER_PERIODE]
*  endif
*next i
*RETURN cStart


#endif DEF_JNL

#ifdef DEF_FIN

**
** FinAuto()
**
FUNCTION FinAuto(cIdJnl,cIdGen,lDcInvert,cTitle,cIdGen1,cIdGen2,cNB)
local nDebit  := 0
local nCredit := 0
local aFnl := {}
local fnl
local jnl := JnlLocate(cIdJnl)
local lOkay := .f.
local cIdDoc
local i
local a
static cPeriode := NIL
static dDate    := NIL
RETURN .f. if jnl == NIL
* default cIdGen to space(LenIdGen())
default cIdGen1 to space(LenIdGen())
default cIdGen2 to space(LenIdGen())
default dDate to UserDate()
if cPeriode == NIL
  MemPer2 := PerJnlClose()
  if lDcInvert
    cPeriode := PerFinAuto()
    MemPer1 := left(PerJnlClose(),2) + "01"
  else
    cPeriode := PerStart(PerActive())
    MemPer1 := space(LEN_PERIODE)
  endif
endif
cIdDoc := DbfPeek( ;
  oJnl(), ;
  cIdJnl, ;
  "JnlNextIdDoc(JNL->SeqType,JNL->IdDoc,PerActive())", ;
  "******" ;
)
//    cIdDoc := JnlNextIdDoc(jnl,JNL->IdDoc,cPeriode)
open area oGen()
  lOkay := GenExist(cIdGen)
  // lOkay := GenExist(cIdGenC) .and.GenExist(cIdGenD)
close area
RETURN !Warning(SetMsg()) if !lOkay
open window (cTitle) size 7,50 help "FINAUTO"
SayGetPeriode()
#ifdef LG_GERMAN
  say "Konten von "
#else
  say "Comptes de "
#endif
get cIdGen1 picture PIC_ID pick PickGen(NIL,cIdGen1)
#ifdef LG_GERMAN
  say " bis "
#else
  say " … "
#endif
get cIdGen2 picture PIC_ID pick PickGen(NIL,cIdGen2)
WinCr()
WinCr()
#ifdef LG_GERMAN
  say "Dokument zu erstellen : " + cIdJnl + " " + cIdDoc + " :"
#else
  say "Document … g‚n‚rer : " + cIdJnl + " " + cIdDoc + " :"
#endif
WinCr()
#ifdef LG_GERMAN
  say "Datum "
#else
  say "Date "
#endif
get dDate
say "  Periode "
get cPeriode picture PIC_ID pick PickPer(cPeriode,cIdJnl)
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
RETURN .f. if ! WrnJnlOpen()
RETURN .f. if ! PerSetDirty(jnl,cPeriode,dDate,cIdDoc)
SetDevise(DevDefault(MemPer1))
* SetDecPos(DevDecPos(DevDefault(MemPer1)))
open area oCtg(), oGen()
  softseek trim(cIdGen1)
  do while ! eof() .and. (empty(cIdGen2) .or. CTG->IdGen <= cIdGen2)
    if len(trim(CTG->IdGen)) == LenIdGen()
      if CTG->Periode != PerYear(CTG->Periode)
      * if right(CTG->Periode,1) != CHR_255
        if ! GenCtrExist(CTG->IdGen)
          if CTG->Periode >= PerStart(MemPer1)
            if ChkPeriode(CTG->Periode) == 0
              nDebit  += val(CTG->Debit)
              nCredit += val(CTG->Credit)
              CtgFnlCollect(aFnl,lDcInvert)
            endif
          endif
        endif
      endif
    endif
    skip
  enddo
close area
if len(aFnl) == 0
  #ifdef LG_GERMAN
    Warning("Keine Buchungen zu generieren !")
  #endif
  #ifdef LG_FRENCH
    Warning("Aucune imputation … g‚n‚rer !")
  #endif
  #ifdef LG_EN
    Warning("Nothing to generate !")
  #endif
  RETURN .f.
endif
if abs(nDebit-nCredit)>DevTolerance(DevDefault(MemPer1))
  fnl := array(FNL_ALEN)
  fnl[FNL_MATCH]   := ""
  fnl[FNL_CPTTYPE] := "" // CPTTYPE_GEN
  * fnl[FNL_COMPTE]  := cIdGen
  fnl[FNL_MONTDEV] := ""
  fnl[FNL_IDDEV]   := ""
  fnl[FNL_MONT]    := ""
  fnl[FNL_LIBELL]  := ""
  if nDebit > nCredit
    fnl[FNL_DC]   := DC_CREDIT
    fnl[FNL_MONT] := ntom( nDebit - nCredit )
    fnl[FNL_COMPTE] := cIdGen
  else
    fnl[FNL_DC]   := DC_DEBIT
    fnl[FNL_MONT] := ntom( nCredit - nDebit )
    fnl[FNL_COMPTE] := cIdGen
  endif
  if lDcInvert
    fnl[FNL_DC]   := DcInvert(fnl[FNL_DC])
  endif
  aadd(aFnl, fnl)
* else
*   Warning(SetMsg())
*   RETURN .f.
endif
if DevDefault(cPeriode) != DevDefault(MemPer1)
  RETURN .f. if ! Confirm(;
    "Betr„ge werden konvertiert von " ;
    + DevDefault(MemPer1) ;
    + " nach " ;
    + DevDefault(cPeriode), MsgSure() ;
    )
  SetDevise(DevDefault(cPeriode))
  * SetDecPos(DevDecPos(DevDefault(cPeriode)))
  for i := 1 to len(aFnl)
    fnl := aFnl[i]
    fnl[FNL_MONTDEV] := fnl[FNL_MONT]
    fnl[FNL_IDDEV]   := DevDefault(MemPer1)
    fnl[FNL_MONT] := ntom(Db2Dev( ;
      DevDefault(cPeriode),;
      MemPer1,;
      val(fnl[FNL_MONTDEV];
    )))
  next i
endif
#ifdef LG_GERMAN
  if lDcInvert
    default cNB to "Abschluss " + PerText()
  else
    default cNB to "šbertrag " + PerText()
  endif
#endif
#ifdef LG_FRENCH
  if lDcInvert
    default cNB to "Cl“ture " + PerText()
  else
    default cNB to "Report " + PerText()
  endif
#endif
#ifdef LG_EN
  if lDcInvert
    default cNB to "Closure " + PerText()
  else
    default cNB to "Report " + PerText()
  endif
#endif
RETURN FinGenerate(jnl,dDate,cPeriode,aFnl,cNB,DevDefault(cPeriode))

/********** in Entwicklung

**
** FinParAuto()
**
*FUNCTION FinParAuto(cIdCtr,cIdJnl,cIdGen,lDcInvert,cTitle,cIdPar1,cIdPar2)
*local nDebit  := 0
*local nCredit := 0
*local aFnl := {}
*local fnl
*local jnl := JnlLocate(cIdJnl)
*local lOkay := .f.
*local cIdDoc
*local i
*local a
*static cPeriode := NIL
*static dDate    := NIL
*RETURN .f. if jnl == NIL
*default cIdGen to space(LenIdGen())
*default cIdPar1 to space(LenIdPar())
*default cIdPar2 to space(LenIdPar())
*default dDate to UserDate()
*if cPeriode == NIL
*  cPeriode := PerFinAuto() // PerActive() // PickPer(jnl[JNL_IDJNL],dDate)
*  MemPer2 := PerJnlClose()
*  MemPer1 := left(PerJnlClose(),2) + "01"
*endif
*cIdDoc := DbfPeek(oJnl(),cIdJnl,"NextId(JNL->IdDoc)","******")
*open window (cTitle) size 8,50 help "FINAUTO"
*SayGetPeriode()
*#ifdef LG_GERMAN
*  say "Zentralisierungsart "
*#else
*  say "Type de centralisation "
*#endif
*get cIdCtr picture PIC_ID pick PickCtr(cIdCtr)
*WinCr()
*#ifdef LG_GERMAN
*  say "Konten von "
*#else
*  say "Comptes de "
*#endif
*get cIdPar1 picture PIC_ID pick PickPar(NIL,cIdPar1)
*#ifdef LG_GERMAN
*  say " bis "
*#else
*  say " … "
*#endif
*get cIdPar2 picture PIC_ID pick PickPar(NIL,cIdPar2)
*WinCr()
*WinCr()
*#ifdef LG_GERMAN
*  say "Dokument zu erstellen : " + cIdJnl + " " + cIdDoc + " :"
*#else
*  say "Document … g‚n‚rer : " + cIdJnl + " " + cIdDoc + " :"
*#endif
*WinCr()
*#ifdef LG_GERMAN
*  say "Datum "
*#else
*  say "Date "
*#endif
*get dDate
*say "  Periode "
*get cPeriode picture PIC_ID pick PickPer(cPeriode,cIdJnl)
*nKey := ReadScr()
*close window
*RETURN .f. if nKey == K_ESC
*RETURN .f. if ! WrnJnlOpen()
*RETURN .f. if ! PerSetDirty(jnl,cPeriode,dDate,cIdDoc)
*open area oHst(), oPar()
*  ddSetOrder ORD_HST_PARDATE
*  softseek trim(cIdPar1)
*  do while ! eof() .and. HST->IdPar <= cIdPar2
*    if !empty(HST->IdCtr)
*      if ChkPeriode(HST->Periode) == 0
*        if HST->DC == DC_DEBIT
*          nDebit   += val(HST->Mont)
*        else
*          nCredit  += val(HST->Mont)
*        endif
*        FnlParCollect(cIdCtr,aFnl,lDcInvert,lNoDetail)
*      endif
*    endif
*    skip
*  enddo
*close area
*if len(aFnl) == 0
*  #ifdef LG_GERMAN
*    Warning("Keine Buchungen zu generieren !")
*  #else
*    Warning("Aucune imputation … g‚n‚rer !")
*  #endif
*  RETURN .f.
*endif
*fnl := array(FNL_ALEN)
*fnl[FNL_MATCH]   := ""
*fnl[FNL_CPTTYPE] := "" // CPTTYPE_GEN
*fnl[FNL_COMPTE]  := cIdGen
*fnl[FNL_MONTDEV] := ""
*fnl[FNL_LIBELL]  := ""
*if nDebit > nCredit
*  fnl[FNL_DC]   := DC_CREDIT
*  fnl[FNL_MONT] := ntom( nDebit - nCredit )
*else
*  fnl[FNL_DC]   := DC_DEBIT
*  fnl[FNL_MONT] := ntom( nCredit - nDebit )
*endif
*if lDcInvert
*  fnl[FNL_DC]   := DcInvert(fnl[FNL_DC])
*endif
*aadd(aFnl, fnl)
*RETURN FinGenerate(jnl,dDate,cPeriode,aFnl)
**
*STATIC FUNCTION FnlParCollect(cIdCtr,aFnl,lDcInvert,lNoDetail)
*local nDevDecPos := DevDecPos(PAR->IdDev)
*local fnl := NIL
*local i
*local nDebit
*for i := 1 to len(aFnl)
*  if aFnl[i][FNL_CPTTYPE] == cIdCtr
*    if aFnl[i][FNL_COMPTE] == HST->IdPar
*      if lNoDetail .or. aFnl[i][FNL_MATCH] == HST->Match
*        fnl := aFnl[i]
*      endif
*    endif
*  endif
*next i
*if fnl == NIL
*  fnl := array(FNL_ALEN)
*  fnl[FNL_MATCH]   := HST->Match
*  fnl[FNL_CPTTYPE] := cIdCtr
*  fnl[FNL_COMPTE]  := HST->IdPar
*  fnl[FNL_MONTDEV] := HST->MontDev
*  fnl[FNL_IDDEV] := HST->IdDev
*  fnl[FNL_LIBELL]  := ""
*  fnl[FNL_DC]   := HST->DC
*  fnl[FNL_MONT] := HST->Mont
*  if !empty(PAR->IdDev)
*    fnl[FNL_MONTDEV] := ntom(HstMontDev(PAR->IdDev),DevDecPos(PAR->IdDev))
*  endif
*  if lDcInvert
*    fnl[FNL_DC]   := DcInvert(fnl[FNL_DC])
*  endif
*  aadd(aFnl, fnl)
*else
*  fnl[FNL_MATCH]   := ""
*  if (fnl[FNL_DC] == HST->DC) == lDcInvert
*    nDebit := - val(HST->Mont)
*    nDevDebit := - val(HST->MontDev)
*  else
*    nDebit := val(HST->Mont)
*    nDevDebit := val(HST->MontDev)
*  endif
*  if val(fnl[FNL_MONT]) + nDebit > 0
*    fnl[FNL_MONT]    := ntom(val(fnl[FNL_MONT]) + nDebit)
*    if ! empty(PAR->IdDev)
*      fnl[FNL_MONTDEV] := ntom(val(fnl[FNL_MONTDEV]) + nDevDebit,nDevDecPos)
*    endif
*  else
*    fnl[FNL_DC]   := DcInvert(fnl[FNL_DC])
*    fnl[FNL_MONT] := ntom(- (val(fnl[FNL_MONT]) + nDebit) )
*    if ! empty(PAR->IdDev)
*      fnl[FNL_MONTDEV] := ntom(- (val(fnl[FNL_MONTDEV]) + nDevDebit),nDevDecPos )
*    endif
*  endif
*endif
*RETURN NIL
*
************/

**
**
STATIC FUNCTION FinGenerate(jnl,dDate,cPeriode,aFnl,cNB,cIdDev)
local cLine := NextNum(space(LEN_POS))
local lOkay := .f.
local a
local i
local cIdDoc
local b := oFin()
local nTolerance
default cNB to ""
open area b
  KeyGoBottom( ;
    jnl[JNL_IDJNL] , "FIN->IdJnl" ;
  )
  if eof() .or. FIN->Etat == DocStatClosed()
    if DocCreate( ;
      jnl, ;
      {|cIdDoc| FinCreate(jnl,cIdDoc,cPeriode) }, ;
      cPeriode ;
    ) != DDCREATE_FAIL
      if ddRecLock()
        FIN->Date  := dDate
        if cIdDev == NIL
          lOkay := .t.
        else
          FIN->IdDev := cIdDev
          lOkay := DocDevValidate()
        endif
      endif
    endif
  else
    Warning(MsgPrevDoc() + MsgNotClosed())
  endif
  if lOkay
    lOkay := .f.
    if (a := FinFnlInit(jnl)) == NIL
      Warning(MsgIdJnlDoc() + " : " + SetMsg())
    else
      lOkay := .t.
      cIdDoc := FIN->IdDoc
      FIN->Remarq := cNB
      if len(aFnl) > 0
        FIN->Etat := DocStatNew()
        lOkay := .f.
        nTolerance := DevTolerance(FIN->IdDev)
        open area oFnl()
          for i := 1 to len(aFnl)
            if abs(val(aFnl[i][FNL_MONT])) > nTolerance
              if dbAddRec()
                FNL->IdJnl   := FIN->IdJnl
                FNL->IdDoc   := FIN->IdDoc
                FNL->Line    := cLine
                FNL->IdCpt   := aFnl[i][FNL_COMPTE]
                FNL->Match   := aFnl[i][FNL_MATCH]
                FNL->Mont    := aFnl[i][FNL_MONT]
                FNL->MontDev := aFnl[i][FNL_MONTDEV]
                FNL->IdDev   := aFnl[i][FNL_IDDEV]
                FNL->DC      := aFnl[i][FNL_DC]
                FNL->IdCtr   := aFnl[i][FNL_CPTTYPE]
                FNL->Libell  := aFnl[i][FNL_LIBELL]
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
      ** „hnlich wie FinEdit() :
      SendKey(K_ENTER)
      edit data b ;
        key FIN->IdJnl + FIN->IdDoc ;
        value jnl[JNL_IDJNL] + cIdDoc ;
        create   {||DDCREATE_FAIL} ;
        query ("FIN"+jnl[JNL_IDDBV]) ;
        mode edit  ;
        full ;
        title (jnl[JNL_IDJNL] + " " + cIdDoc)
      FnlRestore(a)
    endif
    unlock record
  endif
close area
RETURN lOkay




STATIC FUNCTION CtgFnlCollect(aFnl,lDcInvert)
local fnl := NIL
local i
local nDebit
RETURN NIL if empty(CTG->Debit).and.empty(CTG->Credit)
for i := 1 to len(aFnl)
  if empty(aFnl[i][FNL_CPTTYPE]) //  == CPTTYPE_GEN
    if aFnl[i][FNL_COMPTE] == CTG->IdGen
      fnl := aFnl[i]
    endif
  endif
next i
if fnl == NIL
  fnl := array(FNL_ALEN)
  fnl[FNL_MATCH]   := ""
  fnl[FNL_CPTTYPE] := "" // CPTTYPE_GEN
  fnl[FNL_COMPTE]  := CTG->IdGen
  fnl[FNL_MONTDEV] := ""
  fnl[FNL_IDDEV] := ""
  fnl[FNL_LIBELL]  := ""
  if val(CTG->Debit) > val(CTG->Credit)
    fnl[FNL_DC]   := DC_DEBIT
    fnl[FNL_MONT] := ntom(val(CTG->Debit) - val(CTG->Credit))
  else
    fnl[FNL_DC]   := DC_CREDIT
    fnl[FNL_MONT] := ntom(val(CTG->Credit) - val(CTG->Debit))
  endif
  if lDcInvert
    fnl[FNL_DC]   := DcInvert(fnl[FNL_DC])
  endif
  aadd(aFnl, fnl)
else
  if lDcInvert
    nDebit := val(CTG->Credit) - val(CTG->Debit)
  else
    nDebit := val(CTG->Debit) - val(CTG->Credit)
  endif
  if fnl[FNL_DC] == DC_DEBIT
    nDebit += val(fnl[FNL_MONT])
  else
    nDebit -= val(fnl[FNL_MONT])
  endif
  if nDebit >= 0
    fnl[FNL_DC]   := DC_DEBIT
    fnl[FNL_MONT] := ntom(nDebit)
  else
    fnl[FNL_DC]   := DC_CREDIT
    fnl[FNL_MONT] := ntom(-nDebit)
  endif
endif
RETURN NIL


#endif DEF_FIN

FUNCTION PerActive(dDate)
default dDate to UserDate()
RETURN m2p(year(dDate),month(dDate))

FUNCTION m2p(nYear,nMonth)
local cPerActive
if nMonth <= PerShift()
  nMonth += 12
  nYear --
endif
if nMonth < 36
  do while nMonth > (12 + PerShift())
    nMonth -= 12
    nYear += 1
  enddo
endif
cPerActive := y2p(nYear)
cPerActive += strtran(str(nMonth,LEN_PERIODE-LEN_YEAR)," ","0")
RETURN cPerActive

FUNCTION y2p(nYear)
local cPerActive
if nYear < 2000
  cPerActive := str(nYear - 1900,LEN_YEAR)
elseif FixY2K()
  cPerActive := str(nYear - 2000,LEN_YEAR)
  cPerActive := strtran(cPerActive," ","0")
  // "00xx" wird "A0xx", "10xx" wird "B0xx" usw...
  cPerActive := chr(asc(left(cPerActive,1)) + 17) + right(cPerActive,LEN_YEAR-1)
else
  cPerActive := padl(ntrim(nYear - 2000),LEN_YEAR,"0")
endif
RETURN cPerActive



#ifdef DEF_HST

*FUNCTION GenInitD(cIdGen,cPeriode)
*local nSolde := 0
*open area oCtg()
*  softseek cIdGen + PerStart(cPeriode)
*  do while ! eof() .and. CTG->IdGen == cIdGen ;
*           .and. ChkPeriode(CTG->Periode) < 0
*    nSolde += val(CTG->Debit)
*    // nSolde -= val(CTG->Credit)
*    skip
*  enddo
*close area
*RETURN nSolde


#endif DEF_HST


