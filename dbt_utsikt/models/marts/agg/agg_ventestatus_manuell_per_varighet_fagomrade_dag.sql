--agg_ventestatus_manuell_per_varighet_fagomrade_dag
with
ref_agg_ventestatus_avsluttet_per_varighet_fagomrade_dag as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        status_registrert_dato,
        status_avsluttet_dato,
        varighet_dager,
        0 as gjeldende_flagg,
        antall
    from {{ ref('agg_ventestatus_avsluttet_per_varighet_fagomrade_dag') }}
    where handteres_manuelt_flagg = 1
),

ref_agg_ventestatus_gjeldende_per_varighet_fagomrade_dag as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        status_registrert_dato,
        cast(null as date) as status_avsluttet_dato,
        varighet_dager,
        1 as gjeldende_flagg,
        antall
    from {{ ref('agg_ventestatus_gjeldende_per_varighet_fagomrade_dag') }}
    where handteres_manuelt_flagg = 1
),

union_all as (
    select * from ref_agg_ventestatus_avsluttet_per_varighet_fagomrade_dag
    union all
    select * from ref_agg_ventestatus_gjeldende_per_varighet_fagomrade_dag
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
        varighet_dager,
        gjeldende_flagg,
        antall
    from union_all
)

select * from final
