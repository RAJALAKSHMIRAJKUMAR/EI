DROP PROCEDURE IF EXISTS SP_CHARTS_BIZ_NET_REVENUE_ALLUNIT;
CREATE PROCEDURE SP_CHARTS_BIZ_NET_REVENUE_ALLUNIT(IN FROM_DATE VARCHAR(20), IN TO_DATE VARCHAR(20),IN USERSTAMP VARCHAR(50),OUT CHARTS_BIZ_NET_REVENUE_ALLUNIT_TEMPTBL TEXT)
BEGIN
DECLARE FINAL_FROM_DATE VARCHAR(20);
DECLARE FINAL_TO_DATE VARCHAR(20);
DECLARE USERSTAMP_ID INT;
DECLARE BIZ_EXPENSE_ALLUNIT1_TMPTBL TEXT;
DECLARE CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL TEXT;
DECLARE CHARTS_BIZ_NET_REVENUE_ALLUNIT TEXT;
DECLARE CHARTS_GROSS_REVEUE_ALLUNIT TEXT;
DECLARE CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL TEXT;
DECLARE CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL TEXT;
DECLARE CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT TEXT;
DECLARE CHARTS_BIZ_EXPENSE_ALLUNIT TEXT;
DECLARE TEMPTBL_UNIT_RENTAL TEXT;
DECLARE TEMP_INTERMEDIATE_BIZ_NET_REVENUE TEXT;
DECLARE TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
 ROLLBACK;
	IF(CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL IS NOT NULL) THEN
		SET @DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL));
		PREPARE DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT FROM @DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1;
		EXECUTE DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT;
	END IF;
    IF(CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL IS NOT NULL) THEN
		SET @DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL));
		PREPARE DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT FROM @DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1;
		EXECUTE DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT;
    END IF;
    IF(CHARTS_BIZ_EXPENSE_ALLUNIT IS NOT NULL) THEN
		SET @DROP_CHARTS_BIZ_EXPENSE_ALLUNIT=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_BIZ_EXPENSE_ALLUNIT));
		PREPARE DROP_CHARTS_BIZ_EXPENSE_ALLUNIT_STMT FROM @DROP_CHARTS_BIZ_EXPENSE_ALLUNIT;
		EXECUTE DROP_CHARTS_BIZ_EXPENSE_ALLUNIT_STMT;
    END IF;
    IF(TEMPTBL_UNIT_RENTAL IS NOT NULL) THEN    
		SET @DROP_TEMPTBL_UNIT_RENTAL=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTBL_UNIT_RENTAL));
		PREPARE DROP_TEMPTBL_UNIT_RENTAL_STMT FROM @DROP_TEMPTBL_UNIT_RENTAL;
		EXECUTE DROP_TEMPTBL_UNIT_RENTAL_STMT;
    END IF;
    IF(CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL IS NOT NULL) THEN
		SET @DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL));
		PREPARE DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT FROM @DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1;
		EXECUTE DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT;
    END IF;
    IF(TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT IS NOT NULL) THEN
		SET @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT));
		PREPARE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT_STMT FROM @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT;
		EXECUTE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT_STMT;
    END IF;
    DROP VIEW IF EXISTS VIEW_BIZ_NET_REVENUE_ALLUNIT;
    DROP VIEW IF EXISTS VIEW_TOTAL_BIZ_EXPENSE;
