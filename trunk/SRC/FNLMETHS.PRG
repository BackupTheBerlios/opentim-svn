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

#ifdef DEF_FIN

**
** STATIC_SECTION global static variables
**
static snMont    := 0       // neuer Saldo (wenn GrundwÑhrung)
static snMontDev := 0       // neuer Saldo (wenn FremdwÑhrung)
static saJnl     := NIL
static saDev     := NIL
static saFnlDev  := NIL

* static snCours   := NIL
** saMatchList ist die Liste der Matches, die in diesem FIN schon
** enthalten ist. Dadurch wird das Problem gelîst, das auftrat, wenn
** derselbe Kunde mehrere Rechnungen auf einmal bezahlte.
* static saMatchList := {}

**
** MSG_SECTION    MSGnnn definitions
**
#ifdef LG_FRENCH
  #define MSG005 " : ce document ne contient aucun compte lettrable."
  #define MSG007 " : ce document contient plusieurs comptes lettrables"
  static MSG_BLEIBT := "(reste Ö saisir)"
  static MSG_NEUER_SALDO := "(nouveau solde)"
  static LEG_PARSATIS := "[Espace] sÇlectionner [*] invert. [Enter] Continuer [F9] Historique"
  static MSG_FNLPICK := "Propositions "
  static MsgFnlDif := "DiffÇrence de paiement"
#endif
#ifdef LG_GERMAN
  #define MSG005 " : Dokument bewegt keine lettrierbaren Konten."
  #define MSG007 " : Dokument bewegt mehr als ein lettrierbares Konto"
  static MSG_BLEIBT := "(bleibt zu buchen)"
  static MSG_NEUER_SALDO := "(neuer Saldo)"
  static LEG_PARSATIS := "[Leertaste] auswÑhlen [*] Ausw.umkehren [Enter] öbernehmen [F9] Historik"
  static MSG_FNLPICK := "BuchungsvorschlÑge "
  static MsgFnlDif := "Zahlungsdifferenz"
#endif
#ifdef LG_EN
  #define MSG005 " : document doesn't move any matchable accounts."
  #define MSG007 " : document moves more than one matchable account"
  static MSG_BLEIBT := "(to be booked)"
  static MSG_NEUER_SALDO := "(new balance)"
  static LEG_PARSATIS := "[Space] (un)select [*] Invert sel. [Enter] Done [F9] Historic"
  static MSG_FNLPICK := "Booking suggestions "
  static MsgFnlDif := "Paiment difference"
#endif

**
** PROCEDURE_SECTION  - (...grins)
**

FUNCTION FnlSave()
RETURN {     ;
  snMont,    ;
  snMontDev, ;
  saJnl,     ;
  saDev,     ;
  saFnlDev,     ;
  SetDevise();
}

FUNCTION FnlRestore(a)
snMont    := a[1]
snMontDev := a[2]
saJnl     := a[3]
saDev     := a[4]
saFnlDev  := a[5]
SetDevise(a[6])
RETURN NIL

FUNCTION FnlSetPartner(cIdPar)
RETURN .f. if ! ddRecLock()
GsbFnlIdPar(cIdPar)
FnlParValidate()
unlock record
RETURN .t.

* FUNCTION FnlCtrValidate()
* RETURN .t. if empty(FNL->IdCtr)
* RETURN FnlParValidate()

**
** FnlParValidate() - nachdem IdCtr oder IdCpt eingegeben wurden
**
FUNCTION FnlParValidate()
local aFnl
local i
local cIdJnl := FNL->IdJnl
local cIdDoc := FNL->IdDoc
local cIdOp  := FNL->Line
local cIdPar := left(FNL->IdCpt,LenIdPar())
RETURN .t. if empty(cIdPar)
RETURN .f. if ! ParExist(cIdPar)
RETURN .t. if ! PreFnlAppend()
RETURN .t. if FnlAppend(ParFnlCollect(cIdPar,NIL,FNL->Match))
RETURN .t. if ! FnlFirstCheck()
RETURN FnlSetMont()

FUNCTION FnlDevValidate()
if empty(FNL->IdDev)
  RETURN .f. if ! FnlFirstCheck()
endif
if FNL->IdDev == DevDefault(FIN->Periode)
  SetMsg(FNL->IdDev + " ist GrundwÑhrung.")
  FNL->IdDev := ""
endif
RETURN FnlMontValidate()


STATIC FUNCTION SetFnlDev()
if empty(FNL->IdDev)
  saFnlDev := NIL
  RETURN .t.
endif
saFnlDev := DevLocate(FNL->IdDev)
if saFnlDev == NIL
  SetMsg(MsgDevExist())
  RETURN .f.
endif
RETURN .t.


**
** FnlGenValidate() - nachdem IdCtr oder IdCpt eingegeben wurden
**
FUNCTION FnlGenValidate()
local cIdGen := left(FNL->IdCpt,LenIdGen())
RETURN .t. if empty(cIdGen)
RETURN .f. if ! GenExist(cIdGen)
if GENATTR_L $ GEN->Attrib
  RETURN .t. if ! PreFnlAppend()
  RETURN .t. if FnlAppend(GenFnlCollect(cIdGen))
endif
RETURN .t. if ! FnlFirstCheck()
RETURN FnlSetMont()

STATIC FUNCTION FnlAppend(aFnl)
local cIdJnl := FNL->IdJnl
local cIdDoc := FNL->IdDoc
local cIdOp  := FNL->Line
local i
RETURN .f. if len(aFnl) == 0
FNL->Match   := aFnl[1][FNL_MATCH]
FNL->Mont    := aFnl[1][FNL_MONT]
FNL->MontDev := aFnl[1][FNL_MONTDEV]
FNL->IdDev   := aFnl[1][FNL_IDDEV]
FNL->DC      := aFnl[1][FNL_DC]
FNL->IdCtr   := aFnl[1][FNL_CPTTYPE]
FNL->Libell  := aFnl[1][FNL_LIBELL]
#ifdef DEF_ANAFIN
  if HasOption("ANA")
    FNL->IdAna   := aFnl[1][FNL_IDANA]
  endif
#endif DEF_ANAFIN
RETURN .t. if len(aFnl) == 1
FnlAfter()               // [960709]
// ein "append blank" scheint multiple record locks zu lîsen ...
* unlock record
for i := 2 to len(aFnl)
  *** Ñhnlich wie FnlCreate(cIdJnl,cIdDoc) ...
  cIdOp := NextNum(cIdOp)
  if dbAddRec()
    FNL->IdJnl   := cIdJnl
    FNL->IdDoc   := cIdDoc
    FNL->Line    := cIdOp
    FNL->Match   := aFnl[i][FNL_MATCH]
    FNL->Mont    := aFnl[i][FNL_MONT]
    FNL->MontDev := aFnl[i][FNL_MONTDEV]
    FNL->IdDev   := aFnl[i][FNL_IDDEV]
    FNL->DC      := aFnl[i][FNL_DC]
    FNL->IdCtr   := aFnl[i][FNL_CPTTYPE]
    FNL->IdCpt   := aFnl[i][FNL_COMPTE]
    FNL->Libell  := aFnl[i][FNL_LIBELL]
    #ifdef DEF_ANAFIN
      if HasOption("ANA")
        FNL->IdAna   := aFnl[i][FNL_IDANA]
      endif
    #endif DEF_ANAFIN
    FnlAfter()
    unlock record
  else
    exit
  endif
next i
ddGoBottom(.t.)
FnlBefore()
// ein "append blank" scheint multiple record locks zu lîsen ...
// aber dbAddRec() scheinbar nicht (96.01.24)
* RETURN .f. if ! ddRecLock()
* ddRefreshAll()
* goto (nRecNo)
RETURN .t.


**
** FnlCreate()
**
FUNCTION FnlCreate(cIdJnl,cIdDoc)
local cLine   := FNL->Line
local nReturn := DDCREATE_REFRESH
local jnl := JnlLocate(cIdJnl)
local nOrder := indexord()
local lDescend := dbdescend()
RETURN DDCREATE_FAIL if jnl == NIL
RETURN DDCREATE_FAIL if ! FinPreEdit()
ddSetOrder(1)
KeyGoBottom( ;
  cIdJnl + cIdDoc, ;
  "FNL->IdJnl+FNL->IdDoc" ;
)  // derniäre op. de l'extrait en cours
if empty(cLine)
  cLine := NextNum(FNL->Line)
else
  do while .t.
    if FNL->Line >= cLine
      if ddRecLock()
        FNL->Line := NextNum(FNL->Line)
        unlock record
      endif
    else
      exit
    endif
    skip -1
    if bof() .or. FNL->IdDoc != cIdDoc .or. FNL->IdJnl != cIdJnl
      exit
    endif
  enddo
endif
ddSetOrder(nOrder,lDescend)
RETURN DDCREATE_FAIL if ! dbAddRec()
FNL->IdJnl   := cIdJnl
FNL->IdDoc   := cIdDoc
FNL->Line    := cLine
FNL->DC      := jnl[JNL_DC]
FNL->IdCtr   := jnl[JNL_LNCODE]
* unlock record
RETURN nReturn

**
** ParFnlCollect() - Ñhnlich wie GenFnlCollect()
**
FUNCTION ParFnlCollect(cIdPar,cIdHlp,cMatch)
local aFnl := {}
local fnl
local i := 1
local nMont
local nMontDev
local aMatch
local cIdDevDefault := DevDefault(FIN->Periode)
local devDoc := saDev
if devDoc[DEV_IDDEV] == cIdDevDefault
  if ! empty(PAR->IdDev) .and. PAR->IdDev != cIdDevDefault
    devDoc := DevLocate(PAR->IdDev)
  elseif ! empty(saJnl[JNL_IDDEV])
    devDoc := DevLocate(saJnl[JNL_IDDEV])
  endif
endif
if devDoc[DEV_IDDEV] == cIdDevDefault
  devDoc := NIL
