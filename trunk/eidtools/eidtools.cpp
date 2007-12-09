#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#include "xppdef.h"
#include "xpppar.h"
#include "xppcon.h"


#if defined(_WIN32) || defined (__WIN32__)
#include <tchar.h>
#pragma comment( lib, "beidlib" )
#endif

#include "eidlib.h"


#define PRINT( label_, data_ )    printf("%-25s: %s\n", label_, data_)
#if defined(_WIN32) || defined (__WIN32__)
#define PRINTU( label_, data_ )    _tprintf(_T("%-25s: %s\n"), label_,data_)
#else
#define _T
#define PRINTU( label_, data_ )    printf(_T("%-25s: %s\n"), label_,data_)
#endif

#define EID_ERROR      1
#define EID_CARDNUMBER 2
#define EID_CHIPNUMBER 3
#define EID_VALIDITY_BEGIN 4
#define EID_VALIDITY_END 5

#define EID_DELIVERY_MUNICIPALTIY  6
#define EID_NATIONAL_NUMBER 7
#define EID_NAME 8
#define EID_FIRSTNAME1 9
#define EID_FIRSTNAME2 10
#define EID_FIRSTNAME3 11
#define EID_NATIONALITY 12
#define EID_BIRTHPLACE 13
#define EID_BIRTHDATE 14
#define EID_GENDER 15
#define EID_NOBLE_CONDITION 16
#define EID_DOCTYPE 17
#define EID_WHITECANE 18
#define EID_YELLOWCANE 19
#define EID_EXTENDED_MINORITY 20

#define EID_STREET 21
#define EID_NUMBER 22
#define EID_BOX 23
#define EID_ZIP 24
#define EID_MUNICIPALTIY 25
#define EID_COUNTRY 26

#define EID_ALEN       26

void post(ContainerHandle chArray, int i, ContainerHandle uhValue) {
  XPPAPIRET        xr;
  if (uhValue == NULLCONTAINER) return;
  xr = _conArrayPut(chArray, uhValue, i, NULL);
  // if (xr != 0) return;
  _conRelease(uhValue);
}
               
void post_string(ContainerHandle chArray, int i, char* s) {
  post(chArray,i,_conPutC(NULLCONTAINER,s));
}
  
void post_logical(ContainerHandle chArray, int i, int value) {
  post(chArray,i,_conPutL(NULLCONTAINER,value));
}
  
void post_long(ContainerHandle chArray, int i, long value) {
  post(chArray,i,_conPutNL(NULLCONTAINER,value));
}
  

/********
         
void post_string(ContainerHandle chArray, int i, char* s) {
  XPPAPIRET        xr;
  ContainerHandle hString;
  hString = _conPutC(NULLCONTAINER,s);
  if (hString != NULLCONTAINER) {
    xr = _conArrayPut(chArray, hString, i, NULL);
    if (xr != 0) return;
  }
  _conRelease(hString);
}
               
void post_numeric(ContainerHandle chArray, int index, long value) {
  XPPAPIRET        xr;
  ContainerHandle hValue;
  hValue = _conPutNL(NULLCONTAINER,value);
  if (hValue != NULLCONTAINER) {
    xr = _conArrayPut(chArray, hValue, index, NULL);
    if (xr != 0) return;
  }
  _conRelease(hValue);
}

****/
               

/*
 *
 * EID_GET() => cInfo
 */
