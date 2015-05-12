DROP PROCEDURE IF EXISTS SP_EXISTING_UNIT_LOGIN_DETAILS_INSERT;
CREATE PROCEDURE SP_EXISTING_UNIT_LOGIN_DETAILS_INSERT(
IN UNITNO SMALLINT(4),
IN DOORCODE VARCHAR(10),
IN WEBLOGIN VARCHAR(20),
IN WEBPWD VARCHAR(6),
IN USERSTAMP VARCHAR(50),
OUT FLAG INTEGER)
BEGIN 
DECLARE OLDDOORCODE VARCHAR(10);
DECLARE OLDWEBLOGIN VARCHAR(20);
DECLARE OLDWEBPWD VARCHAR(6);
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK; 
END;
IF DOORCODE='' THEN 
SET DOORCODE=NULL;
END IF;
IF WEBLOGIN='' THEN
SET WEBLOGIN=NULL;
END IF;
IF WEBPWD='' THEN
SET WEBPWD=NULL;
END IF;
START TRANSACTION;
SET FLAG = 0;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);
SET OLDDOORCODE = (SELECT ULDTL_DOORCODE FROM UNIT_LOGIN_DETAILS WHERE UNIT_ID = (SELECT UNIT_ID FROM UNIT WHERE UNIT_NO = UNITNO));
SET OLDWEBLOGIN = (SELECT ULDTL_WEBLOGIN FROM UNIT_LOGIN_DETAILS WHERE UNIT_ID = (SELECT UNIT_ID FROM UNIT WHERE UNIT_NO = UNITNO));
SET OLDWEBPWD = (SELECT ULDTL_WEBPWD FROM UNIT_LOGIN_DETAILS WHERE UNIT_ID = (SELECT UNIT_ID FROM UNIT WHERE UNIT_NO = UNITNO));
SET DOORCODE=(SELECT(IF (OLDDOORCODE IS NOT NULL,OLDDOORCODE,DOORCODE)));
SET WEBLOGIN=(SELECT (IF (OLDWEBLOGIN IS NOT NULL,OLDWEBLOGIN,WEBLOGIN)));
SET WEBPWD=(SELECT (IF (OLDWEBPWD IS NOT NULL,OLDWEBPWD,WEBPWD)));
IF  EXISTS(SELECT UNIT_ID FROM UNIT_LOGIN_DETAILS WHERE UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO))THEN
UPDATE UNIT_LOGIN_DETAILS SET ULDTL_DOORCODE=DOORCODE,ULDTL_WEBLOGIN=WEBLOGIN,ULDTL_WEBPWD=WEBPWD,ULD_ID=USERSTAMP_ID WHERE UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO);
SET FLAG=1;
END IF;
IF NOT EXISTS(SELECT UNIT_ID FROM UNIT_LOGIN_DETAILS WHERE UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO))THEN
INSERT INTO UNIT_LOGIN_DETAILS (UNIT_ID,ULDTL_DOORCODE,ULDTL_WEBLOGIN,ULDTL_WEBPWD,ULD_ID)VALUES((SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNITNO),DOORCODE,WEBLOGIN,WEBPWD,USERSTAMP_ID);
SET FLAG = 1;
END IF;
COMMIT;
END;