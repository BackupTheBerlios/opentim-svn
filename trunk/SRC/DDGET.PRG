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


static scGrayColor := NIL
static scEditColor := NIL
* static scButtonColor := NIL

static sadCurrent := NIL

#ifdef LG_FRENCH
  #define MSG001 " : caractŠre invalide !"
#else
  #define MSG001 " : ungltiges Zeichen !"
#endif

**
** ScrPaint()
**
FUNCTION ScrPaint( msk )
local i
* local cText
dispbegin()
  for i := 1 to len(msk[MSK_BOXES])
    BoxRefresh( msk[MSK_BOXES][i] )
  next i
  for i := 1 to len( msk[MSK_STRINGS] )
    *if MskVisible(msk[MSK_STRINGS][i][AS_ROW])
      *cText := msk[MSK_STRINGS][i][AS_TEXT]
      *if left(cText,1) == "="
      *  cText := xparse(substr(cText,2))
      *endif
      #ifdef DEF_VIDSTR
        ft_vidstr( ;
          msk[MSK_STRINGS][i][AS_ROW], ;
          msk[MSK_STRINGS][i][AS_COL], ;
          xstr(msk[MSK_STRINGS][i][AS_TEXT]);
        )
      #else
        @ msk[MSK_STRINGS][i][AS_ROW], ;
          msk[MSK_STRINGS][i][AS_COL]  ;
          say xstr(msk[MSK_STRINGS][i][AS_TEXT])
      #endif
      * #ifdef DEF_VIDSTR
      *   ft_vidstr( ;
      *     msk[MSK_STRINGS][i][AS_ROW] - msk[MSK_VOFFSET], ;
      *     msk[MSK_STRINGS][i][AS_COL], ;
      *     xstr(msk[MSK_STRINGS][i][AS_TEXT]);
      *   )
      * #else
      *   @ msk[MSK_STRINGS][i][AS_ROW] - msk[MSK_VOFFSET], ;
      *     msk[MSK_STRINGS][i][AS_COL]  ;
      *     say xstr(msk[MSK_STRINGS][i][AS_TEXT])
      * #endif
    *endif
  next i
dispend()
RETURN NIL


FUNCTION xstr(cText)
if left(cText,1) == "="
  RETURN xparse(substr(cText,2))
endif
RETURN cText



**
** FldFreshAll()
**
FUNCTION FldFreshAll( msk, ad, lEdit )
local fld
local i
GetList := {}
dispbegin()
  for i := 1 to len( msk[MSK_GETS] )
    FldRefresh( ad, msk[MSK_GETS][i], lEdit, msk )
  next i
dispend()
if ad[AD_WAITBLOCK] != NIL
  for i := 1 to len(msk[MSK_WAITWINLIST])
    * if MskVisible(msk[MSK_WAITWINLIST][i][WIN_TOP])
    *   if MskVisible(msk[MSK_WAITWINLIST][i][WIN_TOP]+msk[MSK_WAITWINLIST][i][WIN_HEIGHT])
        * eval(ad[AD_WAITBLOCK],WinMskOffset(msk[MSK_WAITWINLIST][i],msk))
        eval(ad[AD_WAITBLOCK],msk[MSK_WAITWINLIST][i])
    *   endif
    * endif
  next i
endif
for i := 1 to len( msk[MSK_IMAGES] )
  ShowImg(NIL,msk[MSK_IMAGES][i])
next i
RETURN NIL

* FUNCTION WinMskOffset(win,msk)
* local a := aclone(win)
* a[WIN_TOP] -= msk[MSK_VOFFSET]
* RETURN a

FUNCTION BoxRefresh( a )
* RETURN NIL if ! MskVisible(a[AB_TOP])
* RETURN NIL if ! MskVisible(a[AB_BOTTOM])
dispbox( ;
  a[AB_TOP], ;
  a[AB_LEFT], ;
  a[AB_BOTTOM], ;
  a[AB_RIGHT] ;
)
*dispbox( ;
*  a[AB_TOP] - CurMsk(MSK_VOFFSET), ;
*  a[AB_LEFT], ;
*  a[AB_BOTTOM] - CurMsk(MSK_VOFFSET), ;
*  a[AB_RIGHT] ;
*)
RETURN NIL

* FUNCTION ismemopic(c)
* RETURN len(trim(c))==4 .and. substr(3,1) == "x"

**
** FldRefresh()
**
FUNCTION FldRefresh( ad, mskget, lEdit, msk )
local ag,fld
local s
* RETURN NIL if ! MskVisible(mskget[MSKGET_ROW])
if mskget[MSKGET_FLDHANDLE] == 0
  s := &(mskget[MSKGET_BLOCK])
  if IsMemoPicture(mskget[MSKGET_PICTURE])
    MemoDisplay( ;
      s, ;
      mskget[MSKGET_ROW], ;
      mskget[MSKGET_COL], ;
      val(substr(mskget[MSKGET_PICTURE],4)), ;      // MEMO_PICTURE
      val(left(mskget[MSKGET_PICTURE],2)), ;        // MEMO_PICTURE
      scGrayColor  ;
    )
  else
    @ mskget[MSKGET_ROW], mskget[MSKGET_COL] ;
      say (s) ;
      color (scGrayColor)
    * @ mskget[MSKGET_ROW] - msk[MSK_VOFFSET], mskget[MSKGET_COL] ;
    *   say (s) ;
    *   color (scGrayColor)
  endif
else
  ag := ad[AD_FIELDS][mskget[MSKGET_FLDHANDLE]]
  RETURN NIL if FLDATTR_H $ ag[AG_ATTRIB]
  RETURN NIL if FLDATTR_C $ ag[AG_ATTRIB] .and. !USRATTR_C $ UsrAttrib()
  fld := ag2get(ag, mskget[MSKGET_ROW],;
                    mskget[MSKGET_COL],;
                    mskget[MSKGET_PICTURE])
  *fld := ag2get(ag, mskget[MSKGET_ROW] - msk[MSK_VOFFSET],;
  *                  mskget[MSKGET_COL],;
  *                  mskget[MSKGET_PICTURE])
  if lEdit
    if FldCanEdit(fld)
      fld:colorSpec := scEditColor
    else
      fld:colorSpec := scGrayColor
    endif
    aadd( GetList, fld )
  else
    fld:colorSpec := scGrayColor
  endif
  FldDisplay(fld,mskget[MSKGET_BLOCK])
