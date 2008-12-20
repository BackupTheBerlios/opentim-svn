



[=space(42)][=trim1(PAR->Allo)]
[=space(42)][=trim1(PAR->Vorname)+trim1(PAR->Firme)]
[etc if !empty(PAR->Name2)]
[=space(42)][=trim(PAR->Name2)]
[etc endif]
[=space(42)][par street]
[=space(42)][B][=if(TplLang()=="F",upper(trim(ParCity())),trim(ParCity()))][b]
[=space(42)][=iif(PAR->Pays==MemPays,'',NatField(PAR->Pays,"trim(NAT->Name)"))]

[etc if empty(PAR->Name2)]

[etc endif]





