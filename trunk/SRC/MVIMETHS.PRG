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


**
** STATIC_SECTION global static variables
**

#ifdef DEF_IMP

  static MSG_MVIPICK   := " : Buchungen bernehmen"
  static LEG_IMLTAG    := "[Leertaste] Ausw„hlen [*] Umkehren [Escape] Abbrechen [Enter] Weiter"

  // MviSetFilter()
  static saJnlList  := {}
  static scIdJnl   := NIL
  static scIdGrj   := NIL
  * static scIdDoc   := NIL
  static scIdDoc1  := NIL
  static scIdDoc2  := NIL
  static scIdCtr   := NIL
  static scIdBud   := NIL
  static scPeriode := NIL
  static scIdPar   := NIL
  static scSatis   := NIL
  static scBlock   := NIL


FUNCTION MviSaveFilter()
local a := {}
aadd(a,  saJnlList  )
aadd(a,  scIdJnl    )
aadd(a,  scIdGrj    )
aadd(a,  scIdDoc1   )
aadd(a,  scIdDoc2   )
aadd(a,  scIdCtr    )
aadd(a,  scIdBud    )
aadd(a,  scPeriode  )
aadd(a,  scIdPar    )
aadd(a,  scSatis    )
aadd(a,  scBlock    )
RETURN a

FUNCTION MviRestFilter(a)
saJnlList := a[ 1]
scIdJnl   := a[ 2]
scIdGrj   := a[ 3]
scIdDoc1  := a[ 4]
scIdDoc2  := a[ 5]
scIdCtr   := a[ 6]
scIdBud   := a[ 7]
scPeriode := a[ 8]
scIdPar   := a[ 9]
scSatis   := a[10]
scBlock   := a[11]
RETURN .t.


FUNCTION MviSetFilter( ;
  cSatis, aJnl, ;
  cIdGrj,cIdJnl,cIdDoc1, cIdDoc2, ;
  cIdCtr,cIdBud, ;
  cPeriode, ;
  cIdPar, cBlock ;
  )
  saJnlList  := aJnl
scIdJnl    := cIdJnl
scIdGrj    := cIdGrj
scIdDoc1   := cIdDoc1
scIdDoc2   := cIdDoc2
scIdCtr    := cIdCtr
scIdBud    := cIdBud
if cPeriode == NIL
  scPeriode := left(PerActive(),2)
else
  scPeriode  := cPeriode
endif
scIdPar    := cIdPar
scSatis    := cSatis
scBlock    := cBlock
RETURN NIL


FUNCTION MviScan(bEval)
// MVI durchlaufen, entsprechend MviSetFilter()
local nCount := 0
local nLen
local lOkay := .f.
open area oMvi()
  lOkay := .t.
  MsgDisplay("Buchungen durchsuchen...")
  if ! empty(scIdPar)
    ddSetOrder(ORD_MVI_PARDATE)
    softseek scIdPar
    do while ! eof() .and. MVI->IdPar == scIdPar .and. ! TaskInter()
      if MviEvalFilter()
        MsgDisp2(ntrim(++nCount))
        if ! eval(bEval)
          lOkay := .f.
          exit
        endif
      endif
      skip
    enddo
  elseif ! empty(scIdJnl)
    ddSetOrder(ORD_MVI_ID)
    if JnlLocate(scIdJnl) == NIL
      softseek trim(scIdJnl)
      nLen := len(trim(scIdJnl))
      do while ! eof() .and. left(MVI->IdJnl,nLen) == left(scIdJnl,nLen) ;
                       .and. ! TaskInter()
        if MviEvalFilter()
          MsgDisp2(ntrim(++nCount))
          if ! eval(bEval)
            lOkay := .f.
            exit
          endif
        endif
        skip
      enddo
    else
      softseek scIdJnl + trim(scIdDoc1)
      do while ! eof() .and. MVI->IdJnl == scIdJnl ;
                       .and. ! TaskInter()
        if ! empty(scIdDoc2) .and. MVI->IdDoc > scIdDoc2
          exit
        endif
        if MviEvalFilter()
          MsgDisp2(ntrim(++nCount))
          if ! eval(bEval)
            lOkay := .f.
            exit
          endif
        endif
        skip
      enddo
    endif
  elseif ! empty(scIdBud)
    ddSetOrder(ORD_MVI_BUDDATE)
    softseek scIdCtr + scIdBud
    do while ! eof() .and. ! TaskInter() .and. MVI->IdBud == scIdBud .and. MVI->DC == scIdCtr
      if MviEvalFilter()
        MsgDisp2(ntrim(++nCount))
        if ! eval(bEval)
          lOkay := .f.
          exit
        endif
      endif
      skip
    enddo
  else
    ddSetOrder()
    go top
    do while ! eof() .and. ! TaskInter()
      if MviEvalFilter()
        MsgDisp2(ntrim(++nCount))
        if ! eval(bEval)
          lOkay := .f.
          exit
        endif
      endif
      skip
    enddo
  endif
