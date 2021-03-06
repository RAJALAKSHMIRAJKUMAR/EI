-- VERSION :0.8 TRACKER: 738, START DATE: 12-06-2014, END DATE: 12-06-2014, DESC: implementing trigger changes for not updating primary key in tickler_history   DONE BY: BHAVANI.R
--version 0.7 --sdate:05/06/2014 --edate:05/06/2014 --issue:529 --commentno:#196 --desc:ADD ULD_ID AND TIMESTAMP TO UPDATE OLD VALUE DONE BY:BHAVANI.R
--version:0.6 --sdate:07/04/2014 --edate:07/04/2014 --issue:797 --commentno:28 --comment: table name and header changed --done by:raghu
-- VER:0.5, TRACKER: 529, COMMENT:#105 ,START DATE: 10-02-2014, END DATE: 10-02-2014, DESC: added comma after one header value is completed, DONE BY: MANIKANDAN S
-- version 0.4 sdate:07/02/2014 --edate:07/02/2014 --issue:738 --commentno:#1 --desc:ADDED ONE CONDITION FOR NOT CREATING NULL ROW IN TICKLER_HISTORY DONE BY:DHIVYA
-- version 0.3 sdate:28/01/2014 --edate:28/01/2014 --issue:536 commentno#39 --desc:CHANGED BANK_TRANSFER TABLE HEADERS AS PER TABLE MODIFICATION DONE BY:DHIVYA.A
-- version 0.2 sdate:10/11/2013 --edate:10/11/2013 --issue:636 commentno#47 --desc:trigger name changed by rl
-- version 0.1 start date:12/10/2013 end date:14/10/2013-->issueno:529 -->commentno:53 -->desc:TRIGGER UPDATION QUERY FOR BANK_TRANSFER TABLE done by:dhivya
DROP TRIGGER IF EXISTS TRG_BANK_TRANSER_UPDATE;
CREATE TRIGGER TRG_BANK_TRANSER_UPDATE
AFTER UPDATE ON BANK_TRANSFER
FOR EACH ROW
BEGIN 
-- declaration for old_value and new_value to store it in TICKLER_HISTORY table
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF (OLD.BTM_ID!= NEW.BTM_ID) OR (OLD.BTM_ID IS NULL AND NEW.BTM_ID IS NOT NULL) OR (OLD.BTM_ID IS NOT NULL AND NEW.BTM_ID IS NULL) OR (OLD.BT_DATE!= NEW.BT_DATE) OR (OLD.BT_AMOUNT!= NEW.BT_AMOUNT) OR (OLD.BT_ACC_NAME IS NULL AND NEW.BT_ACC_NAME IS NOT NULL) OR (OLD.BT_ACC_NAME IS NOT NULL AND NEW.BT_ACC_NAME IS NULL) OR (OLD.BT_ACC_NAME!= NEW.BT_ACC_NAME) OR (OLD.BT_ACC_NO IS NULL AND NEW.BT_ACC_NO IS NOT NULL) OR (OLD.BT_ACC_NO IS NOT NULL AND NEW.BT_ACC_NO IS NULL) OR (OLD.BT_ACC_NO!= NEW.BT_ACC_NO) OR (OLD.BT_BANK_CODE IS NULL AND NEW.BT_BANK_CODE IS NOT NULL) OR (OLD.BT_BANK_CODE IS NOT NULL AND NEW.BT_BANK_CODE IS NULL) OR (OLD.BT_BANK_CODE!= NEW.BT_BANK_CODE) OR (OLD.BT_BRANCH_CODE IS NULL AND NEW.BT_BRANCH_CODE IS NOT NULL) OR (OLD.BT_BRANCH_CODE IS NOT NULL AND NEW.BT_BRANCH_CODE IS NULL) OR (OLD.BT_BRANCH_CODE!= NEW.BT_BRANCH_CODE) OR (OLD.BT_BANK_ADDRESS IS NULL AND NEW.BT_BANK_ADDRESS IS NOT NULL) OR (OLD.BT_BANK_ADDRESS IS NOT NULL AND NEW.BT_BANK_ADDRESS IS NULL) OR (OLD.BT_BANK_ADDRESS!= NEW.BT_BANK_ADDRESS) OR (OLD.BT_SWIFT_CODE IS NULL AND NEW.BT_SWIFT_CODE IS NOT NULL) OR (OLD.BT_SWIFT_CODE IS NOT NULL AND NEW.BT_SWIFT_CODE IS NULL) OR (OLD.BT_SWIFT_CODE!= NEW.BT_SWIFT_CODE) OR (OLD.BT_CUST_REF IS NULL AND NEW.BT_CUST_REF IS NOT NULL) OR (OLD.BT_CUST_REF IS NOT NULL AND NEW.BT_CUST_REF IS NULL) OR (OLD.BT_CUST_REF!= NEW.BT_CUST_REF) OR (OLD.BT_INV_DETAILS IS NULL AND NEW.BT_INV_DETAILS IS NOT NULL) OR (OLD.BT_INV_DETAILS IS NOT NULL AND NEW.BT_INV_DETAILS IS NULL) OR (OLD.BT_INV_DETAILS!= NEW.BT_INV_DETAILS) OR (OLD.BT_DEBITED_ON IS NULL AND NEW.BT_DEBITED_ON IS NOT NULL) OR (OLD.BT_DEBITED_ON IS NOT NULL AND NEW.BT_DEBITED_ON IS NULL) OR (OLD.BT_DEBITED_ON!= NEW.BT_DEBITED_ON) OR (OLD.BT_COMMENTS IS NULL AND NEW.BT_COMMENTS IS NOT NULL) OR (OLD.BT_COMMENTS IS NOT NULL AND NEW.BT_COMMENTS IS NULL) OR (OLD.BT_COMMENTS!= NEW.BT_COMMENTS) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'BT_ID=', OLD.BT_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for BTM_ID to store it in TICKLER_HISTORY table
IF (OLD.BTM_ID IS NULL AND NEW.BTM_ID IS NOT NULL) THEN
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BTM_ID=','<NULL>,');
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BTM_ID=',NEW.BTM_ID,',');
ELSEIF (OLD.BTM_ID IS NOT NULL AND NEW.BTM_ID IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BTM_ID=',OLD.BTM_ID,',');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BTM_ID=','<NULL>');
ELSEIF (OLD.BTM_ID!= NEW.BTM_ID) THEN 
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BTM_ID=', OLD.BTM_ID,','); 
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BTM_ID=', NEW.BTM_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for BT_DATE to store it in TICKLER_HISTORY table
IF (OLD.BT_DATE!= NEW.BT_DATE) THEN SET 
    OLD_VALUE = CONCAT(OLD_VALUE,'BT_DATE=', OLD.BT_DATE,','); 
