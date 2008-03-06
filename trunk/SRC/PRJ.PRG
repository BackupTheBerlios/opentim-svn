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

#include "TIM.CH"
#include "DEFDATA.CH"

#ifdef LG_FRENCH
  #define MSG041  "P‚riode(s) "
#else
  #define MSG041  "Periode(n) "
#endif

#ifdef DEF_PIN
static scIdPin := NIL
static saPinLog := {}
#endif DEF_PIN

#ifdef DEF_PIN

**
** PIN - "Pinwand-Eintr„ge"
**
FUNCTION oPin()
static b
if b != NIL ; RETURN b ; endif
define data b ;
            name PIN ;
            wait {|x| PinWait(x)}
ddIndex b on PIN->IdPin format {|x|padl(upper(x),LenIdPin())}
ddIndex b on PIN->IdPrj+dtos(PIN->Date)+PIN->Time   // ORD_PIN_IDPRJ     2
* ddIndex b on PIN->IdPns + dtos(PIN->Date)    // ORD_PIN_STATUS    2
ddFld Date    ,D, 8,0
ddFld Code    ,C, 8,0 picture PIC_ID
ddFld IdPrj   ,C, LenIdPrj(),0 picture PIC_ID pick PickPrj(PIN->IdPrj)
ddFld Memo    ,M,10,0
ddFld Attrib  ,C, 8,0  picture PIC_ID ;
                       pick PickPna(PIN->IdPrj,PIN->Attrib)
ddFld Time    ,C, 5,0 picture PIC_ID      ;
                      postedit {|x| GetTime(x) }
ddFld IdLng   ,C, 1,0 picture PIC_ID pick PickLng(PIN->IdLng)
ddFld IdPns   ,C, 1,0 picture PIC_ID ;
                      pick PickPns(PIN->IdPrj,PIN->IdPns) ;
                      valid {||PnsLocate(PIN->IdPrj,PIN->IdPns)!=NIL}
ddFld _Status ,C,20,0 attrib V ;
  block padr(iif(eof(),"",PnsName(PIN->IdPrj,PIN->IdPns)),20)
ddFld IdPin   ,C, LenIdPin(),0 picture PIC_ID when .f.
* ddFld _First  ,C,60,0 attrib V block padr(memoline(PIN->Memo,60,1),60)
ddFld Short   ,C,80,0 picture "@k@s30"
ddFld Options ,C,10,0 picture PIC_ID pick PickPno(PIN->IdPrj,PIN->Options)
* action b key K_ENTER   block WinMemoEdit()
* action b key K_CTRL_F2 prompt MnuClose() block PinChgStatus()
* action b key K_ALT_F7  prompt MsgMnuAttrib() block PinGetAttrib()
action b key K_F12     prompt MnuMemoEdit()  block WinMemoEdit()
ddEndDef()
RETURN b

FUNCTION PinLogMessage(cTitle,cBody)
local c := trim1(UserId())+dtoc(UserDate())+" "+time()+" "+trim(cTitle)
PIN->Memo:=c+crlf()+iif(empty(cBody),"",trimcr(cBody)+crlf())+crlf()+PIN->Memo
setmsg(c)
RETURN .t.


FUNCTION PinChgStatus()
local cStart := PickPns(PIN->IdPrj,PIN->IdPns)
local nRecOld := recno()
* local nRecNew := NIL
RETURN .f. if cStart == NIL
* if indexord() == ORD_PIN_STATUS
*   if ddSkip(1) != 1
*     ddSkip(-1)
*   endif
*   nRecNew := recno()
*   goto nRecOld
* endif
RETURN .f. if ! ddRecLock()
PIN->IdPns := cStart
unlock record
* if nRecNew == NIL
  ddRefreshCurrent()
* else
*   goto nRecNew
*   ddRefreshAll()
* endif
RETURN MnuDone()

FUNCTION PinGetAttrib
local cAttrib  := PickPna(PIN->IdPrj,PIN->Attrib)
local cOptions := PickPno(PIN->IdPrj,PIN->Options)
if ddRecLock()
  if cAttrib  != NIL ; PIN->Attrib  := cAttrib  ; endif
  if cOptions != NIL ; PIN->Options := cOptions ; endif
  ddRefreshCurrent()
  unlock record
endif
RETURN MnuDone()

FUNCTION PinStart()
if scIdPin != NIL
  RETURN .f. if ! PinStop()
