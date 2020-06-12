---
permalink: /v1/guides/rapidapi/
title: RapidAPI
sidebar:
    nav: v1guides
toc: true
---

RapidAPI provides code samples for many programming languages for all of the APIs, such as the NetFoundry API, in their marketplace. Some developers find this is an accelerated path to leveraging just one or several of the numerous available APIs in their own application. We're excited about the potential ease of integrating multiple APIs and the ease of onboarding we can offer through this platform.

You may click below to connect through RapidAPI to NetFoundry's API and paste code snippets they provide in your IDE to start building right away. After you subscribe through RapidAPI you'll use [RapidAPI's guides](https://docs.rapidapi.com/) to connect to authenticated and wrap your HTTP requests for the NetFoundry API. Beyond that you'll use the same concepts and order of operations to manage your AppWANs.

As a RapidAPI subscriber you will not need a separate Auth0 login or an account with NetFoundry.
{: .notice--success}

[![RapidAPI Marketplace](/assets/images/connect-on-rapidapi.png)](https://rapidapi.com/netfoundryinc-netfoundryinc-default/api/netfoundryapi)

## Hello, World!

```bash
❯ http GET https://netfoundryapi.p.rapidapi.com/networks \
        x-rapidapi-host:netfoundryapi.p.rapidapi.com \
        x-rapidapi-key:${RAPID_API_KEY} | jq '._embedded.networks[0].id'

"4a566244-d9d6-4a92-b40d-385570cfa3d1"
```

```bash
❯ http GET https://netfoundryapi.p.rapidapi.com/geoRegions \
    x-rapidapi-host:netfoundryapi.p.rapidapi.com \
    x-rapidapi-key:${RAPID_API_KEY} | jq '._embedded.geoRegions[11].id'

"1d824744-0b38-425a-b1d3-6c1dd69def26"
```

```bash
❯ http POST https://netfoundryapi.p.rapidapi.com/networks/4a566244-d9d6-4a92-b40d-385570cfa3d1/endpoints \
    x-rapidapi-host:netfoundryapi.p.rapidapi.com \
    x-rapidapi-key:${RAPID_API_KEY} \
    name=kbEndTerm11 \
    geoRegionId=1d824744-0b38-425a-b1d3-6c1dd69def26 \
    endpointType=GW | jq .id
"588bfd0d-f561-4427-bddd-e7aa9de8883d"
```

```bash
❯ http POST https://netfoundryapi.p.rapidapi.com/networks/4a566244-d9d6-4a92-b40d-385570cfa3d1/services \
    x-rapidapi-host:netfoundryapi.p.rapidapi.com \
    x-rapidapi-key:${RAPID_API_KEY} \
    name=kbSvc26 \
    serviceClass=CS \
    serviceInterceptType=IP \
    serviceType=TCP \
    interceptDnsHostname=wttr.in \
    interceptDnsPort=80 \
    interceptFirstPort=80 \
    interceptLastPort=80 \
    networkIp=5.9.243.187 \
    networkFirstPort=80 \
    networkLastPort=80 \
    interceptIp=5.9.243.187 \
    endpointId=588bfd0d-f561-4427-bddd-e7aa9de8883d | jq .id
"085349ac-aece-4cfc-aacb-2562f87413fb"
```

```bash
❯ http POST https://netfoundryapi.p.rapidapi.com/networks/4a566244-d9d6-4a92-b40d-385570cfa3d1/endpoints \
    x-rapidapi-host:netfoundryapi.p.rapidapi.com \
    x-rapidapi-key:${RAPID_API_KEY} \
    name=kbBridgeGw27 \
    endpointType=ZTGW \
    geoRegionId=1d824744-0b38-425a-b1d3-6c1dd69def26 | jq .id
"6c96b27c-f5eb-4027-aad0-1a9dc5cb176a"
```

```bash
❯ http POST https://netfoundryapi.p.rapidapi.com/networks/4a566244-d9d6-4a92-b40d-385570cfa3d1/endpoints \
    x-rapidapi-host:netfoundryapi.p.rapidapi.com \
    x-rapidapi-key:${RAPID_API_KEY} \
    name=kbZitiCl27 \
    endpointType=ZTCL \
    geoRegionId=1d824744-0b38-425a-b1d3-6c1dd69def26 | jq .id
"09baa7c3-869d-4816-86f0-ef7260ba1648"
```

```bash
❯ http POST https://netfoundryapi.p.rapidapi.com/networks/4a566244-d9d6-4a92-b40d-385570cfa3d1/appWans \
    x-rapidapi-host:netfoundryapi.p.rapidapi.com \
    x-rapidapi-key:${RAPID_API_KEY} \
    name=kbAw11 | jq .id
"a088efef-f7a4-4b9a-b4de-80b6cc4025ee"
```

```bash
❯ http POST https://netfoundryapi.p.rapidapi.com/networks/4a566244-d9d6-4a92-b40d-385570cfa3d1/appWans/a088efef-f7a4-4b9a-b4de-80b6cc4025ee/endpoints \
    x-rapidapi-host:netfoundryapi.p.rapidapi.com \
    x-rapidapi-key:${RAPID_API_KEY} \
    ids:='["6c96b27c-f5eb-4027-aad0-1a9dc5cb176a","09baa7c3-869d-4816-86f0-ef7260ba1648"]'
```

```bash
❯ http POST https://netfoundryapi.p.rapidapi.com/networks/4a566244-d9d6-4a92-b40d-385570cfa3d1/appWans/a088efef-f7a4-4b9a-b4de-80b6cc4025ee/services \
    x-rapidapi-host:netfoundryapi.p.rapidapi.com \
    x-rapidapi-key:${RAPID_API_KEY} \
    ids:='["085349ac-aece-4cfc-aacb-2562f87413fb"]'
```

```bash
❯ http --download --output kbTunneler25.jwt GET \
    https://netfoundryapi.p.rapidapi.com/networks/4a566244-d9d6-4a92-b40d-385570cfa3d1/endpoints/09baa7c3-869d-4816-86f0-ef7260ba1648/downloadRegistrationKey \
    x-rapidapi-host:netfoundryapi.p.rapidapi.com \
    x-rapidapi-key:${RAPID_API_KEY}
```

```bash
❯ ziti-tunnel proxy kbAw11-kbSvc26:8080 --identity kbTunneler25.json --verbose
```
