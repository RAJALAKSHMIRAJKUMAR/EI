-- VER 2.3 ISSUE:836 COMMENT #52 STARTDATE:22/09/2014 ENDDATE:22/09/2014 DESC:INVENTORY CARD HARD CODED ERROR MSG GET FROM DB details BY DHIVYA.
-- VER 2.2 ISSUE:813 COMMENT #50 STARTDATE:12/08/2014 ENDDATE:25/08/2014 DESC:removed commit ,added autocommit,added msg for the same unit same month extension with payment details BY PUNI.
-- VER 2.1 ISSUE:345 COMMENT #729 STARTDATE:11/07/2014 ENDDATE:11/07/2014 DESC:ADDED ULDID IN CUSTOMER_LP_DETAILS DONE BY:DHIVYA.A
-- VER 2.0 ISSUE:817 COMMENT #139 STARTDATE:21/06/2014 ENDDATE:21/06/2014 DESC:DROPED TEMP TABLES INSIDE ROLL BACK AND COMMIT DONE BY:DHIVYA.A
--version --> 1.9 startdate:14/06/2014 --enddate:14/06/2014--- issueno 738 COMMENT NO:33 -->desc:CHANGES IN SP FOR UPDATING OLD ULD_ID AND TIMESTAMP FOR TICKLER TABLE BY BHAVANI.R
--version --> 1.8 startdate:29/04/2014 --enddate:30/04/2014--- issueno 817 -->desc:changing all temp table as dynamic BY RL
--version --> 1.7 startdate:21/04/2014 --enddate:21/04/2014--- issueno 615 COMMENT NO:67 -->desc:WHILE INSERTING INTO TICKLER FOR REORDERING OF LP IN CUSTOMER LP DETAILS AND CUSTOMER FEE DETAILS, CORRECTED SUBQUERY RETURNS MORE THAN ONE ROW ERROR BY PUNI
--version --> 1.6 startdate:19/04/2014 --enddate:19/04/2014--- issueno 615 COMMENT N0:64 -->desc:CHANGES IN updation of ced_rec_ver for customer fee details,lp details and entry details --done by:Bhavani.R
--version --> 1.5 startdate:18/04/2014 --enddate:18/04/2014--- issueno 615 COMMENT N0:60 -->desc:CHANGES IN TICKLER PART FOR ENTERING PRIMARY KEY FOR CUSTOMER_EXTENSION_SP --done by:Bhavani.R
--version --> 1.4 startdate:15/04/2014 --enddate:16/04/2014--- issueno 345 COMMENT N0:677 -->desc:CREATING TICKLER PART FOR CUSTOMER_EXTENSION_SP --done by:Bhavani.R
--version --> 1.3 startdate:16/04/2014 --enddate:16/04/2014--- issueno 345 -desc:inserted CED_PRETERMINATE FLAG IF CUST PTD IN MIDDLE LP N EXTNDED --done by:PUNI
--version --> 1.2 startdate:01/04/2014 --enddate:01/04/2014--- issueno 345 -->desc:CHECKED IF THE PASSING CARD S INVENTORY OR NOT --done by:RL
--version --> 1.1 startdate:03/04/2014 --enddate:03/04/2014--- issueno 797 commentno:4-->desc:REPLACED TABLENAME AND HEADERNAME by SASIKALA.D
--version --> 1.0 startdate:26/03/2014 --enddate:26/03/2014--- issueno 345 commentno:627-->desc:reordered rec version of the customer-PUNI
--version --> 0.9 startdate:28/02/2014 --enddate:28/02/2014--- issueno 754 commentno:36-->desc:added sub sp to convert userstamp as uld_id done by:Dhivya 
-- version --> 0.8 startdate -->27/02/2014 enddate --> 27/02/2014 description -->REPLACE USERSTAMP TO ULD_ID AND USERSTAM VARCAH TO USERSTAMPINTEGER -BALAJI
-- version --> 0.7 startdate -->19/02/2014 enddate --> 20/02/2014 description --> Implementing flag for success message in SP_CUSTOMER_EXTENSION_INSERT done by:Bhavani.R -->issue:594    comment:#67 
-- version --> 0.6 startdate -->29/01/2014 enddate --> 30/01/2014 description -->UPDATED CUSTOMER ENTRY DETAILS AS PER STIME AND ETIME DATATYPE UPDATION DONE BY:DHIVYA.A -->issue :594 comment:#71
-- version --> 0.5 startdate -->21/11/2013 enddate --> 21/11/2013 description -->removed unexpected condition in customer access card details -->done by:DHIVYA.A-->issue :660
-- version --> 0.4 startdate -->20/11/2013 enddate --> 20/11/2013 description --> added guest card column in customer access card details -->done by:DHIVYA.A-->issue :248-->commentno:110
-- version --> 0.3 startdtae -->06/11/2013 enddate --> 06/11/2013 description --> CARD IS ASSIGNED TO CUSTOMER, EMPLOYEE_DETAILS TABLE RECORD SHLD UPDATE AS NULL IF THAT CARD EXISTS FOR THE EMPLOYEE modified by & changed sp name -->rl -->issue :345 -->commentno: 303
-- version --> 0.2 startdate -->17/09/2013 enddate --> 17/09/2013 description --> added code for delete null rows in company details created by -->CL -->issue :615
-- version --> 0.1 startdate -->23/08/2013 enddate --> 23/08/2013 description --> SP for the customer extension form saving part created by -->CL -->issue :345

