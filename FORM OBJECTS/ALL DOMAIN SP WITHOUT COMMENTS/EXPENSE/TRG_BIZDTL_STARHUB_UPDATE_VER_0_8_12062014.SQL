DROP TRIGGER IF EXISTS TRG_BIZDTL_STARHUB_UPDATE;
CREATE TRIGGER TRG_BIZDTL_STARHUB_UPDATE 
AFTER UPDATE ON EXPENSE_DETAIL_STARHUB
FOR EACH ROW
BEGIN 
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF (OLD.UNIT_ID!= NEW.UNIT_ID) OR (OLD.ECN_ID IS NULL AND NEW.ECN_ID IS NOT NULL) OR (OLD.ECN_ID IS NOT NULL AND NEW.ECN_ID IS NULL) OR (OLD.ECN_ID!= NEW.ECN_ID) OR (OLD.EDSH_REC_VER!= NEW.EDSH_REC_VER) OR (OLD.EDSH_ACCOUNT_NO != NEW.EDSH_ACCOUNT_NO) OR (OLD.EDSH_APPL_DATE IS NULL AND NEW.EDSH_APPL_DATE IS NOT NULL) OR (OLD.EDSH_APPL_DATE IS NOT NULL AND NEW.EDSH_APPL_DATE IS NULL) OR  (OLD.EDSH_APPL_DATE!= NEW.EDSH_APPL_DATE) OR (OLD.EDSH_CABLE_START_DATE IS NULL AND NEW.EDSH_CABLE_START_DATE IS NOT NULL) OR (OLD.EDSH_CABLE_START_DATE IS NOT NULL AND NEW.EDSH_CABLE_START_DATE IS NULL) OR (OLD.EDSH_CABLE_START_DATE!= NEW.EDSH_CABLE_START_DATE) OR (OLD.EDSH_CABLE_END_DATE IS NULL AND NEW.EDSH_CABLE_END_DATE IS NOT NULL) OR (OLD.EDSH_CABLE_END_DATE IS NOT NULL AND NEW.EDSH_CABLE_END_DATE IS NULL) OR (OLD.EDSH_CABLE_END_DATE!= NEW.EDSH_CABLE_END_DATE) OR (OLD.EDSH_INTERNET_START_DATE IS NULL AND NEW.EDSH_INTERNET_START_DATE IS NOT NULL) OR (OLD.EDSH_INTERNET_START_DATE IS NOT NULL AND NEW.EDSH_INTERNET_START_DATE IS NULL) OR (OLD.EDSH_INTERNET_START_DATE!= NEW.EDSH_INTERNET_START_DATE) OR (OLD.EDSH_INTERNET_END_DATE IS NULL AND NEW.EDSH_INTERNET_END_DATE IS NOT NULL) OR (OLD.EDSH_INTERNET_END_DATE IS NOT NULL AND NEW.EDSH_INTERNET_END_DATE IS NULL) OR (OLD.EDSH_INTERNET_END_DATE!= NEW.EDSH_INTERNET_END_DATE) OR (OLD.EDSH_SSID IS NULL AND NEW.EDSH_SSID IS NOT NULL) OR (OLD.EDSH_SSID IS NOT NULL AND NEW.EDSH_SSID IS NULL) OR (OLD.EDSH_SSID!= NEW.EDSH_SSID) OR (OLD.EDSH_PWD IS NULL AND NEW.EDSH_PWD IS NOT NULL) OR (OLD.EDSH_PWD IS NOT NULL AND NEW.EDSH_PWD IS NULL) OR (OLD.EDSH_PWD!= NEW.EDSH_PWD) OR (OLD.EDSH_CABLE_BOX_SERIAL_NO IS NULL AND NEW.EDSH_CABLE_BOX_SERIAL_NO IS NOT NULL) OR (OLD.EDSH_CABLE_BOX_SERIAL_NO IS NOT NULL AND NEW.EDSH_CABLE_BOX_SERIAL_NO IS NULL) OR (OLD.EDSH_CABLE_BOX_SERIAL_NO!= NEW.EDSH_CABLE_BOX_SERIAL_NO) OR (OLD.EDSH_MODEM_SERIAL_NO IS NULL AND NEW.EDSH_MODEM_SERIAL_NO IS NOT NULL) OR (OLD.EDSH_MODEM_SERIAL_NO IS NOT NULL AND NEW.EDSH_MODEM_SERIAL_NO IS NULL) OR (OLD.EDSH_MODEM_SERIAL_NO!= NEW.EDSH_MODEM_SERIAL_NO) OR (OLD.EDSH_BASIC_GROUP IS NULL AND NEW.EDSH_BASIC_GROUP IS NOT NULL) OR (OLD.EDSH_BASIC_GROUP IS NOT NULL AND NEW.EDSH_BASIC_GROUP IS NULL) OR (OLD.EDSH_BASIC_GROUP!= NEW.EDSH_BASIC_GROUP) OR (OLD.EDSH_ADDTNL_CH IS NULL AND NEW.EDSH_ADDTNL_CH IS NOT NULL) OR (OLD.EDSH_ADDTNL_CH IS NOT NULL AND NEW.EDSH_ADDTNL_CH IS NULL) OR (OLD.EDSH_ADDTNL_CH!= NEW.EDSH_ADDTNL_CH) OR (OLD.EDSH_COMMENTS IS NULL AND NEW.EDSH_COMMENTS IS NOT NULL) OR (OLD.EDSH_COMMENTS IS NOT NULL AND NEW.EDSH_COMMENTS IS NULL) OR (OLD.EDSH_COMMENTS!= NEW.EDSH_COMMENTS) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_ID=', OLD.EDSH_ID,','); 
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
IF (OLD.EDSH_REC_VER!= NEW.EDSH_REC_VER) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_REC_VER=', OLD.EDSH_REC_VER,','); 
END IF;
IF (OLD.EDSH_REC_VER!= NEW.EDSH_REC_VER) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_REC_VER=', NEW.EDSH_REC_VER,','); 
END IF;
IF (OLD.EDSH_ACCOUNT_NO!= NEW.EDSH_ACCOUNT_NO) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_ACCOUNT_NO=', OLD.EDSH_ACCOUNT_NO,','); 
END IF;
IF (OLD.EDSH_ACCOUNT_NO!= NEW.EDSH_ACCOUNT_NO) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_ACCOUNT_NO=', NEW.EDSH_ACCOUNT_NO,','); 
END IF;
IF (OLD.EDSH_APPL_DATE IS NULL AND NEW.EDSH_APPL_DATE IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_APPL_DATE=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_APPL_DATE=',NEW.EDSH_APPL_DATE,',');
ELSEIF (OLD.EDSH_APPL_DATE IS NOT NULL AND NEW.EDSH_APPL_DATE IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_APPL_DATE=',OLD.EDSH_APPL_DATE,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_APPL_DATE=','<NULL>,');
ELSEIF (OLD.EDSH_APPL_DATE!= NEW.EDSH_APPL_DATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_APPL_DATE=', OLD.EDSH_APPL_DATE,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_APPL_DATE=', NEW.EDSH_APPL_DATE,','); 
END IF;
IF (OLD.EDSH_CABLE_START_DATE IS NULL AND NEW.EDSH_CABLE_START_DATE IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_CABLE_START_DATE=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_CABLE_START_DATE=',NEW.EDSH_CABLE_START_DATE,',');
ELSEIF (OLD.EDSH_CABLE_START_DATE IS NOT NULL AND NEW.EDSH_CABLE_START_DATE IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_CABLE_START_DATE=',OLD.EDSH_CABLE_START_DATE,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_CABLE_START_DATE=','<NULL>,');
ELSEIF (OLD.EDSH_CABLE_START_DATE!= NEW.EDSH_CABLE_START_DATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_CABLE_START_DATE=', OLD.EDSH_CABLE_START_DATE,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_CABLE_START_DATE=', NEW.EDSH_CABLE_START_DATE,','); 
END IF;
IF (OLD.EDSH_CABLE_END_DATE IS NULL AND NEW.EDSH_CABLE_END_DATE IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_CABLE_END_DATE=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_CABLE_END_DATE=',NEW.EDSH_CABLE_END_DATE,',');
ELSEIF (OLD.EDSH_CABLE_END_DATE IS NOT NULL AND NEW.EDSH_CABLE_END_DATE IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_CABLE_END_DATE=',OLD.EDSH_CABLE_END_DATE,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_CABLE_END_DATE=','<NULL>,');
ELSEIF (OLD.EDSH_CABLE_END_DATE!= NEW.EDSH_CABLE_END_DATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_CABLE_END_DATE=', OLD.EDSH_CABLE_END_DATE,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_CABLE_END_DATE=', NEW.EDSH_CABLE_END_DATE,','); 
END IF;
IF (OLD.EDSH_INTERNET_START_DATE IS NULL AND NEW.EDSH_INTERNET_START_DATE IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_INTERNET_START_DATE=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_INTERNET_START_DATE=',NEW.EDSH_INTERNET_START_DATE,',');
ELSEIF (OLD.EDSH_INTERNET_START_DATE IS NOT NULL AND NEW.EDSH_INTERNET_START_DATE IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_INTERNET_START_DATE=',OLD.EDSH_INTERNET_START_DATE,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_INTERNET_START_DATE=','<NULL>,');
ELSEIF (OLD.EDSH_INTERNET_START_DATE!= NEW.EDSH_INTERNET_START_DATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_INTERNET_START_DATE=', OLD.EDSH_INTERNET_START_DATE,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_INTERNET_START_DATE=', NEW.EDSH_INTERNET_START_DATE,','); 
END IF;
IF (OLD.EDSH_INTERNET_END_DATE IS NULL AND NEW.EDSH_INTERNET_END_DATE IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_INTERNET_END_DATE=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_INTERNET_END_DATE=',NEW.EDSH_INTERNET_END_DATE,',');
ELSEIF (OLD.EDSH_INTERNET_END_DATE IS NOT NULL AND NEW.EDSH_INTERNET_END_DATE IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_INTERNET_END_DATE=',OLD.EDSH_INTERNET_END_DATE,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_INTERNET_END_DATE=','<NULL>,');
ELSEIF (OLD.EDSH_INTERNET_END_DATE!= NEW.EDSH_INTERNET_END_DATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_INTERNET_END_DATE=', OLD.EDSH_INTERNET_END_DATE,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_INTERNET_END_DATE=', NEW.EDSH_INTERNET_END_DATE,','); 
END IF;
IF (OLD.EDSH_SSID IS NULL AND NEW.EDSH_SSID IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_SSID=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_SSID=',NEW.EDSH_SSID,',');
ELSEIF (OLD.EDSH_SSID IS NOT NULL AND NEW.EDSH_SSID IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_SSID=',OLD.EDSH_SSID,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_SSID=','<NULL>,');
ELSEIF (OLD.EDSH_SSID!= NEW.EDSH_SSID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_SSID=', OLD.EDSH_SSID,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_SSID=', NEW.EDSH_SSID,','); 
END IF;
IF (OLD.EDSH_PWD IS NULL AND NEW.EDSH_PWD IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_PWD=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_PWD=',NEW.EDSH_PWD,',');
ELSEIF (OLD.EDSH_PWD IS NOT NULL AND NEW.EDSH_PWD IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_PWD=',OLD.EDSH_PWD,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_PWD=','<NULL>,');
ELSEIF (OLD.EDSH_PWD!= NEW.EDSH_PWD) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_PWD=', OLD.EDSH_PWD,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_PWD=', NEW.EDSH_PWD,','); 
END IF;
IF (OLD.EDSH_CABLE_BOX_SERIAL_NO IS NULL AND NEW.EDSH_CABLE_BOX_SERIAL_NO IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_CABLE_BOX_SERIAL_NO=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_CABLE_BOX_SERIAL_NO=',NEW.EDSH_CABLE_BOX_SERIAL_NO,',');
ELSEIF (OLD.EDSH_CABLE_BOX_SERIAL_NO IS NOT NULL AND NEW.EDSH_CABLE_BOX_SERIAL_NO IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_CABLE_BOX_SERIAL_NO=',OLD.EDSH_CABLE_BOX_SERIAL_NO,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_CABLE_BOX_SERIAL_NO=','<NULL>,');
ELSEIF (OLD.EDSH_CABLE_BOX_SERIAL_NO!= NEW.EDSH_CABLE_BOX_SERIAL_NO) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_CABLE_BOX_SERIAL_NO=', OLD.EDSH_CABLE_BOX_SERIAL_NO,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_CABLE_BOX_SERIAL_NO=', NEW.EDSH_CABLE_BOX_SERIAL_NO,','); 
END IF;
IF (OLD.EDSH_MODEM_SERIAL_NO IS NULL AND NEW.EDSH_MODEM_SERIAL_NO IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_MODEM_SERIAL_NO=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_MODEM_SERIAL_NO=',NEW.EDSH_MODEM_SERIAL_NO,',');
ELSEIF (OLD.EDSH_MODEM_SERIAL_NO IS NOT NULL AND NEW.EDSH_MODEM_SERIAL_NO IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_MODEM_SERIAL_NO=',OLD.EDSH_MODEM_SERIAL_NO,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_MODEM_SERIAL_NO=','<NULL>,');
ELSEIF (OLD.EDSH_MODEM_SERIAL_NO!= NEW.EDSH_MODEM_SERIAL_NO) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_MODEM_SERIAL_NO=', OLD.EDSH_MODEM_SERIAL_NO,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_MODEM_SERIAL_NO=', NEW.EDSH_MODEM_SERIAL_NO,','); 
END IF;
IF (OLD.EDSH_BASIC_GROUP IS NULL AND NEW.EDSH_BASIC_GROUP IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_BASIC_GROUP=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_BASIC_GROUP=',NEW.EDSH_BASIC_GROUP,',');
ELSEIF (OLD.EDSH_BASIC_GROUP IS NOT NULL AND NEW.EDSH_BASIC_GROUP IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_BASIC_GROUP=',OLD.EDSH_BASIC_GROUP,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_BASIC_GROUP=','<NULL>,');
ELSEIF (OLD.EDSH_BASIC_GROUP!= NEW.EDSH_BASIC_GROUP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_BASIC_GROUP=', OLD.EDSH_BASIC_GROUP,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_BASIC_GROUP=', NEW.EDSH_BASIC_GROUP,','); 
END IF;
IF (OLD.EDSH_ADDTNL_CH IS NULL AND NEW.EDSH_ADDTNL_CH IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_ADDTNL_CH=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_ADDTNL_CH=',NEW.EDSH_ADDTNL_CH,',');
ELSEIF (OLD.EDSH_ADDTNL_CH IS NOT NULL AND NEW.EDSH_ADDTNL_CH IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_ADDTNL_CH=',OLD.EDSH_ADDTNL_CH,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_ADDTNL_CH=','<NULL>,');
ELSEIF (OLD.EDSH_ADDTNL_CH!= NEW.EDSH_ADDTNL_CH) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_ADDTNL_CH=', OLD.EDSH_ADDTNL_CH,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_ADDTNL_CH=', NEW.EDSH_ADDTNL_CH,','); 
END IF;
IF (OLD.EDSH_COMMENTS IS NULL AND NEW.EDSH_COMMENTS IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_COMMENTS=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_COMMENTS=',NEW.EDSH_COMMENTS,',');
ELSEIF (OLD.EDSH_COMMENTS IS NOT NULL AND NEW.EDSH_COMMENTS IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EDSH_COMMENTS=',OLD.EDSH_COMMENTS,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EDSH_COMMENTS=','<NULL>,');
ELSEIF (OLD.EDSH_COMMENTS!= NEW.EDSH_COMMENTS) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_COMMENTS=', OLD.EDSH_COMMENTS,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EDSH_COMMENTS=', NEW.EDSH_COMMENTS,','); 
END IF;
IF (OLD.UNIT_ID!= NEW.UNIT_ID) OR (OLD.ECN_ID IS NULL AND NEW.ECN_ID IS NOT NULL) OR (OLD.ECN_ID IS NOT NULL AND NEW.ECN_ID IS NULL) OR (OLD.ECN_ID!= NEW.ECN_ID) OR (OLD.EDSH_REC_VER!= NEW.EDSH_REC_VER) OR (OLD.EDSH_ACCOUNT_NO != NEW.EDSH_ACCOUNT_NO) OR (OLD.EDSH_APPL_DATE IS NULL AND NEW.EDSH_APPL_DATE IS NOT NULL) OR (OLD.EDSH_APPL_DATE IS NOT NULL AND NEW.EDSH_APPL_DATE IS NULL) OR  (OLD.EDSH_APPL_DATE!= NEW.EDSH_APPL_DATE) OR (OLD.EDSH_CABLE_START_DATE IS NULL AND NEW.EDSH_CABLE_START_DATE IS NOT NULL) OR (OLD.EDSH_CABLE_START_DATE IS NOT NULL AND NEW.EDSH_CABLE_START_DATE IS NULL) OR (OLD.EDSH_CABLE_START_DATE!= NEW.EDSH_CABLE_START_DATE) OR (OLD.EDSH_CABLE_END_DATE IS NULL AND NEW.EDSH_CABLE_END_DATE IS NOT NULL) OR (OLD.EDSH_CABLE_END_DATE IS NOT NULL AND NEW.EDSH_CABLE_END_DATE IS NULL) OR (OLD.EDSH_CABLE_END_DATE!= NEW.EDSH_CABLE_END_DATE) OR (OLD.EDSH_INTERNET_START_DATE IS NULL AND NEW.EDSH_INTERNET_START_DATE IS NOT NULL) OR (OLD.EDSH_INTERNET_START_DATE IS NOT NULL AND NEW.EDSH_INTERNET_START_DATE IS NULL) OR (OLD.EDSH_INTERNET_START_DATE!= NEW.EDSH_INTERNET_START_DATE) OR (OLD.EDSH_INTERNET_END_DATE IS NULL AND NEW.EDSH_INTERNET_END_DATE IS NOT NULL) OR (OLD.EDSH_INTERNET_END_DATE IS NOT NULL AND NEW.EDSH_INTERNET_END_DATE IS NULL) OR (OLD.EDSH_INTERNET_END_DATE!= NEW.EDSH_INTERNET_END_DATE) OR (OLD.EDSH_SSID IS NULL AND NEW.EDSH_SSID IS NOT NULL) OR (OLD.EDSH_SSID IS NOT NULL AND NEW.EDSH_SSID IS NULL) OR (OLD.EDSH_SSID!= NEW.EDSH_SSID) OR (OLD.EDSH_PWD IS NULL AND NEW.EDSH_PWD IS NOT NULL) OR (OLD.EDSH_PWD IS NOT NULL AND NEW.EDSH_PWD IS NULL) OR (OLD.EDSH_PWD!= NEW.EDSH_PWD) OR (OLD.EDSH_CABLE_BOX_SERIAL_NO IS NULL AND NEW.EDSH_CABLE_BOX_SERIAL_NO IS NOT NULL) OR (OLD.EDSH_CABLE_BOX_SERIAL_NO IS NOT NULL AND NEW.EDSH_CABLE_BOX_SERIAL_NO IS NULL) OR (OLD.EDSH_CABLE_BOX_SERIAL_NO!= NEW.EDSH_CABLE_BOX_SERIAL_NO) OR (OLD.EDSH_MODEM_SERIAL_NO IS NULL AND NEW.EDSH_MODEM_SERIAL_NO IS NOT NULL) OR (OLD.EDSH_MODEM_SERIAL_NO IS NOT NULL AND NEW.EDSH_MODEM_SERIAL_NO IS NULL) OR (OLD.EDSH_MODEM_SERIAL_NO!= NEW.EDSH_MODEM_SERIAL_NO) OR (OLD.EDSH_BASIC_GROUP IS NULL AND NEW.EDSH_BASIC_GROUP IS NOT NULL) OR (OLD.EDSH_BASIC_GROUP IS NOT NULL AND NEW.EDSH_BASIC_GROUP IS NULL) OR (OLD.EDSH_BASIC_GROUP!= NEW.EDSH_BASIC_GROUP) OR (OLD.EDSH_ADDTNL_CH IS NULL AND NEW.EDSH_ADDTNL_CH IS NOT NULL) OR (OLD.EDSH_ADDTNL_CH IS NOT NULL AND NEW.EDSH_ADDTNL_CH IS NULL) OR (OLD.EDSH_ADDTNL_CH!= NEW.EDSH_ADDTNL_CH) OR (OLD.EDSH_COMMENTS IS NULL AND NEW.EDSH_COMMENTS IS NOT NULL) OR (OLD.EDSH_COMMENTS IS NOT NULL AND NEW.EDSH_COMMENTS IS NULL) OR (OLD.EDSH_COMMENTS!= NEW.EDSH_COMMENTS) THEN  
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.EDSH_TIMESTAMP!= NEW.EDSH_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EDSH_TIMESTAMP=', OLD.EDSH_TIMESTAMP,','); 
END IF;
END IF;
IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
IF(OLD_VALUE != NEW_VALUE)THEN
     SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
     SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM EXPENSE_DETAIL_STARHUB WHERE EDSH_ID=NEW.EDSH_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EXPENSE_DETAIL_STARHUB'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;