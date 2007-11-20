//
//
// File:    PHREAD.CH
// Author:  Patrick T. Hurley
// Date:    07-26-91 09:02:51am
// Version: 2.1
//
// Notes:   This is my header file for using
//          phread's instead of readmodals
//

#ifndef _PHREAD_CH
#define _PHREAD_CH

// #define CTRL_END_SPECIAL

#ifndef GE_BOUNCE
#define GE_BOUNCE       9
#endif

* #ifndef TRUE
* #define TRUE            (.t.)
* #endif
*
* #ifndef FALSE
* #define FALSE           (.f.)
* #endif

***
*  READ
*

#command READ SAVE => ReadModal(GetList)

#command READ => ReadModal(GetList)                                    ;
       ; GetList := {}

#command CLEAR GETS => __KillRead()               ;
       ; GetList := {}

/*********
//
// @..GET PASSWORD
//
#command @ <row>, <col> GET <var>                                      ;
                        [<clauses,...>]                                ;
                        PASSWORD                                       ;
                        [<moreClauses,...>] => @ <row>, <col> GET <var> ;
                   [<clauses>]                                         ;
                   [<moreClauses>]                                     ;
            ; atail(GetList):reader := {|get|PwdReader(get)}
**************/



#endif


//  End of PHREAD.CH

