import os

from google.cloud import bigquery
from google.api_core.exceptions import BadRequest


class BQConnector:
    def __init__(self, project_id: str):
        self.project_id = project_id
        self.client: bigquery.Client = self.create_client()

    def _execute_query(self, query: str) -> bigquery.QueryJob:
        return self.client.query(query=query)

    def run_query(self, query: str):
        query_job = self._execute_query(query=query)

        try:
            query_job.result()
            stats = query_job.dml_stats
            print(f"Number of rows deleted: {stats.deleted_row_count}")
        except BadRequest as error:
            raise ValueError(f"Error: {error}. BigQuery script not valid, check the .sql script!")

    def create_client(self) -> bigquery.Client:
        return bigquery.Client(project=self.project_id)


def get_query(project_id: str) -> str:
    sql = f"""DELETE FROM `{project_id}.venteregister.stoppstatus_snapshot`
    WHERE lastet_tid_kilde <= TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL -730 DAY)"""

    return sql

def get_project_id() -> str:
    target = os.getenv("TARGET_ENV", "dev")
    if target == "prod":
        project_id = "utsikt-prod-2dfe"
    else:
        project_id = "utsikt-dev-3609"

    return project_id

def main():

    project_id = get_project_id()
    client = BQConnector(project_id=project_id)
    query = get_query(project_id=project_id)
    client.run_query(query)


if __name__ == "__main__":
    main()