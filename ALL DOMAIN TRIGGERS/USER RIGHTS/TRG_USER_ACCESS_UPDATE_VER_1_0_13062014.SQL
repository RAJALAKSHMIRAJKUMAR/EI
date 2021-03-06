-- VERSION 1.0 TRACKER NO: 738, COMMENT:24 ,START DATE: 13-06-2014, END DATE: 13-06-2014, IMPLEMENTING TRIGGER CHANGES FOR NOT UPDATING ULD_ID AND TIMESTAMP IN TICKLER_HISTORY, DONE BY: SASIKALA
-- VERSION 0.9 TRACKER NO: 738, COMMENT:18 ,START DATE: 12-06-2014, END DATE: 12-06-2014, IMPLEMENTING TRIGGER CHANGES FOR NOT UPDATING PRIMARY KEY IN TICKLER_HISTORY, DONE BY: SASIKALA
-- VERSION 0.8 TRACKER NO: 529, COMMENT:196 ,START DATE: 05-06-2014, END DATE: 05-06-2014, ADDEDD OLD USERSTAMP,TIMESTAMP IN OLD TICKLER VALUE AND UPDATED NEW ULD ID IN NEW VALUE, DONE BY: SAFI.M
-- VERSION 0.7 TRACKER NO: 797, COMMENT:#28 ,START DATE: 07-04-2014, END DATE: 07-04-2014, DESC: REPLACED TABLENAME AND HEADERNAME DONE BY:SASIKALA.D
-- version:0.6 --sdate:26/02/2014 --edate:26/02/2014 --issue:529 --commentno:132 --done by:RL
-- VERSION 0.5 TRACKER NO: 529, COMMENT:#105 ,START DATE: 10-02-2014, END DATE: 10-02-2014, DESC: added comma after one header value is completed, DONE BY: MANIKANDAN S
--  version -- > 0.4 -- >issue tracker no :522 startdate:04/02/2014 enddate:04/02/2014  description -- > Added OLD_VALUE != NEW_VALUE condition -- doneby: rl
--  version -- > 0.3 -- >issue tracker no :636 comment no:#47 startdate:08/11/2013 enddate:08/11/2013 description -- > changed trigger name by rl
-- version 0.2 -- >start date:09/10/2013 end date:10/10/2013-- >issueno:636 -- >desc:changed variable name O as old_value and N as new_value and added comments
-- >doneby:dhivya
-- > version 0.1 -- >date:19/08/2013 -- >issueno:529 -- >commentno:35 -- >desc:trigger updation query for USER_ACCESS table-- >doneby:dhivya.A

