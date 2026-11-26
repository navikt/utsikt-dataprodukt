--fak_oppdrag
{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    partition_by={
      "field": "lastet_tid_kilde",
      "data_type": "timestamp",
      "granularity": "day"}
  )
}}

with
ref_stg_db2os__oppdrag_kilde as (
    select
        oppdrag_id,
        kildesystem,
        lastet_tid_kilde
    from {{ ref('stg_db2os__oppdrag_kilde') }}
    {% if is_incremental() %}
        where
            lastet_tid_kilde
            > (
                select coalesce(max(lastet_tid_kilde), '1900-01-01') --noqa: RF02
                from {{ this }}
            )

    {% endif %}
),


lage_primary_key as (
    select
        oppdrag_id,
        kildesystem,
        lastet_tid_kilde,
        sha256(concat(oppdrag_id)) as pk_oppdrag,
        current_timestamp() as lastet_tid
    from ref_stg_db2os__oppdrag_kilde
),

final as (
    select
        pk_oppdrag,
        oppdrag_id,
        kildesystem,
        lastet_tid_kilde,
        lastet_tid
    from lage_primary_key
)

select * from final
