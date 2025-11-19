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
    project_id="utsikt-dev-3609", schema="OS_Q2", table="t_vent_beregning"
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


def get_table_comments_from_oracle(schema_name: str, table_name: str):
    """Retrieves the table comment from an Oracle database for a specified schema and table.

    This function queries the Oracle database to fetch the comment associated with a particular table
    within a given schema. It removes any single or double quotes from the comment to avoid potential
    issues with text formatting.

    Args:
        schema_name (str): The name of the schema where the table is located.
        table_name (str): The name of the table for which the comment is to be retrieved.

    Returns:
        str: The comment associated with the specified table. Returns an empty string if no comment is found.

    Examples:
        Suppose you have a schema named 'HR' and a table named 'EMPLOYEES'. If the comment for the table
        is 'Employee records with personal details.', the function call would be:

        >>> get_table_comments_from_oracle('HR', 'EMPLOYEES')
        'Employee records with personal details.'

        If there is no comment for the specified table, the function would return an empty string:

        >>> get_table_comments_from_oracle('HR', 'UNKNOWN_TABLE')
        ''
    """
    sql = f"""select comments from all_tab_comments
            where owner = upper('{schema_name}') and table_name = upper('{table_name}')"""
    sql_result = db_read_to_df(sql, secret_dict)
    if sql_result.empty or sql_result.iloc[0, 0] is None:
        return ""
    else:
        # Removing quotes as they cause problems later
        return sql_result.iloc[0, 0].replace("'", "").replace('"', "")


def get_column_comments_from_oracle(schema_name: str, table_name: str):
    """Retrieves all column comments for a specified table in an Oracle database schema.

    This function queries the Oracle database to fetch comments for each column in the specified table.
    It processes the comments to remove any single or double quotes and ensures that any missing comments
    are represented as empty strings.

    Args:
        schema_name (str): The name of the schema where the table is located.
        table_name (str): The name of the table for which column comments are to be retrieved.

    Returns:
        df_col_comments (dict): A dictionary containing two columns:
            - 'column_name': The name of each column in lowercase.
            - 'comments': The comment associated with each column, with quotes removed and missing comments replaced with empty strings.

    Examples:
        Suppose you have a schema named 'HR' and a table named 'EMPLOYEES'. If the table has comments for the columns 'ID' and 'NAME', the function call would return a DataFrame like:

        >>> get_column_comments_from_oracle('HR', 'EMPLOYEES')
        column_name                     comments
        0         id  'Employee ID, used as primary key'
        1       name           'Name of the employee'

        If the table has no comments or the columns are not documented, the DataFrame would have empty strings for comments:

        >>> get_column_comments_from_oracle('HR', 'UNKNOWN_TABLE')
        column_name comments
        0         id
        1       name
    """
    sql = f"""select column_name, comments from dba_col_comments
            where owner = upper('{schema_name}') and table_name = upper('{table_name}')"""
    df_col_comments = db_read_to_df(sql, secret_dict)
    df_col_comments["column_name"] = df_col_comments["column_name"].str.lower()
    df_col_comments["comments"] = (
        df_col_comments["comments"].str.replace("'", "").str.replace('"', "")
    )
    df_col_comments["comments"] = df_col_comments["comments"].fillna("")
    return df_col_comments


def get_comments_from_bq(
    sources_yml_path="../dbt_utsikt/models/staging/sources.yml",
) -> None:
    """
    Reads source tables from `sources.yml`, connects to bigquery, retrieves comments,
    and generates a `comments_source.yml` file for model auto-generation.
    """

    print("Henter tabellbeskrivelser fra BigQuery")
    schema_table_dict = _find_all_sources_from_yml(
        sources_yml_path="../models/staging/sources.yml"
    )
    stg_table_descriptions = {}  # Comments for staging models
    for schema, table_list in schema_table_dict.items():
        for table in table_list:
            source_description = _get_table_comments_from_bq(
                project_id="utsikt-dev-3609", schema=schema, table=table
            )[0]

            if source_description is None:
                source_description = "(Ingen modellbeskrivelse i BigQuery)"
            stg_table_descriptions[f"stg_{table}"] = (
                f"Staging av {schema}.{table}, med original beskrivelse: {source_description}."
            )

    # Fill in the dictionary with unique column comments
    print("Henter kolonnekommentarer fra BigQuery")
    column_comments_dict = {}
    for schema, table_list in schema_table_dict.items():
        for table in table_list:
            df_table_columns_comments = get_column_comments_from_oracle(schema, table)
            for _, row in df_table_columns_comments.iterrows():
                # Get unique column comments
                column = row["column_name"]
                comment = row["comments"]
                if column not in column_comments_dict:
                    column_comments_dict[column] = comment.replace("\n", " | ")
    column_comments_dict = dict(sorted(column_comments_dict.items()))

    # Create `comments_source.yml` containing staging model and column comments
    print("Lager 'comments_source.yml'")
    alle_kommentarer = "{\n    source_column_comments: {\n"
    for column, comment in column_comments_dict.items():
        alle_kommentarer += f"""        {column}: "{comment}",\n"""
    alle_kommentarer += "    },\n\n    source_table_descriptions: {\n"
    for table, description in stg_table_descriptions.items():
        alle_kommentarer += f"""        {table}: "{description}",\n"""
    alle_kommentarer += "    }\n}\n"

    project_root = find_project_root(Path(__file__).resolve())
    with open(
        project_root / "dbt/docs/comments_source.yml", "w", encoding="utf-8"
    ) as file:
        file.write(alle_kommentarer)
    print("Ferdig!")


if __name__ == "__main__":

    schema_table_dict = _find_all_sources_from_yml(
        sources_yml_path="../models/staging/sources.yml"
    )
    stg_table_descriptions = {}  # Comments for staging models
    for schema, table_list in schema_table_dict.items():
        for table in table_list:
            source_description = _get_table_comments_from_bq(
                project_id="utsikt-dev-3609", schema=schema, table=table
            )[0]

            if source_description is None:
                source_description = "(Ingen modellbeskrivelse i BigQuery)"
            stg_table_descriptions[f"stg_{table}"] = (
                f"Staging av {schema}.{table}, med original beskrivelse: {source_description}."
            )

    print(stg_table_descriptions)
    column_comments_dict = {}
    print("Lager 'comments_source.yml'")
    alle_kommentarer = "{\n    source_column_comments: {\n"
    for column, comment in column_comments_dict.items():
        alle_kommentarer += f"""        {column}: "{comment}",\n"""
    alle_kommentarer += "    },\n\n    source_table_descriptions: {\n"
    for table, description in stg_table_descriptions.items():
        alle_kommentarer += f"""        {table}: "{description}",\n"""
    alle_kommentarer += "    }\n}\n"

    # project_root = find_project_root(Path(__file__).resolve())
    with open("comments_source.yml", "w", encoding="utf-8") as file:
        file.write(alle_kommentarer)
    print("Ferdig!")
