select
    trim(kode_faggruppe) as faggruppe_kode,
    trim(navn_faggruppe) as faggruppe
from {{ source('OS_Q2', 't_faggruppe') }}
