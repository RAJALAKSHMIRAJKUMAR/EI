--VER 0.4 ISSUE NO:754 COMMENT NO:36 START DATE:28/02/1014 END DATE:28/02/2014 DESC:CHANGING DATA TYPE AND VALUE OF USERSTAMP DONE BY:BHAVANI.R
--VER 0.3 ISSUE NO:535 COMMENT NO:176 START DATE:19/02/1014 END DATE:19/02/2014 DESC:implementing flag DONE BY:RL
---VER 0.2 ISSUE NO:535 COMMENT NO:44 START DATE:12/11/2013 END DATE:12/11/2013 DESC:updation done in expense_purchase_new_card table if same card exists means other details updated. DONE BY:DHIVYA.A
---VER 0.1 ISSUE NO:535 COMMENT NO:23 START DATE:09/10/2013 END DATE:10/10/2013 DESC:SP FOR PURCHASE CARD UPDATION DONE BY:DHIVYA.A
DROP PROCEDURE IF EXISTS SP_BIZDLY_PURCHASE_NEW_CARD_UPDATE;
CREATE PROCEDURE SP_BIZDLY_PURCHASE_NEW_CARD_UPDATE(
IN EPNCID INT,
IN CARDNO VARCHAR(7),
IN INVOICEDATE DATE,
IN AMOUNT DECIMAL(7,2),
IN COMMENTS TEXT,
IN USERSTAMP VARCHAR(50),
OUT EPNC_FLAG INTEGER)
BEGIN
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE OLDCARD VARCHAR(7);
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
	ROLLBACK;
END;
	START TRANSACTION;
	
	SET EPNC_FLAG = 0;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
    SET USERSTAMP_ID = (SELECT @ULDID);
	
	SET OLDCARD=(SELECT EPNC_NUMBER FROM EXPENSE_PURCHASE_NEW_CARD WHERE EPNC_ID=EPNCID);

	IF(EPNCID IS NOT NULL AND CARDNO IS NOT NULL AND INVOICEDATE IS NOT NULL AND AMOUNT IS NOT NULL AND USERSTAMP IS NOT NULL)THEN
--condition for checking the passing card_no not exists in UNIT_ACCESS_STAMP_DETAILS
		IF(CARDNO!=OLDCARD)THEN
			IF NOT EXISTS(SELECT EPNC_NUMBER FROM EXPENSE_PURCHASE_NEW_CARD WHERE EPNC_NUMBER=CARDNO)THEN
				IF NOT EXISTS(SELECT UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNO)THEN
--update UASD_ACCESS_CARD in UNIT_ACCESS_STAMP_DETAILS for the passing EPNCID in EXPENSE_PURCHASE_NEW_CARD table
					UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_CARD=CARDNO,ULD_ID=USERSTAMP_ID WHERE 
					UASD_ACCESS_CARD=OLDCARD;
					SET EPNC_FLAG = 1;
					UPDATE EXPENSE_PURCHASE_NEW_CARD SET EPNC_NUMBER=CARDNO,EPNC_INVOICE_DATE=INVOICEDATE,EPNC_AMOUNT=AMOUNT,
					EPNC_COMMENTS=COMMENTS,ULD_ID=USERSTAMP_ID WHERE EPNC_ID=EPNCID;
					SET EPNC_FLAG = 1;
				END IF;
			END IF;
		ELSE
--UPDATE EPNC_NUMBER,EPNC_INVOICE_DATE,EPNC_AMOUNT,EPNC_COMMENTS,EPNC_USERSTAMP IN EXPENSE_PURCHASE_NEW_CARD TABLE FOR THE PASSING EPNCID.
			UPDATE EXPENSE_PURCHASE_NEW_CARD SET EPNC_INVOICE_DATE=INVOICEDATE,EPNC_AMOUNT=AMOUNT,
			EPNC_COMMENTS=COMMENTS,ULD_ID=USERSTAMP_ID WHERE EPNC_ID=EPNCID;
			SET EPNC_FLAG = 1;
		END IF;
	END IF;
COMMIT;
END;