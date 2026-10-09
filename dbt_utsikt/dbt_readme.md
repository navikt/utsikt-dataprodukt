## Lokalt oppsett
For å sette opp et lokalt `.venv`-miljø, kjør kommandoen `uv sync`. Aktiver python-miljøet med `source .venv/bin/activate`.

For å kjøre dbt-jobben, kjør `dbt run` fra mappa `dbt_utsikt`.

dbt er satt opp til å bruke oauth som innlogging til bigquery, så man må i tillegg kjøre:

`gcloud auth application-default login`

dbt-target styres av `TARGET_ENV` som er default satt til `dev`

### sqlfluff
Vi bruker pakka [sqlfluff](https://docs.sqlfluff.com/en/stable/index.html) for å formattere sql-koden. For å installere:

`uv add --dev sqlfluff sqlfluff-templater-dbt`

For å linte dbt-modeller, kjør `sqlfluff lint models/`

## Gjøre endringer i dbt-løp
1. Gjør endringer på modeller lokalt
2. Kjør dbt-løpet lokalt og sjekk at det funker. Default target er `dev`. For å kjøre kun modellen du har endret (og avhengigheter før og etter), kan du kjøre:
```
dbt run --select +<modell_navn>+
```
3. Deploy task til Union i `development`. Kan følge [union_readme](../union_readme.md) for oppsett. Spesifikt for å deploye `run_dbt` kan man kjøre:

```
cd tasks/run_dbt
flyte deploy --all task_run_dbt.py
```
4. Push/merge til `main`, da vil github action deploye til prod

5. Dersom man har endret en tabell, må man kjøre full refresh også i prod: 
```
dbt run --select <modell_navn> --target prod --full-refresh
```

## Oppdatere dbt-dokumentasjonen
Se [docs_readme.md](docs/docs_readme.md) for informasjon om hvordan man oppdaterer dokumentasjonen.

## Stoppstatus snapshot
Siden dette er et litt komplisert oppsett, har vi laget en egen [confluence-side](https://confluence.adeo.no/spaces/TOB/pages/780356568/dbt+snapshot+stoppstatus) som dokumenterer dette.

## Feilretting av dbt-løpet
Per i dag har vi én feil som kan forekomme. Observert 3-4 ganger i året

### run_stoppstatus_snapshot feiler med DuplicatedRowsException
Dette betyr at `tidspkt reg` er det samme for mer enn en statusendring i stoppstatus, og skaper problemer for snapshot-logikken, som baserer seg på at `beregnings_id` + `stoppnivaa_id` + `tidspkt_reg` er unikt i tabellen `t_vent_stoppstatus`. Dette skal heller egentlig ikke skje, men vi har observert det.

#### Fix
Fix er å er å legge til et mikrosekund på den siste (sjekker lopenr) statusen, sånn at alle statusendringer på samme beregning og stoppnivå får unikt tidspkt_reg. Det er mulig feil status (feil rekkefølge) er allerede lagt inn i stoppstatus_snapshot, og man må slette disse radene. Det er ok å slette alle rader relatert til samme beregnings_id, de blir kopiert inn på nytt når man kjører task `dbt_run_stoppstatus_snapshot`

1. Legge til mikrosekund ved å kjøre skriptet [update_tidspkt_reg_stoppstatus](../queries/update_tidspkt_reg_stoppstatus.sql). Dette ligger også under queries i vårt bq prosjekt.

2. Sjekke hvilken kombinasjon av `beregning_id` og `stoppniva_id` som ikke kan bli 
inserta ved å kjøre 
> SELECT * FROM `utsikt-prod-2dfe.venteregister.int_min_kombo_til_snapshot`

3. Slette rader relatert til disse `beregning_id` og `stoppniva_id`:
> delete from `utsikt-prod-2dfe.venteregister.stoppstatus_snapshot`
where beregning_id = x
and stoppniva_id in (y,z)

4. Kjøre tasken `dbt_run_stoppstatus_snapshot` igjen fra Union.

