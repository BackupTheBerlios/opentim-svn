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

#include "LIB.CH"
#include "dbstruct.ch"

#ifdef DEF_DATANORM

static slNew
static snLine
static scInFile
static a
static scIdDev
static scIdArt
static scIdGra
static scIdLng
static scLine
static fd
static saStdBuf
static sdDate

FUNCTION dn_import(cInPath,cIdLng,lAgain,lWrg)
local lOkay := .f.
local nLine := 0
scIdLng := cIdLng
default lAgain to .t. // ob ein bestehender Artikel auch durch
                      // Neunanlagen berschrieben werden darf.
default lWrg to .t.
** Artikelstammdaten aus DATANORM.001
scInFile := cInPath+"\DATANORM.001"
RETURN .f. if ! dn_start()
open area oArt()
  seek repl("0",LenIdArt())
  saStdBuf := CopyRec()
  lOkay := .t.
  do while lOkay .and. (scLine != NIL)
    scIdArt := a[3]
    do while (scLine != NIL .and. a[3] == scIdArt)
      lOkay := .f.
      if a[1]=="A" .and. a[2]=="N" .and. empty(a[5])
        // Sonderfall AMG :
        // Artikel ohne Beschreibung werden einfach ignoriert...
        do while (scLine != NIL .and. a[3] == scIdArt)
          dn_readline()
        enddo
        lOkay := .t.
        exit
      endif
      seek padr(scIdArt,LenIdArt())
      if eof()
        if a[2] == "N" // Neuanlegung
          if dbAddRec()
            PasteRec(saStdBuf)
            ART->IdArt := a[3]
            ART->Attrib := strtran(ART->Attrib,"H","")
            lOkay := dn_getart()
            unlock record
            dn_readline()
          endif
        endif
      else
        if a[2] == "A" .or. (a[2] == "N" .and. lAgain)
          if ddRecLock()
            lOkay := dn_getart()
            unlock record
            dn_readline()
          endif
        elseif a[2] == "L"
          if ArtPreDelete(.t.)
            if ddRecLock()
              lOkay := .t.
              delete
              unlock record
              do while (scLine != NIL .and. a[3] == scIdArt)
                dn_readline()
              enddo
            endif
          endif
        endif
      endif
      if ! lOkay
        if dn_warning(SetMsg())
          lOkay := .t.
        endif
      endif
    enddo
  enddo
close area
fclose(fd)

if lWrg
  ** Warengruppen aus DATANORM.WRG
  if ! lOkay .or. scLine == NIL
    RETURN .f. if ! Confirm("Importer les groupes d'articles ?")
    lOkay := .t.
  endif
  scInFile := cInPath+"\DATANORM.WRG"
  RETURN .f. if ! dn_start()
  open area oGra()
    lOkay := .t.
    do while lOkay .and. (scLine != NIL)
      scIdGra := a[3]
      do while (scLine != NIL .and. a[3] == scIdGra)
        lOkay := .f.
        if a[1]=="S" .and. empty(a[4])
          // Sonderfall AMG :
          // Warengruppen ohne Beschreibung werden einfach ignoriert...
          do while (scLine != NIL .and. a[3] == scIdGra)
            dn_readline()
          enddo
          lOkay := .t.
          exit
        endif
        seek padr(scIdGra,LenIdGra())
        if eof()
          if dbAddRec()
            GRA->iGra := scIdGra
            lOkay := dn_getgra()
            unlock record
            dn_readline()
          endif
        else
          if ddRecLock()
            lOkay := dn_getgra()
            unlock record
            dn_readline()
          endif
        endif
        if ! lOkay
          if dn_warning(SetMsg())
            lOkay := .t.
          endif
        endif
      enddo
    enddo
  close area
  fclose(fd)
endif


** Einkaufspreise aus DATPREIS.001
if ! lOkay .or. scLine == NIL
  RETURN .f. if ! Confirm("Importer prix d'achat ?")
  lOkay := .t.
endif
scInFile := cInPath+"\DATPREIS.001"
RETURN .f. if ! dn_start()
open area oArt()
  lOkay := .t.
  do while lOkay .and. (scLine != NIL)
    scIdArt := a[3]
    do while (scLine != NIL .and. a[3] == scIdArt)
      lOkay := .f.
      seek padr(scIdArt,LenIdArt())
      if eof()
        lOkay := .t.
        dn_readline()
      else
        if ddRecLock()
          lOkay := dn_getart()
          unlock record
          dn_readline()
        endif
      endif
      if ! lOkay
        if dn_warning(SetMsg())
          lOkay := .t.
        endif
      endif
    enddo
  enddo
