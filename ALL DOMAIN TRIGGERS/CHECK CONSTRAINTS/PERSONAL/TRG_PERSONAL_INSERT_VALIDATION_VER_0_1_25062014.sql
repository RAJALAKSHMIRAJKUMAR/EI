-- version:0.1 --sdate:25-06-2014 --edate:25-06-2014 --issue:593 --desc:ecnid,invoicedate validation --doneby:THIRUPATHI
DROP TRIGGER IF EXISTS TRG_PERSONAL_INSERT_VALIDATION;
CREATE TRIGGER TRG_PERSONAL_INSERT_VALIDATION
BEFORE INSERT ON EXPENSE_PERSONAL
FOR EACH ROW
BEGIN
	CALL SP_TRG_PERSONAL_VALIDATION(NEW.ECN_ID,NEW.EP_INVOICE_DATE,'INSERT');
END;