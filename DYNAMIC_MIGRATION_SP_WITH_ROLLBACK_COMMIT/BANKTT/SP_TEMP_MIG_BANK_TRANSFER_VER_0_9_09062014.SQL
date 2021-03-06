-- VERSION 0.9 -- SDATE:09-06-2014 -- EDATE:09-06-2014 -- ISSUE:566  -- DESC:IMPLEMENTING COMMIT AND ROLLBACK -- DONE BY:BHAVANI.R
--VERSION:0.8 --SDATE:21/05/2014 --EDATE:21/05/2014 --ISSUE --DESC:CHANGED TIME STAMP DATA TYPE (VARCHAR(50) TO TIMESTAMP) --DONEBY:RL
-- VERSION 0.7 -- SDATE:05-04-2014 -- EDATE:05-04-2014 -- ISSUE:802  -- DESC:CHANGING SP SP_TEMP_MIG_BANK_TRANSFER FOR WRONG MIGRATION OF TIMESTAMP -- DONE BY:BHAVANI.R
-- VERSION 0.6 -- SDATE:26-03-2014 -- EDATE:27-03-2014 -- ISSUE:765  -- COMMENT NO:#8 -- DESC:CHANGING SP SP_TEMP_MIG_BANK_TRANSFER AS PREPARED STATEMENTS FOR DYNAMIC RUNNING PURPOSE -- DONE BY:BHAVANI.R
-- version:0.5 -- sdate:17/03/2014 -- edate:17/03/2014 -- issue:765 --desc:droped temp table --doneby:RL
-- version:0.4 --sdate:25/02/2014 --edate:26/02/2014 --issue:750 COMMENT :#30 -desc:CHANGED TIMESTAMP AS SOURCE TIMESTAMP & ALTERED USERSTAMP COLUMN AS ULD_ID done by:dhivya
DROP PROCEDURE IF EXISTS SP_TEMP_MIG_BANK_TRANSFER;
CREATE PROCEDURE SP_TEMP_MIG_BANK_TRANSFER(IN SOURCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50),IN MIGUSERSTAMP VARCHAR(50))
BEGIN
DECLARE START_TIME TIME;
DECLARE END_TIME TIME;
DECLARE DURATION TIME;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
  ROLLBACK;
  END;
  START TRANSACTION;
  SET START_TIME=(SELECT CURTIME());
-- STATEMENT FOR CHANGING MIGUSERSTAMP AS ULD_ID 
	SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',MIGUSERSTAMP,'"'));
	PREPARE LOGINID FROM @LOGIN_ID;
	EXECUTE LOGINID;

-- STATEMENT FOR DROPPING BANK_TRANSFER_MODELS 
	SET @DROP_BANK_TRANSFER_MODELS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.BANK_TRANSFER_MODELS'));
	PREPARE DBANKTRANSFERMODELS FROM @DROP_BANK_TRANSFER_MODELS;
    EXECUTE DBANKTRANSFERMODELS;
	
-- STATEMENT FOR CREATING USER_MENU_DETAILS
    SET @CREATE_BANK_TRANSFER_MODELS=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.BANK_TRANSFER_MODELS( 
	BTM_ID INTEGER NOT NULL	AUTO_INCREMENT,
	BTM_DATA VARCHAR(50) NOT NULL,
	BTM_OBSOLETE CHAR(1),
	ULD_ID INT(2) NOT NULL,	
	BTM_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(BTM_ID),
	FOREIGN KEY(ULD_ID) REFERENCES USER_LOGIN_DETAILS(ULD_ID))'));
    PREPARE CBANKTRANSFERMODELS FROM @CREATE_BANK_TRANSFER_MODELS;
    EXECUTE CBANKTRANSFERMODELS;
	
-- INSERT QUERY FOR BANK_TRANSFER_MODELS

    SET @INSERT_BANK_TRANSFER_MODELS=( SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.BANK_TRANSFER_MODELS (ULD_ID,BTM_ID, BTM_DATA,BTM_TIMESTAMP) SELECT ULD.ULD_ID,M.BTM_ID,M.BTM_DATA,M.BTM_TIMESTAMP FROM ',SOURCESCHEMA,'.MIG_BANK_TRANSFER_MODELS M,',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE ULD.ULD_LOGINID=M.BTM_USERSTAMP'));
    PREPARE INSERTBANKTRANSFERMODELS FROM @INSERT_BANK_TRANSFER_MODELS; 
    EXECUTE INSERTBANKTRANSFERMODELS;

    SET END_TIME=(SELECT CURTIME());
    SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
    SET @COUNT_SCDB_BTM=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SCDB_BTM FROM ',SOURCESCHEMA,'.MIG_BANK_TRANSFER_MODELS'));
	PREPARE COUNTSCDBBTM FROM @COUNT_SCDB_BTM;
	EXECUTE COUNTSCDBBTM;
	
	SET @COUNT_SPLITTED_BTM=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITTED_BTM FROM ',DESTINATIONSCHEMA,'.BANK_TRANSFER_MODELS'));
	PREPARE COUNTSPLITTEDBTM FROM @COUNT_SPLITTED_BTM;
	EXECUTE COUNTSPLITTEDBTM;

    SET @REJECTION_COUNT=(@COUNT_SCDB_BTM-@COUNT_SPLITTED_BTM);

    UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_SCDB_BTM WHERE PREASP_DATA='BANK_TRANSFER_MODELS';
	
