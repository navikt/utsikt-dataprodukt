--fak_oppdrag
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
ref_stg_db2os__oppdrag as (
    select
        oppdrag_id,
        fagomrade_kode,
        lastet_tid_kilde
    from {{ ref('stg_db2os__oppdrag') }}
    {% if is_incremental() %}
        where
            lastet_tid_kilde
            > (
                select coalesce(max(lastet_tid_kilde), '1900-01-01') --noqa: RF02
                from {{ this }}
            )

    {% endif %}
),

ref_stg_db2os__oppdrag_kilde as (
    select
        oppdrag_id,
        kildesystem
    from {{ ref('stg_db2os__oppdrag_kilde') }}
),


ref_int_fagomrader_med_tilhorende_faggrupper as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        faggruppe_navn
    from {{ ref('int_fagomrader_med_tilhorende_faggrupper') }}
),


join_oppdrag_med_fagomrade as (
    select
        ref_stg_db2os__oppdrag.oppdrag_id,
        ref_stg_db2os__oppdrag.fagomrade_kode,
        ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_navn,
        ref_int_fagomrader_med_tilhorende_faggrupper.faggruppe_kode,
        ref_int_fagomrader_med_tilhorende_faggrupper.faggruppe_navn,
        ref_stg_db2os__oppdrag.lastet_tid_kilde
    from ref_stg_db2os__oppdrag
    left join ref_int_fagomrader_med_tilhorende_faggrupper
    on ref_stg_db2os__oppdrag.fagomrade_kode = ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_kode
),

join_oppdrag_med_kildesystem as (
    select
        join_oppdrag_med_fagomrade.oppdrag_id,
        join_oppdrag_med_fagomrade.fagomrade_kode,
        join_oppdrag_med_fagomrade.fagomrade_navn,
        join_oppdrag_med_fagomrade.faggruppe_kode,
        join_oppdrag_med_fagomrade.faggruppe_navn,
        ref_stg_db2os__oppdrag_kilde.kildesystem,
        join_oppdrag_med_fagomrade.lastet_tid_kilde
    from join_oppdrag_med_fagomrade
    left join ref_stg_db2os__oppdrag_kilde
    on join_oppdrag_med_fagomrade.oppdrag_id = ref_stg_db2os__oppdrag_kilde.oppdrag_id
),

lage_primary_key as (
    select
        oppdrag_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        faggruppe_navn,
        kildesystem,
        lastet_tid_kilde,
        sha256(concat(oppdrag_id)) as pk_oppdrag,
        current_timestamp() as lastet_tid
    from join_oppdrag_med_kildesystem
),

final as (
    select
        pk_oppdrag,
        oppdrag_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        faggruppe_navn,
        kildesystem,
        lastet_tid_kilde,
        lastet_tid
    from lage_primary_key)

select * from final