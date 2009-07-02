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

#define USR_IDUSR  1
#define USR_NAME   2
#define USR_ATTRIB 3
#define USR_ALEN   3

#define JNL_IDJNL    1
#define JNL_ALIAS    2
#define JNL_NAME     3
#define JNL_ATTRIB   4
#define JNL_IDCTR    5
#define JNL_IDGEN    6
#define JNL_DC       7
#define JNL_IDDEV    8
#define JNL_DOCLIB1  9
#define JNL_DOCLIB2  10
#define JNL_DOCLIB3  11
#define JNL_DOCLIB1N  12
#define JNL_DOCLIB2N  13
#define JNL_DOCLIB3N  14
#define JNL_LNCODE  15
#define JNL_IDTPT   16
#define JNL_IDTPL   17
#define JNL_IDGRJ   18
#define JNL_IDCDC   19
#define JNL_IDDBV   20
#define JNL_CODECLI 21
#define JNL_COMPTE  22
#define JNL_CODEBQE 23
#define JNL_TAXDECPOS 24
#define JNL_DOCATTR 25
#define JNL_IDHCL   26
#define JNL_SEQTYPE 27
#ifdef DEF_4LANG
  #define JNL_DOCLIB4  28
  #define JNL_DOCLIB4N  29
  #define JNL_ALEN    29
#else
  #define JNL_ALEN    27
#endif

#define SEQTYPE_M "M"
#define SEQTYPE_Y "Y"
#define SEQTYPE_E "E"
#define SEQTYPE_C "C"


#define PRT_ID         1
#define PRT_NAME       2
#define PRT_DC         3
#define PRT_IDREG      4
#define PRT_FIRSTID    5
#define PRT_LASTID     6
#define PRT_IDCTR      7
#define PRT_IDQRY      8
#define PRT_IDQRY_PICK 9
#define PRT_ALEN       9

#define GRJ_ID       1
#define GRJ_NAME     2
#define GRJ_ALEN     2

* #define CDC_ID       1
* #define CDC_NAME     2
* #define CDC_ALEN     2

* #define JNC_IDJNC    1
* #define JNC_NAME     2
* #define JNC_JNLLIST  3
* #define JNC_ALEN     3

#define CTR_ID       1
#define CTR_NAME     2
#define CTR_IDGEN    3
#define CTR_PRTLIST  4
#define CTR_DC       5
#define CTR_ATTRIB   6
#define CTR_HSTCOLS  7
#define CTR_TPLINI   8
#define CTR_ALEN     8

*#define ECS_IDECS    1
*#define ECS_NAME     2
*#define ECS_IDJNL    3
*#define ECS_CPTTYPE  4
*#define ECS_DUREE    5
*#define ECS_IDTXT    6
*#define ECS_DC       7
*#define ECS_ALEN     7

* #define IFC_TPLDOC   3
* #define IFC_TPLIFC   6
* #define IFC_PRTLIST  1
#define IFC_IDCTR    1
#define IFC_IDJNL    2
#define IFC_ATTRIB   3
#define IFC_DELAI    4
#define IFC_IDTPL    5
#define IFC_MEMO1    6
#define IFC_MEMO2    7
#define IFC_MEMO3    8
#define IFC_IDMFC    9
#define IFC_IDREG   10
#define IFC_TEXT    11
#define IFC_IDPAR   12
#define IFC_MEMO4   13
#define IFC_ALEN    13

#ifdef DEF_VNA

  #define TRN_DC       1
  #define TRN_IDJNL1   2
  #define TRN_IDGRJ1   3
  #define TRN_IDJNL2   4
  #define TRN_IDGRJ2   5
  #define TRN_ATTRIB   6
  #define TRN_CARRY    7
  #define TRN_ALEN     7

  #define VNA_NB1        1
  #define VNA_DATE       2
  #define VNA_IDART      3
  #define VNA_QTE        4
  #define VNA_QTEUS      5    // virtual
  #define VNA_PRIXU      6
  #define VNA_BACKMATCH  7
  #define VNA_MATCH      8
  #define VNA_TAGGED     9    // virtual
  #define VNA_MEMO      10
  #define VNA_SATIS     11
  #define VNA_CODE      12
  #define VNA_IDJNL     13
  #define VNA_IDDOC     14
  #define VNA_DC        15
  #define VNA_QTEFORM   16    // virtual
  #define VNA_UPDATE    17
  #define VNA_IDPAR     18
  #define VNA_IDINT     19
  #define VNA_QTESTAT   20
  #define VNA_PRIXL     21
  #define VNA_ATTRIB    22
  // #define VNA_RECNO     23
  #define VNA_LINE      23
  #define VNA_ALEN      23
  * #define VNA_PRIXP     21
  * #define VNA_IDPGA     22

