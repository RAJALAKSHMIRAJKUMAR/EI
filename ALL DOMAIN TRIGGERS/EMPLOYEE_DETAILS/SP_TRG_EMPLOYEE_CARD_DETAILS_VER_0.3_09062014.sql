-- -- version 0.3 -- startdate:09/06/2014 -- endate:09/06/2014 --  ADDED ROLLBACK AND COMMIT-- -desc:SP FOR SP_TRG_EMPLOYEE_CARD_DETAILS - comment #12 -doneby:SASIKALA
-- -- version 0.2 -- startdate:05/12/2013 -- endate:05/12/2013 --  CHANGED ERROR MEESAGE( DECLARE MESSAGE TEXT AND PASSING ERROR MESSAE TO THIS VARIABLE)-- -desc:SP FOR SP_TRG_EMPLOYEE_CARD_DETAILS - comment #21 -doneby:dinesh
-- -- version 0.1 -- startdate:02/12/2013 -- endate:02/12/2013 -- desc:SP FOR SP_TRG_EMPLOYEE_CARD_DETAILS -- doneby:dinesh
DROP PROCEDURE IF EXISTS SP_TRG_EMPLOYEE_CARD_DETAILS;
CREATE PROCEDURE SP_TRG_EMPLOYEE_CARD_DETAILS
( 
IN UASDID INTEGER,
IN CARD VARCHAR(10)
)
BEGIN
DECLARE MESSAGE_TEXT VARCHAR(100);
--  passing ERROR message before INSERT UASD_ID from EMPLOYEE_CARD_DETAILS TABLE
 IF(CARD='INSERT') THEN
    IF EXISTS (SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=UASDID) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT= 'CAN NOT UPDATE UASD_ID ';
    END IF;
 END IF;
--  passing ERROR message before UPDATE UASD_ID and URTD_ID  from EMPLOYEE_CARD_DETAILS TABLE
 IF(CARD='UPDATE') THEN
    IF EXISTS (SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=UASDID) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT= 'CAN NOT UPDATE UASD_ID ';
    END IF;
 END IF;
 END;