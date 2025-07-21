with distinkte_beregninger_per_ventestatus as (
select
distinct(beregning_id)
,ventestatus_id
from {{ ref('stg_db2os__venteregister_stoppstatuser') }} sts
)

select
count(sts.beregning_id) antall_beregninger
,ventestatus
,sts.ventestatus_id
,ma_handteres_manuelt
,extract(month from ber.beregnet_dato) as maned
,extract(year from ber.beregnet_dato) as ar
from distinkte_beregninger_per_ventestatus sts
left join {{ ref('int_venteregister_statuskoder_manuell_handtering') }} stk on sts.ventestatus_id = stk.ventestatus_id
left join {{ ref('stg_db2os__venteregister_beregninger') }} ber on sts.beregning_id = ber.beregning_id
group by ventestatus, sts.ventestatus_id, ma_handteres_manuelt, maned, ar