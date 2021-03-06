--VER 1.6 STARTSATE:11/07/2014 ENDDATE:04/07/2014 ISSUE NO:345 DESC:APPLIED ULD_MAXTIMES UPDATION WILE UPDATION IN ENTRY,PERSONAL DETAILS TABLE. BY SAFI
-- VER 1.5 STARTDATE:04/07/2014 ENDDATE:04/07/2014 ISSUE NO:303 COMMENT NO:416 DESC:CHANGING HADRCODED CONFIGURATION DATA INTO ID DONEBY:BHAVANI.R
--VERSION 1.3:startdate:16/06/2014 -- enddate:17/06/2014 --ISSUENO 738- DESC:UPDATE ULD ID AND TIMESTAMP IN TICKLER HISTORY-BY SAFI
-- version 1.2 startdate:29/04/2014 -- enddate:30/04/2014 -- issueno 817  -- desc:dynamically changed for temptable done by:LALITHA
-- version 1.1 startdate:07/04/2014 -- enddate:07/04/2014-- - issueno 797 commentno:28-- >desc:REPLACED POSTAP_ID TO TTAP_ID AND POSTAP_DATA TTAP_DATA POST_AUDIT_PROFILE TO TICKLER_TABID_PROFILE done by:RAGHU
-- version 1.0 startdate:03/04/2014 -- enddate:03/04/2014-- - issueno 797 commentno:4-- >desc:REPLACED TABLENAME AND HEADERNAME done by:SASIKALA.D 
-- version 0.9 startdate:28/02/2014 -- enddate:28/02/2014-- - issueno 754 commentno:36-- >desc:added sub sp to convert userstamp as uld_id done by:Dhivya 
-- version 0.8 startdate:27/02/2014 -- enddate:27/02/2014-- - issueno 754 commentno:22-- >desc: REPLACE USERSTAMP DATATYPE AS INT
-- version 0.7 startdate:26/02/2014 -- enddate:26/02/2014-- - issueno 750 commentno:36-- >desc: REPLACE TH_USERSTAMP TO ULD_ID AND USERSTAMP TO ULD_ID
-- >version 0.6 -- sdate:18/02/2013 -- edate:19/02/2013 -- issueno:345 -- commentno:#582 desc:updated tickler table and flag return
--  doneby safi
-- >version 0.5 -- sdate:15/11/2013 -- edate:15/11/2013 -- issueno:345 -- commentno:#375 desc:UPDATED LEASE PERIOD AND QUARTERS AS NULL IN CUSTOMER_ENTRY_DETAILS-- doneby:DHIVYA.A
-- >version 0.4 -- sdate:08/11/2013 -- edate:09/11/2013 -- issueno:636 -- commentno:#47 desc:changed sp name-- doneby:DHIVYA.A
-- >version 0.3 -- sdate:19/10/2013 -- edate:19/10/2013 -- issueno:345 -- commentno:195 -- doneby:RL
-- >version 0.2 -- startdate:02/09/2013 -- enddate:04/08/2013 -- issueno:345 -- commentno:#114
-- >desc:updated customer_access_card details table condition and customer_personal_details table   done by:DHIVYA.A
-- > version 0.1 -- >startdate:05/08/2013 end date:08/08/2013-- >issueno:345 -- >commentno:#87 -- >desc:stored procedure for cancel customer
-- >doneby:dhivya
DROP PROCEDURE IF EXISTS SP_CUSTOMER_CANCEL_INSERT;
CREATE PROCEDURE SP_CUSTOMER_CANCEL_INSERT(
IN CUSTOMERID INTEGER,
IN RECVER INTEGER,
IN USERSTAMP VARCHAR(50),
IN COMMENTS TEXT,
OUT CANCEL_FLAG INTEGER
)
BEGIN
DECLARE CANCEL_DATE DATE;
DECLARE MINID INTEGER;
DECLARE MAXID INTEGER;
DECLARE MIN_CARD_ID INTEGER;
DECLARE MAX_CARD_ID INTEGER;
DECLARE TICK_ENTRY_NEW_VALUE TEXT;
DECLARE TICK_ENTRY_OLD_VALUE TEXT;
DECLARE TICK_ACCESS_NEW_VALUE TEXT;
DECLARE TICK_ACCESS_OLD_VALUE TEXT;
DECLARE TICK_COMMENTS_OLD_VALUE TEXT;
DECLARE TICK_COMMENTS_NEW_VALUE TEXT;
DECLARE OLD_COMMENTS TEXT;
DECLARE GUEST_CARD VARCHAR(2); 
DECLARE USERSTAMP_ID INT(2);
DECLARE CPDID INTEGER;
DECLARE MIN_RECVER INTEGER;
DECLARE MAX_RECVER INTEGER;
DECLARE CANCEL_TEMPTBLNAME TEXT;
DECLARE CANCELCARD_TEMPTBLNAME TEXT;
DECLARE CANCEL_CANTMPTBLNAME TEXT;
DECLARE OLD_ULDID INTEGER;
DECLARE CANCELCARD_CANCARDTMPTBLNAME TEXT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK; 
SET @DROPTEMPCANCEL=(SELECT CONCAT('DROP TABLE IF EXISTS ',CANCEL_CANTMPTBLNAME));
PREPARE DROPTEMPCANCEL_STMT FROM @DROPTEMPCANCEL;
EXECUTE DROPTEMPCANCEL_STMT; 
SET @DROPTEMPCANCELCARD=(SELECT CONCAT('DROP TABLE IF EXISTS ',CANCELCARD_CANCARDTMPTBLNAME));
PREPARE DROPTEMPCANCELCARD_STMT FROM @DROPTEMPCANCELCARD;
EXECUTE DROPTEMPCANCELCARD_STMT;
SET CANCEL_FLAG=0;
END;
 START TRANSACTION;  
