--fak_stoppstatus
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
ref_stoppstatus_snapshot as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        lastet_tid_kilde,
        dbt_valid_from as gyldig_fra_tid,
        dbt_valid_to as gyldig_til_tid
    from {{ ref('stoppstatus_snapshot') }}
    {% if is_incremental() %}
        where
            lastet_tid_kilde
            > (
                select coalesce(max(lastet_tid_kilde), '1900-01-01') -- noqa: RF02: LT05: 
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

join_manuell_handtering as (
    select
        ref_stoppstatus_snapshot.beregning_id,
        ref_stoppstatus_snapshot.stoppniva_id,
        ref_stoppstatus_snapshot.ventestatus_kode,
        ref_int_stoppstatuskoder_manuell_handtering.ventestatus_beskrivelse,
        ref_int_stoppstatuskoder_manuell_handtering.handteres_manuelt as handteres_manuelt_flagg,
        ref_stoppstatus_snapshot.lastet_tid_kilde,
        ref_stoppstatus_snapshot.gyldig_fra_tid,
        ref_stoppstatus_snapshot.gyldig_til_tid
    from ref_stoppstatus_snapshot
    left join ref_int_stoppstatuskoder_manuell_handtering
        on ref_stoppstatus_snapshot.ventestatus_kode = ref_int_stoppstatuskoder_manuell_handtering.ventestatus_kode
),

lage_primary_key as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        ventestatus_beskrivelse,
        lastet_tid_kilde,
        gyldig_fra_tid,
        gyldig_til_tid,
        handteres_manuelt_flagg,
        concat(beregning_id, '-', stoppniva_id, '-', lastet_tid_kilde) as pk_stoppstatus
    from join_manuell_handtering
),

final as (
    select
        pk_stoppstatus,
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        ventestatus_beskrivelse,
        lastet_tid_kilde,
        gyldig_fra_tid,
        gyldig_til_tid,
        handteres_manuelt_flagg
    from lage_primary_key
)

select * from final
