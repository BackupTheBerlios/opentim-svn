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


#include "tim.ch"
* #include "Lib.ch"

#ifdef DEF_LFN
#include "lfnlib.ch"
#endif DEF_LFN

static scDelim

static scTagStart := "["
static scTagStop := "]"

static sbOnDecExceed := {|cMont,nMaxDec| ;
  !SetMsg(ltrim(cMont) + MsgDecPos(nMaxDec));
}

* static sbOnDecExceed := {|cMont,nMaxDec| ;
*   Confirm( ;
*     ltrim(cMont) + MsgDecPos(nMaxDec), ;
*     MsgSure() ;
*   );
* }


#ifdef DEF_EID

// uncomment the following line to simulate a card reader:
// #define SIMULATE_CARD_READER

#define EID_ERROR      1
#define EID_CARDNUMBER 2
#define EID_CHIPNUMBER 3
#define EID_VALIDITY_BEGIN 4
#define EID_VALIDITY_END 5

#define EID_DELIVERY_MUNICIPALTIY  6
#define EID_NATIONAL_NUMBER 7
#define EID_NAME 8
#define EID_FIRSTNAME1 9
#define EID_FIRSTNAME2 10
#define EID_FIRSTNAME3 11
#define EID_NATIONALITY 12
#define EID_BIRTHPLACE 13
#define EID_BIRTHDATE 14
#define EID_GENDER 15
#define EID_NOBLE_CONDITION 16
#define EID_DOCTYPE 17
#define EID_WHITECANE 18
#define EID_YELLOWCANE 19
#define EID_EXTENDED_MINORITY 20

#define EID_STREET 21
#define EID_NUMBER 22
#define EID_BOX 23
#define EID_ZIP 24
#define EID_MUNICIPALTIY 25
#define EID_COUNTRY 26

#define EID_ALEN       26

* request EID_GET

#ifdef SIMULATE_CARD_READER

FUNCTION EID_GET_TEST
local a := array(EID_ALEN)
a[1 ] := NIL
a[2 ] := "640069343191"
a[3 ] := "534C494E336611296CFF346E31071028"
a[4 ] := "20050413"
a[5 ] := "20100413"
a[6 ] := "Eupen"
a[7 ] := "54051402050"
a[8 ] := "Mustermann"
a[9 ] := "Maria Ingrid"
a[10] := ""
a[11] := "M"
a[12] := "be"
a[13] := "Eupen"
a[14] := "19640514"
a[15] := "F"
a[16] := ""
a[17] := 1
a[18] := .f.
a[19] := .f.
a[20] := .f.
a[21] := "Meyergasse 62"
a[22] := ""
a[23] := ""
a[24] := "4700"
a[25] := "Eupen"
a[26] := "be"
RETURN a

#endif SIMULATE_CARD_READER

FUNCTION GetEid(lTest)
#ifdef SIMULATE_CARD_READER
  local a := EID_GET_TEST()
#else
  local a := EID_GET()
#endif
// Confirm("foo "+utos(a[EID_ERROR]))
RETURN a if a[EID_ERROR] != NIL
a[EID_NATIONALITY] := eid2nat(a[EID_NATIONALITY])
a[EID_COUNTRY] := eid2nat(a[EID_COUNTRY])
a[EID_BIRTHDATE] := stod(a[EID_BIRTHDATE])
a[EID_VALIDITY_BEGIN] := stod(a[EID_VALIDITY_BEGIN])
a[EID_VALIDITY_END] := stod(a[EID_VALIDITY_END])
if a[EID_GENDER] == "F"
  a[EID_GENDER] := "W"
endif
if year(a[EID_BIRTHDATE]) < 1800
  raise("Geboren im 18. Jahrhundert!?")
elseif year(a[EID_BIRTHDATE]) < 1900
  a[EID_NATIONAL_NUMBER] := left(a[EID_NATIONAL_NUMBER],6);
    + "*" + substr(a[EID_NATIONAL_NUMBER],7)
elseif year(a[EID_BIRTHDATE]) < 2000
  a[EID_NATIONAL_NUMBER] := left(a[EID_NATIONAL_NUMBER],6);
    + " " + substr(a[EID_NATIONAL_NUMBER],7)
elseif year(a[EID_BIRTHDATE]) < 2100
  a[EID_NATIONAL_NUMBER] := left(a[EID_NATIONAL_NUMBER],6);
    + "=" + substr(a[EID_NATIONAL_NUMBER],7)
else
  raise("Geboren im 22. Jahrhundert!?")
endif
a[EID_NATIONAL_NUMBER] := left(a[EID_NATIONAL_NUMBER],10);
    + "-" + substr(a[EID_NATIONAL_NUMBER],11)
a[EID_NAME] := utf2dos(a[EID_NAME])
a[EID_FIRSTNAME1] := utf2dos(a[EID_FIRSTNAME1])
a[EID_FIRSTNAME2] := utf2dos(a[EID_FIRSTNAME2])
a[EID_FIRSTNAME3] := utf2dos(a[EID_FIRSTNAME3])
a[EID_BIRTHPLACE] := utf2dos(a[EID_BIRTHPLACE])
a[EID_NOBLE_CONDITION] := utf2dos(a[EID_NOBLE_CONDITION])
a[EID_DELIVERY_MUNICIPALTIY] := utf2dos(a[EID_DELIVERY_MUNICIPALTIY])
a[EID_MUNICIPALTIY] := utf2dos(a[EID_MUNICIPALTIY])
a[EID_STREET] := utf2dos(a[EID_STREET])
if empty(a[EID_NUMBER]) .and. empty(a[EID_BOX])
  a[EID_NUMBER] := alltrim(Str2RueNum(a[EID_STREET]))
  a[EID_BOX]    := alltrim(Str2RueBte(a[EID_STREET]))
  a[EID_STREET] := alltrim(Str2Rue(a[EID_STREET]))
endif
RETURN a

FUNCTION eid2nat(x)
local cIdNat := x
open area oNat()
  go top
  do while ! eof()
    if upper(trim(NAT->IsoCode)) == upper(trim(x))
      cIdNat := NAT->IdNat
      exit
    endif
    skip
  enddo
close area
RETURN cIdNat

#endif DEF_EID



FUNCTION SetOnDecExceed(b)
RETURN sbOnDecExceed if b == NIL
sbOnDecExceed := b
RETURN .t.

FUNCTION MsgLoading(cFilename)
#ifdef LG_FRENCH
  RETURN "Chargement de " + cFilename + "..."
#endif
#ifdef LG_GERMAN
  RETURN cFilename + " wird geladen..."
#endif
#ifdef LG_EN
  RETURN "Loading " + cFilename + "..."
#endif

**
** NextStr()
**
FUNCTION NextStr( cStr )
local l := len(cStr)
local i
local nChar
for i := l to 1 step -1
  nChar := asc( substr(cStr,i,1) )
  if nChar < 255
    nChar++
    RETURN stuff( cStr, i, 1, chr(nChar) )
  else
    stuff( cStr, i, 1, " " )
  endif
next i
RETURN cStr + chr(255)

**
** NextNum()
**
FUNCTION NextNum(s,cPrefix,cPad)
local l
default cPad to "0"
if cPrefix == NIL
  cPrefix := ""
elseif left(s,len(cPrefix)) != cPrefix .and. ! empty(s)
  cPrefix := ""
endif
l := len(s) - len(cPrefix)
if val(right(s,l)) == 0
  RETURN cPrefix + padl("1",l,"0")
endif
RETURN cPrefix + strtran(str(val(right(s,l))+1,l)," ",cPad)

**
** PrevNum()
**
FUNCTION PrevNum(s)
local nLen := len(s)
local nStart := 0
local nVal := val(s)
do while nVal == 0
  if nStart == nLen
    RETURN space(len(s))
  endif
  nStart += 1
  nVal := val(substr(s,nStart+1))
enddo
RETURN left(s,nStart)+ strtran(str(nVal-1,nLen-nStart)," ","0")

**
** NextId()
**  Beispiele :
**  "123456" -> "123457"
**  "B01" -> "B02"
**  "B 1" -> "B02"
**  "B  " -> "B01"
**  "   " -> "001"
**  "AAA" -> "AAA"
**
FUNCTION NextId(s,cRoot)
local i
default cRoot to ""
if left(s,len(cRoot)) != cRoot .and. !empty(left(s,len(cRoot)))
  cRoot := left(s,len(cRoot))
endif
s := substr(s,len(cRoot)+1)
for i := 1 to len(s)
  if substr(s,i,1) $ " 0123456789"
    * RETURN cRoot + left(s,i-1) + ;
    *        strtran(str(val(substr(s,i))+1,len(s)-i+1)," ","0")
    cRoot += left(s,i-1)
    s := substr(s,i)
    if val(s)+1 < 10 ** len(s)
      s := str(val(s)+1,len(s))
      s := strtran(s," ","0")
    else
      if len(cRoot) > 0
        cRoot := NextStr(cRoot)
        s := repl("0",len(s))
      else
        cRoot := "A"
        s := repl("0",len(s)-1)
      endif
    endif
    RETURN cRoot + s
  endif
next i
RETURN cRoot + s

***
*** freadline()
***
FUNCTION fReadLine( handle )
local line := ""
local ch := freadstr(handle,1)
do while len(ch) <> 0
  if ch == chr(13)
    freadstr(handle,1)
    RETURN line
  elseif ch == chr(10)
    RETURN line // UNIX text file
  elseif ch == "\"        // Aha, ein "\" !
                          // Mal sehen, was danach kommt...
    ch := freadstr(handle,1)
    if ch == chr(13)      // CR_LF nach "\" wird ignoriert
      freadstr(handle,1)  // jetzt auch noch das chr(10) ignorieren...
      ch := freadstr(handle,1)
      do while len(ch) > 0 .and. ch == " "
        ch := freadstr(handle,1) // und alle Spaces am Anfang der
                                 // folgenden Zeile
      enddo
    else
      line += "\" + ch         // Fehlanzeige. War ein ganz normaler "\"
      ch := freadstr(handle,1)
    endif
  else
    line += ch
    ch := freadstr(handle,1)
  endif
enddo
RETURN NIL if empty(line)
RETURN line


FUNCTION MsgFileExist()
#ifdef LG_GERMAN
RETURN " : Datei existiert nicht !"
#endif
#ifdef LG_FRENCH
RETURN " : ce fichier n'existe pas !"
#endif
#ifdef LG_EN
RETURN " : no such file !"
#endif

