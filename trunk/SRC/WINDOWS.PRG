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

#include "memoedit.ch"
#include "LIB.CH"

* #define LUC_RPTLOG   // causes each window to be logged in report session
* #define LUC_SHADOW
#define LEN_LASTWIN 5

**
** STATIC_SECTION global static variables
**
static saWinList := {}
static w_count := 0
static slDialog := .T.
static saLastWin := {}
static scHelpDefault := NIL

#ifdef DEF_HELP

#define SH_IDHLP  1
#define SH_HOTKEY 2
#define SH_TEXT   3
#define SH_LINE   4
#define SH_COL    5
#define SH_ALEN   5

#define COLOR_HIGH "w+/n"
#define COLOR_UREF "b/w"

static saRef := {}    // list of array(SH_ALEN)
static saHlpIndex := {}
static scIdHlp    := NIL
static scLastIdHlp := NIL
static snTextBufRow := 0
* static snLastTextBufRow := 0
static saItemList := {}
static saNdx := NIL
static scHlpPath
static scSearchtext := NIL

static snTabIndex := 0

* static snParseCol
* static snParseRow

#endif DEF_HELP


**
** MSG_SECTION    MSGnnn definitions
**
#ifdef LG_FRENCH
  #define MSG001  " [Alt-F1] Aide [F10] Confirmer [Escape] Abandonner"
  #define WIN_001  "Liste de sÇlection"
  * #define TXT_040  "O"
  static TXT_041 := "Confirmation"
  #define TXT_042  "Avertissement"
  static TXT_043 := "Enfoncez une touche pour continuer"
  #define MSG_010  "RÇponse invalide. Tapez O ou N."
  #define MSG_011  "RÇponse invalide. Valeurs permises : "
  #define MSG013  "Il n'y a aucun Çcran suivant !"
  #define MSG014 " [Alt-F1] Aide [Esc] Quitter [Alt-T] Contenu [BkSp] PrÇcÇdent [Alt-X] Index"
  #define MSG015 "Table des matiäres"
  #define MSG016 "Ecran d'aide suivant :"
  #define MSG017 "Index d'aide"
  static MSG018 := "(Texte non disponible)"
  #define MSG019 "Chargement de l'index d'aide..."
  #define MSG020 " : Aide interactive"
  #define MSG021 " : Textes disponibles"
  #define MSG022 "RÇpertoire des textes d'aide"
  #define MSG_POPCALC_LEGEND "[Enter] afficher/sÇl. rÇsultat [Alt-,] dÇpl. fenàtre"
#endif

#ifdef LG_GERMAN
  #define MSG001  "[Alt-F1] Hilfe [F10] BestÑtigen [Escape] Abbruch"
  static TXT_041 := "BestÑtigung"
  #define TXT_042  "Warnung"
  static TXT_043 := "DrÅcken Sie eine Taste um weiterzumachen"
  #define MSG_010  "UngÅltige Antwort. Geben Sie J oder N ein."
  #define MSG_011  "UngÅltige Antwort. Erlaubte Werte : "
  #define MSG014 " [Alt-F1] Hilfe [Escape] Ende [Alt-T] Inhalt [BkSp] ZurÅck [Alt-X] Index"
  #define MSG015 "Inhaltsverzeichnis"
  #define MSG017 "Index Hilfefunktion"
  static MSG018 := "(Hilfetext nicht verfÅgbar))"
  #define MSG020 " Hilfe-Funktion"
  #define MSG021 " : Hilfetexte"
  #define MSG022 "Verzeichnis der Hilfetexte"
  #define MSG_POPCALC_LEGEND "[Enter] Resultat anz./Åbern. [Alt-,] Fenster verschieben"
#endif

#ifdef LG_EN
  #define MSG001  "[Alt-F1] Help [F10] Okay [Escape] Abort"
  static TXT_041 := "Confirmation"
  #define TXT_042  "Warning"
  static TXT_043 := "Press any key to continue..."
  #define MSG_010  "Invalid answer. Type Y or N."
  #define MSG_011  "Invalid answer. Allowed values : "
  #define MSG014 " [Alt-F1] Hilfe [Escape] Ende [Alt-T] Inhalt [BkSp] ZurÅck [Alt-X] Index"
  #define MSG015 "Inhaltsverzeichnis"
  #define MSG017 "Index Hilfefunktion"
  static MSG018 := "(Hilfetext nicht verfÅgbar))"
  #define MSG020 " Hilfe-Funktion"
  #define MSG021 " : Hilfetexte"
  #define MSG022 "Verzeichnis der Hilfetexte"
  #define MSG_POPCALC_LEGEND "[Enter] Resultat anz./Åbern. [Alt-,] Fenster verschieben"
#endif


**
** PROCEDURE_SECTION  - (...grins)
**
*
#define WS_TOP       1
#define WS_LEFT      2
#define WS_BOTTOM    3
#define WS_RIGHT     4
#define WS_BUF       5
#define WS_HOMEX     6
#define WS_HOMEY     7
#define WS_ENDX      8
#define WS_ENDY      9
#define WS_BOX      10
#define WS_GETLIST  11
#define WS_WIDTH    12
#define WS_LEG      13
#define WS_TITLE    14
#define WS_HELP     15
#define WS_STA      16
#define WS_COLOR    17
#define WS_ALEN     17


#ifndef DEF_GUI

**
** WinOpen()
**
FUNCTION WinOpen( cTitle, ;
                  nTop, nLeft, ;
                  nHeight, nWidth, ;
                  lPerm, cColor, nBox, cHelp,;
                  cLeg )
local buf
local win := array(WS_ALEN)
local w_box
local nBottom, nRight
default cHelp to "" // WinSetHelp()
* debugmsg "Gonna aadd window list..."
*
if empty(nWidth)  ; nWidth  := maxcol() + 1 ; endif
if empty(nHeight) ; nHeight := maxrow() + 1 ; endif
if empty(nTop)    ; nTop    := int( (maxrow() + 1 - nHeight) / 2 ) ; endif
if empty(nLeft)   ; nLeft   := int( (maxcol() + 1 - nWidth) / 2 )  ; endif
default lPerm   to .f.
default cLeg to MSG001
nHeight := min(nHeight,maxrow()+1)
nHeight := max(nHeight,3)
nWidth  := min(nWidth,maxcol()+1)
nWidth  := max(nWidth,5)
if nBox == NIL
  if nHeight == maxrow() + 1 .and. nWidth == maxcol() + 1
    w_box := "         "  // It is a full-screen window
  else
    w_box := B_DOUBLE + " " // It is a framed window
  endif
