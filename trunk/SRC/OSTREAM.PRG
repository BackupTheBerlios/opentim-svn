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

#define LOOP_NAME 1
#define LOOP_EXPR 2
#define LOOP_TEXT 3
* #define LOOP_SAVED_WRITER 4
#define LOOP_ALEN 3

#define CMD_ID 1
#define CMD_BLOCK 2
#define CMD_ALEN 2

static saCmd := {}
static saOsStack := {}

static slActivePps := .f.
static slSecureRebuild := .f.
static slQuickRebuild := .f.
static slAsMail := .f.
static slBatch := .f.
static slPause := .f. // pause after AppShell()
static slAsPdf := .f.
static sbInputFilter := {|x|x}

#define MAX_MEMOLEN 64000


#include "LIB.CH"

#ifdef DEF_PRINT

#ifdef LG_FRENCH
  #define WIN_001 "Imprimer"
  #define TXT_001 "[Escape] pour interrompre l'impression"
  #define TXT_002 "ORN"
  #define MSG_001 "Tapez O pour imprimer page "
  #define MSG_002 "R pour toutes les pages restantes, N pour terminer :"
  #define MSG_003 " pages"
  #define MSG_004 "Impression interrompue apräs "
  #define MSG_005 "Le document prÇvisualisÇ a ÇtÇ imprimÇ. "
  #define MSG_006 "Impression terminÇe jusque page "
  #define MSG_007 "Erreur d'imprimante."
  #define MSG_011  "Tapez O pour continuer."
  static MSG_PREVIEW := "PrÇvisualisation"
  #define MSG013 "Pas de paramätres disponibles."
  #define MSG014 "Paramätres d'imprimante "
  #define MSG015 " F10 Imprimer ≥ ESC Quitter ≥ , , End, Home ≥"
  * #define MSG017 "Options d'impression"
  * #define MSG018 " PrÇvisualisation"
  static MSG019 := " ont ÇtÇ imprimÇes"
  static MSG020 := " Ö imprimer"
  #define MSG021 "Imprimer depuis page "
  #define MSG022 " jusque "
  #define MSG023 "Abandon : erreur de lecture "
  * #define MSG024 " page(s) Ö imprimer"
  #define MSG025 " [F8] Modifier paramätres ≥ [F10] Imprimer ≥ [Escape] Abandon"
  #define MSG026 " [F2] Enregistrer standard ≥ [F10] Continuer ≥ [Escape] Abandon"
  #define MSG027 " Alimentation manuelle    Pied de page "
  #define MSG028 " Saut de page final     "
  #define MSG029 " sans caractäres de contrìle"
  #define MSG030 "Papier :  Hauteur "
  #define MSG031 " lignes  -  Largeur "
  *#define MSG032 " pouces"
  *#define MSG033 "Marges :    Haut : "
  #define MSG034 " lignes -  Gauche : "
  #define MSG035 " caractäres"
  #define MSG036 "             Bas : "
  #define MSG037 " lignes -  Droite : "
  #define MSG038 " caractäres"
  #define MSG039 "Modäle d'imprimante  "
  #define MSG040 "Police               "
  #define MSG041 "Port "
  #define MSG042 "Port d'imprimante"
  #define MSG043 " (redirigÇ dans fichier "
  #define MSG044 "Enregistrer paramätres dans "
  #define MSG045 "Imprimer le fichier prÇvisualisÇ"
  #define MSG046 "Nombre d'exemplaires "
  #define MSG047 "Impression en cours, copie "
  #define MSG048 " : ce fichier n'existe pas."
  #define MSG049 "Options d'imprimante "
  static scDateFormat := "dd/mm/yy"
  static WIN_PRINT := "Imprimer"
  #define MSG_NOTREADY "L'imprimante n'est pas pràte."
  #define MSG_RETRY "O pour rÇessayer : "
#endif

#ifdef LG_GERMAN
  #define WIN_001  "Drucken"
  #define TXT_001  "[Escape] um den Druckvorgang abzubrechen"
  #define TXT_002  "JAN"
  #define MSG_001  "J, um Seite "
  #define MSG_002  " zu drucken, A fÅr alle Seiten, N um abzubrechen :"
  #define MSG_003  " Seiten"
  #define MSG_004  "Druckvorgang wurde unterbrochen nach "
  #define MSG_005  "Druckvorschau wurde gedruckt auf "
  #define MSG_006  "Druckvorgang beendet bis Seite "
  #define MSG_007  "Druckerfehler."
  #define MSG_011  "J um weiterzugehen."
  static MSG_PREVIEW  := "Druckvorschau"
  #define MSG013 "Keine DruckparametersÑtze vorhanden !"
  #define MSG014 "Druckparametersatz "
  #define MSG015 " F10 Drucken ≥ ESC Beenden ≥ , , End, Home ≥"
  * #define MSG017 "Druck-Optionen"
  * #define MSG018 "Druckvorschau"
  static MSG019 := " wurden gedruckt"
  static MSG020 := " zu drucken"
  #define MSG021 "Umfang : von Seite "
  #define MSG022 " bis "
  #define MSG023 "Abbruch : Lesefehler "
  * #define MSG024 " Seite(n) zu drucken"
  #define MSG025 " [F8] Parameter Ñndern ≥ [F10] Druck starten ≥ [Escape] Abbrechen"
  #define MSG026 " [F10] Weiter ≥ [F2] Standard speichern ≥ [Escape] Abbrechen"
  #define MSG027 " neue Seite bestÑtigen    Fu·zeilenart "
  #define MSG028 " Seitensprung nachher   "
  #define MSG029 " Steuerzeichen unterdrÅcken "
  #define MSG030 "Papier :  Hîhe "
  #define MSG031 " Zeilen  -  Breite  "
  *#define MSG032 " Zoll  "
  *#define MSG033 "RÑnder :  Oben : "
  #define MSG034 " Zeilen   -  Links  : "
  #define MSG035 " Zeichen   "
  #define MSG036 "         Unten : "
  #define MSG037 " Zeilen   -  Rechts : "
  #define MSG038 " Zeichen"
  #define MSG039 "Druckertreiber     "
  #define MSG040 "Schriftart         "
  #define MSG041 "Anschlu· "
  #define MSG042 "Druckeranschlu·"
  #define MSG043 " Umleiten in Datei "
  * #define MSG044 "Druckparameter speichern in "
  #define MSG045 "Druckvorschau drucken"
  #define MSG046 "Anzahl Kopien "
  #define MSG047 "Ausdrucken der Druckvorschau, Kopie "
  #define MSG048 " : Datei nicht vorhanden."
  #define MSG049 "Sonder-Optionen    "
  static scDateFormat := "dd.mm.yy"
  static WIN_PRINT := "Drucken"
  #define MSG_NOTREADY "Der Drucker ist nicht betriebsbereit."
  #define MSG_RETRY "J um neu zu versuchen : "
#endif

#ifdef LG_EN
  * #define WIN_001  "Drucken"
  * #define TXT_001  "[Escape] um den Druckvorgang abzubrechen"
  *#define TXT_002  "JAN"
  * #define MSG_001  "J, um Seite "
  * #define MSG_002  " zu drucken, A fÅr alle Seiten, N um abzubrechen :"
  #define MSG_003  " pages"
  #define MSG_004  "Print job has been aborted after "
  * #define MSG_005  "Druckvorschau wurde gedruckt auf "
  * #define MSG_006  "Druckvorgang beendet bis Seite "
  * #define MSG_007  "Druckerfehler."
  * #define MSG_011  "J um weiterzugehen."
  static MSG_PREVIEW  := "Print preview"
  *#define MSG013 "Keine DruckparametersÑtze vorhanden !"
  * #define MSG014 "Druckparametersatz "
  *#define MSG015 " F10 Drucken ≥ ESC Beenden ≥ , , End, Home ≥"
  * #define MSG017 "Druck-Optionen"
  * #define MSG018 "Druckvorschau"
  static MSG019 := " have been printed"
  static MSG020 := " to print"
  #define MSG045 "really print"
  #define MSG046 "copies "
  #define MSG047 "Printing, copy "
  static scDateFormat := "dd.mm.yy"
  static WIN_PRINT := "Print"
  #define MSG_NOTREADY "Printer is not ready"
  * #define MSG_RETRY "J um neu zu versuchen : "
#endif

**
** STATIC_SECTION global static variables
**

static MSG_NIL_OR_CHAR := " : return type must be CHAR, NIL or LOGICAL!"
static scSource := NIL
static snSrcLine := 0

static scTagBegin := "{"
static scTagEnd := "}"
* static slRtfMode := .f.
static slIsLastPage
* static slTrap := .f.

* static scRange  := NIL
static scTplIni := NIL
static sbWriter := {|x|NilWriter(x) }

static scWarnStr := ""

#define PAGEALIGN_LEFT  "L"
#define PAGEALIGN_RIGHT "R"


** interne Variablen, die z.B. in InitPrint() gesetzt werden
**
static snCurPage := 0  // current physical page number
static snLogPage := 0  // current logical page number
static snVPos := 0     // current vertical position (points) <- LstL
static scPageAlign := PAGEALIGN_LEFT
static snApsWidth := 76
static slKeepBlock := .f.
static saKeepLines := {}
* static slFooterActive := .f.
static scPrnBuffer := "" // printer stream buffer
static snPrnStatus := PRN_IDLE
static saPreBuffer   // one entry for each page
static scTime
static snRow := 0
static snCol := 0


**
** Variablen zum Wiederherstellen verschiedener Einstellungen nach dem
** Drucken
static scMntFormat := NIL
static scSetSolde  := NIL
static sSaveDateFormat := NIL
static scLangue  := UsrLang()

** Variablen, die vom aufrufenden Programmcode gesetzt werden
**
static sbPageFooter   := NIL
static sbPageHeader   := NIL
static saHeader   := NIL
* 20021111 static scHeader  := NIL
static sbHeader   := NIL
static sbFooter := NIL
static slNoFirst := .f. // no header on first page
static slNoLast := .f.  // no footer on last page
static snLMargin := 1    // inches
static snRMargin := 1    // inches
static snTMargin := 0    // inches (bis 30.1.96 : Zeilen)
static snBMargin := 1    // inches
static snPapHeight  := 11.69   // inches paper height
static scDrvSpecial := ""
static snPapWidth   := 8.27   // inches paper width
static scPort    := "PRN"     // printer port
static slFinalFF   := .t.
static scExport    := NIL
* static slManual    := .f.
* static slActive    := .t.
static snMaxVpos := 0
static snCopies

static snColCount  := 0
static scColSep    := " "
static saColBuffer := NIL
static saColStack  := {}

* static xCmdSpooler := NIL
static saCmdSpooler := {}

** Variablen, die im Dialogfenster DRUCKEN vom Benutzer manuell
** verÑndert werden kînnen. Die Voreinstellungen fÅr diese Variablen
** werden Åber {set}-Befehle in der SET-Maske gesetzt. Wenn nicht, dann
** gelten die folgenden Voreinstellungen, und dann bleiben diese von
** einem Printjob zum nÑchsten unverÑndert.
static sbPrePrint  := NIL
static scDoPreview := BUTTON_ON
static scDoCapture := BUTTON_OFF
static scPrnFile   := ""    // redirect output to file
static snPrintFrom := 0
static snPrintUntil := 0

static soLoop := NIL
* static saLoopStack := {}
static slPStream := .t.
static saIfStack := {.t.}
static scFrame   := ""
static snLIndent := 0
static snRIndent := 0
static scAlign := ALIGN_LEFT
static scPreviewFile

static sxcCapture := NIL

FUNCTION p_dbi()
saCmd := {}
RETURN .t.

FUNCTION SetCapture(xcCapture)
sxcCapture := xcCapture
RETURN .t.

FUNCTION ChkMemoLen(cMemo)
if len(cMemo) > MAX_MEMOLEN
  Warning("MAX_MEMOLEN overflow !",;
  "(please report this message to PAC Systems)")
  RETURN .f.
endif
RETURN .t.


FUNCTION SetActivePps(x)
RETURN slActivePps if x == NIL
slActivePps := x
RETURN .t.

FUNCTION SetSecureRebuild(x)
RETURN slSecureRebuild if x == NIL
slSecureRebuild := x
RETURN .t.

FUNCTION SetQuickRebuild(x)
RETURN slQuickRebuild if x == NIL
slQuickRebuild := x
RETURN .t.

**
** OpenPrinter()
**
FUNCTION OpenPrinter( ;
  cIdTplIni, ;
  cPreview, ;
  nWidth,;
  bPageHeader,;
  cRange, ;
  bPrePrint, ;
  cIdDlg, ;
  lDlg, ;
  lAsPdf, ;
  lAsMail ;
)
local cMsg := ""
if snPrnStatus == PRN_CONTINUE
  RETURN !SetMsg("Cannot open 2 printer streams at once")
endif
default lAsPdf to .f.
default lAsMail to .f.
snPrnStatus := PRN_IDLE // sonst arbeitet StrParse() manchmal nicht
                        // wÑhrend DlgExec() [20000323]
SetTplIni(cIdTplIni)
// 20060816
// default cRange to ""
if cRange != NIL
  SetRange(cRange)
