DROP PROCEDURE IF EXISTS SP_ACTIVE_CUSTOMERLIST;
CREATE PROCEDURE SP_ACTIVE_CUSTOMERLIST(
	IN FORPERIOD VARCHAR(20),
	IN USERSTAMP VARCHAR(50),
	OUT TEMP_OPL_ACTIVECUSTOMER_TABLE TEXT,
	OUT TEMP_OPL_SORTEDACTIVECUSTOMER_TABLE TEXT
	)
BEGIN
	DECLARE MONTHNUMBER VARCHAR(10);
	DECLARE MONTHSTARTDATE DATE;
	DECLARE MONTHENDDATE DATE;
	DECLARE USERSTAMP_ID TEXT;
	DECLARE SYSDATEANDTIME VARCHAR(50);
	DECLARE SYSDATEANDULDID VARCHAR(50);
    DECLARE TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE TEXT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
	ROLLBACK; 
	IF TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE IS NOT NULL THEN
	SET @TEMP_OPL_SORTED_ACTIVECUSTOMER_DROP=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE));
	PREPARE TEMP_OPL_SORTED_ACTIVECUSTOMER_DROP_STMT FROM @TEMP_OPL_SORTED_ACTIVECUSTOMER_DROP;
	EXECUTE TEMP_OPL_SORTED_ACTIVECUSTOMER_DROP_STMT;
	END IF;