else
  do case
  case nBox == 0 ; w_box := "         "
  case nBox == 1 ; w_box := B_SINGLE + " "
  otherwise      ; w_box := B_DOUBLE + " "
  endcase
endif
*
nTop := min(nTop,maxrow()-nHeight)
nTop := max(nTop,0)
nLeft := min(nLeft,maxcol()-nWidth)
nLeft := max(nLeft,0)
*
nBottom := nTop + nHeight - 1
nRight := nLeft + nWidth  - 1
*
win[WS_TOP]      := nTop
win[WS_LEFT]     := nLeft
win[WS_BOTTOM]   := nBottom
win[WS_RIGHT]    := nRight
win[WS_HOMEY]    := nTop
win[WS_HOMEX]    := nLeft
win[WS_ENDY]     := nBottom
win[WS_ENDX]     := nRight
win[WS_BOX]      := w_box
win[WS_WIDTH]    := nWidth
win[WS_TITLE]    := cTitle
win[WS_HELP]     := cHelp
* default win[WS_HELP] to ""
default win[WS_TITLE] to ""
#ifdef DEF_NANFOR // LUC_SHADOW
  if ! empty( w_box )
    win[WS_BOTTOM]  += 1
    win[WS_RIGHT]   += 2
  endif
#endif
if lPerm
  win[WS_BUF] := NIL
else
  win[WS_BUF] := savescreen( nTop, nLeft, win[WS_BOTTOM], win[WS_RIGHT] )
  win[WS_LEG] := SetLeg()
  win[WS_STA] := SetSta()
endif
win[WS_GETLIST] := GetList
aadd( saWinList, win )
**
GetList := { }
*
win[WS_COLOR] := setcolor()
win_setcolor(win,cColor)
if empty( w_box )
  scroll( nTop, nLeft, nBottom, nRight )
else
  #ifdef DEF_SHADOW // LUC_SHADOW
    if nRight < maxcol() - 1
      ft_shadow( nTop, nLeft, nBottom, nRight )
    endif
  #endif
  dispbox( nTop, nLeft, nBottom, nRight, w_box )
  win[WS_HOMEX] += 2
  win[WS_ENDX]  -= 2
  win[WS_HOMEY] += 1
  win[WS_ENDY]  -= 1
  win[WS_WIDTH] -= 4
endif
if ! empty(cTitle)
  if empty(w_box)
    @ win[WS_HOMEY], win[WS_HOMEX] say padc( cTitle, win[WS_WIDTH] ) ;
                                   color (CfgLegendColor())
    win[WS_HOMEY] += 1
  else
    @ nTop, int( (nLeft+nRight-len(cTitle)) / 2 )  ;
      say " " + cTitle + " "
  endif
endif
#ifdef LUC_RPTLOG
  if ! empty(cTitle)
    rpt_write( space( 2 * (len(saWinList)-1) ) + "˘" + cTitle )
  endif
#endif
if ! lPerm
  SayLeg(cLeg)
endif
SetPos( win[WS_HOMEY], win[WS_HOMEX] )
RETURN NIL


STATIC FUNCTION win_setcolor(win,cColor)
if cColor == NIL
  if empty(win[WS_BOX])
    cColor := CfgBrowseColor()
  else
    cColor := CfgWindowColor()
  endif
endif
setcolor( cColor )
RETURN .t.

FUNCTION WinLoadColor()
RETURN .f. if len(saWinList) == 0
RETURN win_setColor(atail(saWinList))



**
** WinInfo() - for debugging only...
**
*FUNCTION WinInfo
*local win := atail( saWinList )
*open window "Window information" size 13,60
*@row(), col() say "Top    " + ntrim(win[WS_TOP    ]) ; WinCR()
*@row(), col() say "Left   " + ntrim(win[WS_LEFT   ]) ; WinCR()
*@row(), col() say "Bottom " + ntrim(win[WS_BOTTOM ]) ; WinCR()
*@row(), col() say "Right  " + ntrim(win[WS_RIGHT  ]) ; WinCR()
*@row(), col() say "HomeX  " + ntrim(win[WS_HOMEX  ]) ; WinCR()
*@row(), col() say "HomeY  " + ntrim(win[WS_HOMEY  ]) ; WinCR()
*@row(), col() say "EndX   " + ntrim(win[WS_ENDX   ]) ; WinCR()
*@row(), col() say "EndY   " + ntrim(win[WS_ENDY   ]) ; WinCR()
*@row(), col() say "Box    " + win[WS_BOX    ]        ; WinCR()
*@row(), col() say "Width  " + ntrim(win[WS_WIDTH  ])
*WaitKey()
*close window
*RETURN NIL

**
** WinClose()
**
FUNCTION WinClose
local nWinCount := len( saWinList )
local win := atail( saWinList )
* local cLeg
RETURN .f. if nWinCount == 0
asize(saWinList,nWinCount - 1)
aadd(saLastWin, "[" + win[WS_HELP] + "] " + win[WS_TITLE])
if len(saLastWin) > LEN_LASTWIN
  adel(saLastWin,1)
  asize(saLastWin,LEN_LASTWIN)
endif
if win[WS_BUF] != NIL
  restscreen( win[WS_TOP]    , ;
              win[WS_LEFT]   , ;
              win[WS_BOTTOM] , ;
              win[WS_RIGHT]  , ;
              win[WS_BUF]    )
  SayLeg( win[WS_LEG] )
  SaySta( win[WS_STA] )
endif
GetList := win[WS_GETLIST]
setcolor(win[WS_COLOR])
* SayLeg(cLeg)
RETURN .T.

FUNCTION WinDisp2(cText)
local win := atail( saWinList )
@ win[WS_ENDY] + 1, win[WS_ENDX] - 4 - len(cText) say cText
RETURN NIL

FUNCTION WinDrop
local win := atail( saWinList )
win[WS_BUF] := NIL
WinClose()
RETURN NIL

