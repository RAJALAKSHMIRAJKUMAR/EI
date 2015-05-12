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
	DECLARE OLDCARD INTEGER(7);
	DECLARE OLDINVENTORY CHAR(1);
	DECLARE OLDLOST CHAR(1);
	DECLARE OLDACTIVE CHAR(1);
	DECLARE OLDROOMTYPEID INTEGER;
	DECLARE OLDEPNCNUMBER INTEGER;
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE NEWROOMTYPEID INTEGER;
	DECLARE NEWSTAMPDUTYTYPEID INTEGER;
	DECLARE ACCESS_CHKTRANS_FLAG INTEGER;
	DECLARE ROOMTYPE_CHKTRANS_FLAG INTEGER;
	DECLARE OLDLOST_CHKTRANS_FLAG INTEGER;
	DECLARE NEWINVENTORY_CHKTRANS_FLAG INTEGER;
	DECLARE OLDACTIVE_FLAG INTEGER;
	DECLARE EPNC_FLAG INTEGER;
	DECLARE ACTIVE CHAR(1);
	DECLARE DELETEFLAG INTEGER;
	DECLARE INVENTORYLOSTFLAG INTEGER;
	DECLARE CACD_UASDID INTEGER;
	DECLARE CTD_UASDID INTEGER;
	DECLARE EMP_UASDID INTEGER;
	DECLARE CED_UASDID INTEGER;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		SET FLAG = 0;
		ROLLBACK; 
	END;
	SET OLDCARD = (SELECT UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=UASDID);
	SET OLDACTIVE = (SELECT UASD_ACCESS_ACTIVE FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=UASDID);
	SET OLDINVENTORY = (SELECT UASD_ACCESS_INVENTORY FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=UASDID);
	SET OLDLOST = (SELECT UASD_ACCESS_LOST FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=UASDID);
	SET OLDROOMTYPEID = (SELECT URTD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=UASDID);
	SET NEWROOMTYPEID = (SELECT URTD_ID FROM UNIT_ROOM_TYPE_DETAILS WHERE URTD_ROOM_TYPE = ROOMTYPE);
	SET NEWSTAMPDUTYTYPEID = (SELECT USDT_ID FROM UNIT_STAMP_DUTY_TYPE WHERE USDT_DATA = STAMPDUTYTYPE);
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
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
	IF(OLDCARD IS NOT NULL AND NEW_ACCESSCARD IS NULL) THEN
		SET CACD_UASDID = (SELECT COUNT(UASD_ID) FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID = UASDID);
		SET CTD_UASDID = (SELECT COUNT(UASD_ID) FROM CUSTOMER_LP_DETAILS WHERE UASD_ID = UASDID);
		SET EMP_UASDID = (SELECT COUNT(UASD_ID) FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID = UASDID);
		SET OLDEPNCNUMBER = (SELECT COUNT(EPNC_NUMBER) FROM EXPENSE_PURCHASE_NEW_CARD WHERE EPNC_NUMBER = OLDCARD);
	END IF;
	IF(OLDROOMTYPEID IS NOT NULL AND NEWROOMTYPEID IS NULL)THEN
		SET CED_UASDID = (SELECT COUNT(UASD_ID) FROM CUSTOMER_ENTRY_DETAILS WHERE UASD_ID = UASDID);
		IF(CED_UASDID!=0)THEN
			SET ROOMTYPE_CHKTRANS_FLAG = 0;
		ELSE
			SET ROOMTYPE_CHKTRANS_FLAG = 1;
		END IF;
	END IF;	
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
	SET @OLDEPNCNO = (SELECT COUNT(EPNC_NUMBER) FROM EXPENSE_PURCHASE_NEW_CARD WHERE EPNC_NUMBER = OLDCARD);	
	IF(@OLDEPNCNO IS NOT NULL AND NEW_ACCESSCARD IS NULL)THEN
		SET EPNC_FLAG = 0;
	ELSE
		SET EPNC_FLAG = 1;
	END IF;
	IF(ACCESS_CHKTRANS_FLAG = 1 AND ROOMTYPE_CHKTRANS_FLAG = 1 AND OLDLOST_CHKTRANS_FLAG = 1
	AND NEWINVENTORY_CHKTRANS_FLAG = 1 AND OLDACTIVE_FLAG = 1 AND EPNC_FLAG = 1 AND DELETEFLAG = 1 AND INVENTORYLOSTFLAG=1)THEN
		IF(NEW_ACCESSCARD IS NOT NULL OR ROOMTYPE IS NOT NULL OR STAMPDUTYDATE IS NOT NULL OR STAMPDUTYTYPE IS NOT NULL OR STAMPDUTYAMOUNT IS NOT NULL OR COMMENTS IS NOT NULL)THEN
			UPDATE UNIT_ACCESS_STAMP_DETAILS SET USDT_ID = NEWSTAMPDUTYTYPEID ,
			UASD_STAMPDUTYDATE = STAMPDUTYDATE, UASD_STAMPDUTYAMT = STAMPDUTYAMOUNT,
			UASD_ACCESS_CARD = NEW_ACCESSCARD , UASD_ACCESS_INVENTORY = INVENTORYFLAG,
			UASD_ACCESS_LOST = LOSTFLAG , URTD_ID = NEWROOMTYPEID , UASD_COMMENTS = COMMENTS,
			ULD_ID = USERSTAMP_ID WHERE UASD_ID=UASDID AND UNIT_ID = (SELECT UNIT_ID
			FROM UNIT WHERE UNIT_NO = UNIT_NUMBER);
			SET FLAG = 1;
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
	IF(DELETEFLAG = 0 AND ACCESS_CHKTRANS_FLAG=1 AND ROOMTYPE_CHKTRANS_FLAG=1)THEN
		CALL SP_SINGLE_TABLE_ROW_DELETION(6,UASDID,USERSTAMP,@FLAG);
		SET FLAG = 1;
	END IF;
COMMIT;
END;