endif
slAsPdf := lAsPdf
slAsMail := lAsMail
if empty(cIdDlg)
  if cPreview == NIL
    SetPreview(if(USRATTR_P $ UsrAttrib(), BUTTON_ON, BUTTON_OFF))
    if ! USRATTR_O $ UsrAttrib()
      open window (WIN_PRINT) size 5,50 help PRINT
      GetPreview()
      WinCr()
      GetRange()
      GetTplIni()
      nKey := ReadScr()
      close window
      RETURN .f. if nKey == K_ESC
    endif
  else
    scDoPreview := cPreview
    * default cRange to ""
    * GsbRange(cRange)
  endif
else
  if ! DlgExec(cIdDlg,NIL,NIL,NIL,NIL,lDlg)
    snPrnStatus := PRN_ABORT
    RETURN .f.
  endif
endif
saCmdSpooler := {}
* slRtfMode := .f.
* 20021111 scHeader := NIL
scPort    := "PRN"     // printer port
scDrvSpecial := ""
slPStream := .t.

soLoop := NIL
saIfStack := {.t.}
scPreviewFile := NIL
if ! AppIsInstalled()
  scDoPreview := BUTTON_ON
endif
if bPrePrint == NIL
  sbPrePrint := {||.t.}
else
  sbPrePrint := bPrePrint
endif
if scDoPreview == BUTTON_OFF
  if ! eval(sbPrePrint)
    scDoPreview := BUTTON_ON
  endif
endif
scDoCapture := BUTTON_OFF
scMntFormat := SetMntFormat()
scSetSolde  := SetSolde()
sSaveDateFormat  := SetDateFormat()
snCopies    := NIL
* snPrnStatus := PRN_CONTINUE
sbPageHeader := bPageHeader
sbPageFooter := NIL
if ! PpsExec(scTplIni)
  Warning(SetMsg())
  snPrnStatus := PRN_ABORT
endif
// 20030109 ab hier war *vor* AusfÅhrung des PPS
BeginOStream({|x| PrnStream(x)},NIL,"Printer") 
// 20030109 bis hier war *vor* AusfÅhrung des PPS
if nWidth != NIL
  p_SetWidth(nWidth)
endif
saPreBuffer := {}  // see PrnStream()
scPrnBuffer := ""  // see PrnStream()
snCurPage := 0     // current page number. 
                   // value 0 as long as no page has been printed
snLogPage := 0                   
snVPos    := 0     // current vertical position (points)
                   // value 0 as long as nothing has been printed on
                   // current page
scTime := time()
if ! DrvOnSelect()
  EndOStream()
  snPrnStatus := PRN_ABORT
  RETURN .f.
endif
// ! This OPEN WINDOW has its close window only in ClosePrinter():
open window size 7,60 help PRINTING
if scDoPreview == BUTTON_ON
  say MSG_PREVIEW + " : "
else
  say utrp("Print : ", "Drucken : ", "Imprimer : ")
endif
say DrvName()
WinCr()
say "  on " + iif( scDoCapture == BUTTON_OFF, scPort, scPrnFile )
WinCr()
say utrp("[Escape] to interrupt","[Escape] um abzubrechen",;
         "[Escape] pour interrompre")
WinCr()
snRow := row()
snCol := col()
set console off
if scDoPreview == BUTTON_ON ;
  .or. snCopies != NIL ; // 19980724
  .or. len(saCmdSpooler) > 0  // 20000605
  default scPreviewFile to ".\PREVIEW.PRN"
  set printer to (scPreviewFile) // .\PREVIEW.PRN
elseif sxcCapture != NIL
  set printer to (xparse(sxcCapture)) // 2000.01.28
  scDoCapture := BUTTON_OFF
elseif scDoCapture == BUTTON_ON
  set printer to (TmpConvert(scPrnFile))
else
  scPreviewFile := NIL
  if ! isprinter(scPort)
    EndOStream()
    snPrnStatus := PRN_ABORT
    close window
    SetMsg(scPort + " : printer port not ready.")
    RETURN .f.
  endif
  set printer to ( scPort )
endif
set printer on
RETURN .t.

// 20040716 workaround fÅr bei Nols
FUNCTION PrnWakeUp()
set console off
set printer to LPT1
set printer on
PrnOut( DrvReset() )
set printer to
set printer off
set console on
RETURN .t.

FUNCTION PpsExec(cTplIni)
local lOkay 
local bWriter := sbWriter
snLMargin := 1
snRMargin := 1
snTMargin := 0
snBMargin := 1
snPapHeight  := 11.3   // inches paper height
snPapWidth   := 8.27   // inches paper width
sbFooter := NIL
sbHeader := NIL
slNoFirst := .f.
slNoLast := .f.
slFinalFF   := .t.
scExport    := NIL
scPageAlign := PAGEALIGN_LEFT
snLIndent := 0
snRIndent := 0
scAlign   := ALIGN_LEFT
RETURN .t. if empty(cTplIni)
// parameter sets may not produce text. whitespace is allowed but ignored.
sbWriter := {|x|NilWriter(x)} 
if slActivePps 
  lOkay := FileExec(trim(cTplIni)+".PPS") 
else
  lOkay := TplParse( ;
    TplValue(TPLTYPE_INI,cTplIni,{||TplMemo()},""),;
    "INI:"+cTplIni,.f.)
endif    
snMaxVPos := snPapHeight - snBMargin
sbWriter := bWriter 
RETURN lOkay
       


FUNCTION fdostream(fdout,s) // Ñhnlich wie PrnStream
RETURN NIL if ! slPStream
if soLoop != NIL
  soLoop[LOOP_TEXT] += s
  RETURN NIL
endif
fwrite(fdout,TextFormat(s))
RETURN NIL


STATIC FUNCTION PrnStream(cStream)
local nPos
local cLine
RETURN NIL if ! slPStream
// debug  ("PrnStream("+utos(cStream)+")")
if soLoop != NIL
  soLoop[LOOP_TEXT] += cStream
  RETURN NIL
endif
scPrnBuffer += cStream
do while (nPos := at(CR_LF,scPrnBuffer)) != 0
  ** 20000922
  ** Problem CPAS in fprint() mit footer: doppelte Zeile nach
  ** Seitenwechsel. Weil das StÅck vor nPos an PrnSendLine() geschickt
  ** und erst *danach* aus scPrnBuffer entfernt wurde.
  cLine := left(scPrnBuffer,nPos-1)
  scPrnBuffer := substr(scPrnBuffer,nPos + 2)
  PrnSendLine(cLine)
enddo
RETURN NIL

FUNCTION PrnFlush()
if len(scPrnBuffer) != 0
  PrnSendLine(scPrnBuffer)
  scPrnBuffer := ""
endif
RETURN NIL



**
** PrnSendLine()
**
** Jetzt enthÑlt der scPrnBuffer genau eine Textzeile
**
** PrnFlush() leert den PrnBuffer zur aktuellen print destination
** die print destination kann sein "Preview" und/oder "Printer"
** Printer kann wiederum eines der drei sein :
** - ein Druckerport (set printer on,...)
** - eine Datei (set alternate on...)
** - NIL
** MERKE : Nach PrnFlush() ist scPrnBuffer auf jeden Fall *leer* !
**
STATIC FUNCTION PrnSendLine(cLine)
local nPad
// debug Sendconsole("PrnSendLine("+utos(cLine)+")")
// evtl Zeile zentrieren oder rechtsbÅndig setzen
if ALIGN_RIGHT $ scAlign
  nPad := t_cpl() - len(TextUnFormat(cLine))
  cLine := space(nPad) + cLine
elseif ALIGN_CENTER $ scAlign
  nPad := int( (t_cpl() - len(TextUnFormat(cLine))) / 2)
  cLine := space(nPad) + cLine
endif
// evtl. wird die Zeile jetzt vom TabStream abgefangen:
RETURN NIL if TabStream(cLine + CR_LF)
PrintLine( padr(scFrame,snLIndent) + cLine + padr(scFrame,snRIndent) )
RETURN NIL

FUNCTION PrintLine(cLine)
default cLine to ""
// debug SendConsole("PrintLine(" + utos(cLine) + ")")
RETURN .t. if snPrnStatus != PRN_CONTINUE
RETURN .t. if ColStream(cLine)
RETURN .t. if ! PrnPrepare()
if snPrintUntil != 0 .and. snCurPage > snPrintUntil
  snPrnStatus := PRN_DONE
  RETURN .t.
endif
if slKeepBlock
  aadd(saKeepLines,cLine)
else
  snVPos += FntHeight()
  RETURN .t. if snPrintFrom != 0 .and. snCurPage < snPrintFrom
  // 20050322 PreOut(left(cLine,int(FntPitch() * p_LnWidth() + 1)) + CR_LF)
  PreOut(cLine + CR_LF)
  cLine := DrvCvtString(cLine)
  cLine := TextFormat(cLine) // 20021219
  PrnOut(space(int(snLMargin*FntPitch())) + cLine + DrvLineFeed())
endif
RETURN .t.




**
** ClosePrinter()
**
FUNCTION ClosePrinter(lNoWarn)
local cMsg
local cFontName
local nPrnStatus
default lNoWarn to .f.
SetMntFormat(scMntFormat)
SetSolde(scSetSolde)
SetDateFormat(sSaveDateFormat)
if snPrnStatus == PRN_IDLE .and. lNoWarn
  Warning("ClosePrinter() : PRN_IDLE")
  RETURN NIL
endif
PrnFlush()
p_Eject(.t.)
PrnOut( DrvReset() )
*
set printer to
set printer off
set console on
close window // this close window is for the OpenWin() in OpenPrinter() !
** [etc exit] wird nach einem vorherigen [etc do fparse()] benutzt,
** um einen Druckjob ohne weitere Meldung zu beenden.
cFontName := FntName()
nPrnStatus := snPrnStatus // save status at end of stream
EndOStream()
if nPrnStatus == PRN_CONTINUE .or. nPrnStatus == PRN_DONE // normal end
  snPrnStatus := PRN_DONE
  RETURN NIL if snCurPage == 0 // nothing has been printed
  cMsg := ntrim(snCurPage) + MSG_003
  if scPreviewFile != NIL // 20000605
    cMsg += MSG020 // " zu drucken"
  else
    cMsg += MSG019 // " wurden gedruckt"
  endif
  cMsg += " on " + DrvName()
  cMsg += ", " + if( scDoCapture == BUTTON_OFF, scPort, scPrnFile )
  SetMsg(cMsg)
  // SendConsole(cMsg)
elseif nPrnStatus == PRN_ABORT
  snPrnStatus := PRN_ABORT
  if empty(SetMsg())
    SetMsg(MSG_004 + ntrim(snCurPage) + MSG_003)
  else
    Warning(SetMsg())
    RETURN NIL
  endif
endif
if scDoPreview == BUTTON_ON
  RETURN .f. if ! ShowPreview(cFontName)
endif
if scPreviewFile != NIL
  RETURN .f. if ! PrintPreview()
endif
DrvOnSuccess()
RETURN NIL



* #define SCROLL_LINES 15
#define SCROLL_COLS  60

**
** ... display saPreBuffer
**
STATIC FUNCTION ShowPreview(cFntName)
local nCurPage := 1
local nCurLine := 0
local nCurCol := 1
local nWidth := 250 // int(FntPitch() * p_LnWidth()) // snApsWidth
local SCROLL_LINES := maxrow() - 9
local nMaxLine := mlcount(saPreBuffer[1],nWidth) - SCROLL_LINES
local i
local lOkay := .f.
open window (MSG_PREVIEW + " [" + cFntName + "]") ;
     size maxrow()-4,maxcol()+1 ;
     help PREVIEW
do while .t.
  WinDisp2( ;
    " Pg " + ntrim(nCurPage) + "/" + ntrim(len(saPreBuffer)) ;
    + " Ln " + ntrim(nCurLine) + " " ;
  )
  if nextkey() == 0
    MemoDisplay( ;
      saPreBuffer[nCurPage], ;
      3,2,maxrow()-6,maxcol()-3, ;
      NIL, nCurLine, nWidth, nCurCol ;
    )
  endif
  nKey := WaitKeySet()
  if nKey == K_PGDN
    if nCurLine < nMaxLine
      nCurLine += SCROLL_LINES
      if nCurLine > nMaxLine
        nCurLine := nMaxLine
      endif
    elseif nCurPage < len(saPreBuffer)
      nCurPage++
      nMaxLine := mlcount(saPreBuffer[nCurPage],nWidth) - SCROLL_LINES
      nCurLine := 0
    endif
  elseif nKey == K_CTRL_PGUP
      nCurPage := 1
      nMaxLine := mlcount(saPreBuffer[nCurPage],nWidth) - SCROLL_LINES
      nCurLine := 0
  elseif nKey == K_CTRL_PGDN
      nCurPage := len(saPreBuffer)
      nMaxLine := mlcount(saPreBuffer[nCurPage],nWidth) - SCROLL_LINES
      nCurLine := nMaxLine
  elseif nKey == K_PGUP
    if nCurLine > 0
      nCurLine -= SCROLL_LINES
      if nCurLine < 0
        nCurLine := 0
      endif
    elseif nCurPage > 1
      nCurPage--
      nMaxLine := mlcount(saPreBuffer[nCurPage],nWidth) - SCROLL_LINES
      nCurLine := nMaxLine
    endif
  elseif nKey == K_DOWN
    if nCurLine < nMaxLine
      nCurLine++
    elseif nCurPage < len(saPreBuffer)
      nCurPage++
      nMaxLine := mlcount(saPreBuffer[nCurPage],nWidth) - SCROLL_LINES
      nCurLine := 0
    endif
  elseif nKey == K_UP
    if nCurLine > 0
      nCurLine--
    elseif nCurPage > 1
      nCurPage--
      nMaxLine := mlcount(saPreBuffer[nCurPage],nWidth) - SCROLL_LINES
      nCurLine := nMaxLine
    endif
  elseif nKey == K_RIGHT
    if nCurCol + SCROLL_COLS < nWidth
      nCurCol++
    endif
  elseif nKey == K_LEFT
    if nCurCol > 1
      nCurCol--
    endif
  elseif nKey == K_END
    * nCurCol := nWidth - SCROLL_COLS
    nCurCol := snApsWidth - SCROLL_COLS
  elseif nKey == K_HOME
    nCurCol := 0
  elseif nKey == K_ESC
    snPrnStatus := PRN_ABORT
    SetMsg(utr("User aborted","Abbruch durch Benutzer",;
      "Interrompu par l'utilisateur"))
    exit
  * elseif nKey == K_ALT_M
    * DlgExec("ASMAIL")
    * OpenMail(getvar("mailto"),NIL,SetDlgTitle(),p_PreBuffer())
  elseif nKey == K_F3
    FileEdit(scPreviewFile)
    if lastKey() == K_F10
      lOkay := .t.
      exit
    endif
  elseif nKey == K_F10
    lOkay := .t.
    exit
  endif
