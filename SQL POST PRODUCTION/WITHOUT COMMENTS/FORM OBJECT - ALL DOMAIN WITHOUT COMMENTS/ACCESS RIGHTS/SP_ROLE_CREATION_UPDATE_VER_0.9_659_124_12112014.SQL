DROP PROCEDURE IF EXISTS SP_ROLE_CREATION_UPDATE;
CREATE PROCEDURE SP_ROLE_CREATION_UPDATE(
CUSTOM_ROLE VARCHAR(15),
BASIC_ROLE TEXT,
MENUID TEXT,
FILEID TEXT,
USERSTAMP VARCHAR(50),
DB_NAME VARCHAR(20),
OUT RC_FLAG INTEGER,
OUT TEMPTABLEDROP TEXT
)
BEGIN
DECLARE MENU_LENGTH INTEGER;
DECLARE TEMP_MENU TEXT;
DECLARE MENU INTEGER;
DECLARE MENU_POSITION INTEGER;
DECLARE TEMP_FILE TEXT;
DECLARE FPID INTEGER;
DECLARE FILE_POSITION INTEGER;
DECLARE FILE_LOCATION INTEGER;
DECLARE FILE_LENGTH INTEGER;
DECLARE REMOVE_MP_ID TEXT ;
DECLARE GRANT_MP_ID TEXT ;
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE TEMP_INSERT_MENU TEXT;
DECLARE INSERT_MENU TEXT;
DECLARE TEMP_REMOVE_MENU TEXT;
DECLARE REMOVE_MENU TEXT;
DECLARE TEMP_INSERT_FILE TEXT;
DECLARE INSERT_FILE TEXT;
DECLARE TEMP_REMOVE_FILE TEXT;
DECLARE REMOVE_FILE TEXT;
DECLARE RM_COUNT INT;
DECLARE RM_MPID INT;
DECLARE IM_COUNT INT;
DECLARE IM_MPID INT;
DECLARE TEMP_DROP TEXT;
DECLARE GRANT_TEMP_PM_TABLE TEXT;
DECLARE GRANT_TEMP_PM_UNIQUE_TABLE TEXT;
DECLARE GRANT_TEMP_PM_SP_TABLE TEXT;
DECLARE MINDROPID INTEGER;
DECLARE MAXDROPID INTEGER;
DECLARE TABLENAME TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    ROLLBACK;
  SET RC_FLAG=0;
 IF TEMP_INSERT_MENU IS NOT NULL THEN
    SET @DROP_QUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_INSERT_MENU));
      PREPARE DROP_QUERY_STMT FROM @DROP_QUERY;
      EXECUTE DROP_QUERY_STMT;
END IF;
IF TEMP_REMOVE_MENU IS NOT NULL THEN
    SET @DROP_QUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_REMOVE_MENU));
      PREPARE DROP_QUERY_STMT FROM @DROP_QUERY;
      EXECUTE DROP_QUERY_STMT;
END IF;
IF TEMP_INSERT_FILE IS NOT NULL THEN
    SET @DROP_QUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_INSERT_FILE));
      PREPARE DROP_QUERY_STMT FROM @DROP_QUERY;
      EXECUTE DROP_QUERY_STMT;
END IF;
IF TEMP_REMOVE_FILE IS NOT NULL THEN
    SET @DROP_QUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_REMOVE_FILE));
      PREPARE DROP_QUERY_STMT FROM @DROP_QUERY;
      EXECUTE DROP_QUERY_STMT;
END IF;
IF GRANT_TEMP_PM_TABLE IS NOT NULL THEN
    SET @DROP_QUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',GRANT_TEMP_PM_TABLE));
      PREPARE DROP_QUERY_STMT FROM @DROP_QUERY;
      EXECUTE DROP_QUERY_STMT;
END IF;
IF GRANT_TEMP_PM_UNIQUE_TABLE IS NOT NULL THEN
    SET @DROP_QUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',GRANT_TEMP_PM_UNIQUE_TABLE));
      PREPARE DROP_QUERY_STMT FROM @DROP_QUERY;
      EXECUTE DROP_QUERY_STMT;
END IF;
IF GRANT_TEMP_PM_SP_TABLE IS NOT NULL THEN
    SET @DROP_QUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',GRANT_TEMP_PM_SP_TABLE));
      PREPARE DROP_QUERY_STMT FROM @DROP_QUERY;
      EXECUTE DROP_QUERY_STMT;
END IF;
IF TEMPTABLEDROP IS NOT NULL THEN
    SET @DROP_QUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTABLEDROP));
      PREPARE DROP_QUERY_STMT FROM @DROP_QUERY;
      EXECUTE DROP_QUERY_STMT;
