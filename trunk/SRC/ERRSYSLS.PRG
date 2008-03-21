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

/***
*	Errorsys.prg
*       Standard Clipper 5.0 error handler.  (Modified by Luc)
*	Copyright (c) 1990 Nantucket Corp.  All rights reserved.
*
*	Compile:  /m/n/w
*/

#include "error.ch"
#include "LIB.CH"
// put messages to STDERR
#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)

#ifdef LG_FRENCH
  #define MSG_QUIT    "Quitter"
  #define MSG_RETRY   "R‚essayer"
  #define MSG_DEFAULT "Ignorer"
  #define MSG001      "L'imprimante n'est pas prˆte."
  #define MSG002      "Tapez O pour r‚essayer :"
#else
  #define MSG_QUIT    "Abbrechen"
  #define MSG_RETRY   "Wiederholen"
  #define MSG_DEFAULT "Ignorieren"
  #define MSG001 "Der Drucker ist nicht betriebsbereit."
  #define MSG002 "J um neu zu versuchen : "
#endif

static slBreakTrap := .f.
* static sbStdError

* #ifdef DEF_DEBUG
* static saSeqStack := {}
* #endif DEF_DEBUG

* #ifndef __XPP__

/***
*	ErrorSys()
*
*       Note:  automatically executes at startup
*/
proc ErrorSys()
  ErrorBlock( {|e| MyErrorHandler(e)} )
  * sbStdError := ErrorBlock( {|e| MyErrorHandler(e)} )
  * if sbStdError == NIL
  *   ? "NIL"
  *   quit
  * endif
return

* #endif __XPP__

proc raise(msg)
local e := ErrorNew()
e:subSystem := ProgName()
e:genCode := 1
e:severity := ES_CATASTROPHIC
e:description := msg
MyErrorHandler(e)
RETURN


/***
*       DefError()
*/
STATIC FUNCTION MyErrorHandler(e)
local cMemo
local i, cMessage, aOptions, nChoice, cRep := "O"
* avoid Processor stack fault in case of a RTE during MyErrorHandler:
* ErrorBlock(sbStdError)
if ( e:genCode == EG_ZERODIV ) // by default, division by zero yields zero
  return (0)
endif
//
// for "too many files open" error, set NETERR() and subsystem default
if ( e:genCode == EG_OPEN .and. e:osCode == 4 .and. e:canDefault )
  SetMsg("Too many files open.")
  NetErr(.t.)
  RETURN (.f.)                                           // NOTE
endif
//
// for network open error, set NETERR() and subsystem default
if ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )
  NetErr(.t.)
  RETURN (.f.)                                            // NOTE
endif
//
// for lock error during APPEND BLANK, set NETERR() and subsystem default
if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )
  NetErr(.t.)
  RETURN (.f.)                                           // NOTE
endif
* #ifdef DEF _AXS
* Returning true (.T.) from the
* error handling block retries the failed operation and false (.F.)
* resumes processing.
  if e:subSystem == "DBFNTXAX"
    if e:osCode == 7033
      SetMsg("Advantage Database Server connection limit")
      SendConsole("Advantage Database Server connection limit")
      NetErr(.t.)
      RETURN (.f.)
    endif
    if e:osCode == 6611
      SetMsg("ADS 6611 : send timeout")
      SendConsole("ADS 6611 : send timeout")
      NetErr(.t.)
      RETURN (.f.)
    endif
    if e:osCode == 6610
      SetMsg("ADS 6610 : reply timeout")
      SendConsole("ADS 6610 : reply timeout")
      NetErr(.t.)
      RETURN (.f.)
    endif
  endif
* #endif
//
// build error message
cMessage := ErrorMessage(e)
if ! empty(e:osCode)
  cMessage += "; (DOS Error " + ntrim(e:osCode) + ") "
endif
// 20021115>>
if ! empty(SetMsg())
  cMessage += "; (" + SetMsg() + ") "
