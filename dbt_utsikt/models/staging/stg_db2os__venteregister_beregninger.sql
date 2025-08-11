select 
beregnings_id as beregning_id
,dato_beregnet as beregnet_dato
,trim(kode_faggruppe) as faggruppe_id
from {{ source('venteregister', 't_vent_beregning')}}