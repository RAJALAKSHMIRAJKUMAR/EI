DROP TRIGGER IF EXISTS TRG_UNIT_STAMP_DUTY_TYPE_UPDATE;
CREATE TRIGGER TRG_UNIT_STAMP_DUTY_TYPE_UPDATE
AFTER UPDATE ON UNIT_STAMP_DUTY_TYPE
FOR EACH ROW
BEGIN 
	DECLARE OLD_VALUE TEXT DEFAULT '';
	DECLARE NEW_VALUE TEXT DEFAULT '';
	IF (OLD.USDT_DATA!= NEW.USDT_DATA) THEN 
		IF (OLD.USDT_ID) THEN  
		  SET OLD_VALUE = CONCAT(OLD_VALUE,'USDT_ID=', OLD.USDT_ID,','); 
		END IF;
	END IF;
	IF (OLD.USDT_DATA!= NEW.USDT_DATA) THEN  
		SET OLD_VALUE = CONCAT(OLD_VALUE,'USDT_DATA=', OLD.USDT_DATA,','); 
	END IF;
	IF (OLD.USDT_DATA!= NEW.USDT_DATA) THEN  
		SET NEW_VALUE = CONCAT(NEW_VALUE,'USDT_DATA=', NEW.USDT_DATA,','); 
	END IF;
	IF (OLD.USDT_DATA!= NEW.USDT_DATA) THEN 
		IF (OLD.ULD_ID!= NEW.ULD_ID) THEN  
			SET OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
		END IF;
		IF (OLD.USDT_TIMESTAMP!= NEW.USDT_TIMESTAMP) THEN  
			SET OLD_VALUE = CONCAT(OLD_VALUE,'USDT_TIMESTAMP=', OLD.USDT_TIMESTAMP,','); 
		END IF;
	END IF;
	IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
		IF(OLD_VALUE!=NEW_VALUE)THEN
			SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
			SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
			INSERT INTO TICKLER_HISTORY(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
			((SELECT ULD_ID FROM UNIT_STAMP_DUTY_TYPE  WHERE USDT_ID=NEW.USDT_ID),
			(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
			(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='UNIT_STAMP_DUTY_TYPE'),OLD_VALUE,NEW_VALUE);
		END IF;
	END IF;
END;