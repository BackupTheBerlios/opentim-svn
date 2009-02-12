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


#include "TIM.CH"


#ifdef DEF_VEN

static sbVnaVenMemo := {|aMemos|join(aMemos,CR_LF+"---"+CR_LF)}

#ifdef LG_FRENCH
  static LEG_VNATAG := "[Leertaste] Ausw„hlen [*] Umkehren [Escape] Abbrechen [Enter] Weiter"
#else
  static LEG_VNATAG := "[Leertaste] Ausw„hlen [*] Umkehren [Escape] Abbrechen [Enter] Weiter"
#endif


FUNCTION VenIniConfig()
AddIniCmd( { "VnaVenMemo"  , {|x| (sbVnaVenMemo := xparse(x)) != NIL } } )
RETURN .t.

STATIC FUNCTION VnaVenMemo(aMemos) ; RETURN eval(sbVnaVenMemo,aMemos)

FUNCTION MsgVnaAuto
#ifdef LG_GERMAN
  RETURN "Automatik-Fakturierung"
#else
  RETURN "Facturation automatique"
#endif

FUNCTION DocHeader(doc,cIdJnl,cIdDoc,cLangue)
local cHeader
cHeader := trim(JnlDocLib(cIdJnl,cIdDoc,doc[DOC_DC],cLangue))
if cLangue == "F"
  cHeader += " du "
elseif cLangue == "N"
  cHeader += " van "
else
  cHeader += " vom "
endif
cHeader += dtocf(doc[DOC_DATE])
RETURN cHeader





FUNCTION MsgVna07
#ifdef LG_GERMAN
RETURN "Nichts zu fakturieren."
#else
RETURN "Rien … facturer."
#endif


FUNCTION VnaTag(aNaf,cIdPar,cTitle,cIdJnl)
local cTagAttrib := TagVnaAttrib(cIdJnl)
local i
local lFound := .f.
local aTagActions := {}
local nWidth := WinWidth() - 10
local bcUsing := {|x| NafLine(x,cIdPar,nWidth,cTagAttrib) }
aadd(aTagActions, { K_SPACE, {|tag| TagToggle(tag) } } )
aadd(aTagActions, { asc("*"), {|| TagInvert(aNaf) } } )
aadd(aTagActions, { K_CTRL_RET, {|x| ArtPage(x[NAF_IDART]), K_ALT_F5 } } )
SetMsg(ntrim(len(aNaf)) + " " + MsgVnaTag(cIdJnl))
open area oArt()
  browse array aNaf using (bcUsing) ;
                    actions aTagActions ;
                    help "NAFTAG" ;
                    delete {|x|NafDelete(x)} ;
                    legend (LEG_VNATAG) ;
                    title (cTitle)
close area
RETURN .f. if lastchoice() == 0
RETURN .t.


FUNCTION NafDelete(naf)
local lOkay := .f.
#ifdef DEF_VNA
if ArtExist(naf[NAF_IDART]).and.!ARTATTR_S $ ART->Attrib
  if JNLATTR_Q $ JnlAttrib(naf[NAF_IDJNL])
    RETURN !SetMsg( ;
      "Suppression manuelle uniquement pour articles sans stock!")
  endif
endif    
RETURN .f. if ! Confirm(;
  "Suppression manuelle de la proposition!",MsgSure())
open area oVna()
  seek naf[NAF_IDJNL] + naf[NAF_IDDOC] + naf[NAF_LINE]
  if !eof()
    if ddRecLock()
      VNA->Satis := VNASATIS_D
      unlock record
      lOkay := .t.
    endif
    * if DoEvents(oVna():cargo[AD_PREDELETE],"NafDelete")
    *
    * endif
  endif
close area
#endif DEF_VNA
RETURN lOkay

* default
* NafLine(cIdPar,x[NAF_TAGGED],x[NAF_IDDOC],x[NAF_IDJNL],;
*                  x[NAF_DATE],x[NAF_IDART],x[NAF_HTVA],x[NAF_TVAC],;
*                  x[NAF_NB],x[NAF_QTE])
* NafLine(cIdPar,cTagged,cIdDoc,cIdJnl,dDate,cIdArt,;
*                  cHTVA,cTVAC,cNB1,cQte)

STATIC FUNCTION NafLine(naf,cIdPar,nWidth,cTagAttrib)
local c
local cLine := if(naf[NAF_TAGGED],BUTTON_ON,BUTTON_OFF)+" "
default nWidth to 75
if naf[NAF_IDDOC] != NIL
  cLine += trim1(naf[NAF_IDJNL])
  cLine += trim1(naf[NAF_IDDOC])
endif
if naf[NAF_DATE] != NIL
  cLine += trim1(dtoc(naf[NAF_DATE]))
endif
if NAFATTR_I $ cTagAttrib
  #ifdef DEF_ART_REF
    // cLine += " " + naf[NAF_IDDOC]
    cLine += trim(ArtField(naf[NAF_IDART],{||ART->Ref})) + ": "
  #else
    seek naf[NAF_IDART] in ART
    cLine += trim1(naf[NAF_IDART])
  #endif DEF_ART_REF
endif
if naf[NAF_HTVA] != NIL
  cLine += naf[NAF_HTVA]+" "
endif
if naf[NAF_TVAC] != NIL
  cLine += naf[NAF_TVAC]+" "
endif
if NAFATTR_D $ cTagAttrib
  cLine += trim1(ArtName())
endif
cLine += trim1(naf[NAF_NB1])
#ifdef DEF_ACF
  cLine += trim1(ArtAcfRef(naf[NAF_IDART],cIdPar))
#endif DEF_ACF
if NAFATTR_S $ cTagAttrib
  c := iif(ARTATTR_S $ ART->Attrib.or.qton(ART->Lager)>=qton(naf[NAF_QTE]),"OK ","")
  *c := "(a: "+trim1(ltrim(ART->Lager))
  ** c += "c:"+trim1(ltrim(ART->Auftrag))
  ** c += "f:"+trim1(ltrim(ART->Bestellt))+") "
  c += naf[NAF_QTE]
  * c += ") " + naf[NAF_QTE]
else
  c := naf[NAF_QTE]
endif
RETURN padr(cLine,nWidth-len(c))+c