endif
if ! empty(TplSource())
  cMessage += "; (" + TplSource() + ") "
endif
// <<20021115
// build options array
if ( .f. .and. e:genCode == EG_PRINT )       // Luc 91 11 30
  if ! Confirm( MSG001, MSG002 )
    SetMsg(MSG001)
    break( e )
  endif
  RETURN .T.
elseif slBreakTrap
  Warning(cMessage) // 20030321
  * // 19991217 begin
  * ddReport()
  * rpt_write( cMessage, RPT_URGENT )
  * i := 2
  * while ( !empty(ProcName(i)) )
  *   rpt_write( "Called from " + trim(ProcName(i)) + "(" + ntrim(procline(i)) + ")" , RPT_URGENT)
  *   i++
  * enddo
  * // 19991217 end
  SetMsg(cMessage)
  break(e)
else
  aOptions := { MSG_QUIT }
endif
if (e:canRetry)
  AAdd(aOptions, MSG_RETRY)
endif
if (e:canDefault)
  AAdd(aOptions, MSG_DEFAULT)
endif
//
// put up alert box
//
if ! AppIsDemo()     // def DEF_DEMO            // if SET(_SET_BELL)
  *if set(_SET_BELL)
  *  tune_morts()
  *endif
  * tone(262,1)
  * tone(330,1)
  * tone(392,1)
  * tone(523,3)
endif
nChoice := 0
SetKeepReport(.t.)
#ifndef MONKEY
  if !AppIsDemo()
    while ( nChoice == 0 )
      * if ( empty(e:osCode) )
        nChoice := Alert( cMessage, aOptions )
      * else
      *   nChoice := Alert( cMessage + "; (DOS Error " ;
      *              + ntrim(e:osCode) + ")", aOptions )
      * endif
      if ( nChoice == NIL )
        exit
      endif
    enddo
  endif
#endif // MONKEY
//
if ( !Empty(nChoice) )          // do as instructed
  *if ( aOptions[nChoice] == "Break" )
  *  Break(e)
  if ( aOptions[nChoice] == MSG_RETRY )
    return (.t.)
  elseif ( aOptions[nChoice] == MSG_DEFAULT )
    * SetKeepReport(.T.)
    return (.f.)
  endif
endif
AppAbort(cMessage,e)
RETURN NIL // never reached



#ifdef DEF_DEBUG

*FUNCTION PushSequence()
*local i
*aadd(saSeqStack,;
*    trim(ProcName(2)) + "(" ;
*    + ntrim(procline(2)) + ")" )
*for i := 1 to len(saSeqStack)
*  rpt_write(saSeqStack[i])
*next i
*RETURN .t.
*
*FUNCTION PopSequence()
*asize(saSeqStack,len(saSeqStack)-1)
*RETURN .t.

#endif DEF_DEBUG

/***
*       ErrorMessage()
*/
FUNCTION ErrorMessage(e)
local cMessage
// start error message
cMessage := if( e:severity > ES_WARNING, "Error ", "Warning " )
// add subsystem name if available
if ( ValType(e:subSystem) == "C" )
  cMessage += e:subSystem //
  // 20070307 cMessage += e:subSystem()
else
  cMessage += "???"
endif
// add subsystem's error code if available
if ( ValType(e:subCode) == "N" )
  cMessage += ("/" + ntrim(e:subCode))
else
  cMessage += "/???"
endif
// add error description if available
if ( ValType(e:description) == "C" )
  cMessage += ("  " + e:description)
endif
// add either filename or operation
if ( !Empty(e:filename) )
  cMessage += (": " + e:filename)
elseif ( !Empty(e:operation) )
  cMessage += (": " + e:operation)
endif
RETURN (cMessage)

FUNCTION SetBreakTrap(l)
RETURN slBreakTrap if l == NIL
* if l
*   confirm("yes")
* else
*   confirm("yes")
* endif
slBreakTrap := l
RETURN .t.

