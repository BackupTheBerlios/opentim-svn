@echo off
rem Copyright (c) 2007 Luc Saffre
rem
rem This file is part of TIM.
rem
rem TIM is free software: you can redistribute it and/or modify it
rem under the terms of the GNU General Public License as published by
rem the Free Software Foundation; either version 3 of the License, or
rem (at your option) any later version.
rem
rem TIM is distributed in the hope that it will be useful, but WITHOUT
rem ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
rem or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
rem License for more details.
rem
rem You should have received a copy of the GNU General Public License
rem along with TIM. If not, see <http://www.gnu.org/licenses/>.

SET TIMHOME=t:\svnwork\tim\trunk

if not exist %TIMHOME%\SRC\CUST\%1.CH goto error1
set CUST=%1

SET OUTPUT=S:\OBJ\%CUST%
if not exist %OUTPUT%\tim4.ind goto error3

set use_xbase=n
if exist %OUTPUT%\xbase.ind set use_xbase=y

rem SET ADSVER=6.2
SET ADSVER=7.0


if x%use_xbase% == xy goto i_xbase
goto i_clipper

:i_clipper

SET INCLUDE=%TIMHOME%\SRC
SET INCLUDE=%INCLUDE%;s:\CLIP52E\INCLUDE
SET LIB=s:\CLIP52E\LIB;%TIMHOME%\SRC
SET OBJ=S:\OBJ\%CUST%;s:\CLIP52E\OBJ;s:\ads\%ADSVER%\clip52
SET LIB=%LIB%;s:\ADS\%ADSVER%\CLIP52;S:\ADS\%ADSVER%\COMM;s:\ads\%ADSVER%\adsdosip
goto i_ende

:i_xbase

SET LIB=%XPPHOME%\LIB
rem SET INCLUDE=%XPPHOME%\INCLUDE
SET XPPRESOURCE=%XPPHOME%\RESOURCE
SET INCLUDE=%TIMHOME%\src;%XPPHOME%\INCLUDE
goto i_ende

:i_ende

echo set CUST is : %CUST%
echo set OBJ  is : %OBJ%
echo set INCLUDE  is : %INCLUDE%
echo set LIB : %LIB%


t:
cd %TIMHOME%\SRC
if not exist cust.ch goto error2
del cust.ch
echo #include "%TIMHOME%\SRC\CUST\%CUST%.CH" > CUST.CH
if x%use_xbase% == xy goto alaska
if exist %TIMHOME%\src\tim4.rmk goto clipper
if exist %TIMHOME%\src\project.xpj goto alaska
echo %1 : Unknown project. Ignored.
goto ende
rem ***************

:clipper
rmake tim4.rmk /d%DEFINE% /dCUST=%CUST% /wx40000
goto ende

:alaska
pbuild /d%DEFINE% /dCUST=%CUST%
goto ende

:error1
echo %1 : No such custization!
goto ende

:error2
echo cust.ch not found in TIMHOME\SRC !
goto ende

:error3
echo tim4.ind not found for %CUST% !
goto ende

:ende
cd %TIMHOME%

