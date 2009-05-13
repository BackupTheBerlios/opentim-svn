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
#include "DEFDATA.CH"
* #include "DIRECTRY.CH"

*#ifdef __XPP__
*  #ifdef DEF_ADS
*    static slNoPass := .t.
*  #else
*    static slNoPass := .f.
*  #endif
*#else
*  static slNoPass := .f.
*#endif



/************
  USR pre-edit abgeschaltet. Jeder kann USR bearbeiten, aber nur BOSS
  kriegt UsrEdit() aufgerufen.
  Oder UsrEdit() wird durch /USER aufgerufen, und dann ist ja
  noch gar kein Login gemacht worden.
***********/

#ifdef LG_FRENCH
  #define MSG001  "Login"
  #define MSG002  "Date"
  #define MSG003  "Identification"
  #define MSG004  "Code secret "
  static MSG005 := " se dÇconnecte le "
  * static MSG006 := " Ö "
  #define MSG007  "DonnÇes utilisateur "
  #define MSG008  "Nom complet "
  #define MSG009  " Fonction 1 "
  #define MSG010  "          2 "
  #define MSG011  "          3 "
  #define MSG012  "          4 "
  #define MSG013  "Code secret actuel  "
  #define MSG014  "Nouveau code secret "
  #define MSG015  "Encore une fois     "
  #define MSG016  "Code secret incorrect."
  #define MSG017  "Le nouveau code secret a ÇtÇ enregistrÇ."
  #define MSG018  "Les deux codes secrets ne sont pas identiques."
  #define MSG019  "Liste des utilisateurs"
  #define MSG021  " se connecte le "
  * #define MSG022  "Note : date de travail = "
  #define MSG023  "RÇorganisation impossible: d'autres utilisateurs sont actifs"
  #define MSG024  " est active en ce moment."
  #define MSG026  "Changer mot de passe "
  #define MSG027   "Date invalide !"
  #define MSG028  "La session "
  #define MSG029  ") a ÇtÇ interrompue !"
  * #define MSG030  "Tapez O pour rÇorganiser la base de donnÇes :"
  * #define MSG031  " : une session est dÇjÖ active!"
  #define MSG_USER_NOT_FOUND " : nom d'utilisateur inconnu !"
#endif
#ifdef LG_GERMAN
  #define MSG001  "Anmeldung"
  #define MSG002  "Datum"
  #define MSG003  "Benutzerkennung"
  #define MSG004  "Passwort "
  static MSG005 := " beendet Sitzung vom "
  * static MSG006 := " um "
  #define MSG007  "Benutzerangaben "
  #define MSG008  "Kompletter Name"
  #define MSG009  "     Funktion 1"
  #define MSG010  "              2"
  #define MSG011  "              3"
  #define MSG012  "              4"
  #define MSG013  "Passwort bisher    "
  #define MSG014  "Neues Passwort     "
  #define MSG015  "Bitte wiederholen "
  #define MSG016  "Falsches Passwort."
  #define MSG017  "Das neue Passwort ist ab jetzt gÅltig."
  #define MSG018  "Passwort und Wiederholung sind verschieden !"
  #define MSG019  "Benutzerliste"
  #define MSG021  " angemeldet am "
  * #define MSG022  "N.B. : Arbeitsdatum  = "
  #define MSG023  "Reorganisieren unmîglich solange andere Benutzer aktiv sind !"
  #define MSG024  " ist zur Zeit aktiv."
  #define MSG026   "Passwort Ñndern "
  #define MSG027   "Tagesdatum : ungÅltig !"
  #define MSG028  "Sitzung "
  #define MSG029  ") wurde unterbrochen !"
  * #define MSG030  "DrÅcken Sie J um die Datenbank zu reorganisieren :"
  * #define MSG031  " : eine Sitzung ist bereits aktiv!"
  #define MSG_USER_NOT_FOUND " : unbekannter Benutzername !"
