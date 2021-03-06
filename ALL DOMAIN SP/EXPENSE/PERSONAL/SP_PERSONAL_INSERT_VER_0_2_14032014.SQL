--version:0.2 --sdate:14/03/2014 --edate:14/03/2014 --issue:535 --comment no#253 --desc:removed comments in cheking mandatory fields --doneby:RL
--version:0.1 --sdate:12/03/2014 --edate:12/03/2014 --issue:535 --comment no#237 --desc:create sp for save values in expense personal table --doneby:RL 
DROP PROCEDURE IF EXISTS SP_PERSONAL_INSERT;
CREATE PROCEDURE SP_PERSONAL_INSERT(
IN ECNID TEXT,
IN INVOICEDATE TEXT,
IN AMOUNT TEXT,
IN INVOICEITEMS TEXT,
IN INVOICEFROM TEXT,
IN COMMENTS TEXT,
IN USERSTAMP VARCHAR(50),
OUT FINALMESSAGE TEXT)
BEGIN
-- VARIABLE DECLARATION
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE EPECNID TEXT;
	DECLARE EPINVOICEDATE DATE;
	DECLARE EPAMOUNT  DECIMAL(7,2);
	DECLARE EPINVOICEITEMS TEXT;
	DECLARE EPINVOICEFROM VARCHAR(200);
	DECLARE EPCOMMENTS TEXT;
	DECLARE SUBSPSUCCESSFLAG INTEGER;
-- QUERY FOR ROLLBACK COMMAND
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
	END;
-- QUERY FOR SET PASSING VALUES IN TEMP VARIABLE
	SET @TEMP_ECNID = ECNID;
	SET @TEMP_INVOICEDATE = INVOICEDATE;
	SET @TEMP_AMOUNT = AMOUNT;
	SET @TEMP_INVOICEITEMS = INVOICEITEMS;
	SET @TEMP_INVOICEFROM = INVOICEFROM;
	SET @TEMP_COMMENTS = COMMENTS;
-- QUERY FOR CHECK PASSING ALL MANDATORY FIELDS IS NOT NULL
	SET FINALMESSAGE = '';
		MAIN_LOOP : LOOP
-- QUERY FOR SET PASSING ECNID VALUES IN TEMP VARIABLE		
		CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_ECNID,@VALUE,@REMAINING_STRING);
		SELECT @VALUE INTO EPECNID;
		SELECT @REMAINING_STRING INTO @TEMP_ECNID;
-- QUERY FOR SET PASSING INVOICEDATE VALUES IN TEMP VARIABLE			
		CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_INVOICEDATE,@VALUE,@REMAINING_STRING);
		SELECT @VALUE INTO EPINVOICEDATE;
		SELECT @REMAINING_STRING INTO @TEMP_INVOICEDATE;
-- QUERY FOR SET PASSING AMOUNT VALUES IN TEMP VARIABLE			
		CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_AMOUNT,@VALUE,@REMAINING_STRING);
		SELECT @VALUE INTO EPAMOUNT;
		SELECT @REMAINING_STRING INTO @TEMP_AMOUNT;
-- QUERY FOR SET PASSING INVOICE ITEMS VALUES IN TEMP VARIABLE			
		CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_INVOICEITEMS,@VALUE,@REMAINING_STRING);
		SELECT @VALUE INTO EPINVOICEITEMS;
		SELECT @REMAINING_STRING INTO @TEMP_INVOICEITEMS;
-- QUERY FOR SET PASSING INVOICE FROM VALUES IN TEMP VARIABLE			
		CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_INVOICEFROM,@VALUE,@REMAINING_STRING);
		SELECT @VALUE INTO EPINVOICEFROM;
		SELECT @REMAINING_STRING INTO @TEMP_INVOICEFROM;
-- QUERY FOR SET PASSING COMMENTS VALUES IN TEMP VARIABLE			
		CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('^^',@TEMP_COMMENTS,@VALUE,@REMAINING_STRING);
		SELECT @VALUE INTO EPCOMMENTS;
		SELECT @REMAINING_STRING INTO @TEMP_COMMENTS;	
-- QUERY FOR START TRASACTION	
		START TRANSACTION;	
		IF(EPECNID IS NOT NULL AND EPINVOICEDATE IS NOT NULL AND EPAMOUNT IS NOT NULL AND EPINVOICEITEMS IS NOT NULL AND EPINVOICEFROM IS NOT NULL AND USERSTAMP IS NOT NULL)THEN 
-- QUERY FOR CALL SP_SUBPERSONAL_INSERT TO SAVE VALUES IN EXPENSE_STAFF TABLE		
			CALL SP_SUBPERSONAL_INSERT(EPECNID,EPINVOICEDATE,EPAMOUNT,EPINVOICEITEMS,EPINVOICEFROM,EPCOMMENTS,USERSTAMP,@SUCCESSFLAG);
			SET SUBSPSUCCESSFLAG = (SELECT @SUCCESSFLAG);
		END IF;
-- SUBSPSUCCESSFLAG = 0 THEN THROW ERROR MSG
		IF(SUBSPSUCCESSFLAG=0)THEN
			SET FINALMESSAGE = (SELECT CONCAT(FINALMESSAGE,' ','ECN_DATA=',EPECNID,',','INVOICE_DATE=',EPINVOICEDATE,',',
			'AMOUNT=',EPAMOUNT,',','INVOICE_ITEMS=',EPINVOICEITEMS,',','INVOICE_FROM=',EPINVOICEFROM,',',
			'COMMENTS=',EPCOMMENTS,',','USERSTAMP=',USERSTAMP));
		END IF;
		IF @TEMP_ECNID IS NULL THEN
			LEAVE  MAIN_LOOP;
		END IF;
	END LOOP;
	IF(FINALMESSAGE = '')THEN
		SET FINALMESSAGE = 1;
	END IF;
COMMIT;
END;