STATIC FUNCTION TagToggle(tag)
tag[NAF_TAGGED] := ! tag[NAF_TAGGED]
RETURN K_DOWN

STATIC FUNCTION TagInvert(aTag)
local i
for i := 1 to len(aTag)
  aTag[i][NAF_TAGGED] := ! aTag[i][NAF_TAGGED]
next i
RETURN K_ALT_F5


FUNCTION PreVenAuto(cIdJnl)
local lOkay := .f.
open area oVen()
  KeyGoBottom( cIdJnl, "VEN->IdJnl")
  if eof() .or. VEN->Etat == DocStatClosed()
    lOkay := .t.
  else
    SetMsg(MsgPrevDoc()+MsgNotClosed())
  endif
close area
RETURN lOkay

FUNCTION JnlIsActive(cIdJnl,dDate)
local lOkay := .f.
local cIdDoc
local cPeriode := PerActive(dDate)
local jnl := JnlLocate(cIdJnl)
RETURN !SetMsg(cIdJnl+MsgJnlExist()) if jnl == NIL
open area oJnl()
  seek cIdJnl
  cIdDoc := JnlNextIdDoc(JNL->SeqType,JNL->IdDoc,cPeriode)
  lOkay := CheckIdDoc(jnl,cIdDoc,cPeriode)
close area
RETURN lOkay

FUNCTION FilteredSkip(xlFilter)
do while !eof()
  skip
  RETURN .t. if &xlFilter
enddo
RETURN .f.

#ifdef DEF_VNA

#define LEG_PNFBROWSE "[Leertaste] ausw„hlen [*] Ausw.umkehren [Enter] Weiter [Escape] Abbrechen"

FUNCTION VnaAuto2( cTitle,;
  cIdJnl,dDate,;
  cIdPar1,cIdPar2,;
  xlVnaFilter,xlParFilter,;
  cMontMin,;
  lEdit,lVnaTag,;
  xcNB1,xcZahler,xcAkte,;
  cIdJnlI,;
  lSimulate,cTitle1,cTitle2,cTitle3)
local cPeriode
local aPnf := {}
local lOkay := .t.
local aNafSim := {}
local jnl := JnlLocate(cIdJnl)
local jnlt, jnli
local ifc
local n,i,j
local nErr := 0
local nNew := 0
local pnf
local nMont
default xcZahler to "PAR->IdPar"
default xcAkte to "PAR->IdPar"
default dDate to UserDate()
default cIdPar1 to space(LenIdPar())
default cIdPar2 to space(LenIdPar())
default xcNB1 to "''"
default lEdit to .f.
default lSimulate to .f.
if jnl == NIL
  SetMsg(cIdJnl + MsgJnlExist())
  RETURN .f.
endif
if cIdJnlI != NIL
  jnli := JnlLocate(cIdJnlI)
  if jnli == NIL
    SetMsg(cIdJnlI + MsgJnlExist())
    RETURN .f.
  endif
endif
cPeriode := PerActive(dDate)
RETURN .f. if ! PreVenAuto(cIdJnl)
RETURN .f. if ! PnfCollect(aPnf,jnl,cIdPar1,cIdPar2,dDate,xlVnaFilter,xlParFilter,cMontMin)
// RETURN .f. if ! confirm(utos(aPnf))
RETURN .f. if ! PnfSelect(aPnf,cTitle,jnl)
open area oPar(), oVen()
  for i := 1 to len(aPnf)
    pnf:=aPnf[i]
    if pnf[PNF_TAGGED]
      seek pnf[PNF_IDPAR]
      if lVnaTag
        lOkay := VnaTag(pnf[PNF_AVNA],pnf[PNF_IDPAR],;
          trim1(ParName())+pnf[PNF_MATCH]+": ";
            +MsgVnaTag(),jnl[JNL_IDJNL])
        pnf[PNF_MONT] := 0
        for j := 1 to len(pnf[PNF_AVNA])
          nMont := qton(pnf[PNF_AVNA][j][VNA_QTEUS])*val(pnf[PNF_AVNA][j][VNA_PRIXU])
          pnf[PNF_MONT] += nMont
        next j
      else
        lOkay := .t.
      endif
      if lOkay
        if pnf[PNF_MONT] < 0 .and. jnli != NIL
          jnlt:= jnli
        else
          jnlt := jnl
        endif
        if (ifc := IfcLocate(jnlt[JNL_IDCTR],;
          jnlt[JNL_IDJNL],PAR->IdMfc)) == NIL
          SetMsg( ;
            PAR->IdPar + " : " + ;
            jnlt[JNL_IDJNL] + " & " + PAR->IdMfc + MsgIfcFail(), ;
          )
          lOkay := .f.
        else
          n := ParVenAppend( ;
            pnf[PNF_AVNA],&xcZahler,jnlt,ifc,dDate,cPeriode,pnf[PNF_MATCH],;
            lEdit, ;
            .f., ;
            SetPreview(), ;
            PAR->IdMfc, ;
            &xcAkte, cMontMin, lSimulate, aNafSim ;
          )
          if n < 0
            nErr += 1
            if ! Confirm(SetMsg(),MsgContinue())
              lOkay := .f.
              exit
            endif
          else
            nNew += n
          endif
        endif
      endif
    endif
  next i
close area
SetMsg(;
  ntrim(nNew)+utr(" documents"," Dokumente"," documents")+iif(nErr==0,;
    ".",;
    " ("+ntrim(nErr)+utr(" errors"," Fehler"," erreurs")+").";
  ))
RETURN .f. if ! lOkay
if lSimulate
  NafSimReport(aNafSim,cTitle1,cTitle2,cTitle3)
endif
RETURN .t.

STATIC FUNCTION PnfInvert(aTag)
local i
for i := 1 to len(aTag)
  aTag[i][PNF_TAGGED] := ! aTag[i][PNF_TAGGED]
next i
RETURN K_ALT_F5

