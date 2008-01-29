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


#define TONE_SOL1 196.00
#define TONE_LA1  220.00
#define TONE_SI1  246.90
#define TONE_DO1  261.70
#define TONE_RE   293.70
#define TONE_MI   329.60
#define TONE_FA   349.20
#define TONE_SOL  392.00
#define TONE_LA   440.00
#define TONE_SI   493.90
#define TONE_DO   523.30

#xtranslate tune_birthday() => ;
           tone(TONE_DO1,2) ;
         ; tone(TONE_DO1,0)  ;
         ; tone(TONE_RE,4)  ;
         ; tone(TONE_DO1,4)  ;
         ; tone(TONE_FA,4)  ;
         ; tone(TONE_MI,8)

#xtranslate tune_torero() => ;
           tone(TONE_SOL,4) ;
         ; tone(TONE_LA,3)  ;
         ; tone(TONE_SOL,1) ;
         ; tone(TONE_MI,4)  ;
         ; tone(TONE_MI,4)  ;
         ; tone(TONE_MI,3)  ;
         ; tone(TONE_RE,1)  ;
         ; tone(TONE_MI,3)  ;
         ; tone(TONE_FA,1)  ;
         ; tone(TONE_MI,4)

*#xtranslate tune_morts() => ;
*           tone(TONE_RE,3) ;
*         ; tone(TONE_RE,2)  ;
*         ; tone(TONE_RE,1)  ;
*         ; tone(TONE_RE,3)  ;
*         ; tone(TONE_FA,2)  ;
*         ; tone(TONE_MI,1)  ;
*         ; tone(TONE_MI,2)  ;
*         ; tone(TONE_RE,1)  ;
*         ; tone(TONE_RE,2)  ;
*         ; tone(TONE_DO1,1)  ;
*         ; tone(TONE_RE,3)

#xtranslate tune_morts() => ;
           tone(TONE_FA,2)  ;
         ; tone(TONE_MI,1)  ;
         ; tone(TONE_MI,2)  ;
         ; tone(TONE_RE,1)  ;
         ; tone(TONE_RE,2)  ;
         ; tone(TONE_DO1,1)  ;
         ; tone(TONE_RE,6)

#xtranslate tune_maja() => ;
           tone(TONE_SOL1,1)  ;
         ; tone(TONE_DO1,1)  ;
         ; tone(TONE_MI,1)  ;
         ; tone(TONE_LA,1)  ;
         ; tone(TONE_SOL,1)  ;
         ; tone(TONE_MI,1)  ;
         ; tone(TONE_DO1,1)  ;
         ; tone(TONE_RE,2)

