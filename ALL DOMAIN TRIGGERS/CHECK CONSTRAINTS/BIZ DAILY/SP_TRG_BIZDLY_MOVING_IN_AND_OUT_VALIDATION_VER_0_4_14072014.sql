-- VERSION 0.4 STARTDATE:14/07/2014 ENDDATE:14/07/2014 ISSUE NO: 593 COMMENT NO: 283 DESC:UPDATED THE VARIABLE UNITID TO NEWUNITID. DONE BY :SAFI
-- VERSION 0.3 STARTDATE:12/07/2014 ENDDATE:12/07/2014 ISSUE NO: 593 COMMENT NO: 283 DESC:IMPLEMENT INVOICE DATE CHANGES. DONE BY :BHAVANI.R
-- VERSION 0.2 STARTDATE:11/07/2014 ENDDATE:11/07/2014 ISSUE NO: 593 DESC:IMPLEMENT CONFIG UNIT STARTDATE ENDDATE. DONE BY :RAJA
-- VERSION 0.1 STARTDATE:26/06/2014 ENDDATE:26/06/2014 ISSUE NO: 593 DESC:THROWING ERROR MSG FOR THE CHECK CONSTRAINS. DONE BY :RAJA
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