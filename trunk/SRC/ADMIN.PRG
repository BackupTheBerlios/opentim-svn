** ADMIN.PRG
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

#ifdef LG_FRENCH
  static MSG001 := "Masque pour correspondance   "
  static MSG021 := " existe dÇjÖ."
  static MSG023 := "Mode de sÇlection articles "
  static MSG031 := "le compte "
  static MSG032 := "Tapez O pour renommer "
  static MSG033 := "le partenaire "
  static MSG034 := " en "
  static MSG042 := "Paramätres base de donnÇes"
  * static MSG058 := "Journaux"
  static MSG063 := "Conversion des donnÇes "

  static MSG079 := "Langues 1,2,3,4 "
  static MSG080 := "Pays "
  static MSG096 := "Renommer compte gÇnÇral"
  static MSG100 := "Dossier "
#endif
#ifdef LG_GERMAN
  static MSG001 := "Maske fÅr Korrespondenz "
  static MSG021 := " existiert bereits."
  static MSG023 := "Modus fÅr Artikelauswahl "
  static MSG031 := "das Konto "
  static MSG032 := "DrÅcken Sie J, um "
  static MSG033 := "den Partner "
  static MSG034 := " umzunennen in "
  static MSG042 := "Datenbankparameter"
  * static MSG058 := "Journale"
  static MSG063 := "Konvertierung der Daten "


  static MSG079 := "Sprachenverteilung "
  static MSG080 := "Land "
  static MSG096 := "Generalkonto umbenennen"
  static MSG100 := "Datenbank "

#endif
#ifdef LG_EN
  static MSG001 := "Template for correspondence "
  static MSG021 := " already exists."
  static MSG023 := "Selection mod Products "
  static MSG031 := ""
  static MSG032 := "Answer Y to replace identification "
  static MSG033 := ""
  static MSG034 := " with "
  static MSG042 := "Database parameters"
  * static MSG058 := "Journale"
  static MSG063 := "Convert database "
  static MSG079 := "Language distribution "
  static MSG080 := "Country "
  static MSG096 := "Rename General Account"
  static MSG100 := "Database "
#endif





**
** STATIC_SECTION global static variables
**
#ifdef DEF_KITZ
static sbKrgKrmPrix := {|| 0 }
#endif DEF_KITZ

#ifdef DEF_RSV
static sbRsiRsvColumn := {||NIL}
#endif DEF_RSV

* Beispiel tim.dbi Luc:
* OpenMail {|cToAddr,cToName,cSubject,cBody| \
*   mailto_tb("C:\Program Files\Mozilla Thunderbird\thunderbird.exe",\
*   cToAddr,cToName,cSubject,cBody)}
static sbOpenMail := {|cToAddr,cToName,cSubject,cBody,cAttach| ;
  mailto(cToAddr,cToName,cSubject,cBody,cAttach)}
static scWebBrowser := NIL
static scOpenCsv := NIL

static slFixY2K := .t.
static sbParName := {|| trim1(PAR->Allo) + trim(PAR->Firme) }
static sbParLogo := {|| "" }
// iif(empty(PAR->NB2),"",AppPath()+"\photos\"+trim(PAR->NB2)+".jpg")
static sbParCity := {||PlzString(PAR->Pays,PAR->CP)}
static saDevDefault := { "BEF", "EUR" }
// static sbDevToggle := {|| .f. }
static scPerToggle := "A200"
static scHstStart := NIL
static sbPerDevFixed := {|| .f. }

#ifdef DEF_JNL
  static sbPrePerAppend := {|cPeriode| !SetMsg(cPeriode+MsgPerExist())}
  * static sbPerYear := {|cPeriode| ;
  *   padr(left(cPeriode,LEN_YEAR),LEN_PERIODE,CHR_255) ;
  * }
  static sbPerYear := {|cPeriode| ;
    padr(left(cPeriode,LEN_YEAR),LEN_PERIODE,"z") ;
  }
#endif DEF_JNL

#ifdef DEF_TRA
  static sbTrlCompte := {|| PAR->Compte1 }
#endif DEF_TRA

#ifdef DEF_IMP
  static sbZauComPrefix := {||""}
  static sbImlCompte := {|| PAR->Compte1 }
#endif DEF_IMP


#ifdef DEF_PLP
  static sbParSexe := {|cIdPar| DbfPeek(oPar(),cIdPar,"PAR->Sexe",NIL) }
#endif DEF_PLP

#ifdef DEF_VENREMISE
  static sbVenRemise := {|| (100-val(VEN->Remise)) / 100 }
#endif DEF_VENREMISE
* static snLenIdLng  := 1
static snLenQte    := 6
static snLenTel    := 18
* static snLenQteBig := 8
static snLenIdDoc := 6
static snLenIdCtr := 1
static snLenIdTpl := 6
static slUseAdsDbe := .t.
#ifdef __XPP__
  #include "COLLAT.CH"
  static snCollation := COLLAT_GERMAN
#endif __XPP__
#ifdef DEF_DBF
  static scUseDbe := "DBFNTX"
#else
  static scUseDbe := "FOXCDX"
#endif
static snLenIdArt   := 6
#ifdef DEF_INT
  static snLenIdInt   := 8
#endif DEF_INT

* #ifdef DEF_LGT
*   static snLenIdLgt   := 3
* #endif DEF_LGT

static snLenParAttrib := 5
static snLenArtName := 40
static snLenGenName := 40
static snLenParName := 35
static snLenGraName := 40
static slQteEmpty := .t.
static sbVnlAnzahl := {||1}
static saOnMainMenu := {}
static sbOnParSatisfy := {||.t.}
#ifdef DEF_RUN
  static snLenIdCty := 5
  static snLenIdRal := 6
  static snLenIdCat := 6
  static snLenIdClb := 6
  static snLenIdEqu := 6
  static slAgeByYear := .f.
#endif DEF_RUN
#ifdef DEF_FAB
  static snLenIdFab := 2
#endif DEF_FAB
#ifdef DEF_SER
  static snLenIdSer   := 10
  static scIdSerDefault := "''"
#endif DEF_SER
* #ifdef DEF_PLS
#ifdef DEF_ODS
  static saOnOdlPreClose := {}
#endif DEF_ODS
#ifdef DEF_TAX
  static sbTolerateTax := {||.f.}
#endif
#ifdef DEF_VEN
  static sbcNafAttr := {|cIdJnl|"ID"} // NAFATTR_I+NAFATTR_D
  static sbVnlQteBase := {||qton1(FIELD->Qte)}
  static sbQteValidate := {|| StdQteValidate() }
  static snLenLstVen    := 30
  static snLenVnlName := 40
  * static sbOnVenCreate := {||.t.}
  static saOnVnlClose := {} // either NIL or an expression to be
                                 // executed when close was successful.
  static sbOnVenClose := {||.t.}
  static sbVenLibell := {||VEN->NB1}
  static sbAfterVenClose := {}
  * static sbOnVenPostEdit := {||.t.}
  * static saVenPostEdit := NIL
  * static sbVnlIdValidate := {||.t.}
  static sbPreVnlDelete := {||.t.}
  static sbVnlTotBegin := {||.f.}
  static sbVnlAqtFill := {|nQte,nQteStat| .t. }
  static sbVnlIsAqt := {|| .f. }

  #ifdef DEF_HST
    static sbOnHstCtrMix := {||.t.}
    static sbHstMatch := {|| HST->Match }
    static sbHstTestTolerance := {|| 0.001 }
    static sbVenHstMatch := {||if( ;
      empty(VEN->Match),VEN->IdJnl+VEN->IdDoc,VEN->Match ;
    )}
  #else
    static sbVenHstMatch := {||VEN->IdJnl+VEN->IdDoc}
  #endif
  #ifdef DEF_VNA
    * static sbVnlVnaMatch := {||if( ;
    *   empty(FIELD->Match), ;
    *   FIELD->IdJnl+FIELD->IdDoc+FIELD->Line, ;
    *   FIELD->Match ;
    * )}
  #endif
  #ifdef DEF_IPB
    static sbArtIdGen := {|cIdCtr|StdArtIdGen(cIdCtr)}
  #endif DEF_IPB
  #ifdef DEF_PRIXR
    static sbVnlPrixR := {|| ;
      ntom( VenDb2Dev(ArtPrixR(VEN->Periode)), VnlPuDecPos() ) ;
    }
    *static sbVnlPrixR := {|| ;
    *  ntom( VenDb2Dev(val(ART->PrixR)), VnlPuDecPos() ) ;
    *}
  #endif DEF_PRIXR
  static saVnlPreClose := NIL
  static saVnlIdValidate := NIL
  static saVnlVarCollect := NIL
  * static sbOnVenParValidate := {||.t.}
  static saVenParValidate := NIL
  static sbVenMfcDefault := {||ParMfcDefault(VEN->IdJnl)}
  * static sbDoParMfcDefault := {||.t.}
  #ifdef DEF_INT
    static sbVnlIntDefault := {|| ;
      if(FIELD->Code==LNCODE_GEN.or.empty(ART->IdInt),repl("?",LenIdInt()),ART->IdInt) ;
    }
  #endif DEF_INT
#endif DEF_VEN
#ifdef DEF_VNLATTR
  static sbVnlHideDetail := {||VNLATTR_D $ FIELD->Attrib}
  * StandardmÑ·ig gibt es keine Module
  static sbVnlIsModule := {||.f.} // left(VNL->IdArt,1)=="M"}
  static sbVnlIsLinked := {||.f.}
  static sbOdlIsComposed := {||.t.}
  static sxDoModPrix1 := ".t."
  static sxDoAlaDetail := ".t."
  static sbVnlIsDetail := {|| .f. }
  * nur bei Eutaser muss es wie folgt sein.
  * Herr Kettni· hatte dadurch das Problem, dass
  * D-Zeilen nicht in den Zwischensummen berÅcksichtigt wurden.
  * static sbVnlIsDetail := {|| ;
  *   VNLATTR_D $ FIELD->Attrib .or. VNLATTR_H $ FIELD->Attrib ;
  * }
#endif DEF_VNLATTR
#ifdef DEF_MULT
  static saVnlRoundError := NIL
#endif DEF_MULT
  static saTimTestAllow := {}
#ifdef DEF_VNA
  static sbVnaMatch := {||""}
  static sbParVnaStop := {|jnl|PARATTR_S $ PAR->Attrib.and.JnlDoHst(jnl)}
  * static sblPreVnaSuggest := {|dDate|.t.}
  * static sxVnaCopyFilter := "'.t.'"
  static saOnVnaGenerate := NIL
  static xlVnaMustEdit := {||.f.}
  static xlPreVnaUndo := ;
    "(qton1(VNA->QteUs)==qton1(VNA->Qte).and.empty(VNA->Satis)).or.!SetMsg(MsgVnaUndo())"
  static sbPreVnaCollect := {|| IsArtCode(FIELD->Code) }
  static sbVnlVnaCount := {|| 1 }
  static saOnVnaSuggest := {}
#endif DEF_VNA
#ifdef DEF_FIN
  static saFnlFillFilter := {}
  static snLenFnlName := 30
  static saPreFnlAppend := {}
  static sxlCheckFinSolde := {||.t.}
  static sxnFinTolerance := {||DevTolerance(FIN->IdDev)}
#endif DEF_FIN
#ifdef DEF_PLS
  static snLenIdPls := LEN_IDPLS
  static snLenMbrRemark := 50
#endif DEF_PLS
#ifdef DEF_PLI
  static snLenIdPls := LEN_IDPLS
  static snLenMbrRemark := 50
#endif DEF_PLI
#ifdef DEF_ADR
  static snLenIdAdl := 8
#endif DEF_ADR
#ifdef DEF_ALS
  static snLenIdAls := 4
#endif DEF_ALS
#ifdef DEF_KVK
  static scIdZlaDefault := "B" // LEN_IDZLA
#endif DEF_KVK
#ifdef DEF_BIL
  static snLenIdBil := 4
#endif DEF_BIL
#ifdef DEF_BIBLIO
  static snLenIdRub := 4
  static snLenIdNts := 5
#endif DEF_BIBLIO
  static snLenIdGen       := 6
#ifdef DEF_GEN
  static snLenGenHeader := 3
  static sxlOnGenCtrExist := {|cIdGen, cPeriode, cIdJnl| ;
    "M"$GEN->Attrib.or.!SetMsg(cIdGen+MsgDontUse()) ;
  }
  static sxlOnGenJnlExist := {|cIdGen, cPeriode, cIdJnl| ;
    empty(JnlIdGen(cIdJnl)).or.GENATTR_M$GEN->Attrib.or.!SetMsg(cIdGen+MsgDontUse()) ;
  }
#endif DEF_GEN
static snLenIdPrj   := 6
static snLenIdUnt   := 8

  static scDocNew    := DOCSTAT_NEW
  static scDocOpen   := DOCSTAT_OPEN
  static scDocClosed := DOCSTAT_CLOSED
  static scDocError  := DOCSTAT_ERROR

#ifdef DEF_JNL
  static scNoCheckIdDoc := ""
  static sbPreDocUndo  := {||.t.}
  static sbNoCheckRupture  := {||.f.}
  static sbCheckIdDoc := { ;
    |cIdDoc,cPeriode,cIdJnl| ;
    !SetMsg(cIdDoc + MsgCheckIdDoc() + cPeriode) ;
  }
#endif DEF_JNL
#ifdef DEF_ACF
  static sbAcfIdCtr := {||PrtIdCtr(PAR->IdPrt)}
  static sbDoVnlAcfUpdate := {||.f.}
  static sbMustAcfReplicate := {||.t.}
#endif DEF_ACF
#ifdef DEF_ART
  static sbArtCopyTemplate := {||repl("0",LenIdArt())}
  static sbArtName := {|cIdArt,cIdLng|StdArtName(cIdArt,cIdLng)}
  static sbArtIsTotal := {|x|trim(x)=="T"}
  static snLenArtRoot := 0
  static scPicIdArt := PIC_ID
  static snLenArtRef  := 15
  static snLenAcfRef  := 15
  static snLenIdGra := 3
  static scPicIdGra := PIC_ID
  static snLenIdPga := 2
  static sxlArtFilter := "!'" + ARTATTR_H + "'$ART->Attrib"
  static sbNextIdArt  := {|x| DbfNextId(oArt(),left(x,snLenArtRoot),snLenIdArt) }
  static sbNextIdGra  := {|x| DbfNextId(oGra(),x,snLenIdGra) }
  static sbGetIdArt   := {|x| GetId(x,snLenIdArt,snLenArtRoot) }
  static sbGetIdGra   := {|x| upper(x) }
  static sbPreArtCreate  := {||.t.}
  static sbIdArtValidate  := {||.t.}
  static sbIdGraValidate  := {||.t.}
  static scArtIdDev := "EUR"
#endif DEF_ART
#ifdef DEF_ANA
  static snLenIdAna := 6
  static sbGetIdAna   := {|x| if(empty(x),x,padr(trim(x),LenIdAna(),"0")) }
  static sbNoDocMvaCheck  := {||.f.}
  static sbVnlIdAna  := {||""}
#endif DEF_ANA
#ifdef DEF_HOLZ
  static snLenIdStm := 5
  static scOnStmCreate := NIL
  static saPreStmCopy := NIL
#endif DEF_HOLZ
static snLenIdPar := 6
static sbNextIdPar  := {|cIdPrt| StdNextIdPar(cIdPrt) }
// static sbGetIdPar   := {|x| GetId(x,snLenIdPar,0) }
static sbGetIdPar   := {|x,cIdPrtList| StdGetIdPar(x,cIdPrtList) }
static sbIdParValidate  := {|x| .t. }
static snLenIdJnl := 3
static snLenIdMfc := 3
static snLenIdPgp := 3
static snLenIdRga := 3
static snPerShift   := 0
static saOnParSelect := {}
#ifdef DEF_ABO
  static saAboParFilter := {}
  static saAboVnaFilter := {}
#endif DEF_ABO

#ifdef DEF_VEN
#ifdef LG_GERMAN
  static sbMsgVnaTag := {|cIdJnl| "FakturierungsvorschlÑge" }
#else
  static sbMsgVnaTag := {|cIdJnl| "propositions de facturation" }
#endif
#endif DEF_VEN

#ifdef DEF_VCS
  static saVcsJournals := {}
#endif DEF_VCS

*#ifdef CUST_MOOR
*static sblOnCarPassFile := {|cFilename| ;
*  OpenUrl("https://professionals.car-pass.be/httpupload";
*    +"/upload.action?filename="+cFilename)}
*#endif CUST_MOOR



**
** PROCEDURE_SECTION  - (...grins)
**

**
** AppConvert() // sollte besser AppInitDB heissen...
**
FUNCTION AppConvert(lCheck)
local aBuf
local cMemo
local prt
local jnl
* local cIdDev
#ifdef UPGR96
  if lCheck // "/UPGRADE" $ cParams
    #ifdef DEF_VNA
      if IndConfirm("960419",'Neues Feld VNA->QteForm setzen')
        open area oVna(), oArt()
          go top
          do while ! eof()
            if empty(VNA->QteForm)
              if ddRecLock()
                seek VNA->IdArt in ART
                VNA->QteForm := ART->QteForm
                unlock record
              endif
            endif
            skip
          enddo
        close area
      endif
    #endif DEF_VNA
    #ifdef DEF_GEN
      if IndConfirm("960531",'GEN->IdCtr prÅfen')
        WinEdit(oJnl(),"JNL->IdCtr fÅr FIN-Journale muss leer sein.",NIL, {||JnlRefresh(),MnuLoad()})
        ddCloseAll()
        open area oHst(), oGen() exclusive
          go top
          do while ! eof()
            if ! empty(HST->IdCtr)
              if (jnl := JnlLocate(HST->IdJnl)) != NIL
                seek HST->IdGen in GEN
                if empty(GEN->IdCtr)
                  GEN->IdCtr := jnl[JNL_IDCTR]
                elseif GEN->IdCtr != jnl[JNL_IDCTR]
                  if ! empty(jnl[JNL_IDCTR])
                    if Confirm(GEN->IdGen + " auf " + jnl[JNL_IDCTR] + " setzen ?")
                      GEN->IdCtr := jnl[JNL_IDCTR]
                    endif
                  endif
                endif
              endif
            endif
            skip
          enddo
        close area
      endif
    #endif DEF_GEN
    #ifdef DEF_STK
      if IndConfirm("960618",'stk.dbc und JNLATTR_S fÅr VEN-Journale')
        WinEdit(oJnl(),"JNL.DBC", NIL, {||JnlRefresh(),MnuLoad()})
      endif
    #endif DEF_STK
    *#ifdef DEF_GEN
    *  if IndConfirm("960625",'GEN->DC setzen (! GEN->DC in Masken einbauen !)')
    *    ddCloseAll()
    *    open area oGen(), oCtg() exclusive
    *      go top
    *      do while ! eof()
    *        softseek GEN->IdGen in CTG
    *        if val(CTG->Debit) > val(CTG->Credit)
    *          GEN->DC := DC_DEBIT
    *        else
    *          GEN->DC := DC_CREDIT
    *        endif
    *        skip
    *      enddo
    *    close area
    *  endif
    *#endif DEF_GEN
    *#ifdef DEF_TAX
    *  if IndConfirm("960627",'TAXATTR_R setzen')
    *    ddCloseAll()
    *    open area oTax() exclusive
    *      ddSetOrder
    *      go top
    *      do while ! eof()
    *        if TAXATTR_R $ TAX->Attrib
    *          exit
    *        else
    *          TAX->Attrib := TAXATTR_R + TAX->Attrib
    *        endif
    *        skip
    *      enddo
    *    close area
    *  endif
    *#endif DEF_TAX
    #ifdef DEF_VEN
      if IndConfirm("960717",'GEN->IdClj statt GEN->IdCat')
        ddCheck(oTax())
      endif
    #endif DEF_VEN
    #ifdef DEF_VNA
      if IndConfirm("960917",'IFCATTR_F -> IFCATTR_A')
        open area oIfc()
          go top
          do while ! eof()
            if "F" $ IFC->Attrib
              if ddRecLock()
                IFC->Attrib := strtran(IFC->Attrib,"F","A")
                unlock record
              endif
            endif
            skip
          enddo
        close area
      endif
    #endif DEF_VNA
    if IndConfirm("960919","IDQRY in prt und xtv anpassen !")
      DbcEdit("*.dbc",NIL,"IDQRY in PRT, XTV und TPT anpassen !")
    endif
    *#ifdef DEF_VNA
    *  if IndConfirm("960920",'VNA->Mont setzen')
    *    open area oVna(), oVen()
    *      go top
    *      do while ! eof()
    *        seek VNA->IdJnl + VNA->IdDoc in VEN
    *        VNA->Mont := ntom(val(VNA->PrixU)*qton1(VNA->Qte),DevDecPos(VEN->IdDev))
    *        skip
    *      enddo
    *    close area
    *  endif
    *#endif DEF_VNA
    if IndConfirm("961104",'TPL.DBF aus TXT.DBF importieren')
      ddCheck(oTpl())
      open area oTpl()
        select 0
        use (dbPath()+"\TXT") alias TXT
        go top
        do while ! eof()
          select TPL
          seek TXT->Type + TXT->IdTxt
          if eof()
            if dbAddRec()
              TPL->IdTpt := TXT->Type
              TPL->IdTpl := TXT->IdTxt
              TPL->IdOpt := TXT->IdOpt
              TPL->Width := str(TXT->Largeur,3)
              unlock record
            endif
          endif
          if ddRecLock()
            if TXT->Langue == MemLang1
              TPL->Memo1 := TXT->Texte
              TPL->Name  := TXT->Desig
            elseif TXT->Langue == MemLang2
              TPL->Memo2 := TXT->Texte
            elseif TXT->Langue == MemLang3
              TPL->Memo3 := TXT->Texte
            else
              Warning(TXT->Type + " " + TXT->IdTxt + "-" + TXT->Langue + " : could not import")
            endif
            unlock record
          endif
          select TXT
          skip
        enddo
        use
        select TPL
      close area
    endif
    if IndConfirm("960925",'{ven tot_xxxx} durch {ven_xxx} ersetzen')
      open area oTpl()
        go top
        do while ! eof()
          if ddRecLock()
            TPL->Memo1 := strtran(TPL->Memo1,"{ven tot_tvac","{ven tvac")
            TPL->Memo1 := strtran(TPL->Memo1,"{ven tot_mtva","{ven mtva")
            TPL->Memo1 := strtran(TPL->Memo1,"{ven tot_htva","{ven htva")
            TPL->Memo1 := strtran(TPL->Memo1,"{S}","{U}")
            TPL->Memo1 := strtran(TPL->Memo1,"{s}","{u}")
            TPL->Memo2 := strtran(TPL->Memo2,"{ven tot_tvac","{ven tvac")
            TPL->Memo2 := strtran(TPL->Memo2,"{ven tot_mtva","{ven mtva")
            TPL->Memo2 := strtran(TPL->Memo2,"{ven tot_htva","{ven htva")
            TPL->Memo2 := strtran(TPL->Memo2,"{S}","{U}")
            TPL->Memo2 := strtran(TPL->Memo2,"{s}","{u}")
            TPL->Memo3 := strtran(TPL->Memo3,"{ven tot_tvac","{ven tvac")
            TPL->Memo3 := strtran(TPL->Memo3,"{ven tot_mtva","{ven mtva")
            TPL->Memo3 := strtran(TPL->Memo3,"{ven tot_htva","{ven htva")
            TPL->Memo3 := strtran(TPL->Memo3,"{S}","{U}")
            TPL->Memo3 := strtran(TPL->Memo3,"{s}","{u}")
            unlock record
          endif
          skip
        enddo
      close area
      #ifdef DEF_VEN
        open area oIfc()
          go top
          do while ! eof()
            if ddRecLock()
              IFC->Memo1 := strtran(IFC->Memo1,"{ven tot_tvac","{ven tvac")
              IFC->Memo1 := strtran(IFC->Memo1,"{ven tot_mtva","{ven mtva")
              IFC->Memo1 := strtran(IFC->Memo1,"{ven tot_htva","{ven htva")
              IFC->Memo2 := strtran(IFC->Memo2,"{ven tot_tvac","{ven tvac")
              IFC->Memo2 := strtran(IFC->Memo2,"{ven tot_mtva","{ven mtva")
              IFC->Memo2 := strtran(IFC->Memo2,"{ven tot_htva","{ven htva")
              IFC->Memo3 := strtran(IFC->Memo3,"{ven tot_tvac","{ven tvac")
              IFC->Memo3 := strtran(IFC->Memo3,"{ven tot_mtva","{ven mtva")
              IFC->Memo3 := strtran(IFC->Memo3,"{ven tot_htva","{ven htva")
              IFC->Memo1 := strtran(IFC->Memo1,"{S}","{U}")
              IFC->Memo2 := strtran(IFC->Memo2,"{S}","{U}")
              IFC->Memo3 := strtran(IFC->Memo3,"{S}","{U}")
              IFC->Memo1 := strtran(IFC->Memo1,"{s}","{u}")
              IFC->Memo2 := strtran(IFC->Memo2,"{s}","{u}")
              IFC->Memo3 := strtran(IFC->Memo3,"{s}","{u}")
              unlock record
            endif
            skip
          enddo
        close area
      #endif DEF_IFC
      #ifdef DEF_TAX
        open area oTax()
          go top
          do while ! eof()
            if ddRecLock()
              TAX->Memo1 := strtran(TAX->Memo1,"{ven tot_tvac","{ven tvac")
              TAX->Memo1 := strtran(TAX->Memo1,"{ven tot_mtva","{ven mtva")
              TAX->Memo1 := strtran(TAX->Memo1,"{ven tot_htva","{ven htva")
              TAX->Memo2 := strtran(TAX->Memo2,"{ven tot_tvac","{ven tvac")
              TAX->Memo2 := strtran(TAX->Memo2,"{ven tot_mtva","{ven mtva")
              TAX->Memo2 := strtran(TAX->Memo2,"{ven tot_htva","{ven htva")
              TAX->Memo3 := strtran(TAX->Memo3,"{ven tot_tvac","{ven tvac")
              TAX->Memo3 := strtran(TAX->Memo3,"{ven tot_mtva","{ven mtva")
              TAX->Memo3 := strtran(TAX->Memo3,"{ven tot_htva","{ven htva")
              TAX->Memo1 := strtran(TAX->Memo1,"{S}","{U}")
              TAX->Memo2 := strtran(TAX->Memo2,"{S}","{U}")
              TAX->Memo3 := strtran(TAX->Memo3,"{S}","{U}")
              TAX->Memo1 := strtran(TAX->Memo1,"{s}","{u}")
              TAX->Memo2 := strtran(TAX->Memo2,"{s}","{u}")
              TAX->Memo3 := strtran(TAX->Memo3,"{s}","{u}")
              unlock record
            endif
            skip
          enddo
        close area
      #endif DEF_TAX
    endif
    #ifdef DEF_FIN
      if IndConfirm("961004",'JNLATTR_E fÅr OD-Journale')
        open area oJnl()
          go top
          do while ! eof()
            if JNL->Alias == "FIN"
              if JNLATTR_E $ JNL->Attrib
                if JNL->IdGen == "499000"
                  if ddRecLock()
                    JNL->IdGen := ""
                    JNL->Attrib := strtran(JNL->Attrib,"E")
                    unlock record
                  endif
                else
                  Warning(JNL->IdJnl + " Journalattribut E prÅfen !")
                endif
              endif
            endif
            skip
          enddo
        close area
      endif
    #endif DEF_FIN
    #ifdef DEF_TAX
      #ifdef DEF_VEN
        if IndConfirm("961022",'VEN->IdReg setzen')
          ddCheck(oVen())
          open area oVen(), oPar()
            go top
            do while ! eof()
              if TaskInter() ; exit ; endif
              if ParExist(VEN->IdPar)
                if empty(VEN->IdReg)
                  if ddRecLock()
                    VEN->IdReg := PAR->IdReg
                    unlock record
                  else
                    exit
                  endif
                elseif VEN->IdReg != PAR->IdReg
                  Warning(MsgIdJnlDoc() + " : MWSt-Regime Partner <> Rechnung !")
                endif
              else
                Warning(MsgIdJnlDoc() + " : " + SetMsg())
              endif
              skip
            enddo
          close area
        endif
      #endif DEF_VEN
    #endif DEF_TAX
    #ifdef DEF_JNL
      if IndConfirm("961118",'Journalattribute A und R korrigieren')
        open area oJnl()
          go top
          do while ! eof()
            if JNL->Alias == "VEN"
              if ddRecLock()
                if JNLATTR_A $ JNL->Attrib
                  JNL->Attrib := strtran(JNL->Attrib,JNLATTR_A,JNLATTR_R)
                endif
                #ifdef DEF_VNA
                  JNL->Attrib := trim(JNL->Attrib) + JNLATTR_A
                #endif DEF_VNA
                unlock record
              endif
            endif
            skip
          enddo
        close area
      endif
    #endif DEF_JNL
