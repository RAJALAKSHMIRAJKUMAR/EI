-- version:0.7 -- sdate:17/03/2014 -- edate:17/03/2014 -- issue:765 --desc:droped temp table --doneby:RL
--version:0.6--sdate:22/02/2014 --edate:22/02/2014 --issue:750 -desc:changes source timestamp and userstamp as uld_id done by:dhivya
--version:0.5--sdate:22/02/2014 --edate:22/02/2014 --issue:750 -desc:added preaudit and post audit queries done by:dhivya
--version:0.4 --sdate:04/02/2014 --edate:04/02/2014 --desc:removed source table updation sp  --done by:RL
--version:0.3 --sdate:01/02/2014 --edate:01/02/2014 --desc:looping changed as cursor --done by:RL & DHIVYA


DROP PROCEDURE IF EXISTS SP_TEMP_PERSONAL_SCDB_FORMAT;
CREATE PROCEDURE SP_TEMP_PERSONAL_SCDB_FORMAT()
BEGIN
--QUERY FOR CREATE TEMP_PERSONAL_SCDB_FORMAT TABLE
DROP TABLE IF EXISTS TEMP_PERSONAL_SCDB_FORMAT;
CREATE TABLE TEMP_PERSONAL_SCDB_FORMAT LIKE PERSONAL_SCDB_FORMAT;
--QUERY FOR INSERT VALUES TEMP_PERSONAL_SCDB_FORMAT TABLE	
INSERT INTO TEMP_PERSONAL_SCDB_FORMAT SELECT * FROM PERSONAL_SCDB_FORMAT;
--QUERY FOR UPDATE VALUES TEMP_PERSONAL_SCDB_FORMAT TABLE	
UPDATE TEMP_PERSONAL_SCDB_FORMAT SET PE_CAR_EXP_TYPE = 'CASH CARD' WHERE PE_CAR_EXP_TYPE = 'Cash Card/Coupon';
UPDATE TEMP_PERSONAL_SCDB_FORMAT SET PE_BABY_EXPENSE = 'HEALTH CARE/HOSPITAL EXPENSES' WHERE PE_BABY_EXPENSE = 'HEALTH CARE/HOSPITAL EXPENSE';
DELETE FROM TEMP_PERSONAL_SCDB_FORMAT WHERE PE_ID IN(2225,3154);
END;

DROP PROCEDURE IF EXISTS SP_MIG_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM_SPLIT_INSERT;
CREATE PROCEDURE SP_MIG_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM_SPLIT_INSERT()
BEGIN
	DECLARE DONE INT DEFAULT FALSE;
	DECLARE PEID INTEGER;
	DECLARE BABYCOMMENTS TEXT;
	DECLARE ITEMLOCATION INTEGER;
	DECLARE FROMLOCATION INTEGER;
	DECLARE INVOICEITEM TEXT;
	DECLARE INVOICEFROM TEXT;
	DECLARE INVITEM1 TEXT;
	DECLARE INVITEM2 TEXT;
	DECLARE INVFROM TEXT;
	DECLARE COMMENTS_LOCATION INTEGER;
	DECLARE FILTER_CURSOR CURSOR FOR 
	SELECT PE_ID,PE_BABY_COMMENTS,PE_BABY_INVOICE_ITEMS,PE_BABY_INVOICE_FROM FROM PERSONAL_SCDB_FORMAT WHERE PE_TYPE_OF_EXPENSE='BABY' AND PE_BABY_INVOICE_ITEMS IS NULL AND PE_CAR_EXP_INVOICE_FROM IS NULL ;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
	DROP TABLE IF EXISTS TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM;
	CREATE TABLE TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM(ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,PE_ID INT NOT NULL ,PE_BABY_COMMENTS TEXT,PE_INVOICE_ITEM TEXT,PE_INVOICE_FROM TEXT);
	OPEN FILTER_CURSOR;
		read_loop: LOOP
			FETCH FILTER_CURSOR INTO PEID,BABYCOMMENTS,INVOICEITEM,INVOICEFROM;
			IF DONE THEN
				LEAVE read_loop;
			END IF;
			SET COMMENTS_LOCATION=(SELECT LOCATE('\n\n',BABYCOMMENTS));
			SET ITEMLOCATION=(SELECT LOCATE('\n\n',BABYCOMMENTS,COMMENTS_LOCATION+1));
			SET FROMLOCATION=(SELECT LOCATE('\n\n',BABYCOMMENTS,ITEMLOCATION+1));
			SET INVITEM1=(SELECT SUBSTRING(BABYCOMMENTS,COMMENTS_LOCATION+2,ITEMLOCATION-(COMMENTS_LOCATION+2)));
			SET INVITEM2=(SELECT SUBSTRING(BABYCOMMENTS,ITEMLOCATION+2,FROMLOCATION-(ITEMLOCATION+2)));
			SET INVITEM2=(SELECT CONCAT(INVITEM1,INVITEM2));
			SET INVFROM=(SELECT SUBSTRING(BABYCOMMENTS,FROMLOCATION+2));
			IF(COMMENTS_LOCATION!=0) AND (ITEMLOCATION!=0) AND(FROMLOCATION!=0) THEN
				INSERT INTO TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM(PE_ID,PE_BABY_COMMENTS,PE_INVOICE_ITEM,PE_INVOICE_FROM)VALUES(PEID,BABYCOMMENTS,INVITEM2,INVFROM);
			END IF;
		END LOOP;
	CLOSE FILTER_CURSOR;
	IF EXISTS(SELECT PE_ID FROM TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3856)THEN
        DELETE FROM TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3856;
    END IF;
    IF EXISTS(SELECT PE_ID FROM TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3919)THEN
        DELETE FROM TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3919;
    END IF;
    IF EXISTS(SELECT PE_ID FROM TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3974)THEN
        DELETE FROM TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3974;
    END IF;
    IF EXISTS(SELECT PE_ID FROM TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=4049)THEN
        DELETE FROM TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=4049;
    END IF;
