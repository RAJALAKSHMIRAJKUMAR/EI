--version:1.3 --sdate:16/06/2014 --edate:16/06/2014 --desc:removed the group by in unit_account_details , unit_login_details insert query --done by:RL --issue:803 comment no#95
--version:1.2 --sdate:09/06/2014 --edate:09/06/2014 --desc:IMPLEMENTING ROLLBACK AND COMMIT --done by:BHAVANI.R --issue:566
-- version:1.1 -- sadte:27/03/2014 -- edate:27/03/2014 --desc: changed audit into source --doneby:RL
--  version:1.0 --  sadte:17/03/2014 --  edate:17/03/2014 --  issue:765 --  commentno:8 --  desc:dynamically get source nd destination scheman changing userstamp as uld_id in post audit table --  doneby:RL
--   version:0.9 --   sdate:17/03/2014 --   edate:17/03/2014 --   issue:765 --  desc:droped temp table --  doneby:RL
--  version:0.8 --  sdate:14/03/2014 --  edate:14/03/2014 --  issue:750 --  desc:added comments in unit_access_stamp_details --  doneby:RL
--  version:0.7 --  sdate:26/02/2014 --  edate:26/02/2014 --  issue:750 --  desc:uld_id datatype intger changed as integer(2) --  doneby:RL
DROP PROCEDURE IF EXISTS SP_UNIT_DETAILS_INSERT;
CREATE PROCEDURE SP_UNIT_DETAILS_INSERT(IN SOURCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50),IN MIGUSERSTAMP VARCHAR(50))
BEGIN
	
	DECLARE START_TIME TIME;
	DECLARE END_TIME TIME;
	DECLARE DURATION TIME;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
END;
START TRANSACTION;
	
	SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',MIGUSERSTAMP,'"'));
    PREPARE LOGINID FROM @LOGIN_ID;
    EXECUTE LOGINID;
    
		SET START_TIME=(SELECT CURTIME());

		SET FOREIGN_KEY_CHECKS = 0;
-- 1.CREATE QUERY FOR UNIT_ROOM_TYPE_DETAILS
		SET @UNIT_ROOM_TYPE_DETAILS_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.UNIT_ROOM_TYPE_DETAILS'));
		PREPARE UNIT_ROOM_TYPE_DETAILS_DROPQUERYSTMT FROM @UNIT_ROOM_TYPE_DETAILS_DROPQUERY;
		EXECUTE UNIT_ROOM_TYPE_DETAILS_DROPQUERYSTMT;

		SET @UNIT_ROOM_TYPE_DETAILS_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.UNIT_ROOM_TYPE_DETAILS(
		URTD_ID INTEGER NOT NULL AUTO_INCREMENT,
		URTD_ROOM_TYPE VARCHAR(30) UNIQUE NOT NULL,   
		ULD_ID INTEGER(2) NOT NULL,   
		URTD_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		PRIMARY KEY(URTD_ID),
		FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
		PREPARE UNIT_ROOM_TYPE_DETAILS_CREATEQUERYSTMT FROM @UNIT_ROOM_TYPE_DETAILS_CREATEQUERY;
		EXECUTE UNIT_ROOM_TYPE_DETAILS_CREATEQUERYSTMT;

-- INSERT QUERY FOR UNIT_ROOM_TYPE_DETAILS TABLE

		SET @UNIT_ROOM_TYPE_DETAILS_INSERTQUERY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.UNIT_ROOM_TYPE_DETAILS
		(URTD_ROOM_TYPE,ULD_ID,URTD_TIMESTAMP)SELECT DISTINCT T.UNIT_ROOM_TYPE,ULD.ULD_ID,T.TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT T,',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE T.UNIT_ROOM_TYPE IS NOT NULL AND T.USERSTAMP=ULD.ULD_LOGINID GROUP BY UNIT_ROOM_TYPE'));        
		PREPARE UNIT_ROOM_TYPE_DETAILS_INSERTQUERYSTMT FROM @UNIT_ROOM_TYPE_DETAILS_INSERTQUERY;
		EXECUTE UNIT_ROOM_TYPE_DETAILS_INSERTQUERYSTMT;
	
		SET END_TIME=(SELECT CURTIME());
		SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));

