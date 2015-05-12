-- version:0.9 -- sadte:09/06/2014 -- edate:09/06/2014  -- issue:566 COMMENT:12  --desc: IMPLEMENTED ROLLBACK AND COMMIT --doneby:DHIVYA
--  version:0.8 --  sdate:25/03/2014 --  edate:25/03/2014 --  issue:765 -- desc:dynamically get source nd destination schema -- doneby:RL
--  version:0.7 --  sdate:17/03/2014 --  edate:17/03/2014 --  issue:765 -- desc:droped temp table -- doneby:RL
-- version:0.6 -- sdate:04/03/2014 -- edate:04/03/2014 -- Desc:ISSUE CORRECTED INUNIT EXPENSE- DONE BY SAFI
-- version:0.5 -- sdate:28/02/2014 -- edate:28/02/2014 -- issue:750 -- desc:changed userstamp as ULD_ID and timestamp get from scdb done by:RL
-- version:0.4-- sdate:21/02/2014 -- edate:22/02/2014 -- issue:750 -desc:added preaudit and post audit queries done by:dhivya
-- version:0.3 -- sdate:18/02/2014 -- edate:18/02/2014 -- issue:276 -- commentno:26 -- desc:ADD USERSTAMP N TIMESTAMP IN EXPENSE_HOUSEKEEPING_UNIT -- doneby:RL
-- version:0.2 -- sdate:21/01/2014 -- edate:21/01/2014 -- issue:594 -- commentno:50 & 54 -- doneby:RL

DROP PROCEDURE IF EXISTS SP_TEMP_EXPENSE_UNIT_UPDATE;
CREATE PROCEDURE SP_TEMP_EXPENSE_UNIT_UPDATE(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
	DECLARE MINIMUM_ID INTEGER;
	DECLARE MAXIMUM_ID INTEGER;
	DECLARE UNITCATEGORY TEXT;
	DECLARE CUSTFNAME CHAR(30);
	DECLARE CUSTLNAME CHAR(30);	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;	
	SET @TMINID =(SELECT CONCAT('SELECT MIN(ID)INTO @TUMINID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_UNIT'));
	PREPARE TMINIDSTMT FROM @TMINID;
	EXECUTE TMINIDSTMT;
	SET MINIMUM_ID = @TUMINID;	
	SET @TMAXID =(SELECT CONCAT('SELECT MAX(ID)INTO @TUMAXID FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_UNIT'));
	PREPARE TMAXIDSTMT FROM @TMAXID;
	EXECUTE TMAXIDSTMT;
	SET MAXIMUM_ID = @TUMAXID;	
	WHILE(MINIMUM_ID <= MAXIMUM_ID) DO	
	SET @CATEGORY = NULL;
	SET @L_NAME = NULL;
	SET @F_NAME = NULL;	
		SET @EXPDATA = (SELECT CONCAT('SELECT ECNDATA INTO @CATEGORY FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_UNIT WHERE ID=',MINIMUM_ID));
		PREPARE EXPDATASTMT FROM @EXPDATA;
		EXECUTE EXPDATASTMT;
		SET UNITCATEGORY = @CATEGORY;		
		IF (UNITCATEGORY = 'CUSTOMER')THEN		
			SET @LNAME = (SELECT CONCAT('SELECT LASTNAME INTO @L_NAME FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_UNIT WHERE ID=',MINIMUM_ID));
			PREPARE LNAMESTMT FROM @LNAME;
			EXECUTE LNAMESTMT;
			SET CUSTLNAME = @L_NAME;			
			IF(CUSTLNAME IS NULL)THEN			
				SET @FNAME = (SELECT CONCAT('SELECT FIRSTNAME INTO @F_NAME FROM ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_UNIT WHERE ID=',MINIMUM_ID));
				PREPARE FNAMESTMT FROM @FNAME;
				EXECUTE FNAMESTMT;
				SET CUSTFNAME = @F_NAME;				
				SET @UPDATELASTNAME = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_EXPENSE_UNIT SET LASTNAME=@F_NAME WHERE ID=',MINIMUM_ID));
				PREPARE UPDATELASTNAMESTMT FROM @UPDATELASTNAME;
				EXECUTE UPDATELASTNAMESTMT;				
			END IF;			
		END IF;		
		SET MINIMUM_ID = MINIMUM_ID+1;		
	END WHILE;	
	COMMIT;
END;
