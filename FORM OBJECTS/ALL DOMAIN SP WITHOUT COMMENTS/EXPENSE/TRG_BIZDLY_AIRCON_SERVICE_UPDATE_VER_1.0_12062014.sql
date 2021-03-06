DROP TRIGGER IF EXISTS TRG_BIZDLY_AIRCON_SERVICE_UPDATE;
CREATE TRIGGER TRG_BIZDLY_AIRCON_SERVICE_UPDATE  
AFTER UPDATE ON EXPENSE_AIRCON_SERVICE 
FOR EACH ROW
BEGIN 
	DECLARE OLD_VALUE TEXT DEFAULT '';
	DECLARE NEW_VALUE TEXT DEFAULT '';
IF (OLD.EDAS_ID!= NEW.EDAS_ID) OR (OLD.EAS_DATE!= NEW.EAS_DATE) OR (OLD.EAS_COMMENTS IS NULL AND NEW.EAS_COMMENTS IS NOT NULL) OR  (OLD.EAS_COMMENTS IS NOT NULL AND NEW.EAS_COMMENTS IS NULL) OR (OLD.EAS_COMMENTS!= NEW.EAS_COMMENTS) THEN  
		SET OLD_VALUE = CONCAT(OLD_VALUE,'EAS_ID=', OLD.EAS_ID,','); 
	END IF;
	IF (OLD.EDAS_ID!= NEW.EDAS_ID) THEN SET 
		OLD_VALUE = CONCAT(OLD_VALUE,'EDAS_ID=', OLD.EDAS_ID,','); 
	END IF;
	IF (OLD.EDAS_ID!= NEW.EDAS_ID) THEN SET 
		NEW_VALUE = CONCAT(NEW_VALUE,'EDAS_ID=', NEW.EDAS_ID,','); 
	END IF;
	IF (OLD.EAS_DATE!= NEW.EAS_DATE) THEN SET 
		OLD_VALUE = CONCAT(OLD_VALUE,'EAS_DATE=', OLD.EAS_DATE,','); 
	END IF;
	IF (OLD.EAS_DATE!= NEW.EAS_DATE) THEN SET 
		NEW_VALUE = CONCAT(NEW_VALUE,'EAS_DATE=', NEW.EAS_DATE,','); 
	END IF;
	IF (OLD.EAS_COMMENTS IS NULL AND NEW.EAS_COMMENTS IS NOT NULL) THEN
		SET OLD_VALUE=CONCAT(OLD_VALUE,'EAS_COMMENTS=','<NULL>,');
		SET NEW_VALUE=CONCAT(NEW_VALUE,'EAS_COMMENTS=',NEW.EAS_COMMENTS,',');
	ELSEIF (OLD.EAS_COMMENTS IS NOT NULL AND NEW.EAS_COMMENTS IS NULL) THEN
		SET OLD_VALUE=CONCAT(OLD_VALUE,'EAS_COMMENTS=',OLD.EAS_COMMENTS,',');
		SET NEW_VALUE=CONCAT(NEW_VALUE,'EAS_COMMENTS=','<NULL>,');
	ELSEIF (OLD.EAS_COMMENTS!= NEW.EAS_COMMENTS) THEN 
		SET OLD_VALUE = CONCAT(OLD_VALUE,'EAS_COMMENTS=', OLD.EAS_COMMENTS,','); 
		SET NEW_VALUE = CONCAT(NEW_VALUE,'EAS_COMMENTS=', NEW.EAS_COMMENTS,','); 
	END IF;
	IF (OLD.EDAS_ID!= NEW.EDAS_ID) OR (OLD.EAS_DATE!= NEW.EAS_DATE) OR (OLD.EAS_COMMENTS IS NULL AND NEW.EAS_COMMENTS IS NOT NULL) OR  (OLD.EAS_COMMENTS IS NOT NULL AND NEW.EAS_COMMENTS IS NULL) OR (OLD.EAS_COMMENTS!= NEW.EAS_COMMENTS) THEN  
	IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.EAS_TIMESTAMP!= NEW.EAS_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EAS_TIMESTAMP=', OLD.EAS_TIMESTAMP,','); 
END IF;
END IF;
	IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
		IF(OLD_VALUE != NEW_VALUE)THEN
			SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
			SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
			INSERT INTO TICKLER_HISTORY
			(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
			((SELECT ULD_ID FROM EXPENSE_AIRCON_SERVICE  WHERE EAS_ID=NEW.EAS_ID),
			(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
			(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EXPENSE_AIRCON_SERVICE'),OLD_VALUE,NEW_VALUE);
		END IF;
	END IF;
END;