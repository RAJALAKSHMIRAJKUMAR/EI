-- VERSION:0.4 --SDATE:29-09-2014 --EDATE:29-09-2014 --ISSUE:593 --COMMENT NO#364,367 --DESC:changed the date format"DD-MM-YYYY" for frm n to period date --DONEBY:RL
-- VERSION: 0.3 --SDATE:23/09/2014 --EDATE:23/09/2014 --ISSUE:593 --COMMENTNO#347 --DESC:PERIOD RANGE SHOULD NOT REPEAT, EACH MONTH SHOULD HAVE ONE ENTRY --DONEBY:RL
-- version:0.2 --sdate:09/08/2014 --edate:09/08/2014 --issue:836 --desc:error msg getting from config db --doneby:RL
-- VERSION:0.1 -- STARTDATE:25/06/2014 -- ENDDATE:25/06/2014 -- ISSUE NO:595 -- COMMENT NO:89 -- DESC CREATING TRIGGER SP FOR INSERTING AND UPDATING IN EXPENSE_STAFF_SALARY -- DONE BY:BHAVANI.R

DROP PROCEDURE IF EXISTS SP_TRG_STAFFDLY_SALARY_VALIDATION;
CREATE PROCEDURE SP_TRG_STAFFDLY_SALARY_VALIDATION(
IN NEW_ESS_ID INTEGER,
IN NEW_EDSS_ID INTEGER,
IN NEW_INVOICE_DATE DATE,
IN NEW_FROM_PERIOD DATE,
IN NEW_TO_PERIOD DATE,
IN PROCESS TEXT)

