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

#ifdef DEF_CODA

#define CODA_OKAY     0
#define CODA_RECLOCK  1
#define CODA_ABORT    2
#define CODA_IDDEV    3
#define CODA_STRUCT   4



**
** CPT - comptes
**
FUNCTION oCpt()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b    ;
  name CPT ;
  predelete CodaPreDelete()  ;
  wait {|win| CptWait(win)}
ddIndex b on CPT->NoCpt format {|x|x}
* ddIndex b on CPT->IdPar format {|x|GetIdPar(x)}
ddFld NoCpt      , C , 12, 0 // , "Kontonummer"
ddFld ParNames ,C,80,0 picture "@k@s30"
* ddFld IdPar    ,C, LenIdPar(),0  GET_PAD ;
*                         pick PickPar( ;
*                           NIL, ;
*                           CPT->IdPar)
ddFld Solde2     , C , 17, 0
ddFld Date2      , D ,  8, 0
ddFld IdDev      , C ,  3, 0 // , "ISO Kode Devise"
ddFld Inhaber  ,C,80,0 picture "@k@s20"
action b key K_ENTER   prompt "~Inhalt [Enter]" ;
         block CptExtEdit(CPT->NoCpt)
ddEndDef()
RETURN b


FUNCTION CodaPreDelete()
RETURN .f. if ! USRATTR_E $ UsrAttrib()
RETURN ConfirmDelete()

**
** EXT - extraits de compte
**
FUNCTION oExt()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b    ;
  name EXT ;
  predelete CodaPreDelete()  ;
  wait {|win| ExtWait(win)}
ddIndex b on EXT->NoCpt+EXT->NoExt
ddFld NoCpt      , C , 12, 0 // , "Kontonummer"
ddFld NoExt      , C ,5+3, 0 // , "Auszugsnummer"
ddFld NoSeq      , C ,  3, 0 // , "Sequenznummer"
ddFld Solde1     , C , 17, 0 // , "Alter Saldo"
ddFld Date1      , D ,  8, 0 // , "Datum des alten Standes"
ddFld Solde2     , C , 17, 0 // , "Aktueller Saldo"
ddFld Date2      , D ,  8, 0 // , "Datum des akt. Standes"
ddFld DateCrea   , D ,  8, 0 // , "Datum des Erschaffens"
ddFld IdDev      , C ,  3, 0 // , "ISO Kode Devise"
ddFld NoSeqExt   , C ,  3, 0 // Erweiterte Sequenznummer
action b key K_ENTER   prompt "~Inhalt        [Enter]" ;
         block ExtMvmEdit(EXT->NoCpt,EXT->NoExt)
ddEndDef()
RETURN b


**
** MVM - mouvements
**
FUNCTION oMvm()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b    ;
  name MVM ;
  predelete CodaPreDelete()  ;
  // wait {|win| MvmWait(win)}
ddIndex b on MVM->NoCpt+MVM->NoExt+MVM->NoMvm
ddFld NoCpt      , C , 12, 0 // Kontonummer
ddFld NoExt      , C ,5+3, 0 // Auszugsnummer
ddFld NoMvm      , C ,  4, 0 // Nummer der Bewegung
ddFld NoDetail   , C ,  4, 0 // Nummer des Details
ddFld NoRef      , C , 13, 0 // Referenznummer
ddFld ExtNoRef   , C ,  8, 0 // Erweiterte Referenznummer
ddFld Montant    , C , 17, 0 // Betrag der Bewegung
ddFld DatVal     , D ,  8, 0 // Wertdatum
ddFld CodeOp     , C ,  8, 0 // Kode der Bewegung
                             // (substr(CodeOp,2,4) -> CDO.DBF
ddFld TypCom     , C ,  1, 0 // Typ der Mitteilung
ddFld Communic   , C ,106, 0 // Mitteilung
ddFld DatCompt   , D ,  8, 0 // Buchungsdatum
ddFld NoSeqExt   , C ,  3, 0 // Erweiterte Sequenznummer
ddFld NoRefCli   , C , 26, 0 // Referenznummer des Kunden
ddFld CptContre  , C , 14, 0 // Konto der Gegenpartei
ddFld IdContre   , C , 78, 0 // Gegenpartei
ddFld DateCrea   , D ,  8, 0 // Datum des Erschaffens
* action b key K_ENTER   prompt "~Inhalt        [Enter]" ;
*          block MvmInfEdit(MVM->NoCpt,MVM->NoExt,MVM->NoCpt)
ddEndDef()
RETURN b


