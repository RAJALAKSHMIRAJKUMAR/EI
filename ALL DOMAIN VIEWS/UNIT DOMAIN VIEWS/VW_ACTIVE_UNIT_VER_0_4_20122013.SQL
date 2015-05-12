--version 0.4 --sdate:20/12/2013 --edate:20/12/2013 --issue:346 --comment:174 --desc:add new conditionEND DATE>SYSDATE and add UD_NON_EI flag by rl
--version 0.3 --sdate:11/11/2013 --edate:11/11/2013 --issue:636 --comment:47 --desc:changed view name by rl
-->version 0.2 -->createdby:rajalakshmi -->date:2013-07-18 -->issue:563
-->version 0.1 -->createdby:loganathan -->date:2013-05-10 -->issue:346
 --------------------------------- VIEWS FOR ALL ACTIVE UNIT ---------------------------------------
CREATE OR REPLACE VIEW VW_ACTIVE_UNIT
AS 
SELECT U.UNIT_ID,U.UNIT_NO,UD.UD_NON_EI 
FROM UNIT U,UNIT_DETAILS UD
WHERE U.UNIT_ID=UD.UNIT_ID AND UD.UD_OBSOLETE IS NULL AND UD.UD_END_DATE > CURDATE();