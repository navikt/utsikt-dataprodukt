--fak_saldo_postert
{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='pk_saldo_postert',
    merge_update_columns=['antall_mottakere','sum_debet','sum_kredit','oppdatert_tid_kilde'],
    partition_by={
      "field": "postert_ur_dato",
      "data_type": "date",
      "granularity": "day"},
    partition_expiration_days=730
  )
}}

with
ref_stg_db2ur__saldo_detalj as (
    select
        postert_ur_dato,
        hovedkonto_nr,
        underkonto_nr,
        oppdrag_nr,
        antall_mottakere,
        sum_debet,
        sum_kredit,
        lastet_tid_kilde,
        oppdatert_tid_kilde
    from {{ ref('stg_db2ur__saldo_detalj') }}
    {% if is_incremental() %}
        where
            oppdatert_tid_kilde
            > (
                select coalesce(max(oppdatert_tid_kilde), '1900-01-01') -- noqa: RF02
                from {{ this }}
            )

    {% endif %}
),

ref_stg_db2ur__kontoplan as (
    select
        hovedkonto_nr,
        underkonto_nr,
        hovedkonto_navn,
        underkonto_navn
    from {{ ref('stg_db2ur__kontoplan') }}
    where lopenr = 9999
),

ref_stg_db2ur__oppdragskode as (
    select
        oppdrag_nr,
        oppdrag_kode,
        oppdrag_navn
    from {{ ref('stg_db2ur__oppdragskode') }}
),

join_kontoplan_oppdragskode as (
    select
        ref_stg_db2ur__saldo_detalj.*,
        ref_stg_db2ur__kontoplan.hovedkonto_navn,
        ref_stg_db2ur__kontoplan.underkonto_navn,
        ref_stg_db2ur__oppdragskode.oppdrag_kode,
        ref_stg_db2ur__oppdragskode.oppdrag_navn
    from ref_stg_db2ur__saldo_detalj
    left join ref_stg_db2ur__kontoplan
        on
            ref_stg_db2ur__saldo_detalj.hovedkonto_nr = ref_stg_db2ur__kontoplan.hovedkonto_nr
            and ref_stg_db2ur__saldo_detalj.underkonto_nr = ref_stg_db2ur__kontoplan.underkonto_nr
    left join ref_stg_db2ur__oppdragskode
        on
            ref_stg_db2ur__saldo_detalj.oppdrag_nr = ref_stg_db2ur__oppdragskode.oppdrag_nr
),

lage_primary_key as (
    select
        join_kontoplan_oppdragskode.*,
        sha256(concat(postert_ur_dato, hovedkonto_nr, underkonto_nr, oppdrag_nr)) as pk_saldo_postert,
        current_timestamp() as lastet_tid
    from join_kontoplan_oppdragskode
),

final as (
    select
        pk_saldo_postert,
        postert_ur_dato,
        hovedkonto_nr,
        underkonto_nr,
        hovedkonto_navn,
        underkonto_navn,
        oppdrag_nr,
        oppdrag_kode,
        oppdrag_navn,
        antall_mottakere,
        sum_debet,
        sum_kredit,
        lastet_tid_kilde,
        oppdatert_tid_kilde,
        lastet_tid
    from lage_primary_key
)

select * from final
