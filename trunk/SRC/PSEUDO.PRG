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

**
** STATIC_SECTION global static variables
**

**
** MSG_SECTION    MSGnnn definitions
**
* static MSG001 := ""

**
** PROCEDURE_SECTION  - (...grins)
**
**
**
** XxxLibell(), XxxFirme()
**
FUNCTION GenField(cId,bField)
if cId != NIL
  if GEN->IdGen != cId
    seek cId in GEN
  endif
endif
RETURN eval(bField) // GEN->Libell1
**
FUNCTION GenName(cIdGen,cIdLng)
default cIdLng to MemLang1
if cIdGen != NIL
  if GEN->IdGen != cIdGen
    seek cIdGen in GEN
  endif
endif
#ifdef DEF_4LANG
RETURN GEN->Libell4 if cIdLng == MemLang4 .and. ! empty(GEN->Libell4)
#endif
RETURN GEN->Libell3 if cIdLng == MemLang3 .and. ! empty(GEN->Libell3)
RETURN GEN->Libell2 if cIdLng == MemLang2 .and. ! empty(GEN->Libell2)
RETURN GEN->Libell1
**
**


**
**  ParField() positioniert also geleichzeitig den Partner
**
FUNCTION ParField(cId,bField)
if cId != NIL
  if PAR->IdPar != cId
    * if PAR->(indexord()) == 1
    seek cId in PAR
    * else
    *   RETURN DbfPeek(oPar(),cId,bField,NIL)
    * endif
  endif
endif
RETURN eval(bField)

#ifdef DEF_ART

FUNCTION ArtField(cId,bField)
if ART->IdArt != cId
  seek cId in ART
endif
RETURN eval(bField)

FUNCTION ArtIdArtF() ; RETURN ART->IdArt

#endif DEF_ART

#ifdef DEF_VEN

FUNCTION VenField(cId,bBlock)
if cId != NIL
  if VEN->IdJnl + VEN->IdDoc != cId
    seek cId in VEN
  endif
endif
RETURN eval(bBlock)

#endif DEF_VEN

#ifdef DEF_FIN

FUNCTION FinField(cId,bBlock)
if cId != NIL
  if FIN->IdJnl + FIN->IdDoc != cId
    seek cId in FIN
  endif
endif
RETURN eval(bBlock)

#endif DEF_FIN


#ifdef DEF_IMP

FUNCTION ImlExpr(cId,xuExpr)
* if cId != NIL
*   if IML->IdJnl + IML->IdDoc + IML->Line != cId
    seek cId in IML
*   endif
* endif
RETURN &(xuExpr)

#endif DEF_IMP



**
*#ifdef DEF_PRESTO
*  FUNCTION TacLibell(cId)
*  if cId != NIL
*    if TAC->IdTac != cId
*      seek cId in TAC
*    endif
*  endif
*  RETURN TAC->Libell
*#endif



**
** CptName
**
FUNCTION CptName(cCptType,cCompte)
local cLibell := ""
RETURN GenName(cCompte) if empty(cCptType) //  == CPTTYPE_GEN
RETURN ParName(cCompte)

**
** CptAttrib
**
FUNCTION CptAttrib(cCptType,cCompte)
local cLibell := ""
if empty(cCptType) //  == CPTTYPE_GEN
  cLibell := GenField(cCompte, {|| GEN->Attrib})
else
  cLibell := ParField(cCompte,{||PAR->Attrib})
endif
RETURN cLibell


FUNCTION PlzName(cPays,cCP)
RETURN DbfPeek(oPlz(),cPays+cCP,"PLZ->Nom",alltrim(cPays)+"-"+alltrim(cCP))
* if PLZ->Pays != cPays .or. PLZ->Cp != cCp
*   seek cPays + cCp in PLZ
* endif
* RETURN PLZ->Nom

* FUNCTION ParAttrib(cIdJnl)
* local cAttrib := PAR->Attrib
* if empty(cAttrib)
* RETURN IfcValue(cIdJnl,PAR->IdMfc,IFC_ATTRIB)
* endif
* RETURN cAttrib

