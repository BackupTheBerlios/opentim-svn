# *-*-*- Makefile *-*-*

XPPROOT = C:\ALASKA
SDKROOT = C:\Program Files\Microsoft Platform SDK for Windows Server 2003 R2
#BEIDSDK = C:\eID_SDK_2.5\SDK
BEIDSDK = C:\\eID_SDK_3.5\\beidlib\\C++

INCLUDE = $(XPPROOT)\XPPW32\INCLUDE;$(XPPROOT)\DBEW32\INCLUDE;$(SDKROOT)\Include;$(SDKROOT)\Include\crt;$(BEIDSDK)\include

LIB = $(XPPROOT)\XPPW32\LIB;$(XPPROOT)\DBEW32\LIB;$(SDKROOT)\Lib;C:\Program Files\Microsoft Visual Studio 8\VC\lib;$(BEIDSDK)\lib

export INCLUDE
export LIB

sample.exe: sample.obj eidtools.lib eidtools.dll
	alink /DEBUG sample.obj eidtools.lib 

sample.obj: sample.prg
	xpp /b /q /n /m /w /es $?

eidtools.dll: eidtools.cpp eidtools.exp
	cl /LD /Tc $< /link xpprt1.lib eidtools.exp beidlib.lib

eidtools.exp eidtools.lib: eidtools.def 
	aimplib $<

clean:
	rm -f eidtools.lib eidtools.dll eidtools.obj eidtools.exp sample.obj sample.exe
	
    
    
    
