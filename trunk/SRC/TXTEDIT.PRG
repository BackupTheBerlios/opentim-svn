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

#include "memoedit.ch"
#include "LIB.CH"

#ifdef LG_FRENCH
  #define MSG001 " [Esc] Abandon ≥ [F10] Fin & sauvegarde ≥ [Alt-F1] Aide"
  #define MSG002 "Ecrire fichier ASCII"
  static MSG003 := "Nom du fichier : "
  #define MSG004 "Fichier "
  #define MSG005 " : succäs."
  #define MSG006 " : erreur d'Çcriture "
  #define MSG007 "Lire fichier ASCII"
  #define MSG008 " : erreur de lecture."
  #define MSG009 "Sauvegarder les modifications (O/N) ?"
#else
  #define MSG001 " [Esc] Abbrechen ≥ [F10] Ende & speichern ≥ [Alt-F1] Hilfe"
  #define MSG002 "ASCII-Datei schreiben"
  static MSG003 := "Dateiname : "
  #define MSG004 "Datei "
  #define MSG005 " : OK."
  #define MSG006 " : Schreibfehler "
  #define MSG007 "ASCII-Datei laden"
  #define MSG008 " : Lesefehler."
  #define MSG009 "énderungen im Text speichern (J/N) ?"
#endif

static scFileName := ""
static snBufRow := 1
static snBufCol := 0
static snWinRow := 0
static snWinCol := 0
static snRequest
static sbPick := {||BlkPick()}
* static saExit := NIL
static sbBlock := NIL
static scMemo    := NIL
static snWidth   := NIL

static slWrap     := .t.
static snTabSize := 8
static slIsBold   := .f.
static slIsItalic := .f.
static slIsUnder  := .f.

static slGetMode  := .f.

* static scExtFileName := ".\~MEMOTXT.TXT"


FUNCTION SetEditPick(x)
sbPick := x
RETURN .t.

*FUNCTION StdEditPick()
*local cReturn := BlkPick())
*local if (cReturn := BlkPick()) != NIL
*        keyboard cReturn
*      endif

**
** TxtEdit()
**
FUNCTION TxtEdit( ;
  bMemo, ;
  nTop, ;
  nLeft, ;
  nBottom, ;
  nRight, ;
  lEdit, ;
  nWidth, ;
  bNotUsed, ;
  lGetMode ;
)
local cReturn
local nPos, aPos
local nPos2
local nKey
local nSaveCursor := setcursor()
local lSaveGetMode := slGetMode
local cMemoCopy
local cSaveMemo := scMemo
local nSaveWidth := snWidth
local bInsKey := SetKey( K_INS, ;
  {|| setcursor( if(readinsert(!readinsert()), SC_NORMAL, SC_INSERT))};
)
local bInsKey2
local bF1Key := SetKey( K_F1, NIL)
default nWidth to (nRight-nLeft)
snWidth := nWidth
scMemo := eval(bMemo)
if empty(WinSetHelp())
  WinSetHelp("TXTEDIT")
endif
snBufRow := 1
snBufCol := 0
snWinRow := 0
snWinCol := 0
* sbPick := bPick
SayLeg(MSG001)
setcursor( if(readinsert(), SC_INSERT, SC_NORMAL) )   // (Luc)
default lGetMode to .f.
slGetMode := lGetMode
if lGetMode
  * SetKey( K_TAB, {|| SndKeys(chr(K_CTRL_W)) } )
  * SetKey( K_SH_TAB, {|| SndKeys(chr(K_CTRL_W)) } )
endif
                                                         #ifndef MONKEY
