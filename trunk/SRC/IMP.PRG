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

static sbMaxMont := {|cIdJnl| 1239.47 }

#ifdef DEF_IMP
  * static snMaxMont := 1239.47   // = 50000 BEF
  static snLenIdBud := 6
  static snLenIdIml := 8
  static snLenIdTrt := 5
  static saOnImpClose := { }
  static saOnMviGenerate := { }
  static saPreImlClose := { }
  static sbBudIsTolerant := {|cRj| BUDATTR_T $ BUD->Attrib }
#endif DEF_IMP
#ifdef DEF_TRA
  static saPreTrlClose := { }
#endif DEF_TRA


FUNCTION ImpAddDbiItems()
AddIniCmd( { "MaxMont"  , {|x| (sbMaxMont := xparse(x)) != NIL } } )
#ifdef DEF_IMP
  * AddIniCmd( { "MaxMont"  , {|x| snMaxMont := val(x),.t. } } )
  AddIniCmd( { "LenIdBud" , {|x| snLenIdBud := val(x),.t. } } )
  AddIniCmd( { "LenIdIml" , {|x| snLenIdIml := val(x),.t. } } )
  AddIniCmd( { "LenIdTrt" , {|x| snLenIdTrt := val(x),.t. } } )
  AddIniCmd( { "OnImpClose" , {|x| AddIfNotNil(saOnImpClose,cblock(x)) } } )
  AddIniCmd( { "OnMviGenerate" , {|x| ;
    AddIfNotNil(saOnMviGenerate,cblock(x))  ;
  } } )
  AddIniCmd( { "PreImlClose" , {|x| AddIfNotNil(saPreImlClose,cblock(x)) } } )
  AddIniCmd( { "BudIsTolerant" , {|x| (sbBudIsTolerant:=xparse(x))!=NIL } } )
#endif DEF_IMP
#ifdef DEF_TRA
  AddIniCmd( { "PreTrlClose" , {|x| AddIfNotNil(saPreTrlClose,cblock(x)) } } )
#endif DEF_TRA
RETURN .t.


#ifdef DEF_IMP

FUNCTION BudAvail(cDC,cIdBud,cPeriode,cIdCdc)
local cExpr := CdcExpr(cDC,cIdCdc)
local nPos
local nPos2
local nMont
RETURN 0 if empty(cIdCdc)
RETURN 0 if empty(cExpr)
cExpr := strtran(cExpr,"{RJ}",cPeriode)
* Warning("before : " + cExpr)
open area oCtb()
  do while (nPos := at("{",cExpr)) != 0
    nPos2 := at("}",cExpr)
    if nPos2 == nPos + (LEN_IDCDC + 1)
      seek cDC + cIdBud + cPeriode + substr(cExpr,nPos + 1, LEN_IDCDC)
      nMont := BudCdcMont( ;
        substr(cExpr,nPos + 1, LEN_IDCDC), ;
        cPeriode, val(CTB->Mont) ;
      )
      cExpr := left(cExpr,nPos-1) + "(" + ntrim(nMont) + ")" + substr(cExpr,nPos2 + 1)
    else
      exit
    endif
  enddo
close area
* Warning("after : " + cExpr)
RETURN &cExpr if type(cExpr) == "N"
Warning(cDC + cIdCdc + " : " + cExpr + " : syntax error.")
RETURN 0

FUNCTION BudCdcMont(cIdCdc,cRJ,nMont)
local cPerc
RETURN nMont if cIdCdc != "01"
cPerc := xparse("BUD->Mod"+cRJ)
RETURN nMont if empty(cPerc)
cPerc := alltrim(cPerc)
if right(cPerc,1) == "%"
  cPerc := left(cPerc,len(cPerc)-1)
  RETURN nMont * val(cPerc) / 100
endif
RETURN nMont + val(cPerc)


FUNCTION CtbMont(cDC,cIdBud,cPeriode,cIdCdc)
seek cDC + cIdBud + cPeriode + cIdCdc in CTB
// RETURN val(CTB->Mont)
RETURN Db2Dev(SetDevise(),LastPeriode(cPeriode),val(CTB->Mont))

FUNCTION MviSum(nOrder,cKey,xlFilter,xnExpr)
local nSum := 0
default xlFilter to ".t."
open area oMvi()
  ddSetOrder(nOrder)
  softseek cKey
  do while ! eof() .and. left(&(indexkey()),len(cKey)) == cKey
    if &xlFilter
      nSum += &xnExpr
    endif
    skip
  enddo
