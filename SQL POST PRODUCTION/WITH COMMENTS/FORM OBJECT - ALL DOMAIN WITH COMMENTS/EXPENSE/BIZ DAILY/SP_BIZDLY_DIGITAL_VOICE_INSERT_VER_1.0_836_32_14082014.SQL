-- version:1.0--sdate:14/08/2014 --edate:14/08/2014 -->issueno:836--commentno:#32 --> DESC:changing amt data type(7,2) as DECIMAL(5,2) DONE BY: RL
-- version:0.9 --sdate:01/08/2014 --edate:01/08/2014 --issue:835  --desc:IMPLEMENTED AUTOCOMMIT --doneby:DHIVYA
-->version 0.8 -->start date:09/06/2014 end date:09/06/2014 -->issueno:566 commentno:#12 -->description:ADDED ROLLBACK AND COMMIT->DONE BY SASIKALA
-->version 0.7 -->start date:21/03/2014 end date:21/03/2014 -->issueno:535 commentno:#285 -->description:IMPLEMENT ONE FLAG FOR INSERTION,WHILE UPDATING INCLDED USERSTAMP-->DONE BY M.SARADAMBAL
-->version 0.6 -->start date:19/03/2014 end date:19/03/2014 -->issueno:535 commentno:#276 -->description:CHANGING UPDATION PART AND CHANGING ECN DATA AS ECNID -->DONE by:BHAVANI.R
-->version 0.5 -->start date:28/02/2014 end date:28/02/2014 -->issueno:754 commentno:#36 -->description:CHANGING OF USERSTAMP VALUE AS USERSTAMP_ID AND ALSO CHANGING THE DATATYPE -->DONE by:BHAVANI.R
-->version 0.4 -->start date:27/02/2014 end date:27/02/2014 -->issueno:754 commentno:#22 -->description:CHANGING OF USERSTAMP IN TO ULD_ID AS COLUMN HEADER -->DONE by:BHAVANI.R
-->version 0.3 -->start date:22/02/2014 end date:24/02/2014 -->issueno:749 commentno:#70 -->description:CHECKING THE ECNID IS NOT NULL  comments -->created by:ABDUL KADER.M
-->version 0.2 -->start date:17/02/2014 end date:17/02/2014 -->issueno:749 commentno:#14 -->description:implement flag in SP_BIZDLY_DIGITAL_VOICE_INSERT comments -->created by:ABDUL KADER.M
--version 0.1 --startdate:12/11/2013 --endate:13/11/2013 --desc:SP FOR EXPENSE_DIGITAL_VOICE --done by:dinesh

DROP PROCEDURE IF EXISTS SP_BIZDLY_DIGITAL_VOICE_INSERT;
CREATE PROCEDURE SP_BIZDLY_DIGITAL_VOICE_INSERT(
IN UNIT_NUMBER SMALLINT(4),
IN DV_ECN_ID INTEGER,
IN DV_INVOICE_DATE DATE,
IN DV_FROM_PERIOD DATE,
IN DV_TO_PERIOD DATE,
IN DV_AMOUNT DECIMAL(5,2),
IN DV_COMMENTS TEXT,
IN USERSTAMP VARCHAR(50),
OUT DIGITALVOICE_SUCCESSFLAG INTEGER )
BEGIN
	DECLARE EDDVID INTEGER;
	DECLARE ECNID INTEGER;
	DECLARE USERSTAMP_ID INTEGER(2);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
	ROLLBACK; 
	SET DIGITALVOICE_SUCCESSFLAG=0;
	END;
	IF(DV_COMMENTS='' OR DV_COMMENTS IS NULL)THEN
		SET DV_COMMENTS = NULL;
	END IF;
	SET AUTOCOMMIT=0;
	START TRANSACTION;
	SET DIGITALVOICE_SUCCESSFLAG=0;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
    SET USERSTAMP_ID = (SELECT @ULDID);
	SET EDDVID = (SELECT MAX(EDDV_ID) FROM EXPENSE_DETAIL_DIGITAL_VOICE WHERE UNIT_ID = (SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER));
	SET ECNID = (SELECT ECN_ID FROM EXPENSE_DETAIL_DIGITAL_VOICE WHERE EDDV_ID = EDDVID);
	IF  ECNID IS NULL THEN
		SET FOREIGN_KEY_CHECKS=0;
		UPDATE EXPENSE_DETAIL_DIGITAL_VOICE SET ECN_ID=DV_ECN_ID,ULD_ID=USERSTAMP_ID  WHERE EDDV_ID =EDDVID;
	END IF;
		SET FOREIGN_KEY_CHECKS=0;
	IF UNIT_NUMBER IS NOT NULL AND DV_ECN_ID IS NOT NULL AND DV_INVOICE_DATE IS NOT NULL AND DV_FROM_PERIOD IS NOT NULL AND DV_TO_PERIOD IS NOT NULL AND DV_AMOUNT IS NOT NULL AND USERSTAMP IS NOT NULL THEN
		INSERT INTO EXPENSE_DIGITAL_VOICE (EDDV_ID,EDV_INVOICE_DATE,EDV_FROM_PERIOD,EDV_TO_PERIOD,EDV_AMOUNT,EDV_COMMENTS,ULD_ID)VALUES (EDDVID,DV_INVOICE_DATE,DV_FROM_PERIOD,DV_TO_PERIOD,DV_AMOUNT,DV_COMMENTS,USERSTAMP_ID);
		SET DIGITALVOICE_SUCCESSFLAG=1;
	END IF;
COMMIT;
END;
