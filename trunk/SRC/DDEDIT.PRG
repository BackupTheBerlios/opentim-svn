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
#include "getexit.ch"

* #define DEF_COMMIT

* static sbOnQryWait := {||.t.}

**
** STATIC_SECTION global static variables
**
static slExcelUser := .t.
static sbMont2CSV := {|cMont|'"'+komma(alltrim(cMont))+'"'}
static soBrowse := NIL  // current browse object !!!!!!
static saData := NIL  // AD array (previously soBrowse:cargo)
// static b := NIL         // current browse object !!!!!!
static scLeg := ""
static snLastRequest := 0
static sbGotoBlock := NIL
static sbOnIdle
static saRecnos
static snRecno
* static slAllowAppend := .T.
static slMustScan
static slIsEof  := .F. // steht der cursor auf lastrec() + 1 ?
                       // bzw. (im Netz) : stand er drauf beim
                       // stabilize...?!
* static slHitBottom := .f.
static slSumActive := .t.
static slModify := .F.
static saKeyStack := {}
* static sbPickOrder
static snMode  := DDMODE_EDIT
static snStart := 0
static sbStatus := NIL
static sxcKey := '""'
static scKeyValue := ""
static sxlFilter := NIL // {||.t.}
static scFltText  := ""
static sbBefore := NIL
static sbAfter  := NIL
static snLastKey := 0
static snRequest := NIL // DDEDIT_BROWSE
static slNoConfirm := .f.
static snRecStat := RS_VALID
static slCanSkip := .t.
static scRecMessage := ""
static snSkipOffset := 0
static snCellHeight := 0
* static sbSearchFormat := NIL
static scIdFlt := ""
static scCsvSep := ","

**
**
**
static saBar   := NIL

**
** MSG_SECTION    MSGnnn definitions
**
#ifdef LG_FRENCH
  #define MSG001  " (pleine page)"
  #define MSG002  "Recherche : "
  #define MSG003  "Cet enregistrement sera invisible puisqu'il est cachÇ par le filtre"
  #define MSG004  " Imprimer texte des champs mÇmo"
  #define MSG005  "Ordre de tri"
  #define MSG006  "~SpÇcial"
  #define MSG011  "Colonnes 1 Ö "
  #ifdef DEF_HELP
    #define MSG016   " [Alt] Menu [Alt-F1] Aide"
  #else
    #define MSG016   " [Alt] Menu "
  #endif
  #define MSG017   " [F10] Fin"
  #define MSG018  " sans dÇtailler chaque enregistrement"
  #define MSG019  " utiliser masque de document..."
  #define MSG020    " [Enter] SÇlectionner"
  #define MSG_INS_DEL  " [Ins] InsÇrer [Del] Supprimer"
  *
  #define MSG_001  "C'est le premier enregistrement."
  #define MSG_002  "C'est le dernier enregistrement."
  * #define MSG_003  "Cette identification existe dÇjÖ !"
  #define MSG_004  "Vos donnÇes sont invalides et ne peuvent pas rester ainsi:"
  * #define MSG_005  "Tapez O pour sortir quand-màme :"
  #define MSG_006  "Le travail a ÇtÇ interrompu."
  #define MSG_011  "Nouvel enregistrement."
  #define MSG_012  "Je compte..."
  *
  #define MSG_EDIT  "EDIT"
  #define MSG_PICK  "SELECT"
  #define MSG_SRCH  "CHERCHE"
  #define MSG_SHOW  "VISUAL"
  #define MSG_VIEW  "VIEW"
  #define MSG_FIND  "POSIT"
  #define MNU_001  "~Fichier"
  #define MNU_002    "Imprimer (~liste)    [Shift-F7]"
  #define MNU_017    "~Imprimer (enreg. courant) [F7]"
  #ifdef DEF_GIMMICK
    #define MNU_003    "~Compter                       "
    #define MNU_004    "~Valider                       "
  #endif
  #define MNU_109    "~Archive                       "
  #define MNU_005    "~Quitter                  [F10]"
  #define MNU_006    "~Enregistrement"
  #define MNU_011    "~Modifier                  [F3]"
  #define MNU_007    "~Supprimer                [Del]"
  #define MNU_008    "~Ajouter                  [Ins]"
  #define MNU_PASTE  "Recopier ~valeur           [F2]"
  #ifdef DEF_SEEK
    #define MNU_009    "Recherche a~vant       [Ctrl-]"
    #define MNU_036    "Recherche a~rriäre     [Ctrl-]"
    #define MNU_037    "Rem~placer..."
    * #define MNU_035    "~Continuer recherche [Shift-F4]"
  #endif
  #define MNU_010  "~Vue"
  #ifdef DEF_FILTER
  #define MNU_013    "Condition ~filtre...   [Sh-F11]"
  #endif
  #define MNU_014    "SÇlectionner ~Vue...      [F11]"
  #define MNU_015    "DÇpl. col. Ö ~gauche  [Ctrl-F7]"
  #define MNU_016    "DÇpl. col. Ö ~droite  [Ctrl-F8]"
  #define MNU_018    "~Pleine-page/Liste [Ctrl-Enter]" // + KEYTEXT_FULLSCREEN
  #define MNU_019    "I~mport de donnÇes...          "
  #define MNU_020    "E~xport de donnÇes...          "
  // #define MNU_021    "~Mise Ö jour de donnÇes...     "
  #define MNU_022    "~Rafraåchir            [Alt-F5]"
  //
  #define TXT_022   "Validation en cours"
  static TXT_023 := "Tapez [Escape] pour interrompre"
  static TXT_024 :=  " enregistrement(s)"
  #define TXT_025   "Condition de filtrage"
  #define TXT_027  "Filtre:"
  #define TXT_030  "Recherche en cours..."
  #define TXT_031  "Imprimer Liste"
  #define TXT_032  "Titre"
  #define TXT_033  "Page "
  #define TXT_034  "(aucun)"
  * #define MSG_ISOPEN_1 " : cette fenàtre est dÇjÖ ouverte."
  * #define MSG_ISOPEN_2 "Continuer quand-màme (O/N) ?"
  * static MSG_FLTBLOCK := "(Le filtre sera dÇsactivÇ)"
#endif

#ifdef LG_GERMAN
  #define MSG001  " (Vollbild)"
  #define MSG002  "Positionieren : "
  #define MSG003  "Dieser Datensatz wird durch den Filter versteckt sein."
  #define MSG004  " Text der Memo-Felder ebenfalls drucken"
  #define MSG005  "Sortierfolge"
  #define MSG006  "~Spezial"
  * #define MSG007  "(Kein Filter)"
  *#define MSG008  "Filter auswÑhlen"
  *#define MSG009  "DatenbrÅche anzeigen fÅr "
  *#define MSG010  "EingeschrÑnkte Demo-Version! Keine neuen Records mîglich."
  #define MSG011  "Kolonnen 1 bis "
  *#define MSG013  "Hilfe"
  *#define MSG014   " Formatieren fÅr Export"
  *#define MSG015  " Zeichen"
  #ifdef DEF_HELP
    #define MSG016    " [Alt] MenÅ [Alt-F1] Hilfe"
  #else
    #define MSG016    " [Alt] MenÅ "
  #endif
  #define MSG017    " [F10] Ende"
  #define MSG018  " Keine Records drucken; nur DatenbrÅche"
  #define MSG019  " Dokumentmaske benutzen..."
  #define MSG020    " [Enter] Auswahl"
  #define MSG_INS_DEL  " [Ins] EinfÅgen [Del] Lîschen"
  *
  #define MSG_001  "Dies ist der erste Record der Liste."
  #define MSG_002  "Dies ist der letzte Record der Liste."
  #define MSG_004  "Ihre Angaben sind ungÅltig und kînnen so nicht stehen bleiben:"
  * #define MSG_005  "DrÅcken Sie J um dennoch zu beenden :"
  #define MSG_006  "Vorgang wurde abgebrochen."
  #define MSG_011  "Neuer Record."
  #define MSG_012  "ZÑhlvorgang lÑuft..."
  *
  #define MSG_EDIT  "EINGABE"
  #define MSG_PICK  "AUSWAHL"
  #define MSG_SRCH  "SUCHEN"
  #define MSG_SHOW  "ANZEIGE"
  * #define MSG_VIEW  "VIEW"
  #define MSG_FIND  "POSIT"
  *
  #define MNU_001  "~Datei"
  #define MNU_002  "~Liste drucken  [Shift-F7]"
  #define MNU_017  "~Record drucken       [F7]"
  #define MNU_019    "Daten i~mportieren...     "
  #define MNU_020    "Daten e~xportieren...     "
  // #define MNU_021    "Daten ~anpassen...        "
  #ifdef DEF_GIMMICK
    #define MNU_003    "~ZÑhlen                   "
    #define MNU_004    "~PrÅfen                   "
  #endif
  #define MNU_109    "~Archiv wÑhlen...         "
  #define MNU_005    "Be~enden             [F10]"
  #define MNU_006  "~Record"
  #define MNU_011    "~Bearbeiten          [F3]"
  #define MNU_007    "~Lîschen         [Delete]"
  #define MNU_008    "~EinfÅgen        [Insert]"
  #define MNU_PASTE  "öber~nehmen          [F2]"
  #ifdef DEF_SEEK
    #define MNU_009    "Suche ~vorwÑrts  [Ctrl-]"
    #define MNU_036    "Suche ~rÅckwÑrts [Ctrl-]"
    #define MNU_037    "Er~setzen..."
    * #define MNU_035    "~Wiederholen   [Shift-F4]"
  #endif
  #define MNU_010  "~Ansicht"
  #ifdef DEF_FILTER
  #define MNU_013    "~Filter setzen...    [Sh-F11]"
  #endif
  #define MNU_014    "~Ansicht...             [F11]"
  #define MNU_015    "Spalte ~links       [Ctrl-F7]"
  #define MNU_016    "Spalte ~rechts      [Ctrl-F8]"
  #define MNU_018    "~Vollbild/Browse [Ctrl-Enter]"
  #define MNU_022    "~Aktualisieren       [Alt-F5]"
  //
  #define TXT_022   "PrÅfvorgang lÑuft..."
  static TXT_023 := "[Escape] um abzubrechen"
  static TXT_024 :=  " Record(s)"
  #define TXT_025   "Filterbedingung"
  #define TXT_027   "Filter:"
  #define TXT_030   "Suchvorgang lÑuft..."
  #define TXT_031   "Liste drucken"
  #define TXT_032   "Titel"
  #define TXT_033   "Seite "
  #define TXT_034   "(Keiner)"
  * #define MSG_ISOPEN_1 " : Fenster ist bereits offen."
  * #define MSG_ISOPEN_2 "Dennoch weitergehen (J/N) ?"
  * static MSG_FLTBLOCK := "(Filter wird dann aufgehoben)"
#endif

   
#ifdef LG_EN
  #define MSG001  " (Form View)"
  #define MSG002  "Quick search : "
  #define MSG004  " Text der Memo-Felder ebenfalls drucken"
  #define MSG005  "Sort order"
  #define MSG006  "~Special"
  #define MSG011  "Columns 1 to "
  #ifdef DEF_HELP
    #define MSG016    " [Alt] Menu [Alt-F1] Help"
  #else
    #define MSG016    " [Alt] Menu "
  #endif
  #define MSG017    " [F10] End"
  #define MSG020    " [Enter] Select"
  #define MSG_INS_DEL  " [Ins] Insert [Del] Delete"
  *
  #define MSG_001  "This is the first record."
  #define MSG_002  "This is the last record."
  #define MSG_004  "Your data is invalid, we cannot leave them like this:"
  #define MSG_006  "User aborted."
  #define MSG_011  "New record."
  #define MSG_012  "ZÑhlvorgang lÑuft..."
  #define MNU_001  "~File"
  #define MNU_002  "Print ~List     [Shift-F7]"
  #define MNU_017  "Print ~Record         [F7]"
  #define MNU_019    "I~mport data...           "
  #define MNU_020    "E~xport data...           "
  // #define MNU_021    "~Update data...           "
  #ifdef DEF_GIMMICK
    #define MNU_003    "~Count records            "
    #define MNU_004    "~Validate all records     "
  #endif
  #define MNU_109    "~Select archive...        "
  #define MNU_005    "~Quit                [F10]"
  #define MNU_006  "~Record"
  #define MNU_011    "~Edit                [F3]"
  #define MNU_007    "~Delete          [Delete]"
  #define MNU_008    "~Insert          [Insert]"
  #define MNU_PASTE  "öber~nehmen          [F2]"
  #ifdef DEF_SEEK
    #define MNU_009    "Search ~forward  [Ctrl-]"
    #define MNU_036    "Search ~backward [Ctrl-]"
    #define MNU_037    "Find & ~Replace..."
    * #define MNU_035    "~Wiederholen   [Shift-F4]"
  #endif
  #define MNU_010  "~View"
  #ifdef DEF_FILTER
  #define MNU_013    "Select ~filter...    [Sh-F11]"
  #endif
  #define MNU_014    "Select ~View            [F11]"
  #define MNU_015    "Move column ~left   [Ctrl-F7]"
  #define MNU_016    "Move column ~right  [Ctrl-F8]"
  #define MNU_018    "~Form/Browse     [Ctrl-Enter]"
  #define MNU_022    "~Refresh screen      [Alt-F5]"
  //
  #define TXT_022   "Validation..."
  static TXT_023 := "[Escape] to abort"
  static TXT_024 :=  " record(s)"
  * #define TXT_025   "Filterbedingung"
  * #define TXT_027   "Filter:"
  * #define TXT_030   "Suchvorgang lÑuft..."
  #define TXT_031   "Liste drucken"
  #define TXT_032   "Title"
  * #define TXT_033   "Page "
  * #define TXT_034   "(Keiner)"
  * #define MSG_ISOPEN_1 " : window is already open."
#endif


*#ifdef __XPP__
*
*CLASS MyTBrowse FROM TBrowse
*   EXPORTED:
*   // VAR skipBlock is skipBlock in TBrowse assignment exported
*   // VAR cargo assignment exported
*   // ACCESS ASSIGN VAR skipBlock
*   VAR colpos, rowpos
*
*   INLINE ACCESS ASSIGN METHOD colpos( n )
*       LOCAL x
*       IF n != NIL
*          DispBegin()
*          ::panHome()
*          ::Tbrowse:colpos := n
*          FOR x := 2 TO n
*             ::right()
*          NEXT x
*          DispEnd()
*       ENDIF
*    RETURN( ::Tbrowse:colpos )
*
*    INLINE ACCESS ASSIGN METHOD rowpos( n )
*       LOCAL x
*       IF n != NIL
*          DispBegin()
*          ::Tbrowse:rowPos := n
*          ::_currentRow    := n // internal instance variable, not
*                                // to be documented, use at your own risc
*          ::stabilize()
*          DispEnd()
*       ENDIF
*    RETURN( ::Tbrowse:rowpos )
*
*
**   INLINE ACCESS ASSIGN METHOD stabilize()
**      // workaround for PDR 4470
**      IF ::_currentRow == 0
**         ::rowPos      := 1
**         ::_currentRow := 1
**         ::_toSkip := 0
**         ::_state  := 1
**         ::stable  := .T.
**         ::Hilite()
**         RETURN .T.
**      ELSEIF ::_currentRow > ::rowCount
**         ::rowPos      := ::RowCount
**         ::_currentRow := ::RowCount
**         ::_toSkip := 0
**         ::_state  := 1
**         ::stable  := .T.
**         ::Hilite()
**         RETURN .T.
**      ENDIF
**   RETURN ::TBrowse:stabilize()
*
*ENDCLASS
*
*#endif __XPP__

   
**
** PROCEDURE_SECTION  - (...grins)
**

**
**
FUNCTION ddEdit( ad, ;
                 lNoConfirm, ;
                 nMode, ;
                 nStart, ;
                 bCreate, ;
                 bPreEdit, ;
                 aActions, ;
                 xlFilter, ;
                 cKeyValue , ;
                 cLegend, ;
                 cIdQry, ;
                 xcKey, ;
                 bPickOrder , bStatus, ;
                 lFull, bOnIdle, ;
                 cTitle, cHelp, ;
                 cColor, ;
                 lHeaders,;
                 aWindow, ;
                 bBrowseWait, ;
                 bBefore, bAfter, ;
                 cStart, ;
                 lNew, ; // should the postedit method be evaluated?
                 aRecnos ;
               )
local i
local cLeg
local nCursor := setcursor(SC_NONE)
local oOldBrowse  := soBrowse
local aData  := saData
local cOldLeg     := scLeg
local lOldAppMode := slIsEof
local lMustScan := slMustScan
local cIdFlt := scIdFlt
local bSaveCreate := ad[AD_CREATE]
local bOnIdleSave := sbOnIdle
local bSavePreEdit := ad[AD_PREEDIT]
local nSaveRequest := snRequest
local nSaveRecStat := snRecStat
local lSaveCanSkip := slCanSkip
local bSaveKeyBlock := sxcKey
local cSaveKeyValue := scKeyValue
local bSaveFltBlock := sxlFilter
local cSaveFltText  := scFltText
local nSaveMode   := snMode
local nSaveStart  := snStart
local lModify     := slModify
local aKeyStack   := saKeyStack
local lSaveNoConfirm  := slNoConfirm
local bSaveStatus := sbStatus
local bOldBefore := sbBefore
local bOldAfter  := sbAfter
local aSaveBar := saBar
local qry
local aSaveQry := CurQry()
local nSkipOffset := snSkipOffset
local nCellHeight := snCellHeight
local aSaveRecnos := saRecnos
local nSaveRecno := snRecno
saRecnos := aRecnos
if aRecnos != NIL
  * SetMsg("Displaying "+ntrim(len(aRecnos))+" rows.")
  snRecno := min(1,len(aRecnos))