endif
RETURN NIL

FUNCTION FldDisplay(fld,xuExpr)
if IsMemoPicture(fld:picture)
* if fld:cargo[AG_TYPE] == GTYPE_MEMO
  MemoDisplay( ;
    eval(fld:block), ;
    fld:row, ;
    fld:col, ;
    val(substr(fld:picture,4)), ;      // MEMO_PICTURE
    val(left(fld:picture,2)), ;        // MEMO_PICTURE
    fld:colorSpec  ;
  )
  RETURN val(substr(fld:picture,4))
elseif xuExpr != NIL  // neu am 20050919
  @ fld:row, fld:col ;
    say &(xuExpr) ;
    color (fld:colorSpec)
else
  fld:display()
endif
RETURN 1


FUNCTION MskSayAgain(msk)
local fld
local i
* local msk := CurMsk()
* RETURN .f. if msk == NIL
dispbegin()
  for i := 1 to len( msk[MSK_GETS] )
    if msk[MSK_GETS][i][MSKGET_FLDHANDLE] == 0
      *if MskVisible(msk[MSK_GETS][i][MSKGET_ROW])
        @ msk[MSK_GETS][i][MSKGET_ROW], ;
          msk[MSK_GETS][i][MSKGET_COL] ;
          say &(msk[MSK_GETS][i][MSKGET_BLOCK]) ;
          color (scGrayColor)
        *@ msk[MSK_GETS][i][MSKGET_ROW] - msk[MSK_VOFFSET], ;
        *  msk[MSK_GETS][i][MSKGET_COL] ;
        *  say &(msk[MSK_GETS][i][MSKGET_BLOCK]) ;
        *  color (scGrayColor)
      *endif
    endif
  next i
dispend()
RETURN .t.


**
** FldCanEdit()
**
FUNCTION FldCanEdit(fld)
RETURN .t. if fld:preBlock == NIL
RETURN eval(fld:preBlock)

FUNCTION fwb(cFieldname,cAlias)
RETURN fieldwblock(cFieldname,select(cAlias))

FUNCTION PseudoFieldBlock(cName,bPseudo)
local bFldBlock
#ifdef __XPP__
  // The xbase++ version of fieldblock() returns NIL if the fiel doesn't
  // exist in current workspace.
  // Modified copy of alaska's fieldblock() implementation from
  // source\sys\block.prg :
  IF ! "->" $ cName
    cName := "FIELD->"+cName
  ENDIF
  bFldBlock := &( "{|x| iif(x==NIL,"+cName+","+cName+":=x)}" )
#else
  bFldBlock := fieldblock(cName)
#endif
if bPseudo != NIL
  RETURN {|x| ;
    if( eof() , ;
      eval(bPseudo), ;
      eval(bFldBlock,x);
    ) ;
  }
endif
RETURN bFldBlock

FUNCTION ddDeclare( ;
  cAlias, ;
  bPreEdit, bPostEdit, bCreate, bMskWait, ;
  bPreDelete, ;
  bFilePrint, bEditPrint, ;
  cAttrib, ;
  bConvert, bPickFlt, ;
  bQryWait, blOnTest ;
)
local ad := array(AD_ALEN)
if sadCurrent != NIL
  // Warning(cAlias + " : sadCurrent != NIL")
  Warning("Started ddDeclare(" + cAlias ;
    + ") before ending ddDeclare(" ;
    +  sadCurrent[AD_NAME] + ")")
endif
default cAttrib to ""
* default blOnTest to {}
ad[AD_FIELDS]    := {}
ad[AD_NAME]      := cAlias
ad[AD_AINDEX]    := {}
ad[AD_PREEDIT]   := bPreEdit
ad[AD_PREEXIT]   := {||.t.}
ad[AD_POSTEDIT]  := bPostEdit
ad[AD_CREATE]    := bCreate
ad[AD_FILTER]    := NIL
ad[AD_WAITBLOCK] := bMskWait
ad[AD_UPDATED]   := .f.
ad[AD_FILEPRINT] := bFilePrint
ad[AD_EDITPRINT] := bEditPrint
ad[AD_ATTRIB]    := cAttrib
ad[AD_ACTIONS]   := {}
ad[AD_CONVERT]   := bConvert
ad[AD_PICKFLT]   := bPickFlt
ad[AD_PREDELETE] := bPreDelete
ad[AD_FIRST]     := .f.
ad[AD_ONTEST]    := {} // blOnTest
sadCurrent := ad
if blOnTest != NIL
  ddOnTest(blOnTest)
endif
RETURN ad

FUNCTION ddEndDef
* #ifdef DEF_ACT
  if IsCustData(sadCurrent[AD_NAME])
    if ! DefExec(sadCurrent[AD_NAME])
      SendConsole(sadCurrent[AD_NAME]+" : DefExec() failed !")
    endif
  endif
* #endif DEF_ACT
* if ! AddTableDef(sadCurrent)
*   Warning(sadCurrent[AD_NAME] + "AddTableDef() failed!")
* endif
sadCurrent := NIL
RETURN NIL


FUNCTION ValFileName(cName,lExt)
local i
cName := trim(cName)
for i := 1 to len(cName)
  if ! substr(cName,i,1) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789&_"
    SetMsg(substr(cName,i,1) + MSG001 ) // " : caractŠre invalide !")
    RETURN .f.
  endif
next i
RETURN .t.

**
** Funktionen zur Verwendung in def-Dateien
**

* FUNCTION ddSetPath(cPath)
* sadCurrent[AD_PATH] := cPath
* ddCloseAll()
* RETURN .t.

FUNCTION ddSetWait(bWait)
sadCurrent[AD_WAITBLOCK] := bWait
RETURN .t.


FUNCTION ddSetAttrib(cAttrib)
sadCurrent[AD_ATTRIB] := cAttrib
RETURN .t.

**
** ddOnPostEdit() -
**
FUNCTION ddOnPostEdit(b)
if valtype(b)=="C"; b := cblock(b) ; endif
// local b := cblock(xlEvent)
RETURN .f. if b == NIL
default sadCurrent[AD_ONPOSTEDIT] to {}
aadd(sadCurrent[AD_ONPOSTEDIT],b)
RETURN .t.
*
FUNCTION ddOnTest(b)
if valtype(b)=="C"; b := cblock(b) ; endif
RETURN .f. if b == NIL
aadd(sadCurrent[AD_ONTEST],b)
RETURN .t.

