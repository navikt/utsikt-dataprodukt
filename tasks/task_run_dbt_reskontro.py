import flyte
from nav_union.slack import flyte_task
from task_environments.dbt_reskontro_environment import (
    dbt_reskontro_environment as dbt_environment,
)
from utils.dbt_functions import run_dbt_run_commands

# Trigger
trigger_name = "dbt_reskontro_trigger"
trigger_cron = flyte.Cron("0 6 * * 1-5")
trigger = flyte.Trigger(name=trigger_name, automation=trigger_cron)


@flyte_task(
    task_environment=dbt_environment, channel_name="utsikt-ops", notify_on_failure=True
)
def dbt_reskontro_run():
    return run_dbt_run_commands(commands=["run"])


@dbt_environment.task(entrypoint=True, triggers=trigger)
def run_dbt_reskontro():
    dbt_reskontro_run()
