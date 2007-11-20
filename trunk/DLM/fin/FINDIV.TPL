[=p_SetWidth(76)]
[set montant S10]
[=SetDateFormat(tr("dd.mm.yy","dd.mm.yy","dd/mm/yy"))]

Misc. transaction [= FIN->IdJnl] [= FIN->IdDoc]
Date : [= dtocf(FIN->Date)]
Period : [= FIN->Periode]
Remark : [= FIN->Remarq]

[tab define ³ÄÅ]
[=p_addColumn(3,"TR","Pos","[=FNL->Line]")]
[=p_addColumn(LenIdGen(),"BR","IdGen","[=if(empty(FNL->IdCtr),FNL->IdCpt,'')]")]
[=p_addColumn(LenIdPar(),"BR","IdPar","[=if(empty(FNL->IdCtr),'',FNL->IdCpt)]")]
[=p_addColumn(LenIdCtr(),"BR","Z","[=FNL->IdCtr]")]
[=p_addColumn(LenMntF(),"BR",tr("Amount","Betrag","Montant"),"[=FNL->Mont]")]
[=p_addColumn(3,"BR","D/C"," [=FNL->DC] ")]
[tab column L30 "Remark" "[= trim(FNL->Libell)]"]
[fin fnllist "[tab exec]"]
[tab end]


