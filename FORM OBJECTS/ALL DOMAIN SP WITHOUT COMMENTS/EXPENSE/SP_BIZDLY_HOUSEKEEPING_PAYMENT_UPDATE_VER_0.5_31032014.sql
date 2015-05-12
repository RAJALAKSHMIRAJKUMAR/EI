DROP PROCEDURE IF EXISTS SP_BIZDLY_HOUSEKEEPING_PAYMENT_UPDATE;
CREATE PROCEDURE SP_BIZDLY_HOUSEKEEPING_PAYMENT_UPDATE
(IN ID INTEGER(10),
IN UNIT_NUMBER SMALLINT(4), 
IN FOR_PERIOD DATE,
IN PAID_DATE DATE,
IN AMOUNT DECIMAL(7,2),
IN COMMENTS TEXT,
IN USERSTAMP VARCHAR(50),
OUT BHP_FLAG INTEGER(10))
BEGIN
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK; 
END;
START TRANSACTION;
SET BHP_FLAG=0;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);
IF COMMENTS = '' THEN
SET COMMENTS=NULL;
END IF;
IF (FOR_PERIOD IS NOT NULL AND PAID_DATE IS NOT NULL AND AMOUNT IS NOT NULL AND USERSTAMP IS NOT NULL) THEN
update EXPENSE_HOUSEKEEPING_PAYMENT set  UNIT_ID =(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER),
EHKU_ID=(SELECT EHKU_ID FROM EXPENSE_HOUSEKEEPING_UNIT WHERE EHKU_UNIT_NO=UNIT_NUMBER),
EHKP_FOR_PERIOD= FOR_PERIOD,EHKP_PAID_DATE=PAID_DATE,EHKP_AMOUNT=AMOUNT,EHKP_COMMENTS=COMMENTS,ULD_ID=USERSTAMP_ID WHERE EHKP_ID=ID;
SET BHP_FLAG=1;
END IF;
COMMIT;
END;