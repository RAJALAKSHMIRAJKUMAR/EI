DROP PROCEDURE IF EXISTS SP_PAYMENT_DETAIL_INSERT;
CREATE PROCEDURE SP_PAYMENT_DETAIL_INSERT(IN INPUT_UNITNO TEXT,
IN INPUT_CUSTOMERID TEXT,IN INPUT_PAYMENTTYPE TEXT,IN INPUT_RECVERSION TEXT,INPUT_AMOUNT TEXT,INPUT_FORPERIOD TEXT,
IN INPUT_PAIDDATE TEXT,IN INPUT_HIGHLIGHTFLAG TEXT,IN INPUT_COMMENTS TEXT,IN INPUT_USERSTAMP VARCHAR(50),IN OCBCID INTEGER, OUT OUTPUT_FINAL_MESSAGE TEXT)
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
DECLARE UNITNO SMALLINT;
DECLARE CUSTOMERID INTEGER;
DECLARE PAYMENTTYPE VARCHAR(50);
DECLARE RECVERSION INTEGER;
DECLARE AMOUNT DECIMAL(7,2);
DECLARE FORPERIOD VARCHAR(50);
DECLARE PAIDDATE DATE;
DECLARE HIGHLIGHTFLAG CHAR(1);
DECLARE COMMENTS TEXT;
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE CUSTOMERNAME VARCHAR(70);
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
SET @TEMP_UNITNO = INPUT_UNITNO;
SET @TEMP_CUSTOMERID = INPUT_CUSTOMERID;
SET @TEMP_PAYMENTTYPE = INPUT_PAYMENTTYPE;
SET @TEMP_RECVERSION = INPUT_RECVERSION;
SET @TEMP_AMOUNT = INPUT_AMOUNT;
SET @TEMP_FORPERIOD = INPUT_FORPERIOD;
SET @TEMP_PAIDDATE = INPUT_PAIDDATE;
SET @TEMP_HIGHLIGHTFLAG = INPUT_HIGHLIGHTFLAG;
SET @TEMP_COMMENTS = INPUT_COMMENTS;
MAIN_LOOP : LOOP        
    CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_UNITNO,@VALUE,@REMAINING_STRING);
    SELECT @VALUE INTO UNITNO;
    SELECT @REMAINING_STRING INTO @TEMP_UNITNO;    
    CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_CUSTOMERID,@VALUE,@REMAINING_STRING);
    SELECT @VALUE INTO CUSTOMERID;
    SELECT @REMAINING_STRING INTO @TEMP_CUSTOMERID;    
    CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_PAYMENTTYPE,@VALUE,@REMAINING_STRING);
    SELECT @VALUE INTO PAYMENTTYPE;
    SELECT @REMAINING_STRING INTO @TEMP_PAYMENTTYPE;    
    CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_RECVERSION,@VALUE,@REMAINING_STRING);
    SELECT @VALUE INTO RECVERSION;
    SELECT @REMAINING_STRING INTO @TEMP_RECVERSION;    
    CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_AMOUNT,@VALUE,@REMAINING_STRING);
    SELECT @VALUE INTO AMOUNT;
    SELECT @REMAINING_STRING INTO @TEMP_AMOUNT;    
    CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_FORPERIOD,@VALUE,@REMAINING_STRING);
    SELECT @VALUE INTO FORPERIOD;
    SELECT @REMAINING_STRING INTO @TEMP_FORPERIOD;    
    IF OCBCID IS NOT NULL THEN    
     SET PAIDDATE = (SELECT OBR_VALUE_DATE FROM OCBC_BANK_RECORDS WHERE OBR_ID=OCBCID);
    ELSE       
        CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_PAIDDATE,@VALUE,@REMAINING_STRING);
        SELECT @VALUE INTO PAIDDATE;
        SELECT @REMAINING_STRING INTO @TEMP_PAIDDATE;
    END IF;    
    CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_HIGHLIGHTFLAG,@VALUE,@REMAINING_STRING);
    SELECT @VALUE INTO HIGHLIGHTFLAG;    
    SELECT @REMAINING_STRING INTO @TEMP_HIGHLIGHTFLAG;    
    CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('^^',@TEMP_COMMENTS,@VALUE,@REMAINING_STRING);
    SELECT @VALUE INTO COMMENTS;
    SELECT @REMAINING_STRING INTO @TEMP_COMMENTS;    
    SET MESSAGE ='';
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
CALL SP_CHANGE_USERSTAMP_AS_ULDID(INPUT_USERSTAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);
IF EXISTS(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVERSION AND 
    IF(CLP_PRETERMINATE_DATE IS NOT NULL,CLP_STARTDATE>CLP_PRETERMINATE_DATE ,CLP_STARTDATE>CLP_ENDDATE) AND (CLP_GUEST_CARD=' 'OR CLP_GUEST_CARD IS NULL))THEN
    SET MESSAGE = CONCAT(MESSAGE,'CANNOT PAY FOR THIS REVER.');
    SET FLAG=1;
    END IF;          
