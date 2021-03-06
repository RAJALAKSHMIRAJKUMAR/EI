-- VERSION :0.7 TRACKER: 738, START DATE: 12-06-2014, END DATE: 12-06-2014, DESC: implementing trigger changes for not updating primary key in tickler_history   DONE BY: BHAVANI.R
-- VERSION :0.6, TRACKER: 529, START DATE: 05-06-2014, END DATE: 05-06-2014, DESC: ADDED USERSTAMP AND TIMESTAMP OLD_VALUE IN TICKLER_HISTORY TABLE   DONE BY: DHIVYA.A
-- version 0.5 -- sdate:07/04/2014 -- edate:07/04/2014 -- issue:797-- commentno:#28 -- desc:REPLACED TABLENAME AND HEADERNAME DONE BY:SASIKALA.D
--version:0.4 --sdate:26/02/2014 --edate:26/02/2014 --issue:529 --commentno:132 --done by:RL
-- VERSION 0.3 TRACKER NO: 529, COMMENT:#105 ,START DATE: 10-02-2014, END DATE: 10-02-2014, DESC: added comma after one header value is completed, DONE BY: MANIKANDAN S
-- version 0.2 -- sdate:07/02/2014 -- edate:07/02/2014 -- issue:738 -- commentno:#1 -- desc:ADDED ONE CONDITION FOR NOT CREATING NULL ROW IN TICKLER_HISTORY DONE BY:DHIVYA
-- > version 0.1 -- >date:31/01/2014 -- > desc:trigger updation query for REPORT_CONFIGURATION table  -- done by :rl
-- after update on REPORT_CONFIGURATION table this trigger will be executed
DROP TRIGGER IF EXISTS TRG_REPORT_CONFIGURATION_UPDATE ;
CREATE TRIGGER TRG_REPORT_CONFIGURATION_UPDATE   
AFTER UPDATE ON REPORT_CONFIGURATION
FOR EACH ROW
BEGIN 
-- declaration for old_value and new_value to store it in TICKLER_HISTORY table
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF (OLD.CGN_ID!= NEW.CGN_ID) OR (OLD.RCN_DATA!= NEW.RCN_DATA) OR (OLD.RCN_INITIALIZE_FLAG IS NULL AND NEW.RCN_INITIALIZE_FLAG IS NOT NULL) OR (OLD.RCN_INITIALIZE_FLAG IS NOT NULL AND NEW.RCN_INITIALIZE_FLAG IS NULL) OR (OLD.RCN_INITIALIZE_FLAG!= NEW.RCN_INITIALIZE_FLAG) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'RCN_ID=', OLD.RCN_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for CGN_ID to store it in TICKLER_HISTORY table
IF (OLD.CGN_ID!= NEW.CGN_ID) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'CGN_ID=', OLD.CGN_ID,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'CGN_ID=', NEW.CGN_ID,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for RCN_DATA to store it in TICKLER_HISTORY table
IF (OLD.RCN_DATA!= NEW.RCN_DATA) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'RCN_DATA=', OLD.RCN_DATA,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'RCN_DATA=', NEW.RCN_DATA,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for RCN_INITIALIZE_FLAG to store it in TICKLER_HISTORY table
IF (OLD.RCN_INITIALIZE_FLAG IS NULL AND NEW.RCN_INITIALIZE_FLAG IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'RCN_INITIALIZE_FLAG=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'RCN_INITIALIZE_FLAG=',NEW.RCN_INITIALIZE_FLAG,',');
ELSEIF (OLD.RCN_INITIALIZE_FLAG IS NOT NULL AND NEW.RCN_INITIALIZE_FLAG IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'RCN_INITIALIZE_FLAG=',OLD.RCN_INITIALIZE_FLAG,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'RCN_INITIALIZE_FLAG=','<NULL>,');
ELSEIF (OLD.RCN_INITIALIZE_FLAG!= NEW.RCN_INITIALIZE_FLAG) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'RCN_INITIALIZE_FLAG=', OLD.RCN_INITIALIZE_FLAG,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'RCN_INITIALIZE_FLAG=', NEW.RCN_INITIALIZE_FLAG,','); 
END IF;
IF (OLD.CGN_ID!= NEW.CGN_ID) OR (OLD.RCN_DATA!= NEW.RCN_DATA) OR (OLD.RCN_INITIALIZE_FLAG IS NULL AND NEW.RCN_INITIALIZE_FLAG IS NOT NULL) OR (OLD.RCN_INITIALIZE_FLAG IS NOT NULL AND NEW.RCN_INITIALIZE_FLAG IS NULL) OR (OLD.RCN_INITIALIZE_FLAG!= NEW.RCN_INITIALIZE_FLAG) THEN  
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.RCN_TIMESTAMP!= NEW.RCN_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'RCN_TIMESTAMP=', OLD.RCN_TIMESTAMP,','); 
END IF;
END IF;
-- inserting old_values and new_values in the TICKLER_HISTORY table with their corresponding TTIP_ID in TICKLER_TABID_PROFILE
IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
IF(OLD_VALUE!=NEW_VALUE)THEN

-- REMOVING COMMA(,) AT THE END OF OLD_VALUE & NEW_VALUE
     SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
     SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);

INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM REPORT_CONFIGURATION WHERE RCN_ID=NEW.RCN_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='REPORT_CONFIGURATION'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;



