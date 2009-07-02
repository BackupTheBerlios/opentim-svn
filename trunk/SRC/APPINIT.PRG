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

#include "DEFDATA.CH"
#ifdef DEF_CLIP53
  #include "LLIBG.CH"
#endif

#ifndef __XPP__
#ifdef DEF_ADS
  REQUEST AX_CacheRecords
  REQUEST AX_ExprEngine
  REQUEST AX_Loaded
  REQUEST AX_Version
  REQUEST AX_GetActivityInfo
  REQUEST AX_GetInstallInfo
  REQUEST AX_UserNames
  REQUEST AX_Error
#endif DEF_ADS
#endif __XPP__


#ifdef LG_FRENCH
  #define MSG001  "VÇrifier la structure et convertir si nÇcessaire"
  #define MSG002  "Login invalide. Abandon."
  #define MSG003  "Options d'installation"
  #define MSG006  "Choix du dossier"
  static MSG007  := "RÇorganiser la base de donnÇes"
  #define MSG008  "enlever physiquement les enregistrements supprimÇs"
  #define MSG009  "compacter la base de donnÇes"
  #define MSG010  "Ignorer les fichiers suivants :       "
  #define MSG011  "Reconstruire fichiers index (*.NTX)"
  #define MSG012  " ignorer les fichiers communs"
  #define MSG013  "Exclusivement les fichiers suivants : "
  #define MSG018  " : ce dossier n'existe pas !"
  #define MSG019  "Dossier : "
  #define MSG027  "Licence d'utilisation accordÇe Ö"
  #define MSG028  "Options : "
  #define MSG029  "Identification hardware : "
  #define MSG030  "Code d'installation "
  static MSG031 := "Code d'installation invalide."
  #define MSG032  " [F3] modifier licence ≥ [F10] Continuer"
  #define MSG035  "Date limite de fonctionnement : "
  #define MSG036  "VERSION DE DEMONSTRATION LIMITEE"
  #define MSG038   " kbytes"
  #define MSG037  "MÇmoire disponible : "
  #define MSG039  "Espace disque disponible : "
  #define MSG040  "CrÇation Dossier"
  #define MSG041  "Nom abgrÇgÇ"
  #define MSG042  " recopier le dossier "
  #define MSG043  " : existe dÇjÖ !"
  #define MSG_CONFCONV  " Confirmer chaque conversion"
  * #define MSG045  "Tapez O pour nettoyer la base de donnÇes :"
  static MSG_MAXUSERS := "Nombre d'utilisateurs "
#else
  #define MSG001  "Dateistrukturen prÅfen und evtl. konvertieren."
  #define MSG002  "Abbruch. Login ungÅltig."
  #define MSG003  "Installations-Optionen"
  #define MSG006  "Auswahl Datenbank"
  static MSG007  := "Datenbank reorganisieren"
  #define MSG008  "Gelîschte Records physikalisch entfernen"
  #define MSG009  "Datenbank kompaktieren"
  #define MSG010  "Folgende Dateien nicht reorganisieren :          "
  #define MSG011  "Indexdateien (*.NTX) neu erstellen"
  #define MSG012  " gemeinsame Dateien ignorieren"
  #define MSG013  "Ausschlie·lich folgende Dateien reorganisieren : "
  * #define MSG025  "GÅltigkeitsdatum fÅr diesen Installationscode Åberschritten."
  #define MSG018  " : Datenbank nicht gefunden !"
  #define MSG019  "Datenbank : "
  #define MSG027  "Lizenznehmer :"
  #define MSG028  "Optionen : "
  #define MSG029  "Hardware Identification : "
  #define MSG030  "Installations-Code "
  static MSG031 := "UngÅltiger Installations-Code !"
  #define MSG032  " [F3] Lizenz Ñndern ≥ [F10] Weiter"
  #define MSG035  "Zeitlich begrenzt bis zum : "
  #define MSG036  "EINGESCHRéNKTE DEMONSTRATIONSVERSION"
  #define MSG038   " kBytes"
  #define MSG037  "Arbeitsspeicher : "
  #define MSG039  "Freier Festplattenspeicher : "
  #define MSG040  "Dossier erstellen"
  #define MSG041  "Kurzname "
  #define MSG042  " kopieren aus Datenbank "
  #define MSG043  " : existiert schon !"
  #define MSG_CONFCONV  " Konvertierungen bestÑtigen"
  * #define MSG045  "J um die Datenbank zu reinigen :"
  static MSG_MAXUSERS := "Anzahl Benutzer "
#endif

static slMustLogin := .t.

static saIniCmds := {}

static snIndHandle := -1

static snAppVer   // Version
static scAppName  // Application Name        "TIM"

static scMrkOptions := ""
static scOptions := ""
static slReadOnly := .f.
static slDlmRdOnly := .f.
static scBossTables := ""

// options specified in command line:
static scExec := NIL // "/exec:"
static scIdDos := NIL // database name to be used
static slCheck // /check
static slRecover // /recover
static slQuiet // /quietlogin


#ifdef DEF_ACT
  static scCustData := ""
#endif DEF_ACT

// static snShift2000 := 1920
static snLenIdUsr
static saOnRebuild := { ;
  {|cText| Warning( ;
    cText,NIL,"REBUILD",.t.,CfgDataBase() + MsgSystem() ;
  ) } , ;
  {|cText| AppReorg( ;
    .f.,NIL,IndExist("INDEX"),IndExist("CHECK") ;
  ) } ;
}
* static saStaticMemo  := {}
static snLenIdLng  := 1
static saPreLogin
static saOnLogin   := { ;
  {|| AppOnLogin() } ;
}
static sxcHelpPath  := "AppRoot()+'\HELP'"

#ifdef DEF_VERBOSE
  static slKeepReport          := .t.
#else
  static slKeepReport          := .f.
#endif
* static slIgnore              := .f.
static scDataBase            := "."
static scExtEditor          := ""
* static scOpenMail            := "timtools openmail"
static snKeepOpenFiles       := 10
* static snTolerance           := 10
static scProgramPath
static scAppRoot
static scDataRoot
* static scDlmRoot
* static scCommonDBFs          := ""
static scSkipDBFs            := ""
* static scHelpPath            := ""
static saDbd                 := {}
* static slDemo                := .F.
* static saMustOpt             := {}
static scMrkPath             := ""

* static saOptions := NIL


**
**
FUNCTION AppInit(cAppName, nAppVer)
#ifdef DEF_OSLIB
  OL_AutoYield(.t.)
#endif
#ifndef __XPP__
altd(1)
#endif
snAppVer  := nAppVer
scAppName := cAppName
SetPublics() // weil Confirm() sonst RTE macht
*
AddIniCmd({ "SET CONFIRM"      , {|x| set(_SET_CONFIRM,ctol(x)),.t.  } } )
AddIniCmd({ "SET BELL"         , {|x| set(_SET_BELL,ctol(x) ),.t.    } } )
AddIniCmd({ "SET INSERT"       , {|x| set(_SET_INSERT,ctol(x) ) ,.t. } } )
AddIniCmd({ "SET DATE"         , {|x| set(_SET_DATEFORMAT,x) ,.t.    } } )
AddIniCmd({ "SET CANCEL"       , {|x| setcancel(ctol(x)) ,.t.        } } )
// AddIniCmd({ "ScreenBlankDelay" , {|x| SetScreenBlankDelay(x)         } } )
AddIniCmd({ "ScreenBlankDelay" , {|x| .t.  } } )
// AddIniCmd({ "ExitDelay" , {|x| SetExitDelay(x)         } } )
AddIniCmd({ "MustLoginAgain"   , {|x| SetMustLoginAgain(x)           } } )
* AddIniCmd({ "IgnoreEMM"        , {|x| slIgnore := ctol(x), .t.       } } )
AddIniCmd({ "IgnoreEMM"        , {|x| .t. } } )
AddIniCmd({ "ExternalEditor"   , {|x| scExtEditor := x, .t.         } } )
* AddIniCmd({ "OpenMail"         , {|x| (scOpenMail := xparse(x))!=NIL } } )
AddIniCmd({ "MrkPath"          , {|x| (scMrkPath := xparse(x))!=NIL, .t.    } } )
* AddIniCmd({ "MrkPath"          , {|x| scMrkPath := xparse(x),;
*                                      scMrkPath!=NIL.or.(scMrkPath:=x)!=NIL,;
*                                      .t.    } } )
AddIniCmd({ "SkipDBFs"         , {|x| scSkipDBFs         := x, .t.   } } )
AddIniCmd({ "KeepOpenFiles"    , {|x| snKeepOpenFiles := val(x),.t.  } } )
AddIniCmd({ "SetDataRoot"      , {|x| (scDataRoot:=xparse(x))!=NIL  } } )
* AddIniCmd({ "SetAppPath"       , {|x| (scProgramPath:=xparse(x))!=NIL  } } )
* AddIniCmd({ "SetDlmRoot"       , {|x| (scDlmRoot:=xparse(x))!=NIL  } } )
AddIniCmd({ "SetDlmRoot"       , {|x| SetDlmRoots(xparse(x)) } } )
AddIniCmd({ "LoadDlm"          , {|x| LoadDlm(xparse(x))  } } )
*
AddIniCmd( { "CustData" , {|x| scCustData += x + ",",.t. } } )
AddIniCmd( { "Shift2000" , {|x| set(_SET_EPOCH,xparse(x)), .t. } } )
AddIniCmd( { "set epoch" , {|x| set(_SET_EPOCH,xparse(x)), .t. } } )
AddIniCmd( { "ClearOnRebuild" , {|x| saOnRebuild := {}, .t. } } )
AddIniCmd( { "OnRebuild" , {|x| AddIfNotNil(saOnRebuild,xparse(x)) } } )
AddIniCmd( { "LenIdUsr" , {|x| (snLenIdUsr := xparse(x)) != NIL } } )
AddIniCmd( { "PreLogin" , {|x| AddIfNotNil(saPreLogin, cblock(x)) } } )
AddIniCmd( { "OnLogin" , {|x| AddIfNotNil(saOnLogin, cblock(x)) } } )
AddIniCmd( { "HelpPath" , {|x| sxcHelpPath := x, .t.  } } )
AddIniCmd( { "LenIdLng" , {|x| (snLenIdLng := xparse(x)) != NIL } } )
AddIniCmd( { "OnDecExceed" , {|x| SetOnDecExceed(xparse(x)) } } )
*
AddIniCmd( { "do"  , {|x| xparse(x) } } )
RETURN .f. if ! ArcAppInit()
TimInit()
set deleted on
set wrap on
#ifdef LG_FRENCH
  set date french
