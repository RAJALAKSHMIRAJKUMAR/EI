--ISSUE NO:593 VER0.2 STARTDATE:27/06/2014 ENDDATE:28/06/2014 COMMENT NO:100 DESC:TRIGGER BEFORE UPDATE FOR CUSTOMER_FEE_DETAILS DONE BY:DHIVYA


DROP TRIGGER IF EXISTS TRG_CUSTOMER_FEE_DETAILS_UPDATE_VALIDATION;
CREATE TRIGGER TRG_CUSTOMER_FEE_DETAILS_UPDATE_VALIDATION
BEFORE UPDATE ON CUSTOMER_FEE_DETAILS
FOR EACH ROW  
BEGIN
    CALL SP_TRG_CUSTOMER_FEE_DETAILS_VALIDATION(NEW.CFD_ID,NEW.CUSTOMER_ID,NEW.CPP_ID,NEW.CED_REC_VER,NEW.CFD_AMOUNT,'UPDATE');
END;  