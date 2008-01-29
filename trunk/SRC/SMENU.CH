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


#define MI_PROMPT  1
#define MI_HOTKEY  2
#define MI_HKPOS   3
#define MI_HKCHAR  4
#define MI_ROW     5
#define MI_COL     6
#define MI_SUBMENU 7 // in hMenu : array for sub-menu
#define MI_ACTION  7 // in vMenu
#define MI_WHEN    8 // only in vMenu
#define MI_ACTIVE  9 // only in vMenu
#define MI_ALEN    9



* #xcommand DEFINE BAR <aBar>    => BarSetHandle( <aBar> )
#xcommand DEFINE MENU <cTitle> [ IN <aBar> ]  [ TO <aMnu> ] [ USING <aItems> ] ;
  => ;
  [ <aMnu> := ] AddMenu( <aBar>, <cTitle>, <aItems> )
#xcommand MENU ITEM <cPrompt> ;
            [ BLOCK <bAction> ] ;
            [ KEY <nKey> ] ;
            [ WHEN <bWhen> ] ;
            [ INTO <aMnu> ] ;
  => ;
  AddItem( <cPrompt> , <{bAction}>, <nKey>, <{bWhen}>, <aMnu> )

#xcommand MENU LINE [ INTO <aMnu> ] ;
  => ;
  AddLine( <aMnu> )

