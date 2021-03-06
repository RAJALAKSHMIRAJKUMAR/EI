DROP PROCEDURE IF EXISTS SP_UPDATE_CUSTOMER_ACCESS_CARD_DETAILS_PART3;
CREATE PROCEDURE SP_UPDATE_CUSTOMER_ACCESS_CARD_DETAILS_PART3(
IN USERSTAMP VARCHAR(50))
BEGIN
	DECLARE OLDVALUE_ACCESS_TICKLER TEXT;
	DECLARE NEWVALUE_ACCESS_TICKLER TEXT;
	DECLARE OLD_UASDID INTEGER;
	DECLARE NEW_UASDID INTEGER;
	SET FOREIGN_KEY_CHECKS = 0;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(171,597,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 204 ,CACD_TIMESTAMP = CACD_TIMESTAMP WHERE CACD_ID = 597;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(171,597,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,171,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(175,128,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 184,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 128;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(175,128,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,175,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(176,227,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 46,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 227;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(176,227,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,176,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(179,114,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 166,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 114;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(179,114,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,179,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(182,33,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 106,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 33;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(182,33,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,182,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(183,575,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 170,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 575;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(183,575,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,183,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(186,422,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 166,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 422;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(186,422,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,186,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(187,674,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 5,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 674;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(187,674,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,187,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(191,686,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 49,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 686;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(191,686,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,191,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(193,475,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 20 ,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 475;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(193,475,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,193,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(194,98,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=555555),CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 98;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(194,98,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,194,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(198,185,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 285 ,CACD_TIMESTAMP = CACD_TIMESTAMP WHERE CACD_ID = 185;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(198,185,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,198,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(199,341,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 26,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 341;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(199,341,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,199,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(199,487,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 170,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 487;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(199,487,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,199,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(201,111,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID =  (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=6666666),CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 111;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(201,111,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,201,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(212,484,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 134,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 484;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(212,484,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,212,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(214,30,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD = 222222),CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 30;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(214,30,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,214,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(216,306,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 292,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 306;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(216,306,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,216,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(217,550,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 49,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 550;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(217,550,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,217,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(219,57,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD = 1111111),CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 57;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(219,57,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,219,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(221,40,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 182,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 40;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(221,40,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,221,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(223,384,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD = 22222),CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 384;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(223,384,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,223,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(227,301,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 150,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 301;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(227,301,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,227,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));		
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(209,500,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 20,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 500;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(209,500,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,209,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));		
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(232,610,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 9,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 610;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(232,610,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,232,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(233,302,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 98 ,CACD_TIMESTAMP = CACD_TIMESTAMP WHERE CACD_ID = 302;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(233,302,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,233,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(234,265,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 168,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 265;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(234,265,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,234,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(235,120,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD = 88888),CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 120;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(235,120,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,235,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(237,442,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 106,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 442;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(237,442,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,237,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(242,630,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 92,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 630;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(242,630,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,242,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(247,141,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 27,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 141;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(247,141,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,247,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(249,510,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 22,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 510;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(249,510,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,249,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(259,527,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 124 ,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 527;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(259,527,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,259,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(259,325,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 233,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 325;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(259,325,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,259,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(262,362,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 124,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 362;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(262,362,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,262,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(271,166,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = 32,CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 166;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(271,166,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,271,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_OLDVALUE(271,295,USERSTAMP,@OLDVALUE_ACCESS,@OLDUASDID);
		SET OLDVALUE_ACCESS_TICKLER = @OLDVALUE_ACCESS;
		SET OLD_UASDID = @OLDUASDID;
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET UASD_ID = (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD = 111111),CACD_TIMESTAMP=CACD_TIMESTAMP WHERE CACD_ID = 295;
		CALL SP_ACCESS_CARD_TICKLER_HISTORY_NEWVALUE(271,295,USERSTAMP,@NEWVALUE_ACCESS,@NEWUASDID);
		SET NEWVALUE_ACCESS_TICKLER=@NEWVALUE_ACCESS;
		SET NEW_UASDID = @NEWUASDID;
		IF(OLD_UASDID != NEW_UASDID)THEN
			INSERT INTO TICKLER_HISTORY(TP_ID,CUSTOMER_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID)VALUES
			(1,271,13,OLDVALUE_ACCESS_TICKLER, NEWVALUE_ACCESS_TICKLER ,(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERSTAMP));
		END IF;
END;	
