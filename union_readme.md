# Union
For å sette opp og få tilgang til Union, les NADA sin 
[dokumentasjon](https://docs.knada.io/analyse/union/oppsett/). 

[task](tasks)-mappa innholder python-kode som skal kjøres som en union task, 
python-kode som deklarerer kjøretidsmiljøet til tasker og avhengigheter. 
Hver task burde ha sin egen undermappe, med minst tre filer:

  - **<task_navn>.py** skal inneholde python-kode som skal kjøres.
  - **<task_environment_navn>.py** skal inneholde python-kode som deklarerer kjøretidsmiljøet til tasken.
  - **requirements.txt** inneholder python-avhengigheter

  Slik at 
```
tasks/
├── <task_1>/
│   ├── <task_navn>.py
│   ├── <task_environment_navn>.py
│   └── requirements.txt
│
├── <task_2>/
    ├── <task_navn>.py
    ├── <task_environment_navn>.py
    └── requirements.txt

```

## Tasker og kjøreplan

### dbt-tasken
Tasken i `tasks/run_dbt` kjører source freshness, behandler nye stoppstatusrader for snapshotet, kjører dbt-modellene og tester dem. Den er planlagt til å kjøre mandag til fredag kl. 06:00.

### Opprydding av stoppstatus-snapshot
Tasken i `tasks/clean_stoppstatus_snapshot` sletter rader fra `stoppstatus_snapshot` der `lastet_tid_kilde` er eldre enn 730 dager. Den er planlagt til å kjøre hver søndag kl. 00:00. De andre fakta-tabellene våre er partisjonert med partition_expiration_days=730, men dette går ikke med `stoppstatus_snapshot`, og må derfor settes opp manuelt.

## Lokalt Flyte miljø

Vi bruker [uv](https://docs.astral.sh/uv/getting-started/installation/) for å konfigurere og sette
opp lokalt miljø.

```
uv sync
```
Dette antar at du har uv installert.

For å kunne deploye tasker til union så trenger man en config-fil. Den kan lages ved hjelp av følgende kommando:

```
flyte create config --endpoint union.data.nav.no --org union-nav --project utsikt --domain development --builder remote
```

For å sjekke at alt fungerer som det skal, kjør følgende:
```
flyte get project
```
Du skal få opp en liste med union-prosjekter som du har tilgang til, og du får opp vellykket autentisering i nettleseren.

## Deploy en task til development
1. Naviger deg til der tasken er: `cd tasks/<task_1>`
2. `flyte deploy --all <task_navn>.py`
3. Nå kan du besøke [utsikt union development](https://union.data.nav.no/v2/domain/development/project/utsikt) og sjekke at den har blitt deploya 


