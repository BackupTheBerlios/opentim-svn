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

static cIgnore  := BUTTON_ON
static cExact   := BUTTON_OFF
* static cSoundEx := BUTTON_OFF
* static scIndex  := " "
static suSeekValue
static soCol
static snWidth
static snLastStep := 1
* static scLast := NIL
* static snLast := NIL
* static sdLast := NIL

#ifdef LG_FRENCH
  * #define MSG001  "Recherche impossible dans cette colonne"
  #define MSG002  "Recherche dans "
  #define MSG003  "Recherche sans succŠs."
  #define MSG004  "Recherche interrompue."
  #define MSG005  " Ignorer majuscules/minuscules"
  #define MSG006  "Valeur"
  #define MSG007  " Ne chercher qu'en d‚but du champ"
  #define MSG008  " Recherche phon‚tique"
#endif

#ifdef LG_GERMAN
  * #define MSG001  "'Suchen' unm”glich in dieser Kolonne"
  #define MSG002  "Suchen in "
  #define MSG003  "Suchbegriff wurde nicht gefunden."
  #define MSG004  "Suche wurde unterbrochen."
  * #define MSG005  " Groá-/Kleinschreibung ignorieren"
  #define MSG006  "Inhalt"
  * #define MSG007  " Nur am Anfang des Feldes vergleichen"
  * #define MSG008  " Suche nach Aussprache"
#endif

#ifdef LG_EN
  #define MSG002  "Search in "
  #define MSG003  "Search failed."
  #define MSG004  "Search has been aborted."
  #define MSG006  "Value"
#endif


**
** GetCdt()
**
FUNCTION GetCdt( b, ad )
local oCol
local col
local uCurrValue
local cPicture
local lReplace
local nKey
local cHeader
local ag
// RETURN .f. if ! Confirm("colPos is "+utos(b:colPos))
RETURN .f. if b:colPos > b:colCount
oCol := b:getColumn(b:colPos)
col := oCol:cargo
// [970516]
cHeader := col[COL_HEADER]
if col[COL_FLDHANDLE] == 0
  uCurrValue := &(col[COL_BLOCK])
  cPicture   := col[COL_PICTURE]
else
  ag := ad[AD_FIELDS][col[COL_FLDHANDLE]]
  uCurrValue := eval(ag[AG_BLOCK])
  cPicture  := ag[AG_PICTURE]
  default cHeader to ag[AG_NAME]
endif
* cHeader := fld:cargo[AG_HEADER]
* default cHeader to fld:name
soCol := col
lReplace := .T.
if suSeekValue != NIL
  if valtype(suSeekValue) == valtype(uCurrValue)
    if valtype(suSeekValue) == "C"
      if len(suSeekValue) == len(uCurrValue)
        lReplace := .f.
      endif
    endif
  endif
endif
if lReplace
  * suSeekValue := NIL
  suSeekValue := uCurrValue
endif
snWidth := len( transform(suSeekValue,"") ) + 11
if snWidth < 60
  snWidth := 60
endif
if snWidth > maxcol() - 2
  snWidth := maxcol() - 2
endif
open window (MSG002 + cHeader) size 3,snWidth  help EDITSEEK
do while .t.
  @ row(), col() say MSG006 get suSeekValue picture (cPicture)
  * WinCR()
  * @ row(), col() get cIgnore checkbox
  * @ row(), col() say MSG005
  * WinCR()
  * @ row(), col() get cExact  checkbox
  * @ row(), col() say MSG007
  * WinCR()
  * @ row(), col() get cSoundEx checkbox
  * @ row(), col() say MSG008
  nKey := ReadScr()
  exit
  WinHome()
enddo
close window
RETURN (nKey != K_ESC)

**
** ddEditNext()
**
FUNCTION ddEditNext(b,ad)
if suSeekValue != NIL
  ddSearch(b,ad,snLastStep)
endif
RETURN NIL

**
** ddSeekReset()
**
FUNCTION ddSeekReset()
suSeekValue := NIL
snLastStep  := 1
RETURN NIL

static FUNCTION ChkString(cTarget, cString)
* if cSoundEx == "X"
*   if soundex(cTarget) == soundex(cString)
*     RETURN .T.
*   endif
* endif
if cIgnore == "X"
  if cExact == "X"
    if upper(trim(cTarget)) = upper(trim(cString))
      RETURN .T.
    endif
  else
    if upper(trim(cString)) $ upper(cTarget)
      RETURN .T.
    endif
  endif
else
  if cExact == "X"
    if trim(cTarget) = trim(cString)
      RETURN .T.
    endif
  else
    if trim(cString) $ cTarget
      RETURN .T.
    endif
  endif
endif
RETURN .F.


**
** ddSearch()
**
FUNCTION ddSearch(b,ad,nStep)
local nRecNo := recno()
local fld
local cType
local bBlock
if soCol[COL_FLDHANDLE] == 0
  cType  := "C"
  bBlock := {|| &(soCol[COL_BLOCK]) }
else
  fld := ad[AD_FIELDS][soCol[COL_FLDHANDLE]]
  cType  := fld[AG_TYPE]
  bBlock := fld[AG_BLOCK]
endif
snLastStep := nStep
eval(b:skipBlock,nStep)
do while !eof()
  if cType == GTYPE_CHAR .or. cType == GTYPE_AMOUNT ;
                         .or. cType == GTYPE_QTY
    if ChkString(eval(bBlock), suSeekValue)
      ddRefreshAll(b)
      RETURN .T.
    endif
  else
    if eval(bBlock) == suSeekValue
      ddRefreshAll(b)
      RETURN .T.
    endif
  endif
  if TaskInter()
    SetMsg(MSG004)
    exit
  endif
  if eval(b:skipBlock,nStep) != nStep
    SetMsg(MSG003)
    exit
  endif
  MsgDisplay("Record "+ntrim(recno()))
enddo
goto nRecNo
RETURN .F.

