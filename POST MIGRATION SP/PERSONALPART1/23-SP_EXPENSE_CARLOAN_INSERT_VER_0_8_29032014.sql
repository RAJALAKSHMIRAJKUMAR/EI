DROP PROCEDURE IF EXISTS SP_EXPENSE_CARLOAN_INSERT;
CREATE PROCEDURE SP_EXPENSE_CARLOAN_INSERT(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
	DECLARE DONE INT DEFAULT FALSE;
	DECLARE PEID INTEGER;
	DECLARE PAIDDATE DATE;
	DECLARE FROMPERIOD DATE;
	DECLARE TOPERIOD DATE;
	DECLARE CARLOANAMOUNT DECIMAL(7,2);
	DECLARE COMMENTS TEXT;
	DECLARE CARLOAN_USERSTAMP VARCHAR(50);
	DECLARE CARLOAN_TIMESTAMP TIMESTAMP;
	DECLARE FILTER_CURSOR CURSOR FOR 
	SELECT TPSF.PE_ID,TPSF.PE_CARLOAN_PAID_DATE,TPSF.PE_CARLOAN_FROM_PERIOD,TPSF.PE_CARLOAN_TO_PERIOD, 
	TPSF.PE_CARLOAN_AMOUNT,TPSF.PE_CARLOAN_COMMENTS,TPSF.USERSTAMP,TPSF.TIMESTAMP FROM TEMP_PERSONAL_SCDB_FORMAT TPSF WHERE 
	TPSF.PE_TYPE_OF_EXPENSE='CAR LOAN';
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
	OPEN FILTER_CURSOR;
		read_loop: LOOP
			FETCH FILTER_CURSOR INTO PEID,PAIDDATE,FROMPERIOD,TOPERIOD,CARLOANAMOUNT,COMMENTS,CARLOAN_USERSTAMP,CARLOAN_TIMESTAMP;
		IF DONE THEN
			LEAVE read_loop;
		END IF;
		SET @PAID_DATE = PAIDDATE;
		SET @FROM_PERIOD = FROMPERIOD;
		SET @TO_PERIOD = TOPERIOD;
		SET @CARLOAN_AMT = CARLOANAMOUNT;
		SET @CARLOAN_COMMENTS = COMMENTS;
		SET @CARLOANUSERSTAMP = CARLOAN_USERSTAMP;
		SET @CARLOANTIMESTAMP = CARLOAN_TIMESTAMP;
		SET @CARLOANINSERT = (SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.EXPENSE_CAR_LOAN(ECL_PAID_DATE,ECL_FROM_PERIOD,ECL_TO_PERIOD,ECL_AMOUNT,ECL_COMMENTS,ULD_ID,ECL_TIMESTAMP)
		VALUES (@PAID_DATE,@FROM_PERIOD,@TO_PERIOD,@CARLOAN_AMT,@CARLOAN_COMMENTS,
		(SELECT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=@CARLOANUSERSTAMP),@CARLOANTIMESTAMP)'));
		PREPARE CARLOANINSERTSTMT FROM @CARLOANINSERT;
		EXECUTE CARLOANINSERTSTMT;
		END LOOP;
	CLOSE FILTER_CURSOR;
COMMIT;
END;