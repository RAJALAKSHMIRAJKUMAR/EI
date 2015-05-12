-- VER 0.3 ISSUE:817 COMMENT #139 STARTDATE:21/06/2014 ENDDATE:21/06/2014 DESC:DROPED TEMP TABLES INSIDE ROLL BACK AND COMMIT DONE BY:DHIVYA.A
-- VER0.2 STARTDATE:03/05/2014 ENDDATE:03/05/2014 DESC:CONCAT THE USERSTAMP_ID AND SYSTEMDATE WITH THE TEMP_CUSTOMER_EXPIRY DONE BY:RAJA
-- VER0.1 STARTDATE:09/04/2014 ENDDATE:09/04/2014 DESC:MERGED CUSTOMER_EXPIRY BEFORE,EQUAL & BETWEEN SP INTO SINGLE SP DONE BY:DHIVYA.A

DROP PROCEDURE IF EXISTS SP_CUSTOMER_EXPIRY;
CREATE PROCEDURE SP_CUSTOMER_EXPIRY
(IN OPTION_ID INTEGER,
IN FROM_INPUT DATE,
IN TO_INPUT DATE,
IN USERSTAMP VARCHAR(50),
OUT TABLENAME TEXT)
BEGIN
DECLARE SEARCHOPTION VARCHAR(25);
DECLARE EXPIRYDATE TEXT;
DECLARE TEMPTBLNAME TEXT;
DECLARE USERSTAMP_ID INT;
DECLARE TEMPTABLENAME TEXT;
DECLARE CUSTOMER_EXPIRY_FEE_TEMPTABLE TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
IF CUSTOMER_EXPIRY_FEE_TEMPTABLE IS NOT NULL THEN
SET @DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',CUSTOMER_EXPIRY_FEE_TEMPTABLE));
PREPARE DROPQUERYSTMT FROM @DROPQUERY;
EXECUTE DROPQUERYSTMT;
END IF;
DROP VIEW IF EXISTS EXPIRY_MAXRECVER;
END;
START TRANSACTION;
-- TEMPORARY VIEW FOR GETTING CUSTOMER_ID AND MAX REC VER
CREATE OR REPLACE VIEW EXPIRY_MAXRECVER AS SELECT C1.CUSTOMER_ID,MAX(C1.CED_REC_VER) AS REC_VER FROM CUSTOMER_LP_DETAILS C1 WHERE C1.CLP_GUEST_CARD IS NULL AND IF(C1.CLP_PRETERMINATE_DATE IS NOT NULL,C1.CLP_STARTDATE<C1.CLP_PRETERMINATE_DATE,C1.CLP_STARTDATE) GROUP BY C1.CUSTOMER_ID;
IF OPTION_ID=1 THEN
	SET SEARCHOPTION='EQUAL';
	SET @EXPIRY_DATE=(SELECT CONCAT('IF(CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_PRETERMINATE_DATE=','"',FROM_INPUT,'"',',CTD.CLP_ENDDATE=','"',FROM_INPUT,'"',')'));
	SET EXPIRYDATE=@EXPIRY_DATE;
END IF;
IF OPTION_ID=2 THEN
	SET SEARCHOPTION='BEFORE';
	SET @EXPIRY_DATE=(SELECT CONCAT('IF(CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_PRETERMINATE_DATE<=','"',FROM_INPUT,'"',',CTD.CLP_ENDDATE<=','"',FROM_INPUT,'"',')'));
	SET EXPIRYDATE=@EXPIRY_DATE;
END IF;
IF OPTION_ID=3 THEN
	SET SEARCHOPTION='BETWEEN';
	SET @EXPIRY_DATE=(SELECT CONCAT('IF(CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_PRETERMINATE_DATE BETWEEN ','"',FROM_INPUT,'"',' AND ','"',TO_INPUT,'"',',CTD.CLP_ENDDATE BETWEEN ','"',FROM_INPUT,'"',' AND ','"',TO_INPUT,'"',')'));
	SET EXPIRYDATE=@EXPIRY_DATE;