close area
RETURN lOkay

FUNCTION MviGetFilter(cTitle,cFltText,lIdPar)
local bFilter := NIL
default lIdPar to .t.
default scIdJnl   to space(LenIdJnl())
default scIdGrj   to space(LEN_IDGRJ)
default scIdDoc1  to space(LenIdDoc())
default scIdDoc2  to space(LenIdDoc())
default scIdCtr   to space(1)
default scIdBud   to space(LenIdBud())
default scPeriode to space(LEN_PERIODE)
default scIdPar   to space(LenIdPar())
default scSatis   to BUTTON_ON
default scBlock   to BUTTON_OFF
default cTitle to "Filter setzen"
scIdBud := SayIdBud(scIdBud)
scPeriode := padr(scPeriode,LEN_PERIODE)
open window (cTitle) size 9,50 help MVIFILT
get scSatis checkbox
say " nur unbefriedigte Buchungen"
WinCr()
say "Nur Periode "
@ CSR_POS get scPeriode ;
          picture PIC_ID pick PickPer(scPeriode)
WinCr()
say "Nur Partner 1 "
if lIdPar
  @ CSR_POS get scIdPar ;
            picture PIC_ID pick PickPar(NIL,scIdPar) ;
            postedit {|x| GetIdPar(x)}
else
  @ CSR_POS say scIdPar
endif
WinCr()
say "Nur Journalgruppe "
@ CSR_POS get scIdGrj ;
          picture PIC_ID pick PickGrj(scIdGrj)
say " Journal "
@ CSR_POS get scIdJnl ;
          picture PIC_ID pick PickIdJnl("IMP",scIdJnl)
WinCr()
say "Beleg Nr "
@ CSR_POS get scIdDoc1 picture PIC_ID pick PickDoc(scIdJnl,scIdDoc1)
say " bis "
@ CSR_POS get scIdDoc2 picture PIC_ID pick PickDoc(scIdJnl,scIdDoc2)
WinCr()
say "Nur Artikel " ; @ CSR_POS get scIdCtr ;
                               picture PIC_ID ;
                               valid empty(scIdCtr).or.DcValidate(scIdCtr)
say " " ;        @ CSR_POS get scIdBud ;
                               picture PIC_ID ;
                               pick PickBudSay(scIdCtr,scIdBud)
WinCr()
if scBlock == BUTTON_ON
  say "(N.B.: blockierte Buchungen werden ignoriert)"
else
  say "(N.B.: blockierte Buchungen werden angezeigt)"
endif
*get scBlock checkbox when UsrLevel() <= "B"
*say " blockierte Buchungen rausfiltern"
nKey := ReadScr()
close window
scIdBud := GetIdBud(scIdBud)
scPeriode := trim(scPeriode)
RETURN .f. if nKey == K_ESC
cFltText := "(Shift-F11)"
* saJnl := NIL // [971117] [971203]
RETURN .t.


FUNCTION MviEvalFilter
if scBlock == BUTTON_ON
  RETURN .f. if !empty(MVI->Blockiert) // seit 20040211