#endif
#ifdef LG_EN
  #define MSG001  "Login"
  #define MSG002  "Date"
  #define MSG003  "User name"
  #define MSG004  "Password "
  static MSG005 := " ends session of "
  * static MSG006 := " at "
  * #define MSG007  "User settings "
  * #define MSG008  "Kompletter Name"
  * #define MSG009  "     Funktion 1"
  * #define MSG010  "              2"
  * #define MSG011  "              3"
  * #define MSG012  "              4"
  #define MSG013  "Current password   "
  #define MSG014  "New password       "
  #define MSG015  "re-type new passw."
  #define MSG016  "Falsches Passwort."
  #define MSG017  "Das neue Passwort ist ab jetzt gÅltig."
  #define MSG018  "Passwort und Wiederholung sind verschieden !"
  #define MSG019  "User List"
  #define MSG021  " logged in on "
  #define MSG024  " is active."
  #define MSG026   "Passwort Ñndern "
  #define MSG027   "Tagesdatum : ungÅltig !"
  #define MSG028  "Session "
  #define MSG029  ") has been interrupted !"
  #define MSG_USER_NOT_FOUND " : no such user !"
#endif

static scUserName  := ""
static scUserId    := ""
static scUserFct1  := ""
static scUserFct2  := ""
static scUserFct3  := ""
static scIdMnu     := ""
* static scUserFct4  := ""
static scUsrAttrib := ""
static scUsrLevel  := ""
static scAbtlg  := ""
static scGroups  := ""
static sdDate      := NIL

static scLogPath

#ifdef DEF_LOGFILE
  * static slLogFile := .F. // bestand schon vorher ein Logfile dieses Users?
  static snLogFile := -1
  static scLogFile
#endif

* static snUserCount := 0

#ifdef DEF_LOGIN

FUNCTION MsgUsrExist(cUserId)
RETURN '"' + trim(cUserId) + '"' + MSG_USER_NOT_FOUND

**
**
FUNCTION Login(lQuiet)
local nErrCount := 0
local c
local lOkay := .f.
local cPassWd := NIL // space(10)
local cPassword
local nRow, nCol
local dDate := date()
* local pcUserId := padr(GetAppEnv("USER"),LenIdUsr())
* local dDate := date()
local cIdUsr := padr(GetAppEnv("USER"),LenIdUsr())
default lQuiet to .f.
if ! AppPreLogin() // 20020121
  if empty(SetMsg())
    SetMsg("AppPreLogin failed")
  endif
  RETURN .f.
endif
#ifdef DEF_BRAND
  if ! empty(ptod(MrkInstall)) .and. dDate > ptod(MrkInstall)
    dDate := ctod("")
  endif
#endif
if lQuiet
  RETURN .t. if BecomeUser(cIdUsr,"")
  RETURN .f. if empty(SetMsg())
  RETURN !Warning("Quiet login failed:",SetMsg())
endif
open window (MSG001) size 4,53 home (maxrow()-9), NIL  help LOGIN   // centered horizontally
do while !lOkay
  * if nErrCount > 3
  *   SetMsg(utr("Your 3 trials are over",;
  *     "3 fehlgeschlagene Anmeldeversuche",;
  *     "3 essais de login ÇchouÇs"))
  *   exit
  * endif
  WinHome()
  @ CSR_POS say MSG002 get dDate // pick PickDate(sdDate)
  WinCR()
  * @ CSR_POS say MSG003 get pcUserId picture PIC_ID
  @ CSR_POS say MSG003 get cIdUsr picture PIC_ID
  nRow := row()
  nCol := col()
  nKey := ReadScr()
  if nKey == K_ESC .or. AppTerminate()
    exit
  endif
  if empty(dDate)
    SetMsg(MSG027)
    loop
  endif
  cPassword := DbfPeek(oUsr(),cIdUsr,"USR->Password",NIL)
  if cPassword == NIL
    SetMsg(MsgUsrExist(cIdUsr))
  elseif empty(cPassword) // .or. slNoPass
    lOkay := BecomeUser(cIdUsr,cPassword)
  else
    @ nRow, nCol say "  " + MSG004
    nRow := row()
    nCol := col()
    cPassWd := GetPassWd( nRow, nCol )
    if cPassWd == NIL // nKey == K_ESC
      exit
    endif
    lOkay := BecomeUser(cIdUsr,cPassWd)
  endif
  if ! lOkay
    nErrCount++
    loop
  endif
