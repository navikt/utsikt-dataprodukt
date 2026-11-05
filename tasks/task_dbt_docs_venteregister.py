import logging

from task_environments.dbt_venteregister_environment import (
    dbt_venteregister_environment,
)
from dbt_functions import run_dbt_run_commands, publish_docs
from nav_union.slack import flyte_task


def generate_dbt_docs():
    commands = ["docs", "generate"]
    run_dbt_run_commands(commands=commands)


def publish_dbt_docs():
    url = "http://dbt.intern.nav.no/docs/utsikt/"
    dbt_project_name = "utsikt-dataprodukt"
    publish_docs(url=url, dbt_project_name=dbt_project_name)


@flyte_task(
    dbt_venteregister_environment, channel_name="utsikt-ops", notify_on_failure=True
)
def generate_and_publish_docs():
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)

    logger.info("Generating docs...")
    generate_dbt_docs()
    logger.info("Publishing docs...")
    publish_dbt_docs()
    logger.info("Done!")


@dbt_venteregister_environment.task(entrypoint=True)
def run_dbt_docs_venteregister():
    generate_and_publish_docs()