FUNCTION WinCR()
local win := atail( saWinList )
SetPos(row()+1,win[WS_HOMEX])
RETURN NIL
*
FUNCTION WinHome
local win := atail( saWinList )
SetPos(win[WS_HOMEY],win[WS_HOMEX])
RETURN NIL
*
FUNCTION WinWidth
local win := atail( saWinList )
RETURN maxcol() if win == NIL
RETURN win[WS_ENDX] - win[WS_HOMEX]
*
FUNCTION WinEndX
local win := atail( saWinList )
RETURN win[WS_ENDX]
*
FUNCTION WinEndY
local win := atail( saWinList )
RETURN win[WS_ENDY]
*
FUNCTION WinTop
local win := atail( saWinList )
RETURN win[WS_HOMEY]
*
FUNCTION WinLeft
local win := atail( saWinList )
RETURN win[WS_HOMEX]
*
FUNCTION WinIsFull
local win := atail( saWinList )
RETURN win[WS_TOP] == 0
*
FUNCTION WinTitle
local win := atail( saWinList )
RETURN win[WS_TITLE]



#define MEMO_WRAP_WIDTH 72 // bis 19990419 : 76

**
** Confirm()
**
FUNCTION Confirm(cMemo,txt2,cAnswer,cHelp,aKeys,cTitle,nTop)
local mnKey := nKey
local nLen
local nHeight
local nLin, nCol
local i
default cTitle to TXT_041
default cAnswer to MSG_YES
default aKeys to {}
if slDialog
  if txt2 != NIL
    cMemo += CR_LF + txt2
  endif
  nHeight := mlcount(cMemo,MEMO_WRAP_WIDTH)
  nLen := len(cTitle)
  for i := 1 to nHeight
    nLen := max(nLen,len(trim(memoline(cMemo,MEMO_WRAP_WIDTH,i))))
  next i
  nLen += 4
  open window (cTitle) ;
       size nHeight+2 , nLen+4 ;
       help (cHelp) home nTop,NIL
  for i := 1 to nHeight
    say trim(padc(trim(memoline(cMemo,MEMO_WRAP_WIDTH,i)),nLen))
    if i < nHeight
      WinCr()
    endif
  next i
  nLin := row()
  nCol := col() + 1
  keyboard ""
  do while .t.
    AppTerminate(.f.)
    @ nLin, nCol get cAnswer picture "!"
    nKey := ReadScr()
    for i := 1 to len(aKeys)
      if nKey == aKeys[i][1]
        eval(aKeys[i][2])
        loop
      endif
    next i
    if nKey != K_ESC
      if cAnswer == MSG_NO
        exit
      elseif cAnswer $ "YJO" // MSG_YES
        exit
      endif
    endif
    SetMsg(MSG_010)
  enddo
  close window
  nKey := mnKey
else
  SetMsg(cMemo)
endif
RETURN ( cAnswer $ "YJO" )

**
** Warning()
**
FUNCTION Warning(cMemo,txt2,cHelp,lConsole,cTitle,lCenter)
local i
local nLen := len(TXT_043)
local nHeight
local nKey
default cHelp to "WARNING"
default cTitle to TXT_042
default lCenter to .t.
if txt2 != NIL
  if !empty(cMemo)
    cMemo += CR_LF
  endif
  cMemo += txt2
endif
nHeight := mlcount(cMemo,MEMO_WRAP_WIDTH)
nLen := len(TXT_043)
for i := 1 to nHeight
  nLen := max(nLen,len(trim(memoline(cMemo,MEMO_WRAP_WIDTH,i))))
next i
nLen += 5
#ifdef DEF_CONSOLE
  default lConsole to .f.
  if lConsole
    SendConsole(cTitle + " : " + cMemo)
  endif
#endif DEF_CONSOLE
RETURN .t. if SetBatch()
Alarm()
open window (cTitle) size nHeight+3 , nLen+4 help (cHelp)
  for i := 1 to nHeight
    if lCenter
      say trim(padc(trim(memoline(cMemo,MEMO_WRAP_WIDTH,i)),nLen))
    else
      say trim(memoline(cMemo,MEMO_WRAP_WIDTH,i))
    endif
    if i < nHeight
      WinCr()
    endif
  next i
  WinCR()
  say trim(padc(TXT_043,nLen))
  if slDialog
    keyboard ""
    KillKeyStack()
    nKey := WaitKeySet()
  else
    PrintLine(cTitle + " : " + cMemo)
    if ! empty(SetMsg())
      PrintLine(SetMsg())
    endif
  endif
  RptLogDetail()
close window
RETURN .t. // nKey

* FUNCTION MemoWarning(cMemo,cTitle,cHelp)
* local i
* local cLine
* rpt_write(cTitle)
* open window (cTitle) size 13,74 help (cHelp)
* for i := 1 to 10
*   cLine := memoline(cMemo,70,i)
*   say cLine
*   WinCr()
*   if ! empty(cLine)
*     rpt_write("  " + cLine)
*   endif
* next i
* say padc(TXT_043,70)
* nKey := WaitKeySet()
* close window
* RETURN NIL

**
** Decide()
**
FUNCTION Decide(cValid,txt1,txt2,cTitle)
local cAnswer := " "
local mnKey := nKey
local nLen := len(txt1)
local nHeight := 3
local nLin, nCol
* Alarm()
if txt2 != NIL
  if len(txt2) > nLen
    nLen = len(txt2)
  endif
  nHeight++
endif
nLen += 5
open window (cTitle) size nHeight, nLen+4
say trim(padc(txt1,nLen))
if txt2 != NIL
  WinCR()
  say trim(padc(txt2,nLen))
endif
nLin := row()
nCol := col() + 1
do while .t.
  @ nLin, nCol get cAnswer pict "!"
  nKey := ReadScr()
  if nKey == K_ESC
    cAnswer := ""
    exit
  endif
  if cAnswer $ cValid
    exit
  endif
  SetMsg(MSG_011 + cValid + "." )
enddo
close window
nKey := mnKey
RETURN cAnswer


**
** ddWinAdapt() - Adapts browse object to current window size & position
**                Not only for non-full-screen windows
**
*FUNCTION ddWinAdapt( b )
*local win := atail(saWinList)
*b:colorSpec := setcolor()
*b:nTop      := WinTop()
*b:nLeft     := WinLeft()
*b:nRight    := WinEndX()
*if WinIsFull()
*  * BarSet( hBar, NIL, NIL, 0, 0, maxcol() )
*  b:nBottom   := WinEndY() - 3
*  b:footSep := "¡ƒ"
*else
*  * BarSet( hBar, NIL, NIL, WinTop()-2, WinLeft()-2, WinEndX()+2 )
*  b:nBottom   := WinEndY()
*  b:footSep := ""
*endif
*default win[WS_HELP] to b:cargo[AD_NAME]
*RETURN NIL