endif
aMatch := ParHstTag(cIdPar,cIdHlp,cMatch,devDoc)
for i := 1 to len(aMatch)
  nMont    := aMatch[i][MATCH_MONTD] - aMatch[i][MATCH_MONTC]
  nMontDev := aMatch[i][MATCH_DEVD] - aMatch[i][MATCH_DEVC]
  fnl := array(FNL_ALEN)
  if nMont > 0
    fnl[FNL_DC]   := DC_CREDIT
  else
    fnl[FNL_DC]   := DC_DEBIT
    nMont         := - nMont
    nMontDev      := - nMontDev
  endif
  ** start 2001-03-01
  fnl[FNL_MONT]    := ntom(nMont)
  if devDoc == NIL
    fnl[FNL_MONTDEV] := ""
    fnl[FNL_IDDEV] := ""
  else
    fnl[FNL_MONTDEV] := ntom(nMontDev,devDoc[DEV_DECPOS])
    fnl[FNL_IDDEV] := devDoc[DEV_IDDEV]
  endif
  ** end 2001-03-01
  *if saDev[DEV_IDDEV] == DevDefault(FIN->Periode)
  *  fnl[FNL_MONT]    := ntom(nMont)
  *  if empty(PAR->IdDev) .or. PAR->IdDev == DevDefault(FIN->Periode)
  *    fnl[FNL_MONTDEV] := ""
  *  else
  *    fnl[FNL_MONTDEV] := ntom(nMontDev,DevDecPos(PAR->IdDev))
  *  endif
  *elseif saDev[DEV_IDDEV] == PAR->IdDev
  *  fnl[FNL_MONT]    := ntom(nMont)
  *  fnl[FNL_MONTDEV] := ntom(nMontDev,saDev[DEV_DECPOS])
  *else
  *  ** Beispiel : PAR->IdDev ist leer, und ich habe nach dem GW-Wechsel
  *  ** eine Rechnung in BEF von vor dem GW-Wechsel in ein BEF-Bankjournal
  *  ** Åbernommen
  *  fnl[FNL_MONT]    := ntom(nMont)
  *  fnl[FNL_MONTDEV] := ntom(FinDb2Dev(nMont),saDev[DEV_DECPOS])
  *endif
  fnl[FNL_MATCH]   := aMatch[i][MATCH_MATCH]
  fnl[FNL_CPTTYPE] := aMatch[i][MATCH_IDCTR]
  fnl[FNL_COMPTE]  := cIdPar
  fnl[FNL_LIBELL]  := aMatch[i][MATCH_LIBELL]
  fnl[FNL_IDANA]   := aMatch[i][MATCH_IDANA]
  aadd(aFnl, fnl)
next i
RETURN aFnl


**
** ParHstTag() --
**
FUNCTION ParHstTag(cIdPar,cIdHlp,cMatch,devDoc)
local lFound := .f.
local aActions := {}
local i := 1
local nMont
local nMontDev
local aMatch
local cIdDevDefault := DevDefault(FIN->Periode)
local nTolerance := DevTolerance(cIdDevDefault)
default cIdHlp to "HSTTAG"
MsgDisplay( trim(ParName()) + MsgFnlCollect())
aadd(aActions, { asc("*"), {|| ;
  MatchInvert(aMatch), ;
  MatchMsg(aMatch,cIdDevDefault,devDoc) ;
} } )
aadd(aActions, { K_SPACE , {|m| ;
  m[MATCH_TAGGED] := ! m[MATCH_TAGGED], ;
  MatchMsg(aMatch,cIdDevDefault,devDoc), ;
  K_DOWN ;
} } )
aadd(aActions, { K_F9 , {|| ParHstEdit(cIdPar), K_CTRL_F5 } } )
do while ! AppTerminate()
  aMatch := ParMatchList(cIdPar,cIdDevDefault,devDoc,cMatch)
  i := 1
  do while i <= len(aMatch)
    if abs(aMatch[i][MATCH_MONTD] - aMatch[i][MATCH_MONTC]) > nTolerance // RAP_LIMIT
      i++
    else
      adel(aMatch,i)
      asize(aMatch,len(aMatch) - 1 )
    endif
  enddo
  RETURN {} if len(aMatch) == 0
  // K_CTRL_F5 beendet abrowse(), fÑngt dann aber gleich wieder von
  // vorne an (fÅr den Fall, dass im F9-Fenster Matchs geÑndert wurden)
  browse array aMatch using {|m| MatchLine(m,cIdDevDefault,devDoc) } ;
                      title (MSG_FNLPICK + trim(ParName())) ;
                      legend (LEG_PARSATIS) ;
                      actions aActions ;
                      delete {||.f.} ;
                      exit { K_CTRL_F5 } ;
                      help (cIdHlp)
  RETURN {} if lastchoice() == 0
  if abLastKey() == K_CTRL_F5
    loop
  endif
  for i := 1 to len(aMatch)
    if aMatch[i][MATCH_TAGGED]
      lFound := .t.
      exit
    endif
  next i
  if ! lFound
    aMatch[lastchoice()][MATCH_TAGGED] := .t.
  endif
  exit
enddo
i := 1
do while i <= len(aMatch)
  if aMatch[i][MATCH_TAGGED]
    i++
  else
    adel(aMatch,i)
    asize(aMatch,len(aMatch) - 1 )
  endif
enddo
RETURN aMatch


**
** GenFnlCollect() - Ñhnlich wie ParFnlCollect()
**
FUNCTION GenFnlCollect(cIdGen,cIdHlp)
local lFound := .f.
local aActions := {}
local aFnl := {}
local fnl
local i := 1
local nMont
local nMontDev
local aMatch
local cIdDevDefault := DevDefault(FIN->Periode)
local devDoc := saDev
local nTolerance := DevTolerance(cIdDevDefault)
default cIdHlp to "HSTTAG"
*if devDoc[DEV_IDDEV] == cIdDevDefault
*  if ! empty(GEN->IdDev) .and. GEN->IdDev != cIdDevDefault
*    devDoc := DevLocate(GEN->IdDev)
*  elseif ! empty(saJnl[JNL_IDDEV])
*    devDoc := DevLocate(saJnl[JNL_IDDEV])
*  endif
*endif
if devDoc[DEV_IDDEV] == cIdDevDefault
  devDoc := NIL
endif
MsgDisplay( trim(GenName()) + MsgFnlCollect())
do while ! AppTerminate()
  aMatch := GenMatchList(cIdGen,cIdDevDefault,devDoc,FNL->Match)
  i := 1
  do while i <= len(aMatch)
    if abs(aMatch[i][MATCH_MONTD] - aMatch[i][MATCH_MONTC]) > nTolerance // RAP_LIMIT
      i++
    else
      adel(aMatch,i)
      asize(aMatch,len(aMatch) - 1 )
    endif
  enddo
  RETURN {} if len(aMatch) == 0
  aadd(aActions, { asc("*"), {|| ;
    MatchInvert(aMatch), ;
    MatchMsg(aMatch,cIdDevDefault,devDoc) ;
  } } )
  aadd(aActions, { K_SPACE , {|m| ;
    m[MATCH_TAGGED] := ! m[MATCH_TAGGED], ;
    MatchMsg(aMatch,cIdDevDefault,devDoc), ;
    K_DOWN ;
  } } )
  aadd(aActions, { K_F9 ,    {|| GenHstEdit(cIdGen), K_CTRL_F5 } } )
  browse array aMatch using {|m| MatchLine(m,cIdDevDefault,devDoc) } ;
                      title (MSG_FNLPICK + trim(GenName())) ;
                      legend (LEG_PARSATIS) ;
                      actions aActions ;
                      delete {||.f.} ;
                      exit { K_CTRL_F5 } ;
                      help (cIdHlp)
  RETURN {} if lastchoice() == 0
  if abLastKey() == K_CTRL_F5
    loop
  endif
  for i := 1 to len(aMatch)
    if aMatch[i][MATCH_TAGGED]
      lFound := .t.
      exit
    endif
  next i
  if ! lFound
    aMatch[lastchoice()][MATCH_TAGGED] := .t.
  endif
  exit
enddo
i := 1
do while i <= len(aMatch)
  if aMatch[i][MATCH_TAGGED]
    i++
  else
    adel(aMatch,i)
    asize(aMatch,len(aMatch) - 1 )
  endif
enddo
for i := 1 to len(aMatch)
  nMont    := aMatch[i][MATCH_MONTD] - aMatch[i][MATCH_MONTC]
  nMontDev := aMatch[i][MATCH_DEVD] - aMatch[i][MATCH_DEVC]
  fnl := array(FNL_ALEN)
  if nMont > 0
    fnl[FNL_DC]   := DC_CREDIT
  else
    fnl[FNL_DC]   := DC_DEBIT
    nMont         := - nMont
    nMontDev      := - nMontDev
  endif
  ** start 2001-03-01
  fnl[FNL_MONT]    := ntom(nMont)
  if devDoc == NIL
    fnl[FNL_MONTDEV] := ""
    fnl[FNL_IDDEV] := ""
  else
    fnl[FNL_MONTDEV] := ntom(nMontDev,devDoc[DEV_DECPOS])
    fnl[FNL_IDDEV] := devDoc[DEV_IDDEV]
  endif
  ** end 2001-03-01
*  // 19980604 begin
*  if saDev[DEV_IDDEV] == DevDefault(FIN->Periode)
*    fnl[FNL_MONT]    := ntom(nMont)
*    if empty(GEN->IdDev) .or. GEN->IdDev == DevDefault(FIN->Periode)
*      if empty(saJnl[JNL_IDDEV]).or.saJnl[JNL_IDDEV]==DevDefault(FIN->Periode)
*        fnl[FNL_MONTDEV] := ""
*      else
*        fnl[FNL_MONTDEV] := ntom( ;
*          Db2Dev(saJnl[JNL_IDDEV],FIN->Periode,nMont),;
*          DevDecPos(saJnl[JNL_IDDEV]);
*        )
*      endif
*    else
*      fnl[FNL_MONTDEV] := ntom(nMontDev,DevDecPos(GEN->IdDev))
*    endif
*  elseif saDev[DEV_IDDEV] == GEN->IdDev
*    fnl[FNL_MONT]    := ntom(nMont)
*    fnl[FNL_MONTDEV] := ntom(nMontDev,saDev[DEV_DECPOS])
*  else
*    fnl[FNL_MONT]    := ntom(nMont)
*    fnl[FNL_MONTDEV] := ntom(FinDb2Dev(nMont),saDev[DEV_DECPOS])
*    * fnl[FNL_MONTDEV] := ntom(nMont / snCours,saDev[DEV_DECPOS])
*  endif
*  // before 19980604 :
  * if saDev[DEV_IDDEV] == DevDefault(FIN->Periode)
  *   fnl[FNL_MONT]    := ntom(nMont)
  *   fnl[FNL_MONTDEV] := ""
  * else
  *   fnl[FNL_MONT]    := ntom(nMont)
  *   fnl[FNL_MONTDEV] := ntom(nMontDev,saDev[DEV_DECPOS])
  * endif
  // 19980604 end
  fnl[FNL_MATCH]   := aMatch[i][MATCH_MATCH]
  fnl[FNL_CPTTYPE] := aMatch[i][MATCH_IDCTR]
  fnl[FNL_COMPTE]  := cIdGen
  fnl[FNL_IDANA]   := aMatch[i][MATCH_IDANA]
  fnl[FNL_LIBELL]  := aMatch[i][MATCH_LIBELL]
  aadd(aFnl, fnl)
next i
RETURN aFnl


FUNCTION FnlDevPreEdit()
RETURN .f. if saDev == NIL
RETURN .f. if FIN->Etat == DocStatClosed()
RETURN .f. if FIN->IdDev != DevDefault(FIN->Periode)
RETURN .t.

FUNCTION MsgFnlCollect()
#ifdef LG_GERMAN
  RETURN " : BuchungsvorschlÑge ermitteln..."
#else
  RETURN " : rechercher propositions d'imputation..."
#endif


