DROP PROCEDURE IF EXISTS SP_CUSTOMER_DELETE_LI_TING_KUAN_EVAN_481;
CREATE PROCEDURE SP_CUSTOMER_DELETE_LI_TING_KUAN_EVAN_481(
IN FILENAME TEXT,
IN USERSTAMP VARCHAR(50),
OUT SUCCESS_MESSAGE TEXT)
BEGIN
	DECLARE FAILURE_ECN_DATA TEXT;
	DECLARE FAIL_ECNDATA TEXT;
    DECLARE SUCCESS_ECNDATA TEXT;
	DECLARE FAILURE_ECNDATA TEXT;
	DECLARE SUCCESSECNDATA TEXT;
	DECLARE FAILUREECNDATA TEXT;
	DECLARE PATCHFILENAME VARCHAR(100);
	DECLARE PHSTATUS TINYINT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK;
		INSERT INTO PATCH_HISTORY(PO_ID,PH_FILE_NAME,PH_STATUS,ULD_ID) VALUES (1,FILENAME,0,(SELECT ULD_ID 
		FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		SET SUCCESS_MESSAGE = FAIL_ECNDATA;
	END;
	START TRANSACTION;
	SET FOREIGN_KEY_CHECKS = 0;
	SET SUCCESS_ECNDATA =  (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=469);
	SET FAILURE_ECNDATA =  (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=470);
	SET FAILURE_ECN_DATA = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=473);
	SET SUCCESSECNDATA = (SELECT REPLACE(SUCCESS_ECNDATA,'[FILENAME]',FILENAME));
	SET FAILUREECNDATA = (SELECT REPLACE(FAILURE_ECNDATA,'[FILENAME]',FILENAME));
	SET FAIL_ECNDATA = (SELECT REPLACE(FAILURE_ECN_DATA,'[FILENAME]',FILENAME));
	IF EXISTS(SELECT PH_FILE_NAME FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME AND PH_STATUS = 1) THEN
		SET SUCCESS_MESSAGE = FAILUREECNDATA;
	END IF;
	SET PATCHFILENAME = (SELECT PH_FILE_NAME FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME);
	SET PHSTATUS = (SELECT PH_STATUS FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME AND PH_STATUS = 0);
	IF ((PATCHFILENAME IS NOT NULL) AND (PHSTATUS = 0)) OR (PATCHFILENAME IS NULL)THEN
		INSERT INTO TICKLER_HISTORY (TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)
		VALUES (1,481,10,'CED_ID=838,CED_PRETERMINATE=X','CED_PRETERMINATE=NULL',(SELECT ULD_ID FROM 
		USER_LOGIN_DETAILS WHERE ULD_LOGINID = USERSTAMP));
		UPDATE CUSTOMER_ENTRY_DETAILS SET CED_PRETERMINATE = NULL WHERE CED_ID = 838;
		CALL SP_SINGLE_TABLE_ROW_DELETION(10,921,USERSTAMP,@DELETION_FLAG);
		CALL SP_SINGLE_TABLE_ROW_DELETION(10,922,USERSTAMP,@DELETION_FLAG);
		CALL SP_SINGLE_TABLE_ROW_DELETION(12,2881,USERSTAMP,@DELETION_FLAG);
		CALL SP_SINGLE_TABLE_ROW_DELETION(12,2882,USERSTAMP,@DELETION_FLAG);
		CALL SP_SINGLE_TABLE_ROW_DELETION(12,2883,USERSTAMP,@DELETION_FLAG);
		CALL SP_SINGLE_TABLE_ROW_DELETION(12,2884,USERSTAMP,@DELETION_FLAG);
		CALL SP_SINGLE_TABLE_ROW_DELETION(12,2885,USERSTAMP,@DELETION_FLAG);
		CALL SP_SINGLE_TABLE_ROW_DELETION(12,2886,USERSTAMP,@DELETION_FLAG);
		CALL SP_SINGLE_TABLE_ROW_DELETION(12,2887,USERSTAMP,@DELETION_FLAG);
		CALL SP_SINGLE_TABLE_ROW_DELETION(12,2888,USERSTAMP,@DELETION_FLAG);
		INSERT INTO TICKLER_HISTORY (TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)
		VALUES (1,481,13,'CACD_ID=497,CACD_VALID_TILL=2015-02-01','CACD_VALID_TILL=2014-12-12',(SELECT ULD_ID 
		FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID = USERSTAMP));
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET CACD_VALID_TILL = '2014-12-12' , CACD_TIMESTAMP = CACD_TIMESTAMP WHERE CACD_ID = 497;
		INSERT INTO TICKLER_HISTORY (TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)
		VALUES (1,481,14,'CLP_ID=838,CLP_PRETERMINATE_DATE=NULL,CLP_TERMINATE=NULL','CLP_PRETERMINATE_DATE=2014-12-12,CLP_TERMINATE=X',(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID = USERSTAMP));
		UPDATE CUSTOMER_LP_DETAILS SET CLP_PRETERMINATE_DATE='2014-12-12', CLP_TERMINATE='X', CLP_TIMESTAMP=CLP_TIMESTAMP WHERE CLP_ID=838;
		CALL SP_SINGLE_TABLE_ROW_DELETION(14,991,USERSTAMP,@DELETION_FLAG);
		CALL SP_SINGLE_TABLE_ROW_DELETION(14,992,USERSTAMP,@DELETION_FLAG);
		INSERT INTO TICKLER_HISTORY (TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)
		VALUES (1,481,15,'CPD_ID=476,CPD_COMMENTS=SHIFTED TO 3821 UNIT 1 FROM 5501- 02/01/2015

ACTUAL END DATE IS 31/01/2016   13176-******* AUTO TERMINATED ON  03-01-2015 01:00:53 ***************',
'CPD_COMMENTS=SHIFTED TO 3821 UNIT 1 FROM 5501- 02/01/2015

ACTUAL END DATE IS 31/01/2016',(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID = USERSTAMP));

		UPDATE CUSTOMER_PERSONAL_DETAILS SET CPD_COMMENTS = 'SHIFTED TO 3821 UNIT 1 FROM 5501- 02/01/2015

ACTUAL END DATE IS 31/01/2016' WHERE CPD_ID = 476;
		INSERT INTO PATCH_HISTORY(PO_ID,PH_FILE_NAME,PH_STATUS,ULD_ID) VALUES (5,FILENAME,1,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		SET SUCCESS_MESSAGE = SUCCESSECNDATA;	
	END IF;	
	COMMIT;
END;
CALL SP_CUSTOMER_DELETE_LI_TING_KUAN_EVAN_481(FILENAME,USERSTAMP,@SUCCESS_MESSAGE);