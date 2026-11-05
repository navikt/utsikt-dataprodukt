import os

import flyte
from nav_union.slack import flyte_task
from task_environments.python_bq_environment import python_bq_environment
from utils.bigquery_connector import BQConnector

trigger_name = "python_bq_environment_trigger"
trigger_cron = flyte.Cron("0 0 * * 0")
trigger = flyte.Trigger(name=trigger_name, automation=trigger_cron)


def get_query(project_id: str) -> str:
    sql = f"""DELETE FROM `{project_id}.venteregister.stoppstatus_snapshot`
    WHERE lastet_tid_kilde <= TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL -730 DAY)"""

    return sql


def get_project_id() -> str:
    target = os.getenv("TARGET_ENV", "dev")
    if target == "prod":
        project_id = "utsikt-prod-2dfe"
    else:
        project_id = "utsikt-dev-3609"

    return project_id


@flyte_task(
    task_environment=python_bq_environment,
    channel_name="utsikt-ops",
    notify_on_failure=True,
)
def task_delete_rows() -> None:
    project_id = get_project_id()
    client = BQConnector(project_id=project_id)
    query = get_query(project_id=project_id)
    client.run_query(query)


@python_bq_environment.task(triggers=trigger, entrypoint=True)
def clean_stoppstatus_snapshot():
    task_delete_rows()
