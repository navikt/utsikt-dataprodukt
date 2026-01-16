select
    trim(kode_faggruppe) as faggruppe_kode,
    trim(navn_faggruppe) as faggruppe_navn
from {{ source('OS', 't_faggruppe') }}