END IF;
IF (OLD.BT_DATE!= NEW.BT_DATE) THEN SET 
  NEW_VALUE = CONCAT(NEW_VALUE,'BT_DATE=', NEW.BT_DATE,','); 
END IF;
IF (OLD.BT_AMOUNT!= NEW.BT_AMOUNT) THEN SET 
  OLD_VALUE = CONCAT(OLD_VALUE,'BT_AMOUNT=', OLD.BT_AMOUNT,','); 
END IF;
IF (OLD.BT_AMOUNT!= NEW.BT_AMOUNT) THEN SET 
  NEW_VALUE = CONCAT(NEW_VALUE,'BT_AMOUNT=', NEW.BT_AMOUNT,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for BT_ACC_NAME to store it in TICKLER_HISTORY table
IF (OLD.BT_ACC_NAME IS NULL AND NEW.BT_ACC_NAME IS NOT NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_ACC_NAME=','<NULL>,');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_ACC_NAME=',NEW.BT_ACC_NAME,',');
ELSEIF (OLD.BT_ACC_NAME IS NOT NULL AND NEW.BT_ACC_NAME IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_ACC_NAME=',OLD.BT_ACC_NAME,',');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_ACC_NAME=','<NULL>,');
ELSEIF (OLD.BT_ACC_NAME!= NEW.BT_ACC_NAME) THEN 
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BT_ACC_NAME=', OLD.BT_ACC_NAME,','); 
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BT_ACC_NAME=', NEW.BT_ACC_NAME,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for BT_ACC_NO to store it in TICKLER_HISTORY table
IF (OLD.BT_ACC_NO IS NULL AND NEW.BT_ACC_NO IS NOT NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_ACC_NO=','<NULL>,');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_ACC_NO=',NEW.BT_ACC_NO,',');
ELSEIF (OLD.BT_ACC_NO IS NOT NULL AND NEW.BT_ACC_NO IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_ACC_NO=',OLD.BT_ACC_NO,',');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_ACC_NO=','<NULL>,');
ELSEIF (OLD.BT_ACC_NO!= NEW.BT_ACC_NO) THEN 
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BT_ACC_NO=', OLD.BT_ACC_NO,','); 
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BT_ACC_NO=', NEW.BT_ACC_NO,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for BT_BANK_CODE to store it in TICKLER_HISTORY table
IF (OLD.BT_BANK_CODE IS NULL AND NEW.BT_BANK_CODE IS NOT NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_BANK_CODE=','<NULL>,');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_BANK_CODE=',NEW.BT_BANK_CODE,',');
ELSEIF (OLD.BT_BANK_CODE IS NOT NULL AND NEW.BT_BANK_CODE IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_BANK_CODE=',OLD.BT_BANK_CODE,',');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_BANK_CODE=','<NULL>,');
ELSEIF (OLD.BT_BANK_CODE!= NEW.BT_BANK_CODE) THEN 
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BT_BANK_CODE=', OLD.BT_BANK_CODE,','); 
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BT_BANK_CODE=', NEW.BT_BANK_CODE,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for BT_BRANCH_CODE to store it in TICKLER_HISTORY table
IF (OLD.BT_BRANCH_CODE IS NULL AND NEW.BT_BRANCH_CODE IS NOT NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_BRANCH_CODE=','<NULL>,');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_BRANCH_CODE=',NEW.BT_BRANCH_CODE,',');
ELSEIF (OLD.BT_BRANCH_CODE IS NOT NULL AND NEW.BT_BRANCH_CODE IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_BRANCH_CODE=',OLD.BT_BRANCH_CODE,',');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_BRANCH_CODE=','<NULL>,');
ELSEIF (OLD.BT_BRANCH_CODE!= NEW.BT_BRANCH_CODE) THEN 
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BT_BRANCH_CODE=', OLD.BT_BRANCH_CODE,','); 
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BT_BRANCH_CODE=', NEW.BT_BRANCH_CODE,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for BT_BANK_ADDRESS to store it in TICKLER_HISTORY table
IF (OLD.BT_BANK_ADDRESS IS NULL AND NEW.BT_BANK_ADDRESS IS NOT NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_BANK_ADDRESS=','<NULL>,');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_BANK_ADDRESS=',NEW.BT_BANK_ADDRESS,',');
ELSEIF (OLD.BT_BANK_ADDRESS IS NOT NULL AND NEW.BT_BANK_ADDRESS IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_BANK_ADDRESS=',OLD.BT_BANK_ADDRESS,',');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_BANK_ADDRESS=','<NULL>,');
ELSEIF (OLD.BT_BANK_ADDRESS!= NEW.BT_BANK_ADDRESS) THEN 
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BT_BANK_ADDRESS=', OLD.BT_BANK_ADDRESS,','); 
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BT_BANK_ADDRESS=', NEW.BT_BANK_ADDRESS,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for BT_SWIFT_CODE to store it in TICKLER_HISTORY table
IF (OLD.BT_SWIFT_CODE IS NULL AND NEW.BT_SWIFT_CODE IS NOT NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_SWIFT_CODE=','<NULL>,');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_SWIFT_CODE=',NEW.BT_SWIFT_CODE,',');
ELSEIF (OLD.BT_SWIFT_CODE IS NOT NULL AND NEW.BT_SWIFT_CODE IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_SWIFT_CODE=',OLD.BT_SWIFT_CODE,',');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_SWIFT_CODE=','<NULL>,');
ELSEIF (OLD.BT_SWIFT_CODE!= NEW.BT_SWIFT_CODE) THEN 
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BT_SWIFT_CODE=', OLD.BT_SWIFT_CODE,','); 
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BT_SWIFT_CODE=', NEW.BT_SWIFT_CODE,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for BT_CUST_REF to store it in TICKLER_HISTORY table
IF (OLD.BT_CUST_REF IS NULL AND NEW.BT_CUST_REF IS NOT NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_CUST_REF=','<NULL>,');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_CUST_REF=',NEW.BT_CUST_REF,',');
ELSEIF (OLD.BT_CUST_REF IS NOT NULL AND NEW.BT_CUST_REF IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_CUST_REF=',OLD.BT_CUST_REF,',');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_CUST_REF=','<NULL>,');
ELSEIF (OLD.BT_CUST_REF!= NEW.BT_CUST_REF) THEN 
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BT_CUST_REF=', OLD.BT_CUST_REF,','); 
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BT_CUST_REF=', NEW.BT_CUST_REF,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for BT_INV_DETAILS to store it in TICKLER_HISTORY table
IF (OLD.BT_INV_DETAILS IS NULL AND NEW.BT_INV_DETAILS IS NOT NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_INV_DETAILS=','<NULL>,');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_INV_DETAILS=',NEW.BT_INV_DETAILS,',');
ELSEIF (OLD.BT_INV_DETAILS IS NOT NULL AND NEW.BT_INV_DETAILS IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_INV_DETAILS=',OLD.BT_INV_DETAILS,',');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_INV_DETAILS=','<NULL>,');
ELSEIF (OLD.BT_INV_DETAILS!= NEW.BT_INV_DETAILS) THEN 
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BT_INV_DETAILS=', OLD.BT_INV_DETAILS,','); 
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BT_INV_DETAILS=', NEW.BT_INV_DETAILS,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for BT_DEBITED_ON to store it in TICKLER_HISTORY table
IF (OLD.BT_DEBITED_ON IS NULL AND NEW.BT_DEBITED_ON IS NOT NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_DEBITED_ON=','<NULL>,');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_DEBITED_ON=',NEW.BT_DEBITED_ON,',');
ELSEIF (OLD.BT_DEBITED_ON IS NOT NULL AND NEW.BT_DEBITED_ON IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_DEBITED_ON=',OLD.BT_DEBITED_ON,',');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_DEBITED_ON=','<NULL>,');
ELSEIF (OLD.BT_DEBITED_ON!= NEW.BT_DEBITED_ON) THEN 
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BT_DEBITED_ON=', OLD.BT_DEBITED_ON,','); 
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BT_DEBITED_ON=', NEW.BT_DEBITED_ON,','); 
END IF;

-- get the OLD VALUE & NEW_VALUE for BT_COMMENTS to store it in TICKLER_HISTORY table
IF (OLD.BT_COMMENTS IS NULL AND NEW.BT_COMMENTS IS NOT NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_COMMENTS=','<NULL>,');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_COMMENTS=',NEW.BT_COMMENTS,',');
ELSEIF (OLD.BT_COMMENTS IS NOT NULL AND NEW.BT_COMMENTS IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'BT_COMMENTS=',OLD.BT_COMMENTS,',');
    SET NEW_VALUE=CONCAT(NEW_VALUE,'BT_COMMENTS=','<NULL>,');
ELSEIF (OLD.BT_COMMENTS!= NEW.BT_COMMENTS) THEN 
    SET OLD_VALUE = CONCAT(OLD_VALUE,'BT_COMMENTS=', OLD.BT_COMMENTS,','); 
    SET NEW_VALUE = CONCAT(NEW_VALUE,'BT_COMMENTS=', NEW.BT_COMMENTS,','); 
END IF;
IF (OLD.BTM_ID!= NEW.BTM_ID) OR (OLD.BTM_ID IS NULL AND NEW.BTM_ID IS NOT NULL) OR (OLD.BTM_ID IS NOT NULL AND NEW.BTM_ID IS NULL) OR (OLD.BT_DATE!= NEW.BT_DATE) OR (OLD.BT_AMOUNT!= NEW.BT_AMOUNT) OR (OLD.BT_ACC_NAME IS NULL AND NEW.BT_ACC_NAME IS NOT NULL) OR (OLD.BT_ACC_NAME IS NOT NULL AND NEW.BT_ACC_NAME IS NULL) OR (OLD.BT_ACC_NAME!= NEW.BT_ACC_NAME) OR (OLD.BT_ACC_NO IS NULL AND NEW.BT_ACC_NO IS NOT NULL) OR (OLD.BT_ACC_NO IS NOT NULL AND NEW.BT_ACC_NO IS NULL) OR (OLD.BT_ACC_NO!= NEW.BT_ACC_NO) OR (OLD.BT_BANK_CODE IS NULL AND NEW.BT_BANK_CODE IS NOT NULL) OR (OLD.BT_BANK_CODE IS NOT NULL AND NEW.BT_BANK_CODE IS NULL) OR (OLD.BT_BANK_CODE!= NEW.BT_BANK_CODE) OR (OLD.BT_BRANCH_CODE IS NULL AND NEW.BT_BRANCH_CODE IS NOT NULL) OR (OLD.BT_BRANCH_CODE IS NOT NULL AND NEW.BT_BRANCH_CODE IS NULL) OR (OLD.BT_BRANCH_CODE!= NEW.BT_BRANCH_CODE) OR (OLD.BT_BANK_ADDRESS IS NULL AND NEW.BT_BANK_ADDRESS IS NOT NULL) OR (OLD.BT_BANK_ADDRESS IS NOT NULL AND NEW.BT_BANK_ADDRESS IS NULL) OR (OLD.BT_BANK_ADDRESS!= NEW.BT_BANK_ADDRESS) OR (OLD.BT_SWIFT_CODE IS NULL AND NEW.BT_SWIFT_CODE IS NOT NULL) OR (OLD.BT_SWIFT_CODE IS NOT NULL AND NEW.BT_SWIFT_CODE IS NULL) OR (OLD.BT_SWIFT_CODE!= NEW.BT_SWIFT_CODE) OR (OLD.BT_CUST_REF IS NULL AND NEW.BT_CUST_REF IS NOT NULL) OR (OLD.BT_CUST_REF IS NOT NULL AND NEW.BT_CUST_REF IS NULL) OR (OLD.BT_CUST_REF!= NEW.BT_CUST_REF) OR (OLD.BT_INV_DETAILS IS NULL AND NEW.BT_INV_DETAILS IS NOT NULL) OR (OLD.BT_INV_DETAILS IS NOT NULL AND NEW.BT_INV_DETAILS IS NULL) OR (OLD.BT_INV_DETAILS!= NEW.BT_INV_DETAILS) OR (OLD.BT_DEBITED_ON IS NULL AND NEW.BT_DEBITED_ON IS NOT NULL) OR (OLD.BT_DEBITED_ON IS NOT NULL AND NEW.BT_DEBITED_ON IS NULL) OR (OLD.BT_DEBITED_ON!= NEW.BT_DEBITED_ON) OR (OLD.BT_COMMENTS IS NULL AND NEW.BT_COMMENTS IS NOT NULL) OR (OLD.BT_COMMENTS IS NOT NULL AND NEW.BT_COMMENTS IS NULL) OR (OLD.BT_COMMENTS!= NEW.BT_COMMENTS) THEN  
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.BT_TIMESTAMP!= NEW.BT_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'BT_TIMESTAMP=', OLD.BT_TIMESTAMP,','); 
END IF;
END IF;
  IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
    IF (OLD_VALUE!=NEW_VALUE)THEN
    
     SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
     SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
    
    -- inserting old_values and new_values in the TICKLER_HISTORY table with their corresponding POSTTAP_ID in TICKLER_TABID_PROFILE
        INSERT INTO TICKLER_HISTORY
        (ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
        ((SELECT ULD_ID FROM BANK_TRANSFER  WHERE BT_ID=NEW.BT_ID),
        (SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
        (SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='BANK_TRANSFER'),OLD_VALUE,NEW_VALUE);
    END IF;
  END IF;
END;