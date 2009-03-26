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
#include "DEFDATA.CH"

* #ifdef DEF_VEN
*   static slQtePu   := .t.
* #endif

#ifdef LG_FRENCH
  #define MSG003      "~Masque d'impression  [Alt-F8]"
  #define MSG005      "~Paiements match          [F9]"
  #define MSG006      "~Recalculer          [Ctrl-F5]"
  #define MSG007      "~Configurer...            [F5]"
  #define MSG008      "~Mode de s‚lection articles..."
  #define MSG009      "~Transf‚rer … ...         [F9]"
  * #define MSG010      "Modifier ‚t~at...         [F2]"
  * #define MSG011      "~Accomptes            [Alt-F9]"
  #define MSG012      "~Extrait de compte        [F9]"
  #define MSG013      "Bewegungen ~Artikel    [Sh-F9]"
  #define MSG014      "~Cl“turer                 [F2]"
  #define MSG015      "P.U. TVA compr~ise    [Alt-F5]"
  #define MSG016      "Commandes en ~cours       [F6]"
  * #define MSG_VNAAUTO "Facturation ~auto     [Alt-F6]"
  #define MSG_RPQ     "~Remises par quantit‚         "
  #define MSG017      "S~ubstituts         [Shift-F2]"
  * #define MSG018      "~Valider               [Enter]"
  * static MSG021 :=    "~Signal‚tique Parten.  [Sh-F5]"
  #ifdef DEF_ANA
    static MSG023 :=  "Imputations ~analytiques  [F8]"
  #endif DEF_ANA
  * #ifdef DEF_ACF
  * static MSG_ACFEDIT := "~Prix partenaires         [F8]"
  * #endif DEF_ACF
  #define MSG024        "Facturation ~automat.  [Sh-F6]"
  #define MSG025        "Editeur de ~texte        [F12]"
  #define MSG026        "~G‚n‚rer calendrier           "
  #define MSG027        "~Nettoyer                     "
  static MSG031 :=      "~Bewegungen / Bezug  [Ctrl-F9]"
  #define MSG032        "Bewegungen ~Empf„nger [Alt-F9]"
  #ifdef DEF_FIN
    static MSG042 :=    "Copier ~remarque          [F2]"
  #endif
  #ifdef DEF_TRA
 static MSG_TRASTORN := "Stor~nieren                   "
  #endif
#endif

#ifdef LG_GERMAN
  #define MSG006                 "~Neu rechnen          [Ctrl-F5]"
  #define MSG008                 "~Modus Artikelauswahl...       "
  #define MSG012                 "Bewegungen ~Partner        [F9]"
  #define MSG013                 "Bewegungen ~Artikel     [Sh-F9]"
  #define MSG014                 "~Registrieren              [F2]"
  #define MSG016                 "~Laufende Bestellungen     [F6]"
  #define MSG_RPQ                "Mengen~rabatte                 "
  #define MSG017                 "S~ubstitute          [Shift-F2]"
  #ifdef DEF_ANA
    #ifdef DEF_IMP
    static MSG023 :=             "~Analytische Buchungen     [F6]"
    #else
    static MSG023 :=             "~Analytische Buchungen     [F8]"
    #endif
  #endif DEF_ANA
  #define MSG026                 "Kalender ~generieren           "
  #define MSG027                 "~Aufr„umen                     "
  static MSG031 :=               "~Bewegungen /Bezug    [Ctrl-F9]"
  #define MSG032                 "Bewegungen ~Empf„nger  [Alt-F9]"
  #define MSG034                 "~oti-Datei neu schreiben       "
  static MSG033 :=               "Bewe~gungen /EA-Match          "
  #ifdef DEF_TRA
  static MSG_TRASTORN :=         "Stor~nieren                    "
  #endif
#endif

#ifdef LG_EN
  #define MSG006                 "~Neu rechnen          [Ctrl-F5]"
  #define MSG008                 "~Modus Artikelauswahl...       "
  #define MSG012                 "Bewegungen ~Partner        [F9]"
  #define MSG013                 "Bewegungen ~Artikel     [Sh-F9]"
  #define MSG014                 "~Registrieren              [F2]"
  #define MSG016                 "~Laufende Bestellungen     [F6]"
  #define MSG_RPQ                "Mengen~rabatte                 "
  #define MSG017                 "S~ubstitute          [Shift-F2]"
  #ifdef DEF_ANA
    #ifdef DEF_IMP
    static MSG023 :=             "~Analytische Buchungen     [F6]"
    #else
    static MSG023 :=             "~Analytische Buchungen     [F8]"
    #endif
  #endif DEF_ANA
  #define MSG026                 "Kalender ~generieren           "
  #define MSG027                 "~Aufr„umen                     "
  static MSG031 :=               "~Bewegungen /Bezug    [Ctrl-F9]"
  #define MSG032                 "Bewegungen ~Empf„nger  [Alt-F9]"
  #define MSG034                 "~oti-Datei neu schreiben       "
  static MSG033 :=               "Bewe~gungen /EA-Match          "
  #ifdef DEF_TRA
  static MSG_TRASTORN :=         "Stor~nieren                    "
  #endif
#endif


#ifdef DEF_TRA
  static saTrlJnlAllow := {}
#endif DEF_TRA


#ifdef DEF_VEN

**
** VEN - Documents ventes
**
FUNCTION oVen
static b := NIL
if b != NIL ; RETURN b ; endif
define data b               ;
  name VEN                    ;
  preDelete  VenPreDelete()      ;
  create     VenCreate()   ;
  postedit   VenPostEdit()    ;
  editprint  VenPrint()       ;
  wait       {|x| VenWait(x)}
ddIndex b on  VEN->IdJnl+VEN->IdDoc ;
            format {|x| ;
              left(x,LenIdJnl())+ ;
              GetIdDoc( ;
                substr(x,LenIdJnl()+1), ;
                JnlLocate(left(x,LenIdJnl())),;
              );
            }            // ORD_VEN_ID
ddIndex b on  VEN->IdPar+VEN->IdJnl+VEN->IdDoc ;
            format {|x| ;
              left(x,LenIdPar()+LenIdJnl())+ ;
              GetIdDoc( ;
                substr(x,LenIdPar()+LenIdJnl()+1), ;
                JnlLocate(substr(x,LenIdPar()+1,LenIdJnl())) ;
              ) ;
            }            // ORD_VEN_PAR
#ifdef DEF_PRJ
  ddIndex b on  VEN->IdPrj+dtos(VEN->Date)+VEN->IdJnl  // ORD_VEN_PRJ
#endif
ddFld IdJnl    ,C, LenIdJnl(),0  picture PIC_ID when .f.
ddFld IdDoc    ,C, LenIdDoc(),0  picture PIC_ID when .f.
ddFld IdPar    ,C, LenIdPar(),0  picture PIC_ID ;
                        pick PickPar( ;
                          CtrPrtList(JnlIdCtr(VEN->IdJnl)), ;
                          VEN->IdPar) ;
                        postedit {|x| ;
                          GetIdPar( ;
                            x,CtrPrtList(JnlIdCtr(VEN->IdJnl)) ;
                          ) ;
                        } ;
                        valid VenParValidate() ;
                        when VenIsOpen()
ddFld _ParName1,C,40,0  attrib V block padr(ParName(VEN->IdPar),40)
ddFld NB1      ,C,30,0
ddFld Mont     ,T, LenMont(),0 ;
                   GET_DECPOS(DevDecPos(VEN->IdDev)) ;
                   when VenIsOpen() .and. JNLATTR_T $ JnlAttrib(VEN->IdJnl) ;
                   valid VenSetEtat(DocStatNew()) ;
                   value DcVal(JnlDc(VEN->IdJnl))
ddFld Etat     ,C, 1,0  picture "!"  when .f. ;
                   pick PickStatus(VEN->Etat)
ddFld Date     ,D, 8,0  valid VenValDate() when VenIsOpen()
ddFld DatEch   ,D, 8,0
ddFld NB2      ,C,30,0  valid NB2Validate(VEN->NB2)
ddFld Auteur   ,C, LenIdUsr(),0  picture PIC_ID ;
                   pick PickUsr(VEN->Auteur)
#ifdef DEF_HST
  ddFld Match    ,C, LenIdJnl()+LenIdDoc(),0 picture PIC_ID ;
                   pick PickHstPar(VEN->IdPar,VenMatch()) ;
                   when VenIsOpen() ;
                   valid VenMatchValidate()
#else
  ddFld Match    ,C, 0,0 attrib H
#endif DEF_HST
ddFld Attrib   ,C, 6,0  picture PIC_ID ;
                        pick PickFca(VEN->Attrib,MsgIdJnlDoc())
ddFld IdMfc    ,C,LenIdMfc(),0  picture PIC_ID ;
               pick PickIfc(VEN->IdMfc,VEN->IdJnl,MsgIdJnlDoc()) ;
               valid VenMfcValidate(NIL,NIL,.t.) ;
               when VenIsOpen()
ddFld IdPar2   ,C, LenIdPar(),0  GET_PAD ;
                   pick PickPar(CtrPrtList(JnlIdCtr(VEN->IdJnl)),VEN->IdPar2) ;
                   valid VenPar2Validate()
ddFld _ParName2,C,30,0  attrib V block padr(ParName(VEN->IdPar2),30)
ddFld _MontDB  , T,LenMont(),0 attrib V block VenMontDb()
ddFld _DocLib ,C, 20,0  attrib V ;
              block padr(JnlDocLib(VEN->IdJnl,VEN->IdDoc,VEN->DC,UsrLang()),20)
ddFld Periode , C, LEN_PERIODE,0 picture PIC_ID ;
                   pick PickPer(VEN->Periode,VEN->IdJnl) ;
                   when VenIsOpen() ;
                   valid DocPerValidate(ParExpr(VEN->IdPar,"PAR->IdDev"))
#ifdef DEF_TAX
  ddFld IdReg    ,C, LEN_IDREG,0  ;
                     picture PIC_ID ;
                     pick PickReg(VEN->IdReg) ;
                     when VenIsOpen() ;
                     valid VenRegValidate()
#else
  ddFld IdReg    ,C,0,0 attrib H
#endif
ddFld Memo    , M,10,0
ddFld DC      ,C, 1,0  picture PIC_ID valid VenDcValidate() ;
                       when VenIsOpen()
ddFld IdTpl   ,C,LenIdTpl(),0 attrib H
ddFld _Status  , C,10,0 attrib V block EtatText(VEN->Etat)
#ifdef DEF_VENREMISE
  ddFld MontT    , T,LenMont(),0 when .f.
  ddFld Remise   ,C, 3,0 GET_NUM ;
                   when VenIsOpen() ;
                   valid VenRemValidate()
  ddFld MontR    , T,LenMont(),0 when .f.
#else
  ddFld cMontT   , C,0,0 attrib H
  ddFld Remise   , C,0,0 attrib H
  ddFld MontR    , C,0,0 attrib H
#endif DEF_VENREMISE
ddFld IdDev    , C, LEN_IDDEV,0 picture PIC_ID pick PickDev(VEN->IdDev) ;
                        valid VenDevValidate() ;
                        when VenIsOpen()
ddFld Cours    , T,10,0 GET_NUM ;
                        valid CoursValidate(VEN->IdDev) ;
                        when VenIsOpen() ;
                          .and.!PerDevFixed(VEN->Periode,VEN->IdDev)
#ifdef DEF_PRIXR
ddFld SK       , T,LenMont(),0 value val(VEN->SK) when .f.
#else
ddFld SK       , T,LenMont(),0 attrib H // CR value val(VEN->cPrixA)
#endif
ddFld IdPrj    ,C, LenIdPrj(),0  picture PIC_ID ;
                   pick PickPrj(VEN->IdPrj) ;
                   valid PrjValidate(VEN->IdPrj,ParName(VEN->IdPar))
*
action b key K_ENTER   prompt MnuInhalt() ;
                       block VenDetail(NIL,.t.).and.SetMnuDone()
action b key K_CTRL_F2 prompt MnuClose()  ;
                       block SetMnuDone().and.TryRecLock({||VenClose(.t.)})
action b key K_SH_F5   prompt MnuParPage() block ParPage(VEN->IdPar)
#ifdef DEF_VNA
  * action b key K_F6   prompt MSG016 ;
  *          block ParVnaEdit(VEN->IdPar)
  * action b key K_ALT_F6   prompt MSG_VNAAUTO ;
  *          block ParVnaAuto(VEN->IdPar,VEN->IdJnl,VEN->NB1)
#endif
action b key K_ALT_F7  prompt MsgMnuAttrib() block VenPickAttrib()
#ifdef DEF_MVA
  action b key K_F8   prompt MSG023 ;
           block VenMvaEdit()
#endif DEF_MVA
#ifdef DEF_PRESTO
  action b key K_F8  prompt MnuTrmEdit() block ParTrmEdit(VEN->IdPar)
#endif
#ifdef DEF_HST
  action b key K_F9   prompt MnuHstEdit() ;
           block ParHstEdit(VEN->IdPar)
  action b key K_CTRL_F9 prompt MnuDocHstEdit() ;
           block DocHstEdit(VEN->IdJnl,VEN->IdDoc)
  action b key K_ALT_F9  prompt MnuHstMatch() ;
           block MatchHstEdit(VEN->IdPar,VenMatch())
#endif DEF_HST
* #ifdef DEF_HOLZ
*   action b               prompt MSG044 ;
*            block VenDtlEdit() // VEN->IdJnl,VEN->IdDoc)
* #endif DEF_HOLZ
#ifdef DEF_MEMO
  action b key K_F12 prompt MnuMemoEdit() block VenGetMemo(.t.)
#endif
* #ifdef DEF_TOOLBOX
*   action b key K_ALT_F2 block VenRename() ;
*                         when USRATTR_E $ UsrAttrib()
* #endif
#ifndef DEF_MEMO
  ddFldRemove("Memo")
#endif
#ifndef DEF_PRJ
  ddFldRemove("IdPrj")
#endif
* #ifdef DEF_ACT
*   if IsCustData("VEN") ; ActExec("VEN") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

#ifdef DEF_TAX

FUNCTION VenRegValidate()
local lOkay := .f.
local lConfirm := .t.
local jnl
local a
local reg := RegLocate(VEN->IdReg)
if reg == NIL
  SetMsg(VEN->IdReg + MsgRegExist())
  RETURN .f.
