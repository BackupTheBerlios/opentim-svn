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
* #include "DIRECTRY.CH"

**
** STATIC_SECTION global static variables
**
static saQryStack := {}
static saMskStack := {}
static saCurQry   := NIL
static saCurMsk   := NIL

#define LEN_QRYSTACK 10
#define LEN_MSKSTACK 5

**
** MSG_SECTION    MSGnnn definitions
**
static MSG002 := "Type Y to overwrite file "

**
** PROCEDURE_SECTION  - (...grins)
**


**
** QryLoad()
**
FUNCTION QryLoad(ad,cIdQry)
local cFileName
local fd
local cLine
local nLine := 0
local nCut
local lOkay
local i
if saCurQry != NIL
  RETURN saCurQry if saCurQry[QRY_IDQRY] == cIdQry
endif
for i := 1 to len(saQryStack)
  if saQryStack[i][QRY_IDQRY] == cIdQry
    saCurQry := saQryStack[i]
    RETURN saCurQry
  endif
next i
saCurQry := QryNew(cIdQry)
* cFileName := MskPath(ad) + cIdQry + ".QRY"
cFileName := cIdQry + ".QRY"
if (fd := mopen(cFilename)) == NIL
  Warning(SetMsg())
  RETURN saCurQry
endif
* MsgDisplay("Loading " + cFileName + "...")
do while (cLine := mreadline(fd)) != NIL
  nLine++
  if (nCut := at("//",cLine)) != 0
    cLine := left(cLine,nCut-1)
  endif
  if ! empty(cLine)
    lOkay := .f.
    if left(cLine,7) == "column "
      lOkay := ColRead(ad,alltrim(substr(cLine,7)))
    elseif left(cLine,7) == "window "
      lOkay := WinRead(ad,alltrim(substr(cLine,7)))
    * elseif left(cLine,7) == "rect "
    *   lOkay := RectRead(ad,alltrim(substr(cLine,7)))
    elseif left(cLine,5) == "mask "
      saCurQry[QRY_IDMSK] := alltrim(substr(cLine,6))
      lOkay := .t.
    elseif left(cLine,10) == "colorspec "
      saCurQry[QRY_CLRSPEC] := alltrim(substr(cLine,11))
      lOkay := .t.
    elseif left(cLine,6) == "title "
      saCurQry[QRY_TITLE] := alltrim(substr(cLine,7))
      lOkay := .t.
    elseif left(cLine,7) == "legend "
      saCurQry[QRY_LEGEND] := alltrim(substr(cLine,8))
      lOkay := .t.
    elseif left(cLine,7) == "freeze "
      saCurQry[QRY_FREEZE] := val(alltrim(substr(cLine,8)))
      lOkay := .t.
    elseif left(cLine,6) == "order "
      saCurQry[QRY_ORDER] := xparse(alltrim(substr(cLine,7)))
      lOkay := .t. // ( saCurQry[QRY_ORDER] != 0 )
    elseif left(cLine,7) == "filter "
      saCurQry[QRY_FILTER] := alltrim(substr(cLine,8))
      lOkay := .t.
    elseif left(cLine,4) == "key "
      saCurQry[QRY_KEY] := alltrim(substr(cLine,5))
      lOkay := .t.
    elseif left(cLine,9) == "keyvalue "
      saCurQry[QRY_KEYVALUE] := alltrim(substr(cLine,10))
      lOkay := .t.
    elseif left(cLine,11) == "cellheight "
      saCurQry[QRY_CELLHEIGHT] := xparse(alltrim(substr(cLine,12)))
      lOkay := .t.
    elseif left(cLine,7) == "bottom "
      saCurQry[QRY_BOTTOM] := xparse(alltrim(substr(cLine,8)))
      lOkay := .t.
    elseif left(cLine,12) == "marginright "
      saCurQry[QRY_RIGHT] := xparse(alltrim(substr(cLine,13)))
      lOkay := .t.
    elseif left(cLine,4) == "wait"
      lOkay := QryWaitRead(ad,substr(cLine,5))
    elseif left(cLine,5) == "help "
      saCurQry[QRY_HELP] := alltrim(substr(cLine,6))
      lOkay := .t.
    elseif left(cLine,6) == "colsep"
      saCurQry[QRY_COLSEP] := alltrim(substr(cLine,7))
      lOkay := .t.
    elseif left(cLine,6) == "attrib"
      saCurQry[QRY_ATTRIB] := alltrim(substr(cLine,7))
      lOkay := .t.
    elseif left(cLine,13) == "OnAddColumns "
      saCurQry[QRY_ONADDCOLUMNS] := alltrim(substr(cLine,14))
      lOkay := .t.
    endif
    if ! lOkay
      Warning(cFileName + " : error on line " + ntrim(nLine))
    endif
  endif
enddo
mclose(fd)
MsgDisplay("")
RETURN saCurQry

**  .MSK-Dateien beschreiben jeweils eine Vollbild-Maske
**  haben das folgende Format. Jede Zeile beginnt mit einem keyword
**
**  window  <nTop> <nLeft> <nHeight> <nWidth>
**  get   <nFldHandle> <nRow> <nCol>
**  string  <nRow> <nCol> <cString>
**  box     <nTop> <nLeft> <nBottom> <nRight>
FUNCTION MskLoad(ad,cIdMsk)
local cFileName
local fd
local cLine
local nLine := 0
local nCut
local lOkay
local i
if left(cIdMsk,1) == "="
  cIdMsk := xparse(substr(cIdMsk,2))
else
  cIdMsk := cIdMsk
endif
RETURN saCurMsk if saCurMsk != NIL .and. saCurMsk[MSK_IDMSK] == cIdMsk
for i := 1 to len(saMskStack)
  if saMskStack[i][MSK_IDMSK] == cIdMsk
    saCurMsk := saMskStack[i]
    RETURN saCurMsk
  endif
next i
saCurMsk := MskNew(cIdMsk)
* cFileName := MskPath(ad) + cIdMsk + ".MSK"
cFileName := cIdMsk + ".MSK"
if (fd := mopen(cFileName)) == NIL
  Warning(SetMsg())
  RETURN NIL
