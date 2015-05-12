-- version:0.1 --sdate:25-06-2014 --edate:25-06-2014 --issue:593 --desc:ecnid,invoicedate validation --doneby:THIRUPATHI

DROP PROCEDURE IF EXISTS SP_TRG_PERSONAL_CAR_VALIDATION;
CREATE PROCEDURE SP_TRG_PERSONAL_CAR_VALIDATION(
IN NEWECNID INTEGER,
IN NEWINVOICEDATE DATE,
IN PROCESS TEXT)
BEGIN
    DECLARE MESSAGE_TEXT VARCHAR(50);
	IF(PROCESS = 'INSERT') OR (PROCESS = 'UPDATE') THEN
        IF(NEWINVOICEDATE > CURDATE()) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'EC_INVOICE_DATE SHOULD LESS THAN OR EQUAL TO TODAY DATE';
		END IF;
        IF(NEWECNID IS NOT NULL) THEN
            IF NOT EXISTS(SELECT ECN_ID FROM EXPENSE_CONFIGURATION WHERE ECN_ID = NEWECNID AND CGN_ID = 21)THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'ECN_ID IN BETWEEN 30 TO 34';
            END IF;
        END IF;
    END IF;
END;