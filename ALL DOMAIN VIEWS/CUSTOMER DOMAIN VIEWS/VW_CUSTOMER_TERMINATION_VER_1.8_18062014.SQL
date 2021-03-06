--VER 1.8 STARTDATE:18/06/2014 ENDDATE:18/06/2014 ISSUENO:345 CCOMMENT NO:#714 DESC:CHANGED TEMP VIEW NAME AS SUB BY SASIKALA
--VER 1.7 STARTDATE:22/04/2014 ENDDATE:22/04/2014 ISSUENO:345 DESC:FILETERED CANCEL DATE CUSTOMER IN NON TERMINATION CUSTOMER SP BY PUNI
--VER 1.6 STARTDATE:03/04/2014 ENDDATE:03/04/2014 ISSUENO:797 COMMENTNO:#4 DESC:REPLACED HEADER ND TABLE NAME DONE BY:LALITHA
-- version:1.5 --startdate:02/01/2014 --enddate:06/01/2014 --issue:345 --changed the whole SP_NON_TERMINATED_CUSTOMER sp n TERMINATED_CUSTOMER view based on from comment #551 --by PUNI
-->VER 1.4 --ISSUE NO:345 COMMENTNO:#487 START DATE:10/12/2013 ENDDATE:10/12/2013 DESC:ADDED UNIT_NO,START_DATE,PRETERMINATEDATE,RECVER,ENDDATE COLUMN IN ACTIVE CUSTOMER VIEW  SP DONE BY:DHIVYA.A
-->VER 1.3 --START DATE:12/11/2013 ENDDATE:12/11/2013 DESC:CHANGED TEMP_ACTIVE TABLE CHANGED AS VW_TEMP_TERMINATION_ACTIVE_CUSTOMER BY RL
-->VER 1.2--->ISSUE NO:636 COMMENT NO:#47 START DATE:10/11/2013 ENDDATE:10/11/2013 DESC:CHANGED VIEW NAME BY RL
-->VER 1.1--->ISSUE NO:345 START DATE:04/11/2013 ENDDATE:04/11/2013 COMMENT NO:#307 DESC:UPDATED SYSDATE() AS CURDATE()  done by:DHIVYA.A
-->VER 1.0--->ISSUE NO:345 START DATE:28/10/2013 ENDDATE:28/10/2013 COMMENT NO:#263 DESC:ADDED CANCEL_DATE IS NULL CONDITION IN ACTIVE AND NON TERMINATED CUSTOMERS  done by;DHIVYA.A
-->VER 0.10--->ISSUE NO:646 START DATE:24/10/2013 ENDDATE:24/10/2013 DESC:GUEST CARD IS FILTERED IN TEMP_ACTIVE VIEW done by;DHIVYA.A
-->VER 0.9--->ISSUE NO:345 COMMENT NO:#236 START DATE:23/10/2013 ENDDATE:23/10/2013 DESC:changed active customer,terminated customer view variable name CUSTOMER_ID as CUSTOMERID done by;DHIVYA.A
-->VER 0.8--->ISSUE NO:345 COMMENT NO:#219 START DATE:22/10/2013 ENDDATE:23/10/2013 DESC:changed active customer,terminated customer view names and added procedure for nonterminated customers and updated queries as per comment #222 and #223 done by;DHIVYA.A
-->VER 0.7--->ISSUE NO:345 COMMENT NO:#173 START DATE:18/10/2013 ENDDATE:19/10/2013 DESC:updated views for terminated customers,active customers and non_terminated_customers BY:DHIVYA.A
-->VER 0.6--->ISSUE NO:345 COMMENT NO:#173 START DATE:08/10/2013 ENDDATE:08/10/2013 DESC:updated views for terminated customers and created view for  uncancel_customers BY:DHIVYA.A
-->VER 0.5--->ISSUE NO:345 COMMENT NO:#162 START DATE:04/10/2013 ENDDATE:04/10/2013 DESC:updated views for active customers,terminated customers and created view for non_terminated customers BY:DHIVYA.A
-->version 0.4 -->issueno:589 --->desc:created temporary views TEMP_CUSTOMER and TEMP_CUSTOMER_TERMINATE for getting active and non_active customers done by:Dhivya.A
-->version 0.3 -->startdate:02/08/2013 enddate:05/08/2013 -->issueno:322  -->commentno:17 -->desc:added ALL_CANCEL_CUSTOMERS views & CURRENT MONTH CUSTOMER EXPIRY LIST views done by:Dhivya.A
-->version 0.2 -->issue no:563 -->desc:changed view name -->done by:rajalakshmi.r
-->version 0.1 -->Issue tracker-No:347 -->Created on 07.05.2013 -->Completed by S.GopiKrishnan -->enddate:09.05.2013.


