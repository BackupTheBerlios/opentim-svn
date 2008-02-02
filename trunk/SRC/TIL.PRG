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

** Description .... : Tilgungsplan

#include "TIM.CH"
#include "DEFDATA.CH"

#ifdef DEF_TIL

static saTlg

#define ORD_TLG_PARDATE 1

**
** TIL -
**
FUNCTION oTil
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name TIL ;
  create TilCreate() ;
  predelete Confirm("Tilgungsplan l”schen ?").and.TilTllDelete() ;
  wait {|msk| TilWait(msk)} ;
  postedit TilPostEdit()
ddIndex b on TIL->IdTil
ddIndex b on TIL->IdPar+dtos(TIL->Date)
ddFld IdTil     ,C, LEN_IDDOC,0 when .f.
ddFld Date      ,D, 8,0
ddFld IdPar     ,C,LenIdPar(),0  picture PIC_ID ;
                                pick PickPar(NIL,TIL->IdPar)
ddFld IdPar2   ,C,LenIdPar(),0  picture PIC_ID ;
                                pick PickPar(NIL,TIL->IdPar2)
ddFld MatchList ,C,200,0 when TilIsOpen() ;
                         pick TilPickMatch(TIL->MatchList)
ddFld Date1     ,D, 8,0 when TilIsOpen()
ddFld Etat      ,C, 1,0 when .f. // pick PickDbcCode("TILSTAT.DBC",TIL->Status)
ddFld SubMont   ,T,LenMont(),0 GET_MONTANT valid ValSubMont() when TilIsOpen()
ddFld SubCount  ,N,4,0 valid ValSubCount() when TilIsOpen()
ddFld SkipMonth ,N,3,0 when TilIsOpen()
ddFld Bemerk    ,C,30,0
ddFld Mont      ,T,LenMont(),0 GET_MONTANT valid ValSubMont() when TilIsOpen()
ddFld Updated   ,D, 8,0 when .f.
action b key K_ENTER   prompt "~Inhalt         [Enter]" ;
         block TilTllEdit()
action b key K_CTRL_F2 prompt "~Registrieren [Ctrl-F2]" ;
         block TilClose()
ddEndDef()
RETURN b

**
** TLL -
**
FUNCTION oTll
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b  ;
    name TLL ;
    predelete .f. ;
    create DDCREATE_FAIL
ddIndex b on TLL->IdTil+dtos(TLL->Date)
ddFld IdTil     ,C, LEN_IDDOC,0
ddFld Date     ,D, 8,0
ddFld Mont     ,T,LenMont(),0 GET_MONTANT
ddFld Ist      ,T,LenMont(),0 GET_MONTANT when .f.
ddFld IstNZ    ,T,LenMont(),0 GET_MONTANT when .f.
ddFld IstAZ    ,T,LenMont(),0 GET_MONTANT when .f.
ddEndDef()
RETURN b


FUNCTION TilWait(wwin)
local b := oTll()
open area b
  ddSetOrder(1)
  edit data b key    TLL->IdTil ;
              value  TIL->IdTil ;
              mode wait ;
              window wwin ;
              query "TLLTIL"
close area
RETURN NIL


FUNCTION ParTilEdit
RETURN DbfEdit(;
  {oTil(),oPar()},;
  "Tilgungspl„ne fr " + trim(ParName()),;
  "TILPAR",;
  NIL,;
  NIL,;
  PAR->IdPar,;
  "TIL->IdPar";
)

FUNCTION TilIsOpen
// RETURN empty(TIL->Closed)
RETURN (TIL->Etat == DocStatOpen())
// RETURN !HasRecords(oTll(),1,"TLL->IdTil",TIL->IdTil)

FUNCTION TilTllEdit
if TilIsOpen()
  RETURN .f. if ! TilClose()
endif
if TIL->Updated != UserDate()
  if ddRecLock()
    if TilUpdate()
      TIL->Updated := UserDate()
    endif
    unlock record
  endif
endif
RETURN DbfEdit(;
  {oTll(),oTil(),oPar()},;
  "Inhalt Tilgungsplan " + ltrim(TIL->IdTil),;
  "TLLTIL",;
  NIL,;
  NIL,;
  TIL->IdTil,;
  "TLL->IdTil";
)