endif
if REGATTR_A $ reg[REG_ATTRIB]
  if (jnl := JnlLocate(VEN->IdJnl)) != NIL
    if (a := VenVnlInit(jnl)) != NIL
      open area oVnl(DocStatOpen()), oArt(), oGen(), oNew(), oVna()
        lOkay := .t.
        softseek VEN->IdJnl + VEN->IdDoc
        do while lOkay .and. !eof() .and. FIELD->IdDoc == VEN->IdDoc ;
                                    .and. FIELD->IdJnl == VEN->IdJnl
          if TaskInter() ; lOkay := .f. ; exit ; endif
          if lConfirm
            if Confirm(MsgRegValidate())
              lConfirm := .f.
            else
              lOkay := .f.
              exit
            endif
          endif
          if ddRecLock()
            VnlTaxReset()
            unlock record
          else
            lOkay := .f.
            exit
          endif
          skip
        enddo
      close area
      if lOkay
        VenVnlUpdate(jnl)
      endif
      VnlRestore(a)
    endif
  endif
endif
RETURN ph_refresh()

FUNCTION MsgRegValidate()
#ifdef LG_GERMAN
  RETURN "MWSt-Codes im Dokument anpassen (J/N) ?"
#endif
#ifdef LG_FRENCH
  RETURN "Adapter les codes TVA dans le document (O/N) ?"
#endif
#ifdef LG_EN
  RETURN "Do you also want to update VAT codes in this document (Y/N) ?"
#endif

#endif DEF_TAX

#ifdef DEF_VENREMISE

FUNCTION VenRemValidate()
local jnl := JnlLocate(VEN->IdJnl)
local a
RETURN .f. if jnl == NIL
RETURN .f. if (a := VenVnlInit(jnl)) == NIL
if VenVnlUpdate(jnl)
  ph_Refresh()
endif
VnlRestore(a)
RETURN .t.

#endif DEF_VENREMISE

FUNCTION VenMarge(cPrixA,cPrixV)
RETURN Marge(val(cPrixA),VenDev2Db(val(cPrixV)) )

FUNCTION VenDcValidate()
ph_refresh()
RETURN DcValidate(VEN->DC)


**
** VNL - Lignes de VEN
**
FUNCTION oVnl(cVenEtat,lRebuild)
local b
static b1 := NIL
#ifdef DEF_VNLALT
  static b2 := NIL
#endif DEF_VNLALT
if lRebuild == .t.
  b1 := NIL
  #ifdef DEF_VNLALT
    b2 := NIL
  #endif DEF_VNLALT
  RETURN NIL
endif
#ifdef DEF_VNLALT // not used
  if cVenEtat == DocStatClosed()
    RETURN b2 if b2 != NIL
  else
    RETURN b1 if b1 != NIL
  endif
#else
  RETURN b1 if b1 != NIL
#endif DEF_VNLALT
define data b ;
       name VNL           ;
       postedit VnlPostEdit()         ;
       editprint  VnlVenPrint()       ;
       wait     {|x| VnlWait(x)}      ;
       preDelete   VnlPreDelete()
#ifdef DEF_VNLALT
  if cVenEtat != DocStatClosed()
    b[AD_NAME] := "VNLPRE"
  else
    b[AD_NAME] := "VNLDEF"
  endif
#endif DEF_VNLALT
ddIndex b on  FIELD->IdJnl+FIELD->IdDoc+FIELD->Line    // ORD_VNL_DOC
ddIndex b on  FIELD->IdArt // ORD_VNL_ART
#ifdef DEF_SER
  ddIndex b on  FIELD->IdSer // ORD_VNL_IDSER
#endif
ddFld IdJnl   ,C, LenIdJnl(),0 when .f.
ddFld IdDoc   ,C, LenIdDoc(),0 when .f.
#ifdef DEF_QTESUB
  ddFld Qte1    ,C, LenQte(),0 ;
        postedit {|x| GetNum(x) } ;
        pick {|x,r,c| PickNum(x,r,c) } ;
        valid VnlQteValidate() ;
        when VnlPreEdit()
#else
  ddFld Qte1    ,C, 0,0 attrib H
#endif
ddFld Line    ,C, LEN_POS,0 when VnlPreEdit()
ddFld Code    ,C, 1,0 picture  "!" ;
                      pick PickVnlCode(FIELD->Code) ;
                      when VnlPreEdit() ;
                      valid VnlIdValidate()
ddFld IdArt   ,C, LenObjet(),0 picture PicIdArt() ;
                      pick VnlPickArt() ;
                      when VnlPreEdit() ;
                      valid VnlIdValidate() ;
                      block {|x| GsbVnlIdArt(x) }
ddFld Desig   ,C,LenVnlName(),0 ;
                      when VnlPreEdit() ;
                      picture "@K@S28"
ddFld Qte     ,Q, LenQte(),0 when VnlPreEdit() ;
                             valid VnlQteValidate(.t.)
ddFld PrixU   ,T,LenMont(),0 ;
                      when VnlPreEdit() ;
                      valid VnlPuValidate(.t.) ;
                      pick PickNum(FIELD->PrixU)
#ifdef DEF_VNA
ddFld Match   ,C, LenIdJnl()+LenIdDoc()+LEN_POS,0 picture PIC_ID ;
                      when VnlPreEdit() ;
                      pick PickVnlMatch()
#else
ddFld Match   ,C,0,0 attrib H
#endif
#ifdef DEF_TAX
ddFld MontT   ,T,LenMont(),0  ;
                      block {|x| GsbVnlTaxe(x) } ;
                      when VnlPreEdit() ;
                      valid VnlTotRefresh() ;
                      pick PickNum(GsbVnlTaxe())
#else
ddFld MontT   ,C,0,0 attrib H
#endif
ddFld _VenNB1 ,C,30,0 attrib V ;
                      block VenField(FIELD->IdJnl + FIELD->IdDoc,{||VEN->NB1})
#ifdef DEF_TAX
ddFld IdTax   ,C, LEN_IDTAX,0 picture PIC_ID ;
                      when VnlPreEdit() ;
                      pick VnlPickTax() ;
                      valid VnlTaxValidate()
ddFld _TVAC   ,T,LenMont(),0 attrib V ;
                      when VnlPreEdit() ;
                      block {|x| GsbVnlTvac(x) } ;
                      valid VnlTotRefresh() ;
                      pick PickNum(GsbVnlTvac())
#else
ddFld IdTax   ,C,0,0 attrib H
ddFld _TVAC   ,C,0,0 attrib H
#endif
#ifdef DEF_QTESUB
  ddFld Qte2    ,C, LenQte(),0 GET_DECPOS(1) ;
                    when VnlPreEdit() ;
                    valid VnlQteValidate()
#else
  ddFld Qte2    ,C, 0,0 attrib H
#endif
ddFld cMont   ,T,LenMont(),0 block {|x| GsbVnlMont(x) } ;
                      when VnlPreEdit() ;
                      valid VnlTotRefresh() ;
                      pick PickNum(FIELD->cMont)
#ifdef DEF_QTESUB
  ddFld Qte3    ,C, LenQte(),0 GET_DECPOS(1) ;
                    when VnlPreEdit() ;
                    valid VnlQteValidate()
#else
  ddFld Qte3    ,C, 0,0 attrib H
#endif
#ifdef DEF_ART_REF
  ddFld _ArtRef ,C,LenArtRef(),0 attrib V ;
                picture PIC_ID ;
                when VnlPreEdit() ;
                block {|x| VnlArtRef(x)} ;
                valid VnlIdValidate()
                * pick {|cStart| PickRef(cStart) }
#else
  ddFld _ArtRef   ,C, 0,0 attrib H
#endif
ddFld _Periode , C, LEN_PERIODE,0 attrib V ;
                    block VenField(FIELD->IdJnl + FIELD->IdDoc,{||VEN->Periode})
ddFld Memo    ,M,10,0
ddFld _Libell ,C,LenVnlName(),0 picture "@K@S28" attrib V ;
                      when .t. block {|x| VnlLibell(x) }
ddFld _ObjName,C,LenArtName(),0 attrib V ;
                      block padr(VnlObjName(MemLang1),LenArtName())
ddFld _ParName,C,30,0 attrib V block VnlParName()
#ifdef DEF_INT
  ddFld IdInt     ,C, LenIdInt(), 0 picture PIC_ID ;
                    pick PickInt(FIELD->IdInt)
  ddFld QteStat   ,C, LenQte(), 0 GET_NUM
#else
  ddFld IdInt   ,C, 0, 0 attrib H
  ddFld IsMemo  ,C, 1,0 attrib V block if(empty(FIELD->Memo)," ","m")
#endif
* ddFld Date,D, 8,0
ddFld _VenDate,D, 8,0 attrib V block VnlVenDate()
ddFld _IdDev   , C, LEN_IDDEV,0 attrib V ;
                    block VenField(FIELD->IdJnl + FIELD->IdDoc,{||VEN->IdDev})
ddFld _DC     , C, 1,0 attrib V ;
                    block VenField(FIELD->IdJnl + FIELD->IdDoc,{||VEN->DC})
#ifdef DEF_PRIXR
  ddFld PrixR   ,T,LenMont(),0 ;
                      valid VnlPRValidate(.t.)
#else
  ddFld PrixR  ,C,0,0 attrib H
#endif DEF_PRIXR
#ifdef DEF_VNLATTR
  ddFld Attrib  ,C, LEN_VNLATTR,0 picture PIC_ID ;
                    pick PickVnlAttrib(FIELD->Attrib)
#else
  ddFld Attrib  ,C, 0,0 attrib H
#endif
ddFld _Memo   ,C,60,0 attrib V when .t. ;
                      block {|x| GsbGetMemo(x) }
#ifdef DEF_SER
  ddFld IdSer     ,C, LenIdSer(),0 ;
                      postedit {|x| GetIdSer(x) } ;
                      valid VnlSerValidate() ;
                      pick PickSer(FIELD->IdSer,FIELD->IdArt,VEN->Date)
#else
  ddFld IdSer     ,C, 0,0 attrib H
#endif DEF_SER
#ifdef DEF_PROVI
  ddFld PrixPU  ,T,LenMont(),0 GET_DECPOS(VnlDecPos()) ;
                valid ddMustScan(.t.)
  ddFld IdPga   ,C,LenIdPga(),0 picture PIC_ID ;
                pick PickPga(FIELD->IdPga)
  ddFld PrixL   ,T,LenMont(),0 GET_DECPOS(VnlDecPos()) ;
                valid VnlPlValidate()
  ddFld PrixPL  ,T,LenMont(),0 GET_DECPOS(VnlDecPos()) ;
                valid ddMustScan(.t.)
  ddFld GP     ,C, 3, 0 GET_NUM
#else
  ddFld PrixPU  ,C,0,0 attrib H
  ddFld IdPga   ,C,0,0 attrib H
  ddFld PrixPL  ,C,0,0 attrib H
  ddFld PrixL  ,C,0,0 attrib H
  ddFld GP     ,C,0,0 attrib H
#endif DEF_PROVI
#ifdef DEF_MULT
  ddFld Mult    ,C, 4,0 GET_DECPOS(2) ;
                when VnlPreEdit().and.FIELD->Code!=LNCODE_TOTAL ;
                valid VnlMultValidate()
#else
  ddFld Mult    ,C, 0,0 attrib H
#endif DEF_MULT
#ifdef DEF_SUB
  action b key K_SH_F2   prompt MSG017    ;
           block LnPickSub(left(FIELD->IdArt,LenIdArt()))
#endif
action b key K_SH_F4  prompt MnuArtPage() block VnlDetail()
action b key K_CTRL_RET  prompt NIL block VnlDetail()
action b key K_F5   prompt MnuDocCopy() block VnlCopy() ;
                    when indexord() == 1 .and. VenPreEdit()
action b key K_SH_F5      prompt MnuParPage() block ParPage(VEN->IdPar)
action b key K_CTRL_F5    prompt MSG006 block VnlResetAll() ;
                          when indexord() == 1 .and. VenPreEdit()
* #ifdef DEF_VNA
*   action b key K_F6   prompt MSG016 ;
*            block ParVnaEdit(VEN->IdPar)
* #endif
#ifdef DEF_ACF
  action b key K_SH_F2 prompt MnuAcfEdit()  block VnlAcfEdit() ;
                        when IsArtCode(FIELD->Code)
#endif DEF_ACF
#ifdef DEF_REMISE
  action b key NIL     prompt MSG_RPQ ;
           block VnlRpqEdit()
#endif
action b key K_ALT_F7 prompt MsgMnuAttrib() block VnlPickAttrib()
* #ifdef DEF_ANA
*   action b key K_F8 prompt MSG023 ;
*            block VnlMvaEdit()
* #endif DEF_ANA
#ifdef DEF_PRESTO
  action b key K_F8  prompt MnuTrmEdit() block ParTrmEdit(VEN->IdPar)
#endif
* #ifdef DEF_SER
*   action b key K_F8 prompt MsgMnuSer() ;
*            block VnlSerEdit()
* #endif DEF_SER
#ifdef DEF_HST
  action b key K_F9 prompt MnuHstEdit() ;
           block GenHstEdit(left(FIELD->IdArt,LenIdGen())) ;
           when FIELD->Code == LNCODE_GEN
  action b key K_F9   prompt NIL ;
           block ParHstEdit(VEN->IdPar)
#endif DEF_HST
* #ifdef DEF_MEMO
*   action b key K_F12 prompt MnuMemoEdit() block VnlGetMemo()
* #endif
#ifdef DEF_ART
  action b key NIL   prompt MSG008    ;
           block SetPickArtMode() ;
           when indexord() == 1
#endif
action b key K_ENTER prompt MsgMnuDocPage() ;
                     block DocPage(FIELD->IdJnl,FIELD->IdDoc) ;
                     when indexord() == ORD_VNL_ART ;
                       .or. indexord() == ORD_VNL_VNA
#ifndef DEF_MEMO
  ddFldRemove("Memo")
#endif
* #ifndef DEF_VNA
*   ddFldRemove("Match")
* #endif
* #ifndef DEF_STK
*   ddFldRemove("IdStk")
* #endif
ddEndDef()
#ifdef DEF_VNLALT
  if cVenEtat == DocStatClosed()
    b2 := b
  else
    b1 := b
  endif
#else
  b1 := b
#endif DEF_VNLALT
RETURN b

FUNCTION GsbGetMemo(x)
RETURN padr(FIELD->Memo,60) if x == NIL
FIELD->Memo := x
if empty(FIELD->IdArt)
  FIELD->IdArt := "*"