END;

DROP PROCEDURE IF EXISTS SP_MIG_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM_SPLIT_INSERT;
CREATE PROCEDURE SP_MIG_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM_SPLIT_INSERT()
BEGIN
	DECLARE DONE INT DEFAULT FALSE;
	DECLARE PEID INTEGER;
	DECLARE BABYCOMMENTS TEXT;
	DECLARE ITEMLOCATION INTEGER;
	DECLARE FROMLOCATION INTEGER;
	DECLARE INVOICEITEM TEXT;
	DECLARE INVOICEFROM TEXT;
	DECLARE INVITEM TEXT;
	DECLARE INVFROM TEXT;
	DECLARE FILTER_CURSOR CURSOR FOR 
	SELECT PE_ID,PE_BABY_COMMENTS,PE_BABY_INVOICE_ITEMS,PE_BABY_INVOICE_FROM FROM VW_MIG_TEMP_EXP_BABY_REMAINING_COMMENTS;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
	DROP TABLE IF EXISTS TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM;
	CREATE TABLE TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM(ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,PE_ID INT NOT NULL ,PE_BABY_COMMENTS TEXT,PE_INVOICE_ITEM TEXT,PE_INVOICE_FROM TEXT);
	OPEN FILTER_CURSOR;
		read_loop: LOOP
			FETCH FILTER_CURSOR INTO PEID,BABYCOMMENTS,INVOICEITEM,INVOICEFROM;
			IF DONE THEN
				LEAVE read_loop;
			END IF;
			SET ITEMLOCATION=(SELECT LOCATE('\n\n',BABYCOMMENTS));
			SET FROMLOCATION=(SELECT LOCATE('\n\n',BABYCOMMENTS,ITEMLOCATION+1));
			SET INVITEM=(SELECT SUBSTRING(BABYCOMMENTS,ITEMLOCATION+2,FROMLOCATION-(ITEMLOCATION+2)));
			SET INVFROM=(SELECT SUBSTRING(BABYCOMMENTS,FROMLOCATION+2));
			IF(ITEMLOCATION!=0) AND (FROMLOCATION!=0) THEN
				INSERT INTO TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM(PE_ID,PE_BABY_COMMENTS,PE_INVOICE_ITEM,PE_INVOICE_FROM)VALUES(PEID,BABYCOMMENTS,INVITEM,INVFROM);
			END IF;
		END LOOP;
	CLOSE FILTER_CURSOR;
	IF EXISTS(SELECT PE_ID FROM TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3856)THEN
        DELETE FROM TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3856;
    END IF;
    IF EXISTS(SELECT PE_ID FROM TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3919)THEN
        DELETE FROM TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3919;
    END IF;
    IF EXISTS(SELECT PE_ID FROM TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3974)THEN
        DELETE FROM TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=3974;
    END IF;
    IF EXISTS(SELECT PE_ID FROM TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=4049)THEN
        DELETE FROM TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=4049;
    END IF;
END;

