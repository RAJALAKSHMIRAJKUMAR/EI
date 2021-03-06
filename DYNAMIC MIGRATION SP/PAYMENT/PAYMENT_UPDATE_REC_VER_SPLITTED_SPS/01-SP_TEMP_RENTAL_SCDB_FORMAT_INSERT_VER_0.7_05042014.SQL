DROP PROCEDURE IF EXISTS SP_TEMP_RENTAL_SCDB_FORMAT_INSERT;
CREATE PROCEDURE SP_TEMP_RENTAL_SCDB_FORMAT_INSERT(IN SOURCESCHEMA  VARCHAR(40),IN DESTINATIONSCHEMA  VARCHAR(40))
BEGIN
SET FOREIGN_KEY_CHECKS=0;
    SET @DROP_TEMP_RENTAL_SCDB_FORMAT=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_RENTAL_SCDB_FORMAT'));
    PREPARE DROP_TEMP_RENTAL_SCDB_FORMAT_STMT FROM @DROP_TEMP_RENTAL_SCDB_FORMAT;
    EXECUTE DROP_TEMP_RENTAL_SCDB_FORMAT_STMT;
    SET @CREATE_TEMP_RENTAL_SCDB_FORMAT=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_RENTAL_SCDB_FORMAT LIKE ',SOURCESCHEMA,'.RENTAL_SCDB_FORMAT'));
    PREPARE CREATE_TEMP_RENTAL_SCDB_FORMAT_STMT FROM @CREATE_TEMP_RENTAL_SCDB_FORMAT;
    EXECUTE CREATE_TEMP_RENTAL_SCDB_FORMAT_STMT;    
    SET @INSERT_TEMP_RENTAL_SCDB_FORMAT=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_RENTAL_SCDB_FORMAT  SELECT * FROM ',SOURCESCHEMA,'.RENTAL_SCDB_FORMAT'));
	PREPARE INSERT_TEMP_RENTAL_SCDB_FORMAT_STMT FROM @INSERT_TEMP_RENTAL_SCDB_FORMAT;
    EXECUTE INSERT_TEMP_RENTAL_SCDB_FORMAT_STMT;
	SET @ALTER_TEMP_RENTAL_SCDB_FORMAT=(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.TEMP_RENTAL_SCDB_FORMAT ADD COLUMN (RD_AMOUNT VARCHAR(255) NULL,RPP_ID VARCHAR(255) NULL)'));
	PREPARE ALTER_TEMP_RENTAL_SCDB_FORMAT_STMT FROM @ALTER_TEMP_RENTAL_SCDB_FORMAT;
    EXECUTE ALTER_TEMP_RENTAL_SCDB_FORMAT_STMT;	
	SET @UPDATE_TEMP_RENTAL_SCDB_FORMAT=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_RENTAL_SCDB_FORMAT SET
    RD_AMOUNT = CONCAT(IFNULL(RENTAL_DEPOSIT,',"'" "'",'), IFNULL(RENTAL_DEPOSIT_REFUND,',"'" "'",'),  IFNULL(RENTAL_AMOUNT,',"'" "'",'), IFNULL(RENTAL_PROCESSING_FEE,',"'" "'",'), IFNULL(RENTAL_CLEANING_FEE,',"' " "'",'))'));
	PREPARE UPDATE_TEMP_RENTAL_SCDB_FORMAT_STMT FROM @UPDATE_TEMP_RENTAL_SCDB_FORMAT;
    EXECUTE UPDATE_TEMP_RENTAL_SCDB_FORMAT_STMT; 	
	SET @UPDATE_RENT_AMOUNT=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_RENTAL_SCDB_FORMAT SET RPP_ID=1 WHERE RENTAL_AMOUNT IS NOT NULL'));
	PREPARE UPDATE_RENT_AMOUNT_STMT FROM @UPDATE_RENT_AMOUNT;
    EXECUTE UPDATE_RENT_AMOUNT_STMT;	
	SET @UPDATE_RENTAL_DEPOSIT=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_RENTAL_SCDB_FORMAT SET RPP_ID=2 WHERE RENTAL_DEPOSIT IS NOT NULL'));
	PREPARE UPDATE_RENTAL_DEPOSIT_STMT FROM @UPDATE_RENTAL_DEPOSIT;
    EXECUTE UPDATE_RENTAL_DEPOSIT_STMT;	
	SET @UPDATE_RENTAL_PROCESSING_FEE=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_RENTAL_SCDB_FORMAT SET RPP_ID=3 WHERE RENTAL_PROCESSING_FEE IS NOT NULL'));
	PREPARE UPDATE_RENTAL_PROCESSING_FEE_STMT FROM @UPDATE_RENTAL_PROCESSING_FEE;
    EXECUTE UPDATE_RENTAL_PROCESSING_FEE_STMT;	
	SET @UPDATE_RENTAL_CLEANING_FEE=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_RENTAL_SCDB_FORMAT SET RPP_ID=4 WHERE RENTAL_CLEANING_FEE IS NOT NULL'));
	PREPARE UPDATE_RENTAL_CLEANING_FEE_STMT FROM @UPDATE_RENTAL_CLEANING_FEE;
    EXECUTE UPDATE_RENTAL_CLEANING_FEE_STMT;	
	SET @UPDATE_RENTAL_DEPOSIT_REFUND=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_RENTAL_SCDB_FORMAT SET RPP_ID=5 WHERE RENTAL_DEPOSIT_REFUND IS NOT NULL'));
	PREPARE UPDATE_RENTAL_DEPOSIT_REFUND_STMT FROM @UPDATE_RENTAL_DEPOSIT_REFUND;
    EXECUTE UPDATE_RENTAL_DEPOSIT_REFUND_STMT;	
	SET @UPDATE_RENTAL_CUSTOMER=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_RENTAL_SCDB_FORMAT SET RENTAL_CUSTOMER=','"CHARLES AND JOANNA"',' WHERE RENTAL_CUSTOMER=','"CHARLES ANDJOANNA"'));
	PREPARE UPDATE_RENTAL_CUSTOMER_STMT FROM @UPDATE_RENTAL_CUSTOMER;
    EXECUTE UPDATE_RENTAL_CUSTOMER_STMT;
    SET FOREIGN_KEY_CHECKS=1;
END;