enddo
close window
RETURN lOkay

FUNCTION p_PreBuffer()
local c := ""
ascan(saPreBuffer,{|x|c+=x})
RETURN c



**
** 
**
FUNCTION PrintPreview()
local i := 1
local cMsg
local e
local cFile := scPrnFile
local lBreak := SetBreakTrap()
local lOkay := .t.
RETURN .f. if ! eval(sbPrePrint)
if snCopies == NIL
  snCopies := 1
  open window (MSG045) size 3,40 help PRINTPRV
  say MSG046
  @ row(), col() get snCopies picture "###"
  nKey := ReadScr()
  close window
  RETURN .f. if nKey == K_ESC
endif
if len(saCmdSpooler) > 0
  do while i <= snCopies
    if DoEvents(saCmdSpooler)
      i += 1
    elseif ! Confirm(SetMsg(),MsgRetry())
      snPrnStatus := PRN_ABORT
      lOkay := .f.
      i := snCopies + 1
      exit
    endif
  enddo
else
  SetBreakTrap(.t.)
    do while i <= snCopies
      begin sequence
        if scDoCapture == BUTTON_ON
          cFile := TmpConvert(scPrnFile)
          MsgDisplay(MSG047 + ntrim(i) + " ("+cFile+")")
          copy file (scPreviewFile) to ( cFile )
        else
          MsgDisplay(MSG047 + ntrim(i) + " ("+scPort+")")
          copy file (scPreviewFile) to (scPort)
          // 19990913 : hier bei diesem copy wird TIM bei Irene Dericum
          // (CPAS) manchmal abgeknallt (mit der Behauptung, er hÑtte was
          // illegales gemacht). An einem anderen Rechner mit der gleichen
          // Konfiguration und Windows-Version kommt der Fehler nie.
        endif
        i++
      recover using e
        if ! Confirm(MSG_NOTREADY,MsgRetry())
          lOkay := .f.
          snPrnStatus := PRN_ABORT
          // c += " -> " + ErrorMessage(e)
          i := snCopies + 1
        endif
      end sequence
    enddo
  SetBreakTrap(lBreak)
endif
RETURN .f. if ! lOkay
cMsg := ""
if snCopies != 1
  cMsg += ntrim(snCopies) + " x "
endif
cMsg += ntrim(snCurPage) + MSG_003
cMsg += utrp(" have been printed on "," wurden gedruckt auf "," ont ÇtÇ imprimÇes sur ")
cMsg += DrvName()
cMsg += ", " + if( scDoCapture == BUTTON_OFF, scPort, cFile )
SetMsg(cMsg)
// SendConsole(cMsg)
RETURN .t.




** Beispiel :
** SetSpooler('AppShell("excel preview.prn","Excel wird gestartet")')
**
FUNCTION SetSpooler(x)
RETURN saCmdSpooler if x == NIL
if valtype(x) == "C"
  x := cblock(x)
endif
saCmdSpooler := {x}
RETURN .t.



FUNCTION AddSpooler(x)
if valtype(x) == "C"
  x := cblock(x)
endif
aadd(saCmdSpooler,x)
RETURN .t.


FUNCTION SetPrnFile(x)
RETURN scPreviewFile if x == NIL
default snCopies to 1
scPreviewFile := x
RETURN .t.




**
**
**
STATIC FUNCTION p_PageBegin
local cAnswer
local i, b
local aStatus
local lKeepBlock := slKeepBlock
RETURN NIL if snPrnStatus  != PRN_CONTINUE
RETURN NIL if snPapHeight == 0 .and. snCurPage != 0 // continuous form
snCurPage += 1
snLogPage += 1
if snPrintUntil != 0 .and. snCurPage > snPrintUntil
  snPrnStatus := PRN_DONE
  RETURN NIL
endif
// debug SendConsole("p_PageBegin() " + ntrim(snCurPage))
snVPos := FntHeight()
@ snRow + 1, snCol say MsgSeite(UsrLang()) + " " + ntrim(snCurPage)
say " [" + FntName() + "]"
if snPrintFrom == 0 .or. snCurPage >= snPrintFrom
  if scDoPreview == BUTTON_ON .or. SetAsMail()
    aadd(saPreBuffer,"")
  endif
endif
// 20000117 bug
if snPrintFrom == 0 .or. snCurPage >= snPrintFrom
  // debug SendConsole("p_PageBegin() "+ ntrim(snCurPage) + " calls DrvJobBegin()")
  DrvJobBegin()
  PrnOut( DrvInit()+DrvSpecial(scDrvSpecial)+FntCtrl() )
  if snPapHeight != 0
    PrnOut(DrvPapHeight(snPapHeight))
  endif
endif
slKeepBlock := .f.
if sbPageHeader != NIL
  aStatus := SaveStatus()
  snTMargin := 0
  scPrnBuffer := ""
  scAlign := ALIGN_LEFT
  // debug SendConsole("p_PageBegin() "+ ntrim(snCurPage) + " executes sbPageHeader")
  eval(sbPageHeader)
  PrnFlush()
  RestoreStatus(aStatus)
endif
if sbHeader != NIL
  if snLogPage > 1 .or. ! slNoFirst
    aStatus := SaveStatus()
    snTMargin := 0
    scPrnBuffer := ""
    scAlign := ALIGN_LEFT
    b := sbHeader
    sbHeader := NIL
    // debug SendConsole("p_PageBegin() "+ ntrim(snCurPage) + " executes sbHeader")
    eval(b) // execute header template
    PrnFlush()
    RestoreStatus(aStatus)
  endif
endif
// debug SendConsole("p_PageBegin() "+ ntrim(snCurPage) + " skip to first line after header")
do while snVPos < snTMargin .and. snPrnStatus == PRN_CONTINUE
  PrintLine()
enddo
slKeepBlock := lKeepBlock
RETURN NIL

** SaveStatus() - save current state vars
FUNCTION SaveStatus()
local a := {}
aadd(a, snTMargin    )
aadd(a, snBMargin    )
aadd(a, scAlign      )
aadd(a, scPrnBuffer  )
aadd(a, FntCtrl()    )
aadd(a, FntName()    )
aadd(a, snApsWidth   )
aadd(a, snMaxVPos    )
aadd(a, sbHeader     )
RETURN a

** restore state vars
FUNCTION RestoreStatus(a)
snTMargin   := a[1]
snBMargin   := a[2]
scAlign     := a[3]
scPrnBuffer := a[4]
PrnOut(a[5]) // FntCtrl()
FntActivate(a[6]) // FntName()
snApsWidth  := a[7]
snMaxVPos   := a[8]
sbHeader    := a[9]
RETURN NIL

FUNCTION p_MsgDisplay(cMsg)
@ snRow, snCol say padr(cMsg,56)
RETURN NIL


FUNCTION SetPageHeader(bPageHeader)
RETURN sbPageHeader if bPageHeader == NIL
sbPageHeader := bPageHeader
RETURN .t.

FUNCTION SetPageFooter(bPageFooter)
RETURN sbPageFooter if bPageFooter == NIL
sbPageFooter := bPageFooter
RETURN .t.


**
** p_Eject() - ejects current page
**             but only if something has been printed
**
FUNCTION p_Eject(lFinal)
local aStatus
RETURN NIL if snPrnStatus != PRN_CONTINUE
RETURN NIL if snVPos == 0 .and. snCurPage == 0 // nothing has been printed
**
if snPrintFrom != 0 .and. snCurPage < snPrintFrom
  snVPos := 0
  RETURN NIL // virtual pages being printed
endif
if snColCount != 0
  // Falls in der Maske kein abschlie·endes {set columns off} steht
  do while len(saColBuffer) != 0 .and. snPrnStatus == PRN_CONTINUE
    ColFlush()
  enddo
endif
default lFinal to .f.
if (sbFooter != NIL .or. sbPageFooter != NIL) .and. !(lFinal .and. slNoLast)
  if snPapHeight != 0
    do while snVPos < snMaxVPos
      PrintLine()
    enddo
  endif
  aStatus := SaveStatus()
  snMaxVPos := 0  // slFooterActive
  slIsLastPage := lFinal
  * 20021111
  if sbPageFooter != NIL
    eval(sbPageFooter)
  endif
  if sbFooter != NIL
    eval(sbFooter)
  endif
  slIsLastPage := .f.
  PrnFlush()
  RestoreStatus(aStatus)
endif
snVPos := 0
/*
  19990329 : Bei AMG steht ein {=p_eject()} unmittelbar nach {ven
  memo_ifc}, und die IFC-Texte mÅssen ohne CR_LF am Ende sein. Beim
  Ausdrucken einer Attestation 6% bei einer Rechnung mit IdMfc "C" kam
  die letzte Zeile "pour acquit ....(signature)" noch mit auf die
  attestation, weil hier kein PrnFlush() gemacht wurde.
*/
if lFinal
  PrnFlush()
endif
**
if slFinalFF .or. ! lFinal
  PrnOut( DrvFormFeed() )
  PreOut( CR_LF + repl("Õ",int(FntPitch()*p_LnWidth())) + CR_LF )
endif
RETURN NIL

FUNCTION IsLastPage()
RETURN  slIsLastPage


**
** TextFormat()
**
FUNCTION TextFormat(cText)
cText := strtran(cText,scTagBegin+"B"+scTagEnd,DrvBon() )
cText := strtran(cText,scTagBegin+"b"+scTagEnd,DrvBoff())
cText := strtran(cText,scTagBegin+"S"+scTagEnd,DrvSon() )
cText := strtran(cText,scTagBegin+"s"+scTagEnd,DrvSoff())
cText := strtran(cText,scTagBegin+"U"+scTagEnd,DrvUon() )
cText := strtran(cText,scTagBegin+"u"+scTagEnd,DrvUoff())
cText := strtran(cText,scTagBegin+"I"+scTagEnd,DrvIon() )
cText := strtran(cText,scTagBegin+"i"+scTagEnd,DrvIoff())
RETURN cText

**
** TextUnFormat()
**
FUNCTION TextUnFormat(cText)
cText := strtran(cText,scTagBegin+"B"+scTagEnd)
cText := strtran(cText,scTagBegin+"b"+scTagEnd)
cText := strtran(cText,scTagBegin+"U"+scTagEnd)
cText := strtran(cText,scTagBegin+"u"+scTagEnd)
cText := strtran(cText,scTagBegin+"S"+scTagEnd)
cText := strtran(cText,scTagBegin+"s"+scTagEnd)
cText := strtran(cText,scTagBegin+"I"+scTagEnd)
cText := strtran(cText,scTagBegin+"i"+scTagEnd)
RETURN cText


STATIC FUNCTION PrnOut(cText)
** RETURN NIL if print destination == NIL
// debug SendConsole("PrnOut() " + utos(cText))
begin sequence
  ?? cText
  * 20021219 ?? TextFormat(cText)
recover
  snPrnStatus := PRN_ABORT
end sequence
RETURN NIL



STATIC FUNCTION PreOut(c)
local nLen := len(saPreBuffer)
RETURN NIL if nLen == 0
saPreBuffer[nLen] += TextUnformat(c)
RETURN NIL


**
** "Angesichts der Tatsache, dass die nÑchste Textzeile auf ihren Ausdruck
** wartet, veranlasse alles Nîtige"
** returns : "kann die nÑchste Zeile gedruckt werden ?"
**
FUNCTION PrnPrepare
if snMaxVPos > 0
  if snVPos > snMaxVPos // .and. ! slFooterActive
    p_Eject(.f.) // (setzt u.a. snVPos auf 0)
    RETURN .f. if snPrnStatus != PRN_CONTINUE
  endif
endif
if snVPos == 0
  p_PageBegin()
  RETURN .f. if snPrnStatus != PRN_CONTINUE
endif
RETURN .t.

