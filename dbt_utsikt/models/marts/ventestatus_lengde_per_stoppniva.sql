with registrerte_tidsstempler as (
select
t1.beregning_id
,t1.stoppniva_id
,t1.lopenummer
,t1.ventestatus_id
,t1.registrert_tidspunkt
,t2.registrert_tidspunkt as registrert_tidspunkt_neste_ventestatus
,t3.registrert_tidspunkt as registrert_tidspunkt_gjeldende_ventestatus
from {{ ref('stg_db2os__venteregister_stoppstatuser') }} t1
left join {{ ref('stg_db2os__venteregister_stoppstatuser') }} t2
        on t1.beregning_id = t2.beregning_id
        and t1.stoppniva_id = t2.stoppniva_id
        and t2.lopenummer = t1.lopenummer + 1
left join {{ ref('stg_db2os__venteregister_stoppstatuser') }} t3
        on t1.beregning_id = t3.beregning_id
        and t1.stoppniva_id = t3.stoppniva_id
        and t3.lopenummer = 9999
),

lengder_stoppstatuser as (
select beregning_id
,stoppniva_id
,lopenummer
,ventestatus_id
,registrert_tidspunkt
,case
  when registrert_tidspunkt_neste_ventestatus is not null then registrert_tidspunkt_neste_ventestatus - registrert_tidspunkt
  when lopenummer = 9999 then cast(current_datetime('Europe/Oslo') as timestamp) - registrert_tidspunkt
  else registrert_tidspunkt_gjeldende_ventestatus - registrert_tidspunkt
end as lengde_lopenummer
from registrerte_tidsstempler
)

select 
beregning_id
,stoppniva_id
,lopenummer
,sts.ventestatus_id
,ventestatus
,ma_handteres_manuelt
,registrert_tidspunkt
,lengde_lopenummer
,round((EXTRACT(HOUR FROM lengde_lopenummer) + (EXTRACT(MINUTE FROM lengde_lopenummer) / 60) + (EXTRACT(SECOND FROM lengde_lopenummer) / 3600)),3) as lengde_antall_timer --antar at ingen intervals har registrert noe større enn timer
from
lengder_stoppstatuser sts
left join {{ ref('int_venteregister_statuskoder_manuell_handtering') }} stn
on sts.ventestatus_id = stn.ventestatus_id