endif
MsgVerbose(MsgLoading(cFileName))
do while (cLine := mreadline(fd)) != NIL
  nLine++
  if (nCut := at("//",cLine)) != 0
    cLine := left(cLine,nCut-1)
  endif
  if ! empty(cLine)
    lOkay := .f.
    if left(cLine,4) == "get "
      lOkay := FldRead(ad,alltrim(substr(cLine,4)),saCurMsk[MSK_GETS])
    elseif left(cLine,6) == "string"
      lOkay := StrRead(ad,alltrim(substr(cLine,7)))
    elseif left(cLine,3) == "box"
      lOkay := BoxRead(ad,substr(cLine,4))
    elseif left(cLine,5) == "image"
      lOkay := ImgRead(ad,substr(cLine,6))
    elseif left(cLine,4) == "wait"
      lOkay := MskWaitRead(ad,substr(cLine,5))
    elseif left(cLine,5) == "vsize"
      saCurMsk[MSK_VSIZE] := val(alltrim(substr(cLine,6)))
      lOkay := .t.
    endif
    if ! lOkay
      Warning(cFileName + " : error on line " + ntrim(nLine))
    endif
  endif
enddo
mclose(fd)
// MsgDisplay("")
RETURN saCurMsk

**
**  FldRead()
**  get   <nFldHandle> <nRow> <nCol> [...]
**
static FUNCTION FldRead(ad,cLine,aGetList)
local aFld
local nFldHandle
local nPos
local cPicture := NIL
local cBlock   := NIL
local cAttrib  := NIL
if (nPos := rat(" attr ",cLine)) != 0
  cAttrib  := substr(cLine,nPos + 6)
  if USRATTR_C $ cAttrib
    RETURN .t. if ! USRATTR_C $ UsrAttrib()
  endif
  cLine    := trim(left(cLine,nPos - 1))
endif
if (nPos := rat(" pict ",cLine)) != 0
  cPicture := substr(cLine,nPos + 6)
  cLine    := trim(left(cLine,nPos - 1))
endif
if (nPos := rat(" block ",cLine)) != 0
  cBlock   := substr(cLine,nPos + 7)
  cLine    := trim(left(cLine,nPos - 1))
endif
aFld := ListAsArray(alltrim(cLine)," ")
RETURN .f. if len(aFld) != 3
nFldHandle := val(aFld[1])
if nFldHandle != 0
  RETURN .f. if len(ad[AD_FIELDS]) < nFldHandle
  * 20021023
  * if FLDATTR_H $ ad[AD_FIELDS][nFldHandle]:cargo[AG_ATTRIB]
  *   RETURN .t. // hidden (removed) field :
  * endif
  default cPicture to ad[AD_FIELDS][nFldHandle][AG_PICTURE]
else
  default cPicture to ""
endif

aadd( aGetList, { ;
        nFldHandle, ;      // MSKGET_FLDHANDLE
        val(aFld[2]), ;    // MSKGET_ROW
        val(aFld[3]),;     // MSKGET_COL
        cPicture,    ;     // MSKGET_PICTURE
        cAttrib,     ;     // MSKGET_ATTRIB
        cBlock       ;     // MSKGET_BLOCK
      } )                  // MSKGET_ALEN
RETURN .t.

**
**  StrRead()
**  field   <nRow> <nCol> <cString>
**
STATIC FUNCTION StrRead(ad,cLine)
local nPos
local nRow
local nCol
RETURN .f. if (nPos := at(" ",cLine)) == 0
nRow := val(left(cLine,nPos-1))
cLine := ltrim(substr(cLine,nPos+1))
RETURN .f. if (nPos := at(" ",cLine)) == 0
nCol := val(left(cLine,nPos-1))
cLine := ltrim(substr(cLine,nPos+1))
aadd( saCurMsk[MSK_STRINGS], { nRow, nCol, cLine } )
RETURN .t.

**
**  BoxRead()
**  box     <nTop> <nLeft> <nBottom> <nRight>
**
static FUNCTION BoxRead(ad,cLine)
local aBox := ListAsArray(alltrim(cLine)," ")
RETURN .f. if len(aBox) != 4
aadd( saCurMsk[MSK_BOXES], { ;
                                val(aBox[1]), val(aBox[2]), ;
                                val(aBox[3]), val(aBox[4]) ;
                              } )
RETURN .t.

static FUNCTION ImgRead(ad,cLine)
local aBox := ListAsArray(alltrim(cLine)," ")
RETURN .f. if len(aBox) != 5
aadd( saCurMsk[MSK_IMAGES], { ;
                                val(aBox[1]), val(aBox[2]), ;
                                val(aBox[3]), val(aBox[4]), ;
                                aBox[5] ;
                              } )
RETURN .t.

**
**  MskWaitRead()
**  box     <nTop> <nLeft> <nBottom> <nRight>
**
static FUNCTION MskWaitRead(ad,cLine)
local aBox := ListAsArray(alltrim(cLine)," ")
RETURN .f. if len(aBox) != 5
aadd(saCurMsk[MSK_WAITWINLIST], { ;
  val(aBox[1]), val(aBox[2]), ;
  val(aBox[3]), val(aBox[4]), ;
  val(aBox[5]) ;
} )
RETURN .t.

**
**  QryWaitRead()
**  box     <nTop> <nLeft> <nBottom> <nRight>
**
FUNCTION QryWaitRead(ad,cLine)
local aBox := ListAsArray(alltrim(cLine)," ")
RETURN .f. if len(aBox) != 5
aadd(saCurQry[QRY_WAITWINLIST], { ;
  val(aBox[1]), val(aBox[2]), ;
  val(aBox[3]), val(aBox[4]), ;
  val(aBox[5]) ;
} )
RETURN .t.

**
**  WinRead()
**  window  <nHeight> <nWidth> [ <nTop> <nLeft> ]
**
FUNCTION WinRead(ad,cLine)
local nPos
local a := array(WIN_ALEN)
RETURN .f. if (nPos := at(" ",cLine)) == 0
a[WIN_HEIGHT] := val(left(cLine,nPos-1))
cLine := ltrim(substr(cLine,nPos+1))
if (nPos := at(" ",cLine)) == 0
  a[WIN_WIDTH] := val(cLine)
  a[WIN_TOP]  := 0
  a[WIN_LEFT] := 0
  saCurQry[QRY_WINDOW] := a
  RETURN .t.
endif
a[WIN_WIDTH] := val(left(cLine,nPos-1))
cLine := ltrim(substr(cLine,nPos+1))
if (nPos := at(" ",cLine)) == 0
  a[WIN_TOP]  := val(cLine)
  a[WIN_LEFT] := 0
  saCurQry[QRY_WINDOW] := a
  RETURN .t.