#endif DEF_VNA

#ifdef DEF_VEN

  #define NAF_NB1        1
  #define NAF_DATE       2
  #define NAF_IDART      3
  #define NAF_HTVA       4
  #define NAF_QTE        5
  #define NAF_PRIXU      6
  #define NAF_BACKMATCH  7
  #define NAF_LINE      8
  // #define NAF_MATCH      8
  #define NAF_TAGGED     9    // virtual
  #define NAF_MEMO      10
  #define NAF_MTVA      11
  #define NAF_CODE      12
  #define NAF_IDJNL     13
  #define NAF_IDDOC     14
  #define NAF_DC        15
  #define NAF_QTEFORM   16    // virtual
  #define NAF_UPDATE    17
  #define NAF_IDPAR     18
  #define NAF_IDINT     19
  #define NAF_QTESTAT   20
  #define NAF_PRIXL     21
  #define NAF_ATTRIB    22
  #define NAF_AFTER     23
  #define NAF_TVAC      24
  #define NAF_EDIT      25
  #define NAF_ALEN      25

#endif DEF_VEN

#ifdef DEF_TAX

  #define TAX_IDTAX    1
  #define TAX_LIBELL   2
  #define TAX_TAUX     3
  #define TAX_IDCTR    4
  #define TAX_ATTRIB   5
  #define TAX_IDGEN    6
  #define TAX_GENTIERS 7
  * #define TAX_IDCLJ    8
  #define TAX_MEMO1    8
  #define TAX_MEMO2    9
  #define TAX_MEMO3   10
  #define TAX_DATE    11
  #define TAX_VALID   12
  #define TAX_REGLIST 13
  #define TAX_MEMO4   14
  #define TAX_ALEN    14

  #define REG_IDREG   1
  #define REG_LIBELL  2
  #define REG_IDTAX   3
  #define REG_ATTRIB  4
  #define REG_TEXT    5
  #define REG_ALEN    5

#endif DEF_TAX

#define DIF_IDCTR   1
#define DIF_DC      2
#define DIF_NAME    3
#define DIF_IDGEN   4
#define DIF_ALEN    4

#define VRT_IDVRT  1
#define VRT_NAME   2
#define VRT_START  3
#define VRT_LEN    4
#define VRT_ATTRIB 5
#define VRT_SEPAR1 6
#define VRT_SEPAR2 7

#define DEV_IDDEV  1
#define DEV_LIBELL 2
#define DEV_COURS  3
#define DEV_DECPOS 4
#define DEV_COURS2 5
#define DEV_DELTA  6
#define DEV_ALEN   6

#define IPB_IDCTR     1
#define IPB_IDREG     2
#define IPB_IDCAT     3
#define IPB_IDTAX     4
#define IPB_GENBASE   5
#define IPB_ATTRIB    6
#define IPB_IDDEV     7
#define IPB_IDDMA     8
#define IPB_WHEN      9
#define IPB_ALEN      9

#define UNT_IDUNT 1
#define UNT_NAME1 2
#define UNT_NAME2 3
#define UNT_NAME3 4
#define UNT_QTEFORM 5
#define UNT_ALEN  5


**
** "VIRTUAL" RUNTIME OBJECTS - exist only at runtime in memory
**

* #define TVA_IDTAX   1  // Code TVA
* #define TVA_BASE    2  // montant base
* #define TVA_TAXE    3  // montant taxe
* #define TVA_BASEDB  4  // montant taxe (devise de base)
* #define TVA_TAXEDB  5  // montant taxe
* #define TVA_ALEN    5

