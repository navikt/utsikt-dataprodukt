import flyte
from flyteplugins.dbt import DbtNodeResult, DbtTask
from task_environments.dbt_reskontro_environment import (
    dbt_reskontro_environment as dbt_environment,
)

# Trigger
trigger_name = "dbt_reskontro_trigger"
trigger_cron = flyte.Cron("0 6 * * 1-5")
trigger = flyte.Trigger(name=trigger_name, automation=trigger_cron)

dbt_run = DbtTask(
    name="dbt-reskontro-run",
    report=True,
    task_environment=dbt_environment,
)


@dbt_environment.task(entrypoint=True, triggers=trigger)
async def run_dbt_reskontro() -> list[DbtNodeResult]:
    return await dbt_run.aio(command="run")
