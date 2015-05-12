DROP PROCEDURE IF EXISTS SP_TRG_BIZDLY_CARPARK_VALIDATION;
CREATE PROCEDURE SP_TRG_BIZDLY_CARPARK_VALIDATION(
IN EDCPID INTEGER,
IN INVOICEDATE DATE,
IN FROMPERIOD DATE,
IN TOPERIOD DATE,
IN PROCESS TEXT)
BEGIN
	DECLARE MESSAGE_TEXT VARCHAR(50);
	DECLARE TODAYDATE DATE;
	DECLARE UNITID INTEGER;
	DECLARE UNITSTARTDATE DATE;
 	DECLARE UNITENDDATE DATE;
	DECLARE MINDATE DATE;
	DECLARE MAXDATE DATE;
	SET UNITID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_ID=(SELECT UNIT_ID FROM EXPENSE_DETAIL_CARPARK WHERE EDCP_ID = EDCPID)); 
	CALL SP_CONFIG_SDATE_EDATE(UNITID,@S_CONFIGDATE,@E_CONFIGDATE,@INVOICE_DATE);
	SET UNITSTARTDATE=@S_CONFIGDATE;
	SET UNITENDDATE=@E_CONFIGDATE;
	SET MAXDATE=@INVOICE_DATE;
	SET TODAYDATE=CURDATE();
	IF (PROCESS='INSERT') OR (PROCESS='UPDATE') THEN
		IF INVOICEDATE > TODAYDATE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='ECP_INVOICE_DATE SHOULD LESS THAN OR EQUAL TO TODAY DATE';
		END IF;
		SET MINDATE=UNITSTARTDATE;
		IF INVOICEDATE NOT BETWEEN MINDATE AND MAXDATE THEN 
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='ECP_INVOICE_DATE SHOULD BETWEEN UNIT STARTDATE AND ENDDATE';
		END IF;
		IF FROMPERIOD NOT BETWEEN MINDATE AND UNITENDDATE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT=' ECP_FROM_PERIOD SHOULD BETWEEN UNIT STARDATE AND ENDDATE';
		END IF;
		IF TOPERIOD NOT BETWEEN FROMPERIOD AND UNITENDDATE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='ECP_TO_PERIOD SHOULD BETWEEN FROMPERIOD AND UNIT ENDDATE';
		END IF;
	END IF;
END;