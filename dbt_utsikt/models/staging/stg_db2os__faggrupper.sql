select 
kode_faggruppe as faggruppe_id
,navn_faggruppe as faggruppe
from {{ source('venteregister_name', 't_faggruppe')}}