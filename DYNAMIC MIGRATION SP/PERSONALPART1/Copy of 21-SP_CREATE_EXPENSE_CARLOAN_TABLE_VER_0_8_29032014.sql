DROP PROCEDURE IF EXISTS SP_CREATE_EXPENSE_CARLOAN_TABLE;
CREATE PROCEDURE SP_CREATE_EXPENSE_CARLOAN_TABLE(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
	SET @EXPENSE_CAR_LOANDROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.EXPENSE_CAR_LOAN'));
	PREPARE EXPENSE_CAR_LOANDROPQUERYSTMT FROM @EXPENSE_CAR_LOANDROPQUERY;
	EXECUTE EXPENSE_CAR_LOANDROPQUERYSTMT;
	SET @EXPENSE_CAR_LOANCREATEQUERY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.EXPENSE_CAR_LOAN(
	ECL_ID INTEGER NOT NULL AUTO_INCREMENT,
	ECL_PAID_DATE DATE NOT NULL,
	ECL_FROM_PERIOD DATE NOT NULL,
	ECL_TO_PERIOD DATE NOT NULL,
	ECL_AMOUNT DECIMAL(7,2)NOT NULL,
	ECL_COMMENTS TEXT,
	ULD_ID INTEGER(2)NOT NULL,
	ECL_TIMESTAMP TIMESTAMP NOT NULL,
	PRIMARY KEY(ECL_ID),
	FOREIGN KEY (ULD_ID)REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(ULD_ID))'));
	PREPARE EXPENSE_CAR_LOANCREATEQUERYSTMT FROM @EXPENSE_CAR_LOANCREATEQUERY;
	EXECUTE EXPENSE_CAR_LOANCREATEQUERYSTMT;
	SET FOREIGN_KEY_CHECKS=1;
END;
