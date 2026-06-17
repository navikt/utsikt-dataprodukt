--agg_beregninger_p4_per_fagomrade_ytelse_dag
with

ref_fak_stoppnivaer as (
    select
        beregning_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        beregnet_dato
    from {{ ref('fak_stoppnivaer') }}
    where faggruppe_navn in ('Arbeidsytelser', 'Arbeidsytelser tilleggsstønad og tiltakspenger', 'Tilleggsstønader')

),

ref_int_fagomrader_med_tilhorende_faggrupper as (
    select
        fagomrade_kode,
        ytelse
    from {{ ref('int_fagomrader_med_tilhorende_faggrupper') }}
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

join_ytelse as (
    select
        dist_beregning_fagomrade.beregning_id,
        dist_beregning_fagomrade.fagomrade_kode,
        dist_beregning_fagomrade.faggruppe_navn,
        dist_beregning_fagomrade.fagomrade_navn,
        dist_beregning_fagomrade.beregnet_dato,
        ref_int_fagomrader_med_tilhorende_faggrupper.ytelse
    from dist_beregning_fagomrade
    left join
        ref_int_fagomrader_med_tilhorende_faggrupper
        on dist_beregning_fagomrade.fagomrade_kode = ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_kode
),

final as (
    select
        fagomrade_navn,
        fagomrade_kode,
        faggruppe_navn,
        beregnet_dato,
        ytelse,
        count(beregning_id) as antall_beregninger
    from join_ytelse
    group by fagomrade_navn, fagomrade_kode, faggruppe_navn, beregnet_dato, ytelse
)

select * from final
