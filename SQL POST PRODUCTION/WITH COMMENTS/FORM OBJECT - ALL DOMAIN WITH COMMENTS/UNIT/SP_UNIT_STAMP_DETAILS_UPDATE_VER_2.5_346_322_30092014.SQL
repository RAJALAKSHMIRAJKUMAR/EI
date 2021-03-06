-- version 2.5 --sadte:30/09/2014 --edate:30/09/2014 --issue:346 --commentno:322 --desc:ADDED CONDITION WHEN UPDATING LOST_FLAG AS 'X' FOR A CARD. IF THAT CARD EMPLOYEE USED,CARD REMOVED IN EMPLOYEE_CARD_DETAILS  -- doneby:DHIVYA
-- version 2.4 --sadte:31/07/2014 --edate:31/07/2014 --issue:835 --commentno:3 --desc:implementing auto commit  -- doneby:RL
--VER 2.3 STARTDATE:18/06/2014 ENDDATE:19/06/2014 ISSUENO:666 COMMENTNO:#40 DESC:ADDED CONDITION FOR WHEN THE OLD_CARD IS NULL AND NEW_CARD IS NULL DONE BY:DHIVYA
--VER 2.2 STARTDATE:04/04/2014 ENDDATE:04/04/2014 ISSUENO:797 COMMENTNO:#4 DESC:REPLACED HEADER ND TABLE NAME DONE BY:LALITHA
--version 2.1 --sdate:06/03/2014 --edate:10/03/2014 --issue:666 --comment:28 --desc:WHILE TESTING LOST CARD UPDATED INTO INVENTORY CARD WHICH THE CARD IS TRANSACTION AND ALSO ROOMTYPE UPDATED AS NULL WHICH IS IN TRANSACTIONSHLD NOT UPDATE ON THAT TIME WHILE IN TRANSACTION  --doneby:RL	
--version 2.0 --sdate:01/03/2014 --edate:05/03/2014 --issue:666 --comment:18,23 --desc: LOST CARD CAN BE UPDATE AS INVENTORY WHEN THE CARD IS NO TRANSACTION(REASON: WE CANT UPDATE THE REASON WHILE THE CARD VE TRANSACTION) CARD CAN BE MAKE AS NULL WHEN THE CARD HAS NO TRANSACTION AND CARD SHLD BE NOT LOST CARD--doneby:RL	
--version 1.9 --sdate:28/02/2014 --edate:28/02/2014 --issue:754 --comment:36 --desc:changed userstamp data type as varchar(50) --doneby:RL	
--version 1.8 --sdate:27/02/2014 --edate:27/02/2014 --issue:754 --comment:22 --desc:userstamp changed as uld_id --doneby:RL	
--version 1.7  --doneby:SL
--version 1.6 --sdate:14/02/2014 --edate:14/02/2014 --issue:666 --commentno#5 --desc:return flag & add one condition if comments is null then set null n include tikcler part for deletion--doneby:RL
-->version 1.5 -->done by SARADAMBAL -->startdate:21/01/2014 -->enddate:21/01/2014 -->issueno:596  COMMENT NO:#18---->DESC:IMPLEMENT NULL CAN BE UPDATE FOR ACCESS CARD
-->version 1.4 -->done by RL -->startdate:03/12/2013 -->enddate:03/12/2013 -->issueno:666  
-->version 1.3 -->done by RL -->startdate:29/11/2013 -->enddate:30/11/2013 -->issueno:346 commentno:#157 
-->version 1.2 -->done by DHIVYA.A -->startdate:25/11/2013 -->enddate:25/11/2013 -->issueno:346 commentno:#148,151 -->desc:added lostflag as input and removed comments is null condition.
-->version 1.1 -->done by DINESH.M -->startdate:21/11/2013 -->enddate:21/11/2013 -->issueno:253 commentno:#111 -->desc:changed DATA TYPE (INTEGER (7)) FOR NEW_ACCESSCARD AND OLD_ACCESSCARD.
-->version 1.0 -->done by DINESH.M -->startdate:20/11/2013 -->enddate:20/11/2013 -->issueno:253 commentno:#111 -->desc:changed DATA TYPE (INTEGER) FOR NEW_ACCESSCARD
--version 0.9 --modify by:DHIVYA.A --startdate:07-11-2013 --enddate:07-11-2013 --issueno:636--commentno:#47 --desc:CHANGED SP NAME
--version 0.8 --modify by:rajalakshmi.r --startdate:05-11-2013 --enddate:06-11-2013 --issueno:346 , 387 --commentno:133,117,142 --desc:UPDATE THE PURCHASE OF ACCESS CARD TABLE WHEN WE UPDATE THE CARD IN THE UNIT FORMS
--version 0.7 --done by:rajalakshmi.r --startdate:2013-08-14 --enddate:2013-08-14 --issueno:346 --commentno:64
--version :0.6 --startdate:13-08-2013 --enddate:13-08-2013 --done by :rajalakshmi.r --issue:592 
--version :0.5 --startdate:31-07-2013 --enddate:01-08-2013 --done by :rajalakshmi.r --issue:346 --comment no:53
--version :0.4 --startdate:27-07-2013 --enddate:27-07-2013 --desc: remove the row which contains only null values which updating the table which contains only non mandatory headers.  --done by :rajalakshmi.r --issue:575
--version :0.3 --startdate:23-07-2013 --enddate:2013-07-23 --desc:implementing rollback & commit commands --done by :rajalakshmi.r --issue:566
--version 0.2 --created by:rajalakshmi --startdate:2013-07-11 --enddate:2013-07-12 --issueno:356 --desc:modify of unit access stamp details 
--version 0.1 --date:2013-05-10  --issueno:356 --desc:update values in unit access stamp details (unit search & update) --created by:loganathan
DROP PROCEDURE IF EXISTS SP_UNIT_STAMP_DETAILS_UPDATE;
CREATE PROCEDURE SP_UNIT_STAMP_DETAILS_UPDATE(
IN UNIT_NUMBER SMALLINT(4),
IN UASDID INTEGER,
IN NEW_ACCESSCARD INTEGER(7),
IN ROOMTYPE VARCHAR(30),
IN STAMPDUTYDATE VARCHAR(15),
IN STAMPDUTYTYPE CHAR(12),
IN STAMPDUTYAMOUNT DECIMAL(6,2),
IN COMMENTS TEXT,
IN USERSTAMP VARCHAR(50),
IN LOSTFLAG CHAR(1),
IN INVENTORYFLAG CHAR(1),
OUT FLAG INTEGER
)
BEGIN
-- VARIABLE DECLARATION
	DECLARE OLDCARD INTEGER(7);
	DECLARE OLDINVENTORY CHAR(1);
	DECLARE OLDLOST CHAR(1);
	DECLARE OLDACTIVE CHAR(1);
	DECLARE OLDROOMTYPEID INTEGER;
	DECLARE OLDEPNCNUMBER INTEGER;
