@echo off
echo DELDLM.BAT deletes all files which are *usually* no longer needed
echo in the database directory. In fact they must be removed because otherwise they 
echo hide the corresponding file in the DLM\SPRL
pause

del hstven.*
del hstfin.*
del hstgen.*
del hstpar.*
del genhst.*
del parhst.*

del ctr.qry
del ipb.qry
del ifc.qry
del ifc.msk
del tax.qry
del tax.msk
del hstsatis.*
del hst*.qry
del fin*.qry
del fin*.msk
del fnl*.qry
del fnlfill.dlg
del dbcheck.*
del dcltva.*
del lsttva*.*
del dev.qry
del ctt*.qry
del ctg*.qry
del ctp*.qry
del tpl*.qry

del fin.def
del fnl.def
del *.ttl
del *.hcl

rem since 20020119: 9.30
del jnliddoc.dlg
del natcrea.dlg
del nat.qry
del natpick.qry
del nat.def
del nat.msk

rem since 20020119 16.00

del jnl.qry
del jnl.msk
del jnlpick.qry
del reg.qry
del dif.qry

del mnuprint.dbc
del mnuboss.dbc
del news.txt
del timtest.*
del hst.def
del *.exp
del *.imp

ren since 20021230
del fnl*.msk
del fparse.act
del genbil.*
del genstd.dbc
del hstdele.dlg
del hstfilt.dlg
del hstgen01.rep
del hstgen01.dlg
del hstpar01.dlg
del hstpar01.rep
del msg.qry
del msgpar.qry

del mvp*.*
del mvt*.*
del notest.txt
del odl*.qry
del odl*.msk
del ods*.msk
del ods*.qry
del per.qry
del perjnl.qry

del plz*.qry
del prf*.qry
del prf*.msk
del regattr.dbc
del trm*.qry