DROP PROCEDURE IF EXISTS SP_MIG_EXP_BABY_SLASHN_INVOICE_FROM_ITEM_SPLIT_INSERT;
CREATE PROCEDURE SP_MIG_EXP_BABY_SLASHN_INVOICE_FROM_ITEM_SPLIT_INSERT()
BEGIN
	DECLARE DONE INT DEFAULT FALSE;
	DECLARE PEID INTEGER;
	DECLARE BABYCOMMENTS TEXT;
	DECLARE ITEMLOCATION INTEGER;
	DECLARE FROMLOCATION INTEGER;
	DECLARE INVOICEITEM TEXT;
	DECLARE INVOICEFROM TEXT;
	DECLARE INVITEM TEXT;
	DECLARE INVFROM TEXT;
	DECLARE FILTER_CURSOR CURSOR FOR 
	SELECT PE_ID,PE_BABY_COMMENTS,PE_BABY_INVOICE_ITEMS,PE_BABY_INVOICE_FROM FROM VW_MIG_TEMP_EXP_BABY_SINGLE_SLASHN_REMAINING_COMMENTS;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
	DROP TABLE IF EXISTS TEMP_EXP_BABY_SLASHN_INVOICE_FROM_ITEM;
	CREATE TABLE TEMP_EXP_BABY_SLASHN_INVOICE_FROM_ITEM(ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,PE_ID INT NOT NULL ,PE_BABY_COMMENTS TEXT,PE_INVOICE_ITEM TEXT,PE_INVOICE_FROM TEXT);
	OPEN FILTER_CURSOR;
		read_loop: LOOP
			FETCH FILTER_CURSOR INTO PEID,BABYCOMMENTS,INVOICEITEM,INVOICEFROM;
			IF DONE THEN
				LEAVE read_loop;
			END IF;
			SET ITEMLOCATION=(SELECT LOCATE('\n',BABYCOMMENTS));
			SET FROMLOCATION=(SELECT LOCATE('\n\n',BABYCOMMENTS,ITEMLOCATION+1));
			SET INVITEM=(SELECT SUBSTRING(BABYCOMMENTS,ITEMLOCATION+1,FROMLOCATION-(ITEMLOCATION+1)));
			SET INVFROM=(SELECT SUBSTRING(BABYCOMMENTS,FROMLOCATION+2));
			IF(ITEMLOCATION!=0) AND (FROMLOCATION!=0) THEN
				INSERT INTO TEMP_EXP_BABY_SLASHN_INVOICE_FROM_ITEM(PE_ID,PE_BABY_COMMENTS,PE_INVOICE_ITEM,PE_INVOICE_FROM)VALUES(PEID,BABYCOMMENTS,INVITEM,INVFROM);
			END IF;
		END LOOP;
	CLOSE FILTER_CURSOR;
END;

DROP PROCEDURE IF EXISTS SP_BABY_INVOICE_ITEM_FROM_SPLIT;
CREATE PROCEDURE SP_BABY_INVOICE_ITEM_FROM_SPLIT()
BEGIN
DROP TABLE IF EXISTS TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE;
CREATE TABLE TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE(
ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
PE_ID INTEGER,
PE_COMMENTS TEXT,
PE_INVOICE_ITEMS TEXT,
PE_INVOICE_FROM TEXT);

SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS EXPENSE_BABY;
CREATE TABLE EXPENSE_BABY(
EB_ID INTEGER NOT NULL AUTO_INCREMENT,
ECN_ID INTEGER NOT NULL,
EB_INVOICE_DATE DATE NOT NULL,
EB_AMOUNT DECIMAL(7,2) NOT NULL,
EB_INVOICE_ITEMS TEXT NOT NULL,
EB_INVOICE_FROM VARCHAR(200) NOT NULL,
EB_COMMENTS TEXT,
ULD_ID INTEGER(2) NOT NULL,
EB_TIMESTAMP TIMESTAMP NOT NULL,
PRIMARY KEY(EB_ID),
FOREIGN KEY(ECN_ID)REFERENCES EXPENSE_CONFIGURATION(ECN_ID),
FOREIGN KEY (ULD_ID)REFERENCES USER_LOGIN_DETAILS(ULD_ID));
SET FOREIGN_KEY_CHECKS=1;

--INSERT QUERY FOR BABY EXPENSE
INSERT INTO TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE(PE_ID,PE_COMMENTS,PE_INVOICE_ITEMS,PE_INVOICE_FROM)
SELECT PE_ID,PE_BABY_COMMENTS,PE_INVOICE_ITEM,PE_INVOICE_FROM FROM TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM;
INSERT INTO TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE(PE_ID,PE_COMMENTS,PE_INVOICE_ITEMS,PE_INVOICE_FROM)
SELECT PE_ID,PE_BABY_COMMENTS,PE_INVOICE_ITEM,PE_INVOICE_FROM FROM TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM;
INSERT INTO TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE(PE_ID,PE_COMMENTS,PE_INVOICE_ITEMS,PE_INVOICE_FROM)
SELECT PE_ID,PE_BABY_COMMENTS,PE_INVOICE_ITEM,PE_INVOICE_FROM FROM TEMP_EXP_BABY_SLASHN_INVOICE_FROM_ITEM;

