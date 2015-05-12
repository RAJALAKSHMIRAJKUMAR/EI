	DROP PROCEDURE IF EXISTS SP_CUSTOMER_SEARCH_PREVIOUS_RECVER_START_ENADATE;
	CREATE PROCEDURE SP_CUSTOMER_SEARCH_PREVIOUS_RECVER_START_ENADATE(IN CUSTOMERID INTEGER,IN RECVER INTEGER,IN UNIT INTEGER,IN USERSTAMP VARCHAR(50),OUT CUSTOMER_SEARCH_PREVIOUS_RECVER_TMPTBL TEXT)
	BEGIN
	 DECLARE NR_STARTDATE VARCHAR(15);
	 DECLARE PR_ENDDATE VARCHAR(15);
	 DECLARE PRE_RECVERID INTEGER;
	 DECLARE NEXT_RECVERID INTEGER;
	 DECLARE MAX_RECVER INTEGER;
	 DECLARE PRE_ENDDATE VARCHAR(15);
	 DECLARE PR_PRETERMINATEDATE VARCHAR(15);
	 DECLARE END_FLAG INTEGER;
	 DECLARE START_FLAG INTEGER;
	 DECLARE UNIT_MAX_RECVER INTEGER;
	 DECLARE CUSTOMER_SEARCH_PREVIOUS_TBL TEXT;
	 DECLARE USERSTAMP_ID INT;
	 DECLARE RECHECKIN_FLAG CHAR(4);
	 DECLARE TERMP_ENDDATE DATE;
	 DECLARE TERM_CLPPRETERMINATEDATE DATE;
	 DECLARE TER_ENDDATE DATE;
	 DECLARE CANCELDATE DATE;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
   ROLLBACK;
   END;
   START TRANSACTION;
		CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
		SET USERSTAMP_ID=(SELECT @ULDID);
		SET CUSTOMER_SEARCH_PREVIOUS_TBL=(SELECT CONCAT('TEMP_CUSTOMER_PREVIOUS_RECVER_DATES',SYSDATE()));
		SET CUSTOMER_SEARCH_PREVIOUS_TBL=(SELECT REPLACE(CUSTOMER_SEARCH_PREVIOUS_TBL,' ',''));
		SET CUSTOMER_SEARCH_PREVIOUS_TBL=(SELECT REPLACE(CUSTOMER_SEARCH_PREVIOUS_TBL,'-',''));
		SET CUSTOMER_SEARCH_PREVIOUS_TBL=(SELECT REPLACE(CUSTOMER_SEARCH_PREVIOUS_TBL,':',''));
		SET CUSTOMER_SEARCH_PREVIOUS_RECVER_TMPTBL=(SELECT CONCAT(CUSTOMER_SEARCH_PREVIOUS_TBL,'_',USERSTAMP_ID)); 
	 SET PRE_RECVERID=RECVER-1;
	 SET NEXT_RECVERID=RECVER+1;
	 SET NR_STARTDATE=(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=NEXT_RECVERID AND CLP_GUEST_CARD IS NULL);
	 SET PR_ENDDATE=(SELECT CLP_ENDDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=PRE_RECVERID AND CLP_GUEST_CARD IS NULL);
	 SET PR_PRETERMINATEDATE=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=PRE_RECVERID AND CLP_GUEST_CARD IS NULL);
	 IF PR_PRETERMINATEDATE IS NULL THEN
	 SET PRE_ENDDATE=PR_ENDDATE;
	 ELSE
	 SET PRE_ENDDATE=PR_PRETERMINATEDATE;
	 END IF;
	 SET CANCELDATE=(SELECT CED_CANCEL_DATE FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVER);
	 SET RECHECKIN_FLAG=(SELECT CED_RECHECKIN FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVER);
	 SET UNIT_MAX_RECVER=(SELECT MAX(CED_REC_VER) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT));
	 SET MAX_RECVER=(SELECT MAX(CED_REC_VER) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CLP_GUEST_CARD IS NULL);
	 SET TERMP_ENDDATE=(SELECT CLP_ENDDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVER AND CLP_GUEST_CARD IS NULL);
	 SET TERM_CLPPRETERMINATEDATE=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVER AND CLP_GUEST_CARD IS NULL);
	  IF TERM_CLPPRETERMINATEDATE IS NULL THEN
	  SET TER_ENDDATE=TERMP_ENDDATE;
	 ELSE
	  SET TER_ENDDATE=TERM_CLPPRETERMINATEDATE;
	 END IF;
	  IF RECVER=MAX_RECVER AND TERM_CLPPRETERMINATEDATE IS NULL AND UNIT_MAX_RECVER=MAX_RECVER AND TERMP_ENDDATE > CURDATE() AND CANCELDATE IS NULL THEN
	 SET END_FLAG=1;
	 ELSE
	 SET END_FLAG=0;
	 END IF;
	 IF ((RECVER=1 OR MAX_RECVER=1) AND CANCELDATE IS NULL) THEN
	 SET START_FLAG=1;
	 ELSE
	 SET START_FLAG=0;
	 END IF;
	  IF NR_STARTDATE IS NULL THEN
	 SET NR_STARTDATE='NULL';
	 END IF;
	 IF PRE_ENDDATE IS NULL THEN
	 SET PRE_ENDDATE='NULL';
	 END IF;
	 IF RECHECKIN_FLAG IS NOT NULL and CANCELDATE IS NOT NULL THEN
	 SET START_FLAG=1;
	 ELSE
	 SET START_FLAG=START_FLAG;
	 END IF;
	 IF CURDATE()>TER_ENDDATE AND CANCELDATE IS NULL THEN
	  SET START_FLAG=0;
	 END IF;
			SET @CREATE_TEMP_CUSTOMER_PREVIOUS_RECVER_DATES=(SELECT CONCAT('CREATE TABLE ',CUSTOMER_SEARCH_PREVIOUS_RECVER_TMPTBL,'(NEXT_RECVER_STARTDATE VARCHAR(15),PRE_RECVER_ENDDATE VARCHAR(15),MAX_RECVER INTEGER,ENDFLAG INTEGER,STARTFLAG INTEGER)'));
			PREPARE CREATE_TEMP_CUSTOMER_PREVIOUS_RECVER_DATES_STMT FROM @CREATE_TEMP_CUSTOMER_PREVIOUS_RECVER_DATES;
			EXECUTE CREATE_TEMP_CUSTOMER_PREVIOUS_RECVER_DATES_STMT;
			SET @INSERT_TEMP_CUSTOMER_PREVIOUS_RECVER_DATES=(SELECT CONCAT('INSERT INTO ',CUSTOMER_SEARCH_PREVIOUS_RECVER_TMPTBL,' (NEXT_RECVER_STARTDATE,PRE_RECVER_ENDDATE,MAX_RECVER,ENDFLAG,STARTFLAG) VALUES(','"',NR_STARTDATE,'"',',','"',PRE_ENDDATE,'"',',',MAX_RECVER,',',END_FLAG,',',START_FLAG,')'));
			PREPARE INSERT_TEMP_CUSTOMER_PREVIOUS_RECVER_DATES_STMT FROM @INSERT_TEMP_CUSTOMER_PREVIOUS_RECVER_DATES;
			EXECUTE INSERT_TEMP_CUSTOMER_PREVIOUS_RECVER_DATES_STMT;
      COMMIT;
	  END;