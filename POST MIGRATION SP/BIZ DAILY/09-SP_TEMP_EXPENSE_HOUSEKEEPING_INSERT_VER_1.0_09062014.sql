DROP PROCEDURE IF EXISTS SP_TEMP_EXPENSE_HOUSEKEEPING_INSERT;
CREATE PROCEDURE SP_TEMP_EXPENSE_HOUSEKEEPING_INSERT(IN SOURCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
	DECLARE MINIMUMID INTEGER;
	DECLARE MAXIMUMID INTEGER;	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;	
	SET @TEMP_EHKDROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING'));
	PREPARE TEMP_EHKDROPQUERYSTMT FROM @TEMP_EHKDROPQUERY;
	EXECUTE TEMP_EHKDROPQUERYSTMT;	
	SET @TEMP_EHKCREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING(
	ID INTEGER AUTO_INCREMENT,
	TEHK_UNITNO INTEGER,
	TEHK_FORPERIOD DATE,
	TEHK_PAIDDATE DATE,
	TEHK_AMOUNT DECIMAL(7,2),
	TEHK_COMMENTS TEXT,
	TEHK_USERSTAMP VARCHAR(50),
	TEHK_ULDID INTEGER,
	TEHK_TIMESTAMP VARCHAR(50),
	PRIMARY KEY(ID))'));
	PREPARE TEMP_EHKCREATEQUERYSTMT FROM @TEMP_EHKCREATEQUERY;
	EXECUTE TEMP_EHKCREATEQUERYSTMT;	
	SET @TEMP_EHKINSERTQUERY = (SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING
	(ID,TEHK_UNITNO,TEHK_FORPERIOD,TEHK_PAIDDATE,TEHK_AMOUNT,TEHK_COMMENTS,TEHK_USERSTAMP,TEHK_TIMESTAMP)
	SELECT EXP_HKP_ID,EXP_HKP_UNIT_NO,EXP_HKP_FOR_PERIOD,EXP_HKP_PAID_DATE,EXP_HKP_AMOUNT,EXP_HKP_COMMENTS, 
	USERSTAMP,TIMESTAMP FROM ',SOURCESCHEMA,'.BIZ_DAILY_SCDB_FORMAT WHERE EXP_TYPE_OF_EXPENSE="HOUSE KEEPING PAYMENT"'));
	PREPARE TEMP_EHKINSERTQUERYSTMT FROM @TEMP_EHKINSERTQUERY;
	EXECUTE TEMP_EHKINSERTQUERYSTMT;	
  SET @UPDATETIMESTAMP=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING SET TEHK_TIMESTAMP=(SELECT CONVERT_TZ(TEHK_TIMESTAMP, "+08:00","+0:00"))'));
  PREPARE UPDATETIMESTAMPSTMT FROM @UPDATETIMESTAMP;
  EXECUTE UPDATETIMESTAMPSTMT;
	SET @TMINID =(SELECT CONCAT('SELECT MIN(ID)INTO @THMINID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING'));
	PREPARE TMINIDSTMT FROM @TMINID;
	EXECUTE TMINIDSTMT;
	SET MINIMUMID = @THMINID;	
	SET @TMAXID =(SELECT CONCAT('SELECT MAX(ID)INTO @THMAXID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING'));
	PREPARE TMAXIDSTMT FROM @TMAXID;
	EXECUTE TMAXIDSTMT;
	SET MAXIMUMID = @THMAXID;	
	WHILE(MINIMUMID <= MAXIMUMID) DO	
		SET @ULDID = NULL;	
		SET @USERID =(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=
		(SELECT TEHK_USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING WHERE ID=',MINIMUMID,')'));
		PREPARE USERIDSTMT FROM @USERID;
		EXECUTE USERIDSTMT;		
		SET @UPDATEULDID = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING SET TEHK_ULDID=@ULDID WHERE ID=',MINIMUMID));
		PREPARE UPDATEULDIDSTMT FROM @UPDATEULDID;
		EXECUTE UPDATEULDIDSTMT;			
	SET MINIMUMID = MINIMUMID+1;
	END WHILE;	
	COMMIT;
END;	
