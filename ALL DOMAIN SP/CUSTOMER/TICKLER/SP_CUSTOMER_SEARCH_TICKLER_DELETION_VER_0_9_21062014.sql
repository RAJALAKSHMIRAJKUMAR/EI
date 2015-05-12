-- VER 0.9 ISSUE:817 COMMENT #139 STARTDATE:21/06/2014 ENDDATE:21/06/2014 DESC:DROPED TEMP TABLES INSIDE ROLL BACK AND COMMIT DONE BY:DHIVYA.A
--version 0.8 startdate:16/06/2014 --enddate:16/06/2014---ADDED ULD_ID AND TIMESTAMP IN TICKLER_HISTORY TABLE.DONE BY DHIVYA
--version 0.7 startdate:16/05/2014 --enddate:15/05/2014---added comma's in customer fees details tables.DONE BY KUMAR.R
--version 0.6 startdate:05/05/2014 --enddate:05/05/2014---did some corrections in access card and lp details tickler updation part.BY KUMAR.R
--version 0.5 startdate:07/04/2014 --enddate:07/04/2014--- issueno 797 commentno:28 -->desc:Rename table POST_AUDIT_PROFILE INTO TICKLER_TABID_PROFILE DONEBY:BHAVANI.R 
--version 0.4 startdate:28/02/2014 --enddate:28/02/2014--- issueno 754 commentno:36-->desc:added sub sp to convert userstamp as uld_id done by:Dhivya 
--version 0.3 --startdate:27/02/2014 --enddate:27/02/2014 --issueno:754 commentno:#22 -->description:CHANGING OF DATATYPE  USERSTAMP AS ULD_ID -->DONE BY:SAFI
--VER 0.2 ISSUE NO:345 COMMENT:#585 STARTDATE:08/02/2014 ENDDATE:11/02/2014 DESC:CHANGED CUSTOMER_ENTRY_DETAILS,CUSTOMER_FEE_DETAILS,CUSTOMER_TERMINATION_DETAILS TABLE TO SAVE ID INSTEAD OF DATA DONE BY:DHIVYA.A
--VER 0.1 ISSUE NO:345 COMMENT:#567 STARTDATE:05/02/2014 ENDDATE:06/02/2014 DESC:SP FOR CUSTOMER SEARCH TICKLER DELETION DONE BY:DHIVYA.A

DROP PROCEDURE IF EXISTS SP_CUSTOMER_SEARCH_TICKLER_DELETION;
CREATE PROCEDURE SP_CUSTOMER_SEARCH_TICKLER_DELETION(
IN CUSTOMERID INTEGER,
IN USERSTAMP VARCHAR(50),
OUT FLAG INTEGER)

BEGIN
-- CUSTOMER
	DECLARE CUSTOMERFIRSTNAME CHAR(30);
	DECLARE CUSTOMERLASTNAME CHAR(30);
	DECLARE RECHECKINID INTEGER;

-- CUSTOMER_COMPANY_DETAILS
	DECLARE CCDID INTEGER;
	DECLARE CCDCOMPANYNAME VARCHAR(50);
	DECLARE CCDCOMPANYADDR VARCHAR(50);
	DECLARE CCDPOSTALCODE VARCHAR(6);
	DECLARE CCDOFFICENO VARCHAR(8);

-- CUSTOMER_PERSONAL_DETAILS
	DECLARE CPDID INTEGER;
	DECLARE NCID INTEGER;
	DECLARE CPDMOBILE VARCHAR(8);
	DECLARE CPDINTLMOBILE VARCHAR(20);
	DECLARE CPDEMAIL VARCHAR(40);
	DECLARE CPDPASSPORTNO VARCHAR(15);
	DECLARE CPDPASSPORTDATE TEXT;
	DECLARE CPDDOB TEXT;
	DECLARE CPDEPNO VARCHAR(15);
	DECLARE CPDEPDATE TEXT;
	DECLARE CPDCOMMENTS TEXT;

-- CUSTOMER_ENTRY_DETAILS
	DECLARE UNITID INTEGER;
	DECLARE UASDID INTEGER;
	DECLARE CEDRECVER INTEGER;
	DECLARE CEDSDSTIME INTEGER;
	DECLARE CEDSDETIME INTEGER;
	DECLARE CEDEDSTIME INTEGER;
	DECLARE CEDEDETIME INTEGER;
	DECLARE CEDLEASEPERIOD VARCHAR(30);
	DECLARE CEDQUARTERS TEXT;
	DECLARE CEDRECHECKIN CHAR(1);
	DECLARE CEDEXTENSION CHAR(1);
	DECLARE CEDPRETERMINATE CHAR(1);
	DECLARE CEDPROCESSING_WAIVED CHAR(1);
	DECLARE CEDPRORATED CHAR(1);
	DECLARE CEDNOTICEPERIOD TEXT;
	DECLARE CEDNOTICESTARTDATE TEXT;
	DECLARE CEDCANCELDATE TEXT;
	DECLARE CEDID INTEGER;

