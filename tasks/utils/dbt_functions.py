import os

import requests
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


def publish_docs(url: str, dbt_project_name: str):
    url = url + dbt_project_name
    file_paths = ["target/manifest.json", "target/catalog.json", "target/index.html"]

    multipart_form_data = {}

    for file_path in file_paths:
        file_content = read_docs_file(path=file_path)
        file_name = os.path.basename(file_path)

        multipart_form_data[file_name] = (file_name, file_content)

    res = requests.put(url, files=multipart_form_data)
    res.raise_for_status()


def read_docs_file(path: str) -> bytes:
    with open(path, "rb") as file:
        content = file.read()
    return content
