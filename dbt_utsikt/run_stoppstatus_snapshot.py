from dbt.cli.main import dbtRunner, dbtRunnerResult


class DuplicatedRowsException(BaseException):
    def __init__(self, msg):
        return super().__init__(msg)


def check_if_more_rows(dbt_runner):
    cli_args_test = ["test", "--select", "test_antall_rader_til_snapshot"]
    # run the command
    test: dbtRunnerResult = dbt_runner.invoke(cli_args_test)

    if test.success:
        print("test success - det er rader igjen!")
        return True
    else:
        print("test failed - ingen flere rader!")
        return False


def run_int_model(dbt_runner):
    cli_args_int = ["run", "--select", "int_min_kombo_til_snapshot", "--quiet"]
    dbt_runner.invoke(cli_args_int)
    print("running int model")


def run_snapshot(dbt_runner):
    cli_args_snapshot = ["snapshot", "--select", "stoppstatus_snapshot"]
    dbt_runner.invoke(cli_args_snapshot)
    print("running snapshot model")


if __name__ == "__main__":
    dbt_runner = dbtRunner()
    loop_counter = 0
    loop_limit = 10
    run_int_model(dbt_runner)
    is_more_rows = check_if_more_rows(dbt_runner)
    while is_more_rows and loop_counter <= loop_limit:
        run_snapshot(dbt_runner)
        run_int_model(dbt_runner)
        is_more_rows = check_if_more_rows(dbt_runner)
        loop_counter += 1

    if is_more_rows and loop_counter > loop_limit:
        raise DuplicatedRowsException(
            "Det er fortsatt rader igjen - sjekk duplikat tidspkt_reg. Vurder å kjøre skriptet"
        )
