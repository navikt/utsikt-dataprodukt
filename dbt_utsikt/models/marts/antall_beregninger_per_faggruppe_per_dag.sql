--antall_beregninger_per_faggruppe_per_dag
with
ref_stg_db2os__beregninger as (
    select
        beregning_id,
        faggruppe_kode,
        beregnet_dato
    from {{ ref('stg_db2os__beregninger') }}
),

ref_stg_db2os__faggrupper as (
    select
        faggruppe_kode,
        faggruppe_navn
    from {{ ref('stg_db2os__faggrupper') }}
),

antall_beregninger_per_faggruppe_per_dag as (
    select
        ref_stg_db2os__beregninger.faggruppe_kode,
        ref_stg_db2os__faggrupper.faggruppe_navn,
        ref_stg_db2os__beregninger.beregnet_dato,
        count(ref_stg_db2os__beregninger.beregning_id) as antall_beregninger
    from ref_stg_db2os__beregninger
    left join
        ref_stg_db2os__faggrupper
        on
            ref_stg_db2os__beregninger.faggruppe_kode
            = ref_stg_db2os__faggrupper.faggruppe_kode
    group by
        ref_stg_db2os__beregninger.faggruppe_kode,
        ref_stg_db2os__faggrupper.faggruppe_navn,
        ref_stg_db2os__beregninger.beregnet_dato

),

final as (
    select
        faggruppe_kode,
        faggruppe_navn,
        beregnet_dato,
        antall_beregninger
    from antall_beregninger_per_faggruppe_per_dag
)

select * from final
