// 20031017 : PrevNum() vertr„gt jetzt, wenn die Zahl einen
// nicht-numerischen Pr„fix enth„lt
TstEqual(PrevNum("0001"),"0000")
TstEqual(PrevNum("9999"),"9998")
TstEqual(PrevNum("AA01"),"AA00")
TstEqual(PrevNum("AA02"),"AA01")
TstEqual(PrevNum("A20000"),"A19999")
TstEqual(PrevNum("A20001"),"A20000")
TstEqual(PrevNum("020001"),"020000")
TstEqual(PrevNum("020000"),"019999")
TstEqual(PrevNum("ABC020000"),"ABC019999")
TstEqual(PrevNum("ABC000001"),"ABC000000")
TstEqual(PrevNum("060000"),"059999")

