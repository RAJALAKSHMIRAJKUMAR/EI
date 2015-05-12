-- VER 0.6 ISSUE:817 COMMENT #139 STARTDATE:21/06/2014 ENDDATE:21/06/2014 DESC:DROPED TEMP TABLES INSIDE ROLL BACK AND COMMIT DONE BY:DHIVYA.A
--> version 0.5-->startdate:06/05/2014  enddate:06/05/2014 -->issueno:817 -->desc:CUSTOMER EXPIRY ONE WEEK SP DONE DYNAMICALLY -->doneby:DHIVYA.A
--VER 0.4 ISSUE NO:797 COMMENT NO:#4 START DATE:03/04/2014 ENDDATE:03/04/2014 DESC:REPLACED TABLENAME AND HEADERNAME DONE BY:SASIKALA.D
--VER 0.3 ISSUE NO:636 COMMENT NO:#47 START DATE:08/11/2013 ENDDATE:08/11/2013 DESC:changed sp name and changed temp table name inside select query DONE BY:DHIVYA.A
--VER 0.2 ISSUE NO:345 COMMENT NO:#344 START DATE:07/11/2013 ENDDATE:07/11/2013 DESC:added emailid headersss in temp table DONE BY:DHIVYA.A
--VER 0.1 ISSUE NO:345 COMMENT NO:#312 START DATE:05/11/2013 ENDDATE:06/11/2013 DESC:SP FOR CUSTOMER WEEKLY EXPIRY DONE BY:DHIVYA.A

DROP PROCEDURE IF EXISTS SP_CUSTOMER_WEEKLY_EXPIRY_ONE_WEEK;
CREATE PROCEDURE SP_CUSTOMER_WEEKLY_EXPIRY_ONE_WEEK(IN USERSTAMP VARCHAR(50),OUT TEMP_CUSTOMER_WEEKLY_EXPIRY_ONE_WEEK TEXT)
BEGIN
DECLARE ENDDATE DATE;
DECLARE USERSTAMP_ID INTEGER;
DECLARE TEMP_CUSTOMER_WEEKLY_EXPIRY TEXT;
DECLARE TEMP_ALL_CUSTOMER_EXPIRY_LIST_FEE_DETAIL TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK; 
IF TEMP_ALL_CUSTOMER_EXPIRY_LIST_FEE_DETAIL IS NOT NULL THEN
SET @DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ALL_CUSTOMER_EXPIRY_LIST_FEE_DETAIL));
PREPARE DROPQUERYSTMT FROM @DROPQUERY;
EXECUTE DROPQUERYSTMT;
END IF;
DROP VIEW IF EXISTS EXPIRY_MAXRECVER;
END;
START TRANSACTION;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID=(SELECT @ULDID);
SET ENDDATE=(SELECT DATE_ADD(CURDATE(), INTERVAL 7  day));

CALL SP_ALL_CUSTOMER_WEEKLY_EXPIRY_LIST_TEMP_FEE_DETAIL(USERSTAMP,@CUSTOMER_WEEKLY_EXPIRY_FEE_TEMPTBLNAME);

SET TEMP_ALL_CUSTOMER_EXPIRY_LIST_FEE_DETAIL=(SELECT @CUSTOMER_WEEKLY_EXPIRY_FEE_TEMPTBLNAME);
--TEMPORARY VIEW FOR GETTING CUSTOMER_ID AND MAX REC VER
CREATE OR REPLACE VIEW EXPIRY_MAXRECVER AS SELECT C1.CUSTOMER_ID,MAX(C1.CED_REC_VER) AS REC_VER FROM CUSTOMER_LP_DETAILS C1 WHERE C1.CLP_GUEST_CARD IS NULL AND IF(C1.CLP_PRETERMINATE_DATE IS NOT NULL,C1.CLP_STARTDATE<C1.CLP_PRETERMINATE_DATE,C1.CLP_STARTDATE) GROUP BY C1.CUSTOMER_ID;

SET TEMP_CUSTOMER_WEEKLY_EXPIRY=(SELECT CONCAT('TEMP_CUSTOMER_WEEKLY_EXPIRY_ONE_WEEK','_',SYSDATE()));
SET TEMP_CUSTOMER_WEEKLY_EXPIRY=(SELECT REPLACE(TEMP_CUSTOMER_WEEKLY_EXPIRY,' ',''));
SET TEMP_CUSTOMER_WEEKLY_EXPIRY=(SELECT REPLACE(TEMP_CUSTOMER_WEEKLY_EXPIRY,'-',''));
SET TEMP_CUSTOMER_WEEKLY_EXPIRY=(SELECT REPLACE(TEMP_CUSTOMER_WEEKLY_EXPIRY,':',''));
SET TEMP_CUSTOMER_WEEKLY_EXPIRY_ONE_WEEK=(SELECT CONCAT(TEMP_CUSTOMER_WEEKLY_EXPIRY,'_',USERSTAMP_ID));

