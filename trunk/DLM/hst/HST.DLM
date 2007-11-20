// HST.INI
CustData HST GEN CTT

LenIdGen 6 // L„nge Generalkontennummern

LenIdGenHeader 3 // bis zu welcher Titelebene Sammelhistorik gemacht wird

// Ob bei Warnung "Generalkonto nicht manuell benutzen" trotzdem
// registriert werden darf :
// OnGenCtrExist {|cIdGen,cPeriode,cIdJnl|!SetMsg(cIdGen+MsgDontUse())}

// auch dann lettrieren, wenn E und V gemischt sind :
// OnHstCtrMix .t.

// nicht lettrieren, wenn E und V gemischt sind :
// OnHstCtrMix .f.

// nicht lettrieren und Hinweis an Benutzer wenn E und V gemischt sind :
OnHstCtrMix !SetMsg(trim(ParName())\
  +" : unerlaubte Lettrierung Einkauf/Verkauf")


#if HasDgr()
// xnRplDebit wird in RAP.QRY benutzt
OnMainMenu DlgDefine("xnRplDebit","DbfSum(\
  {oHst()},  \
  'if(HST->DC=='+chr(34)+'D'+chr(34)+',val(HST->Mont),-val(HST->Mont))',\
  2, \
  RPL->IdPar+RPL->Match\
)")
#endif


PrePerAppend {|cPeriode|Confirm(\
  cPeriode + MsgPerExist(), \
  "Neue Buchungsperiode erstellen (J/N) ?"\
)}


OnLogin SetPeriode(PerActive())


