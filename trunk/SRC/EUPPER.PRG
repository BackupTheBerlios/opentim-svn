** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2009 Luc Saffre
**
** This file is part of TIM.
**
** TIM is free software: you can redistribute it and/or modify it
** under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 3 of the License, or
** (at your option) any later version.
**
** TIM is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
** License for more details.
**
** You should have received a copy of the GNU General Public License
** along with TIM. If not, see <http://www.gnu.org/licenses/>.

#ifdef __XPP__

* eupper() is provided for backwards compatibility
* There may be calls to eupper() in *.dlg, *.act, *.def

* This file is without #include tim.ch because the expression eupper() would
* get preprocessed to upper().


FUNCTION eupper(c,nLenRoot)
RETURN upper(c)

#else

#include "TIM.CH"

FUNCTION eupper(c,nLenRoot)
local nLen := len(c)
local c2
default nLenRoot to 0
c2 := upper(substr(c,nLenRoot+1))
c2 := strtran(c2,"Å","U")
c2 := strtran(c2,"ö","U")
c2 := strtran(c2,"Ñ","A")
c2 := strtran(c2,"é","A")
c2 := strtran(c2,"ô","O")
c2 := strtran(c2,"î","O")
c2 := strtran(c2,"Ç","E")
c2 := strtran(c2,"ä","E")
c2 := strtran(c2,"à","E")
c2 := strtran(c2,"Ö","A")
c2 := strtran(c2,"†","A") // 19990713
c2 := strtran(c2,"·","S")
c2 := strtran(c2,"‰","O") // 20020325
c2 := strtran(c2,"Â","O")
#ifndef DEF_EUPPER_ALPHA
  c2 := strtran(c2," ")
  c2 := strtran(c2,"-")
  c2 := strtran(c2,".")
#endif DEF_EUPPER_ALPHA
c2 := strtran(c2,"'")
c2 := strtran(c2,'"')
c2 := strtran(c2,'/')
c2 := strtran(c2,'~')
RETURN padr(left(c,nLenRoot) + c2,nLen)

#endif __XPP__


FUNCTION xupper(x)
local i
static a := NIL
if a == NIL
    a := ReadArray("xupper.dbc",2)
endif
for i := 1 to len(a)
    x := strtran(x,a[i][1],a[i][2])
next i
RETURN upper(x)
