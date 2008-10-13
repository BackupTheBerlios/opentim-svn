// sprl.ini

LenIdPar 6  // L„nge PAR->IdPar

// LenTel 18
// ShouldRebuild 0.95
// ParName {|| trim1(PAR->Allo) + PAR->Firme }

OnParSelect (!"G"$PAR->Attrib).or.Confirm(\
  trim(ParName())+" : Partner ist gesperrt !",\
  MsgSure(),"N"\
)

OnMainMenu memodisplay(\
  StrParse(DlmMemoRead("news.txt"),"[]"),\
  1,0,maxrow()-4,maxcol()-2,\
  CfgFullScreenColor()\
)
// ParName {|| trim(PAR->Firme) + trims(PAR->Allo,", ","") }
ParName {|| trim(PAR->Firme) + trims(PAR->Vorname," ","")+ trims(PAR->Allo,", ","") }



// Wenn der Benutzer ein Datum "12.01.02" eingibt, dann versteht TIM
// darunter nicht 1902, sondern 2002, weil alle Daten vor 1920 durch den
// folgenden Eintrag automatisch um 100 Jahre verschoben werden.
// set epoch 2000
// set epoch 1920 (Standardwert ist 1920)

// Grundw„hrung 1 ist BEF, GW 2 ist EUR
DevDefault { "BEF" , "EUR" }

// DevToggle bestimmt, ab wann von GW1 nach GW2 umgeschaltet wird
// DevToggle {|Periode|Periode>="0100"}
PerToggle if(FixY2K(),"A200","0200")

// PerDevFixed bestimmt, ob der Wechselkurs fest ist, oder (wenn nicht)
// im Dokument gespeichert wird. Bei festem Wechselkurs wird immer per
// Dreiecksrechnung ber EUR konvertiert.
PerDevFixed {|cPeriode,cIdDev|cIdDev$"BEF,LUF,DEM,NLG,FRF,ITL,DKK"}
// PerDevFixed {|cPeriode,cIdDev|cPeriode>="0000".and.!cIdDev$"USD"}





// PreLogin SetLenMont(12)
set solde   1        // set solde 1 : 1 Kolonne mit "D" oder "C" dahinter
// set solde   2     // set solde 2 : 2 Kolonnen
// set montant : Breite von formatierten Betrag-Feldern am Bildschirm
set montant S10      // S : Wert 0 wird als Leerstelle gedruckt
                     // Z : Wert 0 wird als "0" gedruckt
LenIdPgp    2
LenIdDoc    6  // length of field IdDoc (VEN, FIN, IMP,...)
LenIdTpl    6  // length of field IdTpl
LenQte      6
LenIdJnl    3

// for tables mentioned behind CustData, TIM will execute a
// corresponding *.def file (e.g. ART.DEF for ART.DBF) when initializing
// the data dictionary
// CustData   VEN HST VNL BIL
CustData PAR


// QteEmpty .f. heiát, dass die Mengenangabe "leer" nicht als 1, sondern
// als 0 interpretiert wird. Default = .t.
// QteEmpty .f.




