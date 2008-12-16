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

#define CARRY_FIELD 1
#define CARRY_VALUE 2
#define CARRY_ALEN  2


**
** STATIC_SECTION global static variables
**
static saJnl     := {}
static scIdJnl   := NIL
static scIdDoc   := NIL
* static scIdCtr   := NIL
static scIdArt   := NIL
static scPeriode := NIL
static scIdPar   := NIL
static scSatis   := NIL
static scFilter  := NIL

**
** MSG_SECTION    MSGnnn definitions
**
#ifdef LG_FRENCH
  static MSG_VNAPICK := " : recopier imputations"
#else
  static MSG_VNAPICK   := " : Buchungen bernehmen"
#endif

**
** PROCEDURE_SECTION  - (...grins)
**


#ifdef DEF_VNA

static snCdlSum  := 0
* static slCdlEdit := .f.
static snCdlCount := 0

**
** ArtVnaEdit() -
**
FUNCTION ArtVnaEdit(cIdArt)
local b := oVna()
open area b, oPar(), oArt()
  ddSetOrder(ORD_VNA_ARTDATE)
  edit data b key VNA->IdArt ;
    value    cIdArt        ;
    start    bottom                 ;
    mode     find  ;
    query ("VNAARTD") ;
    filter "empty(VNA->Satis)" ;
    title ("Fakturierungsvorschl„ge " + trim(SayIdArt(cIdArt)))
close area
RETURN .t.

*FUNCTION VenHasVnaUs()
*local lFound := .f.
*open area oVna()
*  softseek VEN->IdJnl+VEN->IdDoc
*  do while !eof().and.VNA->IdJnl+VNA->IdDoc==VEN->IdJnl+VEN->IdDoc
*    if empty(VNA->Satis)
*      lFound := .t.
*      exit
*    endif
*    skip
*  enddo
*close area
*RETURN lFound

**
**
FUNCTION ParVnaEdit( ;
  cIdPar,cTitle,xlFilter,xuReturn ;
)
local b := oVna()
local uReturn := .t.
open area b, oPar(), oArt(), oVen()
  default xlFilter to "empty(VNA->Satis)"
  default cTitle to MsgVnaTag() + " " + trim(ParName(cIdPar))
  ddSetOrder(ORD_VNA_PARDATE)
  edit data b key VNA->IdPar ;
    value    cIdPar          ;
    start    bottom          ;
    mode     find            ;
    query ("VNAPARD")        ;
    filter xlFilter ;
    title (cTitle)
  if xuReturn != NIL // .and. ddLastKey() == K_F10
    uReturn := xparse(xuReturn)
    * ParDlgVnaAuto(cIdPar,xlVnaFilter,cNB1,dDate,cDlg,cPreview,cIdMfc)
  endif
close area
SetMnuDone()
RETURN uReturn

**
** JnlVnaEdit() -
**
FUNCTION JnlVnaEdit(cTitle)
local cIdJnl := NIL // PickJnl("VEN",NIL)
local b := oVna()
* local aJnl := JnlList({|jnl|JnlVnaExist(jnl)})
do while (cIdJnl := PickIdJnl("VEN",cIdJnl,NIL,cTitle,"VNAJNL")) != NIL
  open area b, oPar(), oArt(), oVen()
    ddSetOrder(ORD_VNA_ID)
    edit data b key VNA->IdJnl ;
      value    cIdJnl             ;
      start    bottom                 ;
      mode     find  ;
      filter   "empty(VNA->Satis)" ;
      query ("VNAJNL") ;
      title (cTitle + " : " + cIdJnl)
  close area
enddo
RETURN .f.

FUNCTION GsbVnaDebit(x)
RETURN space(LenMont()) if VNA->DC == DC_CREDIT
RETURN ntom(val(VNA->PrixU) * qton(VNA->Qte))
   
FUNCTION GsbVnaCredit(x)
RETURN space(LenMont()) if VNA->DC == DC_DEBIT
RETURN ntom(val(VNA->PrixU) * qton(VNA->Qte))



FUNCTION PickVnlMatch()
RETURN NIL if !IsArtCode(VNL->Code)
RETURN DbfPick({oVna(),oPar(),oArt()},;
  "S‚lection r‚f‚rence de suite " + alltrim(VNL->IdArt)+"/"+VNL->IdJnl+"/"+VEN->IdPar,;
  "VNAPICK",trim(VNL->Match),;
  "empty(VNA->Satis).and.VNA->IdPar=='"+VEN->IdPar+"'.and.VnaTrnLocate(JnlLocate('"+VNL->IdJnl+"'))!=NIL",;
  left(VNL->IdArt,LenIdArt()),"VNA->IdArt")


FUNCTION VenPickVnaMatch()
local i
local aKeys := {}
local aRecnos := {}
local jnl := JnlLocate(VEN->IdJnl)
DbfScan({oVna(),oVen()},ORD_VNA_PARDATE,;
  VEN->IdPar,"VNA->IdPar=='"+VEN->IdPar+"'",;
  {||empty(VNA->Satis).and.VnaTrnLocate(jnl)!=NIL},;
  {||DictAddItem(aKeys,VNA->IdJnl+VNA->IdDoc),.t.})
open area oVen()
  for i := 1 to len(aKeys)
    seek aKeys[i]
    if !eof()
      aadd(aRecnos,recno())
    endif
  next i
close area
RETURN DbfPick({oVen(),oPar(),oPlz(),oNat()},;
  "S‚lection r‚f‚rence de suite","VENPARD",;
  trim(VEN->VnaMatch),NIL,NIL,NIL,"VEN->VnaMatch",NIL,aRecnos)

*FUNCTION   VenVenEdit() ... todo
*local i
*local aKeys := {}
*local aRecnos := {}
*local jnl := JnlLocate(VEN->IdJnl)
*DbfScan({oVna(),oVen()},ORD_VNA_PARDATE,;
*  VEN->IdPar,"VNA->IdPar=='"+VEN->IdPar+"'",;
*  {||empty(VNA->Satis).and.VnaTrnLocate(jnl)!=NIL},;
*  {||DictAddItem(aKeys,VNA->IdJnl+VNA->IdDoc),.t.})
*open area oVen()
*  for i := 1 to len(aKeys)
*    seek aKeys[i]
*    if !eof()
*      aadd(aRecnos,recno())
*    endif
*  next i
*close area
*RETURN DbfPick({oVen(),oPar(),oPlz(),oNat()},;
*  "S‚lection r‚f‚rence de suite","VENPARD",;
*  trim(VEN->VnaMatch),NIL,NIL,NIL,"VEN->VnaMatch",NIL,aRecnos)

FUNCTION VnlVnlEdit()
local a
local b := oVnl()
local i
local aKeys := {}
local aRecnos := {}
vnlkeycoll(aKeys,{||VNL->IdJnl+VNL->IdDoc+VNL->Line})
open area b
  for i := 1 to len(aKeys)
    seek aKeys[i]
    if !eof()
      aadd(aRecnos,recno())
    endif
  next i
close area
RETURN !Warning("No entries found for VnlVnlEdit()") if len(aKeys) == 0
RETURN .f. if (a := ArtVnlInit()) == NIL
open area b, oArt(), oVen(), oPar()
  edit data b recnos aRecnos ;
              start    top                          ;
              mode     show                            ;
              query    "VNLVNL" ;
              title ("VnlVnlEdit")
close area
VnlRestore(a)
RETURN .t.

FUNCTION VenVenList()
local i
local aKeys := {}
local aRecnos := {}
if ! empty(VEN->IdJnl)
  open area oVnl()
    softseek VEN->IdJnl+VEN->IdDoc
    do while !eof() .and. VNL->IdJnl+VNL->IdDoc == VEN->IdJnl+VEN->IdDoc
      vnlkeycoll(aKeys,{||VNL->IdJnl+VNL->IdDoc})
      skip
    enddo
  close area
  open area oVen()
    for i := 1 to len(aKeys)
      seek aKeys[i]
      if !eof()
        aadd(aRecnos,{;
          dtos(VEN->Date)+JnlSeq(VEN->IdJnl),; // 1
          recno(),;                            // 2
          VEN->IdJnl+VEN->IdDoc;               // 3
        })
      endif
    next i
  close area
  asort(aRecnos,NIL,NIL,{|a,b|a[1]<=b[1]})
