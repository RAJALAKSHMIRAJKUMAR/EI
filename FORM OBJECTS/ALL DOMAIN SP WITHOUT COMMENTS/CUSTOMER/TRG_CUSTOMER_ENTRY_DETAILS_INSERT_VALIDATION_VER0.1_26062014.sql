DROP TRIGGER IF EXISTS TRG_CUSTOMER_ENTRY_DETAILS_INSERT_VALIDATION;
CREATE TRIGGER TRG_CUSTOMER_ENTRY_DETAILS_INSERT_VALIDATION
BEFORE INSERT ON CUSTOMER_ENTRY_DETAILS
FOR EACH ROW
BEGIN
	CALL SP_TRG_CUSTOMER_ENTRY_DETAILS_VALIDATION(NEW.CED_ID,NEW.CUSTOMER_ID,NEW.CED_REC_VER,'INSERT');
END;