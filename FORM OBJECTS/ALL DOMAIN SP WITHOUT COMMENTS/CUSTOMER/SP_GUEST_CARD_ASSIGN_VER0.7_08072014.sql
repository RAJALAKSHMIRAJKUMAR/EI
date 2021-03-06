DROP PROCEDURE IF EXISTS SP_GUEST_NULL_CARD_ASSIGN;
CREATE PROCEDURE SP_GUEST_NULL_CARD_ASSIGN(IN CA_CUSTOMER_ID INTEGER,IN TERMINATE_RECVER INTEGER,
IN CA_REC_VER INTEGER,
IN ACTIVE_RECVER INTEGER,
IN TEMP_CUSTOMER_RECVER TEXT,
IN USERSTAMP_ID INTEGER,
IN OLD_ACCESS_CARD_NO INTEGER,
IN NEW_ACCESS_CARD_NO INTEGER,
IN USERSTAMP VARCHAR(50),
IN SAMEUNITMINID INTEGER,
OUT GUEST_ASSIGNFLAG INTEGER
)
BEGIN
DECLARE PRETERMINATE_DATE DATE;
DECLARE TEMPCTDID TEXT;
DECLARE MINTERMID INTEGER;
DECLARE MAXTERMID INTEGER;
DECLARE TEMP_CTD_ID TEXT;
DECLARE OLD_ULDID INTEGER;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
IF TEMP_CUSTOMER_RECVER IS NOT NULL THEN
 SET @DROP_TEMPCUSTOMERRECVER=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_CUSTOMER_RECVER));
 PREPARE DROP_TEMPCUSTOMERRECVER_STMT FROM @DROP_TEMPCUSTOMERRECVER;
 EXECUTE DROP_TEMPCUSTOMERRECVER_STMT;
END IF; 
IF TEMP_CTD_ID IS NOT NULL THEN
 SET @DROP_TEMP_CTD_ID=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_CTD_ID));
 PREPARE DROP_TEMP_CTD_ID_STMT FROM @DROP_TEMP_CTD_ID;
 EXECUTE DROP_TEMP_CTD_ID_STMT;
