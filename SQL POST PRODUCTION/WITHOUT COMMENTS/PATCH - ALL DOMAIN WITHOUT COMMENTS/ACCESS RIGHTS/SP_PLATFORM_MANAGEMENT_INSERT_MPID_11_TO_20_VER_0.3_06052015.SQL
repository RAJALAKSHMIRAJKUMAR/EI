DROP PROCEDURE IF EXISTS SP_PLATFORM_MANAGEMENT_INSERT_MPID_11_TO_20;
CREATE PROCEDURE SP_PLATFORM_MANAGEMENT_INSERT_MPID_11_TO_20(
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
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('98','11','6','50',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('99','11','8','11','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('100','11','9','157','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('101','11','10','158','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('102','11','12','159','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('103','11','13','160','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('104','11','14','161','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('105','11','15','162','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('106','11','92','149','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('107','11','40','152',NULL,NULL,'X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('108','11','25','163','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('109','11',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('110','12','6','52',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('111','12','9','53','X','X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('112','12','10','54','X','X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('113','12','12','55','X','X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('114','12','13','56','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('115','12','14','11','X','X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('116','12','15','157',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('117','12','92','158','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('118','12','40','159',NULL,NULL,'X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('119','12','25','160',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('120','12',NULL,'161',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('121','12',NULL,'162',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('122','12',NULL,'149',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('123','12',NULL,'152',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('124','12',NULL,'71',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('125','12',NULL,'164',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('126','12',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('127','13','6','51',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('128','13','8','11',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('129','13','9','157',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('130','13','10','158','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('131','13','12','159','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('132','13','13','160','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('133','13','14','161','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('134','13','15','162',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('135','13','92','149','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('136','13','40','152',NULL,NULL,'X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('137','13','25','163',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('138','13',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('139','14','8','72',NULL,'X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('140','14','9','73',NULL,'X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('141','14','10','74',NULL,'X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('142','14','12','83',NULL,'X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('143','14','13','84',NULL,'X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('144','14','14','86',NULL,'X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('145','14','15','88',NULL,'X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('146','14','92','89','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('147','14','25','149',NULL,'X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('148','14',NULL,'157',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('149','14',NULL,'158',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('150','14',NULL,'159',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('151','14',NULL,'160',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('152','14',NULL,'161',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('153','14',NULL,'162',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('154','14',NULL,'71',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('155','14',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('156','14',NULL,'212',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('157','14',NULL,'213',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('158','14',NULL,'214',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('159','14',NULL,'215',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('160','14',NULL,'216',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('161','14',NULL,'217',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('162','15','6','58',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('163','15','13','59',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('164','15','14','60',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('165','15','15','62',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('166','15','92','63','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('167','15','10','156',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('168','15',NULL,'149',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('169','15',NULL,'157',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('170','15',NULL,'161',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('171','15',NULL,'162',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('172','15',NULL,'11',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('173','15',NULL,'71',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('174','15',NULL,'57',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('175','15',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('176','16','6','64',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('177','16','10','65',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('178','16','13','66',NULL,'X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('179','16','15','149',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('180','16','92','155','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('181','16','14','11',NULL,NULL,'X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('182','16',NULL,'157',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('183','16',NULL,'162',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('184','16',NULL,'159',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('185','16',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('186','17','79','141','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('187','17','80','149','X','X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('188','17','92','206','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('189','17',NULL,'142',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('190','17',NULL,'153',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('191','18',NULL,'68',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('192','18',NULL,'69',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('193','18',NULL,'85',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('194','18',NULL,'149',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('195','18',NULL,'70',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('196','18',NULL,'87',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('197','18',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('198','19','6','50',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('199','19','8','11','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('200','19','9','157','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('201','19','10','158','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('202','19','12','159','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('203','19','13','160','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('204','19','14','161','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('205','19','15','162','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('206','19','92','149','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('207','19','40','152',NULL,NULL,'X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('208','19',NULL,'163',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('209','19',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('210','20','51','26','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('211','20','52','27','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('212','20','53','28','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('213','20','54','29','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('214','20','55','30','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('215','20','56','31','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('216','20','57','32','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('217','20','58','33','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('218','20','59','34','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('219','20','60','35','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('220','20','61','36','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('221','20','62','37','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('222','20','63','38','X','X','X');
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('223','20','48','39',NULL,'X',NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('224','20','92','40','X',NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('225','20',NULL,'41',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('226','20',NULL,'42',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('227','20',NULL,'43',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('228','20',NULL,'149',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('229','20',NULL,'153',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('230','20',NULL,'170',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('231','20',NULL,'172',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('232','20',NULL,'173',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('233','20',NULL,'174',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('234','20',NULL,'175',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('235','20',NULL,'176',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('236','20',NULL,'177',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('237','20',NULL,'178',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('238','20',NULL,'179',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('239','20',NULL,'180',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('240','20',NULL,'181',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('241','20',NULL,'182',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('242','20',NULL,'183',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('243','20',NULL,'195',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('244','20',NULL,'196',NULL,NULL,NULL);
		INSERT INTO PLATFORM_MANAGEMENT(PM_ID,MP_ID,TTIP_ID,SPP_ID,PM_INSERT_PRIV,PM_UPDATE_PRIV,PM_DELETE_PRIV) VALUES ('245','20',NULL,'211',NULL,NULL,NULL);
		INSERT INTO PATCH_HISTORY(PO_ID,PH_FILE_NAME,PH_STATUS,ULD_ID) VALUES (2,FILENAME,1,(SELECT ULD_ID FROM USER_LOGIN_DETAILS 
		WHERE ULD_LOGINID=USERSTAMP));
		SET SUCCESS_MESSAGE = SUCCESSECNDATA;
	END IF;
	COMMIT;
END;
CALL SP_PLATFORM_MANAGEMENT_INSERT_MPID_11_TO_20(FILENAME,USERSTAMP,@SUCCESS_MESSAGE);