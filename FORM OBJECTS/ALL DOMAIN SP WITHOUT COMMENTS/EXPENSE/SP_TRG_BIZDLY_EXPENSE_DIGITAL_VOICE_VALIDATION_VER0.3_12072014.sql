DROP PROCEDURE IF EXISTS SP_TRG_BIZDLY_EXPENSE_DIGITAL_VOICE_VALIDATION;
CREATE PROCEDURE SP_TRG_BIZDLY_EXPENSE_DIGITAL_VOICE_VALIDATION(
IN INVOICEDATE DATE,
IN FROMPERIOD DATE,
IN TOPERIOD DATE,
IN EDDVID INTEGER,
IN PROCESS TEXT
)
BEGIN
DECLARE TODAYDATE DATE;
DECLARE UNITID INTEGER;
DECLARE UNITSTARTDATE DATE;
DECLARE UNITMONTH INTEGER;
DECLARE MINDATE DATE;
DECLARE MAXDATE DATE;
DECLARE UNITENDDATE DATE;
DECLARE MESSAGE_TEXT TEXT;
SET UNITID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_ID=(SELECT UNIT_ID FROM EXPENSE_DETAIL_DIGITAL_VOICE WHERE EDDV_ID=EDDVID)); 
CALL SP_CONFIG_SDATE_EDATE(UNITID,@S_CONFIGDATE,@E_CONFIGDATE,@INVOICE_DATE);
SET UNITSTARTDATE=@S_CONFIGDATE;
SET UNITENDDATE=@E_CONFIGDATE;
SET MAXDATE=@INVOICE_DATE;
SET TODAYDATE=CURDATE();
IF (PROCESS='INSERT') OR (PROCESS='UPDATE') THEN
IF (INVOICEDATE>TODAYDATE) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='EDV_INVOICE_DATE SHOULD LESS THAN OR EQUAL TO TODAY DATE';
END IF;
SET MINDATE=UNITSTARTDATE;
IF INVOICEDATE NOT BETWEEN MINDATE AND MAXDATE THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='EDV_INVOICE_DATE SHOULD BETWEEN UNIT STARTDATE AND ENDDATE';
END IF;
IF FROMPERIOD NOT BETWEEN MINDATE AND INVOICEDATE THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT=' EDV_FROM_PERIOD SHOULD BETWEEN UNIT STARDATE AND INVOICEDATE';
END IF;
IF TOPERIOD NOT BETWEEN FROMPERIOD AND INVOICEDATE THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='EDV_TO_PERIOD SHOULD BETWEEN FROMPERIOD AND INVOICEDATE';
END IF;
END IF;
END;