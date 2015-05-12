DROP PROCEDURE IF EXISTS SP_EXPENSE_BABY_INSERT;
CREATE PROCEDURE SP_EXPENSE_BABY_INSERT(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
	DECLARE DONE INT DEFAULT FALSE;
	DECLARE PEID INTEGER;
	DECLARE BABYEXPENSE TEXT;
	DECLARE INVOICEDATE DATE;
	DECLARE BABYAMOUNT DECIMAL(7,2);
	DECLARE INVOICEITEM TEXT;
	DECLARE INVOICEFROM VARCHAR(200);
	DECLARE COMMENTS TEXT;
	DECLARE BABYUSERSTAMP VARCHAR(50);
	DECLARE BABYTIMESTAMP TIMESTAMP;
	DECLARE FILTER_CURSOR CURSOR FOR 
	SELECT TPSF.PE_ID,TPSF.PE_BABY_EXPENSE,TPSF.PE_BABY_INVOICE_DATE,TPSF.PE_BABY_AMOUNT, TPSF.USERSTAMP,TPSF.TIMESTAMP
	FROM TEMP_PERSONAL_SCDB_FORMAT TPSF WHERE TPSF.PE_TYPE_OF_EXPENSE='BABY';
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
	OPEN FILTER_CURSOR;
		read_loop: LOOP
			FETCH FILTER_CURSOR INTO PEID,BABYEXPENSE,INVOICEDATE,BABYAMOUNT,BABYUSERSTAMP,BABYTIMESTAMP;
			IF DONE THEN
				LEAVE read_loop;
			END IF;
			SET @PERSONALID = PEID;
			SET @BABYCATEGOTY = BABYEXPENSE;
			SET @INVOICE_DATE = INVOICEDATE;
			SET @AMT = BABYAMOUNT;
			SET @BABY_USERSTAMP = BABYUSERSTAMP;
			SET @BABY_TIMESTAMP = BABYTIMESTAMP;
			SET @EXPENSEBABYINSERT = (SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.EXPENSE_BABY(ECN_ID,EB_INVOICE_DATE,EB_AMOUNT,EB_INVOICE_ITEMS,EB_INVOICE_FROM,EB_COMMENTS,ULD_ID,EB_TIMESTAMP)
			VALUES ((SELECT ECN_ID FROM ',DESTINATIONSCHEMA,'.EXPENSE_CONFIGURATION WHERE ECN_DATA=@BABYCATEGOTY AND CGN_ID=25),@INVOICE_DATE,@AMT,
			(SELECT DISTINCT PE_INVOICE_ITEMS FROM TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE WHERE PE_ID=@PERSONALID),
			(SELECT DISTINCT PE_INVOICE_FROM FROM TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE WHERE PE_ID=@PERSONALID),
			(SELECT DISTINCT PE_COMMENTS FROM TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE WHERE PE_ID=@PERSONALID),
			(SELECT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=@BABY_USERSTAMP),@BABY_TIMESTAMP)'));
			PREPARE EXPENSEBABYINSERTSTMT FROM @EXPENSEBABYINSERT;
			EXECUTE EXPENSEBABYINSERTSTMT;
		END LOOP;
	CLOSE FILTER_CURSOR;
COMMIT;
END;
