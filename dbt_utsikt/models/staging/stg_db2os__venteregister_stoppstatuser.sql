select 
beregnings_id as beregning_id
,stoppnivaa_id as stoppniva_id
,kode_ventestatus as ventestatus_id
,lopenr as lopenummer
,cast(tidspkt_reg as TIMESTAMP) as registrert_tidspunkt
from {{ source('venteregister_name', 't_vent_stoppstatus')}}