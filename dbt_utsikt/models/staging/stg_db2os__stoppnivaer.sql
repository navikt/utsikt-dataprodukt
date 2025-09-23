select
    beregnings_id as beregning_id,
    stoppnivaa_id as stoppniva_id,
    oppdrags_id as oppdrag_id,
    fagsystem_id,
    type_skatt,
    dato_periode_fom as periode_fom_dato,
    dato_periode_tom as periode_tom_dato,
    dato_forfall as forfall_dato,
    dato_overfores as overfort_dato,
    trim(kode_fagomraade) as fagomrade_id
from {{ source('OS_Q2', 't_vent_stoppnivaa') }}
