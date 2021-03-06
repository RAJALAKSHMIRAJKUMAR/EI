DROP PROCEDURE IF EXISTS SP_TRG_STAFFDLY_STAFF_VALIDATION;
CREATE PROCEDURE SP_TRG_STAFFDLY_STAFF_VALIDATION(
IN ECNID INTEGER,
IN INVOICEDATE DATE,
IN PROCESS TEXT)
BEGIN
	DECLARE MESSAGE_TEXT VARCHAR(50);
	IF(PROCESS = 'INSERT') OR (PROCESS = 'UPDATE') THEN
		IF(INVOICEDATE > CURDATE()) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'ES_INVOICE_DATE LESS THAN OR EQUAL TO TODAY DATE';
		END IF;
		IF NOT EXISTS(SELECT ECN_ID FROM EXPENSE_CONFIGURATION WHERE ECN_ID = ECNID AND CGN_ID = 26)THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'ECN_ID BETWEEN 25 TO 29';
		END IF;
	END IF;
END;