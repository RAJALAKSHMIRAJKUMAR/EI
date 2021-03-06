DROP PROCEDURE IF EXISTS SP_CUSTOMER_LP_TICKLER_NEWVALUE;
CREATE PROCEDURE SP_CUSTOMER_LP_TICKLER_NEWVALUE (
IN CUSTOMERID INTEGER,
IN CLPID INTEGER,
IN CPDID INTEGER,
IN USERSTAMP VARCHAR(50),
OUT NEWVALUE_LP TEXT,
OUT NEWVALUE_PERSONAL TEXT,
OUT NEWUASDID INTEGER,
OUT NEWCOMMENTS TEXT)
BEGIN
	SET NEWVALUE_LP='';
	SET NEWVALUE_PERSONAL='';
	SET NEWUASDID = (SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID = CUSTOMERID AND CLP_ID = CLPID);
	SET NEWVALUE_LP = (SELECT CONCAT (NEWVALUE_LP,'UASD_ID = ',NEWUASDID));
	SET NEWCOMMENTS = (SELECT CPD_COMMENTS FROM CUSTOMER_PERSONAL_DETAILS WHERE CPD_ID = CPDID AND CUSTOMER_ID = CUSTOMERID);
	SET NEWVALUE_PERSONAL = (SELECT CONCAT(NEWVALUE_PERSONAL,'CPD_COMMENTS = ',NEWCOMMENTS));
END;
