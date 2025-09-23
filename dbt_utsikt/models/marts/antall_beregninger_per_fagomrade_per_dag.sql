with dist_beregning_fagomrade as (
    select distinct
        beregning_id,
        fagomrade_kode
    from {{ ref('stg_db2os__stoppnivaer') }}
    group by beregning_id, fagomrade_kode
),

beregning_id_per_fagomrade_per_beregnet_dato as (
    select
        stpn.beregning_id,
        fagomrade_navn,
        faggruppe_navn,
        beregnet_dato
    from dist_beregning_fagomrade as stpn
    left join
        {{ ref('int_fagomrader_med_tilhorende_faggrupper') }} as fag
        on stpn.fagomrade_kode = fag.fagomrade_kode
    left join
        {{ ref('stg_db2os__beregninger') }} as brg
        on stpn.beregning_id = brg.beregning_id
)

select
    fagomrade_navn,
    faggruppe_navn,
    beregnet_dato,
    count(beregning_id) as antall_beregninger
from beregning_id_per_fagomrade_per_beregnet_dato
group by fagomrade_navn, faggruppe_navn, beregnet_dato

--legg merke til at en beregning_id kan tilhøre flere fagomrader, så en beregning kan telle i flere antall_beregninger per fagområde per dag