*FUNCTION ParModPai(cIdJnl)
*local cIdEsc := PAR->IdMfc
** if empty(cIdEsc)
**   cIdEsc := IfcIdEsc(cIdJnl,PAR->IdGrp)
** endif
*RETURN cIdEsc

#ifdef DEF_PSC

FUNCTION PscName(cIdPar,cIdPlt)
local cName := ""
open area oPsc(), oPar()
  softseek cIdPar
  do while ! eof() .and. PSC->IdPar == cIdPar
    if empty(cIdPlt) .or. cIdPlt == PSC->IdPlt
      cName := trim(ParName(PSC->IdPar2))
      exit
    endif
    skip
  enddo
close area
RETURN cName

#endif DEF_PSC


#ifdef DEF_HOLZ

FUNCTION DtoName(cId)
if cId != NIL
  if STM->IdStm != cId
    seek cId in STM
  endif
endif
if (eof() in STM)
  RETURN ""
endif
RETURN ltrim(STM->Laenge) + "/" + ltrim(STM->Durchm)

#endif DEF_HOLZ

FUNCTION MvtMont(cDC)
RETURN val(FIELD->Mont) if cDC == FIELD->DC
RETURN - val(FIELD->Mont)

#ifdef DEF_ECHE

FUNCTION EclIdDev
RETURN JnlIdDev(EcsIdJnl(ECL->IdEcs))

#endif DEF_ECHE

#ifdef DEF_IMP

FUNCTION BudName(cIdCtr,cIdBud)
RETURN BudField(cIdCtr, cIdBud, {|| BUD->Name1 } )

FUNCTION BudField(cIdCtr,cIdBud,bField)
if cIdBud != NIL
  if BUD->DC + BUD->IdBud != cIdCtr + cIdBud
    seek cIdCtr + cIdBud in BUD
  endif
endif
RETURN eval(bField)

#endif DEF_IMP

#ifdef DEF_PRJ

FUNCTION PrjName(cIdPrj)
RETURN PrjField(cIdPrj, {|| PRJ->Name1 } )

FUNCTION PrjField(cIdPrj,bField)
if cIdPrj != NIL
  if PRJ->IdPrj != cIdPrj
    seek cIdPrj in PRJ
  endif
endif
RETURN eval(bField)

FUNCTION HasPrj ; RETURN .t.

#else

FUNCTION PrjName ; RETURN NIL
FUNCTION HasPrj ; RETURN .f.

#endif DEF_PRJ

#ifdef DEF_ANA

FUNCTION AnaName(cIdAna)
RETURN AnaField(cIdAna, {|| ANA->Name1 } )

FUNCTION AnaField(cIdAna,bField)
if cIdAna != NIL
  if ANA->IdAna != cIdAna
    seek cIdAna in ANA
  endif
endif
RETURN eval(bField)

#endif DEF_ANA

#ifdef DEF_BIL

FUNCTION BilName(cIdBil)
RETURN BilField(cIdBil, {|| BIL->Name } )

FUNCTION BilField(cIdBil,bField)
if cIdBil != NIL
  if BIL->IdBil != cIdBil
    seek cIdBil in BIL
  endif
endif
RETURN eval(bField)

#endif DEF_BIL

*#ifdef DEF_ART_A
*
***
*** DesigArt()
***
*FUNCTION DesigArt( cLangue )
*local cDesig := ""
*#ifndef DEF_MONOLANG
*  if cLangue == MemLang2  ;  cDesig := ART->Name2
*  elseif cLangue == MemLang3  ;  cDesig := ART->Name3
*  endif
*#endif
*if empty(cDesig)
*  cDesig := ART->Name1
*endif
*RETURN trim(cDesig)
*
*#endif DEF_ART_A
*
*#ifdef DEF_ART_B
*
***
*** DesigArt()
***
*FUNCTION DesigArt( cLangue )
*local cDesig := ""
*if cLangue == MemLang2
*  cDesig := ART->Desig2
*endif
*if empty(cDesig)
*  cDesig := ART->Desig1
*endif
*RETURN trim(cDesig)
*
*#endif DEF_ART_B

#ifdef DEF_ART

