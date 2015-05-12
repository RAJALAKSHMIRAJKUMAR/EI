--version 1.4 --sdate:09/04/2014 --edate:09/04/2014 --issue:346 --comment:265 --doneby:SARADAMBAL M---DESC:CHANGE ONE CONDITION SD<=ED
--version 1.3 --sdate:28/02/2014 --edate:28/02/2014 --issue:754 --comment:36 --doneby:RL
--version 1.2 --sdate:27/02/2014 --edate:27/02/2014 --issue:596 --comment:23 --doneby:RL
--version 1.1 --sdate:27/02/2014 --edate:27/02/2014 --issue:754,346 --comment:22,250 --doneby:RL	
-->version 1.0 -->modified by: BHAVANI.R --startdate:17/02/2014 --enddate:17/02/2014 --issueno:749 commentno:#9  -->desc:Implementation of flag in SP_UNIT_CREATION_INSERT 
-->version 0.9 -->modified by :DINESH.M --startdate:20/11/2013 --enddate:21/11/2013 --issueno:253 commentno:#111 -->desc:changed DATA TYPE (INTEGER) FOR ACCESS_CARD 
-->version 0.8 -->modified by: RL --startdate:22/10/2013 --enddate:22/10/2013 --issue:346 commentno#114 --desc:UD_RENTAL changed as UD_PAYMENT
-->version 0.7 -->modified by M.LOGASUNDARI -->startdate:2013-08-21 -->enddate:2012-08-21 -->issueno:346  -->commentno:83 -->included the userstamp column for unit room type details and unit stamp duty types
-->version 0.6 -->modify by:rajalakshmi.r -->startdate:2013-08-14 -->enddate:2013-08-14 -->issueno:346 -->commentno:61
-->version 0.5 -->modify by:rajalakshmi.r -->startdate:2013-07-31 -->enddate:2013-07-31 -->issueno:346 -->commentno:53
-->version 0.4 -->created by:rajalakshmi -->startdate:2013-07-26 -->enddate:2013-07-26 -->issueno:253 -->desc:combined mandatory field SP & non mandatory fields SP
-->version 0.3 -->created by:rajalakshmi -->startdate:2013-07-25 -->enddate:2013-07-25 -->issueno:253 -->desc:added UD_NON_EI header
-->version 0.2 -->created by:rajalakshmi -->date:2013-07-22 -->issueno:566 -->desc:implemented rollback & commit commands
-->version 0.1 -->created by:loganathan -->date:2013-05-10 -->issueno:346 -->desc:unit creation  mandatory fields insert sp

DROP PROCEDURE IF EXISTS SP_UNIT_CREATION_INSERT;
CREATE PROCEDURE SP_UNIT_CREATION_INSERT(
-- parameters for unit table
IN UNIT_NUMBER SMALLINT(4),
-- parameters for unit_details table
IN UNIT_PAYMENT SMALLINT(4),
IN START_DATE DATE,
IN END_DATE DATE,
IN NON_EI CHAR(1),
IN UNIT_DEPOSIT INT(5),
IN USERSTAMP VARCHAR(50),
-- parameters for unit_access_stamp_details table
IN ACCESS_CARD INTEGER(7),
IN ROOMTYPE VARCHAR(30),
IN STAMP_DUTY_DATE DATE,
IN STAMPDUTYTPYE CHAR(12),
IN STAMP_DUTY_AMOUNT DECIMAL(6,2),
IN COMMENTS TEXT,
-- parameters for unit_login_details table
IN DOOR_CODE VARCHAR(10),
IN WEB_LOGIN VARCHAR(20),
IN WEB_PASSWORD VARCHAR(6),
-- parameters for unit_account_details table
IN ACCOUNT_NUMBER VARCHAR(15),
IN ACCOUNT_NAME VARCHAR(25),
IN BANK_CODE VARCHAR(5),
IN BRANCH_CODE VARCHAR(5),
IN BANK_ADDRESS VARCHAR(250),
OUT UNITCREATION_FLAG INTEGER)
BEGIN
-- declaring variables
	DECLARE ROOM_TYPE INT;
	DECLARE STAMP_DUTY_TYPE INT;
	DECLARE STATUS INT(1) DEFAULT 0;
	DECLARE USERSTAMP_ID INTEGER(2);
-- query for rollback comment
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
	END;
