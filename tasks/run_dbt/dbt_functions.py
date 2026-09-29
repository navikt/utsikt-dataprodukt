from dbt.cli.main import dbtRunner, dbtRunnerResult

class DuplicatedRowsException(BaseException):
    def __init__(self, msg):
        super().__init__(msg)


def run_dbt_run_commands(commands: list[str]) -> None:
    dbt_base_commands = ["--no-use-colors", "--log-format-file", "json"]
    runner = dbtRunner()
    results: dbtRunnerResult = runner.invoke(args=dbt_base_commands + commands)

    if results.exception:
        raise results.exception

    if not results.success:
        raise Exception(results.result)


def dbt_snapshot_stoppstatus() -> None:
    commands = ["snapshot", "--select", "stoppstatus_snapshot"]
    run_dbt_run_commands(commands=commands)


def dbt_run_int_model() -> None:
    commands = ["run", "--select", "int_min_kombo_til_snapshot", "--quiet"]
    run_dbt_run_commands(commands=commands)


def dbt_test_if_more_rows() -> bool:
    commands = ["test", "--select", "test_antall_rader_til_snapshot"]
    runner = dbtRunner()
    results: dbtRunnerResult = runner.invoke(args=commands)

    if results.exception:
        raise results.exception

    return results.success