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

#ifdef DEF_LAYOUT

static scHideColor := "N/N"
static scTextColor
static scFldColor
static scItemColor := "W+/R"
static aElemTypes := { "Box", "String", "Field", "Image" }
static nList := 3
static aLists
static nItem := 1
static cName
static b
* static slDirty := .F.

#ifdef LG_FRENCH
  #define MSG001 "O pour supprimer l'‚l‚ment courant :"
  #define MSG002 "Tapez O pour ‚crire "
#else
  #define MSG001 "J um dieses Element zu l”schen :"
  #define MSG002 "J zum Schreiben der Datei "
#endif

**
** ddLayout() - Full-screen layout editor
**
FUNCTION ddLayout(ad)
local nNewItem
local nNewList
local msk := CurMsk()
if FileRdOnly(msk[MSK_IDMSK] + ".MSK")
  RETURN !SetMsg("File " + msk[MSK_IDMSK] + ".MSK is read-only")
endif
scTextColor := StdColor(CfgFullScreenColor())
scFldColor  := BordColor(CfgFullScreenColor())
aLists := { ;
  msk[MSK_BOXES], ;
  msk[MSK_STRINGS], ;
  msk[MSK_GETS], ;
  msk[MSK_IMAGES] ;
}
if len(aLists[nList]) == 0
  nItem := 0
else
  nItem := 1
endif
do while .t.
  SayLeg("[] [] [S]trings [F]ields [B]oxes [M]ove [A]rrange [F2]=Save [F5]=Load [Esc]")
  SetMsg( ElemText(ad) )
  ShowItem( ad, scItemColor )    // show item highlighted
  nKey := WaitKeySet()
  ShowItem( ad, scHideColor )    // hide item (since it could move...)
  nNewItem := nItem
  nNewList := nList
  **
  ** process keystroke ...
  **
  if nKey == K_ESC
    exit
  elseif nKey == K_DEL
    if nItem != 0
      if Confirm(MSG001)
        adel( aLists[nList], nItem )
        asize( aLists[nList], len(aLists[nList]) - 1 )
        nNewItem := nItem - 1
        nItem    := 0           // old item will not be displayed
      endif
    endif
  elseif nKey == K_F3
    EditWaitWin(msk[MSK_WAITWINLIST])
    MskEdit(msk)
  elseif nKey == K_INS
    AddItem(ad)
    nNewItem := len(aLists[nList])
  elseif upper(chr(nKey)) == "A"
      if nList == 1
        browse array aLists[nList] ;
          using {|a| padr( BoxText(a),40) } ;
          start nItem ;
          create {|| BoxCreate() } ;
          arrange
          if LastChoice() != 0
            nNewItem := LastChoice()
          endif
      elseif nList == 2
        browse array aLists[nList] ;
          using {|a| padr(StrText(a),60) } ;
          start nItem ;
          arrange
          if LastChoice() != 0
            nNewItem := LastChoice()
          endif
      elseif nList == 3 // field list
        browse array aLists[nList] ;
          using {|a| FldText(ad[AD_FIELDS],a) } ;
          start nItem ;
          arrange
          if LastChoice() != 0
            nNewItem := LastChoice()
          endif
      endif          
  elseif upper(chr(nKey)) == "B"
    scroll(1,0,maxrow()-3,maxcol())
    ScrPaint(msk)
    FldFreshAll(msk, ad,.f.)
    nNewList := 1
  elseif upper(chr(nKey)) == "S"
    scroll(1,0,maxrow()-3,maxcol())
    ScrPaint(msk)
    FldFreshAll(msk,ad,.f.)
    nNewList := 2
  elseif upper(chr(nKey)) == "F"
    scroll(1,0,maxrow()-3,maxcol())
    ScrPaint(msk)
    FldFreshAll(msk,ad,.f.)
    nNewList := 3
  elseif upper(chr(nKey)) == "I"
    scroll(1,0,maxrow()-3,maxcol())
    ScrPaint(msk)
    FldFreshAll(msk, ad,.f.)
    nNewList := 4
  elseif nKey == K_TAB    .or. nKey == K_DOWN
    nNewItem := nItem + 1
  elseif nKey == K_SH_TAB .or. nKey == K_UP
    nNewItem := nItem - 1
  elseif upper(chr(nKey)) == "M"
    if nItem != 0
      if nList == 1
        BoxMove(ad,aLists[nList][nItem])
      elseif nList == 2
        StrMove(ad,aLists[nList][nItem])
      elseif nList == 3
        FldMove(ad,aLists[nList][nItem])
      elseif nList == 4
        ImgMove(ad,aLists[nList][nItem])
      endif
    endif
  elseif nKey == K_F2
    MskWrite(ad)
  * elseif nKey == K_F5
  *   if MskReLoad(ad) != NIL
  *     nItem := 1
  *     scroll(1,0,22,79)
  *     ScrPaint(msk)
  *     FldFreshAll(msk,ad,.f.)
  *   endif
  elseif nKey == K_ENTER
    if nItem != 0
      if nList == 1
        BoxEdit( aLists[nList][nItem] )
      elseif nList == 2
        StrEdit( aLists[nList][nItem] )
      elseif nList == 3
        MskGetEdit( aLists[nList][nItem], ad )
      elseif nList == 4
        ImgEdit( aLists[nList][nItem] )
      endif
    endif
  endif
  **
  ** show old item in normal color
  **
  if nItem != 0
    if nList == 3
      ShowItem( ad, scFldColor )
    else
      ShowItem( ad, scTextColor )
    endif
  endif
  **
  ** Activate another object...
  **
  nList := nNewList
  if len(aLists[nList]) == 0
    nItem := 0
  else
    nItem := nNewItem
    if nItem > len(aLists[nList])
      nItem := 1
    elseif nItem < 1
      nItem := len(aLists[nList])
    endif
  endif
