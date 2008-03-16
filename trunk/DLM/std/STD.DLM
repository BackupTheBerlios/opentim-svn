// std.dlm
// raus seit 20030108: do ActExec("STARTUP")
CustData NAT TPL
// Siehe 19990209
ClearOnRebuild
OnRebuild {|cText| IndCreate("DBCHECK",cText)}
OnRebuild {|cText| IndCreate("REBUILD",cText)}
OnRebuild {|cText| IndDelete("TIMTEST")}
OnRebuild {|cText| Warning( \
    cText,NIL,"REBUILD",.t.,CfgDataBase() + " : " + \
    tr("System messages","Systemmeldungen","Messages systäme") \
) }
PreLogin !IndExist("DBCHECK").or.ActExec("DBCHECK").or.Confirm(\
  "Das Reorganisieren hat nicht ganz geklappt. "\
  +"Wollen Sie trotzdem in der Datenbank arbeiten ?"\
)

// OnLogin setvar("asMail"," ")
do setvar("mailhost","")
do setvar("mailfrom","")
do setvar("mailto","luc.saffre@gmx.net")
do setvar("mailtpl","MAIL.EML")
do setvar("fontName","")
