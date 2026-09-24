import requests
import os

from typing import Callable


def send_slack_notification(message: str) -> None:
    slack_token = os.environ["SLACK_TOKEN"]
    url = "http://slack.com/api/chat.postMessage"
    headers = {"Authorization": f"Bearer {slack_token}", "Content-Type": "application/json"}
    payload = {"channel": "#utsikt-ops", "text": message}

    response = requests.post(url=url, headers=headers, json=payload)
    response.raise_for_status()


def slack_notification_on_fail(task: Callable ):
    def wrapper():
        try:
            task()
        except Exception as error_message:
            task_name = task.__name__
            domain = os.environ["TARGET_ENV"]
            slack_message = f"❌ {domain}: Feil i  {task_name}! Sjekk logger i Union ❌"
            send_slack_notification(message=slack_message)
            raise Exception(error_message)

        return wrapper