enddo
RETURN NIL


STATIC FUNCTION MskEdit(msk)
open window (msk[MSK_IDMSK] + ".MSK") ;
              size 3,40 help "MSKEDIT"
say "maximum vertical offset "
@ row(), col() get msk[MSK_VSIZE] picture "##"
nKey := ReadScr()
close window
if nKey == K_F2
  SendKey(K_F2)
endif
RETURN NIL


FUNCTION EditWaitWin(a)
local win
local i := 1
do while i != 0 .and. ! AppTerminate()
  if i > len(a)
    win := array(WIN_ALEN)
    win[WIN_TOP]     := 0
    win[WIN_LEFT]    := 0
    win[WIN_HEIGHT]  := 0
    win[WIN_WIDTH]   := 0
    win[WIN_WAITKEY] := 0
  else
    win := a[i]
  endif
  open window ("Wait Window " + ntrim(i) + " of " + ntrim(len(a))) ;
              size 7,40 help "WAITWIN"
  say "Wait action "
  @ row(), col() get win[WIN_WAITKEY] picture "##"
  WinCr()
  say "Height "
  @ row(), col() get win[WIN_HEIGHT] picture "##"
  WinCr()
  say "Width  "
  @ row(), col() get win[WIN_WIDTH] picture "##"
  WinCr()
  say "Top    "
  @ row(), col() get win[WIN_TOP] picture "##"
  WinCr()
  say "Left   "
  @ row(), col() get win[WIN_LEFT] picture "##"
  nKey := ReadScr()
  close window
  if win[WIN_WAITKEY] == 0
    if i <= len(a)
      adel(a,i)
      asize(a,len(a)-1)
    endif
  elseif i > len(a)
    aadd(a, win)
  endif
  if nKey == K_ESC .or. nKey == K_F10 .or. nKey == K_ENTER
    i := 0
  elseif nKey == K_F2
    i := 0
    SendKey(K_F2)
  elseif nKey == K_PGDN .and. i <= len(a)
    i++
  elseif nKey == K_PGUP .and. i > 1
    i--
  endif
enddo
RETURN NIL


FUNCTION ElemText(ad)
local cText := aElemTypes[nList] + " " + ntrim(nItem) + " : "
RETURN cText if nItem == 0
if nList == 1
  cText += BoxText( aLists[nList][nItem] )
elseif nList == 2
  cText += StrText( aLists[nList][nItem] )
elseif nList == 3
  cText += FldText( ad[AD_FIELDS],aLists[nList][nItem] )
