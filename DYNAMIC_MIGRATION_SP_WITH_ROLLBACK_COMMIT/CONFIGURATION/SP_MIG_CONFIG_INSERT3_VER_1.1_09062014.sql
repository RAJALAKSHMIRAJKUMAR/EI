-- version:1.1 -- sdate:09/06/2014 -- edate:09/06/2014 -- issue:566 --comment no#12 --desc:IMPLEMENTED ROLLBACK AND COMMIT --done by:DHIVYA
-- version:1.0 -- sdate:19/04/2014 -- edate:19/04/2014 -- issue:765 --desc:ADD THE VALUE CGNID 48 IN REPORT_CONFIGURATION--done by:BHAVANI.R
-- version:0.9 -- sdate:10/04/2014 -- edate:10/04/2014 -- issue:765 --desc:added SCDB  1/4/2014 TIME STAMP FOR ALL SS RECORDS --done by:RL
-- version:0.8 --sdate:01/04/2014 --edate:01/04/2014 --issue:765 --commentno#53 --desc:SPLIT THE CONFIG MIG  SP INTO 4 PART. --dONEBY:RL
-- version:0.7 --sdate:28/03/2013 --edate:28/03/2014 --issue:783 --desc:changed ALL FOREIGN KEY REFERENCES TABLE SHOULD IN DESTINATION SCHEMA --doneby:RL
--VER:0.6 STARTDATE:28/03/2014 ENDDATE:28/03/2014 ISSUENO:783 DESC:CHANGED THE SP:SP_MIG_CONFIG_INSERT  REMOVED THE DESTINATION SCHEMA IN POST_AUDIT_HISTORY DONE BY:LALITHA
--VER:0.5 STARTDATE:25/03/2014 ENDDATE:25/03/2014 ISSUENO:765 COMMENTNO:#8 DESC:CHANGED THE SP:SP_MIG_CONFIG_INSERT CHANGED THE SCHEMA FOR INSERTION IN POST AUDIT HISTORY AND UPDATION IN PRE AUDIT SUB PROFILE  DONE BY:LALITHA
-- version:0.4 -- sdate:20/03/2014 -- edate:22/03/2014 -- issue:765 -- desc:Changed the SP:SP_MIG_CONFIG_INSERT As prepared stmt for dynamic running purpose --Doneby:Lalitha
-- version:0.3 -- sdate:17/03/2014 -- edate:17/03/2014 -- issue:765 -- desc:droped temp table -- doneby:RL
-- version:0.2 -- sdate:25/02/2014 -- edate:25/02/2014 -- issue:750 -- desc:getting userstamp n time stamp from db & userstamp changed as uld_id -- doneby:RL
-- version:0.1 -- sdate:20/02/2014 -- edate:21/02/2014 -- issue:750 -- desc:Implementing audit table insert -- doneby:RL
DROP PROCEDURE IF EXISTS SP_MIG_CONFIG_INSERT3;
CREATE PROCEDURE SP_MIG_CONFIG_INSERT3(IN SOURCESCHEMA  VARCHAR(40),IN DESTINATIONSCHEMA  VARCHAR(40),IN MIGUSERSTAMP VARCHAR(50))
BEGIN

-- DECLARING VARIABLES
	DECLARE START_TIME TIME;
	DECLARE END_TIME TIME;
	DECLARE DURATION TIME;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;
	
	SET FOREIGN_KEY_CHECKS=0;

-- QUERY FOR CHANGING USERSTAMP AS ULD_ID
    SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',MIGUSERSTAMP,'"'));
    PREPARE LOGINID FROM @LOGIN_ID;
    EXECUTE LOGINID;

