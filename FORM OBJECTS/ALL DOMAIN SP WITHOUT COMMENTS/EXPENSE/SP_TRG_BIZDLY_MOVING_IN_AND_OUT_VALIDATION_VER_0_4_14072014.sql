DROP PROCEDURE IF EXISTS SP_TRG_BIZDLY_MOVING_IN_AND_OUT_VALIDATION;
CREATE PROCEDURE SP_TRG_BIZDLY_MOVING_IN_AND_OUT_VALIDATION(
IN NEWUNITID INTEGER,
IN NEWINVOICEDATE DATE,
IN PROCESS TEXT)
BEGIN
  DECLARE UNITSTARTDATE DATE;
  DECLARE UNITENDDATE DATE;
  DECLARE CONFIGENDDATE DATE;
  DECLARE MESSAGE_TEXT VARCHAR(50);
CALL SP_CONFIG_SDATE_EDATE(NEWUNITID,@S_CONFIGDATE,@E_CONFIGDATE,@INVOICE_DATE);  
SET UNITSTARTDATE=@S_CONFIGDATE;
  SET CONFIGENDDATE=@E_CONFIGDATE;
  SET UNITENDDATE=@INVOICE_DATE;
    IF(PROCESS = 'INSERT') OR (PROCESS='UPDATE')THEN  
		IF (NEWINVOICEDATE > CURDATE())THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT= 'EMIO_INVOICE_DATE SHOULD BE LESSER THAN OR EQUEL TO TODAY DATE';
		END IF;
		IF(NEWINVOICEDATE NOT BETWEEN UNITSTARTDATE AND UNITENDDATE)THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT= 'EMIO_INVOICE_DATE SHOULD BE BETWEEN THE UNIT STARTDATE AND UNIT ENDDATE';
		END IF;
    END IF;
END;