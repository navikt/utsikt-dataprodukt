with

ref_fak_stoppnivaer as (
    select
        fagomrade_navn,
        faggruppe_navn,
        brutto_belop,
        lastet_tid_kilde
    from venteregister.fak_stoppnivaer
),

final as (
    select
        fagomrade_navn,
        faggruppe_navn,
        extract(month from lastet_tid_kilde) as mnd,
        extract(year from lastet_tid_kilde) as ar,
        sum(brutto_belop) as total_brutto_belop
    from ref_fak_stoppnivaer
    group by fagomrade_navn, faggruppe_navn, mnd, ar
)

select * from final
