DROP PROCEDURE IF EXISTS SP_CUSTOMER_EXTENSION_FEE_DTLS_INSERT;
CREATE PROCEDURE SP_CUSTOMER_EXTENSION_FEE_DTLS_INSERT(
IN EX_CUSTOMER_ID INTEGER,
IN EX_RENT DECIMAL(7,2),
IN EX_DEPOSIT DECIMAL(7,2),
IN EX_PROCESSING_FEE DECIMAL(7,2),
IN EX_AIRCON_FIXED_FEE DECIMAL(7,2),
IN EX_AIRCON_QUARTELY_FEE DECIMAL(7,2),
IN EX_ELECTRICITY_CAP DECIMAL(7,2),
IN EX_CHECKOUT_CLEANING_FEE DECIMAL(7,2),
IN EX_DRYCLEAN_FEE DECIMAL(7,2),
IN REC_VER INTEGER,
OUT EX_SUCCESSFLAG TEXT)
BEGIN		
	IF EX_RENT IS NOT NULL THEN			
		INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,1,EX_RENT);
		SET EX_SUCCESSFLAG=1;		
	END IF;			
	IF EX_DEPOSIT IS NOT NULL THEN			
		INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,2,EX_DEPOSIT);
		SET EX_SUCCESSFLAG=1;			
	END IF;			
	IF EX_PROCESSING_FEE IS NOT NULL THEN			
		INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,3,EX_PROCESSING_FEE);
		SET EX_SUCCESSFLAG=1;			
	END IF;			
	IF EX_AIRCON_FIXED_FEE IS NOT NULL THEN				
		INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,4,EX_AIRCON_FIXED_FEE);
		SET EX_SUCCESSFLAG=1;			
	END IF;			
	IF EX_ELECTRICITY_CAP IS NOT NULL THEN			
		INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,5,EX_ELECTRICITY_CAP);
		SET EX_SUCCESSFLAG=1;		
	END IF;			
	IF EX_DRYCLEAN_FEE IS NOT NULL THEN			
		INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,6,EX_DRYCLEAN_FEE);
		SET EX_SUCCESSFLAG=1;		
	END IF;			
	IF EX_AIRCON_QUARTELY_FEE IS NOT NULL THEN			
		INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,7,EX_AIRCON_QUARTELY_FEE);
		SET EX_SUCCESSFLAG=1;		
	END IF;			
	IF EX_CHECKOUT_CLEANING_FEE IS NOT NULL THEN			
		INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,8,EX_CHECKOUT_CLEANING_FEE);
		SET EX_SUCCESSFLAG=1;		
	END IF;
END;