elseif nList == 4
  cText += ImgText( aLists[nList][nItem] )
endif
RETURN cText

FUNCTION StrText(a)
RETURN "@ " + ntrim(a[1]) + "," + ntrim(a[2]) + ' say "' + a[3] + '"'

FUNCTION BoxText(a)
RETURN ntrim(a[1]) + "," + ntrim(a[2]) + " to " + ;
       ntrim(a[3]) + "," + ntrim(a[4])

FUNCTION ImgText(a)
RETURN ntrim(a[1]) + "," + ntrim(a[2]) + " to " + ;
       ntrim(a[3]) + "," + ntrim(a[4]) + " : " + a[5]

**
** FldText()
**
FUNCTION FldText(aFields, mskget)
local fld
if mskget[MSKGET_FLDHANDLE] == 0
  * 20050921
  * RETURN padr("(virtual)",11) + padr(&(mskget[MSKGET_BLOCK]),30) + space(5)
  RETURN padr("(virtual)",11) + padr((mskget[MSKGET_BLOCK]),30) + space(5)
endif
fld := aFields[mskget[MSKGET_FLDHANDLE]]
if "H" $ fld[AG_ATTRIB]
  RETURN padr( fld[AG_NAME] , 11 ) + ;
         padr("(hidden field)",30) + padr(fld[AG_ATTRIB],5)
endif
RETURN padr(fld[AG_NAME] , 11 ) + ;
       padr(eval(fld[AG_BLOCK]),30) + padr(fld[AG_ATTRIB],5)

**
** AddItem()
**
STATIC FUNCTION AddItem(ad)
local uReturn := NIL
local nFldHandle
local cPicture
static cBlock := ""
if nList == 1
  uReturn := { 10, 10, 13, 50 }
elseif nList == 4
  uReturn := { 1, 1, 4, 0, "'photo.jpg'" }
  * RETURN NIL if ! ImgValidate(uReturn)
  SendKey(K_ENTER)
elseif nList == 2
  uReturn := { 10,10, "New String" }
  SendKey(K_ENTER)
elseif nList == 3
  if (nFldHandle := PickField(ad)) == NIL
    nFldHandle := 0
    cBlock := padr(cBlock,128)
    open window ("create virtual field") size 3,50
    say "block "
    get cBlock picture "@k@s40"
    nKey := ReadScr()
    close window
    RETURN NIL if nKey == K_ESC
    RETURN NIL if empty(cBlock)
    cBlock := trim(cBlock)
    cPicture := ""
  else
    cPicture := ad[AD_FIELDS][nFldHandle][AG_PICTURE]
  endif
  uReturn := { ;
    nFldHandle, ;                        // MSKGET_FLDHANDLE
    10, ;                                // MSKGET_ROW
    10, ;                                // MSKGET_COL
    cPicture , ;                         // MSKGET_PICTURE
    NIL,                               ; // MSKGET_ATTRIB
    iif(empty(cBlock),NIL,cBlock)      ; // MSKGET_BLOCK
  }
endif
if uReturn != NIL
  aadd( aLists[nList], uReturn )
endif
RETURN NIL

**
** BoxCreate()
**
FUNCTION BoxCreate()
local a := { 10, 10, 13, 50 }
if BoxEdit(a)
  RETURN a
endif
RETURN NIL

**
** ShowItem
**
FUNCTION ShowItem( ad, cColor )
* local fld
if nItem != 0
  if nList == 1
    ShowBox(ad,aLists[nList][nItem], cColor )
  elseif nList == 2
    ShowString( ad, aLists[nList][nItem], cColor  )
  elseif nList == 3
    ShowField( ad, aLists[nList][nItem], cColor )
  elseif nList == 4
    ShowImg( ad, aLists[nList][nItem], cColor )
  endif
endif
RETURN NIL

**
** FldMove()
**
FUNCTION FldMove(ad, mskget)
local cScr
local nWidth
local s
if !empty(mskget[MSKGET_BLOCK])
  s := xparse(mskget[MSKGET_BLOCK])
  * default s to "NIL"
