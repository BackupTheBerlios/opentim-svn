| file created by TIM for Popsy

CreateKeyAll:   Y

DossierSelect: [=DlgValue("PopsyDossier")]
AcctingSelect: [=ltrim(DlgValue("PopsyExercice"))]



DueDate:30
{
  WordingFR: "30 jours date facture"
  ReportType: 0
  Delay:     30
}

DueDate:30M
{
  WordingFR: "30 jours fin de mois"
  Delay:     30
  ReportType: 1
  MonthDay:   1
}

DueDate:E
{
  WordingFR: "dŠs r‚ception facture"
  Delay:     7
  ReportType: 0
}

[etc do DbfScan(\
  {oPer()},1,\
  NIL,NIL,"PER->Ex=='"+DlgValue("PopsyExercice")+"'",\
  "fparse(DbPath()+'\pexper.tpl')"\
)]

[etc do DbfScan(\
  {oGen()},1,\
  NIL,NIL,"'X'$GEN->Attrib",\
  "fparse(DbPath()+'\pexgen.tpl')"\
)]

[etc do DbfScan(\
  {oPar(),oPlz(),oNat()},1,\
  NIL,NIL,NIL,\
  "fparse(DbPath()+'\pexpar.tpl')"\
)]


[etc do DbfScan(\
  {oVen(),oPar()},1,\
  NIL,NIL,"VEN->Etat==DocStatClosed().and.ChkPeriode(VEN->Periode)==0",\
  "fparse(DbPath()+'\pexven.tpl')"\
)]


