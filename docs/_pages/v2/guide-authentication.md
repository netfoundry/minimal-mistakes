---
permalink: /guides/authentication/
redirect_from:
  - /v2/guides/authentication/
title: "Authentication"
sidebar:
    nav: v2guides
toc: true
classes: wide
---

{% include authentication-steps.md %}

{% include authentication-script.md %}

## Send a Request to the NetFoundry API

Include the token in your request to the NetFoundry API. You could source the shell script above to make `NETFOUNDRY_API_TOKEN` available in the current shell.

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

