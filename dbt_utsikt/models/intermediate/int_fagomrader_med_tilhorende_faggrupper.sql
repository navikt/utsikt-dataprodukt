select 
fagomrade_id
,fagomrade
,omr.faggruppe_id
,faggruppe
from {{ ref('stg_db2os__fagomrader') }} omr
left join {{ ref('stg_db2os__faggrupper') }} grp on grp.faggruppe_id = omr.faggruppe_id