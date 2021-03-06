-- VER 0.5 ISSUE NO:836  STARTDATE:06/08/2014 ENDDATE:06/08/2014 DESC:GETTING ERROR MESSAGE FROM CONFIG TABLE AND ADDED AMOUNT VALIDATION DONE BY:SASIKALA
-- VER 0.4 ISSUE NO:593  COMMENT NO#279 STARTDATE:12/07/2014 ENDDATE:12/07/2014 DESC:added invoice date parameter in SP_CONFIG_SDATE_EDATE   DONE BY:RL
-- VER 0.3 ISSUE NO:593  STARTDATE:11/07/2014 ENDDATE:11/07/2014 DESC:IMPLEMENTED CONFIG STARTDATE AND ENDDATE DONE BY:SASIKALA
-- VER 0.2 ISSUE NO:593  STARTDATE:26/06/2014 ENDDATE:26/06/2014 DESC:CHANGING SP NAME DONE BY:SASIKALA
-- VER 0.1 ISSUE NO:593  STARTDATE:25/06/2014 ENDDATE:25/06/2014 DESC:THROWING ERROR MESSAGE FOR EXPENSE PURCHASE NEW CARD DONE BY:SASIKALA

DROP PROCEDURE IF EXISTS SP_TRG_BIZDLY_PURCHASE_NEW_CARD_VALIDATION;
CREATE PROCEDURE SP_TRG_BIZDLY_PURCHASE_NEW_CARD_VALIDATION(
IN EPNCNO INTEGER,
IN UNITID INTEGER,
IN INVOICEDATE DATE,
IN PROCESS TEXT)
BEGIN
	DECLARE MESSAGE_TEXT VARCHAR(50);
	DECLARE STARTDATE DATE;
	DECLARE ENDDATE DATE;
	DECLARE MINDATE DATE;
	DECLARE MAXDATE DATE;
  DECLARE ERRORMSG TEXT;
  DECLARE EPNCAMT INTEGER;
  DECLARE MSG TEXT;
-- FOR CALLING CONFIG STARTDATE AND ENDDATE
	CALL SP_CONFIG_SDATE_EDATE(UNITID,@S_CONFIGDATE,@E_CONFIGDATE,@INVOICE_DATE);
 	SET STARTDATE=@S_CONFIGDATE;
	SET ENDDATE=@E_CONFIGDATE;
	SET MAXDATE = @INVOICE_DATE;
	IF(PROCESS='INSERT') OR (PROCESS='UPDATE') THEN
-- CHECKING THE CONDITION FOR EPNC NO SHOULD BE LESS THAN 7
		IF(EPNCNO IS NOT NULL) THEN
			IF(LENGTH(EPNCNO) > 7) THEN
      SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=534);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERRORMSG;
			END IF;
		END IF;
-- CHECKING CONDITION FOR INVOICE DATE LESS THAN CURRENT DATE    
		IF(INVOICEDATE > CURDATE()) THEN
      SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=474);
			SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = ERRORMSG;
		END IF;
		SET MINDATE=STARTDATE;
-- CHECKING CONDITION FOR INVOICE DATE BETWEEN STARTDATE AND ENDDATE
		IF(INVOICEDATE NOT BETWEEN MINDATE AND MAXDATE) THEN
    SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=475);
			SIGNAL SQLSTATE '45000'
			   SET MESSAGE_TEXT = ERRORMSG;
		END IF;
    	  END IF;  
END;   