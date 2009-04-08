** Copyright (c) 1992-2001 PAC Systems
** Copyright (c) 2001-2009 Luc Saffre
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

#translate TVAC(<b>,<t>) => round( <b> + ( <b> * <t> / 100 ), 0 )
#translate MTVA(<b>,<t>) => ntom(<b> * <t>)

#define LEN_MONT     10
#define PIC_MONTANT  "@K@!"
#define PIC_NUM      "@K@#"
#ifdef DEF_IMP
  #define DC_DEBIT     "A"
  #define DC_CREDIT    "E"
#else
  #define DC_DEBIT     "D"
  #define DC_CREDIT    "C"
#endif

#xtranslate GET_MONTANT => ;
  postedit {|x| GetMont(x) } ;
  pick {|x,r,c| PickNum(x,r,c) }
#xtranslate GET_DECPOS(<n>) => ;
  postedit {|x| GetNum(x,<n>,<n>) } ;
  pick {|x,r,c| PickNum(x,r,c) }
#xtranslate GET_NUM     => ;
  postedit {|x| GetNum(x) } ;
  pick {|x,r,c| PickNum(x,r,c) }