-- QUERY FOR INSERT VALUES IN POST_AUDIT_HISTORY TABLE

    SET @POSTAPIDSTMT=(SELECT CONCAT('SELECT POSTAP_ID INTO @POSTAPID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA=',"'BANK_TRANSFER_MODELS'"));
    PREPARE POSTAPSTMT FROM @POSTAPIDSTMT;
    EXECUTE POSTAPSTMT;
	
    SET @PREASPSTMT=(SELECT CONCAT('SELECT PREASP_ID INTO @PREASPID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA=',"'BANK_TRANSFER_MODELS'"));
    PREPARE PREASPIDSTMT FROM @PREASPSTMT;
    EXECUTE PREASPIDSTMT;

    SET @PREAMPSTMT=(SELECT CONCAT('SELECT PREAMP_ID INTO @PREAMPID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA=',"'BANKTT'"));
    PREPARE PREAMPIDSTMT FROM @PREAMPSTMT;
    EXECUTE PREAMPIDSTMT;
    SET @DUR=DURATION;
      SET FOREIGN_KEY_CHECKS=0;
	
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES(@POSTAPID,@COUNT_SPLITTED_BTM,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
  

	
-- STATEMENT FOR DROPPING TEMP_MIG_BANK_TRANSFER 
	SET @DROP_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER'));
	PREPARE DTEMPMIGBANKTRANSFER FROM @DROP_TEMP_MIG_BANK_TRANSFER;
    EXECUTE DTEMPMIGBANKTRANSFER;		
-- CREATING TEMP TABLE FOR MIG_BANK_TRANSFER
    SET @CREATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER(BT_SNO INT(11) NOT NULL	AUTO_INCREMENT,BT_DATE DATE ,BT_TRANSACTION_TYPE VARCHAR(5),BT_ACC_NAME VARCHAR(40),BT_ACC_NO VARCHAR(25),BT_AMOUNT DECIMAL(7,2), BT_UNIT VARCHAR(7),BT_CUSTOMER VARCHAR(50),BT_BANK_CODE VARCHAR(4),BT_BRANCH_CODE VARCHAR(3),BT_BANK_ADDRESS TEXT, BT_SWIFT_CODE VARCHAR(12),BTCT_ID INT(11),BT_CUST_REF VARCHAR(200),BT_INV_DETAILS LONGTEXT,BT_DEBITED_ON DATE,BTCB_ID INT(11),BT_COMMENTS LONGTEXT,BTS_ID INT(11),BT_USER_STAMP VARCHAR(50),	BT_TIME_STAMP VARCHAR(50) NOT NULL ,PRIMARY KEY(BT_SNO))'));
    PREPARE CTEMPMIGBANKTRANSFER FROM @CREATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE CTEMPMIGBANKTRANSFER;
-- INSERT QUERY FOR TEMP_MIG_BANK_TRANSFER

    SET @INSERT_TEMP_MIG_BANK_TRANSFER=( SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER(SELECT * FROM ',SOURCESCHEMA,'.MIG_BANK_TRANSFER)'));
    PREPARE INSERTTEMPMIGBANKTRANSFER FROM @INSERT_TEMP_MIG_BANK_TRANSFER; 
    EXECUTE INSERTTEMPMIGBANKTRANSFER;
	

-- THESE CUSTOMERS R UNIT OWNERS
    SET @DELETE_TEMP_MIG_BANK_TRANSFER=( SELECT CONCAT('DELETE FROM ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER WHERE BT_CUSTOMER='"'MAUNG KHIN MAUNG WIN'"' OR BT_CUSTOMER='"'RIN NAN YOONG'"' OR BT_CUSTOMER='"'LEONG KIAN SHIANG'"));
    PREPARE DELETETEMPMIGBANKTRANSFER FROM @DELETE_TEMP_MIG_BANK_TRANSFER; 
    EXECUTE DELETETEMPMIGBANKTRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'ALI'"' WHERE BT_CUSTOMER='"'Ali Yilmaz'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'HANA'"' WHERE BT_CUSTOMER='"'JOO HANA'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'YANIV'"' WHERE BT_CUSTOMER='"'Yaniv Goder'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'VICKY CULLEN'"' WHERE BT_CUSTOMER='"'YANG MING'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'DAIMLER MARI OGASA'"' WHERE BT_CUSTOMER='"'mari ogasa'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'ZUBIN'"' WHERE BT_CUSTOMER='"'Navin C. Sharma and Pamela Morin'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'SALMA'"' WHERE BT_CUSTOMER='"'SAIMA'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'AKIMA'"' WHERE BT_CUSTOMER='"'AKM PRINCIPAL INVESTMENTS Pte Ltd'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'DAVIS AND OLIVIA'"' WHERE BT_CUSTOMER='"'OLIVIA'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'BENJAMIN'"' WHERE BT_CUSTOMER='"'BENJAMIN AARON GILLENWATER'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'SILVIU BUSU'"' WHERE BT_CUSTOMER='"'ARISTOTEL SILVIU BUSU LUNCAR'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'JUNE WANG'"' WHERE BT_CUSTOMER='"'WANG JUNXIA'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'VALLARINO'"' WHERE BT_CUSTOMER='"'VITTORIO VALLARINO GANCIA'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'LILLIAN WONG'"' WHERE BT_CUSTOMER='"'LILLIAN CHIA LING WANG'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'MAN'"' WHERE BT_CUSTOMER='"'CHAN LAI MAN'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'YOKO'"' WHERE BT_CUSTOMER='"'PLENUS & MK PTE LTD'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'BW FLEET'"' WHERE BT_CUSTOMER='"'BW MARITIME PTE LTD'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'HAITHAM'"' WHERE BT_CUSTOMER='"'HAITHAM A H M ABDULKARIM'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'PONTUS'"' WHERE BT_CUSTOMER='"'SIGHTLINE VISION AB'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'FARHANA'"' WHERE BT_CUSTOMER='"'ALAN ZACHARY ANWAR'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'CATHERINE'"' WHERE BT_CUSTOMER='"'CAITLIN JEAN WONG'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'CHRIS'"' WHERE BT_CUSTOMER='"'CHRIS CHEN'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'ROSALIND CHU'"' WHERE BT_CUSTOMER='"'ROSALIND ANNETT CHU'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'MATTHIAS AND CAITILN TILP'"' WHERE BT_CUSTOMER='"'MATTHIAS AND CAITILN'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'LISA MAHTANI'"' WHERE BT_CUSTOMER='"'LISA'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'CHRISTO WIESE'"' WHERE BT_CUSTOMER='"'CHRISTO'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'ANDREJ DOBES'"' WHERE BT_CUSTOMER='"'ANDREJ'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'ALEXANDER BRUNOW'"' WHERE BT_CUSTOMER='"'ALEX BRUNOW'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'RICHARD  WAINWRIGHT'"' WHERE BT_CUSTOMER='"'RICHARD WAINWRIGHT'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'CIARON PATRICK MCKINLEY'"' WHERE BT_CUSTOMER='"'CIARON'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'EASON FANG ENHUA'"' WHERE BT_CUSTOMER='"'EASON'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'VENN ILIEV SALTIROV'"' WHERE BT_CUSTOMER='"'VENN'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'SHUBHAM CHANDRA'"' WHERE BT_CUSTOMER='"'SHUBHAM CHANDHRA'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;
	
	SET @UPDATE_TEMP_MIG_BANK_TRANSFER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_MIG_BANK_TRANSFER SET BT_CUSTOMER='"'ELAINE PATERSON'"' WHERE BT_CUSTOMER='"'ELLEN PATERSON'"));
    PREPARE UPTEMP_MIG_BANK_TRANSFER FROM @UPDATE_TEMP_MIG_BANK_TRANSFER;
    EXECUTE UPTEMP_MIG_BANK_TRANSFER;

-- STATEMENT FOR DROPPING TEMP_BANK_TRANSFER 
	SET @DROP_TEMP_BANK_TRANSFER=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_BANK_TRANSFER'));
	PREPARE DTEMPBANKTRANSFER FROM @DROP_TEMP_BANK_TRANSFER;
    EXECUTE DTEMPBANKTRANSFER;

-- STATEMENT FOR CREATING TEMP_BANK_TRANSFER
    SET @CREATE_TEMP_BANK_TRANSFER=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_BANK_TRANSFER( BT_ID INTEGER NOT NULL,BTCT_ID INTEGER NOT NULL, BTCB_ID INTEGER NOT NULL, BTS_ID INTEGER NOT NULL, BTT_ID TEXT NOT NULL,	BT_DATE	DATE NOT NULL,	BT_AMOUNT DECIMAL(7,2) NOT NULL,	BT_ACC_NAME	VARCHAR(40),BT_ACC_NO VARCHAR(25),BT_BANK_CODE VARCHAR(4),BT_BRANCH_CODE VARCHAR(3),BT_BANK_ADDRESS VARCHAR(250),BT_SWIFT_CODE VARCHAR(12),BT_CUST_REF	VARCHAR(200),BT_INV_DETAILS TEXT,BT_DEBITED_ON DATE,BT_COMMENTS	TEXT,ULD_ID INTEGER(2) NOT NULL,BT_TIMESTAMP VARCHAR(50) NOT NULL ,PRIMARY KEY(BT_ID))'));
    PREPARE CTEMPBANKTRANSFER FROM @CREATE_TEMP_BANK_TRANSFER;
    EXECUTE CTEMPBANKTRANSFER;
	
	COMMIT;
END;

CALL SP_TEMP_MIG_BANK_TRANSFER('SOURCE_SCHEMA','DESTINATION_SCHEMA','EXPATSINTEGRATED@GMAIL.COM');