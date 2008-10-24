[=p_SetWidth(70)]
[set dateformat dd.mm.yy]
[=fparse("ADRPAR.TPL")]

Datum : [=dtocf(UserDate())]

[etc if getvar("IstLetzte")=="X"]
LETZTE MAHNUNG
[etc endif]

[etc if empty(getvar("Intro"))]

Sehr geehrter Kunde !

Wir erlauben uns, Sie auf folgende noch ausstehende Rechnungen aufmerksam
zu machen :
[etc else]

[=toTxtStream(getvar("Intro"))]
[etc endif]

[=fparse("MAHNBODY.INC")]

[etc if ! empty(getvar("Termin"))]
[etc if getvar("IstLetzte")=="X"]
éu·erster Zahlungsstermin ist der [=dtocf(getvar("Termin"))].
Sollte bis dahin ... blabla.. Anwalt...
[etc else]
Wir bitten Sie, Ihr Konto bis spÑtestens zum [=dtocf(getvar("Termin"))]
zu begleichen.
[etc endif]

Sollten Sie in der Zwischenzeit die nîtigen Zahlungen schon in Auftrag
gegeben haben, so bitten wir Sie, diesen Kontoauszug als gegenstandslos 
zu betrachten.

[etc endif]



Mit freundlichen GrÅ·en


[=UsrName()]
[=Fonction()]