-- 13.QUERY FOR CREATE CHEQUE_CONFIGURATION
	SET START_TIME = (SELECT CURTIME());
	
	SET @DROP_CHEQUE_CONFIGURATION=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.CHEQUE_CONFIGURATION'));
	PREPARE DROP_CHEQUE_CONFIGURATION_STMT FROM @DROP_CHEQUE_CONFIGURATION;
    EXECUTE DROP_CHEQUE_CONFIGURATION_STMT;
	
	SET @CREATE_CHEQUE_CONFIGURATION=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.CHEQUE_CONFIGURATION(
	CQCN_ID INTEGER NOT NULL AUTO_INCREMENT,
	CGN_ID INTEGER NOT NULL,
	CQCN_DATA TEXT NOT NULL,
	CQCN_INITIALIZE_FLAG CHAR(1) NULL,
	ULD_ID INTEGER(2) NOT NULL,
	CQCN_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(CQCN_ID),
	FOREIGN KEY(CGN_ID) REFERENCES ',DESTINATIONSCHEMA,'.CONFIGURATION(CGN_ID),
	FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
	PREPARE CREATE_CHEQUE_CONFIGURATION_STMT FROM @CREATE_CHEQUE_CONFIGURATION;
    EXECUTE CREATE_CHEQUE_CONFIGURATION_STMT;

-- QUERY FOR INSERT VALUES IN CHEQUE_CONFIGURATION TABLE
	SET @INSERT_CHEQUE_CONFIGURATION=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.CHEQUE_CONFIGURATION(CGN_ID,CQCN_DATA,CQCN_INITIALIZE_FLAG,ULD_ID,CQCN_TIMESTAMP) 
	(SELECT CSQL.CGN_ID,CSQL.DATA,CSQL.INITIALIZE_FLAG,ULD.ULD_ID,CSQL.TIMESTAMP FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT CSQL, ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE CSQL.CGN_ID=57 AND CSQL.DATA IS NOT NULL AND ULD.ULD_LOGINID=CSQL.USER_STAMP)'));
	PREPARE INSERT_CHEQUE_CONFIGURATION_STMT FROM @INSERT_CHEQUE_CONFIGURATION;
    EXECUTE INSERT_CHEQUE_CONFIGURATION_STMT;

	SET END_TIME = (SELECT CURTIME());

	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));

-- COUNT CHECKING FOR CHEQUE_CONFIGURATION DETAILS
	SET @COUNT_CHEQUECONFIGURATIONSQLFORMAT=(SELECT CONCAT('SELECT COUNT(DATA) INTO @COUNT_CHEQUE_CONFIGURATION_SQL_FORMAT FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE CGN_ID=57 AND DATA IS NOT NULL'));
	PREPARE COUNT_CHEQUECONFIGURATIONSQLFORMAT_STMT FROM @COUNT_CHEQUECONFIGURATIONSQLFORMAT;
    EXECUTE COUNT_CHEQUECONFIGURATIONSQLFORMAT_STMT;

-- COUNT SPLITING FOR CHEQUE_CONFIGURATION DETAILS
	SET @COUNT_SPLITING_CHEQUECONFIGURATION=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_CHEQUE_CONFIGURATION FROM ',DESTINATIONSCHEMA,'.CHEQUE_CONFIGURATION'));
	PREPARE COUNT_SPLITING_CHEQUECONFIGURATION_STMT FROM @COUNT_SPLITING_CHEQUECONFIGURATION;
    EXECUTE COUNT_SPLITING_CHEQUECONFIGURATION_STMT;
   
   SET @REJECTION_COUNT=(@COUNT_CHEQUE_CONFIGURATION_SQL_FORMAT-@COUNT_SPLITING_CHEQUE_CONFIGURATION);

-- QUERY FOR INSERT VALUES IN POST_AUDIT_HISTORY TABLE
    SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='CHEQUE_CONFIGURATION');
	
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='CHEQUE_CONFIGURATION');
	
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CONFIGURATION');
	
	SET @DUR=DURATION;

-- QUERY FOR UPDATE VALUES IN PRE_AUDIT_SUB_PROFILE TABLE
	
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_CHEQUE_CONFIGURATION_SQL_FORMAT WHERE PREASP_DATA='CHEQUE_CONFIGURATION';	
	
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES(@POSTAPID,@COUNT_SPLITING_CHEQUE_CONFIGURATION,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);     	   		
    	