DROP PROCEDURE IF EXISTS SP_CUSTOMER_EXTENSION_INSERT;
CREATE PROCEDURE SP_CUSTOMER_EXTENSION_INSERT(
IN EX_CUSTOMER_ID INTEGER,
IN EX_COMPANY_NAME VARCHAR(50),
IN EX_COMPANY_ADDR VARCHAR(50),
IN EX_POSTAL_CODE VARCHAR(6),
IN EX_OFFICE_NO VARCHAR(8),
IN EX_UNIT_NO SMALLINT(4),
IN EX_SAMEUNIT_FLAG CHAR(1),
IN EX_ROOM_TYPE VARCHAR(30),
IN EX_SD_STIME TIME,
IN EX_SD_ETIME TIME,
IN EX_ED_STIME TIME,
IN EX_ED_ETIME TIME,
IN EX_LEASE_PERIOD VARCHAR(30),
IN EX_QUARTERS DECIMAL(5,2),
IN EX_PROCESSING_WAIVED CHAR(1),
IN EX_PRORATED	CHAR(1),
IN EX_NOTICE_PERIOD TINYINT(1),
IN EX_NOTICE_START_DATE DATE,
IN EX_RENT DECIMAL(7,2),
IN EX_DEPOSIT DECIMAL(7,2),
IN EX_PROCESSING_FEE DECIMAL(7,2),
IN EX_AIRCON_FIXED_FEE DECIMAL(7,2),
IN EX_AIRCON_QUARTELY_FEE DECIMAL(7,2),
IN EX_ELECTRICITY_CAP DECIMAL(7,2),
IN EX_CHECKOUT_CLEANING_FEE DECIMAL(7,2),
IN EX_DRYCLEAN_FEE DECIMAL(7,2),
IN EX_CARD_NO TEXT,
IN EX_VALID_FROM DATE,
IN USERSTAMP VARCHAR(50),
IN EX_STARTDATE DATE,
IN EX_ENDDATE DATE,
IN EX_GUEST_CARD TEXT,
IN EX_NATIONALITY TEXT,
IN EX_MOBILE VARCHAR(8),
IN EX_INTL_MOBILE VARCHAR(20),
IN EX_EMAIL VARCHAR(40),
IN EX_PASSPORT_NO VARCHAR(15),
IN EX_PASSPORT_DATE DATE,
IN EX_DOB DATE,
IN EX_EP_NO VARCHAR(15),
IN EX_EP_DATE DATE,
IN EX_COMMENTS TEXT,
IN EX_SAMEAMNTFLAG	CHAR(1),
OUT EX_SUCCESSFLAG TEXT,
OUT TEMP_OUT_EXT_CARNOTBLNAME TEXT,
OUT TEMP_OUT_EXTN_CLPDTLSTTBLNAME TEXT,
OUT TEMP_OUT_EXTN_FEEDTLTBLNAME TEXT,
OUT PAY_CHK_MSG TEXT
)
BEGIN	
	DECLARE ROOM_TYPE_ID INT;
	DECLARE RE_UNIT_ID INT;
	DECLARE REC_VER INT;
	DECLARE TEMP_ACCESS_CARD TEXT;
	DECLARE ACCESS_CARD_NO INTEGER(7);
	DECLARE ACCESS_POSITION INTEGER;
	DECLARE ACCESS_LOCATION INTEGER;
	DECLARE ACCESS_LENGTH INTEGER;
	DECLARE GUEST_ACCESS_LENGTH INTEGER;
	DECLARE GUEST_FLAG CHAR(1);
	DECLARE FLAG CHAR(1);
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE CURRENT_RV INT DEFAULT 0;
	DECLARE MIN_CELP INT DEFAULT 0;
	DECLARE MIN_CRV INT DEFAULT 0;
	DECLARE MAX_CRV INT DEFAULT 0;
	DECLARE RVCOUNT INT DEFAULT 0;
	DECLARE PAY_CHK_COUNT INT DEFAULT 0;
	DECLARE TEMP_EXT_PAYTBLNAME TEXT;
	DECLARE PYTYPEMINID INT DEFAULT 0;
	DECLARE PYTYPEMAXID INT DEFAULT 0;
	DECLARE PAY_COUNT INT DEFAULT 0;
	DECLARE PAYAMTTYPE TEXT DEFAULT NULL;	
	DECLARE EX_ACTIVECARD_COUNT INTEGER;
	DECLARE LOCATION INTEGER;
	DECLARE CUSTOMER_LENGTH INTEGER;
	DECLARE EXACTIVECARDNO INTEGER;
	DECLARE UASDID INTEGER;
	DECLARE ECDID INTEGER;	
	DECLARE PRETERMINATE VARCHAR(15);
	DECLARE OLDPRETERMINATE TEXT;
	DECLARE NEWPRETERMINATE TEXT;
	DECLARE MINID INTEGER;
	DECLARE MAXID INTEGER;
	DECLARE OLDRECVERFEE TEXT;
    DECLARE NEWRECVERFEE TEXT;
    DECLARE MAX_FEE_ID INTEGER;
    DECLARE MIN_FEE_ID INTEGER;
    DECLARE OLDRECVERENTRY TEXT;
    DECLARE NEWRECVERENTRY TEXT;
    DECLARE MIN_ENTRY_ID INTEGER;
    DECLARE MAX_ENTRY_ID INTEGER;
    DECLARE OLDRECVERLP TEXT;
    DECLARE NEWRECVERLP TEXT;
    DECLARE MIN_LP_ID INTEGER;
    DECLARE MAX_LP_ID INTEGER;
    DECLARE CEDID INTEGER;	
    DECLARE EX_PRETERM_FLAG INT DEFAULT 0;
	DECLARE MINLPID INT DEFAULT 0;
	DECLARE MAXLPID INT DEFAULT 0;
	DECLARE MINFEEID INT DEFAULT 0;
	DECLARE MAXFEEID INT DEFAULT 0;	
	DECLARE TEMPEXTENSIONCARDNO TEXT;
	DECLARE TEMP_EXT_CARNOTBLNAME TEXT;	
	DECLARE OLDULDID INTEGER;
	DECLARE NEWULDID INTEGER;
	DECLARE TIMESTAMP_VALUE TIMESTAMP;
	DECLARE ULDID INTEGER;
	DECLARE ERRORMSG TEXT;
