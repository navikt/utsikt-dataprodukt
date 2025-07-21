select 
ventestatus_id
,ventestatus
,case
  when ventestatus_id in ('ADDR', 'ANRE', 'AVAG', 'AVAV', 'AVRK', 'AVVE','AVVM', 'EONK', 'EOPK', 'KRAV', 'OVUR', 'RETN', 'RETU')
  then 1
  else 0
end as ma_handteres_manuelt
from {{ ref('stg_db2os__venteregister_stoppstatuskoder')}}