-- VARIABLE DECLARATION
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE NEWROOMTYPEID INTEGER;
	DECLARE NEWSTAMPDUTYTYPEID INTEGER;
-- VARIABLE DECLARATION	
	DECLARE ACCESS_CHKTRANS_FLAG INTEGER;
	DECLARE ROOMTYPE_CHKTRANS_FLAG INTEGER;
	DECLARE OLDLOST_CHKTRANS_FLAG INTEGER;
	DECLARE NEWINVENTORY_CHKTRANS_FLAG INTEGER;
	DECLARE OLDACTIVE_FLAG INTEGER;
	DECLARE EPNC_FLAG INTEGER;
	DECLARE ACTIVE CHAR(1);
	DECLARE DELETEFLAG INTEGER;
	DECLARE INVENTORYLOSTFLAG INTEGER;
-- VARIABLE DECLARATION
	DECLARE CACD_UASDID INTEGER;
	DECLARE CTD_UASDID INTEGER;
	DECLARE EMP_UASDID INTEGER;
	DECLARE CED_UASDID INTEGER;
	DECLARE ECDID INTEGER;
-- QUERY FOR ROLLBACK COMMAND
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
		SET FLAG = 0;
	END;
-- QUERY FOR SET OLD VALUES FOR PASSING UASDID
	SET OLDCARD = (SELECT UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=UASDID);
	SET OLDACTIVE = (SELECT UASD_ACCESS_ACTIVE FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=UASDID);
	SET OLDINVENTORY = (SELECT UASD_ACCESS_INVENTORY FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=UASDID);
	SET OLDLOST = (SELECT UASD_ACCESS_LOST FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=UASDID);
	SET OLDROOMTYPEID = (SELECT URTD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=UASDID);