END IF;
SET TEMPTABLEDROP=NULL;
END;
START TRANSACTION;
SET AUTOCOMMIT=0;
SET RC_FLAG=0;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);
SET TEMP_DROP=(SELECT CONCAT('TEMP_DROP_TABLE',SYSDATE()));
SET TEMP_DROP=(SELECT REPLACE(TEMP_DROP,' ',''));
SET TEMP_DROP=(SELECT REPLACE(TEMP_DROP,'-',''));
SET TEMP_DROP=(SELECT REPLACE(TEMP_DROP,':',''));
SET TEMP_DROP=(SELECT CONCAT(TEMP_DROP,'_',USERSTAMP_ID));
SET TEMPTABLEDROP=(SELECT CONCAT(TEMP_DROP,'_',USERSTAMP_ID));
SET INSERT_MENU=(SELECT CONCAT('TEMP_INSERT_MENU',SYSDATE()));
SET INSERT_MENU=(SELECT REPLACE(INSERT_MENU,' ',''));
SET INSERT_MENU=(SELECT REPLACE(INSERT_MENU,'-',''));
SET INSERT_MENU=(SELECT REPLACE(INSERT_MENU,':',''));
SET TEMP_INSERT_MENU=(SELECT CONCAT(INSERT_MENU,'_',USERSTAMP_ID));
SET REMOVE_MENU=(SELECT CONCAT('TEMP_REMOVE_MENU',SYSDATE()));
SET REMOVE_MENU=(SELECT REPLACE(REMOVE_MENU,' ',''));
SET REMOVE_MENU=(SELECT REPLACE(REMOVE_MENU,'-',''));
SET REMOVE_MENU=(SELECT REPLACE(REMOVE_MENU,':',''));
SET TEMP_REMOVE_MENU=(SELECT CONCAT(REMOVE_MENU,'_',USERSTAMP_ID));
SET INSERT_FILE=(SELECT CONCAT('TEMP_INSERT_FILE',SYSDATE()));
SET INSERT_FILE=(SELECT REPLACE(INSERT_FILE,' ',''));
SET INSERT_FILE=(SELECT REPLACE(INSERT_FILE,'-',''));
SET INSERT_FILE=(SELECT REPLACE(INSERT_FILE,':',''));
SET TEMP_INSERT_FILE=(SELECT CONCAT(INSERT_FILE,'_',USERSTAMP_ID));
SET REMOVE_FILE=(SELECT CONCAT('TEMP_REMOVE_FILE',SYSDATE()));
SET REMOVE_FILE=(SELECT REPLACE(REMOVE_FILE,' ',''));
SET REMOVE_FILE=(SELECT REPLACE(REMOVE_FILE,'-',''));
SET REMOVE_FILE=(SELECT REPLACE(REMOVE_FILE,':',''));
SET TEMP_REMOVE_FILE=(SELECT CONCAT(REMOVE_FILE,'_',USERSTAMP_ID));
SET @CREATE_QUERY=(SELECT CONCAT('CREATE TABLE ',TEMPTABLEDROP,'(ID INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,TABLENAME TEXT)'));
PREPARE CREATE_QUERY_STMT FROM @CREATE_QUERY;
EXECUTE CREATE_QUERY_STMT;
SET @CREATE_TEMP_INSERT_MENU=(SELECT CONCAT('CREATE TABLE ',TEMP_INSERT_MENU,'(ID INT NOT NULL AUTO_INCREMENT, RC_ID INTEGER,MP_ID INTEGER, PRIMARY KEY (ID))'));
PREPARE CREATE_TEMP_INSERT_MENU_STMT FROM @CREATE_TEMP_INSERT_MENU;
EXECUTE CREATE_TEMP_INSERT_MENU_STMT;
SET @CREATE_TEMP_REMOVE_MENU=(SELECT CONCAT('CREATE TABLE ',TEMP_REMOVE_MENU,'(ID INT NOT NULL AUTO_INCREMENT, RC_ID INTEGER,MP_ID INTEGER, PRIMARY KEY (ID))'));
PREPARE CREATE_TEMP_REMOVE_MENU_STMT FROM @CREATE_TEMP_REMOVE_MENU;
EXECUTE CREATE_TEMP_REMOVE_MENU_STMT;
SET @CREATE_TEMP_INSERT_FILE=(SELECT CONCAT('CREATE TABLE ',TEMP_INSERT_FILE,'(RC_ID INTEGER,FP_ID TEXT)'));
PREPARE CREATE_TEMP_INSERT_FILE_STMT FROM @CREATE_TEMP_INSERT_FILE;
EXECUTE CREATE_TEMP_INSERT_FILE_STMT;
SET @CREATE_TEMP_REMOVE_FILE=(SELECT CONCAT('CREATE TABLE ',TEMP_REMOVE_FILE,'(RC_ID INTEGER,FP_ID TEXT)'));
PREPARE CREATE_TEMP_REMOVE_FILE_STMT FROM @CREATE_TEMP_REMOVE_FILE;
EXECUTE CREATE_TEMP_REMOVE_FILE_STMT;
SET @INSERT_TEMP_QUERY=(SELECT CONCAT('INSERT INTO ',TEMPTABLEDROP,'(TABLENAME)VALUES(','"',TEMP_INSERT_MENU,'"',')',',(','"',TEMP_REMOVE_MENU,'"',')',',(','"',TEMP_INSERT_FILE,'"',')',',(','"',TEMP_REMOVE_FILE,'"',')'));
PREPARE INSERT_TEMP_QUERY_STMT FROM @INSERT_TEMP_QUERY;
EXECUTE INSERT_TEMP_QUERY_STMT;
IF (CUSTOM_ROLE IS NOT NULL AND BASIC_ROLE IS NOT NULL) THEN
  UPDATE ROLE_CREATION SET URC_ID=(SELECT URC_ID FROM USER_RIGHTS_CONFIGURATION WHERE URC_DATA=BASIC_ROLE)WHERE RC_NAME=CUSTOM_ROLE;
  SET RC_FLAG=1;
