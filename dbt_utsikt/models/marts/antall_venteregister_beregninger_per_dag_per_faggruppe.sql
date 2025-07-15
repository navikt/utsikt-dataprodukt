with dist_beregning_fagomrade as (
select 
distinct beregning_id
,fagomrade_id
from {{ ref('stg_db2os__venteregister_stoppniva') }}
group by beregning_id, fagomrade_id
),

beregning_id_per_fagomrade_per_beregnet_dato as (
select
stpn.beregning_id
,fagomrade
,beregnet_dato
from dist_beregning_fagomrade as stpn 
left join {{ ref('int_fagomrader_med_tilhorende_faggrupper') }} fag on stpn.fagomrade_id = fag.fagomrade_id
left join {{ ref('stg_db2os__venteregister_beregninger') }} brg on brg.beregning_id = stpn.beregning_id
)

select
count(beregning_id) antall_beregninger
,fagomrade
,beregnet_dato
from beregning_id_per_fagomrade_per_beregnet_dato
group by fagomrade, beregnet_dato

--legg merke til at en beregning_id kan tilhøre flere fagomrader, så en beregning kan telle i flere antall_beregninger per fagområde per dag