-- query for rollback command
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 	
	ROLLBACK; 
	IF EX_SUCCESSFLAG=1 THEN
	SET EX_SUCCESSFLAG = 0;
	END IF;	
	IF(TEMP_EXT_CARNOTBLNAME IS NOT NULL)THEN
		SET @TEMPCARDNO_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_EXT_CARNOTBLNAME,''));
		PREPARE TEMPCARDNO_DROPQUERYSTMT FROM @TEMPCARDNO_DROPQUERY;
		EXECUTE TEMPCARDNO_DROPQUERYSTMT;
	END IF;	
	IF(TEMP_EXT_PAYTBLNAME IS NOT NULL)THEN
		SET @TEMP_EXT_PAYTBLDROPQRY = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_EXT_PAYTBLNAME,''));
		PREPARE TEMP_EXT_PAYTBLDROPQRYSTMT FROM @TEMP_EXT_PAYTBLDROPQRY;
		EXECUTE TEMP_EXT_PAYTBLDROPQRYSTMT;
	END IF;	
	END;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);	
-- set null for non mandatory fields in CUSTOMER_ENTRY_DETAILS table
	IF EX_SAMEAMNTFLAG='' THEN
		SET EX_SAMEAMNTFLAG=NULL;
	END IF;
	IF EX_PROCESSING_WAIVED='' THEN
		SET EX_PROCESSING_WAIVED=NULL;
	END IF;
	IF EX_PRORATED='' THEN
		SET EX_PRORATED=NULL;
	END IF;
	IF EX_NOTICE_PERIOD='' THEN
		SET EX_NOTICE_PERIOD=NULL;
	END IF;
	IF EX_ROOM_TYPE='' THEN
		SET EX_ROOM_TYPE=NULL;
	END IF;
-- set null for non mandatory fields in CUSTOMER_ACCESS_CARD_DETAILS table
	IF EX_CARD_NO='' THEN
		SET EX_CARD_NO=NULL;
	END IF;
-- set null for non mandatory fields in CUSTOMER_TERMINATION DETAILS table
	IF EX_GUEST_CARD='' THEN
		SET EX_GUEST_CARD=NULL;
	END IF;
	IF EX_SAMEUNIT_FLAG='' THEN
		SET EX_SAMEUNIT_FLAG=NULL;
	END IF;
-- get UASD_ID for passing ROOM_TYPE
	SET ROOM_TYPE_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE URTD_ID=(SELECT URTD_ID FROM UNIT_ROOM_TYPE_DETAILS WHERE URTD_ROOM_TYPE=EX_ROOM_TYPE) AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=EX_UNIT_NO));
-- get UNIT_ID for passing unitno
	SET RE_UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=EX_UNIT_NO);
	SET REC_VER=(SELECT MAX(CED_REC_VER) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID);
	SET FLAG='X';
-- get customer current rv
	SET CURRENT_RV=(SELECT CED_REC_VER FROM VW_EXTENSION_CUSTOMER WHERE CUSTOMER_ID=EX_CUSTOMER_ID);
	CALL SP_CUSTOMER_MIN_MAX_RV(EX_CUSTOMER_ID,@MIN_LP,@MAX_LP);
	SET MIN_CELP=@MIN_LP;
	START TRANSACTION;
	SET AUTOCOMMIT=0;
	SET EX_SUCCESSFLAG='';	
	SET EX_ACTIVECARD_COUNT = 0;	
	SET CUSTOMER_LENGTH = 1;	
	SET @TEMP_EX_CARD_NO = EX_CARD_NO;	
	IF(EX_CARD_NO IS NOT NULL AND EX_SAMEUNIT_FLAG IS NULL)THEN	
		SET TEMPEXTENSIONCARDNO=(SELECT CONCAT('TEMP_EXTENSION_CARD_NO','_',SYSDATE()));
