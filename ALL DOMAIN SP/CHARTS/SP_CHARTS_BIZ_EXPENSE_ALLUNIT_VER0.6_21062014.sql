-- VER 0.6 ISSUE NO:817 COMMENT #139 STARTDATE:21/06/2014 ENDDATE:21/06/2014 DESC:DROPPING TEMP TABLE IF ROLLBACK OCCURS DONE BY:SASIKALA
-- VER 0.5 ISSUE NO:566 COMMENT #12 STARTDATE:09/06/2014 ENDDATE:09/06/2014 DESC: ADDED ROLLBACK AND COMMIT DONE BY:SASIKALA
-- VER 0.4 ISSUE NO:817 COMMENT #35 STARTDATE:06/05/2014 ENDDATE:06/05/2014 DESC: CHANGED TEMP TABLE FOR DYNAMIC PURPOSE DONE BY:BHAVANI.R
-- VER 0.3 ISSUE NO:595 COMMENT #43 STARTDATE:22/01/2014 ENDDATE:22/01/2014 DESC:CHANGED UNIT NO DATA TYPE AS SMALLINT(4) UNSIGNED ZEROFILL. DONE BY:MANIKANDAN.S
-- VER 0.2 ISSUE NO:595 COMMENT #43 STARTDATE:21/01/2014 ENDDATE:21/01/2014 DESC:FILTERED ACTIVE UNIT FOR ALL UNIT. DONE BY:MANIKANDAN.S
-- VER 0.1 ISSUE NO:595 COMMENT #34 STARTDATE:10/01/2014 ENDDATE:10/01/2014 DESC:SP FOR CHARTS BIZ EXPENSE FOR ALL UNIT. DONE BY:MANIKANDAN.S
DROP PROCEDURE IF EXISTS SP_CHARTS_BIZ_EXPENSE_ALLUNIT;
CREATE PROCEDURE SP_CHARTS_BIZ_EXPENSE_ALLUNIT(IN FROM_DATE VARCHAR(20), IN TO_DATE VARCHAR(20),IN USERSTAMP VARCHAR(50),OUT CHARTS_BIZ_EXPENSE_ALLUNIT_TMPTBL TEXT)
BEGIN
DECLARE FROM_PERIOD_YEAR VARCHAR(20);
DECLARE FROM_PERIOD_MONTH VARCHAR(20);
DECLARE FROM_PERIOD_MONTHNO INTEGER;
DECLARE FINAL_FROM_DATE VARCHAR(20);

DECLARE TO_PERIOD_YEAR VARCHAR(20);
DECLARE TO_PERIOD_MONTH VARCHAR(20);
DECLARE TO_PERIOD_MONTHNO INTEGER;
DECLARE FINAL_TO_DATE VARCHAR(20);
DECLARE USERSTAMP_ID INT;
DECLARE TEMP_BIZ_EXPENSE_CHARTS_ALLUNIT TEXT;
DECLARE INTERMEDIATE_CHARTS_BIZ_TEMPTBL TEXT;
DECLARE INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL TEXT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
 ROLLBACK;
  IF(INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL IS NOT NULL) THEN
 SET @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('DROP TABLE IF EXISTS ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL));
		PREPARE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;
  END IF;
END;    
START TRANSACTION;
  --   TEMP TABLE NAME START
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);
	SET TEMP_BIZ_EXPENSE_CHARTS_ALLUNIT=(SELECT CONCAT('TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT',SYSDATE()));
	SET INTERMEDIATE_CHARTS_BIZ_TEMPTBL=(SELECT CONCAT('TEMP_INTERMEDIATE_CHARTS_BIZ',SYSDATE()));
--    NAME FOR MAIN TEMP TABLE
	SET TEMP_BIZ_EXPENSE_CHARTS_ALLUNIT=(SELECT REPLACE(TEMP_BIZ_EXPENSE_CHARTS_ALLUNIT,' ',''));
	SET TEMP_BIZ_EXPENSE_CHARTS_ALLUNIT=(SELECT REPLACE(TEMP_BIZ_EXPENSE_CHARTS_ALLUNIT,'-',''));
	SET TEMP_BIZ_EXPENSE_CHARTS_ALLUNIT=(SELECT REPLACE(TEMP_BIZ_EXPENSE_CHARTS_ALLUNIT,':',''));
	SET CHARTS_BIZ_EXPENSE_ALLUNIT_TMPTBL=(SELECT CONCAT(TEMP_BIZ_EXPENSE_CHARTS_ALLUNIT,'_',USERSTAMP_ID)); 
