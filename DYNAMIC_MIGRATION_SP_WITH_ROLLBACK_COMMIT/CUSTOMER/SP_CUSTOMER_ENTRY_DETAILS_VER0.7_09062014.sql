-- version:0.7 -- sdate:09/06/2014 -- edate:09/06/2014 -- issue:566 -- COMMENT NO:12 --desc:IMPLEMENTED ROLL BACK AND COMMIT --doneby:DHIVYA.A
-- ver 0.6 sdate:21/03/2014 edate:24/03/2014 issue no:765 desc:changed customer_entry_details table dynamically done by:DHIVYA
-- version:0.5 -- sdate:17/03/2014 -- edate:17/03/2014 -- issue:765 --desc:droped temp table --doneby:RL
--version:0.4--sdate:20/02/2014 --edate:20/02/2014 --issue:750 -desc:added preaudit and post audit queries done by:dhivya
--VER 0.3 STARTDATE:29/01/2014 ENDDATE:29/01/2014 ISSUE NO:594 COMMENT :#70 DESC:CUSTOMER_ENTRY_DETAILS TABLE S UPDATED AS PER STIME AND ETIME DATATYPE UPDATION DONE BY:DHIVYA.A
--VER 0.2 STARTDATE:21/01/2014 ENDDATE:22/01/2014 ISSUE NO:594 COMMENT :#50 DESC:ALL UPDATION DONE IN THE SPLITTED TABLE ITSELF NOT IN THE CUSTOMER SCDB FORMAT TABLE DONE BY:DHIVYA


--TEMPORARY SP FOR CUSTOMER_ENTRY_DETAILS TABLE
DROP PROCEDURE IF EXISTS SP_TEMP_CUSTOMER_ENTRY;
CREATE PROCEDURE SP_TEMP_CUSTOMER_ENTRY(IN SOURCESCHEMA VARCHAR(50),DESTINATIONSCHEMA VARCHAR(50))
BEGIN
DECLARE MAX_CUSTOMER INT;
DECLARE MIN_CUSTOMER INT;
DECLARE REC_VER INT;
DECLARE RE INT;
DECLARE MAX_CED_ID INT;
DECLARE MIN_CED_ID INT;
DECLARE STARTDATE DATE;
DECLARE ENDDATE DATE;
DECLARE PRETERMINATEDATE DATE;
DECLARE ENTRY_REC_VER INTEGER;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
SET @SSCHEMA=SOURCESCHEMA;
SET @DSCHEMA=DESTINATIONSCHEMA;

SET @MAX_CUSTOMER_INSERT =(SELECT CONCAT('SELECT MAX(CC_CUST_ID)INTO @ENTRY_MAX_ID FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT'));
PREPARE MAXCUSTOMERSTMT FROM @MAX_CUSTOMER_INSERT;
EXECUTE MAXCUSTOMERSTMT;
SET MAX_CUSTOMER=@ENTRY_MAX_ID;

SET @MIN_CUSTOMER_INSERT =(SELECT CONCAT('SELECT MIN(CC_CUST_ID) INTO @ENTRY_MIN_ID FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT'));
PREPARE MINCUSTOMERSTMT FROM @MIN_CUSTOMER_INSERT;
EXECUTE MINCUSTOMERSTMT;
SET MIN_CUSTOMER=@ENTRY_MIN_ID ;
SET RE=1;

CALL SP_TEMP_CUSTOMER_SCDB_FORMAT(@SSCHEMA,@DSCHEMA);

SET @DROPTEMPENTRY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS'));
PREPARE DROPTEMPENTRYSTMT FROM @DROPTEMPENTRY;
EXECUTE DROPTEMPENTRYSTMT;
--create query for temp customer entry details
SET @CREATETEMPENTRY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS
(CED_ID INTEGER NOT NULL AUTO_INCREMENT,
CUSTOMER_ID INTEGER NOT NULL,
UNIT_ID INTEGER NOT NULL,
UASD_ID INTEGER NOT NULL,
CED_REC_VER INTEGER NOT NULL,
CED_STARTDATE DATE NOT NULL,
CED_ENDDATE DATE NOT NULL,
CED_PRETERMINATE_DATE DATE NULL,
CED_SD_STIME INTEGER NOT NULL,
CED_SD_ETIME INTEGER NOT NULL,
CED_ED_STIME INTEGER NOT NULL,
CED_ED_ETIME INTEGER NOT NULL,
CED_LEASE_PERIOD VARCHAR(30) NULL,
CED_QUARTERS DECIMAL(5,2) NULL,
CED_EXTENSION CHAR(1) NULL,
CED_RECHECKIN CHAR(1)NULL,
CED_PRETERMINATE CHAR(1) NULL,    
CED_PROCESSING_WAIVED CHAR(1) NULL,
CED_PRORATED CHAR(1) NULL,
CED_NOTICE_PERIOD TINYINT(1) NULL,    
CED_NOTICE_START_DATE DATE NULL,    
CED_CANCEL_DATE    DATE NULL,
CED_COMMENTS TEXT NULL,
CED_USERSTAMP VARCHAR(50) NOT NULL,    
CED_TIMESTAMP TIMESTAMP NOT NULL,
PRIMARY KEY(CED_ID))ENGINE=MYISAM'));
PREPARE CREATETEMPENTRYSTMT FROM @CREATETEMPENTRY;
EXECUTE CREATETEMPENTRYSTMT;


