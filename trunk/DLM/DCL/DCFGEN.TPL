[=SetPageHeader({||PrintHeader(\
  'Detailed Cash-Flow Statement',\
  tr("Fiscal years ", "Steuerjahre ","Ann‚es fiscales") \
     + trim(DlgValue("range1")) \
     + tr(" and ", " und "," et ") + trim(DlgValue("range2"))
     + if(empty(getvar("range3")),"",\
          tr(" and ", " und "," et ") + trim(DlgValue("range3"))),\
  tr("Amounts in ","Betr„ge in ","Montants en ")+SetDevise()\
)})]
[=DbfScan({oDcf()},1,NIL,NIL,"!empty(DCF->Type)","fparse('DCFGEN1.TPL',NIL,'[]')")]
