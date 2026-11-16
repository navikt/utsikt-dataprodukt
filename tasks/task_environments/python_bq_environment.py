import flyte

from default_image import default_image
from service_accounts import ServiceAccounts
from secrets import Secret

image_name = "python_bq_image"
requirements_path = "requirements/requirements_python.txt"

image = default_image(image_name=image_name, requirements_path=requirements_path)

environment_name = "python_bq_environment"
service_account = ServiceAccounts.PYTHON_BQ_SA
secrets: list[flyte.Secret] = [Secret.TARGET_ENV.flyte_secret, Secret.SLACK_TOKEN.flyte_secret]

# Task Environment
python_bq_environment = flyte.TaskEnvironment(name=environment_name,
                                              service_account=service_account,
                                              secrets=secrets,
                                              image=image)
