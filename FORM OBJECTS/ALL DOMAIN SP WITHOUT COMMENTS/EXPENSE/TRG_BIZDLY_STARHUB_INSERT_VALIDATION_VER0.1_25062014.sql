DROP TRIGGER IF EXISTS TRG_BIZDLY_STARHUB_INSERT_VALIDATION;
CREATE TRIGGER TRG_BIZDLY_STARHUB_INSERT_VALIDATION
BEFORE INSERT ON EXPENSE_STARHUB
FOR EACH ROW
BEGIN
    CALL SP_TRG_BIZDLY_EXPENSE_STARHUB_VALIDATION(NEW.ESH_INVOICE_DATE,NEW.ESH_FROM_PERIOD,NEW.ESH_TO_PERIOD,NEW.EDSH_ID,'INSERT');
END;