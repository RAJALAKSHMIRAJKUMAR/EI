DROP PROCEDURE IF EXISTS SP_PRE_PROD_AUDIT_HISTORY;
CREATE PROCEDURE  SP_PRE_PROD_AUDIT_HISTORY
(
IN SOURCE_TABLENAME VARCHAR(70),
IN SOURCE_REC INTEGER,
IN DESTINATION_TABLENAME VARCHAR(70),
IN DESTINATION_REC INTEGER,
IN SUCCESS_FLAG INTEGER,
IN PSTIME TIME,
IN PETIME TIME,
IN USERSTAMP VARCHAR(50),
IN DESTINATIONSCHEMA VARCHAR(50)
)
BEGIN
  DECLARE TIME_DIFF TIME;
  DECLARE USERSTAMP_ID INT(2);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
  ROLLBACK;
  END;
  START TRANSACTION;
SET FOREIGN_KEY_CHECKS=0;
SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',USERSTAMP,'"'));
PREPARE LOGINID FROM @LOGIN_ID;
EXECUTE LOGINID;
SET USERSTAMP_ID = (SELECT @ULDID);
SET TIME_DIFF=(SELECT TIMEDIFF(PETIME,PSTIME));
SET FOREIGN_KEY_CHECKS=0;
INSERT INTO PRE_PROD_AUDIT_HISTORY(PPAH_SOURCE_TABLE_NAME,PPAH_SOURCE_NO_OF_REC,PPAH_DESTINATION_TABLE_NAME,PPAH_DESTINATION_NO_OF_REC,PPAH_SUCCESS_FLAG,PPAH_PSTIME,PPAH_PETIME,PPAH_EXETIME,ULD_ID) VALUES(SOURCE_TABLENAME,SOURCE_REC,DESTINATION_TABLENAME,DESTINATION_REC,SUCCESS_FLAG,PSTIME,PETIME,TIME_DIFF,USERSTAMP_ID);
SET FOREIGN_KEY_CHECKS=1;
COMMIT;
END; 
  