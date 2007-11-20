[=mparse("MYHEAD.TPL")]
[=space(GetVar("VEN.AdrMargin"))][=trim1(PAR->Allo)]
[=space(GetVar("VEN.AdrMargin"))][=trim1(PAR->Vorname)+trim(PAR->Firme)]
[etc if !empty(PAR->Name2)]
[=space(GetVar("VEN.AdrMargin"))][=trim(PAR->Name2)]
[etc endif]
[=space(GetVar("VEN.AdrMargin"))][par street]
[=space(GetVar("VEN.AdrMargin"))][par city]
[etc if PAR->Pays !=MemPays]
[B][=space(GetVar("VEN.AdrMargin"))][=NatField(PAR->Pays,"NAT->Name")][b]
[etc endif]

                       
                
[etc if .f.]
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ [=padr(JnlDocLib(VEN->IdJnl,VEN->IdDoc,VEN->DC)+" "+VEN->IdDoc,40)][=padr(tr("Your ref.: ","Ihre Ref.: ","Votre r‚f.")+VEN->NB2,35) ] ³
³ [=padr(tr("Date : ","Datum : ","Date : ")+dtocf(VEN->Date)    ,40)][=padr(if(VEN->IdReg$"N","",tr("Your VAT id: ","Ihre MWSt-Nr.: ","Votre nø TVA")+PAR->NoTva),35)] ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
[etc else]

[B][=JnlDocLib(VEN->IdJnl,VEN->IdDoc,VEN->DC)+" "+VEN->IdDoc][b]

[=tr("Date : ","Datum : ","Date : ")+dtocf(VEN->Date)]

[etc endif]