FUNCTION WinSetHelp(cHelp)
local win := atail(saWinList)
if len(saWinList) == 0
  if cHelp != NIL
    scHelpDefault := cHelp
  endif
  RETURN ProgName() if scHelpDefault == NIL
  RETURN scHelpDefault
endif
if cHelp != NIL
  win[WS_HELP] := trim(cHelp)
endif
RETURN win[WS_HELP]

#endif DEF_GUI

**
** SetDialog() : Warnungen und BestÑtigungen werden zum Drucker
**               umgeleitet.
**
FUNCTION SetDialog(lNew)
local lOld := slDialog
if lNew != NIL
  slDialog := lNew
endif
RETURN lOld

FUNCTION WinReport()
local i
rpt_write("Open windows :")
for i := 1 to len(saWinList)
  * default saWinList[i][WS_TITLE] to "(no title)"
  rpt_write( space( 2 * (i-1) ) + "[" + saWinList[i][WS_HELP] + "] " + saWinList[i][WS_TITLE] )
next i
rpt_write("Window history :")
for i := 1 to len(saLastWin)
  rpt_write(saLastWin[i])
next i
RETURN NIL


#ifdef DEF_HELP

**
** WinHelp()
**
FUNCTION WinHelp(cIdHlp,cHlpPath)
local cMemo
local nCursor := setcursor(SC_NONE)
local i
local cFileName
local bKeyAltF1
local cSaveHlpPath := scHlpPath
default cHlpPath to AppHelpPath()
scHlpPath := cHlpPath
snTabIndex := 0
if cIdHlp == NIL
  for i := len(saWinList) to 1 step -1
    if ! empty(saWinList[i][WS_HELP])
      if HlpExist(saWinList[i][WS_HELP])
        scIdHlp := saWinList[i][WS_HELP]
        exit
      endif
    endif
  next i
  default scIdHlp to ProgName()
else
  scIdHlp := cIdHlp
  ** [19980106] wenn ich im HauptmenÅ p,h drÅcken, dann sitzt das "H"
  ** noch in lastkey() und wird in HLPMEMO() ausgewertet...
  keyboard "Ê"
  inkey()
endif
open window (ProgName() + MSG020) ;
            size 20,80 ;
            color (CfgHelpColor()) ;
            legend (MSG014)
* HlpInit()
do while scIdHlp != NIL
  cFileName := scHlpPath + "\" + scIdHlp + ".HLP"
  scLastIdHlp      := scIdHlp
  scIdHlp := NIL
  cMemo := HlpLoad(cFileName)
  bKeyAltF1 := SetKey(K_ALT_F1,NIL)
  SetKey(K_TAB,{||TabSettle(1)})
  SetKey(K_SH_TAB,{||TabSettle(-1)})
  SetKey(K_ENTER,{||TabActivate()})
  memoedit( ;
            cMemo, ;
            WinTop(), WinLeft(), WinEndY(), WinEndX(), ;
            .f., "HLPMEMO", 120, NIL, snTextBufRow ;
  )
  SetKey(K_ALT_F1, bKeyAltF1)
  SetKey(K_TAB,NIL)
  SetKey(K_SH_TAB,NIL)
  SetKey(K_ENTER,NIL)
enddo
close window
setcursor(nCursor)
scHlpPath := cSaveHlpPath
RETURN .f.




**
** HLPMEMO - UDF for MemoEdit()
**
FUNCTION HLPMEMO( nMode, nRow, nCol )
local uReturn := ME_DEFAULT
local i
local cStatus
if nMode == ME_IDLE
  snTextBufRow := nRow
  cStatus := scLastIdHlp + "(" + ntrim(nRow) + ")"
  SayMsg()
  WinDisp2( padl(cStatus,12,"Õ") )
  ** K_BS und verschiedene Tasten sind nicht konfigurierbar.
  ** keine UNKEY. Also ME_IDLE ausnutzen...
  if lastkey() == K_BS
    if HlpPrevItem()
      keyboard chr(K_ESC)
      RETURN NIL
    else
      Alarm()
    endif
  else
    ** irgendeine data key
    for i := 1 to len(saRef)
      if upper(saRef[i][SH_HOTKEY]) == upper(chr(lastkey()))
        if HlpGoItem(saRef[i][SH_IDHLP])
          keyboard chr(K_ESC)
          RETURN NIL
        endif
      endif
    next i
  endif
  TabShow()
  RETURN NIL // wird nicht ausgewertet weil ME_IDLE ...