**
** ddEditDetail() -
**
FUNCTION ddEditDetail(b)
if valtype(b)=="C"; b := cblock(b) ; endif
RETURN .f. if b == NIL
default sadCurrent[AD_EDITDETAIL] to {}
aadd(sadCurrent[AD_EDITDETAIL],b)
RETURN .t.

**
** ddOnQryWait() -
**
FUNCTION ddOnQryWait(b)
if valtype(b)=="C"; b := cblock(b) ; endif
RETURN .f. if b == NIL
default sadCurrent[AD_ONQRYWAIT] to {}
aadd(sadCurrent[AD_ONQRYWAIT],b)
RETURN .t.

**
** ddOnDelete() -
**
FUNCTION ddOnDelete(b) // xlEvent)
if valtype(b)=="C"; b := cblock(b) ; endif
* local b := cblock(xlEvent)
RETURN .f. if b == NIL
default sadCurrent[AD_ONDELETE] to {}
aadd(sadCurrent[AD_ONDELETE],b)
RETURN .t.

**
** ddPostDelete() -
**
FUNCTION ddPostDelete(b) // xlEvent)
if valtype(b)=="C"; b := cblock(b) ; endif
// local b := cblock(xlEvent)
RETURN .f. if b == NIL
default sadCurrent[AD_POSTDELETE] to {}
aadd(sadCurrent[AD_POSTDELETE],b)
RETURN .t.

**
** ddScanBlock() -
**
FUNCTION ddSumScan(bSumScan)
sadCurrent[AD_SUMSCAN] := bSumScan
RETURN .t.

**
** ddOnCreate() -
**
FUNCTION ddOnCreate(x)
if valtype(x)=="C"; x := cblock(x) ; endif
RETURN .f. if x == NIL
default sadCurrent[AD_ONCREATE] to {}
aadd(sadCurrent[AD_ONCREATE],x)
RETURN .t.

FUNCTION ddSetCreate(bCreate)
sadCurrent[AD_CREATE] := bCreate
RETURN .t.



FUNCTION ddPickFilter(bBlock)
sadCurrent[AD_PICKFLT] := bBlock
RETURN .t.

FUNCTION ddPrintRecord(bBlock)
sadCurrent[AD_EDITPRINT] := bBlock
RETURN .t.

FUNCTION ddPrintFile(bBlock)
sadCurrent[AD_FILEPRINT] := bBlock
RETURN .t.

FUNCTION ddPreExit(bBlock)
sadCurrent[AD_PREEXIT] := bBlock
RETURN .t.

FUNCTION ddPreEdit(b)
sadCurrent[AD_PREEDIT] := b
RETURN .t.

FUNCTION ddPreDelete(b)
sadCurrent[AD_PREDELETE] := b
RETURN .t.

FUNCTION ddChkFirst()
sadCurrent[AD_FIRST] := .t.
RETURN .t.

FUNCTION ddPreCreate(x)
if valtype(x)=="C"; x := cblock(x) ; endif
default sadCurrent[AD_PRECREATE] to {}
aadd(sadCurrent[AD_PRECREATE],x)
RETURN .t.

FUNCTION ddSetMenu(cIdMnu)
sadCurrent[AD_IDMNU] := cIdMnu
RETURN .t.


FUNCTION ddAddIndex(cExpr, cText, cFor, bKeyFormat) // ,lDescend)
default bKeyFormat to {|x|upper(x)}
default cText to cExpr
* default lDescend to .f.
aadd( sadCurrent[AD_AINDEX], { ;
  cExpr, ;       // AI_EXPR
  cText, ;       // AI_TEXT
  cFor, ;        // AI_FOR
  bKeyFormat ;  // AI_KEYFORMAT  // lDescend ;     // AI_DESCEND
} )  // AI_ALEN
RETURN .t.

FUNCTION ddSetIndex(nIndex,xuExpr,cText,cFor,bKeyFormat)
if xuExpr != NIL
  sadCurrent[AD_AINDEX][nIndex][AI_EXPR] := xuExpr
endif
if bKeyFormat != NIL
  sadCurrent[AD_AINDEX][nIndex][AI_KEYFORMAT] := bKeyFormat
endif
RETURN .t.

**
** ddFldRemove() -
**
FUNCTION ddFldRemove(cName)
local i
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    RETURN !SetMsg(sadCurrent[AD_NAME]+"->"+cName+" was already hidden") if ;
      FLDATTR_H $ sadCurrent[AD_FIELDS][i][AG_ATTRIB]
    sadCurrent[AD_FIELDS][i][AG_ATTRIB] += FLDATTR_H
    RETURN .t.
  endif
next i
Warning(cName + MsgFldExist())
RETURN .f.

FUNCTION ddFldSetAttr(cName,cAttrib)
local i
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    RETURN !SetMsg("was already set") if ;
      cAttrib $ sadCurrent[AD_FIELDS][i][AG_ATTRIB]
    sadCurrent[AD_FIELDS][i][AG_ATTRIB] += cAttrib
    RETURN .t.
  endif
next i
RETURN !SetMsg(cName + MsgFldExist())

FUNCTION ddFldClearAttr(cName,cAttrib)
local i
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    RETURN !SetMsg("was not set") if ;
      ! cAttrib $ sadCurrent[AD_FIELDS][i][AG_ATTRIB]
    sadCurrent[AD_FIELDS][i][AG_ATTRIB] := strtran( ;
      trim(sadCurrent[AD_FIELDS][i][AG_ATTRIB]),cAttrib)
    RETURN .t.
  endif
next i
RETURN !SetMsg(cName + MsgFldExist())

**
** override the validate block of a field in the current table
FUNCTION ddFldSetValidate(cName,b)
local i
if valtype(b)=="C"; b := cblock(b) ; endif
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    sadCurrent[AD_FIELDS][i][AG_VALID] := b // wird oGet:postBlock
    RETURN .t.
  endif
next i
RETURN !SetMsg(cName + MsgFldExist())

**
** ddFldSetWhen() -
**
FUNCTION ddFldSetWhen(cName,b)
local i
if valtype(b)=="C"; b := cblock(b) ; endif
// local bWhen := xparse("{||"+xlWhen+"}")
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    sadCurrent[AD_FIELDS][i][AG_WHEN] := b
    RETURN .t.
  endif
next i
Warning(cName + MsgFldExist())
RETURN .f.

