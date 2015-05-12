-->version 0.8 -->start date:28/02/2014 end date:28/02/2014 -->issueno:754 -->comment no:#36 -->description: CHANGING DATA TYPE AND VALUE OF USERSTAMP -->BY BHAVANI.R
-->version 0.7 -->start date:27/02/2014 end date:27/02/2014 -->issueno:754  -->description: REPLACE USERSTAMP VARCAHR TO USERSTAMP INTEGER -->BY BALAJI.R
-->version 0.5 -->start date:26/02/2014 end date:26/02/2014 -->issueno:750  -->description:UPDATING USERSTAMP TO ULD_ID -->created by:SAFI.M
--> version 0.4 -->issue tracker no :749 comment no:#29 startdate:17/02/2014 enddate:17/02/2014 description --> implementation of flag for success message -->Bhavani.R
-- VER 0.3      -->issue tracker no :636 comment no:#47 startdate:08/11/2013 enddate:09/11/2013 description --> changed sp name created by -->Dhivya.A 
--> version 0.2 -->startdate:24/07/2013 -->enddate:24/07/2013 -->description:implemened rollback & commit commands
--> issueno:566 -->done by:rajalakshmi.r
--> version 0.1 -->startdate:31/05/2013 -->description:petty cash insert with current balance --> issueno:512 -->done by:loganathan

DROP PROCEDURE IF EXISTS SP_BIZDLY_PETTY_CASH_INSERT;
CREATE PROCEDURE SP_BIZDLY_PETTY_CASH_INSERT
(
IN USERSTAMP VARCHAR(50),
IN PC_DATE DATE,
IN PC_CASH_IN DECIMAL(7,2),
IN PC_CASH_OUT DECIMAL(7,2),
IN PC_INVOICE_ITEMS VARCHAR(500),
IN PC_COMMENTS TEXT,
out PETTY_CASH_SUCCESSFLAG INTEGER)
  BEGIN
-- VARIABLE DECLARATION
      DECLARE CASH_IN DECIMAL(10,4);
      DECLARE CASH_OUT DECIMAL(10,4);
      DECLARE BALANCE DECIMAL(10,4);
	  DECLARE USERSTAMP_ID INTEGER(2);
      DECLARE EXIT HANDLER FOR SQLEXCEPTION
      BEGIN 
        ROLLBACK; 
      END;

      IF PC_CASH_IN IS NULL THEN
        SET PC_CASH_IN =0;
      END IF;
      IF PC_CASH_OUT IS NULL THEN
        SET PC_CASH_OUT =0;
      END IF;
        SET CASH_IN =(SELECT SUM(EPC_CASH_IN) FROM EXPENSE_PETTY_CASH);
      IF CASH_IN IS NULL THEN
        SET CASH_IN=0;
      END IF;
        SET CASH_OUT =(SELECT SUM(EPC_CASH_OUT) FROM EXPENSE_PETTY_CASH);
      IF CASH_OUT IS NULL THEN
        SET CASH_OUT=0;
      END IF;
      IF CASH_IN IS NOT NULL  THEN
        SET CASH_IN=CASH_IN +PC_CASH_IN  ;
      ELSE
        SET CASH_IN=PC_CASH_IN;
      END IF;
      IF CASH_OUT IS NOT NULL THEN
        SET CASH_OUT=CASH_OUT + PC_CASH_OUT ;
      ELSE
        SET CASH_OUT=PC_CASH_OUT;
      END IF;
        SET BALANCE=CASH_IN-CASH_OUT;
      IF PC_CASH_IN =0 THEN
        SET PC_CASH_IN =NULL;
      END IF;
      IF PC_CASH_OUT =0 THEN
        SET PC_CASH_OUT =NULL;
      END IF;
      START TRANSACTION;
      SET PETTY_CASH_SUCCESSFLAG=0;
	  CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	  SET USERSTAMP_ID = (SELECT @ULDID);
      IF PC_CASH_IN IS NOT NULL OR PC_CASH_OUT IS NOT NULL THEN
-- INSERT QUERY FOR EXPENSE_PETTY_CASH TABLE
        INSERT INTO EXPENSE_PETTY_CASH(ULD_ID,EPC_DATE,EPC_CASH_IN,EPC_CASH_OUT,EPC_BALANCE,EPC_INVOICE_ITEMS,EPC_COMMENTS) VALUES (USERSTAMP_ID,PC_DATE,PC_CASH_IN,PC_CASH_OUT,BALANCE,PC_INVOICE_ITEMS,PC_COMMENTS);
        SET PETTY_CASH_SUCCESSFLAG=1;
      END IF;
      COMMIT;
 END;