**
**  AComp( <aArray>, <bComp>, [<nStart>], [<nStop>] ) --> valueElement
**  Compares all elements of aArray using the bComp block from nStart to
**  nStop (if specified, otherwise entire array) and returns the result.
**  Several sample blocks are provided in Array.ch.
**
FUNCTION AComp( aArray, bComp, nStart, nStop )
LOCAL value := aArray[1]
AEVAL( aArray, {|x| value := IIF( EVAL(bComp, x, value), x, value )}, ;
       nStart, nStop )
RETURN( value )


FUNCTION StdColor(cColor)
local aStr := ListAsArray(cColor,",")
RETURN aStr[1] if len(aStr) >= 1
RETURN ""

FUNCTION UnsColor(cColor)
local aStr := ListAsArray(cColor,",")
RETURN aStr[5] if len(aStr) >= 5
RETURN ""

FUNCTION BordColor(cColor)
local aStr := ListAsArray(cColor,",")
RETURN aStr[4] if len(aStr) >= 4
RETURN ""

FUNCTION EnhColor(cColor)
local aStr := ListAsArray(cColor,",")
RETURN aStr[2] if len(aStr) >= 2
RETURN ""



**
** Jour()
**
FUNCTION Jour(dDate,cLangue)
static aJoursF := { "Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi" }
static aJoursD := { "Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag" }
static aJoursN := { "Zondag", "Maandag", "Dinsdag", "Woensdag", ;
  "Donderdag", "Vrijdag", "Zaterdag" }
static aJoursK := { "PÅhapÑev", "EsmaspÑev", "TeisipÑev", "KolmapÑev",;
  "NeljapÑev", "Reede", "LaupÑev" }
static aJoursE := { "Sunday", "Monday", "Tuesday", "Wednesday", ;
  "Thursday", "Friday", "Saturday" }
local nJour := dow(dDate)
RETURN "" if nJour == 0
if empty(cLangue) ; cLangue := UsrLang() ; endif
RETURN aJoursF[nJour] if cLangue == "F"
RETURN aJoursD[nJour] if cLangue == "D"
RETURN aJoursN[nJour] if cLangue == "N"
RETURN aJoursK[nJour] if cLangue == "K"
RETURN aJoursE[nJour]


**
** SumArray()
**
FUNCTION SumArray( a, n )
local nSum := 0
local i
for i := 1 to len(a)
  nSum += a[i][n]
next i
RETURN nSum


**
** ArrayPick() - neue Version (nicht mehr achoice(), sondern MnuExec())
**
FUNCTION ArrayPick( aCodes, cTitle, ;
                    cStart, nLen, ;
                    cHelp, ;
                    aRetvals, ;
                    nRow, nCol, ;
                    bcUsing ;
                  )
local i
local nStart
local aHot := {}
if bcUsing == NIL
  bcUsing := {|x|x}
  if cStart != NIL
    nStart := ascan( aCodes, cStart )
  endif
endif
for i := 1 to len(aCodes)
  aadd(aHot,upper(left(eval(bcUsing,aCodes[i]),1)))
next i
default nStart to 1
browse array aCodes using (bcUsing) ;
       start nStart ;
       hotkeys aHot ;
       title (cTitle) ;
       home nRow, nCol ;
       delete {||.f.} ;
       help cHelp ;
       wrap
RETURN NIL if LastChoice() == 0
if aRetVals != NIL
  RETURN aRetVals[LastChoice()]
endif
if nLen != NIL
  RETURN padr(aCodes[LastChoice()],nLen)
endif
RETURN aCodes[LastChoice()]


#define ATR_CHAR   1
#define ATR_LIBELL 2
#define ATR_SELECT 3   // 1=on, -1=off or 0=gray

**
** PickAttrib()
** aAttrib:  { { <cChar>, <cLibell>, <nSelect> }, ... }
**
**
**
FUNCTION PickAttrib( aAttrib, cTitle, cStart, cDelim, cHelp )
local i
local cReturn := ""
local column
local cSet := alltrim(cStart)
local aHot := {}
local aActions := {}
aadd(aActions, { asc("*"), {|| ;
  AtrInvert(aAttrib,@cSet,cDelim), ;
  K_ALT_F5;
} } )
aadd(aActions, { K_SPACE , {|a| ;
  AtrToggle(a,@cSet,cDelim), ;
  K_DOWN ;
} } )

for i := 1 to len(aAttrib)
  aadd(aHot,aAttrib[i][ATR_CHAR])
  if len(aAttrib[i][ATR_CHAR]) > 1
    default cDelim to ","
    // default cDelim to " "
  else
    default cDelim to ""
  endif
next i
browse array aAttrib ;
       using {|a| if(a[ATR_CHAR] $ cSet,BUTTON_ON,BUTTON_OFF) ;
                  + " " + a[ATR_CHAR] + " : " + a[ATR_LIBELL]  }  ;
       hotkeys aHot ;
       actions aActions ;
       space {|a| AtrToggle(a,@cSet,cDelim) } ;
       help cHelp ;
       title (cTitle)
RETURN NIL if LastChoice() == 0
for i := 1 to len(aAttrib)
  if aAttrib[i][ATR_CHAR] $ cSet
    cReturn += aAttrib[i][ATR_CHAR] + cDelim
  endif
next i
if ! empty(cDelim)
  cReturn := left(cReturn,len(cReturn)-len(cDelim))
endif
RETURN cReturn if len(cStart) == 0
RETURN padr(cReturn,len(cStart))


FUNCTION AtrToggle(a,cStr,cDelim)
* if a[ATR_SELECT]
* if eval(a[ATR_SELECT])
*   Warning("Dieses Attribut kann nicht verÑndert werden !")
* endif
if a[ATR_CHAR] $ cStr
  cStr := strtran(cStr,a[ATR_CHAR])
else
  cStr += cDelim + a[ATR_CHAR]
endif
RETURN NIL

FUNCTION AtrInvert(aAttrib,cSet,cDelim)
local i
for i := 1 to len(aAttrib)
  AtrToggle(aAttrib[i],@cSet,cDelim)
next i
RETURN NIL


**
** PickAction
**
*FUNCTION PickAction(aOpt,cTitle)
*local nChoice := 0
*do while .T.
*  browse array aOpt ;
*    using {|a| a[1] } ;
*    enter {|a| eval(a[2]) } ;
*    title cTitle ;
*    to nChoice
*  if nChoice == 0 .or. AppTerminate()
*    exit
*  endif
*enddo
*RETURN NIL

**
** JoinArray
**
FUNCTION JoinArray( aArrays )
local aJoined := {}
local i, j
for i := 1 to len( aArrays )
  for j := 1 to len( aArrays[i] )
    aadd( aJoined, aArrays[i][j] )
  next j
next i
RETURN aJoined



**
** GetPad()
**
FUNCTION GetPad(cId,cPad,cPrefix)
local nLen := len(cId)
local nVal
if len(trim(cId)) == nLen
  RETURN cId
endif
default cPad to "0"
if cPrefix == NIL
  cPrefix := ""
else
  nLen -= len(cPrefix)
  if left(cId,len(cPrefix)) == cPrefix
    cId := right(cId,nLen)
  else
    cId := left(cId,nLen)
  endif
endif
if (nVal := val(cId)) != 0
  cId := padl(trim(cId),nLen,cPad)
endif
RETURN cPrefix + cId


**
**  WriteIni2()
**  aItems[i] is : { <cKeyWord> , <cType> , <uDefaultValue> }
**
FUNCTION WriteIni2( aItems, cFileName, aComments )
local i, fd
fd := fcreate(cFileName)
RETURN .F. if fd == -1
if aComments != NIL
  for i := 1 to len(aComments)
    fwrite( fd, aComments[i] + CR_LF )
  next i
  fwrite( fd, CR_LF)
endif
for i := 1 to len(aItems)
  if aItems[i][2] == "C"
    fwrite( fd, aItems[i][1] + "  " + eval(aItems[i][3]) + CR_LF )
  elseif aItems[i][2] == "N"
    fwrite( fd, aItems[i][1] + "  " + ntrim(eval(aItems[i][3])) + CR_LF )
  elseif aItems[i][2] == "L"
    fwrite( fd, aItems[i][1] + "  " + if(eval(aItems[i][3]),"ON","OFF") + CR_LF )
  endif
next i
fclose(fd)
RETURN .T.

FUNCTION CopyRight()
RETURN "(c) 1993-2001 PAC Systems, (c) 2001-2008 Rumma & Ko"


** #ifdef DEF_FFCOPYRIGHT
** #include "paceff.rig"
** #else
** #include "pac.rig"
** #endif
*#include "rumma.rig"
*
*FUNCTION CopyRight()
*local c := ""
*local a := aCopyRight
*local i
*for i := 1 to len(a)
* c += chr(a[i])
*next i
*RETURN c

FUNCTION SetDbcDelimiter(x)
RETURN scDelim if x == NIL
scDelim := x
RETURN .t.


**
** ReadArray()
**
** [970227] : neuer Parameter bFilter
**
FUNCTION ReadArray(cName,nLen,cDelim,cPath,bFilter)
* local cFileName
local fd
local cLine
local c
local a := {}
local nCut
local aItem
local nLine := 0
local cDllPath := GetDlmPath(cName)
local i
default cDelim to "|"
scDelim := cDelim
* default cPath  to DbPath()
* cFileName := cPath + "\" + cName
if cDllPath == NIL
  Warning(cName+MsgFileExist())
  RETURN a
endif
if (fd := mopen(cDllPath)) == NIL
  Warning(SetMsg())
  RETURN a
endif
MsgDisplay("Loading " + cDllPath + "...")
do while (cLine := mreadline(fd)) != NIL
  nLine++
  if (nCut := at("//",cLine)) != 0
    cLine := left(cLine,nCut-1)
  endif
  if ! empty(cLine)
    aItem := ListAsArray(cLine,scDelim)
    default nLen to len(aItem)
    if nLen == 0 .and. len(aItem) == 1
      aadd(a, aItem[1])
    elseif len(aItem) == nLen
      if bFilter == NIL .or. eval(bFilter,aItem)
        // 20021028
        for i := 1 to len(aItem)
          if left(aItem[i],1) == "="
            aItem[i] := xparse(substr(aItem[i],2))
          endif
        next i
        aadd(a, aItem)
      endif
    else
      Warning( ;
        cDllPath + MsgDbcError() + ntrim(nLine), ;
        NIL, "WRN052" ;
      )
    endif
  endif
enddo
mclose(fd)
MsgDisplay("")
RETURN a

FUNCTION MsgDbcError()
#ifdef LG_GERMAN
RETURN " : ungÅltige Daten in Zeile "
#endif
#ifdef LG_FRENCH
RETURN " : donnÇes invalides en ligne "
#endif
#ifdef LG_EN
RETURN " : invalid data in line "
#endif




