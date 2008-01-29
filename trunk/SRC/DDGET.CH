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

#define FLDATTR_V "V"

**
** Structure of a GET cargo :
**
#define AG_HEADER    1
#define AG_PICKBLK   2
#define AG_ATTRIB    3
#define AG_TYPE      4

  #define GTYPE_DATE    "D"
  #define GTYPE_MEMO    "M"
  #define GTYPE_CHAR    "C"
  #define GTYPE_NUMERIC "N"
  #define GTYPE_LOGICAL "L"
  // TIM specific types :
  #define GTYPE_AMOUNT  "T"
  #define GTYPE_QTY     "Q"
  #define GTYPE_PWD     "X"


#define AG_LEN       5
#define AG_WIDTH     5  // ! doppelte Belegung ! fr Memo-Gets
#define AG_DEC       6
#define AG_HEIGHT    6  // ! doppelte Belegung ! fr Memo-Gets
#define AG_POSTEDIT  7  // post edit formatter
#define AG_AFTER     8
#define AG_DOGET     9
#define AG_NAME     10
#define AG_BLOCK    11
#define AG_PICTURE  12
#define AG_WHEN     13
#define AG_VALID    14
#define AG_ALEN     14

#define FLDATTR_C "C" // this field is confidential data
#define FLDATTR_H "H" // removed (hidden) field
#define FLDATTR_S "S" // skip this field in edit mode


#xtranslate GET_PAD => picture PIC_ID postedit {|x| GetPad(x,"0") }

// GET..RANGE (preprocessed to @..GET..VALID)

#xtranslate  GET <var> [<clauses,...>] RANGE <lo>, <hi> [<moreClauses,...>] => GET <var> ;
         [<clauses>]                                     ;
         VALID {|_1| RangeCheck(_1,, <lo>, <hi>)}        ;
         [<moreClauses>]


**
** GET ... CHECKBOX
**
#xtranslate GET <var>                                   ;
         [<clauses,...>]                                ;
         CHECKBOX                                       ;
         [<moreClauses,...>]                          => GET <var>                                           ;
        [<clauses>]                                     ;
        [<moreClauses>]                                 ;
    ; atail(GetList):reader := {|get|CbxReader(get)}


**
** GET ... PICK
**
#xtranslate GET <var>                                      ;
                        [<clauses,...>]                                ;
                        PICK <bPick>                                   ;
                        [<moreClauses,...>] => GET <var>                                           ;
                   [<clauses>]                                         ;
                   [<moreClauses>]                                     ;
            ; atail(GetList):cargo\[AG_PICKBLK\] := <{bPick}>

**
** GET .. ATTRIB <cAttrib>
**
#xtranslate GET <var>                                      ;
            [<clauses,...>]                                ;
            ATTRIB <cAttrib>                               ;
            [<moreClauses,...>] => GET <var>                                           ;
                   [<clauses>]                                         ;
                   [<moreClauses>]                                     ;
            ; atail(GetList):cargo\[AG_ATTRIB\] := #<cAttrib>

**
** GET .. POSTEDIT <bPostEdit>
**
#xtranslate GET <var>                                      ;
                        [<clauses,...>]                                ;
                        POSTEDIT <bPost>                               ;
                        [<moreClauses,...>] => GET <var>                                           ;
                   [<clauses>]                                         ;
                   [<moreClauses>]                                     ;
            ; atail(GetList):cargo\[AG_POSTEDIT\] := <bPost>

**
** @..GET .. TRIGGER <aFields>
**
*#xtranslate  GET <var>                                      ;
*             [<clauses,...>]                                ;
*             TRIGGER <aTrig>                                ;
*             [<moreClauses,...>]                            ;
*                                                            ;
* => GET <var>                                           ;
*    [<clauses>]                                         ;
*    [<moreClauses>]                                     ;
*  ; atail(GetList):cargo\[AG_TRIGGER\] := <aTrig>



***
*  @..GET
*

* #ifdef CLIP52

#ifdef __XPP__

// Have the pre-processor make "GetNew()"
// utilize the custom Get class.
// WORK-AROUND FOR PDR 5685
#translate GetNew => PdrGet():New
// Note: class PdrGet is defined in ddget.prg


// copied from c:\alaska\cppw32\include\get.ch

#command  @ <nRow>, <nCol> GET <Var> ;
                      [PICTURE <cPict>] ;
                        [VALID <lValid>] ;
                         [WHEN <lWhen>] ;
                         [SEND <message>] ;
      =>  aadd( getList, ;
            ( GetNew( <nRow>, <nCol>, __gBlock(<Var>), __gName(<Var>), ;
                        <cPict>, NIL, <{lValid}>, <{lWhen}>) ):display()) ;
       [; Atail( getList ):<message>] ;
       ; atail(GetList):cargo := array(AG_ALEN)


#command  GET <Var> ;
           [PICTURE <cPict>] ;
           [VALID <lValid>] ;
           [WHEN <lWhen>] ;
           [SEND <message>] ;
      =>  aadd( getList, ;
            ( GetNew( row(), col(), __gBlock(<Var>), __gName(<Var>), ;
                        <cPict>, NIL, <{lValid}>, <{lWhen}>) ):display()) ;
       [; Atail( getList ):<message>] ;
       ; atail(GetList):cargo := array(AG_ALEN)

#else

#command @ <row>, <col> GET <var>                                       ;
                        [PICTURE <pic>]                                 ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                        [SEND <msg>]   => SetPos( <row>, <col> )                                         ;
       ; AAdd(                                                               ;
               GetList,                                                      ;
               _GET_( <var>, <"var">, <pic>, <{valid}>, <{when}> ):display() ;
             )                                                               ;
      [; atail(GetList):<msg>]                                               ;
       ; atail(GetList):cargo := array(AG_ALEN)

#command GET <var>                                       ;
                        [PICTURE <pic>]                                 ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                        [SEND <msg>]                   =>                                 ;
         AAdd(                                                               ;
               GetList,                                                      ;
               _GET_( <var>, <"var">, <pic>, <{valid}>, <{when}> ):display() ;
             )                                                               ;
      [; atail(GetList):<msg>]                                               ;
       ; atail(GetList):cargo := array(AG_ALEN)

#endif __XPP__
*
*#command @ <row>, <col> GET <var>                                       ;
*                        [PICTURE <pic>]                                 ;
*                        [VALID <valid>]                                 ;
*                        [WHEN <when>]                                   ;
*                        [SEND <msg>]                                    ;
*                                                                        ;
*      => SetPos( <row>, <col> )                                         ;
*       ; AAdd(                                                          ;
*               GetList,                                                 ;
*               _GET_( <var>, <(var)>, <pic>, <{valid}>, <{when}> )      ;
*             )                                                          ;
*      [; atail(GetList):<msg>]                                          ;
*       ; atail(GetList):cargo := array(AG_ALEN)
*
*#endif

