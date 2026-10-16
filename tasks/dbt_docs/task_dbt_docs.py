from task_environment import dbt_docs_environment
from dbt_functions import run_dbt_run_commands, publish_docs
from slack_functions import flyte_task


@flyte_task(task_environment=dbt_docs_environment, notify_on_failure=True)
def generate_dbt_docs():
    commands = ["docs", "generate"]
    run_dbt_run_commands(commands=commands)


@flyte_task(task_environment=dbt_docs_environment, notify_on_failure=True)
def publish_dbt_docs():
    url = "http://dbt.intern.nav.no/docs/utsikt/"
    dbt_project_name = "utsikt-dataprodukt"
    publish_docs(url=url, dbt_project_name=dbt_project_name)


@dbt_docs_environment.task(entrypoint=True)
def main():
    generate_dbt_docs()
    publish_dbt_docs()
