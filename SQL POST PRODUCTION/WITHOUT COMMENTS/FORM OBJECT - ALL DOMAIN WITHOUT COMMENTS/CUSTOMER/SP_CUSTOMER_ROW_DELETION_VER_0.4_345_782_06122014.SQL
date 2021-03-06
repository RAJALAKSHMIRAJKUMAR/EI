DROP PROCEDURE IF EXISTS SP_CUSTOMER_ROW_DELETION;
CREATE PROCEDURE SP_CUSTOMER_ROW_DELETION(IN TABLE_ID INT, IN ROW_ID INT,IN V_USERSTAMP INT(2))
BEGIN
DECLARE EMPID INT;
DECLARE UASDID INT;
DECLARE CUSTOMERID INT;
DECLARE COMPNAME varchar(50) DEFAULT NULL;
DECLARE COMPADDR varchar(50) DEFAULT NULL;
DECLARE COMPPOSTCODE varchar(6) DEFAULT NULL;
DECLARE COMPOFFICENO varchar(8) DEFAULT NULL;
DECLARE ACNID TEXT;
DECLARE VALIDFROM DATE;
DECLARE VALIDTILL TEXT;
DECLARE GUESTCARD TEXT;
DECLARE ULDID INTEGER;
DECLARE TSTAMP TIMESTAMP;
DECLARE RECVER INTEGER;
DECLARE STARTDATE DATE;
DECLARE ENDDATE DATE;
DECLARE LPTERMINATE TEXT;
DECLARE PRETERMDATE TEXT;
DECLARE MAXTIMES INTEGER;
DECLARE CUSTOMER_DETAILS TEXT;
IF TABLE_ID =40 THEN 
	SET EMPID=(SELECT EMP_ID FROM EMPLOYEE_CARD_DETAILS WHERE ECD_ID=ROW_ID);
	SET UASDID=(SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE ECD_ID=ROW_ID);
	SET CUSTOMER_DETAILS=(CONCAT('ECD_ID=',ROW_ID,',EMP_ID=',EMPID,',UASD_ID=',UASDID));
	INSERT INTO TICKLER_HISTORY (TP_ID, TTIP_ID, TH_OLD_VALUE, ULD_ID)VALUES (2, TABLE_ID, CUSTOMER_DETAILS, V_USERSTAMP);
	DELETE FROM EMPLOYEE_CARD_DETAILS WHERE ECD_ID=ROW_ID;
ELSEIF TABLE_ID =9 THEN 
	SET CUSTOMERID=(SELECT CUSTOMER_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CCD_ID=ROW_ID);
	SET COMPNAME=(SELECT CCD_COMPANY_NAME FROM CUSTOMER_COMPANY_DETAILS WHERE CCD_ID=ROW_ID);
	SET COMPADDR=(SELECT CCD_COMPANY_ADDR FROM CUSTOMER_COMPANY_DETAILS WHERE CCD_ID=ROW_ID);
	SET COMPPOSTCODE=(SELECT CCD_POSTAL_CODE FROM CUSTOMER_COMPANY_DETAILS WHERE CCD_ID=ROW_ID);
	SET COMPOFFICENO=(SELECT CCD_OFFICE_NO FROM CUSTOMER_COMPANY_DETAILS WHERE CCD_ID=ROW_ID);
	IF COMPNAME IS NULL THEN
		SET COMPNAME='null';
	END IF;
	IF COMPADDR IS NULL THEN
		SET COMPADDR='null';
	END IF;
	IF COMPPOSTCODE IS NULL THEN
		SET COMPPOSTCODE='null';
	END IF;
	IF COMPOFFICENO IS NULL THEN
		SET COMPOFFICENO='null';
	END IF;
	SET CUSTOMER_DETAILS=(CONCAT('CCD_ID=',ROW_ID,',CUSTOMER_ID=',CUSTOMERID,',CCD_COMPANY_NAME=',COMPNAME,',CCD_COMPANY_ADDR=',COMPADDR,',CCD_POSTAL_CODE=',COMPPOSTCODE
	,',CCD_OFFICE_NO=',COMPOFFICENO));
	INSERT INTO TICKLER_HISTORY (TP_ID, TTIP_ID,CUSTOMER_ID,TH_OLD_VALUE, ULD_ID)VALUES (2, TABLE_ID,CUSTOMERID,CUSTOMER_DETAILS, V_USERSTAMP);	
	DELETE FROM CUSTOMER_COMPANY_DETAILS WHERE CCD_ID=ROW_ID;	
