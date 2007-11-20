** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2007 Luc Saffre
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

#define DEF_CLIP52
* #define DEF_CLIP53
* #define DEF_STRFILES

#define TRUE            (.t.)
#define FALSE           (.f.)

#define PIC_ID "@K@!"

#define APPEXIT_NORMAL 0
#define APPEXIT_INIT   1
#define APPEXIT_LOGIN  2
#define APPEXIT_RTE    3


#command OPEN AREA <a1> [, <aN> ] [  <lExcl:EXCLUSIVE> ] => ;
  begin sequence ; if ! AreaOpen( { <a1> [ , <aN> ] }, <.lExcl.> ) ; break ; endif
#command CLOSE AREA => AreaClose() ; end sequence
#command BREAK AREA => AreaClose() ; break

* #define NTX_EXT ".NTX"
#define DEF_DBFNTX
* #define DEF_DBFCDX


#command DEFAULT <p> TO <v> => if <p> == NIL ; <p> := <v> ; endif

#command   SEEK     <cWhat> [ IN <a> ]  => [<a> ->] ( dbSeek(<cWhat>) )
#command   SOFTSEEK <cWhat> [ IN <a> ]  => [<a> ->] ( dbSeek(<cWhat>,.t.) )
#ifdef __XPP__
#translate EOF() IN <a>   => (<a>->(eof().or.bof()))
#else
#translate EOF() IN <a>   => (<a>->(eof()))
#endif
#translate SKIP [<n>] IN <a>   => (<a>->(dbskip(<n>)))
#translate SET ORDER TO [<n>] IN <a>   => (<a>->(dbsetorder(<n>)))
#translate c2min(<cDur>)  => ;
  ( val(left(<cDur>,2)) * 60 + val(right(<cDur>,2)) )


#xtranslate Alarm() => if SET(_SET_BELL) ; tone(523,3) ; endif
* #xtranslate Alarm() => if SET(_SET_BELL) ; tone(800,18) ; endif

#define CR_LF       chr(13)+chr(10)
#define CHR_255     "ˇ"  // chr(255)
#define CHR_TAB     chr(9)
#define CHR_141     "ç"


#define CSR_POS     row(),col()

#ifdef DEF_CLIP53
  #define BUTTON_OFF  .f.
  #define BUTTON_ON   .t.
#else
  #define BUTTON_OFF  " "
  #define BUTTON_ON   "X"
#endif

#define LEN_MEMO   10
#define LEN_LANGUE  1

memvar nKey
memvar GetList

#include "precust.ch"
#include "cust.ch"
#include "postcust.ch"

* #include "today.ch"
#include "appinit.ch"
#include "Inkey.ch"
#include "types.ch"
#ifdef __XPP__
  #include "gra.ch"
  #include "os.ch"
#endif __XPP__

#ifdef DEF_CLIP53
  #include "lsget.ch"
#else
  *#ifdef __XPP__
  *  #include "getsysxb.ch"
  *#else
  *  #include "getsysph.ch"
  *#endif
  #include "getsysph.ch"
  #include "ddGet.ch"
  #include "Inkey2.ch"
#endif
#include "data.ch"
#include "views.ch"
#include "montant.ch"
#include "ddEdit.ch"
#include "Windows.ch"
#include "setcurs.ch"
#include "Box.ch"
#include "Report.ch"
#include "FileIO.ch"
#include "printer.ch"
#include "abrowse.ch"
#include "login.ch"
#include "smenu.ch"
#include "sayget.ch"
// #include "music.ch"
#include "directry.ch"
* #include "dbfsix.ch"

#define K_MOUSE_EVENT   (332)               // numpad 5


* #ifdef DEF_DEBUG
*   #xtranslate debugmsg <msg> => qout(<msg>)
* #else
*   #xtranslate debugmsg <msg> =>
* #endif

#xtranslate brutto(<n>,<s>) => ( <n> + (<n> * <s>) / 100 )

* #define KEY_INSERT      K_CTRL_INS

* #define KEY_MODIFY      K_F3
* #define KEY_FULLSCREEN  K_CTRL_RET
* #define KEYTEXT_MODIFY     "        [F3]"
* #ifdef LG_FRENCH
*   #define KEYTEXT_FULLSCREEN "[Ctrl-Enter]"
* #else
*   #define KEYTEXT_FULLSCREEN "[Strg-Enter]"
* #endif