-- temp table name
		SET TEMPEXTENSIONCARDNO=(SELECT REPLACE(TEMPEXTENSIONCARDNO,' ',''));
		SET TEMPEXTENSIONCARDNO=(SELECT REPLACE(TEMPEXTENSIONCARDNO,'-',''));
		SET TEMPEXTENSIONCARDNO=(SELECT REPLACE(TEMPEXTENSIONCARDNO,':',''));
		SET TEMP_EXT_CARNOTBLNAME=(SELECT CONCAT(TEMPEXTENSIONCARDNO,'_',USERSTAMP_ID)); 
		SET TEMP_OUT_EXT_CARNOTBLNAME=TEMP_EXT_CARNOTBLNAME;-- OUTPUT CARNO TEMP TABLE NAME
		SET @TEMPEXTENSION_CARD_NO=(SELECT CONCAT('CREATE TABLE ',TEMP_EXT_CARNOTBLNAME,'(		
		EX_ID INTEGER AUTO_INCREMENT,
		EX_CARDNO INTEGER(7),
		EX_ACTIVE CHAR(4),
		EX_LOST CHAR(4),
		EX_INVENTORY CHAR(4),
		PRIMARY KEY(EX_ID))'));
		PREPARE TEMPEXTENSION_CARD_NO_STMT FROM @TEMPEXTENSION_CARD_NO;
		EXECUTE TEMPEXTENSION_CARD_NO_STMT;	
		MAIN_LOOP : LOOP		
-- QUERY FOR SET PASSING CARDNO VALUES IN TEMP VARIABLE
			SET @CARD_COUNT = NULL;
			CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_EX_CARD_NO,@VALUE,@REMAINING_STRING);
			SELECT @VALUE INTO ACCESS_CARD_NO;
			SELECT @REMAINING_STRING INTO @TEMP_EX_CARD_NO;			
			SET @EXACTIVEFLAG = (SELECT UASD_ACCESS_ACTIVE FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO);			
			SET @EXLOSTFLAG = (SELECT UASD_ACCESS_LOST FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO);			
			SET @EXINVENTORYFLAG = (SELECT UASD_ACCESS_INVENTORY FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO);			
			SET @CARDNO_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TEMP_EXT_CARNOTBLNAME,'(EX_CARDNO,EX_ACTIVE,EX_LOST,EX_INVENTORY) 
			VALUES(',ACCESS_CARD_NO,',@EXACTIVEFLAG,@EXLOSTFLAG,@EXINVENTORYFLAG)'));
			PREPARE CARDNO_INSERTQUERYSTMT FROM @CARDNO_INSERTQUERY;
			EXECUTE CARDNO_INSERTQUERYSTMT;		
			IF @TEMP_EX_CARD_NO IS NULL THEN
				LEAVE  MAIN_LOOP;
			END IF;		
		END LOOP;		
		SET @EXACTIVECARDCOUNT = (SELECT CONCAT('SELECT COUNT(*) INTO @CARD_COUNT FROM ',TEMP_EXT_CARNOTBLNAME,' WHERE EX_ACTIVE IS NOT NULL OR EX_LOST IS NOT NULL'));
		PREPARE EXACTIVECARDCOUNTSTMT FROM @EXACTIVECARDCOUNT;
		EXECUTE EXACTIVECARDCOUNTSTMT;		
		SET EX_ACTIVECARD_COUNT = @CARD_COUNT;		
	END IF;	
	IF(EX_ACTIVECARD_COUNT>0) THEN	
		SET @MINIID = NULL;
		SET @MAXIID = NULL;	
		SET @MIN_ID = (SELECT CONCAT('SELECT MIN(EX_ID) INTO @MINIID FROM ',TEMP_EXT_CARNOTBLNAME,''));
		PREPARE MIN_ID_STMT FROM @MIN_ID;
		EXECUTE MIN_ID_STMT;		
		SET @MAX_ID = (SELECT CONCAT('SELECT MAX(EX_ID) INTO @MAXIID FROM ',TEMP_EXT_CARNOTBLNAME,''));
		PREPARE MAX_ID_STMT FROM @MAX_ID;
		EXECUTE MAX_ID_STMT;		
		SET MINID = @MINIID;
		SET MAXID = @MAXIID;		
		WHILE (MINID <= MAXID)DO		
			SET @EXCARDNO = NULL;		
			SET @ACTIVE_CARDNO = (SELECT CONCAT('SELECT EX_CARDNO INTO @EXCARDNO FROM ',TEMP_EXT_CARNOTBLNAME,' WHERE EX_ID = ',MINID,' AND (EX_ACTIVE IS NOT NULL OR EX_LOST IS NOT NULL)'));
			PREPARE ACTIVE_CARDNO_STMT FROM @ACTIVE_CARDNO;
			EXECUTE ACTIVE_CARDNO_STMT;			
			SET EXACTIVECARDNO = @EXCARDNO;						
			IF (EXACTIVECARDNO IS NOT NULL)THEN		
				SET EX_SUCCESSFLAG = (SELECT CONCAT(EX_SUCCESSFLAG,',',EXACTIVECARDNO));			
			END IF;		
			SET MINID = MINID+1;			
		END WHILE;	
		SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=571);
		SET LOCATION=(SELECT LOCATE(',', EX_SUCCESSFLAG,CUSTOMER_LENGTH));		
		SET EX_SUCCESSFLAG=(SELECT SUBSTRING(EX_SUCCESSFLAG,LOCATION+1));			
		SET EX_SUCCESSFLAG = (SELECT REPLACE(ERRORMSG,'[CARD NO]',EX_SUCCESSFLAG));
	END IF;
	IF(EX_ACTIVECARD_COUNT=0)THEN
