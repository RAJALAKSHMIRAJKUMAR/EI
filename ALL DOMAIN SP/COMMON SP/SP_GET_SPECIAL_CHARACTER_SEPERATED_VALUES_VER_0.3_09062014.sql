-- VER 0.3 STARTDATE: 09-06-2014, END DATE: 09-06-2014, DESC:ADDED ROLLBACK AND COMMIT DONE BY: SASIKALA
-- VER 0.2, STARTDATE: 13-02-2014, END DATE: 13-02-2014, DESC:CHANGED THIS SP AND MADE IT DYNAMICALLY, HEREAFTER WE CAN USE IT FOR ANY SPECIAL CHARACTER,THIS SP IS CALLED IN SP_PAYMENT_DETAIL_INSERT SP (I CHANGED SP NAME ALSO). DONE BY: MANIKANDAN S
-- VER 0.1, STARTDATE: 11-02-2014, END DATE: 11-02-2014, DESC:SP FOR GETTING COMMA SEPERATED VALUES,THIS SP IS CALLED IN SP_PAYMENT_DETAIL_INSERT SP . DONE BY: MANIKANDAN S

DROP PROCEDURE IF EXISTS SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES;
CREATE PROCEDURE SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(IN SPECIAL_CHARACTER VARCHAR(30), IN INPUT_STRING_WITH_COMMAS TEXT, OUT VALUE TEXT, OUT REMAINING_STRING TEXT)
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
SET @LENGTH = 1;
SET @TEMP = INPUT_STRING_WITH_COMMAS;
SET @SPECIAL_CHAR_LENGTH = LENGTH(SPECIAL_CHARACTER);

		SET @POSITION=(SELECT LOCATE(SPECIAL_CHARACTER, @TEMP,@LENGTH));
		IF @POSITION<=0 THEN
			SET VALUE = @TEMP;
		ELSE
			SELECT SUBSTRING(@TEMP,@LENGTH,@POSITION-1) INTO VALUE;
			SET REMAINING_STRING =(SELECT SUBSTRING(@TEMP,@POSITION+ @SPECIAL_CHAR_LENGTH ));
		END IF;
    
 COMMIT;   
END;
/*
CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('||','C',@value,@remaining_string);
SELECT @value;
SELECT @remaining_string;

SELECT LOCATE('||', 'A||B||C',1)-- 2 POSITION

SELECT SUBSTRING('A||B||C',1,2 -1) -- A VALUE

SELECT SUBSTRING('A||B||C',2+2)
*/


