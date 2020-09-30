---
permalink: /v2/guides/authentication/
title: "Authentication"
sidebar:
    nav: v2guides
toc: true
classes: wide
---

{% include authentication-steps.md %}

## Send a Request to the NetFoundry API

Include the expiring bearer token in your request to the NetFoundry API. You could source the shell script above to make `NETFOUNDRY_API_TOKEN` available.

**HTTPie**

```bash
❯ http GET https://gateway.production.netfoundry.io/core/v2/networks \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}"
```

**cURL**

```bash
❯ curl https://gateway.production.netfoundry.io/core/v2/networks \
    --header "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}"
```

{% include authentication-script.md %}