endif
* local bSearchFormat := sbSearchFormat
default lNoConfirm to .f.
default lHeaders to .t.
slNoConfirm  := lNoConfirm
sbOnIdle := bOnIdle
sbStatus := bStatus
sbBefore := bBefore
sbAfter  := bAfter
* #ifdef __XPP__
*   soBrowse := MyTBrowse()
* #else
  soBrowse := TBrowseDB()
* #endif
* 20070308 soBrowse:cargo  := ad
saData  := ad
default nMode to DDMODE_EDIT
snMode := nMode
* snCellHeight := 0
default cIdQry to ad[AD_NAME]
qry := QryLoad(saData,cIdQry)
slSumActive := ! (QRYATTR_S $ qry[QRY_ATTRIB])
snCellHeight := qry[QRY_CELLHEIGHT]
soBrowse:skipBlock     := {|n,x| Skipper( n, snCellHeight, .t. ) }
soBrowse:goTopBlock    := {|x| KeyGoTop(scKeyValue,sxcKey,sxlFilter)}
soBrowse:goBottomBlock := {|x| KeyGoBottom(scKeyValue,sxcKey,sxlFilter) }
snSkipOffset := 0
default cHelp to (qry[QRY_HELP])
cHelp := cHelp
slMustScan := .t.
** Nicht vergessen : ddSetKey() kann u.U. ein weiteres ddEdit()
** aktivieren, wenn z.B. qry[QRY_KEYVALUE] DbfPick() aufruft.
if ddSetKey(qry,cKeyValue,xcKey,xlFilter)
  if len(WinStack()) < 20  .or. Confirm( ;
      "Sie haben schon "+ntrim(len(WinStack()))+" Fenster offen.", ;
      "Trotzdem noch ein Fenster îffnen (J/N) ?", MSG_NO, "WRN054"  ;
    )
    * 20070505
    default nStart to 0
    snStart := nStart
    * raus am 20071004
    if snStart == DDSTART_TOP // .or. saRecnos != NIL
      eval(soBrowse:goTopBlock)
    elseif snStart == DDSTART_BOTTOM
      eval(soBrowse:goBottomBlock)
      soBrowse:rowPos := soBrowse:rowCount
    * else
    *   slIsEof := eof() // War bis 20070518 weiter unten
    endif
    slIsEof := eof().or.bof() // War bis 20070518 weiter unten
    if qry[QRY_TITLE] != NIL
      cTitle := xparse(qry[QRY_TITLE])
    endif
    if aWindow == NIL
      open window (cTitle) ;
                  size qry[QRY_WINDOW][WIN_HEIGHT], ;
                       qry[QRY_WINDOW][WIN_WIDTH] ;
                  home qry[QRY_WINDOW][WIN_TOP],;
                       qry[QRY_WINDOW][WIN_LEFT] ;
                  help (cHelp) ;
                  permanent (snMode == DDMODE_WAIT)
    else
      open window (cTitle) ;
                  size aWindow[WIN_HEIGHT],aWindow[WIN_WIDTH]  ;
                  home aWindow[WIN_TOP],aWindow[WIN_LEFT] ;
                  frame NOFRAME ;
                  color (iif(snMode == DDMODE_WAIT,CfgWaitColor(),NIL)) ;
                  permanent (snMode == DDMODE_WAIT)
    endif
    ddWinAdapt(soBrowse)
    if qry[QRY_COLSEP] == NIL
      soBrowse:headSep := "¬ƒ"
      soBrowse:colSep  := "≥"
    else
      soBrowse:headSep := substr(qry[QRY_COLSEP],2,2)
      soBrowse:colSep  := left(qry[QRY_COLSEP],1)
      ** [960919] Standardwert in .qry fÅr colsep wÑre also "≥¬ƒ" !
    endif
    if ! lHeaders
      soBrowse:headSep := ""
    endif
    if snMode == DDMODE_WAIT
      soBrowse:autoLite := .f.
    else
      soBrowse:nBottom -= qry[QRY_BOTTOM]
      soBrowse:nRight  -= qry[QRY_RIGHT]
    endif
    if qry[QRY_CLRSPEC] != NIL
      soBrowse:colorSpec := qry[QRY_CLRSPEC]
    endif
    // xbase++ :
    // oTBrowse:nTop:=<n> :configure() must be subsequently executed
    // soBrowse:configure() // neu seit 20070307
    * slAllowAppend := .t. // lAllowAppend
    * sbPickOrder := bPickOrder
    * default sbPickOrder to {|o| PickOrder(o)}
    saBar := NIL
    **
    if bCreate  != NIL   ; ad[AD_CREATE] := bCreate   ; endif
    * if bDelete  != NIL   ; ad[AD_DELETE] := bDelete   ; endif
    if bPreEdit != NIL   ; ad[AD_PREEDIT] := bPreEdit   ; endif
    slModify := .F.
    default lFull to .f.
    if lNew
      snRecStat := RS_UNKNOWN
    else
      snRecStat := RS_VALID
    endif
    ad[AD_UPDATED] := .F.
    sbGotoBlock := NIL
    if qry[QRY_LEGEND] == NIL
      if cLegend != NIL
        scLeg := cLegend
      else
        scLeg := MSG016
        if snMode == DDMODE_PICK
          scLeg += MSG020
        else
          scLeg += MSG017
        endif
        if snMode != DDMODE_SHOW
          scLeg += MSG_INS_DEL
        endif
      endif
    endif
    //
    if lFull
      * seit 20070518 nach oben: slIsEof := eof()
      * slIsEof := eof()
      snRequest := DDEDIT_PAGE
    else
      dispbegin() // dispend()
      ddQryAddColumns(ad,qry,lHeaders)
      snRequest := DDEDIT_BROWSE
      * seit 20070518 nach oben: slIsEof := .f.
      QuickStabilize()
      if snStart == DDSTART_TOP // .or. saRecnos != NIL
        * soBrowse:rowPos := 1
        soBrowse:goTop() // 20070307-20070323
        * eval(soBrowse:goTopBlock)
      elseif snStart == DDSTART_BOTTOM
        #ifdef __XPP__
        soBrowse:rowPos := soBrowse:rowCount
        * soBrowse:goBottom() // 20071004
        #else
        soBrowse:goBottom()
        soBrowse:forceStable()
        #endif __XPP__
      elseif saRecnos == NIL
        if cStart != NIL
          softseek cStart
        endif
        if eof() .or. bof() .or. ! ddCheckWhile()
          * soBrowse:goTop() // 20070307
          eval(soBrowse:goTopBlock)
        else
          do while ! &sxlFilter
            skip
            if eof() .or. bof() .or. ! ddCheckWhile()
              slIsEof := .t.
              // soBrowse:goTop() // 20070307
              eval(soBrowse:goTopBlock)
              exit
            endif
          enddo
          * if as before 20030501 ...
          *  soBrowse:rowPos := soBrowse:rowCount
          * else
            * setrowpos(soBrowse,1)
            soBrowse:rowPos := 1
          * endif
          * soBrowse:configure() 20070309 ?
          * ddRefreshAll()
        endif
      else
        soBrowse:goTop() // 20071004
      endif
      * #ifdef __XPP__
      * soBrowse:forceStable()
      * #endif __XPP__
      *if snRequest == DDEDIT_BROWSE
      *  soBrowse:forceStable()
      *endif
      ddRefreshAll()
      dispend() // dispbegin()
      * confirm("rowPos after ddRefreshAll() is " + ntrim(soBrowse:rowPos))
    endif
    #ifdef DEF_SEEK
      ddSeekReset()
    #endif
    if snMode != DDMODE_WAIT
      * if qry[QRY_LEGEND] == NIL
      *   SayLeg(scLeg)
      * endif
      ddSayStatus()
    endif
    **
    if lFull
      ddPage( WinTitle() + MSG001 , qry, NIL, .f. )
    else
      ddBrowse(qry)
    endif
    **
    #ifdef DEF_SEEK
      ddSeekReset()
    #endif
    if ad[AD_UPDATED]
      MsgDisplay("Commit...")
      dbcommit()
      MsgDisplay("")
    endif
    if snMode != DDMODE_WAIT
      snLastRequest := snRequest
    endif
    close window
  endif // winisopen()
endif // ddSetKey()
setcursor(nCursor)
ad[AD_PREEDIT]  := bSavePreEdit
ad[AD_CREATE]   := bSaveCreate
* ad[AD_DELETE]   := bSaveDelete
saKeyStack := aKeyStack
slModify := lModify
snStart  := nSaveStart
snMode   := nSaveMode
sbStatus := bSaveStatus
sbOnIdle := bOnIdleSave
sbBefore := bOldBefore
sbAfter  := bOldAfter
snRecStat := nSaveRecStat
slCanSkip := lSaveCanSkip
snRequest := nSaveRequest
sxcKey := bSaveKeyBlock
sxlFilter := bSaveFltBlock
scFltText  := cSaveFltText
scKeyValue := cSaveKeyValue
soBrowse := oOldBrowse
saData := aData
saBar  := aSaveBar
scLeg  := cOldLeg
slMustScan := lMustScan
slIsEof      := lOldAppMode
* slHitBottom := lHitBottom
* sbPickOrder := bOldChgOrd
QryRestore(aSaveQry)
snSkipOffset := nSkipOffset
snCellHeight := nCellHeight
slNoConfirm := lSaveNoConfirm
* sbSearchFormat := bSearchFormat
scIdFlt := cIdFlt
saRecnos := aSaveRecnos
snRecno := nSaveRecno
RETURN snLastRequest


PROCEDURE QuickStabilize()
#ifdef __XPP__
local lMustScan := slMustScan
slMustScan := .f.
soBrowse:forceStable()
slMustScan := lMustScan
* soBrowse:configure()
* soBrowse:refreshAll()
* soBrowse:invalidate()
#endif __XPP__
RETURN


FUNCTION ddWinAdapt(b)
b:nTop  := WinTop()
b:nLeft := WinLeft()
b:nRight := WinEndX()
b:colorSpec := setcolor()
if WinIsFull()
  b:nBottom   := WinEndY() - 3
  b:footSep := "¡ƒ"
else
  b:nBottom   := WinEndY()
  b:footSep := ""
endif
// b:configure() // neu hier seit 20070307
RETURN NIL

FUNCTION CanSkip()
RETURN .f. if snRecStat != RS_VALID
RETURN slCanSkip

**
** ddBrowse()
** Initial copy came from tbdemo.prg.
**
STATIC FUNCTION ddBrowse(qry)
local nKey := 0
local nCreate
local i
if qry[QRY_FREEZE] != NIL
  soBrowse:freeze := qry[QRY_FREEZE]
endif
if snMode == DDMODE_EDIT
  if &(soBrowse:getColumn(1):cargo[COL_SKIPBLOCK])
    ddSettle()
  endif
endif
do while snRequest == DDEDIT_BROWSE .or. snRequest == DDEDIT_PAGE
  if snRequest == DDEDIT_PAGE
    ddPage( WinTitle() + MSG001 , qry, NIL, .t. )
    ddRefreshAll()
    loop
  endif
  * raus am 20071113 : nKey := ddNextKey() // neu seit 20070921
  ** raus am 20070921 (spÑter wieder rein) :
  #define DEF_GASTON
  #ifdef DEF_GASTON
  if snRequest == DDEDIT_BROWSE
    if (nKey := ddNextKey()) == 0
      do while (nKey := WaitKeySet(0)) == 0
        * raus am 20071009
        * if snRequest == DDEDIT_ESCAPE  // 980624
        *   nKey := K_ESC
        *   exit
        * endif
        if soBrowse:stabilize()
          if snSkipOffset != 0
            soBrowse:up()
          else
            if qry[QRY_LEGEND] == NIL
              SayLeg(scLeg)
            else
              SayLeg(xparse(qry[QRY_LEGEND]))
            endif
            exit
          endif
        endif
      enddo
    endif
  endif
  #endif DEF_GASTON
  #ifdef DEF_PURZEL
    PurzelStop()
  #endif
  if snMode == DDMODE_WAIT
    if nKey != 0
      PushKey(nKey) // nKey := WaitKeySet()
    endif
    snRequest := DDEDIT_ESCAPE
    RETURN NIL // nKey
  endif
  #ifdef DEF_MOUSE
    mouse_mon()
  #endif
  if nKey == 0
    ** loop did exit because screen is stable; no key was pressed
    // neu seit 20070921 :
    soBrowse:forceStable()
    * if qry[QRY_LEGEND] == NIL
    *   SayLeg(scLeg)
    * else
    *   SayLeg(xparse(qry[QRY_LEGEND]))
    * endif
    // Ende neu seit 20070921
    * if snRecStat == RS_VALID
    if CanSkip()
      if Searching()
        QuickRefresh() // ddRefreshAll()
        loop
      endif
    endif
    ddQryWait(qry)
    * 20070524 if slModify .and. ! slIsEof
    if slModify .and. ! eof() .and. ! bof()
      DoGet()
      loop
    else
      nKey := WaitKeySet(NIL,sbOnIdle)
    endif
  endif
  * LogConsole("ddbrowse.prg processes key "+ntrim(nKey))
  #ifdef DEF_MOUSE
    mouse_moff()
  #endif
  *if nKey == K_SPACE .and. saPick != NIL
  *  ForceStable()
  *  Searching()  // fÅr flinke Finger
  *  ddRecSelect()
  *  loop
  *endif
  * 20070524 if snMode != DDMODE_EDIT .and. !slIsEof .and. soBrowse:colPos == 1
  if snMode != DDMODE_EDIT ;
      .and. !eof() .and. !bof() ;
      .and. soBrowse:colPos == 1 ;
                           .and. !slModify
    // 19980930 : Wenn man in PlsMbrEdit() auf dem letzten Record in der
    // ersten Kolonne eine Partnernummer direkt eingab, dann wurde
    // zuerst ddCreate() korrekt aufgerufen, aber danach wurde die erste
    // Position der Partnernummer durch ddActiveSearch() verschluckt.
    // Deshalb muss auch auf slModify getestet werden.
    if ddActiveSearch(nKey)
      loop
    endif
  endif
  **
  ** process keystrokes
  **
  if nKey == K_RIGHT .or. nKey == K_TAB
    if soBrowse:colPos == soBrowse:colCount
      Alarm()
    else
      soBrowse:right()
    endif
  elseif ( nKey == K_LEFT ) .or. nKey == K_SH_TAB
    if soBrowse:colPos == 1
      Alarm()
    else
      soBrowse:left()
    endif
  #ifdef DEF_LAYOUT
    elseif ( nKey == K_ALT_F10 )
      if USRATTR_C $ UsrAttrib()
        QryEdit(soBrowse,saData,CurQry())
        ddQryReset()
      endif
  #endif
  elseif nKey == K_ENTER .and. snMode == DDMODE_EDIT
    ddSettle()
    soBrowse:refreshCurrent()
  * 20070524 elseif nKey == K_ENTER .and. soBrowse:stable .and. slIsEof
  elseif nKey == K_ENTER .and. soBrowse:stable.and.eof()
    if snMode != DDMODE_FIND
      ddCreate()
    endif
  elseif nKey == K_ENTER .and. snMode == DDMODE_PICK
    * 20030301 if snRecStat != RS_VALID
    if snRecStat == RS_UNKNOWN
      if ddRecLock()
        ddPostEdit()
        unlock record
        ddChkWhile()
      endif
    endif
    if CanSkip()
    * if snRecStat == RS_VALID
      ForceStable()
      Searching()  // fÅr flinke Finger
      snRequest := DDEDIT_EXIT
    endif
  * changed 20061011 : Enter in VenVenEdit() soll auch die MSK anzeigen.
  elseif nKey == K_ENTER .and. CurQry(QRY_IDMSK) != NIL
  * elseif nKey == K_ENTER .and. snMode == DDMODE_FIND ;
  *        .and. CurQry(QRY_IDMSK) != NIL
    ForceStable()
    snRequest := DDEDIT_PAGE
  elseif ( nKey > 31 .and. nKey <= 255 ) .or. nKey == K_F1 ;
                                         .or. nKey == K_CTRL_INS ;
                                         .or. nKey == K_ALT_INS
    if snMode == DDMODE_EDIT .or. snMode == DDMODE_PICK ;
                             .or. snMode == DDMODE_FIND
      PushKey(nKey)
      * 20070524 if slIsEof
      if eof().or.bof()
        if ! ddCreate()
          UndoKey(nKey) // falls das READ nicht zustande kommt...
        endif
      else
        if ! DoGet()
          UndoKey(nKey) // falls z.B. create oder edit nicht erlaubt wÑre
        endif
      endif
    endif
  elseif ( nKey == K_HOME ) ; soBrowse:home()
  elseif ( nKey == K_END )
    if soBrowse:colcount == 1
      if CanSkip()
      * if snRecStat == RS_VALID
        soBrowse:goBottom()
      else
        Alarm()
      endif
    else
      #ifdef __XPP__
        soBrowse:_end()
      #else
        soBrowse:end()
      #endif
    endif
  elseif ( nKey == K_CTRL_HOME )  ; soBrowse:panHome()
  elseif ( nKey == K_CTRL_END )   ; soBrowse:panEnd()
  elseif ( nKey == K_CTRL_LEFT )  ; soBrowse:panLeft()
  elseif ( nKey == K_CTRL_RIGHT ) ; soBrowse:panRight()
  *
  ELSE // user wants to leave current record
    PreSkip()
    if nKey == K_ESC
      * LogConsole("nKey == K_ESC")
      * 20070524 if slIsEof
      if eof().or.bof()
        snRequest := DDEDIT_ESCAPE
        * LogConsole("ddedit.prg:911")
      elseif snRecStat == RS_VALID
        * LogConsole("snRecStat == RS_VALID")
        if eval(saData[AD_PREEXIT])
          snRequest := DDEDIT_ESCAPE
        endif
      elseif slNoConfirm
      * .or. Confirm( MSG_004, ;
      *  MsgRecDelete(), MSG_NO, "WRN012" ;
      *)
        ddEditDelete()
      else
        AppTerminate(.f.)
        Warning(MSG_004+CR_LF+SetMsg(),utrp(;
          "Correct your modifications or delete the record!",;
          "Beheben Sie die Fehler oder lîschen Sie den Datensatz!",;
          "Corrigez les donnÇes ou supprimez l'enregistrement!"))
      endif
    #ifdef DEF_MOUSE
      elseif nKey == K_MOUSE_EVENT  ; ddMouseEvent(soBrowse)
    #endif
    elseif nKey == K_DOWN
      if CanSkip() // if snRecStat == RS_VALID
        QuickStabilize()
        for i := 0 to snCellHeight
          soBrowse:down()
        next i
      else
        Alarm()
      endif
    elseif nKey == K_UP
      if CanSkip() // if snRecStat == RS_VALID
        QuickStabilize()
        * if slIsEof
        *   slIsEof := .f.
        *   b:goBottom()
        * else
          for i := 0 to snCellHeight
            soBrowse:up()
            QuickStabilize()
            * #ifdef __XPP__
            * soBrowse:forceStable()
            * #endif __XPP__
          next i
        * endif
      else
        Alarm()
      endif
    * 20070524 elseif nKey == K_PGDN .and. ! slIsEof
    elseif nKey == K_PGDN .and. !eof()
      if CanSkip() // if snRecStat == RS_VALID
        soBrowse:pageDown()
      else
        Alarm()
      endif
    elseif nKey == K_CTRL_PGDN
      if CanSkip() // if snRecStat == RS_VALID
        soBrowse:goBottom()
      else
        Alarm()
      endif
    elseif nKey == K_PGUP
      if CanSkip() // if snRecStat == RS_VALID
        * 19980722 Rudi : BBL 980006
        * if slIsEof
        *   slIsEof := .f.
        *   eval(b:goBottomBlock)
        * endif
        soBrowse:pageUp()
      else
        Alarm()
      endif
    elseif nKey == K_CTRL_PGUP
      if CanSkip() // if snRecStat == RS_VALID
        slIsEof := .f.
        soBrowse:goTop()
      else
        Alarm()
      endif
    elseif nKey != 0
      ForceStable()
      if ddDoCommand( nKey )
        slIsEof := eof().or.bof() // (recno() == lastrec() + 1)
      elseif nKey == K_ENTER
        if CurQry(QRY_IDMSK) != NIL
          snRequest := DDEDIT_PAGE
        else
          ddSettle()
          if snCellHeight == 0
            soBrowse:refreshCurrent()
          else
            soBrowse:refreshAll()
          endif
        endif
      else
        Alarm()
      endif
    endif
  endif