XPPRET XPPENTRY EID_GET(XppParamList paramList) {

    ContainerHandle chResult;
    ContainerHandle chArray;
    char s[4096] = {0};
    int i = 0;

    // Alround test buffer
    BYTE buffer[4096] = {0};
    BEID_Bytes tBytes = {0};

    BEID_Status tStatus = {0};
    BEID_ID_Data idData = {0};
    BEID_Address adData = {0};
    BEID_Certif_Check tCheck = {0};
    BEID_VersionInfo tVersion = {0};
    BEID_Raw tRawData = {0};

    long lHandle = 0;

    tBytes.length = 4096;
    tBytes.data = buffer;

    chResult = _conNew(NULLCONTAINER);
    chArray = _conNewArray(1, EID_ALEN);

    // post_numeric(chArray,EID_ERROR,0);

    // sprintf(s,"Card Number: %s\n\0x00", "foo");

    tStatus = BEID_Init("", 0, 0, &lHandle);

    // Read ID Data
    tStatus = BEID_GetID(&idData, &tCheck);

    if(tStatus.general == BEID_OK) {

      post_string(chArray,EID_CARDNUMBER, idData.cardNumber); // a[1] : card number
      post_string(chArray,EID_CHIPNUMBER, idData.chipNumber);
      post_string(chArray,EID_VALIDITY_BEGIN, idData.validityDateBegin);
      post_string(chArray,EID_VALIDITY_END,idData.validityDateEnd);
      post_string(chArray,EID_DELIVERY_MUNICIPALTIY,idData.municipality);
      post_string(chArray,EID_NATIONAL_NUMBER,idData.nationalNumber);
      post_string(chArray,EID_NAME,idData.name);
      post_string(chArray,EID_FIRSTNAME1,idData.firstName1);
      post_string(chArray,EID_FIRSTNAME2,idData.firstName2);
      post_string(chArray,EID_FIRSTNAME3,idData.firstName3);
      post_string(chArray,EID_NATIONALITY,idData.nationality);
      post_string(chArray,EID_BIRTHPLACE,idData.birthLocation);
      post_string(chArray,EID_BIRTHDATE,idData.birthDate);
      post_string(chArray,EID_GENDER,idData.sex);
      post_string(chArray,EID_NOBLE_CONDITION,idData.nobleCondition);
      post_long(chArray,EID_DOCTYPE,idData.documentType);
      post_logical(chArray,EID_WHITECANE,idData.whiteCane);
      post_logical(chArray,EID_YELLOWCANE,idData.yellowCane);
      post_logical(chArray,EID_EXTENDED_MINORITY,idData.extendedMinority);
      
//        sprintf(s,"Card Number: %s\r\n", idData.cardNumber);
//        sprintf(s,"Chip Number: %s\r\n", idData.chipNumber);
//        sprintf(s,"%-25s: %s - %s\n", "Validity",
//                idData.validityDateBegin,
//                idData.validityDateEnd);
      
//        sprintf(s,"Delivery Municipality: %s\r\n", idData.municipality);
//        sprintf(s,"National Number: %s\r\n", idData.nationalNumber);
//        sprintf(s,"Name: %s\r\n", idData.name);
//        sprintf(s,"First name 1:  %s\r\n", idData.firstName1);
//        sprintf(s,"First name 2:  %s\r\n", idData.firstName2);
//        sprintf(s,"First name 3:  %s\r\n", idData.firstName3);
//        sprintf(s,"Nationality: %s\r\n", idData.nationality);
//        sprintf(s,"Birthplace: %s\r\n", idData.birthLocation);
//        sprintf(s,"Birthdate: %s\r\n", idData.birthDate);
//        sprintf(s,"Gender: %s\r\n", idData.sex);
//        sprintf(s,"Noble Condition: %s\r\n", idData.nobleCondition);
//        sprintf(s,"%-25s: %d\n", "Document Type", idData.documentType);
//        sprintf(s,"Special Status: Whitecane: %s, Yellowcane: %s, Extendedminority: %s\n",
//                idData.whiteCane ? "TRUE" : "FALSE",
//                idData.yellowCane ? "TRUE" : "FALSE",
//                idData.extendedMinority ? "TRUE" : "FALSE");
//        sprintf(s,"\n");


      tStatus = BEID_GetAddress(&adData, &tCheck);
      if(tStatus.general == BEID_OK) {

        post_string(chArray,EID_STREET, adData.street);
        post_string(chArray,EID_NUMBER, adData.streetNumber);
        post_string(chArray,EID_BOX, adData.boxNumber);
        post_string(chArray,EID_ZIP, adData.zip);
        post_string(chArray,EID_MUNICIPALTIY, adData.municipality);
        post_string(chArray,EID_COUNTRY, adData.country);


        tStatus = BEID_GetPicture(&tBytes, &tCheck);
        if(tStatus.general == BEID_OK) {
          FILE *pf = fopen("photo.jpg", "w+b");
          if(pf != NULL)
            {
              fwrite(tBytes.data, sizeof(unsigned char),
                     tBytes.length, pf);
              fclose(pf);
            }
        } else {
          sprintf(s,"BEID_GetPicture() returned %d", tStatus.general);
          post_string(chArray,EID_ERROR,s);
        }
      } else {
        sprintf(s,"BEID_GetAddress() returned %d", tStatus.general);
        post_string(chArray,EID_ERROR,s);
      }
    } else {
      sprintf(s,"BEID_GetId() returned %d", tStatus.general);
      post_string(chArray,EID_ERROR,s);
    }



/************ for later

    // Read Address Data
    PrintStatus( "Get Address", tStatus );
    if(BEID_OK == tStatus.general)
    {
        PrintAddressData(&adData);
    }
    memset(&tCheck, 0, sizeof(BEID_Certif_Check));


    // Read Picture Data
    tStatus = BEID_GetPicture(&tBytes, &tCheck);
    PrintStatus( "Get Picture", tStatus );
    if(BEID_OK == tStatus.general)
    {
            FILE *pf = fopen("photo.jpg", "w+b");
        if(pf != NULL)
        {
                fwrite(tBytes.data, sizeof(unsigned char),
tBytes.length, pf);
            fclose(pf);
    }
        printf("Picture written in \"photo.jpg\". Launching picture file
...\n");
 //       system("start photo.jpg");
}
    memset(&tCheck, 0, sizeof(BEID_Certif_Check));

    // Re use buffer
    memset(buffer, 0, sizeof(buffer));
    tBytes.length = 4096;

   
********************/

   tStatus = BEID_Exit();


    // _conPutCL(chResult,s , sizeof(s) );
   // _conPutC(chResult,s);
   // _conReturn(paramList, chResult);
   // _conRelease(chResult);



   _conReturn( paramList, chArray ); 
   _conRelease( chArray ); 
   
   return;
}