-- set null for non mandotary fields for unit_details table
	IF NON_EI='' THEN
		SET NON_EI=NULL;
	END IF;
	IF UNIT_DEPOSIT='' THEN 
		SET UNIT_DEPOSIT=NULL;
	END IF;
-- set null for non mandotary fields for unit_account_details table
	IF ACCOUNT_NUMBER='' THEN
		SET ACCOUNT_NUMBER=NULL;
	END IF;
	IF ACCOUNT_NAME='' THEN
		SET ACCOUNT_NAME=NULL;
	END IF;
	IF BANK_CODE='' THEN
		SET BANK_CODE=NULL;
	END IF;
	IF BRANCH_CODE='' THEN
		SET BRANCH_CODE=NULL;
	END IF;
	IF BANK_ADDRESS='' THEN
		SET BANK_ADDRESS=NULL;
	END IF;
-- set null for non mandotary fields for unit_access_stamp_details table
	IF ACCESS_CARD='' THEN 
		SET ACCESS_CARD=NULL;
	END IF;
	IF ROOMTYPE='' OR ROOMTYPE=NULL THEN
		SET ROOMTYPE=NULL;
	END IF;
	IF STAMPDUTYTPYE='' OR STAMPDUTYTPYE=NULL THEN 
		SET STAMPDUTYTPYE=NULL;
	END IF;
	IF COMMENTS='' THEN
		SET COMMENTS=NULL;
	END IF;
-- set null for non mandotary fields for unit_login_details table
	IF WEB_LOGIN=''THEN
		SET WEB_LOGIN=NULL;
	END IF;
	IF WEB_PASSWORD='' THEN
		SET WEB_PASSWORD=NULL;
	END IF;
	IF DOOR_CODE='' THEN
		SET DOOR_CODE=NULL;
	END IF;
	START TRANSACTION;
	SET UNITCREATION_FLAG=0;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
-- insert query for unit table
	IF(UNIT_NUMBER IS NOT NULL AND UNIT_PAYMENT IS NOT NULL AND START_DATE IS NOT NULL AND END_DATE IS NOT NULL) THEN
		IF(START_DATE <= END_DATE)THEN
			SET STATUS = 2;
		ELSE
			SET STATUS = 0;
		END IF;
		IF(STATUS =2)THEN
			INSERT INTO UNIT (UNIT_NO) VALUES(UNIT_NUMBER);
		END IF;
		IF(STATUS = 2)THEN
			INSERT INTO UNIT_DETAILS(UNIT_ID,UD_START_DATE,UD_END_DATE,UD_PAYMENT,UD_DEPOSIT,ULD_ID,UD_NON_EI,UD_COMMENTS)VALUES((SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER),START_DATE ,END_DATE,UNIT_PAYMENT,UNIT_DEPOSIT,USERSTAMP_ID,NON_EI,COMMENTS);
			SET UNITCREATION_FLAG = 1; 
		ELSE
			SET UNITCREATION_FLAG = 0; 
		END IF;
	END IF;
-- insert query for unit_room_type_details table
	IF(STATUS =2)THEN
		IF ROOMTYPE IS NOT NULL THEN
			IF EXISTS(SELECT URTD_ROOM_TYPE FROM UNIT_ROOM_TYPE_DETAILS WHERE URTD_ROOM_TYPE=ROOMTYPE) THEN
				SET ROOM_TYPE = (SELECT URTD_ID FROM UNIT_ROOM_TYPE_DETAILS WHERE URTD_ROOM_TYPE=ROOMTYPE);
			END IF;
			IF NOT EXISTS(SELECT URTD_ROOM_TYPE FROM UNIT_ROOM_TYPE_DETAILS WHERE URTD_ROOM_TYPE=ROOMTYPE) THEN
				INSERT INTO UNIT_ROOM_TYPE_DETAILS (URTD_ROOM_TYPE, ULD_ID) VALUES (ROOMTYPE, USERSTAMP_ID);
				SET UNITCREATION_FLAG=1;
				SET ROOM_TYPE = (SELECT URTD_ID FROM UNIT_ROOM_TYPE_DETAILS WHERE URTD_ROOM_TYPE=ROOMTYPE);
			END IF;
		END IF;
	END IF;