-- UPDATE RV +1 FROM CURRENT RV+1 TO MAX RV IN CUSTOMER_ENTRY_DETAILS AND CUSTOMER_LP_DETAILS START
		SET RVCOUNT=(SELECT COUNT(*) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID);		
		IF RVCOUNT>1 THEN			 
			SET MIN_CRV=(CURRENT_RV+1);			
			SET MAX_CRV=REC_VER;				
				IF (SELECT COUNT(*) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=MIN_CRV AND UNIT_ID=RE_UNIT_ID)>0 THEN
					SET EX_PRETERM_FLAG=1;
				END IF;
			WHILE MAX_CRV>=MIN_CRV DO		
				SET CEDID=(SELECT CED_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=MAX_CRV);			
-- TICKLER PART TO REORDER REC VER FOR LP DETAILS START
				SET MINLPID=(SELECT MIN(CLP_ID) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=MAX_CRV);
				SET MAXLPID=(SELECT MAX(CLP_ID) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=MAX_CRV);					
				SET NEWRECVERLP=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_REC_VER=',MAX_CRV+1)));				
					WHILE(MINLPID<=MAXLPID)DO						
						IF (SELECT COUNT(*) FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=MINLPID AND CED_REC_VER=MAX_CRV AND CUSTOMER_ID=EX_CUSTOMER_ID)>0 THEN							
							SET @OLDULDID=(SELECT CONCAT('SELECT ULD_ID INTO @OLD_ULDID FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=',MINLPID,' AND CED_REC_VER=',MAX_CRV,' AND CUSTOMER_ID=',EX_CUSTOMER_ID));
							PREPARE OLDULDID_STMT FROM @OLDULDID;
							EXECUTE OLDULDID_STMT;
							SET ULDID=@OLD_ULDID;              
							SET OLDRECVERLP=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CLP_ID=',MINLPID,',','CED_REC_VER=',MAX_CRV)));						
							IF (USERSTAMP_ID != ULDID) THEN
								SET OLDRECVERLP=(SELECT CONCAT(OLDRECVERLP,',ULD_ID=',ULDID));
							END IF;              
							SET @OLDTIMESTAMP=(SELECT CONCAT('SELECT CLP_TIMESTAMP INTO @OLD_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=',MINLPID,' AND CED_REC_VER=',MAX_CRV,' AND CUSTOMER_ID=',EX_CUSTOMER_ID));
							PREPARE OLDTIMESTAMP_STMT FROM @OLDTIMESTAMP;
							EXECUTE OLDTIMESTAMP_STMT;
							SET TIMESTAMP_VALUE=@OLD_TIMESTAMP;
							SET OLDRECVERLP=(SELECT CONCAT(OLDRECVERLP,',CLP_TIMESTAMP=',TIMESTAMP_VALUE));
							INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_LP_DETAILS'),OLDRECVERLP,NEWRECVERLP,USERSTAMP_ID,EX_CUSTOMER_ID);							
							SET EX_SUCCESSFLAG=1;						
						END IF;						
						SET MINLPID=MINLPID+1;
					END WHILE;
-- TICKLER PART TO REORDER REC VER FOR LP DETAILS END					
					UPDATE CUSTOMER_LP_DETAILS SET CED_REC_VER=(MAX_CRV+1),ULD_ID=USERSTAMP_ID WHERE CED_REC_VER=MAX_CRV AND CUSTOMER_ID=EX_CUSTOMER_ID;
					SET EX_SUCCESSFLAG=1;
-- UPDATE FEE DETAILS IN TICKLER TABLE START										
					SET MINFEEID=(SELECT MIN(CFD_ID) FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=MAX_CRV);
					SET MAXFEEID=(SELECT MAX(CFD_ID) FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=MAX_CRV);
					SET NEWRECVERFEE=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_REC_VER=',MAX_CRV+1)));					
					WHILE(MINFEEID<=MAXFEEID)DO						
						IF (SELECT COUNT(*) FROM CUSTOMER_FEE_DETAILS WHERE CFD_ID=MINFEEID AND CED_REC_VER=MAX_CRV AND CUSTOMER_ID=EX_CUSTOMER_ID)>0 THEN							
							SET OLDRECVERFEE=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CFD_ID=',MINFEEID,',','CED_REC_VER=',MAX_CRV)));							
							INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_FEE_DETAILS'),OLDRECVERFEE,NEWRECVERFEE,USERSTAMP_ID,EX_CUSTOMER_ID);							
							SET EX_SUCCESSFLAG=1;						
						END IF;
						SET MINFEEID=MINFEEID+1;
					END WHILE;					
