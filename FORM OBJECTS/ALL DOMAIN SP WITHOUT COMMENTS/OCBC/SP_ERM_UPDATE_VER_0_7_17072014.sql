DROP PROCEDURE IF EXISTS SP_ERM_UPDATE;
CREATE PROCEDURE SP_ERM_UPDATE(
IN ERMODATA VARCHAR(40),
IN ERMID INTEGER,
IN CUSTNAME VARCHAR(40),
IN RENT DECIMAL(7,2),
IN MOVINGDATE DATE,
IN MINSTAY VARCHAR(10),
IN NCDATA TEXT,
IN NOOFGUESTS VARCHAR(10),
IN AGE VARCHAR(10),
IN CONTACTNO VARCHAR(20),
IN EMAILID VARCHAR(40),
IN COMMENTS TEXT,
IN USERSTAMP VARCHAR(50),
OUT ERM_SUCCESSFLAG INTEGER)
BEGIN
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
END;
START TRANSACTION;
SET ERM_SUCCESSFLAG=0;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);
IF NOT EXISTS(SELECT ERMO_DATA FROM ERM_OCCUPATION_DETAILS WHERE ERMO_DATA=ERMODATA)THEN
INSERT INTO ERM_OCCUPATION_DETAILS(ERMO_DATA,ULD_ID)VALUES(ERMODATA,USERSTAMP_ID);
SET ERM_SUCCESSFLAG=1;
END IF; 
UPDATE ERM_ENTRY_DETAILS SET ERM_CUST_NAME=CUSTNAME,ERM_RENT=RENT,ERM_MOVING_DATE=MOVINGDATE,
ERM_MIN_STAY=MINSTAY,ERMO_ID=(SELECT ERMO_ID FROM ERM_OCCUPATION_DETAILS WHERE ERMO_DATA=ERMODATA),
NC_ID=(SELECT NC_ID FROM NATIONALITY_CONFIGURATION WHERE NC_DATA=NCDATA),
ERM_NO_OF_GUESTS=NOOFGUESTS,ERM_AGE=AGE,ERM_CONTACT_NO=CONTACTNO,ERM_EMAIL_ID=EMAILID,
ERM_COMMENTS=COMMENTS,ULD_ID=USERSTAMP_ID WHERE ERM_ID=ERMID;
SET ERM_SUCCESSFLAG=1;
COMMIT;
END;