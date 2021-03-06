DROP PROCEDURE IF EXISTS SP_TEMP_BIZDLY_ELECTRICITY_SEARCH;
CREATE PROCEDURE SP_TEMP_BIZDLY_ELECTRICITY_SEARCH(
IN START_DATE TEXT,
IN END_DATE TEXT,
IN FROM_INPUT TEXT,
IN TO_INPUT TEXT,
IN SEARCH_OPTION_ID INTEGER,
IN USERSTAMP VARCHAR(50),
OUT FINALTABLENAME TEXT)
BEGIN
	DECLARE MIN_ID INTEGER;
	DECLARE MAX_ID INTEGER;
	DECLARE FROM_AMOUNT DECIMAL(7,2);
	DECLARE TO_AMOUNT DECIMAL(7,2);
	DECLARE SEARCHOPTION VARCHAR(50);
	DECLARE USERSTAMP_ID INTEGER;
	DECLARE SYSDATEANDTIME VARCHAR(50);
	DECLARE SYSDATEANDULDID VARCHAR(50);
	DECLARE TEMP_ELECTRICITY_DETAILS TEXT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
		IF(TEMP_ELECTRICITY_DETAILS IS NOT NULL) THEN
			SET @D_TEMP_ELECTRICITY_DETAILS_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ELECTRICITY_DETAILS));
			PREPARE D_TEMP_ELECTRICITY_DETAILS_DROPQUERY_STMT FROM @D_TEMP_ELECTRICITY_DETAILS_DROPQUERY;
			EXECUTE D_TEMP_ELECTRICITY_DETAILS_DROPQUERY_STMT;
		END IF;
	END;
	START TRANSACTION;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);
	SET SYSDATEANDTIME=(SELECT SYSDATE());
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,' ',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,'-',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,':',''));
	SET SYSDATEANDULDID=(SELECT CONCAT(SYSDATEANDTIME,'_',USERSTAMP_ID));
	SET TEMP_ELECTRICITY_DETAILS=(SELECT CONCAT('TEMP_ELECTRICITY_DETAILS','_',SYSDATEANDULDID));
	SET @DYNAMICRECORD_QUERY=(SELECT CONCAT('CREATE TABLE ',TEMP_ELECTRICITY_DETAILS,'(
	ID INTEGER NOT NULL AUTO_INCREMENT,
	EEID INTEGER,
	UNITNO SMALLINT(4) UNSIGNED ZEROFILL,
	ECNID INTEGER,
	INVOICE_DATE DATE,
	FROM_PERIOD DATE,
	TO_PERIOD DATE,
	ECN_ID INTEGER,
	AMOUNT DECIMAL(7,2),
	COMMENTS TEXT,
	USERSTAMP VARCHAR(50),
	TTIMESTAMP VARCHAR(50),
	PRIMARY KEY(ID))'));
	PREPARE TEMP_ELECTRICITY_DETAILS_STMT from @DYNAMICRECORD_QUERY;
	EXECUTE TEMP_ELECTRICITY_DETAILS_STMT;
	IF(SEARCH_OPTION_ID = 159)THEN
		SET SEARCHOPTION = 'ELECTRICITY_COMMENTS';
		SET @COMMENTS_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TEMP_ELECTRICITY_DETAILS,'(EEID,UNITNO,ECNID,INVOICE_DATE,FROM_PERIOD,TO_PERIOD,ECN_ID,AMOUNT,COMMENTS,USERSTAMP,TTIMESTAMP) 
        SELECT EE.EE_ID,U.UNIT_NO,EDE.ECN_ID,EE.EE_INVOICE_DATE,EE.EE_FROM_PERIOD,EE.EE_TO_PERIOD,EE.ECN_ID,EE.EE_AMOUNT,EE.EE_COMMENTS,
        ULD.ULD_LOGINID,EE.EE_TIMESTAMP FROM EXPENSE_ELECTRICITY EE,EXPENSE_DETAIL_ELECTRICITY EDE, UNIT U, UNIT_DETAILS UD, USER_LOGIN_DETAILS 
        ULD WHERE EE.EE_INVOICE_DATE >= ','"',START_DATE,'"',' AND EE.EE_INVOICE_DATE <= ','"',END_DATE,'"',' AND EE.EE_COMMENTS=','"',FROM_INPUT,'"',' AND EE.EDE_ID=EDE.EDE_ID AND 
        U.UNIT_ID=EDE.UNIT_ID AND U.UNIT_ID=UD.UNIT_ID AND UD.UD_OBSOLETE IS NULL AND UD.UD_END_DATE>CURDATE() AND ULD.ULD_ID=EE.ULD_ID')); 
        PREPARE COMMENTS_INSERTQUERY_STMT FROM @COMMENTS_INSERTQUERY;
        EXECUTE COMMENTS_INSERTQUERY_STMT;
	END IF;
	IF(SEARCH_OPTION_ID = 160)THEN
		SET FROM_AMOUNT = FROM_INPUT;
		SET TO_AMOUNT = TO_INPUT;
		SET SEARCHOPTION = 'ELECTRICITY_DEPOSIT';
		SET @DEPOSITAMT_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TEMP_ELECTRICITY_DETAILS,'(EEID,UNITNO,ECNID,INVOICE_DATE,FROM_PERIOD,TO_PERIOD,ECN_ID,AMOUNT,COMMENTS,USERSTAMP,TTIMESTAMP) 
		SELECT EE.EE_ID,U.UNIT_NO,EDE.ECN_ID,EE.EE_INVOICE_DATE,EE.EE_FROM_PERIOD,EE.EE_TO_PERIOD,EE.ECN_ID,EE.EE_AMOUNT,EE.EE_COMMENTS,ULD.ULD_LOGINID,
		EE.EE_TIMESTAMP FROM EXPENSE_ELECTRICITY EE,EXPENSE_DETAIL_ELECTRICITY EDE, UNIT U, UNIT_DETAILS UD,USER_LOGIN_DETAILS ULD WHERE 
		EE.EE_INVOICE_DATE >= ','"',START_DATE,'"',' AND EE.EE_INVOICE_DATE <= ','"',END_DATE,'"',' AND EE.ECN_ID=135 AND EE.EE_AMOUNT >= ',FROM_AMOUNT,' AND EE.EE_AMOUNT <= ',TO_AMOUNT,' AND 
		EE.EDE_ID=EDE.EDE_ID AND U.UNIT_ID=EDE.UNIT_ID AND U.UNIT_ID=UD.UNIT_ID AND UD.UD_OBSOLETE IS NULL AND UD.UD_END_DATE>CURDATE() AND EE.ULD_ID=ULD.ULD_ID')); 
		PREPARE DEPOSITAMT_INSERTQUERY_STMT FROM @DEPOSITAMT_INSERTQUERY;
		EXECUTE DEPOSITAMT_INSERTQUERY_STMT;
	END IF;
	IF(SEARCH_OPTION_ID = 161)THEN
		SET FROM_AMOUNT = FROM_INPUT;
		SET TO_AMOUNT = TO_INPUT;
		SET SEARCHOPTION = 'ELECTRICITY_DEPOSIT_REFUND';
		SET @DEPOSITREFUNDAMT_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TEMP_ELECTRICITY_DETAILS,'(EEID,UNITNO,ECNID,INVOICE_DATE,FROM_PERIOD,TO_PERIOD,ECN_ID,AMOUNT,COMMENTS,USERSTAMP,TTIMESTAMP) 
		SELECT EE.EE_ID,U.UNIT_NO,EDE.ECN_ID,EE.EE_INVOICE_DATE,EE.EE_FROM_PERIOD,EE.EE_TO_PERIOD,EE.ECN_ID,EE.EE_AMOUNT,EE.EE_COMMENTS,ULD.ULD_LOGINID,
		EE.EE_TIMESTAMP FROM EXPENSE_ELECTRICITY EE,EXPENSE_DETAIL_ELECTRICITY EDE, UNIT U, UNIT_DETAILS UD,USER_LOGIN_DETAILS ULD WHERE 
		EE.EE_INVOICE_DATE >= ','"',START_DATE,'"',' AND EE.EE_INVOICE_DATE <= ','"',END_DATE,'"',' AND EE.ECN_ID=134 AND EE.EE_AMOUNT >= ',FROM_AMOUNT,' AND EE.EE_AMOUNT <= ',TO_AMOUNT,' AND 
		EE.EDE_ID=EDE.EDE_ID AND U.UNIT_ID=EDE.UNIT_ID AND U.UNIT_ID=UD.UNIT_ID AND UD.UD_OBSOLETE IS NULL AND UD.UD_END_DATE>CURDATE() AND EE.ULD_ID=ULD.ULD_ID')); 
		PREPARE DEPOSITREFUNDAMT_INSERTQUERY_STMT FROM @DEPOSITREFUNDAMT_INSERTQUERY;
		EXECUTE DEPOSITREFUNDAMT_INSERTQUERY_STMT;
	END IF;
	IF(SEARCH_OPTION_ID = 162)THEN
		SET SEARCHOPTION = 'ELECTRICITY_FROM_PERIOD';
		SET @FROMPERIOD_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TEMP_ELECTRICITY_DETAILS,'(EEID,UNITNO,ECNID,INVOICE_DATE,FROM_PERIOD,TO_PERIOD,ECN_ID,AMOUNT,COMMENTS,USERSTAMP,TTIMESTAMP) 
		SELECT EE.EE_ID,U.UNIT_NO,EDE.ECN_ID,EE.EE_INVOICE_DATE,EE.EE_FROM_PERIOD,EE.EE_TO_PERIOD,EE.ECN_ID,EE.EE_AMOUNT,EE.EE_COMMENTS,ULD.ULD_LOGINID,EE.EE_TIMESTAMP 
		FROM EXPENSE_ELECTRICITY EE, EXPENSE_DETAIL_ELECTRICITY EDE, UNIT U, UNIT_DETAILS UD,USER_LOGIN_DETAILS ULD WHERE EE.EE_FROM_PERIOD >= ','"',START_DATE,'"',' AND 
		EE.EE_FROM_PERIOD <= ','"',END_DATE,'"',' AND EE.EDE_ID=EDE.EDE_ID AND U.UNIT_ID=EDE.UNIT_ID AND U.UNIT_ID=UD.UNIT_ID AND UD.UD_OBSOLETE IS NULL AND UD.UD_END_DATE>CURDATE()
		AND EE.ULD_ID=ULD.ULD_ID'));  
		PREPARE FROMPERIOD_STMT FROM @FROMPERIOD_INSERTQUERY;
		EXECUTE FROMPERIOD_STMT;
	END IF;
	IF(SEARCH_OPTION_ID = 163)THEN
		SET FROM_AMOUNT = FROM_INPUT;
		SET TO_AMOUNT = TO_INPUT;
		SET SEARCHOPTION = 'ELECTRICITY_INVOICE_AMOUNT';
		SET @INVOICEAMT_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TEMP_ELECTRICITY_DETAILS,'(EEID,UNITNO,ECNID,INVOICE_DATE,FROM_PERIOD,TO_PERIOD,ECN_ID,AMOUNT,COMMENTS,USERSTAMP,TTIMESTAMP) 
		SELECT EE.EE_ID,U.UNIT_NO,EDE.ECN_ID,EE.EE_INVOICE_DATE,EE.EE_FROM_PERIOD,EE.EE_TO_PERIOD,EE.ECN_ID,EE.EE_AMOUNT,EE.EE_COMMENTS,ULD.ULD_LOGINID,EE.EE_TIMESTAMP 
		FROM EXPENSE_ELECTRICITY EE,EXPENSE_DETAIL_ELECTRICITY EDE, UNIT U, UNIT_DETAILS UD,USER_LOGIN_DETAILS ULD WHERE EE.EE_INVOICE_DATE >= ','"',START_DATE,'"',' AND 
		EE.EE_INVOICE_DATE <= ','"',END_DATE,'"',' AND EE.ECN_ID=133 AND EE.EE_AMOUNT >= ',FROM_AMOUNT,' AND EE.EE_AMOUNT <= ',TO_AMOUNT,' AND EE.EDE_ID=EDE.EDE_ID AND U.UNIT_ID=EDE.UNIT_ID AND 
		U.UNIT_ID=UD.UNIT_ID AND UD.UD_OBSOLETE IS NULL AND UD.UD_END_DATE>CURDATE() AND EE.ULD_ID=ULD.ULD_ID'));  
		PREPARE INVOICEAMT_INSERTQUERY_STMT FROM @INVOICEAMT_INSERTQUERY;
		EXECUTE INVOICEAMT_INSERTQUERY_STMT;
	END IF;
	IF(SEARCH_OPTION_ID = 164)THEN
		SET SEARCHOPTION = 'ELECTRICITY_INVOICE_DATE';
		SET @INVOICEDATE_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TEMP_ELECTRICITY_DETAILS,'(EEID,UNITNO,ECNID,INVOICE_DATE,FROM_PERIOD,TO_PERIOD,ECN_ID,AMOUNT,COMMENTS,USERSTAMP,TTIMESTAMP) 
		SELECT EE.EE_ID,U.UNIT_NO,EDE.ECN_ID,EE.EE_INVOICE_DATE,EE.EE_FROM_PERIOD,EE.EE_TO_PERIOD,EE.ECN_ID,EE.EE_AMOUNT,EE.EE_COMMENTS,ULD.ULD_LOGINID,EE.EE_TIMESTAMP 
		FROM EXPENSE_ELECTRICITY EE, EXPENSE_DETAIL_ELECTRICITY EDE, UNIT U, UNIT_DETAILS UD,USER_LOGIN_DETAILS ULD WHERE EE.EE_INVOICE_DATE >= ','"',START_DATE,'"',' AND 
		EE.EE_INVOICE_DATE <= ','"',END_DATE,'"',' AND EE.EDE_ID=EDE.EDE_ID AND U.UNIT_ID=EDE.UNIT_ID AND U.UNIT_ID=UD.UNIT_ID AND UD.UD_OBSOLETE IS NULL AND UD.UD_END_DATE>CURDATE()
		AND EE.ULD_ID=ULD.ULD_ID'));  
		PREPARE INVOICEDATE_INSERTQUERY_STMT FROM @INVOICEDATE_INSERTQUERY;
		EXECUTE INVOICEDATE_INSERTQUERY_STMT;
	END IF;
	IF(SEARCH_OPTION_ID = 165)THEN
		SET SEARCHOPTION = 'ELECTRICITY_INVOICE_TO';
		SET @INVOICETO_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TEMP_ELECTRICITY_DETAILS,'(EEID,UNITNO,ECNID,INVOICE_DATE,FROM_PERIOD,TO_PERIOD,ECN_ID,AMOUNT,COMMENTS,USERSTAMP,TTIMESTAMP) 
		SELECT EE.EE_ID,U.UNIT_NO,EDE.ECN_ID,EE.EE_INVOICE_DATE,EE.EE_FROM_PERIOD,EE.EE_TO_PERIOD,EE.ECN_ID,EE.EE_AMOUNT,EE.EE_COMMENTS,ULD.ULD_LOGINID,EE.EE_TIMESTAMP 
		FROM EXPENSE_ELECTRICITY EE, EXPENSE_DETAIL_ELECTRICITY EDE, UNIT U, UNIT_DETAILS UD ,USER_LOGIN_DETAILS ULD WHERE EE.EDE_ID=EDE.EDE_ID AND EDE.ECN_ID=',FROM_INPUT,'
		AND EE.EE_INVOICE_DATE >=','"',START_DATE,'"',' AND EE.EE_INVOICE_DATE <= ','"',END_DATE,'"',' AND U.UNIT_ID=EDE.UNIT_ID AND U.UNIT_ID=UD.UNIT_ID AND UD.UD_OBSOLETE IS NULL AND UD.UD_END_DATE>CURDATE() AND EE.ULD_ID=ULD.ULD_ID')); 
		PREPARE INVOICETO_INSERTQUERY_STMT FROM @INVOICETO_INSERTQUERY;
		EXECUTE INVOICETO_INSERTQUERY_STMT;
	END IF;
	IF(SEARCH_OPTION_ID = 166)THEN
		SET SEARCHOPTION = 'ELECTRICITY_TO_PERIOD';
		SET @TOPERIOD_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TEMP_ELECTRICITY_DETAILS,'(EEID,UNITNO,ECNID,INVOICE_DATE,FROM_PERIOD,TO_PERIOD,ECN_ID,AMOUNT,COMMENTS,USERSTAMP,TTIMESTAMP) 
		SELECT EE.EE_ID,U.UNIT_NO,EDE.ECN_ID,EE.EE_INVOICE_DATE,EE.EE_FROM_PERIOD,EE.EE_TO_PERIOD,EE.ECN_ID,EE.EE_AMOUNT,EE.EE_COMMENTS,ULD.ULD_LOGINID,EE.EE_TIMESTAMP 
		FROM EXPENSE_ELECTRICITY EE, EXPENSE_DETAIL_ELECTRICITY EDE, UNIT U, UNIT_DETAILS UD,USER_LOGIN_DETAILS ULD WHERE EE.EE_TO_PERIOD >= ','"',START_DATE,'"',' AND 
		EE.EE_TO_PERIOD <= ','"',END_DATE,'"',' AND EE.EDE_ID=EDE.EDE_ID AND U.UNIT_ID=EDE.UNIT_ID AND U.UNIT_ID=UD.UNIT_ID AND UD.UD_OBSOLETE IS NULL AND UD.UD_END_DATE>CURDATE() AND EE.ULD_ID=ULD.ULD_ID')); 
		PREPARE TOPERIOD_INSERTQUERY_STMT FROM @TOPERIOD_INSERTQUERY;
		EXECUTE TOPERIOD_INSERTQUERY_STMT;
	END IF;
	IF(SEARCH_OPTION_ID = 191)THEN
		SET SEARCHOPTION = 'ELECTRICITY_UNITNO';
		SET @UNITID_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TEMP_ELECTRICITY_DETAILS,'(EEID,UNITNO,ECNID,INVOICE_DATE,FROM_PERIOD,TO_PERIOD,ECN_ID,AMOUNT,COMMENTS,USERSTAMP,TTIMESTAMP) 
		SELECT EE.EE_ID,U.UNIT_NO,EDE.ECN_ID,EE.EE_INVOICE_DATE,EE.EE_FROM_PERIOD,EE.EE_TO_PERIOD,EE.ECN_ID,EE.EE_AMOUNT,EE.EE_COMMENTS,ULD.ULD_LOGINID,EE.EE_TIMESTAMP 
		FROM EXPENSE_ELECTRICITY EE,EXPENSE_DETAIL_ELECTRICITY EDE, UNIT U,USER_LOGIN_DETAILS ULD WHERE EE.EE_INVOICE_DATE >= ','"',START_DATE,'"',' AND EE.EE_INVOICE_DATE <= ','"',END_DATE,'"',' AND 
		EDE.UNIT_ID=',FROM_INPUT,' AND EE.EDE_ID=EDE.EDE_ID AND U.UNIT_ID=EDE.UNIT_ID AND EE.ULD_ID = ULD.ULD_ID')); 
		PREPARE UNITID_INSERTQUERY_STMT FROM @UNITID_INSERTQUERY;
		EXECUTE UNITID_INSERTQUERY_STMT;
	END IF;
	SET @TABLENAME=(SELECT CONCAT('TEMP_BIZDLY_',SEARCHOPTION ,'_','SEARCH'));
	SET FINALTABLENAME=(SELECT CONCAT(@TABLENAME,'_',SYSDATEANDULDID));
   SET @CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',FINALTABLENAME,'(
	EE_ID INTEGER,
	EE_UNITNO SMALLINT(4) UNSIGNED ZEROFILL,
	EE_INVOICE_TO TEXT,
	EE_INVOICE_DATE DATE,
	EE_FROM_PERIOD DATE,
	EE_TO_PERIOD DATE,
	EE_INVOICE_AMOUNT DECIMAL(7,2),
	EE_DEPOSIT DECIMAL(7,2),
	EE_DEPOSIT_REFUND DECIMAL(7,2),
	EE_COMMENTS TEXT,
	EE_USERSTAMP VARCHAR(50),
	EE_TIMESTAMP VARCHAR(50))'));
	PREPARE CREATEQUERYSTMT FROM @CREATEQUERY;
	EXECUTE CREATEQUERYSTMT;
	IF((SEARCH_OPTION_ID=159) OR (SEARCH_OPTION_ID=160) OR (SEARCH_OPTION_ID=161) OR (SEARCH_OPTION_ID=162)
	OR (SEARCH_OPTION_ID=163) OR (SEARCH_OPTION_ID=164) OR (SEARCH_OPTION_ID=165) OR (SEARCH_OPTION_ID=166)
	OR (SEARCH_OPTION_ID=191))THEN
		SET @MINID=(SELECT CONCAT('SELECT MIN(ID) INTO @MINIMUMID FROM ',TEMP_ELECTRICITY_DETAILS,''));
		PREPARE MINID_STMT FROM @MINID;
		EXECUTE MINID_STMT;
		SET @MAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAXIMUMID FROM ',TEMP_ELECTRICITY_DETAILS,''));
		PREPARE MAXID_STMT FROM @MAXID;
		EXECUTE MAXID_STMT;
		SET MIN_ID = @MINIMUMID;
		SET MAX_ID = @MAXIMUMID;
		WHILE (MAX_ID>=MIN_ID)DO
			SET @INSERTQUERY = (SELECT CONCAT('INSERT INTO ',FINALTABLENAME,'(EE_ID,EE_UNITNO,EE_INVOICE_TO,EE_INVOICE_DATE,EE_FROM_PERIOD,EE_TO_PERIOD,EE_INVOICE_AMOUNT,EE_DEPOSIT_REFUND,EE_DEPOSIT,EE_COMMENTS,EE_USERSTAMP,EE_TIMESTAMP)
			VALUES ((SELECT EEID FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,'),
			(SELECT UNITNO FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,'),
			(SELECT ECN_DATA FROM EXPENSE_CONFIGURATION WHERE ECN_ID=(SELECT ECNID FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,')),
			(SELECT INVOICE_DATE FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,'),
			(SELECT FROM_PERIOD FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,'),
			(SELECT TO_PERIOD FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,'),
			(SELECT AMOUNT FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,' AND ECN_ID=133),
			(SELECT AMOUNT FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,' AND ECN_ID=134),
			(SELECT AMOUNT FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,' AND ECN_ID=135),
			(SELECT COMMENTS FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,'),
			(SELECT USERSTAMP FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,'),
			(SELECT TTIMESTAMP FROM ',TEMP_ELECTRICITY_DETAILS,' WHERE ID=',MIN_ID,'))'));
			PREPARE INSERTQUERYSTMT FROM @INSERTQUERY;
			EXECUTE INSERTQUERYSTMT;
		SET MIN_ID = MIN_ID+1;
		END WHILE;
	END IF;
	SET @D_TEMP_ELECTRICITY_DETAILS_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ELECTRICITY_DETAILS));
	PREPARE D_TEMP_ELECTRICITY_DETAILS_DROPQUERY_STMT FROM @D_TEMP_ELECTRICITY_DETAILS_DROPQUERY;
	EXECUTE D_TEMP_ELECTRICITY_DETAILS_DROPQUERY_STMT;
  COMMIT;
END;