DROP PROCEDURE IF EXISTS SP_UPDATE_LOWERCASE_TO_UPPERCASE;
CREATE PROCEDURE SP_UPDATE_LOWERCASE_TO_UPPERCASE(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
SET @UPDATEURTD = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.UNIT_ROOM_TYPE_DETAILS SET URTD_ROOM_TYPE = UCASE(URTD_ROOM_TYPE)'));
PREPARE UPDATEURTDSTMT FROM @UPDATEURTD;
EXECUTE UPDATEURTDSTMT;
SET @UPDATEUSDT = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.UNIT_STAMP_DUTY_TYPE SET USDT_DATA = UCASE(USDT_DATA)'));
PREPARE UPDATEUSDTSTMT FROM @UPDATEUSDT;
EXECUTE UPDATEUSDTSTMT;
SET @UPDATEULD = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.UNIT_LOGIN_DETAILS SET ULDTL_WEBLOGIN = UCASE(ULDTL_WEBLOGIN)'));
PREPARE UPDATEULDSTMT FROM @UPDATEULD;
EXECUTE UPDATEULDSTMT;
SET @UPDATEUACD = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.UNIT_ACCOUNT_DETAILS SET UACD_ACC_NAME = UCASE(UACD_ACC_NAME) , UACD_BANK_ADDRESS = UCASE(UACD_BANK_ADDRESS)'));
PREPARE UPDATEUACDSTMT FROM @UPDATEUACD;
EXECUTE UPDATEUACDSTMT;
SET @UPDATECUSTOMER = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.CUSTOMER SET CUSTOMER_FIRST_NAME = UCASE(CUSTOMER_FIRST_NAME) , CUSTOMER_LAST_NAME = UCASE(CUSTOMER_LAST_NAME)'));
PREPARE UPDATECUSTOMERSTMT FROM @UPDATECUSTOMER;
EXECUTE UPDATECUSTOMERSTMT;
SET @UPDATECCD = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.CUSTOMER_COMPANY_DETAILS SET CCD_COMPANY_NAME = UCASE(CCD_COMPANY_NAME) , CCD_COMPANY_ADDR = UCASE(CCD_COMPANY_ADDR)'));
PREPARE UPDATECCDSTMT FROM @UPDATECCD;
EXECUTE UPDATECCDSTMT;
SET @UPDATECPD = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.CUSTOMER_PERSONAL_DETAILS SET CPD_EP_NO = UCASE(CPD_EP_NO) , CPD_PASSPORT_NO = UCASE(CPD_PASSPORT_NO)'));
PREPARE UPDATECPDSTMT FROM @UPDATECPD;
EXECUTE UPDATECPDSTMT;
SET @UPDATEEASB = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EXPENSE_AIRCON_SERVICE_BY SET EASB_DATA = UCASE(EASB_DATA)'));
PREPARE UPDATEEASBSTMT FROM @UPDATEEASB;
EXECUTE UPDATEEASBSTMT;
SET @UPDATEEDSH = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_STARHUB SET EDSH_ACCOUNT_NO = UCASE(EDSH_ACCOUNT_NO) , EDSH_CABLE_BOX_SERIAL_NO = UCASE(EDSH_CABLE_BOX_SERIAL_NO) ,EDSH_MODEM_SERIAL_NO = UCASE(EDSH_MODEM_SERIAL_NO)'));
PREPARE UPDATEEDSHSTMT FROM @UPDATEEDSH;
EXECUTE UPDATEEDSHSTMT;
SET @UPDATEEDDV = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_DIGITAL_VOICE SET EDDV_DIGITAL_ACCOUNT_NO = UCASE(EDDV_DIGITAL_ACCOUNT_NO)'));
PREPARE UPDATEEDDVSTMT FROM @UPDATEEDDV;
EXECUTE UPDATEEDDVSTMT;
SET @UPDATEEDCP = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_CARPARK SET EDCP_CAR_NO = UCASE(EDCP_CAR_NO)'));
PREPARE UPDATEEDCPSTMT FROM @UPDATEEDCP;
EXECUTE UPDATEEDCPSTMT;
SET @UPDATEUNIT = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EXPENSE_UNIT SET EU_INVOICE_FROM = UCASE(EU_INVOICE_FROM)'));
PREPARE UPDATEUNITSTMT FROM @UPDATEUNIT;
EXECUTE UPDATEUNITSTMT;
SET @UPDATEPERSONAL = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EXPENSE_PERSONAL SET EP_INVOICE_FROM = UCASE(EP_INVOICE_FROM)'));
PREPARE UPDATEPERSONALSTMT FROM @UPDATEPERSONAL;
EXECUTE UPDATEPERSONALSTMT;
SET @UPDATEEXPCAR = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EXPENSE_CAR SET EC_INVOICE_FROM = UCASE(EC_INVOICE_FROM)'));
PREPARE UPDATEEXPCARSTMT FROM @UPDATEEXPCAR;
EXECUTE UPDATEEXPCARSTMT;
SET @UPDATEBABY = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EXPENSE_BABY SET EB_INVOICE_FROM = UCASE(EB_INVOICE_FROM)'));
PREPARE UPDATEBABYSTMT FROM @UPDATEBABY;
EXECUTE UPDATEBABYSTMT;
SET @UPDATESTAFF = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EXPENSE_STAFF SET ES_INVOICE_FROM = UCASE(ES_INVOICE_FROM)'));
PREPARE UPDATESTAFFSTMT FROM @UPDATESTAFF;
EXECUTE UPDATESTAFFSTMT;
SET @UPDATEBANKTRANSFER = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.BANK_TRANSFER SET BT_BANK_ADDRESS = UCASE(BT_BANK_ADDRESS) , BT_CUST_REF = UCASE(BT_CUST_REF) , BT_ACC_NAME = UCASE(BT_ACC_NAME)'));
PREPARE UPDATEBANKTRANSFERSTMT FROM @UPDATEBANKTRANSFER;
EXECUTE UPDATEBANKTRANSFERSTMT;
SET @UPDATEBANKTRANSFERMODEL = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.BANK_TRANSFER_MODELS SET BTM_DATA = UCASE(BTM_DATA)'));
PREPARE UPDATEBANKTRANSFERMODELSTMT FROM @UPDATEBANKTRANSFERMODEL;
EXECUTE UPDATEBANKTRANSFERMODELSTMT;
SET @UPDATECHEQUE = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.CHEQUE_ENTRY_DETAILS SET CHEQUE_TO = UCASE(CHEQUE_TO) , CHEQUE_FOR = UCASE(CHEQUE_FOR)'));
PREPARE UPDATECHEQUESTMT FROM @UPDATECHEQUE;
EXECUTE UPDATECHEQUESTMT;
SET @UPDATEERM = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.ERM_ENTRY_DETAILS SET ERM_CUST_NAME  = UCASE(ERM_CUST_NAME )'));
PREPARE UPDATEERMSTMT FROM @UPDATEERM;
EXECUTE UPDATEERMSTMT;
SET @UPDATEEMPDTL = (SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.EMPLOYEE_DETAILS SET EMP_FIRST_NAME = UCASE(EMP_FIRST_NAME) , EMP_LAST_NAME = UCASE(EMP_LAST_NAME)'));
PREPARE UPDATEEMPDTLSTMT FROM @UPDATEEMPDTL;
EXECUTE UPDATEEMPDTLSTMT;
COMMIT;
END;
CALL SP_UPDATE_LOWERCASE_TO_UPPERCASE(DESTINATIONSCHEMA);