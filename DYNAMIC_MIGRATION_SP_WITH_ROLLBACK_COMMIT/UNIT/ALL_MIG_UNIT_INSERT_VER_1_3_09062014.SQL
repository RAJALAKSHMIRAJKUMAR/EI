--version:1.3 --sdate:09/06/2014 --edate:09/06/2014 --desc:IMPLEMENTING ROLLBACK AND COMMIT --done by:BHAVANI.R --issue:566
--version:1.2 --sdate:17/05/2014 --edate:17/05/2014 --desc:rearrage the call query --done by:rl --issue:803
-- version:1.1 -- sadte:27/03/2014 -- edate:27/03/2014 --desc: changed audit into source --doneby:RL
-- version:1.0 -- sadte:17/03/2014 -- edate:17/03/2014 -- issue:765 -- commentno:8 -- desc:dynamically get source nd destination scheman changing -- doneby:RL
--  version:0.9 --  sdate:17/03/2014 --  edate:17/03/2014 --  issue:765 -- desc:droped temp table -- doneby:RL
-- version:0.8 -- sdate:14/03/2014 -- edate:14/03/2014 -- issue:750 -- desc:added comments in unit_access_stamp_details -- doneby:RL
-- version:0.7 -- sdate:26/02/2014 -- edate:26/02/2014 -- issue:750 -- desc:uld_id datatype intger changed as integer(2) -- doneby:RL

-- version:1.2 -- sadte:17/05/2014 -- edate:17/05/2014  --doneby:RL
-- version:1.1 -- sadte:27/03/2014 -- edate:27/03/2014 --desc: changed audit into source --doneby:RL
-- version:1.0 -- sadte:17/03/2014 -- edate:17/03/2014 -- issue:765 -- commentno:8 -- desc:dynamically get source nd destination scheman changing -- doneby:RL
--  version:0.9 --  sdate:17/03/2014 --  edate:17/03/2014 --  issue:765 -- desc:droped temp table -- doneby:RL
-- version:0.8 -- sdate:14/03/2014 -- edate:14/03/2014 -- issue:750 -- desc:added comments in unit_access_stamp_details -- doneby:RL
-- version:0.7 -- sdate:26/02/2014 -- edate:26/02/2014 -- issue:750 -- desc:uld_id datatype intger changed as integer(2) -- doneby:RL

DROP PROCEDURE IF EXISTS ALL_MIG_UNIT_INSERT;
CREATE PROCEDURE ALL_MIG_UNIT_INSERT(IN SOURCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50),IN MIGUSERSTAMP VARCHAR(50))
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
	
	SET @SP_TEMP_UNIT_SCDB_FORMAT_INSERT=(SELECT CONCAT('CALL ',SOURCESCHEMA,'.SP_TEMP_UNIT_SCDB_FORMAT(@SSCHEMA,@DSCHEMA)'));
    PREPARE SP_TEMP_UNIT_SCDB_FORMATINSERT FROM @SP_TEMP_UNIT_SCDB_FORMAT_INSERT;
    EXECUTE SP_TEMP_UNIT_SCDB_FORMATINSERT;
	
	SET @SP_UNIT_DETAILS_INSERT=(SELECT CONCAT('CALL ',SOURCESCHEMA,'.SP_UNIT_DETAILS_INSERT(@SSCHEMA,@DSCHEMA,@USER_STAMP)'));
    PREPARE SP_UNIT_DETAILS_INSERT_STMT FROM @SP_UNIT_DETAILS_INSERT;
    EXECUTE SP_UNIT_DETAILS_INSERT_STMT;
   
    SET START_TIME=(SELECT CURTIME());
   
	SET @SP_CREATE_UNIT_ACCESS_STAMP_DETAILS_TABLE=(SELECT CONCAT('CALL ',SOURCESCHEMA,'.SP_CREATE_UNIT_ACCESS_STAMP_DETAILS_TABLE(@DSCHEMA)'));
    PREPARE SP_CREATE_UNIT_ACCESS_STAMP_DETAILSTABLE FROM @SP_CREATE_UNIT_ACCESS_STAMP_DETAILS_TABLE;
    EXECUTE SP_CREATE_UNIT_ACCESS_STAMP_DETAILSTABLE;
	
	SET @SP_TEMP_UNIT_ACCESS_STAMP_DETAILS_INSERT=(SELECT CONCAT('CALL ',SOURCESCHEMA,'.SP_TEMP_UNIT_ACCESS_STAMP_DETAILS_INSERT(@DSCHEMA)'));
    PREPARE SP_TEMP_UNIT_ACCESS_STAMP_DETAILSINSERT FROM @SP_TEMP_UNIT_ACCESS_STAMP_DETAILS_INSERT;
    EXECUTE SP_TEMP_UNIT_ACCESS_STAMP_DETAILSINSERT;
	
	SET @SP_UNIT_ACCESS_STAMP_UPDATE=(SELECT CONCAT('CALL ',SOURCESCHEMA,'.SP_UNIT_ACCESS_STAMP_UPDATE(@DSCHEMA)'));
    PREPARE SP_UNIT_ACCESS_STAMP_UPDATESTMT FROM @SP_UNIT_ACCESS_STAMP_UPDATE;
    EXECUTE SP_UNIT_ACCESS_STAMP_UPDATESTMT;
	
	
	SET FOREIGN_KEY_CHECKS=0;
	SET @SP_UNIT_ACCESS_STAMP_DETAILS_INSERT=(SELECT CONCAT('CALL ',SOURCESCHEMA,'.SP_UNIT_ACCESS_STAMP_DETAILS_INSERT(@DSCHEMA)'));
    PREPARE SP_UNIT_ACCESS_STAMP_DETAILS_INSERTSTMT FROM @SP_UNIT_ACCESS_STAMP_DETAILS_INSERT;
    EXECUTE SP_UNIT_ACCESS_STAMP_DETAILS_INSERTSTMT;
	
	SET END_TIME=(SELECT CURTIME());
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
		
