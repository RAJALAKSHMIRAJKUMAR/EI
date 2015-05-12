--  version:0.8-- startdate:28/04/2014 --enddate :28/04/2014 ---issue 813 comment :Extra Added ULD in dynamic temp table Done by Kumar.
--  version:0.7 -- startdate:26/04/2014 -- enddate:26/04/2014 -- issue:813 -- comment #1,ADDED SYSDATE WITH THE TEMP TABLE CREATION BY PUNI
--  version 0.6 -- issue:636 comment:129 sdate:11/11/2013 desc:CC_AIRCON_QUARTELY_FEE changed as CC_AIRCON_QUARTERLY_FEE BY RL
--  version -- > 0.5 -- >issue tracker no :636 comment no:#47 startdate:08/11/2013 enddate:08/11/2013 description -- > changed sp name and temp table name  created by -- >Dhivya.A 
--  version -- > 0.4 startdate -- >15/10/2013 enddate -- > 15/10/2013 description -- > added comments and changed temp table CC_RENT_AMOUNT variable name as CC_PAYMENT_AMOUNT created by -- >Dhivya.A -- >issue tracker no :636
--  version -- > 0.3 startdate -- >24/07/2013 enddate -- > 24/07/2013 description -- > implemented roll back & commit commands created by -- >rajalakshmi.r -- >issue tracker no :566
--  version -- > 0.2 description -- > merged TEMP_EXTENSION_FEE_DETAIL sp & EXTENSION_FEE sp -- > startdate -- >08/07/2013 enddate -- > 08/07/2013 
--  version -- > 0.1 startdate -- >05/07/2013 enddate -- > 05/07/2013 description -- > temporary fee detail table for extension form created by -- >rajalakshmi.r -- >issue tracker no :345
DROP PROCEDURE IF EXISTS SP_CUSTOMER_EXTENSION_TEMP_FEE_DETAIL;
CREATE PROCEDURE SP_CUSTOMER_EXTENSION_TEMP_FEE_DETAIL(IN CUSTOMERID INTEGER,USERSTAMP VARCHAR(50),OUT EXTN_FEETMPTBLNAME TEXT)
BEGIN
DECLARE REC_VER INT;
DECLARE CID INTEGER;
DECLARE EXTN_TEMPTBLNAME TEXT;
DECLARE USERSTAMP_ID INT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK; 
END;
SET CID = CUSTOMERID;
START TRANSACTION;
--  TEMP TABLE NAME START
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID=(SELECT @ULDID);
SET EXTN_TEMPTBLNAME=(SELECT CONCAT('TEMP_CUSTOMER_EXTENSION_FEE_DETAIL',SYSDATE()));
--  temp table name
SET EXTN_TEMPTBLNAME=(SELECT REPLACE(EXTN_TEMPTBLNAME,' ',''));
SET EXTN_TEMPTBLNAME=(SELECT REPLACE(EXTN_TEMPTBLNAME,'-',''));
SET EXTN_TEMPTBLNAME=(SELECT REPLACE(EXTN_TEMPTBLNAME,':',''));
SET EXTN_FEETMPTBLNAME=(SELECT CONCAT(EXTN_TEMPTBLNAME,'_',USERSTAMP_ID)); 
--  TEMP TABLE NAME END
-- temp table create query for TEMP_CUSTOMER_EXTENSION_FEE_DETAIL
SET @TEMP_CUSTOMER_EXTENSION_FEE_DETAIL=(SELECT CONCAT('CREATE TABLE ',EXTN_FEETMPTBLNAME,'
(
EF_SNO INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
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
PREPARE TEMP_CUSTOMER_EXTENSION_FEE_DETAIL_STMT FROM @TEMP_CUSTOMER_EXTENSION_FEE_DETAIL;
EXECUTE TEMP_CUSTOMER_EXTENSION_FEE_DETAIL_STMT;
SET REC_VER = (SELECT MAX(CED_REC_VER) FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CID);
WHILE REC_VER !=0 DO
IF EXISTS (SELECT CED_REC_VER FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CID AND CED_REC_VER=REC_VER) THEN
-- insert query for TEMP_CUSTOMER_EXTENSION_FEE_DETAIL
SET @PAYMNTAMT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CID AND CED_REC_VER=REC_VER AND CPP_ID=1);
SET @DEPAMT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CID AND CED_REC_VER=REC_VER AND CPP_ID=2);
SET @PROCAMT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CID AND CED_REC_VER=REC_VER AND CPP_ID=3);
SET @AIRCONAMT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CID AND CED_REC_VER=REC_VER AND CPP_ID=4);
SET @ELECTAMT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CID AND CED_REC_VER=REC_VER AND CPP_ID=5);
SET @DRYCLEANAMT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CID AND CED_REC_VER=REC_VER AND CPP_ID=6);
SET @AIRCONQURTAMT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CID AND CED_REC_VER=REC_VER AND CPP_ID=7);
SET @CHKOUTCLNAMT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CID AND CED_REC_VER=REC_VER AND CPP_ID=8);
SET @INSERT_TEMP_CUSTOMER_EXTENSION_FEE_DETAIL=(SELECT CONCAT('INSERT INTO ',EXTN_FEETMPTBLNAME,' (CUSTOMER_ID,CUSTOMER_VER,CC_PAYMENT_AMOUNT,CC_DEPOSIT,CC_PROCESSING_FEE,CC_AIRCON_FIXED_FEE,CC_ELECTRICITY_CAP,CC_DRYCLEAN_FEE,CC_AIRCON_QUARTERLY_FEE,CC_CHECKOUT_CLEANING_FEE)
VALUES (',CID,',',REC_VER,',','
@PAYMNTAMT,
@DEPAMT,
@PROCAMT,
@AIRCONAMT,
@ELECTAMT,
@DRYCLEANAMT,
@AIRCONQURTAMT,
@CHKOUTCLNAMT)'));
PREPARE INSERT_TEMP_CUSTOMER_EXTENSION_FEE_DETAIL_STMT FROM @INSERT_TEMP_CUSTOMER_EXTENSION_FEE_DETAIL;
EXECUTE INSERT_TEMP_CUSTOMER_EXTENSION_FEE_DETAIL_STMT;
END IF;
SET REC_VER=REC_VER-1;
END WHILE;
COMMIT;
END;