-- 14.QUERY FOR CREATE REPORT_CONFIGURATION
	
	SET START_TIME = (SELECT CURTIME());
	
	SET @DROP_REPORT_CONFIGURATION=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.REPORT_CONFIGURATION'));
	PREPARE DROP_REPORT_CONFIGURATION_STMT FROM @DROP_REPORT_CONFIGURATION;
    EXECUTE DROP_REPORT_CONFIGURATION_STMT;
	
	SET @CREATE_REPORT_CONFIGURATION=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.REPORT_CONFIGURATION(
	RCN_ID INTEGER NOT NULL AUTO_INCREMENT,
	CGN_ID INTEGER NOT NULL,
	RCN_DATA TEXT NOT NULL,
	RCN_INITIALIZE_FLAG	CHAR(1) NULL,
	ULD_ID INTEGER(2) NOT NULL,
	RCN_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(RCN_ID),
	FOREIGN KEY(CGN_ID) REFERENCES ',DESTINATIONSCHEMA,'.CONFIGURATION(CGN_ID),
	FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
	PREPARE CREATE_REPORT_CONFIGURATION_STMT FROM @CREATE_REPORT_CONFIGURATION;
    EXECUTE CREATE_REPORT_CONFIGURATION_STMT;

-- QUERY FOR INSERT VALUES IN REPORT_CONFIGURATION TABLE
	SET @INSERT_REPORT_CONFIGURATION=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.REPORT_CONFIGURATION(CGN_ID,RCN_DATA,RCN_INITIALIZE_FLAG,ULD_ID,RCN_TIMESTAMP) 
	(SELECT CSQL.CGN_ID,CSQL.DATA,CSQL.INITIALIZE_FLAG,ULD.ULD_ID,CSQL.TIMESTAMP FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT CSQL, ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE CSQL.CGN_ID IN (59,60,61,62,63,64,65,73,48) AND CSQL.DATA IS NOT NULL AND ULD.ULD_LOGINID=CSQL.USER_STAMP)'));
	PREPARE INSERT_REPORT_CONFIGURATION_STMT FROM @INSERT_REPORT_CONFIGURATION;
    EXECUTE INSERT_REPORT_CONFIGURATION_STMT;
	
	SET END_TIME = (SELECT CURTIME());
	
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));

-- COUNT CHECKING FOR REPORT_CONFIGURATION DETAILS
	SET @COUNT_REPORTCONFIGURATIONSQLFORMAT=(SELECT CONCAT('SELECT COUNT(DATA) INTO @COUNT_REPORT_CONFIGURATION_SQL_FORMAT FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE CGN_ID IN (59,60,61,62,63,64,65,73,48) AND DATA IS NOT NULL'));
	PREPARE COUNT_REPORTCONFIGURATIONSQLFORMAT_STMT FROM @COUNT_REPORTCONFIGURATIONSQLFORMAT;
    EXECUTE COUNT_REPORTCONFIGURATIONSQLFORMAT_STMT;

-- COUNT SPLITING FOR REPORT_CONFIGURATION DETAILS
	SET @COUNT_SPLITING_REPORTCONFIGURATION=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_REPORT_CONFIGURATION FROM ',DESTINATIONSCHEMA,'.REPORT_CONFIGURATION'));
	PREPARE COUNT_SPLITING_REPORTCONFIGURATION_STMT FROM @COUNT_SPLITING_REPORTCONFIGURATION;
    EXECUTE COUNT_SPLITING_REPORTCONFIGURATION_STMT;
	
	SET @REJECTION_COUNT=(@COUNT_REPORT_CONFIGURATION_SQL_FORMAT-@COUNT_SPLITING_REPORT_CONFIGURATION);