enddo
snLastKey := nKey
RETURN NIL


**
** ddPage()
**
FUNCTION ddPage( cTitle, qry, bAfter, lNoPreExit )
local nKey
local ad := saData // soBrowse:cargo
local aSaveMsk := CurMsk()
local msk := MskLoad(ad,CurQry(QRY_IDMSK))
RETURN NIL if msk == NIL
* default lNoPreExit to .f.
open window (cTitle) color (CfgFullScreenColor()) ;
                     legend (scLeg) ;
                     help (msk[MSK_IDMSK]) ;
                     permanent (snMode == DDMODE_WAIT)
LogDebug(utos(saKeyStack))
if snMode != DDMODE_WAIT
  ddSayStatus()
endif
ScrPaint(msk)
do while snRequest == DDEDIT_PAGE // .or. lOnce
  * 19980626 if snRecStat == RS_UNKNOWN
  if CanSkip() // if snRecStat == RS_VALID
    Searching()
  endif
  if slModify
    nKey := ddReadPage( msk )
  else
    FldFreshAll( msk, ad, .f. )
    ddQryWait(qry)
    if snMode == DDMODE_WAIT
      snRequest := DDEDIT_ESCAPE
      exit
    endif
    if qry[QRY_LEGEND] == NIL
      SayLeg(scLeg)
    else
      SayLeg(xparse(qry[QRY_LEGEND]))
    endif
    nKey := WaitKeySet(NIL,sbOnIdle)
    * 20070524 if snMode != DDMODE_EDIT .and. ! slIsEof
    if snMode != DDMODE_EDIT .and. ! eof() .and. ! bof()
      if ddActiveSearch(nKey)
        loop
      endif
    endif
  endif
  PreSkip()
  if nKey == K_ESC
    * 20070524 if slIsEof
    if eof().or.bof()
      snRequest := DDEDIT_BROWSE
    elseif snRecStat == RS_VALID
      if lNoPreExit .or. eval(saData[AD_PREEXIT])
        snRequest := DDEDIT_BROWSE
      endif
    else
      snRequest := DDEDIT_BROWSE
      * if slNoConfirm .or. Confirm( MSG_004, MsgRecDelete(), MSG_NO, "WRN012" )
      *   ddEditDelete()
      *   snRequest := DDEDIT_BROWSE
      * endif
    endif
  #ifdef DEF_LAYOUT
    elseif nKey == K_ALT_F10 .and. USRATTR_C $ UsrAttrib() ; ddLayout(ad)
  #endif
  elseif nKey == K_PGUP
    if CanSkip() // if snRecStat == RS_VALID
      * 20070524 if slIsEof
      if eof().or.bof()
        slIsEof := .f.
        // soBrowse:goBottom() // 20070307
        eval(soBrowse:goBottomBlock)
      * elseif eval(b:skipBlock,-(snCellHeight+1)) != -(snCellHeight+1)
      elseif Skipper(-1,0,.f.) != -1
        SetMsg(MSG_001)                   // hit top
      endif
      if (msk := ddMskReload(ad,msk)) == NIL ; snRequest := DDEDIT_BROWSE ; endif
    else
      Alarm()
    endif
  elseif nKey == K_PGDN
    * 20070524 if CanSkip() .and. ! slIsEof // if snRecStat == RS_VALID .and. ! slIsEof
    if CanSkip() .and. !eof() .and. !bof() // if snRecStat == RS_VALID .and. ! slIsEof
      if Skipper(1,0,.f.) != 1
        * if ! slIsEof
        *   goto lastrec() + 1
        *   slIsEof := .t.
        *   FldFreshAll( CurMsk(), b:cargo, slModify )
        * else
          SetMsg(MSG_002)
        * endif
      endif
      if (msk := ddMskReload(ad,msk)) == NIL ; snRequest := DDEDIT_BROWSE ; endif
    else
      Alarm()
    endif
  elseif ( nKey > 31 .and. nKey <= 255 ) .or. nKey == K_F1
    if snMode == DDMODE_EDIT .or. snMode == DDMODE_PICK ;
                             .or. snMode == DDMODE_FIND
      * 20070524 if slIsEof // 960417 recno() == lastrec() + 1
      if eof().or.bof()
        PushKey(nKey)
        if ! ddCreate()
          UndoKey(nKey) // falls z.B. create oder edit nicht erlaubt wÑre
        endif
      endif
    endif
  elseif nKey == K_ENTER .and. snMode == DDMODE_PICK
    if CanSkip()
    * if snRecStat == RS_VALID
      snRequest := DDEDIT_BROWSE
    else
      Alarm()
    endif
  elseif nKey == K_CTRL_PGUP
    if CanSkip()
    * if snRecStat == RS_VALID // .and. lSkip
      // soBrowse:goTop() // 20070307
      eval(soBrowse:goTopBlock)
      if (msk := ddMskReload(ad,msk)) == NIL ; snRequest := DDEDIT_BROWSE ; endif
    else
      Alarm()
    endif
  elseif nKey == K_CTRL_PGDN
    if CanSkip()
    * if snRecStat == RS_VALID // .and. lSkip
      // soBrowse:goBottom() // 20070307
      eval(soBrowse:goBottomBlock)
      if (msk := ddMskReload(ad,msk)) == NIL ; snRequest := DDEDIT_BROWSE ; endif
    else
      Alarm()
    endif
  *elseif nKey == K_UP
  ** Wenn ich Pfeilnachoben drÅcke, will ich mehr von dem sehen, was
  ** oberhalb dem momentan sichtbaren Bereich steht, also wird der
  ** Bildschirm nach unten gescrollt.
  *  if MskScroll(-1)
  *    ScrPaint(msk)
  *    ph_refresh()
  *  else
  *    Alarm()
  *  endif
  *elseif nKey == K_DOWN
  *  if MskScroll(1)
  *    ScrPaint(msk)
  *    ph_refresh()
  *  else
  *    Alarm()
  *  endif
  elseif nKey != 0
    if ddDoCommand(nKey)
      slIsEof := eof().or.bof()
      // 20000504 if (msk := ddMskReload(ad,msk)) == NIL
      // wenn man die letzte VEN eines Journals gelîscht hatte,
      // kam eine Fehlermeldung, dass die MSK-Datei nicht existiert.
      * 20070524 if slIsEof .or. (msk := ddMskReload(ad,msk)) == NIL
      if eof().or. bof().or. (msk := ddMskReload(ad,msk)) == NIL
        snRequest := DDEDIT_BROWSE
      endif
    elseif nKey == K_ENTER
      ddEditChange(.t.)
    else
      Alarm()
    endif
  endif
enddo
close window
slModify := .F.
MskRestore(aSaveMsk)
RETURN NIL

STATIC FUNCTION ddMskReload(ad,msk)
local cIdMsk := msk[MSK_IDMSK]
local a
RETURN msk if left(CurQry(QRY_IDMSK),1) != "="
RETURN NIL if (a := MskLoad(ad,CurQry(QRY_IDMSK))) == NIL
if a[MSK_IDMSK] != cIdMsk
  WinCls()
  ddSayStatus()
  ScrPaint(a)
endif
RETURN a


*FUNCTION ddRecSelect()
*local i
*for i := 1 to len(saPick)
*  if saPick[i] == recno()
*    adel(saPick,i)
*    asize(saPick,len(saPick)-1)
*    ddRefreshCurrent()
*    RETURN NIL
*  endif
*next i
*aadd(saPick, recno())
*ddRefreshCurrent()
*RETURN NIL
*
*FUNCTION ddTagged()
*local i
*RETURN " " if saPick == NIL
*for i := 1 to len(saPick)
*  if saPick[i] == recno()
*    RETURN "˚"
*  endif
*next i
*RETURN " "

#ifdef LG_GERMAN
#define LEG_READ "[F3] oder [F10] Ende   [Escape] Abbrechen   [Alt-F1] Hilfe"
#else
#define LEG_READ "[F3] ou [F10] confirmer   [Escape] Abandon   [Alt-F1] Aide"
#endif

**
** ddReadPage()
**
STATIC FUNCTION ddReadPage( msk )
local ad := saData // soBrowse:cargo
local cLeg := SetLeg()
local aBuf
* 20070524 if slIsEof // 960417 recno() == lastrec() + 1
if eof().or.bof()
  slModify := .f.
  RETURN WaitKeySet(NIL,sbOnIdle)
endif
RETURN WaitKeySet(NIL,sbOnIdle) if ! ddOnPreEdit(ad)
RETURN WaitKeySet(NIL,sbOnIdle) if ! ddRecLock()
// 20000504 slModify := .f.
FldFreshAll( msk, ad, .t. )
SayLeg(LEG_READ)
ddBefore(ad)
setcursor(if(readinsert(),SC_INSERT,SC_NORMAL))
if DBFATTR_S $ ad[AD_ATTRIB]
  aBuf := CopyRec()
endif
ReadModal(GetList,NIL,NIL,msk) ; GetList := {} // 19980422
setcursor(SC_NONE)
SayLeg(cLeg)
if nKey == K_ENTER .or. nKey == K_F3 .or. nKey == K_F10 .or. nKey == K_ESC
  slModify := .F.
endif
* 20030301 if updated() .or. snRecStat == RS_NEW .or. lastkey() != K_ESC
if updated() .or. snRecStat == RS_UNKNOWN .or. lastkey() != K_ESC
  snRecStat := RS_UNKNOWN
  ddPostEdit()
  #ifdef DEF_CONSOLE
    if aBuf != NIL
      RecConsole(aBuf)
    endif
  #endif DEF_CONSOLE
endif
ddAfter()
unlock record
ddChkWhile()
if nKey == K_ENTER .or. nKey == K_F3 .or. nKey == K_F10 .or. nKey == K_ESC
  nKey := 0
endif
RETURN nKey


**
** ddDoCommand()
**
STATIC FUNCTION ddDoCommand(nKey)
RptLogDetail()
slModify := .f.
if nKey == K_F4
  nKey := K_ALT_S
                      #ifdef DEF_ALT
elseif nKey == K_ALT
  nKey := NIL
                      #endif DEF_ALT
endif
if saBar == NIL
  saBar := {}
  define menu MNU_001 in saBar
    #ifdef DEF_PRINT
    menu item MNU_002 block ddFilePrint() key K_SH_F7
    menu item MNU_017 block ddEditPrint() key K_F7 ;
                      when saData[AD_EDITPRINT] != NIL
    #endif DEF_PRINT
    #ifdef DEF_GIMMICK
      AddLine()
      menu item MNU_003 block ddFileCount()
      menu item MNU_004 block ddFileCheck()
    #endif
    menu item MNU_109 block ddFileArchive() ;
                      when CanSkip() // snRecStat == RS_VALID

    #ifdef DEF_IMPORT
      menu item MNU_020 block ddExport()
      * if USRATTR_E $ UsrAttrib()
        menu item MNU_019 block ddImport()
      * endif
    #endif DEF_IMPORT
    AddLine()
    menu item MNU_005 block ddFileExit() key K_F10
  define menu MNU_006 in saBar
    menu item MNU_007 block ddEditDelete() key K_DEL ;
                      when  snMode != DDMODE_SHOW .and. !eof().and. !bof()
                      * 20070524 when  snMode != DDMODE_SHOW .and. ! slIsEof
    menu item MNU_008 block ddEditAppend() key K_INS ;
                      when CanSkip() .and. snMode != DDMODE_SHOW
                      // snRecStat == RS_VALID ;
    // menu item MNU_PASTE block ddPaste() key K_F2
    menu item MNU_011 block ddEditChange().and.SetMnuDone() key K_F3
    #ifdef DEF_SEEK
      AddLine()
      menu item MNU_009 block ddEditForward() key K_CTRL_DOWN ;
                        when CanSkip()
      menu item MNU_036 block ddEditBack() key K_CTRL_UP ;
                        when CanSkip()
      #ifdef DEF_REPLACE
      menu item MNU_037 block ddEditReplace()  ;
                        when CanSkip()
      #endif
    #endif
  define menu MNU_010 in saBar
    * menu item MNU_012 block ddViewMode()
    * menu item MNU_014 block ddViewOrder() key K_CTRL_F10 ;
    menu item MNU_014 block ddViewQuery() key K_F11 ;
                      when CurQry(QRY_IDQRY) != "FLTPICK"
    #ifdef DEF_FILTER
    menu item MNU_013 block ddViewFilter() key K_SH_F11 ;
                      when CanSkip() // snRecStat == RS_VALID
    #endif
    AddLine()
    menu item MNU_015 block ddSwapLeft()  key K_CTRL_F7 ;
                      when snRequest == DDEDIT_BROWSE
    menu item MNU_016 block ddSwapRight() key K_CTRL_F8 ;
                      when snRequest == DDEDIT_BROWSE
    AddLine()
    menu item MNU_018 block ViewFull(.f.)  key K_CTRL_RET ;
                      when CurQry(QRY_IDMSK) != NIL
    menu item MNU_022 block ddRefreshAll()  ;
                      key K_ALT_F5 ;
                      when !eof().and.!bof()
                      * when ! slIsEof
  define menu MSG006 in saBar
  saBar[4][MI_SUBMENU] := saData[AD_ACTIONS]
  if saData[AD_IDMNU] != NIL
    MnuExec(saBar,saData[AD_IDMNU])
  endif
