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
    schedule_interval="@daily",
    catchup=False,
    default_args=default_args,
) as dag:
    run_stoppstatus_snapshot = python_operator(
        dag=dag,
        name="run_stoppstatus_snapshot",
        startup_timeout_seconds=60 * 10,
        repo="navikt/utsikt-dataprodukt",
        script_path="dbt_utsikt/run_stoppstatus_snapshot.py",
        retries=1,
        python_version="3.13",
        use_uv_pip_install=True,
        requirements_path="requirements.txt",
    )
    run_dbt = python_operator(
        dag=dag,
        name="run_dbt",
        startup_timeout_seconds=60 * 10,
        repo="navikt/utsikt-dataprodukt",
        script_path="dbt_utsikt/dbt_run.py",
        retries=1,
        python_version="3.13",
        use_uv_pip_install=True,
        requirements_path="requirements.txt",
    )

run_stoppstatus_snapshot >> run_dbt
