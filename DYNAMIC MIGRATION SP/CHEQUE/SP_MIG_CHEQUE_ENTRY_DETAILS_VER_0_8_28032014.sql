-- VERSION:0.8 -- sdate:28/03/2014 -- edate:28/03/2014 -- issue:765 --COMMENT:#8 --desc:CHANGING INSERTION IN POSTAUDITY HISTORY --doneby:BHAVANI.R
-- version:0.7 -- sdate:19/03/2014 -- edate:19/03/2014 -- issue:765 --COMMENT:#8 --desc:CHANGING SP AS PREPARD STATEMENTS FOR DYNAMIC RUNNING PURPOSE --doneby:BHAVANI.R
-- version:0.6 -- sdate:17/03/2014 -- edate:17/03/2014 -- issue:765 --desc:droped temp table --doneby:RL
--VERSION 0.5--sdate:04/03/2014 --edate:04/03/2014--CHANGING header datatype as int(2)- DONE BY SAFI
--VERSION 0.4--sdate:25/02/2014 --edate:25/02/2014--CHANGING USAERSTAMP TO ULD_ID- DONE BY SAFI
--VERSION 0.3--sdate:20/02/2014 --edate:21/02/2014--IMPLEMENT AUDIT QUREY - DONE BY SAFI
--version:0.2 --sdate:31/01/2014 --edate:31/01/2014 --issue:522 --desc:added PUBLIC_HOLIDAY,STORED_PROCEDURE_PROFILE,VIEW_PROFILE,PLATFORM_MANAGEMENT table insert quereis --doneby:RL
--version:0.1 --sdate:23/01/2014 --edate:23/01/2014 --desc:all user rights table insert queries --doneby:RL
DROP PROCEDURE IF EXISTS SP_MIG_CHEQUE_ENTRY_DETAILS;
CREATE PROCEDURE SP_MIG_CHEQUE_ENTRY_DETAILS(IN SOURCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50),IN USER_STAMP VARCHAR(50))
BEGIN
DECLARE START_TIME TIME;
DECLARE END_TIME TIME;
DECLARE DURATION TIME;

-- STATEMENT FOR CHANGING USERSTAMP AS ULD_ID 
	SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',USER_STAMP,'"'));
	PREPARE LOGINID FROM @LOGIN_ID;
	EXECUTE LOGINID;

SET START_TIME=(SELECT CURTIME());

-- STATEMENT FOR DROPPING CHEQUE_ENTRY_DETAILS    
	SET @DROP_CHEQUE_ENTRY_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.CHEQUE_ENTRY_DETAILS'));
	PREPARE DCHEQUEENTRYDETAILS FROM @DROP_CHEQUE_ENTRY_DETAILS;
    EXECUTE DCHEQUEENTRYDETAILS;