--Temporary view for customer and its max recver
CREATE OR REPLACE VIEW VW_SUB_CUSTOMER AS SELECT C1.CUSTOMER_ID AS CUSTOMERID,MAX(C1.CED_REC_VER) AS REC_VER FROM CUSTOMER_LP_DETAILS C1 WHERE C1.CLP_GUEST_CARD IS NULL AND IF(C1.CLP_PRETERMINATE_DATE IS NOT NULL,C1.CLP_STARTDATE<C1.CLP_PRETERMINATE_DATE,C1.CLP_STARTDATE) GROUP BY C1.CUSTOMER_ID;
--Temp view for Terminated customer
CREATE OR REPLACE VIEW VW_SUB_TERMINATED_CUSTOMER AS
SELECT C1.CUSTOMERID,C.UASD_ID,C.CLP_TERMINATE,C1.REC_VER,CED.CED_CANCEL_DATE FROM CUSTOMER_LP_DETAILS C,VW_SUB_CUSTOMER C1 ,CUSTOMER_ENTRY_DETAILS CED WHERE C.CED_REC_VER=C1.REC_VER AND CED.CED_REC_VER=C1.REC_VER AND CED.CUSTOMER_ID=C1.CUSTOMERID AND C.CUSTOMER_ID=C1.CUSTOMERID AND C.CLP_TERMINATE IS NOT NULL AND C.CLP_GUEST_CARD IS NULL GROUP BY C.CUSTOMER_ID;

-- view for TERMINATED_CUSTOMER
CREATE OR REPLACE VIEW VW_TERMINATION_TERMINATED_CUSTOMER AS
SELECT CUSTOMER_ID AS CUSTOMERID,CONCAT(CUSTOMER_FIRST_NAME,'_',CUSTOMER_LAST_NAME)AS CUSTOMERNAME 
FROM CUSTOMER WHERE CUSTOMER_ID IN
(SELECT CUSTOMERID FROM VW_SUB_TERMINATED_CUSTOMER WHERE CLP_TERMINATE IS NOT NULL AND CED_CANCEL_DATE IS NULL  GROUP BY CUSTOMERID);

--Temporary view for filtering all TERMINATED CUSTOMER
CREATE OR REPLACE VIEW VW_SUB_TERMINATION_ACTIVE_CUSTOMER AS
SELECT C.CUSTOMER_ID AS CUSTOMERID,MAX(C.CED_REC_VER)AS RECVER
FROM CUSTOMER_LP_DETAILS C
LEFT JOIN VW_TERMINATION_TERMINATED_CUSTOMER T ON C.CUSTOMER_ID = T.CUSTOMERID
WHERE T.CUSTOMERID IS NULL AND C.CLP_TERMINATE IS NULL AND IF(C.CLP_PRETERMINATE_DATE IS NOT NULL,C.CLP_STARTDATE<C.CLP_PRETERMINATE_DATE,C.CLP_STARTDATE)AND C.CLP_GUEST_CARD IS NULL GROUP BY C.CUSTOMER_ID;

--VIEW FOR ACTIVE CUSTOMER
CREATE OR REPLACE VIEW VW_TERMINATION_ACTIVE_CUSTOMER AS
SELECT C1.CUSTOMER_ID AS CUSTOMERID,CONCAT(CUSTOMER_FIRST_NAME,'_',CUSTOMER_LAST_NAME)AS CUSTOMERNAME,C.CED_REC_VER,C.CLP_STARTDATE,C.CLP_ENDDATE,C.CLP_PRETERMINATE_DATE,U.UNIT_NO  
FROM UNIT U,CUSTOMER C1,CUSTOMER_LP_DETAILS C,CUSTOMER_ENTRY_DETAILS C2,VW_SUB_TERMINATION_ACTIVE_CUSTOMER T WHERE C.CUSTOMER_ID = T.CUSTOMERID
AND C.CLP_TERMINATE IS NULL AND U.UNIT_ID=C2.UNIT_ID AND C.UASD_ID IS NOT NULL AND C.CLP_STARTDATE<=CURDATE() AND if (C.CLP_PRETERMINATE_DATE IS NOT NULL ,C.CLP_PRETERMINATE_DATE>CURDATE(),C.CLP_ENDDATE>CURDATE())AND C.CUSTOMER_ID=C1.CUSTOMER_ID AND
C1.CUSTOMER_ID=T.CUSTOMERID  AND C.CLP_GUEST_CARD IS NULL AND C.CUSTOMER_ID=C2.CUSTOMER_ID AND C2.CED_CANCEL_DATE IS NULL AND C.CED_REC_VER=C2.CED_REC_VER AND T.CUSTOMERID=C2.CUSTOMER_ID GROUP BY C.CUSTOMER_ID;




