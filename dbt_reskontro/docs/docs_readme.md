# Oppdatere dokumentasjon
Team utsikt har 
[dokumentasjon av dbt-kodebasen](https://dbt.ansatt.nav.no/docs/utsikt) som er autogenerert og interaktiv. For å oppdatere kolonnekommentarer og tabellbeskrivelser må følgende gjøres:

1. Fyll ut kommentarer i filen `docs/comments_custom.yml`
2. Kjør kommando `python docs/generate_comments_from_sql.py`
    Dette er et skript som genererer `.yml`-filer med kommentarer hentet fra `docs/comments_custom.yml` og `docs/comments_source.yml`. Det er viktig at sql-koden til modeller ender med en `final as (`, for det er her kolonnenavnene hentes fra. Creds til Brynjar som har laget dette skriptet.

De siste to stegene blir kjørt i egen union task når man oppdaterer dbt_reskontro og pusher til main:
3. `dbt docs generate`
4. `python docs/publish_docs.py` som publiserer docen.

Voilá!

Det er [landingsside.md](landingsside.md) som angir hva som står på landingssida.