SET CANCEL_FLAG=0;
SET CANCEL_DATE=CURDATE();
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID=(SELECT @ULDID);
SET CANCEL_TEMPTBLNAME=(SELECT CONCAT('TEMP_CANCEL_CUSTOMER_DETAILS','_',SYSDATE()));
SET CANCEL_TEMPTBLNAME=(SELECT REPLACE(CANCEL_TEMPTBLNAME,' ',''));
SET CANCEL_TEMPTBLNAME=(SELECT REPLACE(CANCEL_TEMPTBLNAME,'-',''));
SET CANCEL_TEMPTBLNAME=(SELECT REPLACE(CANCEL_TEMPTBLNAME,':',''));
SET CANCEL_CANTMPTBLNAME=(SELECT CONCAT(CANCEL_TEMPTBLNAME,'_',USERSTAMP_ID)); 
SET @TEMP_CREATECANCEL_CUSTOMER_DETAILS=(SELECT CONCAT('CREATE TABLE ',CANCEL_CANTMPTBLNAME,'(ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,CED_ID INTEGER,CACD_ID INTEGER,CUSTOMER_ID INTEGER,REC_VER INTEGER,QUARTERS DECIMAL(5,2),LEASE_PERIOD VARCHAR(30),CLP_GUEST_CARD CHAR(1) ,UASD_ACCESS_CARD INTEGER(7),UASD_ID INTEGER,CANCELDATE DATE, ULD_ID INTEGER, CAN_TIMESTAMP TIMESTAMP )'));
PREPARE TEMP_CREATECANCEL_CUSTOMER_DETAILS_STMT FROM @TEMP_CREATECANCEL_CUSTOMER_DETAILS;
EXECUTE TEMP_CREATECANCEL_CUSTOMER_DETAILS_STMT;
SET @TEMP_INSERTCANCEL_CUSTOMER_DETAILS=(SELECT CONCAT('INSERT INTO ',CANCEL_CANTMPTBLNAME,'(CED_ID,CACD_ID,CUSTOMER_ID,REC_VER,QUARTERS,LEASE_PERIOD,CLP_GUEST_CARD,UASD_ACCESS_CARD,UASD_ID,CANCELDATE,ULD_ID,CAN_TIMESTAMP) SELECT CED.CED_ID,CACD.CACD_ID,CED.CUSTOMER_ID,CED.CED_REC_VER,CED_QUARTERS,CED_LEASE_PERIOD,CLP_GUEST_CARD,UASD_ACCESS_CARD ,CTD.UASD_ID,CED.CED_CANCEL_DATE,CACD.ULD_ID,CACD.CACD_TIMESTAMP FROM CUSTOMER_ENTRY_DETAILS CED,CUSTOMER_LP_DETAILS CTD LEFT JOIN CUSTOMER_ACCESS_CARD_DETAILS CACD ON CTD.UASD_ID=CACD.UASD_ID AND CACD.ACN_ID IS NULL  LEFT JOIN UNIT_ACCESS_STAMP_DETAILS UASD ON (UASD.UASD_ID=CTD.UASD_ID) WHERE (CED.CUSTOMER_ID=',CUSTOMERID,')AND (CTD.CUSTOMER_ID=CED.CUSTOMER_ID) AND (CED.CED_REC_VER=CTD.CED_REC_VER) AND  CED.CED_REC_VER>=',RECVER,' AND CTD.CLP_TERMINATE IS NULL')) ;
PREPARE TEMP_INSERTCANCEL_CUSTOMER_DETAILS_STMT FROM @TEMP_INSERTCANCEL_CUSTOMER_DETAILS;
EXECUTE TEMP_INSERTCANCEL_CUSTOMER_DETAILS_STMT;
SET @TEMP_MINID=(SELECT CONCAT('SELECT MIN(ID) INTO @TEMPMINID FROM ',CANCEL_CANTMPTBLNAME));
PREPARE TEMP_MINID_STMT FROM @TEMP_MINID;
EXECUTE TEMP_MINID_STMT;
SET MINID=@TEMPMINID;
SET @TEMP_MAXID=(SELECT CONCAT('SELECT MAX(ID)INTO @TEMPMAXID FROM ',CANCEL_CANTMPTBLNAME));
PREPARE TEMP_MAXID_STMT FROM @TEMP_MAXID;
EXECUTE TEMP_MAXID_STMT;
SET MAXID=@TEMPMAXID;
WHILE(MAXID>=MINID)DO
SET @GUESTCARD=NULL;
SET @GUEST_CARD=(SELECT CONCAT('SELECT CLP_GUEST_CARD INTO @GUESTCARD FROM ',CANCEL_CANTMPTBLNAME,' WHERE ID=',MINID,''));
PREPARE GUEST_CARD_STMT FROM @GUEST_CARD;
EXECUTE GUEST_CARD_STMT;
SET GUEST_CARD=@GUESTCARD;
IF(GUEST_CARD IS NULL)THEN
SET @RECVER=NULL;
SET @QUAR_TERS=NULL;
SET @LEASEPERIOD=NULL;
SET @CEDID=NULL;
SET @TICKRECVER=(SELECT CONCAT('SELECT REC_VER INTO @RECVER FROM ',CANCEL_CANTMPTBLNAME,' WHERE ID=',MINID));
PREPARE TICKRECVER_STMT FROM @TICKRECVER;
EXECUTE TICKRECVER_STMT; 
SET @TICKQUARTERS=(SELECT CONCAT('SELECT QUARTERS INTO @QUAR_TERS FROM ',CANCEL_CANTMPTBLNAME,' WHERE ID=',MINID));
PREPARE TICKQUARTERS_STMT FROM @TICKQUARTERS;
EXECUTE TICKQUARTERS_STMT;
SET @TICK_LP=(SELECT CONCAT('SELECT LEASE_PERIOD INTO @LEASEPERIOD FROM ',CANCEL_CANTMPTBLNAME,' WHERE ID=',MINID));
PREPARE TICK_LP_STMT FROM @TICK_LP;
EXECUTE TICK_LP_STMT; 
 SET @TICK_CEDID=(SELECT CONCAT('SELECT CED_ID INTO @CEDID FROM ',CANCEL_CANTMPTBLNAME,' WHERE ID=',MINID));
 PREPARE TICK_CEDID_STMT FROM @TICK_CEDID;
