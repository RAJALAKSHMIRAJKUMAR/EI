-- version 0.9 -- sdate:13/06/2014 -- edate:13/06/2014 -- issue:738 -- commentno:#27 -- desc:IMPLEMENTING TRIGGER CHANGES FOR NOT UPDATING ULD_ID,TIMESTAMP IN TICKLER_HISTORY BY: RAJA
-- version 0.8 -- sdate:12/06/2014 -- edate:12/06/2014 -- issue:738 -- commentno:#18 -- desc:IMPLEMENTING TRIGGER CHANGES FOR NOT UPDATING PRIMARY KEY IN TICKLER_HISTORY BY: RAJA
-- version 0.7 -- sdate:05/06/2014 -- edate:05/06/2014 -- issue:529 -- commentno:#196 -- desc:ADD ULD_ID AND TIMESTAMP TO UPDATE OLD VALUE DONE BY:BHAVANI.R
-- version:0.6 -- sdate:07/04/2014 -- edate:07/04/2014 -- issue:797 -- commentno:28 -- comment: table name and header changed -- done by:Rajaraghu
-- VERSION :0.5, TRACKER: 529, COMMENT:#105 ,START DATE: 10-02-2014, END DATE: 10-02-2014, DESC: added comma after one header value is completed, DONE BY: MANIKANDAN S
-- version 0.4 -- sdate:08/02/2014 -- edate:08/02/2014 -- issue:738 -- commentno:#1 -- desc:ADDED ONE CONDITION FOR NOT CREATING NULL ROW IN TICKLER_HISTORY DONE BY:DHIVYA
-- version 0.3-- >startdate:27/01/2014 enddate:27/01/2014 -- >issue no:536 comment no:#39 desc:changed cheque_entry_details cs_id as BCN_ID as per table updation done by:DHIVYA.A
-- version 0.2 -- sdate:10/11/2013 -- edate:10/11/2013 -- issue:636 commentno#47 -- desc:trigger name changed by rl
-- > version 0.1-- >start date:12/10/2013 end date:14/10/2013-- >issueno:529 -- >commentno:53 -- >desc:TRIGGER UPDATION QUERY FOR BANK_TRANSFER TABLE
-- >doneby:dhivya