enddo
close window
sdDate := dDate
if sdDate == date()
  sdDate := NIL
endif
RETURN lOkay

FUNCTION BecomeUser(cIdUsr,cPasswd)
local lOkay := .f.
* default cPasswd to ""
if cPasswd == NIL
  default cIdUsr to UserId()
  if UserId() != cIdUsr
    RETURN !SetMsg("Password required to become another user.")
  endif
endif
open area oUsr()
  seek cIdUsr
  if eof()
    SetMsg(MsgUsrExist(cIdUsr))
  else
    if cPasswd == NIL // .or. slNoPass
      lOkay := .t.
    elseif empty(cPasswd).and.empty(USR->Password)
      lOkay := .t.
    elseif Encrypt(cPassWd) == USR->Password
      lOkay := .t.
    else
      SetMsg(utr("Wrong password",;
                 "Falsches Passwort",;
                 "Mot de passe incorrect"))
    endif
    if lOkay
      * readinsert( USR->InsMode )
      scUserId := cIdUsr
      * scUserId    := pcUserId
      scUserName  := trim(USR->Name)
      scUserFct1  := trim(USR->Fct1)
      scUserFct2  := trim(USR->Fct2)
      scUserFct3  := trim(USR->Fct3)
      scIdMnu     := trim(USR->IdMnu)
      * scUserFct4  := trim(USR->Fct4)
      scUsrAttrib := trim(USR->Attrib)
      if USRATTR_D $ scUsrAttrib
        * RptDetailed(.t.)
        SetKeepReport(.t.)
      endif
      SetReadOnly(USRATTR_R $ scUsrAttrib)
      scUsrLevel  := USR->Level
      SendConsole( ;
        trim(CfgDataBase()) + " : " + ;
        trim(scUserId) + MSG021 + dtoc(date())  ;
      )
    endif
  endif
close area
RETURN .f. if ! lOkay
RETURN OnLogin()


**
**
FUNCTION Logout(lMsg)
SaveDbVars()
default lMsg to .T.
RETURN NIL if empty(scUserId)
if lMsg
  * raus am 20030213
  *rpt_write( ;
  *  trim(CfgDataBase()) + " : " + ;
  *  trim(scUserId) + MSG005 + dtoc(date()) + MSG006 + time(), ;
  *  RPT_DISPLAY ;
  *)
  SendConsole( ;
    trim(CfgDataBase()) + " : " + ;
    trim(scUserId) + MSG005 + dtoc(date()) ;
  )
endif
RETURN NIL


**
** ChangePwd()
**
*FUNCTION ChangePwd
*local cName
*local cFct1
*local cFct2
*local cFct3
*local cFct4
*local nReturn := NIL
*open area oUsr()
*  seek scUserId
*  if ! eof()
*    if ddRecLock()
*      cName  := USR->Name
*      cFct1  := USR->Fct1
*      cFct2  := USR->Fct2
*      cFct3  := USR->Fct3
*      * cFct4  := USR->Fct4
*      open window (MSG007 + trim(scUserId)) size 7,40 help USRINFO
*      do while .t.
*        WinHome()
*        @ CSR_POS say MSG008 get cName
*        WinCR()
*        @ CSR_POS say MSG009 get cFct1
*        WinCR()
*        @ CSR_POS say MSG010 get cFct2
*        WinCR()
*        @ CSR_POS say MSG011 get cFct3
*        WinCR()
*        @ CSR_POS say MSG012 get cFct4
*        nKey := ReadScr()
*        if nKey == K_ESC
*          exit
*        endif
*        USR->Name   := cName
*        USR->Fct1   := cFct1
*        USR->Fct2   := cFct2
*        USR->Fct3   := cFct3
*        * USR->Fct4   := cFct4
*        scUserName  := trim(USR->Name)
*        scUserFct1  := trim(USR->Fct1)
*        scUserFct2  := trim(USR->Fct2)
*        scUserFct3  := trim(USR->Fct3)
*        * scUserFct4  := trim(USR->Fct4)
*        exit
*      enddo
*      close window
*      unlock record
*    endif
*  endif
*close area
*RETURN .f.