endif
if snRequest == DDEDIT_BROWSE
  // RETURN .f. if ! Confirm("nTop="+ntrim(soBrowse:nTop))

  RETURN hMenu( saBar, ;
    soBrowse:nTop - 1, ;
    soBrowse:nLeft, ;
    soBrowse:nRight, ;
    CfgEditMenuColor(), ;
    nKey ;
  )
endif
RETURN hMenu( saBar, 0, 0, maxcol(), CfgEditMenuColor(), nKey )


FUNCTION RecIsValid
RETURN .t. if snRecStat == RS_VALID
RETURN .f. if snRecStat == RS_INVALID // 20030301
RETURN .f. if eof().or.bof()
* 20070524 RETURN .f. if slIsEof
RETURN .f. if ! ddRecLock()
ddBefore()
ddPostEdit()
ddAfter()
unlock record
ddChkWhile()
RETURN (snRecStat == RS_VALID)

**
**
FUNCTION ddOnPreEdit(ad)
RETURN .f. if IsReadOnly(ad)
* if IsDlmPath(ad)...
* if ddIsPublic(ad)
*   if ! USRATTR_E $ UsrAttrib()
*     SetMsg(ad[AD_NAME]+MsgExpertOnly())
*     RETURN .f.
*   endif
* endif
RETURN .t. if ad[AD_PREEDIT] == NIL
RETURN .t. if eval(ad[AD_PREEDIT])
// #ifdef DEF_WRITE
RETURN .t. if USRATTR_W $ UsrAttrib()
// #endif
RETURN .f.

* FUNCTION ddIsPublic(ad)
* RETURN .f. // ad[AD_PATH] != DbPath() + "\"


FUNCTION MsgPreEdit
#ifdef LG_FRENCH
RETURN "Il est interdit de modifier cet enregistrement"
#endif
#ifdef LG_GERMAN
RETURN "Dieser Datensatz darf nicht bearbeitet werden."
#endif
#ifdef LG_EN
RETURN "It is not allowed to modify here."
#endif


**
**
STATIC FUNCTION ddActiveSearch(nKey)
* local nRecNo
* local c, c2
local c
static scString := ""
static snOldMode := NIL
local lMustSeekAgain := .F.
if nKey >= 32 .and. nKey <= 255
  if snMode != DDMODE_SEARCH     // entering search mode
    snOldMode := snMode
    snMode := DDMODE_SEARCH
    scString := chr(nKey)
  else
    scString += chr(nKey)
  endif
  lMustSeekAgain := .T.
elseif nKey == K_BS
  if snMode == DDMODE_SEARCH
    if len(scString) > 0
      scString := left( scString, len(scString) - 1 )
      lMustSeekAgain := .T.
    endif
  endif
else
  if snMode == DDMODE_SEARCH
    snMode := snOldMode           // leaving search mode
  endif
endif
if snMode == DDMODE_SEARCH
  c := eval( ;
    saData[AD_AINDEX][indexord()][AI_KEYFORMAT], ;
    scKeyValue + scString ;
  )
  if lMustSeekAgain
    sbGotoBlock := {|| dbseek(c,.t.)}
  endif
  SayMsg( MSG002 + scString + " [" + substr(c,len(scKeyValue)+1) + "] " )
  RETURN .T.
endif
* before 20041216 :
* if lMustSeekAgain
*   c2 := eval( ;
*     soBrowse:cargo[AD_AINDEX][indexord()][AI_KEYFORMAT], ;
*     scKeyValue + scString ;
*   )
*   sbGotoBlock := {|| dbseek(c2),.t.}
* endif
* if snMode == DDMODE_SEARCH
*   c := substr(eval( ;
*     soBrowse:cargo[AD_AINDEX][indexord()][AI_KEYFORMAT], ;
*     scKeyValue + scString ;
*   ),len(scKeyValue)+1)
*   SayMsg( MSG002 + scString + " [" + c + "] " )
*   RETURN .T.
* endif
RETURN .F.

FUNCTION save_recno()
RETURN iif(eof().or.bof(),NIL,recno())

FUNCTION rest_recno(nRecNo)
if nRecNo == NIL
  goto lastrec()+1
else
  goto nRecNo
endif
RETURN NIL

**
** Searching() : returns .t. if RefreshAll() requested
**
FUNCTION Searching()
local nRecNo := save_recno()
RETURN .f. if sbGotoBlock == NIL
eval(sbGotoBlock)
sbGotoBlock := NIL
RETURN .f. if nRecNo == recno()
* do while ! eval(sxlFilter)
do while ! &sxlFilter
  skip // ddSkip(1) // skip 20070519
  if ! ddCheckWhile()
    rest_recno(nRecNo)
    RETURN .f.
  elseif eof().or.bof() // 20070801 recno() == lastrec() + 1
    rest_recno(nRecNo)
    RETURN .f.
  endif
enddo
RETURN .t. if ddCheckWhile() .and. !eof() .and. !bof() // 20070801 recno() != lastrec() + 1
rest_recno(nRecNo)
RETURN .F.

* FUNCTION ddRefreshOnIdle(x)
* RETURN .t. if sbGotoBlock == NIL
* sbGotoBlock := {||ddRefreshAll()}
* RETURN .t.


**
** ddSwapLeft()
**
STATIC FUNCTION ddSwapLeft()
local col
if snRequest == DDEDIT_BROWSE
  if soBrowse:colPos > 1
    col := soBrowse:getColumn(soBrowse:colPos)
    soBrowse:setColumn(soBRowse:colPos,soBRowse:getColumn(soBRowse:colPos-1))
    soBRowse:colPos--
    soBRowse:setColumn(soBRowse:colPos,col)
    * soBRowse:refreshAll() // invalidate()
    soBRowse:invalidate()
  endif
endif
RETURN SetMnuDone()


**
** ddSwapRight()
**
STATIC FUNCTION ddSwapRight()
local col
if snRequest == DDEDIT_BROWSE
  if soBRowse:colPos < soBRowse:colCount
    col := soBRowse:getColumn(soBRowse:colPos)
    soBrowse:setColumn(soBrowse:colPos,soBrowse:getColumn(soBrowse:colPos+1))
    soBrowse:colPos++
    soBrowse:setColumn(soBrowse:colPos,col)
    * soBrowse:refreshAll() // invalidate()
    soBrowse:invalidate()
  endif
endif
RETURN SetMnuDone()

**
** ddEditChange()
**
FUNCTION ddEditChange(lNew)
default lNew to ! slModify
if snMode == DDMODE_SHOW
  Alarm()
  #ifdef DEF_WRITE
    if USRATTR_W $ UsrAttrib()
      slModify := lNew
    endif
  #endif
else
  slModify := lNew
endif
RETURN .t. // SetMnuDone() // 19990915


**
** DoGet()
**
STATIC FUNCTION DoGet()
local uNewVal
local i
local uIndexVal := NIL
local column := soBrowse:getColumn(soBrowse:colPos)
local fld,g
local nRow
local nCol
local lExitSave := Set(_SET_EXIT, .t.)
local lOkay := .t.
* local nRecNo
local aBuf
slModify := .F.
if COLATTR_R $ column:cargo[COL_ATTRIB]
  // inkey()
  // Warning(column:cargo[COL_HEADER] + MsgReadOnly())
  SetMsg(xstr(column:cargo[COL_HEADER]) + " : " + MsgReadOnly())
  RETURN .f.
endif
ForceStable()
if ! ddOnPreEdit(saData)
  Warning(MsgPreEdit(), SetMsg())
  RETURN .f.
endif
* nRecNo := recno()
RETURN .f. if ! ddRecLock()
if DBFATTR_S $ saData[AD_ATTRIB]
  aBuf := CopyRec()
endif
slModify := .f.
ddBefore(saData)
if ! empty(indexkey())
  uIndexVal := &(indexkey())
endif
if column:cargo[COL_FLDHANDLE] == 0
  lOkay := .f.
  * fld := GetNew(row()-snSkipOffset,col(),cblock(column[COL_BLOCK]))
  * if phRead({ fld }) == 0
  *   lOkay := .f. // die when-Klausel hat das Bearbeiten verboten
  * endif
else
  fld := saData[AD_FIELDS][column:cargo[COL_FLDHANDLE]]
  if COLATTR_Q $ column:cargo[COL_ATTRIB] // Quickpick
    uNewVal := eval(fld[AG_PICKBLK],"")
    if uNewVal != NIL
      eval(fld[AG_BLOCK],uNewVal)
      * fld:varPut(uNewVal) // unerklÑrter bug bei PickStreet() nach ParCreate
      * fld:updateBuffer()
      * if fld:postBlock <> NIL
      *   lOkay := eval(fld:postBlock, fld)
      *   fld:updateBuffer()
      * endif
    endif
  else
    g := ag2get(fld,row()-snSkipOffset,col(),column:cargo[COL_PICTURE])
    fld[AG_HEIGHT] := snCellHeight + 1
    fld[AG_WIDTH] := column:width
    if fld[AG_DOGET] == NIL
      if ReadModal({ g }) == 0
        lOkay := .f. // die when-Klausel hat das Bearbeiten verboten
      endif
    else
      eval(fld[AG_DOGET])
      if fld[AG_VALID] <> NIL
        lOkay := eval(fld[AG_VALID], g)
        fld:updateBuffer()
      endif
    endif
  endif
endif
Set(_SET_EXIT, lExitSave)
QuickStabilize()
* #ifdef __XPP__
* soBrowse:forceStable()
* #endif __XPP__
if lOkay
  if updated() .or. snRecStat == RS_UNKNOWN
  * 20030301 if updated() .or. snRecStat == RS_NEW
    snRecStat := RS_UNKNOWN
    ddPostEdit()
    * column:cargo[COL_BUFFER] := fld:VarGet()
    column:cargo[COL_BUFFER] := eval(fld[AG_BLOCK])
    slMustScan := .t.
  endif
endif
ddAfter() // 20051019 jetzt erst nach unlock record und Warning()
* if nRecNo!=recno()
*   Warning("recno() changed unexpectedly!")
* endif
unlock record
#ifdef DEF_CONSOLE
  if aBuf != NIL // "S" $ ad[AD_ATTRIB]
    RecConsole(aBuf)
  endif
#endif DEF_CONSOLE
ddChkWhile()
RETURN .f. if ! lOkay
if column:cargo[COL_ONEDIT] == NIL
  if nKey == K_ENTER .or. ( ;
    nKey > 31 .and. nKey < 255 .and. ! COLATTR_S $ column:cargo[COL_ATTRIB] ;
  )
    ddSettle()
  endif
  if snCellHeight != 0 .or. ( ;
                              ! empty(indexkey()) ;
                              .and. &(indexkey()) != uIndexVal ;
                              .and. ! eof() ; // 20070524 slIsEof
                              .and. ! bof() ;
                            )
    QuickStabilize()
    * #ifdef __XPP__
    *   soBrowse:forceStable()
    * #endif __XPP__
    ddRefreshAll()
  else
    soBrowse:refreshCurrent()
  endif
else
  for i := 1 to len(column:cargo[COL_ONEDIT])
    if ! &(column:cargo[COL_ONEDIT][i])
      Warning(SetMsg())
    endif
  next i
  ddRefreshAll()
endif
if nKey == K_DOWN     ; SendKey(nKey)
elseif nKey == K_UP   ; SendKey(nKey)
elseif nKey == K_TAB  ; SendKey(nKey)
elseif nKey == K_CTRL_PGDN  ; SendKey(nKey)
elseif nKey == K_CTRL_PGUP  ; SendKey(nKey)
#ifdef DEF_ALT
elseif nKey == K_ALT  ; SendKey(nKey)
#endif
endif
RETURN .t.

**
** ddPaste()
**
FUNCTION ddPaste
local i
local col
RETURN SetMnuDone() if snMode == DDMODE_SHOW
RETURN SetMnuDone() if snRequest != DDEDIT_BROWSE
* 20070524 if slIsEof // [960417]  recno() == lastrec() + 1
if eof().or.bof()
  RETURN SetMnuDone() if ! ddCreate()
  if ddRecLock()
    ddBefore()
    for i := 1 to soBrowse:colCount()
      col := soBrowse:getColumn(i)
      ColPaste(col:cargo)
    next i
    ddPostEdit()
    ddAfter()
    ddRefreshCurrent()
    unlock record
    ddChkWhile()
  endif
else
  if ddRecLock()
    ddBefore()
    col := soBrowse:getColumn(soBrowse:colPos)
    ColPaste(col:cargo)
    ddPostEdit()
    ddAfter()
    if ! &(col:cargo[COL_SKIPBLOCK])
      // 20000503 : wenn ich in Bemerkung (also auf einem Feld, das
      // normalerweise Åbersprungen wird) F2 drÅcke, dann soll er nicht
      // weiterspringen
      ddSettle()
    endif
    ddRefreshCurrent()
    unlock record
    ddChkWhile()
  endif
endif
RETURN SetMnuDone()

FUNCTION ColPaste(col)
local fld
RETURN NIL if col[COL_FLDHANDLE] == 0
RETURN NIL if ! COLATTR_P $ col[COL_ATTRIB]
fld := saData[AD_FIELDS][col[COL_FLDHANDLE]]
eval(fld[AG_BLOCK],col[COL_BUFFER])
* fld:VarPut(col[COL_BUFFER])
if fld[AG_VALID] != NIL
  eval(fld[AG_VALID])
*if fld:postblock != NIL
*  eval(fld:postblock)
endif
RETURN NIL

**
** ddSettle()
**
STATIC FUNCTION ddSettle()
local i
local col
* DebugWait("ddSettle()")
#ifdef __XPP__
  * QuickStabilize()
  soBrowse:forceStable()
  do while soBrowse:colPos < soBrowse:colCount
    soBrowse:right()
    QuickStabilize()
    * soBrowse:forceStable()
    col := soBrowse:getColumn(soBrowse:colPos)
    if ! &(col:cargo[COL_SKIPBLOCK])
      RETURN NIL
    endif
  enddo
#else
  for i := soBrowse:colPos + 1 to soBrowse:colCount
    col := soBrowse:getColumn(i)
    if ! &(col:cargo[COL_SKIPBLOCK])
      soBrowse:colPos := i
      soBrowse:refreshCurrent()
      RETURN NIL
    endif
  next i
#endif
** Jetzt ist der Cursor also in der letzten Kolonne angekommen und hat
** noch immer keinen Rastplatz gefunden.
** Also mÅssen wir zum nÑchsten Record rÅber und die Herbergs-Suche von
** vorne beginnen.
if CanSkip() // snRecStat == RS_VALID
  QuickStabilize()
  * soBrowse:forceStable()
  soBrowse:refreshCurrent()
  for i := 0 to snCellHeight
    soBrowse:down()
  next i
  soBrowse:forceStable()
  // ForceStable() benutzt dispbegin() und dispend()
  // [19980206]
  * while ( ! soBrowse:stabilize() ) ; end
  ** here again the "very special case" :
  * if soBrowse:hitBottom .and. ! slIsEof
  *   slHitBottom := .t.
  *   soBrowse:down()
  *   ForceStable()
  * endif
  #ifdef DEF_SETTLE
    for i := 1 to soBrowse:colPos - 1
      col := soBrowse:getColumn(i)
      if ! &(col:cargo[COL_SKIPBLOCK])
        #ifdef __XPP__
          soBrowse:panHome()
        #endif __XPP__
        soBrowse:forceStable()
        soBrowse:colPos := i
        soBrowse:refreshCurrent()
        soBrowse:forceStable()
        RETURN NIL
      endif
    next i
  #endif DEF_SETTLE
endif
RETURN NIL


#ifdef DEF_MOUSE

**
** ddMouseEvent()
**
*STATIC FUNCTION ddMouseEvent()
*LOCAL MouseFld
*LOCAL m_row, m_col, m_but
*local nCol, nWidth
*local nRow, i
*//
*// get mouse position
*mouse_mchk (@m_row, @m_col, @m_but)
*//
*// check for button 1
*if ( m_but == 1 )
*  if m_row >= soBrowse:nTop                    ;
*    .and. m_row <= soBrowse:nBottom            ;
*    .and. m_col >= soBrowse:nLeft              ;
*    .and. m_col <= soBrowse:nRight
*    nCol := soBrowse:leftVisible
*    nWidth := soBrowse:colWidth(nCol) + soBrowse:nLeft
*    do while nWidth < m_col
*      nCol++
*      nWidth += soBrowse:colWidth(nCol)
*      if nCol > soBrowse:rightVisible
*        exit
*      endif
*    enddo
*    do while nCol < soBrowse:colPos
*      soBrowse:left()
*    enddo
*    do while nCol > soBrowse:colPos
*      soBrowse:right()
*    enddo
*    nRow := row()
*    if nRow > m_row .and. snRecStat == RS_VALID       // let's move up
*      for i := 1 to (nRow - m_row)
*        soBrowse:up()
*      next i
*    elseif nRow < m_row .and. snRecStat == RS_VALID // let's move down
*      for i := 1 to (m_row - nRow)
*        soBrowse:down()
*      next i
*    endif
*    soBrowse:refreshAll()
*  endif
*endif
*RETURN NIL

