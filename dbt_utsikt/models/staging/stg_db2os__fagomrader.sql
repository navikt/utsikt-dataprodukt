select
    trim(kode_fagomraade) as fagomrade_id,
    trim(navn_fagomraade) as fagomrade,
    trim(kode_faggruppe) as faggruppe_kode
from {{ source('OS_Q2', 't_fagomraade') }}
