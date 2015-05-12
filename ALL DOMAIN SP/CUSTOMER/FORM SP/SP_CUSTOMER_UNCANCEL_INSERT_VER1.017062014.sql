--VERSION 1.0:startdate:16/06/2014 -- enddate:17/06/2014 --ISSUENO 738- DESC:UPDATE ULD ID AND TIMESTAMP IN TICKLER HISTORY-BY SAFI
-- version 0.9 startdate:07/05/2014 -- enddate:07/05/2014 -- issueno 821  -- desc:changed comments updation query and fixed future customer and active customer without card issue done by:DHIVYA
-- version 0.8 startdate:30/04/2014 -- enddate:30/04/2014 -- issueno 817  -- desc:dynamically changed for temptable done by:LALITHA
--version 0.7 startdate:07/04/2014 --enddate:07/04/2014--- issueno 797 commentno:28-->desc:replaced tablename and headername done by:raja
--version 0.6 startdate:05/04/2014 --enddate:05/04/2014--- issueno 797 commentno:4-->desc:replaced tablename and headername done by:sasikala.D
--version 0.5 startdate:28/02/2014 --enddate:28/02/2014--- issueno 754 commentno:36-->desc:added sub sp to convert userstamp as uld_id done by:Dhivya 
-->version 0.4 -->start date:26/02/2014 end date:26/02/2014 -->issueno:750  -->description:UPDATING USERSTAMP TO ULD_ID -->created by:SAFI.M
-- version :0.3-startdate:18/02/2014 --enddate:19/02/2014--issueno:345 --doneby:safi desc:updated tickler and flag return 
--version:0.2 --startdate:22/11/2013 --enddate:23/11/2013 --issueno:648 --doneby:rl
-- version:0.1 --startdate:23/10/2013 --enddate:31/10/2013 --issueno:345 --commentno:197 --desc:uncancel form sp --doneby:rl
DROP PROCEDURE IF EXISTS SP_CUSTOMER_UNCANCEL_INSERT;
CREATE PROCEDURE SP_CUSTOMER_UNCANCEL_INSERT(
IN CUSTOMERID INTEGER,
IN RECORD_VERSION INTEGER,
IN COMMENTS TEXT,
IN RECVER_LPQ TEXT,
IN USERSTAMP VARCHAR(50),
OUT UNCANCEL_FLAG INTEGER)
BEGIN
DECLARE CANCEL_DATE DATE;
DECLARE MIN_REC_VER INTEGER;
DECLARE MAX_REC_VER INTEGER;
DECLARE TEMP_RECVER_LPQ TEXT;
DECLARE REC_VERSION INTEGER;
DECLARE REC_VERSION_POSITION INTEGER;
DECLARE REC_VERSION_LOCATION INTEGER;
DECLARE REC_VERSION_LENGTH INTEGER;
DECLARE LEASE_PERIOD VARCHAR(30);
DECLARE LEASE_PERIOD_POSITION INTEGER;
DECLARE QUARTERS DECIMAL(5,2);
DECLARE QUARTERS_POSITION INTEGER;
DECLARE TICK_ACCESS_NEW_VALUE TEXT;
DECLARE TICK_ACCESS_OLD_VALUE TEXT;
DECLARE OLD_COMMENTS TEXT;
DECLARE TICK_TERMINATION_OLD_VALUE TEXT;
DECLARE TICK_TERMINATION_NEW_VALUE TEXT;
DECLARE TICK_COMMENTS_OLD_VALUE TEXT;
DECLARE TICK_COMMENTS_NEW_VALUE TEXT;
DECLARE TICK_ENTRY_DETAILS_OLD_VALUE TEXT;
DECLARE TICK_ENTRY_DETAILS_NEW_VALUE TEXT;
DECLARE OLD_CANCEL_DATE DATE;
DECLARE MIN_ID INTEGER;
DECLARE MAX_ID INTEGER;
DECLARE CEDID INTEGER;
DECLARE MIN_CARD_ID INTEGER;
DECLARE MAX_CARD_ID INTEGER;
DECLARE GUEST_CARD VARCHAR(3);
DECLARE CACD_GUEST_CARD TEXT;
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE CPDID INTEGER;
DECLARE TEMP_UNCANCEL_CARD_NO TEXT;
DECLARE UNCANCEL_CARDTEMPTBLNAME TEXT;
DECLARE UNCANCEL_CARDTMPTBLNAME TEXT;
DECLARE UNCANCELUNIQUE_CARDTEMPTBLNAME TEXT;
DECLARE UNCANCELUNIQUE_CARDTMPTBLNAME TEXT;
DECLARE UNCANCELACCESS_CARDTMPTBLNAME TEXT;
DECLARE UNCANCELACCESS_CARDTEMPTBLNAME TEXT;
DECLARE UNCANCELTERMINATION_TERMINATIONTMPTBLNAME TEXT;
DECLARE UNCANCELTERMINATION_TEMPTBLNAME TEXT;
DECLARE COUNT_ID INTEGER;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
IF UNCANCEL_CARDTMPTBLNAME IS NOT NULL THEN
    SET @TEMP_UNCANCEL_CARD_NO=(SELECT CONCAT('DROP TABLE IF EXISTS ',UNCANCEL_CARDTMPTBLNAME));
    PREPARE TEMP_UNCANCEL_CARD_NO_STMT FROM @TEMP_UNCANCEL_CARD_NO;
    EXECUTE TEMP_UNCANCEL_CARD_NO_STMT;
