-- version:0.5 --sdate:27/07/2014 --edate:27/07/2014 --issue:831 CMT:62--desc:CHANGED PATCH HISTORY VIEW IF STATUS=1 'SUCCESS' ELSE FAILURE  --done by:DHIVYA
-- version:0.4 --sdate:24/07/2014 --edate:24/07/2014 --issue:831 --desc:added out put variable n error msg  --done by:RL
-- version:0.3 --sdate:23/07/2014 --edate:23/07/2014 --issue:831 --desc:added VW_PATCH_HISTORY --done by:RL
-- version:0.2 --sdate:22/07/2014 --edate:22/07/2014 --issue:831 --desc:changed PO_FOLDER_ID datatype text changed to varchar(50) in PATCH_OBJECTS TABLE --done by:RL
-- version:0.1 --sdate:19/07/2014 --edate:19/07/2014 --issue:831 --desc:create query for patch domain --done by:RL

DROP PROCEDURE IF EXISTS SP_CREATE_PATCH_TABLES;
CREATE PROCEDURE SP_CREATE_PATCH_TABLES(
IN FILENAME TEXT,
IN USERSTAMP VARCHAR(50),
OUT SUCCESS_MESSAGE TEXT)
BEGIN
-- VARIABLE DECLARATION
	DECLARE FAILURE_ECN_DATA TEXT;
	DECLARE FAIL_ECNDATA TEXT;
    DECLARE SUCCESS_ECNDATA TEXT;
	DECLARE FAILURE_ECNDATA TEXT;
	DECLARE SUCCESSECNDATA TEXT;
	DECLARE FAILUREECNDATA TEXT;
	DECLARE PATCHFILENAME VARCHAR(100);
	DECLARE PHSTATUS TINYINT;
	
