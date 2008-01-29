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

//
// Values for cargo[AD_REQUEST] :
//
#define DDEDIT_EXIT   0  // Terminate ddEdit()
#define DDEDIT_BROWSE 1  // continue in browse mode
#define DDEDIT_PAGE   2  // continue in full-screen mode
#define DDEDIT_SELECT 0  // no longer used
#define DDEDIT_ESCAPE 4

//
// Values for cargo[AD_MODE] :
//
#define DDMODE_EDIT   0  // data key replaces contents of field
#define DDMODE_SHOW   1  // editing and deleting not allowed
#define DDMODE_PICK   2  // Enter means "Select current record"
#define DDMODE_WAIT   3  // exit upon first keystroke or if stable
#define DDMODE_FIND   4  // like EDIT, but data key starts search
#define DDMODE_SEARCH 5  // indexed background search (activated internally)

//
// Return values for delete block
//
* #define DDDEL_FAIL       0
* #define DDDEL_NODELETE   0
* #define DDDEL_NOCONFIRM  1
* #define DDDEL_CONFIRM    2

//
// Return values for creation block
//
#define DDCREATE_FAIL    0
#define DDCREATE_DONE    1
#define DDCREATE_EDIT    2
#define DDCREATE_FULL    3
#define DDCREATE_REFRESH 4
#define DDCREATE_ERROR   5
* #define DDCREATE_DETAIL  5

#define DETAIL_REFRESH 1


#translate MODE EDIT   =>  MODE 0
#translate MODE SHOW   =>  MODE 1
#translate MODE PICK   =>  MODE 2
#translate MODE WAIT   =>  MODE 3
#translate MODE FIND   =>  MODE 4
// Note : mode 5 ("searching") is only activated internally

#translate START TOP      =>  START 1
#translate START BOTTOM   =>  START 2

#translate DDSTART_STAY     =>  0
#translate DDSTART_TOP      =>  1
#translate DDSTART_BOTTOM   =>  2



#command EDIT DATA    <oBrowse>                ;
                      [ MODE <nMode> ]         ;
                      [ START <nStart> ]       ;
                      [ SOFTSEEK <cStart> ]       ;
                      [ CREATE <bCreate> ]       ;
                      [ WINDOW <aWin> ]       ;
                      [ BROWSEWAIT <bBrowseWait> ]       ;
                      [ PICKORD <bPickOrd> ]       ;
                      [ PREEDIT <bPreEdit> ]       ;
                      [ BEFORE <bBefore> ]       ;
                      [ AFTER <bAfter> ]       ;
                      [ STATUS <bStatus> ]       ;
                      [ HEADERS <lHeaders> ]       ;
                      [ ACTION <aAction1> [ , <aActionN> ]  ]       ;
                      [ <lNoConfirm: NOCONFIRM> ]    ;
                      [ <lFull: FULL> ]    ;
                      [ <lNoSkip: NOSKIP> ]    ;
                      [ <lNew: NEW> ]    ;
                      [ FILTER <xlFilter> ]       ;
                      [ TITLE <cTitle> ]       ;
                      [ HELP <cHelp> ]       ;
                      [ KEY <xcKey> VALUE <cKeyValue> ]       ;
                      [ LEGEND <cLegend> ]       ;
                      [ QUERY  <cIdDbv> ]       ;
                      [ COLOR  <cColor> ]       ;
                      [ ONIDLE <bOnIdle> ]       ;
                      [ RECNOS <aRecnos> ]       ;
                   => ddEdit( <oBrowse>,    ;
                              <.lNoConfirm.>,  ;
                              <nMode>,      ;
                              <nStart>,     ;
                              <bCreate>,  ;
                              <{bPreEdit}>,  ;
                              { <aAction1> [,<aActionN>] },  ;
                              <xlFilter>, ;
                              <cKeyValue>, <cLegend>, <cIdDbv>, ;
                              <(xcKey)>, <bPickOrd>,    ;
                              <{bStatus}>, <.lFull.>, <(bOnIdle)>, ;
                              <(cTitle)>, <(cHelp)>, <(cColor)>, ;
                              <lHeaders>, <aWin>, <{bBrowseWait}>, ;
                              <{bBefore}>, <{bAfter}>, ;
                              <cStart>, <.lNew.>, <aRecnos>   ;
                             )

**
** some pseudo-functions :
**
* #xtranslate ddRecStat( <b> ) => <b>:cargo\[AD_RECSTAT\]
* #xtranslate ddRequest( <b> ) => <b>:cargo\[AD_REQUEST\]
* #xtranslate ddQuery( <b> ) => <b>\[AD_CURQRY\]

**
** action arrays :
**
#define AA_KEY   1
#define AA_TEXT  2
#define AA_BLOCK 3

#define RS_VALID   1   // trigger wurde noch nicht ausgefÅhrt
#define RS_INVALID 2   // postedit returned .f.
#define RS_UNKNOWN 3   // record did change, postedit not done
#define RS_NEW     4   // postedit nach dem nÑchsten READ durchfÅhren
                       // (auch wenn nicht updated())