**
** UsrChangePwd()
**
FUNCTION UsrChangePwd(cIdUsr)
local cOldPwd
local cNewPwd1
local cNewPwd2
default cIdUsr to scUserId
open area oUsr()
  seek cIdUsr // scUserId
  if eof() ; break area ; endif
  if ddRecLock()
    open window (MSG026 + trim(cIdUsr)) size 5,40 help CHGPWD
    @ CSR_POS say MSG013
    cOldPwd := GetPassWd( row(), col() )
    if cOldPwd != NIL
      WinCR()
      @ CSR_POS say MSG014
      cNewPwd1 := GetPassWd( row(), col() )
      if cNewPwd1 != NIL
        WinCR()
        @ CSR_POS say MSG015
        cNewPwd2 := GetPassWd( row(), col() )
        if cNewPwd2 != NIL
          if Encrypt(cOldPwd) <> USR->PassWord .and. !empty(USR->PassWord)
            SetMsg(MSG016)
          else
            if cNewPwd1 == cNewPwd2
              if empty(cNewPwd1)
                USR->PassWord := ""
              else
                USR->PassWord := Encrypt(cNewPwd1)
              endif
              SetMsg(MSG017)
            else
              SetMsg(MSG018)
            endif
          endif
        endif
      endif
    endif
    close window
    unlock record
  endif
close area
RETURN .f.


**
** Encrypt
**
STATIC FUNCTION Encrypt( s1 )
local s2 := ""
local i
for i := 1 to len(s1)
  #ifdef DEF_ADS
    s2 += chr( 32 + ((asc(substr(s1,i,1)) + i) % 92 ))
    s2 += chr(32 + (i % 92))
  #else
    s2 += chr(255 - i - asc( substr(s1,i,1) ) )
    s2 += chr(i)
  #endif
next
RETURN s2

**
** GetPassWd
**
STATIC FUNCTION GetPassWd( nRow, nCol )
local cPassword := ""
local nPos := 0
local nKey
local nCursor := setcursor(SC_INSERT)
@ nRow,nCol say ".........."
do while .t.
  setpos(nRow,nCol+nPos)
  nKey := WaitKey()
  if nKey == K_ESC
    @ nRow, nCol say ".........."
    setcursor(nCursor)
    RETURN NIL
  endif
  if nKey > 32 .and. nKey < 255 .and. nPos < 10
    cPassword += chr(nKey)
    @ nRow, nCol + nPos say "*"
    nPos++
  endif
  if nKey == 8 .and. nPos > 0
    nPos--
    cPassword := left(cPassword,nPos)
    @ nRow, nCol + nPos say "."
  endif
  if nKey == K_RETURN
    exit
  endif
enddo
setcursor(nCursor)
RETURN padr(cPassword,10)


**
** UsrEdit
**
FUNCTION UsrEdit
local b := oUsr()
open area b
  edit data b ;
            title (MSG019) ;
            start top ;
            query "USR" ;
            mode DDMODE_FIND ;
            create {|| UsrCreate() }
close area
RETURN BecomeUser() 

FUNCTION UsrCreate
local aBuf := CopyRec()
local cIdUsr := USR->UserId
open window ("Create User") size 3,50 help USRCREA
say "User ID "
get cIdUsr picture PIC_ID
nKey := ReadScr()
close window
RETURN DDCREATE_FAIL if nKey == K_ESC
seek cIdUsr
if ! eof()
  SetMsg(cIdUsr + " : user id already exists")
  RETURN DDCREATE_FAIL
endif
RETURN DDCREATE_FAIL if ! dbAddRec()
PasteRec(aBuf)
USR->Password := ""
USR->UserId := cIdUsr
* unlock record
* endif
RETURN DDCREATE_REFRESH


**
** USR - Utilisateurs
**
FUNCTION oUsr()
** local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name USR
ddindex b on USR->UserId
ddFld UserId   ,C,  LenIdUsr(),0 picture PIC_ID when .f.
ddFld IdMnu    ,C,  5,0 picture PIC_ID
ddFld Birth    ,D,  8,0
ddFld Heure    ,C,  8,0 attrib H
ddFld Level    ,C,  1,0 picture "!"
ddFld Name     ,C, 20,0
ddFld Fct1     ,C, 20,0
ddFld Fct2     ,C, 20,0
ddFld Fct3     ,C, 20,0
ddFld Fct4     ,C, 20,0 attrib H
ddFld Password ,X, 20,0  
ddFld Attrib   ,C, 10,0  picture PIC_ID pick UsrPickAttrib(USR->Attrib)
ddEndDef()
RETURN b