endif
a[WIN_TOP] := val(left(cLine,nPos-1))
cLine := ltrim(substr(cLine,nPos+1))
a[WIN_LEFT] := val(cLine)
saCurQry[QRY_WINDOW] := a
RETURN .t.

**
**  RectRead()
**  rect  <nHeight> <nWidth> [ <nTop> <nLeft> ]
**
*FUNCTION RectRead(ad,cLine)
*local nPos
*local a := array(WIN_ALEN)
*RETURN .f. if (nPos := at(" ",cLine)) == 0
*a[WIN_HEIGHT] := val(left(cLine,nPos-1))
*cLine := ltrim(substr(cLine,nPos+1))
*if (nPos := at(" ",cLine)) == 0
*  a[WIN_WIDTH] := val(cLine)
*  a[WIN_TOP]  := 0
*  a[WIN_LEFT] := 0
*  saCurQry[QRY_RECT] := a
*  RETURN .t.
*endif
*a[WIN_WIDTH] := val(left(cLine,nPos-1))
*cLine := ltrim(substr(cLine,nPos+1))
*if (nPos := at(" ",cLine)) == 0
*  a[WIN_TOP]  := val(cLine)
*  a[WIN_LEFT] := 0
*  saCurQry[QRY_RECT] := a
*  RETURN .t.
*endif
*a[WIN_TOP] := val(left(cLine,nPos-1))
*cLine := ltrim(substr(cLine,nPos+1))
*a[WIN_LEFT] := val(cLine)
*saCurQry[QRY_RECT] := a
*RETURN .t.

**
**  ColRead()
**  column <nFldHandle> [ <cHeader> ]
**
STATIC FUNCTION ColRead(ad,cLine)
local nPos
local nFldHandle
local cHeader
local cPicture  := NIL
local cAttrib   := ""
local cExpr     := NIL
local cSayBlock := NIL
local cBlock    := NIL
local aOnEdit   := NIL
local xlSkip    := ".f."
local xbColorBlock
local xlIf := NIL
if (nPos := rat(" IfExpr ",cLine)) != 0
  xlIf  := substr(cLine,nPos + 8)
  cLine    := trim(left(cLine,nPos - 1))
endif
if (nPos := rat(" ColorBlock ",cLine)) != 0
  xbColorBlock  := substr(cLine,nPos + 12)
  cLine    := trim(left(cLine,nPos - 1))
endif
if (nPos := rat(" onEdit ",cLine)) != 0
  aOnEdit  := ListAsArray(substr(cLine,nPos + 8),";")
  cLine    := trim(left(cLine,nPos - 1))
endif
if (nPos := rat(" say ",cLine)) != 0
  cSayBlock   := substr(cLine,nPos + 5)
  cLine   := trim(left(cLine,nPos - 1))
endif
if (nPos := rat(" expr ",cLine)) != 0
  cExpr   := substr(cLine,nPos + 6)
  cLine   := trim(left(cLine,nPos - 1))
endif
if (nPos := rat(" attr ",cLine)) != 0
  cAttrib  := substr(cLine,nPos + 6)
  if USRATTR_C $ cAttrib
    RETURN .t. if ! USRATTR_C $ UsrAttrib()
  endif
  cLine    := trim(left(cLine,nPos - 1))
endif
if (nPos := rat(" skip ",cLine)) != 0
  xlSkip   := substr(cLine,nPos + 6)
  cLine    := trim(left(cLine,nPos - 1))
endif
if (nPos := rat(" pict ",cLine)) != 0
  cPicture := substr(cLine,nPos + 6)
  cLine    := trim(left(cLine,nPos - 1))
endif
if (nPos := rat(" block ",cLine)) != 0
  cBlock   := substr(cLine,nPos + 7)
  cLine    := trim(left(cLine,nPos - 1))
endif
if (nPos := at(" ",cLine)) == 0
  nFldHandle := val(cLine)
  cHeader := "" // [960919] ad[AD_FIELDS][nFldHandle]:Name
else
  nFldHandle := val(left(cLine,nPos-1))
  cHeader := alltrim(substr(cLine,nPos))
endif
if nFldHandle == 0
  RETURN .f. if cBlock == NIL
  default cPicture to ""
else
  RETURN .f. if len(ad[AD_FIELDS]) < nFldHandle
  * 20021023
  * if FLDATTR_H $ ad[AD_FIELDS][nFldHandle]:cargo[AG_ATTRIB]
  *   RETURN .t. // hidden (removed) field
  * endif
  default cPicture to ad[AD_FIELDS][nFldHandle][AG_PICTURE]
endif
* if FLDATTR_C $ ad[AD_FIELDS][nFldHandle]:cargo[AG_ATTRIB]
*   if ! USRATTR_C $ UsrAttrib()
*     RETURN .t.  // confidential data - do not add this column
*   endif
* endif
aadd( saCurQry[QRY_COLUMNS], { ;
  nFldHandle, ;    // COL_FLDHANDLE
  cHeader, ;       // COL_HEADER
  cAttrib, ;       // COL_ATTRIB
  cPicture,;       // COL_PICTURE
  "",     ;        // COL_BUFFER
  cExpr,    ;      // COL_EXPR
  0,      ;        // COL_SUM
  cSayBlock, ;     // COL_SAYBLOCK
  cBlock,    ;     // COL_BLOCK
  aOnEdit,   ;     // COL_ONEDIT
  xlSkip,    ;     // COL_SKIPBLOCK
  xbColorBlock ;   // COL_CLRBLOCK
  , xlIf         ;   // COL_IFEXPR
} )                // COL_ALEN
RETURN .t.

