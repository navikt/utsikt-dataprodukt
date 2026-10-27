from flyteplugins.dbt import DbtTask, DbtNodeResult

from task_enviroment import dbt_environment, trigger

dbt_run = DbtTask(
    name="dbt-reskontro-run",
    report=True,
    task_environment=dbt_environment,
)


@dbt_environment.task(entrypoint=True, triggers=trigger)
async def run_dbt_reskontro() -> list[DbtNodeResult]:
    return await dbt_run.aio(command="run")
