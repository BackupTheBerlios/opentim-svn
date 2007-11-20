**
** File Name ...... : PRINTTPL.PRG
** Application .... : LIB
** Description .... :
** Copyright ...... : Luc Saffre, P.A.C. Systems, Eupen, Belgium
**
#include "Lib.ch"

#ifdef LG_FRENCH
  * #define MSG001  "Aujourd'hui (date du jour)"
  * #define MSG002  "Utilisateur (Nom complet)"
  * #define MSG003  "Utilisateur (Fonction)"
  * #define MSG004  "Licence : Nom 1"
  * #define MSG005  "Licence : Nom 2"
  * #define MSG006  "Licence : Nom 3"
  * #define MSG007  "= (Expression)"
  * #define MSG008  "Aller … <Ligne>"
  * #define MSG009  "Saut de page"
  #define MSG010  "S‚lection Code de masque"
  #define MSG011  "Automatic Pitch Select"
  #define MSG012  "Largeur requise (en caract./ligne) : "
  #define MSG013  "Aucune commande de masque n'est active pour l'instant."
  #define MSG014  "D‚marrez une impression pour activer des commandes de masque !"
#else
  * #define MSG001  "Heute (Tagesdatum)"
  * #define MSG002  "Benutzer : voller Name"
  * #define MSG003  "Benutzer : Funktion   "
  * #define MSG004  "Lizenz : Name 1"
  * #define MSG005  "Lizenz : Name 2"
  * #define MSG006  "Lizenz : Name 3"
  * #define MSG007  "= (Ausdruck)"
  * #define MSG008  "GeheZu <Zeile>"
  * #define MSG009  "Seitenumbruch"
  #define MSG010  "Auswahl Maskenbefehl"
  #define MSG011  "Automatic Pitch Select"
  #define MSG012  "Ben”tigte Breite (Zeichen/Zeile) : "
  #define MSG013  "Momentan sind keine Maskenbefehle zur Auswahl definiert."
  #define MSG014  "Starten Sie einen Ausdruck, damit Maskenbefehle aktiviert werden !"
#endif

**
** Bemerkung :
**
** Folgende Funktionen werden hier zwar aufgerufen, mssen jedoch
** in der Applikation definiet werden :
**
** FUNCTION PickTpl(cIdMsk,cLangue)
** FUNCTION TplGetInfo(...)
** ...
**


static scLangue  := LANGUE1
static saCommands  := {}

FUNCTION TplLang ; RETURN scLangue


#ifdef DEF_LOGIN

* FUNCTION UsrFonction(cIdUsr)
* if     scLangue == MemLang2 ; RETURN UserFct2(cIdUsr)
* elseif scLangue == MemLang3 ; RETURN UserFct3(cIdUsr)
* elseif scLangue == MemLang4 ; RETURN UserFct4(cIdUsr)
* else                        ; RETURN UserFct1(cIdUsr)
* endif
* RETURN ""

#endif DEF_LOGIN

#ifdef DEF_TPL

**
** TplExec()
**
** Execute each Line of cTpl
**
** cTpl is a memo string, containing CR,LF and other control chars
**
FUNCTION TplExec(cTpl,cParam,cBefore,aLines)
local nPos
local nLeftIndent := SetLeftIndent()
local cLine := ""
RETURN NIL if empty(cTpl)
if cBefore != NIL
  SetLeftIndent(len(cBefore))
endif
cTpl := hardcr(cTpl) + CR_LF
do while (nPos := at(CR_LF,cTpl)) != 0
  cLine += left(cTpl,nPos-1)
  if right(cLine,1) == "\"
    cLine := left(cLine,len(cLine)-1)
  else
    LineExec(cLine,aLines)
    cLine := ""
  endif
  cTpl := substr(cTpl,nPos+2)
enddo
SetLeftIndent(nLeftIndent)
RETURN NIL



