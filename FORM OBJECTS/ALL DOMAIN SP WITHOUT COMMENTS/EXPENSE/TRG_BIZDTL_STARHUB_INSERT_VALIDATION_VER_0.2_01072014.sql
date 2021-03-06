DROP TRIGGER IF EXISTS TRG_BIZDTL_STARHUB_INSERT_VALIDATION;
CREATE TRIGGER TRG_BIZDTL_STARHUB_INSERT_VALIDATION
BEFORE INSERT ON EXPENSE_DETAIL_STARHUB
FOR EACH ROW
BEGIN
	CALL SP_TRG_BIZDTL_STARHUB_VALIDATION(NULL,NULL,NEW.UNIT_ID,NEW.ECN_ID,NEW.EDSH_APPL_DATE,NEW.EDSH_CABLE_START_DATE,NEW.EDSH_CABLE_END_DATE,NEW.EDSH_INTERNET_START_DATE,NEW.EDSH_INTERNET_END_DATE,'INSERT');
END;