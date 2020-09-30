## Audience

This is aimed at NetFoundry customers and [trial users](https://nfconsole.io/signup) who will use the API directly to augment and automate their use of the NF Console.

## Overview

All authenticated operations require an HTTP header like

```yaml
Authorization: Bearer {NETFOUNDRY_API_TOKEN}
```

where `{NETFOUNDRY_API_TOKEN}` is an expiring JSON Web Token (JWT) that you obtain from Cognito, NetFoundry API's identity provider, by authenticating with your API account.

## Step by Step

### Get a permanent credential

1. [Start a free trial](https://nfconsole.io/signup) if you need a login for NF Console
2. [Log in to NF Console](https://nfconsole.io/login)
3. In NF Console, navigate to "Organization", "Manage API Account", and click <i class="fas fa-plus-circle"></i>
4. Make a note of the three values shown: CLIENT_ID, PASSWORD, OAUTH_URL

### Get a temporary token

Use your permanent credential; `client_id`, `client_secret`; to obtain an expiring `access_token` from the identity provider. Here are examples for `curl` and `http` to get you started.

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

## Shell example

Pull it all together with [HTTPie (command-line HTTP client)](https://httpie.org/) and [`jq` (command-line JSON processor)](https://stedolan.github.io/jq/).

```bash
NETFOUNDRY_CLIENT_ID=1st50d7si3dnu275bck2bd228m
NETFOUNDRY_PASSWORD=1lhfgel7fi048nabt0f74ghckqbj5lsbmqa1g101ud9a935edhv8
NETFOUNDRY_OAUTH_URL=https://netfoundry-sandbox-hnssty.auth.us-east-1.amazoncognito.com/oauth2/token
source export-netfoundry-api-token.bash
```

[download this example](/assets/export-netfoundry-api-token.bash)

{% highlight bash %}
{% include export-netfoundry-api-token.bash %}
{% endhighlight %}

