DROP PROCEDURE IF EXISTS SP_CUSTOMER_NULL_CARDASSIGN_INSERT;
CREATE PROCEDURE SP_CUSTOMER_NULL_CARDASSIGN_INSERT(
IN CA_CUSTOMER_ID INTEGER,
IN CA_UNIT_NO INTEGER(4),
IN CA_REC_VER INTEGER,
IN CA_CARD_NO TEXT,
IN CA_VALID_FROM DATE,
IN CA_GUEST_CARD TEXT,
IN CA_STARTDATE DATE,
IN CA_ENDDATE DATE,
IN CA_COMMENTS TEXT,
IN SAMEUNITMINID INTEGER,
IN USERSTAMP VARCHAR(50),
IN TEMPTABLEDROPPING TEXT,
OUT FLAG TEXT)
BEGIN
    DECLARE PRETERMINATE_DATE DATE;
    DECLARE RECHECKIN_RECVER INTEGER;
    DECLARE RECHECKIN_NULL_RECVER INTEGER;
    DECLARE STARTDATE DATE;
    DECLARE TERMINATE_RECVER INTEGER;
    DECLARE ACTIVE_RECVER INTEGER;
    DECLARE FUTURE_RECVER INTEGER;
    DECLARE TERMINATE_NULL_RECVER INTEGER;
    DECLARE ACTIVE_NULL_RECVER INTEGER;
    DECLARE FUTURE_NULL_RECVER INTEGER;
    DECLARE TEMP_ACCESS_CARD TEXT;
    DECLARE OLD_ACCESS_CARD_NO VARCHAR(7);
    DECLARE NEW_ACCESS_CARD_NO VARCHAR(7);
    DECLARE ACCESS_POSITION INTEGER;
    DECLARE ACCESS_LOCATION INTEGER;
    DECLARE ACCESS_LENGTH INTEGER;
    DECLARE GUEST_ACCESS_LENGTH INTEGER;
    DECLARE GUEST_FLAG CHAR(1);
    DECLARE MIN_REC_VER INTEGER;
    DECLARE MAX_REC_VER INTEGER;
    DECLARE MINID INTEGER;
    DECLARE MAXID INTEGER;
    DECLARE ENDDATE DATE;
    DECLARE USERSTAMP_ID INTEGER;
    DECLARE MINTERMID INTEGER;
    DECLARE MAXTERMID INTEGER;
    DECLARE MINACCESSID INTEGER;
    DECLARE MAXACCESSID INTEGER;
    DECLARE UASDID INTEGER;
    DECLARE OLDCOMMENTS TEXT;
    DECLARE NEWCOMMENTS TEXT;
    DECLARE SAMEUNITMAXID INTEGER;
    DECLARE CURRENT_REC_VER INTEGER;
    DECLARE TEMPCACDID TEXT;
    DECLARE TEMP_CACD_ID TEXT;
	DECLARE TEMPCARD TEXT;
	DECLARE TEMP_CARD TEXT;
	DECLARE TEMPNULLCARDCUSTOMER TEXT;
	DECLARE TEMP_NULL_CARD_CUSTOMER TEXT;
	DECLARE TEMPCTDID TEXT;
	DECLARE TEMP_CTD_ID TEXT;
	DECLARE OLD_ULDID INTEGER;
	DECLARE T_UASDID INTEGER;
     SET AUTOCOMMIT=0;
    IF CA_COMMENTS='' THEN
      SET CA_COMMENTS=NULL;
    END IF;
    IF CA_CARD_NO='' THEN
        SET CA_CARD_NO=NULL;
    END IF;
    IF CA_GUEST_CARD='' THEN
        SET CA_GUEST_CARD=NULL;
    END IF;
  CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
    SET USERSTAMP_ID = (SELECT @ULDID);
    SET FLAG=0;
    SET RECHECKIN_RECVER=(SELECT MAX(CED_REC_VER) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_RECHECKIN='X');
   IF CA_CARD_NO IS NULL AND CA_GUEST_CARD IS NULL THEN
         IF CA_REC_VER=1 OR RECHECKIN_RECVER=CA_REC_VER THEN
					SET TEMPCACDID=(SELECT CONCAT('TEMP_CACD_ID_',SYSDATE()));
                    SET TEMPCACDID=(SELECT REPLACE(TEMPCACDID,' ',''));
                    SET TEMPCACDID=(SELECT REPLACE(TEMPCACDID,'-',''));
                    SET TEMPCACDID=(SELECT REPLACE(TEMPCACDID,':',''));
                    SET TEMP_CACD_ID=(SELECT CONCAT(TEMPCACDID,'_',USERSTAMP_ID)); 	
					SET @CREATE_TEMP_CACD_ID=(SELECT CONCAT('CREATE TABLE ',TEMP_CACD_ID,'(ID INTEGER AUTO_INCREMENT PRIMARY KEY,CACDID INTEGER)'));
					PREPARE CREATE_TEMP_CACD_ID_STMT FROM @CREATE_TEMP_CACD_ID;
                    EXECUTE CREATE_TEMP_CACD_ID_STMT;
					SET @INSERT_TEMP_TABLE_DROPPING=(SELECT CONCAT('INSERT INTO ',TEMPTABLEDROPPING,'(TABLE_NAME)VALUES(','"',TEMP_CACD_ID,'"',')'));
					PREPARE INSERT_TEMP_TABLE_DROPPING_STMT FROM @INSERT_TEMP_TABLE_DROPPING;
					EXECUTE INSERT_TEMP_TABLE_DROPPING_STMT;	
                    SET @INSERT_TEMP_CACD_ID=(SELECT CONCAT('INSERT INTO ',TEMP_CACD_ID,'(CACDID) SELECT CACD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID IN (SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=',CA_CUSTOMER_ID,' AND CED_REC_VER>=',CA_REC_VER,' AND CED_REC_VER<=',SAMEUNITMINID,') AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
					PREPARE INSERT_TEMP_CACD_ID_STMT FROM @INSERT_TEMP_CACD_ID;
                    EXECUTE INSERT_TEMP_CACD_ID_STMT;
                    SET @MINACCESSID=(SELECT CONCAT('SELECT MIN(ID) INTO @TEMPMINACCESSID FROM ',TEMP_CACD_ID));
					PREPARE MINACCESSID_STMT FROM @MINACCESSID;
                    EXECUTE MINACCESSID_STMT;					
                    SET @MAXACCESSID=(SELECT CONCAT('SELECT MAX(ID) INTO @TEMPMAXACCESSID FROM ',TEMP_CACD_ID));
					PREPARE MAXACCESSID_STMT FROM @MAXACCESSID;
                    EXECUTE MAXACCESSID_STMT;
					SET MINACCESSID=@TEMPMINACCESSID;
					SET MAXACCESSID=@TEMPMAXACCESSID;
                    WHILE MINACCESSID<=MAXACCESSID DO
					SET @CACD_ID=NULL;
				    SET @SELECT_CACDID=(SELECT CONCAT('SELECT CACDID INTO @CACD_ID FROM ',TEMP_CACD_ID,' WHERE ID=',MINACCESSID));
				    PREPARE SELECT_CACDID_STMT FROM @SELECT_CACDID;
                    EXECUTE SELECT_CACDID_STMT;
					CALL SP_CUSTOMER_ROW_DELETION(13,@CACD_ID,USERSTAMP_ID);                      
					SET MINACCESSID=MINACCESSID+1;
                    END WHILE;
					UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_INVENTORY='X',UASD_ACCESS_ACTIVE=NULL WHERE UASD_ID IN (SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_REC_VER>=CA_REC_VER AND CED_REC_VER<=SAMEUNITMINID);
				SET FLAG=1;
        ELSE
		 SET TEMPCARD=(SELECT CONCAT('TEMP_CARD_',SYSDATE()));
         SET TEMPCARD=(SELECT REPLACE(TEMPCARD,' ',''));
         SET TEMPCARD=(SELECT REPLACE(TEMPCARD,'-',''));
         SET TEMPCARD=(SELECT REPLACE(TEMPCARD,':',''));
         SET TEMP_CARD=(SELECT CONCAT(TEMPCARD,'_',USERSTAMP_ID)); 	
	     SET @CREATE_TEMP_CARD=(SELECT CONCAT('CREATE TABLE ',TEMP_CARD,'(ID INTEGER PRIMARY KEY AUTO_INCREMENT,CARDNO INTEGER)'));
		 PREPARE CREATE_TEMP_CARD_STMT FROM @CREATE_TEMP_CARD;
         EXECUTE CREATE_TEMP_CARD_STMT;
		 SET @INSERT_TEMP_TABLE_DROPPING=(SELECT CONCAT('INSERT INTO ',TEMPTABLEDROPPING,'(TABLE_NAME)VALUES(','"',TEMP_CARD,'"',')'));
		PREPARE INSERT_TEMP_TABLE_DROPPING_STMT FROM @INSERT_TEMP_TABLE_DROPPING;
		EXECUTE INSERT_TEMP_TABLE_DROPPING_STMT;
         IF SAMEUNITMINID IS NULL THEN
           SET @INSERT_TEMP_CARD=(SELECT CONCAT('INSERT INTO ',TEMP_CARD,'(CARDNO) SELECT DISTINCT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=',CA_CUSTOMER_ID,' AND CED_REC_VER=',CA_REC_VER,'  AND UASD_ID IS NOT NULL'));
		   PREPARE INSERT_TEMP_CARD_STMT FROM @INSERT_TEMP_CARD;
           EXECUTE INSERT_TEMP_CARD_STMT;
         ELSE
           SET @INSERT_TEMP_CARD=(SELECT CONCAT('INSERT INTO ',TEMP_CARD,'(CARDNO) SELECT DISTINCT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=',CA_CUSTOMER_ID,' AND CED_REC_VER>=',CA_REC_VER,' AND CED_REC_VER<=',SAMEUNITMINID,'  AND UASD_ID IS NOT NULL'));
		   PREPARE INSERT_TEMP_CARD_STMT FROM @INSERT_TEMP_CARD;
           EXECUTE INSERT_TEMP_CARD_STMT;
         END IF;
          SET @MINID=(SELECT CONCAT('SELECT MIN(ID) INTO @TEMPMINID FROM ',TEMP_CARD));
		  PREPARE MINID_STMT FROM @MINID;
           EXECUTE MINID_STMT;
          SET @MAXID=(SELECT CONCAT('SELECT MAX(ID)INTO @TEMPMAXID FROM ',TEMP_CARD));
          PREPARE MAXID_STMT FROM @MAXID;
           EXECUTE MAXID_STMT;
		   SET MINID=@TEMPMINID;
		   SET MAXID=@TEMPMAXID;
    WHILE(MINID<=MAXID)DO	
	     SET TEMPNULLCARDCUSTOMER=(SELECT CONCAT('TEMP_NULL_CARD_CUSTOMER_',SYSDATE()));
         SET TEMPNULLCARDCUSTOMER=(SELECT REPLACE(TEMPNULLCARDCUSTOMER,' ',''));
         SET TEMPNULLCARDCUSTOMER=(SELECT REPLACE(TEMPNULLCARDCUSTOMER,'-',''));
         SET TEMPNULLCARDCUSTOMER=(SELECT REPLACE(TEMPNULLCARDCUSTOMER,':',''));
         SET TEMP_NULL_CARD_CUSTOMER=(SELECT CONCAT(TEMPNULLCARDCUSTOMER,'_',MINID,'_',USERSTAMP_ID)); 	
	         SET @CREATE_TEMP_NULL_CARD_CUSTOMER=(SELECT CONCAT('CREATE TABLE ',TEMP_NULL_CARD_CUSTOMER,'(CLP_ID INTEGER,CUSTOMER_ID INTEGER,CED_REC_VER INTEGER,UASD_ID INTEGER,CLP_STARTDATE DATE,CLP_ENDDATE DATE,CLP_PRETERMINATE_DATE DATE,CLP_TERMINATE CHAR(1),ULD_ID INTEGER,TIMESTAMP TIMESTAMP)'));
			PREPARE CREATE_TEMP_NULL_CARD_CUSTOMER_STMT FROM @CREATE_TEMP_NULL_CARD_CUSTOMER;
            EXECUTE CREATE_TEMP_NULL_CARD_CUSTOMER_STMT; 
			 SET @INSERT_TEMP_TABLE_DROPPING=(SELECT CONCAT('INSERT INTO ',TEMPTABLEDROPPING,'(TABLE_NAME)VALUES(','"',TEMP_NULL_CARD_CUSTOMER,'"',')'));
			PREPARE INSERT_TEMP_TABLE_DROPPING_STMT FROM @INSERT_TEMP_TABLE_DROPPING;
			EXECUTE INSERT_TEMP_TABLE_DROPPING_STMT;
            SET RECHECKIN_NULL_RECVER=(SELECT MAX(CED_REC_VER) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_RECHECKIN='X');
            IF RECHECKIN_NULL_RECVER IS NOT NULL THEN
                SET @INSERT_TEMP_NULL_CARD_CUSTOMER=(SELECT CONCAT('INSERT INTO ',TEMP_NULL_CARD_CUSTOMER,' SELECT CLP_ID,CUSTOMER_ID,CED_REC_VER,UASD_ID,CLP_STARTDATE,CLP_ENDDATE,CLP_PRETERMINATE_DATE,CLP_TERMINATE,ULD_ID,CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=',CA_CUSTOMER_ID,' AND UASD_ID=(SELECT CARDNO FROM ',TEMP_CARD,' WHERE ID=',MINID,') AND CED_REC_VER!=',CA_REC_VER,' AND (CED_REC_VER>=',RECHECKIN_NULL_RECVER,' AND CED_REC_VER<=',RECHECKIN_NULL_RECVER,')  AND  CLP_TERMINATE IS NULL'));
				PREPARE INSERT_TEMP_NULL_CARD_CUSTOMER_STMT FROM @INSERT_TEMP_NULL_CARD_CUSTOMER;
                EXECUTE INSERT_TEMP_NULL_CARD_CUSTOMER_STMT;
                ELSE
                SET @INSERT_TEMP_NULL_CARD_CUSTOMER=(SELECT CONCAT('INSERT INTO ',TEMP_NULL_CARD_CUSTOMER,' SELECT CLP_ID,CUSTOMER_ID,CED_REC_VER,UASD_ID,CLP_STARTDATE,CLP_ENDDATE,CLP_PRETERMINATE_DATE,CLP_TERMINATE,ULD_ID,CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=',CA_CUSTOMER_ID,' AND UASD_ID=(SELECT CARDNO FROM ',TEMP_CARD,' WHERE ID=',MINID,') AND CED_REC_VER!=',CA_REC_VER,' AND CLP_TERMINATE IS NULL'));
				PREPARE INSERT_TEMP_NULL_CARD_CUSTOMER_STMT FROM @INSERT_TEMP_NULL_CARD_CUSTOMER;
                EXECUTE INSERT_TEMP_NULL_CARD_CUSTOMER_STMT;
            END IF;               
			    SET @TERMINATE_NULL_RECVER=NULL;
                SET @TERMINATE_NULLRECVER=(SELECT CONCAT('SELECT MAX(CED_REC_VER) INTO @TERMINATE_NULL_RECVER FROM ',TEMP_NULL_CARD_CUSTOMER,' WHERE UASD_ID=(SELECT CARDNO FROM ',TEMP_CARD,' WHERE ID=',MINID,') AND CED_REC_VER<',CA_REC_VER,' AND IF (CLP_PRETERMINATE_DATE IS NOT NULL,CLP_PRETERMINATE_DATE<CURDATE(), CLP_ENDDATE<CURDATE()) AND CLP_TERMINATE IS NULL'));
				PREPARE TERMINATE_NULLRECVER_STMT FROM @TERMINATE_NULLRECVER;
                EXECUTE TERMINATE_NULLRECVER_STMT;
				SET TERMINATE_RECVER=@TERMINATE_NULL_RECVER;
				SET @ACTIVE_NULLRECVER=NULL;
                SET @ACTIVE_NULLRECVER=(SELECT CONCAT('SELECT MAX(CED_REC_VER) INTO @ACTIVE_NULLRECVER FROM ',TEMP_NULL_CARD_CUSTOMER,' WHERE UASD_ID=(SELECT CARDNO FROM ',TEMP_CARD,' WHERE ID=',MINID,') AND CED_REC_VER<',CA_REC_VER,' AND IF (CLP_PRETERMINATE_DATE IS NOT NULL,CLP_PRETERMINATE_DATE>CURDATE(), CLP_ENDDATE>CURDATE()) AND CLP_TERMINATE IS NULL'));
				PREPARE ACTIVE_NULLRECVER_STMT FROM @ACTIVE_NULLRECVER;
                EXECUTE ACTIVE_NULLRECVER_STMT;
				SET ACTIVE_NULL_RECVER=@ACTIVE_NULLRECVER;
				SET @FUTURE_NULLRECVER=NULL;
                SET @FUTURE_NULLRECVER=(SELECT CONCAT('SELECT MAX(CED_REC_VER) INTO @FUTURE_NULLRECVER FROM ',TEMP_NULL_CARD_CUSTOMER,' WHERE UASD_ID=(SELECT CARDNO FROM ',TEMP_CARD,' WHERE ID=',MINID,') AND CED_REC_VER>',CA_REC_VER,' AND IF (CLP_PRETERMINATE_DATE IS NOT NULL,CLP_PRETERMINATE_DATE>CURDATE(), CLP_ENDDATE>CURDATE()) AND CLP_TERMINATE IS NULL'));
				PREPARE FUTURE_NULLRECVER_STMT FROM @FUTURE_NULLRECVER;
                EXECUTE FUTURE_NULLRECVER_STMT;
				SET FUTURE_NULL_RECVER=@FUTURE_NULLRECVER;
                IF TERMINATE_RECVER IS NOT NULL AND ACTIVE_NULL_RECVER IS NULL THEN
				           SET @TEMPPRETERMINATE_DATE=NULL;
                           SET @PRETERMINATEDATE=(SELECT CONCAT('SELECT CLP_PRETERMINATE_DATE INTO @TEMPPRETERMINATE_DATE FROM ',TEMP_NULL_CARD_CUSTOMER,' WHERE CED_REC_VER=@TERMINATE_NULL_RECVER'));
						   PREPARE PRETERMINATEDATE_STMT FROM @PRETERMINATEDATE;
                           EXECUTE PRETERMINATEDATE_STMT;
						   SET @TEMP_CACDID=NULL;
				  SET @SELECT_TEMPCACDID=(SELECT CONCAT('SELECT CACD_ID INTO @TEMP_CACDID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=(SELECT CARDNO FROM ',TEMP_CARD,' WHERE ID=',MINID,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
				  PREPARE SELECT_TEMPCACDID_STMT FROM @SELECT_TEMPCACDID;
                  EXECUTE SELECT_TEMPCACDID_STMT;
				  SET @TEMP_ULDID=NULL;
				  SET @SELECT_TEMPULDID=(SELECT CONCAT('SELECT ULD_ID INTO @TEMP_ULDID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=(SELECT CARDNO FROM ',TEMP_CARD,' WHERE ID=',MINID,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
				  PREPARE SELECT_TEMPULDID_STMT FROM @SELECT_TEMPULDID;
                  EXECUTE SELECT_TEMPULDID_STMT;
				  SET OLD_ULDID=@TEMP_ULDID;
				  SET @TEMP_TIMESTAMP=NULL;
				  SET @SELECT_TEMPTIMESTAMP=(SELECT CONCAT('SELECT CACD_TIMESTAMP INTO @TEMP_TIMESTAMP FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=(SELECT CARDNO FROM ',TEMP_CARD,' WHERE ID=',MINID,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
				  PREPARE SELECT_TEMPTIMESTAMP_STMT FROM @SELECT_TEMPTIMESTAMP;
                  EXECUTE SELECT_TEMPTIMESTAMP_STMT;
						   SET PRETERMINATE_DATE=@TEMPPRETERMINATE_DATE;
                             IF PRETERMINATE_DATE IS NULL THEN
								SET @UASDID=NULL;
								SET @TEMPUASDID=(SELECT CONCAT('SELECT UASD_ID INTO @UASDID FROM ',TEMP_NULL_CARD_CUSTOMER,' WHERE CED_REC_VER=',TERMINATE_RECVER));
								PREPARE UASDID_STMT FROM @TEMPUASDID;
                                EXECUTE UASDID_STMT;
								IF(OLD_ULDID!=USERSTAMP_ID)THEN
                                  SET @TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',@TEMP_CACDID,',UASD_ID=',@UASDID,',ACN_ID=NULL',',CACD_VALID_TILL=NULL,','ULD_ID=',OLD_ULDID,',','CACD_TIMESTAMP=',@TEMP_TIMESTAMP));
								ELSE
								  SET @TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',@TEMP_CACDID,',UASD_ID=',@UASDID,',ACN_ID=NULL',',CACD_VALID_TILL=NULL,','CACD_TIMESTAMP=',@TEMP_TIMESTAMP));	
								END IF;
								SET @VALIDTILL=NULL;
								SET @TEMPCLP_ENDDATE=(SELECT CONCAT('SELECT CLP_ENDDATE INTO @VALIDTILL FROM ',TEMP_NULL_CARD_CUSTOMER,' WHERE CED_REC_VER=',TERMINATE_RECVER));
								PREPARE TEMPCLP_ENDDATE_STMT FROM @TEMPCLP_ENDDATE;
                                EXECUTE TEMPCLP_ENDDATE_STMT;
                                SET @TICK_ACCESS_NEW_VALUE=(SELECT CONCAT('ACN_ID=4',',VALID_TILL=',@VALIDTILL));
                                INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ACCESS_CARD_DETAILS'),@TICK_ACCESS_OLD_VALUE,@TICK_ACCESS_NEW_VALUE,USERSTAMP_ID,CA_CUSTOMER_ID);
                                SET @UPDATECACD=(SELECT CONCAT('UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET ACN_ID=4,CACD_VALID_TILL=(SELECT CLP_ENDDATE FROM ',TEMP_NULL_CARD_CUSTOMER,' WHERE CED_REC_VER=',TERMINATE_RECVER,')  WHERE UASD_ID=(SELECT CARDNO FROM ',TEMP_CARD,' WHERE ID=',MINID,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
								PREPARE UPDATECACD_STMT FROM @UPDATECACD;
                                EXECUTE UPDATECACD_STMT;
                              ELSE
							    SET @UASDID=NULL;
								SET @TEMPUASDID=(SELECT CONCAT('SELECT UASD_ID INTO @UASDID FROM ',TEMP_NULL_CARD_CUSTOMER,' WHERE CED_REC_VER=',TERMINATE_RECVER));
								PREPARE UASDID_STMT FROM @TEMPUASDID;
                                EXECUTE UASDID_STMT;
                                IF(OLD_ULDID!=USERSTAMP_ID)THEN
                                    SET @TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',@TEMP_CACDID,',UASD_ID=',@UASDID,',ACN_ID=NULL',',CACD_VALID_TILL=NULL,','ULD_ID=',OLD_ULDID,',','CACD_TIMESTAMP=',@TEMP_TIMESTAMP));
								ELSE
								   SET @TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',@TEMP_CACDID,',UASD_ID=',@UASDID,',ACN_ID=NULL',',CACD_VALID_TILL=NULL,','CACD_TIMESTAMP=',@TEMP_TIMESTAMP));
                                END IF;								   
								SET @VALIDTILL=NULL;
								SET @TEMPCLP_ENDDATE=(SELECT CONCAT('SELECT CLP_ENDDATE INTO @VALIDTILL FROM ',TEMP_NULL_CARD_CUSTOMER,' WHERE CED_REC_VER=',TERMINATE_RECVER));
								PREPARE TEMPCLP_ENDDATE_STMT FROM @TEMPCLP_ENDDATE;
                                EXECUTE TEMPCLP_ENDDATE_STMT;
                                SET @TICK_ACCESS_NEW_VALUE=(SELECT CONCAT('ACN_ID=4',',VALID_TILL=',@VALIDTILL));
                                INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ACCESS_CARD_DETAILS'),@TICK_ACCESS_OLD_VALUE,@TICK_ACCESS_NEW_VALUE,USERSTAMP_ID,CA_CUSTOMER_ID);
                                SET @UPDATE_CACD=(SELECT CONCAT('UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET ACN_ID=4,CACD_VALID_TILL=(SELECT CLP_PRETERMINATE_DATE FROM ',TEMP_NULL_CARD_CUSTOMER,' WHERE CED_REC_VER=',TERMINATE_RECVER,')  WHERE UASD_ID=(SELECT CARDNO FROM ',TEMP_CARD,' WHERE ID=',MINID,') AND CUSTOMER_ID=',CA_CUSTOMER_ID,' AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
								PREPARE UPDATE_CACD_STMT FROM @UPDATE_CACD;
                                EXECUTE UPDATE_CACD_STMT;
                                END IF;
								SET @TEMP_UASDID=NULL;
								SET @SELECT_CARD=(SELECT CONCAT('SELECT CARDNO INTO @TEMP_UASDID FROM ',TEMP_CARD,' WHERE ID=',MINID));
								PREPARE SELECT_CARD_STMT FROM @SELECT_CARD;
                                EXECUTE SELECT_CARD_STMT;
								SET T_UASDID=@TEMP_UASDID;
                            UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_INVENTORY='X',UASD_ACCESS_ACTIVE=NULL WHERE UASD_ID=T_UASDID;
                        ELSE
                            IF ACTIVE_NULL_RECVER IS NULL THEN
							SET @CACD_ID=NULL;
                            SET @TEMPCACD_ID=(SELECT CONCAT('SELECT CACD_ID INTO @CACD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=',CA_CUSTOMER_ID,' AND UASD_ID=(SELECT CARDNO FROM ',TEMP_CARD,' WHERE ID=',MINID,') AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL'));
							PREPARE TEMPCACD_ID_STMT FROM @TEMPCACD_ID;
                            EXECUTE TEMPCACD_ID_STMT;							
							CALL SP_CUSTOMER_ROW_DELETION(13,@CACD_ID,USERSTAMP_ID);                      
							SET @TEMP_UASDID=NULL;
								SET @SELECT_CARD=(SELECT CONCAT('SELECT CARDNO INTO @TEMP_UASDID FROM ',TEMP_CARD,' WHERE ID=',MINID));
								PREPARE SELECT_CARD_STMT FROM @SELECT_CARD;
                                EXECUTE SELECT_CARD_STMT;
                                 SET T_UASDID=@TEMP_UASDID;								
                            UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_INVENTORY='X',UASD_ACCESS_ACTIVE=NULL WHERE UASD_ID=T_UASDID;
                        END IF;
                        END IF;
           SET MINID=MINID+1;
		END WHILE;
    END IF;
   SET MIN_REC_VER = CA_REC_VER;
    IF SAMEUNITMINID IS NULL THEN
    SET SAMEUNITMINID=CA_REC_VER;
    ELSE
    SET SAMEUNITMINID=SAMEUNITMINID;
    END IF;
        WHILE(MIN_REC_VER<=SAMEUNITMINID)DO
        SET UASDID=(SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_REC_VER=MIN_REC_VER AND CLP_GUEST_CARD IS NULL);
        IF UASDID IS NOT NULL THEN
		SET OLD_ULDID=(SELECT ULD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_REC_VER=MIN_REC_VER AND CLP_GUEST_CARD IS NULL);
		IF(USERSTAMP_ID!=OLD_ULDID) THEN
		SET @TICKTERMOLDVALUE=(SELECT CONCAT('CLP_ID=',(SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_REC_VER=MIN_REC_VER AND CLP_GUEST_CARD IS NULL),',UASD_ID=',(SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_REC_VER=MIN_REC_VER AND CLP_GUEST_CARD IS NULL),',','CED_REC_VER=',MIN_REC_VER,',','ULD_ID=',OLD_ULDID,',','CLP_TIMESTAMP=',(SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_REC_VER=MIN_REC_VER AND CLP_GUEST_CARD IS NULL)));
		ELSE
        SET @TICKTERMOLDVALUE=(SELECT CONCAT('CLP_ID=',(SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_REC_VER=MIN_REC_VER AND CLP_GUEST_CARD IS NULL),',UASD_ID=',(SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_REC_VER=MIN_REC_VER AND CLP_GUEST_CARD IS NULL),',','CED_REC_VER=',MIN_REC_VER,',','CLP_TIMESTAMP=',(SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CA_CUSTOMER_ID AND CED_REC_VER=MIN_REC_VER AND CLP_GUEST_CARD IS NULL)));
		END IF;
        SET @TICKTERMNEWVALUE=(SELECT CONCAT('UASD_ID=NULL',',','CED_REC_VER=',MIN_REC_VER));
        INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_LP_DETAILS'),@TICKTERMOLDVALUE,@TICKTERMNEWVALUE,USERSTAMP_ID,CA_CUSTOMER_ID);
        END IF;
            UPDATE CUSTOMER_LP_DETAILS CTD,CUSTOMER_ENTRY_DETAILS CED,UNIT U SET CTD.UASD_ID=NULL WHERE
            CTD.CED_REC_VER=MIN_REC_VER AND CTD.CUSTOMER_ID=CA_CUSTOMER_ID AND CTD.CUSTOMER_ID=CED.CUSTOMER_ID AND
            CED.CED_REC_VER=CTD.CED_REC_VER AND CED.UNIT_ID=U.UNIT_ID AND U.UNIT_NO=CA_UNIT_NO AND CLP_GUEST_CARD IS NULL;
			SET @CUST_FLAG=2;
			SET TEMPCTDID=(SELECT CONCAT('TEMP_CTD_ID_',SYSDATE()));
            SET TEMPCTDID=(SELECT REPLACE(TEMPCTDID,' ',''));
            SET TEMPCTDID=(SELECT REPLACE(TEMPCTDID,'-',''));
            SET TEMPCTDID=(SELECT REPLACE(TEMPCTDID,':',''));
            SET TEMP_CTD_ID=(SELECT CONCAT(TEMPCTDID,'_',MIN_REC_VER,'_',USERSTAMP_ID)); 	
            SET @CREATE_TEMP_CTD_ID=(SELECT CONCAT('CREATE TABLE ',TEMP_CTD_ID,'(ID INTEGER AUTO_INCREMENT PRIMARY KEY,CTDID INTEGER)'));
			PREPARE CREATE_TEMP_CTD_ID_STMT FROM @CREATE_TEMP_CTD_ID;
            EXECUTE CREATE_TEMP_CTD_ID_STMT; 
			SET @INSERT_TEMP_TABLE_DROPPING=(SELECT CONCAT('INSERT INTO ',TEMPTABLEDROPPING,'(TABLE_NAME)VALUES(','"',TEMP_CTD_ID,'"',')'));
			PREPARE INSERT_TEMP_TABLE_DROPPING_STMT FROM @INSERT_TEMP_TABLE_DROPPING;
			EXECUTE INSERT_TEMP_TABLE_DROPPING_STMT;
            SET @INSERT_TEMP_CTD_ID=(SELECT CONCAT('INSERT INTO ',TEMP_CTD_ID,'(CTDID)(SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID =',CA_CUSTOMER_ID,' AND CED_REC_VER =',MIN_REC_VER,' AND CLP_GUEST_CARD IS NOT NULL)'));
			PREPARE INSERT_TEMP_CTD_ID_STMT FROM @INSERT_TEMP_CTD_ID;
            EXECUTE INSERT_TEMP_CTD_ID_STMT;
			SET @TEMPMINID=NULL;
            SET @TEMPMIN_ID=(SELECT CONCAT('SELECT MIN(ID) INTO @TEMPMINID FROM ',TEMP_CTD_ID));
			PREPARE TEMPMINID_STMT FROM @TEMPMIN_ID;
            EXECUTE TEMPMINID_STMT;
			SET @TEMPMAXID=NULL;
            SET @TEMPMAX_ID=(SELECT CONCAT('SELECT MAX(ID) INTO @TEMPMAXID FROM ',TEMP_CTD_ID));
			PREPARE TEMPMAX_ID_STMT FROM @TEMPMAX_ID;
            EXECUTE TEMPMAX_ID_STMT;
			SET MINID=@TEMPMINID;
			SET MAXID=@TEMPMAXID;
            WHILE MINID<=MAXID DO
			SET @CTD_ID=NULL;
			SET @TEMP_CTD_ID=(SELECT CONCAT('SELECT CTDID INTO @CTD_ID  FROM ',TEMP_CTD_ID,' WHERE ID=',MINID));
			PREPARE TEMP_CTD_ID_STMT FROM @TEMP_CTD_ID;
            EXECUTE TEMP_CTD_ID_STMT;
            CALL SP_CUSTOMER_ROW_DELETION(14,@CTD_ID,USERSTAMP_ID);
            SET MINID=MINID+1;
            END WHILE;
        SET MIN_REC_VER = MIN_REC_VER+1;
	END WHILE;		    
      SET FLAG=1;
    END IF;
	END;
	