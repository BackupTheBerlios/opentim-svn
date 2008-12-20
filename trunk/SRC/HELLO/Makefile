HB=harbour
HBCC=cl
CFLAGS=
CPPFLAGS=
SDKROOT=C:\Program Files\Microsoft Platform SDK for Windows Server 2003 R2
MSVCROOT=C:\Program Files\Microsoft Visual Studio 8\VC
XHBROOT=s:\xharbour
HBFLAGS=/m /n0 /i$(XHBROOT)\include
INCLUDE=$(SDKROOT)\Include;$(SDKROOT)\Include\crt;$(XHBROOT)\include
LIB = $(SDKROOT)\Lib;$(MSVCROOT)\lib;$(XHBROOT)\lib
export LIB

C_USR=-TP
HB_ARCHITECTURE=w32
HB_COMPILER=msvc
HB_GT_LIB=gtwin
#HB_MT=MT multi-threaded ?
HB_MT=
HB_FIRST_LIBS=
HB_LIBLIST=$(HB_FIRST_LIBS) common.lib dllmain.lib debug.lib vm$(HB_MT).lib rtl$(HB_MT).lib pcrepos.lib $(_HB_GT_LIB).lib lang.lib rdd$(HB_MT).lib macro$(HB_MT).lib pp$(HB_MT).lib dbffpt$(HB_MT).lib dbfntx$(HB_MT).lib dbfcdx$(HB_MT).lib hsx$(HB_MT).lib hbsix$(HB_MT).lib ct$(HB_MT).lib tip$(HB_MT).lib $(ADS_LIBS) $(HB_USER_LIBS) $(HB_ALGLIB)


OBJ =HELLO.obj

HELLO.exe : $(OBJ)
#	cl $^ /out:$@
	link.exe $^ /NODEFAULTLIB:libcmt.lib /out:HELLO.exe /subsystem:CONSOLE /FORCE:MULTIPLE $(LDFLAGS) $(HB_LIBLIST) shell32.lib user32.lib winspool.lib ole32.lib oleaut32.lib ws2_32.lib kernel32.lib gdi32.lib comctl32.lib comdlg32.lib 


#/VERBOSE "/OUT:C:\Documents and Settings\Luc\My Documents\Visual Studio 2005\Projects\hello\Debug\hello.exe" /INCREMENTAL:NO /MANIFEST "/MANIFESTFILE:Debug\hello.exe.intermediate.manifest" /DEBUG "/PDB:c:\documents and settings\luc\my documents\visual studio 2005\projects\hello\debug\hello.pdb" /SUBSYSTEM:CONSOLE /MACHINE:X86 kernel32.lib 

clean :
	rm -f *.c *.obj

%.obj : %.c
	cl /W3 /c /I"$(INCLUDE)" $< 
#	$(HBCC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.c : %.PRG
	$(HB) $(HBFLAGS) $<