-- insert query for unit_stamp_duty_type table
	IF(STATUS = 2) THEN
		IF STAMPDUTYTPYE IS NOT NULL THEN
			IF EXISTS(SELECT USDT_DATA FROM UNIT_STAMP_DUTY_TYPE WHERE USDT_DATA=STAMPDUTYTPYE) THEN
				SET STAMP_DUTY_TYPE = (SELECT USDT_ID FROM UNIT_STAMP_DUTY_TYPE WHERE USDT_DATA=STAMPDUTYTPYE);
			END IF;
			IF NOT EXISTS(SELECT USDT_DATA FROM UNIT_STAMP_DUTY_TYPE WHERE USDT_DATA=STAMPDUTYTPYE) THEN
				INSERT INTO UNIT_STAMP_DUTY_TYPE (USDT_DATA, ULD_ID) VALUES (STAMPDUTYTPYE, USERSTAMP_ID);
				SET UNITCREATION_FLAG=1;
				SET STAMP_DUTY_TYPE = (SELECT USDT_ID FROM UNIT_STAMP_DUTY_TYPE WHERE USDT_DATA=STAMPDUTYTPYE);
			END IF;
		END IF;
	END IF;
-- insert query for unit_access_stamp_details table
	IF(STATUS =2)THEN
		IF(ACCESS_CARD IS NULL AND ( ROOM_TYPE IS NOT NULL OR STAMP_DUTY_DATE IS NOT NULL OR  STAMP_DUTY_TYPE IS NOT NULL OR STAMP_DUTY_AMOUNT IS NOT NULL)) THEN
			INSERT INTO UNIT_ACCESS_STAMP_DETAILS(UNIT_ID,UASD_ACCESS_CARD,URTD_ID,UASD_STAMPDUTYDATE,USDT_ID,UASD_STAMPDUTYAMT,ULD_ID)
			VALUES((SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER),ACCESS_CARD,ROOM_TYPE,STAMP_DUTY_DATE,STAMP_DUTY_TYPE,STAMP_DUTY_AMOUNT,USERSTAMP_ID);
			SET UNITCREATION_FLAG=1;
		END IF;
	END IF;
	IF(STATUS = 2)THEN
		IF(ACCESS_CARD IS NOT NULL)THEN
			INSERT INTO UNIT_ACCESS_STAMP_DETAILS(UNIT_ID,UASD_ACCESS_CARD,URTD_ID,UASD_STAMPDUTYDATE,USDT_ID,UASD_STAMPDUTYAMT,ULD_ID,UASD_ACCESS_INVENTORY)
			VALUES((SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER),ACCESS_CARD,ROOM_TYPE,STAMP_DUTY_DATE,STAMP_DUTY_TYPE,STAMP_DUTY_AMOUNT,USERSTAMP_ID,'X');
			SET UNITCREATION_FLAG=1;
		END IF;
	END IF;
-- insert query for unit_login_details table
	IF(STATUS = 2)THEN
		IF (DOOR_CODE IS NOT NULL OR WEB_LOGIN IS NOT NULL OR WEB_PASSWORD IS NOT NULL ) THEN
			INSERT INTO UNIT_LOGIN_DETAILS(UNIT_ID,ULDTL_DOORCODE,ULDTL_WEBLOGIN,ULDTL_WEBPWD,ULD_ID)VALUES((SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER), DOOR_CODE,WEB_LOGIN,WEB_PASSWORD,USERSTAMP_ID);
			SET UNITCREATION_FLAG=1;
		END IF;
	END IF;
-- insert query for unit_account_details table
	IF(STATUS = 2)THEN
		IF(ACCOUNT_NUMBER IS NOT NULL OR ACCOUNT_NAME IS NOT NULL OR BANK_CODE IS NOT NULL OR BRANCH_CODE IS NOT NULL OR BANK_ADDRESS IS NOT NULL ) THEN
			INSERT INTO UNIT_ACCOUNT_DETAILS(UNIT_ID,UACD_ACC_NO,UACD_ACC_NAME,UACD_BANK_CODE,UACD_BRANCH_CODE,UACD_BANK_ADDRESS)VALUES((SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER),ACCOUNT_NUMBER,ACCOUNT_NAME,BANK_CODE,BRANCH_CODE,BANK_ADDRESS);
			SET UNITCREATION_FLAG=1;
		END IF;
	END IF;
COMMIT ;
END;