#define DOC_LIBELL  1
#define DOC_IDPAR   2
#define DOC_ECHE    3
#define DOC_IDDEV   4
* #define DOC_COURS   5
#define DOC_ETAT    5
#define DOC_MONT    6
#define DOC_DATE    7
#define DOC_DC      8
#define DOC_MATCH   9
#define DOC_NB     10
#define DOC_IDANA  11
#define DOC_MEMO   12
#define DOC_ALEN   12

#define ESC_IDESC   1
#define ESC_LIBELL1 2
#define ESC_LIBELL2 3
#define ESC_LIBELL3 4
#define ESC_LIBELL4 5
#define ESC_DELAI   6
#define ESC_ATTRIB  7
#define ESC_IDTXT   8
#define ESC_TAUX    9


#define CDS_IDCDS  1
#define CDS_NAME   2
#define CDS_ALEN   2

*#define TRN_IDCDS1  1
*#define TRN_IDCDS2  2
*#define TRN_IDCDS3  3
*#define TRN_LIBELL  4
*#define TRN_ATTRIB  5
*#define TRN_IDJNL   6
*#define TRN_IDTXT   7

#define AWC_IDAWC   1
#define AWC_DESIG   2
#define AWC_PRIXV   3
#define AWC_PRIXA   4

#define AGS_IDAGS   1
#define AGS_DESIG   2
#define AGS_ATTRIB  3
#define AGS_IDTPL   4
#define AGS_NEXT    5


**
** PREPARATIONAL OBJECT : une transaction est un ensemble de MVT_
**                        dont les sommes D/C sont Çgales.
**

**
** MVT-Records fÅr das Collect-Array beim Registrieren VEN oder FIN
**
#define MVT_IDGEN   1
#define MVT_ISBASE  2
#define MVT_LINE    3
#define MVT_TAX     4
#define MVT_MONT    5  // vorher MVT_TAXE
#define MVT_MONTDB  6
// #define MVT_TAXEDB  7
#define MVT_SK      7
#define MVT_IDANA   8
#define MVT_ALEN    8

#define MVG_IDGEN   1
#define MVG_DC      2
#define MVG_MONT    3
#define MVG_DATE    4
* #define MVG_IDJNL   5
#define MVG_PERIODE 5
#define MVG_LINE    6
#define MVG_IDTAX   7
#define MVG_MONTDEV 8
#define MVG_IDANA   9
#define MVG_ALEN    9

**
** MVP-Records fÅr das Collect-Array beim Registrieren FIN
**
* #define MVP_IDCTR   1
* #define MVP_IDPAR   2
* #define MVP_MONT    3
* #define MVP_LINE    4 // (nur bei FIN benutzt, bei VEN leer)
* #define MVP_MATCH   5
* #define MVP_IDBUD   6

**
** MVA-Records fÅr das Collect-Array beim Registrieren FIN
**
* #define MVB_IDCTR   1
#define MVB_IDBUD   1
#define MVB_MONT    2
#define MVB_LINE    3 // (nur bei FIN benutzt, bei VEN leer)
#define MVB_ALEN    3

#ifdef DEF_VEN

#define VEN_IDJNL  1
#define VEN_IDDOC  2
#define VEN_REMARQ 3
#define VEN_MEMO   4
#define VEN_IDPAR  5
#define VEN_AVNL   6
#define VEN_MONT   7
#define VEN_ALEN   7

#define ALN_CODE      1
#define ALN_IDART     2
#define ALN_QTE       3
#define ALN_DESIG     4
#define ALN_PRIXU     5
#define ALN_IDTAX     6
#define ALN_MONTT     7
#define ALN_MONTB     8
#define ALN_QTE1      9
#define ALN_QTE2      10
#define ALN_QTE3      11
#define ALN_ATTRIB    12
#define ALN_ALEN      12

#endif DEF_VEN

#ifdef DEF_FIN

#define FNL_IDOP      1
#define FNL_CPTTYPE   2
#define FNL_COMPTE    3
#define FNL_MONT      4
#define FNL_MATCH     5
#define FNL_IDANA     6
#define FNL_DC        7
#define FNL_MONTDEV   8
#define FNL_LIBELL    9
#define FNL_IDDEV    10
#define FNL_DATE     11
#define FNL_ALEN     11