ELSEIF TABLE_ID=13 THEN
SET CUSTOMERID=(SELECT CUSTOMER_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CACD_ID=ROW_ID);
SET UASDID=(SELECT UASD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CACD_ID=ROW_ID);
SET ACNID=(SELECT ACN_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CACD_ID=ROW_ID);
SET VALIDFROM=(SELECT CACD_VALID_FROM FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CACD_ID=ROW_ID);
SET VALIDTILL=(SELECT CACD_VALID_TILL FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CACD_ID=ROW_ID);
SET GUESTCARD=(SELECT CACD_GUEST_CARD FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CACD_ID=ROW_ID);
SET ULDID=(SELECT ULD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CACD_ID=ROW_ID);
SET TSTAMP=(SELECT CACD_TIMESTAMP FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CACD_ID=ROW_ID);
IF ACNID IS NULL THEN
SET ACNID='null';
END IF;
IF VALIDTILL IS NULL THEN
SET VALIDTILL='null';
END IF;
IF GUESTCARD IS NULL THEN
SET GUESTCARD='null';
END IF;
SET CUSTOMER_DETAILS=(CONCAT('CACD_ID=',ROW_ID,',CUSTOMER_ID=',CUSTOMERID,',UASD_ID=',UASDID,',ACN_ID=',ACNID,',CACD_VALID_FROM=',VALIDFROM
	,',CACD_VALID_TILL=',VALIDTILL,',CACD_GUEST_CARD=',GUESTCARD,',ULD_ID=',ULDID,',CACD_TIMESTAMP=',TSTAMP));
INSERT INTO TICKLER_HISTORY (TP_ID, TTIP_ID,CUSTOMER_ID,TH_OLD_VALUE, ULD_ID)VALUES (2, TABLE_ID,CUSTOMERID,CUSTOMER_DETAILS, V_USERSTAMP);	
DELETE FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CACD_ID=ROW_ID;	
ELSEIF TABLE_ID=14 THEN
SET CUSTOMERID=(SELECT CUSTOMER_ID FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID);
SET RECVER=(SELECT CED_REC_VER FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID);
SET UASDID=(SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID);
SET STARTDATE=(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID);
SET ENDDATE=(SELECT CLP_ENDDATE FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID);
SET LPTERMINATE=(SELECT CLP_TERMINATE FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID);
SET PRETERMDATE=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID);
SET GUESTCARD=(SELECT CLP_GUEST_CARD FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID);
SET MAXTIMES=(SELECT ULD_TS_MAXTIMES FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID);
SET ULDID=(SELECT ULD_ID FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID);
SET TSTAMP= (SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID); 
IF UASDID IS NULL THEN
SET UASDID='null';
END IF;
IF LPTERMINATE IS NULL THEN
SET LPTERMINATE='null';
END IF;
IF PRETERMDATE IS NULL THEN
SET PRETERMDATE='null';
END IF;
IF GUESTCARD IS NULL THEN
SET GUESTCARD='null';
END IF;
SET CUSTOMER_DETAILS=(CONCAT('CLP_ID=',ROW_ID,',CUSTOMER_ID=',CUSTOMERID,',UASD_ID=',UASDID,',CED_REC_VER=',RECVER,',CLP_STARTDATE=',STARTDATE
	,',CLP_ENDDATE=',ENDDATE,',CLP_TERMINATE=',LPTERMINATE,',CLP_PRETERMINATE_DATE=',PRETERMDATE,',CLP_GUEST_CARD=',GUESTCARD,',ULD_TS_MAXTIMES=',MAXTIMES,',ULD_ID=',ULDID,',CLP_TIMESTAMP=',TSTAMP));
INSERT INTO TICKLER_HISTORY (TP_ID, TTIP_ID,CUSTOMER_ID,TH_OLD_VALUE, ULD_ID)VALUES (2, TABLE_ID,CUSTOMERID,CUSTOMER_DETAILS, V_USERSTAMP);	
DELETE FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=ROW_ID;
END IF;
END;
