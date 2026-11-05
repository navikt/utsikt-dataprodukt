from pathlib import Path

import flyte
from nav_union.utils import default_image

environment_name = "python_bq_environment"
service_account = "python-bq-sa"

image = default_image()

index_url = (
    "https://oauth2accesstoken@"
    "europe-west1-python.pkg.dev/nav-data-images-prod/pypi/simple/"
)


env_vars = {"UV_KEYRING_PROVIDER": "subprocess"}
image = image.with_env_vars(env_vars)

requirements_path = Path("requirements/requirements_python.txt")
image = image.with_requirements(
    requirements_path,
    index_url=index_url,
)


# Secrets
secret_target_env_key = "TARGET_ENV"
secret_target_env = flyte.Secret(key=secret_target_env_key)

secret_slack_token_key = "slack-token"
secret_slack_token = flyte.Secret(key=secret_slack_token_key, as_env_var="SLACK_TOKEN")

secrets: list[flyte.Secret] = [secret_target_env, secret_slack_token]

# Task Environment
python_bq_environment = flyte.TaskEnvironment(
    name=environment_name, service_account=service_account, secrets=secrets, image=image
)
