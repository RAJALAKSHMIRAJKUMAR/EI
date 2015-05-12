DROP TRIGGER IF EXISTS TRG_BIZDLY_ELECTRICITY_INSERT_VALIDATION;
CREATE TRIGGER TRG_BIZDLY_ELECTRICITY_INSERT_VALIDATION
BEFORE INSERT ON EXPENSE_ELECTRICITY
FOR EACH ROW
BEGIN
	CALL SP_TRG_BIZDLY_EXPENSE_ELECTRICITY_VALIDATION(NEW.EE_INVOICE_DATE,NEW.EE_FROM_PERIOD,NEW.EE_TO_PERIOD,NEW.EDE_ID,NEW.ECN_ID,'INSERT');
END;