FUNCTION MatchLine(m,cIdDevDefault,devDoc)
local cLine := if(m[MATCH_TAGGED],BUTTON_ON,BUTTON_OFF)
cLine += " " + m[MATCH_MATCH]
cLine += " " + dtoc(m[MATCH_DATE])
#ifdef DEF_ANAFIN
  * if ! empty(m[MATCH_IDANA])
  *   cLine += padr(m[MATCH_IDANA] + " " + AnaName(m[MATCH_IDANA]),20)
  * endif
#endif DEF_ANAFIN
cLine += " " + padr(m[MATCH_LIBELL],20)
cLine += " " + ntom( ;
  m[MATCH_MONTD] - m[MATCH_MONTC] ;
)
cLine += " " + cIdDevDefault
if devDoc != NIL
* if saDev[DEV_IDDEV] != cIdDevDefault
  cLine += " " + ntom( ;
    m[MATCH_DEVD] - m[MATCH_DEVC], devDoc[DEV_DECPOS] ;
  )
  cLine += " " + devDoc[DEV_IDDEV]
endif
RETURN cLine

FUNCTION MatchMsg(aMatch,cIdDevDefault,devDoc)
local i
local nMont    := 0
local nMontDev := 0
local cMsg
for i := 1 to len(aMatch)
  if aMatch[i][MATCH_TAGGED]
    nMont += aMatch[i][MATCH_MONTD]
    nMont -= aMatch[i][MATCH_MONTC]
    nMontDev += aMatch[i][MATCH_DEVD]
    nMontDev -= aMatch[i][MATCH_DEVC]
  endif
next i
#ifdef LG_GERMAN
  cMsg := "Markiert : "
#else
  cMsg := "SÇlectionnÇ : "
#endif
cMsg += cIdDevDefault + " " + ltrim(ntomf(nMont))
if devDoc != NIL // nMontDev != 0
  cMsg += " ; " + devDoc[DEV_IDDEV]
  cMsg += " " + ltrim(ntomf(nMontDev,devDoc[DEV_DECPOS]))
endif
SetMsg(cMsg)
RETURN K_ALT_F5

FUNCTION MatchInvert(aMatch)
local i
for i := 1 to len(aMatch)
  aMatch[i][MATCH_TAGGED] := ! aMatch[i][MATCH_TAGGED]
next i
RETURN K_ALT_F5


**
** ParMatchList() --- Ñhnlich wie GenMatchList()
**
FUNCTION ParMatchList(cIdPar,cIdDevDefault,devDoc,cMatch)
local aMatch := {}
local xlTagged
if ! empty(cMatch)
  xlTagged := "HST->Match=='" + cMatch + "'"
elseif TIMATTR_A $ MemAttrib
  xlTagged := ".t."
else
  xlTagged := ".f."
endif
open area oHst(), oFin(), oVen(), oGen(), oPar()
  ddSetOrder(ORD_HST_PARDATE)
  softseek cIdPar
  do while ! eof() .and. HST->IdPar == cIdPar
    if TaskInter()
      aMatch := {}
      exit
    endif
    if HST->Satis == " "
      HstAddMatch(aMatch,cIdDevDefault,devDoc,xlTagged)
    endif
    skip
  enddo
close area
RETURN aMatch


**
** GenMatchList() --- Ñhnlich wie ParMatchList()
**
FUNCTION GenMatchList(cIdGen,cIdDevDefault,devDoc,cMatch)
local aMatch := {}
local xlTagged
if ! empty(cMatch)
  xlTagged := "HST->Match=='" + cMatch + "'"
elseif TIMATTR_A $ MemAttrib
  xlTagged := ".t."
else
  xlTagged := ".f."
endif
open area oHst(), oFin(), oVen(), oGen(), oPar()
  ddSetOrder(ORD_HST_GENDATE)
  softseek cIdGen
  do while ! eof() .and. HST->IdGen == cIdGen
    if TaskInter()
      aMatch := {}
      exit
    endif
    if HST->Satis == " "
      HstAddMatch(aMatch,cIdDevDefault,devDoc,xlTagged)
    endif
    skip
  enddo
close area
RETURN aMatch

**
** HstAddMatch()
** cIdDevDefault : die GrundwÑhrung, die mich interessiert
** devDoc    : die FremdwÑhrung, die mich interessiert
**             NIL hei·t : ist mir egal
STATIC FUNCTION HstAddMatch(aMatch,cIdDevDefault,devDoc,xlTagged)
local i
local m
local cIdAna := ""
local nMont := HstMont(cIdDevDefault) // val(HST->Mont)
local nMontDev := 0
local doc := DocInfo(HST->IdJnl,HST->IdDoc,HST->Line)
if doc == NIL // das darf nicht sein !
  Warning("HstAddMatch() : DocInfo() failed.", SetMsg())
  RETURN NIL
endif
* #ifdef DEF_CTRATTR
*   RETURN NIL if ! CTRATTR_L $ CtrAttrib(HST->IdCtr)
* #endif
if devDoc != NIL
  nMontDev := HstMont(devDoc[DEV_IDDEV])
endif
for i := 1 to len(aMatch)
  if aMatch[i][MATCH_MATCH] == HstMatch() // HST->Match
    if aMatch[i][MATCH_IDCTR] == HST->IdCtr
      * if aMatch[i][MATCH_IDANA] == cIdAna
        if ! empty(trim(doc[DOC_LIBELL])) // [971015]
          if ! trim(doc[DOC_LIBELL]) $ aMatch[i][MATCH_LIBELL]
            aMatch[i][MATCH_LIBELL] += "; " + trim(doc[DOC_LIBELL])
          endif
        endif
        if HST->DC == DC_DEBIT
          aMatch[i][MATCH_MONTD]  += nMont
          aMatch[i][MATCH_DEVD]   += nMontDev
        else
          aMatch[i][MATCH_MONTC]  += nMont
          aMatch[i][MATCH_DEVC]   += nMontDev
        endif
        RETURN NIL
      * endif
    endif
  endif
next i
m := array(MATCH_ALEN)
m[MATCH_MATCH]   := HstMatch() // HST->Match
m[MATCH_DATE]    := HST->Date
m[MATCH_IDCTR]   := HST->IdCtr
m[MATCH_LIBELL]  := trim(doc[DOC_LIBELL])
m[MATCH_IDANA]   := doc[DOC_IDANA]
m[MATCH_TAGGED]  := &xlTagged
if HST->DC == DC_DEBIT
  m[MATCH_MONTD]    := nMont
  m[MATCH_DEVD]     := nMontDev
  m[MATCH_MONTC]    := 0
  m[MATCH_DEVC] := 0
else
  m[MATCH_MONTC]    := nMont
  m[MATCH_DEVC]     := nMontDev
  m[MATCH_MONTD]    := 0
  m[MATCH_DEVD] := 0
endif
aadd(aMatch,m)
RETURN NIL


**
** MvtAddMatch()
**
*FUNCTION MvtAddMatch(aMatch)
*local i
*local m
*local doc := DocInfo(MVT->IdJnl,MVT->IdDoc,MVT->Line)
*for i := 1 to len(aMatch)
*  if aMatch[i][MATCH_MATCH] == MVT->Match
*    * if aMatch[i][MATCH_IDCTR] == MVT->IdCtr
*      if aMatch[i][MATCH_LIBELL] != trim(doc[DOC_LIBELL])
*        aMatch[i][MATCH_LIBELL] += "; " + trim(doc[DOC_LIBELL])
*      endif
*      if MVT->DC == DC_DEBIT
*        aMatch[i][MATCH_MONTD]    += val(MVT->Mont)
*      else
*        aMatch[i][MATCH_MONTC]    += val(MVT->Mont)
*      endif
*      RETURN NIL
*    * endif
*  endif
*next i
*m := array(MATCH_ALEN)
*m[MATCH_MATCH]   := MVT->Match
*m[MATCH_DATE]    := MVT->Date
*m[MATCH_IDCTR]   := CPTTYPE_GEN
*m[MATCH_LIBELL]  := trim(doc[DOC_LIBELL])
*m[MATCH_TAGGED]  := (TIMATTR_A $ MemAttrib)
*if MVT->DC == DC_DEBIT
*  m[MATCH_MONTD]    := val(MVT->Mont)
*  m[MATCH_DEVD] := 0
*  m[MATCH_MONTC]    := 0
*  m[MATCH_DEVC] := 0
*else
*  m[MATCH_MONTC]    := val(MVT->Mont)
*  m[MATCH_DEVC] := 0
*  m[MATCH_MONTD]    := 0
*  m[MATCH_DEVD] := 0
*endif
*aadd(aMatch,m)
*RETURN NIL



*FUNCTION DocIdDev(cIdJnl,cIdDoc)
*local cIdDev
*#ifdef DEF_VEN
*  if JnlAlias(cIdJnl) == "VEN"
*    open area oVen()
*      cIdDev := EvalVen(cIdJnl,cIdDoc,{||VEN->IdDev})
*    close area
*    RETURN cIdDev
*  endif
*#endif DEF_VEN
*cIdDev := JnlIdDev(cIdJnl)
*RETURN cIdDev


**
** FnlPostEdit()
**
FUNCTION FnlPostEdit()
local ctr
local jnl
if empty(FNL->IdCtr) //  == CPTTYPE_GEN
  RETURN .f. if ! GenExist(left(FNL->IdCpt,LenIdGen()))
  if GenCtrExist(GEN->IdGen)
    RETURN .f. if ! OnGenCtrExist(GEN->IdGen,FIN->Periode,FIN->IdJnl)
  endif
  if GenJnlExist(GEN->IdGen)
    RETURN .f. if ! OnGenJnlExist(GEN->IdGen,FIN->Periode,FIN->IdJnl)
  endif
else
  RETURN .f. if ! ParExist(left(FNL->IdCpt,LenIdPar()))
  if (ctr := CtrLocate(FNL->IdCtr)) == NIL
    SetMsg(FNL->IdCtr+MsgCtrExist())
    RETURN .f.
  endif
  #ifdef DEF_ANAFIN
    RETURN .f. if ! GenExist(ctr[CTR_IDGEN])
  #endif DEF_ANAFIN
endif
#ifdef DEF_ANAFIN
  if GENATTR_Y $ GEN->Attrib .and. empty(FNL->IdAna)
    FNL->IdAna := GEN->IdAna
  endif
  RETURN .f. if (jnl := JnlLocate(FNL->IdJnl)) == NIL
  RETURN .f. if ! JnlAnaCheck(jnl,FnlIdAna())
#endif DEF_ANAFIN
RETURN .t.

#ifdef DEF_ANA

FUNCTION JnlAnaCheck(jnl,cIdAna)
if empty(cIdAna)
  if JNLATTR_Y $ jnl[JNL_ATTRIB] .and. GENATTR_Y $ GEN->Attrib
    SetMsg(GEN->IdGen + " : Analysekonto angeben !")
    RETURN .f.
  endif
else
  if ! GENATTR_Y $ GEN->Attrib
    SetMsg(GEN->IdGen + " : kein Analysekonto angeben !")
    RETURN .f.
  endif
  if ! JNLATTR_Y $ jnl[JNL_ATTRIB]
    SetMsg(jnl[JNL_IDJNL] + " : kein Analysekonto angeben !")
    RETURN .f.
  endif
  RETURN .f. if ! AnaExist(cIdAna)
