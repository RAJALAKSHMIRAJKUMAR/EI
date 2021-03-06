DROP TRIGGER IF EXISTS TRG_BIZDTL_DIGITAL_VOICE_UPDATE;
CREATE TRIGGER TRG_BIZDTL_DIGITAL_VOICE_UPDATE  
AFTER UPDATE ON EXPENSE_DETAIL_DIGITAL_VOICE
FOR EACH ROW
BEGIN 
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF (OLD.UNIT_ID!= NEW.UNIT_ID) OR (OLD.ECN_ID IS NULL AND NEW.ECN_ID IS NOT NULL) OR (OLD.ECN_ID IS NOT NULL AND NEW.ECN_ID IS NULL) OR (OLD.ECN_ID!= NEW.ECN_ID) OR (OLD.EDDV_REC_VER!= NEW.EDDV_REC_VER) OR (OLD.EDDV_DIGITAL_VOICE_NO!= NEW.EDDV_DIGITAL_VOICE_NO) OR (OLD.EDDV_DIGITAL_ACCOUNT_NO!= NEW.EDDV_DIGITAL_ACCOUNT_NO) OR (OLD.EDDV_COMMENTS IS NULL AND NEW.EDDV_COMMENTS IS NOT NULL) OR (OLD.EDDV_COMMENTS IS NOT NULL AND NEW.EDDV_COMMENTS IS NULL) OR (OLD.EDDV_COMMENTS!= NEW.EDDV_COMMENTS) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'EDDV_ID=', OLD.EDDV_ID,','); 
END IF;
IF (OLD.UNIT_ID!= NEW.UNIT_ID) THEN 
  SET OLD_VALUE = CONCAT(OLD_VALUE,'UNIT_ID=', OLD.UNIT_ID,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'UNIT_ID=', NEW.UNIT_ID,',');
END IF;
IF (OLD.ECN_ID IS NULL AND NEW.ECN_ID IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'ECN_ID=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'ECN_ID=',NEW.ECN_ID,',');
ELSEIF (OLD.ECN_ID IS NOT NULL AND NEW.ECN_ID IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'ECN_ID=',OLD.ECN_ID,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'ECN_ID=','<NULL>,');
ELSEIF (OLD.ECN_ID!= NEW.ECN_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECN_ID=', OLD.ECN_ID,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'ECN_ID=', NEW.ECN_ID,','); 
END IF;
IF (OLD.EDDV_REC_VER!= NEW.EDDV_REC_VER) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDDV_REC_VER=', OLD.EDDV_REC_VER,','); 
END IF;
IF (OLD.EDDV_REC_VER!= NEW.EDDV_REC_VER) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EDDV_REC_VER=', NEW.EDDV_REC_VER,','); 
END IF;
IF (OLD.EDDV_DIGITAL_VOICE_NO!= NEW.EDDV_DIGITAL_VOICE_NO) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDDV_DIGITAL_VOICE_NO=', OLD.EDDV_DIGITAL_VOICE_NO,','); 
END IF;
IF (OLD.EDDV_DIGITAL_VOICE_NO!= NEW.EDDV_DIGITAL_VOICE_NO) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EDDV_DIGITAL_VOICE_NO=', NEW.EDDV_DIGITAL_VOICE_NO,','); 
END IF;
IF (OLD.EDDV_DIGITAL_ACCOUNT_NO!= NEW.EDDV_DIGITAL_ACCOUNT_NO) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDDV_DIGITAL_ACCOUNT_NO=', OLD.EDDV_DIGITAL_ACCOUNT_NO,','); 
END IF;
IF (OLD.EDDV_DIGITAL_ACCOUNT_NO!= NEW.EDDV_DIGITAL_ACCOUNT_NO) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EDDV_DIGITAL_ACCOUNT_NO=', NEW.EDDV_DIGITAL_ACCOUNT_NO,','); 
END IF;
IF (OLD.EDDV_COMMENTS IS NULL AND NEW.EDDV_COMMENTS IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDDV_COMMENTS=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDDV_COMMENTS=',NEW.EDDV_COMMENTS,',');
ELSEIF (OLD.EDDV_COMMENTS IS NOT NULL AND NEW.EDDV_COMMENTS IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDDV_COMMENTS=',OLD.EDDV_COMMENTS,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDDV_COMMENTS=','<NULL>,');
ELSEIF (OLD.EDDV_COMMENTS!= NEW.EDDV_COMMENTS) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDDV_COMMENTS=', OLD.EDDV_COMMENTS,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDDV_COMMENTS=', NEW.EDDV_COMMENTS,','); 
END IF;
IF (OLD.UNIT_ID!= NEW.UNIT_ID) OR (OLD.ECN_ID IS NULL AND NEW.ECN_ID IS NOT NULL) OR (OLD.ECN_ID IS NOT NULL AND NEW.ECN_ID IS NULL) OR (OLD.ECN_ID!= NEW.ECN_ID) OR (OLD.EDDV_REC_VER!= NEW.EDDV_REC_VER) OR (OLD.EDDV_DIGITAL_VOICE_NO!= NEW.EDDV_DIGITAL_VOICE_NO) OR (OLD.EDDV_DIGITAL_ACCOUNT_NO!= NEW.EDDV_DIGITAL_ACCOUNT_NO) OR (OLD.EDDV_COMMENTS IS NULL AND NEW.EDDV_COMMENTS IS NOT NULL) OR (OLD.EDDV_COMMENTS IS NOT NULL AND NEW.EDDV_COMMENTS IS NULL) OR (OLD.EDDV_COMMENTS!= NEW.EDDV_COMMENTS) THEN  
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.EDDV_TIMESTAMP!= NEW.EDDV_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDDV_TIMESTAMP=', OLD.EDDV_TIMESTAMP,','); 
END IF;
END IF;
IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
IF(OLD_VALUE != NEW_VALUE)THEN
     SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
     SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM EXPENSE_DETAIL_DIGITAL_VOICE WHERE EDDV_ID=NEW.EDDV_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EXPENSE_DETAIL_DIGITAL_VOICE'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;