#define FIN_JNL       1
#define FIN_DATE      2
#define FIN_PERIODE   3
#define FIN_AFNL      4
#define FIN_ALEN      4

#endif DEF_FIN

#define AGA_ID   1
#define AGA_NAME 2
#define AGA_ALEN 2

#define PRA_ID   1
#define PRA_NAME 2
#define PRA_ALEN 2

#define GRP_ID   1
#define GRP_NAME 2
#define GRP_ALEN 2

#define MFC_ID    1
#define MFC_NAME1 2
#define MFC_NAME2 3
#define MFC_NAME3 4
#define MFC_NAME4 5
#define MFC_ALEN  5

#define PNS_ID   1
#define PNS_NAME 2
#define PNS_ALEN 2

* #define PMV_ID   1
* #define PMV_NAME 2
* #define PMV_ALEN 2

*#define TMV_IDJNL      1
*#define TMV_CPTTYPE    2
*#define TMV_IDPMV1     3
*#define TMV_IDPMV2     4
*#define TMV_ATTRIB     5

#define CDC_IDCDC   1
#define CDC_DC      2
#define CDC_NAME    3
#define CDC_HEADER  4
#define CDC_EXPR    5
#define CDC_ALEN    5

#ifdef DEF_IMP

  #define SAT_DC       1
  #define SAT_IDJNL1   2
  #define SAT_IDGRJ1   3
  #define SAT_IDJNL2   4
  #define SAT_IDGRJ2   5
  #define SAT_ATTRIB   6
  #define SAT_FILTER   7
  #define SAT_ALEN     7

  #define SRV_IDSRV      1
  #define SRV_NAME       2
  #define SRV_ATTRIB     3
  #define SRV_CODTOT     4
  #define SRV_SUBBUD     5
  #define SRV_IDBUD_D    6
  #define SRV_IDBUD_C    7
  #define SRV_ALEN       7

#endif DEF_IMP


#ifdef DEF_MVI

  #define CTB_IDCDC    1
  #define CTB_DC       2
  #define CTB_PERIODE  3
  #define CTB_IDBUD    4
  #define CTB_MONT     5
  #define CTB_ALEN     6

  #define IMP_DC        1
  #define IMP_IDBUD     2
  #define IMP_IDPAR     3
  #define IMP_JNL       4
  #define IMP_AIML      5
  #define IMP_ALEN      5

  #define IML_DC        1
  #define IML_IDPAR     2
  #define IML_NB1       3
  #define IML_MONT      4
  #define IML_DATE      5
  #define IML_IDBUD     6
  #define IML_BACKMATCH 7
  #define IML_MATCH     8
  #define IML_IDPAR2    9
  #define IML_IDPRJ    10
  #define IML_NB2      11
  #define IML_COMPTE1  12
  #define IML_JNL      13
  #define IML_EAMATCH  14
  #define IML_PERIODE  15
  #define IML_MONTDEV  16
  #define IML_ALEN     16

  #define MVI_LINE       1
  #define MVI_DC         2
  #define MVI_IDPAR      3
  #define MVI_NB1        4
  #define MVI_MONT       5
  #define MVI_DATE       6
  #define MVI_IDBUD      7
  #define MVI_BACKMATCH  8
  #define MVI_MATCH      9
  #define MVI_IDPAR2    10
  #define MVI_IDPRJ     11
  #define MVI_NB2       12
  #define MVI_COMPTE1   13
  #define MVI_MONTUS    14
  #define MVI_MONTCTB   15
  #define MVI_EAMATCH   16
  #define MVI_ALEN      16

#endif DEF_MVI

#ifdef DEF_ART

  #define CTA_IDCTA  1
  #define CTA_NAME   2
  #define CTA_ALEN   2 // Namenskonflikt
  // CTA.DBF = Sammelhistorik Analysekonten
  // CTA.DBC = CatÇgories d'articles

#endif DEF_ART

#ifdef DEF_MVS

  #define MVS_IDART      1
  #define MVS_QTE        2
  #define MVS_MONT       3
  #define MVS_DC         4
  #define MVS_LINE       5
  #define MVS_ALEN       5

#endif DEF_MVS

