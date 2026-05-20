select
    oppdrags_id as oppdrag_id,
    trim(kode_fagomraade) as fagomrade_kode,
    timestamp(tidspkt_reg, 'Europe/Oslo') as lastet_tid_kilde
from {{ source('OS', 't_oppdrag') }}
