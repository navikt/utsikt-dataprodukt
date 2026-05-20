select
    oppdrags_id as oppdrag_id,
    kode_komponent,
    timestamp(tidspkt_reg, 'Europe/Oslo') as lastet_tid_kilde
from {{ source('OS', 't_oppdrag_kilde') }}
