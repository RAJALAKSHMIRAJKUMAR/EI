DROP PROCEDURE IF EXISTS SP_ALL_DOMAIN_ALTER_AUTO_INCREMENT;
CREATE PROCEDURE SP_ALL_DOMAIN_ALTER_AUTO_INCREMENT(
IN FILENAME TEXT,
IN USERSTAMP VARCHAR(50),
OUT SUCCESS_MESSAGE TEXT)

BEGIN
	DECLARE FAILURE_ECN_DATA TEXT;
	DECLARE FAIL_ECNDATA TEXT;
	DECLARE SUCCESS_ECNDATA TEXT;
	DECLARE FAILURE_ECNDATA TEXT;
	DECLARE SUCCESSECNDATA TEXT;
	DECLARE FAILUREECNDATA TEXT;
	DECLARE PATCHFILENAME VARCHAR(100);
	DECLARE PHSTATUS TINYINT;
	DECLARE MINID INTEGER;
	DECLARE MAXID INTEGER;
	DECLARE MAIN_TABLE_NAME TEXT;
	DECLARE PRIMARYID_HEADER VARCHAR(50);
	DECLARE TSTAMP VARCHAR(50);
	DECLARE PRIMARYID_MAXCOUNT INTEGER;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		DROP TABLE IF EXISTS TEMP_ALL_DOMAIN_TABLE_NAMES;
		ROLLBACK;
		INSERT INTO PATCH_HISTORY(PO_ID,PH_FILE_NAME,PH_STATUS,ULD_ID) VALUES (10,FILENAME,0,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
	END;
	SET AUTOCOMMIT = 0;
 	START TRANSACTION;
	SET FOREIGN_KEY_CHECKS = 0;
	SET SUCCESS_ECNDATA =  (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=469);
	SET FAILURE_ECNDATA =  (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=470);
	SET FAILURE_ECN_DATA = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=473);
	SET SUCCESSECNDATA = (SELECT REPLACE(SUCCESS_ECNDATA,'[FILENAME]',FILENAME));
	SET FAILUREECNDATA = (SELECT REPLACE(FAILURE_ECNDATA,'[FILENAME]',FILENAME));
	SET FAIL_ECNDATA = (SELECT REPLACE(FAILURE_ECN_DATA,'[FILENAME]',FILENAME));
	IF EXISTS(SELECT PH_FILE_NAME FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME AND PH_STATUS = 1) THEN
		SET SUCCESS_MESSAGE = FAILUREECNDATA;
	END IF;
	SET PATCHFILENAME = (SELECT PH_FILE_NAME FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME);
	SET PHSTATUS = (SELECT PH_STATUS FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME AND PH_STATUS = 0);
	IF ((PATCHFILENAME IS NOT NULL) AND (PHSTATUS = 0)) OR (PATCHFILENAME IS NULL)THEN
		DROP TABLE IF EXISTS TEMP_ALL_DOMAIN_TABLE_NAMES;
		CREATE TABLE TEMP_ALL_DOMAIN_TABLE_NAMES(ID INTEGER AUTO_INCREMENT,TTIPDATA VARCHAR(50),PRIMARY KEY(ID));
		INSERT INTO TEMP_ALL_DOMAIN_TABLE_NAMES(TTIPDATA) SELECT TTIP_DATA FROM TICKLER_TABID_PROFILE WHERE TTIP_ID NOT IN (68,69,94,95);
		SET MINID = (SELECT MIN(ID) FROM TEMP_ALL_DOMAIN_TABLE_NAMES);
		SET MAXID = (SELECT MAX(ID) FROM TEMP_ALL_DOMAIN_TABLE_NAMES);
		WHILE(MINID <= MAXID) DO
			SET MAIN_TABLE_NAME = (SELECT TRIM(TTIPDATA) FROM TEMP_ALL_DOMAIN_TABLE_NAMES WHERE ID = MINID);
			SET PRIMARYID_HEADER = (SELECT DISTINCT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = MAIN_TABLE_NAME AND COLUMN_KEY='PRI' AND TABLE_SCHEMA=(SELECT DATABASE())); 
			SET TSTAMP = (SELECT DISTINCT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = MAIN_TABLE_NAME AND COLUMN_NAME LIKE '%TIMESTAMP' AND TABLE_SCHEMA=(SELECT DATABASE()));
			SET @MAXCOUNT = (SELECT CONCAT('SELECT MAX(',PRIMARYID_HEADER,') INTO @MAXIMUM_COUNT FROM ',MAIN_TABLE_NAME,''));
			PREPARE MAXCOUNT_STMT FROM @MAXCOUNT;
			EXECUTE MAXCOUNT_STMT;
			SET PRIMARYID_MAXCOUNT = @MAXIMUM_COUNT;
			IF(PRIMARYID_MAXCOUNT IS NOT NULL)THEN
				SET @ALTER_QUERY = (SELECT CONCAT('ALTER TABLE ',MAIN_TABLE_NAME,' AUTO_INCREMENT = ',PRIMARYID_MAXCOUNT,''));
				PREPARE ALTER_QUERY_STMT FROM @ALTER_QUERY;
				EXECUTE ALTER_QUERY_STMT;
			END IF;
			SET MINID = MINID+1;
		END WHILE;
		DROP TABLE IF EXISTS TEMP_ALL_DOMAIN_TABLE_NAMES;
		INSERT INTO PATCH_HISTORY(PO_ID,PH_FILE_NAME,PH_STATUS,ULD_ID) VALUES (10,FILENAME,1,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		SET SUCCESS_MESSAGE = SUCCESSECNDATA;
		SET FOREIGN_KEY_CHECKS = 1;
	END IF;
	COMMIT;
END;
CALL SP_ALL_DOMAIN_ALTER_AUTO_INCREMENT(FILENAME,USERSTAMP,@SUCCESS_MESSAGE);