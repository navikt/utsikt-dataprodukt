select
    trim(kode_fagomraade) as fagomrade_kode,
    trim(navn_fagomraade) as fagomrade_navn,
    trim(kode_faggruppe) as faggruppe_kode
from {{ source('OS', 't_fagomraade') }}