-- COUNT CHECKING FOR UNIT_ROOM_TYPE_DETAILS
		SET @COUNT_SCDB_UNIT_ROOM_TYPE=(SELECT CONCAT('SELECT DISTINCT COUNT(DISTINCT(UNIT_ROOM_TYPE)) INTO @COUNT_UNITSCDB_ROOMTYPE FROM ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT WHERE UNIT_ROOM_TYPE IS NOT NULL'));
		PREPARE COUNT_SCDB_UNIT_ROOM_TYPESTMT FROM @COUNT_SCDB_UNIT_ROOM_TYPE;
		EXECUTE COUNT_SCDB_UNIT_ROOM_TYPESTMT;
    
		SET @COUNT_SPLITTING_UNIT_ROOM_TYPE=(SELECT CONCAT('SELECT COUNT(*)INTO @SPLITTED_ROOMTYPE FROM ',DESTINATIONSCHEMA,'.UNIT_ROOM_TYPE_DETAILS'));
		PREPARE COUNT_SPLITTING_UNIT_ROOM_TYPESTMT FROM @COUNT_SPLITTING_UNIT_ROOM_TYPE;
		EXECUTE COUNT_SPLITTING_UNIT_ROOM_TYPESTMT;
	
		SET @REJECTION_COUNT=(@COUNT_UNITSCDB_ROOMTYPE-@SPLITTED_ROOMTYPE);
		
		SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='UNIT_ROOM_TYPE_DETAILS');
	
		SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='UNIT_ROOM_TYPE_DETAILS');
	
		SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='UNIT');
	
		SET @DUR=DURATION;
        
		UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_UNITSCDB_ROOMTYPE WHERE PREASP_DATA='UNIT_ROOM_TYPE_DETAILS';
	
		INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
		VALUES(@POSTAPID,@SPLITTED_ROOMTYPE,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
	
-- 2.CREATE QUERY FOR UNIT_STAMP_DUTY_TYPE
		SET START_TIME=(SELECT CURTIME());
		
		SET @USDT_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.UNIT_STAMP_DUTY_TYPE'));
		PREPARE USDT_DROPQUERYSTMT FROM @USDT_DROPQUERY;
		EXECUTE USDT_DROPQUERYSTMT;
	
		SET @USDT_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.UNIT_STAMP_DUTY_TYPE(
        USDT_ID    INTEGER NOT NULL AUTO_INCREMENT,
        USDT_DATA CHAR(12) UNIQUE NOT NULL,   
        ULD_ID INTEGER(2) NOT NULL,   
        USDT_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY(USDT_ID),
		FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
		PREPARE USDT_CREATEQUERYSTMT FROM @USDT_CREATEQUERY;
		EXECUTE USDT_CREATEQUERYSTMT;
       
-- INSERT QUERY FOR UNIT_STAMP_DUTY_TYPE TABLE
		SET @USDT_INSERTQUERY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.UNIT_STAMP_DUTY_TYPE
		(USDT_DATA,ULD_ID,USDT_TIMESTAMP)SELECT DISTINCT T.UNIT_STAMPDUTYTYPE,ULD.ULD_ID,T.TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT T,',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE T.UNIT_STAMPDUTYTYPE IS NOT NULL AND T.USERSTAMP=ULD.ULD_LOGINID GROUP BY T.UNIT_STAMPDUTYTYPE'));        
		PREPARE USDT_INSERTQUERYSTMT FROM @USDT_INSERTQUERY;
		EXECUTE USDT_INSERTQUERYSTMT;

		SET END_TIME=(SELECT CURTIME());
        SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
		
