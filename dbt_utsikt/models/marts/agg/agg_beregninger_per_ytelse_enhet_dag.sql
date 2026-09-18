--agg_beregninger_p4_per_fagomrade_ytelse_dag
with

ref_fak_stoppnivaer as (
    select
        beregning_id,
        fagomrade_kode,
        fagomrade_navn,
        enhet_behandler,
        faggruppe_navn,
        lastet_tid_kilde
    from {{ ref('fak_stoppnivaer') }}
),

ref_int_fagomrader_med_tilhorende_faggrupper as (
    select
        fagomrade_kode,
        ytelse
    from {{ ref('int_fagomrader_med_tilhorende_faggrupper') }}
),

derive_enhet_behandler as (
    select
        beregning_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        case
            when enhet_behandler = '8020' then 'NØS'
            when enhet_behandler = '4819' then 'NØP'
            else 'Annet'
        end as enhet_behandler,
        date(lastet_tid_kilde) as lastet_dato_kilde
    from ref_fak_stoppnivaer
),


dist_beregning_fagomrade as (
    select distinct
        beregning_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        enhet_behandler,
        lastet_dato_kilde
    from derive_enhet_behandler
),

join_ytelse as (
    select
        dist_beregning_fagomrade.beregning_id,
        dist_beregning_fagomrade.fagomrade_kode,
        dist_beregning_fagomrade.fagomrade_navn,
        dist_beregning_fagomrade.faggruppe_navn,
        dist_beregning_fagomrade.enhet_behandler,
        dist_beregning_fagomrade.lastet_dato_kilde,
        ref_int_fagomrader_med_tilhorende_faggrupper.ytelse
    from dist_beregning_fagomrade
    left join
        ref_int_fagomrader_med_tilhorende_faggrupper
        on dist_beregning_fagomrade.fagomrade_kode = ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_kode
),

count_beregninger as (
    select
        fagomrade_kode,
        fagomrade_navn,
        enhet_behandler,
        faggruppe_navn,
        lastet_dato_kilde,
        ytelse,
        count(beregning_id) as antall_beregninger
    from join_ytelse
    group by enhet_behandler, fagomrade_kode, fagomrade_navn, faggruppe_navn, lastet_dato_kilde, ytelse
),

final as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        ytelse,
        enhet_behandler,
        lastet_dato_kilde,
        antall_beregninger
    from count_beregninger
)

select * from final
