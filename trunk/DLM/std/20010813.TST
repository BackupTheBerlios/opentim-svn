// Siehe 2001-08-13

TstEqual("995622",ntrim0(9956.22*100)) // stimmt erst seit 2001-08-13

TstEqual("    995622",str(9956.22*100,10,0))
// ltrim(str(x,10,0))
// Funktionierte auch vorher schon.

TstEqual("    995621",str(int(9956.22*100),10,0))
// Ursache ist also int(x)
