// Testing nText()...

ntext("    1.02 ","D",.t.) =="ein Komma Null zwei"
ntext("    1.023","D",.t.) =="ein Komma Null dreiundzwanzig"
ntext("    1.23 ","D",.t.) =="ein Komma dreiundzwanzig"
ntext("  123.23 ","D",.t.) =="einhundertdreiundzwanzig Komma dreiundzwanzig"
ntext("  123    ","D",.t.) =="einhundertdreiundzwanzig"
ntext("12345    ","D",.t.) =="zwîlftausenddreihundertfÅnfundvierzig"
ntext("    0.5  ","D",.t.) =="Null Komma fÅnf"
ntext("    0.48 ","D",.t.) =="Null Komma achtundvierzig"