**
** INF - info mouvements
**
FUNCTION oInf()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b    ;
  name INF ;
  predelete CodaPreDelete()
ddIndex b on INF->NoCpt+INF->NoExt+INF->NoMvm+INF->NoInf
ddFld NoCpt      , C , 12, 0 //  Kontonummer
ddFld NoExt      , C ,5+3, 0 //  Auszugsnummer
ddFld NoMvm      , C ,  4, 0 //  Nummer der Bewegung
ddFld NoInf      , C ,  4, 0 //  Nummer der Information
ddFld TypCom     , C ,  1, 0 //  Typ der Information
ddFld Communic   , C ,254, 0 //  Information
ddFld DateCrea   , D ,  8, 0 //  Datum des Erschaffens
ddEndDef()
RETURN b


**
** CDO - aus CODECODA.DBF
**
FUNCTION oCdo()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b    ;
  name CDO
ddIndex b on CDO->IdCdo format {|x|x}
ddFld IdCdo      ,C , 4, 0 // , "Kontonummer"
ddFld Name       ,C, 25,0
// action b key K_ENTER   prompt MSG_GraArtEdit block GraArtEdit()
ddEndDef()
RETURN b


**
**
**
FUNCTION CodaImport(cWildCard)
local cFileName
local aDir := directory(cWildCard)
local i
local nError
local fd
local lOkay := .f.
if len(aDir) == 0
  SetMsg(cWildCard + MsgDosError())
