-- version:0.3 --sdate:20/09/2014 --edate:20/09/2014 --issue:535 --commentno#324 --desc:added the unitno n unit id from unit table --done by:RL
--version:0.2 --sdate:14/05/2014 --edate:14/05/2014 --issue:817 --commentno#55 --desc:changed temp table as dynamic --doneby:RL
-->version 0.1 -->start date:28/02/2014 end date:28/02/2014 -->issueno:535 comment no:#212,DESC:COMBINE HOUSEPAYMENT PAYMENT DETAILS FOR SEARCH --> by PUNITHA

DROP PROCEDURE IF EXISTS SP_BIZDLY_HOUSE_KEEPING_PAYMENT_SRCH_DTLS;
CREATE PROCEDURE SP_BIZDLY_HOUSE_KEEPING_PAYMENT_SRCH_DTLS(
IN USERSTAMP VARCHAR(50),
OUT BIZDLY_HOUSE_KEEPING_PAYMENTDTLS TEXT)

BEGIN

-- VARIABLE DECLARATION
	DECLARE USERSTAMP_ID INTEGER;
	DECLARE SYSDATEANDTIME VARCHAR(50);
	DECLARE SYSDATEANDULDID VARCHAR(50);
	DECLARE EHKP_UNITDTLS TEXT;
	DECLARE UNIT_DTL TEXT;

-- QUERY FOR ROLLBACK COMMAND
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
		IF(EHKP_UNITDTLS IS NOT NULL) THEN
			SET @EHKP_UNITDTLS_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',EHKP_UNITDTLS,''));
			PREPARE EHKP_UNITDTLS_DROPQUERY_STMT FROM @EHKP_UNITDTLS_DROPQUERY;
			EXECUTE EHKP_UNITDTLS_DROPQUERY_STMT;
		END IF;
		IF(UNIT_DTL IS NOT NULL) THEN
			SET @UNIT_DTL_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',UNIT_DTL,''));
			PREPARE UNIT_DTL_DROPQUERY_STMT FROM @UNIT_DTL_DROPQUERY;
			EXECUTE UNIT_DTL_DROPQUERY_STMT;
		END IF;
	END;
	
	START TRANSACTION;

-- QUERY FOR ALL SP_CHANGE_USERSTAMP_AS_ULDID
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);
	
	SET SYSDATEANDTIME=(SELECT SYSDATE());
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,' ',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,'-',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,':',''));
	SET SYSDATEANDULDID=(SELECT CONCAT(SYSDATEANDTIME,'_',USERSTAMP_ID));

-- QUERY FOR CREATE TEMP_EHKP_UNITDTLS TABLE
	SET EHKP_UNITDTLS = (SELECT CONCAT('TEMP_EHKP_UNITDTLS','_',SYSDATEANDULDID));

	SET @EHKP_UNITDTLS_CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',EHKP_UNITDTLS,'(
	ID INTEGER AUTO_INCREMENT,
	UNIT_ID INTEGER,
	PRIMARY KEY(ID))'));
	PREPARE EHKP_UNITDTLS_CREATEQUERY_STMT FROM @EHKP_UNITDTLS_CREATEQUERY;
	EXECUTE EHKP_UNITDTLS_CREATEQUERY_STMT;

-- QUERY FOR INSERT VALUES TEMP_EHKP_UNITDTLS TABLE FROM EXPENSE_HOUSEKEEPING_PAYMENT TABLE

	SET @EHKP_UNITDTLS_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',EHKP_UNITDTLS,'(UNIT_ID) 
	SELECT DISTINCT(UNIT_ID) FROM EXPENSE_HOUSEKEEPING_PAYMENT WHERE UNIT_ID IS NOT NULL ORDER BY UNIT_ID ASC'));
	PREPARE EHKP_UNITDTLS_INSERTQUERY_STMT FROM @EHKP_UNITDTLS_INSERTQUERY;
	EXECUTE EHKP_UNITDTLS_INSERTQUERY_STMT;

-- QUERY FOR CREATE TEMP_UNIT_DTL TABLE
	SET UNIT_DTL = (SELECT CONCAT('TEMP_UNIT_DTL','_',SYSDATEANDULDID));

	SET @UNIT_DTL_CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',UNIT_DTL,'(
	ID INTEGER AUTO_INCREMENT,
	UNIT_ID VARCHAR(50),
	UNIT_NO SMALLINT(4) UNSIGNED ZEROFILL,
	PRIMARY KEY(ID))'));
	PREPARE UNIT_DTL_CREATEQUERY_STMT FROM @UNIT_DTL_CREATEQUERY;
	EXECUTE UNIT_DTL_CREATEQUERY_STMT;

-- QUERY FOR INSERT VALUES TEMP_UNIT_DTL TABLE FROM UNIT TABLE(UNIT_ID NOT IN TEMP_EHKP_UNITDTLS TABLE)

	SET @UNIT_DTL_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',UNIT_DTL,'(UNIT_ID,UNIT_NO) 
	(SELECT CONCAT(UNIT_ID,'' ' ' '',''UNIT'') AS UNITID,UNIT_NO FROM UNIT WHERE UNIT_ID NOT IN (SELECT UNIT_ID FROM ',EHKP_UNITDTLS,'))'));
	PREPARE UNIT_DTL_INSERTQUERY_STMT FROM @UNIT_DTL_INSERTQUERY;
	EXECUTE UNIT_DTL_INSERTQUERY_STMT;

