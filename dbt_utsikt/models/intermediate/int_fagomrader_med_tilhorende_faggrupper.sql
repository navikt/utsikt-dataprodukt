-- int_fagomrader_med_tilhorende_faggrupper
with

ref_int_fagomrader_til_ytelser as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        ytelse
    from {{ ref('int_fagomrader_til_ytelser') }}
),

ref_stg_db2os__faggrupper as (
    select
        faggruppe_kode,
        faggruppe_navn
    from {{ ref('stg_db2os__faggrupper') }}
),

join_omrade_gruppe as (
    select
        ref_int_fagomrader_til_ytelser.fagomrade_kode,
        ref_int_fagomrader_til_ytelser.fagomrade_navn,
        ref_int_fagomrader_til_ytelser.ytelse,
        ref_stg_db2os__faggrupper.faggruppe_kode,
        ref_stg_db2os__faggrupper.faggruppe_navn
    from ref_int_fagomrader_til_ytelser
    left join
        ref_stg_db2os__faggrupper
        on
            ref_int_fagomrader_til_ytelser.faggruppe_kode
            = ref_stg_db2os__faggrupper.faggruppe_kode
),

final as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        faggruppe_navn,
        ytelse
    from join_omrade_gruppe
)

select * from final
