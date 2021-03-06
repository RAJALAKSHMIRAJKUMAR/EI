DROP TRIGGER IF EXISTS TRG_CHEQUE_ENTRY_DETAILS_UPDATE_VALIDATION;
CREATE TRIGGER TRG_CHEQUE_ENTRY_DETAILS_UPDATE_VALIDATION
BEFORE UPDATE ON CHEQUE_ENTRY_DETAILS
FOR EACH ROW
BEGIN
    CALL SP_TRG_CHEQUE_ENTRY_DETAILS_VALIDATION(NEW.CHEQUE_AMOUNT,'UPDATE');
END;