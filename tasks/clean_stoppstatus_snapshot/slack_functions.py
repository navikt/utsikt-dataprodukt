import requests
import os

from typing import Callable
from flyte import TaskEnvironment
from functools import wraps

def send_slack_notification(message: str) -> None:
    slack_token = os.environ["SLACK_TOKEN"]
    url = "http://slack.com/api/chat.postMessage"
    headers = {"Authorization": f"Bearer {slack_token}", "Content-Type": "application/json"}
    payload = {"channel": "#utsikt-ops", "text": message}

    response = requests.post(url=url, headers=headers, json=payload)
    response.raise_for_status()


def flyte_task(task_environment: TaskEnvironment, notify_on_failure: bool = True):
    def decorator(task: Callable):
        @wraps(task)
        def wrapped():
            try:
                return task()
            except Exception as error_message:
                if notify_on_failure:
                    task_name = task.__name__
                    domain = os.environ["TARGET_ENV"]
                    slack_message = f"❌ {domain}: Feil i  {task_name}! Sjekk logger i Union ❌"
                    send_slack_notification(message=slack_message)

                raise Exception(error_message)

        return task_environment.task(wrapped)

    return decorator
