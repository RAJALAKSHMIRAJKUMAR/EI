-- version --> 0.3 startdate-->01/08/2014 enddate-->25/08/2014 --issueno:732,commentno:57-->desc:REMOVED COMMIT,ROLLBACK,ADDED CONDITION TO UPDATE ACS CARD TABLE BY PUNI
-- version --> 0.2 startdate-->17/06/2014 enddate-->19/06/2014 --issueno:738,commentno:33-->desc:UPDATED ULD ID N TIMESTAMP IN OLD VALUE COL IN TICKLER HISTORY BY PUNI
-- version --> 0.1 startdate-->08/05/2014 enddate-->09/05/2014--issueno:743,-->desc:SPLITTED SP TO UPDATE PTD NULL FOR CUSTOMER TO CALL IN MAIN SP BY SAFI
DROP PROCEDURE IF EXISTS SP_CUSTOMER_MANUAL_TERMINATION_PTD_NULL_INSERT;
CREATE PROCEDURE SP_CUSTOMER_MANUAL_TERMINATION_PTD_NULL_INSERT(
IN CT_CUSTOMER_ID INTEGER,
IN CT_REC_VER INTEGER,
IN TERM_MAX_CUSTRV INTEGER,
IN ACTIVE_RECVER INTEGER,
IN USERSTAMP_ID INTEGER,
OUT TERMRESULT_FLAG INTEGER)
BEGIN
	DECLARE TERM_NULL_PTD DATE;
	DECLARE TERM_NULL_ENDATE DATE;
	DECLARE TERM_NULL_STARTDATE DATE;
	DECLARE TERM_NULL_NRVSTARTDATE DATE;
	DECLARE TERM_NULL_NRVENDATE DATE;
	DECLARE TERM_UASDID INTEGER DEFAULT NULL;
	DECLARE MIN_RECVER INTEGER;
	DECLARE MAX_RECVER INTEGER;
	DECLARE TICK_PTD TEXT;
	DECLARE TICK_OLD_VALUE  TEXT;
	DECLARE TICK_NEW_VALUE  TEXT;
	DECLARE MIN_CTDID INTEGER DEFAULT 0;
	DECLARE MAX_CTDID INTEGER DEFAULT 0;
	DECLARE CLP_GSTVAL VARCHAR(10);
	DECLARE CLP_UASDIDVAL INTEGER;
	DECLARE PTDFLAG INTEGER DEFAULT 0;
	DECLARE EDFLAG INTEGER DEFAULT 0;
	DECLARE TICK_ACS_OLD_VALUE TEXT;
	DECLARE GST_NULL_FLAG INTEGER DEFAULT 0;	
	SET MIN_RECVER=ACTIVE_RECVER;
	SET MAX_RECVER=TERM_MAX_CUSTRV;
	IF(MAX_RECVER>=MIN_RECVER) THEN
		RECVER_LOOP:  LOOP	
-- update ptd=null from active rv to input rv -1 start		
			SET TERM_NULL_STARTDATE=(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_GUEST_CARD IS NULL AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()));
			SET TERM_NULL_PTD=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_GUEST_CARD IS NULL AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()));
			SET TERM_NULL_ENDATE=(SELECT CLP_ENDDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_GUEST_CARD IS NULL AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()));
			SET TERM_NULL_NRVSTARTDATE=(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=(MIN_RECVER+1) AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_GUEST_CARD IS NULL AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()));					
			SET TERM_NULL_NRVENDATE=(SELECT CLP_ENDDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=(MIN_RECVER+1) AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_GUEST_CARD IS NULL AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()));					
			SET TERM_UASDID = (SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER AND CLP_GUEST_CARD IS NULL AND CUSTOMER_ID=CT_CUSTOMER_ID AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()));
			SET TICK_PTD=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER AND CLP_GUEST_CARD IS NULL AND CUSTOMER_ID=CT_CUSTOMER_ID AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()));
			IF TICK_PTD IS NULL THEN 
				SET TICK_PTD='null';
			END IF;		
			IF (SELECT COUNT(*) FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=(MIN_RECVER+1) AND CLP_STARTDATE=TERM_NULL_ENDATE AND CUSTOMER_ID=CT_CUSTOMER_ID AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()))>0 THEN
				IF MIN_RECVER<CT_REC_VER THEN
