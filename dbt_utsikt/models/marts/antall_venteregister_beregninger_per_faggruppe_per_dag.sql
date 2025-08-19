select
count(beregning_id) antall_beregninger
,brg.faggruppe_id
,faggruppe
,beregnet_dato
from  {{ ref('stg_db2os__venteregister_beregninger') }} brg
left join {{ ref('stg_db2os__faggrupper') }} fag on brg.faggruppe_id = fag.faggruppe_id
group by brg.faggruppe_id, faggruppe, beregnet_dato