--issue no:593 startdate:26/06/2014 enddate:26/06/2014 COMMENT NO:100 DESC:VALIDATION FOR ACCESS CARD DETAILS DONE BY:DHIVYA


-- BEFORE INSERT TRIGGER FOR CUSTOMER_ACCESS_CARD_DETAILS
DROP TRIGGER IF EXISTS TRG_CUSTOMER_ACCESS_CARD_DETAILS_INSERT_VALIDATION;
CREATE TRIGGER TRG_CUSTOMER_ACCESS_CARD_DETAILS_INSERT_VALIDATION
BEFORE INSERT ON CUSTOMER_ACCESS_CARD_DETAILS
FOR EACH ROW
BEGIN
	CALL SP_TRG_CUSTOMER_ACCESS_CARD_DETAILS_VALIDATION(NEW.ACN_ID,'INSERT');
END;