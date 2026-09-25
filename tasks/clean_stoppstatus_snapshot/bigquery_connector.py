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
            raise ValueError(
                f"Error: {error}. BigQuery script not valid, check the .sql script!"
            )

    def create_client(self) -> bigquery.Client:
        return bigquery.Client(project=self.project_id)