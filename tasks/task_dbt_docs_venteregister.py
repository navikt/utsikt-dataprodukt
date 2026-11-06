import logging

from nav_union.slack import flyte_task
from task_environments.dbt_venteregister_environment import (
    dbt_venteregister_environment,
)
from utils.dbt_functions import publish_docs, run_dbt_run_commands


@flyte_task(
    dbt_venteregister_environment, channel_name="utsikt-ops", notify_on_failure=True
)
def generate_and_publish_docs():
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)

    logger.info("Generating docs...")
    run_dbt_run_commands(commands=["docs", "generate"])

    logger.info("Publishing docs...")
    publish_docs(
        url="http://dbt.intern.nav.no/docs/utsikt/",
        dbt_project_name="dbt_venteregister",
    )

    logger.info("Done!")


@dbt_venteregister_environment.task(entrypoint=True)
def run_dbt_docs_venteregister():
    generate_and_publish_docs()