-- QUERY FOR INSERT VALUES IN POST_AUDIT_HISTORY TABLE
    SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='REPORT_CONFIGURATION');
	
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='REPORT_CONFIGURATION');
	
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CONFIGURATION');
	
	SET @DUR=DURATION;

-- QUERY FOR UPDATE VALUES IN PRE_AUDIT_SUB_PROFILE TABLE
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_REPORT_CONFIGURATION_SQL_FORMAT WHERE PREASP_DATA='REPORT_CONFIGURATION';	
	
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES
	(@POSTAPID,@COUNT_SPLITING_REPORT_CONFIGURATION,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);   

-- 15.QUERY FOR CREATE CUSTOMER_PAYMENT_PROFILE
	SET START_TIME = (SELECT CURTIME());
	
	SET @DROP_CUSTOMER_PAYMENT_PROFILE=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.CUSTOMER_PAYMENT_PROFILE'));
	PREPARE DROP_CUSTOMER_PAYMENT_PROFILE_STMT FROM @DROP_CUSTOMER_PAYMENT_PROFILE;
    EXECUTE DROP_CUSTOMER_PAYMENT_PROFILE_STMT;
	
	SET @CREATE_CUSTOMER_PAYMENT_PROFILE=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.CUSTOMER_PAYMENT_PROFILE(CPP_ID INTEGER NOT NULL AUTO_INCREMENT,CPP_DATA VARCHAR(50) NOT NULL,ULD_ID INTEGER(2) NOT NULL,CPP_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,PRIMARY KEY(CPP_ID),FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
	PREPARE CREATE_CUSTOMER_PAYMENT_PROFILE_STMT FROM @CREATE_CUSTOMER_PAYMENT_PROFILE;
    EXECUTE CREATE_CUSTOMER_PAYMENT_PROFILE_STMT;

-- QUERY FOR INSERT VALUES IN CUSTOMER_PAYMENT_PROFILE TABLE
	SET @INSERT_CUSTOMER_PAYMENT_PROFILE=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.CUSTOMER_PAYMENT_PROFILE(CPP_DATA,ULD_ID,CPP_TIMESTAMP)(SELECT CSQL.CPP_DATA,ULD.ULD_ID,CSQL.TIMESTAMP FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT CSQL,',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE CSQL.CPP_DATA IS NOT NULL AND ULD.ULD_LOGINID=CSQL.USER_STAMP)'));
	PREPARE INSERT_CUSTOMER_PAYMENT_PROFILE_STMT FROM @INSERT_CUSTOMER_PAYMENT_PROFILE;
    EXECUTE INSERT_CUSTOMER_PAYMENT_PROFILE_STMT;
	
	SET END_TIME = (SELECT CURTIME());
	
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));

-- COUNT CHECKING FOR CUSTOMER_PAYMENT_PROFILE DETAILS
	SET @COUNT_CUSTOMERPAYMENTPROFILESQLFORMAT=(SELECT CONCAT('SELECT COUNT(CPP_DATA) INTO @COUNT_CUSTOMER_PAYMENT_PROFILE_SQL_FORMAT FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE CPP_DATA IS NOT NULL'));
	PREPARE COUNT_CUSTOMERPAYMENTPROFILESQLFORMAT_STMT FROM @COUNT_CUSTOMERPAYMENTPROFILESQLFORMAT;
    EXECUTE COUNT_CUSTOMERPAYMENTPROFILESQLFORMAT_STMT;

-- COUNT SPLITING FOR CUSTOMER_PAYMENT_PROFILE DETAILS
	SET @COUNT_SPLITING_CUSTOMERPAYMENTPROFILE=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_CUSTOMER_PAYMENT_PROFILE FROM ',DESTINATIONSCHEMA,'.CUSTOMER_PAYMENT_PROFILE'));
	PREPARE COUNT_SPLITING_CUSTOMERPAYMENTPROFILE_STMT FROM @COUNT_SPLITING_CUSTOMERPAYMENTPROFILE;
    EXECUTE COUNT_SPLITING_CUSTOMERPAYMENTPROFILE_STMT;
	
	SET @REJECTION_COUNT=(@COUNT_CUSTOMER_PAYMENT_PROFILE_SQL_FORMAT-@COUNT_SPLITING_CUSTOMER_PAYMENT_PROFILE);

