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
from {{ ref('stg_db2os__stoppstatuskoder') }}