STATIC FUNCTION LineExec(cLine,aLines)
local nPos1
local nPos2
local cNewLine := ""
local cRetVal
local i
local cCode
local cParam
do while (nPos1 := at("{",cLine)) != 0
  cNewLine += left(cLine,nPos1-1)
  cLine := substr(cLine,nPos1)
  if substr(cLine,2,1) == "="
    nPos2 := at("}",cLine)
    cCode  := "="
    cParam := ltrim(substr(cLine,3,nPos2-3))
  else
    nPos1 := at(" ",cLine)
    nPos2 := at("}",cLine)
    if nPos1 == 0 .or. nPos1 > nPos2
      cCode  := upper(substr(cLine,2,nPos2-2))
      cParam := ""
    else
      cCode  := upper(substr(cLine,2,nPos1-2))
      cParam := substr(cLine,nPos1+1,nPos2-nPos1-1)
    endif
  endif
  cRetVal  := NIL
  for i := 1 to len(saCommands)
    if upper(saCommands[i][1]) == cCode
      cRetVal := eval(saCommands[i][2],cParam,cNewLine)
      RETURN NIL if cRetVal == NIL
      ** dann war es n„mlich ein Befehl, der nichts ersetzt, sondern
      ** selbst die n”tigen PrintLines() aufruft. In diesem Fall wird
      ** die Zeile hier ignoriert.
      exit
    endif
  next i
  if cRetVal == NIL
    cNewLine += left(cLine,nPos2)
  else
    cNewLine += cRetVal
  endif
  cLine := substr(cLine,nPos2+1)
enddo
cNewLine += cLine
if aLines == NIL
  PrintLine(cNewLine)
else
  aadd(aLines,cNewLine)
endif
RETURN NIL


FUNCTION TplInit(cLangue)
if cLangue != NIL
  scLangue := cLangue
endif
saCommands := {}
TplAddCommand("="     , {|x| EvalMac(x) }, NIL )
TplAddCommand("Ligne" , {|x| SkipToLine(x) }, NIL )
TplAddCommand("Font"  , {|x| FontCtrl(x) }, {|| PickFont("") } )
TplAddCommand("FF"    , {|| EjectPage() }, NIL )
TplAddCommand("APS"   , {|x| ChangeLnWidth(val(x)) }, {|| GetWidth() } )
TplAddCommand("Printer" , {|x| SetLptActive(x) }, {|| GetLptActive() } )
#ifdef DEF_LOGIN
  TplAddCommand("DateJour" , {|| dtoc(UserDate()) } , NIL )
  TplAddCommand("LoginDate", {|| dtocf(UserDate(),scLangue) } , NIL )
  * TplAddCommand("Auteur" , {|| UserName() }            , NIL )
  TplAddCommand("UserName" , {|| UserName() }            , NIL )
#endif DEF_LOGIN
#ifdef DEF_BRAND
  TplAddCommand("Licence1" , {|| MrkStr1 }, NIL  )
  TplAddCommand("Licence2" , {|| MrkStr2 }, NIL  )
  TplAddCommand("Licence3" , {|| MrkStr3 }, NIL  )
#endif DEF_BRAND
RETURN NIL

FUNCTION TplAddCommand(cCode,bCommand,bPick)
local i
local a := { cCode, bCommand, bPick }
for i := 1 to len(saCommands)
  if upper(saCommands[i][1]) == upper(cCode)
    saCommands[i] := a
    RETURN NIL
  elseif upper(saCommands[i][1]) > upper(cCode)
    aadd(saCommands,NIL)
    ains(saCommands,i)
    saCommands[i] := a
    RETURN NIL
  endif
next i
aadd(saCommands, a )
RETURN NIL

FUNCTION TplPickCommand
local c
local cPick
local i := 2
static snLastChoice := 0
if len(saCommands) == 0
  Warning(MSG013,MSG014)
  RETURN NIL
endif
browse array saCommands ;
       using {|x| padr(x[1],20) } ;
       start snLastChoice ;
       help  "TPL" ;
       title (MSG010)
if LastChoice() == 0
  keyboard ""
  RETURN NIL
endif
snLastChoice := LastChoice()
c := "{" + saCommands[snLastChoice][1]
if saCommands[snLastChoice][3] == NIL
  keyboard c + "}"
else
  if (cPick := eval(saCommands[snLastChoice][3])) != NIL
    c += " " + cPick
    keyboard c + "}"
  endif
endif
RETURN NIL


FUNCTION PrintTemplate(cIdTpl,lAskPrinter)
default lAskPrinter to .t.
if lAskPrinter
  open printer template (cIdTpl)
else
  open printer noask template (cIdTpl) // idem
endif
close printer
RETURN MENU_DONE

FUNCTION GetWidth
local cWidth := space(3)
open window (MSG011) size 3,50 help APS
say MSG012
get cWidth GET_NUM
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
RETURN NIL if empty(cWidth)
RETURN NIL if val(cWidth) == 0
RETURN alltrim(cWidth)

**
** dtocf()
**
FUNCTION dtocf(dDate,cLangue)
local cSep := "/"
RETURN space(10) if empty(dDate)
if cLangue == "D"
  cSep := "."
endif
RETURN strtran(str(day(dDate),2)," ","0") + cSep + ;
       strtran(str(month(dDate),2)," ","0") + cSep + ;
       str(year(dDate),4)