-- QUERY FOR INSERT VALUES IN POST_AUDIT_HISTORY TABLE
    SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='CUSTOMER_PAYMENT_PROFILE');
	
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='CUSTOMER_PAYMENT_PROFILE');
	
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CONFIGURATION');
	
	SET @DUR=DURATION;

-- QUERY FOR UPDATE VALUES IN PRE_AUDIT_SUB_PROFILE TABLE
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_CUSTOMER_PAYMENT_PROFILE_SQL_FORMAT WHERE PREASP_DATA='CUSTOMER_PAYMENT_PROFILE';	
	
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES(@POSTAPID,@COUNT_SPLITING_CUSTOMER_PAYMENT_PROFILE,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);     	   		
   
-- 16.QUERY FOR CREATE CUSTOMER_TIME_PROFILE
	SET START_TIME = (SELECT CURTIME());
	
	SET @DROP_CUSTOMER_TIME_PROFILE=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE'));
	PREPARE DROP_CUSTOMER_TIME_PROFILE_STMT FROM @DROP_CUSTOMER_TIME_PROFILE;
    EXECUTE DROP_CUSTOMER_TIME_PROFILE_STMT;
	
	SET @CREATE_CUSTOMER_TIME_PROFILE=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE(
	CTP_ID INTEGER NOT NULL AUTO_INCREMENT,
	CTP_DATA TIME NOT NULL,
	PRIMARY KEY(CTP_ID))'));
    PREPARE CREATE_CUSTOMER_TIME_PROFILE_STMT FROM @CREATE_CUSTOMER_TIME_PROFILE;
    EXECUTE CREATE_CUSTOMER_TIME_PROFILE_STMT;

-- QUERY FOR INSERT VALUES IN CUSTOMER_TIME_PROFILE TABLE
	SET @INSERT_CUSTOMER_TIME_PROFILE=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE(CTP_DATA) 
	(SELECT CTP_DATA FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE CTP_DATA IS NOT NULL)'));
	PREPARE INSERT_CUSTOMER_TIME_PROFILE_STMT FROM @INSERT_CUSTOMER_TIME_PROFILE;
    EXECUTE INSERT_CUSTOMER_TIME_PROFILE_STMT;
	
	SET END_TIME = (SELECT CURTIME());
	
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));

-- COUNT CHECKING FOR CUSTOMER_TIME_PROFILE DETAILS
	SET @COUNT_CUSTOMERTIMEPROFILESQLFORMAT=(SELECT CONCAT('SELECT COUNT(CTP_DATA) INTO @COUNT_CUSTOMER_TIME_PROFILE_SQL_FORMAT FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE CTP_DATA IS NOT NULL'));
	PREPARE COUNT_CUSTOMERTIMEPROFILESQLFORMAT_STMT FROM @COUNT_CUSTOMERTIMEPROFILESQLFORMAT;
    EXECUTE COUNT_CUSTOMERTIMEPROFILESQLFORMAT_STMT;

-- COUNT SPLITING FOR CUSTOMER_TIME_PROFILE DETAILS
	SET @COUNT_SPLITINGCUSTOMERTIMEPROFILE=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_CUSTOMER_TIME_PROFILE FROM ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE'));
	PREPARE COUNT_SPLITINGCUSTOMERTIMEPROFILE_STMT FROM @COUNT_SPLITINGCUSTOMERTIMEPROFILE;
    EXECUTE COUNT_SPLITINGCUSTOMERTIMEPROFILE_STMT;
	
	SET @REJECTION_COUNT=(@COUNT_CUSTOMER_TIME_PROFILE_SQL_FORMAT-@COUNT_SPLITING_CUSTOMER_TIME_PROFILE);

