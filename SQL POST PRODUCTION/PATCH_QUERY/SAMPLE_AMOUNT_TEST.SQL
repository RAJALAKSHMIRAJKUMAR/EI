DROP TABLE IF EXISTS TEMP_AMT_TEST1;
CREATE TABLE TEMP_AMT_TEST1(
ID INTEGER AUTO_INCREMENT,
NAME VARCHAR(10),
DOB DATE,
AMOUNT DECIMAL(5,2),
PRIMARY KEY(ID));

DROP PROCEDURE IF EXISTS SP_SUBTEMP_AMT_TEST1_INSERT;
CREATE PROCEDURE SP_SUBTEMP_AMT_TEST1_INSERT(
IN INPUT_NAME VARCHAR(10),
IN INPUT_DOB DATE,
IN INPUT_AMOUNT DECIMAL(5,2),
OUT SUCCESSFLAG INTEGER)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
		SET SUCCESSFLAG = 0;
	END;
	START TRANSACTION;	
	SET SUCCESSFLAG = 0;
	IF(INPUT_NAME IS NOT NULL AND INPUT_DOB IS NOT NULL AND INPUT_AMOUNT IS NOT NULL)THEN
		INSERT INTO TEMP_AMT_TEST1(NAME,DOB,AMOUNT) VALUES (INPUT_NAME,INPUT_DOB,INPUT_AMOUNT);
		SET SUCCESSFLAG = 1;
	END IF;
COMMIT;
END;

DROP PROCEDURE IF EXISTS SP_TEMP_AMT_TEST1_INSERT;
CREATE PROCEDURE SP_TEMP_AMT_TEST1_INSERT(
IN IN_NAME TEXT,
IN IN_DOB TEXT,
IN IN_AMOUNT TEXT,
OUT FINALMESSAGE TEXT)
BEGIN
	DECLARE INDOB DATE;
	DECLARE INAMOUNT  DECIMAL(5,2);
	DECLARE INNAME VARCHAR(10);
	DECLARE SUBSPSUCCESSFLAG INTEGER;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
	END;
	SET @TEMP_NAME = IN_NAME;
	SET @TEMP_DOB = IN_DOB;
	SET @TEMP_AMOUNT = IN_AMOUNT;
	SET FINALMESSAGE = '';
		MAIN_LOOP : LOOP
		CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_NAME,@VALUE,@REMAINING_STRING);
		SELECT @VALUE INTO INNAME;
		SELECT @REMAINING_STRING INTO @TEMP_NAME;
		CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_DOB,@VALUE,@REMAINING_STRING);
		SELECT @VALUE INTO INDOB;
		SELECT @REMAINING_STRING INTO @TEMP_DOB;
		CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_AMOUNT,@VALUE,@REMAINING_STRING);
		SELECT @VALUE INTO INAMOUNT;
		SELECT @REMAINING_STRING INTO @TEMP_AMOUNT;
		START TRANSACTION;	
		IF(INNAME IS NOT NULL AND INDOB IS NOT NULL AND INAMOUNT IS NOT NULL)THEN 
			CALL SP_SUBTEMP_AMT_TEST1_INSERT(INNAME,INDOB,INAMOUNT,@SUCCESSFLAG);
			SET SUBSPSUCCESSFLAG = (SELECT @SUCCESSFLAG);
		END IF;
		IF(SUBSPSUCCESSFLAG=0)THEN
			SET FINALMESSAGE = (SELECT CONCAT(FINALMESSAGE,' ','NAME=',INNAME,',','DOB=',INDOB,',',
			'AMOUNT=',INAMOUNT));
		END IF;
		IF @TEMP_NAME IS NULL THEN
			LEAVE  MAIN_LOOP;
		END IF;
	END LOOP;
	IF(FINALMESSAGE = '')THEN
		SET FINALMESSAGE = 1;
	END IF;
COMMIT;
END;

DROP PROCEDURE IF EXISTS SP_TRG_TEMP_AMT_TEST1_VALIDATION;
CREATE PROCEDURE SP_TRG_TEMP_AMT_TEST1_VALIDATION(
IN AMT DECIMAL(5,2),
IN PROCESS TEXT)
BEGIN
    DECLARE MESSAGE_TEXT VARCHAR(50);
	IF(PROCESS = 'INSERT') OR (PROCESS = 'UPDATE') THEN
		IF(AMT = 999.99)THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'AMOUNT VALUE OUT OF RANGE';
		END IF;
	END IF;
END;

DROP TRIGGER IF EXISTS TRG_TEMP_AMT_TEST_INSERT1_VALIDATION;
CREATE TRIGGER TRG_TEMP_AMT_TEST_INSERT1_VALIDATION
BEFORE INSERT ON TEMP_AMT_TEST1
FOR EACH ROW
BEGIN
	CALL SP_TRG_TEMP_AMT_TEST1_VALIDATION(NEW.AMOUNT,'INSERT');
END;


CALL SP_TEMP_AMT_TEST1_INSERT('aaaa,priya,aaa,bbb','2001-01-01,2014-10-01,2014-10-02,2014-10-02','300.00,1000.00,400.00,20000.00',@FINALMESSAGE);
SELECT @FINALMESSAGE;

SELECT * FROM TEMP_AMT_TEST1