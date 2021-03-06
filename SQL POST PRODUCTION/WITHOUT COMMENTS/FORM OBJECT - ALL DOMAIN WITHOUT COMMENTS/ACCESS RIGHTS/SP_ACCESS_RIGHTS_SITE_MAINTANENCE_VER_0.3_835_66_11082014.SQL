DROP PROCEDURE IF EXISTS SP_ACCESS_RIGHTS_SITE_MAINTANENCE;
CREATE PROCEDURE SP_ACCESS_RIGHTS_SITE_MAINTANENCE(MENUID TEXT)
BEGIN
DECLARE MENU_LENGTH INTEGER;
DECLARE TEMP_MENU TEXT;
DECLARE MENU INTEGER;
DECLARE MENU_POSITION INTEGER;
BEGIN 
	ROLLBACK; 
END;
SET AUTOCOMMIT= 0;
START TRANSACTION;
IF MENUID IS NOT NULL THEN
UPDATE MENU_PROFILE SET MP_SCRIPT_FLAG=NULL;
SET TEMP_MENU = MENUID;
SET MENU_LENGTH = 1;
	loop_label : LOOP
		SET MENU_POSITION=(SELECT LOCATE(',', TEMP_MENU,MENU_LENGTH));
		IF MENU_POSITION<=0 THEN
			SET MENU=TEMP_MENU;
		ELSE
			SELECT SUBSTRING(TEMP_MENU,MENU_LENGTH,MENU_POSITION-1) INTO MENU;
			SET TEMP_MENU=(SELECT SUBSTRING(TEMP_MENU,MENU_POSITION+1));
		END IF;
		UPDATE MENU_PROFILE SET MP_SCRIPT_FLAG='X' WHERE MP_ID=MENU;
		IF MENU_POSITION<=0 THEN
			LEAVE  loop_label;
		END IF;
	END LOOP;
ELSE
	UPDATE MENU_PROFILE SET MP_SCRIPT_FLAG=NULL WHERE MP_SCRIPT_FLAG='X';
END IF;
COMMIT;
END;