EXECUTE TICK_CEDID_STMT;
SET TICK_ENTRY_OLD_VALUE=(SELECT CONCAT('CED_ID=',@CEDID,',CED_REC_VER=',@RECVER,',CED_QUARTERS=',@QUAR_TERS,',CED_LEASE_PERIOD=',@LEASEPERIOD,',CED_CANCEL_DATE=NULL'));
SET TICK_ENTRY_NEW_VALUE=(SELECT CONCAT('CED_QUARTERS=NULL',',CED_LEASE_PERIOD=NULL',',CED_CANCEL_DATE=',CANCEL_DATE));
INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ENTRY_DETAILS'),TICK_ENTRY_OLD_VALUE,TICK_ENTRY_NEW_VALUE,USERSTAMP_ID,CUSTOMERID);
END IF;
SET MINID = MINID+1;
END WHILE;
SET CANCELCARD_TEMPTBLNAME=(SELECT CONCAT('TEMP_CANCEL_CARD',SYSDATE()));
SET CANCELCARD_TEMPTBLNAME=(SELECT REPLACE(CANCELCARD_TEMPTBLNAME,' ',''));
SET CANCELCARD_TEMPTBLNAME=(SELECT REPLACE(CANCELCARD_TEMPTBLNAME,'-',''));
SET CANCELCARD_TEMPTBLNAME=(SELECT REPLACE(CANCELCARD_TEMPTBLNAME,':',''));
SET CANCELCARD_CANCARDTMPTBLNAME=(SELECT CONCAT(CANCELCARD_TEMPTBLNAME,'_',USERSTAMP_ID));
SET @TEMP_CREATECANCEL_CARD=(SELECT CONCAT('CREATE TABLE ',CANCELCARD_CANCARDTMPTBLNAME,'(ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,UASD_ID INTEGER,CACD_ID INTEGER,ULD_ID INTEGER,CAN_TIMESTAMP TIMESTAMP)'));
PREPARE TEMP_CREATECANCEL_CARD_STMT FROM @TEMP_CREATECANCEL_CARD;
EXECUTE TEMP_CREATECANCEL_CARD_STMT;
SET @TEMP_INSERTCANCEL_CARD=(SELECT CONCAT('INSERT INTO ',CANCELCARD_CANCARDTMPTBLNAME,'(UASD_ID,CACD_ID,ULD_ID,CAN_TIMESTAMP)SELECT  UASD_ID,CACD_ID,ULD_ID,CACD_TIMESTAMP FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=',CUSTOMERID,' AND ACN_ID IS NULL'));
PREPARE TEMP_INSERTCANCEL_CARD_STMT FROM @TEMP_INSERTCANCEL_CARD;
EXECUTE TEMP_INSERTCANCEL_CARD_STMT;
SET @TEMP_MIN_CARD_ID=(SELECT CONCAT('SELECT MIN(ID) INTO @TEMPMINCARDID FROM ',CANCELCARD_CANCARDTMPTBLNAME));
PREPARE TEMP_MIN_CARD_ID_STMT FROM @TEMP_MIN_CARD_ID;
EXECUTE TEMP_MIN_CARD_ID_STMT;
SET MIN_CARD_ID=@TEMPMINCARDID;
SET @TEMP_MAX_CARD_ID=(SELECT CONCAT('SELECT MAX(ID)INTO @TEMPMAXCARDID FROM ',CANCELCARD_CANCARDTMPTBLNAME));
PREPARE TEMP_MAX_CARD_ID_STMT FROM @TEMP_MAX_CARD_ID;
EXECUTE TEMP_MAX_CARD_ID_STMT;
SET MAX_CARD_ID=@TEMPMAXCARDID;
WHILE(MAX_CARD_ID>=MIN_CARD_ID)DO
SET @TICK_UASDID=(SELECT CONCAT('SELECT UASD_ID INTO @UASDID FROM ',CANCELCARD_CANCARDTMPTBLNAME,' WHERE ID=',MIN_CARD_ID));
PREPARE TICK_UASDID_STMT FROM @TICK_UASDID;
EXECUTE TICK_UASDID_STMT;
SET @TICK_CACDID=(SELECT CONCAT('SELECT CACD_ID INTO @CACDID FROM ',CANCELCARD_CANCARDTMPTBLNAME,' WHERE ID=',MIN_CARD_ID));
PREPARE TICK_CACDID_STMT FROM @TICK_CACDID;
EXECUTE TICK_CACDID_STMT;
SET @TICK_ULDID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',CANCELCARD_CANCARDTMPTBLNAME,' WHERE ID=',MIN_CARD_ID));
PREPARE TICK_ULDID_STMT FROM @TICK_ULDID;
EXECUTE TICK_ULDID_STMT;
SET OLD_ULDID=@ULDID;
SET @TICK_TIMESTAMP=(SELECT CONCAT('SELECT CAN_TIMESTAMP INTO @CANCEL_TIMESTAMP FROM ',CANCELCARD_CANCARDTMPTBLNAME,' WHERE ID=',MIN_CARD_ID));
PREPARE TICK_TIMESTAMP_STMT FROM @TICK_TIMESTAMP;
EXECUTE TICK_TIMESTAMP_STMT;
IF(OLD_ULDID!=USERSTAMP_ID)THEN
SET TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD=',@CACDID,',UASD_ID=',@UASDID, ',ACN_ID=NULL',',','CACD_VALID_TILL=NULL',', ULD_ID=',@ULDID,', CACD_TIMESTAMP=',@CANCEL_TIMESTAMP));
ELSE
SET TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD=',@CACDID,',UASD_ID=',@UASDID, ',ACN_ID=NULL',',','CACD_VALID_TILL=NULL',', CACD_TIMESTAMP=',@CANCEL_TIMESTAMP));
END IF;
SET TICK_ACCESS_NEW_VALUE=(SELECT CONCAT('ACN_ID=',4,',','CACD_VALID_TILL=',CANCEL_DATE));
INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ACCESS_CARD_DETAILS'),TICK_ACCESS_OLD_VALUE,TICK_ACCESS_NEW_VALUE,USERSTAMP_ID,CUSTOMERID);
SET MIN_CARD_ID = MIN_CARD_ID+1;
END WHILE;
SET OLD_COMMENTS=(SELECT CPD_COMMENTS FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
IF OLD_COMMENTS IS NULL THEN
    SET OLD_COMMENTS='NULL';
END IF;
IF COMMENTS='' THEN
        SET COMMENTS='NULL';
END IF;
IF(OLD_COMMENTS!=COMMENTS)THEN
SET CPDID=(SELECT CPD_ID FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
SET TICK_COMMENTS_OLD_VALUE=(SELECT CONCAT('CPD_ID=',CPDID,',CPD_COMMENTS=',OLD_COMMENTS));
SET TICK_COMMENTS_NEW_VALUE=(SELECT CONCAT('CPD_COMMENTS=',COMMENTS));
INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_PERSONAL_DETAILS'),TICK_COMMENTS_OLD_VALUE,TICK_COMMENTS_NEW_VALUE,USERSTAMP_ID,CUSTOMERID);
END IF;
IF(COMMENTS='NULL')THEN
SET COMMENTS=NULL;
END IF;
UPDATE CUSTOMER_ENTRY_DETAILS SET CED_CANCEL_DATE=CANCEL_DATE,CED_LEASE_PERIOD=NULL,CED_QUARTERS=NULL  WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER>=RECVER;
SET MIN_RECVER=RECVER;
SET MAX_RECVER=(SELECT MAX(CED_REC_VER) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
WHILE(MAX_RECVER>=MIN_RECVER)DO
CALL SP_LP_DETAILS_ULD_TS_MAXTIMES(CUSTOMERID,MIN_RECVER,USERSTAMP_ID);
SET MIN_RECVER=MIN_RECVER+1;
END WHILE;
SET CANCEL_FLAG=1;
UPDATE CUSTOMER_PERSONAL_DETAILS SET CPD_COMMENTS=COMMENTS WHERE CUSTOMER_ID=CUSTOMERID;
SET CANCEL_FLAG=1;
IF EXISTS (SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER>=RECVER AND UASD_ID IS NOT NULL)THEN
UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET CACD_VALID_TILL=CANCEL_DATE,ACN_ID=(SELECT ACN_ID FROM ACCESS_CONFIGURATION WHERE ACN_ID=4),ULD_ID=USERSTAMP_ID WHERE CUSTOMER_ID=CUSTOMERID AND ACN_ID IS NULL AND UASD_ID IN(SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER>=RECVER AND CUSTOMER_ID=CUSTOMERID);
SET CANCEL_FLAG=1;
UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_ACTIVE=null,UASD_ACCESS_LOST=null,UASD_ACCESS_INVENTORY='X'
WHERE UASD_ID IN(SELECT UASD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID IN(SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER>=RECVER AND CUSTOMER_ID=CUSTOMERID));
SET CANCEL_FLAG=1;
END IF; 
 SET @DROPTEMPCANCEL=(SELECT CONCAT('DROP TABLE IF EXISTS ',CANCEL_CANTMPTBLNAME));
PREPARE DROPTEMPCANCEL_STMT FROM @DROPTEMPCANCEL;
EXECUTE DROPTEMPCANCEL_STMT; 
SET @DROPTEMPCANCELCARD=(SELECT CONCAT('DROP TABLE IF EXISTS ',CANCELCARD_CANCARDTMPTBLNAME));
PREPARE DROPTEMPCANCELCARD_STMT FROM @DROPTEMPCANCELCARD;
EXECUTE DROPTEMPCANCELCARD_STMT;  
 COMMIT;  
END;