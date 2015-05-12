DROP PROCEDURE IF EXISTS SP_USER_RIGHTS_BASIC_PROFILE_SAVE;
CREATE PROCEDURE SP_USER_RIGHTS_BASIC_PROFILE_SAVE (IN USER_STAMP VARCHAR(50), IN ROLE VARCHAR(255),IN BASIC_ROLES VARCHAR(255), IN MENUS VARCHAR(255),OUT UR_FLAG INTEGER) 
BEGIN
  DECLARE V_URC_ID   INT;
  DECLARE V_STRLEN    INT DEFAULT 0;
  DECLARE V_SUBSTRLEN INT DEFAULT 0;
  DECLARE V_MENU_ID INT;
  DECLARE V_BASIC_ROLES_ID INT;
  DECLARE V_BASIC_ROLE VARCHAR(255);
  DECLARE USERSTAMP_ID INTEGER(2);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
   ROLLBACK;
  END;
  START TRANSACTION;
SET V_URC_ID = (SELECT URC_ID FROM USER_RIGHTS_CONFIGURATION WHERE URC_DATA = ROLE);
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USER_STAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);
SET UR_FLAG=0;
IF BASIC_ROLES IS NULL THEN
    SET BASIC_ROLES = '';
  END IF;
DO_THIS_FIRST:
  LOOP
    SET V_STRLEN = CHAR_LENGTH(BASIC_ROLES); 
    SET V_BASIC_ROLE = SUBSTRING_INDEX(BASIC_ROLES, ',', 1); 
    SET V_BASIC_ROLES_ID = (SELECT URC_ID FROM USER_RIGHTS_CONFIGURATION WHERE URC_DATA = V_BASIC_ROLE);
    INSERT INTO BASIC_ROLE_PROFILE (URC_ID, BRP_BR_ID, ULD_ID) VALUES (V_URC_ID, V_BASIC_ROLES_ID, USERSTAMP_ID);
    SET UR_FLAG=1;
    SET V_SUBSTRLEN = CHAR_LENGTH(SUBSTRING_INDEX(BASIC_ROLES, ',', 1)) + 2;
    SET BASIC_ROLES = MID(BASIC_ROLES, V_SUBSTRLEN, V_STRLEN);
    IF BASIC_ROLES = '' THEN
      LEAVE DO_THIS_FIRST;
    END IF;
  END LOOP DO_THIS_FIRST;
  IF MENUS IS NULL THEN
    SET MENUS = '';
  END IF;
DO_THIS:
  LOOP
    SET V_STRLEN = CHAR_LENGTH(MENUS);
    SET V_MENU_ID = SUBSTRING_INDEX(MENUS, ',', 1);
    INSERT INTO BASIC_MENU_PROFILE (URC_ID, MP_ID, ULD_ID) VALUES (V_URC_ID, V_MENU_ID, USERSTAMP_ID);    
    SET UR_FLAG=1;
    SET V_SUBSTRLEN = CHAR_LENGTH(SUBSTRING_INDEX(MENUS, ',', 1)) + 2;
    SET MENUS = MID(MENUS, V_SUBSTRLEN, V_STRLEN);
    IF MENUS = '' THEN
      LEAVE DO_THIS;
    END IF;
  END LOOP DO_THIS;
  COMMIT;
END;