endif
if empty(scIdBud) .or. MVI->IdBud == scIdBud
  if empty(scIdCtr) .or. MVI->DC == scIdCtr
    if empty(scPeriode) .or. MVI->Periode = scPeriode
    * if empty(scPeriode) .or. left(MVI->Periode,len(scPeriode)) = scPeriode
      if empty(scIdPar) .or. MVI->IdPar == scIdPar
        if empty(scIdDoc1) .or. MVI->IdDoc >= scIdDoc1
          if empty(scIdDoc2) .or. MVI->IdDoc <= scIdDoc2
            if ! empty(MVI->MontUs) .or. scSatis == BUTTON_OFF
              * if JnlIsInList(MVI->IdJnl,saJnl) .and. JnlMatch(JnlLocate(MVI->IdJnl),scIdJnl)
              if JnlMatch(JnlLocate(MVI->IdJnl),scIdJnl,scIdGrj,saJnlList)
                RETURN .t.
              endif
            endif
          endif
        endif
      endif
    endif
  endif
endif
RETURN .f.

FUNCTION MviPickFilter()
RETURN NIL if ! MviGetFilter()
RETURN ddSetFilter("MviEvalFilter()", MviFltText() )

FUNCTION MviFltText
local cText := ""
if scSatis == BUTTON_ON ; cText += "offene " ; endif
if ! empty(scIdGrj) ; cText += scIdGrj + " " ; endif
if ! empty(scIdJnl) ; cText += scIdJnl + " " ; endif
RETURN cText

**
** ImlCopy()
**
FUNCTION ImlCopy()
local aLn
local aTagActions := {}
local aTag
local cIdDoc2 := IMP->IdDoc
local jnlDest := JnlLocate(IMP->IdJnl)
local b := oIml()
local i
local cFltText := ""
local lOkay
local cIdPar  := IMP->IdPar
local cIdPar2 := IMP->IdPar2
* local a := MviSaveFilter()
if ddRecStat() == RS_INVALID
  Warning("L”schen Sie zuerst den aktuellen Record !")
  RETURN MnuDone()
endif
MviSetFilter( ;
  BUTTON_ON, JnlList({|jnl| JnlSatisfies(jnl,jnlDest)}), ;
  space(LEN_IDGRJ),space(LenIdJnl()), space(LenIdDoc()), space(LenIdDoc()), ;
  JnlDC(IMP->IdJnl), IMP->IdBud, ;
  left(IMP->Periode,LEN_YEAR), ;
  IMP->IdPar, BUTTON_ON ;
)
if (aLn := MviLnCollect( ;
     {|| ImpMviPreCollect() }, ;
     .t. ) ) != NIL
  ImlGenerate(aLn,jnlDest[JNL_IDJNL],cIdDoc2)
  ddSetUpdated(.t.) // b[AD_UPDATED] := .t.
  #ifdef DEF_MVA
    if JNLATTR_Y $ jnlDest[JNL_ATTRIB]
      softseek IMP->IdJnl+IMP->IdDoc
      do while !eof() .and. IML->IdJnl+IML->IdDoc == IMP->IdJnl+IMP->IdDoc
        if BudExist(IML->DC,IML->IdBud).and.BUDATTR_Y $ BUD->Attrib
          ImlMvaEdit()
        endif
        skip
      enddo
    endif
  #endif DEF_MVA
  ddGoBottom(.t.)
endif
* MviRestFilter(a)
RETURN .t.

