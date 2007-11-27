PROCEDURE Main
local c,i
? "Gonna call EID_GET()..."
c := EID_GET()
* ? "len(c) is ", len(c)
* for i := 1 to 20 // len(c)
*    ? i, asc(substr(c,i,1))
* next i
? c
RETURN
