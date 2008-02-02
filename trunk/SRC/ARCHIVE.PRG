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

static snCurArchive
static saArchives
static scArcTables
static saOnSetArchive

#define ARC_NAME     1
#define ARC_PATH     2
#define ARC_DESC     3
#define ARC_READONLY 4
#define ARC_ALEN     4


FUNCTION ArcAppInit()
AddIniCmd({ "AddArchive"      , {|x| AddArchive(x)} })
AddIniCmd({ "SetArcTable"     , {|x| SetArcTable(x)} })
AddIniCmd({ "OnSetArchive"   , {|x| AddIfNotNil(saOnSetArchive,cblock(x))} })
RETURN .t.


FUNCTION ArcDbInit()
saArchives := {}
scArcTables := ""
snCurArchive := 1
saOnSetArchive := {}
RETURN .t.

FUNCTION ArcOnLogin()
if len(saArchives) == 0
  AddArchive(CfgDataBase(),DbPath(),"Aktuelle Datenbank",.f.)
endif
RETURN SetArchive(1)


FUNCTION HasArch
RETURN (len(saArchives) > 1)


FUNCTION AddArchive(cName,cPath,cDesc,lReadOnly)
default cPath to DbPath()+"\"+cName
default cDesc to cPath
default lReadOnly to .t.
aadd(saArchives,{ ;
  cName,;    // ARC_NAME
  cPath,;    // ARC_PATH
  cDesc,;    // ARC_DESC
  lReadOnly; // ARC_READONLY
})   // ARC_ALEN
RETURN .t.

FUNCTION SetArcTable(cAlias)
scArcTables += cAlias + ","
RETURN .t.


FUNCTION PickArchive(nStart)
browse array saArchives using {|x| ;
                          padr(x[ARC_NAME],8) + " " + ;
                          padr( ;
                            trim1(x[ARC_DESC]);
                              +if(x[ARC_READONLY],"(schreibgeschÅtzt)","");
                          ,50) ;
                        } ;
             start nStart ;
             delete {||.f.} ;
             title ("Auswahl Archiv")
RETURN NIL if lastchoice() == 0
RETURN lastchoice()

FUNCTION SelectArchive()
local nArchive := PickArchive(snCurArchive)
RETURN .f. if nArchive == NIL
RETURN .f. if ! SetArchive(nArchive)
ddCloseAll()
AppReset()
RETURN SetMnuDone()


FUNCTION ddPath(ad)
local cPath
if IsArchive(ad)
  RETURN saArchives[snCurArchive][ARC_PATH]+"\"
endif
cPath := GetDlmPath(ad[AD_NAME]+dbf_ext())
if cPath == NIL
  cPath := DbPath()+"\"
else
  cPath := left(cPath,rat("\",cPath))
endif
RETURN cPath

** 20020219 :
** lReadOnly NIL : egal
** lReadOnly .t. : nur die read-only Datenbanken
** lReadOnly .f. : nur die schreibbaren Datenbanken
FUNCTION ArcEval(b,lReadOnly,p1,p2)
local i
local nCurArchive := snCurArchive
for i := 1 to len(saArchives)
  if lReadOnly == NIL .or. saArchives[i][ARC_READONLY] == lReadOnly
    snCurArchive := i
    if ! eval(b,p1,p2)
      snCurArchive := nCurArchive
      RETURN .f.
    endif
  endif
next i
snCurArchive := nCurArchive
RETURN .t.

FUNCTION IsArchive(ad)
RETURN ad[AD_NAME] $ scArcTables

FUNCTION SetArchive(nArchive)
RETURN snCurArchive if nArchive == NIL
snCurarchive := nArchive
SetReadOnly(saArchives[snCurArchive][ARC_READONLY])
RETURN DoEvents(saOnSetArchive)

* FUNCTION ArcIsReadOnly()
* RETURN saArchives[snCurArchive][ARC_READONLY]

FUNCTION ArcName(n)
default n to snCurArchive
RETURN saArchives[n][ARC_NAME]

FUNCTION ArcPath(n)
RETURN DbPath() if ! HasArch()
default n to snCurArchive
RETURN DbPath()+"\"+saArchives[n][ARC_NAME]

FUNCTION ArcTitle(n)
default n to snCurArchive
RETURN saArchives[n][ARC_DESC]