close area
RETURN nSum


**
** CTB
**
*FUNCTION CtbEdit()
*local b := oCtb()
*open area b
*  edit data b start top mode show query "CTB" title (MSG_CTB)
*close area
*RETURN .f.

#endif DEF_IMP

#ifdef DEF_DEV

**
FUNCTION MaxMontOverflow(cIdJnl,cIdJnl2,cIdDev,nMont,cPeriode)
local nMontDb := Dev2Db(cIdDev,cPeriode,nMont)
local nMontEuro := Db2Dev("EUR",cPeriode,nMontDb)
RETURN .f. if nMontEuro < eval(sbMaxMont,cIdJnl,cIdJnl2)
// MaxMontValue(cIdJnl) // snMaxMont
RETURN .t.

* FUNCTION MaxMontValue(cIdJnl)
* RETURN eval(sbMaxMont,cIdJnl) // snMaxMont

#endif DEF_DEV

#ifdef DEF_IMP
  FUNCTION LenIdBud ; RETURN snLenIdBud
  FUNCTION LenIdIml ; RETURN snLenIdIml
  FUNCTION LenIdTrt ; RETURN snLenIdTrt
  FUNCTION BudIsTolerant(cRj); RETURN eval(sbBudIsTolerant,cRJ)
  * FUNCTION OnImpClose
  * local i
  * for i := 1 to len(saOnImpClose)
  *   RETURN .f. if ! &(saOnImpClose[i])
  * next i
  * RETURN .t.
  FUNCTION OnImpClose ; RETURN DoEvents(saOnImpClose)
  FUNCTION PreImlClose ; RETURN DoEvents(saPreImlClose)
  FUNCTION OnMviGenerate ; RETURN DoEvents(saOnMviGenerate)
#endif DEF_IMP
#ifdef DEF_TRA
  FUNCTION PreTrlClose ; RETURN DoEvents(saPreTrlClose)
#endif DEF_TRA

#ifdef DEF_IMP

/**

Jede Buchung wird einerseits im Feld Debit (bzw. Credit) des
Haupt-Partners (MVI->IdPar) summiert, und andererseits im Feld Debit2
(bzw. Credit2) des Nebenpartners (z.B. Zahlungsempf„nger). Ausnahme:
Fr Nebenpartner mit Attribut 2 wird der Betrag ausnahmsweise in Debit2
bzw. Credit2 des Haupt-Partners summiert. Im Mahnwesen sieht es dann so
aus, als w„re kein Nebenpartner benutzt worden.

Einziger Partner mit Attribut 2 ist "Finanzielle Begleitung". Also wenn
der als Partner 2 einer Buchung steht, soll es frs Mahnwesen so sein,
als w„re Partner 2 leer gewesen.

**/

FUNCTION ParMviUpdate(dDateE,dDateF,dDateA)
local lHatOffeneForderung := .f.
local lHatEinnahme := .f.
local lAltfall := .t.
local jnl
local lOkay := .f.
RETURN .t. if PAR->IdPar==repl("0",LenIdPar())
RETURN .f. if ! ddRecLock()
open area oMvi()
  lOkay := .t.
  ddSetOrder(2)
  softseek PAR->IdPar
  do while lOkay.and.!eof().and.MVI->IdPar == PAR->IdPar
    if TaskInter() ; lOkay := .f. ; endif
    if (jnl := JnlLocate(MVI->IdJnl)) != NIL
      if MVI->Date2 > dDateA
        lAltfall := .f.
      endif
      if jnl[JNL_IDGRJ] == "TRE"
        if MVI->DC == DC_CREDIT // Einnahme
          if trim(SayIdBud(MVI->IdBud)) != "P87/000/00"
            if MVI->Date2 >= dDateE
              lHatEinnahme := .t.
            endif
            * lob := MVI->Date2
          endif
        endif
      elseif jnl[JNL_IDGRJ] == "FFO"
        if !empty(MVI->MontUs)
          if MVI->Date2 <= dDateF
            lHatOffeneForderung := .t.
          endif
        endif
      endif
    endif
    skip
  enddo
  if lOkay .and. lAltfall
    ddSetOrder(8) // MVI->IdPar2
    softseek PAR->IdPar
    do while lOkay.and.!eof().and.MVI->IdPar2 == PAR->IdPar
      if TaskInter() ; lOkay := .f. ; endif
      if MVI->Date2 > dDateA
        lAltfall := .f.
      endif
      skip
    enddo
  endif