-- QUERY FOR GET URTD_ID  FOR PASSING ROOM TYPE VALUE
	SET NEWROOMTYPEID = (SELECT URTD_ID FROM UNIT_ROOM_TYPE_DETAILS WHERE URTD_ROOM_TYPE = ROOMTYPE);
-- QUERY FOR GET USDT_ID  FOR PASSING STAMP DUTY TYPE VALUE
	SET NEWSTAMPDUTYTYPEID = (SELECT USDT_ID FROM UNIT_STAMP_DUTY_TYPE WHERE USDT_DATA = STAMPDUTYTYPE);
-- QUERY FOR SET NULL FOR MANDATORY FIELDS	
	IF (NEW_ACCESSCARD = '' OR NEW_ACCESSCARD = NULL) THEN
		SET NEW_ACCESSCARD = NULL;
	END IF;
	IF (ROOMTYPE = '' OR ROOMTYPE = NULL) THEN
		SET ROOMTYPE = NULL;
	END IF;
	IF (STAMPDUTYTYPE = '' OR STAMPDUTYTYPE = NULL) THEN
		SET STAMPDUTYTYPE = NULL;
	END IF;
	IF (COMMENTS = '' OR COMMENTS = NULL) THEN
		SET COMMENTS = NULL;
	END IF;
-- QUERY FOR SET INITIAL VALUES FOR FLAG	
	SET AUTOCOMMIT = 0;
	START TRANSACTION;	
	SET FLAG = 0;
	SET ACCESS_CHKTRANS_FLAG = 1;
	SET ROOMTYPE_CHKTRANS_FLAG = 1;
	SET OLDLOST_CHKTRANS_FLAG = 1;
	SET NEWINVENTORY_CHKTRANS_FLAG = 1;
	SET OLDACTIVE_FLAG = 1;
	SET EPNC_FLAG = 1;
	SET DELETEFLAG = 1;
	SET INVENTORYLOSTFLAG = 1;
-- QUERY FOR CALL SP_CHANGE_USERSTAMP_AS_ULDID SP
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);

