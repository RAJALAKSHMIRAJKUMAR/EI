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
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID=(SELECT @ULDID);
SET EXTN_TEMPTBLNAME=(SELECT CONCAT('TEMP_CUSTOMER_EXTENSION_FEE_DETAIL',SYSDATE()));
SET EXTN_TEMPTBLNAME=(SELECT REPLACE(EXTN_TEMPTBLNAME,' ',''));
SET EXTN_TEMPTBLNAME=(SELECT REPLACE(EXTN_TEMPTBLNAME,'-',''));
SET EXTN_TEMPTBLNAME=(SELECT REPLACE(EXTN_TEMPTBLNAME,':',''));
SET EXTN_FEETMPTBLNAME=(SELECT CONCAT(EXTN_TEMPTBLNAME,'_',USERSTAMP_ID)); 
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