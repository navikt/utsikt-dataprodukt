# TO DO

- [ ] Mounte hemmelighet som spesifiserer hvilket prosjekt dbt skal kjøre mot. Se task [run_dbt](/tasks/run_dbt)
- [ ] Dokumentere



# Kjøremiljø for å kjøre dbt lokalt

- installer uv
- opprett en venv ```uv venv```
- installer avhengigheter. De finner du [tasks/run_dbt/requirements.txt](tasks/run_dbt/requirements.txt)
og installerer de slik ```uv pip install -r requirements.txt```
-  For å kjøre dbt lokalt må du stå i mappen [dbt_utsikt](dbt_utsikt) også må du kjøre 
```uv run python ../tasks/run_dbt/task_run_dbt.py```