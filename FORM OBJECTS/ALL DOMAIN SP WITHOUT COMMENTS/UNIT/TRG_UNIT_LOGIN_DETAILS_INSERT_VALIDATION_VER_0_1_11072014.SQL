DROP TRIGGER IF EXISTS TRG_UNIT_LOGIN_DETAILS_INSERT_VALIDATION;
CREATE TRIGGER TRG_UNIT_LOGIN_DETAILS_INSERT_VALIDATION
BEFORE INSERT ON UNIT_LOGIN_DETAILS
FOR EACH ROW
BEGIN
	CALL SP_TRG_UNIT_LOGIN_DETAILS_VALIDATION(NEW.ULDTL_DOORCODE,NEW.ULDTL_WEBLOGIN,'INSERT');
END;