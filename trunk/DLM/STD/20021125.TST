// 20021125
// Neue Funktion dos2latin1()
// dos2base64() hatte noch zwei Bugs. Jetzt funktioniert sie.
TstEqual(dos2latin1("ABC"),"ABC")
TstEqual(dos2latin1("”™šá…ƒ‚ˆŠŒ“–—‰‡ñ äå„"),"ÄöÖüÜßàâéêèîôûùëç±áõÕä")
TstEqual(dos2latin1("®"),chr(171))
TstEqual(dos2latin1("¯"),chr(187))


TstEqual(dos2base64("ABC") , "QUJD")
TstEqual(dos2base64("‚")   , "w6k=")
TstEqual(dos2base64("e")   , "ZQ==")
TstEqual(dos2base64("‚e")  , "w6ll")
TstEqual(dos2base64("‚t‚") , "w6l0w6k=")
TstEqual(dos2base64("raret‚") , "cmFyZXTDqQ==")


