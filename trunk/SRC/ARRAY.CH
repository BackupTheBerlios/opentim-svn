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

/***
*  
*     Array.ch
*     Header file for array functions contained in Array.ch.
*     Copyright Nantucket Corporation, 1990
*
*     Usage: place #include "Array.ch" at the top of any program file
*            that uses a function from Array.prg.
*/

// Comparison blocks to be used with AComp()
#define AC_MAX    {|x,y| x > y}           // Element with maximum value
#define AC_MIN    {|x,y| x < y}           // Element with minimum value
#define AC_MAXLEN {|x,y| LEN(x) > LEN(y)} // Element with maximum length
#define AC_MINLEN {|x,y| LEN(x) < LEN(y)} // Element with minimum length
