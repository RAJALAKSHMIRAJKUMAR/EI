-- version:0.9 -- sadte:09/06/2014 -- edate:09/06/2014  -- issue:566 COMMENT:12  --desc: IMPLEMENTED ROLLBACK AND COMMIT --doneby:DHIVYA
--  version:0.8 --  sdate:26/03/2014 --  edate:26/03/2014 --  issue:765 -- desc:dynamically get source nd destination schema -- doneby:RL
--  version:0.7 --  sdate:17/03/2014 --  edate:17/03/2014 --  issue:765 -- desc:droped temp table -- doneby:RL
-- version:0.6 -- sdate:04/03/2014 -- edate:04/03/2014 -- Desc:ISSUE CORRECTED INUNIT EXPENSE- DONE BY SAFI
-- version:0.5 -- sdate:28/02/2014 -- edate:28/02/2014 -- issue:750 -- desc:changed userstamp as ULD_ID and timestamp get from scdb done by:RL
-- version:0.4-- sdate:21/02/2014 -- edate:22/02/2014 -- issue:750 -desc:added preaudit and post audit queries done by:dhivya
-- version:0.3 -- sdate:18/02/2014 -- edate:18/02/2014 -- issue:276 -- commentno:26 -- desc:ADD USERSTAMP N TIMESTAMP IN EXPENSE_HOUSEKEEPING_UNIT -- doneby:RL
-- version:0.2 -- sdate:21/01/2014 -- edate:21/01/2014 -- issue:594 -- commentno:50 & 54 -- doneby:RL

DROP PROCEDURE IF EXISTS SP_EXPENSE_HOUSEKEEPING_PAYMENT_INSERT;
CREATE PROCEDURE SP_EXPENSE_HOUSEKEEPING_PAYMENT_INSERT(IN DESTINATIONSCHEMA VARCHAR(50))

BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;
	
	SET @EHKP_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.EXPENSE_HOUSEKEEPING_PAYMENT'));
	PREPARE EHKP_DROPQUERYSTMT FROM @EHKP_DROPQUERY;
	EXECUTE EHKP_DROPQUERYSTMT;
	
	SET @EHKP_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.EXPENSE_HOUSEKEEPING_PAYMENT(
	EHKP_ID	INTEGER NOT NULL AUTO_INCREMENT,
	UNIT_ID	INTEGER NULL,	
	EHKU_ID	INTEGER NULL,	
	EHKP_FOR_PERIOD	DATE NOT NULL,	
	EHKP_PAID_DATE DATE NOT NULL,	
	EHKP_AMOUNT	DECIMAL(5,2) NOT NULL,	
	EHKP_COMMENTS TEXT NULL,
	ULD_ID INTEGER(2) NOT NULL,	
	EHKP_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(EHKP_ID),
	FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
	PREPARE EHKP_CREATEQUERYSTMT FROM @EHKP_CREATEQUERY;
	EXECUTE EHKP_CREATEQUERYSTMT;
	
	SET @EHKP_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.EXPENSE_HOUSEKEEPING_PAYMENT
	(EHKP_ID,UNIT_ID,EHKP_FOR_PERIOD,EHKP_PAID_DATE,EHKP_AMOUNT,EHKP_COMMENTS,ULD_ID,EHKP_TIMESTAMP)
	SELECT ID,TEHKP_UNITID,TEHKP_FORPERIOD,TEHKP_PAIDDATE,TEHKP_AMOUNT,TEHKP_COMMENTS,TEHKP_ULDID,TEHKP_TIMESTAMP
	FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING_PAYMENT'));
	PREPARE EHKP_INSERTQUERYSTMT FROM @EHKP_INSERTQUERY;
	EXECUTE EHKP_INSERTQUERYSTMT;
	
	SET @EHKPINSERTQUERY = (SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.EXPENSE_HOUSEKEEPING_PAYMENT
	(EHKP_ID,EHKU_ID,EHKP_FOR_PERIOD,EHKP_PAID_DATE,EHKP_AMOUNT,EHKP_COMMENTS,ULD_ID,EHKP_TIMESTAMP)
	SELECT ID,TEHKU_UID,TEHKU_FORPERIOD,TEHKU_PAIDDATE,TEHKU_AMOUNT,TEHKU_COMMENTS,TEHKU_ULDID,TEHKU_TIMESTAMP
	FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING_UNIT'));
	PREPARE EHKPINSERTQUERYSTMT FROM @EHKPINSERTQUERY;
	EXECUTE EHKPINSERTQUERYSTMT;
	COMMIT;
	
END;