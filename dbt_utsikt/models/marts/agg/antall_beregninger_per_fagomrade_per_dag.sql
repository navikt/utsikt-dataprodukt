--antall_beregninger_per_fagomrade_per_dag

with

ref_fak_stoppnivaer as (
    select
        beregning_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        beregnet_dato
    from {{ ref('fak_stoppnivaer') }}
),

dist_beregning_fagomrade as (
    select distinct
        beregning_id,
        fagomrade_kode,
        faggruppe_navn,
        fagomrade_navn,
        beregnet_dato
    from ref_fak_stoppnivaer
),

final as (
    select
        fagomrade_navn,
        faggruppe_navn,
        beregnet_dato,
        count(beregning_id) as antall_beregninger
    from dist_beregning_fagomrade
    group by fagomrade_navn, faggruppe_navn, beregnet_dato
)

select * from final


--legg merke til at en beregning_id kan tilhøre flere fagomrader, 
--så en beregning kan telle i flere antall_beregninger per fagområde per dag
