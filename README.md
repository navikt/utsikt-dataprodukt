# utsikt-dataprodukt
Team utsikt sitt prosjekt for å produsere dataprodukter i utbetalingsseksjonen. [dbt](https://docs.getdbt.com/docs/local/connect-data-platform/bigquery-setup?version=2) er brukt som verktøy for å transformere data i BigQuery, og [union](https://www.union.ai/) er brukt for å skedulere kjøringen av jobber.

## Struktur
- [dbt_utsikt](dbt_utsikt) innholder et dbt prosjekt som transformerer tabeller i BigQuery. 
For å kjøre dbt kommandoer, må du stå i denne mappen. Les mer om denne mappa her: [dbt_readme.md](dbt_utsikt/dbt_readme.md)

- [queries](queries) inneholder nyttige SQL-spørringer.

- [task](tasks) innholder oppsett for å skedulere jobber med Union. Les mer om taskene og Union-oppsettet i [union_readme.md](union_readme.md).

## Henvendelser
Spørsmål knyttet til koden eller repositoryet kan stilles som issues her på GitHub

### For Nav-ansatte
Interne henvendelser kan sendes via Slack i kanalen #team-utsikt.