endif
RETURN aRecnos

FUNCTION VenVenLast()
local aRecnos := VenVenList()
RETURN space(LenIdJnl()) if len(aRecnos)==0
RETURN space(LenIdJnl()) if len(aRecnos)==1.and.aRecnos[1][2]==recno()
RETURN left(atail(aRecnos)[3],LenIdJnl())

FUNCTION VenVenEdit()
local i
local aRecnos := VenVenList()
RETURN !SetMsg("Il n'existe aucun document li‚ … "+MsgIdJnlDoc()) if len(aRecnos) == 0
for i := 1 to len(aRecnos)
  aRecnos[i] := aRecnos[i][2]
next i
open area oVen(), oPar(), oPlz(), oNat()
  edit data oVen() recnos aRecnos ;
              start    top                       ;
              mode     show                      ;
              query    "VENVEN" ;
              title (MsgIdJnlDoc()+" "+MnuItemName())
close area
RETURN .t.

FUNCTION VenVenWait(wwin)
local i
local aRecnos := VenVenList()
for i := 1 to len(aRecnos)
  aRecnos[i] := aRecnos[i][2]
next i
open area oVen(), oPar(), oPlz(), oNat()
  edit data oVen() recnos aRecnos ;
              start    top                       ;
              mode     wait                      ;
              query    "VENVEN" ;
              title (MsgIdJnlDoc()+" : documents li‚s") ;
              window wwin
close area
RETURN .t.

* sammelt alle anderen VNLs, die (rckw„rts oder vorw„rts)
* mit dieser VNL verbunden sind, in aKeys ein
/*
examples:
- SRV -> VNA -> NCV
- 
*/
STATIC FUNCTION vnlkeycoll(aKeys,bKey)
// local a := {}
// local cMatch 
open area oVnl()
  // go back to the root
  do while !eof().and.!empty(VNL->Match);
           .and.VNL->Match!=VNL->IdJnl+VNL->IdDoc+VNL->Line
    seek VNL->Match
  enddo
  // cMatch := VNL->IdJnl+VNL->IdDoc+VNL->Line
  ddSetOrder(ORD_VNL_VNA)
  do while !eof() .and.VNL->Match!=VNL->IdJnl+VNL->IdDoc+VNL->Line
    DictAddItem(aKeys,eval(bKey))
    seek VNL->IdJnl+VNL->IdDoc+VNL->Line
  enddo
close area
* SetMsg(ntrim(len(aKeys))+" entries.")
RETURN .t.
* STATIC FUNCTION vnlkeycoll(aKeys,bKey)
* open area oVnl()
*   do while !eof().and.!empty(VNL->Match)
*     seek VNL->Match
*   enddo
*   ddSetOrder(ORD_VNL_VNA)
*   do while !eof()
*     DictAddItem(aKeys,eval(bKey))
*     seek VNL->IdJnl+VNL->IdDoc+VNL->Line
*   enddo
* close area
* SetMsg(ntrim(len(aKeys))+" entries.")
* RETURN .t.



**
FUNCTION PickVna(cIdArt,cIdJnl,cIdPar,bReturn)
local b := oVna()
local cMatch := NIL
local cIdJnlFrom
default bReturn to {|| VNA->IdJnl + VNA->IdDoc + VNA->Line}
open area b
  if ! empty(cIdArt)
    ** siehe 20060824
    * ddSetOrder(ORD_VNA_ARTDATE)
    edit data b key   VNA->IdArt;
                value cIdArt ;
                mode pick ;
                query "VNAARTD" ;
                start top ;
                title (trim(SayIdArt(cIdArt)) + MSG_VNAPICK)
    *** ddSetOrder ORD_VNA_ARTDATE
    **edit data b key   VNA->IdArt + VNA->IdJnl;
    **            value cIdArt+cIdJnl ;
    **            mode pick ;
    **            query "VNAARTD" ;
    **            start top ;
    **            title (trim(SayIdArt(cIdArt)) + MSG_VNAPICK)
  elseif ! empty(cIdJnl)
    ddSetOrder(ORD_VNA_ID)
    edit data b key   VNA->IdJnl ;
                value cIdJnl ;
                mode pick ;
                query ("VNAJNL") ;
                start top ;
                title (cIdJnl + MSG_VNAPICK)
  elseif ! empty(cIdPar)
    ddSetOrder(ORD_VNA_PARDATE)
    edit data b key   VNA->IdPar ;
                value cIdPar ;
                mode pick ;
                query ("VNAPARD") ;
                start top ;
                title (cIdPar + MSG_VNAPICK)
  else
    Warning( ;
      "Weder Artikel noch Journal noch Partner sind bekannt.",;
      "Wie will ich da was anzeigen...")
  endif
  if ddLastReq() == DDEDIT_SELECT
    cMatch := eval(bReturn)
  endif
close area
RETURN cMatch


**
** VnaAuto() - Automatik-Fakturierung
**
FUNCTION VnaAuto(cVnaTag,cDlg,cNB1,cIdJnl1,xlParFilter,cIdMfc)
local jnl
* local aVenCarry := {}
local aJnl := JnlList({|j|JnlTrnExist(j)})
local xlVnaFilter
static cIdPar1 := NIL
static cIdPar2 := NIL
static dDate := NIL
* default cConfirm to BUTTON_ON
default cDlg     to BUTTON_OFF
default cVnaTag  to BUTTON_OFF
if len(aJnl) == 1
  jnl := aJnl[1]
else
  RETURN .f. if (jnl := PickJnl("VEN",NIL,aJnl)) == NIL
endif
default dDate to UserDate()
default cIdJnl1 to space(LenIdJnl())
default cIdPar1 to space(LenIdPar())
default cIdPar2 to space(LenIdPar())
default cNB1 to space(30)
cNB1 := padr(cNB1,30)
open window (MsgVnaAuto() + " : " + jnl[JNL_IDJNL]) ;
            size 10,50 help VNAAUTO
say MsgParVon() // "Partner von "
get cIdPar1 picture PIC_ID ;
            pick PickPar(CtrPrtList(jnl[JNL_IDCTR]),cIdPar1) ;
            postedit {|x|GetIdPar(x)}
say MsgBis() // " bis "
get cIdPar2 picture PIC_ID ;
            pick PickPar(CtrPrtList(jnl[JNL_IDCTR]),cIdPar2) ;
            postedit {|x|GetIdPar(x)}
WinCr()
say MsgVna06() // "Ausschlieálich Vorschl„ge aus Journal "
get cIdJnl1 picture PIC_ID pick PickIdJnl("VEN",cIdJnl1)
WinCr()
say MsgVna05() // "Dokumente datiert auf "
get dDate
WinCr()
say MsgVna04() // "Mindestbetrag "
get MemVnaMont GET_DECPOS(DevDecPos(DevDefault(PerActive())))
WinCr()
say MsgVna03() // "Bemerkung "
get cNB1
* WinCr()
* get cConfirm checkbox
* say MsgVna02() // " fr jeden Partner einzeln best„tigen"
WinCr()
get cVnaTag checkbox
#ifdef LG_GERMAN
say " Vorschl„ge einzeln best„tigen"
#else
say " confirmer avant de cr‚er chaque facture"
#endif
WinCr()
get cDlg checkbox
say MsgVna01() // " erstellte Dokumente bearbeiten"
WinCr()
GetPreview()
* get cPreview checkbox
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
AppSaveMem()
if empty(cIdJnl1)
  xlVnaFilter := ".t."
else
  xlVnaFilter := "VNA->IdJnl=='" + cIdJnl1 + "'"
endif
RETURN DoVnaAuto( ;
  jnl[JNL_IDJNL], ;
  dDate, ;
  xlParFilter, ;
  xlVnaFilter, ;
  cIdMfc, ;
  cDlg==BUTTON_ON, ;
  cVnaTag==BUTTON_ON, ;
  cNB1, ;
  cIdPar1,cIdPar2 ;
)


