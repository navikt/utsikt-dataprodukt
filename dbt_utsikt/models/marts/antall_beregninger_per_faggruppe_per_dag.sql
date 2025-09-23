select
    brg.faggruppe_id,
    faggruppe,
    beregnet_dato,
    count(beregning_id) as antall_beregninger
from {{ ref('stg_db2os__beregninger') }} as brg
left join
    {{ ref('stg_db2os__faggrupper') }} as fag
    on brg.faggruppe_id = fag.faggruppe_id
group by brg.faggruppe_id, faggruppe, beregnet_dato