**
**  PicRead()
**  window  <nTop> <nLeft> <nHeight> <nWidth>
**
*STATIC FUNCTION PicRead(ad,cLine)
*local nPos := at(" ",cLine)
*local nFldHandle
*local cHeader
*if nPos == 0
*  nFldHandle := val(cLine)
*  cHeader := ad[AD_FIELDS][nFldHandle]:Name
*else
*  nFldHandle := val(left(cLine,nPos-1))
*  cHeader := alltrim(substr(cLine,nPos))
*endif
*RETURN .f. if len(ad[AD_FIELDS]) < nFldHandle
*if FLDATTR_C $ ad[AD_FIELDS][nFldHandle]:cargo[AG_ATTRIB]
*  if ! USRATTR_C $ UsrAttrib()
*    RETURN .t.  // confidential data - do not add this column
*  endif
*endif
*if FLDATTR_H $ ad[AD_FIELDS][nFldHandle]:cargo[AG_ATTRIB]
*  RETURN .t. // hidden (removed) field :
*endif
*aadd( ad[AD_VIEW][DBV_COLUMNS], nFldHandle )
*ad[AD_FIELDS][nFldHandle]:cargo[AG_HEADER] := cHeader
*RETURN .t.

**
**  ColRead()
**  window  <nTop> <nLeft> <nHeight> <nWidth>
**
*FUNCTION ColRead(ad,cLine) ...hier
*local a := ListAsArray(alltrim(cLine)," ")
*local i
*for i := 1 to len(a)
*  aadd( ad[AD_VIEW][DBV_COLUMNS], val(a[i]) )
*next i
*RETURN NIL


FUNCTION QryEdit(ob,ad,qry)
if FileRdOnly(qry[QRY_IDQRY] + ".QRY")
  RETURN !SetMsg("File " + qry[QRY_IDQRY] + ".QRY is read-only")
endif
browse array qry[QRY_COLUMNS] ;
  using {|col| ColText(ad[AD_FIELDS],col) } ;
  start  ob:colPos ;
  create {|| ColCreate(ad) } ;
  enter {|col| ColEdit(col,ad) } ;
  title  ("Edit Query " + qry[QRY_IDQRY]) ;
  arrange ;
  actions { ;
    { K_F2, {|| QryWrite(ad)  , NIL } }, ;
    { K_F3, {|| QryGetParam(ad), NIL } }, ;
    { K_F5, {|| ddDebug() , NIL } }  ;
  } ;
  legend " [Alt-] [Alt-] [Ins] [Del] ³ [F2]=Save [F3]=Params ³ [Esc]=Exit"
RETURN NIL


static FUNCTION ColCreate(ad)
local nFldHandle := PickField( ad, "Select field to use for new column" )
local cHeader := space(30)
local cBlock  := space(128)
if nFldHandle == NIL
  open window ("create virtual column") size 4,42
  say "header "
  get cHeader
  WinCr()
  say "block  "
  get cBlock picture "@k@s30"
  nKey := ReadScr()
  close window
  RETURN NIL if nKey == K_ESC
  RETURN { ;
    0, ;                                        // COL_FLDHANDLE
    trim(cHeader), ;                            // COL_HEADER
    "", ;                                       // COL_ATTRIB
    "", ;                                       // COL_PICTURE
    "",                                     ;   // COL_BUFFER
    NIL,                                    ;   // COL_EXPR
    0,                                      ;   // COL_SUM
    NIL,                                    ;   // COL_SAYBLOCK
    cBlock,                                 ;   // COL_BLOCK
    NIL,                                    ;   // COL_ONEDIT
    ".t.",                                  ;   // COL_SKIPBLOCK
    NIL                        ;   // COL_CLRBLOCK
    , NIL ;   // COL_IFEXPR
    }                                             // COL_ALEN
endif
RETURN { ;
  nFldHandle, ;                                        // COL_FLDHANDLE
  ad[AD_FIELDS][nFldHandle][AG_NAME], ;        // COL_HEADER
  "", ;                                                // COL_ATTRIB
  ad[AD_FIELDS][nFldHandle][AG_PICTURE], ;     // COL_PICTURE
  "",                                     ;            // COL_BUFFER
  NIL,                                    ;            // COL_EXPR
  0,                                      ;            // COL_SUM
  NIL,                                    ;            // COL_SAYBLOCK
  NIL,                                    ;            // COL_BLOCK
  NIL,                                    ;            // COL_ONEDIT
  ".f.",                                  ;            // COL_SKIPBLOCK
  NIL       ;            // COL_CLRBLOCK
  , NIL ; // COL_IFEXPR
}                                                      // COL_ALEN

STATIC FUNCTION ColText(aFields,col)
local fld
local cText
local cPicture := col[COL_PICTURE]
default cPicture to "NIL"
if col[COL_FLDHANDLE] == 0
  cText := padr("(virtual)",11)
else
  fld := aFields[col[COL_FLDHANDLE]]
  cText := padr(fld[AG_NAME],11)
endif
cText += padr(col[COL_ATTRIB],5)
cText += padr(col[COL_HEADER],20)
* if col[COL_FLDHANDLE] == 0
if col[COL_BLOCK] != NIL // neu 20050919
  cText += padr(col[COL_BLOCK],30)
else
  // if col[COL_IFEXPR] == NIL .and.  ! &(col[COL_IFEXPR])
  if FLDATTR_H $ fld[AG_ATTRIB]
    cText += space(30)
  else
    cText += padr(eval(fld[AG_BLOCK],NIL,0),30)
  endif
endif
cText += padr(cPicture,10)
RETURN cText




FUNCTION FileRdOnly(cFilename)
local c
RETURN .t. if SetReadOnly()
RETURN .f. if ! SetDlmRdOnly()
c := GetDlmPath(cFilename)
RETURN .f. if c == NIL
RETURN .f. if left(c,len(DbPath()))==DbPath()
RETURN .t.



**
** QryWrite()
**
FUNCTION QryWrite(ad)
local cName
local i, j
local fd
local a
* cName := MskPath(ad) + saCurQry[QRY_IDQRY] + ".QRY"
cName := GetDlmPath(saCurQry[QRY_IDQRY] + ".QRY")
default cName to DbPath() + "\" + saCurQry[QRY_IDQRY] + ".QRY"
open window ("Write .QRY") size 3,50
do while .t.
  cName := padr(cName,120)
  @ row(), col() get cName picture "@K@!@S46"
  nKey := ReadScr()
  cName := trim(cName)
  if nKey == K_ESC
    close window
    RETURN .f.
  endif
  if file(cName)
    if Confirm(MSG002 + cName + " :", NIL, "Y")
      exit
    endif
  else
    exit
  endif
enddo
close window
fd := fcreate( cName )
if fd == -1
  Warning("File creation error : " + cName )
  RETURN .F.
