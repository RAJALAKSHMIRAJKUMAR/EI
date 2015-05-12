-- version:0.4 --sadte:09/06/2014 --edate:09/06/2014 --issue:566 COMMNT:12--desc:IMPLEMENTED ROLL BACK AND COMMIT --done by:DHIVYA
-- version:0.3 --sadte:11/04/2014 --edate:11/04/2014 --issue:803 --desc:added call query --done by:RL

-- version:0.2 --sadte:29/03/2014 --edate:29/03/2014 --issue:747 --commentno#42 --desc:get source to destination dynamically --done by:RL
--version:0.1 --sdate:07/02/2014 --edate:07/02/2014 --issue:740 --desc:update uppercase email id changed as lower case email id --doneby:RL

DROP PROCEDURE IF EXISTS SP_UPDATE_EMAIL_UPPERCASE_TO_LOWERCASE;
CREATE PROCEDURE SP_UPDATE_EMAIL_UPPERCASE_TO_LOWERCASE(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;

--CUSTOMER_PERSONAL_DETAILS
	SET @UPDATECPD = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.CUSTOMER_PERSONAL_DETAILS SET CPD_EMAIL = LCASE (CPD_EMAIL)'));
	PREPARE UPDATECPDSTMT FROM @UPDATECPD;
	EXECUTE UPDATECPDSTMT;

--EMAIL_LIST
	SET @UPDATEEMAILLIST = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EMAIL_LIST SET EL_EMAIL_ID = LCASE (EL_EMAIL_ID)'));
	PREPARE UPDATEEMAILLISTSTMT FROM @UPDATEEMAILLIST;
	EXECUTE UPDATEEMAILLISTSTMT;
	
--EMPLOYEE_DETAILS
	SET @UPDATEEMPDTL = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EMPLOYEE_DETAILS SET EMP_EMAIL = LCASE (EMP_EMAIL)'));
	PREPARE UPDATEEMPDTLSTMT FROM @UPDATEEMPDTL;
	EXECUTE UPDATEEMPDTLSTMT;
	
--USER_LOGIN_DETAILS
	SET @UPDATEULD = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS SET ULD_LOGINID = LCASE (ULD_LOGINID)'));
	PREPARE UPDATEULDSTMT FROM @UPDATEULD;
	EXECUTE UPDATEULDSTMT;
	
--ERM_ENTRY_DETAILS
	SET @UPDATEERM = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.ERM_ENTRY_DETAILS SET ERM_EMAIL_ID = LCASE (ERM_EMAIL_ID)'));
	PREPARE UPDATEERMSTMT FROM @UPDATEERM;
	EXECUTE UPDATEERMSTMT;
	COMMIT;
END;

CALL SP_UPDATE_EMAIL_UPPERCASE_TO_LOWERCASE(DESTINATIONSCHEMA);