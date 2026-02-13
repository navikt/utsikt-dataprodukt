--agg_belop_per_fagomrade_maned
with

ref_fak_stoppnivaer as (
    select
        fagomrade_navn,
        faggruppe_navn,
        belop_brutto,
        lastet_tid_kilde
    from {{ ref('fak_stoppnivaer') }}
),

beregne_belop as (
    select
        fagomrade_navn,
        faggruppe_navn,
        date_trunc(lastet_tid_kilde, month) as forste_i_maned,
        sum(belop_brutto) as belop_brutto
    from ref_fak_stoppnivaer
    group by fagomrade_navn, faggruppe_navn, forste_i_maned
),

final as (
    select
        fagomrade_navn,
        faggruppe_navn,
        forste_i_maned,
        belop_brutto
    from beregne_belop
)

select * from final
