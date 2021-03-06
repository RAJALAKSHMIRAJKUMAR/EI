-- VER 1.2 ISSUE:817 COMMENT #139 STARTDATE:24/06/2014 ENDDATE:24/06/2014 DESC:DROPED TEMP TABLES INSIDE ROLL BACK AND COMMIT DONE BY:DHIVYA.A
-- VER 1.1, STARTDATE:24/05/2014, END DATE:24/05/2014, TRACKER NO:743  COMMENTNO:#188, DESC:CHANGES IN SP FOR INSERTION OF COMMENTS WITH DOUBLE QUOTES DONE BY:BHAVANI.R
-- VER 1.0, STARTDATE:17/05/2014, END DATE:17/05/2014, TRACKER NO:743  COMMENTNO:#168, DESC:SPLITTED THE SP CUSTOMER_TICKLER_DATA FOR DYNAMIC RUNNING PROCESS DONE BY:BHAVANI.R
-- VER 0.9, STARTDATE:14/05/2014, END DATE:14/05/2014, TRACKER NO:817  COMMENTNO:#57, DESC:CHANGES IN THE SP TEMP TABLE FOR DYNAMIC RUNNING PROCESS DONE BY:BHAVANI.R
-- VER 0.8, STARTDATE:12/05/2014, END DATE:14/05/2014, TRACKER NO:529  COMMENTNO:#183, DESC:CHANGING THE SP FOR RECORDS UPDATE IN EXPENSE UNIT TABLE WHERE CUSTOMER_ID IS NULL DONE BY:BHAVANI.R
-- VER 0.7, STARTDATE:03/05/2014, END DATE:03/05/2014, TRACKER NO:529  COMMENTNO:#167, DESC:CHANGING THE SP FOR SHOWING CUSTOMER DATA IN TEMP TICKLER FOR OTHER DOMAIN DONE BY:BHAVANI.R
-- VER 0.6, STARTDATE:28/04/2014, END DATE:28/04/2014, TRACKER NO:529  COMMENTNO:#161, DESC:SHOWING THE DATA FOR ULD_ID DONE BY:BHAVANI.R
-- VER 0.5, STARTDATE:25/04/2014, END DATE:25/04/2014, TRACKER NO:529  COMMENTNO:#154, DESC:CHANGES IN DATA FOR START TIME AND END TIME FOR CUSTOMER_ENTRY_DETAILS DONE BY:BHAVANI.R
-- VER 0.4, STARTDATE:07/04/2014, END DATE:07/04/2014, TRACKER NO:797  COMMENTNO:#28, DESC:CHANGED TABLE POST_AUDIT_PROFILE INTO TICKLER_TABID_PROFILE DONE BY:BHAVANI.R
-- VER 0.3, STARTDATE:15/03/2014, END DATE:15/03/2014, TRACKER NO:529  COMMENTNO:#149, DESC:CHANGED LOADED ONLY CUSTOMER TICKLER HISTORY,ADDED CUSTOMER NAME HEADER , DONE BY:LALITHA
-- version 0.2 --startdate:27/02/2014 --enddate:27/02/2014 --issueno:754 commentno:#22 -->description:CHANGING OF DATATYPE  USERSTAMP AS ULD_ID -->DONE BY:SAFI
-- VER 0.1, STARTDATE: 18-02-2014, END DATE: 18-02-2014, DESC: SP FOR DISPLAYING DATA FOR ID FROM TICKLER HISTORY TABLE. DONE BY: MANIKANDAN S
DROP PROCEDURE IF EXISTS SP_CUSTOMER_TICKLER_DATA;
CREATE PROCEDURE SP_CUSTOMER_TICKLER_DATA(IN USERSTAMP VARCHAR(50),OUT CUSTOMER_TICKLER_HISTORY_TMPTBL TEXT)
BEGIN
DECLARE COUNT_TICKLER_HISTORY INT;
DECLARE TICKLERVALUE INTEGER;
DECLARE CUSTOMER_TICKLER_HISTORY_TBL TEXT;
DECLARE CUSTOMER_TICKLER_VALUES_TBL TEXT;
DECLARE CUSTOMER_TICKLER_VALUES_TMPTBL TEXT;
DECLARE USERSTAMP_ID INT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
  ROLLBACK;
  IF CUSTOMER_TICKLER_VALUES_TMPTBL IS NOT NULL THEN
	SET @DROP_TEMP_TICKLER_VALUES=(SELECT CONCAT('DROP TABLE IF EXISTS ',CUSTOMER_TICKLER_VALUES_TMPTBL));
	PREPARE DROP_TEMP_TICKLER_VALUES_STMT FROM @DROP_TEMP_TICKLER_VALUES;
	EXECUTE DROP_TEMP_TICKLER_VALUES_STMT;
	END IF;
 END;