-- INSERT LP DETAILS INTO TICKLER				
					IF TERM_UASDID IS NOT NULL THEN
						IF(USERSTAMP_ID!=(SELECT ULD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER AND UASD_ID=TERM_UASDID AND CLP_GUEST_CARD IS NULL)) THEN
							SET TICK_OLD_VALUE=(SELECT CONCAT('CLP_ID=',(SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER AND UASD_ID=TERM_UASDID AND CLP_GUEST_CARD IS NULL),',CED_REC_VER=',MIN_RECVER,',CLP_GUEST_CARD=null',',UASD_ID=',TERM_UASDID,',CLP_STARTDATE=',(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_GUEST_CARD IS NULL),',CLP_ENDDATE=',TERM_NULL_ENDATE,',CLP_PRETERMINATE_DATE=',TICK_PTD,',CLP_TERMINATE=null',',ULD_ID=',(SELECT ULD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER AND UASD_ID=TERM_UASDID AND CLP_GUEST_CARD IS NULL),',CLP_TIMESTAMP=',(SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER AND UASD_ID=TERM_UASDID AND CLP_GUEST_CARD IS NULL)));
						ELSE
							SET TICK_OLD_VALUE=(SELECT CONCAT('CLP_ID=',(SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER AND UASD_ID=TERM_UASDID AND CLP_GUEST_CARD IS NULL),',CED_REC_VER=',MIN_RECVER,',CLP_GUEST_CARD=null',',UASD_ID=',TERM_UASDID,',CLP_STARTDATE=',(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_GUEST_CARD IS NULL),',CLP_ENDDATE=',TERM_NULL_ENDATE,',CLP_PRETERMINATE_DATE=',TICK_PTD,',CLP_TERMINATE=null',',CLP_TIMESTAMP=',(SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER AND UASD_ID=TERM_UASDID AND CLP_GUEST_CARD IS NULL)));
						END IF;	
					ELSE
						IF(USERSTAMP_ID!=(SELECT ULD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER AND CLP_GUEST_CARD IS NULL)) THEN
							SET TICK_OLD_VALUE=(SELECT CONCAT('CLP_ID=',(SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER ),',CED_REC_VER=',MIN_RECVER,',CLP_GUEST_CARD=null',',UASD_ID=null',',CLP_STARTDATE=',(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_GUEST_CARD IS NULL),',CLP_ENDDATE=',TERM_NULL_ENDATE,',CLP_PRETERMINATE_DATE=',TICK_PTD,',CLP_TERMINATE=null',',ULD_ID=',(SELECT ULD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER AND CLP_GUEST_CARD IS NULL),',CLP_TIMESTAMP=',(SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER AND CLP_GUEST_CARD IS NULL)));
						ELSE
							SET TICK_OLD_VALUE=(SELECT CONCAT('CLP_ID=',(SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER ),',CED_REC_VER=',MIN_RECVER,',CLP_GUEST_CARD=null',',UASD_ID=null',',CLP_STARTDATE=',(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_GUEST_CARD IS NULL),',CLP_ENDDATE=',TERM_NULL_ENDATE,',CLP_PRETERMINATE_DATE=',TICK_PTD,',CLP_TERMINATE=null',',CLP_TIMESTAMP=',(SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=MIN_RECVER AND CLP_GUEST_CARD IS NULL)));
						END IF;	
					END IF;							
					IF TERM_NULL_PTD IS NOT NULL THEN
