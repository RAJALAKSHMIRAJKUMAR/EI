-- version:1.1 -- sadte:09/06/2014 -- edate:09/06/2014  -- issue:566 COMMENT:12  --desc: IMPLEMENTED ROLLBACK AND COMMIT --doneby:DHIVYA
-- version:1.0 -- sadte:23/04/2014 -- edate:23/04/2014 --desc: UPDATED TIMESTAMP --doneby:SASIKALA
-- version:0.9 -- sadte:27/03/2014 -- edate:27/03/2014 --desc: changed audit into source --doneby:RL
--  version:0.8 --  sdate:19/03/2014 --  edate:19/03/2014 --  issue:765 -- desc:dynamically get source nd destination schema -- doneby:RL
--  version:0.7 --  sdate:17/03/2014 --  edate:17/03/2014 --  issue:765 -- desc:droped temp table -- doneby:RL
-- version:0.6 -- sdate:04/03/2014 -- edate:04/03/2014 -- Desc:ISSUE CORRECTED INUNIT EXPENSE- DONE BY SAFI
-- version:0.5 -- sdate:28/02/2014 -- edate:28/02/2014 -- issue:750 -- desc:changed userstamp as ULD_ID and timestamp get from scdb done by:RL
-- version:0.4-- sdate:21/02/2014 -- edate:22/02/2014 -- issue:750 -desc:added preaudit and post audit queries done by:dhivya
-- version:0.3 -- sdate:18/02/2014 -- edate:18/02/2014 -- issue:276 -- commentno:26 -- desc:ADD USERSTAMP N TIMESTAMP IN EXPENSE_HOUSEKEEPING_UNIT -- doneby:RL
-- version:0.2 -- sdate:21/01/2014 -- edate:21/01/2014 -- issue:594 -- commentno:50 & 54 -- doneby:RL
DROP PROCEDURE IF EXISTS SP_MIG_ALL_BIZDLY_INSERT;
CREATE PROCEDURE SP_MIG_ALL_BIZDLY_INSERT(IN SOURCESCHEMA VARCHAR(50), IN DESTINATIONSCHEMA VARCHAR(50),IN MIGUSERSTAMP VARCHAR(50))
BEGIN
	DECLARE START_TIME TIME;
	DECLARE END_TIME TIME;
	DECLARE DURATION TIME;	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;
	SET @SSCHEMA = SOURCESCHEMA;
	SET @DSCHEMA = DESTINATIONSCHEMA;
	SET @USER_STAMP = MIGUSERSTAMP;	
	SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @INPUTUSERSTAMPID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=@USER_STAMP'));
    PREPARE LOGINID FROM @LOGIN_ID;
    EXECUTE LOGINID;
    CALL SP_TEMP_BIZ_DAILY_SCDB_FORMAT_INSERT(@SSCHEMA,@DSCHEMA);
	CALL SP_MIG_BIZDLY_INSERT(@SSCHEMA,@DSCHEMA,@USER_STAMP);	
	SET START_TIME=(SELECT CURTIME());	
	CALL SP_EXPENSE_AIRCON_SERVICE_INSERT(@DSCHEMA);	
	SET @TEMP_AIRCONDROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE'));
	PREPARE TEMP_AIRCONDROPQUERYSTMT FROM @TEMP_AIRCONDROPQUERY;
	EXECUTE TEMP_AIRCONDROPQUERYSTMT;	
	SET END_TIME=(SELECT CURTIME());
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));	
	SET @COUNT_SCDB_EAS=(SELECT COUNT(*) FROM BIZ_DAILY_SCDB_FORMAT WHERE EXP_TYPE_OF_EXPENSE='AIRCON SERVICES') ;	
	SET @COUNT_SPLITTED_EAS=(SELECT CONCAT('SELECT COUNT(*)INTO @SPLITTED_EAS FROM ',DESTINATIONSCHEMA,'.EXPENSE_AIRCON_SERVICE'));
	PREPARE COUNT_SPLITTED_EASSTMT FROM @COUNT_SPLITTED_EAS;
	EXECUTE COUNT_SPLITTED_EASSTMT;	
	SET @REJECTION_COUNT=(@COUNT_SCDB_EAS-@SPLITTED_EAS);	
	SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='EXPENSE_AIRCON_SERVICE');	
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='EXPENSE_AIRCON_SERVICE');	
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='BIZ DAILY');	
	SET @DUR=DURATION;	
	SET FOREIGN_KEY_CHECKS =0;		
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_SCDB_EAS WHERE PREASP_DATA='EXPENSE_AIRCON_SERVICE';	
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
	VALUES(@POSTAPID,@SPLITTED_EAS,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@INPUTUSERSTAMPID);	
	CALL SP_EXPENSE_ELECTRICITY_INSERT(@SSCHEMA,@DSCHEMA,@USER_STAMP);	
	SET START_TIME=(SELECT CURTIME());	
	CALL SP_TEMP_EXPENSE_UNIT_INSERT(@DSCHEMA);	
	CALL SP_TEMP_EXPENSE_UNIT_UPDATE(@DSCHEMA);	
	CALL SP_TEMP_EXPENSE_UNITUPDATE(@DSCHEMA);	
	CALL SP_EXPENSE_UNIT_INSERT(@DSCHEMA);	
	SET @TEMP_EXPUNIT_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_UNIT'));
	PREPARE TEMP_EXPUNIT_DROPQUERYSTMT FROM @TEMP_EXPUNIT_DROPQUERY;
	EXECUTE TEMP_EXPUNIT_DROPQUERYSTMT;	
	SET END_TIME=(SELECT CURTIME());
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));	
	SET @COUNT_SCDB_EU=(SELECT COUNT(*) FROM BIZ_DAILY_SCDB_FORMAT WHERE EXP_TYPE_OF_EXPENSE='UNIT EXPENSE') ;	
	SET @COUNT_SPLITTED_EU=(SELECT CONCAT('SELECT COUNT(*)INTO @SPLITTED_EU FROM ',DESTINATIONSCHEMA,'.EXPENSE_UNIT'));
	PREPARE COUNT_SPLITTED_EUSTMT FROM @COUNT_SPLITTED_EU;
	EXECUTE COUNT_SPLITTED_EUSTMT;	
	SET @REJECTION_COUNT=(@COUNT_SCDB_EU-@SPLITTED_EU);	
	SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='EXPENSE_UNIT');	
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='EXPENSE_UNIT');	
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='BIZ DAILY');	
	SET @DUR=DURATION;		
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_SCDB_EU WHERE PREASP_DATA='EXPENSE_UNIT';	
	SET FOREIGN_KEY_CHECKS =0;	
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
	VALUES(@POSTAPID,@SPLITTED_EU,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@INPUTUSERSTAMPID);	
	SET FOREIGN_KEY_CHECKS=1;	
	SET START_TIME=(SELECT CURTIME());	
	CALL SP_TEMP_EXPENSE_HOUSEKEEPING_INSERT(@SSCHEMA,@DSCHEMA);	
	CALL SP_TEMP_EXPENSE_HOUSEKEEPING_PAYMENT_INSERT(@DSCHEMA);	
	CALL SP_EXPENSE_HOUSEKEEPING_UNIT_INSERT(@DSCHEMA);	
	CALL SP_EXPENSE_HOUSEKEEPING_PAYMENT_INSERT(@DSCHEMA);	
	SET @TEMP_EHKDROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING'));
	PREPARE TEMP_EHKDROPQUERYSTMT FROM @TEMP_EHKDROPQUERY;
	EXECUTE TEMP_EHKDROPQUERYSTMT;	
	SET @TEMP_EHK_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING_PAYMENT'));
	PREPARE TEMP_EHK_DROPQUERYSTMT FROM @TEMP_EHK_DROPQUERY;
	EXECUTE TEMP_EHK_DROPQUERYSTMT;	
	SET @TEMP_EHKU_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING_UNIT'));
	PREPARE TEMP_EHKU_DROPQUERYSTMT FROM @TEMP_EHKU_DROPQUERY;
	EXECUTE TEMP_EHKU_DROPQUERYSTMT;	
	SET END_TIME=(SELECT CURTIME());
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));	
	SET @COUNT_SCDB_EHKP=(SELECT COUNT(*) FROM BIZ_DAILY_SCDB_FORMAT WHERE EXP_TYPE_OF_EXPENSE='HOUSE KEEPING PAYMENT');	
	SET @COUNT_SPLITTED_EHKP=(SELECT CONCAT('SELECT COUNT(*)INTO @SPLITTED_EHKP FROM ',DESTINATIONSCHEMA,'.EXPENSE_HOUSEKEEPING_PAYMENT'));
	PREPARE COUNT_SPLITTED_EHKPSTMT FROM @COUNT_SPLITTED_EHKP;
	EXECUTE COUNT_SPLITTED_EHKPSTMT;	
	SET @REJECTION_COUNT=(@COUNT_SCDB_EHKP-@SPLITTED_EHKP);	
	SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='EXPENSE_HOUSEKEEPING_PAYMENT');	
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='EXPENSE_HOUSEKEEPING_PAYMENT');	
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='BIZ DAILY');	
	SET @DUR=DURATION;		
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_SCDB_EHKP WHERE PREASP_DATA='EXPENSE_HOUSEKEEPING_PAYMENT';	
	SET FOREIGN_KEY_CHECKS=0;	
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
	VALUES(@POSTAPID,@SPLITTED_EHKP,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@INPUTUSERSTAMPID);	
	SET FOREIGN_KEY_CHECKS=1;	
	SET @COUNT_SCDB_EHKU=(SELECT CONCAT('SELECT COUNT(DISTINCT(B.EXP_HKP_UNIT_NO)) INTO @SCDB_COUNTEHKU FROM ',SOURCESCHEMA,'.BIZ_DAILY_SCDB_FORMAT B 
	LEFT JOIN ',DESTINATIONSCHEMA,'.UNIT U ON U.UNIT_NO = B.EXP_HKP_UNIT_NO WHERE U.UNIT_NO IS NULL AND B.EXP_TYPE_OF_EXPENSE="HOUSE KEEPING PAYMENT"'));
	PREPARE COUNT_SCDB_EHKUSTMT FROM @COUNT_SCDB_EHKU;
	EXECUTE COUNT_SCDB_EHKUSTMT;	
	SET @COUNT_SPLITTED_EHKU=(SELECT CONCAT('SELECT COUNT(*)INTO @SPLITTED_EHKU FROM ',DESTINATIONSCHEMA,'.EXPENSE_HOUSEKEEPING_UNIT'));
	PREPARE COUNT_SPLITTED_EHKUSTMT FROM @COUNT_SPLITTED_EHKU;
	EXECUTE COUNT_SPLITTED_EHKUSTMT;	
	SET @REJECTION_COUNT=(@SCDB_COUNTEHKU-@SPLITTED_EHKU);	
	SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='EXPENSE_HOUSEKEEPING_UNIT');	
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='EXPENSE_HOUSEKEEPING_UNIT');	
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='BIZ DAILY');	
	SET FOREIGN_KEY_CHECKS=0;	
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@SCDB_COUNTEHKU WHERE PREASP_DATA='EXPENSE_HOUSEKEEPING_UNIT';	
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
	VALUES(@POSTAPID,@SPLITTED_EHKU,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@INPUTUSERSTAMPID);		
	SET FOREIGN_KEY_CHECKS=1;	
	SET @TBIZDLY_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_BIZ_DAILY_SCDB_FORMAT'));
	PREPARE TBIZDLY_DROPQUERYSTMT FROM @TBIZDLY_DROPQUERY;
	EXECUTE TBIZDLY_DROPQUERYSTMT;	
	COMMIT;
END;
CALL SP_MIG_ALL_BIZDLY_INSERT(SOURCESCHEMA,DESTINATIONSCHEMA,MIGUSERSTAMP);	