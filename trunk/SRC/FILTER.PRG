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

#ifdef DEF_FILTER

#ifdef LG_FRENCH
  #define MSG001 " : ajouter vue"
  #define MSG002 "DÇsignation "
  #define MSG003 "Expression "
  * #define MSG004 "DÇsignation: obligatoire."
  #define MSG005 "SÇlection Filtre"
  #define MSG006 "Liste des filtres"
  #define MSG007 "(pas de filtre)"
  #define MSG008 "Condition de filtrage invalide : "
#else
  #define MSG001 " : Ansicht einfÅgen"
  #define MSG002 "Bezeichnung "
  #define MSG003 "Ausdruck "
  * #define MSG004 "Bezeichnung darf nicht leer sein!"
  #define MSG005 "Auswahl Filter"
  #define MSG006 "Liste der Filter"
  #define MSG007 "(Kein Filter)"
  #define MSG008 "UngÅltige Filterbedingung : "
#endif

*static saFltText := NIL


**
** ddSetFilter()
**
** SET FILTER TO <cExpr> TEXT <cText>
**
** Returns .T. if the new filter makes the current record disappear
** (In this case, the calling function should do a GO TOP or a SKIP)
**
*FUNCTION ddSetFilter(ad, cExpr, cText)
*local lGoTop
*if empty(cExpr)
*  lGoTop := (recno() == lastrec() + 1)
*  set filter to
*  ad[AD_FILTER] := NIL
*elseif type(cExpr) == "L"
*  lGoTop := ! (&cExpr)
*  #ifdef DEF_PURZEL
*    set filter to &("("+cExpr+").or.Purzel()")
*  #else
*    set filter to &cExpr
*  #endif
*  ad[AD_FILTER] := cText
*else
*  SetMsg( MSG008 + cExpr )
*  RETURN .f.
*endif
** if cIdQry != NIL
**   ddQryLoad(ad[AD_NAME] + cIdQry)
** endif
*RETURN lGoTop


**
** FltText()
** Return filter text of current alias
**
*FUNCTION FltText(ad)
*RETURN ad[AD_FILTER] if !empty(ad[AD_FILTER])
*RETURN MSG007 // "(pas de filtre)"

**
** oFlt()
**
FUNCTION oFlt()
static b := NIL
if  b != NIL ; RETURN b ; endif
define data b name FLT          ;
              attrib P ;
              create FltCreate()
ddindex b on FLT->Alias+FLT->IdFlt
ddFld Alias  ,C,  8,0 picture PIC_ID
ddFld Desig  ,C, 40,0 picture "@K@S30" // width 30
ddFld Expr   ,C,254,0 picture "@K@S30" pick FltPickExpr()
ddFld IdFlt  ,C,  3,0 picture PIC_ID
ddFld IdQry  ,C,  5,0 picture PIC_ID ;
                      pick PickQry(FltCargo(AD_NAME),".QRY",FLT->IdQry)
ddFld IdDlg  ,C,  8,0 picture PIC_ID ;
                      pick PickQry("",".DLG",FLT->IdDlg)
ddEndDef()
RETURN b

**
** FltCreate()
**
FUNCTION FltCreate(cAlias)
* local ad := FltCargo()
local cDesig := FLT->Desig
local cExpr  := FLT->Expr
local lOK := .F.
local cIdFlt := FLT->IdFlt
default cAlias to FLT->Alias
open window (trim(cAlias) + MSG001) size 4,70 help FLTCREA
do while .t.
  WinHome()
  say MSG002
  @ row(), col() get cDesig
  WinCR()
  say MSG003
  @ row(), col() get cExpr picture "@K@S40" pick FltPickExpr()
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN DDCREATE_FAIL
  endif
  * if empty(cDesig)
  *   SetMsg(MSG004) // "DÇsignation: obligatoire."
  *   loop
  * endif
  exit
enddo
close window
* softseek cAlias + "A"
* do while val(FLT->IdFlt) == 0
*   skip -1
*   if bof() .or. FLT->Alias != cAlias
*     goto lastrec() + 1
*     exit
*   endif
* enddo
* cIdFlt := NextNum(FLT->IdFlt)
RETURN DDCREATE_FAIL if ! dbAddRec()
FLT->Alias := cAlias
FLT->Desig := cDesig
FLT->Expr  := cExpr
FLT->IdFlt := cIdFlt
FLT->IdQry := "NIL"
RETURN DDCREATE_DONE


FUNCTION FltPickExpr()
local ad := FltCargo()
local n := PickField(ad)
if n != NIL
  keyboard (ad[AD_FIELDS][n][AG_NAME])
endif
RETURN NIL

**
** FltActivate()
**
** Set filter to Standard filter
** If no filter text starting with "#" exists, set filter off
**
*FUNCTION FltActivate(ad,cIdFlt)
*local i
*local lFound := .F.
*local cAlias := padr(alias(),10)
*local cExpr := NIL
*local cText := NIL
** local cIdQry := NIL
*RETURN .f. if empty(cIdFlt)
*open area oFlt()
*  seek cAlias + cIdFlt
*  if ! eof()
*    cExpr := trim(FLT->Expr)
*    cText := trim(FLT->Desig)
*    * if (cIdQry := trim(FLT->IdQry)) == "NIL"
*    *   cIdQry := NIL
*    * endif
*  endif
*close area
*RETURN .f. if cExpr == NIL
*RETURN ddSetFilter( ad, cExpr, cText )


**
** PickFlt()
**
* FUNCTION PickFlt(ad,cStart)
* local b := oFlt()
* local cIdFlt := NIL
* local cAlias := padr(ad[AD_NAME],8)
* RETURN NIL if ad[AD_NAME] == "FLT"
* open area b
*   if empty(cStart)
*     softseek cAlias
*   else
*     softseek cAlias + trim(cStart)
*   endif
*   edit data b create   FltCreate(ad)       ;
*               mode     pick                       ;
*               key      FLT->Alias value cAlias    ;
*               query    "FLTPICK" ;
*               append ;
*               title (MSG005)
*   if ddLastReq() == DDEDIT_SELECT
*     cIdFlt := FLT->IdFlt
*   endif
* close area
* RETURN cIdFlt

#else

FUNCTION oFlt
RETURN NIL

#endif

*#ifdef DEF_STDFILTER
*
**
** FltSetStandard()
**
** Set filter to Standard filter
** If no filter text starting with "#" exists, set filter off
**
*FUNCTION FltSetStandard(ad)
*local i
*local lFound := .F.
*local cAlias := padr(alias(),10)
*local nSelect := select()
*local cExpr := NIL
*local cText := NIL
*open area oFlt()
*  seek cAlias + UserId()
*  if FLT->Alias == cAlias .and. FLT->IdUsr == UserId()
*    cExpr := trim(FLT->Expr)
*    cText := trim(FLT->Desig)
*  endif
*close area
*RETURN ddSetFilter( ad, cExpr, cText )
*
*
*#endif DEF_STDFILTER


