-- VER 0.2 ISSUE NO:593  STARTDATE:26/06/2014 ENDDATE:26/06/2014 DESC:CHANGING THE TRIGGER NAME DONE BY:SASIKALA
-- VER 0.1 ISSUE NO:593  STARTDATE:24/06/2014 ENDDATE:25/06/2014 DESC:TRIGGER FOR CALLING SP ON THROWING ERROR MESSAGE FOR CHEQUE AMOUNT MORE THAN 5 DIGITS DONE BY:SASIKALA

DROP TRIGGER IF EXISTS TRG_CHEQUE_ENTRY_DETAILS_UPDATE_VALIDATION;
CREATE TRIGGER TRG_CHEQUE_ENTRY_DETAILS_UPDATE_VALIDATION
BEFORE UPDATE ON CHEQUE_ENTRY_DETAILS
FOR EACH ROW
BEGIN
    CALL SP_TRG_CHEQUE_ENTRY_DETAILS_VALIDATION(NEW.CHEQUE_AMOUNT,'UPDATE');
END;