endif
fwrite( fd, "//" + CR_LF )
fwrite( fd, "// " + saCurQry[QRY_IDQRY] + ".QRY" + " - generated " + dtoc(date()) + CR_LF )
fwrite( fd, "// for " + ad[AD_NAME] + dbf_ext() + CR_LF )
fwrite( fd, "//" + CR_LF )
if saCurQry[QRY_WINDOW][WIN_HEIGHT] != 0
  fwrite( fd, "window " )
  fwrite( fd, ntrim(saCurQry[QRY_WINDOW][WIN_HEIGHT]) + " ")
  fwrite( fd, ntrim(saCurQry[QRY_WINDOW][WIN_WIDTH] ) + " ")
  fwrite( fd, ntrim(saCurQry[QRY_WINDOW][WIN_TOP]   ) + " ")
  fwrite( fd, ntrim(saCurQry[QRY_WINDOW][WIN_LEFT]  ) + " ")
  fwrite( fd, CR_LF )
endif
a := saCurQry[QRY_COLUMNS]
for i := 1 to len( a )
  fwrite( fd, "column " + ntrim(a[i][COL_FLDHANDLE]) )
  fwrite( fd, " " + a[i][COL_HEADER] )
  if ! empty(a[i][COL_BLOCK])
    fwrite( fd, " block " + trim(a[i][COL_BLOCK]) ) // 20030225
  endif
  if ! empty(a[i][COL_PICTURE])
    fwrite( fd, " pict " + a[i][COL_PICTURE] )
  endif
  if a[i][COL_SKIPBLOCK] != ".f."
    fwrite( fd, " skip ")
    fwrite(fd, a[i][COL_SKIPBLOCK])
  endif
  if ! empty(a[i][COL_ATTRIB])
    fwrite( fd, " attr " + a[i][COL_ATTRIB] )
  endif
  if a[i][COL_EXPR] != NIL
    fwrite( fd, " expr " + a[i][COL_EXPR] )
  endif
  if a[i][COL_SAYBLOCK] != NIL
    fwrite( fd, " say " + a[i][COL_SAYBLOCK] )
  endif
  if a[i][COL_ONEDIT] != NIL
    fwrite( fd, " onEdit ")
    for j := 1 to len(a[i][COL_ONEDIT])
      fwrite(fd, a[i][COL_ONEDIT][j])
      if j < len(a[i][COL_ONEDIT])
        fwrite(fd,";")
      endif
    next j
  endif
  if a[i][COL_CLRBLOCK] != NIL
    fwrite( fd, " ColorBlock ")
    fwrite(fd, a[i][COL_CLRBLOCK])
  endif
  if a[i][COL_IFEXPR] != NIL
    fwrite( fd, " IfExpr ")
    fwrite(fd, a[i][COL_IFEXPR])
  endif
  fwrite( fd, CR_LF )
next i
if saCurQry[QRY_CLRSPEC] != NIL
  fwrite( fd, "colorspec " + saCurQry[QRY_CLRSPEC] + CR_LF )
endif
if saCurQry[QRY_IDMSK] != NIL
  fwrite( fd, "mask " + saCurQry[QRY_IDMSK] + CR_LF )
endif
if saCurQry[QRY_ORDER] != 0
  fwrite( fd, "order " + ntrim(saCurQry[QRY_ORDER]) + CR_LF )
endif
if saCurQry[QRY_HELP] != saCurQry[QRY_IDQRY]
  fwrite( fd, "help " + saCurQry[QRY_HELP] + CR_LF )
endif
if saCurQry[QRY_COLSEP] != NIL
  fwrite( fd, "colsep " + saCurQry[QRY_COLSEP] + CR_LF )
endif
if ! empty(saCurQry[QRY_ATTRIB])
  fwrite( fd, "attrib " + saCurQry[QRY_ATTRIB] + CR_LF )
endif
if ! empty(saCurQry[QRY_ONADDCOLUMNS])
  fwrite( fd, "OnAddColumns " + saCurQry[QRY_ONADDCOLUMNS] + CR_LF )
endif
if ! empty(saCurQry[QRY_FILTER])
  fwrite( fd, "filter " + saCurQry[QRY_FILTER] + CR_LF )
endif
* if saCurQry[QRY_WAITWIN] != NIL
for i := 1 to len(saCurQry[QRY_WAITWINLIST])
  fwrite(fd, "wait " ;
    + ntrim(saCurQry[QRY_WAITWINLIST][i][WIN_HEIGHT]) + " " ;
    + ntrim(saCurQry[QRY_WAITWINLIST][i][WIN_WIDTH]) + " " ;
    + ntrim(saCurQry[QRY_WAITWINLIST][i][WIN_TOP]) + " " ;
    + ntrim(saCurQry[QRY_WAITWINLIST][i][WIN_LEFT]) + " " ;
    + ntrim(saCurQry[QRY_WAITWINLIST][i][WIN_WAITKEY]) + CR_LF ;
  )
  * fwrite(fd, ntrim(saCurQry[QRY_WAITKEY]) + CR_LF)
next i
if saCurQry[QRY_BOTTOM] != 0
  fwrite( fd, "bottom " + ntrim(saCurQry[QRY_BOTTOM]) + CR_LF )
endif
if saCurQry[QRY_RIGHT] != 0
  fwrite( fd, "marginright " + ntrim(saCurQry[QRY_RIGHT]) + CR_LF )
endif
if saCurQry[QRY_CELLHEIGHT] != 0
  fwrite( fd, "cellheight " + ntrim(saCurQry[QRY_CELLHEIGHT]) + CR_LF )
endif
if saCurQry[QRY_KEY] != NIL
  fwrite( fd, "key " + saCurQry[QRY_KEY] + CR_LF )
endif
if saCurQry[QRY_KEYVALUE] != NIL
  fwrite( fd, "keyvalue " + saCurQry[QRY_KEYVALUE] + CR_LF )
endif
if saCurQry[QRY_TITLE] != NIL
  fwrite( fd, "title " + saCurQry[QRY_TITLE] + CR_LF )
endif
if saCurQry[QRY_LEGEND] != NIL
  fwrite( fd, "legend " + saCurQry[QRY_LEGEND] + CR_LF )
endif
if saCurQry[QRY_FREEZE] != NIL
  fwrite( fd, "freeze " + ntrim(saCurQry[QRY_FREEZE]) + CR_LF )
endif
fclose(fd)
RETURN .T.


