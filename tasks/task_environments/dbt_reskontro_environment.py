import flyte

from service_accounts import ServiceAccounts
from secrets import Secret
from default_image import default_image


environment_name = "dbt_reskontro_environment"
service_account = ServiceAccounts.DBT_SA


image_name = "dbt_docs_reskontro_image"
requirements_path = "requirements/requirements_dbt.txt"
dbt_folder_path = "../dbt_reskontro"


# Build image
image = default_image(image_name=image_name,
                      requirements_path=requirements_path,
                      source_folder_path=dbt_folder_path)



# Secrets
secrets: list[flyte.Secret] = [secret.flyte_secret for secret in Secret]

# Task Environment
dbt_reskontro_environment = flyte.TaskEnvironment(
    name=environment_name,
    service_account=service_account,
    secrets=secrets, image=image
)
