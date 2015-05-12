DROP TRIGGER IF EXISTS TRG_BIZDTL_DIGITAL_VOICE_UPDATE_VALIDATION;
CREATE TRIGGER TRG_BIZDTL_DIGITAL_VOICE_UPDATE_VALIDATION
BEFORE UPDATE ON EXPENSE_DETAIL_DIGITAL_VOICE
FOR EACH ROW
BEGIN
	CALL SP_TRG_BIZDTL_DIGITAL_VOICE_VALIDATION(OLD.EDDV_ID,NULL,NEW.ECN_ID,'UPDATE');
END;