*do while ! AppTerminate()
*  RETURN .f. if ! MviGetFilter("Buchungen bernehmen",cFltText)
*  aTag := {}
*  MviScan({|| aadd(aTag, { recno(), .f. } ) })
*  if len(aTag) > 0
*    aLn := {}
*    do while len(aLn) == 0 .and. ! AppTerminate()
*      open area oMvi()
*        aadd(aTagActions, { K_SPACE, {|tag| TagToggle(tag) } } )
*        aadd(aTagActions, { asc("*"), {|| TagInvert(aTag) } } )
*        SetMsg(ntrim(len(aTag)) + " Buchungen gefunden.")
*        browse array aTag using {|tag| MviText(tag) } ;
*                          actions aTagActions ;
*                          delete .f. ;
*                          help "IMLTAG" ;
*                          legend (LEG_IMLTAG)
*      close area
*      if lastkey() == K_ESC
*        exit
*      endif
*      lOkay := .f.
*      open area oMvi()
*        lOkay := .t.
*        for i := 1 to len(aTag)
*          if aTag[i][2]
*            goto aTag[i][1]
*            if left(MVI->Periode,LEN_YEAR) == left(IMP->Periode,LEN_YEAR)
*              if empty(IMP->IdPar) .or. MVI->IdPar == IMP->IdPar
*                MviImlCollect(aLn)
*              else
*                Warning(MsgIdJnlDoc() + " : falscher Partner")
*                lOkay := .f.
*                exit
*              endif
*            else
*              Warning(MsgIdJnlDoc() + " : falsches Rechnungsjahr")
*              lOkay := .f.
*              exit
*            endif
*          endif
*        next i
*      close area
*      if lOkay
*        if len(aLn) == 0
*          Warning("Sie haben keine einzige Buchung ausgew„hlt !")
*        else
*          ImlGenerate(aLn,jnlDest[JNL_IDJNL],cIdDoc2)
*          b[AD_UPDATED] := .t.
*          ddGoBottom(.t.)
*          RETURN MnuDone()
*        endif
*      endif
*    enddo
*  else
*    Warning("Keine Buchungen gefunden !")
*  endif
*enddo
*ddRefreshAll()
*RETURN .f.

FUNCTION ImpMviPreCollect()
if left(MVI->Periode,LEN_YEAR) != left(IMP->Periode,LEN_YEAR)
  Warning(MsgIdJnlDoc() + " : falsches Rechnungsjahr")
  RETURN .f.
endif
RETURN .t. if empty(IMP->IdPar) .or. MVI->IdPar == IMP->IdPar
RETURN .t. if JNLATTR_V $ JnlAttrib(MVI->IdJnl) // 19991124
Warning(MsgIdJnlDoc() + " : falscher Partner")
RETURN .f.


STATIC FUNCTION TagToggle(tag)
tag[1] := ! tag[1]
RETURN K_DOWN
* SendKey(K_DOWN)
* RETURN NIL

STATIC FUNCTION TagInvert(aTag)
local i
for i := 1 to len(aTag)
  aTag[i][1] := ! aTag[i][1]
next i
RETURN K_ALT_F5
* SendKey(K_ALT_F5)
* RETURN NIL


FUNCTION MviText(tag)
local cLine := if(tag[1],"û"," ")
goto tag[2]
cLine += " " + MVI->IdJnl
cLine += " " + MVI->IdDoc
cLine += " " + dtoc(MVI->Date2)
cLine += " " + left(MVI->NB1,29)
cLine += " " + MVI->MontUs
cLine += " " + padl("(" + ltrim(MVI->Mont) + ")",12)
RETURN cLine


FUNCTION JnlSatisfies(jnl1,jnl2)
local sat := SatLocate(jnl1,jnl2)
RETURN .f. if sat == NIL
RETURN .t.

FUNCTION MviImlCollect(aIml,lTestAttrV)
local a := array(IML_ALEN)
// default lTestAttrV to .f.
if ! (lTestAttrV .and. JNLATTR_V $ JnlAttrib(MVI->IdJnl))
  a[IML_IDPAR    ] := MVI->IdPar
  a[IML_IDPAR2   ] := MVI->IdPar2
endif
a[IML_NB1      ] := MVI->NB1
a[IML_DATE     ] := MVI->Date
a[IML_DC       ] := MVI->DC
a[IML_IDBUD    ] := MVI->IdBud
a[IML_MATCH    ] := MVI->Match
a[IML_EAMATCH  ] := MVI->EaMatch
a[IML_IDPRJ    ] := MVI->IdPrj
a[IML_NB2      ] := MVI->NB2
a[IML_COMPTE1  ] := MVI->Compte1
a[IML_MONT     ] := MVI->MontUs
a[IML_MONTDEV  ] := "" // 20011221
a[IML_BACKMATCH] := MVI->IdJnl + MVI->IdDoc + MVI->Line
a[IML_PERIODE  ] := MVI->Periode
* seek MVI->IdJnl + MVI->IdDoc + MVI->Line in IML
* a[IML_MEMO     ] := IML->Memo
* a[IML_DATE3    ] := MVI->Date3
aadd(aIml,a)
RETURN .t.