FUNCTION PnfCollect(aPnf,jnl,cIdPar1,cIdPar2,dDate,xlVnaFilter,xlParFilter,cMontMin)
local nCount := 0
local cIdPar
local nMont
local pnf
local lOkay := .f.
local trn
local i
local cVnaMatch := ""
// local xcVnaMatch := "trim(VEN->NB1)"
default xlParFilter to "!'" + PARATTR_A +"'$PAR->Attrib"
default xlVnaFilter to "empty(VNA->Satis)"
// default xcVnaMatch to "NIL"
open area oVna(), oPar(), oArt(), oVen()
  ddSetOrder(ORD_VNA_PARDATE)
  softseek trim(cIdPar1)
  lOkay := .t.
  do while lOkay .and. ! eof()
    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    // MsgDisplay(ntrim(recno()))
    if TaskInter() ; exit ; endif
    if ! empty(cIdPar2)
      if left(VNA->IdPar,len(trim(cIdPar2))) > trim(cIdPar2)
        exit
      endif
    endif
    if &xlVnaFilter
      seek VNA->IdPar in PAR
      // MsgDisplay(trim(ParName()) + "...")
      if &(xlParFilter)
        seek VNA->IdJnl + VNA->IdDoc in VEN
        if ! VENATTR_A $ VEN->Attrib
          if (trn := VnaTrnLocate(jnl)) != NIL
            if ! TRNATTR_M $ trn[TRN_ATTRIB]
              if VEN->DatEch <= dDate .or. TRNATTR_D $ trn[TRN_ATTRIB]
                pnf := VnaPnfColl(aPnf,VnaMatch())
                nMont := qton1(VNA->QteUs)*val(VNA->PrixU)
                if TRNATTR_I $ trn[TRN_ATTRIB]
                  nMont := -nMont
                endif
                if VNA->DC == jnl[JNL_DC]
                  pnf[PNF_MONT] += nMont
                else
                  pnf[PNF_MONT] -= nMont
                endif
                lOkay := NafCollect(pnf[PNF_AVNA],;
                  VNA->IdJnl,;
                  VNA->IdDoc,;
                  VNA->Line,; // VNA->Match,;
                  VNA->Date,;
                  VNA->IdArt,;
                  VNA->Code,;
                  VNA->QteUs,;
                  VNA->NB1,;
                  VNA->Memo,;
                  VNA->PrixU,;
                  (TRNATTR_X $ trn[TRN_ATTRIB]),;
                  VNA->QteForm,;
                  if(HasInt(),VNA->QteStat,NIL),;
                  if(HasInt(),VNA->IdInt,NIL),;
                  if(HasProvi(),VNA->PrixL,NIL),;
                  if(HasVnlAttr(),VNA->Attrib,NIL),;
                  if(TRNATTR_I $ trn[TRN_ATTRIB],DcInvert(VNA->DC),VNA->DC),;
                  TRNATTR_U $ trn[TRN_ATTRIB],;
                  NIL,NIL,NIL,NIL,;
                  VnaMustEdit();
                )
              endif
            endif
          endif
        endif
      endif
    endif
    skip          
  enddo
close area
for i := 1 to len(aPnf)
  if !empty(cMontMin) .and. abs(aPnf[i][PNF_MONT]) < val(cMontMin)
    aPnf[i][PNF_TAGGED] := .f.
  endif
next i
RETURN lOkay

STATIC FUNCTION VnaPnfColl(aPnf,cVnaMatch)
local i
local pnf
for i := 1 to len(aPnf)
  if aPnf[i][PNF_MATCH] == cVnaMatch
    if aPnf[i][PNF_IDPAR] == VNA->IdPar
      pnf = aPnf[i]
      exit
    endif
  endif
next i
if pnf == NIL
  pnf := { .t., VNA->IdPar, cVnaMatch, {}, 0, VEN->IdDev, ;
    VNA->IdJnl, VNA->IdDoc, VEN->Date } // PNF_ALEN
  aadd(aPnf,pnf)
  MsgDisplay("("+ntrim(len(aPnf)) + ") " + trim(ParName()) + "...")
endif
RETURN pnf




FUNCTION PnfSelect(aPnf,cTitle,jnl)
local lOkay := .t.
local aActions := {}
aadd(aActions, { asc("*"), {|| ;
  PnfInvert(aPnf) ;
} } )
aadd(aActions, { K_SPACE , {|m| ;
  m[PNF_TAGGED] := !m[PNF_TAGGED], ;
  K_DOWN ;
} } )
*aadd(aActions, { K_F6 , {|m| ;
*  VnaTag(m[PNF_AVNA],m[PNF_IDPAR],m[PNF_MATCH]+": "+MsgVnaTag(),jnl[JNL_IDJNL]), ;
*  NIL ;
*} } )
open area oPar(), oVen(), oArt()
  browse array aPnf using {|m| ;
      iif(m[PNF_TAGGED],"X"," ");
      +" "+m[PNF_IDPAR];
      +" "+padr(ParName(m[PNF_IDPAR]),30);
      +" "+padr(m[PNF_MATCH],25);
      +" "+m[PNF_IDJNL];
      +" "+m[PNF_IDDOC];
      +" "+dtoc(m[PNF_DATE]);
      +" "+ntom(m[PNF_MONT]);
      +" "+m[PNF_IDDEV];
    } ;
    title (cTitle) ;
    legend (LEG_PNFBROWSE) ;
    actions (aActions) ;
    delete {||.f.}
  if lastchoice() == 0
    lOkay := .f.
  endif
close area
RETURN lOkay

FUNCTION ParPnfPick(aPnf,oStart,cTitle)
local nStart := 0
local i
if oStart != NIL
  for i := 1 to len(aPnf)
    if aPnf[i][PNF_MATCH] == oStart[PNF_MATCH]
      nStart := i
      exit
    endif
  next i
endif
open area oPar(), oVen(), oArt()
  browse array aPnf using {|m| ;
      padr(iif(empty(m[PNF_MATCH]),;
        utrp("(no externale ref.)",;
          "(ohne externe Ref.)",;
          "(sans r‚f‚rence ext.)"),;
        m[PNF_MATCH]),25);
      +" "+m[PNF_IDJNL];
      +" "+m[PNF_IDDOC];
      +" "+dtoc(m[PNF_DATE]);
      +" "+ntom(m[PNF_MONT]);
      +" "+m[PNF_IDDEV];
    } ;
    title (cTitle) ;
    start (nStart) ;
    delete {||.f.}
close area
RETURN NIL if lastchoice() == 0
RETURN aPnf[lastchoice()]



#endif DEF_VNA



