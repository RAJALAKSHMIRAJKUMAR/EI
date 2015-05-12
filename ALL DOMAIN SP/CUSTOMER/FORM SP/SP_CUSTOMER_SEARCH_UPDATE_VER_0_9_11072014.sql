--version 0.9 startdate:11/07/2014 --enddate:11/07/2014---issue no:345 comment 729 desc:added sub sp for increment nooftimes and updateD uld_id in lp_details if any data changed in other tables .BY DHIVYA
--version 0.8 startdate:06/05/2014 --enddate:06/05/2014---did some corrections in company details uodation part.BY KUMAR R
--version 0.7 startdate:03/04/2014 --enddate:03/04/2014--- issueno 797 -->desc:REPLACED TABLENAME AND HEADERNAME done by:SASIKALA.D
--version 0.6 startdate:10/03/2014 --enddate:10/03/2014--- issueno 345 -->desc:changed condition for customer termination details table updation part done by:KUMAR R
--version 0.5 startdate:28/02/2014 --enddate:28/02/2014--- issueno 754 commentno:36-->desc:added sub sp to convert userstamp as uld_id done by:Dhivya 
-->version 0.4 -->start date:26/02/2014 end date:26/02/2014 -->issueno:750  -->description:UPDATING USERSTAMP TO ULD_ID -->created by:SAFI.M
-- version --> 0.3 startdate -->05/02/2014 enddate --> 05/02/2014 description -->CHANGED SP NAME DONE BY:DHIVYA.A -->issue :594 comment #83
-- version --> 0.2 startdate -->29/01/2014 enddate --> 30/01/2014 description -->UPDATED CUSTOMER ENTRY DETAILS AS PER STIME AND ETIME DATATYPE UPDATION DONE BY:DHIVYA.A -->issue :594 comment #71
--> version 0.1-->startdate:19/12/2013  enddate:21/12/2013-->issueno:345 commentno:#542 -->desc:SP FOR CUSTOMER UPDATION
-->doneby:KUMAR.R