END IF;
IF (MENUID IS NOT NULL) THEN
  SET TEMP_MENU = MENUID;
  SET MENU_LENGTH = 1;
	loop_label : LOOP
		SET MENU_POSITION = (SELECT LOCATE(',', TEMP_MENU,MENU_LENGTH));
		IF MENU_POSITION<=0 THEN
			SET MENU = TEMP_MENU;
		ELSE
			SELECT SUBSTRING(TEMP_MENU,MENU_LENGTH,MENU_POSITION-1) INTO MENU;
			SET TEMP_MENU=(SELECT SUBSTRING(TEMP_MENU,MENU_POSITION+1));
		END IF;		
		IF NOT EXISTS(SELECT MP_ID FROM USER_MENU_DETAILS WHERE MP_ID=MENU AND RC_ID=(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=CUSTOM_ROLE))THEN
			INSERT INTO USER_MENU_DETAILS(MP_ID,RC_ID,ULD_ID)VALUES(MENU,(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=CUSTOM_ROLE),USERSTAMP_ID);
		  SET RC_FLAG=1;
		END IF;	
	SET @INSERT_TEMP_INSERT_MENU=(SELECT CONCAT('INSERT INTO ',TEMP_INSERT_MENU,'(RC_ID,MP_ID)VALUES((SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=','"',CUSTOM_ROLE,'"','),',MENU,')'));
    PREPARE INSERT_TEMP_INSERT_MENU_STMT FROM @INSERT_TEMP_INSERT_MENU;
    EXECUTE INSERT_TEMP_INSERT_MENU_STMT;
		IF MENU_POSITION<=0 THEN
			LEAVE  loop_label;
		END IF;
	END LOOP;
END IF;
 SET @DROP_USER=(SELECT CONCAT('DROP USER ',CUSTOM_ROLE));
 PREPARE DROP_USER_STMT FROM @DROP_USER;
 EXECUTE DROP_USER_STMT;
  SET @sql = CONCAT('CREATE USER ''',CUSTOM_ROLE,'''@','''%''',' IDENTIFIED BY ''',CUSTOM_ROLE,"'");
  PREPARE s1 FROM @sql;
  EXECUTE s1;
  DEALLOCATE PREPARE s1;
IF MENUID IS NOT NULL THEN
	CALL SP_PLATFORM_MGMT_DB_USER_RIGHTS_GRANT_REVOKE(DB_NAME, CUSTOM_ROLE, MENUID,'GRANT',USERSTAMP_ID,@GRANT_TEMP_PM_UNIQUE_TABLE_NAMES,@GRANT_TEMP_UNIQUE_TABLE_NAMES,@GRANT_TEMP_PM_UNIQUE_SP_NAMES);
	SET GRANT_TEMP_PM_TABLE=@GRANT_TEMP_UNIQUE_TABLE_NAMES;
	SET GRANT_TEMP_PM_UNIQUE_TABLE=@GRANT_TEMP_PM_UNIQUE_TABLE_NAMES;
	SET GRANT_TEMP_PM_SP_TABLE =@GRANT_TEMP_PM_UNIQUE_SP_NAMES;

	IF GRANT_TEMP_PM_TABLE IS NOT NULL THEN
		SET @INSERT_TEMP_QUERY=(SELECT CONCAT('INSERT INTO ',TEMPTABLEDROP,'(TABLENAME)VALUES(','"',GRANT_TEMP_PM_TABLE,'"',')'));
		PREPARE INSERT_TEMP_QUERY_STMT FROM @INSERT_TEMP_QUERY;
		EXECUTE INSERT_TEMP_QUERY_STMT;
	END IF;
	IF GRANT_TEMP_PM_UNIQUE_TABLE IS NOT NULL THEN
		SET @INSERT_TEMP_QUERY=(SELECT CONCAT('INSERT INTO ',TEMPTABLEDROP,'(TABLENAME)VALUES(','"',GRANT_TEMP_PM_UNIQUE_TABLE,'"',')'));
		PREPARE INSERT_TEMP_QUERY_STMT FROM @INSERT_TEMP_QUERY;
		EXECUTE INSERT_TEMP_QUERY_STMT;
	END IF;
	IF GRANT_TEMP_PM_SP_TABLE IS NOT NULL THEN
		SET @INSERT_TEMP_QUERY=(SELECT CONCAT('INSERT INTO ',TEMPTABLEDROP,'(TABLENAME)VALUES(','"',GRANT_TEMP_PM_SP_TABLE,'"',')'));
		PREPARE INSERT_TEMP_QUERY_STMT FROM @INSERT_TEMP_QUERY;
		EXECUTE INSERT_TEMP_QUERY_STMT;
	END IF;
