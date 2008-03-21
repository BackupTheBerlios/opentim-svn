** Copyright (c) 2007 Luc Saffre
** Based on the ERRORSYS.PRG included with Alaska Xbase++ compiler
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

#include "XBP.CH"
#include "error.ch"
#include "TIM.CH"

#define  XPPDEBUG
// #define NEWLINE ";"
#define NEWLINE CR_LF
***********************************
* Name of error log without extension
***********************************
#define EHS_ERRORLOG "XPPERROR"

/*
 *  language specific string constant which are used in the error handler
 */
#define EHS_CANCEL            "Cancel"
#define EHS_EXIT_WITH_LOG     "Exit with LOG file"
#define EHS_RETRY             "Retry"
#define EHS_IGNORE            "Ignore"
#define EHS_OS_ERROR          NEWLINE+"Operating system error : "
#define EHS_CALLED_FROM       "Called from"
#define EHS_XPP_ERROR_MESSAGE "Xbase++ Error Message"
#define EHS_ERROR             "Error "
#define EHS_WARNING           "Warning "
#define EHS_DESCRIPTION       NEWLINE+"Description : "
#define EHS_FILE              NEWLINE+"File : "
#define EHS_OPERATION         NEWLINE+"Operation : "
#define EHS_LOG_OPEN_FAILED   "Unable to open error log file"
#define EHS_ERROR_LOG_OF      "ERROR LOG of "
#define EHS_DATE              " Date:"
#define EHS_XPP_VERSION       "Xbase++ version     :"
#define EHS_OS_VERSION        "Operating system    :"
#define EHS_LOG_WRITTEN_TO(cFile) "Error log was written to the file "+ cFile

static slBreakTrap := .f.


***********************************
* Install default error code block
***********************************
PROCEDURE ErrorSys()                             
   ErrorBlock( {|o| StandardEH(o)} )             
RETURN



*************************************
* Default error handler function
*************************************
STATIC FUNCTION StandardEH( oError )
   LOCAL i, cMessage, aOptions, nOption, nSeverity
   LOCAL row, col
   LOCAL oDacSession, oSession

   /* Check if error is handled automatically */
   DO CASE

   /* Division by zero results in 0 */
   CASE oError:genCode == XPP_ERR_ZERODIV      
      RETURN 0                            

   /* Error opening a file on a network */
   CASE oError:genCode == XPP_ERR_OPEN  .AND. ;
        oError:osCode  == 32            .AND. ;
        oError:canDefault                      
      RETURN(.F.)

   /* LS 20071113 : Error opening a file on a network */
   * CASE oError:genCode == 6624 .AND. ;
   *      oError:osCode  == 32 .AND. ;
   *      oError:canDefault
   *    RETURN(.F.)

   /* No lock is set */
   CASE oError:genCode == XPP_ERR_APPENDLOCK .AND. ;
        oError:canDefault                        
      RETURN(.F.)

   ENDCASE

   oSession := DbSession()
   IF oSession = NIL .AND. IsFunction("DacSession", FUNC_CLASS)
      oDacSession := &("DacSession()")
      oSession := oDacSession:getDefault()
   ENDIF
   IF oSession != NIL
       IF oSession:getLastError() != 0
           oError:cargo := {oError:cargo, ;
                            oSession:getLastError(),;
                            oSession:getLastMessage() }
       ENDIF              
   ENDIF

   /* No default handling defined: create error message */
   cMessage := ErrorMessage( oError )

   /* Array for selection */
#ifdef XPPDEBUG
   aOptions := { EHS_CANCEL, EHS_EXIT_WITH_LOG }
#else
   aOptions := { EHS_CANCEL }