*    #ifdef DEF_PLS
*      if IndConfirm("961217",'Kontaktpersonen Åbernehmen')
*        open area oPar(), oPls()
*          ddSetOrder 2
*          softseek "L"
*          do while ! eof() .and. PAR->IdPrt == "L"
*            select PLS
*            if dbAddRec()
*              PLS->IdPls := PAR->IdPar
*              PLS->Name  := PAR->Firme
*              PLS->Memo  := PAR->Memo
*              unlock record
*            else
*              exit
*            endif
*            select PAR
*            skip
*          enddo
*        close area
*        open area oMbr()
*          select 0
*          use (DbPath() + "\PSC")
*          go top
*          do while ! eof()
*            select MBR
*            if dbAddRec()
*              MBR->IdPls := PSC->IdPar
*              MBR->IdPar := PSC->IdPar2
*              MBR->Pos   := "0" + PSC->Seq
*              unlock record
*            else
*              exit
*            endif
*            select PSC
*            skip
*          enddo
*        close area
*      endif
*    #endif DEF_PLS
  endif
#endif UPGR96
#ifdef UPGR97
  if lCheck
    #ifdef DEF_JNL
      if IndConfirm("970107",'Periodenstruktur anpassen')
        c970107()
      endif
    #endif DEF_JNL
    #ifdef DEF_HST
      if IndConfirm("970117",'ParRapListe() umbenennen nach MvpAuto()')
        c970117()
      endif
    #endif DEF_HST
    #ifdef DEF_VEN
      if IndConfirm("970121",'JNLATTR_K fÅr VEN-Journale setzen')
        ddCloseAll()
        open area oJnl()
          go top
          do while ! eof()
            if JNL->Alias == "VEN"
              if ! JNLATTR_K $ JNL->Attrib
                if ddRecLock()
                  JNL->Attrib := trim(JNL->Attrib) + JNLATTR_K
                  unlock record
                endif
              endif
            endif
            skip
          enddo
        close area
      endif
    #endif DEF_VEN
    if IndConfirm("970124",'Datei PGP.DBC anpassen')
      c970124()
    endif
    if IndConfirm("970128",'PrtParEdit() und ParEdit()')
      c970128()
    endif
    #ifdef DEF_FIN
      if IndConfirm("970529",'JNLATTR_K fÅr FIN-Journale setzen')
        ddCloseAll()
        open area oJnl()
          go top
          do while ! eof()
            if JNL->Alias == "FIN"
              if ! JNLATTR_K $ JNL->Attrib
                if ddRecLock()
                  JNL->Attrib := trim(JNL->Attrib) + JNLATTR_K
                  unlock record
                endif
              endif
            endif
            skip
          enddo
        close area
      endif
    #endif DEF_FIN
    #ifdef DEF_HST
      if IndConfirm("970708",'MVP+MVT => HST')
        c970708()
      endif
      IndWarn("971008",'Die hcl-Dateien wurden nicht angepasst !')
    #endif DEF_HST
    #ifdef DEF_VNA
      if IndConfirm("971026",'VNA->QteForm neu setzen')
        open area oVna(), oArt()
          go top
          do while ! eof()
            if empty(VNA->QteForm)
              if ddRecLock()
                seek VNA->IdArt in ART
                VNA->QteForm := ART->QteForm
                unlock record
              endif
            endif
            skip
          enddo
        close area
      endif
    #endif DEF_VNA
    * IndWarn("971122",'set dateformat : "\" manuell einfÅgen !')
    #ifdef DEF_PRIXR
      if IndConfirm("971126",'VNL->PrixR jetzt STöCKpreis')
        Warning("971126.IND wurde noch nicht gemacht !")
        IndDelete("971126")
      endif
      *  open area oVnl(), oVen()
      *    go top
      *    do while ! eof()
      *      if TaskInter()
      *        if Confirm(MsgSure()) ; exit ; endif
      *      endif
      *      if abs(qton1(VNL->Qte)) != 1 .and. qton1(VNL->Qte) != 0
      *        seek VNL->IdJnl + VNL->IdDoc in VEN
      *        if eof() in VEN
      *          Warning(MsgIdJnlDoc() + " : eof() in VEN !")
      *        else
      *          if ddRecLock()
      *            VNL->PrixR := ntom( ;
      *              val(VNL->PrixR)/qton1(VNL->Qte);
      *            )
      *            unlock record
      *          else
      *            Warning(MsgIdJnlDoc() + " : ddRecLock() failed !")
      *          endif
      *        endif
      *      endif
      *      skip
      *    enddo
      *  close area
      *  Warning("Achtung : auch sum-expression in vnl*.qry anpassen")
    #endif DEF_PRIXR
#endif UPGR97
#ifdef UPGR98
  if lCheck
    * #ifdef DEF_HST
    *   if IndConfirm("980114",'GEN->IdDev := '+DevDefault(PerActive()))
    *     open area oGen()
    *       go top
    *       do while ! eof()
    *         if ddRecLock()
    *           GEN->IdDev := DevDefault(PerActive())
    *           unlock record
    *         endif
    *         skip
    *       enddo
    *     close area
    *   endif
    * #endif DEF_HST
    #ifdef DEF_REPORT
      if IndConfirm("980617",'replace "before" by "ValidateRecord" in *.rep')
        c980617()
      endif
    #endif DEF_REPORT
    #ifdef DEF_IMP
      if IndConfirm("980618",'IMP->Cours und IMP->IdDev setzen')
        c980618()
      endif
    #endif DEF_IMP
    #ifdef DEF_VEN
      if IndConfirm("980623",'VenTvaListe() : xlParFilter statt cIdReg')
        DbcEdit("mnu*.dbc",NIL,'VenTvaListe() : xlParFilter statt cIdReg')
      endif
    #endif DEF_VEN
    #ifdef DEF_VNLALT
      if IndConfirm("980727",'"VNL->" durch "FIELD->" ersetzen')
        open area oTpl()
          go top
          do while ! eof()
            if ddRecLock()
              TplStrTran("VNL->","FIELD->")
              unlock record
            endif
            skip
          enddo
        close area
      endif
    #endif DEF_VNLALT
    #ifdef DEF_GEN
      if IndConfirm( ;
        "980728", ;
        'GEN->IdDev leeren wenn GrundwÑhrung' ;
      )
        c980728()
      endif
    #endif DEF_GEN
    if IndConfirm( ;
      "980907", ;
      'PAR->IdDev leeren wenn GrundwÑhrung' ;
    )
      c980907()
    endif
    #ifdef DEF_FIN
      if IndConfirm( ;
        "981019", ;
        'Neues Feld FIN->IdDev initialisieren' ;
      )
        c981019()
      endif
    #endif DEF_FIN
    if IndConfirm( ;
      "981113", ;
      'Read NAT.DBC into NAT.DBF' ;
    )
      c981113()
    endif
  endif
#endif UPGR98
  if lCheck
    #ifdef DEF_JNL
      if IndConfirm( ;
        "A00215", ;
        'Neues Feld JNL->SeqType initialisieren' ;
      )
        cA00215()
      endif
    #endif DEF_FIN
    *#ifdef DEF_HST
    *  if IndConfirm( ;
    *    "20010117", ;
    *    'Betrag FW in alten HST prÅfen';
    *  )
    *    HstDevCheck()
    *  endif
    *#endif DEF_HST
    #ifdef DEF_HST
      if IndConfirm( ;
        "A10411", ;
        'Neues Feld HST->IdDev initialisieren' ;
      )
        cA10411()
      endif
    #endif DEF_FIN
  endif
**
** JnlCheck() wird immer getestet.
**
#ifdef DEF_JNL
  if IndConfirm("JNLCHECK",'JNL->IdDoc setzen')
    JnlCheck()
  endif
#endif DEF_JNL
RETURN .T. if MemVersion == AppVer()
RETURN .F. if ! Confirm(MSG063 + ntrim(MemVersion) + " -> " + ntrim(AppVer()) )
MemVersion := AppVer()
AppSaveMem()
RETURN .t.

#ifdef UPGR98

#ifdef DEF_GEN

FUNCTION c980728
local cIdDev := DevDefault(PerActive())
  open area oGen()
    go top
    do while ! eof()
      if GEN->IdDev == cIdDev .and. ddRecLock()
        GEN->IdDev := ""
        unlock record
      endif
      skip
    enddo
  close area
RETURN NIL

#endif DEF_GEN

FUNCTION c980907
local cIdDev := DevDefault(PerActive())
  open area oPar()
    go top
    do while ! eof()
      if PAR->IdDev == cIdDev .and. ddRecLock()
        PAR->IdDev := ""
        unlock record
      endif
      skip
    enddo
  close area
RETURN NIL

#ifdef DEF_FIN

FUNCTION c981019
local jnl
open area oFin()
  go top
  do while ! eof()
    if empty(FIN->IdDev) .and. ddRecLock()
      if (jnl := JnlLocate(FIN->IdJnl)) != NIL
        if empty(jnl[JNL_IDDEV])
          FIN->IdDev := DevDefault(FIN->Periode)
        else
          FIN->IdDev := jnl[JNL_IDDEV]
        endif
      endif
      unlock record
    endif
    skip
  enddo
close area
RETURN NIL


#endif DEF_FIN


FUNCTION c981113
local aNat := ReadArray("NAT.DBC",NAT_ALEN)
local i
local lOkay := .f.
open area oNat()
  go top
  if ! eof()
    Warning("Error : existing NAT.DBF is not empty !")
  else
    lOkay := .t.
    for i := 1 to len(aNat)
      if dbAddRec()
        NAT->IdNat := aNat[i][1]
        NAT->Name  := aNat[i][2]
        NAT->Intra := aNat[i][3]
        NAT->IdLng := aNat[i][4]
        NAT->IdTlf := aNat[i][5]
        NAT->TelPrefix := aNat[i][6]
        NAT->TvaPrefix := aNat[i][7]
        NAT->IdDev     := aNat[i][8]
        NAT->TvaPict   := aNat[i][9]
        unlock record
      else
        lOkay := .f.
        exit
      endif
    next i
  endif
close area
RETURN NIL if ! lOkay
delete file (DbPath()+"\NAT.DBC")
RETURN NIL

#endif UPGR98

#ifdef DEF_JNL

FUNCTION cA00215
open area oJnl()
  go top
  do while ! eof()
    if empty(JNL->SeqType)
      if ddRecLock()
        if JNL->Alias != JNLALIAS_IMP .and. JNLATTR_O $ JNL->Attrib
          JNL->SeqType := SEQTYPE_M
        elseif JNL->Alias == "FIN" .and. !empty(JNL->IdGen)
          JNL->SeqType := SEQTYPE_Y
        else
          JNL->SeqType := SEQTYPE_E
        endif
        unlock record
      endif
    endif
    skip
  enddo
close area
RETURN NIL


#endif DEF_JNL


FUNCTION u20021213
local lOkay := .f.
local cFilename
local c
RETURN .f. if ! Confirm("update 20021213 : "+MsgSure())
open area oTpl()
  lOkay := .t.
  softseek TPLTYPE_INI
  do while lOkay .and. TPL->IdTpt == TPLTYPE_INI .and. ! eof()
    cFilename := DbPath()+"\"+trim(TPL->IdTpl)+".PPS"
    if file(cFilename)
      SetMsg(cFilename + " : file already exists!")
      lOkay := .f.
    else
      c := "// " + trim(TPL->Name)+CR_LF + TPL->Memo1
      c := strtran(c,"set driver "        , 'DrvLoad("'           )
      c := strtran(c,"set special"       , 'p_SetSpecial('        )
      c := strtran(c,"set option"        , 'p_SetSpecial('        )
      c := strtran(c,"set finalff"       , 'p_SetFinalFF('        )
      c := strtran(c,"set paperheight"   , 'p_SetPapHeight('      )
      c := strtran(c,"set paperwidth"    , 'p_SetPapWidth('       )
      c := strtran(c,"set marginleft"    , 'p_SetLMargin('        )
      c := strtran(c,"set marginright"   , 'p_SetRMargin('        )
      c := strtran(c,"set margintop"     , 'p_SetTMargin('        )
      c := strtran(c,"set marginbottom"  , 'p_SetBMargin('        )
      c := strtran(c,"set pagealign"     , 'p_SetPgAlign('        )
      c := strtran(c,"set indent"        , 'p_Indent('            )
      c := strtran(c,"set outport"       , 'p_SetPort('           )
      c := strtran(c,"set font"          , 'p_SetFont('           )
      c := strtran(c,"set apswidth"      , 'p_SetWidth('          )
      c := strtran(c,"set header"        , 'p_SetHeader('         )
      c := strtran(c,"set footer"        , 'p_SetFooter('         )
      c := strtran(c,"set capture"       , 'p_SetCapture('        )
      c := strtran(c,"set align"         , 'p_SetAlign('          )
      c := strtran(c,"set columns"       , 'p_SetColumns('        )
      c := strtran(c,"set montant"       , 'SetMntFormat('        )
      c := strtran(c,"set solde"         , 'SetSolde('            )
      c := strtran(c,"set lang"          , 'SetTplLang('          )
      c := strtran(c,"set dateformat"    , 'SetDateFormat('       )
      c := strtran(c,"etc do"            , ''                     )
      if ! memowrit(cFilename,c)
        SetMsg(cFilename+" : memowrit() failed !")
        lOkay := .f.
      endif
    endif
    skip
  enddo
close area
if ! lOkay
  Warning(SetMsg())
endif
RETURN lOkay



#ifdef DEF_HST

FUNCTION cA10411
local lOkay := .f.
local jnl
open area oHst(), oPar(), oGen(), oFin(), oVen()
  lOkay := .t.
  go top
  do while ! eof()
    if TaskInter()
      lOkay := .f.
      exit
    endif
    if empty(HST->IdDev) .and. !empty(HST->MontDev)
      if ddRecLock()
        HST->IdDev := HstIdDev()
        unlock record
      else
      endif
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
#ifdef DEF_FIN
  open area oFnl(), oPar(), oGen(), oFin(), oVen()
    go top
    do while ! eof()
      if TaskInter()
        lOkay := .f.
        exit
      endif
      if empty(FNL->IdDev) .and. !empty(FNL->MontDev)
        if ddRecLock()
          seek FNL->IdJnl+FNL->IdDoc in FIN
          if (jnl := JnlLocate(FIN->IdJnl)) == NIL
            lOkay := .f.
            exit
          endif
          if FinFnlInit(jnl) == NIL
            Warning(SetMsg())
            lOkay := .f.
            exit
          endif
          if ! FnlFirstCheck()
            Warning(SetMsg())
            lOkay := .f.
            exit
          endif
          unlock record
        else
        endif
      endif
      skip
    enddo
  close area
  RETURN .f. if ! lOkay
#endif
RETURN .t.


#endif DEF_HST





#ifdef DEF_IMP

STATIC FUNCTION c980618()
local lOkay := .f.
open area oImp()
  lOkay := .t.
  ddSetOrder(0)
  go top
  do while ! eof()
    if TaskInter()
      lOkay := .f.
      exit
    endif
    if empty(IMP->Cours) .or. empty(IMP->IdDev)
      if ddRecLock()
        IMP->Cours := padl("1",LenMont())
        IMP->IdDev := "BEF"
        unlock record
      else
        lOkay := .f.
        exit
      endif
    endif
    skip
  enddo
close area
if ! lOkay
  IndDelete("980618")
endif
RETURN NIL

#endif DEF_IMP


* #ifdef UPGRADE_97

FUNCTION TplStrTran(c1,c2)
FIELD->Memo1 := strtran(FIELD->Memo1,c1,c2)
FIELD->Memo2 := strtran(FIELD->Memo2,c1,c2)
FIELD->Memo3 := strtran(FIELD->Memo3,c1,c2)
RETURN .t.

#ifdef DEF_JNL

FUNCTION c970107()
local lOkay := .f.
local cPeriode := "*"
ddCheck(oPer())
ddCheck(oJnl())
open area oPer(), oJnl()
  lOkay := .t.
  go top
  do while ! eof()
    if PER->Etat == PERSTAT_CLOSED
      select JNL
      seek PER->IdJnl
      if JNL->Periode < PER->Periode
        if ddRecLock()
          JNL->Periode := PER->Periode
          unlock record
        else
          lOkay := .f.
        endif
      endif
      select PER
    endif
    skip
  enddo
close area
if lOkay
  open area oPer()
    go top
    do while ! eof()
      if ddRecLock()
        if PER->Periode == cPeriode
          delete
        else
          cPeriode := PER->Periode
          PER->Name := PerDefaultName(cPeriode)
        endif
        unlock record
      else
        lOkay := .f.
        exit
      endif
      skip
    enddo
  close area
endif
RETURN NIL if lOkay
Warning( ;
  "970107.ind : Konvertierung hat fehlgeschlagen !", ;
  "Hot-line 087/59.35.53 !" ;
)
RETURN NIL

#endif DEF_JNL


FUNCTION c970117()
local aDir := directory(dbPath() + "\mnu*.dbc")
local i
for i := 1 to len(aDir)
  RETURN .f. if ! FileConvert( ;
    dbPath() + "\" + aDir[i][F_NAME], ;
    {|x| ;
        x := strtran(x,"ParRapListe","MvpAuto"), ;
        x := strtran(x,'LstPrint(','TplDlgPrint("LST",') ;
    } ;
  )
next i
RETURN .t.

FUNCTION c970124()
RETURN .t. if ! file(dbPath() + "\PGP.DBC")
RETURN FileConvert( ;
  dbPath() + "\PGP.DBC", ;
  {|x| ;
      x := strtran(x,"|","||V|Prix1|") ;
  } ;
)

FUNCTION c970128()
local aDir := directory(dbPath() + "\mnu*.dbc")
local i
for i := 1 to len(aDir)
  RETURN .f. if ! FileConvert( ;
    dbPath() + "\" + aDir[i][F_NAME], ;
    {|x| ;
        x := strtran(x,"ParEdit(","PrtParEdit("), ;
        x := strtran(x,'ParEditAll(','ParEdit(') ;
    } ;
  )
next i
RETURN .t.

#ifdef DEF_REPORT

FUNCTION c980617()
local aDir := directory(dbPath() + "\*.rep")
local i
for i := 1 to len(aDir)
  RETURN .f. if ! FileConvert( ;
    dbPath() + "\" + aDir[i][F_NAME], ;
    {|x| ;
        x := strtran(x,"before ","ValidateRecord ") ;
    } ;
  )
next i
RETURN .t.

#endif DEF_REPORT

#ifdef DEF_HST

FUNCTION c970708()
local nCount := 0
local lMvtSatis := .f.
local a, i
ddCloseAll()
open area oFlt()
  ddSetOrder()
  go top
  do while ! eof()
    if ddRecLock()
      if trim(FLT->Alias) == "MVTGEN"
        FLT->Alias := "HSTGEN"
      elseif trim(FLT->Alias) == "MVPPAR"
        FLT->Alias := "HSTPAR"
      elseif trim(FLT->Alias) == "MVP"
        FLT->Alias := "HST"
      elseif trim(FLT->Alias) == "MVT"
        FLT->Alias := "HST"
      endif
      FLT->Expr := strtran(FLT->Expr,"MVP->","HST->")
      FLT->Expr := strtran(FLT->Expr,"MVT->","HST->")
      unlock record
    endif
    skip
  enddo
close area
open area oTpl()
  go top
  do while ! eof()
    if ddRecLock()
      TplStrTran("MVP->","HST->")
      TplStrTran("MVT->","HST->")
      TplStrTran("{mvp","{hst")
      TplStrTran("{mvg","{hst")
      TplStrTran("{par mvp","{par hst")
      TplStrTran("{gen mvg","{gen hst")
      unlock record
    endif
    skip
  enddo
close area
open area oHst()
  select 0
  use (DbPath() + "\MVT")
  a := dbstruct()
  for i := 1 to len(a)
    if upper(a[i][1]) == "MATCH"
      lMvtSatis := .t.
    endif
  next i
  go top
  do while ! eof()
    if TaskInter() ; exit ; endif
    MsgDisp2("(MVT) " + ntrim0(++nCount * 100 / lastrec()) + "%" )
    if ! empty(MVT->IdDoc)
      select HST
      if dbAddRec()
        HST->IdGen   := MVT->IdGen
        HST->IdPar   := ""
        HST->IdJnl   := MVT->IdJnl
        HST->IdDoc   := MVT->IdDoc
        HST->Line    := MVT->Line
        HST->Date    := MVT->Date
        HST->Periode := MVT->Periode
        HST->DC      := MVT->DC
        HST->Mont    := MVT->Mont
        // HST->MontDev := MVT->MontDev
        HST->IdCtr   := ""
        if lMvtSatis
          HST->Match   := MVT->Match
          HST->Satis   := MVT->Satis
        endif
        unlock record
      endif
      select MVT
    endif
    skip
  enddo
  use
  use (DbPath() + "\MVP")
  go top
  nCount := 0
  do while ! eof()
    if TaskInter() ; exit ; endif
    MsgDisp2("(MVP) " + ntrim0(++nCount * 100 / lastrec()) + "%" )
    select HST
    if dbAddRec()
      HST->IdGen   := CtrIdGen(MVP->IdCtr)
      HST->IdPar   := MVP->IdPar
      HST->IdJnl   := MVP->IdJnl
      HST->IdDoc   := MVP->IdDoc
      HST->Line    := MVP->Line
      HST->Date    := MVP->Date
      HST->Periode := MVP->Periode
      HST->DC      := MVP->DC
      HST->Mont    := MVP->Mont
      HST->MontDev := MVP->MontDev
      HST->Match   := MVP->Match
      HST->Satis   := MVP->Satis
      HST->IdCtr   := MVP->IdCtr
      unlock record
    endif
    select MVP
    skip
  enddo
  use
  select HST
close area
RETURN NIL

#endif DEF_HST


FUNCTION FileConvert(cName,b)
local i,o
local cBakName
local nPos := rat(".",cName)
local cLine
RETURN .f. if nPos == 0
cName := upper(cName)
if substr(cName,nPos+1) == "OLD"
  Warning("cannot convert " + cName)
  RETURN .f.