endif
RETURN NIL


* FUNCTION VnlPreEdit()
* RETURN VenPreEdit( ;
*   "Drcken Sie [Esc] und dann [F2] zum entregistrieren" ;
* )

FUNCTION VnlParName()
RETURN VenField(FIELD->IdJnl + FIELD->IdDoc,{||padr(ParName(VEN->IdPar),30)})

FUNCTION VnlVenDate
RETURN VenField(FIELD->IdJnl + FIELD->IdDoc,{||VEN->Date})

#ifdef DEF_ACF

FUNCTION VnlAcfEdit
RETURN ArtAcfEdit(VEN->IdPar,"ACFVNL")

#endif DEF_ACF


#ifdef DEF_ART_REF

FUNCTION VnlArtRef(x)
local cIdArt
if x == NIL
  RETURN space(LenArtRef()) if ! IsArtCode(FIELD->Code)
  RETURN ArtField(left(FIELD->IdArt,LenIdArt()), {|| ART->Ref} )
endif
open area oArt()
  ddSetOrder(ORD_ART_REF)
  x := RefTrunc(x)
  seek x
  if eof()
    Alarm()
    cIdArt := PickArt("",VEN->IdPar,NIL,x)
  else
    cIdArt := ART->IdArt
    ** neu 19990427 : Wenn ART->Ref nicht eindeutig ist.
    skip
    if RefTrunc(ART->Ref) == x .and. !eof()
      Alarm()
      cIdArt := PickArt("",VEN->IdPar,NIL,x)
    endif
    ** ende neu 19990427
  endif
close area
if cIdArt != NIL
  FIELD->Code  := LNCODE_ART
  FIELD->IdArt := cIdArt
endif
RETURN NIL


* FUNCTION VnlRefValidate
* local cIdArt
* open area oArt()
*   ddSetOrder ORD_ART_REF
*   seek RefTrunc(x)
*   if eof()
*     cIdArt := VnlPickRef(x)
*   else
*     cIdArt := ART->IdArt
*   endif
* close area
* if cIdArt != NIL
*   FIELD->Code  := LNCODE_ART
*   FIELD->IdArt := cIdArt
* endif
* RETURN NIL

FUNCTION PickRef(cStart)
* local cIdArt
* open area oArt()
*   ddSetOrder ORD_ART_REF
*   softseek trim(RefTrunc(cStart))
*   cIdArt := ART->IdArt
* close area
RETURN PickArt("",NIL,{||ART->Ref},RefTrunc(cStart))

#else

FUNCTION PickRef() ; RETURN NIL
FUNCTION VnlArtRef(x) ; RETURN NIL

#endif ART_REF

FUNCTION VnlConvert()
DBN->Line  := right(DBO->Line,LEN_POS)
RETURN .t.

FUNCTION VnlDetail
#ifdef DEF_ART
  RETURN ArtPage(left(FIELD->IdArt,LenIdArt())) if IsArtCode(FIELD->Code)
#endif DEF_ART
#ifdef DEF_GEN
  RETURN GenPage(left(FIELD->IdArt,LenIdGen())) if FIELD->Code == LNCODE_GEN
#endif DEF_GEN
#ifdef DEF_NEWS
  RETURN NewPage(left(FIELD->IdArt,LenIdPar())) if FIELD->Code == LNCODE_NEWS
#endif DEF_NEWS
RETURN MnuDone()

* FUNCTION LnQtePu(lNew)
* if lNew != NIL
*   slQtePu := lNew
* endif
* RETURN slQtePu


FUNCTION VnlTvac
#ifdef DEF_TAX
  RETURN val(FIELD->cMont) + val(FIELD->MontT)
#else
  RETURN val(FIELD->cMont)
#endif

#ifdef DEF_VNLATTR

FUNCTION PickVnlAttrib(cStart)
local aAttrib := {}
#ifdef LG_FRENCH
  aadd(aAttrib, { VNLATTR_U, "souligner               " , 1 } )
  aadd(aAttrib, { VNLATTR_D, "cacher le prix d‚taill‚ " , 1 } )
  aadd(aAttrib, { VNLATTR_S, "saut de page            " , 1 } )
  aadd(aAttrib, { VNLATTR_H, "invisible               " , 1 } )
  aadd(aAttrib, { VNLATTR_F, "Note de bas de page     " , 1 } )
#endif
#ifdef LG_GERMAN
  aadd(aAttrib, { VNLATTR_U, "Unterstrichen              " , 1 } )
  aadd(aAttrib, { VNLATTR_D, "ohne Detail-Preis          " , 1 } )
  aadd(aAttrib, { VNLATTR_S, "Seitenwechsel              " , 1 } )
  aadd(aAttrib, { VNLATTR_H, "unsichtbar                 " , 1 } )
  aadd(aAttrib, { VNLATTR_F, "Fuánote                    " , 1 } )
#endif
#ifdef LG_EN
  aadd(aAttrib, { VNLATTR_U, "Underlined                 " , 1 } )
  aadd(aAttrib, { VNLATTR_D, "no detail price            " , 1 } )
  aadd(aAttrib, { VNLATTR_S, "page break before          " , 1 } )
  aadd(aAttrib, { VNLATTR_H, "hidden                     " , 1 } )
  aadd(aAttrib, { VNLATTR_F, "Footnote                   " , 1 } )
#endif
RETURN PickAttrib(aAttrib,NIL,cStart,"","VNLATTR")

#endif DEF_VNLATTR



#endif DEF_VEN

#ifdef DEF_IVT

**
** IVT - Inventaires
**
**
FUNCTION oIvt
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b              ;
       name IVT                   ;
       predelete  IvtPreDelete()        ;
       create  IvtCreate()        ;
       preedit IvtPreEdit() ;
       editprint IvtPrint()
ddIndex b on  dtos(IVT->Date)
ddFld Date     ,D,  8,0 when .f.
ddFld Etat     ,C,  1,0 when .f. picture PIC_ID
ddFld PAMP     ,C, 10,0 when .f.
ddFld DPA      ,C, 10,0 when .f.
ddFld Nbre     ,C,  5,0 when .f.
ddFld _Status  , C,10,0 attrib V block EtatText(IVT->Etat)
action b key K_ENTER   prompt MnuInhalt() block IvtIvlEdit()
action b key K_CTRL_F2 prompt MSG014 block IvtClot()
action b key K_CTRL_F5 prompt NIL    block IvtRound()
ddEndDef()
RETURN b


**
** IVL - Lignes d'inventaire
**
FUNCTION oIvl(lRebuild)
* local b
static b := NIL
if lRebuild == .t. ; b := NIL ; RETURN NIL ; endif
if b != NIL ; RETURN b ; endif
define data b name IVL   ;
  postedit IvlPostEdit() ;
  preedit  IvtPreEdit()  ;
  predelete   IvlPreDelete()
ddIndex b on  dtos(IVL->Date)+IVL->IdArt // ORD_IVL_DATE
ddIndex b on  IVL->IdArt+dtos(IVL->Date) // ORD_IVL_ART
ddFld Date    ,D, 8,0 when .f.
ddFld IdArt   ,C, LenIdArt(),0 picture PicIdArt() ;
                  pick PickArt(IVL->IdArt)
ddFld _ArtName ,C,40,0 attrib V block padr(ArtName(IVL->IdArt),40)
* ddFld _Desig  ,C,40,0 attrib V block ArtDesig(IVL->IdArt)
ddFld Qte     ,C, LenQte(),0 GET_NUM
ddFld DPA     ,C,10,0 GET_MONTANT
ddFld PAMP    ,C,10,0 GET_MONTANT
action b key K_SH_F4      prompt MnuArtPage() ;
                          block ArtPage(IVL->IdArt)
ddEndDef()
RETURN b

FUNCTION IvlPreDelete ; RETURN .t.

#endif DEF_IVT

*#ifdef DEF_SHT
*
***
*** SHT - Feuilles de calcul
***
*FUNCTION oSht()
*local b
** static b := NIL
** if b != NIL ; RETURN b ; endif
*define data b                 ;
*  name SHT                    ;
*  editprint  ShtPrint()
*  ddIndex b on  upper(SHT->IdSht)
*ddFld IdSht  ,C,  8,0  picture PIC_ID
*ddFld Titre  ,C, 40,0
*ddFld Attrib ,C,  6,0  picture PIC_ID ;
*                       pick PickShtAttrib(SHT->Attrib)
*ddFld Width   ,C, 3,0  GET_NUM
*action b key K_F5    prompt MSG007 block ShtBalEdit()
*ddEndDef()
*RETURN b
*
*
*
***
*** BAL - Balances (champs des feuilles de calcul)
***
*FUNCTION oBal()
*local b
** static b := NIL
** if b != NIL ; RETURN b ; endif
*define data b name BAL
*       * convert BalConvert()
*ddIndex b on  BAL->IdSht + BAL->Seq
*ddFld Titre   ,C, 40,0  Header "Titre"
*ddFld IdGen1  ,C,  LenIdGen(),0  pick PickGen(NIL,BAL->IdGen1)
*ddFld IdGen2  ,C,  LenIdGen(),0  pick PickGen(NIL,BAL->IdGen2)
*ddFld Attrib  ,C,  6,0  picture PIC_ID ;
*                        pick PickBalAttrib(BAL->Attrib)
*ddFld Level   ,C,  2,0  GET_NUM
*ddFld IdSht   ,C,  8,0
*ddFld Seq     ,C,  3,0  postedit {|x|GetSeq(x)}
*ddFld _SoldeI ,C,  21,0 attrib V block BalIni()
*ddFld _TotalP ,C,  21,0 attrib V block BalMvt()
*ddFld _SoldeF ,C,  21,0 attrib V block BalFinal()
*ddFld Expr    ,C,128,0 picture "@K@S40" // width 40
*ddFld _Solde  ,C,  10,0 attrib V block BalSolde()
** action b key K_ENTER prompt "~Imprimer" block OpdGetOdl()
*#ifdef DEF_STRFILES
*  #ifdef LG_GERMAN
*  #include "BALD.STR"
*  #else
*  #include "BALF.STR"
*  #endif
*#endif DEF_STRFILES
*ddEndDef()
*RETURN b
*
*FUNCTION BalConvert
*DBN->IdGen1 := DBO->IdCfr1
*DBN->IdGen2 := DBO->IdCfr2
*RETURN .t.
*
*
*#endif DEF_SHT

#ifdef DEF_PRESTO

**
** TRM - Rendez-vous
**
FUNCTION oTrm()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name TRM                          ;
            preedit TrmPreEdit(b)           ;
            postedit TrmPostEdit(b)           ;
            editprint TrmPrint() ;
            predelete TrmPreDelete() ;
            wait {|x| TrmWait(x)}
ddIndex b on dtos(TRM->Date)+TRM->Debut       // ORD_TRM_DATE
ddIndex b on TRM->IdPar+dtos(TRM->Date)+TRM->Debut // ORD_TRM_PAR
ddIndex b on TRM->User+TRM->Etat+dtos(TRM->Date)+TRM->Debut // ORD_TRM_USER
ddIndex b on TRM->IdTac+dtos(TRM->Date)+TRM->Debut // ORD_TRM_TAC
#ifdef DEF_PRJ
ddIndex b on TRM->IdPrj+dtos(TRM->Date)+TRM->Debut // ORD_TRM_PRJ
#endif DEF_PRJ
* ddIndex b on TRM->Etat+dtos(TRM->Date)+TRM->Debut
ddFld Jour   ,C, 10,0 attrib V block padr(Jour(TRM->Date),10)
ddFld Date   ,D, 8,0 valid ph_Refresh()
ddFld Debut  ,C, 5,0 picture PIC_MONTANT valid TrmTimeValidate() ;
                     postedit {|x| GetTime(x) }
ddFld Fin    ,C, 5,0 picture PIC_MONTANT ;
                     postedit {|x| GetTime(x) } ;
                     valid TrmTimeValidate()
ddFld Texte  ,C,40,0
ddFld User   ,C, LenIdUsr(),0 picture PIC_ID pick PickUsr(TRM->User)
ddFld Attrib ,C, 4,0 picture PIC_ID      ;
                     pick PickAga(TRM->Attrib)
ddFld IdTac  ,C, LenIdArt(),0 picture PIC_ID                        ;
                     pick PickTac(TRM->IdTac) ;
                     valid ph_refresh()
                     * when ddQuery(b) != ORD_TRM_TAC
* #ifdef DEF_ART
* ddFld IdArt  ,C, LenIdArt(),0 picture PIC_ID                        ;
*                      pick PickArt(TRM->IdArt)
*                      * when ddQuery(b) != ORD_TRM_TAC
* #else
* ddFld IdArt  ,C, 0,0 attrib H
* #endif DEF_ART
ddFld IdPar  ,C, LenIdPar(),0 GET_PAD         ;
                     pick PickPar(NIL,TRM->IdPar) ;
                     valid OnParSelect().and.ph_refresh()
                     * when ddQuery(b) != ORD_TRM_PAR
ddFld _ParName  ,C,30,0 attrib  V  ;
                        block padr(ParName(TRM->IdPar),30)
ddFld IdPrj     ,C, LenIdPrj(),0 picture PIC_ID ;
                                 pick PickPrj(TRM->IdPrj)
ddFld Match    ,C, LenIdJnl()+LEN_IDDOC+LEN_POS,0 ;
                   picture PIC_ID
ddFld _AgaText  ,C,40,0 attrib V block padr(AgaText(TRM->Attrib),40)
ddFld MemoTxt   ,M,10,0 // same name... !
ddFld _TacName  ,C,40,0 attrib V block padr(TacName(TRM->IdTac),40)
ddFld Duree     ,C, 6,0 valid TrmTimeValidate() ;
                        postedit {|x| GetTime(x) }
ddFld _PrjName  ,C,30,0 attrib V block PrjName(TRM->IdPrj)
ddFld Etat      ,C,LEN_IDAGS,0 picture PIC_ID when .f.
ddFld _Etat     ,C,20,0 attrib V block AgsDesig(TRM->Etat)
*
action b key K_F12     prompt MnuMemoEdit() block TrmMemoEdit(b)
action b               prompt MSG026 block TrmGenerate(b)
action b               prompt MSG027 block TrmPack(b)
action b key K_CTRL_F2 prompt MnuClose() block TrmDlgClose(b)
* action b key K_F9      prompt MSG009 block TrmChgUser(b)
action b key K_SH_F5   prompt MnuParPage() block ParPage(TRM->IdPar)
#ifdef DEF_VNA
  action b key K_F6   prompt MSG016 ;
           block ParVnaEdit(TRM->IdPar)
