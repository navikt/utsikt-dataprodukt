# Union
For å sette opp og få tilgang til Union, les NADA sin 
[dokumentasjon](https://docs.knada.io/analyse/union/oppsett/). 

## Projekt struktur
- [dbt_utsikt](dbt_utsikt) innholder et dbt prosjekt som transformerer tabeller i big query. 
For å kjøre dbt kommandoer, må du stå i denne mappen.

- [queries](queries) inneholder nyttige SQL-spørringer.


- [task](tasks) innholder python-kode som skal kjøres som en union task, 
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

## Lokalt miljø


## Deploy en task


