select 
kode_fagomraade as fagomrade_id
,navn_fagomraade as fagomrade
,kode_faggruppe as faggruppe_id
from {{ source('venteregister_name', 't_fagomraade')}}