# Feilretting av dbt-løpet
Per i dag har vi to feil som kan forekomme. Her kommer symtomene og fiksen.

## Duplikater i fak_stoppnivaer gjør at fak_stoppstatus feiler
Dette forekommer pga manuell patching i databasen som endrer en rad i `t_vent_stoppnivaa`, inkludert tidspkt_reg. Dermed får vi duplikat i våre tabeller som gjør at fak_stoppstatus feiler med feilmelding:

> Database Error in model fak_stoppstatus (models/marts/fak/fak_stoppstatus.sql)
UPDATE/MERGE must match at most one source row for each target row

Quick fix er å slette duplikater i `fak_stoppnivaer` og `t_vent_stoppnivaa`. En bedre fix er å endre incremental strategy i `fak_stoppnivaer`.

## tidspkt reg det samme for mer enn en statusendring i stoppstatus
Dette skaper problemer for snapshot-logikken, som baserer seg på at `beregnings_id` + `stoppnivaa_id` + `tidspkt_reg` er unikt i tabellen `t_vent_stoppstatus`. 

Dette skal heller egentlig ikke skje, men vi har observert det. Quick fix er å legge til et mikrosekund på den siste (sjekker lopenr) statusen. Dette kan gjøres ved å kjøre skriptet [update_tidspkt_reg_stoppstatus](https://github.com/navikt/utsikt-dataprodukt/blob/egne_dataset/queries/update_tidspkt_reg_stoppstatus.sql). 

Det er mulig feil status (feil rekkefølge) er allerede lagt inn i stoppstatus_snapshot, så det er mulig man må slette denne raden. Det er ok å slette alle rader relatert til samme beregnings_id, de blir kopiert inn på nytt når man kjører [run_stoppstatus_snapshot](https://github.com/navikt/utsikt-dataprodukt/blob/egne_dataset/dbt_utsikt/run_stoppstatus_snapshot.py)