-- version:0.1 --sdate:26-06-2014 --edate:26-06-2014 --issue:593 --desc:ccdpostalcode,ccdofficeno validation --doneby:THIRUPATHI

DROP TRIGGER IF EXISTS TRG_CUSTOMER_COMPANY_DETAILS_INSERT_VALIDATION;
CREATE TRIGGER TRG_CUSTOMER_COMPANY_DETAILS_INSERT_VALIDATION
BEFORE INSERT ON CUSTOMER_COMPANY_DETAILS
FOR EACH ROW
BEGIN
	CALL SP_TRG_CUSTOMER_COMPANY_DETAILS_VALIDATION(NEW.CCD_POSTAL_CODE,NEW.CCD_OFFICE_NO,'INSERT');
END;