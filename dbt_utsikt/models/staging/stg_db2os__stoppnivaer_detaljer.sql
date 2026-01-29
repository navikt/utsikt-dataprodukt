select
    beregnings_id as beregning_id,
    stoppnivaa_id as stoppniva_id,
    linjenr,
    linje_id,
    kode_klasse as klasse_kode,
    dato_faktisk_fom as faktisk_fom_dato,
    dato_faktisk_tom as faktisk_tom_dato,
    trekkvedtak_id,
    PARSE_NUMERIC(belop) as belop,
    TIMESTAMP(tidspkt_reg, 'Europe/Oslo') as lastet_tid_kilde
from {{ source('OS', 't_vent_detalj') }}
