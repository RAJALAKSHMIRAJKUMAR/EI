-- VER 1.3 STARTDATE:23/09/2014 ENDDATE:23/09/2014 ISSUE:836 CMT:52 DESC:HARDCODED ERROR MSG GET FROM CONFIG DB DONE BY :DHIVYA
-- VER 1.2 STARTDATE:01/08/2014 ENDDATE:01/08/2014 DESC:IMPLEMENTED AUTOCOMMIT DONE BY :DHIVYA
--VER 1.1 STARTDATE:18/06/2014 ENDDATE:18/06/2014 DESC:RENAMED RECVERSION TO LEASEPERIOD IN PAYMENT UPDATE ERROR MESSAGE DONE BY KUMAR R
--VER 1.0 STARTDATE:10/06/2014 ENDDATE:10/06/2014 ISSUENO:566 COMMENTNO:#12 DESC:ADDED ROLLBACK AND COMMIT DONE BY:SASIKALA
--VER 0.9 STARTDATE:04/04/2014 ENDDATE:04/04/2014 ISSUENO:797 COMMENTNO:#4 DESC:REPLACED HEADER ND TABLE NAME DONE BY:LALITHA
--version 0.8 --sdate:28/02/2014 --edate:28/02/2014 --issue:754 --comment:36 --doneby:RL	
--version 0.7 --sdate:27/02/2014 --edate:27/02/2014 --issue:754 --comment:22 --doneby:RL	
--ver 0.6, startdate:26/02/2014 --enddate:26/02/2014--- issueno 750 commentno:36-->desc: REPLACE PD_USERSTAMP TO ULD_ID --doneby:balaji
-- VER:0.5, TRACKER:593  ,START DATE: 24-02-2014, END DATE: 24-02-2014, DESC: PAID_DATE column not available in Updation Query so included paid date column in updation query.  DONE BY: MANIKANDAN S
-- VER:0.4, TRACKER:593  ,START DATE: 21-02-2014, END DATE: 21-02-2014, DESC: FIXED ISSUE, UPDATION NOT OCCURS.  DONE BY: MANIKANDAN S
-- VER:0.3, TRACKER:593  ,START DATE: 14-02-2014, END DATE: 14-02-2014, DESC: changed the logic,single inputs only will come for all argument so removed looping conditions, DONE BY: MANIKANDAN S
-- VER:0.2, TRACKER:593  ,START DATE: 13-02-2014, END DATE: 13-02-2014, DESC: SENDING ERROR MESSAGE TO FRONT END, DONE BY: MANIKANDAN S
-- ver 0.1 start date:25/12/2013 end date:28/12/2013 issue no:637 comment no:#7 desc:sp for PAYMENT_DETAILS UPDATE done by:DHIVYA.A



DROP PROCEDURE IF EXISTS SP_PAYMENT_DETAIL_UPDATE;
CREATE PROCEDURE SP_PAYMENT_DETAIL_UPDATE(IN INPUT_PDID INTEGER,IN UNITNO SMALLINT,
IN CUSTOMERID INTEGER,IN PAYMENTTYPE VARCHAR(50),IN RECVERSION INTEGER,AMOUNT DECIMAL(7,2),FORPERIOD VARCHAR(50),
IN PAIDDATE DATE,IN HIGHLIGHTFLAG CHAR(1),IN COMMENTS TEXT,IN USERSTAMP VARCHAR(50), OUT OUTPUT_FINAL_MESSAGE TEXT)
BEGIN 
DECLARE FOR_PERIOD_YEAR VARCHAR(20);
DECLARE FOR_PERIOD_MONTH VARCHAR(20);
DECLARE FOR_PERIOD_MONTHNO INTEGER;
DECLARE STARTDATE DATE;
DECLARE ENDDATE DATE;
DECLARE PRE_DATE DATE;
DECLARE FOR_PERIOD_DATE DATE;
DECLARE MONTH_LENGTH INTEGER;
DECLARE STARTDATE_MONTH INTEGER;
DECLARE STARTDATE_LENGTH INTEGER;
DECLARE PRETERMINATEDATE DATE;
DECLARE FLAG INTEGER;
DECLARE MESSAGE TEXT DEFAULT '';
DECLARE FINAL_MESSAGE TEXT DEFAULT '';
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE ERRORMSG TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
SET AUTOCOMMIT=0;
START TRANSACTION;
SET FOR_PERIOD_YEAR=(SELECT SUBSTRING_INDEX(FORPERIOD,'-',-1));
SET FOR_PERIOD_MONTH=(SELECT SUBSTRING(FORPERIOD,1,3));
SET FOR_PERIOD_MONTHNO=(select month(str_to_date(FOR_PERIOD_MONTH,'%b')));
SET MONTH_LENGTH=(SELECT LENGTH(FOR_PERIOD_MONTHNO));
SET STARTDATE_MONTH=(SELECT MONTH(CLP_STARTDATE) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND 
CED_REC_VER=RECVERSION AND CLP_GUEST_CARD IS NULL);
SET STARTDATE_LENGTH=(SELECT LENGTH(STARTDATE_MONTH));
SET FOR_PERIOD_DATE=(select concat((select SUBSTRING_INDEX(FORPERIOD, '-', -1)),'-',FOR_PERIOD_MONTHNO,'-','01'));
IF  (STARTDATE_LENGTH=1) THEN
	SET STARTDATE=(SELECT CONCAT((SELECT YEAR(CLP_STARTDATE) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND 
	CED_REC_VER=RECVERSION AND CLP_GUEST_CARD IS NULL),'-','0',(SELECT MONTH(CLP_STARTDATE) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND 
	CED_REC_VER=RECVERSION AND CLP_GUEST_CARD IS NULL),'-','01'));