elseif mskget[MSKGET_FLDHANDLE] != 0
  s := eval(ad[AD_FIELDS][mskget[MSKGET_FLDHANDLE]][AG_BLOCK])
else
  RETURN NIL
endif
nWidth := len(transform(s, mskget[MSKGET_PICTURE]))
do while .t.
  cScr := savescreen( ;
    mskget[MSKGET_ROW], ;
    mskget[MSKGET_COL], ;
    mskget[MSKGET_ROW], ;
    mskget[MSKGET_COL] + nWidth ;
  )
  ShowField(ad,mskget,scItemColor)
  nKey := WaitKeySet()
  restscreen( ;
    mskget[MSKGET_ROW], ;
    mskget[MSKGET_COL], ;
    mskget[MSKGET_ROW], ;
    mskget[MSKGET_COL] + nWidth, ;
    cScr ;
  )
  if nKey == K_DOWN
    mskget[MSKGET_ROW] ++
  elseif nKey == K_UP
    mskget[MSKGET_ROW] --
  elseif nKey == K_RIGHT
    mskget[MSKGET_COL] ++
  elseif nKey == K_LEFT
    mskget[MSKGET_COL] --
  elseif nKey == K_ENTER
    exit
  elseif nKey == K_ESC
    exit
  endif
enddo
RETURN NIL

**
** StrMove()
**
FUNCTION StrMove(ad,a)
local cScr
do while .T.
  cScr := savescreen( a[1], a[2], a[1], a[2] + len(a[3]) )
  ShowString( ad, a, scItemColor )
  nKey := WaitKeySet()
  restscreen( a[1], a[2], a[1], a[2] + len(a[3]) , cScr )
  if nKey == K_DOWN
    a[1] ++
  elseif nKey == K_UP
    a[1] --
  elseif nKey == K_RIGHT
    a[2] ++
  elseif nKey == K_LEFT
    a[2] --
  elseif nKey == K_ENTER
    exit
  endif
enddo
RETURN NIL

**
** BoxMove()
**
FUNCTION BoxMove(ad,a)
local cScr
do while .T.
  cScr := savescreen( a[1], a[2], a[3], a[4] )
  ShowBox( ad, a, scItemColor )
  nKey := WaitKeySet()
  restscreen( a[1], a[2], a[3], a[4] , cScr )
  if nKey == K_DOWN
    a[1] ++
    a[3] ++
  elseif nKey == K_UP
    a[1] --
    a[3] --
  elseif nKey == K_RIGHT
    a[2] ++
    a[4] ++
  elseif nKey == K_LEFT
    a[2] --
    a[4] --
  elseif nKey == K_ENTER
    exit
  endif
enddo
RETURN NIL

**
** ImgMove()
**
FUNCTION ImgMove(ad,a)
local cScr
do while .t.
  cScr := savescreen( a[1], a[2], a[1]+a[3], a[2]+a[4] )
  ShowImg( ad, a, scItemColor )
  nKey := WaitKeySet()
  restscreen( a[1], a[2], a[1]+a[3], a[2]+a[4] , cScr )
  if nKey == K_DOWN
    a[1] ++
  elseif nKey == K_UP
    a[1] --
  elseif nKey == K_RIGHT
    a[2] ++
  elseif nKey == K_LEFT
    a[2] --
  elseif nKey == K_ENTER .or. nKey == K_ESC
    exit
  endif
enddo
RETURN NIL

**
** BoxEdit()
**
FUNCTION BoxEdit(a)
open window "Edit Box" size 6,30
say "   Top "
@ row(), col() get a[1] picture "##" ; WinCr()
say "  Left "
@ row(), col() get a[2] picture "##" ; WinCr()
say "Bottom "
@ row(), col() get a[3] picture "##" ; WinCr()
say " Right "
@ row(), col() get a[4] picture "##"
READ
close window
RETURN ( lastkey() != K_ESC )

**
** ImgEdit()
**
FUNCTION ImgEdit(a)
a[5] := padr(a[5],200)
open window "Edit Image" size 7,44
say "   Top "
@ row(), col() get a[1] picture "##" ; WinCr()
say "  Left "
@ row(), col() get a[2] picture "##" ; WinCr()
say "max. height "
@ row(), col() get a[3] picture "##" ; WinCr()
say "max. width  "
@ row(), col() get a[4] picture "##" ; WinCr()
say "Filename "
@ row(), col() get a[5] picture "@k@s30"
READ
close window
a[5] := trim(a[5])
RETURN ( lastkey() != K_ESC )