-- CUSTOMER_LP_DETAILS
	DECLARE CLPID INTEGER;
	DECLARE CTDRECVER INTEGER;
	DECLARE CTDSTARTDATE DATE;
	DECLARE CTDENDDATE DATE;
	DECLARE CTDTERMINATE CHAR(1);
	DECLARE CTDPRETERMINATEDATE TEXT;
	DECLARE CTDGUESTCARD CHAR(1);

-- CUSTOMER_FEE_DETAILS
	DECLARE CFRECVER INTEGER;
	DECLARE PAYMENTCPPID TEXT;
	DECLARE CCPAYMENTAMOUNT TEXT;
	DECLARE DEPOSIT_ID TEXT;
	DECLARE CCDEPOSIT TEXT;
	DECLARE PROCFEEID TEXT;
	DECLARE CCPROCESSINGFEE TEXT;
	DECLARE AIRCONFIXEDID TEXT;
	DECLARE CCAIRCONFIXEDFEE TEXT;
	DECLARE ELECTRICITYID TEXT;
	DECLARE CCELECTRICITYCAP TEXT;
	DECLARE DRYCLEANID TEXT;
	DECLARE CCDRYCLEANFEE TEXT;
	DECLARE AIRCONQUARTELYID TEXT;
	DECLARE CCAIRCONQUARTERLYFEE TEXT;
	DECLARE CLEANINGID TEXT;
	DECLARE CCCHECKOUTCLEANINGFEE TEXT;
	DECLARE CTD_ULDID INTEGER;
	DECLARE CTDTIMESTAMP TIMESTAMP;

	DECLARE MINID INTEGER;
	DECLARE MAXID INTEGER;

	DECLARE CUSTOMER_LENGTH INTEGER;
	DECLARE HEADERNAME TEXT;
	DECLARE HEADER_POSITION INTEGER;
	DECLARE CUSTOMER_HEADER_NAME TEXT;
	DECLARE LOCATION INTEGER;

	DECLARE OLD_CUSTOMER_RECORDS TEXT;
	DECLARE CUSTOMER_RECORDS_POSITION INTEGER;
	DECLARE CUSTOMER_RECORDS TEXT;

	DECLARE DLTEDRECORDDETAILS TEXT;
	DECLARE USERSTAMP_ID INTEGER(2);

	DECLARE CUSTOMER_SEARCH_DELETION TEXT;
	DECLARE UNIT_ACCESS_ID INTEGER;
	DECLARE TEMP_CUST_SRCH_REC_VER INTEGER;
	DECLARE SYSDATEANDTIME VARCHAR(50);
	DECLARE SYSDATEANDULDID VARCHAR(50);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		

		ROLLBACK; 
		SET FLAG=0;
		IF CUSTOMER_SEARCH_DELETION IS NOT NULL THEN
		SET @DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',CUSTOMER_SEARCH_DELETION,''));
		PREPARE DROPQUERYSTMT FROM @DROPQUERY;
		EXECUTE DROPQUERYSTMT;
		END IF;
	END;
	
	START TRANSACTION;
	
	SET FLAG=0;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);

	SET SYSDATEANDTIME=(SELECT SYSDATE());
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,' ',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,'-',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,':',''));
	SET SYSDATEANDULDID=(SELECT CONCAT(SYSDATEANDTIME,'_',USERSTAMP_ID));	

	
	SET RECHECKINID=(SELECT MAX(CED_REC_VER) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_RECHECKIN='X');

	SET CUSTOMER_SEARCH_DELETION=(SELECT CONCAT('TEMP_CUSTOMER_SEARCH_DELETION','_',SYSDATEANDULDID));
	
	SET @CUST_SRCH_DEL_CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',CUSTOMER_SEARCH_DELETION,'
	(ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,CUSTOMERID INTEGER,RECVER INTEGER,UASD_ID INTEGER)'));
	PREPARE CUST_SRCH_DEL_CREATE_STMT FROM @CUST_SRCH_DEL_CREATEQUERY;
	EXECUTE CUST_SRCH_DEL_CREATE_STMT;

	SET @CUST_SRCH_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',CUSTOMER_SEARCH_DELETION,'
	(CUSTOMERID,RECVER,UASD_ID)SELECT CUSTOMER_ID,CED_REC_VER,UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=',CUSTOMERID,''));
	PREPARE CUST_SRCH_INSERT_STMT FROM @CUST_SRCH_INSERTQUERY;
	EXECUTE CUST_SRCH_INSERT_STMT;
	
	SET @MIN_ID = (SELECT CONCAT('SELECT MIN(ID) INTO @MINIMUMID FROM ',CUSTOMER_SEARCH_DELETION,''));
	PREPARE MIN_ID_STMT FROM @MIN_ID;
	EXECUTE MIN_ID_STMT;
	
	SET @MAX_ID = (SELECT CONCAT('SELECT MAX(ID) INTO @MAXIMUMID FROM ',CUSTOMER_SEARCH_DELETION,''));
	PREPARE MAX_ID_STMT FROM @MAX_ID;
	EXECUTE MAX_ID_STMT;
	
	SET MINID = @MINIMUMID;
	SET MAXID = @MAXIMUMID;


	IF RECHECKINID IS NULL THEN
	
		SET @UASDID = (SELECT CONCAT('SELECT UASD_ID INTO @ACCESSID FROM ',CUSTOMER_SEARCH_DELETION,' WHERE UASD_ID IS NOT NULL GROUP BY CUSTOMERID'));
		PREPARE UASDID_STMT FROM @UASDID;
		EXECUTE UASDID_STMT;
		
		SET UNIT_ACCESS_ID = @ACCESSID;
		
		IF (UNIT_ACCESS_ID IS NULL) THEN
		
			IF NOT EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=CUSTOMERID)THEN
				
				IF NOT EXISTS(SELECT CUSTOMER_ID FROM EXPENSE_UNIT WHERE CUSTOMER_ID=CUSTOMERID)THEN
				
					IF NOT EXISTS(SELECT CUSTOMER_ID FROM PAYMENT_DETAILS WHERE CUSTOMER_ID=CUSTOMERID)THEN