#ifdef LG_GERMAN
#define MSG_STRANGE " : Zahl enthÑlt nicht-numerische Zeichen."
#endif
#ifdef LG_FRENCH
#define MSG_STRANGE " : contient des caractäres non numÇriques."
#endif
#ifdef LG_EN
#define MSG_STRANGE " : contains non-numeric characters."
#endif

**
** GetNum()
**
FUNCTION GetNum(cMont,nMinDec,nMaxDec)
local nDec
local nLen
local cSaved  
default nMinDec to 0
RETURN cMont if empty(cMont)
nLen := len(cMont)
cMont := strtran(alltrim(cMont),",",".")
if right(cMont,1) == "-"
  cMont := "-" + left(cMont,len(cMont)-1)
endif
nDec  := MntDecPos(cMont)
if nDec < nMinDec
  cSaved := cMont
  if nDec == 0
    cMont += "."
  endif
  cMont += repl("0",nMinDec - nDec)
  RETURN padl(cSaved,nLen) if len(cMont) > nLen // neu 20041118
  nDec := nMinDec
endif
if nMaxDec == NIL
  nMinDec := nDec
else
  ** neu 950810
  ** Nadia hatte "1.825.648" in einer OD eingegeben,
  ** TIM nahm ohne Warnung als Wert "2" an
  if nDec > nMaxDec
    if xeval(sbOnDecExceed,cMont,nMaxDec)
      nMinDec := nDec // sonst kommt ja spÑter MSG_STRANGE
    else
      RETURN str(val(cMont),nLen,nMaxDec)
    endif
  endif
endif
cMont := padl(cMont,nLen)
if str(val(cMont),nLen,nMinDec) != cMont
  RETURN str(val(cMont),nLen,nMinDec) if ! Confirm( ;
    ltrim(cMont) + MSG_STRANGE, ;
    MsgSure(), ;
    MSG_YES ;
  )
endif
RETURN cMont

FUNCTION MsgDecPos(nMaxDec)
#ifdef LG_FRENCH
  RETURN " : montant avec plus de " + ntrim(nMaxDec) + " positions dÇcimales."
#else
  RETURN " : mehr als " + ntrim(nMaxDec) + " Nachkommastellen."
#endif

* FUNCTION MsgNotFound
* #ifdef LG_GERMAN
* RETURN " : nicht gefunden !"
* #endif
* #ifdef LG_FRENCH
* RETURN " : n'existe pas !"
* #endif


FUNCTION MsgRetry()
#ifdef LG_GERMAN
  RETURN "Neu versuchen (J/N) ?"
#endif
#ifdef LG_FRENCH
  RETURN "RÇessayer (O/N) ?"
#endif
#ifdef LG_EN
  RETURN "Retry (Y/N) ?"
#endif

FUNCTION ctol(x)
RETURN .t. if upper(x) == "ON"
RETURN .f. if upper(x) == "OFF"
RETURN xparse(x)

FUNCTION MemoDisplay( ;
  cMemo, ;
  nRow,nCol,nHeight,nWidth, ;
  cColor, ;
  nOffset,nWrapLen,nLeft, cBoxFrame ;
)
local i
default nOffset to 0
default nLeft to 1
default nWrapLen to nWidth
if ! empty(cBoxFrame)
  dispbox(nRow-1,nCol-1,nRow+nHeight,nCol+nWidth,cBoxFrame)
endif
nWrapLen := min(nWrapLen,254)
for i := 1 to nHeight
  @ nRow, nCol say padr( ;
    substr(memoline(cMemo,nWrapLen,i+nOffset), nLeft, nWidth), ;
  nWidth) color (cColor)
  nRow++
next i
RETURN .t.


FUNCTION WinEdit( ;
  ad, ;
  cTitle, cIdQry, ;
  bAfter, ;
  bKeyBlock, cKeyValue ;
)
default cIdQry to ad[AD_NAME]
cTitle := trim(strtran(cTitle,"~"))
open area ad
  edit data ad ;
            start top ;
            mode find ;
            query (cIdQry) ;
            title (cTitle)
  if ad[AD_UPDATED]
    if bAfter != NIL
      eval(bAfter)
    endif
  endif
close area
RETURN .f.

FUNCTION DbfEdit( ;
  a,cTitle,cIdQry,nMode,xlFilter,cKeyValue,xcKey,;
  xuReturn, xbCreate, aWindow, nStart, bOnIdle ;
)
* nStart 2 : bottom
local bCreate
default cIdQry to a[1][AD_NAME]
default cTitle to a[1][AD_NAME]
default nMode to DDMODE_FIND
default nStart to DDSTART_TOP
if xbCreate != NIL
  bCreate := xparse( "{||" + xbCreate + "}" )
endif
begin sequence
  if ! AreaOpen( a, .f. ) ; break ; endif
  edit data a[1] ;
            start (nStart) ;
            mode (nMode) ;
            query (cIdQry) ;
            title (cTitle) ;
            onidle (bOnIdle) ;
            filter (xlFilter) ;
            create (bCreate) ;
            key (xcKey) ;
            value (cKeyValue) ;
            window (aWindow)
  AreaClose()
end sequence
RETURN &xuReturn if xuReturn != NIL
RETURN .t.

FUNCTION DbfPick( ;
  a,cTitle,cIdQry,cStart,xlFilter,cKeyValue,xcKey,;
  xuReturn, bCreate, aRecnos ;
)
local nStart := 1 // 1 : go top, 2: go bottom, 0: softseek cStart
local uReturn := NIL
default cIdQry to a[1][AD_NAME]+"PICK"
default xuReturn to a[1][AD_AINDEX][1][AI_EXPR]
default cTitle to "Auswahl " + a[1][AD_NAME]
begin sequence
  if ! AreaOpen( a, .f. ) ; break ; endif
  if ! empty(cStart)
    seek cStart
    if !eof()
      nStart := 0
      cStart := NIL
    else
      nStart := 0
    endif
  endif
  edit data a[1] ;
            mode (DDMODE_PICK) ;
            query (cIdQry) ;
            title (cTitle) ;
            filter (xlFilter) ;
            key (xcKey) ;
            value (cKeyValue) ;
            softseek (cStart) ;
            start (nStart) ;
            create (bCreate) ;
            recnos (aRecnos)
  if ddLastReq() == DDEDIT_SELECT
    * default xuReturn to indexkey()
    uReturn := &xuReturn
  endif
  AreaClose()
end sequence
RETURN uReturn




FUNCTION DbfLook(b,cKey,cReturn,uReturn)
open area b
  seek cKey
  if found()
    uReturn := &cReturn
  endif
close area
RETURN uReturn


*FUNCTION DbfReplace( ;
*  a,cStart,xlWhile,xlFilter,;
*)
*local bCreate
*default cIdQry to a[1][AD_NAME]
*default cTitle to a[1][AD_NAME]
*default nMode to DDMODE_FIND
*if xbCreate != NIL
*  bCreate := xparse( "{||" + xbCreate + "}" )
*endif
*begin sequence
*  if ! AreaOpen( a, .f. ) ; break ; endif
*  default
*  edit data a[1] ;
*            start top ;
*            mode (nMode) ;
*            query (cIdQry) ;
*            title (cTitle) ;
*            filter (xlFilter) ;
*            create (bCreate) ;
*            key (xcKey) ;
*            value (cKeyValue)
*  AreaClose()
*end sequence
*RETURN &xuReturn if xuReturn != NIL
*RETURN .f. // (ddLastKey() == K_F10) // .f.

FUNCTION ntrim0(n)
RETURN ltrim(str(n,15,0))

FUNCTION trimcr(c)
c := trim(c)
do while right(c,2) == CR_LF
  c := trim(left(c,len(c)-2))
enddo
RETURN c

#ifdef DEF_ACT

FUNCTION DefExec(cAlias)
RETURN FileExec(cAlias + ".DEF")

FUNCTION ActExec(cActName,p)
RETURN FileExec(cActName + ".ACT",p)

#endif DEF_ACT

**
** trim1
**
FUNCTION trim1(cStr,cDelim)
RETURN "" if empty(cStr)
default cDelim to " "
RETURN trim(cStr) + cDelim

FUNCTION trim1b(cStr,cDelim)
RETURN "" if empty(cStr)
default cDelim to " "
RETURN cDelim + trim(cStr)



FUNCTION MsgSure(cLangue)
#ifdef LG_GERMAN
  RETURN "Sind Sie sicher (J/N) ?"
#endif
#ifdef LG_FRENCH
  RETURN "Etes-vous certain (O/N) ?"
#endif
#ifdef LG_EN
  RETURN "Are you sure (Y/N) ?"
#endif

FUNCTION MsgWorking()
#ifdef LG_GERMAN
  RETURN "Arbeitsvorgang lÑuft..."
#endif
#ifdef LG_FRENCH
  RETURN "Travail en cours..."
#endif
#ifdef LG_EN
  RETURN "Working..."
#endif

FUNCTION DbfPeek(b,cSeekKey,xuReturn,uReturn,nOrder)
if valtype(xuReturn) == "C"
  xuReturn := cblock(xuReturn)
endif
open area b
  if nOrder == NIL
    seek cSeekKey
    if ! eof()
      uReturn := eval(xuReturn)
    endif
  else
    ddSetOrder(nOrder)
    softseek cSeekKey
    if ! eof() .and. left(&(indexkey()),len(cSeekKey)) == cSeekKey
      uReturn := eval(xuReturn)
    endif
  endif
close area
RETURN uReturn



FUNCTION DbfScramble(b,aFields)
local nCount := 0
local i
RETURN .f. if ! Confirm( ;
  "WARNING! Data in " + b[AD_NAME] + " will be scrambled !", ;
  MsgSure() ;
)
open area b
  ddSetOrder()
  go top
  do while ! eof()
    if TaskInter() ; exit ; endif
    MsgDisp2(ntrim0(nCount++ * 100 / lastrec()) + "%")
    if ddRecLock()
      for i := 1 to len(aFields)
        &("FIELD->"+aFields[i]) := StrScramble(&("FIELD->"+aFields[i]))
      next i
      unlock record
    endif
    skip
  enddo
close area
RETURN MnuDone()


STATIC FUNCTION StrScramble(cStr)
local i
local cNew := ""
for i := 1 to len(cStr)
  cNew += ChrScramble(substr(cStr,i,1))
next i
RETURN cNew

STATIC FUNCTION ChrScramble(c)
local cSelbst := "aeiouy"
local i,j
local nPos
RETURN c if ! isalpha(c)
if (nPos := at(c,cSelbst)) != 0
  RETURN left(cSelbst,1) if nPos == len(cSelbst)
  RETURN substr(cSelbst,nPos+1,1)
