DROP PROCEDURE IF EXISTS SP_LOGIN_UPDATE;
CREATE PROCEDURE SP_LOGIN_UPDATE(
LOGINID VARCHAR(40),
ROLENAME VARCHAR(15),
JOINDATE DATE,
USERSTAMP VARCHAR(50),
OUT TEMP_OUTTBL_UPD_MENU TEXT,
OUT TEMP_OUTTBL_UPD_LOGINID TEXT,
OUT UR_FLAG INTEGER)
BEGIN
DECLARE OLDROLENAME VARCHAR(15);
DECLARE MINID INTEGER;
DECLARE MAXID INTEGER;
DECLARE RECVER INTEGER;
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE TEMPTBL_MENU TEXT;
DECLARE TEMPTBL_LOGINID TEXT;
DECLARE TMP_MENU TEXT;
DECLARE TMP_LOGINID TEXT;
DECLARE EPID INT;
DECLARE EMAILLIST INT;
DECLARE EMAIL_MINID INTEGER;
DECLARE EMAIL_MAXID INTEGER;
DECLARE T_ELID INTEGER;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
    ROLLBACK;
    SET UR_FLAG=0; 
IF(TEMPTBL_MENU IS NOT NULL)THEN
  SET @DROP_TEMPTBL_MENU=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTBL_MENU));
  PREPARE DROP_TEMPTBL_MENU_STMT FROM @DROP_TEMPTBL_MENU;
  EXECUTE DROP_TEMPTBL_MENU_STMT;
END IF;
IF (TEMPTBL_LOGINID IS NOT NULL)THEN
			SET @DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTBL_LOGINID,''));
			PREPARE DROPQUERYSTMT FROM @DROPQUERY;
			EXECUTE DROPQUERYSTMT;
