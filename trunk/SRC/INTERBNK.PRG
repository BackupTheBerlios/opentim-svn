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

#include "Tim.ch"

#ifdef DEF_INTERBNK

**
** STATIC_SECTION global static variables
**

* #ifdef DEF_IMP
*
* static scOtiFile := "(none)"
*
* #endif DEF_IMP

* #ifdef DEF_FIN

static snSum        := 0
static snSumComptes := 0
static snFnlCount   := 0

* #endif DEF_FIN

**
** MSG_SECTION    MSGnnn definitions
**
static MSG_OTIFAIL := " : Transferdatei kann nicht erstellt werden !"
static snDecPos := NIL
static xnMont := NIL

**
** PROCEDURE_SECTION  - (...grins)
**

#ifdef DEF_IMP

**
** ImpOtiWrite()
**
STATIC FUNCTION ImpOtiWrite(fd,jnl)
* local cFileName
* local fd
* local jnl := JnlLocate(IMP->IdJnl)
local cText
local cCommunic
local nSeq := 0
local nSum := 0
local nSumComptes := 0
local dExec := UserDate()
local lCommStruct
LOCAL cComSep := "*"  // Separator fr Mitteilung in šberweisung
if ! OtiHeader(jnl,fd,IMP->Date2)
  RETURN .f.
endif
open area oIml(), oPar(), oPlz(), oNat(), oBud()
  softseek IMP->IdJnl + IMP->IdDoc
  do while ! eof() .and. IML->IdDoc == IMP->IdDoc ;
                   .and. IML->IdJnl == IMP->IdJnl ;
                   .and. ! TaskInter()
    if !IsIBAN(IML->Compte1)
      nSeq++
      seek IML->IdPar  in PAR
      seek PAR->Pays + PAR->CP in PLZ
      seek IML->DC+IML->IdBud in BUD
      cText := ""
      cCommunic := ""
      // Interbank-Datei (Teil 1)
      ** drin lassen falls (...)
      ** if IsCommStruct(IML->NB2) // substr(IML->NB2,4,1) == "/" .and. substr(IML->NB2,9,1) == "/" .and. len(trim(IML->NB2))==14
      **   cCommunic := padr(strtran(trim(IML->NB2),"/"),106)
      **   lCommStruct := .t.
      ** else
        cCommunic := ZauComPrefix()+trim(IML->NB2)
        cCommunic += cComSep + trim(PAR->Firme)
        cCommunic += cComSep + IML->IdJnl + " " + IML->IdDoc
        cCommunic := padr(cCommunic,106)
        lCommStruct := .f.
      ** endif
      if empty(IML->IdPar2)
        seek IML->IdPar  in PAR
      else
        seek IML->IdPar2 in PAR
      endif
      seek PAR->Pays + PAR->CP in PLZ
      cText := ""
      cText += "1"
      cText += spacezero(nSeq,4,0)
      cText += "        "
      cText += "0000000000"
      cText += OtiCompte(IML->Compte1)
      cText += spacezero(&xnMont,12,snDecPos)
      nSum += &xnMont // val(IML->Mont)
      nSumComptes += val(OtiCompte(IML->Compte1))
      cText += padr(upper(PAR->Firme),26)
      cText += OtiLangue(PAR->Langue) // Langue b‚n‚ficiaire
      cText += UPPER(substr(cCommunic,1,53))
      cText += if(lCommStruct,"8","3")
      cText += CR_LF
      fwrite(fd,dos2latin1(cText))
      // Interbank-Datei (Teil 2)
      cText := ""
      cText += "2"
      cText += spacezero(nSeq,4,0)
      cText += "0"
      cText += padr(upper(ParStreet()),26)
      cText += left(PAR->CP,4)
      cText += left(upper(PLZ->Nom),22)
      if lCommStruct
        cText += space(53)
      else
        cText += UPPER(substr(cCommunic,54,53))
      endif
      if left(IML->Compte1,2) == "99" ;
         .and. substr(IML->Compte1,5,7) == repl("0",7)
        cText += "1"  // code frais
      else
        cText += "0"  // code frais
      endif
      cText += space(12)
      cText += space(4)
      cText += CR_LF
      fwrite(fd,dos2latin1(cText))
    endif
    skip
  enddo
close area
OtiFooter(fd,nSeq,nSum,nSumComptes)
* fclose(fd)
RETURN .t.

**
** OtiFooter()
**
STATIC FUNCTION OtiFooter(nFile,nDataRec,nSum,nSumKto)
LOCAL cFooter := ""
cFooter += "9"                        // Identification de l'enregistrement
cFooter += spacezero(nDataRec*2,4,0)
cFooter += spacezero(nDataRec,4,0)
cFooter += spacezero(nSum,12,snDecPos)
cFooter += spacezero(val(right(str(nSumKto),15)),15,0)
cFooter += "00000000000"
cFooter += space(81)
cFooter += CR_LF
fwrite(nFile,cFooter)
RETURN NIL


**
** OtiHeader()
**
STATIC FUNCTION OtiHeader(jnl,nFile,dExec)
LOCAL cHeader := ""
cHeader += "0"                       // Identification de l'enregistrement
cHeader += "0000"
cHeader += dtoOti(UserDate())        // Date de cr‚ation du support
cHeader += jnl[JNL_CODEBQE]          // Num‚ro de code de la banque.
                                     // CCB = "050"
cHeader += "01"                      // Code nature de l'application
cHeader += dtoOti(dExec)             // Date d'ex‚cution demand‚e
cHeader += " "                       // <D>uplicata ou non
cHeader += "000"
cHeader += strtran(jnl[JNL_COMPTE],"-","")  // Compte donneur d'ordre
cHeader += padr(MemName1,26) // Nom donneur d'ordre
cHeader += padr(MemName2,26) // Adresse donneur d'ordre
cHeader += left(MemName3,4)  // CPOST donneur d'ordre
cHeader += padr(substr(MemName3,6),22) // Loc. donneur d'ordre
cHeader += "3"                      // code langue
cHeader += jnl[JNL_CODECLI] + "0000000"    // num‚ro d'identification du fichier
* bis 19980616 : Version 1
* cHeader += "1"                      // code version
* seit 19980616 : Version "3" = ordre de paiement en BEF
*                         "5" = ordre de paiement en EUR
if IMP->IdDev == "BEF"
* if jnl[JNL_IDDEV] == "BEF"
  cHeader += "3"                      // code version
  snDecPos := 0
elseif IMP->IdDev == "EUR"
*elseif jnl[JNL_IDDEV] == "EUR"
  cHeader += "5"                      // code version
  snDecPos := 2
else
  SetMsg(IMP->IdDev + " : unbekannte W„hrung fr OTI-Dateien !")
  * SetMsg(jnl[JNL_IDDEV] + " : unbekannte W„hrung fr OTI-Dateien !")
  RETURN .f.
endif
* if jnl[JNL_IDDEV] == DevDefault(IMP->Periode)
if IMP->IdDev == DevDefault(IMP->Periode)
  xnMont := "val(IML->Mont)"
else
  xnMont := "val(IML->MontDev)"
endif
cHeader := dos2latin1(cHeader) // 20040202
fwrite(nFile,cHeader + CR_LF)
RETURN .t.


* FUNCTION OtiFile()
* local c := scOtiFile
* scOtiFile := "(none)"
* RETURN c

#endif DEF_IMP

FUNCTION dtoOti(dDate)
RETURN dtocf(dDate,"ddmmyy")


#ifdef DEF_FIN

** cParam := <code banque:3> ; <Kontonummer:12> ; <Nød'immatri:10> ; <ident. remettant:11>

**
** FinOtiFile() existiert nur zwecks Abw„rtskompatibilit„t.
**
FUNCTION FinOtiFile(cParam)
local aParam := ListAsArray(cParam,";")
local cFileName
RETURN WarnInterBnk() if len(aParam) != 3
RETURN WarnInterBnk(1) if len(aParam[1]) != 3  // Bank-Id
RETURN WarnInterBnk(2) if len(aParam[2]) != 12 // Kontonummer
RETURN WarnInterBnk(3) if len(aParam[3]) != 1 // Sprache
cFileName := AppPath() + "\EXPORT\" + left(FIN->IdJnl,2)
cFileName += FIN->IdDoc
RETURN FinOtiCreate(cFilename,aParam[1],aParam[2],aParam[3])

