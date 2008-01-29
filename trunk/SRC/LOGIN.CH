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


* #xtranslate UsrIsBoss()  => ("B" $ UsrAttrib())
* #xtranslate UsrIsWrite() => ("R" $ UsrAttrib())

* #define USRATTR_C "C" // may see confidential data
* #define USRATTR_O "O" // Dialogfenster DRUCKEN Åberspringen
* #define USRATTR_P "P" // default Preview to BUTTON_ON
* #define USRATTR_L "L" // limited user
* #define USRATTR_B "B" // boss
* #define USRATTR_S "S" // superuser
#define USRATTR_D "D" // detaillierter bericht
#define USRATTR_R "R" // read-only user
#define USRATTR_W "W" // user WRITE (hidden)
#define USRATTR_A "A" // Warnung wenn andere Benutzer aktiv
#define USRATTR_B "B" // Datenbankverwalter (Boss)
#define USRATTR_C "C" // kann vertrauliche Daten sehen
#define USRATTR_H "H" // ist unsichtbar fÅr andere Benutzer
#define USRATTR_L "L" // EingeschrÑnkter Benutzer
#define USRATTR_O "O" // Dialogfenster 'Druckoptionen' Åberspringen
#define USRATTR_P "P" // Druckvorschau standardmÑ·ig eingeschaltet
#define USRATTR_E "E" // Experte
#define USRATTR_S "S" // Super-User
#define USRATTR_Y "Y" // Yes-User

* #define USRATT_BOSS    "B"
* #define USRATT_RDONLY  "R"
* #define USRATT_PREVIEW "P"
* #define USRATT_MODIFY  "M"

* #define LEN_IDUSR 8