**
** StrEdit()
**
FUNCTION StrEdit(a)
a[3] := padr(a[3],250)
open window "Edit String" size 3,62
* @ CSR_POS say "   Row" get a[1] picture "###" ; WinCr()
* @ CSR_POS say "Column" get a[2] picture "###" ; WinCr()
@ CSR_POS say "String" get a[3] picture "@k@s50"
READ
close window
a[3] := alltrim(a[3])
RETURN .T.

**
** GetEdit()
**
STATIC FUNCTION MskGetEdit(mskget,ad)
local nHandle  := mskget[MSKGET_FLDHANDLE]
local cPicture := mskget[MSKGET_PICTURE]
local cAttrib  := mskget[MSKGET_ATTRIB]
local cBlock   := mskget[MSKGET_BLOCK]
default cPicture to ""
default cAttrib  to ""
default cBlock   to ""
default nHandle  to 0
cPicture := padr(cPicture,30)
cAttrib  := padr(cAttrib,5)
cBlock   := padr(cBlock,128)
open window "Fullscreen Field Properties" size 6,50
@ CSR_POS say "Picture   " get cPicture
WinCr()
@ CSR_POS say "Attributes" get cAttrib picture PIC_ID
WinCr()
@ CSR_POS say "Block     " get cBlock picture "@k@s30"
WinCr()
@ CSR_POS say "Handle    " get nHandle pick PickField(ad) picture "999" // ntrim(mskget[MSKGET_FLDHANDLE])
if nHandle == 0 // mskget[MSKGET_FLDHANDLE] == 0
  say " (virtual)"
else
  say " : " + ad[AD_FIELDS][nHandle][AG_NAME]
endif
READ
close window
RETURN .t. if nKey == K_ESC
mskget[MSKGET_PICTURE] := trim(cPicture)
mskget[MSKGET_ATTRIB]  := trim(cAttrib)
if empty(cBlock)
  mskget[MSKGET_BLOCK]  := NIL
else
  mskget[MSKGET_BLOCK]  := trim(cBlock)
endif
mskget[MSKGET_FLDHANDLE] := nHandle
RETURN .T.

**
** FldEdit()
**
** Attributes wird dann doch nicht „nderbar, weil sowieso immer schon bei
** ddFld gesetzt (performance).
**
**
FUNCTION FldEdit(ad, fld)
local cHeader := fld:cargo[AG_HEADER]
default cHeader to ""
cHeader := padr(cHeader,40)
open window ("Edit field " + fld:name) size 3,60
say "column header "
@ row(), col() get cHeader
nKey := ReadScr()
close window
if nKey != K_ESC
  * fld:row := nRow
  * fld:col := nCol
  fld:cargo[AG_HEADER] := trim(cHeader)
  * fld:cargo[AG_ATTRIB] := trim(cAttrib)
endif
RETURN NIL

**
** ColEdit()
**
FUNCTION ColEdit(col,ad)
local cHeader  := col[COL_HEADER]
local cPicture := padr(col[COL_PICTURE],40)
local cAttrib  := padr(col[COL_ATTRIB],5)
local cOnEdit  := space(255)
local cSkipBlock := padr(col[COL_SKIPBLOCK],255)
local cIfExpr
local xbColorBlock
local cBlock
local cExpr
local cSayBlock
local i
if col[COL_IFEXPR] == NIL
  cIfExpr := space(255)
else
  cIfExpr := padr(col[COL_IFEXPR],255)
endif
if col[COL_CLRBLOCK] == NIL
  xbColorBlock := space(255)
else
  xbColorBlock := padr(col[COL_CLRBLOCK],255)
endif
if col[COL_EXPR] == NIL
  cExpr := space(200)
else
  cExpr := padr(col[COL_EXPR],200)
endif
if col[COL_BLOCK] == NIL
  cBlock := space(200)
else
  cBlock := padr(col[COL_BLOCK],200)