FUNCTION WarnInterBnk(n)
Warning("{fin interbnk : syntax error} in parameter " + ntrim(n))
RETURN NIL

#ifndef CUST_OTI1999

*
* FinOtiCreate() version "Isabel"
* see \collect\doc\ciri-interbank
*
FUNCTION FinOtiCreate( ;
  cFilename,cIdBnk,cCompte,cIdLng,cNoTva,xcFnlCompte ;
)
local cLine := ""
local fd
local lOkay := .f.
local nDecPos
default cNoTva to strtran(substr(MemNoTva,4),".","")
if len(cIdBnk) != 3
  Warning(cIdBnk + " : code banque destinataire n'a pas 3 positions")
  RETURN NIL
endif
if (fd := fcreate(cFileName)) == -1
  Warning(cFileName + MsgDosError(ferror()))
  RETURN NIL
endif
cLine := "0"                        // Identification de l'enregistrement
cLine += dtocf(UserDate(),"ddmmyy") // Date de cr‚ation du support
cLine += "0"                        // zone r‚serv‚e
cLine += repl(" ",11)               // blancs
cLine += cIdBnk                     // Num‚ro de code de la banque
cLine += "01"                       // Code nature de l'application
cLine += padr(left(FIN->IdJnl,2)+FIN->IdDoc,10)  // num‚ro d'immatriculation
cLine += padr(cNoTva,11) //
cLine += " "                        // <D>uplicata ou non
cLine += cCompte                    // Compte donneur d'ordre
if FIN->IdDev $ "BEF,BF "
  cLine += "3"                        // code version 3 = "BEF"
  nDecPos := 0
elseif FIN->IdDev == "EUR"
  cLine += "5"                        // code version 5 = "EUR"
  nDecPos := 2
else
  Warning(FIN->IdDev + " : ungltige W„hrung fr Interbank-Protokoll !")
  RETURN NIL
endif
cLine += dtocf(FIN->Date,"ddmmyy")  // Date d'ex‚cution
cLine += repl(" ",1)                // blancs
cLine += "00" // objet de paiement (non d‚fini)
cLine += repl(" ",242)                // blancs
cLine += repl(" ",3)                  // blancs
cLine += repl(" ",47)                 // zone r‚serv‚e blancs
* cLine += "000"
fwrite(fd,cLine+CR_LF)
snSum        := 0
snSumComptes := 0
snFnlCount   := 0
open area oFnl(), oPar(), oPlz(), oNat()
  lOkay := .t.
  softseek FIN->IdJnl + FIN->IdDoc
  do while ! eof() .and. FNL->IdJnl == FIN->IdJnl ;
                   .and. FNL->IdDoc == FIN->IdDoc
    if ! FnlOtiLine(fd,nDecPos,cIdLng,xcFnlCompte)
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
cLine := "9"                        // Identification de l'enregistrement
cLine += space(15)
cLine += spacezero(snFnlCount,6,0)
cLine += spacezero(snSum,12,nDecPos)
cLine += space(11)
cLine += spacezero(val(right(str(snSumComptes),15)),15,0)
cLine += "2" // code fichier multiple (2 = dernier fichier)
cLine += padr(FIN->IdJnl+FIN->IdDoc,12)
cLine += space(267)
cLine += space(20)
fwrite(fd,cLine+CR_LF)
fclose(fd)
RETURN cFileName if lOkay
Warning(SetMsg(),FIN->IdJnl + " " + FIN->IdDoc + MSG_OTIFAIL)
if ! USRATTR_E $ UsrAttrib()
  delete file (cFileName)
endif
RETURN FIN->IdJnl + " " + FIN->IdDoc + MSG_OTIFAIL

*
* FinOtiCreate() version "Isabel"
* see \collect\doc\ciri-interbank
*
STATIC FUNCTION FnlOtiLine(fd,nDecPos,cIdLng,xcFnlCompte)
local cText := ""
local cCommunic := ""
local lCommStruct
local cCompte
local nMont
default xcFnlCompte to "PAR->Compte1"
seek left(FNL->IdCpt,LenIdPar()) in PAR
cCompte := xparse(xcFnlCompte)
if empty(cCompte)
  SetMsg(FNL->Line + " : " + trim(ParName()) + " : ohne Kontonummer !")
  RETURN .f.
endif
if FNL->DC == DC_CREDIT
  SetMsg(FNL->Line + " : Kredit-Buchung in Zahlungsauftrag !")
  RETURN .f.
endif
seek PAR->Pays + PAR->CP in PLZ
// Interbank-Datei (Teil 1)
if substr(FNL->Libell,4,1) == "/" .and. substr(FNL->Libell,9,1) == "/"
  cCommunic := padr(strtran(trim(FNL->Libell),"/"),106)
  lCommStruct := .t.
else
  cCommunic := padr(FNL->Libell,106)
  lCommStruct := .f.
endif
snFnlCount++
cText := ""
cText += "1"  // Identification de l'enregistrement
cText += spacezero(snFnlCount,6,0)
cText += space(3)
cText += padr(FNL->IdJnl+FNL->IdDoc+FNL->Line,13) // nø de r‚f. propre au donneur d'ordre
cText += space(24) // Blancs
cText += "0" // code civilit‚
cText += "0" // code frais
cText += repl("0",10) // z‚ros
cText += OtiCompte(cCompte) // compte du b‚n‚ficiaire
cText += if(lCommStruct,"8","3") // code nature
cText += repl("0",3) // z‚ros
snSumComptes += val(OtiCompte(cCompte))
if FIN->IdDev == DevDefault(FIN->Periode)
  nMont := val(FNL->Mont)
else
  nMont := val(FNL->MontDev)
endif
snSum += nMont
cText += spacezero(nMont,12,nDecPos) // montant
cText += padr(alltrim(MemName1),26) // Nom donneur d'ordre
cText += padr(alltrim(MemName2),26) // Adresse donneur d'ordre
cText += padr(i_plz(MemName3,2),4)  // CPOST donneur d'ordre
cText += padr(i_plz(MemName3,3),22) // Loc. donneur d'ordre
cText += OtiLangue(cIdLng)          // code langue
cText += padr(ParName(),26)     // nom du b‚n‚ficiaire
cText += padr(ParStreet(),26)
cText += left(PAR->CP,4)
cText += upper(left(PLZ->Nom,22))
cText += OtiLangue(PAR->Langue) // langue b‚n‚ficiaire
cText += upper(substr(cCommunic,1,53))
cText += space(9) // Blancs
fwrite(fd,cText+CR_LF)
*// Interbank-Datei (Teil 2)
*cText := ""
*cText += "2"
*cText += spacezero(snFnlCount,4,0)
*cText += "0"  // code de civilit‚ b‚n‚ficiaire
*if lCommStruct
*  cText += space(53)
*else
*  cText += UPPER(substr(cCommunic,54,53))
*endif
*if left(PAR->Compte1,2) == "99" ;
*   .and. substr(PAR->Compte1,5,7) == repl("0",7)
*  cText += "1"  // code frais
*else
*  cText += "0"  // code frais
*endif
*cText += space(12)
*cText += space(4)
*fwrite(fd,cText+CR_LF)
RETURN .t.

#endif

#ifdef CUST_OTI1999

*
* alte Version (bis 19991213)
*
FUNCTION FinOtiCreate(cFilename,cIdBnk,cCompte,cIdLng)
local cLine := ""
local fd
local lOkay := .f.
local nDecPos
if (fd := fcreate(cFileName)) == -1
  Warning(cFileName + MsgDosError(ferror()))
  RETURN NIL
