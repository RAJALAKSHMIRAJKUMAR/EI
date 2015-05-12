-- VER 0.2 TRACKER NO:566 COMMENT #12 STARTDATE:09/06/2014 ENDDATE:09/06/2014 DONE BY:SASIKALA

-- VER 0.1 TRACKER NO:595 COMMENT #39 STARTDATE:27/01/2014 ENDDATE:27/01/2014 DONE BY:MANIKANDAN.S
/* This procedure is Sub procedure called in another SP. This procedure is used to format the date. If the input is January-2012 then it will give the output as 2012-01-01*/
DROP PROCEDURE IF EXISTS SP_FORMAT_DATE;
CREATE PROCEDURE SP_FORMAT_DATE(IN FROM_DATE VARCHAR(20), IN TO_DATE VARCHAR(20), OUT FINAL_FROM_DATE VARCHAR(20), OUT FINAL_TO_DATE VARCHAR(20))
BEGIN
DECLARE FROM_PERIOD_YEAR VARCHAR(20);
DECLARE FROM_PERIOD_MONTH VARCHAR(20);
DECLARE FROM_PERIOD_MONTHNO INTEGER;

DECLARE TO_PERIOD_YEAR VARCHAR(20);
DECLARE TO_PERIOD_MONTH VARCHAR(20);
DECLARE TO_PERIOD_MONTHNO INTEGER;

DECLARE LAST_DAY_OF_MONTH VARCHAR(10);

DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN
  ROLLBACK;
 END; 
 START TRANSACTION;
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
    
    SET TO_PERIOD_MONTHNO =(select month(str_to_date(TO_PERIOD_MONTH,'%b')));-- GET MONTHNO FOR PASSING FOR PERIOD
    
    SET FINAL_TO_DATE = (SELECT DATE_FORMAT(LAST_DAY(CONCAT(TO_PERIOD_YEAR,'-',TO_PERIOD_MONTHNO,'-','01')), '%Y-%m-%d'));
    
  ELSE
    SET FINAL_TO_DATE = (SELECT DATE_FORMAT(LAST_DAY(FINAL_FROM_DATE), '%Y-%m-%d'));
  END IF;
  COMMIT;
END;
/*
CALL SP_FORMAT_DATE('Janurary-2013',null,@fd,@td);
select @fd;
select @td;
*/