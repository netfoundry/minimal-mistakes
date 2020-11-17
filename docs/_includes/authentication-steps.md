## Audience

This is aimed at NetFoundry customers and [trial users](https://nfconsole.io/signup) who will use the API directly to augment and automate their use of the NF Console.

## Overview

All authenticated operations require an HTTP header like

```yaml
Authorization: Bearer {NETFOUNDRY_API_TOKEN}
```

where `{NETFOUNDRY_API_TOKEN}` is an expiring JSON Web Token (JWT) that you obtain from Cognito, NetFoundry API's identity provider, by authenticating with your API account.

## Get an API Account

1. [Start a free trial](https://nfconsole.io/signup) if you need a login for NF Console
2. [Log in to NF Console](https://nfconsole.io/login)
3. In NF Console, navigate to "Organization", "Manage API Account", and click <i class="fas fa-plus-circle"></i>
4. Click the button to download "credentials.json"
5. Save in one of
    * project default: `./credentials.json`
    * user default: `~/.netfoundry/credentials.json`
    * device default: `/netfoundry/credentials.json`

You may override the default paths with an environment variable.

```bash
NETFOUNDRY_API_ACCOUNT=~/Downloads/example-account.json
```