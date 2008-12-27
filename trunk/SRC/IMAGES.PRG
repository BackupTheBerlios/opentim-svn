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

#ifdef DEF_LFN
#include "LFNLIB.CH"
#endif


#define VOL_ID    1
#define VOL_PATH  2
#define VOL_NAME  3
#define VOL_TYPE  4
#define VOL_URL   5
#define VOL_ALEN  5

#define LEN_IDVOL  8



static scSuffix := "."

static sbVol2url := {|vol,x|"file:///"+strtran(vol[VOL_PATH],"\","/")+x}
// static sbVol2url := {|vol,x|"file:///"+strtran(vol[VOL_PATH],"\","/")+"/"+x}
// static sbVol2url := {|vol,x|"file:///"+vol[VOL_PATH]+"/"+x}
static saVol := NIL

*static saVol := { ;
*  { 'lino', "t:\svnwork\lino\trunk\",  ;
*    {|x| "http://svn.berlios.de/viewcvs/lino/trunk/"+x+'?view=markup'}},;
*  { "a", "a:\", {|x|x} },;
*  { "c", "c:\", {|x|x} },;
*  { "d", "d:\", {|x|x} },;
*  { "f", "f:\", {|x|x} },;
*  { "t", "t:\", {|x|x} } ;
*}



FUNCTION VolRefresh()
local i
saVol := ReadArray("VOL.DBC",VOL_ALEN)
// post-load conversions:
for i := 1 to len(saVol)
  saVol[i][VOL_ID] := alltrim(saVol[i][VOL_ID])
  saVol[i][VOL_PATH] := lower(alltrim(saVol[i][VOL_PATH]))
  if empty(saVol[i][VOL_URL])
    saVol[i][VOL_URL] := sbVol2url
  endif
next i
RETURN NIL

**
*FUNCTION VolLocate(cId)
*local i
*if saVol == NIL ; VolRefresh() ; endif
*for i := 1 to len(saVol)
*  RETURN saVol[i] if saVol[i][VOL_ID] == cId
*next i
*RETURN NIL

**
** PickVol()
**
FUNCTION PickVol(cStart,cTitle)
local nStart := 0
local i
if saVol == NIL ; VolRefresh() ; endif
for i := 1 to len(saVol)
  if saVol[i][VOL_ID] == cStart
    nStart := i
  endif
next i
default cTitle to "Volumen w„hlen"
browse array saVol using {|x| ;
                         padr(x[VOL_ID],LEN_IDVOL) + " " + ;
                         padr(x[VOL_NAME],30) + " " + ;
                         padr(x[VOL_PATH],30) } ;
             delete {||.f.} ;
             start nStart ;
             help "VOL" ;
             title (cTitle)
if lastchoice() != 0
   RETURN saVol[LastChoice()]
   *RETURN saVol[LastChoice()][VOL_ID]
endif
RETURN NIL
**
*FUNCTION VolExist(cId)
*RETURN .t. if VolLocate(cId) != NIL
*SetMsg(cId + " : unbekannte Preisgruppe !")
*RETURN .f.



FUNCTION volsplit(x)
local vol
local i
local a := split(x,":",2)
RETURN NIL if len(a) != 2
a[1] := lower(a[1])
if saVol == NIL ; VolRefresh() ; endif
for i := 1 to len(saVol)
  vol := saVol[i]
  if a[1]==vol[VOL_ID]
  *if lower(left(x,len(vol[VOL_ID])+1))==vol[VOL_ID]+":"
    // x:=substr(x,len(vol[VOL_ID])+2)
    x := strtran(a[2],"\","/")
    if left(x,1)=="/"
      x:=substr(x,2)
    endif
    RETURN {vol,x}
  endif
next i
if len(a[1]) == 1
  vol=array(VOL_ALEN)
  vol[VOL_ID] := a[1]
  vol[VOL_PATH] := left(x,2)+"\"
  vol[VOL_NAME] := "Drive "+upper(a[1])+":"
  vol[VOL_URL] := sbVol2url
  x := strtran(a[2],"\","/")
  if left(x,1) == "/"
    x := substr(x,2)
  endif
  RETURN {vol,x}
endif
RETURN NIL // "oops"

FUNCTION vol2url(x)
local a := volsplit(x)
RETURN "oops" if a==NIL
// RETURN trim(a[2]) if empty(a[1][VOL_URL])
RETURN eval(a[1][VOL_URL],a[1],trim(a[2]))

FUNCTION vol2loc(x)
local a:= volsplit(x)
RETURN x if a==NIL
RETURN a[1][VOL_PATH] + strtran(trim(a[2]),"/","\")


FUNCTION loc2vol(x)
local i
local vol
*local a:= volsplit(x)
*if a==NIL
*  Warning(x+" : volsplit() failed...")
*  RETURN x
*endif
*x:=strtran(x,"\","/")
*if left(x,1)=="/"
*  x:=substr(x,2)
*endif
*RETURN a[1][VOL_ID] + ":" + x
if saVol == NIL ; VolRefresh() ; endif
for i := 1 to len(saVol)
  vol := saVol[i]
  if lower(left(x,len(vol[VOL_PATH])))==vol[VOL_PATH]
    x:=substr(x,len(vol[VOL_PATH])+1)
    x:=strtran(x,"\","/")
    if left(x,1)=="/"
      x:=substr(x,2)
    endif
    RETURN vol[VOL_ID] + ":"+x
  endif
next i
RETURN x




FUNCTION lf_memoread(fn)
local cBlock := space(1024)
local s := ""
local fdin
local nBytesRead
#ifdef DEF_LFN
  fdin := lf_fopen(fn)
#else
  fdin := fopen(fn)
#endif
RETURN NIL if fdin == -1
do while .t.
  nBytesRead := fread(fdin,@cBlock,1024)
  if nBytesRead == 0
    fclose(fdin)
    RETURN s
  endif
  s += left(cBlock,nBytesRead)
enddo
RETURN NIL // never reached
* raise("never reach
* fclose(fdin)
* RETURN s


FUNCTION MsgPickFiles(cWildcard,cTitle)
local c
RETURN .f. if ! ddRecLock()
default cTitle to MnuItemName()
c := GsbFileList(cWildcard,MSG->Files,cTitle)
if c != NIL
  MSG->Files := c
endif
unlock record
RETURN .t.

* FUNCTION shquote(s)
* RETURN s if ! " " $ s
* RETURN '"'+strtran(s,'"','\"')+'"'


FUNCTION GsbFileList(cWildcard,cStart,cTitle)
local aSelected := {}
local c
local i
local nStart := 1
local aActions := {}
local lUpdated := .f.
aadd(aActions, { K_ENTER , {|m| ;
  empty(m).or.AppShell('start "" "'+ vol2loc(m)+'"'), ;
  NIL ;
} } )
aadd(aActions, { K_ESC , {|m| ;
  if(lUpdated,;
     if(Confirm("Žnderungen speichern (J/N)"),K_F10,K_ESC),;
     K_ESC) ;
} } )
if cStart != NIL
  aSelected := split(cStart,CR_LF,NIL,.t.)
  i := 1
  do while i <= len(aSelected)
    if empty(aSelected[i])
      adel(aSelected,i)
      asize(aSelected,len(aSelected)-1)
    else
      i++
    endif
  enddo
endif
default cWildcard to "*"
default cTitle to "File List Editor"
do while ! AppTerminate()
  abrowse(aSelected,{|m|flline(m)},NIL,.t.,;
          {|x|PickFile(x,cWildcard)}, ;
          {|x|Confirm("Datei "+x+" aus Liste entfernen.",MsgSure())},;
          cTitle,NIL,NIL,NIL,NIL,aActions,;
          "[Ins] [Del] [Enter] [F10] [Esc]", ;
          NIL,NIL,.f.,70,NIL,NIL,;
          NIL,NIL,NIL,NIL,NIL,NIL,@lUpdated)

*FUNCTION aBrowse( aItems, bBlock, nItem , lArrange, ;
*                  bCreate, bDelete,                 ;
*                  cTitle, bEnter,                   ;
*                  bSpace, aHot, cHelp, aActions, cLegend , ;
*                  nRow, nCol, lWrap, nWidth, bIdle, aExit, ;
*                  win, nMode, bPosit, lPermanent, nFrame, ;
*                  lArrowExit ;
*
*  browse array aSelected using {|m| flline(m) } ;
*               title "File List Editor" ;
*               start nStart ; // home nRow, nCol ;
*               create {|x|PickFile(x,cWildcard)} ;
*               delete {|x|Confirm(;
*                 "Datei "+x+" aus Liste entfernen.",MsgSure())} ;
*               legend ("[Ins] [Del] [Enter] [F10] [Esc]") ;
*               actions aActions ;
*               arrange

  RETURN NIL if lastchoice() == 0
  *if lastchoice() == 0
  *  RETURN NIL if ! lUpdated
  *  RETURN NIL if ! Confirm("Žnderungen speichern (J/N)")
  *  RETURN join(aSelected,CR_LF)
  *endif
  RETURN join(aSelected,CR_LF) if abLastKey() == K_F10
  nStart := lastchoice()
enddo
RETURN NIL

STATIC FUNCTION flline(x)
RETURN padr(x,70)


#define PF_NAME 1
#define PF_TAGGED 2
#define PF_ISDIR 3
#define PF_ALEN 3


FUNCTION PickFile(cStart,cWildcard)
local cDir
local a
local vol
default cStart to ""
default cWildcard to "*"
a := volsplit(cStart)
if a == NIL
  vol := PickVol(cStart)
  if vol == NIL
    SetMsg("no volume specified")
    RETURN NIL
  endif
  a := { vol, "" }
endif
cStart := a[2]
cDir := left(cStart,rat("/",cStart))
cStart := substr(cStart,len(cDir)+1)
cDir := a[1][VOL_PATH]+strtran(cDir,"/","\")
cDir := normpath(abspath(cDir))
*if right(cDir,1) != "\"
*  cDir += "\"
*endif
RETURN PickFile_(a[1],cDir,cStart,cWildcard)

FUNCTION PickFile_(vol,cDir,cStart,cWildcard)
local i, j
local aDir
local aDirs
local aFiles
local nStart := 1
local lSelected
local lFound
local aActions := {}
aadd(aActions, { K_F3 , {|pf| ;
  if(aDirs[nStart][PF_ISDIR],.f.,;
     AppShell("start "+ cDir+pf[PF_NAME]));
} } )
do while ! AppTerminate()
  aDirs := {}
  aFiles := {}
  * confirm(utos(cDir),utos(cWildcard))
  MsgDisplay("Lese Verzeichnis "+cDir+cWildcard+"...")
  #ifdef DEF_LFN
    aDir := LF_Directory(cDir+"*.*",LFN_DIRECTORY,LFN_DIRECTORY)
    for i := 1 to len(aDir)
      if ! trim(aDir[i][LFN_LONG]) == "."
        aadd(aDirs,{aDir[i][LFN_LONG], NIL, .t.} ) // PF_ALEN
      endif
    next i
    aDir := LF_Directory(cDir+cWildcard)
    for i := 1 to len(aDir)
      aadd(aFiles,{aDir[i][LFN_LONG], NIL, .f.} ) // PF_ALEN
    next i
  #else
    aDir := Directory(cDir+"*.*","D")
    for i := 1 to len(aDir)
      if trim(aDir[i][F_NAME]) != "." .and. "D" $ aDir[i][F_ATTR]
        aadd(aDirs,{aDir[i][F_NAME], NIL, .t.} ) // PF_ALEN
      endif
    next i
    aDir := Directory(cDir+cWildcard)
    for i := 1 to len(aDir)
      aadd(aFiles,{aDir[i][F_NAME], NIL, .f.} ) // PF_ALEN
    next i
  #endif
  asort(aDirs,NIL,NIL,{|a,b|a[PF_NAME]<b[PF_NAME]})
  asort(aFiles,NIL,NIL,{|a,b|a[PF_NAME]<b[PF_NAME]})
  for i := 1 to len(aFiles)
    aadd(aDirs,aFiles[i])
  next i
  if !empty(cStart) // != NIL
    for i := 1 to len(aDirs)
      if aDirs[i][PF_NAME]==cStart
        nStart := i
      endif
    next i
  endif
  // K_CTRL_F5 beendet abrowse(), f„ngt dann aber gleich wieder von
  // vorne an (Refresh)
  browse array aDirs using {|m| pfline(m) } ;
                     title (cDir+cWildcard) ;
                     start nStart ; // home nRow, nCol ;
                     legend ("[Ins] [Del] [*] [F3] [F10] [Esc] [Ctrl-F5]") ;
                     actions aActions ;
                     exit { K_CTRL_F5, K_BS }
                     // create {|x|PickFile_(vol,cDir,x,cWildcard)}
  RETURN NIL if lastchoice() == 0
  nStart := lastchoice()
  if abLastKey() == K_ENTER
    RETURN loc2vol(cDir+aDirs[nStart][PF_NAME]) if ! aDirs[nStart][PF_ISDIR]
    RETURN PickFile_(vol,;
      normpath(cDir+aDirs[nStart][PF_NAME])+"\",NIL,cWildcard)
  elseif abLastKey() == K_F10
    RETURN loc2vol(cDir+aDirs[nStart][PF_NAME])
  elseif abLastKey() == K_BS
    RETURN PickFile_(vol,;
      normpath(cDir+"..")+"\",NIL,cWildcard)
  endif
enddo
RETURN NIL


FUNCTION pfline(x)
local cLine := padr(x[PF_NAME],50)
if x[PF_ISDIR]
  cLine += "<DIR>"
else
  cLine += "     "
endif
RETURN cLine



FUNCTION BrowseDir(cDir,cWildcard,aSelected)
// not used. same as pickfile() but with multiple selection
local i, j
local aDir
local aDirs
local aFiles
local nStart := 1
local lSelected
local lFound
local aActions := {}
aadd(aActions, { asc("*"), {|| ;
  pfinvert(aDirs,cDir,aSelected) ;
} } )
aadd(aActions, { K_SPACE , {|m| ;
  pfselect(m,cDir,aSelected),;
  K_DOWN ;
} } )
aadd(aActions, { K_INS , {|m| ;
  pfselect(m,cDir,aSelected,.t.),;
  K_DOWN ;
} } )
aadd(aActions, { K_DEL , {|m| ;
  pfselect(m,cDir,aSelected,.f.),;
  K_DOWN ;
} } )
cDir := normpath(abspath(cDir))
if right(cDir,1) != "\"
  cDir += "\"
endif
do while ! AppTerminate()
  aDirs := {}
  aFiles := {}
  MsgDisplay("Lade Verzeichnis "+cDir+cWildcard+"...")
  #ifdef DEF_LFN
    aDir := LF_Directory(cDir+cWildcard,NIL,LFN_DIRECTORY)
    #define XX_ATT LFN_ATT
    #define XX_NAME LFN_LONG
  #else
    aDir := Directory(cDir+cWildcard)
    #define XX_ATT F_ATTR
    #define XX_NAME F_NAME
  #endif
  for i := 1 to len(aDir)
    if substr(ft_byt2bit(chr(aDir[i][XX_ATT])),4,1) == "1"
      if aDir[i][XX_NAME] != "."
        aadd(aDirs,{aDir[i], .f., .t.} ) // PF_ALEN
      endif
    else
      lSelected := .f.
      for j := 1 to len(aSelected)
        if aSelected[j] == cDir+aDir[i][XX_NAME]
          lSelected := .t.
          exit
        endif
      next j
      aadd(aFiles,{aDir[i], lSelected, .f.} ) // PF_ALEN
    endif
  next i
  asort(aDirs,NIL,NIL,{|a,b|a[PF_NAME]<b[PF_NAME]})
  asort(aFiles,NIL,NIL,{|a,b|a[PF_NAME]<b[PF_NAME]})
  for i := 1 to len(aFiles)
    aadd(aDirs,aFiles[i])
  next i
  // K_CTRL_F5 beendet abrowse(), f„ngt dann aber gleich wieder von
  // vorne an (fr den Fall, dass im F9-Fenster Matchs ge„ndert wurden)
  browse array aDirs using {|m| pfsline(m) } ;
                     title cDir+cWildcard ;
                     start nStart ; // home nRow, nCol ;
                     legend ("[Ins] [Del] [*] [F3] [F10] [Esc] [Ctrl-F5]") ;
                     actions aActions ;
                     delete {||.f.} ;
                     exit { K_CTRL_F5 }
  RETURN .f. if lastchoice() == 0
  if abLastKey() == K_CTRL_F5
    loop
  elseif abLastKey() == K_F3
    nStart := lastchoice()
    if ! aDirs[nStart][PF_ISDIR]
      AppShell("start "+ aDirs[nStart][PF_NAME])
    endif
  elseif abLastKey() == K_ENTER
    nStart := lastchoice()
    if aDirs[nStart][PF_ISDIR]
      BrowseDir(normpath(cDir+aDirs[nStart][PF_NAME]),;
                cWildcard,aSelected)
      loop
    else
      pfselect(aDirs[lastchoice()],cDir,aSelected,.t.)
      RETURN .t.
    endif
  elseif abLastKey() == K_F10
    for i := 1 to len(aDirs)
      if aDirs[i][PF_TAGGED]
        lFound := .t.
        exit
      endif
    next i
    if ! lFound
      pfselect(aDirs[lastchoice()],cDir,aSelected,.t.)
    endif
    RETURN .t.
  endif
enddo
RETURN .f. // if AppTerminate()


STATIC FUNCTION pfsline(x)
local cLine := if(x[PF_TAGGED],BUTTON_ON,BUTTON_OFF)
cLine += " " + padr(x[PF_NAME],50)
if x[PF_ISDIR]
  cLine += "<DIR>"
else
  cLine += "     "
endif
RETURN cLine

FUNCTION pfinvert(a,cDir,aSelect)
local i
for i := 1 to len(a)
  pfselect(a[i],cDir,aSelect)
next i
RETURN K_ALT_F5


FUNCTION pfselect(x,cDir,aSelect,lSelect)
local cFullname := cDir+x[PF_NAME]
local i
if lSelect == NIL
  x[PF_TAGGED] := ! x[PF_TAGGED]
else
  RETURN NIL if x[PF_TAGGED] == lSelect // don't add/delete again in aSelect
  x[PF_TAGGED] := lSelect
endif
if x[PF_TAGGED]
  aadd(aSelect,cFullname)
  RETURN NIL
endif
for i := 1 to len(aSelect)
  if aSelect[i] == cFullname
    adel(aSelect,i)
    asize(aSelect,len(aSelect)-1)
    RETURN NIL
  endif
next i
SetMsg("(Warning:"+cFullname+")")
RETURN NIL

*FUNCTION PickFile(cRoot,cStart,cWildcard)
*local aDir
*local i
*local a
*local cPath
*local cDir := cRoot+"\"+scSuffix
*do while .t.
*  aDir := LF_Directory(cDir+"\"+cWildcard)
*  if len(aDir) != 0
*    if Confirm("Okay to insert "+ntrim(len(aDir)+" images?"))
*      a := {}
*      for i := 1 to len(aDir)
*        aadd(a,aDir[i][LFN_LONG])
*      next i
*      RETURN a
*    endif
*  endif
*  aDir := LF_Directory(cDir)
*  a := {".."}
*  for i := 1 to len(aDir)
*    if PathExist(aDir[i][LFN_SHORT])
*      aadd(a,aDir[i][LFN_LONG])
*    endif
*  next i
*  cPath := ArrayPick( a, cDir, NIL, 60 )
*  RETURN NIL if cPath == NIL
*  cDir := cDir + "\" + cPath
*enddo
*RETURN NIL // never reached


* #ifdef DEF_WWW

FUNCTION root_suffix(cFilename,cSuffix)
local n := rat(".",cFilename)
RETURN left(cFilename,n-1)+cSuffix+substr(cFilename,n)

FUNCTION pic2html(cName,cParams,cTitle)
local s
local cRefURL // := cName
local nPos
* local nPos := rat(".",cName)
local cSrcURL
local cFilename
local cWidth
local cStyle
local cHeight
local cClass := "foto"
local cAltText
local cAlign
local cBorder := "0"
local avol
local a := { ;
  { "border", {|x|cBorder:=x}   }, ;
  { "width", {|x|cWidth:=x}   }, ;
  { "height", {|x|cHeight:=x} }, ;
  { "class", {|x|cClass:=x} }, ;
  { "align", {|x|cAlign:=x} }, ;
  { "alt", {|x|cAltText:=x}   }, ;
  { "href", {|x|cRefURL:=x}   }, ;
  { "style", {|x|cStyle:=x}   }  ;
}
RETURN .f. if ! parse_kw(cParams,a,{|x|cAltText:=cTitle:=x,.t.})
// cName := DrvCvtString(cName)
avol := volsplit(cName)
RETURN !SetMsg(cName+" : invalid volume specifier!") if avol == NIL
* default cAltText to cName
if !empty(cWidth).and. "/" $ cWidth
  cWidth := ntrim(int(xparse("400*"+cWidth)))
endif
if !empty(cHeight).and. "/" $ cHeight
  cHeight := ntrim(int(xparse("400*"+cHeight)))
endif
// RETURN .f. if !Confirm(cName)
cSrcUrl := eval(avol[1][VOL_URL],avol[1],trim(avol[2]))
* confirm(sSrcUrl)
* cSrcURL:=vol2url(cName)
default cRefURL to cSrcURL
** http://www.net-es.dk/~pj/python/gallery2.py
* if left(cName,5) == "fotos"
if avol[1][VOL_TYPE] == "gallery2"
  nPos := rat("/",cSrcURL)
  if nPos != 0
    if right(cName,4) == ".jpg"
      cRefURL := left(cSrcURL,len(cSrcURL)-4) + ".html"
    endif
    cSrcURL := left(cSrcURL,nPos) + "resized/" + substr(cSrcURL,nPos+1)
  endif
** http://www.dotfunk.com/projects/image_server :
elseif avol[1][VOL_TYPE] == "image_server"
* elseif left(cName,7) == "iserver"
  cSrcURL := strtran(cSrcUrl,"/show/","/thumb/")
elseif avol[1][VOL_TYPE] == "maketn"
  cFilename := root_suffix(;
    avol[1][VOL_PATH] + "\"+ strtran(avol[2],"/","\"), "_web")
  cSrcUrl := root_suffix(cSrcUrl,"_web")
  // RETURN !SetMsg(cFilename + MsgFileExist()) if ! file(cFilename)
endif
s := '<a href="'+ cRefURL+'"'
if cTitle != NIL
  s += ' title="' + DrvCvtString(cTitle)+'"'
endif
s += '>'
s += '<img src="' + cSrcURL + '" '
if cHeight != NIL
  s += 'style="height:' + cHeight + '; '
  if cWidth != NIL
    s += 'width:' + cWidth + '; '
  endif
  s+='" '
elseif cWidth != NIL
  s += 'style="width:' + cWidth + ';" '
endif
if cAlign != NIL
  s += ' align="' + cAlign+'"'
endif
if cClass != NIL
  s += ' class="' + cClass+'"'
endif
if cStyle != NIL
  s += ' style="' + cStyle+'"'
endif
if cAltText != NIL
  s += ' alt="' + cAltText + '"'
endif
s += ' border="' + cBorder + '"/>'
s += '</a>'
RETURN s

*endif
*** ab hier ist es nicht mehr unterhalten
*s := '<a href="'+ getBasePath()+"/images/pictures/" + cName
*if cTitle != NIL
*  s += '" title="'
*endif
** s += '" target="_blank">'
*s += '">'
*s += '<img src="' + getBasePath()
*s += '/images/pictures/'
*default cRefURL to cName
*s += cRefURL + '"'
*s += ' alt="' + cAltText+'"'
*s += ' border="' + cBorder + '"'
*if cWidth == NIL
*  default cHeight to "150"
*endif
*if cHeight != NIL ; s += ' height="' + cHeight + '"' ; endif
*if cWidth != NIL ; s += ' width="' + cWidth +'"' ; endif
*if cAlign != NIL
*  s += ' align="' + cAlign+'"'
*endif
** s += cParams + '>'
*s += '></a>'
*RETURN s

* #endif DEF_WWW

* 20070307 #endif DEF_LFN




#ifdef DEF_IMAGES

**
** IMG - Images
**
**
FUNCTION oImg()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                        ;
  name IMG                           ;
  editprint  ActExec('IMGPRINT') ;
  create AutoIncCopy(b) ;
  predelete ImgPreDelete(IMG->IdImg) ;
  wait {|wwin|ImgWait(wwin)}
ddIndex b on  IMG->IdImg format {|x|padl(x,LenIdPar())}
ddIndex b on  dtos(IMG->Date)+IMG->Time
ddFld IdImg   ,C, LenIdPar(),0 when .f.
ddFld Filename ,C, 100,0 pick PickLFN(getvar("ImagesRoot"),IMG->Filename)
ddFld IdUsr   ,C, LenIdUsr(),0 picture PIC_ID
ddFld Date    ,D, 8,0
ddFld Time    ,C, 8,0
ddFld Title1  ,C,100,0
ddFld Title2  ,C,100,0
ddFld Title3  ,C,100,0
ddFld Title4  ,C,100,0
ddEndDef()
RETURN b

FUNCTION ImgWait(wwin)
#ifdef DEF_RFX
  RETURN NIL if DoRfxWait(wwin,"IMG",IMG->IdImg)
#endif DEF_RFX
RETURN NIL



FUNCTION ImgTitle()
RETURN trim1(IMG->Title)

FUNCTION ImgPreDelete(cIdImg)
local lOkay := .t.
*  #ifdef DEF_RFX
*  if DbfSum({oRfx()},'1',2,padr('IMG:'+alltrim(IMG->IdImg),LEN_RFX)) != 0
*     RETURN !SetMsg('there are RFXs!')
*   endif
* #endif DEF_RFX
RETURN ConfirmDelete() if empty(cIdImg)
RETURN .f. if ! Confirm( ;
  IMG->IdImg + " " + trim(ImgTitle()) + " :", MsgRecDelete(), ;
  MSG_NO ;
)
#ifdef DEF_RFX
  // ... delete also RFX from this
#endif DEF_RFX
RETURN lOkay

FUNCTION ImgPage(cIdImg)
open area oImg(), oPrj()
  if cIdImg != NIL
    seek cIdImg
  endif
  edit data oImg() full noskip query ("IMG") title (ImgTitle())
close area
RETURN MnuDone()

#else

FUNCTION oImg() ; RETURN NIL

#endif DEF_IMAGES