END;
START TRANSACTION;
	SET MONTHNUMBER=(SELECT SUBSTRING(FORPERIOD,1,3));
	SET MONTHSTARTDATE=(SELECT CONCAT((SELECT SUBSTRING_INDEX(FORPERIOD, '-', -1)),'-',(SELECT MONTH(STR_TO_DATE(MONTHNUMBER,'%b'))),'-','01'));
	SET MONTHENDDATE=(SELECT LAST_DAY(MONTHSTARTDATE));
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);
	SET SYSDATEANDTIME=(SELECT SYSDATE());
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,' ',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,'-',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,':',''));
	SET SYSDATEANDULDID=(SELECT CONCAT(SYSDATEANDTIME,'_',USERSTAMP_ID));
	SET TEMP_OPL_ACTIVECUSTOMER_TABLE=(SELECT CONCAT('TEMP_OPL_ACTIVECUSTOMER_TABLE',SYSDATEANDULDID));
	SET @TEMP_OPL_ACTIVE_CUSTOMER_CREATETABLEQUERY=(SELECT CONCAT('CREATE TABLE ',TEMP_OPL_ACTIVECUSTOMER_TABLE,'(SNO INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,CUSTOMERID INTEGER,UNIT_NO INTEGER(4) UNSIGNED ZEROFILL,CUSTOMERNAME VARCHAR(60),CED_REC_VER INTEGER,STARTDATE DATE,ENDDATE DATE,PAYMENT_AMOUNT DECIMAL(7,2),DEPOSIT DECIMAL(7,2),PROCESSING_FEE DECIMAL(7,2),CLP_TERMINATE CHAR(4),PRETERMINATE CHAR(4),PRETERMINATEDATE DATE,COMMENTS TEXT)'));
	PREPARE TEMP_OPL_ACTIVE_CUSTOMER_CREATETABLE_STMT FROM @TEMP_OPL_ACTIVE_CUSTOMER_CREATETABLEQUERY;
	EXECUTE TEMP_OPL_ACTIVE_CUSTOMER_CREATETABLE_STMT;
	SET @TEMP_OPL_ACTIVE_CUSTOMER_INSERTQUERY=(SELECT CONCAT('INSERT INTO ',TEMP_OPL_ACTIVECUSTOMER_TABLE,'(CUSTOMERID,UNIT_NO,CED_REC_VER,STARTDATE,ENDDATE,PRETERMINATEDATE) SELECT CUSTOMER_ID,UNIT_NO,CED_REC_VER,CLP_STARTDATE,CLP_ENDDATE,CLP_PRETERMINATE_DATE FROM VW_PAYMENT_CURRENT_ACTIVE_CUSTOMER WHERE CLP_ENDDATE>=CURDATE()AND (CLP_PRETERMINATE_DATE IS NULL OR CLP_PRETERMINATE_DATE>=CURDATE())'));
	PREPARE TEMP_OPL_ACTIVE_CUSTOMER_INSERTQUERY_STMT FROM @TEMP_OPL_ACTIVE_CUSTOMER_INSERTQUERY;
	EXECUTE TEMP_OPL_ACTIVE_CUSTOMER_INSERTQUERY_STMT;
	SET @TEMP_OPL_TERM_CUSTOMER_INSERTQUERY=(SELECT CONCAT('INSERT INTO ',TEMP_OPL_ACTIVECUSTOMER_TABLE,'(CUSTOMERID,UNIT_NO,CED_REC_VER,STARTDATE,ENDDATE,PRETERMINATEDATE) SELECT C.CUSTOMER_ID,U.UNIT_NO,CED.CED_REC_VER,CTD.CLP_STARTDATE,CTD.CLP_ENDDATE,CTD.CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS CTD,CUSTOMER C,CUSTOMER_ENTRY_DETAILS CED,UNIT U,UNIT_ACCESS_STAMP_DETAILS UASD WHERE  IF (CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_PRETERMINATE_DATE BETWEEN ','"',MONTHSTARTDATE,'"',' AND CURDATE(),CLP_ENDDATE BETWEEN ','"',MONTHSTARTDATE,'"',' AND CURDATE())  AND CTD.CLP_GUEST_CARD IS NULL AND CTD.CLP_STARTDATE<=CURDATE() AND C.CUSTOMER_ID=CED.CUSTOMER_ID AND CED.CED_REC_VER=CTD.CED_REC_VER AND CED.CUSTOMER_ID=CTD.CUSTOMER_ID AND CED.UASD_ID=UASD.UASD_ID AND U.UNIT_ID=UASD.UNIT_ID AND CTD.CLP_TERMINATE IS NOT NULL ORDER BY C.CUSTOMER_ID,CED.CED_REC_VER'));
	PREPARE TEMP_OPL_TERM_CUSTOMER_INSERTQUERY_STMT FROM @TEMP_OPL_TERM_CUSTOMER_INSERTQUERY;
	EXECUTE TEMP_OPL_TERM_CUSTOMER_INSERTQUERY_STMT;
	SET @TEMP_OPL_TERM_CUSTOMER_DIFFINSERTQUERY=(SELECT CONCAT('INSERT INTO ',TEMP_OPL_ACTIVECUSTOMER_TABLE,'(CUSTOMERID,UNIT_NO,CED_REC_VER,STARTDATE,ENDDATE,PRETERMINATEDATE) SELECT C.CUSTOMER_ID,U.UNIT_NO,CED.CED_REC_VER,CTD.CLP_STARTDATE,CTD.CLP_ENDDATE,CTD.CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS CTD,CUSTOMER C,CUSTOMER_ENTRY_DETAILS CED,UNIT U,UNIT_ACCESS_STAMP_DETAILS UASD WHERE  CTD.CLP_PRETERMINATE_DATE BETWEEN ','"',MONTHSTARTDATE,'"',' AND CURDATE() AND CTD.CLP_GUEST_CARD IS NULL AND CTD.CLP_STARTDATE<=CURDATE() AND C.CUSTOMER_ID=CED.CUSTOMER_ID AND CED.CED_REC_VER=CTD.CED_REC_VER AND CED.CUSTOMER_ID=CTD.CUSTOMER_ID AND CED.UASD_ID=UASD.UASD_ID AND U.UNIT_ID=UASD.UNIT_ID AND CTD.CLP_TERMINATE IS NULL ORDER BY C.CUSTOMER_ID,CED.CED_REC_VER'));
	PREPARE TEMP_OPL_TERM_CUSTOMER_DIFFINSERTQUERY_STMT FROM @TEMP_OPL_TERM_CUSTOMER_DIFFINSERTQUERY;
	EXECUTE TEMP_OPL_TERM_CUSTOMER_DIFFINSERTQUERY_STMT;
	SET @ACTIVECUSTOMERMAXID=(SELECT CONCAT('SELECT MAX(SNO) INTO @MAX_ID FROM ',TEMP_OPL_ACTIVECUSTOMER_TABLE));
	PREPARE ACTIVECUSTOMERMAXID_STMT FROM @ACTIVECUSTOMERMAXID;
	EXECUTE ACTIVECUSTOMERMAXID_STMT;
	SET @ACTIVECUSTOMERMINID=(SELECT CONCAT('SELECT MIN(SNO) INTO @MIN_ID FROM ',TEMP_OPL_ACTIVECUSTOMER_TABLE));
	PREPARE ACTIVECUSTOMERMINID_STMT FROM @ACTIVECUSTOMERMINID;
	EXECUTE ACTIVECUSTOMERMINID_STMT;
	WHILE @MIN_ID<= @MAX_ID DO
		SET @CUSTIDQUERY=(SELECT CONCAT('SELECT CUSTOMERID INTO @CUSTID FROM ',TEMP_OPL_ACTIVECUSTOMER_TABLE,' WHERE SNO=@MIN_ID'));
		PREPARE CUSTID_STMT FROM @CUSTIDQUERY;
		EXECUTE CUSTID_STMT;
		SET @RECVERQUERY=(SELECT CONCAT('SELECT CED_REC_VER INTO @CED_REC_VER FROM ',TEMP_OPL_ACTIVECUSTOMER_TABLE,' WHERE SNO=@MIN_ID'));
		PREPARE RECVER_STMT FROM @RECVERQUERY;
		EXECUTE RECVER_STMT;
		SET @CUSTOMERNAME=(SELECT CONCAT(CUSTOMER_FIRST_NAME,' ',CUSTOMER_LAST_NAME) AS CUSTOMERNAME FROM CUSTOMER WHERE CUSTOMER_ID=@CUSTID);
		SET @PAYMENT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=@CUSTID AND CED_REC_VER=@CED_REC_VER AND CPP_ID=1);
		SET @DEPOSIT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=@CUSTID AND CED_REC_VER=@CED_REC_VER AND CPP_ID=2);
		SET @PROCESS=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=@CUSTID AND CED_REC_VER=@CED_REC_VER AND CPP_ID=3);
		SET @COMMENTS=(SELECT CPD_COMMENTS FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=@CUSTID);
		SET @PRETERMINATE=(SELECT CED_PRETERMINATE FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=@CUSTID AND CED_REC_VER=@CED_REC_VER);
		SET @TERMINATE=(SELECT CLP_TERMINATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=@CUSTID AND CED_REC_VER=@CED_REC_VER AND CLP_GUEST_CARD IS NULL);
		SET @ACTIVECUSTOMERLISTUPDATE=(SELECT CONCAT('UPDATE ',TEMP_OPL_ACTIVECUSTOMER_TABLE,' SET CUSTOMERNAME=@CUSTOMERNAME,PAYMENT_AMOUNT=@PAYMENT,DEPOSIT=@DEPOSIT,PROCESSING_FEE=@PROCESS,COMMENTS=@COMMENTS,PRETERMINATE=@PRETERMINATE,CLP_TERMINATE=@TERMINATE WHERE SNO=@MIN_ID'));
		PREPARE ACTIVECUSTOMERLISTUPDATE_STMT FROM @ACTIVECUSTOMERLISTUPDATE;
		EXECUTE ACTIVECUSTOMERLISTUPDATE_STMT;
		SET @MIN_ID=@MIN_ID+1;
	END WHILE;
	SET TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE=(SELECT CONCAT('TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE',SYSDATEANDULDID));
	SET @TEMP_OPL_SORTACTIVE_CUSTOMER_CREATETABLEQUERY=(SELECT CONCAT('CREATE TABLE ',TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE,'(SNO INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,CUSTOMERID INTEGER,CED_REC_VER INTEGER)'));
	PREPARE TEMP_SORTOPL_ACTIVE_CUSTOMER_CREATETABLE_STMT FROM @TEMP_OPL_SORTACTIVE_CUSTOMER_CREATETABLEQUERY;
	EXECUTE TEMP_SORTOPL_ACTIVE_CUSTOMER_CREATETABLE_STMT;	
	SET @TEMP_OPL_SORTACTIVE_CUSTOMER_INSERTQUERY=(SELECT CONCAT('INSERT INTO ',TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE,'(CUSTOMERID,CED_REC_VER) SELECT CUSTOMERID,MAX(CED_REC_VER) FROM ',TEMP_OPL_ACTIVECUSTOMER_TABLE,' GROUP BY CUSTOMERID'));
	PREPARE TEMP_OPL_SORTACTIVE_CUSTOMER_INSERTQUERY_STMT FROM @TEMP_OPL_SORTACTIVE_CUSTOMER_INSERTQUERY;
	EXECUTE TEMP_OPL_SORTACTIVE_CUSTOMER_INSERTQUERY_STMT;	
	SET @SORTACTIVECUSTOMERMAXID=(SELECT CONCAT('SELECT MAX(SNO) INTO @SORTMAX_ID FROM ',TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE));
	PREPARE SORTACTIVECUSTOMERMAXID_STMT FROM @SORTACTIVECUSTOMERMAXID;
	EXECUTE SORTACTIVECUSTOMERMAXID_STMT;	
	SET @SORTACTIVECUSTOMERMINID=(SELECT CONCAT('SELECT MIN(SNO) INTO @SORTMIN_ID FROM ',TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE));
	PREPARE SORTACTIVECUSTOMERMINID_STMT FROM @SORTACTIVECUSTOMERMINID;
	EXECUTE SORTACTIVECUSTOMERMINID_STMT;	
	SET TEMP_OPL_SORTEDACTIVECUSTOMER_TABLE=(SELECT CONCAT('TEMP_OPL_SORTEDACTIVECUSTOMER_TABLE',SYSDATEANDULDID));
	SET @TEMP_OPL_SORTED_ACTIVE_CUSTOMER_CREATETABLEQUERY=(SELECT CONCAT('CREATE TABLE ',TEMP_OPL_SORTEDACTIVECUSTOMER_TABLE,'(SNO INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,CUSTOMERID INTEGER,UNIT_NO INTEGER(4) UNSIGNED ZEROFILL,CUSTOMERNAME VARCHAR(60),CED_REC_VER INTEGER,STARTDATE DATE,ENDDATE DATE,PAYMENT_AMOUNT DECIMAL(7,2),DEPOSIT DECIMAL(7,2),PROCESSING_FEE DECIMAL(7,2),CLP_TERMINATE CHAR(4),PRETERMINATE CHAR(4),PRETERMINATEDATE DATE,COMMENTS TEXT)'));
	PREPARE TEMP_OPL_SORTED_ACTIVE_CUSTOMER_CREATETABLE_STMT FROM @TEMP_OPL_SORTED_ACTIVE_CUSTOMER_CREATETABLEQUERY;
	EXECUTE TEMP_OPL_SORTED_ACTIVE_CUSTOMER_CREATETABLE_STMT;	
	WHILE @SORTMIN_ID<= @SORTMAX_ID DO	
	SET @SORTCUSTIDQUERY=(SELECT CONCAT('SELECT CUSTOMERID INTO @SORTCUSTID FROM ',TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE,' WHERE SNO=@SORTMIN_ID'));
	PREPARE SORTCUSTID_STMT FROM @SORTCUSTIDQUERY;
	EXECUTE SORTCUSTID_STMT;	
	SET @RECVERQUERY=(SELECT CONCAT('SELECT CED_REC_VER INTO @SORT_CED_REC_VER FROM ',TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE,' WHERE SNO=@SORTMIN_ID'));
    PREPARE RECVER_STMT FROM @RECVERQUERY;
    EXECUTE RECVER_STMT;
	SET @SORTUNITNO=(SELECT U.UNIT_NO FROM UNIT U,CUSTOMER_ENTRY_DETAILS CED WHERE CED.CUSTOMER_ID=@SORTCUSTID AND CED.CED_REC_VER=@SORT_CED_REC_VER AND U.UNIT_ID=CED.UNIT_ID);
	SET @SORTCUSTOMERNAME=(SELECT CONCAT(CUSTOMER_FIRST_NAME,' ',CUSTOMER_LAST_NAME) AS CUSTOMERNAME FROM CUSTOMER WHERE CUSTOMER_ID=@SORTCUSTID);
	SET @SORTSTARTDATE=(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=@SORTCUSTID AND CED_REC_VER=@SORT_CED_REC_VER AND CLP_GUEST_CARD IS NULL);
	SET @SORTENDDATE=(SELECT CLP_ENDDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=@SORTCUSTID AND CED_REC_VER=@SORT_CED_REC_VER AND CLP_GUEST_CARD IS NULL);
	SET @SORTPAYMENT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=@SORTCUSTID AND CED_REC_VER=@SORT_CED_REC_VER AND CPP_ID=1);
	SET @SORTDEPOSIT=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=@SORTCUSTID AND CED_REC_VER=@SORT_CED_REC_VER AND CPP_ID=2);
	SET @SORTPROCESS=(SELECT CFD_AMOUNT FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=@SORTCUSTID AND CED_REC_VER=@SORT_CED_REC_VER AND CPP_ID=3);
	SET @SORTCOMMENTS=(SELECT CPD_COMMENTS FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=@SORTCUSTID);
	SET @SORTPRETERMINATE=(SELECT CED_PRETERMINATE FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=@SORTCUSTID AND CED_REC_VER=@SORT_CED_REC_VER);
 	SET @SORTTERMINATE =(SELECT CLP_TERMINATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=@SORTCUSTID AND CED_REC_VER=@SORT_CED_REC_VER AND CLP_GUEST_CARD IS NULL);
	SET @SORTPRETERM_DATE=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=@SORTCUSTID AND CED_REC_VER=@SORT_CED_REC_VER AND CLP_GUEST_CARD IS NULL);
	SET @TEMP_OPL_SORTED_ACTIVE_CUSTOMER_INSERTQUERY=(SELECT CONCAT('INSERT INTO ',TEMP_OPL_SORTEDACTIVECUSTOMER_TABLE,'(CUSTOMERID,UNIT_NO,CUSTOMERNAME,CED_REC_VER,STARTDATE,ENDDATE,PAYMENT_AMOUNT,DEPOSIT,PROCESSING_FEE,COMMENTS,PRETERMINATE,CLP_TERMINATE,PRETERMINATEDATE) VALUES(@SORTCUSTID,@SORTUNITNO,@SORTCUSTOMERNAME,@SORT_CED_REC_VER,@SORTSTARTDATE,@SORTENDDATE,@SORTPAYMENT,@SORTDEPOSIT,@SORTPROCESS,@SORTCOMMENTS,@SORTPRETERMINATE,@SORTTERMINATE,@SORTPRETERM_DATE)'));
	PREPARE TEMP_OPL_SORTED_ACTIVE_CUSTOMER_INSERTQUERY_STMT FROM @TEMP_OPL_SORTED_ACTIVE_CUSTOMER_INSERTQUERY;
	EXECUTE TEMP_OPL_SORTED_ACTIVE_CUSTOMER_INSERTQUERY_STMT;	
	SET @SORTMIN_ID=@SORTMIN_ID+1;
	END WHILE;	
	SET @TEMP_OPL_SORTED_ACTIVECUSTOMER_DROP=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_OPL_SORTED_ACTIVECUSTOMER_TABLE));
	PREPARE TEMP_OPL_SORTED_ACTIVECUSTOMER_DROP_STMT FROM @TEMP_OPL_SORTED_ACTIVECUSTOMER_DROP;
	EXECUTE TEMP_OPL_SORTED_ACTIVECUSTOMER_DROP_STMT;
	COMMIT;
	END;