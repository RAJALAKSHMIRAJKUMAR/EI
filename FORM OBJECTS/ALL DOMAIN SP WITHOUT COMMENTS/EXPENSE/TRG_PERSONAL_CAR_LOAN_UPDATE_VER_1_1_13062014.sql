DROP TRIGGER IF EXISTS TRG_PERSONAL_CAR_LOAN_UPDATE;
CREATE TRIGGER TRG_PERSONAL_CAR_LOAN_UPDATE  
AFTER UPDATE ON EXPENSE_CAR_LOAN
FOR EACH ROW
BEGIN 
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF ((OLD.ECL_PAID_DATE!= NEW.ECL_PAID_DATE) OR (OLD.ECL_FROM_PERIOD!= NEW.ECL_FROM_PERIOD) OR (OLD.ECL_TO_PERIOD!= NEW.ECL_TO_PERIOD) OR (OLD.ECL_AMOUNT!= NEW.ECL_AMOUNT) OR (OLD.ECL_COMMENTS IS NULL AND NEW.ECL_COMMENTS IS NOT NULL) OR (OLD.ECL_COMMENTS IS NOT NULL AND NEW.ECL_COMMENTS IS NULL) OR (OLD.ECL_COMMENTS!= NEW.ECL_COMMENTS)) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'ECL_ID=', OLD.ECL_ID,','); 
END IF;
IF (OLD.ECL_PAID_DATE!= NEW.ECL_PAID_DATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECL_PAID_DATE=', OLD.ECL_PAID_DATE,','); 
END IF;
IF (OLD.ECL_PAID_DATE!= NEW.ECL_PAID_DATE) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'ECL_PAID_DATE=', NEW.ECL_PAID_DATE,','); 
END IF;
IF (OLD.ECL_FROM_PERIOD!= NEW.ECL_FROM_PERIOD) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECL_FROM_PERIOD=', OLD.ECL_FROM_PERIOD,','); 
END IF;
IF (OLD.ECL_FROM_PERIOD!= NEW.ECL_FROM_PERIOD) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'ECL_FROM_PERIOD=', NEW.ECL_FROM_PERIOD,','); 
END IF;
IF (OLD.ECL_TO_PERIOD!= NEW.ECL_TO_PERIOD) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECL_TO_PERIOD=', OLD.ECL_TO_PERIOD,','); 
END IF;
IF (OLD.ECL_TO_PERIOD!= NEW.ECL_TO_PERIOD) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'ECL_TO_PERIOD=', NEW.ECL_TO_PERIOD,','); 
END IF;
IF (OLD.ECL_AMOUNT!= NEW.ECL_AMOUNT) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECL_AMOUNT=', OLD.ECL_AMOUNT,','); 
END IF;
IF (OLD.ECL_AMOUNT!= NEW.ECL_AMOUNT) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'ECL_AMOUNT=', NEW.ECL_AMOUNT,','); 
END IF;
IF (OLD.ECL_COMMENTS IS NULL AND NEW.ECL_COMMENTS IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'ECL_COMMENTS=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'ECL_COMMENTS=',NEW.ECL_COMMENTS,',');
ELSEIF(OLD.ECL_COMMENTS IS NOT NULL AND NEW.ECL_COMMENTS IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'ECL_COMMENTS=',OLD.ECL_COMMENTS,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'ECL_COMMENTS=','<NULL>,');
ELSEIF (OLD.ECL_COMMENTS!= NEW.ECL_COMMENTS) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECL_COMMENTS=', OLD.ECL_COMMENTS,',');  
SET NEW_VALUE = CONCAT(NEW_VALUE,'ECL_COMMENTS=', NEW.ECL_COMMENTS,','); 
END IF;
IF ((OLD.ECL_PAID_DATE!= NEW.ECL_PAID_DATE) OR (OLD.ECL_FROM_PERIOD!= NEW.ECL_FROM_PERIOD) OR (OLD.ECL_TO_PERIOD!= NEW.ECL_TO_PERIOD) OR (OLD.ECL_AMOUNT!= NEW.ECL_AMOUNT) OR (OLD.ECL_COMMENTS IS NULL AND NEW.ECL_COMMENTS IS NOT NULL) OR (OLD.ECL_COMMENTS IS NOT NULL AND NEW.ECL_COMMENTS IS NULL) OR (OLD.ECL_COMMENTS!= NEW.ECL_COMMENTS)) THEN
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.ECL_TIMESTAMP!= NEW.ECL_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECL_TIMESTAMP=', OLD.ECL_TIMESTAMP,','); 
END IF;
END IF;
IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
IF(OLD_VALUE!=NEW_VALUE)THEN
SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM EXPENSE_CAR_LOAN WHERE ECL_ID=NEW.ECL_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EXPENSE_CAR_LOAN'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;