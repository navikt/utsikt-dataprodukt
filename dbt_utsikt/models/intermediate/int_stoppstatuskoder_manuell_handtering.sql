with

ref_stg_db2os__stoppstatuskoder as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse
    from {{ ref('stg_db2os__stoppstatuskoder') }}
),

sette_manuelle_koder as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        case
            when
                ventestatus_kode in (
                    'ADDR',
                    'ANRE',
                    'AVAG',
                    'AVAV',
                    'AVRK',
                    'AVVE',
                    'AVVM',
                    'EONK',
                    'EOPK',
                    'KRAV',
                    'OVUR',
                    'RETN',
                    'RETU'
                )
                then 1
            else 0
        end as handteres_manuelt
    from ref_stg_db2os__stoppstatuskoder
),

final as (
    select
        ventestatus_kode,
        ventestatus_beskrivelse,
        handteres_manuelt
    from sette_manuelle_koder
)

select * from final