endif
RETURN .t.

#endif DEF_ANA


**
** FnlSetMont() setzt FNL->Mont und FNL->MontDev falls leer
**
FUNCTION FnlSetMont()
local nMont     // der Betrag, der zu setzen ist
local nMontDev  // der Betrag FremdwÑhrung, der zu setzen ist
// local nDevDecPos := saDev[DEV_DECPOS]
RETURN .t. if ! empty(FNL->Mont)
RETURN .t. if ! empty(saJnl[JNL_IDGEN])

// das Folgende gilt also nur in OPD :

if FIN->IdDev == DevDefault(FIN->Periode)
  nMont := snMont
  if saFnlDev != NIL
    nMontDev := Db2Dev(saFnlDev[DEV_IDDEV],FIN->Periode,nMont)
  endif
else
  nMontDev := snMontDev
  // if saFnlDev != NIL : kann nicht sein
  if saFnlDev[DEV_IDDEV] == FIN->IdDev
    nMont := FinDev2Db(nMontDev)
  else
    nMont := Dev2Db(saFnlDev[DEV_IDDEV],FIN->Periode,nMontDev)
  endif
endif

*if saDev[DEV_IDDEV] == DevDefault(FIN->Periode)
*  nMont    := snMont
*  if empty(saJnl[JNL_IDDEV]).or.saJnl[JNL_IDDEV] == saDev[DEV_IDDEV]
*    nMontDev := 0
*  else
*    nMontDev := Db2Dev(saJnl[JNL_IDDEV],FIN->Periode,nMont)
*    nDevDecPos := DevDecPos(saJnl[JNL_IDDEV])
*  endif
*else
*  nMontDev := snMont
*  nMont := FinDev2Db(nMontDev)
*endif

if nMont < 0
  FNL->DC   := DcInvert(saJnl[JNL_DC])
  nMont     := - nMont
  if saFnlDev != NIL
    nMontDev  := - nMontDev
  endif
else
  FNL->DC   := saJnl[JNL_DC]
endif
FNL->Mont := ntom0(nMont)
if saFnlDev != NIL
  FNL->MontDev := ntom0(nMontDev,saFnlDev[DEV_DECPOS])
else
  FNL->MontDev := ""
endif
RETURN .t.

**
** GEN und PAR mÅssen bereits positioniert sein !
*FUNCTION FnlIdDev()
*RETURN cIdDev

*FUNCTION FnlDecPos
*RETURN saDev[DEV_DECPOS] if saDev[DEV_IDDEV] != DevDefault(FIN->Periode)
*if empty(FNL->IdCtr) // CPTTYPE_GEN
*  if GenExist(left(FNL->IdCpt,LenIdGen())) .and. !empty(GEN->IdDev)
*    RETURN DevDecPos(GEN->IdDev)
*  endif
*else
*  if ParExist(left(FNL->IdCpt,LenIdPar())) .and. !empty(PAR->IdDev)
*    RETURN DevDecPos(PAR->IdDev)
*  endif
*endif
*RETURN DevDecPos(DevDefault(FIN->Periode))


FUNCTION GsbFnlMont(cDC,x)
local nMont
if x == NIL
  if eof() // recno() == lastrec() + 1
    RETURN space(LenMont()) if FIN->IdDev != DevDefault(FIN->Periode)
    if empty(FIN->Mont2) .and. JNLATTR_S $ saJnl[JNL_ATTRIB]
      nMont := snMont  // neuer Saldo
    else
      nMont := val(FIN->Mont2) - snMont // msg_bleibt
    endif
    RETURN space(LenMont()) if abs(snMont) < Tolerance(saDev[DEV_DECPOS])
    if nMont < 0
      RETURN space(LenMont()) if saJnl[JNL_DC] != cDC
    else
      RETURN space(LenMont()) if saJnl[JNL_DC] == cDC
    endif
    RETURN ntom(abs(nMont))
  endif
  RETURN space(LenMont()) if FNL->DC != cDC
  RETURN FNL->Mont
endif
FNL->DC := cDC
FNL->Mont := x
RETURN NIL


FUNCTION GsbFnlDev(cDC,x)
local nMont
if x == NIL
  if eof() // 20070801 recno() == lastrec() + 1
    RETURN space(LenMont()) if FIN->IdDev == DevDefault(FIN->Periode)
    if empty(FIN->Mont2) .and. JNLATTR_S $ saJnl[JNL_ATTRIB]
      nMont := snMontDev      // neuer Saldo
    else
      nMont := val(FIN->Mont2) - snMontDev     // msg_bleibt
    endif
    RETURN space(LenMont()) if abs(nMont) < Tolerance(saDev[DEV_DECPOS])
    if nMont < 0
      RETURN space(LenMont()) if saJnl[JNL_DC] != cDC
    else
      RETURN space(LenMont()) if saJnl[JNL_DC] == cDC
    endif
    RETURN ntom(abs(nMont),saDev[DEV_DECPOS])
  endif
  RETURN space(LenMont()) if FNL->DC != cDC
  RETURN FNL->MontDev
endif
FNL->DC := cDC
FNL->MontDev := x
RETURN NIL




FUNCTION GsbFnlLibell(x)
if x != NIL
  FNL->Libell := x
  RETURN NIL
endif
if eof() // 20070801 recno() == lastrec() + 1
  * if saJnl[JNL_IDDEV] == DevDefault(FIN->Periode)
  if FIN->IdDev == DevDefault(FIN->Periode)
    if abs(snMont-val(FIN->Mont2)) < Tolerance(saDev[DEV_DECPOS])
      RETURN space(LenFnlName())
    endif
  else
    if abs(snMontDev-val(FIN->Mont2)) < Tolerance(saDev[DEV_DECPOS])
      RETURN space(LenFnlName())
    endif
  endif
  if JNLATTR_S $ saJnl[JNL_ATTRIB]  // Kassen- oder Bankjournal
    RETURN padr(MSG_NEUER_SALDO,LenFnlName()) if empty(FIN->Mont2)
    RETURN padr(MSG_BLEIBT,LenFnlName())
  elseif empty(saJnl[JNL_IDGEN]) // OD-Journal
    RETURN padr(MSG_BLEIBT,LenFnlName())
  endif
  RETURN padr("(Total)",LenFnlName()) // z.B. Zahlungsauftrag
endif
if empty(FNL->IdCtr)
  RETURN padr(trim1(FNL->Libell) + GenName(left(FNL->IdCpt,LenIdGen())),LenFnlName())
endif
RETURN padr(trim1(FNL->Libell) + ParName(left(FNL->IdCpt,LenIdPar())),LenFnlName())

FUNCTION GsbFnlIdPar(x)
if x == NIL
  RETURN space(LenIdPar()) if empty(FNL->IdCtr)
  RETURN left(FNL->IdCpt,LenIdPar())
endif
* 20021028 FNL->IdCpt := GetPad(x,"0")
FNL->IdCpt := GetIdPar(x)
FNL->IdCtr := JnlIdCtr(FNL->IdJnl)
if empty(FNL->IdCtr)
  if ParExist(left(FNL->IdCpt,LenIdPar()))
    FNL->IdCtr := PrtIdCtr(PAR->IdPrt)
  else
    FNL->IdCtr := "?"
  endif
endif
RETURN NIL

FUNCTION GsbFnlIdGen(x)
if x == NIL
  RETURN padr(FNL->IdCpt,LenIdGen()) if empty(FNL->IdCtr)
  RETURN space(LenIdGen())
endif
FNL->IdCtr := ""
FNL->IdCpt := GetIdGen(x)
RETURN NIL

**
** FnlMatchValidate()
**
FUNCTION FnlMatchValidate()
local jnl
local a := {}
RETURN .t. if empty(FNL->Match)
#ifdef DEF_CVM
  ** 960708 : rien que pour Thierry
  if len(trim(FNL->Match)) != len(FNL->Match)
    FNL->Match := CvmExec(FNL->Match)
  endif
#endif DEF_CVM
#ifdef DEF_HST
  if empty(FNL->IdCpt)
    open area oHst(), oGen()
      ddSetOrder(ORD_HST_DOC)
      softseek FNL->Match
      do while ! eof() .and. HST->IdJnl + HST->IdDoc == FNL->Match
        if ! empty(HST->IdCtr) .or. ( ;
          GenExist(HST->IdGen) .and. GENATTR_L $ GEN->Attrib ;
        )
          DictAddItem(a,HST->IdCtr+HST->IdPar+HST->IdGen)
        endif
        skip
      enddo
    close area
    if len(a) == 0
      SetMsg(FNL->Match + MSG005 )
      RETURN .t.
    elseif len(a) > 1
      Warning(FNL->Match + MSG007)
      RETURN .t.
    else
      FNL->IdCtr := left(a[1],LenIdCtr())
      if empty(FNL->IdCtr)
        FNL->IdCpt := right(a[1],LenIdGen())
      else
        FNL->IdCpt := substr(a[1],LenIdCtr()+1,LenIdPar())
      endif
      FNL->MontDev := ""
      FNL->IdDev := ""
      FNL->Mont := ""
      if empty(FNL->IdCtr)
        RETURN FnlGenValidate()
      else
        RETURN FnlParValidate()
      endif
    endif
  endif
#endif DEF_HST
RETURN .t. if ! FnlFirstCheck()
RETURN FnlDifCheck()



#ifdef DEF_CVM

FUNCTION CvmExec(cMatch)
local i
static a
default a to ReadArray("CVM.DBC",2)
for i := 1 to len(a)
  if a[i][1] == left(cMatch,1)
    cMatch := trim(substr(cMatch,2))
    cMatch := padl(cMatch,LenIdJnl()+LenIdDoc()-len(a[i][2]),"0")
    RETURN a[i][2] + cMatch
  endif
next i
RETURN cMatch

#endif DEF_CVM


**
** FnlMontValidate()
**
FUNCTION FnlMontValidate
local nMont
local nMontDev
// 20010411 RETURN .t. if ! FnlFirstCheck()
RETURN .f. if ! SetFnlDev()
RETURN .t. if ! FnlSetMont() // falls FNL->MontDev geleert wurde
nMont := val(FNL->Mont)
if saFnlDev == NIL
  FNL->MontDev := ""
else
  FNL->Mont := ntom0( nMont )
  if saFnlDev[DEV_IDDEV] == FIN->IdDev
    nMontDev := FinDb2Dev(nMont)
  else
    nMontDev := Db2Dev(saFnlDev[DEV_IDDEV],FIN->Periode,nMont)
  endif
  FNL->MontDev := ntom(nMontDev,saFnlDev[DEV_DECPOS])
*  if FIN->IdDev != DevDefault(FIN->Periode)
*    FNL->MontDev := ntom0( FinDb2Dev(nMont), saFnlDev[DEV_DECPOS] )
*  else
*    FNL->MontDev := ntom0( ;
*      Db2Dev(saFnlDev[DEV_IDDEV],FIN->Periode,nMont), ;
*      saFnlDev[DEV_DECPOS] ;
*    )
*  endif
endif
RETURN FnlDifCheck()

