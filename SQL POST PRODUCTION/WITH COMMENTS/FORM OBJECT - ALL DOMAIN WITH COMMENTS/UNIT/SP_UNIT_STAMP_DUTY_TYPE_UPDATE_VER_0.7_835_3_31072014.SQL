-- version 0.7 --sadte:31/07/2014 --edate:31/07/2014 --issue:835 --commentno:3 --desc:implementing auto commit-- doneby:RL
--version 0.6 --sdate:28/02/2014 --edate:28/02/2014 --issue:754 --comment:36 --doneby:RL	
--version 0.5 --sdate:27/02/2014 --edate:27/02/2014 --issue:754 --comment:22 --doneby:RL	
--version:0.4 --issue:346 --commentno:227 --sdate:15/02/2014 --edate:15/02/2014 --desc:return success flag whether the data is updated r not --doneby:RL
--version:0.3 --ISSUE NO:636 COMMENT NO:#47 sd:07/11/2013 --enddate:07/11/2013 --desc:CHANGED SP NAME and added comments DONE BY:DHIVYA.A
--version:0.2 -->startdate:14/08/2013 -->enddate:14/08/2013 -->issueno:346 -->commentno:73 -->desc:added USDT_USERSTAMP header updation -->created by:DHIVYA.A
--> version:0.1 -->startdate:14/08/2013 -->enddate:14/08/2013 -->issueno:346 -->commentno:73 -->desc:unit stamp duty table updation -->created by:rajalakshmi.rajalakshmi--> version:0.1 -->startdate:14/08/2013 -->enddate:14/08/2013 -->issueno:346 -->commentno:73 -->desc:unit stamp duty table updation -->created by:rajalakshmi.rajalakshmi
DROP PROCEDURE IF EXISTS SP_UNIT_STAMP_DUTY_TYPE_UPDATE;
CREATE PROCEDURE SP_UNIT_STAMP_DUTY_TYPE_UPDATE(
IN ID INT,
IN STAMP_DUTY_TYPE VARCHAR(30),
IN USERSTAMP VARCHAR(50),
OUT FLAG INTEGER)
BEGIN 
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
		SET FLAG = 0;
	END;
	SET AUTOCOMMIT = 0;
	START TRANSACTION;
	SET FLAG = 0;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
	IF NOT EXISTS(SELECT USDT_DATA FROM UNIT_STAMP_DUTY_TYPE WHERE USDT_DATA=STAMP_DUTY_TYPE)THEN
--UPDATE QUERY FOR UNIT_STAMP_DUTY_TYPE TABLE
		UPDATE UNIT_STAMP_DUTY_TYPE SET USDT_DATA=STAMP_DUTY_TYPE,ULD_ID=USERSTAMP_ID WHERE USDT_ID = ID;
		SET FLAG = 1;
	END IF;
	COMMIT;
END;