import os

from google.cloud import bigquery
from google.api_core.exceptions import BadRequest


class BQConnector:
    def __init__(self):
        self.client: bigquery.Client = self._create_client()

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

    @staticmethod
    def _create_client() -> bigquery.Client:
        return bigquery.Client()


def get_query(target: str) -> str:
    if target == "prod":
        project =  "utsikt-prod-2dfe"
    else:
        project = "utsikt-dev-3609"
    sql = f"""DELETE FROM `{project}.venteregister.stoppstatus_snapshot`
    WHERE lastet_tid_kilde <= TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL -730 DAY)"""

    return sql

def main():
    client = BQConnector()
    query = get_query(target=os.getenv("TARGET_ENV", "dev"))
    client.run_query(query)


if __name__ == "__main__":
    main()