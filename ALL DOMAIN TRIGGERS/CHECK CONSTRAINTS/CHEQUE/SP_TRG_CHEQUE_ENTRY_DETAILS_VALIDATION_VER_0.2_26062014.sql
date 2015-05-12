-- VER 0.2 ISSUE NO:593  STARTDATE:26/06/2014 ENDDATE:26/06/2014 DESC:CHANGING THE SP NAME DONE BY:SASIKALA
-- VER 0.1 ISSUE NO:593  STARTDATE:24/06/2014 ENDDATE:25/06/2014 DESC:THROWING ERROR MESSAGE FOR CHEQUE AMOUNT MORE THAN 5 DIGITS DONE BY:SASIKALA

DROP PROCEDURE IF EXISTS SP_TRG_CHEQUE_ENTRY_DETAILS_VALIDATION;
CREATE PROCEDURE SP_TRG_CHEQUE_ENTRY_DETAILS_VALIDATION(
IN CHKAMT INTEGER(20),
IN PROCESS TEXT)
BEGIN
DECLARE MESSAGE_TEXT VARCHAR(50);
    IF(PROCESS = 'INSERT') OR (PROCESS='UPDATE') THEN
        IF CHKAMT IS NOT NULL THEN
    -- FINDING SUBSTRING INDEX FOR CHEQUE AMOUNT
        SET @CHK_AMT=(SELECT SUBSTRING_INDEX(CHKAMT, '.', 1));
        -- CHECKING THE LENGTH OF THE AMOUNT
            IF(LENGTH(@CHK_AMT) > 5) THEN
                SIGNAL SQLSTATE '45000'
                -- THROWING ERROR MESSAGE
                SET MESSAGE_TEXT = 'CHEQUE_AMOUNT SHOULD BE LESS THAN OR EQUAL TO 5 DIGITS !!!';
            END IF;
        END IF;
    END IF;
END;
 