select 
trim(kode_fagomraade) as fagomrade_id
,trim(navn_fagomraade) as fagomrade
,trim(kode_faggruppe) as faggruppe_id
from {{ source('venteregister', 't_fagomraade')}}