#endif

   IF oError:canRetry
      AAdd( aOptions, EHS_RETRY )
   ENDIF

   IF oError:canDefault
      AAdd( aOptions, EHS_IGNORE )
   ENDIF

   IF ! Empty( oError:osCode )
      cMessage += EHS_OS_ERROR + LTrim(Str(oError:osCode)) +;
                  NEWLINE + DosErrorMessage(oError:osCode)
   ENDIF
   if oError:args != NIL
     cMessage += NEWLINE + "Arguments : " + utos(oError:args)
   endif

   if slBreakTrap
      // 20070511 das folgende Warning habe ich rausgeholt, weil es zu
      // einem xppfatal kommt, wenn das beim einlesen der tim.ini
      // passiert (wenn noch kein XbpCrt() da ist.
      * Warning(cMessage)
      SetMsg(cMessage)
      break(oError)
   endif

   // 20021115>>
   if ! empty(SetMsg())
     cMessage += "; (" + SetMsg() + ") "
   endif
   if ! empty(TplSource())
     cMessage += "; (" + TplSource() + ") "
   endif
   // <<20021115

   SetKeepReport(.t.)

   IF AppType() <> APPTYPE_PM

      /* Display Alert() Box possible ? */
      IF SetAppWindow() != NIL
         i   := 0
         row := Row()
         col := Col()
         DO WHILE i == 0                     
            i := Alert( cMessage, aOptions )
         ENDDO
         SetPos( row, col )

         /* Perform selected option */
         IF ! Empty( i )            
            DO CASE
            CASE aOptions[i] == EHS_IGNORE
               RETURN .F.
            CASE aOptions[i] == EHS_RETRY
               RETURN .T.
            CASE aOptions[i] == EHS_CANCEL
               Break( oError )
            CASE aOptions[i] == EHS_EXIT_WITH_LOG
               ErrorLog( oError, 2 )
            ENDCASE
         ENDIF
      ELSE
         /* There is no console window */
#ifdef XPPDEBUG
    ErrorLog( oError, 2 )
#endif
      ENDIF

      /*
       * Program can not or should not be continued
       * Set error level and terminate program !
       */

      ErrorLevel(1)
      * QUIT
      AppAbort(cMessage,oError)
   ENDIF

   IF oError:canDefault .AND. oError:canRetry
      nOption := XBPMB_ABORTRETRYIGNORE
   ELSEIF oError:canRetry
      nOption := XBPMB_RETRYCANCEL
   ELSEIF oError:canDefault
      nOption := XBPMB_OKCANCEL
   ELSE
      nOption := XBPMB_CANCEL
   ENDIF

   /*
    * Get Callstack from error object or gather it together.
    */
   IF IsMethod( oError, "getCallstack" )
     cMessage += oError:getCallstack( NEWLINE )
   ELSE
     i := 1
     DO WHILE ! Empty( ProcName(++i) )
        cMessage += NEWLINE
        cMessage += EHS_CALLED_FROM + " " 
        cMessage += Trim( ProcName(i) ) 
        cMessage += "(" + LTrim( Str( ProcLine(i) ) ) + ")"
     ENDDO
   ENDIF

   i := 0
   /* select icon for ConfirmBox() */
   DO CASE
      CASE oError:severity == XPP_ES_FATAL
           nSeverity := XBPMB_CRITICAL
      CASE oError:severity == XPP_ES_ERROR
           nSeverity := XBPMB_CRITICAL
      CASE oError:severity == XPP_ES_WARNING
           nSeverity := XBPMB_WARNING
      OTHERWISE
           nSeverity := XBPMB_INFORMATION
   ENDCASE
   /* Display ConfirmBox() */
   // i := ConfirmBox( , StrTran( cMessage, ";", Chr(13) ),
   i := ConfirmBox( , cMessage, ;
                    EHS_XPP_ERROR_MESSAGE , ;
                    nOption , ;
                    nSeverity + XBPMB_APPMODAL+XBPMB_MOVEABLE )

   DO CASE
   CASE i == XBPMB_RET_RETRY
      RETURN (.T.)
   CASE i == XBPMB_RET_IGNORE
      RETURN (.F.)
   CASE i == XBPMB_RET_CANCEL
#ifdef XPPDEBUG
         IF ConfirmBox(, EHS_EXIT_WITH_LOG, EHS_XPP_ERROR_MESSAGE, XBPMB_YESNO,;
                  XBPMB_WARNING+XBPMB_APPMODAL+XBPMB_MOVEABLE ) != XBPMB_RET_YES
              Break( oError )
         ENDIF
