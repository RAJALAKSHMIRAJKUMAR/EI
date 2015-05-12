DROP PROCEDURE IF EXISTS SP_TEMP_EXPENSE_HOUSEKEEPING_PAYMENT_INSERT;
CREATE PROCEDURE SP_TEMP_EXPENSE_HOUSEKEEPING_PAYMENT_INSERT(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
	DECLARE MINIMUM_ID INTEGER;
	DECLARE MAXIMUM_ID INTEGER;	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;	
	SET @TEMP_EHK_DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING_PAYMENT'));
	PREPARE TEMP_EHK_DROPQUERYSTMT FROM @TEMP_EHK_DROPQUERY;
	EXECUTE TEMP_EHK_DROPQUERYSTMT;	
	SET @TEMP_EHK_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING_PAYMENT(
	ID INTEGER AUTO_INCREMENT,
	TEHKP_UNITNO INTEGER,
	TEHKP_UNITID INTEGER,
	TEHKP_FORPERIOD DATE,
	TEHKP_PAIDDATE DATE,
	TEHKP_AMOUNT DECIMAL(7,2),
	TEHKP_COMMENTS TEXT,
	TEHKP_ULDID INTEGER,
	TEHKP_TIMESTAMP VARCHAR(50),
	PRIMARY KEY(ID))'));
	PREPARE TEMP_EHK_CREATEQUERYSTMT FROM @TEMP_EHK_CREATEQUERY;
	EXECUTE TEMP_EHK_CREATEQUERYSTMT;	
	SET @TEMP_EHK_INSERTQUERY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING_PAYMENT(
	ID,TEHKP_UNITNO,TEHKP_FORPERIOD,TEHKP_PAIDDATE,TEHKP_AMOUNT,TEHKP_COMMENTS,TEHKP_ULDID,TEHKP_TIMESTAMP)
	SELECT ID,TEHK_UNITNO,TEHK_FORPERIOD,TEHK_PAIDDATE,TEHK_AMOUNT,TEHK_COMMENTS,TEHK_ULDID,TEHK_TIMESTAMP
	FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING TEHK , ',DESTINATIONSCHEMA,'.UNIT U
	WHERE U.UNIT_NO = TEHK.TEHK_UNITNO'));
	PREPARE TEMP_EHK_INSERTQUERYSTMT FROM @TEMP_EHK_INSERTQUERY;
	EXECUTE TEMP_EHK_INSERTQUERYSTMT;	
	SET @T_MINID =(SELECT CONCAT('SELECT MIN(ID)INTO @TH_MINID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING_PAYMENT'));
	PREPARE T_MINIDSTMT FROM @T_MINID;
	EXECUTE T_MINIDSTMT;
	SET MINIMUM_ID = @TH_MINID;	
	SET @T_MAXID =(SELECT CONCAT('SELECT MAX(ID)INTO @TH_MAXID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING_PAYMENT'));
	PREPARE T_MAXIDSTMT FROM @T_MAXID;
	EXECUTE T_MAXIDSTMT;
	SET MAXIMUM_ID = @TH_MAXID;	
	WHILE(MINIMUM_ID <= MAXIMUM_ID) DO	
		SET @UNITID = NULL;	
		SET @U_UNITNO = (SELECT CONCAT('SELECT UNIT_ID INTO @UNITID FROM ',DESTINATIONSCHEMA,'.UNIT
		WHERE UNIT_NO = (SELECT TEHKP_UNITNO FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING_PAYMENT
		WHERE ID = ',MINIMUM_ID,')'));
		PREPARE U_UNITNOSTMT FROM @U_UNITNO;
		EXECUTE U_UNITNOSTMT;		
		SET @UPDATEUNITID =(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_HOUSEKEEPING_PAYMENT
		SET TEHKP_UNITID=@UNITID WHERE ID=',MINIMUM_ID));
		PREPARE UPDATEUNITIDSTMT FROM @UPDATEUNITID;
		EXECUTE UPDATEUNITIDSTMT;		
	SET MINIMUM_ID = MINIMUM_ID+1;
	END WHILE;	
	COMMIT;
END;