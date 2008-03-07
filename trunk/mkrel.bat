rem @echo off
set TARGET=u:\htdocs\timwebs\tim\dl\dist\dlm.zip
if exist %TARGET% del %TARGET%
zip -r %TARGET% DLM -x "*/.svn/*"
