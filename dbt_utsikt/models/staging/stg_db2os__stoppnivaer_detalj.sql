select
    beregnings_id as beregning_id,
    stoppnivaa_id as stoppniva_id,
    linjenr,
    trekkvedtak_id,
    PARSE_NUMERIC(belop) as belop,
    TIMESTAMP(tidspkt_reg, 'Europe/Oslo') as lastet_tid_kilde
from {{ source('OS', 't_vent_detalj') }}