endif
scIdPin := PIN->IdPin
LogPin(utrp("Started to work on this.","Bearbeitung begonnen.","Commenc‚."))
RETURN .t.

FUNCTION PinStop()
*local cTime1 := ""
RETURN .t. if scIdPin == NIL
// LogPin("Stop")
* if len(saPinLog) > 1
*   cTime1 := saPinLog[1][1]
* endif
RETURN .f. if ! ActExec("PINSTOP")
scIdPin := NIL
saPinLog := {}
RETURN .t.

FUNCTION LenIdPin() ; RETURN 6

FUNCTION GetPinId()
RETURN scIdPin

FUNCTION GetPinLog()
local c := ""
RETURN c if scIdPin == NIL
ascan(saPinLog,{|x|c+=x[1]+":"+x[2]+CR_LF})
RETURN c

FUNCTION LogPin(cMsg)
RETURN .t. if scIdPin == NIL
aadd(saPinLog,{time(),cMsg})
RETURN .t.

FUNCTION PinName(cIdPin)
RETURN "" if empty(cIdPin)
RETURN DbfPeek(oPin(),cIdPin,"PIN->Short",cIdPin+"?")

FUNCTION PickPin(cStart)
RETURN DbfPick({oPin()},"Choose a ticket :","PINPICK",cStart)

FUNCTION PinRouse(nOrder,cIdPns,dDate)
** cIdPns: welcher Status geweckt werden soll
** nOrder: index order, der nach IdUsr+IdPns+Date sortiert
local n := 0
local lOkay := .f.
local cIdUsr := padr(UserId(),LenIdUsr())
default cIdPns to "S"
default nOrder to 3
default dDate to UserDate()
open area oPin()
  ddSetOrder(nOrder)
  lOkay :=.t.
  softseek cIdUsr+cIdPns
  do while !eof().and.PIN->IdUsr==cIdUsr.and.PIN->IdPns==cIdPns
    if PIN->Date > dDate
      exit
    endif
    if ddRecLock()
      PIN->IdPns := ""
      n += 1
      unlock record
    else
      lOkay := .f.
    endif
    softseek cIdUsr+cIdPns
  enddo
close area
SetMsg(ntrim(n)+" tickets ont ‚t‚ r‚ouverts.")
RETURN lOkay

#else

FUNCTION LogPin(cMsg)
RETURN .t.

#endif DEF_PIN

**
** SetPeriode( [cPerRange] )
** Setzt oder ermittelt den aktuellen Periodenbereich
** z.B. : SetPeriode() gibt einen String "9701-9706" zurck
**        SetPeriode("1-6") setzt den Periodenbereich auf "9701-9706"
** Im Gegensatz zu GsbPeriode() gibt SetPeriode(!NIL) .t. zurck.
** GsbPeriode() k”nnte eigentlich komplett durch SetPeriode() ersetzt
** werden, aber z.B. bei HK gibt es noch dlg-Dateien, in denen
** GsbPeriode gerufen wird.
FUNCTION SetPeriode(cPerRange)
#ifdef DEF_JNL
RETURN GsbPeriode() if cPerRange == NIL
GsbPeriode(cPerRange)
#endif
RETURN .t.

FUNCTION SetQuarter(nYear,nQuarter)
if nQuarter == 0 ; RETURN SetPeriode(ntrim(nYear)) ; endif
if nQuarter == 1 
  MemPer1 := m2p(nYear,1)
  MemPer2 := m2p(nYear,3)
elseif nQuarter == 2 
  MemPer1 := m2p(nYear,4)
  MemPer2 := m2p(nYear,6)
elseif nQuarter == 3 
  MemPer1 := m2p(nYear,7)
  MemPer2 := m2p(nYear,9)
elseif nQuarter == 4 
  MemPer1 := m2p(nYear,10)
  MemPer2 := m2p(nYear,12)
else
  RETURN ! SetMsg(ntrim(nQuarter)+" : invalid quarter!")
endif
RETURN .t.




#ifdef DEF_JNL

FUNCTION SayGetPeriode()
local cGet := GsbPeriode()
say MSG041
@ row(), col() get cGet picture PIC_ID ;
                        pick PickPerRange(cGet) ;
                        postedit {|x| GetPeriode(x) }
WinCR()
RETURN NIL

FUNCTION GsbPeriode(x)
if x == NIL
  RETURN space(LEN_PERIODE*2+2) if empty(MemPer1+MemPer2)
  RETURN padr(MemPer1,LEN_PERIODE*2+2) if MemPer1 == MemPer2
  RETURN padr(MemPer1 + "-" + MemPer2,LEN_PERIODE*2+2)