END IF;
SET @INSERT_TEMP_REMOVE_MENU=(SELECT CONCAT('INSERT INTO ',TEMP_REMOVE_MENU,'(RC_ID, MP_ID)SELECT U.RC_ID,U.MP_ID FROM USER_MENU_DETAILS U LEFT JOIN ',TEMP_INSERT_MENU,' T ON U.MP_ID=T.MP_ID WHERE T.MP_ID IS NULL AND U.RC_ID=(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=','"',CUSTOM_ROLE,'"',')'));
PREPARE INSERT_TEMP_REMOVE_MENU_STMT FROM @INSERT_TEMP_REMOVE_MENU;
EXECUTE INSERT_TEMP_REMOVE_MENU_STMT;
SET @DELETE_MENU=(SELECT CONCAT ('DELETE FROM USER_MENU_DETAILS WHERE MP_ID IN (SELECT MP_ID FROM ',TEMP_REMOVE_MENU,')AND RC_ID IN(SELECT RC_ID FROM ',TEMP_REMOVE_MENU,')'));
PREPARE DELETE_MENU_STMT FROM @DELETE_MENU;
EXECUTE DELETE_MENU_STMT;
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
		IF NOT EXISTS(SELECT FP_ID FROM USER_FILE_DETAILS WHERE RC_ID=(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=CUSTOM_ROLE)AND FP_ID=FPID )THEN
		INSERT INTO USER_FILE_DETAILS(RC_ID,FP_ID,ULD_ID)VALUES((SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=CUSTOM_ROLE),FPID,USERSTAMP_ID);
		SET RC_FLAG=1;
    END IF;
	SET @INSERT_TEMP_INSERT_FILE=(SELECT CONCAT('INSERT INTO ',TEMP_INSERT_FILE,'(RC_ID,FP_ID)VALUES((SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=','"',CUSTOM_ROLE,'"','),',FPID,')'));
	PREPARE INSERT_TEMP_INSERT_FILE_STMT FROM @INSERT_TEMP_INSERT_FILE;
    EXECUTE INSERT_TEMP_INSERT_FILE_STMT;
		IF FILE_POSITION<=0 THEN
			LEAVE  loop_label;
		END IF;
	END LOOP;
	SET @INSERT_TEMP_REMOVE_FILE=(SELECT CONCAT('INSERT INTO ',TEMP_REMOVE_FILE,' SELECT U.RC_ID,U.FP_ID FROM USER_FILE_DETAILS U LEFT JOIN ',TEMP_INSERT_FILE,' T ON U.FP_ID=T.FP_ID WHERE T.FP_ID IS NULL AND U.RC_ID=(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=','"',CUSTOM_ROLE,'"',')'));
	PREPARE INSERT_TEMP_REMOVE_FILE_STMT FROM @INSERT_TEMP_REMOVE_FILE;
	EXECUTE INSERT_TEMP_REMOVE_FILE_STMT;
   	SET @DELETE_FILE=(SELECT CONCAT ('DELETE FROM USER_FILE_DETAILS WHERE FP_ID IN(SELECT FP_ID FROM ',TEMP_REMOVE_FILE,')AND RC_ID IN(SELECT RC_ID FROM ',TEMP_REMOVE_FILE,')'));
	PREPARE DELETE_FILE_STMT FROM @DELETE_FILE;
  EXECUTE DELETE_FILE_STMT;
  END IF;
  IF  FILEID IS NULL THEN
     DELETE FROM USER_FILE_DETAILS WHERE RC_ID=(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=CUSTOM_ROLE);
  END IF;   
END;
