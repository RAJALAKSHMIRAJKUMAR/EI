-- version:0.1 --sdate:25-06-2014 --edate:25-06-2014 --issue:593 --desc:eclpaiddate,eclfromperiod,ecltoperiod validation --doneby:THIRUPATHI

DROP TRIGGER IF EXISTS TRG_PERSONAL_CAR_LOAN_INSERT_VALIDATION;
CREATE TRIGGER TRG_PERSONAL_CAR_LOAN_INSERT_VALIDATION
BEFORE INSERT ON EXPENSE_CAR_LOAN
FOR EACH ROW
BEGIN
	CALL SP_TRG_PERSONAL_CAR_LOAN_VALIDATION(NEW.ECL_PAID_DATE,NEW.ECL_FROM_PERIOD,NEW.ECL_TO_PERIOD,'INSERT');
END;