FUNCTION TilCreate()
local aBuf := CopyRec()
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
TIL->IdTil := DbfOnBottom(oTil(),1,"str(val(TIL->IdTil)+1,6,0)","     1")
if indexord() == 2
  TIL->IdPar := ddKeyValue()
endif
TIL->Date  := UserDate()
TIL->Date1 := UserDate()
TIL->SkipMonth := 1
TIL->SubMont := ntom(100)
TIL->Etat := DocStatOpen()
RETURN DDCREATE_FULL

*FUNCTION TllPreDelete()
*RETURN .f. if ! Confirm("Alle Raten l”schen?")
*RETURN .f. if ! TilTllDelete()
*ddSendKey(K_ALT_F5) // ddGoTop()
*RETURN .f.

**
** TilPostEdit()
**
FUNCTION TilPostEdit()
if empty(TIL->IdPar)
  SetMsg("Partner : darf nicht leer sein")
  RETURN .f.
endif
RETURN .t.


FUNCTION TilPickMatch()
local nMont := 0
local i
local aIml
local a := {}
local cMatchList := ""
local lOkay
if empty(TIL->IdPar)
  SetMsg("Partner : darf nicht leer sein")
  RETURN NIL
endif
#ifdef DEF_MVI
  MviSetFilter( ;
    BUTTON_ON, NIL, ;
    "FFO",space(LenIdJnl()), ;
    space(LenIdDoc()), space(LenIdDoc()), ;
    " ", NIL, ;
    space(LEN_PERIODE), ;
    TIL->IdPar ;
  )
  RETURN NIL if (aIml := MviLnCollect( {||.t.}, .f. ) ) == NIL
  RETURN "" if len(aIml) == 0
  for i := 1 to len(aIml)
    aCollect(a, { aIml[i][IML_MATCH], val(aIml[i][IML_MONT]) } )
    nMont += val(aIml[i][IML_MONT])
    if i > 1
      cMatchList += " "
    endif
    cMatchList += aIml[i][IML_MATCH]
  next i
#endif
TIL->Mont := ntom(nMont)
ValSubMont()
RETURN cMatchList



FUNCTION TilClose
local lOkay := .f.
RETURN .f. if ! ddRecLock()
if TIL->Etat == DocStatOpen()
  if Confirm("Raten generieren ?")
    if TilTllGenerate()
      TIL->Etat := DocStatClosed()
      // TIL->Closed := UserDate()
      TIL->Updated := ctod("")
      lOkay := .t.
    endif
  endif
else
  if Confirm("Alle Raten l”schen?")
    if TilTllDelete()
      // TIL->Closed := ctod("")
      TIL->Etat := DocStatOpen()
      lOkay := .t.
    endif
  endif
endif
unlock record
RETURN lOkay



STATIC FUNCTION TilTllGenerate()
local nSubMont
local nCount := 0
local dDate := TIL->Date1
local nMont := val(TIL->Mont)
local lOkay := .f.
local nLaufzeit := TIL->SubCount * TIL->SkipMonth / 12
// RETURN .f. if empty(TIL->MatchList)
if abs(nMont) < Tolerance(SetDecPos())
  SetMsg("Betrag darf nicht leer sein !")
  RETURN .f.
endif
if TIL->SkipMonth < 1
  SetMsg("Rhythmus darf nicht 0 sein !")
  RETURN .f.
endif
RETURN .f. if ! ValSubMont()
if nLaufzeit > 20
  SetMsg("Maximale Laufzeit 20 Jahre !")
else
  open area oTll()
    lOkay := .t.
    do while lOkay .and. nMont > 0
      nSubMont := min(nMont,val(TIL->SubMont))
      if dbAddRec()
        TLL->IdTil := TIL->IdTil
        TLL->Date := dDate
        TLL->Mont := ntom(nSubMont)
        unlock record
      else
        lOkay := .f.
      endif
      nMont -= nSubMont
      dDate := SkipMonth(dDate,TIL->SkipMonth)
      nCount += 1
    enddo
  close area
endif
RETURN .f. if ! lOkay
SetMsg(ntrim(nCount) + " Eintr„ge wurden erzeugt.")
RETURN .t.