#endif


**
** ddPostEdit()
**
FUNCTION ddPostEdit()
#ifdef MONKEY
  static snErrCount := 0
#endif
local ad := saData
* 20070524 if slIsEof // 960417 recno() == lastrec() + 1
if eof().or.bof() // 960417 recno() == lastrec() + 1
  snRecStat := RS_VALID
  RETURN NIL
endif
ad[AD_UPDATED] := .t.
if ad[AD_POSTEDIT] == NIL
  snRecStat := RS_VALID
elseif eval(ad[AD_POSTEDIT])
  snRecStat := RS_VALID
elseif USRATTR_W $ UsrAttrib() .and. Confirm(SetMsg(),"Ignore this warning (Y/N) ?")
  snRecStat := RS_VALID
else
  snRecStat := RS_INVALID
endif
if snRecStat == RS_VALID
  if DoEvents(saData[AD_ONPOSTEDIT]).and.DoEvents(saData[AD_ONTEST])
    if lastkey() == K_ENTER .or. lastkey() == K_F10 .or. lastkey() == K_PGDN
      DoEvents(saData[AD_EDITDETAIL])
    endif
  else
    snRecStat := RS_INVALID
  endif
endif
if snRecStat == RS_INVALID
  scRecMessage := SetMsg()
  RETURN .t.
endif
RETURN NIL

FUNCTION ddChkWhile()
if ! ddCheckWhile() .or. ! &sxlFilter
  if snRecStat == RS_INVALID
    slCanSkip := .f.
  else
    ddGoTop()
    * snRecStat := RS_INVALID
  endif
else
  slCanSkip := .t.
endif
* if ! empty(dbfilter())
*   if ! &(dbfilter())
*     Warning(MSG003)
*     if snRecStat == RS_VALID // .and. snRequest == DDEDIT_BROWSE
*       ddRefreshAll()
*     endif
*   endif
* endif
RETURN NIL


* FUNCTION ddDoPostEdit(ad)
* RETURN DoEvents(ad[AD_ONPOSTEDIT])

**
** ddEditDelete()
**
FUNCTION ddEditDelete()
local area
local lOkay
local nRetVal
local lDoIt := .F.
local i
local cMsg
local aDbd
local cIdDos
RETURN .f. if IsReadOnly(saData)
* if USRATTR_R $ UsrAttrib()
*   SetMsg(MsgReadOnly())
*   RETURN .F.
* endif
if snSkipOffset != 0
  SetMsg("(Nur auf dem ersten Record einer Gruppe)")
  RETURN .f.
endif
* 960417 RETURN SetMnuDone() if recno() == lastrec() + 1
if saData[AD_PREEDIT] != NIL
  if ! eval(saData[AD_PREEDIT])
    RETURN .f. if ! USRATTR_W $ UsrAttrib()
  endif
endif
if saData[AD_PREDELETE] == NIL
  RETURN .f. if ! ConfirmDelete()
else
  RETURN .f. if ! eval(saData[AD_PREDELETE])
endif
RETURN .f. if ! DoEvents(saData[AD_ONDELETE],saData[AD_NAME]+":onDelete")
RETURN .f. if ! ddRecLock()
ddBefore(saData)
delete
unlock record
if Skipper(1,0,.f.) == 1
  snSkipOffset := 0
else
  // soBrowse:goBottom() // 20070307
  eval(soBrowse:goBottomBlock)
endif
DoEvents(saData[AD_POSTDELETE])
saData[AD_UPDATED] := .T.
snRecStat := RS_VALID
slCanSkip := .t.
ddRefreshAll()
RETURN SetMnuDone()

FUNCTION setrs_unknown
snRecStat := RS_UNKNOWN
RETURN .t.


* FUNCTION IsShared(ad)
* RETURN .f. if ad[AD_PATH] == DbPath() + "\"
* RETURN .t. // ( len(ad[AD_PATH]) < len(DbPath()) )
* RETURN ad[AD_SHARED]

FUNCTION ConfirmDelete(cMsg2)
RETURN Confirm( MsgRecDelete(), cMsg2, MSG_YES, "WRN012" )

**
** ddEditAppend()
**
STATIC FUNCTION ddEditAppend()
RETURN SetMnuDone() if ddCreate()
RETURN .f.

* FUNCTION MsgReadOnly()
* RETURN "Diese Funktion ist gesperrt."

**
** ddCreate()
**
FUNCTION ddCreate()
local nRecNo := save_recno()
local i
// local lEof := (nRecNo == lastrec() + 1) // eof() *vor* eval(bCreate) !
* local nOrder := indexord()
local nCreate
RETURN .f. if snMode == DDMODE_SHOW
RETURN .f. if IsReadOnly(saData)
#ifdef __XPP__
if snRequest == DDEDIT_BROWSE
  QuickStabilize()
  * soBrowse:forceStable()
endif
#endif __XPP__
RETURN .f. if ! DoEvents(saData[AD_PRECREATE])
if saData[AD_CREATE] == NIL
  if CurQry(QRY_IDMSK) != NIL
    nCreate := DDCREATE_FULL
  * 20070524 elseif slIsEof
  elseif eof().or.bof()
    nCreate := DDCREATE_EDIT
  else
    slModify := .T.
    nCreate := DDCREATE_REFRESH
  endif
  if dbAddRec()
    SetMsg(MSG_011)
    * if len(RecStack()) > 0
    *   PopRec()
    * endif
  else
    nCreate := DDCREATE_FAIL
  endif
else
  // ddSetOrder 1
  nCreate := eval( saData[AD_CREATE] )
  // ddSetOrder (nOrder)
endif
if nCreate == DDCREATE_FAIL
  rest_recno(nRecNo)
  * 20070524 if slIsEof
  * if eof()
  *   goto lastrec() + 1 // falls nÑmlich nRecNo mittlerweile schon nicht
  *                      // mehr == lastrec() + 1 ist, weil andere
  *                      // Benutzer inzwischen records erstellt haben
  * else
  *   goto nRecNo
  * endif
  RETURN .f.
endif
slIsEof := .f. // since the new record now exists
saData[AD_UPDATED] := .t.
snSkipOffset := 0
DoEvents(saData[AD_ONCREATE],saData[AD_NAME]+":onCreate")
ddAfter()
dbcommit()  // 980627
unlock record // das wird hier erst seit 19980424 gemacht...
// und am 19980512 wieder rein (bei HK)
if nCreate == DDCREATE_EDIT
  slModify := .t.
  snRecStat := RS_UNKNOWN
  ddRefreshAll() // neu seit 20071120
elseif nCreate == DDCREATE_FULL
  slModify  := .t.
  snRecStat := RS_UNKNOWN
  if CurQry(QRY_IDMSK) != NIL
    snRequest := DDEDIT_PAGE
  endif
elseif nCreate == DDCREATE_REFRESH
  snRecStat := RS_UNKNOWN
  ddRefreshAll()
else
  snRecStat := RS_UNKNOWN
  ddRefreshAll()
endif
RETURN .T.

FUNCTION DoEvents(a,cText)
local i
local cMsg
local lOkay
RETURN .t. if a == NIL
for i := 1 to len(a)
  lOkay := xeval(a[i])
  // 20071019 lOkay := eval(a[i])
  default lOkay to .f.
  do while ! lOkay
    RETURN .f. if cText == NIL
    cMsg := cText + "[" + ntrim(i) + "]  failed."
    if ! Confirm(cMsg, MsgRetry())
      rpt_write(cMsg)
      SetKeepReport(.t.)
      RETURN .f.
    endif
    lOkay := eval(a[i])
    // 20071019 lOkay := xeval(a[i])
    default lOkay to .f.
  enddo
next i
RETURN .t.

** Execute an optional Clipper expression. 
** Return .t. if the expression is empty.
**
FUNCTION DoEvent(xlEvent)
RETURN .t. if empty(xlEvent)
RETURN &xlEvent

STATIC FUNCTION PreSkip()  // 20030301
* #ifdef __XPP__
*   if snRequest == DDEDIT_BROWSE
*     soBrowse:forceStable()
*   endif
* #endif __XPP__
* LogConsole("PreSkip() "+alias()+":"+&(indexkey()))
if snRecStat == RS_UNKNOWN  // RS_NEW
  if ddRecLock()
    ddBefore()
    ddPostEdit()
    ddAfter()
    unlock record
    * ddChkWhile()
  endif
endif
// RETURN .f. if ! slCanSkip
RETURN .t. if snRecStat == RS_VALID
* 20070524 RETURN .t. if slIsEof
RETURN .t. if eof().or.bof()
SetMsg(scRecMessage)
RETURN .f.



**
** ddFileExit()
**
FUNCTION ddFileExit()
RETURN .f. if ! PreSkip()
RETURN .f. if ! eval(saData[AD_PREEXIT])
snRequest := DDEDIT_EXIT
* if soBrowse:stable()
*   soBrowse:deHilite()
* endif
RETURN SetMnuDone()


**
** ForceStable()
**
FUNCTION ForceStable()
* if ! slIsEof
  * 20070831 dispbegin()
  while ( ! soBrowse:stabilize() ) ; end
  * 20070831 dispend()
* endif
RETURN NIL

*STATIC FUNCTION Skipper(n,nCellHeight,lBeyond)
*local i
** LogConsole(skipstat())
*i := Skipper_(n,nCellHeight,lBeyond)
*LogConsole("Skipper("+ntrim(n)+",lBeyond="+utos(lBeyond)+") -> "+ntrim(i))
** LogConsole("->" + skipstat())
*RETURN i
*
*STATIC FUNCTION skipstat
*local c := ""
*if saRecNos == NIL
*  c += alias()+ntrim(indexord())+":"+&(indexkey())
*else
*  c += "snRecNo is "+utos(snRecNo)
*endif
*c += ", recno() is "+ntrim(recno())
*c += ", slIsEof is "+utos(slIsEof)
*RETURN c


**
** If lBeyond is .t., Skipper() will simulate a pseudo-record by accepting to
** go one record beyond eof()
**
STATIC FUNCTION Skipper(n,nCellHeight,lBeyond)
local i := 0
local nSkipOffset := snSkipOffset
* 20070524 local nRecNo := if(slIsEof,NIL,recno()) // der letzte ungefilterte record
local nRecNo := save_recno()
// local nRecNo := if(eof(),NIL,recno()) // der letzte ungefilterte record
// N.B.: wenn der Cursor auf eof() steht (slIsEof), dann merken wir uns
// hier nicht die recno(), weil die im Multi-User-Betrieb mittlerweile
// nicht mehr gÅltig sein kînnte.
** sleep(5)
if n == 0
  // Warum gibt es eigentlich einen Aufruf Skipper(0) ?
  // ex.: Last and unique record of while-range has been deleted.
  if saRecnos == NIL
    skip 0
  elseif snRecno > 0
    goto saRecnos[snRecno]
  else
    goto lastrec() + 1
  endif
  // Achtung : bei skip 0 anschlie·end wohl noch ddCheckWhile()
  if eof().or.bof() .or. ! &sxlFilter .or. ! ddCheckWhile()
    goto lastrec() + 1
    slIsEof := .t.
    snRecNo := 0
  else
    slIsEof := .f. // neu seit 20070518
  endif
  * RETURN 0
elseif n > 0
  do while i < n
    *#ifndef DEF_NO_BROWSE_BREAK
    *  if snMode != DDMODE_WAIT .and. TaskInter(NIL,.t.) // 980624
    *    snRequest := DDEDIT_ESCAPE
    *    RETURN 0
    *  endif
    *#endif
    if snSkipOffset < nCellHeight
      i++
      snSkipOffset++
    * 20070524 elseif slIsEof
    elseif eof().or.bof()
      * LogConsole("slIsEof")
      exit
    else
      if saRecnos == NIL
        skip 1
      elseif snRecno < len(saRecnos)
        if snRecno == 0 ; raise("recno() == 0 but !slIsEof") ; endif
        snRecno += 1
        goto saRecnos[snRecno]
      else
        goto lastrec() + 1
      endif
      snSkipOffset := 0
      if bof() .or. eof() .or. ! ddCheckWhile()
        * LogConsole("eof().or.!ddCheckWhile()")
        if lBeyond
          i++
          slIsEof := .t.
          snRecNo := 0
          goto lastrec() + 1
          exit // neu am 20070518
        elseif nRecNo != NIL
          goto nRecNo
          snSkipOffset := nSkipOffset
          exit
        else
          goto lastrec() + 1
          slIsEof := .t.
          snRecNo := 0
          exit
        endif
      elseif &sxlFilter
        nRecNo := recno()
        i++
        nSkipOffset := snSkipOffset
      * else
      *   LogConsole("!sxlFilter:"+sxlFilter)
      endif
    endif
  enddo
elseif ( n < 0 )
  do while i > n
    *#ifndef DEF_NO_BROWSE_BREAK
    *  if snMode != DDMODE_WAIT .and. TaskInter(NIL,.t.) // 980624
    *    snRequest := DDEDIT_ESCAPE
    *    RETURN 0
    *  endif
    *#endif
    if snSkipOffset > 0
      i--
      snSkipOffset--
    else // also wenn snSkipOffset 0 ist:
      snSkipOffset := nCellHeight
      * 20070524 if slIsEof
      if eof() .or. bof()
        // soBrowse:goBottom() // 20070307
        eval(soBrowse:goBottomBlock)
        slIsEof := .f. // neu seit 20070518
        * if lBeyond
        *   i--
        * endif
      else
        if saRecnos == NIL
          skip -1
        elseif snRecno > 1
          snRecno -= 1
          goto saRecnos[snRecno]
        else
          goto lastrec() + 1
        endif
      endif
      if eof() .or. bof() .or. ! ddCheckWhile()
        ** Das geht zu weit. Hier dÅrfen wir nicht bleiben.
        if nRecNo == NIL
          goto lastrec() + 1
          slIsEof := .t.
          snRecNo := 0
        else
          goto nRecNo
          slIsEof := .f. // neu am 20070518
        endif
        snSkipOffset := nSkipOffset
        exit
      endif
      ** Normalerweise wÑren wir hier jetzt auf dem nÑchsten gÅltigen
      ** Record... aber es gibt ja noch den Filter, der den Erfolg
      ** verzîgern kann.
      if &sxlFilter
        ** Aha.
        ** Jetzt haben wir endlich den "vorigen" Record gefunden.
        ** i kann dekrementiert werden.
        slIsEof := .f. // 980102
        nRecNo := recno()
        nSkipOffset := snSkipOffset
        i--
      endif
    endif
  enddo
  * #ifdef __XPP__
  * i := -i // 20070308
  * #endif
endif
RETURN i

FUNCTION ddFileArchive
if IsArchive(saData)
  RETURN !SetMsg(;
    "Archiv wÑhlen: nicht erlaubt auf archivierenden Daten";
  )
endif
RETURN .f. if ! SelectArchive()
if snRequest == DDEDIT_PAGE
  WinCls()
  ScrPaint(CurMsk())
endif
ddWinAdapt(soBrowse)
ddSayStatus()
ddRefreshAll()
MnuDrop()
RETURN .t.

#ifdef DEF_GIMMICK

**
**  ddFileCheck()
**  -------------
**  Scans the currently visible records.
**  For each of them: if pre-edit block says .T., the post-edit block
**  is executed. Stops if a record with invalid data is found (postedit .F.).
**  If <bAddiBlock> is specified, it will be executed before postblock.
**  <bAddiBlock> can do special processing for the record (e.g. scan
**  subsequent records).
**
FUNCTION ddFileCheck( bAddiBlock )
local nSkipped := 0
local nRecCnt := 0
local nRecNo := save_recno()
local lRecValid
local nRow, nCol
* default ob to soBrowse
*
LastGet("")
open window (TXT_022) size 4,35
say TXT_023
WinCR()
nRow := row()
nCol := col()
do while !eof().and.!bof()
  @ nRow, nCol say ntrim(++nRecCnt) + TXT_024
  if ddRecLock()
    if ddOnPreEdit(saData)
      if bAddiBlock != NIL
        eval( bAddiBlock )
      endif
      ddPostEdit()
    else
      nSkipped += 1
    endif
    unlock record
    ddChkWhile()
  endif
  if snRecStat == RS_INVALID
    close window
    ddRefreshAll()
    RETURN SetMnuDone()
  endif
  if TaskInter()
    close window
    SetMsg(MSG_006)
    rest_recno(nRecNo)
    * goto nRecNo
    RETURN .f.
  endif
  if Skipper(1,0,.f.) != 1 // 20070518
  * if eval(soBrowse:skipBlock,1) != 1
    exit
  endif
enddo
close window
SetMsg( ntrim(nRecCnt) + TXT_024 ;
        + iif(nSkipped > 0, " ("+ntrim(nSkipped)+" skipped)",""))
rest_recno(nRecNo)
* goto nRecNo
ddRefreshAll()
RETURN SetMnuDone()