END IF;
IF UNCANCELUNIQUE_CARDTMPTBLNAME IS NOT NULL THEN
    SET @TEMP_UNCANCEL_UNIQUE_CARD_NO=(SELECT CONCAT('DROP TABLE IF EXISTS ',UNCANCELUNIQUE_CARDTMPTBLNAME));
    PREPARE TEMP_UNCANCEL_UNIQUE_CARD_NO_STMT FROM @TEMP_UNCANCEL_UNIQUE_CARD_NO;
    EXECUTE TEMP_UNCANCEL_UNIQUE_CARD_NO_STMT;
END IF;
IF UNCANCELACCESS_CARDTMPTBLNAME IS NOT NULL THEN
    SET @TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',UNCANCELACCESS_CARDTMPTBLNAME));
    PREPARE TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS_STMT FROM @TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS;
    EXECUTE TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS_STMT;
END IF;
IF UNCANCELTERMINATION_TERMINATIONTMPTBLNAME IS NOT NULL THEN
    SET @TEMP_UNCANCEL_CUSTOMER_TERMINATION_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME));
    PREPARE TEMP_UNCANCEL_CUSTOMER_TERMINATION_DETAILS_STMT FROM @TEMP_UNCANCEL_CUSTOMER_TERMINATION_DETAILS;
    EXECUTE TEMP_UNCANCEL_CUSTOMER_TERMINATION_DETAILS_STMT;