IF FOR_PERIOD_DATE NOT BETWEEN STARTDATE AND ENDDATE THEN
SET MESSAGE = CONCAT(MESSAGE,'FOR_PERIOD SHOULD BETWEEN STARTDATE AND ENDDATE.');
SET FLAG=1;
END IF;                 
IF (PAYMENTTYPE='PAYMENT' OR PAYMENTTYPE='CLEANING FEE') THEN
IF EXISTS(SELECT * FROM PAYMENT_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVERSION AND 
            PD_FOR_PERIOD=FOR_PERIOD_DATE AND PP_ID=(SELECT PP_ID FROM PAYMENT_PROFILE WHERE PP_DATA=PAYMENTTYPE) AND 
            UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO))THEN
        SET MESSAGE = CONCAT(MESSAGE,'ALREADY PAID FOR THIS MONTH.');
SET FLAG=1;
END IF;
END IF;
IF (PAYMENTTYPE='DEPOSIT REFUND')THEN
IF (FOR_PERIOD_DATE!=(SELECT ADDDATE(LAST_DAY(SUBDATE(ENDDATE, INTERVAL 1 MONTH)), 1))) THEN
SET MESSAGE = CONCAT(MESSAGE,'CANNOT PAY DEPOSIT REFUND FOR THIS MONTH.');
SET FLAG=1;
END IF;
IF EXISTS(SELECT * FROM PAYMENT_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVERSION AND 
PD_FOR_PERIOD=(SELECT ADDDATE(LAST_DAY(SUBDATE(ENDDATE, INTERVAL 1 MONTH)), 1)) AND PP_ID=(SELECT PP_ID FROM PAYMENT_PROFILE WHERE PP_DATA=PAYMENTTYPE) AND 
UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO))THEN
SET MESSAGE = CONCAT(MESSAGE,'ALREADY PAID DEPOSIT REFUND FOR THIS CUSTOMER.');
SET FLAG=1;
END IF;
END IF;
IF (PAYMENTTYPE='DEPOSIT')THEN
IF (FOR_PERIOD_DATE!=STARTDATE)THEN
SET MESSAGE = CONCAT(MESSAGE,'CANNOT PAY DEPOSIT FOR THIS MONTH.');
SET FLAG=1;
END IF;
IF EXISTS(SELECT * FROM PAYMENT_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVERSION AND 
PD_FOR_PERIOD=STARTDATE AND PP_ID=(SELECT PP_ID FROM PAYMENT_PROFILE WHERE PP_DATA=PAYMENTTYPE) AND 
UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO))THEN
SET MESSAGE = CONCAT(MESSAGE,'ALREADY PAID DEPOSIT FOR THIS CUSTOMER.');
SET FLAG=1;
END IF;
END IF;
IF (PAYMENTTYPE='PROCESSING FEE')THEN
    IF (FOR_PERIOD_DATE!=STARTDATE)THEN
    SET MESSAGE = CONCAT(MESSAGE,'CANNOT PAY PROCESSING FEE FOR THIS MONTH.');
    SET FLAG=1;
    END IF;      
    IF EXISTS(SELECT * FROM PAYMENT_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVERSION AND 
    PD_FOR_PERIOD=STARTDATE AND PP_ID=(SELECT PP_ID FROM PAYMENT_PROFILE WHERE PP_DATA=PAYMENTTYPE) AND 
    UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO))THEN
    SET MESSAGE = CONCAT(MESSAGE,'ALREADY PAID PROCESSING FEE FOR THIS CUSTOMER.');
     SET FLAG=1;
    END IF;
