--fak_stoppnivaer_detaljer
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

ref_stg_db2os__stoppnivaer_detaljer as (
    select
        beregning_id,
        stoppniva_id,
        linjenr,
        trekkvedtak_id,
        belop,
        lastet_tid_kilde
    from {{ ref('stg_db2os__stoppnivaer_detaljer') }}
    {% if is_incremental() %}
        where
            lastet_tid_kilde
            > (
                select coalesce(max(lastet_tid_kilde), '1900-01-01') -- noqa: RF02
                from {{ this }}
            )

    {% endif %}
),

primary_key_og_lastet_tid as (
    select
        ref_stg_db2os__stoppnivaer_detaljer.*,
        sha256(concat(beregning_id, stoppniva_id, linjenr)) as pk_stoppnivaer_detaljer,
        current_timestamp() as lastet_tid
    from ref_stg_db2os__stoppnivaer_detaljer
),

final as (
    select
        pk_stoppnivaer_detaljer,
        beregning_id,
        stoppniva_id,
        linjenr,
        trekkvedtak_id,
        belop,
        lastet_tid_kilde,
        lastet_tid
    from primary_key_og_lastet_tid
)

select * from final
