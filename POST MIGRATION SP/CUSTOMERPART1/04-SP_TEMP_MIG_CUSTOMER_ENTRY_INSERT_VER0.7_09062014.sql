DROP PROCEDURE IF EXISTS SP_TEMP_MIG_CUSTOMER_ENTRY_INSERT;
CREATE PROCEDURE SP_TEMP_MIG_CUSTOMER_ENTRY_INSERT(IN SOUCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
SET FOREIGN_KEY_CHECKS=0;
SET @DRCUSTOMERENTRY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.CUSTOMER_ENTRY_DETAILS'));
PREPARE DRCUSTOMERENTRY FROM @DRCUSTOMERENTRY;
EXECUTE DRCUSTOMERENTRY;
SET @CREATECUSTOMERENTRY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.CUSTOMER_ENTRY_DETAILS(
CED_ID INTEGER NOT NULL	AUTO_INCREMENT,
CUSTOMER_ID	INTEGER NOT NULL,
UNIT_ID	INTEGER NOT NULL,
UASD_ID	INTEGER NOT NULL, 
CED_REC_VER	INTEGER NOT NULL,	
CED_SD_STIME INTEGER NOT NULL,	
CED_SD_ETIME INTEGER NOT NULL,	
CED_ED_STIME INTEGER NOT NULL,	
CED_ED_ETIME INTEGER NOT NULL,	
CED_LEASE_PERIOD VARCHAR(30) NULL,	
CED_QUARTERS DECIMAL(5,2) NULL,	
CED_RECHECKIN CHAR(1) NULL,	
CED_EXTENSION CHAR(1) NULL,	
CED_PRETERMINATE CHAR(1) NULL,	
CED_PROCESSING_WAIVED CHAR(1) NULL,	
CED_PRORATED CHAR(1) NULL,	
CED_NOTICE_PERIOD TINYINT(1) NULL,	
CED_NOTICE_START_DATE DATE NULL,	
CED_CANCEL_DATE	DATE NULL,
PRIMARY KEY(CED_ID),
FOREIGN KEY(CUSTOMER_ID) REFERENCES ',DESTINATIONSCHEMA,'.CUSTOMER(CUSTOMER_ID),
FOREIGN KEY(UNIT_ID) REFERENCES ',DESTINATIONSCHEMA,'.UNIT(UNIT_ID),
FOREIGN KEY(UASD_ID) REFERENCES ',DESTINATIONSCHEMA,'.UNIT_ACCESS_STAMP_DETAILS(UASD_ID),
FOREIGN KEY(CED_SD_STIME)REFERENCES ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE(CTP_ID),
FOREIGN KEY(CED_SD_ETIME)REFERENCES ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE(CTP_ID),
FOREIGN KEY(CED_ED_STIME)REFERENCES ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE(CTP_ID),
FOREIGN KEY(CED_ED_ETIME)REFERENCES ',DESTINATIONSCHEMA,'.CUSTOMER_TIME_PROFILE(CTP_ID))'));
PREPARE CREATECUSENTRYSTMT FROM @CREATECUSTOMERENTRY;
EXECUTE CREATECUSENTRYSTMT;
SET @CUSTOMERENTRYINSERT=(SELECT CONCAT('INSERT INTO
',DESTINATIONSCHEMA ,'.CUSTOMER_ENTRY_DETAILS(CUSTOMER_ID,UNIT_ID,UASD_ID,CED_REC_VER,CED_SD_STIME,
CED_SD_ETIME,CED_ED_STIME,CED_ED_ETIME,CED_LEASE_PERIOD,CED_QUARTERS,CED_EXTENSION,CED_RECHECKIN
,CED_PRETERMINATE,CED_NOTICE_PERIOD,CED_NOTICE_START_DATE,CED_PROCESSING_WAIVED,CED_CANCEL_DATE)
SELECT CUSTOMER_ID ,UNIT_ID ,UASD_ID ,CED_REC_VER ,CED_SD_STIME,CED_SD_ETIME ,CED_ED_STIME ,CED_ED_ETIME ,
CED_LEASE_PERIOD ,CED_QUARTERS ,CED_EXTENSION ,CED_RECHECKIN,CED_PRETERMINATE ,CED_NOTICE_PERIOD
,CED_NOTICE_START_DATE ,CED_PROCESSING_WAIVED ,CED_CANCEL_DATE FROM ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_ENTRY_DETAILS'));
PREPARE CUSTOMERENTRYINSERTSTMT FROM @CUSTOMERENTRYINSERT;
EXECUTE CUSTOMERENTRYINSERTSTMT ;
SET FOREIGN_KEY_CHECKS=1;
COMMIT;
END;
