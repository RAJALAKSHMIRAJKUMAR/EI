-- VER 0.4 ISSUE NO:836  --COMMENTNO#3 STARTDATE:06/08/2014 ENDDATE:06/08/2014 DESC:GETTING ERROR MSG FROM CONFIG TABLE AND ADDED AMOUNT VALIDATION   DONE BY:SASIKALA
-- VER 0.3 ISSUE NO:593  --COMMENTNO#279 STARTDATE:12/07/2014 ENDDATE:12/07/2014 DESC:added invoice date parameter in SP_CONFIG_SDATE_EDATE   DONE BY:RL
-- version:0.2 --sdate:11-07-2014 --edate:11-07-2014 --issue:593 --commentno#225 --desc:IMPLEMENTED THE CONFIG STARTDATE AND ENDDATE --doneby:SASIKALA
-- version:0.1 --sdate:24-06-2014 --edate:25-06-2014 --issue:593 --commentno#75 --desc:ecnid,CUSTOMERID,invoicedate validation --doneby:RL
DROP PROCEDURE IF EXISTS SP_TRG_BIZDLY_EXPUNIT_VALIDATION;
CREATE PROCEDURE SP_TRG_BIZDLY_EXPUNIT_VALIDATION(
IN UNITID INTEGER,
IN NEWECNID INTEGER,
IN CUSTOMERID INTEGER,
IN INVOICEDATE DATE,
IN PROCESS TEXT)
BEGIN
	DECLARE MESSAGE_TEXT VARCHAR(50);
	DECLARE TODAYDATE DATE;
	DECLARE UNITSTARTDATE DATE;
	DECLARE UNITENDDATE DATE;
	DECLARE MINDATE DATE;
	DECLARE MAXDATE DATE;
  DECLARE ERRORMSG TEXT;
  DECLARE MSG TEXT;
  DECLARE EUAMT INTEGER;
-- FOR CALLING THE CONFIG STARTDATE AND ENDDATE
	CALL SP_CONFIG_SDATE_EDATE(UNITID,@S_CONFIGDATE,@E_CONFIGDATE,@INVOICE_DATE);
	SET UNITSTARTDATE=@S_CONFIGDATE;
	SET UNITENDDATE=@E_CONFIGDATE;
	SET MAXDATE = @INVOICE_DATE;
	SET TODAYDATE=CURDATE();
	IF (PROCESS='INSERT') OR (PROCESS='UPDATE') THEN
		IF INVOICEDATE > TODAYDATE THEN
    SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=474);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT=ERRORMSG;
		END IF;
		SET MINDATE=UNITSTARTDATE;
		IF INVOICEDATE NOT BETWEEN MINDATE AND MAXDATE THEN 
       SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=475);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT=ERRORMSG;
		END IF;
		IF(CUSTOMERID IS NOT NULL AND NEWECNID IS NOT NULL)THEN
			IF NOT EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER WHERE CUSTOMER_ID = CUSTOMERID) THEN
          SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=529);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERRORMSG;
			END IF;
			IF(NEWECNID!=23)THEN
         SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=530);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERRORMSG;
			END IF;
		END IF;
		IF(CUSTOMERID IS NULL)THEN
			IF NOT EXISTS(SELECT ECN_ID FROM EXPENSE_CONFIGURATION WHERE ECN_ID=NEWECNID AND ECN_ID IN (22,24,192))THEN
         SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=531);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERRORMSG;
			END IF;
		END IF;
    	END IF;
END;