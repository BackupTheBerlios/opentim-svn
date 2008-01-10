** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2008 Luc Saffre
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

* File MkStr.prg
* Luc Saffre

#define CR_LF chr(13) + chr(10)

FUNCTION MkStr
local cString
local cStr2
local fd := fcreate("MKSTR.OUT")
local i
if fd == -1
  ? "Could not open file MKSTR.OUT."
  quit
endif
do while .t.
  accept "String to 'encrypt' : " to cString
  if empty(cString)
    exit
  endif
  * fwrite( fd, "Decrypt(" )
  * cStr2 := Encrypt( cString )
  for i := 1 to len(cString)
    fwrite( fd, "chr(" + ltrim(str( asc( substr( cString, i, 1)))) + ")" )
    if i != len( cString )
      fwrite( fd, " + " )
    endif
  next i
  fwrite( fd, " // " + cString + CR_LF )
enddo
fclose(fd)
RETURN NIL

FUNCTION Encrypt( s1 )
local s2 := ""
local i
for i := 1 to len(s1)
  s2 := s2 + chr(255 - i - asc( substr(s1,i,1) ) )
  s2 := s2 + chr(i)
next
RETURN s2

FUNCTION Decrypt( s1 )
local s2 := ""
local i
for i := 1 to len(s1) step 2
  s2 += chr( ;
    - ( asc(substr(s1,i,1)) - 255 + i )  ;
  )
next
RETURN s2


