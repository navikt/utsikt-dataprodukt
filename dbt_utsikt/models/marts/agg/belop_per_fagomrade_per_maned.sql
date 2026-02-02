with

ref_fak_stoppnivaer as (
    select
        fagomrade_navn,
        faggruppe_navn,
        belop_brutto,
        lastet_tid_kilde
    from venteregister.fak_stoppnivaer
),

final as (
    select
        fagomrade_navn,
        faggruppe_navn,
        extract(month from lastet_tid_kilde) as maned,
        extract(year from lastet_tid_kilde) as ar,
        sum(belop_brutto) as total_belop_brutto
    from ref_fak_stoppnivaer
    group by fagomrade_navn, faggruppe_navn, mnd, ar
)

select * from final
