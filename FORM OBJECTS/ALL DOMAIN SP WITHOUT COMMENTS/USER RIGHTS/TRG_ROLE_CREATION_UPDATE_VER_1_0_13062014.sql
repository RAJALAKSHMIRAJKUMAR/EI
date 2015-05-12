DROP TRIGGER IF EXISTS TRG_ROLE_CREATION_UPDATE;
CREATE TRIGGER TRG_ROLE_CREATION_UPDATE  
AFTER UPDATE ON ROLE_CREATION 
FOR EACH ROW
BEGIN 
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
DECLARE ULDUSERSTAMP VARCHAR(50);
DECLARE ULDID INTEGER(2);
IF ((OLD.URC_ID!= NEW.URC_ID) OR (OLD.RC_NAME!= NEW.RC_NAME)) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'RC_ID=', OLD.RC_ID,','); 
END IF;
IF (OLD.URC_ID!= NEW.URC_ID) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'URC_ID=', OLD.URC_ID,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'URC_ID=', NEW.URC_ID,','); 
END IF;
IF (OLD.RC_NAME!= NEW.RC_NAME) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'RC_NAME=', OLD.RC_NAME,','); 
  SET NEW_VALUE = CONCAT(NEW_VALUE,'RC_NAME=', NEW.RC_NAME,','); 
END IF;
IF ((OLD.URC_ID!= NEW.URC_ID) OR (OLD.RC_NAME!= NEW.RC_NAME)) THEN  
IF (OLD.RC_USERSTAMP!= NEW.RC_USERSTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'RC_USERSTAMP=', OLD.RC_USERSTAMP,','); 
END IF;
IF (OLD.RC_TIMESTAMP!= NEW.RC_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'RC_TIMESTAMP=', OLD.RC_TIMESTAMP,','); 
END IF;
END IF;
IF (OLD_VALUE !='' AND NEW_VALUE!='') THEN
IF (OLD_VALUE != NEW_VALUE)THEN
     SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
     SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
	 SET ULDUSERSTAMP = (SELECT RC_USERSTAMP FROM ROLE_CREATION  WHERE RC_ID=NEW.RC_ID);
	 SET ULDID = (SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=ULDUSERSTAMP);
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
(ULDID,(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='ROLE_CREATION'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;