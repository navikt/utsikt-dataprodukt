# utsikt-dataprodukt
Team utsikt sitt dbt-prosjekt for å transformere data i utbetalingsseksjonen.

Repoet er ikke åpent grunnet underliggende system er en del av kritisk utbetalingsinfrastruktur, og vi refererer til databaseskjemaer og tabellnavn i denne koden.

## Kjøremiljø
For å sette opp et lokalt `.venv`-miljø, kjør kommandoen `uv sync`.

For å kjøre dbt-jobben, kjør `uv run dbt run` fra mappa `dbt_utsikt`.

dbt er satt opp til å bruke oauth som innlogging til bigquery, så man må i tillegg kjøre:

`gcloud auth application-default login`

Airflow (og foreløpig dependabot) krever en `requirements.txt`-fil, og denne kan genereres ved å kjøre 

`uv pip compile pyproject.toml -o requirements.txt`

## Oppdatere pakker
Dependabot støtter enda ikke uv helt, derfor har vi følgende oppskrift dersom man får en pull request av dependabot:
1. Kjøre `uv sync --upgrade`
2. Slette `requirements.txt`-filen
3. Kjøre `uv pip compile pyproject.toml -o requirements.txt`


## dokumentasjon
For å oppdatere dokumentasjon, kjør først:
`uv run dbt docs generate`. 

Så kan man kjøre skriptet `publish_docs.py`

[dokumentasjon av dbt-kodebasen](https://dbt.ansatt.nav.no/docs/utsikt/utsikt-dataprodukt/index.html#!/overview)