END IF;
  IF HIGHLIGHTFLAG =' ' then 
  SET HIGHLIGHTFLAG = NULL; 
  END IF;      
IF (FLAG=0) THEN         
IF(UNITNO IS NOT NULL AND CUSTOMERID IS NOT NULL AND PAYMENTTYPE IS NOT NULL AND AMOUNT IS NOT NULL AND FORPERIOD IS NOT NULL AND PAIDDATE IS NOT NULL AND INPUT_USERSTAMP IS NOT NULL) THEN       
INSERT INTO PAYMENT_DETAILS(UNIT_ID,CUSTOMER_ID,PP_ID,CED_REC_VER,PD_AMOUNT,PD_FOR_PERIOD,PD_PAID_DATE,
PD_HIGHLIGHT_FLAG,PD_COMMENTS,ULD_ID)VALUES((SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO),CUSTOMERID,(SELECT PP_ID FROM PAYMENT_PROFILE WHERE PP_DATA=PAYMENTTYPE),RECVERSION,AMOUNT,FOR_PERIOD_DATE,
PAIDDATE,HIGHLIGHTFLAG,COMMENTS,USERSTAMP_ID);
END IF;    
 IF OCBCID IS NOT NULL AND PAIDDATE IS NULL THEN
	INSERT INTO PAYMENT_DETAILS(UNIT_ID,CUSTOMER_ID,PP_ID,CED_REC_VER,PD_AMOUNT,PD_FOR_PERIOD,PD_PAID_DATE,
	PD_HIGHLIGHT_FLAG,PD_COMMENTS,ULD_ID)VALUES((SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO),CUSTOMERID,(SELECT PP_ID FROM     PAYMENT_PROFILE WHERE PP_DATA=PAYMENTTYPE),RECVERSION,AMOUNT,FOR_PERIOD_DATE,
	(SELECT OBR_VALUE_DATE FROM OCBC_BANK_RECORDS WHERE OBR_ID=OCBCID),HIGHLIGHTFLAG,COMMENTS,USERSTAMP_ID);
END IF;
  ELSE
    SET CUSTOMERNAME=(SELECT CONCAT(CUSTOMER_FIRST_NAME,' ',CUSTOMER_LAST_NAME)AS CUSTOMERNAME FROM CUSTOMER WHERE CUSTOMER_ID=CUSTOMERID);
    SET FINAL_MESSAGE = CONCAT(FINAL_MESSAGE,'UNIT NO= ',UNITNO,', CUSTOMER ID= ',CUSTOMERID,',CUSTOMERNAME= ',CUSTOMERNAME,', PAYMENT TYPE= ',PAYMENTTYPE,',LEASE PERIOD= ',RECVERSION,', AMOUNT= ',AMOUNT,',FOR PERIOD= ',FORPERIOD,', PAID DATE=',PAIDDATE,', COMMENTS= ',IFNULL(COMMENTS,' '),'/ WARNING: ',MESSAGE,'//    ');
  END IF;
  IF @TEMP_UNITNO IS NULL THEN
LEAVE  MAIN_LOOP;
END IF;
END LOOP; 
SET OUTPUT_FINAL_MESSAGE = FINAL_MESSAGE;
 IF OCBCID IS NOT NULL AND OUTPUT_FINAL_MESSAGE=' ' THEN 	
	UPDATE OCBC_BANK_RECORDS SET OBR_REFERENCE='X',ULD_ID=USERSTAMP_ID WHERE OBR_ID=OCBCID;
END IF;
COMMIT;
END;