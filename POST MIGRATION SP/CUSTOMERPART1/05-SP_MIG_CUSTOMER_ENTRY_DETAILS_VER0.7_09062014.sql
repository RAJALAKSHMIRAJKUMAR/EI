DROP PROCEDURE IF EXISTS SP_MIG_CUSTOMER_ENTRY_DETAILS;
CREATE PROCEDURE SP_MIG_CUSTOMER_ENTRY_DETAILS(IN SOURCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50),IN MIGUSERSTAMP VARCHAR(100))
BEGIN
DECLARE START_TIME TIME;
DECLARE END_TIME TIME;
DECLARE DURATION TIME;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
SET SOURCESCHEMA=@SSCHEMA;
SET DESTINATIONSCHEMA=@DSCHEMA;
SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',MIGUSERSTAMP,'"'));
PREPARE LOGINID FROM @LOGIN_ID;
EXECUTE LOGINID;
SET START_TIME=(SELECT CURTIME());
CALL SP_TEMP_CUSTOMER_ENTRY(@SSCHEMA,@DSCHEMA);
CALL SP_TEMP_MIG_CUSTOMER_ENTRY_INSERT(@SSCHEMA,@DSCHEMA);
SET END_TIME=(SELECT CURTIME());
SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
SET @COUNTSCDBCEDSTMT=(SELECT CONCAT('SELECT COUNT(*)INTO @COUNT_SCDB_CED FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT WHERE CC_GUEST_CARD_NO IS NULL'));
PREPARE SCDBCEDSTMT FROM @COUNTSCDBCEDSTMT;
EXECUTE SCDBCEDSTMT;
SET @COUNTSPLITTEDCEDSTMT=(SELECT CONCAT('SELECT COUNT(*)INTO @COUNT_SPLITTED_CED FROM ',DESTINATIONSCHEMA,'.CUSTOMER_ENTRY_DETAILS'));
PREPARE SPLITTEDCEDSTMT FROM @COUNTSPLITTEDCEDSTMT;
EXECUTE SPLITTEDCEDSTMT;
SET @REJECTION_COUNT=(@COUNT_SCDB_CED-@COUNT_SPLITTED_CED);
UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_SCDB_CED  WHERE PREASP_DATA='CUSTOMER_ENTRY_DETAILS';
SET @POSTAPIDSTMT=(SELECT CONCAT('SELECT POSTAP_ID INTO @POSTAPID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA=',"'CUSTOMER_ENTRY_DETAILS'"));
PREPARE POSTAPSTMT FROM @POSTAPIDSTMT;
EXECUTE POSTAPSTMT;
SET @PREASPSTMT=(SELECT CONCAT('SELECT PREASP_ID INTO @PREASPID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA=',"'CUSTOMER_ENTRY_DETAILS'"));
PREPARE PREASPIDSTMT FROM @PREASPSTMT;
EXECUTE PREASPIDSTMT;
SET @PREAMPSTMT=(SELECT CONCAT('SELECT PREAMP_ID INTO @PREAMPID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA=',"'CUSTOMER'"));
PREPARE PREAMPIDSTMT FROM @PREAMPSTMT;
EXECUTE PREAMPIDSTMT;
SET @DUR=DURATION;
SET FOREIGN_KEY_CHECKS=0;
INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
VALUES(@POSTAPID,@COUNT_SPLITTED_CED,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
COMMIT;
END;