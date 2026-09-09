
from dbt.cli.main import dbtRunner, dbtRunnerResult

dbt = dbtRunner()


result = dbt.invoke()


with DAG(
    dag_id="utsikt_dataprodukt",
    start_date=datetime(2026, 3, 25),
    schedule_interval="0 6 * * 1-5",  # Runs 6am UTC weekdays (7am Oslo time summer and 6am Oslo time winter)
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
        slack_channel="#utsikt-ops",
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