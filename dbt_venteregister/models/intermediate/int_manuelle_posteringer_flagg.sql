-- int_manuelle_posteringer_flagg
with

ref_stg_db2os__fagomrader as (
    select
        fagomrade_kode,
        fagomrade_navn
    from {{ ref('stg_db2os__fagomrader') }}
),

flagge_manuelle_posteringer as (
    select
        fagomrade_kode,
        fagomrade_navn,
        case -- Trine Johansen har sagt at fagområde_kode som starter med M er manuelle posteringer.
            when fagomrade_kode like 'M%' then 1 --fagområde_kode bruker store bokstaver 
            else 0
        end as manuell_postering_flagg
    from ref_stg_db2os__fagomrader
),

final as (
    select
        fagomrade_kode,
        fagomrade_navn,
        manuell_postering_flagg
    from flagge_manuelle_posteringer
)

select * from final
