-- VER0.9 STARTDATE:2014/11/01 ENDDATE:2014/11/12  ISSUE 659 CMT:124 DESC: IMPLEMENTED PLATFORM_MANAGEMENT SP DONE BY:DHIVYA
--version 0.8--startdate:25/09/2014 --enddate:25/09/2014 -->ISSUE:651,COMMENT:57 DESC:ADDED AUTOCOMMIT,REMOVED COMMIT,PASSED TEMP TABLE AS OUT PARAMETER,REMOVED SINGLE ROW DEL SP N ADDED INSERT N DEL QUERY FOR TICKLER HISTORY BY PUNI
--version 0.7 --sdate:23/06/2014 --edate:23/06/2014 TRACKER NO:817 COMMENT #139 DESC: DROPPING TEMP TABLE IF ROLLBACK OCCURS DONE BY:BHAVANI.R
-- version 0.6 startdate:15/05/2014 --enddate:15/05/2014--- issueno 817 commentno:65-->desc: CHANGED THE SP FOR DYNAMIC PURPOSE DONE BY: RAJA
-- version 0.5 startdate:28/02/2014 --enddate:28/02/2014--- issueno 754 commentno:36-->desc: APPLIED SUB_SP TO REPLACE USERSTAMP AS ID-SAFI
-- version 0.4 --sdate:27/02/2014 --edate:27/02/2014 --issue:754 --comment:22 --doneby:RL 
-- VER 0.3 ISSUE NO:659 COMMENT # STARTDATE:03/02/2014 ENDDATE:04/02/2014 DESC: CALLING SUB SP FOR updating GRANT PERMISSION FOR CUSTOM ROLE USER. DONE BY: MANIKANDAN.S
-- VER 0.2 ISSUE NO:659 COMMENT #29 STARTDATE:17/12/2013 ENDDATE:17/12/2013 DESC:CHANGED USER_FILE_DETAILS TABLE HEADER NAME AS PER TABLE MODIFICATION DONE BY:DHIVYA.A
-- VER 0.1 ISSUE NO:659 COMMENT #2 STARTDATE:13/12/2013 ENDDATE:13/12/2013 DESC:SP FOR ROLE CREATION UPDATE DONE BY:DHIVYA.A


DROP PROCEDURE IF EXISTS SP_ROLE_CREATION_INSERT;
CREATE PROCEDURE SP_ROLE_CREATION_INSERT(
CUSTOM_ROLE VARCHAR(15),
BASIC_ROLE TEXT,
MENUID TEXT,
FILEID TEXT,
USERSTAMP VARCHAR(50),
DB_NAME VARCHAR(20),
OUT SUCCESS_FLAG INTEGER)
BEGIN
-- VARAIBLE DECLARATION
DECLARE MENU_LENGTH INTEGER;
DECLARE TEMP_MENU TEXT;
DECLARE MENU INTEGER;
DECLARE MENU_POSITION INTEGER;
DECLARE TEMP_FILE TEXT;
DECLARE FPID INTEGER;
DECLARE FILE_POSITION INTEGER;
DECLARE FILE_LENGTH INTEGER;
DECLARE GRANT_MP_ID TEXT DEFAULT "'";
DECLARE USER_NAME VARCHAR(50);
DECLARE V_USER_COUNT  SMALLINT(1);
DECLARE V_STRLEN    INT DEFAULT 0;
DECLARE V_SUBSTRLEN INT DEFAULT 0;
DECLARE V_MENU_ID   INT;
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE TEMP_PM_TABLE TEXT;
DECLARE TEMP_PM_UNIQUE_TABLE TEXT;
DECLARE TEMP_PM_SP_TABLE TEXT;
-- QUERY FOR ROLLBACK COMMAND
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
	ROLLBACK; 
    SET SUCCESS_FLAG=0;
-- QUERY FOR DROPPING DYNAMIC TEMP TABLE
IF TEMP_PM_TABLE IS NOT NULL THEN
SET @DROP_TEMP_PM=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_PM_TABLE));
PREPARE DROP_TEMP_PM_STMT FROM @DROP_TEMP_PM;
EXECUTE DROP_TEMP_PM_STMT;
END IF;
IF TEMP_PM_UNIQUE_TABLE IS NOT NULL THEN
SET @DROP_TEMP_UNIQUE=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_PM_UNIQUE_TABLE));
PREPARE DROP_TEMP_UNIQUE_STMT FROM @DROP_TEMP_UNIQUE;
EXECUTE DROP_TEMP_UNIQUE_STMT;
END IF;
IF TEMP_PM_SP_TABLE IS NOT NULL THEN
SET @DROP_TEMP_PM_SP_TABLE=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_PM_SP_TABLE));
PREPARE DROP_TEMP_PM_SP_TABLE_STMT FROM @DROP_TEMP_PM_SP_TABLE;
EXECUTE DROP_TEMP_PM_SP_TABLE_STMT;
END IF;
END;
START TRANSACTION;
SET AUTOCOMMIT = 0;
-- SUB SP FOR CONVERTING USERSTAMP AS ULD_ID
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);
	IF CUSTOM_ROLE IS NOT NULL AND BASIC_ROLE IS NOT NULL THEN
      IF NOT EXISTS (SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME = CUSTOM_ROLE) THEN
      -- INSERT QUERY FOR ROLE_CREATION
        INSERT INTO ROLE_CREATION(URC_ID,RC_NAME,RC_USERSTAMP) VALUES ((SELECT URC_ID FROM USER_RIGHTS_CONFIGURATION WHERE URC_DATA=BASIC_ROLE),CUSTOM_ROLE,USERSTAMP);
              SET SUCCESS_FLAG=1;
      END IF;
		END IF;