#ifdef DEF_CTS

  #define CTS_IDJNL    1
  #define CTS_PERIODE  2
  #define CTS_IDART    3
  #define CTS_QTE      4
  #define CTS_MONT     5
  #define CTS_INTRA    6
  #define CTS_QTEFORM  7
  #define CTS_ANZ      8
  #define CTS_ALEN     8

#endif DEF_CTS


#ifdef DEF_STK

  #define QTS_STK      1
  #define QTS_IDART    2
  #define QTS_QTE      3
  #define QTS_MONT     4
  #define QTS_IDSER    5
  #define QTS_VALUE    6
  #define QTS_ALEN     6

  #define STK_IDSTK     1
  #define STK_TYPE      2
  #define STK_DC        3
  #define STK_EXPR      4
  #define STK_XUVALUE   5
  #define STK_ALEN      5

  #define STKTYPE_QTE   "Q"
  #define STKTYPE_PU    "U"
  #define STKTYPE_DATE  "D"
  #define STKTYPE_LAST  "L"

#endif DEF_STK

#define LNG_ID   1
#define LNG_NAME 2
#define LNG_ALEN 2

#ifdef DEF_REMISE

  #define RPP_IDPGP  1
  #define RPP_IDPGA  2
  #define RPP_REMISE 3

  #define RPQ_IDRGA  1
  #define RPQ_IDPGP  2
  #define RPQ_QTE    3
  #define RPQ_REMISE 4

  #define RGA_ID   1
  #define RGA_NAME 2
  #define RGA_ALEN 2

#endif DEF_REMISE

#define PGA_ID     1
#define PGA_DECPOS 2
#define PGA_NAME   3
#define PGA_ALEN   3

#define PGP_ID    1
#define PGP_IDPRT 2
* #define PGP_IDCTR 3
* #define PGP_IDDEV 4
* #define PGP_PRIX  5
#define PGP_NAME  3
#define PGP_ALEN  3

#define DCR_IDDCL    1
#define DCR_IDCTR    2
#define DCR_NAME     3
#define DCR_IDTAX    4
#define DCR_IDCAT    5
#define DCR_ATTRIB   6
#define DCR_IDJNL    7
#define DCR_HEADER   8
#define DCR_DC       9
#define DCR_ALEN     9

#define CLJ_IDCTR    1
#define CLJ_IDCLJ    2
#define CLJ_HEADER   3
#define CLJ_ALEN     3

#define NAT_IDNAT  1
#define NAT_NAME   2
#define NAT_INTRA  3
#define NAT_IDLNG  4
#define NAT_IDTLF  5
#define NAT_PREFIX 6
#define NAT_TVAPRE 7
#define NAT_IDDEV  8
#define NAT_TVAPIC 9
#define NAT_ALEN   9

#ifdef DEF_IMP

  #define GRB_DC     1
  #define GRB_POS    2
  #define GRB_DIENST 3
  #define GRB_HEADER 4
  #define GRB_IDGRB  5
  #define GRB_NAME   6
  #define GRB_ALEN   6

  #define FCB_IDFCB 1
  #define FCB_NAME  2
  #define FCB_ALEN  2

  #define SBB_IDSBB 1
  #define SBB_NAME  2
  #define SBB_ALEN  2

#endif DEF_IMP

#ifdef DEF_TRA

  #define TRT_IDTRT  1
  #define TRT_NAME   2
  #define TRT_DC     3
  #define TRT_IDBUD  4
  #define TRT_IDJNL  5
  #define TRT_EXPR   6
  #define TRT_IDBUDI 7
  #define TRT_IDTPL  8
  #define TRT_ALEN   8

#endif DEF_TRA

#define TPT_ID          1
#define TPT_IDQRY       2
#define TPT_NAME        3
#define TPT_ALEN        3

#define XTV_ALIAS   1
#define XTV_IDQRY   2
#define XTV_NAME    3
#define XTV_FILTER  4
#define XTV_ALEN    4

#ifdef DEF_HOLZ

  #define CLS_IDCLS   1
  #define CLS_CLSTYPE 2
  #define CLS_NAME    3
  #define CLS_MZ      4
  #define CLS_EXPR    5
  #define CLS_ALEN    5

  #define CLSLIST_IDART 1
  #define CLSLIST_IDCLS 2
  #define CLSLIST_MENGE 3
  #define CLSLIST_COUNT 4
  #define CLSLIST_ALEN  4

