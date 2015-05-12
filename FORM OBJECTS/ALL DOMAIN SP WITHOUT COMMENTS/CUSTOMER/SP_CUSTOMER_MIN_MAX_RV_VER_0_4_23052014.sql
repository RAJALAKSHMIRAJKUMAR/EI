DROP PROCEDURE IF EXISTS SP_CUSTOMER_MIN_MAX_RV;
CREATE PROCEDURE SP_CUSTOMER_MIN_MAX_RV(IN USERSTAMP VARCHAR(50),CUSTID INTEGER,OUT MNMAXTBLNAME TEXT)
BEGIN
DECLARE MIN_CUSTRV INTEGER;
DECLARE MAX_CUSTRV INTEGER;
DECLARE TNAME TEXT;
DECLARE USERSTAMP_ID INT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
END;
START TRANSACTION;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID=(SELECT @ULDID);
SET TNAME=(SELECT CONCAT('TEMP_CUSTOMER_MIN_MAX_RV_',SYSDATE()));
SET TNAME=(SELECT REPLACE(TNAME,' ',''));
SET TNAME=(SELECT REPLACE(TNAME,'-',''));
SET TNAME=(SELECT REPLACE(TNAME,':',''));
SET TNAME=(SELECT CONCAT(TNAME,'_',USERSTAMP_ID));
SET MNMAXTBLNAME=TNAME; 
SET @CREATE_TEMP_CUSTOMER_MIN_MAX_RV=(SELECT CONCAT('CREATE TABLE ',TNAME,'(TCMM_ID INTEGER AUTO_INCREMENT NOT NULL,TCMM_CUSTOMERID INTEGER,TCMM_MINRV INTEGER,TCMM_MAXRV INTEGER,PRIMARY KEY(TCMM_ID))'));
PREPARE CREATE_TEMP_CUSTOMER_MIN_MAX_RV_STMT FROM @CREATE_TEMP_CUSTOMER_MIN_MAX_RV;
EXECUTE CREATE_TEMP_CUSTOMER_MIN_MAX_RV_STMT;
	SET MIN_CUSTRV=(SELECT MAX(CED.CED_REC_VER) FROM CUSTOMER_ENTRY_DETAILS CED,CUSTOMER_LP_DETAILS CLP WHERE CED_RECHECKIN IS NOT NULL AND  IF(CLP.CLP_PRETERMINATE_DATE IS NOT NULL,CLP.CLP_STARTDATE< CLP.CLP_PRETERMINATE_DATE,CLP.CLP_STARTDATE< CLP.CLP_ENDDATE) AND CED.CUSTOMER_ID=CUSTID);
	SET MAX_CUSTRV=(SELECT MAX(CED.CED_REC_VER) FROM CUSTOMER_ENTRY_DETAILS CED,CUSTOMER_LP_DETAILS CLP WHERE IF(CLP.CLP_PRETERMINATE_DATE IS NOT NULL,CLP.CLP_STARTDATE< CLP.CLP_PRETERMINATE_DATE,CLP.CLP_STARTDATE< CLP.CLP_ENDDATE) AND CED.CUSTOMER_ID=CUSTID);
	IF MIN_CUSTRV IS NOT NULL THEN
		SET @INSERT_TEMP_CUSTOMER_MIN_MAX_RV=(SELECT CONCAT('INSERT INTO ',TNAME,'(TCMM_CUSTOMERID,TCMM_MINRV,TCMM_MAXRV)VALUES(',CUSTID,',',MIN_CUSTRV,',',MAX_CUSTRV,')'));
		PREPARE INSERT_TEMP_CUSTOMER_MIN_MAX_RV_STMT FROM @INSERT_TEMP_CUSTOMER_MIN_MAX_RV;
		EXECUTE INSERT_TEMP_CUSTOMER_MIN_MAX_RV_STMT;
	ELSE
		SET MIN_CUSTRV=(SELECT MIN(CED.CED_REC_VER) FROM CUSTOMER_ENTRY_DETAILS CED,CUSTOMER_LP_DETAILS CLP WHERE IF(CLP.CLP_PRETERMINATE_DATE IS NOT NULL,CLP.CLP_STARTDATE< CLP.CLP_PRETERMINATE_DATE,CLP.CLP_STARTDATE< CLP.CLP_ENDDATE) AND CED.CUSTOMER_ID=CUSTID);
		SET @INSERT_TEMP_CUSTOMER_MIN_MAX_RV=(SELECT CONCAT('INSERT INTO ',TNAME,'(TCMM_CUSTOMERID,TCMM_MINRV,TCMM_MAXRV)VALUES(',CUSTID,',',MIN_CUSTRV,',',MAX_CUSTRV,')'));
		PREPARE INSERT_TEMP_CUSTOMER_MIN_MAX_RV_STMT FROM @INSERT_TEMP_CUSTOMER_MIN_MAX_RV;
		EXECUTE INSERT_TEMP_CUSTOMER_MIN_MAX_RV_STMT;
	END IF;	
COMMIT;
END;