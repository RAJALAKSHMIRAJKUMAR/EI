DROP TRIGGER IF EXISTS TRG_BIZDLY_PURCHASE_NEW_CARD_UPDATE_VALIDATION;
CREATE TRIGGER TRG_BIZDLY_PURCHASE_NEW_CARD_UPDATE_VALIDATION
BEFORE UPDATE ON EXPENSE_PURCHASE_NEW_CARD
FOR EACH ROW  
BEGIN
    CALL SP_TRG_BIZDLY_PURCHASE_NEW_CARD_VALIDATION(NEW.EPNC_NUMBER,NEW.UNIT_ID,NEW.EPNC_INVOICE_DATE,'UPDATE');
END;