-- STATEMENT FOR  CREATING CHEQUE_ENTRY_DETAILS
    SET @CREATE_CHEQUE_ENTRY_DETAILS=(SELECT CONCAT('CREATE TABLE  ',DESTINATIONSCHEMA,'.CHEQUE_ENTRY_DETAILS(CHEQUE_ID INTEGER NOT NULL AUTO_INCREMENT, CHEQUE_DATE	DATE  NOT NULL,	CHEQUE_TO VARCHAR(100) NOT NULL, CHEQUE_NO INTEGER(6) NOT NULL,	CHEQUE_FOR VARCHAR(100) NOT NULL,	CHEQUE_AMOUNT DECIMAL(7,2) NOT NULL,	CHEQUE_UNIT_NO VARCHAR(25) NULL, BCN_ID INTEGER NOT NULL, CHEQUE_DEBITED_RETURNED_DATE DATE NULL,	CHEQUE_COMMENTS	TEXT NULL, ULD_ID INTEGER(2) NOT NULL,CHEQUE_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY(CHEQUE_ID), FOREIGN KEY(BCN_ID) REFERENCES ',DESTINATIONSCHEMA,'.BANKTT_CONFIGURATION (BCN_ID), FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
    PREPARE CCHEQUEENTRYDETAILS FROM @CREATE_CHEQUE_ENTRY_DETAILS;
    EXECUTE CCHEQUEENTRYDETAILS;
-- STATEMENT FOR  INSERTING VALUES INTO CHEQUE_ENTRY_DETAILS 
    SET @INSERT_CHEQUE_ENTRY_DETAILS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.CHEQUE_ENTRY_DETAILS(CHEQUE_ID, CHEQUE_DATE, CHEQUE_TO, CHEQUE_NO, CHEQUE_FOR, CHEQUE_AMOUNT, CHEQUE_UNIT_NO, BCN_ID, CHEQUE_DEBITED_RETURNED_DATE, CHEQUE_COMMENTS, ULD_ID, CHEQUE_TIMESTAMP)SELECT MCED.CHEQUE_SNO, MCED.CHEQUE_DATE, MCED.CHEQUE_TO, MCED.CHEQUE_NO, MCED.CHEQUE_FOR, MCED.CHEQUE_AMOUNT, MCED.CHEQUE_UNIT_NO, BC.BCN_ID, MCED.CHEQUE_DEBITED_RETURNED_DATE, MCED.CHEQUE_COMMENTS, ULD.ULD_ID, MCED.CHEQUE_TIMESTAMP FROM MIG_CHEQUE_ENTRY_DETAILS MCED, MIG_CHEQUE_STATUS_DETAILS MSC, ',DESTINATIONSCHEMA,'.BANKTT_CONFIGURATION BC, ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE MCED.CS_ID=MSC.CS_ID AND MSC.CS_DATA=BC.BCN_DATA AND MCED.CHEQUE_USERSTAMP=ULD.ULD_LOGINID'));
    PREPARE INSERTCHEQUEENTRYDETAILS FROM @INSERT_CHEQUE_ENTRY_DETAILS;
    EXECUTE INSERTCHEQUEENTRYDETAILS;
    
    SET END_TIME=(SELECT CURTIME());
    SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
-- GETTING THE COUNT FOR SCDB CHEQUE
	SET @COUNT_SCDB_CHEQUE=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SCDB_CHEQUE FROM ',SOURCESCHEMA,'.MIG_CHEQUE_ENTRY_DETAILS'));
	PREPARE COUNTSCDBCHEQUE FROM @COUNT_SCDB_CHEQUE;
	EXECUTE COUNTSCDBCHEQUE;
-- GETTING THE COUNT FOR SPLITTING CHEQUE
    SET @COUNT_SPLITTING_CHEQUE=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITTING_CHEQUE FROM ',DESTINATIONSCHEMA,'.CHEQUE_ENTRY_DETAILS'));
	PREPARE COUNTSPLITTINGCHEQUE FROM @COUNT_SPLITTING_CHEQUE;
	EXECUTE COUNTSPLITTINGCHEQUE;


    SET @REJECTION_COUNT=(@COUNT_SCDB_CHEQUE-@COUNT_SPLITTING_CHEQUE);
-- STATEMENT FOR UPDATING PRE_AUDIT_SUB_PROFILE
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_SCDB_CHEQUE WHERE PREASP_DATA='CHEQUE_ENTRY_DETAILS';
    
-- STATEMENT FOR INSERT INTO POST_AUDIT_HISTORY

    SET @POSTAPIDSTMT=(SELECT CONCAT('SELECT POSTAP_ID INTO @POSTAPID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA=',"'CHEQUE_ENTRY_DETAILS'"));
    PREPARE POSTAPSTMT FROM @POSTAPIDSTMT;
    EXECUTE POSTAPSTMT;
	
    SET @PREASPSTMT=(SELECT CONCAT('SELECT PREASP_ID INTO @PREASPID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA=',"'CHEQUE_ENTRY_DETAILS'"));
    PREPARE PREASPIDSTMT FROM @PREASPSTMT;
    EXECUTE PREASPIDSTMT;

    SET @PREAMPSTMT=(SELECT CONCAT('SELECT PREAMP_ID INTO @PREAMPID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA=',"'CHEQUE'"));
    PREPARE PREAMPIDSTMT FROM @PREAMPSTMT;
    EXECUTE PREAMPIDSTMT;
    SET @DUR=DURATION;
    SET FOREIGN_KEY_CHECKS=0;
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES(@POSTAPID,@COUNT_SPLITTING_CHEQUE,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
   

    END;
    CALL SP_MIG_CHEQUE_ENTRY_DETAILS('TEST_MIG','TEST_MIG','EXPATSINTEGRATED@GMAIL.COM');