endif
cLine := "0"                        // Identification de l'enregistrement
cLine += "0"                        // z‚ro
cLine += "0"                        // zone r‚serv‚e
cLine += "00"                       // objet du paiement
cLine += dtocf(UserDate(),"ddmmyy") // Date de cr‚ation du support
cLine += cIdBnk                     // Num‚ro de code de la banque
cLine += "01"                       // Code nature de l'application
cLine += dtocf(FIN->Date,"ddmmyy")  // Date d'ex‚cution
cLine += " "                        // <D>uplicata ou non
cLine += "000"
cLine += cCompte                    // Compte donneur d'ordre
cLine += padr(alltrim(MemName1),26) // Nom donneur d'ordre
cLine += padr(alltrim(MemName2),26) // Adresse donneur d'ordre
cLine += padr(i_plz(MemName3,2),4)  // CPOST donneur d'ordre
cLine += padr(i_plz(MemName3,3),22) // Loc. donneur d'ordre
cLine += OtiLangue(cIdLng)          // code langue
cLine += padr(left(FIN->IdJnl,2)+FIN->IdDoc,10)  // num‚ro d'immatriculation
if FIN->IdDev $ "BEF,BF "
  cLine += "3"                        // code version 3 = "BEF"
  nDecPos := 0
elseif FIN->IdDev == "EUR"
  cLine += "5"                        // code version 5 = "EUR"
  nDecPos := 2
else
  Warning(FIN->IdDev + " : ungltige W„hrung fr Interbank-Protokoll !")
endif
fwrite(fd,cLine+CR_LF)
snSum        := 0
snSumComptes := 0
snFnlCount   := 0
open area oFnl(), oPar(), oPlz(), oNat()
  lOkay := .t.
  softseek FIN->IdJnl + FIN->IdDoc
  do while ! eof() .and. FNL->IdJnl == FIN->IdJnl ;
                   .and. FNL->IdDoc == FIN->IdDoc
    if ! FnlOtiLine(fd,nDecPos)
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
cLine := "9"                        // Identification de l'enregistrement
cLine += spacezero(snFnlCount*2,4,0)
cLine += spacezero(snFnlCount,4,0)
cLine += spacezero(snSum,12,nDecPos)
cLine += spacezero(val(right(str(snSumComptes),15)),15,0)
cLine += padr(MemNoTva,11) // substr(cParam,29,11)
cLine += space(81)
fwrite(fd,cLine+CR_LF)
fclose(fd)
RETURN cFileName if lOkay
Warning(SetMsg(),FIN->IdJnl + " " + FIN->IdDoc + MSG_OTIFAIL)
if ! USRATTR_E $ UsrAttrib()
  delete file (cFileName)
endif
RETURN FIN->IdJnl + " " + FIN->IdDoc + MSG_OTIFAIL


*
* alte Version (bis 19991213)
*
STATIC FUNCTION FnlOtiLine(fd,nDecPos)
local cText := ""
local cCommunic := ""
local lCommStruct
seek left(FNL->IdCpt,LenIdPar()) in PAR
if empty(PAR->Compte1)
  SetMsg(FNL->Line + " : " + trim(ParName()) + " : ohne Kontonummer !")
  RETURN .f.
endif
if FNL->DC == DC_CREDIT
  SetMsg(FNL->Line + " : Kredit-Buchung in Zahlungsauftrag !")
  RETURN .f.
endif
seek PAR->Pays + PAR->CP in PLZ
// Interbank-Datei (Teil 1)
if substr(FNL->Libell,4,1) == "/" .and. substr(FNL->Libell,9,1) == "/"
  cCommunic := padr(strtran(trim(FNL->Libell),"/"),106)
  lCommStruct := .t.
else
  cCommunic := padr(FNL->Libell,106)
  lCommStruct := .f.
endif
snFnlCount++
cText := ""
cText += "1"  // Identification de l'enrecistrement
cText += spacezero(snFnlCount,4,0)
cText += space(8) // nø de r‚f. propre au donneur d'ordre
cText += space(10) // Blancs
cText += OtiCompte(PAR->Compte1)
snSumComptes += val(OtiCompte(PAR->Compte1))
cText += spacezero(val(FNL->Mont),12,nDecPos)
snSum += val(FNL->Mont)
cText += padr(ParName(),26)     // nom du b‚n‚ficiaire
cText += OtiLangue(PAR->Langue) // langue b‚n‚ficiaire
cText += upper(substr(cCommunic,1,53))
cText += if(lCommStruct,"8","3")
fwrite(fd,cText+CR_LF)
* PrintLine(cText)
// Interbank-Datei (Teil 2)
cText := ""
cText += "2"
cText += spacezero(snFnlCount,4,0)
cText += "0"  // code de civilit‚ b‚n‚ficiaire
cText += padr(ParStreet(),26)
cText += left(PAR->CP,4)
cText += upper(left(PLZ->Nom,22))
if lCommStruct
  cText += space(53)
else
  cText += UPPER(substr(cCommunic,54,53))
endif
if left(PAR->Compte1,2) == "99" ;
   .and. substr(PAR->Compte1,5,7) == repl("0",7)
  cText += "1"  // code frais
else
  cText += "0"  // code frais
endif
cText += space(12)
cText += space(4)
fwrite(fd,cText+CR_LF)
RETURN .t.

#endif CUST_OTI1999

*
* alte Version (bis 19990216)
*
*FUNCTION FinOtiCreate(cFilename,cIdBnk,cCompte,cIdLng)
*local cLine := ""
*local fd
*local lOkay := .f.
*if (fd := fcreate(cFileName)) == -1
*  Warning(cFileName + MsgDosError())
*  RETURN NIL
*endif
*cLine := "0"                        // Identification de l'enregistrement
*cLine += "0000"
*cLine += dtocf(UserDate(),"ddmmyy") // Date de cr‚ation du support
*cLine += cIdBnk                     // Num‚ro de code de la banque
*cLine += "01"                       // Code nature de l'application
*cLine += dtocf(FIN->Date,"ddmmyy")  // Date d'ex‚cution
*cLine += " "                        // <D>uplicata ou non
*cLine += "000"
*cLine += cCompte // substr(cParam,5,12)  // Compte donneur d'ordre
*cLine += padr(alltrim(MemName1),26) // Nom donneur d'ordre
*cLine += padr(alltrim(MemName2),26) // Adresse donneur d'ordre
*cLine += padr(i_plz(MemName3,2),4)  // CPOST donneur d'ordre
*cLine += padr(i_plz(MemName3,3),22) // Loc. donneur d'ordre
*cLine += OtiLangue(cIdLng)       // code langue
*cLine += padr(left(FIN->IdJnl,2)+FIN->IdDoc,10)  // num‚ro d'immatriculation
*cLine += "2"                        // code version
*fwrite(fd,cLine+CR_LF)
*snSum        := 0
*snSumComptes := 0
*snFnlCount   := 0
*open area oFnl(), oPar(), oPlz(), oNat()
*  lOkay := .t.
*  softseek FIN->IdJnl + FIN->IdDoc
*  do while ! eof() .and. FNL->IdJnl == FIN->IdJnl ;
*                   .and. FNL->IdDoc == FIN->IdDoc
*    if ! FnlOtiLine(fd)
*      lOkay := .f.
*      exit
*    endif
*    skip
*  enddo
*close area
*cLine := "9"                        // Identification de l'enregistrement
*cLine += spacezero(snFnlCount*2,4,0)
*cLine += spacezero(snFnlCount,4,0)
*cLine += spacezero(snSum,12,0)
*cLine += spacezero(val(right(str(snSumComptes),15)),15,0)
*cLine += padr(MemNoTva,11) // substr(cParam,29,11)
*cLine += space(81)
*fwrite(fd,cLine+CR_LF)
*fclose(fd)
*RETURN cFileName if lOkay
*Warning(SetMsg(),FIN->IdJnl + " " + FIN->IdDoc + MSG_OTIFAIL)
*if ! USRATTR_E $ UsrAttrib()
*  delete file (cFileName)
*endif
*RETURN FIN->IdJnl + " " + FIN->IdDoc + MSG_OTIFAIL
*
*
*STATIC FUNCTION FnlOtiLine(fd)
*local cText := ""
*local cCommunic := ""
*local lCommStruct
*seek left(FNL->IdCpt,LenIdPar()) in PAR
*if empty(PAR->Compte1)
*  SetMsg(trim(ParName()) + " : ohne Kontonummer !")
*  RETURN .f.
*endif
*if FNL->DC == DC_CREDIT
*  SetMsg(FNL->Line + " : Kredit-Buchung in Zahlungsauftrag !")
*  RETURN .f.
*endif
*seek PAR->Pays + PAR->CP in PLZ
*// Interbank-Datei (Teil 1)
*if substr(FNL->Libell,4,1) == "/" .and. substr(FNL->Libell,9,1) == "/"
*  cCommunic := padr(strtran(trim(FNL->Libell),"/"),106)
*  lCommStruct := .t.
*else
*  cCommunic := padr(FNL->Libell,106)
*  lCommStruct := .f.
*endif
*snFnlCount++
*cText := ""
*cText += "1"  // Identification de l'enrecistrement
*cText += spacezero(snFnlCount,4,0)
*cText += space(8) // nø de r‚f. propre au donneur d'ordre
*cText += space(10) // "0000000000"
*cText += OtiCompte(PAR->Compte1)
*snSumComptes += val(OtiCompte(PAR->Compte1))
*cText += spacezero(val(FNL->Mont),12,0)
*snSum += val(FNL->Mont)
*cText += padr(ParName(),26)     // nom du b‚n‚ficiaire
*cText += OtiLangue(PAR->Langue) // langue b‚n‚ficiaire
*cText += upper(substr(cCommunic,1,53))
*cText += if(lCommStruct,"8","3")
*fwrite(fd,cText+CR_LF)
** PrintLine(cText)
*// Interbank-Datei (Teil 2)
*cText := ""
*cText += "2"
*cText += spacezero(snFnlCount,4,0)
*cText += "0"  // code de civilit‚ b‚n‚ficiaire
*cText += padr(ParStreet(),26)
*cText += left(PAR->CP,4)
*cText += upper(left(PLZ->Nom,22))
*if lCommStruct
*  cText += space(53)
*else
*  cText += UPPER(substr(cCommunic,54,53))
*endif
*if left(PAR->Compte1,2) == "99" ;
*   .and. substr(PAR->Compte1,5,7) == repl("0",7)
*  cText += "1"  // code frais
*else
*  cText += "0"  // code frais
*endif
*cText += space(12)
*cText += space(4)
*fwrite(fd,cText+CR_LF)
*RETURN .t.