-- QUERY FOR INSERT VALUES IN POST_AUDIT_HISTORY TABLE
    SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='CUSTOMER_TIME_PROFILE');
	
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='CUSTOMER_TIME_PROFILE');
	
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CONFIGURATION');
	
	SET @DUR=DURATION;

-- QUERY FOR UPDATE VALUES IN PRE_AUDIT_SUB_PROFILE TABLE
	
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_CUSTOMER_TIME_PROFILE_SQL_FORMAT WHERE PREASP_DATA='CUSTOMER_TIME_PROFILE';	
	
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES
	(@POSTAPID,@COUNT_SPLITING_CUSTOMER_TIME_PROFILE,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);     	   		
    	
-- 17.QUERY FOR CREATE PAYMENT_PROFILE
	SET START_TIME = (SELECT CURTIME());
	
	SET @DROP_PAYMENT_PROFILE=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.PAYMENT_PROFILE'));
	PREPARE DROP_PAYMENT_PROFILE_STMT FROM @DROP_PAYMENT_PROFILE;
    EXECUTE DROP_PAYMENT_PROFILE_STMT;
	
	SET @CREATE_PAYMENT_PROFILE=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.PAYMENT_PROFILE(
	PP_ID INTEGER NOT NULL AUTO_INCREMENT,
	PP_DATA	VARCHAR(50) NOT NULL,
	PRIMARY KEY(PP_ID))'));
	PREPARE CREATE_PAYMENT_PROFILE_STMT FROM @CREATE_PAYMENT_PROFILE;
    EXECUTE CREATE_PAYMENT_PROFILE_STMT;

-- QUERY FOR INSERT VALUES IN PAYMENT_PROFILE TABLE
	SET @INSERT_PAYMENT_PROFILE=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.PAYMENT_PROFILE(PP_DATA) 
	(SELECT PP_DATA FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE PP_DATA IS NOT NULL)'));
	PREPARE INSERT_PAYMENT_PROFILE_STMT FROM @INSERT_PAYMENT_PROFILE;
    EXECUTE INSERT_PAYMENT_PROFILE_STMT;
	
	SET END_TIME = (SELECT CURTIME());
	
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));

-- COUNT CHECKING FOR PAYMENT_PROFILE DETAILS
	SET @COUNT_PAYMENTPROFILESQLFORMAT=(SELECT CONCAT('SELECT COUNT(PP_DATA) INTO @COUNT_PAYMENT_PROFILE_SQL_FORMAT FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE PP_DATA IS NOT NULL'));
	PREPARE COUNT_PAYMENTPROFILESQLFORMAT_STMT FROM @COUNT_PAYMENTPROFILESQLFORMAT;
    EXECUTE COUNT_PAYMENTPROFILESQLFORMAT_STMT;

-- COUNT SPLITING FOR PAYMENT_PROFILE DETAILS
	SET @COUNT_SPLITING_PAYMENTPROFILE=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_PAYMENT_PROFILE FROM ',DESTINATIONSCHEMA,'.PAYMENT_PROFILE'));
	PREPARE COUNT_SPLITING_PAYMENTPROFILE_STMT FROM @COUNT_SPLITING_PAYMENTPROFILE;
    EXECUTE COUNT_SPLITING_PAYMENTPROFILE_STMT;
	
	SET @REJECTION_COUNT=(@COUNT_PAYMENT_PROFILE_SQL_FORMAT-@COUNT_SPLITING_PAYMENT_PROFILE);

-- QUERY FOR INSERT VALUES IN POST_AUDIT_HISTORY TABLE
    SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='PAYMENT_PROFILE');
	
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='PAYMENT_PROFILE');
	
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CONFIGURATION');
	
	SET @DUR=DURATION;

