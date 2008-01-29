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

*         [ VIEWDETAIL <bViewDetail> ]
*           <{bViewDetail}>,

#command DEFINE DATA <ad>                                     ;
         NAME <cAlias>                                       ;
         [ PREEDIT <bPreEdit> ]                              ;
         [ POSTEDIT <bPostEdit> ]                            ;
         [ CREATE <bCreate> ]                                ;
         [ PREDELETE <bPreDelete> ]                                ;
         [ WAIT <bWait> ]                                    ;
         [ FILEPRINT <bFilePrint> ]                          ;
         [ EDITPRINT <bEditPrint> ]                          ;
         [ ATTRIB <cFldAttrib> ]                             ;
         [ CONVERT <bConvert> ]                              ;
         [ PICKFLT <bPickFlt> ]                              ;
         [ QRYWAIT <bQryWait> ]                              ;
         [ ONTEST <blOnTest> ]                               ;
         =>                                                  ;
         <ad> := ddDeclare(                                   ;
           <"cAlias">,                                       ;
           <{bPreEdit}> ,                                    ;
           <{bPostEdit}> ,                                   ;
           <{bCreate}> ,                                     ;
           <{bWait}>,                                        ;
           <{bPreDelete}>,                                   ;
           <{bFilePrint}>,                                   ;
           <{bEditPrint}>,                                   ;
           #<cFldAttrib>,                                    ;
           <{bConvert}>,                                     ;
           <{bPickFlt}>,                                     ;
           <{bQryWait}>,                                     ;
           <{blOnTest}>                                      ;
         )

#xcommand DDINDEX <ad> ON <cKey> [ TEXT <cText> ] [ FOR <cFor> ]  ;
                                 [ FORMAT <bKeyFormat> ] ;
         => ;
         ddAddIndex( ;
           <"cKey">, <cText>, ;
           <(cFor)>, ;
           <bKeyFormat> ;
         )

#command DDFLD <cFldName>, <cFldType> , <nFldLength>, <nFldDec>  ;
                 [ ATTRIB <cFldAttrib> ]            ;
                 [ PICTURE <cFldPicture> ]          ;
                 [ PICK <bFldPick> ]                ;
                 [ VALID <bFldValid> ]              ;
                 [ WHEN <bFldWhen> ]                ;
                 [ POSTEDIT <bPostBlock> ]          ;
                 [ VALUE <bValue> ]                 ;
                 [ BLOCK <bBlock> ]                 ;
                 [ HANDLE <nHandle> ]               ;
                 [ PSEUDO <bPseudo> ]               ;
  => ddAddField(                                                    ;
          <"cFldName">, <"cFldType">, <nFldLength>, <nFldDec>,      ;
          <cFldPicture>, #<cFldAttrib>, ;
          <{bBlock}>, <nHandle> , ;
          <{bFldValid}>,   ;
          <{bFldPick}>, <{bFldWhen}>, ;
          <bPostBlock>, ;
          <{bValue}>, <{bPseudo}> ;
     )

* #xtranslate ddAction( <b>, <nKey>, <cText>, <bBlock> ) ;
*             => aadd( <b>:cargo\[AD_ACTIONS\], { <nKey>, <cText>, <{bBlock}> } )

#xcommand ACTION <b> [ PROMPT <cPrompt> ] ;
            [ BLOCK <bAction> ] ;
            [ KEY <nKey> ] ;
            [ WHEN <bWhen> ] ;
  => ;
  AddItem( <cPrompt> , <{bAction}>, <nKey>, <{bWhen}>, <b>\[AD_ACTIONS\] )