-- UPDATE FEE DETAILS IN TICKLER TABLE END
					UPDATE CUSTOMER_FEE_DETAILS SET CED_REC_VER=(MAX_CRV+1) WHERE CED_REC_VER=MAX_CRV AND CUSTOMER_ID=EX_CUSTOMER_ID;					
					SET EX_SUCCESSFLAG=1;
					SET OLDRECVERENTRY=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_ID=',CEDID,',','CED_REC_VER=',MAX_CRV)));
					SET NEWRECVERENTRY=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_REC_VER=',MAX_CRV+1)));					
					INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ENTRY_DETAILS'),OLDRECVERENTRY,NEWRECVERENTRY,USERSTAMP_ID,EX_CUSTOMER_ID);
					SET EX_SUCCESSFLAG=1;					
					UPDATE CUSTOMER_ENTRY_DETAILS SET CED_REC_VER=(MAX_CRV+1) WHERE CED_REC_VER=MAX_CRV AND CUSTOMER_ID=EX_CUSTOMER_ID;
					SET EX_SUCCESSFLAG=1;				
				SET MAX_CRV=MAX_CRV-1;			
			END WHILE;			
			SET REC_VER=CURRENT_RV;		
		END IF;
-- update query for customer_company_details table
		CALL SP_CUSTOMER_EXTENSION_COMPANY_DTLS_INSERT(EX_CUSTOMER_ID,EX_COMPANY_NAME,EX_COMPANY_ADDR,EX_POSTAL_CODE,EX_OFFICE_NO,USERSTAMP,@EX_SUCCESSFLAG);		
-- INSERT QUERY FOR CUSTOMER_ENTRY_DETAILS
		IF EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID) THEN			
			IF EX_SAMEUNIT_FLAG IS NOT NULL THEN
				SET CEDID=(SELECT CED_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=REC_VER);
				SET PRETERMINATE=(SELECT IF(CED_PRETERMINATE IS NULL,'NULL',CED_PRETERMINATE) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=REC_VER);						
				IF(PRETERMINATE!=FLAG) THEN					
					LABEL1: BEGIN								
						IF (PRETERMINATE IS NULL AND FLAG IS NULL) THEN
							LEAVE LABEL1;
						ELSE
							SET OLDPRETERMINATE=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_ID=',CEDID,',','CED_PRETERMINATE=',PRETERMINATE)));
							SET NEWPRETERMINATE=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_PRETERMINATE=',FLAG)));
							INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ENTRY_DETAILS'),OLDPRETERMINATE,NEWPRETERMINATE,USERSTAMP_ID,EX_CUSTOMER_ID);
						END IF;							
					END LABEL1;						
				END IF;						
				UPDATE CUSTOMER_ENTRY_DETAILS SET CED_PRETERMINATE=FLAG WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=REC_VER;
				SET EX_SUCCESSFLAG=1;					
			END IF;				
			IF EX_PRETERM_FLAG=1 THEN 
--  INSERT PRETERMINATE FLAG IF CUST EXTN IN MIDDLE LP
				INSERT INTO CUSTOMER_ENTRY_DETAILS(CUSTOMER_ID, UNIT_ID, UASD_ID, CED_REC_VER, CED_SD_STIME, CED_SD_ETIME, CED_ED_STIME, CED_ED_ETIME, CED_LEASE_PERIOD, CED_QUARTERS, CED_EXTENSION,CED_PRETERMINATE, CED_PROCESSING_WAIVED, CED_PRORATED, CED_NOTICE_PERIOD, CED_NOTICE_START_DATE) VALUES(EX_CUSTOMER_ID, RE_UNIT_ID, ROOM_TYPE_ID, REC_VER+1, (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_SD_STIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_SD_ETIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_ED_STIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_ED_ETIME), EX_LEASE_PERIOD, EX_QUARTERS, FLAG,FLAG,EX_PROCESSING_WAIVED, EX_PRORATED, EX_NOTICE_PERIOD, EX_NOTICE_START_DATE);
			ELSE
				INSERT INTO CUSTOMER_ENTRY_DETAILS(CUSTOMER_ID, UNIT_ID, UASD_ID, CED_REC_VER, CED_SD_STIME, CED_SD_ETIME, CED_ED_STIME, CED_ED_ETIME, CED_LEASE_PERIOD, CED_QUARTERS, CED_EXTENSION, CED_PROCESSING_WAIVED, CED_PRORATED, CED_NOTICE_PERIOD, CED_NOTICE_START_DATE) VALUES(EX_CUSTOMER_ID, RE_UNIT_ID, ROOM_TYPE_ID, REC_VER+1, (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_SD_STIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_SD_ETIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_ED_STIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_ED_ETIME), EX_LEASE_PERIOD, EX_QUARTERS, FLAG, EX_PROCESSING_WAIVED, EX_PRORATED, EX_NOTICE_PERIOD, EX_NOTICE_START_DATE);
			END IF;				
			SET EX_SUCCESSFLAG=1;			
		END IF;		
