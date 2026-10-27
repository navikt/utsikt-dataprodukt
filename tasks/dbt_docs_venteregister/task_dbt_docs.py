import logging

from task_environment import dbt_docs_environment
from dbt_functions import run_dbt_run_commands, publish_docs
from slack_functions import flyte_task


def generate_dbt_docs():
    commands = ["docs", "generate"]
    run_dbt_run_commands(commands=commands)


def publish_dbt_docs():
    url = "http://dbt.intern.nav.no/docs/utsikt/"
    dbt_project_name = "utsikt-dataprodukt"
    publish_docs(url=url, dbt_project_name=dbt_project_name)


@flyte_task(dbt_docs_environment, notify_on_failure=True)
def generate_and_publish_docs():
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)

    logger.info("Generating docs...")
    generate_dbt_docs()
    logger.info("Publishing docs...")
    publish_dbt_docs()
    logger.info("Done!")



@dbt_docs_environment.task(entrypoint=True)
def main():
    generate_and_publish_docs()
