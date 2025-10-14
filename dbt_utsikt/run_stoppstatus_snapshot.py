from dbt.cli.main import dbtRunner, dbtRunnerResult


def check_if_more_rows(dbt_runner, cli_args):
    # run the command
    test: dbtRunnerResult = dbt_runner.invoke(cli_args)

    if test.success:
        print(f"test success - det er rader igjen!")
        return True
    else:
        print(f"test failed - ingen flere rader!")
        return False


def run_int_model(dbt_runner, cli_args):
    run: dbtRunnerResult = dbt_runner.invoke(cli_args)
    print("running int model")


def run_snapshot(dbt_runner, cli_args):
    run: dbtRunnerResult = dbt_runner.invoke(cli_args)
    print("running snapshot model")


cli_args_int = ["run", "--select", "int_min_kombo_til_snapshot", "--quiet"]
cli_args_test = ["test", "--select", "test_antall_rader_til_snapshot"]
cli_args_snapshot = ["snapshot", "--select", "stoppstatus_snapshot"]

if __name__ == "__main__":
    dbt_runner = dbtRunner()
    loop_counter = 0
    run_int_model(dbt_runner, cli_args_int)
    is_more_rows = check_if_more_rows(dbt_runner, cli_args_test)
    while is_more_rows and loop_counter <= 10:
        run_snapshot(dbt_runner, cli_args_snapshot)
        run_int_model(dbt_runner, cli_args_int)
        is_more_rows = check_if_more_rows(dbt_runner, cli_args_test)
        loop_counter += 1

    if is_more_rows and loop_counter > 10:
        print("stoppet etter max antall forsøk")
