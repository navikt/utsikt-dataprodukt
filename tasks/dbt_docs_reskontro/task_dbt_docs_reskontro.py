from flyteplugins.dbt import DbtNodeResult, DbtTask
import os
import requests
import asyncio

from task_environment import dbt_docs_reskontro_environment as dbt_environment


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


dbt_run = DbtTask(
    name="dbt-docs-reskontro",
    report=True,
    task_environment=dbt_environment,
)


@dbt_environment.task(entrypoint=True)
async def run_dbt_docs_reskontro():
    await dbt_run.aio(command="docs generate")
    await asyncio.to_thread(
        publish_docs,
        url="http://dbt.intern.nav.no/docs/utsikt/",
        dbt_project_name="dbt_reskontro",
    )
