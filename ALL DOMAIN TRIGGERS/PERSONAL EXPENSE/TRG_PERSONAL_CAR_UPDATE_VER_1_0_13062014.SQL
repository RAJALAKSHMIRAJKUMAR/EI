-- version 1.0 -- sdate:13/06/2014 -- edate:13/06/2014 -- issue:738 -- commentno:#24 -- desc:IMPLEMENTING TRIGGER CHANGES FOR NOT UPDATING ULD_ID AND TIMESTAMP IN TICKLER_HISTORY DONE BY:SASIKALA.D
-- version 0.9 -- sdate:12/06/2014 -- edate:12/06/2014 -- issue:738 -- commentno:#18 -- desc:IMPLEMENTING TRIGGER CHANGES FOR NOT UPDATING PRIMARY KEY IN TICKLER_HISTORY DONE BY:SASIKALA.D
-- version 0.8 -- sdate:07/04/2014 -- edate:07/04/2014 -- issue:797 -- commentno:#28 -- desc:REPLACED TABLENAME AND HEADERNAME DONE BY:SASIKALA.D
-- version:0.7 -- sdate:26/02/2014 -- edate:26/02/2014 -- issue:529 -- commentno:132 -- done by:RL
-- version:0.6 -- sdate:10/02/2014 -- edate:10/02/2014 -- issue:529 -- desc:add comma after 1 header value is completed -- doneby:RL
-- version 0.5 -- sdate:08/02/2014 -- edate:08/02/2014 -- issue:738 -- commentno:#1 -- desc:ADDED ONE CONDITION FOR NOT CREATING NULL ROW IN TICKLER_HISTORY DONE BY:DHIVYA
-- version 0.4 -- sd:08/11/2013 -- ed:08/11/2013 -- issue:636 -- commentno:47 -- desc:trigger name changed by rl
-- version 0.3 -- >start date:08/10/2013 end date:10/10/2013-- >issueno:636 -- >desc:changed variable name O as old_value and N as new_value and added comments
-- >doneby:dhivya
-- > version 0.2 -- >date:02/08/2013 -- >issueno:529 -- >commentno:23 -- >desc:changed ECN_SNO to ECN_ID &added one condition for null fields
-- >doneby:dhivya

