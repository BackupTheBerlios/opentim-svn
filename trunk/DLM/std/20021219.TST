// Neues Modul IBAN

#skip if ! HasDlm("IBAN")


// Beispiel kommt von
// http://www.dexia.be/Home_fr/frame.asp?dir=/Private_fr/Payment&page=iban.asp&leftmenu=1

// GÅltige Kontonummer Dexia Bank:
// 20031017 : die folgende Zeile failte, und das ist auch richtig so.
//            (wenn BE Ausland ist, dann sollen Kontonummern laut IBAN
//             und nicht wie in Belgien Åblich formatiert werden)
// TstEqual(BqePostEdit("GKCCBEBB:BE35 0630 2555 0037"),"GKCCBEBB:BE35 063-0255500-37")
//

// GÅltige belgische Kontonummer
TstEqual(BqePostEdit("0630 2555 0037"),"063-0255500-37")

// Landescode stimmt nicht mit dem vom Dexia Åberein :
TstEqual(BqeValidate("GKCCBEBB:DE35 0630 2555 0037"),.f.)

// Landescode stimmt, aber Kontonummer ist keine gÅltige belgischer Nr.
TstEqual(BqeValidate("GKCCBEBB:BE35 0630 2555 0036"),.f.)

// ungÅltiger BIC
TstEqual(BqeValidate("foo:BE35 0630 2555 0037"),.f.)


// http://www.abb-bvb.be/gen/fr/search.idq?CiRestriction=IBAN&CiScope=%2F&FastDir=%2Fgen%2Ffr&HTMLQueryForm=search.html
// FR14 2004 1010 0505 0001 3M02 606
// "AGRIFRPP882","FR76 1820 6000 1030 5696 6400 117"
// "AGRIFRPP882:FR76 1820 6000 1030 5696 6400 117"
// BE62 5100 0754 7061
// NL91 ABNA 0417 1643 00

