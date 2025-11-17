--fak_stoppstatus
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
),

ref_int_stoppstatuskoder_manuell_handtering as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        handteres_manuelt
    from {{ ref('int_stoppstatuskoder_manuell_handtering') }}
),

beregne_lengde_stoppstatus as (
    select
        ref_stoppstatus_snapshot.beregning_id,
        ref_stoppstatus_snapshot.stoppniva_id,
        ref_stoppstatus_snapshot.ventestatus_kode,
        ref_int_stoppstatuskoder_manuell_handtering.ventestatus_beskrivelse,
        ref_int_stoppstatuskoder_manuell_handtering.handteres_manuelt as handteres_manuelt_flagg,
        ref_stoppstatus_snapshot.lastet_tid_kilde,
        ref_stoppstatus_snapshot.gyldig_fra_tid,
        ref_stoppstatus_snapshot.gyldig_til_tid,
        coalesce(ref_stoppstatus_snapshot.gyldig_til_tid, current_timestamp()) - ref_stoppstatus_snapshot.gyldig_fra_tid as lengde_stoppstatus
    from ref_stoppstatus_snapshot
    left join ref_int_stoppstatuskoder_manuell_handtering
        on ref_stoppstatus_snapshot.ventestatus_kode = ref_int_stoppstatuskoder_manuell_handtering.ventestatus_kode
),

final as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        ventestatus_beskrivelse,
        lastet_tid_kilde,
        gyldig_fra_tid,
        gyldig_til_tid,
        handteres_manuelt_flagg,
        lengde_stoppstatus
    from beregne_lengde_stoppstatus
)

select * from final
