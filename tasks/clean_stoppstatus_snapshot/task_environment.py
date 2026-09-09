import flyte

from pathlib import Path

environment_name = "python_bq_environment"
service_account = "python_bq_sa"


image_uri="europe-west1-docker.pkg.dev/nav-data-images-prod/nav-union-images/flyte:3.13-base"
registry= "europe-west1-docker.pkg.dev/nav-data-images-prod/nav-union-images"

env_vars = {"UV_KEYRING_PROVIDER": "subprocess" }

requirements_path = Path("requirements.txt")
index_url = (
            "https://oauth2accesstoken@"
            "europe-west1-python.pkg.dev/nav-data-images-prod/pypi/simple/")


image_name = "python_bq_image"
image = flyte.Image.from_base(image_uri=image_uri).clone(registry=registry, name=image_name, extendable=True)
image = image.with_env_vars(env_vars)
image = image.with_requirements(requirements_path, index_url=index_url)


trigger_name = "python_bq_environment_trigger"
trigger_cron = flyte.Cron("0 0 * * 0")
trigger = flyte.Trigger(name=trigger_name, automation=trigger_cron)

python_bq_environment = flyte.TaskEnvironment(name=environment_name, service_account=service_account, image=image)