-- update query for CUSTOMER_PERSONAL_DETAILS table
		CALL SP_CUSTOMER_EXTENSION_PERSONAL_DTLS_INSERT(EX_CUSTOMER_ID,EX_NATIONALITY,EX_MOBILE,EX_INTL_MOBILE,EX_EMAIL,EX_PASSPORT_NO,EX_PASSPORT_DATE,EX_DOB,EX_EP_NO,EX_EP_DATE,EX_COMMENTS,USERSTAMP,@EX_SUCCESSFLAG);
-- insert query for CUSTOMER_ACCESS_CARD_DETAILS
		IF EX_CARD_NO IS NOT NULL AND EX_VALID_FROM IS NOT NULL AND EX_SAMEUNIT_FLAG IS NULL THEN				
			SET TEMP_ACCESS_CARD = EX_CARD_NO;
			SET ACCESS_LENGTH=1;				
			loop_label:  LOOP					
				SET ACCESS_POSITION=(SELECT LOCATE(',', TEMP_ACCESS_CARD,ACCESS_LENGTH));					
				IF ACCESS_POSITION<=0 THEN
					SET ACCESS_CARD_NO=TEMP_ACCESS_CARD;
				ELSE
					SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_LENGTH,ACCESS_POSITION-1) INTO ACCESS_CARD_NO;
					SET TEMP_ACCESS_CARD=(SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_POSITION+1));
				END IF;					
				SET ACCESS_LOCATION=(SELECT LOCATE(ACCESS_CARD_NO, EX_GUEST_CARD));
				SET GUEST_ACCESS_LENGTH=(SELECT LENGTH(ACCESS_CARD_NO));
				SET GUEST_FLAG=(SELECT SUBSTRING(EX_GUEST_CARD,ACCESS_LOCATION+GUEST_ACCESS_LENGTH+1,1));
				SET GUEST_FLAG=TRIM(GUEST_FLAG);					
				IF GUEST_FLAG='' THEN
					SET GUEST_FLAG=NULL;
				END IF;			
				SET UASDID = (SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO));				
				IF(UASDID IS NOT NULL) THEN					
					SET ECDID = (SELECT ECD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID = UASDID);					
					CALL SP_CUSTOMER_ROW_DELETION(40,ECDID,USERSTAMP_ID);					
					SET EX_SUCCESSFLAG=1;				
				END IF;				
				INSERT INTO CUSTOMER_ACCESS_CARD_DETAILS (CUSTOMER_ID,UASD_ID,CACD_VALID_FROM,CACD_GUEST_CARD,ULD_ID) VALUES(EX_CUSTOMER_ID,(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=EX_UNIT_NO)),EX_VALID_FROM,GUEST_FLAG,USERSTAMP_ID);					
				UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_ACTIVE=FLAG,UASD_ACCESS_INVENTORY=NULL WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=EX_UNIT_NO);
				SET EX_SUCCESSFLAG=1;					
				IF ACCESS_POSITION<=0 THEN
					LEAVE  loop_label;
				END IF;				
			END LOOP;			
		END IF;		
-- insert query for CUSTOMER_LP_DETAILS
		IF EX_STARTDATE IS NOT NULL AND EX_ENDDATE IS NOT NULL THEN				
			IF EX_CARD_NO IS NOT NULL THEN					
				SET TEMP_ACCESS_CARD = EX_CARD_NO;
				SET ACCESS_LENGTH=1;		
				loop_label:  LOOP						
					SET ACCESS_POSITION=(SELECT LOCATE(',', TEMP_ACCESS_CARD,ACCESS_LENGTH));							
					IF ACCESS_POSITION<=0 THEN
						SET ACCESS_CARD_NO=TEMP_ACCESS_CARD;
					ELSE
						SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_LENGTH,ACCESS_POSITION-1) INTO ACCESS_CARD_NO;
						SET TEMP_ACCESS_CARD=(SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_POSITION+1));
					END IF;						
					SET ACCESS_LOCATION=(SELECT LOCATE(ACCESS_CARD_NO, EX_GUEST_CARD));
					SET GUEST_ACCESS_LENGTH=(SELECT LENGTH(ACCESS_CARD_NO));
					SET GUEST_FLAG=(SELECT SUBSTRING(EX_GUEST_CARD,ACCESS_LOCATION+GUEST_ACCESS_LENGTH+1,1));
					SET GUEST_FLAG=TRIM(GUEST_FLAG);						
					IF GUEST_FLAG='' THEN
						SET GUEST_FLAG=NULL;
					END IF;						
					SET UASDID = (SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO));				
					IF(UASDID IS NOT NULL) THEN					
						SET ECDID = (SELECT ECD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID = UASDID);					
						CALL SP_CUSTOMER_ROW_DELETION(40,ECDID,USERSTAMP_ID);					
						SET EX_SUCCESSFLAG=1;				
					END IF;						
					INSERT INTO CUSTOMER_LP_DETAILS (CUSTOMER_ID,CED_REC_VER,UASD_ID,CLP_STARTDATE,CLP_ENDDATE,CLP_GUEST_CARD,ULD_ID) VALUES (EX_CUSTOMER_ID,REC_VER+1,(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=EX_UNIT_NO)),EX_STARTDATE,EX_ENDDATE,GUEST_FLAG,USERSTAMP_ID);
					SET EX_SUCCESSFLAG=1;						
					IF ACCESS_POSITION<=0 THEN
						LEAVE  loop_label;
					END IF;					
				END LOOP;				
			ELSE					
					INSERT INTO CUSTOMER_LP_DETAILS (CUSTOMER_ID,CED_REC_VER,UASD_ID,CLP_STARTDATE,CLP_ENDDATE,CLP_GUEST_CARD,ULD_ID) VALUES (EX_CUSTOMER_ID,REC_VER+1,EX_CARD_NO,EX_STARTDATE,EX_ENDDATE,GUEST_FLAG,USERSTAMP_ID);
					SET EX_SUCCESSFLAG=1;  
			END IF;			
		END IF;			