-- CUSTOMER
						SET CUSTOMERFIRSTNAME=(SELECT CUSTOMER_FIRST_NAME FROM CUSTOMER WHERE CUSTOMER_ID=CUSTOMERID);
						SET CUSTOMERLASTNAME=(SELECT CUSTOMER_LAST_NAME FROM CUSTOMER WHERE CUSTOMER_ID=CUSTOMERID);
						SET HEADERNAME=(SELECT CONCAT('CUSTOMER_FIRST_NAME',',','CUSTOMER_LAST_NAME'));
						SET OLD_CUSTOMER_RECORDS=(SELECT CONCAT(CUSTOMERFIRSTNAME,'^^',CUSTOMERLASTNAME));

						SET CUSTOMER_LENGTH=1;
						SET DLTEDRECORDDETAILS=' ';

						loop_label : LOOP
							SET HEADER_POSITION=(SELECT LOCATE(',', HEADERNAME,CUSTOMER_LENGTH));
							IF HEADER_POSITION<=0 THEN
								SET CUSTOMER_HEADER_NAME=HEADERNAME;
							ELSE
								SELECT SUBSTRING(HEADERNAME,CUSTOMER_LENGTH,HEADER_POSITION-1) INTO CUSTOMER_HEADER_NAME;
								SET HEADERNAME=(SELECT SUBSTRING(HEADERNAME,HEADER_POSITION+1));
							END IF;
		
							SET CUSTOMER_RECORDS_POSITION=(SELECT LOCATE('^^', OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH));
							IF CUSTOMER_RECORDS_POSITION<=0 THEN
								SET CUSTOMER_RECORDS=OLD_CUSTOMER_RECORDS;
							ELSE
								SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH,CUSTOMER_RECORDS_POSITION-1) INTO CUSTOMER_RECORDS;
								SET OLD_CUSTOMER_RECORDS=(SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_RECORDS_POSITION+2));
							END IF;
		
							SET DLTEDRECORDDETAILS=(SELECT CONCAT(DLTEDRECORDDETAILS,',',CUSTOMER_HEADER_NAME,'=',CUSTOMER_RECORDS));
					
							IF CUSTOMER_RECORDS_POSITION<=0 THEN
								LEAVE  loop_label;
							END IF;
						END LOOP;
						
						SET LOCATION=(SELECT LOCATE(',', DLTEDRECORDDETAILS,CUSTOMER_LENGTH));
						SET DLTEDRECORDDETAILS=(SELECT SUBSTRING(DLTEDRECORDDETAILS,LOCATION+1));
	
						INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,ULD_ID)VALUES
						((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='DELETION'),CUSTOMERID,(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER'),
						DLTEDRECORDDETAILS,USERSTAMP_ID);
					
-- CUSTOMER_COMPANY_DETAILS
						SET CCDID=(SELECT CCD_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CCDCOMPANYNAME=(SELECT CCD_COMPANY_NAME FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CCDCOMPANYADDR=(SELECT CCD_COMPANY_ADDR FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CCDPOSTALCODE=(SELECT CCD_POSTAL_CODE FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CCDOFFICENO=(SELECT CCD_OFFICE_NO FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
					
						IF CCDCOMPANYNAME IS NULL THEN
							SET CCDCOMPANYNAME=' ';
						END IF;
					
						IF CCDCOMPANYADDR IS NULL THEN
							SET CCDCOMPANYADDR=' ';
						END IF;
					
						IF CCDPOSTALCODE IS NULL THEN
							SET CCDPOSTALCODE=' ';
						END IF;
					
						IF CCDOFFICENO IS NULL THEN
							SET CCDOFFICENO=' ';
						END IF;
					
						SET HEADERNAME=(SELECT CONCAT('CCD_ID',',','CCD_COMPANY_NAME',',','CCD_COMPANY_ADDR',',','CCD_POSTAL_CODE',',','CCD_OFFICE_NO'));
						SET OLD_CUSTOMER_RECORDS=(SELECT CONCAT(CCDID,'^^',CCDCOMPANYNAME,'^','^',CCDCOMPANYADDR,'^','^',CCDPOSTALCODE,'^','^',CCDOFFICENO));
						
						SET CUSTOMER_LENGTH=1;
						SET DLTEDRECORDDETAILS=' ';

						loop_label : LOOP
							SET HEADER_POSITION=(SELECT LOCATE(',', HEADERNAME,CUSTOMER_LENGTH));
							IF HEADER_POSITION<=0 THEN
								SET CUSTOMER_HEADER_NAME=HEADERNAME;
							ELSE
								SELECT SUBSTRING(HEADERNAME,CUSTOMER_LENGTH,HEADER_POSITION-1) INTO CUSTOMER_HEADER_NAME;
								SET HEADERNAME=(SELECT SUBSTRING(HEADERNAME,HEADER_POSITION+1));
							END IF;
		
							SET CUSTOMER_RECORDS_POSITION=(SELECT LOCATE('^^', OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH));
							IF CUSTOMER_RECORDS_POSITION<=0 THEN
								SET CUSTOMER_RECORDS=OLD_CUSTOMER_RECORDS;
							ELSE
								SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH,CUSTOMER_RECORDS_POSITION-1) INTO CUSTOMER_RECORDS;
								SET OLD_CUSTOMER_RECORDS=(SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_RECORDS_POSITION+2));
							END IF;
					
							IF CUSTOMER_RECORDS!=' ' THEN
								SET DLTEDRECORDDETAILS=(SELECT CONCAT(DLTEDRECORDDETAILS,',',CUSTOMER_HEADER_NAME,'=',CUSTOMER_RECORDS));
							END IF;
					
							IF CUSTOMER_RECORDS_POSITION<=0 THEN
								LEAVE  loop_label;
							END IF;
						END LOOP;
						
						SET LOCATION=(SELECT LOCATE(',', DLTEDRECORDDETAILS,CUSTOMER_LENGTH));
						SET DLTEDRECORDDETAILS=(SELECT SUBSTRING(DLTEDRECORDDETAILS,LOCATION+1));
	
						INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,ULD_ID)VALUES
						((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='DELETION'),CUSTOMERID,(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_COMPANY_DETAILS'),
						DLTEDRECORDDETAILS,USERSTAMP_ID);
				
-- CUSTOMER_PERSONAL_DETAILS
						SET CPDID=(SELECT CPD_ID FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET NCID=(SELECT NC_ID FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CPDMOBILE=(SELECT CPD_MOBILE FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CPDINTLMOBILE=(SELECT CPD_INTL_MOBILE FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CPDEMAIL=(SELECT CPD_EMAIL FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CPDPASSPORTNO=(SELECT CPD_PASSPORT_NO FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CPDPASSPORTDATE=(SELECT CPD_PASSPORT_DATE FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CPDDOB=(SELECT CPD_DOB FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CPDEPNO=(SELECT CPD_EP_NO FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CPDEPDATE=(SELECT CPD_EP_DATE FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
						SET CPDCOMMENTS=(SELECT CPD_COMMENTS FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
				
						IF CPDMOBILE IS NULL THEN
							SET CPDMOBILE=' ';
						END IF;
						IF CPDINTLMOBILE IS NULL THEN
							SET CPDINTLMOBILE=' ';
						END IF;
					
						IF CPDPASSPORTNO IS NULL THEN
							SET CPDPASSPORTNO=' ';
						END IF;
					
						IF CPDPASSPORTDATE IS NULL THEN
							SET CPDPASSPORTDATE=' ';
						END IF;
					
						IF CPDDOB IS NULL THEN
							SET CPDDOB=' ';
						END IF;
				
						IF CPDEPNO IS NULL THEN
							SET CPDEPNO=' ';
						END IF;
					
						IF CPDEPDATE IS NULL THEN
							SET CPDEPDATE=' ';
						END IF;
					
						IF CPDCOMMENTS IS NULL THEN
							SET CPDCOMMENTS=' ';
						END IF;
					
						SET HEADERNAME=(SELECT CONCAT('CPD_ID',',NC_ID',',','CPD_MOBILE',',','CPD_INTL_MOBILE',',','CPD_EMAIL',',','CPD_PASSPORT_NO',',','CPD_PASSPORT_DATE',',','CPD_DOB',',','CPD_EP_NO',',','CPD_EP_DATE',',','CPD_COMMENTS'));
						SET OLD_CUSTOMER_RECORDS=(SELECT CONCAT(CPDID,'^^',NCID,'^','^',CPDMOBILE,'^','^',CPDINTLMOBILE,'^','^',CPDEMAIL,'^','^',CPDPASSPORTNO,'^','^',CPDPASSPORTDATE,'^','^',CPDDOB,'^','^',CPDEPNO,'^','^',CPDEPDATE,'^','^',CPDCOMMENTS));
						
						SET CUSTOMER_LENGTH=1;
						SET DLTEDRECORDDETAILS=' ';

						loop_label : LOOP
							SET HEADER_POSITION=(SELECT LOCATE(',', HEADERNAME,CUSTOMER_LENGTH));
							IF HEADER_POSITION<=0 THEN
								SET CUSTOMER_HEADER_NAME=HEADERNAME;
							ELSE
								SELECT SUBSTRING(HEADERNAME,CUSTOMER_LENGTH,HEADER_POSITION-1) INTO CUSTOMER_HEADER_NAME;
								SET HEADERNAME=(SELECT SUBSTRING(HEADERNAME,HEADER_POSITION+1));
							END IF;
		
							SET CUSTOMER_RECORDS_POSITION=(SELECT LOCATE('^^', OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH));
							IF CUSTOMER_RECORDS_POSITION<=0 THEN
								SET CUSTOMER_RECORDS=OLD_CUSTOMER_RECORDS;
							ELSE
								SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH,CUSTOMER_RECORDS_POSITION-1) INTO CUSTOMER_RECORDS;
								SET OLD_CUSTOMER_RECORDS=(SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_RECORDS_POSITION+2));
							END IF;
					
							IF CUSTOMER_RECORDS!=' ' THEN
							SET DLTEDRECORDDETAILS=(SELECT CONCAT(DLTEDRECORDDETAILS,',',CUSTOMER_HEADER_NAME,'=',CUSTOMER_RECORDS));
							END IF;
							
							IF CUSTOMER_RECORDS_POSITION<=0 THEN
								LEAVE  loop_label;
							END IF;
						END LOOP;
						
						SET LOCATION=(SELECT LOCATE(',', DLTEDRECORDDETAILS,CUSTOMER_LENGTH));
						SET DLTEDRECORDDETAILS=(SELECT SUBSTRING(DLTEDRECORDDETAILS,LOCATION+1));
		
						INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,ULD_ID)VALUES
						((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='DELETION'),CUSTOMERID,(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_PERSONAL_DETAILS'),
						DLTEDRECORDDETAILS,USERSTAMP_ID);
					
						WHILE MINID<=MAXID DO
					
-- CUSTOMER_ENTRY_DETAILS

							SET @TEMP_CUST_SRCH_RECVER = (SELECT CONCAT('SELECT RECVER INTO @FRECVER FROM ',CUSTOMER_SEARCH_DELETION,' WHERE ID=',MINID,''));
							PREPARE TEMP_CUST_SRCH_RECVER_STMT FROM @TEMP_CUST_SRCH_RECVER;
							EXECUTE TEMP_CUST_SRCH_RECVER_STMT;
							
							SET TEMP_CUST_SRCH_REC_VER = @FRECVER;
							SET CEDID=(SELECT CED_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET UNITID=(SELECT UNIT_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET UASDID=(SELECT UASD_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDRECVER=(SELECT CED_REC_VER FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDSDSTIME=(SELECT CED_SD_STIME FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDSDETIME=(SELECT CED_SD_ETIME FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDEDSTIME=(SELECT CED_ED_STIME FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDEDETIME=(SELECT CED_ED_ETIME FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDLEASEPERIOD=(SELECT CED_LEASE_PERIOD FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDQUARTERS=(SELECT CED_QUARTERS FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDRECHECKIN=(SELECT CED_RECHECKIN FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDEXTENSION=(SELECT CED_EXTENSION FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDPRETERMINATE=(SELECT CED_PRETERMINATE FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDPROCESSING_WAIVED=(SELECT CED_PROCESSING_WAIVED FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDPRORATED=(SELECT CED_PRORATED FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDNOTICEPERIOD=(SELECT CED_NOTICE_PERIOD FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDNOTICESTARTDATE=(SELECT CED_NOTICE_START_DATE FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CEDCANCELDATE=(SELECT CED_CANCEL_DATE FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
					
							IF CEDLEASEPERIOD IS NULL THEN
								SET CEDLEASEPERIOD=' ';
							END IF;
							
							IF CEDQUARTERS IS NULL THEN
								SET CEDQUARTERS=' ';
							END IF;
							
							IF CEDRECHECKIN IS NULL THEN
								SET CEDRECHECKIN=' ';
							END IF;
							
							IF CEDEXTENSION IS NULL THEN
								SET CEDEXTENSION=' ';
							END IF;
							
							IF CEDPRETERMINATE IS NULL THEN
								SET CEDPRETERMINATE=' ';
							END IF;
					
							IF CEDPRORATED IS NULL THEN
								SET CEDPRORATED=' ';
							END IF;
							
							IF CEDNOTICEPERIOD IS NULL THEN
								SET CEDNOTICEPERIOD=' ';
							END IF;
							
							IF CEDNOTICESTARTDATE IS NULL THEN
								SET CEDNOTICESTARTDATE=' ';
							END IF;
							
							IF CEDCANCELDATE IS NULL OR CEDCANCELDATE=' ' THEN
								 SET CEDCANCELDATE=' ';
							END IF;
					
							IF CEDPROCESSING_WAIVED IS NULL THEN
								SET CEDPROCESSING_WAIVED=' ';
							END IF;
							
							SET HEADERNAME=(SELECT CONCAT('CED_ID',',UNIT_ID',',','UASD_ID',',','CED_REC_VER',',','CED_SD_STIME',',','CED_SD_ETIME',',','CED_ED_STIME',',','CED_ED_ETIME',',','CED_LEASE_PERIOD',',','CED_QUARTERS',',','CED_RECHECKIN',',','CED_EXTENSION',',','CED_PRETERMINATE',',','CED_PROCESSING_WAIVED',',','CED_PRORATED',',','CED_NOTICE_PERIOD',',','CED_NOTICE_START_DATE',',','CED_CANCEL_DATE'));
							SET OLD_CUSTOMER_RECORDS=(SELECT CONCAT(CEDID,'^^',UNITID,'^^',UASDID,'^^',CEDRECVER,'^^',CEDSDSTIME,'^^',CEDSDETIME,'^^',CEDEDSTIME,'^^',CEDEDETIME,'^^',CEDLEASEPERIOD,'^^',CEDQUARTERS,'^^',CEDRECHECKIN,'^^',CEDEXTENSION,'^^',CEDPRETERMINATE,'^^',CEDPROCESSING_WAIVED,'^^',CEDPRORATED,'^^',CEDNOTICEPERIOD,'^^',CEDNOTICESTARTDATE,'^^',CEDCANCELDATE));
							
							SET CUSTOMER_LENGTH=1;
							SET DLTEDRECORDDETAILS=' ';

							loop_label : LOOP
								SET HEADER_POSITION=(SELECT LOCATE(',', HEADERNAME,CUSTOMER_LENGTH));
								IF HEADER_POSITION<=0 THEN
									SET CUSTOMER_HEADER_NAME=HEADERNAME;
								ELSE
									SELECT SUBSTRING(HEADERNAME,CUSTOMER_LENGTH,HEADER_POSITION-1) INTO CUSTOMER_HEADER_NAME;
									SET HEADERNAME=(SELECT SUBSTRING(HEADERNAME,HEADER_POSITION+1));
								END IF;
		
								SET CUSTOMER_RECORDS_POSITION=(SELECT LOCATE('^^', OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH));
								IF CUSTOMER_RECORDS_POSITION<=0 THEN
									SET CUSTOMER_RECORDS=OLD_CUSTOMER_RECORDS;
								ELSE
									SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH,CUSTOMER_RECORDS_POSITION-1) INTO CUSTOMER_RECORDS;
									SET OLD_CUSTOMER_RECORDS=(SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_RECORDS_POSITION+2));
								END IF;
					
								IF CUSTOMER_RECORDS!=' '  THEN
								SET DLTEDRECORDDETAILS=(SELECT CONCAT(DLTEDRECORDDETAILS,',',CUSTOMER_HEADER_NAME,'=',CUSTOMER_RECORDS));
								END IF;
								
								IF CUSTOMER_RECORDS_POSITION<=0 THEN
									LEAVE  loop_label;
								END IF;
							END LOOP;
							
							SET LOCATION=(SELECT LOCATE(',', DLTEDRECORDDETAILS,CUSTOMER_LENGTH));
							SET DLTEDRECORDDETAILS=(SELECT SUBSTRING(DLTEDRECORDDETAILS,LOCATION+1));
			
							INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,ULD_ID)VALUES
							((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='DELETION'),CUSTOMERID,(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ENTRY_DETAILS'),
							DLTEDRECORDDETAILS,USERSTAMP_ID);
					
-- CUSTOMER_LP_DETAILS
							SET CLPID=(SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CTDRECVER=(SELECT CED_REC_VER FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CTDSTARTDATE=(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CTDENDDATE=(SELECT CLP_ENDDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CTDTERMINATE=(SELECT CLP_TERMINATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CTDPRETERMINATEDATE=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CTDGUESTCARD=(SELECT CLP_GUEST_CARD FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CTD_ULDID=(SELECT ULD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							SET CTDTIMESTAMP=(SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER);
							IF CTDTERMINATE IS NULL THEN
								SET CTDTERMINATE=' ';
							END IF;
							
							IF CTDPRETERMINATEDATE IS NULL OR CTDPRETERMINATEDATE=' ' THEN
								SET CTDPRETERMINATEDATE=' ';
							END IF;
							
							IF CTDGUESTCARD IS NULL THEN
								SET CTDGUESTCARD=' ';
							END IF;
							IF CTD_ULDID!=USERSTAMP_ID THEN
								SET HEADERNAME=(SELECT CONCAT('CLP_ID',',','CED_REC_VER',',','CLP_STARTDATE',',','CLP_ENDDATE',',','CLP_TERMINATE',',','CLP_PRETERMINATE_DATE',',','CLP_GUEST_CARD',',','ULD_ID',',','CLP_TIMESTAMP'));
								SET OLD_CUSTOMER_RECORDS=(SELECT CONCAT(CLPID,'^^',CTDRECVER,'^^',CTDSTARTDATE,'^^',CTDENDDATE,'^^',CTDTERMINATE,'^^',CTDPRETERMINATEDATE,'^^',CTDGUESTCARD,'^^',CTD_ULDID,'^^',CTDTIMESTAMP));
							END IF;
							IF CTD_ULDID=USERSTAMP_ID THEN
							SET HEADERNAME=(SELECT CONCAT('CLP_ID',',','CED_REC_VER',',','CLP_STARTDATE',',','CLP_ENDDATE',',','CLP_TERMINATE',',','CLP_PRETERMINATE_DATE',',','CLP_GUEST_CARD',',','CLP_TIMESTAMP'));
							SET OLD_CUSTOMER_RECORDS=(SELECT CONCAT(CLPID,'^^',CTDRECVER,'^^',CTDSTARTDATE,'^^',CTDENDDATE,'^^',CTDTERMINATE,'^^',CTDPRETERMINATEDATE,'^^',CTDGUESTCARD,'^^',CTDTIMESTAMP));
							END IF;
							SET CUSTOMER_LENGTH=1;
							SET DLTEDRECORDDETAILS=' ';

							loop_label : LOOP
								SET HEADER_POSITION=(SELECT LOCATE(',', HEADERNAME,CUSTOMER_LENGTH));
								IF HEADER_POSITION<=0 THEN
									SET CUSTOMER_HEADER_NAME=HEADERNAME;
								ELSE
									SELECT SUBSTRING(HEADERNAME,CUSTOMER_LENGTH,HEADER_POSITION-1) INTO CUSTOMER_HEADER_NAME;
									SET HEADERNAME=(SELECT SUBSTRING(HEADERNAME,HEADER_POSITION+1));
								END IF;
		
								SET CUSTOMER_RECORDS_POSITION=(SELECT LOCATE('^^', OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH));
								IF CUSTOMER_RECORDS_POSITION<=0 THEN
									SET CUSTOMER_RECORDS=OLD_CUSTOMER_RECORDS;
								ELSE
									SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH,CUSTOMER_RECORDS_POSITION-1) INTO CUSTOMER_RECORDS;
									SET OLD_CUSTOMER_RECORDS=(SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_RECORDS_POSITION+2));
								END IF;
					
								IF CUSTOMER_RECORDS!=' ' THEN
								SET DLTEDRECORDDETAILS=(SELECT CONCAT(DLTEDRECORDDETAILS,',',CUSTOMER_HEADER_NAME,'=',CUSTOMER_RECORDS));
								END IF;
								
								IF CUSTOMER_RECORDS_POSITION<=0 THEN
									LEAVE  loop_label;
								END IF;
							END LOOP;
					
							SET LOCATION=(SELECT LOCATE(',', DLTEDRECORDDETAILS,CUSTOMER_LENGTH));
							SET DLTEDRECORDDETAILS=(SELECT SUBSTRING(DLTEDRECORDDETAILS,LOCATION+1));
			
							INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,ULD_ID)VALUES
							((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='DELETION'),CUSTOMERID,(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_LP_DETAILS'),
							DLTEDRECORDDETAILS,USERSTAMP_ID);

-- INSERT QUERY FOR TICKLER_HISTORY(CUSTOMER_FEE_DETAILS)
-- CUSTOMER FEE DETAILS
					
							SET CFRECVER = TEMP_CUST_SRCH_REC_VER;
							SET PAYMENTCPPID=(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=1);
							SET CCPAYMENTAMOUNT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=1);
							SET DEPOSIT_ID =(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=2);
							SET CCDEPOSIT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=2);
							SET PROCFEEID=(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=3);
							SET CCPROCESSINGFEE=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=3);
							SET AIRCONFIXEDID=(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=4);
							SET CCAIRCONFIXEDFEE=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=4);
							SET ELECTRICITYID=(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=5);
							SET CCELECTRICITYCAP=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=5);
							SET DRYCLEANID=(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=6);
							SET CCDRYCLEANFEE=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=6);
							SET AIRCONQUARTELYID=(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=7);
							SET CCAIRCONQUARTERLYFEE=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=7);
							SET CLEANINGID=(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=8);
							SET CCCHECKOUTCLEANINGFEE=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER = TEMP_CUST_SRCH_REC_VER AND CPP_ID=8);
					
							IF DEPOSIT_ID IS NULL THEN
								SET DEPOSIT_ID=' ';
							END IF;
							IF CCDEPOSIT IS NULL THEN
								SET CCDEPOSIT=' ';
							END IF;
							
							IF PROCFEEID IS NULL THEN
								SET PROCFEEID=' ';
							END IF;
							
							IF CCPROCESSINGFEE IS NULL THEN
								SET CCPROCESSINGFEE=' ';
							END IF;
							
							IF AIRCONFIXEDID IS NULL THEN
								SET AIRCONFIXEDID=' ';
							END IF;
					
							IF CCAIRCONFIXEDFEE IS NULL THEN
								SET CCAIRCONFIXEDFEE=' ';
							END IF;
							
							IF ELECTRICITYID IS NULL THEN
								SET ELECTRICITYID=' ';
							END IF;
							
							IF CCELECTRICITYCAP IS NULL THEN
								SET CCELECTRICITYCAP=' ';
							END IF;
							
							IF DRYCLEANID IS NULL THEN
								SET DRYCLEANID=' ';
							END IF;
					
							IF CCDRYCLEANFEE IS NULL THEN
								SET CCDRYCLEANFEE=' ';
							END IF;
							
							IF AIRCONQUARTELYID IS NULL THEN
								SET AIRCONQUARTELYID=' ';
							END IF;
							
							IF CCAIRCONQUARTERLYFEE IS NULL THEN
								SET CCAIRCONQUARTERLYFEE=' ';
							END IF;
					
							IF CLEANINGID IS NULL THEN
								SET CLEANINGID=' ';
							END IF;
							
							IF CCCHECKOUTCLEANINGFEE IS NULL THEN
								SET CCCHECKOUTCLEANINGFEE=' ';
							END IF;
							
							SET HEADERNAME=(SELECT CONCAT('CED_REC_VER',',','CPP_ID',',','CFD_AMOUNT',',','CPP_ID',',','CFD_AMOUNT',',','CPP_ID',',','CFD_AMOUNT',',','CPP_ID',',','CFD_AMOUNT',',','CPP_ID',',','CFD_AMOUNT',',','CPP_ID',',','CFD_AMOUNT',',','CPP_ID',',','CFD_AMOUNT',',','CPP_ID',',','CFD_AMOUNT'));
							SET OLD_CUSTOMER_RECORDS=(SELECT CONCAT(CFRECVER,'^^',PAYMENTCPPID,'^^',CCPAYMENTAMOUNT,'^^',DEPOSIT_ID,'^^',CCDEPOSIT,'^^',PROCFEEID,'^^',CCPROCESSINGFEE,'^^',AIRCONFIXEDID,'^^',CCAIRCONFIXEDFEE,'^^',ELECTRICITYID,'^^',CCELECTRICITYCAP,'^^',DRYCLEANID,'^^',CCDRYCLEANFEE,'^^',AIRCONQUARTELYID,'^^',CCAIRCONQUARTERLYFEE,'^^',CLEANINGID,'^^',CCCHECKOUTCLEANINGFEE));
							
							SET CUSTOMER_LENGTH=1;
							SET DLTEDRECORDDETAILS=' ';

							loop_label : LOOP
								SET HEADER_POSITION=(SELECT LOCATE(',', HEADERNAME,CUSTOMER_LENGTH));
								IF HEADER_POSITION<=0 THEN
									SET CUSTOMER_HEADER_NAME=HEADERNAME;
								ELSE
									SELECT SUBSTRING(HEADERNAME,CUSTOMER_LENGTH,HEADER_POSITION-1) INTO CUSTOMER_HEADER_NAME;
									SET HEADERNAME=(SELECT SUBSTRING(HEADERNAME,HEADER_POSITION+1));
								END IF;
		
								SET CUSTOMER_RECORDS_POSITION=(SELECT LOCATE('^^', OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH));
								IF CUSTOMER_RECORDS_POSITION<=0 THEN
									SET CUSTOMER_RECORDS=OLD_CUSTOMER_RECORDS;
								ELSE
									SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_LENGTH,CUSTOMER_RECORDS_POSITION-1) INTO CUSTOMER_RECORDS;
									SET OLD_CUSTOMER_RECORDS=(SELECT SUBSTRING(OLD_CUSTOMER_RECORDS,CUSTOMER_RECORDS_POSITION+2));
								END IF;
					
								IF CUSTOMER_RECORDS!=' ' THEN
								SET DLTEDRECORDDETAILS=(SELECT CONCAT(DLTEDRECORDDETAILS,',',CUSTOMER_HEADER_NAME,'=',CUSTOMER_RECORDS));
								END IF;
								
								IF CUSTOMER_RECORDS_POSITION<=0 THEN
									LEAVE  loop_label;
								END IF;
							END LOOP;
							
							SET LOCATION=(SELECT LOCATE(',', DLTEDRECORDDETAILS,CUSTOMER_LENGTH));
							SET DLTEDRECORDDETAILS=(SELECT SUBSTRING(DLTEDRECORDDETAILS,LOCATION+1));
							
							
			
							INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,ULD_ID)VALUES
							((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='DELETION'),CUSTOMERID,(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_FEE_DETAILS'),
							DLTEDRECORDDETAILS,USERSTAMP_ID);
					
					
							SET MINID=MINID+1;

						END WHILE;
						
						SET FOREIGN_KEY_CHECKS=0;
						DELETE FROM CUSTOMER WHERE CUSTOMER_ID=CUSTOMERID;
						DELETE FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID;
						DELETE FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID;
						DELETE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID;
						DELETE FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID;
						DELETE FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID;

						IF NOT EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER WHERE CUSTOMER_ID=CUSTOMERID)THEN
							IF NOT EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID)THEN
								IF NOT EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID)THEN
									IF NOT EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID)THEN
										IF NOT EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID)THEN
											IF NOT EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUSTOMERID)THEN
												SET FLAG=1;
											END IF;
										END IF;
									END IF;
								END IF;
							END IF;
						END IF;
				END IF;
			END IF;
		END IF;
	END IF;
END IF;

SET @DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',CUSTOMER_SEARCH_DELETION,''));
PREPARE DROPQUERYSTMT FROM @DROPQUERY;
EXECUTE DROPQUERYSTMT;

COMMIT;

END;