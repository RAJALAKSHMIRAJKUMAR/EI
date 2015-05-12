--version 0.3 --sdate:11/11/2013 --edate:11/11/2013 --issue:636 --comment:47 --desc:changed view name by rl
-->version 0.2 -->createdby:rajalakshmi -->date:2013-07-18 -->issue:563
-->version 0.1 -->createdby:loganathan -->date:2013-05-10 -->issue:346
--------------------------------- VIEWS FOR ALL NON ACTIVE UNIT ---------------------------------------
CREATE OR REPLACE VIEW VW_NON_ACTIVE_UNIT 
AS 
SELECT UNIT_ID,UNIT_NO 
FROM UNIT 
WHERE UNIT_ID 
IN 
(SELECT UNIT_ID FROM UNIT_DETAILS WHERE UD_OBSOLETE IS NOT NULL)