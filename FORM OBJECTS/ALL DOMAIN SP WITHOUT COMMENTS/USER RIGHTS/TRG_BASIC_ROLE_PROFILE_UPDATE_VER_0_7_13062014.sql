DROP TRIGGER IF EXISTS TRG_BASIC_ROLE_PROFILE_UPDATE;
CREATE TRIGGER TRG_BASIC_ROLE_PROFILE_UPDATE  
AFTER UPDATE ON BASIC_ROLE_PROFILE 
FOR EACH ROW
BEGIN 
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF ((OLD.URC_ID!= NEW.URC_ID) OR (OLD.BRP_BR_ID!= NEW.BRP_BR_ID)) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'BRP_ID=', OLD.BRP_ID,','); 
END IF;
IF (OLD.URC_ID!= NEW.URC_ID) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'URC_ID=', OLD.URC_ID,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'URC_ID=', NEW.URC_ID,',');
END IF;
IF (OLD.BRP_BR_ID!= NEW.BRP_BR_ID) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'BRP_BR_ID=', OLD.BRP_BR_ID,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'BRP_BR_ID=', NEW.BRP_BR_ID,','); 
END IF;
IF ((OLD.URC_ID!= NEW.URC_ID) OR (OLD.BRP_BR_ID!= NEW.BRP_BR_ID)) THEN  
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.BRP_TIMESTAMP!= NEW.BRP_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'BRP_TIMESTAMP=', OLD.BRP_TIMESTAMP,','); 
END IF;
END IF;
IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
IF (OLD_VALUE != NEW_VALUE) THEN
     SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
     SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM BASIC_ROLE_PROFILE  WHERE BRP_ID=NEW.BRP_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='BASIC_ROLE_PROFILE'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;