-- VER 0.2, STARTDATE:09/06/2014, END DATE:09/06/2014, TRACKER NO:566  COMMENTNO:#12, DESC:ADDED ROLLBACK AND COMMIT DONE BY:SASIKALA
-- VER 0.1, STARTDATE:17/05/2014, END DATE:17/05/2014, TRACKER NO:743  COMMENTNO:#168, DESC:SPLITTED THE SP CUSTOMER_TICKLER_DATA FOR DYNAMIC RUNNING PROCESS DONE BY:BHAVANI.R
DROP PROCEDURE IF EXISTS SP_CUSTOMER_TICKLER_FEE_DETAILS;
CREATE PROCEDURE SP_CUSTOMER_TICKLER_FEE_DETAILS()
BEGIN   
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
		CFD_OV_CS_LOOP : LOOP
              
              CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_OLD_VALUE,@VALUE,@REMAINING_STRING);
              SELECT @REMAINING_STRING INTO @TH_OLD_VALUE;
              
              -- SEPERATING COLUMN NAME AND COLUMN VALUE 
              CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
              
              IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
                  SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
                  SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
                  SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
                  
              END IF;
              
              IF UPPER(@COLUMN_NAME) = 'CPP_ID' THEN
                  SELECT CPP_DATA INTO @CPP_DATA FROM CUSTOMER_PAYMENT_PROFILE WHERE CPP_ID = @COLUMN_VALUE;
                  SET @REPLACE_STRING = CONCAT('CPP_DATA=',@CPP_DATA);
                  SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
                  
              END IF;
                
				IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
					SELECT ULD_LOGINID INTO @OLDULDLOGINIDFEE FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
                  	SET @REPLACE_STRING = CONCAT('ULD_LOGINID=',@OLDULDLOGINIDFEE);
					SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
                LEAVE CFD_OV_CS_LOOP;
                END IF;				
					  
              
              IF @TH_OLD_VALUE IS NULL THEN
			          LEAVE  CFD_OV_CS_LOOP;
		          END IF;
			END LOOP;             
           
           IF @TH_NEW_VALUE IS NOT NULL THEN
				SET @V_TEMP_NEW_VALUE = @TH_NEW_VALUE;
				CFD_NV_CS_LOOP : LOOP
              
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_NEW_VALUE,@VALUE,@REMAINING_STRING);
					SELECT @REMAINING_STRING INTO @TH_NEW_VALUE;
              
					-- SEPERATING COLUMN NAME AND COLUMN VALUE 
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
              
					IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
						SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
						SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
						SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
                  
					END IF;
              
					IF UPPER(@COLUMN_NAME) = 'CPP_ID' THEN
						SELECT CPP_DATA INTO @CPP_DATA FROM CUSTOMER_PAYMENT_PROFILE WHERE CPP_ID = @COLUMN_VALUE;
						SET @REPLACE_STRING = CONCAT('CPP_DATA=',@CPP_DATA);
						SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
					END IF;  
				
					IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
						SELECT ULD_LOGINID INTO @NEWULDLOGINIDFEE FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
						SET @REPLACE_STRING = CONCAT('ULD_LOGINID=',@NEWULDLOGINIDPFEE);
						SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
						LEAVE CFD_NV_CS_LOOP;
					END IF;	
              
					IF @TH_NEW_VALUE IS NULL THEN
			          LEAVE  CFD_NV_CS_LOOP;
					END IF;
	           END LOOP;  
			ELSE
             SET @V_TEMP_NEW_VALUE = NULL;
			END IF;
      COMMIT;
			END;