#endif DEF_FIN

#ifdef DEF_IMP

* 2002-01-03 : SYSI-Dateien k”nnen gar nicht mehr in BEF gemacht werden.


**
** {imp sysifile \
**   <code remettant:3> ; <code banque:3> ; <Kontonummer:12> ; <Sprache:1> \
** }
**
FUNCTION ImpSysiFile(cParam)
local cLine := ""
local aParam := ListAsArray(cParam,";")
local cFileName
local fd
local lOkay := .f.
local jnl := JnlLocate(IMP->IdJnl)
RETURN NIL if jnl == NIL
RETURN WarnInterBnk() if len(aParam) != 4
RETURN WarnInterBnk(1) if len(aParam[1]) != 3  // Code remettant
RETURN WarnInterBnk(2) if len(aParam[2]) != 3  // Code banque
RETURN WarnInterBnk(3) if len(aParam[3]) != 12 // Kontonummer
RETURN WarnInterBnk(4) if len(aParam[4]) != 1 // Sprache
cFileName := TmpConvert( ;
  AppPath() + "\" + trim(IMP->IdJnl) + "*.OTI" ;
)
* cFileName := TmpConvert(AppPath() + "\" + trim(IMP->IdJnl) + "*.OTI")
if (fd := fcreate(cFileName)) == -1
  Warning(cFileName + MsgDosError(ferror()))
  RETURN NIL
endif
cLine := "A"                        // Identification de l'enregistrement
cLine += "0000"
cLine += dtocf(UserDate(),"ddmmyy") // Date de cr‚ation du support
cLine += aParam[1]                  // code remettant
cLine += space(9)
cLine += aParam[2]                  // code banque
cLine += "06"                       // Nature (06=pr‚l.en fav. de l'inst.)
cLine += padr(aParam[1],10,"0")  // num‚ro d'identification du fichier
cLine += dtocf(IMP->Date2,"ddmmyy")  // Date valeur
cLine += space(3)
cLine += "5"
cLine += "EUR"
cLine += space(77)
fwrite(fd,cLine+CR_LF)
* cLine += aParam[2] // substr(cParam,5,12)  // Compte donneur d'ordre
* cLine += padr(alltrim(MemName1),26) // Nom donneur d'ordre
* cLine += padr(alltrim(MemName2),26) // Adresse donneur d'ordre
* cLine += padr(i_plz(MemName3,2),4)  // CPOST donneur d'ordre
* cLine += padr(i_plz(MemName3,3),22) // Loc. donneur d'ordre
* cLine += OtiLangue(aParam[3])       // code langue
* cLine += padr(left(IMP->IdJnl,2)+IMP->IdDoc,10)  // num‚ro d'immatriculation
* cLine += "2"                        // code version
* fwrite(fd,cLine+CR_LF)
snSum        := 0
snSumComptes := 0
snFnlCount   := 0
open area oIml(), oPar(), oPlz(), oNat()
  lOkay := .t.
  softseek IMP->IdJnl + IMP->IdDoc
  do while ! eof() .and. IML->IdJnl == IMP->IdJnl ;
                   .and. IML->IdDoc == IMP->IdDoc
    if ! ImlSysiLine(fd,aParam)
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
cLine := "Z"                        // Identification de l'enregistrement
cLine += "9999"
cLine += aParam[1]      // code remettant    len=3
cLine += space(5)
cLine += aParam[2]      // code banque  len=3
cLine += spacezero(snFnlCount,6,0)
cLine += spacezero(snSum,12,2)
cLine += spacezero(val(right(str(snSumComptes),15)),15,0)
cLine += padr(aParam[1],10,"0")  // num‚ro d'identification du fichier
cLine += space(69)
fwrite(fd,cLine+CR_LF)
fclose(fd)
RETURN cFileName if lOkay
Warning(IMP->IdJnl + " " + IMP->IdDoc + MSG_OTIFAIL)
if ! USRATTR_E $ UsrAttrib()
  delete file (cFileName)
endif
RETURN IMP->IdJnl + " " + IMP->IdDoc + MSG_OTIFAIL


STATIC FUNCTION ImlSysiLine(fd,aParam)
local cText := ""
local cCommunic := ""
*local lCommStruct
*if empty(IML->Compte1)
*  SetMsg(IML->Line + " : " + trim(ParName()) + " ohne Kontonummer !")
*  RETURN .f.
*endif
*if FNL->DC == DC_CREDIT
*  SetMsg(FNL->Line + " : Kredit-Buchung in Zahlungsauftrag !")
*  RETURN .f.
*endif
*seek PAR->Pays + PAR->CP in PLZ
*// Interbank-Datei (Teil 1)
*if substr(FNL->Libell,4,1) == "/" .and. substr(FNL->Libell,9,1) == "/"
*  cCommunic := padr(strtran(trim(FNL->Libell),"/"),106)
*  lCommStruct := .t.
*else
*  cCommunic := padr(FNL->Libell,106)
*  lCommStruct := .f.
*endif
snFnlCount++
cText := "B"   // Identification de l'enrecistrement
cText += spacezero(snFnlCount,4,0)
cText += CCBMonth(IMP->Date2) // ex‚cution demand‚e
cText += aParam[1]
cText += spacezero(snFnlCount,10,0)
cText += OtiCompte(IML->Compte1)
snSumComptes += val(OtiCompte(IML->Compte1))
seek IML->IdPar in PAR
cText += padr(PAR->Firme,26)     // nom du b‚n‚ficiaire
cText += padr(ParStreet(),26)     // nom du b‚n‚ficiaire
cText += left(PAR->CP,4)
seek PAR->Pays + PAR->CP in PLZ
cText += left(PLZ->Nom,14)
cText += OtiLangue(PAR->Langue) // langue b‚n‚ficiaire
cText += aParam[3]  // kontonummer
cText += "0"
cText += "4" // langue b‚n‚ficiaire
cText += spacezero(val(IML->Mont),10,2)
snSum += val(IML->Mont)
fwrite(fd,cText+CR_LF)

// Interbank-Datei (Teil 2)
cText := "C"   // Identification de l'enrecistrement
cText += spacezero(snFnlCount,4,0)
cText += padr(alltrim(MemName1),26) // Nom b‚n‚f.
cText += padr(alltrim(MemName2),26) // Adresse b‚n‚f.
cText += padr(i_plz(MemName3,2),4)  // CPOST b‚n‚f.
cText += padr(i_plz(MemName3,3),14) // Loc. b‚n‚f.
cText += "3"  // code nature de l'ordre
* cText += padr(ParStreet(),26)
* cText += left(PAR->CP,4)
* cText += upper(left(PLZ->Nom,22))
cText += padr(IML->NB2,52)
*if lCommStruct
*  cText += space(53)
*else
*  cText += UPPER(substr(cCommunic,54,53))
*endif
*if left(PAR->Compte1,2) == "99" ;
*   .and. substr(PAR->Compte1,5,7) == repl("0",7)
*  cText += "1"  // code frais
*else
*  cText += "0"  // code frais
*endif
*cText += space(12)
*cText += space(4)
fwrite(fd,cText+CR_LF)
RETURN .t.

FUNCTION WarnInterBnk(n)
Warning("{imp sysifile : syntax error} in parameter " + ntrim(n))
RETURN NIL

FUNCTION CCBMonth(dDate)
local c := strtran(str(day(dDate),2)," ","0")
local nMonth := month(dDate)
if nMonth < 10
  c += str(nMonth,1)
elseif nMonth == 10
  c += "O"
elseif nMonth == 11
  c += "N"
elseif nMonth == 12
  c += "D"
endif
RETURN c


#endif DEF_IMP


FUNCTION OtiCompte(cCompte)
RETURN padr(strtran(cCompte,"-",""),12)

FUNCTION OtiLangue(cLangue)
RETURN "1" if cLangue == "N"
RETURN "2" if cLangue == "F"
RETURN "3" if cLangue == "D"
RETURN "4" if cLangue == "E"
RETURN "0"


#ifdef DEF_IMP

FUNCTION ImpWriteZau(cFilename)
local cReturn := ""
local jnl := JnlLocate(IMP->IdJnl)
* local lOkay := .t.
default cFilename to AppPath() + "\" + substr(IMP->IdJnl,2,2) + IMP->IdDoc
#ifdef DEF_IBAN
  if ImpImlFind("!IsIBAN(IML->Compte1)")
    if fgenerate(cFilename+".OTI", {|fd|ImpOtiWrite(fd,jnl)})
      cReturn := cFilename+".OTI"
    else
      RETURN .f.
      * cReturn := SetMsg()
      * lOkay := .f.
    endif
  else
    cReturn := "(ohne *.OTI)"
  endif
  if ImpImlFind("IsIBAN(IML->Compte1)")
    if fgenerate(cFilename+".VME", {|fd|ImpVmeWrite(fd,jnl)})
      cReturn := trim1(cReturn,"; ") + cFilename+".VME"
    else
      RETURN .f.
      * cReturn := trim1(cReturn,"; ") + SetMsg()
      * lOkay := .f.
    endif
  else
    cReturn := trim1(cReturn,"; ") + "(ohne *.VME)"
  endif
#else
  if fgenerate(cFilename+".OTI", {|fd|ImpOtiWrite(fd,jnl)})
    cReturn := cFilename+".OTI"
  else
    RETURN .f.
  endif
#endif
RETURN cReturn



#ifdef DEF_IBAN

FUNCTION ImpImlFind(xlFind)
local lFound := .f.
open area oIml()
  softseek IMP->IdJnl + IMP->IdDoc
  do while ! eof() .and. IML->IdDoc == IMP->IdDoc ;
                   .and. IML->IdJnl == IMP->IdJnl ;
                   .and. ! TaskInter()
    if &xlFind
      lFound := .t.
      exit
    endif
    skip
  enddo
close area
RETURN lFound


* FUNCTION IBAN2BIC(cIBAN)
* local a := split(cIBAN,":")
* if len(a) != 2
*   raise(cIBAN+" : bad IBAN"))
* endif
* RETURN a[1]

