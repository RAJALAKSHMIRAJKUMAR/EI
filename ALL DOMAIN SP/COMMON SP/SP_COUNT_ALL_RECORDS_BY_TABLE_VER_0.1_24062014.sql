--> version 0.1-->startdate:24/06/2014  enddate:24/06/2014-->issueno:743 ,commentno:261-->desc:dynamically created table n added comparison to compare before n after restart tables by puni

-- CALL QUERY
-- CALL SP_COUNT_ALL_RECORDS_BY_TABLE("BEFORERESTART")
DROP PROCEDURE IF EXISTS SP_COUNT_ALL_RECORDS_BY_TABLE;
CREATE  PROCEDURE SP_COUNT_ALL_RECORDS_BY_TABLE(INSTTYPE VARCHAR(20))
BEGIN
DECLARE done INT DEFAULT 0;
DECLARE TNAME CHAR(255);
DECLARE table_names CURSOR for
-- SELECT ALL TABLES
SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE(); 
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
OPEN table_names; 
SET @DROPBEFTBL=(SELECT CONCAT('DROP TABLE IF EXISTS ',INSTTYPE));
    PREPARE DROPBEFTBL_STMT FROM @DROPBEFTBL;
    EXECUTE DROPBEFTBL_STMT;
-- CREATE BEFORE RESTART TABLE
IF(	INSTTYPE!="AFTERRESTART") THEN
	SET @CREATEBEFORETBL=(SELECT CONCAT('CREATE TABLE ',INSTTYPE,'(ROWID INTEGER NOT NULL AUTO_INCREMENT,TABLE_NAME CHAR(255),RECORD_COUNT INT,PRIMARY KEY(ROWID)) ENGINE = INNODB;'));
    PREPARE CREATEBEFORETBL_STMT FROM @CREATEBEFORETBL;
    EXECUTE CREATEBEFORETBL_STMT;
-- CREATE AFTERRESTART TABLE
ELSE
	SET @CREATEBEFORETBL=(SELECT CONCAT('CREATE TABLE ',INSTTYPE,'(ROWID INTEGER NOT NULL AUTO_INCREMENT,TABLE_NAME CHAR(255),RECORD_COUNT INT,CHKCOUNT INT,PRIMARY KEY(ROWID)) ENGINE = INNODB;'));
    PREPARE CREATEBEFORETBL_STMT FROM @CREATEBEFORETBL;
    EXECUTE CREATEBEFORETBL_STMT;
END IF;
-- INSERT ALL TABLE NAME N ROW COUNT
WHILE done = 0 DO
  FETCH NEXT FROM table_names INTO TNAME;
   IF done = 0 THEN
    SET @SQL_TXT = CONCAT("INSERT INTO ",INSTTYPE,"(TABLE_NAME,RECORD_COUNT)(SELECT '" , TNAME  , "' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM ", TNAME, ")");
    PREPARE stmt_name FROM @SQL_TXT;
    EXECUTE stmt_name;
    DEALLOCATE PREPARE stmt_name;
  END IF;
END WHILE;
CLOSE table_names;
-- COMPARING BEFORE RESTART N AFTER RESTART TABLE
IF  (SELECT count(*)FROM information_schema.TABLES WHERE (TABLE_SCHEMA = DATABASE()) AND (TABLE_NAME = 'AFTERRESTART'))>0 THEN
SET @TESTFLAG=0;
	IF (SELECT COUNT(*) FROM AFTERRESTART)>0 AND (SELECT COUNT(*) FROM BEFORERESTART)>0 THEN
		SET @MINROWID=(SELECT MIN(ROWID) FROM AFTERRESTART);
		SET @MAXROWID=(SELECT MAX(ROWID) FROM AFTERRESTART);
		WHILE @MINROWID<=@MAXROWID DO
			SET @MNROWID=(SELECT MIN(ROWID) FROM BEFORERESTART);
			SET @MXROWID=(SELECT MAX(ROWID) FROM BEFORERESTART);	
			WHILE @MNROWID<=@MXROWID DO
				IF (SELECT TABLE_NAME FROM BEFORERESTART WHERE ROWID=@MNROWID)=(SELECT TABLE_NAME FROM AFTERRESTART WHERE ROWID=@MINROWID) THEN
					IF (SELECT RECORD_COUNT FROM BEFORERESTART WHERE ROWID=@MNROWID)!=(SELECT RECORD_COUNT FROM AFTERRESTART WHERE ROWID=@MINROWID) THEN
					SET @TESTFLAG=1;
						UPDATE AFTERRESTART SET CHKCOUNT=1 WHERE ROWID=@MINROWID;
					END IF;
				END IF;
				SET @MNROWID=@MNROWID+1;	
			END WHILE;
			SET @MINROWID=@MINROWID+1;
		END WHILE;
	END IF;
END IF;
END;