**
** MskWrite()
**
FUNCTION MskWrite(ad)
local cName
local i, j
local fd
local a
* cName := MskPath(ad) + saCurMsk[MSK_IDMSK] + ".MSK"
* cName := DbPath() + "\" + saCurMsk[MSK_IDMSK] + ".MSK"
cName := GetDlmPath(saCurMsk[MSK_IDMSK] + ".MSK")
default cName to DbPath() + "\" + saCurMsk[MSK_IDMSK] + ".MSK"
open window ("Write .MSK") size 3,50
do while .t.
  cName := padr(cName,120)
  @ row(), col() get cName picture "@K@!@S46"
  nKey := ReadScr()
  cName := trim(cName)
  if nKey == K_ESC
    close window
    RETURN .f.
  endif
  if file(cName)
    if Confirm(MSG002 + cName + " :", NIL, "Y")
      exit
    endif
  else
    exit
  endif
enddo
close window
fd := fcreate( cName )
if fd == -1
  Warning("File creation error : " + cName )
  RETURN .F.
endif
fwrite( fd, "//" + CR_LF )
fwrite( fd, "// generated " + dtoc(date()) + CR_LF )
* fwrite( fd, "// " + cName + " - generated " + dtoc(date()) + CR_LF )
fwrite( fd, "// for " + ad[AD_NAME] + dbf_ext() + CR_LF )
fwrite( fd, "//" + CR_LF )
fwrite( fd, CR_LF )
a := saCurMsk[MSK_BOXES]
for i := 1 to len( a )
  fwrite( fd, "box " ;
    + ntrim(a[i][1]) + " " ;
    + ntrim(a[i][2]) + " " ;
    + ntrim(a[i][3]) + " " ;
    + ntrim(a[i][4]) + CR_LF ;
  )
next i
fwrite( fd, CR_LF )
a := saCurMsk[MSK_IMAGES]
for i := 1 to len( a )
  fwrite( fd, "image " ;
    + ntrim(a[i][1]) + " " ;
    + ntrim(a[i][2]) + " " ;
    + ntrim(a[i][3]) + " " ;
    + ntrim(a[i][4]) + " " ;
    + a[i][5] + CR_LF ;
  )
next i
fwrite( fd, CR_LF )
a := saCurMsk[MSK_STRINGS]
for i := 1 to len( a )
  fwrite( fd, "string " ;
    + ntrim(a[i][1]) + " " ;
    + ntrim(a[i][2]) + " " ;
    + a[i][3] + CR_LF ;
  )
next i
fwrite( fd, CR_LF )
* a := saCurMsk[MSK_VFIELDS]
*   for i := 1 to len( a )
*     fwrite( fd, "vfield " ;
*       + ntrim(a[i][VFLD_ROW]) + " " ;
*       + ntrim(a[i][VFLD_COL]) + " " ;
*       + a[i][VFLD_MAC] ;
*     )
*     if a[i][4] != NIL
*       fwrite( fd, " color " + a[i][VFLD_COLOR] )
*     endif
*     fwrite( fd, CR_LF )
*   next i
*   fwrite( fd, CR_LF )
a := saCurMsk[MSK_GETS]
for i := 1 to len( a )
  fwrite( fd, "get " ;
    + ntrim(a[i][MSKGET_FLDHANDLE]) + " " ;
    + ntrim(a[i][MSKGET_ROW]) + " " ;
    + ntrim(a[i][MSKGET_COL]) ;
  )
  * if a[i][MSKGET_PICTURE] != NIL
  if ! empty(a[i][MSKGET_BLOCK])
    fwrite( fd, " block " + a[i][MSKGET_BLOCK])
  endif
  if ! empty(a[i][MSKGET_PICTURE])
    fwrite( fd, " pict " + a[i][MSKGET_PICTURE])
  endif
  if ! empty(a[i][MSKGET_ATTRIB])
    fwrite( fd, " attr " + a[i][MSKGET_ATTRIB] )
  endif
  fwrite( fd, CR_LF )
next i
*if saCurMsk[MSK_WAITWIN] != NIL
for i := 1 to len(saCurMsk[MSK_WAITWINLIST])
  fwrite(fd, "wait " ;
    + ntrim(saCurMsk[MSK_WAITWINLIST][i][WIN_HEIGHT]) + " " ;
    + ntrim(saCurMsk[MSK_WAITWINLIST][i][WIN_WIDTH]) + " " ;
    + ntrim(saCurMsk[MSK_WAITWINLIST][i][WIN_TOP]) + " " ;
    + ntrim(saCurMsk[MSK_WAITWINLIST][i][WIN_LEFT]) + " " ;
    + ntrim(saCurMsk[MSK_WAITWINLIST][i][WIN_WAITKEY]) + CR_LF ;
  )
next i
if saCurMsk[MSK_VSIZE] != 0
  fwrite( fd, "vsize " + ntrim(saCurMsk[MSK_VSIZE]) + CR_LF )
endif
fclose(fd)
RETURN .T.


**
** QryReload()
**
FUNCTION QryReload(ad)
local cIdDbv := PickQry(ad[AD_NAME],".QRY",saCurQry[QRY_IDQRY],"Load .QRY :")
local cIdQry
local i
RETURN .f. if cIdDbv == NIL
RETURN .f. if cIdDbv == NIL
cIdQry := ad[AD_NAME] + cIdDbv
for i := 1 to len(saQryStack)
  if saQryStack[i][QRY_IDQRY] == cIdQry
    adel(saQryStack,i)
    asize(saQryStack,len(saQryStack)-1)
    exit
  endif
next i
saCurQry := NIL
RETURN ddQryReset(ad[AD_NAME] + cIdDbv)

**
** MskReload()
**
*FUNCTION MskReload(ad)
*local cIdDbv := PickQry(ad[AD_NAME],".MSK",saCurMsk[MSK_IDMSK],"Load .MSK :")
*local i
*local cIdMsk
*RETURN NIL if cIdDbv == NIL
*cIdMsk := ad[AD_NAME] + cIdDbv
*for i := 1 to len(saMskStack)
*  if saMskStack[i][MSK_IDMSK] == cIdMsk
*    adel(saMskStack,i)
*    asize(saMskStack,len(saMskStack)-1)
*    exit
*  endif
*next i
*saCurMsk := NIL
*RETURN MskLoad(ad, cIdMsk)

