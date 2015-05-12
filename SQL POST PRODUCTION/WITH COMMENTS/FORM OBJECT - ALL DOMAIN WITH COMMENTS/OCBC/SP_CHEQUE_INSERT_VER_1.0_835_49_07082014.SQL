-- version 1.0 --sadte:07/08/2014 --edate:07/08/2014 --issue:835 --commentno:3 --desc:implementing auto commit --done by : RL
--version 0.9 --sdate:09/07/2014 --edate:09/07/2014 --issue:303 --comment:416 --doneby:BHAVANI.R -- DESC: REPLACED HARDCOADED CONFIGURATION DATA INTO ID.
--version 0.8 --sdate:28/02/2014 --edate:28/02/2014 --issue:754 --comment:36 --doneby:RL
--version 0.7 --sdate:27/02/2014 --edate:27/02/2014 --issue:754 --comment:22 --doneby:BHAVANI
-->version 0.6 -->start date:25/02/2014 -->end date:25/02/2014 -->issue no:755   commentno:#3  -->desc :Changing userstamp into uldid in SP_CHEQUE_INSERT done by:Bhavani.R 
-->version 0.5 -->start date:18/02/2014 -->end date:18/02/2014 --issueno:749 commentno:#49 -->description:implement flag for success message  -->created by:ABDUL KADER.M
--version 0.4-->startdate:27/01/2014 enddate:27/01/2014 -->issue no:536 comment no:#39 desc:changed cheque_entry_details cs_id as BCN_ID as per table updation done by:DHIVYA.A
--version 0.3-->startdate:09/11/2013 enddate:09/11/2013 -->issue no:636 comment no:#47 desc:changed sp name and file name done by:DHIVYA.A
--> version 0.2 -->startdate:11/10/2013  enddate:11/10/2013-->issueno:636 -->desc:added comments-->doneby:DHIVYA.A
---version 0.1 issue no:626 start date:21/09/2013 and end date:21/09/2013 desc:sp for cheque entry done by:DHIVYA.A

DROP PROCEDURE IF EXISTS SP_CHEQUE_INSERT;
CREATE PROCEDURE SP_CHEQUE_INSERT(
IN CHEQUEDATE DATE,
IN CHEQUETO VARCHAR(100),
IN CHEQUENO INTEGER(6),
IN CHEQUEFOR VARCHAR(100),
IN CHEQUEAMOUNT DECIMAL(7,2),
IN CHEQUEUNITNO VARCHAR(25),
IN CHEQUECOMMENTS TEXT,
IN USERSTAMP VARCHAR(50),
OUT CHEQUEFLAG INTEGER(10))
BEGIN
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK;
		SET CHEQUEFLAG=0;
	END;
	SET CHEQUEFLAG=0;
	SET AUTOCOMMIT = 0;
	START TRANSACTION;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
	IF(CHEQUEDATE IS NOT NULL AND CHEQUETO IS NOT NULL AND CHEQUENO IS NOT NULL AND CHEQUEFOR IS NOT NULL AND CHEQUEAMOUNT IS NOT NULL AND USERSTAMP IS NOT NULL)THEN
		INSERT INTO CHEQUE_ENTRY_DETAILS(CHEQUE_DATE,CHEQUE_TO,CHEQUE_NO,CHEQUE_FOR,CHEQUE_AMOUNT,CHEQUE_UNIT_NO,
		BCN_ID,CHEQUE_COMMENTS,ULD_ID)VALUES(CHEQUEDATE,CHEQUETO,CHEQUENO,CHEQUEFOR,CHEQUEAMOUNT,CHEQUEUNITNO,
		12,CHEQUECOMMENTS,USERSTAMP_ID);
		SET CHEQUEFLAG=1;
	END IF;
COMMIT;
END;