--TEMPORARY TABLE FOR TEMP_CUSTOMER_WEEKLY_EXPIRY_ONE_WEEK;
SET @CREATE_CUSTOMER_WEEKLY_EXPIRY=(SELECT CONCAT('CREATE TABLE ',TEMP_CUSTOMER_WEEKLY_EXPIRY_ONE_WEEK,'(CUSTOMERFIRSTNAME VARCHAR(100),CUSTOMERLASTNAME VARCHAR(100),RECVER INTEGER,UNITNO INTEGER(4) UNSIGNED ZEROFILL,
ENDDATE DATE,PRETERMINATEDATE DATE,PAYMENT INTEGER,EMAILID VARCHAR(40))'));
PREPARE CREATE_CUSTOMER_WEEKLY_EXPIRY_STMT FROM @CREATE_CUSTOMER_WEEKLY_EXPIRY;
EXECUTE CREATE_CUSTOMER_WEEKLY_EXPIRY_STMT;

--INSERT QUERY FOR TEMP_CUSTOMER_WEEKLY_EXPIRY_ONE_WEEK
SET @INSERT_CUSTOMER_WEEKLY_EXPIRY=(SELECT CONCAT('INSERT INTO ',TEMP_CUSTOMER_WEEKLY_EXPIRY_ONE_WEEK,
' SELECT C3.CUSTOMER_FIRST_NAME,C3.CUSTOMER_LAST_NAME,CTD.CED_REC_VER,U.UNIT_NO,CTD.CLP_ENDDATE,CTD.CLP_PRETERMINATE_DATE,E1.CC_PAYMENT_AMOUNT,CPD.CPD_EMAIL
FROM CUSTOMER_LP_DETAILS CTD,CUSTOMER_ENTRY_DETAILS CED,EXPIRY_MAXRECVER E,'
,TEMP_ALL_CUSTOMER_EXPIRY_LIST_FEE_DETAIL,' E1,UNIT U,CUSTOMER C3,CUSTOMER_PERSONAL_DETAILS CPD
WHERE CED.CUSTOMER_ID=CTD.CUSTOMER_ID AND CED.CED_REC_VER=CTD.CED_REC_VER AND
CTD.CLP_GUEST_CARD IS NULL AND E.CUSTOMER_ID=CED.CUSTOMER_ID AND E.CUSTOMER_ID=CTD.CUSTOMER_ID AND E.REC_VER=CED.CED_REC_VER AND 
E.REC_VER=CTD.CED_REC_VER AND CTD.CLP_TERMINATE IS NULL AND CED.CED_CANCEL_DATE IS NULL 
AND E1.CUSTOMER_ID=CED.CUSTOMER_ID
AND E1.CUSTOMER_ID=CTD.CUSTOMER_ID AND E1.CUSTOMER_VER=CED.CED_REC_VER AND E1.CUSTOMER_VER=CTD.CED_REC_VER AND E.REC_VER=E1.CUSTOMER_VER AND
E.CUSTOMER_ID=E1.CUSTOMER_ID AND U.UNIT_ID=CED.UNIT_ID AND C3.CUSTOMER_ID=CTD.CUSTOMER_ID AND C3.CUSTOMER_ID=CED.CUSTOMER_ID AND 
E.CUSTOMER_ID=C3.CUSTOMER_ID AND E1.CUSTOMER_ID=C3.CUSTOMER_ID AND IF(CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_PRETERMINATE_DATE=','"',ENDDATE,'"',',CTD.CLP_ENDDATE=','"',ENDDATE,'"',')AND
CPD.CUSTOMER_ID=CTD.CUSTOMER_ID AND CPD.CUSTOMER_ID=CED.CUSTOMER_ID AND E.CUSTOMER_ID=CPD.CUSTOMER_ID AND
E1.CUSTOMER_ID=CPD.CUSTOMER_ID AND C3.CUSTOMER_ID=CPD.CUSTOMER_ID  GROUP BY CTD.CUSTOMER_ID  ORDER BY U.UNIT_NO,C3.CUSTOMER_FIRST_NAME')) ;
PREPARE INSERT_CUSTOMER_WEEKLY_EXPIRY_STMT FROM @INSERT_CUSTOMER_WEEKLY_EXPIRY;
EXECUTE INSERT_CUSTOMER_WEEKLY_EXPIRY_STMT;
DROP VIEW IF EXISTS EXPIRY_MAXRECVER;
SET @DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ALL_CUSTOMER_EXPIRY_LIST_FEE_DETAIL));
PREPARE DROPQUERYSTMT FROM @DROPQUERY;
EXECUTE DROPQUERYSTMT;
COMMIT;
END;