#endif
#ifndef DEF_VNA
  ddFldRemove("Match")
#endif
#ifndef DEF_PRJ
  ddFldRemove("IdPrj")
  ddFldRemove("_PrjName")
#endif
* #ifdef DEF_ACT
*   if IsCustData("TRM") ; ActExec("TRM") ; endif
* #endif DEF_ACT
ddEndDef()
RETURN b

FUNCTION TrmPreDelete
RETURN ConfirmDelete() if empty(TRM->MemoTxt)
RETURN Confirm( ;
  "Der Memo-Text zu diesem Termin ist nicht leer.", ;
  MsgSure(), ;
  MSG_NO ;
)

*FUNCTION TrmConvert
*if empty(DBN->IdPar)
 * if ! empty(DBO->iCli)
 *   DBN->IdPar := ParNewId("C",DBO->iCli)
 * elseif ! empty(DBO->iFou)
 *   DBN->IdPar := ParNewId("F",DBO->iFou)
 * endif
*endif
*RETURN .t.

**
** AGS - Etats de commande
**
**
FUNCTION oAgs()
local b
define data b name AGS
ddIndex b on  AGS->IdAgs
ddFld IdAgs  ,C, LEN_IDAGS,0 picture PIC_ID
ddFld Desig  ,C,20,0
ddFld Attrib ,C, 5,0 picture PIC_ID pick PickAgsAttrib(AGS->Attrib)
ddFld User   ,C, 8,0 picture PIC_ID pick PickUsr(AGS->User)
ddFld Next   ,C, LEN_IDAGS,0 ;
              picture PIC_ID ;
              pick PickAgs(AGS->Next)
ddFld IdTpl  ,C, LenIdTpl(),0 picture PIC_ID ;
                              pick PickTpl(TPLTYPE_TRM,AGS->IdTpl)
ddEndDef()
RETURN b


#endif DEF_PRESTO


#ifdef DEF_IMP

**
** IMP - Documents "imputation"
**
FUNCTION oImp
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name IMP                   ;
  predelete  ImpPreDelete()     ;
  preedit    ImpPreEdit()     ;
  postedit   ImpPostEdit()    ;
  EditPrint  ImpPrint()       ;
  wait       {|x| ImpWait(x)}
ddIndex b on  IMP->IdJnl+IMP->IdDoc ;
              format {|x|left(x,LenIdJnl())+GetIdDoc(substr(x,LenIdJnl()+1))}            // ORD_VEN_ID
              // ORD_IMP_ID
* ddIndex b on  IMP->IdPar+IMP->IdJnl+IMP->IdDoc  // ORD_IMP_PAR
ddFld IdJnl    ,C, LenIdJnl(),0  picture PIC_ID when .f.
ddFld IdDoc    ,C, LEN_IDDOC,0  picture PIC_ID when .f.
ddFld IdPar    ,C, LenIdPar(),0  GET_PAD ;
                        pick PickPar( ;
                          NIL, ;
                          IMP->IdPar) ;
                        valid ImpPar1Validate()
ddFld _ParName1,C,30,0  attrib V block ParField(IMP->IdPar,{||PAR->Firme})
ddFld NB1      ,C,30,0
ddFld NB2      ,C,30,0 valid NB2Validate(IMP->NB2)
ddFld Mont1    ,T, LenMont(),0 GET_MONTANT ;
                   when JNLATTR_S $ JnlAttrib(IMP->IdJnl)
ddFld Etat     ,C, 1,0  picture "!"  when .f.
ddFld Date1    ,D, 8,0 valid ImpDateValidate()
ddFld Date2    ,D, 8,0
ddFld IdUsr    ,C,LenIdUsr(),0   picture PIC_ID pick PickUsr(IMP->IdUsr)
ddFld IdBud   ,C, LenIdBud(),0  picture PIC_ID ;
      block {|x| GsbIdBud(x) } ;
      pick PickBudSay(JnlDC(IMP->IdJnl),IMP->IdBud) ;
      valid ImpBudValidate(JnlDC(IMP->IdJnl))
ddFld _BudName ,C, 40,0 attrib V ;
                        block padr(BudName(JnlDC(IMP->IdJnl),IMP->IdBud),40)
ddFld _ImlDate ,D,8,0  attrib V block ImpImlField({||IML->Date})
ddFld IdPar2   ,C, LenIdPar(),0  GET_PAD ;
                   pick PickPar(NIL,IMP->IdPar2) ;
                   valid ImpPar2Validate()
ddFld _ParName2,C,30,0  attrib V block ParField(IMP->IdPar2,{||PAR->Firme})
ddFld Periode  , C, LEN_PERIODE,0 picture PIC_ID ;
                    pick PickPer(IMP->Periode,IMP->IdJnl,UserDate()) ;
                    valid ImpPerValidate()
ddFld Memo     , M,10,0
ddFld IdPrj    ,C, LenIdPrj(),0  picture PIC_ID ;
                   pick PickPrj(IMP->IdPrj)
                   * valid ImlPrjValidate(JnlDC(IMP->IdJnl))
ddFld Compte1  ,C,LenBqe(),0 ;
      postedit {|x| BqePostEdit(x) } ;
      valid BqeValidate(IMP->Compte1) ;
      pick ImlPickCompte()
ddFld Mont2    ,T, LenMont(),0 GET_MONTANT ;
                   when JNLATTR_S $ JnlAttrib(IMP->IdJnl)
ddFld Date3    ,D, 8,0
ddFld IdDev    , C, LEN_IDDEV,0 picture PIC_ID ;
                        pick PickDev(IMP->IdDev) ;
                        valid ImpDevValidate() ;
                        when empty(JnlIdDev(IMP->IdJnl))
ddFld Cours    , T,10,0 GET_NUM ;
                        valid CoursValidate(IMP->IdDev)
action b key K_ENTER prompt MnuInhalt() ;
                     block ImpImlEdit() ;
                     when ddRecStat() == RS_VALID
action b key K_CTRL_F2 prompt MnuClose() ;
       block TryRecLock({||ImpDlgClose(JnlLocate(IMP->IdJnl))})
* action b key K_F5    prompt MnuDocCopy() block ImpCopy()
action b key K_SH_F5 prompt MnuParPage() block ParPage(IMP->IdPar)
action b key K_F9    prompt MSG012 block ParMviEdit(IMP->IdPar) ;
                                   when ! empty(IMP->IdPar)
action b key K_SH_F9 prompt MSG013 ;
                     block BudMviEdit(JnlDC(IMP->IdJnl),IMP->IdBud) ;
                     when ! empty(IMP->IdBud)
action b key K_ALT_F9  prompt MSG032 block ParMv2Edit(IMP->IdPar2) ;
                       when ! empty(IMP->IdPar2)
#ifdef DEF_MEMO
  action b key K_F12 prompt MnuMemoEdit() block ImpGetMemo(.t.)
#endif
* action b key NIL       prompt MSG034 block ImpDlgWriteOti() ;
*                        when USRATTR_E $ UsrAttrib()
#ifdef DEF_LNK
  action b             prompt MsgLniEdit() ;
                       block MviLniEdit(IMP->IdJnl+IMP->IdDoc)
#endif DEF_LNK
*#ifdef DEF_ANA
*  action b key K_F6   prompt MSG023 ;
*           block ImpMvaEdit()
*#endif DEF_ANA
#ifndef DEF_MEMO
  ddFldRemove("Memo")
#endif
#ifndef DEF_PRJ
  ddFldRemove("IdPrj")
#endif
ddEndDef()
RETURN b

FUNCTION ImpBudValidate(cDC)
RETURN .f. if ! ValIdBud(JnlDC(IMP->IdJnl),IMP->IdBud)
FIELD->IdPrj := BUD->IdPrj
RETURN .t.


FUNCTION ImlBudValidate(cDC)
RETURN .f. if ! ValIdBud(IML->DC,IML->IdBud)
if empty(IMP->IdPrj)
  FIELD->IdPrj := BUD->IdPrj
endif
RETURN .t.


FUNCTION IfcDate2( cIdJnl, cIdMfc, dDate )
local ifc := IfcLocate(JnlIdCtr(cIdJnl),cIdJnl,cIdMfc)
RETURN dDate if ifc == NIL
dDate += val(ifc[IFC_DELAI])
if IFCATTR_M $ ifc[IFC_ATTRIB]
  dDate := LastOfMonth(dDate)
endif
RETURN dDate

FUNCTION ImpDateValidate()
if empty(IMP->IdPar2)
  seek IMP->IdPar in PAR
else
  seek IMP->IdPar2 in PAR
endif
IMP->Date3 := IfcDate2(IMP->IdJnl,PAR->IdMfc,IMP->Date1)
RETURN ph_refresh()

FUNCTION ImpPar1Validate()
RETURN .f. if ! ParValidate(IMP->IdPar)
IMP->Date3 := IfcDate2(IMP->IdJnl,PAR->IdMfc,IMP->Date1)
RETURN ph_Refresh() // ImpDateValidate() // ph_refresh()

FUNCTION ImpPar2Validate()
RETURN .t. if empty(IMP->IdPar2)
RETURN .f. if ! ParValidate(IMP->IdPar2)
IMP->Date3 := IfcDate2(IMP->IdJnl,PAR->IdMfc,IMP->Date1)
RETURN ph_Refresh()

FUNCTION ImlPar1Validate()
RETURN .f. if ! ParValidate(IML->IdPar)
RETURN ph_Refresh()

FUNCTION ImlPar2Validate()
if ! empty(IML->IdPar2)
  RETURN .f. if ! ParValidate(IML->IdPar2)
endif
RETURN ph_Refresh()

FUNCTION ValIdBud(cIdCtr,cIdBud)
RETURN .f. if ! BudExist(cIdCtr,cIdBud)
if BUDATTR_W $ BUD->Attrib
  RETURN .f. if ! Confirm( ;
    cIdCtr + "-" + trim(SayIdBud(cIdBud)) + " sollte nicht benutzt werden !", ;
    MsgSure(), MSG_NO, "WRN005" ;
  )
endif
if BUD->IsSum == BUTTON_ON // BUDATTR_S $ BUD->Attrib
  SetMsg("Summenartikel nicht erlaubt zum Direktbuchen")
  RETURN .f.
endif
RETURN ph_Refresh()

FUNCTION Par2Name(lAnrede)
* local cIdPar := ImlIdPar2()
* if empty(FIELD->IdPar2)
*   cIdPar := FIELD->IdPar
* else
*   cIdPar := FIELD->IdPar2
* endif
RETURN ParName(ImlIdPar2()) if lAnrede
RETURN ParField(ImlIdPar2(), {|| PAR->Firme } )

FUNCTION ImlPickCompte()
RETURN PickParCompte(ImlIdPar2(),FIELD->Compte1) 
// RETURN PickParCompte(FIELD->IdPar2,FIELD->Compte1)

FUNCTION ImlCountry()
RETURN NIL // nat2iso(ParExpr(ImlIdPar2(),"PAR->Pays"))

FUNCTION ImlIdPar2()
RETURN FIELD->IdPar if empty(FIELD->IdPar2)
RETURN FIELD->IdPar2


**
** IML - Documents "imputation"
**
FUNCTION oIml
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name IML                   ;
  preedit    ImlPreEdit()     ;
  postedit   ImlPostEdit()    ;
  wait       {|msk| ImlWait(msk) }
  * pickflt    ImlPickFilter() ;
ddIndex b on  IML->IdJnl+IML->IdDoc+IML->Line
ddFld IdJnl    ,C, LenIdJnl(),0  picture PIC_ID when .f.
ddFld IdDoc    ,C, LEN_IDDOC,0  picture PIC_ID when .f.
ddFld IdCtr    ,C, LenIdCtr(),0 picture PIC_ID // pick PickCtr(IML->IdCtr)
ddFld Line     ,C, LEN_POS,0 GET_NUM
ddFld IdPar    ,C, LenIdPar(),0  GET_PAD ;
                   pick PickPar( ;
                          NIL , ;
                          IML->IdPar) ;
                   valid ImlPar1Validate(IML->IdPar)
ddFld _ParName1,C,30,0  attrib V block ParField(IML->IdPar,{||PAR->Firme})
ddFld NB1      ,C,30,0
ddFld Mont     ,T, LenMont(),0 GET_MONTANT ;
                               block {|x| ImlMont(x) } ;
                               valid ImlMontValidate()
ddFld Date     ,D, 8,0
ddFld IdBud    ,C, LenIdBud(),0 picture PIC_ID ;
                                block {|x| GsbIdBud(x) } ;
                                pick PickBudSay(IML->DC,IML->IdBud) ;
                                valid ImlBudValidate()
ddFld _BudName ,C, 40,0 attrib V ;
                        block padr(BudName(IML->DC,IML->IdBud),40)
ddFld BackMatch,C, LenIdJnl()+LEN_IDDOC+LEN_POS,0 picture PIC_ID ;
                   when USRATTR_E $ UsrAttrib()
                   // pick ImlPickMatch({||IML->IdJnl+IML->IdDoc+IML->Line})
                   // skip .t.
ddFld Match    ,C, LenIdJnl()+LEN_IDDOC+LEN_POS,0 picture PIC_ID ;
                   when USRATTR_E $ UsrAttrib()
                   // pick ImlPickMatch({|| IML->Match})
                   // skip .t.
ddFld IdPar2   ,C, LenIdPar(),0  GET_PAD ;
                   pick PickPar(NIL,IML->IdPar2) ;
                   valid ImlPar2Validate(IML->IdPar2)
                   // skip .t.
ddFld _ParName2,C,30,0  attrib V block ParField(IML->IdPar2,{||PAR->Firme})
ddFld _ParAnrede ,C,25,0  attrib V block padr(Par2Name(.t.),25)
ddFld _NB1orBud ,C,40,0 picture "@K@S28" attrib V ; // width 28
                      when .t. block {|x| ImlLibell(x) }
ddFld IdPrj    ,C, LenIdPrj(),0  picture PIC_ID ;
                   pick PickPrj(IML->IdPrj)
                   * valid ImlPrjValidate(IML->DC)
                   // skip .t.
ddFld NB2      ,C,30,0 valid NB2Validate(IML->NB2)
ddFld Compte1  ,C,LenBqe(),0 ;
      postedit {|x| BqePostEdit(x) } ;
      valid BqeValidate(IML->Compte1) ;
      pick ImlPickCompte()
                       // skip .t.
