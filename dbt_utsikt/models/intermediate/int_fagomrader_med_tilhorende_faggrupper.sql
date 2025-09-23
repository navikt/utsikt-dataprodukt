-- int_fagomrader_med_tilhorende_faggrupper
with

ref_stg_db2os__fagomrader as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode
    from {{ ref('stg_db2os__fagomrader') }}
),

ref_stg_db2os__faggrupper as (
    select
        faggruppe_kode,
        faggruppe_navn
    from {{ ref('stg_db2os__faggrupper') }}
),

join_omrade_gruppe as (
    select
        ref_stg_db2os__fagomrader.fagomrade_kode,
        ref_stg_db2os__fagomrader.fagomrade_navn,
        ref_stg_db2os__faggrupper.faggruppe_kode,
        ref_stg_db2os__faggrupper.faggruppe_navn
    from ref_stg_db2os__fagomrader
    left join
        ref_stg_db2os__faggrupper
        on
            ref_stg_db2os__fagomrader.faggruppe_kode
            = ref_stg_db2os__faggrupper.faggruppe_kode
),

final as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        faggruppe_navn
    from join_omrade_gruppe
)

select * from final
