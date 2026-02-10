--agg_ventestatus_avsluttet_per_varighet_fagomrade_dag
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
        extract(date from lastet_tid_kilde) as status_registrert_dato,
        extract(date from gyldig_til_tid) as status_avsluttet_dato,
        date_diff(extract(date from gyldig_til_tid), extract(date from lastet_tid_kilde), day) as varighet_dager
    from ref_fak_stoppstatus
),

antall_statuser_per_dag as (
    select
        ventestatus_beskrivelse,
        ventestatus_kode,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        status_registrert_dato,
        status_avsluttet_dato,
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
        status_registrert_dato,
        status_avsluttet_dato,
        varighet_dager
),

final as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        status_registrert_dato,
        status_avsluttet_dato,
        handteres_manuelt_flagg,
        varighet_dager,
        antall
    from antall_statuser_per_dag
)

select * from final