-- CHECK COUNT FOR UNIT_ACCESS_STAMP_DETAILS
    
	SET @COUNT_SCDB_UASD=(SELECT CONCAT('SELECT DISTINCT COUNT(*) INTO @COUNT_UASD FROM ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT WHERE UNIT_STAMPDUTYTYPE IS NOT NULL OR UNIT_STAMPDUTYAMT IS NOT NULL OR UNIT_STAMPDUTYDATE IS NOT NULL OR UNIT_ROOM_TYPE IS NOT NULL OR UNIT_COMMENTS IS NOT NULL OR UNIT_ACCESS_CARD IS NOT NULL'));
	PREPARE COUNT_SCDB_UASDSTMT FROM @COUNT_SCDB_UASD;
	EXECUTE COUNT_SCDB_UASDSTMT;
    
	SET @COUNT_SPLITTING_UASD=(SELECT CONCAT('SELECT COUNT(*)INTO @SPLITTED_UASD FROM ',DESTINATIONSCHEMA,'.UNIT_ACCESS_STAMP_DETAILS'));
	PREPARE COUNT_SPLITTING_UASDSTMT FROM @COUNT_SPLITTING_UASD;
	EXECUTE COUNT_SPLITTING_UASDSTMT;
	
	SET @REJECTION_COUNT=(@COUNT_UASD-@SPLITTED_UASD);
	
	SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='UNIT_ACCESS_STAMP_DETAILS');
	
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='UNIT_ACCESS_STAMP_DETAILS');
	
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='UNIT');
	
	SET @DUR=DURATION;
		
-- UPDATE QUERY FOR PRE_AUDIT_SUB_PROFILE
	SET FOREIGN_KEY_CHECKS=0;
	
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_UASD WHERE PREASP_DATA='UNIT_ACCESS_STAMP_DETAILS';
	
	SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=@USER_STAMP'));
    PREPARE LOGINID FROM @LOGIN_ID;
    EXECUTE LOGINID;
	
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
	VALUES(@POSTAPID,@SPLITTED_UASD,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);	

	SET FOREIGN_KEY_CHECKS=1;
	
	SET @TEMP_UNIT_SCDB_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_UNIT_SCDB_FORMAT'));
	PREPARE TEMP_UNIT_SCDB_DROPQUERYSTMT FROM @TEMP_UNIT_SCDB_DROPQUERY;
	EXECUTE TEMP_UNIT_SCDB_DROPQUERYSTMT;
		
	SET @TEMP_UASD_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_UNIT_ACCESS_STAMP_DETAILS'));
	PREPARE TEMP_UASD_DROPQUERYSTMT FROM @TEMP_UASD_DROPQUERY;
	EXECUTE TEMP_UASD_DROPQUERYSTMT;
COMMIT;	
END;

CALL ALL_MIG_UNIT_INSERT('rl_source','rl_dest','sattudj@gmail.com');