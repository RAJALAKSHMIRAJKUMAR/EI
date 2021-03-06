--VER 0.7 STARTDATE:18/06/2014 ENDDATE:18/06/2014 ISSUENO:345 COMMENTNO:#714 DESC:CHANGED TEMP VIEW NAME AS SUB DONE BY:SASIKALA
--VER 0.6 STARTDATE:03/04/2014 ENDDATE:03/04/2014 ISSUENO:797 COMMENTNO:#4 DESC:REPLACED HEADER ND TABLE NAME DONE BY:LALITHA
-->VER 0.5--->ISSUE NO:345 COMMENT NO:#436 START DATE:27/11/2013 ENDDATE:27/11/2013 DESC:added recversion header in VW_RECHECKIN_CUSTOMER
-->VER 0.4--->ISSUE NO:636 COMMENT NO:#47 START DATE:10/11/2013 ENDDATE:10/11/2013 DESC:CHANGED VIEW NAME BY RL
-->VERSION 0.3 ISSUE NO:345 START DATE:04/11/2013 ENDDATE:04/11/2013 COMMENT NO:#307 DESC:UPDATED SYSDATE() AS CURDATE()  done by:DHIVYA.A
--VERSION 0.2 ISSUE NO:345 STARTDATE:29/10/2013 ENDDATE:29/10/2013 ISSUE NO:345 COMMENT NO:#276 DESC:added alias name for customer first name and last name DONE BY:DHIVYA.A
--VER 0.1 ISSUE NO:345 COMMENT NO:#227 START DATE:23/10/2013 END DATE:24/10/2013 DESC:VIEW FOR EXTENSION CUSTOMER DONE BY:DHIVYA.A

--TEMPORARY VIEW FOR GETTING MAXIMUM RECORD VERSION
CREATE OR REPLACE VIEW VW_SUB_RECHECKIN_CUSTOMER AS 
SELECT CUSTOMER_ID,MAX(CED_REC_VER) AS RECVER FROM CUSTOMER_LP_DETAILS WHERE CLP_GUEST_CARD IS NULL AND IF(CLP_PRETERMINATE_DATE IS NOT NULL,CLP_STARTDATE<CLP_PRETERMINATE_DATE,CLP_STARTDATE )GROUP BY CUSTOMER_ID;

--TEMPORARY VIEW FOR GETTING CUSTOMERID,RECVER,CLP_TERMINATE,CANCELDATE AND UNITID
CREATE OR REPLACE VIEW VW_SUB_RECHECKIN_TERMINATE_CUSTOMER AS
SELECT CTD.CUSTOMER_ID,CTD.CED_REC_VER,CTD.CLP_TERMINATE,CTD.CLP_STARTDATE,CTD.CLP_ENDDATE,CED.CED_CANCEL_DATE,CED.UNIT_ID FROM
CUSTOMER_LP_DETAILS CTD,CUSTOMER_ENTRY_DETAILS CED,VW_SUB_RECHECKIN_CUSTOMER T
WHERE CTD.CUSTOMER_ID=CED.CUSTOMER_ID AND CTD.CUSTOMER_ID=T.CUSTOMER_ID AND CED.CUSTOMER_ID=T.CUSTOMER_ID 
AND CTD.CED_REC_VER=CED.CED_REC_VER AND T.RECVER=CED.CED_REC_VER
AND T.RECVER=CTD.CED_REC_VER AND CTD.CLP_GUEST_CARD IS NULL GROUP BY CTD.CUSTOMER_ID;

--VIEWS FOR RECHECKIN CUSTOMER
CREATE OR REPLACE VIEW VW_RECHECKIN_CUSTOMER AS
SELECT U.UNIT_ID,U.UNIT_NO,C.CUSTOMER_ID,T.CED_REC_VER,CONCAT(C.CUSTOMER_FIRST_NAME,'_',C.CUSTOMER_LAST_NAME)AS CUSTOMERNAME FROM
UNIT U,CUSTOMER C,VW_SUB_RECHECKIN_TERMINATE_CUSTOMER T WHERE U.UNIT_ID=T.UNIT_ID AND C.CUSTOMER_ID=T.CUSTOMER_ID AND 
((T.CLP_TERMINATE IS NOT NULL)OR(T.CLP_STARTDATE<CURDATE()AND T.CED_CANCEL_DATE IS NOT NULL));