**
** PickQry()
**
FUNCTION PickQry(cRoot,cExt,cStart,cTitle,nWidth)
local cName
local i
local nStart := 0
* local aDir := directory(MskPath() + cRoot + "*" + cExt)
local aDir := GetDlmDir(cRoot + "*" + cExt)
default cStart to ""
cStart := trim(cStart)
for i := 1 to len(aDir)
  if aDir[i][F_NAME] == cRoot + cStart + cExt
    nStart := i
  endif
next i
browse array aDir using {|a| padr(a[F_NAME],12) } start nStart ;
                  title (cTitle)
RETURN NIL if lastchoice() == 0
cName := substr(aDir[lastchoice()][F_NAME],len(cRoot)+1)
cName := strtran(cName,cExt)
RETURN trim(cName) if nWidth == NIL
RETURN padr(trim(cName),nWidth)

FUNCTION QryGetParam(ad)
local cIdMsk  := saCurQry[QRY_IDMSK]
local nHeight := saCurQry[QRY_WINDOW][WIN_HEIGHT]
local nWidth  := saCurQry[QRY_WINDOW][WIN_WIDTH]
local nTop    := saCurQry[QRY_WINDOW][WIN_TOP]
local nLeft   := saCurQry[QRY_WINDOW][WIN_LEFT]
local nBottom := saCurQry[QRY_BOTTOM]
local nRight  := saCurQry[QRY_RIGHT]
* local nRectHeight := saCurQry[QRY_RECT][WIN_HEIGHT]
* local nRectWidth  := saCurQry[QRY_RECT][WIN_WIDTH]
* local nRectTop    := saCurQry[QRY_RECT][WIN_TOP]
* local nRectLeft   := saCurQry[QRY_RECT][WIN_LEFT]
local nOrder  := saCurQry[QRY_ORDER]
local nFreeze := saCurQry[QRY_FREEZE]
local nCellHeight := saCurQry[QRY_CELLHEIGHT]
local cKey      := saCurQry[QRY_KEY]
local cKeyValue := saCurQry[QRY_KEYVALUE]
local cTitle  := saCurQry[QRY_TITLE]
local cLegend := saCurQry[QRY_LEGEND]
local cHelp   := padr(saCurQry[QRY_HELP],8)
local cColSep := padr(saCurQry[QRY_COLSEP],8)
local cAttrib := padr(saCurQry[QRY_ATTRIB],8)
local cFilter := saCurQry[QRY_FILTER]
local cColorSpec := saCurQry[QRY_CLRSPEC]
local cOnAddColumns := saCurQry[QRY_ONADDCOLUMNS]
default cFilter to ""
default cColorSpec to ""
default cOnAddColumns to ""
*  cFilter := space(128)
*else
  cFilter := padr(cFilter,128)
* endif
if cIdMsk == NIL
  cIdMsk := "NIL"
elseif left(cIdMsk,1) != "="
  cIdMsk := substr(cIdMsk,len(ad[AD_NAME])+1)
endif
cIdMsk := padr(cIdMsk,120)
if saCurQry[QRY_COLSEP] == NIL
  cColSep := space(8)
else
  cColSep := padr(saCurQry[QRY_COLSEP],8)
endif
default nFreeze to 0
default cKey      to ""
cKey := padr(cKey,128)
default cKeyValue to ""
cKeyValue := padr(cKeyValue,128)
default cTitle    to ""
default cLegend    to ""
cTitle     := padr(cTitle   ,255)
cLegend    := padr(cLegend  ,255)
cColorSpec := padr(cColorSpec,255)
cOnAddColumns := padr(cOnAddColumns,255)
do while .t.
  open window (saCurQry[QRY_IDQRY] + ".QRY : parameters") size 18,60 ;
              help "QRYPARAM"
  say ".msk for fullscreen "
  @ row(), col() get cIdMsk picture "@k@s20" ;
                 pick PickQry(ad[AD_NAME],".MSK",cIdMsk,NIL,5)
  WinCr()
    @ row(), col() say "Window : height " get nHeight picture "###"
    @ row(), col() say ", width "         get nWidth  picture "###"
    @ row(), col() say ", top "           get nTop    picture "###"
    @ row(), col() say ", left "          get nLeft   picture "###"
  WinCr()
    @ row(), col() say "   margin bottom " get nBottom   picture "##"
    @ row(), col() say "  right " get nRight   picture "##"
  WinCr() ; @ row(), col() say "index order " get nOrder  ;
                           picture "##" pick PickOrd(ad,nOrder)
  WinCr() ; @ row(), col() say "freeze " get nFreeze  ;
                           picture "##"
  WinCr() ; @ row(), col() say "selector " get cHelp  picture PIC_ID
  WinCr() ; @ row(), col() say "column separator " get cColSep
  WinCr() ; @ row(), col() say "attributes " get cAttrib ;
                           picture PIC_ID pick PickQryAttrib(cAttrib)
  WinCr() ; @ row(), col() say "filter " get cFilter ;
                           picture "@k@s48"
  WinCr() ; @ row(), col() say "cell height " get nCellHeight ;
                           picture "##"
  WinCr() ; @ row(), col() say "range value" get cKeyValue ;
                           picture "@k@s44"
  WinCr() ; @ row(), col() say "range key  " get cKey      ;
                           picture "@k@s44"
  WinCr() ; @ row(), col() say "title" get cTitle ;
                           picture "@k@s50"
  WinCr() ; @ row(), col() say "legend " get cLegend ;
                           picture "@k@s48"
  WinCr() ; @ row(), col() say "colorSpec " get cColorSpec ;
                           picture "@k@s45"
  WinCr() ; @ row(), col() say "OnAddColumns " get cOnAddColumns ;
                           picture "@k@s42"
  nKey := ReadScr()
  close window
  RETURN NIL if nKey == K_ESC
  if nKey == K_F3
    * saCurQry[QRY_WAITWINLIST] :=
    EditWaitWin(saCurQry[QRY_WAITWINLIST])
    loop
  endif
  exit
enddo
saCurQry[QRY_WINDOW][WIN_HEIGHT]  := nHeight
saCurQry[QRY_WINDOW][WIN_WIDTH]   := nWidth
saCurQry[QRY_WINDOW][WIN_TOP]     := nTop
saCurQry[QRY_WINDOW][WIN_LEFT]    := nLeft
cIdMsk := trim(cIdMsk)
if upper(cIdMsk) == "NIL"
  saCurQry[QRY_IDMSK] := NIL