#define IBAN_BIC  1
#define IBAN_IBAN 2
#define IBAN_ALEN 2


* Paiements ‚trangers
* Standard bancaire nø I.4
* Lay-out 128 - Version 3.1 - Edition avril 2003
* g:\doc\iban\ad18069.pdf
* revidiert am 20060102 laut wp14021.pdf (Seite 10 ff.)
STATIC FUNCTION ImpVmeWrite(fd,jnl)
local cText
local cCommunic
local nSeq := 0
local nSum := 0
* local nSumComptes := 0
local lCommStruct
* local cIdBic
* local cIBAN
local a
local lOkay := .f.
LOCAL cComSep := "*"  // Separator fr Mitteilung in šberweisung
local cCompte := BqeBeParse(jnl[JNL_COMPTE])
RETURN .f. if cCompte == NIL
cCompte := strtran(cCompte,'-')
if len(cCompte) != 12
  RETURN ! SetMsg(cCompte + " : L„nge msste 12 sein!")
endif
if IMP->IdDev != "EUR"
  RETURN ! SetMsg(IMP->IdDev + " : W„hrung wird nicht untersttzt!")
endif
if IMP->IdDev == DevDefault(IMP->Periode)
  xnMont := "val(IML->Mont)"
else
  xnMont := "val(IML->MontDev)"
endif
snDecPos := DevDecPos(IMP->IdDev)
cText := "0"                       // Identification de l'enregistrement
cText += dtoOti(UserDate())        // Date de cr‚ation du support
cText += space(12)                 // Blancs
cText += jnl[JNL_CODEBQE]          // Num‚ro de code de la banque.
                                   // CCB = "050"
if len(jnl[JNL_CODEBQE]) != 3
  RETURN !SetMsg(jnl[JNL_CODEBQE]+" : code banque invalide")
endif
cText += "51"                      // Code application : 51
cText += jnl[JNL_CODECLI] + "0000000"  // num‚ro d'identification du fichier
                                       // Nø de r‚f‚rence du fichier attribu‚ par le remettant
