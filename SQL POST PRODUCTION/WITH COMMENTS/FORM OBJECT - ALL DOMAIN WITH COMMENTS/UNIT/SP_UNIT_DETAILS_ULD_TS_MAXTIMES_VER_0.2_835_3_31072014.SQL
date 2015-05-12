-- version 0.2 --sadte:31/07/2014 --edate:31/07/2014 --issue:835 --commentno:3 --desc:implementing auto commit n removed rollback ,commit -- doneby:RL
-- version:0.1 --sdate:11/07/2014 --edate:11/07/2014 --issue:346 --commentno#308 --desc: sub sp for increment no of times and updated uld_id in unit_details if any data changed in other tables(unit,unit_account_dtls) --done by:RL

DROP PROCEDURE IF EXISTS SP_UNIT_DETAILS_ULD_TS_MAXTIMES;
CREATE PROCEDURE SP_UNIT_DETAILS_ULD_TS_MAXTIMES(IN UNIT_NUMBER_ID INTEGER,USER_ULDID INTEGER)
BEGIN
	DECLARE ULDTSMAXTIMES INTEGER;
	SET ULDTSMAXTIMES = (SELECT ULD_TS_MAXTIMES FROM UNIT_DETAILS WHERE UNIT_ID = UNIT_NUMBER_ID);
	UPDATE UNIT_DETAILS SET ULD_TS_MAXTIMES = (ULDTSMAXTIMES+1),ULD_ID = USER_ULDID WHERE UNIT_ID = UNIT_NUMBER_ID;
END;