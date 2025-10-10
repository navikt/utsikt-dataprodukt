--fak_stoppnivaer
{{
  config(
    materialized='incremental',
    incremental_strategy='merge'
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
        overfort_dato,
        lastet_tid_kilde
    from {{ ref('stg_db2os__stoppnivaer') }}
    {% if is_incremental() %}
        where
            lastet_tid_kilde
            > (
                select coalesce(max(lastet_tid_kilde), '1900-01-01') -- noqa: RF02: LT05: 
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

join_med_beregnet_dato_og_faggruppe as (
    select
        ref_stg_db2os__stoppnivaer.beregning_id,
        ref_stg_db2os__stoppnivaer.stoppniva_id,
        ref_stg_db2os__stoppnivaer.oppdrag_id,
        ref_stg_db2os__stoppnivaer.fagsystem_id,
        ref_stg_db2os__stoppnivaer.type_skatt,
        ref_stg_db2os__stoppnivaer.periode_fom_dato,
        ref_stg_db2os__stoppnivaer.periode_tom_dato,
        ref_stg_db2os__stoppnivaer.forfall_dato,
        ref_stg_db2os__stoppnivaer.fagomrade_kode,
        ref_stg_db2os__stoppnivaer.overfort_dato,
        ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_navn,
        ref_int_fagomrader_med_tilhorende_faggrupper.faggruppe_navn,
        ref_stg_db2os__beregninger.beregnet_dato,
        ref_stg_db2os__stoppnivaer.lastet_tid_kilde
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
),

final as (
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
        overfort_dato,
        fagomrade_navn,
        faggruppe_navn,
        beregnet_dato,
        lastet_tid_kilde
    from join_med_beregnet_dato_og_faggruppe
)

select * from final