-- INSERT QUERY FOR CUSTOMER_FEE_DETAILS
		CALL SP_CUSTOMER_EXTENSION_FEE_DTLS_INSERT(EX_CUSTOMER_ID,EX_RENT,EX_DEPOSIT,EX_PROCESSING_FEE,EX_AIRCON_FIXED_FEE,EX_AIRCON_QUARTELY_FEE,
		EX_ELECTRICITY_CAP,EX_CHECKOUT_CLEANING_FEE,EX_DRYCLEAN_FEE,REC_VER,@EX_SUCCESSFLAG);
		IF EX_SAMEUNIT_FLAG IS NOT NULL AND EX_SAMEAMNTFLAG IS NOT NULL THEN
-- PAYMENT TRANSACTION CHK FOR THE SAME MONTH EXTENSION 
		SET @PAYMENT_CHKQUERY = (SELECT CONCAT('SELECT COUNT(*) INTO @PAY_TRANSCOUNT FROM PAYMENT_DETAILS WHERE PD_FOR_PERIOD= (SELECT ADDDATE(LAST_DAY(SUBDATE(','"',EX_STARTDATE,'"',',INTERVAL 1 MONTH)), 1)) AND CED_REC_VER BETWEEN ',MIN_CELP,' AND ',CURRENT_RV,' AND PP_ID  IN(1,2,3) AND UNIT_ID=',RE_UNIT_ID,' AND CUSTOMER_ID=',EX_CUSTOMER_ID));
		PREPARE PAYMENT_CHKQUERYSTMT FROM @PAYMENT_CHKQUERY;
		EXECUTE PAYMENT_CHKQUERYSTMT;
		SET PAY_CHK_COUNT=@PAY_TRANSCOUNT;
		IF PAY_CHK_COUNT>0 THEN	
			-- GET PAYMENT TYPE START
			SET PYTYPEMINID=(SELECT MIN(PP_ID) FROM PAYMENT_PROFILE);
			SET PYTYPEMAXID=(SELECT MAX(PP_ID) FROM PAYMENT_PROFILE);	
			WHILE(PYTYPEMINID<=PYTYPEMAXID) DO
				SET @PAYMENTTYPE_CHKQUERY = (SELECT CONCAT('SELECT COUNT(*) INTO @PAY_TYPECHKCOUNT FROM PAYMENT_DETAILS WHERE PD_FOR_PERIOD= (SELECT ADDDATE(LAST_DAY(SUBDATE(','"',EX_STARTDATE,'"',',INTERVAL 1 MONTH)), 1)) AND CED_REC_VER BETWEEN ',MIN_CELP,' AND ',CURRENT_RV,' AND PP_ID  IN(1,2,3) AND UNIT_ID=',RE_UNIT_ID,' AND CUSTOMER_ID=',EX_CUSTOMER_ID,' AND PP_ID=',PYTYPEMINID));
				PREPARE PAYMENTTYPE_CHKQUERYSTMT FROM @PAYMENTTYPE_CHKQUERY;
				EXECUTE PAYMENTTYPE_CHKQUERYSTMT;
				SET PAY_COUNT=@PAY_TYPECHKCOUNT;
				IF PAY_COUNT > 0 THEN
					IF PAYAMTTYPE IS NOT NULL THEN	
						SET PAYAMTTYPE=(SELECT CONCAT(PAYAMTTYPE,',',(SELECT PP_DATA FROM PAYMENT_PROFILE WHERE PP_ID=PYTYPEMINID)));	
					ELSE
						SET PAYAMTTYPE=(SELECT PP_DATA FROM PAYMENT_PROFILE WHERE PP_ID=PYTYPEMINID);
					END IF;
				END IF;
				SET PYTYPEMINID=PYTYPEMINID+1;
				SET @PAYMENTTYPE_CHKQUERY=NULL;	
				SET @PAY_TYPECHKCOUNT=NULL;	
			END WHILE;	
		-- GET PAYMENT TYPE END	
			SET PAY_CHK_MSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=569);
			SET PAY_CHK_MSG=(SELECT REPLACE(PAY_CHK_MSG,'<MONTH>',(SELECT CONCAT((SELECT UCASE(MONTHNAME(STR_TO_DATE((SELECT MONTH(EX_STARTDATE)), '%m')))),'-',(SELECT YEAR(EX_STARTDATE))))));
			SET PAY_CHK_MSG=(SELECT REPLACE(PAY_CHK_MSG,'<AMTTYPE>',PAYAMTTYPE));
		ELSE 
			SET PAY_CHK_MSG=NULL;
		END IF;	
	END IF;	
	END IF;		
END;