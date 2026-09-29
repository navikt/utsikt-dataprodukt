import os

from bigquery_connector import BQConnector
from task_environment import python_bq_environment, trigger
from slack_functions import flyte_task


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

@flyte_task(task_environment=python_bq_environment, notify_on_failure=True)
def task_delete_rows() -> None:
    project_id = get_project_id()
    client = BQConnector(project_id=project_id)
    query = get_query(project_id=project_id)
    client.run_query(query)

@python_bq_environment.task(triggers=trigger, entrypoint=True)
def main():
    task_delete_rows()
