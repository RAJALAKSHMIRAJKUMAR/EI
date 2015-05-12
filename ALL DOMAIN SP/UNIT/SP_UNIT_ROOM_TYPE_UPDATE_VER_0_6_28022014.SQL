--version 0.6 --sdate:28/02/2014 --edate:28/02/2014 --issue:754 --comment:36 --doneby:RL	
--version 0.5 --sdate:27/02/2014 --edate:27/02/2014 --issue:754 --comment:22 --doneby:RL	
--version:0.4 --issue:346 --commentno:227 --sdate:15/02/2014 --edate:15/02/2014 --desc:return success flag whether the data is updated r not --doneby:RL
--version:0.3 --ISSUE NO:636 COMMENT NO:#47 sd:07/11/2013 --enddate:07/11/2013 --desc:CHANGED SP NAME and added comments DONE BY:DHIVYA.A
--version:0.2 --date:19/08/2013  --issueno:346 --commentno:79 -->desc:added URTD_ROOM_TYPE header updation -->created by:DHIVYA.A
--version:0.1 --startdate:14/08/2013 --enddate:14/08/2013 -->issueno:346 -->commentno:70 -->desc:unit room type table updation -->created by:rajalakshmi.rajalakshmi
DROP PROCEDURE IF EXISTS SP_UNIT_ROOM_TYPE_UPDATE;
CREATE PROCEDURE SP_UNIT_ROOM_TYPE_UPDATE(
IN ID INT,
IN ROOMTYPE VARCHAR(30),
IN USERSTAMP VARCHAR(50),
OUT FLAG INTEGER)
BEGIN 
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
	END;
	START TRANSACTION;
	SET FLAG = 0;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
	IF NOT EXISTS(SELECT URTD_ROOM_TYPE FROM UNIT_ROOM_TYPE_DETAILS WHERE URTD_ROOM_TYPE=ROOMTYPE)THEN
--UPDATE QUERY FOR UNIT_ROOM_TYPE_DETAILS TABLE
		UPDATE UNIT_ROOM_TYPE_DETAILS SET URTD_ROOM_TYPE=ROOMTYPE, ULD_ID=USERSTAMP_ID WHERE URTD_ID = ID;
		SET FLAG = 1;
	END IF;
	COMMIT;
END;