**
**  ddFileCount()
**
FUNCTION ddFileCount()
local nRecCnt := 0
local nRecNo := save_recno()
local nRow, nCol
local lIsEof := slIsEof
slIsEof := .f.
*
// soBrowse:goTop() // 20070307
eval(soBrowse:goTopBlock)
open window (MSG_012) size 4,40
say TXT_023
WinCR()
nRow := row()
nCol := col()
do while !eof().and.!bof()
  @ nRow, nCol say ntrim(++nRecCnt) + TXT_024
  if TaskInter()
    close window
    SetMsg(MSG_006)
    rest_recno(nRecNo)
    * goto nRecNo
    RETURN .f.
  endif
  if Skipper(1,0,.f.) != 1 // 20070518
  * if eval(soBrowse:skipBlock,1) != 1
    exit
  endif
enddo
close window
SetMsg( ntrim(nRecCnt) + TXT_024 ) // " enregistrement(s)." )
rest_recno(nRecNo)
* goto nRecNo
slIsEof := lIsEof
RETURN SetMnuDone()

#endif // DEF_GIMMICK

**
**  ddScan()
**
FUNCTION ddScan( bAction, cFilter, lNoconfirm )
local nRecNo := save_recno()
local lIsEof := slIsEof
local lOkay := .t.
if saRecnos != NIL ; raise("ddScan() with saRecnos") ; endif
default cFilter to sxlFilter
KeyGoTop(scKeyValue,sxcKey,cFilter)
do while !eof() .and.!bof() .and. &sxcKey == scKeyValue
  if &cFilter
    if ! eval(bAction)
      lOkay := .f.
      exit
    endif
  endif
  if TaskInter(NIL,lNoConfirm)
    lOkay := .f.
    exit
  endif
  skip // ddSkip(1) // skip 20070519
  * skip
  * if Skipper(1,0,.f.) != 1
  *   exit
  * endif
enddo
slIsEof := lIsEof
rest_recno(nRecNo)
RETURN lOkay

FUNCTION ddEditSearch(xlFind)
local nRecNo := save_recno()
local lOkay := .t.
MsgDisplay(MsgWorking())
ddSkip(1)
do while !eof() .and.!bof() .and. &sxcKey == scKeyValue
  if &xlFind
    SetMsg("Gefunden.")
    RETURN ddRefreshAll()
  endif
  if TaskInter()
    lOkay := .f.
    exit
  endif
  ddSkip(1)
enddo
rest_recno(nRecNo)
Warning("Nichts gefunden !")
RETURN lOkay



FUNCTION DeleteAll(bPreDelete)
default bPreDelete to saData[AD_PREDELETE]
ddScan({||TryDelete(bPreDelete)})
ddRefreshAll()
RETURN .t.

FUNCTION TryDelete(bPreDelete)
RETURN .t. if ! eval(bPreDelete)
RETURN .f. if ! DoEvents(saData[AD_ONDELETE],saData[AD_NAME]+":onDelete")
RETURN .f. if ! ddRecLock()
delete
unlock record
RETURN .t.

#ifdef DEF_IMPORT

STATIC FUNCTION ddImport(ad)
default ad to saData
DbfImport(ad)
ddRefreshAll()
RETURN SetMnuDone()


STATIC FUNCTION ddExport(ad)
default ad to saData
RETURN .f. if ! DbfExport( ;
  {ad}, ;
  indexord(), ;
  scKeyValue, ;
  sxcKey+"=='"+scKeyValue+"'", ;
  sxlFilter ;
)
RETURN SetMnuDone()

#endif DEF_IMPORT

**
** ddViewOrder()
**
** Activates the next user-selectable index order
** 
**
* STATIC FUNCTION ddViewOrder()
* local nOrder := indexord()
* local i    := nOrder
* local nLen := len(soBrowse:cargo[AD_AINDEX])
* local nChoice := 0
* local aLib := {}
* local aOrd := {}
* * if nLen < 2
* *   RETURN .f.              // There are not enough choices anyway...
* * endif
* if soBrowse:cargo[AD_AINDEX][i][AI_TEXT] == NIL
*   SetMsg("(not allowed to change order)")
*   RETURN .f.              // Current index order is not selectable
* endif
* for i := 1 to nLen
*   if soBrowse:cargo[AD_AINDEX][i][AI_TEXT] != NIL
*     aadd( aLib, soBrowse:cargo[AD_AINDEX][i][AI_TEXT] )
*     aadd( aOrd, i )
*   endif
* next i
* open window (MSG005) size (len(aLib) + 2), 32 help VIEWORD
* #ifndef MONKEY
* nChoice := achoice( WinTop(), WinLeft(), WinEndY(), WinEndX(), aLib, , , nOrder )
* #endif
* close window
* RETURN .f. if nChoice == 0
* ddSetOrder (aOrd[nChoice])
* * AD_KEYBLOCK
* ddRefreshAll()
* ddSayStatus()
* RETURN SetMnuDone()

**
** ddViewOrder()
**
* STATIC FUNCTION ddViewOrder()
* local nOrder := eval(sbPickOrder,soBrowse)
* RETURN .f. if nOrder == NIL
* ddSetOrder (nOrder)
* ddRefreshAll()
* ddSayStatus()
* RETURN SetMnuDone()

**
** PickOrder()
**
*FUNCTION PickOrder(b)
*local nOrder := indexord()
*local nLen := len(b:cargo[AD_AINDEX])
*local a := {}
*local i
*if b:cargo[AD_AINDEX][nOrder][AI_TEXT] == NIL
*  Warning("In dieser Liste ist keine alternative Sortierfolge mîglich !")
*  RETURN 0
*endif
*for i := 1 to nLen
*  if b:cargo[AD_AINDEX][i][AI_TEXT] != NIL
*    aadd( a, { b:cargo[AD_AINDEX][i][AI_TEXT], i } )
*  endif
*next i
*browse array a using {|x| padr(x[1],40) } ;
*             title (MSG005) ;
*             help  "VIEWORD"
*RETURN NIL if lastchoice() == 0
*RETURN a[lastchoice()][2]

**
** ddSayStatus
**
FUNCTION ddSayStatus()
local cStatus := ""
* RETURN NIL if snMode == DDMODE_WAIT
if sbStatus != NIL
  cStatus += eval(sbStatus) + " ≥"
endif
*if snMode == DDMODE_EDIT   ; cStatus += MSG_EDIT
*elseif snMode == DDMODE_PICK   ; cStatus += MSG_PICK
** elseif snMode == DDMODE_SEARCH ; cStatus += MSG_SRCH
*elseif snMode == DDMODE_SHOW   ; cStatus += MSG_SHOW
*elseif snMode == DDMODE_FIND   ; cStatus += MSG_FIND
*endif
* cStatus += ntrim(indexord())
cStatus += " ≥"
*?if len(soBrowse:cargo[AD_AINDEX]) > 0 // != 0
*?  if indexord() != 0
*?    if soBrowse:cargo[AD_AINDEX][indexord()][AI_TEXT] != NIL
*?      cStatus += trim(soBrowse:cargo[AD_AINDEX][indexord()][AI_TEXT]) + ;
*?                 " ≥ "
*?    endif
*?  endif
*?endif
* #ifdef DEF_FILTER
  if ! empty(scFltText)
    * cStatus += " Nur " + scFltText
    cStatus += scFltText
  endif
* #endif
*if ddIsPublic(soBrowse:cargo)
*  cStatus += utos(soBrowse:cargo[AD_PATH]) + " ≥"
** if ddIsCommon(soBrowse:cargo)
*  * cStatus += "* ≥"
*endif
if IsArchive(saData)
  cStatus += "a ≥"
endif
* if ddIsPublic(saData)
*   cStatus += "* ≥"
* endif
SaySta( cStatus )
RETURN NIL

**
** ddQryAddColumns()
**
** adds column objects to browse object
** if query is {}, the default order is the natural field order
**
STATIC FUNCTION ddQryAddColumns( ad, qry, lHeaders )
local c
local i
local col
local aFld := saData[AD_FIELDS]
local aCol := qry[QRY_COLUMNS]
if len(aCol) == 0   // query empty : default col order = field order
  for i := 1 to len(aFld)
    col := { ;
      i, ;                // COL_FLDHANDLE
      aFld[i][AG_NAME], ;     // COL_HEADER
      "", ;
      aFld[i][AG_PICTURE], ; // COL_PICTURE
      "", ;
      NIL, ;
      0, ;
      NIL, ;              // COL_SAYBLOCK
      NIL,;               // COL_BLOCK
      NIL,;               // COL_ONEDIT
      ".f.",;             // COL_SKIPBLOCK
      NIL   ;             // COL_CLRBLOCK
      , NIL  ;            // COL_IFEXPR
    }                     // COL_ALEN
    if FldColumnNew( ad, col, lHeaders )
      aadd(qry[QRY_COLUMNS], col)
    endif
  next i
else
  for i := 1 to len( aCol )
    col := aCol[i]
    if col[COL_IFEXPR] == NIL .or. &(col[COL_IFEXPR])
      if col[COL_FLDHANDLE] == 0
        VrtColumnNew( ad, col, lHeaders)
      else
        FldColumnNew( ad, col, lHeaders)
      endif
    endif
  next i
endif
RETURN NIL if qry[QRY_ONADDCOLUMNS] == NIL
c := qry[QRY_ONADDCOLUMNS]
RETURN xparse(qry[QRY_ONADDCOLUMNS])

**
** ddQryReset()
**
FUNCTION ddQryReset(cIdQry)
local qry
local lGoTop := .f.
* LogConsole("20071025 ddQryReset()")
if cIdQry == NIL
  qry := CurQry()
else
  qry := QryLoad(saData,cIdQry)
  if ddSetKey(qry,scKeyValue,sxcKey,sxlFilter)
    if qry[QRY_TITLE] != NIL
      SetWinTitle(xparse(qry[QRY_TITLE]))
    endif
    if ! ddCheckWhile() .or. ! &sxlFilter
      lGoTop := .t.
    endif
  endif
endif
do while soBrowse:colCount > 0
  soBrowse:delColumn(1)               // delete old query
enddo
* raus am 20070327 soBrowse:configure()
ddQryAddColumns(saData,qry,.t.)
* Skipper(0,0)
* slIsEof := .f.
if lGoTop
  if snStart == 2 // start bottom
    soBrowse:goBottom()
  else
    soBrowse:goTop()
  endif
else
  * LogConsole("20071025 ddQryReset() !lGoTop")
  ddRefreshAll()
endif
ddSayStatus()
RETURN .t.

FUNCTION QryAddColumn(cFldName,xuValue,cHeader,xbColorBlock,cPicture)
local col := array(COL_ALEN)
local aFld
local i
default cPicture to ""
col[COL_ATTRIB   ] := ""
col[COL_PICTURE  ] := cPicture
col[COL_BUFFER   ] := ""
col[COL_SUM      ] := 0
col[COL_SAYBLOCK ] := NIL
col[COL_ONEDIT   ] := NIL
col[COL_SKIPBLOCK] := ".f."
col[COL_CLRBLOCK ] := xbColorBlock
col[COL_IFEXPR   ] := NIL
col[COL_EXPR     ] := NIL // xuValue
if cFldname == NIL
  col[COL_FLDHANDLE] := 0
  col[COL_HEADER]    := cHeader
  col[COL_BLOCK    ] := xuValue
  RETURN VrtColumnNew( saData, col, .t. )
else
  aFld := saData[AD_FIELDS]
  for i := 1 to len(aFld)
    if aFld[i][AG_NAME] == cFldName
      col[COL_FLDHANDLE] := i
      default cHeader to aFld[i]:name
      col[COL_HEADER]    := cHeader
      col[COL_BLOCK    ] := NIL
      FldColumnNew( saData, col, .t. )
      RETURN .t.
    endif
  next i
  SetMsg(cFldName + " field not found.")
endif
RETURN .f.

**
** Adds the specified field as a column to the browse object
**
STATIC FUNCTION FldColumnNew(ad, col, lHeaders)
local column
local i
local nWidth
local fldBlock
local lIsMemo 
local fld := ad[AD_FIELDS][col[COL_FLDHANDLE]]
RETURN .f. if FLDATTR_H $ fld[AG_ATTRIB]  // removed field
RETURN .f. if FLDATTR_C $ fld[AG_ATTRIB]  .and. !USRATTR_C $ UsrAttrib()
* RETURN .f. if fld:type == "M" // memo-fields never occur in browse view
* fld:picture := col[COL_PICTURE]
if col[COL_BLOCK] == NIL
  if fld[AG_TYPE] == "D"
    col[COL_SAYBLOCK] := '""'
  endif
  fldBlock := fld[AG_BLOCK] // :block
  if fldBlock == NIL ; raise("fld:block is NIL") ; endif
else
  fldBlock := cblock(col[COL_BLOCK]) // 20050919
  if fldBlock == NIL ; raise("col:block is NIL") ; endif
endif
if fld[AG_TYPE] == "M" // substr(col[COL_PICTURE],3,2) == "@s"
  nWidth := val(left(col[COL_PICTURE],2)) // MEMO_PICTURE
else
  * if fld:picture == NIL ; raise("picture is NIL") ; endif
  nWidth := len(transform(eval(fldBlock,NIL,0),col[COL_PICTURE]))
endif
lIsMemo := (fld[AG_TYPE]=="M")
// b := {|x| GsbColEof(x,col,fld:block,nWidth,ad,lIsMemo) }
column := TBcolumnNew( ;
  if(lHeaders,xstr(col[COL_HEADER]),NIL), ;
  {|x| GsbColEof(x,col,fldBlock,nWidth,ad,lIsMemo) } )
column:width := nWidth
* logConsole(fld[AG_NAME]+" "+ntrim(nWidth))
if col[COL_CLRBLOCK] != NIL
  column:colorBlock := xparse(col[COL_CLRBLOCK])
endif
column:cargo := col
soBrowse:addColumn(column)
RETURN .t.

**
** VrtColumnNew()
**
STATIC FUNCTION VrtColumnNew(ad,col,lHeaders)
local column
local nWidth
local lIsMemo := .f.
* local bBlock := xparse(col[COL_BLOCK])
if substr(col[COL_PICTURE],3,1) == "x"
  // it's a virtual memo field
  nWidth := val(left(col[COL_PICTURE],2)) // MEMO_PICTURE
  lIsMemo := .t.
else
  nWidth := len(transform(&(col[COL_BLOCK]),col[COL_PICTURE]))
endif
column := TBcolumnNew( ;
  if(lHeaders,xstr(col[COL_HEADER]),NIL), ;
  {|x|GsbColEof(x,col,{||&(col[COL_BLOCK])},nWidth,ad,lIsMemo) } ;
)
column:width := nWidth
if col[COL_CLRBLOCK] != NIL
  column:colorBlock := xparse(col[COL_CLRBLOCK])
endif
column:cargo := col
soBrowse:addColumn(column)
RETURN .t.

FUNCTION ColValue(nCol)
local col := soBrowse:getColumn(nCol)
RETURN eval(col:block)

static FUNCTION GsbColEof(x,col,bBlock,nWidth,ad,lIsMemo)
* local cSayBlock
local i
if x == NIL
  * 20070524 if slIsEof .and. slSumActive .and. snSkipOffset == 0
  if (eof().or.bof()) .and. slSumActive .and. snSkipOffset == 0
    if col[COL_EXPR] != NIL
      if slMustScan
        MsgDisplay(utrp("Computing sums...",;
                        "Summen berechnen...",;
                        "Calcul des sommes en cours..."))
        for i := 1 to soBrowse:ColCount
          soBrowse:GetColumn(i):cargo[COL_SUM] := 0
        next i
        if saData[AD_SUMSCAN] == NIL
          slMustScan := ! ddScan({||ColScan()},NIL,.t.)
        else
          slMustScan := ! eval(saData[AD_SUMSCAN],{||ColScan()},sxlFilter)
        endif
        MsgDisplay("")
      endif
      RETURN padl(col[COL_SUM],nWidth) if col[COL_SAYBLOCK] == NIL
    endif
    if col[COL_SAYBLOCK] != NIL
      RETURN eval(&("{|nSum|" + col[COL_SAYBLOCK] + "}"),col[COL_SUM])
    endif
  endif
  if lIsMemo
    RETURN space(nWidth) if mlcount(eval(bBlock)) == 0
    RETURN memoline(eval(bBlock),nWidth,snSkipOffset+1)
  endif
  RETURN transform(eval(bBlock),col[COL_PICTURE]) if snSkipOffset == 0
  RETURN space(nWidth)
endif
RETURN eval(bBlock,x)


static FUNCTION ColScan
local i
local col
* local cExpr
for i := 1 to soBrowse:ColCount
  col := soBrowse:GetColumn(i)
  if col:cargo[COL_EXPR] != NIL
    * cExpr := strtran(col:cargo[COL_EXPR],"nVal",ntrim(val()))
    col:cargo[COL_SUM] += &(col:cargo[COL_EXPR])
  endif
next i
RETURN .t.


*FUNCTION ddRefresh
*local i
*ddScan({||})
*for i := 1 to soBrowse:colCount
*  if fld:cargo[AG_FTRBLOCK] != NIL
*    column:footing := eval(fld:cargo[AG_FTRBLOCK])
*  endif
*next i
*RETURN NIL