close area
* open area oMvi()
*   lOkay := .t.
*   ddSetOrder 2
*   KeyGoBottom(PAR->IdPar,"MVI->IdPar")
*   do while lOkay.and.(!lHatEinnahme.or.!lHatOffeneForderung);
*     .and.!eof().and.!bof().and.MVI->IdPar==PAR->IdPar
*     if TaskInter() ; lOkay := .f. ; endif
*     if (jnl := JnlLocate(MVI->IdJnl)) != NIL
*       if MVI->Date2 > dDateA
*         lAltfall := .f.
*       endif
*       if jnl[JNL_IDGRJ] == "TRE"
*         if MVI->DC == DC_CREDIT // Einnahme
*           if trim(SayIdBud(MVI->IdBud)) != "P87/000/00"
*             if MVI->Date2 >= dDateE
*               lHatEinnahme := .t.
*             endif
*           endif
*         endif
*       elseif jnl[JNL_IDGRJ] == "FFO"
*         if !empty(MVI->MontUs)
*           if MVI->Date2 <= dDateF
*             lHatOffeneForderung := .t.
*           endif
*         endif
*       endif
*     endif
*     skip -1
*   enddo
*   if lOkay
*     ddSetOrder 8 // MVI->IdPar2
*     KeyGoBottom(PAR->IdPar,"MVI->IdPar2")
*     do while lOkay.and.(!lHatEinnahme.or.!lHatOffeneForderung);
*       .and.!eof().and.!bof().and.MVI->IdPar2==PAR->IdPar
*       if TaskInter() ; lOkay := .f. ; endif
*       if (jnl := JnlLocate(MVI->IdJnl)) != NIL
*         if MVI->Date2 > dDateA
*           lAltfall := .f.
*         endif
*         if jnl[JNL_IDGRJ] == "TRE"
*           if MVI->DC == DC_CREDIT // Einnahme
*             if trim(SayIdBud(MVI->IdBud)) != "P87/000/00"
*               if MVI->Date2 >= dDateE
*                 lHatEinnahme := .t.
*               endif
*             endif
*           endif
*         elseif jnl[JNL_IDGRJ] == "FFO"
*           if !empty(MVI->MontUs)
*             if MVI->Date2 <= dDateF
*               lHatOffeneForderung := .t.
*             endif
*           endif
*         endif
*       endif
*       skip -1
*     enddo
*   endif
* close area
if lHatOffeneForderung .and. ! lHatEinnahme
  PAR->Attrib := strtran(trim(PAR->Attrib),"E")+"E"
else
  PAR->Attrib := strtran(trim(PAR->Attrib),"E")
endif
if lAltfall
  PAR->Attrib := strtran(trim(PAR->Attrib),"A")+"A"
else
  PAR->Attrib := strtran(trim(PAR->Attrib),"A")
endif
unlock record
// SetMsg(trim(ParName())+" : "+PAR->Attrib)
RETURN lOkay

