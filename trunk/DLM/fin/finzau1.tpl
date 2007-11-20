[=p_SetWidth(76)]
[set montant S10]
[=SetDateFormat(tr("dd.mm.yy","dd.mm.yy","dd/mm/yy"))]
Ordre de paiement : [= FIN->IdJnl] [= FIN->IdDoc]
Date d'ex‚cution [= dtocf(FIN->Date)]
Fichier de transfert ISABEL : [=FinOtiCreate(\
  AppPath()+"\TEMP\"+FIN->IdDoc+"."+FIN->IdJnl,\
  "123","123123456712","D"\
)]

[tab define ³ÄÅ]
[tab column L3 "N§" "[= FNL->Line]"]
[tab column R10 "Montant" "[= FNL->Mont]"]
[tab column L14 "Compte b‚n‚" "[= trim(PAR->Compte1)]"]
[tab column L30 "B‚n‚ficiaire" "[par name1]"]
[tab column L30 "Communication" "[= trim(FNL->Libell)]"]
[tab begin]
[fin fnllist "[tab exec]"]
[tab end]

TOTAL : [=FIN->IdDev] [=ntomf(val(FIN->Mont2),DevDecPos(FIN->IdDev))]