#else
         Break( oError )
#endif
   ENDCASE

#ifdef XPPDEBUG
   ErrorLog( oError, 2 )
#endif

   /* Set error level and terminate program ! */
   ErrorLevel(1)
   * QUIT
   AppAbort(cMessage,oError)

RETURN .F. /* The compiler expects a return value */



***************************************
FUNCTION ErrorMessage( oError )
*
*  Creates a string with the important Informations
*  from the error object
***************************************

   /* Check if this is an error or warning message */
   LOCAL cMessage := ;                           
         IIf( oError:severity > XPP_ES_WARNING, ;
                          EHS_ERROR, EHS_WARNING )

   /* Add name of subsystem or 'unkown subsytem' */
   IF Valtype( oError:subSystem ) == "C"        
      cMessage += oError:subSystem              
   ELSE
      cMessage += "????"                       
   ENDIF

   /* Add error code of subsystem */
   IF Valtype( oError:subCode ) == "N"           
      cMessage += "/"+ LTrim(Str(oError:subCode))
   ELSE
      cMessage += "/????"                        
   ENDIF

   /* Optional: Add error description */
   IF Valtype( oError:description ) == "C"
      cMessage += EHS_DESCRIPTION + ;   
                   oError:description
   ENDIF

   /* Optional: Add name of the file which were the error occured */
   IF ! Empty( oError:fileName )               
      cMessage += EHS_FILE + oError:fileName 
   ENDIF

   /* Optional: Add name of the operation which caused the error */
   IF ! Empty( oError:operation )       
      cMessage += EHS_OPERATION + oError:operation
   ENDIF

   /* Add Thread ID of the thread on which the error occured */
   cMessage += ";Thread ID : " + ;         
                LTrim(Str(oError:thread))  

   IF Valtype(oError:cargo)="A" .AND. len(oError:cargo) == 3
      IF ValType(oError:cargo[1])=="C"
         cMessage += ";" +  LineSplit(oError:cargo[1], 50)
      ENDIF
      cMessage += ";" +  LineSplit(oError:cargo[3], 50)
   ENDIF
RETURN cMessage



