select
    brg.faggruppe_kode,
    faggruppe_navn,
    beregnet_dato,
    count(beregning_id) as antall_beregninger
from {{ ref('stg_db2os__beregninger') }} as brg
left join
    {{ ref('stg_db2os__faggrupper') }} as fag
    on brg.faggruppe_kode = fag.faggruppe_kode
group by brg.faggruppe_kode, faggruppe_navn, beregnet_dato