IF MENUID IS NOT NULL THEN
  SET TEMP_MENU = MENUID;
  SET MENU_LENGTH = 1;
 loop_label : LOOP
		SET MENU_POSITION=(SELECT LOCATE(',', TEMP_MENU,MENU_LENGTH));
		IF MENU_POSITION<=0 THEN
			SET MENU=TEMP_MENU;
		ELSE
			SELECT SUBSTRING(TEMP_MENU,MENU_LENGTH,MENU_POSITION-1) INTO MENU;
			SET TEMP_MENU=(SELECT SUBSTRING(TEMP_MENU,MENU_POSITION+1));
		END IF;
		-- INSERT QUERY FOR USER_MENU_DETAILS
		INSERT INTO USER_MENU_DETAILS(MP_ID,RC_ID,ULD_ID)VALUES(MENU,(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=CUSTOM_ROLE),USERSTAMP_ID);
        SET SUCCESS_FLAG=1;
		IF MENU_POSITION<=0 THEN
			LEAVE  loop_label;
		END IF;
	END LOOP;
END IF;
IF FILEID IS NOT NULL THEN
	SET TEMP_FILE = FILEID;
	SET FILE_LENGTH=1;
	loop_label:  LOOP
		SET FILE_POSITION=(SELECT LOCATE(',', TEMP_FILE,FILE_LENGTH));
		IF FILE_POSITION<=0 THEN
			SET FPID=TEMP_FILE;
		ELSE
			SELECT SUBSTRING(TEMP_FILE,FILE_LENGTH,FILE_POSITION-1) INTO FPID;
			SET TEMP_FILE=(SELECT SUBSTRING(TEMP_FILE,FILE_POSITION+1));
		END IF;
		-- INSERT QUERY FOR USER_FILE_DETAILS
		INSERT INTO USER_FILE_DETAILS(RC_ID,FP_ID,ULD_ID)VALUES((SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=CUSTOM_ROLE),FPID,USERSTAMP_ID);
        SET SUCCESS_FLAG=1;
		IF FILE_POSITION<=0 THEN
			LEAVE  loop_label;
		END IF;
	END LOOP;
END IF; 
MAIN_LOOP:
  LOOP
    SET V_STRLEN = CHAR_LENGTH(MENUID);
    SET V_MENU_ID = SUBSTRING_INDEX(MENUID, ',', 1);   
    SET GRANT_MP_ID = CONCAT (GRANT_MP_ID,V_MENU_ID,''',''');
    SET V_SUBSTRLEN = CHAR_LENGTH(SUBSTRING_INDEX(MENUID, ',', 1)) + 2;
    SET MENUID = MID(MENUID, V_SUBSTRLEN, V_STRLEN);
    IF MENUID = '' THEN
      LEAVE MAIN_LOOP;
    END IF;    
  END LOOP MAIN_LOOP;
  SET GRANT_MP_ID = SUBSTRING(GRANT_MP_ID,1,CHAR_LENGTH(GRANT_MP_ID)-2);
      SET USER_NAME = CUSTOM_ROLE;
      SET @user_name = USER_NAME;
      select count(user) into V_USER_COUNT from mysql.user WHERE USER = @user_name;
      IF V_USER_COUNT = 0 THEN
      -- QUERY FOR CREATING NEW USER
      SET @sql = CONCAT('CREATE USER ''',USER_NAME,'''@','''%''',' IDENTIFIED BY ''',USER_NAME,"'");
       PREPARE s1 FROM @sql;
       EXECUTE s1;
       DEALLOCATE PREPARE s1;
       END IF;
       -- CALLING PF SP AND IT LL GIVE GRANT PERMISSION TO SP'S & TABLES FOR A PASSING MENUS
CALL SP_PLATFORM_MGMT_DB_USER_RIGHTS_GRANT_REVOKE(DB_NAME, USER_NAME, GRANT_MP_ID,'GRANT',USERSTAMP_ID,@TEMP_PM_UNIQUE_TABLE_NAMES,@TEMP_UNIQUE_TABLE_NAMES,@TEMP_PM_UNIQUE_SP_NAMES);
SET TEMP_PM_TABLE=@TEMP_UNIQUE_TABLE_NAMES;
SET TEMP_PM_UNIQUE_TABLE=@TEMP_PM_UNIQUE_TABLE_NAMES;
SET TEMP_PM_SP_TABLE=@TEMP_PM_UNIQUE_SP_NAMES;
-- DROP QUERY FOR A DYNAMIC TEMP TABLE
IF TEMP_PM_TABLE IS NOT NULL THEN
SET @DROP_TEMP_PM=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_PM_TABLE));
PREPARE DROP_TEMP_PM_STMT FROM @DROP_TEMP_PM;
EXECUTE DROP_TEMP_PM_STMT;
END IF;
IF TEMP_PM_UNIQUE_TABLE IS NOT NULL THEN
SET @DROP_TEMP_UNIQUE=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_PM_UNIQUE_TABLE));
PREPARE DROP_TEMP_UNIQUE_STMT FROM @DROP_TEMP_UNIQUE;
EXECUTE DROP_TEMP_UNIQUE_STMT;
END IF;
IF TEMP_PM_SP_TABLE IS NOT NULL THEN
SET @DROP_TEMP_PM_SP_TABLE=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_PM_SP_TABLE));
PREPARE DROP_TEMP_PM_SP_TABLE_STMT FROM @DROP_TEMP_PM_SP_TABLE;
EXECUTE DROP_TEMP_PM_SP_TABLE_STMT;
END IF;
COMMIT;
END;