endif
GetPeriode(x)
RETURN NIL


FUNCTION GetPeriode(x)
local nPos
x := upper(trim(x))
if len(x) == 2 // LEN_YEAR
  if PerLocate(x + strtran( ;
    str(PerShift()+1,LEN_PERIODE-LEN_YEAR), ;
    " ", "0") ;
  ) != NIL
    x := x + strtran(str(PerShift()+1,LEN_PERIODE-LEN_YEAR)," ","0") ;
         + "-" + ;
         x + strtran(str(PerShift()+12,LEN_PERIODE-LEN_YEAR)," ","0")
  endif
endif
if val(x)>1900 .and. val(x) < 3000     // 19991013
  MemPer1 := y2p(val(x))+"01"
  MemPer2 := y2p(val(x))+"12"
elseif (nPos := at("-",x)) == 0
  MemPer1 := MemPer2 := PerConvert(trim(x))
else
  MemPer1 := PerConvert(alltrim(left(x,nPos-1)))
  MemPer2 := PerConvert(alltrim(substr(x,nPos+1)))
endif
if MemPer1 > MemPer2
  Warning(trim(GsbPeriode()) + " : ungltiger Periodenbereich !")
endif
if !empty(MemPer1)
  PerExist(MemPer1)
  * if ! PerExist(MemPer1)
  *   Warning(SetMsg())
  * endif
  SetDevise(DevDefault(MemPer1))
endif
if !empty(MemPer2).and.MemPer2 != MemPer1
  PerExist(MemPer2)
  * if ! PerExist(MemPer2)
  *   Warning(SetMsg())
  * endif
endif
if DevDefault(MemPer1) != DevDefault(MemPer2)
  Warning(trim(GsbPeriode()) + WrnPer1())
endif
RETURN GsbPeriode()

FUNCTION PerConvert(c)
RETURN space(LEN_PERIODE) if empty(c)
RETURN c if len(c) > (LEN_PERIODE - LEN_YEAR)
RETURN y2p(year(UserDate())) + strtran(str(val(c),LEN_PERIODE-2,0)," ","0")
* RETURN str(year(UserDate())-1900,2,0) + strtran(str(val(c),LEN_PERIODE-2,0)," ","0")


**
** ChkPeriode
**
FUNCTION ChkPeriode(cPeriode,cPer1,cPer2)
default cPer1 to MemPer1
default cPer2 to MemPer2
* RETURN -2 if cPeriode < PerStart(cPer1)
if ! empty(cPer1) .and. cPeriode < cPer1
  RETURN -1
endif
if ! empty(cPer2) .and. cPeriode > cPer2
  RETURN 1
endif
RETURN 0


#endif DEF_JNL

FUNCTION WrnPer1
#ifdef LG_GERMAN
  RETURN " : Grundw„hrung „ndert innerhalb dieses Periodenbereichs !"
#endif
#ifdef LG_FRENCH
  RETURN " : changement devise de base au sein de la p‚riode !"
#endif
#ifdef LG_EN
  RETURN " : base currency changes within this period range !"
#endif