WHILE MIN_CUSTOMER<= MAX_CUSTOMER DO
-- insert query for temp customer entry details
SET @INSERT_TEMP_ENTRY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS(CUSTOMER_ID,UNIT_ID,UASD_ID,CED_REC_VER,CED_STARTDATE,CED_ENDDATE,CED_PRETERMINATE_DATE, CED_SD_STIME, CED_SD_ETIME, CED_ED_STIME, CED_ED_ETIME,CED_LEASE_PERIOD,
		CED_QUARTERS,CED_EXTENSION,CED_PRETERMINATE,CED_NOTICE_PERIOD,CED_NOTICE_START_DATE,CED_CANCEL_DATE,CED_PROCESSING_WAIVED, CED_USERSTAMP)
		SELECT C2.CC_CUST_ID,U.UNIT_ID,U2.UASD_ID,C2.CC_REC_VER,C2.CC_STARTDATE,C2.CC_ENDDATE,C2.CC_PRE_TERMINATE_DATE,19, 20, 7,
		8,C2.CC_LEASE_PERIOD,C2.CC_QUARTERS,C2.CC_EXTENSION,C2.CC_PRETERMINATE,C2.CC_NOTICE_PERIOD,
		C2.CC_NOTICE_START_DATE,C2.CC_CANCEL_DATE,C2.CC_PROCESSING_WAIVED,C2.USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT C2,',DESTINATIONSCHEMA,'.UNIT_ACCESS_STAMP_DETAILS U2,',DESTINATIONSCHEMA,'.UNIT U,',DESTINATIONSCHEMA,'.UNIT_ROOM_TYPE_DETAILS URTD WHERE CC_GUEST_CARD_NO IS NULL
		AND U.UNIT_ID=U2.UNIT_ID AND URTD.URTD_ID=U2.URTD_ID AND U.UNIT_NO=C2.CC_UNIT_NO AND C2.CC_ROOMTYPE=URTD.URTD_ROOM_TYPE AND C2.CC_CUST_ID=',MIN_CUSTOMER,' ORDER BY C2.CC_REC_VER'));
		PREPARE INSERT_TEMP_ENTRY_STMT FROM @INSERT_TEMP_ENTRY;
		EXECUTE INSERT_TEMP_ENTRY_STMT;
        
		SET @MAXCEDID=(SELECT CONCAT('SELECT MAX(CED_ID)INTO @RECMAXID FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=',MIN_CUSTOMER));
		PREPARE MAXCEDIDSTMT FROM @MAXCEDID;
		EXECUTE MAXCEDIDSTMT;
		SET MAX_CED_ID=@RECMAXID;
		SET @MINCEDID=(SELECT CONCAT('SELECT MIN(CED_ID)INTO @RECMINID FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=',MIN_CUSTOMER));
		PREPARE MINCEDIDSTMT FROM @MINCEDID;
		EXECUTE MINCEDIDSTMT;
		SET MIN_CED_ID=@RECMINID;
		SET RE=1;
		
		WHILE MIN_CED_ID<=MAX_CED_ID DO
		SET @UPDATECUSTOMERENTRY=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS SET CED_REC_VER=',RE, ' WHERE CED_ID=',MIN_CED_ID));
		PREPARE UPDATECUSTOMERENTRYSTMT FROM @UPDATECUSTOMERENTRY;
		EXECUTE UPDATECUSTOMERENTRYSTMT;
		
		SET @STARTDATESTMT=(SELECT CONCAT('SELECT CED_STARTDATE INTO @SDATE FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS WHERE CED_ID=(',MIN_CED_ID,'+1) AND IF(CED_PRETERMINATE_DATE IS NOT NULL,CED_PRETERMINATE_DATE>CED_STARTDATE,CED_ENDDATE>CED_STARTDATE)'));
		PREPARE ENTRYSTARTDATESTMT FROM @STARTDATESTMT;
		EXECUTE ENTRYSTARTDATESTMT;
		SET STARTDATE=@SDATE;
		
		SET @PRETERMINATEDATESTMT=(SELECT CONCAT('SELECT CED_PRETERMINATE_DATE INTO @PDATE FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS WHERE CED_ID=',MIN_CED_ID ));
		PREPARE ENTRYPRETERMINATESTMT FROM @PRETERMINATEDATESTMT;
		EXECUTE ENTRYPRETERMINATESTMT;
		SET PRETERMINATEDATE=@PDATE;
		
		IF PRETERMINATEDATE IS NOT NULL THEN
		
			SET @PRETERMINATEDATESTMT=(SELECT CONCAT('SELECT CED_PRETERMINATE_DATE INTO @PREDATE FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS WHERE CED_ID=',MIN_CED_ID ));
			PREPARE ENTRYPREDATESTMT FROM @PRETERMINATEDATESTMT;
			EXECUTE ENTRYPREDATESTMT;
			SET ENDDATE=@PREDATE;
		ELSE
			SET @ENDDATEDATESTMT=(SELECT CONCAT('SELECT CED_ENDDATE INTO @EDATE FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS WHERE CED_ID=',MIN_CED_ID));
			PREPARE ENTRYENDATESTMT FROM @ENDDATEDATESTMT;
			EXECUTE ENTRYENDATESTMT;
			SET ENDDATE=@EDATE;
		END IF;
		-- update recheckin flag in temp_customer_entry_details
		IF (STARTDATE>ENDDATE)THEN
			SET @UPDATEENTRYRECHECKIN=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS SET CED_RECHECKIN=','"X"',' WHERE CED_ID=(',MIN_CED_ID,'+1)'));
			PREPARE UPDATEENTRYRECHECKINSTMT FROM @UPDATEENTRYRECHECKIN;
			EXECUTE UPDATEENTRYRECHECKINSTMT;
		END IF;

		SET RE=RE+1;
		SET MIN_CED_ID=MIN_CED_ID+1;
	END WHILE;

