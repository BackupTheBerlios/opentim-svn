[etc if VEN->IdDev=="EUR"]
[etc if PAR->Pays=="B  "]
(= [=ltrim(ntomf(val(VEN->Mont)*40.3399,0))],- BEF)
[etc endif]
[etc if PAR->Pays=="D  "]
(= [=ltrim(ntomf(val(VEN->Mont)*1.95583,2))] DEM)
[etc endif]
[etc else]
(= [=ltrim(ntomf(\
  Db2Dev(\
    "EUR",\
    VEN->Periode,\
    Dev2Db(VEN->IdDev,VEN->Periode,val(VEN->Mont))\
  ),2\
))] EUR)
[etc endif]
