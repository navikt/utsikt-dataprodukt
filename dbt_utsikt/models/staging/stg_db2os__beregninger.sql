select
    beregnings_id as beregning_id,
    dato_beregnet as beregnet_dato,
    timestamp(tidspkt_reg, 'Europe/Oslo') as lastet_tid_kilde,
    trim(kode_faggruppe) as faggruppe_kode
from {{ source('OS_Q2', 't_vent_beregning') }}
