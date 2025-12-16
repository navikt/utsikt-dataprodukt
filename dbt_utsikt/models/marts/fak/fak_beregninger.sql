--fak_beregninger
{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    partition_by={
      "field": "lastet_tid_kilde",
      "data_type": "timestamp",
      "granularity": "day"},
    partition_expiration_days=730
  )
}}

with
ref_stg_db2os__beregninger as (
    select
        beregning_id,
        faggruppe_kode,
        beregnet_dato,
        lastet_tid_kilde
    from {{ ref('stg_db2os__beregninger') }}
    {% if is_incremental() %}
        where
            lastet_tid_kilde
            > (
                select coalesce(max(lastet_tid_kilde), '1900-01-01') --noqa: RF02
                from {{ this }}
            )

    {% endif %}
),

ref_stg_db2os__faggrupper as (
    select
        faggruppe_kode,
        faggruppe_navn
    from {{ ref('stg_db2os__faggrupper') }}
),

join_beregninger_med_faggruppe as (
    select
        ref_stg_db2os__beregninger.beregning_id,
        ref_stg_db2os__beregninger.faggruppe_kode,
        ref_stg_db2os__faggrupper.faggruppe_navn,
        ref_stg_db2os__beregninger.beregnet_dato,
        ref_stg_db2os__beregninger.lastet_tid_kilde
    from ref_stg_db2os__beregninger
    left join
        ref_stg_db2os__faggrupper
        on
            ref_stg_db2os__beregninger.faggruppe_kode
            = ref_stg_db2os__faggrupper.faggruppe_kode
),

lage_primary_key as (
    select
        beregning_id,
        faggruppe_kode,
        faggruppe_navn,
        beregnet_dato,
        lastet_tid_kilde,
        sha256(concat(beregning_id)) as pk_beregning,
        current_timestamp() as lastet_tid
    from join_beregninger_med_faggruppe
),

final as (
    select
        pk_beregning,
        beregning_id,
        faggruppe_kode,
        faggruppe_navn,
        beregnet_dato,
        lastet_tid_kilde,
        lastet_tid
    from lage_primary_key
)

select * from final
