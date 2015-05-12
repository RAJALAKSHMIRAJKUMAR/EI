DROP PROCEDURE IF EXISTS SP_TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION_SPLIT4;
CREATE PROCEDURE SP_TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION_SPLIT4(IN SOURCESCHEMA  VARCHAR(40),IN DESTINATIONSCHEMA  VARCHAR(40))
BEGIN
	DECLARE STARTTIME TIME;
	DECLARE ENDTIME TIME;
	DECLARE DURATION TIME;
	DECLARE MIN_PDID INTEGER;
	DECLARE MAX_PDID INTEGER;
	DECLARE MIN_TPDURV_ID INTEGER;
	DECLARE MAX_TPDURV_ID INTEGER;
	DECLARE FORPERIOD_MONTH INTEGER;
	DECLARE FORPERIOD_YEAR INTEGER;
	DECLARE ENDDATE DATE;
	DECLARE STARTDATE_MONTH INTEGER;
	DECLARE STARTDATE_LENGTH INTEGER;
	DECLARE STARTDATE_YEAR INTEGER;
	DECLARE STARTDATE DATE;
	DECLARE FORPERIOD DATE;
	DECLARE CURRENT_STARTDATE_MONTH INTEGER;
	DECLARE CURRENT_STARTDATE_YEAR INTEGER;
	DECLARE CURRENT_ENDDATE_MONTH INTEGER;
	DECLARE CURRENT_ENDDATE_YEAR INTEGER;
	DECLARE CURRENT_SDATE_MONTH_YEAR TEXT;
	DECLARE PREVIOUS_REC_ENDDATE_MONTH INTEGER;
	DECLARE PREVIOUS_REC_ENDDATE_YEAR INTEGER;
	DECLARE PREVIOUS_REC_ENDDATE_MONTH_YEAR TEXT;
	DECLARE PTDDATE DATE;
	DECLARE PTDDATE1 DATE;
	DECLARE PTDDATE2 DATE;
	DECLARE RECHECKINFLAG VARCHAR(2);
	DECLARE REC_VER INTEGER;
    SET FOREIGN_KEY_CHECKS=0;  
	SET STARTTIME = (SELECT CURTIME());		
	SET @MINPDID = (SELECT CONCAT('SELECT MIN(PD_ID) INTO @MIN_PDID FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_SPLIT4'));
	PREPARE MINPDID_STMT FROM @MINPDID;
    EXECUTE MINPDID_STMT;
	SET MIN_PDID=@MIN_PDID;
	SET @MAXPDID = (SELECT CONCAT('SELECT MAX(PD_ID) INTO @MAX_PDID FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_SPLIT4'));
	PREPARE MAXPDID_STMT FROM @MAXPDID;
    EXECUTE MAXPDID_STMT;
	SET MAX_PDID=@MAX_PDID;
	WHILE(MIN_PDID<=MAX_PDID)DO
	    SET @FORPERIOD=NULL;
		SET @SELECT_FORPERIOD = (SELECT CONCAT('SELECT PD_FOR_PERIOD INTO @FORPERIOD FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_SPLIT4 WHERE PD_ID=',MIN_PDID));
		PREPARE SELECT_FORPERIOD_STMT FROM @SELECT_FORPERIOD;
        EXECUTE SELECT_FORPERIOD_STMT;
		SET FORPERIOD=@FORPERIOD;		
        SET @DROP_TEMP_PAYMENT_DETAILS_UPDATE_REC=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION'));
        PREPARE DROP_TEMP_PAYMENT_DETAILS_UPDATE_REC_STMT FROM @DROP_TEMP_PAYMENT_DETAILS_UPDATE_REC;
        EXECUTE DROP_TEMP_PAYMENT_DETAILS_UPDATE_REC_STMT;		
		SET @CREATE_TEMP_PAYMENT_DETAILS_UPDATE_REC=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION(TPDURV_ID INTEGER AUTO_INCREMENT,TPDURV_CUSTID INTEGER,
		TPDURV_RECVER INTEGER,TPDURV_STARTDATE DATE,TPDURV_ENDDATE DATE,TPDURV_PTDDATE DATE,TPDURV_RECHECKINFLAG
		CHAR(1),PRIMARY KEY(TPDURV_ID))'));		
		PREPARE CREATE_TEMP_PAYMENT_DETAILS_UPDATE_REC_STMT FROM @CREATE_TEMP_PAYMENT_DETAILS_UPDATE_REC;
        EXECUTE CREATE_TEMP_PAYMENT_DETAILS_UPDATE_REC_STMT; 		
		SET @INSERT_TEMP_PAYMENT_DETAILS_UPDATE_REC=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION(TPDURV_CUSTID,TPDURV_RECVER,TPDURV_STARTDATE,TPDURV_ENDDATE,TPDURV_PTDDATE,TPDURV_RECHECKINFLAG)
		SELECT TCED.CUSTOMER_ID,TCED.CED_REC_VER,TCED.CED_STARTDATE,TCED.CED_ENDDATE,TCED.CED_PRETERMINATE_DATE,TCED.CED_RECHECKIN FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS TCED WHERE TCED.CUSTOMER_ID=(SELECT CUSTOMER_ID FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_SPLIT4 WHERE PD_ID=',MIN_PDID,')AND
		TCED.UNIT_ID=(SELECT UNIT_ID FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_SPLIT4 WHERE PD_ID=',MIN_PDID,')
		AND IF(TCED.CED_PRETERMINATE_DATE IS NOT NULL,TCED.CED_PRETERMINATE_DATE>TCED.CED_STARTDATE,TCED.CED_ENDDATE>TCED.CED_STARTDATE)'));
		PREPARE INSERT_TEMP_PAYMENT_DETAILS_UPDATE_REC_STMT FROM @INSERT_TEMP_PAYMENT_DETAILS_UPDATE_REC;
        EXECUTE INSERT_TEMP_PAYMENT_DETAILS_UPDATE_REC_STMT; 
        SET @MIN_TPDURV_ID=NULL;
        SET @MAX_TPDURV_ID=NULL;
		SET @MINTPDURV_ID = (SELECT CONCAT('SELECT MIN(TPDURV_ID) INTO @MIN_TPDURV_ID FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION'));
		PREPARE MINTPDURV_ID_STMT FROM @MINTPDURV_ID;
        EXECUTE MINTPDURV_ID_STMT;
        SET MIN_TPDURV_ID=@MIN_TPDURV_ID;		
		SET @MAXTPDURV_ID = (SELECT CONCAT('SELECT MAX(TPDURV_ID) INTO @MAX_TPDURV_ID FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION'));
		PREPARE MAXTPDURV_ID_STMT FROM @MAXTPDURV_ID;
		EXECUTE MAXTPDURV_ID_STMT;  
        SET MAX_TPDURV_ID=@MAX_TPDURV_ID;		
		WHILE(MIN_TPDURV_ID<=MAX_TPDURV_ID)DO
		SET @TPDURV_PTDATE=NULL;
			SET @SELECT_TPDURV_PTDDATE=(SELECT CONCAT('SELECT TPDURV_PTDDATE  INTO @TPDURV_PTDATE FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID,' AND TPDURV_PTDDATE IS NOT NULL'));
			PREPARE SELECT_TPDURV_PTDDATE_STMT FROM @SELECT_TPDURV_PTDDATE;
            EXECUTE SELECT_TPDURV_PTDDATE_STMT; 
			SET PTDDATE=@TPDURV_PTDATE;
			DEALLOCATE  PREPARE SELECT_TPDURV_PTDDATE_STMT;
			IF PTDDATE IS NOT NULL THEN   
                SET @ENDDATE=NULL;
				SET @SELECT_ENDDATE = (SELECT CONCAT('SELECT TPDURV_PTDDATE INTO @ENDDATE FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID));
				PREPARE SELECT_ENDDATE_STMT FROM @SELECT_ENDDATE;
                EXECUTE SELECT_ENDDATE_STMT; 
				SET ENDDATE=@ENDDATE;
			ELSE
			    SET @ENDDATE=NULL;
				SET @SELECTENDDATE = (SELECT CONCAT('SELECT TPDURV_ENDDATE INTO @ENDDATE FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID));
				PREPARE SELECTENDDATE_STMT FROM @SELECTENDDATE;
                EXECUTE SELECTENDDATE_STMT;
				SET ENDDATE=@ENDDATE;
			END IF;   
			SET @STARTDATE_MONTH=NULL;
			SET @STARTDATE_YEAR=NULL;
			SET @SELECT_STARTDATE_MONTH = (SELECT CONCAT('SELECT MONTH(TPDURV_STARTDATE) INTO @STARTDATE_MONTH FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID));
			PREPARE SELECT_STARTDATE_MONTH_STMT FROM @SELECT_STARTDATE_MONTH;
            EXECUTE SELECT_STARTDATE_MONTH_STMT;
			SET STARTDATE_MONTH=@STARTDATE_MONTH;
			SET @SELECT_STARTDATE_YEAR = (SELECT CONCAT('SELECT YEAR(TPDURV_STARTDATE) INTO @STARTDATE_YEAR FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID));
			PREPARE SELECT_STARTDATE_YEAR_STMT FROM @SELECT_STARTDATE_YEAR;
            EXECUTE SELECT_STARTDATE_YEAR_STMT;
			SET STARTDATE_YEAR=@STARTDATE_YEAR;
			SET STARTDATE_LENGTH=(SELECT LENGTH(STARTDATE_MONTH));			
			IF(STARTDATE_LENGTH=1) THEN   
				SET STARTDATE=(SELECT CONCAT(STARTDATE_YEAR,'-','0',STARTDATE_MONTH,'-','01'));				
			ELSE
				SET STARTDATE=(SELECT CONCAT(STARTDATE_YEAR,'-',STARTDATE_MONTH,'-','01'));				
			END IF; 
            SET @CURRENT_STARTDATE_MONTH=NULL;
			SET @CURRENT_STARTDATE_YEAR=NULL;
			SET @CURRENTSTARTDATE_MONTH = (SELECT CONCAT('SELECT MONTH(TPDURV_STARTDATE) INTO @CURRENT_STARTDATE_MONTH FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID));
			PREPARE CURRENTSTARTDATE_MONTH_STMT FROM @CURRENTSTARTDATE_MONTH;
            EXECUTE CURRENTSTARTDATE_MONTH_STMT;
			SET CURRENT_STARTDATE_MONTH=@CURRENT_STARTDATE_MONTH;
			SET @CURRENTSTARTDATE_YEAR = (SELECT CONCAT('SELECT YEAR(TPDURV_STARTDATE) INTO @CURRENT_STARTDATE_YEAR FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID));
			PREPARE CURRENTSTARTDATE_YEAR_STMT FROM @CURRENTSTARTDATE_YEAR;
            EXECUTE CURRENTSTARTDATE_YEAR_STMT;
			SET CURRENT_STARTDATE_YEAR=@CURRENT_STARTDATE_YEAR;
			SET @TPDURV_PTDATE1=NULL;
			SET @SELECT_TPDURV_PTDDATE1=(SELECT CONCAT('SELECT TPDURV_PTDDATE  INTO @TPDURV_PTDATE1 FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID,' AND TPDURV_PTDDATE IS NOT NULL'));
			PREPARE SELECT_TPDURV_PTDDATE1_STMT FROM @SELECT_TPDURV_PTDDATE1;
            EXECUTE SELECT_TPDURV_PTDDATE1_STMT;
            SET PTDDATE1=@TPDURV_PTDATE1;	
			IF PTDDATE1 IS NOT NULL THEN
			    SET @CURRENT_ENDDATE_MONTH=NULL;
				SET @CURRENT_ENDDATE_YEAR=NULL;
                SET @CURRENTENDDATE_MONTH = (SELECT CONCAT('SELECT MONTH(TPDURV_PTDDATE) INTO @CURRENT_ENDDATE_MONTH FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID));
				PREPARE CURRENTENDDATE_MONTH_STMT FROM @CURRENTENDDATE_MONTH;
                EXECUTE CURRENTENDDATE_MONTH_STMT;
				SET CURRENT_ENDDATE_MONTH=@CURRENT_ENDDATE_MONTH;
				SET @CURRENTENDDATE_YEAR = (SELECT CONCAT('SELECT YEAR(TPDURV_PTDDATE) INTO @CURRENT_ENDDATE_YEAR FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID));
				PREPARE CURRENTENDDATE_YEAR_STMT FROM @CURRENTENDDATE_YEAR;
                EXECUTE CURRENTENDDATE_YEAR_STMT;
				SET CURRENT_ENDDATE_YEAR=@CURRENT_ENDDATE_YEAR;
            ELSE
			    SET @CURRENT_ENDDATE_MONTH=NULL;
				SET @CURRENT_ENDDATE_YEAR=NULL;
                SET @SELECT_CURRENT_ENDDATE_MONTH = (SELECT CONCAT('SELECT MONTH(TPDURV_ENDDATE) INTO @CURRENT_ENDDATE_MONTH FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID));
				PREPARE SELECT_CURRENT_ENDDATE_MONTH_STMT FROM @SELECT_CURRENT_ENDDATE_MONTH;
                EXECUTE SELECT_CURRENT_ENDDATE_MONTH_STMT;
				SET @SELECT_CURRENT_ENDDATE_YEAR = (SELECT CONCAT('SELECT YEAR(TPDURV_ENDDATE) INTO @CURRENT_ENDDATE_YEAR FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID));
				PREPARE SELECT_CURRENT_ENDDATE_YEAR_STMT FROM @SELECT_CURRENT_ENDDATE_YEAR;
                EXECUTE SELECT_CURRENT_ENDDATE_YEAR_STMT;
            END IF;
			SET CURRENT_STARTDATE_MONTH=@CURRENT_STARTDATE_MONTH;
			SET CURRENT_STARTDATE_YEAR=@CURRENT_STARTDATE_YEAR;
			SET CURRENT_SDATE_MONTH_YEAR = (SELECT CONCAT(CURRENT_STARTDATE_MONTH,'-',CURRENT_STARTDATE_YEAR));
            SET @TPDURV_RECHECKINFLAG=NULL;
			SET @SELECT_TPDURV_RECHECKINFLAG=(SELECT CONCAT('SELECT TPDURV_RECHECKINFLAG INTO @TPDURV_RECHECKINFLAG FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID,' AND TPDURV_RECHECKINFLAG IS NOT NULL'));
			PREPARE SELECT_TPDURV_RECHECKINFLAG_STMT FROM @SELECT_TPDURV_RECHECKINFLAG;
            EXECUTE SELECT_TPDURV_RECHECKINFLAG_STMT;
			SET RECHECKINFLAG=@TPDURV_RECHECKINFLAG;
			     IF RECHECKINFLAG IS NOT NULL  THEN
                     SET @TPDURV_PTDDATE2=NULL;	
				    SET @SELECT_TPDURV_PPTDDATE= (SELECT CONCAT('SELECT TPDURV_PTDDATE INTO @TPDURV_PTDDATE2 FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID,' AND TPDURV_PTDDATE IS NOT NULL AND TPDURV_ID-1'));
				    PREPARE SELECT_TPDURV_PPTDDATE_STMT FROM @SELECT_TPDURV_PPTDDATE;
                    EXECUTE SELECT_TPDURV_PPTDDATE_STMT;
					SET PTDDATE2=@TPDURV_PTDDATE2;
				     IF PTDDATE2 IS NOT NULL THEN
					 SET @PREVIOUS_REC_ENDDATE_MONTH=NULL;
					 SET @PREVIOUS_REC_ENDDATE_YEAR=NULL;
					   SET @SELECT_PREVIOUS_REC_ENDDATE_MONTH1 = (SELECT CONCAT('SELECT MONTH(TPDURV_PTDDATE) INTO @PREVIOUS_REC_ENDDATE_MONTH FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID,' AND TPDURV_ID-1'));
					   PREPARE SELECT_PREVIOUS_REC_ENDDATE_MONTH1_STMT FROM @SELECT_PREVIOUS_REC_ENDDATE_MONTH1;
                       EXECUTE SELECT_PREVIOUS_REC_ENDDATE_MONTH1_STMT;
					   SET @SELECT_PREVIOUS_REC_ENDDATE_YEAR = (SELECT CONCAT('SELECT YEAR(TPDURV_PTDDATE) INTO @PREVIOUS_REC_ENDDATE_YEAR FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID,' AND TPDURV_ID-1'));
					   PREPARE SELECT_PREVIOUS_REC_ENDDATE_YEAR_STMT FROM @SELECT_PREVIOUS_REC_ENDDATE_YEAR;
                       EXECUTE SELECT_PREVIOUS_REC_ENDDATE_YEAR_STMT;
				    ELSE
					   SET @SELECT_PREVIOUS_REC_ENDDATE_MONTH = (SELECT CONCAT('SELECT MONTH(TPDURV_ENDDATE) INTO @PREVIOUS_REC_ENDDATE_MONTH FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID,' AND TPDURV_ID-1'));
					   PREPARE SELECT_PREVIOUS_REC_ENDDATE_MONTH_STMT FROM @SELECT_PREVIOUS_REC_ENDDATE_MONTH;
                       EXECUTE SELECT_PREVIOUS_REC_ENDDATE_MONTH_STMT;
					   SET @SELECTPREVIOUS_REC_ENDDATE_YEAR = (SELECT CONCAT('SELECT YEAR(TPDURV_ENDDATE) INTO @PREVIOUS_REC_ENDDATE_YEAR FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE TPDURV_ID=',MIN_TPDURV_ID,' AND TPDURV_ID-1'));
					   PREPARE SELECTPREVIOUS_REC_ENDDATE_YEAR_STMT FROM @SELECTPREVIOUS_REC_ENDDATE_YEAR;
                       EXECUTE SELECTPREVIOUS_REC_ENDDATE_YEAR_STMT;
				    END IF;
					SET PREVIOUS_REC_ENDDATE_MONTH=@PREVIOUS_REC_ENDDATE_MONTH;
					SET PREVIOUS_REC_ENDDATE_YEAR=@PREVIOUS_REC_ENDDATE_YEAR;
			SET PREVIOUS_REC_ENDDATE_MONTH_YEAR = (SELECT CONCAT(PREVIOUS_REC_ENDDATE_MONTH,'-',PREVIOUS_REC_ENDDATE_YEAR));
				IF(CURRENT_SDATE_MONTH_YEAR=PREVIOUS_REC_ENDDATE_MONTH_YEAR)THEN
				    SET @REC_VER=NULL;
					SET @SELECT_REC_VER = (SELECT CONCAT('SELECT TPDURV_RECVER INTO @REC_VER FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE 
					TPDURV_ID=',MIN_TPDURV_ID));
					PREPARE SELECT_REC_VER_STMT FROM @SELECT_REC_VER;
                    EXECUTE SELECT_REC_VER_STMT;
					SET REC_VER=@REC_VER;
					SET @UPDATE_TEMP_PAYMENT_DETAILS=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_SPLIT4 SET CED_REC_VER=(',REC_VER,'-1) WHERE (PD_ID=(',MIN_PDID,'-1) AND PP_ID=1)'));
					PREPARE UPDATE_TEMP_PAYMENT_DETAILS_STMT FROM @UPDATE_TEMP_PAYMENT_DETAILS;
                    EXECUTE UPDATE_TEMP_PAYMENT_DETAILS_STMT;
				END IF;
			END IF;    
			IF(FORPERIOD BETWEEN STARTDATE AND ENDDATE)THEN
				SET @UPDATE_REC_VER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_SPLIT4 SET CED_REC_VER=(SELECT TPDURV_RECVER FROM ',DESTINATIONSCHEMA,'.TEMP_PAYMENT_DETAILS_UPDATE_RECORD_VERSION WHERE 
				TPDURV_ID=',MIN_TPDURV_ID,')WHERE PD_ID=',MIN_PDID));
				PREPARE UPDATE_REC_VER_STMT FROM @UPDATE_REC_VER;
                EXECUTE UPDATE_REC_VER_STMT;
			END IF;
		SET MIN_TPDURV_ID=MIN_TPDURV_ID+1;
		END WHILE;
	SET MIN_PDID=MIN_PDID+1;
	END WHILE;
        SET FOREIGN_KEY_CHECKS=1; 
		SET ENDTIME = (SELECT CURTIME());
	SET DURATION=(SELECT TIMEDIFF(ENDTIME,STARTTIME));	
	DROP TABLE IF EXISTS TEMP_PAYMENT_DETAILS_DURATION4;
	CREATE TABLE TEMP_PAYMENT_DETAILS_DURATION4(ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,PAYMENT_DURATION4 TIME);
	INSERT INTO TEMP_PAYMENT_DETAILS_DURATION4(PAYMENT_DURATION4)VALUES(DURATION);
END;
