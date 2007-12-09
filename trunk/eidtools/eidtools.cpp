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



void PrintIDData(BEID_ID_Data *pData)
{
    PRINT("Card Number", pData->cardNumber);
    PRINT("Chip Number", pData->chipNumber);
    printf("%-25s: %s - %s\n", "Validity",
           pData->validityDateBegin,
           pData->validityDateEnd);
    PRINTU(_T("Delivery Municipality"), pData->municipality);
    PRINT("National Number", pData->nationalNumber);
    PRINTU(_T("Name"), pData->name);
    PRINTU(_T("First name 1"), pData->firstName1);
    PRINTU(_T("First name 2"), pData->firstName2);
    PRINTU(_T("First name 3"), pData->firstName3);
    PRINT("Nationality", pData->nationality);
    PRINTU(_T("Birthplace"), pData->birthLocation);
    PRINT("Birthdate", pData->birthDate);
    PRINT("Gender", pData->sex);
    PRINTU(_T("Noble Condition"), pData->nobleCondition);
    printf("%-25s: %d\n", "Document Type", pData->documentType);
    printf("Special Status: Whitecane: %s, Yellowcane: %s, Extendedminority: %s\n",
      pData->whiteCane ? "TRUE" : "FALSE",
      pData->yellowCane ? "TRUE" : "FALSE",
    pData->extendedMinority ? "TRUE" : "FALSE");
    printf("\n");
}

void PrintAddressData(BEID_Address *pData)
{
    PRINTU(_T("Street"), pData->street);
    PRINT("Number", pData->streetNumber);
    PRINT("Box", pData->boxNumber);
    PRINT("Zip", pData->zip);
    PRINTU(_T("Municipality"), pData->municipality);
    PRINT("Country", pData->country);
    printf("\n");
}



/*
 *
 * EID_GET() => cInfo
 */
XPPRET XPPENTRY EID_GET(XppParamList paramList) {

    ContainerHandle chResult = _conNew(NULLCONTAINER);

    char s[4096] = {0};

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


    // sprintf(s,"Card Number: %s\n\0x00", "foo");

    tStatus = BEID_Init("", 0, 0, &lHandle);

    // Read ID Data
    tStatus = BEID_GetID(&idData, &tCheck);

    if(tStatus.general == BEID_OK)
    {
      sprintf(s,"Card Number: %s\r\n", idData.cardNumber);
      sprintf(s,"Chip Number: %s\r\n", idData.chipNumber);
      sprintf(s,"%-25s: %s - %s\n", "Validity",
              idData.validityDateBegin,
              idData.validityDateEnd);
      sprintf(s,"Delivery Municipality: %s\r\n", idData.municipality);
      sprintf(s,"National Number: %s\r\n", idData.nationalNumber);
      sprintf(s,"Name: %s\r\n", idData.name);
      sprintf(s,"First name 1:  %s\r\n", idData.firstName1);
      sprintf(s,"First name 2:  %s\r\n", idData.firstName2);
      sprintf(s,"First name 3:  %s\r\n", idData.firstName3);
      sprintf(s,"Nationality: %s\r\n", idData.nationality);
      sprintf(s,"Birthplace: %s\r\n", idData.birthLocation);
      sprintf(s,"Birthdate: %s\r\n", idData.birthDate);
      sprintf(s,"Gender: %s\r\n", idData.sex);
      sprintf(s,"Noble Condition: %s\r\n", idData.nobleCondition);
      sprintf(s,"%-25s: %d\n", "Document Type", idData.documentType);
      sprintf(s,"Special Status: Whitecane: %s, Yellowcane: %s, Extendedminority: %s\n",
              idData.whiteCane ? "TRUE" : "FALSE",
              idData.yellowCane ? "TRUE" : "FALSE",
              idData.extendedMinority ? "TRUE" : "FALSE");
      sprintf(s,"\n");
    } else 
      sprintf(s,"BEID_GetId() returned %d\r\n", tStatus.general);



/************ for later

    // Read Address Data
    tStatus = BEID_GetAddress(&adData, &tCheck);
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
   _conPutC(chResult,s);
   _conReturn(paramList, chResult);
   _conRelease(chResult);
   return;
}





