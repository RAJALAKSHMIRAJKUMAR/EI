DROP PROCEDURE IF EXISTS SP_EMPDTL_UPDATE;
CREATE PROCEDURE SP_EMPDTL_UPDATE(
 IN EMPID INTEGER,
 IN FIRST_NAME CHAR(30),
 IN LAST_NAME CHAR(30),
 IN DESIGNATION TEXT,
 IN MOBILE  VARCHAR(10),      
 IN EMAIL VARCHAR(40),
 IN COMMENTS TEXT,
 IN USERSTAMP VARCHAR(50),
 IN CARD_NO_REMOVE TEXT,
 IN ACCESS_CARD TEXT,
 OUT EMPDTL_FLAG TEXT)
BEGIN
	DECLARE ACCESS_CARD_NO INTEGER(7);
	DECLARE ACCESS_CARD_NO_REMOVE INTEGER(7);
	DECLARE TEMP_CARD_NO INTEGER(7);
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE ECDID INTEGER;
	DECLARE UASDID INTEGER;
	DECLARE ECNID INTEGER;
	DECLARE OLDFNAME CHAR(30);
	DECLARE OLDLNAME CHAR(30);
	DECLARE OLDECNID INTEGER;
	DECLARE OLDMOBILE  VARCHAR(10);      
	DECLARE OLDEMAIL VARCHAR(40);
	DECLARE OLDCOMMENTS TEXT;
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
	SET @TEMP_ACCESS_CARDNO = ACCESS_CARD;
	SET @TEMP_CARD_NO = ACCESS_CARD;
	SET @TEMP_REMOVE_CARDNO = CARD_NO_REMOVE;
	SET AUTOCOMMIT = 0;
	START TRANSACTION;
	SET EMPDTL_FLAG = '';
	SET ACTIVECARDCOUNT = 0;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID =(SELECT @ULDID);
	IF CARD_NO_REMOVE = '' THEN
		SET CARD_NO_REMOVE=NULL;
	END IF;
	IF ACCESS_CARD = '' THEN
		SET ACCESS_CARD=NULL;
	END IF;
	IF COMMENTS = '' THEN
		SET COMMENTS=NULL;
	END IF;
	IF EMAIL = '' THEN
		SET EMAIL = NULL;
	END IF;
	SET SUCCESS_ECNDATA =  (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 571);
	SET ECNID = (SELECT ECN_ID FROM EXPENSE_CONFIGURATION WHERE ECN_DATA=DESIGNATION AND CGN_ID=35);
	SET OLDFNAME = (SELECT EMP_FIRST_NAME FROM EMPLOYEE_DETAILS WHERE EMP_ID = EMPID);
	SET OLDLNAME  = (SELECT EMP_LAST_NAME FROM EMPLOYEE_DETAILS WHERE EMP_ID = EMPID);
	SET OLDECNID = (SELECT ECN_ID FROM EMPLOYEE_DETAILS WHERE EMP_ID = EMPID);
	SET OLDMOBILE  = (SELECT EMP_MOBILE FROM EMPLOYEE_DETAILS WHERE EMP_ID = EMPID); 
	SET OLDEMAIL  = (SELECT EMP_EMAIL FROM EMPLOYEE_DETAILS WHERE EMP_ID = EMPID);
	IF OLDEMAIL IS NULL THEN
		SET OLDEMAIL='NULL';
	END IF;
	IF EMAIL IS NULL THEN
		SET EMAIL='NULL';
	END IF;
	SET OLDCOMMENTS = (SELECT EMP_COMMENTS FROM EMPLOYEE_DETAILS WHERE EMP_ID = EMPID);
	IF OLDCOMMENTS IS NULL THEN
		SET OLDCOMMENTS='NULL';
	END IF;
	IF COMMENTS IS NULL THEN
		SET COMMENTS='NULL';
	END IF;
	SET SYSDATEANDTIME = (SELECT SYSDATE());
	SET SYSDATEANDTIME = (SELECT REPLACE(SYSDATEANDTIME,' ',''));
	SET SYSDATEANDTIME = (SELECT REPLACE(SYSDATEANDTIME,'-',''));
	SET SYSDATEANDTIME = (SELECT REPLACE(SYSDATEANDTIME,':',''));
	SET SYSDATEANDULDID = (SELECT CONCAT(SYSDATEANDTIME,'_',USERSTAMP_ID));	
	SET CHECK_CARDNO = (SELECT CONCAT('TEMP_CHECK_EMP_UPDATE_CARDNO','_',SYSDATEANDULDID));
	IF(ACCESS_CARD IS NOT NULL) THEN
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
				SET EMPDTL_FLAG = (SELECT CONCAT(EMPDTL_FLAG,',',ACTIVECARDNO));
			END IF;
			SET MINID = MINID+1;
			SET @ACTIVE_CARD_NO = NULL;
		END WHILE;
		SET LOCATION=(SELECT LOCATE(',', EMPDTL_FLAG,EMPLOYEE_LENGTH));
		SET EMPDTL_FLAG=(SELECT SUBSTRING(EMPDTL_FLAG,LOCATION+2));
		SET EMPDTL_FLAG = (SELECT REPLACE(SUCCESS_ECNDATA,'[CARD NO]',EMPDTL_FLAG));
	END IF;
	IF((ACTIVECARDCOUNT = 0) AND (FIRST_NAME IS NULL OR LAST_NAME IS NULL OR DESIGNATION IS NULL OR MOBILE IS NULL OR USERSTAMP_ID IS NULL )) THEN
		SET EMPDTL_FLAG = 0;
	END IF;
	IF((ACTIVECARDCOUNT = 0) AND (FIRST_NAME IS NOT NULL AND LAST_NAME IS NOT NULL AND DESIGNATION IS NOT NULL AND MOBILE IS NOT NULL AND USERSTAMP_ID IS NOT NULL )) THEN
		IF(CARD_NO_REMOVE IS NULL AND ACCESS_CARD IS NULL) THEN
			IF((OLDFNAME!=FIRST_NAME) OR (OLDLNAME!=LAST_NAME) OR (OLDECNID!=ECNID) OR (OLDMOBILE!=MOBILE) OR (OLDEMAIL!=EMAIL) OR (OLDCOMMENTS!=COMMENTS))THEN
				IF(COMMENTS='NULL')THEN
					SET COMMENTS=NULL;
				END IF;
				IF(EMAIL = 'NULL')THEN
					SET EMAIL = NULL;
				END IF;
				UPDATE EMPLOYEE_DETAILS SET EMP_FIRST_NAME=FIRST_NAME,EMP_LAST_NAME=LAST_NAME,ECN_ID=ECNID,EMP_MOBILE=MOBILE,EMP_EMAIL=EMAIL,EMP_COMMENTS=COMMENTS,ULD_ID=USERSTAMP_ID WHERE EMP_ID=EMPID ;
				SET EMPDTL_FLAG=1;
			END IF;
		END IF;
		IF ACCESS_CARD IS NOT NULL AND CARD_NO_REMOVE IS NULL THEN
			loop_label:  LOOP
				CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_ACCESS_CARDNO,@VALUE,@REMAINING_STRING);
				SELECT @VALUE INTO ACCESS_CARD_NO;
				SELECT @REMAINING_STRING INTO @TEMP_ACCESS_CARDNO;
				IF NOT EXISTS(SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO))THEN
					INSERT INTO EMPLOYEE_CARD_DETAILS (EMP_ID,UASD_ID) VALUES (EMPID,(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO));
					SET EMPDTL_FLAG=1;
				END IF;
				IF @TEMP_ACCESS_CARDNO IS NULL THEN
					LEAVE  loop_label;
				END IF;
			END LOOP;
			IF((OLDFNAME!=FIRST_NAME) OR (OLDLNAME!=LAST_NAME) OR (OLDECNID!=ECNID) OR (OLDMOBILE!=MOBILE) OR (OLDEMAIL!=EMAIL) OR (OLDCOMMENTS!=COMMENTS))THEN
				IF(COMMENTS='NULL')THEN
					SET COMMENTS=NULL;
				END IF;
				IF(EMAIL = 'NULL')THEN
					SET EMAIL = NULL;
				END IF;
				UPDATE EMPLOYEE_DETAILS SET EMP_FIRST_NAME=FIRST_NAME,EMP_LAST_NAME=LAST_NAME,ECN_ID=ECNID,EMP_MOBILE=MOBILE,EMP_EMAIL=EMAIL,EMP_COMMENTS=COMMENTS,ULD_ID=USERSTAMP_ID WHERE EMP_ID=EMPID ;
				SET EMPDTL_FLAG=1;
			END IF;
		END IF;
		IF CARD_NO_REMOVE IS NOT NULL AND ACCESS_CARD IS NULL THEN
			loop_label:  LOOP
				CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_REMOVE_CARDNO,@VALUE,@REMAINING_STRING);
				SELECT @VALUE INTO ACCESS_CARD_NO_REMOVE;
				SELECT @REMAINING_STRING INTO @TEMP_REMOVE_CARDNO;
				SET UASDID = (SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO_REMOVE));
				IF (UASDID IS NOT NULL)THEN
					SET ECDID = (SELECT ECD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID = UASDID);
					CALL SP_SINGLE_TABLE_ROW_DELETION(40,ECDID,USERSTAMP,@FLAG);
					SET EMPDTL_FLAG=1;
				END IF; 
				IF @TEMP_REMOVE_CARDNO IS NULL THEN
					LEAVE  loop_label;
				END IF;
			END LOOP;	
			IF((OLDFNAME!=FIRST_NAME) OR (OLDLNAME!=LAST_NAME) OR (OLDECNID!=ECNID) OR (OLDMOBILE!=MOBILE) OR (OLDEMAIL!=EMAIL) OR (OLDCOMMENTS!=COMMENTS))THEN
				IF(COMMENTS='NULL')THEN
					SET COMMENTS=NULL;
				END IF;
				IF(EMAIL = 'NULL')THEN
					SET EMAIL = NULL;
				END IF;
				UPDATE EMPLOYEE_DETAILS SET EMP_FIRST_NAME=FIRST_NAME,EMP_LAST_NAME=LAST_NAME,ECN_ID=ECNID,EMP_MOBILE=MOBILE,EMP_EMAIL=EMAIL,EMP_COMMENTS=COMMENTS,ULD_ID=USERSTAMP_ID WHERE EMP_ID=EMPID ;
				SET EMPDTL_FLAG=1;
			END IF;
		END IF;	
		IF ACCESS_CARD IS NOT NULL AND CARD_NO_REMOVE IS NOT NULL THEN
			loop_label:  LOOP
				CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_ACCESS_CARDNO,@VALUE,@REMAINING_STRING);
				SELECT @VALUE INTO ACCESS_CARD_NO;
				SELECT @REMAINING_STRING INTO @TEMP_ACCESS_CARDNO;
				IF NOT EXISTS(SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO))THEN
					INSERT INTO EMPLOYEE_CARD_DETAILS (EMP_ID,UASD_ID) VALUES ( EMPID,( SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO));
					SET EMPDTL_FLAG=1;
				END IF; 
				IF @TEMP_ACCESS_CARDNO IS NULL THEN
					LEAVE  loop_label;
				END IF;
			END LOOP;
			loop_label:  LOOP
				CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_REMOVE_CARDNO,@VALUE,@REMAINING_STRING);
				SELECT @VALUE INTO ACCESS_CARD_NO_REMOVE;
				SELECT @REMAINING_STRING INTO @TEMP_REMOVE_CARDNO;
				SET UASDID = (SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO_REMOVE));
				IF (UASDID IS NOT NULL)THEN
					SET ECDID = (SELECT ECD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID = UASDID);
					CALL SP_SINGLE_TABLE_ROW_DELETION(40,ECDID,USERSTAMP,@FLAG);
					SET EMPDTL_FLAG=1;
				END IF; 	
				IF @TEMP_REMOVE_CARDNO IS NULL THEN
					LEAVE  loop_label;
				END IF;
			END LOOP;	
			IF((OLDFNAME!=FIRST_NAME) OR (OLDLNAME!=LAST_NAME) OR (OLDECNID!=ECNID) OR (OLDMOBILE!=MOBILE) OR (OLDEMAIL!=EMAIL) OR (OLDCOMMENTS!=COMMENTS))THEN
				IF(COMMENTS='NULL')THEN
					SET COMMENTS=NULL;
				END IF;
				IF(EMAIL = 'NULL')THEN
					SET EMAIL = NULL;
				END IF;
				UPDATE EMPLOYEE_DETAILS SET EMP_FIRST_NAME=FIRST_NAME,EMP_LAST_NAME=LAST_NAME,ECN_ID=ECNID,EMP_MOBILE=MOBILE,EMP_EMAIL=EMAIL,EMP_COMMENTS=COMMENTS,ULD_ID=USERSTAMP_ID WHERE EMP_ID=EMPID ;
				SET EMPDTL_FLAG=1;
			END IF;
		END IF;
		CALL SP_EMPLOYEE_DETAILS_ULD_TS_MAXTIMES(EMPID,USERSTAMP_ID);
	END IF;
	IF(CHECK_CARDNO IS NOT NULL)THEN
		SET @CHECK_CARDNO_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',CHECK_CARDNO,''));
		PREPARE CHECK_CARDNO_DROPQUERY_STMT FROM @CHECK_CARDNO_DROPQUERY;
		EXECUTE CHECK_CARDNO_DROPQUERY_STMT;
	END IF;
COMMIT;
END;
