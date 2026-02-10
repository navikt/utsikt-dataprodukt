-- agg_ventestatus_gjeldende_per_varighet_fagomrade_dag
-- agg_ventestatus_gjeldende_per_varighet_fagomrade_dag
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
    where gyldig_til_tid is null -- kun gjeldende statuser
    --and date(lastet_tid_kilde) > DATE_SUB(current_date, INTERVAL 3 MONTH) --kun 3 måneder tilbake i tid
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
        date_diff(current_date(), extract(date from lastet_tid_kilde), day) as varighet_dager
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
        varighet_dager
),

final as (
    select
        ventestatus_beskrivelse,
        ventestatus_kode,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        status_registrert_dato,
        handteres_manuelt_flagg,
        varighet_dager,
        antall
    from antall_statuser_per_dag
)

select * from final
