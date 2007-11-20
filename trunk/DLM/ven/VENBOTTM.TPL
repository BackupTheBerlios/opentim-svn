[etc if VEN->IdReg$"I"]

[etc if TplLang()=="D"]
Innergemeinschaftliche Warenlieferung. \
Ihre MWSt-Id-Nr.: [=if(empty(PAR->NoTva),"(bitte mitteilen!)",trim(PAR->NoTva))]
[etc endif]
[etc if TplLang()=="F"]
Livraison intracommunautaire de marchandises. \
Votre Id TVA : [=if(empty(PAR->NoTva),"(… nous communiquer s.v.p.!)",trim(PAR->NoTva))]
[etc endif]
[etc endif]
[etc if VEN->IdReg$"X"]

[etc if TplLang()=="D"]
Export von Dienstleistungen. \
Ihre MWSt-Id-Nr.: [=if(empty(PAR->NoTva),"(bitte mitteilen!)",trim(PAR->NoTva))]
[etc endif]
[etc if TplLang()=="F"]
Export de prestations de service. \
Votre Id TVA : [=if(empty(PAR->NoTva),"(… nous communiquer s.v.p.!)",trim(PAR->NoTva))]
[etc endif]
[etc endif]
[etc if VEN->IdReg$"AC"]

[etc if TplLang()=="D"]
Ihre MWSt-Nr.: [=trim(PAR->NoTva)].
[etc endif]
[etc if TplLang()=="F"]
Votre nø T.V.A.: [=trim(PAR->NoTva)].
[etc endif]
[etc if TplLang()=="E"]
Your V.A.T. id : [=trim(PAR->NoTva)].
[etc endif]
[etc endif]
[etc if VEN->DC=='D'.and.!empty(VEN->IdMfc)]

[etc if empty(VenIfcMemo())]
[=tr("Payment:","Zahlungsbedingungen:","Mode de paiement:")] \
[=MfcName(VEN->IdMfc,TplLang())]
[etc else]
[ven memo_ifc]
[etc endif]
[etc endif]
[=mparse("VENNEWS.TPL")]