-- QUERY FOR ROLLBACK COMMAND
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK;
		INSERT INTO PATCH_HISTORY(PO_ID,PH_FILE_NAME,PH_STATUS,ULD_ID) VALUES (1,FILENAME,0,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		SET SUCCESS_MESSAGE = FAIL_ECNDATA;
	END;
	START TRANSACTION;
	SET FOREIGN_KEY_CHECKS = 0;
	
-- QUERY FOR GET ERROR MESSGAE FROM ERROR_MESSAGE_CONFIGURATION TABLE
	SET SUCCESS_ECNDATA = 'PATCH FILE [FILENAME] EXECUTED SUCCESSFULLY';	
	SET FAILURE_ECNDATA = 'PATCH FILE [FILENAME] ALREADY EXECUTED.RUN SOME OTHER FILE';	
	SET FAILURE_ECN_DATA = 'PATCH FILE [FILENAME] HAVING ISSUE';
	
-- QUERY FOR REPLACE [FILENAME]
	SET SUCCESSECNDATA = (SELECT REPLACE(SUCCESS_ECNDATA,'[FILENAME]',FILENAME));
	SET FAILUREECNDATA = (SELECT REPLACE(FAILURE_ECNDATA,'[FILENAME]',FILENAME));
	SET FAIL_ECNDATA = (SELECT REPLACE(FAILURE_ECN_DATA,'[FILENAME]',FILENAME));
	
-- QUERY FOR CHECK THE PASSING FILE NAME EXISTS IN PATCH_HISTORY TABLE
	IF EXISTS(SELECT PH_FILE_NAME FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME AND PH_STATUS = 1) THEN
		SET SUCCESS_MESSAGE = FAILUREECNDATA;
	END IF;
	
-- QUERY FOR CHECK THE PASSING FILE NAME NOT EXISTS IN PATCH_HISTORY TABLE
	SET PATCHFILENAME = (SELECT PH_FILE_NAME FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME);
	SET PHSTATUS = (SELECT PH_STATUS FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME AND PH_STATUS = 0);
	
	IF ((PATCHFILENAME IS NOT NULL) AND (PHSTATUS = 0)) OR (PATCHFILENAME IS NULL)THEN
	
-- QUERY FOR CREATE PATCH_OBJECTS TABLE
		DROP TABLE IF EXISTS PATCH_OBJECTS;
		CREATE TABLE PATCH_OBJECTS(
		PO_ID INTEGER AUTO_INCREMENT NOT NULL,
		PO_MODULE_NAME VARCHAR(50) NOT NULL,
		PO_FOLDER_ID VARCHAR(50) NOT NULL,
		PRIMARY KEY(PO_ID));
		
-- QUERY FOR VALUES IN PATCH_OBJECTS TABLE
		INSERT INTO PATCH_OBJECTS(PO_MODULE_NAME,PO_FOLDER_ID) VALUES ('CONFIGURATION','0Bwv4Rd7ZecjPNC02RzFTQkU4ZzA');
		INSERT INTO PATCH_OBJECTS(PO_MODULE_NAME,PO_FOLDER_ID) VALUES ('ACCESS RIGHTS','0Bwv4Rd7ZecjPenRhbV9Rb1A2VTg');
		INSERT INTO PATCH_OBJECTS(PO_MODULE_NAME,PO_FOLDER_ID) VALUES ('EMAIL','0Bwv4Rd7ZecjPdjlqVXlldEhHdFU');
		INSERT INTO PATCH_OBJECTS(PO_MODULE_NAME,PO_FOLDER_ID) VALUES ('UNIT','0Bwv4Rd7ZecjPSnJiaXBJaml5cWs');
		INSERT INTO PATCH_OBJECTS(PO_MODULE_NAME,PO_FOLDER_ID) VALUES ('CUSTOMER','0Bwv4Rd7ZecjPejdLTjczQmhxRlk');
		INSERT INTO PATCH_OBJECTS(PO_MODULE_NAME,PO_FOLDER_ID) VALUES ('ACCESS','0Bwv4Rd7ZecjPOEk3ajlObnQ3dUk');
		INSERT INTO PATCH_OBJECTS(PO_MODULE_NAME,PO_FOLDER_ID) VALUES ('PAYMENT','0Bwv4Rd7ZecjPUkRfcElRVVhLSk0');
		INSERT INTO PATCH_OBJECTS(PO_MODULE_NAME,PO_FOLDER_ID) VALUES ('EXPENSE','0Bwv4Rd7ZecjPbk9EdmVaSGR1U1k');
		INSERT INTO PATCH_OBJECTS(PO_MODULE_NAME,PO_FOLDER_ID) VALUES ('OCBC','0Bwv4Rd7ZecjPZGw0TVVuZjh2Qk0');
		INSERT INTO PATCH_OBJECTS(PO_MODULE_NAME,PO_FOLDER_ID) VALUES ('COMMON SP','0Bwv4Rd7ZecjPYV95bWs4QV81bEU');
		
-- QUERY FOR CREATE PATCH_HISTORY TABLE		
		DROP TABLE IF EXISTS PATCH_HISTORY;
		CREATE TABLE PATCH_HISTORY(
		PH_ID INTEGER NOT NULL AUTO_INCREMENT,
		PO_ID INTEGER NOT NULL,
		PH_FILE_NAME VARCHAR(100) NOT NULL UNIQUE,	
		PH_STATUS TINYINT NOT NULL,	
		ULD_ID INTEGER NOT NULL,
		PH_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		PRIMARY KEY(PH_ID),
		FOREIGN KEY(PO_ID) REFERENCES PATCH_OBJECTS(PO_ID),
		FOREIGN KEY(ULD_ID) REFERENCES USER_LOGIN_DETAILS(ULD_ID));
		SET FOREIGN_KEY_CHECKS = 1;
		
-- QUERY FOR CREATE PATCH HISTORY VIEW	
		CREATE OR REPLACE VIEW VW_PATCH_HISTORY AS
		SELECT PO.PO_MODULE_NAME, PH.PH_FILE_NAME,IF(PH.PH_STATUS=1,'SUCCESS','FAILURE')AS PH_STATUS, ULD.ULD_LOGINID, PH.PH_TIMESTAMP
		FROM PATCH_OBJECTS PO, PATCH_HISTORY PH, USER_LOGIN_DETAILS ULD WHERE PO.PO_ID = PH.PO_ID
		AND ULD.ULD_ID = PH.ULD_ID;
		
-- QUERY FOR INSERT VALUES IN PATCH_HISTORY
		INSERT INTO PATCH_HISTORY(PO_ID,PH_FILE_NAME,PH_STATUS,ULD_ID) VALUES (1,FILENAME,1,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		SET SUCCESS_MESSAGE = SUCCESSECNDATA;
		SET FOREIGN_KEY_CHECKS = 1;
	
	END IF;
	
	COMMIT;
END;

CALL SP_CREATE_PATCH_TABLES(FILENAME,USERSTAMP,@SUCCESS_MESSAGE);