DROP TRIGGER IF EXISTS TRG_CHEQUE_ENTRY_DETAILS_UPDATE;
CREATE TRIGGER TRG_CHEQUE_ENTRY_DETAILS_UPDATE
AFTER UPDATE ON CHEQUE_ENTRY_DETAILS
FOR EACH ROW
BEGIN 
-- declaration for old_value and new_value to store it in TICKLER_HISTORY table
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF ((OLD.CHEQUE_DATE!= NEW.CHEQUE_DATE) OR (OLD.CHEQUE_TO!= NEW.CHEQUE_TO) OR (OLD.CHEQUE_NO != NEW.CHEQUE_NO) OR (OLD.CHEQUE_FOR!= NEW.CHEQUE_FOR)OR (OLD.CHEQUE_AMOUNT!= NEW.CHEQUE_AMOUNT)
OR (OLD.CHEQUE_UNIT_NO IS NULL AND NEW.CHEQUE_UNIT_NO IS NOT NULL) OR (OLD.CHEQUE_UNIT_NO IS NOT NULL AND NEW.CHEQUE_UNIT_NO IS NULL) OR (OLD.CHEQUE_UNIT_NO != NEW.CHEQUE_UNIT_NO)
OR (OLD.BCN_ID!= NEW.BCN_ID) OR (OLD.CHEQUE_DEBITED_RETURNED_DATE IS NULL AND NEW.CHEQUE_DEBITED_RETURNED_DATE IS NOT NULL) OR (OLD.CHEQUE_DEBITED_RETURNED_DATE IS NOT NULL AND NEW.CHEQUE_DEBITED_RETURNED_DATE IS NULL) OR (OLD.CHEQUE_DEBITED_RETURNED_DATE != NEW.CHEQUE_DEBITED_RETURNED_DATE)
OR (OLD.CHEQUE_COMMENTS IS NULL AND NEW.CHEQUE_COMMENTS IS NOT NULL) OR (OLD.CHEQUE_COMMENTS IS NOT NULL AND NEW.CHEQUE_COMMENTS IS NULL) OR (OLD.CHEQUE_COMMENTS != NEW.CHEQUE_COMMENTS)) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'CHEQUE_ID=', OLD.CHEQUE_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for CHEQUE_DATE to store it in TICKLER_HISTORY table
IF (OLD.CHEQUE_DATE!= NEW.CHEQUE_DATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'CHEQUE_DATE=', OLD.CHEQUE_DATE,','); 
END IF;
IF (OLD.CHEQUE_DATE!= NEW.CHEQUE_DATE) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'CHEQUE_DATE=', NEW.CHEQUE_DATE,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for CHEQUE_TO to store it in TICKLER_HISTORY table
IF (OLD.CHEQUE_TO!= NEW.CHEQUE_TO) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'CHEQUE_TO=', OLD.CHEQUE_TO,','); 
END IF;
IF (OLD.CHEQUE_TO!= NEW.CHEQUE_TO) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'CHEQUE_TO=', NEW.CHEQUE_TO,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for CHEQUE_NO to store it in TICKLER_HISTORY table
IF (OLD.CHEQUE_NO!= NEW.CHEQUE_NO) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'CHEQUE_NO=', OLD.CHEQUE_NO,','); 
END IF;
IF (OLD.CHEQUE_NO!= NEW.CHEQUE_NO) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'CHEQUE_NO=', NEW.CHEQUE_NO,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for CHEQUE_FOR to store it in TICKLER_HISTORY table
IF (OLD.CHEQUE_FOR!= NEW.CHEQUE_FOR) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'CHEQUE_FOR=', OLD.CHEQUE_FOR,','); 
END IF;
IF (OLD.CHEQUE_FOR!= NEW.CHEQUE_FOR) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'CHEQUE_FOR=', NEW.CHEQUE_FOR,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for CHEQUE_AMOUNT to store it in TICKLER_HISTORY table
IF (OLD.CHEQUE_AMOUNT!= NEW.CHEQUE_AMOUNT) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'CHEQUE_AMOUNT=', OLD.CHEQUE_AMOUNT,','); 
END IF;
IF (OLD.CHEQUE_AMOUNT!= NEW.CHEQUE_AMOUNT) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'CHEQUE_AMOUNT=', NEW.CHEQUE_AMOUNT,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for CHEQUE_UNIT_NO to store it in TICKLER_HISTORY table
IF (OLD.CHEQUE_UNIT_NO IS NULL AND NEW.CHEQUE_UNIT_NO IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'CHEQUE_UNIT_NO=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'CHEQUE_UNIT_NO=',NEW.CHEQUE_UNIT_NO,',');
ELSEIF (OLD.CHEQUE_UNIT_NO IS NOT NULL AND NEW.CHEQUE_UNIT_NO IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'CHEQUE_UNIT_NO=',OLD.CHEQUE_UNIT_NO,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'CHEQUE_UNIT_NO=','<NULL>,');
ELSEIF (OLD.CHEQUE_UNIT_NO!= NEW.CHEQUE_UNIT_NO) THEN 
SET OLD_VALUE = CONCAT(OLD_VALUE,'CHEQUE_UNIT_NO=', OLD.CHEQUE_UNIT_NO,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'CHEQUE_UNIT_NO=', NEW.CHEQUE_UNIT_NO,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for BCN_ID to store it in TICKLER_HISTORY table
IF (OLD.BCN_ID!= NEW.BCN_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'BCN_ID=', OLD.BCN_ID,','); 
END IF;
IF (OLD.BCN_ID!= NEW.BCN_ID) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'BCN_ID=', NEW.BCN_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for CHEQUE_DEBITED_RETURNED_DATE to store it in TICKLER_HISTORY table
IF (OLD.CHEQUE_DEBITED_RETURNED_DATE IS NULL AND NEW.CHEQUE_DEBITED_RETURNED_DATE IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'CHEQUE_DEBITED_RETURNED_DATE=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'CHEQUE_DEBITED_RETURNED_DATE=',NEW.CHEQUE_DEBITED_RETURNED_DATE,',');
ELSEIF (OLD.CHEQUE_DEBITED_RETURNED_DATE IS NOT NULL AND NEW.CHEQUE_DEBITED_RETURNED_DATE IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'CHEQUE_DEBITED_RETURNED_DATE=',OLD.CHEQUE_DEBITED_RETURNED_DATE,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'CHEQUE_DEBITED_RETURNED_DATE=','<NULL>,');
ELSEIF (OLD.CHEQUE_DEBITED_RETURNED_DATE!= NEW.CHEQUE_DEBITED_RETURNED_DATE) THEN 
SET OLD_VALUE = CONCAT(OLD_VALUE,'CHEQUE_DEBITED_RETURNED_DATE=', OLD.CHEQUE_DEBITED_RETURNED_DATE,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'CHEQUE_DEBITED_RETURNED_DATE=', NEW.CHEQUE_DEBITED_RETURNED_DATE,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for CHEQUE_COMMENTS to store it in TICKLER_HISTORY table
IF (OLD.CHEQUE_COMMENTS IS NULL AND NEW.CHEQUE_COMMENTS IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'CHEQUE_COMMENTS=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'CHEQUE_COMMENTS=',NEW.CHEQUE_COMMENTS,',');
ELSEIF (OLD.CHEQUE_COMMENTS IS NOT NULL AND NEW.CHEQUE_COMMENTS IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'CHEQUE_COMMENTS=',OLD.CHEQUE_COMMENTS,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'CHEQUE_COMMENTS=','<NULL>,');
ELSEIF (OLD.CHEQUE_COMMENTS!= NEW.CHEQUE_COMMENTS) THEN 
SET OLD_VALUE = CONCAT(OLD_VALUE,'CHEQUE_COMMENTS=', OLD.CHEQUE_COMMENTS,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'CHEQUE_COMMENTS=', NEW.CHEQUE_COMMENTS,','); 
END IF;
IF ((OLD.CHEQUE_DATE!= NEW.CHEQUE_DATE) OR (OLD.CHEQUE_TO!= NEW.CHEQUE_TO) OR (OLD.CHEQUE_NO != NEW.CHEQUE_NO) OR (OLD.CHEQUE_FOR!= NEW.CHEQUE_FOR)OR (OLD.CHEQUE_AMOUNT!= NEW.CHEQUE_AMOUNT)
OR (OLD.CHEQUE_UNIT_NO IS NULL AND NEW.CHEQUE_UNIT_NO IS NOT NULL) OR (OLD.CHEQUE_UNIT_NO IS NOT NULL AND NEW.CHEQUE_UNIT_NO IS NULL) OR (OLD.CHEQUE_UNIT_NO != NEW.CHEQUE_UNIT_NO)
OR (OLD.BCN_ID!= NEW.BCN_ID) OR (OLD.CHEQUE_DEBITED_RETURNED_DATE IS NULL AND NEW.CHEQUE_DEBITED_RETURNED_DATE IS NOT NULL) OR (OLD.CHEQUE_DEBITED_RETURNED_DATE IS NOT NULL AND NEW.CHEQUE_DEBITED_RETURNED_DATE IS NULL) OR (OLD.CHEQUE_DEBITED_RETURNED_DATE != NEW.CHEQUE_DEBITED_RETURNED_DATE)
OR (OLD.CHEQUE_COMMENTS IS NULL AND NEW.CHEQUE_COMMENTS IS NOT NULL) OR (OLD.CHEQUE_COMMENTS IS NOT NULL AND NEW.CHEQUE_COMMENTS IS NULL) OR (OLD.CHEQUE_COMMENTS != NEW.CHEQUE_COMMENTS)) THEN
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.CHEQUE_TIMESTAMP!= NEW.CHEQUE_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'CHEQUE_TIMESTAMP=', OLD.CHEQUE_TIMESTAMP,','); 
END IF;
END IF;
IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
IF (OLD_VALUE!=NEW_VALUE)THEN

-- REMOVING COMMA(,) AT THE END OF OLD_VALUE & NEW_VALUE
     SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
     SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);

-- inserting old_values and new_values in the TICKLER_HISTORY table with their corresponding POSTTAP_ID in TICKLER_TABID_PROFILE
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM CHEQUE_ENTRY_DETAILS  WHERE CHEQUE_ID=NEW.CHEQUE_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CHEQUE_ENTRY_DETAILS'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;