**
** ddFldSetPick() -
**
FUNCTION ddFldSetPick(cName,bPick)
local i
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    sadCurrent[AD_FIELDS][i][AG_PICKBLK] := bPick
    RETURN .t.
  endif
next i
Warning(cName + MsgFldExist())
RETURN .f.

**
** ddFldDoGet() -
**
FUNCTION ddFldDoGet(cName,bDoGet)
local i
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    sadCurrent[AD_FIELDS][i][AG_DOGET] := bDoGet
    RETURN .t.
  endif
next i
Warning(cName + MsgFldExist())
RETURN .f.

FUNCTION FldLocate(ad,cName)
local i
for i := 1 to len(ad[AD_FIELDS])
  RETURN ad[AD_FIELDS][i] if ad[AD_FIELDS][i][AG_NAME] == cName
next i
RETURN NIL


FUNCTION MsgFldExist() ; RETURN " : field not found."

**
** ddFldSetPostEdit() -
**
FUNCTION ddFldSetPostEdit(cName,bPostEdit)
local i
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    sadCurrent[AD_FIELDS][i][AG_POSTEDIT] := bPostEdit
    RETURN .t.
  endif
next i
Warning(cName + MsgFldExist())
RETURN .f.


**
** ddFldSetSize() -
**
FUNCTION ddFldSetSize(cName,nLen,nDec)
local i
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    sadCurrent[AD_FIELDS][i][AG_LEN] := nLen
    sadCurrent[AD_FIELDS][i][AG_DEC] := nDec
    RETURN .t.
  endif
next i
Warning(cName + MsgFldExist())
RETURN .f.

FUNCTION ddFldAddAttrib(cName,cAttrib)
local i
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    sadCurrent[AD_FIELDS][i][AG_ATTRIB] += cAttrib
    RETURN .t.
  endif
next i
Warning(cName + MsgFldExist())
RETURN .f.

**
** ddFldDelAttrib() -
**
FUNCTION ddFldDelAttrib(cName,cAttrib)
local i
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    sadCurrent[AD_FIELDS][i][AG_ATTRIB] ;
      := strtran(sadCurrent[AD_FIELDS][i][AG_ATTRIB],cAttrib)
    RETURN .t.
  endif
next i
Warning(cName + MsgFldExist())
RETURN .f.

**
** ddFldSetBlock() -
**
FUNCTION ddFldSetBlock(cName,bBlock)
local i
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    sadCurrent[AD_FIELDS][i]:Block := bBlock
    RETURN .t.
  endif
next i
Warning(cName + MsgFldExist())
RETURN .f.

**
** ddFldSetBlock() -
**
* FUNCTION ddFldSetBlock(ad,cName,bBlock)
* local i
* local fld := NIL
* for i := 1 to len(ad[AD_FIELDS])
*   if ad[AD_FIELDS][i][AG_NAME] == cName
*     fld := ad[AD_FIELDS][i]
*     exit
*   endif
* next i
* if fld != NIL
*   fld:block := bBlock
* endif
* RETURN NIL

**
FUNCTION ddFldSetAfter(cName,bAfter)
local i
for i := 1 to len(sadCurrent[AD_FIELDS])
  if sadCurrent[AD_FIELDS][i][AG_NAME] == cName
    sadCurrent[AD_FIELDS][i][AG_AFTER] := bAfter
    RETURN .t.
  endif
next i
Warning(cName + MsgFldExist())
RETURN .f.

FUNCTION HasField(ad,cName)
local i
for i := 1 to len(ad[AD_FIELDS])
  if ad[AD_FIELDS][i][AG_NAME] == cName
    RETURN ! FLDATTR_H $ ad[AD_FIELDS][i][AG_ATTRIB]
  endif
next i
RETURN .f.

FUNCTION ag2get(ag,nRow,nCol,cPicture)
local oGet
default cPicture to ag[AG_PICTURE]
oGet := GetNew(    ;
  nRow, nCol,  ;
  ag[AG_BLOCK],            ;
  ag[AG_NAME], ;
  cPicture ;
)
oGet:postBlock := ag[AG_VALID]
oGet:preBlock := ag[AG_WHEN]
if ag[AG_TYPE] == GTYPE_MEMO
  oGet:reader := {|x| MemoReader(x) }
elseif ag[AG_TYPE] == GTYPE_LOGICAL
  oGet:reader := {|x| CbxReader(x) }
endif
oGet:cargo := ag
RETURN oGet

**
** ddAddField()
**
FUNCTION ddAddField( cName, cType, nLen, nDec, ;
                     cPicture, cAttrib, ;
                     bBlock, nHandle, ;
                     blValid, bPickBlock, bPreBlock, ;
                     bPostEdit, ;
                     bAfter, bPseudo)
local ag
default cAttrib to ""
default scEditColor   to UnsColor(CfgFullScreenColor()) + "," + EnhColor(CfgFullScreenColor())
default scGrayColor   to BordColor(CfgFullScreenColor()) + "," + BordColor(CfgFullScreenColor())
if cType == GTYPE_MEMO
  default cPicture to "03x30"
  #ifdef __XPP__
  if DbeSetDefault()=="FOXCDX"
    nLen := 4
  else
    nLen := 10
  endif
  #else
    nLen := 10
  #endif __XPP__
elseif cType == GTYPE_LOGICAL
  default cPicture to "@k@!"
else
  default cPicture to ""
endif
default bBlock to PseudoFieldBlock(cName,bPseudo)
default bPreBlock to iif(FLDATTR_V $ cAttrib,{||.F.},{||.t.})
ag     := array(AG_ALEN)
ag[AG_PICKBLK]  := bPickBlock
ag[AG_ATTRIB]   := cAttrib
ag[AG_NAME]     := cName
ag[AG_BLOCK]    := bBlock
ag[AG_PICTURE]  := cPicture
ag[AG_TYPE]     := cType
ag[AG_LEN]      := nLen
ag[AG_DEC]      := nDec
ag[AG_POSTEDIT] := bPostEdit
ag[AG_VALID]    := blValid
ag[AG_WHEN]     := bPreBlock
ag[AG_AFTER]    := bAfter
if nHandle == NIL
  aadd( sadCurrent[AD_FIELDS], ag )
else
  sadCurrent[AD_FIELDS][nHandle] := ag
endif
RETURN .t.