DROP PROCEDURE IF EXISTS SP_CUSTOMER_SEARCH_UPDATE;
CREATE PROCEDURE SP_CUSTOMER_SEARCH_UPDATE
(
IN CUST_ID INTEGER,
IN FIRST_NAME CHAR(30),
IN LAST_NAME CHAR(30),
IN COMPANY_NAME    VARCHAR(50),
IN COMPANY_ADDRESS VARCHAR(50),
IN POSTAL_CODE VARCHAR(6),
IN OFFICE_NO VARCHAR(8),
IN UNIT_NUMBER INTEGER,
IN CUSTOMER_RECORD_VERSION INTEGER,
IN ROOM_TYPE VARCHAR(30),
IN SD_STIME    TIME,
IN SD_ETIME    TIME,
IN ED_STIME    TIME,
IN ED_ETIME    TIME,
IN LEASE_PERIOD    VARCHAR(30),
IN QUARTERS    DECIMAL(5,2),
IN PROCESSING_WAIVED CHAR(1),
IN PRORATED CHAR(1),
IN NOTICE_PERIOD TINYINT(1),
IN NOTICE_START_DATE DATE,
IN RENT DECIMAL(7,2),
IN DEPOSIT DECIMAL(7,2),
IN PROCESSING_FEE DECIMAL(7,2),
IN AIRCON_FIXED_FEE DECIMAL(7,2),
IN AIRCON_QUARTELY_FEE DECIMAL(7,2),
IN ELECTRICITY_CAP DECIMAL(7,2),
IN CHECKOUT_CLEANING_FEE DECIMAL(7,2),
IN DRYCLEAN_FEE DECIMAL(7,2),
IN USERSTAMP VARCHAR(50),
IN START_DATE DATE,
IN END_DATE DATE,
IN NATIONALITY TEXT,
IN MOBILE VARCHAR(8),
IN INTL_MOBILE VARCHAR(20),
IN EMAIL VARCHAR(40),
IN PASSPORT_NO VARCHAR(15),
IN PASSPORT_DATE DATE,
IN DOB DATE,
IN EP_NO VARCHAR(15),    
IN EP_DATE DATE,
IN COMMENTS TEXT,
IN ACCESS_CARD TEXT,
IN ACCESS_CARD_DATES TEXT,
OUT SUCCESS_FLAG INTEGER
)
BEGIN
DECLARE CCDID INTEGER; 
DECLARE ROOM_TYPE_ID INTEGER;
DECLARE NATIONALITY_ID INTEGER;
DECLARE CARD_VALID_FROM DATE;
DECLARE OLD_TEMP_ACCESS_CARD TEXT;
DECLARE OLD_ACCESS_CARD_NO VARCHAR(7);
DECLARE OLD_ACCESS_POSITION INTEGER;
DECLARE OLD_ACCESS_LOCATION INTEGER;
DECLARE OLD_ACCESS_LENGTH INTEGER;
DECLARE NEW_TEMP_ACCESS_CARD TEXT;
DECLARE NEW_ACCESS_POSITION INTEGER;
DECLARE NEW_ACCESS_LOCATION INTEGER;
DECLARE NEW_ACCESS_LENGTH INTEGER;
DECLARE NEW_GUEST_ACCESS_LENGTH INTEGER;
DECLARE NEW_GUEST_FLAG CHAR(1);
DECLARE ACCESS_CARD_FULL_LENGTH INTEGER;
DECLARE ACCESS_FULL_CARD VARCHAR(50);
DECLARE CARD_NO VARCHAR(10);
DECLARE CARD_STARTDATE VARCHAR(15);
DECLARE ACCESS_CARD_LENGTH INTEGER;
DECLARE TEMP_ACCESS_CARD TEXT;
DECLARE ACCESS_POSITION INTEGER;
DECLARE ACCESS_CARD_NO TEXT;
DECLARE ACCESS_LENGTH INTEGER;
DECLARE CARD_DATE_SPLIT INTEGER;
DECLARE ACCESSCARD_STARTDATE VARCHAR(12);
DECLARE ACCESSCARD_ENDDATE VARCHAR(12);
DECLARE TEMP_ACCESS_CARD_LENGTH INTEGER;
DECLARE CARDNO_POSITION INTEGER;
DECLARE CARDDATE_POSITION INTEGER;
DECLARE CARD_STARTDATE_POSITION INTEGER;
DECLARE CARD_ENDDATE_POSITION INTEGER;
DECLARE CARD_START_DATE VARCHAR(15);
DECLARE CARD_END_DATE VARCHAR(15);
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE AIRCONEXSISTID INT;
DECLARE AIRCONAMOUNT DECIMAL(7,2);
DECLARE AIRCONID INT;
DECLARE PTDDATE DATE;
DECLARE NOOFTIMES INT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
SET SUCCESS_FLAG=0;
END;
IF COMPANY_NAME='' THEN
SET COMPANY_NAME=NULL;
END IF;
IF COMPANY_ADDRESS='' THEN
SET COMPANY_ADDRESS=NULL;
END IF;
IF POSTAL_CODE='' THEN
SET POSTAL_CODE=NULL;
END IF;
IF OFFICE_NO='' THEN
SET OFFICE_NO=NULL;
END IF;
IF PROCESSING_WAIVED='' THEN
SET PROCESSING_WAIVED=NULL;
END IF;
IF PRORATED='' THEN
SET PRORATED=NULL;
END IF;
IF NOTICE_PERIOD='' THEN
SET NOTICE_PERIOD=NULL;
END IF;
IF MOBILE='' THEN
SET MOBILE=NULL;
END IF;
IF INTL_MOBILE='' THEN
SET INTL_MOBILE=NULL;
END IF;
IF PASSPORT_NO='' THEN
SET PASSPORT_NO=NULL;
END IF;
IF EP_NO='' THEN
SET EP_NO=NULL;
END IF;
SET SUCCESS_FLAG=0;
SET CCDID=(SELECT CCD_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=CUST_ID);
SET ROOM_TYPE_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE URTD_ID=(SELECT URTD_ID FROM UNIT_ROOM_TYPE_DETAILS WHERE URTD_ROOM_TYPE=ROOM_TYPE) AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER));
SET NATIONALITY_ID=(SELECT NC_ID FROM NATIONALITY_CONFIGURATION WHERE NC_DATA=NATIONALITY);
START TRANSACTION;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID=(SELECT @ULDID);
IF FIRST_NAME IS NOT NULL AND LAST_NAME IS NOT NULL THEN
UPDATE CUSTOMER SET CUSTOMER_FIRST_NAME=FIRST_NAME,CUSTOMER_LAST_NAME=LAST_NAME WHERE CUSTOMER_ID=CUST_ID;
SET SUCCESS_FLAG=1;
END IF;
IF EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=CUST_ID)THEN
UPDATE CUSTOMER_COMPANY_DETAILS SET CCD_COMPANY_NAME=COMPANY_NAME,CCD_COMPANY_ADDR=COMPANY_ADDRESS, CCD_POSTAL_CODE=POSTAL_CODE,CCD_OFFICE_NO=OFFICE_NO WHERE CUSTOMER_ID=CUST_ID;
SET SUCCESS_FLAG=1;
END IF;
IF NOT EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=CUST_ID)THEN
INSERT INTO CUSTOMER_COMPANY_DETAILS(CUSTOMER_ID,CCD_COMPANY_NAME,CCD_COMPANY_ADDR,CCD_POSTAL_CODE,CCD_OFFICE_NO) VALUES(CUST_ID,COMPANY_NAME,COMPANY_ADDRESS,POSTAL_CODE,OFFICE_NO);
SET SUCCESS_FLAG=1;
END IF;
IF(COMPANY_NAME IS NULL AND COMPANY_ADDRESS IS NULL AND POSTAL_CODE IS NULL AND OFFICE_NO IS NULL) THEN
DELETE FROM CUSTOMER_COMPANY_DETAILS WHERE CCD_ID=CCDID;
SET SUCCESS_FLAG=1;
END IF;
IF RENT IS NOT NULL THEN
UPDATE CUSTOMER_FEE_DETAILS SET CFD_AMOUNT=RENT WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER=CUSTOMER_RECORD_VERSION AND CPP_ID=1;
SET SUCCESS_FLAG=1;
END IF;
IF DEPOSIT IS NOT NULL THEN
IF EXISTS(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER=CUSTOMER_RECORD_VERSION AND CPP_ID=2) THEN
UPDATE CUSTOMER_FEE_DETAILS SET CFD_AMOUNT=DEPOSIT WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=2;
SET SUCCESS_FLAG=1;
END IF;
IF NOT EXISTS (SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=2) THEN
INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (CUST_ID,CUSTOMER_RECORD_VERSION,2,DEPOSIT);
SET SUCCESS_FLAG=1;
END IF;
ELSE
DELETE FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=2;
SET SUCCESS_FLAG=1;
END IF;
IF PROCESSING_FEE IS NOT NULL THEN
IF EXISTS(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=3) THEN
UPDATE CUSTOMER_FEE_DETAILS SET CFD_AMOUNT=PROCESSING_FEE WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=3;
SET SUCCESS_FLAG=1;
END IF;
IF NOT EXISTS (SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=3) THEN
INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (CUST_ID,CUSTOMER_RECORD_VERSION,3,PROCESSING_FEE);
SET SUCCESS_FLAG=1;
END IF;
ELSE
DELETE FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=3;
SET SUCCESS_FLAG=1;
END IF;
IF AIRCON_FIXED_FEE IS NOT NULL OR AIRCON_QUARTELY_FEE IS NOT NULL THEN
  SET AIRCONEXSISTID=(SELECT CFD_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER=CUSTOMER_RECORD_VERSION AND (CPP_ID=4 OR CPP_ID=7));
  IF AIRCON_FIXED_FEE IS NOT NULL THEN
	 SET AIRCONID=4;
	 SET AIRCONAMOUNT=AIRCON_FIXED_FEE;
  END IF;
  IF AIRCON_QUARTELY_FEE IS NOT NULL THEN
     SET AIRCONID=7;
	 SET AIRCONAMOUNT=AIRCON_QUARTELY_FEE;
  END IF;
  IF AIRCONEXSISTID IS NOT NULL THEN
     UPDATE CUSTOMER_FEE_DETAILS SET CFD_AMOUNT=AIRCONAMOUNT,CPP_ID=AIRCONID WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CFD_ID=AIRCONEXSISTID;
  ELSE
  	INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (CUST_ID,CUSTOMER_RECORD_VERSION,AIRCONID,AIRCONAMOUNT);
  END IF;      