--  TEMP TABLE NAME START
		CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
		SET USERSTAMP_ID=(SELECT @ULDID);
		SET CUSTOMER_TICKLER_HISTORY_TBL=(SELECT CONCAT('TEMP_TICKLER_HISTORY',SYSDATE()));
		SET CUSTOMER_TICKLER_VALUES_TBL=(SELECT CONCAT('TEMP_TICKLER_VALUES',SYSDATE()));
--  NAME FOR TEMP_TICKLER_HISTORY TABLE
		SET CUSTOMER_TICKLER_HISTORY_TBL=(SELECT REPLACE(CUSTOMER_TICKLER_HISTORY_TBL,' ',''));
		SET CUSTOMER_TICKLER_HISTORY_TBL=(SELECT REPLACE(CUSTOMER_TICKLER_HISTORY_TBL,'-',''));
		SET CUSTOMER_TICKLER_HISTORY_TBL=(SELECT REPLACE(CUSTOMER_TICKLER_HISTORY_TBL,':',''));
		SET CUSTOMER_TICKLER_HISTORY_TMPTBL=(SELECT CONCAT(CUSTOMER_TICKLER_HISTORY_TBL,'_',USERSTAMP_ID)); 
--  NAME FOR TEMP_TICKLER_VLAUES TABLE
		SET CUSTOMER_TICKLER_VALUES_TBL=(SELECT REPLACE(CUSTOMER_TICKLER_VALUES_TBL,' ',''));
		SET CUSTOMER_TICKLER_VALUES_TBL=(SELECT REPLACE(CUSTOMER_TICKLER_VALUES_TBL,'-',''));
		SET CUSTOMER_TICKLER_VALUES_TBL=(SELECT REPLACE(CUSTOMER_TICKLER_VALUES_TBL,':',''));
		SET CUSTOMER_TICKLER_VALUES_TMPTBL=(SELECT CONCAT(CUSTOMER_TICKLER_VALUES_TBL,'_',USERSTAMP_ID));
--   TEMP TABLE NAME END
-- CREATING TEMP TABLE FOR GETTING TICKLER HISTORY TABLE VALUES BECAUSE WE NEED TO ITERATE UNIQUE ID AND GET ONE BY ONE ROW.(TH_ID IS NOT SEQUENTIAL SOMETIMES)
		
		SET @CREATE_TEMP_TICKLER_VALUES=(SELECT CONCAT('CREATE TABLE ',CUSTOMER_TICKLER_VALUES_TMPTBL,'(ID INT NOT NULL AUTO_INCREMENT,TH_ID INT,CUSTOMER_ID INT,CUSTOMER_FIRST_NAME CHAR(30),CUSTOMER_LAST_NAME CHAR(30),TP_ID INT,POSTAP_ID INT, TH_OLD_VALUE TEXT,TH_NEW_VALUE TEXT,TH_USERSTAMP VARCHAR(40),TH_TIMESTAMP TIMESTAMP, PRIMARY KEY (ID))'));
		PREPARE CREATE_TEMP_TICKLER_VALUES_STMT FROM @CREATE_TEMP_TICKLER_VALUES;
		EXECUTE CREATE_TEMP_TICKLER_VALUES_STMT;
		
      
-- TEMP TABLE FOR FINAL OUTPUT SIMILAR TO TICKLER HISTORY TABLE
		SET @CREATE_TEMP_TICKLER_HISTORY=(SELECT CONCAT('CREATE TABLE ',CUSTOMER_TICKLER_HISTORY_TMPTBL,'(TH_ID INT,CUSTOMER_ID INT,CUSTOMER_FIRST_NAME CHAR(30),CUSTOMER_LAST_NAME CHAR(30),UPDATION_DELETION CHAR(10),TABLE_NAME VARCHAR(70), TH_OLD_VALUE TEXT,TH_NEW_VALUE TEXT,TH_USERSTAMP  VARCHAR(40),TH_TIMESTAMP TIMESTAMP)'));
		PREPARE CREATE_TEMP_TICKLER_HISTORY_STMT FROM @CREATE_TEMP_TICKLER_HISTORY;
		EXECUTE CREATE_TEMP_TICKLER_HISTORY_STMT;
		