FUNCTION UsrPickAttrib(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  * aadd(aAttrib,  { USRATTR_A, "Avertir si d'autres sessions actives    ", 0 } )
  aadd(aAttrib,  { USRATTR_B, "est l'administrateur du systäme         ", 0 } )
  aadd(aAttrib,  { USRATTR_C, "peut voir des donnÇes confidentielles   ", 0 } )
  aadd(aAttrib,  { USRATTR_D, ".rpt dÇtaillÇ                           ", 0 } )
  aadd(aAttrib,  { USRATTR_H, "est invisible pour d'autres utilisateurs", 0 } )
  aadd(aAttrib,  { USRATTR_L, "utilisateur limitÇ                      ", 0 } )
  aadd(aAttrib,  { USRATTR_O, "sans dialogue Options d'impression      ", 0 } )
  aadd(aAttrib,  { USRATTR_P, "prÇvisualisation activÇe par dÇfaut     ", 0 } )
  aadd(aAttrib,  { USRATTR_E, "Expert                                  ", 0 } )
  aadd(aAttrib,  { USRATTR_S, "Super-Utilisateur                       ", 0 } )
  aadd(aAttrib,  { USRATTR_Y, "Eviter les confirmations frÇquentes     ", 0 } )
  aadd(aAttrib,  { USRATTR_R, "cet utilisateur ne peut modifier        ", 0 } )
#else
  * aadd(aAttrib,  { USRATTR_A, "Warnung wenn andere Benutzer aktiv        ", 0 } )
  aadd(aAttrib,  { USRATTR_B, "Datenbankverwalter (Boss)                 ", 0 } )
  aadd(aAttrib,  { USRATTR_C, "kann vertrauliche Daten sehen             ", 0 } )
  aadd(aAttrib,  { USRATTR_D, "Detaillierter Bericht in .rpt             ", 0 } )
  aadd(aAttrib,  { USRATTR_H, "ist unsichtbar fÅr andere Benutzer        ", 0 } )
  aadd(aAttrib,  { USRATTR_L, "EingeschrÑnkter Benutzer                  ", 0 } )
  aadd(aAttrib,  { USRATTR_O, "Dialogfenster 'Druckoptionen' Åberspringen", 0 } )
  aadd(aAttrib,  { USRATTR_P, "Druckvorschau standardmÑ·ig eingeschaltet ", 0 } )
  aadd(aAttrib,  { USRATTR_E, "Experte                                   ", 0 } )
  aadd(aAttrib,  { USRATTR_S, "Super-User                                ", 0 } )
  aadd(aAttrib,  { USRATTR_Y, "HÑufige BestÑtigungen vermeiden           ", 0 } )
  aadd(aAttrib,  { USRATTR_R, "Benutzer darf nichts verÑndern            ", 0 } )
#endif
RETURN PickAttrib(aAttrib,"User attributes",cStart,"","USRATTR")

*FUNCTION UsrSetAttrib
*local cUsrAttrib
*if "L" $ scUsrAttrib
*  Alarm()
*  RETURN .f.
*endif
*cUsrAttrib := UsrPickAttrib(scUsrAttrib)
*RETURN .f. if cUsrAttrib == NIL
*scUsrAttrib := cUsrAttrib
*RETURN MnuDone()

#endif DEF_LOGIN


FUNCTION SetUserDate(d)
if d != date()
  sdDate := d
endif
RETURN .t.

FUNCTION UserDate
RETURN date() if sdDate == NIL
// default sdDate to date()
RETURN sdDate

FUNCTION UserId    ; RETURN scUserId
FUNCTION UserName  ; RETURN scUserName
FUNCTION UserFct1  ; RETURN scUserFct1
FUNCTION UserFct2  ; RETURN scUserFct2
FUNCTION UserFct3  ; RETURN scUserFct3
FUNCTION UsrIdMnu ; RETURN scIdMnu
* FUNCTION UserFct4  ; RETURN scUserFct4
FUNCTION UsrAttrib ; RETURN scUsrAttrib
FUNCTION UsrLevel  ; RETURN scUsrLevel

FUNCTION SetAbtlg(x)
RETURN scAbtlg if x == NIL
scAbtlg := x
RETURN .t.

FUNCTION SetGroups(x)
RETURN scGroups if x == NIL
scGroups := x
RETURN .t.

**
** GetAppEnv() : falls die DOS-Variable nicht gesetzt ist : TIM
**
FUNCTION GetAppEnv(cVarName)
* local cUserId := upper(trim(left(getenv(cVarName),8)))
local cUserId := upper(trim(left(getvar(cVarName),8)))
if empty(cUserId)
  cUserId := ProgName()
endif
RETURN cUserId

#ifdef DEF_LOGFILE

*FUNCTION MsgNoRebuild
*#ifdef LG_GERMAN
*  RETURN ;
*  "Wenn Sie hier unterbrechen, mÅssen Sie die Sammelhistorik" ;
*  + CR_LF + "zu einem spÑteren Zeitpunkt rekonstruieren."
*#else
*  RETURN ;
*  "Si vous interrompez maintenant, vous devez" ;
*  + CR_LF + "reconstruire les historiques mensuels plus tard."
*#endif

FUNCTION log_filename()
RETURN scLogFile

**
** LogOpen() - Check for other connections & open .log file
**
FUNCTION LogOpen()
local cLine
local aDir
local lAlone := .T.
local lInterrupt := .F.
local fd
local i
local cWarn
local cMemo := ""
local cSessId
local nUsrCount := 1
local nSessId := 0
local nTryCount := 0
if MrkMaxUsers > 1
  if empty(getvar("PC"))
    RETURN !SetMsg("Your PC environment variable is not set." ;
            + CR_LF + "Please contact your system administrator!")
  endif
endif
scLogPath := DbPath()
aDir := directory(scLogPath + "\*.LOG")
for i := 1 to len(aDir)
  cSessId := strtran(aDir[i][F_NAME],".LOG")
  nSessId := max(nSessId,val(cSessId))
  if (fd := fopen(scLogPath + "\" + aDir[i][1],FO_READWRITE+FO_EXCLUSIVE)) == -1
    lAlone := .F. // I am not alone
    nUsrCount++
    cMemo += MSG028 + cSessId + MSG024 + CR_LF
  *elseif cSessId == "IMPORT"
  *  cMemo += tr(;
  *    "Neu indexieren nach Import",;
  *    "RÇorganiser apräs  import",;
  *    "Reindex after import")
  *  lInterrupt := .T.
  else
    cLine := freadline(fd)
    fclose(fd)
    default cLine to ""
    cLine := trim(cLine)
    if len(cLine) < 20 // "@" $ cLine
      cSessId += " [" + cLine + "]"
    endif
    cMemo += MSG028 + cSessId + ;
        " (" + dtoc(aDir[i][F_DATE]) + " " + aDir[i][F_TIME] ;
        + MSG029 + CR_LF
    lInterrupt := .t. // Some session has been interrupted
  endif
next i
if nUsrCount > MrkMaxUsers
  #ifdef LG_GERMAN
    Warning( ;
      "Benutzerzahl Åberschritten.", ;
      "Maximal " + ntrim(MrkMaxUsers) + " Benutzer.", ;
      "WRN040" ;
    )
  #else
    Warning( ;
      "Trop d'utilisateurs simultanÇs.", ;
      "Votre license admet seulement " + ntrim(MrkMaxUsers) + " utilisateurs.", ;
      "WRN040" ;
    )
  #endif
  RETURN .f.
endif
nSessId += 1
do while snLogFile == -1
  scLogFile := scLogPath + "\" + ntrim(nSessId) + ".LOG"
  if (snLogFile := fcreate(scLogFile)) != -1
    /* 20021212 fcreate() leaves the file open in read/write + FO_COMPAT
    Bei gx zeigte ShowLogList() dann spÑter ?@? an.
    Deshalb îffnen wir die Datei jetzt mit "richtigem" Exklusivzugriff.
    Was immer das auch hei·en mag.
    */
    fclose(snLogFile)
    snLogFile := fopen(scLogFile,FO_READWRITE+FO_DENYWRITE)
  endif
  if snLogFile == -1
    nTryCount += 1
    /*
    20090420 TIM probiert jetzt (wie bei missglÅckten Record Locks)
    drei mal, bevor er den Benutzer mit einer Frage belÑstigt.
    */
    if nTryCount > 3 .and. ! Confirm( ;
      scLogFile+MsgDosError(ferror()), ;
      MsgRetry(), MSG_YES, "MSG003";
    )
      * slLogFile := .F.
      RETURN .F.
    endif
    /* 20081124 es kann in Sto·zeiten passieren, dass ein anderer
       Benutzer mir die Sitzungsnummer vor der Nase weggeschnappt hat.
       Nehmen wir einfach die nÑchste Nummer, damit kein Streit
       aufkommt: 
    */
    nSessId += 1 
  endif
enddo
fwrite(snLogFile,getvar("USER")+"@"+getvar("PC")+CR_LF)
if lInterrupt
  IndCreate("INDEX")
  SetKeepReport(.t.)
  OnRebuild(cMemo,"OnRebuild() failed !")
  * RETURN .f. if ! AppConvert(lCheck)
endif
RETURN .t.

FUNCTION MsgFerase(cFilename)
#ifdef LG_GERMAN
  RETURN "Datei "+cFilename+" lîschen"
#endif
#ifdef LG_FRENCH
  RETURN "Supprimer fichier "+cFilename
#endif
#ifdef LG_EN
  RETURN "Delete file "+cFilename
#endif

FUNCTION LogClear()
local aDir
local i
* local cUserId := GetAppEnv("PC")
scLogPath := DbPath()
aDir := directory(scLogPath + "\*.LOG")
for i := 1 to len(aDir)
  if scLogPath+"\"+aDir[i][F_NAME] != scLogFile
  * if aDir[i][F_NAME] != cUserId + ".LOG"
    ferase(scLogPath + "\" + aDir[i][1])
    if ferror() != 0
      Warning(scLogPath + "\" + aDir[i][1] + MsgDosError(ferror()))
    endif
  endif
next i
* slLogFile := .F.   // damit am Ende mein eigenes LOG-file gelîscht wird
RETURN .t.

FUNCTION UsrIsAlone()
local fd
local i
local aDir := directory(scLogPath + "\*.log")
* local cMyLogFile := trim(upper(GetAppEnv("PC"))) + ".LOG"
* local cMyLogFile := strtran(scLogFile,scLogPath+"\")
for i := 1 to len(aDir)
  * if aDir[i][F_NAME] != cMyLogFile
  if scLogPath+"\"+aDir[i][F_NAME] != scLogFile
    if (fd := fopen(scLogPath + "\" + aDir[i][F_NAME],FO_READWRITE+FO_EXCLUSIVE)) == -1
      RETURN .f.
    else
      fclose(fd)
    endif
  endif
next i
RETURN .t.

FUNCTION ShowLogList(cTitle)
local fd
local i
local aDir
* local cMyLogFile := trim(upper(GetAppEnv("PC"))) + ".LOG"
* local cMyLogFile := strtran(scLogFile,scLogPath+"\")
local a := {}
local cString
MsgDisplay(MsgWorking())
aDir := directory(scLogPath + "\*.log")
for i := 1 to len(aDir)
  if scLogPath+"\"+aDir[i][F_NAME] == scLogFile
    cString := utr("(myself)","(ich)","(moi-màme)")
  elseif (fd := fopen(DbPath() + "\" + aDir[i][F_NAME],FO_READWRITE+FO_EXCLUSIVE)) != -1
    cString := trimcr(alltrim(freadstr(fd,20)))
    cString += " (abgestÅrzt!)"
    fclose(fd)
  else
    * if (fd := fopen(DbPath() + "\" + aDir[i][F_NAME],FO_READ)) != -1
    if (fd := fopen(DbPath() + "\" + aDir[i][F_NAME])) != -1
      cString := trimcr(alltrim(freadstr(fd,20)))
      cString += " (aktiv)"
      fclose(fd)
    else
      cString := "?@? (aktiv)"
    endif
    * aadd( a, ;
    *   padr(strtran(aDir[i][F_NAME],".LOG"),9) ;
    *   + padr("(aktiv)",20) ;
    *   + dtoc(aDir[i][F_DATE]) + " " + aDir[i][F_TIME] ;
    * )
  endif
  aadd( a, ;
    padr(strtran(aDir[i][F_NAME],".LOG"),9) ;
    + padr(cString,32) ;
    + dtoc(aDir[i][F_DATE]) + " " + aDir[i][F_TIME] ;
  )
next i
asort(a)
browse array a using {|x|x} title (cTitle)
RETURN MnuDone()

#endif DEF_LOGFILE

FUNCTION LogClose()
* local cUserId := GetAppEnv("PC")
#ifdef DEF_LOGFILE
if snLogFile != -1
  fclose(snLogFile)
  snLogFile := -1
  if ferase(scLogFile) != 0
    Warning(MsgFerase(scLogFile)+MsgDosError(ferror()))
  endif
  * if ! slLogFile  // nur lîschen, wenn es nicht schon vorher bestand
  *   ferase(scLogPath + "\" + cUserId + ".LOG")
  * endif
endif
#endif DEF_LOGFILE
RETURN NIL



FUNCTION MsgNoAccess()
#ifdef LG_FRENCH
RETURN trim(scUserId) + ", vous n'avez pas la permission pour cette action !"
#else
RETURN trim(scUserId) + ", Sie besitzen nicht die nîtigen Benutzerrechte !"
#endif

FUNCTION UsrGroups(cIdUsr) ; RETURN UsrField(cIdUsr,"trim(USR->Groups)")
FUNCTION UsrName(cIdUsr) ; RETURN UsrField(cIdUsr,"trim(Name)")
FUNCTION Auteur(cIdUsr) ; RETURN UsrField(cIdUsr,"trim(Name)")

FUNCTION UsrField(cIdUsr,cMac)
local uReturn := NIL
default cIdUsr to scUserId
open area oUsr()
  seek padr(cIdUsr,LenIdUsr())
  uReturn := &cMac
close area
RETURN uReturn

FUNCTION Fonction(cIdUsr,cLangue)
local cFonction := ""
if empty(cIdUsr)
  cIdUsr := scUserId
endif
default cLangue to TplLang()
open area oUsr()
  seek padr(cIdUsr,LenIdUsr())
  if cLangue == MemLang3 ; cFonction := trim(USR->Fct3)
  elseif cLangue == MemLang2 ; cFonction := trim(USR->Fct2)
  else
    cFonction := trim(USR->Fct1)
  endif
close area
RETURN cFonction


FUNCTION OpenDrawer(cBefehl)
local cPassWd
local lOkay := .f.
open area oUsr()
  seek UserId()
  if ! eof()
    open window ("Kasse îffnen") size 3,50
      say MSG004
      if (cPassWd := GetPassWd( row(), col() )) != NIL
        if Encrypt( cPassWd ) == USR->PassWord
          lOkay := .t.
        endif
      endif
    close window
  endif
close area
RETURN .f. if ! lOkay
RETURN .f. if ! &cBefehl
SendConsole( ;
  trim(scUserId) + " îffnet Kasse am " + dtoc(date()) + " um " + time() ;
)
RETURN .f.

#ifdef DEF_NZS

FUNCTION UsrNzsInit()
local b := {|| USR->NZS := USR->NZS + USR->NZK, .t. }
** Kann sein, dass es gar keine ZustÑndigen gibt und das ganze System
** deaktiviert ist:
RETURN .t. if DbfSum({oUsr()},"1",1,NIL,NIL,"USR->NZK>0") == 0
do while DbfSum({oUsr()},"1",1,NIL,NIL,"USR->NZS>0.and.USR->NZK>0") <= 0
  RETURN .f. if !Confirm("NÑchste Runde NeuzugÑnge beginnen ? (J/N)")
  RETURN .f. if ! DbfScan(;
    {oUsr()},1,NIL,NIL,"USR->NZK>0",{|| TryRecLock(b)};
  )
enddo
RETURN .t.

#endif DEF_NZS