ELSE
	DELETE FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=7;
	DELETE FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=4;
	SET SUCCESS_FLAG=1;
END IF;
IF ELECTRICITY_CAP IS NOT NULL THEN
IF EXISTS(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=5) THEN
UPDATE CUSTOMER_FEE_DETAILS SET CFD_AMOUNT=ELECTRICITY_CAP WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=5;
SET SUCCESS_FLAG=1;
END IF;
IF NOT EXISTS (SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=5) THEN
INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (CUST_ID,CUSTOMER_RECORD_VERSION,5,ELECTRICITY_CAP);
SET SUCCESS_FLAG=1;
END IF;
ELSE
DELETE FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=5;
SET SUCCESS_FLAG=1;
END IF;
IF DRYCLEAN_FEE IS NOT NULL THEN
IF EXISTS(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=6) THEN
UPDATE CUSTOMER_FEE_DETAILS SET CFD_AMOUNT=DRYCLEAN_FEE WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=6;
SET SUCCESS_FLAG=1;
END IF;
IF NOT EXISTS (SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=6) THEN
INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (CUST_ID,CUSTOMER_RECORD_VERSION,6,DRYCLEAN_FEE);
SET SUCCESS_FLAG=1;
END IF;
ELSE
DELETE FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=6;
SET SUCCESS_FLAG=1;
END IF;
IF CHECKOUT_CLEANING_FEE IS NOT NULL THEN
IF EXISTS(SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=8) THEN
UPDATE CUSTOMER_FEE_DETAILS SET CFD_AMOUNT = CHECKOUT_CLEANING_FEE WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=8;
SET SUCCESS_FLAG=1;
END IF;
IF NOT EXISTS (SELECT CPP_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=8) THEN
INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (CUST_ID,CUSTOMER_RECORD_VERSION,8,CHECKOUT_CLEANING_FEE);
SET SUCCESS_FLAG=1;
END IF;
ELSE
DELETE FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER= CUSTOMER_RECORD_VERSION AND CPP_ID=8;
SET SUCCESS_FLAG=1;
END IF;
IF ROOM_TYPE IS NOT NULL AND SD_STIME IS NOT NULL AND SD_ETIME IS NOT NULL AND ED_STIME IS NOT NULL AND ED_ETIME IS NOT NULL AND LEASE_PERIOD IS NOT NULL AND QUARTERS IS NOT NULL THEN
UPDATE CUSTOMER_ENTRY_DETAILS SET UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER),UASD_ID=ROOM_TYPE_ID,CED_SD_STIME=(SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=SD_STIME),CED_SD_ETIME=(SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=SD_ETIME),CED_ED_STIME= (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=ED_STIME),CED_ED_ETIME=(SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=ED_ETIME),CED_PROCESSING_WAIVED=PROCESSING_WAIVED,CED_PRORATED=PRORATED,CED_NOTICE_PERIOD = NOTICE_PERIOD,CED_NOTICE_START_DATE=NOTICE_START_DATE,CED_LEASE_PERIOD=LEASE_PERIOD,CED_QUARTERS=QUARTERS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER=CUSTOMER_RECORD_VERSION;
SET SUCCESS_FLAG=1;
END IF;
IF EMAIL IS NOT NULL AND NATIONALITY IS NOT NULL THEN
UPDATE CUSTOMER_PERSONAL_DETAILS SET NC_ID=NATIONALITY_ID,CPD_MOBILE=MOBILE,CPD_INTL_MOBILE=INTL_MOBILE,CPD_EMAIL=EMAIL,CPD_PASSPORT_NO=PASSPORT_NO,CPD_PASSPORT_DATE=PASSPORT_DATE,CPD_DOB=DOB,CPD_EP_NO=EP_NO,CPD_EP_DATE= EP_DATE,
CPD_COMMENTS=COMMENTS WHERE CUSTOMER_ID=CUST_ID;
SET SUCCESS_FLAG=1;
END IF;
SET PTDDATE=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER=CUSTOMER_RECORD_VERSION AND CLP_GUEST_CARD IS NULL);
IF ACCESS_CARD IS NOT NULL THEN
       SET TEMP_ACCESS_CARD = ACCESS_CARD;
       SET ACCESS_LENGTH=1;
   loop_label : LOOP
       SET CARDNO_POSITION=(SELECT LOCATE(',',TEMP_ACCESS_CARD,ACCESS_LENGTH));
       SET CARD_NO = (SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_LENGTH,CARDNO_POSITION-1));
       SET TEMP_ACCESS_CARD = (SELECT SUBSTRING(TEMP_ACCESS_CARD,CARDNO_POSITION+1));
       SET CARDDATE_POSITION = (SELECT LOCATE(',',TEMP_ACCESS_CARD,ACCESS_LENGTH));
            IF (CARDDATE_POSITION=0) THEN
                               SET CARD_STARTDATE = TEMP_ACCESS_CARD;
                       ELSE
           SET CARD_STARTDATE=(SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_LENGTH,CARDDATE_POSITION-1));
       END IF;
       SET TEMP_ACCESS_CARD = (SELECT SUBSTRING(TEMP_ACCESS_CARD,CARDDATE_POSITION+1));
             UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET CACD_VALID_FROM=CARD_STARTDATE,ULD_ID=USERSTAMP_ID WHERE CUSTOMER_ID=CUST_ID AND ACN_ID IS NULL AND UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARD_NO AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER));
			SET SUCCESS_FLAG=1;
       IF CARDDATE_POSITION<=0 THEN
           LEAVE  loop_label;
       END IF;
   END LOOP;
