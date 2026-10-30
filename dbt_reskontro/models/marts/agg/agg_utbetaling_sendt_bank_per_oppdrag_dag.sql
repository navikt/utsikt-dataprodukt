--agg_utbetaling_sendt_bank_per_oppdrag_dag #TODO endre til noe mer fornuftig navn når vi vet hva "oppdrag" betyr i denne sammenhengen

with ref_fak_saldo_postert as (
    select
        postert_ur_dato,
        oppdrag_navn,
        sum_kredit,
        antall_mottakere,
        hovedkonto_nr
    from {{ ref('fak_saldo_postert') }}
),

filter_hovedkonto_skyldner as (
    select
        postert_ur_dato,
        oppdrag_navn,
        sum_kredit,
        antall_mottakere
    from ref_fak_saldo_postert
    where hovedkonto_nr = '084'
),

final as (
    select
        postert_ur_dato,
        oppdrag_navn,
        sum_kredit,
        antall_mottakere
    from filter_hovedkonto_skyldner

)

select * from final