**
** Hier kommt eine Zeile auf einmal an, die auch ausgedruckt werden soll
** Aber vielleicht wird sie auch im saColBuffer aufbewahrt, weil es
** mehrere Kolonnen gibt.
**
FUNCTION ColStream(cLine)
RETURN .f. if snColCount == 0
aadd(saColBuffer,padr(cLine,p_cpl()))
if snPapHeight != 0 .and. len(saColBuffer) >= p_LinesLeft() * snColCount
  ColFlush()
endif
RETURN .t.

**
** ColFlush() - Spaltenausgleich ...und dann ab durch den PrnStream
**
FUNCTION ColFlush
local i,j
local nLines
local n := 0
local cLine
local nColCount := snColCount
local aHeader := {}
* RETURN NIL if snColCount == 0
#ifdef DEF_TABLE
  aHeader := TabHeader()
#endif
snColCount := 0 // das wird jetzt abgeschaltet, damit PrintLine() auch
                // ungestîrt ausdruckt
if ! PrnPrepare()
  snColCount := nColcount
  RETURN NIL
endif
* do while len(saColBuffer) != 0 .and. snPrnStatus == PRN_CONTINUE
  **
  ** zuerst mal Åberlegen, wieviele Zeilen Åberhaupt auf die aktuelle
  ** Seite passen. Falls nicht genug Platz da ist, wird saColBuffer
  ** nÑmlich virtuell unterteilt.
  **
  nLines := int((len(saColBuffer)-1) / nColCount) + 1
  if snPapHeight != 0
    if nLines + len(aHeader) > p_LinesLeft()
      nLines := int(p_LinesLeft() - len(aHeader))
    endif
    if nLines < FntHeight()
      p_Eject(.f.) // 19990329
      snColCount := nColcount
      RETURN NIL   // das wird ein endless loop, wenn header so gro· ist, da· er
                   // selbst auf eine leere Seite gar nicht drauf passt...
    endif
  endif
  for i := 1 to len(aHeader)
    cLine := ""
    for j := 1 to nColCount
      cLine += aHeader[i]
      if j < nColCount
        cLine += scColSep
      endif
    next j
    PrintLine(cLine)
  next j
  for i := 1 to nLines
    cLine := ""
    for j := 1 to nColCount
      ** auf der i-ten Zeile in der j-ten Kolonne muss das n-te Element
      ** gedruckt werden...!
      n := i + ((j - 1) * nLines)
      if n <= len(saColBuffer)
        cLine += saColBuffer[n]
        if j < nColCount
          cLine += scColSep
        endif
      endif
    next j
    PrintLine(cLine)
  next i
  ** und jetzt wird der Buffer endlich geleert
  n := min(nLines * nColCount,len(saColBuffer))
  for i := 1 to n
    adel(saColBuffer,1)
  next i
  asize(saColBuffer,len(saColBuffer)-n)
* enddo
snColCount := nColcount
RETURN NIL

**
** {set dialog on|off}
**
* FUNCTION p_DoDialog(c)
* scDoDialog := if(upper(c) == "OFF", BUTTON_OFF,BUTTON_ON)
* RETURN NIL

**
**  {set capture <cFileName>}
**  {set capture} oder {set capture off}
**
FUNCTION p_SetCapture(c)
if empty(c) .or. upper(c) == "OFF"
  scDoCapture  := BUTTON_OFF
else
  scPrnFile := upper(c)
  scDoCapture  := BUTTON_ON
endif
RETURN .t.

**
** {set export <cDelim>}
**
FUNCTION p_SetExport(c)
if c != NIL
  scExport := xparse(c) // EvalExpr(c)
endif
RETURN scExport

**
** {set manual on|off}
**
* FUNCTION p_DoManual(c)
* scDoManual := if(upper(c) == "OFF", BUTTON_OFF,BUTTON_ON)
* RETURN NIL


**
** {set indent <nLeft>,<nRight> [, cBox ] }
**
FUNCTION p_Indent(cParam)
local a
static saIndent := {}
if lower(cParam) == "off"
  RETURN NIL if len(saIndent) == 0
  a := atail(saIndent)
  snLIndent := a[1]
  snRIndent := a[2]
  scFrame   := a[3]
  asize(saIndent,len(saIndent) - 1)
else
  aadd(saIndent, { snLIndent, snRIndent, scFrame } )  // push current settings
  a := ListAsArray(cParam,",")
  if len(a) == 2
    snLIndent += val(a[1])
    snRIndent += val(a[2])
  elseif len(a) == 3
    snLIndent += val(a[1])
    snRIndent += val(a[2])
    scFrame   := xparse(a[3]) // EvalExpr(a[3])
  endif
endif
RETURN NIL


**
** p_LnWidth() - width (inches) of printable paper area
**               used mainly by FntApsActivate()
**
FUNCTION p_LnWidth
RETURN snPapWidth - (snLMargin + snRMargin)

**
** p_LnLength() errechnet, wieviele Zeichen auf eine Zeile passen
** fÅr evtl. Wrapping, z.B. Artikelbeschreibungen, Memofelder,...
**       wie p_cpl
* FUNCTION p_LnLength
* RETURN int( (snPapWidth - (snLMargin + snRMargin)) * FntPitch())


** template vars
FUNCTION p_SetHeader(cTpl)
local nPos := at("/nofirst",cTpl)
if nPos == 0
  slNoFirst := .f.
else
  slNoFirst := .t.
  cTpl := trim(left(cTpl,nPos-1))
endif
if len(cTpl) <= LenIdTpl()
  cTpl := upper(cTpl)
  if cTpl == "NIL"
    sbHeader := NIL
  else
    sbHeader := {||TplParse(TplValue(TPLTYPE_HDR,cTpl,{||TplMemo()},""))}
  endif
else
  saHeader := ListAsArray(cTpl,"|")
  if len(saHeader) == 3
    saHeader[1] := StrParse(saHeader[1])
    saHeader[2] := StrParse(saHeader[2])
    saHeader[3] := StrParse(saHeader[3])
    sbPageHeader := {|| ;
      PrintHeader(saHeader[1],saHeader[2],saHeader[3]) ;
    }
  else
    SetMsg(cTpl + " :","muss genau 2 '|' enthalten !")
    RETURN .f.
  endif
endif
RETURN .t.

FUNCTION p_SetFooter(cTpl,lNoLast)
local nPos := at("/nolast",cTpl)
if nPos == 0
  slNoLast := .f.
else
  slNoLast := .t.
  cTpl := trim(left(cTpl,nPos-1))
endif
**if len(cTpl) <= LstIdTpl()
**  scFooter := upper(cTpl)
**else
*  scFooter := cTpl
**endif
if len(cTpl) > LenIdTpl()
  sbFooter := {|| TplParse(cTpl) }
else
  cTpl := TplValue(TPLTYPE_HDR,upper(cTpl),{||TplMemo()})
  RETURN !SetMsg(TPLTYPE_HDR+":"+upper(cTpl)+MsgTplExist()) if cTpl == NIL
  sbFooter := {|| TplParse(cTpl) }
endif
RETURN .t.

FUNCTION SetTplHeader(b,lNoFirst)
default lNoFirst to .f.
slNoFirst := lNoFirst
* sbPageHeader := b
sbHeader := b
RETURN .t.

FUNCTION SetTplFooter(b,lNoLast)
default lNoLast to .f.
slNoLast := lNoLast
sbFooter := b
RETURN .t.

** numeric vars
FUNCTION p_SetLMargin(n)
RETURN snLMargin if n == NIL
snLMargin := n
RETURN .t.
FUNCTION p_SetRMargin(n)   ; snRMargin := n ; RETURN .t.
FUNCTION p_SetTMargin(n)   ; snTMargin := n ; RETURN .t.
FUNCTION p_SetBMargin(n)
  snBMargin := n
  snMaxVPos := snPapHeight - snBMargin
RETURN .t.

FUNCTION p_SetSpecial(c)
RETURN scDrvSpecial if c == NIL
scDrvSpecial := c
RETURN .t.

FUNCTION p_SetPapHeight(n)
snPapHeight  := n
snMaxVPos := snPapHeight - snBMargin
RETURN .t.

FUNCTION p_SetPapWidth(n)  ; snPapWidth   := n ; RETURN .t.
** char vars

FUNCTION p_SetPort(c)
RETURN scPort if c == NIL
scPort := c
RETURN .t.

FUNCTION p_SetFinalFF(l)   ; slFinalFF := l ; RETURN .t.

FUNCTION p_Align(cAlign)
if cAlign != NIL
  scAlign := cAlign
endif
RETURN scAlign

FUNCTION p_SetAlign(cPar)
RETURN NIL if ! slPStream
scAlign := upper(cPar)
RETURN .t.

**
** {etc goto <nLine>}
**
FUNCTION p_Goto(nLine)
local nGoto
RETURN NIL if ! slPStream
if nLine > 0
  nGoto := FntHeight() * nLine
else
  nGoto := snMaxVPos + (FntHeight() * nLine)
endif
* 20071031 confirm("p_goto("+ntrim(nGoto)+")")
if snVPos > nGoto
  * 20050616 Debugging
  * Confirm(;
  *   "p_goto("+ntrim(nLine)+") : MaxVPos "+ntrim(snMaxVPos);
  *   +"vpos "+ntrim(snVPos);
  *   +"FntHeight "+ntrim(FntHeight());
  * )
  p_Eject(.f.) // 19990329
endif
do while snVPos < nGoto .and. snPrnStatus == PRN_CONTINUE
  PrintLine()
enddo
RETURN NIL

FUNCTION p_MrgMirror()
local n := snLMargin
snLMargin := snRMargin
snRMargin := n
RETURN NIL

**
** {etc dbskip}
**
FUNCTION p_dbskip(c)
dbskip()
RETURN NIL

FUNCTION p_PageNum(x)
RETURN snLogPage if x == NIL
snLogPage := x
RETURN .t.
// two aliases for backwards compatibility:
FUNCTION p_CurPage(x) ; RETURN p_PageNum(x)
FUNCTION SetCurPage(n) ; RETURN p_PageNum(n)

**
** {etc block begin}
** {etc block end}
**
FUNCTION p_Block(cPar)
local i
slKeepBlock := .f.
if snPapHeight != 0 .and. len(saKeepLines) > p_LinesLeft()
  p_Eject(.f.)
endif
for i := 1 to len(saKeepLines)
  PrintLine(saKeepLines[i])
next i
saKeepLines := {}
if cPar == "begin"
  slKeepBlock := .t.
elseif cPar != "end"
  TplWarning("?#!")
endif
RETURN NIL

**
** {etc abort <lExpr>}
**
FUNCTION p_Abort(cPar)
if cPar != NIL
  RETURN .f. if ! xparse(cPar)
endif
snPrnStatus := PRN_ABORT
RETURN .t.

**
** {set columns 2 " "}
** {set columns 3 " ≥ "}
**
FUNCTION p_SetColumns(cPar)
local nPos
if snColCount != 0
  do while len(saColBuffer) != 0 .and. snPrnStatus == PRN_CONTINUE
    ColFlush()
  enddo
endif
if cPar == "off"
  PopColumns()
else
  nPos  := at(" ",cPar)
  PushColumns()
  saColBuffer    := {}
  if nPos == 0
    snColCount := val(cPar)
    scColSep   := space(3)
  else
    snColCount := val(left(cPar,nPos-1))
    scColSep   := OhneAnf(substr(cPar,nPos+1))
  endif
  if snColCount == 0
    PopColumns()
    TplWarning("p_SetColumns() : colCount == 0")
    * RETURN NIL
  endif
endif
RETURN NIL

FUNCTION PushColumns()
aadd(saColStack, { saColBuffer, snColCount, scColSep } )
RETURN NIL

FUNCTION PopColumns()
RETURN NIL if len(saColStack) == 0
saColBuffer    := atail(saColStack)[1]
snColCount     := atail(saColStack)[2]
scColSep       := atail(saColStack)[3]
asize(saColStack, len(saColStack) - 1)
RETURN NIL

FUNCTION TplLang() ; RETURN scLangue

FUNCTION SetTplLang(cLangue)
RETURN scLangue if cLangue == NIL
scLangue := cLangue
RETURN .t.

FUNCTION LstContinue()
RETURN (snPrnStatus == PRN_CONTINUE)
* RETURN .f.

FUNCTION p_LinesLeft
RETURN -1 if snPapHeight == 0
RETURN int( (snMaxVPos - snVPos) / FntHeight() ) if snVPos != 0
RETURN int( (snMaxVPos - snTMargin) / FntHeight() )

**
** PrintHeader()
**
FUNCTION PrintHeader( cHead1, cHead2, cHead3, bLeer)
local cLine1
local cLine2
local cLine3
local nLenStr
local nLen2
local nLen3 := 12
#ifdef DEF_FIDU
  local cStr1 := MemName1
  local cStr2 := MemName2
  local cStr3 := MemName3
#else
  local cStr1 := MrkStr1
  local cStr2 := MrkStr2
  local cStr3 := MrkStr3
#endif
default cHead1 to ""
default cHead2 to ""
default cHead3 to ""
* default lLeer to .T.
default bLeer to {||PrintLine("")}
nLenStr := len(trim(cStr1))
if nLenStr < len(trim(cStr2)) ; nLenStr := len(trim(cStr2)) ; endif
if nLenStr < len(trim(cStr3)) ; nLenStr := len(trim(cStr3)) ; endif
nLen2 := p_cpl() - 2 - nLenStr - nLen3
PrintLine( replicate("ƒ",p_cpl()) )
cLine1 := padr(cStr1,nLenStr)              + " "
cLine2 := padr(cStr2,nLenStr)              + " "
cLine3 := padr(cStr3,nLenStr)              + " "
if nLen2 < len(trim(cHead1))
  cLine1 += space(nLen2)                 + " "
  cLine2 += space(nLen2)                 + " "
  cLine3 += space(nLen2)                 + " "