close area
fclose(fd)


RETURN lOkay

STATIC PROCEDURE dn_readline()
if (scLine := freadline(fd)) != NIL
  MsgDisp2(ntrim(++snLine))
  if TaskInter()
    scLine := NIL
    RETURN
  endif
  a := ListAsArray(scLine,";")
  if len(a) < 3
    dn_warning("invalid line (minimum 3 fields)")
    scLine := NIL
  endif
endif
RETURN




STATIC FUNCTION dn_getart()
if a[3] != scIdArt
  RETURN ! SetMsg("internal error 1")
endif
if a[1] == "A"
  if a[4] != "00"
    RETURN !SetMsg("field 4 is not '00'...")
  endif
  if len(a) != 14
    RETURN !SetMsg(ntrim(len(a))+" instead of 13 fields")
  endif
  if scIdLng == MemLang2
    ART->Name2 := a[5]
    ART->Text2 := a[6]
  else
    ART->Name1 := a[5]
    ART->Text1 := a[6]
  endif
  ART->PE := a[8]
  ART->IdUnt := a[9]
  // if a[7] == "1" // Bruttopreis
    // ART->TVAC := ntom(Dev2Db(scIdDev,PerActive(),val(a[10])/100),ArtPuDecPos())
    // ArtTvacValidate()
  // elseif a[7] == "2" // Nettopreis
    ART->Prix1 := ntom(Dev2Db(scIdDev,PerActive(),val(a[10])/100),ArtPuDecPos())
    ArtP1Validate()
  // else
    // RETURN !SetMsg("field 7 must contain 1 or 2")
  // endif
  ART->Code3 := a[11] // Rabattgruppe
  ART->iGra := a[12] // Hauptwarengruppe
  RETURN .t.
elseif a[1] == "B"
  if len(a) != 17
    RETURN !SetMsg(ntrim(len(a))+" instead of 17 fields")
  endif
  ART->RefExt := a[4]
  RETURN .t.
elseif a[1] == "P"
  // if a[4] == "2" // Nettopreis
    ART->PrixR := ntom(Dev2Db(scIdDev,PerActive(),val(a[5])/100),ArtPuDecPos())
  // else
  //  RETURN !SetMsg("field 4 of a P record must contain 2")
  // endif
  RETURN .t.
endif
RETURN .f.


STATIC FUNCTION dn_getgra()
if a[3] != scIdGra
  RETURN ! SetMsg("internal error 2")
endif
if scIdLng == MemLang2
  GRA->Name2 := a[4]
else
  GRA->Name1 := a[4]
endif
RETURN .t.


STATIC FUNCTION dn_start()
snLine := 0
if (fd := fopen(scInFile)) == -1
  RETURN ! SetMsg(scInFile+MsgDosError(ferror()))
endif
MsgDisplay("Import "+scInFile+"...")
if (scLine := freadline(fd)) != NIL .and. left(scLine,1) == "V"
  scIdDev := substr(scLine,126,3)
  sdDate := ntod( ;
    val(substr(scLine,7,2)),;
    val(substr(scLine,5,2)),;
    val(substr(scLine,3,2));
  )
else
  RETURN !SetMsg("format de fichier invalide")
endif
RETURN .f. if ! DevExist(scIdDev)
dn_readline()
RETURN .t.


STATIC FUNCTION dn_warning(cText)
RETURN Confirm(scInFile+":"+ntrim(snLine)+": "+cText,MsgContinue())

#endif DEF_DATANORM


FUNCTION utos(c)
local r
local i
RETURN "NIL" if c == NIL
RETURN '"' + c + '"' if valtype(c) $ "CM"
if valtype(c) == "N"
  r := ltrim(str(c,20,2))
  if "." $ r
    do while right(r,1) == "0"
      r := left(r,len(r)-1)
    enddo
    if right(r,1) == "."
      r := left(r,len(r)-1)
    endif
  endif
  RETURN r
endif
RETURN "ctod('"+dtoc(c)+"')" if valtype(c) == "D"
RETURN (if(c,".t.",".f.")) if valtype(c) == "L"
if valtype(c) == "A"
  r := "{"
  for i := 1 to len(c)
    if i > 1
      r += ", "
    endif
    r += utos(c[i])
  next i
  r += "}"
  RETURN r
endif
RETURN valtype(c)


