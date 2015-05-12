-- VERSION: 0.2, TRACKER:566   , COMMENT: # 12  ,STARTDATE:10-06-2014  ENDDATE: 10-06-2014, DESC:ADDED ROLLBACK AND COMMIT DONE BY: SASIKALA
-- VERSION: 0.1, TRACKER:   , COMMENT: #   ,STARTDATE:04-01-2014  ENDDATE: 04-02-2014, DESC: PLATFORM MANAGEMENT,THIS SUB SP IS CALLED IN SP_ROLE_CREATION_INSERT & SP_ROLE_CREATION_UPDATE  FOR GRANT OR REVOKE PERMISSION. DONE BY: MANIKANDAN S
DROP PROCEDURE IF EXISTS SP_PLATFORM_MGMT_DB_USER_RIGHTS_GRANT_REVOKE;
CREATE PROCEDURE SP_PLATFORM_MGMT_DB_USER_RIGHTS_GRANT_REVOKE(IN DB_NAME VARCHAR(20), IN USER_NAME VARCHAR(50), IN MENUS VARCHAR(100),IN ACTION VARCHAR(10))
BEGIN
DECLARE COUNT1        INT;
DECLARE COUNT2        INT;
DECLARE COUNT3        INT;
DECLARE V_POSTAP_ID   INT;
DECLARE V_SPP_ID      INT;
DECLARE V_VP_ID       INT;
DECLARE V_TABLE_NAME  VARCHAR(100);
DECLARE V_SP_NAME     VARCHAR(100);
DECLARE V_VP_NAME     VARCHAR(100);
DECLARE MIN_ID        INT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
  ROLLBACK;
END;
START TRANSACTION;
DROP TABLE IF EXISTS TEMP_PM_UNIQUE_TABLE_NAMES;
CREATE TABLE TEMP_PM_UNIQUE_TABLE_NAMES (ID INT NOT NULL AUTO_INCREMENT, POSTAP_ID INT,PRIMARY KEY (ID));

SET @SQL = CONCAT('INSERT INTO TEMP_PM_UNIQUE_TABLE_NAMES(POSTAP_ID) SELECT DISTINCT POSTAP_ID FROM PLATFORM_MANAGEMENT WHERE MP_ID IN (',MENUS,') AND POSTAP_ID IS NOT NULL');

PREPARE S1 FROM @SQL;
EXECUTE S1;
DEALLOCATE PREPARE S1;

 SELECT COUNT(*) INTO COUNT1 FROM TEMP_PM_UNIQUE_TABLE_NAMES;
   INSERT INTO TEMP VALUES (ACTION);
 IF COUNT1 > 0 THEN
