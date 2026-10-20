-- agg_beregninger_per_ventestatus_varighet_fagomrade_enhet
with

ref_fak_stoppstatus as (
    select
        beregning_id,
        ventestatus_kode,
        ventestatus_beskrivelse,
        handteres_manuelt_flagg,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        enhet_behandler,
        lastet_tid_kilde,
        gyldig_fom_tid,
        gyldig_til_tid, -- gjeldende status dersom gyldig_til_tid er null
        lastet_tid
    from {{ ref('fak_stoppstatus') }}
),

ref_int_fagomrader_med_tilhorende_faggrupper as (
    select
        fagomrade_kode,
        ytelse
    from {{ ref('int_fagomrader_med_tilhorende_faggrupper') }}
),

clean_data as (
    select
        beregning_id,
        ventestatus_kode,
        ventestatus_beskrivelse,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        handteres_manuelt_flagg,
        case
            when enhet_behandler = '8020' then 'NØS'
            when enhet_behandler = '4819' then 'NØP'
            else 'Annet'
        end as enhet_behandler,
        case
            when gyldig_til_tid is null then 1
            else 0
        end as gjeldende_flagg,
        extract(date from lastet_tid_kilde) as status_registrert_dato,
        coalesce(extract(date from gyldig_til_tid), current_date()) as gyldig_til_dato
    from ref_fak_stoppstatus
),

calculate_antall_dager as (
    select
        beregning_id,
        ventestatus_kode,
        ventestatus_beskrivelse,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        handteres_manuelt_flagg,
        enhet_behandler,
        gjeldende_flagg,
        status_registrert_dato,
        date_diff(gyldig_til_dato, status_registrert_dato, day) as varighet_dager
    from clean_data
),

antall_statuser_per_dag as (
    select
        ventestatus_beskrivelse,
        ventestatus_kode,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        enhet_behandler,
        status_registrert_dato,
        handteres_manuelt_flagg,
        varighet_dager,
        gjeldende_flagg,
        count(distinct beregning_id) as antall_beregninger
    from calculate_antall_dager
    group by
        ventestatus_beskrivelse,
        ventestatus_kode,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        enhet_behandler,
        handteres_manuelt_flagg,
        status_registrert_dato,
        varighet_dager,
        gjeldende_flagg
),

join_ytelse as (
    select
        antall_statuser_per_dag.*,
        ref_int_fagomrader_med_tilhorende_faggrupper.ytelse
    from antall_statuser_per_dag
    left join ref_int_fagomrader_med_tilhorende_faggrupper
        on antall_statuser_per_dag.fagomrade_kode = ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_kode
),

final as (
    select
        ventestatus_beskrivelse,
        ventestatus_kode,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        enhet_behandler,
        ytelse,
        gjeldende_flagg,
        status_registrert_dato,
        handteres_manuelt_flagg,
        varighet_dager,
        antall_beregninger
    from join_ytelse
)

select * from final
