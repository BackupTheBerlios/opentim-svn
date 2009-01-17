// VCS
VcsValidate("108/1388/88296")
VcsValidate("944/1133/69015")
VcsValidate("612/0821/82994")
VcsValidate("012/8085/67585")
VcsValidate("012808567585")

VcsJournals("VKR FFOI FFO1 FFO")
TstEqual( hst2vcs("VKR","010001","001"), "001/0001/00110" )
TstEqual( hst2vcs("FFO","010001","001"), "301/0001/00115" )
TstEqual( hst2vcs("FFO","A10001","001"), NIL )
TstEqual( vcs2hst("001/0001/00110"), "VKR010001001" )
TstEqual( vcs2hst("301/0001/00115"), "FFO010001001" )

