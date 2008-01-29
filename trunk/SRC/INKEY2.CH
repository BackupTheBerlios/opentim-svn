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

///////////////////////////////////////////////
//
// File:    INKEY2.CH
// Author:  Patrick T. Hurley
// Date:    07-26-91 12:21:42pm
// Version: 1.0
//
// Notes:   More inkey constants when you need
//          Few Nantuket decieded not to give you
//

* #ifndef _INKEY2_CH
* #define _INKEY2_CH

// LS 920123
// The following defines added after reading CLBBS & trying with keycode.prg
// #define   K_SPACE        20
* #define   K_CTRL_UP      397
* #define   K_CTRL_DOWN    401
* #define   K_CTRL_INS     402
* #define   K_CTRL_DEL     403
#define   K_ALT_PLUS     334
#define   K_ALT_MINUS    330
* #define   K_ALT_ENTER    422

// used together with ft_alt() in stdio.prg
#define   K_ALT    500


#define K_LOWKEY    (-39)
#define K_HIKEY     (386)

* #define K_SPACE     (32)
#define K_BAR       (95)
#define K_EQUAL     (61)
#define K_PLUS      (43)
#define K_MINUS     (45)

#define K_NORM_0    (48)
#define K_NORM_1    (49)
#define K_NORM_2    (50)
#define K_NORM_3    (51)
#define K_NORM_4    (52)
#define K_NORM_5    (53)
#define K_NORM_6    (54)
#define K_NORM_7    (55)
#define K_NORM_8    (56)
#define K_NORM_9    (57)

#define K_LOWER_A   (97)
#define K_LOWER_B   (98)
#define K_LOWER_C   (99)
#define K_LOWER_D   (100)
#define K_LOWER_E   (101)
#define K_LOWER_F   (102)
#define K_LOWER_G   (103)
#define K_LOWER_H   (104)
#define K_LOWER_I   (105)
#define K_LOWER_J   (106)
#define K_LOWER_K   (107)
#define K_LOWER_L   (108)
#define K_LOWER_M   (109)
#define K_LOWER_N   (110)
#define K_LOWER_O   (111)
#define K_LOWER_P   (112)
#define K_LOWER_Q   (113)
#define K_LOWER_R   (114)
#define K_LOWER_S   (115)
#define K_LOWER_T   (116)
#define K_LOWER_U   (117)
#define K_LOWER_V   (118)
#define K_LOWER_W   (119)
#define K_LOWER_X   (120)
#define K_LOWER_Y   (121)
#define K_LOWER_Z   (122)

#define K_UPPER_A   (65)
#define K_UPPER_B   (66)
#define K_UPPER_C   (67)
#define K_UPPER_D   (68)
#define K_UPPER_E   (69)
#define K_UPPER_F   (70)
#define K_UPPER_G   (71)
#define K_UPPER_H   (72)
#define K_UPPER_I   (73)
#define K_UPPER_J   (74)
#define K_UPPER_K   (75)
#define K_UPPER_L   (76)
#define K_UPPER_M   (77)
#define K_UPPER_N   (78)
#define K_UPPER_O   (79)
#define K_UPPER_P   (80)
#define K_UPPER_Q   (81)
#define K_UPPER_R   (82)
#define K_UPPER_S   (83)
#define K_UPPER_T   (84)
#define K_UPPER_U   (85)
#define K_UPPER_V   (86)
#define K_UPPER_W   (87)
#define K_UPPER_X   (88)
#define K_UPPER_Y   (89)
#define K_UPPER_Z   (90)

* #endif

//  End of INKEY2.CH

