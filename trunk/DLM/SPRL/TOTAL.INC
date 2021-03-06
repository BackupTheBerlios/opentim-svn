[etc if VEN->IdReg$"I".and."I"$JnlAttrib(VEN->IdJnl)]
IntraStat : ��[=repl("�",10)]���[=repl("�",LenQte())]���[=repl("�",LenQte())]���[=repl("�",LenMont())]���[=repl("�",LenMont())]Ŀ
            � [=padr("Code",10)] � [=padl("Kg",LenQte())] � [=padl("m�",LenQte())] � [=padl("EUR",LenMont())] � [=padl(VEN->IdDev,LenMont())] �
[etc do DbfScan([oHsi(),oInt()],1,\
  VEN->IdJnl+VEN->IdDoc,\
  "HSI->IdJnl+HSI->IdDoc=='"+VEN->IdJnl+VEN->IdDoc+"'",\
  "IntExist(HSI->IdInt)","toStream(\
    '            � '+INT->Code+' � '+HSI->QteStat+' � '+HSI->Qte+' � '\
    +HSI->Mont+' � '+HSI->MontDev+' �'+chr(13)+chr(10)\
  )"\
)]
            ��[=repl("�",10)]���[=repl("�",LenQte())]���[=repl("�",LenQte())]���[=repl("�",LenMont())]���[=repl("�",LenMont())]��
[etc endif]
[etc line]
[etc if 'O'$VEN->Attrib]
[set align r]
[etc if !empty(VEN->Remise)]
[=tr("Total before discount","Gesamt brutto","Total brut")] : [=ntomf(val(VEN->MontR))]
[=tr("Discount","Rabatt","Remise")] [=ltrim(VEN->Remise)] % : [=ntomf(\
  val(VEN->Mont)-val(VEN->MontT)-val(VEN->MontR)\
)]
[etc endif]
[=tr("Total","Gesamtbetrag :","Total :")] [ven htva]
[ven memo_tax]
[etc if VenMtva(VEN->IdDev)!=0]
[=repl("�",35)]
[=tr("Total w/o taxes","Gesamt inkl. MWSt. :","Total T.V.A. comprise :")] [ven tvac]
[etc endif]
[etc do setvar("zuZahlen",val(VEN->Mont))]
[etc if type("VEN->Anzahlung")=="C".and.!empty(VEN->Anzahlung)]
[etc do DlgPlus("zuZahlen",-val(VEN->Anzahlung))]
[=tr("Account","Anzahlung","Acompte")] : [=ntomf(-val(VEN->Anzahlung))]
[=tr("to pay","zu zahlen","� payer")] : [=ntomf(getvar("zuZahlen"))]
[etc endif]
([=if(TplLang()=="D","Alle Preise in ","Tous les prix en ")+VEN->IdDev])
[etc if VEN->IdDev!="EUR"]
([=MsgMontant(TplLang())] EUR : [=ltrim(ntomf(VenMont2Dev("EUR",DlgValue("zuZahlen")),2))])
[etc endif]
[etc if .f.]
[etc if VEN->IdDev=="EUR".and.PAR->Pays=="D  "]
([=MsgMontant(TplLang())] DEM : [=ltrim(ntomf(VenMont2Dev("DEM",DlgValue("zuZahlen")),2))])
[etc endif]
[etc if VEN->IdDev=="EUR".and.PAR->Pays=="B  "]
([=MsgMontant(TplLang())] BEF : [=ltrim(ntomf(VenMont2Dev("BEF",DlgValue("zuZahlen")),0))])
[etc endif]
[etc endif]
[set align l]
[etc if VEN->IdReg=="M"]
[etc if TplLang()=="D"]
[B]DIFFERENZBESTEUERUNG - Mehrwertsteuer NICHT AUSWEISBAR ![b]
[etc else]
[B]LIVRAISON SOUMISE AU REGIME PARTICULIER D'IMPOSITION DE LA MARGE
BENEFICIAIRE - T.V.A. NON DEDUCTIBLE[b]
[etc endif]
[etc endif]
[etc if VEN->IdReg$"IS"]

[etc if TplLang()=="D"]
Innergemeinschaftliche Warenlieferung. \
Ihre MWSt-Id-Nr.: [=if(empty(PAR->NoTva),"(bitte mitteilen!)",trim(PAR->NoTva))]
[etc else]
Livraison intracommunautaire de marchandises. \
Votre Id TVA : [=if(empty(PAR->NoTva),"(� nous communiquer s.v.p.!)",trim(PAR->NoTva))]
[etc endif]
[etc endif]
[etc if VEN->IdReg$"ACMLD"]

[=tr("Your VAT id:","Ihre MWSt-Nr.:","Votre n� T.V.A.:")] [=trim(PAR->NoTva)].
[etc endif]
[etc endif]
[etc if VEN->DC=='D'.and.!empty(VEN->IdMfc)]

[ven memo_ifc]
[etc endif]