-- QUERY FOR CHECK UASDID HAVING TRANSACTION OR NOT (ACCESS CARD)	
	IF(OLDCARD IS NOT NULL AND NEW_ACCESSCARD IS NULL) THEN
		SET CACD_UASDID = (SELECT COUNT(UASD_ID) FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID = UASDID);
		SET CTD_UASDID = (SELECT COUNT(UASD_ID) FROM CUSTOMER_LP_DETAILS WHERE UASD_ID = UASDID);
		SET EMP_UASDID = (SELECT COUNT(UASD_ID) FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID = UASDID);
		SET OLDEPNCNUMBER = (SELECT COUNT(EPNC_NUMBER) FROM EXPENSE_PURCHASE_NEW_CARD WHERE EPNC_NUMBER = OLDCARD);
	END IF;
	-- QUERY FOR CHECK PASSING UASD_ID HAVING ANY TRANSACTION R NOT	(ROOMTYPE)	
	IF(OLDROOMTYPEID IS NOT NULL AND NEWROOMTYPEID IS NULL)THEN
		SET CED_UASDID = (SELECT COUNT(UASD_ID) FROM CUSTOMER_ENTRY_DETAILS WHERE UASD_ID = UASDID);
		IF(CED_UASDID!=0)THEN
			SET ROOMTYPE_CHKTRANS_FLAG = 0;
		ELSE
			SET ROOMTYPE_CHKTRANS_FLAG = 1;
		END IF;
	END IF;	
	-- QUERY FOR CHECK OLD ACTIVE FLAG	
	IF(OLDACTIVE IS NOT NULL AND (INVENTORYFLAG IS NOT NULL OR LOSTFLAG IS NOT NULL))THEN
		SET OLDACTIVE_FLAG = 0;
	ELSE
		SET OLDACTIVE_FLAG = 1;
	END IF;
	
	IF(OLDCARD IS NOT NULL AND NEW_ACCESSCARD IS NULL) THEN
		IF((CACD_UASDID!=0 AND CTD_UASDID!=0) OR (EMP_UASDID!=0 OR OLDEPNCNUMBER!=0))THEN
			SET ACCESS_CHKTRANS_FLAG = 0;
		ELSE
			SET ACCESS_CHKTRANS_FLAG = 1;
			SET INVENTORYFLAG = NULL;
			SET LOSTFLAG = NULL;
			SET ACTIVE = NULL;
			IF ROOMTYPE IS NULL THEN
				IF ROOMTYPE_CHKTRANS_FLAG=1 THEN
				UPDATE UNIT_ACCESS_STAMP_DETAILS SET USDT_ID = NEWSTAMPDUTYTYPEID ,
				UASD_STAMPDUTYDATE = STAMPDUTYDATE, UASD_STAMPDUTYAMT = STAMPDUTYAMOUNT,
				UASD_ACCESS_CARD = NEW_ACCESSCARD , UASD_ACCESS_INVENTORY = INVENTORYFLAG,
				UASD_ACCESS_LOST = LOSTFLAG ,UASD_ACCESS_ACTIVE=ACTIVE, URTD_ID = NEWROOMTYPEID , UASD_COMMENTS = COMMENTS,
				ULD_ID = USERSTAMP_ID WHERE UASD_ID=UASDID AND UNIT_ID = (SELECT UNIT_ID
				FROM UNIT WHERE UNIT_NO = UNIT_NUMBER);
				SET FLAG = 1;
				END IF;
			
			ELSE
				
					UPDATE UNIT_ACCESS_STAMP_DETAILS SET USDT_ID = NEWSTAMPDUTYTYPEID ,
					UASD_STAMPDUTYDATE = STAMPDUTYDATE, UASD_STAMPDUTYAMT = STAMPDUTYAMOUNT,
					UASD_ACCESS_CARD = NEW_ACCESSCARD , UASD_ACCESS_INVENTORY = INVENTORYFLAG,
					UASD_ACCESS_LOST = LOSTFLAG ,UASD_ACCESS_ACTIVE=ACTIVE, URTD_ID = NEWROOMTYPEID , UASD_COMMENTS = COMMENTS,
					ULD_ID = USERSTAMP_ID WHERE UASD_ID=UASDID AND UNIT_ID = (SELECT UNIT_ID
					FROM UNIT WHERE UNIT_NO = UNIT_NUMBER);
			
			SET FLAG = 1;
		
			END IF;
		END IF;
	END IF;


