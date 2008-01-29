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

* #define DEF_CTOOLS

* #ifdef DEF_CTOOLS
*   #xtranslate HWID() => HWID3()
* #else
*   #xtranslate HWID() => HWID2()
* #endif

memvar MrkInstall
* memvar MrkOptions
memvar MrkStr1
memvar MrkStr2
memvar MrkStr3
memvar MrkMaxUsers
memvar MemVersion
memvar MemName1
memvar MemName2
memvar MemName3
memvar MemLang1
memvar MemLang2
memvar MemLang3
#ifdef DEF_4LANG
  memvar MemLang4
#endif

* #xtranslate AppIsShell() => ("X" $ MrkOptions)
* #xtranslate AppIsLabel() => ("E" $ MrkOptions)

#define DBD_IDDOS   1
#define DBD_NAME    2
#define DBD_ATTRIB  3
#define DBD_ALEN    3

#define DBDATTR_H   "H"  // hidden