**
** FnlMDValidate()
**
FUNCTION FnlMDValidate
local nMontDev
local cMont
RETURN .f. if ! SetFnlDev()   // 20010807
// RETURN .f. if ! FnlFirstCheck()
RETURN .t. if ! FnlSetMont() // falls FNL->MontDev geleert wurde
if saFnlDev == NIL
  FNL->MontDev := ""
else
  nMontDev := val(FNL->MontDev)
  FNL->MontDev := ntom0( nMontDev, saFnlDev[DEV_DECPOS] )
  if FIN->IdDev == saFnlDev[DEV_IDDEV]
    cMont := ntom0( FinDev2Db(nMontDev) )
  else
    cMont := ntom0( Dev2Db(saFnlDev[DEV_IDDEV],FIN->Periode,nMontDev) )
  endif
  if FNL->Mont != cMont
    if empty(FNL->Mont).or.Confirm(MsgSetMont(SetDevise()))
      FNL->Mont := cMont
    endif
  endif
endif
RETURN FnlDifCheck()


* **
* ** FnlMontValidate() -- Benutzer hat manuell FNL->Mont verÑndert
* **
* FUNCTION FnlMontValidate
* local nMontDev := 0
* local dev
* RETURN .t. if ! FnlFirstCheck()
* RETURN .f. if ! FnlSetMont() // (ggf. fÅllen falls leer)
* if saDev[DEV_IDDEV] == DevDefault(FIN->Periode)
*   if empty(FNL->IdCtr) // Generalkonto
*     if GenExist(left(FNL->IdCpt,LenIdGen()))
*       if empty(GEN->IdDev) .or. GEN->IdDev == DevDefault(FIN->Periode)
*         if empty(saJnl[JNL_IDDEV]) ;
*           .or. saJnl[JNL_IDDEV] == DevDefault(FIN->Periode)
*           FNL->MontDev := ""
*         else
*           nMontDev := Db2Dev(saJnl[JNL_IDDEV],FIN->Periode,val(FNL->Mont))
*           FNL->MontDev := ntom0( nMontDev, DevDecPos(saJnl[JNL_IDDEV]) )
*         endif
*       else
*         nMontDev := Db2Dev(GEN->IdDev,FIN->Periode,val(FNL->Mont))
*         * nMontDev := val(FNL->Mont) / val(DevCours(GEN->IdDev,FIN->Periode))
*         FNL->MontDev := ntom0( nMontDev, DevDecPos(GEN->IdDev) )
*       endif
*     else
*       FNL->MontDev := ""
*     endif
*   else
*     if ParExist(FNL->IdCpt)
*       if empty(PAR->IdDev) .or. PAR->IdDev == DevDefault(FIN->Periode)
*         if empty(saJnl[JNL_IDDEV]) ;
*           .or. saJnl[JNL_IDDEV] == DevDefault(FIN->Periode)
*           FNL->MontDev := ""
*         else
*           nMontDev := Db2Dev(saJnl[JNL_IDDEV],FIN->Periode,val(FNL->Mont))
*           FNL->MontDev := ntom0( nMontDev, DevDecPos(saJnl[JNL_IDDEV]) )
*         endif
*       else
*         nMontDev := Db2Dev(PAR->IdDev,FIN->Periode,val(FNL->Mont))
*         * nMontDev := val(FNL->Mont) / val(DevCours(PAR->IdDev,FIN->Periode))
*         FNL->MontDev := ntom0( nMontDev, DevDecPos(PAR->IdDev) )
*       endif
*     else
*       FNL->MontDev := ""
*     endif
*   endif
* else
*   nMontDev := FinDb2Dev(val(FNL->Mont))
*   if Confirm(MsgSetMont(FIN->IdDev))
*     FNL->MontDev := ntom0( nMontDev, saDev[DEV_DECPOS] )
*   endif
* endif
* RETURN FnlDifCheck()



* **
* ** FnlMDValidate()
* **
* FUNCTION FnlMDValidate
* local nMontDev := val(FNL->MontDev)
* RETURN .t. if ! FnlFirstCheck()
* RETURN .f. if ! FnlSetMont() // falls FNL->MontDev geleert wurde
* if FIN->IdDev == DevDefault(FIN->Periode)
*   if empty(FNL->IdCtr)
*     if GenExist(left(FNL->IdCpt,LenIdGen()))
*       if empty(GEN->IdDev) .or. GEN->IdDev == DevDefault(FIN->Periode)
*         if empty(saJnl[JNL_IDDEV]) ;
*           .or. saJnl[JNL_IDDEV] == DevDefault(FIN->Periode)
*           FNL->MontDev := ""
*         else
*           FNL->MontDev := ntom0( nMontDev, DevDecPos(saJnl[JNL_IDDEV]) )
*           if Confirm(MsgSetMont(FIN->IdDev))
*             FNL->Mont := ntom0(Dev2Db(saJnl[JNL_IDDEV],FIN->Periode,nMontDev))
*           endif
*         endif
*       else
*         FNL->MontDev := ntom0( nMontDev, DevDecPos(GEN->IdDev) )
*         if Confirm(MsgSetMont(FIN->IdDev))
*           FNL->Mont := ntom0(Dev2Db(GEN->IdDev,FIN->Periode,nMontDev))
*         endif
*       endif
*     else
*       FNL->MontDev := ""
*     endif
*   else
*     if ParExist(left(FNL->IdCpt,LenIdPar()))
*       if empty(PAR->IdDev) .or. PAR->IdDev == DevDefault(FIN->Periode)
*         if empty(saJnl[JNL_IDDEV]) ;
*           .or. saJnl[JNL_IDDEV] == DevDefault(FIN->Periode)
*           FNL->MontDev := ""
*         else
*           FNL->MontDev := ntom0( nMontDev, DevDecPos(saJnl[JNL_IDDEV]) )
*           if Confirm(MsgSetMont(FIN->IdDev))
*             FNL->Mont := ntom0(Dev2Db(saJnl[JNL_IDDEV],FIN->Periode,nMontDev))
*           endif
*         endif
*       else
*         FNL->MontDev := ntom0( nMontDev, DevDecPos(PAR->IdDev) )
*         if Confirm(MsgSetMont(FIN->IdDev))
*           FNL->Mont := ntom0(Dev2Db(PAR->IdDev,FIN->Periode,nMontDev))
*         endif
*       endif
*     else
*       FNL->MontDev := ""
*     endif
*   endif
* else
*   FNL->Mont := ntom0( FinDev2Db(nMontDev) )
*   FNL->MontDev := ntom0( nMontDev, saDev[DEV_DECPOS] )
* endif
* RETURN FnlDifCheck()


FUNCTION MsgSetMont(cIdDev)
#ifdef LG_GERMAN
RETURN "Betrag " + cIdDev + " anpassen (J/N) ?"
#else
RETURN "Adapter le montant en " + cIdDev + " (O/N) ?"
#endif

**
** FnlDifCheck() -- prÅft auf Zahlungsdifferenz
**
STATIC FUNCTION FnlDifCheck
local dev
local aMatch := {}
local cMont
local cMontDev
local nMont    := 0
local nMontDev := 0
local cIdPar
local cIdGen
local cIdDevDefault
local cIdDev
local nCount := 0
ddSendKey(K_ALT_F5) // neu seit [19980723]
RETURN .t. if empty(FNL->Match)
cIdDevDefault := DevDefault(FIN->Periode)
if empty(FNL->IdCtr)
  cIdGen := left(FNL->IdCpt,LenIdGen())
  open area oHst(), oPar(), oGen(), oFin(), oVen()
    ddSetOrder(ORD_HST_GENMATCH)
    seek cIdGen + FNL->Match
    do while HST->IdGen == cIdGen .and. HST->Match == FNL->Match
      nCount++
      if HST->DC == DC_DEBIT
        nMont    += HstMont(cIdDevDefault) // val(HST->Mont)
        if saFnlDev != NIL
          nMontDev += HstMont(saFnlDev[DEV_IDDEV])
        endif
      else
        nMont    -= HstMont(cIdDevDefault) // val(HST->Mont)
        if saFnlDev != NIL
          nMontDev -= HstMont(saFnlDev[DEV_IDDEV])
        endif
      endif
      skip
    enddo
  close area
else
  cIdPar := left(FNL->IdCpt,LenIdPar())
  * RETURN .t. if ! ParExist(cIdPar)
  * cIdDev := PAR->IdDev
  open area oHst(), oPar(), oGen(), oFin(), oVen()
    ddSetOrder(ORD_HST_PARMATCH)
    seek cIdPar + FNL->Match
    do while HST->IdPar == cIdPar .and. HST->Match == FNL->Match
      nCount++
      if HST->DC == DC_DEBIT
        nMont    += HstMont(cIdDevDefault)
        if saFnlDev != NIL
          nMontDev += HstMont(saFnlDev[DEV_IDDEV])
        endif
      else
        nMont    -= HstMont(cIdDevDefault)
        if saFnlDev != NIL
          nMontDev -= HstMont(saFnlDev[DEV_IDDEV])
        endif
      endif
      skip
    enddo
  close area
endif
RETURN .t. if nCount == 0
if FNL->DC == DC_DEBIT
  nMont    := - nMont
  nMontDev := - nMontDev
endif
FnlDifEdit(nMont,nMontDev)
RETURN .t.

*if saDev[DEV_IDDEV] == cIdDevDefault
*  FnlDifEdit(nMont,nMontDev,cIdDev)
*else
*  if saDev[DEV_IDDEV] != cIdDev .and. ! empty(cIdDev)
*    ** Kassenjournal in FremdwÑhrung, die au·erdem nicht mit der FW des
*    ** Partners/Generalkontos Åbereinstimmt.
*    ** HST->MontDev versteht sich aber immer in der des Partners
*    ** deshalb muss nMontDev jetzt noch in die WÑhrung des
*    ** Kassenjournals umgerechnet werden...
*    ** 2000-01-12 nMontDev := FinDb2Dev(nMontDev)
*    nMontDev := FinDb2Dev(nMont)
*    * nMontDev := nMontDev / snCours * val(DevCours(cIdDev,FIN->Periode))
*  endif
*  FnlDifEdit(nMont,nMontDev,saDev[DEV_IDDEV])
*endif
*RETURN .t.

FUNCTION FnlFirstCheck()
local cIdDevDefault := DevDefault(FIN->Periode)
if saDev[DEV_IDDEV] != cIdDevDefault
  saFnlDev := saDev
else
  saFnlDev := NIL
  if empty(FNL->IdCtr)
    RETURN .f. if ! GenExist(left(FNL->IdCpt,LenIdGen()))
    if !empty(GEN->IdDev)
      saFnlDev := DevLocate(GEN->IdDev)
    endif
  else
    RETURN .f. if ! ParExist(left(FNL->IdCpt,LenIdPar()))
    if !empty(PAR->IdDev)
      saFnlDev := DevLocate(PAR->IdDev)
    endif
  endif
  if saFnlDev == NIL .or. saFnlDev[DEV_IDDEV] == cIdDevDefault
    if !empty(saJnl[JNL_IDDEV]) .and. saJnl[JNL_IDDEV] != cIdDevDefault
      saFnlDev := DevLocate(saJnl[JNL_IDDEV])
    endif
  endif
