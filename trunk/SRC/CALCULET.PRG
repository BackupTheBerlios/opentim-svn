* Nom.....: Calcul.prg
* But.....: Calculatrice
* Date....: 30/03/90
* Auteur..: G. XHONNEUX/L. SAFFRE
* Last Mod: 30/03/90 - 09/04/90
*
FUNCTION PopCalcul
SET COLOR TO BG+/,W+/B
*   SET COLOR TO N/W,W+/W

calc = SPACE(30)
j=0
i=-1
decl arr[50]
mLin=12
mCol=27
mHei=8
mT=mLin-mHei-1
mL=mCol-2
mR=mCol+31
mB=mLin+3
mScr1=savescreen(mT,mL,mB,mR)
@ mT,mL clea to mB,mR
@ mT,mL to mB,mR doub
@ mT,mL+10 say "TASCHENRECHNER"
@ mB-2,mL say "«"+repl("ƒ",32)+"∂"
do whil .t.
  @ mLin,mCol get calc
  @ mB-1,mCol say "ESC=Ende,=Papier,CLP=Abrei·en "
  readexit(.t.)
  read
  readexit(.f.)
  mKey=lastkey()
  if mKey=27
    exit
  endi
  if upper(calc)="CLP"
    i=-1
    for j=1 to 50
      adel(arr,1)
    next
    calc=""
    @ mT+1,mL+2 clea to mB-4,mR-2
    loop
  endi
  if mKey=5
    @ mB-1,mCol say "ESC=ZurÅck,ENTER=öbernehmen"
    @ mLin,mCol say space(30)
    mScr2=savescreen(mT+1,mL+2,mB-4,mR-2)
    j=achoice(mT+1,mL+2,mB-4,mR-2,arr,"","",i+1,7)
    restscreen(mT+1,mL+2,mB-4,mR-2,mScr2)
    if j=0
      result=""
    else
      result=trim(arr[j])
      if left(result,1)="="
        result=stuff(result,1,2,"")
      endi
    endi
  endi
  if mKey=13
    result=ltrim(str(&calc,30))
    if .not.empty(result)
      if i>48
        adel(arr,1)
        adel(arr,1)
      else
        i=i+2
      endi
      arr[i]=calc
      arr[i+1]="= "+ltrim(result)
      scroll(mLin-mHei,mCol,mLin-1,mCol+29,2)
      @ mLin-2,mCol say arr[i]
      @ mLin-1,mCol say arr[i+1]
    endi
  endi
  keyboard repl(chr(4),len(result))
  calc=result+space(30-len(result))
endd
restscreen(mT,mL,mB,mR,mScr1)

RETURN

func expr_error
para name,line,info,model,_1,_2,_3
retu ""

func undef_error
para name,line,info,model,_1
publ &_1
&_1=0
@ mLin+2,mCol say space(30)
@ mLin+2,mCol say "Wert fÅr &_1 :" get &_1 pict "9999999999"
read
retu .t.

