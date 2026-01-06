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

ref_fak_beregninger as (
    select
        beregning_id,
        beregnet_dato
    from {{ ref('fak_beregninger') }}
),

join_beregnet_dato as (
    select
        ref_fak_stoppstatus.*,
        ref_fak_beregninger.beregnet_dato
    from ref_fak_stoppstatus
    left join ref_fak_beregninger on ref_fak_stoppstatus.beregning_id = ref_fak_beregninger.beregning_id
),

antall_beregninger_per_ventestatus_per_beregnet_dato as (
    select
        ventestatus_beskrivelse,
        ventestatus_kode,
        beregnet_dato,
        handteres_manuelt_flagg,
        count(beregning_id)
            as antall_beregninger
    from join_beregnet_dato
    group by
        ventestatus_beskrivelse,
        ventestatus_kode,
        handteres_manuelt_flagg,
        beregnet_dato
),

final as (
    select
        beregnet_dato,
        ventestatus_kode,
        ventestatus_beskrivelse,
        antall_beregninger,
        handteres_manuelt_flagg
    from antall_beregninger_per_ventestatus_per_beregnet_dato
)

select * from final