endif
* 20010411
if saFnlDev == NIL
  FNL->IdDev := ""
else
  FNL->IdDev := saFnlDev[DEV_IDDEV]
endif
RETURN .t.


**
** FnlDifEdit()
**
** cIdDev : welche WÑhrung als FW benutzt wird
**
FUNCTION FnlDifEdit(nMont,nMontDev) // ,cIdDev)
local cIdDevDefault := DevDefault(FIN->Periode)
local nNbDec    := DevDecPos(cIdDevDefault)
* local nNbDecDev := DevDecPos(cIdDev)
local cMont
local cMontDev := ""
local nDiff
local nDiffDev
local dif
local aBuf
local cIdGen
local nRecNo := recno()
local cDC := FNL->DC
* local lMontDev := ! (empty(cIdDev) .or. cIdDev == cIdDevDefault)
if nMont < 0
  cDC := DcInvert(FNL->DC)
  nMont := - nMont
  nMontDev := - nMontDev
endif
cMont := ntom(nMont,nNbDec)
if empty(FNL->Mont)
  FNL->DC  := cDC
  FNL->Mont := cMont
endif
if saFnlDev != NIL
  cMontDev := ntom(nMontDev,saFnlDev[DEV_DECPOS])
  if empty(FNL->MontDev)
    * if abs(nMontDev) < Tolerance(saFnlDev[DEV_DECPOS])
    *   if saFnlDev[DEV_IDDEV] == FIN->IdDev
    *     nMontDev := FinDb2Dev(nMont)
    *   else
    *     nMontDev := Db2Dev(saFnlDev[DEV_IDDEV],FIN->Periode,nMont)
    *   endif
    * endif
    FNL->DC  := cDC
    FNL->MontDev := cMontDev
  endif
endif
if abs(val(FNL->Mont) - nMont) < Tolerance(nNbDec)
  if saFnlDev == NIL
    RETURN NIL if empty(FNL->MontDev)
  else
    RETURN NIL if abs(val(FNL->MontDev) - nMontDev) < Tolerance(saFnlDev[DEV_DECPOS])
  endif
endif
open window (MsgFnlDif) size 6,46 home 0,10 help FNLDIF
say FNL->Match
WinCr()
say padr(FNL->IdCpt + " : " + ParName(), 30)
WinCr()
#ifdef LG_GERMAN
say "offen   : "
#endif
#ifdef LG_FRENCH
say "Ö payer : "
#endif
#ifdef LG_EN
say "to pay : "
#endif
say cMont + " " + DevDefault(FIN->Periode)
if saFnlDev != NIL // lMontDev
  say " = " + cMontDev + " " + saFnlDev[DEV_IDDEV] // cIdDev
endif
WinCr()
#ifdef LG_GERMAN
say "gebucht : "
#endif
#ifdef LG_FRENCH
say "payÇ : "
#endif
#ifdef LG_EN
say "perceived : "
#endif
get FNL->Mont GET_DECPOS(nNbDec)
say " " + DevDefault(FIN->Periode)
if saFnlDev != NIL // lMontDev
  say " = "
  get FNL->MontDev GET_DECPOS(saFnlDev[DEV_DECPOS]) // nNbDecDev)
  say " " + saFnlDev[DEV_IDDEV] // cIdDev
endif
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
nDiff    := val(cMont) - val(FNL->Mont)
nDiffDev := val(cMontDev) - val(FNL->MontDev)
RETURN NIL if abs(nDiff) < 0.01 .and. abs(nDiffDev) < 0.01
RETURN NIL if (dif := PickDif(FNL->IdCtr,FNL->DC,nDiff)) == NIL
RETURN NIL if empty(dif[DIF_IDGEN])
FNL->DC      := cDC
FNL->Mont    := cMont
if saFnlDev != NIL // lMontDev
  FNL->MontDev := cMontDev
endif
aBuf := CopyRec()
if dbAddRec()
  PasteRec(aBuf)
  FNL->IdCtr := "" // CPTTYPE_GEN
  FNL->IdCpt := dif[DIF_IDGEN] // cIdGen
  if nDiff < 0
    FNL->Mont    := ntom(-nDiff,nNbDec)
    if saFnlDev != NIL // lMontDev
      FNL->MontDev := ntom(-nDiffDev,saFnlDev[DEV_DECPOS]) // nNbDecDev)
    endif
  else
    FNL->DC      := DcInvert(FNL->DC)
    FNL->Mont    := ntom(nDiff,nNbDec)
    if saFnlDev != NIL // lMontDev
      FNL->MontDev := ntom(nDiffDev,saFnlDev[DEV_DECPOS]) // nNbDecDev)
    endif
  endif
  FnlAfter()
  unlock record
endif
goto nRecNo
RETURN NIL


FUNCTION FinFnlInit(jnl)
local a := FnlSave()
saJnl       := jnl
* if saJnl[JNL_IDDEV] == DevDefault(FIN->Periode)
if FIN->IdDev == DevDefault(FIN->Periode)
  snMont      := val(FIN->Mont1)
  snMontDev   := 0
else
  snMont      := 0
  snMontDev   := val(FIN->Mont1)
endif
* snCours := val(FIN->Cours)
* RETURN NIL if (saDev := DevLocate(jnl[JNL_IDDEV])) == NIL
if (saDev := DevLocate(FIN->IdDev)) == NIL
  SetMsg(FIN->IdDev + MsgDevExist())
  RETURN NIL
endif
* RETURN NIL if snCours == 0
SetDevise(DevDefault(FIN->Periode))
* SetDecPos(DevDecPos(DevDefault(FIN->Periode)))
RETURN a

* FUNCTION FnlSetRemarq
* scFinRemarq := FNL->Libell
* RETURN MnuDone()

FUNCTION FnlAfter
if FNL->DC == saJnl[JNL_DC]
  snMont    -= val(FNL->Mont)
  snMontDev -= val(FNL->MontDev)
else
  snMont    += val(FNL->Mont)
  snMontDev += val(FNL->MontDev)
endif
RETURN NIL

FUNCTION FnlBefore
if FNL->DC == saJnl[JNL_DC]
  snMont    += val(FNL->Mont)
  snMontDev += val(FNL->MontDev)
else
  snMont    -= val(FNL->Mont)
  snMontDev -= val(FNL->MontDev)
endif
RETURN NIL

FUNCTION FinSolde2
RETURN snMont if FIN->IdDev == DevDefault(FIN->Periode)
RETURN snMontDev

FUNCTION FnlMont ; RETURN snMont
FUNCTION FnlMontDev ; RETURN snMontDev

FUNCTION FnlDevDecPos()
SetFnlDev()
RETURN saFnlDev[DEV_DECPOS] if saFnlDev != NIL
RETURN 0


#endif DEF_FIN

#ifdef DEF_HST

**
** ParSatisfy()
** Ñhnlich wie GenSatisfy()
**
FUNCTION ParSatisfy(cIdPar,dDate)
local nMont
local lOkay := .f.
local cMatch := NIL
local lSatis
local lNotSatis
local nDebit
local nCredit
local nParDebit  := 0
local nParCredit := 0
local dParDate := NIL
local dMatchDate
local cIdDev // := DevDefault(PerActive())
local nDecPos := DevDecPos(DevDefault(PerActive()))
local cIdCtr
local lCtrMix := NIL // Wird irgendwo Einkauf/Verkauf verwechselt?
local lSetSatis
* local lParCtrMix := .f.
* local cIdDevPar
MsgDisplay(cIdPar + " : " + MsgSatis() + "...")
open area oHst(), oVen(), oFin(), oPar(), oGen()
  seek cIdPar in PAR
  * cIdDevPar := PAR->IdDev
  lOkay := .t.
  ddSetOrder(ORD_HST_PARMATCH)
  softseek cIdPar
  do while ! eof() .and. HST->IdPar == cIdPar
    if TaskInter() ; lOkay := .f. ; exit ; endif
    cMatch := HST->Match
    nDebit := nCredit := 0
    lSatis := .f.    // wird .t. wenn mindestens eine *-Buchung da ist
    lNotSatis := .f. // wird .t. wenn mindestens eine Buchung ohne * da ist
    dMatchDate := NIL // Datum der Ñltesten offenen Buchung pro Match
    cIdDev := NIL
    lCtrMix := NIL // Wird irgendwo Einkauf/Verkauf verwechselt?
    cIdCtr := NIL
    do while ! eof() .and. HST->IdPar == cIdPar ;
                     .and. HST->Match == cMatch
      #ifdef DEF_CTRATTR
        if CTRATTR_L $ CtrAttrib(HST->IdCtr)
          skip
          loop
        endif
      #endif DEF_CTRATTR
      if empty(dDate) .or. HST->Date <= dDate
        default cIdDev to DevDefault(HST->Periode)
        default cIdCtr to HST->IdCtr
        if cIdCtr != HST->IdCtr
          lCtrMix := HST->Match
        endif
        if HST->DC == DC_DEBIT
          nDebit  += HstMont(cIdDev)
        else
          nCredit += HstMont(cIdDev)
        endif
      endif
      if HST->Satis == "*"
        lSatis := .t.
      else
        lNotSatis := .t.
        if dMatchDate == NIL .or. HST->Date < dMatchDate
          dMatchDate := HST->Date
        endif
      endif
      skip
    enddo
    ** dMatchDate ist die Ñlteste offene Buchung PRO MATCH.
    ** Uns interessiert aber die Ñ.o.B. des PARTNERS
    ** RAP_LIMIT
    if cIdDev == NIL .or. abs(nDebit-nCredit) > DevTolerance(cIdDev)
      ** Wenn keine Buchungen im Datumbereich waren, dann ist cIdDev
      ** NIL. Dann gibt es vielleicht sehr wohl welche, aber die sind
      ** dann neuer als dDate. Die mÅssen dann auf unlettriert gesetzt
      ** werden.
      lSetSatis := .f.
    else
      if lCtrMix != NIL
        lSetSatis := OnHstCtrMix(lCtrMix)
      else
        lSetSatis := .t.
      endif
    endif
    if ! lSetSatis
      nParDebit  += Dev2Db(cIdDev,PerActive(),nDebit)
      nParCredit += Dev2Db(cIdDev,PerActive(),nCredit)
      if lSatis
        dMatchDate := NIL // dann mÅssen wir noch mal neu nachschauen
        softseek cIdPar + cMatch
        do while ! eof() .and. HST->IdPar == cIdPar ;
                         .and. HST->Match == cMatch
          #ifdef DEF_CTRATTR
            if CTRATTR_L $ CtrAttrib(HST->IdCtr)
              skip
              loop
            endif
          #endif DEF_CTRATTR
          * if empty(dDate) .or. HST->Date <= dDate
            if HST->Satis != " "
              if ddRecLock()
                HST->Satis := " "
                unlock record
              endif
            endif
            if dMatchDate == NIL .or. HST->Date < dMatchDate
              dMatchDate := HST->Date
            endif
          * endif
          skip
        enddo
      endif
    else
      ** Wenn der Match befriedigt ist (Summe D = Summe C)
      dMatchDate := NIL // dann ist ja alles okay
      if lNotSatis // waren da HST's ohne "*" ?
        softseek cIdPar + cMatch
        do while ! eof() .and. HST->IdPar == cIdPar ;
                         .and. HST->Match == cMatch
          #ifdef DEF_CTRATTR
            if CTRATTR_L $ CtrAttrib(HST->IdCtr)
              skip
              loop
            endif
          #endif DEF_CTRATTR
          * if empty(dDate) .or. HST->Date <= dDate
            if HST->Satis != "*"
              if ddRecLock()
                HST->Satis := "*"
                unlock record
              endif
            endif
          * endif
          skip
        enddo
      endif
    endif
    * if lCtrMix
    *   lParCtrMix := .t.
    * endif
    if dMatchDate != NIL
      if dParDate == NIL .or. dParDate > dMatchDate
        dParDate := dMatchDate
      endif
    endif
  enddo