#define NSIM_PAR1 1
#define NSIM_PAR2 2
#define NSIM_MONT 3
#define NSIM_AVNA 4
#define NSIM_ALEN 4


** NafAuto() : Nachfolger von VnaAuto
**
FUNCTION NafAuto( bVnlSuggest,;
  cIdJnl,dDate,;
  lDlg,lVnaTag,;
  cIdPar1,cIdPar2,cMontMin,xlParFilter,xcNB1,xcZahler,xcAkte,;
  lSimulate,cTitle1,cTitle2,cTitle3)
local cPeriode
local aVna
local lOkay := .t.
local aNafSim := {}
local nCount := 0
local jnl := JnlLocate(cIdJnl)
local ifc
local n
local nErr := 0
local nNew := 0
default xcZahler to "PAR->IdPar"
default xcAkte to "PAR->IdPar"
default dDate to UserDate()
* default xlVnaFilter to ".t."
default xlParFilter to "!'" + PARATTR_A +"'$PAR->Attrib"
default cIdPar1 to space(LenIdPar())
default cIdPar2 to space(LenIdPar())
default xcNB1 to "''"
* default cNB1 to space(30)
default lDlg to .f.
default lSimulate to .f.
if jnl == NIL
  SetMsg(cIdJnl + MsgJnlExist())
  RETURN .f.
endif
cPeriode := PerActive(dDate)
* if (cPeriode := PerActive(dDate)) == NIL
*   SetMsg("Keine Periode aktiv am "+ dtoc(dDate)+" !")
*   RETURN .f.
* endif
RETURN .f. if ! PreVenAuto(cIdJnl)
open area oPar(), oArt()
  softseek trim(cIdPar1)
  do while lOkay .and. ! eof()
    MsgDisplay(trim(ParName()) + "...")
    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if TaskInter() ; exit ; endif
    if ! empty(cIdPar2)
      if left(PAR->IdPar,len(trim(cIdPar2))) > trim(cIdPar2)
        exit
      endif
    endif
    if &(xlParFilter)
      n := 1
      do while lOkay .and. n > 0
        if (ifc := IfcLocate(jnl[JNL_IDCTR],jnl[JNL_IDJNL],PAR->IdMfc)) == NIL
          SetMsg( ;
            PAR->IdPar + " : " + ;
            jnl[JNL_IDJNL] + " & " + PAR->IdMfc + MsgIfcFail(), ;
          )
          lOkay := .f.
        else
          aVna := eval(bVnlSuggest,jnl,ifc)
          n := ParVenAppend( ;
            aVna,&xcZahler,jnl,ifc,dDate,cPeriode,&xcNB1,;
            lDlg, ;
            lVnaTag, ;
            SetPreview(), ;
            PAR->IdMfc, ;
            &xcAkte, cMontMin, lSimulate, aNafSim ;
          )
          if n < 0
            lOkay := .f.
          else
            nNew += n
            n := 0
          endif
          // if n is 0, loop stops without error
          // Ich weiss nicht mehr, weshalb hier ein Loop auf dem Partner
          // ist, solange es was zu fakturieren gibt... Muss irgendeinen
          // historischen Grund haben... 20070112
        endif
      enddo
    endif
    if ! lOkay
      nErr += 1
      lOkay := Confirm(SetMsg(),MsgContinue())
    endif
    skip
  enddo
close area
SetMsg(;
  ntrim(nNew)+utr(" documents"," Dokumente"," documents")+iif(nErr==0,;
    ".",;
    " ("+ntrim(nErr)+utr(" errors"," Fehler"," erreurs")+").";
  ))
RETURN .f. if ! lOkay
if lSimulate
  NafSimReport(aNafSim,cTitle1,cTitle2,cTitle3)
  *open area oPar()
  *  browse array aNafSim using {|x| ;
  *    iif(empty(x[2]).or.x[1]==x[2], ;
  *      padr(ParName(x[1]),50),;
  *      padr(trim1(ParName(x[2]))+"("+trim(ParName(x[1]))+")",50))+;
  *    +" "+ntom(x[NSIM_MONT]);
  *    } width 61 actions { ;
  *      { K_ENTER, {|x|NafSimDetail(x)} } ;
  *    } ;
  *    title (trim1(cTitle1)+trim1(cTitle2)+cTitle3)
  *close area
  *if lastkey() != K_ESC
  *  NafSimReport(aNafSim,cTitle1,cTitle2,cTitle3)
  *endif
endif
RETURN .t.

STATIC FUNCTION NafSimDetail(a)
browse array a[NSIM_AVNA] ;
  using {|x| ;
    padr(x[NAF_NB1],50)+x[NAF_PRIXU]+x[NAF_HTVA] ;
  } ;
  width 70 ;
  title (trim(ParName(a[1])))
RETURN NIL

STATIC FUNCTION NafSimReport(aNafSim,cTitle1,cTitle2,cTitle3)
local i, j, a, c
local lFirstPar := .t.
open printer SetTplIni() width 82 ;
     preview SetPreview() ;
     range   SetRange() ;
     titblock {|| ;
       PrintHeader(cTitle1,cTitle2,cTitle3) ;
     }
open area oPar()
  for i := 1 to len(aNafSim)
    if lFirstPar ; lFirstPar := .f. ; else ; PrintLine() ; endif
    c := trim(ParName(aNafSim[i][NSIM_PAR2]))
    if aNafSim[i][NSIM_PAR1] != aNafSim[i][NSIM_PAR2]
      c += " (" + trim(ParName(aNafSim[i][NSIM_PAR1])) + ")"
    endif
    PrintLine(c + " :")
    for j := 1 to len(aNafSim[i][NSIM_AVNA])
      a := aNafSim[i][NSIM_AVNA][j]
      PrintLine("  "+padr(a[NAF_NB1],60)+a[NAF_PRIXU]+a[NAF_HTVA])
    next j
  next i
close area
close printer
RETURN NIL








/*
NafExec() ist der Nachfolger von ParVnaAuto
*/