FUNCTION PickMvi(cIdPar,cIdCtr,cIdBud,cIdJnl,bReturn)
local b := oMvi()
local cMatch := NIL
local cIdJnlFrom
default bReturn to {|| MVI->IdJnl + MVI->IdDoc + MVI->Line }
open area b
  if ! empty(cIdPar)
    * ddSetOrder ORD_MVI_PARDATE
    edit data b key   MVI->IdPar ;
                value cIdPar ;
                mode pick ;
                query "MVIPARD" ;
                start top ;
                title (ParName(cIdPar) + MSG_MVIPICK)
  elseif ! empty(cIdBud)
    * ddSetOrder ORD_MVI_BUDDATE
    edit data b key   MVI->DC + MVI->IdBud + MVI->IdJnl;
                value cIdCtr+cIdBud+cIdJnl ;
                mode pick ;
                query "MVIBUDD" ;
                start top ;
                title (trim(SayIdBud(cIdBud)) + MSG_MVIPICK)
  elseif ! empty(cIdJnl)
    ddSetOrder(ORD_MVI_ID)
    edit data b key   MVI->IdJnl ;
                value cIdJnl ;
                mode pick ;
                query ("MVIJNL") ;
                start top ;
                title (cIdJnl + MSG_MVIPICK)
  else
    Warning( ;
      "Weder Partner noch Artikel noch Journal sind bekannt.",;
      "Wie will ich da was anzeigen...")
  endif
  if ddLastReq() == DDEDIT_SELECT
    cMatch := eval(bReturn)
  endif
close area
RETURN cMatch


*FUNCTION ImpCopy
*local cIdJnl := PickSat1(IMP->IdJnl,"Dokument bernehmen aus...")
*local cMatch
*local cIdJnlDest := IMP->IdJnl
*local cIdDocDest := IMP->IdDoc
*local aBuf
*local nRecNo
*local cLine
*RETURN NIL if cIdJnl == NIL
*cMatch := PickImp(cIdJnl)
*RETURN NIL if empty(cMatch)
*RETURN NIL if ! ddRecLock()
*open area oImp()
*  seek cMatch
*  aBuf := CopyRec()
*close area
*PasteRec(aBuf)
*IMP->IdJnl := cIdJnlDest
*IMP->IdDoc := cIdDocDest
*IMP->Etat  := DocStatOpen()
*open area oIml()
*  ddSetOrder ORD_IML_ID
*  KeyGoBottom( ;
*    cIdJnlDest + cIdDocDest, ;
*    {|| IML->IdJnl + IML->IdDoc }, {||.t.} ;
*  )
*  cLine := NextId(IML->Line)
*  softseek cMatch
*  do while ! eof() .and. IML->IdJnl + IML->IdDoc == cMatch
*    nRecNo := recno()
*    aBuf := CopyRec()
*    append blank
*    if ddRecLock()
*      PasteRec(aBuf)
*      IML->IdJnl := cIdJnlDest
*      IML->IdDoc := cIdDocDest
*      IML->Line  := cLine
*      unlock record
*    endif
*    cLine := NextId(cLine)
*    goto nRecNo
*    skip
*  enddo
*close area
*RETURN NIL
*
*FUNCTION PickImp(cIdJnl)
*local b := oImp()
*local cMatch := NIL
*open area b
*  edit data b key   IMP->IdJnl ;
*              value cIdJnl ;
*              mode pick ;
*              query ("IMP" + JnlIdDbv(cIdJnl)+"P") ;
*              title (cIdJnl + " : Dokument bernehmen")
*  if ddLastReq() == DDEDIT_SELECT
*    cMatch := IMP->IdJnl + IMP->IdDoc
*  endif
*close area
*RETURN cMatch