-- UPDATE LP DETAILS TABLE					
						UPDATE CUSTOMER_LP_DETAILS CTD SET CTD.CLP_PRETERMINATE_DATE=NULL, CTD.ULD_ID=USERSTAMP_ID WHERE CTD.CUSTOMER_ID=CT_CUSTOMER_ID AND CTD.CED_REC_VER=MIN_RECVER AND CTD.CLP_GUEST_CARD IS NULL;
						SET TERMRESULT_FLAG=1;
						SET TICK_NEW_VALUE='CLP_PRETERMINATE_DATE=null';
						INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES(1,14,TICK_OLD_VALUE,TICK_NEW_VALUE,USERSTAMP_ID,CT_CUSTOMER_ID);
					END IF;	
				END IF;	
			ELSE
				IF (SELECT COUNT(*) FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=(MIN_RECVER+1) AND (CLP_STARTDATE>TERM_NULL_PTD OR CLP_STARTDATE<TERM_NULL_PTD) AND CUSTOMER_ID=CT_CUSTOMER_ID AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()))>0 AND TERM_NULL_PTD IS NOT NULL  AND TERM_NULL_STARTDATE<TERM_NULL_PTD AND TERM_NULL_ENDATE>=TERM_NULL_PTD THEN								
					IF TERM_NULL_PTD<TERM_NULL_NRVENDATE THEN
						SET PTDFLAG=1;											
					ELSEIF TERM_NULL_ENDATE<TERM_NULL_NRVENDATE THEN
						SET EDFLAG=1;
					END IF;
					ELSEIF (SELECT COUNT(*) FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=(MIN_RECVER+1) AND (CLP_STARTDATE>TERM_NULL_PTD OR CLP_STARTDATE<TERM_NULL_PTD) AND CUSTOMER_ID=CT_CUSTOMER_ID AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()))>0 AND TERM_NULL_PTD IS NOT NULL  AND (TERM_NULL_STARTDATE>=TERM_NULL_PTD OR TERM_NULL_ENDATE<TERM_NULL_PTD) THEN								
					IF TERM_NULL_ENDATE<TERM_NULL_NRVENDATE THEN
						SET EDFLAG=1;
					END IF;		
					ELSEIF (SELECT COUNT(*) FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=(MIN_RECVER+1) AND (CLP_STARTDATE>TERM_NULL_ENDATE OR CLP_STARTDATE<TERM_NULL_ENDATE) AND CUSTOMER_ID=CT_CUSTOMER_ID AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()))>0 AND TERM_NULL_PTD IS NULL THEN								
					IF TERM_NULL_ENDATE<TERM_NULL_NRVENDATE THEN
						SET EDFLAG=1;								
					END IF;
				END IF;								
				IF PTDFLAG=1 OR EDFLAG=1 THEN									
					SET MIN_CTDID=(SELECT MIN(CLP_ID) FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER+1 AND CUSTOMER_ID=CT_CUSTOMER_ID);
					SET MAX_CTDID=(SELECT MAX(CLP_ID) FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER+1 AND CUSTOMER_ID=CT_CUSTOMER_ID);
					WHILE (MIN_CTDID<=MAX_CTDID) DO
						IF EXISTS (SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=MIN_CTDID AND IF (CLP_PRETERMINATE_DATE IS NOT NULL ,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE())) THEN
							SET CLP_GSTVAL=(SELECT CLP_GUEST_CARD FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=MIN_CTDID);
							IF CLP_GSTVAL IS NULL THEN
								SET CLP_GSTVAL='null';
							END IF;
							SET CLP_UASDIDVAL=(SELECT UASD_ID FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=MIN_CTDID);
							IF CLP_UASDIDVAL IS NOT NULL THEN
								IF(USERSTAMP_ID!=(SELECT ULD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=(MIN_RECVER+1) AND CLP_ID=MIN_CTDID)) THEN
									SET TICK_OLD_VALUE=(SELECT CONCAT('CLP_ID=',MIN_CTDID,',CED_REC_VER=',(MIN_RECVER+1),',CLP_GUEST_CARD=',CLP_GSTVAL,',UASD_ID=',CLP_UASDIDVAL,',CLP_STARTDATE=',(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER+1 AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_ID=MIN_CTDID),',CLP_ENDDATE=',TERM_NULL_ENDATE,',CLP_PRETERMINATE_DATE=',TICK_PTD,',CLP_TERMINATE=null',',ULD_ID=',(SELECT ULD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=(MIN_RECVER+1) AND CLP_ID=MIN_CTDID),',CLP_TIMESTAMP=',(SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=(MIN_RECVER+1) AND CLP_ID=MIN_CTDID)));
								ELSE
									SET TICK_OLD_VALUE=(SELECT CONCAT('CLP_ID=',MIN_CTDID,',CED_REC_VER=',(MIN_RECVER+1),',CLP_GUEST_CARD=',CLP_GSTVAL,',UASD_ID=',CLP_UASDIDVAL,',CLP_STARTDATE=',(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER+1 AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_ID=MIN_CTDID),',CLP_ENDDATE=',TERM_NULL_ENDATE,',CLP_PRETERMINATE_DATE=',TICK_PTD,',CLP_TERMINATE=null',',CLP_TIMESTAMP=',(SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=(MIN_RECVER+1) AND CLP_ID=MIN_CTDID)));
								END IF;	
							ELSE
								IF(USERSTAMP_ID!=(SELECT ULD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=(MIN_RECVER+1) AND CLP_ID=MIN_CTDID)) THEN
									SET TICK_OLD_VALUE=(SELECT CONCAT('CLP_ID=',MIN_CTDID,',CED_REC_VER=',(MIN_RECVER+1),',CLP_GUEST_CARD=',CLP_GSTVAL,',UASD_ID=null',',CLP_STARTDATE=',(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER+1 AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_ID=MIN_CTDID),',CLP_ENDDATE=',TERM_NULL_ENDATE,',CLP_PRETERMINATE_DATE=',TICK_PTD,',CLP_TERMINATE=null',',ULD_ID=',(SELECT ULD_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=(MIN_RECVER+1) AND CLP_ID=MIN_CTDID),',CLP_TIMESTAMP=',(SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=(MIN_RECVER+1) AND CLP_ID=MIN_CTDID)));
								ELSE
									SET TICK_OLD_VALUE=(SELECT CONCAT('CLP_ID=',MIN_CTDID,',CED_REC_VER=',(MIN_RECVER+1),',CLP_GUEST_CARD=',CLP_GSTVAL,',UASD_ID=null',',CLP_STARTDATE=',(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER=MIN_RECVER+1 AND CUSTOMER_ID=CT_CUSTOMER_ID AND CLP_ID=MIN_CTDID),',CLP_ENDDATE=',TERM_NULL_ENDATE,',CLP_PRETERMINATE_DATE=',TICK_PTD,',CLP_TERMINATE=null',',CLP_TIMESTAMP=',(SELECT CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CT_CUSTOMER_ID AND CED_REC_VER=(MIN_RECVER+1) AND CLP_ID=MIN_CTDID)));
								END IF;		
							END IF;
							IF PTDFLAG=1 THEN
								IF(TERM_NULL_PTD!=TERM_NULL_NRVSTARTDATE) THEN												
									IF CLP_UASDIDVAL IS NOT NULL THEN
										IF (SELECT COUNT(*) FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL)>0 THEN
										IF(SELECT COUNT(*) FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER BETWEEN ACTIVE_RECVER AND TERM_MAX_CUSTRV AND UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID )=1 THEN
										IF(USERSTAMP_ID!=(SELECT ULD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL)) THEN
											SET TICK_ACS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',(SELECT CACD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL),',UASD_ID=',CLP_UASDIDVAL,',ACN_ID=null',',CACD_VALID_FROM=',(SELECT CACD_VALID_FROM FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL),',CACD_VALID_TILL=null',',CACD_GUEST_CARD=',CLP_GSTVAL,',ULD_ID=',(SELECT ULD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL),',CACD_TIMESTAMP=',(SELECT CACD_TIMESTAMP FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL)));
										ELSE
											SET TICK_ACS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',(SELECT CACD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL),',UASD_ID=',CLP_UASDIDVAL,',ACN_ID=null',',CACD_VALID_FROM=',(SELECT CACD_VALID_FROM FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL),',CACD_VALID_TILL=null',',CACD_GUEST_CARD=',CLP_GSTVAL,',CACD_TIMESTAMP=',(SELECT CACD_TIMESTAMP FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL)));
										END IF;	
										SET TICK_NEW_VALUE=(SELECT CONCAT('CACD_VALID_FROM=',TERM_NULL_PTD));
										INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES(1,13,TICK_ACS_OLD_VALUE,TICK_NEW_VALUE,USERSTAMP_ID,CT_CUSTOMER_ID);
										UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET CACD_VALID_FROM=TERM_NULL_PTD WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL;										
										END IF;
										END IF;
									END IF;
									UPDATE CUSTOMER_LP_DETAILS CTD SET CTD.CLP_STARTDATE=TERM_NULL_PTD, CTD.ULD_ID=USERSTAMP_ID WHERE CTD.CUSTOMER_ID=CT_CUSTOMER_ID AND CTD.CED_REC_VER=(MIN_RECVER+1);
									SET TERMRESULT_FLAG=1;													
									SET TICK_NEW_VALUE=(SELECT CONCAT('CLP_STARTDATE=',TERM_NULL_PTD));
									INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES(1,14,TICK_OLD_VALUE,TICK_NEW_VALUE,USERSTAMP_ID,CT_CUSTOMER_ID);
								END IF;											
								ELSEIF EDFLAG=1 THEN
									IF(TERM_NULL_ENDATE!=TERM_NULL_NRVSTARTDATE) THEN
										IF CLP_UASDIDVAL IS NOT NULL THEN
											IF (SELECT COUNT(*) FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL)>0 THEN
											IF(SELECT COUNT(*) FROM CUSTOMER_LP_DETAILS WHERE CED_REC_VER BETWEEN ACTIVE_RECVER AND TERM_MAX_CUSTRV AND UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID )=1 THEN
											IF(USERSTAMP_ID!=(SELECT ULD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL)) THEN
												SET TICK_ACS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',(SELECT CACD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL),',UASD_ID=',CLP_UASDIDVAL,',ACN_ID=null',',CACD_VALID_FROM=',(SELECT CACD_VALID_FROM FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL),',CACD_VALID_TILL=null',',CACD_GUEST_CARD=',CLP_GSTVAL,',ULD_ID=',(SELECT ULD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL),',CACD_TIMESTAMP=',(SELECT CACD_TIMESTAMP FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL)));
											ELSE
												SET TICK_ACS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',(SELECT CACD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL),',UASD_ID=',CLP_UASDIDVAL,',ACN_ID=null',',CACD_VALID_FROM=',(SELECT CACD_VALID_FROM FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL),',CACD_VALID_TILL=null',',CACD_GUEST_CARD=',CLP_GSTVAL,',CACD_TIMESTAMP=',(SELECT CACD_TIMESTAMP FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL)));
											END IF;	
											SET TICK_NEW_VALUE=(SELECT CONCAT('CACD_VALID_FROM=',TERM_NULL_ENDATE));
											INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES(1,13,TICK_ACS_OLD_VALUE,TICK_NEW_VALUE,USERSTAMP_ID,CT_CUSTOMER_ID);
											UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET CACD_VALID_FROM=TERM_NULL_ENDATE WHERE UASD_ID=CLP_UASDIDVAL AND CUSTOMER_ID=CT_CUSTOMER_ID AND ACN_ID IS NULL;											
											END IF;
											END IF;
										END IF;
										UPDATE CUSTOMER_LP_DETAILS CTD SET CTD.CLP_STARTDATE=TERM_NULL_ENDATE, CTD.ULD_ID=USERSTAMP_ID WHERE CTD.CUSTOMER_ID=CT_CUSTOMER_ID AND CTD.CED_REC_VER=(MIN_RECVER+1);																						
										SET TICK_NEW_VALUE=(SELECT CONCAT('CLP_STARTDATE=',TERM_NULL_ENDATE));
										INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES(1,14,TICK_OLD_VALUE,TICK_NEW_VALUE,USERSTAMP_ID,CT_CUSTOMER_ID);
										SET TERMRESULT_FLAG=1;	
									END IF;
								END IF;
							END IF;
						SET MIN_CTDID=MIN_CTDID+1;
					END WHILE;
						END IF;							
				END IF;
			IF MIN_RECVER=MAX_RECVER THEN
				LEAVE RECVER_LOOP;
			END IF;
			SET MIN_RECVER=MIN_RECVER+1;
			SET EDFLAG=0;
			SET PTDFLAG=0;
		END LOOP;
-- update ptd=null from active rv to input rv -1 end		
	END IF;
END;