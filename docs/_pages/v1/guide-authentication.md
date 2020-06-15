---
permalink: /v1/guides/authentication/
title: "Authentication"
sidebar:
    nav: v1guides
toc: true
classes: wide
---

{% include authentication.md %}

### Use the token with an API operation

Include the expiring bearer token in your request to the NetFoundry API. You could source the shell script above to make `NETFOUNDRY_API_TOKEN` available.

**HTTPie**

```bash
❯ http GET https://gateway.production.netfoundry.io/rest/v1/networks \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}"
```

**cURL**

```bash
❯ curl \
    --silent \
    --show-error \
    --request GET \
    --header "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" \
    https://gateway.production.netfoundry.io/rest/v1/networks
```