FUNCTION MviLnCollect(bPreCollect,lIdPar)
local i
local aTag
local aLn := {}
local cFltText := ""
local cTitle := "Buchungen bernehmen"
local aTagActions := {}
aadd(aTagActions, { K_SPACE, {|tag| TagToggle(tag) } } )
aadd(aTagActions, { asc("*"), {|| TagInvert(aTag) } } )
do while ! AppTerminate()
  aTag := {}
  RETURN NIL if ! MviGetFilter(cTitle,cFltText,lIdPar)
  if MviScan({|| xaadd(aTag, { .f., recno(), MVI->Date2 } ) })
    if len(aTag) > 0
      // asort(aTag,,,{|a,b|a[3] <= b[3]})
      do while len(aLn) == 0 .and. ! AppTerminate()
        open area oMvi()
          SetMsg(ntrim(len(aTag)) + " Buchungen gefunden.")
          browse array aTag using {|tag| MviText(tag) } ;
                            actions aTagActions ;
                            title (cTitle) ;
                            delete {||.f. } ;
                            help "IMLTAG" ;
                            legend (LEG_IMLTAG)
        close area
        if lastkey() == K_ESC
          exit
        endif
        open area oMvi(), oIml()
          for i := 1 to len(aTag)
            if aTag[i][1]
              goto aTag[i][2]
              if eval(bPreCollect)
                MviImlCollect(aLn,.t.)
              endif
            endif
          next i
        close area
        if len(aLn) == 0
          Warning("Sie haben keine einzige Buchung ausgew„hlt !")
        else
          RETURN aLn
        endif
      enddo
    else
      Warning("Keine Buchungen gefunden !")
    endif
  endif
enddo
RETURN NIL

FUNCTION xaadd(a,i)
if len(a) > 4000
  Warning("Mehr als 4000 Eintr„ge! šberprfen Sie Ihre Kriterien...")
  RETURN .f.
endif
aadd(a,i)
RETURN .t.


#endif DEF_IMP

#ifdef DEF_JNL
#ifdef LG_GERMAN
FUNCTION MsgUndo() ; RETURN " : Dokument entregistrieren. "
FUNCTION MsgClose  ; RETURN " : Dokument registrieren (J/N) ?"
#endif
#ifdef LG_FRENCH
FUNCTION MsgUndo() ; RETURN " : r‚ouvrir le document. "
FUNCTION MsgClose  ; RETURN " : cl“turer le document (O/N) ?"
#endif
#ifdef LG_EN
FUNCTION MsgUndo() ; RETURN " : reopen document. "
FUNCTION MsgClose  ; RETURN " : close this document (Y/N) ?"
#endif
#endif DEF_JNL


#ifdef DEF_RUN

**
** PickClb()
**
FUNCTION PickClb( cStart, cTitle )
local cIdClb := NIL
local b := oClb()
local nStart := 1 // DDSTART_TOP
default cStart to ""
default cTitle to "Liste des clubs"
open area b
  softseek trim(cStart)
    edit data   b ;
         mode   pick ;
         query  ("CLBPICK") ;
         title  (cTitle)
  if ddLastReq() == DDEDIT_SELECT
    cIdClb := CLB->IdClb
  endif
close area
RETURN cIdClb


**
** PickRal()
**
FUNCTION PickRal( cStart, cTitle )
local cId := NIL
local b := oRal()
default cTitle to "S‚lection Course"
open area b
  if cStart == NIL
    go top
  else
    softseek trim(cStart)
  endif
  edit data b ;
            mode pick ;
            query "RALPICK" ;
            create DDCREATE_FAIL ;
            title (cTitle)
  if ddLastReq() == DDEDIT_SELECT
    cId := RAL->IdRal
  endif
close area
RETURN cId

#endif DEF_RUN


FUNCTION join(a,c)
local result := ""
local i := 1
RETURN result if len(a) == 0
for i := 1 to len(a)-1
  result += a[i] + c
next i
RETURN result+atail(a)



FUNCTION abspath(c)
RETURN ft_default()+":\"+curdir() if empty(c)
if left(c,1) == "\"
  c:=ft_default()+":"+c
elseif left(c,2) == ".\"
  c:=ft_default()+":\"+curdir()+substr(c,2)
elseif substr(c,2,1) != ":"
  c:=ft_default()+":\"+curdir()+"\"+c
endif
RETURN c

FUNCTION normpath(c)
local a := split(c,"\")
local a2 := {}
local i := 1
do while i <= len(a)
  if a[i] == ".."
    // adel(a2,len(a2))
    asize(a2,len(a2)-1)
  elseif ! a[i] == "."
    aadd(a2,a[i])
  endif
  i+=1
enddo
RETURN join(a2,"\")


