# Find orphaned tables
import json
from google.cloud import bigquery

# Get dbt models
with open("target/manifest.json") as f:
    manifest = json.load(f)
    dbt_models = {
        node["name"]
        for node in manifest["nodes"].values()
        if node["resource_type"] in ("model", "snapshot")
    }

# Get BigQuery tables
# client = bigquery.Client(project="utsikt-dev-3609")
client = bigquery.Client(project="utsikt-prod-2dfe")
dataset_id = "venteregister"
tables = client.list_tables(dataset_id)
bq_tables = {table.table_id for table in tables}

# Find orphans
orphaned = bq_tables - dbt_models
print(f"Orphaned tables: {orphaned}")
