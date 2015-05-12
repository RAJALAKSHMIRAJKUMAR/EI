-- version:1.0 -- sdate:09/06/2014 -- edate:09/06/2014 -- issue:566 -- COMMENT NO:12 --desc:IMPLEMENTED ROLL BACK AND COMMIT --doneby:DHIVYA.A
--VER 0.9 ISSUE NO:765 STARTDATE:22/04/2014 ENDDATE:22/04/2014 DESC:CHANGED TIME ZONE DONE BY:DHIVYA
-- version:0.6 -- sdate:17/03/2014 -- edate:27/03/2014 -- issue:765 --desc:sp changed dynamically --doneby:DHIVYA
-- version:0.5 -- sdate:17/03/2014 -- edate:17/03/2014 -- issue:765 --desc:droped temp table --doneby:RL
--version:0.4 --sdate:25/02/2014 --edate:26/02/2014 --issue:750 comment:#30 -desc:added uld_id header and source timestamp by:dhivya
--version:0.3 --sdate:19/02/2014 --edate:19/02/2014 --issue:750 -desc:added preaudit and post audit queries done by:dhivya
--VER 0.2 STARTDATE:21/01/2014 ENDDATE:22/01/2014 ISSUE NO:594 COMMENT :#50 DESC:ALL UPDATION DONE IN THE SPLITTED TABLE ITSELF NOT IN THE ACCESS SCDB FORMAT TABLE DONE BY:DHIVYA
 
DROP PROCEDURE IF EXISTS SP_TEMP_CUSTOMER_ACCESS_CARD_DETAILS;
CREATE PROCEDURE SP_TEMP_CUSTOMER_ACCESS_CARD_DETAILS(IN SOURCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50))
 BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
 -- DROP QUERY FOR TEMP_CUSTOMER_ACCESS_CARD_DETAILS
SET @DROPTEMPCUSTOMERACCESS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ACCESS_CARD_DETAILS'));
PREPARE DRTEMPCUSTOMERACCESS FROM @DROPTEMPCUSTOMERACCESS;
EXECUTE DRTEMPCUSTOMERACCESS;
 -- CREATE QUERY FOR TEMP_CUSTOMER_ACCESS_CARD_DETAILS
