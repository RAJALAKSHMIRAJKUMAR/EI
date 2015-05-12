-- version:0.2 --sadte:09/06/2014 --edate:09/06/2014 --issue:566 COMMNT:12--desc:IMPLEMENTED ROLL BACK AND COMMIT --done by:DHIVYA
--version:0.1 --sdate:22/05/2014 --edate:22/05/2014 --issue:765 --comment no#145 --desc:changed userstamp datatype as text --done by:rl
DROP PROCEDURE IF EXISTS SP_UPDATE_TIMESTAMP_DATATYPE_AS_VARCHAR;
CREATE PROCEDURE SP_UPDATE_TIMESTAMP_DATATYPE_AS_VARCHAR(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;
	SET @URTD_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.UNIT_ROOM_TYPE_DETAILS MODIFY COLUMN URTD_TIMESTAMP TEXT NOT NULL'));
	PREPARE URTD_DTLS_STMT FROM @URTD_DTLS;
	EXECUTE URTD_DTLS_STMT;
	SET @USDT_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.UNIT_STAMP_DUTY_TYPE MODIFY COLUMN USDT_TIMESTAMP TEXT NOT NULL'));
	PREPARE USDT_DTLS_STMT FROM @USDT_DTLS;
	EXECUTE USDT_DTLS_STMT;
	SET @UD_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.UNIT_DETAILS MODIFY COLUMN UD_TIMESTAMP TEXT NOT NULL'));
	PREPARE UD_DTLS_STMT FROM @UD_DTLS;
	EXECUTE UD_DTLS_STMT;
	SET @ULDTL_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.UNIT_LOGIN_DETAILS MODIFY COLUMN ULDTL_TIMESTAMP TEXT NOT NULL'));
	PREPARE ULDTL_DTLS_STMT FROM @ULDTL_DTLS;
	EXECUTE ULDTL_DTLS_STMT;
	SET @UASD_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.UNIT_ACCESS_STAMP_DETAILS MODIFY COLUMN UASD_TIMESTAMP TEXT NOT NULL'));
	PREPARE UASD_DTLS_STMT FROM @UASD_DTLS;
	EXECUTE UASD_DTLS_STMT;
	SET @CPP_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.CUSTOMER_PAYMENT_PROFILE MODIFY COLUMN CPP_TIMESTAMP TEXT NOT NULL'));
	PREPARE CPP_DTLS_STMT FROM @CPP_DTLS;
	EXECUTE CPP_DTLS_STMT;
	SET @CACD_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.CUSTOMER_ACCESS_CARD_DETAILS MODIFY COLUMN CACD_TIMESTAMP TEXT NOT NULL'));
	PREPARE CACD_DTLS_STMT FROM @CACD_DTLS;
	EXECUTE CACD_DTLS_STMT;
	SET @CLP_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.CUSTOMER_LP_DETAILS MODIFY COLUMN CLP_TIMESTAMP TEXT NOT NULL'));
	PREPARE CLP_DTLS_STMT FROM @CLP_DTLS;
	EXECUTE CLP_DTLS_STMT;
	SET @TH_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.TICKLER_HISTORY MODIFY COLUMN TH_TIMESTAMP TEXT NOT NULL'));
	PREPARE TH_DTLS_STMT FROM @TH_DTLS;
	EXECUTE TH_DTLS_STMT;
	SET @ETD_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EMAIL_TEMPLATE_DETAILS MODIFY COLUMN ETD_TIMESTAMP TEXT NOT NULL'));
	PREPARE ETD_DTLS_STMT FROM @ETD_DTLS;
	EXECUTE ETD_DTLS_STMT;
	SET @EL_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EMAIL_LIST MODIFY COLUMN EL_TIMESTAMP TEXT NOT NULL'));
	PREPARE EL_DTLS_STMT FROM @EL_DTLS;
	EXECUTE EL_DTLS_STMT;
	SET @PD_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.PAYMENT_DETAILS MODIFY COLUMN PD_TIMESTAMP TEXT NOT NULL'));
	PREPARE PD_DTLS_STMT FROM @PD_DTLS;
	EXECUTE PD_DTLS_STMT;
	SET @EMP_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EMPLOYEE_DETAILS MODIFY COLUMN EMP_TIMESTAMP TEXT NOT NULL'));
	PREPARE EMP_DTLS_STMT FROM @EMP_DTLS;
	EXECUTE EMP_DTLS_STMT;
	SET @EDSS_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_STAFF_SALARY MODIFY COLUMN EDSS_TIMESTAMP TEXT NOT NULL'));
	PREPARE EDSS_DTLS_STMT FROM @EDSS_DTLS;
	EXECUTE EDSS_DTLS_STMT;
	SET @ESS_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_STAFF_SALARY MODIFY COLUMN ESS_TIMESTAMP TEXT NOT NULL'));
	PREPARE ESS_DTLS_STMT FROM @ESS_DTLS;
	EXECUTE ESS_DTLS_STMT;
	SET @ES_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_STAFF MODIFY COLUMN ES_TIMESTAMP TEXT NOT NULL'));
	PREPARE ES_DTLS_STMT FROM @ES_DTLS;
	EXECUTE ES_DTLS_STMT;
	SET @EA_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_AGENT MODIFY COLUMN EA_TIMESTAMP TEXT NOT NULL'));
	PREPARE EA_DTLS_STMT FROM @EA_DTLS;
	EXECUTE EA_DTLS_STMT;
	SET @EASB_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_AIRCON_SERVICE_BY MODIFY COLUMN EASB_TIMESTAMP TEXT NOT NULL'));
	PREPARE EASB_DTLS_STMT FROM @EASB_DTLS;
	EXECUTE EASB_DTLS_STMT;
	SET @EDSH_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_STARHUB MODIFY COLUMN EDSH_TIMESTAMP TEXT NOT NULL'));
	PREPARE EDSH_DTLS_STMT FROM @EDSH_DTLS;
	EXECUTE EDSH_DTLS_STMT;
	SET @EDE_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_ELECTRICITY MODIFY COLUMN EDE_TIMESTAMP TEXT NOT NULL'));
	PREPARE EDE_DTLS_STMT FROM @EDE_DTLS;
	EXECUTE EDE_DTLS_STMT;
	SET @EDDV_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_DIGITAL_VOICE MODIFY COLUMN EDDV_TIMESTAMP TEXT NOT NULL'));
	PREPARE EDDV_DTLS_STMT FROM @EDDV_DTLS;
	EXECUTE EDDV_DTLS_STMT;
	SET @EDAS_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_AIRCON_SERVICE MODIFY COLUMN EDAS_TIMESTAMP TEXT NOT NULL'));
	PREPARE EDAS_DTLS_STMT FROM @EDAS_DTLS;
	EXECUTE EDAS_DTLS_STMT;
	SET @EDCP_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_DETAIL_CARPARK MODIFY COLUMN EDCP_TIMESTAMP TEXT NOT NULL'));
	PREPARE EDCP_DTLS_STMT FROM @EDCP_DTLS;
	EXECUTE EDCP_DTLS_STMT;
	SET @EU_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_UNIT MODIFY COLUMN EU_TIMESTAMP TEXT NOT NULL'));
	PREPARE EU_DTLS_STMT FROM @EU_DTLS;
	EXECUTE EU_DTLS_STMT;
	SET @EE_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_ELECTRICITY MODIFY COLUMN EE_TIMESTAMP TEXT NOT NULL'));
	PREPARE EE_DTLS_STMT FROM @EE_DTLS;
	EXECUTE EE_DTLS_STMT;
	SET @ESH_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_STARHUB MODIFY COLUMN ESH_TIMESTAMP TEXT NOT NULL'));
	PREPARE ESH_DTLS_STMT FROM @ESH_DTLS;
	EXECUTE ESH_DTLS_STMT;
	SET @EDV_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_DIGITAL_VOICE MODIFY COLUMN EDV_TIMESTAMP TEXT NOT NULL'));
	PREPARE EDV_DTLS_STMT FROM @EDV_DTLS;
	EXECUTE EDV_DTLS_STMT;
	SET @EFU_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_FACILITY_USE MODIFY COLUMN EFU_TIMESTAMP TEXT NOT NULL'));
	PREPARE EFU_DTLS_STMT FROM @EFU_DTLS;
	EXECUTE EFU_DTLS_STMT;
	SET @ECP_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_CARPARK MODIFY COLUMN ECP_TIMESTAMP TEXT NOT NULL'));
	PREPARE ECP_DTLS_STMT FROM @ECP_DTLS;
	EXECUTE ECP_DTLS_STMT;
	SET @EMIO_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_MOVING_IN_AND_OUT  MODIFY COLUMN EMIO_TIMESTAMP TEXT NOT NULL'));
	PREPARE EMIO_DTLS_STMT FROM @EMIO_DTLS;
	EXECUTE EMIO_DTLS_STMT;
	SET @EAS_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_AIRCON_SERVICE MODIFY COLUMN EAS_TIMESTAMP TEXT NOT NULL'));
	PREPARE EAS_DTLS_STMT FROM @EAS_DTLS;
	EXECUTE EAS_DTLS_STMT;
	SET @ENPC_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_PURCHASE_NEW_CARD  MODIFY COLUMN EPNC_TIMESTAMP TEXT NOT NULL'));
	PREPARE ENPC_DTLS_STMT FROM @ENPC_DTLS;
	EXECUTE ENPC_DTLS_STMT;
	SET @EPC_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_PETTY_CASH MODIFY COLUMN EPC_TIMESTAMP TEXT NOT NULL'));
	PREPARE EPC_DTLS_STMT FROM @EPC_DTLS;
	EXECUTE EPC_DTLS_STMT;
	SET @EHK_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_HOUSEKEEPING  MODIFY COLUMN EHK_TIMESTAMP TEXT NOT NULL'));
	PREPARE EHK_DTLS_STMT FROM @EHK_DTLS;
	EXECUTE EHK_DTLS_STMT;
	SET @EHKP_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_HOUSEKEEPING_PAYMENT MODIFY COLUMN EHKP_TIMESTAMP TEXT NOT NULL'));
	PREPARE EHKP_DTLS_STMT FROM @EHKP_DTLS;
	EXECUTE EHKP_DTLS_STMT;
	SET @EHKU_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_HOUSEKEEPING_UNIT  MODIFY COLUMN EHKU_TIMESTAMP TEXT NOT NULL'));
	PREPARE EHKU_DTLS_STMT FROM @EHKU_DTLS;
	EXECUTE EHKU_DTLS_STMT;
	SET @EP_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_PERSONAL MODIFY COLUMN EP_TIMESTAMP TEXT NOT NULL'));
	PREPARE EP_DTLS_STMT FROM @EP_DTLS;
	EXECUTE EP_DTLS_STMT;
	SET @EC_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_CAR  MODIFY COLUMN EC_TIMESTAMP TEXT NOT NULL'));
	PREPARE EC_DTLS_STMT FROM @EC_DTLS;
	EXECUTE EC_DTLS_STMT;
	SET @EB_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_BABY MODIFY COLUMN EB_TIMESTAMP TEXT NOT NULL'));
	PREPARE EB_DTLS_STMT FROM @EB_DTLS;
	EXECUTE EB_DTLS_STMT;
	SET @ECL_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.EXPENSE_CAR_LOAN MODIFY COLUMN ECL_TIMESTAMP TEXT NOT NULL'));
	PREPARE ECL_DTLS_STMT FROM @ECL_DTLS;
	EXECUTE ECL_DTLS_STMT;
	SET @RC_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.ROLE_CREATION  MODIFY COLUMN RC_TIMESTAMP TEXT NOT NULL'));
	PREPARE RC_DTLS_STMT FROM @RC_DTLS;
	EXECUTE RC_DTLS_STMT;
	SET @ULD_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS MODIFY COLUMN ULD_TIMESTAMP TEXT NOT NULL'));
	PREPARE ULD_DTLS_STMT FROM @ULD_DTLS;
	EXECUTE ULD_DTLS_STMT;
	SET @UA_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.USER_ACCESS MODIFY COLUMN UA_TIMESTAMP TEXT NOT NULL'));
	PREPARE UA_DTLS_STMT FROM @UA_DTLS;
	EXECUTE UA_DTLS_STMT;
	SET @MD_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.USER_MENU_DETAILS  MODIFY COLUMN MD_TIMESTAMP TEXT NOT NULL'));
	PREPARE MD_DTLS_STMT FROM @MD_DTLS;
	EXECUTE MD_DTLS_STMT;
	SET @UFD_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.USER_FILE_DETAILS MODIFY COLUMN UFD_TIMESTAMP TEXT NOT NULL'));
	PREPARE UFD_DTLS_STMT FROM @UFD_DTLS;
	EXECUTE UFD_DTLS_STMT;
	SET @BRP_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.BASIC_ROLE_PROFILE MODIFY COLUMN BRP_TIMESTAMP TEXT NOT NULL'));
	PREPARE BRP_DTLS_STMT FROM @BRP_DTLS;
	EXECUTE BRP_DTLS_STMT;
	SET @BMP_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.BASIC_MENU_PROFILE MODIFY COLUMN BMP_TIMESTAMP TEXT NOT NULL'));
	PREPARE BMP_DTLS_STMT FROM @BMP_DTLS;
	EXECUTE BMP_DTLS_STMT;
	SET @TED_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.TRIGGER_EXECUTION_DETAILS MODIFY COLUMN TED_TIMESTAMP TEXT NOT NULL'));
	PREPARE TED_DTLS_STMT FROM @TED_DTLS;
	EXECUTE TED_DTLS_STMT;
	SET @BTM_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.BANK_TRANSFER_MODELS MODIFY COLUMN BTM_TIMESTAMP TEXT NOT NULL'));
	PREPARE BTM_DTLS_STMT FROM @BTM_DTLS;
	EXECUTE BTM_DTLS_STMT;
	SET @BT_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.BANK_TRANSFER MODIFY COLUMN BT_TIMESTAMP TEXT NOT NULL'));
	PREPARE BT_DTLS_STMT FROM @BT_DTLS;
	EXECUTE BT_DTLS_STMT;
	SET @CHEQUE_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.CHEQUE_ENTRY_DETAILS MODIFY COLUMN CHEQUE_TIMESTAMP TEXT NOT NULL'));
	PREPARE CHEQUE_DTLS_STMT FROM @CHEQUE_DTLS;
	EXECUTE CHEQUE_DTLS_STMT;
	SET @ERMO_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.ERM_OCCUPATION_DETAILS MODIFY COLUMN ERMO_TIMESTAMP TEXT NOT NULL'));
	PREPARE ERMO_DTLS_STMT FROM @ERMO_DTLS;
	EXECUTE ERMO_DTLS_STMT;
	SET @ERM_DTLS = (SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.ERM_ENTRY_DETAILS MODIFY COLUMN ERM_TIMESTAMP TEXT NOT NULL'));
	PREPARE ERM_DTLS_STMT FROM @ERM_DTLS;
	EXECUTE ERM_DTLS_STMT;
	COMMIT;
END;
CALL SP_UPDATE_TIMESTAMP_DATATYPE_AS_VARCHAR(DESTINATIONSCHEMA);