*#ifdef __XPP__
*
*FUNCTION ddRefreshAll()
*if snRequest == DDEDIT_BROWSE
*  if slIsEof // .and. !eof()
*    // wenn Warteliste CPAS anfangs leer war und dann refresht wird
*    soBrowse:goTop()
*  else
*    soBrowse:refreshAll()
*  endif
*  soBrowse:forceStable()
*  slIsEof := eof()
*  slMustScan := .t.
*elseif snRequest == DDEDIT_PAGE
*  FldFreshAll( CurMsk(), saData, slModify )
*endif
*RETURN .t.
*
*#else

**
** Setzt eventuell soBrowse:rowPos neu (kînnte zu weit unten stehen von vorheriger
** Benutzung des Browseobjekts).  Browse:refreshAll() ignoriert den Fall,
** dass der Bildschirm nicht bis oben gefÅllt sein kînnte, und dann erscheint
** die erste Zeile wiederholt.
**
FUNCTION ddRefreshAll()
local nRowPos := 1
* 20070524 local nRecNo := recno()
local nRecNo := save_recno()
if snRequest == DDEDIT_BROWSE
  QuickStabilize()
  * 20070524 if slIsEof
  if eof().or.bof()
    // wenn Warteliste CPAS anfangs leer war und dann refresht wird
    soBrowse:goTop()
  else
    do while .t.
      QuickStabilize()
      if eval(soBrowse:skipBlock,-1) != -1
        exit
      endif
      nRowPos++
      if nRowPos >= soBrowse:rowPos
        exit
      endif
    enddo
    * 20070524 if slIsEof
    rest_recno(nRecNo)
    QuickStabilize()
    if nRowPos < soBrowse:rowPos
      soBrowse:rowPos := nRowPos
      * soBrowse:configure() // neu seit 20071018
    elseif nRowPos > soBrowse:rowPos
      soBrowse:rowPos := nRowPos
      soBrowse:configure()
    endif
    QuickStabilize()
  endif
  slIsEof := eof().or.bof()
  slMustScan := .t.
  soBrowse:refreshAll()
  soBrowse:forceStable() // nach énderung der Sortierfolge Åber F11 wurde
                         // das Browse sonst durcheinandergeworfen.
  // 20070309 aber xbase forceStable() setzt rowPos immer auf 1
elseif snRequest == DDEDIT_PAGE
  if eof().or.bof()
    eval(soBrowse:goTopBlock)
  endif
  FldFreshAll( CurMsk(), saData, slModify )
endif
RETURN .t.

* #endif __XPP__

**
** QuickRefresh()
**
FUNCTION QuickRefresh()
local nRowPos := 1
local nRecNo := save_recno()
* RETURN NIL if AppTerminate()
if snRequest == DDEDIT_BROWSE
  slIsEof := eof().or.bof()
  do while .t.
    if eval(soBrowse:skipBlock,-1) != -1
      exit
    endif
    nRowPos++
    if nRowPos > soBrowse:rowPos
      exit
    endif
  enddo
  * 20070524 if slIsEof
  rest_recno(nRecNo)
  if nRowPos < soBrowse:rowPos
    soBrowse:rowPos := nRowPos
  endif
  soBrowse:refreshAll()
elseif snRequest == DDEDIT_PAGE
  FldFreshAll( CurMsk(), saData, slModify )
endif
RETURN NIL

FUNCTION ddMustScan()
RETURN (slMustScan := .t.)


**
** ddRefreshCurrent()
**
** N.B.
** Wird eventuell benutzt Åber bAfter, wenn gar kein Browse aktiv ist !
** Dann ist snRequest == DDEDIT_PAGE
**
FUNCTION ddRefreshCurrent()
RETURN .t. if soBrowse == NIL
if snRequest == DDEDIT_BROWSE
  if snCellHeight == 0
    soBrowse:refreshCurrent()
  else
    soBrowse:refreshAll()
  endif
elseif snRequest == DDEDIT_PAGE
  FldFreshAll( CurMsk(), saData, slModify )
endif
RETURN .t.


#ifdef DEF_SEEK

**
** ddEditForward()
**
STATIC FUNCTION ddEditForward()
RETURN .f. if ! GetCdt(soBrowse,saData)
ddSearch(soBrowse,saData,1)
RETURN SetMnuDone()


**
** ddEditBack()
**
STATIC FUNCTION ddEditBack()
RETURN .f. if ! GetCdt(soBrowse,saData)
ddSearch(soBrowse,saData,-1)
RETURN SetMnuDone()


#endif // DEF_SEEK

**
** ViewFull()
**
STATIC FUNCTION ViewFull(lForce)
if snRequest == DDEDIT_BROWSE .or. lForce
  RETURN .f. if CurQry(QRY_IDMSK) == NIL
  snRequest := DDEDIT_PAGE
else
  snRequest := DDEDIT_BROWSE
endif
RETURN SetMnuDone()

FUNCTION IsFull ; RETURN (snRequest == DDEDIT_PAGE)

STATIC FUNCTION ddEditPrint()
eval(saData[AD_EDITPRINT])
RETURN SetMnuDone()


#ifdef DEF_FILTER

**
** ddViewFilter()
**
STATIC FUNCTION ddViewFilter()
local xlFilter
local cFltExpr
local cFltText := scFltText
local ad := saData
if ad[AD_PICKFLT] != NIL
  eval(ad[AD_PICKFLT])  // wird normalerweise ddSetFilter() aufrufen
  ddSayStatus()
  RETURN SetMnuDone()
endif
cFltExpr := padr(dbfilter(),128)
open window "Filter" size 3,54
@ row(), col() get cFltExpr picture "@K@S50"
nKey := ReadScr()
close window
RETURN SetMnuDone() if nKey == K_ESC
if empty(cFltExpr)
  xlFilter := ".t."
  cFltText := ""
else
  xlFilter := trim(cFltExpr)
  cFltText  := cFltExpr
endif
ddSetFilter(xlFilter,cFltText)
ddSayStatus()
RETURN SetMnuDone()

**
** ddViewQuery()
**
STATIC FUNCTION ddViewQuery()
local cCondit
local cAlias := padr(CurQry(QRY_HELP),8)
* local cTitle := WinTitle()
local nSelect := select()
local cIdQry
local cIdDlg
local cExpr
local cFltText := scFltText
local flt := oFlt()
* QuickStabilize()
FltCargo(NIL,saData)
open area flt
  // softseek cAlias
  softseek cAlias + scIdFlt
  edit data flt create   {|| FltCreate(cAlias) }    ;
                mode     pick                       ;
                key      FLT->Alias ;
                value    cAlias    ;
                query    "FLTPICK" ;
                title    (MsgPickFlt())
  cExpr    := trim(FLT->Expr)
  cFltText := trim(FLT->Desig)
  cIdQry   := trim(FLT->IdQry)
  cIdDlg   := trim(FLT->IdDlg)
  scIdFlt  := FLT->IdFlt
close area
RETURN .f. if ddLastReq() != DDEDIT_SELECT
if ! empty(cIdDlg)
  SetDlgTitle(cFltText)
  RETURN .f. if ! DlgExec(cIdDlg)
endif
if cIdQry == "NIL"
  if empty(cExpr)
    ddSetFilter(".t.", "")
  elseif left(cExpr,1) == "="
    ddSetFilter(xparse(substr(cExpr,2)), cFltText)
  else
    ddSetFilter(StrParse(cExpr), cFltText)
  endif
else
  if empty(cExpr)
    sxlFilter := ".t."
    scFltText := ""
  elseif left(cExpr,1) == "="
    sxlFilter := xparse(substr(cExpr,2))
    default sxlFilter to ".t."
    scFltText := cFltText
  else
    sxlFilter := StrParse(cExpr)
    scFltText := cFltText
  endif
  ddQryReset(saData[AD_NAME] + cIdQry)
endif
ddSayStatus()
RETURN SetMnuDone()

#ifdef LG_GERMAN
FUNCTION MsgPickFlt() ; RETURN "WÑhlen Sie eine Ansicht aus :"
#else
FUNCTION MsgPickFlt() ; RETURN "SÇlectionnez une autre vue :"
#endif


FUNCTION FltCargo(nItem,ad)
static sad
if ad != NIL
  sad := ad
endif
RETURN sad[nItem] if nItem != NIL
RETURN sad

#endif DEF_FILTER

#ifdef DEF_PRINT

**
** ddFilePrint()
**
STATIC FUNCTION ddFilePrint()
if saData[AD_FILEPRINT] != NIL
  eval(saData[AD_FILEPRINT])
  RETURN SetMnuDone()
endif
ddListing()
RETURN SetMnuDone()

**
** ddListing() - Prints a standard Listing using current browse object
**
**
STATIC FUNCTION ddListing()
local cOutFile:="TMP.CSV"
local lOkay := .t.
local fld
local value
local ad := saData
local fd
local cType
local nHeight := 10
local cTitle1 := padr(WinTitle(), 50 )
local cTitle2 := padr(scFltText,50)
* local cTitle2 := padr(sxlFilter,50)
local cLine
local cTit1 := ""
local cTit2 := ""
local col
local i
local nRecNo := save_recno()
local lIsEof := slIsEof
local nMaxColCount := soBrowse:colCount
* local cMemoName := NIL
* local cMemoHeader := NIL
* local nWidth
static cToCSV  := BUTTON_OFF
local cSep := csvsep() // iif(slExcelUser,",",";") // chr(9))
* static cColumns  := BUTTON_ON
static cMemo     := BUTTON_OFF
static cNoDetail := BUTTON_OFF
local cKeyValue := NIL
local nKeyLen := 0
local nKeyCount := 0
* local aValue := {}
local nColCount := soBrowse:colPos
if nColCount == 1
  nColCount := soBrowse:colCount
endif
*for i := 1 to len(soBrowse:cargo[AD_FIELDS])
*  if ! FLDATTR_H $ soBrowse:cargo[AD_FIELDS][i]:cargo[AG_ATTRIB]
*    if soBrowse:cargo[AD_FIELDS][i]:cargo[AG_TYPE] == GTYPE_MEMO
*    * 20030312 if soBrowse:cargo[AD_FIELDS][i]:type == "M"
*      cMemoName := "FIELD->" + soBrowse:cargo[AD_FIELDS][i]:name
*      cMemoHeader := soBrowse:cargo[AD_FIELDS][i]:cargo[AG_HEADER]
*      if cMemoHeader == NIL
*        cMemoHeader := soBrowse:cargo[AD_FIELDS][i]:name
*      endif
*      exit
*    endif
*  endif
*next i
* if cMemoName != NIL
*   nHeight ++
* endif
SetTplIni("LISTE")
// open window (TXT_031) size nHeight,62 help DDLISTE
open window (MnuItemName()) size nHeight,62 help DDLISTE
GetPreview() ; WinCr()
GetTplIni()
GetRange()
say TXT_032 + " 1 "
@ row(), col() get cTitle1
WinCR()
say TXT_032 + " 2 "
@ row(), col() get cTitle2
WinCR()
if saData[AD_AINDEX][indexord()][AI_TEXT] != NIL
  say MSG005 + " " + trim(saData[AD_AINDEX][indexord()][AI_TEXT])
endif
WinCR()
// @ row(), col() get cColumns checkbox
say MSG011 // "Colonnes 1 Ö "
@ row(), col() get nColCount picture "###" ;
               valid nColCount >= 1 .and. nColCount <= nMaxColCount
WinCR()
@ row(), col() get cToCSV checkbox
say utr(" export to CSV"," Export nach CSV", " export vers CSV")
* if cMemoName != NIL
*   WinCR()
*   @ row(), col() get cMemo checkbox
*   say MSG004
* endif
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
slIsEof := .f.
cTitle1 := trim(cTitle1)
cTitle2 := trim(cTitle2)
// soBrowse:goTop() // 20070307
eval(soBrowse:goTopBlock)
if cToCSV == BUTTON_ON
  if (fd := fcreate(cOutFile)) == -1
    RETURN !SetMsg(cOutFile+MsgDosError(doserror()))
  endif
  * fwrite(fd,dos2latin1(cTitle1) + CR_LF)
  * fwrite(fd,dos2latin1(cTitle2) + CR_LF)
  for i := 1 to nColCount
    col := soBrowse:getColumn(i)
    if i > 1
      fwrite(fd,cSep)
    endif
    fwrite(fd,val2csv(GTYPE_CHAR,col:heading," in column header "+ntrim(i)))
  next i
  fwrite(fd,CR_LF)
*elseif cToPds == BUTTON_ON
*  if (fd := fcreate("TMP.PDS")) == -1
*    RETURN .f.
*  endif
*  ...
*  fwrite(fd,cTitle1 + CR_LF)
*  fwrite(fd,cTitle2 + CR_LF)
*  for i := 1 to nColCount
*    col := soBrowse:getColumn(i)
*    if i > 1
*      fwrite(fd,chr(9))
*    endif
*    fwrite(fd,dos2latin1(col:heading))
*  next i
*  fwrite(fd,CR_LF)
else
  for i := 1 to nColCount
    col := soBrowse:getColumn(i)
    * nWidth := col:width
    cTit1 += padr(col:heading,col:width)
    cTit2 += replicate("ƒ", col:width)
    if i != nColCount
      cTit1 += " "
      cTit2 += " "
    endif
    * aadd(aValue,0)
  next i
  RETURN .f. if ! OpenPrinter(SetTplIni(),SetPreview(),len(cTit2),;
                  {||  ;
                     PrintHeader(cTitle1,cTitle2), ;
                     PrintLine(left(cTit1,p_cpl())), ;
                     PrintLine(left(cTit2,p_cpl()))  ;
                  },SetRange())
  * open printer (SetTplIni()) ;
  *      preview (SetPreview()) ;
  *      range (SetRange()) ;
  *      width len(cTit2) ;
  *TitBlock {||  ;
  *  PrintHeader(cTitle1,cTitle2), ;
  *  PrintLine(left(cTit1,p_cpl())), ;
  *  PrintLine(left(cTit2,p_cpl()))  ;
  *}
  * 20031030
endif
do while !eof() .and.!bof() // .and. LstContinue()
  if TaskInter() ; exit ; endif
  * if cColumns == BUTTON_ON
    cLine := ""
    for i := 1 to nColCount
      col := soBrowse:getColumn(i)
      if cToCSV == BUTTON_ON
        if i > 1
          cLine += cSep
        endif
        if col:cargo[COL_FLDHANDLE] == 0
          cType := GTYPE_MEMO
          value := eval(col:block)
        else
          fld := ad[AD_FIELDS][col:cargo[COL_FLDHANDLE]]
          cType := fld[AG_TYPE]
          value := eval(fld[AG_BLOCK])
        endif
        cLine += val2csv(cType,value," in column '"+col:heading+'"')
      else
        cLine += padl( eval(col:block), col:width ) + " "
      endif
    next i
    if cToCSV == BUTTON_ON
      fwrite(fd,cLine + CR_LF)
    else
      PrintLine( left( cLine, p_cpl()) )
    endif
  * endif
  * if cMemo == BUTTON_ON .and. cMemoName != NIL .and. ! empty(&cMemoName)
  *   PrintLine(padr(cMemoHeader + " ",p_cpl(),"ƒ"))
  *   for i := 1 to mlcount(&cMemoName)
  *     PrintLine(memoline(&cMemoName,p_cpl(),i))
  *   next i
  *   PrintLine( padr("",p_cpl(),"ƒ") )
  * endif
  * if eval(soBrowse:skipBlock,1) != 1
  if Skipper(1,0,.f.) != 1
    exit
  endif
enddo
if cToCSV == BUTTON_ON
  fclose(fd)
  // AppShell("excel.bat TMP.CSV")
  // AppShell("excel.bat " + cOutFile)
  OpenCsv(cOutFile)
else
  if LstContinue()
    goto (lastrec() + 1)
    slMustScan := .t.
    slIsEof := .t.
    cLine := ""
    for i := 1 to nColCount
      col := soBrowse:getColumn(i)
      cLine += padr(eval(col:block),col:width) + " "
    next i
  endif
  if ! empty(cLine)
    PrintLine(cTit2)
    PrintLine(cLine)
  endif
  close printer
endif
rest_recno(nRecNo)
slIsEof := lIsEof
RETURN SetMnuDone()
      


FUNCTION val2csv(cType,v,cSrc,nDecPos)
default cSrc to ""
* RETURN "" if v == NIL
// local v := FldValue(i) // eval(get:block)
if cType == GTYPE_MEMO
  * RETURN '"'+dos2latin1(strtran(strtran(v,CR_LF,chr(10)),'"','""'))+'"'
  RETURN '"'+dos2latin1(strtran(strtran(v,chr(141)," "),'"','""'))+'"'
elseif cType == GTYPE_CHAR
  RETURN '"'+iif(slExcelUser,"","'")+strtran(dos2latin1(v),'"','""')+'"'
elseif cType == GTYPE_DATE
  * if slExcelUser
  *   RETURN dtocf(v,"yyyy-mm-dd")
  * endif
  RETURN dtocf(v,'"yyyy-mm-dd"')
  * RETURN dtocf(v,"dd/mm/yyyy")
