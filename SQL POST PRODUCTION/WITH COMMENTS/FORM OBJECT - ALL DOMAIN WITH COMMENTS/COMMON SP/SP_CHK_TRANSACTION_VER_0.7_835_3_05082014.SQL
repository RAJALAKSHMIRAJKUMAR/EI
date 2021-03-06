-- version 0.7 --sadte:05/08/2014 --edate:05/08/2014 --issue:835 --commentno:3 --desc:implementing auto commit  --done by : RL
--version 0.6 --sdate:23/06/2014 --edate:23/06/2014 -desc:dropped temp table when rollback occur --doneby:safi    
--version 0.5 --sdate:09/06/2014 --edate:09/06/2014 --issue:566 --comment:12 --doneby:SASIKALA	
--version 0.4 --sdate:07/04/2014 --edate:07/02/2014 --issue:797 --comment:28 --doneby:SAFI	
-- VER 0.3, STARTDATE: 18-02-2014, END DATE: 18-02-2014, DESC:instead of checking child tables using foreign key relationship, now getting child tables using the COLUMN NAME of parent table(whether parent table primary key columna name is available in any TABLE). DONE BY: MANIKANDAN S
-- VER 0.2, STARTDATE: 17-02-2014, END DATE: 17-02-2014, DESC:REMOVED USERSTAMP PARAMETER  DONE BY: DHIVYA
-- VER 0.1, STARTDATE: 13-02-2014, END DATE: 14-02-2014, DESC:SP FOR SP FOR CHECK TRANSACTION OF TABLE. DONE DYNAMICALLY. SO THAT THIS SP CAN BE USED FOR ANY TABLE EVEN IT HAS MANY CHILD TABLES. DONE BY: MANIKANDAN S
DROP PROCEDURE IF EXISTS SP_CHK_TRANSACTION;
CREATE PROCEDURE SP_CHK_TRANSACTION(
IN TABLE_ID INT, 
IN DELETING_ROWID INT, 
OUT OUTPUT_FLAG SMALLINT(1))
BEGIN
	DECLARE V_TABLE_NAME VARCHAR(64);
	DECLARE V_TEMP_TABLE_NAME TEXT;
	DECLARE i INT DEFAULT 1;
	DECLARE DELETION_FLAG SMALLINT(1) DEFAULT 0;
	DECLARE FLAG SMALLINT(1) DEFAULT 0;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
		IF(V_TEMP_TABLE_NAME IS NOT NULL)THEN
			SET @SQL = CONCAT('DROP TABLE IF EXISTS ',V_TEMP_TABLE_NAME);
			PREPARE S1 FROM @SQL;
			EXECUTE S1;
			DEALLOCATE PREPARE S1;
		END IF;
		SET OUTPUT_FLAG = 0;
	END;
	
	SET AUTOCOMMIT = 0;
	START TRANSACTION;

	SELECT TRIM(TTIP_DATA) INTO V_TABLE_NAME FROM TICKLER_TABID_PROFILE WHERE TTIP_ID = TABLE_ID;
	
	SET @SQL = CONCAT('SELECT DISTINCT COLUMN_NAME INTO @V_TABLE_PRIMAY_COLUMN_ID FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''',V_TABLE_NAME,''' AND COLUMN_KEY = ','''PRI''','AND TABLE_SCHEMA=(select database())');
	PREPARE S1 FROM @SQL;
	EXECUTE S1;
	DEALLOCATE PREPARE S1;
  
	SET @SQL1 = CONCAT('SELECT COUNT(*) INTO @ROW_COUNT FROM ',V_TABLE_NAME,' WHERE ',@V_TABLE_PRIMAY_COLUMN_ID,' = ',DELETING_ROWID);
    PREPARE s1 FROM @SQL1;
    EXECUTE s1;
    DEALLOCATE PREPARE s1; 
	
	IF(@ROW_COUNT > 0) THEN
		SET @SQL = CONCAT('SELECT COUNT(TABLE_NAME) INTO @CHILD_TABLE_COUNT FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME IN (''',@V_TABLE_PRIMAY_COLUMN_ID,''') AND TABLE_SCHEMA=(select database()) AND TABLE_NAME NOT IN (''',V_TABLE_NAME,"')");
		PREPARE S1 FROM @SQL;
		EXECUTE S1;
		DEALLOCATE PREPARE S1;
		
		IF @CHILD_TABLE_COUNT > 0 THEN
			SET V_TEMP_TABLE_NAME = CONCAT('TEMP_',V_TABLE_NAME,'_COLUMN_NAMES');
			SET @SQL = CONCAT('DROP TABLE IF EXISTS ',V_TEMP_TABLE_NAME);
			PREPARE S1 FROM @SQL;
			EXECUTE S1;
			DEALLOCATE PREPARE S1;
			
			SET @SQL = CONCAT('CREATE TABLE ',V_TEMP_TABLE_NAME,' (ID INT NOT NULL AUTO_INCREMENT, CHILD_TABLE_NAME VARCHAR(64), PRIMARY KEY (ID))');
			PREPARE S1 FROM @SQL;
			EXECUTE S1;
			DEALLOCATE PREPARE S1;
			
			SET @SQL = CONCAT('INSERT INTO ',V_TEMP_TABLE_NAME,'(CHILD_TABLE_NAME) SELECT TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME IN (''',@V_TABLE_PRIMAY_COLUMN_ID,''') AND TABLE_SCHEMA=(select database()) AND TABLE_NAME NOT IN (''',V_TABLE_NAME,"')");
			PREPARE S1 FROM @SQL;
			EXECUTE S1;
			DEALLOCATE PREPARE S1;
     
			L1: LOOP
			
				SET @SQL = CONCAT('SELECT CHILD_TABLE_NAME INTO @CHILD_TABLE_NAME FROM ',V_TEMP_TABLE_NAME,' WHERE ID = ',i);
				PREPARE S1 FROM @SQL;
				EXECUTE S1;
				DEALLOCATE PREPARE S1;
				
				SET @SQL = CONCAT('SELECT COUNT(*) INTO @COUNT FROM ', @CHILD_TABLE_NAME,' WHERE ',@V_TABLE_PRIMAY_COLUMN_ID ,'=', DELETING_ROWID);
				PREPARE S1 FROM @SQL;
				EXECUTE S1;
				DEALLOCATE PREPARE S1;
			
				IF @COUNT > 0 THEN
					SET DELETION_FLAG = 1;
					LEAVE L1;
				END IF;
      
				SET i = i + 1;
      
				SET @CHILD_TABLE_COUNT = @CHILD_TABLE_COUNT - 1;
      
				IF (@CHILD_TABLE_COUNT = 0) THEN
					LEAVE L1;
				END IF;
     
			END LOOP;
    
			IF DELETION_FLAG != 1 THEN
				SET FLAG = 1;
			END IF;
			
			SET @SQL = CONCAT('DROP TABLE IF EXISTS ',V_TEMP_TABLE_NAME);
			PREPARE S1 FROM @SQL;
			EXECUTE S1;
			DEALLOCATE PREPARE S1;
		
		ELSE  
    
			SET FLAG = 1;
		
		END IF;
	
	ELSE
		
		SET FLAG = 0;

	END IF;
	SET OUTPUT_FLAG = FLAG;
COMMIT;
END;