END IF;
SET UNCANCEL_FLAG=0;
END;
START TRANSACTION;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);
SET UNCANCEL_CARDTEMPTBLNAME=(SELECT CONCAT('TEMP_UNCANCEL_CARD_NO','_',SYSDATE()));
SET UNCANCEL_CARDTEMPTBLNAME=(SELECT REPLACE(UNCANCEL_CARDTEMPTBLNAME,' ',''));
SET UNCANCEL_CARDTEMPTBLNAME=(SELECT REPLACE(UNCANCEL_CARDTEMPTBLNAME,'-',''));
SET UNCANCEL_CARDTEMPTBLNAME=(SELECT REPLACE(UNCANCEL_CARDTEMPTBLNAME,':',''));
SET UNCANCEL_CARDTMPTBLNAME=(SELECT CONCAT(UNCANCEL_CARDTEMPTBLNAME,'_',USERSTAMP_ID)); 
SET @TEMP_CREATEUNCANCEL_CARD_NO=(SELECT CONCAT('CREATE TABLE ',UNCANCEL_CARDTMPTBLNAME,'(ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,UASD_ID INTEGER NULL)'));
PREPARE TEMP_CREATEUNCANCEL_CARD_NO_STMT FROM @TEMP_CREATEUNCANCEL_CARD_NO;
EXECUTE TEMP_CREATEUNCANCEL_CARD_NO_STMT;
SET @TEMP_INSERTUNCANCEL_CARD_NO=(SELECT CONCAT('INSERT INTO ',UNCANCEL_CARDTMPTBLNAME,'(UASD_ID)SELECT UASD_ID FROM  CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=',CUSTOMERID,' AND CED_REC_VER>=',RECORD_VERSION));
PREPARE TEMP_INSERTUNCANCEL_CARD_NO_STMT FROM @TEMP_INSERTUNCANCEL_CARD_NO;
EXECUTE TEMP_INSERTUNCANCEL_CARD_NO_STMT;
SET UNCANCELUNIQUE_CARDTEMPTBLNAME=(SELECT CONCAT('TEMP_UNCANCEL_UNIQUE_CARD_NO','_',SYSDATE()));
SET UNCANCELUNIQUE_CARDTEMPTBLNAME=(SELECT REPLACE(UNCANCELUNIQUE_CARDTEMPTBLNAME,' ',''));
SET UNCANCELUNIQUE_CARDTEMPTBLNAME=(SELECT REPLACE(UNCANCELUNIQUE_CARDTEMPTBLNAME,'-',''));
SET UNCANCELUNIQUE_CARDTEMPTBLNAME=(SELECT REPLACE(UNCANCELUNIQUE_CARDTEMPTBLNAME,':',''));
SET UNCANCELUNIQUE_CARDTMPTBLNAME=(SELECT CONCAT(UNCANCELUNIQUE_CARDTEMPTBLNAME,'_',USERSTAMP_ID)); 
SET @TEMP_CREATEUNCANCEL_UNIQUE_CARD_NO=(SELECT CONCAT('CREATE TABLE ',UNCANCELUNIQUE_CARDTMPTBLNAME,'(ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,UASD_ID INTEGER NOT NULL)'));
PREPARE TEMP_CREATEUNCANCEL_UNIQUE_CARD_NO_STMT FROM @TEMP_CREATEUNCANCEL_UNIQUE_CARD_NO;
EXECUTE TEMP_CREATEUNCANCEL_UNIQUE_CARD_NO_STMT; 
SET @TEMP_INSERTUNCANCEL_UNIQUE_CARD_NO=(SELECT CONCAT('INSERT INTO ',UNCANCELUNIQUE_CARDTMPTBLNAME,'(UASD_ID)SELECT DISTINCT UASD_ID FROM ',UNCANCEL_CARDTMPTBLNAME,' WHERE UASD_ID IS NOT NULL'));
PREPARE TEMP_INSERTUNCANCEL_UNIQUE_CARD_NO_STMT FROM @TEMP_INSERTUNCANCEL_UNIQUE_CARD_NO;
EXECUTE TEMP_INSERTUNCANCEL_UNIQUE_CARD_NO_STMT;  
SET @TEMP_MIN_CARD_ID=(SELECT CONCAT('SELECT MIN(ID) INTO @TEMPMINCARDID FROM ',UNCANCELUNIQUE_CARDTMPTBLNAME));
PREPARE TEMP_MIN_CARD_ID_STMT FROM @TEMP_MIN_CARD_ID;
EXECUTE TEMP_MIN_CARD_ID_STMT;
SET MIN_CARD_ID=@TEMPMINCARDID; 
SET @TEMP_MAX_CARD_ID=(SELECT CONCAT('SELECT MAX(ID) INTO @TEMPMAXCARDID FROM ',UNCANCELUNIQUE_CARDTMPTBLNAME));
PREPARE TEMP_MAX_CARD_ID_STMT FROM @TEMP_MAX_CARD_ID;
EXECUTE TEMP_MAX_CARD_ID_STMT;
SET MAX_CARD_ID=@TEMPMAXCARDID; 
WHILE(MIN_CARD_ID<=MAX_CARD_ID)DO
SET UNCANCELACCESS_CARDTEMPTBLNAME=(SELECT CONCAT('TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS','_',SYSDATE()));
SET UNCANCELACCESS_CARDTEMPTBLNAME=(SELECT REPLACE(UNCANCELACCESS_CARDTEMPTBLNAME,' ',''));
SET UNCANCELACCESS_CARDTEMPTBLNAME=(SELECT REPLACE(UNCANCELACCESS_CARDTEMPTBLNAME,'-',''));
SET UNCANCELACCESS_CARDTEMPTBLNAME=(SELECT REPLACE(UNCANCELACCESS_CARDTEMPTBLNAME,':',''));
SET UNCANCELACCESS_CARDTMPTBLNAME=(SELECT CONCAT(UNCANCELACCESS_CARDTEMPTBLNAME,'_',USERSTAMP_ID)); 
SET @DROP_QUERY_UNCANCEL=(SELECT CONCAT('DROP TABLE IF EXISTS ',UNCANCELACCESS_CARDTMPTBLNAME));
PREPARE DROP_QUERY_UNCANCEL_STMT FROM @DROP_QUERY_UNCANCEL;
EXECUTE DROP_QUERY_UNCANCEL_STMT;
SET @TEMP_CREATEUNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS=(SELECT CONCAT('CREATE TABLE ',UNCANCELACCESS_CARDTMPTBLNAME,'(CACD_ID    INTEGER NOT NULL ,CUSTOMER_ID INTEGER NOT NULL,UASD_ID INTEGER NOT NULL,ACN_ID INTEGER NULL,CACD_VALID_FROM DATE NOT NULL,CACD_VALID_TILL DATE NULL,CACD_GUEST_CARD CHAR(1) NULL,ULD_ID INT(2) NOT NULL,CACD_TIMESTAMP TIMESTAMP)'));
PREPARE TEMP_CREATEUNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS_STMT FROM @TEMP_CREATEUNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS;
EXECUTE TEMP_CREATEUNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS_STMT;
SET @TICK_UASDID=(SELECT CONCAT('SELECT UASD_ID INTO @UASDID FROM ',UNCANCELUNIQUE_CARDTMPTBLNAME,' WHERE ID=',MIN_CARD_ID));
PREPARE TICK_UASDID_STMT FROM @TICK_UASDID;
EXECUTE TICK_UASDID_STMT;
SET @TEMP_INSERTUNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS=(SELECT CONCAT('INSERT INTO ',UNCANCELACCESS_CARDTMPTBLNAME,'(CACD_ID,CUSTOMER_ID,UASD_ID,ACN_ID,CACD_VALID_FROM,CACD_VALID_TILL,CACD_GUEST_CARD,ULD_ID,CACD_TIMESTAMP)SELECT CACD.CACD_ID,CACD.CUSTOMER_ID,CACD.UASD_ID,CACD.ACN_ID,CACD.CACD_VALID_FROM,CACD.CACD_VALID_TILL,CACD.CACD_GUEST_CARD,CACD.ULD_ID,CACD.CACD_TIMESTAMP FROM CUSTOMER_ACCESS_CARD_DETAILS CACD WHERE   CACD.CUSTOMER_ID =',CUSTOMERID,' AND CACD.UASD_ID=',@UASDID));
PREPARE TEMP_INSERTUNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS_STMT FROM @TEMP_INSERTUNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS;
EXECUTE TEMP_INSERTUNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS_STMT;
SET @TICKCACDGUEST_CARD=(SELECT CONCAT('SELECT CACD_GUEST_CARD INTO @CACDGUESTCARD FROM ',UNCANCELACCESS_CARDTMPTBLNAME));
PREPARE TICKCACDGUESTCARD_STMT FROM @TICKCACDGUEST_CARD;
EXECUTE TICKCACDGUESTCARD_STMT;
SET CACD_GUEST_CARD=@CACDGUESTCARD;
SET @TICKACNID=(SELECT CONCAT('SELECT ACN_ID INTO @ACN_ID FROM ',UNCANCELACCESS_CARDTMPTBLNAME));
PREPARE TICKACNID_STMT FROM @TICKACNID;
EXECUTE TICKACNID_STMT;
IF(@ACN_ID IS NULL)THEN
SET @ACN_ID='NULL';
END IF;
SET @TICK_CACD_VALIDTILL=(SELECT CONCAT('SELECT CACD_VALID_TILL INTO @CACD_VALID_TILL FROM ',UNCANCELACCESS_CARDTMPTBLNAME));
PREPARE TICK_CACD_VALIDTILL_STMT FROM @TICK_CACD_VALIDTILL;
EXECUTE TICK_CACD_VALIDTILL_STMT;
IF(@CACD_VALID_TILL IS NULL)THEN
SET @CACD_VALID_TILL='NULL';
END IF;
IF(CACD_GUEST_CARD IS NULL)THEN
SET CACD_GUEST_CARD='NULL';
END IF;
SET @TICKCACDID=(SELECT CONCAT('SELECT CACD_ID INTO @CACDID FROM  ',UNCANCELACCESS_CARDTMPTBLNAME));
PREPARE TICKCACDID_STMT FROM @TICKCACDID;
EXECUTE TICKCACDID_STMT;
SET @TICKCUSTOMERID=(SELECT CONCAT('SELECT CUSTOMER_ID INTO @TEMPCUSTOMERID FROM ',UNCANCELACCESS_CARDTMPTBLNAME));
PREPARE TICKCUSTOMERID_STMT FROM @TICKCUSTOMERID;
EXECUTE TICKCUSTOMERID_STMT;
SET @TICKUASDID=(SELECT CONCAT('SELECT UASD_ID INTO @UASDID FROM ',UNCANCELACCESS_CARDTMPTBLNAME));
PREPARE TICKUASDID_STMT FROM @TICKUASDID;
EXECUTE TICKUASDID_STMT;
SET @TICKCACDVALIDFROM=(SELECT CONCAT('SELECT CACD_VALID_FROM INTO @CACDVALIDFROM FROM ',UNCANCELACCESS_CARDTMPTBLNAME));
PREPARE TICKCACDVALIDFROM_STMT FROM @TICKCACDVALIDFROM;
EXECUTE TICKCACDVALIDFROM_STMT;
SET @TICKULDID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',UNCANCELACCESS_CARDTMPTBLNAME));
PREPARE TICKULDID_STMT FROM @TICKULDID;
EXECUTE TICKULDID_STMT;
SET @TICKCACDTIMESTAMP=(SELECT CONCAT('SELECT CACD_TIMESTAMP INTO @CACDTIMESTAMP FROM ',UNCANCELACCESS_CARDTMPTBLNAME));
PREPARE TICKCACDTIMESTAMP_STMT FROM @TICKCACDTIMESTAMP;
EXECUTE TICKCACDTIMESTAMP_STMT;
SET TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',@CACDID,',CUSTOMER_ID=',@TEMPCUSTOMERID,',UASD_ID=',@UASDID,',ACN_ID=',@ACN_ID,',CACD_VALID_FROM=',@CACDVALIDFROM,',CACD_VALID_TILL=',@CACD_VALID_TILL,',CACD_GUEST_CARD=',CACD_GUEST_CARD,',ULD_ID=',@ULDID,',CACD_TIMESTAMP=',@CACDTIMESTAMP));
 INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='DELETION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ACCESS_CARD_DETAILS'),TICK_ACCESS_OLD_VALUE,NULL,USERSTAMP_ID,CUSTOMERID);