ddFld _ParName ,C,25,0  attrib V block padr(Par2Name(.f.),25)
ddFld DC       ,C, 1,0 picture PIC_ID valid DcValidate(IML->DC)
ddFld _Debit ,T, LenMont(),0  GET_MONTANT attrib V ;
                       when .t. ;
                       block {|x| GsbImlDebit(x) } ;
                       valid ImlMontValidate()
ddFld _Credit,T, LenMont(),0  GET_MONTANT attrib V ;
                       when .t. ;
                       block {|x| GsbImlCredit(x) } ;
                       valid ImlMontValidate()
ddFld _BudAvail,C, LenMntF(),0 attrib V block ImlBudAvail()
ddFld _CdcHeader,C, LenMntF(),0 attrib H
                                // block CdcHeader(IML->DC,MemIdCdc)
ddFld IdIml    ,C, LenIdIml(),0 when .f.
ddFld EaMatch  ,C, LenIdJnl()+LEN_IDDOC,0 picture PIC_ID ;
                   when USRATTR_E $ UsrAttrib()
ddFld MontDev  ,T, LenMont(),0 block {|x| ImlMontDev(x) } ;
                   valid ImlDevValidate() ;
                   pick PickNum(IML->MontDev)
ddFld _DevDebit ,T, LenMont(),0  GET_DECPOS(ImlDevDecPos()) attrib V ;
                       when .t. ;
                       valid ImlDevValidate() ;
                       block {|x| GsbImlDev(DC_DEBIT,x) }
ddFld _DevCredit,T, LenMont(),0  GET_DECPOS(ImlDevDecPos()) attrib V ;
                       when .t. ;
                       valid ImlDevValidate() ;
                       block {|x| GsbImlDev(DC_CREDIT,x) }
action b key K_SH_F4   prompt MnuArtPage() ;
                       block BudPage(IML->DC, IML->IdBud)
action b key K_F5    prompt MnuDocCopy() block ImlCopy() ;
                                   when IMP->Etat != DocStatClosed()
action b key K_SH_F5 prompt MnuParPage() block ParPage(IML->IdPar)
action b key K_F9 prompt MSG012 ;
                  block ParMviEdit(IML->IdPar) ;
                  when ! empty(IML->IdPar)
action b key K_SH_F9 prompt MSG013 ;
                  block BudMviEdit(IML->DC,IML->IdBud) ;
                  when ! empty(IML->IdBud)
action b key K_CTRL_F9 prompt MSG031 ;
                       block MatchMviEdit(IML->IdPar,IML->Match)
action b key K_ALT_F9  prompt MSG032 block ParMv2Edit(IMP->IdPar2) ;
                       when ! empty(IMP->IdPar2)
action b prompt MSG033 block EaMviEdit(IML->IdPar,IML->EaMatch)
#ifdef DEF_MEMO
  action b key K_F12 prompt MnuMemoEdit() block ImpGetMemo(.f.)
#endif
#ifdef DEF_LNK
  action b             prompt MsgLniEdit() ;
                       block MviLniEdit(IML->Match)
#endif DEF_LNK
#ifdef DEF_MVA
  action b key K_F6 prompt MSG023 ;
           block ImlMvaEdit()
#endif DEF_MVA
ddEndDef()
RETURN b

FUNCTION MsgLniEdit()
RETURN "~š-Links                       "


FUNCTION PickBudSay(cIdCtr,cIdBud)
local cReturn := PickBud(cIdCtr,cIdBud)
RETURN NIL if cReturn == NIL
RETURN SayIdBud(cReturn)


FUNCTION ImpValue(cIdJnl,cIdDoc,bValue)
seek cIdJnl + cIdDoc in IMP
RETURN eval(bValue)

**
** MVI - mouvements imputation
**
FUNCTION oMvi
static b := NIL
if b != NIL ; RETURN b ; endif
define data b              ;
  name MVI                   ;
  pickflt    MviPickFilter() ;
  create     DDCREATE_FAIL ;
  predelete  MviPreDelete() ;
  wait       {|msk| MviWait(msk) }
  //  preedit    .f.  20071010 MVI->Blockiert darf man n„mlich
ddIndex b on  MVI->IdJnl+MVI->IdDoc+MVI->Line          // ORD_MVI_ID
ddIndex b on  MVI->IdPar+dtos(MVI->Date) ;
              text "Partner,Datum"                     // ORD_MVI_PARDATE
ddIndex b on  MVI->DC+MVI->IdBud+dtos(MVI->Date)       // ORD_MVI_BUDDATE
* ddIndex b on  MVI->IdPar+MVI->Match+dtos(MVI->Date) ;
*               text "Partner,Match"                     // ORD_MVI_PARMATCH
ddIndex b on  MVI->Match+dtos(MVI->Date) ;
              text "Match"                            // ORD_MVI_PARMATCH
ddIndex b on  MVI->DC+MVI->IdBud+MVI->IdJnl+MVI->IdDoc ;
              text "Artikel,Journal"                   // ORD_MVI_BUDJNL
ddIndex b on  MVI->IdPar+MVI->IdJnl+MVI->IdDoc ;
              text "Partner,Journal"                   // ORD_MVI_PARJNL
#ifdef DEF_PRJ
  ddIndex b on  MVI->IdPrj+dtos(MVI->Date)             // ORD_MVI_PRJ
#endif
ddIndex b on  MVI->IdPar2+dtos(MVI->Date) ;
              for ! empty(MVI->IdPar2) ;
              text "Empf„nger,Datum"                  // ORD_MVI_PAR2DATE
ddIndex b on  MVI->IdPar+MVI->EaMatch+dtos(MVI->Date) ;
              text "Partner,EA-Match"                 // ORD_MVI_EAMATCH
ddFld IdJnl    ,C, LenIdJnl(),0 when .f.
ddFld IdDoc    ,C, LEN_IDDOC,0  when .f.
ddFld IdCtr    ,C, LenIdCtr(),0 when .f.
ddFld Line     ,C, LEN_POS,0    when .f.
ddFld IdPar    ,C, LenIdPar(),0 when .f.
ddFld _ParName1,C,30,0  attrib V block ParField(MVI->IdPar,{||PAR->Firme})
ddFld NB1      ,C,30,0          when .f.
ddFld Mont     ,T, LenMont(),0  when .f. value MviMont()
ddFld Date     ,D, 8,0          when .f.
ddFld IdBud    ,C, LenIdBud(),0 block {|x| GsbIdBud(x) } when .f.
ddFld _BudName ,C, 40,0 attrib V ;
                        block padr(BudName(MVI->DC,MVI->IdBud),40)
ddFld BackMatch,C, LenIdJnl()+LEN_IDDOC+LEN_POS,0 picture PIC_ID ;
                   when .f.
ddFld Match    ,C, LenIdJnl()+LEN_IDDOC+LEN_POS,0 when .f.
ddFld IdPar2   ,C, LenIdPar(),0  GET_PAD when .f.
ddFld _ParName2,C,30,0  attrib V block ParField(MVI->IdPar2,{||PAR->Firme})
ddFld MontUs   ,T, LenMont(),0 GET_MONTANT when USRATTR_E $ UsrAttrib() ;
                               value MviMontUs()
ddFld _NB1orBud ,C,40,0 picture "@K@S28" attrib V ;
                      when .f.;
                      block {|| MviLibell() }
ddFld IdPrj    ,C, LenIdPrj(),0 picture PIC_ID ;
                               pick PickPrj(MVI->IdPrj) ;
                               when USRATTR_E $ UsrAttrib()
ddFld NB2      ,C,30,0 when .f. valid NB2Validate(MVI->NB2)
ddFld Compte1  ,C,LenBqe(),0 when .f.
ddFld _ParName ,C,25,0 attrib V block padr(Par2Name(.f.),25)
ddFld DC       ,C, 1,0 when .f.
ddFld _Debit ,T, LenMont(),0  attrib V block {|x| GsbMviDebit(x) }
ddFld _Credit,T, LenMont(),0  attrib V block {|x| GsbMviCredit(x) }
ddFld Date1    ,D, 8,0 when .f.
ddFld Date2    ,D, 8,0 when .f.
ddFld Periode  , C, LEN_PERIODE,0 picture PIC_ID when .f.
ddFld _ParAnrede ,C,25,0 attrib V block padr(Par2Name(.t.),25)
ddFld MontCtb  ,T, 10,0 GET_MONTANT when USRATTR_E $ UsrAttrib()
ddFld _Date3   ,D, 8,0  attrib V block {|x| MviDate3(x) }
ddFld EaMatch  ,C, LenIdJnl()+LEN_IDDOC,0 picture PIC_ID ;
                   when USRATTR_E $ UsrAttrib()
ddFld _Par1=2  ,C, 1,0 attrib V ;
                       block if(empty(MVI->IdPar2) .or. MVI->IdPar2==MVI->IdPar," ","")
ddFld Blockiert,C, 1,0 picture PIC_ID when UsrLevel() <= "B"
*
action b key K_SH_F4   prompt MnuArtPage() ;
                       block BudPage(MVI->DC, MVI->IdBud)
action b key K_SH_F5   prompt MnuParPage() block ParPage(MVI->IdPar)
action b key K_F9 prompt MSG012 ;
                  block ParMviEdit(MVI->IdPar) ;
                  when ! empty(MVI->IdPar)
action b key K_SH_F9 prompt MSG013 ;
                  block BudMviEdit(MVI->DC,MVI->IdBud) ;
                  when ! empty(MVI->IdBud)
action b key K_CTRL_F9 prompt MSG031 ;
                       block MatchMviEdit(MVI->IdPar,MVI->Match)
action b key K_ALT_F9  prompt MSG032 block ParMv2Edit(MVI->IdPar2) ;
                       when ! empty(MVI->IdPar2)
action b               prompt MSG033 block EaMviEdit(MVI->IdPar,MVI->EaMatch)
#ifdef DEF_MEMO
  action b key K_F12 prompt MnuMemoEdit() block MviMemoEdit()
#endif
#ifdef DEF_LNK
  action b             prompt MsgLniEdit() ;
                       block MviLniEdit(MVI->Match)
#endif DEF_LNK
ddEndDef()
RETURN b

FUNCTION MviMemoEdit
RETURN MnuDone() if ! DocExist(MVI->IdJnl,MVI->IdDoc)
select IMP
ImpGetMemo(.t.)
select MVI
RETURN MnuDone()

* FUNCTION MviMemoEdit
* RETURN MnuDone() if ! ParExist(MVI->IdPar)
* select PAR
* ParMemoEdit()
* select MVI
* RETURN MnuDone()

FUNCTION MviMontUs()
RETURN val(MVI->MontUs) if MVI->DC == DC_DEBIT
RETURN - val(MVI->MontUs)

FUNCTION MviMont()
RETURN val(MVI->Mont) if MVI->DC == DC_CREDIT
RETURN - val(MVI->Mont)

FUNCTION MviLibell()
RETURN MVI->NB1 if ! empty(MVI->NB1)
* if ! empty(MVI->IdBud)
  RETURN padr(BudName(MVI->DC,MVI->IdBud),40)
* endif
* RETURN space(40)

FUNCTION MviImpField(x)
if MVI->IdJnl + MVI->IdDoc != IMP->IdJnl + IMP->IdDoc
  seek MVI->IdJnl + MVI->IdDoc in IMP
endif
RETURN &x // IMP->Date2

FUNCTION MviDate3
if MVI->IdJnl + MVI->IdDoc != IMP->IdJnl + IMP->IdDoc
  seek MVI->IdJnl + MVI->IdDoc in IMP
endif
RETURN IMP->Date3

FUNCTION MviMemo
if MVI->IdJnl + MVI->IdDoc != IMP->IdJnl + IMP->IdDoc
  seek MVI->IdJnl + MVI->IdDoc in IMP
endif
RETURN IMP->Memo


**
** CTB - centralisation Imp
**
FUNCTION oCtb()
static b := NIL
if b != NIL ; RETURN b ; endif
define data b   ;
  name CTB
ddIndex b on CTB->DC + CTB->IdBud + CTB->Periode + CTB->IdCdc // ORD_CTB_BUD
ddIndex b on CTB->Periode + CTB->IdCdc + CTB->DC + CTB->IdBud // ORD_CTB_PERIODE
ddFld DC       ,C, 1,0          when USRATTR_E $ UsrAttrib()
ddFld IdBud    ,C, LenIdBud(),0 picture PIC_ID ;
                                block {|x| GsbIdBud(x) } ;
                                pick PickBudSay(CTB->DC,CTB->IdBud) ;
                                valid BudExist(CTB->DC,CTB->IdBud) ;
                                when USRATTR_E $ UsrAttrib()
ddFld Periode  ,C, LEN_PERIODE,0 when .f.
ddFld IdCdc    ,C, LEN_IDCDC,0   when .f.
ddFld Mont     ,T, LenMont(),0   GET_MONTANT ;
                                 when USRATTR_E $ UsrAttrib()
ddFld _Header  ,C, LenMntF(),0 attrib V ;
                   block CdcHeader(CTB->DC,CTB->IdCdc)
ddFld _Avail   ,T, LenMont(),0 attrib V ;
                   block ntom( ;
                     CtbBudAvail(), ;
                     DevDecPos(DevDefault(LastPeriode(CTB->Periode))) ;
                   )
ddEndDef()
RETURN b

FUNCTION LastPeriode(cPerCtr)
RETURN PerActive(ntod(val(cPerCtr),12,31))

**
** SAT - Befriedigungs-Tabelle - Table de satisfaction
**
FUNCTION oSat()
local b
define data b   ;
  name SAT      ;
  create SeqCreate(oSat()) ;
  attrib K ;
  postedit SatPostEdit()
  ddIndex b on SAT->Seq
ddFld Seq     ,C,  3,0  postedit {|x|GetSeq(x)}
ddFld IdJnl1    ,C, LenIdJnl(),0 picture PIC_ID ;
                    pick PickIdJnl( ;
                      "IMP", ;
                      SAT->IdJnl1, ;
                      JnlList({|j|j[JNL_IDGRJ] == SAT->IdGrj1}) ;
                    )
ddFld IdJnl2    ,C, LenIdJnl(),0 picture PIC_ID ;
                    pick PickIdJnl( ;
                      "IMP", ;
                      SAT->IdJnl2, ;
                      JnlList({|j|j[JNL_IDGRJ] == SAT->IdGrj2}) ;
                    )
