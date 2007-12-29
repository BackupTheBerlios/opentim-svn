[=p_SetWidth(76)]
[set montant S10]
[=SetDateFormat(tr("dd.mm.yy","dd.mm.yy","dd/mm/yy"))]

Kassenauszug [= FIN->IdJnl] [= FIN->IdDoc]
Auszugdatum [= dtocf(FIN->Date)]

Alter Saldo    [=ntomf(val(FIN->Mont1))] TOTAL

[tab define ³ÄÅ]
[=p_addColumn(3,"TR","Pos","[=FNL->Line]")]
[=p_addColumn(LenIdGen(),"BR","IdGen","[=if(empty(FNL->IdCtr),FNL->IdCpt,'')]")]
[=p_addColumn(LenIdPar(),"BR","IdPar","[=if(empty(FNL->IdCtr),'',FNL->IdCpt)]")]
[tab column R12 "Montant" "[= FNL->Mont] [= FNL->DC]"]
[tab column L30 "Communication" "[= trim(FNL->Libell)]"]
[fin fnllist "[tab exec]"]
[tab end]

Neuer Saldo    [=ntomf(val(FIN->Mont2))] TOTAL


