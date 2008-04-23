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

static fdRpt      := -1
static scFileName := NIL
static snStart    := 0
static scRptArchive := NIL
static sbLogConsole := {|cMsg| LogMsg(AppRoot()+"\CONSOLE.MSG",cMsg)}
static sbOnRTE := {|cFilename| OnRteDefault(cFilename) }



**
**
FUNCTION rpt_open
local fd
snStart := seconds()
RETURN .f. if ! ActExec("STARTUP")
scFilename := "\"+curdir()+"\SESSION.RPT"
do while file(scFilename)
  if (fd := fopen(scFilename,FO_READWRITE+FO_EXCLUSIVE)) == -1
    RETURN .f. if ! Confirm( ;
      utr(;
      "Another session is already using the directory ",;
      "Eine andere Sitzung ist bereits aktiv im Verzeichnis ",;
      "Une autre session est dÇjÖ active dans le rÇpertoire ";
      )+curdir(),MsgRetry();
    )
  else
    fclose(fd)
    if ! rpt_clean(scFilename,.t.)
      RETURN .f. if ! Confirm(SetMsg(),MsgRetry())
    endif
  endif
enddo
do while .t.
  if (fdRpt := fcreate(scFilename)) != -1
    RETURN .t.
  endif
  RETURN .f. if ! Confirm( ;
    scFilename + MsgDosError(ferror()),;
    MsgRetry();
  )
enddo
RETURN NIL // never reached

**
** rpt_write()
**
FUNCTION rpt_write(cText,nMsg)
default nMsg to RPT_SILENT
if nMsg == RPT_DISPLAY
  MsgDisplay( cText )
endif
if nMsg == RPT_WARNING
  Warning(cText) // , MSG001)
endif
if fdRpt == - 1
  * if nMsg == RPT_URGENT
  *   ? cText
  * endif
  RETURN NIL
endif
fwrite( fdRpt, time() + " " + cText + CR_LF )
RETURN NIL

FUNCTION RptWrite(c)
if SetKeepReport()
  rpt_write(c)
endif
RETURN .t.

FUNCTION rpt_warn(lConfirm,cMsg)
RETURN rpt_write(cMsg,RPT_WARNING) if lConfirm
RETURN rpt_write(cMsg)


FUNCTION SetRptArchive(x)
RETURN scRptArchive if x == NIL
scRptArchive := x
RETURN .t.

FUNCTION rpt_filename()
RETURN scFilename

STATIC FUNCTION rpt_clean(cOldFilename,lForce)
local fdBat
* local cSuffix := "A"
local cSuffix := "AA"
local cNewFileName
local cRptArchive
if empty(scRptArchive)
  cRptArchive := "\"+curdir()+"\RPT"
else
  cRptArchive := scRptArchive
endif
#ifdef __XPP__
  if !PathExist(cRptArchive)
    if ! CreateDir(cRptArchive)
      RETURN !Warning(utrp(;
        "Could not create directory for session reports!",;
        "Kann Archivordner fÅr Sitzungsberichte nicht erstellen!",;
        "CrÇation du rÇpertoire d'archivage des rapports de session!"),;
      cRptArchive+MsgDosError())
    endif
  endif
#endif
if lForce.or.SetKeepReport()
  cNewFileName := cRptArchive + "\" + right(dtos(date()),6)
  do while( file(cNewFileName+cSuffix+".RPT"))
    if cSuffix == "ZZ"
      RETURN !SetMsg("Reached ZZ suffix for "+cNewFilename)
    elseif right(cSuffix,1) == "Z"
      cSuffix := chr(asc(left(cSuffix,1))+1)+"A"
    else
      cSuffix := left(cSuffix,1)+chr(asc(right(cSuffix,1))+1)
    endif
    * cSuffix := chr(asc(cSuffix)+1)
  enddo
  cNewFileName += cSuffix + ".RPT"
  if frename(cOldFilename,cNewFilename) == -1
    /* rename may fail on DOS and windows if source and target drive are different. So we try also a copy followed by delete. */
    RETURN .f. if ! CopyFile(cOldFilename,cNewFilename)
    RETURN FileDelete(cOldFileName,.f.)
    // RETURN !SetMsg("Cannot move " + cOldFilename ;
    //  + " to " + cNewFilename+ MsgDosError(ferror()))
  endif
  SendConsole("keep report : " + cNewFileName)
  RETURN .t. if errorlevel() == 0 
  RETURN eval(sbOnRTE,cNewFileName)
endif
if ferase(cOldFilename) == -1
  RETURN !SetMsg(MsgFerase(cOldFilename) + MsgDosError(ferror()))
endif
RETURN .t.

