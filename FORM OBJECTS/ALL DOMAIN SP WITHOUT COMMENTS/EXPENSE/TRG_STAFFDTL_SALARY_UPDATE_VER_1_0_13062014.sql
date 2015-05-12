DROP TRIGGER IF EXISTS TRG_STAFFDTL_SALARY_UPDATE;
CREATE TRIGGER TRG_STAFFDTL_SALARY_UPDATE  
AFTER UPDATE ON EXPENSE_DETAIL_STAFF_SALARY 
FOR EACH ROW
BEGIN 
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF ((OLD.EMP_ID!= NEW.EMP_ID) OR (OLD.EDSS_CPF_NUMBER IS NULL AND NEW.EDSS_CPF_NUMBER IS NOT NULL) OR (OLD.EDSS_CPF_AMOUNT IS NULL AND NEW.EDSS_CPF_AMOUNT IS NOT NULL) OR (OLD.EDSS_CPF_AMOUNT IS NOT NULL AND NEW.EDSS_CPF_AMOUNT IS NULL) OR (OLD.EDSS_CPF_AMOUNT!= NEW.EDSS_CPF_AMOUNT) OR
(OLD.EDSS_LEVY_AMOUNT IS NULL AND NEW.EDSS_LEVY_AMOUNT IS NOT NULL) OR (OLD.EDSS_LEVY_AMOUNT IS NOT NULL AND NEW.EDSS_LEVY_AMOUNT IS NULL) OR (OLD.EDSS_LEVY_AMOUNT!= NEW.EDSS_LEVY_AMOUNT) OR
(OLD.EDSS_SALARY_AMOUNT!= NEW.EDSS_SALARY_AMOUNT) OR (OLD.EDSS_COMMENTS IS NULL AND NEW.EDSS_COMMENTS IS NOT NULL) OR (OLD.EDSS_COMMENTS IS NOT NULL AND NEW.EDSS_COMMENTS IS NULL) OR (OLD.EDSS_COMMENTS!= NEW.EDSS_COMMENTS)) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'EDSS_ID=', OLD.EDSS_ID,','); 
END IF;
IF (OLD.EMP_ID!= NEW.EMP_ID) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'EMP_ID=', OLD.EMP_ID,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'EMP_ID=', NEW.EMP_ID,','); 
END IF;
IF (OLD.EDSS_CPF_NUMBER IS NULL AND NEW.EDSS_CPF_NUMBER IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSS_CPF_NUMBER=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSS_CPF_NUMBER=',NEW.EDSS_CPF_NUMBER,',');
ELSEIF(OLD.EDSS_CPF_NUMBER IS NOT NULL AND NEW.EDSS_CPF_NUMBER IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSS_CPF_NUMBER=',OLD.EDSS_CPF_NUMBER,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSS_CPF_NUMBER=','<NULL>,');
ELSEIF (OLD.EDSS_CPF_NUMBER!= NEW.EDSS_CPF_NUMBER) THEN 
SET OLD_VALUE = CONCAT(OLD_VALUE,'EDSS_CPF_NUMBER=', OLD.EDSS_CPF_NUMBER,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSS_CPF_NUMBER=', NEW.EDSS_CPF_NUMBER,','); 
END IF;
IF (OLD.EDSS_CPF_AMOUNT IS NULL AND NEW.EDSS_CPF_AMOUNT IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSS_CPF_AMOUNT=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSS_CPF_AMOUNT=',NEW.EDSS_CPF_AMOUNT,',');
ELSEIF (OLD.EDSS_CPF_AMOUNT IS NOT NULL AND NEW.EDSS_CPF_AMOUNT IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSS_CPF_AMOUNT=',OLD.EDSS_CPF_AMOUNT,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSS_CPF_AMOUNT=','<NULL>,');
ELSEIF (OLD.EDSS_CPF_AMOUNT!= NEW.EDSS_CPF_AMOUNT) THEN 
SET OLD_VALUE = CONCAT(OLD_VALUE,'EDSS_CPF_AMOUNT=', OLD.EDSS_CPF_AMOUNT,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSS_CPF_AMOUNT=', NEW.EDSS_CPF_AMOUNT,','); 
END IF;
IF (OLD.EDSS_LEVY_AMOUNT IS NULL AND NEW.EDSS_LEVY_AMOUNT IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSS_LEVY_AMOUNT=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSS_LEVY_AMOUNT=',NEW.EDSS_LEVY_AMOUNT,',');
ELSEIF (OLD.EDSS_LEVY_AMOUNT IS NOT NULL AND NEW.EDSS_LEVY_AMOUNT IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSS_LEVY_AMOUNT=',OLD.EDSS_LEVY_AMOUNT,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSS_LEVY_AMOUNT=','<NULL>,');
ELSEIF (OLD.EDSS_LEVY_AMOUNT!= NEW.EDSS_LEVY_AMOUNT) THEN 
SET OLD_VALUE = CONCAT(OLD_VALUE,'EDSS_LEVY_AMOUNT=', OLD.EDSS_LEVY_AMOUNT,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSS_LEVY_AMOUNT=', NEW.EDSS_LEVY_AMOUNT,','); 
END IF;
IF (OLD.EDSS_SALARY_AMOUNT!= NEW.EDSS_SALARY_AMOUNT) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSS_SALARY_AMOUNT=', OLD.EDSS_SALARY_AMOUNT,','); 
END IF;
IF (OLD.EDSS_SALARY_AMOUNT!= NEW.EDSS_SALARY_AMOUNT) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EDSS_SALARY_AMOUNT=', NEW.EDSS_SALARY_AMOUNT,','); 
END IF;
IF (OLD.EDSS_COMMENTS IS NULL AND NEW.EDSS_COMMENTS IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSS_COMMENTS=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSS_COMMENTS=',NEW.EDSS_COMMENTS,',');
ELSEIF(OLD.EDSS_COMMENTS IS NOT NULL AND NEW.EDSS_COMMENTS IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSS_COMMENTS=',OLD.EDSS_COMMENTS,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSS_COMMENTS=','<NULL>,');
ELSEIF (OLD.EDSS_COMMENTS!= NEW.EDSS_COMMENTS) THEN 
SET OLD_VALUE = CONCAT(OLD_VALUE,'EDSS_COMMENTS=', OLD.EDSS_COMMENTS,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSS_COMMENTS=', NEW.EDSS_COMMENTS,','); 
END IF;
IF ((OLD.EMP_ID!= NEW.EMP_ID) OR (OLD.EDSS_CPF_NUMBER IS NULL AND NEW.EDSS_CPF_NUMBER IS NOT NULL) OR (OLD.EDSS_CPF_AMOUNT IS NULL AND NEW.EDSS_CPF_AMOUNT IS NOT NULL) OR (OLD.EDSS_CPF_AMOUNT IS NOT NULL AND NEW.EDSS_CPF_AMOUNT IS NULL) OR (OLD.EDSS_CPF_AMOUNT!= NEW.EDSS_CPF_AMOUNT) OR
(OLD.EDSS_LEVY_AMOUNT IS NULL AND NEW.EDSS_LEVY_AMOUNT IS NOT NULL) OR (OLD.EDSS_LEVY_AMOUNT IS NOT NULL AND NEW.EDSS_LEVY_AMOUNT IS NULL) OR (OLD.EDSS_LEVY_AMOUNT!= NEW.EDSS_LEVY_AMOUNT) OR
(OLD.EDSS_SALARY_AMOUNT!= NEW.EDSS_SALARY_AMOUNT) OR (OLD.EDSS_COMMENTS IS NULL AND NEW.EDSS_COMMENTS IS NOT NULL) OR (OLD.EDSS_COMMENTS IS NOT NULL AND NEW.EDSS_COMMENTS IS NULL) OR (OLD.EDSS_COMMENTS!= NEW.EDSS_COMMENTS)) THEN  
 IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.EDSS_TIMESTAMP!= NEW.EDSS_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSS_TIMESTAMP=', OLD.EDSS_TIMESTAMP,','); 
END IF;
END IF;
IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
IF(OLD_VALUE != NEW_VALUE)THEN
     SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
     SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM EXPENSE_DETAIL_STAFF_SALARY  WHERE EDSS_ID=NEW.EDSS_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EXPENSE_DETAIL_STAFF_SALARY '),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;