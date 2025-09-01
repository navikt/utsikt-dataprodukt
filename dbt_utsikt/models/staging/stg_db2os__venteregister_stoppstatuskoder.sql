select 
kode_ventestatus as ventestatus_id
,beskrivelse as ventestatus
from {{ source('OS_Q2', 't_vent_statuskode')}}