BEGIN

	DECLARE MESSAGE_TEXT VARCHAR(50);
	DECLARE ERROR_MSG TEXT;

	DECLARE INVOICEDATE_MONTH INTEGER;
	DECLARE INVOICEDATE_MONTH_LENGTH INTEGER;
	DECLARE INVOICEDATE_YEAR INTEGER;
	DECLARE INVOICEDATE_MONTHNAME TEXT;
	DECLARE INVOICEDATE_MONTH_YEAR VARCHAR(20);
	DECLARE FIRSTDAY_INVOICEDATE DATE;
	DECLARE LASTDAY_INVOICEDATE DATE;

	DECLARE FROMPERIOD_MONTH INTEGER;
	DECLARE FROMPERIOD_MONTH_LENGTH INTEGER;
	DECLARE FROMPERIOD_YEAR INTEGER;
	DECLARE FIRSTDAY_FROMPERIOD DATE;
	DECLARE FIRSTDAYFROMPERIOD VARCHAR(25);
	DECLARE LASTDAY_FROMPERIOD DATE;
	DECLARE LASTDAYFROMPERIOD VARCHAR(25);

	DECLARE TOPERIOD_MONTH INTEGER;
	DECLARE TOPERIOD_MONTH_LENGTH INTEGER;
	DECLARE TOPERIOD_YEAR INTEGER;
	DECLARE FIRSTDAY_TOPERIOD DATE;
	DECLARE FIRSTDAYTOPERIOD VARCHAR(25);
	DECLARE LASTDAY_TOPERIOD DATE;
	DECLARE LASTDAYTOPERIOD VARCHAR(25);

	SET INVOICEDATE_MONTH = (SELECT MONTH(NEW_INVOICE_DATE));

	SET INVOICEDATE_MONTH_LENGTH = (SELECT LENGTH(INVOICEDATE_MONTH));
	IF(INVOICEDATE_MONTH_LENGTH <= 1) THEN
		SET INVOICEDATE_MONTH = (SELECT CONCAT('0',INVOICEDATE_MONTH));
	ELSE
		SET INVOICEDATE_MONTH = INVOICEDATE_MONTH;
	END IF;

	SET INVOICEDATE_YEAR = (SELECT YEAR(NEW_INVOICE_DATE));

	SET INVOICEDATE_MONTHNAME = (SELECT UCASE(MONTHNAME(STR_TO_DATE(INVOICEDATE_MONTH, '%m'))));

	SET INVOICEDATE_MONTH_YEAR = (SELECT CONCAT(INVOICEDATE_MONTHNAME,'-',INVOICEDATE_YEAR));

	SET FIRSTDAY_INVOICEDATE = (SELECT CONCAT(INVOICEDATE_YEAR,'-',INVOICEDATE_MONTH,'-','01'));

	SET LASTDAY_INVOICEDATE = (SELECT LAST_DAY(FIRSTDAY_INVOICEDATE));

	SET FROMPERIOD_MONTH = (SELECT MONTH(NEW_FROM_PERIOD));

	SET FROMPERIOD_MONTH_LENGTH = (SELECT LENGTH(FROMPERIOD_MONTH));
	IF(FROMPERIOD_MONTH_LENGTH <= 1) THEN
		SET FROMPERIOD_MONTH = (SELECT CONCAT('0',FROMPERIOD_MONTH));
	ELSE
		SET FROMPERIOD_MONTH = FROMPERIOD_MONTH;
	END IF;

	SET FROMPERIOD_YEAR = (SELECT YEAR(NEW_FROM_PERIOD));

	SET FIRSTDAY_FROMPERIOD = (SELECT CONCAT(FROMPERIOD_YEAR,'-',FROMPERIOD_MONTH,'-','01'));

	SET FIRSTDAYFROMPERIOD = (SELECT DATE_FORMAT(FIRSTDAY_FROMPERIOD, '%d-%m-%Y'));

	SET LASTDAY_FROMPERIOD = (SELECT LAST_DAY(FIRSTDAY_FROMPERIOD));

	SET LASTDAYFROMPERIOD = (SELECT DATE_FORMAT(LASTDAY_FROMPERIOD, '%d-%m-%Y'));
	
	SET TOPERIOD_MONTH = (SELECT MONTH(NEW_TO_PERIOD));

	SET TOPERIOD_MONTH_LENGTH = (SELECT LENGTH(TOPERIOD_MONTH));

	IF(TOPERIOD_MONTH_LENGTH <= 1) THEN
		SET TOPERIOD_MONTH = (SELECT CONCAT('0',TOPERIOD_MONTH));
	ELSE
		SET TOPERIOD_MONTH = TOPERIOD_MONTH;
	END IF;

	SET TOPERIOD_YEAR = (SELECT YEAR(NEW_TO_PERIOD));

	SET FIRSTDAY_TOPERIOD = (SELECT CONCAT(TOPERIOD_YEAR,'-',TOPERIOD_MONTH,'-','01'));

	SET FIRSTDAYTOPERIOD = (SELECT DATE_FORMAT(FIRSTDAY_TOPERIOD, '%d-%m-%Y'));

	SET LASTDAY_TOPERIOD = (SELECT LAST_DAY(FIRSTDAY_TOPERIOD));

	SET LASTDAYTOPERIOD = (SELECT DATE_FORMAT(LASTDAY_TOPERIOD, '%d-%m-%Y'));
	
	IF(PROCESS = 'INSERT') THEN

		IF(NEW_INVOICE_DATE IS NOT NULL) THEN

			IF(NEW_INVOICE_DATE > CURDATE()) THEN

				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 474);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
			
			IF EXISTS(SELECT ESS_INVOICE_DATE FROM EXPENSE_STAFF_SALARY WHERE EDSS_ID = NEW_EDSS_ID AND 
			ESS_INVOICE_DATE BETWEEN FIRSTDAY_INVOICEDATE AND LASTDAY_INVOICEDATE) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 574);
				SET ERROR_MSG = (SELECT REPLACE(ERROR_MSG,'[MONTH]',INVOICEDATE_MONTH_YEAR));
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
		
		END IF;
		
		IF(NEW_FROM_PERIOD IS NOT NULL) THEN
			
			IF(NEW_FROM_PERIOD >= NEW_INVOICE_DATE) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 512);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
			
			IF EXISTS(SELECT ESS_FROM_PERIOD FROM EXPENSE_STAFF_SALARY WHERE EDSS_ID = NEW_EDSS_ID AND 
			ESS_FROM_PERIOD BETWEEN FIRSTDAY_FROMPERIOD AND LASTDAY_FROMPERIOD) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 575);
				SET ERROR_MSG = (SELECT REPLACE(ERROR_MSG,'[SDATE]',FIRSTDAYFROMPERIOD));
				SET ERROR_MSG = (SELECT REPLACE(ERROR_MSG,'[EDATE]',LASTDAYFROMPERIOD));
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
		
		END IF;
		
		IF(NEW_TO_PERIOD IS NOT NULL) THEN
			
			IF(NEW_TO_PERIOD < NEW_FROM_PERIOD) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 513);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
			
			IF(NEW_TO_PERIOD >= NEW_INVOICE_DATE) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 514);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
			
			IF EXISTS(SELECT ESS_TO_PERIOD FROM EXPENSE_STAFF_SALARY WHERE EDSS_ID = NEW_EDSS_ID AND 
			ESS_TO_PERIOD BETWEEN FIRSTDAY_TOPERIOD AND LASTDAY_TOPERIOD) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 576);
				SET ERROR_MSG = (SELECT REPLACE(ERROR_MSG,'[SDATE]',FIRSTDAYTOPERIOD));
				SET ERROR_MSG = (SELECT REPLACE(ERROR_MSG,'[EDATE]',LASTDAYTOPERIOD));
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
		
		END IF;
	
	END IF;
	
	IF(PROCESS = 'UPDATE') THEN
		
		IF(NEW_INVOICE_DATE IS NOT NULL) THEN
			
			IF(NEW_INVOICE_DATE > CURDATE()) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 474);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
			
			IF EXISTS(SELECT ESS_INVOICE_DATE FROM EXPENSE_STAFF_SALARY WHERE EDSS_ID = NEW_EDSS_ID AND 
			ESS_INVOICE_DATE BETWEEN FIRSTDAY_INVOICEDATE AND LASTDAY_INVOICEDATE AND ESS_ID!=NEW_ESS_ID) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 574);
				SET ERROR_MSG = (SELECT REPLACE(ERROR_MSG,'[MONTH]',INVOICEDATE_MONTH_YEAR));
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
		
		END IF;
		
		IF(NEW_FROM_PERIOD IS NOT NULL) THEN
			
			IF(NEW_FROM_PERIOD >= NEW_INVOICE_DATE) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 512);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
			
			IF EXISTS(SELECT ESS_FROM_PERIOD FROM EXPENSE_STAFF_SALARY WHERE EDSS_ID = NEW_EDSS_ID AND 
			ESS_FROM_PERIOD BETWEEN FIRSTDAY_FROMPERIOD AND LASTDAY_FROMPERIOD AND ESS_ID!=NEW_ESS_ID) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 575);
				SET ERROR_MSG = (SELECT REPLACE(ERROR_MSG,'[SDATE]',FIRSTDAYFROMPERIOD));
				SET ERROR_MSG = (SELECT REPLACE(ERROR_MSG,'[EDATE]',LASTDAYFROMPERIOD));
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
		
		END IF;
		
		IF(NEW_TO_PERIOD IS NOT NULL) THEN
			
			IF(NEW_TO_PERIOD < NEW_FROM_PERIOD) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 513);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
			
			IF(NEW_TO_PERIOD >= NEW_INVOICE_DATE) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 514);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
			
			IF EXISTS(SELECT ESS_TO_PERIOD FROM EXPENSE_STAFF_SALARY WHERE EDSS_ID = NEW_EDSS_ID AND 
			ESS_TO_PERIOD BETWEEN FIRSTDAY_TOPERIOD AND LASTDAY_TOPERIOD AND ESS_ID!=NEW_ESS_ID) THEN
				
				SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 576);
				SET ERROR_MSG = (SELECT REPLACE(ERROR_MSG,'[SDATE]',FIRSTDAYTOPERIOD));
				SET ERROR_MSG = (SELECT REPLACE(ERROR_MSG,'[EDATE]',LASTDAYTOPERIOD));
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERROR_MSG;
			
			END IF;
		
		END IF;
	
	END IF;

END;
