** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2009 Luc Saffre
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

#ifdef DEF_PRINT

**
** STATIC_SECTION global static variables
**

#define MAX_PREVIEW 32000
#define MEMO_PREVIEW
* #define FILE_PREVIEW

#ifdef LG_FRENCH
  * #define MSG040 "Police"
  * #define MSG048 " : ce fichier n'existe pas."
#endif

#ifdef LG_GERMAN
  * #define MSG040 "Schriftart"
  * #define MSG048 " : Datei nicht vorhanden."
#endif


#define FNT_NAME   1  // name
#define FNT_PITCH  2  // # chars per inch
#define FNT_HEIGHT 3  // line spacing (in inches)
                      // e.g. : 12 pt == spacing 12/72 inch == 6 lpi
#define FNT_CTRL   4  // escape-sequenz
#define FNT_ALEN   4

#define SPC_ID    1
#define SPC_NAME  2
#define SPC_CTRL  3

* static sbConverter  := NIL
static saCvtList := {}

static saOnSuccess  := {}
static saJobBegin  := {}
static saOnSelect  := {}
static saFntList := {}
static saSpecial := {}
* static scSpecial := ""
static saFntCurrent := NIL

static scDrvName       := ""
static scDrvInit       := ""
static scDrvReset      := ""
static scDrvFormFeed   := ""
static scDrvPapHeight  := ""
static scDrvBon        := ""
static scDrvBoff       := ""
static scDrvUon        := ""
static scDrvUoff       := ""
static scDrvIOn        := ""
static scDrvIOff       := ""
static scDrvSOn        := ""
static scDrvSOff       := ""
static scDrvLineFeed   := CR_LF
static scLastRead := NIL

FUNCTION DrvSave()
RETURN {             ;
  saJobBegin       , ;
  saOnSelect       , ;
  saCvtList        , ;
  saFntList        , ;
  saSpecial        , ;
  saFntCurrent     , ;
  scDrvName        , ;
  scDrvInit        , ;
  scDrvReset       , ;
  scDrvFormFeed    , ;
  scDrvPapHeight   , ;
  scDrvBon         , ;
  scDrvBoff        , ;
  scDrvUon         , ;
  scDrvUoff        , ;
  scDrvIOn         , ;
  scDrvIOff        , ;
  scDrvSOn         , ;
  scDrvSOff        , ;
  scDrvLineFeed    , ;
  scLastRead       , ;
  saOnSuccess        ;
}



FUNCTION DrvRestore(a)
saJobBegin       := a[ 1]
saOnSelect       := a[ 2]
saCvtList        := a[ 3]
saFntList        := a[ 4]
saSpecial        := a[ 5]
saFntCurrent     := a[ 6]
scDrvName        := a[ 7]
scDrvInit        := a[ 8]
scDrvReset       := a[ 9]
scDrvFormFeed    := a[10]
scDrvPapHeight   := a[11]
scDrvBon         := a[12]
scDrvBoff        := a[13]
scDrvUon         := a[14]
scDrvUoff        := a[15]
scDrvIOn         := a[16]
scDrvIOff        := a[17]
scDrvSOn         := a[18]
scDrvSOff        := a[19]
scDrvLineFeed    := a[20]
scLastRead       := a[21]
saOnSuccess      := a[22]
RETURN .t.

* FUNCTION DrvBegin(cDriver)
* FUNCTION DrvEnd()




**
** DrvLoad()
**
FUNCTION DrvLoad( cDriver )
static a := NIL
if empty(cDriver)
  saFntList := {}
  saCvtList := {}
  * sbConverter := NIL
  saSpecial := {}
  saOnSelect  := {}
  saJobBegin  := {}
  saOnSuccess  := {}
  scLastRead := NIL
  RETURN .t.
