with

ref_fak_stoppstatus as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        handteres_manuelt_flagg,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        lastet_tid_kilde,
        gyldig_fom_tid,
        gyldig_til_tid,
        lastet_tid
    from {{ ref('fak_stoppstatus') }}
    where gyldig_til_tid is not null
),

calculate_antall_dager as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        handteres_manuelt_flagg,
        timestamp_trunc(lastet_tid_kilde, day) as registrert_dag,
        date_diff(date(gyldig_til_tid), date(gyldig_fom_tid), day) as varighet_dager
    from ref_fak_stoppstatus
),

antall_statuser_per_dag as (
    select
        ventestatus_beskrivelse,
        ventestatus_kode,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        registrert_dag,
        handteres_manuelt_flagg,
        varighet_dager,
        count(*) as antall
    from calculate_antall_dager
    group by
        ventestatus_beskrivelse,
        ventestatus_kode,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        handteres_manuelt_flagg,
        registrert_dag,
        varighet_dager
),

final as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        registrert_dag,
        handteres_manuelt_flagg,
        varighet_dager,
        antall
    from antall_statuser_per_dag
)

select * from final
