DROP PROCEDURE IF EXISTS SP_PLATFORM_MANAGEMENT_INSERT_MPID_21_TO_30;
CREATE PROCEDURE SP_PLATFORM_MANAGEMENT_INSERT_MPID_21_TO_30(
IN FILENAME TEXT,
IN USERSTAMP VARCHAR(50),
OUT SUCCESS_MESSAGE TEXT)
BEGIN
	DECLARE FAILURE_ECN_DATA TEXT;
	DECLARE FAIL_ECNDATA TEXT;
    DECLARE SUCCESS_ECNDATA TEXT;
	DECLARE FAILURE_ECNDATA TEXT;
	DECLARE SUCCESSECNDATA TEXT;
	DECLARE FAILUREECNDATA TEXT;
	DECLARE PATCHFILENAME VARCHAR(100);
	DECLARE PHSTATUS TINYINT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK;
		INSERT INTO PATCH_HISTORY(PO_ID,PH_FILE_NAME,PH_STATUS,ULD_ID) VALUES (2,FILENAME,0,(SELECT ULD_ID FROM USER_LOGIN_DETAILS 
		WHERE ULD_LOGINID=USERSTAMP));
		SET SUCCESS_MESSAGE = FAIL_ECNDATA;
	END;
	START TRANSACTION;
	SET SUCCESS_ECNDATA =  (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=469);
	SET FAILURE_ECNDATA =  (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=470);
	SET FAILURE_ECN_DATA = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=473);
	SET SUCCESSECNDATA = (SELECT REPLACE(SUCCESS_ECNDATA,'[FILENAME]',FILENAME));
	SET FAILUREECNDATA = (SELECT REPLACE(FAILURE_ECNDATA,'[FILENAME]',FILENAME));
	SET FAIL_ECNDATA = (SELECT REPLACE(FAILURE_ECN_DATA,'[FILENAME]',FILENAME));
	IF EXISTS(SELECT PH_FILE_NAME FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME AND PH_STATUS = 1) THEN
		SET SUCCESS_MESSAGE = FAILUREECNDATA;
	END IF;	
	SET PATCHFILENAME = (SELECT PH_FILE_NAME FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME);
	SET PHSTATUS = (SELECT PH_STATUS FROM PATCH_HISTORY WHERE PH_FILE_NAME = FILENAME AND PH_STATUS = 0);
	IF ((PATCHFILENAME IS NOT NULL) AND (PHSTATUS = 0)) OR (PATCHFILENAME IS NULL)THEN
	INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('246','21','45','25','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('247','21','46','149','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('248','21','47','153','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('249','21','48','170','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('250','21','49','184','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('251','21','50','185','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('252','21','92','186','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('253','21',NULL,'194',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('254','22','64','46','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('255','22','65','47','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('256','22','66','48','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('257','22','67','49','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('258','22','92','149','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('259','22',NULL,'153',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('260','22',NULL,'187',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('261','22',NULL,'188',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('262','22',NULL,'189',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('263','22',NULL,'190',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('264','23','42','44','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('265','23','43','45','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('266','23','44','149','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('267','23','92','153','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('268','23',NULL,'191',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('269','23',NULL,'192',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('270','23',NULL,'193',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('271','23',NULL,'197',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('272','23',NULL,'198',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('273','24','41','149','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('274','24','92','151','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('275','24',NULL,'153',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('276','24',NULL,'200',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('277','25','39','21','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('278','25','40','22','X',NULL,'X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('279','25','92','23','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('280','25',NULL,'24',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('281','25',NULL,'149',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('282','25',NULL,'152',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('283','25',NULL,'171',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('284','25',NULL,'199',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('285','26',NULL,'131',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('286','26',NULL,'132',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('287','26',NULL,'133',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('288','26',NULL,'134',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('289','26',NULL,'135',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('290','26',NULL,'136',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('291','26',NULL,'137',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('292','26',NULL,'208',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('293','26',NULL,'149',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('294','26',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('295','27','20',NULL,NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('296','28','18','127','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('297','28','81','209',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('298','28',NULL,'149',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('299','28',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('300','29','18','127','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('301','29','81','209',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('302','29',NULL,'149',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('303','29',NULL,'130',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('304','29',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('305','30',NULL,'125',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('306','30',NULL,'210',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('307','30',NULL,'149',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('308','30',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PATCH_HISTORY(PO_ID,PH_FILE_NAME,PH_STATUS,ULD_ID) VALUES (2,FILENAME,1,(SELECT ULD_ID FROM USER_LOGIN_DETAILS 
		WHERE ULD_LOGINID=USERSTAMP));
		SET SUCCESS_MESSAGE = SUCCESSECNDATA;
	END IF;
	COMMIT;
END;
CALL SP_PLATFORM_MANAGEMENT_INSERT_MPID_21_TO_30(FILENAME,USERSTAMP,@SUCCESS_MESSAGE);