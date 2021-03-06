DROP PROCEDURE IF EXISTS SP_TRG_CUSTOMER_COMPANY_DETAILS_VALIDATION;
CREATE PROCEDURE SP_TRG_CUSTOMER_COMPANY_DETAILS_VALIDATION(
IN NEWCCDPOSTALCODE VARCHAR(6),
IN NEWCCDOFFICENO VARCHAR(8),
IN PROCESS TEXT)
BEGIN
	DECLARE MESSAGE_TEXT VARCHAR(50);
	DECLARE ERRORMSG_POSTALCODE TEXT;
	DECLARE ERRORMSG_CONTACTNO TEXT;
	SET ERRORMSG_POSTALCODE=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=344);
	SET ERRORMSG_CONTACTNO=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=339);
	IF(PROCESS = 'INSERT') OR (PROCESS = 'UPDATE') THEN
		IF(LENGTH(NEWCCDPOSTALCODE)<5) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = ERRORMSG_POSTALCODE;
		END IF;
		IF(LENGTH(NEWCCDOFFICENO)<6) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = ERRORMSG_CONTACTNO;
		END IF;
	END IF;
END;
