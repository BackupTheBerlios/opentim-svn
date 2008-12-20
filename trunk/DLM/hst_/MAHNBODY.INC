[set margintop 2]
[tab define " Ä "]
[tab column L0 "Bezeichnung" "[=ActExec('HSTTEXT')]"]
[tab column L8 "Datum " "[=dtocf(HST->Date)]"]
[tab column L8 "Z-Ziel" "[=dtocf(HstDate2())]"]
[tab column L10 "šberf„llig" "[=if(HstDate2()<UserDate().and.HST->DC=='D',\
 ntomf(HstDb2Dev(PAR->IdDev)),space(LenMntF()))]"]
[tab column L10 "offen" "[=if(HstDate2()>=UserDate().and.HST->DC=='D',\
 ntomf(HstDb2Dev(PAR->IdDev)),space(LenMntF()))]"]
[tab column R10 "Kredit" "[=if(HST->DC=='C',\
 ntomf(HstDb2Dev(PAR->IdDev)),space(LenMntF()))]"]
[tab begin]
[par hstlist "[tab exec]"]
[tab end]

[etc if ParCredit()!=0]
[=padl("Total",p_cpl()-35)] : [par hstdebit] [par hstcredit]
[=padl("Saldo",p_cpl()-35)] : [par hstsolde d] [par hstsolde c]
[etc endif]
[etc if !empty(getvar("Kosten"))]
[=padl("Kosten",p_cpl()-35)] : [=ntomf(val(getvar("Kosten")))]
[etc endif]
[=padl("Zu zahlen",p_cpl()-35)] : [=ntomf(\
  val(getvar("Kosten"))+ParDebit()-ParCredit())] [= PAR->IdDev]
