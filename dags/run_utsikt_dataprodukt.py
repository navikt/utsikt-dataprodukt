import pendulum
from datetime import datetime
from airflow import DAG
from dataverk_airflow import python_operator

default_args = {
    "owner": "utsikt",
    "description": "utsikt_dataprodukt",
    "depends_on_past": False,
}

with DAG(
    dag_id="utsikt_dataprodukt",
    start_date=datetime(2023, 1, 22, tzinfo=pendulum.timezone("Europe/Oslo")),
    schedule_interval="@once",
    catchup=False,
    default_args=default_args,
) as dag:

    run_dbt = python_operator(
        dag=dag,
        name="filter_kafka",
        startup_timeout_seconds=60 * 10,
        repo="navikt/utsikt_dataprodukt",
        script_path="dbt_utsikt/dbt_run.py",
        retries=1,
    )
