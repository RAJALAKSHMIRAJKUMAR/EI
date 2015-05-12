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
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
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
COMMIT;
END;
