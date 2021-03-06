DROP PROCEDURE IF EXISTS SP_BIZDLY_HOUSEKEEPING_DURATION_AMOUNT_SRCH;
CREATE PROCEDURE SP_BIZDLY_HOUSEKEEPING_DURATION_AMOUNT_SRCH(
IN EMPLOYEE_ID INTEGER,
IN INPUT_DATE DATE,
IN AMOUNT DECIMAL(7,2),
IN USERSTAMP VARCHAR(50),
OUT HOUSEKEEPING_DURATION_AMOUNT TEXT)
BEGIN
	DECLARE USERSTAMP_ID INTEGER;
	DECLARE SYSDATEANDTIME VARCHAR(50);
	DECLARE SYSDATEANDULDID VARCHAR(50);
	DECLARE INPUT_MONTH INTEGER;
	DECLARE INPUT_YEAR INTEGER;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
  ROLLBACK;
  END;
	SET INPUT_MONTH = (SELECT MONTH(INPUT_DATE));
	SET INPUT_YEAR = (SELECT YEAR(INPUT_DATE));
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);
	SET SYSDATEANDTIME=(SELECT SYSDATE());
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,' ',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,'-',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,':',''));
	SET SYSDATEANDULDID=(SELECT CONCAT(SYSDATEANDTIME,'_',USERSTAMP_ID));	
	SET HOUSEKEEPING_DURATION_AMOUNT=(SELECT CONCAT('TEMP_HOUSEKEEPING_DURATION_AMOUNT','_',SYSDATEANDULDID));
	SET @HKD_AMT_CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',HOUSEKEEPING_DURATION_AMOUNT,' AS 
	(SELECT SUM(EHK_DURATION) AS DURATION,SUM(EHK_DURATION) * ',AMOUNT,' AS AMOUNT FROM EXPENSE_HOUSEKEEPING EHK 
	JOIN  EMPLOYEE_DETAILS ED ON EHK.EMP_ID=ED.EMP_ID AND ED.EMP_ID=',EMPLOYEE_ID,' AND 
	YEAR(EHK.EHK_WORK_DATE)=',INPUT_YEAR,' AND MONTH(EHK.EHK_WORK_DATE)=',INPUT_MONTH,')'));
	PREPARE HKD_AMT_CREATEQUERYSTMT FROM @HKD_AMT_CREATEQUERY;
	EXECUTE HKD_AMT_CREATEQUERYSTMT;
  COMMIT;
END;