--  QUERY FOR CREATE TEMP_BIZDLY_HOUSE_KEEPING_PAYMENTDTLS TABLE
	SET BIZDLY_HOUSE_KEEPING_PAYMENTDTLS=(SELECT CONCAT('TEMP_BIZDLY_HOUSE_KEEPING_PAYMENTDTLS','_',SYSDATEANDULDID));
	
	SET @HOUSE_KEEPING_PAYMENTDTLS_CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',BIZDLY_HOUSE_KEEPING_PAYMENTDTLS,'(
	EHKP_ID INT NULL,
	UNIT_ID VARCHAR(50) NULL,
	UNIT_NO SMALLINT(4) UNSIGNED ZEROFILL NULL,
	EHKP_FOR_PERIOD DATE NULL,
	EHKP_PAID_DATE DATE NULL,
	EHKP_AMOUNT DECIMAL(7,2) NULL,
	EHKP_COMMENTS TEXT NULL,
	EHKP_USERSTAMP VARCHAR(50) NULL,
	EHKP_TIMESTAMP TIMESTAMP NULL)'));
	PREPARE HOUSE_KEEPING_PAYMENTDTLS_CREATEQUERY_STMT FROM @HOUSE_KEEPING_PAYMENTDTLS_CREATEQUERY;
	EXECUTE HOUSE_KEEPING_PAYMENTDTLS_CREATEQUERY_STMT;
	
--  QUERY FOR INSERT VALUES IN TEMP_BIZDLY_HOUSE_KEEPING_PAYMENTDTLS FROM EXPENSE_HOUSEKEEPING_PAYMENT TABLE
    SET @HOUSE_KEEPING_PAYMENTDTLS_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',BIZDLY_HOUSE_KEEPING_PAYMENTDTLS,'(
	EHKP_ID,UNIT_ID,UNIT_NO,EHKP_FOR_PERIOD,EHKP_PAID_DATE,EHKP_AMOUNT,EHKP_COMMENTS,EHKP_USERSTAMP,EHKP_TIMESTAMP)
	(SELECT EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_ID,CONCAT(EXPENSE_HOUSEKEEPING_PAYMENT.UNIT_ID,'' ' ' '',''UNIT'') AS UNITID,UNIT.UNIT_NO AS UNITNO,
	EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_FOR_PERIOD,EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_PAID_DATE,
	EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_AMOUNT,EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_COMMENTS,ULD.ULD_LOGINID AS EHKP_USERSTAMP, EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_TIMESTAMP 
	FROM EXPENSE_HOUSEKEEPING_PAYMENT  JOIN UNIT ON EXPENSE_HOUSEKEEPING_PAYMENT.UNIT_ID = UNIT.UNIT_ID,USER_LOGIN_DETAILS ULD  WHERE ULD.ULD_ID = EXPENSE_HOUSEKEEPING_PAYMENT.ULD_ID) UNION 
	(SELECT EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_ID,CONCAT(EXPENSE_HOUSEKEEPING_PAYMENT.EHKU_ID,'' ' ' '',''HKUNIT'') AS UNITID,
	EXPENSE_HOUSEKEEPING_UNIT.EHKU_UNIT_NO AS UNITNO,EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_FOR_PERIOD,
	EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_PAID_DATE,EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_AMOUNT,EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_COMMENTS,
	ULD.ULD_LOGINID AS EHKP_USERSTAMP,EXPENSE_HOUSEKEEPING_PAYMENT.EHKP_TIMESTAMP FROM EXPENSE_HOUSEKEEPING_PAYMENT
	JOIN EXPENSE_HOUSEKEEPING_UNIT ON EXPENSE_HOUSEKEEPING_PAYMENT.EHKU_ID = EXPENSE_HOUSEKEEPING_UNIT.EHKU_ID,
	USER_LOGIN_DETAILS ULD  WHERE  ULD.ULD_ID= EXPENSE_HOUSEKEEPING_PAYMENT.ULD_ID)'));
	PREPARE HOUSE_KEEPING_PAYMENTDTLS_INSERTQUERY_STMT FROM @HOUSE_KEEPING_PAYMENTDTLS_INSERTQUERY;
	EXECUTE HOUSE_KEEPING_PAYMENTDTLS_INSERTQUERY_STMT;

-- QUERY FOR INSERT VALUES IN TEMP_BIZDLY_HOUSE_KEEPING_PAYMENTDTLS FROM TEMP_UNIT_DTL TABLE
	SET @HOUSE_KEEPING_PAYMENTDTLSINSERTQUERY = (SELECT CONCAT('INSERT INTO ',BIZDLY_HOUSE_KEEPING_PAYMENTDTLS,'(
	UNIT_ID,UNIT_NO) (SELECT UNIT_ID,UNIT_NO FROM ',UNIT_DTL,')'));
	PREPARE HOUSE_KEEPING_PAYMENTDTLSINSERTQUERY_STMT FROM @HOUSE_KEEPING_PAYMENTDTLSINSERTQUERY;
	EXECUTE HOUSE_KEEPING_PAYMENTDTLSINSERTQUERY_STMT;

	IF(EHKP_UNITDTLS IS NOT NULL) THEN
		SET @EHKP_UNITDTLS_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',EHKP_UNITDTLS,''));
		PREPARE EHKP_UNITDTLS_DROPQUERY_STMT FROM @EHKP_UNITDTLS_DROPQUERY;
		EXECUTE EHKP_UNITDTLS_DROPQUERY_STMT;
	END IF;
	IF(UNIT_DTL IS NOT NULL) THEN
		SET @UNIT_DTL_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',UNIT_DTL,''));
		PREPARE UNIT_DTL_DROPQUERY_STMT FROM @UNIT_DTL_DROPQUERY;
		EXECUTE UNIT_DTL_DROPQUERY_STMT;
	END IF;

	COMMIT;

END;