END;     
 START TRANSACTION; 
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);
	SET BIZ_EXPENSE_ALLUNIT1_TMPTBL=(SELECT CONCAT('TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1',SYSDATE()));
	SET CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT CONCAT('TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT',SYSDATE()));
	SET CHARTS_GROSS_REVEUE_ALLUNIT=(SELECT CONCAT('TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1',SYSDATE()));
	SET CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT=(SELECT CONCAT('TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1',SYSDATE()));
	SET TEMP_INTERMEDIATE_BIZ_NET_REVENUE=(SELECT CONCAT('TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT',SYSDATE()));
	SET BIZ_EXPENSE_ALLUNIT1_TMPTBL=(SELECT REPLACE(BIZ_EXPENSE_ALLUNIT1_TMPTBL,' ',''));
	SET BIZ_EXPENSE_ALLUNIT1_TMPTBL=(SELECT REPLACE(BIZ_EXPENSE_ALLUNIT1_TMPTBL,'-',''));
	SET BIZ_EXPENSE_ALLUNIT1_TMPTBL=(SELECT REPLACE(BIZ_EXPENSE_ALLUNIT1_TMPTBL,':',''));
	SET CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL=(SELECT CONCAT(BIZ_EXPENSE_ALLUNIT1_TMPTBL,'_',USERSTAMP_ID)); 
	SET CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT REPLACE(CHARTS_BIZ_NET_REVENUE_ALLUNIT,' ',''));
	SET CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT REPLACE(CHARTS_BIZ_NET_REVENUE_ALLUNIT,'-',''));
	SET CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT REPLACE(CHARTS_BIZ_NET_REVENUE_ALLUNIT,':',''));
	SET CHARTS_BIZ_NET_REVENUE_ALLUNIT_TEMPTBL=(SELECT CONCAT(CHARTS_BIZ_NET_REVENUE_ALLUNIT,'_',USERSTAMP_ID));
	SET CHARTS_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_GROSS_REVEUE_ALLUNIT,' ',''));
	SET CHARTS_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_GROSS_REVEUE_ALLUNIT,'-',''));
	SET CHARTS_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_GROSS_REVEUE_ALLUNIT,':',''));
	SET CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL=(SELECT CONCAT(CHARTS_GROSS_REVEUE_ALLUNIT,'_',USERSTAMP_ID));
	SET CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT,' ',''));
	SET CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT,'-',''));
	SET CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT,':',''));
	SET CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL=(SELECT CONCAT(CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT,'_',USERSTAMP_ID));
	SET TEMP_INTERMEDIATE_BIZ_NET_REVENUE=(SELECT REPLACE(TEMP_INTERMEDIATE_BIZ_NET_REVENUE,' ',''));
	SET TEMP_INTERMEDIATE_BIZ_NET_REVENUE=(SELECT REPLACE(TEMP_INTERMEDIATE_BIZ_NET_REVENUE,'-',''));
	SET TEMP_INTERMEDIATE_BIZ_NET_REVENUE=(SELECT REPLACE(TEMP_INTERMEDIATE_BIZ_NET_REVENUE,':',''));
	SET TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT=(SELECT CONCAT(TEMP_INTERMEDIATE_BIZ_NET_REVENUE,'_',USERSTAMP_ID));
  CALL SP_FORMAT_DATE(FROM_DATE,TO_DATE,@fd,@td);
  SELECT @fd INTO FINAL_FROM_DATE;
  SELECT @td INTO FINAL_TO_DATE;  
  CALL SP_CHARTS_BIZ_EXPENSE_ALLUNIT(FROM_DATE, TO_DATE,USERSTAMP,@CHARTS_BIZ_EXPENSE_ALLUNIT_TMPTBL);
  SET CHARTS_BIZ_EXPENSE_ALLUNIT=(SELECT @CHARTS_BIZ_EXPENSE_ALLUNIT_TMPTBL); 
	SET @CREATE_VIEW_TOTAL_BIZ_EXPENSE=(SELECT CONCAT('CREATE OR REPLACE VIEW VIEW_TOTAL_BIZ_EXPENSE AS (SELECT UNIT_NUMBER, SUM(COALESCE(CAR_PARK,'"0"'))+SUM(COALESCE(DIGITAL_VOICE,'"0"'))+ SUM(COALESCE(ELECTRICITY,'"0"'))+ SUM(COALESCE(FACILITY_USE,'"0"'))+ SUM(COALESCE(MOVE_IN_OUT,'"0"'))+ SUM(COALESCE(STARHUB,'"0"'))+ SUM(COALESCE(UNIT_EXPENSE,'"0"')) AS TOTAL_BIZ_EXP FROM ',CHARTS_BIZ_EXPENSE_ALLUNIT,' GROUP BY UNIT_NUMBER)'));
	PREPARE CREATE_VIEW_TOTAL_BIZ_EXPENSE_STMT FROM @CREATE_VIEW_TOTAL_BIZ_EXPENSE;
	EXECUTE CREATE_VIEW_TOTAL_BIZ_EXPENSE_STMT;  
	CALL SP_CHARTS_GET_UNIT_RENTAL_ALLUNIT(FINAL_FROM_DATE, FINAL_TO_DATE,USERSTAMP,@TEMPTBL_UNIT_RENTAL_ALLUNIT);
	SET TEMPTBL_UNIT_RENTAL=(SELECT @TEMPTBL_UNIT_RENTAL_ALLUNIT);
    SET @CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1=(SELECT CONCAT('CREATE TABLE ',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL,'(ID INT NOT NULL AUTO_INCREMENT,UNIT_NUMBER SMALLINT(4) UNSIGNED ZEROFILL,TOTAL_BIZ_EXP DECIMAL(10,2),PRIMARY KEY(ID))'));
	PREPARE CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT FROM @CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1;
	EXECUTE CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT;  
	SET @INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1=(SELECT CONCAT('INSERT INTO ',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL,' (UNIT_NUMBER , TOTAL_BIZ_EXP)SELECT UD.UNIT_NO , IFNULL(TB.TOTAL_BIZ_EXP,0) + IFNULL(UD.UD_PAYMENT, 0) FROM ',TEMPTBL_UNIT_RENTAL,' UD LEFT JOIN VIEW_TOTAL_BIZ_EXPENSE TB ON UD.UNIT_NO = TB.UNIT_NUMBER'));
	PREPARE INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT FROM @INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1;
	EXECUTE INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT;  
    SET @CREATE_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1=(SELECT CONCAT('CREATE TABLE ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL,'(ID INT NOT NULL AUTO_INCREMENT, UNIT_NUMBER SMALLINT(4) UNSIGNED ZEROFILL,GROSS_REVENUE DECIMAL(10,2), PRIMARY KEY (ID))'));
	PREPARE CREATE_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT FROM @CREATE_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1;
	EXECUTE CREATE_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT;	
    SET @CREATE_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1=(SELECT CONCAT('CREATE TABLE ',CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL,'(UNIT_NUMBER SMALLINT(4) UNSIGNED ZEROFILL,GROSS_REVENUE DECIMAL(10,2))'));
	PREPARE CREATE_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT FROM @CREATE_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1;
	EXECUTE CREATE_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT;	
   	SET @INSERT_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1=(SELECT CONCAT('INSERT INTO ',CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL,' (UNIT_NUMBER, GROSS_REVENUE )SELECT UN.UNIT_NO,PD.PD_AMOUNT FROM PAYMENT_DETAILS PD,UNIT UN ,UNIT_DETAILS UD WHERE UD.UD_OBSOLETE IS NULL AND UD.UD_NON_EI IS NULL AND UD.UD_END_DATE>CURDATE() AND UD.UNIT_ID=UN.UNIT_ID AND UN.UNIT_ID = PD.UNIT_ID AND PD.PD_FOR_PERIOD BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"'));
	PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1;
	EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT; 
    SET @INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1=(SELECT CONCAT('INSERT INTO ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL,' (UNIT_NUMBER , GROSS_REVENUE)(SELECT UNIT_NUMBER,SUM(COALESCE(GROSS_REVENUE,'"0"')) FROM ',CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL,' GROUP BY UNIT_NUMBER ORDER BY UNIT_NUMBER ASC)'));
	PREPARE INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT FROM @INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1;
	EXECUTE INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT;  
   	SET @VW_BIZ_NET_REVENUE_ALLUNIT=(SELECT CONCAT('CREATE OR REPLACE VIEW VIEW_BIZ_NET_REVENUE_ALLUNIT AS
    SELECT t1.UNIT_NUMBER, (t1.GROSS_REVENUE-ifnull(t2.TOTAL_BIZ_EXP,0)) AS REVENUE FROM ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL,' t1
    LEFT JOIN ',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL,' t2 ON t1.UNIT_NUMBER = t2.UNIT_NUMBER
    UNION
    SELECT t2.UNIT_NUMBER, (ifnull(t1.GROSS_REVENUE,0)-t2.TOTAL_BIZ_EXP) AS REVENUE FROM ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL,' t1
    RIGHT JOIN ',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL,' t2 ON t1.UNIT_NUMBER = t2.UNIT_NUMBER'));
	PREPARE CREATE_VW_BIZ_NET_REVENUE_ALLUNIT_STMT FROM @VW_BIZ_NET_REVENUE_ALLUNIT;
	EXECUTE CREATE_VW_BIZ_NET_REVENUE_ALLUNIT_STMT;  
	SET @CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT=(SELECT CONCAT('CREATE TABLE ',TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT,'(UNITNUMBER SMALLINT(4) UNSIGNED ZEROFILL,GROSSREVENUE DECIMAL(10,2), TOTALRENTAL_BIZ DECIMAL(10,2), NETREVENUE DECIMAL(10,2), UNITRENTAL DECIMAL(10,2), TOTALBIZ DECIMAL(10,2),GROSSID INTEGER)'));
	PREPARE CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT_STMT FROM @CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT;
	EXECUTE CREATE_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT_STMT;
    SET @INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT CONCAT('INSERT INTO ',TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT,' (UNITNUMBER,TOTALRENTAL_BIZ,NETREVENUE,UNITRENTAL,TOTALBIZ,GROSSID) SELECT A.UNIT_NUMBER,C.TOTAL_BIZ_EXP,D.REVENUE,E.UD_PAYMENT,F.TOTAL_BIZ_EXP,C.ID FROM VIEW_BIZ_NET_REVENUE_ALLUNIT A,',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL,' C,VIEW_BIZ_NET_REVENUE_ALLUNIT D ,',TEMPTBL_UNIT_RENTAL,' E,VIEW_TOTAL_BIZ_EXPENSE F WHERE  A.UNIT_NUMBER=C.UNIT_NUMBER AND A.UNIT_NUMBER=D.UNIT_NUMBER AND A.UNIT_NUMBER=E.UNIT_NO AND A.UNIT_NUMBER=F.UNIT_NUMBER'));
	PREPARE INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT_STMT FROM @INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT;
	EXECUTE INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT_STMT;
    SET @INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT CONCAT('INSERT INTO ',TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT,' (UNITNUMBER,GROSSREVENUE,GROSSID) SELECT UNIT_NUMBER,GROSS_REVENUE,ID FROM ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL));
	PREPARE INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT_STMT FROM @INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT;
	EXECUTE INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT_STMT;  
	SET @CREATE_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT CONCAT('CREATE TABLE ',CHARTS_BIZ_NET_REVENUE_ALLUNIT_TEMPTBL,'(UNIT_NUMBER SMALLINT(4) UNSIGNED ZEROFILL,GROSS_REVENUE DECIMAL(10,2), TOTAL_RENTAL_BIZ DECIMAL(10,2), REVENUE DECIMAL(10,2), UNIT_RENTAL DECIMAL(10,2), TOTAL_BIZ DECIMAL(10,2))'));
	PREPARE CREATE_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT_STMT FROM @CREATE_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT;
	EXECUTE CREATE_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT_STMT;
        SET @INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT CONCAT('INSERT INTO ',CHARTS_BIZ_NET_REVENUE_ALLUNIT_TEMPTBL,' (UNIT_NUMBER,GROSS_REVENUE,TOTAL_RENTAL_BIZ,REVENUE,UNIT_RENTAL,TOTAL_BIZ) SELECT UNITNUMBER,IFNULL(SUM(GROSSREVENUE),0),IFNULL(SUM(TOTALRENTAL_BIZ),0),IFNULL(SUM(NETREVENUE),0),IFNULL(SUM(UNITRENTAL),0),IFNULL(SUM(TOTALBIZ),0) FROM ',TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT,' GROUP BY UNITNUMBER ORDER BY UNITNUMBER ASC'));
		PREPARE INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT_STMT FROM @INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT;
		EXECUTE INSERT_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT_STMT;
		SET @DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL));
		PREPARE DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT FROM @DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1;
		EXECUTE DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT;		
		SET @DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL));
		PREPARE DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT FROM @DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1;
		EXECUTE DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT;    
    SET @DROP_CHARTS_BIZ_EXPENSE_ALLUNIT=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_BIZ_EXPENSE_ALLUNIT));
    PREPARE DROP_CHARTS_BIZ_EXPENSE_ALLUNIT_STMT FROM @DROP_CHARTS_BIZ_EXPENSE_ALLUNIT;
    EXECUTE DROP_CHARTS_BIZ_EXPENSE_ALLUNIT_STMT;    
    SET @DROP_TEMPTBL_UNIT_RENTAL=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTBL_UNIT_RENTAL));
    PREPARE DROP_TEMPTBL_UNIT_RENTAL_STMT FROM @DROP_TEMPTBL_UNIT_RENTAL;
    EXECUTE DROP_TEMPTBL_UNIT_RENTAL_STMT;    
		SET @DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL));
		PREPARE DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT FROM @DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1;
		EXECUTE DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT;    
		SET @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT));
		PREPARE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT_STMT FROM @DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT;
		EXECUTE DROP_TEMP_INTERMEDIATE_CHARTS_BIZ_NET_REVEUE_ALLUNIT_STMT;    
    DROP VIEW IF EXISTS VIEW_BIZ_NET_REVENUE_ALLUNIT;    
    DROP VIEW IF EXISTS VIEW_TOTAL_BIZ_EXPENSE;    
 COMMIT;
END;
