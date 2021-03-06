DROP PROCEDURE IF EXISTS SP_EMPDTL_INSERT;
CREATE PROCEDURE SP_EMPDTL_INSERT(
IN FIRST_NAME CHAR(30),
IN LAST_NAME CHAR(30),
IN DESIGNATION TEXT,
IN MOBILE  VARCHAR(10),
IN EMAIL VARCHAR(40),
IN COMMENTS TEXT,
IN USERSTAMP varchar(50),
IN CARD_NO TEXT,
OUT EMP_SUCCESSFLAG TEXT)
BEGIN
	DECLARE TEMP_ACCESS_CARD TEXT;
    DECLARE ACCESS_CARD_NO INTEGER(7);
    DECLARE ACCESS_POSITION INTEGER;
    DECLARE ACCESS_LOCATION INTEGER;
    DECLARE ACCESS_LENGTH INTEGER;
    DECLARE TEMP_ACCESS_CARD_FLAG TEXT;
    DECLARE ACCESS_CARD_FLAG INTEGER(7);
    DECLARE ACCESS_POSITION_FLAG INTEGER;
    DECLARE ACCESS_LOCATION_FLAG INTEGER;
    DECLARE ACCESS_LENGTH_FLAG INTEGER;
    DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE SYSDATEANDTIME VARCHAR(50);
	DECLARE SYSDATEANDULDID VARCHAR(50);
	DECLARE CHECK_CARDNO TEXT;
	DECLARE ACTIVECARDCOUNT INTEGER;
	DECLARE MINID INTEGER;
	DECLARE MAXID INTEGER;
	DECLARE EMPLOYEE_LENGTH INTEGER;
	DECLARE LOCATION INTEGER;
	DECLARE ACTIVECARDNO INTEGER(7);
	DECLARE SUCCESS_ECNDATA TEXT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		IF(CHECK_CARDNO IS NOT NULL)THEN
			SET @CHECK_CARDNO_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',CHECK_CARDNO,''));
			PREPARE CHECK_CARDNO_DROPQUERY_STMT FROM @CHECK_CARDNO_DROPQUERY;
			EXECUTE CHECK_CARDNO_DROPQUERY_STMT;
		END IF;
	END;
	SET AUTOCOMMIT = 0;
	START TRANSACTION;
	SET EMP_SUCCESSFLAG='';
	SET ACTIVECARDCOUNT = 0;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
	IF EMAIL = '' THEN
		SET EMAIL=NULL;
	END IF;
	IF COMMENTS = '' THEN
		SET COMMENTS=NULL;
	END IF;
	IF CARD_NO='' THEN
		SET CARD_NO=NULL;
	END IF;
	SET SUCCESS_ECNDATA =  (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 571);
	SET SYSDATEANDTIME = (SELECT SYSDATE());
	SET SYSDATEANDTIME = (SELECT REPLACE(SYSDATEANDTIME,' ',''));
	SET SYSDATEANDTIME = (SELECT REPLACE(SYSDATEANDTIME,'-',''));
	SET SYSDATEANDTIME = (SELECT REPLACE(SYSDATEANDTIME,':',''));
	SET SYSDATEANDULDID = (SELECT CONCAT(SYSDATEANDTIME,'_',USERSTAMP_ID));	
	SET CHECK_CARDNO = (SELECT CONCAT('TEMP_CHECK_EMP_CARDNO','_',SYSDATEANDULDID));
	SET @TEMP_CARD_NO = CARD_NO;
	IF(CARD_NO IS NOT NULL) THEN
		SET @CHECK_CARDNO_CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',CHECK_CARDNO,'(
		ID INTEGER AUTO_INCREMENT,
		CARDNO INTEGER(7),
		UASDID INTEGER NOT NULL,
		ACTIVE CHAR(1),
		LOST CHAR(1),
		INVENTORY CHAR(1),
		PRIMARY KEY(ID))'));
		PREPARE CHECK_CARDNO_CREATEQUERY_STMT FROM @CHECK_CARDNO_CREATEQUERY;
		EXECUTE CHECK_CARDNO_CREATEQUERY_STMT;
		MAIN_LOOP : LOOP
			CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_CARD_NO,@VALUE,@REMAINING_STRING);
			SELECT @VALUE INTO ACCESS_CARD_NO;
			SELECT @REMAINING_STRING INTO @TEMP_CARD_NO;
			SET @CARDID = (SELECT CONCAT('SELECT UASD_ID  INTO @UASDID_VALUE FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=',ACCESS_CARD_NO,''));
			PREPARE CARDID_STMT FROM @CARDID;
			EXECUTE CARDID_STMT;
			SET @ACTIVE_FLAG = (SELECT CONCAT('SELECT UASD_ACCESS_ACTIVE  INTO @ACTIVE_VALUE FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=',ACCESS_CARD_NO,''));
			PREPARE ACTIVE_FLAG_STMT FROM @ACTIVE_FLAG;
			EXECUTE ACTIVE_FLAG_STMT;
			SET @LOST_FLAG = (SELECT CONCAT('SELECT UASD_ACCESS_LOST INTO @LOST_VALUE FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=',ACCESS_CARD_NO,''));
			PREPARE LOST_FLAG_STMT FROM @LOST_FLAG;
			EXECUTE LOST_FLAG_STMT;
			SET @INVENTORY_FLAG = (SELECT CONCAT('SELECT UASD_ACCESS_INVENTORY INTO @INVENTORY_VALUE FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=',ACCESS_CARD_NO,''));
			PREPARE INVENTORY_FLAG_STMT FROM @INVENTORY_FLAG;
			EXECUTE INVENTORY_FLAG_STMT;
			SET @CHECK_CARDNO_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',CHECK_CARDNO,'(CARDNO,UASDID,ACTIVE,LOST,INVENTORY)VALUES
			(',ACCESS_CARD_NO,',@UASDID_VALUE,@ACTIVE_VALUE,@LOST_VALUE,@INVENTORY_VALUE)'));
			PREPARE CHECK_CARDNO_INSERTQUERY_STMT FROM @CHECK_CARDNO_INSERTQUERY;
			EXECUTE CHECK_CARDNO_INSERTQUERY_STMT;
			IF @TEMP_CARD_NO IS NULL THEN
				LEAVE  MAIN_LOOP;
			END IF;
			SET @UASDID_VALUE = NULL;
			SET @ACTIVE_VALUE = NULL;
			SET @LOST_VALUE = NULL;
			SET @INVENTORY_VALUE = NULL;
		END LOOP;
		SET @ACTIVECARD_COUNT = (SELECT CONCAT('SELECT COUNT(*) INTO @ACTIVE_CARD_COUNT FROM ',CHECK_CARDNO,' WHERE ACTIVE IS NOT NULL OR LOST IS NOT NULL'));
		PREPARE ACTIVECARD_COUNT_STMT FROM @ACTIVECARD_COUNT;
		EXECUTE ACTIVECARD_COUNT_STMT;
		SET ACTIVECARDCOUNT = @ACTIVE_CARD_COUNT;
	END IF;
	IF(ACTIVECARDCOUNT!=0) THEN
		SET @TEMP_MINID = (SELECT CONCAT('SELECT MIN(ID) INTO @TEMPMINID FROM ',CHECK_CARDNO));
		PREPARE TEMP_MINID_STMT FROM @TEMP_MINID;
		EXECUTE TEMP_MINID_STMT;
		SET MINID=@TEMPMINID;
		SET @TEMP_MAXID =(SELECT CONCAT('SELECT MAX(ID) INTO @TEMPMAXID FROM ',CHECK_CARDNO));
		PREPARE TEMP_MAXID_STMT FROM @TEMP_MAXID;
		EXECUTE TEMP_MAXID_STMT;
		SET MAXID=@TEMPMAXID;
		WHILE (MINID <= MAXID) DO
			SET @ACTIVE_CARDNO = (SELECT CONCAT('SELECT CARDNO INTO @ACTIVE_CARD_NO FROM ',CHECK_CARDNO,' WHERE ID =',MINID,' AND (ACTIVE IS NOT NULL OR LOST IS NOT NULL)'));
			PREPARE ACTIVE_CARD_NO_STMT FROM @ACTIVE_CARDNO;
			EXECUTE ACTIVE_CARD_NO_STMT;
			SET ACTIVECARDNO = @ACTIVE_CARD_NO;
			IF (ACTIVECARDNO IS NOT NULL)THEN
				SET EMP_SUCCESSFLAG = (SELECT CONCAT(EMP_SUCCESSFLAG,',',ACTIVECARDNO));
			END IF;
			SET MINID = MINID+1;
			SET @ACTIVE_CARD_NO = NULL;
		END WHILE;
		SET LOCATION=(SELECT LOCATE(',', EMP_SUCCESSFLAG,EMPLOYEE_LENGTH));
		SET EMP_SUCCESSFLAG=(SELECT SUBSTRING(EMP_SUCCESSFLAG,LOCATION+2));
		SET EMP_SUCCESSFLAG = (SELECT REPLACE(SUCCESS_ECNDATA,'[CARD NO]',EMP_SUCCESSFLAG));
	END IF;
	IF (FIRST_NAME IS NULL OR LAST_NAME IS NULL OR DESIGNATION IS NULL OR MOBILE IS NULL OR USERSTAMP_ID IS NULL ) THEN
		SET EMP_SUCCESSFLAG = 0;
	END IF;
	IF (ACTIVECARDCOUNT = 0)THEN
		IF (FIRST_NAME IS NOT NULL AND LAST_NAME IS NOT NULL AND DESIGNATION IS NOT NULL AND MOBILE IS NOT NULL AND USERSTAMP_ID IS NOT NULL ) THEN
			IF CARD_NO IS NULL THEN
				INSERT INTO EMPLOYEE_DETAILS(EMP_FIRST_NAME,EMP_LAST_NAME,ECN_ID,EMP_MOBILE,EMP_EMAIL,EMP_COMMENTS,ULD_ID)
				VALUES (FIRST_NAME,LAST_NAME,(SELECT ECN_ID FROM EXPENSE_CONFIGURATION WHERE ECN_DATA=DESIGNATION AND CGN_ID=35),MOBILE,EMAIL,COMMENTS,USERSTAMP_ID);
				SET EMP_SUCCESSFLAG=1;
			END IF;
			IF(CARD_NO IS NOT NULL) THEN
				SET TEMP_ACCESS_CARD=CARD_NO;
				SET ACCESS_LENGTH=1;
				loop_label:  LOOP
					SET ACCESS_POSITION=(SELECT LOCATE(',', TEMP_ACCESS_CARD,ACCESS_LENGTH));
					IF ACCESS_POSITION<=0 THEN
						SET ACCESS_CARD_NO=TEMP_ACCESS_CARD;
					ELSE
						SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_LENGTH,ACCESS_POSITION-1) INTO ACCESS_CARD_NO;
						SET TEMP_ACCESS_CARD=(SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_POSITION+1));
					END IF;
					IF EXISTS (SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO)) THEN
						SET EMP_SUCCESSFLAG = 1;
					END IF;
					IF ACCESS_POSITION<=0 THEN
						LEAVE  loop_label;
					END IF;
				END LOOP;
			END IF;
			IF EMP_SUCCESSFLAG!=1 THEN
				INSERT INTO EMPLOYEE_DETAILS (EMP_FIRST_NAME,EMP_LAST_NAME,ECN_ID,EMP_MOBILE,EMP_EMAIL,EMP_COMMENTS,ULD_ID) VALUES (FIRST_NAME,LAST_NAME,(SELECT ECN_ID
				FROM EXPENSE_CONFIGURATION WHERE ECN_DATA=DESIGNATION AND CGN_ID=35),MOBILE,EMAIL,COMMENTS,USERSTAMP_ID);
				SET TEMP_ACCESS_CARD_FLAG =CARD_NO;
				SET ACCESS_LENGTH_FLAG=1;
				loop_label:  LOOP
					SET ACCESS_POSITION_FLAG=(SELECT LOCATE(',', TEMP_ACCESS_CARD_FLAG,ACCESS_LENGTH_FLAG));
					IF ACCESS_POSITION_FLAG<=0 THEN
						SET ACCESS_CARD_FLAG=TEMP_ACCESS_CARD_FLAG;
					ELSE
						SELECT SUBSTRING(TEMP_ACCESS_CARD_FLAG,ACCESS_LENGTH_FLAG,ACCESS_POSITION_FLAG-1) INTO ACCESS_CARD_FLAG;
						SET TEMP_ACCESS_CARD_FLAG=(SELECT SUBSTRING(TEMP_ACCESS_CARD_FLAG,ACCESS_POSITION_FLAG+1));
					END IF;
					INSERT INTO EMPLOYEE_CARD_DETAILS (EMP_ID,UASD_ID) VALUES ((SELECT EMP_ID FROM EMPLOYEE_DETAILS ORDER BY EMP_ID DESC LIMIT 1),( SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_FLAG));
					SET EMP_SUCCESSFLAG=1;
					IF ACCESS_POSITION_FLAG<=0 THEN
						LEAVE  loop_label;
					END IF;
				END LOOP;    
			END IF;
		END IF;
	END IF;
	IF(CHECK_CARDNO IS NOT NULL)THEN
		SET @CHECK_CARDNO_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',CHECK_CARDNO,''));
		PREPARE CHECK_CARDNO_DROPQUERY_STMT FROM @CHECK_CARDNO_DROPQUERY;
		EXECUTE CHECK_CARDNO_DROPQUERY_STMT;
	END IF;
	COMMIT;
END;
