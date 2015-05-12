DROP PROCEDURE IF EXISTS SP_CAR_INVOICE_ITEM_FROM_SPLITTING;
CREATE PROCEDURE SP_CAR_INVOICE_ITEM_FROM_SPLITTING(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
	SET FOREIGN_KEY_CHECKS=0;
	SET @DROPEXPCAR=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.EXPENSE_CAR'));
	PREPARE DROPEXPCARSTMT FROM @DROPEXPCAR;
	EXECUTE DROPEXPCARSTMT;
	SET @CREATEEXPCAR = (SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.EXPENSE_CAR(
	EC_ID INTEGER NOT NULL AUTO_INCREMENT,
	ECN_ID INTEGER NOT NULL,
	EC_INVOICE_DATE DATE NOT NULL,
	EC_AMOUNT DECIMAL(7,2) NOT NULL,
	EC_INVOICE_ITEMS TEXT NOT NULL,
	EC_INVOICE_FROM VARCHAR(200) NOT NULL,
	EC_COMMENTS TEXT,
	ULD_ID INTEGER(2) NOT NULL,
	EC_TIMESTAMP TIMESTAMP NOT NULL,
	PRIMARY KEY(EC_ID),
	FOREIGN KEY(ECN_ID)REFERENCES ',DESTINATIONSCHEMA,'.EXPENSE_CONFIGURATION(ECN_ID),
	FOREIGN KEY (ULD_ID)REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
	PREPARE CREATEEXPCARSTMT FROM @CREATEEXPCAR;
	EXECUTE CREATEEXPCARSTMT;
	SET FOREIGN_KEY_CHECKS=1;
	DROP TABLE IF EXISTS TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE;
	CREATE TABLE TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE(
	ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
	PE_ID INTEGER,
	PE_COMMENTS TEXT,
	PE_INVOICE_ITEMS TEXT,
	PE_INVOICE_FROM TEXT);
	INSERT INTO TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE(PE_ID,PE_COMMENTS,PE_INVOICE_ITEMS,PE_INVOICE_FROM)
	SELECT PE_ID,PE_CAR_EXP_COMMENTS,PE_INVOICE_ITEM,PE_INVOICE_FROM FROM TEMP_EXP_CAR_DOUBLE_SLASHN_INVOICE_FROM_ITEM;
	INSERT INTO TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE(PE_ID,PE_COMMENTS,PE_INVOICE_ITEMS,PE_INVOICE_FROM)
	SELECT PE_ID,PE_CAR_EXP_COMMENTS,PE_INVOICE_ITEM,PE_INVOICE_FROM FROM TEMP_EXP_CAR_SINGLE_SLASHN_INVOICE_FROM_ITEM;
	INSERT INTO TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE(PE_ID,PE_COMMENTS,PE_INVOICE_ITEMS,PE_INVOICE_FROM)
	SELECT PE_ID,PE_CAR_EXP_COMMENTS,PE_INVOICE_ITEM,PE_INVOICE_FROM FROM TEMP_EXP_CAR_SLASHN_INVOICE_FROM_ITEM;
	CREATE OR REPLACE VIEW VW_CAR_REMAINING_COMMENTS AS  SELECT t1.PE_ID
	FROM PERSONAL_SCDB_FORMAT t1
	LEFT JOIN TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE t2 ON t2.PE_ID = t1.PE_ID
	WHERE t2.PE_ID IS NULL AND PE_TYPE_OF_EXPENSE='CAR EXPENSE';
	INSERT INTO TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE(PE_ID,PE_COMMENTS,PE_INVOICE_ITEMS,PE_INVOICE_FROM)
	SELECT PSCDB.PE_ID,PSCDB.PE_CAR_EXP_COMMENTS,PSCDB.PE_CAR_EXP_INVOICE_ITEMS,PSCDB.PE_CAR_EXP_INVOICE_FROM FROM
	PERSONAL_SCDB_FORMAT PSCDB,VW_CAR_REMAINING_COMMENTS T WHERE T.PE_ID=PSCDB.PE_ID AND PSCDB.PE_TYPE_OF_EXPENSE='CAR EXPENSE';
	UPDATE TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE SET PE_INVOICE_ITEMS='NO ITEM' WHERE PE_INVOICE_ITEMS IS NULL OR PE_INVOICE_ITEMS=' ';
	UPDATE TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE SET PE_INVOICE_FROM='NO FROM' WHERE PE_INVOICE_FROM IS NULL OR PE_INVOICE_FROM=' ';
	UPDATE TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE SET PE_INVOICE_FROM=(SELECT PE_CAR_EXP_INVOICE_FROM  FROM TEMP_PERSONAL_SCDB_FORMAT
	WHERE PE_ID=110) WHERE PE_ID=110;
	DROP TABLE IF EXISTS TEMP_EXP_CAR_DOUBLE_SLASHN_INVOICE_FROM_ITEM;
	DROP TABLE IF EXISTS TEMP_EXP_CAR_SINGLE_SLASHN_INVOICE_FROM_ITEM;
	DROP TABLE IF EXISTS TEMP_EXP_CAR_SLASHN_INVOICE_FROM_ITEM;
	DROP VIEW IF EXISTS VW_CAR_REMAINING_COMMENTS;
COMMIT;
END;
