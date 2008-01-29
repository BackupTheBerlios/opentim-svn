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


#define NOFRAME  0
#define SGLFRAME 1
#define DBLFRAME 2

#command OPEN WINDOW  [ <cTitle> ]                    ;
                      [ SIZE <nHeight>, <nWidth> ]    ;
                      [ HOME <nRow>, <nCol> ]         ;
                      [ PERMANENT <lPerm> ]          ;
                      [ COLOR <cColor> ]              ;
                      [ FRAME <nBox> ]                ;
                      [ HELP <cHelp> ]                ;
                      [ LEGEND <cLeg> ]               ;
                   => WinOpen( <(cTitle)>,            ;
                               <nRow>, <nCol>,        ;
                               <nHeight>, <nWidth>,   ;
                               <lPerm>,               ;
                               <(cColor)>,            ;
                               <nBox>, <(cHelp)>,     ;
                               <cLeg>                 ;
                             )

#command CLOSE WINDOW   =>   WinClose()
#command DROP WINDOW    =>   WinDrop()

#define WIN_HEIGHT  1
#define WIN_WIDTH   2
#define WIN_TOP     3
#define WIN_LEFT    4
#define WIN_WAITKEY 5
#define WIN_ALEN    5