cText += padr('',11) // NøTVA (d'immatriculation) du remettant du fichier
cText += padr('',11) // NøTVA (d'immatriculation) du donneur d'ordre
cText += " "                      // <D>uplicata ou non
cText += "3"                      // code version
cText += padr('',12) // zone r‚serv‚e aux relations bilat‚rales
cText += "0"   // code globalisation : pas de globalisation
cText += space(4) // blancs
cText += "1" // sous-code version
cText += space(52) // blancs
fwrite(fd,cText + CR_LF)
open area oIml(), oPar(), oPlz(), oNat()
  lOkay := .t.
  softseek IMP->IdJnl + IMP->IdDoc
  do while ! eof() .and. IML->IdDoc == IMP->IdDoc ;
                   .and. IML->IdJnl == IMP->IdJnl ;
                   .and. ! TaskInter()
    if IsIBAN(IML->Compte1)
      a := split(IML->Compte1,":")
      if len(a) != IBAN_ALEN
        SetMsg(IML->Compte1+" : ungltige IBAN")
        lOkay := .f.
        * break
        exit
      endif
      if BicCountry(a[IBAN_BIC]) == NIL
        SetMsg(a[IBAN_BIC] + " : unbekannte oder falsche BIC !")
        lOkay := .f.
        * break
        exit
      endif
      a[IBAN_IBAN] := strtran(a[IBAN_IBAN]," ") // neu 20040713
      * cIdBic := IBAN2BIC(IML->Compte1)
      nSeq++
      if empty(IML->IdPar2)
        seek IML->IdPar  in PAR
      else
        seek IML->IdPar2 in PAR
      endif
      seek PAR->Pays + PAR->CP in PLZ
      * seek IML->IdPar  in PAR
      * seek PAR->Pays + PAR->CP in PLZ
      *
      // Enregistrement de donn‚es 1 : sous-division 01
      cText := "1"                       // Identification de l'enregistrement
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "01" // 6-7 sous-division
      cText += dtoOti(IMP->Date2)        // 8-13 date d'ex‚cution demand‚e
      cText += space(16) // 14-29 r‚f du donneur d'ordre
      cText += IMP->IdDev    // 30-32 Code ISO de la monnaie du paiement
      cText += " " // 33 blanc
      cText += "C" // 34 Code relatif au montant … payer (annexe I.4)
                   // C : Si le montant est exprim‚ dans la devise du paiement (cas
                   // normal).
      cText += spacezero(&xnMont,15,snDecPos) // 35-49 montant … payer
      nSum += &xnMont // val(IML->Mont)
      * nSumComptes += val(OtiCompte(IML->Compte1))
      cText += " " // 50 : blanc
      cText += space(3) // 51-53 devise du compte … d‚biter ou blancs.
      cText += space(6) // 54-59 : 6 blancs
      cText += cCompte  // 60-71 : Nø de compte … d‚biter
      cText += space(22) // 72-93 : blancs
      cText += space(1) // Indication relative … la date demand‚e en
                        // positions 8-13 : date en 8-13 = date d'ex‚cution
      cText += space(34) // 95-128 : blancs
      cText += CR_LF
      fwrite(fd,cText)
      *

      // sous-divisions 02, 03, 05
      // vielleicht gar nicht n”tig. Ist ja immer der gleiche
      // "Les sous-divisions 01, 06, 10 et 11 sont obligatoires, les autres
      // sous-divisions sont optionnelles;"
      // 20031002 aber Robert Gillon sagt, dass sie obligatorisch sind:
      // "Il faut noter que chaque type de record est requis (1 … 12)."
      // 20031008 Gillon hat sich vertan : er hatte mit 3.0 getestet
      * cText := "1"
      * cText += spacezero(nSeq,4,0) // 2-5
      * cText += "02" // sous-division
      * cText += space(35) // nom du donneur d'ordre ou blancs
      * cText += space(70) // adresse du donneur d'ordre ou blancs
      * cText += space(16) // blancs
      * cText += CR_LF
      * fwrite(fd,cText)
      **
      *cText := "1"
      *cText += spacezero(nSeq,4,0) // 2-5
      *cText += "03" // sous-division
      *cText += space(35+10+11+65) //
      *cText += CR_LF
      *fwrite(fd,cText)
      *
      // Enregistrement de donn‚es 1 : sous-division 04
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "04" // 6-7 : sous-division
      cText += space(80) // 8-87 : blancs
      cText += padr(a[IBAN_BIC],35) // 88-122 : BIC (Id. de la banque du b‚n‚f)
      cText += "1" // 123 : indicateur que 88-122 contient un BIC
      cText += space(5) // 124-128 : blancs
      cText += CR_LF
      fwrite(fd,cText)
      *
      *cText := "1"
      *cText += spacezero(nSeq,4,0) // 2-5
      *cText += "05" // sous-division
      *cText += space(35+35+35+16) //
      *cText += CR_LF
      *fwrite(fd,cText)
      *
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "06" // 6-7 : sous-division
      cText += padr(a[IBAN_IBAN],34) // 8-41 : IBAN
      cText += padr(PAR->Firme,35) // 42-76 : Nom du b‚n‚f.
      cText += padr(ParStreet(),35) //
      cText += "1" // 123 : indicateur que 8-41 contient un IBAN
      cText += BicCountry(a[IBAN_BIC]) // Code ISO alphab‚tique du pays de  destination
      cText += space(14) // 115-128 : blancs
      cText += CR_LF
      fwrite(fd,dos2latin1(cText))
      *
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "07" // 6-7 : sous-division
      cText += space(35) // 8-42 : blancs
      cText += padr(ParCity(),35) // 43-77 : Localit‚, Etat, Pays
      cText += space(10) // 78-87 : blancs
      cCommunic := trim(IML->NB2)
      cCommunic += cComSep + trim(PAR->Firme)
      cCommunic += cComSep + IML->IdJnl + " " + IML->IdDoc
      cCommunic := padr(cCommunic,106)
      cText += padr(cCommunic,35) // 88-122 : communication ligne 1
      cText += space(6) // 123-128 : blancs
      cText += CR_LF
      fwrite(fd,dos2latin1(cText))
      *
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "08" // 6-7 : sous-division
      cText += substr(cCommunic,36,35) // 8-42 : communication ligne 2
      cText += substr(cCommunic,71,35) // 43-77 : communication ligne 3
      cText += space(35) //
      cText += space(16) //
      cText += CR_LF
      fwrite(fd,dos2latin1(cText))
      *
      * cText := "1"
      * cText += spacezero(nSeq,4,0) // 2-5
      * cText += "09" // sous-division
      * cText += space(35+35+35+16) //
      * cText += CR_LF
      * 20031013 fwrite(fd,cText)
      *
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "10" // 6-7 : sous-division
      cText += space(35) //
      cText += "   " // mode de paiement laiss‚ au choix de la banque
      * cText += "NOR" // code frais (until 20031104 "SHA")
      cText += "SHA" // 20031111 : wieder zurck auf ÿSHA"
      cText += " " // 49 : blanc
      cText += IMP->IdDev //
      cText += space(6) //
      cText += space(12) // 59-70 : compte frais … d‚biter (si diff‚rent)
      cText += space(1) //
      cText += BicCountry(a[IBAN_BIC]) // Code ISO alphab‚tique du pays de  destination
      cText += space(55) // blancs
      cText += CR_LF
      fwrite(fd,cText)
      *
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "11" // 6-7 : sous-division
      cText += "000" // rubrique balance des paiements
      cText += spacezero(&xnMont,15,snDecPos) // montant … payer
      cText += space(6) //
      cText += space(49) // justification
      cText += space(10) // accord bilat‚ral
      cText += space(38) // blancs
      cText += CR_LF
      fwrite(fd,cText)
      *
    endif
    skip
  enddo
close area
// footer
cText := ""
cText += "9"                        // Identification de l'enregistrement
cText += spacezero(nSeq*7,6,0)
cText += spacezero(nSeq,6,0)
cText += spacezero(nSum,15,snDecPos)
cText += space(100)
cText += CR_LF
fwrite(fd,cText)
RETURN lOkay



#endif DEF_IBAN

#endif DEF_IMP


#ifdef DEF_FIN

** 20040428:
** replace FinOtiCreate() with FinWriteZau()
**
FUNCTION FinWriteZau(cFilename,xcFnlCompte)
local nCount
local cReturn := ""
local jnl := JnlLocate(FIN->IdJnl)
* local lOkay := .t.
default cFilename to AppPath() + "\" + substr(FIN->IdJnl,2,2) + FIN->IdDoc
default xcFnlCompte to "PAR->Compte1"
#ifdef DEF_IBAN
  nCount := FinFnlCount(xcFnlCompte,"!IsIBAN("+xcFnlCompte+")")
  if nCount > 0
    if fgenerate(cFilename+".FBF", {|fd|FinOtiWrite(fd,jnl,xcFnlCompte)})
      cReturn := cFilename+".FBF"
    else
      RETURN .f.
      * cReturn := SetMsg()
      * lOkay := .f.
    endif
  elseif nCount == 0
    cReturn := "(ohne *.FBF)"
  else
    RETURN .f.
  endif
  nCount := FinFnlCount(xcFnlCompte,"IsIBAN("+xcFnlCompte+")")
  if nCount > 0
    if fgenerate(cFilename+".VME", {|fd|FinVmeWrite(fd,jnl,xcFnlCompte)})
      cReturn := trim1(cReturn,"; ") + cFilename+".VME"
    else
      RETURN .f.
      * cReturn := trim1(cReturn,"; ") + SetMsg()
      * lOkay := .f.
    endif
  elseif nCount == 0
    cReturn := trim1(cReturn,"; ") + "(ohne *.VME)"
  else
    RETURN .f.
  endif