CREATE OR REPLACE VIEW VW_BABY_REMAINING_COMMENTS AS  SELECT t1.PE_ID
FROM PERSONAL_SCDB_FORMAT t1
LEFT JOIN TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE t2 ON t2.PE_ID = t1.PE_ID
WHERE t2.PE_ID IS NULL AND t1.PE_TYPE_OF_EXPENSE='BABY';

INSERT INTO TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE(PE_ID,PE_COMMENTS,PE_INVOICE_ITEMS,PE_INVOICE_FROM)
SELECT PSCDB.PE_ID,PSCDB.PE_BABY_COMMENTS,PSCDB.PE_BABY_INVOICE_ITEMS,PSCDB.PE_BABY_INVOICE_FROM FROM
PERSONAL_SCDB_FORMAT PSCDB,VW_BABY_REMAINING_COMMENTS T WHERE T.PE_ID=PSCDB.PE_ID AND PSCDB.PE_TYPE_OF_EXPENSE='BABY';
UPDATE TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE SET PE_INVOICE_ITEMS='NO ITEM' WHERE PE_INVOICE_ITEMS IS NULL OR PE_INVOICE_ITEMS=' ';
UPDATE TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE SET PE_INVOICE_FROM='NO FROM' WHERE PE_INVOICE_FROM IS NULL OR PE_INVOICE_FROM=' ';
DROP TABLE IF EXISTS TEMP_EXP_BABY_SINGLE_SLASHN_INVOICE_FROM_ITEM;
DROP TABLE IF EXISTS TEMP_EXP_BABY_DOUBLE_SLASHN_INVOICE_FROM_ITEM;
DROP TABLE IF EXISTS TEMP_EXP_BABY_SLASHN_INVOICE_FROM_ITEM;

END;


--QUERY FOR INSERT VALUES EXPENSE_BABY TABLE   
DROP PROCEDURE IF EXISTS SP_EXPENSE_BABY_INSERT;
CREATE PROCEDURE SP_EXPENSE_BABY_INSERT()
BEGIN
DECLARE DONE INT DEFAULT FALSE;
DECLARE PEID INTEGER;
DECLARE BABYEXPENSE TEXT;
DECLARE INVOICEDATE DATE;
DECLARE BABYAMOUNT DECIMAL(7,2);
DECLARE INVOICEITEM TEXT;
DECLARE INVOICEFROM VARCHAR(200);
DECLARE COMMENTS TEXT;
DECLARE BABYUSERSTAMP VARCHAR(50);
DECLARE BABYTIMESTAMP TIMESTAMP;
DECLARE FILTER_CURSOR CURSOR FOR 
SELECT TPSF.PE_ID,TPSF.PE_BABY_EXPENSE,TPSF.PE_BABY_INVOICE_DATE,TPSF.PE_BABY_AMOUNT, TPSF.USERSTAMP,TPSF.TIMESTAMP
FROM TEMP_PERSONAL_SCDB_FORMAT TPSF WHERE TPSF.PE_TYPE_OF_EXPENSE='BABY';
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
OPEN FILTER_CURSOR;
read_loop: LOOP
FETCH FILTER_CURSOR INTO PEID,BABYEXPENSE,INVOICEDATE,BABYAMOUNT,BABYUSERSTAMP,BABYTIMESTAMP;
IF DONE THEN
LEAVE read_loop;
END IF;
INSERT INTO EXPENSE_BABY(ECN_ID,EB_INVOICE_DATE,EB_AMOUNT,EB_INVOICE_ITEMS,EB_INVOICE_FROM,EB_COMMENTS,ULD_ID,EB_TIMESTAMP)
VALUES((SELECT ECN_ID FROM EXPENSE_CONFIGURATION WHERE ECN_DATA=BABYEXPENSE AND CGN_ID=25),INVOICEDATE,BABYAMOUNT,
(SELECT DISTINCT PE_INVOICE_ITEMS FROM TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE WHERE PE_ID=PEID),
(SELECT DISTINCT PE_INVOICE_FROM FROM TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE WHERE PE_ID=PEID),
(SELECT DISTINCT PE_COMMENTS FROM TEMP_BABY_INVOICE_ITEM_FROM_SPLITTED_TABLE WHERE PE_ID=PEID),(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=BABYUSERSTAMP),BABYTIMESTAMP);
END LOOP;
CLOSE FILTER_CURSOR;
END;