snRequest := TXT_EDIT
do while snRequest == TXT_EDIT
  scMemo := memoedit( ;
             scMemo, ;
             nTop, nLeft, nBottom, nRight, ;
             lEdit, "LSMEMO", ;
             snWidth, NIL, ;
             snBufRow, snBufCol, ;
             snWinRow, snWinCol )
  if ! lEdit
    if snRequest != TXT_ESCAPE .and. snRequest != TXT_EXIT
      // im read-only modus kommt man nur mit [Esc] oder F10 oder Alt-F4
      // raus. Nicht mit [Alt-Ins] oder [Alt-I]
      snRequest := TXT_EDIT
    endif
    loop
  endif
  do case
  case snRequest == TXT_UP
    eval(bMemo,scMemo)
  case snRequest == TXT_DOWN
    eval(bMemo,scMemo)
  case snRequest == TXT_EXIT
    eval(bMemo,scMemo)
  case snRequest == TXT_TOGGLE
    open window ("Einstellungen") size 3,50
    say "Zeilenbreite "
    get snWidth picture "###" range 0,255
    nKey := ReadScr()
    close window
    snRequest := TXT_EDIT
  case snRequest == TXT_COMMIT
    eval(bMemo,scMemo)
    if ! empty(alias())
      dbcommit()
    endif
    snRequest := TXT_EDIT
  case snRequest == TXT_PASTE
    cReturn := clipboard()
    if cReturn != NIL
      nPos  := mlctopos(scMemo,snWidth,snBufRow,snBufCol,snTabSize,slWrap)
      scMemo := left(scMemo,nPos-1)+cReturn+substr(scMemo,nPos)
      #ifdef __XPP__
      aPos := mpostolc(scMemo,snWidth,nPos+len(cReturn)+1,snTabSize,slWrap)
      #else
      aPos := mpostolc(scMemo,snWidth,nPos+len(cReturn),snTabSize,slWrap)
      #endif
      snWinRow += (aPos[1] - snBufRow)
      snWinCol += (aPos[2] - snBufCol)
      snBufRow := aPos[1]
      snBufCol := aPos[2]
      * snBufCol += len(cReturn)+1
      * snWinCol += len(cReturn)+1
      * if snWinCol > nRight - nLeft
      *   snWinCol := nRight - nLeft
      * endif
    endif
    snRequest := TXT_EDIT
  *case snRequest == TXT_F1
  *  nPos  := mlctopos(scMemo,snWidth,snBufRow,snBufCol,snTabSize,slWrap)
  *  bInsKey2 := SetKey( K_INS, NIL )
  *  if (cReturn := eval(sbPick)) != NIL
  *    scMemo := left(scMemo,nPos-1)+cReturn+substr(scMemo,nPos)
  *    snBufCol += len(cReturn)+1
  *    snWinCol += len(cReturn)+1
  *    if snWinCol > nRight - nLeft
  *      snWinCol := nRight - nLeft
  *    endif
  *    * keyboard cReturn
  *    * snRequest := TXT_COMMIT
  *  endif
  *  SetKey(K_INS, bInsKey2)
  *  snRequest := TXT_EDIT
  *case snRequest == TXT_ALT_INS
    * GetPasteBuffer()
    * snRequest := TXT_EDIT
    * snRequest := TXT_PASTE
  case snRequest == TXT_CTRL_INS
    nPos  := mlctopos(scMemo,snWidth,snBufRow,snBufCol,snTabSize,slWrap)
    if (nPos2 := at(CR_LF,substr(scMemo,nPos))) == 0
      clipboard(strtran(substr(scMemo,nPos),CHR_141))
    else
      clipboard(strtran(substr(scMemo,nPos,nPos2-1),CHR_141))
    endif
    snRequest := TXT_EDIT
    MsgDisplay(SetMsg())
  case snRequest == TXT_EXPORT
    open window (MSG002) size 3,52 help ASCII-E
    scFileName := padr(scFileName,30)
    say MSG003
    @ row(), col() get scFileName picture PIC_ID
    nKey := ReadScr()
    close window
    if nKey != K_ESC
      scFileName := alltrim(scFileName)
      if memowrit(scFileName,hardcr(scMemo))
        SetMsg(MSG004 + scFileName + MSG005 ) // success
      else
        SetMsg(MSG004 + scFileName + MSG006 + ntrim(ferror()) )
      endif
    endif
    snRequest := TXT_EDIT
  case snRequest == TXT_IMPORT
    open window (MSG007) size 3,51 help ASCII-I
    scFileName := padr(scFileName,30)
    say MSG003
    @ row(), col() get scFileName picture PIC_ID
    nKey := ReadScr()
    close window
    if nKey != K_ESC
      scFileName := alltrim(scFileName)
      cMemoCopy := memoread(scFileName)
      if empty(cMemoCopy)
        SetMsg( scFileName + MSG008 )
      else
        scMemo := cMemoCopy
      endif
    endif
    snRequest := TXT_EDIT
  case snRequest == TXT_EXTEDIT
    if (cMemoCopy := ext_edit(scMemo)) != NIL
      scMemo := cMemoCopy
    endif
    snRequest := TXT_EDIT
  endcase
enddo
* eval(bMemo,scMemo)
                                                      #endif  MONKEY
* #ifdef DEF_TPL
*   SetKey( K_F1 , NIL )
* #endif DEF_TPL
SetKey( K_INS, bInsKey )
SetKey( K_F1, bF1Key )
if lGetMode
  * SetKey( K_TAB, NIL )
  * SetKey( K_SH_TAB, NIL )
