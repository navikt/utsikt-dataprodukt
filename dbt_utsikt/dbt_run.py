from dbt.cli.main import dbtRunner, dbtRunnerResult

# initialize
dbt = dbtRunner()

# create CLI args as a list of strings
cli_args1 = ["run", "--select", "+antall_beregninger_per_faggruppe_per_dag"]
cli_args2 = ["run", "--select", "+antall_beregninger_per_fagomrade_per_dag"]
cli_args3 = ["run", "--select", "+antall_beregninger_per_ventestatus_per_dag"]

if __name__ == "__main__":
    res1: dbtRunnerResult = dbt.invoke(cli_args1)
    res2: dbtRunnerResult = dbt.invoke(cli_args2)
    res3: dbtRunnerResult = dbt.invoke(cli_args3)