L_TABLE:
 LOOP
    SELECT POSTAP_ID INTO V_POSTAP_ID FROM TEMP_PM_UNIQUE_TABLE_NAMES WHERE ID = COUNT1;
     
    SELECT POSTAP_DATA INTO V_TABLE_NAME FROM POST_AUDIT_PROFILE WHERE POSTAP_ID = V_POSTAP_ID;
     INSERT INTO TEMP VALUES (V_TABLE_NAME);
      IF V_TABLE_NAME IS NOT NULL AND V_TABLE_NAME != 'POST_AUDIT_PROFILE' AND V_TABLE_NAME != 'STORED_PROCEDURE_PROFILE' AND V_TABLE_NAME != 'VIEW_PROFILE' THEN
       
      IF ACTION = 'GRANT' THEN
        SET @SQL = CONCAT('GRANT SELECT,INSERT,UPDATE ON ',DB_NAME,'.',V_TABLE_NAME,' TO ''',USER_NAME ,'''@','''%''');
      ELSE
        SET @SQL = CONCAT('REVOKE SELECT,INSERT,UPDATE ON ',DB_NAME,'.',V_TABLE_NAME,' FROM ''',USER_NAME ,'''@','''%''');
      END IF;
      
      PREPARE S1 FROM @SQL;
      EXECUTE S1;
      DEALLOCATE PREPARE S1;
      END IF;  
    
     SET COUNT1 = COUNT1 - 1;
     
    IF COUNT1 = 0 THEN
      LEAVE L_TABLE;
    END IF;
 END LOOP L_TABLE;
 END IF;
 
 
  DROP TABLE IF EXISTS TEMP_PM_UNIQUE_SP_NAMES;
CREATE TABLE TEMP_PM_UNIQUE_SP_NAMES (ID INT NOT NULL AUTO_INCREMENT, SPP_ID INT,PRIMARY KEY (ID));

SET @SQL = CONCAT('INSERT INTO TEMP_PM_UNIQUE_SP_NAMES(SPP_ID) SELECT DISTINCT SPP_ID FROM PLATFORM_MANAGEMENT WHERE MP_ID IN (',MENUS,') AND SPP_ID IS NOT NULL');PREPARE S1 FROM @SQL;

PREPARE S1 FROM @SQL;
EXECUTE S1;
DEALLOCATE PREPARE S1;

 SELECT COUNT(*) INTO COUNT2 FROM TEMP_PM_UNIQUE_SP_NAMES;
  
  IF COUNT2 > 0 THEN
L_SP:
 LOOP
    SELECT SPP_ID INTO V_SPP_ID FROM TEMP_PM_UNIQUE_SP_NAMES WHERE ID = COUNT2;
    SELECT SPP_NAME INTO V_SP_NAME FROM STORED_PROCEDURE_PROFILE WHERE SPP_ID = V_SPP_ID;
      
     IF V_SP_NAME IS NOT NULL THEN
    
    IF ACTION = 'GRANT' THEN
      SET @SQL = CONCAT('GRANT EXECUTE ON PROCEDURE ',DB_NAME,'.',V_SP_NAME,' TO ''',USER_NAME ,'''@','''%''');
    ELSE
      SET @SQL = CONCAT('REVOKE EXECUTE ON PROCEDURE ',DB_NAME,'.',V_SP_NAME,' FROM ''',USER_NAME ,'''@','''%''');
    END IF;
       
      PREPARE S1 FROM @SQL;
      EXECUTE S1;
      DEALLOCATE PREPARE S1;
     END IF;
    
     SET COUNT2 = COUNT2 - 1;
    IF COUNT2 = 0 THEN
      LEAVE L_SP;
    END IF;
   END LOOP L_SP;
  END IF;
  
  DROP TABLE IF EXISTS TEMP_PM_UNIQUE_VIEW_NAMES;
CREATE TABLE TEMP_PM_UNIQUE_VIEW_NAMES (ID INT NOT NULL AUTO_INCREMENT, VP_ID INT,PRIMARY KEY (ID));

SET @SQL = CONCAT('INSERT INTO TEMP_PM_UNIQUE_VIEW_NAMES(VP_ID) SELECT DISTINCT VP_ID FROM PLATFORM_MANAGEMENT WHERE MP_ID IN (',MENUS,') AND VP_ID IS NOT NULL');
PREPARE S1 FROM @SQL;
EXECUTE S1;
DEALLOCATE PREPARE S1;

 SELECT COUNT(*) INTO COUNT3 FROM TEMP_PM_UNIQUE_VIEW_NAMES;
  
  IF COUNT3 > 0 THEN
L_VIEW:
 LOOP
    SELECT VP_ID INTO V_VP_ID FROM TEMP_PM_UNIQUE_VIEW_NAMES WHERE ID = COUNT3;
    SELECT VP_NAME INTO V_VP_NAME FROM VIEW_PROFILE WHERE VP_ID = V_VP_ID;
    
    IF V_VP_NAME IS NOT NULL THEN
     IF ACTION = 'GRANT' THEN
        SET @SQL = CONCAT('GRANT SELECT ON ',DB_NAME,'.',V_VP_NAME,' TO ''',USER_NAME ,'''@','''%''');
     ELSE
        SET @SQL = CONCAT('REVOKE SELECT ON ',DB_NAME,'.',V_VP_NAME,' FROM ''',USER_NAME ,'''@','''%''');
     END IF;
     
      PREPARE S1 FROM @SQL;
      EXECUTE S1;
      DEALLOCATE PREPARE S1;
    END IF;
    
     SET COUNT3 = COUNT3 - 1;
    IF COUNT3 = 0 THEN
      LEAVE L_VIEW;
    END IF;
   END LOOP L_VIEW;
  END IF;
 
  DROP TABLE IF EXISTS TEMP_PM_UNIQUE_TABLE_NAMES;
  DROP TABLE IF EXISTS TEMP_PM_UNIQUE_SP_NAMES;
  DROP TABLE IF EXISTS TEMP_PM_UNIQUE_VIEW_NAMES;
 
COMMIT; 
END;

/*
CALL SP_PLATFORM_MGMT_DB_USER_RIGHTS_GRANT_REVOKE('DEVELOPMENT','MANI','''1'',''10''');
*/