endif
slGetMode := lSaveGetMode
setcursor(nSaveCursor)
cMemoCopy := scMemo
scMemo := cSaveMemo
RETURN cMemoCopy


**
** LSMEMO - UDF for MemoEdit()
**
FUNCTION LSMEMO( nMode, nLine, nCol )
local bInsKey2
local nLastKey := lastkey()
* static snOldLine := 0
local cReturn
local i
local nPos
* ol_yield()
#ifdef __XPP__
  // Till Warweg 2007-03-26:
  #include "XBP.CH"
  #include "APPEVENT.CH"
  // Filter out non-keyboard events in the
  // user function
  IF (nMode==ME_UNKEY.OR.nMode==ME_UNKEYX) .AND. AppType()==APPTYPE_PM
    if LastAppEvent() == xbeK_SH_INS
      snRequest := TXT_PASTE
      RETURN K_CTRL_W
    elseif LastAppEvent() >= xbeB_Event
      * LogConsole("LSMEMO(non-keyboard) "+eventname(LastAppEvent()))
      RETURN ME_DEFAULT
    endif
  ENDIF
#endif
if nMode == ME_IDLE
  * LogConsole("LSMEMO(ME_IDLE)")
  SayMsg()
  LegDisp2( "L"+ ntrim(nLine) + " C" + ntrim(nCol+1) )
  * if saExit != NIL
  *   for i := 1 to len(saExit)
  *     RETURN K_CTRL_W if lastkey() == saExit[i]
  *   next i
  * endif
  #ifndef __XPP__
  if slGetMode
    if snRequest != TXT_UP .and. nLastkey == K_UP .and. nLine == 1 .and. snBufRow == 1
      snRequest := TXT_UP
      * RETURN K_CTRL_W
      keyboard chr(K_CTRL_W)
      RETURN NIL //
    endif
    * if lastkey() == K_DOWN .and. nLine > mlcount(scMemo)
    *   snRequest := TXT_DOWN
    *   keyboard chr(K_CTRL_W)
    *   RETURN NIL //
    * endif
  endif
  #endif __XPP__
