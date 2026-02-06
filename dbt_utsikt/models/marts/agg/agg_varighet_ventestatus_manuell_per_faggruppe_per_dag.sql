with
ref_agg_varighet_ventestatus_avsluttet_per_faggruppe_per_dag as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        registrert_dag,
        varighet_dager,
        0 as gjeldende_flagg,
        antall
    from {{ ref('agg_varighet_ventestatus_avsluttet_per_faggruppe_per_dag') }}
    where handteres_manuelt_flagg = 1
),

ref_agg_varighet_ventestatus_gjeldende_per_faggruppe_per_dag as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        registrert_dag,
        varighet_dager,
        1 as gjeldende_flagg,
        antall
    from {{ ref('agg_varighet_ventestatus_gjeldende_per_faggruppe_per_dag') }}
    where handteres_manuelt_flagg = 1
),

union_all as (
    select * from ref_agg_varighet_ventestatus_avsluttet_per_faggruppe_per_dag
    union all
    select * from ref_agg_varighet_ventestatus_gjeldende_per_faggruppe_per_dag
),

final as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        registrert_dag,
        varighet_dager,
        gjeldende_flagg,
        antall
    from union_all
)

select * from final
