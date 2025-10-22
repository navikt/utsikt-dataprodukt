select
    beregnings_id as beregning_id,
    stoppnivaa_id as stoppniva_id,
    kode_ventestatus as ventestatus_kode,
    lopenr as lopenummer,
    timestamp(tidspkt_reg, 'Europe/Oslo') as registrert_tidspunkt
from {{ source('OS_Q2', 't_vent_stoppstatus') }}