*#ifdef DEF_HTN
*
***
*** HTN - Hypertext nodes
***
*FUNCTION oHtn()
*static b
*if b != NIL ; RETURN b ; endif
*define data b name HTN ;
*       wait {|x|MemoWait(x)} ;
*       create HtnCreate()
*ddIndex b on HTN->IdHtc+HTN->IdHts+HTN->IdHtn
*ddIndex b on HTN->IdHtc+HTN->IdHts+HTN->Seq format {|x|GetNum(x)}
** ddIndex b on dtos(HTN->Date)+HTN->IdHtn
*ddFld IdHtn   ,C, LEN_IDHTN,0
*ddFld Date    ,D, 8,0
*ddFld IdHtc   ,C, LEN_IDHTC,0 pick PickHtc(HTN->IdHtc)
*ddFld IdHts   ,C, LEN_IDHTS,0 pick PickHts(HTN->IdHtc,HTN->IdHts)
*ddFld Title1  ,C,60,0
*ddFld Memo    ,M,10,0
*ddFld Attrib  ,C, 8,0  picture PIC_ID ;
*                       pick PickDbcAttr("HTNATTR.DBC",HTN->Attrib)
*ddFld IdLng   ,C, 1,0 picture PIC_ID pick PickLng(HTN->IdLng)
*ddFld Seq     ,C, 4,0 postedit {|x|GetNum(x)}
*ddFld Title2  ,C,60,0
*ddFld Title3  ,C,60,0
**action b key K_ENTER   block WinMemoEdit()
**action b key K_ALT_F7  prompt MsgMnuAttrib() block HtnGetAttrib()
**action b key K_F12     prompt MnuMemoEdit()  block WinMemoEdit()
*ddEndDef()
*RETURN b
*
**FUNCTION HtnGetAttrib
**local cAttrib  := PickDbcAttr("HTNATTR.DBC",HTN->Attrib)
**RETURN .f. if cAttrib == NIL
**if ddRecLock()
**  if cAttrib  != NIL ; HTN->Attrib  := cAttrib  ; endif
**  ddRefreshCurrent()
**  unlock record
**endif
**RETURN SetMnuDone()
*
***
*** HTC - Hypertext chapters
***
*FUNCTION oHtc()
*static b
*if b != NIL ; RETURN b ; endif
*define data b name HTC ;
*       wait {|x|MemoWait(x)}
*ddIndex b on HTC->IdHtc format {|x|x}
*ddIndex b on HTC->Seq format {|x|GetNum(x)}
*ddFld IdHtc   ,C, LEN_IDHTC,0 pick PickHtc(HTC->IdHtc)
*ddFld Title1  ,C,60,0
*ddFld Memo    ,M,10,0
*ddFld Attrib  ,C, 8,0  picture PIC_ID ;
*                       pick PickDbcAttr("HTCATTR.DBC",HTC->Attrib)
*ddFld IdLng   ,C, 1,0 picture PIC_ID pick PickLng(HTC->IdLng)
*ddFld Seq     ,C, 4,0 postedit {|x|GetNum(x)}
*ddFld Title2  ,C,60,0
*ddFld Title3  ,C,60,0
*action b key K_ENTER   block HtcHtsEdit(HTC->IdHtc)
**action b key K_F12     prompt MnuMemoEdit()  block WinMemoEdit()
*ddEndDef()
*RETURN b
*
*FUNCTION HtcHtsEdit(cIdHtc)
*RETURN DbfEdit( ;
*  {oHts(),oHtc()}, ;
*  "Sections of chapter " + trim(cIdHtc), ;
*  "HTSHTC", NIL, ;
*  NIL, cIdHtc, "HTS->IdHtc", ;
*  NIL, 'HtsCreate("'+cIdHtc+'")' ;
*)
*
*
***
*** HTS - Hypertext sections
***
*FUNCTION oHts()
*static b
*if b != NIL ; RETURN b ; endif
*define data b name HTS ;
*       wait {|x|MemoWait(x)}
*ddIndex b on HTS->IdHtc+HTS->IdHts format {|x|x}
*ddIndex b on HTS->IdHtc+HTS->Seq format {|x|GetNum(x)}
*ddFld IdHtc   ,C, LEN_IDHTC,0 pick PickHtc(HTS->IdHtc)
*ddFld IdHts   ,C, LEN_IDHTS,0 pick PickHts(HTS->IdHtc,HTS->IdHtc)
*ddFld Title1  ,C,60,0
*ddFld Memo    ,M,10,0
*ddFld Attrib  ,C, 8,0  picture PIC_ID ;
*                       pick PickDbcAttr("HTSATTR.DBC",HTS->Attrib)
*ddFld IdLng   ,C, 1,0 picture PIC_ID pick PickLng(HTS->IdLng)
*ddFld Seq     ,C, 4,0 postedit {|x|GetNum(x)}
*ddFld Title2  ,C,60,0
*ddFld Title3  ,C,60,0
*action b key K_ENTER   block HtsHtnEdit(HTS->IdHtc,HTS->IdHts)
** action b key K_ENTER   block WinMemoEdit()
** action b key K_F12     prompt MnuMemoEdit()  block WinMemoEdit()
*ddEndDef()
*RETURN b
*
*
*FUNCTION HtsHtnEdit(cIdHtc,cIdHts)
*RETURN DbfEdit( ;
*  {oHtn(), oHts()}, ;
*  "Nodes of section " + trim(cIdHtc) + " " + trim(cIdHts), ;
*  "HTNHTS", NIL, ;
*  NIL, cIdHtc+cIdHts, "HTN->IdHtc+HTN->IdHts", ;
*  NIL, 'HtnCreate()' ;
*)
*
*
*FUNCTION PickHtc(cStart)
*RETURN DbfPick({oHtc()},"Choose a chapter :","HTCPICK",cStart)
*
*FUNCTION PickHts(cIdHtc,cStart)
*RETURN DbfPick( ;
*  {oHts(),oHtc()}, ;
*  "Sections of chapter "+trim(cIdHtc),;
*  "HTSPICK", ;
*  cStart, ".t.", ;
*  cIdHtc, "HTS->IdHtc", ;
*  "HTS->IdHts", {||HtsCreate(cIdHtc)};
*)
*
*FUNCTION HtcCreate()
*local lEof := eof()
*local aBuf := CopyRec()
*RETURN DDCREATE_FAIL if ! dbAddRec()
*if lEof .or. Confirm("Record kopieren (J/N)")
*  PasteRec(aBuf)
*endif
*RETURN DDCREATE_DONE
*
*FUNCTION HtsCreate(cIdHtc)
*local lEof := eof()
*local aBuf := CopyRec()
*// local cIdHts
*// default cIdHtc to PickHtc()
*// RETURN DDCREATE_FAIL if cIdHtc == NIL
*// KeyGoBottom(cIdHtc,"HTS->IdHtc")
*// cIdHts := NextId(HTS->IdHts)
*RETURN DDCREATE_FAIL if ! dbAddRec()
*if lEof .or. Confirm("Record kopieren (J/N)")
*  PasteRec(aBuf)
*endif
*if cIdHtc != NIL
*  HTS->IdHtc := cIdHtc
*endif
*// HTS->IdHts := cIdHts
*RETURN DDCREATE_DONE
*
*
*
*FUNCTION HtnCreate()
*local lEof := eof()
*local cIdHtn
*local aBuf := CopyRec()
*// go bottom
*// cIdHtn := NextId(HTN->IdHtn)
*RETURN DDCREATE_FAIL if ! dbAddRec()
*if lEof .or. Confirm("Record kopieren (J/N)")
*  PasteRec(aBuf)
*endif
*// HTN->IdHtn := cIdHtn
*HTN->Date := UserDate()
*RETURN DDCREATE_DONE
*
*
*FUNCTION HtsTitle(cIdHtc,cIdHts)
*seek cIdHtc + cIdHts in HTS
*RETURN HTS->Title1
*
*
*FUNCTION MemoWait(win)
*if win[WIN_WAITKEY] == 12
*  MemoDisplay(FIELD->Memo, ;
*    win[WIN_TOP], ;
*    win[WIN_LEFT], ;
*    win[WIN_HEIGHT], ;
*    win[WIN_WIDTH] ;
*  )
*endif
*RETURN NIL
*
*
**FUNCTION PickHtn(cIdHtc,cIdHts)
**RETURN NIL if (cIdHtc := PickHtc(cIdHtc)) == NIL
**RETURN NIL if (cIdHts := PickHts(cIdHtc,cIdHts)) == NIL
**RETURN DbfPick( ;
**  {oHtn(),oHts()},;
**  "Nodes of section " + trim(cIdHtc) + " " + trim(cIdHts), ;
**  "HTNPICK", NIL, NIL, ;
**  cIdHtc+cIdHts, "HTN->IdHtc+HTN->IdHts", ;
**  "HTN->IdHtn" ;
**)
*
**FUNCTION HtnTitle(cIdHtc,cIdHts,cIdHtn)
**RETURN DbfPeek(oHtn(),cIdHtn,"trim(HTN->Title1)",cIdHtn)
*
*
*FUNCTION HtRef(cUrl)
*local xuReturn := "'<a href='+chr(34)+'"
*xuReturn += HtBasePath()+"/'+HtFilename()+chr(34)+'>'+trim(FIELD->Title1)+'</a>'"
*// Warning("xuReturn =" + xuReturn)
*RETURN HtPeek(cUrl,xuReturn,"???")
*
*FUNCTION HtBasePath()
*RETURN ".." if alias()=="HTS"
*RETURN "../.." if alias()=="HTN"
*RETURN "." if alias() == "HTC"
*Warning("HtBasePath() : bad alias")
*RETURN "."
*
*FUNCTION HtFilename()
*RETURN trim(HTN->IdHtc)+"/"+trim(HTN->IdHts);
*       +"/"+trim(HTN->IdHtn)+".HTM" if alias() == "HTN"
*RETURN trim(HTC->IdHtc)+".HTM" if alias()=="HTC"
*RETURN trim(HTS->IdHtc)+"/"+trim(HTS->IdHts)+".HTM" if alias()=="HTS"
*Warning("HtFilename() : bad alias")
*RETURN "UNKOWN.HTM"
*
*FUNCTION HtPeek(cUrl,xuReturn,uNotFound)
*local cIdHtc
*local cIdHts
*local cIdHtn
*local cReturn := ""
*local n
*// default uNotFound to "(not found)"
*if (n := at("/",cUrl)) != -1
*  cIdHtc := padr(left(cUrl,n-1),LEN_IDHTC)
*  cUrl := substr(cUrl,n+1)
*  if (n := at("/",cUrl)) != -1
*    cIdHts := padr(left(cUrl,n-1),LEN_IDHTS)
*    cUrl := substr(cUrl,n+1)
*    Warning('"'+cIdHtc+"/"+cIdHts+"/"+cIdHtn+'"')
*    RETURN DbfPeek(oHtn(),cIdHtc+cIdHts+padr(cUrl,LEN_IDHTN),xuReturn,uNotFound)
*  endif
*  RETURN DbfPeek(oHts(),cIdHtc+padr(cUrl,LEN_IDHTS),xuReturn,uNotFound)
*endif
*RETURN DbfPeek(oHtc(),padr(cUrl,LEN_IDHTC),xuReturn,uNotFound)
*
*
*
*
*FUNCTION HtnRef(cIdHtn,cText)
*local cIdHtc := DbfPeek(oHtn(),cIdHtn,"trim(HTN->IdHtc)",NIL)
*local cReturn := '<a href="'
*if cIdHtc == NIL
*  cReturn += '"../notfound.htm"'
*else
*  cReturn += '"../' + cIdHtc + '/' + cIdHtn + '.htm"'
*endif
*cReturn += cText + "</a>"
*RETURN cReturn
*
*
*
*#endif DEF_HTN