endif
snBufRow := nLine
snBufCol := nCol
snWinRow := row()
snWinCol := col()
if nMode == ME_UNKEY .or. nMode == ME_UNKEYX
  // if nMode == ME_UNKEY
  //   LogConsole("LSMEMO(ME_UNKEY) "+utos(nLastkey))
  // else
  //   LogConsole("LSMEMO(ME_UNKEYX) "+utos(nLastkey))
  // endif
  if nLastkey == K_ESC .or. nLastkey == K_ALT_F4
    // 20090429 : xbase memoedit() meldet oft UNKEY statt UNKEYX, 
    // wenn der Text bereit verÑndert wurde. Workaround: ESC speichert
    // einfach stillschweigend auch immer ab. Also keine Mîglichkeit
    // mehr, die énderungen zu stornieren. Wird niemanden stîren.
    snRequest := TXT_EXIT
    RETURN K_CTRL_W
    if .f.
      snRequest := TXT_ESCAPE
      if nMode == ME_UNKEYX
        RETURN K_ESC if ! Confirm(MSG009)
        snRequest := TXT_EXIT
        RETURN K_CTRL_W
      else
        if nLastkey == K_ALT_F4
          AppTerminate(.t.)
        endif
        RETURN K_ESC
      endif
    endif
  endif
  if nLastkey == K_F1
    bInsKey2 := SetKey( K_INS, NIL )
    cReturn := eval(sbPick)
    SetKey(K_INS, bInsKey2)
    if cReturn != NIL
      clipboard(cReturn)
      snRequest := TXT_PASTE
      RETURN K_CTRL_W
    endif
    RETURN ME_IGNORE
    * RETURN K_CTRL_W
  endif
  *if nLastkey == K_F1
  *  snRequest := TXT_F1
  *  RETURN K_CTRL_W
    *SetKey( K_INS, NIL )
    *if (cReturn := eval(sbPick)) != NIL
    *  nPos := mlctopos(scMemo,snWidth,nLine,nCol,snTabSize,slWrap)
    *  scMemo := left(scMemo,nPos)+cReturn+substr(scMemo,nPos+1)
    *  snBufCol += len(cReturn)
    *  * keyboard cReturn
    *  snRequest := TXT_COMMIT
    *endif
    *SetKey( K_INS, ;
    *  {|| setcursor( if(readinsert(!readinsert()), SC_NORMAL, SC_INSERT))};
    *)
    ** RETURN ME_IGNORE
    *RETURN K_CTRL_W
  *endif
  if nLastkey == K_ALT_INS
    * SetMsg("(Alt-Ins)")
    snRequest := TXT_PASTE
    * snRequest := TXT_ALT_INS
    RETURN K_CTRL_W
  * elseif nLastkey == xbeK_SH_INS
  *   snRequest := TXT_PASTE
  *   RETURN K_CTRL_W
  elseif nLastkey == K_SH_TAB
    if slGetMode
      snRequest := TXT_UP
      RETURN K_CTRL_W
    endif
  elseif nLastkey == K_TAB
    if slGetMode
      snRequest := TXT_DOWN
      RETURN K_CTRL_W
    endif
  #ifdef __XPP__
  elseif slGetMode .and. nLastkey==K_UP .and. nLine==1 .and. snBufRow==1
    snRequest := TXT_UP
    RETURN K_CTRL_W
  #endif __XPP__
  elseif nLastkey == K_CTRL_INS
    snRequest := TXT_CTRL_INS
    RETURN K_CTRL_W
  *elseif lastkey() == K_ALT_B .or. lastkey() == K_F4 .or.lastkey() == K_F1
  *  SetKey( K_INS, NIL )
  *  if (cReturn := BlkPick()) != NIL
  *    keyboard cReturn
  *  endif
  *  SetKey( K_INS, ;
  *    {|| setcursor( if(readinsert(!readinsert()), SC_NORMAL, SC_INSERT))};
  *  )
  *  RETURN ME_IGNORE
  endif
  if nLastkey == K_F5
    if slIsBold ; keyboard Tagged("b") ; else ; keyboard Tagged("B") ; endif
    slIsBold := ! slIsBold
    RETURN ME_IGNORE
  endif
  if nLastkey == K_F6
    if slIsItalic ; keyboard Tagged("i") ; else ; keyboard Tagged("I") ; endif
    slIsItalic := ! slIsItalic
    RETURN ME_IGNORE
  endif
  if nLastkey == K_F7
    if slIsUnder ; keyboard Tagged("u") ; else ; keyboard Tagged("U") ; endif
    slIsUnder := ! slIsUnder
    RETURN ME_IGNORE
  endif
  * if nLastkey == K_F8
  *   cReturn := PickFont
  *   RETURN ME_IGNORE
  * endif
  if nLastkey == K_ALT_W
    snRequest := TXT_TOGGLE
    RETURN K_CTRL_W
  endif
  if nLastkey == K_ALT_E
    snRequest := TXT_EXPORT
    RETURN K_CTRL_W
  endif
  if nLastkey == K_F2
    snRequest := TXT_COMMIT
    RETURN K_CTRL_W
  endif
  if nLastkey == K_ALT_I
    snRequest := TXT_IMPORT
    RETURN K_CTRL_W
  endif
  if nLastkey == K_ALT_T
    snRequest := TXT_EXTEDIT
    RETURN K_CTRL_W
  endif
  if nLastkey == K_F10 .or. nLastkey == K_F3 .or. nLastkey == K_CTRL_W
    if snRequest == TXT_EDIT
      snRequest := TXT_EXIT
    endif
    RETURN K_CTRL_W
  endif
  if nLastkey == K_CTRL_DEL
    RETURN K_CTRL_Y
  endif
elseif nMode == ME_INIT
  // LogConsole("LSMEMO(ME_INIT) "+utos(nLastkey))
  snBufRow := 0
endif
RETURN ME_DEFAULT

**
** TxtExitState() wird in getsysph.prg abgefragt
**
FUNCTION TxtExitState
RETURN snRequest

FUNCTION SetTxtBlock(bBlock)
sbBlock := bBlock
RETURN NIL

FUNCTION MsgOverwrite()
#ifdef LG_GERMAN
RETURN " existiert. Datei Åberschreiben (J/N) ?"
#endif
#ifdef LG_FRENCH
RETURN " existe. Voulez-vous l'Çcraser (O/N) ?"
#endif
#ifdef LG_EN
RETURN " : overwrite existing file (Y/N) ?"
#endif

FUNCTION FileGetSet(cFileName,cMemo)
if cMemo == NIL
  RETURN memoread(cFileName)
endif
fwritememo(cFileName,hardcr(cMemo))
RETURN NIL

FUNCTION fwritememo(cFileName,cMemo)
#ifdef DEF_LFN
local fd := lf_fcreate(cFileName)
#else
local fd := fcreate(cFileName)
#endif
if fd == -1
  Warning(cFileName + MsgDosError(ferror()))
  RETURN .f.
endif
fwrite(fd,cMemo)
fclose(fd)
SetMsg(cFileName + " wurde gespeichert.")
RETURN .t.

FUNCTION SndKeys(c)
keyboard c
RETURN NIL