endif
cBakName := left(cName,nPos) + "OLD"
if (! file(cBakName)) .or. Confirm(cBakName + MsgOverwrite())
  copy file (cName) to (cBakName)
  if doserror() != 0
    Warning(cBakName + MsgDosError())
    RETURN .f.
  endif
endif
if (i := fopen(cBakName)) == -1
  Warning(cBakName + MsgDosError(ferror()))
  RETURN .f.
endif
if (o := fcreate(cName)) == -1
  Warning(cName + MsgDosError(ferror()))
  RETURN .f.
endif
do while (cLine := freadline(i)) != NIL
  fwrite(o,xeval(b, cLine) + CR_LF)
enddo
fclose(o)
fclose(i)
RETURN .t.

* #endif UPGRADE_97


**
** Paramätres gÇnÇraux
**
FUNCTION ParaGen
local nHeight := 14
#ifdef DEF_MSG
  MemTxtCor := padr(MemTxtCor,LenIdTpl())
#endif
MemAttrib := padr(MemAttrib,10)
#ifdef DEF_MVS
GsbPeriode(MemMvsPeriode)
MemMvsPeriode := GsbPeriode()
#endif DEF_MVS
open window (MSG042 + " : " + CfgDataBase()) size nHeight,60 help PARAGEN
@ row(), col() say MSG100             get MemName1 ; WinCr()
@ row(), col() say space(len(MSG100)) get MemName2 ; WinCr()
@ row(), col() say space(len(MSG100)) get MemName3 ; WinCr()
WinCr()
say MSG080
@ row(), col() get MemPays picture PIC_ID ;
                           pick PickNat(MemPays)
WinCr()
#ifdef DEF_IMP
@ row(), col() say "Kreditkontrolle " get MemIdCdc picture PIC_ID
WinCr()
* @ row(), col() say "Reeller Kassenstand " get MemSaldo picture "##########"
* WinCr()
#endif DEF_IMP
* WinCr()
say "  " + MsgTva03(UsrLang()) + " "
@ row(), col() get MemNoTVA ;
               picture PIC_ID ;
               postedit {|x| GetNoTva(x,MemPays) } ;
               valid ValNoTva(MemNoTva)
WinCR()
say MSG079
@ row(), col() get MemLang1 picture PIC_ID pick PickLng(MemLang1)
@ CSR_POS+1 get MemLang2 picture PIC_ID pick PickLng(MemLang2)
@ CSR_POS+1 get MemLang3 picture PIC_ID pick PickLng(MemLang3)
#ifdef DEF_4LANG
  @ CSR_POS+1 get MemLang4 picture "!" pick PickLng(MemLang4)
#endif
* WinCR()
* say "  " + MSG004
* @ row(), col() get DevDefault() picture PIC_ID pick PickDev(DevDefault()) ;
*                             valid DevLocate(DevDefault()) != NIL
WinCR()
* #ifdef DEF_ART_OR_PRESTO
*  say MSG007
*  @ row(), col() get MemArtIdDev picture PIC_ID pick PickDev(MemArtIdDev) ;
*                                 valid DevLocate(MemArtIdDev) != NIL
*  WinCR()
* #endif
*    WinCR()
*    say MSG081
*    @ row(), col() get MemLenIdArt picture "##"
*    say MSG083
*    @ row(), col() get MemLenIdGra picture "##"
#ifdef DEF_ART
  WinCR()
  say MSG023
  @ row(), col() get MemPickArtMode picture PIC_ID ;
                     pick PickPickArtMode(MemPickArtMode)
#endif
* WinCR()
* say MSG024
* @ row(), col() get MemLnDecPos picture "##"
* say MSG025
#ifdef DEF_SUB
  WinCR()
  say "Substitutions-Attribute "
  @ row(), col() get MemSubAttrib picture PIC_ID pick PickSubAttrib(MemSubAttrib)
#endif
#ifdef DEF_MSG
  WinCR()
  say MSG001
  @ row(), col() get MemTxtCor picture PIC_ID ;
            pick PickTpl(TPLTYPE_MSG,MemTxtCor)
#endif
#ifdef DEF_MVS
  WinCR()
  say "Aktiver Periodenbereich fÅr Lagervalorisierung "
  @ row(), col() get MemMvsPeriode picture PIC_ID ;
            pick PickPerRange(MemMvsPeriode) // 970407
#endif
WinCr()
say "Datenbank-Attribute "
@ row(), col() get MemAttrib picture PIC_ID pick PickTimAttrib(MemAttrib)
nKey := ReadScr()
close window
RETURN .f. if nKey == K_ESC
MemAttrib := trim(MemAttrib)
AppSaveMem()
RETURN MnuDone()

#ifdef DEF_ART

FUNCTION SetPickArtMode(cStart)
local cNew := PickPickArtMode(MemPickArtMode)
if cNew != NIL
  MemPickArtMode := cNew
  RETURN MnuDone()
endif
RETURN .f.

FUNCTION PickPickArtMode(cStart)
local a := {}
#ifdef LG_FRENCH
  aadd(a, "A : tous les articles    " )
  aadd(a, "G : via groupe d'articles" )
#else
  aadd(a, "A : Alle Artikel         " )
  aadd(a, "G : Åber Artikelgruppe   " )
#endif LG_FRENCH
RETURN ArrayPick(a,trim(MSG023),cStart,1)

#endif DEF_ART

**
** AppDataList()
**
FUNCTION AppDataList
local a := {}
local pa, i
MsgDisplay(CfgDataBase() + " : " + MsgWorking()) // "Travail en cours...")
aadd( a, oUsr() )
aadd( a, oPlz() )
aadd( a, oPar() )
aadd( a, oNat() )
* #ifdef DEF_BNB
*   aadd( a, oBNB() )
* #endif DEF_BNB
#ifdef DEF_IBAN
  aadd( a, oBic() )
#endif DEF_IBAN
#ifdef DEF_LOC
  aadd( a, oLoc() )
#endif DEF_LOC
#ifdef DEF_AMK
  aadd( a, oAmk() )
#endif DEF_AMK
#ifdef DEF_GST
  aadd( a, oGst() )
#endif DEF_GST
#ifdef DEF_MTG
  aadd( a, oMtg() )
#endif DEF_MTG
#ifdef DEF_TSK
  aadd( a, oTsk() )
#endif DEF_TSK
#ifdef DEF_PXT
  pa := PxtTables()
  for i := 1 to len(pa)
    aadd( a, pa[i] )
  next i
#endif DEF_PXT
#ifdef DEF_IMAGES
  aadd( a, oImg() )
#endif DEF_IMAGES
#ifdef DEF_LITERA
  aadd( a, oPub() )
  aadd( a, oAut() )
  aadd( a, oQuo() )
  aadd( a, oPbt() )
#endif DEF_LITERA
#ifdef DEF_WWW
  aadd( a, oRfx() )
  aadd( a, oMsx() )
  * aadd( a, oMst() )
  * aadd( a, oMlm() )
  aadd( a, oNew() )
  aadd( a, oNgr() )
  aadd( a, oTpc() )
  * aadd( a, oTlt() )
  aadd( a, oSrc() )
  aadd( a, oNav() )
  * aadd( a, oMlt() )
* #ifdef DEF_KWD
  aadd( a, oKwd() )
  aadd( a, oKwi() )
* #endif DEF_KWD
#endif DEF_WWW
#ifdef DEF_PLP
  aadd( a, oPlp() )
#endif DEF_PLP
#ifdef DEF_PRB
  aadd( a, oPrb() )  // Probleme
  aadd( a, oPpr() )  // Partnerprobleme
#endif DEF_PRB
#ifdef DEF_ADR
  aadd( a, oAdr() )
  aadd( a, oAdl() )
  aadd( a, oAdm() )
#endif DEF_ADR
#ifdef DEF_CODA
  aadd( a, oCpt() )
  aadd( a, oExt() )
  aadd( a, oMvm() )
  aadd( a, oInf() )
  aadd( a, oCdo() )
#endif DEF_CODA
#ifdef DEF_RSV
  aadd( a, oRsv() )
  aadd( a, oRsi() )
  * aadd( a, oTsl() )
  aadd( a, oRsc() )
  aadd( a, oRst() )
#endif DEF_RSV
#ifdef DEF_RUN
  aadd( a, oArr() )
  aadd( a, oClb() )
  aadd( a, oPos() )
  aadd( a, oRal() )
  aadd( a, oCat() )
  aadd( a, oCty() ) // Kategorisierungsarten
#endif DEF_RUN
#ifdef DEF_FAB
  aadd( a, oFab() )
#endif DEF_FAB
* #ifdef DEF_HTN
*   aadd( a, oHtn() )
*   aadd( a, oHtc() )
*   aadd( a, oHts() )
* #endif DEF_HTN
#ifdef DEF_IPB
  aadd( a, oIpb() )
#endif DEF_IPB
#ifdef DEF_VOC
  aadd( a, oVoc() )
  aadd( a, oVlv() )
  #ifdef DEF_WWW
    aadd( a, oVlm() )
  #endif DEF_WWW
#endif DEF_VOC
* #ifdef DEF_CFN
*   aadd( a, oCfn() )
* #endif DEF_CFN
#ifdef DEF_INT
  aadd( a, oHsi() )
  aadd( a, oInt() )
#endif DEF_INT
#ifdef DEF_TLG
  aadd( a, oTlg() )
#endif DEF_TLG
#ifdef DEF_TIL
  aadd( a, oTil() )
  aadd( a, oTll() )
#endif DEF_TIL
#ifdef DEF_FNA
  aadd( a, oFna() )
#endif DEF_FNA
#ifdef DEF_DCL
  aadd( a, oDcl() )
  aadd( a, oDcf() )
  aadd( a, oDcp() )
#endif DEF_DCL
#ifdef DEF_KVK
  aadd( a, oKvk() )
  aadd( a, oKvl() )
  aadd( a, oZla() )
#endif DEF_KVK
#ifdef DEF_LIC
  aadd( a, oLic() )
  aadd( a, oRel() )
#endif DEF_LIC
#ifdef DEF_BIL
  aadd( a, oBil() )
#endif DEF_BIL
* #ifdef DEF_CFS
*   aadd( a, oCfs() )
* #endif DEF_CFS
#ifdef DEF_ODS
  aadd( a, oOds() )
  aadd( a, oOdl() )
#endif DEF_ODS
#ifdef DEF_PRE
  aadd( a, oPre() )
  aadd( a, oPrl() )
#endif DEF_PRE
* #ifdef DEF_PRD
*   aadd( a, oPrd() )
*   aadd( a, oPrl() )
* #endif DEF_PRD
#ifdef DEF_ALA
  aadd( a, oAla() )
#endif DEF_ALA
#ifdef DEF_REMISE
  aadd( a, oRpp() )
  aadd( a, oRpq() )
#endif DEF_REMISE
#ifdef DEF_PRF
  aadd( a, oPrf() )
#endif DEF_PRF
aadd( a, oCtr() )
#ifdef DEF_ECHE
  aadd( a, oEcl() )
  aadd( a, oEcs() )
#endif DEF_ECHE
#ifdef DEF_MSG
  aadd( a, oMsg() )
#endif
#ifdef DEF_EVT
  aadd( a, oEvt() )
  aadd( a, oEvi() )
  aadd( a, oEvl() )
#endif
#ifdef DEF_PSC
  aadd( a, oPsc() )
#endif
#ifdef DEF_ANW
  aadd( a, oAnw() )
  aadd( a, oAwc() )
#endif
#ifdef DEF_MASQUES
  aadd( a, oTpl() )
#endif
#ifdef DEF_DEV
aadd( a, oDev() )
#endif DEF_DEV
#ifdef DEF_GEN
  aadd( a, oGen() )
#endif DEF_GEN
#ifdef DEF_JNL
  aadd( a, oPer() )
  aadd( a, oJnl() )
  aadd( a, oIfc() )
  * aadd( a, oClt() )
#endif DEF_JNL
#ifdef DEF_VEN
  aadd( a, oVen() )
  aadd( a, oVnl(DocStatClosed()) )
  aadd( a, oIpr() )
#endif
#ifdef DEF_VNLALT
  aadd( a, oVnl(DocStatNew()) )
#endif DEF_VNLALT
#ifdef DEF_TAX
  aadd( a, oReg() )
  * aadd( a, oDcr() )
  aadd( a, oTax() )
#endif DEF_TAX
#ifdef DEF_CTT
  aadd( a, oCtt() )
#endif DEF_CTT
#ifdef DEF_PRESTO
  aadd( a, oAgs() )
  aadd( a, oTac() )
  aadd( a, oTrm() )
  * aadd( a, oPtt() )
#endif
#ifdef DEF_ART
  aadd( a, oArt() )
#endif
#ifdef DEF_UNT
  aadd( a, oUnt() )
#endif
#ifdef DEF_GRA
  aadd( a, oGra() )
#endif
#ifdef DEF_SUB
  aadd( a, oSub() )
#endif
#ifdef DEF_VAR
  aadd( a, oVrt() )
  aadd( a, oVar() )
#endif
#ifdef DEF_ACF
  aadd( a, oAcf() )
#endif
#ifdef DEF_FIN
  aadd( a, oFin() )
  aadd( a, oFnl() )
  aadd( a, oDif() )
#endif
#ifdef DEF_HST
  aadd( a, oHst() )
#endif DEF_HST
#ifdef DEF_CTG
  aadd( a, oCtg() )
#endif DEF_CTG
#ifdef DEF_CTP
  aadd( a, oCtp() )
#endif DEF_CTP
* #ifdef DEF_SHT
*   aadd( a, oSht() )
*   aadd( a, oBal() )
* #endif
#ifdef DEF_IVT
  aadd( a, oIvt() )
  aadd( a, oIvl() )
#endif
#ifdef DEF_VNA
  aadd( a, oTrn() )
  aadd( a, oVna() )
#endif DEF_VNA
#ifdef DEF_MVS
  aadd( a, oMvs() )
#endif DEF_MVS
#ifdef DEF_CTS
  aadd( a, oCts() )
#endif DEF_CTS
* #ifdef DEF_STK
*   aadd( a, oQts() )
* #endif
#ifdef DEF_PTG
  aadd( a, oPtl() )
  aadd( a, oRes() )
#endif
* #ifdef DEF_SHELL
*   aadd( a, oBat() )
* #endif
#ifdef DEF_DGR
  aadd( a, oRap() )
  aadd( a, oRpl() )
  aadd( a, oDgr() )
#endif
* nppmeths.prg wird sowieso gar nicht reingelinkt. Wurde nie benutzt
*#ifdef DEF_NPP
*  aadd( a, oNpp() )
*  aadd( a, oNpa() )
*#endif
#ifdef DEF_FILTER
  aadd( a, oFlt() )
#endif
* #ifdef DEF_LABEL
*   aadd( a, oLbl() )
* #endif
#ifdef DEF_STS
  aadd( a, oSts() )
#endif
#ifdef DEF_SPC
  aadd( a, oSpc() )
#endif
#ifdef DEF_PLS
  aadd( a, oPls() )
  aadd( a, oMbr() )
#endif
#ifdef DEF_PLI
  aadd( a, oPls() )
  aadd( a, oMbr() )
#endif
#ifdef DEF_ALS
  aadd( a, oAls() )
  aadd( a, oAlm() )
#endif
#ifdef DEF_PRJ
  aadd( a, oPrj() )
#endif
#ifdef DEF_PIN
  aadd( a, oPin() )
#endif
#ifdef DEF_HOLZ
  aadd( a, oStm() )
#endif
* #ifdef DEF_DTL
*   aadd( a, oDtl() )
* #endif
#ifdef DEF_IMP
  aadd( a, oCdc() )
  aadd( a, oBud() )
  aadd( a, oImp() )
  aadd( a, oIml() )
  aadd( a, oMvi() )
  aadd( a, oSat() )
  aadd( a, oCtb() )
  aadd( a, oSrv() )
#endif
#ifdef DEF_LNK
  aadd( a, oLni() )
  aadd( a, oLnk() )
#endif
#ifdef DEF_TRA
  aadd( a, oTra() )
  aadd( a, oTrl() )
  aadd( a, oTrt() )
#endif
#ifdef DEF_ANA
  aadd( a, oAna() )
#endif DEF_ANA
#ifdef DEF_MVA
  aadd( a, oMva() )
  aadd( a, oCta() )
  aadd( a, oOda() )
#endif DEF_MVA
#ifdef DEF_SER
  aadd( a, oSer() )
#endif
#ifdef DEF_BIBLIO
  aadd( a, oAut() )
  aadd( a, oObj() )
  aadd( a, oDtp() )
  aadd( a, oGrp() )
  aadd( a, oRef() )
  aadd( a, oRub() )
  aadd( a, oNts() )
  aadd( a, oOut() )
#endif DEF_BIBLIO
#ifdef DEF_LGT
  aadd( a, oLgt() )
#endif DEF_LGT
#ifdef DEF_FRF
  aadd( a, oFrf() )
#endif DEF_FRF
#ifdef DEF_VENREMISE
  aadd( a, oVnr() )
#endif DEF_VENREMISE
#ifdef DEF_KITZ
  aadd( a, oSes() )
  aadd( a, oDis() )
  aadd( a, oLdj() )
  aadd( a, oKrg() )
  aadd( a, oKrl() )
  aadd( a, oKtg() )
#endif DEF_KITZ
#ifdef DEF_DLS
  aadd( a, oDls() )  // Dienstleistungen
  aadd( a, oDla() )  // DL-Arten
#endif  
#ifdef DEF_DLP
  aadd( a, oDlp() )  // DL-Partner (Sitzungsteilnehmer)
#endif DEF_DLP
#ifdef DEF_LPJ
  aadd( a, oLpj() )  // Link PAR-PRJ (Akteure)
#endif
#ifdef DEF_DRG
  aadd( a, oDrg() )  //
  aadd( a, oDrl() )  //
#endif DEF_DRG
asort(a,NIL,NIL,{|x,y| x[AD_FIRST] .or. x[AD_NAME] <= y[AD_NAME]})
RETURN a


#ifdef DEF_STS


