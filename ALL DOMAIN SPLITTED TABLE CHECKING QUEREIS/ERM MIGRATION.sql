-- ERM ENTRY DETAILS

-- ERM_CUST_NAME

SELECT DISTINCT  ERM_CUST_NAME FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS;
SELECT DISTINCT ERM_CUST_NAME FROM ERM_ENTRY_DETAILS;
SELECT DISTINCT MERM.ERM_CUST_NAME,ERM.ERM_CUST_NAME FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.ERM_CUST_NAME=ERM.ERM_CUST_NAME
SELECT DISTINCT MERM. ERM_CUST_NAME FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM WHERE NOT EXISTS(SELECT ERM.ERM_CUST_NAME FROM ERM_ENTRY_DETAILS ERM WHERE MERM.ERM_CUST_NAME=ERM.ERM_CUST_NAME)
SELECT DISTINCT * FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM WHERE MERM.ERM_CUST_NAME='RAPHAËL'

-- ERM_RENT

SELECT DISTINCT  MERM.ERM_RENT FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT ERM.ERM_RENT FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.ERM_RENT,ERM.ERM_RENT FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.ERM_RENT=ERM.ERM_RENT

-- ERM_MOVING DATE

SELECT DISTINCT  MERM.ERM_MOVING_DATE FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT ERM.ERM_MOVING_DATE FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.ERM_MOVING_DATE,ERM.ERM_MOVING_DATE FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.ERM_MOVING_DATE=ERM.ERM_MOVING_DATE

-- ERM_MIN_STAY

SELECT DISTINCT  MERM.ERM_MIN_STAY FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT ERM.ERM_MIN_STAY FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.ERM_MIN_STAY,ERM.ERM_MIN_STAY FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.ERM_MIN_STAY=ERM.ERM_MIN_STAY

-- ERMO_ID
SELECT DISTINCT  MERM.ERMO_ID FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT ERM.ERMO_ID FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.ERMO_ID,ERM.ERMO_ID FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.ERMO_ID=ERM.ERMO_ID

-- NC_SNO
SELECT DISTINCT  MERM.NC_SNO FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT ERM.NC_ID FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.NC_SNO,ERM.NC_ID FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.NC_SNO=ERM.NC_ID

-- ERM_NO_OF_GUESTS
SELECT DISTINCT MERM.ERM_NO_OF_GUESTS FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT ERM.ERM_NO_OF_GUESTS FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.ERM_NO_OF_GUESTS,ERM.ERM_NO_OF_GUESTS FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.ERM_NO_OF_GUESTS=ERM.ERM_NO_OF_GUESTS

-- ERM_AGE
SELECT DISTINCT MERM.ERM_AGE FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT ERM.ERM_AGE FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.ERM_AGE,ERM.ERM_AGE FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.ERM_AGE=ERM.ERM_AGE

-- ERM_CONTACT NO
SELECT DISTINCT MERM.ERM_CONTACT_NO FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT ERM.ERM_CONTACT_NO FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.ERM_CONTACT_NO,ERM.ERM_CONTACT_NO FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.ERM_CONTACT_NO=ERM.ERM_CONTACT_NO

-- ERM_MAIL_ID
SELECT DISTINCT MERM.ERM_EMAIL_ID FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT ERM.ERM_EMAIL_ID FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.ERM_EMAIL_ID,ERM.ERM_EMAIL_ID FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.ERM_EMAIL_ID=ERM.ERM_EMAIL_ID

-- ERM_COMMENTS
SELECT DISTINCT MERM.ERM_COMMENTS FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT ERM.ERM_COMMENTS FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.ERM_COMMENTS,ERM.ERM_COMMENTS FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.ERM_COMMENTS=ERM.ERM_COMMENTS

-- ERM_TIMESTAMP
SELECT DISTINCT MERM.ERM_TIMESTAMP FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT ERM.ERM_TIMESTAMP FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.ERM_TIMESTAMP,ERM.ERM_TIMESTAMP FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM,ERM_ENTRY_DETAILS ERM WHERE MERM.ERM_TIMESTAMP=ERM.ERM_TIMESTAMP 

-- ULDID
SELECT DISTINCT ERM.ULD_ID FROM ERM_ENTRY_DETAILS ERM;
SELECT DISTINCT MERM.ERM_USERSTAMP FROM SOURCE_04062014.MIG_ERM_ENTRY_DETAILS MERM;
SELECT DISTINCT A.ERM_USERSTAMP,B.ULD_LOGINID,B.ULD_ID,C.ULD_ID FROM
SOURCE_04062014.MIG_ERM_ENTRY_DETAILS A INNER JOIN
USER_LOGIN_DETAILS B  ON A.ERM_USERSTAMP=B.ULD_LOGINID INNER JOIN
ERM_ENTRY_DETAILS C ON B.ULD_ID=C.ULD_ID;

-- ERM OCCUPATION DETAILS

-- ERM_DATA
SELECT DISTINCT ERMO_DATA FROM SOURCE_04062014.MIG_ERM_OCCUPATION_DETAILS;
SELECT DISTINCT ERMO_DATA FROM ERM_OCCUPATION_DETAILS;
SELECT DISTINCT MEOD.ERMO_DATA,EOD.ERMO_DATA FROM SOURCE_04062014.MIG_ERM_OCCUPATION_DETAILS MEOD,ERM_OCCUPATION_DETAILS EOD WHERE MEOD.ERMO_DATA=EOD.ERMO_DATA

-- ULD_ID
SELECT DISTINCT EOD.ULD_ID FROM ERM_OCCUPATION_DETAILS EOD;
SELECT DISTINCT MEOD.ERMO_USERSTAMP FROM SOURCE_04062014.MIG_ERM_OCCUPATION_DETAILS MEOD;
SELECT DISTINCT A.ERMO_USERSTAMP,B.ULD_LOGINID,B.ULD_ID,C.ULD_ID FROM
SOURCE_04062014.MIG_ERM_OCCUPATION_DETAILS A INNER JOIN
USER_LOGIN_DETAILS B  ON A.ERMO_USERSTAMP=B.ULD_LOGINID INNER JOIN
ERM_ENTRY_DETAILS C ON B.ULD_ID=C.ULD_ID;

-- TIMESTAMP
SELECT DISTINCT EOD.ERMO_TIMESTAMP FROM ERM_OCCUPATION_DETAILS EOD;
SELECT DISTINCT MEOD.ERMO_TIMESTAMP FROM SOURCE_04062014.MIG_ERM_OCCUPATION_DETAILS MEOD;

