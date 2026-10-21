from flyteplugins.dbt import DbtTask, DbtNodeResult
from nav_union.slack import flyte_task

from task_enviroment import dbt_environment, trigger

dbt_run = DbtTask(
    name="dbt-reskontro-run",
    report=True,
    task_environment=dbt_environment,
)


@flyte_task(task_environment=dbt_environment, channel_name="utsikt-ops")
async def run_dbt_reskontro() -> list[DbtNodeResult]:
    return await dbt_run.aio(command="run")


@dbt_environment.task(entrypoint=True, triggers=trigger)
def main():
    run_dbt_reskontro()
