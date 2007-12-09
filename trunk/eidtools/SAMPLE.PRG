PROCEDURE Main
local a,i
local c := ""
? "Gonna call EID_GET()..."
a := EID_GET()
* ? "len(c) is ", len(c)
for i := 1 to len(a)
  c += ltrim(str(i)) + " : " + utos(a[i]) + chr(13)+chr(10)
*    ? i, asc(substr(c,i,1))
next i
? c
memowrit("SAMLE.OUT",c)
RETURN

** simplified utos() works only for NIL and CHAR
FUNCTION utos(u)
local r
if u == NIL
  RETURN "NIL"
endif
if valtype(u) == "D"
  RETURN "ctod('"+dtoc(u)+"')"
endif
if valtype(u) == "L"
  RETURN (if(u,".t.",".f."))
endif
if valtype(u) == "N"
  r := ltrim(str(u,20,4))
  if "." $ r
    do while right(r,1) == "0"
      r := left(r,len(r)-1)
    enddo
    if right(r,1) == "."
      r := left(r,len(r)-1)
    endif
  endif
  RETURN r
endif
RETURN u
