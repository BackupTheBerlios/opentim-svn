// ntom() holt jetzt („hnlich wie zuvor schon ntomf()) Nullen hinterm
// Komma weg, wenn dies aus Platzmangel n”tig ist.
// Siehe auch Nachtrag 20060207

TstEqual(ntom(-1840000,2)   ,"-1840000.0")
TstEqual(ntom(-1840000.1,2) ,"-1840000.1")
TstEqual(ntom(-1840000.12,2),\
  iif(AppCompiler()=="xbase","*******.**","**********"))
TstEqual(ntom(11840000.01,2),\
  iif(AppCompiler()=="xbase","*******.**","**********"))
TstEqual(ntom(11840000.1,2) ,"11840000.1")
TstEqual(ntom(11840000.1,3) ,"11840000.1")
