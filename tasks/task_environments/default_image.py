import flyte

from pathlib import Path

IMAGE_URI = "europe-west1-docker.pkg.dev/nav-data-images-prod/nav-union-images/flyte:3.13-base"
REGISTRY = "europe-west1-docker.pkg.dev/nav-data-images-prod/nav-union-images"
ENV_VARS = {"UV_KEYRING_PROVIDER": "subprocess"}
INDEX_URL =  "https://oauth2accesstoken@europe-west1-python.pkg.dev/nav-data-images-prod/pypi/simple/"


def default_image(image_name: str, requirements_path: str, source_folder_path: str | None = None) -> flyte.Image:

    image = flyte.Image.from_base(image_uri=IMAGE_URI)
    image = image.clone(registry=REGISTRY, name=image_name, extendable=True)
    image = image.with_env_vars(env_vars=ENV_VARS)
    image = image.with_requirements(requirements_path= Path(requirements_path), index_url=INDEX_URL)

    if source_folder_path:
        image = image.with_source_folder(src=Path(source_folder_path), copy_contents_only=True)

    return image
