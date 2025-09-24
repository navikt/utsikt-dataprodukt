with
ref_stg_db2os__stoppstatuser as (
    select
        beregning_id,
        ventestatus_kode
    from {{ ref('stg_db2os__stoppstatuser') }}
),

ref_int_statuskoder_manuell_handtering as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        handteres_manuelt
    from {{ ref('int_statuskoder_manuell_handtering') }}
),

ref_stg_db2os__beregninger as (
    select
        beregning_id,
        beregnet_dato
    from {{ ref('stg_db2os__beregninger') }}
),

distinkte_beregninger_per_ventestatus as (
    select distinct
        ventestatus_kode,
        beregning_id
    from ref_stg_db2os__stoppstatuser
),

antall_beregninger_per_ventestatus_per_dag as (
    select
        ref_int_statuskoder_manuell_handtering.ventestatus_beskrivelse,
        distinkte_beregninger_per_ventestatus.ventestatus_kode,
        ref_stg_db2os__beregninger.beregnet_dato,
        count(distinkte_beregninger_per_ventestatus.beregning_id)
            as antall_beregninger,
        case
            when
                ref_int_statuskoder_manuell_handtering.handteres_manuelt = 1
                then 'Håndteres manuelt'
            else 'Ingen manuell håndtering'
        end as handteres_manuelt
    from distinkte_beregninger_per_ventestatus
    left join
        ref_int_statuskoder_manuell_handtering
        on
            distinkte_beregninger_per_ventestatus.ventestatus_kode
            = ref_int_statuskoder_manuell_handtering.ventestatus_kode
    left join
        ref_stg_db2os__beregninger
        on
            distinkte_beregninger_per_ventestatus.beregning_id
            = ref_stg_db2os__beregninger.beregning_id
    group by
        ref_int_statuskoder_manuell_handtering.ventestatus_beskrivelse,
        distinkte_beregninger_per_ventestatus.ventestatus_kode,
        ref_int_statuskoder_manuell_handtering.handteres_manuelt,
        ref_stg_db2os__beregninger.beregnet_dato
),

final as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        antall_beregninger,
        handteres_manuelt
    from antall_beregninger_per_ventestatus_per_dag
)

select * from final
