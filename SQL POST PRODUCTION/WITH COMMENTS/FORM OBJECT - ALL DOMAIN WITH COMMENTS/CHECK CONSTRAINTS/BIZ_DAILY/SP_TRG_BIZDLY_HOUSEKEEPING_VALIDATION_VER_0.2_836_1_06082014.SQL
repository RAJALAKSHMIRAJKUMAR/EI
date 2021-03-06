-- version:0.2 --sdate:06/08/2014 --edate:06/08/2014 --issue:836  --desc:GETTING ERROR MSG FROM CONFIG TABLE --doneby:SASIKALA
-- version:0.1 --sdate:03/07/2014 --edate:03/07/2014 --issue:593 --comment no#167 --desc:workdate & duration validation --doneby:RL

DROP PROCEDURE IF EXISTS SP_TRG_BIZDLY_HOUSEKEEPING_VALIDATION;
CREATE PROCEDURE SP_TRG_BIZDLY_HOUSEKEEPING_VALIDATION(
IN WORKDATE DATE,
IN DURATION DECIMAL(4,2),
IN PROCESS TEXT)
BEGIN
	DECLARE MESSAGE_TEXT VARCHAR(50);
	DECLARE DURATIONHOUR INTEGER;
	DECLARE DURATIONMIN INTEGER;
  DECLARE ERRORMSG TEXT;
 
	SET DURATIONHOUR = (SELECT SUBSTRING_INDEX(DURATION, '.',1));
	SET DURATIONMIN = (SELECT SUBSTRING_INDEX(DURATION, '.',-1));
	IF(PROCESS = 'INSERT') OR (PROCESS = 'UPDATE')THEN
		IF(WORKDATE > CURDATE())THEN
    SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=516);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = ERRORMSG;
		END IF;
		IF(DURATIONHOUR > 24)THEN
       SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=245);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = ERRORMSG;
		END IF;
		IF(DURATIONMIN >= 60)THEN
     SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=246);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = ERRORMSG;
		END IF;
		IF(DURATIONHOUR = 24 AND DURATIONMIN!=00)THEN
     SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=539);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = ERRORMSG;
		END IF;
	END IF;
END;