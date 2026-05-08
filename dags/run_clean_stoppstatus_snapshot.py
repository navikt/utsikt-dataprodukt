from datetime import datetime
from airflow import DAG
from airflow.models import Variable
from dataverk_airflow import python_operator


# Hent miljøvariabler
env = Variable.get("ENV")

default_args = {
    "owner": "utsikt",
    "description": "Clean stoppstatus snapshot",
    "depends_on_past": False,
}

with DAG(
    dag_id="clean_stoppstatus_snapshot",
    default_args=default_args,
    start_date=datetime(2026, 5, 8),
    schedule_interval="@weekly",
    catchup=False
) as dag:
    run_clean_stoppstatus_snapshot = python_operator(
        dag=dag,
        name="clean_stoppstatus_snapshot",
        startup_timeout_seconds=60 * 10,
        repo="navikt/utsikt-dataprodukt",
        script_path="python_scripts/clean_stoppstatus_snapshot.py",
        extra_envs={"TARGET_ENV": env},
        retries=1,
        python_version="3.13",
        use_uv_pip_install=True,
        requirements_path="requirements.txt",
        slack_channel="#utsikt-ops",
    )

run_clean_stoppstatus_snapshot
