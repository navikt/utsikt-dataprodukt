--fak_stoppstatus
{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='pk_stoppstatus',
    merge_update_columns = ['gyldig_til_tid'],
    partition_by={
      "field": "lastet_tid_kilde",
      "data_type": "timestamp",
      "granularity": "day"},
    partition_expiration_days=730
  )
}}

with
ref_stoppstatus_snapshot as (
    select
        dbt_scd_id as pk_stoppstatus,
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        lastet_tid_kilde,
        dbt_valid_from as gyldig_fom_tid,
        dbt_valid_to as gyldig_til_tid
    from {{ ref('stoppstatus_snapshot') }}
    {% if is_incremental() %}
        where
            coalesce(dbt_valid_to, '9999-01-01')
            > (
                select coalesce(max(gyldig_til_tid), '1900-01-01') -- noqa: RF02
                from {{ this }}
            )
    {% endif %}
),

ref_int_stoppstatuskoder_manuell_handtering as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        handteres_manuelt
    from {{ ref('int_stoppstatuskoder_manuell_handtering') }}
),

ref_fak_stoppnivaer as (
    select
        beregning_id,
        stoppniva_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn
    from {{ ref('fak_stoppnivaer') }}

),

join_manuell_handtering as (
    select
        ref_stoppstatus_snapshot.*,
        ref_int_stoppstatuskoder_manuell_handtering.ventestatus_beskrivelse,
        ref_int_stoppstatuskoder_manuell_handtering.handteres_manuelt as handteres_manuelt_flagg
    from ref_stoppstatus_snapshot
    left join ref_int_stoppstatuskoder_manuell_handtering
        on ref_stoppstatus_snapshot.ventestatus_kode = ref_int_stoppstatuskoder_manuell_handtering.ventestatus_kode
),

join_stoppnivaer as (
    select
        join_manuell_handtering.*,
        ref_fak_stoppnivaer.fagomrade_kode,
        ref_fak_stoppnivaer.fagomrade_navn,
        ref_fak_stoppnivaer.faggruppe_navn,
        current_timestamp() as lastet_tid
    from join_manuell_handtering
    left join ref_fak_stoppnivaer
        on
            join_manuell_handtering.beregning_id = ref_fak_stoppnivaer.beregning_id
            and
            join_manuell_handtering.stoppniva_id = ref_fak_stoppnivaer.stoppniva_id
),

final as (
    select
        pk_stoppstatus,
        beregning_id,
        stoppniva_id,
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
    from join_stoppnivaer
)

select * from final
