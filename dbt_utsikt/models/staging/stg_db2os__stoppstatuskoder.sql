select
    kode_ventestatus as ventestatus_kode,
    beskrivelse as ventestatus_beskrivelse
from {{ source('OS', 't_vent_statuskode') }}