ddFld Attrib    ,C, 5,0  picture PIC_ID pick PickSatAttr(SAT->Attrib)
ddFld _JnlName1  ,C, 30,0 attrib V block padr(JnlName(SAT->IdJnl1),30)
ddFld _JnlName2  ,C, 30,0 attrib V block padr(JnlName(SAT->IdJnl2),30)
ddFld IdGrj1    ,C, LEN_IDGRJ,0 picture PIC_ID ;
                    pick PickGrj(SAT->IdGrj1)
ddFld IdGrj2    ,C, LEN_IDGRJ,0 picture PIC_ID ;
                    pick PickGrj(SAT->IdGrj2)
ddFld DC       ,C, 1,0 picture PIC_ID valid DcValidate(SAT->DC)
ddFld Filter   ,C, 60,0
ddEndDef()
RETURN b


FUNCTION SatPostEdit()
local jnl
RETURN .f. if ! GrjExist(SAT->IdGrj1)
RETURN .f. if ! GrjExist(SAT->IdGrj2)
if ! empty(SAT->IdJnl1)
  RETURN .f. if ! JnlExist(SAT->IdJnl1)
endif
* if ! empty(SAT->IdJnl2)
*   RETURN .f. if ! JnlExist(SAT->IdJnl2)
*   if ! JNLATTR_A $ JnlAttrib(SAT->IdJnl2)
*     SetMsg( ;
*       SAT->IdJnl2 + " : Journalattribut A nicht gesetzt !" ;
*     )
*     RETURN .f.
*   endif
* endif
RETURN .t.


#endif DEF_IMP

#ifdef DEF_TRA

**
** TRA -
**
FUNCTION oTra
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name TRA                   ;
  predelete  TraPreDelete(b)     ;
  preedit    TraPreEdit()     ;
  postedit   TraPostEdit()    ;
  EditPrint  TraPrint()       ;
  wait       {|x| TraWait(x)}
ddIndex b on  TRA->IdJnl+TRA->IdDoc             // ORD_TRA_ID
ddFld IdDoc    ,C, LEN_IDDOC,0  picture PIC_ID when .f.
ddFld IdPar    ,C, LenIdPar(),0  GET_PAD ;
                        pick PickPar( ;
                          NIL, ;
                          TRA->IdPar) ;
                        valid TraParValidate()
ddFld _ParName ,C,30,0  attrib V block ParField(TRA->IdPar,{||PAR->Firme})
ddFld Date     ,D, 8,0 // valid TraDateValidate()
ddFld IdUsr    ,C,LenIdUsr(),0   picture PIC_ID pick PickUsr(TRA->IdUsr)
ddFld Etat     ,C, 1,0  picture "!"  when .f.
ddFld Scheck   ,C, 6,0
ddFld Mont     ,T, LenMont(),0 GET_MONTANT when .f.
ddFld IdDev    ,C, LEN_IDDEV,0 picture PIC_ID when .f. ;
                        pick PickDev(TRA->IdDev) ;
                        valid DevExist(TRA->IdDev)
ddFld IdJnl    ,C, LenIdJnl(),0 when .f. picture PIC_ID
ddFld Date2    ,D, 8,0
action b key K_CTRL_F2  prompt MnuClose() block TraDlgClose()
action b key K_ENTER prompt MnuInhalt() ;
                     block TraTrlEdit() ;
                     when ddRecStat() == RS_VALID
action b key K_SH_F5 prompt MnuParPage() block ParPage(TRA->IdPar)
action b key K_F9    prompt MSG012 block ParMviEdit(TRA->IdPar) ;
                                   when ! empty(TRA->IdPar)
action b key NIL     prompt MSG_TRASTORN block TraStorn()
ddEndDef()
RETURN b

** used in ARCHIV.ACT
** returns .t. if each TRL->Periode of this TRA is inside Periodenbereich
FUNCTION TraChkPeriode()
local lOkay := .f.
open area oTrl()
  lOkay := .t.
  softseek TRA->IdJnl+TRA->IdDoc
  do while !eof().and.TRL->IdJnl+TRL->IdDoc==TRA->IdJnl+TRA->IdDoc
    if ChkPeriode(TRL->Periode) != 0
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
RETURN lOkay


**
** TRL - Documents "imputation"
**
FUNCTION oTrl
static b := NIL
if b != NIL ; RETURN b ; endif
  define data b              ;
  name TRL                   ;
  postedit   TrlPostEdit()    ;
  preedit    TrlPreEdit()    ;
  editprint  TrlDlgPrint()    ;
  wait       {|x| TrlWait(x)}
ddIndex b on  TRL->IdJnl+TRL->IdDoc+TRL->Line       // ORD_TRL_ID
ddFld IdDoc    ,C, LEN_IDDOC,0  picture PIC_ID when .f.
ddFld Line     ,C, LEN_POS,0    GET_NUM
ddFld IdJnl2   ,C, LenIdJnl(),0 picture PIC_ID ;
                   pick PickIdJnl( ;
                     NIL,TRL->IdJnl2, ;
                     JnlList( {|jnl| TrlJnlIsAllowed( ;
                       TRA->IdJnl,jnl,TRL->DC ;
                     ) } ) ;
                   ) ;
                   valid TrlJnlValidate()
ddFld Mont     ,T, LenMont(),0 GET_DECPOS(DevDecPos(DevDefault(TRL->Periode))) ;
                               valid TrlMontValidate()
ddFld DC       ,C, 1,0 picture PIC_ID when .f.
ddFld IdTrt    ,C, LenIdTrt(),0  picture PIC_ID ;
                                 pick TrlPickTrt() ;
                                 valid TrlTrtValidate()
ddFld _TrtName ,C, 30,0 attrib V ;
                        block padr(TrtName(TRL->IdTrt),30)
ddFld IdPar2   ,C, LenIdPar(),0  GET_PAD ;
                   pick PickPar(NIL,TRL->IdPar2) ;
                   valid TrlPar2Validate()
ddFld _ParName2,C,30,0  attrib V block ParField(TRL->IdPar2,{||PAR->Firme})
ddFld Compte1  ,C,LenBqe(),0 ;
      postedit {|x| BqePostEdit(x) } ;
      valid BqeValidate(TRL->Compte1) ;
      pick TrlPickCompte()
ddFld NB1      ,C,30,0
ddFld NB2      ,C,30,0 valid NB2Validate(TRL->NB2)
ddFld Periode  , C, LEN_PERIODE,0 ;
                picture PIC_ID ;
                pick PickPer(TRL->Periode,TRL->IdJnl2,UserDate(),;
                  TRL->IdJnl);
                valid TrlPerValidate()
ddFld _Debit ,T, LenMont(),0  attrib V ;
                       when .t. ;
                       block {|x| GsbImlDebit(x) } ;
                       valid TrlMontValidate()
ddFld _Credit,T, LenMont(),0  attrib V ;
                       when .t. ;
                       block {|x| GsbImlCredit(x) } ;
                       valid TrlMontValidate()
ddFld BackMatch,C, LenIdJnl()+LEN_IDDOC+LEN_POS,0 picture PIC_ID ;
                   when USRATTR_E $ UsrAttrib()
ddFld Match    ,C, LenIdJnl()+LEN_IDDOC+LEN_POS,0 picture PIC_ID ;
                   when USRATTR_E $ UsrAttrib()
ddFld Attrib   ,C, 1,0 picture PIC_ID when .f.
ddFld IdBud    ,C, LenIdBud(),0 picture PIC_ID ;
                                block {|x| GsbIdBud(x) } ;
                                pick PickBudSay(TRL->DC,TRL->IdBud) ;
                                valid ValIdBud(TRL->DC,TRL->IdBud)
ddFld Etat     ,C, 1,0 picture PIC_ID when .f.
ddFld NB3      ,C,60,0
ddFld IdImp    ,C,LEN_IDDOC,0 when .f.
ddFld MontDev  ,T, LenMont(),0 ;
                   valid TrlDevValidate() ;
                   when !empty(TRL->IdDev) ;
                   pick PickNum(TRL->MontDev)
ddFld IdDev    , C, LEN_IDDEV,0 picture PIC_ID ;
                    pick PickDev(TRL->IdDev) ;
                    when empty(JnlIdDev(TRL->IdJnl2)) ;
                    valid TrlIdDevValidate()
ddFld IdJnl    ,C, LenIdJnl(),0 when .f. picture PIC_ID
ddFld IdPar    ,C, LenIdPar(),0  GET_PAD ;
                        pick PickPar( ;
                          NIL, ;
                          TRL->IdPar) ;
                        valid TrlParValidate()
ddFld Date2    ,D, 8,0 // valid TrlDate2Validate()
action b key K_F5    prompt MnuDocCopy() block TrlCopy()
action b key K_SH_F4   prompt MnuArtPage() ;
                       block BudPage(TRL->DC, TRL->IdBud)
action b key K_SH_F5 prompt MnuParPage() block TrlParPage()
action b key K_F9    prompt MSG012 block ParMviEdit(TRA->IdPar) ;
                                   when ! empty(TRL->IdPar2)
action b key K_SH_F9 prompt MSG013 ;
                     block BudMviEdit(TRL->DC,TRL->IdBud) ;
                     when ! empty(TRL->IdBud)
action b key K_ALT_F9  prompt MSG032 block ParMv2Edit(TRL->IdPar2) ;
                       when ! empty(TRL->IdPar2)
action b key K_ENTER block DocPage(TRL->IdJnl2,TRL->IdImp)
ddEndDef()
RETURN b


FUNCTION TrlJnlAllow(cIdJnl,cJnlList)
local i
for i := 1 to len(saTrlJnlAllow)
  if saTrlJnlAllow[i][1] == cIdJnl
    saTrlJnlAllow[i][2] := cJnlList
    RETURN .t.
  endif
next i
aadd(saTrlJnlAllow,{cIdJnl,cJnlList})
RETURN .t.

FUNCTION TrlJnlIsAllowed(cIdJnl,jnl,cDC)
local lOkay := .f.
local i
for i := 1 to len(saTrlJnlAllow)
  if saTrlJnlAllow[i][1] == cIdJnl
    if jnl[JNL_IDJNL] $ saTrlJnlAllow[i][2]
      lOkay := .t.
    endif
  endif
next i
RETURN .f. if ! lOkay
* 19990722 RETURN .f. if ! JNLATTR_C $ jnl[JNL_ATTRIB]
RETURN .t. if cDC == NIL
RETURN .t. if ! JNLATTR_F $ jnl[JNL_ATTRIB]
RETURN (cDC == jnl[JNL_DC])

FUNCTION TrlPickTrt
if empty(TRL->BackMatch)
  RETURN PickTrt(TRL->IdTrt,JnlDC(TRA->IdJnl)) if JNLATTR_F $ JnlAttrib(TRA->IdJnl)
  RETURN PickTrt(TRL->IdTrt)
endif
RETURN PickTrt(TRL->IdTrt,TRL->DC,TRL->IdBud)


FUNCTION TrlIdPar2() // 20090226
RETURN TRL->IdPar2 if ! empty(TRL->IdPar2)
RETURN TRL->IdPar if ! empty(TRL->IdPar) // 19990630
RETURN TRA->IdPar

FUNCTION TrlParPage()
RETURN ParPage(TrlIdPar2()) 

FUNCTION TrlPickCompte()       // 19990630
RETURN PickParCompte(TrlIdPar2(),TRL->Compte1) 

FUNCTION TrlCountry()
RETURN NIL // nat2iso(ParExpr(TrlIdPar2(),"PAR->Pays")) 

FUNCTION TrlPreEdit()
RETURN .f. if ! TraPreEdit()
if TRL->Etat == TRLSTAT_CTL .or. TRL->Etat == TRLSTAT_CTL_STORNIERT
  Warning("Verweigert. Diese Buchung ist bereits zentralisiert !")
  RETURN .f.
endif
if TRLATTR_P $ TRL->Attrib
  if ddRecLock()
    TRL->Attrib := strtran(TRL->Attrib,TRLATTR_P)
    unlock record
  endif
endif
RETURN .t.


* FUNCTION TrlPickTrt
* local cIdTrt := PickTrt(TRL->IdTrt,TRL->DC,TRL->IdBud)
* RETURN NIL if cIdTrt == NIL

**
** TRT -
**
FUNCTION oTrt
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name TRT ;
       attrib K ;
       postedit TrtPostEdit()
ddIndex b on  TRT->Seq
ddFld Seq     ,C,  3,0  postedit {|x|GetSeq(x)}
ddFld IdTrt   ,C, LenIdTrt(),0  picture PIC_ID
ddFld Name    ,C,30,0
ddFld DC      ,C, 1,0
ddFld IdBud   ,C, LenIdBud(),0 picture PIC_ID ;
              block {|x| GsbIdBud(x) } ;
              pick PickBudSay(TRT->DC,TRT->IdBud) ;
              valid BudExist(TRT->DC,TRT->IdBud)
ddFld IdJnl   ,C,LenIdJnl(),0  picture PIC_ID ;
              pick PickIdJnl(JNLALIAS_IMP,TRT->IdJnl)
ddFld Expr    ,C,120,0 picture "@K@S30"
ddFld IdBudI  ,C,LenIdBud(),0  picture PIC_ID ;
              block {|x|iif(x==NIL,SayIdBud(TRT->IdBudI),;
                TRT->IdBudI:=GetIdBud(x))} ;
              pick PickBudSay(DcInvert(TRT->DC),TRT->IdBudI) ;
              valid empty(TRT->IdBudI).or.BudExist(;
                DcInvert(TRT->DC),TRT->IdBudI)
ddFld IdTpl  ,C, LenIdTpl(),0 picture PIC_ID ;
               pick PickTpl(TPLTYPE_TRL,TRT->IdTpl)
* action b key K_F9    prompt MSG012 block ParMviEdit(TRA->IdPar) ;
*                                    when ! empty(TRA->IdPar)
ddEndDef()
RETURN b

FUNCTION TrtPostEdit()
local jnl
RETURN .f. if !BudExist(TRT->DC,TRT->IdBud)
RETURN .t. if empty(TRT->IdJnl)
RETURN .f. if (jnl := JnlLocate(TRT->IdJnl)) == NIL
RETURN .f. if !BudExist(DcInvert(TRT->DC),TRT->IdBudI)
if JNLATTR_P $ jnl[JNL_ATTRIB]
  RETURN !SetMsg(TRT->IdJnl + " : Journal-Attribut P wrde ignoriert !")