* ** fÅr Leo Mattar :
* #define KEY_MODIFY      K_CTRL_RET
* #define KEY_FULLSCREEN  K_F3
* #define KEYTEXT_MODIFY     "[Ctrl-Enter]"
* #define KEYTEXT_FULLSCREEN "        [F3]"

* #ifndef DEF_VIDSTR
*   #xtranslate ft_vidstr(<r>,<c>,<t>,<color>) ;
*   => ;
*   @ <r>,<c> SAY <t> COLOR <color>
*   *
*   #xtranslate ft_vidstr(<r>,<c>,<t>) ;
*   => ;
*   @ <r>,<c> SAY <t>
* #endif


#xtranslate RETURN <uReturn> IF <lIf> ;
  => ;
if (<lIf>) ; RETURN (<uReturn>) ; endif


* #define LEN_IDTPL 6

#define TPLTYPE_INI "INI"
* #define TPLTYPE_SET "SET"   // set
#define TPLTYPE_HDR "HDR"   // header & footer
#define TPLTYPE_INC "INC"   // include blocks
#define TPLTYPE_BLK "BLK"

#define ALIGN_LEFT   "L"
#define ALIGN_RIGHT  "R"
#define ALIGN_CENTER "C"
#define ALIGN_TOP    "T"
#define ALIGN_BOTTOM "B"


* #xtranslate TplStream(<cMemo>) => TplParse( <cMemo>, {|x| PrnStream(x) } )

* #xcommand UNLOCK RECORD => dbrunlock(recno())
* #xcommand UNLOCK RECORD => dbunlock()
#xcommand UNLOCK RECORD => a_runlock()

#define MSG_NO "N"

#ifdef LG_GERMAN
  #define MSG_YES "J"
#endif
#ifdef LG_FRENCH
  #define MSG_YES "O"
#endif
#ifdef LG_EN
  #define MSG_YES "Y"
#endif

#define INI_KEYWORD 1
#define INI_BLOCK   2
#define INI_ALEN    2


** Werden in txtedit.prg und phread.prg benutzt :
#define TXT_EDIT     0
#define TXT_EXIT     1
#define TXT_EXPORT   2
#define TXT_IMPORT   3
#define TXT_EXTEDIT  4
#define TXT_TOGGLE   5
#define TXT_COMMIT   6
#define TXT_ALT_INS  7
#define TXT_CTRL_INS 8
#define TXT_UP       9
#define TXT_DOWN    10
#define TXT_ESCAPE  11
#define TXT_PASTE   12

#ifdef DEF_DEBUG
  #xtranslate LogDebug(<x>) => LogConsole(<x>)
#else
  #xtranslate LogDebug(<x>) => // NIL
#endif

#ifdef DEF_VERBOSE
  #xtranslate MsgVerbose(<x>) => MsgDisplay(<x>)
#else
  #xtranslate MsgVerbose(<x>) => // NIL
#endif

*#ifdef DEF_CONSOLE
*  #xtranslate LogSystem(<x>)  => LogMessage(<x>,"System")
*  #xtranslate LogConfig(<x>)  => LogMessage(<x>,"Config")
*  #xtranslate LogConsole(<x>) => LogMessage(<x>,"Console")
*#else
*  #xtranslate LogSystem(<x>) => // NIL
*  #xtranslate LogConsole(<x>) => // NIL
*  #xtranslate LogConfig(<x>)  => // NIL
*#endif


// #define DEF_ALLKEY

#ifdef __XPP__
  #xtranslate eupper(<s> [,<nRoot>]) => upper(<s>)
#else
  #xtranslate upper(<s>,<nRoot>) => upper(<s>)
  // Sonst kommt "Error C2010  Incorrect number of arguments: 'UPPER'"
  #xtranslate dbdescend() => .f.
  #xtranslate dbsetdescend(<lDescend>) => NIL
#endif __XPP__

#define DEF_DBF

#ifdef DEF_GUI
#include "Xbp.ch"
#endif DEF_GUI
