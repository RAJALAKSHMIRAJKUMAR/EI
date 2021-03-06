-- version:0.1 --sdate:25-06-2014 --edate:25-06-2014 --issue:593 --commentno#75 --desc:TRIGGER FOR BEFORE INSERT --doneby:DHIVYA


-- TRIGGER FOR BEFORE INSERT VALIDATION
DROP TRIGGER IF EXISTS TRG_BIZDLY_DIGITAL_VOICE_INSERT_VALIDATION;
CREATE TRIGGER TRG_BIZDLY_DIGITAL_VOICE_INSERT_VALIDATION
BEFORE INSERT ON EXPENSE_DIGITAL_VOICE
FOR EACH ROW
BEGIN
    CALL SP_TRG_BIZDLY_EXPENSE_DIGITAL_VOICE_VALIDATION(NEW.EDV_INVOICE_DATE,NEW.EDV_FROM_PERIOD,NEW.EDV_TO_PERIOD,NEW.EDDV_ID,'INSERT');
END;