SET MIN_CARD_ID=MIN_CARD_ID+1;
IF UNCANCELACCESS_CARDTMPTBLNAME IS NOT NULL THEN
    SET @TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',UNCANCELACCESS_CARDTMPTBLNAME));
    PREPARE TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS_STMT FROM @TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS;
    EXECUTE TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS_STMT;
END IF;
END WHILE;
SET MIN_REC_VER = RECORD_VERSION;
SET MAX_REC_VER = (SELECT MAX(CED_REC_VER) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
WHILE(MIN_REC_VER<=MAX_REC_VER)DO
SET CANCEL_DATE = (SELECT CED_CANCEL_DATE FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=MIN_REC_VER);
DELETE FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID IN (SELECT DISTINCT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=MIN_REC_VER)AND CUSTOMER_ID=CUSTOMERID AND CACD_VALID_TILL=CANCEL_DATE;
SET MIN_REC_VER = MIN_REC_VER+1;
END WHILE;
SET UNCANCEL_FLAG=1;
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
UPDATE CUSTOMER_PERSONAL_DETAILS SET CPD_COMMENTS=COMMENTS WHERE CUSTOMER_ID=CUSTOMERID;  
SET UNCANCEL_FLAG=1;
SET UNCANCELTERMINATION_TEMPTBLNAME=(SELECT CONCAT('TEMP_UNCANCEL_CUSTOMER_TERMINATION_DETAILS','_',SYSDATE()));
SET UNCANCELTERMINATION_TEMPTBLNAME=(SELECT REPLACE(UNCANCELTERMINATION_TEMPTBLNAME,' ',''));
SET UNCANCELTERMINATION_TEMPTBLNAME=(SELECT REPLACE(UNCANCELTERMINATION_TEMPTBLNAME,'-',''));
SET UNCANCELTERMINATION_TEMPTBLNAME=(SELECT REPLACE(UNCANCELTERMINATION_TEMPTBLNAME,':',''));
SET UNCANCELTERMINATION_TERMINATIONTMPTBLNAME=(SELECT CONCAT(UNCANCELTERMINATION_TEMPTBLNAME,'_',USERSTAMP_ID)); 
SET @TEMP_CREATEUNCANCEL_CUSTOMER_TERMINATION_DETAILS=(SELECT CONCAT('CREATE TABLE ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,'(ID INTEGER NOT NULL    AUTO_INCREMENT,CLP_ID INTEGER,CUSTOMER_ID INTEGER NOT NULL,CED_REC_VER INTEGER NOT NULL,UASD_ID INTEGER NULL,CLP_STARTDATE DATE NOT NULL,CLP_ENDDATE DATE NOT NULL,CLP_TERMINATE CHAR(1) NULL,CLP_PRETERMINATE_DATE DATE NULL,CLP_GUEST_CARD CHAR(1) NULL,ULD_ID INT(2) NOT NULL,CLP_TIMESTAMP TIMESTAMP,PRIMARY KEY(ID))'));
PREPARE TEMP_CREATEUNCANCEL_CUSTOMER_TERMINATION_DETAILS_STMT FROM @TEMP_CREATEUNCANCEL_CUSTOMER_TERMINATION_DETAILS;
EXECUTE TEMP_CREATEUNCANCEL_CUSTOMER_TERMINATION_DETAILS_STMT;
SET @TEMP_INSERTUNCANCEL_CUSTOMER_TERMINATION_DETAILS=(SELECT CONCAT('INSERT INTO ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,'(CLP_ID,CUSTOMER_ID,CED_REC_VER,UASD_ID,CLP_STARTDATE,CLP_ENDDATE,CLP_TERMINATE,CLP_PRETERMINATE_DATE,CLP_GUEST_CARD,ULD_ID,CLP_TIMESTAMP)SELECT CLP_ID,CUSTOMER_ID,CED_REC_VER,UASD_ID,CLP_STARTDATE,CLP_ENDDATE,CLP_TERMINATE,CLP_PRETERMINATE_DATE,CLP_GUEST_CARD,ULD_ID,CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID = ',CUSTOMERID,' AND CED_REC_VER >= ',RECORD_VERSION,' AND UASD_ID IS NOT NULL'));
PREPARE TEMP_INSERTUNCANCEL_CUSTOMER_TERMINATION_DETAILS_STMT FROM @TEMP_INSERTUNCANCEL_CUSTOMER_TERMINATION_DETAILS;
EXECUTE TEMP_INSERTUNCANCEL_CUSTOMER_TERMINATION_DETAILS_STMT;
SET @TEMP_MIN_ID=(SELECT CONCAT('SELECT MIN(ID) INTO @TEMPMINID FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME));
PREPARE TEMP_MIN_ID_STMT FROM @TEMP_MIN_ID;
EXECUTE TEMP_MIN_ID_STMT;
SET MIN_ID=@TEMPMINID;
SET @TEMP_MAX_ID=(SELECT CONCAT('SELECT MAX(ID) INTO @TEMPMAXID FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME));
PREPARE TEMP_MAX_ID_STMT FROM @TEMP_MAX_ID;
EXECUTE TEMP_MAX_ID_STMT;
SET MAX_ID=@TEMPMAXID;
    WHILE(MIN_ID<=MAX_ID)DO
            SET @TICKGUEST_CARD=(SELECT CONCAT('SELECT CLP_GUEST_CARD INTO @GUESTCARD FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
            PREPARE TICKGUESTCARD_STMT FROM @TICKGUEST_CARD;
            EXECUTE TICKGUESTCARD_STMT;
            SET GUEST_CARD=@GUESTCARD;
            IF(GUEST_CARD IS NULL)THEN
                SET @TICKCARDUASDID=(SELECT CONCAT('SELECT UASD_ID INTO @CARDUASDID FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICKCARDUASDID_STMT FROM @TICKCARDUASDID;
                EXECUTE TICKCARDUASDID_STMT;
                SET @TICKCEDRECVER=(SELECT CONCAT('SELECT CED_REC_VER INTO @CEDRECVER FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICKCEDRECVER_STMT FROM @TICKCEDRECVER;
                EXECUTE TICKCEDRECVER_STMT;
                SET TICK_TERMINATION_OLD_VALUE=(SELECT CONCAT('UASD_ID=',@CARDUASDID,',CED_REC_VER=',@CEDRECVER));
                SET TICK_TERMINATION_NEW_VALUE=(SELECT CONCAT('UASD_ID=NULL'));
                INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_LP_DETAILS'),TICK_TERMINATION_OLD_VALUE,TICK_TERMINATION_NEW_VALUE,USERSTAMP_ID,CUSTOMERID);
            ELSE
                SET @TICK_CLP_TERMINATE=(SELECT CONCAT('SELECT CLP_TERMINATE INTO @CLP_TERMINATE FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICK_CLP_TERMINATE_STMT FROM @TICK_CLP_TERMINATE;
                EXECUTE TICK_CLP_TERMINATE_STMT;
                IF(@CLP_TERMINATE IS NULL)THEN
                    SET @CLP_TERMINATE='NULL';
                END IF;
                SET @TICK_CLP_PRETERMINATE=(SELECT CONCAT('SELECT CLP_PRETERMINATE_DATE INTO @CLP_PRETERMINATE_DATE FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICK_CLP_PRETERMINATE_STMT FROM @TICK_CLP_PRETERMINATE;
                EXECUTE TICK_CLP_PRETERMINATE_STMT;
                IF(@CLP_PRETERMINATE_DATE IS NULL)THEN
                    SET @CLP_PRETERMINATE_DATE='NULL';
                END IF;
                SET @TICK_CLP_GUEST_CARD=(SELECT CONCAT('SELECT CLP_GUEST_CARD INTO @CLP_GUEST_CARD FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICK_CLP_GUEST_CARD_STMT FROM @TICK_CLP_GUEST_CARD;
                EXECUTE TICK_CLP_GUEST_CARD_STMT;
                IF(@CLP_GUEST_CARD IS NULL)THEN
                SET @CLP_GUEST_CARD='NULL';
                END IF;
                SET @TICKCLPID=(SELECT CONCAT('SELECT CLP_ID  INTO @CLPID FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICKCLPID_STMT FROM @TICKCLPID;
                EXECUTE TICKCLPID_STMT;
                SET @TICKCED_REC_VER=(SELECT CONCAT('SELECT CED_REC_VER INTO @CEDRECVER FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICKCED_REC_VER_STMT FROM @TICKCED_REC_VER;
                EXECUTE TICKCED_REC_VER_STMT;
                SET @TICKUASD_ID=(SELECT CONCAT('SELECT UASD_ID INTO @UASDID FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICKUASD_ID_STMT FROM @TICKUASD_ID;
                EXECUTE TICKUASD_ID_STMT;
                SET @TICKCLPSTARTDATE=(SELECT CONCAT('SELECT CLP_STARTDATE INTO @CLPSTARTDATE FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICKCLPSTARTDATE_STMT FROM @TICKCLPSTARTDATE;
                EXECUTE TICKCLPSTARTDATE_STMT;
                SET @TICKCLPENDDATE=(SELECT CONCAT('SELECT CLP_ENDDATE INTO @CLPENDDATE FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICKCLPENDDATE_STMT FROM @TICKCLPENDDATE;
                EXECUTE TICKCLPENDDATE_STMT;
                SET @TICKCLPTIMESTAMP=(SELECT CONCAT('SELECT CLP_TIMESTAMP INTO @CLPTIMESTAMP FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICKCLPTIMESTAMP_STMT FROM @TICKCLPTIMESTAMP;
                EXECUTE TICKCLPTIMESTAMP_STMT;
                SET @TICKULD_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULD_ID FROM ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME,' WHERE ID=',MIN_ID));
                PREPARE TICKULD_ID_STMT FROM @TICKULD_ID;
                EXECUTE TICKULD_ID_STMT;
                SET TICK_TERMINATION_OLD_VALUE=(SELECT CONCAT('CLP_ID=',@CLPID ,',CED_REC_VER=',@CEDRECVER,',UASD_ID=',@UASDID,',CLP_STARTDATE=',@CLPSTARTDATE,',CLP_ENDDATE=',@CLPENDDATE,',CLP_TERMINATE=',@CLP_TERMINATE,'CLP_PRETERMINATE_DATE=',@CLP_PRETERMINATE_DATE,',CLP_GUEST_CARD=',@CLP_GUEST_CARD,',ULD_ID=',@ULD_ID,',CLP_TIMESTAMP=',@CLPTIMESTAMP));
                INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='DELETION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_LP_DETAILS'),TICK_TERMINATION_OLD_VALUE,NULL,USERSTAMP_ID,CUSTOMERID);
            END IF;
    SET MIN_ID=MIN_ID+1;
END WHILE;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID = null , ULD_ID = USERSTAMP_ID WHERE CUSTOMER_ID = CUSTOMERID AND CED_REC_VER >= RECORD_VERSION AND CLP_GUEST_CARD IS NULL; 
SET UNCANCEL_FLAG=1;
DELETE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID = CUSTOMERID AND CED_REC_VER >= RECORD_VERSION AND CLP_GUEST_CARD IS NOT NULL;  
SET UNCANCEL_FLAG=1;
SET TEMP_RECVER_LPQ = RECVER_LPQ;
SET REC_VERSION_LENGTH = 1;
    loop_label : LOOP
        SET REC_VERSION_POSITION=(SELECT LOCATE(',&',TEMP_RECVER_LPQ,REC_VERSION_LENGTH));
        SET REC_VERSION = (SELECT CAST((SELECT SUBSTRING(TEMP_RECVER_LPQ,REC_VERSION_LENGTH,1)) AS UNSIGNED INTEGER));
        SET TEMP_RECVER_LPQ = (SELECT SUBSTRING(TEMP_RECVER_LPQ,REC_VERSION_POSITION+2));
        SET LEASE_PERIOD_POSITION = (SELECT LOCATE(',&',TEMP_RECVER_LPQ,REC_VERSION_LENGTH));
        SET LEASE_PERIOD= (SELECT SUBSTRING(TEMP_RECVER_LPQ,REC_VERSION_LENGTH,LEASE_PERIOD_POSITION-1));
        SET TEMP_RECVER_LPQ = (SELECT SUBSTRING(TEMP_RECVER_LPQ,LEASE_PERIOD_POSITION+2));
        SET QUARTERS_POSITION = (SELECT LOCATE(',&',TEMP_RECVER_LPQ,REC_VERSION_LENGTH));
        IF (QUARTERS_POSITION=0) THEN
            SET QUARTERS = TEMP_RECVER_LPQ;
        ELSE
            SET QUARTERS = (SELECT CAST((SELECT SUBSTRING(TEMP_RECVER_LPQ,REC_VERSION_LENGTH,QUARTERS_POSITION-1))AS DECIMAL(5,2)));
        END IF;
        SET TEMP_RECVER_LPQ = (SELECT SUBSTRING(TEMP_RECVER_LPQ,QUARTERS_POSITION+2));
    	SET CEDID=(SELECT CED_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=REC_VERSION);
        SET OLD_CANCEL_DATE=(SELECT CED_CANCEL_DATE FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=REC_VERSION);
        SET TICK_ENTRY_DETAILS_OLD_VALUE=(SELECT CONCAT('CED_ID=',CEDID,',CED_CANCEL_DATE=',OLD_CANCEL_DATE,',CED_LEASE_PERIOD=NULL',',CED_QUARTERS=NULL'));
        SET TICK_ENTRY_DETAILS_NEW_VALUE=(SELECT CONCAT('CED_CANCEL_DATE=NULL',',CED_LEASE_PERIOD=',LEASE_PERIOD,',CED_QUARTERS=',QUARTERS));
        INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ENTRY_DETAILS'),TICK_ENTRY_DETAILS_OLD_VALUE,TICK_ENTRY_DETAILS_NEW_VALUE,USERSTAMP_ID,CUSTOMERID);
         UPDATE CUSTOMER_ENTRY_DETAILS SET  CED_LEASE_PERIOD = LEASE_PERIOD , CED_CANCEL_DATE = NULL  ,
        CED_QUARTERS = QUARTERS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=REC_VERSION; 
        SET UNCANCEL_FLAG=1; 
        IF QUARTERS_POSITION<=0 THEN
            LEAVE  loop_label;
        END IF;
    END LOOP;
IF UNCANCEL_CARDTMPTBLNAME IS NOT NULL THEN
    SET @TEMP_UNCANCEL_CARD_NO=(SELECT CONCAT('DROP TABLE IF EXISTS ',UNCANCEL_CARDTMPTBLNAME));
    PREPARE TEMP_UNCANCEL_CARD_NO_STMT FROM @TEMP_UNCANCEL_CARD_NO;
    EXECUTE TEMP_UNCANCEL_CARD_NO_STMT;
END IF;
IF UNCANCELUNIQUE_CARDTMPTBLNAME IS NOT NULL THEN
    SET @TEMP_UNCANCEL_UNIQUE_CARD_NO=(SELECT CONCAT('DROP TABLE IF EXISTS ',UNCANCELUNIQUE_CARDTMPTBLNAME));
    PREPARE TEMP_UNCANCEL_UNIQUE_CARD_NO_STMT FROM @TEMP_UNCANCEL_UNIQUE_CARD_NO;
    EXECUTE TEMP_UNCANCEL_UNIQUE_CARD_NO_STMT;
END IF;
IF UNCANCELACCESS_CARDTMPTBLNAME IS NOT NULL THEN
    SET @TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',UNCANCELACCESS_CARDTMPTBLNAME));
    PREPARE TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS_STMT FROM @TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS;
    EXECUTE TEMP_UNCANCEL_CUSTOMER_ACCESS_CARD_DETAILS_STMT;
END IF;
IF UNCANCELTERMINATION_TERMINATIONTMPTBLNAME IS NOT NULL THEN
    SET @TEMP_UNCANCEL_CUSTOMER_TERMINATION_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',UNCANCELTERMINATION_TERMINATIONTMPTBLNAME));
    PREPARE TEMP_UNCANCEL_CUSTOMER_TERMINATION_DETAILS_STMT FROM @TEMP_UNCANCEL_CUSTOMER_TERMINATION_DETAILS;
    EXECUTE TEMP_UNCANCEL_CUSTOMER_TERMINATION_DETAILS_STMT;
END IF;
 COMMIT;
END;