FUNCTION TilTllDelete
local lOkay := .f.
MsgDisplay(MsgWorking())
open area oTll()
  lOkay := .t.
  softseek TIL->IdTil
  do while TLL->IdTil == TIL->IdTil .and. ! eof()
    if ddRecLock()
      delete
      unlock record
    else
      lOkay := .f.
    endif
    softseek TIL->IdTil
  enddo
close area
MsgDisplay("")
RETURN lOkay


STATIC FUNCTION ValSubCount()
RETURN .t. if val(TIL->Mont) == 0
if TIL->SubCount <= 0
  SetMsg("Mindestens 1 Rate erforderlich !")
  RETURN .f.
endif
TIL->SubMont := ntom(TIL->Mont / TIL->SubCount)
RETURN ph_refresh()

STATIC FUNCTION ValSubMont()
RETURN .t. if val(TIL->Mont) == 0
if abs(val(TIL->SubMont)) < Tolerance(SetDecPos())
  SetMsg("Ratenbetrag darf nicht Null sein !")
  RETURN .f.
endif
TIL->SubCount := int(val(TIL->Mont) / val(TIL->SubMont)) + 1
RETURN ph_refresh()

STATIC FUNCTION ValTilMont()
RETURN .t. if val(TIL->Mont) == 0
RETURN ValSubCount()



#define TLL_DATE  1
#define TLL_IST   2
#define TLL_ISTNZ 3
#define TLL_ISTAZ 4
#define TLL_ALEN  4

FUNCTION TilUpdate
local xlMviFilter := "JnlIdGrj(MVI->IdJnl)=='TRE'"
local aTll := {}
local i
local lOkay := .f.
local nField
local lFound
local nMont
MsgDisplay(MsgWorking())
open area oTll()
  lOkay := .t.
  softseek TIL->IdTil
  do while ! eof() .and. TLL->IdTil == TIL->IdTil
    aadd(aTll, { ;
      TLL->Date,;
      0,;
      0,;
      0 ;
    }) // TLL_ALEN
    skip
  enddo
close area
RETURN .f. if ! lOkay
if len(aTll) == 0
  RETURN ! SetMsg("Tilgungsplan ist leer")
endif
lOkay := .f.
open area oMvi()
  lOkay := .t.
  ddSetOrder(ORD_MVI_PARDATE)
  softseek TIL->IdPar
  do while ! eof() .and. MVI->IdPar == TIL->IdPar
    if &xlMviFilter
      if MVI->Match $ TIL->MatchList
        nField := TLL_IST
      elseif empty(MVI->Match)
        nField := TLL_ISTNZ
      else
        nField := TLL_ISTAZ
      endif
      lFound := .f.
      if MVI->DC == DC_CREDIT
        nMont := val(MVI->Mont)
      else
        nMont := - val(MVI->Mont)
      endif
      for i := 1 to len(aTll)
        if MVI->Date2 <= aTll[i][TLL_DATE]
          aTll[i][nField] += nMont
          lFound := .t.
          exit
        endif
      next i
      if ! lFound
        lOkay := .f.
        SetMsg("Unkompletter Tilgungsplan!")
      endif
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay 
lOkay := .f.
open area oTll()
  lOkay := .t.
  for i := 1 to len(aTll)
    seek TIL->IdTil + dtos(aTll[i][TLL_DATE])
    if ddRecLock()
      TLL->Ist   := ntom(aTll[i][TLL_IST])
      TLL->IstNz := ntom(aTll[i][TLL_ISTNZ])
      TLL->IstAz := ntom(aTll[i][TLL_ISTAZ])
      unlock record
    else
      lOkay := .t.
    endif
  next i
close area
RETURN .f. if ! lOkay 
MsgDisplay("")
RETURN .t.



FUNCTION HasTil
RETURN .t.

#else

FUNCTION HasTil
RETURN .f.

#endif DEF_TIL


#ifdef DEF_GST

FUNCTION oGst
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name GST
ddIndex b on GST->IdGst
ddIndex b on GST->IdPar+dtos(GST->raus)
ddFld IdPar     ,C,LenIdPar(),0  picture PIC_ID ;
                                pick PickPar(NIL,GST->IdPar)
ddFld IdGst     ,C, 4,0
ddFld Name      ,C,40,0
ddFld rein      ,D, 8,0
ddFld raus      ,D, 8,0
ddEndDef()
RETURN b

#endif DEF_GST
