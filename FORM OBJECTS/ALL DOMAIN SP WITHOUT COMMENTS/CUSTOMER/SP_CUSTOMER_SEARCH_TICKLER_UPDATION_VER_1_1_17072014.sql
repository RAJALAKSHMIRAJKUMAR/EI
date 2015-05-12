DROP PROCEDURE IF EXISTS SP_CUSTOMER_TICKLER_UPDATE;
CREATE PROCEDURE SP_CUSTOMER_TICKLER_UPDATE(
IN CUSTOMERID INTEGER,
IN RECVER INTEGER,
IN OLDCUSTOMERTABLEDETAILS TEXT,
IN NEWCUSTOMERTABLEDETAILS TEXT,
IN OLDCOMPANYTABLEDETAILS TEXT,
IN NEWCOMPANYTABLEDETAILS TEXT,
IN OLDPERSONALDETAILS TEXT,
IN NEWPERSONALDETAILS TEXT,
IN OLDENTRYDETAILS TEXT,
IN NEWENTRYDETAILS TEXT,
IN OLDFEEDETAILS TEXT,
IN NEWFEEDETAILS TEXT,
IN OLDTERMINATIONDETAILS TEXT,
IN NEWTERMINATIONDETAILS TEXT,
IN USERSTAMP VARCHAR(50),
IN OLDUSERSTAMP VARCHAR(40),
IN OLDTIMESTAMP VARCHAR(40))
BEGIN 
DECLARE OLD_CUSTOMERTABLEDETAILS TEXT;
DECLARE NEW_CUSTOMERTABLEDETAILS TEXT;
DECLARE CUSTOMER_HEADNAME TEXT;
DECLARE CUSTOMER_LENGTH INTEGER;
DECLARE OLDNAMEPOSITION INTEGER;
DECLARE OLDCUSTOMER_NAME TEXT;
DECLARE NEWNAMEPOSITION INTEGER;
DECLARE NEWCUSTOMER_NAME TEXT;
DECLARE CUSTOMERHEADPOSITION INTEGER;
DECLARE CUSTOMERHEADNAME TEXT;
DECLARE NEWCUSTOMERRECORDS TEXT ;
DECLARE OLDCUSTOMERRECORDS TEXT ;
DECLARE OLDTEMP_ACCESS_CARD TEXT;
DECLARE OLDCARDNO_POSITION INTEGER;
DECLARE OLDCARD_NO VARCHAR(10);
DECLARE OLDCARD_STARTDATE_POSITION INTEGER;
DECLARE OLDCARD_ENDDATE_POSITION INTEGER;
DECLARE OLDCARD_START_DATE VARCHAR(15);
DECLARE OLDCARD_END_DATE VARCHAR(15);
DECLARE NEWTEMP_ACCESS_CARD TEXT;
DECLARE NEWCARDNO_POSITION INTEGER;
DECLARE NEWCARD_NO VARCHAR(10);
DECLARE NEWCARD_STARTDATE_POSITION INTEGER;
DECLARE NEWCARD_ENDDATE_POSITION INTEGER;
DECLARE NEWCARD_START_DATE VARCHAR(15);
DECLARE NEWCARD_END_DATE VARCHAR(15);
DECLARE ACCESS_LENGTH INTEGER;
DECLARE NEWRECORDS TEXT;
DECLARE OLDRECORDS TEXT;
DECLARE NEWRECORD TEXT;
DECLARE OLDRECORD TEXT;
DECLARE ACCESSNEWRECORDS TEXT;
DECLARE ACCESSOLDRECORDS TEXT;
DECLARE ACCNEWRECORD TEXT;
DECLARE ACCOLDRECORD TEXT;
DECLARE CUST_ID VARCHAR(30);
DECLARE HEADLENGTH INTEGER;
DECLARE CUSTOMERHEADERNAMES TEXT;
DECLARE COMPANYTABLENAMES TEXT;
DECLARE PERSONALTABLENAMES TEXT;
DECLARE ENTRYHEADNAMES TEXT;
DECLARE FEEHEADNAMES TEXT;
DECLARE OLD_UNITID INTEGER;
DECLARE NEW_UNITID INTEGER;
DECLARE CPPID INTEGER;
DECLARE LOCATION INTEGER;
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE OLDUSERSTAMP_ID INT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);
CALL SP_CHANGE_USERSTAMP_AS_ULDID(OLDUSERSTAMP,@ULDID);
SET OLDUSERSTAMP_ID = (SELECT @ULDID);
SET CUST_ID='';
SET CUSTOMERHEADERNAMES='CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME';
SET COMPANYTABLENAMES='CCD_COMPANY_NAME,CCD_COMPANY_ADDR,CCD_POSTAL_CODE,CCD_OFFICE_NO';
SET ENTRYHEADNAMES='UNIT_ID,UASD_ID,CED_SD_STIME,CED_SD_ETIME,CED_ED_STIME,CED_ED_ETIME,CED_LEASE_PERIOD,CED_QUARTERS,CED_NOTICE_PERIOD,CED_NOTICE_START_DATE,CED_PROCESSING_WAIVED,CED_PRORATED';
SET PERSONALTABLENAMES='NC_ID,CPD_MOBILE,CPD_INTL_MOBILE,CPD_EMAIL,CPD_PASSPORT_NO,CPD_PASSPORT_DATE,CPD_DOB,CPD_EP_NO,CPD_EP_DATE,CPD_COMMENTS';
SET FEEHEADNAMES='CC_PAYMENT_AMOUNT,CC_DEPOSIT,CC_PROCESSING_FEE,CC_AIRCON_FIXED_FEE,CC_ELECTRICITY_CAP,CC_DRYCLEAN_FEE,CC_AIRCON_QUARTERLY_FEE,CC_CHECKOUT_CLEANING_FEE';
IF OLDCUSTOMERTABLEDETAILS!=NEWCUSTOMERTABLEDETAILS THEN
       SET OLD_CUSTOMERTABLEDETAILS = OLDCUSTOMERTABLEDETAILS;
       SET NEW_CUSTOMERTABLEDETAILS = NEWCUSTOMERTABLEDETAILS;
       SET CUSTOMERHEADNAME=CUSTOMERHEADERNAMES;
       SET NEWCUSTOMERRECORDS=CUST_ID;
       SET OLDCUSTOMERRECORDS=CUST_ID;
       SET CUSTOMER_LENGTH=1;
   loop_label : LOOP
       SET OLDNAMEPOSITION=(SELECT LOCATE(',',OLD_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH));
          IF (OLDNAMEPOSITION=0) THEN
            SET OLDCUSTOMER_NAME = OLD_CUSTOMERTABLEDETAILS;
              ELSE
            SET OLDCUSTOMER_NAME=(SELECT SUBSTRING(OLD_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH,OLDNAMEPOSITION-1));
             SET OLD_CUSTOMERTABLEDETAILS=(SELECT SUBSTRING(OLD_CUSTOMERTABLEDETAILS,OLDNAMEPOSITION+1));
       END IF;    
       SET NEWNAMEPOSITION=(SELECT LOCATE(',',NEW_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH));
       IF (NEWNAMEPOSITION=0) THEN
       SET NEWCUSTOMER_NAME=NEW_CUSTOMERTABLEDETAILS;
       ELSE
       SET NEWCUSTOMER_NAME=(SELECT SUBSTRING(NEW_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH,NEWNAMEPOSITION-1));
       SET NEW_CUSTOMERTABLEDETAILS=(SELECT SUBSTRING(NEW_CUSTOMERTABLEDETAILS,NEWNAMEPOSITION+1));
       END IF;     
       SET CUSTOMERHEADPOSITION=(SELECT LOCATE(',',CUSTOMERHEADNAME,CUSTOMER_LENGTH));
       IF(CUSTOMERHEADPOSITION=0)THEN
       SET CUSTOMER_HEADNAME=CUSTOMERHEADNAME;
       ELSE
       SET CUSTOMER_HEADNAME=(SELECT SUBSTRING(CUSTOMERHEADNAME,CUSTOMER_LENGTH,CUSTOMERHEADPOSITION-1));
       SET CUSTOMERHEADNAME=(SELECT SUBSTRING(CUSTOMERHEADNAME,CUSTOMERHEADPOSITION+1));
       END IF;
       IF OLDCUSTOMER_NAME!=NEWCUSTOMER_NAME THEN     
       SET NEWRECORD=(SELECT CONCAT(CUSTOMER_HEADNAME, '=', NEWCUSTOMER_NAME));
       SET OLDRECORD=(SELECT CONCAT(CUSTOMER_HEADNAME, '=' ,OLDCUSTOMER_NAME));
       SET NEWCUSTOMERRECORDS=(SELECT CONCAT(NEWCUSTOMERRECORDS,',',NEWRECORD));
       SET OLDCUSTOMERRECORDS=(SELECT CONCAT(OLDCUSTOMERRECORDS,',',OLDRECORD)); 
       END IF;         
       IF CUSTOMERHEADPOSITION<=0 THEN
       LEAVE  loop_label;
       END IF;
   END LOOP;
   SET LOCATION=(SELECT LOCATE(',', NEWCUSTOMERRECORDS,1));
    SET NEWCUSTOMERRECORDS=(SELECT SUBSTRING(NEWCUSTOMERRECORDS,LOCATION+1));
    SET LOCATION=(SELECT LOCATE(',', OLDCUSTOMERRECORDS,1));
    SET OLDCUSTOMERRECORDS=(SELECT SUBSTRING(OLDCUSTOMERRECORDS,LOCATION+1));
     INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)values((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER'),OLDCUSTOMERRECORDS,NEWCUSTOMERRECORDS,USERSTAMP_ID,CUSTOMERID);
 END IF;
 IF OLDCOMPANYTABLEDETAILS!=NEWCOMPANYTABLEDETAILS THEN
       SET OLD_CUSTOMERTABLEDETAILS = OLDCOMPANYTABLEDETAILS;
       SET NEW_CUSTOMERTABLEDETAILS = NEWCOMPANYTABLEDETAILS;
       SET CUSTOMERHEADNAME=COMPANYTABLENAMES;
       SET NEWCUSTOMERRECORDS=CUST_ID;
       SET OLDCUSTOMERRECORDS=CUST_ID;
       SET CUSTOMER_LENGTH=1;
   loop_label : LOOP
       SET OLDNAMEPOSITION=(SELECT LOCATE(',',OLD_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH));
          IF (OLDNAMEPOSITION=0) THEN
            SET OLDCUSTOMER_NAME = OLD_CUSTOMERTABLEDETAILS;
              ELSE
            SET OLDCUSTOMER_NAME=(SELECT SUBSTRING(OLD_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH,OLDNAMEPOSITION-1));
             SET OLD_CUSTOMERTABLEDETAILS=(SELECT SUBSTRING(OLD_CUSTOMERTABLEDETAILS,OLDNAMEPOSITION+1));
       END IF;      
       SET NEWNAMEPOSITION=(SELECT LOCATE(',',NEW_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH));
       IF (NEWNAMEPOSITION=0) THEN
       SET NEWCUSTOMER_NAME=NEW_CUSTOMERTABLEDETAILS;
       ELSE
       SET NEWCUSTOMER_NAME=(SELECT SUBSTRING(NEW_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH,NEWNAMEPOSITION-1));
       SET NEW_CUSTOMERTABLEDETAILS=(SELECT SUBSTRING(NEW_CUSTOMERTABLEDETAILS,NEWNAMEPOSITION+1));
       END IF;       
       SET CUSTOMERHEADPOSITION=(SELECT LOCATE(',',CUSTOMERHEADNAME,CUSTOMER_LENGTH));
       IF(CUSTOMERHEADPOSITION=0)THEN
       SET CUSTOMER_HEADNAME=CUSTOMERHEADNAME;
       ELSE
       SET CUSTOMER_HEADNAME=(SELECT SUBSTRING(CUSTOMERHEADNAME,CUSTOMER_LENGTH,CUSTOMERHEADPOSITION-1));
       SET CUSTOMERHEADNAME=(SELECT SUBSTRING(CUSTOMERHEADNAME,CUSTOMERHEADPOSITION+1));
       END IF;
       IF OLDCUSTOMER_NAME!=NEWCUSTOMER_NAME THEN
       IF NEWCUSTOMER_NAME='' THEN
       SET NEWCUSTOMER_NAME='NULL';
       END IF;
       IF OLDCUSTOMER_NAME="" THEN
       SET OLDCUSTOMER_NAME='NULL';
       END IF;
       SET NEWRECORD=(SELECT CONCAT(CUSTOMER_HEADNAME, '=', NEWCUSTOMER_NAME));
       SET OLDRECORD=(SELECT CONCAT(CUSTOMER_HEADNAME, '=' ,OLDCUSTOMER_NAME));
       SET NEWCUSTOMERRECORDS=(SELECT CONCAT(NEWCUSTOMERRECORDS,',',NEWRECORD));
       SET OLDCUSTOMERRECORDS=(SELECT CONCAT(OLDCUSTOMERRECORDS,',',OLDRECORD));       
       END IF;     
       IF CUSTOMERHEADPOSITION<=0 THEN
       LEAVE  loop_label;
       END IF;
   END LOOP;
   SET LOCATION=(SELECT LOCATE(',', NEWCUSTOMERRECORDS,1));
    SET NEWCUSTOMERRECORDS=(SELECT SUBSTRING(NEWCUSTOMERRECORDS,LOCATION+1));
    SET LOCATION=(SELECT LOCATE(',', OLDCUSTOMERRECORDS,1));
    SET OLDCUSTOMERRECORDS=(SELECT SUBSTRING(OLDCUSTOMERRECORDS,LOCATION+1));
       INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)values((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_COMPANY_DETAILS'),OLDCUSTOMERRECORDS,NEWCUSTOMERRECORDS,USERSTAMP_ID,CUSTOMERID);
 END IF;
 IF OLDPERSONALDETAILS!=NEWPERSONALDETAILS THEN
       SET OLD_CUSTOMERTABLEDETAILS = OLDPERSONALDETAILS;
       SET NEW_CUSTOMERTABLEDETAILS = NEWPERSONALDETAILS;
       SET CUSTOMERHEADNAME=PERSONALTABLENAMES;
       SET NEWCUSTOMERRECORDS=CUST_ID;
       SET OLDCUSTOMERRECORDS=CUST_ID;
       SET CUSTOMER_LENGTH=1;
   loop_label : LOOP
       SET OLDNAMEPOSITION=(SELECT LOCATE('^',OLD_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH));
          IF (OLDNAMEPOSITION=0) THEN
            SET OLDCUSTOMER_NAME = OLD_CUSTOMERTABLEDETAILS;
              ELSE
            SET OLDCUSTOMER_NAME=(SELECT SUBSTRING(OLD_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH,OLDNAMEPOSITION-1));
             SET OLD_CUSTOMERTABLEDETAILS=(SELECT SUBSTRING(OLD_CUSTOMERTABLEDETAILS,OLDNAMEPOSITION+1));
       END IF;      
       SET NEWNAMEPOSITION=(SELECT LOCATE('^',NEW_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH));
       IF (NEWNAMEPOSITION=0) THEN
       SET NEWCUSTOMER_NAME=NEW_CUSTOMERTABLEDETAILS;
       ELSE
       SET NEWCUSTOMER_NAME=(SELECT SUBSTRING(NEW_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH,NEWNAMEPOSITION-1));
       SET NEW_CUSTOMERTABLEDETAILS=(SELECT SUBSTRING(NEW_CUSTOMERTABLEDETAILS,NEWNAMEPOSITION+1));
       END IF;      
       SET CUSTOMERHEADPOSITION=(SELECT LOCATE(',',CUSTOMERHEADNAME,CUSTOMER_LENGTH));
       IF(CUSTOMERHEADPOSITION=0)THEN
       SET CUSTOMER_HEADNAME=CUSTOMERHEADNAME;
       ELSE
       SET CUSTOMER_HEADNAME=(SELECT SUBSTRING(CUSTOMERHEADNAME,CUSTOMER_LENGTH,CUSTOMERHEADPOSITION-1));
       SET CUSTOMERHEADNAME=(SELECT SUBSTRING(CUSTOMERHEADNAME,CUSTOMERHEADPOSITION+1));
       END IF;
       IF OLDCUSTOMER_NAME!=NEWCUSTOMER_NAME THEN
       IF OLDCUSTOMER_NAME=' ' THEN
       SET OLDCUSTOMER_NAME='NULL';
       END IF;
       IF NEWCUSTOMER_NAME=' ' THEN
       SET NEWCUSTOMER_NAME='NULL';
       END IF;
       IF CUSTOMER_HEADNAME='NC_ID' THEN
        SET NEWCUSTOMER_NAME=(SELECT NC_ID FROM NATIONALITY_CONFIGURATION WHERE NC_DATA=NEWCUSTOMER_NAME);
        SET OLDCUSTOMER_NAME=(SELECT NC_ID FROM NATIONALITY_CONFIGURATION WHERE NC_DATA=OLDCUSTOMER_NAME);
       END IF;
       SET NEWRECORD=(SELECT CONCAT(CUSTOMER_HEADNAME, '=', NEWCUSTOMER_NAME));
       SET OLDRECORD=(SELECT CONCAT(CUSTOMER_HEADNAME, '=' ,OLDCUSTOMER_NAME));
       SET NEWCUSTOMERRECORDS=(SELECT CONCAT(NEWCUSTOMERRECORDS,',',NEWRECORD));
       SET OLDCUSTOMERRECORDS=(SELECT CONCAT(OLDCUSTOMERRECORDS,',',OLDRECORD));       
       END IF;   
       IF CUSTOMERHEADPOSITION<=0 THEN
       LEAVE  loop_label;
       END IF;
   END LOOP;
   SET LOCATION=(SELECT LOCATE(',', NEWCUSTOMERRECORDS,1));
    SET NEWCUSTOMERRECORDS=(SELECT SUBSTRING(NEWCUSTOMERRECORDS,LOCATION+1));
    SET LOCATION=(SELECT LOCATE(',', OLDCUSTOMERRECORDS,1));
    SET OLDCUSTOMERRECORDS=(SELECT SUBSTRING(OLDCUSTOMERRECORDS,LOCATION+1));
       INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)values((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_PERSONAL_DETAILS'),OLDCUSTOMERRECORDS,NEWCUSTOMERRECORDS,USERSTAMP_ID,CUSTOMERID);
 END IF;
 IF OLDENTRYDETAILS!=NEWENTRYDETAILS THEN
       SET OLD_CUSTOMERTABLEDETAILS = OLDENTRYDETAILS;
       SET NEW_CUSTOMERTABLEDETAILS = NEWENTRYDETAILS;
       SET CUSTOMERHEADNAME=ENTRYHEADNAMES;
       SET NEWCUSTOMERRECORDS='';
       SET OLDCUSTOMERRECORDS=(SELECT CONCAT('CED_REC_VER=',RECVER));
       SET CUSTOMER_LENGTH=1;
   loop_label : LOOP
       SET OLDNAMEPOSITION=(SELECT LOCATE('@',OLD_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH));
          IF (OLDNAMEPOSITION=0) THEN
            SET OLDCUSTOMER_NAME = OLD_CUSTOMERTABLEDETAILS;
              ELSE
            SET OLDCUSTOMER_NAME=(SELECT SUBSTRING(OLD_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH,OLDNAMEPOSITION-1));
             SET OLD_CUSTOMERTABLEDETAILS=(SELECT SUBSTRING(OLD_CUSTOMERTABLEDETAILS,OLDNAMEPOSITION+1));
       END IF;      
       SET NEWNAMEPOSITION=(SELECT LOCATE('@',NEW_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH));
       IF (NEWNAMEPOSITION=0) THEN
       SET NEWCUSTOMER_NAME=NEW_CUSTOMERTABLEDETAILS;
       ELSE
       SET NEWCUSTOMER_NAME=(SELECT SUBSTRING(NEW_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH,NEWNAMEPOSITION-1));
       SET NEW_CUSTOMERTABLEDETAILS=(SELECT SUBSTRING(NEW_CUSTOMERTABLEDETAILS,NEWNAMEPOSITION+1));
       END IF;       
       SET CUSTOMERHEADPOSITION=(SELECT LOCATE(',',CUSTOMERHEADNAME,CUSTOMER_LENGTH));
       IF(CUSTOMERHEADPOSITION=0)THEN
       SET CUSTOMER_HEADNAME=CUSTOMERHEADNAME;
       ELSE
       SET CUSTOMER_HEADNAME=(SELECT SUBSTRING(CUSTOMERHEADNAME,CUSTOMER_LENGTH,CUSTOMERHEADPOSITION-1));
       SET CUSTOMERHEADNAME=(SELECT SUBSTRING(CUSTOMERHEADNAME,CUSTOMERHEADPOSITION+1));
       END IF;      
       IF OLDCUSTOMER_NAME=' ' THEN
       SET OLDCUSTOMER_NAME='NULL';
       END IF;
       IF NEWCUSTOMER_NAME=' ' THEN
       SET NEWCUSTOMER_NAME='NULL';
       END IF;
        IF CUSTOMER_HEADNAME='UNIT_ID' THEN
            SET OLDCUSTOMER_NAME=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=OLDCUSTOMER_NAME);
            SET NEWCUSTOMER_NAME=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=NEWCUSTOMER_NAME);
            SET OLD_UNITID=OLDCUSTOMER_NAME;
            SET NEW_UNITID=NEWCUSTOMER_NAME;
        END IF;
        IF CUSTOMER_HEADNAME='UASD_ID' THEN
            SET OLDCUSTOMER_NAME=(SELECT DISTINCT CED.UASD_ID FROM UNIT_ROOM_TYPE_DETAILS URTD,UNIT_ACCESS_STAMP_DETAILS UASD,CUSTOMER_ENTRY_DETAILS CED WHERE CED.UASD_ID=UASD.UASD_ID AND UASD.URTD_ID=URTD.URTD_ID AND URTD.URTD_ROOM_TYPE=OLDCUSTOMER_NAME AND UASD.UNIT_ID=OLD_UNITID);
            SET NEWCUSTOMER_NAME=(SELECT DISTINCT CED.UASD_ID FROM UNIT_ROOM_TYPE_DETAILS URTD,UNIT_ACCESS_STAMP_DETAILS UASD,CUSTOMER_ENTRY_DETAILS CED WHERE CED.UASD_ID=UASD.UASD_ID AND UASD.URTD_ID=URTD.URTD_ID AND URTD.URTD_ROOM_TYPE=NEWCUSTOMER_NAME AND UASD.UNIT_ID=NEW_UNITID);
        END IF;
        IF (CUSTOMER_HEADNAME='CED_SD_STIME' OR CUSTOMER_HEADNAME='CED_SD_ETIME' OR CUSTOMER_HEADNAME='CED_ED_STIME' OR CUSTOMER_HEADNAME='CED_ED_ETIME' )THEN
            SET OLDCUSTOMER_NAME=(SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=OLDCUSTOMER_NAME);
            SET NEWCUSTOMER_NAME=(SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=NEWCUSTOMER_NAME);
        END IF;
        IF OLDCUSTOMER_NAME!=NEWCUSTOMER_NAME THEN
       SET NEWRECORD=(SELECT CONCAT(CUSTOMER_HEADNAME, '=', NEWCUSTOMER_NAME));
       SET OLDRECORD=(SELECT CONCAT(CUSTOMER_HEADNAME, '=' ,OLDCUSTOMER_NAME));
       SET NEWCUSTOMERRECORDS=(SELECT CONCAT(NEWCUSTOMERRECORDS,',',NEWRECORD));
       SET OLDCUSTOMERRECORDS=(SELECT CONCAT(OLDCUSTOMERRECORDS,',',OLDRECORD));      
       END IF;   
       IF CUSTOMERHEADPOSITION<=0 THEN
       LEAVE  loop_label;
       END IF;
   END LOOP;  
      SET NEWCUSTOMERRECORDS=(SELECT SUBSTRING(NEWCUSTOMERRECORDS,2)); 
        INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)values((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ENTRY_DETAILS'),OLDCUSTOMERRECORDS,NEWCUSTOMERRECORDS,USERSTAMP_ID,CUSTOMERID);
 END IF;
 IF OLDFEEDETAILS!=NEWFEEDETAILS THEN
       SET OLD_CUSTOMERTABLEDETAILS = OLDFEEDETAILS;
       SET NEW_CUSTOMERTABLEDETAILS = NEWFEEDETAILS;
       SET CUSTOMERHEADNAME=FEEHEADNAMES;
       SET NEWCUSTOMERRECORDS='';
       SET OLDCUSTOMERRECORDS=(SELECT CONCAT('CED_REC_VER=',RECVER));
       SET CUSTOMER_LENGTH=1;
   loop_label : LOOP
       SET OLDNAMEPOSITION=(SELECT LOCATE(',',OLD_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH));
          IF (OLDNAMEPOSITION=0) THEN
            SET OLDCUSTOMER_NAME = OLD_CUSTOMERTABLEDETAILS;
              ELSE
            SET OLDCUSTOMER_NAME=(SELECT SUBSTRING(OLD_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH,OLDNAMEPOSITION-1));
             SET OLD_CUSTOMERTABLEDETAILS=(SELECT SUBSTRING(OLD_CUSTOMERTABLEDETAILS,OLDNAMEPOSITION+1));
       END IF;      
       SET NEWNAMEPOSITION=(SELECT LOCATE(',',NEW_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH));
       IF (NEWNAMEPOSITION=0) THEN
       SET NEWCUSTOMER_NAME=NEW_CUSTOMERTABLEDETAILS;
       ELSE
       SET NEWCUSTOMER_NAME=(SELECT SUBSTRING(NEW_CUSTOMERTABLEDETAILS,CUSTOMER_LENGTH,NEWNAMEPOSITION-1));
       SET NEW_CUSTOMERTABLEDETAILS=(SELECT SUBSTRING(NEW_CUSTOMERTABLEDETAILS,NEWNAMEPOSITION+1));
       END IF;       
       SET CUSTOMERHEADPOSITION=(SELECT LOCATE(',',CUSTOMERHEADNAME,CUSTOMER_LENGTH));
       IF(CUSTOMERHEADPOSITION=0)THEN
       SET CUSTOMER_HEADNAME=CUSTOMERHEADNAME;
       ELSE
       SET CUSTOMER_HEADNAME=(SELECT SUBSTRING(CUSTOMERHEADNAME,CUSTOMER_LENGTH,CUSTOMERHEADPOSITION-1));
       SET CUSTOMERHEADNAME=(SELECT SUBSTRING(CUSTOMERHEADNAME,CUSTOMERHEADPOSITION+1));
       END IF;
       IF OLDCUSTOMER_NAME!=NEWCUSTOMER_NAME THEN
       IF OLDCUSTOMER_NAME=' ' THEN
       SET OLDCUSTOMER_NAME='NULL';
       END IF;
       IF NEWCUSTOMER_NAME=' ' THEN
       SET NEWCUSTOMER_NAME='NULL';
       END IF;
       SET CPPID=(SELECT CPP_ID FROM CUSTOMER_PAYMENT_PROFILE WHERE CPP_DATA=CUSTOMER_HEADNAME);
        IF CUSTOMERHEADNAME='CED_REC_VER' THEN
            SET NEWRECORD=(SELECT CONCAT(CUSTOMER_HEADNAME, '=', NEWCUSTOMER_NAME));
            SET OLDRECORD=(SELECT CONCAT(CUSTOMER_HEADNAME, '=', OLDCUSTOMER_NAME));
        END IF;
       SET NEWRECORD=(SELECT CONCAT('CPP_ID=',CPPID,',CFD_AMOUNT=', NEWCUSTOMER_NAME));
       SET OLDRECORD=(SELECT CONCAT('CPP_ID=',CPPID,',CFD_AMOUNT=',OLDCUSTOMER_NAME));
       SET NEWCUSTOMERRECORDS=(SELECT CONCAT(NEWCUSTOMERRECORDS,',',NEWRECORD));
       SET OLDCUSTOMERRECORDS=(SELECT CONCAT(OLDCUSTOMERRECORDS,',',OLDRECORD));       
       END IF;   
       IF CUSTOMERHEADPOSITION<=0 THEN
       LEAVE  loop_label;
       END IF;
   END LOOP;  
     SET NEWCUSTOMERRECORDS=(SELECT SUBSTRING(NEWCUSTOMERRECORDS,2));
       INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)values((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_FEE_DETAILS'),OLDCUSTOMERRECORDS,NEWCUSTOMERRECORDS,USERSTAMP_ID,CUSTOMERID);
 END IF;
IF (OLDTERMINATIONDETAILS!=NEWTERMINATIONDETAILS) THEN
SET OLDTEMP_ACCESS_CARD = OLDTERMINATIONDETAILS;
SET NEWTEMP_ACCESS_CARD = NEWTERMINATIONDETAILS;
SET NEWRECORDS='';
SET OLDRECORDS=(SELECT CONCAT('CED_REC_VER=',RECVER));
SET ACCESSNEWRECORDS='';
SET ACCESSOLDRECORDS=(SELECT CONCAT('CED_REC_VER=',RECVER));
SET ACCESS_LENGTH = 1;
    loop_label : LOOP
    	SET OLDCARDNO_POSITION=(SELECT LOCATE(',',OLDTEMP_ACCESS_CARD,ACCESS_LENGTH));
		SET OLDCARD_NO = (SELECT SUBSTRING(OLDTEMP_ACCESS_CARD,ACCESS_LENGTH,OLDCARDNO_POSITION-1));
		SET OLDTEMP_ACCESS_CARD = (SELECT SUBSTRING(OLDTEMP_ACCESS_CARD,OLDCARDNO_POSITION+1));
		SET OLDCARD_STARTDATE_POSITION = (SELECT LOCATE(',',OLDTEMP_ACCESS_CARD,ACCESS_LENGTH));
		SET OLDCARD_START_DATE= (SELECT SUBSTRING(OLDTEMP_ACCESS_CARD,ACCESS_LENGTH,OLDCARD_STARTDATE_POSITION-1));
		SET OLDTEMP_ACCESS_CARD = (SELECT SUBSTRING(OLDTEMP_ACCESS_CARD,OLDCARD_STARTDATE_POSITION+1));
		SET OLDCARD_ENDDATE_POSITION = (SELECT LOCATE(',',OLDTEMP_ACCESS_CARD,ACCESS_LENGTH));
        IF (OLDCARD_ENDDATE_POSITION=0) THEN
            SET OLDCARD_END_DATE = OLDTEMP_ACCESS_CARD;
        ELSE
            SET OLDCARD_END_DATE=(SELECT SUBSTRING(OLDTEMP_ACCESS_CARD,ACCESS_LENGTH,OLDCARD_ENDDATE_POSITION-1));
        END IF;
			SET OLDTEMP_ACCESS_CARD = (SELECT SUBSTRING(OLDTEMP_ACCESS_CARD,OLDCARD_ENDDATE_POSITION+1));       
			SET NEWCARDNO_POSITION=(SELECT LOCATE(',',NEWTEMP_ACCESS_CARD,ACCESS_LENGTH));
			SET NEWCARD_NO = (SELECT SUBSTRING(NEWTEMP_ACCESS_CARD,ACCESS_LENGTH,NEWCARDNO_POSITION-1));
			SET NEWTEMP_ACCESS_CARD = (SELECT SUBSTRING(NEWTEMP_ACCESS_CARD,NEWCARDNO_POSITION+1));
			SET NEWCARD_STARTDATE_POSITION = (SELECT LOCATE(',',NEWTEMP_ACCESS_CARD,ACCESS_LENGTH));
			SET NEWCARD_START_DATE= (SELECT SUBSTRING(NEWTEMP_ACCESS_CARD,ACCESS_LENGTH,NEWCARD_STARTDATE_POSITION-1));
			SET NEWTEMP_ACCESS_CARD = (SELECT SUBSTRING(NEWTEMP_ACCESS_CARD,NEWCARD_STARTDATE_POSITION+1));
			SET NEWCARD_ENDDATE_POSITION = (SELECT LOCATE(',',NEWTEMP_ACCESS_CARD,ACCESS_LENGTH));     
        IF (NEWCARD_ENDDATE_POSITION=0) THEN
            SET NEWCARD_END_DATE = NEWTEMP_ACCESS_CARD;
        ELSE
            SET NEWCARD_END_DATE=(SELECT SUBSTRING(NEWTEMP_ACCESS_CARD,ACCESS_LENGTH,NEWCARD_ENDDATE_POSITION-1));
        END IF;
        SET NEWTEMP_ACCESS_CARD = (SELECT SUBSTRING(NEWTEMP_ACCESS_CARD,NEWCARD_ENDDATE_POSITION+1));
        IF OLDCARD_NO=' ' OR OLDCARD_NO='' THEN
			SET OLDCARD_NO='NULL';
        END IF;
        IF NEWCARD_NO=' ' OR NEWCARD_NO='' THEN
			SET NEWCARD_NO='NULL';
        END IF;
        IF ((NEWCARD_START_DATE!=OLDCARD_START_DATE)OR(NEWCARD_END_DATE!=OLDCARD_END_DATE))THEN
			IF NEWCARD_NO!='NULL' THEN
			    IF NEWCARD_START_DATE!=OLDCARD_START_DATE AND NEWCARD_END_DATE!=OLDCARD_END_DATE THEN
				SET NEWRECORD=(SELECT CONCAT('CLP_STARTDATE','=',NEWCARD_START_DATE, ',','CLP_ENDDATE','=',NEWCARD_END_DATE));
				SET OLDRECORD=(SELECT CONCAT('UASD_ID', '=', (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=OLDCARD_NO), ',','CLP_STARTDATE','=',OLDCARD_START_DATE, ',','CLP_ENDDATE','=',OLDCARD_END_DATE, ',','ULD_ID','=',OLDUSERSTAMP_ID,',','CLP_TIMESTAMP','=',OLDTIMESTAMP));
				END IF;
				IF NEWCARD_START_DATE!=OLDCARD_START_DATE AND NEWCARD_END_DATE=OLDCARD_END_DATE THEN
				SET NEWRECORD=(SELECT CONCAT('CLP_STARTDATE','=',NEWCARD_START_DATE));
				SET OLDRECORD=(SELECT CONCAT('UASD_ID', '=', (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=OLDCARD_NO), ',','CLP_STARTDATE','=',OLDCARD_START_DATE, ',','CLP_ENDDATE','=',OLDCARD_END_DATE, ',','ULD_ID','=',OLDUSERSTAMP_ID,',','CLP_TIMESTAMP','=',OLDTIMESTAMP));
			    END IF;
				IF NEWCARD_START_DATE=OLDCARD_START_DATE AND NEWCARD_END_DATE!=OLDCARD_END_DATE THEN
				SET NEWRECORD=(SELECT CONCAT('CLP_ENDDATE','=',NEWCARD_END_DATE));
				SET OLDRECORD=(SELECT CONCAT('UASD_ID', '=', (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=OLDCARD_NO), ',','CLP_ENDDATE','=',OLDCARD_END_DATE, ',','ULD_ID','=',OLDUSERSTAMP_ID,',','CLP_TIMESTAMP','=',OLDTIMESTAMP));
				END IF;
			ELSE		
			    IF NEWCARD_START_DATE!=OLDCARD_START_DATE AND NEWCARD_END_DATE!=OLDCARD_END_DATE THEN
				SET NEWRECORD=(SELECT CONCAT('CLP_STARTDATE','=',NEWCARD_START_DATE, ',','CLP_ENDDATE','=',NEWCARD_END_DATE));
				SET OLDRECORD=(SELECT CONCAT('CLP_STARTDATE','=',OLDCARD_START_DATE, ',','CLP_ENDDATE','=',OLDCARD_END_DATE, ',','ULD_ID','=',OLDUSERSTAMP_ID,',','CLP_TIMESTAMP','=',OLDTIMESTAMP));
				END IF;
				IF NEWCARD_START_DATE!=OLDCARD_START_DATE AND NEWCARD_END_DATE=OLDCARD_END_DATE THEN
				SET NEWRECORD=(SELECT CONCAT('CLP_STARTDATE','=',NEWCARD_START_DATE));
				SET OLDRECORD=(SELECT CONCAT('CLP_STARTDATE','=',OLDCARD_START_DATE));
			    END IF;
				IF NEWCARD_START_DATE=OLDCARD_START_DATE AND NEWCARD_END_DATE!=OLDCARD_END_DATE THEN
				SET NEWRECORD=(SELECT CONCAT('CLP_ENDDATE','=',NEWCARD_END_DATE));
				SET OLDRECORD=(SELECT CONCAT('CLP_ENDDATE','=',OLDCARD_END_DATE));
				END IF;
			END IF;
			SET NEWRECORDS=(SELECT CONCAT(NEWRECORDS,',',NEWRECORD));
			SET OLDRECORDS=(SELECT CONCAT(OLDRECORDS,',',OLDRECORD));
			SET ACCNEWRECORD=(SELECT CONCAT('UASD_ID', '=', (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=NEWCARD_NO), ',','CACD_VALID_FROM','=',NEWCARD_START_DATE));
			SET ACCOLDRECORD=(SELECT CONCAT('UASD_ID', '=', (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=OLDCARD_NO), ',','CACD_VALID_FROM','=',OLDCARD_START_DATE, ',','ULD_ID','=',OLDUSERSTAMP_ID,',','CLP_TIMESTAMP','=',OLDTIMESTAMP));
			SET ACCESSNEWRECORDS=(SELECT CONCAT(ACCESSNEWRECORDS,',',ACCNEWRECORD));
			SET ACCESSOLDRECORDS=(SELECT CONCAT(ACCESSOLDRECORDS,',',ACCOLDRECORD));
	        END IF;
        IF NEWCARD_ENDDATE_POSITION<=0 THEN
		    SET NEWRECORDS=(SELECT SUBSTRING(NEWRECORDS,2));
			INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)values((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_LP_DETAILS'),OLDRECORDS,NEWRECORDS,USERSTAMP_ID,CUSTOMERID);
			IF OLDCARD_NO!='NULL' AND OLDCARD_START_DATE!=NEWCARD_START_DATE THEN
				SET ACCESSNEWRECORDS=(SELECT SUBSTRING(ACCESSNEWRECORDS,2));
				INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)values((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ACCESS_CARD_DETAILS'),ACCESSOLDRECORDS,ACCESSNEWRECORDS,USERSTAMP_ID,CUSTOMERID);
			END IF;         
			LEAVE  loop_label;
        END IF;
    END LOOP;
    END IF;
COMMIT;
END;