#endif DEF_HOLZ

* #ifdef DEF_MVP

#define CTP_PERIODE  1
#define CTP_DEBIT    2
#define CTP_CREDIT   3
#define CTP_IDCTR    4
#define CTP_IDPAR    5
#define CTP_UMSATZ   6
#define CTP_ALEN     6

* #endif DEF_MVP

#ifdef DEF_PSC

#define LEN_IDPLT  3

#define PLT_IDPLT  1
#define PLT_NAME   2
#define PLT_ALEN   2

#endif DEF_PSC

#define TLF_IDTLF   1
#define TLF_MINLEN  2
#define TLF_MAXLEN  3
#define TLF_PICTURE 4
#define TLF_ALEN    4

#define IPBATTR_E "E"

#ifdef DEF_OBJ

  #define OBT_ID    1
  #define OBT_NAME  2
  #define OBT_IDQRY 3
  #define OBT_ALEN  3

  #define OBF_NAME  1
  #define OBF_TYPE  2
  #define OBF_LEN   3
  #define OBF_DEC   4
  #define OBF_ALEN  4

  #define NTX_ALIAS 1
  #define NTX_EXPR  2
  #define NTX_TEXT  3
  #define NTX_ALEN  3

#endif DEF_OBJ

#ifdef DEF_VCB
  #define VCB_IDVCB 1
  #define VCB_EXPR  2
  #define VCB_ALEN  2
#endif DEF_VCB

#define TPL_IDTPL  1
#define TPL_IDLNG  2
#define TPL_WIDTH  3
#define TPL_MEMO   4
#define TPL_IDOPT  5
#define TPL_ATTRIB 6
#define TPL_NAME   7
#define TPL_IDDLG  8
#define TPL_ALEN   8


#define MNU_EXPR   1
#define MNU_MENU   2
#define MNU_ITEM   3
#define MNU_MACRO  4
#define MNU_HOTKEY 5
#define MNU_ALEN   5

#ifdef DEF_DGR

  #define DGR_IDDGR   1
  #define DGR_DC      2
  #define DGR_DAYS    3
  #define DGR_NAME1   4
  #define DGR_NAME2   5
  #define DGR_NAME3   6
  #define DGR_IDTPL   7
  #define DGR_ATTRIB  8
  #define DGR_ZINSEN  9
  #define DGR_KOSTEN 10
  #define DGR_ALEN   10

#endif DEF_DGR

#ifdef DEF_KVK

* #define ZLA_IDCTR   1
#define ZLA_IDZLA   1
#define ZLA_NAME    2
#define ZLA_IDCTR   3
#define ZLA_COURS   4
#define ZLA_DECPOS  5
#define ZLA_IDDEV   6
#define ZLA_IDGEN   7
#define ZLA_ALEN    7

*#define SER_IDART   1
*#define SER_IDSER   2
*#define SER_QTE     3
*#define SER_MONT    4
*#define SER_ALEN    4

#endif DEF_KVK

#ifdef DEF_HST

#define HCL_HEADER   1
#define HCL_WIDTH    2
#define HCL_WHEN     3
#define HCL_VALUE    4
#define HCL_TEXT     5
#define HCL_XCSUM    6
#define HCL_ALEN     6

#define TTL_HEADER   1
#define TTL_WHEN     2
#define TTL_ALEN     2

#endif DEF_HST

#ifdef DEF_FIN

#define MATCH_MATCH    1
#define MATCH_MONTD    2
#define MATCH_MONTC    3
#define MATCH_IDCTR    4
#define MATCH_LIBELL   5
#define MATCH_DEVD 6
#define MATCH_DEVC 7
#define MATCH_DATE     8
#define MATCH_TAGGED   9
#define MATCH_IDANA    10
#define MATCH_ALEN     10

#endif DEF_FIN

#ifdef DEF_FNA

#define FNA_IDGEN  1
#define FNA_EXPR   2
#define FNA_IDGEN1 3
#define FNA_IDGEN2 4
#define FNA_ALEN   4

