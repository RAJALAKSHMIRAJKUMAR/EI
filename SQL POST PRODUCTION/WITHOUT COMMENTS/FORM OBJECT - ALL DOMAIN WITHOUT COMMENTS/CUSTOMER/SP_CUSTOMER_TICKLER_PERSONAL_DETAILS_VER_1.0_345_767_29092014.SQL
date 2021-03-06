DROP PROCEDURE IF EXISTS SP_CUSTOMER_TICKLER_PERSONAL_DETAILS;
CREATE PROCEDURE SP_CUSTOMER_TICKLER_PERSONAL_DETAILS()
BEGIN
DECLARE FINAL_UNITNO SMALLINT(4) UNSIGNED ZEROFILL;
DECLARE FIRST_NAME_VALUE TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
CPD_OV_CS_LOOP : LOOP
              CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_OLD_VALUE,@VALUE,@REMAINING_STRING);
              SELECT @REMAINING_STRING INTO @TH_OLD_VALUE;
              CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
				IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
					      IF EXISTS (SELECT CUSTOMER_FIRST_NAME FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE) THEN
								SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
        END IF;
        SET @SELECT_CUSTOMER_FIRST_NAME=(SELECT CONCAT('SELECT CUSTOMER_FIRST_NAME INTO @FIRSTNAMEVALUE FROM ',TEMP_CUSTOMER,' WHERE CUSTOMER_ID = @COLUMN_VALUE'));
        PREPARE SELECT_CUSTOMER_FIRST_NAME_STMT FROM @SELECT_CUSTOMER_FIRST_NAME;
        EXECUTE SELECT_CUSTOMER_FIRST_NAME_STMT;
        SET FIRST_NAME_VALUE=@FIRSTNAMEVALUE;
        IF (FIRST_NAME_VALUE IS NOT NULL) THEN
				SET @SELECT_CUSTOMER_NAME=(SELECT CONCAT ('SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM ',TEMP_CUSTOMER,' WHERE CUSTOMER_ID = @COLUMN_VALUE'));
				PREPARE SELECT_CUSTOMER_NAME_STMT FROM @SELECT_CUSTOMER_NAME;
        		EXECUTE SELECT_CUSTOMER_NAME_STMT;
        		        END IF;
					SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
					SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
				END IF;
        IF UPPER(@COLUMN_NAME) = 'NC_ID' THEN
					SELECT NC_DATA INTO @NC_DATA FROM NATIONALITY_CONFIGURATION WHERE NC_ID = @COLUMN_VALUE;
					SET @REPLACE_STRING = CONCAT('NC_DATA=',@NC_DATA);
					SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
				END IF;
        IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
					SELECT ULD_LOGINID INTO @OLDULDLOGINIDPERSONAL FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
                  	SET @REPLACE_STRING = CONCAT('ULD_LOGINID=',@OLDULDLOGINIDPERSONAL);
					SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
					LEAVE CPD_OV_CS_LOOP;
                END IF;	
				IF @TH_OLD_VALUE IS NULL THEN
			        LEAVE  CPD_OV_CS_LOOP;
		        END IF;
	        END LOOP;             
			IF @TH_NEW_VALUE IS NOT NULL THEN
				SET @V_TEMP_NEW_VALUE = @TH_NEW_VALUE;
				CPD_NV_CS_LOOP : LOOP
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_NEW_VALUE,@VALUE,@REMAINING_STRING);
					SELECT @REMAINING_STRING INTO @TH_NEW_VALUE;
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
					IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
						      IF EXISTS (SELECT CUSTOMER_FIRST_NAME FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE) THEN
								SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
        END IF;
        SET @SELECT_CUSTOMER_FIRST_NAME=(SELECT CONCAT('SELECT CUSTOMER_FIRST_NAME INTO @FIRSTNAMEVALUE FROM ',TEMP_CUSTOMER,' WHERE CUSTOMER_ID = @COLUMN_VALUE'));
        PREPARE SELECT_CUSTOMER_FIRST_NAME_STMT FROM @SELECT_CUSTOMER_FIRST_NAME;
        EXECUTE SELECT_CUSTOMER_FIRST_NAME_STMT;
        SET FIRST_NAME_VALUE=@FIRSTNAMEVALUE;
        IF (FIRST_NAME_VALUE IS NOT NULL) THEN
				SET @SELECT_CUSTOMER_NAME=(SELECT CONCAT ('SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM ',TEMP_CUSTOMER,' WHERE CUSTOMER_ID = @COLUMN_VALUE'));
				PREPARE SELECT_CUSTOMER_NAME_STMT FROM @SELECT_CUSTOMER_NAME;
        		EXECUTE SELECT_CUSTOMER_NAME_STMT;
        		        END IF;
						SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
						SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
					END IF;
					IF UPPER(@COLUMN_NAME) = 'NC_ID' THEN
						SELECT NC_DATA INTO @NC_DATA FROM NATIONALITY_CONFIGURATION WHERE NC_ID = @COLUMN_VALUE;
						SET @REPLACE_STRING = CONCAT('NC_DATA=',@NC_DATA);
						SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
					END IF; 
					IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
						SELECT ULD_LOGINID INTO @NEWULDLOGINIDPERSONAL FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
						SET @REPLACE_STRING = CONCAT('ULD_LOGINID=',@NEWULDLOGINIDPERSONAL);
						SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
						LEAVE CPD_NV_CS_LOOP;
					END IF;	
					IF @TH_NEW_VALUE IS NULL THEN
			          LEAVE  CPD_NV_CS_LOOP; 
					END IF;
	           END LOOP;  
           ELSE
             SET @V_TEMP_NEW_VALUE = NULL;
           END IF;
           COMMIT;
		   END;  
