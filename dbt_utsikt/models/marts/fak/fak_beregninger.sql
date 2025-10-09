--fak_beregninger
{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    partition_by={
      "field": "lastet_tid_kilde",
      "data_type": "datetime",
      "granularity": "day"}
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
                select coalesce(max(lastet_tid_kilde), '1900-01-01') -- noqa: RF02: LT05: 
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

final as (
    select
        beregning_id,
        faggruppe_kode,
        faggruppe_navn,
        beregnet_dato,
        lastet_tid_kilde
    from join_beregninger_med_faggruppe
)

select * from final