else
  open area oCpt(), oExt(), oMvm(), oInf()
    lOkay := .t.
    for i := 1 to len(aDir)
      cFileName := left(cWildCard,rat("\",cWildCard)) + aDir[i][F_NAME]
      do while (fd := fopen(cFileName)) == -1
        if ! Confirm( ;
          cFileName + MsgDosError(ferror()), ;
          MsgRetry() ;
        )
          lOkay := .f.
        endif
      enddo
      if lOkay
        MsgDisplay("Importing " + cFileName + "...")
        nError := Coda_f_import(fd)
        if nError != CODA_OKAY
          SetMsg("CODA error " + ntrim(nError))
          lOkay := .f.
        endif
        fclose(fd)
      endif
      if lOkay
        SendConsole("CODA import " + cFileName + " : okay")
        delete file (cFileName)
      else
        exit
      endif
    next i
    select CPT
  close area
endif
RETURN lOkay






**
**
** Siehe g:\doc\coda\coda.pdf : Lay-out 128 (?)
**
STATIC FUNCTION Coda_f_Import(fd)
local lOkay := .t.
local dDateCrea
local cNoCpt
local cNoExt
local cNoMvm
local cYear // NoExt wird in TIM mit dem Jahr pr„fixiert
local lSkip := .f.
local nMont
local dev
local cLine
* local cIdPar
* local nNew := 0
do while (cLine:=freadline(fd)) != NIL
  if left(cLine,1) == "0" // header
    dDateCrea := cdtod(substr(cLine,6,6))
    cYear := str(year(dDateCrea),4)
    lSkip := .f.
    loop
  endif
  if lSkip
    loop
  endif

  if left(cLine,1) == "1" // ancien solde
    cNoCpt := substr(cLine,6,12)
    cNoExt := cYear + "/" + substr(cLine,3,3)
    * cNoSeq := substr(cLine,126,3)
    select CPT
    seek cNoCpt
    if eof()
      *if Confirm(cNoCpt + " : Kontonummer anlegen (J/N)")
       if dbAddRec()
         * nNew += 1
         CPT->NoCpt := cNoCpt
         unlock record
       else
         RETURN CODA_RECLOCK
       endif
      *else
      * lSkip := .t.
      *endif
      * 20031124 jetzt nicht mehr : loop
    endif
    * if lSkip
    *   loop
    * endif
    select EXT
    seek cNoCpt+cNoExt in EXT
    if eof()
      if dbAddRec()
        EXT->NoCpt  := cNoCpt
        EXT->NoExt  := cNoExt
        EXT->NoSeq  := substr(cLine,126,3)
        EXT->IdDev  := substr(cLine,19,3)
        RETURN CODA_IDDEV if (dev := DevLocate(EXT->IdDev)) == NIL
        nMont := val(substr(cLine,44,12))
        nMont += val(substr(cLine,56,3)) / 1000
        if substr(cLine,43,1) == "1"
          nMont := - nMont
        endif
        nMont := round(nMont,dev[DEV_DECPOS])
        EXT->Solde1 := str(nMont,17,dev[DEV_DECPOS])
        EXT->Date1  := cdtod(substr(cLine,59,6))
        EXT->DateCrea  := dDateCrea
        unlock record
      else
        RETURN CODA_RECLOCK
      endif
    else
      SendConsole(cNoCpt+cNoExt + " : Daten doppelt eingelesen")
      if EXT->DateCrea != dDateCrea
        SendConsole( ;
          "  "+cNoCpt+cNoExt + " : " + ;
          dtoc(EXT->DateCrea) + " <> " + dtoc(dDateCrea) ;
        )
      endif
      lSkip := .t.
      // also alle Zeilen bis zum n„chsten Header ignorieren
    endif

  elseif left(cLine,1) == "2" // mouvement
    RETURN CODA_STRUCT if dev == NIL
    if substr(cLine,2,1) == "1" // partie 1 du mouvement
      * 20060214
      cNoMvm    := substr(cLine,3,4)
      select MVM
      if MVM->NoMvm!=cNoMvm.or.MVM->NoCpt!=cNoCpt.or.MVM->NoExt!=cNoExt
        if dbAddRec()
          MVM->NoCpt := cNoCpt
          MVM->NoExt := cNoExt
          MVM->NoMvm    := cNoMvm
          MVM->NoDetail := substr(cLine,7,4)
          MVM->NoRef    := substr(cLine,11,13)
          MVM->ExtNoRef := substr(cLine,24,8)
          nMont := val(substr(cLine,33,12))
          nMont += val(substr(cLine,45,3)) / 1000
          if substr(cLine,32,1) == "1"
            nMont := - nMont
          endif
          nMont := round(nMont,dev[DEV_DECPOS])
          MVM->Montant := str(nMont,17,dev[DEV_DECPOS])
          MVM->DatVal   := cdtod(substr(cLine,48,6))
          MVM->CodeOp   := substr(cLine,54,8)
          MVM->TypCom   := substr(cLine,62,1)
          MVM->Communic := substr(cLine,63,53)
          MVM->DatCompt := cdtod(substr(cLine,116,6))
          MVM->NoSeqExt := substr(cLine,122,3)
          unlock record
        else
          RETURN CODA_RECLOCK
        endif
      endif
    elseif substr(cLine,2,1) == "2" // partie 2 du mouvement
      RETURN CODA_STRUCT if alias() != "MVM"
      if ddRecLock()
        MVM->Communic := left(MVM->Communic,53) + substr(cLine,11,53)
        MVM->NoRefCli := substr(cLine,64,26)
        unlock record
      else
        RETURN CODA_RECLOCK
      endif
    elseif substr(cLine,2,1) == "3" // partie 3 du mouvement
      RETURN CODA_STRUCT if alias() != "MVM"
      if ddRecLock()
        MVM->CptContre := substr(cLine,11,12)
        MVM->IdContre  := substr(cLine,48,78)
        unlock record
      else
        RETURN CODA_RECLOCK
      endif
    endif

  elseif left(cLine,1) == "3" // info
    RETURN CODA_STRUCT if substr(cLine,3,4) != cNoMvm
    if substr(cLine,2,1) == "1" // partie 1 de l'info
      select INF
      if dbAddRec()
        INF->NoCpt  := cNoCpt
        INF->NoExt  := cNoExt
        INF->NoMvm  := cNoMvm
        INF->NoInf  := substr(cLine,7,4)
        INF->TypCom := substr(cLine,40,1)
        INF->Communic := substr(cLine,41,73)
        unlock record
      else
        RETURN CODA_RECLOCK
      endif
    elseif substr(cLine,2,1) == "2" // partie 2 de l'info
      RETURN CODA_STRUCT if alias() != "INF"
      if ddRecLock()
        INF->Communic := left(INF->Communic,73) + substr(cLine,11,105)
        unlock record
      else
        RETURN CODA_RECLOCK
      endif
    elseif substr(cLine,2,1) == "3" // partie 3 de l'info
      RETURN CODA_STRUCT if alias() != "INF"
      if ddRecLock()
        INF->Communic := left(INF->Communic,178) + substr(cLine,11,90)
        unlock record
      else
        RETURN CODA_RECLOCK
      endif
    endif

  elseif left(cLine,1) == "4" // message libre (non utilis‚)
  elseif left(cLine,1) == "5" // (non utilis‚)
  elseif left(cLine,1) == "6" // (non utilis‚)
  elseif left(cLine,1) == "7" // (non utilis‚)

  elseif left(cLine,1) == "8" // nouveau solde
    select EXT
    RETURN CODA_STRUCT if EXT->NoCpt != substr(cLine,5,12)
    if ddRecLock()
      EXT->NoSeqExt := substr(cLine,2,3)
      nMont := val(substr(cLine,43,12))
      nMont += val(substr(cLine,55,3)) / 1000
      if substr(cLine,42,1) == "1"
        nMont := - nMont
      endif
      nMont := round(nMont,dev[DEV_DECPOS])
      EXT->Solde2 := str(nMont,17,dev[DEV_DECPOS])
      EXT->Date2  := cdtod(substr(cLine,58,6))
      unlock record
      select CPT
      if ddRecLock()
        CPT->Solde2 := str(nMont,17,dev[DEV_DECPOS])
        CPT->Date2  := cdtod(substr(cLine,58,6))
        CPT->IdDev  := dev[DEV_IDDEV]
        unlock record
      endif
    else
      RETURN CODA_RECLOCK
    endif

  elseif left(cLine,1) == "9" // trailer record

  endif
enddo
RETURN CODA_OKAY


FUNCTION cdtod(c)
local cDate := left(c,2) + "."
cDate += substr(c,3,2) + "."
cDate += substr(c,5,2)
RETURN ctod(cDate)


*FUNCTION CodaCptExist(cNoCpt)
*RETURN .t. if ! found()
*RETURN lExist

**
** CptWait()
**
FUNCTION CptWait(wwin)
local b
local cNoCpt := CPT->NoCpt
if nextkey() != 0
  RETURN NIL
elseif wwin[WIN_WAITKEY] == 1
  RETURN CptExtEdit(cNoCpt,wwin)
endif
RETURN .f.


**
** CptExtEdit()
**
FUNCTION CptExtEdit(cNoCpt,wwin)
local b := oExt()
local nMode := if(wwin == NIL,DDMODE_FIND,DDMODE_WAIT)
* RETURN ClearWaitWin(wwin) if jnl == NIL
open area b,oCpt()
  seek cNoCpt in CPT
  softseek cNoCpt
  edit data b  ;
            key FIELD->NoCpt ;
            value cNoCpt  ;
            mode (nMode)   ;
            window wwin ;
            start bottom ;
            query ("EXTCPT")
close area
RETURN NIL

**
** ExtWait()
**
FUNCTION ExtWait(wwin)
local b
local cNoCpt := EXT->NoCpt
local cNoExt := EXT->NoExt
if nextkey() != 0
  RETURN NIL
elseif wwin[WIN_WAITKEY] == 1
  RETURN ExtMvmEdit(cNoCpt,cNoExt,wwin)
endif
RETURN .f.


**
** ExtMvmEdit()
**
FUNCTION ExtMvmEdit(cNoCpt,cNoExt,wwin)
local nMode := if(wwin == NIL,DDMODE_FIND,DDMODE_WAIT)
local b := oMvm()
* RETURN ClearWaitWin(wwin) if jnl == NIL
open area b
  softseek cNoCpt+cNoExt
  edit data b  ;
            key FIELD->NoCpt + FIELD->NoExt ;
            value cNoCpt+cNoExt  ;
            mode (nMode)   ;
            window wwin ;
            start top ;
            query ("MVMEXT")
close area
RETURN NIL

**
** MvmWait()
**
*FUNCTION MvmWait(wwin)
*local b
*local cNoCpt := MVM->NoCpt
*local cNoExt := MVM->NoExt
*local cNoMvm := MVM->NoMvm
*if nextkey() != 0
*  RETURN NIL
*elseif wwin[WIN_WAITKEY] == 1
*  RETURN MvmInfEdit(cNoCpt,cNoExt,cNoMvm,wwin)
*endif
*RETURN .f.
*
*
***
*** MvmInfEdit()
***
*FUNCTION MvmInfEdit(cNoCpt,cNoExt,cNoMvm,wwin)
*local nMode := if(wwin == NIL,DDMODE_FIND,DDMODE_WAIT)
*local b := oInf()
** RETURN ClearWaitWin(wwin) if jnl == NIL
*open area b
*  softseek cNoCpt+cNoExt+cNoMvm
*  edit data b  ;
*            key FIELD->NoCpt + FIELD->NoExt + FIELD->NoMvm;
*            value cNoCpt+cNoExt+cNoMvm  ;
*            mode (nMode)   ;
*            window wwin ;
*            start top ;
*            query ("INFMVM")
*close area
*RETURN NIL

**
** CptAppend() : called from CODAIMP.ACT
**
*FUNCTION CptAppend(cNoCpt,cIdPar)
*local lOkay := .f.
*cNoCpt := trim(cNoCpt)
*if len(cNoCpt) != 12
*  SetMsg("Partner " + cIdPar + " : ungltige Kontonummer " + cNoCpt)
*  RETURN .f.
*endif
*open area oCpt()
*  lOkay := .t.
*  seek cNoCpt
*  if eof()
*    if dbAddRec()
*      CPT->IdPar := cIdPar
*      CPT->NoCpt := cNoCpt
*      unlock record
*    else
*      lOkay := .f.
*    endif
*  else
*    if CPT->IdPar != cIdPar
*      lOkay := Confirm( ;
*        cNoCpt+" : Konto bereits fr anderen Partner als "+cIdPar,;
*        MsgContinue();
*      )
*    endif
*  endif
*close area
*RETURN lOkay

FUNCTION SetCptParName(cNoCpt,cName)
local lOkay := .f.
local cParNames
cNoCpt := trim(cNoCpt)
open area oCpt()
  lOkay := .t.
  seek strtran(cNoCpt,"-","")
  if ! eof()
    if ddRecLock()
      if empty(CPT->ParNames)
        cParNames := cName
      else
        cParNames := trim(CPT->ParNames) + ", " + cName
      endif
      CPT->ParNames := cParNames
      if trim(CPT->ParNames) != trim(cParNames)
        lOkay := Confirm(cNoCpt+" : '"+trim(cName)+;
          "' passt nicht mehr in CPT->ParNames rein",MsgContinue()," ")
      endif
      unlock record
    else
      lOkay := .f.
    endif
  endif
close area
RETURN lOkay

FUNCTION CodaEdit(aComptes)
local i
local a := {}
for i := 1 to len(aComptes)
  if ! empty(aComptes[i])
    if DbfPeek(oCpt(),strtran(aComptes[i],'-'),".t.",.f.)
      DictAddItem(a, padr(aComptes[i],14))
    endif
  endif
next i
if len(a) == 0
  SetMsg(trim(ParName())+" hat keine CODA-Konten")
  RETURN .f.
endif
browse array a ;
  using {|x|x+" "+DbfPeek(oCpt(),strtran(x,'-'),;
            "padr(ParNames,20)+' '+Solde2+' '+Iddev+' '+dtoc(Date2)",;
            space(44);
        )} ;
  title ("CODA-Bankkonten von "+trim(PAR->Firme)) ;
  enter {|x|CptExtEdit(strtran(x,"-"))}
RETURN .t.

#else

FUNCTION CodaDummy
RETURN NIL

#endif DEF_CODA


