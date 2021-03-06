-->VERSION 1.1-STARTDATE:11/07/2014 ENDDATE:11/07/2014-->ISSUE NO:345 DESC:APPLIED ULD_MAXTIMES UPDATION WILE UPDATION IN ENTRY,PERSONAL DETAILS TABLE. BY SAFI
--> version 1.0-->startdate:17/06/2014  enddate:18/06/2014 -->issueno:738 COMMENT:22 -->desc:ADDED ULD_ID AND TIMESTAMP IN TICKLER_HISTORY TABLE OLD_VALUE-->doneby:DHIVYA.A
--> version 0.9-->startdate:03/05/2014  enddate:03/05/2014 -->issueno:817 -->desc:CHANGED TICKLER PART FOR UPDATING REASON IN CUSTOMER_ACCESS_CARD_DETAILS -->doneby:DHIVYA.A
--version 0.8 startdate:8/04/2014 --enddate:8/4/2014--- issueno 754 commentno:36-->desc: CHANGED POST AUDIT PROFILE-SAFI
--version 0.7 startdate:28/02/2014 --enddate:28/02/2014--- issueno 754 commentno:36-->desc: APPLIED SUB_SP TO REPLACE USERSTAMP AS ID-SAFI

--version 0.6 startdate:27/02/2014 --enddate:27/02/2014--- issueno 754 commentno:22-->desc: REPLACE USERSTAMP DATATYPE AS INT-SAFI
--version 0.5 startdate:26/02/2014 --enddate:26/02/2014--- issueno 750 commentno:36-->desc: REPLACE USERSTAMP TO ULD_ID
--> version 0.4-->startdate:18/02/2014  enddate:19/02/2014-->issueno:636 comment no:#47-->desc:UPDATED TICKLER AND RETURN FLAG
-->doneby:SAFI.M
--> version 0.3-->startdate:11/11/2013  enddate:11/11/2013-->issueno:636 comment no:#47-->desc:changed sp name
-->doneby:DHIVYA.A
--> version 0.2-->startdate:11/10/2013  enddate:11/10/2013-->issueno:636 -->desc:added comments
-->doneby:DHIVYA.A
--->version 0.1 issue no:348 comment no:#23 ,start date :03/09/2013 end date:11/09/2013 desc:SP for access_card search and update done by:DHIVYA.A
DROP PROCEDURE IF EXISTS SP_ACCESS_CARD_UPDATE;
CREATE PROCEDURE SP_ACCESS_CARD_UPDATE(IN CUSTOMERID INTEGER,IN CARDNUMBER INTEGER,IN REASON TEXT,IN COMMENTS TEXT,IN USERSTAMP VARCHAR(50),OUT CARD_UPDATE_FLAG INTEGER)
BEGIN
DECLARE TICK_COMMENTS_OLD_VALUE TEXT;
DECLARE TICK_COMMENTS_NEW_VALUE TEXT;
DECLARE TICK_ACCESS_OLD_VALUE TEXT;
DECLARE TICK_ACCESS_NEW_VALUE TEXT;
DECLARE OLD_COMMENTS TEXT;
DECLARE OLD_ACN_ID INTEGER;
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE NEW_ACN_ID INTEGER;
DECLARE ULDID INTEGER;
DECLARE CPDID INTEGER;
DECLARE CACDID INTEGER;
DECLARE MINRECVER INTEGER;
DECLARE MAXRECVER INTEGER;
DECLARE CACDTIMESTAMP TIMESTAMP;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK; 
END; 
START TRANSACTION;
SET CARD_UPDATE_FLAG=0;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID =(SELECT @ULDID);
SET OLD_COMMENTS=(SELECT CPD_COMMENTS FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
SET CPDID=(SELECT CPD_ID FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
IF OLD_COMMENTS IS NULL THEN
	SET OLD_COMMENTS='NULL';
END IF;
IF COMMENTS IS NULL THEN
	SET COMMENTS='NULL';
END IF;
IF(OLD_COMMENTS!=COMMENTS)THEN
SET TICK_COMMENTS_OLD_VALUE=(SELECT CONCAT('CPD_ID=',CPDID,',CPD_COMMENTS=',OLD_COMMENTS));
SET TICK_COMMENTS_NEW_VALUE=(SELECT CONCAT('CPD_COMMENTS=',COMMENTS));
INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_PERSONAL_DETAILS'),TICK_COMMENTS_OLD_VALUE,TICK_COMMENTS_NEW_VALUE,USERSTAMP_ID,CUSTOMERID);
SET MINRECVER=(SELECT MIN(CED_REC_VER) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNUMBER));
SET MAXRECVER=(SELECT MAX(CED_REC_VER) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNUMBER));
IF MINRECVER IS NOT NULL THEN
WHILE(MAXRECVER>=MINRECVER)DO
CALL SP_CUSTOMER_LP_DETAILS_ULD_TS_MAXTIMES(CUSTOMERID,MINRECVER,USERSTAMP_ID);
SET MINRECVER=MINRECVER+1;
END WHILE;
END IF;
END IF;
IF(COMMENTS='NULL')THEN
SET COMMENTS=NULL;
END IF;
UPDATE CUSTOMER_PERSONAL_DETAILS SET CPD_COMMENTS=COMMENTS WHERE CUSTOMER_ID=CUSTOMERID;
SET CARD_UPDATE_FLAG=1;
SET CACDID=(SELECT CACD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND UASD_ID IN (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNUMBER) AND  ACN_ID!=4 );
SET ULDID=(SELECT ULD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND UASD_ID IN (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNUMBER) AND  ACN_ID!=4 );
SET CACDTIMESTAMP=(SELECT CACD_TIMESTAMP FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND UASD_ID IN (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNUMBER) AND  ACN_ID!=4 );
SET OLD_ACN_ID=(SELECT ACN_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND UASD_ID IN (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNUMBER) AND  ACN_ID!=4 );
SET NEW_ACN_ID=(SELECT ACN_ID FROM ACCESS_CONFIGURATION WHERE ACN_DATA=REASON);
IF OLD_ACN_ID!=NEW_ACN_ID THEN
IF ULDID!=USERSTAMP_ID THEN
SET TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',CACDID,',UASD_ID=',(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNUMBER),',ACN_ID=',(SELECT ACN_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND UASD_ID IN (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNUMBER) AND  ACN_ID!=4 ),',ULD_ID=',ULDID,',CACD_TIMESTAMP=',CACDTIMESTAMP));
ELSE
SET TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',CACDID,',UASD_ID=',(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNUMBER),',ACN_ID=',(SELECT ACN_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND UASD_ID IN (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNUMBER) AND  ACN_ID!=4 ),',CACD_TIMESTAMP=',CACDTIMESTAMP));
END IF;
SET TICK_ACCESS_NEW_VALUE=(SELECT CONCAT('ACN_ID=',(SELECT ACN_ID FROM ACCESS_CONFIGURATION WHERE ACN_DATA=REASON)));
INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ACCESS_CARD_DETAILS'),TICK_ACCESS_OLD_VALUE,TICK_ACCESS_NEW_VALUE,USERSTAMP_ID,CUSTOMERID);
UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET ACN_ID=(SELECT ACN_ID FROM ACCESS_CONFIGURATION WHERE ACN_DATA=REASON),ULD_ID=USERSTAMP_ID WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARDNUMBER)AND CUSTOMER_ID=CUSTOMERID AND ACN_ID!=4; 
SET CARD_UPDATE_FLAG=1;
END IF;
COMMIT; 
END;