endif
* raus am 20060411
* if JNLATTR_B $ jnl[JNL_ATTRIB]
*   RETURN !SetMsg(TRT->IdJnl + " : Journal-Attribut B wrde ignoriert !")
* endif
RETURN .t.

FUNCTION TrlTrtValidate()
local trt := TrtLocate(TRL->IdTrt)
if trt == NIL
  SetMsg(TRL->IdTrt+" : unbekannte Transaktionsart." )
  RETURN .f.
endif
if !empty(TRL->Match+TRL->Backmatch)
  if !empty(TRL->DC).and.TRL->DC != trt[TRT_DC]
    SetMsg(TRL->IdTrt + " : Transaktionsart nicht erlaubt fr "+DcName(TRL->DC))
    RETURN .f.
  endif
endif
TRL->DC := trt[TRT_DC]
TRL->IdBud := trt[TRT_IDBUD]
* if empty(TRL->IdBud)
*   TRL->DC := trt[TRT_DC]
*   TRL->IdBud := trt[TRT_IDBUD]
* elseif TRL->IdBud != trt[TRT_IDBUD]
*   SetMsg("Falscher Transaktions-Code !")
*   RETURN .f.
* elseif TRL->DC != trt[TRT_DC]
*   SetMsg("Falscher Transaktions-Code !")
*   RETURN .f.
* endif
if ! empty(trt[TRT_EXPR])
  TRL->NB1 := &(trt[TRT_EXPR])
  if TRL->IdJnl == "SOZ "
    TRL->NB2 := TRL->NB1
  endif
endif
RETURN .t.

#endif DEF_TRA



#ifdef DEF_ALA

**
** ALA - Artikelkomponenten
**
FUNCTION oAla()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b name ALA                            ;
  postedit AlaPostEdit()             ;
  preedit  ArtPreEdit() ;
  predelete .t. // DDDEL_NOCONFIRM
ddIndex b on  ALA->IdArt1+ALA->Line     // ORD_ALA_ART1
ddIndex b on  ALA->IdArt2+ALA->IdArt1   // ORD_ALA_ART2
ddFld IdArt1   ,C, LenIdArt(),0  when indexord()!=1 ;
                   postedit {|x|GetIdArt(x)} ;
                   pick PickArt(ALA->IdArt1) ;
                   picture PicIdArt()
ddFld Line     ,C, LEN_POS,0 GET_NUM
ddFld IdArt2   ,C, LenIdArt(),0 when indexord()!=2 ;
               picture  PicIdArt() ;
               pick PickArt(ALA->IdArt2) ;
               postedit {|x|GetIdArt(x)} ;
               valid AlaIdValidate()
ddFld NB       ,C,40,0 picture "@K@S25"
ddFld Qte      ,C, LenQte(),0 GET_NUM ;
               valid AlaQteValidate()
ddFld Prix1    ,T,LenMont(),0 GET_MONTANT ;
               valid AlaP1Validate()
ddFld PrixR    ,T,LenMont(),0 GET_MONTANT ;
               valid AlaPRValidate()
ddFld _ArtName ,C,LenArtName(),0 attrib V ;
               block padr(ArtName(ALA->IdArt2),LenArtName())
action b key K_SH_F4      prompt MnuArtPage() ;
                          block ArtPage(ALA->IdArt2)
action b key K_F5         prompt MnuDocCopy() block AlaCopy(ART->IdArt)
action b key K_CTRL_F5    prompt MSG006 block AlaResetAll() ;
                          when ArtPreEdit()
* action b key K_CTRL_F5    block ArtPage(ALA->IdArt2)
action b key K_CTRL_RET   block ArtPage(if(indexord()==2,ALA->IdArt1,ALA->IdArt2))
action b key K_ALT_F7     prompt MsgMnuAttrib() ;
                          block AlaPickAttrib()
ddEndDef()
RETURN b

FUNCTION AlaResetAll()
local cIdArt := ART->IdArt
local lOkay := .f.
RETURN .f. if ! Confirm("Recalculer P.R. et P.V. (O/N) ?")
open area oAla(), oArt()
  lOkay := .t.
  softseek cIdArt
  do while lOkay .and. ! eof() .and. ALA->IdArt1 == cIdArt
    if ArtExist(ALA->IdArt2)
      if ddRecLock()
        ALA->PrixR := ntom(val(ART->PrixR) * qton1(ALA->Qte))
        ALA->Prix1 := ntom(val(ART->Prix1) * qton1(ALA->Qte))
        unlock record
      else
        exit
      endif
    else
      lOkay := .f.
    endif
    skip
  enddo
close area
ddRefreshAll()
RETURN lOkay // MnuDone()


FUNCTION AlaPostEdit()
RETURN .f. if ! ArtExist(ALA->IdArt2)
RETURN .t.

FUNCTION AlaIdValidate()
RETURN .f. if ! ArtExist(ALA->IdArt2)
ALA->Qte := ntoq(qton(ALA->Qte),ART->QteForm)
if !empty(ART->PrixR)
  ALA->PrixR := ntom(val(ART->PrixR) * qton1(ALA->Qte))
endif
if !empty(ART->Prix1)
  ALA->Prix1 := ntom(val(ART->Prix1) * qton1(ALA->Qte))
endif
RETURN ddMustScan()

FUNCTION AlaQteValidate()
RETURN .t. if ! ArtExist(ALA->IdArt2)
ALA->Qte := ntoq(qton(ALA->Qte),ART->QteForm)
if !empty(ART->PrixR)
  ALA->PrixR := ntom(val(ART->PrixR) * qton1(ALA->Qte))
endif
if !empty(ART->Prix1)
  ALA->Prix1 := ntom(val(ART->Prix1) * qton1(ALA->Qte))
endif
RETURN ddMustScan()

FUNCTION AlaPRValidate()
if empty(ALA->PrixR) .and. ArtExist(ALA->IdArt2)
  ALA->PrixR := ntom(val(ART->PrixR) * qton1(ALA->Qte))
endif
RETURN ddMustScan()

FUNCTION AlaP1Validate()
if empty(ALA->Prix1) .and. ArtExist(ALA->IdArt2)
  ALA->Prix1 := ntom(val(ART->Prix1) * qton1(ALA->Qte))
endif
RETURN ddMustScan()

* FUNCTION AlaCopy(cIdArt1)
* local cIdArt := PickArt(cIdArt1)
* RETURN MnuDone()

#endif DEF_ALA

#ifdef DEF_VNA

**
** VNA - mouvements imputation
**
FUNCTION oVna
static b := NIL
if b != NIL ; RETURN b ; endif
define data       b              ;
       name       VNA                   ;
       create     VnaCreate() ;
       preedit    USRATTR_E $ UsrAttrib() ;
       wait       {|x| VnaWait(x) }
ddIndex b on  VNA->IdJnl+VNA->IdDoc+VNA->Line          // ORD_VNA_ID
ddIndex b on  VNA->IdPar+VNA->Periode+dtos(VNA->Date) ;
              text "Partner,Periode,Datum"             // ORD_VNA_PARDATE
ddIndex b on  VNA->IdArt+dtos(VNA->Date)+VNA->IdPar  // ORD_VNA_ARTDATE
// der folgende Index ist unntz, aber eventuelle custom indexes will
// ich nicht umnummerieren.
ddIndex b on  VNA->IdArt+dtos(VNA->Date) ;
              text "Artikel+Datum"                     // ORD_VNA_ARTMATCH
ddFld IdJnl    ,C, LenIdJnl(),0 when .f.
ddFld IdDoc    ,C, LEN_IDDOC,0  when .f.
ddFld IdArt    ,C, LenIdArt(),0 block {|x| GsbIdArt(x) } ;
                   pick VnlPickArt() ;
                   picture PicIdArt() ;
                   when USRATTR_B $ UsrAttrib()
ddFld IdPar    ,C, LenIdPar(),0 when .f.
ddFld DC       ,C, 1,0 when .f.
ddFld Qte      ,C, LenQte(),0  when .f.
ddFld QteUs    ,C, LenQte(),0  when USRATTR_B $ UsrAttrib() ;
                   postedit {|x| ntoq(qton(x),VNA->QteForm)}
ddFld PrixU    ,T, LenMont(),0  when USRATTR_B $ UsrAttrib()
#ifdef DEF_VNLATTR
  ddFld Attrib  ,C, LEN_VNLATTR,0 picture PIC_ID ;
                    pick PickVnlAttrib(VNA->Attrib)
#else
ddFld _Debit   ,T, LenMont(),0  attrib V block {|x| GsbVnaDebit(x) } ;
                   value DcVal(DC_DEBIT)
#endif
ddFld _Credit  ,T, LenMont(),0  attrib V block {|x| GsbVnaCredit(x) } ;
                   value DcVal(DC_CREDIT)
ddFld Periode  , C, LEN_PERIODE,0 picture PIC_ID
ddFld Date     ,D, 8,0  when USRATTR_B $ UsrAttrib()
ddFld NB1      ,C,LenVnlName(),0  when USRATTR_B $ UsrAttrib()
ddFld _ArtRef  ,C, LenArtRef(),0 attrib V ;
                   block ArtField(VNA->IdArt,{||ART->Ref})
ddFld Line     ,C, LEN_POS,0 when .f.
* ddFld Match    ,C, LenIdJnl()+LEN_IDDOC+LEN_POS,0 when .f.
ddFld _ObjName ,C, LenVnlName(),0 attrib V ;
                        block {|| padr(VnaObjName(),LenVnlName()) }
ddFld _ParName ,C, 30,0 attrib V ;
                        block padr(ParName(VNA->IdPar),30)
ddFld _NB1orArt ,C,LenVnlName(),0 picture "@K@S28" attrib V ;
                      block {|| VnaLibell() }
ddFld Memo     ,M, 10,0
ddFld Satis    ,C, 1,0 when USRATTR_B $ UsrAttrib()
ddFld Code     ,C, 1,0 picture PIC_ID when USRATTR_B $ UsrAttrib()
ddFld QteForm  ,C, 1,0 pick PickQteForm(VNA->QteForm)
#ifdef DEF_INT
  ddFld IdInt     ,C, LenIdInt(), 0
  ddFld QteStat   ,C, LenQte(), 0 GET_NUM
#else
  ddFld IdInt   ,C, 0, 0 attrib H
  ddFld QteStat ,C, 0, 0 attrib H
#endif
#ifdef DEF_PROVI
  ddFld PrixL   ,T,LenMont(),0 ;
                when USRATTR_B $ UsrAttrib()
#else
  ddFld PrixL  ,C,0,0 attrib H
#endif DEF_PROVI
* #ifdef DEF_NACHLASS
* #else
* #endif DEF_NACHLASS
action b key K_SH_F4   prompt MnuArtPage() block ArtPage(VNA->IdArt)
action b key K_SH_F5   prompt MnuParPage() block ParPage(VNA->IdPar)
* action b key K_ALT_F6   prompt MSG_VNAAUTO ;
*          block ParVnaAuto(VNA->IdPar,VNA->IdJnl,VNA->NB1)
* action b key K_CTRL_F9 prompt MSG031 ;
*                        block MatchVnaEdit(VNA->IdArt,VNA->Match)
action b key K_SH_F9 prompt MSG013 ;
                  block ArtVnaEdit(VNA->IdArt) ;
                  when ! empty(VNA->IdArt)
action b key K_F12     prompt MnuMemoEdit() ;
                       block VnaMemoEdit()
action b key K_ENTER   block DocPage(VNA->IdJnl,VNA->IdDoc)
#ifndef DEF_ART_REF
  ddFldRemove("_ArtRef")
#endif DEF_ART_REF
*#ifdef DEF_ACT
*  if IsCustData("VNA") ; ActExec("VNA") ; endif
*#endif DEF_ACT
ddEndDef()
RETURN b

* FUNCTION VnaDelete()
* RETURN DDDEL_FAIL if ! VnaPreDelete()
* RETURN DDDEL_CONFIRM

* FUNCTION VnaPreEdit()
* * RETURN .f. if ! PerIsOpen(VNA->Periode,VNA->IdJnl)
* RETURN .t. if USRATTR_S $ UsrAttrib()
* * Warning(MsgNoAccess(),NIL,"WRN028")
* RETURN .f.

**
** TRN - Befriedigungstabelle Automatik-Fakturierung
**
FUNCTION oTrn()
local b
define data b   ;
       name TRN      ;
       create SeqCreate(oTrn()) ;
       attrib K ;
       postedit TrnPostEdit()
ddIndex b on TRN->Seq
ddFld Seq     ,C,  3,0  postedit {|x|GetSeq(x)}
ddFld DC        ,C, 1,0 picture PIC_ID // valid DcValidate(TRN->DC)
ddFld IdJnl1    ,C, LenIdJnl(),0 picture PIC_ID ;
                    pick PickIdJnl( ;
                      "IMP", ;
                      TRN->IdJnl1, ;
                      JnlList({|j|j[JNL_IDGRJ] == TRN->IdGrj1}) ;
                    )
ddFld IdJnl2    ,C, LenIdJnl(),0 picture PIC_ID ;
                    pick PickIdJnl( ;
                      "IMP", ;
                      TRN->IdJnl2, ;
                      JnlList({|j|j[JNL_IDGRJ] == TRN->IdGrj2}) ;
                    )
ddFld Attrib    ,C, 5,0  picture PIC_ID pick PickTrnAttr(TRN->Attrib)
ddFld _JnlName1 ,C, 30,0 attrib V block padr(JnlName(TRN->IdJnl1),30)
ddFld _JnlName2 ,C, 30,0 attrib V block padr(JnlName(TRN->IdJnl2),30)
ddFld IdGrj1    ,C, LEN_IDGRJ,0 picture PIC_ID ;
                    pick PickGrj(TRN->IdGrj1)
ddFld IdGrj2    ,C, LEN_IDGRJ,0 picture PIC_ID ;
                    pick PickGrj(TRN->IdGrj2)
#ifdef DEF_CARRY
  ddFld Carry     ,C, 50,0
#endif DEF_CARRY
ddEndDef()
RETURN b


FUNCTION TrnPostEdit()
* if ! empty(TRN->IdGrj1)
*   RETURN .f. if ! GrjExist(TRN->IdGrj1)
* endif
*  RETURN .f. if ! GrjExist(TRN->IdGrj2)
if ! empty(TRN->IdJnl1)
  RETURN .f. if ! JnlExist(TRN->IdJnl1)
  TRN->IdGrj1 := JnlIdGrj(TRN->IdJnl1)
