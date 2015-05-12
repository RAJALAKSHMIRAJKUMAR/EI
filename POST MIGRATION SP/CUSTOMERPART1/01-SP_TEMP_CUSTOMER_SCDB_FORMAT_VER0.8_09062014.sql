DROP PROCEDURE IF EXISTS SP_TEMP_CUSTOMER_SCDB_FORMAT;
CREATE PROCEDURE SP_TEMP_CUSTOMER_SCDB_FORMAT(IN SOURCESCHEMA VARCHAR(50),DESTINATIONSCHEMA VARCHAR(50))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
SET @DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT'));
PREPARE DROPQUERYSTMT FROM @DROPQUERY;
EXECUTE DROPQUERYSTMT;
SET @CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT(
CC_STARTDATE VARCHAR(255) NULL,
CC_REC_VER INTEGER NULL,
CC_GUEST_CARD_NO VARCHAR(255) NULL,
CC_PROCESSING_FEE VARCHAR(255) NULL,
TIMESTAMP VARCHAR(255) NULL,
CC_DEPOSIT VARCHAR(255) NULL,
CC_COMPANY_ADDR VARCHAR(255) NULL,
CC_PASSPORT_DATE VARCHAR(255) NULL,
CC_CHECKOUT_CLEANING_FEE VARCHAR(255) NULL,
CC_LEASE_PERIOD VARCHAR(255) NULL,
CC_ID INTEGER NULL,
CC_NOTICE_START_DATE VARCHAR(255) NULL,
CC_POSTAL_CODE VARCHAR(255) NULL,
CC_DRYCLEAN_FEE VARCHAR(255) NULL,
SILOID VARCHAR(255) NULL,
CC_FIRST_NAME VARCHAR(255) NULL,
`CC_QUARTERS` VARCHAR(255) NULL,
`CC_NATIONALITY` VARCHAR(255) NULL,
`CC_RENT_AMOUNT` VARCHAR(255) NULL,
`CC_NOTICE_PERIOD` VARCHAR(255) NULL,
`CC_PASSPORT_NO` VARCHAR(255) NULL,
`CC_MOBILE2` VARCHAR(255) NULL,
`CC_EP_NO` VARCHAR(255) NULL,
`CC_CARD_NO` VARCHAR(255) NULL,
`CC_ROOMTYPE` VARCHAR(255) NULL,
`CC_CUST_ID` INTEGER NULL,
`CC_EXTENSION` VARCHAR(255) NULL,
`CC_ELECTRICITY_CAP` VARCHAR(255) NULL,
`CC_COMPANY_NAME` VARCHAR(255) NULL,
`CC_MOBILE` VARCHAR(255) NULL,
`CC_AIRCON_FIXED_FEE` VARCHAR(255) NULL,
`CC_DOB` VARCHAR(255) NULL,
`CC_EMAIL` VARCHAR(255) NULL,
`CC_CANCEL_DATE` VARCHAR(255) NULL,
`CC_COMMENTS` TEXT NULL,
`CC_TERMINATE` VARCHAR(255) NULL,
`CC_UNIT_NO` VARCHAR(255) NULL,
`CC_EP_DATE` VARCHAR(255) NULL,
`CC_ENDDATE` VARCHAR(255) NULL,
`CC_LAST_NAME` VARCHAR(255) NULL,
`CC_PRETERMINATE` VARCHAR(255) NULL,
`CC_OFFICE_NO` VARCHAR(255) NULL,
`CC_AIRCON_QUARTERLY_FEE` VARCHAR(255) NULL,
`USERSTAMP` VARCHAR(255) NULL,
`CC_PRE_TERMINATE_DATE` VARCHAR(255) NULL,
 CC_PROCESSING_WAIVED VARCHAR(255) NULL)'));
PREPARE CREATEQUERYSTMT FROM @CREATEQUERY;
EXECUTE CREATEQUERYSTMT;
SET @INSERTQUERY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT SELECT * FROM ',SOURCESCHEMA,'.CUSTOMER_SCDB_FORMAT'));
PREPARE INSERTQUERYSTMT FROM @INSERTQUERY;
EXECUTE INSERTQUERYSTMT;
SET @UPDATENAME=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT SET cc_last_name=cc_first_name WHERE cc_last_name IS NULL'));
PREPARE UPDATENAMESTMT FROM @UPDATENAME;
EXECUTE UPDATENAMESTMT;
SET @UPDATEROOMTYPESTUDIO1=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT SET cc_roomtype=',"'Studio1'" ,' WHERE cc_roomtype=',"'STUDIO 1'"));
PREPARE UPDATEROOMTYPESTUDIO1STMT FROM @UPDATEROOMTYPESTUDIO1;
EXECUTE UPDATEROOMTYPESTUDIO1STMT;
SET @UPDATEROOMTYPESTUDIO2=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT SET cc_roomtype=',"'Studio2'",' WHERE cc_roomtype=',"'STUDIO 2'"));
PREPARE UPDATEROOMTYPESTUDIO2STMT FROM @UPDATEROOMTYPESTUDIO2;
EXECUTE UPDATEROOMTYPESTUDIO2STMT;
SET @UPDATENATIONALITY=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT SET CC_NATIONALITY =',"'SINGAPORE'",' WHERE CC_NATIONALITY IS NULL'));
PREPARE UPDATENATIONALITYSTMT FROM @UPDATENATIONALITY;
EXECUTE UPDATENATIONALITYSTMT;
SET @UPDATEEMAIL=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT SET CC_EMAIL=',"'expatsintegrated@gmail.com'",' WHERE CC_EMAIL IS NULL'));
PREPARE UPDATEEMAILSTMT FROM @UPDATEEMAIL;
EXECUTE UPDATEEMAILSTMT;
SET @UPDATENATIONALITYSPAIN=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT SET CC_NATIONALITY=',"'SPAIN'", ' WHERE  CC_NATIONALITY LIKE ', "'SPAIN%'"));
PREPARE UPDATENATIONALITYSPAINSTMT FROM @UPDATENATIONALITYSPAIN;
EXECUTE UPDATENATIONALITYSPAINSTMT;
SET @UPDATENATTHAILAND=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT SET CC_NATIONALITY=',"'THAILAND'", ' WHERE  CC_NATIONALITY LIKE ', "'THAILAND%'"));
PREPARE UPDATENATTHAILANDSTMT FROM @UPDATENATTHAILAND;
EXECUTE UPDATENATTHAILANDSTMT;
SET @UPDATERENT=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT SET CC_RENT_AMOUNT=2650 WHERE  CC_ID=479'));
PREPARE UPDATERENTSTMT FROM @UPDATERENT;
EXECUTE UPDATERENTSTMT;
SET @UPDATETIMESTAMP=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_CUSTOMER_SCDB_FORMAT SET TIMESTAMP=(SELECT CONVERT_TZ(TIMESTAMP, "+08:00","+0:00"))'));
PREPARE UPDATETIMESTAMPSTMT FROM @UPDATETIMESTAMP;
EXECUTE UPDATETIMESTAMPSTMT;
COMMIT;
END;