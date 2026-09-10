
from dbt.cli.main import dbtRunner, dbtRunnerResult

# cron_string = "0 6 * * 1-5"

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
        raise results.exception

def dbt_snapshot_stoppstatus() -> None:
    commands = ["snapshot","--select", "stoppstatus_snapshot"]
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

    return test.success


def dbt_source_freshness()-> None:
    commands = ["source", "freshness"]
    run_dbt_run_commands(commands=commands)


def dbt_run_stoppstatus_snapshot() -> None:
    counter = 0
    limit = 10

    dbt_run_int_model()

    more_rows = dbt_test_if_more_rows()

    while more_rows and counter < limit:
        dbt_run_stoppstatus_snapshot()
        dbt_run_int_model()
        more_rows = dbt_test_if_more_rows()
        counter += 1

    if more_rows and loop_counter > loop_limit:
        error_message = "Det er fortsatt rader igjen - sjekk duplikat tidspkt_reg. Vurder å kjøre skriptet"
        raise DuplicatedRowsException(error_message)


def dbt_run() -> None:
    commands = ["run"]
    run_dbt_run_commands(commands=commands)


def dbt_test() -> None:
    commands = ["test","--exclude", "test_antall_rader_til_snapshot"]
    run_dbt_run_commands(commands=commands)



def main():
    pass