FUNCTION GetLptActive()
RETURN ArrayPick({;
 "OFF",   ;
 "ON"  ;
})

#endif DEF_TPL

/*************** experimente ...


**
** TplExec2()
**
** Execute each Line of cTpl
**
** cTpl is a memo string, containing CR,LF and other control chars
**
FUNCTION ___TplExec(cTpl,cParam,cBefore,aLines)
local nPos
local nLeftIndent := SetLeftIndent()
local cLine := ""
RETURN NIL if empty(cTpl)
if cBefore != NIL
  SetLeftIndent(len(cBefore))
endif
cTpl := hardcr(cTpl) + CR_LF
do while (nPos := at(CR_LF,cTpl)) != 0
  cLine += left(cTpl,nPos-1)
  if right(cLine,1) == "\"
    cLine := left(cLine,len(cLine)-1)
  else
    LineExec(cLine,aLines)
    cLine := ""
  endif
  cTpl := substr(cTpl,nPos+2)
enddo
SetLeftIndent(nLeftIndent)
RETURN NIL

... experimente ...

FUNCTION ___MemoParse(cMemo,aCommands,cNewMemo)
local nPos1
local nPos2
local nLen
local cCode
local cParam
local cRetVal
local i
local lFound
local cChar
local cOldChar
default cNewMemo to ""
do while (nPos1 := at("{",cMemo)) != 0
  **
  ** zun„chst wird das Stck bis *vor* den ersten "{" unver„ndert
  ** bernommen :
  cNewMemo += left(cMemo,nPos1-1)
  cMemo := substr(cMemo,nPos1)
  **
  ** Jetzt muss ich den schliessenden "}" ausfindig machen. Das ist
  ** nicht unbedingt der n„chste. {}-Codes sollen ja erstens
  ** ineinandergeschachtelt sein drfen, und zweitens soll "\" als
  ** Escape-Zeichen dienen
  **
  nPos2 := 0         // nPos2 : Position des schliessenden "}"
                     // 0  : noch nicht gefunden
                     // -1 : sogar noch einen weiteren ”ffnenden "{"
                     //      gefunden (also den n„chsten schliessenden
                     //      nicht nehmen.
                     // > 0 : nPos2 enth„lt die gesuchte Position
  i := 2
  nLen := len(cMemo) // weil cMemo recht lang sein k”nnte
  do while nPos2 <= 0 .and. i <= nLen
    cOldChar := cChar
    cChar := substr(cMemo,i,1)
    if cChar == "{" .and. cOldChar != "\"
      nPos2 --  // einen nesting-level rauf schalten
    elseif cChar == "}" .and. cOldChar != "\"
      nPos2++
      if nPos2 > 0
        nPos2 := i
        exit
      endif
    elseif cChar == chr(13) .and. cOldChar != "\"
      ** Ein Maskenbefehl darf nicht auf mehrere Zeilen verteilt sein
      ** CR_LF ist also auch ein implizites Maskenbefehl-Ende
      ** Ausser wenn die CR_LFs durch "\" escaped werden.
      nPos2 := i
      exit
    endif
    i++
  enddo
  ** nPos1 wird jetzt benutzt, um eventuelle Befehlsparameter zu
  ** identifizieren.
  nPos1 := at(" ",cMemo)
  if nPos1 == 0 .or. nPos1 > nPos2
    cCode  := upper(substr(cMemo,2,nPos2-2))
    cParam := ""
  else
    cCode  := upper(substr(cMemo,2,nPos1-2))
    cParam := substr(cMemo,nPos1+1,nPos2-nPos1-1)
  endif
  cRetVal := NIL
  lFound  := .f.
  for i := 1 to len(aCommands)
    if aCommands[i][1] == cCode
      cRetVal := eval(aCommands[i][2],cParam,cNewMemo)
      lFound := .t.
      ** dann war es n„mlich ein Befehl, der nichts ersetzt, sondern
      ** selbst die n”tigen PrintLines() aufruft. In diesem Fall wird
      ** die Zeile hier ignoriert.
      exit
    endif
  next i
  if lFound
    if cRetVal == NIL
      cMemo := substr(cMemo,nPos2+1)
      if empty(memoline(cMemo,76,1))
        cMemo := substr(cMemo,3)
      endif
    else
      cNewMemo += cRetVal
      cMemo := substr(cMemo,nPos2+1)
    endif
  else
    cNewMemo += left(cMemo,nPos2)
    cMemo := substr(cMemo,nPos2+1)
  endif
enddo
cNewMemo += cMemo
RETURN cNewMemo

... experimente  **************/
