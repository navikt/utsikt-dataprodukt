--antall_beregninger_per_fagomrade_per_dag

with

ref_stg_db2os__stoppnivaer as (
    select
        beregning_id,
        fagomrade_kode
    from {{ ref('stg_db2os__stoppnivaer') }}
),

ref_int_fagomrader_med_tilhorende_faggrupper as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn
    from {{ ref('int_fagomrader_med_tilhorende_faggrupper') }}
),

ref_stg_db2os__beregninger as (
    select
        beregning_id,
        beregnet_dato
    from {{ ref('stg_db2os__beregninger') }}
),

dist_beregning_fagomrade as (
    select distinct
        beregning_id,
        fagomrade_kode
    from ref_stg_db2os__stoppnivaer
),

beregning_id_per_fagomrade_per_beregnet_dato as (
    select
        dist_beregning_fagomrade.beregning_id,
        ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_navn,
        ref_int_fagomrader_med_tilhorende_faggrupper.faggruppe_navn,
        ref_stg_db2os__beregninger.beregnet_dato
    from dist_beregning_fagomrade
    left join
        ref_int_fagomrader_med_tilhorende_faggrupper
        on
            dist_beregning_fagomrade.fagomrade_kode
            = ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_kode
    left join
        ref_stg_db2os__beregninger
        on
            dist_beregning_fagomrade.beregning_id
            = ref_stg_db2os__beregninger.beregning_id
),

final as (
    select
        fagomrade_navn,
        faggruppe_navn,
        beregnet_dato,
        count(beregning_id) as antall_beregninger
    from beregning_id_per_fagomrade_per_beregnet_dato
    group by fagomrade_navn, faggruppe_navn, beregnet_dato
)

select * from final


--legg merke til at en beregning_id kan tilhøre flere fagomrader, 
--så en beregning kan telle i flere antall_beregninger per fagområde per dag
