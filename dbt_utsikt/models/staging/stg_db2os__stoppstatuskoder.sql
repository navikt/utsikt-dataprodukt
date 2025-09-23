select
    kode_ventestatus as ventestatus_kode,
    beskrivelse as ventestatus_beskrivelse
from {{ source('OS_Q2', 't_vent_statuskode') }}