**
**
FUNCTION DoVnaAuto( ;
  cIdJnl, ;
  dDate, ;
  xlParFilter, ;
  xlVnaFilter, ;
  cIdMfc, ;
  lDlg, ;
  lVnaTag, ;
  cNB1, ;
  cIdPar1,cIdPar2, ;
  xlStdVnaFilter ;
)
local cIdMfcCheck
local cPeriode
local aVna
local lOkay := .t.
local nCount := 0
local jnl := JnlLocate(cIdJnl)
local ifc
local n
local nErr := 0
local nNew := 0
default dDate to UserDate()
default xlVnaFilter to ".t."
default xlParFilter to "!'" + PARATTR_A +"'$PAR->Attrib"
default cIdPar1 to space(LenIdPar())
default cIdPar2 to space(LenIdPar())
default cNB1 to space(30)
default lDlg to .f.
default lDlg to .f.
if jnl == NIL
  SetMsg(cIdJnl + MsgJnlExist())
  RETURN .f.
endif
if (cPeriode := PerActive(dDate)) == NIL
  SetMsg("Keine Periode aktiv am "+ dtoc(dDate)+" !")
  RETURN .f.
endif
open area oPar(), oArt()
  softseek trim(cIdPar1)
  do while lOkay .and. ! eof()
    MsgDisplay(trim(ParName()) + "...")
    MsgDisp2(ntrim0(++nCount * 100 / lastrec()) + "%" )
    if TaskInter() ; exit ; endif
    if ! empty(cIdPar2)
      if PAR->IdPar > cIdPar2
        exit
      endif
    endif
    if &(xlParFilter)
      n := 1
      do while lOkay .and. n > 0
        aVna := VnaSuggest(PAR->IdPar,jnl,dDate,xlVnaFilter,xlStdVnaFilter)
        if cIdMfc == NIL
          cIdMfcCheck := PAR->IdMfc
        else
          cIdMfcCheck := cIdMfc
        endif
        if (ifc := IfcLocate(jnl[JNL_IDCTR],jnl[JNL_IDJNL],cIdMfcCheck)) == NIL
          SetMsg( ;
            PAR->IdPar + " : " + ;
            jnl[JNL_IDJNL] + " & " + PAR->IdMfc + MsgIfcFail(), ;
          )
          lOkay := .f.
        else
          n := ParVenAppend( ;
            aVna,PAR->IdPar,jnl,ifc,dDate,cPeriode,cNB1,;
            lDlg, ;
            lVnaTag, ;
            SetPreview(), ;
            cIdMfcCheck, ;
            NIL, MemVnaMont, .f. ;
          )
          if n < 0
            lOkay := .f.
          else
            nNew += n
          endif
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
RETURN SetMsg(;
  ntrim(nNew)+utr(" documents","Dokumente"," documents")+iif(nErr==0,;
    ".",;
    " ("+ntrim(nErr)+utr(" errors"," Fehler"," erreurs")+").";
  ))

FUNCTION MsgParVon()
#ifdef LG_GERMAN
RETURN "Partner von "
#else
RETURN "Compte particulier de "
#endif

FUNCTION MsgBis()
#ifdef LG_GERMAN
RETURN " bis "
#else
RETURN " … "
#endif

FUNCTION MsgVna01()
#ifdef LG_GERMAN
RETURN " erstellte Dokumente bearbeiten"
#else
RETURN " modifier chaque document g‚n‚r‚"
#endif

* FUNCTION MsgVna02()
* #ifdef LG_GERMAN
* RETURN " fr jeden Partner einzeln best„tigen"
* #else
* RETURN " confirmation pour chaque particulier"
* #endif

FUNCTION MsgVna03()
#ifdef LG_GERMAN
RETURN "Bemerkung "
#else
RETURN "Remarque "
#endif

FUNCTION MsgVna04()
#ifdef LG_GERMAN
RETURN "Mindestbetrag "
#else
RETURN "Montant minimum "
#endif

FUNCTION MsgVna05()
#ifdef LG_GERMAN
RETURN "Dokumente datiert auf "
#else
RETURN "Dokuments dat‚s au "
#endif

FUNCTION MsgVna06()
#ifdef LG_GERMAN
RETURN "Ausschlieálich Vorschl„ge aus Journal "
#else
RETURN "Uniquement propositions de journal "
#endif

**
** ParDlgVnaAuto() - Automatik-Fakturierung
**
FUNCTION ParDlgVnaAuto(cIdPar,xlVnaFilter,cNB1,dDate,cDlg,cIdMfc)
local jnl
local aJnl := JnlList({|j|JnlTrnExist(j)})
RETURN NIL if ! ParExist(cIdPar)
if len(aJnl) == 1
  jnl := aJnl[1]
else
  RETURN NIL if (jnl := PickJnl("VEN",NIL,aJnl)) == NIL
endif
default dDate to UserDate()
default cNB1 to space(30)
default cDlg to BUTTON_ON
open window (MsgVnaAuto() + " : " + jnl[JNL_IDJNL]) ;
            size 8,50 help VNAAUTO
say "Partner : " + ParName()
WinCr()
say MsgVna05() // "Dokument(e) datiert auf "
get dDate
WinCr()
say MsgVna04() // "Mindestbetrag "
get MemVnaMont GET_MONTANT
WinCr()
say MsgVna03() // "Bemerkung "
get cNB1
WinCr()
get cDlg checkbox
say MsgVna01() // " erstellte Dokumente bearbeiten"
WinCr()
GetPreview() // " Seitenvorschau"
nKey := ReadScr()
close window
RETURN NIL if nKey == K_ESC
AppSaveMem()
RETURN ParVnaAuto( ;
  cIdPar,jnl[JNL_IDJNL],dDate,xlVnaFilter,cDlg,cNB1,NIL,cIdMfc ;
)