SET @CREATECUSTOMERACCESS=(SELECT CONCAT('
 CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ACCESS_CARD_DETAILS(
 AC_ID INTEGER,
 AC_FIRST_NAME CHAR(30),
 AC_LAST_NAME CHAR(30),
 AC_CARD INTEGER,
 AC_GUEST_CARD CHAR(1),
 AC_REASON TEXT,
 AC_REC_VER INTEGER,
 AC_UNIT_NO INTEGER,
 AC_VALID_FROM DATE,
 AC_VALID_TILL DATE,
 AC_COMMENTS TEXT,
 ULDID INTEGER,
 ACCESS_TIMESTAMP VARCHAR(50))'));
 PREPARE CREATEACCESSSTMT FROM @CREATECUSTOMERACCESS;
 EXECUTE CREATEACCESSSTMT;
 
 -- DROP QUERY FOR TEMP_CUSTOMER
 SET @DROPTEMPCUSTOMER=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER'));
PREPARE DRTEMPCUSTOMER FROM @DROPTEMPCUSTOMER;
EXECUTE DRTEMPCUSTOMER;
 
-- CREATE QUERY FOR TEMP_CUSTOMER
SET @CREATETEMPCUSTOMER=(SELECT CONCAT('
 CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER(
 CC_CUST_ID INTEGER,
 CC_FIRST_NAME CHAR(30),
 CC_LAST_NAME CHAR(30),
 CC_STARTDATE DATE,
 CC_UNIT_NO INTEGER,
 CC_CARD_NO INTEGER)'));
 PREPARE CREATETEMPCUSTOMERSTMT FROM @CREATETEMPCUSTOMER;
 EXECUTE CREATETEMPCUSTOMERSTMT;
 
 SET @UPDATEACESS=(SELECT CONCAT('UPDATE ',SOURCESCHEMA,'.ACCESS_SCDB_FORMAT SET USERSTAMP=TRIM(USERSTAMP)'));
 PREPARE UPDATEACCESSSTMT FROM @UPDATEACESS;
EXECUTE  UPDATEACCESSSTMT;
 
 
 SET @INSERTACCESS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ACCESS_CARD_DETAILS(AC_ID,AC_FIRST_NAME,AC_LAST_NAME,AC_CARD,AC_GUEST_CARD,AC_REASON,AC_REC_VER,AC_UNIT_NO,AC_VALID_FROM,AC_VALID_TILL,AC_COMMENTS,ULDID,ACCESS_TIMESTAMP)
 SELECT ASF.AC_ID,ASF.AC_FIRST_NAME,ASF.AC_LAST_NAME,ASF.AC_CARD,ASF.AC_GUEST_CARD,ASF.AC_REASON,ASF.AC_REC_VER,ASF.AC_UNIT_NO,ASF.AC_VALID_FROM,ASF.AC_VALID_TILL,ASF.AC_COMMENTS,ULD.ULD_ID,ASF.TIMESTAMP FROM ',SOURCESCHEMA,'.ACCESS_SCDB_FORMAT ASF,'
 ,DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE ULD.ULD_LOGINID=ASF.USERSTAMP'));
 PREPARE INSERTACCESSSTMT FROM @INSERTACCESS;
 EXECUTE INSERTACCESSSTMT;
 
 SET @UPDATEACCESS=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ACCESS_CARD_DETAILS SET AC_LAST_NAME=AC_FIRST_NAME WHERE AC_LAST_NAME IS NULL'));
 PREPARE UPDATEACCESSSTMT FROM @UPDATEACCESS;
 EXECUTE UPDATEACCESSSTMT;
 
 SET @INSERTTEMPACCESS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER(CC_CUST_ID,CC_FIRST_NAME,CC_LAST_NAME,CC_STARTDATE,CC_UNIT_NO,CC_CARD_NO)
 SELECT CC_CUST_ID,CC_FIRST_NAME,CC_LAST_NAME,CC_STARTDATE,CC_UNIT_NO,CC_CARD_NO FROM ',SOURCESCHEMA,'.CUSTOMER_SCDB_FORMAT'));
 PREPARE INSERTTEMPACCESSSTMT FROM @INSERTTEMPACCESS;
 EXECUTE INSERTTEMPACCESSSTMT;
 
 SET @UPDATETEMPACCESS=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER SET CC_LAST_NAME=CC_FIRST_NAME WHERE CC_LAST_NAME IS NULL'));
 PREPARE UPDATETEMPACCESSSTMT FROM @UPDATETEMPACCESS;
 EXECUTE UPDATETEMPACCESSSTMT;
 SET @UPDATETIMESTAMP=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ACCESS_CARD_DETAILS SET ACCESS_TIMESTAMP=(SELECT CONVERT_TZ(ACCESS_TIMESTAMP, "+08:00","+0:00"))'));
PREPARE UPDATETIMESTAMPSTMT FROM @UPDATETIMESTAMP;
EXECUTE UPDATETIMESTAMPSTMT;
 
SET @DROPACCESSCARD=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.CUSTOMER_ACCESS_CARD_DETAILS'));
PREPARE DRACCESSSTMT FROM @DROPACCESSCARD;
EXECUTE DRACCESSSTMT;

SET @CREATECUSTOMERACCESS=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.CUSTOMER_ACCESS_CARD_DETAILS(
CACD_ID	INTEGER NOT NULL AUTO_INCREMENT,
CUSTOMER_ID	INTEGER NOT NULL,
UASD_ID	INTEGER NOT NULL,
ACN_ID INTEGER NULL,
CACD_VALID_FROM	DATE NOT NULL,
CACD_VALID_TILL	DATE NULL,
CACD_GUEST_CARD	CHAR(1) NULL,
ULD_ID INT(2) NOT NULL,	
CACD_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY(CACD_ID),
FOREIGN KEY(CUSTOMER_ID) REFERENCES ',DESTINATIONSCHEMA,'.CUSTOMER(CUSTOMER_ID),
FOREIGN KEY(UASD_ID) REFERENCES ',DESTINATIONSCHEMA,'.UNIT_ACCESS_STAMP_DETAILS(UASD_ID),
FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
PREPARE CREATECUSTOMERACCESSSTMT FROM @CREATECUSTOMERACCESS;
EXECUTE CREATECUSTOMERACCESSSTMT;
COMMIT;
END;
 
 
 
 -- SP FOR CUSTOMER_ACCESS_CARD_DETAILS INSERTION
DROP PROCEDURE IF EXISTS SP_CUSTOMER_ACCESS_CARD_DETAILS;
CREATE PROCEDURE SP_CUSTOMER_ACCESS_CARD_DETAILS(IN SOURCE_SCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50),IN ACCESS_USERSTAMP VARCHAR(100))
 BEGIN
DECLARE  DONE INT DEFAULT FALSE;
DECLARE FIRSTNAME CHAR(30);
 DECLARE LASTNAME CHAR(30);
 DECLARE ACCESSCARD INTEGER(7);
 DECLARE ACNDATA TEXT;
 DECLARE VALIDFROM DATE;
 DECLARE VALIDTILL DATE;
 DECLARE GUESTCARD CHAR(1);
 DECLARE RECVER INTEGER;
 DECLARE USERID INTEGER;
 DECLARE UNITNO INTEGER;
 DECLARE CARDNO INTEGER;
 DECLARE START_TIME TIME;
 DECLARE END_TIME TIME;
 DECLARE DURATION TIME;
 DECLARE ACCESSTIMESTAMP TIMESTAMP;
 DECLARE FILTER_CURSOR CURSOR FOR 
SELECT AC_FIRST_NAME,AC_LAST_NAME,AC_CARD,AC_VALID_FROM,AC_REASON,AC_REC_VER,AC_VALID_TILL,AC_GUEST_CARD,AC_UNIT_NO,ULDID,ACCESS_TIMESTAMP FROM VW_TEMP_ACCESS_CARD_DETAILS;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
SET @VW_TEMP_ACCESS_CARD_DETAILS_STMT=(SELECT CONCAT('CREATE OR REPLACE VIEW VW_TEMP_ACCESS_CARD_DETAILS AS SELECT AC_FIRST_NAME,AC_LAST_NAME,AC_CARD,AC_VALID_FROM,AC_REASON,AC_REC_VER,AC_VALID_TILL,AC_GUEST_CARD,AC_UNIT_NO,ULDID,ACCESS_TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ACCESS_CARD_DETAILS'));
PREPARE ACESS_STMT FROM @VW_TEMP_ACCESS_CARD_DETAILS_STMT;
EXECUTE ACESS_STMT;
SET START_TIME=(SELECT CURTIME());
SET SOURCE_SCHEMA=@SSCHEMA;
SET DESTINATIONSCHEMA=@DSCHEMA;
SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',ACCESS_USERSTAMP,'"'));
	PREPARE LOGINID FROM @LOGIN_ID;
	EXECUTE LOGINID;

OPEN FILTER_CURSOR;
read_loop: LOOP
FETCH FILTER_CURSOR INTO FIRSTNAME,LASTNAME,ACCESSCARD,VALIDFROM,ACNDATA,RECVER,VALIDTILL,GUESTCARD,UNITNO,USERID,ACCESSTIMESTAMP;
IF DONE THEN
      LEAVE read_loop;
END IF;
SET @FIRST_NAME = FIRSTNAME;
SET @LAST_NAME = LASTNAME;
SET @ACCESS_CARD = ACCESSCARD;
SET @VALID_FROM = VALIDFROM;
SET @ACN_DATA = ACNDATA;
SET @REC_VER = RECVER;
SET @VALID_TILL = VALIDTILL;
SET @GUEST_CARD = GUESTCARD;
SET @ACCESSUNITNO = UNITNO;
SET @ACCESSULDID = USERID;
SET @TIME_STAMP = ACCESSTIMESTAMP;
SET @UASDIDSTMT = (SELECT CONCAT('SELECT UASD_ID INTO @UASDID FROM ',DESTINATIONSCHEMA,'.UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=@ACCESS_CARD'));
PREPARE UASDID_STMT FROM @UASDIDSTMT;
EXECUTE UASDID_STMT;
IF ACNDATA IS NOT NULL THEN
SET @ACNIDSTMT = (SELECT CONCAT('SELECT ACN_ID INTO @ACNID FROM ',DESTINATIONSCHEMA,'.ACCESS_CONFIGURATION WHERE ACN_DATA=@ACN_DATA'));
PREPARE ACCESSID_STMT FROM @ACNIDSTMT;
EXECUTE ACCESSID_STMT;
ELSE
SET @ACNID=NULL;
END IF;
IF ((ACNDATA IS NULL)OR(ACNDATA='TERMINATED'))THEN
SET @CUSTOMERIDSTMT=(SELECT CONCAT('SELECT DISTINCT TC.CC_CUST_ID INTO @CUSTID FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER TC,',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ACCESS_CARD_DETAILS TACD WHERE TACD.AC_FIRST_NAME=TC.CC_FIRST_NAME AND TACD.AC_LAST_NAME=TC.CC_LAST_NAME AND TC.CC_STARTDATE<=@VALID_FROM AND TACD.AC_LAST_NAME=@LAST_NAME AND TACD.AC_FIRST_NAME=@FIRST_NAME AND TACD.AC_UNIT_NO=@ACCESSUNITNO AND TACD.AC_CARD=TC.CC_CARD_NO AND TACD.AC_CARD=@ACCESS_CARD'));
PREPARE CUSTOMERID_STMT FROM @CUSTOMERIDSTMT;
EXECUTE CUSTOMERID_STMT;
ELSE
SET @CUSTOMERIDSTMT1=(SELECT CONCAT('SELECT DISTINCT CC_CUST_ID INTO @CCID FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER WHERE  CC_LAST_NAME=@LAST_NAME AND CC_FIRST_NAME=@FIRST_NAME AND CC_UNIT_NO=@ACCESSUNITNO') );
PREPARE CUSTOMERID_STMT1 FROM @CUSTOMERIDSTMT1;
EXECUTE CUSTOMERID_STMT1;
END IF;
--INSERT QUERY FOR CUSTOMER_ACCESS_CARD_DETAILS
IF ((ACNDATA IS NULL)OR(ACNDATA='TERMINATED'))THEN
SET @INSERTACCESS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.CUSTOMER_ACCESS_CARD_DETAILS(CUSTOMER_ID,UASD_ID,ACN_ID,CACD_VALID_FROM,CACD_VALID_TILL,CACD_GUEST_CARD,ULD_ID,CACD_TIMESTAMP)VALUES
(@CUSTID,@UASDID,@ACNID,@VALID_FROM,@VALID_TILL,@GUEST_CARD,@ACCESSULDID,@TIME_STAMP)'));
PREPARE INSERTACCESSSTMT FROM @INSERTACCESS;
EXECUTE INSERTACCESSSTMT;
ELSE
SET @INSERTACCESSDAMAGED=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.CUSTOMER_ACCESS_CARD_DETAILS(CUSTOMER_ID,UASD_ID,ACN_ID,CACD_VALID_FROM,CACD_VALID_TILL,CACD_GUEST_CARD,ULD_ID,CACD_TIMESTAMP)VALUES
(@CCID,@UASDID,@ACNID,@VALID_FROM,@VALID_TILL,@GUEST_CARD,@ACCESSULDID,@TIME_STAMP)'));
PREPARE INSERTACCESSDAMAGED FROM @INSERTACCESSDAMAGED;
EXECUTE INSERTACCESSDAMAGED;
END IF;
END LOOP;
CLOSE FILTER_CURSOR;
-- AUDIT QUERY
SET END_TIME=(SELECT CURTIME());
SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
SET @COUNTSCDBCACD=(SELECT CONCAT('SELECT COUNT(*)INTO @COUNT_SCDB_CACD FROM ',SOURCE_SCHEMA,'.ACCESS_SCDB_FORMAT'));
PREPARE COUNTSCDBCACDSTMT FROM @COUNTSCDBCACD;
EXECUTE COUNTSCDBCACDSTMT;
SET @COUNTSPLITTEDCACD=(SELECT CONCAT('SELECT COUNT(*)INTO @COUNT_SPLITTED_CACD FROM ',DESTINATIONSCHEMA,'.CUSTOMER_ACCESS_CARD_DETAILS'));
PREPARE COUNTSPLITTEDCACD FROM @COUNTSPLITTEDCACD;
EXECUTE COUNTSPLITTEDCACD;
SET @REJECTION_COUNT=(@COUNT_SCDB_CACD-@COUNT_SPLITTED_CACD);
UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_SCDB_CACD  WHERE PREASP_DATA='CUSTOMER_ACCESS_CARD_DETAILS';

SET @POSTAPIDSTMT=(SELECT CONCAT('SELECT POSTAP_ID INTO @POSTAPID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA=',"'CUSTOMER_ACCESS_CARD_DETAILS'"));
PREPARE POSTAPSTMT FROM @POSTAPIDSTMT;
EXECUTE POSTAPSTMT;
SET @PREASPSTMT=(SELECT CONCAT('SELECT PREASP_ID INTO @PREASPID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA=',"'CUSTOMER_ACCESS_CARD_DETAILS'"));
PREPARE PREASPIDSTMT FROM @PREASPSTMT;
EXECUTE PREASPIDSTMT;
SET @PREAMPSTMT=(SELECT CONCAT('SELECT PREAMP_ID INTO @PREAMPID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA=',"'ACCESS'"));
PREPARE PREAMPIDSTMT FROM @PREAMPSTMT;
EXECUTE PREAMPIDSTMT;
SET @DUR=DURATION;
SET FOREIGN_KEY_CHECKS=0;
INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
VALUES(@POSTAPID,@COUNT_SPLITTED_CACD,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
SET @DROPTEMPACESS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ACCESS_CARD_DETAILS'));
PREPARE DRTEMPACCESS FROM @DROPTEMPACESS;
EXECUTE DRTEMPACCESS;
SET @DROPTEMPCUSTOMER=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER'));
PREPARE DRTEMPCUSTOMER FROM @DROPTEMPCUSTOMER;
EXECUTE DRTEMPCUSTOMER;

DROP VIEW IF EXISTS VW_TEMP_ACCESS_CARD_DETAILS;
COMMIT;
END;