else
  cLine1 += padc(cHead1,nLen2)                 + " "
  cLine2 += padc(cHead2,nLen2)                 + " "
  cLine3 += padc(cHead3,nLen2)                 + " "
endif
cLine1 += padl( MsgSeite() + " " + ntrim(snCurPage), nLen3 )
cLine2 += padl( dtoc(UserDate()), nLen3 )
cLine3 += padl( scTime, nLen3 )
PrintLine(cLine1)
PrintLine(cLine2)
PrintLine(cLine3)
if nLen2 < len(trim(cHead1))
  if !empty(cHead1)
    PrintLine()
    PrintLine(padc((cHead1),p_cpl()))
  endif
  if !empty(cHead2) ; PrintLine(padc((cHead2),p_cpl())) ; endif
  if !empty(cHead3) ; PrintLine(padc((cHead3),p_cpl())) ; endif
endif
#ifdef DEF_FIDU
  cLine1 := trim1(MrkStr1)
#else
  cLine1 := ""
#endif
PrintLine( cLine1 + replicate("ƒ",p_cpl() - len(cLine1)) )
* if bLeer != NIL
  eval(bLeer)
* endif
* if lLeer
*   PrintLine()
* endif
RETURN NIL


**
** p_cpl() - Anzahl Zeichen pro Zeile
**
FUNCTION p_cpl
local nWidth := snApsWidth
if snColCount != 0
  nWidth := nWidth - len(scColSep) * (snColCount - 1)
  nWidth := int(nWidth / snColCount)
endif
RETURN nWidth - snLIndent - snRIndent

FUNCTION MsgSeite(cLangue)
default cLangue to scLangue // TplLang()
if     cLangue == "D" ; RETURN "Seite"
elseif cLangue == "N" ; RETURN "Blz."
else                  ; RETURN "Page"
endif
RETURN "page"


FUNCTION KeepBlockBegin()
RETURN NIL

FUNCTION KeepBlockEnd()
RETURN NIL

FUNCTION KeepTogether
RETURN NIL


FUNCTION p_SetWidth(nApsWidth)
local cMsg
FntApsActivate(nApsWidth)
snApsWidth := nApsWidth
// Confirm("p_setWidth() snApsWidth "+ntrim(snApsWidth)+" "+scPrnBuffer)
if scPageAlign == PAGEALIGN_RIGHT
  snLMargin := snPapWidth - snRMargin - (nApsWidth / FntPitch())
  if snLMargin < 0
    #ifdef LG_GERMAN
      cMsg := "Es fehlen "
    #else
      cMsg := "Il manque "
    #endif
    cMsg += ltrim(str(-snLMargin))
    #ifdef LG_GERMAN
      cMsg += " Zoll Papierbreite"
    #else
      cMsg += " pouces"
    #endif
    cMsg += CR_LF
    #ifdef LG_GERMAN
      cMsg += " um "
    #else
      cMsg += " pour imprimer "
    #endif
    cMsg += ntrim(nApsWidth)
    #ifdef LG_GERMAN
      cMsg += " Zeichen darzustellen."
    #else
      cMsg += " caractäres par ligne."
    #endif
    Warning(cMsg)
    snLMargin := 0
  endif
endif
RETURN .t.

*FUNCTION p_SetWidth(nWidth)
*FntApsActivate(nWidth)
*snApsWidth := nWidth
*RETURN NIL

**
** dtocf()
**
*FUNCTION dtocf(dDate,cLangue)
*local cSep := "/"
*RETURN space(10) if empty(dDate)
*default cLangue to scLangue
*if cLangue == "D"
*  cSep := "."
*endif
*RETURN strtran(str(day(dDate),2)," ","0") + cSep + ;
*       strtran(str(month(dDate),2)," ","0") + cSep + ;
*       str(year(dDate),4)
*

FUNCTION SetDateFormat(c)
RETURN scDateFormat if c == NIL
scDateFormat := c
RETURN .t.


FUNCTION dtocf(dDate,cFormat,cIdLng)
local cReturn := ""
local cToken := ""
local i
default cFormat to scDateFormat
default cIdLng to scLangue
RETURN dtoc(dDate) if empty(cFormat)
RETURN "" if empty(dDate)
for i := 1 to len(cFormat)
  if substr(cFormat,i,1) $ "dmy"
    if right(cToken,1) != substr(cFormat,i,1)
      cReturn += TokenText(dDate,cToken,cIdLng)
      cToken := ""
    endif
    cToken += substr(cFormat,i,1)
  else
    if ! empty(cToken)
      cReturn += TokenText(dDate,cToken,cIdLng)
      cToken := ""
    endif
    cReturn += substr(cFormat,i,1)
  endif
next i
if ! empty(cToken)
  cReturn += TokenText(dDate,cToken,cIdLng)
endif
RETURN cReturn

STATIC FUNCTION TokenText(dDate,cToken,cIdLng)
RETURN jour(dDate,cIdLng) if cToken == "dddd"
RETURN strtran(str(day(dDate),2,0)," ","0") if cToken == "dd"
RETURN ntrim(day(dDate)) if cToken == "d"
RETURN MonthName(month(dDate),cIdLng) if cToken == "mmmm"
RETURN strtran(str(month(dDate),2,0)," ","0") if cToken == "mm"
RETURN str(year(dDate),4,0) if cToken == "yyyy"
RETURN substr(str(year(dDate),4,0),3) if cToken == "yy"
RETURN cToken


*FUNCTION dtocf(dDate,c)
*default c to scDateFormat
*RETURN dtoc(dDate) if empty(c)
*RETURN "" if empty(dDate)
*c := astrtran(c,"dddd",jour(dDate,scLangue))
*c := astrtran(c,"dd",strtran(str(day(dDate),2,0)," ","0"))
*c := astrtran(c,"d",ntrim(day(dDate)))
*c := astrtran(c,"mmmm",MonthName(month(dDate),scLangue))
*c := astrtran(c,"mm",strtran(str(month(dDate),2,0)," ","0"))
*c := astrtran(c,"yyyy",str(year(dDate),4,0))
*c := astrtran(c,"yy",substr(str(year(dDate),4,0),3))
*RETURN c

*FUNCTION astrtran(cWhere,c1,c2)
*local nPos
*local cReturn := ""
*local lFound
*do while (nPos := at(c1,cWhere)) > 0
*  lFound := .t.
*  if nPos > 1 .and. isalpha(substr(cWhere,nPos-1,1))
*    lFound := .f.
*  endif
*  if nPos + len(c1) < len(cWhere) .and. isalpha(substr(cWhere,nPos+len(c1),1))
*    lFound := .f.
*  endif
*  cReturn += left(cWhere,nPos-1)
*  if lFound
*    cReturn += c2
*  else
*    cReturn += c1
*  endif
*  cWhere := substr(cWhere,nPos+len(c1))
*enddo
*cReturn += cWhere
*RETURN cReturn




**
** LstError()
**
FUNCTION LstError(nNew)
if nNew != NIL
  snPrnStatus := nNew
endif
RETURN snPrnStatus



FUNCTION p_SetFont(cIdFnt)
PrnFlush()
FntActivate(cIdFnt)
snApsWidth := int((snPapWidth - snLMargin - snRMargin) * FntPitch())
// Confirm("p_SetFont() snApsWidth "+ntrim(snApsWidth)+" "+scPrnBuffer)
eval(sbWriter,FntCtrl())
RETURN NIL

*FUNCTION p_LinesLeft()
*FntHeight()
*RETURN NIL

FUNCTION TmpConvert(cFile)
local nPos := at("*",cFile)
local aDir
local cNew
local nDosError
RETURN "TMP.TXT" if empty(cFile)
RETURN cFile if nPos == 0
aDir := directory(cFile)
if len(aDir) == 0
  cNew := strtran(cFile,"*","0001")
