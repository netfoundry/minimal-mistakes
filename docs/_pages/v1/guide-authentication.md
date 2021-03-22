---
permalink: /v1/guides/authentication/
redirect_to: /guides/authentication/
title: "Authentication"
sidebar:
    nav: v1guides
toc: true
classes: wide
---

{% include authentication-steps.md %}

{% include authentication-script.md %}

### Send a Request to the NetFoundry API

Include the expiring bearer token in your request to the NetFoundry API. You could source the shell script above to make `NETFOUNDRY_API_TOKEN` available in the current shell.

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
