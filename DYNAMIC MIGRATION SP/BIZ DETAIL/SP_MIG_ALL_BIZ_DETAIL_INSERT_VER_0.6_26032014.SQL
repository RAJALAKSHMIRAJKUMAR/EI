-- version:0.6 -- sdate:24/03/2014 -- edate:26/03/2014 -- issue:765 --COMMENT NO: 8--desc:UPDATED SP DYNAMICALLY --doneby:SAFI
-- version:0.5 -- sdate:17/03/2014 -- edate:17/03/2014 -- issue:765 --desc:droped temp table --doneby:RL
--version:0.4 --sdate:28/02/2014 --edate:28/02/2014 --issue:750 --desc:changed userstamp as ULD_ID and timestamp get from scdb done by:RL
--version:0.3 --sdate:21/02/2014 --edate:21/02/2014 --issue:750 --desc:added preaudit and post audit queries done by:dhivya
--version:0.2 --sdate:21/01/2014 --edate:21/01/2014 --issue:594 --commentno:50 & 54 --doneby:RL
DROP PROCEDURE IF EXISTS SP_MIG_ALL_BIZ_DETAIL_INSERT;
CREATE PROCEDURE SP_MIG_ALL_BIZ_DETAIL_INSERT(IN SOURCESCHEMA  VARCHAR(40),IN DESTINATIONSCHEMA  VARCHAR(40),IN MIGUSERSTAMP VARCHAR(50))	
BEGIN
SET FOREIGN_KEY_CHECKS=0;
	CALL SP_TEMP_BIZ_DETAIL_SCDB_FORMAT(SOURCESCHEMA,DESTINATIONSCHEMA);
	CALL EXPENSE_AIRCON_SERVICE_BY_INSERT(SOURCESCHEMA,DESTINATIONSCHEMA,MIGUSERSTAMP);
	CALL SP_EXPENSE_DETAIL_AIRCON_SERVICE_INSERT(SOURCESCHEMA,DESTINATIONSCHEMA,MIGUSERSTAMP);
	CALL SP_EXPENSE_DETAIL_ELECTRICITY_INSERT(SOURCESCHEMA,DESTINATIONSCHEMA,MIGUSERSTAMP);
	CALL SP_EXPENSE_DETAIL_DIGITAL_VOICE_INSERT(SOURCESCHEMA,DESTINATIONSCHEMA,MIGUSERSTAMP);
	CALL SP_EXPENSE_DETAIL_CARPARK_INSERT(SOURCESCHEMA,DESTINATIONSCHEMA,MIGUSERSTAMP);
	CALL SP_EXPENSE_DETAIL_STARHUB_INSERT(SOURCESCHEMA,DESTINATIONSCHEMA,MIGUSERSTAMP);
	SET @DROP_TEMP_BIZ_DETAIL_SCDB_FORMAT=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT'));
    PREPARE TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT FROM @DROP_TEMP_BIZ_DETAIL_SCDB_FORMAT;
    EXECUTE TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT;
    SET FOREIGN_KEY_CHECKS=1;
END;

CALL SP_MIG_ALL_BIZ_DETAIL_INSERT(SOURCESCHEMA,DESTINATIONSCHEMA,MIGUSERSTAMP);