close area
RETURN .f. if ! lOkay
* RETURN .t. if ! empty(dDate)
open area oPar()
  seek cIdPar
  if ! eof()
    if ddRecLock()
      PAR->Debit := ntom(nParDebit,nDecPos)
      PAR->Credit := ntom(nParCredit,nDecPos)
      if dParDate == NIL
        PAR->MvpDate := ctod("")
      else
        PAR->MvpDate := dParDate
      endif
      if ! OnParSatisfy(.f.)
        lOkay := Confirm(SetMsg(),MsgContinue())
      endif
      unlock record
    endif
  endif
close area
RETURN lOkay

#endif DEF_HST

#ifdef DEF_FIN

**
** ParCash()
**
*FUNCTION ParCash(cIdPar)
*local aFnl
*local aJnl := JnlList({|j| j[JNL_ALIAS] == "FIN" .and. JNLATTR_D $ j[JNL_ATTRIB]})
*local jnl
*local lOkay := .f.
*local cIdDoc
*local cLine
*local i
*local b := oFin()
*local a
*RETURN .f. if ! ParExist(cIdPar)
*if len(aJnl) == 1
*  jnl := aJnl[1]
*else
*  jnl := PickJnl(NIL,NIL,aJnl,"Barzahlung","PARCASH")
*  RETURN .f. if jnl == NIL
*endif
*open area b
*  KeyGoBottom( ;
*    jnl[JNL_IDJNL] , "FIN->IdJnl" ;
*  )
*  if eof() .or. FIN->Etat == DocStatClosed()
*    * if Confirm(jnl[JNL_IDJNL] + " : Kasse erîffnen (J/N)")
*      if DocCreate( ;
*        jnl, ;
*        {|cIdDoc| FinCreate(jnl,cIdDoc) } ;
*      ) != DDCREATE_FAIL
*        if ddRecLock()
*          lOkay := .t.
*        endif
*      endif
*    * endif
*  elseif ddRecLock()
*    lOkay := .t.
*  endif
*  if lOkay
*    lOkay := .f.
*    if (a := FinFnlInit(jnl)) == NIL
*      Warning(MsgIdJnlDoc() + " : " + SetMsg())
*    else
*      aFnl := ParFnlCollect(cIdPar,"PARCASH")
*      lOkay := .t.
*      cIdDoc := FIN->IdDoc
*      if len(aFnl) > 0
*        FIN->Etat := DocStatNew()
*        lOkay := .f.
*        open area oFnl()
*          KeyGoBottom( ;
*            FIN->IdJnl + FIN->IdDoc, ;
*            "FNL->IdJnl+FNL->IdDoc" ;
*          )
*          cLine := NextNum(FNL->Line)
*          for i := 1 to len(aFnl)
*            if dbAddRec()
*              FNL->IdJnl   := FIN->IdJnl
*              FNL->IdDoc   := FIN->IdDoc
*              FNL->Line    := cLine
*              FNL->IdCpt   := cIdPar
*              FNL->Match   := aFnl[i][FNL_MATCH]
*              FNL->Mont    := aFnl[i][FNL_MONT]
*              FNL->MontDev := aFnl[i][FNL_MONTDEV]
*              FNL->IdDev   := aFnl[i][FNL_IDDEV]
*              FNL->DC      := aFnl[i][FNL_DC]
*              FNL->IdCtr   := aFnl[i][FNL_CPTTYPE]
*              FNL->Libell  := aFnl[i][FNL_LIBELL]
*              unlock record
*              cLine := NextNum(cLine)
*            else
*              lOkay := .f.
*              exit
*            endif
*          next i
*        close area
*      endif
*      ** Ñhnlich wie FinEdit() :
*      SendKey(K_ENTER)
*      edit data b ;
*        key FIN->IdJnl + FIN->IdDoc ;
*        value jnl[JNL_IDJNL] + cIdDoc ;
*        create   {|| DDCREATE_FAIL } ;
*        query ("FIN"+jnl[JNL_IDDBV]) ;
*        mode edit  ;
*        full ;
*        title (jnl[JNL_IDJNL] + " " + cIdDoc)
*    endif
*    unlock record
*    FnlRestore(a)
*  endif
*close area
*RETURN lOkay

FUNCTION FinDb2Dev(nMont)
// RETURN nMont if FIN->IdDev == DevDefault(FIN->Periode)
RETURN Db2Dev(FIN->IdDev,FIN->Periode,nMont) if empty(FIN->Cours)
RETURN nMont * val(FIN->Cours) if FIN->Periode >= PerToggle()
RETURN nMont / val(FIN->Cours)

FUNCTION FinDev2Db(nMont)
// RETURN nMont if FIN->IdDev == DevDefault(FIN->Periode)
RETURN Dev2Db(FIN->IdDev,FIN->Periode,nMont) if empty(FIN->Cours)
RETURN nMont / val(FIN->Cours) if FIN->Periode >= PerToggle()
RETURN nMont * val(FIN->Cours)


#define TAG_RECNO 1
#define TAG_TAGGED 2

**
** FnlHstFill()
**
FUNCTION FnlHstFill( ;
  nOrder, ;
  cStart, ;
  xlWhile, ;
  xlFilter, ;
  xcTagLine, ;
  lDcInvert, ;
  lGroup, ;
  nMaxSize, ;
  bIdle, lWithDate ;
)
local aFnl := {}
local aTag := {}
local i
local cPeriode := FIN->Periode
RETURN .f. if FIN->Etat == DocStatClosed()
default nOrder to 1
default cStart to ""
default xlWhile to ".t."
default xlFilter to ".t."
default lDcInvert to .t.
default lGroup to .f.
default nMaxSize to 1000
if xcTagLine == NIL
  xcTagLine := 'HST->IdJnl+HST->IdDoc'
  xcTagLine += '+ " " + left(dtoc(HST->Date),5)'
  * xcTagLine += '+ " " + HST->IdPar'
  xcTagLine += '+ " " + padr(ParName(HST->IdPar),20)'
  xcTagLine += '+ " " + right(HST->Match,6)'
  xcTagLine += '+ " " + padr(HstDocName(HST->IdJnl,HST->IdDoc,HST->Line),16)'
  xcTagLine += '+ " " + HST->Mont'
  xcTagLine += '+ " " + HST->DC'
endif
open area oHst(), oVen(), oFin(), oFnl(), oPar(), oGen()
  ddSetOrder(nOrder)
  softseek cStart
  do while ! eof() .and. &xlWhile
    if FnlFillFilter()
      if &xlFilter
        if len(aTag) > nMaxSize
          #ifdef LG_GERMAN
            Warning("Die Liste enthÑlt mehr als " + ntrim(nMaxSize)+ " EintrÑge !")
          #else
            Warning("La liste contient plus de " + ntrim(nMaxSize)+ " entrÇes !")
          #endif
          exit
        endif
        aadd(aTag, { recno(), .t. }) // TAG_RECNO, TAG_TAGGED
      endif
    endif
    skip
  enddo
  aTag := TagSelect(aTag,xcTagLine,NIL,NIL,NIL,bIdle)
  for i := 1 to len(aTag)
    goto (aTag[i][TAG_RECNO])
    HstFnlCollect(aFnl,lDcInvert,lGroup,cPeriode,lWithDate)
  next i
close area
if len(aFnl) == 0
  #ifdef LG_GERMAN
    SetMsg("(Sie haben keine Buchungen ausgewÑhlt)")
  #else
    SetMsg("(Vous n'avez sÇlectionnÇ aucune proposition)")
  #endif
  RETURN .f.
endif
FnlGenerate(aFnl,FIN->IdJnl,FIN->IdDoc)
ddSetUpdated(.t.) // oFnl()[AD_UPDATED] := .t.
ddGoBottom(.t.)
RETURN .t.


FUNCTION HstCompte
RETURN padr(HST->IdGen,LenCompte()) if empty(HST->IdCtr)
RETURN padr(HST->IdPar,LenCompte())

FUNCTION HstFnlCollect(aFnl,lDcInvert,lGroup,cPeriode,lWithDate)
local fnl := NIL
local i
local nDebit
local nDevDebit
local aDevDefault := DevLocate(DevDefault(cPeriode))
local cIdDev
default lWithDate to .f.
if lGroup
  for i := 1 to len(aFnl)
    if aFnl[i][FNL_CPTTYPE]  == HST->IdCtr
      if aFnl[i][FNL_COMPTE] == HstCompte()
        if aFnl[i][FNL_MATCH] == HST->Match
          fnl := aFnl[i]
        endif
      endif
    endif
  next i
