DROP PROCEDURE IF EXISTS SP_ALL_DOMIAN_VIEWS_PART2;
CREATE PROCEDURE SP_ALL_DOMIAN_VIEWS_PART2()
BEGIN
CREATE OR REPLACE VIEW VW_SUB_CUSTOMER AS SELECT C1.CUSTOMER_ID AS CUSTOMERID,MAX(C1.CED_REC_VER) AS REC_VER FROM CUSTOMER_LP_DETAILS C1 WHERE C1.CLP_GUEST_CARD IS NULL AND IF(C1.CLP_PRETERMINATE_DATE IS NOT NULL,C1.CLP_STARTDATE<C1.CLP_PRETERMINATE_DATE,C1.CLP_STARTDATE) GROUP BY C1.CUSTOMER_ID;
CREATE OR REPLACE VIEW VW_SUB_TERMINATED_CUSTOMER AS
SELECT C1.CUSTOMERID,C.UASD_ID,C.CLP_TERMINATE,C1.REC_VER,CED.CED_CANCEL_DATE FROM CUSTOMER_LP_DETAILS C,VW_SUB_CUSTOMER C1 ,CUSTOMER_ENTRY_DETAILS CED WHERE C.CED_REC_VER=C1.REC_VER AND CED.CED_REC_VER=C1.REC_VER AND CED.CUSTOMER_ID=C1.CUSTOMERID AND C.CUSTOMER_ID=C1.CUSTOMERID AND C.CLP_TERMINATE IS NOT NULL AND C.CLP_GUEST_CARD IS NULL GROUP BY C.CUSTOMER_ID;
CREATE OR REPLACE VIEW VW_TERMINATION_TERMINATED_CUSTOMER AS SELECT CUSTOMER_ID AS CUSTOMERID,CONCAT(CUSTOMER_FIRST_NAME,'_',CUSTOMER_LAST_NAME)AS CUSTOMERNAME 
FROM CUSTOMER WHERE CUSTOMER_ID IN (SELECT CUSTOMERID FROM VW_SUB_TERMINATED_CUSTOMER WHERE CLP_TERMINATE IS NOT NULL AND CED_CANCEL_DATE IS NULL  GROUP BY CUSTOMERID);
CREATE OR REPLACE VIEW VW_SUB_TERMINATION_ACTIVE_CUSTOMER AS
SELECT C.CUSTOMER_ID AS CUSTOMERID,MAX(C.CED_REC_VER)AS RECVER
FROM CUSTOMER_LP_DETAILS C
LEFT JOIN VW_TERMINATION_TERMINATED_CUSTOMER T ON C.CUSTOMER_ID = T.CUSTOMERID
WHERE T.CUSTOMERID IS NULL AND C.CLP_TERMINATE IS NULL AND IF(C.CLP_PRETERMINATE_DATE IS NOT NULL,C.CLP_STARTDATE<C.CLP_PRETERMINATE_DATE,C.CLP_STARTDATE)AND C.CLP_GUEST_CARD IS NULL GROUP BY C.CUSTOMER_ID;
CREATE OR REPLACE VIEW VW_TERMINATION_ACTIVE_CUSTOMER AS
SELECT C1.CUSTOMER_ID AS CUSTOMERID,CONCAT(CUSTOMER_FIRST_NAME,'_',CUSTOMER_LAST_NAME)AS CUSTOMERNAME,C.CED_REC_VER,C.CLP_STARTDATE,C.CLP_ENDDATE,C.CLP_PRETERMINATE_DATE,U.UNIT_NO  
FROM UNIT U,CUSTOMER C1,CUSTOMER_LP_DETAILS C,CUSTOMER_ENTRY_DETAILS C2,VW_SUB_TERMINATION_ACTIVE_CUSTOMER T WHERE C.CUSTOMER_ID = T.CUSTOMERID
AND C.CLP_TERMINATE IS NULL AND U.UNIT_ID=C2.UNIT_ID AND C.CLP_STARTDATE<=CURDATE() AND if (C.CLP_PRETERMINATE_DATE IS NOT NULL ,C.CLP_PRETERMINATE_DATE>CURDATE(),C.CLP_ENDDATE>CURDATE())AND C.CUSTOMER_ID=C1.CUSTOMER_ID AND
C1.CUSTOMER_ID=T.CUSTOMERID  AND C.CLP_GUEST_CARD IS NULL AND C.CUSTOMER_ID=C2.CUSTOMER_ID AND C2.CED_CANCEL_DATE IS NULL AND C.CED_REC_VER=C2.CED_REC_VER AND T.CUSTOMERID=C2.CUSTOMER_ID GROUP BY C.CUSTOMER_ID;
END;
CALL SP_ALL_DOMIAN_VIEWS_PART2();