endif
cSelbst := upper(cSelbst)
if (nPos := at(c,cSelbst)) != 0
  RETURN left(cSelbst,1) if nPos == len(cSelbst)
  RETURN substr(cSelbst,nPos+1,1)
endif
c := chr(asc(c)+1)
RETURN c


FUNCTION ForLoop(nFrom,nTo,bBlock)
local i
for i := nFrom to nTo
  RETURN .f. if ! eval(bBlock,i)
next i
RETURN .t.

FUNCTION WhileLoop(xlWhile,xlDo)
default xlDo to {||.t.}
do while eval(xlWhile)
  RETURN .f. if ! eval(xlDo)
enddo
RETURN .t.



**
**
**
FUNCTION KeyGetSet(x,cKey,bMemo,uDefault)
local cMemo := eval(bMemo)
local cNewMemo := ""
local nPos
if x == NIL
  RETURN uDefault if (nPos := at(scTagStart+cKey+"=",cMemo)) == 0
  cMemo := substr(cMemo,nPos+len(cKey)+len(scTagStart)+1)
  RETURN uDefault if (nPos := at(scTagStop,cMemo)) == 0
  RETURN xparse(left(cMemo,nPos-1))
endif
if (nPos := at(scTagStart+cKey+"=",cMemo)) == 0
  cNewMemo := cMemo
else
  cNewMemo := left(cMemo,nPos-1)
  cMemo := substr(cMemo,nPos+len(cKey)+len(scTagStart)+1)
  if (nPos := at(scTagStop,cMemo)) == 0
    Warning("KeyGetSet() : Das geht wohl nicht !")
  else
    cNewMemo += substr(cMemo,nPos+1)
  endif
endif
if x != uDefault
  cNewMemo += scTagStart + cKey + "="
  if valtype(x) == "C"
    x := strtran(x,'"','"+chr(34)+"')
    x := strtran(x,scTagStop,"")
    x := strtran(x,scTagStart,"")
    cNewMemo += '"' + x + '"'
  elseif valtype(x) == "D"
    cNewMemo += 'ctod("' + dtoc(x) + '")'
  endif
  cNewMemo += scTagStop
endif
RETURN eval(bMemo,cNewMemo)

FUNCTION ChkRange(uValue,uMin,uMax)
if empty(uMin) .or. uValue >= uMin
  if empty(uMax) .or. uValue <= uMax
    RETURN .t.
  endif
endif
RETURN .f.


FUNCTION on(n,x0,x1,x2)
RETURN x0 if n == 0
RETURN x1 if n == 1
RETURN x2

**
** DbfWhileExist()
**
FUNCTION DbfWhileExist(adTables,nOrder,cStart,blOnExist)
** used @ agv/venpps.rep
local lOkay := .t.
local xlWhile
// local b := cblock(xlOnExist)
BEGIN SEQUENCE
  if ! AreaOpen(adTables,.f.) ; BREAK ; endif
  ddSetOrder(nOrder)
  xlWhile := "left("+indexkey()+","+ntrim(len(cStart))+")=='"+cStart+"'"
  lOkay := .t.
  do while .t.
    softseek (cStart)
    if eof().or.! &xlWhile
      exit
    endif
    if ! TryRecLock(blOnExist)
      if !Confirm(MsgContinue())
        lOkay := .f.
        exit
      endif
    endif
  enddo
  AreaClose()
END SEQUENCE
RETURN lOkay

**
** DbfSum() --- Ñhnlich wie DbfList
**
FUNCTION DbfSum(adTables,xnValue,nOrder,cStart,xlWhile,xlFilter,lDescend)
local lOkay := .t.
local nSum := 0
default nOrder to 1
default cStart to ""
default xlFilter to ".t."
// Confirm("DbfSum: "+xnValue+", "+cStart+", "+xlWhile+", "+xlFilter)
if valtype(xnValue)=="C"
  xnValue := cblock(xnValue)
endif
BEGIN SEQUENCE
  if ! AreaOpen(adTables,.f.) ; BREAK ; endif
  ddSetOrder(nOrder,lDescend)
  default xlWhile to "left("+indexkey()+","+ntrim(len(cStart))+")=='"+cStart+"'"
  * if valtype(eval(xnValue)) != "N"
  *   Warning("type(xnValue) is " + type(xnValue) )
  *   lOkay := .f.
  * endif
  if valtype(xparse(xlWhile)) != "L"
    Warning("type(xlWhile) is " + type(xlWhile) )
    lOkay := .f.
  endif
  if valtype(xparse(xlFilter)) != "L"
    Warning("type(xlFilter) is " + type(xlFilter) )
    lOkay := .f.
  endif
  if lOkay
    dbsoftseek(cStart)
    do while ! eof() .and. &xlWhile
      * if TaskInter() ; p_abort() ; exit ; endif
      if &xlFilter
        nSum += eval(xnValue)
      endif
      skip
    enddo
  endif
  AreaClose()
END SEQUENCE
RETURN nSum

**
** DbfList() --- Ñhnlich wie DbfSum()
**
** FUNCTION DbfList(adTables,cTpl,nOrder,cStart,xlWhile,xlFilter)
FUNCTION DbfTplScan(adTables,cTpl,nOrder,cStart,xlWhile,xlFilter)
local nSum := 0
default nOrder to 1
default cStart to ""
default xlFilter to ".t."
BEGIN SEQUENCE
  if ! AreaOpen(adTables,.f.) ; BREAK ; endif
  ddSetOrder(nOrder)
  default xlWhile to "left("+indexkey()+","+ntrim(len(cStart))+")=='"+cStart+"'"
  softseek (cStart)
  do while ! eof() .and. &xlWhile
    if &xlFilter
      TplParse(cTpl)
    endif
    skip
  enddo
  AreaClose()
END SEQUENCE
RETURN NIL


FUNCTION DbfRecall(a,xlFilter)
local lOkay := .f.
*local cNoConfirm := BUTTON_OFF
*local cFilter := space(100)
*open window ("recall deleted records") size 4,50
*say "Filter : "
*get cFilter picture "@k@s30"
*get cNoConfirm checkbox
*say "no confirm"
*nKey := ReadScr()
*close window
*RETURN NIL if nKey == K_ESC
RptWrite("DbfRecall() "+a[1][AD_NAME]+" FOR "+xlFilter)
set deleted off
begin sequence
  if ! AreaOpen( a, .f. ) ; break ; endif
  lOkay := .t.
  go top
  do while lOkay .and. ! eof()
    if TaskInter()
      lOkay := .f.
      exit
    endif
    if deleted()
      if &xlFilter
        if ddRecLock()
          *if cNoConfirm == BUTTON_ON .or. Confirm(ntrim(recno())+" : undelete?")
            recall
          *endif
          unlock record
        else
          lOkay := .f.
        endif
      endif
    endif
    skip
  enddo
  AreaClose()
end sequence
set deleted on
RETURN lOkay

FUNCTION dbsoftseek(cStart)
#ifdef __XPP__
  if UseDbe()=="FOXCDX"
    dbseek(cStart,.t.,NIL,dbdescend())
  else
    softseek cStart
  endif
#else
  softseek cStart
#endif __XPP__
RETURN NIL

FUNCTION DbfScan(a,nOrder,cStart,xlWhile,xlFilter,xlEval,nMaxCount,;
                 lTaskInter,lDescend)
local lOkay := .f.
local nCount := 0
local lOldDescend := dbdescend()
#ifdef DEF_DEBUG
  local cLine := 'DbfScan() : start="'
#endif DEF_DEBUG
default cStart to ""
default xlFilter to {||.t.}
default lTaskInter to .t.
default lDescend to .f.
RETURN .t. if a == NIL
if valtype(xlEval)=="C"
  xlEval := cblock(xlEval)
endif
if valtype(xlFilter)=="C"
  xlFilter := cblock(xlFilter)
endif
*#ifdef DEF_DEBUG
*  // cLine += cStart + '"'
*  cLine += ' xlWhile=' + utos(xlWhile)
*  cLine += ' xlFilter="' + xlFilter      +'"'
*  * cLine += ' xlEval="' + xlEval          +'"'
*  SendConsole(cLine)
*#endif DEF_DEBUG
* 20020304 : DbfScan() macht jetzt kein ddCloseAll() mehr
* ddCloseAll()
* warum war denn das? Jedenfalls fÅhrte das in ARCHIV.ACT dazu, dass
* jedes Mal alle Dateien geschlossen wurden.
begin sequence
  *#ifdef DEF_DEBUG
  *  PushSequence()
  *#endif DEF_DEBUG
  if ! AreaOpen( a, .f. ) ; break ; endif
  lOkay := .t.
  if nOrder != NIL
    ddSetOrder(nOrder,lDescend)
  endif
  if indexord() != 0
    dbsoftseek(cStart)
  else
    go top
  endif
  if len(cStart) == 0
    default xlWhile to ".t."
  else
    default xlWhile to "left(" + indexkey() + "," ;
            + ntrim(len(cStart)) + ")=='" + cStart + "'"
  endif
  do while ! eof() .and. &xlWhile
    if lTaskInter
      MsgDisp2(ntrim0(nCount++ * 100 / lastrec()) + "%")
      if TaskInter() ; lOkay := .f.; exit ; endif
    endif
    if xeval(xlFilter)
      if ! xeval(xlEval)
        lOkay := .f.
        exit
      endif
    endif
    skip
    if nMaxCount != NIL .and. nCount > nMaxCount
      exit
    endif
  enddo
  AreaClose()
end sequence
  *#ifdef DEF_DEBUG
  *  popSequence()
  *#endif DEF_DEBUG
#ifdef __XPP__
  if used()
    dbSetDescend(lOldDescend)
  endif
#endif __XPP__
RETURN lOkay

FUNCTION DbfSetField(b,cKey,cFieldname,uValue)
local lOkay := .f.
open area b
  seek cKey
  if ! eof()
    if ddRecLock()
      &(b[AD_NAME]+"->"+cFieldname) := uValue
      unlock record
      lOkay := .t.
    endif
  endif
close area
RETURN .t.


FUNCTION netto(nBrutto,nSatz)
RETURN ( (100 * (nBrutto)) / (100 + nSatz) )


FUNCTION FileDate(cFilename)
local aDir
static sdDate := NIL
static scFilename := NIL
if cFilename == scFilename
  RETURN sdDate
endif
aDir := directory(cFilename)
RETURN ctod("") if len(aDir) != 1
sdDate := aDir[1][F_DATE]
scFilename := cFilename
RETURN sdDate

