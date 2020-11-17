## Get a Token in the Current Shell

Conveniently use your API account in a shell with this script.

```bash
# get an API token with the default API account ~/.netfoundry/credentials.json
❯ source ./export-netfoundry-api-token.bash
```

```bash
# or override the default credentials file to use a different API account
❯ NETFOUNDRY_API_ACCOUNT=~/Downloads/example-account.json \
    source ./export-netfoundry-api-token.bash
```

### Get the Script 

[download](/assets/export-netfoundry-api-token.bash){: .btn .btn--info .btn--x-large}

<details>
<summary>Preview</summary>

{% highlight bash %}
{% include export-netfoundry-api-token.bash %}
{% endhighlight %}

</details>  

### Command-line Examples

These show how the script above obtains the token. Use your API account (`clientId`, `password`, `authenticationUrl`) to obtain a temporary `access_token` from the identity provider. Here are examples for HTTPie and cURL to get you started.

```bash
NETFOUNDRY_CLIENT_ID=3tcm6to3qqfu78juj9huppk9g3
NETFOUNDRY_PASSWORD=149a7ksfj3t5lstg0pesun69m1l4k91d6h8m779l43q0ekekr782
NETFOUNDRY_OAUTH_URL=https://netfoundry-production-xfjiye.auth.us-east-1.amazoncognito.com/oauth2/token
```

**HTTPie**

```bash
❯ http --form --auth "${NETFOUNDRY_CLIENT_ID}:${NETFOUNDRY_PASSWORD}" \
    POST ${NETFOUNDRY_OAUTH_URL} \
    "scope=https://gateway.production.netfoundry.io//ignore-scope" \
    "grant_type=client_credentials"
```

**cURL**

```bash
❯ curl --user ${NETFOUNDRY_CLIENT_ID}:${NETFOUNDRY_PASSWORD} \
    --request POST ${NETFOUNDRY_OAUTH_URL} \
    --header 'content-type: application/x-www-form-urlencoded' \
    --data 'grant_type=client_credentials&scope=https%3A%2F%2Fgateway.production.netfoundry.io%2F%2Fignore-scope'
```