endif
if col[COL_SAYBLOCK] == NIL
  cSayBlock := space(200)
else
  cSayBlock := padr(col[COL_SAYBLOCK],200)
endif
if col[COL_ONEDIT] != NIL
  cOnEdit := ""
  for i := 1 to len(col[COL_ONEDIT])
    cOnEdit += col[COL_ONEDIT][i]
    if i < len(col[COL_ONEDIT])
      cOnEdit += ";"
    endif
  next i
  cOnEdit := padr(cOnEdit,255)
endif
*if col[COL_AOFFSET] != NIL
*  cSkipBlock := ""
*  for i := 1 to len(col[COL_AOFFSET])
*    cSkipBlock += ntrim(col[COL_AOFFSET][i])
*    if i < len(col[COL_AOFFSET])
*      cSkipBlock += ","
*    endif
*  next i
*  cSkipBlock := padr(cSkipBlock,255)
*endif
default cHeader to ""
cHeader := padr(cHeader,250)
open window ("Edit column : " + col[COL_HEADER]) ;
     size 13,60 help "COLEDIT"
say "header       " ; @ row(), col() get cHeader picture "@k@s40"
WinCr()
say "picture      " ; @ row(), col() get cPicture
WinCr()
say "attributes   " ; @ row(), col() get cAttrib ;
                                     picture PIC_ID ;
                                     pick PickColAttrib(cAttrib)
WinCr()
say "sum-expr.    " ; @ row(), col() get cExpr picture "@K@S40"
WinCr()
say "say-expr.    " ; @ row(), col() get cSayBlock picture "@K@S40"
WinCr()
say "block        " ; @ row(), col() get cBlock picture "@K@S40"
WinCr()
say "onEdit       " ; @ row(), col() get cOnEdit picture "@K@S40"
WinCr()
say "skip expr.   " ; @ row(), col() get cSkipBlock picture "@K@S40"
WinCr()
say "color block  " ; @ row(), col() get xbColorBlock picture "@K@S40"
WinCr()
say "visible if   " ; @ row(), col() get cIfExpr picture "@K@S40"
WinCr()
say "field handle " ; @ row(), col() get col[COL_FLDHANDLE] ;
                                     picture "###" ;
                                     pick PickField(ad)
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
col[COL_HEADER]  := trim(cHeader)
col[COL_PICTURE] := trim(cPicture)
col[COL_ATTRIB]  := trim(cAttrib)
if empty(cExpr)
  col[COL_EXPR]    := NIL
else
  col[COL_EXPR]    := trim(cExpr)
endif
col[COL_SAYBLOCK] := if(empty(cSayBlock),NIL,trim(cSayBlock))
if empty(cBlock)
  if col[COL_FLDHANDLE] == 0
    col[COL_BLOCK]    := '""'
  else
    col[COL_BLOCK]    := NIL
  endif
else
  col[COL_BLOCK]    := trim(cBlock)
endif
if empty(cOnEdit)
  col[COL_ONEDIT]    := NIL
else
  col[COL_ONEDIT]    := ListAsArray(trim(cOnEdit),";")
endif
if empty(cSkipBlock)
  col[COL_SKIPBLOCK]    := ".f."
else
  col[COL_SKIPBLOCK]    := trim(cSkipBlock)
endif
if empty(xbColorBlock)
  col[COL_CLRBLOCK]    := NIL
else
  col[COL_CLRBLOCK]    := trim(xbColorBlock)
endif
if empty(cIfExpr)
  col[COL_IFEXPR]    := NIL
else
  col[COL_IFEXPR]    := trim(cIfExpr)
endif
RETURN NIL

FUNCTION PickColAttrib(cAttrib)
local a := {}
* aadd(a, { COLATTR_S, "Skip this column when [Enter]", 1 })
aadd(a, { COLATTR_S, "no settle after typeout ", 1 })
aadd(a, { COLATTR_R, "read-only column        ", 1 })
aadd(a, { COLATTR_P, "paste                   ", 1 })
aadd(a, { COLATTR_C, "confidential            ", 1 })
aadd(a, { COLATTR_Q, "quick picker            ", 1 })
RETURN PickAttrib(a,NIL,cAttrib)


