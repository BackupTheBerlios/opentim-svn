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

#define PRN_IDLE      0
#define PRN_CONTINUE  1
#define PRN_ABORT     2  // print job was aborted (off-line or escape)
#define PRN_DONE      3
#define PRN_EXIT      4  // fÅr {etc exit}
* #define PRN_OFFLINE   4

 

#command OPEN PRINTER [<cIdTpl>] ;
                      [ WIDTH <nWidth> ] ;
                      [ RANGE <cRange> ] ;
                      [ PREVIEW <cPreview> ] ;
                      [ PREPRINT <bPrePrint> ] ;
                      [ TITBLOCK <bHeader> ] ;
         => ;
         OpenPrinter( ;
           <cIdTpl>, ;
           <cPreview>, ;
           <nWidth>, ;
           <bHeader>, ;
           <cRange>, ;
           <bPrePrint> ;
         )
#command CLOSE PRINTER => ClosePrinter()

