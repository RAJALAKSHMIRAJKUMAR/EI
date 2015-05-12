DROP PROCEDURE IF EXISTS SP_TRG_CUSTOMER_PERSONAL_DETAILS_VALIDATION;
CREATE PROCEDURE  SP_TRG_CUSTOMER_PERSONAL_DETAILS_VALIDATION(
IN NEWCUSTOMERID INTEGER,
IN NEWMOBILE VARCHAR(8),
IN NEWINTLMOBILE VARCHAR(20),
IN NEWPASSPORTNO VARCHAR(15),
IN NEWPASSPORTDATE DATE,
IN NEWEPNO VARCHAR(15),
IN NEWEPDATE DATE,
IN PROCESS VARCHAR(20))
BEGIN
	DECLARE CLPENDDATE DATE;
	DECLARE CLPPREDATE DATE;
	DECLARE END_DATE DATE;
	DECLARE MAXRECVER INTEGER;
	DECLARE MESSAGE_TEXT VARCHAR(50);
	SET MAXRECVER=(SELECT MAX(CED_REC_VER) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=NEWCUSTOMERID);
	SET CLPPREDATE=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=NEWCUSTOMERID AND CED_REC_VER=MAXRECVER AND CLP_GUEST_CARD IS NULL);
	SET CLPENDDATE=(SELECT CLP_ENDDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=NEWCUSTOMERID AND CED_REC_VER=MAXRECVER AND CLP_GUEST_CARD IS NULL);
	IF(CLPPREDATE IS NOT NULL)THEN
		SET END_DATE=CLPPREDATE;
	ELSE
		SET END_DATE=CLPENDDATE;
	END IF;
	IF(PROCESS='INSERT') OR (PROCESS='UPDATE')THEN
		IF(NEWMOBILE IS NOT NULL)THEN
			IF(LENGTH(NEWMOBILE)<6) THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT= 'CPD_MOBILE NUMBER SHOULD BE MINIMUM 6 DIGITS.'; 
			END IF;
		END IF;
		IF(NEWINTLMOBILE IS NOT NULL)THEN
			IF(LENGTH(NEWINTLMOBILE)<6) THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT= 'CPD_INTL_MOBILE NUMBER SHOULD BE MINIMUM 6 DIGITS.'; 
			END IF;
		END IF;
		IF(NEWPASSPORTNO IS NOT NULL)THEN
			IF(LENGTH(NEWPASSPORTNO)<6) THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT= 'CPD_PASSPORT_NO SHOULD BE MINIMUM 6 DIGITS.'; 
			END IF;
		END IF;
		IF(NEWPASSPORTDATE IS NOT NULL)THEN  
			IF(NEWPASSPORTDATE <=END_DATE)THEN 
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT= 'CPD_PASSPORT_DATE SHOULD BE GREATER THAN CUSTOMER ENDDATE.'; 
			END IF;  
		END IF;
		IF(NEWPASSPORTDATE IS NOT NULL)THEN  
			IF(NEWPASSPORTDATE <=CURDATE())THEN 
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT= 'CPD_PASSPORT_DATE SHOULD BE GREATER THAN TODAY DATE.'; 
			END IF;  
		END IF;
		IF(NEWPASSPORTDATE IS NOT NULL)THEN 
			IF(NEWPASSPORTDATE > CURDATE() AND NEWPASSPORTDATE > END_DATE)THEN
				IF (NEWPASSPORTDATE > DATE_ADD(CURDATE(), INTERVAL 10 YEAR)) THEN
					SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT= 'CPD_PASSPORT_DATE SHOULD BE WITHIN 10 YEARS FROM TODAY DATE';    
				END IF; 
			END IF;
		END IF;
		IF(NEWEPNO IS NOT NULL)THEN
			IF(LENGTH(NEWEPNO)<6) THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT= 'CPD_EP_NO SHOULD BE MINIMUM 6 DIGITS.'; 
			END IF;
		END IF;
		IF(NEWEPDATE IS NOT NULL)THEN  
			IF(NEWEPDATE <=END_DATE)THEN 
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT= 'CPD_EP_DATE SHOULD BE GREATER THAN CUSTOMER ENDDATE.'; 
			END IF;  
		END IF;
		IF(NEWEPDATE IS NOT NULL)THEN  
			IF(NEWEPDATE <=CURDATE())THEN 
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT= 'CPD_EP_DATE SHOULD BE GREATER THAN TODAY DATE.'; 
			END IF;  
		END IF;
		IF(NEWEPDATE IS NOT NULL)THEN 
			IF(NEWEPDATE > CURDATE() AND NEWEPDATE > END_DATE)THEN
				IF (NEWEPDATE > DATE_ADD(CURDATE(), INTERVAL 3 YEAR)) THEN 
					SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT= 'CPD_EP_DATE SHOULD BE WITHIN 3 YEARS FROM TODAY DATE';
				END IF;
			END IF;
		END IF;
	END IF;
END;