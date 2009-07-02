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


** Based on DBESYS.PRG ditributed with Alaska Xbase++ compiler

#ifdef __XPP__

#define MSG_DBE_NOT_LOADED   " database engine not loaded"
#define MSG_DBE_NOT_CREATED  " database engine could not be created"

#include "TIM.CH"
#include "DMLB.CH"
#include "DBFDBE.CH"
#include "FOXDBE.CH"

#ifdef DEF_ADS

// Alaska Data Access Chain library is required.
#pragma library("ADAC20B.LIB")

STATIC soSession := NIL

#endif DEF_ADS


*******************************************************************************
* DbeSys() is always executed at program startup
*******************************************************************************
PROCEDURE dbeSys()
/* 
 *   The lHidden parameter is set to .T. for all database engines 
 *   which will be combined to a new abstract database engine.
 */
#ifdef DEF_ADS
LOCAL cServerDrive := left(AppName(.t.),2)
#endif DEF_ADS
* LOCAL aDbes := { { "DBFDBE", .T.},;
*                  { "NTXDBE", .T.},;
*                  { "FOXDBE", .T.},;
*                  { "CDXDBE", .T.},;
*                  { "DELDBE", .F.},;
*                  { "SDFDBE", .F.} }
* LOCAL aBuild :={ ;
*   { "DBFNTX", 1, 2 },;
*   { "FOXCDX", 3, 4 };
* }
* LOCAL i

  /*
   *   Set the sorting order and the date format
   */
  SetCollation(DbeCollation())
  * SET COLLATION TO GERMAN
  * SET COLLATION TO AMERICAN
  * SET DATE TO AMERICAN

  #ifdef DEF_ADS
    if UseAdsDbe()
      IF ! DbeLoad( "ADSDBE", .f.)
        raise( "Database Engine ADSDBE not loaded")
      ENDIF
*      aDbes := {{ "ADSDBE", .F.}}
*      aBuild := {}
    endif
  #endif DEF_ADS

  #ifdef DEF_FOX

    IF ! DbeLoad( "FOXDBE", .T.)
      raise( "Database Engine FOXDBE not loaded")
    ENDIF

    IF ! DbeLoad( "CDXDBE" , .T.)
      raise( "Database Engine CDXDBE not loaded" )
    ENDIF

    IF ! DbeBuild( "FOXCDX", "FOXDBE", "CDXDBE" )
      raise( "Database Engine DBFCDX not created" )
    ENDIF

    * DbeSetDefault("FOXDBE")
    DbeInfo( COMPONENT_DATA, DBE_EXTENSION, "FOX" )
                 
  #endif

  #ifdef DEF_DBF

    IF ! DbeLoad( "DBFDBE", .T.)
      raise( "Database Engine NTXDBE not loaded")
    ENDIF

    IF ! DbeLoad( "NTXDBE" , .T.)
      raise( "Database Engine NTXDBE not loaded")
    ENDIF

    IF ! DbeBuild( "DBFNTX", "DBFDBE", "NTXDBE" )
      raise( "Database Engine DBFNTX not created")
    ENDIF

  #endif DEF_DBF

  /* 
   *   load all database engines 
   */
*  FOR i:= 1 TO len(aDbes)
*      IF ! DbeLoad( aDbes[i][1], aDbes[i][2])
*         Alert( aDbes[i][1] + MSG_DBE_NOT_LOADED , {"OK"} )
*      ENDIF
*  NEXT i

  DbeSetDefault(UseDbe()) // "DBFNTX")

  #ifdef DEF_ADS
    if UseAdsDbe()
      DbeSetDefault("ADSDBE")

      // connect to the ADS server
      soSession := dacSession():New( "DBE=ADSDBE;SERVER="+cServerDrive )

      // check if we are connected to the ADS server
      IF ( !soSession:isConnected( ) )
        raise("Error connecting to ADS on "+cServerDrive+" : "+utos(soSession:getLastError()))
      ENDIF
      // SetCollation(DbeCollation())
      // Warning(ntrim(DbeCollation()))
    endif
  #endif DEF_ADS


  /* 
   *   create database engines 
   */
*  FOR i:= 1 TO len(aBuild)
*      IF ! DbeBuild( aBuild[i][1], aDbes[aBuild[i][2]][1], aDbes[aBuild[i][3]][1])
*         Alert( aBuild[i][1] + MSG_DBE_NOT_CREATED , {"OK"} )
*      ENDIF
*  NEXT i

RETURN

FUNCTION dbf_ext()
RETURN "."+DbeInfo( COMPONENT_DATA, DBE_EXTENSION )

FUNCTION dbt_ext()
RETURN "."+DbeInfo( COMPONENT_DATA, DBE_USER+1)

/*** hier ist es egal, welche DBE benutzt wird: alle drei unterstÅtzten
DBEs haben ihre XXX_MEMOFILE_EXT definiert als (DBE_USER+1)

DBFDBE_MEMOFILE_EXT
FOXDBE_MEMOFILE_EXT
ADSDBE_MEMOFILE_EXT
***/

FUNCTION ntx_ext()
RETURN "."+DbeInfo( COMPONENT_ORDER, DBE_EXTENSION )


#ifdef DEF_ADS

FUNCTION AdsDiag()
if soSession == NIL
  writeln("soSession is NIL")
elseif ! soSession:isConnected()
  writeln("Connection to server failed!")
  writeln("Error code :" + utos(soSession:getLastError()))
  writeln("Description:" + utos(soSession:getLastMessage()))
else
  writeln("Active DacSession: "+soSession:getConnectionString())
  writeln("isUsed() : " + utos(soSession:isUsed()))
  writeln("isCompound() : " + utos(soSession:isCompound()))
  writeln("isDefault() : " + utos(soSession:isDefault()))
endif
RETURN .t.

FUNCTION AdsDisconnect
if soSession != NIL
  soSession:disconnect()
  soSession := NIL
endif
RETURN .t.


* dummy functions for backward compatibility

* AX_CacheRecords(n)
* Get/Set the number of records to read-ahead and cached on the client
* AX_CacheRecords( [<nNumRecords>] ) -> numeric
* <nNumRecords>  The number of records to be read-ahead and cached on
* the client after a skip operation
FUNCTION AX_CacheRecords(n)
RETURN -1 // return the previous setting

FUNCTION ax_error
RETURN 0 if soSession == NIL
RETURN soSession:getLastError()

#endif DEF_ADS

#else

FUNCTION ntx_ext() ; RETURN ".NTX"
FUNCTION dbf_ext() ; RETURN ".DBF"
FUNCTION dbt_ext() ; RETURN ".DBT"

#endif __XPP__


//
// EOF