#ifdef DEF_LFN

FUNCTION fdate(cFilename)
local a := lf_getftime(cFilename)
RETURN ctod("") if len(a) == 0
RETURN a[LFN_FDATE]

FUNCTION ftime(cFilename)
local a := lf_getftime(cFilename)
RETURN "" if len(a) == 0
RETURN a[LFN_FTIME]

FUNCTION fsize(cFilename)
RETURN lf_getfsize(cFilename)

FUNCTION fexist(cFilename)
RETURN lf_isfile(cFilename)


#else

FUNCTION fdate(cFilename)
local aDir := directory(cFilename)
RETURN ctod("") if len(aDir) != 1
RETURN aDir[1][F_DATE]

FUNCTION ftime(cFilename)
local aDir := directory(cFilename)
RETURN "" if len(aDir) != 1
RETURN aDir[1][F_TIME]

FUNCTION fsize(cFilename)
local aDir := directory(cFilename)
RETURN 0 if len(aDir) != 1
RETURN aDir[1][F_SIZE]

FUNCTION fexist(cFilename)
RETURN file(cFilename)

#endif

** pad "split"
FUNCTION pads(c1,c2,nWidth) ; RETURN c1 + padl(c2,nWidth-len(c1))

FUNCTION trims(c,cLeft,cRight)
RETURN "" if empty(c)
RETURN cLeft + trim(c) + cRight

FUNCTION InRange(u,u1,u2)
if !empty(u1)
  RETURN .f. if u < u1
endif
if !empty(u2)
  RETURN .f. if u > u2
endif
RETURN .t.

FUNCTION ntrim(nNumber)
RETURN "NIL" if nNumber == NIL
RETURN ltrim(str(nNumber))

FUNCTION IsNewId(cId)
local lDescend := dbdescend()
local nOrder := indexord()
local lIsNew
ddSetOrder(1)
seek cId
lIsNew := eof()
ddSetOrder(nOrder,lDescend)
RETURN lIsNew





FUNCTION IsUnique(cId)
local nRecNo := recno()
local lOkay := .t.
seek cId
if found()
  SetMsg(cId + MsgNotUnique())
  lOkay := .f.
endif
goto (nRecNo)
RETURN lOkay

FUNCTION MsgNotUnique
#ifdef LG_GERMAN
  RETURN " : diese Identifizierung existiert bereits !"
#else
  RETURN " : cette identification existe dÇjÖ !"
#endif

**
**
**
FUNCTION AddIfNotNil(a,uNotNil)
RETURN .f. if uNotNil == NIL
aadd(a, uNotNil)
RETURN .t.

#ifdef DEF_DEBUG

PROCEDURE ShowCallStack
local nCursor := setcursor(SC_NORMAL)
local i := 2
local cMemo := ""
while ( !empty(ProcName(i)) )
  cMemo += "Called from " + trim(ProcName(i))
  cMemo += "(" + ntrim(procline(i)) + ")" + CR_LF
  i++
enddo
open window ("Callstack") size 20,80
  TxtEdit( ;
    {|x| cMemo }, ;
    WinTop(), WinLeft(), WinEndY(), WinEndX(), ;
    .f., 250, NIL ;
  )
close window
setcursor(nCursor)
RETURN

#endif DEF_DEBUG

FUNCTION avalue(a,i,j,k)
if k == NIL
  if j == NIL
    RETURN a[i]
  endif
  RETURN a[i][j]
endif
RETURN a[i][j][k]

**
** iisect() - inclusive intersect
**
FUNCTION iisect(a1,a2,b1,b2)
if a1 <= b1
  if a2 >= b1
    * if a2 >= b2
      RETURN .t. // (b2 - b1)
    * else
    *   RETURN .t. // (a2 - b1)
    * endif
  else
    RETURN .f. // 0
  endif
else
  if a1 <= b2
    RETURN .t.
  else
    RETURN .f. // 0
  endif
endif
RETURN NIL // never reached

FUNCTION GetCdu(x,a)
local nPos
local nLevel := 1
local cReturn := ""
default a  to { 2, 2, 2 }
while (nPos := at(".",x)) > 0
  if nLevel > len(a)
    exit
  endif
  cReturn += padl(alltrim(left(x,nPos-1)),a[nLevel])
  x := substr(x,nPos+1)
  nLevel++
enddo
if nLevel <= len(a)
  cReturn += padl(alltrim(x),a[nLevel])
endif
RETURN cReturn


FUNCTION SayCdu(x,a)
local i
local cReturn := ""
local nLen := len(x)
local c
default a  to { 2, 2, 2 }
nLen += len(a) - 1
for i := 1 to len(a)
  c := alltrim(left(x,a[i]))
  if empty(c)
    exit
  endif
  cReturn += c
  if i != len(a)
    cReturn += "."
  endif
  x := substr(x,a[i]+1)
next i
RETURN padr(cReturn,nLen)

**
** (Import Stammdaten Willy Reinartz)
**
FUNCTION numonly(s)
local r := ""
local i,c
for i := 1 to len(s)
  c := substr(s,i,1)
  if c $ "0123456789"
    r += c
  endif
next i
RETURN r

FUNCTION Memo2Tex(c)
local r := ""
c := trim(c)
do while right(c,2) == CR_LF
  c := trim(left(c,len(c)-2))
enddo
c := strtran(trim(c),chr(141)," ")
if left(c,4) == "#TeX"
  if substr(c,5,2) == CR_LF
    RETURN substr(c,7)
  else
    RETURN substr(c,5)
  endif
endif
c := strtran(trim(c),chr(13)+chr(10),"\newline ")
RETURN DrvCvtString(c)

*#ifdef DEF_LFN
*
*FUNCTION FileDelete(cFilename,lConfirm,lOnlyIfExists)
*local cDllPath := GetDlmPath(cFilename)
*default lOnlyIfExists to .f.
*if ! lf_isfile(cFilename)
*  if lOnlyIfExists
*    RETURN .t.
*  else
*    SetMsg(cFilename+MsgFileExist())
*    RETURN .f.
*  endif
*endif
*default lConfirm to .t.
*if lConfirm
*  RETURN .f. if ! Confirm( MsgFerase(cDllPath), MsgSure())
*endif
*if ! lf_ferase(cFilename)
*  SetMsg(cDllPath + MsgDosError(ferror()))
*  RETURN .f.
*endif
*RETURN .t.
*
*#else

FUNCTION FileDelete(cFilename,lConfirm,lOnlyIfExists)
local cDllPath
cFilename := trim(cFilename)
cDllPath := GetDlmPath(cFilename)
default lOnlyIfExists to .f.
if cDllPath == NIL
  if lOnlyIfExists
    RETURN .t.
  else
    SetMsg(cFilename+MsgFileExist())
    RETURN .f.
  endif
endif
default lConfirm to .t.
if lConfirm
  RETURN .f. if ! Confirm( MsgFerase(cDllPath), MsgSure())
endif
#ifdef DEF_LFN
if ! lf_ferase(cDllPath)
#else
if ferase(cDllPath) != 0
#endif
  RETURN ! SetMsg(cDllPath + MsgDosError(ferror()))
endif
RETURN .t.

* #endif


#ifdef DEF_EAN
// see ...\wiladt\eandoc.tex
*FUNCTION EAN2Tex(src)
*static atab := {  ;
*  {0,0,0,0,0,0}, ;
*  {0,0,1,0,1,1}, ;
*  {0,0,1,1,0,1}, ;
*  {0,0,1,1,1,0}, ;
*  {0,1,0,0,1,1}, ;
*  {0,1,1,0,0,1}, ;
*  {0,1,1,1,0,0}, ;
*  {0,1,0,1,0,1}, ;
*  {0,1,0,1,1,0}, ;
*  {0,1,1,0,1,0}  ;
*}
*local i
*local n
*local target
*src := strtran(src,".")
*target := left(src,1)+" +"
*for i := 1 to 6
*  n := val(substr(src,i+1,1))
*  target += chr(65+n+atab[val(left(src,1))+1][i]*32)
*next i
*target += "-"
*for i := 1 to 6
*  n := val(substr(src,i+7,1))
*  target += chr(75+n)
*next i
*RETURN "\eanfont"+target

FUNCTION GetEAN13(x,cPrefix,cPicture)
local src := alltrim(strtran(x,"."))
local r := ""
local c
RETURN x if len(src) == 13
if len(src) + len(cPrefix) <= 12
  src := cPrefix + repl("0",12-len(cPrefix+src)) + src
endif
if len(src) == 12
  src += EANCheckChar(src)
endif
default cPicture to "@r " ;
  +repl("9",len(cPrefix))+"." ;
  +repl("9",12-len(cPrefix)) ;
  +".9"
RETURN transform(src,cPicture)

*FUNCTION GetEAN13(x)
*local src := alltrim(strtran(x,"."))
*local r := ""
*local c
*RETURN x if len(src) != 12
*src += EANCheckChar(src)
*RETURN transform(src,"@r 9.999999.999999")

*FUNCTION EANCheckChar(src)
*local i
*local c
*for i := 0 to 9
*  c := chr(48+i)
*  RETURN c if EANChkSum(src+c) == 0
*next i
*RETURN "*"
*// die letzte Ziffer muss so sein, dass Checksum % 10 Null ist

FUNCTION EANCheckChar(src)
local i
local nCheckSum := 0
for i := 1 to 12
  nCheckSum += (val(substr(src,i,1)) * if(i % 2 == 0, 3, 1))
next i
if nCheckSum % 10 == 0
  RETURN "0" // chr(48 + nCheckSum % 10)
endif
RETURN chr( 48 + 10 - (nCheckSum % 10))


FUNCTION IsEAN13(x)
local i
local src := alltrim(strtran(x,"."))
local r := ""
local c
if len(src) != 13
  SetMsg("UngÅltige EAN-Nummer (muss 13 Ziffern enthalten) !")
  RETURN .f.
endif
c := EANCheckChar(src)
RETURN .t. if right(src,1) == c
SetMsg("Die PrÅfziffer muss " + c + " sein.")
RETURN .f.


#endif DEF_EAN

FUNCTION GetSeq(x)
RETURN x if val(x) == 0
RETURN padl(trim(x),len(x),"0")



FUNCTION DbfReplace(b, nOrder, xcKey, cOldKey, cNewKey)
local lOkay := .f.
RETURN .t. if b == NIL
RETURN .f. if TaskInter()
open area b
  lOkay := .t.
  ddSetOrder(nOrder)
  dbsoftseek(cOldKey)
  do while !eof() .and. xparse(xcKey) == cOldKey
    if ddRecLock()
      replace &xcKey with cNewKey
      unlock record
    else
      lOkay := .f.
      exit
    endif
    dbsoftseek(cOldKey)
  enddo
