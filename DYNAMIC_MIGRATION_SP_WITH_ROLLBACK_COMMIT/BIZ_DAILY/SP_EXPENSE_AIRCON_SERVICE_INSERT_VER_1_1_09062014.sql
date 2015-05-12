-- version:1.1 -- sadte:09/06/2014 -- edate:09/06/2014  -- issue:566 COMMENT:12  --desc: IMPLEMENTED ROLLBACK AND COMMIT --doneby:DHIVYA
-- version:1.0 -- sadte:23/04/2014 -- edate:23/04/2014 -- issue:765  --desc: UPDATED TIMESTAMP --doneby:SASIKALA
-- version:0.9 -- sadte:27/03/2014 -- edate:27/03/2014 --desc: changed audit into source --doneby:RL
-- version:0.8 -- sdate:19/03/2014 -- edate:19/03/2014 -- issue:765 --desc:dynamically get source nd destination schema --doneby:RL
-- version:0.7 -- sdate:17/03/2014 -- edate:17/03/2014 -- issue:765 --desc:droped temp table --doneby:RL
-- version:0.6 --sdate:04/03/2014 --edate:04/03/2014 --Desc:ISSUE CORRECTED INUNIT EXPENSE- DONE BY SAFI
-- version:0.5 --sdate:28/02/2014 --edate:28/02/2014 --issue:750 --desc:changed userstamp as ULD_ID and timestamp get from scdb done by:RL
-- version:0.4--sdate:21/02/2014 --edate:22/02/2014 --issue:750 -desc:added preaudit and post audit queries done by:dhivya
-- version:0.3 --sdate:18/02/2014 --edate:18/02/2014 --issue:276 --commentno:26 --desc:ADD USERSTAMP N TIMESTAMP IN EXPENSE_HOUSEKEEPING_UNIT --doneby:RL
-- version:0.2 --sdate:21/01/2014 --edate:21/01/2014 --issue:594 --commentno:50 & 54 --doneby:RL
DROP PROCEDURE IF EXISTS SP_EXPENSE_AIRCON_SERVICE_INSERT;
CREATE PROCEDURE SP_EXPENSE_AIRCON_SERVICE_INSERT(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
	DECLARE AIRCONMINID INTEGER;
	DECLARE AIRCONMAXID INTEGER;	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;
	SET @TEMP_AIRCON_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE'));
	PREPARE TEMP_AIRCON_DROPQUERYSTMT FROM @TEMP_AIRCON_DROPQUERY;
	EXECUTE TEMP_AIRCON_DROPQUERYSTMT;
	SET @TEMP_AIRCON_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE(
    ID INTEGER AUTO_INCREMENT,
	AIRCONUNITNO INTEGER,
	UNITNOID INTEGER,
	AIRCONSERVICEBY CHAR(50),
	EDASID INTEGER,
	AIRCONDATE DATE,
	AIRCONCOMMENTS TEXT,
	AIRCONUSERSTAMP VARCHAR(50),
	AIRCONTIMESTAMP VARCHAR(50),
	AIRCONULDID INTEGER,
	PRIMARY KEY(ID))'));
	PREPARE TEMP_AIRCON_CREATEQUERYSTMT FROM @TEMP_AIRCON_CREATEQUERY;
	EXECUTE TEMP_AIRCON_CREATEQUERYSTMT;	
	SET @TEMPAIRCON_INSERQUERY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE
	(AIRCONUNITNO,AIRCONSERVICEBY,AIRCONDATE,AIRCONCOMMENTS,AIRCONUSERSTAMP,AIRCONTIMESTAMP)
    SELECT EXP_UNIT_NO,EXP_AIRCON_SERVICED_BY, EXP_AIRCON_SERVICED_DATE, EXP_AIRCON_COMMENTS, USERSTAMP,TIMESTAMP 
	FROM ',DESTINATIONSCHEMA,'.TEMP_BIZ_DAILY_SCDB_FORMAT WHERE EXP_TYPE_OF_EXPENSE="AIRCON SERVICES"'));
	PREPARE TEMPAIRCON_INSERQUERYSTMT FROM @TEMPAIRCON_INSERQUERY;
	EXECUTE TEMPAIRCON_INSERQUERYSTMT;	
  SET @UPDATETIMESTAMP=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE SET AIRCONTIMESTAMP=(SELECT CONVERT_TZ(AIRCONTIMESTAMP, "+08:00","+0:00"))'));
  PREPARE UPDATETIMESTAMPSTMT FROM @UPDATETIMESTAMP;
  EXECUTE UPDATETIMESTAMPSTMT;
	SET @MINID =(SELECT CONCAT('SELECT MIN(ID)INTO @MIN_ID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE'));
	PREPARE MINIDSTMT FROM @MINID;
	EXECUTE MINIDSTMT;	
	SET AIRCONMINID = @MIN_ID;	
	SET @MAXID =(SELECT CONCAT('SELECT MAX(ID)INTO @MAX_ID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE'));
	PREPARE MAXIDSTMT FROM @MAXID;
	EXECUTE MAXIDSTMT;	
	SET AIRCONMAXID = @MAX_ID;	
	WHILE (AIRCONMINID <= AIRCONMAXID) DO
	SET @ULDID = NULL;
	SET @UID = NULL;
	SET @EASBID = NULL;
	SET @SERVICEID = NULL;	
		SET @USERID =(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=
		(SELECT AIRCONUSERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE WHERE ID=',AIRCONMINID,')'));
		PREPARE USERIDSTMT FROM @USERID;
		EXECUTE USERIDSTMT;		
		SET @UNOID =(SELECT CONCAT('SELECT UNIT_ID INTO @UID FROM ',DESTINATIONSCHEMA,'.UNIT WHERE UNIT_NO=
		(SELECT AIRCONUNITNO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE WHERE ID=',AIRCONMINID,')'));
		PREPARE UNOIDSTMT FROM @UNOID;
		EXECUTE UNOIDSTMT;		
		SET @USERVICEBY =(SELECT CONCAT('SELECT EASB_ID INTO @EASBID FROM ',DESTINATIONSCHEMA,'.EXPENSE_AIRCON_SERVICE_BY WHERE EASB_DATA=
		(SELECT AIRCONSERVICEBY FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE WHERE ID=',AIRCONMINID,')'));
		PREPARE USERVICEBYSTMT FROM @USERVICEBY;
		EXECUTE USERVICEBYSTMT;		
		SET @MAXEDASID = (SELECT CONCAT('SELECT MAX(EDAS_ID) INTO @SERVICEID FROM ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_AIRCON_SERVICE
		WHERE UNIT_ID=@UID AND EASB_ID=@EASBID'));
		PREPARE MAXEDASIDSTMT FROM @MAXEDASID;
		EXECUTE MAXEDASIDSTMT;		
		SET @UPDATETAS = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE SET AIRCONULDID=@ULDID WHERE ID=',AIRCONMINID));
		PREPARE UPDATETASSTMT FROM @UPDATETAS;
		EXECUTE UPDATETASSTMT;		
		SET @UPDATEUNITID = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE SET UNITNOID=@UID WHERE ID=',AIRCONMINID));
		PREPARE UPDATEUNITIDSTMT FROM @UPDATEUNITID;
		EXECUTE UPDATEUNITIDSTMT;		
		SET @UPDATEEDAS = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_AIRCON_SERVICE SET EDASID=@SERVICEID WHERE ID=',AIRCONMINID));
		PREPARE UPDATEEDASSTMT FROM @UPDATEEDAS;
		EXECUTE UPDATEEDASSTMT;		
		SET AIRCONMINID = AIRCONMINID+1;	
	END WHILE;	
	SET FOREIGN_KEY_CHECKS=0;	
	SET @EAS_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.EXPENSE_AIRCON_SERVICE'));
	PREPARE EAS_DROPQUERYSTMT FROM @EAS_DROPQUERY;
	EXECUTE EAS_DROPQUERYSTMT;		
	SET @EAS_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.EXPENSE_AIRCON_SERVICE(
	EAS_ID	INTEGER NOT NULL AUTO_INCREMENT,
	EDAS_ID	INTEGER NOT NULL,
	EAS_DATE DATE NOT NULL,	
	EAS_COMMENTS TEXT NULL,
	ULD_ID INTEGER(2) NOT NULL,	
	EAS_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(EAS_ID),
	FOREIGN KEY(EDAS_ID) REFERENCES ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_AIRCON_SERVICE (EDAS_ID),
	FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
	PREPARE EAS_CREATEQUERYSTMT FROM @EAS_CREATEQUERY;
	EXECUTE EAS_CREATEQUERYSTMT;	
	SET @AIRCON_INSERQUERY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.EXPENSE_AIRCON_SERVICE
	(EDAS_ID, EAS_DATE, EAS_COMMENTS, ULD_ID,EAS_TIMESTAMP)
	SELECT EDASID,AIRCONDATE,AIRCONCOMMENTS,AIRCONULDID,AIRCONTIMESTAMP FROM ',DESTINATIONSCHEMA,'
	.TEMP_EXPENSE_AIRCON_SERVICE'));
	PREPARE AIRCON_INSERQUERYSTMT FROM @AIRCON_INSERQUERY;
	EXECUTE AIRCON_INSERQUERYSTMT;	
	SET FOREIGN_KEY_CHECKS=1;	
	COMMIT;
END;