FUNCTION NafExec( ;
  bCollect,;
  cIdPar1, ;
  cIdJnl, ;
  dDate, ;
  cDlg, ;
  cNB1, ;
  lVnaTag, ;
  cIdMfc, ;
  cIdPar2, ;
  cIdPar3 ;
)
local n
local ifc
local cPeriode
local jnl := JnlLocate(cIdJnl)
RETURN !SetMsg(cIdJnl+MsgJnlExist()) if jnl == NIL
if empty(cIdPar2) ; cIdPar2 := cIdPar1 ; endif
if empty(cIdPar3) ; cIdPar3 := cIdPar2 ; endif
cPeriode := PerActive(dDate)
*if (cPeriode := PerActive(dDate)) == NIL
*  Warning(dtoc(dDate) + " : keine Periode aktiv !")
*  RETURN .f.
*endif
if cIdMfc == NIL
  cIdMfc := DbfPeek(oPar(),cIdPar1,"ParMfcDefault('+cIdJnl+')",NIL)
  RETURN !MsgParExist(cIdPar1) if cIdMfc == NIL
endif
if (ifc := IfcLocate(jnl[JNL_IDCTR],jnl[JNL_IDJNL],cIdMfc)) == NIL
  Warning( ;
    jnl[JNL_IDJNL] + " & " + cIdMfc + MsgIfcFail(), ;
    NIL, "WRN024" ;
  )
  RETURN .f.
endif
n := ParVenAppend( ;
  eval(bCollect,cIdPar1,jnl,ifc), ;
  cIdPar2, ;
  jnl, ;
  ifc, ;
  dDate, ;
  cPeriode, ;
  cNB1, ;
  cDlg==BUTTON_ON, ;
  lVnaTag, ;
  SetPreview(), ;
  cIdMfc, cIdPar3, "", .f. ;
)
RETURN .t. if n > 0
RETURN .f.

FUNCTION ArtVenAppend()
local lOkay
local aVna := {}
local cIdPar
local jnl
local bCollect := {||aVna}
jnl := PickJnl()
RETURN .f. if jnl == NIL
NafCollect(aVna,;
  "",;
  "",;
  "",;
  UserDate(),;
  ART->IdArt,;
  LNCODE_ART,;
  "",;
  "",;
  "",;
  "",;
  .t.,;
  ART->QTEFORM,;
  "",;
  "",;
  "",;
  "",;
  jnl[JNL_DC],;
  .t.,;
  "",;
  "",;
  NIL;
)
cIdPar := PickPar()
RETURN .f. if cIdPar == NIL
open area oVen()
  lOkay := NafExec(bCollect,cIdPar,jnl[JNL_IDJNL],UserDate(),BUTTON_ON,"",.t.)
close area
RETURN lOkay




**
** Die OnCreate-Events wurden bis zum 19990226 vor dem
** Erstellen des Inhalts ausgefhrt. Jetzt erst nachher. Bei
** EH wird in der VKLINIT.ACT n„mlich VEN->Skonto und
** VEN->Remise gesetzt und dann VenRemValidate() gerufen. Wenn
** dann der Inhalt noch nicht existiert, dann stimmen die
** Gesamtbetr„ge ja nicht. Bei EH ist IFCATTR_F gesetzt.
** 19990311
** Bei HK wird allerdings bei OnCreate die VenCarry() gerufen, und
** dann muss der Record gelockt sein.
FUNCTION ParVenAppend( ;
  aVna,cIdPar1,jnl,ifc,dDate,cPeriode,cNB1,;
  lDlg, lVnaTag, ;
  cPreview, ;
  cIdMfc, cIdPar2, cMontMin, lSimulate, aNafSim ;
)
local aCtp := {}
local aCtg := {}
local aHsi := {}
local cDC
local nSum := 0
local i
local cMatch := NIL
local nMont
RETURN -1 if aVna == NIL
if len(aVna) == 0
  * SetMsg(trim(ParName()) + MsgVna07() + jnl[JNL_IDJNL])
  SetMsg(MsgVna07())
  RETURN 0
endif
* 20070507 RETURN 0 if ! PreVenAuto(jnl[JNL_IDJNL])
RETURN -1 if ! PreVenAuto(jnl[JNL_IDJNL])
default lVnaTag to ! IFCATTR_X $ ifc[IFC_ATTRIB]
if lVnaTag .and. ! lSimulate
  RETURN 0 if ! VnaTag( ;
    aVna, cIdPar1, trim(ParName())+" : "+MsgVnaTag(jnl[JNL_IDJNL]),jnl[JNL_IDJNL] ;
  )
endif
** Jetzt gucken wir uns zuerst mal die Fakturierungsvorschl„ge an.
** uns interessiert : (a) die Summe und (b) ob alle sich auf das gleiche
** Dokument beziehen.
for i := 1 to len(aVna)
  if aVna[i][NAF_TAGGED]
    if aVna[i][NAF_EDIT]
      lDlg := .t.
    endif
    if aVna[i][NAF_HTVA] != NIL
      nMont := val(aVna[i][NAF_HTVA])
    elseif aVna[i][NAF_TVAC] != NIL
      nMont := val(aVna[i][NAF_TVAC])
    else
      nMont := val(aVna[i][NAF_PRIXU]) * qton1(aVna[i][NAF_QTE])
    endif
    if aVna[i][NAF_DC] == jnl[JNL_DC]
      nSum += nMont
    else
      nSum -= nMont
    endif
    if cMatch == NIL
      cMatch := aVna[i][NAF_IDJNL]+aVna[i][NAF_IDDOC]
    elseif cMatch != aVna[i][NAF_IDJNL]+aVna[i][NAF_IDDOC]
      cMatch := ""
    endif
  endif
next i
if !empty(cMontMin)
  RETURN 0 if abs(nSum) < val(cMontMin)
endif
if lSimulate
  aadd(aNafSim, { cIdPar1, cIdPar2, nSum, aVna }) // NSIM_ALEN
  RETURN 1
endif
if nSum >= 0 .or. IFCATTR_N $ ifc[IFC_ATTRIB]
  cDC := jnl[JNL_DC]
else
  cDC  := DcInvert(jnl[JNL_DC])
  nSum := - nSum
endif
RETURN -1 if ! VenMake(cIdPar1,cIdPar2,jnl[JNL_IDJNL],lDlg,;
                       dDate,cNB1,cIdMfc,jnl,ifc,aVna,cDC,cPeriode,cMatch,NIL,cPreview)
RETURN 1




