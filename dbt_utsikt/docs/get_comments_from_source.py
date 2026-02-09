from pathlib import Path
from yaml import safe_load
from google.cloud import bigquery


def _find_all_sources_from_yml(sources_yml_path):
    """Finds all source tables listed in the specified `sources.yml` file."""
    print("Finner sources.yml fra:", sources_yml_path)
    # project_root = find_project_root(Path(__file__).resolve())
    try:
        with open(sources_yml_path, "r") as file:
            content = file.read()
    except FileNotFoundError:
        raise FileNotFoundError(f"Cannot find YAML file at: {sources_yml_path}")

    yml_raw = safe_load(content)
    schema_list = yml_raw["sources"]
    schema_table_dict = {}  # schema as key, list of table names as value
    for schema in schema_list:
        if schema["name"] != schema["schema"]:
            print("Obs! Verdiene for name og schema er ulike! Se:", schema)
        schema_name = schema["name"]
        tables_name_list = []
        for table in schema["tables"]:
            tables_name_list.append(table["name"])
        schema_table_dict[schema_name] = tables_name_list
    return schema_table_dict


def _get_table_comments_from_bq(
    project_id="utsikt-dev-3609", schema="OS", table="t_vent_beregning"
):
    # Construct a BigQuery client object.
    client = bigquery.Client()

    table_id = project_id + "." + schema + "." + table

    table = client.get_table(table_id)  # Make an API request.

    # View table properties
    print(
        "Got table '{}.{}.{}'.".format(table.project, table.dataset_id, table.table_id)
    )
    # print("Table schema: {}".format(table.schema))
    # print("Table description: {}".format(table.description))
    return [table.description, table.schema]


def _write_to_comments_source(stg_table_descriptions, column_comments_dict):
    # Create `comments_source.yml` containing staging model and column comments
    print("Lager 'comments_source.yml'")
    alle_kommentarer = "{\n    source_table_descriptions: {\n"
    for table, description in stg_table_descriptions.items():
        alle_kommentarer += f"""        {table}: "{description}",\n"""
    alle_kommentarer += "    },\n\n    source_column_comments: {\n"
    for column, comment in column_comments_dict.items():
        alle_kommentarer += f"""        {column}: "{comment}",\n"""

    alle_kommentarer += "    }\n}\n"

    # project_root = find_project_root(Path(__file__).resolve())
    with open("comments_source.yml", "w", encoding="utf-8") as file:
        file.write(alle_kommentarer)
    print("Ferdig!")


def generate_comments_from_bq(sources_yml_path) -> None:
    """
    Reads source tables from `sources.yml`, connects to bigquery, retrieves comments,
    and generates a `comments_source.yml` file for model auto-generation.
    """

    print("Henter tabellbeskrivelser fra BigQuery")
    schema_table_dict = _find_all_sources_from_yml(sources_yml_path)
    stg_table_descriptions = {}  # Comments for staging models
    column_comments_dict = {}
    for schema, table_list in schema_table_dict.items():
        for table in table_list:
            if schema == "OS":
                [source_description, source_schema] = _get_table_comments_from_bq(
                    project_id="utsikt-dev-3609", schema=schema, table=table
                )

                if source_description is None:
                    source_description = "(Ingen modellbeskrivelse i BigQuery)"
                stg_table_descriptions[f"stg_{table}"] = (
                    f"Staging av {schema}.{table}, med original beskrivelse: {source_description}."
                )
                # kolonnekommentarer
                for kolonne in source_schema:
                    column_comments_dict[kolonne.name.lower()] = kolonne.description
    column_comments_dict = dict(sorted(column_comments_dict.items()))

    _write_to_comments_source(stg_table_descriptions, column_comments_dict)


if __name__ == "__main__":

    generate_comments_from_bq(sources_yml_path="../models/staging/sources.yml")
