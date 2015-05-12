DROP PROCEDURE IF EXISTS SP_TEMP_BIZ_DAILY_SCDB_FORMAT_INSERT;
CREATE PROCEDURE SP_TEMP_BIZ_DAILY_SCDB_FORMAT_INSERT(IN SOURCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;
	SET @TBIZDLY_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_BIZ_DAILY_SCDB_FORMAT'));
	PREPARE TBIZDLY_DROPQUERYSTMT FROM @TBIZDLY_DROPQUERY;
	EXECUTE TBIZDLY_DROPQUERYSTMT;	
	SET @TBIZDLY_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_BIZ_DAILY_SCDB_FORMAT LIKE ',SOURCESCHEMA,'.BIZ_DAILY_SCDB_FORMAT'));
	PREPARE TBIZDLY_CREATEQUERYSTMT FROM @TBIZDLY_CREATEQUERY;
	EXECUTE TBIZDLY_CREATEQUERYSTMT;
	SET @TBIZDLY_INSERTQUERY=(SELECT CONCAT('INSERT ',DESTINATIONSCHEMA,'.TEMP_BIZ_DAILY_SCDB_FORMAT SELECT * FROM ',SOURCESCHEMA,'.BIZ_DAILY_SCDB_FORMAT'));
	PREPARE TBIZDLY_INSERTQUERYSTMT FROM @TBIZDLY_INSERTQUERY;
	EXECUTE TBIZDLY_INSERTQUERYSTMT;	
	SET @UPDATESLORACAIRCON=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_BIZ_DAILY_SCDB_FORMAT SET EXP_AIRCON_SERVICED_BY=',"'LORAC AIRCON AND ENGINEERING PTE LTD'",' WHERE EXP_AIRCON_SERVICED_BY=',"'LORAC AIRCON'"));
	PREPARE UPDATESLORACAIRCONSTMT FROM @UPDATESLORACAIRCON;
	EXECUTE UPDATESLORACAIRCONSTMT;	
	SET @UPDATEBCSAIRCON=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_BIZ_DAILY_SCDB_FORMAT SET EXP_AIRCON_SERVICED_BY=',"'BCS Aircon Engineering Pte Ltd'",' WHERE EXP_AIRCON_SERVICED_BY=',"'BCS AIRCON ENGINEERING'"));
	PREPARE UPDATEBCSAIRCONSTMT FROM @UPDATEBCSAIRCON;
	EXECUTE UPDATEBCSAIRCONSTMT;	
  SET @UPDATETIMESTAMP=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_BIZ_DAILY_SCDB_FORMAT SET TIMESTAMP=(SELECT CONVERT_TZ(TIMESTAMP, "+08:00","+0:00"))'));
  PREPARE UPDATETIMESTAMPSTMT FROM @UPDATETIMESTAMP;
  EXECUTE UPDATETIMESTAMPSTMT;
  SET @UPDATEPETTYID=(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.TEMP_BIZ_DAILY_SCDB_FORMAT MODIFY COLUMN EXP_PETTY_ID INTEGER'));
  PREPARE UPDATEPETTYIDSTMT FROM @UPDATEPETTYID;
  EXECUTE UPDATEPETTYIDSTMT;
  COMMIT;
END;