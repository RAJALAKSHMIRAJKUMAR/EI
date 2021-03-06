DROP PROCEDURE IF EXISTS SP_EXPENSE_DETAIL_DIGITAL_VOICE_INSERT;
CREATE PROCEDURE SP_EXPENSE_DETAIL_DIGITAL_VOICE_INSERT(IN SOURCESCHEMA  VARCHAR(40),IN DESTINATIONSCHEMA  VARCHAR(40),IN MIGUSERSTAMP VARCHAR(50))
BEGIN
    DECLARE DONE INT DEFAULT FALSE;
	DECLARE UNITNO INTEGER;
	DECLARE DIGITAL_UNITID INTEGER;
	DECLARE INVOICETO TEXT;
	DECLARE DIGITALVOICENO INTEGER(8);
	DECLARE DIGITALACCNO VARCHAR(11);
	DECLARE RECVER INTEGER;
	DECLARE COMMENTS TEXT;
	DECLARE DIGITAL_ECN_ID INTEGER;
	DECLARE DIGITAL_VOICE_USERSTAMP VARCHAR(50);
	DECLARE DIGITAL_TIMESTAMP TIMESTAMP;
	DECLARE START_TIME TIME;
	DECLARE END_TIME TIME;
	DECLARE DURATION TIME;
	DECLARE DIGITAL_MINID INTEGER;
    DECLARE DIGITAL_MAXID INTEGER;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;
    SET FOREIGN_KEY_CHECKS=0;	
	SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',MIGUSERSTAMP,'"'));
    PREPARE LOGINID FROM @LOGIN_ID;
    EXECUTE LOGINID;
	SET @DROP_EXPENSE_DETAIL_DIGITAL_VOICE=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_DIGITAL_VOICE'));
    PREPARE DROP_EXPENSE_DETAIL_DIGITAL_VOICE_STMT FROM @DROP_EXPENSE_DETAIL_DIGITAL_VOICE;
    EXECUTE DROP_EXPENSE_DETAIL_DIGITAL_VOICE_STMT;				
	SET @CREATE_EXPENSE_DETAIL_DIGITAL_VOICE=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_DIGITAL_VOICE(
	EDDV_ID	INTEGER NOT NULL AUTO_INCREMENT,
	UNIT_ID	INTEGER NOT NULL,
	ECN_ID	INTEGER NULL,
	EDDV_REC_VER INTEGER NOT NULL,	
	EDDV_DIGITAL_VOICE_NO INTEGER(8) NOT NULL,	
	EDDV_DIGITAL_ACCOUNT_NO	VARCHAR(11) NOT NULL,	
	EDDV_COMMENTS TEXT NULL,
	ULD_ID INTEGER(2) NOT NULL,	
	EDDV_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(EDDV_ID),
	FOREIGN KEY(UNIT_ID) REFERENCES ',DESTINATIONSCHEMA,'.UNIT (UNIT_ID),
	FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
	PREPARE CREATE_EXPENSE_DETAIL_DIGITAL_VOICE_STMT FROM @CREATE_EXPENSE_DETAIL_DIGITAL_VOICE;
    EXECUTE CREATE_EXPENSE_DETAIL_DIGITAL_VOICE_STMT;
	SET @DROP_EXPENSE_DETAIL_DIGITAL_VOICE=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE'));
    PREPARE DROP_EXPENSE_DETAIL_DIGITAL_VOICE_STMT FROM @DROP_EXPENSE_DETAIL_DIGITAL_VOICE;
    EXECUTE DROP_EXPENSE_DETAIL_DIGITAL_VOICE_STMT;
	SET @CREATE_TEMP_EXPENSE_DETAIL_DIGITAL_VOICE=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE(
	ID	INTEGER NOT NULL AUTO_INCREMENT,
	UNIT_NO	INTEGER NOT NULL,
	EDDV_INVOICE_TO	TEXT NULL,
	EDDV_DIGITAL_VOICE_NO INTEGER(8) NOT NULL,	
	EDDV_DIGITAL_ACCOUNT_NO	VARCHAR(11) NOT NULL,	
	EDDV_COMMENTS TEXT NULL,
	EDDV_USERSTAMP VARCHAR(50) NOT NULL,	
	EDDV_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(ID))'));
	PREPARE CREATE_TEMP_EXPENSE_DETAIL_DIGITAL_VOICE_STMT FROM @CREATE_TEMP_EXPENSE_DETAIL_DIGITAL_VOICE;
    EXECUTE CREATE_TEMP_EXPENSE_DETAIL_DIGITAL_VOICE_STMT;	
	SET @SELECT_DIGITAL_VOICE=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE(UNIT_NO,EDDV_INVOICE_TO,EDDV_DIGITAL_VOICE_NO,EDDV_DIGITAL_ACCOUNT_NO,EDDV_COMMENTS,EDDV_USERSTAMP,EDDV_TIMESTAMP)SELECT EXPD_UNIT_NO,EXPD_INVOICE_TO,EXPD_DIGITAL_VOICE_NO,EXPD_DIGITAL_ACCOUNT_NO,EXPD_COMMENTS,USERSTAMP,TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT WHERE EXPD_TYPE_OF_EXPENSE=',"'DIGITAL VOICE'"));	
	PREPARE SELECT_DIGITAL_VOICE_STMT FROM @SELECT_DIGITAL_VOICE;
    EXECUTE SELECT_DIGITAL_VOICE_STMT;	
	SET START_TIME=(SELECT CURTIME());
	SET @EDDV_MINID=(SELECT CONCAT('SELECT MIN(ID) INTO @MIN_ID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE'));
	PREPARE EDDV_MINID_STMT FROM @EDDV_MINID;
    EXECUTE EDDV_MINID_STMT;
	SET @EDDV_MAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAX_ID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE'));
	PREPARE EDDV_MAXID_STMT FROM @EDDV_MAXID;
    EXECUTE EDDV_MAXID_STMT;
    SET DIGITAL_MINID=@MIN_ID;
    SET DIGITAL_MAXID=@MAX_ID;
    WHILE(DIGITAL_MINID<=DIGITAL_MAXID)DO		
		SET @RECVER=1;	
        SET @EDDV_COMMENTS=NULL;
        SET @ECN_ID=NULL;		
		SET @SELECT_COMMENT=(SELECT CONCAT('SELECT EDDV_COMMENTS INTO @EDDV_COMMENTS FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID));
	    PREPARE SELECT_COMMENT_STMT FROM @SELECT_COMMENT;
        EXECUTE SELECT_COMMENT_STMT;
		SET COMMENTS=@EDDV_COMMENTS;		
		IF COMMENTS IS NULL THEN
		SET @EDDV_COMMENT=NULL;		
		ELSE
		SET @EDDV_COMMENT=COMMENTS;
		END IF;
		SET @SELECT_ECN_ID=(SELECT CONCAT('SELECT DISTINCT ECN_ID INTO @ECN_ID FROM ',DESTINATIONSCHEMA,'.EXPENSE_CONFIGURATION WHERE ECN_DATA=(SELECT EDDV_INVOICE_TO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,') AND CGN_ID=27'));
		PREPARE SELECT_ECN_ID_STMT FROM @SELECT_ECN_ID;
        EXECUTE SELECT_ECN_ID_STMT;
		SET DIGITAL_ECN_ID=@ECN_ID;
		IF(DIGITAL_ECN_ID IS NULL)THEN
		SET @D_ECN_ID=NULL;
		ELSE
		SET @D_ECN_ID=DIGITAL_ECN_ID;
		END IF;
		SET @EDDV_UNITID=NULL;
		SET @SELECT_UNITID=(SELECT CONCAT('SELECT UNIT_ID INTO @EDDV_UNITID FROM ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_DIGITAL_VOICE WHERE UNIT_ID=(SELECT UNIT_ID FROM ',DESTINATIONSCHEMA,'.UNIT WHERE UNIT_NO=(SELECT UNIT_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,'))'));
		PREPARE SELECT_UNITID_STMT FROM @SELECT_UNITID;
        EXECUTE SELECT_UNITID_STMT;
		SET DIGITAL_UNITID=@EDDV_UNITID;		
		IF DIGITAL_UNITID IS NOT NULL THEN	
            SET @REC_VER=NULL;		
			SET @SELECT_RECVER=(SELECT CONCAT('SELECT MAX(EDDV_REC_VER) INTO @REC_VER FROM ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_DIGITAL_VOICE WHERE UNIT_ID=(SELECT UNIT_ID FROM ',DESTINATIONSCHEMA,'.UNIT WHERE UNIT_NO=(SELECT UNIT_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,'))'));
			PREPARE SELECT_RECVER_STMT FROM @SELECT_RECVER;
            EXECUTE SELECT_RECVER_STMT;			
			SET @RECVER=@REC_VER;
			SET @INSERT_EXPENSE_DETAIL_DIGITAL_VOICE=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_DIGITAL_VOICE(UNIT_ID,ECN_ID,EDDV_REC_VER,EDDV_DIGITAL_VOICE_NO,EDDV_DIGITAL_ACCOUNT_NO,EDDV_COMMENTS,ULD_ID,EDDV_TIMESTAMP)VALUES
			((SELECT UNIT_ID FROM ',DESTINATIONSCHEMA,'.UNIT WHERE UNIT_NO=(SELECT UNIT_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,')),@D_ECN_ID,(@RECVER+1),(SELECT EDDV_DIGITAL_VOICE_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,'),(SELECT EDDV_DIGITAL_ACCOUNT_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,'),
			@EDDV_COMMENT,(SELECT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT EDDV_USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,')),(SELECT EDDV_TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,'))'));
			PREPARE INSERT_EXPENSE_DETAIL_DIGITAL_VOICE_STMT FROM @INSERT_EXPENSE_DETAIL_DIGITAL_VOICE;
            EXECUTE INSERT_EXPENSE_DETAIL_DIGITAL_VOICE_STMT;
		ELSE
			SET @INSERT_EXPENSE_DETAIL_DIGITAL_VOICE=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_DIGITAL_VOICE(UNIT_ID,ECN_ID,EDDV_REC_VER,EDDV_DIGITAL_VOICE_NO,EDDV_DIGITAL_ACCOUNT_NO,EDDV_COMMENTS,ULD_ID,EDDV_TIMESTAMP)VALUES
			((SELECT UNIT_ID FROM ',DESTINATIONSCHEMA,'.UNIT WHERE UNIT_NO=(SELECT UNIT_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,')),@D_ECN_ID,@RECVER,(SELECT EDDV_DIGITAL_VOICE_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,'),(SELECT EDDV_DIGITAL_ACCOUNT_NO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,'),
			@EDDV_COMMENT,(SELECT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT EDDV_USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,')),(SELECT EDDV_TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE WHERE ID=',DIGITAL_MINID,'))'));
			PREPARE INSERT_EXPENSE_DETAIL_DIGITAL_VOICE_STMT FROM @INSERT_EXPENSE_DETAIL_DIGITAL_VOICE;
            EXECUTE INSERT_EXPENSE_DETAIL_DIGITAL_VOICE_STMT;
		END IF;
		SET DIGITAL_MINID=DIGITAL_MINID+1;
		END WHILE;	
		SET END_TIME=(SELECT CURTIME());
		SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
		SET @COUNTSCDB_EDDV=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SCDB_EDDV FROM ',SOURCESCHEMA,'.BIZ_DETAIL_SCDB_FORMAT WHERE EXPD_TYPE_OF_EXPENSE=',"'DIGITAL VOICE'"));
		PREPARE COUNTSCDB_EDDV_STMT FROM @COUNTSCDB_EDDV;
        EXECUTE COUNTSCDB_EDDV_STMT;
		SET @COUNTSPLITTED_EDDV=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITTED_EDDV  FROM ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_DIGITAL_VOICE'));
		PREPARE COUNTSPLITTED_EDDV_STMT FROM @COUNTSPLITTED_EDDV;
        EXECUTE COUNTSPLITTED_EDDV_STMT;
		SET @REJECTION_COUNT=(@COUNT_SCDB_EDDV-@COUNT_SPLITTED_EDDV);
        SET FOREIGN_KEY_CHECKS=0;
		UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC = @COUNT_SCDB_EDDV WHERE PREASP_DATA='EXPENSE_DETAIL_DIGITAL_VOICE';	     	
		INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='EXPENSE_DETAIL_DIGITAL_VOICE'),@COUNT_SPLITTED_EDDV,
	   (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='EXPENSE_DETAIL_DIGITAL_VOICE'),
	   (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='BIZ DETAIL'),DURATION,@REJECTION_COUNT,@ULDID);
       SET FOREIGN_KEY_CHECKS=1;
       SET @DROP_EXPENSE_DETAIL_DIGITAL_VOICE=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_DETAIL_DIGITAL_VOICE'));
       PREPARE DROP_EXPENSE_DETAIL_DIGITAL_VOICE_STMT FROM @DROP_EXPENSE_DETAIL_DIGITAL_VOICE;
       EXECUTE DROP_EXPENSE_DETAIL_DIGITAL_VOICE_STMT;	   
	   SET FOREIGN_KEY_CHECKS=1;
	   COMMIT;
	   END;
       