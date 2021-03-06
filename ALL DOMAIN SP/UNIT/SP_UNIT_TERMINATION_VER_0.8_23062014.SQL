--version 0.8--sdate:23/06/2014 --edate:23/06/2014 TRACKER NO:817 COMMENT #139 DESC: DROPPING TEMP TABLE IF ROLLBACK OCCURS DONE BY:BHAVANI.R
--version 0.7--sdate:13/06/2014 --edate:14/06/2014 --issue:738 --comment no#33 --desc: UPDATE USERSTAMP AND TIMESTAMP --done by:RL
--version 0.6 --sdate:27/05/2014 --edate:27/05/2014 --issue:346 --comment no#274 --desc: UPDATING COMMENTS IN TICKLER WHILE CHANGING EMPTY INTO UNIT TERMINATION --done by:RL
--version 0.5 --sdate:07/04/2014 --edate:07/04/2014 --issue:797,346 --dsc:changed POSTAP_ID AS TTIP_ID and IN SP_UNIT_TERMINATION,UPDATE COMMENTS ALSO IMPLEMENT THIS WHILE UPDATING OBSOLETE ='X'-doneby:RL
--version 0.4 --sdate:01/03/2014 --edate:01/03/2014 --issue:346---comment:255-doneby:SARADAMBAL
--version 0.3 --sdate:28/02/2014 --edate:28/02/2014 --issue:754 --comment:36 --doneby:RL
--version 0.2 --sdate:27/02/2014 --edate:27/02/2014 --issue:754 --comment:22 --doneby:RL
--version:0.1 --ISSUE NO:346 COMMENT NO:#192 sd:12/02/2014 --enddate:12/02/2014 --desc:SP FOR UNIT TERMINATION  DONE BY:DHIVYA.A

DROP PROCEDURE IF EXISTS SP_UNIT_TERMINATION;
CREATE PROCEDURE SP_UNIT_TERMINATION(
IN UNITNO INTEGER,
IN UNIT_USERSTAMP VARCHAR(50),
IN UNIT_COMMENTS TEXT,
OUT FLAG INTEGER)
BEGIN
	
	DECLARE OBSOLETE CHAR(1);
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE OLDCOMMENTS TEXT;
	DECLARE OLDULDID TEXT;
	DECLARE OLDTIMESTAMP TEXT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK; 
		DROP VIEW IF EXISTS VW_UNIT_TERMINATION;
	END;
	
	START TRANSACTION;
	
	SET OLDULDID = (SELECT ULD_ID FROM UNIT_DETAILS WHERE UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO));
	SET OLDTIMESTAMP = (SELECT UD_TIMESTAMP FROM UNIT_DETAILS WHERE UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO));
	
	SET OBSOLETE=(SELECT UD_OBSOLETE FROM UNIT_DETAILS WHERE UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO));
	IF OBSOLETE=' ' THEN
		SET OBSOLETE=NULL;
	END IF;
	
	IF UNIT_COMMENTS=' ' THEN
		SET UNIT_COMMENTS=NULL;
	END IF;

	CALL SP_CHANGE_USERSTAMP_AS_ULDID(UNIT_USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
	
	SET FLAG=0;
	
	CREATE OR REPLACE VIEW VW_UNIT_TERMINATION AS SELECT * FROM VW_CURRENT_ACTIVE_CUSTOMER WHERE IF(CLP_PRETERMINATE_DATE IS NOT NULL,CLP_PRETERMINATE_DATE>SYSDATE(),CLP_ENDDATE>SYSDATE());

	SET OLDCOMMENTS = (SELECT UD_COMMENTS FROM UNIT_DETAILS WHERE UNIT_ID = (SELECT UNIT_ID FROM UNIT WHERE UNIT_NO = UNITNO));
  

	IF OLDCOMMENTS IS NULL THEN
		SET OLDCOMMENTS = 'null';
	END IF;
	IF UNIT_COMMENTS IS NULL THEN
		SET UNIT_COMMENTS = 'null';
	END IF;

	IF OBSOLETE IS NULL THEN
		
		IF NOT EXISTS(SELECT UNIT_NO FROM VW_UNIT_TERMINATION WHERE UNIT_NO=UNITNO)THEN
			
			IF(OLDCOMMENTS != UNIT_COMMENTS)THEN
			
				IF(OLDULDID != USERSTAMP_ID)THEN
				
					INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
					(1,4,(SELECT CONCAT('UNIT_ID=',(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO),',','UD_OBSOLETE=','null',',','UD_COMMENTS=',OLDCOMMENTS,',','ULD_ID=',OLDULDID,',','UD_TIMESTAMP=',OLDTIMESTAMP)),
					(SELECT CONCAT('UNIT_ID=',(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO),',','UD_OBSOLETE=','X',',','UD_COMMENTS=',UNIT_COMMENTS)),USERSTAMP_ID);
			
				ELSE
				
					INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
					(1,4,(SELECT CONCAT('UNIT_ID=',(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO),',','UD_OBSOLETE=','null',',','UD_COMMENTS=',OLDCOMMENTS,',','UD_TIMESTAMP=',OLDTIMESTAMP)),
					(SELECT CONCAT('UNIT_ID=',(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO),',','UD_OBSOLETE=','X',',','UD_COMMENTS=',UNIT_COMMENTS)),USERSTAMP_ID);
			
				END IF;
			
			ELSE
			
				IF(OLDULDID != USERSTAMP_ID)THEN
				
					INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
					(1,4,(SELECT CONCAT('UNIT_ID=',(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO),',','UD_OBSOLETE=','null',',','ULD_ID=',OLDULDID,',','UD_TIMESTAMP=',OLDTIMESTAMP)),
					(SELECT CONCAT('UNIT_ID=',(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO),',','UD_OBSOLETE=','X')),USERSTAMP_ID);
		
				ELSE
				
					INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
					(1,4,(SELECT CONCAT('UNIT_ID=',(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO),',','UD_OBSOLETE=','null',',','UD_TIMESTAMP=',OLDTIMESTAMP)),
					(SELECT CONCAT('UNIT_ID=',(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO),',','UD_OBSOLETE=','X')),USERSTAMP_ID);
			
				END IF;
			
			END IF;
		-- UPDATE QUERY FOR UNIT_DETAILS
		
			IF(UNIT_COMMENTS='null')THEN
				SET UNIT_COMMENTS=NULL;
			END IF;
		
			UPDATE UNIT_DETAILS SET UD_OBSOLETE='X' , ULD_ID=USERSTAMP_ID,UD_COMMENTS=UNIT_COMMENTS WHERE UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO);
			SET FLAG=1;
	
		END IF;

	END IF;
	
	DROP VIEW IF EXISTS VW_UNIT_TERMINATION;
	
COMMIT;
END;