endif
cDriver := trim(cDriver)
RETURN .t. if scLastRead == cDriver
if a == NIL
  a := {}  // INI_ALEN
  aadd(a, { "Name"         , {|x| scDrvName      := x, .t. } })
  aadd(a, { "Initialize"   , {|x| scDrvInit      := x, .t. } })
  aadd(a, { "Reset"        , {|x| scDrvReset     := x, .t. } })
  aadd(a, { "FormFeed"     , {|x| scDrvFormFeed  := x, .t. } })
  aadd(a, { "PaperHeight"  , {|x| scDrvPapHeight := x, .t. } })
  aadd(a, { "BoldOn"       , {|x| scDrvBon       := x, .t. } })
  aadd(a, { "BoldOff"      , {|x| scDrvBoff      := x, .t. } })
  aadd(a, { "UnderOn"      , {|x| scDrvUon       := x, .t. } })
  aadd(a, { "UnderOff"     , {|x| scDrvUoff      := x, .t. } })
  aadd(a, { "ItalOn"       , {|x| scDrvIon       := x, .t. } })
  aadd(a, { "ItalOff"      , {|x| scDrvIoff      := x, .t. } })
  aadd(a, { "ShadowOn"     , {|x| scDrvSon       := x, .t. } })
  aadd(a, { "ShadowOff"    , {|x| scDrvSoff      := x, .t. } })
  aadd(a, { "LineFeed"     , {|x| scDrvLineFeed  := EvalMac(x), .t. } })
  aadd(a, { "Font"         , {|x| DrvAddFont(x)                     } })
  aadd(a, { "convert"      , {|x| CvtCollect(saCvtList,x)           } })
  aadd(a, { "inputFilter"  , {|x| SetInputFilter(xparse(x))         } })
  aadd(a, { "Option"       , {|x| DrvGetSpecial(x)                  } })
  aadd(a, { "OnSelect"     , {|x| AddIfNotNil(saOnSelect,cblock(x))   } })
  aadd(a, { "OnJobBegin"   , {|x| AddIfNotNil(saJobBegin,cblock(x))   } })
  aadd(a, { "OnSuccess"    , {|x| AddIfNotNil(saOnsuccess,cblock(x))  } })
