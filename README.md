# utsikt-dataprodukt
Team utsikt sitt dbt-prosjekt for å transformere data i utbetalingsseksjonen.

Repoet er ikke åpent grunnet underliggende system er en del av kritisk utbetalingsinfrastruktur, og vi refererer til databaseskjemaer og tabellnavn i denne koden.

## Kjøremiljø
For å sette opp et lokalt `.venv`-miljø, kjør kommandoen `uv sync`.

For å kjøre dbt-jobben, kjør `uv run dbt run` fra mappa `dbt_utsikt`.

dbt er satt opp til å bruke oauth som innlogging til bigquery, så man må i tillegg kjøre:

`gcloud auth application-default login`

Airflow (og foreløpig dependabot) krever en `requirements.txt`-fil, og denne kan genereres ved å kjøre 

`toml-to-req --toml-file pyproject.toml`

Her bruker vi pakka [toml-to-requirements](https://pypi.org/project/toml-to-requirements/).

### sqlfluff
Vi bruker pakka [sqlfluff](https://docs.sqlfluff.com/en/stable/index.html) for å formattere sql-koden. For å installere:

`uv add --dev sqlfluff sqlfluff-templater-dbt`

For å linte dbt-modeller, kjør `sqlfluff lint models/`

## Oppdatere pakker
Dependabot støtter enda ikke uv helt, derfor har vi følgende oppskrift dersom man får en pull request av dependabot:
1. Kjøre `uv sync --upgrade`
2. Kjøre `toml-to-req --toml-file pyproject.toml`


## Oppdatere dokumentasjon
Team utsikt har 
[dokumentasjon av dbt-kodebasen](https://dbt.ansatt.nav.no/docs/utsikt/utsikt-dataprodukt/index.html#!/overview) som er autogenerert og interaktiv. For å oppdatere kolonnekommentarer og tabellbeskrivelser må følgende gjøres:

1. Fyll ut kommentarer i filen `docs/comments_custom.yml`
2. Kjør kommando `python docs/generate_comments_from_sql.py`
    Dette er et skript som genererer `.yml`-filer med kommentarer hentet fra `docs/comments_custom.yml` og `docs/comments_source.yml`. Det er viktig at sql-koden til modeller ender med en `final as (`, for det er her kolonnenavnene hentes fra. Creds til Brynjar som har laget dette skriptet.
3. Kjør kommando `dbt docs generate`
4. Kjør kommando `python docs/publish_docs.py` som publiserer docen.

Voilá!

