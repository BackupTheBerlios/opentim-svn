:staticmod:`DEF_IBAN` -- IBAN support
=====================================

.. staticmod:: DEF_IBAN

Defines table :class:`BIC`.

N.B.: For historical reasons, fields and functions related to
Bank Account Numbers (BAN) don't follow a rigurous naming
convention.

Compte == Bnk == Bqe == BAN


Global functions
----------------

.. function:: gsbNBAN(x,cCountry,cFieldname)

   Get/Set function for a virtual national "domestic" bank account
   number field. cCountry is the country code and cFieldname the name
   of the storage field. 
   If the country is not supported, then TIM does not validate
   the data. Currently TIM checks just belgian numbers.
   
.. function:: gsbBIC(x,cIdNat,cFieldname)
 
.. function:: LenIdBic()

.. function:: LenBqe

.. function:: BicValidate(cIdBic)

.. function:: MsgBicExist(cIdBic)

.. function:: BicCountry(cIdBic)

.. function:: BqePostEdit(x)

.. function:: BqeValidate(x)

.. function:: IsIBAN(x)

  returns true if the specified BAN is an IBAN (and not a national number)

.. function:: ChkIBAN34(x)

  check digits at pos 3 and 4 of a IBAN

.. function:: BnkParse(x)

  returns either the correctly formatted BIC:IBAN string, or NIL.
  If NIL, then SetMsg() contains the explanation
  
.. function:: BanBeParse(x)

.. function:: be2iban(cCompte)

.. function:: be2bic(cCompte)



.. function:: ddAddBanFields(cFieldname)

  adds 3 virtual fields NBAN, BIC and IBAN for this cFieldname
  
  
.. function:: isnban(cBAN)

   Returns True if the specified `cBAN` is an national BAN in "old" format.
   
   You can use this in your :xfile:`PAR.MSK` or :xfile:`PAR.QRY` in the 
   expression of a text field to decorate old BANs whose BIC:IBAN 
   needs to be verified. Example::
  
   =iif(isnban(Compte2),"?"," ")
   
   
  
.. function:: BanClean(x)

  Converts the specified value of a BAN field to new storage format. 
  See `20090219`_
 
.. function:: BanSplit(x)

  splits the string and always returns an array with 3 elements::
  
    #define BAN_NBAN   1
    #define BAN_BIC    2
    #define BAN_IBAN   3
  
.. function:: BanValidate(aBan)

   Returns True if this is a valid BAN, otherwise sets the error
   message and returns False.
  
.. function:: BqeValidate(x)
   
   Calls :func:`BanSplit` and then :func:`BanValidate`.

  



External Sources
----------------

- http://fr.wikipedia.org/wiki/ISO_13616#Composition
- http://www.europebanks.info/ibanguide.htm#5
- http://fr.wikipedia.org/wiki/ISO_13616#Composition
- `Marek Horodyski's BigMod function 
  <http://groups.google.com/groups?dq=&hl=en&lr=&ie=UTF-8&
  oe=UTF-8&threadm=3EC0C56B.2BBF606%40skynet.be&prev=/groups
  %3Fq%3Dcomp.lang.clipper%2B%26ie%3DUTF-8%26oe%3DUTF-8%26hl
  %3Den%26btnG%3DGoogle%2BSearch>`_


Importing BIC codes
-------------------

There are several data import drivers to fill the :class:`BIC` table
with data.

.. xfile:: BICSWIFT.IMP

   This driver should work for files from 
   `BICPlusIBAN Directory   
   <http://www.swift.com/biconline/index.cfm?
   fuseaction=display_newdownload>`_
   
.. xfile:: BIBB.IMP 

   Approximately 4061 records
  
   This driver should work for the PC-Text file from  
   `Bundesbank <http://www.bundesbank.de/zahlungsverkehr/
   zahlungsverkehr_bankleitzahlen_download.php>`_
  
.. xfile:: BIBNB.IMP 

   Approximately 804 records
   
   This driver should work for the Excel file 
   ("Full List of Current Codes") from 
   `Banque Nationale de Belgique 
   <http://www.bnb.be/pub/07_00_00_00_00/
   07_06_00_00_00/07_06_02_00_00.htm>`_
   (you must open it with Excel and save it as a tab-delimited text file)
  
Estonian BIC Codes
------------------

In Estland gibt es genau 8 BIC-Codes:
  
  ================== ===============================
  Eesti Krediidipank EKRDEE22
  Eesti Pank         EPBEEE2X
  SEB Pank           EEUHEE2X
  Hansapank          HABAEE2X
  Nordea Pank        NDEAFIHH in favour of NDEAEE2X
  Marfin Pank Eesti  PREAEE22
  Sampo Pank         FOREEE2X
  Tallinna Äripank   TABUEE22
  ================== ===============================

  (Quelle: http://www.pangaliit.ee/arveldused/IBAN/)

Vergleich: in Belgien gibt es ca 800 BIC-Codes und in Deutschland 
ca. 4000.  