-- COUNT CHECKING FOR UNIT_STAMP_DUTY_TYPE
		SET @COUNT_SCDB_STYPE=(SELECT CONCAT('SELECT DISTINCT COUNT(DISTINCT(UNIT_STAMPDUTYTYPE)) INTO @COUNT_SCDBTYPE FROM ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT WHERE UNIT_STAMPDUTYTYPE IS NOT NULL'));
		PREPARE COUNT_SCDB_STYPESTMT FROM @COUNT_SCDB_STYPE;
		EXECUTE COUNT_SCDB_STYPESTMT;
    
		SET @COUNT_USDT=(SELECT CONCAT('SELECT COUNT(*)INTO @SPLITTED_STAMPTYPE FROM ',DESTINATIONSCHEMA,'.UNIT_STAMP_DUTY_TYPE'));
		PREPARE COUNT_USDTSTMT FROM @COUNT_USDT;
		EXECUTE COUNT_USDTSTMT;
		
		SET @REJECTION_COUNT=(@COUNT_SCDBTYPE-@SPLITTED_STAMPTYPE);
		
		SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='UNIT_STAMP_DUTY_TYPE');
	
		SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='UNIT_STAMP_DUTY_TYPE');
	
		SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='UNIT');
	
		SET @DUR=DURATION;
        
		UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_SCDBTYPE WHERE PREASP_DATA='UNIT_STAMP_DUTY_TYPE';
	
		INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
		VALUES(@POSTAPID,@SPLITTED_STAMPTYPE,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
	
-- 3.CREATE QUERY FOR UNIT
		
		SET START_TIME=(SELECT CURTIME());
		
		SET @UNIT_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.UNIT'));
		PREPARE UNITDROPQUERY FROM @UNIT_DROPQUERY;
		EXECUTE UNITDROPQUERY;
        
		SET @UNIT_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.UNIT(
        UNIT_ID    INTEGER NOT NULL AUTO_INCREMENT,
        UNIT_NO    SMALLINT(4) UNSIGNED ZEROFILL UNIQUE NOT NULL,
        PRIMARY KEY(UNIT_ID))'));
		PREPARE UNITCREATEQUERY FROM @UNIT_CREATEQUERY;
		EXECUTE UNITCREATEQUERY;
		
-- INSERT QUERY FOR UNIT TABLE
		
		SET @UNIT_INSERTQUERY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.UNIT
		(UNIT_NO)SELECT UNIT_NO FROM ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT GROUP BY UNIT_NO ORDER BY UNIT_NO'));        
		PREPARE UNITINSERTQUERY FROM @UNIT_INSERTQUERY;
		EXECUTE UNITINSERTQUERY;

        SET END_TIME=(SELECT CURTIME());
        SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
        
-- COUNT CHECKING FOR UNIT
        
		SET @COUNT_SCDB_UNIT=(SELECT CONCAT('SELECT DISTINCT COUNT(DISTINCT(UNIT_NO)) INTO @COUNTSCDBUNIT FROM ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT WHERE UNIT_NO IS NOT NULL'));
		PREPARE COUNT_SCDBUNIT FROM @COUNT_SCDB_UNIT;
		EXECUTE COUNT_SCDBUNIT;
    
		SET @COUNT_UNIT=(SELECT CONCAT('SELECT COUNT(*)INTO @SPLITTED_UNIT FROM ',DESTINATIONSCHEMA,'.UNIT'));
		PREPARE COUNTUNIT FROM @COUNT_UNIT;
		EXECUTE COUNTUNIT;
	
		SET @REJECTION_COUNT=(@COUNTSCDBUNIT-@SPLITTED_UNIT);
		
		SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='UNIT');
	
		SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='UNIT');
	
		SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='UNIT');
	
		SET @DUR=DURATION;
        
		UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNTSCDBUNIT WHERE PREASP_DATA='UNIT';
	
		INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
		VALUES(@POSTAPID,@SPLITTED_UNIT,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
	
-- 4.CREATE QUERY FOR UNIT_DETAILS	
		SET START_TIME=(SELECT CURTIME());
		
		SET @UNITDTLS_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.UNIT_DETAILS'));
		PREPARE UNITDTLSDROPQUERY FROM @UNITDTLS_DROPQUERY;
		EXECUTE UNITDTLSDROPQUERY;
        
		SET @UNITDTLS_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.UNIT_DETAILS(
        UD_ID INTEGER NOT NULL AUTO_INCREMENT,
        UNIT_ID    INTEGER NOT NULL,
        UD_START_DATE DATE NOT NULL,
        UD_END_DATE    DATE NOT NULL,   
        UD_PAYMENT SMALLINT(4) NOT NULL,   
        UD_DEPOSIT INTEGER(5) NULL,   
        UD_OBSOLETE CHAR(1) NULL,   
        UD_NON_EI CHAR(1) NULL,   
        UD_COMMENTS    TEXT NULL,   
        ULD_ID INTEGER(2) NOT NULL,   
        UD_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY(UD_ID),
        FOREIGN KEY(UNIT_ID) REFERENCES ',DESTINATIONSCHEMA,'.UNIT(UNIT_ID),
		FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
		PREPARE UNITDTLSCREATEQUERY FROM @UNITDTLS_CREATEQUERY;
		EXECUTE UNITDTLSCREATEQUERY;
		
		
-- INSERT QUERY FOR UNIT_DETAILS TABLE

		SET @UNITDTLS_INSERTQUERY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.UNIT_DETAILS
		(UNIT_ID,UD_START_DATE,UD_END_DATE,UD_PAYMENT,UD_OBSOLETE,UD_NON_EI,UD_COMMENTS,ULD_ID,UD_TIMESTAMP)
		SELECT DISTINCT(U.UNIT_ID),TUSF.UNIT_START_DATE,TUSF.UNIT_END_DATE,TUSF.UNIT_RENTAL,TUSF.UNIT_OBSOLETE,
		TUSF.UD_NON_EI,TUSF.UNIT_COMMENTS,ULD.ULD_ID,TUSF.TIMESTAMP FROM ',DESTINATIONSCHEMA,'.UNIT U INNER JOIN 
		',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT TUSF ON U.UNIT_NO= TUSF.UNIT_NO JOIN ',DESTINATIONSCHEMA,'.
		USER_LOGIN_DETAILS ULD WHERE TUSF.UNIT_START_DATE IS NOT NULL AND TUSF.UNIT_END_DATE IS NOT NULL AND
        TUSF.UNIT_RENTAL IS NOT NULL AND ULD.ULD_LOGINID=TUSF.USERSTAMP GROUP BY UNIT_ID'));        
		PREPARE UNITDTLSINSERTQUERY FROM @UNITDTLS_INSERTQUERY;
		EXECUTE UNITDTLSINSERTQUERY;

        SET END_TIME=(SELECT CURTIME());
        SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
        
-- COUNT CHECKING FOR UNIT_DETAILS
	
		SET @COUNT_SCDB_UNITDTLS=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNTSCDBUNITDTLS FROM ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT WHERE UNIT_START_DATE IS NOT NULL AND UNIT_END_DATE IS NOT NULL AND UNIT_RENTAL IS NOT NULL'));
		PREPARE COUNT_SCDBUNITDTLS FROM @COUNT_SCDB_UNITDTLS;
		EXECUTE COUNT_SCDBUNITDTLS;
    
		SET @COUNT_UNITDTLS=(SELECT CONCAT('SELECT COUNT(*)INTO @SPLITTED_UNITDTLS FROM ',DESTINATIONSCHEMA,'.UNIT_DETAILS'));
		PREPARE COUNTUNITDTLS FROM @COUNT_UNITDTLS;
		EXECUTE COUNTUNITDTLS;
	
		SET @REJECTION_COUNT=(@COUNTSCDBUNITDTLS-@SPLITTED_UNITDTLS);
		
		SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='UNIT_DETAILS');
	
		SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='UNIT_DETAILS');
	
		SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='UNIT');
	
		SET @DUR=DURATION;
        
		UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNTSCDBUNITDTLS WHERE PREASP_DATA='UNIT_DETAILS';
	
		INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
		VALUES(@POSTAPID,@SPLITTED_UNITDTLS,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
		
-- 5.CREATE QUERY FOR UNIT_LOGIN_DETAILS

		SET START_TIME=(SELECT CURTIME());
		
		SET @ULDTL_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.UNIT_LOGIN_DETAILS'));
		PREPARE ULDTLDROPQUERY FROM @ULDTL_DROPQUERY;
		EXECUTE ULDTLDROPQUERY;
        
		SET @ULDTL_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.UNIT_LOGIN_DETAILS(
        ULDTL_ID INTEGER NOT NULL AUTO_INCREMENT,
        UNIT_ID INTEGER NOT NULL,
		ULDTL_DOORCODE VARCHAR(10) NULL,   
        ULDTL_WEBLOGIN VARCHAR(20) NULL,   
        ULDTL_WEBPWD VARCHAR(6) NULL,   
        ULD_ID INTEGER(2) NOT NULL,   
        ULDTL_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY(ULDTL_ID),
        FOREIGN KEY(UNIT_ID) REFERENCES ',DESTINATIONSCHEMA,'.UNIT(UNIT_ID),
		FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
		PREPARE ULDTLCREATEQUERY FROM @ULDTL_CREATEQUERY;
		EXECUTE ULDTLCREATEQUERY;
		
-- INSERT QUERY FOR UNIT_DETAILS TABLE

		SET @ULDTL_INSERTQUERY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.UNIT_LOGIN_DETAILS
		(UNIT_ID,ULDTL_DOORCODE,ULDTL_WEBLOGIN,ULDTL_WEBPWD,ULD_ID,ULDTL_TIMESTAMP)
		SELECT U.UNIT_ID,TUSF.UNIT_DOORCODE,TUSF.UNIT_WEBLOGIN,TUSF.UNIT_WEBPWD,ULD.ULD_ID,TUSF.TIMESTAMP
		FROM ',DESTINATIONSCHEMA,'.UNIT U INNER JOIN 
		',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT TUSF ON U.UNIT_NO= TUSF.UNIT_NO JOIN ',DESTINATIONSCHEMA,'.
		USER_LOGIN_DETAILS ULD WHERE (TUSF.UNIT_DOORCODE IS NOT NULL OR TUSF.UNIT_WEBLOGIN IS NOT NULL
		OR TUSF.UNIT_WEBPWD) AND ULD.ULD_LOGINID=TUSF.USERSTAMP'));        
		PREPARE ULDTLINSERTQUERY FROM @ULDTL_INSERTQUERY;
		EXECUTE ULDTLINSERTQUERY;

        SET END_TIME=(SELECT CURTIME());
        SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
		
		SET @VW_ULDTLSCDB=(SELECT CONCAT('CREATE OR REPLACE VIEW ',DESTINATIONSCHEMA,'.VW_UNIT_LOGIN_DETAILS AS SELECT * FROM  ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT WHERE UNIT_DOORCODE IS NOT NULL OR UNIT_WEBLOGIN IS NOT NULL OR UNIT_WEBPWD IS NOT NULL'));
		PREPARE VWULDTLSCDB FROM @VW_ULDTLSCDB;
		EXECUTE VWULDTLSCDB;
        
		SET @COUNT_SCDB_ULDTL=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNTSCDBULDTL FROM ',DESTINATIONSCHEMA,'.VW_UNIT_LOGIN_DETAILS'));
		PREPARE COUNT_SCDBULDTL FROM @COUNT_SCDB_ULDTL;
		EXECUTE COUNT_SCDBULDTL;
    
		SET @COUNT_ULDTL=(SELECT CONCAT('SELECT COUNT(*)INTO @SPLITTED_ULDTL FROM ',DESTINATIONSCHEMA,'.UNIT_LOGIN_DETAILS'));
		PREPARE COUNTULDTL FROM @COUNT_ULDTL;
		EXECUTE COUNTULDTL;
	
		SET @REJECTION_COUNT=(@COUNTSCDBULDTL-@SPLITTED_ULDTL);
		
		SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='UNIT_LOGIN_DETAILS');
	
		SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='UNIT_LOGIN_DETAILS');
	
		SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='UNIT');
	
		SET @DUR=DURATION;
        
		UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNTSCDBULDTL WHERE PREASP_DATA='UNIT_LOGIN_DETAILS';
	
		INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
		VALUES(@POSTAPID,@SPLITTED_ULDTL,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
		
-- 6.CREATE QUERY FOR UNIT_ACCOUNT_DETAILS

		SET START_TIME=(SELECT CURTIME());
		
		SET @UACD_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.UNIT_ACCOUNT_DETAILS'));
		PREPARE UACDDROPQUERY FROM @UACD_DROPQUERY;
		EXECUTE UACDDROPQUERY;
        
		SET @UACD_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.UNIT_ACCOUNT_DETAILS(
        UACD_ID INTEGER NOT NULL AUTO_INCREMENT,
        UNIT_ID INTEGER NOT NULL,
        UACD_ACC_NO VARCHAR(15) NULL,   
        UACD_ACC_NAME VARCHAR(25) NULL,   
        UACD_BANK_CODE VARCHAR(5) NULL,   
        UACD_BRANCH_CODE VARCHAR(5) NULL,   
        UACD_BANK_ADDRESS VARCHAR(250) NULL,
        PRIMARY KEY(UACD_ID),
        FOREIGN KEY(UNIT_ID) REFERENCES ',DESTINATIONSCHEMA,'.UNIT(UNIT_ID))'));
		PREPARE UACDCREATEQUERY FROM @UACD_CREATEQUERY;
		EXECUTE UACDCREATEQUERY;
		
-- INSERT QUERY FOR UNIT_ACCOUNT_DETAILS TABLE

		SET @UACD_INSERTQUERY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.UNIT_ACCOUNT_DETAILS
		(UNIT_ID,UACD_ACC_NO,UACD_ACC_NAME,UACD_BANK_CODE,UACD_BRANCH_CODE,UACD_BANK_ADDRESS)
		SELECT DISTINCT(U.UNIT_ID),TUSF.UNIT_ACC_NO,TUSF.UNIT_ACC_NAME,TUSF.UNIT_BANKCODE,TUSF.UNIT_BRANCHCODE,TUSF.UNIT_BANKADDR
		FROM ',DESTINATIONSCHEMA,'.UNIT U INNER JOIN ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT TUSF ON U.UNIT_NO= TUSF.UNIT_NO WHERE TUSF.UNIT_ACC_NO IS NOT NULL OR TUSF.UNIT_ACC_NAME IS NOT NULL OR TUSF.UNIT_BANKCODE
        IS NOT NULL OR TUSF.UNIT_BRANCHCODE IS NOT NULL OR TUSF.UNIT_BANKADDR IS NOT NULL'));        
		PREPARE UACDINSERTQUERY FROM @UACD_INSERTQUERY;
		EXECUTE UACDINSERTQUERY;

        SET END_TIME=(SELECT CURTIME());
        SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));

		SET @VW_UACDSCDB=(SELECT CONCAT('CREATE OR REPLACE VIEW ',DESTINATIONSCHEMA,'.VW_UNIT_ACCOUNT_DETAILS AS SELECT * FROM  ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT WHERE UNIT_ACC_NO IS NOT NULL OR UNIT_ACC_NAME IS NOT NULL OR UNIT_BANKCODE IS NOT NULL OR UNIT_BRANCHCODE IS NOT NULL OR UNIT_BANKADDR IS NOT NULL'));
		PREPARE VWUACDSCDB FROM @VW_UACDSCDB;
		EXECUTE VWUACDSCDB;
        
		SET @COUNT_SCDB_UACD=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNTSCDBUACD FROM ',DESTINATIONSCHEMA,'.VW_UNIT_ACCOUNT_DETAILS'));
		PREPARE COUNT_SCDBUACD FROM @COUNT_SCDB_UACD;
		EXECUTE COUNT_SCDBUACD;
    
		SET @COUNT_UACD=(SELECT CONCAT('SELECT COUNT(*)INTO @SPLITTED_UACD FROM ',DESTINATIONSCHEMA,'.UNIT_ACCOUNT_DETAILS'));
		PREPARE COUNTUACD FROM @COUNT_UACD;
		EXECUTE COUNTUACD;
	
		SET @REJECTION_COUNT=(@COUNTSCDBUACD-@SPLITTED_UACD);
		
		SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='UNIT_ACCOUNT_DETAILS');
	
		SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='UNIT_ACCOUNT_DETAILS');
	
		SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='UNIT');
	
		SET @DUR=DURATION;
        
		UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNTSCDBUACD WHERE PREASP_DATA='UNIT_ACCOUNT_DETAILS';
	
		INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
		VALUES(@POSTAPID,@SPLITTED_UACD,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
	
		SET @VWUACD_DROPQUERY=(SELECT CONCAT('DROP VIEW IF EXISTS ',DESTINATIONSCHEMA,'.VW_UNIT_ACCOUNT_DETAILS'));
		PREPARE VWUACDDROPQUERY FROM @VWUACD_DROPQUERY;
		EXECUTE VWUACDDROPQUERY;
        
        SET @VWULDTL_DROPQUERY=(SELECT CONCAT('DROP VIEW IF EXISTS ',DESTINATIONSCHEMA,'.VW_UNIT_LOGIN_DETAILS'));
		PREPARE VWULDTLDROPQUERY FROM @VWULDTL_DROPQUERY;
		EXECUTE VWULDTLDROPQUERY;
	
	SET FOREIGN_KEY_CHECKS = 1;
  COMMIT;
END;