-- after update on USER_ACCESS table this trigger will be executed
DROP TRIGGER IF EXISTS TRG_USER_ACCESS_UPDATE;
CREATE TRIGGER TRG_USER_ACCESS_UPDATE  
AFTER UPDATE ON USER_ACCESS
FOR EACH ROW
BEGIN 
-- declaration for old_value and new_value to store it in TICKLER_HISTORY table
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
DECLARE UAUSERSTAMP VARCHAR(50);
DECLARE ULDID INTEGER(2);
IF ((OLD.RC_ID!= NEW.RC_ID) OR (OLD.UA_REC_VER IS NULL AND NEW.UA_REC_VER IS NOT NULL) OR (OLD.UA_JOIN_DATE!= NEW.UA_JOIN_DATE) OR (OLD.UA_JOIN IS NULL AND NEW.UA_JOIN IS NOT NULL) OR(OLD.UA_JOIN IS NOT NULL AND NEW.UA_JOIN IS NULL) OR (OLD.UA_JOIN!= NEW.UA_JOIN) OR
(OLD.UA_END_DATE IS NULL AND NEW.UA_END_DATE IS NOT NULL) OR (OLD.UA_END_DATE IS NOT NULL AND NEW.UA_END_DATE IS NULL) OR (OLD.UA_END_DATE!= NEW.UA_END_DATE) OR  (OLD.UA_TERMINATE IS NULL AND NEW.UA_TERMINATE IS NOT NULL) OR (OLD.UA_TERMINATE IS NOT NULL AND NEW.UA_TERMINATE IS NULL) OR (OLD.UA_TERMINATE!= NEW.UA_TERMINATE) OR
(OLD.UA_REASON IS NULL AND NEW.UA_REASON IS NOT NULL) OR (OLD.UA_REASON IS NOT NULL AND NEW.UA_REASON IS NULL) OR (OLD.UA_REASON!= NEW.UA_REASON)) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'UA_ID=', OLD.UA_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for RC_ID to store it in TICKLER_HISTORY table
IF (OLD.RC_ID!= NEW.RC_ID) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'RC_ID=', OLD.RC_ID,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'RC_ID=', NEW.RC_ID,',');
END IF;
-- get the OLD VALUE & NEW_VALUE for UA_REC_VER to store it in TICKLER_HISTORY table
IF (OLD.UA_REC_VER!= NEW.UA_REC_VER) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'UA_REC_VER=', OLD.UA_REC_VER,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'UA_REC_VER=', NEW.UA_REC_VER,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for UA_JOIN_DATE to store it in TICKLER_HISTORY table
IF (OLD.UA_JOIN_DATE!= NEW.UA_JOIN_DATE) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'UA_JOIN_DATE=', OLD.UA_JOIN_DATE,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'UA_JOIN_DATE=', NEW.UA_JOIN_DATE,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for UA_JOIN to store it in TICKLER_HISTORY table
IF (OLD.UA_JOIN IS NULL AND NEW.UA_JOIN IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'UA_JOIN=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'UA_JOIN=',NEW.UA_JOIN,',');
ELSEIF (OLD.UA_JOIN IS NOT NULL AND NEW.UA_JOIN IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'UA_JOIN=',OLD.UA_JOIN,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'UA_JOIN=','<NULL>,');
ELSEIF (OLD.UA_JOIN!= NEW.UA_JOIN) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'UA_JOIN=', OLD.UA_JOIN,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'UA_JOIN=', NEW.UA_JOIN,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for UA_END_DATE to store it in TICKLER_HISTORY table
IF (OLD.UA_END_DATE IS NULL AND NEW.UA_END_DATE IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'UA_END_DATE=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'UA_END_DATE=',NEW.UA_END_DATE,',');
ELSEIF (OLD.UA_END_DATE IS NOT NULL AND NEW.UA_END_DATE IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'UA_END_DATE=',OLD.UA_END_DATE,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'UA_END_DATE=','<NULL>,');
ELSEIF (OLD.UA_END_DATE!= NEW.UA_END_DATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'UA_END_DATE=', OLD.UA_END_DATE,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'UA_END_DATE=', NEW.UA_END_DATE,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for UA_TERMINATE to store it in TICKLER_HISTORY table
IF (OLD.UA_TERMINATE IS NULL AND NEW.UA_TERMINATE IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'UA_TERMINATE=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'UA_TERMINATE=',NEW.UA_TERMINATE,',');
ELSEIF(OLD.UA_TERMINATE IS NOT NULL AND NEW.UA_TERMINATE IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'UA_TERMINATE=',OLD.UA_TERMINATE,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'UA_TERMINATE=','<NULL>,');
ELSEIF (OLD.UA_TERMINATE!= NEW.UA_TERMINATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'UA_TERMINATE=', OLD.	UA_TERMINATE,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'UA_TERMINATE=', NEW.UA_TERMINATE,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for UA_REASON to store it in TICKLER_HISTORY table
IF (OLD.UA_REASON IS NULL AND NEW.UA_REASON IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'UA_REASON=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'UA_REASON=',NEW.UA_REASON,',');
ELSEIF(OLD.UA_REASON IS NOT NULL AND NEW.UA_REASON IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'UA_REASON=',OLD.UA_REASON,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'UA_REASON=','<NULL>,');
ELSEIF (OLD.UA_REASON!= NEW.UA_REASON) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'UA_REASON=', OLD.UA_REASON,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'UA_REASON=', NEW.UA_REASON,','); 
END IF;
IF ((OLD.RC_ID!= NEW.RC_ID) OR (OLD.UA_REC_VER IS NULL AND NEW.UA_REC_VER IS NOT NULL) OR (OLD.UA_JOIN_DATE!= NEW.UA_JOIN_DATE) OR (OLD.UA_JOIN IS NULL AND NEW.UA_JOIN IS NOT NULL) OR(OLD.UA_JOIN IS NOT NULL AND NEW.UA_JOIN IS NULL) OR (OLD.UA_JOIN!= NEW.UA_JOIN) OR
(OLD.UA_END_DATE IS NULL AND NEW.UA_END_DATE IS NOT NULL) OR (OLD.UA_END_DATE IS NOT NULL AND NEW.UA_END_DATE IS NULL) OR (OLD.UA_END_DATE!= NEW.UA_END_DATE) OR  (OLD.UA_TERMINATE IS NULL AND NEW.UA_TERMINATE IS NOT NULL) OR (OLD.UA_TERMINATE IS NOT NULL AND NEW.UA_TERMINATE IS NULL) OR (OLD.UA_TERMINATE!= NEW.UA_TERMINATE) OR
(OLD.UA_REASON IS NULL AND NEW.UA_REASON IS NOT NULL) OR (OLD.UA_REASON IS NOT NULL AND NEW.UA_REASON IS NULL) OR (OLD.UA_REASON!= NEW.UA_REASON)) THEN  
-- get the OLD VALUE & NEW_VALUE for ULD_ID to store it in TICKLER_HISTORY table
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'ULD_ID=', NEW.ULD_ID,','); 
END IF;
IF (OLD.UA_USERSTAMP!= NEW.UA_USERSTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'UA_USERSTAMP=', OLD.UA_USERSTAMP,','); 
END IF;
IF (OLD.UA_TIMESTAMP!= NEW.UA_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'UA_TIMESTAMP=', OLD.UA_TIMESTAMP,','); 
END IF;
END IF;
-- inserting old_values and new_values in the TICKLER_HISTORY table with their corresponding TTIP_ID in TICKLER_TABID_PROFILE
IF (OLD_VALUE !='' AND NEW_VALUE!='') THEN
IF (OLD_VALUE != NEW_VALUE)THEN

-- REMOVING COMMA(,) AT THE END OF OLD_VALUE & NEW_VALUE
     SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
     SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
	 SET UAUSERSTAMP = (SELECT UA_USERSTAMP FROM USER_ACCESS WHERE UA_ID=NEW.UA_ID);
	 SET ULDID = (SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=UAUSERSTAMP);

INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
(ULDID,(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='USER_ACCESS'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;