FUNCTION ddAddSpecial(bAction,cPrompt,nKey,bWhen)
AddItem( cPrompt , bAction, nKey, bWhen, sadCurrent[AD_ACTIONS] )
RETURN .t.

#ifdef __XPP__

#include "APPEVENT.CH"


// Custom Get class
// WORK-AROUND FOR PDR 5685
CLASS PdrGet FROM Get
  EXPORTED:

   inline METHOD display()
     LOCAL nLen
     LOCAL cBuf
     * IF ValType(::Buffer) == "C" .AND. ::Picture != NIL
     IF ::Picture != NIL
       IF ValType(::Buffer) == "C"
       * IF ::type == "C"
         nLen := Len(::Buffer)
         cBuf := Transform( ::VarGet(), ::Picture )
         ::Length := Len( cBuf )
         ::Scroll:= !(nLen == ::Length)
       * ELSE
       *   LogConsole(::Name + ":display() : type is " + ::type)
       ENDIF
     ENDIF
   RETURN ::Get:Display()

ENDCLASS

FUNCTION eventname(n)
RETURN "xbe_None" if n == xbe_None
RETURN "xbeK_UP" if n == xbeK_UP
RETURN "xbeK_DOWN" if n == xbeK_DOWN
RETURN "xbeK_LEFT" if n == xbeK_LEFT
RETURN "xbeK_RIGHT" if n == xbeK_RIGHT
RETURN "xbeK_HOME" if n == xbeK_HOME
RETURN "xbeK_END" if n == xbeK_END
RETURN "xbeK_PGUP" if n == xbeK_PGUP
RETURN "xbeK_PGDN" if n == xbeK_PGDN
RETURN "xbeK_CTRL_UP" if n == xbeK_CTRL_UP
RETURN "xbeK_CTRL_DOWN" if n == xbeK_CTRL_DOWN
RETURN "xbeK_CTRL_LEFT" if n == xbeK_CTRL_LEFT
RETURN "xbeK_CTRL_RIGHT" if n == xbeK_CTRL_RIGHT
RETURN "xbeK_CTRL_HOME" if n == xbeK_CTRL_HOME
RETURN "xbeK_CTRL_END" if n == xbeK_CTRL_END
RETURN "xbeK_CTRL_PGUP" if n == xbeK_CTRL_PGUP
RETURN "xbeK_CTRL_PGDN" if n == xbeK_CTRL_PGDN
RETURN "xbeK_ALT_UP" if n == xbeK_ALT_UP
RETURN "xbeK_ALT_DOWN" if n == xbeK_ALT_DOWN
RETURN "xbeK_ALT_LEFT" if n == xbeK_ALT_LEFT
RETURN "xbeK_ALT_RIGHT" if n == xbeK_ALT_RIGHT
RETURN "xbeK_ALT_HOME" if n == xbeK_ALT_HOME
RETURN "xbeK_ALT_END" if n == xbeK_ALT_END
RETURN "xbeK_ALT_PGUP" if n == xbeK_ALT_PGUP
RETURN "xbeK_ALT_PGDN" if n == xbeK_ALT_PGDN
RETURN "xbeK_ALT_SPACE" if n == xbeK_ALT_SPACE
RETURN "xbeK_ALT_SHIFT" if n == xbeK_ALT_SHIFT
RETURN "xbeK_SH_UP" if n == xbeK_SH_UP
RETURN "xbeK_SH_DOWN" if n == xbeK_SH_DOWN
RETURN "xbeK_SH_LEFT" if n == xbeK_SH_LEFT
RETURN "xbeK_SH_RIGHT" if n == xbeK_SH_RIGHT
RETURN "xbeK_SH_HOME" if n == xbeK_SH_HOME
RETURN "xbeK_SH_END" if n == xbeK_SH_END
RETURN "xbeK_SH_PGUP" if n == xbeK_SH_PGUP
RETURN "xbeK_SH_PGDN" if n == xbeK_SH_PGDN
RETURN "xbeK_SH_CTRL_UP" if n == xbeK_SH_CTRL_UP
RETURN "xbeK_SH_CTRL_DOWN" if n == xbeK_SH_CTRL_DOWN
RETURN "xbeK_SH_CTRL_LEFT" if n == xbeK_SH_CTRL_LEFT
RETURN "xbeK_SH_CTRL_RIGHT" if n == xbeK_SH_CTRL_RIGHT
RETURN "xbeK_SH_CTRL_HOME" if n == xbeK_SH_CTRL_HOME
RETURN "xbeK_SH_CTRL_END" if n == xbeK_SH_CTRL_END
RETURN "xbeK_SH_CTRL_PGUP" if n == xbeK_SH_CTRL_PGUP
RETURN "xbeK_SH_CTRL_PGDN" if n == xbeK_SH_CTRL_PGDN
RETURN "xbeK_ENTER" if n == xbeK_ENTER
RETURN "xbeK_RETURN" if n == xbeK_RETURN
RETURN "xbeK_SPACE" if n == xbeK_SPACE
RETURN "xbeK_ESC" if n == xbeK_ESC
RETURN "xbeK_CTRL_ENTER" if n == xbeK_CTRL_ENTER
RETURN "xbeK_CTRL_RETURN" if n == xbeK_CTRL_RETURN
RETURN "xbeK_CTRL_RET" if n == xbeK_CTRL_RET
RETURN "xbeK_ALT_ENTER" if n == xbeK_ALT_ENTER
RETURN "xbeK_ALT_RETURN" if n == xbeK_ALT_RETURN
RETURN "xbeK_ALT_EQUALS" if n == xbeK_ALT_EQUALS
RETURN "xbeK_P_ALT_ENTER" if n == xbeK_P_ALT_ENTER
RETURN "xbeK_P_CTRL_5" if n == xbeK_P_CTRL_5
RETURN "xbeK_P_CTRL_SLASH" if n == xbeK_P_CTRL_SLASH
RETURN "xbeK_P_CTRL_ASTERISK" if n == xbeK_P_CTRL_ASTERISK
RETURN "xbeK_P_CTRL_MINUS" if n == xbeK_P_CTRL_MINUS
RETURN "xbeK_P_CTRL_PLUS" if n == xbeK_P_CTRL_PLUS
RETURN "xbeK_P_ALT_5" if n == xbeK_P_ALT_5
RETURN "xbeK_P_ALT_SLASH" if n == xbeK_P_ALT_SLASH
RETURN "xbeK_P_ALT_ASTERISK" if n == xbeK_P_ALT_ASTERISK
RETURN "xbeK_P_ALT_MINUS" if n == xbeK_P_ALT_MINUS
RETURN "xbeK_P_ALT_PLUS" if n == xbeK_P_ALT_PLUS
RETURN "xbeK_NUM_LOCK" if n == xbeK_NUM_LOCK
RETURN "xbeK_SCROLL_LOCK" if n == xbeK_SCROLL_LOCK
RETURN "xbeK_CAPS_LOCK" if n == xbeK_CAPS_LOCK
RETURN "xbeK_SH_CAPS_LOCK" if n == xbeK_SH_CAPS_LOCK
RETURN "xbeK_ALT_CAPS_LOCK" if n == xbeK_ALT_CAPS_LOCK
RETURN "xbeK_CTRL_CAPS_LOCK" if n == xbeK_CTRL_CAPS_LOCK
RETURN "xbeK_INS" if n == xbeK_INS
RETURN "xbeK_DEL" if n == xbeK_DEL
RETURN "xbeK_BS" if n == xbeK_BS
RETURN "xbeK_TAB" if n == xbeK_TAB
RETURN "xbeK_SH_TAB" if n == xbeK_SH_TAB
RETURN "xbeK_CTRL_TAB" if n == xbeK_CTRL_TAB
RETURN "xbeK_CTRL_INS" if n == xbeK_CTRL_INS
RETURN "xbeK_CTRL_DEL" if n == xbeK_CTRL_DEL
RETURN "xbeK_CTRL_BS" if n == xbeK_CTRL_BS
RETURN "xbeK_ALT_INS" if n == xbeK_ALT_INS
RETURN "xbeK_ALT_DEL" if n == xbeK_ALT_DEL
RETURN "xbeK_ALT_BS" if n == xbeK_ALT_BS
RETURN "xbeK_SH_INS" if n == xbeK_SH_INS
RETURN "xbeK_SH_DEL" if n == xbeK_SH_DEL
RETURN "xbeK_SH_BS" if n == xbeK_SH_BS
RETURN "xbeK_SH_ESC" if n == xbeK_SH_ESC
RETURN "xbeK_CTRL_A" if n == xbeK_CTRL_A
RETURN "xbeK_CTRL_B" if n == xbeK_CTRL_B
RETURN "xbeK_CTRL_C" if n == xbeK_CTRL_C
RETURN "xbeK_CTRL_D" if n == xbeK_CTRL_D
RETURN "xbeK_CTRL_E" if n == xbeK_CTRL_E
RETURN "xbeK_CTRL_F" if n == xbeK_CTRL_F
RETURN "xbeK_CTRL_G" if n == xbeK_CTRL_G
RETURN "xbeK_CTRL_H" if n == xbeK_CTRL_H
RETURN "xbeK_CTRL_I" if n == xbeK_CTRL_I
RETURN "xbeK_CTRL_J" if n == xbeK_CTRL_J
RETURN "xbeK_CTRL_K" if n == xbeK_CTRL_K
RETURN "xbeK_CTRL_L" if n == xbeK_CTRL_L
RETURN "xbeK_CTRL_M" if n == xbeK_CTRL_M
RETURN "xbeK_CTRL_N" if n == xbeK_CTRL_N
RETURN "xbeK_CTRL_O" if n == xbeK_CTRL_O
RETURN "xbeK_CTRL_P" if n == xbeK_CTRL_P
RETURN "xbeK_CTRL_Q" if n == xbeK_CTRL_Q
RETURN "xbeK_CTRL_R" if n == xbeK_CTRL_R
RETURN "xbeK_CTRL_S" if n == xbeK_CTRL_S
RETURN "xbeK_CTRL_T" if n == xbeK_CTRL_T
RETURN "xbeK_CTRL_U" if n == xbeK_CTRL_U
RETURN "xbeK_CTRL_V" if n == xbeK_CTRL_V
RETURN "xbeK_CTRL_W" if n == xbeK_CTRL_W
RETURN "xbeK_CTRL_X" if n == xbeK_CTRL_X
RETURN "xbeK_CTRL_Y" if n == xbeK_CTRL_Y
RETURN "xbeK_CTRL_Z" if n == xbeK_CTRL_Z
RETURN "xbeK_ALT_A" if n == xbeK_ALT_A
RETURN "xbeK_ALT_B" if n == xbeK_ALT_B
RETURN "xbeK_ALT_C" if n == xbeK_ALT_C
RETURN "xbeK_ALT_D" if n == xbeK_ALT_D
RETURN "xbeK_ALT_E" if n == xbeK_ALT_E
RETURN "xbeK_ALT_F" if n == xbeK_ALT_F
RETURN "xbeK_ALT_G" if n == xbeK_ALT_G
RETURN "xbeK_ALT_H" if n == xbeK_ALT_H
RETURN "xbeK_ALT_I" if n == xbeK_ALT_I
RETURN "xbeK_ALT_J" if n == xbeK_ALT_J
RETURN "xbeK_ALT_K" if n == xbeK_ALT_K
RETURN "xbeK_ALT_L" if n == xbeK_ALT_L
RETURN "xbeK_ALT_M" if n == xbeK_ALT_M
RETURN "xbeK_ALT_N" if n == xbeK_ALT_N
RETURN "xbeK_ALT_O" if n == xbeK_ALT_O
RETURN "xbeK_ALT_P" if n == xbeK_ALT_P
RETURN "xbeK_ALT_Q" if n == xbeK_ALT_Q
RETURN "xbeK_ALT_R" if n == xbeK_ALT_R
RETURN "xbeK_ALT_S" if n == xbeK_ALT_S
RETURN "xbeK_ALT_T" if n == xbeK_ALT_T
RETURN "xbeK_ALT_U" if n == xbeK_ALT_U
RETURN "xbeK_ALT_V" if n == xbeK_ALT_V
RETURN "xbeK_ALT_W" if n == xbeK_ALT_W
RETURN "xbeK_ALT_X" if n == xbeK_ALT_X
RETURN "xbeK_ALT_Y" if n == xbeK_ALT_Y
RETURN "xbeK_ALT_Z" if n == xbeK_ALT_Z
RETURN "xbeK_ALT_1" if n == xbeK_ALT_1
RETURN "xbeK_ALT_2" if n == xbeK_ALT_2
RETURN "xbeK_ALT_3" if n == xbeK_ALT_3
RETURN "xbeK_ALT_4" if n == xbeK_ALT_4
RETURN "xbeK_ALT_5" if n == xbeK_ALT_5
RETURN "xbeK_ALT_6" if n == xbeK_ALT_6
RETURN "xbeK_ALT_7" if n == xbeK_ALT_7
RETURN "xbeK_ALT_8" if n == xbeK_ALT_8
RETURN "xbeK_ALT_9" if n == xbeK_ALT_9
RETURN "xbeK_ALT_0" if n == xbeK_ALT_0
RETURN "xbeK_F1" if n == xbeK_F1
RETURN "xbeK_F2" if n == xbeK_F2
RETURN "xbeK_F3" if n == xbeK_F3
RETURN "xbeK_F4" if n == xbeK_F4
RETURN "xbeK_F5" if n == xbeK_F5
RETURN "xbeK_F6" if n == xbeK_F6
RETURN "xbeK_F7" if n == xbeK_F7
RETURN "xbeK_F8" if n == xbeK_F8
RETURN "xbeK_F9" if n == xbeK_F9
RETURN "xbeK_F10" if n == xbeK_F10
RETURN "xbeK_F11" if n == xbeK_F11
RETURN "xbeK_F12" if n == xbeK_F12
RETURN "xbeK_CTRL_F1" if n == xbeK_CTRL_F1
RETURN "xbeK_CTRL_F2" if n == xbeK_CTRL_F2
RETURN "xbeK_CTRL_F3" if n == xbeK_CTRL_F3
RETURN "xbeK_CTRL_F4" if n == xbeK_CTRL_F4
RETURN "xbeK_CTRL_F5" if n == xbeK_CTRL_F5
RETURN "xbeK_CTRL_F6" if n == xbeK_CTRL_F6
RETURN "xbeK_CTRL_F7" if n == xbeK_CTRL_F7
RETURN "xbeK_CTRL_F8" if n == xbeK_CTRL_F8
RETURN "xbeK_CTRL_F9" if n == xbeK_CTRL_F9
RETURN "xbeK_CTRL_F10" if n == xbeK_CTRL_F10
RETURN "xbeK_CTRL_F11" if n == xbeK_CTRL_F11
RETURN "xbeK_CTRL_F12" if n == xbeK_CTRL_F12
RETURN "xbeK_ALT_F1" if n == xbeK_ALT_F1
RETURN "xbeK_ALT_F2" if n == xbeK_ALT_F2
RETURN "xbeK_ALT_F3" if n == xbeK_ALT_F3
RETURN "xbeK_ALT_F4" if n == xbeK_ALT_F4
RETURN "xbeK_ALT_F5" if n == xbeK_ALT_F5
RETURN "xbeK_ALT_F6" if n == xbeK_ALT_F6
RETURN "xbeK_ALT_F7" if n == xbeK_ALT_F7
RETURN "xbeK_ALT_F8" if n == xbeK_ALT_F8
RETURN "xbeK_ALT_F9" if n == xbeK_ALT_F9
RETURN "xbeK_ALT_F10" if n == xbeK_ALT_F10
RETURN "xbeK_ALT_F11" if n == xbeK_ALT_F11
RETURN "xbeK_ALT_F12" if n == xbeK_ALT_F12
RETURN "xbeK_SH_F1" if n == xbeK_SH_F1
RETURN "xbeK_SH_F2" if n == xbeK_SH_F2
RETURN "xbeK_SH_F3" if n == xbeK_SH_F3
RETURN "xbeK_SH_F4" if n == xbeK_SH_F4
RETURN "xbeK_SH_F5" if n == xbeK_SH_F5
RETURN "xbeK_SH_F6" if n == xbeK_SH_F6
RETURN "xbeK_SH_F7" if n == xbeK_SH_F7
RETURN "xbeK_SH_F8" if n == xbeK_SH_F8
RETURN "xbeK_SH_F9" if n == xbeK_SH_F9
RETURN "xbeK_SH_F10" if n == xbeK_SH_F10
RETURN "xbeK_SH_F11" if n == xbeK_SH_F11
RETURN "xbeK_SH_F12" if n == xbeK_SH_F12
RETURN "xbeK_ALT_MINUS" if n == xbeK_ALT_MINUS
RETURN "xbeK_ALT_AE" if n == xbeK_ALT_AE
RETURN "xbeK_ALT_OE" if n == xbeK_ALT_OE
RETURN "xbeK_ALT_UE" if n == xbeK_ALT_UE
RETURN "xbeK_ALT_SZ" if n == xbeK_ALT_SZ
RETURN "xbeK_CMENU" if n == xbeK_CMENU
RETURN "xbeK_SHIFT" if n == xbeK_SHIFT
RETURN "xbeK_CTRL" if n == xbeK_CTRL
RETURN "xbeK_ALT" if n == xbeK_ALT
RETURN "xbeP_None" if n == xbeP_None
RETURN "xbeM_Enter" if n == xbeM_Enter
RETURN "xbeM_Leave" if n == xbeM_Leave
RETURN "xbeM_LbDown" if n == xbeM_LbDown
RETURN "xbeM_MbDown" if n == xbeM_MbDown
RETURN "xbeM_RbDown" if n == xbeM_RbDown
RETURN "xbeM_LbUp" if n == xbeM_LbUp
RETURN "xbeM_MbUp" if n == xbeM_MbUp
RETURN "xbeM_RbUp" if n == xbeM_RbUp
RETURN "xbeM_LbClick" if n == xbeM_LbClick
RETURN "xbeM_MbClick" if n == xbeM_MbClick
RETURN "xbeM_RbClick" if n == xbeM_RbClick
RETURN "xbeM_LbDblClick" if n == xbeM_LbDblClick
RETURN "xbeM_MbDblClick" if n == xbeM_MbDblClick
RETURN "xbeM_RbDblClick" if n == xbeM_RbDblClick
RETURN "xbeM_LbMotion" if n == xbeM_LbMotion
RETURN "xbeM_MbMotion" if n == xbeM_MbMotion
RETURN "xbeM_RbMotion" if n == xbeM_RbMotion
RETURN "xbeM_Motion" if n == xbeM_Motion
RETURN "xbeM_Wheel" if n == xbeM_Wheel
RETURN "xbeP_Keyboard" if n == xbeP_Keyboard
RETURN "xbeP_HelpRequest" if n == xbeP_HelpRequest
RETURN "xbeP_Activate" if n == xbeP_Activate
RETURN "xbeP_ItemSelected" if n == xbeP_ItemSelected
RETURN "xbeP_Move" if n == xbeP_Move
RETURN "xbeP_Resize" if n == xbeP_Resize
RETURN "xbeP_Paint" if n == xbeP_Paint
RETURN "xbeP_PresParamChanged" if n == xbeP_PresParamChanged
RETURN "xbeP_SetInputFocus" if n == xbeP_SetInputFocus
RETURN "xbeP_KillInputFocus" if n == xbeP_KillInputFocus
RETURN "xbeP_SetDisplayFocus" if n == xbeP_SetDisplayFocus
RETURN "xbeP_KillDisplayFocus" if n == xbeP_KillDisplayFocus
RETURN "xbeP_Close" if n == xbeP_Close
RETURN "xbeP_Quit" if n == xbeP_Quit
RETURN "xbeP_ItemMarked" if n == xbeP_ItemMarked
RETURN "xbeP_ClipboardChange" if n == xbeP_ClipboardChange
RETURN "xbeP_MeasureItem" if n == xbeP_MeasureItem
RETURN "xbeP_DrawItem" if n == xbeP_DrawItem
RETURN "xbeP_DragEnter" if n == xbeP_DragEnter
RETURN "xbeP_DragMotion" if n == xbeP_DragMotion
RETURN "xbeP_DragLeave" if n == xbeP_DragLeave
RETURN "xbeP_DragDrop" if n == xbeP_DragDrop
RETURN "xbeP_Measure" if n == xbeP_Measure
RETURN "xbeP_Draw" if n == xbeP_Draw
RETURN "xbeHelp_Inform" if n == xbeHelp_Inform
RETURN "xbeLB_ItemMarked" if n == xbeLB_ItemMarked
RETURN "xbeLB_ItemSelected" if n == xbeLB_ItemSelected
RETURN "xbeLB_VScroll" if n == xbeLB_VScroll
RETURN "xbeLB_HScroll" if n == xbeLB_HScroll
RETURN "xbeMLE_HScroll" if n == xbeMLE_HScroll
RETURN "xbeMLE_VScroll" if n == xbeMLE_VScroll
RETURN "xbeSLE_Scroll" if n == xbeSLE_Scroll
RETURN "xbeSLE_Overflow" if n == xbeSLE_Overflow
RETURN "xbeTab_TabActivate" if n == xbeTab_TabActivate
RETURN "xbeP_Selected" if n == xbeP_Selected
RETURN "xbeSpin_Up" if n == xbeSpin_Up
RETURN "xbeSpin_Down" if n == xbeSpin_Down
RETURN "xbeSpin_EndSpin" if n == xbeSpin_EndSpin
RETURN "xbeSB_Scroll" if n == xbeSB_Scroll
RETURN "xbeMENB_BeginMenu" if n == xbeMENB_BeginMenu
RETURN "xbeMENB_EndMenu" if n == xbeMENB_EndMenu
RETURN "xbeMENB_OnMenuKey" if n == xbeMENB_OnMenuKey
RETURN "xbeBRW_ItemMarked" if n == xbeBRW_ItemMarked
RETURN "xbeBRW_ItemSelected" if n == xbeBRW_ItemSelected
RETURN "xbeBRW_ItemRbDown" if n == xbeBRW_ItemRbDown
RETURN "xbeBRW_HeaderRbDown" if n == xbeBRW_HeaderRbDown
RETURN "xbeBRW_FooterRbDown" if n == xbeBRW_FooterRbDown
RETURN "xbeBRW_Navigate" if n == xbeBRW_Navigate
RETURN "xbeBRW_Pan" if n == xbeBRW_Pan
RETURN "xbeBRW_ForceStable" if n == xbeBRW_ForceStable
RETURN "xbeTV_ItemMarked" if n == xbeTV_ItemMarked
RETURN "xbeTV_ItemSelected" if n == xbeTV_ItemSelected
RETURN "xbeTV_ItemExpanded" if n == xbeTV_ItemExpanded
RETURN "xbeTV_ItemCollapsed" if n == xbeTV_ItemCollapsed
RETURN "xbeRTF_Change" if n == xbeRTF_Change
RETURN "xbeRTF_SelChange" if n == xbeRTF_SelChange
RETURN "xbeTBAR_Change" if n == xbeTBAR_Change
RETURN "xbeTBAR_ButtonClick" if n == xbeTBAR_ButtonClick
RETURN "xbeTBAR_ButtonMenuClick" if n == xbeTBAR_ButtonMenuClick
RETURN "xbeTBAR_ButtonDropDown" if n == xbeTBAR_ButtonDropDown
RETURN "xbeSBAR_PanelClick" if n == xbeSBAR_PanelClick
RETURN "xbeSBAR_PanelDblClick" if n == xbeSBAR_PanelDblClick
RETURN "xbeSBAR_AsyncRefresh" if n == xbeSBAR_AsyncRefresh
RETURN "xbeHTML_BeforeNavigate" if n == xbeHTML_BeforeNavigate
RETURN "xbeHTML_NavigateComplete" if n == xbeHTML_NavigateComplete
RETURN "xbeHTML_DocumentComplete" if n == xbeHTML_DocumentComplete
RETURN "xbeHTML_LoadError" if n == xbeHTML_LoadError
RETURN "xbeHTML_StatusTextChange" if n == xbeHTML_StatusTextChange
RETURN "xbeHTML_ProgressChange" if n == xbeHTML_ProgressChange
RETURN "xbeHTML_DownloadBegin" if n == xbeHTML_DownloadBegin
RETURN "xbeHTML_DownloadComplete" if n == xbeHTML_DownloadComplete
RETURN "xbeHTML_TitleChange" if n == xbeHTML_TitleChange
RETURN "xbeHTML_FrameBeforeNavigate" if n == xbeHTML_FrameBeforeNavigate
RETURN "xbeHTML_FrameNavigateComplete" if n == xbeHTML_FrameNavigateComplete
RETURN "xbeDBO_Notify" if n == xbeDBO_Notify
RETURN "xbeP_User" if n > xbeP_User
RETURN "unknown event"+ntrim(n)





#endif __XPP__

FUNCTION GetPaste(oGet,s)
local i
RETURN NIL if s == NIL
for i := 1 to len(s)
  oGet:insert(substr(s,i,1))
next i
RETURN NIL