#ifdef CUST_PAC

* „hnlich wie gleichnamige funktionen fr CUST_MOOR in etc.prg

FUNCTION PrjUpdate(dDate)
local a
local lOkay := .f.
if ddRecLock()
  a := PrjVenScan(PRJ->IdPrj,dDate)
  lOkay := .t.
  PRJ->QteUsed := h2time(a[1],LenQte())
  unlock record
endif
RETURN lOkay


FUNCTION PrjVenScan(cIdPrj,dDate2)
local nQteUsed := 0
* local aParQte := {}
PrjPacScan(PRJ->IdPrj,dDate2,;
  {||nQteUsed+=iif(VenIsNc(),-1,1)*qton(VNL->Qte),.t.})
RETURN { nQteUsed }

FUNCTION PrjIsUpdated()
local a := PrjVenScan(PRJ->IdPrj)
RETURN "QteUsed" if PRJ->QteUsed := h2time(a[1],LenQte())
RETURN NIL

FUNCTION VenIsPrjField()
RETURN .t. if VEN->IdJnl=="SRV"
RETURN .f.
  

FUNCTION PrjPacScan(cIdPrj,dDate2,blEval)
* wird auch in PRJPACK.INC benutzt
local nQte
* local lFirst := .t.
local lOkay := .f.
local xlVenFilter := 'VEN->Etat==DocStatClosed().and.VEN->IdJnl=="SRV"'
local xlVnlFilter := 'IsArtCode(VNL->Code).and.ArtExist(VNL->IdArt)'
* default bOnFirst to {||.t.}
* default bOnUsed to {||.t.}
* setvar("Qte1",qton(PRJ->Qte1))
* setvar("QteUsed",0)
open area oVen()
  lOkay := .t.
  ddSetOrder(3) // VEN->IdPrj+VEN->Date
  softseek cIdPrj
  do while lOkay .and. !eof() .and. VEN->IdPrj == cIdPrj
    if !empty(dDate2).and. VEN->Date > dDate2
      exit
    endif
    if &xlVenFilter
      open area oVnl(), oArt()
        softseek VEN->IdJnl+VEN->IdDoc
        do while lOkay .and. !eof() ;
          .and. VNL->IdJnl+VNL->IdDoc == VEN->IdJnl+VEN->IdDoc
          if &xlVnlFilter
            if "P" $ ART->Attrib
              nQte := qton(VNL->Qte)
              if VenIsNc()
                nQte := -nQte
              endif
              if ! eval(blEval)
                lOkay := .f.
              endif
            endif
          endif
          skip
        enddo
      close area
    endif
    skip
  enddo
close area
RETURN lOkay

#endif CUST_PAC


