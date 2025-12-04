with

ref_fak_stoppstatus as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        ventestatus_beskrivelse,
        lastet_tid_kilde,
        gyldig_fra_tid,
        gyldig_til_tid,
        handteres_manuelt_flagg
    from {{ ref("fak_stoppstatus") }}
),

beregne_lengde_stoppstatus as (
    select
        *,
        coalesce(ref_fak_stoppstatus.gyldig_til_tid, current_timestamp()) - ref_fak_stoppstatus.gyldig_fra_tid as lengde_stoppstatus
    from ref_fak_stoppstatus
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
