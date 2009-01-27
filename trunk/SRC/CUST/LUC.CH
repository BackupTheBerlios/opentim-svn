**
** File Name ...... : luc.ch
** Application .... : TIM300
** Description .... : Modification causes re-compilation of each .prg
** Copyright ...... : Luc Saffre, P.A.C. Systems, Eupen, Belgium
**

#define DEF_NOWAIT
#define LG_EN

#define DEF_FILTER
#define DEF_TOOLBOX  // rename, user WRITE, ...
#define DEF_LAYOUT

#define DEF_MACROREC
#define DEF_GIMMICK   // Fichier Compter et Fichier Valider
#define DEF_IMPORT
#define DEF_SEEK      // Edition Recherche
#define DEF_SHELL     // external editor, programmes externes

#define DEF_BRAND      // Application with copy protection
#define DEF_LOGIN      // Application with USR.DBF and login system

* #define DEF_WRITE

**
** TIM #defines
**

#define DEF_JNL
#define DEF_VEN
#define DEF_TAX
#define DEF_CTT
* #define DEF_FAC

#define DEF_GEN
#define DEF_FIN
* #define DEF_ECHE
#define DEF_RAPPEL


#define DEF_ART
#define DEF_GRA
#define DEF_IPB
#define DEF_UNT
* #define DEF_IVT
#define DEF_STK
* #define DEF_MOD
* #define DEF_SPC


* #define DEF_INTRA

#define DEF_MEMO
* #define DEF_PTG
* #define DEF_PSC

#define DEF_LOGFILE
#define DEF_TPL

* #define DEF_XTV

* #define DEF_HOLZ

#define DEF_MSG

#define DEF_CTS       // Sammelhistorik Artikel

#define DEF_ACT

// #define DEF_BIL

* #define DEF_KVK


#define DEF_TIM220

*  #define DEF_VNA       // Automatik-Fakturierung
#define DEF_ODS       // OD's de stock
*  #define DEF_MVS       // mouvements de stock
#define DEF_ANA       // Analytische Buchhaltung
#define DEF_ANAFIN
*  #define DEF_INT
*  #define DEF_PRIXR


* #define DEF_DBDEDIT


// [970708] : DEF_MVP raus
#define DEF_CTP
#define DEF_CTG
#define DEF_HST
* #define DEF_DCL

#define DEF_REPORT

** mal rein, mal raus :
**
#define DEF_PRESTO
#define DEF_VENREMISE
#define DEF_VNLATTR
* #define UPGRADE_96

// FÅr Leute, die von CUST_AMG kommen
* #define DEF_CARRY
* #define DEF_CFN
* #define DEF_MULT
* #define DEF_PRIXR
* #define DEF_GRAREMISE
#define DEF_CONSOLE

#undef DEF_HELP

#define DEF_PLS
#define DEF_VOC

#define DEF_SQLEXPORT
// #define DEF_TREE

#define DEF_ALA       // Artikelkomponenten
#define DEF_ACF

// #define DEF_ALS       // Artikellisten

// #define DEF_GPF

#define DEF_PRJ
#define DEF_WWW

#define DEF_NETWORK   // no default "EXCLUSIVE" in OPEN AREA

#define DEF_PLP  // Ñhnlich wie DEF_PSC
#define DEF_LIC
#define DEF_4LANG
#define DEF_UNITTEST

#define DEF_RFX

// #define DEF_BIBLIO
#define DEF_LITERA
// N.B. Litera und Biblio sind nicht miteinander kombinierbar, weil
// oAut() dann doppelt ist. Sind aber auch zwei verschiedene AnsÑtze fÅr
// das Gleiche

#define DEF_NEWS
// #define DEF_IMAGES
// 20070307 #define DEF_LFN

// #define DEF_DEBUG

// #define DEF_VERBOSE
#define DEF_IE10

#define CUST_RUMMA

#define DEF_DCL
#define DEF_MTG

#define DEF_DLS
// #define DEF_DRG

// #define DEF_TSK

#define DEF_PIN

#define DEF_FOX

// #define DEF_ALT

// #define DEF_EID

#define DEF_INDEX


#define DEF_LOC

#define DEF_VCS
#define DEF_IBAN
