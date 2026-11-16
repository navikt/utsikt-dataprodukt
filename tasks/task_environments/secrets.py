from enum import Enum

import flyte

class Secret(Enum):
    """
    Representerer en flyte secret som skal mountes inn i et imaget og som eksisterer i Union.

    F.eks.
    [NAVN_PÅ_HEMMELIGHET_I_IMAGE] = [Navn på hemmelighet i Union]
    """
    TARGET_ENV = "TARGET_ENV"
    SLACK_TOKEN = "slack-token"

    @property
    def key(self):
        """
        Navn til hemmeligheten når det blir mounted i imaget
        """
        return self.value

    @property
    def as_env_var(self):
        """
        Hva hemmeligheten i Union. Sjekk union-dashboard for å se hvilke hemmeligheter som finnes
        """
        return self.name

    @property
    def flyte_secret(self):
        return flyte.Secret(key=self.key, as_env_var=self.as_env_var)