#else
  if fgenerate(cFilename+".FBF", {|fd|FinOtiWrite(fd,jnl,xcFnlCompte)})
    cReturn := cFilename+".FBF"
  else
    RETURN .f.
  endif
#endif
RETURN cReturn



#ifdef DEF_IBAN

STATIC FUNCTION FinFnlCount(xcFnlCompte,xlFilter)
local nCount := 0
RETURN -1 if ! FinFnlLoop(xcFnlCompte,xlFilter,{||nCount+=1,.t.})
RETURN nCount

FUNCTION FinFnlLoop(xcFnlCompte,xlFilter,b)
* local lFound := .f.
local lOkay := .f.
local cCompte
open area oFnl(),oPar(),oPlz()
  lOkay := .t.
  softseek FIN->IdJnl + FIN->IdDoc
  do while lOkay .and. ! eof() ;
           .and. FNL->IdDoc == FIN->IdDoc ;
           .and. FNL->IdJnl == FIN->IdJnl
    if TaskInter()
      lOkay := .f.
      exit
    endif
    if !ParExist(left(FNL->IdCpt,LenIdPar()))
      lOkay := .f.
      exit
    endif
    * seek left(FNL->IdCpt,LenIdPar()) in PAR
    * cCompte := xparse(xcFnlCompte)
    * if empty(cCompte)
    *   SetMsg(FNL->Line + " : " + trim(ParName()) + " : ohne Kontonummer !")
    *   lOkay := .f.
    * endif
    seek PAR->Pays + PAR->CP in PLZ
    if &xlFilter
      if ! eval(b)
        lOkay := .f.
        exit
      endif
    endif
    skip
  enddo
close area
RETURN lOkay


* FUNCTION IBAN2BIC(cIBAN)
* local a := split(cIBAN,":")
* if len(a) != 2
*   raise(cIBAN+" : bad IBAN"))
* endif
* RETURN a[1]

#define IBAN_BIC  1
#define IBAN_IBAN 2
#define IBAN_ALEN 2


** Copy of ImpVmeWrite(), replacing IMP and IMP by FIN and FNL
**	
STATIC FUNCTION FinVmeWrite(fd,jnl,xcFnlCompte)
local cText
local cCommunic
local nSeq := 0
local nSum := 0
local cFnlCompte
* local nSumComptes := 0
local lCommStruct
* local cIdBic
* local cIBAN
local a
local lOkay := .f.
LOCAL cComSep := "*"  // Separator fr Mitteilung in šberweisung
local cCompte := BqeBeParse(jnl[JNL_COMPTE])
RETURN .f. if cCompte == NIL
cCompte := strtran(cCompte,'-')
if len(cCompte) != 12
  RETURN ! SetMsg(cCompte + " : L„nge msste 12 sein!")
endif
if FIN->IdDev != "EUR"
  RETURN ! SetMsg(FIN->IdDev + " : W„hrung wird nicht untersttzt!")
endif
if FIN->IdDev == DevDefault(FIN->Periode)
  xnMont := "val(FNL->Mont)"
else
  xnMont := "val(FNL->MontDev)"
endif
snDecPos := DevDecPos(FIN->IdDev)
cText := "0"                       // Identification de l'enregistrement
cText += dtoOti(UserDate())        // Date de cr‚ation du support
cText += space(12)                 // Blancs
cText += jnl[JNL_CODEBQE]          // Num‚ro de code de la banque.
                                   // CCB = "050"
if len(jnl[JNL_CODEBQE]) != 3
  RETURN !SetMsg(jnl[JNL_CODEBQE]+" : code banque invalide")
endif
cText += "51"                      // Code application : 51
cText += jnl[JNL_CODECLI] + "0000000"  // num‚ro d'identification du fichier
                                       // Nø de r‚f‚rence du fichier attribu‚ par le remettant
cText += padr('',11) // NøTVA (d'immatriculation) du remettant du fichier
cText += padr('',11) // NøTVA (d'immatriculation) du donneur d'ordre
cText += " "                      // <D>uplicata ou non
cText += "3"                      // code version
cText += padr('',12) // zone r‚serv‚e aux relations bilat‚rales
cText += "0"   // code globalisation : pas de globalisation
cText += space(4) // blancs
cText += "1" // sous-code version
cText += space(52) // blancs
fwrite(fd,cText + CR_LF)
open area oFnl(), oPar(), oPlz(), oNat()
  lOkay := .t.
  softseek FIN->IdJnl + FIN->IdDoc
  do while lOkay .and. ! eof() .and. FNL->IdDoc == FIN->IdDoc ;
                 .and. FNL->IdJnl == FIN->IdJnl ;
                 .and. ! TaskInter()

    if ! ParExist(left(FNL->IdCpt,LenIdPar()))
      SetMsg(FNL->IdCpt+" : no such partner")
      lOkay := .f.
      exit
    endif
    cFnlCompte := &xcFnlCompte
    if IsIBAN(cFnlCompte)
      a := split(cFnlCompte,":")
      if len(a) != IBAN_ALEN
        SetMsg(cFnlCompte+" : bad IBAN")
        lOkay := .f.
        exit
      endif
      if BicCountry(a[IBAN_BIC]) == NIL
        SetMsg(a[IBAN_BIC] + " : unbekannte oder falsche BIC !")
        lOkay := .f.
        exit
      endif
      * cIdBic := IBAN2BIC(FNL->Compte1)
      nSeq++
      seek PAR->Pays + PAR->CP in PLZ
      *
      // Enregistrement de donn‚es 1 : sous-division 01
      cText := "1"                       // Identification de l'enregistrement
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "01" // 6-7 sous-division
      cText += dtoOti(FIN->Date)        // 8-13 date d'ex‚cution demand‚e
      cText += space(16) // 14-29 r‚f du donneur d'ordre
      cText += FIN->IdDev    // 30-32 Code ISO de la monnaie du paiement
      cText += " " // 33 blanc
      cText += "C" // 34 Code relatif au montant … payer (annexe I.4)
                   // C : Si le montant est exprim‚ dans la devise du paiement (cas
                   // normal).
      cText += spacezero(&xnMont,15,snDecPos) // 35-49 montant … payer
      nSum += &xnMont // val(FNL->Mont)
      cText += " " // 50 : blanc
      cText += space(3) // 51-53 devise du compte … d‚biter ou blancs.
      cText += space(6) // 54-59 : 6 blancs
      cText += cCompte  // 60-71 : Nø de compte … d‚biter
      cText += space(22) // 72-93 : blancs
      cText += space(1) // Indication relative … la date demand‚e en
                        // positions 8-13 : date en 8-13 = date d'ex‚cution
      cText += space(34) // 95-128 : blancs
      cText += CR_LF
      fwrite(fd,cText)
      *
      // sous-divisions 02, 03, 05
      // vielleicht gar nicht n”tig. Ist ja immer der gleiche
      // "Les sous-divisions 01, 06, 10 et 11 sont obligatoires, les autres
      // sous-divisions sont optionnelles;"
      // 20031002 aber Robert Gillon sagt, dass sie obligatorisch sind:
      // "Il faut noter que chaque type de record est requis (1 … 12)."
      // 20031008 Gillon hat sich vertan : er hatte mit 3.0 getestet
      * cText := "1"
      * cText += spacezero(nSeq,4,0) // 2-5
      * cText += "02" // sous-division
      * cText += space(35) // nom du donneur d'ordre ou blancs
      * cText += space(70) // adresse du donneur d'ordre ou blancs
      * cText += space(16) // blancs
      * cText += CR_LF
      * fwrite(fd,cText)
      **
      *cText := "1"
      *cText += spacezero(nSeq,4,0) // 2-5
      *cText += "03" // sous-division
      *cText += space(35+10+11+65) //
      *cText += CR_LF
      *fwrite(fd,cText)
      *
      // Enregistrement de donn‚es 1 : sous-division 04
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "04" // 6-7 : sous-division
      cText += space(80) // 8-87 : blancs
      cText += padr(a[IBAN_BIC],35) // 88-122 : BIC (Id. de la banque du b‚n‚f)
      cText += "1" // 123 : indicateur que 88-122 contient un BIC
      cText += space(5) // 124-128 : blancs
      cText += CR_LF
      fwrite(fd,cText)
      *
      *cText := "1"
      *cText += spacezero(nSeq,4,0) // 2-5
      *cText += "05" // sous-division
      *cText += space(35+35+35+16) //
      *cText += CR_LF
      *fwrite(fd,cText)
      *
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "06" // 6-7 : sous-division
      cText += padr(a[IBAN_IBAN],34) // 8-41 : IBAN
      cText += padr(PAR->Firme,35) // 42-76 : Nom du b‚n‚f.
      cText += padr(ParStreet(),35) //
      cText += "1" // 123 : indicateur que 8-41 contient un IBAN
      cText += BicCountry(a[IBAN_BIC]) // Code ISO alphab‚tique du pays de  destination
      cText += space(14) // 115-128 : blancs
      cText += CR_LF
      fwrite(fd,dos2latin1(cText))
      *
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "07" // 6-7 : sous-division
      cText += space(35) // 8-42 : blancs
      cText += padr(ParCity(),35) // 43-77 : Localit‚, Etat, Pays
      cText += space(10) // 78-87 : blancs
      *
      if substr(FNL->Libell,4,1) == "/" .and. substr(FNL->Libell,9,1) == "/"
        cCommunic := padr(strtran(trim(FNL->Libell),"/"),106)
        *lCommStruct := .t.
      else
        cCommunic := padr(FNL->Libell,106)
        *lCommStruct := .f.
      endif
      * cCommunic := trim(FNL->NB2)
      * cCommunic += cComSep + trim(PAR->Firme)
      * cCommunic += cComSep + FNL->IdJnl + " " + FNL->IdDoc
      * cCommunic := padr(cCommunic,106)
      cText += padr(cCommunic,35) // 88-122 : communication ligne 1
      cText += space(6) // 123-128 : blancs
      cText += CR_LF
      fwrite(fd,dos2latin1(cText))
      *
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "08" // 6-7 : sous-division
      cText += substr(cCommunic,36,35) // 8-42 : communication ligne 2
      cText += substr(cCommunic,71,35) // 43-77 : communication ligne 3
      cText += space(35) //
      cText += space(16) //
      cText += CR_LF
      fwrite(fd,dos2latin1(cText))
      *
      * cText := "1"
      * cText += spacezero(nSeq,4,0) // 2-5
      * cText += "09" // sous-division
      * cText += space(35+35+35+16) //
      * cText += CR_LF
      * 20031013 fwrite(fd,cText)
      *
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "10" // 6-7 : sous-division
      cText += space(35) //
      cText += "   " // mode de paiement laiss‚ au choix de la banque
      * cText += "NOR" // code frais (until 20031104 "SHA")
      cText += "SHA" // 20031111 : wieder zurck auf ÿSHA"
      cText += " " // 49 : blanc
      cText += FIN->IdDev //
      cText += space(6) //
      cText += space(12) // 59-70 : compte frais … d‚biter (si diff‚rent)
      cText += space(1) //
      cText += BicCountry(a[IBAN_BIC]) // Code ISO alphab‚tique du pays de  destination
      cText += space(55) // blancs
      cText += CR_LF
      fwrite(fd,cText)
      *
      cText := "1"
      cText += spacezero(nSeq,4,0) // 2-5
      cText += "11" // 6-7 : sous-division
      cText += "000" // rubrique balance des paiements
      cText += spacezero(&xnMont,15,snDecPos) // montant … payer
      cText += space(6) //
      cText += space(49) // justification
      cText += space(10) // accord bilat‚ral
      cText += space(38) // blancs
      cText += CR_LF
      fwrite(fd,cText)
      *
    endif
    skip
  enddo
