DROP PROCEDURE IF EXISTS SP_CHARTS_BIZ_EXPENSE_PERUNIT;
CREATE PROCEDURE SP_CHARTS_BIZ_EXPENSE_PERUNIT(IN UNIT_NO INT, IN FROM_DATE VARCHAR(20), IN TO_DATE VARCHAR(20),IN USERSTAMP VARCHAR(50),OUT MAIN_TEMPTBL_CHARTS_BIZ_EXPENSE_PERUNIT TEXT)
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
DECLARE MAIN_BIZ_EXPENSE_PERUNIT TEXT;
DECLARE INTERMEDIATE_BIZ_EXPENSE_PERUNIT TEXT;
DECLARE INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
 ROLLBACK;
  IF(INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL IS NOT NULL) THEN
  SET @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('DROP TABLE IF EXISTS ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL));
		PREPARE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;
    END IF;
END; 
START TRANSACTION;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);
	SET MAIN_BIZ_EXPENSE_PERUNIT=(SELECT CONCAT('TEMP_CHARTS_BIZ_EXPENSE_PERUNIT',SYSDATE()));
	SET INTERMEDIATE_BIZ_EXPENSE_PERUNIT=(SELECT CONCAT('TEMP_INTERMEDIATE_CHARTS_BIZ',SYSDATE()));
	SET MAIN_BIZ_EXPENSE_PERUNIT=(SELECT REPLACE(MAIN_BIZ_EXPENSE_PERUNIT,' ',''));
	SET MAIN_BIZ_EXPENSE_PERUNIT=(SELECT REPLACE(MAIN_BIZ_EXPENSE_PERUNIT,'-',''));
	SET MAIN_BIZ_EXPENSE_PERUNIT=(SELECT REPLACE(MAIN_BIZ_EXPENSE_PERUNIT,':',''));
	SET MAIN_TEMPTBL_CHARTS_BIZ_EXPENSE_PERUNIT=(SELECT CONCAT(MAIN_BIZ_EXPENSE_PERUNIT,'_',USERSTAMP_ID)); 
	SET INTERMEDIATE_BIZ_EXPENSE_PERUNIT=(SELECT REPLACE(INTERMEDIATE_BIZ_EXPENSE_PERUNIT,' ',''));
	SET INTERMEDIATE_BIZ_EXPENSE_PERUNIT=(SELECT REPLACE(INTERMEDIATE_BIZ_EXPENSE_PERUNIT,'-',''));
	SET INTERMEDIATE_BIZ_EXPENSE_PERUNIT=(SELECT REPLACE(INTERMEDIATE_BIZ_EXPENSE_PERUNIT,':',''));
	SET INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL=(SELECT CONCAT(INTERMEDIATE_BIZ_EXPENSE_PERUNIT,'_',USERSTAMP_ID)); 
  IF (FROM_DATE IS NOT NULL) THEN    
    SET FROM_PERIOD_YEAR    =(SELECT SUBSTRING_INDEX(FROM_DATE,'-',-1));
    SET FROM_PERIOD_MONTH   =(SELECT SUBSTRING(FROM_DATE,1,3));    
    SET FROM_PERIOD_MONTHNO =(select month(str_to_date(FROM_PERIOD_MONTH,'%b')));
    SET FINAL_FROM_DATE = CONCAT(FROM_PERIOD_YEAR,'-',FROM_PERIOD_MONTHNO,'-','01');
  ELSE
    SET FINAL_FROM_DATE   = CURDATE();
    SET FROM_PERIOD_YEAR  = YEAR(CURDATE());
    SET FROM_PERIOD_MONTHNO = MONTH(CURDATE());
  END IF;  
  IF (TO_DATE IS NOT NULL) THEN    
    SET TO_PERIOD_YEAR=(SELECT SUBSTRING_INDEX(TO_DATE,'-',-1));
    SET TO_PERIOD_MONTH=(SELECT SUBSTRING(TO_DATE,1,3));    
    SET TO_PERIOD_MONTHNO=(select month(str_to_date(TO_PERIOD_MONTH,'%b')));
    SET FINAL_TO_DATE = CONCAT(TO_PERIOD_YEAR,'-',TO_PERIOD_MONTHNO,'-','31');
  ELSE
    SET FINAL_TO_DATE = CONCAT(FROM_PERIOD_YEAR,'-',FROM_PERIOD_MONTHNO,'-','31');
  END IF;    
  	SET @CREATE_MAIN_TEMPTBL_CHARTS_BIZ_EXPENSE_PERUNIT=(SELECT CONCAT('CREATE TABLE ',MAIN_TEMPTBL_CHARTS_BIZ_EXPENSE_PERUNIT,'(MONTH_YEAR VARCHAR(20),CAR_PARK DECIMAL(10,2),DIGITAL_VOICE DECIMAL(10,2),ELECTRICITY DECIMAL(10,2),FACILITY_USE DECIMAL(10,2),MOVE_IN_OUT DECIMAL(10,2),STARHUB DECIMAL(10,2),UNIT_EXPENSE DECIMAL(10,2))'));
	PREPARE CREATE_MAIN_TEMPTBL_CHARTS_BIZ_EXPENSE_PERUNIT_STMT FROM @CREATE_MAIN_TEMPTBL_CHARTS_BIZ_EXPENSE_PERUNIT;
	EXECUTE CREATE_MAIN_TEMPTBL_CHARTS_BIZ_EXPENSE_PERUNIT_STMT;   
  	SET @CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('CREATE TABLE ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL,'(MONTH_YEAR VARCHAR(20),CAR_PARK DECIMAL(10,2),DIGITAL_VOICE DECIMAL(10,2),ELECTRICITY DECIMAL(10,2),FACILITY_USE DECIMAL(10,2),MOVE_IN_OUT DECIMAL(10,2),STARHUB DECIMAL(10,2),UNIT_EXPENSE DECIMAL(10,2), DATE DATE)'));
	PREPARE CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ;
	EXECUTE CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT; 	
		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL,' (MONTH_YEAR, CAR_PARK, DATE)SELECT DATE_FORMAT(ECP.ECP_INVOICE_DATE,"%M-%Y"),ECP.ECP_AMOUNT, ECP.ECP_INVOICE_DATE FROM EXPENSE_CARPARK ECP,EXPENSE_DETAIL_CARPARK EDCP,UNIT UN WHERE  ECP.ECP_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"',' AND ECP.EDCP_ID = EDCP.EDCP_ID AND EDCP.UNIT_ID = UN.UNIT_ID AND UN.UNIT_NO = ',UNIT_NO));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;   
		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL,' (MONTH_YEAR, DIGITAL_VOICE, DATE)SELECT DATE_FORMAT(EDV.EDV_INVOICE_DATE,"%M-%Y"),EDV.EDV_AMOUNT, EDV.EDV_INVOICE_DATE FROM EXPENSE_DIGITAL_VOICE EDV,EXPENSE_DETAIL_DIGITAL_VOICE EDDV,UNIT UN WHERE  EDV.EDV_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"',' AND EDV.EDDV_ID = EDDV.EDDV_ID AND EDDV.UNIT_ID = UN.UNIT_ID AND UN.UNIT_NO = ',UNIT_NO));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;
		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL,' (MONTH_YEAR, ELECTRICITY, DATE)SELECT DATE_FORMAT(EE.EE_INVOICE_DATE,"%M-%Y"),EE.EE_AMOUNT, EE.EE_INVOICE_DATE FROM EXPENSE_ELECTRICITY EE,EXPENSE_DETAIL_ELECTRICITY EDE,UNIT UN WHERE  EE.EE_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"',' AND EE.EDE_ID = EDE.EDE_ID AND EDE.UNIT_ID = UN.UNIT_ID AND UN.UNIT_NO = ',UNIT_NO));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;		
		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL,' (MONTH_YEAR, FACILITY_USE, DATE)SELECT DATE_FORMAT(EFU.EFU_INVOICE_DATE,"%M-%Y"),EFU.EFU_AMOUNT, EFU.EFU_INVOICE_DATE FROM EXPENSE_FACILITY_USE EFU,UNIT UN WHERE  EFU.EFU_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"',' AND EFU.UNIT_ID = UN.UNIT_ID AND UN.UNIT_NO = ',UNIT_NO));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;
  		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL,' (MONTH_YEAR, MOVE_IN_OUT, DATE)SELECT DATE_FORMAT(EMIO.EMIO_INVOICE_DATE,"%M-%Y"),EMIO.EMIO_AMOUNT, EMIO.EMIO_INVOICE_DATE FROM EXPENSE_MOVING_IN_AND_OUT EMIO,UNIT UN WHERE  EMIO.EMIO_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"',' AND EMIO.UNIT_ID = UN.UNIT_ID AND UN.UNIT_NO = ',UNIT_NO));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;
	  		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL,' (MONTH_YEAR, STARHUB, DATE)SELECT DATE_FORMAT(ESH.ESH_INVOICE_DATE,"%M-%Y"),ESH.ESH_AMOUNT, ESH.ESH_INVOICE_DATE FROM EXPENSE_STARHUB ESH,EXPENSE_DETAIL_STARHUB EDSH,UNIT UN WHERE  ESH.ESH_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"',' AND ESH.EDSH_ID = EDSH.EDSH_ID AND EDSH.UNIT_ID = UN.UNIT_ID AND UN.UNIT_NO = ',UNIT_NO));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;			
	  		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('INSERT INTO ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL,' (MONTH_YEAR, UNIT_EXPENSE, DATE)SELECT DATE_FORMAT(EU.EU_INVOICE_DATE,"%M-%Y"),EU.EU_AMOUNT, EU.EU_INVOICE_DATE FROM EXPENSE_UNIT EU,UNIT UN WHERE  EU.EU_INVOICE_DATE BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"',' AND EU.UNIT_ID = UN.UNIT_ID AND UN.UNIT_NO = ',UNIT_NO));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT;  
	  SET @INSERT_TEMP_CHARTS_BIZ_EXPENSE_PERUNIT=(SELECT CONCAT('INSERT INTO ',MAIN_TEMPTBL_CHARTS_BIZ_EXPENSE_PERUNIT,' (MONTH_YEAR ,CAR_PARK ,DIGITAL_VOICE ,ELECTRICITY ,FACILITY_USE ,MOVE_IN_OUT ,STARHUB ,UNIT_EXPENSE )(SELECT MONTH_YEAR,SUM(COALESCE(CAR_PARK,'"0"')),SUM(COALESCE(DIGITAL_VOICE,'"0"')), SUM(COALESCE(ELECTRICITY,'"0"')), SUM(COALESCE(FACILITY_USE,'"0"')), SUM(COALESCE(MOVE_IN_OUT,'"0"')), SUM(COALESCE(STARHUB,'"0"')), SUM(COALESCE(UNIT_EXPENSE,'"0"')) FROM ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL,' GROUP BY MONTH_YEAR ORDER BY DATE)'));
		PREPARE INSERT_TEMP_CHARTS_BIZ_EXPENSE_PERUNIT_STMT FROM @INSERT_TEMP_CHARTS_BIZ_EXPENSE_PERUNIT;
		EXECUTE INSERT_TEMP_CHARTS_BIZ_EXPENSE_PERUNIT_STMT;    
    SET @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ=(SELECT CONCAT('DROP TABLE IF EXISTS ',INTERMEDIATE_CHARTS_BIZ_EXPENSE_PERUNIT_TEMPTBL));
		PREPARE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT FROM @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ;
		EXECUTE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_STMT; 
 COMMIT;
END;
