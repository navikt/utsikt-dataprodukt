--fak_stoppnivaer
{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='pk_stoppnivaer',
    merge_update_columns=['type_skatt', 'lastet_tid'],
    partition_by={
      "field": "lastet_tid_kilde",
      "data_type": "timestamp",
      "granularity": "day"},
    partition_expiration_days=730
  )
}}

with

ref_stg_db2os__stoppnivaer as (
    select
        beregning_id,
        stoppniva_id,
        oppdrag_id,
        fagsystem_id,
        type_skatt,
        periode_fom_dato,
        periode_tom_dato,
        forfall_dato,
        fagomrade_kode,
        overfores_dato,
        lastet_tid_kilde
    from {{ ref('stg_db2os__stoppnivaer') }}
    {% if is_incremental() %}
        where
            lastet_tid_kilde
            > (
                select coalesce(max(lastet_tid_kilde), '1900-01-01') -- noqa: RF02
                from {{ this }}
            )

    {% endif %}
),

ref_int_fagomrader_med_tilhorende_faggrupper as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn
    from {{ ref('int_fagomrader_med_tilhorende_faggrupper') }}
),

ref_stg_db2os__beregninger as (
    select
        beregning_id,
        beregnet_dato
    from {{ ref('stg_db2os__beregninger') }}
),

fak_stoppnivaer_detaljer as (
    select
        beregning_id,
        stoppniva_id,
        linje_id,
        belop
    from {{ ref('fak_stoppnivaer_detaljer') }}
),

summer_belop as (
    select
        beregning_id,
        stoppniva_id,
        sum(belop) as belop_brutto
    from fak_stoppnivaer_detaljer
    where linje_id > 0
    group by
        beregning_id,
        stoppniva_id
),

join_med_beregnet_dato_og_faggruppe as (
    select
        ref_stg_db2os__stoppnivaer.*,
        ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_navn,
        ref_int_fagomrader_med_tilhorende_faggrupper.faggruppe_navn,
        ref_stg_db2os__beregninger.beregnet_dato,
        summer_belop.belop_brutto
    from ref_stg_db2os__stoppnivaer
    left join
        ref_int_fagomrader_med_tilhorende_faggrupper
        on
            ref_stg_db2os__stoppnivaer.fagomrade_kode
            = ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_kode
    left join
        ref_stg_db2os__beregninger
        on
            ref_stg_db2os__stoppnivaer.beregning_id
            = ref_stg_db2os__beregninger.beregning_id
    left join
        summer_belop
        on
            ref_stg_db2os__stoppnivaer.beregning_id
            = summer_belop.beregning_id
            and ref_stg_db2os__stoppnivaer.stoppniva_id
            = summer_belop.stoppniva_id
),

lage_primary_key as (
    select
        join_med_beregnet_dato_og_faggruppe.*,
        sha256(concat(beregning_id, stoppniva_id)) as pk_stoppnivaer,
        current_timestamp() as lastet_tid
    from join_med_beregnet_dato_og_faggruppe
),

dedupliser_stoppnivaer as (
    select * except (rn)
    from (
        select
            *,
            row_number() over (
                partition by pk_stoppnivaer
                order by lastet_tid_kilde desc
            ) as rn
        from lage_primary_key
    )
    where rn = 1
),

final as (
    select
        pk_stoppnivaer,
        beregning_id,
        stoppniva_id,
        oppdrag_id,
        fagsystem_id,
        type_skatt,
        periode_fom_dato,
        periode_tom_dato,
        forfall_dato,
        fagomrade_kode,
        overfores_dato,
        fagomrade_navn,
        faggruppe_navn,
        beregnet_dato,
        belop_brutto,
        lastet_tid_kilde,
        lastet_tid
    from dedupliser_stoppnivaer
)

select * from final