ELSE
	SET STARTDATE=(SELECT CONCAT((SELECT YEAR(CLP_STARTDATE) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND 
	CED_REC_VER=RECVERSION AND CLP_GUEST_CARD IS NULL),'-',(SELECT MONTH(CLP_STARTDATE) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND 
	CED_REC_VER=RECVERSION AND CLP_GUEST_CARD IS NULL),'-','01'));
END IF;
SET ENDDATE=(SELECT CLP_ENDDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND 
CED_REC_VER=RECVERSION AND CLP_GUEST_CARD IS NULL);
SET PRETERMINATEDATE=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND 
CED_REC_VER=RECVERSION AND CLP_GUEST_CARD IS NULL);
IF PRETERMINATEDATE IS NOT NULL THEN
SET ENDDATE=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND 
CED_REC_VER=RECVERSION AND CLP_GUEST_CARD IS NULL);
ELSE
SET ENDDATE=(SELECT CLP_ENDDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND 
CED_REC_VER=RECVERSION AND CLP_GUEST_CARD IS NULL);
END IF;
SET FLAG=0;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);  
  SELECT PD.PD_FOR_PERIOD,PD.CED_REC_VER,PP.PP_DATA INTO @FOR_PERIOD,@REC_VER,@TYPE FROM PAYMENT_DETAILS PD,PAYMENT_PROFILE PP WHERE PP.PP_ID = PD.PP_ID AND PD.PD_ID = INPUT_PDID; 
  IF (@FOR_PERIOD != FOR_PERIOD_DATE OR @REC_VER != RECVERSION OR @TYPE != PAYMENTTYPE) THEN  
	IF EXISTS(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVERSION AND 
	IF(CLP_PRETERMINATE_DATE IS NOT NULL,CLP_STARTDATE>CLP_PRETERMINATE_DATE ,CLP_STARTDATE>CLP_ENDDATE) AND (CLP_GUEST_CARD=' 'OR CLP_GUEST_CARD IS NULL))THEN
	    SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=556);
	    SET ERRORMSG=(SELECT REPLACE(ERRORMSG,'[RECVER]',RECVERSION));
		SET MESSAGE = CONCAT(MESSAGE,ERRORMSG);
		SET FLAG=1;
	END IF;    
		IF FOR_PERIOD_DATE NOT BETWEEN STARTDATE AND ENDDATE THEN 
			SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=557);
			SET MESSAGE = CONCAT(MESSAGE,ERRORMSG);
			SET FLAG=1;
		END IF;
		IF (PAYMENTTYPE='PAYMENT' OR PAYMENTTYPE='CLEANING FEE') THEN
			IF EXISTS(SELECT * FROM PAYMENT_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVERSION AND 
			PD_FOR_PERIOD=FOR_PERIOD_DATE AND PP_ID=(SELECT PP_ID FROM PAYMENT_PROFILE WHERE PP_DATA=PAYMENTTYPE) AND	UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO))THEN
			    SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=558);
			    SET ERRORMSG=(SELECT REPLACE(ERRORMSG,'[MONTH]',FORPERIOD));
				SET MESSAGE = CONCAT(MESSAGE,ERRORMSG);
				SET FLAG=1;
			END IF;
		END IF;
		IF (PAYMENTTYPE='DEPOSIT REFUND')THEN			
			IF (FOR_PERIOD_DATE!=(SELECT ADDDATE(LAST_DAY(SUBDATE(ENDDATE, INTERVAL 1 MONTH)), 1))) THEN
				SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=559);
				SET ERRORMSG=(SELECT REPLACE(ERRORMSG,'[MONTH]',FORPERIOD));
   				SET MESSAGE = CONCAT(MESSAGE,ERRORMSG);
			SET FLAG=1;
			END IF;
			IF EXISTS(SELECT * FROM PAYMENT_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVERSION AND 
			PD_FOR_PERIOD=(SELECT ADDDATE(LAST_DAY(SUBDATE(ENDDATE, INTERVAL 1 MONTH)), 1)) AND PP_ID=(SELECT PP_ID FROM PAYMENT_PROFILE WHERE PP_DATA=PAYMENTTYPE) AND 
			UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO))THEN
				SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=560);
				SET ERRORMSG=(SELECT REPLACE(ERRORMSG,'[CUSTOMER]',CUSTNAME));
				SET MESSAGE = CONCAT(MESSAGE,ERRORMSG);
			SET FLAG=1;
			END IF;
		END IF;
		IF (PAYMENTTYPE='DEPOSIT')THEN
			IF (FOR_PERIOD_DATE!=STARTDATE)THEN
				SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=561);
				SET ERRORMSG=(SELECT REPLACE(ERRORMSG,'[MONTH]',FORPERIOD));
				SET MESSAGE = CONCAT(MESSAGE,ERRORMSG);
			  SET FLAG=1;
			END IF;      
			IF EXISTS(SELECT * FROM PAYMENT_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVERSION AND 
			    PD_FOR_PERIOD=STARTDATE AND PP_ID=(SELECT PP_ID FROM PAYMENT_PROFILE WHERE PP_DATA=PAYMENTTYPE) AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO))THEN
				SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=562);
				SET ERRORMSG=(SELECT REPLACE(ERRORMSG,'[CUSTOMER]',CUSTNAME));
				SET MESSAGE = CONCAT(MESSAGE,ERRORMSG);
			  SET FLAG=1;
			END IF;
		END IF;		
		IF (PAYMENTTYPE='PROCESSING FEE')THEN			
			IF (FOR_PERIOD_DATE!=STARTDATE)THEN
			    SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=563);
			    SET ERRORMSG=(SELECT REPLACE(ERRORMSG,'[MONTH]',FORPERIOD));
				SET MESSAGE = CONCAT(MESSAGE,ERRORMSG);
			SET FLAG=1;
			END IF;
			IF EXISTS(SELECT * FROM PAYMENT_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVERSION AND 
			PD_FOR_PERIOD=STARTDATE AND PP_ID=(SELECT PP_ID FROM PAYMENT_PROFILE WHERE PP_DATA=PAYMENTTYPE) AND 
			UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO))THEN
			    SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=564);
			    SET ERRORMSG=(SELECT REPLACE(ERRORMSG,'[CUSTOMER]',CUSTNAME));
				SET MESSAGE = CONCAT(MESSAGE,ERRORMSG);
			SET FLAG=1;
			END IF;
		END IF;
	END IF;	
 IF HIGHLIGHTFLAG =' ' THEN 
 SET HIGHLIGHTFLAG = null; 
 END IF;		
	IF (FLAG=0) THEN
		IF(UNITNO IS NOT NULL AND CUSTOMERID IS NOT NULL AND PAYMENTTYPE IS NOT NULL AND AMOUNT IS NOT NULL AND FORPERIOD IS NOT NULL AND PAIDDATE IS NOT NULL AND USERSTAMP IS NOT NULL) THEN		
			UPDATE PAYMENT_DETAILS SET PP_ID=(SELECT PP_ID FROM PAYMENT_PROFILE WHERE PP_DATA=PAYMENTTYPE),CED_REC_VER=RECVERSION,PD_AMOUNT=AMOUNT,
			PD_FOR_PERIOD=FOR_PERIOD_DATE,PD_PAID_DATE= PAIDDATE,PD_HIGHLIGHT_FLAG=HIGHLIGHTFLAG,PD_COMMENTS=COMMENTS,ULD_ID=USERSTAMP_ID WHERE PD_ID=INPUT_PDID;
		END IF;
  ELSE
    SET FINAL_MESSAGE = CONCAT(FINAL_MESSAGE,'UNIT NO= ',UNITNO,', CUSTOMER ID= ',CUSTOMERID,', PAYMENT TYPE= ',PAYMENTTYPE,', LEASE PERIOD= ',RECVERSION,', AMOUNT= ',AMOUNT,',FOR PERIOD= ',FORPERIOD,', PAID DATE=',PAIDDATE,', COMMENTS= ',IFNULL(COMMENTS,' '),'/ WARNING: ',MESSAGE);
  END IF;
SET OUTPUT_FINAL_MESSAGE = FINAL_MESSAGE;
COMMIT;
END;
