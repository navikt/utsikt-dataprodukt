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

ref_int_manuelle_posteringer_flagg as (
    select
        fagomrade_kode,
        fagomrade_navn,
        manuell_postering_flagg
    from {{ ref('int_manuelle_posteringer_flagg') }}
),

ref_stg_db2os__faggrupper as (
    select
        faggruppe_kode,
        faggruppe_navn
    from {{ ref('stg_db2os__faggrupper') }}
),

join_manuelle_posteringer as (
    select
        ref_int_fagomrader_til_ytelser.fagomrade_kode,
        ref_int_fagomrader_til_ytelser.fagomrade_navn,
        ref_int_fagomrader_til_ytelser.ytelse,
        ref_int_fagomrader_til_ytelser.faggruppe_kode,
        ref_int_manuelle_posteringer_flagg.manuell_postering_flagg
    from ref_int_fagomrader_til_ytelser
    left join
        ref_int_manuelle_posteringer_flagg
        on
            ref_int_fagomrader_til_ytelser.fagomrade_kode
            = ref_int_manuelle_posteringer_flagg.fagomrade_kode
),

join_omrade_gruppe as (
    select
        join_manuelle_posteringer.fagomrade_kode,
        join_manuelle_posteringer.fagomrade_navn,
        join_manuelle_posteringer.ytelse,
        join_manuelle_posteringer.manuell_postering_flagg,
        ref_stg_db2os__faggrupper.faggruppe_kode,
        ref_stg_db2os__faggrupper.faggruppe_navn
    from join_manuelle_posteringer
    left join
        ref_stg_db2os__faggrupper
        on
            join_manuelle_posteringer.faggruppe_kode
            = ref_stg_db2os__faggrupper.faggruppe_kode
),

final as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        faggruppe_navn,
        ytelse,
        manuell_postering_flagg
    from join_omrade_gruppe
)

select * from final
