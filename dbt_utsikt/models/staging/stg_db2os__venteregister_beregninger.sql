select 
beregnings_id as beregning_id
,dato_beregnet as beregnet_dato
,kode_faggruppe as faggruppe_id
from {{ source('venteregister_name', 't_vent_beregning')}}