END IF;
-- CALL QUERY FOR USERID
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID=(SELECT @ULDID);
SET TEMPTBLNAME=SYSDATE();
--  TEMP TABLE NAME
SET TEMPTBLNAME=(SELECT REPLACE(TEMPTBLNAME,' ',''));
SET TEMPTBLNAME=(SELECT REPLACE(TEMPTBLNAME,'-',''));
SET TEMPTBLNAME=(SELECT REPLACE(TEMPTBLNAME,':',''));
SET TEMPTABLENAME=(SELECT CONCAT(TEMPTBLNAME,'_',USERSTAMP_ID)); 
SET TABLENAME=(SELECT CONCAT('TEMP_CUSTOMER_EXPIRY_',SEARCHOPTION ,'_','DATE',TEMPTABLENAME));
-- CALL QUERY FOR ALL_CUSTOMER_EXPIRY_LIST_TEMP_FEE_DETAIL
CALL SP_ALL_CUSTOMER_EXPIRY_LIST_TEMP_FEE_DETAIL(USERSTAMP,@CUSTOMER_EXPIRY_FEE_TEMPTBLNAME,@FLAG);
SET CUSTOMER_EXPIRY_FEE_TEMPTABLE=(SELECT @CUSTOMER_EXPIRY_FEE_TEMPTBLNAME);
-- CREATE QUERY FOR CUSTOMER_EXPIRY_TEMP_TABLE
SET @CREATE_QUERY=(SELECT CONCAT('CREATE TABLE ',TABLENAME,'(CUSTOMERID INTEGER,CUSTOMERFIRSTNAME VARCHAR(100),CUSTOMERLASTNAME VARCHAR(100),RECVER INTEGER,UNITNO INTEGER(4) UNSIGNED ZEROFILL,STARTDATE DATE,ENDDATE DATE,PRETERMINATEDATE DATE,ROOMTYPE VARCHAR(30),EXTENSIONFLAG CHAR(1),RECHECKINGFLAG CHAR(1),PAYMENT INTEGER,DEPOSIT INTEGER,PROCESSINGFEE INTEGER,COMMENTS TEXT,USERSTAMP VARCHAR(50),EXPIRY_TIMESTAMP TIMESTAMP)'));
PREPARE CREATE_QUERY_STMT FROM @CREATE_QUERY;
EXECUTE CREATE_QUERY_STMT;
-- INSERT QUERY FOR CUSTOMER_EXPIRY_TEMP_TABLE
SET @INSERT_QUERY=(SELECT CONCAT('INSERT INTO ',TABLENAME,' SELECT CTD.CUSTOMER_ID,C3.CUSTOMER_FIRST_NAME,C3.CUSTOMER_LAST_NAME,CTD.CED_REC_VER,U.UNIT_NO,CTD.CLP_STARTDATE,CTD.CLP_ENDDATE,CTD.CLP_PRETERMINATE_DATE,URTD.URTD_ROOM_TYPE,CED.CED_EXTENSION,CED.CED_RECHECKIN,E1.CC_PAYMENT_AMOUNT,E1.CC_DEPOSIT,E1.CC_PROCESSING_FEE,CPD.CPD_COMMENTS,ULD.ULD_LOGINID,CTD.CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS CTD,CUSTOMER_ENTRY_DETAILS CED,EXPIRY_MAXRECVER E,',CUSTOMER_EXPIRY_FEE_TEMPTABLE,' E1,CUSTOMER_PERSONAL_DETAILS CPD,UNIT_ACCESS_STAMP_DETAILS UASD,UNIT_ROOM_TYPE_DETAILS URTD,UNIT U,CUSTOMER C3,USER_LOGIN_DETAILS ULD WHERE ULD.ULD_ID=CTD.ULD_ID AND CED.CUSTOMER_ID=CTD.CUSTOMER_ID AND CED.CED_REC_VER=CTD.CED_REC_VER AND ULD.ULD_ID=CTD.ULD_ID AND CTD.CLP_GUEST_CARD IS NULL AND E.CUSTOMER_ID=CED.CUSTOMER_ID AND E.CUSTOMER_ID=CTD.CUSTOMER_ID AND E.REC_VER=CED.CED_REC_VER AND E.REC_VER=CTD.CED_REC_VER AND CTD.CLP_TERMINATE IS NULL AND CED.CED_CANCEL_DATE IS NULL AND CPD.CUSTOMER_ID=CTD.CUSTOMER_ID AND CPD.CUSTOMER_ID=CED.CUSTOMER_ID AND E1.CUSTOMER_ID=CED.CUSTOMER_ID AND E1.CUSTOMER_ID=CTD.CUSTOMER_ID AND E1.CUSTOMER_VER=CED.CED_REC_VER AND E1.CUSTOMER_VER=CTD.CED_REC_VER AND E.REC_VER=E1.CUSTOMER_VER AND E.CUSTOMER_ID=E1.CUSTOMER_ID AND CED.UASD_ID=UASD.UASD_ID AND UASD.URTD_ID=URTD.URTD_ID AND U.UNIT_ID=CED.UNIT_ID AND C3.CUSTOMER_ID=CTD.CUSTOMER_ID AND C3.CUSTOMER_ID=CED.CUSTOMER_ID AND E.CUSTOMER_ID=C3.CUSTOMER_ID AND E1.CUSTOMER_ID=C3.CUSTOMER_ID AND C3.CUSTOMER_ID=CPD.CUSTOMER_ID AND ',EXPIRYDATE,' GROUP BY CTD.CUSTOMER_ID  ORDER BY U.UNIT_NO,C3.CUSTOMER_FIRST_NAME'));
PREPARE INSERT_QUERY_STMT FROM @INSERT_QUERY;
EXECUTE INSERT_QUERY_STMT;
DROP VIEW IF EXISTS EXPIRY_MAXRECVER;
SET @DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',CUSTOMER_EXPIRY_FEE_TEMPTABLE));
PREPARE DROPQUERYSTMT FROM @DROPQUERY;
EXECUTE DROPQUERYSTMT;
COMMIT;
END; 


CALL SP_CUSTOMER_EXPIRY(2,'2015-05-14',null,'expatsintegrated@gmail.com',@TABLENAME);
SELECT @TABLENAME;

SELECT * FROM TEMP_CUSTOMER_EXPIRY_BEFORE_DATE20140505133735_5;











