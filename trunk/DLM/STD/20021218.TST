// 20021218
// Neue Funktion utor()
TstEqual(utor("abc"),'"abc"')
TstEqual(xparse(utor("abc")),"abc")
TstEqual(xparse(utor('"abc"')),'"abc"')
TstEqual(xparse(utor('12" paper"')),'12" paper"')

