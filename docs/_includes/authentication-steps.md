## Audience

This is aimed at NetFoundry customers and [trial users](https://nfconsole.io/signup) who will use the API directly to augment and automate their use of the NF Console.

## Overview

All authenticated operations require an HTTP header like

```yaml
Authorization: Bearer {NETFOUNDRY_API_TOKEN}
```

where `{NETFOUNDRY_API_TOKEN}` is an expiring JSON Web Token (JWT) that you obtain from Cognito, NetFoundry API's identity provider, by authenticating with your API account.

## Step by Step

### Get an API Account

1. [Start a free trial](https://nfconsole.io/signup) if you need a login for NF Console
2. [Log in to NF Console](https://nfconsole.io/login)
3. In NF Console, navigate to "Organization", "Manage API Account", and click <i class="fas fa-plus-circle"></i>
4. Make a note of the three values shown: CLIENT_ID, PASSWORD, OAUTH_URL

### Get an Access Token

Use your API account (`clientId`, `password`, `authenticationUrl`) to obtain a temporary `access_token` from the identity provider. Here are examples for HTTPie and cURL to get you started.

**HTTPie**

```bash
❯ http --form --auth "${NETFOUNDRY_CLIENT_ID}:${NETFOUNDRY_PASSWORD}" \
    POST $NETFOUNDRY_OAUTH_URL \
    "scope=https://gateway.production.netfoundry.io//ignore-scope" \
    "grant_type=client_credentials"
```

**cURL**

```bash
❯ curl --user ${NETFOUNDRY_CLIENT_ID}:${NETFOUNDRY_PASSWORD} \
    --request POST $NETFOUNDRY_OAUTH_URL \
    --header 'content-type: application/x-www-form-urlencoded' \
    --data 'grant_type=client_credentials&scope=https%3A%2F%2Fgateway.sandbox.netfoundry.io%2F%2Fignore-scope'
```