STATIC FUNCTION OnRteDefault(cFilename)
local fdBat := fcreate( "rpt.bat" )
RETURN .f. if fdBat == -1
fwrite( fdBat, "@echo off" + CR_LF )
fwrite( fdBat, "REM ******** Generated " + dtoc(date()) + " at " + time() + CR_LF )
fwrite( fdBat, "if '%1' == '' goto usage" + CR_LF )
fwrite( fdBat, "%1 " + cFileName + CR_LF )
fwrite( fdBat, "goto end" + CR_LF )
fwrite( fdBat, ":usage" + CR_LF )
fwrite( fdBat, "echo Syntax : RPT command" + CR_LF )
fwrite( fdBat, ":end" + CR_LF )
fclose(fdBat)
RETURN .t.


**
** rpt_close()
**
FUNCTION rpt_close()
local nSeconds := seconds() - snStart
local nHours := int(nSeconds/3600)
local nMinutes := int( (nSeconds - nHours * 3600) / 60 )
rpt_write( ;
  ntrim(nHours) + ":" + ;
  strtran(str(nMinutes,2,0)," ","0") + ":" + ;
  strtran(str(nSeconds % 60,2,0)," ","0") , ;
  RPT_DISPLAY ;
)
#ifdef __XPP__
  #ifdef DEF_ADS
    AdsDisconnect()
  #endif DEF_ADS
#endif __XPP__
if fdRpt != -1
  fclose(fdRpt)
  if ! rpt_clean(scFilename,.f.)
    Warning(SetMsg())
  endif
endif
* scFileName := ""
RETURN NIL

FUNCTION MsgLookRpt
#ifdef LG_GERMAN
  RETURN "Siehe Sitzungsbericht" // + scFileName
#else
  RETURN "Voir rapport de session" // + scFileName
#endif

* #ifdef DEF_CONSOLE

FUNCTION SetConsole(b)
RETURN sbLogConsole if b == NIL
sbLogConsole := b
RETURN .t.

FUNCTION SetRteHandler(b)
RETURN sbOnRTE if b == NIL
sbOnRte := b
RETURN .t.

FUNCTION SendHotLine(cMsg)
RETURN .t. if SendConsole("call hotline ! " + cMsg)
Warning(cMsg)
RETURN .f.

FUNCTION SendConsole(cMsg) // deprecated
RETURN LogConsole(cMsg)

* FUNCTION LogMessage(cMsg)
FUNCTION LogConsole(cMsg)
RptWrite("[console] " + cMsg)
RETURN eval(sbLogConsole,cMsg)
* RETURN LogMsg(AppPath() + "\CONSOLE.MSG",cMsg)


FUNCTION LogMsg(cFilename,cMsg)
local nCount := 0
local fd := -1
local i
do while fd == -1
  if file(cFileName)
    fd := fopen(cFileName,FO_READWRITE+FO_DENYWRITE)
  else
    fd := fcreate(cFileName)
  endif
  if fd == -1
    nCount += 1
    if nCount > 10
      if ! Confirm(cFileName + MsgDosError(ferror()),MsgRetry())
        RETURN .f.
      endif
      nCount := 0
    else
      #ifdef __XPP__
        sleep(10)
      #endif
      #ifdef DEF_OSLIB
        for i := 1 to 100
          ol_yield()
        next i
      #endif
    endif
  endif
enddo
fseek(fd,0,FS_END)
fwrite(fd, ;
  left(dtoc(date()),5) + " " + time() + " " + ;
  UserId() + " " + getvar("PC",.f.,"NIL") + " " + cMsg + CR_LF ;
)
fclose(fd)
RETURN .t.

* #endif DEF_CONSOLE

FUNCTION MsgDosError(nError)
default nError to doserror()
#ifdef LG_GERMAN
  RETURN " : [32] Exklusivzugriff verweigert " if nError == 32
  RETURN " : DOS-Fehler " + ntrim(nError)
#else
  RETURN " : [32] accäs exclusif impossible" if nError == 32
  RETURN " : Erreur DOS " + ntrim(nError)
#endif

PROCEDURE RptLogDetail
if USRATTR_D $ UsrAttrib()
  rpt_write("[" + WinSetHelp() + ":" + WinTitle() + "] lastkey() = " + ntrim(lastkey()))
endif
RETURN


FUNCTION ChDir(c)
local n
local cDrive
RETURN !SetMsg("cannot chdir() after session start") if fdRpt != -1
#ifdef __XPP__
  *! ("cd "+c)
  *if curdir() != c
  *  RETURN !SetMsg('"cd '+ c +'" failed : '+curdir())
  *endif
  * ? "cd to " + c
  curdir(c)
  *if substr(c,2,1) == ":"
  *  curdrive(left(c,1))
  *  curdir(substr(c,3))
  *else
  *  curdir(c)
  *endif
#else
#ifdef __XHARBOUR__
  DirChange(c)
#else
  n := ft_chdir(c)
  RETURN !SetMsg('ChDir("'+c+'") : error '+ntrim(n)) if n != 0
  if substr(c,2,1)==":"
    cDrive := upper(left(c,1))
    if ft_default(cDrive) != cDrive
      RETURN !SetMsg("Could not set default drive to "+cDrive+":")
    endif
  endif
#endif
#endif
RETURN .t.