FUNCTION ShowBox( ad, aBox, cColor )
* if ! (MskVisible(aBox[1]) .and. MskVisible(aBox[3]))
*   SetMsg(ElemText(ad) + " : NOT VISIBLE")
*   * SetMsg("Box is not not visible")
*   RETURN NIL
* endif
* dispbox( aBox[1]-CurMsk(MSK_VOFFSET), aBox[2], aBox[3]-CurMsk(MSK_VOFFSET), aBox[4], NIL, cColor)
dispbox( aBox[1], aBox[2], aBox[3], aBox[4], NIL, cColor)
RETURN NIL

*FUNCTION ImgValidate(aImg)
** Confirm(utos(aImg))
*RETURN !SetMsg("top : must be numeric") if valtype(aImg[1]) != "N"
*RETURN !SetMsg("left : must be numeric") if valtype(aImg[2]) != "N"
*RETURN !SetMsg("width : must be numeric") if valtype(aImg[3]) != "N"
*RETURN !SetMsg("height : must be numeric") if valtype(aImg[4]) != "N"
*RETURN !SetMsg("xfilename : must be numeric") if valtype(aImg[5]) != "C"
*RETURN .t.

FUNCTION ShowImg( ad, aBox, cColor )
local cFilename
* RETURN NIL if ! ImgValidate(aBox)
* if ! (MskVisible(aBox[1]) .and. MskVisible(aBox[3]))
*   SetMsg(ElemText(ad) + " : NOT VISIBLE")
*   RETURN NIL
* endif
if cColor == scHideColor
  cFilename := ""
else
  cFilename := xparse(aBox[5])
endif
ShowImage(cFilename, aBox[1],aBox[2], aBox[3],aBox[4])
RETURN NIL

FUNCTION ShowString( ad, aString, cColor)
*if ! MskVisible(aString[1])
*  SetMsg(ElemText(ad) + " : NOT VISIBLE")
*  * SetMsg("String is not not visible")
*  RETURN NIL
*endif
* @ aString[1]-CurMsk(MSK_VOFFSET), aString[2] say aString[3] color (cColor)
@ aString[1], aString[2] say aString[3] color (cColor)
RETURN NIL

FUNCTION ShowField( ad, mskget , cColor )
local fld
local s
* if ! MskVisible(mskget[MSKGET_ROW])
*   SetMsg(ElemText(ad) + " : NOT VISIBLE")
*   RETURN NIL
* endif
if ! empty(mskget[MSKGET_BLOCK])
  s := xparse(mskget[MSKGET_BLOCK])
  default s to "NIL"
  @ mskget[MSKGET_ROW], mskget[MSKGET_COL] ;
    say (s) color (cColor) picture (mskget[MSKGET_PICTURE])
  * @ mskget[MSKGET_ROW]-CurMsk(MSK_VOFFSET), mskget[MSKGET_COL] ;
  *   say (s) color (cColor) picture (mskget[MSKGET_PICTURE])
elseif mskget[MSKGET_FLDHANDLE] != 0
  fld := ad[AD_FIELDS][mskget[MSKGET_FLDHANDLE]]
  if FLDATTR_H $ fld[AG_ATTRIB]
    @ mskget[MSKGET_ROW], mskget[MSKGET_COL] ;
      say "(hidden)" color (cColor)
    * @ mskget[MSKGET_ROW]-CurMsk(MSK_VOFFSET), mskget[MSKGET_COL] ;
    *   say "(hidden)" color (cColor)
  elseif fld[AG_TYPE] == GTYPE_MEMO
    @ mskget[MSKGET_ROW], mskget[MSKGET_COL] ;
      say (" Memo Edit " + fld[AG_PICTURE]) color (cColor)
    * @ mskget[MSKGET_ROW]-CurMsk(MSK_VOFFSET), mskget[MSKGET_COL] ;
    *   say (" Memo Edit " + fld[AG_PICTURE]) color (cColor)
  else
    @ mskget[MSKGET_ROW], mskget[MSKGET_COL] ;
      say transform(eval(fld[AG_BLOCK]),mskget[MSKGET_PICTURE]) color (cColor)
    * @ mskget[MSKGET_ROW]-CurMsk(MSK_VOFFSET), mskget[MSKGET_COL] ;
    *   say transform(eval(fld[AG_BLOCK]),mskget[MSKGET_PICTURE]) color (cColor)
  endif
