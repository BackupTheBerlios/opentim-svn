** Copyright (c) 2007 Luc Saffre
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

#ifdef DEF_TSK

#define ORD_TSK_ID   1
#define ORD_TSK_DATE 2

#define FREQ_D "D"
#define FREQ_W "W"
#define FREQ_M "M"
#define FREQ_Y "Y"

**
** TSK -
**
FUNCTION oTsk
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name TSK // create AutoIncCopy(b)
ddIndex b on TSK->IdTsk format {|x|padl(x,LenIdTsk())}
ddIndex b on dtos(TSK->Date)+TSK->Time // ORD_TSK_DATE
ddFld IdTsk    ,C,LenIdTsk(),0 postedit {|x|GetNum(x)} when .f. attrib P
ddFld IdUsr    ,C, LenIdUsr(),0 picture PIC_ID pick PickUsr(TSK->IdUsr)
ddFld Date     ,D, 8,0
ddFld Time     ,C, 5,0
ddFld Days     ,N,  3,0
ddFld Weeks    ,N,  3,0
ddFld Months   ,N,  3,0
ddFld Years    ,N,  3,0
ddFld Type     ,C,  1,0 picture PIC_ID ;
      pick {|x| PickDbcCode("TSKTYPE.DBC",x)}
ddFld IdPar    ,C,LenIdPar(),0  picture PIC_ID ;
      pick PickPar(NIL,TSK->IdPar)
ddFld IdJnl    ,C, LenIdJnl(),0 picture PIC_ID ;
      pick PickIdJnl(JNLALIAS_VEN,TSK->IdJnl)
ddFld IdDoc    ,C, LEN_IDDOC,0 pick PickDoc(TSK->IdJnl,TSK->IdDoc)
ddFld Name     ,C,200,0 picture "@k@s30"
ddFld Error    ,C,  100,0 picture "@k@s30"  // empty if ok
ddFld LastDate ,D, 8,0
ddFld LastTime ,C, 5,0
* ddFld Etat     ,C,  1,0 picture PIC_ID ;
*       pick {|x| PickDbcCode("TSKETAT.DBC",x)}
* ddFld xcText   ,C,200,0 picture "@k@s30"
action b key K_F5    prompt "~Ex‚cuter maintenant  [F5]" ;
       block TskExec()
ddEndDef()
RETURN b

FUNCTION LenIdTsk() ; RETURN 4

FUNCTION RunTasks(cIdUsr,dDate)
local lOkay := .f.
local nOkay := 0
local nFailed := 0
local nLocked := 0
local c
local cTime := time()
local nRecNo
default cIdUsr to "" // UserId()
default dDate to UserDate()
open area oTsk(), oPar()
  lOkay := .t.
  ddSetOrder(ORD_TSK_DATE)
  go top
  do while lOkay .and. !eof() ;
           .and. (empty(TSK->Date).or.TSK->Date <= dDate) ;
           .and. (empty(TSK->Time).or.TSK->Time <= cTime)
    if TaskInter() ; lOkay := .f. ; exit ; endif
    skip ; nRecNo := recno() ; skip -1
    if empty(TSK->IdUsr).or.empty(cIdUsr).or.TSK->IdUsr == cIdUsr
      if empty(TSK->Error).or.Confirm(;
        "Tƒche "+alltrim(TSK->IdTsk)+" ("+trim(TSK->Name)+") a ‚chou‚ le ";
        +dtoc(TSK->LastDate)+" … "+TSK->LastTime;
        +" avec comme message d'erreur"+CR_LF;
        +trim(TSK->Error),MsgRetry())
        seek TSK->IdPar in PAR
        if TskExec()
          nOkay += 1
        else
          nFailed += 1
          lOkay := .f.
        endif
        if ! lOkay
          lOkay := Confirm(;
            utr("Task "+alltrim(TSK->IdTsk);
              +" was scheduled for today but failed.",;
              "Aufgabe Nr. "+alltrim(TSK->IdTsk);
              +" war vorgesehen, aber schlug fehl.",;
              "Tƒche n§ "+alltrim(TSK->IdTsk);
              +" a ‚chou‚.";
            ),utr(;
              "Continue with other tasks (Y/N)?",;
              "Restliche Aufgaben trotzdem ausfhren (J/N)?",;
              "Continuer l'ex‚cution les tƒches (O/N)?";
            ))
        endif
      else
        nLocked += 1
      endif
    endif
    c := ntrim(nOkay)+" tasks executed"
    if nFailed != 0
      c += ", "+ntrim(nFailed)+" failed"
    endif
    if nLocked != 0
      c += ", "+ntrim(nLocked)+" locked"
    endif
    c += "."
    SetMsg(c)
    goto (nRecNo) // skip
  enddo
close area
RETURN lOkay

FUNCTION TskExec()
local lOkay := .f.
local x := DbcText("TSKTYPE.DBC",TSK->Type,3)
local dDate := iif(empty(TSK->Date),UserDate(),TSK->Date)
RETURN !SetMsg(TSK->Type+" : invald task type.") if x == NIL
* RETURN .f. if !confirm("execute:"+x+"?")
RETURN .f. if ! ddRecLock()
if xparse(x)
  TSK->Error := ""
  if TSK->Days > 0
    dDate += TSK->Days
  elseif TSK->Weeks > 0
    dDate += TSK->Weeks * 7
  elseif TSK->Months > 0
    dDate := SkipMonth(dDate,TSK->Months)
  elseif TSK->Years > 0
    dDate := SkipMonth(dDate,TSK->Years*12)
  endif
  TSK->Date := dDate
  lOkay := .t.
else
  TSK->Error := SetMsg()
  * if empty(TSK->Error)
  *   TSK->Error := utr("user abort","Abbruch durch Benutzer",;
  *   "Abandon par l'utilisateur")
  * endif
endif
TSK->LastDate := UserDate()
TSK->LastTime := time()
unlock record
RETURN lOkay


#else

FUNCTION oTsk() ; RETURN NIL

#endif DEF_TSK