#endif DEF_FNA

#ifdef DEF_EVT

#define EVT_IDEVT  1
#define EVT_NAME   2
#define EVT_IDTPT  3
#define EVT_IDTPL  4
#define EVT_IDMSK  5
#define EVT_ALEN   5

#endif DEF_EVT

#ifdef DEF_INT

  * #define CTI_IDJNL     1
  * #define CTI_IDINT     2
  * #define CTI_NATCODE   3
  * #define CTI_PERIODE   4
  * #define CTI_DC        5
  * #define CTI_QTE       6
  * #define CTI_QTESTAT   7
  * #define CTI_QTEFORM   8
  * #define CTI_MONT      9
  * #define CTI_ALEN      9

#endif DEF_INT

#ifdef DEF_ART

  #define IPR_IDCTR   1
  #define IPR_IDPRT   2
  #define IPR_IDPGP   3
  #define IPR_IDDEV   4
  #define IPR_PRIXU   5
  #define IPR_ATTRIB  6
  #define IPR_ALEN    6

#endif DEF_ART

#ifdef DEF_LGT

#define LGT_XLWHEN 1
#define LGT_NAME   2
#define LGT_IDGEN  3
#define LGT_IDTAX  4
#define LGT_XNBASE 5
#define LGT_ALEN   5

#endif DEF_LGT

#ifdef DEF_FRF

  #define FRF_XLWHEN  1
  #define FRF_IDGEN   2
  #define FRF_IDTAX   3
  #define FRF_XNBASE  4
  #define FRF_XNTAXE  5
  #define FRF_ALEN    5

#endif DEF_FRF

#ifdef DEF_VENREMISE

  #define VNR_FLDNAME 1
  #define VNR_XLWHEN  2
  #define VNR_XNMULT  3
  #define VNR_MONT    4
  #define VNR_ALEN    4

#endif DEF_VENREMISE

#ifdef DEF_RUN
  #define CLB_IDCLB    1
  #define CLB_NAME     2
  #define CLB_ALEN     2

  #define EQU_IDEQU    1
  #define EQU_NAME     2
  #define EQU_ALEN     2

  #define CAT_IDCAT    1
  #define CAT_SEX      2
  #define CAT_AGELIMIT 3
  #define CAT_NAME     4
  #define CAT_ALEN     4

#endif DEF_RUN


#ifdef DEF_RSV

  #define LEN_IDRST   3
  #define LEN_IDRSC   3
  * #define LEN_IDTSL   2

  * #define TSL_IDTSL 1
  * #define TSL_TIME1 2
  * #define TSL_TIME2 3
  * #define TSL_ALEN 3

  #define RST_IDRST 1
  #define RST_NAME  2
  #define RST_ALEN  3

  #define ORD_RSI_DATE 1
  #define ORD_RSI_DOC  2
  #define ORD_RSI_RST  3
  #define ORD_RSI_RSC  4

#endif DEF_RSV

#ifdef DEF_HTN

#define LEN_IDHTN 8
#define LEN_IDHTC 8
#define LEN_IDHTS 8

#endif DEF_HTN

#ifdef DEF_ALS

#define ALSATTR_R "R"

#define TPLTYPE_ALS "ALS"
#define ORD_ALM_ALS     1
#define ORD_ALM_ART     2

#endif DEF_ALS

#ifdef DEF_WWW

#define MST_IDMST   1
#define MST_NAME1   2
#define MST_SORT    3
#define MST_ATTRIB  4
#define MST_IDTPL   5
#define MST_ALEN    5

#endif DEF_WWW

#ifdef DEF_RFX

#define LEN_RFX 10

#endif DEF_RFX



#ifdef DEF_VOC
#define LEN_IDVOC 6
#endif DEF_VOC

#ifdef DEF_BIBLIO
#define DTPATTR_A "A"
#define DTPATTR_D "D"
#define DTPATTR_R "R"
#define DTPATTR_G "G"
#define DTPATTR_B "B"
#endif DEF_BIBLIO

#define VNASATIS_D "D"


#ifdef DEF_IBAN

#define BAN_NBAN   1
#define BAN_BIC    2
#define BAN_IBAN   3

#endif