elseif cType == GTYPE_NUMERIC
  default nDecPos to SetDecPos()
  * RETURN ltrim(ntom(v,nDecPos,20)) if slExcelUser
  RETURN mont2csv(ntom(v,nDecPos,20)) // '"'+komma(ltrim(ntom(v,nDecPos,20)))+'"'
elseif cType == GTYPE_AMOUNT
  if "," $ v
    raise("invalid amount "+utos(v)+cSrc)
  endif
  * if slExcelUser
  *   RETURN alltrim(v)
  * endif
  RETURN mont2csv(v) // '"'+komma(alltrim(v))+'"'
elseif cType == GTYPE_QTY
  if "," $ v
    raise("invalid quantity "+utos(v)+cSrc)
  endif
  * if slExcelUser
  *   * RETURN strtran(alltrim(v),",",".") if "," $ v
  *   RETURN alltrim(v)
  * endif
  * RETURN komma(alltrim(v))
  RETURN mont2csv(v) // '"'+komma(alltrim(v))+'"'
else
  raise("Invalid type "+utos(cType))
endif
RETURN utos(v)


FUNCTION val2str(cType,v,cSrc,nDecPos)
default cSrc to ""
default nDecPos to SetDecPos()
if cType == GTYPE_MEMO
  RETURN strtran(strtran(v,chr(141)," "),'"','""')
elseif cType == GTYPE_CHAR
  RETURN v
elseif cType == GTYPE_DATE
  RETURN dtocf(v)
elseif cType == GTYPE_NUMERIC
  RETURN ltrim(komma(ntom(v,nDecPos,20)))
elseif cType == GTYPE_AMOUNT
  RETURN ltrim(v)
elseif cType == GTYPE_QTY
  RETURN ltrim(komma(v))
else
  raise("Invalid type "+utos(cType))
endif
RETURN utos(v)




FUNCTION mont2csv(cMont)
RETURN eval(sbMont2CSV,cMont) // '"'+komma(alltrim(cMont))+'"'

FUNCTION SetMont2CSV(b)
RETURN sbMont2CSV if b == NIL
sbMont2CSV := b
RETURN .t.

FUNCTION csvsep(x)
RETURN scCsvSep if x == NIL
scCsvSep := x
RETURN .t.
* RETURN iif(slExcelUser,";",",")

#endif DEF_PRINT


FUNCTION ddBefore()
if sbBefore != NIL
  eval(sbBefore) // ad[AD_BEFORE])
endif
RETURN NIL

FUNCTION ddAfter()
if sbAfter != NIL
  eval(sbAfter) // ad[AD_AFTER])
endif
RETURN NIL

FUNCTION ddSeek(id,lSoft)
local nOrder := indexord()
local lOkay
ddSetOrder(1)
lOkay := dbseek(id,lSoft)
ddSetOrder(nOrder)
RETURN lOkay

**
**
FUNCTION ddGoTop()
* LogConsole("20071025 ddGoTop()")
if snRequest == DDEDIT_BROWSE
  soBrowse:goTop()
  ddRefreshAll()
else
  // soBrowse:goTop() // 20070307
  eval(soBrowse:goTopBlock)
endif
RETURN .t. // SetMnuDone()

**
**
FUNCTION ddGoBottom(lRefresh)
* LogConsole("20071025 ddGoBottom()")
if lRefresh .and. snRequest == DDEDIT_BROWSE
  slIsEof := .f.
  soBrowse:goBottom()
  ForceStable()
else
  // soBrowse:goBottom() // 20070307
  eval(soBrowse:goBottomBlock)
endif
RETURN .t.


* FUNCTION ddUpdate(cFldName)
* snRecStat := RS_UNKNOWN
* LastGet(cFldName)
* ddPostEdit(soBrowse:cargo)
* ddRefreshCurrent(soBrowse:cargo)
* RETURN NIL

*FUNCTION ddFullScreen(ad, cTitle, bAfter, cIdQry)
*local nSaveMode := snMode
*local cSaveLeg := scLeg
*default cIdQry to ad[AD_CURQRY]
*default cIdQry to ad[AD_NAME]
*QryLoad(ad,cIdQry)
*scLeg := " "
*scLeg := padr(" " + MSG017,74) + "≥ "
*scLeg += ad[AD_NAME]
*if ddIsCommon(ad)
*  scLeg += "*"
*endif
*snMode := DDMODE_EDIT
*ddPage(ad,cTitle,.t.,bAfter)
*snMode := nSaveMode
*scLeg := cSaveLeg
*RETURN NIL

STATIC FUNCTION ddSetKey(qry,cKeyValue,xcKey,xlFilter)
if qry[QRY_KEYVALUE] != NIL
  if cKeyValue != NIL
    scKeyValue:=cKeyValue // 20061012 fÅr SPZ\PARPICK6.QRY
  endif
  RETURN .f. if (cKeyValue := xparse(qry[QRY_KEYVALUE])) == NIL
  xcKey     := qry[QRY_KEY]
endif
if qry[QRY_ORDER] != 0
  ddSetOrder(qry[QRY_ORDER])
  // Wenn der neue index eine for-klausel hat, die den aktuellen Record
  // unsichtbar macht, dann nÅtzet hier auch kein "skip 0"
endif
if cKeyValue == NIL
  sxcKey := '""'
  scKeyValue := ""
else
  scKeyValue := cKeyValue
  default xcKey to "left(" + indexkey() + "," + ntrim(len(cKeyValue)) + ")"
  sxcKey := xcKey
endif
if qry[QRY_FILTER] == NIL
  default xlFilter to ".t."
  sxlFilter := xlFilter
else
  sxlFilter := xparse(qry[QRY_FILTER])
endif
#ifdef __XPP__
  if QRYATTR_D $ qry[QRY_ATTRIB]
    DbSetDescend(.t.)
  endif
#endif __XPP__
RETURN .t.

* FUNCTION ChkKeyValue()
FUNCTION ddCheckWhile ; RETURN (&sxcKey == scKeyValue)


#ifdef DEF_REPLACE

FUNCTION ddEditReplace()
local cDecide := "Y"
local fld
local oCol := soBrowse:getColumn(soBrowse:colPos)
local blReplace
local xcWas, xcWomit
static cWas := NIL
static cWomit := NIL
RETURN !SetMsg("Find/Replace : not allowed in virtual columns!") ;
  if oCol:cargo[COL_FLDHANDLE] == 0
fld := saData[AD_FIELDS][ocol:cargo[COL_FLDHANDLE]]
RETURN !SetMsg("Find/Replace : not allowed in virtual columns!") ;
       if FLDATTR_V $ fld[AG_ATTRIB]
RETURN !SetMsg("Find/Replace : only in char or memo fields!") ;
       if ! fld[AG_TYPE] $ "CM"
default cWas   to space(50)
default cWomit to space(50)
open window ('Replace in field "'+fld[AG_NAME]+'"') size 5,60
say "find : "
@ row(), col() get cWas
WinCr()
say "replace with : "
@ row(), col() get cWomit
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
xcWas := alias()+"->"+fld[AG_NAME]
xcWomit := "strtran("+alias()+"->"+fld[AG_NAME]+",";
  +utos(trim(cWas))+","+utos(trim(cWomit))+")"
blReplace := cblock("("+xcWas+":="+xcWomit+")!=NIL")
RETURN ddScan({||;
  cDecide!="Q".and.(cDecide=="A".or.(;
    cDecide:=Decide("QYNA",;
      "On record "+ntrim(recno())+", replace "+utos(&xcWas),;
      "with "+utos(&xcWomit));
  )!=NIL).and.(!(cDecide$"AY").or.TryRecLock(blReplace))})

#endif DEF_REPLACE

FUNCTION ddLastReq    ; RETURN snLastRequest
FUNCTION ddMode       ; RETURN snMode
FUNCTION ddLastKey    ; RETURN snLastKey
FUNCTION ddKeyValue() ; RETURN scKeyValue
FUNCTION ddRecStat()  ; RETURN snRecStat
FUNCTION ddSkip(n)    ; RETURN eval(soBrowse:skipBlock,n)


FUNCTION ddAlias()
RETURN "" if soBrowse == NIL
RETURN saData[AD_NAME]

FUNCTION ddScroll(n)
soBrowse:rowpos += n
soBrowse:configure()
RETURN NIL

FUNCTION ddSetFilter(xlFilter,cFltText)
RETURN sxlFilter if xlFilter == NIL
* LogConsole("20071025 ddSetFilter() "+utos(xlFilter))
sxlFilter := xlFilter
scFltText  := cFltText
slMustScan := .t.
if !eof().and.!bof()
  slIsEof := .f.
  do while ! xparse(sxlFilter)
    if eof().or.bof() .or. !ddCheckWhile()
      slIsEof := .t.
      exit
    endif
    skip // ddSkip(1) // 20070519  skip
  enddo
endif
*if ! &sxlFilter
*  if snStart == 2 // start bottom
*    ddGoBottom(.t.)
*  elseif snStart == 1 // start top
*    ddGoTop()
*  else
*    do while ddCheckWhile() .and. ! eof()
*      if &sxlFilter
*        exit
*      endif
*      skip
*    enddo
*  endif
* 20070524 if slIsEof
// soBrowse:invalidate() // neu seit 20071025
// soBrowse:configure() //  seit 20071025
if eof().or.bof()
  * LogConsole("20071025 eof() or bof() after skip")
  * QuickStabilize() // seit 20071025
  slIsEof := .f.
  if snStart == 2 // start bottom
    ddGoBottom(.t.)
  else
    ddGoTop()
  endif
else
  // Cursor bleibt auf dem aktuellen Record stehen. Aber falls durch das
  // Aufheben eines bestehenden Filters jetzt mehr Records sichtbar
  // werden, verschiebe ich den Cursor nach ganz unten, damit in
  // ddRefreshAll() dann mîglichst viele der neuen records sichtbar
  // werden
  QuickStabilize()
  soBrowse:rowPos := soBrowse:rowCount
  * soBrowse:configure() //  raus seit 20071002
  ddRefreshAll()
endif
RETURN NIL

FUNCTION FltText()
RETURN scFltText

FUNCTION SetFltText(cNewText)
RETURN scFltText if cNewText == NIL
scFltText := cNewText
ddSayStatus()
RETURN .t.


**
**
FUNCTION KeyGoTop(cKey,cKeyExpr,xlFilter)
local i
default xlFilter to ".t." // sxlFilter
if saRecnos == NIL
  #ifdef __XPP__
    if empty(cKey)
      go top
    else
      dbseek(cKey,.f.,NIL,dbdescend())
    endif
    do while !eof() .and. !bof() .and. ! &xlFilter ;
                    .and. left( &cKeyExpr, len(cKey) ) == cKey
      skip
    enddo
  #else
    softseek cKey
    do while !eof() .and.!bof() .and. ! &xlFilter ;
                     .and. left( &cKeyExpr, len(cKey) ) == cKey
      skip
    enddo
  #endif
else
  i := 1
  do while i <= len(saRecnos)
    goto saRecnos[i]
    if left( &cKeyExpr, len(cKey) ) == cKey .and. &xlFilter
      snRecno := i
      slIsEof := .f.
      exit
    endif
    i += 1
  enddo
endif
if left( &cKeyExpr, len(cKey) ) != cKey
  goto lastrec() + 1
  snRecno := 0
  slIsEof := .t.
endif
RETURN NIL

**
** KeyGoBottom()
**
FUNCTION KeyGoBottom(cKey,cKeyExpr,xlFilter)
local i
default xlFilter to ".t." // sxlFilter
if saRecnos == NIL
  #ifdef __XPP__
    * if empty(cKey) // bis 20071009
    if len(cKey) == 0
      go bottom
    else
      dbseek(cKey,.f.,NIL,!dbdescend())
    endif
    do while !eof() .and.!bof()  .and. ! &xlFilter ;
                    .and. left( &cKeyExpr, len(cKey) ) == cKey
      skip -1
    enddo
  #else
    softseek NextStr(cKey)
    skip -1
    do while !eof() .and. ! bof() .and. ! &xlFilter ;
                    .and. left( &cKeyExpr, len(cKey) ) == cKey
      skip -1
    enddo
  #endif
else
  i := len(saRecnos)
  do while i > 0
    goto saRecnos[i]
    if left( &cKeyExpr, len(cKey) ) == cKey .and. &xlFilter
      slIsEof := .f.
      snRecno := i
      exit
    endif
    i -= 1
  enddo
endif
if left(&cKeyExpr,len(cKey)) != cKey
  slIsEof := .t.
  goto lastrec() + 1
  snRecno := 0
endif
RETURN NIL

STATIC FUNCTION ddQryWait(qry)
local i
StaDisp2(ntrim(recno()) + "/" + ntrim(lastrec()))
RETURN NIL if snRequest != DDEDIT_BROWSE // [960620]
* if qry[QRY_WAITWIN] != NIL .and. saData[AD_WAITBLOCK] != NIL
RETURN NIL if ! DoEvents(saData[AD_ONQRYWAIT])
if saData[AD_WAITBLOCK] != NIL
  for i := 1 to len(qry[QRY_WAITWINLIST])
    eval(saData[AD_WAITBLOCK],qry[QRY_WAITWINLIST][i])
  next i
endif
if ! SetDialog()
  * inkey(0.5)
  SendKey(K_F10)
endif
* eval(sbOnQryWait)
RETURN NIL

// used by doeach.act

*FUNCTION SetOnQryWait(x)
*RETURN sbOnQryWait if x == NIL
*sbOnQryWait := x
*RETURN .t.


FUNCTION ddRequest
RETURN snRequest

FUNCTION ddSetUpdated(lNew)
RETURN saData[AD_UPDATED] if lNew == NIL
saData[AD_UPDATED] := lNew
RETURN .t.

* FUNCTION ddScrollDown
* soBrowse:rowPos

FUNCTION MsgRecDelete
#ifdef LG_GERMAN
  RETURN "DrÅcken Sie J um den Record zu lîschen :"
#endif
#ifdef LG_FRENCH
  RETURN "Tapez O pour supprimer l'enregistrement :"
#endif
#ifdef LG_EN
  RETURN "Type Y to delete the record :"
#endif

FUNCTION MemoOffset(bGetSet,nWidth,x)
RETURN memoline(eval(bGetSet),nWidth,snSkipOffset+1) if x == NIL
RETURN eval(bGetSet,x)


FUNCTION ddDebug
open window ("debug") size 9,70
say "alias()    : " + alias()      ; WinCr()
say "indexkey() : " + indexkey()   ; WinCr()
say "sxcKey     : " + sxcKey       ; WinCr()
say "scKeyValue : " + scKeyValue   ; WinCr()
say "sxlFilter  : " + sxlFilter    ; WinCr()
nKey := waitkey()
close window
RETURN NIL

FUNCTION MsgReadOnly()
#ifdef LG_GERMAN
RETURN "Hier dÅrfen Sie nichts verÑndern !"
#else
RETURN "Il est interdit de modifier ici !"
#endif

FUNCTION ddAutoRefresh()
RETURN .t. if len(saKeyStack) > 0
RETURN ddSendKey(K_ALT_F5)

FUNCTION ddNextKey
local nKey
RETURN 0 if len(saKeyStack) == 0
nKey := saKeyStack[1]
adel(saKeyStack,1)
asize(saKeyStack,len(saKeyStack)-1)
RETURN nKey

FUNCTION ddSendKey(nKey)
aadd(saKeyStack,nKey)
RETURN .t.

FUNCTION ddKillKey(nKey)
saKeyStack := {}
RETURN .t.


**
** DbfCreate()
**
FUNCTION DbfCreate(ad)
local nRecNo := save_recno()
local nOrder := indexord()
local nCreate
local lOkay := .f.
local lIsEof := eof().or.bof()
RETURN .f. if ! DoEvents(ad[AD_PRECREATE])
if ad[AD_CREATE] == NIL
  if dbAddRec()
    SetMsg(MSG_011)
    lOkay := .t.
  endif
else
  * ddSetOrder(1)
  nCreate := eval( ad[AD_CREATE] )
  * ddSetOrder (nOrder)
  if nCreate == DDCREATE_FAIL
    rest_recno(nRecNo)
    * if lIsEof
    *   goto lastrec() + 1 // falls nÑmlich nRecNo mittlerweile schon nicht
    *                      // mehr == lastrec() + 1 ist, weil andere
    *                      // Benutzer inzwischen records erstellt haben
    * else
    *   goto nRecNo
    * endif
    RETURN .f.
  endif
endif
DoEvents(ad[AD_ONCREATE],ad[AD_NAME]+":onCreate")
unlock record
RETURN .T.

** ddColumn() - wird benutzt in Worriken
FUNCTION ddColumn
RETURN soBrowse:colPos

FUNCTION ddScrollCursor(n)
default n to 1
if soBrowse:rowPos + n <= soBrowse:rowCount
  soBrowse:rowPos += n
  soBrowse:configure() // invalidate()
endif
RETURN .t.

FUNCTION GetPrimaryKey()
RETURN saData[AD_AINDEX][1][AI_EXPR]

FUNCTION SetExcelUser(x)
if x == NIL ; RETURN slExcelUser ; endif
slExcelUser := x
scCsvSep := iif(slExcelUser,";",",")
RETURN .t.