close area
RETURN lOkay

FUNCTION arrayLoop(a,blOnEach)
local i
for i := 1 to len(a)
  RETURN .f. if ! xeval(blOnEach,a[i])
next i
RETURN .t.

FUNCTION DbfAddRec(a,blOnCreate)
local lOkay := .f.
local b := a[1]
* open area b
begin sequence
  if ! AreaOpen( a, .f. ) ; break ; endif
  ddSetOrder(1)
  lOkay := .t.
  if ! DoEvents(b[AD_PRECREATE])
    lOkay := .f.
  elseif dbAddRec()
    DoEvents(b[AD_ONCREATE],b[AD_NAME]+":onCreate")
    if ! xeval(blOnCreate)
      lOkay := .f.
    endif
    unlock record
  else
    SetMsg("reclock() failed")
    lOkay := .f.
  endif
* close area
  AreaClose()
end sequence
RETURN lOkay

FUNCTION AddRecord(blOnCreate)
local u
if dbAddRec()
  u := xeval(blOncreate)
  unlock record
  RETURN u
endif
RETURN .f.

FUNCTION OnArea(ad,blEval)
local lOkay := .f.
RETURN .f. if ! AreaOpen({ad},.f.)
lOkay := eval(blEval)
AreaClose()
RETURN lOkay

*FUNCTION OnAreaa(a,blEval)
*local lOkay := .f.
*RETURN .f. if ! AreaOpen(a,.f.)
*lOkay := eval(blEval)
*AreaClose()
*RETURN lOkay

* Rad neu erfunden am 20050530
*FUNCTION OnArea(b,buReturn)
*local uReturn := .f.
*open area b
*  uReturn := eval(buReturn)
*close area
*RETURN uReturn






*FUNCTION DbfPack(b)
*local lOkay := .f.
*open area b exclusive
*  pack
*  lOkay := .t.
*close area
*RETURN lOkay

FUNCTION DbfAutoInc(b,nOrder)
local cReturn
local nLastId := 0
local xcIndexKey
local nLen
default nOrder to 1
open area b
  ddSetOrder(nOrder)
  xcIndexKey := indexkey()
  nLen := len(xparse(xcIndexKey))
  softseek repl("9",nLen)
  do while ! bof()
    nLastId := val(xparse(xcIndexKey))
    if nLastId == 0
      skip -1
    else
      exit
    endif
  enddo
  cReturn := str(nLastId+1,nLen,0)
close area
RETURN cReturn

FUNCTION DbfZap(b)
local lOkay := .f.
ddCloseAll()
open area b exclusive
  lOkay := .t.
  ZAP
close area
RETURN lOkay



#ifdef DEF_HST

FUNCTION OnFixY2kModif(cOld,cNew)
#ifdef DEF_VEN
  open area oVen() exclusive
    ddSetOrder(0)
    go top
    do while ! eof()
      if left(VEN->IdDoc,1) == cOld
        VEN->IdDoc := cNew + substr(VEN->IdDoc,2)
      endif
      if left(VEN->Periode,1) == cOld
        VEN->Periode := cNew + substr(VEN->Periode,2)
      endif
      skip
    enddo
  close area
  open area oVnl() exclusive
    ddSetOrder(0)
    go top
    do while ! eof()
      if left(VNL->IdDoc,1) == cOld
        VNL->IdDoc := cNew + substr(VNL->IdDoc,2)
      endif
      skip
    enddo
  close area
#endif DEF_VEN
#ifdef DEF_FIN
  open area oFin() exclusive
    ddSetOrder(0)
    go top
    do while ! eof()
      if left(FIN->IdDoc,1) == cOld
        FIN->IdDoc := cNew + substr(FIN->IdDoc,2)
      endif
      if left(FIN->Periode,1) == cOld
        FIN->Periode := cNew + substr(FIN->Periode,2)
      endif
      skip
    enddo
  close area
  open area oFnl() exclusive
    ddSetOrder(0)
    go top
    do while ! eof()
      if left(FNL->IdDoc,1) == cOld
        FNL->IdDoc := cNew + substr(FNL->IdDoc,2)
      endif
      skip
    enddo
  close area
#endif DEF_FIN
  open area oHst() exclusive
    ddSetOrder(0)
    go top
    do while ! eof()
      if left(HST->IdDoc,1) == cOld
        HST->IdDoc := cNew + substr(HST->IdDoc,2)
      endif
      if left(HST->Periode,1) == cOld
        HST->Periode := cNew + substr(HST->Periode,2)
      endif
      skip
    enddo
  close area
RETURN .t.

#endif DEF_HST


** http://www.faqs.org/rfcs/rfc1521.html
** DLM\CRM\PAR.DIF
FUNCTION dos2quoted(s)
local i,c
local s2 := ""
s:=dos2latin1(s)
for i := 1 to len(s)
  c := substr(s,i,1)
  if c $ "_=" .or. asc(c) > 127
    s2 += "="+left(FT_BYT2HEX(c),2)
  else
    s2 += c
  endif
next i
s2 := strtran(s2," ","_")
RETURN "=?iso-8859-1?q?"+s2+"?="



FUNCTION dos2base64(cStr)
* FUNCTION base64enc(cStr)
local rest
local i
local cBits := ""
local n := 0
local pos := 5
local cResult1 := ""
local cResult := ""
static saChars := {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",;
"L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y",;
"Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",;
"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0",;
"1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"}
cStr := dos2utf8(cStr)
for i := 1 to len(cStr)
  cBits += strtran(FT_BYT2BIT(substr(cStr,i,1))," ")
next i
for i := 1 to len(cBits)
  if substr(cBits,i,1) == "1"
    n += (2 ** pos)
  endif
  if pos == 0
    cResult1 += saChars[n+1]
    pos := 5
    n := 0
  else
    pos -= 1
  endif
next i
*
* When fewer than 24 input bits are available in an input group, zero
* bits are added (on the right) to form an integral number of 6-bit
* groups.
*
if pos != 5
* if pos != 5 // if n != 0 // if pos != 0
  cResult1 += saChars[n+1]
endif
*
*
* Padding at the end of the data is performed using the '=' character.
* Since all base64 input is an integral number of octets, only the
* following cases can arise: (1) the final quantum of encoding input is
* an integral multiple of 24 bits; here, the final unit of encoded
* output will be an integral multiple of 4 characters with no "="
* padding, (2) the final quantum of encoding input is exactly 8 bits;
* here, the final unit of encoded output will be two characters followed
* by two "=" padding characters, or (3) the final quantum of encoding
* input is exactly 16 bits; here, the final unit of encoded output will
* be three characters followed by one "=" padding character.
*
* 20021124 also :
* (1) : len(cResult1) % 4 == 0 : repl := 0
* (2) : len(cResult1) % 4 == 1 : repl := 2
* (3) : len(cResult1) % 4 == 2 : repl := 1
* (4) : len(cResult1) % 4 == 3 : raise
* und nicht einfach :
* cResult1 += repl("=",len(cResult1) % 3)
* len(cStr) -> len(cBits)  len(cResult1)
*     0            0            0          0
*     1            8            2          2      ==
*     2           16            3          3      =
*     3           24            4          0
*     4           32            6          2      ==
rest := len(cResult1) % 4
if rest == 0
  // no "="
elseif rest == 3
  cResult1 += "="
elseif rest == 2
  cResult1 += "=="
else
  raise("rest is 1")
endif
*
* The output stream (encoded bytes) must be represented in lines of no
* more than 76 characters each.
*
do while len(cResult1) > 76
  cResult += left(cResult1,76) + CR_LF
  cResult1 := substr(cResult1,77)
enddo
cResult += cResult1
*
RETURN cResult

FUNCTION dos2utf8(cStr)
RETURN latin2utf8(dos2latin1(cStr))

FUNCTION latin2utf8(cStr)
*
* http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
/***
  chr(c)
  n     n (bin)      UTF-8 (bin)
  ---   ---------    ---------------------   ----
  0     0000 0000 -> 0000 0000               chr(0)
  ...  pure ASCII (no conversion)
  127   0111 1111 -> 0111 1111               chr(127)
  128   1000 0000 -> 110 00010 + 10 000000   chr(194)+chr(128)
  129   1000 0001 -> 110 00010 + 10 000001   chr(194)+chr(129)
  ...
  191   1011 1111 -> 110 00010 + 10 111111   chr(194)+chr(191)
  192   1100 0000 -> 110 00011 + 10 000000   chr(195)+chr(128)
  193   1100 0001 -> 110 00011 + 10 000001   chr(195)+chr(129)
  ...
  255   1111 1111 -> 110 00011 + 10 111111   chr(195)+chr(191)
***/
local i
local result := ""
local n
for i := 1 to len(cStr)
  n := asc(substr(cStr,i,1))
  if n <= 127
    result += chr(n)
  elseif n <= 191
    result += chr(194)+chr(n)
  else
    result += chr(195)+chr(n-64)
  endif
next i
RETURN result

FUNCTION utf2latin(cStr)
local i := 1
local result := ""
local n
do while i <= len(cStr)
  n := asc(substr(cStr,i,1))
  if n <= 127
    result += chr(n)
  elseif n == 194
    i += 1
    n := asc(substr(cStr,i,1))
    result += chr(n)
  elseif n == 195
    i += 1
    n := asc(substr(cStr,i,1))
    result += chr(n+64)
  else
    result += "?"
  endif
  i += 1
enddo
RETURN result

FUNCTION utf2dos(x)
RETURN latin2dos(utf2latin(x))


FUNCTION dos2xml(c)
c := strtran(c,'&',  "&amp;")
c := strtran(c,"'",  "&apos;")
c := strtran(c,'"',  "&quot;")
c := strtran(c,'<',  "&lt;")
c := strtran(c,'>',  "&gt;")
RETURN dos2utf8(c)