endif
if ! empty(TRN->IdJnl2)
  RETURN .f. if ! JnlExist(TRN->IdJnl2)
  TRN->IdGrj2 := JnlIdGrj(TRN->IdJnl2)
endif
* if TRNATTR_A $ TRN->Attrib
*   RETURN .f. if ! JnlExist(TRN->IdJnl2)
* endif
RETURN .t.

#else

FUNCTION oVna ; RETURN NIL

#endif DEF_VNA


#ifdef DEF_STK

**
** QTS - quantit‚s en stock
**
*FUNCTION oQts()
*static b := NIL
*if b != NIL ; RETURN b ; endif
*define data b name QTS
*ddIndex b on QTS->IdArt + QTS->IdStk
*ddFld IdArt    ,C, LenIdArt(),0  when .f.
*ddFld IdStk    ,C, LEN_IDSTK,0   when .f.
*ddFld Qte      ,C, LenQte(),0    when USRATTR_S $ UsrAttrib()
*ddFld Mont     ,C, LenMont(),0   when USRATTR_S $ UsrAttrib() ;
*                                 value val(QTS->Mont)
*ddFld _Name    ,C, 30,0   attrib V ;
*                   block padr(StkName(QTS->IdStk),30)
*RETURN b

#endif DEF_STK


#ifdef DEF_JNL

FUNCTION JnlExist(cIdJnl)
RETURN .t. if JnlLocate(cIdJnl) != NIL
SetMsg(cIdJnl + MsgJnlExist() ) // " : unbekanntes Journal !")
RETURN .f.

FUNCTION MsgJnlExist()
#ifdef LG_GERMAN
RETURN " : unbekanntes Journal !"
#else
RETURN " : Journal inconnu !"
#endif


FUNCTION GrjExist(cIdGrj)
RETURN .t. if GrjLocate(cIdGrj) != NIL
SetMsg(cIdGrj + " : unbekannte Journalgruppe !")
RETURN .f.

#endif DEF_JNL

#ifdef DEF_ODS

**
** ODS - Documents financiers
**
FUNCTION oOds()
* local b
static b := NIL
if b != NIL ; RETURN b ; endif
define data b                 ;
  name ODS                    ;
  preedit    OdsPreEdit()     ;
  postedit   OdsPostEdit()    ;
  predelete  OdsPreDelete()      ;
  editprint  OdsPrint()       ;
  wait       {|x| OdsWait(x)}
ddIndex b on  ODS->IdJnl+ODS->IdDoc ;
              format {|x| ;
                left(x,LenIdJnl())+GetIdDoc( ;
                  substr(x,LenIdJnl()+1),;
                  JnlLocate(left(x,LenIdJnl()));
              )}            // ORD_VEN_ID
ddIndex b on  ODS->IdPar+ODS->IdJnl+ODS->IdDoc ;
              format {|x| ;
                left(x,LenIdPar()+LenIdJnl())+ ;
                GetIdDoc( ;
                  substr(x,LenIdPar()+LenIdJnl()+1), ;
                  JnlLocate(substr(x,LenIdPar()+1,LenIdJnl())) ;
                ) ;
              }            // ORD_ODS_PAR
ddFld IdJnl   ,C, LenIdJnl(),0  when .f.
ddFld IdDoc   ,C, LenIdDoc(),0  when .f.
ddFld IdPar   ,C, LenIdPar(),0  GET_PAD ;
                        pick PickPar( ;
                          NIL, ;
                          ODS->IdPar)
ddFld _ParName ,C,30,0  attrib V block padr(ParName(ODS->IdPar),30)
ddFld Date    ,D,  8,0 // valid PerChkDate(ODS->Periode,ODS->Date)
ddFld Remarq  ,C, 30,0
ddFld _Status  , C,10,0 attrib V block EtatText(ODS->Etat)
ddFld Etat    ,C,  1,0  when .f. picture "!"
ddFld Periode ,C,  LEN_PERIODE,0  picture PIC_ID ;
                   pick PickPer(ODS->Periode,ODS->IdJnl)
ddFld Mont    ,T, LenMont(),0  GET_MONTANT
ddFld Memo    ,M, 10,0
action b key K_ENTER   prompt MnuInhalt() block OdsOdlEdit()
action b key K_CTRL_F2 prompt MnuClose() block OdsDlgClose()
#ifdef DEF_MVS
  action b key K_CTRL_F9 prompt "Lagerhistorik Dokument [Ctrl-F9]" ; // MnuDocHstEdit() ;
         block DocMvsEdit(ODS->IdJnl,ODS->IdDoc)
#endif DEF_MVS
action b key K_F12     prompt MnuMemoEdit() block OdsMemoEdit()
ddEndDef()
RETURN b

**
** ODL - D‚tail journaux financiers
**
FUNCTION oOdl()
* local b
static b := NIL
RETURN b if b != NIL
define data b           ;
  name ODL                   ;
  postedit OdlPostEdit() ;
  preedit OdsPreEdit() ;
  predelete .t. // DDDEL_CONFIRM
ddIndex b on ODL->IdJnl+ODL->IdDoc+ODL->Line            // ORD_ODL_DOC
ddIndex b on ODL->IdArt+ODL->IdJnl+ODL->IdDoc+ODL->Line // ORD_ODL_ART
ddFld IdJnl    ,C, LenIdJnl(),0  when .f.
ddFld IdDoc    ,C, LenIdDoc(),0  when .f.
ddFld Line     ,C, LEN_POS,0
ddFld IdArt    ,C, LenIdArt(),0 picture  PicIdArt() ;
                      pick PickArt(ODL->IdArt) ;
                      postedit {|x|GetIdArt(x)} ;
                      valid OdlIdValidate()
ddFld _ArtName ,C,LenArtName(),0 attrib V ;
                                 block padr(ArtName(ODL->IdArt),LenArtName())
ddFld DC       ,C, 1,0  picture "!" valid DcValidate(ODL->DC)
ddFld Qte      ,C, LenQte(),0 GET_NUM valid OdlQteValidate()
ddFld Mont     ,T, LenMont(),0  GET_MONTANT
ddFld _Debit   ,C, LenQte(),0  GET_NUM attrib V when .t. ;
                               block {|x| GsbQteDebit(x) } ;
                               valid OdlQteValidate()
ddFld _Credit  ,C, LenQte(),0  GET_NUM attrib V when .t. ;
                               block {|x| GsbQteCredit(x) } ;
                               valid OdlQteValidate()
ddFld _PrixU   ,T, LenMont(),0 attrib V when .t. ;
                        block {|x|GsbOdlPU(x)}
ddFld Remarq   ,C,30,0
#ifdef DEF_ART_REF
  ddFld _ArtRef ,C,LenArtRef(),0 attrib V ;
                picture PIC_ID ;
                when OdsPreEdit() ;
                block {|x| OdlArtRef(x)} ;
                valid OdlIdValidate()
#else
  ddFld _ArtRef   ,C, 0,0 attrib H
#endif
action b key K_SH_F4     prompt MnuArtPage() block ArtPage(ODL->IdArt)
action b key K_CTRL_RET  block ArtPage(ODL->IdArt)
#ifdef DEF_CTS
  action b key K_SH_F6     block ArtCtsEdit(ODL->IdArt)
#endif DEF_CTS
// action b key K_F5        prompt MnuDocCopy() block OdlGenerate()
action b key K_F5        prompt MnuDocCopy() block OdlCopy()
ddEndDef()
RETURN b

FUNCTION OdlPostEdit()
RETURN .f. if ! ArtExist(ODL->IdArt)
if empty(ODL->Qte)
  #ifdef LG_GERMAN
    SetMsg("Menge : darf nicht leer sein.")
  #else
    SetMsg("Qt‚ : ce champ ne doit pas ˆtre vide.")
  #endif
  RETURN .f.
endif
if empty(ODL->Mont)
  ODL->Mont := ntom(ArtPrixR(ODS->Periode) * qton(ODL->Qte))
  // ODL->Mont := ntom(val(ART->PrixR) * qton(ODL->Qte))
endif
RETURN .t.

FUNCTION OdlIdValidate()
local a := {}
RETURN .t. if ! ArtExist(ODL->IdArt)
*if ! empty(ODL->Qte)
ODL->Mont := ntom(ArtPrixR(ODS->Periode) * qton1(ODL->Qte))
*endif
// ODL->Mont := ntom(val(ART->PrixR) * qton1(ODL->Qte))
#ifdef DEF_ALA
  OdlAlaGenerate()
#endif
RETURN .t.

FUNCTION OdlQteValidate()
RETURN .t. if ! ArtExist(ODL->IdArt)
ODL->Qte  := ntoq(qton(ODL->Qte),ART->QteForm)
ODL->Mont := ntom(ArtPrixR(ODS->Periode) * qton(ODL->Qte))
// ODL->Mont := ntom(val(ART->PrixR) * qton(ODL->Qte))
#ifdef DEF_ALA
  OdlAlaGenerate()
#endif
RETURN .t.

FUNCTION GsbOdlPU(x)
if x == NIL
  RETURN ntom(val(ODL->Mont)/qton(ODL->Qte),ArtPuDecPos())
endif
ODL->Mont := ntom(val(x)*qton(ODL->Qte))
RETURN NIL


#ifdef DEF_ALA

FUNCTION OdlAlaGenerate()
local nQte := qton(ODL->Qte)
local cDC  := DcInvert(ODL->DC)
local cLine := NextNum(ODL->Line)
local lOkay := .f.
local cIdArt := ODL->IdArt
local nRecNo := recno()
local nAdded := 0
RETURN .t. if !OdlIsComposed()
RETURN .t. if empty(ODL->Qte)
RETURN .t. if empty(ODL->IdArt)
** 19990830 : Test, ob schon mal generiert wurde
seek ODL->IdJnl+ODL->IdDoc+cLine
if found()
  goto nRecNo
  SetMsg("Komponenten wurden nicht eingefgt.")
  RETURN .t.
endif
goto nRecNo
open area oAla(), oArt()
  lOkay := .t.
  softseek cIdArt
  do while ! eof() .and. ALA->IdArt1 == cIdArt
    if ArtExist(ALA->IdArt2)
      select ODL
      if dbAddRec()
        ODL->IdJnl := ODS->IdJnl
        ODL->IdDoc := ODS->IdDoc
        ODL->IdArt := ALA->IdArt2
        ODL->Qte   := ntoq(qton(ALA->Qte)*nQte,ART->QteForm)
        ODL->DC    := cDC
        ODL->Line  := cLine
        unlock record
        ddScrollCursor()
        cLine := NextNum(cLine)
        nAdded += 1
      else
        lOkay := .f.
        exit
      endif
      select ALA
    else
      lOkay := .f.
      exit
    endif
    skip
  enddo
close area
if ! lOkay
  SetMsg("OdlAlaGenerate() failed !")
endif
if nAdded > 0
  SetMsg(ntrim(nAdded)+" Komponenten eingefgt")
  ddRefreshAll()
  * ddSendKey(K_ALT_F5)
*else
*  goto nRecNo
endif
RETURN lOkay

* FUNCTION MyTest()
* ODL->Line := ODL->Line
* RETURN .t.

FUNCTION MyTest()
local nRecno
open area oArt()
  go top
  if ddRecLock()
    nRecNo := recno()
    seek repl("0",LenIdArt())
    open area oPar()
      // do something
    close area
    goto nRecNo
    ART->IdArt:=ART->IdArt  // here it happens
    unlock record
  endif
close area
RETURN .t.

#endif DEF_ALA



#ifdef DEF_ART_REF

** „hnlich wie VnlArtRef()

FUNCTION OdlArtRef(x)
local cIdArt
if x == NIL
  RETURN ArtField(left(FIELD->IdArt,LenIdArt()), {|| ART->Ref} )
endif
open area oArt()
  ddSetOrder(ORD_ART_REF)
  x := RefTrunc(x)
  seek x
  if eof()
    cIdArt := PickArt("",NIL,NIL,x)
  else
    cIdArt := ART->IdArt
    ** neu 19990427 : Wenn ART->Ref nicht eindeutig ist.
    skip
    if RefTrunc(ART->Ref) == x .and. !eof()
      cIdArt := PickArt("",NIL,NIL,x)
    endif
    ** ende neu 19990427
  endif
close area
if cIdArt != NIL
  FIELD->IdArt := cIdArt
endif
RETURN NIL

#endif ART_REF

#endif DEF_ODS

#ifdef DEF_DEV

**
**
**
FUNCTION DcVal(cDC,cIdDev,nVal)
default nVal to val(FIELD->Mont)
if cIdDev != NIL
  if DevDefault(FIELD->Periode) != cIdDev
    nVal := Db2Dev(cIdDev,FIELD->Periode,nVal)
    * nVal := nVal / val(DevCours(cIdDev,FIELD->Periode))
  endif
endif
RETURN nVal if FIELD->DC == cDC
RETURN - nVal

FUNCTION DevVal(cIdDev,nVal,cPeriode)
default nVal to val(FIELD->Mont)
default cPeriode to FIELD->Periode
if DevDefault(cPeriode) != cIdDev
  nVal := Db2Dev(cIdDev,cPeriode,nVal)
  * nVal := nVal / val(DevCours(cIdDev,cPeriode))
endif
RETURN nVal

#endif DEF_DEV

FUNCTION PickParCompte(cIdPar,cStart)
local a := {}
RETURN NIL if ! ParExist(cIdPar)
if ! empty(PAR->Compte1) ; aadd(a, PAR->Compte1) ; endif
if ! empty(PAR->Compte2) ; aadd(a, PAR->Compte2) ; endif
#ifdef DEF_TRA
  if ! empty(PAR->CptSysi) ; aadd(a, PAR->CptSysi) ; endif
#endif DEF_TRA
RETURN ArrayPick(a,"Auswahl Kontonummer",cStart)



FUNCTION PickStatus(cStart)
local a := {}
aadd(a, DocStatNew()+" "+EtatText(DocStatNew()))
aadd(a, DocStatOpen()+" "+EtatText(DocStatOpen()))
aadd(a, DocStatClosed()+" "+EtatText(DocStatClosed()))
aadd(a, DocStatError()+" "+EtatText(DocStatError()))
RETURN ArrayPick(a,;
  utr("Document status","Dokumentstatus","Etat du document"),cStart)