END IF;
END;
START TRANSACTION; 
SET AUTOCOMMIT=0;
SET UR_FLAG=0;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);
SET TMP_MENU=(SELECT CONCAT('TEMP_TBL_UPD_MENU',SYSDATE()));
SET TMP_MENU=(SELECT REPLACE(TMP_MENU,' ',''));
SET TMP_MENU=(SELECT REPLACE(TMP_MENU,'-',''));
SET TMP_MENU=(SELECT REPLACE(TMP_MENU,':',''));
SET TEMPTBL_MENU=(SELECT CONCAT(TMP_MENU,'_',USERSTAMP_ID));
SET TMP_LOGINID=(SELECT CONCAT('TEMP_TBL_UPD_LOGINID',SYSDATE()));
SET TMP_LOGINID=(SELECT REPLACE(TMP_LOGINID,' ',''));
SET TMP_LOGINID=(SELECT REPLACE(TMP_LOGINID,'-',''));
SET TMP_LOGINID=(SELECT REPLACE(TMP_LOGINID,':',''));
SET TEMPTBL_LOGINID=(SELECT CONCAT(TMP_LOGINID,'_',USERSTAMP_ID));
SET RECVER=(SELECT MAX(UA_REC_VER) FROM USER_ACCESS WHERE ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGINID));
SET OLDROLENAME=(SELECT R.RC_NAME FROM USER_ACCESS U,ROLE_CREATION R WHERE R.RC_ID=U.RC_ID AND U.ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGINID)AND U.UA_REC_VER=RECVER);
SET @CREATE_TEMPTBL_LOGINID=(SELECT CONCAT('CREATE TABLE ',TEMPTBL_LOGINID,'(ID INTEGER AUTO_INCREMENT PRIMARY KEY,ELID VARCHAR(40))'));
PREPARE CREATE_TEMPTBL_LOGINID_STMT FROM @CREATE_TEMPTBL_LOGINID;
EXECUTE CREATE_TEMPTBL_LOGINID_STMT;
SET @CREATE_TEMPTBL_MENU=(SELECT CONCAT('CREATE TABLE ',TEMPTBL_MENU,'(ID INTEGER PRIMARY KEY AUTO_INCREMENT,MP_ID INTEGER,EP_ID INTEGER)'));
PREPARE CREATE_TEMPTBL_MENU_STMT FROM @CREATE_TEMPTBL_MENU;
EXECUTE CREATE_TEMPTBL_MENU_STMT;
		SET TEMP_OUTTBL_UPD_MENU=TEMPTBL_MENU;
        SET TEMP_OUTTBL_UPD_LOGINID=TEMPTBL_LOGINID;
	IF (ROLENAME IS NOT NULL AND JOINDATE IS NOT NULL AND USERSTAMP IS NOT NULL)THEN
		UPDATE USER_ACCESS SET RC_ID=(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=ROLENAME),UA_JOIN_DATE=JOINDATE,UA_USERSTAMP=USERSTAMP WHERE ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGINID)AND UA_REC_VER=RECVER;
      SET UR_FLAG=1;
	END IF;
	IF (OLDROLENAME!=ROLENAME)THEN		
		SET @INSERT_TEMPTBL_LOGINID=(SELECT CONCAT('INSERT INTO ',TEMPTBL_LOGINID,'(ELID) SELECT EL_ID FROM EMAIL_LIST WHERE EL_EMAIL_ID=','"',LOGINID,'" AND  EP_ID IN(1,17,15,16,13,14,20,24)'));
		PREPARE INSERT_TEMPTBL_LOGINID_STMT FROM @INSERT_TEMPTBL_LOGINID;
		EXECUTE INSERT_TEMPTBL_LOGINID_STMT;
		SET @MIN_ID=NULL;
		SET @SELECT_MINID=(SELECT CONCAT('SELECT MIN(ID) INTO @MIN_ID FROM ',TEMPTBL_LOGINID));
		PREPARE SELECT_MINID_STMT FROM @SELECT_MINID;
		EXECUTE SELECT_MINID_STMT;
		SET EMAIL_MINID=@MIN_ID;
		SET @MAX_ID=NULL;
		SET @SELECT_MAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAX_ID FROM ',TEMPTBL_LOGINID));
		PREPARE SELECT_MAXID_STMT FROM @SELECT_MAXID;
		EXECUTE SELECT_MAXID_STMT;
		SET EMAIL_MAXID=@MAX_ID;
		WHILE EMAIL_MINID<=EMAIL_MAXID DO
			SET @SELECT_ELID=(SELECT CONCAT('SELECT ELID INTO @EID FROM ',TEMPTBL_LOGINID,' WHERE ID=',EMAIL_MINID));
			PREPARE SELECT_ELID_STMT FROM @SELECT_ELID;
			EXECUTE SELECT_ELID_STMT;
			SET T_ELID=@EID;
			INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,ULD_ID) VALUES(2,22,(SELECT CONCAT("EL_ID=",T_ELID,",EP_ID=",(SELECT EP_ID FROM EMAIL_LIST WHERE EL_ID=T_ELID),",EL_EMAIL_ID=",LOGINID,",ULD_ID=",(SELECT ULD_ID FROM EMAIL_LIST WHERE EL_ID=T_ELID),",EL_TIMESTAMP=",(SELECT EL_TIMESTAMP FROM EMAIL_LIST WHERE EL_ID=T_ELID))),USERSTAMP_ID);
			DELETE FROM EMAIL_LIST WHERE EL_ID=T_ELID;
			SET EMAIL_MINID=EMAIL_MINID+1;
		END WHILE;
		SET UR_FLAG=1;		 
	SET @INSERT_TEMPTBL_MENU=(SELECT CONCAT('INSERT INTO ',TEMPTBL_MENU,'(MP_ID,EP_ID) SELECT M.MP_ID,M.EP_ID FROM USER_MENU_DETAILS U,MENU_PROFILE M WHERE U.RC_ID=(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=','"',ROLENAME,'"',')AND U.MP_ID=M.MP_ID'));
	PREPARE INSERT_TEMPTBL_MENU_STMT FROM @INSERT_TEMPTBL_MENU;
  EXECUTE INSERT_TEMPTBL_MENU_STMT;
  SET @MIN_ID=NULL; 
  SET @SELECT_MINID=(SELECT CONCAT('SELECT MIN(ID) INTO @MIN_ID FROM ',TEMPTBL_MENU));
  PREPARE SELECT_MINID_STMT FROM @SELECT_MINID;
  EXECUTE SELECT_MINID_STMT;
	SET MINID=@MIN_ID;
  SET @MAX_ID=NULL;
  SET @SELECT_MAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAX_ID FROM ',TEMPTBL_MENU));
  PREPARE SELECT_MAXID_STMT FROM @SELECT_MAXID;
  EXECUTE SELECT_MAXID_STMT;
	SET MAXID=@MAX_ID;
	WHILE (MINID<=MAXID)DO 
    SET @T_EPID=NULL;
    SET @SELECT_EPID=(SELECT CONCAT('SELECT EP_ID INTO @T_EPID FROM ',TEMPTBL_MENU,' WHERE ID=',MINID,' AND EP_ID IS NOT NULL'));
    PREPARE SELECT_EPID_STMT FROM @SELECT_EPID;
    EXECUTE SELECT_EPID_STMT;
    SET EPID=(SELECT @T_EPID);
  		IF (EPID IS NOT NULL)THEN
       SET @SELECT_EMAIL_LIST=(SELECT CONCAT('SELECT COUNT(*) INTO @T_EMAILLIST FROM EMAIL_LIST WHERE EP_ID=(SELECT EP_ID FROM ',TEMPTBL_MENU,' WHERE ID=',MINID,')AND EL_EMAIL_ID=','"',LOGINID,'"'));
       PREPARE SELECT_EMAIL_LIST_STMT FROM @SELECT_EMAIL_LIST;
       EXECUTE SELECT_EMAIL_LIST_STMT;
       SET EMAILLIST=(SELECT @T_EMAILLIST);
	        IF (EMAILLIST=0)THEN 
      			SET @INSERT_EMAIL_LIST=(SELECT CONCAT('INSERT INTO EMAIL_LIST(EP_ID,EL_EMAIL_ID,ULD_ID)VALUES((SELECT EP_ID FROM ',TEMPTBL_MENU,' WHERE ID=',MINID,'),','"',LOGINID,'"',',',USERSTAMP_ID,')'));
            PREPARE INSERT_EMAIL_LIST_STMT FROM @INSERT_EMAIL_LIST;
            EXECUTE INSERT_EMAIL_LIST_STMT;
              SET UR_FLAG=1;
		      END IF;
		  END IF;
		SET MINID=MINID+1;
	END WHILE;  
	END IF;
END;
