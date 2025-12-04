import os
import time
from dbt.cli.main import dbtRunner, dbtRunnerResult
import logging


def dbt_run_airflow(dbt_command) -> None:
    """Funksjon for å kjøre dbt i en Airflow DAG."""
    # henter dbt-kommando fra DAGen. Default er 'build'
    # eks på dbt_command i DAG er: 'build --select tag:daglig'
    # dbt_command = os.environ.get("dbt_command", 'build')
    logging.info(f"Kjører dbt med kommando 'dbt {dbt_command}'. Først litt oppsett...")
    dbt_command = dbt_command.split(" ")

    # setter opp miljøvariabler
    os.environ["TZ"] = "Europe/Oslo"
    time.tzset()  # OBS! Denne linja funker ikke på windows

    # lager en dbtRunner
    dbt = dbtRunner()

    # kjører den gitte dbt-kommandoen, som også gir live logging
    output: dbtRunnerResult = dbt.invoke(dbt_command)

    # etter kjørt dbt-kommando håndterer vi eventuell feil
    # exit code 2, feil utenfor DBT
    if output.success:
        logging.info("dbt kjørt ok")


if __name__ == "__main__":
    dbt_command = os.environ.get("dbt_command", "run --select fak_beregninger")
    dbt_run_airflow(dbt_command)