SET MIN_CUSTOMER=MIN_CUSTOMER+1;
END WHILE;
COMMIT;
END;


-- insert query for customer entry details
DROP PROCEDURE IF EXISTS SP_TEMP_MIG_CUSTOMER_ENTRY_INSERT;
CREATE PROCEDURE SP_TEMP_MIG_CUSTOMER_ENTRY_INSERT(IN SOUCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
SET FOREIGN_KEY_CHECKS=0;
SET @DRCUSTOMERENTRY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.CUSTOMER_ENTRY_DETAILS'));
PREPARE DRCUSTOMERENTRY FROM @DRCUSTOMERENTRY;
EXECUTE DRCUSTOMERENTRY;
SET @CREATECUSTOMERENTRY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.CUSTOMER_ENTRY_DETAILS(
CED_ID INTEGER NOT NULL	AUTO_INCREMENT,
CUSTOMER_ID	INTEGER NOT NULL,
UNIT_ID	INTEGER NOT NULL,
UASD_ID	INTEGER NOT NULL, 
CED_REC_VER	INTEGER NOT NULL,	
CED_SD_STIME INTEGER NOT NULL,	
CED_SD_ETIME INTEGER NOT NULL,	
CED_ED_STIME INTEGER NOT NULL,	
CED_ED_ETIME INTEGER NOT NULL,	
CED_LEASE_PERIOD VARCHAR(30) NULL,	
CED_QUARTERS DECIMAL(5,2) NULL,	
CED_RECHECKIN CHAR(1) NULL,	
CED_EXTENSION CHAR(1) NULL,	
CED_PRETERMINATE CHAR(1) NULL,	
CED_PROCESSING_WAIVED CHAR(1) NULL,	
CED_PRORATED CHAR(1) NULL,	
CED_NOTICE_PERIOD TINYINT(1) NULL,	
CED_NOTICE_START_DATE DATE NULL,	
CED_CANCEL_DATE	DATE NULL,
PRIMARY KEY(CED_ID),
FOREIGN KEY(CUSTOMER_ID) REFERENCES ',DESTINATIONSCHEMA,'.CUSTOMER(CUSTOMER_ID),
FOREIGN KEY(UNIT_ID) REFERENCES ',DESTINATIONSCHEMA,'.UNIT(UNIT_ID),
FOREIGN KEY(UASD_ID) REFERENCES ',DESTINATIONSCHEMA,'.UNIT_ACCESS_STAMP_DETAILS(UASD_ID),
FOREIGN KEY(CED_SD_STIME)REFERENCES ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE(CTP_ID),
FOREIGN KEY(CED_SD_ETIME)REFERENCES ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE(CTP_ID),
FOREIGN KEY(CED_ED_STIME)REFERENCES ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE(CTP_ID),
FOREIGN KEY(CED_ED_ETIME)REFERENCES ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE(CTP_ID))'));
PREPARE CREATECUSENTRYSTMT FROM @CREATECUSTOMERENTRY;
EXECUTE CREATECUSENTRYSTMT;
SET @CUSTOMERENTRYINSERT=(SELECT CONCAT('INSERT INTO
',DESTINATIONSCHEMA ,'.CUSTOMER_ENTRY_DETAILS(CUSTOMER_ID,UNIT_ID,UASD_ID,CED_REC_VER,CED_SD_STIME,
CED_SD_ETIME,CED_ED_STIME,CED_ED_ETIME,CED_LEASE_PERIOD,CED_QUARTERS,CED_EXTENSION,CED_RECHECKIN
,CED_PRETERMINATE,CED_NOTICE_PERIOD,CED_NOTICE_START_DATE,CED_PROCESSING_WAIVED,CED_CANCEL_DATE)
SELECT CUSTOMER_ID ,UNIT_ID ,UASD_ID ,CED_REC_VER ,CED_SD_STIME,CED_SD_ETIME ,CED_ED_STIME ,CED_ED_ETIME ,
CED_LEASE_PERIOD ,CED_QUARTERS ,CED_EXTENSION ,CED_RECHECKIN,CED_PRETERMINATE ,CED_NOTICE_PERIOD
,CED_NOTICE_START_DATE ,CED_PROCESSING_WAIVED ,CED_CANCEL_DATE FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS'));
PREPARE CUSTOMERENTRYINSERTSTMT FROM @CUSTOMERENTRYINSERT;
EXECUTE CUSTOMERENTRYINSERTSTMT ;
SET FOREIGN_KEY_CHECKS=1;
COMMIT;
END;


-- post audit history
DROP PROCEDURE IF EXISTS SP_MIG_CUSTOMER_ENTRY_DETAILS;
CREATE PROCEDURE SP_MIG_CUSTOMER_ENTRY_DETAILS(IN SOURCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50),IN MIGUSERSTAMP VARCHAR(100))
BEGIN

DECLARE START_TIME TIME;
DECLARE END_TIME TIME;
DECLARE DURATION TIME;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
SET SOURCESCHEMA=@SSCHEMA;
SET DESTINATIONSCHEMA=@DSCHEMA;
SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',MIGUSERSTAMP,'"'));
PREPARE LOGINID FROM @LOGIN_ID;
EXECUTE LOGINID;
-- AUDIT HISTORY INSERTS
SET START_TIME=(SELECT CURTIME());
CALL SP_TEMP_CUSTOMER_ENTRY(@SSCHEMA,@DSCHEMA);
CALL SP_TEMP_MIG_CUSTOMER_ENTRY_INSERT(@SSCHEMA,@DSCHEMA);
SET END_TIME=(SELECT CURTIME());
SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
SET @COUNTSCDBCEDSTMT=(SELECT CONCAT('SELECT COUNT(*)INTO @COUNT_SCDB_CED FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT WHERE CC_GUEST_CARD_NO IS NULL'));
PREPARE SCDBCEDSTMT FROM @COUNTSCDBCEDSTMT;
EXECUTE SCDBCEDSTMT;
SET @COUNTSPLITTEDCEDSTMT=(SELECT CONCAT('SELECT COUNT(*)INTO @COUNT_SPLITTED_CED FROM ',DESTINATIONSCHEMA,'.CUSTOMER_ENTRY_DETAILS'));
PREPARE SPLITTEDCEDSTMT FROM @COUNTSPLITTEDCEDSTMT;
EXECUTE SPLITTEDCEDSTMT;
SET @REJECTION_COUNT=(@COUNT_SCDB_CED-@COUNT_SPLITTED_CED);

UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_SCDB_CED  WHERE PREASP_DATA='CUSTOMER_ENTRY_DETAILS';

SET @POSTAPIDSTMT=(SELECT CONCAT('SELECT POSTAP_ID INTO @POSTAPID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA=',"'CUSTOMER_ENTRY_DETAILS'"));
PREPARE POSTAPSTMT FROM @POSTAPIDSTMT;
EXECUTE POSTAPSTMT;
SET @PREASPSTMT=(SELECT CONCAT('SELECT PREASP_ID INTO @PREASPID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA=',"'CUSTOMER_ENTRY_DETAILS'"));
PREPARE PREASPIDSTMT FROM @PREASPSTMT;
EXECUTE PREASPIDSTMT;
SET @PREAMPSTMT=(SELECT CONCAT('SELECT PREAMP_ID INTO @PREAMPID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA=',"'CUSTOMER'"));
PREPARE PREAMPIDSTMT FROM @PREAMPSTMT;
EXECUTE PREAMPIDSTMT;
SET @DUR=DURATION;
SET FOREIGN_KEY_CHECKS=0;
INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
VALUES(@POSTAPID,@COUNT_SPLITTED_CED,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
COMMIT;
END;