-- QUERY FOR CHECK LOST FLAG	
	IF(OLDCARD IS NOT NULL AND NEW_ACCESSCARD IS NULL AND OLDLOST IS NOT NULL)THEN
		SET CACD_UASDID = (SELECT COUNT(UASD_ID) FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID = UASDID);
		SET CTD_UASDID = (SELECT COUNT(UASD_ID) FROM CUSTOMER_LP_DETAILS WHERE UASD_ID = UASDID);
		SET EMP_UASDID = (SELECT COUNT(UASD_ID) FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID = UASDID);
		SET OLDEPNCNUMBER = (SELECT COUNT(EPNC_NUMBER) FROM EXPENSE_PURCHASE_NEW_CARD WHERE EPNC_NUMBER = OLDCARD);
		IF((CACD_UASDID!=0 AND CTD_UASDID!=0) OR (EMP_UASDID!=0 OR OLDEPNCNUMBER!=0))THEN
			SET OLDLOST_CHKTRANS_FLAG = 0;
		ELSE
			SET OLDLOST_CHKTRANS_FLAG = 1;
		END IF;
	END IF;
	
-- QUERY FOR CHECK OLD LOST FLAG	
	IF(OLDLOST IS NOT NULL AND INVENTORYFLAG IS NOT NULL)THEN
		SET CACD_UASDID = (SELECT COUNT(UASD_ID) FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID = UASDID);
		SET CTD_UASDID = (SELECT COUNT(UASD_ID) FROM CUSTOMER_LP_DETAILS WHERE UASD_ID = UASDID);
		IF(CACD_UASDID!=0 AND CTD_UASDID!=0) THEN
			SET NEWINVENTORY_CHKTRANS_FLAG = 0;
		ELSE
			SET NEWINVENTORY_CHKTRANS_FLAG = 1;
		END IF;
	END IF;
	
	IF(INVENTORYFLAG IS NOT NULL AND LOSTFLAG IS NOT NULL)THEN
		SET INVENTORYLOSTFLAG = 0;
	ELSE
		SET INVENTORYLOSTFLAG = 1;
	END IF;
	
-- QUERY FOR CHECK PURCHASE CARD 
	SET @OLDEPNCNO = (SELECT COUNT(EPNC_NUMBER) FROM EXPENSE_PURCHASE_NEW_CARD WHERE EPNC_NUMBER = OLDCARD);	
	IF(@OLDEPNCNO IS NOT NULL AND NEW_ACCESSCARD IS NULL)THEN
		SET EPNC_FLAG = 0;
	ELSE
		SET EPNC_FLAG = 1;
	END IF;
	
	IF(ACCESS_CHKTRANS_FLAG = 1 AND ROOMTYPE_CHKTRANS_FLAG = 1 AND OLDLOST_CHKTRANS_FLAG = 1
	AND NEWINVENTORY_CHKTRANS_FLAG = 1 AND OLDACTIVE_FLAG = 1 AND EPNC_FLAG = 1 AND DELETEFLAG = 1 AND INVENTORYLOSTFLAG=1)THEN
		IF(NEW_ACCESSCARD IS NOT NULL OR ROOMTYPE IS NOT NULL OR STAMPDUTYDATE IS NOT NULL OR STAMPDUTYTYPE IS NOT NULL OR STAMPDUTYAMOUNT IS NOT NULL OR COMMENTS IS NOT NULL)THEN
-- QUERY FOR UPDATE VALUES IN UNIT_ACCESS_STAMP_DETAILS TABLE	
			UPDATE UNIT_ACCESS_STAMP_DETAILS SET USDT_ID = NEWSTAMPDUTYTYPEID ,
			UASD_STAMPDUTYDATE = STAMPDUTYDATE, UASD_STAMPDUTYAMT = STAMPDUTYAMOUNT,
			UASD_ACCESS_CARD = NEW_ACCESSCARD , UASD_ACCESS_INVENTORY = INVENTORYFLAG,
			UASD_ACCESS_LOST = LOSTFLAG , URTD_ID = NEWROOMTYPEID , UASD_COMMENTS = COMMENTS,
			ULD_ID = USERSTAMP_ID WHERE UASD_ID=UASDID AND UNIT_ID = (SELECT UNIT_ID
			FROM UNIT WHERE UNIT_NO = UNIT_NUMBER);
			SET FLAG = 1;