*open area oPar()
*  seek cIdPar
*  if eof()
*    SetMsg(MsgParExist(cIdPar1))
*  else
*    nMade := ParVenAppend({},PAR->IdPar,jnl,ifc,UserDate())
*  endif
*close area




FUNCTION VenMake(cIdPar1,cIdPar2,cIdJnl,;
                 lDlg,dDate,cNB1,;
                 cIdMfc,jnl,ifc,aVna,cDC,cPeriode,cMatch,;
                 blOnCreate,cPreview)
local lOkay := .f.
local a
local b := oVen()
local nRecNo
local cIdDoc
if jnl == NIL
  if empty(cIdJnl)
    default cIdJnl to ""
    jnl := PickJnl(JNLALIAS_VEN,cIdJnl,NIL,;
           utrp("Create document...",;
                "Dokument erstellen...",;
                "Cr‚er un document..."))
  else
    jnl := JnlLocate(cIdJnl)
  endif
  RETURN .f. if jnl == NIL
endif
if ifc == NIL
  default cIdMfc to ParMfcDefault(jnl[JNL_IDJNL])
  if (ifc := IfcLocate(jnl[JNL_IDCTR],jnl[JNL_IDJNL],cIdMfc)) == NIL
    SetMsg(jnl[JNL_IDJNL] + " & " + cIdMfc + MsgIfcFail())
    RETURN -1
  endif
endif
default aVna to {}
default dDate to UserDate()
default cDC to jnl[JNL_DC]
default cPeriode to PerActive(dDate)
default lDlg to .t.
if IFCATTR_B $ ifc[IFC_ATTRIB]
  default cMatch to ""
else
  cMatch := ""
endif
open area b, oPar(), oPlz(), oNat(), oPrj()
  open area oJnl()
    seek jnl[JNL_IDJNL]
    if ddRecLock()
      cIdDoc := JnlNextIdDoc(JNL->SeqType,JNL->IdDoc,cPeriode)
      * 20040203 cIdDoc := NextNum(JNL->IdDoc,left(cPeriode,LEN_YEAR))
      if CheckIdDoc(jnl,cIdDoc,cPeriode)
        select VEN
        seek jnl[JNL_IDJNL] + cIdDoc
        if ! eof()
          SetMsg(jnl[JNL_IDJNL] + " " + cIdDoc + MsgDocExist())
        elseif dbAddRec()
          nRecNo := recno()
          JNL->IdDoc := cIdDoc
          VEN->IdJnl   := jnl[JNL_IDJNL]
          VEN->IdDoc   := cIdDoc
          VEN->Etat    := DocStatNew()
          VEN->IdPar   := cIdPar1
          if cIdPar2 != NIL
            VEN->IdPar2  := cIdPar2
          endif
          VEN->Date    := dDate
          VEN->Periode := cPeriode
          VEN->DC      := cDC
          if empty(PAR->IdDev)
            VEN->IdDev   := DevDefault(cPeriode)
          else
            VEN->IdDev   := PAR->IdDev
          endif
          VEN->Cours   := DocDevCours(VEN->IdDev,cPeriode)
          if cNB1 != NIL
            VEN->NB1     := cNB1
          endif
          #ifdef DEF_TAX
            VEN->IdReg   := PAR->IdReg
          #endif
          VEN->Auteur  := UserId() // "AUTO"
          #ifdef DEF_HST
            VEN->Match   := cMatch
          #endif
          VEN->Attrib  := jnl[JNL_DOCATTR]
          VenParValidate(jnl,ifc,.f.,cIdMfc)
          // 19990226 :
          // bei EH mssen die VenParValidate-Events auch bei
          // Automatikfakturierung ausgefhrt werden, wegen der Anzahl
          // Rechnungskopien. Also hier nicht nur VenMfcValidate(),
          // sondern VenParValidate()
          // VenMfcValidate(jnl,ifc,.f.)  raus 19990226
          // 19990517 :
          // Aber bei PAC darf die ZahlArt S2, die in VnaAuto() forciert
          // wird, nicht wieder durch die Zahlart aus PAR->IdMfc
          // berschrieben werden
          //
          // 20000504 :
          DoEvents(b[AD_ONCREATE],"ParVenAppend.OnCreate")
          if blOnCreate != NIL
            eval(blOnCreate)
          endif
          // die kamen vorher erst sp„ter
          if (a := VenVnlInit(jnl)) == NIL
            SetMsg(MsgIdJnlDoc() + " : " + SetMsg())
          else
            lOkay := .t.
            if ! VenVnlGenerate(aVna,jnl,ifc,VEN->DC)
              SetMsg(MsgIdJnlDoc() + " : " + SetMsg())
              lOkay := .f.
            elseif ! IFCATTR_U $ ifc[IFC_ATTRIB]
              if ! VenVnlReset(VNLRESET_PU)
                SetMsg(MsgIdJnlDoc() + " : " + SetMsg())
                lOkay := .f.
              endif
            endif
            VEN->Etat    := iif(len(aVna)==0,DocStatNew(),DocStatOpen())
            // ... denn sonst wrde TIM
            // nochmal die Fakturierungsvorschl„ge anzeigen...
            if lOkay .and. ! lDlg
              lOkay := .f.
              // 20000504
              // DoEvents(b[AD_ONCREATE],"ParVenAppend.OnCreate")
              // die werden jetzt weiter oben ausgefhrt, weil bei
              // EH auch VEN->IdReg aus einem VKA nach VKL und VKR
              // bernommen werden muss.
              if VenVnlUpdate(jnl)
                VEN->Etat := DocStatOpen()
                if PerSetDirty(jnl,VEN->Periode,VEN->Date,VEN->IdDoc)
                  if VenDoClose(jnl,ifc,.f.,cPreview)
                    lOkay := .t.
                  endif
                endif
              endif
            endif
            VnlRestore(a)
          endif
          if recno() != nRecNo
            raise("recno() changed during ParVenAppend().")
          endif
          dbcommit()
          unlock record
        endif
        select JNL
        dbcommit()
      endif
      unlock record
    endif
  close area
  if lOkay .and. lDlg
    * if len(aVna) == 0 .or. IFCATTR_F $ ifc[IFC_ATTRIB]
    if IFCATTR_F $ ifc[IFC_ATTRIB]
      ddSendKey(K_F3)
    else
      ddSendKey(K_ENTER)
    endif
    edit data b ;
         key VEN->IdJnl + VEN->IdDoc ;
         value jnl[JNL_IDJNL] + cIdDoc ;
         create   {||DDCREATE_FAIL} ;
         query ("VEN"+jnl[JNL_IDDBV]) ;
         mode edit  ;
         full noskip ;
         title (MsgVnaAuto() + " : " + jnl[JNL_IDJNL] +  " " + cIdDoc)
    if VEN->Etat == DocStatClosed()
      lOkay := .t.
    else
      SetMsg(MsgIdJnlDoc()+MsgNotClosed())
      lOkay := .f.
    endif
  endif
