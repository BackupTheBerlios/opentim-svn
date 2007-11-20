Sales:
{
	Header:
	{
                JrnlID:                 "[=VEN->IdJnl]"
		DocType:         	1
                DocNumber:              "[=ntrim(val(substr(VEN->IdDoc,3)))]"
                CustID:                 "[=trim(VEN->IdPar)]"
                Comment:                "Bon [=trim(VEN->RefExt)]"
                PeriodID:               "[=DbfPeek(\
                  oPer(),\
                  VEN->Periode,\
                  "ltrim(PER->Id)",\
                  VEN->Periode+" : p‚riode non d‚finie"\
                )]"
                DateDoc:                [=dtoc(VEN->Date)]
                DateDue:                [=dtoc(VEN->DatEch)]
                Piece:                  ""
                CrcyDoc:                "[=trim(VEN->IdDev)]"
                AmountCrcyDoc:          [=ltrim(ntom(val(VEN->Mont),2))]
                AmountCrcyBase:         [=ltrim(ntom(val(VenMontDb()),2))]
	}
[etc do DbfScan(\
  {oVnl(),oArt(),oGen()},1,\
  VEN->IdJnl+VEN->IdDoc,\
  "VNL->IdDoc==VEN->IdDoc.and.VNL->IdJnl==VEN->IdJnl",\
  NIL,\
  "fparse(DbPath()+'\pexvnl.tpl')"\
)]
}

