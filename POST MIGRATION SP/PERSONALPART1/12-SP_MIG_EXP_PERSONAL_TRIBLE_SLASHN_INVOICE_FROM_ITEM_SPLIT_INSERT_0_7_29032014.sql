DROP PROCEDURE IF EXISTS SP_MIG_EXP_PERSONAL_TRIBLE_SLASHN_INVOICE_FROM_ITEM_SPLIT_INSERT;
CREATE PROCEDURE SP_MIG_EXP_PERSONAL_TRIBLE_SLASHN_INVOICE_FROM_ITEM_SPLIT_INSERT()
BEGIN
DECLARE DONE INT DEFAULT FALSE;
DECLARE PEID INTEGER;
DECLARE PERSONALCOMMENTS TEXT;
DECLARE ITEMLOCATION INTEGER;
DECLARE FROMLOCATION INTEGER;
DECLARE INVOICEITEM TEXT;
DECLARE INVOICEFROM TEXT;
DECLARE INVITEM TEXT;
DECLARE INVFROM TEXT;
DECLARE FILTER_CURSOR CURSOR FOR 
SELECT PE_ID,PE_PERSONAL_COMMENTS,PE_PERSONAL_INVOICE_ITEMS,PE_PERSONAL_INVOICE_FROM FROM PERSONAL_SCDB_FORMAT WHERE PE_TYPE_OF_EXPENSE='PERSONAL' AND PE_PERSONAL_COMMENTS IS NOT NULL AND (PE_PERSONAL_INVOICE_ITEMS IS NULL OR PE_PERSONAL_INVOICE_FROM IS NULL);
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
END;
START TRANSACTION;
DROP TABLE IF EXISTS TEMP_EXP_PERSONAL_TRIBLE_SLASHN_INVOICE_FROM_ITEM;
CREATE TABLE TEMP_EXP_PERSONAL_TRIBLE_SLASHN_INVOICE_FROM_ITEM(ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,PE_ID INT NOT NULL ,PE_PERSONAL_COMMENTS TEXT,PE_INVOICE_ITEM TEXT,PE_INVOICE_FROM TEXT);
OPEN FILTER_CURSOR;
read_loop: LOOP
FETCH FILTER_CURSOR INTO PEID,PERSONALCOMMENTS,INVOICEITEM,INVOICEFROM;
IF DONE THEN
      LEAVE read_loop;
END IF;
SET ITEMLOCATION=(SELECT LOCATE('\n\n\n',PERSONALCOMMENTS));
SET FROMLOCATION=(SELECT LOCATE('\n\n',PERSONALCOMMENTS,ITEMLOCATION+3));
SET INVITEM=(SELECT SUBSTRING(PERSONALCOMMENTS,ITEMLOCATION+3,FROMLOCATION-(ITEMLOCATION+3)));
SET INVFROM=(SELECT SUBSTRING(PERSONALCOMMENTS,FROMLOCATION+2));
IF(ITEMLOCATION!=0) AND (FROMLOCATION!=0) THEN
		INSERT INTO TEMP_EXP_PERSONAL_TRIBLE_SLASHN_INVOICE_FROM_ITEM(PE_ID,PE_PERSONAL_COMMENTS,PE_INVOICE_ITEM,PE_INVOICE_FROM)VALUES(PEID,PERSONALCOMMENTS,INVITEM,INVFROM);
		END IF;
END LOOP;
CLOSE FILTER_CURSOR;
IF EXISTS(SELECT PE_ID FROM TEMP_EXP_PERSONAL_TRIBLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=2497)THEN
DELETE FROM TEMP_EXP_PERSONAL_TRIBLE_SLASHN_INVOICE_FROM_ITEM WHERE PE_ID=2497;
END IF;
COMMIT;
END;