endif
scDrvName       := ""
scDrvReset      := ""
scDrvInit       := ""
scDrvFormFeed   := ""
scDrvPapHeight  := ""
scDrvBon        := ""
scDrvBoff       := ""
scDrvUon        := ""
scDrvUoff       := ""
scDrvIOn        := ""
scDrvIOff       := ""
scDrvSOn        := ""
scDrvSOff       := ""
scDrvLineFeed   := CR_LF
saFntList  := {}
saCvtList  := {}
* sbConverter := NIL
saSpecial  := {}
saOnSelect := {}
saJobBegin := {}
saOnSuccess := {}
* 20010802 if IniLoad( a, AppPath() + "\" + cDriver )
RETURN .f. if ! IniLoad( a, cDriver + ".DRV" )
scLastRead := cDriver
if empty(scDrvName)
  scDrvName := cDriver+".DRV"
endif
RETURN .t.



**
** ValDriver()
**
* STATIC FUNCTION ValDriver( cDriver, cFont )
* if ReadDrv( cDriver )
*   if ValFont( @cFont )
*     @ 10,39 say padr(scDrvName,30)
*     RETURN .T.
*   endif
* endif
* RETURN .F.


**
** PickFont()
**
FUNCTION PickFnt(cStart)
local i
local nStart := 0
if len(saFntList) == 0
  DrvLoad(PickDrv())
endif
for i := 1 to len(saFntList)
  if saFntList[i][FNT_NAME] == cStart
    nStart := i
  endif
next i
browse array saFntList using {|fnt| fnt[FNT_NAME] } ;
             start nStart   ;
             help "PICKFNT"
RETURN NIL if lastchoice() == 0
RETURN saFntList[lastchoice()][FNT_NAME]


**
** ValFont()
**
* STATIC FUNCTION ValFont( cFont )
* local lFound
* local i
* if len( saFntList ) == 0 .or. empty(cFont)
*   cFont  := space(25)
*   snOptFont := 0
*   RETURN .T.
* endif
* lFound := .f.
* for i := 1 to len(saFntList)
*   if upper(saFntList[i][FNT_NAME]) == upper(trim(cFont))
*     snOptFont := i
*     lFound    := .t.
*     exit
*   endif
* next i
* if ! lFound
*   cFont     := space(25)
*   snOptFont := 0
* endif
* cFont := padr( cFont, 25 )
* RETURN .T.


FUNCTION EvalMac( cMacro )
RETURN "" if empty(cMacro)
if valtype(cMacro) == "C"
  RETURN ( &cMacro )
endif
RETURN cMacro

**
** DrvAddFont() - Line format :
**        Font <cFontName> <nPitch> <nHeight> [ <cEscSequence> ]
**
** <nHeight> steht in der .drv-Datei in Points, wird aber sofort
**           nach inches umgerechnet.
FUNCTION DrvAddFont( cLine )
local nCut
local nHeight
local cHeight
local a := array(FNT_ALEN)
** FNT_NAME
nCut := at( " ", cLine )
a[FNT_NAME] := left( cLine, nCut - 1 )
cLine := ltrim(substr(cLine,nCut + 1))
** FNT_PITCH
nCut := at( " ", cLine )
a[FNT_PITCH] := xparse(left( cLine, nCut - 1 ))
cLine := ltrim(substr(cLine,nCut + 1))
** FNT_HEIGHT
nCut := at( " ", cLine )
cHeight := left( cLine, nCut - 1 )
* if type(cHeight) != "N"
*   Warning(cHeight + " : invalid font height")
*   RETURN .f.
* endif
a[FNT_HEIGHT] := xparse(cHeight) // val(left( cLine, nCut - 1 )) / 72
if a[FNT_HEIGHT] >= 1 .or. a[FNT_HEIGHT] <= 0
  Warning( ;
    a[FNT_NAME] + " : abnormal font height " + ;
    ntrim(a[FNT_HEIGHT]) + " inch" ;
  )
endif
cLine := ltrim(substr(cLine,nCut + 1))
** FNT_CTRL
* nCut := at( " ", cLine )
a[FNT_CTRL] := cLine // EvalMac(cLine) // , nCut - 1 ))
if empty(a[FNT_NAME]) .or. a[FNT_PITCH] == 0 ;
                      .or. a[FNT_HEIGHT] == 0
  * Warning(scDrvName + ".DRV : ungltiger Font-Eintrag !")
  RETURN .F.
endif
aadd(saFntList, a)
RETURN .T.


**
** CvtCollect() - Line format :
**        convert <expr1> to <expr2>
**        convert {|x|dos2latin1(x)}
**
FUNCTION CvtCollect( aCvtList, cLine )
local nCut
local nHeight
local cHeight
local a
if (nCut := at( " to ", cLine )) == 0
  a := xparse(cLine)
  if valtype(a) != T_BLOCK
    SetMsg("convert must return a codebolck")
    RETURN .f.
  endif
  aadd(aCvtList, a)
  RETURN .t.
  * a :=   sbConverter := xparse(cLine)
  * RETURN .t. if valtype(sbConverter) == T_BLOCK
  * SetMsg("convert must return a codebolck")
  * RETURN .f.
endif
a := array(2)
a[1] := EvalMac(left( cLine, nCut - 1 ))
cLine := ltrim(substr(cLine,nCut + 4))
a[2] := EvalMac(cLine)
aadd(aCvtList, a)
RETURN .T.

FUNCTION PickDrv(cStart)
local cDrvName := FilePick("*.drv",NIL,NIL,NIL,cStart)
RETURN NIL if cDrvName == NIL
RETURN left(cDrvName,at(".",cDrvName)-1)

**
** PickDrv()
**
*FUNCTION PickDrv(cStart)
*local i
*local cName
*local aDrvPublic := directory( AppPath() + "\*.DRV" )
*static nStart := 0
*for i := 1 to len(aDrvPublic)
*  if trim(strtran(aDrvPublic[i][F_NAME],".DRV")) == trim(cStart)
*    nStart := i
*  endif
*next i
*browse array aDrvPublic ;
*             using {|drv| ;
*               padr(drv[F_NAME],12) + " " + ;
*               padr(FileFirstLine(AppPath()+"\"+drv[F_NAME]),50) ;
*             } ;
*             title ("select printer driver") ;
*             start nStart ;
*             help "PICKDRV"
*RETURN NIL if lastchoice() == 0
*nStart := lastchoice()
*RETURN strtran(aDrvPublic[nStart][F_NAME],".DRV")

*if len(aNames) == 0
*  Warning("")
*  RETURN NIL
*endif
*asort(aNames)
* RETURN ArrayPick(aNames,"Select driver",trim(cStart),8,"PICKDRV")

**
** DrvGetSpecial() - Transforms a text line of format
**                 <cName> <cControlChars>
**            and adds it to saSpecial
**
FUNCTION DrvGetSpecial( cLine )
local nCut
local cName
local cId
nCut := at( " ", cLine )
RETURN .f. if nCut == 0
cId := left( cLine, nCut - 1 )
cLine := ltrim( substr( cLine, nCut ) )
nCut := at( " ", cLine )
RETURN .f. if nCut == 0
cName := left( cLine, nCut - 1 )
cLine := trim(ltrim( substr( cLine, nCut ) ))
aadd(saSpecial, { cId, cName, EvalMac(cLine) } )
RETURN .t.

FUNCTION DrvHasOption(cId)
local i
for i := 1 to len(saSpecial)
  RETURN .t. if saSpecial[i][1] == cId
next i
RETURN .f.

* FUNCTION SetDriver(cDriver)
* scDriver := cDriver
* RETURN NIL

FUNCTION DrvOnSelect()
RETURN DoEvents(saOnSelect)

FUNCTION DrvJobBegin()
RETURN DoEvents(saJobBegin)

FUNCTION DrvOnSuccess()
RETURN DoEvents(saOnSuccess)

FUNCTION FntActivate(cIdFnt)
saFntCurrent := FntLocate(cIdFnt)
RETURN NIL

FUNCTION FntName()
RETURN "default printer font" if saFntCurrent == NIL
RETURN saFntCurrent[FNT_NAME]

FUNCTION FntHeight()
RETURN (1/6) if saFntCurrent == NIL
RETURN (1/6) if "6" $ p_setSpecial()
RETURN (1/7) if "7" $ p_setSpecial()
RETURN (1/8) if "8" $ p_setSpecial()
RETURN saFntCurrent[FNT_HEIGHT]

FUNCTION FntPitch()
RETURN 12 if saFntCurrent == NIL
RETURN saFntCurrent[FNT_PITCH]

FUNCTION FntCtrl(cIdFnt)
local fnt
if cIdFnt != NIL
  fnt := FntLocate(cIdFnt)
  RETURN .f. if fnt == NIL
  RETURN xparse(fnt[FNT_CTRL])
endif
RETURN "" if saFntCurrent == NIL
RETURN xparse(saFntCurrent[FNT_CTRL])

FUNCTION FntLocate(cIdFnt)
local i
for i := 1 to len(saFntList)
  if saFntList[i][FNT_NAME] == cIdFnt
    RETURN saFntList[i]
  endif
next i
RETURN NIL


FUNCTION DrvName
RETURN scDrvName if left(scDrvName,1) != "="
RETURN &(substr(scDrvName,2))

FUNCTION DrvFilename
RETURN scLastRead + ".DRV"

FUNCTION DrvInit
RETURN if(scDrvInit=="","",xparse(scDrvInit))
FUNCTION DrvReset
RETURN if(scDrvReset=="","",xparse(scDrvReset))

FUNCTION DrvFormFeed
RETURN if(scDrvFormFeed=="","",xparse(scDrvFormFeed))

FUNCTION DrvBon      ; RETURN if(scDrvBon  == "","",xparse(scDrvBon  ))
FUNCTION DrvBoff     ; RETURN if(scDrvBoff == "","",xparse(scDrvBoff ))
FUNCTION DrvUon      ; RETURN if(scDrvUon  == "","",xparse(scDrvUon  ))
FUNCTION DrvUoff     ; RETURN if(scDrvUoff == "","",xparse(scDrvUoff ))
FUNCTION DrvIOn      ; RETURN if(scDrvIOn  == "","",xparse(scDrvIOn  ))
FUNCTION DrvIOff     ; RETURN if(scDrvIOff == "","",xparse(scDrvIOff ))
FUNCTION DrvSOn      ; RETURN if(scDrvSOn  == "","",xparse(scDrvSOn  ))
FUNCTION DrvSOff     ; RETURN if(scDrvSOff == "","",xparse(scDrvSOff ))

FUNCTION DrvCvtString(c)
* 20040202
* if sbConverter != NIL
*   c := eval(sbConverter,c)
* endif
RETURN CvtString(saCvtList,c)

FUNCTION CvtString(aCvtList,c)
local i, a
RETURN c if ! valtype(c) $ "CM" // Weil f_import ruft convert fr alle
                                // Felder (z.B. EUROCHEM)
for i := 1 to len(aCvtList)
  * 20040202
  a := aCvtList[i]
  if valtype(a) == T_BLOCK
    c := eval(a,c)
  else
    * c := strtran(c,aCvtList[i][1],aCvtList[i][2])
    c := sgrep(c,a[1],a[2])
  endif
next i
RETURN c


FUNCTION sgrep(c,cWhat,cInto)
if left(cWhat,1) == "^"
  cWhat := substr(cWhat,2)
  if left(c,len(cWhat)) == cWhat
    c := cInto + substr(c,len(cWhat)+1)
  endif
  RETURN strtran( c, CR_LF + cWhat, CR_LF + cInto )
elseif left(cWhat,2) == "\^"
  cWhat := substr(cWhat,2)    // remove escape character
endif
RETURN strtran(c,cWhat,cInto)


FUNCTION DrvPapHeight(nHeight)
RETURN "" if empty(scDrvPapHeight)
RETURN EvalMac(strtran(scDrvPapHeight,"#",ntrim(nHeight)))


* FUNCTION DrvSetSpecial(cSpc)
* scSpecial := cSpc
* RETURN NIL

FUNCTION DrvSpecial(cSpecial)
local cReturn := ""
local i
for i := 1 to len(saSpecial)
  if saSpecial[i][SPC_ID] $ cSpecial
    cReturn += saSpecial[i][SPC_CTRL]
  endif
next i
RETURN cReturn

**
** FntApsActivate()  APS (Auto Pitch Select) feature
**              activates the "most appropriate font" to fit the
**              required # of chars per line
**
FUNCTION FntApsActivate(nWidth)
local i
for i := 1 to len(saFntList)
  * if int(saFntList[i][FNT_PITCH] * p_LnWidth()) > nWidth 970718
  if int(saFntList[i][FNT_PITCH] * p_LnWidth()) >= nWidth
    saFntCurrent := saFntList[i]
    RETURN NIL
  endif
next i
if len(saFntList) != 0
  saFntCurrent := atail(saFntList)
endif
RETURN NIL

FUNCTION PickDrvSpecial()
local a := {}
local i
for i := 1 to len(saSpecial)
  aadd(a, { saSpecial[i][SPC_ID], saSpecial[i][SPC_NAME],1 })
next i
RETURN PickAttrib(a,scDrvName)


FUNCTION DrvLineFeed
RETURN scDrvLineFeed

#endif DEF_PRINT

**
** CvtExec()
**
*FUNCTION CvtExec( cMemo, cIdCvt )
*local a := {}
*local aCvtList := {}
*aadd(a, { "convert"  , {|x| CvtCollect(aCvtList,x) } })
*if IniLoad( a, AppPath() + "\" + cIdCvt + ".CVT" )
*  RETURN CvtString(aCvtList,cMemo)
*endif
*RETURN cMemo


FUNCTION RtfMemo(cMemo)
// cMemo := strtran(cMemo,chr(141)," ")
* cMemo := strtran(cMemo, CR_LF+"- ", CR_LF+ ;
*   "\par \pard \fi-360\li360\sb60\sa60\jclisttab\tx360\ls1\adjustright " ;
* )
* cMemo := strtran(cMemo, CR_LF, CR_LF+"\par \pard ")
* cMemo := "{\pntext\pard\plain\f3\fs20\cgrid \loch\af3\dbch\af0\hich\f3 \'b7\tab}" ;
*          + cMemo
RETURN DrvCvtString(cMemo)


FUNCTION cpi2pt(nCpi)
RETURN 24 if nCpi <= 5
RETURN 12 if nCpi <= 10
RETURN 11 if nCpi <= 11
RETURN 10 if nCpi <= 12
RETURN  9 if nCpi <= 15
RETURN  8 if nCpi <= 16
RETURN  7 if nCpi <= 17
RETURN  6 if nCpi <= 18
RETURN  5 if nCpi <= 20
RETURN  4

