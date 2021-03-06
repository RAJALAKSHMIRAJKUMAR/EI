DROP TRIGGER IF EXISTS TRG_BIZDLY_ELECTRICITY_UPDATE;
CREATE TRIGGER TRG_BIZDLY_ELECTRICITY_UPDATE  
AFTER UPDATE ON EXPENSE_ELECTRICITY
FOR EACH ROW
BEGIN 
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF (OLD.EDE_ID!= NEW.EDE_ID) OR (OLD.EE_INVOICE_DATE!= NEW.EE_INVOICE_DATE) OR (OLD.EE_FROM_PERIOD != NEW.EE_FROM_PERIOD ) OR  (OLD.EE_TO_PERIOD != NEW.EE_TO_PERIOD ) OR (OLD.ECN_ID!= NEW.ECN_ID) OR (OLD.EE_AMOUNT!= NEW.EE_AMOUNT) OR (OLD.EE_COMMENTS IS NULL AND NEW.EE_COMMENTS IS NOT NULL) OR (OLD.EE_COMMENTS IS NOT NULL AND NEW.EE_COMMENTS IS NULL) OR (OLD.EE_COMMENTS != NEW.EE_COMMENTS) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'EE_ID=', OLD.EE_ID,','); 
END IF;
IF (OLD.EDE_ID!= NEW.EDE_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDE_ID=', OLD.EDE_ID,','); 
END IF;
IF (OLD.EDE_ID!= NEW.EDE_ID) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EDE_ID=', NEW.EDE_ID,','); 
END IF;
IF (OLD.EE_INVOICE_DATE!= NEW.EE_INVOICE_DATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EE_INVOICE_DATE=', OLD.EE_INVOICE_DATE,','); 
END IF;
IF (OLD.EE_INVOICE_DATE!= NEW.EE_INVOICE_DATE) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EE_INVOICE_DATE=', NEW.EE_INVOICE_DATE,','); 
END IF;
IF (OLD.EE_FROM_PERIOD!= NEW.EE_FROM_PERIOD) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EE_FROM_PERIOD=', OLD.EE_FROM_PERIOD,','); 
END IF;
IF (OLD.EE_FROM_PERIOD!= NEW.EE_FROM_PERIOD) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EE_FROM_PERIOD=', NEW.EE_FROM_PERIOD,','); 
END IF;
IF (OLD.EE_TO_PERIOD!= NEW.EE_TO_PERIOD) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EE_TO_PERIOD=', OLD.EE_TO_PERIOD,','); 
END IF;
IF (OLD.EE_TO_PERIOD!= NEW.EE_TO_PERIOD) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EE_TO_PERIOD=', NEW.EE_TO_PERIOD,','); 
END IF;
IF (OLD.ECN_ID!= NEW.ECN_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECN_ID=', OLD.ECN_ID,','); 
END IF;
IF (OLD.ECN_ID!= NEW.ECN_ID) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'ECN_ID=', NEW.ECN_ID,','); 
END IF;
IF (OLD.EE_AMOUNT!= NEW.EE_AMOUNT) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EE_AMOUNT=', OLD.EE_AMOUNT,','); 
END IF;
IF (OLD.EE_AMOUNT!= NEW.EE_AMOUNT) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EE_AMOUNT=', NEW.EE_AMOUNT,','); 
END IF;
IF (OLD.EE_COMMENTS IS NULL AND NEW.EE_COMMENTS IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EE_COMMENTS=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EE_COMMENTS=',NEW.EE_COMMENTS,',');
ELSEIF(OLD.EE_COMMENTS IS NOT NULL AND NEW.EE_COMMENTS IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EE_COMMENTS=',OLD.EE_COMMENTS,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EE_COMMENTS=','<NULL>,');
ELSEIF (OLD.EE_COMMENTS!= NEW.EE_COMMENTS) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EE_COMMENTS=', OLD.EE_COMMENTS,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EE_COMMENTS=', NEW.EE_COMMENTS,','); 
END IF;
IF (OLD.EDE_ID!= NEW.EDE_ID) OR (OLD.EE_INVOICE_DATE!= NEW.EE_INVOICE_DATE) OR (OLD.EE_FROM_PERIOD != NEW.EE_FROM_PERIOD ) OR  (OLD.EE_TO_PERIOD != NEW.EE_TO_PERIOD ) OR (OLD.ECN_ID!= NEW.ECN_ID) OR (OLD.EE_AMOUNT!= NEW.EE_AMOUNT) OR (OLD.EE_COMMENTS IS NULL AND NEW.EE_COMMENTS IS NOT NULL) OR (OLD.EE_COMMENTS IS NOT NULL AND NEW.EE_COMMENTS IS NULL) OR (OLD.EE_COMMENTS != NEW.EE_COMMENTS) THEN  
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.EE_TIMESTAMP!= NEW.EE_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EE_TIMESTAMP=', OLD.EE_TIMESTAMP,','); 
END IF;
END IF;
IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
IF(OLD_VALUE != NEW_VALUE)THEN
SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM EXPENSE_ELECTRICITY WHERE EE_ID=NEW.EE_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EXPENSE_ELECTRICITY'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;