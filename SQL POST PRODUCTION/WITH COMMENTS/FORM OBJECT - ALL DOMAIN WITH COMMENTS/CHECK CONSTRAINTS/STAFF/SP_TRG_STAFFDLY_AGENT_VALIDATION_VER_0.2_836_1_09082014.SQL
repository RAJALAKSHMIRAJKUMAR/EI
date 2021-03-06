-- version:0.2 --sdate:09/08/2014 --edate:09/08/2014 --issue:836 --desc:error msg getting from config db --doneby:RL
-- version:0.1 --sdate:20-06-2014 --edate:20-06-2014 --issue:593 --commentno#75 --desc:invoice date validation --doneby:RL

DROP PROCEDURE IF EXISTS SP_TRG_STAFFDLY_AGENT_VALIDATION;
CREATE PROCEDURE SP_TRG_STAFFDLY_AGENT_VALIDATION(
IN AGENTDATE DATE,
IN PROCESS TEXT)
BEGIN
	DECLARE MESSAGE_TEXT VARCHAR(50);
	DECLARE ERROR_MSG TEXT;
	IF(PROCESS = 'INSERT') OR (PROCESS = 'UPDATE') THEN
		IF(AGENTDATE > CURDATE()) THEN
			SET ERROR_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 516);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = ERROR_MSG;
		END IF;
	END IF;
END;