-- GETTING COUNT FROM TICKLER HISTORY IF NO DATA AVAILABLE NO NEED TO GO FOR FURTHER CODINGS
	 SELECT COUNT(*) INTO COUNT_TICKLER_HISTORY FROM TICKLER_HISTORY WHERE CUSTOMER_ID IS NOT NULL;
   
    
IF COUNT_TICKLER_HISTORY > 0 THEN
  -- INSERTING TICKLER HISTORY VALUES IN TEMP TABLE FOR ITERATION

		SET @INSERT_TEMP_TICKLER_VALUES=(SELECT CONCAT('INSERT INTO ',CUSTOMER_TICKLER_VALUES_TMPTBL,' (TH_ID,CUSTOMER_ID,CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME,TP_ID,POSTAP_ID,TH_OLD_VALUE,TH_NEW_VALUE,TH_USERSTAMP,TH_TIMESTAMP) SELECT T.TH_ID,T.CUSTOMER_ID,C.CUSTOMER_FIRST_NAME,C.CUSTOMER_LAST_NAME,T.TP_ID,T.TTIP_ID,T.TH_OLD_VALUE,T.TH_NEW_VALUE,ULD.ULD_LOGINID,T.TH_TIMESTAMP FROM TICKLER_HISTORY T,USER_LOGIN_DETAILS ULD,CUSTOMER C WHERE ULD.ULD_ID=T.ULD_ID AND C.CUSTOMER_ID=T.CUSTOMER_ID AND C.CUSTOMER_ID IS NOT NULL'));
		PREPARE INSERT_TEMP_TICKLER_VALUES_STMT FROM @INSERT_TEMP_TICKLER_VALUES;
		EXECUTE INSERT_TEMP_TICKLER_VALUES_STMT;
		

         
