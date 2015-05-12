DROP PROCEDURE IF EXISTS SP_EXPENSE_DETAIL_STARHUB_INSERT;
CREATE PROCEDURE SP_EXPENSE_DETAIL_STARHUB_INSERT(IN SOURCESCHEMA  VARCHAR(40),IN DESTINATIONSCHEMA  VARCHAR(40),IN MIGUSERSTAMP VARCHAR(50))
BEGIN
    DECLARE DONE INT DEFAULT FALSE;
	DECLARE UNITNO INTEGER;
	DECLARE STAR_UNIT_ID INTEGER;
	DECLARE INVOICETO TEXT;
	DECLARE ACCOUNTNO VARCHAR(11);
	DECLARE APPLDATE DATE;
	DECLARE RECVER INTEGER;
	DECLARE STARTDATE DATE;
	DECLARE ENDDATE DATE;
	DECLARE INTERNET_STARTDATE DATE;
	DECLARE INTERNET_ENDDATE DATE;
	DECLARE SSID VARCHAR(25);
	DECLARE PWD VARCHAR(25);
	DECLARE CABLE_BOX_SERIAL_NO VARCHAR(50);
	DECLARE MODEM_SERIAL_NO VARCHAR(50);
	DECLARE BASIC_GROUP TEXT;
	DECLARE ADDTNL_CH TEXT;
	DECLARE COMMENTS TEXT;
	DECLARE STARHUB_USERSTAMP VARCHAR(50);
	DECLARE STARHUB_TIMESTAMP TIMESTAMP;
	DECLARE START_TIME TIME;
	DECLARE END_TIME TIME;
	DECLARE DURATION TIME;
	DECLARE STAR_MINID INTEGER;
	DECLARE STAR_MAXID INTEGER;
	DECLARE STAR_ECN_ID INTEGER;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;
	SET FOREIGN_KEY_CHECKS=0;
	SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',MIGUSERSTAMP,'"'));
    PREPARE LOGINID FROM @LOGIN_ID;
    EXECUTE LOGINID;
	SET @DROP_EXPENSE_DETAIL_STARHUB=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_STARHUB'));
    PREPARE DROP_EXPENSE_DETAIL_STARHUB_STMT FROM @DROP_EXPENSE_DETAIL_STARHUB;
    EXECUTE DROP_EXPENSE_DETAIL_STARHUB_STMT;
	SET @CREATE_EXPENSE_DETAIL_STARHUB=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_STARHUB(
	EDSH_ID	INTEGER NOT NULL AUTO_INCREMENT,
	UNIT_ID	INTEGER NOT NULL,
	ECN_ID INTEGER NULL,
	EDSH_REC_VER INTEGER NOT NULL,
	EDSH_ACCOUNT_NO	VARCHAR(11) NOT NULL,	
	EDSH_APPL_DATE DATE NULL,	
	EDSH_CABLE_START_DATE DATE NULL,
	EDSH_CABLE_END_DATE	DATE NULL,	
	EDSH_INTERNET_START_DATE DATE NULL,	
	EDSH_INTERNET_END_DATE DATE NULL,	
	EDSH_SSID VARCHAR(25) NULL,	
	EDSH_PWD VARCHAR(25) NULL,	
	EDSH_CABLE_BOX_SERIAL_NO VARCHAR(50) NULL,	
	EDSH_MODEM_SERIAL_NO VARCHAR(50) NULL,	
	EDSH_BASIC_GROUP TEXT NULL,	
	EDSH_ADDTNL_CH TEXT NULL,	
	EDSH_COMMENTS TEXT NULL,
	ULD_ID INTEGER(2) NOT NULL,	
	EDSH_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(EDSH_ID),
	FOREIGN KEY(UNIT_ID) REFERENCES ',DESTINATIONSCHEMA,'.UNIT (UNIT_ID),
	FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
	PREPARE CREATE_EXPENSE_DETAIL_STARHUB_STMT FROM @CREATE_EXPENSE_DETAIL_STARHUB;
    EXECUTE CREATE_EXPENSE_DETAIL_STARHUB_STMT;
	SET @DROP_TEMP_EXPENSE_DETAIL_STARHUB=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB'));
    PREPARE DROP_TEMP_EXPENSE_DETAIL_STARHUB_STMT FROM @DROP_TEMP_EXPENSE_DETAIL_STARHUB;
    EXECUTE DROP_TEMP_EXPENSE_DETAIL_STARHUB_STMT;
	SET @CREATE_TEMP_EXPENSE_DETAIL_STARHUB=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB(
	ID	INTEGER NOT NULL AUTO_INCREMENT,
	UNIT_NO	INTEGER NOT NULL,
	EDSH_INVOICE_TO TEXT NULL,
	EDSH_ACCOUNT_NO	VARCHAR(11) NOT NULL,	
	EDSH_APPL_DATE DATE NULL,	
	EDSH_CABLE_START_DATE DATE NULL,
	EDSH_CABLE_END_DATE	DATE NULL,	
	EDSH_INTERNET_START_DATE DATE NULL,	
	EDSH_INTERNET_END_DATE DATE NULL,	
	EDSH_SSID VARCHAR(25) NULL,	
	EDSH_PWD VARCHAR(25) NULL,	
	EDSH_CABLE_BOX_SERIAL_NO VARCHAR(50) NULL,	
	EDSH_MODEM_SERIAL_NO VARCHAR(50) NULL,	
	EDSH_BASIC_GROUP TEXT NULL,	
	EDSH_ADDTNL_CH TEXT NULL,	
	EDSH_COMMENTS TEXT NULL,
	EDSH_USERSTAMP VARCHAR(40) NOT NULL,	
	EDSH_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(ID))'));
	PREPARE CREATE_TEMP_EXPENSE_DETAIL_STARHUB_STMT FROM @CREATE_TEMP_EXPENSE_DETAIL_STARHUB;
    EXECUTE CREATE_TEMP_EXPENSE_DETAIL_STARHUB_STMT;	 
	SET @SELECT_STAR_HUB=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB(UNIT_NO,EDSH_INVOICE_TO,EDSH_ACCOUNT_NO,EDSH_APPL_DATE,EDSH_CABLE_START_DATE,EDSH_CABLE_END_DATE,EDSH_INTERNET_START_DATE,EDSH_INTERNET_END_DATE,EDSH_SSID,EDSH_PWD,EDSH_CABLE_BOX_SERIAL_NO,EDSH_MODEM_SERIAL_NO,EDSH_BASIC_GROUP,EDSH_ADDTNL_CH,EDSH_COMMENTS,EDSH_USERSTAMP,EDSH_TIMESTAMP) SELECT EXPD_UNIT_NO,EXPD_INVOICE_TO,EXPD_STAR_HUB_ACCOUNT_NO,EXPD_APPL_DATE,EXPD_CABLE_START_DATE,EXPD_CABLE_END_DATE,EXPD_INTERNET_START_DATE,EXPD_INTERNET_END_DATE,EXPD_SSID,EXPD_PWD,EXPD_CABLE_BOX_SERIAL_NO,EXPD_MODEM_SERIAL_NO,EXPD_BASIC_GROUP,EXPD_ADDTNL_CH,EXPD_COMMENTS,USERSTAMP,TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT WHERE EXPD_TYPE_OF_EXPENSE=',"'STAR HUB'"));	
	PREPARE SELECT_STAR_HUB_STMT FROM @SELECT_STAR_HUB;
    EXECUTE SELECT_STAR_HUB_STMT;	
	SET START_TIME=(SELECT CURTIME());
	SET @EDSH_MINID=(SELECT CONCAT('SELECT MIN(ID) INTO @MIN_ID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB'));
	PREPARE EDSH_MINID_STMT FROM @EDSH_MINID;
    EXECUTE EDSH_MINID_STMT;
	SET @EDSH_MAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAX_ID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB'));
	PREPARE EDSH_MAXID_STMT FROM @EDSH_MAXID;
    EXECUTE EDSH_MAXID_STMT;
    SET STAR_MINID=@MIN_ID;
    SET STAR_MAXID=@MAX_ID;
    WHILE(STAR_MINID<=STAR_MAXID)DO		
		SET @RECVER=1;	
       SET @UNITID=NULL;
       SET @ECN_ID=NULL;	   
		SET @SELECT_UNIT_ID=(SELECT CONCAT('SELECT UNIT_ID INTO @UNITID FROM ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_STARHUB WHERE UNIT_ID=(SELECT UNIT_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID,')'));
		PREPARE SELECT_UNIT_ID_STMT FROM @SELECT_UNIT_ID;
        EXECUTE SELECT_UNIT_ID_STMT;
		SET STAR_UNIT_ID=@UNITID;
		SET @SELECT_ECN_ID=(SELECT CONCAT('SELECT DISTINCT ECN_ID INTO @ECN_ID FROM ',DESTINATIONSCHEMA,'.EXPENSE_CONFIGURATION WHERE ECN_DATA=(SELECT EDSH_INVOICE_TO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID,') AND CGN_ID=27'));
		PREPARE SELECT_ECN_ID_STMT FROM @SELECT_ECN_ID;
        EXECUTE SELECT_ECN_ID_STMT;
		SET STAR_ECN_ID=@ECN_ID;
		IF(STAR_ECN_ID IS NULL)THEN
		SET @S_ECN_ID=NULL;
		ELSE
		SET @S_ECN_ID=STAR_ECN_ID;
		END IF;
		SET @EDSH_CABLE_START_DATE=NULL;
		SET @SELECT_CABLE_START_DATE=(SELECT CONCAT('SELECT EDSH_CABLE_START_DATE INTO @EDSH_CABLE_START_DATE FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_CABLE_START_DATE_STMT FROM @SELECT_CABLE_START_DATE;
        EXECUTE SELECT_CABLE_START_DATE_STMT;
		SET STARTDATE=@EDSH_CABLE_START_DATE;
        IF	STARTDATE IS NULL THEN
		SET @EDSH_CABLE_STARTDATE=NULL;
		ELSE
		SET @EDSH_CABLE_STARTDATE=STARTDATE;
		END IF;  
        SET @APPL_DATE=NULL;		
        SET @SELECT_APPL_DATE=(SELECT CONCAT('SELECT EDSH_APPL_DATE INTO @APPL_DATE FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_APPL_DATE_STMT FROM @SELECT_APPL_DATE;
        EXECUTE SELECT_APPL_DATE_STMT;
		SET APPLDATE=@APPL_DATE;
        IF	APPLDATE IS NULL THEN
		SET @APPL_DATE=NULL;
		ELSE
		SET @APPL_DATE=APPLDATE;
		END IF; 
        SET @CABLE_END_DATE=NULL;		
        SET @SELECT_CABLE_END_DATE=(SELECT CONCAT('SELECT EDSH_CABLE_END_DATE INTO @CABLE_END_DATE FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_CABLE_END_DATE_STMT FROM @SELECT_CABLE_END_DATE;
        EXECUTE SELECT_CABLE_END_DATE_STMT;
		SET ENDDATE=@CABLE_END_DATE;
        IF	ENDDATE IS NULL THEN
		SET @CABLE_ENDDATE=NULL;
		ELSE
		SET @CABLE_ENDDATE=ENDDATE;
		END IF;  
        SET @INTERNET_START_DATE=NULL;		
        SET @SELECT_INTERNET_START_DATE=(SELECT CONCAT('SELECT EDSH_INTERNET_START_DATE INTO @INTERNET_START_DATE FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_INTERNET_START_DATE_STMT FROM @SELECT_INTERNET_START_DATE;
        EXECUTE SELECT_INTERNET_START_DATE_STMT;
		SET INTERNET_STARTDATE=@INTERNET_START_DATE;
        IF	INTERNET_STARTDATE IS NULL THEN
		SET @INTERNETSTARTDATE=NULL;
		ELSE
		SET @INTERNETSTARTDATE=INTERNET_STARTDATE;
		END IF;
        SET @INTERNET_END_DATE=NULL;		
        SET @SELECT_INTERNET_END_DATE=(SELECT CONCAT('SELECT EDSH_INTERNET_END_DATE INTO @INTERNET_END_DATE FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_INTERNET_END_DATE_STMT FROM @SELECT_INTERNET_END_DATE;
        EXECUTE SELECT_INTERNET_END_DATE_STMT;
		SET INTERNET_ENDDATE=@INTERNET_END_DATE;
        IF	INTERNET_ENDDATE IS NULL THEN
		SET @INTERNETENDDATE=NULL;
		ELSE
		SET @INTERNETENDDATE=INTERNET_ENDDATE;
		END IF;
        SET @EDSH_SSID=NULL;		
        SET @SELECT_SSID=(SELECT CONCAT('SELECT EDSH_SSID INTO @EDSH_SSID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_SSID_STMT FROM @SELECT_SSID;
        EXECUTE SELECT_SSID_STMT;
		SET SSID=@EDSH_SSID;
        IF	SSID IS NULL THEN
		SET @EDSHSSID=NULL;
		ELSE
		SET @EDSHSSID=SSID;
		END IF;
        SET @EDSH_PWD=NULL;		
        SET @SELECT_PWD=(SELECT CONCAT('SELECT EDSH_PWD INTO @EDSH_PWD FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_PWD_STMT FROM @SELECT_PWD;
        EXECUTE SELECT_PWD_STMT;
		SET PWD=@EDSH_PWD;
        IF	PWD IS NULL THEN
		SET @EDSHPWD=NULL;
		ELSE
		SET @EDSHPWD=PWD;
		END IF;
		SET @EDSH_CABLE_BOX_SERIAL_NO=NULL;
        SET @SELECT_CABLE_BOX_SERIAL_NO=(SELECT CONCAT('SELECT EDSH_CABLE_BOX_SERIAL_NO INTO @EDSH_CABLE_BOX_SERIAL_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_CABLE_BOX_SERIAL_NO_STMT FROM @SELECT_CABLE_BOX_SERIAL_NO;
        EXECUTE SELECT_CABLE_BOX_SERIAL_NO_STMT;
		SET CABLE_BOX_SERIAL_NO=@EDSH_CABLE_BOX_SERIAL_NO;
        IF	CABLE_BOX_SERIAL_NO IS NULL THEN
		SET @EDSHCABLE_BOX_SERIAL_NO=NULL;
		ELSE
		SET @EDSHCABLE_BOX_SERIAL_NO=CABLE_BOX_SERIAL_NO;
		END IF;
        SET @EDSH_MODEM_SERIAL_NO=NULL;		
		SET @SELECT_MODEM_SERIAL_NO=(SELECT CONCAT('SELECT EDSH_MODEM_SERIAL_NO INTO @EDSH_MODEM_SERIAL_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_MODEM_SERIAL_NO_STMT FROM @SELECT_MODEM_SERIAL_NO;
        EXECUTE SELECT_MODEM_SERIAL_NO_STMT;
		SET MODEM_SERIAL_NO=@EDSH_MODEM_SERIAL_NO;
        IF	MODEM_SERIAL_NO IS NULL THEN
		SET @EDSHMODEM_SERIAL_NO=NULL;
		ELSE
		SET @EDSHMODEM_SERIAL_NO=MODEM_SERIAL_NO;
		END IF; 
		SET @EDSH_BASIC_GROUP=NULL;
		SET @SELECT_BASIC_GROUP=(SELECT CONCAT('SELECT EDSH_BASIC_GROUP INTO @EDSH_BASIC_GROUP FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_BASIC_GROUP_STMT FROM @SELECT_BASIC_GROUP;
        EXECUTE SELECT_BASIC_GROUP_STMT;
		SET BASIC_GROUP=@EDSH_BASIC_GROUP;
        IF	BASIC_GROUP IS NULL THEN
		SET @EDSHBASIC_GROUP=NULL;
		ELSE
		SET @EDSHBASIC_GROUP=BASIC_GROUP;
		END IF; 
		SET @EDSH_ADDTNL_CH=NULL;
		SET @SELECT_ADDTNL_CH=(SELECT CONCAT('SELECT EDSH_ADDTNL_CH INTO @EDSH_ADDTNL_CH FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_ADDTNL_CH_STMT FROM @SELECT_ADDTNL_CH;
        EXECUTE SELECT_ADDTNL_CH_STMT;
		SET ADDTNL_CH=@EDSH_ADDTNL_CH;
        IF	ADDTNL_CH IS NULL THEN
		SET @EDSHADDTNL_CH=NULL;
		ELSE
		SET @EDSHADDTNL_CH=ADDTNL_CH;
		END IF; 
		SET @EDSH_COMMENTS=NULL;
		SET @SELECT_COMMENTS=(SELECT CONCAT('SELECT EDSH_COMMENTS INTO @EDSH_COMMENTS FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID));
		PREPARE SELECT_COMMENTS_STMT FROM @SELECT_COMMENTS;
        EXECUTE SELECT_COMMENTS_STMT;
		SET COMMENTS=@EDSH_COMMENTS;
        IF	COMMENTS IS NULL THEN
		SET @EDSHCOMMENTS=NULL;
		ELSE
		SET @EDSHCOMMENTS=COMMENTS;
		END IF;        
		IF STAR_UNIT_ID IS NOT NULL THEN
		    SET @REC_VER=NULL;
			SET @SELECT_RECVER=(SELECT CONCAT('SELECT MAX(EDSH_REC_VER) INTO @REC_VER FROM ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_STARHUB WHERE UNIT_ID=(SELECT UNIT_ID FROM ',DESTINATIONSCHEMA,'.UNIT WHERE UNIT_NO=(SELECT UNIT_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID,'))'));
			PREPARE SELECT_RECVER_STMT FROM @SELECT_RECVER;
            EXECUTE SELECT_RECVER_STMT;
			SET @RECVER=@REC_VER;
			SET @INSERT_EXPENSE_DETAIL_STARHUB=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_STARHUB(UNIT_ID,ECN_ID,EDSH_REC_VER,EDSH_ACCOUNT_NO,EDSH_APPL_DATE,EDSH_CABLE_START_DATE,EDSH_CABLE_END_DATE,EDSH_INTERNET_START_DATE,EDSH_INTERNET_END_DATE,EDSH_SSID,EDSH_PWD,EDSH_CABLE_BOX_SERIAL_NO,EDSH_MODEM_SERIAL_NO,EDSH_BASIC_GROUP,EDSH_ADDTNL_CH,EDSH_COMMENTS,ULD_ID,EDSH_TIMESTAMP)VALUES
			((SELECT UNIT_ID FROM ',DESTINATIONSCHEMA,'.UNIT WHERE UNIT_NO=(SELECT UNIT_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID,')),@S_ECN_ID,(@RECVER+1),(SELECT EDSH_ACCOUNT_NO  FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID,'),@APPL_DATE,@EDSH_CABLE_STARTDATE,@CABLE_ENDDATE,@INTERNETSTARTDATE,@INTERNETENDDATE,@EDSHSSID,@EDSHPWD,@EDSHCABLE_BOX_SERIAL_NO,@EDSHMODEM_SERIAL_NO,@EDSHBASIC_GROUP,@EDSHADDTNL_CH,@EDSHCOMMENTS,(SELECT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT EDSH_USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID,')),(SELECT EDSH_TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID,'))'));
			PREPARE INSERT_EXPENSE_DETAIL_STARHUB_STMT FROM @INSERT_EXPENSE_DETAIL_STARHUB;
            EXECUTE INSERT_EXPENSE_DETAIL_STARHUB_STMT;
		ELSE
			SET @INSERT_EXPENSE_DETAIL_STARHUB=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_STARHUB(UNIT_ID,ECN_ID,EDSH_REC_VER,EDSH_ACCOUNT_NO,EDSH_APPL_DATE,EDSH_CABLE_START_DATE,EDSH_CABLE_END_DATE,EDSH_INTERNET_START_DATE,EDSH_INTERNET_END_DATE,EDSH_SSID,EDSH_PWD,EDSH_CABLE_BOX_SERIAL_NO,EDSH_MODEM_SERIAL_NO,EDSH_BASIC_GROUP,EDSH_ADDTNL_CH,EDSH_COMMENTS,ULD_ID,EDSH_TIMESTAMP)VALUES
			((SELECT UNIT_ID FROM ',DESTINATIONSCHEMA,'.UNIT WHERE UNIT_NO=(SELECT UNIT_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID,')),@S_ECN_ID,(@RECVER),(SELECT EDSH_ACCOUNT_NO  FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID,'),@APPL_DATE,@EDSH_CABLE_STARTDATE,@CABLE_ENDDATE,@INTERNETSTARTDATE,@INTERNETENDDATE,@EDSHSSID,@EDSHPWD,@EDSHCABLE_BOX_SERIAL_NO,@EDSHMODEM_SERIAL_NO,@EDSHBASIC_GROUP,@EDSHADDTNL_CH,@EDSHCOMMENTS,(SELECT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT EDSH_USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID,')),(SELECT EDSH_TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB WHERE ID=',STAR_MINID,'))'));
			PREPARE INSERT_EXPENSE_DETAIL_STARHUB_STMT FROM @INSERT_EXPENSE_DETAIL_STARHUB;
            EXECUTE INSERT_EXPENSE_DETAIL_STARHUB_STMT;
		END IF;
		SET STAR_MINID=STAR_MINID+1;
		END WHILE;		
		SET END_TIME=(SELECT CURTIME());
		SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
		SET @COUNTSCDB_EDSB=(SELECT CONCAT('SELECT COUNT(*)  INTO @COUNT_SCDB_EDSB FROM ',SOURCESCHEMA,'.BIZ_DETAIL_SCDB_FORMAT WHERE EXPD_TYPE_OF_EXPENSE=',"'STAR HUB'"));
		PREPARE COUNTSCDB_EDSB_STMT FROM @COUNTSCDB_EDSB;
        EXECUTE COUNTSCDB_EDSB_STMT;
		SET @COUNTSPLITTED_EDSB=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITTED_EDSB FROM ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_STARHUB'));
		PREPARE COUNTSPLITTED_EDSB_STMT FROM @COUNTSPLITTED_EDSB;
        EXECUTE COUNTSPLITTED_EDSB_STMT;
		SET @REJECTION_COUNT=(@COUNT_SCDB_EDSB-@COUNT_SPLITTED_EDSB);
        SET FOREIGN_KEY_CHECKS=0;
		UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC = @COUNT_SCDB_EDSB WHERE PREASP_DATA='EXPENSE_DETAIL_STARHUB';	    
		INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='EXPENSE_DETAIL_STARHUB'),@COUNT_SPLITTED_EDSB,
	   (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='EXPENSE_DETAIL_STARHUB'),
	   (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='BIZ DETAIL'),DURATION,@REJECTION_COUNT,@ULDID); 
       SET FOREIGN_KEY_CHECKS=1;
        SET @DROP_TEMP_EXPENSE_DETAIL_STARHUB=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_STARHUB'));
        PREPARE DROP_TEMP_EXPENSE_DETAIL_STARHUB_STMT FROM @DROP_TEMP_EXPENSE_DETAIL_STARHUB;
        EXECUTE DROP_TEMP_EXPENSE_DETAIL_STARHUB_STMT;	
		SET FOREIGN_KEY_CHECKS=1;
		COMMIT;
END;