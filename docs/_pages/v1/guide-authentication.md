---
permalink: /v1/guides/authentication/
title: "Authentication"
sidebar:
    nav: v1guides
toc: true
classes: wide
---

{% include authentication-steps.md %}

### Send a Request to the NetFoundry API

Include the expiring bearer token in your request to the NetFoundry API. You could source the shell script below to make `NETFOUNDRY_API_TOKEN` available.

**HTTPie**

```bash
❯ http GET https://gateway.production.netfoundry.io/rest/v1/networks \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}"
```

**cURL**

```bash
❯ curl https://gateway.production.netfoundry.io/rest/v1/networks \
    --header "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}"
```

{% include authentication-script.md %}