endif
RETURN NIL

#endif DEF_LAYOUT

**
** PickField()
**
FUNCTION PickField(ad,cTitle)
local aFields := {}
local i
local fld
local nChoice
default cTitle to "Select Field"
for i := 1 to len(ad[AD_FIELDS])
  fld := ad[AD_FIELDS][i]
  aadd( aFields, ;
    padr(fld[AG_NAME],10) + padr(fld[AG_HEADER],20) + ;
    str(i,3,0) ;
  )
next i
open window (cTitle) size 10,32
nChoice := achoice( WinTop(), WinLeft(), WinEndY(), WinEndX(), aFields )
close window
RETURN NIL if nChoice == 0
RETURN nChoice

#ifdef __XPP__

#define MARGIN 3

FUNCTION ShowImage(cFilename,nTop,nLeft,nHeight,nWidth)
local oPS := SetAppWindow():presSpace()
local oBMP:= XbpBitmap():new():create( oPS )
local oFnt := GetWinFont()
local aPos
local aTargetRect
local aSize
if empty(cFilename)
  scroll(nTop,nLeft,nTop+nHeight,nLeft+nWidth)
  RETURN .t.
endif
if ! oBMP:loadFile(cFilename)
  scroll(nTop,nLeft,nTop+nHeight,nLeft+nWidth)
  RETURN !SetMsg(cFilename+MsgDosError())
endif
aPos := { nLeft * oFnt:width + MARGIN, ;
  (maxrow() - nTop + 1) * oFnt:height - MARGIN}
if nHeight == NIL
  aSize := { oBmp:xSize , oBmp:ySize }
else
  * aSize := hw2size(nHeight,nWidth)
  aSize := { nWidth * oFnt:width, nHeight * oFnt:height }
  if aSize[1] == 0
    // compute x (width) using picture ratio
    // x = y * x1 / x2
    if aSize[2] == 0
      raise("you must specify at least width or height")
    endif
    aSize[1] := int(aSize[2] * oBmp:xSize  / oBmp:ySize)
  elseif aSize[2] != 0
    aSize[1] := min(aSize[1], int(aSize[2] * oBmp:xSize  / oBmp:ySize))
  endif
  if aSize[2] == 0
    // compute height using picture ratio
    // y = x * y1 / x1
    if aSize[1] == 0
      raise("you must specify at least width or height")
    endif
    aSize[2] := int(aSize[1] * oBmp:ySize  / oBmp:xSize)
  elseif aSize[1] != 0
    aSize[2] := min(aSize[2],int(aSize[1] * oBmp:ySize  / oBmp:xSize))
  endif
endif
** nTop,Left means the upper left corner, but aTargetRect must specify
** the lower left corner:
aPos[2] -= aSize[2]
**
aTargetRect := { aPos[1], aPos[2], aPos[1]+aSize[1], aPos[2]+aSize[2]}
* aTargetRect := { aPos[1], aPos[2], aSize[1], aSize[2]}
* aTargetRect := { aSize[1], aSize[2],aPos[1], aPos[2] }
* aTargetRect := { aSize[1],aPos[1], aPos[2], aSize[2] }
// { width, height, x, y }
* aTargetRect := { 1000, 80, 140, 200}
* aTargetRect := { 84, 120, 10, 10}
* SetMsg("target:"+utos(aTargetRect)+", size:"+utos(aSize)+", pos:"+utos(aPos))
oBMP:draw(oPS,aTargetRect,{0, 0, oBmp:xSize, oBmp:ySize})
* GraLine(oPS,{aTargetRect[1], aTargetRect[2]}, ;
*   {aTargetRect[3], aTargetRect[4]})
* GraLine(oPS,{100,100},{200,200})
RETURN .t.

#else

FUNCTION ShowImage(cFilename,nTop,nLeft,nHeight,nWidth)
MsgDisplay("ShowImage() not available in Clipper version")
RETURN .t.

#endif __XPP__


