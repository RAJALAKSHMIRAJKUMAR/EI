DROP TRIGGER IF EXISTS TRG_PERSONAL_BABY_UPDATE;
CREATE TRIGGER TRG_PERSONAL_BABY_UPDATE  
AFTER UPDATE ON EXPENSE_BABY
FOR EACH ROW
BEGIN 
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF ((OLD.ECN_ID!= NEW.ECN_ID) OR (OLD.EB_INVOICE_DATE!= NEW.EB_INVOICE_DATE) OR (OLD.EB_AMOUNT!= NEW.EB_AMOUNT) OR (OLD.EB_INVOICE_ITEMS!= NEW.EB_INVOICE_ITEMS) OR (OLD.EB_INVOICE_FROM!= NEW.EB_INVOICE_FROM) OR (OLD.EB_COMMENTS IS NULL AND NEW.EB_COMMENTS IS NOT NULL) OR (OLD.EB_COMMENTS IS NOT NULL AND NEW.EB_COMMENTS IS NULL) OR (OLD.EB_COMMENTS!= NEW.EB_COMMENTS)) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'EB_ID=', OLD.EB_ID,','); 
END IF;
IF (OLD.ECN_ID!= NEW.ECN_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECN_ID=', OLD.ECN_ID,','); 
END IF;
IF (OLD.ECN_ID!= NEW.ECN_ID) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'ECN_ID=', NEW.ECN_ID,','); 
END IF;
IF (OLD.EB_INVOICE_DATE!= NEW.EB_INVOICE_DATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EB_INVOICE_DATE=', OLD.EB_INVOICE_DATE,','); 
END IF;
IF (OLD.EB_INVOICE_DATE!= NEW.EB_INVOICE_DATE) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EB_INVOICE_DATE=', NEW.EB_INVOICE_DATE,','); 
END IF;
IF (OLD.EB_AMOUNT!= NEW.EB_AMOUNT) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EB_AMOUNT=', OLD.EB_AMOUNT,','); 
END IF;
IF (OLD.EB_AMOUNT!= NEW.EB_AMOUNT) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EB_AMOUNT=', NEW.EB_AMOUNT,','); 
END IF;
IF (OLD.EB_INVOICE_ITEMS!= NEW.EB_INVOICE_ITEMS) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EB_INVOICE_ITEMS=', OLD.EB_INVOICE_ITEMS,','); 
END IF;
IF (OLD.EB_INVOICE_ITEMS!= NEW.EB_INVOICE_ITEMS) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EB_INVOICE_ITEMS=', NEW.EB_INVOICE_ITEMS,','); 
END IF;
IF (OLD.EB_INVOICE_FROM!= NEW.EB_INVOICE_FROM) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EB_INVOICE_FROM=', OLD.EB_INVOICE_FROM,','); 
END IF;
IF (OLD.EB_INVOICE_FROM!= NEW.EB_INVOICE_FROM) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EB_INVOICE_FROM=', NEW.EB_INVOICE_FROM,','); 
END IF;
IF (OLD.EB_COMMENTS IS NULL AND NEW.EB_COMMENTS IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EB_COMMENTS=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EB_COMMENTS=',NEW.EB_COMMENTS,',');
ELSEIF(OLD.EB_COMMENTS IS NOT NULL AND NEW.EB_COMMENTS IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EB_COMMENTS=',OLD.EB_COMMENTS,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EB_COMMENTS=','<NULL>,');
ELSEIF (OLD.EB_COMMENTS!= NEW.EB_COMMENTS) THEN 
SET OLD_VALUE = CONCAT(OLD_VALUE,'EB_COMMENTS=', OLD.EB_COMMENTS,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EB_COMMENTS=', NEW.EB_COMMENTS,','); 
END IF;
IF ((OLD.ECN_ID!= NEW.ECN_ID) OR (OLD.EB_INVOICE_DATE!= NEW.EB_INVOICE_DATE) OR (OLD.EB_AMOUNT!= NEW.EB_AMOUNT) OR (OLD.EB_INVOICE_ITEMS!= NEW.EB_INVOICE_ITEMS) OR (OLD.EB_INVOICE_FROM!= NEW.EB_INVOICE_FROM) OR (OLD.EB_COMMENTS IS NULL AND NEW.EB_COMMENTS IS NOT NULL) OR (OLD.EB_COMMENTS IS NOT NULL AND NEW.EB_COMMENTS IS NULL) OR (OLD.EB_COMMENTS!= NEW.EB_COMMENTS)) THEN  
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.EB_TIMESTAMP!= NEW.EB_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EB_TIMESTAMP=', OLD.EB_TIMESTAMP,','); 
END IF;
END IF;
IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
IF(OLD_VALUE!=NEW_VALUE)THEN
SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM EXPENSE_BABY WHERE EB_ID=NEW.EB_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EXPENSE_BABY'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;