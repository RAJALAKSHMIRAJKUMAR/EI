DROP PROCEDURE IF EXISTS SP_TRG_CHEQUE_ENTRY_DETAILS_VALIDATION;
CREATE PROCEDURE SP_TRG_CHEQUE_ENTRY_DETAILS_VALIDATION(
IN CHKAMT INTEGER(20),
IN PROCESS TEXT)
BEGIN
	DECLARE MESSAGE_TEXT VARCHAR(50);
	IF(PROCESS = 'INSERT') OR (PROCESS='UPDATE') THEN
		IF CHKAMT IS NOT NULL THEN
			SET @CHK_AMT=(SELECT SUBSTRING_INDEX(CHKAMT, '.', 1));
				IF(LENGTH(@CHK_AMT) > 5) THEN
					SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = 'CHEQUE_AMOUNT SHOULD BE LESS THAN OR EQUAL TO 5 DIGITS !!!';
				END IF;
		END IF;
	END IF;
END;