FUNCTION dos2html(c)
// see http://www.w3.org/TR/MathML2/025.html
// Unicode Characters: 02500 to 025FF (BOX DRAWINGS)
c := strtran(c,"ƒ",  "&#x2500;")
c := strtran(c,"≥",  "&#x2502;")
c := strtran(c,"Ÿ",  "&#x2518;")
c := strtran(c,"¿",  "&#x2514;")
c := strtran(c,"⁄",  "&#x250C;")
c := strtran(c,"ø",  "&#x2510;")
c := strtran(c,"¡",  "&#x2534;")
c := strtran(c,"¬",  "&#x252C;")
c := strtran(c,"√",  "&#x251C;")
c := strtran(c,"¥",  "&#x2524;")
c := strtran(c,"…",  "&#x2554;")
c := strtran(c,"Õ",  "&#x2550;")
c := strtran(c,"ª",  "&#x2557;")
c := strtran(c,"∫",  "&#x2551;")
c := strtran(c,"»",  "&#x255A;")
c := strtran(c,"º",  "&#x255D;")
c := strtran(c,"",  "&darr;")
c := strtran(c,"Ñ",  "&auml;")
c := strtran(c,"é",  "&Auml;" )
c := strtran(c,"†",  "&aacute;")
c := strtran(c,"Ö",  "&agrave;")
c := strtran(c,"É",  "&acirc;")
c := strtran(c,"Ü",  "&aring;")
c := strtran(c,"è",  "&Aring;")
c := strtran(c,"¯a",  "&aring;")
c := strtran(c,"¯A",  "&Aring;")
c := strtran(c,"ë",  "&aelig;")
c := strtran(c,"í",  "&Aelig;")
c := strtran(c,"Å",  "&uuml;")
c := strtran(c,"ö",  "&Uuml;")
c := strtran(c,"ñ",  "&ucirc;")
c := strtran(c,"£",  "&uacute;")
c := strtran(c,"ó",  "&ugrave;")
c := strtran(c,"î",  "&ouml;")
c := strtran(c,"ô",  "&Ouml;")
c := strtran(c,"ì",  "&ocirc;")
c := strtran(c,"¢",  "&oacute;")
c := strtran(c,"ï",  "&ograve;")
c := strtran(c,"Ì",  "&Oslash;")
c := strtran(c,"·",  "&szlig;")
c := strtran(c,"¯",  "&deg;")
c := strtran(c,"˝",  "&sup2;")
c := strtran(c,"¸",  "&sup3;")
c := strtran(c,"á",  "&ccedil;")
c := strtran(c,"Ç",  "&eacute;")
c := strtran(c,"ä",  "&egrave;")
c := strtran(c,"à",  "&ecirc;")
c := strtran(c,"â",  "&euml;")
c := strtran(c,"å",  "&icirc;")
c := strtran(c,"ç",  "&igrave;")
c := strtran(c,"°",  "&iacute;")
c := strtran(c,"ã",  "&iuml;")
c := strtran(c,"~o",  "&otilde;")
c := strtran(c,"‰",  "&otilde;")
c := strtran(c,"~O",  "&Otilde;")
c := strtran(c,"Â",  "&Otilde;")
c := strtran(c,"Æ",  "&laquo;")
c := strtran(c,"Ø",  "&raquo;")
c := strtran(c,"˘",  "&uml;")
c := strtran(c,"˙",  "&middot;")
c := strtran(c,"ı",  "&sect;")
c := strtran(c,"Ô",  "&acute;")
c := strtran(c,"´",  "&frac12;")
c := strtran(c,"∏",  "&copy;")
c := strtran(c,chr(255), " ")
RETURN c


FUNCTION dos2latin1(c)
c := strtran(c,"ƒ" , "-")
c := strtran(c,"≥" , "|")
c := strtran(c,"¡" , "+")
c := strtran(c,"¬" , "+")
c := strtran(c,"…" , "+")
c := strtran(c,"Õ" , "=")
c := strtran(c,"ª" , "+")
c := strtran(c,"∫" , "|")
c := strtran(c,"»" , "+")
c := strtran(c,"º" , "+")

c := strtran(c,"é" , "ƒ")
c := strtran(c,"î" , "ˆ")
c := strtran(c,"ô" , "÷")
c := strtran(c,"Å" , "¸")
c := strtran(c,"ö" , "‹")
c := strtran(c,"·" , "ﬂ")
c := strtran(c,"Ö" , "‡")
c := strtran(c,"É" , "‚")
c := strtran(c,"Ç" , "È")
c := strtran(c,"à" , "Í")
c := strtran(c,"ä" , "Ë")
c := strtran(c,"å" , "Ó")
c := strtran(c,"ì" , "Ù")
c := strtran(c,"ñ" , "˚")
c := strtran(c,"ó" , "˘")
c := strtran(c,"â" , "Î")
c := strtran(c,"á" , "Á")
c := strtran(c,"Ò" , "±")

c := strtran(c,"†" , "·")
c := strtran(c,"‰" , "ı")
c := strtran(c,"Â" , "’")

c := strtran(c,"Ñ" , "‰")
c := strtran(c,"Æ" , "´")
c := strtran(c,"Ø" , "ª")
c := strtran(c,"¯" , "∞")
c := strtran(c,"´" , chr(189)) // "Ω"
c := strtran(c,"¨" , chr(188)) // "º")


RETURN c

FUNCTION latin2dos(c)
c := strtran(c, "ƒ","é" )
c := strtran(c, "ˆ","î" )
c := strtran(c, "÷","ô" )
c := strtran(c, "¸","Å" )
c := strtran(c, "‹","ö" )
c := strtran(c, "ﬂ","·" )
c := strtran(c, "‡","Ö" )
c := strtran(c, "‚","É" )
c := strtran(c, "È","Ç" )
c := strtran(c, "Í","à" )
c := strtran(c, "Ë","ä" )
c := strtran(c, "Ó","å" )
c := strtran(c, "Ù","ì" )
c := strtran(c, "˚","ñ" )
c := strtran(c, "˘","ó" )
c := strtran(c, "Î","â" )
c := strtran(c, "Á","á" )
c := strtran(c, "±","Ò" )

c := strtran(c, "‰","Ñ" )
c := strtran(c, "·","†" )
c := strtran(c, "ı","‰" )
c := strtran(c, "’","Â" )

c := strtran(c, "´","Æ" )
c := strtran(c, "ª","Ø" )
c := strtran(c, "∞","¯" )
RETURN c



FUNCTION HasRecords(ad,nOrder,xcKey,cKey)
** Achtung : cKey und xcKey wÑren besser andersrum...
local lHasRecords := .f.
default nOrder to 1
default cKey to ""
default xcKey to "''"
open area ad
  ddSetOrder(nOrder) // also sets dbdescend() to .f.
  #ifdef __XPP__
    lHasRecords := dbseek(cKey,.t.)
  #else
    softseek cKey
    if !eof() .and. &(xcKey) == cKey
      lHasRecords := .t.
    endif
  #endif
close area
RETURN lHasRecords




#ifdef CUST_MOOR

  FUNCTION PrjVenScan(cIdPrj,dDate1,dDate2)
  ** wird auch in PRJMRG.REP und PRJSTK.REP benutzt !
  local nStk1 := 0
  local nStk2 := 0
  local cType
  local dPrjDate1
  local dPrjDate2
  * local lStk1 := .f.
  * local lStk2 := .f.
  * local lStkRep := .f.
  local dOverflow := NIL
  local nWert := 0
  local nVK := 0
  local cIdPar := PRJ->IdPar
  local dDatumEK := ctod("")
  local dDatumVK := ctod("")
  local lOkay := .f.
  local e := ""
  local nKosten := 0
  open area oVen()
    lOkay := .t.
    ddSetOrder(3)
    softseek cIdPrj
    do while !eof().and.VEN->IdPrj == cIdPrj
      if !empty(dDate2) .and. VEN->Date>dDate2
        exit
      endif
      if ! VenIsOpen()
        if (VEN->IdJnl$"EKR".and.VEN->Layout=="K").or.VEN->IdJnl=="IKO"
          if empty(dDate1) .or. VEN->Date >= dDate1
            if VenIsNC()
              nKosten += VenMont2Dev(SetDevise(),val(VEN->MontR))
            else
              nKosten += VenMont2Dev(SetDevise(),val(VEN->MontR))
            endif
          endif
        endif
        if VEN->IdJnl$"EKM,EKR".and.VEN->Layout$"E "
          if VenIsNC()
            dDatumEK := ctod("")
            nWert := 0
            * lStk2 := .f.
            nStk2 -= 1
            if !empty(dDate1) .and. (VEN->Date < dDate1)
              nStk1 -= 1
            endif
          else
            cIdPar := VEN->IdPar
            if nStk2 == 0
              dDatumVK := ctod("")
              nVK := 0
            endif
            nStk2 += 1
            if !empty(dDate1) .and. (VEN->Date < dDate1)
              nStk1 += 1
            endif
            dDatumEK := VEN->Date
            nWert := VenMont2Dev(SetDevise(),val(VEN->MontR))
            nKosten := 0
            // lStk2 := .t.
            * if !empty(dDatumVK) .and. dDatumVK < VEN->Date
            *   dDatumVK := ctod("")
            * endif
          endif
        endif
        * if VEN->IdJnl=="VKR".and.VEN->Layout=="R".and.!VenIsNC()
        *   lStkRep := .f.
        * endif
        if VEN->IdJnl=="VKR".and.VEN->Layout=="V"
          if VenIsNC()
            dDatumVK := ctod("")
            nVK -= VenMont2Dev(SetDevise(),val(VEN->MontR))
            * lStk2 := .t.
            nStk2 += 1
            if !empty(dDate1) .and. (VEN->Date < dDate1)
              nStk1 += 1
            endif
          else
            nStk2 -= 1
            if !empty(dDate1) .and. (VEN->Date < dDate1)
              nStk1 -= 1
            endif
            cIdPar := VEN->IdPar
            dDatumVK := VEN->Date
            nVK += VenMont2Dev(SetDevise(),val(VEN->MontR))
            * lStk2 := .f.
            * if !empty(dDate1).and.VEN->Date < dDate1
            *   lStk1 := .f.
            * endif
          endif
        endif
        if dOverflow == NIL
          if nStk2 > 1
            dOverflow := VEN->Date
          endif
        elseif dOverflow == VEN->Date .and. nStk2 <= 1
          dOverflow := NIL
        endif
      endif
      skip
    enddo
  close area
  *
  dPrjDate1 := dDatumEK
  dPrjDate2 := dDatumVK
  if dOverflow != NIL
    SetMsg(alltrim(PRJ->IdPrj)+" : öberlauf Lagerbestand am "+dtoc(dOverflow))
    cType := "?"
  elseif nStk2 == 1
    cType := "G"
  elseif nStk2 == 0
    if empty(dDatumVK)
      if !empty(dDatumEK)
        SetMsg(alltrim(PRJ->IdPrj)+;
        " : Fehler: DatumEK leer, Stock 0 und DatumVK nicht leer?")
        cType := "?"
      else
        cType := "S"
      endif
    else
      cType := "V"
      dPrjDate1 := dDatumVK
      dPrjDate2 := dDatumEK
    endif
  else
    SetMsg(alltrim(PRJ->IdPrj)+" : Lagerbestand weder 0 noch 1 !")
    cType := "?"
  endif
  *
  RETURN { dDatumEK, dDatumVK, nWert, ;
    nStk1, nStk2, cIdPar, ;
    nKosten, nVK, ;
    cType, dPrjDate1, dPrjDate2 }

  FUNCTION PrjUpdate(dDate)
  * local a
  local lOkay := .f.
  local a
  LogDebug("PrjUpdate()")
  a := PrjVenScan(PRJ->IdPrj,NIL,dDate)
  if ddRecLock()
    lOkay := .t.
    PRJ->Kosten := ntom(a[7])
    PRJ->Wert := ntom(a[3])
    PRJ->IdPar := a[6]
    PRJ->Type := a[9]
    PRJ->Date1 := a[10]
    PRJ->Date2 := a[11]
    PRJ->ParName:=upper(ParName(PRJ->IdPar))
    * if a[5] == 1
    *   PRJ->Type := "G"
    *   PRJ->Date1 := a[1]
    *   PRJ->Date2 := a[2]
    * elseif a[5] == 0
    *   if empty(a[2])
    *     if !empty(a[1])
    *       Warning(alltrim(PRJ->IdPrj)+;
    *       " : Fehler: DatumEK leer, Stock 0 und DatumVK nicht leer?")
    *     endif
    *     PRJ->Type := "S"
    *     PRJ->Date1 := a[1]
    *     PRJ->Date2 := a[2]
    *   else
    *     PRJ->Type := "V"
    *     PRJ->Date1 := a[2]
    *     PRJ->Date2 := a[1]
    *   endif
    * else
    *   PRJ->Type := "?"
    *   PRJ->Date1 := a[1]
    *   PRJ->Date2 := a[2]
    * endif
    * commit
    unlock record
  endif
  RETURN lOkay

  FUNCTION PrjIsUpdated()
  local a := PrjVenScan(PRJ->IdPrj)
  RETURN "Kosten" if PRJ->Kosten != ntom(a[7])
  RETURN "Wert" if PRJ->Wert != ntom(a[3])
  RETURN "Partner" if PRJ->IdPar != a[6]
  RETURN "Lagercode" if PRJ->Type != a[9]
  RETURN "Datum1" if PRJ->Date1 != a[10]
  RETURN "Datum2" if PRJ->Date2 != a[11]
  RETURN NIL

  FUNCTION VenIsPrjField()
  RETURN .t. if VEN->IdJnl=="EKR".and.VEN->Layout=="K"
  RETURN .t. if VEN->IdJnl=="IKO"
  RETURN .t. if VEN->IdJnl=="VKR".and.VEN->Layout=="V"
  RETURN .t. if VEN->IdJnl$"EKM,EKR".and.VEN->Layout$"E "
  RETURN .f.


