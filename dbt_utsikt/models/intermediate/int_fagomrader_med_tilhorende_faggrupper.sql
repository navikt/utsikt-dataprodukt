-- int_fagomrader_med_tilhorende_faggrupper
select
    fagomrade_id,
    fagomrade,
    omr.faggruppe_id,
    faggruppe
from {{ ref('stg_db2os__fagomrader') }} as omr
left join
    {{ ref('stg_db2os__faggrupper') }} as grp
    on omr.faggruppe_id = grp.faggruppe_id