-- NAME FOR INTERMEDIATE TEMP TABLE
	SET INTERMEDIATE_CHARTS_BIZ_TEMPTBL=(SELECT REPLACE(INTERMEDIATE_CHARTS_BIZ_TEMPTBL,' ',''));
	SET INTERMEDIATE_CHARTS_BIZ_TEMPTBL=(SELECT REPLACE(INTERMEDIATE_CHARTS_BIZ_TEMPTBL,'-',''));
	SET INTERMEDIATE_CHARTS_BIZ_TEMPTBL=(SELECT REPLACE(INTERMEDIATE_CHARTS_BIZ_TEMPTBL,':',''));
	SET INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL=(SELECT CONCAT(INTERMEDIATE_CHARTS_BIZ_TEMPTBL,'_',USERSTAMP_ID));
--   TEMP TABLE NAME END

  IF (FROM_DATE IS NOT NULL) THEN
    
    SET FROM_PERIOD_YEAR    =(SELECT SUBSTRING_INDEX(FROM_DATE,'-',-1));-- SPLIT YEAR FOR PASSING FOR PERIOD
    SET FROM_PERIOD_MONTH   =(SELECT SUBSTRING(FROM_DATE,1,3));
    
    SET FROM_PERIOD_MONTHNO =(select month(str_to_date(FROM_PERIOD_MONTH,'%b')));-- GET MONTHNO FOR PASSING FOR PERIOD

    SET FINAL_FROM_DATE = CONCAT(FROM_PERIOD_YEAR,'-',FROM_PERIOD_MONTHNO,'-','01');
  ELSE
    SET FINAL_FROM_DATE   = CURDATE();
    SET FROM_PERIOD_YEAR  = YEAR(CURDATE());
    SET FROM_PERIOD_MONTHNO = MONTH(CURDATE());
  END IF;
  
  IF (TO_DATE IS NOT NULL) THEN
    
    SET TO_PERIOD_YEAR=(SELECT SUBSTRING_INDEX(TO_DATE,'-',-1));-- SPLIT YEAR FOR PASSING FOR PERIOD
    SET TO_PERIOD_MONTH=(SELECT SUBSTRING(TO_DATE,1,3));
    
    SET TO_PERIOD_MONTHNO=(select month(str_to_date(TO_PERIOD_MONTH,'%b')));-- GET MONTHNO FOR PASSING FOR PERIOD

    SET FINAL_TO_DATE = CONCAT(TO_PERIOD_YEAR,'-',TO_PERIOD_MONTHNO,'-','31');
  ELSE
    SET FINAL_TO_DATE = CONCAT(FROM_PERIOD_YEAR,'-',FROM_PERIOD_MONTHNO,'-','31');
  END IF;
  
  -- CREATING MAIN TEMP TABLE FOR FINAL OUTPUT

	SET @CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT=(SELECT CONCAT('CREATE TABLE ',CHARTS_BIZ_EXPENSE_ALLUNIT_TMPTBL,'(UNIT_NUMBER SMALLINT(4) UNSIGNED ZEROFILL,CAR_PARK DECIMAL(20,2),DIGITAL_VOICE DECIMAL(20,2),ELECTRICITY DECIMAL(20,2),FACILITY_USE DECIMAL(20,2),MOVE_IN_OUT DECIMAL(20,2),STARHUB DECIMAL(20,2),UNIT_EXPENSE DECIMAL(20,2))'));
	PREPARE CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT_STMT FROM @CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT;
	EXECUTE CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT_STMT;  
  
  
  -- CREATING INTERMEDIATE TEMP TABLE 
	SET @CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('CREATE TABLE ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL,'(UNIT_NUMBER SMALLINT(4) UNSIGNED ZEROFILL,CAR_PARK DECIMAL(7,2),DIGITAL_VOICE DECIMAL(7,2),ELECTRICITY DECIMAL(7,2),FACILITY_USE DECIMAL(7,2),MOVE_IN_OUT DECIMAL(7,2),STARHUB DECIMAL(7,2),UNIT_EXPENSE DECIMAL(7,2))'));
	PREPARE CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ;
	EXECUTE CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT; 
	
		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL,' (UNIT_NUMBER, CAR_PARK)SELECT UN.UNIT_NO,ECP.ECP_AMOUNT FROM EXPENSE_CARPARK ECP,EXPENSE_DETAIL_CARPARK EDCP,UNIT UN,UNIT_DETAILS UD WHERE UD.UD_OBSOLETE IS NULL AND UD.UD_NON_EI IS NULL AND UD.UD_END_DATE>CURDATE() AND UD.UNIT_ID=UN.UNIT_ID AND UN.UNIT_ID = EDCP.UNIT_ID AND EDCP.EDCP_ID = ECP.EDCP_ID AND ECP.ECP_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"'));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;

		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL,' (UNIT_NUMBER, DIGITAL_VOICE)SELECT UN.UNIT_NO,EDV.EDV_AMOUNT FROM EXPENSE_DIGITAL_VOICE EDV,EXPENSE_DETAIL_DIGITAL_VOICE EDDV,UNIT UN,UNIT_DETAILS UD WHERE UD.UD_OBSOLETE IS NULL AND UD.UD_NON_EI IS NULL AND UD.UD_END_DATE>CURDATE() AND UD.UNIT_ID=UN.UNIT_ID AND UN.UNIT_ID = EDDV.UNIT_ID AND EDDV.EDDV_ID = EDV.EDDV_ID AND EDV.EDV_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"'));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;
		
		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL,' (UNIT_NUMBER, ELECTRICITY)SELECT UN.UNIT_NO,EE.EE_AMOUNT FROM EXPENSE_ELECTRICITY EE,EXPENSE_DETAIL_ELECTRICITY EDE,UNIT UN ,UNIT_DETAILS UD WHERE UD.UD_OBSOLETE IS NULL AND UD.UD_NON_EI IS NULL AND UD.UD_END_DATE>CURDATE() AND UD.UNIT_ID=UN.UNIT_ID AND UN.UNIT_ID = EDE.UNIT_ID AND EDE.EDE_ID = EE.EDE_ID AND EE.EE_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"'));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;

		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL,' (UNIT_NUMBER, FACILITY_USE)SELECT UN.UNIT_NO,EFU.EFU_AMOUNT FROM EXPENSE_FACILITY_USE EFU,UNIT UN ,UNIT_DETAILS UD WHERE UD.UD_OBSOLETE IS NULL AND UD.UD_NON_EI IS NULL AND UD.UD_END_DATE>CURDATE() AND UD.UNIT_ID=UN.UNIT_ID AND  UN.UNIT_ID = EFU.UNIT_ID AND EFU.EFU_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"'));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;
		
		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL,' (UNIT_NUMBER, MOVE_IN_OUT)SELECT UN.UNIT_NO,EMIO.EMIO_AMOUNT FROM EXPENSE_MOVING_IN_AND_OUT EMIO,UNIT UN ,UNIT_DETAILS UD WHERE UD.UD_OBSOLETE IS NULL AND UD.UD_NON_EI IS NULL AND UD.UD_END_DATE>CURDATE() AND UD.UNIT_ID=UN.UNIT_ID AND  UN.UNIT_ID = EMIO.UNIT_ID AND EMIO.EMIO_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"'));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;

		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL,' (UNIT_NUMBER, STARHUB)SELECT UN.UNIT_NO,ESH.ESH_AMOUNT FROM EXPENSE_STARHUB ESH,EXPENSE_DETAIL_STARHUB EDSH,UNIT UN ,UNIT_DETAILS UD WHERE UD.UD_OBSOLETE IS NULL AND UD.UD_NON_EI IS NULL AND UD.UD_END_DATE>CURDATE() AND UD.UNIT_ID=UN.UNIT_ID AND UN.UNIT_ID = EDSH.UNIT_ID AND EDSH.EDSH_ID = ESH.EDSH_ID AND ESH.ESH_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"'));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;

 		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL,' (UNIT_NUMBER, UNIT_EXPENSE) SELECT UN.UNIT_NO,EU.EU_AMOUNT FROM EXPENSE_UNIT EU,UNIT UN ,UNIT_DETAILS UD WHERE UD.UD_OBSOLETE IS NULL AND UD.UD_NON_EI IS NULL AND UD.UD_END_DATE>CURDATE() AND UD.UNIT_ID=UN.UNIT_ID AND UN.UNIT_ID = EU.UNIT_ID AND EU.EU_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"'));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;


      -- INSERTING INTO FINAL TEMP TABLE GROUPING BY UNIT NUMBER
	  
	    SET @INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT=(SELECT CONCAT('INSERT INTO ',CHARTS_BIZ_EXPENSE_ALLUNIT_TMPTBL,' (UNIT_NUMBER ,CAR_PARK ,DIGITAL_VOICE ,ELECTRICITY ,FACILITY_USE ,MOVE_IN_OUT ,STARHUB ,UNIT_EXPENSE) (SELECT UNIT_NUMBER,SUM(COALESCE(CAR_PARK,'"0"')),SUM(COALESCE(DIGITAL_VOICE,'"0"')), SUM(COALESCE(ELECTRICITY,'"0"')), SUM(COALESCE(FACILITY_USE,'"0"')), SUM(COALESCE(MOVE_IN_OUT,'"0"')), SUM(COALESCE(STARHUB,'"0"')), SUM(COALESCE(UNIT_EXPENSE,'"0"')) FROM ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL,' GROUP BY UNIT_NUMBER ORDER BY UNIT_NUMBER ASC)'));
		PREPARE INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT_STMT FROM @INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT;
		EXECUTE INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT_STMT;

		SET @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('DROP TABLE IF EXISTS ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_TEMPTBL));
		PREPARE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;


 COMMIT;
END;
/* 
  CALL SP_CHARTS_BIZ_EXPENSE_ALLUNIT('January-2011' , 'January-2014','EXPATSINTEGRATED@GMAIL.COM',@CHARTS_BIZ_EXPENSE_ALLUNIT_TMPTBL);
  SELECT @CHARTS_BIZ_EXPENSE_ALLUNIT_TMPTBL;
  SELECT * FROM TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT20140621171314_2;
*/