Customer:[=PAR->IdPar]
{
        FirstName:      "[=trim(PAR->Vorname)]"
        LastName:       "[=trim(PAR->Firme)]"
        Address:        "[=trim(ParStreet())]"
        ZipCode:        "[=trim(PAR->CP)]"
        City:           "[=trim(PlzName(PAR->Pays,PAR->CP))]"
        State:          ""
        Country:        "[=trim(PAR->Pays)]"
        Title:          "[=trim(PAR->Allo)]"
        Company:        "[=trim(PAR->Firme)]"
        Department:     "[=trim(PAR->Name2)]"
        Office:         ""
	Assistant:     	""
        PhoneBusiness:  "[=trim(PAR->Tel)]"
        PhoneBusiness2: ""
        PhoneFax:       "[=trim(PAR->Fax)]"
        PhoneAssistant: ""
        EMail:          ""
        URL:            ""
        VATNum:         "[=strtran(trim(substr(PAR->NoTva,4)),".")]"
        VATFormat:      "[=left(PAR->NoTva,2)]"
        BankNum:        "[=trim(PAR->Compte1)]"
        BankFormat:     "[=trim(PAR->Pays)]"
	Language:      	0
        CrcyID:         "[=trim(PAR->IdDev)]"
        Category:       ""
        Memo:           ""
        [*ImputAcctID:    ""]
	CtrzAcctID:    	""
	SuppID:        	""
	MaxRecallLevel:	4
        DueDateID:      "[=trim(PAR->IdMfc)]"
	PayType:       	"HB"
	[*Mask:          	"1C2N53NIOO"]
	ToReestimate:  	Y
	MultipleCrcy:  	Y
}
