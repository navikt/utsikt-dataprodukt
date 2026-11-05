import flyte
from nav_union.slack import flyte_task
from task_environments.dbt_venteregister_environment import (
    dbt_venteregister_environment as dbt_environment,
)
from utils import dbt_functions

# Trigger
trigger_name = "dbt_venteregister_environment_trigger"
trigger_cron = flyte.Cron("0 6 * * 1-5")
trigger = flyte.Trigger(name=trigger_name, automation=trigger_cron)


@flyte_task(
    task_environment=dbt_environment, channel_name="utsikt-ops", notify_on_failure=True
)
def dbt_source_freshness() -> None:
    commands = ["source", "freshness"]
    dbt_functions.run_dbt_run_commands(commands=commands)


@flyte_task(
    task_environment=dbt_environment, channel_name="utsikt-ops", notify_on_failure=True
)
def dbt_run_stoppstatus_snapshot() -> None:
    counter = 0
    limit = 9

    dbt_functions.dbt_run_int_model()
    more_rows = dbt_functions.dbt_test_if_more_rows()

    while more_rows and counter < limit:
        dbt_functions.dbt_snapshot_stoppstatus()
        dbt_functions.dbt_run_int_model()
        more_rows = dbt_functions.dbt_test_if_more_rows()
        counter += 1

        if more_rows and counter > limit:
            error_message = "Det er fortsatt rader igjen - sjekk duplikat tidspkt_reg. Vurder å kjøre skriptet"
            raise dbt_functions.DuplicatedRowsException(error_message)


@flyte_task(
    task_environment=dbt_environment, channel_name="utsikt-ops", notify_on_failure=True
)
def dbt_run() -> None:
    commands = ["run"]
    dbt_functions.run_dbt_run_commands(commands=commands)


@flyte_task(
    task_environment=dbt_environment, channel_name="utsikt-ops", notify_on_failure=True
)
def dbt_test() -> None:
    commands = ["test", "--exclude", "test_antall_rader_til_snapshot"]
    dbt_functions.run_dbt_run_commands(commands=commands)


@dbt_environment.task(entrypoint=True, triggers=trigger)
def run_dbt_venteregister():
    dbt_source_freshness()
    dbt_run_stoppstatus_snapshot()
    dbt_run()
    dbt_test()
