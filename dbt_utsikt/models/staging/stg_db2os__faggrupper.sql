select
    trim(kode_faggruppe) as faggruppe_kode,
    trim(navn_faggruppe) as faggruppe_navn
from {{ source('OS_T1', 't_faggruppe') }}
