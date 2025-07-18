select 
kode_ventestatus as ventestatus_id
,beskrivelse as ventestatus
from {{ source('venteregister_name', 't_vent_statuskode')}}