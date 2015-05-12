--version 0.4 --sdate:11/11/2013 --edate:11/11/2013 --issue:636 --comment:47 --desc:changed view name by rl
-->version 0.3 -->date:02/08/2013 enddate:02/08/2013 -->issueno:322  -->commentno:17 -->desc:DAMAGED_SPOILED_CARD VIEW (UASD_SNO IS CHANGED AS UASD_ID)done by Dhivya.A
-->version 0.2 -->createdby:rajalakshmi -->date:2013-07-18 -->issue:563
-->version 0.1 -->createdby:loganathan -->date:2013-05-10 -->issue:346
-------------------------------- VIEWS FOR ALL DAMAGED/SPOILED CARDS ------------------------------
CREATE OR REPLACE VIEW VW_DAMAGED_SPOILED_CARD
AS
SELECT UASD_ID,UASD_ACCESS_CARD
FROM UNIT_ACCESS_STAMP_DETAILS
WHERE
UASD_ACCESS_LOST = 'X'
