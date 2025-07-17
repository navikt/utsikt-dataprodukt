select 
trim(kode_faggruppe) as faggruppe_id
,trim(navn_faggruppe) as faggruppe
from {{ source('venteregister_name', 't_faggruppe')}}