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


#xcommand BROWSE ARRAY <aItems> ;
          USING <bBlock> ;
          [ START <nItem> ] ;
          [ ENTER <bEnter> ] ;
          [ HOTKEYS <aHot> ] ;
          [ SPACE <bSpace> ] ;
          [ FRAME <nFrame> ] ;
          [ IDLE <bIdle> ] ;
          [ EXIT <aExit> ] ;
          [ CREATE <bCreate> ] ;
          [ DELETE <bDelete> ] ;
          [ TITLE  <cTitle> ] ;
          [ WIDTH  <nWidth> ] ;
          [ HOME  <nRow>, <nCol> ] ;
          [ LEGEND  <cLeg> ] ;
          [ HELP   <cHelp> ] ;
          [ MODE   <nMode> ] ;
          [ POSIT  <bPosit> ] ;
          [ WINDOW  <aWindow> ] ;
          [ ACTIONS  <aActions> ] ;
          [ <lArrange:ARRANGE> ] ;
          [ PERMANENT <lPermanent> ] ;
          [ ARROWEXIT <lArrowExit> ] ;
          [ <lWrap:WRAP> ] ;
          => aBrowse( ;
            <aItems>, <bBlock>, <nItem> , ;
            <.lArrange.>, <bCreate>, <bDelete>, <(cTitle)>, ;
            <bEnter>, <bSpace>, <aHot>, <cHelp>, <aActions>, <cLeg>, ;
            <nRow>, <nCol>, <.lWrap.>, <nWidth>, <bIdle>, <aExit>, ;
            <aWindow>, <nMode>, <bPosit>, <lPermanent>, <nFrame>, ;
            <lArrowExit> ;
          )

#define ABMODE_EDIT 1
#define ABMODE_WAIT 2