-- QUERY FOR UPDATE VALUES IN PRE_AUDIT_SUB_PROFILE TABLE

	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_PAYMENT_PROFILE_SQL_FORMAT WHERE PREASP_DATA='PAYMENT_PROFILE';	

	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES
	(@POSTAPID,@COUNT_SPLITING_PAYMENT_PROFILE,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);     	   		
    	
-- 18.QUERY FOR CREATE TICKLER_PROFILE
	SET START_TIME = (SELECT CURTIME());
	
	SET @DROP_TICKLER_PROFILE=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TICKLER_PROFILE'));
	PREPARE DROP_TICKLER_PROFILE_STMT FROM @DROP_TICKLER_PROFILE;
    EXECUTE DROP_TICKLER_PROFILE_STMT;
	
	SET @CREATE_TICKLER_PROFILE=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TICKLER_PROFILE(
	TP_ID INTEGER NOT NULL AUTO_INCREMENT,
	TP_TYPE	CHAR(10) NOT NULL,
	PRIMARY KEY(TP_ID))'));
	PREPARE CREATE_TICKLER_PROFILE_STMT FROM @CREATE_TICKLER_PROFILE;
    EXECUTE CREATE_TICKLER_PROFILE_STMT;

-- QUERY FOR INSERT VALUES IN TICKLER_PROFILE TABLE
	SET @INSERT_TICKLER_PROFILE=(SELECT CONCAT('INSERT INTO  ',DESTINATIONSCHEMA,'.TICKLER_PROFILE(TP_TYPE) 
	(SELECT TP_TYPE FROM CONFIG_SQL_FORMAT WHERE TP_TYPE IS NOT NULL)'));
	PREPARE INSERT_TICKLER_PROFILE_STMT FROM @INSERT_TICKLER_PROFILE;
    EXECUTE INSERT_TICKLER_PROFILE_STMT;
	
	SET END_TIME = (SELECT CURTIME());
	
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));

-- COUNT CHECKING FOR TICKLER_PROFILE DETAILS
	SET @COUNT_TICKLERPROFILESQLFORMAT=(SELECT CONCAT('SELECT COUNT(TP_TYPE) INTO @COUNT_TICKLER_PROFILE_SQL_FORMAT FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE TP_TYPE IS NOT NULL'));
	PREPARE COUNT_TICKLERPROFILESQLFORMAT_STMT FROM @COUNT_TICKLERPROFILESQLFORMAT;
    EXECUTE COUNT_TICKLERPROFILESQLFORMAT_STMT;

-- COUNT SPLITING FOR TICKLER_PROFILE DETAILS
	SET @COUNT_SPLITING_TICKLERPROFILE=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_TICKLER_PROFILE FROM ',DESTINATIONSCHEMA,'.TICKLER_PROFILE'));
	PREPARE COUNT_SPLITING_TICKLERPROFILE_STMT FROM @COUNT_SPLITING_TICKLERPROFILE;
    EXECUTE COUNT_SPLITING_TICKLERPROFILE_STMT;
    
	SET @REJECTION_COUNT=(@COUNT_TICKLER_PROFILE_SQL_FORMAT-@COUNT_SPLITING_TICKLER_PROFILE);

-- QUERY FOR INSERT VALUES IN POST_AUDIT_HISTORY TABLE
    SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='TICKLER_PROFILE');
	
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='TICKLER_PROFILE');
	
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CONFIGURATION');
	
	SET @DUR=DURATION;

-- QUERY FOR UPDATE VALUES IN PRE_AUDIT_SUB_PROFILE TABLE
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_TICKLER_PROFILE_SQL_FORMAT WHERE PREASP_DATA='TICKLER_PROFILE';	
	
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES
	(@POSTAPID,@COUNT_SPLITING_TICKLER_PROFILE,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);     	   		   
   
   SET FOREIGN_KEY_CHECKS=1;	
	COMMIT;
END;   	

CALL SP_MIG_CONFIG_INSERT3(SOURCESCHEMA,DESTINATIONSCHEMA,MIGUSERSTAMP);