************************************************
STATIC PROCEDURE ErrorLog( oError, nStackStart )
*
*  Creates a string with the important Informations
*  from the error object
************************************************
   LOCAL i:=0, bError := ErrorBlock( {|e| Break(e)} )
   LOCAL cErrorLog
   LOCAL cExtension:= "LOG"
   LOCAL lPrint, lConsole, cAlternate, lAlternate, lExtra
   /* Save current printer related settings, turn printer off */
   lPrint     := Set( _SET_PRINTER )
   lConsole   := Set( _SET_CONSOLE )
   cAlternate := Set( _SET_ALTFILE )
   lAlternate := Set( _SET_ALTERNATE )
   lExtra     := Set( _SET_EXTRA, .F. )

   SET PRINTER OFF
   SET CONSOLE ON

   IF SetAppWindow() == NIL ;
     .OR. .NOT. SetAppWindow():isDerivedFrom( RootCrt() )
      SET CONSOLE OFF
   ENDIF 

   /* Trap errors that might occur while opening the ALTERNATE file */
   DO WHILE .T.                        
      cErrorLog := EHS_ERRORLOG + "." + cExtension
      BEGIN SEQUENCE                    
        SET ALTERNATE TO (cErrorLog)
        SET ALTERNATE ON
      RECOVER
        /* 
         * ALTERNATE file could not be opened:
         * try other filename
         */
        cExtension := PadL(++i,3,"0")  
        IF i > 999
           IF AppType() <> APPTYPE_PM
              TONE(660,5)
              ? EHS_LOG_OPEN_FAILED 
              IF !Set( _SET_CONSOLE )
                  OutErr( CHR(10)+CHR(13) + EHS_LOG_OPEN_FAILED )
              ENDIF
           ELSE
              MsgBox( EHS_LOG_OPEN_FAILED )
           ENDIF
           ErrorLevel(1)
           AppAbort(EHS_LOG_OPEN_FAILED,oError)
           // QUIT
        ENDIF
        LOOP
      END SEQUENCE
      EXIT
   ENDDO

   ErrorBlock( bError )

   ? Replicate( "-", 78 )
   ? EHS_ERROR_LOG_OF +'"'+ appName(.T.) +'"'+ EHS_DATE, Date(), Time()
   ?
   ? EHS_XPP_VERSION , Version()+"."+Version(3)
   ? EHS_OS_VERSION  , Os()
   ? Replicate( "-", 78 )
   ? "oError:args         :"
   IF Valtype(oError:Args)=="A"
      AEval( oError:Args, ;
             {|x,y| Qout( Space(9),"-> VALTYPE:", y:=Valtype(x) )  , ;
                     IIf( y=="O", QQout( " CLASS:", x:className() ), ;
                                  QQout( " VALUE:", Var2Char(x) ) ) } )
   ELSE
      Qout( Space(10),"-> NIL" )
   ENDIF

   ? "oError:canDefault   :" , oError:canDefault
   ? "oError:canRetry     :" , oError:canRetry
   ? "oError:canSubstitute:" , oError:canSubstitute
   ? "oError:cargo        :" , oError:cargo
   ? "oError:description  :" , oError:description
   ? "oError:filename     :" , oError:filename
   ? "oError:genCode      :" , oError:genCode
   ? "oError:operation    :" , oError:operation
   ? "oError:osCode       :" , oError:osCode
   ? "oError:severity     :" , oError:severity
   ? "oError:subCode      :" , oError:subCode
   ? "oError:subSystem    :" , oError:subSystem
   ? "oError:thread       :" , oError:thread
   ? "oError:tries        :" , oError:tries

   ? Replicate( "-", 78 )
   ? "CALLSTACK:"
   ? Replicate( "-", 78 )

   i := nStackStart

   IF IsMethod( oError, "getCallstack" )
     ? oError:getCallstack( Chr(13) + Chr(10) )
   ELSE
     DO WHILE ! Empty( ProcName(++i) )  
        ? EHS_CALLED_FROM, Trim( ProcName(i) )   + "(" + ;
                   LTrim( Str( ProcLine(i) ) ) + ")"
     ENDDO
   ENDIF
   ?

   SET ALTERNATE TO
   SET ALTERNATE OFF

   IF AppType() <> APPTYPE_PM
      TONE(660,5)
      ? EHS_LOG_WRITTEN_TO(cErrorLog)
      IF !Set( _SET_CONSOLE )
          OutErr( CHR(10)+CHR(13) + EHS_LOG_WRITTEN_TO(cErrorLog) )
      ENDIF
   ELSE
      MsgBox( EHS_LOG_WRITTEN_TO(cErrorLog)  )
   ENDIF

   /* Restore previous settings */
   Set( _SET_PRINTER,   lPrint)
   Set( _SET_CONSOLE,   lConsole)
   Set( _SET_ALTFILE,   cAlternate)
   Set( _SET_ALTERNATE, lAlternate)
   Set( _SET_EXTRA,     lExtra)

RETURN



/* Split large line for Alert()-box output */
FUNCTION LineSplit(cMessage, nMaxCol)
LOCAL i
LOCAL cLines := ""
LOCAL nLines

   nLines := MlCount(cMessage, nMaxCol,, .T.)
   FOR i:= 1 TO nLines
        cLines += Rtrim(MemoLine(cMessage, nMaxCol, i,,.T.)) +";"
   NEXT
   IF cLines[-1]==";"
      cLines := Left(cLines,len(cLines)-1)
   ENDIF
RETURN cLines

FUNCTION SetBreakTrap(l)
RETURN slBreakTrap if l == NIL
slBreakTrap := l
RETURN .t.

proc raise(msg)
local e := ErrorNew()
e:subSystem := ProgName()
e:genCode := 1
e:severity := ES_CATASTROPHIC
e:description := msg
StandardEH(e)
RETURN


