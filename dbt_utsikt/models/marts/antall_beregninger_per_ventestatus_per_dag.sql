with distinkte_beregninger_per_ventestatus as (
    select distinct
        ventestatus_id,
        (beregning_id)
    from {{ ref('stg_db2os__stoppstatuser') }}
)

select
    ventestatus,
    sts.ventestatus_id,
    beregnet_dato,
    count(sts.beregning_id) as antall_beregninger,
    case
        when handteres_manuelt = 1 then 'Håndteres manuelt'
        else 'Ingen manuell håndtering'
    end as handteres_manuelt
from distinkte_beregninger_per_ventestatus as sts
left join
    {{ ref('int_statuskoder_manuell_handtering') }} as stk
    on sts.ventestatus_id = stk.ventestatus_id
left join
    {{ ref('stg_db2os__beregninger') }} as ber
    on sts.beregning_id = ber.beregning_id
group by ventestatus, sts.ventestatus_id, handteres_manuelt, beregnet_dato