else
  cNew := left(cFile,rat("\",cFile))
  asort(aDir,,, {|x,y| x[F_NAME] < y[F_NAME] } )
  cNew += NextTmpFile(atail(aDir)[F_NAME])
endif
RETURN cNew

FUNCTION NextTmpFile(cName)
local nPos := at(".",cName)
RETURN NextId(left(cName,nPos-1)) + substr(cName,nPos)


FUNCTION PickPort
RETURN ArrayPick( ;
  { "PRN ", ;
    "LPT1", ;
    "LPT2", ;
    "LPT3", ;
    "COM1", ;
    "COM2", ;
    "COM3"  ;
  }  ;
)


#else

  FUNCTION LstContinue() ; RETURN .t.
  FUNCTION LstError() ; RETURN 0

#endif DEF_PRINT


* FUNCTION p_AddDlg(dlg)
* aadd(saDlg,dlg)
* RETURN NIL

*FUNCTION p_DlgPreview
*local dlg := array(DLG_ALEN)
*dlg[DLG_CHECKBOX] := .t.
*dlg[DLG_CAPTION] := MSG018
*dlg[DLG_GET] := GetNew(row(),col(), ;
*  {|x| if( x == NIL, scDoPreview, scDoPreview := x) }, ;
*  NIL, PIC_ID ;
*)
*dlg[DLG_GET]:cargo := array(AG_ALEN)
*p_AddDlg(dlg)
*RETURN NIL
*
*FUNCTION p_DlgRange
*local dlg := array(DLG_ALEN)
*dlg[DLG_CHECKBOX] := .f.
*dlg[DLG_CAPTION] := "Seitenumfang"
*dlg[DLG_GET] := GetNew(row(),col(), ;
*  {|x| GsbRange(x) }, ;
*  NIL, PIC_ID ;
*)
*dlg[DLG_GET]:cargo := array(AG_ALEN)
*p_AddDlg(dlg)
*RETURN NIL


FUNCTION SetRange(x)
local nPos
if x == NIL
  RETURN space(10) if snPrintFrom == 0 .and. snPrintFrom == 0
  RETURN padr(ntrim(snPrintFrom),10) if snPrintFrom == snPrintUntil
  RETURN padr(ntrim(snPrintFrom) + "-" + ntrim(snPrintUntil),10)
endif
if (nPos := at("-",x)) == 0
  snPrintFrom := snPrintUntil := val(x)
  RETURN .t.
endif
snPrintFrom := val(left(x,nPos-1))
snPrintUntil := val(substr(x,nPos+1))
RETURN .t.

FUNCTION mparse(cInFile,cCmdTags,lAllowInt,lFlatLongLines)
* 20021118 local aIfStack := saIfStack
local cSaveCmdTags := SetCmdTags()
local fd := mopen(cInFile,.t.)
RETURN .f. if fd == NIL
if cCmdTags != NIL
  SetCmdTags(cCmdTags)
endif
default lAllowInt to .f.
TplParse(mrawmemo(fd),cInFile,lAllowInt,lFlatLongLines)
* 20021118 saIfStack := aIfStack
mclose(fd)
RETURN SetCmdTags(cSaveCmdTags)

FUNCTION sparse(cMemo,cSource,lTaskInter)
local lDone := .f.
local b := {||iif(lDone,NIL,iif((lDone:=.t.)!=NIL,hardcr(cMemo),NIL))}
RETURN parse(b,SetCmdTags(),lTaskInter,cSource)
  

/***

StrParse() returns the parsed template string

sparse() parses a string to the current ostream (and returns .f. on
failure)

***/

FUNCTION StrParse(cTpl,cCmdTags)
local c := ""
local nPrnStatus := snPrnStatus
local lOkay
local cSaveCmdTags := SetCmdTags()
BeginOStream({|x| if(slPStream,c += x,NIL)})
if cCmdTags != NIL
  SetCmdTags(cCmdTags)
endif
lOkay := TplParse(cTpl,"StrParse()",.f.)
EndOStream()
snPrnStatus := nPrnStatus
SetCmdTags(cSaveCmdTags)
RETURN c


  

**
** TplParse() - see also fparse()
**
FUNCTION TplParse(cMemo,cSource,lAllowInt,lFlatLongLines,lInline)
local c
local nPos1
local nPos2
local nLen
local cIdTca
local aTcs
local cIdTcs
local cParam
local cRetVal
local i,j
local lFound
local cChar
local cOldChar
local cSaveSource := scSource
local aIfStack := saIfStack
RETURN .f. if cMemo == NIL
RETURN .f. if ! ChkMemoLen(cMemo)
default lInline to .t.
default lAllowInt to .t.
default lFlatLongLines to .t.
// LogDebug("TplParse() : " + valtype(cMemo) + " " + ntrim(len(cMemo)))
if lFlatLongLines
  cMemo := strtran(cMemo,"\"+CR_LF)
endif
scSource := cSource
do while (nPos1 := at(scTagBegin,cMemo)) != 0 ;
         .and. snPrnStatus != PRN_ABORT
  if lAllowInt .and. TaskInter()
    snPrnStatus := PRN_ABORT
    exit
  endif
  // zunÑchst das StÅck bis vor dem ersten "{" unverÑndert Åbernehmen:
  eval(sbWriter,left(cMemo,nPos1-1))
  cMemo := substr(cMemo,nPos1)
  **
  ** Jetzt muss ich die schlie·ende "}" ausfindig machen. Das ist
  ** nicht unbedingt die nÑchste. {}-Codes sollen ja erstens
  ** ineinandergeschachtelt sein dÅrfen, und zweitens soll "\" als
  ** Escape-Zeichen dienen
  **
  nPos2 := 0         // nPos2 : Position des schliessenden "}"
                     // 0  : noch nicht gefunden
                     // -1 : sogar noch einen weiteren îffnenden "{"
                     //      gefunden (also den nÑchsten schliessenden
                     //      nicht nehmen.
                     // > 0 : nPos2 enthÑlt die gesuchte Position
  i := 2
  nLen := len(cMemo) // weil cMemo recht lang sein kînnte...
                     // keine Beweise, ob das dadurch schneller geht.
  do while nPos2 <= 0 .and. i <= nLen
    cOldChar := cChar
    cChar := substr(cMemo,i,1)
    if cChar == scTagBegin .and. cOldChar != "\"
      nPos2 --  // einen nesting-level rauf schalten
    elseif cChar == scTagEnd .and. cOldChar != "\"
      nPos2++
      if nPos2 > 0
        nPos2 := i
        exit
      endif
    endif
    i++
  enddo
  if nPos2 == 0 // keine schlie·ende "}" gefunden...
    cRetVal := cMemo
    nPos2 := len(cMemo)
  else
    scWarnStr := alltrim(left(cMemo,nPos2))
    **
    ** nPos1 wird jetzt benutzt, um eventuelle Befehlsparameter zu
    ** identifizieren.
    if substr(cMemo,2,1) == "="
      if slPStream
        c := substr(cMemo,3,nPos2-3)
        c := eval(sbInputFilter,c)
        c := strtran(c,CR_LF," ") // 20070425
        #ifdef DEF_OLDPARSE
          // nur fÅr GX, damit bestehende Druckmasken nicht angepasst
          // zu werden brauchen.
          if lInline
            cRetVal := ExprParse(c)
          else
            cRetVal := xparse(c)
          endif
        #else
          cRetVal := xparse(c)
        #endif
      else
        cRetVal := NIL
      endif
    elseif substr(cMemo,2,1) == "*" // Kommentar
      cRetVal := NIL
    else // if !slRtfMode
      nPos1 := at(" ",left(cMemo,nPos2-1))
      **  Mîgliche FÑlle :
      **         {idtca idtcs}
      **         {idtca idtcs par1}
      **         {idtca idtcs par1 par2}
      **         {g}      -> cIdTca := leer oder so
      **
      **
      if nPos1 == 0
        cRetVal := left(cMemo,nPos2) // take input without change
      else
        cIdTca := substr(cMemo,2,nPos1-2)
        cParam := substr(cMemo,nPos1+1,nPos2-nPos1-1)
        nPos1 := at(" ",cParam)
        if nPos1 == 0
          cIdTcs := cParam
          cParam := ""
        else
          cIdTcs := left(cParam,nPos1 - 1)
          cParam := substr(cParam,nPos1 + 1)
        endif
        cRetVal := TcsEval(cIdTca,cIdTcs,cParam,left(cMemo,nPos2))
      endif
    * 20021219
    * else
    *   nPos2   := 1
    *   cRetVal := left(cMemo,nPos2)
    endif
  endif
  ** Befehle, die NIL zurÅckgeben, mÅssen selbst ein eval(bBuffer)
  ** machen, wenn sie etwas bewirken wollen. Der aufrufbewirkende Textteil
  ** wird nicht in den Buffer reingeschrieben.
  ** Wenn ein Befehl NIL zurÅckgibt und au·erdem auch noch von einem
  ** CR_LF gefolgt ist, dann wird ebenfalls das CR_LF ignoriert.
  ** Wenn ein Befehl etwas zurÅckgibt, muss dies ein string sein, und
  ** dieser String wird dann in den Buffer reingeschrieben.
  ** Unbekannte Befehle werden unverÑndert Åbernommen.
  cMemo := substr(cMemo,nPos2+1)
  if cRetVal == NIL
    if left(cMemo,2) == CR_LF
      cMemo := substr(cMemo,3)
    endif
  elseif valtype(cRetVal) == "C"
    eval(sbWriter,DrvCvtString(cRetVal))  
  elseif valtype(cRetVal) == "L"
    if cRetVal
      if left(cMemo,2) == CR_LF // new 20021112
        cMemo := substr(cMemo,3)
      endif
    else
      snPrnStatus := PRN_ABORT
      * // 20040428 TplWarning(SetMsg())
      * if empty(SetMsg()).or.!Confirm( ;
      *   scWarnStr+" : " + SetMsg(),MsgContinue(),MSG_NO)
      *   snPrnStatus := PRN_ABORT
      * endif
    endif
  else
    // 20040428 TplWarning(scWarnStr + MSG_NIL_OR_CHAR )
    SetMsg(scWarnStr + MSG_NIL_OR_CHAR )
    snPrnStatus := PRN_ABORT
  endif
enddo
eval(sbWriter,cMemo)
scSource := cSaveSource
saIfStack := aIfStack
// 20030113 RETURN LstContinue()
RETURN .t. // LstContinue() // lOkay // cNewMemo


FUNCTION length2i(cLength)
cLength := strtran(cLength,",",".")
if right(cLength,2) == "mm"
  cLength := left(cLength,len(cLength)-2)
  RETURN val(cLength) / 25.4
endif
if right(cLength,2) == "cm"
  cLength := left(cLength,len(cLength)-2)
  RETURN val(cLength) / 2.54
endif
RETURN val(cLength)


FUNCTION TcsEval(cIdTca,cIdTcs,p,c)
local lReturn, aLoop, b
local cMac
local e
local i
// debug SendConsole("TcsEval "+cIdTca+" "+cIdTcs+" "+p)
for i := 1 to len(saCmd)
  if saCmd[i][CMD_ID] == cIdTca
    RETURN xeval(saCmd[i][CMD_BLOCK],cIdTcs,p,c)
  endif
next i
if cIdTca == "login"
  if cIdTcs == "name"             ; c:= Auteur(StrParse(p))
  * elseif cIdTcs == "fonction"     ; c:= Fonction(p,scLangue)
  elseif cIdTcs == "title"        ; c:= Fonction(StrParse(p),scLangue)
  elseif cIdTcs == "date"         ; c:= dtocf(UserDate())
  endif
elseif cIdTca == "set"
  if     cIdTcs == "driver"        ; c:= DrvLoad(p)
  elseif cIdTcs == "special"       ; c:= p_SetSpecial(p)
  elseif cIdTcs == "option"        ; c:= p_SetSpecial(p)
  elseif cIdTcs == "finalff"       ; p_SetFinalFF(ctol(p)) ; c := NIL
  elseif cIdTcs == "paperheight"   ; p_SetPapHeight(length2i(p)) ; c := NIL
  elseif cIdTcs == "paperwidth"    ; c:= p_SetPapWidth(length2i(p))
  elseif cIdTcs == "marginleft"    ; c:= if(p_SetLMargin(length2i(p)),NIL,SetMsg())
  elseif cIdTcs == "marginright"   ; c:= if(p_SetRMargin(length2i(p)),NIL,SetMsg())
  elseif cIdTcs == "margintop"     ; c:= if(p_SetTMargin(length2i(p)),NIL,SetMsg())
  elseif cIdTcs == "marginbottom"  ; c:= if(p_SetBMargin(length2i(p)),NIL,SetMsg())
  elseif cIdTcs == "pagealign"     ; scPageAlign := upper(p) ; c := NIL
  elseif cIdTcs == "indent"        ; c:= p_Indent(p)
  elseif cIdTcs == "outport"       ; c:= p_SetPort(p)
  elseif cIdTcs == "font"          ; c:= p_SetFont(p)
  elseif cIdTcs == "apswidth"      ; p_SetWidth(val(p)) ; c:= FntCtrl()
  elseif cIdTcs == "header"        ; c:= p_SetHeader(p)
  elseif cIdTcs == "footer"        ; c:= p_SetFooter(p)
  elseif cIdTcs == "capture"       ; c:= if(p_SetCapture(p),NIL,SetMsg())
  elseif cIdTcs == "align"         ; c:= p_SetAlign(p)
  elseif cIdTcs == "columns"       ; c:= p_SetColumns(p)
  elseif cIdTcs == "montant"       ; SetMntFormat(p) ; c := NIL
  elseif cIdTcs == "solde"         ; SetSolde(p)     ; c := NIL
  elseif cIdTcs == "lang"          ; SetTplLang(StrParse(p))  ; c := NIL
  elseif cIdTcs == "dateformat"    ; SetDateFormat(p) ; c := NIL
  endif
elseif cIdTca == "etc"
      if cIdTcs == "include"
        if slPStream
          c:= TplInclude(TPLTYPE_INC,StrParse(p))
        endif
  elseif cIdTcs == "if"      ; c:= p_If(p)
  * elseif cIdTcs == "elseif"  ; c:= p_ElseIf(p)
  elseif cIdTcs == "else"    ; c:= p_Else()
  elseif cIdTcs == "endif"   ; c:= p_EndIf()
  elseif cIdTcs == "scan"    ; c:= EtcScan(p)
  elseif cIdTcs == "line"    ; c:= repl("ƒ",p_cpl())
  elseif cIdTcs == "abort"   ; c:= p_Abort(p)
  elseif cIdTcs == "goto"    ; c:= p_Goto(xparse(p))
  elseif cIdTcs == "dbskip"  ; c := p_dbskip(p)
  elseif cIdTcs == "block"   ; c:= p_Block(p)
  elseif cIdTcs == "page"    ; c:= ntrim(p_PageNum())
  elseif cIdTcs == "eject"   ; c:= p_Eject(.f.)
  elseif cIdTcs == "nextjob" ; c:= p_NextJob(p)
  elseif cIdTcs == "do"
    if slPStream
      xparse(p)
    endif
    c := NIL
  elseif cIdTcs == "loop"
    if slPStream
      soLoop := splitws(p,2)
      aadd(soLoop,"") // LOOP_NAME, LOOP_EXPR, LOOP_TEXT (LOOP_ALEN)
      * LogDebug("loop: "+p+" {|xlEval|"+utos(c)+"}")
    endif
    RETURN NIL
  * 20080125 elseif cIdTcs == "exit"    ; snPrnStatus := PRN_EXIT ; c:= NIL
  endif
elseif cIdTca == "dlg"
  c := DlgValue(cIdTcs)
#ifdef DEF_TABLE
elseif cIdTca == "tab"
      if cIdTcs == "define"      ; c:= p_TabDefine(p)
  elseif cIdTcs == "column"      ; c:= p_TabColumn(p)
  elseif cIdTcs == "exec"        ; c:= p_TabExec(p)
  elseif cIdTcs == "begin"       ; c:= p_TabBegin(p)
  elseif cIdTcs == "end"         ; c:= p_TabEnd(p)
  elseif cIdTcs == "height"      ; c:= p_TabHeight(val(p))
  elseif cIdTcs == "space"       ; c:= p_TabSpace(val(p))
  endif
#endif
elseif slPStream  // neu 20020112
  RETURN AppTcsEval(cIdTca,cIdTcs,p,c) // ,bBuffer)
endif
RETURN c

FUNCTION p_SetPgAlign(c)
RETURN scPageAlign if c == NIL
scPageAlign := upper(c)
RETURN .t.


FUNCTION CmdDefine(cIdCmd,bReturn)
local i
local cmd
for i := 1 to len(saCmd)
  if saCmd[i][CMD_ID] == cIdCmd
    if bReturn == NIL
      adel(saCmd,i)
      asize(saCmd,len(saCmd)-1)
    else
      saCmd[i][CMD_BLOCK] := bReturn
    endif
    RETURN .t.
  endif
next i
if bReturn == NIL
  SetMSg(cIdCmd + " : cmd did not exist")
  RETURN .f.
endif
cmd := array(CMD_ALEN)
cmd[CMD_ID] := cIdCmd
cmd[CMD_BLOCK] := bReturn
aadd(saCmd,cmd)
RETURN .t.




FUNCTION ExprParse(cTpl)
RETURN xparse(StrParse(cTpl))


FUNCTION GetPreview(cDefault)
if cDefault != NIL
  scDoPreview := cDefault
endif
@ CSR_POS get scDoPreview checkbox
say " " + MSG_PREVIEW // Druckvorschau"
* WinCr()
RETURN NIL

* FUNCTION SetPreview ; RETURN scDoPreview

FUNCTION GetRange
local cRange := SetRange()
#ifdef LG_GERMAN
  say "Seiten von-bis : "
#else
  say "Pages de-Ö : "
#endif
@ CSR_POS get cRange valid SetRange(cRange)
WinCr()
RETURN NIL


FUNCTION GetTplIni(cTplIni)
say utrp("Printer parameter set", ;
         "Druckparametersatz ", ;
         "Paramätres imprimante ")
@ CSR_POS get scTplIni picture PIC_ID ;
                       pick PickTpl(TPLTYPE_INI,scTplIni)
WinCr()
RETURN NIL


FUNCTION SetTplIni(x)
default scTplIni to space(8)
RETURN scTplIni if x == NIL
scTplIni := padr(x,LenIdTpl())
RETURN .t.

// CALU : {etc if ...} {etc nextjob} {etc endif}
FUNCTION p_NextJob(cIdTplIni)
local nWidth := snApsWidth
local aIfStack := saIfStack
RETURN NIL if ! slPStream
ClosePrinter()
OpenPrinter(cIdTplIni,scDoPreview,nWidth)
saIfStack := aIfStack
RETURN NIL

FUNCTION ColCount ; RETURN snColCount // for p_TabExec()

FUNCTION EtcScan(p)
local cFormat  := ""
local cFilter  := NIL
local nHeight  := 1
local nWidth   := 1
local nPos
local aBuf := {}
if (nPos := at("/format ",p)) != 0
  cFormat := substr(p,nPos + 8)
  p := left(p,nPos - 1)
endif
if (nPos := at("/filter ",p)) != 0
  cFilter := substr(p,nPos + 8)
  p := left(p,nPos - 1)
endif
ddScan( {|| EtcCollect(@aBuf,cFormat,p) }, cFilter )
EtcCollect(aBuf,cFormat)
RETURN NIL

STATIC FUNCTION EtcCollect(aBuf,cFormat,cTpl)
* local bParseBuffer := SetParseBuffer()
local nColumns := 0
local nHeight
local nWidth
local i
local j
local aLines
local nSpace := 0
local nPos
local aFormat := ListAsArray(cFormat,"x")
local c := ""
if len(aFormat) == 3
  nColumns := val(aFormat[1])
  nHeight  := val(aFormat[2])
  nWidth   := val(aFormat[3])
  nSpace := int((p_cpl() - nWidth * nColumns) / (nColumns - 1))
endif
if nColumns > 0
  if len(aBuf) >= nColumns .or. cTpl == NIL
    ** aBuf leeren
    aLines := {}
    for j := 1 to nHeight
      aadd(aLines,"")
    next j
    for i := 1 to nColumns
      if i <= len(aBuf)
        for j := 1 to nHeight
          aLines[j] += padr(memoline(aBuf[i],nWidth,j),nWidth)
          if i < len(aBuf)
            aLines[j] += space(nSpace)
          endif
        next j
      endif
    next i
    for j := 1 to nHeight
      PrintLine(aLines[j])
    next j
    aBuf := {}
  endif
  if cTpl != NIL
    aadd(aBuf,StrParse(cTpl))
  endif
elseif cTpl != NIL
  TplParse(cTpl)
endif
RETURN .t.


FUNCTION p_setCopies(nCopies)
snCopies := nCopies
RETURN .t.

FUNCTION SetCmdTags(cTagBegin,cTagEnd)
local nLen
RETURN scTagBegin + scTagEnd if cTagBegin == NIL
if cTagEnd == NIL
  nLen := len(cTagBegin) / 2
  if int(nLen) != nLen .or. nLen < 1
    RETURN ! SetMsg('"'+cTagBegin+'" must be 2 or 4 characters long.')
  endif
  scTagBegin := left(cTagBegin,1)
  scTagEnd   := right(cTagBegin,1)
else
  scTagBegin := cTagBegin
  scTagEnd   := cTagEnd
endif
RETURN .t.

// Tagged() wird benutzt in txtedit.prg und in report.prg
FUNCTION Tagged(c) ; RETURN scTagBegin + c + scTagEnd


FUNCTION MsgPrinting()
RETURN utrp(" being printed", " wird gedruckt"," en cours d'impression")

** FUNCTION MsgPrinting()
** #ifdef LG_GERMAN
**   FUNCTION MsgPrinting() ; RETURN " wird gedruckt"
** #else
**   FUNCTION MsgPrinting() ; RETURN " en cours d'impression"
** #endif

FUNCTION SetPreview(cPreview)
RETURN scDoPreview if cPreview == NIL
scDoPreview := cPreview // if(lPreview,BUTTON_ON,BUTTON_OFF)
RETURN .t.



FUNCTION freader(fdin,nBytes)
local cBlock := space(nBytes)
local nBytesRead := fread(fdin,@cBlock,nBytes)
RETURN NIL if nBytesRead == 0
cBlock := left(cBlock,nBytesRead)
* snSrcLine += mlcount(cBlock,255,NIL,.f.)
RETURN cBlock


**
** fparse() derived from TplParse()
** funktioniert auch mit Dateien, die grî·er als 64K sind.
** énderung im Algoritmus :
** Wenn nPos2 0 ist, dann wird nichts getan, sondern das nÑchste StÅck
** eingelesen.
**
FUNCTION fparse(cInFile,cOutFile,cCmdTags,;
  lAllowInt,lOverWrite,lAppend,nBytes,cDrvName,lInline;
)
local lOkay := .t.
local cFileName
local fdin
local cDllPath := GetDlmPath(cInFile)
local bInputFilter := SetInputFilter()
if cDllPath == NIL
  SetMsg(cInFile+MsgFileExist())
  RETURN .f.
endif
// Confirm("fparse("+utos(cInFile)+","+utos(cOutFile)+")")
fdin := fopen(cDllPath)
if fdin == -1
  SetMsg(cDllPath + MsgDosError(ferror()))
  RETURN .f.
endif
if cOutFile != NIL
  if ! BeginOfStream(cOutFile,lAppend,lOverwrite,cDrvName)
    fclose(fdin)
    RETURN .f.
  endif
else
  RETURN .f. if snPrnStatus != PRN_CONTINUE
endif
#ifdef DEF_DEBUG
  MsgDisplay(cInFile)
#endif DEF_DEBUG
default nBytes to 200
lOkay := parse( ;
  {||freader(fdin,nBytes)}, ;
  cCmdTags, lAllowInt, cInFile, lInline;
)
fclose(fdin)
if cOutFile != NIL
  EndOfstream()
endif
SetInputFilter(bInputFilter)
RETURN lOkay

FUNCTION split(c,cDelim,nMaxLen,lSeqCountsOnce)
local a := {}
local n
default lSeqCountsOnce to .f.
do while (n := at(cDelim,c)) > 0
  if nMaxLen != NIL .and. len(a) == nMaxLen -1
    exit
  endif
  aadd(a,left(c,n-1))
  c := substr(c,n+len(cDelim))
  if lSeqCountsOnce
    while left(c,len(cDelim)) == cDelim
      c := substr(c,len(cDelim)+1)
    enddo
  endif
enddo
aadd(a,c)
RETURN a

FUNCTION splitws(c,nMaxLen)
local a := {}
// local n := 1
local ch
local lNext := .t.
do while len(c) > 0
  if left(c,2) == CR_LF
    ch := CR_LF
    c := substr(c,3)
    lNext := .t.
  else
    ch := left(c,1)
    c := substr(c,2)
    if ch == " " .or. ch == chr(9)
      lNext := .t.
    else
      if lNext 
        aadd(a,ch)
        if nMaxLen != NIL .and. len(a) == nMaxLen 
          a[len(a)] += c
          exit
        endif
        lNext := .f.
      else
        a[len(a)] += ch
        // atail(a) += ch
      endif
    endif
  endif
enddo
RETURN a
  


STATIC FUNCTION parse(bReader,cCmdTags,lAllowInt,cSource,lInline)
local aLoop, b
local aIfStack := saIfStack
local cSaveSource := scSource
local nSaveSrcLine := snSrcLine
local cSaveCmdTags := SetCmdTags()
local lOkay := .t.
local nPos1
local nPos2
local nPos3
local nLen
local cIdTca
local cIdTcs
local cRetVal
local cChar
local cOldChar
local cMemo := ""
local i,a,c
local cParam
local cBlock
default lAllowInt to .t.
if cCmdTags != NIL
  SetCmdTags(cCmdTags)
endif
scSource := cSource
snSrcLine := 1
default lInline to .t.
do while (cBlock := eval(bReader)) != NIL
  if snPrnStatus != PRN_CONTINUE
    lOkay := .f.
    exit
  endif
  if lAllowInt .and. TaskInter()
    lOkay := .f.
    exit
  endif
  cMemo += cBlock
  * cMemo := flatlonglines(cMemo) // 19990715
  do while (nPos1 := at(scTagBegin,cMemo)) != 0
    if snPrnStatus != PRN_CONTINUE
      lOkay := .f.
      exit
    endif
    if nPos1 > 1 .and. substr(cMemo,nPos1-1,1) == "\"
      snSrcLine += ft_nooccur(CR_LF,left(cMemo,nPos1-2),NIL,NIL,.f.)
      eval(sbWriter,flatlonglines(left(cMemo,nPos1-2))+scTagBegin)
      cMemo := substr(cMemo,nPos1+len(scTagBegin))
      loop
    endif
    **
    ** zunÑchst wird das StÅck bis *vor* den ersten "{" unverÑndert
    ** Åbernommen :
    **
    snSrcLine += ft_nooccur(CR_LF,left(cMemo,nPos1-1),NIL,NIL,.f.)
    eval(sbWriter,flatlonglines(left(cMemo,nPos1-1)))
    cMemo := substr(cMemo,nPos1)
    **
    ** Jetzt muss ich die schlie·ende "}" ausfindig machen. Das ist
    ** nicht unbedingt die nÑchste. {}-Codes sollen ja erstens
    ** ineinandergeschachtelt sein dÅrfen, und zweitens soll "\" als
    ** Escape-Zeichen dienen
    **
    nPos2 := 0         // nPos2 : Position des schliessenden "}"
                       // 0  : noch nicht gefunden
                       // -1 : sogar noch einen weiteren îffnenden "{"
                       //      gefunden (also den nÑchsten schliessenden
                       //      nicht nehmen.
                       // > 0 : nPos2 enthÑlt die gesuchte Position
    i := 2
    nLen := len(cMemo) // weil cMemo recht lang sein kînnte...
                       // keine Beweise, ob das dadurch schneller geht.
    do while nPos2 <= 0 .and. i <= nLen
      cOldChar := cChar
      cChar := substr(cMemo,i,1)
      if cChar == scTagBegin .and. cOldChar != "\"
        nPos2 --  // einen nesting-level rauf schalten
      elseif cChar == scTagEnd .and. cOldChar != "\"
        nPos2++
        if nPos2 > 0
          nPos2 := i
          exit
        endif
      endif
      i++
    enddo
    * if nPos2 == 0
    ** 19990311 : bei HK war doch tatsÑchlich ein Block nach zwei
    ** îffnenden "[" beendet. Also war nPos2 nicht == 0, sondern < 0
    ** Resultat : endless Loop. Konnte zwar umgangen werden durch
    ** VerÑndern der Blockgrî·e...
    if nPos2 <= 0
      exit
      ** nÑchstes StÅck einlesen und dranhÑngen. Der bisher
      ** eingelesene StÅck darf noch nicht weggeschrieben werden, denn es
      ** kînnte ja noch ein abschlie·endes "}" kommen.
    else
      snSrcLine += ft_nooccur(CR_LF,left(cMemo,nPos2),NIL,NIL,.f.)
      scWarnStr := alltrim(left(cMemo,nPos2))
      * neu 20070915
      if soLoop != NIL
        ** wir sind fÅr einen loop am sammeln. also nichts parsen, nur
        ** sammeln und aufs ende warten
        aLoop := soLoop
        if substr(cMemo,2,len(aLoop[LOOP_NAME])+13) ;
          == "etc endloop "+aLoop[LOOP_NAME]+scTagEnd
          ** ende gefunden. loop ausfÅhren. vorher vom loopstack poppen.
          LogDebug("endloop "+aLoop[LOOP_NAME];
                   +" {|xlEval|"+aLoop[LOOP_EXPR]+"} "+aLoop[LOOP_TEXT])
          soLoop := NIL
          b := {||sparse(aLoop[LOOP_TEXT],"loop "+aLoop[LOOP_NAME],.f.)}
          cRetVal := eval(xparse("{|xlEval|"+aLoop[LOOP_EXPR]+"}"),b)
        else
          * aLoop[LOOP_TEXT] += left(cMemo,nPos2)
          eval(sbWriter,left(cMemo,nPos2))
          cRetVal := NIL
          * LogDebug("in loop "+aLoop[LOOP_NAME]+" collect "+cRetVal)
        endif
      * ende neu 20070915
      **
      elseif substr(cMemo,2,1) == "="
        * after 19990104 :
        #ifdef DEF_DEBUG
          if substr(cMemo,3,1) == "="
            TplWarning("{=" + substr(cMemo,4,nPos2-4) +"} : change == to = !")
          endif
        #endif DEF_DEBUG
        if slPStream
          c := flatlonglines(substr(cMemo,3,nPos2-3))
          c := eval(sbInputFilter,c)
          c := strtran(c,CR_LF," ") // 20030320
          #ifdef DEF_OLDPARSE
            // nur fÅr GX, damit bestehende Druckmasken nicht angepasst
            // zu werden brauchen.
            if lInline
              cRetVal := ExprParse(c)
            else
              cRetVal := xparse(c)
            endif
          #else
            cRetVal := xparse(c)
          #endif
        else
          cRetVal := NIL
        endif
      elseif substr(cMemo,2,1) == "*"
        cRetVal := NIL
      else
        c := flatlonglines(substr(cMemo,2,nPos2-2))
        c := eval(sbInputfilter,c)
        a := splitws(c,3)
        if len(a) <= 1
          cRetVal := left(cMemo,nPos2) // leave unchanged
        elseif len(a) == 2
          cRetVal := TcsEval(a[1],a[2],"") // 20030326
        else
          cRetVal := TcsEval(a[1],a[2],a[3])
        endif
      endif
      ** Befehle, die NIL zurÅckgeben, mÅssen selber ein fwrite(fdout)
      ** machen, wenn sie etwas bewirken wollen. Der aufrufbewirkende Textteil
      ** wird nicht in den Buffer reingeschrieben.
      ** Wenn ein Befehl NIL zurÅckgibt und au·erdem auch noch von einem
      ** CR_LF gefolgt ist, dann wird ebenfalls das CR_LF ignoriert.
      ** Wenn ein Befehl etwas zurÅckgibt, muss dies ein string sein, und
      ** dieser String wird dann in den Buffer reingeschrieben.
      ** Unbekannte Befehle werden unverÑndert Åbernommen.
      cMemo := substr(cMemo,nPos2+1)
      if cRetVal == NIL
        if left(cMemo,2) == CR_LF
          cMemo := substr(cMemo,3)
        endif
      elseif valtype(cRetVal) $ "CM"
        eval(sbWriter,DrvCvtString(cRetVal))
        * fwrite(fdout,cRetVal)
      elseif valtype(cRetVal) == "L"
        if cRetVal
          if left(cMemo,2) == CR_LF // new 20021112
            cMemo := substr(cMemo,3)
          endif
        else
          // 20040428 TplWarning(SetMsg())
          snPrnStatus := PRN_ABORT
          // p_abort()
        endif
      else
        // 20040428 TplWarning(scWarnStr + MSG_NIL_OR_CHAR)
        SetMsg(scWarnStr + MSG_NIL_OR_CHAR)
        snPrnStatus := PRN_ABORT
        // p_abort()
      endif
    endif
  enddo
  if nPos1 == 0
    snSrcLine += ft_nooccur(CR_LF,cMemo,NIL,NIL,.f.)
    eval(sbWriter,flatlonglines(cMemo))
    cMemo := ""
  endif
enddo
eval(sbWriter,flatlonglines(cMemo))
scSource := cSaveSource
snSrcLine := nSaveSrcLine
saIfStack := aIfStack
SetCmdTags(cSaveCmdTags)
RETURN lOkay



#define OS_FD       1
#define OS_FILENAME 2
#define OS_WRITER   3
#define OS_LANG     4
#define OS_DRV      5
#define OS_IFSTACK  6
#define OS_PRNSTAT  7
#define OS_ALEN     7

FUNCTION BeginOfStream(cOutFile,lAppend,lOverwrite,cDrvName)
local cFileName := TmpConvert(cOutFile)
local fdout
// Confirm("BeginOfStream("+utos(cOutFile)+")")
default lAppend to .f.
if lAppend
  #ifdef DEF_LFN
    fdout := lf_fopen(cFileName,FO_READWRITE)
  #else
    fdout := fopen(cFileName,FO_READWRITE)
  #endif
  if fdout == -1
    SetMsg(cOutFile + MsgDosError(ferror()))
    RETURN .f.
  endif
  fseek(fdout,0,FS_END)
else
  default lOverwrite to .f.
  if !lOverwrite .and. fexist(cFileName)
    if ! Confirm( ;
      cFileName + MsgOverwrite(),NIL,MSG_NO ;
    )
      RETURN .f.
    endif
  endif
  #ifdef DEF_LFN
  fdout := lf_fcreate(cFileName)
  #else
  fdout := fcreate(cFileName)
  #endif
  if fdout == -1
    SetMsg(cOutFile + MsgDosError(ferror()))
    RETURN .f.
  endif
endif
* 20070920
* RETURN BeginOStream({|x|if(slPStream,fwrite(fdout,TextFormat(x)),NIL)},;
*                     fdout,cFilename,cDrvName)
RETURN BeginOStream({|x|fdostream(fdout,x)},fdout,cFilename,cDrvName)


STATIC FUNCTION BeginOStream(bWriter,fdout,cFilename,cDrvName)
local os := { ;
  fdout,;
  cFilename,;
  sbWriter,;
  scLangue,;
  DrvSave(),;
  saIfStack, ;
  snPrnStatus ;
} // OS_ALEN
if cDrvName != NIL
  RETURN .f. if ! DrvLoad(cDrvName)
endif
snPrnStatus := PRN_CONTINUE
slPStream := .t.
saIfStack := { .t. }
sbWriter := bWriter
aadd(saOsStack,os)
MsgVerbose("BeginOStream() "+cFilename)
RETURN .t.

STATIC FUNCTION EndOStream()
local os
if len(saOsStack) == 0
  raise("saOsStack: stack underflow")
endif
os := atail(saOsStack)  // OS_ALEN
MsgVerbose("EndOStream() "+os[OS_FILENAME])
if ! slPStream
  Warning(os[OS_FILENAME] + " : Missing ENDIF at EOF !")
endif
* if len(saIfStack) != 0 .and. len(saOsStack) == 1
*   Warning(os[OS_FILENAME] + " : IF stack not empty at EOF !")
* endif
sbWriter := os[OS_WRITER]
scLangue := os[OS_LANG]
saIfStack := os[OS_IFSTACK]
snPrnStatus := os[OS_PRNSTAT]
DrvRestore(os[OS_DRV])
asize(saOsStack,len(saOsStack)-1)
RETURN os

FUNCTION EndOfstream()
local os := EndOStream()
fclose(os[OS_FD])
if snPrnStatus == PRN_CONTINUE
  #ifdef LG_GERMAN
    SetMsg(os[OS_FILENAME] + " wurde geschrieben.")
  #endif
  #ifdef LG_FRENCH
    SetMsg(os[OS_FILENAME] + " a ÇtÇ crÇÇ.")
  #endif
  #ifdef LG_EN
    SetMsg(os[OS_FILENAME] + " has been created.")
  #endif
*else
*  SetMsg("(Abort)")
endif
RETURN .t.

FUNCTION osfilename()
local os := atail(saOsStack)
RETURN os[OS_FILENAME]



FUNCTION TplWarning(c)
RETURN .t. if empty(c)
if scSource != NIL
  c := "File " + scSource + ":" + CR_LF + c
endif
RETURN Warning(c)

FUNCTION TplSource
RETURN NIL if scSource == NIL
RETURN scSource + "(" + ntrim(snSrcLine) + ")" ;
  + trims(scWarnStr," near '","'")


FUNCTION flatlonglines(cMemo)
local cNewMemo := ""
local nPos
do while (nPos := at("\"+CR_LF,cMemo)) > 0
  if substr(cMemo,nPos-1,1) == "\"
    cNewMemo += left(cMemo,nPos-1) + CR_LF
    cMemo := substr(cMemo,nPos+3)
  else
    cNewMemo += left(cMemo,nPos-1)
    cMemo := ltrim(substr(cMemo,nPos+3))
  endif
enddo
cNewMemo += cMemo
RETURN cNewMemo


FUNCTION toTxtStream(c)
RETURN toStream(DrvCvtString(c))

FUNCTION toStream(c)
RETURN .f. if snPrnStatus != PRN_CONTINUE
RETURN .f. if sbWriter == NIL
eval(sbWriter,c)
RETURN .t.

FUNCTION writeln(s)
default s to ""
RETURN toTxtStream(s+CR_LF)

**
** {etc elseif <lExpr>}
**
*STATIC FUNCTION p_ElseIf(cPar)
*if slPStream
*  slPStream := .f.
*else
*  slPStream := xparse(cPar)
*endif
*RETURN NIL


STATIC FUNCTION IfStack()
local i
for i := 1 to len(saIfStack)
  RETURN .f. if ! saIfStack[i]
next i
RETURN .t.

STATIC FUNCTION p_If(cPar)
aadd(saIfStack,slPStream)
RETURN NIL if ! slPStream
if xparse(cPar)
  slPStream := .t.
else
  saIfStack[len(saIfStack)] := .f.
  slPStream := .f.
endif
RETURN NIL

STATIC FUNCTION p_Else
local n := len(saIfStack)
if n <= 1
  RETURN ! SetMsg("[etc else] without [etc if] !")
endif
saIfStack[n] := ! atail(saIfStack)
slPStream := IfStack()
RETURN .t.

STATIC FUNCTION p_EndIf
local n := len(saIfStack)
if n <= 1
  RETURN ! SetMsg("[etc endif] : stack underflow !")
endif
asize(saIfStack,n-1)
slPStream := IfStack()
RETURN .t.

FUNCTION NextRefName(cDir,dDate)
RETURN NextFileName(cDir,ntrim(val(dtocf(dDate,"yymmdd"))),"REF")

FUNCTION NextFileName(cDir,cRoot,cExt)
local aDir := directory(cDir + "\" + cRoot + "*." + cExt)
local nStart := len(cRoot) + 1
local nLastNum := 0
local i, n
for i := 1 to len(aDir)
  n := val(substr(left(aDir[i][F_NAME],len(aDir[i][F_NAME])-4),nStart))
  nLastNum := max(nLastNum,n)
next i
RETURN cDir + "\" + cRoot + ntrim(nLastNum+1)+"."+cExt

FUNCTION Test20010522
local d,i,cName
for d := ctod("23.8.1999") to ctod("24.12.2015")
  if TaskInter()
    Warning("abandon!")
    RETURN .f.
  endif
  MsgDisp2(dtoc(d))
  for i := 1 to 34
    cName := NextRefName("c:\temp\ref",d)
    if file(cName)
      Warning("ERREUR : " + cName + " existait dÇjÖ!")
      RETURN .f.
    endif
    memowrit(cName,cName+" = Dossier " + ntrim(i) + " crÇÇ le " + dtoc(d))
    if ! file(cName)
      Warning("ERREUR : " + cName + " n'a pas ÇtÇ crÇÇ !")
      RETURN .f.
    endif
  next i
next d
RETURN .t.

FUNCTION tr(en,de,fr,nl,ee)
local cLangue := iif(scLangue=="*",MemLang1,scLangue)
RETURN de if cLangue == "D"
RETURN fr if cLangue == "F"
RETURN en if cLangue == "E" .and. en != NIL
RETURN nl if cLangue == "N" .and. nl != NIL
RETURN ee if cLangue == "K" .and. ee != NIL
RETURN en

FUNCTION utr(en,de,fr)
RETURN de if UsrLang() == "D"
RETURN fr if UsrLang() == "F"
RETURN en


FUNCTION LngExpr(x,cIdLng)
local s
default cIdLng to TplLang()
#ifdef DEF_4LANG
if cIdLng == MemLang4
  s := xparse(x+"4")
  RETURN s if !empty(s)
endif
#endif
if cIdLng == MemLang3
  s := xparse(x+"3")
  RETURN s if !empty(s)
endif
if cIdLng == MemLang2
  s := xparse(x+"2")
  RETURN s if !empty(s)
endif
RETURN xparse(x+"1")

FUNCTION fprint(cFilename,cCmdTags,nWidth,bPageHeader,;
  cRange, ;
  bPrePrint, ;
  cIdDlg, ;
  lDlg, ;
  lAsPdf, lAsMail )
RETURN .f. if ! OpenPrinter(SetTplIni(),SetPreview(),nWidth,bPageHeader,;
  cRange, ;
  bPrePrint, ;
  cIdDlg, ;
  lDlg, ;
  lAsPdf, lAsMail )
p_MsgDisplay(SetDlgTitle())
if ! fparse(cFilename,NIL,cCmdTags)
  Warning(SetMsg())
endif
ClosePrinter()
RETURN .t.

FUNCTION xprint(x,nWidth)
local lOkay := .t.
RETURN .f. if ! OpenPrinter(SetTplIni(),SetPreview(),nWidth)
p_MsgDisplay(SetDlgTitle())
lOkay := eval(x)
ClosePrinter()
RETURN lOkay


FUNCTION SetAsMail(x) // getvar("asMail")
RETURN slAsMail if x == NIL
slAsMail := x
RETURN .t.

FUNCTION SetBatch(x)
RETURN slBatch if x == NIL
slBatch := x
RETURN .t.

FUNCTION SetPause(x)
RETURN slPause if x == NIL
slPause := x
RETURN .t.

FUNCTION SetAsPdf(x) // getvar("asPDF")
RETURN slAsPdf if x == NIL
slAsPdf := x
RETURN .t.

FUNCTION SetInputFilter(x)
RETURN sbInputFilter if x == NIL
LogDebug("SetInputfilter()")
sbInputFilter := x
RETURN .t.

FUNCTION rtf2dos(cExpr)
cExpr := strtran(cExpr,"\{",'{')
cExpr := strtran(cExpr,"\}",'}')
RETURN cExpr

FUNCTION xml2dos(cExpr)
cExpr := strtran(cExpr,"&quot;",'"')
cExpr := strtran(cExpr,"&lt;",'<')
cExpr := strtran(cExpr,"&gt;",'>')
cExpr := strtran(cExpr,"&amp;",'&')
cExpr := strtran(cExpr,"&apos;","'")
RETURN cExpr


FUNCTION memoToStream(cMemo,cLinePrefix,nWidth)
local i
default cLinePrefix to ""
default nWidth to p_cpl() - len(cLinePrefix)
for i := 1 to mlcount(cMemo, nWidth)
  writeln(cLinePrefix+memoline(cMemo, nWidth, i ))
next i
RETURN .t.


STATIC PROC NilWriter(x)
if ! empty(x)
  raise("Attempted to print "+utos(x)+" while no output stream defined")
endif
RETURN 

