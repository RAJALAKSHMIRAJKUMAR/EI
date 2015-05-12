-- version --> 0.9 startdate -->10/05/2014 enddate --> 10/05/2014 description --> ADDING REC VER IN PARAMATER FOR INSERTING DATE WITH REC VER --->SARADAMBAL --->issue:493
-- version --> 0.8 startdate -->28/04/2013 enddate --> 30/04/2013 description --> implemented dynamic temp table --->SARADAMBAL --->ISSUE :817
-- version --> 0.7 startdate -->09/11/2013 enddate --> 10/11/2013 description --> ADDED CALCULATIONS FOR FAULTY CARD AND CHANGED SP NAME created by -->CL -->issue :493
-- version --> 0.6 startdate -->21/10/2013 enddate --> 08/11/2013 description --> Changed name for the SP created by -->CL -->issue :493
-->version 0.5 -->startdate:02/08/2013 -->enddate:02/08/2013 -->description:ACN_SNO changed as ACN_ID 
-->version 0.4 -->startdate:10/07/2013 -->enddate:10/07/2013 -->description:changing date conditions
-->version 0.3 -->startdate:10/07/2013 -->enddate:10/07/2013 -->description:changing date conditions
-->version 0.2 -->startdate:09/07/2013 -->enddate:09/07/2013 -->description: using customer id -->issue tracker no: 554
-->version 0.1 -->stratdate:09/07/2013 -->enddate:09/07/2013 -->description:calculate LOST/DAMAGED CARD amounts  for deposit deduction-->issue tracker no:493 -->created by:rajalakshmi.r

DROP PROCEDURE IF EXISTS SP_DD_FLD_CARD_CALCULATION;
CREATE PROCEDURE SP_DD_FLD_CARD_CALCULATION(
IN ID INTEGER,
IN STARTDATE DATE,
IN ENDDATE DATE,
IN REC_VER INTEGER,
IN TEMP_DD_CALCULATION TEXT,
OUT ACC_COUNT INT,
OUT AMOUNT INT)
BEGIN
-- query for rollback command
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
	ROLLBACK; 
END;
START TRANSACTION;
SET ACC_COUNT = (SELECT COUNT(ACN_ID) FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE  ACN_ID BETWEEN 1 AND 3 AND CACD_VALID_TILL BETWEEN STARTDATE AND ENDDATE AND CUSTOMER_ID=ID);
SET AMOUNT = ACC_COUNT * 50;
IF ACC_COUNT!=0 THEN
	--    INSERT QUERY FOR DYNAMIC TEMP TABLE
			SET @DD_CALC_INSERT_CARDTILLDATE=(SELECT CONCAT('INSERT INTO ',TEMP_DD_CALCULATION ,'(DDCARDTILLDATE,DDRECVER) SELECT CUSTOMER_ACCESS_CARD_DETAILS.CACD_VALID_TILL,',REC_VER,' FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE  ACN_ID BETWEEN 1 AND 3 AND CACD_VALID_TILL BETWEEN ' ,'"',STARTDATE,'"',' AND ' ,'"',ENDDATE,'"',' AND CUSTOMER_ID=',ID));
			PREPARE DD_CALC_INSERT_CARDTILLDATE_STMT FROM @DD_CALC_INSERT_CARDTILLDATE;
			EXECUTE DD_CALC_INSERT_CARDTILLDATE_STMT;

END IF;
COMMIT;
END;