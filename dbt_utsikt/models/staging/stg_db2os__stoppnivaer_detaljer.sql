select
    beregnings_id as beregning_id,
    stoppnivaa_id as stoppniva_id,
    linjenr,
    linje_id,
    dato_faktisk_fom as faktisk_fom_dato,
    dato_faktisk_tom as faktisk_tom_dato,
    trekkvedtak_id,
    trim(kode_klasse) as klasse_kode,
    parse_numeric(belop) as belop,
    timestamp(tidspkt_reg, 'Europe/Oslo') as lastet_tid_kilde
from {{ source('OS', 't_vent_detalj') }}