endif
SetKey(K_TAB,NIL)
SetKey(K_SH_TAB,NIL)
SetKey(K_ENTER,NIL)
if nMode == ME_UNKEY .or. nMode == ME_UNKEYX
  ** In diesen beiden FÑllen wird der RETURN-Wert von memoedit()
  ** beachtet. Deshalb ist keyboard chr(K_ESC) nicht nîtig
  **
  if lastkey() == K_ALT_F4
    AppTerminate(.t.)
    uReturn := K_ESC
  elseif lastkey() == K_F3
    FileEdit(scHlpPath + "\" + scLastIdHlp + ".HLP")
    scIdHlp := scLastIdHlp
    uReturn := K_ESC
  #ifdef DEF_PRINT
  elseif lastkey() == K_F7
    HlpPrint(scLastIdHlp)
    scIdHlp := scLastIdHlp
    uReturn := K_ESC
  #endif DEF_PRINT
  elseif lastkey() == K_F10
    saHlpIndex := {}
    saNdx := NIL
    uReturn := K_ESC
  elseif lastkey() == K_ALT_F1 .and. scIdHlp != "INDEX"
    if HlpGoItem("INDEX")
      uReturn := K_ESC
    endif
  * elseif lastkey() == K_ALT_T .and. scIdHlp != "INDEX"
  *   if HlpGoItem("INDEX")
  *     uReturn := K_ESC
  *   endif
  elseif lastkey() == K_ALT_G
    if HlpGoItem(PickIndex(scLastIdHlp))
      uReturn := K_ESC
    endif
  elseif lastkey() == K_CTRL_DOWN
    if HlpSearch(.f.)
      uReturn := K_ESC
    endif
  elseif lastkey() == K_CTRL_UP
    if HlpSearch(.t.)
      uReturn := K_ESC
    endif
  elseif lastkey() == K_ALT_X
    if HlpGoItem(PickNdx())
      uReturn := K_ESC
    endif
  endif
endif
SetKey(K_TAB,{||TabSettle(1)})
SetKey(K_SH_TAB,{||TabSettle(-1)})
SetKey(K_ENTER,{||TabActivate()})
RETURN uReturn

FUNCTION TabShow() // cSelColor)
local i
* RETURN NIL if len(saRef) == 0
for i := 1 to len(saRef)
  if saRef[i][SH_LINE] != 0 .and. TabVisible(saRef[i])
    @ saRef[i][SH_LINE] - snTextBufRow + 1 , ;
      saRef[i][SH_COL] ;
      say saRef[i][SH_TEXT] ;
      color (if(i==snTabIndex,COLOR_HIGH,COLOR_UREF))
  endif
next i
RETURN NIL

FUNCTION TabSettle(nSkip)
local nTabIndex := snTabIndex
RETURN NIL if len(saRef) == 0
// TabShow(CfgHelpColor())
do while .t.
  snTabIndex += nSkip
  if snTabIndex > len(saRef)
    snTabIndex := 1
  elseif snTabIndex < 1
    snTabIndex := len(saRef)
  endif
  if TabVisible(saRef[snTabIndex])
    exit
  endif
enddo
TabShow() // COLOR_HIGH)
RETURN NIL

FUNCTION TabVisible(sh)
RETURN .f. if sh[SH_LINE] - snTextBufRow < 2
RETURN .f. if sh[SH_LINE] - snTextBufRow > 19
RETURN .t.


FUNCTION TabActivate
RETURN NIL if snTabIndex == 0
RETURN NIL if ! HlpGoItem(saRef[snTabIndex][SH_IDHLP])
keyboard chr(K_ESC)
RETURN NIL

FUNCTION HlpSearch(lBack)
static aDir := NIL
static i := NIL
local nPos
default scSearchtext to ""
scSearchtext := padr(scSearchtext,50)
open window "Suchen" size 3,60
say "Text "
get scSearchText valid (i := NIL) == NIL
nKey := ReadScr()
close window
scSearchtext := trim(scSearchtext)
RETURN .f. if nKey == K_ESC
default aDir to directory(scHlpPath + "\*.HLP")
RETURN .f. if len(aDir) == 0
MsgDisplay("Suchen nach " + scSearchtext + "...")
if lBack
  default i to len(aDir)
else
  default i to 0
endif
do while .t.
  if TaskInter() ; exit ; endif
  if lBack
    MsgDisp2(ntrim0(100 - i*100/len(aDir)) + "%")
    i--
    if i < 1
      SetMsg("nicht gefunden")
      RETURN .f.
    endif
  else
    MsgDisp2(ntrim0(i*100/len(aDir)) + "%")
    i++
    if i > len(aDir)
      SetMsg("nicht gefunden")
      RETURN .f.
    endif
  endif
  nPos := at( ;
    upper(scSearchText), ;
    upper(memoread(scHlpPath+"\"+aDir[i][F_NAME])) ;
  )
  if nPos != 0
    HlpGoItem(strtran(aDir[i][F_NAME],".HLP"))
    snTextBufRow := NIL
    exit
  endif
enddo
MsgDisplay("")
RETURN .t.

#ifdef DEF_PRINT

**
** HlpPrint()
**
FUNCTION HlpPrint(cIdHlp)
local cMemo
local cFileName
cFileName := scHlpPath + "\" + cIdHlp + ".HLP"
cMemo := HlpLoad(cFileName)
open printer "HELP" width 76
  TplParse(cMemo)
close printer
RETURN NIL

#endif DEF_PRINT


STATIC FUNCTION HlpLoad(cFilename) // ,cSearch)
local cLine
local aCommands := {}
local nPos1
local nPos2
* local nLen
local cNewMemo := ""
local cCode
local cParam
local cRetVal
local i
local lFound
local cChar
local cOldChar
local a
local nLine := 6
local nCol
local lCrlf
local cMemo := mopen(cFilename)
RETURN MSG018 if cMemo == NIL
MsgDisplay(MsgLoading(cFilename))
aadd(aCommands, { "ref", {|x,nLine,nCol| AddSiehe(x,nLine,nCol) } } )
aadd(aCommands, { "xe" , {|x,nLine,nCol| GetOneEntry(x) } } )
saRef := {}
cNewMemo := repl("ƒ",76) + CR_LF
cNewMemo += padc(mgetline(cMemo),76) + CR_LF
cNewMemo += repl("ƒ",76) + CR_LF
do while (cLine := mgetline(cMemo)) != NIL
  if snTextBufRow == NIL .and. scSearchtext != NIL
    if upper(scSearchText) $ upper(cLine)
      snTextBufRow := nLine - 2
    endif
  endif
  nCol := 2
  ** Eine Zeile, die *nur* {}-Codes enthÑlt, darf nicht sichtbar sein
  ** Eine einfache Leerzeile dagegen ist wohl sichtbar...
  lCrlf := empty(cLine)
  do while (nPos1 := at("{",cLine)) != 0
    **
    if nPos1 > 1
      lCrlf := .t.
    endif
    * if nPos1 > 1 .and. substr(cLine,nPos-1,1) == "\"
    * endif
    nCol += (nPos1-1)
    ** zunÑchst wird das StÅck bis *vor* den ersten "{" unverÑndert
    ** Åbernommen :
    cNewMemo += left(cLine,nPos1-1)
    cLine := substr(cLine,nPos1)
    **
    ** Jetzt muss ich den schlie·enden "}" ausfindig machen. Das ist
    ** nicht unbedingt der nÑchste. {}-Codes sollen ja erstens
    ** ineinandergeschachtelt sein dÅrfen, und zweitens soll "\" als
    ** Escape-Zeichen dienen
    **
    nPos2 := 0         // nPos2 : Position des schliessenden "}"
                       // 0  : noch nicht gefunden
                       // -1 : sogar noch einen weiteren îffnenden "{"
                       //      gefunden (also den nÑchsten schliessenden
                       //      nicht nehmen.
                       // > 0 : nPos2 enthÑlt die gesuchte Position
    i := 2    // frÅhestens an der 2. Position in cLine
    * nLen := len(cLine) // weil cLine recht lang sein kînnte
    do while nPos2 <= 0 .and. i <= len(cLine)
      cOldChar := cChar
      cChar := substr(cLine,i,1)
      if cChar == "{" .and. cOldChar != "\"
        nPos2 --  // einen nesting-level rauf schalten
      elseif cChar == "}" .and. cOldChar != "\"
        nPos2++
        if nPos2 > 0
          nPos2 := i
          exit
        endif
      *elseif cChar == chr(13) .and. cOldChar != "\"
      *  ** Ein Maskenbefehl darf nicht auf mehrere Zeilen verteilt sein
      *  ** CR_LF ist also auch ein implizites Maskenbefehl-Ende
      *  ** Ausser wenn die CR_LFs durch "\" escaped werden.
      *  nPos2 := i
      *  exit
      endif
      i++
    enddo
    if nPos2 <= 0
      ** Wenn es keine schlie·ende "}" gibt...
      * cNewMemo += cLine
      * cLine := ""
      exit
    endif
    ** nPos1 wird jetzt benutzt, um eventuelle Befehlsparameter zu
    ** identifizieren.
    nPos1 := at(" ",cLine)
    if nPos1 == 0 .or. nPos1 > nPos2
      cCode  := substr(cLine,2,nPos2-2)
      cParam := ""
    else
      cCode  := substr(cLine,2,nPos1-2)
      cParam := substr(cLine,nPos1+1,nPos2-nPos1-1)
    endif
    cRetVal := NIL
    lFound  := .f.
    for i := 1 to len(aCommands)
      if aCommands[i][1] == cCode
        cRetVal := eval(aCommands[i][2],cParam,nLine,nCol)
        lFound := .t.
        * RETURN NIL if cRetVal == NIL  ****** was sollte DAS denn...?
        ** dann war es nÑmlich ein Befehl, der nichts ersetzt, sondern
        ** selbst die nîtigen PrintLines() aufruft. In diesem Fall wird
        ** die Zeile hier ignoriert.
        exit
      endif
    next i
    if lFound
      if cRetVal == NIL
        cLine := substr(cLine,nPos2+1)
      else
        cNewMemo += cRetVal
        lCrlf := .t.
        cLine := substr(cLine,nPos2+1)
      endif
    * elseif left(cCode,1) == "="
    *   cNewMemo += EvalExpr(substr(cCode,2)+cParam)
    *   cLine := substr(cLine,nPos2+1)
    else
      cNewMemo += left(cLine,nPos2)
      cLine := substr(cLine,nPos2+1)
    endif
  enddo
  if ! empty(cLine)
    cNewMemo += cLine + CR_LF
    nLine++
  elseif lCrlf
    cNewMemo += CR_LF
    nLine++
  endif
enddo
default snTextBufRow to 0
mclose(cMemo)
* aadd(saRef, { "INDEX", " ", HlpTitel("INDEX"), 0, 0 }) // SH_ALEN
MsgDisplay("")
RETURN cNewMemo

STATIC FUNCTION AddSiehe(cLine,nLine,nCol)
local nPos
local cIdHlp
local cHotKey := " "
local lShow := .t.
* cLine := upper(cLine)
* if "/s" $ cLine
*   cLine := trim(strtran(cLine,"/s"))
*   lShow := .t.
* endif
* if "/h" $ cLine
*   cLine := trim(strtran(cLine,"/h"))
*   lShow := .f.
* endif
if (nPos := at(" ",cLine)) == 0
  cIdHlp := upper(cLine)
  cLine := HlpTitel(cIdHlp)
else
  cIdHlp := left(cLine,nPos-1)
  cLine  := substr(cLine,nPos+1)
  if (nPos := at(" ",cLine)) == 0
    cHotKey := upper(cLine)
    cLine   := cHotKey + " : " + HlpTitel(cIdHlp)
  else
    cHotKey := upper(left(cLine,nPos-1))
    cLine  := cHotKey + " : " + substr(cLine,nPos+1)
  endif
endif
aadd(saRef, { cIdHlp, cHotKey, cLine, nLine, nCol } ) // SH_ALEN
if lShow
  RETURN cLine
  * if empty(cHotKey)
  *   RETURN chr(34) + cLine + chr(34)
  * else
  *   RETURN ">>> " + cHotKey + " : " + cLine
  * endif
endif
RETURN NIL


FUNCTION HlpGoItem(cIdHlp,nLine)
local x
RETURN .f. if cIdHlp == NIL
* if left(cIdHlp,1) == "="
*   SetKey(K_TAB,NIL)
*   SetKey(K_SH_TAB,NIL)
*   SetKey(K_ENTER,NIL)
*   x := &(substr(cIdHlp,2))
*   SetKey(K_TAB,{||TabSettle(1)})
*   SetKey(K_SH_TAB,{||TabSettle(-1)})
*   SetKey(K_ENTER,{||TabActivate()})
*   RETURN .f.
* else
  aadd(saItemList, { scLastIdHlp, snTextBufRow, snTabIndex } )
  // default nLine to 0
  * snTextBufRow := 0 // nLine
  snTabIndex   := 0
  scIdHlp := cIdHlp
* endif
RETURN .t.

FUNCTION HlpPrevItem
RETURN .f. if len(saItemList) == 0
scIdHlp      := atail(saItemList)[1]
snTextBufRow := atail(saItemList)[2]
snTabIndex   := atail(saItemList)[3]
asize(saItemList,len(saItemList)-1)
RETURN .t.

*STATIC FUNCTION PickSiehe
*local i
*local aRef := {}
*for i := 1 to len(saRef)
*  if empty(saRef[i][SH_HOTKEY])
*    aadd(aRef, saRef[i])
*  endif
*next i
*RETURN NIL if len(aRef) == 0
*browse array aRef ;
*       using {|a| a[SH_HOTKEY] + " " + ;
*             padr(HlpTitel(a[SH_IDHLP]),50) + " " + ;
*             padl(a[SH_IDHLP],8) } ;
*       title (MSG016)
*RETURN NIL if LastChoice() == 0
*RETURN aRef[LastChoice()][SH_IDHLP]

STATIC FUNCTION PickIndex
local i
RETURN NIL if len(saHlpIndex) == 0
browse array saHlpIndex ;
       using {|a| padr(a[2],50) + " " + padr(a[1],8) } ;
       title (MSG022)
RETURN NIL if LastChoice() == 0
RETURN saHlpIndex[LastChoice()][1]

STATIC FUNCTION HlpTitel(cIdHlp)
local i
local cLine
for i := 1 to len(saHlpIndex)
  if saHlpIndex[i][1] == cIdHlp
    RETURN saHlpIndex[i][2]
  endif
next i
cLine := FileFirstLine(scHlpPath + "\" + cIdHlp + ".HLP")
if empty(cLine)
  cLine := cIdHlp + ".HLP (nicht vorhanden)"
endif
aadd(saHlpIndex, { cIdHlp, cLine } )
RETURN cLine

#define NDX_WORD   1
#define NDX_AIDHLP 2

STATIC FUNCTION PickNdx()
local fd
local cLine
local i
local cFile := scHlpPath + "\_INDEX.HLP"
static nStart := 0
if saNdx == NIL
  saNdx := {}
  if file(cFile)
    MsgDisplay("Loading index...")
    RETURN NIL if (fd := mopen(cFile)) == NIL
    do while (cLine := mgetline(fd)) != NIL
      if TaskInter() ; exit ; endif
      AddNdxEntry(alltrim(cLine))
    enddo
    mclose(fd)
  else
    MsgDisplay("Building _INDEX...")
    HlpBuildIndex(cFile)
  endif
  MsgDisplay("")
endif
SetKey(K_TAB,NIL)
SetKey(K_SH_TAB,NIL)
SetKey(K_ENTER,NIL)
browse array saNdx ;
             using {|a| padr(a[NDX_WORD],40) } ;
             start nStart ;
             title (MSG017)
SetKey(K_TAB,{||TabSettle(1)})
SetKey(K_SH_TAB,{||TabSettle(-1)})
SetKey(K_ENTER,{||TabActivate()})
RETURN NIL if LastChoice() == 0
nStart := LastChoice()
browse array saNdx[nStart][NDX_AIDHLP] ;
             using {|cIdHlp| padr(HlpTitel(cIdHlp),50) } ;
             title (saNdx[nStart][NDX_WORD] + MSG021)
RETURN NIL if LastChoice() == 0
RETURN saNdx[nStart][NDX_AIDHLP][LastChoice()]

*STATIC FUNCTION HlpInit()
*local fd
*local cLine
*local cFile := scHlpPath + "\_TOC.HLP"
*RETURN NIL if len(saHlpIndex) > 0
*if file(cFile)
*  MsgDisplay(MSG019)
*  if (fd := fopen(cFile) == -1
*    Warning(cFile,MsgDosError())
*    RETURN NIL
*  endif
*  do while (cLine := freadline(fd)) != NIL
*    if TaskInter() ; exit ; endif
*    AddTocEntry(alltrim(cLine))
*  enddo
*  fclose(fd)
*else
*  MsgDisplay("Building _TOC...")
*  HlpBuildToc(cFile)
*endif
*MsgDisplay("")
*RETURN NIL


* STATIC FUNCTION AddTocEntry(cLine)
* local nPos
* if (nPos := at(" ",cLine)) != 0
*   aadd(saHlpIndex, { ;
*                      alltrim(left(cLine,nPos)), ;
*                      alltrim(substr(cLine,nPos+1)) ;
*                    } ;
*   )
* endif
* RETURN NIL
*
*
* STATIC FUNCTION HlpBuildToc(cFile)
* local aDir := directory(scHlpPath + "\*.HLP")
* local fd
* local i
* local cIdHlp
* if (fd := fcreate(cFile)) == -1
*   Warning(cFile,MsgDosError())
*   RETURN NIL
* endif
* for i := 1 to len(aDir)
*   cIdHlp := strtran(aDir[i][F_NAME],".HLP")
*   aadd(saHlpIndex, { cIdHlp, FileFirstLine(scHlpPath + "\" + cIdHlp + ".HLP") } )
* next i
* asort(saHlpIndex, NIL, NIL, {|x,y| upper(x[2]) < upper(y[2]) } )
* for i := 1 to len(saHlpIndex)
*   fwrite(fd, ;
*     padr(saHlpIndex[i][1],9) + ;
*     saHlpIndex[i][2] + CR_LF ;
*   )
* next i
* fclose(fd)
* RETURN fd

STATIC FUNCTION AddNdxEntry(cLine)
local nPos
if (nPos := at("=>",cLine)) != 0
  aadd(saNdx, { ;
                     alltrim(left(cLine,nPos-1)), ;
                     ListAsArray( ;
                       alltrim(substr(cLine,nPos+2)), ;
                       " " ;
                     ) ;
                   } ;
  )
else
  Warning(cLine + " : invalid _index.hlp entry !")
endif
RETURN NIL

STATIC FUNCTION HlpBuildIndex(cFile)
local aDir := directory(scHlpPath + "\*.HLP")
local fd
local i
local j
local cIdHlp
saNdx := {}
for i := 1 to len(aDir)
  cIdHlp := strtran(aDir[i][F_NAME],".HLP")
  MsgDisp2(cIdHlp)
  if left(cIdHlp,1) != "_"
    * LoadNdxEntries(cIdHlp)
  endif
next i
if (fd := fcreate(cFile)) != -1
  asort(saNdx,NIL,NIL, {|x,y|upper(x[1]) < upper(y[1])} )
  for i := 1 to len(saNdx)
    fwrite(fd, saNdx[i][1] + " =>" )
    for j := 1 to len(saNdx[i][2])
      fwrite(fd, " " + saNdx[i][2][j] )
    next j
    fwrite(fd, CR_LF)
  next i
  fclose(fd)
endif
RETURN fd

* STATIC FUNCTION LoadNdxEntries(cIdHlp)
* local aCommands := {}
* local cFileName := scHlpPath + "\" + cIdHlp + ".HLP"
* aadd(aCommands, { "xe", {|cParam| GetOneEntry(cParam,cIdHlp) } } )
* MemoParse(memoread(cFileName),aCommands)
* RETURN NIL

FUNCTION GetOneEntry(cLine,cIdHlp)
local i
local lShow := .f.
local lFound := .f.
*if "/h" $ cLine
*  cLine := trim(strtran(cLine,"/h"))
*  lShow := .f.
*endif
if "/s" $ cLine
  cLine := trim(strtran(cLine,"/s"))
  lShow := .t.
endif
if cIdHlp != NIL
  for i := 1 to len(saNdx)
    if saNdx[i][1] == cLine
      aadd(saNdx[i][2], cIdHlp)
      lFound := .t.
    endif
  next i
  if ! lFound
    aadd(saNdx, { cLine, { cIdHlp } } )
  endif
endif
if lShow
  RETURN "" + cLine + ""
endif
RETURN NIL

PROCEDURE CallHelp
WinHelp()
RETURN

FUNCTION HlpExist(cIdHlp)
local cFile := scHlpPath + "\" + cIdHlp + ".HLP"
RETURN .t. if file(cFile)
if USRATTR_E $ UsrAttrib()
  RETURN .t. if Confirm(cFile + MsgDosError(),"Create new help item (Y/N) ?")
endif
RETURN .f.

#endif DEF_HELP

FUNCTION FileFirstLine(cFileName)
local fd
local cLine := NIL
local cDllPath := GetDlmPath(cFilename)
if cDllPath == NIL
  RETURN cFileName + MsgFileExist()
endif
if (fd := fopen(cDllPath)) != -1
  cLine := freadline(fd)
  fclose(fd)
  if left(cLine,2) == "//"
    cLine := alltrim(substr(cLine,3))
  endif
  RETURN cLine
endif
RETURN cDllPath + MsgDosError(ferror())

**
** PickNum() - der kleine feine Taschenrechner
**
FUNCTION PickNum(cStart)
local cExpr
local cNewExpr
local nResult
local lExitSave := Set(_SET_EXIT, .t.)
static nRow := NIL
static nCol := NIL
default nRow to int(maxrow() / 2) - 1
default nCol to int(maxcol() / 2) - 22
if cStart == NIL
  cStart := space(LenMont())
elseif ! empty(cStart)
  SendKey(K_END)
endif
cNewExpr := cStart
set key K_ALT_F12 to
* default cStart to scStart
cExpr := cStart
* if nCol < maxcol() / 2
*   nCol += 12
* else
*   nCol -= 34
* endif
* if nRow < maxrow() / 2
*   nRow += 1
* else
*   nRow -= 3
* endif
* if nCol + 46 > maxcol() ; nCol := maxcol() - 46 ; endif
* if nRow + 5 > maxrow() ; nRow := maxrow() - 5 ; endif
* if nCol < 1 ; nCol := 1 ; endif
* if nRow < 1 ; nRow := 1 ; endif
do while cNewExpr != NIL
  open window "Calculator" size 3,44 home nRow,nCol ;
              help CALC legend (MSG_POPCALC_LEGEND)
  cExpr := padr(ltrim(cExpr),128)
  WinHome()
  @ row(), col() get cExpr picture "@K@S40"
  nKey := ReadScr()
  close window
  cExpr := alltrim(cExpr)
  if nKey == K_ENTER
    nResult := xparse(cExpr)
    if nResult == NIL
      SetMsg(cExpr + " : Syntax error.")
      loop
    elseif valtype(nResult) == "N"
      * nResult  := &cExpr
      * nDec := max(nMinDec,MntDecPos(cExpr))
      cNewExpr := ltrim(ntrim(nResult))
      if "." $ cNewExpr
        do while right(cNewExpr,1) == "0"
          cNewExpr := " " + left(cNewExpr,len(cNewExpr)-1)
        enddo
        if right(cNewExpr,1) == "."
          cNewExpr := " " + left(cNewExpr,len(cNewExpr)-1)
        endif
      endif
      if val(cNewExpr) == val(cExpr)
        cNewExpr := padl(cExpr,len(cStart))
        exit
      else
        cExpr := cNewExpr
        SendKey(K_END)
      endif
    elseif valtype(nResult) == "C"
      cExpr := nResult
      SendKey(K_END)
      loop
    endif
  elseif nKey == K_DOWN .or. nKey == K_ALT_DOWN
    if nRow < maxrow()-6
      nRow++
    else
      nRow := 1
    endif
  elseif nKey == K_UP .or. nKey == K_ALT_UP
    if nRow > 1
      nRow--
    else
      nRow := maxrow()-6
    endif
  elseif nKey == K_ALT_RIGHT
    if nCol < maxcol()-45
      nCol++
    else
      nCol := 1
    endif
  elseif nKey == K_ALT_LEFT
    if nCol > 1
      nCol--
    else
      nCol := maxcol()-45
    endif
  elseif nKey == K_F10
    exit
  elseif nKey == K_ESC
    cNewExpr := NIL
  else
    Alarm()
  endif
enddo
set key K_ALT_F12 to PopAdder
Set(_SET_EXIT,lExitSave)
RETURN cNewExpr

FUNCTION WinIsOpen(cIdHlp)
local i
for i := 1 to len(saWinList)
  RETURN .t. if saWinList[i][WS_HELP] == cIdHlp
next i
RETURN .f.

#ifdef DEF_HELP
  FUNCTION MsgHelp ; RETURN "[Alt-F1] = Hilfe"
#else
  FUNCTION MsgHelp ; RETURN NIL
#endif

**
** FileEdit()
**
FUNCTION FileEdit(cFileName,cHelp,lEdit)
local nCursor := setcursor(SC_NORMAL)
local i
local cDllPath := GetDlmPath(cFilename)
if cDllPath == NIL
  RETURN ! SetMsg(cFileName+MsgFileExist())
  // RETURN NIL
endif
default lEdit to .t.
open window (cDllPath) ;
            size maxrow()-5,maxcol() ;
            help (cHelp)
  TxtEdit( ;
    {|x| FileGetSet(cDllPath,x) }, ;
    WinTop(), WinLeft(), WinEndY(), WinEndX(), ;
    lEdit, 250, NIL ;
  )
close window
setcursor(nCursor)
RETURN .t.


FUNCTION WinCls
local win := atail(saWinList)
scroll( win[WS_HOMEY], win[WS_HOMEX], win[WS_BOTTOM]-2, win[WS_RIGHT] )
RETURN NIL


FUNCTION SetWinTitle(cTitle)
local win := atail(saWinList)
if empty(win[WS_BOX])
  @ win[WS_HOMEY]-1, win[WS_HOMEX] say padc( cTitle, win[WS_WIDTH] ) ;
                                 color (CfgLegendColor())
else
  @ win[WS_TOP], win[WS_LEFT]+1  ;
    say padc( ;
      " " + cTitle + " ", ;
      win[WS_RIGHT]-win[WS_LEFT]-3, ;
      substr(win[WS_BOX],2,1) ;
    )
endif
RETURN NIL

FUNCTION WinStack
RETURN saWinList