close area
// footer
cText := ""
cText += "9"                        // Identification de l'enregistrement
cText += spacezero(nSeq*7,6,0)
cText += spacezero(nSeq,6,0)
cText += spacezero(nSum,15,snDecPos)
cText += space(100)
cText += CR_LF
fwrite(fd,cText)
RETURN lOkay




#endif DEF_IBAN

**
** copy of FinOtiCreate(), adapted to be called by FinWriteZau()
** continues to use FnlOtiLine() from above
STATIC FUNCTION FinOtiWrite( fd, jnl, xcFnlCompte )
local cLine := ""
local lOkay := .f.
local nDecPos
local cNoTva := strtran(substr(MemNoTva,4),".","")
local cIdBnk := jnl[JNL_CODEBQE]
local cCompte := BqeBeParse(jnl[JNL_COMPTE])
RETURN .f. if cCompte == NIL
cCompte := strtran(cCompte,'-')
if len(cCompte) != 12
  RETURN ! SetMsg(cCompte + " : L„nge msste 12 sein!")
endif
if len(cIdBnk) != 3
  SetMsg(cIdBnk + " : code banque destinataire n'a pas 3 positions")
  RETURN .f. 
endif
cLine := "0"                        // Identification de l'enregistrement
cLine += dtocf(UserDate(),"ddmmyy") // Date de cr‚ation du support
cLine += "0"                        // zone r‚serv‚e
cLine += repl(" ",11)               // blancs
cLine += cIdBnk                     // Num‚ro de code de la banque
cLine += "01"                       // Code nature de l'application
cLine += padr(left(FIN->IdJnl,2)+FIN->IdDoc,10)  // num‚ro d'immatriculation
cLine += padr(cNoTva,11) //
cLine += " "                        // <D>uplicata ou non
cLine += cCompte                    // Compte donneur d'ordre
if FIN->IdDev $ "BEF,BF "
  cLine += "3"                        // code version 3 = "BEF"
  nDecPos := 0
elseif FIN->IdDev == "EUR"
  cLine += "5"                        // code version 5 = "EUR"
  nDecPos := 2
else
  SetMsg(FIN->IdDev + " : ungltige W„hrung fr Interbank-Protokoll !")
  RETURN .f.
endif
cLine += dtocf(FIN->Date,"ddmmyy")  // Date d'ex‚cution
cLine += repl(" ",1)                // blancs
cLine += "00" // objet de paiement (non d‚fini)
cLine += repl(" ",242)                // blancs
cLine += repl(" ",3)                  // blancs
cLine += repl(" ",47)                 // zone r‚serv‚e blancs
* cLine += "000"
fwrite(fd,cLine+CR_LF)
snSum        := 0
snSumComptes := 0
snFnlCount   := 0
RETURN .f. if ! FinFnlLoop(xcFnlCompte,;
        "!IsIBAN("+xcFnlCompte+")",;
        {||FnlOtiLine(fd,nDecPos,MemLang1,xcFnlCompte)})
cLine := "9"                        // Identification de l'enregistrement
cLine += space(15)
cLine += spacezero(snFnlCount,6,0)
cLine += spacezero(snSum,12,nDecPos)
cLine += space(11)
cLine += spacezero(val(right(str(snSumComptes),15)),15,0)
cLine += "2" // code fichier multiple (2 = dernier fichier)
cLine += padr(FIN->IdJnl+FIN->IdDoc,12)
cLine += space(267)
cLine += space(20)
fwrite(fd,cLine+CR_LF)
RETURN .t.




#endif DEF_FIN

#endif DEF_INTERBNK


FUNCTION spacezero(nValue,nLen,nDecPos)
local c
default nDecPos to 0
c := strtran(ltrim(str(nValue,nLen,nDecPos)),".","")
* if nDecPos != 0
  // nValue := int(nValue * ( 10 ** nDecPos ))
* endif
// RETURN padl(nValue,nLen,"0")
RETURN padl(c,nLen,"0")

FUNCTION fgenerate(cFilename,blExec)
local fd
if (fd := fcreate(cFileName)) == -1
  SetMsg(cFileName + MsgDosError(ferror()))
  RETURN .f.
endif
MsgDisplay("Schreibe Datei " + cFileName + "...")
if eval(blExec,fd)
  fclose(fd)
  RETURN .t.
endif
fclose(fd)
ferase(cFilename)
RETURN .f.


