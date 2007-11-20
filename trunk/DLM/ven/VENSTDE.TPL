[=p_SetWidth(76)]
[set montant S10]
[=SetDateFormat(tr("mmmm d, yyyy","d. mmmm yyyy","d mmmm yyyy"))]
[=SetTplHeader({||fparse("MYHEAD.TPL")})]
[=SetTplFooter({||fparse("VENFTR.TPL")},.t.)]

[set align r]
[B][=VEN->IdJnl+" "+VEN->IdDoc][b]
[=tr("Date : ","Datum : ","Date : ")+dtocf(VEN->Date)]
[set align l]

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


You introduced the following cash receipts for declarable company expenses.
(All amounts in [=VEN->IdDev])

[ven memo]
[tab define " � "]
[=p_addColumn(3,"TR","Pos","[=VNL->Line]")]
[=p_addColumn(LenObjet(),"TL","Accnt.","[=VNL->IdArt]")]
[=p_addColumn(0,"TL",\
  tr("Description","Beschreibung","Description"),"[vnl descript amt]")]
[=p_addColumn(LenMntF(),"BR",tr("w/o VAT","ohne MWSt","HTVA"),"[vnl htva]")]
[=p_addColumn(3,"BR",tr("%","%","%"),"[=VNL->IdTax]")]
[=p_addColumn(LenMntF(),"BR",tr("VAT","MWSt","TVA"),"[vnl mtva]")]
[=p_addColumn(LenMntF(),"BR",tr("VAT incl","inkl.MWSt","TVAC"),"[vnl tvac]")]
[tab begin]
[ven vnllist "[tab exec]"]
[tab end]
--- ------ ---------------------------- ---------- --- ---------- ----------
                                        [ven htva]     [ven mtva] [ven tvac]

[etc if .f.]
[set align r]
[=tr("Total :","Gesamtbetrag :","Total :")] [=VEN->IdDev] [ven htva]
[ven memo_tax]
[etc if VenMtva("BEF")!=0]
컴컴컴컴컴컴컴
[=tr("Total incl. tax :","Gesamt inkl. MWSt. :","Total T.V.A. comprise:")] [=VEN->IdDev] [ven tvac]
[etc endif]
[set align l]
[etc endif]


For confirmation :  ________________________

