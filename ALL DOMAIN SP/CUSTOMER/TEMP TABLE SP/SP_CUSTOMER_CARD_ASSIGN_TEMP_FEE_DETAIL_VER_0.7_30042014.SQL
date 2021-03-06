-- version 0.7 --issue:817 sdate:30-04-2014 ENDDATE:30-04-2014 desc:CHANGED TEMP TABLE FOR DYNAMIC RUNNING PURPOSE DONE BY:BHAVANI.R
-- version 0.6 --issue:636 comment:129 sdate:11/11/2013 desc:CC_AIRCON_QUARTELY_FEE changed as CC_AIRCON_QUARTERLY_FEE BY RL
-- version --> 0.5 -->issue tracker no :636 comment no:#47 startdate:08/11/2013 enddate:08/11/2013 description --> changed sp name and temp table name  created by -->Dhivya.A 
-- version --> 0.4 startdate -->15/10/2013 enddate --> 15/10/2013 description --> added comments and changed temp table cc_rent_amount variable name as CC_PAYMENT_AMOUNT_AMOUNT created by -->Dhivya.A -->issue tracker no :636
-- version --> 0.3 startdtae -->24/07/2013 enddate --> 24/07/2013 description --> implemented roll back & commit commands created by -->rajalakshmi.r -->issue tracker no :566
-- version --> 0.2 description --> merged TEMP_CARD_ASSIGN_FEE_DETAIL sp & CARD_ASSIGN_FEE_DETAILS sp --> startdate -->08/07/2013 enddate --> 08/07/2013 
-- version --> 0.1 startdtae -->05/07/2013 enddate --> 05/07/2013 description --> temporary fee detail table for card assign form created by -->rajalakshmi.r -->issue tracker no :345
DROP PROCEDURE IF EXISTS SP_CUSTOMER_CARD_ASSIGN_TEMP_FEE_DETAIL;
CREATE PROCEDURE SP_CUSTOMER_CARD_ASSIGN_TEMP_FEE_DETAIL(IN CUSTOMERID INTEGER,IN USERSTAMP VARCHAR(50),OUT CUSTOMER_CARD_ASSIGN_FEE_TEMPTBLNAME TEXT)
BEGIN
DECLARE REC_VER INT;
DECLARE ID INTEGER;
DECLARE CUSTOMER_CARD_ASSIGN_TEMPTBLNAME TEXT;
DECLARE USERSTAMP_ID INT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK; 
END;
SET ID = CUSTOMERID;
START TRANSACTION;
--  TEMP TABLE NAME START
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID=(SELECT @ULDID);
SET CUSTOMER_CARD_ASSIGN_TEMPTBLNAME=(SELECT CONCAT('TEMP_CUSTOMER_CARD_ASSIGN_FEE_DETAIL',SYSDATE()));
--  temp table name
SET CUSTOMER_CARD_ASSIGN_TEMPTBLNAME=(SELECT REPLACE(CUSTOMER_CARD_ASSIGN_TEMPTBLNAME,' ',''));
SET CUSTOMER_CARD_ASSIGN_TEMPTBLNAME=(SELECT REPLACE(CUSTOMER_CARD_ASSIGN_TEMPTBLNAME,'-',''));
SET CUSTOMER_CARD_ASSIGN_TEMPTBLNAME=(SELECT REPLACE(CUSTOMER_CARD_ASSIGN_TEMPTBLNAME,':',''));
SET CUSTOMER_CARD_ASSIGN_FEE_TEMPTBLNAME=(SELECT CONCAT(CUSTOMER_CARD_ASSIGN_TEMPTBLNAME,'_',USERSTAMP_ID)); 
--  TEMP TABLE NAME END
-- create temporary table CUSTOMER_CARD_ASSIGN_FEE_TEMPTBLNAME
SET @CREATE_TEMP_CUSTOMER_CARD_ASSIGN_FEE_DETAIL=(SELECT CONCAT('CREATE TABLE ',CUSTOMER_CARD_ASSIGN_FEE_TEMPTBLNAME,'
(
SNO INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
CUSTOMER_ID INT,
CUSTOMER_VER INT,
CC_PAYMENT_AMOUNT DECIMAL(7,2),
CC_DEPOSIT DECIMAL(7,2),
CC_PROCESSING_FEE DECIMAL(7,2),
CC_AIRCON_FIXED_FEE DECIMAL(7,2),
CC_ELECTRICITY_CAP DECIMAL(7,2),
CC_DRYCLEAN_FEE DECIMAL(7,2),
CC_AIRCON_QUARTERLY_FEE DECIMAL(7,2),
CC_CHECKOUT_CLEANING_FEE DECIMAL(7,2))'));
PREPARE CREATE_TEMP_CUSTOMER_CARD_ASSIGN_FEE_DETAIL_STMT FROM @CREATE_TEMP_CUSTOMER_CARD_ASSIGN_FEE_DETAIL;
EXECUTE CREATE_TEMP_CUSTOMER_CARD_ASSIGN_FEE_DETAIL_STMT;
SET REC_VER = (SELECT MAX(CED_REC_VER) FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=ID);
WHILE REC_VER !=0 DO
IF EXISTS (SELECT CED_REC_VER FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=ID AND CED_REC_VER=REC_VER) THEN
-- insert query for CUSTOMER_CARD_ASSIGN_FEE_TEMPTBLNAME table
SET @INSERT_TEMP_CUSTOMER_CARD_ASSIGN_FEE_DETAIL=(SELECT CONCAT('INSERT INTO ',CUSTOMER_CARD_ASSIGN_FEE_TEMPTBLNAME,' (CUSTOMER_ID,CUSTOMER_VER,CC_PAYMENT_AMOUNT,CC_DEPOSIT,CC_PROCESSING_FEE,CC_AIRCON_FIXED_FEE,
CC_ELECTRICITY_CAP,CC_DRYCLEAN_FEE,CC_AIRCON_QUARTERLY_FEE,CC_CHECKOUT_CLEANING_FEE)VALUES (',ID,',',REC_VER,',
(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=',ID,' AND CED_REC_VER=',REC_VER,' AND CPP_ID=1),
(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=',ID,' AND CED_REC_VER=',REC_VER,' AND CPP_ID=2),
(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=',ID,' AND CED_REC_VER=',REC_VER,' AND CPP_ID=3),
(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=',ID,' AND CED_REC_VER=',REC_VER,' AND CPP_ID=4),
(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=',ID,' AND CED_REC_VER=',REC_VER,' AND CPP_ID=5),
(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=',ID,' AND CED_REC_VER=',REC_VER,' AND CPP_ID=6),
(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=',ID,' AND CED_REC_VER=',REC_VER,' AND CPP_ID=7),
(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=',ID,' AND CED_REC_VER=',REC_VER,' AND CPP_ID=8))'));
PREPARE INSERT_TEMP_CUSTOMER_CARD_ASSIGN_FEE_DETAIL_STMT FROM @INSERT_TEMP_CUSTOMER_CARD_ASSIGN_FEE_DETAIL;
EXECUTE INSERT_TEMP_CUSTOMER_CARD_ASSIGN_FEE_DETAIL_STMT;
END IF;
SET REC_VER=REC_VER-1;
END WHILE;
COMMIT;
END;