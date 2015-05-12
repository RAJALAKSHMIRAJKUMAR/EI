DROP PROCEDURE IF EXISTS SP_CUSTOMER_LP_DETAILS_ULD_TS_MAXTIMES;
CREATE PROCEDURE SP_CUSTOMER_LP_DETAILS_ULD_TS_MAXTIMES
(CUSTOMERID INTEGER,RECVER INTEGER,USERULDID INTEGER)
BEGIN
DECLARE ULDTSMAXTIMES INTEGER;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK; 
END;
START TRANSACTION;
SET ULDTSMAXTIMES=(SELECT ULD_TS_MAXTIMES FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID
AND CED_REC_VER=RECVER AND CLP_GUEST_CARD IS NULL);
UPDATE CUSTOMER_LP_DETAILS SET ULD_TS_MAXTIMES=(ULDTSMAXTIMES+1),ULD_ID=USERULDID WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=RECVER;
COMMIT;
END;