elseif left(cIdMsk,1) == "="
  saCurQry[QRY_IDMSK] := cIdMsk
else
  saCurQry[QRY_IDMSK] := ad[AD_NAME] + cIdMsk
endif
if empty(cColSep)
  saCurQry[QRY_COLSEP] := NIL
else
  saCurQry[QRY_COLSEP] := trim(cColSep)
endif
saCurQry[QRY_ORDER]  := nOrder
saCurQry[QRY_BOTTOM] := nBottom
saCurQry[QRY_RIGHT] := nRight
saCurQry[QRY_FREEZE] := if(nFreeze==0,NIL,nFreeze)
saCurQry[QRY_CELLHEIGHT]  := nCellHeight
saCurQry[QRY_HELP]   := trim(cHelp)
saCurQry[QRY_ATTRIB] := trim(cAttrib)
if empty(cFilter)
  saCurQry[QRY_FILTER] := NIL
else
  saCurQry[QRY_FILTER] := trim(cFilter)
endif
if empty(cKey)
  saCurQry[QRY_KEY] := NIL
else
  saCurQry[QRY_KEY] := trim(cKey)
endif
if empty(cKeyValue)
  saCurQry[QRY_KEYVALUE] := NIL
else
  saCurQry[QRY_KEYVALUE] := trim(cKeyValue)
endif
if empty(cTitle)
  saCurQry[QRY_TITLE] := NIL
else
  saCurQry[QRY_TITLE] := trim(cTitle)
endif
if empty(cLegend)
  saCurQry[QRY_LEGEND] := NIL
else
  saCurQry[QRY_LEGEND] := trim(cLegend)
endif
if empty(cColorSpec)
  saCurQry[QRY_CLRSPEC] := NIL
else
  saCurQry[QRY_CLRSPEC] := trim(cColorSpec)
endif
if empty(cOnAddColumns)
  saCurQry[QRY_ONADDCOLUMNS] := NIL
else
  saCurQry[QRY_ONADDCOLUMNS] := trim(cOnAddColumns)
endif
RETURN NIL

FUNCTION PickOrd(ad,nStart)
local aPick := {}
local i
local cOrder
for i := 1 to len(ad[AD_AINDEX])
  aadd(aPick, str(i,2,0) + " " + padr(indexkey(i),60))
next i
cOrder := ArrayPick(aPick,"forced index order",str(nStart,2,0))
RETURN NIL if cOrder == NIL
RETURN val(cOrder)

FUNCTION PickQryAttrib(cStart)
local a := {}
* aadd(a, { QRYATTR_W , "no warning on multiple load"} )
aadd(a, { QRYATTR_S , "disable sum display           "} )
aadd(a, { QRYATTR_D , "descending (invert sort order)"} )
RETURN PickAttrib(a,NIL,cStart)



*FUNCTION MskPath(ad)
*RETURN DbPath() + "\" if ad == NIL
*RETURN ddPath(ad)

FUNCTION QryNew(cIdQry)
local a := array(QRY_ALEN)
a[QRY_ONADDCOLUMNS] := NIL
a[QRY_COLUMNS] := {}
a[QRY_ORDER]   := 0 // indexord()
a[QRY_BOTTOM]  := 0
a[QRY_RIGHT]  := 0
a[QRY_CELLHEIGHT] := 0
a[QRY_HELP]    := cIdQry
a[QRY_COLSEP]  := NIL
a[QRY_ATTRIB]  := ""
a[QRY_WINDOW]  := { 0, 0, 0, 0 }
a[QRY_IDQRY]   := cIdQry
a[QRY_IDMSK]   := NIL
* a[QRY_WAITWIN] := NIL // { 0, 0, 0, 0 }
a[QRY_WAITWINLIST] := {} // { 0, 0, 0, 0 }
* a[QRY_WAITKEY] := 0
if len(saQryStack) > LEN_QRYSTACK
  adel(saQryStack, 1)
  asize(saQryStack,len(saQryStack)-1)
endif
aadd(saQryStack, a)
RETURN a

FUNCTION MskNew(cIdMsk)
local a := array(MSK_ALEN)
a[MSK_IDMSK]   := cIdMsk
a[MSK_BOXES]   := {}
a[MSK_IMAGES]   := {}
a[MSK_STRINGS] := {}
a[MSK_GETS]    := {}
a[MSK_VOFFSET] := 0 // no longer used 20071212
a[MSK_VSIZE]   := 0
a[MSK_WAITWINLIST] := {}
if len(saMskStack) > LEN_MSKSTACK
  adel(saMskStack, 1)
  asize(saMskStack,len(saMskStack)-1)
endif
aadd(saMskStack, a)
RETURN a


FUNCTION QryIdMsk
RETURN NIL if saCurQry == NIL
RETURN saCurQry[QRY_IDMSK]

FUNCTION CurQry(i)
RETURN saCurQry if i == NIL
RETURN NIL if saCurQry == NIL
RETURN saCurQry[i]

FUNCTION CurMsk(i)
RETURN saCurMsk if i == NIL
RETURN NIL if saCurMsk == NIL
RETURN saCurMsk[i]

FUNCTION QryIdQry ; RETURN saCurQry[QRY_IDQRY]
FUNCTION QryHelp  ; RETURN saCurQry[QRY_HELP]

FUNCTION QryRestore(qry) ; saCurQry := qry ; RETURN NIL
FUNCTION MskRestore(msk) ; saCurMsk := msk ; RETURN NIL

FUNCTION MskCloseAll
saQryStack := {}
saMskStack := {}
RETURN NIL

* FUNCTION MskVisible(nRow)
* nRow -= saCurMsk[MSK_VOFFSET]
* RETURN .f. if nRow < 1 .or. nRow > (maxrow()-2)
* RETURN .t.

*FUNCTION MskScroll(nScroll)
** a negative number scrolls down
*RETURN .f. if saCurMsk[MSK_VOFFSET] + nScroll < 0
*RETURN .f. if saCurMsk[MSK_VOFFSET] + nScroll > saCurMsk[MSK_VSIZE]
*saCurMsk[MSK_VOFFSET] += nScroll
** scroll(1,0,22,79,nScroll)
*scroll(1,0,maxrow()-2,maxcol(),nScroll)
*RETURN .t.
