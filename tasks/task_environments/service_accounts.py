from enum import StrEnum


# Utsikt sine servicebrukere
# er definert her: https://github.com/navikt/utsikt-union/blob/main/union-config-prod.yaml

class ServiceAccounts(StrEnum):
    DBT_SA = "dbt-sa"
    PYTHON_BQ_SA = "python-bq-sa"
