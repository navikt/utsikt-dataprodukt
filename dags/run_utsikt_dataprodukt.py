import pendulum
from datetime import datetime
from airflow import DAG
from airflow.models import Variable
from dataverk_airflow import python_operator
from airflow_dbt_operator import dbt_operator

# Hent miljøvariabler
env = Variable.get("ENV")  # "P" for produksjon, "U" for ikke-produksjon

default_args = {
    "owner": "utsikt",
    "description": "utsikt_dataprodukt",
    "depends_on_past": False,
}

with DAG(
    dag_id="utsikt_dataprodukt",
    start_date=datetime(2023, 1, 22, tzinfo=pendulum.timezone("Europe/Oslo")),
    schedule_interval="@daily",
    catchup=False,
    default_args=default_args,
) as dag:
    dbt_source_freshness = dbt_operator(
        dag=dag,
        name="dbt_source_freshness",
        dbt_command="source freshness",
        env=env,
        retries=1,
    )
    run_stoppstatus_snapshot = python_operator(
        dag=dag,
        name="run_stoppstatus_snapshot",
        startup_timeout_seconds=60 * 10,
        repo="navikt/utsikt-dataprodukt",
        script_path="dbt_utsikt/run_stoppstatus_snapshot.py",
        extra_envs={"TARGET_ENV": env},
        retries=1,
        python_version="3.13",
        use_uv_pip_install=True,
        requirements_path="requirements.txt",
    )
    dbt_run = dbt_operator(
        dag=dag,
        name="dbt_run",
        dbt_command="run",
        env=env,
        retries=1,
    )
    dbt_test = dbt_operator(
        dag=dag,
        name="dbt_test",
        dbt_command="test --exclude test_antall_rader_til_snapshot",
        env=env,
        retries=1,
    )

dbt_source_freshness >> run_stoppstatus_snapshot >> dbt_run >> dbt_test
