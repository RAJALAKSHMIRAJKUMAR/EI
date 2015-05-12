-- version:0.1 --sdate:25-06-2014 --edate:25-06-2014 --issue:593 --desc:ecnid,invoicedate validation --doneby:THIRUPATHI
DROP TRIGGER IF EXISTS TRG_PERSONAL_CAR_UPDATE_VALIDATION;
CREATE TRIGGER TRG_PERSONAL_CAR_UPDATE_VALIDATION
BEFORE UPDATE ON EXPENSE_CAR
FOR EACH ROW
BEGIN
	CALL SP_TRG_PERSONAL_CAR_VALIDATION(NEW.ECN_ID,NEW.EC_INVOICE_DATE,'UPDATE');
END;