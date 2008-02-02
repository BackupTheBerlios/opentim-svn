** Copyright (c) 2002-2008 Luc Saffre
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

#ifndef __XPP__
#ifndef __XHARBOUR__

  #define DEF_ALT      // ft_alt() benutzen ?
  #define DEF_NANFOR   // sonstige NANFOR-Funktionen benutzen ?
                       // ft_peek(), ft_poke(), ft_dsksize()
  #define DEF_SHADOW
  #define DEF_VIDSTR  // ft_vidstr() benutzen ?
  #define DEF_OSLIB

  #define DEF_LFN  // seit 20070307 fÅr alle

#endif __XHARBOUR__
#endif __XPP__


#ifdef DEF_VIDSTR
  #define DEF_SHOWTIME  // Fortlaufend aktuelle Zeit anzeigen ?
  #define DEF_PURZEL    // PurzelmÑnnchen wenn "Arbeitsvorgang lÑuft"
#endif

* #ifndef DEF_VIDSTR
*   #xtranslate ft_vidstr(<a>,<b>,<c>) => ls_vidstr(<a>,<b>,<c>)
* #endif

* #define DEF_MOUSE

#ifdef LG_FRENCH
  #xtranslate UsrLang() =>  "F"
#endif
#ifdef LG_GERMAN
  #xtranslate UsrLang() => "D"
#endif
#ifdef LG_EN
  #xtranslate UsrLang() => "E"
#endif

#ifdef LG_GERMAN
  #xtranslate utrp(<en>,<de>[[[,<fr>],<nl>],<et>]) => <de>
  #xtranslate utrp(<en>) => <en>
#endif
#ifdef LG_FRENCH
  #xtranslate utrp(<en>,<de>,<fr> [,<list,...>]) => <fr>
  // #xtranslate utrp(<en>,<de>,<fr>) => <fr>
  // #xtranslate utrp(<en>[,<de>]) => <en>
#endif
#ifdef LG_EN
  #xtranslate utrp(<en> [,<list,...>]) => <en>
#endif


