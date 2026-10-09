# Oppdatere dokumentasjon
Team utsikt har 
[dokumentasjon av dbt-kodebasen](https://dbt.ansatt.nav.no/docs/utsikt/utsikt-dataprodukt/index.html#!/overview) som er autogenerert og interaktiv. For å oppdatere kolonnekommentarer og tabellbeskrivelser må følgende gjøres:

1. Fyll ut kommentarer i filen `docs/comments_custom.yml`
2. Kjør kommando `python docs/generate_comments_from_sql.py`
    Dette er et skript som genererer `.yml`-filer med kommentarer hentet fra `docs/comments_custom.yml` og `docs/comments_source.yml`. Det er viktig at sql-koden til modeller ender med en `final as (`, for det er her kolonnenavnene hentes fra. Creds til Brynjar som har laget dette skriptet.
3. Kjør kommando `dbt docs generate`
4. Kjør kommando `python docs/publish_docs.py` som publiserer docen.

Voilá!

Det er [landingsside.md](landingsside.md) som angir hva som står på landingssida.

##
Skriptet [find_orphans.py](find_orphans.py) er laget for å kunne kjøre og se om det er noen tabeller i BigQuery som bør slettes.