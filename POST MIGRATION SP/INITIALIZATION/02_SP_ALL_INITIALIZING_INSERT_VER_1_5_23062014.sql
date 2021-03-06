DROP PROCEDURE IF EXISTS SP_ALL_INITIALIZING_INSERT;
CREATE PROCEDURE SP_ALL_INITIALIZING_INSERT(IN SOURCESCHEMA  VARCHAR(40),IN DESTINATIONSCHEMA  VARCHAR(40),IN USER_STAMP VARCHAR(50))
BEGIN
DECLARE START_TIME TIME;
DECLARE END_TIME TIME;
DECLARE DURATION TIME;    
DECLARE MIN_RID INTEGER;
DECLARE MAX_RID INTEGER;
DECLARE MIN_URC_ID INTEGER;
DECLARE MAX_URC_ID INTEGER;
DECLARE URCDATA TEXT;
DECLARE CFDATA TEXT;
DECLARE MIN_ULDID INTEGER;
DECLARE MAX_ULDID INTEGER;
DECLARE LOGINID VARCHAR(50);
DECLARE URCUSERSTAMP VARCHAR(50);
DECLARE URCTIMESTAMP VARCHAR(50);
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
END;
START TRANSACTION; 
SET FOREIGN_KEY_CHECKS=0;
SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',USER_STAMP,'"'));
PREPARE LOGINID FROM @LOGIN_ID;
EXECUTE LOGINID;
DROP TABLE IF EXISTS TEMP_USER_RIGHTS_SCDB_FORMAT;
CREATE TABLE TEMP_USER_RIGHTS_SCDB_FORMAT AS SELECT * FROM USER_RIGHTS_SCDB_FORMAT;
ALTER TABLE TEMP_USER_RIGHTS_SCDB_FORMAT MODIFY COLUMN Rid INTEGER;
SET @DROP_TICKLER_HISTORY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TICKLER_HISTORY'));
PREPARE DROP_TICKLER_HISTORY_STMT FROM @DROP_TICKLER_HISTORY;
EXECUTE DROP_TICKLER_HISTORY_STMT;
SET @CREATE_TICKLER_HISTORY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TICKLER_HISTORY(
TH_ID INTEGER NOT NULL AUTO_INCREMENT,
TP_ID INTEGER NOT NULL,
CUSTOMER_ID INTEGER NULL,
TTIP_ID INTEGER NOT NULL,
TH_OLD_VALUE TEXT NOT NULL,    
TH_NEW_VALUE TEXT NULL,    
ULD_ID INTEGER(2) NOT NULL,
TH_TIMESTAMP  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY(TH_ID),
FOREIGN KEY(TP_ID) REFERENCES ',DESTINATIONSCHEMA,'.TICKLER_PROFILE(TP_ID),
FOREIGN KEY(TTIP_ID) REFERENCES ',DESTINATIONSCHEMA,'.TICKLER_TABID_PROFILE(TTIP_ID),
FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
PREPARE CREATE_TICKLER_HISTORY_STMT FROM @CREATE_TICKLER_HISTORY;
EXECUTE CREATE_TICKLER_HISTORY_STMT;
SET @DROP_TRIGGER_EXECUTION_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TRIGGER_EXECUTION_DETAILS'));
PREPARE DROP_TRIGGER_EXECUTION_DETAILS_STMT FROM @DROP_TRIGGER_EXECUTION_DETAILS;
EXECUTE DROP_TRIGGER_EXECUTION_DETAILS_STMT;
SET @CREATE_TRIGGER_EXECUTION_DETAILS=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TRIGGER_EXECUTION_DETAILS(
TED_ID INTEGER NOT NULL AUTO_INCREMENT,
TC_ID INTEGER NOT NULL,
TED_TIME DATETIME NOT NULL,
ULD_ID INTEGER(2) NOT NULL,
TED_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY(TED_ID),
FOREIGN KEY(TC_ID) REFERENCES ',DESTINATIONSCHEMA,'.TRIGGER_CONFIGURATION(TC_ID),
FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
PREPARE CREATE_TRIGGER_EXECUTION_DETAILS_STMT FROM @CREATE_TRIGGER_EXECUTION_DETAILS;
EXECUTE CREATE_TRIGGER_EXECUTION_DETAILS_STMT;
SET START_TIME = (SELECT CURTIME());
SET @DROP_POST_AUDIT_PROFILE=(SELECT CONCAT('DROP TABLE IF EXISTS ',SOURCESCHEMA,'.POST_AUDIT_PROFILE'));
PREPARE DROP_POST_AUDIT_PROFILE_STMT FROM @DROP_POST_AUDIT_PROFILE;
EXECUTE DROP_POST_AUDIT_PROFILE_STMT;
SET @CREATE_POST_AUDIT_PROFILE=(SELECT CONCAT('CREATE TABLE ',SOURCESCHEMA,'.POST_AUDIT_PROFILE(
POSTAP_ID INTEGER NOT NULL AUTO_INCREMENT,
POSTAP_DATA	VARCHAR(50) NOT NULL,
PRIMARY KEY(POSTAP_ID))'));
PREPARE CREATE_POST_AUDIT_PROFILE_STMT FROM @CREATE_POST_AUDIT_PROFILE;
EXECUTE CREATE_POST_AUDIT_PROFILE_STMT;
SET @INSERT_POST_AUDIT_PROFILE=(SELECT CONCAT('INSERT INTO ',SOURCESCHEMA,'. POST_AUDIT_PROFILE(POSTAP_DATA) (SELECT POSTAP_DATA FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE POSTAP_DATA IS NOT NULL)'));
PREPARE INSERT_POST_AUDIT_PROFILE_STMT FROM @INSERT_POST_AUDIT_PROFILE;
EXECUTE INSERT_POST_AUDIT_PROFILE_STMT;
SET END_TIME = (SELECT CURTIME());
SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
SET @COUNTPOST_AUDIT_PROFILE_SQL_FORMAT = (SELECT CONCAT('SELECT COUNT(POSTAP_DATA) INTO @COUNT_POST_AUDIT_PROFILE_SQL_FORMAT FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE POSTAP_DATA IS NOT NULL'));
PREPARE COUNTPOST_AUDIT_PROFILE_SQL_FORMAT_STMT FROM @COUNTPOST_AUDIT_PROFILE_SQL_FORMAT;
EXECUTE COUNTPOST_AUDIT_PROFILE_SQL_FORMAT_STMT;	
SET @COUNTSPLITING_POST_AUDIT_PROFILE=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_POST_AUDIT_PROFILE FROM ',SOURCESCHEMA,'.POST_AUDIT_PROFILE'));
PREPARE COUNTSPLITING_POST_AUDIT_PROFILE_STMT FROM @COUNTSPLITING_POST_AUDIT_PROFILE;
EXECUTE COUNTSPLITING_POST_AUDIT_PROFILE_STMT;	
SET @REJECTION_COUNT=(@COUNT_POST_AUDIT_PROFILE_SQL_FORMAT-@COUNT_SPLITING_POST_AUDIT_PROFILE);		
UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC = @COUNT_POST_AUDIT_PROFILE_SQL_FORMAT WHERE PREASP_DATA='POST_AUDIT_PROFILE';
INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='POST_AUDIT_PROFILE'),@COUNT_SPLITING_POST_AUDIT_PROFILE,(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='POST_AUDIT_PROFILE'),(SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CONFIGURATION'),DURATION,@REJECTION_COUNT,@ULDID);
SET START_TIME = (SELECT CURTIME());	
SET @DROP_TICKLER_TABLE_PROFILE=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TICKLER_TABID_PROFILE'));
PREPARE DROP_TICKLER_TABLE_PROFILE_STMT FROM @DROP_TICKLER_TABLE_PROFILE;
EXECUTE DROP_TICKLER_TABLE_PROFILE_STMT;
SET @CREATE_TICKLER_TABLE_PROFILE=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TICKLER_TABID_PROFILE(
TTIP_ID INTEGER NOT NULL AUTO_INCREMENT,
TTIP_DATA	VARCHAR(50) NOT NULL,
PRIMARY KEY(TTIP_ID))'));
PREPARE CREATE_TICKLER_TABLE_PROFILE_STMT FROM @CREATE_TICKLER_TABLE_PROFILE;
EXECUTE CREATE_TICKLER_TABLE_PROFILE_STMT;
SET @INSERT_TICKLER_TABLE_PROFILE=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'. TICKLER_TABID_PROFILE(TTIP_DATA) (SELECT POSTAP_DATA FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE POSTAP_DATA IS NOT NULL)'));
PREPARE INSERT_TICKLER_TABLE_PROFILE_STMT FROM @INSERT_TICKLER_TABLE_PROFILE;
EXECUTE INSERT_TICKLER_TABLE_PROFILE_STMT;
SET END_TIME = (SELECT CURTIME());
SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
SET @COUNTPOST_AUDIT_PROFILE_SQL_FORMAT = (SELECT CONCAT('SELECT COUNT(POSTAP_DATA) INTO @COUNT_POST_AUDIT_PROFILE_SQL_FORMAT FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE POSTAP_DATA IS NOT NULL'));
PREPARE COUNTPOST_AUDIT_PROFILE_SQL_FORMAT_STMT FROM @COUNTPOST_AUDIT_PROFILE_SQL_FORMAT;
EXECUTE COUNTPOST_AUDIT_PROFILE_SQL_FORMAT_STMT;	
SET @COUNTSPLITING_POST_AUDIT_PROFILE=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_POST_AUDIT_PROFILE FROM ',DESTINATIONSCHEMA,'.TICKLER_TABID_PROFILE'));
PREPARE COUNTSPLITING_POST_AUDIT_PROFILE_STMT FROM @COUNTSPLITING_POST_AUDIT_PROFILE;
EXECUTE COUNTSPLITING_POST_AUDIT_PROFILE_STMT;	
SET @REJECTION_COUNT=(@COUNT_POST_AUDIT_PROFILE_SQL_FORMAT-@COUNT_SPLITING_POST_AUDIT_PROFILE);		
UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC = @COUNT_POST_AUDIT_PROFILE_SQL_FORMAT WHERE PREASP_DATA='TICKLER_TABID_PROFILE';
INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='TICKLER_TABID_PROFILE'),@COUNT_SPLITING_POST_AUDIT_PROFILE,(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='TICKLER_TABID_PROFILE'),(SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CONFIGURATION'),DURATION,@REJECTION_COUNT,@ULDID);
SET START_TIME = (SELECT CURTIME());	
SET @DROP_CONFIGURATION_PROFILE=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.CONFIGURATION_PROFILE'));
PREPARE DROP_CONFIGURATION_PROFILE_STMT FROM @DROP_CONFIGURATION_PROFILE;
EXECUTE DROP_CONFIGURATION_PROFILE_STMT;	
SET @CREATE_CONFIGURATION_PROFILE=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.CONFIGURATION_PROFILE(		
CNP_ID INTEGER NOT NULL	AUTO_INCREMENT,
CNP_DATA VARCHAR(25) UNIQUE	NOT NULL,
PRIMARY KEY(CNP_ID))'));	
PREPARE CREATE_CONFIGURATION_PROFILE_STMT FROM @CREATE_CONFIGURATION_PROFILE;
EXECUTE CREATE_CONFIGURATION_PROFILE_STMT;
SET @INSERT_CONFIGURATION_PROFILE=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.CONFIGURATION_PROFILE(CNP_DATA) SELECT CNP_DATA FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE CNP_DATA IS NOT NULL'));
PREPARE INSERT_CONFIGURATION_PROFILE_STMT FROM @INSERT_CONFIGURATION_PROFILE;
EXECUTE INSERT_CONFIGURATION_PROFILE_STMT;
SET END_TIME = (SELECT CURTIME());
SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
SET @COUNTCONFIG_SQL_FORMAT =(SELECT CONCAT('SELECT COUNT(CNP_DATA) INTO @COUNT_CONFIG_SQL_FORMAT FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE CNP_DATA IS NOT NULL'));
PREPARE COUNTCONFIG_SQL_FORMAT_STMT FROM @COUNTCONFIG_SQL_FORMAT;
EXECUTE COUNTCONFIG_SQL_FORMAT_STMT;
SET @COUNTSPLITING_CONFIGURATION_PROFILE = (SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_CONFIGURATION_PROFILE FROM ',DESTINATIONSCHEMA,'.CONFIGURATION_PROFILE'));
PREPARE COUNTSPLITING_CONFIGURATION_PROFILE_STMT FROM @COUNTSPLITING_CONFIGURATION_PROFILE;
EXECUTE COUNTSPLITING_CONFIGURATION_PROFILE_STMT;
SET @REJECTION_COUNT=(@COUNT_CONFIG_SQL_FORMAT-@COUNT_SPLITING_CONFIGURATION_PROFILE);
UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC = @COUNT_CONFIG_SQL_FORMAT WHERE PREASP_DATA='CONFIGURATION_PROFILE';
INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='CONFIGURATION_PROFILE'),@COUNT_SPLITING_CONFIGURATION_PROFILE,(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='CONFIGURATION_PROFILE'),(SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CONFIGURATION'),DURATION,@REJECTION_COUNT,@ULDID);
SET START_TIME = (SELECT CURTIME());	
SET @DROP_CONFIGURATION=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.CONFIGURATION'));
PREPARE DROP_CONFIGURATION_STMT FROM @DROP_CONFIGURATION;
EXECUTE DROP_CONFIGURATION_STMT;	
SET @CREATE_CONFIGURATION=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.CONFIGURATION(
CGN_ID INTEGER NOT NULL AUTO_INCREMENT,
CNP_ID INTEGER NOT NULL,
CGN_TYPE VARCHAR(50) UNIQUE	NOT NULL,
CGN_NON_IP_FLAG	CHAR(2) NULL,
PRIMARY KEY(CGN_ID),
FOREIGN KEY(CNP_ID) REFERENCES ',DESTINATIONSCHEMA,'.CONFIGURATION_PROFILE(CNP_ID))'));
PREPARE CREATE_CONFIGURATION_STMT FROM @CREATE_CONFIGURATION;
EXECUTE CREATE_CONFIGURATION_STMT;
SET @INSERT_CONFIGURATION=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.CONFIGURATION(CGN_TYPE,CNP_ID,CGN_NON_IP_FLAG) 
(SELECT DISTINCT(CSQL.CGN_DATA),CNP_ID,CGN_NON_IP_FLAG FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT CSQL  WHERE CSQL.CGN_DATA IS NOT NULL)'));
PREPARE INSERT_CONFIGURATION_STMT FROM @INSERT_CONFIGURATION;
EXECUTE INSERT_CONFIGURATION_STMT;
SET END_TIME = (SELECT CURTIME());
SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
SET @COUNTCONFIGURTION_SQL_FORMAT = (SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_CONFIGURTION_SQL_FORMAT  FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT CSQL  WHERE CSQL.CGN_DATA IS NOT NULL'));
PREPARE COUNTCONFIGURTION_SQL_FORMAT_STMT FROM @COUNTCONFIGURTION_SQL_FORMAT;
EXECUTE COUNTCONFIGURTION_SQL_FORMAT_STMT;
SET @COUNTSPLITING_CONFIGURATION = (SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_CONFIGURATION FROM  ',DESTINATIONSCHEMA,'.CONFIGURATION'));
PREPARE COUNTSPLITING_CONFIGURATION_STMT FROM @COUNTSPLITING_CONFIGURATION;
EXECUTE COUNTSPLITING_CONFIGURATION_STMT;
SET @REJECTION_COUNT=(@COUNT_CONFIGURTION_SQL_FORMAT-@COUNT_SPLITING_CONFIGURATION);
UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC = @COUNT_CONFIGURTION_SQL_FORMAT WHERE PREASP_DATA='CONFIGURATION';
INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='CONFIGURATION'),@COUNT_SPLITING_CONFIGURATION,(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='CONFIGURATION'),
(SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CONFIGURATION'),DURATION,@REJECTION_COUNT,@ULDID);
SET START_TIME = (SELECT CURTIME());
SET @DROP_USER_RIGHTS_CONFIGURATION=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION'));
	PREPARE DROP_USER_RIGHTS_CONFIGURATION_STMT FROM @DROP_USER_RIGHTS_CONFIGURATION;
	EXECUTE DROP_USER_RIGHTS_CONFIGURATION_STMT;
	SET @CREATE_USER_RIGHTS_CONFIGURATION=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION(
	URC_ID INTEGER(2) NOT NULL AUTO_INCREMENT,
	CGN_ID INTEGER NOT NULL,
	URC_DATA TEXT NOT NULL,
	URC_INITIALIZE_FLAG	CHAR(1) NULL,
	URC_USERSTAMP VARCHAR(50) NOT NULL,
	URC_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(URC_ID),
	FOREIGN KEY(CGN_ID) REFERENCES ',DESTINATIONSCHEMA,'.CONFIGURATION(CGN_ID))'));
	PREPARE CREATE_USER_RIGHTS_CONFIGURATION_STMT FROM @CREATE_USER_RIGHTS_CONFIGURATION;
	EXECUTE CREATE_USER_RIGHTS_CONFIGURATION_STMT;
	SET @INSERT_USER_RIGHTS_CONFIGURATION=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION(CGN_ID,URC_DATA,URC_INITIALIZE_FLAG,URC_USERSTAMP,URC_TIMESTAMP) 
	SELECT CGN_ID,DATA,INITIALIZE_FLAG,USER_STAMP,TIMESTAMP FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE CGN_ID IN (43,66,67,68) AND DATA IS NOT NULL'));
	PREPARE INSERT_USER_RIGHTS_CONFIGURATION_STMT FROM @INSERT_USER_RIGHTS_CONFIGURATION;
	EXECUTE INSERT_USER_RIGHTS_CONFIGURATION_STMT;
	SET @MINURC_ID = (SELECT CONCAT('SELECT MIN(URC_ID) INTO @MINURCID FROM ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION'));
	PREPARE MINURC_ID_STMT FROM @MINURC_ID;
	EXECUTE MINURC_ID_STMT;
	SET @MAXURC_ID = (SELECT CONCAT('SELECT MAX(URC_ID) INTO @MAXURCID FROM ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION'));
	PREPARE MAXURC_ID_STMT FROM @MAXURC_ID;
	EXECUTE MAXURC_ID_STMT;
	SET MIN_URC_ID = @MINURCID;
	SET MAX_URC_ID = @MAXURCID;
	WHILE(MIN_URC_ID <= MAX_URC_ID)DO
		SET @RIGHTSDATA = (SELECT CONCAT('SELECT URC_DATA INTO @RIGHTS_DATA FROM ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION WHERE URC_ID=',MIN_URC_ID,''));
		PREPARE RIGHTSDATA_STMT FROM @RIGHTSDATA;
		EXECUTE RIGHTSDATA_STMT;
		SET URCDATA = @RIGHTS_DATA;
		SET @URDATA = (SELECT CONCAT('SELECT CF_DATA INTO @UR_DATA FROM ',DESTINATIONSCHEMA,'.TEMP_CONFIG_SCDB_FORMAT WHERE CF_DATA=','"',URCDATA,'"'));
		PREPARE URDATA_STMT FROM @URDATA;
		EXECUTE URDATA_STMT;
		SET CFDATA = @UR_DATA;
		IF(URCDATA = CFDATA)THEN
			SET @RUSERSTAMP = (SELECT CONCAT('SELECT USERSTAMP INTO @RIGHTS_USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_CONFIG_SCDB_FORMAT WHERE CF_DATA = ','"',URCDATA,'"'));
			PREPARE RUSERSTAMP_STMT FROM @RUSERSTAMP;
			EXECUTE RUSERSTAMP_STMT;
			SET URCUSERSTAMP = @RIGHTS_USERSTAMP;
			SET @UPDATE_USERSTAMP = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION SET URC_USERSTAMP=','"',URCUSERSTAMP,'"',' WHERE URC_ID=',MIN_URC_ID,''));
			PREPARE UPDATE_USERSTAMP_STMT FROM @UPDATE_USERSTAMP;
			EXECUTE UPDATE_USERSTAMP_STMT;
			SET @TIME_STAMP = (SELECT CONCAT('SELECT TIMESTAMP INTO @RIGHTS_TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_CONFIG_SCDB_FORMAT WHERE CF_DATA = ','"',URCDATA,'"'));
			PREPARE TIME_STAMP_STMT FROM @TIME_STAMP;
			EXECUTE TIME_STAMP_STMT;
			SET URCTIMESTAMP = @RIGHTS_TIMESTAMP;
			SET @UPDATE_TIMESTAMP = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION SET URC_TIMESTAMP=','"',URCTIMESTAMP,'"',' WHERE URC_ID=',MIN_URC_ID,''));
			PREPARE UPDATE_TIMESTAMP_STMT FROM @UPDATE_TIMESTAMP;
			EXECUTE UPDATE_TIMESTAMP_STMT;
		END IF;
		SET MIN_URC_ID = MIN_URC_ID+1;
	END WHILE;
SET END_TIME = (SELECT CURTIME());
SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
SET @COUNTUSER_RIGHTS_CONFIGURATION_SQL_FORMAT = (SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_USER_RIGHTS_CONFIGURATION_SQL_FORMAT FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT CSQL   WHERE CGN_ID IN (43,66,67,68) AND DATA IS NOT NULL'));
PREPARE COUNTUSER_RIGHTS_CONFIGURATION_SQL_FORMAT_STMT FROM @COUNTUSER_RIGHTS_CONFIGURATION_SQL_FORMAT;
EXECUTE COUNTUSER_RIGHTS_CONFIGURATION_SQL_FORMAT_STMT;
SET @COUNTSPLITING_USER_RIGHTS_CONFIGURATION = (SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_USER_RIGHTS_CONFIGURATION FROM ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION'));
PREPARE COUNTSPLITING_USER_RIGHTS_CONFIGURATION_STMT FROM @COUNTSPLITING_USER_RIGHTS_CONFIGURATION;
EXECUTE COUNTSPLITING_USER_RIGHTS_CONFIGURATION_STMT;
SET @REJECTION_COUNT=(@COUNT_USER_RIGHTS_CONFIGURATION_SQL_FORMAT-@COUNT_SPLITING_USER_RIGHTS_CONFIGURATION);
UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC = @COUNT_USER_RIGHTS_CONFIGURATION_SQL_FORMAT WHERE PREASP_DATA='USER_RIGHTS_CONFIGURATION';
INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='USER_RIGHTS_CONFIGURATION'),@COUNT_SPLITING_USER_RIGHTS_CONFIGURATION,
(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='USER_RIGHTS_CONFIGURATION'),
(SELECT PREAMP_ID FROM .PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CONFIGURATION'),DURATION,@REJECTION_COUNT,@ULDID);
 SET @DROP_TEMP_USERRIGHTS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_RIGHTS_CONFIGURATION'));
PREPARE DROP_TEMP_USERRIGHTS_STMT FROM@DROP_TEMP_USERRIGHTS;
EXECUTE DROP_TEMP_USERRIGHTS_STMT;
SET START_TIME = (SELECT CURTIME());
SET @DROP_ROLE_CREATION=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.ROLE_CREATION'));
PREPARE DROP_ROLE_CREATION_STMT FROM @DROP_ROLE_CREATION;
EXECUTE DROP_ROLE_CREATION_STMT;    
SET @CREATE_ROLE_CREATION=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.ROLE_CREATION(
RC_ID INTEGER(2) NOT NULL AUTO_INCREMENT,
URC_ID INTEGER(2) NOT NULL,
RC_NAME    VARCHAR(15)    UNIQUE NOT NULL,
RC_USERSTAMP VARCHAR(50) NOT NULL,
RC_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY(RC_ID),
FOREIGN KEY(URC_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION (URC_ID))'));
PREPARE CREATE_ROLE_CREATION_STMT FROM @CREATE_ROLE_CREATION;
EXECUTE CREATE_ROLE_CREATION_STMT;    
SET @DROP_TEMP_ROLE_CREATION=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_ROLE_CREATION'));
PREPARE DROP_TEMP_ROLE_CREATION_STMT FROM @DROP_TEMP_ROLE_CREATION;
EXECUTE DROP_TEMP_ROLE_CREATION_STMT;    
SET @CREATE_TEMP_ROLE_CREATION=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_ROLE_CREATION(
ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
ROLES VARCHAR(255) NULL,
RACESS VARCHAR(255) NULL,
RUSERSTAMP VARCHAR(255) NULL,
RTIMESTAMP TIMESTAMP NULL)'));
PREPARE CREATE_TEMP_ROLE_CREATION_STMT FROM @CREATE_TEMP_ROLE_CREATION;
EXECUTE CREATE_TEMP_ROLE_CREATION_STMT;
SET @INSERT_TEMP_ROLE_CREATION=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_ROLE_CREATION(ROLES,RACESS,RUSERSTAMP,RTIMESTAMP)
SELECT DISTINCT ROLES,RACESS,USERSTAMP,TIMESTAMP FROM ',SOURCESCHEMA,'.USER_RIGHTS_SCDB_FORMAT WHERE ROLES IS NOT NULL GROUP BY ROLES'));
PREPARE INSERT_TEMP_ROLE_CREATION_STMT FROM @INSERT_TEMP_ROLE_CREATION;
EXECUTE INSERT_TEMP_ROLE_CREATION_STMT;
SET @MINRIDSTMT=(SELECT CONCAT('SELECT MIN(ID) INTO @MINRID FROM ',DESTINATIONSCHEMA,'.TEMP_ROLE_CREATION'));
PREPARE MINRID_STMT FROM @MINRIDSTMT;
EXECUTE MINRID_STMT;
SET MIN_RID=@MINRID ;
SET @MAXRIDSTMT=(SELECT CONCAT('SELECT MAX(ID) INTO @MAXRID FROM ',DESTINATIONSCHEMA,'.TEMP_ROLE_CREATION'));
PREPARE MAXRID_STMT FROM @MAXRIDSTMT;
EXECUTE MAXRID_STMT;
SET MAX_RID=@MAXRID;
WHILE (MIN_RID<=MAX_RID) DO
SET @INSERT_ROLE_CREATION=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.ROLE_CREATION(URC_ID,RC_NAME,RC_USERSTAMP,RC_TIMESTAMP)VALUES((SELECT URC_ID FROM ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION WHERE URC_DATA=(SELECT RACESS FROM ',DESTINATIONSCHEMA,'.TEMP_ROLE_CREATION WHERE ID=',MIN_RID,')),(SELECT ROLES FROM ',DESTINATIONSCHEMA,'.TEMP_ROLE_CREATION WHERE ID=',MIN_RID,'),(SELECT RUSERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_ROLE_CREATION WHERE ID=',MIN_RID,'),(SELECT RTIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_ROLE_CREATION WHERE ID='
,MIN_RID,') )'));    
SET MIN_RID=MIN_RID+1;
PREPARE INSERT_ROLE_CREATION_STMT FROM @INSERT_ROLE_CREATION;
EXECUTE INSERT_ROLE_CREATION_STMT;
END WHILE;
SET @UPDATETIMESTAMP=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.ROLE_CREATION SET RC_TIMESTAMP=(SELECT CONVERT_TZ(RC_TIMESTAMP, "+08:00","+0:00"))'));
PREPARE UPDATETIMESTAMPSTMT FROM @UPDATETIMESTAMP;
EXECUTE UPDATETIMESTAMPSTMT;
SET END_TIME = (SELECT CURTIME());
SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
SET @COUNTROLE_CREATION_SCDB_FORMAT = (SELECT CONCAT('SELECT COUNT(distinct(roles)) INTO @COUNT_ROLE_CREATION_SCDB_FORMAT FROM  ',SOURCESCHEMA,'.USER_RIGHTS_SCDB_FORMAT WHERE roles IS NOT NULL'));
PREPARE COUNTROLE_CREATION_SCDB_FORMAT_STMT FROM @COUNTROLE_CREATION_SCDB_FORMAT;
EXECUTE COUNTROLE_CREATION_SCDB_FORMAT_STMT;
SET @COUNTSPLITING_ROLE_CREATION = (SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_ROLE_CREATION FROM ',DESTINATIONSCHEMA,'.ROLE_CREATION'));
PREPARE COUNTSPLITING_ROLE_CREATION_STMT FROM @COUNTSPLITING_ROLE_CREATION;
EXECUTE COUNTSPLITING_ROLE_CREATION_STMT;
SET @REJECTION_COUNT=(@COUNT_ROLE_CREATION_SCDB_FORMAT-@COUNT_SPLITING_ROLE_CREATION);
UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC = @COUNT_ROLE_CREATION_SCDB_FORMAT WHERE PREASP_DATA='ROLE_CREATION';
INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='ROLE_CREATION'),@COUNT_SPLITING_ROLE_CREATION,
(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='ROLE_CREATION'),
(SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='USER RIGHTS'),DURATION,@REJECTION_COUNT,@ULDID);
SET START_TIME = (SELECT CURTIME());
SET @DROP_USER_LOGIN_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS'));
PREPARE DROP_USER_LOGIN_DETAILS_STMT FROM @DROP_USER_LOGIN_DETAILS;
EXECUTE DROP_USER_LOGIN_DETAILS_STMT;
SET @CREATE_USER_LOGIN_DETAILS=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(
ULD_ID INTEGER(2) NOT NULL AUTO_INCREMENT,		
ULD_LOGINID	VARCHAR(40)	UNIQUE NOT NULL,
ULD_USERSTAMP VARCHAR(50) NOT NULL,
ULD_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY(ULD_ID))'));
PREPARE CREATE_USER_LOGIN_DETAILS_STMT FROM @CREATE_USER_LOGIN_DETAILS;
EXECUTE CREATE_USER_LOGIN_DETAILS_STMT;
DROP TABLE IF EXISTS TEMP_USER_LOGIN_DETAILS;
CREATE TABLE TEMP_USER_LOGIN_DETAILS(
ULD_ID INTEGER(2) NOT NULL AUTO_INCREMENT,		
ULD_LOGINID	VARCHAR(40)	 NOT NULL,
ULD_USERSTAMP VARCHAR(50) NOT NULL,
ULD_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY(ULD_ID));
INSERT INTO TEMP_USER_LOGIN_DETAILS(ULD_LOGINID,ULD_USERSTAMP,ULD_TIMESTAMP)(SELECT DISTINCT(UNAME),USERSTAMP,TIMESTAMP FROM TEMP_USER_RIGHTS_SCDB_FORMAT WHERE UNAME IS NOT NULL ORDER BY Rid ASC);

SET MIN_ULDID=(SELECT MIN(ULD_ID) FROM TEMP_USER_LOGIN_DETAILS);
SET MAX_ULDID=(SELECT MAX(ULD_ID) FROM TEMP_USER_LOGIN_DETAILS);
WHILE(MIN_ULDID<=MAX_ULDID)DO
SET @SELECT_LOGINID=(SELECT CONCAT('SELECT  COUNT(ULD_LOGINID) INTO @TEMP_LOGINID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT ULD_LOGINID FROM TEMP_USER_LOGIN_DETAILS WHERE ULD_ID=',MIN_ULDID,')'));
PREPARE SELECT_LOGINID_STMT FROM @SELECT_LOGINID;
EXECUTE SELECT_LOGINID_STMT;
SET LOGINID=@TEMP_LOGINID;
IF LOGINID =0 THEN
SET @INSERT_USER_LOGIN_DETAILS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_LOGINID,ULD_USERSTAMP,ULD_TIMESTAMP)(SELECT DISTINCT(ULD_LOGINID),ULD_USERSTAMP,ULD_TIMESTAMP FROM TEMP_USER_LOGIN_DETAILS WHERE ULD_ID=',
MIN_ULDID,')'));
PREPARE INSERT_USER_LOGIN_DETAILS_STMT FROM @INSERT_USER_LOGIN_DETAILS;
EXECUTE INSERT_USER_LOGIN_DETAILS_STMT;
END IF;
SET MIN_ULDID=MIN_ULDID+1;
END WHILE;
SET @UPDATETIMESTAMP=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS SET ULD_TIMESTAMP=(SELECT CONVERT_TZ(ULD_TIMESTAMP, "+08:00","+0:00"))'));
PREPARE UPDATETIMESTAMPSTMT FROM @UPDATETIMESTAMP;
EXECUTE UPDATETIMESTAMPSTMT;
SET END_TIME = (SELECT CURTIME());
SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
SET @COUNTUSER_LOGIN_DETAILS_SCDB_FORMAT = (SELECT CONCAT('SELECT count(distinct(Uname)) INTO @COUNT_USER_LOGIN_DETAILS_SCDB_FORMAT FROM ',SOURCESCHEMA,'.USER_RIGHTS_SCDB_FORMAT WHERE Uname IS NOT NULL'));
PREPARE COUNTUSER_LOGIN_DETAILS_SCDB_FORMAT_STMT FROM @COUNTUSER_LOGIN_DETAILS_SCDB_FORMAT;
EXECUTE COUNTUSER_LOGIN_DETAILS_SCDB_FORMAT_STMT;
SET @COUNTSPLITING_USER_LOGIN_DETAILS = (SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_USER_LOGIN_DETAILS FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS'));
PREPARE COUNTSPLITING_USER_LOGIN_DETAILS_STMT FROM @COUNTSPLITING_USER_LOGIN_DETAILS;
EXECUTE COUNTSPLITING_USER_LOGIN_DETAILS_STMT;
SET @REJECTION_COUNT=(@COUNT_USER_LOGIN_DETAILS_SCDB_FORMAT-@COUNT_SPLITING_USER_LOGIN_DETAILS);
UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC = @COUNT_USER_LOGIN_DETAILS_SCDB_FORMAT WHERE PREASP_DATA='USER_LOGIN_DETAILS';
INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='USER_LOGIN_DETAILS'),@COUNT_SPLITING_USER_LOGIN_DETAILS,
(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='USER_LOGIN_DETAILS'),
(SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='USER RIGHTS'),DURATION,@REJECTION_COUNT,@ULDID);
SET START_TIME = (SELECT CURTIME());
SET @DROP_USER_ACCESS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.USER_ACCESS'));
PREPARE DROP_USER_ACCESS_STMT FROM @DROP_USER_ACCESS;
EXECUTE DROP_USER_ACCESS_STMT;					
SET @CREATE_USER_ACCESS=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.USER_ACCESS(
UA_ID INTEGER NOT NULL AUTO_INCREMENT,
RC_ID INTEGER(2) NOT NULL,
ULD_ID INTEGER(2) NOT NULL, 
UA_REC_VER INTEGER NOT NULL,	
UA_JOIN_DATE DATE NOT NULL,	
UA_JOIN	CHAR(1) NULL,	
UA_END_DATE	DATE NULL,	
UA_TERMINATE CHAR(1) NULL,	
UA_REASON TEXT NULL,	
UA_USERSTAMP VARCHAR(50) NOT NULL,	
UA_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY(UA_ID),
FOREIGN KEY(RC_ID) REFERENCES ',DESTINATIONSCHEMA,'.ROLE_CREATION (RC_ID),
FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
PREPARE CREATE_USER_ACCESS_STMT FROM @CREATE_USER_ACCESS;
EXECUTE CREATE_USER_ACCESS_STMT;
SET @DROP_TEMP_USER_ACCESS_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS'));
PREPARE DROP_TEMP_USER_ACCESS_DETAILS_STMT FROM @DROP_TEMP_USER_ACCESS_DETAILS;
EXECUTE DROP_TEMP_USER_ACCESS_DETAILS_STMT;	
SET @CREATE_TEMP_USER_ACCESS_DETAILS=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS(
ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
UNAME VARCHAR(250),
URECVER VARCHAR(255) NULL,
UJOIN VARCHAR(255) NULL,
UTERMINATE VARCHAR(255) NULL,
UJDATE DATE NULL,
UEDATE DATE NULL,
UREASON VARCHAR(255) NULL,
USERSTAMP VARCHAR(255) NULL,
URROLES VARCHAR(255) DEFAULT NULL,
UTIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)'));
PREPARE CREATE_TEMP_USER_ACCESS_DETAILS_STMT FROM @CREATE_TEMP_USER_ACCESS_DETAILS;
EXECUTE CREATE_TEMP_USER_ACCESS_DETAILS_STMT;		
SET @INSERT_TEMP_USER_ACCESS_DETAILS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS(UNAME,URECVER,UJOIN,UTERMINATE,UJDATE,UEDATE,UREASON,USERSTAMP,URROLES,UTIMESTAMP)
SELECT UNAME,URECVER,UJOIN,UTERMINATE,UJDATE,UEDATE,UREASON,USERSTAMP,URROLES,TIMESTAMP FROM ',SOURCESCHEMA,'.USER_RIGHTS_SCDB_FORMAT WHERE UNAME IS NOT NULL'));
PREPARE INSERT_TEMP_USER_ACCESS_DETAILS_STMT FROM @INSERT_TEMP_USER_ACCESS_DETAILS;
EXECUTE INSERT_TEMP_USER_ACCESS_DETAILS_STMT;
SET @MINID=(SELECT CONCAT('SELECT MIN(ID)  INTO @MIN_ID  FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS'));
PREPARE MINID_STMT FROM @MINID;
EXECUTE MINID_STMT;
SET @MAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAX_ID FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS'));
PREPARE MAXID_STMT FROM @MAXID;
EXECUTE MAXID_STMT;	
SET MIN_RID=@MIN_ID;
SET MAX_RID=@MAX_ID;
WHILE (MIN_RID<=MAX_RID) DO
	SET @INSERT_USER_ACCESS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.USER_ACCESS(RC_ID,ULD_ID,UA_REC_VER,UA_JOIN_DATE,UA_JOIN,UA_END_DATE,UA_TERMINATE,UA_REASON,UA_USERSTAMP,UA_TIMESTAMP)VALUES
	((SELECT RC_ID FROM ',DESTINATIONSCHEMA,'.ROLE_CREATION WHERE RC_NAME=(SELECT URROLES FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,')),
	(SELECT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT UNAME FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,')),
	(SELECT URECVER FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
	(SELECT UJDATE FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
	(SELECT UJOIN FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
	(SELECT UEDATE FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
	(SELECT UTERMINATE FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
	(SELECT UREASON FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
	(SELECT USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
	(SELECT UTIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'))'));
	SET MIN_RID=MIN_RID+1;
	PREPARE INSERT_USER_ACCESS_STMT FROM @INSERT_USER_ACCESS;
	EXECUTE INSERT_USER_ACCESS_STMT;	
END WHILE;
SET @UPDATETIMESTAMP=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.USER_ACCESS SET UA_TIMESTAMP=(SELECT CONVERT_TZ(UA_TIMESTAMP, "+08:00","+0:00"))'));
PREPARE UPDATETIMESTAMPSTMT FROM @UPDATETIMESTAMP;
EXECUTE UPDATETIMESTAMPSTMT;
SET END_TIME = (SELECT CURTIME());
SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
SET @COUNTUSER_ACCESS_SCDB_FORMAT =(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_USER_ACCESS_SCDB_FORMAT FROM ',SOURCESCHEMA,'.USER_RIGHTS_SCDB_FORMAT WHERE UNAME IS NOT NULL'));
PREPARE COUNTUSER_ACCESS_SCDB_FORMAT_STMT FROM @COUNTUSER_ACCESS_SCDB_FORMAT;
EXECUTE COUNTUSER_ACCESS_SCDB_FORMAT_STMT;	
SET @COUNTSPLITING_USER_ACCESS = (SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_USER_ACCESS FROM ',DESTINATIONSCHEMA,'.USER_ACCESS'));
PREPARE COUNTSPLITING_USER_ACCESS_STMT FROM @COUNTSPLITING_USER_ACCESS;
EXECUTE COUNTSPLITING_USER_ACCESS_STMT;	
SET @REJECTION_COUNT=(@COUNT_USER_ACCESS_SCDB_FORMAT-@COUNT_SPLITING_USER_ACCESS);
UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC = @COUNT_USER_ACCESS_SCDB_FORMAT WHERE PREASP_DATA='USER_ACCESS';
INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='USER_ACCESS'),@COUNT_SPLITING_USER_ACCESS,(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='USER_ACCESS'),
(SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='USER RIGHTS'),DURATION,@REJECTION_COUNT,@ULDID);	
SET @DROP_TRC=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_ROLE_CREATION'));
PREPARE DROP_TRC_STMT FROM @DROP_TRC;
EXECUTE DROP_TRC_STMT;
SET @DROP_TUAD=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS'));
PREPARE DROP_TUAD_STMT FROM @DROP_TUAD;
EXECUTE DROP_TUAD_STMT; 
DROP TABLE IF EXISTS TEMP_USER_RIGHTS_SCDB_FORMAT;
DROP TABLE IF EXISTS TEMP_USER_LOGIN_DETAILS;
SET FOREIGN_KEY_CHECKS =1;
COMMIT;
END;	
CALL SP_ALL_INITIALIZING_INSERT(SOURCESCHEMA,DESTINATIONSCHEMA,USER_STAMP);