#endif
#ifdef LG_GERMAN
  set date german
#endif
#ifdef __XPP__
  ** this is probably useless and has no effect
  ** because it will be overridden by SetCollation from TIM.INI:
  set collation to system
#endif __XPP__
set scoreboard off
set century off
set bell off
set softseek off
#ifdef DEF_CLIP53
  msetcursor(.f.)
  * set videomode to LLG_VIDEO_VGA_640_480_16
  * set eventmask to INKEY_ALL
  * mshow(LLM_CURSOR_ARROW)
#endif DEF_CLIP53
#ifndef MONKEY
  #ifdef DEF_CLIP53
    set key K_F1  to GetDoPick()
  #endif
  set key K_ALT_F12 to PopAdder
#endif
#ifdef DEF_DEBUG
  set key K_ALT_F1 to DebugBreak
  set key K_ALT_F9 to ShowCallStack
#endif
#ifdef DEF_HELP
  * set key K_ALT_F1 to WinHelp(NIL)
  set key K_ALT_F1 to CallHelp
#endif
* set key K_ALT_F3 to BiosInfo()
#ifdef __XHARBOUR__
  scProgramPath := left(ExeName(),rat("\",ExeName())-1)
#else
#ifdef __XPP__
  scProgramPath := left(AppName(.t.),rat("\",AppName(.t.))-1)
  * ? scProgramPath
#else
  scProgramPath := left(ft_origin(),rat("\",ft_origin())-1)
#endif
#endif
if upper(right(scProgramPath,4)) == "\BIN"
  scAppRoot := left(scProgramPath,len(scProgramPath)-4)
else
  scAppRoot := scProgramPath
endif
* raus am 20070326 : cParams := AppGetPrgPath(cParams)
scDataRoot := scProgramPath
* scDlmRoot := scProgramPath+"\DLM"
RETURN .f. if ! AppReadIni()
RETURN .t.

FUNCTION AppMain(cParams)
local nPos, nLen
slCheck := .f.
slRecover := .f.
slQuiet := .f.
#ifndef DEF_GUI
set cursor off
#endif
default cParams to ""
if ! empty(cParams)
  cParams := upper(cParams)
  #ifdef MONKEY
    if "/MONKEY" $ cParams
      cParams := strtran( cParams, "/MONKEY" )
      StartMonkey()
    endif
    set key K_ALT_F8 to StartMonkey()
  #endif
  #ifdef DEF_VERBOSE
    if "/VERBOSE" $ cParams
      SetLogVerbose(.t.)
      cParams := strtran(cParams,"/VERBOSE")
    endif
  #endif
  if "/CHECK" $ cParams
    slCheck := .T.
    cParams := strtran(cParams,"/CHECK")
  endif
  if "/RECOVER" $ cParams
    slRecover := .T.
    cParams := strtran(cParams,"/RECOVER")
  endif
  if (nPos := at("/USER:",cParams)) != 0
    nLen := at(" ",substr(cParams,nPos+6))
    if nLen == 0
      setvar("USER",substr(cParams,nPos+6))
    else
      setvar("USER",substr(cParams,nPos+6,nLen))
      * nLen := NIL
    endif
    nLen := len(getvar("USER"))
    cParams := left(cParams,nPos-1)+substr(cParams,nPos+nLen+6)
  endif
  if (nPos := at("/PC:",cParams)) != 0
    nLen := at(" ",substr(cParams,nPos+4))
    if nLen == 0
      setvar("PC",substr(cParams,nPos+4))
    else
      setvar("PC",substr(cParams,nPos+4,nLen))
      * nLen := NIL
    endif
    nLen := len(getvar("PC"))
    cParams := left(cParams,nPos-1)+substr(cParams,nPos+nLen+4)
  endif
  #ifdef DEF_LOGIN
    * if "/USER" $ cParams
    *   lUser := .T.
    *   cParams := strtran(cParams,"/USER")
    * endif
    if "/QUIETLOGIN" $ cParams
      slQuiet := .T.
      cParams := strtran(cParams,"/QUIETLOGIN")
    endif
  #endif
endif
RETURN .f. if ! rpt_open()
rpt_write( ;
  scAppName + " " + ntrim(snAppVer) + " (" + dtos(AppDate()) ;
  + ") on " +sys_osname();
)
RETURN .f. if ! DbdLoad() // called exactly once per run
#ifndef DEF_GUI
  cParams := AppReadColor(cParams)
#endif
cParams := GetAppExec(cParams)
SplashScreen() // TimLogo()
#ifdef MONKEY
  @ 5,60 say "MONKEY"
#endif
SayLeg(" " + scAppName + " " + ntrim(snAppVer) + " - " + CopyRight())
scIdDos := alltrim(cParams)
RETURN .t.

FUNCTION dblogin()
local cIdDos
if empty(scIdDos)
  * warning("gonna PickDataPath()")
  RETURN .f. if (cIdDos := PickDataPath(scIdDos)) == NIL
  * warning("PickDataPath() returned : "+cIdDos)
else
  cIdDos := scIdDos
endif
#ifdef DEF_MOUSE
  mouse_init()
#endif
* warning("gonna OpenData()")
RETURN .f. if ! OpenData(cIdDos) // ,lCheck) // ,lRecover)
* warning("OpenData() returned .t.")
if scExec != NIL
  RETURN .f. if ! xparse(scExec)
endif
**
** LOGIN
**
#ifdef DEF_LOGIN
  if ! Login(slQuiet)
    if ! empty(SetMsg())
      Warning(SetMsg())
    endif
    close data
    rpt_write(MSG002)
    LogClose()
    #ifndef DEF_GUI
      set color to
      scroll()
    #endif DEF_GUI
    rpt_close()
    * errorlevel(APPEXIT_LOGIN)
    quit
  endif
  * set key K_ALT_F11 to UsrSetAttrib()
#endif
// 19990728 : (falls LenIdLng() geÑndert hat)
MemLang1 :=  padr(MemLang1,LenIdLng())
MemLang2 :=  padr(MemLang2,LenIdLng())
MemLang3 :=  padr(MemLang3,LenIdLng())
#ifdef DEF_4LANG
  MemLang4 :=  padr(MemLang4,LenIdLng())
#endif
AppSaveMem()
slMustLogin := .f.
RETURN .f. if ! MnuLoad(UsrIdMnu())
RETURN .t.

FUNCTION MustLogin()
RETURN slMustLogin




STATIC FUNCTION AppReadIni()
local fn := "\" + ProgName() + ".INI"
// local aIniCmds := {}    // INI_ALEN
RETURN .f. if ! DlmInit()
scCustData := ""
snLenIdUsr := 8
saPreLogin   := {}
saOnLogin   := { ;
  {|| AppOnLogin() } ;
}
snLenIdLng  := 1
set(_SET_EPOCH,1920)
RETURN .f. if ! IniLoad( saIniCmds, AppPath() + fn, .t. )
RETURN .f. if ! LoadDlm("STD")
* if ! LoadDlm("STD")
*   AddDllDir(scProgramPath)
* endif
* RETURN .t.
* 20070511 aber wenn es kein home-Verzeichnis gibt...
* RETURN .t. if ! file("."+fn)
* RETURN .f. if ! IniLoad( saIniCmds, "." + fn, .F. )
RETURN .t.

STATIC FUNCTION SetPublics()
// In Makros und sonstige Formeln kann mPublic verwendet werden.
// Wird z.B. in CPAS benutzt.
PUBLIC mPublic
PUBLIC nKey := 0
PUBLIC MrkInstall := space(12)
PUBLIC MrkMaxUsers := 1
PUBLIC MrkStr1 := space(30)
PUBLIC MrkStr2 := space(30)
PUBLIC MrkStr3 := space(30)
PUBLIC MemVersion := 0 // nAppVer
PUBLIC MemName1 := space(30)
PUBLIC MemName2 := space(30)
PUBLIC MemName3 := space(30)
#ifdef LG_FRENCH
  PUBLIC MemLang1 :=  padr("F",LenIdLng())
  PUBLIC MemLang2 :=  padr("D",LenIdLng())
  PUBLIC MemLang3 :=  padr("N",LenIdLng())
#else
  PUBLIC MemLang1 :=  padr("D",LenIdLng())
  PUBLIC MemLang2 :=  padr("F",LenIdLng())
  PUBLIC MemLang3 :=  padr("N",LenIdLng())
#endif
#ifdef DEF_4LANG
  PUBLIC MemLang4 :=  padr("E",LenIdLng())
#endif
RETURN .t.

*FUNCTION IniCmd(cKeyword,cLine)
*local i
*for i := 1 to len(saIniCmds)
*  if saIniCmds[i][INI_KEYWORD] == cKeyword
*    if ! eval(saIniCmds[i][INI_BLOCK],cLine)
*      if !Confirm(cKeyword+" "+cLine+": "+SetMsg(),MsgContinue())
*        RETURN .f.
*      endif
*    endif
*  endif
*next i
*RETURN !SetMsg(cKeyword + " : no such initialization command")










PROCEDURE PopAdder
static scLastValue := NIL
scLastValue := PickNum(scLastValue,NIL,NIL)
RETURN


**
** AppNormEnd()
**
FUNCTION AppNormEnd(cCommand,cMsg)
local fd
#ifdef DEF_PIN
PinStop()
#endif DEF_PIN
ddCloseAll()
if cCommand != NIL
  if (fd := fcreate("after.bat")) != -1
    fwrite(fd,cCommand)
    fclose(fd)
  else
    Warning("after.bat" + MsgDosError(ferror()))
  endif
endif
#ifdef MONKEY
  RETURN MnuDone() if IsMonkey()
#endif
#ifdef DEF_LOGIN
  Logout(.t.)
#endif
close data
LogClose()
#ifdef DEF_MACROREC
  if IsMacro()
    StartRecorder()
  endif
#endif
set printer to
rpt_close()
errorlevel(0)
if cMsg != NIL
  SetExitDelay(0) // WaitKey() must not call AppNormEnd() again
  Warning(cMsg,NIl,NIL,NIL,"Ein Wort zum Schluss:")
endif
#ifndef DEF_GUI
  set color to
  scroll()
#endif
quit
RETURN NIL // never reached

FUNCTION AppAbort(cMessage,oError)
local i
// local cLine
//
// display message and traceback
// 20030213 rpt_write( cMessage, RPT_URGENT )
if !empty(cMessage)
  SendConsole( cMessage )
  rpt_write(MnuJobName())
endif
#ifndef __XPP__
  i := 2
  while ( !empty(ProcName(i)) )
    rpt_write( "Called from " + trim(ProcName(i)) + "(" + ntrim(procline(i)) + ")" , RPT_URGENT)
    i++
  enddo
#endif __XPP__
ddReport()
#ifdef DEF_LOGIN
  Logout()
#endif
* RETURN AppClose()
* FUNCTION AppClose()
LogClose()
rpt_close(APPEXIT_RTE) // close & create a .ERR copy of .RPT file ... !
errorlevel(APPEXIT_RTE)
quit
RETURN FOO->Bar // never reached




**
**
**
FUNCTION AppPickOpt(aOptions,cStart)
RETURN NIL if aOptions == NIL
RETURN PickAttrib( aOptions, MSG003, cStart,"","APPATTR" )


FUNCTION AppLegend
RETURN ProgName() + " " + ntrim(AppVer()) + " - " + CopyRight()


#ifdef DEF_SHELL

FUNCTION runbg(cProgram,cParams,lAsync,lBackground,lLog)
local uRetVal
local cMsg
default lAsync to .f.
default lBackground to .t.
RETURN !SetMsg("runbg(): "+cProgram+MsgFileExist()) if ! file(cProgram)
default cParams to ""
default lLog to ! ">" $ cParams
#ifdef __XPP__
  if lLog 
    cParams += " > runbg.log 2>&1"
  endif
  uRetVal := RunShell(cParams,cProgram,lAsync,lBackground)
  RETURN .t. if uRetVal == 0
  cMsg := "runbg("+cProgram+" "+cParams+") returned "+utos(uRetVal)
  if lLog 
      LogConsole(cMsg)
      RptWrite(memoread("runbg.log"))
      SetKeepReport(.t.)
  endif
  RETURN !SetMsg(cMsg)
#endif
RETURN AppShell(cProgram+" "+cParams)

**
** AppShell()
**
FUNCTION AppShell(cCommand,cTitle,lPause,lConfirm)
local nCursor := setcursor(SC_INSERT)
default cTitle to cCommand
* default cTitle to DlgTitle()
default cTitle to "DOS Shell"
* default cCommand to "COMMAND.COM"
* default lPause to (USRATTR_E $ UsrAttrib()) // .f.
default lPause to SetPause()
* default lConfirm to .f.
default lConfirm to SetPause()
if lConfirm
  RETURN .f. if ! Confirm(cCommand)
endif
open window (cTitle) color (CfgTextColor())
ddCloseAll()
commit
#ifndef MONKEY
  #ifdef __XPP__
    RunShell("/C "+cCommand)
  #else
    cCommand := GetShellCmd(cCommand)
    ! (cCommand)
  #endif
  if lPause
    waitkey()
  endif
#endif
close window
setcursor(nCursor)
RETURN .t.

FUNCTION GetShellCmd(x)
RETURN "cmd /c " + x if getenv("OS")=="Windows_NT"
RETURN x

FUNCTION AppDlgShell(cIdDlg,xcCommand,cTitle,lPause)
SetDlgTitle(cTitle)
RETURN .f. if ! DlgExec(cIdDlg)
RETURN AppShell(xparse(xcCommand),cTitle,lPause)


#endif

FUNCTION AppMemFile()
local c := DbPath() + "\" + scAppName
#ifdef __XPP__
  c += ".xbase"
#endif __XPP__
c += ".MEM"
RETURN c

FUNCTION AppSaveMem()
save to (AppMemFile()) all like Mem*
RETURN .t.


**
** PickDataPath()
**
FUNCTION PickDataPath(cStart)
local i
local nStart := 0
* default saDbd to DbdLoad()
RETURN cStart if len(saDbd) == 0
RETURN trim(saDbd[1][DBD_IDDOS]) if len(saDbd) == 1
if cStart != NIL
  for i := 1 to len(saDbd)
    if trim(saDbd[i][DBD_IDDOS]) == cStart
      nStart := i
      exit
    endif
  next i
endif
browse array saDbd ;
       using {|p| p[DBD_IDDOS] + " " + padr(p[DBD_NAME],30) } ;
       title (MSG006) ;
       start nStart ;
       help "PICKDBD" ;
       delete {||.f.}
RETURN NIL if lastchoice() == 0
RETURN trim(saDbd[lastchoice()][DBD_IDDOS])

FUNCTION OpenData(cIdDos) // ,lCheck,lRecover) // ,aDbd)
* local cMemFile
local nPos
local cLockFile
* static slCheck   := NIL
* static slRecover := NIL
* default slCheck to lCheck
* default slRecover to lRecover
* default lCheck to slCheck
* default lRecover to slRecover
scDataBase := cIdDos
* 20020906
if ! PathExist(DbPath())
  RETURN ! SetMsg(DbPath()+" : no such directory")
endif
cLockFile := DbPath() + "\dblock.ind"
do while file(cLockFile)
  RETURN .f. if ! Confirm( ;
    scDataBase + ;
    MsgDbLock(), ;
    MsgRetry(),NIL,"DBLOCK", ;
    { ;
      { K_F12, ;
        {|| FileEdit(cLockFile) } ;
      } ;
    } ;
  )
enddo
RETURN .f. if ! MrkRead(.t.)
// RETURN .f. if ! AppReadIni()
* cMemFile := DbPath() + "\" + scAppName
* #ifdef __XPP__
*   cMemFile += ".xbase"
* #endif
* cMemFile += ".MEM"
* if file(cMemFile)
if file(AppMemFile())
  * restore from (cMemFile) additive
  restore from (AppMemFile()) additive
endif
SetTplLang(MemLang1)
RETURN .f. if ! p_dbi()
RETURN .f. if ! ArcDbInit()
RETURN .f. if ! AppReadDbi()
RETURN .f. if ! LoadDbVars()
RETURN .f. if ! ArcOnLogin()
#ifdef __XPP__
SetAppWindow():setTitle(scAppName+" "+trim1(scDatabase);
                        +trims(MemName1," (",")"))
#endif __XPP__
#ifdef DEF_RFX
RETURN .f. if ! RfxInit()
#endif DEF_RFX
RETURN .f. if ! LogOpen()
if slRecover .or. slCheck
  AppReorg(slCheck,NIL,slRecover,slCheck) // Reorganisieren ohne Dialog
endif
RETURN AppConvert(slCheck)




**
** ReLogin()
**
FUNCTION ReLogin
local cIdDos := PickDataPath(CfgDataBase())
RETURN .f. if cIdDos == NIL
RETURN .f. if ! ddCloseAll() // 20030902
Logout(.f.)
LogClose()
// RETURN .f. if ! SetDataBase(cIdDos)
SetPublics()
RETURN .f. if ! AppReadIni()
RETURN .f. if ! OpenData(cIdDos)
RETURN .f. if ! Login()
RETURN .f. if ! AppRefresh()
RETURN MnuDone()




* FUNCTION ddIsCommon(ad) ; RETURN (ad[AD_NAME] $ scCommonDBFs)

FUNCTION MsgDbLock()
#ifdef LG_GERMAN
RETURN " : Datenbank momentan gesperrt."
#endif
#ifdef LG_FRENCH
RETURN " : dossier momentanÇment verrouillÇ."
#endif
#ifdef LG_EN
RETURN " : database has been locked for maintenance."
#endif

#ifdef DEF_BRAND

FUNCTION AppMrkFile
local cPath
if empty(scMrkPath)
  cPath := DbPath() + "\"
else
  cPath := scMrkPath + "\"
endif
cPath += scAppName
#ifdef __XPP__
  cPath += ".xbase"
#endif
cPath += ".MRK"
RETURN cPath

**
** MrkRead()
**
STATIC FUNCTION MrkRead(lDlg)
local cPath := AppMrkFile()
* LogConsole(cPath)
if file(cPath)
  restore from (cPath) addi
else
  SendConsole(cPath+MsgFileExist())
endif
RETURN .T. if AppIsInstalled()
if lDlg
  WarnDemo()
  RETURN GetMark()
endif
RETURN .f.

#else

STATIC FUNCTION MrkRead ; RETURN .t.

#endif DEF_BRAND


**
** AppAbout
**
FUNCTION AppAbout()
open window size 19,62 help ABOUT
* say padc( ProgName() + " Version " + ntrim(AppVer()) + " " + DATE_TODAY,58) ; WinCr()
say padc( ProgName() + " Version " + ntrim(AppVer()) ;
    + " [" + dtoc(AppDate())+"] on "+sys_osname(),58)
WinCr()
say padc( CopyRight() ,58) ; WinCr()
WinCr()
say padc(MSG027,58) ; WinCr()
WinCr()
say padc(trim(MrkStr1),58) ; WinCr()
say padc(trim(MrkStr2),58) ; WinCr()
say padc(trim(MrkStr3),58) ; WinCr()
WinCr()
if ! empty(scMrkOptions)
  say padc(MSG028 + " " + scMrkOptions,58) ; WinCr()
endif
#ifdef DEF_BRAND
  if ! empty(ptod(MrkInstall))
     say padc( MSG035 + dtoc(ptod(MrkInstall)), 58 ) ; WinCr()
  endif
  if AppIsDemo()
    say padc( MSG036 ,58) ; WinCr()
  endif
  * say padc( MSG029 + HWID(), 58 )  ; WinCr()
  say padc( ntrim(MrkMaxUsers) + " user(s)", 58 )  ; WinCr()
#else
  say padc("SHAREWARE",58) ; WinCr()
#endif
WinCr()
WinCr()
say padc( ;
  MSG037 + ntrim(memory(0)) + "/" + ;
           ntrim(memory(1)) + "/" + ;
           ntrim(memory(2)) + MSG038, 58 ;
) ; WinCr()
say padc( MSG039 + ntrim(diskspace()) + " bytes", 58)
#ifdef DEF_BRAND
  SayLeg(MSG032) // "[F3] pour modifier le nom de licence")
  if WaitKeySet() == K_F3 // KEY_MODIFY
    GetMark()
  endif
#else
  WaitKeySet()
#endif DEF_BRAND
close window
RETURN .f.

#ifdef DEF_BRAND

**
** GetMark()
**
STATIC FUNCTION GetMark()
* local cName
do while .t.
  RETURN .F. if AppTerminate()
  if MrkStr1 == NIL
    raise("MrkStr1 is NIL!?")
  endif
  open window "Installation" size 15,46 help ABOUT
  say padc(scAppName + " Version " + ltrim(str(snAppVer,5,2)),40)
  WinCR()
  WinCr()
  say MSG027 ; WinCR()
  say "   " ; @ row(), col() get MrkStr1 ; WinCR()
  say "   " ; @ row(), col() get MrkStr2 ; WinCR()
  say "   " ; @ row(), col() get MrkStr3 ; WinCR()
  WinCr()
  if ! empty(scMrkOptions)
    say padc(MSG028 + " " + scMrkOptions,42) ; WinCr()
  endif
  WinCr()
  WinCr()
  say MSG_MAXUSERS
  get MrkMaxUsers picture "###"
  WinCr()
  say MSG030
  @ row(), col() get MrkInstall picture "@R@K !!!-###.###.###"
  nKey := ReadScr()
  close window
  RETURN .F. if nKey == K_ESC
  if AppIsInstalled()
    * save to (cName) all like Mrk*
    save to (AppMrkFile()) all like Mrk*
    RETURN .T.
  endif
  Warning(MSG031,NIL,"WRN041")
enddo
RETURN NIL // never reached

#endif DEF_BRAND

**
**
FUNCTION AppIsInstalled()
#ifdef DEF_BRAND
  local cInstall := stok( { MrkStr1, MrkStr2, MrkStr3 }, ;
                      trim(scAppName) + scMrkOptions , ;
                      snAppVer, ;
                      ptod(left(MrkInstall,3)), ;
                      padr(ntrim(MrkMaxUsers) + "U",8) ;
                    )
  RETURN .F. if right(MrkInstall,9) != cInstall
#endif
#ifndef DEF_NETWORK
  if MrkMaxUsers > 1
    RETURN .f. if ! Confirm( ;
      "Ihre Version ist nicht fÅr Netzwerkbetrieb vorgesehen !", ;
      MsgSure() ;
    )
  endif
#endif DEF_NETWORK
RETURN .t.

*FUNCTION AppGetPrgPath(cParams)
*local nPos
*local cName
*if ( nPos := at("/P:",cParams) ) != 0
*  cName := substr(cParams,nPos+3)
*  if (nPos := at("/",cName)) != 0
*    cName := left(cName,nPos-1)
*  endif
*  cParams := trim(strtran(cParams,"/P:" + cName))
*  scProgramPath := cName
*endif
*RETURN cParams

#ifdef DEF_MACROREC

*FUNCTION AppStartMacro(cParams)
*local nPos
*local cName
*if ( nPos := at("/RECORD",cParams) ) != 0
*  StartRecorder()
*  cParams := trim(strtran(cParams,"/RECORD"))
*  RETURN cParams
*endif
*if ( nPos := at("/PLAY:",cParams) ) != 0
*  cName := substr(cParams,nPos+6)
*  if (nPos := at("/",cName)) != 0
*    cName := left(cName,nPos-1)
*  endif
*  LoadMacro(cName)
*  ExecMacro()
*  cParams := trim(strtran(cParams,"/PLAY:" + cName))
*endif
*if ( nPos := at("/DELAY:",cParams) ) != 0
*  cName := substr(cParams,nPos+7)
*  if (nPos := at("/",cName)) != 0
*    cName := left(cName,nPos-1)
*  endif
*  SetPlayDelay(val(cName))
*  cParams := trim(strtran(cParams,"/DELAY:" + cName))
*endif
*RETURN cParams

#endif DEF_MACROREC

#ifdef DEF_ACT

STATIC FUNCTION GetAppExec(cParams)
local nPos
* local cName
if ( nPos := at("/EXEC:",cParams) ) != 0
  scExec := substr(cParams,nPos+6)
  if (nPos := at("/",scExec)) != 0
    scExec := left(scExec,nPos-1)
  endif
  * ActExec(cName)
  cParams := trim(strtran(cParams,"/EXEC:" + scExec))
endif
RETURN cParams

#endif DEF_ACT

FUNCTION CfgProgramPath      ; RETURN scProgramPath
FUNCTION AppPath             ; RETURN scProgramPath
FUNCTION AppRoot             ; RETURN scAppRoot
*FUNCTION DlmRoot             ; RETURN scDlmRoot
FUNCTION DataRoot            ; RETURN scDataRoot

FUNCTION CfgDataBase         ; RETURN scDataBase
FUNCTION CfgKeepOpenFiles    ; RETURN snKeepOpenFiles
FUNCTION AppVer              ; RETURN snAppVer
FUNCTION ProgName             ; RETURN scAppName
FUNCTION AppIsDemo           ; RETURN ! AppIsInstalled() // slDemo

FUNCTION SetKeepReport(lNew)
#ifdef DEF_DEBUG
  RETURN .t. if lNew == NIL
#endif DEF_DEBUG
RETURN slKeepReport if lNew == NIL
slKeepReport := lNew
RETURN .t.

FUNCTION DbPath ; RETURN scDataRoot + "\" + scDataBase
* FUNCTION DbOptions ; RETURN trim(MrkOptions)

FUNCTION PathExist(cPath)
local aDir
RETURN .T. if cPath == "."
aDir := directory(cPath,"D")
RETURN .F. if len(aDir) == 0
RETURN .T.


**
** AppReorg() - called without lDlg when /recover or interrupted session
**
FUNCTION AppReorg(lDlg,cOnly,lIndex,lCheck,lRebuild)
local aData
local i
local lOkay := .t.
local lOkayOkay := .t.
local cIndex
local cCheck
local cCommon   := BUTTON_ON
local cRebuild
local cSkipDBFs := padr(scSkipDBFs,20)
* local cNoCommon := BUTTON_OFF
local cConfirm  := BUTTON_ON
* local cMsg := ""
default lDlg   to .t.
default lRebuild to .f.
default lCheck to .f.
default lIndex to .t.
default cOnly to ""
cCheck := if(lCheck,BUTTON_ON,BUTTON_OFF)
cIndex := if(lIndex,BUTTON_ON,BUTTON_OFF)
cRebuild := if(lRebuild,BUTTON_ON,BUTTON_OFF)
cOnly := padr(cOnly,20)
#ifdef DEF_NETWORK
  if lIndex
    RETURN .f. if ! LockData(MSG007)
  endif
#endif DEF_NETWORK
if lDlg
  open window (MSG007) size 9,74 help REORGA
  @ row(), col() get cIndex checkbox // when .f., aber dann héngt [Ctrl-Home] sich auf...
  say " INDEX   : " + MSG011
  WinCr()
  @ row(), col() get cRebuild checkbox
  say " REBUILD : " + MSG009
  WinCr()
  @ row(), col() get cCheck checkbox
  say " CHECK   : " + MSG001
  WinCr()
  say "           "
  @ row(), col() get cConfirm checkbox
  say MSG_CONFCONV
  WinCr()
  WinCr()
  say MSG010
  @ row(), col() get cSkipDBFs picture PIC_ID
  WinCr()
  say MSG013
  @ row(), col() get cOnly picture PIC_ID
  * WinCr()
  * @ row(), col() get cNoCommon checkbox
  * say MSG012 // " gemeinsame Dateien ignorieren"
  nKey := ReadScr()
  close window
  if nKey == K_ESC
    #ifdef DEF_NETWORK
      if lIndex
        UnlockData()
      endif
    #endif DEF_NETWORK
    RETURN .f.
  endif
endif
SetKeepReport(.t.)
aData := AppDataList()
ddCloseAll()
for i := 1 to len(aData)
  if TaskInter() ; lOkayOkay := .f. ; exit ; endif
  if aData[i] != NIL
    if ! aData[i][AD_NAME] $ cSkipDBFs
      if empty(cOnly) .or. aData[i][AD_NAME] $ cOnly
        if cCheck == BUTTON_ON
          if IsArchive(aData[i])
            lOkay := ArcEval({||ddCheck(aData[i],cConfirm == BUTTON_ON)},.f.)
          else
            lOkay := ddCheck(aData[i],cConfirm == BUTTON_ON)
          endif
        endif
        if lOkay .and. cRebuild == BUTTON_ON
          if IsArchive(aData[i])
            lOkay := ArcEval({||ddConvertDbf( aData[i] )},.f.)
          else
            lOkay := ddConvertDbf( aData[i] )
          endif
        endif
        if lOkay .and. (cIndex == BUTTON_ON .or.cRebuild == BUTTON_ON)
          if IsArchive(aData[i])
            lOkay := ArcEval({||ddIndex( aData[i] )},.f.)
          else
            lOkay := ddIndex( aData[i] )
          endif
        endif
      endif
    endif
  endif
  if ! lOkay
    lOkayOkay := .f.
    if Confirm(MsgContinue())
      lOkay := .t.
    else
      exit
    endif
  endif
next i
ddCloseAll()
#ifdef DEF_LOGFILE
  if lOkayOkay
    if cIndex == BUTTON_ON .or. cRebuild == BUTTON_ON
      LogClear()
    elseif cCheck == BUTTON_ON
      if file(DbPath() + "\CHECK.LOG")
        ferase(DbPath() + "\CHECK.LOG")
      endif
    endif
  endif
#endif
#ifdef DEF_NETWORK
  if lIndex
    UnlockData()
  endif
#endif DEF_NETWORK
RETURN .f. if ! lOkayOkay
if cIndex == BUTTON_ON .or. cRebuild == BUTTON_ON
  IndDelete("INDEX")
endif
if cCheck == BUTTON_ON
  IndDelete("CHECK")
endif
RETURN .t.


* #ifdef DEF_ROLLBACK

**
** RlbStart()
**
*FUNCTION RlbStart(cTitle)
*local i
*local cPath
*if file(DbPath()+"\rollback.ind")
*  Warning( ;
*    "Es existiert bereits eine Datei rollback.ind !", ;
*    "Wenden Sie sich an den Datenbankverwalter.", ;
*    "ROLLBACK", NIL, cTitle;
*  )
*  RETURN .f.
*endif
*RETURN .f. if ! LockData(cTitle)
*ddCloseAll()
*AppShell(DbPath()+"\rollback.bat " + DbPath(),cTitle)
*RETURN .f. if ! file(DbPath()+"\rollback.ind")
*RETURN .t.

* FUNCTION RlbStop()
* delete file (DbPath()+"\rollback.ind")
* RETURN UnlockData()

* #endif DEF_ROLLBACK

#ifdef DEF_NETWORK

FUNCTION LockData(cMsg)
local fd
local cRlbFile := DbPath() + "\dblock.ind"
MsgDisplay("Datenbank sperren...")
if ! UsrIsAlone()
  #ifdef LG_GERMAN
    Warning( ;
      "Die Datenbank kann momentan nicht gesperrt werden", ;
      "weil andere Benutzer darin arbeiten." ;
    )
  #else
    Warning( ;
      "Il n'est pas possible de verrouiller la base de donnÇes", ;
      "tant que d'autres utilisateurs travaillent." ;
    )
  #endif
  RETURN .f.
endif
if file(cRlbFile)
  Warning(cMsg,cRlbFile + " existiert bereits !")
  RETURN .f.
endif
if (fd := fcreate(cRlbFile)) == -1
  Warning(cMsg,cRlbFile + MsgDosError(ferror()))
  RETURN .f.
endif
fwrite(fd,cMsg)
fclose(fd)
MsgDisplay("")
RETURN .t.

FUNCTION UnlockData
local cRlbFile := DbPath() + "\dblock.ind"
RETURN .f. if ! file(cRlbFile)
ferase(cRlbFile)
RETURN .t.

#endif DEF_NETWORK

FUNCTION AppHelpPath
* default scHelpPath to (scProgramPath + "\HELP")
RETURN xparse(sxcHelpPath)

FUNCTION IndConfirm(cIdInd,cMsg1,cMsg2)
#ifdef LG_GERMAN
  default cMsg2 to "Konvertierung starten (J/N) ?"
#else
  default cMsg2 to "DÇmarrer la conversion (O/N) ?"
#endif
RETURN IndCheck(cIdInd,cMsg1,cMsg2,MSG_YES)

FUNCTION IndWarn(cIdInd,cMsg1)
RETURN IndCheck(cIdInd,cMsg1,"Rufen Sie bitte bei PAC an : 087/55.62.31",MSG_NO)

STATIC FUNCTION IndCheck(cIdInd,cMsg1,cMsg2,cAnswer)
* local cFileName := GetDlmPath(cIdInd + ".IND")
local cFileName := DbPath() + "\" + cIdInd + ".IND"
local fd
RETURN .f. if file(cFileName)
RETURN .f. if ! Confirm(cMsg1,cMsg2,cAnswer,cIdInd)
RETURN .f. if ( fd := fcreate(cFileName)) == -1
fwrite(fd,dtoc(UserDate()) + " " + time() + " : " + cMsg1)
fclose(fd)
RETURN .t.

FUNCTION IndOpen(cIdInd,cMsg)
local cFileName := DbPath() + "\" + cIdInd + ".IND"
if snIndHandle != -1
  SetMsg("IndOpen() : IndHandle already in use")
  RETURN .f.
endif
RETURN .f. if ( snIndHandle := fcreate(cFileName)) == -1
fwrite(snIndHandle,dtoc(UserDate()) + " " + time() + " " + UserId() + cMsg)
RETURN .t.

FUNCTION IndClose()
RETURN .t. if snIndHandle == -1
fclose(snIndHandle)
snIndHandle := -1
RETURN .t.

FUNCTION IndExist(cIdInd)
* local cFileName := GetDlmPath(cIdInd + ".IND")
local cFileName := DbPath() + "\" + cIdInd + ".IND"
RETURN file(cFileName)

FUNCTION IndDate(cIdInd)
local aDir := directory(DbPath() + "\" + cIdInd + ".IND")
* local aDir := directory(DbPath() + "\" + cIdInd + ".IND")
RETURN ctod("") if len(aDir) == 0
RETURN aDir[1][F_DATE]

FUNCTION IndDelete(cIdInd,lWarn)
local cFileName := DbPath() + "\" + cIdInd + ".IND"
default lWarn to .f.
if snIndHandle != -1
  fclose(snIndHandle)
  snIndHandle := -1
endif
RETURN .t. if ferase(cFileName) == 0
RETURN .t. if !lWarn
SetMsg(cFileName + MsgDosError(ferror()))
RETURN .f.

FUNCTION IndCreate(cIdInd,cMsg)
local cFileName := DbPath() + "\" + cIdInd + ".IND"
local fd := fcreate(cFileName)
RETURN .f. if fd == -1
if cMsg == NIL
  fwrite(fd,trim(ProcName(2)) + "(" + ntrim(procline(2)) + ")")
else
  fwrite(fd,cMsg)
endif
fclose(fd)
RETURN .t.

FUNCTION WarnDemo
#ifdef LG_FRENCH
  RETURN Warning( ;
    MSG031, "Contactez votre revendeur.", "WRN042" ;
  )
#else
  RETURN Warning( ;
    MSG031, "Wenden Sie sich an Ihren VerkÑufer.", "WRN042" ;
  )
#endif

FUNCTION AddMrkOption(c)
scMrkOptions += c
RETURN NIL

FUNCTION AddOption(c)
if !empty(scOptions)
  scOptions += ","
endif
scOptions += c
RETURN .t.

FUNCTION HasOption(c)
RETURN (c $ scOptions)
* RETURN (c $ scMrkOptions)

#ifdef DEF_DBDEDIT

FUNCTION DbdEdit(cTitle)
local aKeys := {}
saDbd := ReadArray( ;
  scProgramPath + "\DBD.DBC",DBD_ALEN, ;
  NIL, ;
  NIL ;
)
ddCloseAll()
browse array saDbd ;
             using {|p|DbdLine(p)} ;
             title (cTitle) ;
             delete {|p| DbdDelete(p) } ;
             create {|p| DbdCreate(p) } ;
             enter  {|p| DbdEnter(p) } ;
             actions aKeys
WriteArray(saDbd,scProgramPath+"\DBD.DBC",DBD_ALEN)
RETURN NIL

FUNCTION DbdEnter(dbd)
dbd[DBD_ATTRIB] := padr(dbd[DBD_ATTRIB],8)
open window ("Datenbank-Deskriptor") size 5,50
say "Name        " + dbd[DBD_IDDOS]
WinCr()
say "Bezeichnung "
get dbd[DBD_NAME]
WinCr()
say "Attribute   "
get dbd[DBD_ATTRIB] picture PIC_ID
nKey := ReadScr()
close window
dbd[DBD_ATTRIB] := trim(dbd[DBD_ATTRIB])
RETURN NIL


FUNCTION DbdLine(dbd)
local cLine := dbd[DBD_IDDOS]
cLine += dbd[DBD_NAME]
cLine += str( ;
  WildSize(scDataRoot+"\"+dbd[DBD_IDDOS]+"\*.db*") / 1000, ;
  10,1 ;
) + "KB "
cLine += dtoc( ;
  WildDate(scDataRoot+"\"+dbd[DBD_IDDOS]+"\*.db*");
)
RETURN cLine

FUNCTION DbdDelete(dbd)
local cIdDos := trim(dbd[DBD_IDDOS])
RETURN .f. if ! Confirm( ;
  cIdDos + " : Datenbank wird gelîscht.", MsgSure() ;
)
RETURN .f. if ! Confirm( ;
  cIdDos + " : alle Daten sind anschlie·end weg !", MsgSure() ;
)
RETURN .f. if ! WildDelete(scDataRoot + "\" + cIdDos,"*.*")
ft_rmdir(scDataRoot + "\" + cIdDos)
RETURN .t.

FUNCTION DbdCreate(dbd)
local aNew   := array(DBD_ALEN)
local cIdDbd
local cName1
local cIdDbdFrom
RETURN NIL if dbd == NIL
cName1 := padr(dbd[DBD_NAME],30)
cIdDbdFrom := dbd[DBD_IDDOS]
cIdDbd     := dbd[DBD_IDDOS]
open window ("Datenbank erstellen") size 5,50 help DBDCREA
do while ! AppTerminate()
  WinHome()
  say "als Kopie von " + cIdDbdFrom
  WinCr()
  say "ID : "
  get cIdDbd picture PIC_ID valid !empty(cIdDbd) .and. cIdDbd != cIdDbdFrom
  WinCr()
  say "Beschreibung "
  get cName1
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN NIL
  endif
  if ValNewDbd(trim(cIdDbd))
    exit
  endif
enddo
close window
RETURN NIL if ! DbdCopy(trim(cIdDbdFrom),trim(cIdDbd),cName1)
aNew[DBD_IDDOS]  := cIdDbd
aNew[DBD_NAME ]  := cName1
aNew[DBD_ATTRIB] := ""
* DbdSaveMem(aNew)
DbdSetMsg(cIdDbd,"Datenbank wird erstmals aktiviert")
RETURN aNew


FUNCTION DbdCopy(cIdTpl,cIdDbd,cName1)
MsgDisplay("Verzeichnis anlegen : " + scDataRoot + "\" + cIdDbd)
ft_mkdir(scDataRoot + "\" + cIdDbd)
if ! PathExist(scDataRoot + "\" + cIdDbd)
  Warning(cIdDbd + " : Verzeichnis konnte nicht erstellt werden.")
  RETURN .f.
endif
if ! WildCopy( scDataRoot + "\" + cIdTpl, ;
               "*.DB*", ;
               scDataRoot + "\" + cIdDbd )
  DbdSetMsg(cIdDbd, MSG044())
  Warning(cIdDbd + " : " + MSG044())
  RETURN .f.
endif
if ! WildCopy( scDataRoot + "\" + cIdTpl, ;
               "*.qry", ;
               scDataRoot + "\" + cIdDbd )
  DbdSetMsg(cIdDbd, MSG044())
  Warning(cIdDbd + " : " + MSG044())
  RETURN .f.
endif
if ! WildCopy( scDataRoot + "\" + cIdTpl, ;
               "*.msk", ;
               scDataRoot + "\" + cIdDbd )
  DbdSetMsg(cIdDbd, MSG044())
  Warning(cIdDbd + " : " + MSG044())
  RETURN .f.
endif
if ! WildCopy( scDataRoot + "\" + cIdTpl, ;
               "*.MEM", ;
               scDataRoot + "\" + cIdDbd )
  DbdSetMsg(cIdDbd, MSG044())
  Warning(cIdDbd + " : " + MSG044())
  RETURN .f.
endif
if ! WildCopy( scDataRoot + "\" + cIdTpl, ;
               "*.act", ;
               scDataRoot + "\" + cIdDbd )
  DbdSetMsg(cIdDbd, MSG044())
  Warning(cIdDbd + " : " + MSG044())
  RETURN .f.
endif
if ! WildCopy( scDataRoot + "\" + cIdTpl, ;
               "*.ind", ;
               scDataRoot + "\" + cIdDbd )
  DbdSetMsg(cIdDbd, MSG044())
  Warning(cIdDbd + " : " + MSG044())
  RETURN .f.
endif
if ! WildCopy( scDataRoot + "\" + cIdTpl, ;
               "*.MRK", ;
               scDataRoot + "\" + cIdDbd )
  DbdSetMsg(cIdDbd, MSG044())
  Warning(cIdDbd + " : " + MSG044())
  RETURN .f.
endif
RETURN .t.

FUNCTION MSG044
RETURN "Datenbank wurde nicht korrekt erstellt !"

FUNCTION DbdSetMsg(cIdDbd,cMsg)
local fd
fd := fcreate(scDataRoot + "\" + cIdDbd + "\CHECK.LOG")
if fd != -1
  fwrite(fd,cMsg)
  fclose(fd)
endif
RETURN NIL


FUNCTION WildSize(cWild)
local aDir := directory(cWild)
local i
local nSize := 0
for i := 1 to len(aDir)
  nSize += aDir[i][F_SIZE]
next i
RETURN nSize

FUNCTION WildDate(cWild)
local aDir := directory(cWild)
local i
local dDate := ctod("")
for i := 1 to len(aDir)
  if aDir[i][F_DATE] > dDate
    dDate := aDir[i][F_DATE]
  endif
next i
RETURN dDate

FUNCTION ValNewDbd(cIdDbd)
RETURN .f. if ! ValFileName(cIdDbd)
if file(scDataRoot + "\" + cIdDbd + "\*.*")
  RETURN Confirm( ;
    cIdDbd + " : diese Datenbank existiert bereits !", ;
    "Bestehende Daten Åberschreiben (J/N) ?" ;
  )
endif
RETURN .t.

**
** WriteArray()
**
static FUNCTION WriteArray(a,cFilename,nLen,cDelim) // ,cPath)
local fd
local cLine
local c
local i
local j
local nCut
local aItem
local nLine := 0
default cDelim to "|"
if (fd := fcreate(cFileName)) == -1
  Warning(cFileName + MsgDosError(ferror()))
  RETURN .f.
endif
MsgDisplay("Writing " + cFileName + "...")
for i := 1 to len(a)
  for j := 1 to nLen
    fwrite(fd,a[i][j])
    if j == nLen
      fwrite(fd,CR_LF)
    else
      fwrite(fd,cDelim)
    endif
  next j
next i
fclose(fd)
MsgDisplay("")
RETURN .t.

#endif DEF_DBDEDIT

FUNCTION WildCopy(cFromPath,cWild,cToPath)
local aDir := directory(cFromPath + "\" + cWild)
local i
for i := 1 to len(aDir)
  MsgDisplay("Kopieren " + aDir[i][F_NAME] + " -> " + cToPath)
  copy file (cFromPath + "\" + aDir[i][F_NAME]) ;
         to (cToPath + "\" + aDir[i][F_NAME])
  if doserror() != 0
    RETURN ! SetMsg(cToPath + aDir[i][F_NAME] + MsgDosError())
    * RETURN .F.
  endif
next i
RETURN .T.

FUNCTION CopyFile(cFrom,cTo)
#ifdef DEF_LFN
  RETURN ! SetMsg(cFrom+": lf_fcopy("+cFrom+","+cTo+") failed") if lf_fcopy(cFrom,cTo) == -1
  RETURN .t.
#else
  copy file (cFrom) to (cTo)
  RETURN .t. if doserror() == 0
  RETURN !SetMsg(cTo + MsgDosError())
#endif



FUNCTION DbdLoad()
if ! file(scDataRoot+"\DBD.DBC")
  RETURN .f. if ! DbdGenerate()
endif
saDbd := ReadArray( ;
  scDataRoot + "\DBD.DBC", DBD_ALEN, ;
  NIL, ;
  NIL, ;
  {|p|!DBDATTR_H $ p[DBD_ATTRIB]} ;
)
RETURN .t.

FUNCTION DbdGenerate
local i
local a := directory(scDataRoot+"\*.*","D")
local fd
local nCount := 0
* RETURN NIL if ! Confirm("generate dbd.dbc (y/n) ?")
if (fd := fcreate(scDataRoot + "\DBD.DBC")) == -1
  SetMsg(scDataRoot + "\DBD.DBC" + MsgDosError(ferror()))
  RETURN .f.
endif
for i := 1 to len(a)
  if file(DataRoot()+"\"+a[i][F_NAME]+"\" + scAppName + ".dbi")
    fwrite(fd,padr(a[i][F_NAME],8)+"|")
    fwrite(fd,padr(a[i][F_NAME],30)+"|")
    fwrite(fd,CR_LF)
    nCount++
  endif
next i
fclose(fd)
if nCount == 0
  SetMsg(scDataRoot + " : no databases found")
  RETURN .f.
endif
RETURN .t.



#ifdef DEF_ACT

FUNCTION IsCustData(cAlias) ; RETURN (cAlias $ scCustData)

#endif DEF_ACT

FUNCTION LenIdUsr  ; RETURN snLenIdUsr
* FUNCTION Shift2000 ; RETURN set(_SET_EPOCH) // snShift2000

FUNCTION OnRebuild(cText)
local i
for i := 1 to len(saOnRebuild)
  if ! eval(saOnRebuild[i],cText)
    Warning("OnRebuild["+ntrim(i)+"] failed !",NIL,NIL,.t.)
    RETURN .f.
  endif
next i
RETURN .t.

FUNCTION OnLogin
RETURN DoEvents(saOnLogin)
* local i
* for i := 1 to len(saOnLogin)
*   RETURN .f. if ! eval(saOnLogin[i])
* next i
* RETURN .t.

FUNCTION AppPreLogin
RETURN DoEvents(saPreLogin)


*FUNCTION StaticMemo(cFilename)
*local i
*for i := 1 to len(saStaticMemo)
*  RETURN .t. if eval(saStaticMemo[i],cFilename)
*next i
*RETURN .f.

FUNCTION AddIniCmd(a)
local i
for i := 1 to len(saIniCmds)
  if saIniCmds[i][1] == a[1]
    * raise("Duplicate AddIniCmd('"+a[1]+"')")
    saIniCmds[i][2] := a[2]
    RETURN .t.
  endif
next i
aadd(saIniCmds,a)
RETURN .t.


FUNCTION AppIniCmds() // AppDbiItems()
* local aDbi := {}
RETURN saIniCmds

* FUNCTION AddIfNotNil(a,uItem)
* RETURN .f. if uItem == NIL
* aadd(a,uItem)
* RETURN .t.

FUNCTION cblock(x) ; RETURN xparse( "{||" + x + "}" )
FUNCTION cblock1(x) ; RETURN xparse( "{|x|" + x + "}" )

FUNCTION LenIdLng ; RETURN snLenIdLng

*FUNCTION AddPublic(x)
*local nPos := at("=",x)
*local cName
*RETURN .f. if nPos == 0
*cName := left(x,nPos-1)
*public &cName
*&cName := xparse(substr(x,nPos+1))
*RETURN .t.

FUNCTION WildDelete(cPath,cWild)
local aDir := directory(cPath + "\" + cWild)
local i
for i := 1 to len(aDir)
  MsgDisplay("Deleting file " + cPath + aDir[i][F_NAME] )
  RETURN .f. if ! FileDelete(cPath + "\" + aDir[i][F_NAME],.f.)
next i
RETURN .T.

FUNCTION LimitDate() ; RETURN ptod(MrkInstall)

FUNCTION MsgSystem
#ifdef LG_GERMAN
  RETURN " : Systemmeldungen"
#else
  RETURN " : messages systäme"
#endif

#ifndef DEF_GUI

**
** Determine ColorSet name & read COL file
**
FUNCTION AppReadColor(cParams)
local cColorSet
local n := at("/COL:",cParams)
if n != 0
  cColorSet := substr(cParams,n+5)
  if (n := at("/",cColorSet)) != 0
    cColorSet := trim(left(cColorSet,n-1))
  endif
  cParams := trim(strtran(cParams,"/COL:" + cColorSet))
else
  cColorSet := "COLOR"
endif
LoadColor(cColorSet)
RETURN cParams

#endif DEF_GUI


FUNCTION ext_edit(s)
local cFilename := "~MEMOTXT.TXT"
local stamp
if empty(scExtEditor)
  SetMsg("No ExternalEditor defined in TIM.INI!")
  RETURN NIL
endif
if ! memowrit(cFilename,hardcr(s))
  SetMsg("Could not write temporary file "+cFilename)
  RETURN NIL
endif
if (stamp := timestamp(cFilename)) == NIL
  SetMsg("Could not get timestamp for file "+cFilename)
  RETURN NIL
endif
#ifdef __XPP__
  * if RunShell(cFilename,scExtEditor) == -1
  if RunShell("/C "+scExtEditor+" "+cFilename) == -1
  * if RunShell("/C START "+scExtEditor+" "+cFilename) == -1
    SetMsg("RunShell('"+cFilename+"','"+scExtEditor+"') returned -1")
    RETURN NIL
  endif
#else
  open window ("External Editor") color (CfgTextColor())
  setcursor(SC_NORMAL)
  ! (scExtEditor + " " + cFileName)
  setcursor( if(readinsert(), SC_INSERT, SC_NORMAL) )
  close window
#endif
if stamp == timestamp(cFilename)
  SetMsg("No changes detected")
  RETURN NIL
endif
s := memoread(cFileName)
if len(s) == 0 .and. fsize(cFilename) != 0
  SetMsg(cFileName + " : read error "+ltrim(str(ferror())))
  RETURN NIL
endif
RETURN s

FUNCTION timestamp(cFilename)
local aDir
aDir := Directory(cFilename)
if len(aDir) != 1
  RETURN NIL
endif
* RETURN dtos(aDir[1][F_WRITE_DATE])+aDir[1][F_WRITE_TIME]
RETURN dtos(aDir[1][F_DATE])+aDir[1][F_TIME]+ntrim(aDir[1][F_SIZE])

*FUNCTION ext_edit(cFilename)
*#ifdef __XPP__
*  *if ! file(scExtEditor)
*  *  SetMsg("ExternalEditor in TIM.INI : "+scExtEditor+" : no such file")
*  *  RETURN NIL
*  *else
*  if RunShell(cFilename,scExtEditor) == -1
*  * if RunShell("/C START "+scExtEditor+" "+cFilename) == -1
*    SetMsg("RunShell('"+cFilename+"','"+scExtEditor+"') returned -1")
*    RETURN NIL
*  endif
*#else
*  open window ("External Editor") color (CfgTextColor())
*  setcursor(SC_NORMAL)
*  ! (scExtEditor + " " + cFileName)
*  setcursor( if(readinsert(), SC_INSERT, SC_NORMAL) )
*  close window
*#endif
*cMemo := memoread(cFileName)
*if empty(cMemo)
*  SetMsg(cFileName + " is empty. read error.")
*  RETURN NIL
*endif
*RETURN cMemo


*FUNCTION OpenMail(cToAddr,cToName,cSubject,cBody)
*local fd
*local cFrom := "<me@example.com>"
*local cTmpFile := strtran(time(),":")+".eml"
*// local cDate := dtocf(date(),"ddd, dd mmm yyyy ")+time()+" +0200"
*if empty(cToAddr)
*  RETURN !SetMsg("E-Mail-Adresse darf nicht leer sein!")
*endif
*#ifdef DEF_LFN
*  fd := lf_fcreate(cTmpFile)
*#else
*  fd := fcreate(cTmpFile)
*#endif DEF_LFN
*if fd == -1
*  SetMsg(MsgDosError())
*  RETURN .f.
*endif
*fwrite(fd,"Message-Id: <"+dtos(date())+strtran(time(),":");
*  +"@example.com>"+CR_LF)
*fwrite(fd,"Date: " + dtocf(date(),"dddd, dd mmmm yyyy ")+time()+" +0200" + CR_LF)
*fwrite(fd,"From: " + trim(cFrom) + CR_LF)
*if empty(cToName)
*  fwrite(fd,"To: " + trim(cToAddr) + CR_LF)
*else
*  fwrite(fd,'To: "' + trim(dos2latin1(cToName)) + '" <'+trim(cToAddr)+">" + CR_LF)
*endif
*if cSubject != NIL
*  fwrite(fd,"Subject: " + trim(dos2latin1(cSubject))+CR_LF)
*endif
*fwrite(fd,"Mime-Version: 1.0"+CR_LF)
*fwrite(fd,"Content-Type: text/plain; charset=ISO-8859-1"+CR_LF)
*fwrite(fd,"Content-Transfer-Encoding: binary"+CR_LF)
*fwrite(fd,"Content-Disposition: inline"+CR_LF)
*fwrite(fd,CR_LF)
*if cBody != NIL
*  fwrite(fd,dos2latin1(cBody) + CR_LF)
*endif
*fclose(fd)
*RETURN AppShell(scOpenMail + " " + cTmpFile)
*// RETURN AppShell(AppPath()+"\timtools openmail tmp.eml")


* FUNCTION beep
* IF ( SET( _SET_BELL ) )
*   tone(150,1)
*   * ?? CHR(7)
* ENDIF
* RETURN .t.




FUNCTION SetReadOnly(x)
RETURN slReadOnly if x == NIL
slReadOnly := x
RETURN .t.

FUNCTION SetDlmRdOnly(x)
RETURN slDlmRdOnly if x == NIL
slDlmRdOnly := x
RETURN .t.

FUNCTION SetBossTables(x)
RETURN scBossTables if x == NIL
scBossTables := x
RETURN .t.

FUNCTION IsReadOnly(ad)
RETURN .t. if slReadOnly
RETURN .t. if slDlmRdOnly .and. left(ddPath(ad),len(DbPath()))!=DbPath()
RETURN .f. if empty(UserId())  // before login, e.g. during tim /check
RETURN .f. if USRATTR_B $ UsrAttrib()
RETURN (ad[AD_NAME] $ scBossTables)

* RETURN .t. if USRATTR_R $ UsrAttrib()
*   SetMsg(MsgReadOnly())
*   RETURN .F.
* endif

** returns a list of databases who are children of the directory
** containing this table
** wenn ad[AD_PATH] == "...CPAS\" ist, dann mÅssen
** ...CPAS\ARCHIV
** ...CPAS\DATA
** genommen werden
*FUNCTION DbdList(ad)
*local i
*local a := {}
*local cPath
*for i := 1 to len(saDbd)
*  cPath := scDataRoot + "\" + trim(saDbd[i][DBD_IDDOS]) + "\"
*  if left(cPath,len(ad[AD_PATH])) == ad[AD_PATH]
*    aadd(a,saDbd[i])
*  endif
*next i
*RETURN a


#ifdef DEF_4LANG
FUNCTION Has4Lang ; RETURN .t.
#else
FUNCTION Has4Lang ; RETURN .f.
#endif


FUNCTION MemDefine(cName)
xparse("public " + cName)
RETURN .t.

proc DebugBreak
raise("You pressed Alt-F1")
return

FUNCTION AppDate
#ifdef __XHARBOUR__
  RETURN FileDate(ExeName())
#else
#ifdef __XPP__
  RETURN FileDate(AppName(.t.)) // scProgramPath+"\tim4.exe")
#else
  RETURN FileDate(ft_origin())
#endif
#endif

FUNCTION AppCompiler
#ifdef __XHARBOUR__
  RETURN "xharbour"
#else
#ifdef __XPP__
  RETURN "xbase"
#else
  RETURN "clipper"
#endif
#endif


#ifdef __XHARBOUR__

FUNCTION ft_default()
RETURN CurDrive()

#endif

#ifdef __XPP__

FUNCTION ft_default()
RETURN CurDrive()

* FUNCTION SetCollation(n)
* #include "set.ch"
* // #include "COLLAT.CH"
* set(_SET_COLLATION,n)
* // SET COLLATION to &cCollation
* RETURN .t.

#else

FUNCTION SetFontSize()
RETURN .t.
FUNCTION SetWindowSize()
RETURN .t.

FUNCTION SetCollation(nCollation)
RETURN .t.

#endif __XPP__