FUNCTION CarPassLoop(cIdJnl,b)
local xlFilter := "!empty(VEN->IdPrj)"
xlFilter += ".and.!empty(VEN->Km)"
xlFilter += ".and.VEN->Etat==DocStatClosed()"
xlFilter += ".and.inrange(VEN->DateRec,getvar('Date1'),getvar('Date2'))"
xlFilter += ".and.PrjExist(VEN->IdPrj)"
xlFilter += ".and.!empty(PRJ->Chassis)"
RETURN DbfScan({oVen(),oPrj()},1,cIdJnl,"VEN->IdJnl=='"+cIdJnl+"'",xlFilter,b)

FUNCTION CarPassFile(cIdJnl,cSender,cNoTva1,cNoTva2,xcNB)
* based on car-pass.be : InflowProcessSpecificationv3.pdf
* cSender : id for sender
* cNoTva1 : code of legally responsible (enterprise  n¯)
* cNoTva2 : code for entity that entered the data (establishment n¯)
* cNB : internal code for entity that entered the data (optional)
local cLine := ""
local fd
local lOkay := .f.
local nCount := 0
local cFilename
local cLoadId := "001"
default cNoTva1 to strtran(substr(MemNoTva,4),".","")
default cNoTva2 to strtran(substr(MemNoTva,4),".","")
default xcNB to '""'
do while cLoadId <= "999"
  cFilename := "R"+cSender+dtos(UserDate())+cLoadId+".txt"
  if ! file(cFilename)
    exit
  endif
  cLoadId := strtran(str(val(cLoadId)+1,3,0)," ","0")
enddo
if len(cSender) != 10
  SetMsg(cSender+ " : invalid sender id")
elseif len(trim(cNoTva1)) != 10
  SetMsg(cNoTva1 + " : n¯ d'entreprise invalide!")
elseif len(trim(cNoTva2)) != 10
  SetMsg(cNoTva2 + " : n¯ d'utilisateur invalide!")
elseif file(cFilename).and.!confirm(cFilename+MsgOverwrite())
  SetMsg("RefusÇ d'Çcraser fichier existant "+cFilename)
elseif (fd := fcreate(cFileName)) == -1
  SetMsg(cFileName + MsgDosError(ferror()))
else
  lOkay := .t.
  cLine := "1R"  // header row
  cLine += cSender
  cLine += dtos(UserDate())
  cLine += cLoadId
  fwrite(fd,cLine+CR_LF)
  if ! CarPassLoop(cIdJnl,{|| nCount += 1, ;
             CarPassLine(fd,cNoTva1,cNoTva2,xcNB)})
    lOkay := .f.
  endif
  cLine := "3"  // trailer row
  cLine += strtran(str(nCount+2,8,0)," ","0")
  fwrite(fd,cLine) // *pas* de CRLF apräs le trailer record!
  fclose(fd)
endif
if lOkay .and. nCount == 0
  SetMsg("Rien Ö dÇclarer.")
  lOkay := .f.
endif
if ! lOkay
  FileDelete(cFileName,.t.,.t.)
  RETURN NIL
endif
SetMsg(cFileName+" a ÇtÇ gÇnÇrÇ. ("+ntrim(nCount)+" kilomÇtrages)")
RETURN cFilename


FUNCTION CarPassLine(fd,cNoTva1,cNoTva2,xcNB)
local cLine := "2"
local cNB := xparse(xcNB)
RETURN .f. if cNB == NIL
cNB := padr(cNB,10)
cLine += padr(PRJ->Chassis,17)
cLine += right(VEN->Km,7)
cLine += "120"
cLine += dtos(VEN->DateRec)
cLine += cNoTva1
cLine += cNoTva2
cLine += cNB
cLine += dtos(PRJ->Zulassung)
cLine += space(2)
fwrite(fd,cLine+CR_LF)
RETURN .t.

#endif CUST_MOOR

FUNCTION memo2pds(c)
local i
local a := split(hardcr(c),CR_LF+CR_LF,NIL,.t.)
for i := 1 to len(a)
  toStream('p("""')
  toTxtStream(a[i])
  toStream('""")'+CR_LF)
next i
RETURN .t.

FUNCTION c2html(c)
RETURN strtran(c,'"','\"')

FUNCTION notags(c)
c := strtran(c,"<","&lt;")
c := strtran(c,">","&gt;")
c := strtran(c,"&","&amp;")
RETURN c

FUNCTION TimeTrim(cTime)
if right(cTime,3) == ":00"
  cTime := substr(cTime,1,len(cTime)-3)
endif
RETURN ltrim(cTime)

FUNCTION SrvQte(cIdJnl,cIdUsr,dDate,xlFilter)
local nQte := 0
open area oVen()
  softseek cIdJnl
  do while !eof() .and. VEN->IdJnl == cIdJnl
    if VEN->Date == dDate
      if trim(VEN->Auteur) == cIdUsr
        if &xlFilter
          nQte += timediff(VEN->Von,VEN->Bis)
          nQte -= qton(VEN->Pause)
        endif
      endif
    endif
    skip
  enddo
close area
RETURN nQte

*FUNCTION SrvList(dDate1,dDate2)
*local r := r_open()
*r_addgroup({|n,v|ls_woy(v)},;
*  {|v|"Woche "+ntrim(v)+":"},;
*  {|v|"Total Woche "+ntrim(v)+":"})
*r_addgroup({|n,v|month(v)},;
*  {|v|"Monat "+ntrim(v)+":"},;
*  {|v|"Total Monat "+ntrim(v)+":"})
*r_forloop(dDate1,dDate2,1,NIL,{|n,v|srvline(v)})
**r_close()


#define ROW_LABEL 1
#define ROW_FIELD 2
#define ROW_VALUE 3

** http://tim.saffre-rumma.ee/src/23.html
FUNCTION TagUpdate(aData,cTitle,lDlg)
// { label, datafield, suggested new value }
* local cHeader := ""
local i
local aIndexes := {}
local aTagged := {}
* local nLabelWidth := 5
* local nValueWidth
local aActions := {}
local aChanges := {}
local lMatch
local cChangeTxt
local uOldValue
local nUpdates := 0
default lDlg to .t.
*default aHeaders to { "Datenfeld", ;
*                      "Alter Wert", ;
*                      "ersetzen durch:" }
for i := 1 to len(aData)
  cChangeTxt := NIL
  uOldValue := &(aData[i][ROW_FIELD])
  if valtype(uOldValue) $ "DLN"
    lMatch := uOldValue == aData[i][ROW_VALUE]
  else
    uOldValue := trim(uOldValue)
    if aData[i][ROW_VALUE] == NIL
      lMatch := .t.
    else
      lMatch := uOldValue == trim(aData[i][ROW_VALUE])
    endif
  endif
  if ! lMatch
    cChangeTxt := aData[i][ROW_LABEL] + " " + utos(uOldValue) ;
                  + " -> "+utos(aData[i][ROW_VALUE])
    aadd(aTagged, .t.)
    aadd(aIndexes,i)
    aadd(aChanges,cChangeTxt)
    nUpdates += 1
  endif
  * nLabelWidth := max(nLabelWidth,len(aData[i][ROW_LABEL]))
next i
RETURN !SetMsg("Nichts zu aktualisieren.") if nUpdates == 0
if lDlg
  aadd(aActions, { K_SPACE , {|row,i| ;
    aTagged[i] := ! aTagged[i], ;
    K_DOWN ;
  } } )
  browse array aIndexes using {|row,i| ;
      iif(aTagged[i],BUTTON_ON,BUTTON_OFF);
      +" "+padr(aChanges[i],maxcol()-6);
    } ;
    title (cTitle) ;
    actions aActions
  RETURN .f. if LastChoice() == 0
endif
for i := 1 to len(aTagged)
  if aTagged[i]
    &(aData[aIndexes[i]][ROW_FIELD]) := aData[aIndexes[i]][ROW_VALUE]
  endif
next i
RETURN .t.
