DROP TRIGGER IF EXISTS TRG_CUSTOMER_COMPANY_DETAILS_UPDATE_VALIDATION;
CREATE TRIGGER TRG_CUSTOMER_COMPANY_DETAILS_UPDATE_VALIDATION
BEFORE UPDATE ON CUSTOMER_COMPANY_DETAILS
FOR EACH ROW
BEGIN
	CALL SP_TRG_CUSTOMER_COMPANY_DETAILS_VALIDATION(NEW.CCD_POSTAL_CODE,NEW.CCD_OFFICE_NO,'UPDATE');
END;