-- QUERY FOR UPDATE VALUES IN EXPENSE_PURCHASE_NEW_CARD TABLE	
			UPDATE EXPENSE_PURCHASE_NEW_CARD SET EPNC_NUMBER = NEW_ACCESSCARD WHERE EPNC_NUMBER = OLDCARD;
			SET FLAG = 1;
		END IF;
	END IF;
	IF OLDCARD IS NULL AND NEW_ACCESSCARD IS NULL THEN
			IF ROOMTYPE IS NULL   THEN
				IF ROOMTYPE_CHKTRANS_FLAG=1 THEN
				UPDATE UNIT_ACCESS_STAMP_DETAILS SET USDT_ID = NEWSTAMPDUTYTYPEID ,
				UASD_STAMPDUTYDATE = STAMPDUTYDATE, UASD_STAMPDUTYAMT = STAMPDUTYAMOUNT,
				UASD_ACCESS_CARD = NEW_ACCESSCARD , UASD_ACCESS_INVENTORY = INVENTORYFLAG,
				UASD_ACCESS_LOST = LOSTFLAG ,UASD_ACCESS_ACTIVE=ACTIVE, URTD_ID = NEWROOMTYPEID , UASD_COMMENTS = COMMENTS,
				ULD_ID = USERSTAMP_ID WHERE UASD_ID=UASDID AND UNIT_ID = (SELECT UNIT_ID
				FROM UNIT WHERE UNIT_NO = UNIT_NUMBER);
				SET FLAG = 1;
				END IF;
			ELSE
				UPDATE UNIT_ACCESS_STAMP_DETAILS SET USDT_ID = NEWSTAMPDUTYTYPEID ,
				UASD_STAMPDUTYDATE = STAMPDUTYDATE, UASD_STAMPDUTYAMT = STAMPDUTYAMOUNT,
				UASD_ACCESS_CARD = NEW_ACCESSCARD , UASD_ACCESS_INVENTORY = INVENTORYFLAG,
				UASD_ACCESS_LOST = LOSTFLAG , URTD_ID = NEWROOMTYPEID , UASD_COMMENTS = COMMENTS,
				ULD_ID = USERSTAMP_ID WHERE UASD_ID=UASDID AND UNIT_ID = (SELECT UNIT_ID
				FROM UNIT WHERE UNIT_NO = UNIT_NUMBER);
				SET FLAG = 1;
				
			END IF;
			END IF;
	
	IF((NEW_ACCESSCARD IS NULL AND ROOMTYPE IS NULL AND STAMPDUTYDATE IS NULL AND STAMPDUTYTYPE IS NULL AND STAMPDUTYAMOUNT IS NULL) AND (COMMENTS IS NULL OR COMMENTS IS NOT NULL))THEN
		SET DELETEFLAG = 0;
	ELSE
		SET DELETEFLAG = 1;
	END IF;
-- QUERY FOR DELETE VALUES IN UNIT_ACCESS_STAMP_DETAILS TABLE	
	IF(DELETEFLAG = 0 AND ACCESS_CHKTRANS_FLAG=1 AND ROOMTYPE_CHKTRANS_FLAG=1)THEN
		CALL SP_SINGLE_TABLE_ROW_DELETION(6,UASDID,USERSTAMP,@FLAG);
		SET FLAG = 1;
	END IF;
	IF(LOSTFLAG='X' AND FLAG=1) THEN
		SET ECDID=(SELECT ECD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=UASDID);
		IF ECDID IS NOT NULL THEN
			CALL SP_CUSTOMER_ROW_DELETION(40,ECDID,USERSTAMP_ID);
		END IF;
	END IF;
COMMIT;
END;