{% docs __overview__ %}

# dbt docs for [utsikt_dataprodukt (GitHub-link)](https://github.com/navikt/utsikt_dataprodukt)

Dette er autogenerert dokumentasjon som er ***søkbar og interaktiv***.

Ved spørsmål ta kontakt på Slack i kanalen **`#team-utsikt`**.

På venstresiden er en meny som viser **Sources** og **Projects**.
**Sources** er alle kildene som blir brukt i prosjektet, og viser alle tabeller med tilhørende kolonner som blir brukt.
**Projects**, nærmere bestemt `dbt_utsikt` under **Projects**, viser alle modellene som blir brukt i prosjektet.
I **Projects** kan du navigere til modellene og finne metadata, SQL-kode og avhengigheter til andre modeller.


## Tips til bruk av denne siden

- **Søkefeltet øverst søker på alt** av tabeller, kolonner, modeller og annet. Feks er alle kolonner fra pen-tabeller søkbare.
- **Filtrer ut sources under resources i lineage**, fordi de vises dobbelt som kilde og som staging-modell. Tester kan også filtreres ut.
- **Høyreklikk på en modell** i lineagen for å feks kun vise opp- og nedstrøms modeller fra den modellen.
- **Kopier SQL-kode fra Code/Compiled** i en modell og kjør det rett i databasen.
- **Bruk CTEene som modellene er bygget opp med** for å forstå hvordan modellene henger sammen. Kjør en og en CTE for å se resultatet.

## Lineage

    Trykk på den blå knappen nederst til høyre for å se lineage.
    Lineagen viser dataflyten i prosjektet mellom modellene, som typisk er views. 

Hvis du er inne på en spesifikk modell, så starter lineagen der. 
For å se hele så trykk først på mappen `dbt_utsikt` under **Projects**, og deretter lineage-knappen.


## Modeller i dbt

### Hovedmodellene ligger i mappen `models/`

**Kilder**
  - tabeller som er kilder til modellene, fordelt på ulike skjemaer
  - de fleste kildene er pen-skjematabeller
  - alle kilder er definert i mappen `models/staging/sources.yml` på GitHub

**Staging**
  - modeller som speiler kilder, men kun med kolonner som blir brukt i prosjektet
  - eventuelt med enkle transformasjoner og filtrering

**Intermediate**
  - modeller som gjør mer komplekse transformasjoner, men som er interne
  - deles opp i flere modeller for å gjøre det lettere å forstå og vedlikeholde

**Marts**
  - modeller som er ferdige dataprodukter eller klare for analyse
  - Inneholder både faktatabeller og aggregerte views, men det er foreløpig kun aggregatene i mappen `agg` som deles.

### Andre type modeller

**Tests**
  - tester for å sjekke at dataen er som forventet
  - tester ligger både i mappen `tests/` og er definert i yaml-configen til modeller


{% enddocs %}