close area
RETURN lOkay


**
** generiert FIELD-Records anhand von VNA-array
**
FUNCTION VenVnlGenerate(aVna,jnl,ifc,cDC)
local cIdDev1
local cLine
local i
local lOkay := .f.
local cMatch := NIL
local doc
local cText
local naf  
local cIdJnl := VEN->IdJnl
local cIdDoc := VEN->IdDoc
local b := oVnl(VEN->Etat)
local aMemos := {}
open area b, oArt(), oGen(), oSpc(), oVen(), oVna(), oDls()
  lOkay := .t.
  KeyGoBottom(cIdJnl + cIdDoc, "FIELD->IdJnl+FIELD->IdDoc" )
  cLine := NextNum(FIELD->Line)
  for i := 1 to len(aVna)
    naf := aVna[i]
    if naf[NAF_TAGGED]
      if !empty(naf[NAF_IDDOC])
        if cMatch != naf[NAF_IDJNL] + naf[NAF_IDDOC]
          cIdDev1 := NIL
          **
          ** Leere R-Zeile zwischen verschiedenen Match
          **
          if IFCATTR_R $ ifc[IFC_ATTRIB] .and. cMatch != NIL
            if dbAddRec()
              FIELD->IdJnl := cIdJnl
              FIELD->IdDoc := cIdDoc
              FIELD->Line  := cLine
              FIELD->Code  := LNCODE_REMARQ
              cLine := NextNum(FIELD->Line)
              * dbcommit()
              unlock record
            else
              lOkay := .f.
              exit
            endif
          endif
          **
          ** R-Zeile mit Verweis auf Match-Dokument
          **
          if IFCATTR_D $ ifc[IFC_ATTRIB]
            if (doc := DocInfo(naf[NAF_IDJNL],naf[NAF_IDDOC])) != NIL
              if dbAddRec()
                FIELD->IdJnl := cIdJnl
                FIELD->IdDoc := cIdDoc
                FIELD->Line  := cLine
                FIELD->Code  := LNCODE_REMARQ
                FIELD->Desig := DocHeader( ;
                  doc, naf[NAF_IDJNL],naf[NAF_IDDOC], ;
                  PAR->Langue ;
                )
                if !empty(doc[DOC_MEMO])
                  aadd(aMemos,trimcr(doc[DOC_MEMO]))
                endif
                cLine := NextNum(FIELD->Line)
                * dbcommit()
                unlock record
              else
                lOkay := .f.
                exit
              endif
              if ! empty(doc[DOC_LIBELL])
                if dbAddRec()
                  FIELD->IdJnl := cIdJnl
                  FIELD->IdDoc := cIdDoc
                  FIELD->Line  := cLine
                  FIELD->Code  := LNCODE_ART
                  FIELD->IdArt := "*"
                  FIELD->Desig := doc[DOC_LIBELL]
                  * VnlTaxValidate()
                  * VnlPostEdit()
                  #ifdef DEF_TAX
                  VnlTaxReset()
                  #endif DEF_TAX
                  cLine := NextNum(FIELD->Line)
                  * dbcommit()
                  unlock record
                else
                  lOkay := .f.
                  exit
                endif
              endif
              cIdDev1 := doc[DOC_IDDEV]
            endif
          endif
          if ! empty(ifc[IFC_TEXT])
            seek naf[NAF_IDJNL] + naf[NAF_IDDOC] in VEN
            cIdDev1 := VEN->IdDev
            cText  := xparse(ifc[IFC_TEXT])
            if ! empty(cText)
              if dbAddRec()
                FIELD->IdJnl := cIdJnl
                FIELD->IdDoc := cIdDoc
                FIELD->Line  := cLine
                FIELD->Code  := LNCODE_REMARQ
                FIELD->Memo  := cText
                cLine := NextNum(FIELD->Line)
                unlock record
              else
                lOkay := .f.
                exit
              endif
            endif
            if !empty(VEN->Memo)
              aadd(aMemos,trimcr(VEN->Memo))
            endif
          endif
          if cIdDev1 == NIL
            seek naf[NAF_IDJNL] + naf[NAF_IDDOC] in VEN
            if !eof() in VEN
              *SetMsg(naf[NAF_IDJNL] + naf[NAF_IDDOC];
              *  + " : no such document";
              *)
              *lOkay := .f.
            * else
              cIdDev1 := VEN->IdDev
            endif
          endif
        endif
        cMatch := naf[NAF_IDJNL] + naf[NAF_IDDOC]
      else
        cMatch := NIL
      endif
      if dbAddRec()
        FIELD->IdJnl := cIdJnl
        FIELD->IdDoc := cIdDoc
        FIELD->Line  := cLine
        FIELD->Code  := naf[NAF_CODE]
        FIELD->IdArt := naf[NAF_IDART]
        if naf[NAF_DC] == cDC
          FIELD->Qte   := naf[NAF_QTE]
        else
          FIELD->Qte   := ntoq( ;
                          - qton(naf[NAF_QTE]) , ;
                          naf[NAF_QTEFORM] ;
                        )
        endif
        FIELD->Desig := naf[NAF_NB1]
        if ! empty(naf[NAF_MEMO])
          FIELD->Memo  := naf[NAF_MEMO]
        endif

        #ifdef DEF_VNLDATE
          if ! empty(naf[NAF_DATE])
            FIELD->Date  := naf[NAF_DATE]
          endif
        #endif
*
        #ifdef DEF_VNA
          if !empty(naf[NAF_LINE])
            FIELD->Match := naf[NAF_IDJNL]+naf[NAF_IDDOC]+naf[NAF_LINE]
          endif
        #endif