-- after update on EXPENSE_CAR table this trigger will be executed
DROP TRIGGER IF EXISTS TRG_PERSONAL_CAR_UPDATE;
CREATE TRIGGER TRG_PERSONAL_CAR_UPDATE  
AFTER UPDATE ON EXPENSE_CAR
FOR EACH ROW
BEGIN 
-- declaration for old_value and new_value to store it in TICKLER_HISTORY table
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF ((OLD.ECN_ID!= NEW.ECN_ID) OR (OLD.EC_INVOICE_DATE!= NEW.EC_INVOICE_DATE) OR (OLD.EC_AMOUNT!= NEW.EC_AMOUNT) OR (OLD.EC_INVOICE_ITEMS!= NEW.EC_INVOICE_ITEMS) OR (OLD.EC_INVOICE_FROM!= NEW.EC_INVOICE_FROM) OR (OLD.EC_COMMENTS IS NULL AND NEW.EC_COMMENTS IS NOT NULL) OR (OLD.EC_COMMENTS IS NOT NULL AND NEW.EC_COMMENTS IS NULL) OR (OLD.EC_COMMENTS!= NEW.EC_COMMENTS)) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'EC_ID=', OLD.EC_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for ECN_ID to store it in TICKLER_HISTORY table
IF (OLD.ECN_ID!= NEW.ECN_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECN_ID=', OLD.ECN_ID,','); 
END IF;
IF (OLD.ECN_ID!= NEW.ECN_ID) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'ECN_ID=', NEW.ECN_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EC_INVOICE_DATE to store it in TICKLER_HISTORY table
IF (OLD.EC_INVOICE_DATE!= NEW.EC_INVOICE_DATE) THEN SET 
OLD_VALUE= CONCAT(OLD_VALUE,'EC_INVOICE_DATE=', OLD.EC_INVOICE_DATE,','); 
END IF;
IF (OLD.EC_INVOICE_DATE!= NEW.EC_INVOICE_DATE) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EC_INVOICE_DATE=', NEW.EC_INVOICE_DATE,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EC_AMOUNT to store it in TICKLER_HISTORY table
IF (OLD.EC_AMOUNT!= NEW.EC_AMOUNT) THEN SET 
OLD_VALUE= CONCAT(OLD_VALUE,'EC_AMOUNT=', OLD.EC_AMOUNT,','); 
END IF;
IF (OLD.EC_AMOUNT!= NEW.EC_AMOUNT) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EC_AMOUNT=', NEW.EC_AMOUNT,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EC_INVOICE_ITEMS to store it in TICKLER_HISTORY table
IF (OLD.EC_INVOICE_ITEMS!= NEW.EC_INVOICE_ITEMS) THEN SET 
OLD_VALUE= CONCAT(OLD_VALUE,'EC_INVOICE_ITEMS=', OLD.EC_INVOICE_ITEMS,','); 
END IF;
IF (OLD.EC_INVOICE_ITEMS!= NEW.EC_INVOICE_ITEMS) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EC_INVOICE_ITEMS=', NEW.EC_INVOICE_ITEMS,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EC_INVOICE_FROM to store it in TICKLER_HISTORY table
IF (OLD.EC_INVOICE_FROM!= NEW.EC_INVOICE_FROM) THEN SET 
OLD_VALUE= CONCAT(OLD_VALUE,'EC_INVOICE_FROM=', OLD.EC_INVOICE_FROM,','); 
END IF;
IF (OLD.EC_INVOICE_FROM!= NEW.EC_INVOICE_FROM) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EC_INVOICE_FROM=', NEW.EC_INVOICE_FROM,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EC_COMMENTS to store it in TICKLER_HISTORY table
IF (OLD.EC_COMMENTS IS NULL AND NEW.EC_COMMENTS IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EC_COMMENTS=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EC_COMMENTS=',NEW.EC_COMMENTS,',');
ELSEIF(OLD.EC_COMMENTS IS NOT NULL AND NEW.EC_COMMENTS IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EC_COMMENTS=',OLD.EC_COMMENTS,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EC_COMMENTS=','<NULL>,');
ELSEIF (OLD.EC_COMMENTS!= NEW.EC_COMMENTS) THEN 
SET OLD_VALUE= CONCAT(OLD_VALUE,'EC_COMMENTS=', OLD.EC_COMMENTS,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EC_COMMENTS=', NEW.EC_COMMENTS,','); 
END IF;
IF ((OLD.ECN_ID!= NEW.ECN_ID) OR (OLD.EC_INVOICE_DATE!= NEW.EC_INVOICE_DATE) OR (OLD.EC_AMOUNT!= NEW.EC_AMOUNT) OR (OLD.EC_INVOICE_ITEMS!= NEW.EC_INVOICE_ITEMS) OR (OLD.EC_INVOICE_FROM!= NEW.EC_INVOICE_FROM) OR (OLD.EC_COMMENTS IS NULL AND NEW.EC_COMMENTS IS NOT NULL) OR (OLD.EC_COMMENTS IS NOT NULL AND NEW.EC_COMMENTS IS NULL) OR (OLD.EC_COMMENTS!= NEW.EC_COMMENTS)) THEN  
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.EC_TIMESTAMP!= NEW.EC_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EC_TIMESTAMP=', OLD.EC_TIMESTAMP,','); 
END IF;
END IF;
-- inserting old_values and new_values in the TICKLER_HISTORY table with their corresponding TTIP_ID in TICKLER_TABID_PROFILE
IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
IF(OLD_VALUE!=NEW_VALUE)THEN
SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM EXPENSE_CAR WHERE EC_ID=NEW.EC_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EXPENSE_CAR'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;
