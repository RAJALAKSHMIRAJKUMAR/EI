DROP TRIGGER IF EXISTS TRG_BIZDLY_HOUSEKEEPING_PAYMENT_UPDATE_VALIDATION;
CREATE TRIGGER TRG_BIZDLY_HOUSEKEEPING_PAYMENT_UPDATE_VALIDATION
BEFORE UPDATE ON EXPENSE_HOUSEKEEPING_PAYMENT
FOR EACH ROW
BEGIN
	CALL SP_TRG_BIZDLY_HOUSEKEEPING_PAYMENT_VALIDATION(NEW.UNIT_ID,NEW.EHKU_ID,NEW.EHKP_FOR_PERIOD,NEW.EHKP_PAID_DATE,'UPDATE');
END;