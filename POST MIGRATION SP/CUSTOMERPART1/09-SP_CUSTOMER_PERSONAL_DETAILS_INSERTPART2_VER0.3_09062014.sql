DROP PROCEDURE IF EXISTS SP_CUSTOMER_PERSONAL_DETAILS_INSERT_PART2;
CREATE PROCEDURE SP_CUSTOMER_PERSONAL_DETAILS_INSERT_PART2(IN SOURCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50),IN MIGUSERSTAMP VARCHAR(50))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @USERSTAMPID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',MIGUSERSTAMP,'"'));
PREPARE LOGINID FROM @LOGIN_ID;
EXECUTE LOGINID;
SET @UPDATECPDCOMMENTS=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.CUSTOMER_PERSONAL_DETAILS SET CPD_COMMENTS=NULL WHERE CPD_COMMENTS=','" \n"'));
PREPARE UPDATECPDCOMMENTSSTMT FROM @UPDATECPDCOMMENTS;
EXECUTE UPDATECPDCOMMENTSSTMT;
SET @UPDATECPDCOMMENTS1=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.CUSTOMER_PERSONAL_DETAILS SET CPD_COMMENTS=NULL WHERE CPD_COMMENTS=','" \n\n"'));
PREPARE UPDATECPDCOMMENTS1STMT FROM @UPDATECPDCOMMENTS1;
EXECUTE UPDATECPDCOMMENTS1STMT;
SET @UPDATECPDCOMMENTS2=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.CUSTOMER_PERSONAL_DETAILS SET CPD_COMMENTS=NULL WHERE CPD_COMMENTS=','" \n\n\n"'));
PREPARE UPDATECPDCOMMENT2SSTMT FROM @UPDATECPDCOMMENTS2;
EXECUTE UPDATECPDCOMMENT2SSTMT;
SET @VW_CUS_PERSONAL=(SELECT CONCAT('CREATE OR REPLACE VIEW ',DESTINATIONSCHEMA,'.VW_CUSTOMER_PERSONAL_DETAILS AS SELECT DISTINCT CC_CUST_ID FROM  ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT WHERE  CC_EMAIL IS NOT NULL AND CC_NATIONALITY IS NOT NULL'));
	PREPARE VWCUSPERSONAL FROM @VW_CUS_PERSONAL;
	EXECUTE VWCUSPERSONAL;
	SET @COUNTSCDBCPD=(SELECT CONCAT('SELECT COUNT(*)INTO @COUNT_SCDB_CPD FROM ',DESTINATIONSCHEMA,'.VW_CUSTOMER_PERSONAL_DETAILS'));
	PREPARE SCDBCPD FROM @COUNTSCDBCPD;
	EXECUTE SCDBCPD;
	SET @COUNTSPLITTINGCPD=(SELECT CONCAT('SELECT COUNT(*)INTO @COUNT_SPLITTING_CPD FROM ',DESTINATIONSCHEMA,'.CUSTOMER_PERSONAL_DETAILS'));
	PREPARE SPLITTINGCPD FROM @COUNTSPLITTINGCPD;
	EXECUTE SPLITTINGCPD;
	SET @REJECTION_COUNT=(@COUNT_SCDB_CPD- @COUNT_SPLITTING_CPD);
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_SCDB_CPD WHERE PREASP_DATA='CUSTOMER_PERSONAL_DETAILS';
	SET FOREIGN_KEY_CHECKS=0;
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)
	VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='CUSTOMER_PERSONAL_DETAILS'),@COUNT_SPLITTING_CPD,(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='CUSTOMER_PERSONAL_DETAILS'),
	(SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='CUSTOMER'),(SELECT SPLITTED_DURATION FROM TEMP_PERSONAL_PART2),@REJECTION_COUNT,@USERSTAMPID);
DROP TABLE IF EXISTS TEMP_CUSTOMER_ACCESS_COMMENT;
DROP TABLE IF EXISTS TEMP_CUSTOMER_PERSONAL;
DROP TABLE IF EXISTS TEMP_CUSTOMER_COMMENTS_UPDATE;
DROP TABLE IF EXISTS TEMP_RECVER;
DROP TABLE IF EXISTS TEMP_ACCESS_COMMENTS;
SET @DRTEMPTERMINATION=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_GUEST_CUSTOMER_TERMINATION_DETAILS'));
PREPARE DRTEMPTERMINATIONSTMT FROM @DRTEMPTERMINATION;
EXECUTE DRTEMPTERMINATIONSTMT;
SET @DRVIEWCUSPERSONAL=(SELECT CONCAT('DROP VIEW IF EXISTS ',DESTINATIONSCHEMA,'.VW_CUSTOMER_PERSONAL_DETAILS'));
PREPARE DRVIEWCUSPERSONALSTMT FROM @DRVIEWCUSPERSONAL;
EXECUTE DRVIEWCUSPERSONALSTMT;
DROP TABLE IF EXISTS TEMP_PERSONAL_PART1;
DROP TABLE IF EXISTS TEMP_PERSONAL_PART2;
DROP TABLE IF EXISTS TEMP_CUSTOMER_PERSONAL_DETAILS;
COMMIT;
END;
