# Feilretting av dbt-løpet
Per i dag har vi én feil som kan forekomme. Observert 3-4 ganger i året

## run_stoppstatus_snapshot feiler med DuplicatedRowsException
Dette betyr at `tidspkt reg` er det samme for mer enn en statusendring i stoppstatus, og skaper problemer for snapshot-logikken, som baserer seg på at `beregnings_id` + `stoppnivaa_id` + `tidspkt_reg` er unikt i tabellen `t_vent_stoppstatus`. Dette skal heller egentlig ikke skje, men vi har observert det.

### Fix
Fix er å er å legge til et mikrosekund på den siste (sjekker lopenr) statusen, sånn at alle statusendringer på samme beregning og stoppnivå får unikt tidspkt_reg. Det er mulig feil status (feil rekkefølge) er allerede lagt inn i stoppstatus_snapshot, og man må slette disse radene. Det er ok å slette alle rader relatert til samme beregnings_id, de blir kopiert inn på nytt når man kjører [run_stoppstatus_snapshot](https://github.com/navikt/utsikt-dataprodukt/blob/egne_dataset/dbt_utsikt/run_stoppstatus_snapshot.py). 

1. Legge til mikrosekund ved å kjøre skriptet [update_tidspkt_reg_stoppstatus](https://github.com/navikt/utsikt-dataprodukt/blob/egne_dataset/queries/update_tidspkt_reg_stoppstatus.sql). Dette ligger også under queries i vårt bq prosjekt.

2. Sjekke hvilken kombinasjon av `beregning_id` og `stoppniva_id` som ikke kan bli 
inserta ved å kjøre 
> SELECT * FROM `utsikt-prod-2dfe.venteregister.int_min_kombo_til_snapshot`

3. Slette rader relatert til disse `beregning_id` og `stoppniva_id`:
> delete from `utsikt-prod-2dfe.venteregister.stoppstatus_snapshot`
where beregning_id = x
and stoppniva_id in (y,z)

4. Kjøre python-scriptet `run_stoppstatus_snapshot` igjen. Fra Airflow kan man trykke `clear` status på den feilende jobben, og den vil kjøre igjen.

