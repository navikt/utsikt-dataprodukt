select
    trim(kode_faggruppe) as faggruppe_id,
    trim(navn_faggruppe) as faggruppe
from {{ source('OS_Q2', 't_faggruppe') }}