FUNCTION StdArtName(cIdArt,cIdLng)
local cName := ""
if cIdArt != NIL
  if ART->IdArt != cIdArt
    seek cIdArt in ART
  endif
endif
#ifdef DEF_VAR
  cName += VarText(cIdArt,VRTATTR_P)
#endif DEF_VAR
default cIdLng to MemLang1
if cIdLng == MemLang3 .and. ! empty(ART->Name3)
  cName += ART->Name3
#ifdef DEF_4LANG
elseif cIdLng == MemLang4 .and. ! empty(ART->Name4)
  cName += ART->Name4
#endif
elseif cIdLng == MemLang2 .and. ! empty(ART->Name2)
  cName += ART->Name2
else
  cName += ART->Name1
endif
#ifdef DEF_VAR
  cName := trim1(cName) + VarText(cIdArt,VRTATTR_S)
#endif DEF_VAR
* RETURN StrParse(cName)
RETURN cName

#endif DEF_ART

#ifdef DEF_GRA

FUNCTION GraName(cId,cIdLng)
if cId != NIL
  if GRA->iGra != cId
    seek cId in GRA
  endif
endif
default cIdLng to MemLang1
RETURN GRA->Name3 if cIdLng == MemLang3 .and. ! empty(GRA->Name3)
RETURN GRA->Name2 if cIdLng == MemLang2 .and. ! empty(GRA->Name2)
RETURN GRA->Name1

#else

FUNCTION GraName ; RETURN ""

#endif DEF_GRA

#ifdef DEF_VAR

FUNCTION VarText(cIdArt,cAttrib)
local i
local aVrt := VrtList()
local cText := ""
local cIdVar
open area oVar()
  for i := 1 to len(aVrt)
    if cAttrib $ aVrt[i][VRT_ATTRIB]
      cIdVar :=  padr( ;
        substr(cIdArt,aVrt[i][VRT_START],aVrt[i][VRT_LEN]), ;
        LEN_IDVAR ;
      )
      seek aVrt[i][VRT_IDVRT] + cIdVar
      if ! eof()
        cText += aVrt[i][VRT_SEPAR1] + trim(VAR->Name1) + aVrt[i][VRT_SEPAR2]
      endif
    endif
  next i
close area
RETURN cText

#endif DEF_VAR

FUNCTION ParExpr(cId,cMac) ; RETURN ParField(cId,{||xparse(cMac)})

#ifdef DEF_VEN
FUNCTION VenExpr(cId,cMac) ; RETURN VenField(cId,cblock(cMac))
#endif DEF_VEN

#ifdef DEF_FIN

FUNCTION FnlBanque
RETURN "" if empty(FNL->IdCtr) //  == CPTTYPE_GEN
RETURN ParField(FNL->IdCpt, {|| trim(PAR->Compte1) } )

#endif DEF_FIN

* FUNCTION MfcValidate(cIdMfc)
* RETURN .t. if empty(cIdMfc)
* RETURN .t. if MfcLocate(cIdMfc) != NIL
* SetMsg(cIdMfc + " : ungltige Zahlart")
* RETURN .f.

#ifdef DEF_VNA

FUNCTION VnaObjName
RETURN GenName(left(VNA->IdArt,LenIdGen())) if VNA->Code == LNCODE_GEN
RETURN ArtName(left(VNA->IdArt,LenIdArt())) if IsArtCode(VNA->Code)
RETURN ""

FUNCTION VnaLibell()
RETURN VNA->NB1 if ! empty(VNA->NB1)
RETURN padr(VnaObjName(),LenVnlName())

#endif DEF_VNA

#ifdef DEF_PRESTO

FUNCTION TacName(cId,cIdLng)
if cId != NIL
  if TAC->IdTac != cId
    seek cId in TAC
  endif
endif
default cIdLng to MemLang1
RETURN TAC->Name3 if cIdLng == MemLang3
RETURN TAC->Name2 if cIdLng == MemLang2
RETURN TAC->Name1

FUNCTION TacExist(cIdTac)
seek cIdTac in TAC
if eof() in TAC
  SetMsg(cIdTac + " : unbekannter Tarif")
  RETURN .f.
endif
RETURN .t.

#endif DEF_PRESTO