**
** ParSalden() - Partnersalden neu rechnen
**
FUNCTION ParSalden()
* local lob_c  // letzte offene Buchung credit
* local lob_d
* local lob
local dMviDate
local ap1, ap, i, nRecNo
local nDebit   := 0
local nDebit2  := 0
local nCredit  := 0
local nCredit2 := 0
local nCount := 0
local lOkay := .f.
local jnl
local cIdDev := DevDefault(PerActive())
local nDecPos := DevDecPos(cIdDev)
local nMont
MsgDisplay("Partnersalden neu rechnen...")
open area oPar()
  nCount := 0
  lOkay := .t.
  go top
  do while lOkay .and. ! eof()
    MsgDisp2("(1) " + ntrim0(100 * nCount++ / lastrec()) + "%")
    if TaskInter()
      lOkay := .f.
    elseif ddRecLock()
      PAR->Debit  := ""
      PAR->Credit := ""
      PAR->Debit2 := ""
      PAR->Credit2:= ""
      PAR->MviDate := ctod('')
      unlock record
    else
      lOkay := .f.
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
lOkay := .f.
open area oPar(), oMvi()
  nCount := 0
  MVI->(ddSetOrder(8)) // in MVI // MVI->IdPar2+datum
  lOkay := .t.
  go top
  do while lOkay .and. ! eof()
    MsgDisp2("(2) " + ntrim0(100 * nCount++ / lastrec()) + "%")
    if TaskInter()
      lOkay := .f.
    elseif ddRecLock()
      nDebit  := 0
      nCredit := 0
      nDebit2 := 0
      nCredit2:= 0
      * lob_c := ctod("")
      * lob_d := ctod("")
      * lob := ctod("")
      * lHatOffeneForderung := .f.
      * lHatEinnahme := .f.
      dMviDate := ctod("")
      ap1 := {} // array of { IdPar, D1, C1, D2, C2 } for partner 1
      select MVI
      softseek PAR->IdPar
      do while ! eof() .and. lOkay .and. MVI->IdPar2 == PAR->IdPar
        if TaskInter() ; lOkay := .f. ; endif
        if (jnl := JnlLocate(MVI->IdJnl)) != NIL
          if jnl[JNL_IDCDC] == MemIdCdc
            nMont := val(MVI->MontUs)
            if DevDefault(MVI->Periode) != cIdDev
              nMont := nMont / val(DevCours(cIdDev,MVI->Periode))
            endif
            ap := NIL
            if MVI->IdPar == MVI->IdPar2
              if MVI->DC == DC_DEBIT
                nDebit += nMont
                nDebit2 += nMont
              else
                nCredit += nMont
                nCredit2 += nMont
              endif
            else
              for i := 1 to len(ap1)
                if ap1[i][1] == MVI->IdPar
                  ap := ap1[i]
                  exit
                endif
              next i
              if ap == NIL
                ap := { MVI->IdPar, 0, 0, 0, 0}
                aadd(ap1, ap)
              endif
              if MVI->DC == DC_DEBIT
                ap[2] += nMont
              else
                ap[3] += nMont
              endif
              if PARATTR_2 $ PAR->Attrib
                if MVI->DC == DC_DEBIT
                  ap[4] += nMont
                else
                  ap[5] += nMont
                endif
              else
                if MVI->DC == DC_DEBIT
                  nDebit2 += nMont
                else
                  nCredit2 += nMont
                endif
              endif
            endif
          *elseif jnl[JNL_IDCDC] == "03"
          *  if MVI->DC == DC_CREDIT
          *    * if jnl[JNL_IDGRJ] == "TRE"
          *    dMviDate := MVI->Date2
          *  endif
          endif
          if !empty(MVI->MontUs)
            if empty(dMviDate) .or. MVI->Date2 < dMviDate
              dMviDate := MVI->Date2
            endif
          endif
          *if !empty(MVI->MontUs)
          *  if MVI->DC == DC_CREDIT
          *    lob_c := MVI->Date2
          *  else
          *    lob_d := MVI->Date2
          *  endif
          *endif
        endif
        skip
      enddo
      select PAR
      PAR->Debit   := ntom(val(PAR->Debit)   + nDebit,   nDecPos)
      PAR->Credit  := ntom(val(PAR->Credit)  + nCredit,  nDecPos)
      PAR->Debit2  := ntom(val(PAR->Debit2)  + nDebit2,  nDecPos)
      PAR->Credit2 := ntom(val(PAR->Credit2) + nCredit2, nDecPos)
      PAR->MviDate := dMviDate
      *if lHatOffeneForderung
      *  PAR->MviDate := lob
      *else
      *  PAR->MviDate := ctod("")
      *endif
      * if val(PAR->Debit) > val(PAR->Credit)
      *   PAR->MviDate := lob_d
      * else
      *   PAR->MviDate := lob_c
      * endif
      unlock record
      nRecNo := recno()
      for i := 1 to len(ap1)
        seek ap1[i][1]
        if ! eof()
          if ddRecLock()
            PAR->Debit   := ntom(val(PAR->Debit)   + ap1[i][2],nDecPos)
            PAR->Credit  := ntom(val(PAR->Credit)  + ap1[i][3],nDecPos)
            PAR->Debit2  := ntom(val(PAR->Debit2)  + ap1[i][4],nDecPos)
            PAR->Credit2 := ntom(val(PAR->Credit2) + ap1[i][5],nDecPos)
            unlock record
          else
            lOkay := .f.
            exit
          endif
        endif
      next i
      goto nRecNo
    else
      lOkay := .f.
    endif
    skip
  enddo
close area
RETURN lOkay

#endif DEF_IMP