endif
if fnl == NIL
  fnl := array(FNL_ALEN)
  fnl[FNL_MATCH]   := HST->Match
  fnl[FNL_CPTTYPE] := HST->IdCtr
  fnl[FNL_COMPTE]  := HstCompte()
  if lWithDate
    fnl[FNL_DATE]    := HST->Date
  endif
  * 19990727 fnl[FNL_LIBELL]  := "" // HST->Libell
  fnl[FNL_LIBELL]  := HstParLibell(HST->IdJnl,HST->IdDoc,HST->Line)
  fnl[FNL_MONT] := ntom( ;
    HstMont(aDevDefault[DEV_IDDEV]),;
    aDevDefault[DEV_DECPOS];
  )
  if saDev[DEV_IDDEV] == aDevDefault[DEV_IDDEV]
    if empty(saJnl[JNL_IDDEV]) .or. saJnl[JNL_IDDEV] == aDevDefault[DEV_IDDEV]
      // FremdwÑhrung der ursprÅnglichen Buchung Åbernehmen
      cIdDev := HST->IdDev
      * 20010411 cIdDev := HstIdDev()
      if empty(cIdDev) .or. cIdDev == saDev[DEV_IDDEV] ;
                       .or. cIdDev == aDevDefault[DEV_IDDEV]
        fnl[FNL_MONTDEV] := ""
        fnl[FNL_IDDEV] := ""
      else
        fnl[FNL_IDDEV] := cIdDev
        fnl[FNL_MONTDEV] := ntom(;
        HstMont(cIdDev),;
        DevDecPos(cIdDev);
      )
      endif
    else
      // das Journal will eine FremdwÑhrung
      fnl[FNL_IDDEV] := saJnl[JNL_IDDEV]
      fnl[FNL_MONTDEV]    := ntom(;
        HstMont(saJnl[JNL_IDDEV]),;
        DevDecPos(saJnl[JNL_IDDEV]);
      )
    endif
  else
    // das Dokument ist in einer FW ausgestellt
    fnl[FNL_IDDEV] := saDev[DEV_IDDEV]
    fnl[FNL_MONTDEV]    := ntom(;
      HstMont(saDev[DEV_IDDEV]),;
      saDev[DEV_DECPOS];
    )
  endif
  #ifdef DEF_ANAFIN
    fnl[FNL_IDANA] := ""
  #endif DEF_ANAFIN
  if lDcInvert
    fnl[FNL_DC]   := DcInvert(HST->DC)
  else
    fnl[FNL_DC]   := HST->DC
  endif
  aadd(aFnl, fnl)
else
  nDebit    := HstMont(aDevDefault[DEV_IDDEV])
  if saDev[DEV_IDDEV] == aDevDefault[DEV_IDDEV]
    if empty(saJnl[JNL_IDDEV]) .or. saJnl[JNL_IDDEV] == aDevDefault[DEV_IDDEV]
      cIdDev := HST->IdDev
      * 20010411 cIdDev := HstIdDev()
    else
      cIdDev := saJNL[JNL_IDDEV]
    endif
  else
    cIdDev := saDev[DEV_IDDEV]
  endif
  if empty(cIdDev)
    nDevDebit := 0
  else
    nDevDebit := HstMont(cIdDev)
  endif
  if (HST->DC == DC_DEBIT .and. lDcInvert) .or. ;
     (HST->DC == DC_CREDIT .and. !lDcInvert)
    nDebit    := - nDebit
    nDevDebit := - nDevDebit
  endif
  if fnl[FNL_DC] == DC_DEBIT
    nDebit    += val(fnl[FNL_MONT])
    nDevDebit += val(fnl[FNL_MONTDEV])
  else
    nDebit    -= val(fnl[FNL_MONT])
    nDevDebit -= val(fnl[FNL_MONTDEV])
  endif
  if nDebit >= 0
    fnl[FNL_DC]   := DC_DEBIT
    fnl[FNL_MONT] := ntom(nDebit)
    fnl[FNL_MONTDEV] := ntom(nDevDebit,DevDecPos(cIdDev))
  else
    fnl[FNL_DC]   := DC_CREDIT
    fnl[FNL_MONT] := ntom(-nDebit)
    fnl[FNL_MONTDEV] := ntom(-nDevDebit,DevDecPos(cIdDev))
  endif
  fnl[FNL_IDDEV] := cIdDev
endif
RETURN .t.

**
** TagSelect()
**
FUNCTION TagSelect(aTag,xcTagLine,cTitle,cLegend,cIdHlp,bIdleBlock)
local lFound := .f.
local aActions := {}
local aReturn := {}
local i := 1
local nMont
local nMontDev
local aMatch
local cIdDevDefault := DevDefault(FIN->Periode)
default cIdHlp to "TAG"
aadd(aActions, { asc("*"), {|| ;
  TagInvertAll(aTag) ;
} } )
aadd(aActions, { K_SPACE , {|t| ;
  t[TAG_TAGGED] := ! t[TAG_TAGGED], ;
  K_DOWN ;
} } )
browse array aTag using {|x| TagLine(x,xcTagLine) } ;
                  title (cTitle) ;
                  legend (cLegend) ;
                  actions aActions ;
                  delete {||.f.} ;
                  help (cIdHlp) ;
                  idle (bIdleBlock)
RETURN {} if lastchoice() == 0
for i := 1 to len(aTag)
  if aTag[i][TAG_TAGGED]
    lFound := .t.
    exit
  endif
next i
if ! lFound
  aTag[lastchoice()][TAG_TAGGED] := .t.
endif
i := 1
do while i <= len(aTag)
  if aTag[i][TAG_TAGGED]
    i++
  else
    adel(aTag,i)
    asize(aTag,len(aTag) - 1 )
  endif
enddo
RETURN aTag

STATIC FUNCTION TagLine(tag,xcTagLine)
local cLine := if(tag[TAG_TAGGED],BUTTON_ON,BUTTON_OFF)
goto (tag[TAG_RECNO])
cLine += " " + xparse(xcTagLine)
RETURN cLine

STATIC FUNCTION TagInvertAll(aTag)
local i
for i := 1 to len(aTag)
  aTag[i][TAG_TAGGED] := ! aTag[i][TAG_TAGGED]
next i
RETURN K_ALT_F5


FUNCTION FnlJnlAttrib()
RETURN saJnl[JNL_ATTRIB]



#endif DEF_FIN


#ifdef DEF_HST

**
** GenSatisfy()
**
FUNCTION GenSatisfy(cIdGen,dDate) // Ñhnlich wie ParSatisfy()
local lOkay := .f.
local cMatch := NIL
local lSatis
local lNotSatis
local nDebit
local nCredit
local nGenDebit  := 0
local nGenCredit := 0
local cIdDev // := DevDefault(PerActive())
* local cIdDevGen
MsgDisplay(cIdGen + " : " + MsgSatis() + "...")
open area oHst(), oVen(), oFin(), oGen(), oPar()
  seek cIdGen in GEN
  * cIdDevGen := GEN->IdDev
  lOkay := .t.
  ddSetOrder(ORD_HST_GENMATCH)
  softseek cIdGen
  do while ! eof() .and. HST->IdGen == cIdGen
    if TaskInter() ; lOkay := .f. ; exit ; endif
    cMatch := HST->Match
    nDebit := nCredit := 0
    lSatis := .f.
    lNotSatis := .f.
    cIdDev := NIL
    do while ! eof() .and. HST->IdGen == cIdGen ;
                     .and. HST->Match == cMatch
      * HstChkMontDev(GEN->IdDev,cIdDevGen)
      if empty(dDate) .or. HST->Date <= dDate
        default cIdDev to DevDefault(HST->Periode)
        if HST->DC == DC_DEBIT
          nDebit  += HstMont(cIdDev) // val(HST->Mont)
        else
          nCredit += HstMont(cIdDev) // val(HST->Mont)
        endif
      endif
      if HST->Satis == "*"
        lSatis := .t.
      else
        lNotSatis := .t.
      endif
      skip
    enddo
    if cIdDev != NIL .and. abs(nDebit-nCredit) > DevTolerance(cIdDev)
      nGenDebit  += nDebit
      nGenCredit += nCredit
      if lSatis
        softseek cIdGen + cMatch
        do while ! eof() .and. HST->IdGen == cIdGen ;
                         .and. HST->Match == cMatch
          if empty(dDate) .or. HST->Date <= dDate
            if HST->Satis != " "
              if ddRecLock()
                HST->Satis := " "
                unlock record
              endif
            endif
          endif
          skip
        enddo
      endif
    else
      if lNotSatis
        softseek cIdGen + cMatch
        do while ! eof() .and. HST->IdGen == cIdGen ;
                         .and. HST->Match == cMatch
          if empty(dDate) .or. HST->Date <= dDate
            if HST->Satis != "*"
              if ddRecLock()
                HST->Satis := "*"
                unlock record
              endif
            endif
          endif
          skip
        enddo
      endif
    endif
  enddo
close area
RETURN lOkay

/**
  also ich bin auf einer HST und muss jetzt ggf. HST->MontDev neu
  ausfÅllen, weil PAR->IdDev (oder GEN-IdDev) seit der Buchung geÑndert
  haben kînnte. "ggf." hei·t natÅrlich nur, wenn das Dokument nicht in
  einer FW war
**/
*FUNCTION HstChkMontDev(cIdDev)
*local cMontDev
*local doc := DocInfo(HST->IdJnl,HST->IdDoc,HST->Line)
*static slReally
*RETURN NIL if doc == NIL
*RETURN NIL if doc[DOC_IDDEV] != DevDefault(HST->Periode)
*if empty(cIdDev) .or. cIdDev == DevDefault(HST->Periode)
*  cIdDev := JnlIdDev(HST->IdJnl)
*endif
*if empty(cIdDev) .or. cIdDev == DevDefault(HST->Periode)
*  cMontDev := space(LenMont())
*else
*  cMontDev := ntom(Db2Dev(cIdDev,HST->Periode,val(HST->Mont)),DevDecPos(cIdDev))
*endif
*if cMontDev != HST->MontDev
*  default slReally to Confirm(;
*    MsgIdJnlDoc()+' : Betrag FremdwÑhrung ist "';
*    + ltrim(HST->MontDev) + '" statt "' ;
*    + ltrim(cMontDev)+'"', ;
*    "Soll ich diese und alle weiteren Buchungen Ñndern (J/N) ?";
*  )
*  RETURN NIL if ! slReally
*  if ddRecLock()
*    HST->MontDev := cMontDev
*    unlock record
*  endif
*endif
*RETURN NIL

#endif DEF_HST


FUNCTION GsbMontD(x)
if x == NIL
  * RETURN ScanSolde(DC_DEBIT) if recno() == lastrec() + 1
  RETURN space(LenMont()) if eof() // 20070801 recno() == lastrec() + 1
  RETURN space(LenMont()) if FIELD->DC == DC_CREDIT
  RETURN FIELD->Mont
endif
FIELD->DC := DC_DEBIT
FIELD->Mont := x
RETURN NIL


FUNCTION GsbMontC(x)
if x == NIL
  * RETURN ScanSolde(DC_CREDIT) if recno() == lastrec() + 1
  RETURN space(LenMont()) if eof() // 20070801 recno() == lastrec() + 1
  RETURN space(LenMont()) if FIELD->DC == DC_DEBIT
  RETURN FIELD->Mont
endif
FIELD->DC := DC_CREDIT
FIELD->Mont := x
RETURN NIL

*STATIC FUNCTION ScanSolde(cDC)
*local nSolde := 0
** ddScan( {|| nSolde += DcValue(cDC) , .t. } )
*ddScan( {|| ;
*  nSolde += HstMont(SetDevise())*if(FIELD->DC==cDC,1,-1),;
*  .t. ;
*} )
*RETURN ntom(nSolde) if nSolde > 0
*RETURN space(LenMont())


*#ifdef DEF_IMP
*
*FUNCTION GsbImlDev(cDC,x)
*local nMont
*if x == NIL
*  RETURN space(LenMont()) if IML->DC != cDC
*  RETURN IML->MontDev
*endif
*IML->DC := cDC
*IML->MontDev := x
*RETURN NIL
*
*
*#endif DEF_IMP