**
** ParVnaAuto()
**
FUNCTION ParVnaAuto( ;
  cIdPar1, ;
  cIdJnl, ;
  dDate, ;
  xlVnaFilter, ;
  cDlg, ;
  cNB1, ;
  lVnaTag, ;
  cIdMfc, ;
  cIdPar2, ;
  cIdPar3, ;
  xlStdVnaFilter ;
)
RETURN NafExec( {|p,j,i| ;
    VnaSuggest(p,j,dDate,xlVnaFilter,xlStdVnaFilter);
  }, ;
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

FUNCTION OnVenVnaParent(cIdJnl,xlOnParent)
/**
 Fhrt xlOnParent aus auf dem ersten Bestellschein (Dokument im Journal
 cIdJnl), der in diesem Dokument befriedigt wird. Kontrolliert nicht, ob
 mehrere Bestellscheine befriedigt werden.

**/
local cIdDoc
local lOkay := .f.
open area oVnl()
  lOkay := .t.
  softseek VEN->IdJnl+VEN->IdDoc
  do while !eof().and.VNL->IdJnl+VNL->IdDoc==VEN->IdJnl+VEN->IdDoc
    if ! empty(VNL->Match)
      cIdDoc := DbfPeek(oVnl(),VNL->Match,{||VnlParent(cIdJnl)},NIL)
      if cIdDoc != NIL
        lOkay := DbfPeek(oVen(),cIdDoc,xlOnParent,.f.)
        exit
      endif
    endif
    skip
  enddo
close area
RETURN lOkay

FUNCTION VnaParent(cIdJnl)
local c := DbfPeek(oVnl(),VNA->IdJnl+VNA->IdDoc+VNA->Line,;
  {||VnlParent(cIdJnl)},NIL)
RETURN space(LenIdJnl()+LenIdDoc()) if c == NIL
RETURN c

FUNCTION VnlParent(cIdJnl)
RETURN left(VNL->Match,LenIdJnl()+LenIdDoc()) ;
  if left(VNL->Match,LenIdJnl()) == cIdJnl
RETURN NIL if empty(VNL->Match)
RETURN DbfPeek(oVnl(),VNL->Match,{||VnlParent(cIdJnl)},NIL)

**
** Vorschlagsliste von offenen VNA pro Partner und Jnl
** cIdPar : der Partner, fr den vorgeschlagen werden soll
** jnl    : das Journal, fr das vorgeschlagen werden soll
**
FUNCTION VnaSuggest(cIdPar,jnl,dDate,xlVnaFilter,xlStdVnaFilter,cVnaMatch)
local a
local aVna := {}
local nCount := 0
local trn
* local cVnaMatch := NIL
local cDocMatch := NIL
local nQte
default xlStdVnaFilter to "empty(VNA->Satis)"
* bis 20061006:
* default xlStdVnaFilter to ;
*   "empty(VNA->Satis).and.dtos(VNA->Date)<='"+dtos(dDate)+"'"
open area oVna(), oVen()
  ddSetOrder(ORD_VNA_PARDATE)
  softseek cIdPar
  do while ! eof() .and. VNA->IdPar == cIdPar
    nCount := 0
    ** [19990324] cMatch := left(VNA->Match,LenIdJnl()+LEN_IDDOC)
    cDocMatch := VNA->IdJnl + VNA->IdDoc
    seek VNA->IdJnl + VNA->IdDoc in VEN
    do while ! eof() .and. VNA->IdPar == cIdPar ;
                     .and. VNA->IdJnl + VNA->IdDoc == cDocMatch
      if &xlStdVnaFilter
        if &xlVnaFilter
          if (trn := VnaTrnLocate(jnl)) != NIL
            if ! TRNATTR_M $ trn[TRN_ATTRIB]
              if ! VENATTR_A $ VEN->Attrib
                if VnaCollSug(aVna,dDate,trn,@cVnaMatch)
                  nCount++
                endif
              endif
            endif
          endif
        endif
      endif
      skip
    enddo
    if nCount > 0
      ** OnVnaSuggest() setzt bei EH gewisse Variablen, die sp„ter
      ** im generierten Dokument gesetzt werden. VEN->Frais etc...
      OnVnaSuggest()
      if ParVnaStop(jnl)
      * if PARATTR_S $ PAR->Attrib .and. JnlDoHst(jnl)
        ** PARATTR_S unterdrckt Sammel*rechnungen*, nicht
        ** Sammel-Lieferscheine !
        exit
      endif
    endif
  enddo
close area
*#ifdef DEF_DLS
*RETURN NIL if ! ParDls2Naf(aVna,jnl,NIL,dDate,.t.,"!DlsHasVnl()",;
*  "trim1(DlaName())+dtoc(DLS->Date)+' '+trim(UsrName(DLS->IdUsr))",;
*  "DLS->NB+crlf()+DLS->Memo","DLS->Dauer","''","''",".t.",NIL)
*#endif DEF_DLS
*#ifdef DEF_ABO
*  open area oVna()
*    ddSetOrder ORD_VNA_PARDATE
*    if nCount > 0 .and. AboParFilter()
*      softseek space(LenIdPar())
*      do while ! eof() .and. empty(VNA->IdPar)
*        if AboVnaFilter()
*          if (trn := VnaTrnLocate(jnl)) != NIL
*            if VnaCollSug(aVna,trn)
*              nCount++
*            endif
*          endif
*        endif
*        skip
*      enddo
*    endif
*  close area
*#endif DEF_ABO
RETURN aVna

/******************
Der while-loop in VnaSuggest() :
[960924] wie kam ich bloá darauf, auf den Match zu testen ?
endless loop bei PARATTR_S und Lieferschein, der aus Auftrag
bernommen war... oder so...
19990324 : bei EH haben alle Kunden standardm„áig PARATTR_S gesetzt.
Um mehrere Auftr„ge miteinander zu verbinden (damit sie gemeinsam
fakturiert werden), wird VEN->VnaMatch benutzt. Damit das
funktioniert, muss ich natrlich auf den Match und nicht auf
VNA->IdJnl+IdDoc schauen.
Ich weiá nicht mehr, warum die andere Methode eingebaut wurde.
Vielleicht, weil dann das "seek VNA->IdJnl + VNA->IdDoc in VEN" auf
jedem einzelnen Record gemacht werden muss?
Nein, nein, nein. Das ist Quatsch. Bei EH muss OnVnaSuggest() auf
*jedem* einzelnen VKL, der in die Rechnung kommt, ausgefhrt werden.
Also muss der Loop pro Dokument und nicht pro Match gehen. PARATTR_S
ist bei EH nicht n”tig, weil xlVnaFilter die
Buchungsvorschl„ge immer auf einen einzigen Auftragsmatch beschr„nkt.
PARATTR_S darf also *nicht* gesetzt sein. PARATTR_S wird glaube ich
sowieso nicht mehr benutzt.

19990730 : xlStdVnaFilter : dieser neue Parameter ist zwar eigentlich
doppelt gemoppelt (sollte besser in xlVnaFilter stehen), aber ich habe
keine Lust, bei allen bestehenden Installationen die Bedingung vom Datum
und Satis in deren xlVnaFilter hinzuzufgen. EH sind die ersten, die
aufs Datum *nicht* testen wollen, und nur deshalb muss bei ihnen der
Defaultwert auf "empty(VNA->Satis)" gesetzt werden.

1999112 : Wenn zwei Auftr„ge vom gleichen Kunden hintereinander erfasst
waren, dann wurde OnVnaSuggest f„lschlicherweise auch dann auf dem
zweiten Auftrag ausgefhrt, wenn die xlVnaFilter kein einziger VNA
dieses Dokuments in den Lieferschein bernommen wurde. Weil nCount nicht
auf 0 zurckgesetzt wurde.

**************/


#ifdef DEF_ACF

FUNCTION ParAcfAuto( ;
  cIdPar, ;
  cIdJnl, ;
  dDate, ;
  lTagged ;
)
RETURN NafExec( {|p,j,i| ;
    ParAcfCollect(p,j,dDate,lTagged);
  }, ;
  cIdPar, ;
  cIdJnl, ;
  dDate, ;
  "X", ;
  NIL, ;
  .t. ;
)

FUNCTION ParAcfCollect(cIdPar,jnl,dDate,lTagged)
local lOkay := .f.
local aNaf := {}
local nQte
default lTagged to .t.
open area oAcf(), oArt()
  lOkay := .t.
  ddSetOrder(ORD_ACF_PAR)
  softseek PAR->IdPar
  do while lOkay.and.!eof().and.ACF->IdPar==PAR->IdPar
    seek ACF->IdArt in ART
    nQte := qton(ART->StkMin)-qton(ART->Lager)-qton(ART->Bestellt)+qton(ART->Auftrag)
    if nQte > 0
      NafCollect(aNaf,;
        "",;
        "",;
        "",;
        NIL,;
        ACF->IdArt,;
        LNCODE_ART,;
        ntoq(nQte,ART->QteForm),;
        "",;
        "",;
        ACF->Prix,;
        lTagged,;
        ART->QteForm,;
        if(HasInt(),ART->QteStat,NIL),; // #ifdef DEF_INT
        if(HasInt(),ART->IdInt,NIL),;   // #ifdef DEF_INT
        NIL,;   // #ifdef DEF_PROVI
        "",;  // #ifdef DEF_VNLATTR
        jnl[JNL_DC],;
        .t.;
      )
    endif
    skip
  enddo
close area
// RETURN {} if ! lOkay
RETURN aNaf


#endif DEF_ACF



*#ifdef DEF_CARRY
*
*STATIC FUNCTION CarryCollect(aCarry,cFields)
*local i,j
*local c
*local xuValue
*local aFields
**local aValues := {}
*RETURN NIL if empty(cFields)
*aFields := ListAsArray(cFields,",")
**for i := 1 to len(aFields)
** if (nPos := at(":=",aFields[i])) != 0
**   aadd(aValues,substr(aFields[i],nPos+2)
**   aFields[i] := left(aFields[i],nPos-1)
** else
**   aadd(aValues,aFields[i])
** endif
**next i
*for i := 1 to len(aFields)
*  c := NIL
*  for j := 1 to len(aCarry)
*    if aCarry[j][CARRY_FIELD] == aFields[i]
*      c := aCarry[j]
*      exit
*    endif
*  next j
*  if c == NIL
*    c := array(CARRY_ALEN)
*    c[CARRY_FIELD] := aFields[i]
*    c[CARRY_VALUE] := &(aFields[i])
*    aadd(aCarry,c)
*  endif
*next i
*RETURN NIL
*
*FUNCTION CarryPaste(aCarry)
*local i
*for i := 1 to len(aCarry)
*  &(alias() + "->" + aCarry[i][CARRY_FIELD]) := aCarry[i][CARRY_VALUE]
*next i
*aCarry := {}
*RETURN NIL
*
*
*#endif DEF_CARRY

STATIC FUNCTION VnaCollSug(aNaf,dDate,trn,cVnaMatch)
local c
RETURN .f. if VEN->DatEch > dDate .and. !TRNATTR_D $ trn[TRN_ATTRIB]
if TRNATTR_1 $ trn[TRN_ATTRIB]
  c := VnaMatch()
  if cVnaMatch == NIL
    cVnaMatch := c
  elseif cVnaMatch != c
    RETURN .f.
  endif
endif
* RETURN .f. if ! PreVnaSuggest(dDate)
* if !empty(trn[TRN_BLFILTER])
*   RETURN .f. if ! eval(trn[TRN_XLFILTER],dDate)
* endif
RETURN NafCollect(aNaf,;
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
  if(HasInt(),VNA->QteStat,NIL),; // #ifdef DEF_INT
  if(HasInt(),VNA->IdInt,NIL),;   // #ifdef DEF_INT
  if(HasProvi(),VNA->PrixL,NIL),;   // #ifdef DEF_PROVI
  if(HasVnlAttr(),VNA->Attrib,NIL),;  // #ifdef DEF_VNLATTR
  if(TRNATTR_I $ trn[TRN_ATTRIB],DcInvert(VNA->DC),VNA->DC),;
  TRNATTR_U $ trn[TRN_ATTRIB],;
  NIL,NIL,NIL,NIL,;
  VnaMustEdit();
)






* **
* ** ParVnaAuto()
* **
* FUNCTION ParVnaAuto( ;
*   cIdPar1, ;
*   cIdJnl, ;
*   dDate, ;
*   xlVnaFilter, ;
*   cDlg, ;
*   cNB1, ;
*   lVnaTag, ;
*   cIdMfc, ;
*   cIdPar2, ;
*   cIdPar3, ;
*   xlStdVnaFilter ;
* )
* local aVna
* local ifc
* local cPeriode
* local jnl := JnlLocate(cIdJnl)
* RETURN !SetMsg(cIdJnl+MsgJnlExist()) if jnl == NIL
* RETURN .f. if ! ParExist(cIdPar1)
* if empty(cIdPar2) ; cIdPar2 := cIdPar1 ; endif
* if empty(cIdPar3) ; cIdPar3 := cIdPar2 ; endif
* if (cPeriode := PerActive(dDate)) == NIL
*   Warning(dtoc(dDate) + " : keine Periode aktiv !")
*   RETURN .f.
* endif
* * default cIdMfc to PAR->IdMfc
* default cIdMfc to ParMfcDefault(cIdJnl)
* if (ifc := IfcLocate(jnl[JNL_IDCTR],jnl[JNL_IDJNL],cIdMfc)) == NIL
*   Warning( ;
*     jnl[JNL_IDJNL] + " & " + cIdMfc + MsgIfcFail(), ;
*     NIL, "WRN024" ;
*   )
*   RETURN .f.
* endif
* default lVnaTag to ! IFCATTR_X $ ifc[IFC_ATTRIB]
* aVna := VnaSuggest(cIdPar1,jnl,dDate,xlVnaFilter,xlStdVnaFilter)
* if len(aVna) == 0
*   Warning( ;
*     trim(ParName()) + MsgVna07() ;
*     + jnl[JNL_IDJNL], NIL, "WRN025" ;
*   )
*   RETURN .f.
* endif
* if ! ParVenAppend( ;
*   aVna, ;
*   cIdPar2, ;
*   jnl, ;
*   ifc, ;
*   dDate, ;
*   cPeriode, ;
*   cNB1, ;
*   cDlg==BUTTON_ON, ;
*   lVnaTag, ;
*   SetPreview(), ;
*   cIdMfc, cIdPar3 ;
* )
*   RETURN ! Warning(SetMsg())
* endif
* RETURN .t.

*STATIC FUNCTION aVnaSum(aVna,jnl)
*local i
*local nSum := 0
*for i := 1 to len(aVna)
*  if aVna[i][VNA_DC] == jnl[JNL_DC]
*    nSum += val(aVna[i][VNA_PRIXU]) * qton1(aVna[i][VNA_QTEUS])
*  else
*    nSum -= val(aVna[i][VNA_PRIXU]) * qton1(aVna[i][VNA_QTEUS])
*  endif
*next i
*RETURN nSum

* FUNCTION HasVna ; RETURN .t.

#else

FUNCTION PickVna ; RETURN NIL

* FUNCTION HasVna ; RETURN .f.

#endif DEF_VNA

#ifdef DEF_PRESTO

*FUNCTION TrmVnaCreate(jnl,cIdDoc)
*local lOkay := DDCREATE_FAIL
*open area oVna()
*  if dbAddRec()
*    VNA->IdJnl     := jnl[JNL_IDJNL]
*    VNA->IdDoc     := cIdDoc
*    VNA->IdPar     := TRM->IdPar
*    VNA->Periode   := PerActive()
*    VNA->NB1       := TRM->Debut + "-" + TRM->Fin
*    VNA->Code      := LNCODE_ART
*    VNA->Memo      := ""
*    VNA->Satis     := ""
*    VNA->Date      := TRM->Date
*    VNA->DC        := jnl[JNL_DC]
*    VNA->IdArt     := TRM->IdArt
*    VNA->Match     := jnl[JNL_IDJNL] + cIdDoc
*    VNA->PrixU     := ART->Prix1
*    VNA->Qte       := TRM->Duree
*    VNA->QteUs     := TRM->Duree
*    lOkay := DDCREATE_DONE
*    unlock record
*  endif
*close area
** if lOkay == DDCREATE_DONE
**   TRM->Match := jnl[JNL_IDJNL] + cIdDoc
** endif
*RETURN lOkay

#endif DEF_PRESTO





#ifdef DEF_VEN

**
**
FUNCTION VenAppend( ;
  cIdJnl,cTitle,dDate, ;
  cMatch,xlVnlFilter, ;
  cIdPar, cIdPar2, ;
  lInvert, lVnlReset, lCopy, lTaxReset, cNB1, xlOkay ;
)
local a
local cIdDoc
local cIdDoc1 := VEN->IdDoc
local cIdJnl1 := VEN->IdJnl
local cDC1 := VEN->DC
* local aVnaMatch := {}
local lOkay := .f.
local b := oVen()
local i
local aVenBuf
local aVnlBuf := {}
local jnl := JnlLocate(cIdJnl)
default lCopy to .t.
default xlOkay to ".t."
default xlVnlFilter to ".t."
* default lInvert to .f.
default lVnlReset to .f.
default lTaxReset to .f.
if cTitle != NIL
  RETURN .f. if ! Confirm( ;
    cTitle, ;
    MsgSure() ;
  )
endif
RETURN .f. if jnl == NIL
if lCopy
  aVenBuf := CopyRec("VEN")
endif
default dDate to UserDate()
if lInvert == NIL
  lInvert := (jnl[JNL_DC] != VEN->DC)
endif
if lCopy
  open area oVnl(VEN->Etat), oArt(), oGen()
    softseek VEN->IdJnl+VEN->IdDoc
    do while ! eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                     .and. FIELD->IdJnl == VEN->IdJnl
      if &xlVnlFilter
        aadd(aVnlBuf,CopyRec())
        * #ifdef DEF_VNA
        * aadd(aVnaMatch,VnlVnaMatch())
        * #endif DEF_VNA
      endif
      skip
    enddo
  close area
endif
open area b, oPar(), oPlz(), oNat()
  KeyGoBottom( cIdJnl, "VEN->IdJnl")
  if eof() .or. VEN->Etat == DocStatClosed()
    lOkay := .t.
  else
    lOkay := Confirm( ;
      MsgPrevDoc() + MsgNotClosed(), ;
      MsgContinue(), MSG_NO, "WRN007" ;
    )
  endif
  if lOkay
    lOkay := .f.
    open area oJnl()
      seek cIdJnl
      if ddRecLock()
        cIdDoc := NextNum(JNL->IdDoc,left(PerActive(),LEN_YEAR))
        select VEN
        seek cIdJnl + cIdDoc
        if ! eof()
          Warning( ;
            jnl[JNL_IDJNL] + " " + cIdDoc + MsgDocExist(), ;
            NIL, "WRN014" ;
          )
        elseif dbAddRec()
          JNL->IdDoc := cIdDoc
          if lCopy
            PasteRec(aVenBuf)
          else
            VEN->DC := jnl[JNL_DC]
          endif
          VEN->IdJnl   := cIdJnl
          VEN->IdDoc   := cIdDoc
          VEN->Etat    := DocStatNew()
          VEN->Date    := dDate
          VEN->Periode := PerActive(dDate)
          VEN->Attrib  := jnl[JNL_DOCATTR]
          if cNB1 != NIL
            VEN->NB1 := cNB1
          endif
          if lInvert
            VEN->DC := DcInvert(VEN->DC)
          endif
          if cMatch  != NIL ; VEN->Match  := cMatch  ; endif
          * 20040130 bei agv w„re folgendes logischer:
          * if cIdPar  != NIL
          *   VEN->IdPar  := cIdPar
          * endif
          * if !empty(VEN->IdPar)
          *   if lVnlReset
          *     VenParValidate(jnl,NIL,.f.,VEN->IdMfc)
          *   else
          *     VenParValidate(jnl,NIL,.f.)
          *   endif
          * endif
          * aber ich lass den alten Code und l”se bei AGV mit OnCreate
          if cIdPar  != NIL
            VEN->IdPar  := cIdPar
            if !lCopy
              VenParValidate(jnl,NIL,.f.)
            elseif lVnlReset
              VenParValidate(jnl,NIL,.f.,VEN->IdMfc)
            endif
          endif
          if cIdPar2 != NIL ; VEN->IdPar2 := cIdPar2 ; endif
          DoEvents(b[AD_ONCREATE],"VenAppend")
          if lCopy
            if lVnlReset.or.lTaxReset
              if (a := VenVnlInit(jnl)) == NIL
                Warning(MsgIdJnldoc()+" : "+SetMsg())
              endif
            endif
            open area oVnl(DocStatNew()),oArt(),oGen(), oVna()
              lOkay := .t.
              for i := 1 to len(aVnlBuf)
                if dbAddRec()
                  PasteRec(aVnlBuf[i])
                  #ifdef DEF_VNA
                    * FIELD->Match := aVnaMatch[i]
                    if TrnLocate(jnl,cIdJnl1,cDC1) == NIL
                      FIELD->Match := ""
                    else
                      FIELD->Match := VNL->IdJnl+VNL->IdDoc+VNL->Line
                    endif
                  #endif DEF_VNA
                  FIELD->IdJnl := cIdJnl
                  FIELD->IdDoc := cIdDoc
                  if lVnlReset
                    **** begin 20010502
                    if ! VnlIdValidate()
                      lOkay := .f.
                      exit
                    endif
                    * FIELD->PrixU := ""
                    * FIELD->cMont := ""
                    * FIELD->MontT := ""
                    * VnlReset(VNLRESET_PU+VNLRESET_TAX)
                    **** end 20010502
                  endif
                  if lTaxReset
                    FIELD->MontT := ""
                    FIELD->IdTax := ""
                    VnlReset(VNLRESET_TAX)
                  endif
                  unlock record
                else
                  lOkay := .f.
                  exit
                endif
              next i
            close area
            if a != NIL
              VnlRestore(a)
            endif
          else
            lOkay := .t.
          endif
          if lOkay
            #ifdef DEF_HOLZ
              if ! VenStmAppend(cIdJnl1,cIdDoc1,cIdJnl,cIdDoc)
                Warning("Problem bei VenStmAppend()")
              endif
            #endif DEF_HOLZ
            default cTitle to jnl[JNL_IDJNL] +  " " + cIdDoc
            SendKey(K_ENTER)
            SendKey(K_ENTER)
            edit data b ;
              key VEN->IdJnl + VEN->IdDoc ;
              value jnl[JNL_IDJNL] + cIdDoc ;
              create   {||DDCREATE_FAIL} ;
              query ("VEN"+jnl[JNL_IDDBV]) ;
              mode edit  ;
              full noskip ;
              title (cTitle)
            dbcommit()
            lOkay := xparse(xlOkay)
          endif
          unlock record
        endif
        select JNL
        dbcommit()
        unlock record
      endif
    close area
  endif
close area
RETURN lOkay


#endif DEF_VEN

#ifdef DEF_FIN

**
**
FUNCTION FinAppend( ;
  cIdJnl,cTitle,dDate,cNB1, ;
  xlFnlFilter, ;
  lInvert, lCopy, xlOkay ;
)
local cIdDoc
local cIdDoc1 := FIN->IdDoc
local cIdJnl1 := FIN->IdJnl
local lOkay := .f.
local b := oFin()
local i
local aFinBuf
local aFnlBuf := {}
local jnl := JnlLocate(cIdJnl)
default lCopy to .t.
default lInvert to .f.
default xlOkay to ".t."
default xlFnlFilter to ".t."
if cTitle != NIL
  RETURN .f. if ! Confirm( ;
    cTitle, ;
    MsgSure() ;
  )
endif
RETURN .f. if jnl == NIL
if lCopy
  aFinBuf := CopyRec("FIN")
endif
default dDate to UserDate()
if lCopy
  open area oFnl(), oPar(), oGen()
    softseek FIN->IdJnl+FIN->IdDoc
    do while ! eof() .and. FIELD->IdDoc == FIN->IdDoc ;
                     .and. FIELD->IdJnl == FIN->IdJnl
      if &xlFnlFilter
        aadd(aFnlBuf,CopyRec())
      endif
      skip
    enddo
  close area
endif
open area b
  KeyGoBottom( cIdJnl, "FIN->IdJnl")
  if eof() .or. FIN->Etat == DocStatClosed()
    lOkay := .t.
  else
    lOkay := Confirm( ;
      MsgPrevDoc() + MsgNotClosed(), ;
      MsgContinue(), MSG_NO, "WRN007" ;
    )
  endif
  if lOkay
    lOkay := .f.
    open area oJnl()
      seek cIdJnl
      if ddRecLock()
        cIdDoc := NextNum(JNL->IdDoc,left(PerActive(),LEN_YEAR))
        select FIN
        seek cIdJnl + cIdDoc
        if ! eof()
          Warning( ;
            jnl[JNL_IDJNL] + " " + cIdDoc + MsgDocExist(), ;
            NIL, "WRN014" ;
          )
        elseif dbAddRec()
          JNL->IdDoc := cIdDoc
          if lCopy
            PasteRec(aFinBuf)
          endif
          FIN->IdJnl   := cIdJnl
          FIN->IdDoc   := cIdDoc
          FIN->Etat    := DocStatNew()
          FIN->Date    := dDate
          FIN->Periode := PerActive(dDate)
          if cNB1 != NIL
            FIN->Remarq := cNB1
          endif
          DoEvents(b[AD_ONCREATE],"VenAppend")
          if lCopy
            open area oFnl(),oPar(),oGen()
              lOkay := .t.
              for i := 1 to len(aFnlBuf)
                if dbAddRec()
                  PasteRec(aFnlBuf[i])
                  FIELD->IdJnl := cIdJnl
                  FIELD->IdDoc := cIdDoc
                  unlock record
                else
                  lOkay := .f.
                  exit
                endif
              next i
            close area
          else
            lOkay := .t.
          endif
          if lOkay
            default cTitle to jnl[JNL_IDJNL] +  " " + cIdDoc
            SendKey(K_ENTER)
            SendKey(K_ENTER)
            edit data b ;
              key FIN->IdJnl + FIN->IdDoc ;
              value jnl[JNL_IDJNL] + cIdDoc ;
              create   {||DDCREATE_FAIL} ;
              query ("FIN"+jnl[JNL_IDDBV]) ;
              mode edit  ;
              full noskip ;
              title (cTitle)
            dbcommit()
            lOkay := xparse(xlOkay)
          endif
          unlock record
        endif
        select JNL
        dbcommit()
        unlock record
      endif
    close area
  endif
close area
RETURN lOkay


#endif DEF_FIN






#ifdef DEF_HOLZ

FUNCTION VenStmAppend(cIdJnl1,cIdDoc1,cIdJnl2,cIdDoc2)
local nRecNo
local lOkay := .f.
open area oStm()
  lOkay := .t.
  ddSetOrder(StmOrder(cIdJnl1))
  softseek cIdDoc1
  do while ! eof() .and. &("STM->"+cIdJnl1+"IdDoc") == cIdDoc1
    skip
    nRecNo := recno()
    skip -1
    if ddRecLock()
      &("STM->"+cIdJnl2+"IdDoc") := cIdDoc2
      &("STM->"+cIdJnl2+"Line") := &("STM->"+cIdJnl1+"Line")
      unlock record
    else
      lOkay := .f.
    endif
    goto nRecNo
  enddo
close area
RETURN lOkay

#endif DEF_HOLZ


#ifdef CUST_NOLS

#define NF_IDART  1
#define NF_PRIXU  2
#define NF_QTE    3
#define NF_PLAQUE 4
#define NF_DATE   5
#define NF_IDJNL  6
#define NF_IDDOC  7
#define NF_COUNT  8
#define NF_HTVA   9
#define NF_MTVA  10
#define NF_REMISE 11
#define NF_IDTAX 12
#define NF_ALEN  12

#define NFR_IDART 1
#define NFR_HTVA  2
#define NFR_MTVA  3
#define NFR_ALEN  3



// collector for NafExec() at NOLS


FUNCTION NFSuggest(cIdPar,forjnl,ifc,dDate1,dDate2)
local cMatch
local aRem := {}
local cPlaque
local a
local i
local aNF := {}
local aVna := {}
local nCount
local trn
local tax
// local cMatch := NIL
local nQte, nHTVA, nMTVA
local lByDoc := "L" $ PAR->Attrib
local lByPlaque := "N" $ PAR->Attrib
local lByPrix := "P" $ PAR->Attrib
local lByDate := "D" $ PAR->Attrib
local lRemTotal := "R" $ PAR->Attrib
local cDesig
local nf
local xlAfter  
local cQte, cPrixU, ipr
local blVenFilter:={||VEN->IdJnl=="VKL".and.inrange(VEN->Date,dDate1,dDate2)}
local cIdDev := if(empty(PAR->IdDev),DevDefault(PerActive(dDate2)),PAR->IdDev)
local nDecPos := max(DevDecPos(cIdDev),forjnl[JNL_TAXDECPOS])
local xlVnlFilter := "IsArtCode(VNL->Code)"
local bAddTotal := {|cPlaque|NafCollect(aVna,;
  "", "", "",;
  NIL,;
  "=",;
  LNCODE_TOTAL,;
  "",;
  cPlaque,;
  "",; // VNL->Memo
  "",;
  .t.,;
  ART->QteForm,;
  "","","","",;
  forjnl[JNL_DC],;
  .f.,;
  "",;
  "",;
  "VnlTotRefresh()";
)}
local bAddRemise := {|cIdArt,nHtva,nMtva|NafCollect(aVna,;
  "", "", "",;
  NIL,;
  cIdArt,;
  LNCODE_ART,;
  "",;
  "Rabatt "+trim(ArtName(cIdArt)),;
  "",; // VNL->Memo
  "",;
  .t.,;
  ART->QteForm,;
  "","","","",;
  forjnl[JNL_DC],;
  .f.,;
  ntom(nHtva,nDecPos),;
  ntom(nMtva,nDecPos),;
  ".t.";
)}
open area oVen(), oVnl(), oArt()
  ddSetOrder(ORD_VEN_PAR)
  softseek cIdPar
  do while ! eof() .and. VEN->IdPar == cIdPar
    if eval(blVenFilter)
      nCount := 0
      cMatch := VEN->IdJnl + VEN->IdDoc
      select VNL
      softseek cMatch
      do while ! eof() .and. VNL->IdJnl + VNL->IdDoc == cMatch
        if &xlVnlFilter
          nHTVA := val(VNL->cMont)
          nMTVA := val(VNL->MontT)
          nQte := qton1(VNL->Qte)
          if VenIsNC()
            nHTVA := - nHTVA
            nMTVA := - nMTVA
            nQte := - nQte
          endif
          nf := NIL
          for i := 1 to len(aNF)
            if aNF[i][NF_IDTAX] == VNL->IdTax
              if !lByDoc .or. (;
                 aNF[i][NF_IDJNL] == VNL->IdJnl;
                 .and.aNF[i][NF_IDDOC] == VNL->IdDoc)
                if !lByPlaque .or. aNF[i][NF_PLAQUE] == VNL->Plaque
                  if !lByPrix .or. aNF[i][NF_PRIXU] == VNL->PrixU
                    if !lByDate .or. aNF[i][NF_DATE] == VEN->Date
                      if aNF[i][NF_IDART] ==  VNL->IdArt
                        *if aNF[i][NF_REMISE] == VNL->Rabatt
                          nf := aNF[i]
                        *endif
                      endif
                    endif
                  endif
                endif
              endif
            endif
          next i
          // confirm(utos(nf))
          if nf == NIL
            nf := array(NF_ALEN)
            nf[NF_IDART] := VNL->IdArt
            if lByDoc
              nf[NF_IDJNL] := VNL->IdJnl
              nf[NF_IDDOC] := VNL->IdDoc
            else
              nf[NF_IDJNL] := ""
              nf[NF_IDDOC] := ""
            endif
            if lByDate
              nf[NF_DATE] :=  VEN->Date
            endif
            if lByPlaque
              nf[NF_PLAQUE] :=  VNL->Plaque
            endif
            if lByPrix
              nf[NF_PRIXU] :=  VNL->PrixU
            endif
            nf[NF_REMISE] := qton1(VNL->Qte)*val(VNL->Rabatt)/100
            nf[NF_HTVA] := nHTVA
            nf[NF_MTVA] := nMTVA
            nf[NF_IDTAX] := VNL->IdTax
            nf[NF_QTE] := nQte
            nf[NF_COUNT] :=  1
            aadd(aNF,nf)
          else
            nf[NF_HTVA] += nHTVA
            nf[NF_MTVA] += nMTVA
            nf[NF_QTE] += nQte
            nf[NF_COUNT] +=  1
            nf[NF_REMISE] += qton1(VNL->Qte)*val(VNL->Rabatt)/100
          endif
        *else
        *  warning("vnlfilter failed: "+MsgIdJnlDoc()+":"+VNL->Line)
        endif
        skip
      enddo
      select VEN
    * else
    *   warning("venfilter failed: "+MsgIdJnlDoc())
    endif
    skip
  enddo
  *if len(aNF) > 0
  *  Confirm(VEN->IdJnl+VEN->IdDoc+":"+ntrim(len(aNF)))
  *endif
  * 20060209 ab hier
  ** vorher:
  ** if lByPlaque
  **   aNF := asort(aNF,NIL,NIL,{|a,b|a[NF_PLAQUE]<=b[NF_PLAQUE]})
  ** endif
  if lByDate
    if lByPlaque
      aNF := asort(aNF,NIL,NIL,{|a,b|;
        a[NF_PLAQUE]+dtos(a[NF_DATE])<=b[NF_PLAQUE]+dtos(b[NF_DATE])})
    else
      aNF := asort(aNF,NIL,NIL,{|a,b|a[NF_DATE]<=b[NF_DATE]})
    endif
  else
    if lByPlaque
      aNF := asort(aNF,NIL,NIL,{|a,b|a[NF_PLAQUE]<=b[NF_PLAQUE]})
    endif
  endif
  cPlaque := NIL
  * nRemise := 0
  * 20060209 bis hier
  for i := 1 to len(aNF)
    nf := aNF[i]
    if lByPlaque.and.cPlaque != nf[NF_PLAQUE]
      if cPlaque != NIL
        eval(bAddTotal,cPlaque)
      endif
      cPlaque := nf[NF_PLAQUE]
    endif
    seek (nf[NF_IDART]) in ART
    cDesig := ""
    if empty(nf[NF_IDDOC])
      cDesig := trim1(ArtName(NIL,PAR->Langue))
      if lByDate
        cDesig += dtoc(nf[NF_DATE]) + " "
      endif
      * if lByPlaque
      *   cDesig += trim1(nf[NF_PLAQUE])
      * endif
      if lByPrix
        cDesig += komma(ltrim(nf[NF_PRIXU]))
      endif
    endif
    if lByPrix
      cQte   := ntoq(nf[NF_QTE],ART->QteForm)
      cPrixU := nf[NF_PRIXU]
    else
      cQte := ""
      cPrixU := ""
      * cQte   := padl("1",LenQte())
      * ipr := IprLocate(;
      *   forjnl[JNL_IDCTR],PAR->IdPrt,PAR->IdPgp,;
      *   cIdDev,;
      * )
      * if ipr != NIL .and. IPRATTR_C $ ipr[IPR_ATTRIB]
      *   cPrixU := ntom(nf[NF_HTVA]+nf[NF_MTVA],2)
      * else
      *   cPrixU := ntom(nf[NF_HTVA],2)
      * endif
    endif
    if nf[NF_PLAQUE] == NIL
      xlAfter := ".t."
    else
      xlAfter := "(VNL->Plaque:='"+nf[NF_PLAQUE]+"')!=NIL"
    endif
    * 20060209 ab hier (einfach nur so...)
    if nf[NF_DATE] != NIL
      xlAfter += ".and.(VNL->Date:=stod('"+dtos(nf[NF_DATE])+"'))!=NIL"
    endif
    * 20060209  bis hier
    NafCollect(aVna,;
      nf[NF_IDJNL], nf[NF_IDDOC], "",;
      nf[NF_DATE],;
      nf[NF_IDART],;
      LNCODE_ART,;
      cQte,;
      cDesig,;
      "",; // VNL->Memo
      cPrixU,;
      .t.,;
      ART->QteForm,;
      "","","","",;
      forjnl[JNL_DC],;
      .f.,;
      ntom(nf[NF_HTVA],nDecPos),;
      ntom(nf[NF_MTVA],nDecPos),;
      xlAfter;
    )
    * if cPlaque == nf[NF_PLAQUE]
    *   nRemise += nf[NF_REMISE]
    * else
    * if abs(nRemise) > Tolerance(2)
    if abs(nf[NF_REMISE]) > Tolerance(2)
      tax := TaxLocate(forjnl[JNL_IDCTR],nf[NF_IDTAX],.t.,VEN->Date)
      * tax := TaxLocate(forjnl[JNL_IDCTR],VNL->IdTax,.t.,VEN->Date)
      // tax := TaxLocate(VnlIdCtr(),VNL->IdTax,.t.,VEN->Date)
      if tax == NIL
        Warning(SetMsg())
      else
        nHTVA := netto(nf[NF_REMISE],tax[TAX_TAUX])
        if lRemTotal // Rabatte zusammenfassen?
          RemCollect(aRem,nf[NF_IDART],-nHtva,nHtva-nf[NF_REMISE])
        else
          NafCollect(aVna,;
            nf[NF_IDJNL], nf[NF_IDDOC], "",;
            nf[NF_DATE],;
            nf[NF_IDART],;
            LNCODE_ART,;
            "",;
            "Rabatt",;
            "",; // VNL->Memo
            "",;
            .t.,;
            ART->QteForm,;
            "","","","",;
            forjnl[JNL_DC],;
            .f.,;
            ntom(-nHTVA,nDecPos),;
            ntom(nHTVA-nf[NF_REMISE],nDecPos),;
            ".t.";
          )
        endif
      endif
    endif
    nCount++
  next i
  if lByPlaque.and.cPlaque != NIL
    eval(bAddTotal,cPlaque)
  endif
  if len(aRem) > 0
    for i := 1 to len(aRem)
      eval(bAddRemise,;
        aRem[i][NFR_IDART],aRem[i][NFR_HTVA],aRem[i][NFR_MTVA])
    next i
  endif
close area
RETURN aVna

FUNCTION RemCollect(aRem,cIdArt,nHtva,nMtva)
local i,a
for i := 1 to len(aRem)
  if aRem[i][NFR_IDART] == cIdArt
    aRem[i][NFR_HTVA] += nHtva
    aRem[i][NFR_MTVA] += nMtva
    RETURN .t.
  endif
next i
a := array(NFR_ALEN)
a[NFR_IDART] := cIdArt
a[NFR_HTVA] := nHtva
a[NFR_MTVA] := nMtva
aadd(aRem,a)
RETURN .t.

#endif CUST_NOLS

#ifdef CUST_RUMMA

#define NF_IDART  1
#define NF_PRIXU  2
#define NF_QTE    3
// #define NF_PLAQUE 4
#define NF_DATE   5
#define NF_IDJNL  6
#define NF_IDDOC  7
#define NF_COUNT  8
#define NF_HTVA   9
#define NF_MTVA  10
// #define NF_REMISE 11
#define NF_ALEN  11

// collector for NafExec()
// fr Rumma & Ko


FUNCTION NFSuggest(cIdPar,forjnl,ifc,dDate1,dDate2)
local a
local i
local aNF := {}
local aVna := {}
local nCount
local trn
local tax
local cMatch := NIL
local nQte, nHTVA, nMTVA 
local lByDoc := .t.
local lByPlaque := "N" $ PAR->Attrib
local lByPrix := "P" $ PAR->Attrib
local lByDate := "D" $ PAR->Attrib
local cDesig
local nf
local xlAfter  
local cQte, cPrixU, ipr
local blVenFilter:={||VEN->IdJnl=="ALS".and.inrange(VEN->Date,dDate1,dDate2)}
local cIdDev := if(empty(PAR->IdDev),DevDefault(PerActive(dDate2)),PAR->IdDev)
local xlVnlFilter := ".t."
open area oVen(), oVnl(), oArt()
  ddSetOrder(ORD_VEN_PAR)
  softseek cIdPar
  do while ! eof() .and. VEN->IdPar == cIdPar
    if eval(blVenFilter)
      * NafCollect(aVna,;
      *  nf[NF_IDJNL], nf[NF_IDDOC],;
      *  cMatch,;
      *  nf[NF_DATE],;
      *  nf[NF_IDART],;
      *  LNCODE_ART,;
      *  cQte,;
      *  cDesig,;
      *  "",; // VNL->Memo
      *  cPrixU,;
      *  .t.,;
      *  ART->QteForm,;
      *  "","","","",;
      *  forjnl[JNL_DC],;
      *  .f.,;
      *  ntom(nf[NF_HTVA],DevDecPos(cIdDev)),;
      *  ntom(nf[NF_MTVA],DevDecPos(cIdDev)),;
      *)
      cMatch := VEN->IdJnl + VEN->IdDoc
      select VNL
      softseek cMatch
      do while ! eof() .and. VNL->IdJnl + VNL->IdDoc == cMatch
        if &xlVnlFilter
          NafCollect(aVna,;
            VEN->IdJnl, VEN->IdDoc, "",;
            NIL,;
            VNL->IdArt,;
            VNL->Code,;
            VNL->Qte,;
            VNL->Desig,;
            VNL->Memo,;
            VNL->PrixU,;
            .t.,;
            ART->QteForm,;
            "","","","",;
            forjnl[JNL_DC],;
            .f.,;
            VNL->cMont,;
            VNL->MontT;
          )
        endif
        skip
      enddo
      select VEN
    endif
    skip
  enddo
close area
RETURN aVna


#endif CUST_RUMMA


