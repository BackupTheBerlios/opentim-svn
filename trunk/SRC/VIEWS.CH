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

#define QRY_IDQRY    1
#define QRY_COLUMNS  2
  #define COL_FLDHANDLE 1
  #define COL_HEADER    2
  #define COL_ATTRIB    3
  #define COL_PICTURE   4
  #define COL_BUFFER    5
  #define COL_EXPR      6
  #define COL_SUM       7
  #define COL_SAYBLOCK  8
  #define COL_BLOCK     9
  #define COL_ONEDIT    10
  #define COL_SKIPBLOCK 11
  #define COL_CLRBLOCK  12
  #define COL_IFEXPR    13
  #define COL_ALEN      13
#define QRY_ORDER    3 // index order to activate
#define QRY_WINDOW   4
#define QRY_IDMSK    5
#define QRY_HELP     6 // index order to activate
#define QRY_WAITWINLIST  7
#define QRY_WAITKEY  8
#define QRY_COLSEP   9
#define QRY_ATTRIB  10
#define QRY_FILTER  11
#define QRY_CELLHEIGHT 12
#define QRY_KEY        13
#define QRY_KEYVALUE   14
#define QRY_TITLE      15
#define QRY_FREEZE     16
#define QRY_LEGEND     17
#define QRY_BOTTOM     18
#define QRY_CLRSPEC    19
#define QRY_ONADDCOLUMNS 20
#define QRY_RIGHT        21
#define QRY_ALEN         21

#define MSK_GETS     1 // FldHandles & line,col for GET objects
  #define MSKGET_FLDHANDLE 1
  #define MSKGET_ROW       2
  #define MSKGET_COL       3
  #define MSKGET_PICTURE   4
  #define MSKGET_ATTRIB    5
  #define MSKGET_BLOCK     6
  #define MSKGET_ALEN      6
#define MSK_STRINGS  2
#define MSK_BOXES    3
    #define AB_TOP    1
    #define AB_LEFT   2
    #define AB_BOTTOM 3
    #define AB_RIGHT  4
    #define AB_ALEN   4

*#define MSK_VFIELDS  4
*  #define VFLD_ROW   1
*  #define VFLD_COL   2
*  #define VFLD_MAC   3
*  #define VFLD_COLOR 4
*  #define VFLD_ALEN  4

#define MSK_WAITWINLIST  5
#define MSK_WAITKEY  6
#define MSK_IDMSK    7
#define MSK_VOFFSET  8
#define MSK_VSIZE    9
#define MSK_IMAGES   10 // {nTop, nLeft, nWidth, nHeight, xcFilename}
#define MSK_ALEN     10

#define COLATTR_S "S" // no settle after typeout
#define COLATTR_R "R" // read-only
#define COLATTR_P "P" // paste
#define COLATTR_C "C" // confidential
#define COLATTR_Q "Q" // quick-pick

#define QRYATTR_W "W"
#define QRYATTR_S "S"
#define QRYATTR_D "D"