END IF;
END;
START TRANSACTION; 
 IF (OLD_ACCESS_CARD_NO IS NOT NULL AND NEW_ACCESS_CARD_NO IS NULL) THEN             
                   IF TERMINATE_RECVER IS NOT NULL AND ACTIVE_RECVER IS NULL THEN
    			     SET @TEMPPRETERMINATE_DATE=NULL;
                     SET @PRETERMINATEDATE=(SELECT CONCAT('SELECT CLP_PRETERMINATE_DATE INTO @TEMPPRETERMINATE_DATE FROM ',TEMP_CUSTOMER_RECVER,' WHERE CED_REC_VER=',TERMINATE_RECVER));
					 PREPARE PRETERMINATEDATE_STMT FROM @PRETERMINATEDATE;
                            EXECUTE PRETERMINATEDATE_STMT;
							 SET PRETERMINATE_DATE=@TEMPPRETERMINATE_DATE;
							    SET @TEMP_CACDID=NULL;
				  SET @SELECT_TEMPCACDID=(SELECT CONCAT('SELECT CACD_ID INTO @TEMP_CACDID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM ',TEMP_CUSTOMER_RECVER,' WHERE CED_REC_VER=',TERMINATE_RECVER,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
				  PREPARE SELECT_TEMPCACDID_STMT FROM @SELECT_TEMPCACDID;
                  EXECUTE SELECT_TEMPCACDID_STMT;
				  SET @TEMP_ULDID=NULL;
				  SET @SELECT_TEMPULDID=(SELECT CONCAT('SELECT ULD_ID INTO @TEMP_ULDID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM ',TEMP_CUSTOMER_RECVER,' WHERE CED_REC_VER=',TERMINATE_RECVER,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
				  PREPARE SELECT_TEMPULDID_STMT FROM @SELECT_TEMPULDID;
                  EXECUTE SELECT_TEMPULDID_STMT;
				  SET OLD_ULDID=@TEMP_ULDID;
				  SET @TEMP_TIMESTAMP=NULL;
				  SET @SELECT_TEMPTIMESTAMP=(SELECT CONCAT('SELECT CACD_TIMESTAMP INTO @TEMP_TIMESTAMP FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM ',TEMP_CUSTOMER_RECVER,' WHERE CED_REC_VER=',TERMINATE_RECVER,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
				  PREPARE SELECT_TEMPTIMESTAMP_STMT FROM @SELECT_TEMPTIMESTAMP;
                  EXECUTE SELECT_TEMPTIMESTAMP_STMT;							 
                       IF PRETERMINATE_DATE IS NULL THEN 
                            SET @UASD_ID=NULL;
                            SET @UASDID=(SELECT CONCAT('SELECT UASD_ID INTO @UASD_ID FROM ',TEMP_CUSTOMER_RECVER,' WHERE CED_REC_VER=',TERMINATE_RECVER));
							PREPARE UASDID_STMT FROM @UASDID;
                            EXECUTE UASDID_STMT;
							IF(OLD_ULDID!=USERSTAMP_ID)THEN
                                SET @TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',@TEMP_CACDID,',UASD_ID=',@UASD_ID,',ACN_ID=NULL',',CACD_VALID_TILL=NULL,','ULD_ID=',OLD_ULDID,',','CACD_TIMESTAMP=',@TEMP_TIMESTAMP));
								ELSE
								SET @TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',@TEMP_CACDID,',UASD_ID=',@UASD_ID,',ACN_ID=NULL',',CACD_VALID_TILL=NULL,','CACD_TIMESTAMP=',@TEMP_TIMESTAMP));	
								END IF;											
                            SET @VALIDTILL=NULL;
						    SET @TEMPCLP_ENDDATE=(SELECT CONCAT('SELECT CLP_ENDDATE INTO @VALIDTILL FROM ',TEMP_CUSTOMER_RECVER,' WHERE CED_REC_VER=',TERMINATE_RECVER));
						    PREPARE TEMPCLP_ENDDATE_STMT FROM @TEMPCLP_ENDDATE;
                            EXECUTE TEMPCLP_ENDDATE_STMT;
						     SET @TICK_ACCESS_NEW_VALUE=(SELECT CONCAT('ACN_ID=4',',CACD_VALID_TILL=',@VALIDTILL));                           
                            INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ACCESS_CARD_DETAILS'),@TICK_ACCESS_OLD_VALUE,@TICK_ACCESS_NEW_VALUE,USERSTAMP_ID,CA_CUSTOMER_ID);
                            SET @UPDATECACD=(SELECT CONCAT('UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET ACN_ID=4,CACD_VALID_TILL=(SELECT CLP_ENDDATE FROM ',TEMP_CUSTOMER_RECVER ,' WHERE CED_REC_VER=',TERMINATE_RECVER,'),ULD_ID=',USERSTAMP_ID,'  WHERE UASD_ID=(SELECT UASD_ID FROM ',TEMP_CUSTOMER_RECVER,' WHERE CED_REC_VER=',TERMINATE_RECVER,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
							PREPARE UPDATECACD_STMT FROM @UPDATECACD;
                            EXECUTE UPDATECACD_STMT;
                         ELSE 
						    SET @UASD_ID=NULL;
                            SET @UASDID=(SELECT CONCAT('SELECT UASD_ID INTO @UASD_ID FROM ',TEMP_CUSTOMER_RECVER,' WHERE CED_REC_VER=',TERMINATE_RECVER));
							PREPARE UASDID_STMT FROM @UASDID;
                            EXECUTE UASDID_STMT;
                            IF(OLD_ULDID!=USERSTAMP_ID)THEN
                                SET @TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',@TEMP_CACDID,',UASD_ID=',@UASD_ID,',ACN_ID=NULL',',CACD_VALID_TILL=NULL,','ULD_ID=',OLD_ULDID,',','CACD_TIMESTAMP=',@TEMP_TIMESTAMP));
								ELSE
								SET @TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',@TEMP_CACDID,',UASD_ID=',@UASD_ID,',ACN_ID=NULL',',CACD_VALID_TILL=NULL,','CACD_TIMESTAMP=',@TEMP_TIMESTAMP));	
								END IF;			   
                            SET @VALIDTILL=NULL;
						    SET @TEMPCLP_ENDDATE=(SELECT CONCAT('SELECT CLP_ENDDATE INTO @VALIDTILL FROM ',TEMP_CUSTOMER_RECVER,' WHERE CED_REC_VER=',TERMINATE_RECVER));
						    PREPARE TEMPCLP_ENDDATE_STMT FROM @TEMPCLP_ENDDATE;
                            EXECUTE TEMPCLP_ENDDATE_STMT;
                            SET @TICK_ACCESS_NEW_VALUE=(SELECT CONCAT('ACN_ID=4',',CACD_VALID_TILL=',@VALIDTILL)); 
                            INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ACCESS_CARD_DETAILS'),@TICK_ACCESS_OLD_VALUE,@TICK_ACCESS_NEW_VALUE,USERSTAMP_ID,CA_CUSTOMER_ID);
                            SET @UPDATE_CACD=(SELECT CONCAT('UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET ACN_ID=4,CACD_VALID_TILL=(SELECT CLP_PRETERMINATE_DATE FROM ',TEMP_CUSTOMER_RECVER,' WHERE CED_REC_VER=',TERMINATE_RECVER,'),ULD_ID=',USERSTAMP_ID,'  WHERE UASD_ID=(SELECT UASD_ID FROM ',TEMP_CUSTOMER_RECVER,' WHERE CED_REC_VER=',TERMINATE_RECVER,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
							PREPARE UPDATECACD_STMT FROM @UPDATECACD;
                            EXECUTE UPDATECACD_STMT;
                       END IF;
                            UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_INVENTORY='X',UASD_ACCESS_ACTIVE=NULL WHERE UASD_ACCESS_CARD=OLD_ACCESS_CARD_NO;
						ELSE
                         IF ACTIVE_RECVER IS NULL  OR ACTIVE_RECVER IS NOT NULL THEN                            
                            SET @CACD_ID=(SELECT CACD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=OLD_ACCESS_CARD_NO)AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL AND CACD_GUEST_CARD IS NOT NULL);
                            CALL SP_SINGLE_TABLE_ROW_DELETION((SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ACCESS_CARD_DETAILS'),@CACD_ID,USERSTAMP,@DELETION_GUEST_ASSIGNFLAG);
                            SET @THID=(SELECT TH_ID FROM TICKLER_HISTORY WHERE TH_ID=(SELECT MAX(TH_ID) FROM TICKLER_HISTORY WHERE TTIP_ID=13));
                            UPDATE TICKLER_HISTORY SET CUSTOMER_ID=CA_CUSTOMER_ID WHERE TH_ID=@THID;
							IF NOT EXISTS(SELECT * FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_REC_VER=CA_REC_VER AND UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=OLD_ACCESS_CARD_NO))THEN
                            UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_INVENTORY='X',UASD_ACCESS_ACTIVE=NULL WHERE UASD_ACCESS_CARD=OLD_ACCESS_CARD_NO;
							END IF;
                         END IF;                          						 
                    END IF;
                    IF SAMEUNITMINID IS NULL THEN
					     SET TEMPCTDID=(SELECT CONCAT('TEMP_CTD_ID_',SYSDATE()));
                         SET TEMPCTDID=(SELECT REPLACE(TEMPCTDID,' ',''));
                         SET TEMPCTDID=(SELECT REPLACE(TEMPCTDID,'-',''));
                         SET TEMPCTDID=(SELECT REPLACE(TEMPCTDID,':',''));
                         SET TEMP_CTD_ID=(SELECT CONCAT(TEMPCTDID,'_',USERSTAMP_ID)); 	
					     SET @DROP_TEMP_CTD_ID=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_CTD_ID));
					     PREPARE DROP_TEMP_CTD_ID_STMT FROM @DROP_TEMP_CTD_ID;
                         EXECUTE DROP_TEMP_CTD_ID_STMT;
                         SET @CREATE_TEMP_CTD_ID=(SELECT CONCAT('CREATE TABLE ',TEMP_CTD_ID,'(ID INTEGER AUTO_INCREMENT PRIMARY KEY,CACDID INTEGER)'));
					     PREPARE CREATE_TEMP_CTD_ID_STMT FROM @CREATE_TEMP_CTD_ID;
                         EXECUTE CREATE_TEMP_CTD_ID_STMT;
						 IF ACTIVE_RECVER IS NOT NULL THEN
                         SET @INSERT_TEMP_CTDID=(SELECT CONCAT('INSERT INTO ',TEMP_CTD_ID,'(CACDID)SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=',OLD_ACCESS_CARD_NO,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND CED_REC_VER>=',ACTIVE_RECVER,' AND CED_REC_VER<=',CA_REC_VER,' AND CLP_GUEST_CARD IS NOT NULL'));
						 ELSE
						 SET @INSERT_TEMP_CTDID=(SELECT CONCAT('INSERT INTO ',TEMP_CTD_ID,'(CACDID)SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=',OLD_ACCESS_CARD_NO,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND  CED_REC_VER=',CA_REC_VER,' AND CLP_GUEST_CARD IS NOT NULL'));
						 END IF;
					     PREPARE INSERT_TEMP_CTDID_STMT FROM @INSERT_TEMP_CTDID;
                         EXECUTE INSERT_TEMP_CTDID_STMT;
						 SET @TEMPMINTERMID=NULL;
						 SET @TEMPMAXTERMID=NULL;
                         SET @MINTERM_ID=(SELECT CONCAT('SELECT MIN(ID) INTO @TEMPMINTERMID FROM ',TEMP_CTD_ID));
						 PREPARE MINTERM_ID_STMT FROM @MINTERM_ID;
                         EXECUTE MINTERM_ID_STMT;
                         SET @MAXTERM_ID=(SELECT CONCAT('SELECT MAX(ID) INTO @TEMPMAXTERMID FROM ',TEMP_CTD_ID));
						 PREPARE MAXTERM_ID_STMT FROM @MAXTERM_ID;
                         EXECUTE MAXTERM_ID_STMT;
						 SET MINTERMID=@TEMPMINTERMID;
						 SET MAXTERMID=@TEMPMAXTERMID;
                         WHILE MINTERMID<=MAXTERMID DO
						   SET @CACD_ID=NULL;
						   SET @SELECT_CACDID=(SELECT CONCAT('SELECT CACDID INTO @CACD_ID FROM ',TEMP_CTD_ID,' WHERE ID=',MINTERMID));
						   PREPARE SELECT_CACDID_STMT FROM @SELECT_CACDID;
                           EXECUTE SELECT_CACDID_STMT;
                           CALL SP_SINGLE_TABLE_ROW_DELETION((SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_LP_DETAILS'),@CACD_ID,USERSTAMP,@DELETION_GUEST_ASSIGNFLAG);
                           SET @THID=(SELECT TH_ID FROM TICKLER_HISTORY WHERE TH_ID=(SELECT MAX(TH_ID) FROM TICKLER_HISTORY WHERE TTIP_ID=14));
                           UPDATE TICKLER_HISTORY SET CUSTOMER_ID=CA_CUSTOMER_ID WHERE TH_ID=@THID;               
                           SET MINTERMID=MINTERMID+1;
                        END WHILE;
                        SET GUEST_ASSIGNFLAG=1;
                    ELSE
					     SET TEMPCTDID=(SELECT CONCAT('TEMP_CTD_ID_',SYSDATE()));
                         SET TEMPCTDID=(SELECT REPLACE(TEMPCTDID,' ',''));
                         SET TEMPCTDID=(SELECT REPLACE(TEMPCTDID,'-',''));
                         SET TEMPCTDID=(SELECT REPLACE(TEMPCTDID,':',''));
                         SET TEMP_CTD_ID=(SELECT CONCAT(TEMPCTDID,'_',USERSTAMP_ID)); 	
					     SET @DROP_TEMP_CTD_ID=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_CTD_ID));
					     PREPARE DROP_TEMP_CTD_ID_STMT FROM @DROP_TEMP_CTD_ID;
                         EXECUTE DROP_TEMP_CTD_ID_STMT;
                         SET @CREATE_TEMP_CTD_ID=(SELECT CONCAT('CREATE TABLE ',TEMP_CTD_ID,'(ID INTEGER AUTO_INCREMENT PRIMARY KEY,CACDID INTEGER)'));
					     PREPARE CREATE_TEMP_CTD_ID_STMT FROM @CREATE_TEMP_CTD_ID;
                         EXECUTE CREATE_TEMP_CTD_ID_STMT; 
                          IF ACTIVE_RECVER IS NOT NULL THEN						 
                         SET @INSERT_TEMP_CTDID=(SELECT CONCAT('INSERT INTO ',TEMP_CTD_ID,'(CACDID)SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=',OLD_ACCESS_CARD_NO,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND CED_REC_VER>=',ACTIVE_RECVER,' AND CED_REC_VER<=',SAMEUNITMINID,' AND CLP_GUEST_CARD IS NOT NULL'));
						 ELSE
						 SET @INSERT_TEMP_CTDID=(SELECT CONCAT('INSERT INTO ',TEMP_CTD_ID,'(CACDID)SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=',OLD_ACCESS_CARD_NO,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND CED_REC_VER>=',CA_REC_VER,' AND CED_REC_VER<=',SAMEUNITMINID,' AND CLP_GUEST_CARD IS NOT NULL'));
						 END IF;
						 PREPARE INSERT_TEMP_CTDID_STMT FROM @INSERT_TEMP_CTDID;
                         EXECUTE INSERT_TEMP_CTDID_STMT;
                         SET @TEMPMINTERMID=NULL;
						 SET @TEMPMAXTERMID=NULL;
                         SET @MINTERM_ID=(SELECT CONCAT('SELECT MIN(ID) INTO @TEMPMINTERMID FROM ',TEMP_CTD_ID));
						 PREPARE MINTERM_ID_STMT FROM @MINTERM_ID;
                         EXECUTE MINTERM_ID_STMT;
                         SET @MAXTERM_ID=(SELECT CONCAT('SELECT MAX(ID) INTO @TEMPMAXTERMID FROM ',TEMP_CTD_ID));
						 PREPARE MAXTERM_ID_STMT FROM @MAXTERM_ID;
                         EXECUTE MAXTERM_ID_STMT; 
						 SET MINTERMID=@TEMPMINTERMID;
						 SET MAXTERMID=@TEMPMAXTERMID;						 
                         WHILE MINTERMID<=MAXTERMID DO
						   SET @CACD_ID=NULL;
						   SET @SELECT_CACDID=(SELECT CONCAT('SELECT CACDID INTO @CACD_ID FROM ',TEMP_CTD_ID,' WHERE ID=',MINTERMID));
						   PREPARE SELECT_CACDID_STMT FROM @SELECT_CACDID;
                           EXECUTE SELECT_CACDID_STMT;
                           CALL SP_SINGLE_TABLE_ROW_DELETION((SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_LP_DETAILS'),@CACD_ID,USERSTAMP,@DELETION_GUEST_ASSIGNFLAG);
                           SET @THID=(SELECT TH_ID FROM TICKLER_HISTORY WHERE TH_ID=(SELECT MAX(TH_ID) FROM TICKLER_HISTORY WHERE TTIP_ID=14));
                           UPDATE TICKLER_HISTORY SET CUSTOMER_ID=CA_CUSTOMER_ID WHERE TH_ID=@THID;                
                           SET MINTERMID=MINTERMID+1;
                       END WHILE;
                       SET GUEST_ASSIGNFLAG=1;
                    END IF;
					IF NOT EXISTS(SELECT * FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_REC_VER=CA_REC_VER AND UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=OLD_ACCESS_CARD_NO))THEN
                            UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_INVENTORY='X',UASD_ACCESS_ACTIVE=NULL WHERE UASD_ACCESS_CARD=OLD_ACCESS_CARD_NO;
							END IF;
             END IF;
			 IF TEMP_CTD_ID IS NOT NULL THEN
			 SET @DROP_TEMP_CTD_ID=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_CTD_ID));
		     PREPARE DROP_TEMP_CTD_ID_STMT FROM @DROP_TEMP_CTD_ID;
             EXECUTE DROP_TEMP_CTD_ID_STMT;
			 END IF;		
        COMMIT; 
END;