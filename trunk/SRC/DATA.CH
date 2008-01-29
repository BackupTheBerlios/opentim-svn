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

**
** File Data.ch
** Luc Saffre
**

// Structure of a database descriptor array :

#define AD_FIELDS    1  // record descriptor array
#define AD_NAME      2  // Name of DBF, without extension

#define AD_AINDEX    3  // Array of n index expressions (strings).
                        // Each expression indicates an index file for
                        // this DBF. The index files will have the
                        // same name as the DBF, followed by a numeric
                        // from 1 to n.
    #define AI_EXPR       1
    #define AI_TEXT       2
    #define AI_FOR        3
    #define AI_KEYFORMAT  4
    #define AI_ALEN       4

#define AD_PREEDIT   4  // Pre-edit block
                        // Returns .T. if editing of current record is allowed
#define AD_POSTEDIT  5  // Post-edit block
                        // Returns .T. if current record contains valid data
                        // Evaluated each time that editing has occured
                        // Can modify data of record; can ask user
#define AD_CREATE    6  // Append block
                        // Performs APPEND BLANK & sets specific values
                        // If NIL : ddEdit performs a simple append blank
#define AD_FIRST     7  // .t. if this table must be indexed before all
                        // others

#define AD_QRYWAIT   8
#define AD_FILTER    9  // Filter Text
#define AD_WAITBLOCK 10
#define AD_PREDELETE 11 // Delete block
#define AD_PREEXIT   12

#define AD_UPDATED       13  // updated or not during last EDIT DATA

#define AD_FILEPRINT     14  //
#define AD_EDITPRINT     15  //
#define AD_PRECREATE     16
* #define AD_KEYBLOCK      16  //
* #define AD_KEYVALUE      17  // search key prefix
#define AD_ATTRIB        18  // Database attributes
                             // U : file is located in User directory
                             // K : do not Keep open if unused
#define AD_ONCREATE      19  //
#define AD_ACTIONS       20  // actions for Action menu

        #define AS_ROW    1
        #define AS_COL    2
        #define AS_TEXT   3
        #define AS_ALEN   3

#define AD_CONVERT       23  // convert-block
#define AD_PICKFLT       24  //
#define AD_ONDELETE      25  //
#define AD_IDMNU         26  //
#define AD_ONPOSTEDIT    27  //
#define AD_EDITDETAIL    28  //
#define AD_ONQRYWAIT     29  //
#define AD_POSTDELETE    30  //
#define AD_SUMSCAN       31  //
#define AD_RDONLY        32  //
// #define AD_PATH          32  // complete path
// AD_PATH no longer used since 20010719
// again used since 20020117
#define AD_ONTEST        33  //
#define AD_ALEN          33  // Length of array

* #define AD_CURMSK        21  // Currently loaded .MSK
* #define AD_CURQRY        22  // Currently loaded .QRY
* #define AD_BEFORE        23  //
* #define AD_AFTER         24  //
* #define AD_KEYFORMAT     26  // Formatier-Block fÅr Positioniermodus