*
        #ifdef DEF_PROVI
          FIELD->PrixL := naf[NAF_PRIXL]
        #endif DEF_PROVI
        #ifdef DEF_VNLATTR
          FIELD->Attrib := naf[NAF_ATTRIB]
        #endif DEF_VNLATTR
        #ifdef DEF_INT
          FIELD->IdInt   := naf[NAF_IDINT]
          FIELD->QteStat := naf[NAF_QTESTAT]
        #endif DEF_INT
        if naf[NAF_UPDATE]
          if ! VnlIdValidate()
            lOkay := .f.
          endif
        elseif naf[NAF_HTVA] != NIL .or. naf[NAF_TVAC] != NIL
          #ifdef DEF_TAX
            if VnlFirstCheck(jnl[JNL_IDCTR])
              VnlSetIdTax()
            else
              lOkay := .f.
              // raise("VnlFirstCheck() failed")
            endif
          #endif DEF_TAX
          FIELD->PrixU := naf[NAF_PRIXU]
          if naf[NAF_TVAC] == NIL  // 20061109 if empty(naf[NAF_TVAC])
            FIELD->cMont := naf[NAF_HTVA]
            #ifdef DEF_TAX
              FIELD->MontT := naf[NAF_MTVA]
            #endif
          else
            GsbVnlTvac(naf[NAF_TVAC])
          endif
        else
          FIELD->PrixU := naf[NAF_PRIXU]
          #ifdef DEF_TAX // 20060801
            if VnlTaxReset() // ruft ja auch VnlFirstCheck()...!
              if FIELD->Code == LNCODE_TOTAL
                VnlTotValidate()
              elseif FIELD->Code == LNCODE_MODULE
                VnlModUpdate()
              else
                VnlSetBase()
              endif
            else
              lOkay := .f.
            endif
          #endif DEF_TAX
        endif
        // AD_ONPOSTEDIT nur wenn NAF_AFTER nicht angegeben:
        // bei Nols kriegen Rabatt-Zeilen sonst trotzdem im
        // AD_ONPOSTEDIT die Plaque des Kunden hingesetzt.
        if naf[NAF_AFTER] == NIL
          if ! DoEvents(b[AD_ONPOSTEDIT]).or.!DoEvents(b[AD_ONTEST])
            lOkay := .f.
          endif
        else
          if ! xparse(naf[NAF_AFTER])
            lOkay:= .f.
          endif
        endif
        ** Falls W„hrungswechsel zwischen Auftrag und Rechnung:
        seek cIdJnl + cIdDoc in VEN
        if cIdDev1 != NIL .and. VEN->IdDev != cIdDev1
          FIELD->PrixU := ntom(;
            VenDev2Mont(cIdDev1,val(VNL->PrixU)),VnlPuDecPos();
          )
          #ifdef DEF_PROVI
            FIELD->PrixL := ntom(;
              VenDev2Mont(cIdDev1,val(VNL->PrixL)),VnlPuDecPos();
            )
          #endif DEF_PROVI
          VnlSetBase()
        endif
*
        VnlAfter()
        cLine := NextNum(FIELD->Line)
        // 20060803 : bei Nols werden Zischensummen generiert, und diese
        // Zeilen mssen hier gefllt werden
        if VNL->Code == LNCODE_TOTAL
          VnlTotValidate()
        endif
        * dbcommit()
        unlock record
      else
        lOkay := .f.
        exit
      endif
    endif
  next i
  dbcommit()
close area
if empty(VEN->Memo) .and. len(aMemos) > 0
  if !empty(cText := VnaVenMemo(aMemos))
    VEN->Memo := cText
  endif
endif
RETURN lOkay

FUNCTION NafCollect(aVna,;
  NA_IDJNL,;
  NA_IDDOC,;
  NA_LINE,;
  NA_DATE,;
  NA_IDART,;
  NA_CODE,;
  NA_QTE,;
  NA_NB1,;
  NA_MEMO,;
  NA_PRIXU,;
  NA_TAGGED,;
  NA_QTEFORM,;
  NA_QTESTAT,;
  NA_IDINT,;
  NA_PRIXL,;
  NA_ATTRIB,;
  NA_DC,;
  NA_UPDATE,;
  cHTVA,;
  cMTVA,;
  xlAfter,;
  cTVAC,;
  lEdit;
)
local a := array(NAF_ALEN)
default lEdit to .f.
a[NAF_IDJNL]   :=  NA_IDJNL
a[NAF_IDDOC]   :=  NA_IDDOC
// a[NAF_MATCH]   :=  NA_MATCH
a[NAF_LINE]   :=  NA_LINE
a[NAF_DATE]    :=  NA_DATE
a[NAF_IDART]   :=  NA_IDART
a[NAF_CODE]    :=  NA_CODE
a[NAF_QTE]     :=  NA_QTE
a[NAF_NB1]     :=  NA_NB1
a[NAF_MEMO]    :=  NA_MEMO
a[NAF_PRIXU]   :=  NA_PRIXU
a[NAF_TAGGED]  :=  NA_TAGGED
a[NAF_QTEFORM] :=  NA_QTEFORM
a[NAF_QTESTAT] :=  NA_QTESTAT
a[NAF_IDINT]   :=  NA_IDINT
a[NAF_PRIXL]   :=  NA_PRIXL
a[NAF_ATTRIB]  :=  NA_ATTRIB
a[NAF_DC]      :=  NA_DC
a[NAF_UPDATE]  :=  NA_UPDATE
a[NAF_HTVA]    :=  cHTVA
a[NAF_MTVA]    :=  cMTVA
a[NAF_TVAC]    :=  cTVAC
a[NAF_AFTER]   :=  xlAfter
a[NAF_EDIT]    :=  lEdit
aadd(aVna,a)
RETURN .t.


#endif DEF_VEN


#ifdef DEF_INT
FUNCTION HasInt() ; RETURN .t.
#else
FUNCTION HasInt() ; RETURN .f.
#endif

#ifdef DEF_PROVI
FUNCTION HasProvi() ; RETURN .t.
#else
FUNCTION HasProvi() ; RETURN .f.
#endif
#ifdef DEF_VNLATTR
FUNCTION HasVnlAttr() ; RETURN .t.
#else
FUNCTION HasVnlAttr() ; RETURN .f.
#endif

