DROP PROCEDURE IF EXISTS SP_TRG_CUSTOMER_ACCESS_CARD_DETAILS_VALIDATION;
CREATE PROCEDURE SP_TRG_CUSTOMER_ACCESS_CARD_DETAILS_VALIDATION(
IN NEWACNID INTEGER,
IN PROCESS TEXT)
BEGIN
DECLARE MESSAGE_TEXT VARCHAR(50);
	IF(PROCESS = 'INSERT') THEN
		IF NEWACNID IS NOT NULL THEN
			IF NOT EXISTS(SELECT ACN_ID FROM ACCESS_CONFIGURATION WHERE ACN_ID=NEWACNID) THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'ACN_ID NOT IN ACCESS_CONFIGURATION';
			END IF;
		END IF;
	END IF;
	IF(PROCESS = 'UPDATE') THEN
		IF NEWACNID IS NOT NULL THEN
			IF NOT EXISTS(SELECT ACN_ID FROM ACCESS_CONFIGURATION WHERE ACN_ID=NEWACNID) THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'ACN_ID NOT IN ACCESS_CONFIGURATION';
			END IF;
		END IF;
	END IF;
END;