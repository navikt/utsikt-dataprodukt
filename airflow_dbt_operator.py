from airflow import DAG
from dataverk_airflow import python_operator


def dbt_operator(
    *,
    dag: DAG,
    name: str,
    dbt_command: str,
    env: str,
    repo: str = "navikt/utsikt-dataprodukt",
    slack_channel: str = "#utsikt-ops",
    retries: int = 2,
    branch: str = "main",
    startup_timeout_seconds: int = 60 * 10,
    script_path: str = "dbt_utsikt/dbt_run_airflow.py",
    python_version="3.13",
    use_uv_pip_install=True,
    requirements_path="requirements.txt",
):
    extra_envs = {"dbt_command": dbt_command, "TARGET_ENV": env}
    return python_operator(
        dag=dag,
        name=name,
        repo=repo,
        script_path=script_path,
        slack_channel=slack_channel,
        extra_envs=extra_envs,
        retries=retries,
        branch=branch,
        startup_timeout_seconds=startup_timeout_seconds,
        python_version=python_version,
        requirements_path=requirements_path,
    )
