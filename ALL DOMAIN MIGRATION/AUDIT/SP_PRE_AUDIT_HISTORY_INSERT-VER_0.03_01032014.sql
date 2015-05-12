-- version --> 0.3 startdtae -->01/03/2014 enddate --> 01/03/2014 description --> CHANGED USERSTAMP TO ULD ID created by -->KUMAR -->issue :743
-- version --> 0.2 startdtae -->28/02/2014 enddate --> 28/02/2014 description --> CHANGED TIME STAMP FORMAT AND TIME DIFF CAL IN SAME SP created by -->KUMAR -->issue :743
-- version --> 0.1 startdtae -->20/02/2014 enddate --> 20/02/2014 description --> CREATED SP FOR INSERTING THE PRE AUDIT HISTORY DATA'S created by -->KUMAR -->issue :743
  DROP PROCEDURE IF EXISTS SP_PRE_AUDIT_HISTORY;
  CREATE PROCEDURE SP_PRE_AUDIT_HISTORY(IN ID INTEGER,
  IN PROJ_KEY VARCHAR(50),
  IN STATUS INTEGER,
  IN SCDB_REC_BDUMP INTEGER,
  IN SCDB_AREC INTEGER,
  IN SQL_REC INTEGER,
  IN PSTIME VARCHAR(15),
  IN PETIME VARCHAR(15),
  IN USER_STAMP VARCHAR(50),
  IN PRE_TIMESTAMP TIMESTAMP
 )
  BEGIN
  DECLARE TIME_DIFF TIME;
  DECLARE USERSTAMP_ID INT(2);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
  ROLLBACK;
  END;
  SET FOREIGN_KEY_CHECKS=0;
  CALL DEVELOPMENT.SP_CHANGE_USERSTAMP_AS_ULDID(USER_STAMP,@ULDID);
  SET USERSTAMP_ID = (SELECT @ULDID);
  SET TIME_DIFF=(SELECT TIMEDIFF(PETIME,PSTIME));
  INSERT INTO PRE_AUDIT_HISTORY(PREAMP_ID,PREAMP_PROJ_KEY,PREAMP_STATUS,PREAMP_SCDB_REC_BDUMP,PREAMP_SCDB_AREC,PREAMP_SQL_REC,PREAMP_PSTIME,PREAMP_PETIME,PREAMP_EXE_TIME,ULD_ID,PREAMP_TIMESTAMP)
  VALUES(ID,PROJ_KEY,STATUS,SCDB_REC_BDUMP,SCDB_AREC,SQL_REC,PSTIME,PETIME,TIME_DIFF,USERSTAMP_ID,PRE_TIMESTAMP);
  SET FOREIGN_KEY_CHECKS=1;
  COMMIT;
  END;