END IF;
IF START_DATE IS NOT NULL AND END_DATE IS NOT NULL THEN
SET TEMP_ACCESS_CARD = ACCESS_CARD_DATES;
SET ACCESS_LENGTH = 1;
    loop_label : LOOP
        SET CARDNO_POSITION=(SELECT LOCATE(',',TEMP_ACCESS_CARD,ACCESS_LENGTH));
        SET CARD_NO = (SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_LENGTH,CARDNO_POSITION-1));
        SET TEMP_ACCESS_CARD = (SELECT SUBSTRING(TEMP_ACCESS_CARD,CARDNO_POSITION+1));
        SET CARD_STARTDATE_POSITION = (SELECT LOCATE(',',TEMP_ACCESS_CARD,ACCESS_LENGTH));
        SET CARD_START_DATE= (SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_LENGTH,CARD_STARTDATE_POSITION-1));
        SET TEMP_ACCESS_CARD = (SELECT SUBSTRING(TEMP_ACCESS_CARD,CARD_STARTDATE_POSITION+1));
        SET CARD_ENDDATE_POSITION = (SELECT LOCATE(',',TEMP_ACCESS_CARD,ACCESS_LENGTH));   
        IF (CARD_ENDDATE_POSITION=0) THEN
            SET CARD_END_DATE = TEMP_ACCESS_CARD;
        ELSE
            SET CARD_END_DATE=(SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_LENGTH,CARD_ENDDATE_POSITION-1));
        END IF;
        SET TEMP_ACCESS_CARD = (SELECT SUBSTRING(TEMP_ACCESS_CARD,CARD_ENDDATE_POSITION+1));
        IF ACCESS_CARD IS NOT NULL AND PTDDATE IS NULL THEN
        UPDATE CUSTOMER_LP_DETAILS SET CLP_STARTDATE=CARD_START_DATE,CLP_ENDDATE=CARD_END_DATE WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER=CUSTOMER_RECORD_VERSION AND UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARD_NO AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER));
        END IF;
		IF ACCESS_CARD IS NULL AND PTDDATE IS NULL THEN
        UPDATE CUSTOMER_LP_DETAILS SET CLP_STARTDATE=CARD_START_DATE,CLP_ENDDATE=CARD_END_DATE WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER=CUSTOMER_RECORD_VERSION ;
        END IF;
		IF ACCESS_CARD IS NOT NULL AND PTDDATE IS NOT NULL THEN
        UPDATE CUSTOMER_LP_DETAILS SET CLP_STARTDATE=CARD_START_DATE WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER=CUSTOMER_RECORD_VERSION AND UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CARD_NO AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=UNIT_NUMBER));
        END IF;
		IF ACCESS_CARD IS NULL AND PTDDATE IS NOT NULL THEN
        UPDATE CUSTOMER_LP_DETAILS SET CLP_STARTDATE=CARD_START_DATE WHERE CUSTOMER_ID=CUST_ID AND CED_REC_VER=CUSTOMER_RECORD_VERSION ;
        END IF;
        SET SUCCESS_FLAG=1;
        IF CARD_ENDDATE_POSITION<=0 THEN
            LEAVE  loop_label;
        END IF;
    END LOOP;
  END IF;
  CALL SP_CUSTOMER_LP_DETAILS_ULD_TS_MAXTIMES(CUST_ID,CUSTOMER_RECORD_VERSION,USERSTAMP_ID);
COMMIT;
END;