-- ITERATION WILL OCCUR TILL COUNT IS GREATER THAN ZERO.
    WHILE COUNT_TICKLER_HISTORY > 0 DO
		-- GETTING EACH ROW VALUES OF TEMP TICKLER HISTORY TABLE USING AUTO INCREMENT ID
		SET @SELECT_TEMP_TICKLER_VALUES=(SELECT CONCAT('SELECT TH_ID,CUSTOMER_ID,CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME,TP_ID,POSTAP_ID,TH_OLD_VALUE,TH_NEW_VALUE,TH_USERSTAMP,TH_TIMESTAMP INTO @TH_ID,@CUSTOMER_ID,@CUSTOMER_FIRST_NAME,@CUSTOMER_LAST_NAME,@TP_ID,@TTIP_ID,@TH_OLD_VALUE,@TH_NEW_VALUE,@TH_USERSTAMP,@TH_TIMESTAMP FROM ',CUSTOMER_TICKLER_VALUES_TMPTBL,' WHERE ID = ',COUNT_TICKLER_HISTORY));
		PREPARE  SELECT_TEMP_TICKLER_VALUES_STMT FROM @SELECT_TEMP_TICKLER_VALUES;
		EXECUTE SELECT_TEMP_TICKLER_VALUES_STMT;
     
    -- SAVING OLD_VALUE AND NEW VALUE IN NEW TEMP VARIABLE
		SET @V_TEMP_OLD_VALUE = @TH_OLD_VALUE;
		SET @V_TEMP_NEW_VALUE = @TH_NEW_VALUE;
              
		-- IF TABLE = CUSTOMER_COMPANY_DETAILS BECAUSE WE HARD CODING FOR CUSTOMER TABLES
		IF (@TTIP_ID = 9) THEN
              
			-- LOOP FOR GETTING EACH COMMA SEPERATED VALUE FROM OLD VALUE
				CCD_OV_CS_LOOP : LOOP
              
				-- CALLING SP FOR SEPERATING COMMA VALUES
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_OLD_VALUE,@VALUE,@REMAINING_STRING);
					SELECT @REMAINING_STRING INTO @TH_OLD_VALUE;
              
				-- SEPERATING COLUMN NAME AND COLUMN VALUE 
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
          
				-- CHECKING WHETHER COLUMN NAME = CUSTOMER_ID THEN WE HAVE TO GET DATA RELATED TO THAT ID
						IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
							-- GETTING CUSTOMER NAME USING CUSTOMER ID
								SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
                  
							-- REPLACE ID VALUE WITH DATA
								SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
								SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
             	
						END IF;
           
						IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
                 
							SELECT ULD_LOGINID INTO @OLDULDLOGINIDCOMPANY FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
							SET @REPLACE_STRING = CONCAT('ULD_LOGINID=',@OLDULDLOGINIDCOMPANY);
							SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
							LEAVE  CCD_OV_CS_LOOP;
						END IF;
             
						IF @TH_OLD_VALUE IS NULL THEN
							LEAVE  CCD_OV_CS_LOOP;
						END IF;
				END LOOP;           
           
			-- TH_NEW_VALUE MAY BE NULL IN TICKLER HISTORY SO CHECKING WHETHER ITS NOT NULL
			IF @TH_NEW_VALUE IS NOT NULL THEN
				-- LOOP FOR GETTING EACH COMMA SEPERATED VALUE FROM OLD VALUE
					CCD_NV_CS_LOOP : LOOP
              
						CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_NEW_VALUE,@VALUE,@REMAINING_STRING);
						SELECT @REMAINING_STRING INTO @TH_NEW_VALUE;
              
				-- SEPERATING COLUMN NAME AND COLUMN VALUE 
						CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
              
						IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
             
							SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
                  			SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
							SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
                   
						END IF;  
						IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
							SELECT ULD_LOGINID INTO @NEWULDLOGINIDCOMPANY FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
                  			SET @REPLACE_STRING = CONCAT('ULD_LOGINID=',@NEWULDLOGINIDCOMPANY);
							SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
							LEAVE  CCD_NV_CS_LOOP;
						END IF;				  
              
						IF @TH_NEW_VALUE IS NULL THEN
							LEAVE  CCD_NV_CS_LOOP;
						END IF;
					END LOOP;  
			END IF;

		ELSEIF (@TTIP_ID = 10) THEN 
            
              CALL SP_CUSTOMER_TICKLER_ENTRY_DETAILS();
               
		ELSEIF (@TTIP_ID = 12) THEN     
          
		CALL SP_CUSTOMER_TICKLER_FEE_DETAILS();
      
          
		ELSEIF (@TTIP_ID = 13) THEN 
            CACD_OV_CS_LOOP : LOOP
              
              CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_OLD_VALUE,@VALUE,@REMAINING_STRING);
              SELECT @REMAINING_STRING INTO @TH_OLD_VALUE;
              
              -- SEPERATING COLUMN NAME AND COLUMN VALUE 
              CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
              
				IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
                  SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
                  SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
                  SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
				END IF;
              
				IF UPPER(@COLUMN_NAME) = 'UASD_ID' THEN
                    SELECT UASD_ACCESS_CARD INTO @UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=@COLUMN_VALUE;
                    SET @REPLACE_STRING = CONCAT('UASD_ACCESS_CARD=',IFNULL(@UASD_ACCESS_CARD,'NULL'));
                    SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
				END IF;
              
				IF UPPER(@COLUMN_NAME) = 'ACN_ID' THEN
                 IF (@COLUMN_VALUE IS NOT NULL AND UPPER(@COLUMN_VALUE) != 'NULL') THEN
					SELECT ACN_DATA INTO @ACN_DATA FROM ACCESS_CONFIGURATION WHERE ACN_ID = @COLUMN_VALUE;
					SET @REPLACE_STRING = CONCAT('ACN_DATA=',IFNULL(@ACN_DATA,'NULL'));
					SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
                 END IF; 
				END IF;

			   IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
					SELECT ULD_LOGINID INTO @OLDULDLOGINIDACCESS FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
                  	SET @REPLACE_STRING = CONCAT('ULD_LOGINID=',@OLDULDLOGINIDACCESS);
					SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
					LEAVE CACD_OV_CS_LOOP;
                END IF;	
                 
              
                IF @TH_OLD_VALUE IS NULL THEN
  			          LEAVE  CACD_OV_CS_LOOP;
  		          END IF;
	           END LOOP; 
           
           
           IF @TH_NEW_VALUE IS NOT NULL THEN
				SET @V_TEMP_NEW_VALUE = @TH_NEW_VALUE;
				CACD_NV_CS_LOOP : LOOP
              
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_NEW_VALUE,@VALUE,@REMAINING_STRING);
					SELECT @REMAINING_STRING INTO @TH_NEW_VALUE;
              
              -- SEPERATING COLUMN NAME AND COLUMN VALUE 
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
              
              
					IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
						SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
						SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
						SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
					END IF;
              
					IF UPPER(@COLUMN_NAME) = 'UASD_ID' THEN
                      SELECT UASD_ACCESS_CARD INTO @UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=@COLUMN_VALUE;
                      SET @REPLACE_STRING = CONCAT('UASD_ACCESS_CARD=',IFNULL(@UASD_ACCESS_CARD,'NULL'));
                      SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
					END IF;
            
              
					IF UPPER(@COLUMN_NAME) = 'ACN_ID' THEN
						IF (@COLUMN_VALUE IS NOT NULL AND UPPER(@COLUMN_VALUE) != 'NULL') THEN
						SELECT ACN_DATA INTO @ACN_DATA FROM ACCESS_CONFIGURATION WHERE ACN_ID = @COLUMN_VALUE;
						SET @REPLACE_STRING = CONCAT('ACN_DATA=',IFNULL(@ACN_DATA,'NULL'));
						SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
						END IF; 
					END IF;  

					IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
						SELECT ULD_LOGINID INTO @NEWULDLOGINIDACCESS FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
						SET @REPLACE_STRING = CONCAT('ULD_LOGINID=',@NEWULDLOGINIDACCESS);
						SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
						LEAVE CACD_NV_CS_LOOP;
					END IF;
              
					IF @TH_NEW_VALUE IS NULL THEN
			          LEAVE  CACD_NV_CS_LOOP;
					END IF;
				END LOOP;  
           ELSE
             SET @V_TEMP_NEW_VALUE = NULL;
           END IF;     
		ELSEIF (@TTIP_ID = 14) THEN 
            CTD_OV_CS_LOOP : LOOP
              
              CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_OLD_VALUE,@VALUE,@REMAINING_STRING);
              SELECT @REMAINING_STRING INTO @TH_OLD_VALUE;
              
              -- SEPERATING COLUMN NAME AND COLUMN VALUE 
              CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
              
				IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
                  SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
                  SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
                  SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
				END IF;
              
              IF UPPER(@COLUMN_NAME) = 'UASD_ID' THEN
					IF (@COLUMN_VALUE IS NOT NULL AND UPPER(@COLUMN_VALUE) != 'NULL') THEN
                      SELECT UASD_ACCESS_CARD INTO @UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=@COLUMN_VALUE;
                      SET @REPLACE_STRING = CONCAT('UASD_ACCESS_CARD=',IFNULL(@UASD_ACCESS_CARD,'NULL'));
                      SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
					END IF;
              END IF;
			  
				IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
					SELECT ULD_LOGINID INTO @OLDULDLOGINIDLP FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
                  	SET @REPLACE_STRING = CONCAT('ULD_USERSTAMP=',@OLDULDLOGINIDLP);
					SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
					LEAVE CTD_OV_CS_LOOP;
                END IF;	
              
                IF @TH_OLD_VALUE IS NULL THEN
  			          LEAVE  CTD_OV_CS_LOOP;
  		        END IF;
	        END LOOP; 
           
           
           IF @TH_NEW_VALUE IS NOT NULL THEN
				SET @V_TEMP_NEW_VALUE = @TH_NEW_VALUE;
				CTD_NV_CS_LOOP : LOOP
              
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_NEW_VALUE,@VALUE,@REMAINING_STRING);
					SELECT @REMAINING_STRING INTO @TH_NEW_VALUE;
              
					-- SEPERATING COLUMN NAME AND COLUMN VALUE 
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
              
              
					IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
						SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
						SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
						SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
					END IF;
              
					IF UPPER(@COLUMN_NAME) = 'UASD_ID' THEN
						IF (@COLUMN_VALUE IS NOT NULL AND UPPER(@COLUMN_VALUE) != 'NULL') THEN
							SELECT UASD_ACCESS_CARD INTO @UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=@COLUMN_VALUE;
							SET @REPLACE_STRING = CONCAT('UASD_ACCESS_CARD=',IFNULL(@UASD_ACCESS_CARD,'NULL'));
							SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
						END IF; 
					END IF;   

					IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
						SELECT ULD_LOGINID INTO @NEWULDLOGINIDLP FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
						SET @REPLACE_STRING = CONCAT('ULD_LOGINID=',@NEWULDLOGINIDLP);
						SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
						LEAVE CTD_NV_CS_LOOP;
					END IF;	
              
					IF @TH_NEW_VALUE IS NULL THEN
			          LEAVE  CTD_NV_CS_LOOP;
					END IF;
	           END LOOP;  
           ELSE
				SET @V_TEMP_NEW_VALUE = NULL;
           END IF;     
          
		ELSEIF (@TTIP_ID = 15) THEN     
          
          CPD_OV_CS_LOOP : LOOP
              
              CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_OLD_VALUE,@VALUE,@REMAINING_STRING);
              SELECT @REMAINING_STRING INTO @TH_OLD_VALUE;
              
              -- SEPERATING COLUMN NAME AND COLUMN VALUE 
              CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
              
				IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
					SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
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
              
					-- SEPERATING COLUMN NAME AND COLUMN VALUE 
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
              
					IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
						SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
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
		ELSEIF (@TTIP_ID = 18) THEN     
          
			CALL SP_CUSTOMER_TICKLER_PAYMENT_DETAILS();
		ELSEIF (@TTIP_ID = 51) THEN     
          
          EU_OV_CS_LOOP : LOOP
              
				CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_OLD_VALUE,@VALUE,@REMAINING_STRING);
				SELECT @REMAINING_STRING INTO @TH_OLD_VALUE;
              
				-- SEPERATING COLUMN NAME AND COLUMN VALUE 
				CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
              
          
				IF UPPER(@COLUMN_NAME) = 'UNIT_ID' THEN
					SELECT UNIT_NO INTO @UNIT_NO FROM UNIT WHERE UNIT_ID = @COLUMN_VALUE;
					SET @REPLACE_STRING = CONCAT('UNIT_NO=',@UNIT_NO);
					SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
				END IF;
					
				IF UPPER(@COLUMN_NAME) = 'ECN_ID' THEN
					SELECT ECN_DATA INTO @OLDECNATA FROM EXPENSE_CONFIGURATION WHERE ECN_ID = @COLUMN_VALUE;
					SET @REPLACE_STRING = CONCAT('ECN_DATA=',@OLDECNATA);
					SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
				END IF;
					
				LABEL1: BEGIN
					IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
						SET @OLD_TICKLER=(SELECT CONCAT('SELECT TH_OLD_VALUE INTO @OLDTICKLER FROM TICKLER_HISTORY WHERE TH_ID=',@TH_ID));
						PREPARE OLDTICKLER_STMT FROM @OLD_TICKLER;
						EXECUTE OLDTICKLER_STMT;
						SET TICKLERVALUE=(SELECT LOCATE('CUSTOMER_ID=<NULL>',@OLDTICKLER,1));
						IF(TICKLERVALUE=0) THEN
							SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
							SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
							SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
						ELSE
							LEAVE LABEL1;
						END IF;
					END IF;
				END LABEL1;
                       
				IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
					SELECT ULD_LOGINID INTO @OLDLOGINIDEXPENSE FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
                  	SET @REPLACE_STRING = CONCAT('ULD_LOGINID=',@OLDLOGINIDEXPENSE);
					SELECT REPLACE(@V_TEMP_OLD_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_OLD_VALUE;
					LEAVE EU_OV_CS_LOOP;
                END IF;	
              
				IF @TH_OLD_VALUE IS NULL THEN
			        LEAVE  EU_OV_CS_LOOP;
		        END IF;
	        END LOOP;             
           
           IF @TH_NEW_VALUE IS NOT NULL THEN
				SET @V_TEMP_NEW_VALUE = @TH_NEW_VALUE;
				EU_NV_CS_LOOP : LOOP
              
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TH_NEW_VALUE,@VALUE,@REMAINING_STRING);
					SELECT @REMAINING_STRING INTO @TH_NEW_VALUE;
              
					-- SEPERATING COLUMN NAME AND COLUMN VALUE 
					CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
              
				IF UPPER(@COLUMN_NAME) = 'UNIT_ID' THEN
					SELECT UNIT_NO INTO @NEWUNIT_NO FROM UNIT WHERE UNIT_ID = @COLUMN_VALUE;
					SET @REPLACE_STRING = CONCAT('UNIT_NO=',@NEWUNIT_NO);
					SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
				END IF;
			  
				
        
				IF UPPER(@COLUMN_NAME) = 'ECN_ID' THEN
					SELECT ECN_DATA INTO @NEWECNATA FROM EXPENSE_CONFIGURATION WHERE ECN_ID = @COLUMN_VALUE;
					SET @REPLACE_STRING = CONCAT('ECN_DATA=',@NEWECNATA);
					SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
				END IF;
        
				IF UPPER(@COLUMN_NAME) = 'CUSTOMER_ID' THEN
					SELECT CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME INTO @FIRST_NAME_VALUE,@LAST_NAME_VALUE FROM CUSTOMER WHERE CUSTOMER_ID = @COLUMN_VALUE;
					SET @REPLACE_STRING = CONCAT('CUSTOMER_FIRST_NAME=',@FIRST_NAME_VALUE,',CUSTOMER_LAST_NAME=',@LAST_NAME_VALUE);
					SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
				END IF;
                     
				IF UPPER(@COLUMN_NAME) = 'ULD_ID' THEN
					SELECT ULD_LOGINID INTO @NEWLOGINIDEXPENSE FROM USER_LOGIN_DETAILS WHERE ULD_ID = @COLUMN_VALUE;
                  	SET @REPLACE_STRING = CONCAT('ULD_LOGINID=',@NEWLOGINIDEXPENSE);
					SELECT REPLACE(@V_TEMP_NEW_VALUE,@VALUE,@REPLACE_STRING) INTO @V_TEMP_NEW_VALUE;
					LEAVE EU_NV_CS_LOOP;
                END IF;
              
				IF @TH_NEW_VALUE IS NULL THEN
			        LEAVE  EU_NV_CS_LOOP; 
		        END IF;
	        END LOOP;  
			ELSE
				SET @V_TEMP_NEW_VALUE = NULL;
			END IF;
		 
		END IF;
        
 
		IF(@CUSTOMER_ID IS NOT NULL AND @V_TEMP_OLD_VALUE IS NOT NULL)THEN
		IF @V_TEMP_NEW_VALUE IS NULL THEN
    SET @V_TEMP_NEW_VALUE='NULL';
    END IF;
		SET @INSERT_TEMP_TICKLER_HISTORY=(SELECT CONCAT('INSERT INTO ',CUSTOMER_TICKLER_HISTORY_TMPTBL,' SELECT ',@TH_ID,',',@CUSTOMER_ID,',','"',@CUSTOMER_FIRST_NAME,'"',',','"',@CUSTOMER_LAST_NAME,'"',',(SELECT TP_TYPE FROM TICKLER_PROFILE WHERE TP_ID = ',@TP_ID,'),(SELECT TTIP_DATA FROM TICKLER_TABID_PROFILE WHERE TTIP_ID=',@TTIP_ID,'),','"',REPLACE(@V_TEMP_OLD_VALUE,'"','\\"'),'"',',','"',REPLACE(@V_TEMP_NEW_VALUE,'"','\\"'),'"',',','"',@TH_USERSTAMP,'"',',','"',@TH_TIMESTAMP,'"'));
		PREPARE INSERT_TEMP_TICKLER_HISTORY_STMT FROM @INSERT_TEMP_TICKLER_HISTORY;
		EXECUTE INSERT_TEMP_TICKLER_HISTORY_STMT;
		END IF;

      
    SET COUNT_TICKLER_HISTORY = COUNT_TICKLER_HISTORY - 1;
    END WHILE;
         
 END IF;
 		SET @DROP_TEMP_TICKLER_VALUES=(SELECT CONCAT('DROP TABLE IF EXISTS ',CUSTOMER_TICKLER_VALUES_TMPTBL));
		PREPARE DROP_TEMP_TICKLER_VALUES_STMT FROM @DROP_TEMP_TICKLER_VALUES;
		EXECUTE DROP_TEMP_TICKLER_VALUES_STMT;
 
COMMIT;
END;