**
** StsRebuild() -
**
*FUNCTION StsRebuild
*local i := 0
*local lContinue := .t.
*local nMontS
*local nPamp
*local nQteS
*local cIdArt := NIL
*local nrecNo
*local nQteV
*local nPrixA
*MsgDisplay(MsgWorking()) // travail en cours...
*ddCloseAll()
*open area oSts() exclusive
*  zap
*  MsgDisplay("Analyse des factures achat...")
*  open area oVen(), oVnl(), oArt()
*    go top
*    do while ! eof() .and. lContinue
*      if VEN->Etat == DocStatClosed()
*        if CptIsAchat(JnlIdCtr(VEN->IdJnl))
*          VenScan( {|| VnlAddSts() } )
*        endif
*      endif
*      MsgDisp2(ntrim0(100 * i++ / lastrec()) + "%")
*      lContinue := ! TaskInter()
*      skip
*    enddo
*  close area
*  MsgDisplay("RÇorganisation par article...")
*  i := 0
*  open area oArt()
*    select STS
*    go top
*    do while ! eof()
*      MsgDisp2(ntrim0(100 * i++ / lastrec()) + "%")
*      if STS->IdArt != cIdArt
*        nQteS  := 0
*        nPamp  := 0
*        nMontS := 0
*        cIdArt := STS->IdArt
*        seek STS->IdArt in ART
*      endif
*      **
*      **  PAMP = prix d'achat moyen pondÇrÇ
*      **
*      **
*      **  Berechnung nMontS (Lagerwert am Ende der Periode) :
*      **  1. Anfangs enthÑlt nMontS noch den Lagerwert des Vormonats.
*      **  2. Der Betrag aller EinkÑufe der Periode wird hinzugezÑhlt.
*      **
*      nMontS += val(STS->MontA)
*      **
*      **  3. Die verkauften Artikel werden wieder abgezogen. Aber hier
*      **     wird es jetzt ein klein wenig kompliziert.
*      **     TIM arbeitet hier Åber eine Art FIFO-System.
*      **
*      if qton(STS->QteV) <= nQteS
*        **
*        ** Wenn ich alle VerkÑufe dieser Periode aus dem Lagerbestand der
*        ** vorigen Periode befriedigen kann, werden alle verkauften Artikel
*        ** zum Mittel-EK (nPamp) des Vormonats abgezogen.
*        **
*        nMontS -= nPamp * qton(STS->QteV)
*      else
*        **
*        ** Ansonsten wird zuerst der Bestand des Vormonats geleert, bevor
*        ** man den neuen Bestand anbricht.
*        **
*        nMontS -= nPamp * nQteS
*        **
*        ** FÅr den Rest der verkauften Artikel (nQteV StÅck) wird also der
*        ** Mittel-EK des Monats genommen. (Fall A)
*        ** (Wenn der Bestand ins Negative geht (d.h. man hat einen Artikel
*        ** verkauft, den man noch gar nicht eingekauft hat) dann wird es
*        ** noch mal komplizierter.
*        ** Erste Mîglichkeit: der Artikel wurde in einer der folgenden
*        ** Perioden eingekauft. Dann nimmt man also den ersten Einkaufspreis
*        **
*        ** nQteV : "vom Lagerwert noch abzuziehende Artikel"
*        **
*        nQteV := (qton(STS->QteV) - nQteS)
*        nRecNo := recno()
*        do while nQteV != 0 .and. !eof() .and. STS->IdArt == cIdArt
*          if qton(STS->QteA) != 0 // es wurden Artikel eingekauft...
*            nPrixA := nPamp := val(STS->MontA) / qton(STS->QteA)
*            if qton(STS->QteA) >= nQteV // und sogar genug ...
*              **
*              ** das hier ist Fall A :
*              **
*              nMontS -= (nQteV) * nPrixA
*              nQteV := 0
*            else
*              nMontS -= qton(STS->QteA) * nPrixA
*              nQteV  -= qton(STS->QteA)
*            endif
*          endif
*          skip
*        enddo
*        goto nRecNo
*        if nQteV != 0
*          nPrixA := nPamp := val(ART->Prix2)
*          nMontS -= (nQteV) * nPrixA
*        endif
*      endif
*      nQteS += qton(STS->QteA)
*      nQteS -= qton(STS->QteV)
*      if nQteS != 0
*        nPamp := val(ntom(nMontS)) / nQteS
*      endif
*      **
*      ** MontS und QteS sind die eigentlich interessanten Angaben. Sie sind
*      ** der Grund, warum dieser ganze Zirkus hier Åberhaupt veranstaltet
*      ** wird...
*      **
*      STS->MontS := ntom(nMontS)
*      STS->QteS  := ntoq(nQteS,ART->QteForm)
*      STS->PAMP  := ntom(nPamp)
*      skip
*    enddo
*  close area
*close area
*ddCloseAll()
*RETURN .f.

*FUNCTION VnlAddSts(nQte)
*local nMont
*if VNL->Code == LNCODE_ART
*  nQte *= qton1(VNL->Qte)
*  seek VNL->IdArt in ART
*  select STS
*  seek VNL->IdArt + VEN->Periode
*  if eof()
*    append blank
*    STS->Periode := VEN->Periode
*    STS->IdArt   := VNL->IdArt
*  endif
*  nMont := val(VNL->cMont) * val(VEN->Cours)
*  if VenIsNegative()
*    nMont *= -1
*  endif
*  if CptIsAchat()
*  STS->QteV  := ntoq( qton(STS->QteV) + nQte, ART->QteForm )
*  STS->MontV := ntom(val(STS->MontV) + nMont)
*  select VNL
*endif
*RETURN .T.

*FUNCTION VnlAddSts()
*local nMont
*local nQte
*if VNL->Code == LNCODE_ART
*  nQte := qton1(VNL->Qte)
*  seek left(VNL->IdArt,LenIdArt()) in ART
*  select STS
*  seek left(VNL->IdArt,LenIdArt()) + ACH->Periode
*  if eof()
*    append blank
*    STS->Periode := ACH->Periode
*    STS->IdArt   := VNL->IdArt
*  endif
*  nMont := val(VNL->cMont) * val(ACH->Cours)
*  if JnlDC(VNL->IdJnl) == DC_DEBIT
*    nQte  := - nQte
*    nMont := - nMont
*  endif
*  STS->QteA  := ntoq( qton(STS->QteA) + nQte,ART->QteForm )
*  STS->MontA := ntom(val(STS->MontA) + nMont)
*  select VNL
*endif
*RETURN .T.

#endif DEF_STS

#ifdef DEF_TOOLBOX

#ifdef DEF_GEN

**
** GenRename()
**
FUNCTION GenRename(cIdNew)
local cIdOld := GEN->IdGen
local i := 0
local lDelete := .f.
local lOkay := .f.
local nRecNo1
local nRecNo2
#ifdef DEF_HST
  open area oHst()
    ddSetOrder(ORD_HST_GENDATE)
    lOkay := .t.
    softseek GEN->IdGen
    if ! eof() .and. HST->IdGen == GEN->IdGen
      if ! PerIsOpen(HST->Periode,HST->IdJnl)
        lOkay := .f.
      endif
    endif
  close area
  RETURN .f. if ! lOkay
#endif DEF_HST
if cIdNew == NIL
  cIdNew := space(LenIdGen())
  open window (MSG096) size 5,50 help GENRENA
  do while .t.
    WinHome()
    say GEN->Libell1
    WinCr()
    say MsgOldId() + cIdOld
    WinCr()
    say MsgNewId()
    @ row(), col() get cIdNew pick PickGen(NIL,cIdNew) // GET_PAD
    nKey := ReadScr()
    if nKey == K_ESC
      close window
      RETURN .f.
    endif
    if empty(cIdNew)
      loop
    endif
    exit
  enddo
  close window
endif
open area oGen()
  seek cIdNew
  if eof()
    lOkay := .t.
  else
    lOkay := Confirm( cIdNew + MSG021, MsgUnion() )
    lDelete := .t.
  endif
close area
RETURN .f. if ! lOkay
RETURN .f. if ! Confirm(MSG032 + MSG031 + cIdOld + MSG034 + cIdNew )
ddCloseAll()
RETURN .f. if ! ddRecLock()
SendConsole( "GenRename() " + cIdOld + " -> " + cIdNew )
MsgDisplay( MsgRename() + alias() + " " + cIdOld + " -> " + cIdNew + "...")
#ifdef DEF_VEN
  lOkay := .f.
  open area oVnl(DocStatClosed())
    lOkay := .t.
    ddSetOrder(ORD_VNL_ART)
    softseek cIdOld
    do while lOkay .and. ! eof() ;
                   .and. left(FIELD->IdArt,LenIdGen()) == cIdOld
      nRecNo1 := recno()
      skip
      nRecNo2 := recno()
      if FIELD->Code == LNCODE_GEN
        goto nRecNo1
        if ddRecLock()
          FIELD->IdArt := cIdNew
          i++
          unlock record
        else
          lOkay := .f.
        endif
      endif
      goto nRecNo2
    enddo
  close area
  if ! lOkay ; SendConsole("GenRename() failed !") ; endif
#endif DEF_VEN
#ifdef DEF_VNLALT
  lOkay := .f.
  open area oVnl(DocStatOpen())
    lOkay := .t.
    ddSetOrder(ORD_VNL_ART)
    softseek cIdOld
    do while lOkay .and. ! eof() ;
                   .and. left(FIELD->IdArt,LenIdGen()) == cIdOld
      nRecNo1 := recno()
      skip
      nRecNo2 := recno()
      if FIELD->Code == LNCODE_GEN
        goto nRecNo1
        if ddRecLock()
          FIELD->IdArt := cIdNew
          i++
          unlock record
        else
          lOkay := .f.
        endif
      endif
      goto nRecNo2
    enddo
  close area
  if ! lOkay ; SendConsole("GenRename() failed !") ; endif
#endif DEF_VNLALT
#ifdef DEF_FIN
  lOkay := .f.
  open area oFnl(), oHst(), oCtg()
    lOkay := .t.
    ddSetOrder()
    go top
    do while lOkay .and. ! eof()
      if empty(FNL->IdCtr) .and. left(FNL->IdCpt,LenIdGen()) == cIdOld
        if ddRecLock()
          FNL->IdCpt := cIdNew
          i++
          unlock record
        else
          lOkay := .f.
        endif
      endif
      skip
    enddo
  close area
  if ! lOkay ; SendConsole("GenRename() failed !") ; endif
#endif DEF_FIN
#ifdef DEF_HST
  open area oHst()
    ddSetOrder(ORD_HST_GENDATE)
    softseek cIdOld
    do while lOkay .and. ! eof() .and. HST->IdGen == cIdOld
      nRecNo1 := recno()
      skip
      nRecNo2 := recno()
      goto nRecNo1
      if ddRecLock()
        HST->IdGen := cIdNew
        i++
        unlock record
      else
        lOkay := .f.
      endif
      goto nRecNo2
    enddo
  close area
  if ! lOkay ; SendConsole("GenRename() failed !") ; endif
#endif DEF_HST
#ifdef DEF_CTG
  IndCreate("REBUILD")
#endif DEF_CTG
SetMsg( MsgRename() + MsgDone())
commit
if lDelete
  delete
else
  GEN->IdGen := cIdNew
endif
unlock record
ddCloseAll()
ddRefreshAll()
RETURN MnuDone()

#endif DEF_GEN

**
** ParRename()
**
FUNCTION ParRename(cIdNew)
local cIdOld := PAR->IdPar
local i := 0
local lOkay := .f.
local lDelete := .f.
if cIdNew == NIL
  cIdNew := space(LenIdPar())
  open window "Partner umbenennen" size 5,50 help PARRENA
  do while .T.
    WinHome()
    say ParName()
    WinCr()
    say MsgOldId() + PAR->IdPar
    WinCr()
    say MsgNewId()
    @ row(), col() get cIdNew picture PIC_ID pick PickPar(NIL,cIdNew)
    nKey := ReadScr()
    if nKey == K_ESC
      close window
      RETURN .f.
    endif
    if empty(cIdNew)
      loop
    endif
    exit
  enddo
  close window
endif
open area oPar()
  seek cIdNew
  if eof()
    lOkay := .t.
  elseif Confirm( cIdNew + MSG021, MsgUnion() )
    lOkay := .t.
    lDelete := .t.
  endif
close area
RETURN .f. if ! lOkay
RETURN .f. if ! Confirm(MSG032 + MSG033 + cIdOld + MSG034 + cIdNew )
ddCloseAll()
SendConsole( "ParRename() " + cIdOld + " -> " + cIdNew )
RETURN .f. if ! ddRecLock()
MsgDisplay(MsgWorking())
lOkay := .f.
open area oVen(), oMvs(), oVna(), oTrm(), oHst(), ;
          oFnl(), oMsg(), oPsc(), oAcf(), oMbr(), ;
          oEvi(), oPlp(), oPpr()  ;
          exclusive
  #ifdef DEF_VEN
    select VEN
    ddSetOrder()
    go top
    do while ! eof()
      if VEN->IdPar == cIdOld
        VEN->IdPar := cIdNew
        i++
      endif
      if VEN->IdPar2 == cIdOld
        VEN->IdPar2 := cIdNew
      endif
      skip
    enddo
  #endif
  #ifdef DEF_HST
    select HST
    ddSetOrder()
    go top
    do while ! eof()
      if HST->IdPar == cIdOld
        HST->IdPar := cIdNew
        i++
      endif
      skip
    enddo
  #endif DEF_HST
  #ifdef DEF_FIN
    select FNL
    ddSetOrder()
    go top
    do while ! eof()
      if ! empty(FNL->IdCtr) //  != CPTTYPE_GEN
        if padr(FNL->IdCpt,LenIdPar()) == cIdOld
          FNL->IdCpt := cIdNew
          i++
        endif
      endif
      skip
    enddo
  #endif
  #ifdef DEF_MVS
    select MVS
    ddSetOrder()
    go top
    do while ! eof()
      if MVS->IdPar == cIdOld
        MVS->IdPar := cIdNew
      endif
      skip
    enddo
  #endif DEF_MVS
  #ifdef DEF_VNA
    select VNA
    ddSetOrder()
    go top
    do while ! eof()
      if VNA->IdPar == cIdOld
        VNA->IdPar := cIdNew
      endif
      skip
    enddo
  #endif DEF_VNA
  #ifdef DEF_PSC
    select PSC
    ddSetOrder(ORD_PSC_PAR1)
    softseek cIdOld
    do while PSC->IdPar == cIdOld .and. ! eof()
      PSC->IdPar := cIdNew
      softseek cIdOld
    enddo
    ddSetOrder(ORD_PSC_PAR2)
    softseek cIdOld
    do while PSC->IdPar2 == cIdOld .and. ! eof()
      PSC->IdPar2 := cIdNew
      softseek cIdOld
    enddo
  #endif DEF_PSC
  #ifdef DEF_PLP
    select PLP
    ddSetOrder(ORD_PLP_1)
    softseek cIdOld
    do while PLP->IdPar1 == cIdOld .and. ! eof()
      PLP->IdPar1 := cIdNew
      softseek cIdOld
    enddo
    ddSetOrder(ORD_PLP_2)
    softseek cIdOld
    do while PLP->IdPar2 == cIdOld .and. ! eof()
      PLP->IdPar2 := cIdNew
      softseek cIdOld
    enddo
  #endif DEF_PLP
  #ifdef DEF_PRB
    select PPR
    ddSetOrder(1)
    softseek cIdOld
    do while PPR->IdPar == cIdOld .and. ! eof()
      PPR->IdPar := cIdNew
      softseek cIdOld
    enddo
  #endif DEF_PRB
  #ifdef DEF_PLS
    select MBR
    ddSetOrder(ORD_MBR_PAR)
    softseek cIdOld
    do while MBR->IdPar == cIdOld .and. ! eof()
      MBR->IdPar := cIdNew
      softseek cIdOld
    enddo
    ddSetOrder(ORD_MBR_PAR2)
    softseek cIdOld
    do while MBR->IdPar2 == cIdOld .and. ! eof()
      MBR->IdPar2 := cIdNew
      softseek cIdOld
    enddo
  #endif DEF_PLS
  #ifdef DEF_PLI
    select MBR
    ddSetOrder(ORD_MBR_PAR)
    softseek cIdOld
    do while MBR->IdPar == cIdOld .and. ! eof()
      MBR->IdPar := cIdNew
      softseek cIdOld
    enddo
  #endif DEF_PLI
  #ifdef DEF_MSG
    select MSG
    ddSetOrder()
    go top
    do while ! eof()
      if MSG->IdPar == cIdOld
        MSG->IdPar := cIdNew
      endif
      skip
    enddo
  #endif DEF_MSG
  #ifdef DEF_EVT
    select EVI
    ddSetOrder()
    go top
    do while ! eof()
      if EVI->IdPar == cIdOld
        EVI->IdPar := cIdNew
      endif
      skip
    enddo
  #endif DEF_EVT
  #ifdef DEF_PRESTO
    select TRM
    ddSetOrder()
    go top
    do while !eof()
      if TRM->IdPar == cIdOld
        TRM->IdPar := cIdNew
        i++
      endif
      skip
    enddo
  #endif
  #ifdef DEF_ACF
    select ACF
    ddSetOrder()
    go top
    do while ! eof()
      if ACF->IdPar == cIdOld
        ACF->IdPar := cIdNew
        i++
      endif
      skip
    enddo
  #endif DEF_ACF
  commit
  lOkay := .t.
close area
#ifdef DEF_CTP
  IndCreate("REBUILD")
#endif DEF_CTP
if lOkay
  if lDelete
    delete
  else
    PAR->IdPar := cIdNew
  endif
endif
unlock record
ddCloseAll()
ddRefreshAll()
RETURN MnuDone()



#ifdef DEF_PLS

**
** PlsRename()
**
FUNCTION PlsRename(cIdNew)
local cIdOld := PLS->IdPls
local i := 0
local lOkay := .f.
local lDelete := .f.
if cIdNew == NIL
  cIdNew := PLS->IdPls // space(LenIdPls())
  open window "Liste umbenennen" size 5,50 help LSTRENA
  do while .T.
    WinHome()
    say PLS->Name
    WinCr()
    say MsgOldId() + PLS->IdPls
    WinCr()
    say MsgNewId()
    @ row(), col() get cIdNew picture PIC_ID pick PickPls(cIdNew)
    nKey := ReadScr()
    if nKey == K_ESC
      close window
      RETURN .f.
    endif
    if empty(cIdNew)
      loop
    endif
    exit
  enddo
  close window
endif
open area oPls()
  seek cIdNew
  if eof()
    lOkay := .t.
  elseif Confirm( cIdNew + MSG021, MsgUnion() )
    lOkay := .t.
    lDelete := .t.
  endif
close area
RETURN .f. if ! lOkay
RETURN .f. if ! Confirm(MSG032 + MSG033 + cIdOld + MSG034 + cIdNew )
ddCloseAll()
SendConsole( "PlsRename() " + cIdOld + " -> " + cIdNew )
RETURN .f. if ! ddRecLock()
MsgDisplay(MsgWorking()) // "Ne pas interrompre...")
lOkay := .f.
open area oMbr()
  lOkay := .t.
  * ddSetOrder ORD_MBR_PLSPAR
  ddSetOrder(ORD_MBR_PLSTEXT)
  softseek cIdOld
  do while lOkay .and. MBR->IdPls == cIdOld .and. ! eof()
    if ddRecLock()
      MBR->IdPls := cIdNew
      unlock record
    else
      lOkay := .f.
    endif
    softseek cIdOld
  enddo
  commit
close area
if lOkay
  if lDelete
    delete
  else
    PLS->IdPls := cIdNew
  endif
endif
unlock record
ddCloseAll()
ddRefreshAll()
RETURN SetMnuDone()

#endif DEF_PLS

#ifdef DEF_ALS

**
** AlsRename()
**
FUNCTION AlsRename(cIdNew)
local cIdOld := ALS->IdAls
local i := 0
local lOkay := .f.
local lDelete := .f.
if cIdNew == NIL
  cIdNew := space(LenIdAls())
  open window "Liste umbenennen" size 5,50
  do while .T.
    WinHome()
    say trim(ALS->Name)
    WinCr()
    say MsgOldId() + ALS->IdAls
    WinCr()
    say MsgNewId()
    @ row(), col() get cIdNew picture PIC_ID pick PickAls(cIdNew)
    nKey := ReadScr()
    if nKey == K_ESC
      close window
      RETURN .f.
    endif
    if empty(cIdNew)
      loop
    endif
    exit
  enddo
  close window
endif
open area oAls()
  seek cIdNew
  if eof()
    lOkay := .t.
  elseif Confirm( cIdNew + MSG021, MsgUnion() )
    lOkay := .t.
    lDelete := .t.
  endif
close area
RETURN .f. if ! lOkay
RETURN .f. if ! Confirm(MSG032 + "die Artikelliste " + cIdOld + MSG034 + cIdNew )
ddCloseAll()
SendConsole( "AlsRename() " + cIdOld + " -> " + cIdNew )
RETURN .f. if ! ddRecLock()
MsgDisplay(MsgWorking()) // "Ne pas interrompre...")
lOkay := .f.
open area oAlm()
  lOkay := .t.
  ddSetOrder(ORD_ALM_ALS)
  softseek cIdOld
  do while lOkay .and. ALM->IdAls == cIdOld .and. ! eof()
    if ddRecLock()
      ALM->IdAls := cIdNew
      unlock record
    else
      lOkay := .f.
    endif
    softseek cIdOld
  enddo
  commit
close area
if lOkay
  if lDelete
    delete
  else
    ALS->IdAls := cIdNew
  endif
endif
unlock record
ddCloseAll()
ddRefreshAll()
RETURN SetMnuDone()

#endif DEF_ALS

*#ifdef DEF_HTN
*
***
*** HtcRename()
***
*FUNCTION HtcRename(cIdNew)
*local cIdOld := HTC->IdHtc
*local i := 0
*local lOkay := .f.
*local lDelete := .f.
*if cIdNew == NIL
*  cIdNew := space(LEN_IDHTC)
*  open window "rename chapter" size 5,50
*  do while .t.
*    WinHome()
*    say HTC->Title
*    WinCr()
*    say MsgOldId() + HTC->IdHtc
*    WinCr()
*    say MsgNewId()
*    @ row(), col() get cIdNew picture PIC_ID pick PickHtc(cIdNew)
*    nKey := ReadScr()
*    if nKey == K_ESC
*      close window
*      RETURN .f.
*    endif
*    if empty(cIdNew)
*      loop
*    endif
*    exit
*  enddo
*  close window
*endif
*open area oHtc()
*  seek cIdNew
*  if eof()
*    lOkay := .t.
*  elseif Confirm( cIdNew + MSG021, MsgUnion() )
*    lOkay := .t.
*    lDelete := .t.
*  endif
*close area
*RETURN .f. if ! lOkay
*RETURN .f. if ! Confirm(MSG032 + MSG033 + cIdOld + MSG034 + cIdNew )
*ddCloseAll()
*SendConsole( "HtcRename() " + cIdOld + " -> " + cIdNew )
*RETURN .f. if ! ddRecLock()
*MsgDisplay(MsgWorking()) // "Ne pas interrompre...")
*lOkay := .f.
*open area oHts()
*  lOkay := .t.
*  ddSetOrder 1
*  softseek cIdOld
*  do while lOkay .and. HTS->IdHtc == cIdOld .and. ! eof()
*    if ddRecLock()
*      HTS->IdHtc := cIdNew
*      unlock record
*    else
*      lOkay := .f.
*    endif
*    softseek cIdOld
*  enddo
*  commit
*close area
*open area oHtn()
*  lOkay := .t.
*  ddSetOrder 1
*  softseek cIdOld
*  do while lOkay .and. HTN->IdHtc == cIdOld .and. ! eof()
*    if ddRecLock()
*      HTN->IdHtc := cIdNew
*      unlock record
*    else
*      lOkay := .f.
*    endif
*    softseek cIdOld
*  enddo
*  commit
*close area
*if lOkay
*  if lDelete
*    delete
*  else
*    HTC->IdHtc := cIdNew
*  endif
*endif
*unlock record
*ddCloseAll()
*ddRefreshAll()
*RETURN SetMnuDone()
*
*#endif DEF_HTN

#ifdef DEF_ART

FUNCTION ArtRename
local cOldId  := ART->IdArt
local lUnion := .f.
local lOk := .F.
local cNewId  := NextIdArt(ART->IdArt)
open window (MsgRename() + "Artikel") size 4,40 help ARTRENA
open area oArt()
  do while ! lOk
    WinHome()
    say MsgOldId() + cOldId picture PIC_ID
    WinCr()
    say MsgNewId()
    @ row(), col() get cNewId picture PIC_ID postedit {|x|GetIdArt(x)}
    nKey := ReadScr()
    if nKey == K_ESC
      exit
    endif
    seek cNewId
    if ! eof()
      lUnion := Confirm( ;
        "Artikel " + cNewId + MSG021, ;
        MsgUnion(), MSG_NO ;
      )
      * if lUnion
      *   lUnion := Confirm(MsgSure(),NIL,MSG_NO)
      * endif
      if ! lUnion
        loop
      endif
    endif
    if ! Confirm(MSG032 + cOldId + MSG034 + cNewId + " :" )
      loop
    endif
    lOk := .T.
  enddo
close area
close window
RETURN .f. if ! lOk
ddCloseAll()
RETURN .f. if ! ArtDoRename(cNewId,lUnion)
ddCloseAll()
ddRefreshAll()
RETURN MnuDone()


**
** ArtDoRename() - Renommer article
**
FUNCTION ArtDoRename(cNewId,lUnion)
local lOk := .t.
local cOldId  := ART->IdArt
RETURN .f. if ! ddRecLock()
SendConsole( "ArtRename() " + cOldId + " -> " + cNewId)
MsgDisplay( MsgRename() + alias() + " " + cOldId + " -> " + cNewId + "...")
#ifdef DEF_VEN
  lOK := .f.
  open area oVnl(DocStatClosed())
    lOK := .t.
    ddSetOrder(ORD_VNL_ART)
    softseek cOldId
    do while lOK .and. ! eof() .and. left(FIELD->IdArt,LenIdArt()) == cOldId
      if IsArtCode(FIELD->Code)
        if ddRecLock()
          FIELD->IdArt := cNewId
          unlock record
        else
          lOK := Confirm(MsgContinue())
        endif
        softseek cOldId
      else
        skip
      endif
    enddo
  close area
  if ! lOK ; SendConsole("ArtRename() failed !") ; endif
#endif DEF_VEN
#ifdef DEF_VNLALT
  lOK := .f.
  open area oVnl(DocStatOpen())
    lOK := .t.
    ddSetOrder(ORD_VNL_ART)
    softseek cOldId
    do while lOK .and. ! eof() .and. left(FIELD->IdArt,LenIdArt()) == cOldId
      if IsArtCode(FIELD->Code)
        if ddRecLock()
          FIELD->IdArt := cNewId
          unlock record
        else
          lOK := Confirm(MsgContinue())
        endif
        softseek cOldId
      else
        skip
      endif
    enddo
  close area
  if ! lOK ; SendConsole("ArtRename() failed !") ; endif
#endif DEF_VNLALT
*#ifdef DEF_IVT
*  lOK := .f.
*  open area oIvl()
*    lOK := .t.
*    ddSetOrder
*    go top
*    do while lOk .and. ! eof()
*      if IVL->IdArt == cOldId
*        if ddRecLock()
*          IVL->IdArt := cNewId
*          unlock record
*        else
*          lOK := Confirm(MsgContinue())
*        endif
*      endif
*      skip
*    enddo
*  close area
*#endif DEF_IVT
#ifdef DEF_ACF
  lOK := .f.
  open area oAcf()
    lOK := .t.
    ddSetOrder(ORD_ACF_ART)
    softseek cOldId
    do while lOK .and. ACF->IdArt == cOldId .and. ! eof()
      if ddRecLock()
        ACF->IdArt := cNewId
        unlock record
      else
        lOK := Confirm(MsgContinue())
      endif
      softseek cOldId
    enddo
  close area
  if ! lOK ; SendConsole("ArtRename() failed !") ; endif
#endif DEF_ACF
#ifdef DEF_ALA
  lOK := .f.
  open area oAla()
    lOK := .t.
    go top
    do while lOk .and. ! eof()
      if ALA->IdArt1 == cOldId
        if ddRecLock()
          ALA->IdArt1 := cNewId
          unlock record
        else
          lOK := Confirm(MsgContinue())
        endif
      endif
      if ALA->IdArt2 == cOldId
        if ddRecLock()
          ALA->IdArt2 := cNewId
          unlock record
        else
          lOK := Confirm(MsgContinue())
        endif
      endif
      skip
    enddo
  close area
  if ! lOK ; SendConsole("ArtRename() failed !") ; endif
#endif DEF_ALA
#ifdef DEF_ALS
  lOK := .f.
  open area oAlm()
    lOK := .t.
    ddSetOrder(ORD_ALM_ART)
    softseek cOldId
    do while ALM->IdArt == cOldId .and. ! eof()
      if ddRecLock()
        ALM->IdArt := cNewId
        unlock record
      else
        lOK := Confirm(MsgContinue())
      endif
      softseek cOldId
    enddo
  close area
  if ! lOK ; SendConsole("ArtRename() failed !") ; endif
#endif DEF_ALS
#ifdef DEF_CTS
  lOK := .f.
  open area oCts()
    lOk := .t.
    softseek cOldId
    do while lOK .and. ! eof() .and. CTS->IdArt == cOldId
      if ddRecLock()
        CTS->IdArt := cNewId
        unlock record
      else
        lOK := Confirm(MsgContinue())
      endif
      softseek cOldId
    enddo
  close area
  if ! lOK ; SendConsole("ArtRename() failed !") ; endif
#endif DEF_CTS
#ifdef DEF_ODS
  lOK := .f.
  open area oOdl()
    ddSetOrder(ORD_ODL_ART)
    lOk := .t.
    softseek cOldId
    do while lOK .and. ! eof() .and. ODL->IdArt == cOldId
      if ddRecLock()
        ODL->IdArt := cNewId
        unlock record
      else
        lOK := Confirm(MsgContinue())
      endif
      softseek cOldId
    enddo
  close area
  if ! lOK ; SendConsole("ArtRename() failed !") ; endif
#endif DEF_ODS
#ifdef DEF_VNA
  lOK := .f.
  open area oVna()
    ddSetOrder(ORD_VNA_ARTDATE)
    lOk := .t.
    softseek cOldId
    do while lOK .and. ! eof() .and. VNA->IdArt == cOldId
      if ddRecLock()
        VNA->IdArt := cNewId
        unlock record
      else
        lOK := Confirm(MsgContinue())
      endif
      softseek cOldId
    enddo
  close area
  if ! lOK ; SendConsole("ArtRename() failed !") ; endif
#endif DEF_CTS
if lOk
  #ifdef DEF_IDART2
    lOk := .f.
    open area oArt()
      lOK := .t.
      go top
      do while lOK .and. ! eof()
        if ART->IdArt2 == cOldId
          if ddRecLock()
            ART->IdArt2 := cNewId
            unlock record
          else
            lOK := Confirm(MsgContinue())
          endif
        endif
        skip
      enddo
    close area
    if ! lOK ; SendConsole("ArtRename() failed !") ; endif
  #endif DEF_IDART2
  if lOk
    if lUnion
      delete
    else
      ART->IdArt := cNewId
    endif
    SetMsg( MsgRename() + MsgDone())
  endif
endif
unlock record
RETURN lOk

#endif DEF_ART


#ifdef DEF_GRA

**
** GraRename() - Renommer article
**
FUNCTION GraRename()
local cOldId  := GRA->iGra
local cNewId  := GRA->iGra
local i
local nKey
local lUnion := .f.
local lOk := .F.
local MSG_WHAT := "Artikelgruppe"
local nRecNo1
local nRecNo2
open window (MsgRename() + MSG_WHAT) size 4,40 help GRARENA
open area oGra()
  do while ! lOk
    WinHome()
    say MsgOldId() + cOldId picture PIC_ID
    WinCr()
    say MsgNewId()
    @ row(), col() get cNewId picture PIC_ID
    nKey := ReadScr()
    if nKey == K_ESC
      exit
    endif
    seek cNewId
    if ! eof()
      lUnion := Confirm( ;
        MSG_WHAT + " " + cNewId + MSG021, ;
        MsgUnion() ;
      )
      if ! lUnion
        loop
      endif
    endif
    if ! Confirm(MSG032 + cOldId + MSG034 + cNewId + " :" )
      loop
    endif
    lOk := .T.
  enddo
close area
close window
RETURN .f. if ! lOk
**
** Jetzt geht es echt los !
**
ddCloseAll()
RETURN .f. if ! ddRecLock()
SendConsole( "GraRename() " + cOldId + " -> " + cNewId )
MsgDisplay(MsgRename() + MSG_WHAT + " " + cOldId + " -> " + cNewId + "...")
open area oArt() exclusive
  ddSetOrder(ORD_ART_GRA)
  softseek cOldId
  do while ! eof() .and. ART->iGra == cOldId
    nRecNo1 := recno()
    skip
    nRecNo2 := recno()
    goto nRecNo1
    ART->iGra := cNewId
    goto nRecNo2
  enddo
close area
if ! lUnion
  GRA->iGra := cNewId
endif
unlock record
ddCloseAll()
ddRefreshAll()
RETURN NIL

#endif DEF_GRA

#ifdef DEF_ANA

FUNCTION AnaRename
local cOldId  := ANA->IdAna
local lUnion := .f.
local lOk := .F.
local cNewId  := ANA->IdAna
open window (MsgRename() + "Analysekonto") size 4,40 help ANARENA
open area oAna()
  do while ! lOk
    WinHome()
    say MsgOldId() + cOldId picture PIC_ID
    WinCr()
    say MsgNewId()
    @ row(), col() get cNewId picture PIC_ID postedit {|x|GetIdAna(x)}
    nKey := ReadScr()
    if nKey == K_ESC
      exit
    endif
    seek cNewId
    if ! eof()
      lUnion := Confirm( ;
        "Analysekonto " + cNewId + MSG021, ;
        MsgUnion(), MSG_NO ;
      )
      if ! lUnion
        loop
      endif
    endif
    if ! Confirm(MSG032 + cOldId + MSG034 + cNewId + " :" )
      loop
    endif
    lOk := .T.
  enddo
close area
close window
RETURN .f. if ! lOk
ddCloseAll()
RETURN .f. if ! AnaDoRename(cNewId,lUnion)
ddCloseAll()
ddRefreshAll()
RETURN MnuDone()


**
** AnaDoRename() - Renommer compte analytique
**
FUNCTION AnaDoRename(cNewId,lUnion)
local lOk := .t.
local cOldId  := ANA->IdAna
RETURN .f. if ! ddRecLock()
SendConsole( "AnaRename() " + cOldId + " -> " + cNewId)
MsgDisplay( MsgRename() + alias() + " " + cOldId + " -> " + cNewId + "...")
lOK := .f.
#ifdef DEF_HST
  open area oHst()
    lOK := .t.
    ddSetOrder(ORD_HST_ANA)
    softseek cOldId
    do while lOK .and. HST->IdAna == cOldId .and. ! eof()
      if ddRecLock()
        HST->IdAna := cNewId
        unlock record
      else
        lOK := Confirm(MsgContinue())
      endif
      softseek cOldId
    enddo
  close area
  if ! lOK ; SendConsole("AnaRename() failed !") ; endif
#endif DEF_HST
#ifdef DEF_MVA
  lOK := .f.
  open area oMva()
    lOK := .t.
    ddSetOrder(ORD_MVA_CPTDATE)
    softseek cOldId
    do while lOK .and. MVA->IdAna == cOldId .and. ! eof()
      if ddRecLock()
        MVA->IdAna := cNewId
        unlock record
      else
        lOK := Confirm(MsgContinue())
      endif
      softseek cOldId
    enddo
  close area
  if ! lOK ; SendConsole("AnaRename() failed !") ; endif
  lOK := .f.
  open area oCta()
    lOk := .t.
    softseek cOldId
    do while lOK .and. ! eof() .and. CTA->IdAna == cOldId
      if ddRecLock()
        CTA->IdAna := cNewId
        unlock record
      else
        lOK := Confirm(MsgContinue())
      endif
      softseek cOldId
    enddo
  close area
  if ! lOK ; SendConsole("AnaRename() failed !") ; endif
#endif DEF_MVA
*#ifdef DEF_MSG
*  lOK := .f.
*  open area oMsg()
*    ddSetOrder(ORD_MSG_ANA)
*    lOk := .t.
*    softseek cOldId
*    do while lOK .and. ! eof() .and. MSG->IdAna == cOldId
*      if ddRecLock()
*        MSG->IdAna := cNewId
*        unlock record
*      else
*        lOK := Confirm(MsgContinue())
*      endif
*      softseek cOldId
*    enddo
*  close area
*  if ! lOK ; SendConsole("AnaRename() failed !") ; endif
*#endif DEF_MSG
if lOk
  if lUnion
    delete
  else
    ANA->IdAna := cNewId
  endif
  SetMsg( MsgRename() + MsgDone())
endif
unlock record
RETURN lOk

#endif DEF_ANA


#ifdef DEF_PRJ

**
** PrjRename() - Renommer article
**
FUNCTION PrjRename()
local cOldId  := PRJ->IdPrj
local cNewId  := space(len(PRJ->IdPrj))
local i
local nKey
local lUnion := .f.
local lOk := .F.
open window (MsgRename() + "Projekt") size 4,40 help PRJRENA
open area oPrj()
  do while ! lOk
    WinHome()
    say MsgOldId() + cOldId picture PIC_ID
    WinCr()
    say MsgNewId()
    @ row(), col() get cNewId picture PIC_ID
    nKey := ReadScr()
    if nKey == K_ESC
      exit
    endif
    seek cNewId
    if ! eof()
      lUnion := Confirm( ;
        "Projekt " + cNewId + MSG021, ;
        MsgUnion() ;
      )
      if ! lUnion
        loop
      endif
    endif
    if ! Confirm(MSG032 + cOldId + MSG034 + cNewId + " :" )
      loop
    endif
    lOk := .T.
  enddo
close area
close window
RETURN .f. if ! lOk
**
** Jetzt geht es echt los !
**
ddCloseAll()
RETURN .f. if ! ddRecLock()
open area oPin(), oVen(), oTrm()
  SendConsole("PrjRename() : " + cOldId + " to " + cNewId )
  MsgDisplay(MsgWorking())
  #ifdef DEF_VEN
    select VEN
    ddSetOrder(ORD_VEN_PRJ)
    softseek cOldId
    i := 0
    do while ! eof() .and. VEN->IdPrj == cOldId
      if ddRecLock()
        VEN->IdPrj := cNewId
        unlock record
      else
        SendConsole(MsgIdJnlDoc() + " : PrjRename() failed !")
        lOK := .f.
      endif
      softseek cOldId
    enddo
  #endif DEF_VEN
  #ifdef DEF_PIN
    select PIN
    ddSetOrder(ORD_PIN_IDPRJ)
    softseek cOldId
    do while ! eof() .and. PIN->IdPrj == cOldId
      if ddRecLock()
        PIN->IdPrj := cNewId
        unlock record
      else
        SendConsole("PIN"+dbf_ext()+" (" +ntrim(recno()) + ") : PrjRename() failed !")
        lOK := .f.
      endif
      softseek cOldId
    enddo
  #endif DEF_PIN
  #ifdef DEF_PRESTO
    select TRM
    ddSetOrder(ORD_TRM_PRJ)
    softseek cOldId
    i := 0
    do while ! eof() .and. TRM->IdPrj == cOldId
      if ddRecLock()
        TRM->IdPrj := cNewId
        unlock record
      else
        SendConsole("TRM"+dbf_ext()+" (" +ntrim(recno()) + ") : PrjRename() failed !")
        lOK := .f.
      endif
      softseek cOldId
    enddo
  #endif
close area
if lUnion
  delete
else
  PRJ->IdPrj := cNewId
endif
unlock record
ddCloseAll()
if lOK
  SetMsg( MsgRename() + MsgDone())
else
  SetMsg("")
  Warning( ;
    "PrjRename() : nicht alle Records konnten angepasst werden !", ;
    "Siehe CONSOLE.MSG !" ;
  )
endif
ddRefreshAll()
RETURN NIL

#endif DEF_PRJ

#ifdef LG_GERMAN

FUNCTION MsgRename ; RETURN "Umbennennen "
FUNCTION MsgOldId  ; RETURN "Alte Nummer : "
FUNCTION MsgNewId  ; RETURN "Neue Nummer : "
FUNCTION MsgUnion  ; RETURN "Referenzen zusammenfassen und aktuellen Record lîschen (J/N) ?"

#endif

#ifdef LG_FRENCH

FUNCTION MsgRename ; RETURN "Renommer "
FUNCTION MsgOldId  ; RETURN "Ancien ID : "
FUNCTION MsgNewId  ; RETURN "Nouvel ID : "
FUNCTION MsgUnion  ; RETURN "Regrouper les rÇfÇrences et supprimer l'enreg. courant (O/N) ?"

#endif

#ifdef LG_EN

FUNCTION MsgRename ; RETURN "Rename "
FUNCTION MsgOldId  ; RETURN "Old ID : "
FUNCTION MsgNewId  ; RETURN "New ID : "
FUNCTION MsgUnion  ; RETURN "Merge references of both IDs and delete current record (Y/N) ?"

#endif

#endif DEF_TOOLBOX

*#ifdef DEF_MVP
*
**
** TimCentral()
**
*FUNCTION TimCentral
*local cParCentral := BUTTON_ON
*local cLettre     := BUTTON_ON
*open window (MSG078) size 6,40 help CENTRAL
*  @ row(), col() get cParCentral checkbox
*  say " " + MSG067
*  WinCr()
*  @ row(), col() get cLettre checkbox
*  say " " + MSG092
*  WinCr()
*  GetPreview()
*  GetTplIni("LISTE")
*  nKey := ReadScr()
*close window
*RETURN .f. if nKey == K_ESC
*open printer SetTplIni() width 80 ;
*             preview SetPreview() ;
*             TitBlock {|| PrintHeader(MSG078) }
*if ! LstContinue()
*  close printer
*  RETURN .f.
*endif
*close printer
*RETURN MnuDone()
*
*#endif DEF_MVP


#define SUM_IDJNL    1
#define SUM_PERIODE  3
#define SUM_DEBIT    4
#define SUM_CREDIT   5
#define SUM_ALEN     2

*FUNCTION SumCollect(aSum,jnc,cIdJnl,cPeriode,nDebit,nCredit)
*local i
*local a := NIL
*local nPos := at(cIdJnl,jnc[JNC_JNLLIST])
*RETURN NIL if nPos == 0
*for i := 1 to len(aSum)
*  if aSum[i][SUM_PERIODE] == cPeriode
*    a := aSum[i]
*    exit
*  endif
*next i
*if a == NIL
*  a := array(SUM_ALEN)
*  a[SUM_IDJNL]   := cIdJnl
*  a[SUM_PERIODE] := cPeriode
*  a[SUM_DEBIT]   := 0
*  a[SUM_CREDIT]  := 0
*  aadd(aSum,a)
*endif
*if substr(jnc[JNC_JNLLIST],nPos-1,1) == "-"
*  a[SUM_DEBIT]  -= nDebit
*  a[SUM_CREDIT] -= nCredit
*else
*  a[SUM_DEBIT]  += nDebit
*  a[SUM_CREDIT] += nCredit
*endif
*RETURN NIL



#ifdef DEF_MVA

**
** CtaRebuild() - Sammelhistorik Analysekonten rekonstruieren
**
FUNCTION CtaRebuild()
local nCount := 0
local lOkay := .f.
local jnl
local aCta := {}
local doc
ddCloseAll()
open area oCta() exclusive
  zap
  lOkay := .t.
close area
RETURN .f. if ! lOkay
ddCloseAll()
open area oMva()
  lOkay := .t.
  go top
  do while lOkay .and. ! eof()
    if TaskInter() ; lOkay := .f. ; exit ; endif
    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
    if (doc := DocInfo(MVA->IdJnl,MVA->IdDoc)) != NIL
      if doc[DOC_ETAT] == DocStatClosed()
        if ! CtaCollect(aCta,MVA->Periode,val(MVA->Mont))
          lOkay := .f.
          exit
        endif
        if len(aCta) > 50
          if CtaUpdate(aCta)
            aCta := {}
          else
           lOkay := .f.
           exit
          endif
        endif
      endif
    endif
    skip
  enddo
close area
RETURN .f. if ! lOkay
RETURN CtaUpdate(aCta)


#endif DEF_MVA





#ifdef DEF_RUN
  FUNCTION LenIdCty ; RETURN snLenIdCty
  FUNCTION LenIdRal ; RETURN snLenIdRal
  FUNCTION LenIdCat ; RETURN snLenIdCat
  FUNCTION LenIdClb ; RETURN snLenIdClb
  FUNCTION LenIdEqu ; RETURN snLenIdEqu
  FUNCTION AgeByYear ; RETURN slAgeByYear
#endif DEF_RUN

#ifdef DEF_FAB
  FUNCTION LenIdFab ; RETURN snLenIdFab
#endif DEF_FAB

#ifdef DEF_GEN
FUNCTION OnGenCtrExist(cIdGen,cPeriode,cIdJnl)
RETURN xeval(sxlOnGenCtrExist,cIdGen,cPeriode,cIdJnl)

* #ifdef DEF_JNL
FUNCTION OnGenJnlExist(cIdGen,cPeriode,cIdJnl)
RETURN xeval(sxlOnGenJnlExist,cIdGen,cPeriode,cIdJnl)
* #endif DEF_JNL
#endif DEF_GEN


#ifdef DEF_VNA

FUNCTION AddVnaEvent(x)
local b := cblock(x)
RETURN .f. if b == NIL
default saOnVnaGenerate to {}
aadd(saOnVnaGenerate,b)
RETURN .t.


#endif DEF_VNA

#ifdef DEF_HOLZ

FUNCTION AddStmCopy(x)
local b := cblock(x)
RETURN .f. if b == NIL
default saPreStmCopy to {}
aadd(saPreStmCopy,b)
RETURN .t.

#endif DEF_VNA

#ifdef DEF_VEN


FUNCTION AddVnlPreClose(x)
local b := cblock(x)
RETURN .f. if b == NIL
default saVnlPreClose to {}
aadd(saVnlPreClose,b)
RETURN .t.

* FUNCTION AddVenPostEdit(x)
* local b := cblock(x)
* RETURN .f. if b == NIL
* default saVenPostedit to {}
* aadd(saVenPostEdit,b)
* RETURN .t.

FUNCTION AddVnlIdValidate(x)
local b := cblock(x)
RETURN .f. if b == NIL
default saVnlIdValidate to {}
aadd(saVnlIdValidate,b)
RETURN .t.

FUNCTION AddVnlVarCollect(x)
local b := cblock(x)
RETURN .f. if b == NIL
default saVnlVarCollect to {}
aadd(saVnlVarCollect,b)
RETURN .t.

FUNCTION AddVenParValidate(x)
local b := cblock(x)
RETURN .f. if b == NIL
default saVenParValidate to {}
aadd(saVenParValidate,b)
RETURN .t.

#endif DEF_VEN


FUNCTION LenIdDoc ; RETURN snLenIdDoc
FUNCTION LenIdCtr ; RETURN snLenIdCtr
FUNCTION LenQte   ; RETURN snLenQte
FUNCTION LenTel   ; RETURN snLenTel
#ifdef DEF_ART
  FUNCTION LenIdArt ; RETURN snLenIdArt
  FUNCTION LenArtRoot ; RETURN snLenArtRoot
  FUNCTION ArtIsTotal(cIdArt) ; RETURN eval(sbArtIsTotal,cIdArt)
  FUNCTION ArtName(cIdArt,cIdLng) ; RETURN eval(sbArtName,cIdArt,cIdLng)
  FUNCTION PicIdArt  ; RETURN scPicIdArt
#else
  FUNCTION LenIdArt ; RETURN 2
#endif DEF_ART
FUNCTION LenParAttrib ; RETURN snLenParAttrib
FUNCTION LenArtName ; RETURN snLenArtName
FUNCTION LenGenName ; RETURN snLenGenName
FUNCTION LenParName ; RETURN snLenParName
FUNCTION LenGraName ; RETURN snLenGraName
FUNCTION QteEmpty   ; RETURN slQteEmpty
FUNCTION VnlAnzahl  ; RETURN eval(sbVnlAnzahl)
#ifdef DEF_SER
  FUNCTION IdSerDefault
  RETURN &scIdSerDefault
#endif DEF_SER
#ifdef DEF_SER
  FUNCTION LenIdSer ; RETURN snLenIdSer
#endif DEF_SER
#ifdef DEF_INT
  FUNCTION LenIdInt ; RETURN snLenIdInt
#endif DEF_INT
* #ifdef DEF_LGT
*   FUNCTION LenIdLgt ; RETURN snLenIdLgt
* #endif DEF_LGT

FUNCTION TimTestAllow(c)
local i
local lOkay
for i := 1 to len(saTimTestAllow)
  lOkay := xeval(saTimTestAllow[i],c)
  default lOkay to .f.
  RETURN .t. if lOkay
next i
RETURN .f.

#ifdef DEF_VNA
  FUNCTION OnVnaGenerate   ; RETURN DoEvents(saOnVnaGenerate,"OnVnaGenerate")
  FUNCTION OnVnaSuggest   ; RETURN DoEvents(saOnVnaSuggest,"OnVnaSuggest")
  FUNCTION PreVnaCollect   ; RETURN eval(sbPreVnaCollect)
  FUNCTION VnlVnaCount   ; RETURN eval(sbVnlVnaCount)
  FUNCTION VnaMustEdit   ; RETURN eval(xlVnaMustEdit)
  FUNCTION ParVnaStop(jnl) ; RETURN eval(sbParVnaStop,jnl)
  FUNCTION VnaMatch() ; RETURN eval(sbVnaMatch)
  * FUNCTION OnVnaGenerate     ; RETURN eval(sbOnVnaGenerate)
  * FUNCTION VnaPreEdit        ; RETURN eval(sbVnaPreEdit)
  FUNCTION PreVnaUndo ; RETURN xparse(xlPreVnaUndo)
  * FUNCTION VnlVnaMatch         ; RETURN eval(sbVnlVnaMatch)
  * FUNCTION VnaCopyFilter       ; RETURN &(sxVnaCopyFilter)
  * FUNCTION PreVnaSuggest(dDate)  ; RETURN xeval(sblPreVnaSuggest,dDate)
#endif DEF_VNA
#ifdef DEF_ODS
  FUNCTION OnOdlPreClose      ; RETURN DoEvents(saOnOdlPreClose)
#endif DEF_ODS
#ifdef DEF_VEN
  FUNCTION VnlPreClose      ; RETURN DoEvents(saVnlPreClose)
  FUNCTION LenLstVen        ; RETURN snLenLstVen
  FUNCTION LenVnlName       ; RETURN snLenVnlName
  FUNCTION OnVenClose       ; RETURN xeval(sbOnVenClose)
  FUNCTION OnVnlClose(a)
  local i
  local u
  for i := 1 to len(saOnVnlClose)
    u := eval(saOnVnlClose[i])
    if u != NIL
      aadd(a,u)
    endif
  next i
  RETURN .t.
  FUNCTION VenMfcDefault    ; RETURN eval(sbVenMfcDefault)
  * FUNCTION DoParMfcDefault  ; RETURN xeval(sbDoParMfcDefault)
  FUNCTION VenDocLibell     ; RETURN xeval(sbVenLibell)
  FUNCTION AfterVenClose       ; RETURN DoEvents(sbAfterVenClose)
  FUNCTION OnVenParValidate ; RETURN DoEvents(saVenParValidate)
  FUNCTION OnVnlIdValidate  ; RETURN DoEvents(saVnlIdValidate)
  FUNCTION OnVnlVarCollect  ; RETURN DoEvents(saVnlVarCollect)
  FUNCTION PreVnlDelete     ; RETURN xeval(sbPreVnlDelete)
  FUNCTION VnlTotBegin()  ; RETURN eval(sbVnlTotBegin)
  FUNCTION VnlAqtFill(nQte,nQteStat)
  RETURN eval(sbVnlAqtFill,nQte,nQteStat)
  FUNCTION VnlIsAqt() ;  RETURN eval(sbVnlIsAqt)
  FUNCTION VenMatch         ; RETURN eval(sbVenHstMatch)
  FUNCTION VnlQteBase()     ; RETURN xeval(sbVnlQteBase)
  FUNCTION QteValidate()     ; RETURN xeval(sbQteValidate)
  #ifdef DEF_PRIXR
  FUNCTION VnlPrixR()       ; RETURN eval(sbVnlPrixR)
  #endif DEF_PRIXR
  #ifdef DEF_IPB
  FUNCTION ArtIdGen(cIdCtr)       ; RETURN eval(sbArtIdGen,cIdCtr)
  #endif DEF_IPB
  #ifdef DEF_INT
  FUNCTION VnlIntDefault()       ; RETURN eval(sbVnlIntDefault)
  #endif DEF_INT

  FUNCTION TagVnaAttrib(cIdJnl)
  RETURN eval(sbcNafAttr,cIdJnl)


#endif DEF_VEN
#ifdef DEF_TAX
  FUNCTION TolerateTax()     ; RETURN eval(sbTolerateTax)
#endif
#ifdef DEF_FIN
FUNCTION FnlFillFilter ; RETURN DoEvents(saFnlFillFilter)
FUNCTION LenFnlName   ; RETURN snLenFnlName
FUNCTION PreFnlAppend ; RETURN DoEvents(saPreFnlAppend,"PreFnlAppend")
FUNCTION CheckFinSolde ; RETURN eval(sxlCheckFinSolde)
FUNCTION FinTolerance ; RETURN eval(sxnFinTolerance)
#endif DEF_FIN
#ifdef DEF_PLS
  FUNCTION LenIdPls ; RETURN snLenIdPls
  FUNCTION LenMbrRemark ; RETURN snLenMbrRemark
#endif DEF_PLS
#ifdef DEF_PLI
  FUNCTION LenIdPls ; RETURN snLenIdPls
  FUNCTION LenMbrRemark ; RETURN snLenMbrRemark
#endif DEF_PLI
#ifdef DEF_ADR
  FUNCTION LenIdAdl ; RETURN snLenIdAdl
#endif DEF_ADR
#ifdef DEF_ALS
  FUNCTION LenIdAls ; RETURN snLenIdAls
#endif DEF_ALS
#ifdef DEF_KVK
FUNCTION IdZlaDefault ; RETURN scIdZlaDefault
#endif DEF_FIN
#ifdef DEF_BIL
FUNCTION LenIdBil ; RETURN snLenIdBil
#endif DEF_BIL
#ifdef DEF_BIBLIO
FUNCTION LenIdRub ; RETURN snLenIdRub
FUNCTION LenIdNts ; RETURN snLenIdNts
#endif DEF_BIBLIO
FUNCTION UseAdsDbe ; RETURN slUseAdsDbe
#ifdef __XPP__
FUNCTION DbeCollation ; RETURN snCollation
#endif __XPP__
FUNCTION UseDbe ; RETURN scUseDbe
FUNCTION LenIdTpl ; RETURN snLenIdTpl
FUNCTION LenIdGen       ; RETURN snLenIdGen
#ifdef DEF_GEN
  FUNCTION LenIdGenHeader ; RETURN snLenGenHeader
#endif DEF_GEN
#ifdef DEF_ART
  FUNCTION PicIdGra  ; RETURN scPicIdGra
  FUNCTION LenIdGra  ; RETURN snLenIdGra
  FUNCTION LenArtRef ; RETURN snLenArtRef
  FUNCTION LenIdPga ; RETURN snLenIdPga
  FUNCTION ArtFilter ; RETURN sxlArtFilter
  FUNCTION NextIdArt(x) ; RETURN eval(sbNextIdArt,x)
  FUNCTION NextIdGra(x) ; RETURN eval(sbNextIdGra,x)
  FUNCTION GetIdArt(x) ; RETURN eval(sbGetIdArt,x)
  FUNCTION GetIdGra(x) ; RETURN eval(sbGetIdGra,x)
  FUNCTION IdArtValidate(x) ; RETURN eval(sbIdArtValidate,x)
  FUNCTION IdGraValidate(x) ; RETURN eval(sbIdGraValidate,x)
  FUNCTION LenRefExt ; RETURN snLenAcfRef
  FUNCTION PreArtCreate   ; RETURN eval(sbPreArtCreate)
#else
  FUNCTION LenArtRef ; RETURN 0
#endif DEF_ART
#ifdef DEF_ACF
  FUNCTION AcfIdCtr   ; RETURN eval(sbAcfIdCtr)
  FUNCTION DoVnlAcfUpdate   ; RETURN eval(sbDoVnlAcfUpdate)
  FUNCTION MustAcfReplicate   ; RETURN eval(sbMustAcfReplicate)
#endif DEF_ACF

FUNCTION LenIdPar ; RETURN snLenIdPar
FUNCTION GetIdPar(x,cIdPrt) ; RETURN eval(sbGetIdPar,x,cIdPrt)
FUNCTION IdParValidate(cIdPar)  ; RETURN eval(sbIdParValidate,cIdPar)
FUNCTION NextIdPar(cIdPrt) ; RETURN eval(sbNextIdPar,cIdPrt)

FUNCTION LenIdJnl ; RETURN snLenIdJnl
* FUNCTION LenIdTac ; RETURN snLenIdGen
FUNCTION LenIdPrj ; RETURN snLenIdPrj
FUNCTION LenIdUnt ; RETURN snLenIdUnt
FUNCTION LenIdMfc ; RETURN snLenIdMfc
#ifdef DEF_ANA
  FUNCTION LenIdAna ; RETURN snLenIdAna
  FUNCTION GetIdAna(x) ; RETURN eval(sbGetIdAna,x)
  FUNCTION NoDocMvaCheck      ; RETURN  eval(sbNoDocMvaCheck)
  FUNCTION VnlIdAna      ; RETURN  eval(sbVnlIdAna)
#else
  FUNCTION LenIdAna() ; RETURN 0
  FUNCTION VnlIdAna() ; RETURN NIL
#endif DEF_ANA
#ifdef DEF_HOLZ
  FUNCTION LenIdStm ; RETURN snLenIdStm
  FUNCTION OnStmCreate ; RETURN scOnStmCreate
  FUNCTION PreStmCopy  ; RETURN DoEvents(saPreStmCopy,"PreStmCopy")
#endif DEF_HOLZ


#ifdef DEF_MULT

FUNCTION AddVnlRoundError(x)
local b := cblock(x)
RETURN .f. if b == NIL
default saVnlRoundError to {}
aadd(saVnlRoundError,b)
RETURN .t.

FUNCTION OnVnlRoundError() ; RETURN DoEvents(saVnlRoundError)

#endif DEF_MULT

FUNCTION OnParSelect
local i
for i := 1 to len(saOnParSelect)
  RETURN .f. if ! xparse(saOnParSelect[i])
next i
RETURN .t.
// &scOnParSelect

#ifdef DEF_ABO

FUNCTION AboParFilter ; RETURN DoEvents(saAboParFilter)
FUNCTION AboVnaFilter ; RETURN DoEvents(saAboVnaFilter)

#endif DEF_ABO

FUNCTION LenIdPgp ; RETURN snLenIdPgp
FUNCTION LenIdRga ; RETURN snLenIdRga
FUNCTION PerShift ; RETURN snPerShift
#ifdef DEF_GEN
  FUNCTION LenCompte ; RETURN max(snLenIdPar,snLenIdGen)
  FUNCTION LenObjet  ; RETURN max(snLenIdArt,snLenIdGen)
#else
  FUNCTION LenObjet  ; RETURN snLenIdArt
#endif DEF_GEN


FUNCTION MvpMontant(cDC)
RETURN val(FIELD->Mont) if FIELD->DC == cDC
RETURN 0


* FUNCTION JnlIsInList(cIdJnl,aJnl)
* local i
* * RETURN .t. if len(aJnl) == 0
* for i := 1 to len(aJnl)
*   RETURN .t. if aJnl[i][JNL_IDJNL] == cIdJnl
* next i
* RETURN .f.


/******* ist nicht abgecheckt wegen ArtPrix1()
*
*#ifdef DEF_ART_REF
*
*#define MSG_CONFIRM " énderungen bestÑtigen"
*
***
*** AcfPrxUpdate
***
*FUNCTION AcfPrxUpdate
** local nRow
** local nCol
*local lOkay := .t.
*local cPrix1
*local cPrix2
*local aPrx := {}
** local cPrix3
*local cPrixA
*local cConfirm := BUTTON_ON
*static cIdArt1 := NIL
*static cIdArt2 := NIL
*static cRef1 := NIL
*static cRef2 := NIL
*static cIdPar := NIL
*static cFilter := ""
*static cxPrix1 := "val(ART->Prix1)"
*static cxPrix2 := "val(ART->Prix2)"
*static cxPrixA := "val(ACF->Prix)"
*default cIdArt1 to space(LenIdArt())
*default cIdArt2 to space(LenIdArt())
*default cRef1 to space(LenArtRef())
*default cRef2 to space(LenArtRef())
*default cIdPar to space(LenIdPar())
*aadd(aPrx, {} )
*cRef1 := padr(cRef1,LenArtRef())
*cRef2 := padr(cRef2,LenArtRef())
*open window (MsgArtPrxUpdate()) size 10,60 help "ACFPRX" home 2,0
*  cFilter := padr(cFilter,128)
*  cxPrix1 := padr(cxPrix1,128)
*  cxPrix2 := padr(cxPrix2,128)
*  cxPrixA := padr(cxPrixA,128)
*  say "Lieferant "
*  get cIdPar picture PIC_ID pick PickPar(NIL,cIdPar)
*  WinCr()
*  say "Artikelnummer von "
*  get cIdArt1
*  say " bis "
*  get cIdArt2
*  WinCr()
*  say "Referenz von "
*  get cRef1
*  say " bis "
*  get cRef2
*  WinCr()
*  say "Filter       "
*  get cFilter picture "@K@S40"
*  WinCr()
*  say "Formel Basis "
*  get cxPrix2 picture "@K@S40"
*  WinCr()
*  say "       VK    "
*  get cxPrix1 picture "@K@S40"
*  WinCr()
*  say "       EK    "
*  get cxPrixA picture "@K@S40"
*  WinCr()
*  get cConfirm checkbox
*  say MSG_CONFIRM
*  nKey := ReadScr()
*  if nKey != K_ESC
*    cRef1 := trim(RefTrunc(cRef1))
*    cRef2 := trim(RefTrunc(cRef2))
*    if empty(cFilter)
*      cFilter := ".t."
*    else
*      cFilter := trim(cFilter)
*    endif
*    cxPrix1 := trim(cxPrix1)
*    cxPrix2 := trim(cxPrix2)
*    cxPrixA := trim(cxPrixA)
*    open area oAcf(), oArt()
*      ddSetOrder ORD_ACF_PAR
*      softseek trim(cIdPar)
*      do while ! eof() .and. lOkay
*        if ! empty(cIdPar)
*          if ACF->IdPar != cIdPar
*            exit
*          endif
*        endif
*        if TaskInter() ; exit ; endif
*        if empty(cIdArt1) .or. ACF->IdArt >= cIdArt1
*          if empty(cIdArt2) .or. ACF->IdArt <= cIdArt2
*            seek ACF->IdArt in ART
*            if empty(cRef1) .or. left(RefTrunc(ART->Ref),len(cRef1)) >= cRef1
*              if empty(cRef2) .or. left(RefTrunc(ART->Ref),len(cRef2)) <= cRef2
*                if &cFilter
*                  if ddRecLock()
*                    select ART
*                    if ddRecLock()
*                      cPrix2 := ntom(&cxPrix2,ArtPuDecPos())
*                      if cConfirm == BUTTON_ON
*                        open window "énderungsvorschlag" ;
*                             size 9,54 help "ACFPRX2" ;
*                             home 10,0 ;
*                             legend "[Esc] Abbrechen  [F7] nicht Ñndern  [F10] oder [Enter] bestÑtigen"
*                        say ART->Ref
*                        WinCr()
*                        say ACF->AcfRef
*                        WinCr()
*                        say ART->Name1
*                        WinCr()
*                        say "Basis " + ART->Prix2 + " "
*                        get cPrix2 GET_DECPOS(ArtPuDecPos())
*                        * nRow := row()
*                        * nCol := col()
*                        nKey := ReadScr()
*                        if nKey == K_ESC
*                          lOkay := .f.
*                        else
*                          ART->Prix2 := cPrix2
*                          cPrix1 := ntom(&cxPrix1,ArtPuDecPos())
*                          cPrixA := ntom(&cxPrixA,ArtPuDecPos())
*                          WinCr()
*                          say "VK    " + ART->Prix1 + " "
*                          get cPrix1 GET_DECPOS(ArtPuDecPos())
*                          WinCr()
*                          say "EK    " + ACF->Prix + " "
*                          get cPrixA GET_DECPOS(ArtPuDecPos())
*                          WinCr()
*                          get cConfirm checkbox
*                          say MSG_CONFIRM
*                          nKey := ReadScr()
*                          if nKey == K_ESC ; lOkay := .f. ; endif
*                        endif
*                        close window
*                        if lOkay .and. (nKey == K_F10 .or. nKey == K_ENTER)
*                          ART->Prix1 := cPrix1
*                          ACF->Prix  := cPrixA
*                          ACF->Date := UserDate()
*                        endif
*                      else
*                        cPrix1 := ntom(&cxPrix1,ArtPuDecPos())
*                        cPrixA := ntom(&cxPrixA,ArtPuDecPos())
*                        ART->Prix1 := cPrix1
*                        ACF->Prix  := cPrixA
*                        ACF->Date := UserDate()
*                      endif
*                      unlock record
*                    else
*                      lOkay := .f.
*                    endif
*                    select ACF
*                    unlock record
*                  else
*                    lOkay := .f.
*                  endif
*                endif
*              endif
*            endif
*          endif
*        endif
*        skip
*      enddo
*    close area
*  endif
*close window
*RETURN NIL
*
*FUNCTION MsgArtPrxUpdate() ; RETURN "Artikelpreise Ñndern"
*
*#endif DEF_ART_REF
********************************/

#ifdef DEF_JNL

FUNCTION JnlCheck()
open area oJnl()
  go top
  do while ! eof()
    if ddRecLock()
      #ifdef DEF_VEN
      if JNL->Alias == "VEN"
        open area oVen()
          KeyGoBottom(JNL->IdJnl,"VEN->IdJnl")
          JNL->IdDoc := VEN->IdDoc
        close area
      endif
      #endif DEF_VEN
      #ifdef DEF_FIN
      if JNL->Alias == "FIN"
        open area oFin()
          KeyGoBottom(JNL->IdJnl,"FIN->IdJnl")
          JNL->IdDoc := FIN->IdDoc
        close area
      endif
      #endif DEF_FIN
      #ifdef DEF_ODS
      if JNL->Alias == "ODS"
        open area oOds()
          KeyGoBottom(JNL->IdJnl,"ODS->IdJnl")
          JNL->IdDoc := ODS->IdDoc
        close area
      endif
      #endif DEF_ODS
      #ifdef DEF_IMP
      if JNL->Alias == "IMP"
        open area oImp()
          KeyGoBottom(JNL->IdJnl,"IMP->IdJnl")
          if IMP->IdJnl == JNL->IdJnl
            JNL->IdDoc := IMP->IdDoc
          endif
        close area
      endif
      #endif DEF_IMP
      unlock record
    endif
    skip
  enddo
close area
RETURN NIL

#endif DEF_JNL

#ifdef DEF_CTS

**
** CtsUpdate()
**
FUNCTION CtsUpdate(aCts)
local i
local lOkay := .f.
open area oCts()
  lOkay := .t.
  for i := 1 to len(aCts)
    Purzel()
    seek aCts[i][CTS_IDART] + aCts[i][CTS_PERIODE] + aCts[i][CTS_IDJNL] + aCts[i][CTS_INTRA]
    if eof()
      if dbAddRec()
        CTS->IdArt   := aCts[i][CTS_IDART]
        CTS->Periode := aCts[i][CTS_PERIODE]
        CTS->Intra   := aCts[i][CTS_INTRA]
        CTS->IdJnl   := aCts[i][CTS_IDJNL]
        CTS->Qte     := ntoq(aCts[i][CTS_QTE],aCts[i][CTS_QTEFORM])
        * CTS->Qte     := ntoq(aCts[i][CTS_QTE],ART->QteForm)
        CTS->Mont    := ntom(aCts[i][CTS_MONT])
        CTS->Anz     := aCts[i][CTS_ANZ]
        * CTS->MontR   := ntom(aCts[i][CTS_MONTR])
        unlock record
      else
        lOkay := .f.
        exit
      endif
    elseif ddRecLock()
      CTS->Anz     := CTS->Anz + aCts[i][CTS_ANZ]
      CTS->Qte     := ntoq(qton(CTS->Qte) + aCts[i][CTS_QTE],aCts[i][CTS_QTEFORM])
      CTS->Mont    := ntom(val(CTS->Mont)  + aCts[i][CTS_MONT])
      unlock record
    else
      lOkay := .f.
      exit
    endif
  next i
close area
RETURN lOkay

#endif DEF_CTS

#ifdef DEF_INT

**
** CtiUpdate()
**
*FUNCTION CtiUpdate(aCti)
*local i
*local lOkay := .f.
*open area oCti()
*  lOkay := .t.
*  for i := 1 to len(aCti)
*    Purzel()
*    seek aCti[i][CTI_IDINT] + aCti[i][CTI_PERIODE] + aCti[i][CTI_IDJNL] + aCti[i][CTI_NATCODE] + aCti[i][CTI_DC]
*    if eof()
*      if dbAddRec()
*        CTI->IdInt   := aCti[i][CTI_IDINT]
*        CTI->Periode := aCti[i][CTI_PERIODE]
*        CTI->IdJnl   := aCti[i][CTI_IDJNL]
*        CTI->NatCode := aCti[i][CTI_NATCODE]
*        CTI->DC      := aCti[i][CTI_DC]
*        CTI->Qte     := ntoq(aCti[i][CTI_QTE],aCti[i][CTI_QTEFORM])
*        CTI->QteStat := ntoq(aCti[i][CTI_QTESTAT],aCti[i][CTI_QTEFORM])
*        CTI->Mont    := ntom(aCti[i][CTI_MONT])
*        unlock record
*      else
*        lOkay := .f.
*        exit
*      endif
*    elseif ddRecLock()
*      CTI->Qte     := ntoq( qton(CTI->Qte)+aCti[i][CTI_QTE], aCti[i][CTI_QTEFORM])
*      CTI->QteStat := ntoq( qton(CTI->QteStat)+aCti[i][CTI_QTESTAT], aCti[i][CTI_QTEFORM])
*      CTI->Mont    := ntom(val(CTI->Mont)  + aCti[i][CTI_MONT])
*      unlock record
*    else
*      lOkay := .f.
*      exit
*    endif
*  next i
*close area
*RETURN lOkay

#endif DEF_INT

FUNCTION StdMemoWidth ; RETURN 76

#ifdef DEF_BIBLIO

**
** RubRename()
**
FUNCTION RubRename()
local cIdOld := RUB->IdRub
local i := 0
local lDelete := .f.
local lOkay := .f.
local cIdNew := space(LenIdRub())
open window ("Rubrik umbenennen") size 5,50 help RUBRENA
do while .t.
  WinHome()
  say RUB->Name
  WinCr()
  say MsgOldId() + cIdOld
  WinCr()
  say MsgNewId()
  @ row(), col() get cIdNew picture PIC_ID pick RubPick(cIdNew)
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN .f.
  endif
  if empty(cIdNew)
    loop
  endif
  exit
enddo
close window
open area oRub()
  seek cIdNew
  if eof()
    lOkay := .t.
  else
    lOkay := Confirm( cIdNew + " existiert bereits !", MsgUnion() )
    lDelete := .t.
  endif
close area
RETURN .f. if ! lOkay
RETURN .f. if ! Confirm( ;
  "Umbenennen " + cIdOld + " nach " + cIdNew, ;
  MsgSure() ;
)
ddCloseAll()
RETURN .f. if ! ddRecLock()
MsgDisplay(MsgWorking())
open area oObj() exclusive
  ddSetOrder()
  go top
  do while !eof()
    if OBJ->IdRub == cIdOld
      OBJ->IdRub := cIdNew
      i++
    endif
    skip
  enddo
  commit
close area
if lDelete
  delete
else
  RUB->IdRub := cIdNew
endif
unlock record
ddCloseAll()
ddRefreshAll()
RETURN MnuDone()

#endif DEF_BIBLIO

#ifdef DEF_FIN

FUNCTION FinReset(cIdJnl,cIdDoc1)
local nMont
local jnl := JnlLocate(cIdJnl)
local nDecPos
RETURN .f. if jnl == NIL
RETURN .f. if ! USRATTR_S $ UsrAttrib()
if ! JNLATTR_S $ jnl[JNL_ATTRIB]
  Warning("Salden neu rechnen : unzulÑssig fÅr Journal " + cIdJnl)
  RETURN .f.
endif
RETURN .f. if ! Confirm( ;
  cIdJnl + " : Salden neu rechnen ab Dokument " + cIdDoc1, ;
  MsgSure(), MSG_NO, "FINRESET" ;
)
* nDecPos := DevDecPos(jnl[JNL_IDDEV])
nDecPos := DevDecPos(FIN->IdDev)
open area oFin(), oFnl()
  softseek cIdJnl + cIdDoc1
  do while ! eof() .and. FIN->IdJnl == cIdJnl
    default nMont to val(FIN->Mont1)
    if ddRecLock()
      FIN->Mont1 := ntom(nMont,nDecPos)
      select FNL
      softseek FIN->IdJnl + FIN->IdDoc
      do while ! eof() .and. FNL->IdJnl == cIdJnl ;
                       .and. FNL->IdDoc == FIN->IdDoc
        * if jnl[JNL_IDDEV] == DevDefault(FIN->Periode)
        if FIN->IdDev == DevDefault(FIN->Periode)
          if FNL->DC == jnl[JNL_DC]
            nMont -= val(FNL->Mont)
          else
            nMont += val(FNL->Mont)
          endif
        else
          if FNL->DC == jnl[JNL_DC]
            nMont -= val(FNL->MontDev)
          else
            nMont += val(FNL->MontDev)
          endif
        endif
        skip
      enddo
      select FIN
      FIN->Mont2 := ntom(nMont,nDecPos)
      unlock record
    else
      exit
    endif
    skip
  enddo
close area
ddRefreshAll()
RETURN MnuDone()

#endif DEF_FIN

#ifdef DEF_VEN

**
** VenRename()
**
FUNCTION VenRename()
local cIdDocOld := VEN->IdDoc
local cIdJnlOld := VEN->IdJnl
local cIdJnlNew := VEN->IdJnl
local cIdDocNew := VEN->IdDoc
local i := 0
local lDelete := .f.
local lOkay := .f.
RETURN .f. if ! VenPreEdit()
open window ("Dokument umbenennen") size 5,50 help VENRENA
do while .t.
  WinHome()
  say MsgOldId() + cIdJnlOld + " " + cIdDocOld
  WinCr()
  say MsgNewId()
  @ row(), col() get cIdJnlNew picture PIC_ID ;
                 pick PickIdJnl("VEN",cIdJnlNew) ;
                 valid JnlLocate(cIdJnlNew)!=NIL
  say " "
  @ row(), col() get cIdDocNew pick PickDoc(cIdJnlNew,cIdDocNew)
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN .f.
  endif
  if empty(cIdJnlNew)
    loop
  endif
  if empty(cIdDocNew)
    loop
  endif
  exit
enddo
close window
open area oVen()
  seek cIdJnlNew + cIdDocNew
  if eof()
    lOkay := .t.
  else
    Warning( cIdJnlNew + " " + cIdDocNew + MSG021 )
  endif
close area
RETURN .f. if ! lOkay
RETURN .f. if ! Confirm( ;
  MSG032 + MSG031 + cIdJnlOld + " " + cIdDocOld + ;
  MSG034 + cIdJnlNew + " " + cIdDocNew ;
)
ddCloseAll()
RETURN .f. if ! ddRecLock()
lOkay := .f.
SendConsole( ;
  "VenRename() " + ;
  cIdJnlOld + " " + cIdDocOld + " -> " + cIdJnlNew + " " + cIdDocNew ;
)
MsgDisplay(MsgWorking())
open area oVnl(DocStatClosed())
  lOkay := .t.
  softseek cIdJnlOld + cIdDocOld
  do while FIELD->IdJnl == cIdJnlOld ;
           .and. FIELD->IdDoc == cIdDocOld ;
           .and. ! eof()
    if ddRecLock()
      FIELD->IdJnl := cIdJnlNew
      FIELD->IdDoc := cIdDocNew
      unlock record
    else
      lOkay := .f.
      exit
    endif
    softseek cIdJnlOld + cIdDocOld
  enddo
  commit
close area
open area oVnl(DocStatOpen())
  lOkay := .t.
  softseek cIdJnlOld + cIdDocOld
  do while FIELD->IdJnl == cIdJnlOld ;
           .and. FIELD->IdDoc == cIdDocOld ;
           .and. ! eof()
    if ddRecLock()
      FIELD->IdJnl := cIdJnlNew
      FIELD->IdDoc := cIdDocNew
      unlock record
    else
      lOkay := .f.
      exit
    endif
    softseek cIdJnlOld + cIdDocOld
  enddo
  commit
close area
if ! lOkay
  SendConsole("VenRename() failed !")
  RETURN .f.
endif
VEN->IdDoc := cIdDocNew
VEN->IdJnl := cIdJnlNew
SetMsg( MsgRename() + MsgDone() )
unlock record
ddCloseAll()
ddRefreshAll()
RETURN SetMnuDone()

#endif DEF_VEN


#ifdef DEF_FIN

**
** FinRename()
**
FUNCTION FinRename()
local cIdDocOld := FIN->IdDoc
local cIdJnlOld := FIN->IdJnl
local cIdJnlNew := FIN->IdJnl
local cIdDocNew := FIN->IdDoc
local i := 0
local lDelete := .f.
local lOkay := .f.
RETURN .f. if ! FinPreEdit()
open window ("Dokument umbenennen") size 5,50 help FINRENA
do while .t.
  WinHome()
  say MsgOldId() + cIdJnlOld + " " + cIdDocOld
  WinCr()
  say MsgNewId()
  @ row(), col() get cIdJnlNew picture PIC_ID pick PickIdJnl("FIN",cIdJnlNew)
  say " "
  @ row(), col() get cIdDocNew pick PickDoc(cIdJnlNew,cIdDocNew)
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN .f.
  endif
  if empty(cIdJnlNew)
    loop
  endif
  if empty(cIdDocNew)
    loop
  endif
  exit
enddo
close window
open area oFin()
  seek cIdJnlNew + cIdDocNew
  if eof()
    lOkay := .t.
  else
    Warning( cIdJnlNew + " " + cIdDocNew + MSG021 )
  endif
close area
RETURN .f. if ! lOkay
RETURN .f. if ! Confirm( ;
  MSG032 + MSG031 + cIdJnlOld + " " + cIdDocOld + ;
  MSG034 + cIdJnlNew + " " + cIdDocNew ;
)
ddCloseAll()
RETURN .f. if ! ddRecLock()
lOkay := .f.
SendConsole( ;
  "FinRename() " + ;
  cIdJnlOld + " " + cIdDocOld + " -> " + cIdJnlNew + " " + cIdDocNew ;
)
MsgDisplay(MsgWorking())
open area oFnl()
  lOkay := .t.
  softseek cIdJnlOld + cIdDocOld
  do while FNL->IdJnl == cIdJnlOld ;
           .and. FNL->IdDoc == cIdDocOld ;
           .and. ! eof()
    if ddRecLock()
      FNL->IdJnl := cIdJnlNew
      FNL->IdDoc := cIdDocNew
      unlock record
    else
      lOkay := .f.
      exit
    endif
    softseek cIdJnlOld + cIdDocOld
  enddo
  commit
close area
if ! lOkay
  SendConsole("FinRename() failed !")
  RETURN .f.
endif
FIN->IdDoc := cIdDocNew
FIN->IdJnl := cIdJnlNew
SetMsg(MsgRename() + MsgDone())
SendConsole( SetMsg() )
unlock record
ddCloseAll()
ddRefreshAll()
RETURN SetMnuDone()

#endif DEF_FIN


#ifdef DEF_ODS

**
** OdsRename()
**
FUNCTION OdsRename()
local cIdDocOld := ODS->IdDoc
local cIdJnlOld := ODS->IdJnl
local cIdJnlNew := ODS->IdJnl
local cIdDocNew := ODS->IdDoc
local i := 0
local lDelete := .f.
local lOkay := .f.
RETURN .f. if ! OdsPreEdit()
open window ("Dokument umbenennen") size 5,50 help ODSRENA
do while .t.
  WinHome()
  say MsgOldId() + cIdJnlOld + " " + cIdDocOld
  WinCr()
  say MsgNewId()
  @ row(), col() get cIdJnlNew picture PIC_ID pick PickIdJnl("ODS",cIdJnlNew)
  say " "
  @ row(), col() get cIdDocNew pick PickDoc(cIdJnlNew,cIdDocNew)
  nKey := ReadScr()
  if nKey == K_ESC
    close window
    RETURN .f.
  endif
  if empty(cIdJnlNew)
    loop
  endif
  if empty(cIdDocNew)
    loop
  endif
  exit
enddo
close window
open area oOds()
  seek cIdJnlNew + cIdDocNew
  if eof()
    lOkay := .t.
  else
    Warning( cIdJnlNew + " " + cIdDocNew + MSG021 )
  endif
close area
RETURN .f. if ! lOkay
RETURN .f. if ! Confirm( ;
  MSG032 + MSG031 + cIdJnlOld + " " + cIdDocOld + ;
  MSG034 + cIdJnlNew + " " + cIdDocNew ;
)
ddCloseAll()
RETURN .f. if ! ddRecLock()
lOkay := .f.
SendConsole( ;
  "OdsRename() " + ;
  cIdJnlOld + " " + cIdDocOld + " -> " + cIdJnlNew + " " + cIdDocNew ;
)
MsgDisplay(MsgWorking())
open area oOdl()
  lOkay := .t.
  softseek cIdJnlOld + cIdDocOld
  do while ODL->IdJnl == cIdJnlOld ;
           .and. ODL->IdDoc == cIdDocOld ;
           .and. ! eof()
    if ddRecLock()
      ODL->IdJnl := cIdJnlNew
      ODL->IdDoc := cIdDocNew
      unlock record
    else
      lOkay := .f.
      exit
    endif
    softseek cIdJnlOld + cIdDocOld
  enddo
  commit
close area
if ! lOkay
  SendConsole("OdsRename() failed !")
  RETURN .f.
endif
ODS->IdDoc := cIdDocNew
ODS->IdJnl := cIdJnlNew
SetMsg(MsgRename() + MsgDone())
SendConsole( SetMsg() )
unlock record
ddCloseAll()
ddRefreshAll()
RETURN SetMnuDone()

#endif DEF_ODS


*#ifdef DEF_IPB
*
*FUNCTION IpbTest()
*local i
*local lOkay := .f.
*open area oIpb(), oGen()
*  lOkay := .t.
*  go top
*  do while ! eof() .and. LstContinue()
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    if ! GenIsHidden(IPB->GenBase)
*      TestMsg("IPB->" + IPB->Seq + " : " + SetMsg())
*    endif
*    skip
*  enddo
*close area
*RETURN lOkay
*
*#endif DEF_IPB

#ifdef DEF_GEN

*FUNCTION CtrTest()
*local i
*local lOkay := .f.
*open area oCtr(), oGen()
*  lOkay := .t.
*  go top
*  do while ! eof() .and. LstContinue()
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    if ! GenIsHidden(CTR->IdGen)
*      TestMsg("CTR->" + CTR->IdCtr + " : " + SetMsg())
*    endif
*    skip
*  enddo
*close area
*RETURN lOkay

#endif DEF_GEN


#ifdef DEF_GEN

FUNCTION GenIsHidden(cIdGen)
RETURN .t. if empty(cIdGen)
RETURN .f. if ! GenExist(cIdGen)
if ! GENATTR_H $ GEN->Attrib
  SetMsg(cIdGen + WrnNotHidden())
  RETURN .f.
endif
RETURN .t.

#endif DEF_GEN


FUNCTION FixY2K(x) 
RETURN slFixY2K if x == NIL
slFixY2K := x
RETURN .t.

**
** DevToggle gibt an, ob wir uns *vor* oder *nach* dem Umstieg befinden.
**
* FUNCTION DevToggle(cPeriode) ; RETURN eval(sbDevToggle,cPeriode)

FUNCTION PerToggle() ; RETURN scPerToggle

FUNCTION HstStart() ; RETURN scHstStart

/**
  Ermittelt die Periode, in der die Buchhaltung gestartet wurde, die zum
  Zeitpunkt cPeriode aktiv ist.
  Wird benutzt in ChkPeriode() sowie in Reports, die einen
  Beginnsaldo errechnen mÅssen (z.B. GENBIL.REP, HSTGEN.REP und GENHST.REP)
**/

FUNCTION PerStart(cPeriode)
RETURN space(LEN_PERIODE) if cPeriode < scPerToggle
RETURN scPerToggle

/*
HSTPARD.QRY : ich mîchte wissen, ob diese Periode fÅr Ermittlung der Summe und
den Salden am Bildschirm "aktiv" ist.

*/
FUNCTION PerIsActive(cPeriode)
// Vor dem Toggle sind alle Perioden aktiv:
RETURN .t. if scPerToggle > PerActive()
// Nach dem Toggle sind nur die Perioden seit dem Toggle aktiv
RETURN (cPeriode >= scPerToggle)



**
** DevDefault ist ein array, das zwei WÑhrungen enthÑlt
** DevDefault[1] ist die GrundwÑhrung *vor* dem Umstieg
** DevDefault[2] ist die GrundwÑhrung *nach* dem Umstieg
**
FUNCTION DevDefault(cPeriode)
RETURN saDevDefault[2] if cPeriode >= PerToggle()
RETURN saDevDefault[1]

FUNCTION PerDevFixed(cPeriode,cIdDev)
RETURN eval(sbPerDevFixed,cPeriode,cIdDev)

#ifdef DEF_JNL
  FUNCTION PerYear(cPeriode) ; RETURN eval(sbPerYear,cPeriode)
  FUNCTION PrePerAppend(cPeriode) ; RETURN eval(sbPrePerAppend,cPeriode)
#endif DEF_JNL

#ifdef DEF_VENREMISE
  FUNCTION VenRemise ; RETURN eval(sbVenRemise)
#endif DEF_VENREMISE

#ifdef DEF_TRA
  FUNCTION TrlCompte ; RETURN eval(sbTrlCompte)
#endif DEF_TRA

#ifdef DEF_IMP
  FUNCTION ZauComPrefix ; RETURN eval(sbZauComPrefix)
  FUNCTION ImlCompte ; RETURN eval(sbImlCompte)
#endif DEF_IMP

#ifdef DEF_PLP
  FUNCTION ParSexe(cIdPar) ; RETURN eval(sbParSexe,cIdPar)
#endif DEF_PLP

FUNCTION ParName(cIdPar)
RETURN ParField(cIdPar, sbParName )

FUNCTION ParLogo(cIdPar)
RETURN ParField(cIdPar, sbParLogo )

* FUNCTION BlkParName ; RETURN sbParName
* FUNCTION BlkParCity ; RETURN sbParCity

FUNCTION ParCity(cIdPar)
RETURN ParField(cIdPar,sbParCity)
* RETURN ParField(cIdPar,{||PlzString(PAR->Pays,PAR->CP)})

FUNCTION ParAddress(cIdPar)
RETURN ParField(cIdPar,{||trim1(ParStreet(),', ')+ParCity()})


*FUNCTION r980323
*open area oVnl() exclusive
*  select 0
*  use VNL2
*  index on VNL2->IdJnl+VNL2->IdDoc+VNL2->Line to VNLTMP
*  select VNL
*  go top
*  do while ! eof()
*    if VNL->Code == "G"
*      select VNL2
*      seek VNL->IdJnl+VNL->IdDoc+VNL->Line
*      if ! eof()
*        select VNL
*        if VNL->cMont == VNL2->cMont
*          if left(VNL->IdArt,3) == left(VNL2->IdArt,3)
*            VNL->IdArt := VNL2->IdArt
*          else
*            Warning(MsgIdJnlDoc() + " : VNL->IdArt")
*          endif
*        else
*          Warning(MsgIdJnlDoc() + " : VNL->Mont")
*        endif
*      else
*        select VNL
*      endif
*    endif
*    skip
*  enddo
*  select VNL2
*  use
*  select VNL
*close area
*RETURN NIL


  FUNCTION DocStatNew         ; RETURN  scDocNew
  FUNCTION DocStatOpen        ; RETURN  scDocOpen
  FUNCTION DocStatClosed      ; RETURN  scDocClosed
  FUNCTION DocStatError       ; RETURN  scDocError

#ifdef DEF_JNL

  FUNCTION PreDocUndo         ; RETURN  eval(sbPreDocUndo)
  FUNCTION NoCheckRupture     ; RETURN  eval(sbNoCheckRupture)

#endif DEF_JNL

FUNCTION OnMainMenu
local i
for i := 1 to len(saOnMainMenu)
  if ! xparse(saOnMainMenu[i])
    if ! Confirm(MsgContinue())
      AppNormEnd()
      * RETURN .f.
    endif
  endif
next i
RETURN .t.


FUNCTION OnParSatisfy()
RETURN eval(sbOnParSatisfy)

#ifdef DEF_JNL

FUNCTION CheckIdDoc(jnl,cIdDoc,cPeriode)
local nPos
RETURN .t. if scNoCheckIdDoc == "*"
* RETURN .t. if JNLATTR_O $ jnl[JNL_ATTRIB]
RETURN .t. if jnl[JNL_SEQTYPE] == SEQTYPE_M
RETURN .t. if jnl[JNL_IDJNL] $ scNoCheckIdDoc
if jnl[JNL_SEQTYPE] == SEQTYPE_E
  RETURN .t. if left(cIdDoc,LEN_YEAR) == left(cPeriode,LEN_YEAR)
elseif jnl[JNL_SEQTYPE] == SEQTYPE_Y
  RETURN .t. if left(cIdDoc,LEN_YEAR) == y2p(year(PerDate1(cPeriode)))
else
  RETURN .t.
endif
if (nPos := at("until ",scNoCheckIdDoc)) != 0
  RETURN .t. if cPeriode <= substr(scNoCheckIdDoc,nPos+6)
endif
RETURN eval(sbCheckIdDoc,cIdDoc,cPeriode,jnl[JNL_IDJNL])

#endif DEF_JNL



FUNCTION AppOnLogin
#ifdef DEF_DEV
* SetDecPos(DevDecPos(DevDefault(MemPer1)))
SetDevise(DevDefault(MemPer1))
*local dev
*local cIdDev := DevDefault(PerActive())
*if (dev := DevLocate(cIdDev)) == NIL
*  Warning(cIdDev + MsgDevExist())
*  RETURN .f.
*endif
*SetDecPos(dev[DEV_DECPOS])
#endif DEF_DEV
RETURN .t.

#ifdef DEF_ART

FUNCTION ArtCopyTemplate(cIdArt)
RETURN eval(sbArtCopyTemplate,cIdArt)

#endif DEF_ART


#ifdef DEF_HST

FUNCTION HstMatch
RETURN eval(sbHstMatch)

FUNCTION OnHstCtrMix(cMatch)
RETURN eval(sbOnHstCtrMix,cMatch)

FUNCTION HstTestTolerance(cPeriode)
RETURN eval(sbHstTestTolerance,cPeriode)

#endif DEF_HST

#ifdef DEF_VEN
#ifdef DEF_VNLATTR

FUNCTION DoModPrix1
RETURN xparse(sxDoModPrix1)

FUNCTION DoAlaDetail
RETURN xparse(sxDoAlaDetail)

FUNCTION VnlIsModule(cIdArt) ; RETURN eval(sbVnlIsModule,cIdArt)
FUNCTION VnlIsLinked() ; RETURN eval(sbVnlIsLinked)
FUNCTION OdlIsComposed() ; RETURN eval(sbOdlIsComposed)

FUNCTION VnlHideDetail
RETURN eval(sbVnlHideDetail)

FUNCTION VnlIsModDetail()
RETURN eval(sbVnlIsDetail)


#else

FUNCTION VnlIsModDetail() ; RETURN .f.
FUNCTION VnlIsModule() ; RETURN .f.
FUNCTION VnlIsLinked() ; RETURN .f.
FUNCTION DoModPrix1() ; RETURN .t.

#endif DEF_VNLATTR
#endif DEF_VEN

#ifdef DEF_RUN

*FUNCTION t19990603
*RETURN .f. if ! Confirm(MsgSure())
*open area oPar(), oClb()
*  ddSetOrder 2 in CLB
*  go top
*  do while ! eof()
*    seek PAR->ClbNom in CLB
*    if eof() in CLB
*      Warning(PAR->IdPar + " : eof() in CLB !")
*    endif
*    if ddRecLock()
*      PAR->IdClb := CLB->IdClb
*      unlock record
*    endif
*    skip
*  enddo
*close area
*open area oPos(), oClb()
*  ddSetOrder 2 in CLB
*  go top
*  do while ! eof()
*    seek POS->IdClb in CLB
*    if eof() in CLB
*      Warning(POS->IdRal+POS->IdPos + " : eof() in CLB !")
*    endif
*    if ddRecLock()
*      POS->IdClb := CLB->IdClb
*      unlock record
*    endif
*    skip
*  enddo
*close area
*RETURN .t.

**
** ClbRename()
**
FUNCTION ClbRename(cIdNew)
local cIdOld := CLB->IdClb
local i := 0
local lOkay := .f.
local lDelete := .f.
local nRecNo1
local nRecNo2
if cIdNew == NIL
  cIdNew := space(LenIdClb())
  open window "renommer club" size 5,50 help CLBRENA
  do while .T.
    WinHome()
    say CLB->Name
    WinCr()
    say MsgOldId() + CLB->IdClb
    WinCr()
    say MsgNewId()
    @ row(), col() get cIdNew picture PIC_ID pick PickClb(cIdNew)
    nKey := ReadScr()
    if nKey == K_ESC
      close window
      RETURN .f.
    endif
    * if empty(cIdNew)
    *   loop
    * endif
    exit
  enddo
  close window
endif
open area oClb()
  seek cIdNew
  if eof()
    lOkay := .t.
  elseif Confirm( cIdNew + MSG021, MsgUnion() )
    lOkay := .t.
    lDelete := .t.
  endif
close area
RETURN .f. if ! lOkay
RETURN .f. if ! Confirm(MSG032 + " le club " + cIdOld + MSG034 + cIdNew )
ddCloseAll()
SendConsole( "ClbRename() " + cIdOld + " -> " + cIdNew )
RETURN .f. if ! ddRecLock()
MsgDisplay(MsgWorking())
lOkay := .f.
open area oPos(), oPar() exclusive
  select POS
  ddSetOrder()
  go top
  do while ! eof()
    if POS->IdClb == cIdOld
      POS->IdClb := cIdNew
      i++
    endif
    skip
  enddo
  commit
  select PAR
  ddSetOrder(ORD_PAR_CLB)
  softseek cIdOld
  do while ! eof() .and. PAR->IdClb == cIdOld
    nRecNo1 := recno()
    skip
    nRecNo2 := recno()
    goto nRecNo1
    PAR->IdClb := cIdNew
    goto nRecNo2
  enddo
  lOkay := .t.
close area
if lOkay
  if lDelete
    delete
  else
    CLB->IdClb := cIdNew
  endif
endif
unlock record
ddCloseAll()
ddRefreshAll()
RETURN MnuDone()



#endif DEF_RUN


#ifdef DEF_TRA

FUNCTION c19990630
local nCount := 0
local lOkay := .f.
open area oTra() exclusive
  ddSetOrder()
  lOkay := .t.
  do while lOkay .and. !eof()
    TRA->IdJnl := "TRA"
    skip
  enddo
close area
RETURN .f. if ! lOkay
open area oTrl() exclusive
  ddSetOrder()
  lOkay := .t.
  do while lOkay .and. !eof()
    TRL->IdJnl2 := TRL->IdJnl
    TRL->IdJnl := "TRA"
    skip
  enddo
close area
RETURN .f. if ! lOkay
RETURN .t.

#endif DEF_TRA

#ifdef DEF_RSV

FUNCTION RsiRsvColumn()
RETURN xeval(sbRsiRsvColumn)

#endif DEF_RSV

#ifdef DEF_TAX

** a is an array of { cIdCtr, cIdOld, cIdNew }
**
FUNCTION TaxRename(a)
local i
local nCount
local lOkay := .f.
MsgDisplay("TaxRename(VNL)...")
open area oVnl()
  lOkay := .t.
  go top
  nCount := 0
  do while ! eof()
    if (i := TaxIsOldId(a,JnlIdCtr(VNL->IdJnl),VNL->IdTax)) != 0
      if ddRecLock()
        VNL->IdTax := a[i][3]
        unlock record
      else
        lOkay := .f.
      endif
    endif
    MsgDisp2(ntrim0(++nCount*100/lastrec())+"%")
    if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
close area
RETURN ! SendConsole("TaxRename(VNL) failed") if ! lOkay
lOkay := .f.
MsgDisplay("TaxRename(GEN)...")
open area oGen()
  lOkay := .t.
  go top
  nCount := 0
  do while ! eof()
    if (i := TaxIsOldId(a,GEN->IdCtr,GEN->IdTax)) != 0
      if ddRecLock()
        GEN->IdTax := a[i][3]
        unlock record
      else
        lOkay := .f.
      endif
    endif
    MsgDisp2(ntrim0(++nCount*100/lastrec())+"%")
    if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
close area
RETURN ! SendConsole("TaxRename(GEN) failed") if ! lOkay
lOkay := .f.
MsgDisplay("TaxRename(HST)...")
open area oHst()
  lOkay := .t.
  go top
  nCount := 0
  do while ! eof()
    if (i := TaxIsOldId(a,JnlIdCtr(HST->IdJnl),HST->IdTax)) != 0
      if ddRecLock()
        HST->IdTax := a[i][3]
        unlock record
      else
        lOkay := .f.
      endif
    endif
    MsgDisp2(ntrim0(++nCount*100/lastrec())+"%")
    if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
close area
RETURN ! SendConsole("TaxRename(HST) failed") if ! lOkay
#ifdef DEF_IPB
  lOkay := .f.
  MsgDisplay("TaxRename(IPB)...")
  open area oIpb()
    lOkay := .t.
    go top
    nCount := 0
    do while ! eof()
      if (i := TaxIsOldId(a,IPB->IdCtr,IPB->IdTax)) != 0
        if ddRecLock()
          IPB->IdTax := a[i][3]
          unlock record
        else
          lOkay := .f.
        endif
      endif
      MsgDisp2(ntrim0(++nCount*100/lastrec())+"%")
      if TaskInter() ; lOkay := .f. ; exit ; endif
      skip
    enddo
  close area
  RETURN ! SendConsole("TaxRename(IPB) failed") if ! lOkay
#endif
lOkay := .f.
MsgDisplay("TaxRename(TAX)...")
open area oTax()
  lOkay := .t.
  go top
  nCount := 0
  do while ! eof()
    if (i := TaxIsOldId(a,TAX->IdCtr,TAX->IdTax)) != 0
      if ddRecLock()
        TAX->IdTax := a[i][3]
        unlock record
      else
        lOkay := .f.
      endif
    endif
    MsgDisp2(ntrim0(++nCount*100/lastrec())+"%")
    if TaskInter() ; lOkay := .f. ; exit ; endif
    skip
  enddo
close area
RETURN ! SendConsole("TaxRename(TAX) failed") if ! lOkay
#ifdef DEF_CTT
  lOkay := .f.
  MsgDisplay("TaxRename(CTT)...")
  open area oCtt()
    lOkay := .t.
    go top
    nCount := 0
    do while ! eof()
      if (i := TaxIsOldId(a,JnlIdCtr(CTT->IdJnl),CTT->IdTax)) != 0
        if ddRecLock()
          CTT->IdTax := a[i][3]
          unlock record
        else
          lOkay := .f.
        endif
      endif
      MsgDisp2(ntrim0(++nCount*100/lastrec())+"%")
      if TaskInter() ; lOkay := .f. ; exit ; endif
      skip
    enddo
  close area
  RETURN ! SendConsole("TaxRename(CTT) failed") if ! lOkay
#endif DEF_CTT
RETURN lOkay

STATIC FUNCTION TaxIsOldId(a,cIdCtr,cIdTax)
local i
for i := 1 to len(a)
  if a[i][1] == cIdCtr
    if a[i][2] == cIdTax
      RETURN i
    endif
  endif
next i
RETURN 0



#endif DEF_TAX


#ifdef DEF_ADR

**
** AdlRename()
**
FUNCTION AdlRename(cIdNew)
local cIdOld := ADL->IdAdl
local i := 0
local lOkay := .f.
local lDelete := .f.
if cIdNew == NIL
  cIdNew := ADL->IdAdl // space(LenIdAdl())
  open window "Adressenliste umbenennen" size 5,50 help ADLRENA
  do while .T.
    WinHome()
    say ADL->Name
    WinCr()
    say MsgOldId() + ADL->IdAdl
    WinCr()
    say MsgNewId()
    @ row(), col() get cIdNew picture PIC_ID pick PickAdl(cIdNew)
    nKey := ReadScr()
    if nKey == K_ESC
      close window
      RETURN .f.
    endif
    if empty(cIdNew)
      loop
    endif
    exit
  enddo
  close window
endif
open area oAdl()
  seek cIdNew
  if eof()
    lOkay := .t.
  elseif Confirm( cIdNew + MSG021, MsgUnion() )
    lOkay := .t.
    lDelete := .t.
  endif
close area
RETURN .f. if ! lOkay
RETURN .f. if ! Confirm(MSG032 + MSG033 + cIdOld + MSG034 + cIdNew )
ddCloseAll()
SendConsole( "AdlRename() " + cIdOld + " -> " + cIdNew )
RETURN .f. if ! ddRecLock()
MsgDisplay(MsgWorking()) // "Ne pas interrompre...")
lOkay := .f.
open area oAdm()
  lOkay := .t.
  ddSetOrder(ORD_ADM_ADL)
  softseek cIdOld
  do while lOkay .and. ADM->IdAdl == cIdOld .and. ! eof()
    if ddRecLock()
      ADM->IdAdl := cIdNew
      unlock record
    else
      lOkay := .f.
    endif
    softseek cIdOld
  enddo
  commit
close area
if lOkay
  if lDelete
    delete
  else
    ADL->IdAdl := cIdNew
  endif
endif
unlock record
ddCloseAll()
ddRefreshAll()
RETURN SetMnuDone()

#endif DEF_ADR

#ifdef DEF_HST

/***
Bei Pohlen z.B. gibt es noch Rechnungen in FW, wo der Betrag FW fÅr die
Buchungen in Generalkonten nicht in die HST eingetragen wurde.
Das stîrt seit 2001-01-16 im IntegritÑtstest. Auch HstMont("DEM") gibt
dann 0 zurÅck, was ja falsch ist.
HstDevCheck() korrigiert das nachtrÑglich.
**/
*FUNCTION HstDevCheck()
*local nCount := 0
*local lOkay := .f.
*local cIdDev
*local nMontDev
*local jnl
*open area oHst(),oGen(),oPar(),oFin(),oVen()
*  lOkay := .t.
*  go top
*  do while ! eof()
*    MsgDisp2(ntrim0(100 * nCount++ / lastrec()) + "%")
*    if TaskInter() ; lOkay := .f. ; exit ; endif
*    cIdDev := HstIdDev()
*    if cIdDev != DevDefault(HST->Periode) .and. empty(HST->MontDev)
*      nMontDev := 0
*      if (jnl := JnlLocate(HST->IdJnl)) == NIL
*        SetMsg(HST->IdJnl + MsgJnlExist())
*        lOkay := .f.
*        exit
*      endif
*      #ifdef DEF_VEN
*        if jnl[JNL_ALIAS] == JNLALIAS_VEN
*          seek HST->IdJnl+HST->IdDoc in VEN
*          if VEN->IdJnl+VEN->IdDoc != HST->IdJnl+HST->IdDoc
*            Warning(MsgIdJnlDoc() + " : VEN->IdDoc...")
*            lOkay := .f.
*            exit
*          endif
*          nMontDev := VenDb2Dev(val(HST->Mont))
*        endif
*      #endif  DEF_VEN
*      #ifdef DEF_FIN
*        if jnl[JNL_ALIAS] == JNLALIAS_FIN
*          seek HST->IdJnl+HST->IdDoc in FIN
*          if FIN->IdJnl+FIN->IdDoc != HST->IdJnl+HST->IdDoc
*            Warning(MsgIdJnlDoc() + " : FIN->IdDoc...")
*            lOkay := .f.
*            exit
*          endif
*          nMontDev := FinDb2Dev(val(HST->Mont))
*        endif
*      #endif  DEF_FIN
*      if ddRecLock()
*        HST->MontDev := ntom(;
*          nMontDev,;
*          DevDecPos(cIdDev);
*        )
*        unlock record
*      endif
*    endif
*    skip
*  enddo
*close area
*RETURN lOkay

#endif DEF_HST

#ifdef DEF_ART

FUNCTION ArtIdDev() ; RETURN scArtIdDev

FUNCTION ArtPrixDB(cPeriode,nPrix)
RETURN nPrix if scArtIdDev == DevDefault(cPeriode)
RETURN Dev2Db(scArtIdDev,cPeriode,nPrix)

FUNCTION ArtPrixR(cPeriode) ; RETURN ArtPrixDB(cPeriode,val(ART->PrixR))
FUNCTION ArtPrix1(cPeriode) ; RETURN ArtPrixDB(cPeriode,val(ART->Prix1))

FUNCTION IsArtCode(cCode)
RETURN .t. if cCode  == LNCODE_ART ;
  .or. cCode == LNCODE_ARTFIXE ;
  .or. cCode == LNCODE_TOTAL ;
  .or. cCode == LNCODE_MODULE ;
  .or. cCode == LNCODE_VARIANTE
RETURN .f.


#endif DEF_ART

#ifdef DEF_VEN
FUNCTION MsgVnaTag(cIdJnl)
RETURN xeval(sbMsgVnaTag,cIdJnl)
#endif

*#ifdef CUST_MOOR
*FUNCTION OnCarPassFile(cFilename)
*RETURN eval(sblOnCarPassFile,cFilename)
*#endif CUST_MOOR





FUNCTION TimInit()
* raus am 20070416 weil unnîtig afaik
* #ifdef __XPP__
*   AddIniCmd( { "RddSetDefault" , {|x| DbeSetDefault(x), .t. } } )
* #else
*   AddIniCmd( { "RddSetDefault" , {|x| RddSetDefault(x), .t. } } )
* #endif
AddIniCmd( { "set epoch" , {|x| set(_SET_EPOCH,val(x)),.t. } } )
AddIniCmd( { "UseAdsDbe" , {|x| slUseAdsDbe:= ctol(x),.t. } } )
#ifdef __XPP__
  AddIniCmd( { "SetCollation" , {|x| (snCollation:= xparse(x))!=NIL } } )
#endif
AddIniCmd( { "UseDbe" , {|x| (scUseDbe:= xparse(x))!=NIL } } )
AddIniCmd( { "LenIdTpl" , {|x| snLenIdTpl := val(x),.t. } } )
AddIniCmd( { "OnMainMenu" , {|x| aadd(saOnMainMenu,x),.t. } } )
AddIniCmd( { "OnParSatisfy" , {|x| ;
  (sbOnParSatisfy := xparse(x))!=NIL ;
} } )
#ifdef DEF_ART
  AddIniCmd( { "LenIdArt" , {|x| snLenIdArt := val(x),.t. } } )
  AddIniCmd( { "LenArtRoot" , {|x| snLenArtRoot := val(x),.t. } } )
  AddIniCmd( { "ArtIsTotal" , {|x| (sbArtIsTotal := xparse(x)) != NIL } } )
  AddIniCmd( { "ArtName" , {|x| (sbArtName := xparse(x)) != NIL } } )
  AddIniCmd( { "PicIdArt" , {|x| (scPicIdArt := xparse(x)) != NIL } } )
  AddIniCmd( { "ArtCopyTemplate" , {|x| (sbArtCopyTemplate := xparse(x)) != NIL } } )
#endif DEF_ART
AddIniCmd( { "LenParAttrib" , {|x| snLenParAttrib := val(x),.t. } } )
AddIniCmd( { "OnParSelect" , {|x| aadd(saOnParSelect,x),.t. } } )
AddIniCmd( { "NextIdPar" , {|x| (sbNextIdPar := xparse(x)) != NIL } } )
AddIniCmd( { "GetIdPar" , {|x| (sbGetIdPar := xparse(x)) != NIL } } )
AddIniCmd( { "IdParValidate" , {|x| (sbIdParValidate := xparse(x)) != NIL } } )
AddIniCmd( { "LenParName" , {|x| snLenParName := val(x),.t. } } )
AddIniCmd( { "LenArtName" , {|x| snLenArtName := val(x),.t. } } )
AddIniCmd( { "LenGenName" , {|x| snLenGenName := val(x),.t. } } )
AddIniCmd( { "LenGraName" , {|x| snLenGraName := val(x),.t. } } )
AddIniCmd( { "QteEmpty"   , {|x| (slQteEmpty := xparse(x)) != NIL } } )
AddIniCmd( { "VnlAnzahl"  , {|x| (sbVnlAnzahl := xparse(x)) != NIL } } )
AddIniCmd( { "OpenMail"  , {|x| (sbOpenMail := xparse(x)) != NIL } } )
// AddIniCmd( { "WebBrowser"  , {|x| (scWebBrowser := xparse(x)) != NIL } } )
AddIniCmd( { "OpenUrl"  , {|x| (scWebBrowser := xparse(x)) != NIL } } )
AddIniCmd( { "OpenCsv"  , {|x| (scOpenCsv := xparse(x)) != NIL } } )
#ifdef DEF_SER
  AddIniCmd( { "IdSerDefault" , {|x| scIdSerDefault := x,.t. } } )
  AddIniCmd( { "LenIdSer" , {|x| snLenIdSer := val(x),.t. } } )
#endif DEF_SER
#ifdef DEF_INT
  AddIniCmd( { "LenIdInt" , {|x| snLenIdInt := val(x),.t. } } )
#endif DEF_INT
* #ifdef DEF_LGT
*   AddIniCmd( { "LenIdLgt" , {|x| snLenIdLgt := val(x),.t. } } )
* #endif DEF_LGT
AddIniCmd( { "TimTestAllow" , {|x| AddIfNotNil(saTimTestAllow,xparse(x)) } } )
*#ifdef CUST_MOOR
*  AddIniCmd( { "OnCarPassFile" , {|x|(sblOnCarPassFile:=xparse(x))!=NIL}})
*#endif CUST_MOOR
#ifdef DEF_VNA
  AddIniCmd( { "MsgVnaTag" , {|x| (sbMsgVnaTag:=xparse(x)) != NIL } } )
  AddIniCmd( { "PreVnaCollect" , {|x| (sbPreVnaCollect:=xparse(x)) != NIL } } )
  AddIniCmd( { "VnlVnaCount" , {|x| (sbVnlVnaCount:=cblock(x)) != NIL } } )
  AddIniCmd( { "OnVnaSuggest" , {|x| AddIfNotNil(saOnVnaSuggest,cblock(x)) } } )
  AddIniCmd( { "PreVnaUndo" , {|x| (xlPreVnaUndo:=x) != NIL } } )
  AddIniCmd( { "VnaMustEdit" , {|x| (xlVnaMustEdit:=cblock(x)) != NIL } } )
  AddIniCmd( { "ParVnaStop" , {|x| (sbParVnaStop:=xparse(x)) != NIL } } )
  AddIniCmd( { "VnaMatch" , {|x| (sbVnaMatch:=cblock(x)) != NIL } } )
  AddIniCmd( { "OnVnaGenerate" , {|x| AddVnaEvent(x) } } )
  * AddIniCmd( { "VnlVnaMatch" , {|x| ;
  *   (sbVnlVnaMatch := cblock(x)) != NIL ;
  * } } )
  * AddIniCmd( { "VnaCopyFilter" , {|x| (sxVnaCopyFilter := x) != NIL } } )
  * AddIniCmd( { "PreVnaSuggest" , {|x| (sblPreVnaSuggest := x) != NIL } } )
#endif DEF_VNA
#ifdef DEF_MULT
  AddIniCmd( { "OnVnlRoundError" , {|x| AddVnlRoundError(x) } } )
#endif DEF_MULT
#ifdef DEF_VNLATTR
  AddIniCmd( { "DoModSalesPrice" , {|x| (sxDoModPrix1 := x) != NIL } } )
  AddIniCmd( { "DoAlaDetail" , {|x| (sxDoAlaDetail := x) != NIL } } )
  AddIniCmd( { "VnlIsModule" , {|x| (sbVnlIsModule := xparse(x)) != NIL } } )
  AddIniCmd( { "VnlIsLinked" , {|x| (sbVnlIsLinked := xparse(x)) != NIL } } )
  AddIniCmd( { "OdlIsComposed" , {|x| (sbOdlIsComposed:= xparse(x)) != NIL } } )
  AddIniCmd( { "VnlHideDetail" , {|x| (sbVnlHideDetail:=cblock(x)) != NIL } } )
  AddIniCmd( { "VnlIsModDetail" , {|x| ;
    (sbVnlIsDetail := cblock(x)) != NIL ;
  } } )
#endif DEF_VNLATTR
#ifdef DEF_ODS
  AddIniCmd( { "OnOdlPreClose" , {|x| AddIfNotNil(saOnOdlPreClose,cblock(x)) } } )
#endif DEF_ODS
#ifdef DEF_VEN
  VenIniConfig()
  * AddIniCmd( { "DoParMfcDefault", ;
  *   {|x| (sbDoParMfcDefault:=cblock(x))!=NIL } } )
  AddIniCmd( { "VenMfcDefault", {|x| (sbVenMfcDefault:=cblock(x))!=NIL }})
  AddIniCmd( { "VenParValidate" , {|x| AddVenParValidate(x) } } )
  AddIniCmd( { "VnlIdValidate" , {|x| AddVnlIdValidate(x) } } )
  AddIniCmd( { "VnlVarCollect" , {|x| AddVnlVarCollect(x) } } )
  AddIniCmd( { "VnlPreClose" , {|x| AddVnlPreClose(x) } } )
  AddIniCmd( { "LenLstVen"  , {|x| snLenLstVen := val(x),.t. } } )
  AddIniCmd( { "LenVnlName" , {|x| snLenVnlName := val(x),.t. } } )
  AddIniCmd( { "OnVenClose" , {|x| (sbOnVenClose:=xparse(x)) != NIL } } )
  * AddIniCmd( { "OnVnlClose" , {|x| (sbOnVnlClose:=xparse(x)) != NIL } } )
  AddIniCmd( { "OnVnlClose" , {|x| AddIfNotNil(saOnVnlClose,cblock(x))} } )
  AddIniCmd( { "VenDocLibell" , {|x| (sbVenLibell:=xparse(x)) != NIL } } )
  AddIniCmd( { "AfterVenClose" , {|x| ;
      AddIfNotNil(sbAfterVenClose,cblock(x)) } } )
  AddIniCmd( { "PreVnlDelete" , {|x| ;
    (sbPreVnlDelete := xparse(x)) != NIL ;
  } } )
  AddIniCmd( { "VnlQteBase" , {|x| ;
    (sbVnlQteBase := cblock(x)) != NIL ;
  } } )
  AddIniCmd( { "VnlQteValidate" , {|x| ;
    (sbQteValidate := cblock(x)) != NIL ;
  } } )
  AddIniCmd( { "VnlTotBegin" , {|x| ;
    (sbVnlTotBegin := xparse(x)) != NIL ;
  } } )
  AddIniCmd( { "VnlAqtFill" , {|x| ;
    (sbVnlAqtFill := xparse(x)) != NIL ;
  } } )
  AddIniCmd( { "TagVnaAttrib" , {|x| ;
    (sbcNafAttr := xparse(x)) != NIL ;
  } } )
  AddIniCmd( { "VnlIsAqt" , {|x| ;
    (sbVnlIsAqt := xparse(x)) != NIL ;
  } } )
  AddIniCmd( { "VenMatch" , {|x| ;
    (sbVenHstMatch := cblock(x)) != NIL ;
  } } )
  #ifdef DEF_IPB
    AddIniCmd( { "ArtIdGen" , {|x| (sbArtIdGen := xparse(x)) != NIL } } )
  #endif DEF_IPB
  #ifdef DEF_PRIXR
    AddIniCmd( { "VnlPrixR" , {|x| (sbVnlPrixR := xparse(x)) != NIL } } )
  #endif DEF_PRIXR
  #ifdef DEF_TAX
    AddIniCmd( { "TolerateTax" , {|x| (sbTolerateTax := cblock(x)) != NIL } } )
  #endif
  #ifdef DEF_INT
    AddIniCmd( { "VnlIntDefault" , {|x| (sbVnlIntDefault := cblock(x)) != NIL } } )
  #endif DEF_INT
#endif DEF_VEN
#ifdef DEF_HST
  AddIniCmd( { "HstMatch" , {|x| (sbHstMatch := cblock(x)) != NIL } } )
  AddIniCmd( { "OnHstCtrMix" , {|x| (sbOnHstCtrMix := cblock(x)) != NIL } } )
  AddIniCmd( { "HstTestTolerance" , {|x| ;
    (sbHstTestTolerance := xparse(x)) != NIL ;
  } } )
#endif DEF_HST
#ifdef DEF_FIN
AddIniCmd( { "LenFnlName" , {|x| snLenFnlName := val(x),.t. } } )
AddIniCmd( { "PreFnlAppend" , {|x| AddIfNotNil(saPreFnlAppend,cblock(x)) } } )
AddIniCmd( { "CheckFinSolde", {|x| (sxlCheckFinSolde := cblock(x))!=NIL } } )
AddIniCmd( { "FinTolerance", {|x| (sxnFinTolerance := cblock(x))!=NIL } } )
AddIniCmd( { "FnlFillFilter" , {|x| AddIfNotNil(saFnlFillFilter,cblock(x)) } } )
#endif DEF_FIN
#ifdef DEF_PLS
  AddIniCmd( { "LenIdPls" , {|x| snLenIdPls := val(x),.t. } } )
  AddIniCmd( { "LenMbrRemark" , {|x| snLenMbrRemark := val(x),.t. } } )
#endif DEF_PLS
#ifdef DEF_PLI
  AddIniCmd( { "LenIdPls" , {|x| snLenIdPls := val(x),.t. } } )
  AddIniCmd( { "LenMbrRemark" , {|x| snLenMbrRemark := val(x),.t. } } )
#endif DEF_PLI
#ifdef DEF_ADR
  AddIniCmd( { "LenIdAdl" , {|x| snLenIdAdl := val(x),.t. } } )
#endif DEF_ADR
#ifdef DEF_ALS
  AddIniCmd( { "LenIdAls" , {|x| snLenIdAls := val(x),.t. } } )
#endif DEF_ALS
#ifdef DEF_KVK
AddIniCmd( { "IdZlaDefault" , {|x| scIdZlaDefault := x,.t. } } )
#endif DEF_KVK
#ifdef DEF_BIL
  AddIniCmd( { "LenIdBil" , {|x| snLenIdBil := val(x),.t. } } )
#endif DEF_BIL
#ifdef DEF_BIBLIO
  AddIniCmd( { "LenIdRub" , {|x| snLenIdRub := val(x),.t. } } )
  AddIniCmd( { "LenIdNts" , {|x| snLenIdNts := val(x),.t. } } )
#endif DEF_BIBLIO
AddIniCmd( { "LenIdDoc" , {|x| snLenIdDoc := val(x),.t. } } )
AddIniCmd( { "LenIdCtr" , {|x| (snLenIdCtr := xparse(x))!=NIL } } )
AddIniCmd( { "LenQte"   , {|x| snLenQte := val(x),.t. } } )
AddIniCmd( { "ParName" , {|x| (sbParName := xparse(x)) != NIL } } )
AddIniCmd( { "ParLogo" , {|x| (sbParLogo := cblock(x)) != NIL } } )
AddIniCmd( { "ParCity" , {|x| (sbParCity := xparse(x)) != NIL } } )
AddIniCmd( { "FixY2K"  , {|x| (slFixY2K := xparse(x)) != NIL } } )
// AddIniCmd( { "DevToggle" , {|x| (sbDevToggle := xparse(x)) != NIL } } )
AddIniCmd( { "HstStart" , {|x| (scHstStart := xparse(x)) != NIL } } )
AddIniCmd( { "PerToggle" , {|x| (scPerToggle := xparse(x)) != NIL } } )
AddIniCmd( { "DevDefault" , {|x| (saDevDefault := xparse(x)) != NIL;
           .and.len(saDevDefault)==2 } } )
AddIniCmd( { "PerDevFixed" , {|x| (sbPerDevFixed := xparse(x)) != NIL } } )
#ifdef DEF_TRA
  AddIniCmd( { "TrlCompte"    , ;
    {|x| (sbTrlCompte := cblock(x)) != NIL } } )
#endif DEF_TRA
#ifdef DEF_IMP
  AddIniCmd( { "ZauComPrefix" , ;
    {|x| (sbZauComPrefix := cblock(x)) != NIL } } )
  AddIniCmd( { "ImlCompte"    , ;
    {|x| (sbImlCompte := cblock(x)) != NIL } } )
#endif DEF_IMP
#ifdef DEF_PLP
  AddIniCmd( { "ParSexe"    , {|x| (sbParSexe := xparse(x)) != NIL } } )
#endif DEF_PLP
#ifdef DEF_VENREMISE
  AddIniCmd( { "VenRemise"    , {|x| (sbVenRemise := cblock(x)) != NIL } } )
#endif DEF_VENREMISE
#ifdef DEF_JNL
  AddIniCmd( { "PrePerAppend"    , {|x| (sbPrePerAppend := xparse(x)) != NIL } } )
  AddIniCmd( { "PerYear"    , {|x| (sbPerYear := xparse(x)) != NIL } } )
#endif DEF_JNL
#ifdef DEF_RSV
  AddIniCmd( { "RsiRsvColumn" , {|x| (sbRsiRsvColumn := cblock(x)) != NIL } } )
#endif DEF_RSV
#ifdef DEF_KITZ
  AddIniCmd( { "KrgKrmPrix" , {|x| (sbKrgKrmPrix := cblock(x)) != NIL } } )
#endif DEF_KITZ
* AddIniCmd( { "ShouldRebuild" , {|x| (snShouldRebuild := xparse(x)) != NIL } } )
AddIniCmd( { "LenTel"   , {|x| snLenTel := val(x),.t. } } )
* AddIniCmd( { "LenQteBig"  , {|x| snLenQteBig := val(x),.t. } } )
  AddIniCmd( { "LenIdGen" , {|x| snLenIdGen := val(x),.t. } } )
#ifdef DEF_GEN
  AddIniCmd( { "LenIdGenHeader" , {|x| snLenGenHeader := val(x),.t. } } )
  AddIniCmd( { "OnGenCtrExist" , {|x| (sxlOnGenCtrExist := xparse(x))!=NIL } } )
  AddIniCmd( { "OnGenJnlExist" , {|x| (sxlOnGenJnlExist := xparse(x))!=NIL } } )
#endif DEF_GEN
AddIniCmd( { "LenIdPrj" , {|x| snLenIdPrj := val(x),.t. } } )
AddIniCmd( { "LenIdUnt" , {|x| snLenIdUnt := val(x),.t. } } )
  AddIniCmd( { "DocStatNew" , {|x| (scDocNew := xparse(x)) != NIL } } )
  AddIniCmd( { "DocStatOpen" , {|x| (scDocOpen := xparse(x)) != NIL } } )
  AddIniCmd( { "DocStatClosed" , {|x| (scDocClosed := xparse(x)) != NIL } } )
  AddIniCmd( { "DocStatError" , {|x| (scDocError := xparse(x)) != NIL } } )
#ifdef DEF_JNL
  AddIniCmd( { "NoCheckIdDoc" , {|x| scNoCheckIdDoc := x,.t. } } )
  AddIniCmd( { "CheckIdDoc" , {|x| (sbCheckIdDoc := xparse(x)) != NIL } } )
  AddIniCmd( { "PreDocUndo"  , {|x| (sbPreDocUndo := xparse(x)) != NIL } } )
  AddIniCmd( { "NoCheckRupture"  , {|x| (sbNoCheckRupture := cblock(x)) != NIL } } )
#endif DEF_JNL
#ifdef DEF_ART
  AddIniCmd( { "PicIdGra" , {|x| (scPicIdGra := xparse(x)) != NIL } } )
  AddIniCmd( { "LenIdGra" , {|x| snLenIdGra := val(x),.t. } } )
  AddIniCmd( { "LenIdPga" , {|x| snLenIdPga := val(x),.t. } } )
  AddIniCmd( { "ArtFilter" , {|x| (sxlArtFilter := xparse(x)) != NIL } } )
  AddIniCmd( { "NextIdArt" , {|x| (sbNextIdArt := xparse(x)) != NIL } } )
  AddIniCmd( { "NextIdGra" , {|x| (sbNextIdGra := xparse(x)) != NIL } } )
  AddIniCmd( { "GetIdGra" , {|x| (sbGetIdGra := xparse(x)) != NIL } } )
  AddIniCmd( { "PreArtCreate" , {|x| (sbPreArtCreate := xparse(x)) != NIL } } )
  AddIniCmd( { "IdArtValidate" , {|x| (sbIdArtValidate := xparse(x)) != NIL } } )
  AddIniCmd( { "IdGraValidate" , {|x| (sbIdGraValidate := xparse(x)) != NIL } } )
  AddIniCmd( { "GetIdArt" , {|x| (sbGetIdArt := xparse(x)) != NIL } } )
  AddIniCmd( { "LenAcfRef" , {|x| snLenAcfRef := val(x),.t. } } )
  AddIniCmd( { "LenRefExt" , {|x| snLenAcfRef := val(x),.t. } } )
  AddIniCmd( { "ArtIdDev" , {|x| (scArtIdDev := xparse(x))!=NIL } } )
#endif DEF_ART
#ifdef DEF_ACF
  AddIniCmd( { "AcfIdCtr" , {|x| (sbAcfIdCtr := xparse(x)) != NIL } } )
  AddIniCmd( { "DoVnlAcfUpdate" , {|x| (sbDoVnlAcfUpdate := xparse(x)) != NIL } } )
  AddIniCmd( { "MustAcfReplicate" , {|x| (sbMustAcfReplicate := xparse(x)) != NIL } } )
#endif DEF_ACF
#ifdef DEF_ART_REF
  AddIniCmd( { "LenArtRef" , {|x| snLenArtRef := val(x),.t. } } )
#endif DEF_ART_REF
AddIniCmd( { "LenIdPar" , {|x| snLenIdPar := val(x),.t. } } )
AddIniCmd( { "set montant" , {|x| SetMntFormat(x) } } )
AddIniCmd( { "set solde" , {|x| SetSolde(x) } } )
AddIniCmd( { "LenIdJnl" , {|x| snLenIdJnl := val(x),.t. } } )
  ImpAddDbiItems()
#ifdef DEF_ANA
  AddIniCmd( { "LenIdAna" , {|x| snLenIdAna := val(x),.t. } } )
  AddIniCmd( { "GetIdAna" , {|x| (sbGetIdAna := xparse(x)) != NIL } } )
  AddIniCmd( { "NoDocMvaCheck"  , {|x| (sbNoDocMvaCheck := cblock(x)) != NIL } } )
  AddIniCmd( { "VnlIdAna"  , {|x| (sbVnlIdAna := cblock(x)) != NIL } } )
#endif DEF_ANA
#ifdef DEF_HOLZ
AddIniCmd( { "LenIdStm" , {|x| snLenIdStm := val(x),.t. } } )
AddIniCmd( { "OnStmCreate" , {|x| scOnStmCreate := x,.t. } } )
AddIniCmd( { "PreStmCopy" , {|x| AddStmCopy(x) } } )
#endif DEF_HOLZ
#ifdef DEF_ABO
AddIniCmd( { "AboParFilter" , {|x| AddIfNotNil(saAboParFilter,cblock(x)) } } )
AddIniCmd( { "AboVnaFilter" , {|x| AddIfNotNil(saAboVnaFilter,cblock(x)) } } )
#endif DEF_ABO
AddIniCmd( { "LenIdMfc" , {|x| snLenIdMfc := val(x),.t. } } )
AddIniCmd( { "LenIdPgp" , {|x| snLenIdPgp := val(x),.t. } } )
AddIniCmd( { "LenIdRga" , {|x| snLenIdRga := val(x),.t. } } )
AddIniCmd( { "PerShift" , {|x| snPerShift := val(x),.t. } } )
#ifdef DEF_RUN
  AddIniCmd( { "LenCatType" , {|x| snLenIdCty := val(x),.t. } } )
  AddIniCmd( { "LenIdRal" , {|x| snLenIdRal := val(x),.t. } } )
  AddIniCmd( { "LenIdCat" , {|x| snLenIdCat := val(x),.t. } } )
  AddIniCmd( { "LenIdClb" , {|x| snLenIdClb := val(x),.t. } } )
  AddIniCmd( { "LenIdEqu" , {|x| snLenIdEqu := val(x),.t. } } )
  AddIniCmd( { "AgeByYear" , {|x| slAgeByYear := ctol(x),.t. } } )
#endif DEF_RUN
#ifdef DEF_FAB
  AddIniCmd( { "LenIdFab" , {|x| snLenIdFab := val(x),.t. } } )
#endif DEF_FAB
#ifdef DEF_VCS
  AddIniCmd( { "VcsJournals" , {|x| VcsJournals(x) } } )
#endif DEF_VCS
RETURN NIL


FUNCTION AppReadDbi()
saOnMainMenu := {}
sbOnParSatisfy := {||.t.}
saOnParSelect := {}
saTimTestAllow := {}
#ifdef DEF_VNA
  saOnVnaSuggest := {}
#endif DEF_VNA
#ifdef DEF_FIN
  saFnlFillFilter:= {}
#endif DEF_FIN
#ifdef DEF_ODS
  saOnOdlPreClose := {}
#endif DEF_ODS
#ifdef DEF_VCS
  saVcsJournals := {}
#endif DEF_VCS
itinit()
RETURN IniLoad( AppIniCmds(), DbPath() + "\TIM.DBI", .t.)

FUNCTION OpenMail(cToAddr,cToName,cSubject,cBody,cAttach)
RETURN eval(sbOpenMail,cToAddr,cToName,cSubject,cBody,cAttach)


FUNCTION OpenUrl(cURL)
if ! ":" $ cURL
  cUrl := "http://"+cUrl
endif
#ifdef __XPP__
  if scWebBrowser != NIL
    RunShell(cUrl,scWebBrowser,.t.)
    RETURN .t.
  endif
#endif __XPP__
RETURN AppShell("start "+cURL)

FUNCTION OpenCsv(cFilename)
#ifdef __XPP__
  if scOpenCsv != NIL
    RunShell(cFilename,scOpenCsv,.t.)
    RETURN .t.
  endif
#endif __XPP__
RETURN AppShell("start "+cFilename)

#ifdef DEF_FOX

FUNCTION dbf2fox(lConfirm)
RETURN onEachTable({|ad|dbf2fox_(ad,lConfirm)})

FUNCTION fox2dbf(lConfirm)
RETURN onEachTable({|ad|fox2dbf_(ad,lConfirm)})

FUNCTION onEachTable(b)
local a := AppDataList()
local i
local lOkay := .t.
local n := 0
local cName
for i := 1 to len(a)
  if a[i] != NIL
    if IsArchive(a[i])
      lOkay := ArcEval(b,NIL,a[i])
    else
      lOkay := eval(b,a[i])
    endif
    if lOkay
      n += 1
    else
      if ! Confirm(MsgContinue())
        exit
      endif
    endif
  endif
next i
SetMsg(ntrim(n)+" tables have been converted.")
RETURN lOkay

FUNCTION dbf2fox_(ad,lConfirm)
local cName := ddPath(ad)+ad[AD_NAME]
default lConfirm to .t.
if file(cName+".FOX") .and. lConfirm
  RETURN .f. if ! Confirm("Overwrite file "+cName+".FOX ?")
endif
MsgDisplay(cName + ": copy .DBF to .FOX")
LogConsole(cName + ": copy .DBF to .FOX")
use (cName) via ("DBFNTX")
copy to (cName) via ("FOXCDX")
RETURN .t.

FUNCTION fox2dbf_(ad,lConfirm)
local cName := ddPath(ad)+ad[AD_NAME]
default lConfirm to .t.
if file(cName+".DBF") .and. lConfirm
  RETURN .f. if ! Confirm("Overwrite file "+cName+".DBF ?")
endif
MsgDisplay(cName + ": copy .FOX to .DBF")
LogConsole(cName + ": copy .FOX to .DBF")
use (cName) via ("FOXCDX")
copy to (cName) via ("DBFNTX")
RETURN .t.

#endif DEF_FOX


#ifdef DEF_VCS

FUNCTION VcsJournals(x)
RETURN saVcsJournals if x == NIL
saVcsJournals := splitws(x)
RETURN .t.

FUNCTION JnlVcsPos(cIdJnl)
local i
cIdJnl := trim(cIdJnl)
for i := 1 to len(saVcsJournals)
    RETURN i-1 if saVcsJournals[i] == cIdJnl
next i
RETURN NIL

FUNCTION VcsIdJnl(cVcs)
local i := val(left(cVcs,1))
RETURN NIL if i >= len(saVcsJournals)
RETURN padr(saVcsJournals[i+1],LenIdJnl())
  


#endif

#ifdef DEF_KITZ

/**
20090528
Example:
KrgKrmPrix iif(inrange(KRG->IdKrg,"001188","001300"),26.72,0)
**/

FUNCTION KrgKrmPrix()
RETURN eval(sbKrgKrmPrix)

#endif DEF_KITZ

