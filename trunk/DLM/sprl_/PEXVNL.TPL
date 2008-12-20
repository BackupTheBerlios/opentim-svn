[etc do VnlFirstCheck("V").or.Warning(MsgIdJnlDoc()+":"+VNL->Line+" : "+SetMsg())]
Line:
{
        GnrlID:            "[=GEN->IdGen]"
        AnalID:                 ""
        VATCode:                "[=trim(VNL->IdTax)]"
        Comment:                "[=trim(VNL->Desig)]"
        FlagDC:                 [=VEN->DC]
        CrcyID:                 "[=trim(VEN->IdDev)]"
        AmountCrcy:             [=ltrim(ntom(VenDev2Db(val(VNL->cMont)),2))]
   AmountCrcyDoc:          [=ltrim(ntom(val(VNL->cMont),2))]
   AmountCrcyBase:         [=ltrim(ntom(VenDev2Db(val(VNL->cMont)),2))]
       AmountVATCrcyDoc:       [=ltrim(ntom(val(VNL->MontT),2))]
}

