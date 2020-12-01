---
title: "Hello, World!"
permalink: /guides/hello-world/
redirect_from:
  - /v2/guides/hello-world/
sidebar:
    nav: v2guides
toc: true
classes: wide
---

This guides you step by step to create an AppWAN with HTTP requests.

## Audience

This is for you if you're ready to create your first AppWAN with version 2 of the NetFoundry API (`/core/v2`). I'll assume you're acquainted with [the foundational concepts](/help#foundational-concepts) and have an API token from the identity provider. You can go back to the [authentication guide](/v1/guides/authentication/) if you need to get that token.

<!-- There's a separate guide for [getting started with RapidAPI](/v1/guides/rapidapi/)
{: .notice--success}
 -->

## By Example

The result of these request examples is an AppWAN that allows Tunneler to initiate connections to a service. You could describe any server in your service definition, even one that is not public as long as the edge router is able to reach the server.

### Set up Your Workspace

These examples, like those in the [authentication guide](/v2/guides/authentication/), make use of [HTTPie (command-line HTTP client)](https://httpie.org/) and [`jq` (command-line JSON processor)](https://stedolan.github.io/jq/).

If you have your API authentication token assigned to environment variable `NETFOUNDRY_API_TOKEN` then you're ready to go!

### Discover Network Configuration ID

This is a simplistic sizing of your network's components. Use "small" for cost-conscious testing, "medium" for nominal performance.

```bash
❯ http GET https://gateway.production.netfoundry.io/rest/v1/networkConfigMetadata/ \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" | jq '._embedded.networkConfigMetadatas[]|{name:.name,id:.id}'
{
  "name": "small",
  "id": "2616da5c-4441-4c3d-a9a2-ed37262f2ef4"
}
{
  "name": "medium",
  "id": "5df0ee05-2abd-4996-9261-f2da6c4d5c3a"
}
❯ NF_CONFIG=2616da5c-4441-4c3d-a9a2-ed37262f2ef4
```

### Discover Network Group ID

A network group organizes your NetFoundry networks for billing and permissions. You need to know the network group ID in order to create a network. This example filters for a particular group by name. In most cases there will be only one group in the list of results.

<!-- TODO update organizations to fixed object reference like networkgroups -->
```bash
❯ http GET https://gateway.production.netfoundry.io/rest/v1/network-groups/ \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" | jq '._embedded.organizations[]|select(.name == "MYGROUP")|{name:.name,id:.id}'
{
  "name": "MYGROUP",
  "id": "4d15ef35-cfa0-4963-a667-5c86d16ce77e"
}
❯ NF_NETWORK_GROUP=4d15ef35-cfa0-4963-a667-5c86d16ce77e
```

### Create a Network

This will provision the dedicated compute infrastructure of your NetFoundry network. The value of `locationCode` determines the AWS region in which your controller node is located. It is not crucial to home the controller near your clients or services for performance reasons, but you may have other reasons for preferring or avoiding a particular geographic region.

```bash
❯ http POST https://gateway.production.netfoundry.io/core/v2/networks \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" \
  locationCode="us-west-2" \
  name="exampleNetwork" \
  networkConfigMetadataId="${NF_CONFIG}" \
  networkGroupId="${NF_NETWORK_GROUP}" | jq .id
"3559807e-617d-4c29-a434-9ea15393a582"
❯ NF_NETWORK=3559807e-617d-4c29-a434-9ea15393a582
```

### Create an Edge Router

At this time edge routers must be homed in an AWS datacenter if hosted by NetFoundry. You can also self-host an edge router by enrolling an installation of `ziti-router` with your network. In the NetFoundry platform, a datacenter is a cloud-provider-specific geographic region which is in the case of AWS a region with multiple availability zones.

```bash
❯ http GET https://gateway.production.netfoundry.io/rest/v1/dataCenters \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" | jq '._embedded.dataCenters[]|select(.provider == "AWS")|{location:.locationCode, id:.id}'
{
  "location": "ca-central-1",
  "id": "c3b7e284-a214-701e-0111-c3a7c2b1e280"
}
❯ NF_SERVICE_DC=c3b7e284-a214-701e-0111-c3a7c2b1e280
```

```bash
❯ http POST https://gateway.production.netfoundry.io/core/v2/edge-routers \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" <<EOF | jq .id
{
        "networkId": "${NF_NETWORK}",
        "attributes": [
                "#all"
        ],
        "name": "exampleEdgeRouter",
        "dataCenterId": "${NF_SERVICE_DC}",
        "linkListener": true
}
EOF
"38e52f43-bd70-46f7-b5b3-63b135a6ae2f"
❯ NF_EDGE_ROUTER=38e52f43-bd70-46f7-b5b3-63b135a6ae2f
```

### Edge Router Policy

Authorize endpoints with matching `endpointAttributes` to dial via edge routers to which this policy is applied in `edgeRouterAttributes`.

```bash
❯ http POST https://gateway.production.netfoundry.io/core/v2/edge-router-policies \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" <<EOF | jq .id
{
        "endpointAttributes": [
                "#all"
        ],
        "edgeRouterAttributes": [
                "#all"
        ],
        "networkId": "${NF_NETWORK}",
        "name": "exampleEdgeRouterPolicy"
}
EOF
"e8a534a1-d4bc-4570-86c0-1288fb2ced65"
❯ NF_POLICY=e8a534a1-d4bc-4570-86c0-1288fb2ced65
```

### Define a Service

Describe a server. Endpoints will be authorized to access this service if they have matching tags in `attributes`.

```bash
❯ http POST https://gateway.production.netfoundry.io/core/v2/services \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" <<EOF | jq .id
{
        "attributes": [
                "#all"
        ],
        "edgeRouterAttributes": [

        ],
        "networkId": "${NF_NETWORK}",
        "name": "exampleService",
        "egressRouterId": "${NF_EDGE_ROUTER}",
        "clientHostName": "eth0.me",
        "clientPortRange": "80",
        "serverHostName": "eth0.me",
        "serverPortRange": "80"
}
EOF
"d1f6ef84-f979-4a2e-8e8f-b46c0fa1664b"
❯ NF_SERVICE_ID=d1f6ef84-f979-4a2e-8e8f-b46c0fa1664b
❯ NF_SERVICE_NAME="exampleService"
```

### Create an AppWAN

Authorize endpoints with matching tags in `endpointAttributes` to access services with matching tags in `serviceAttributes`.

```bash
❯ http POST https://gateway.production.netfoundry.io/core/v2/app-wans \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" <<EOF | jq .id
{
        "networkId": "${NF_NETWORK}",
        "serviceAttributes": [
                "#all"
        ],
        "endpointAttributes": [
                "#all"
        ],
        "name": "exampleAppWAN"
}
EOF
"6085ad2f-4adf-470c-a315-23f30b9aacae"
❯ NF_APPWAN=6085ad2f-4adf-470c-a315-23f30b9aacae
```

### Create a Tunneler Endpoint

The tags in `attributes` are used to authorize this endpoint to access services with matching tags via edge routers with matching tags.

```bash
❯ http POST https://gateway.production.netfoundry.io/core/v2/endpoints \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" <<EOF | jq .id
{
        "networkId": "${NF_NETWORK}",
        "attributes": [
                "#all"
        ],
        "enrollmentMethod": {
                "ott": true
        },
        "name": "exampleTunneler"
}
EOF
"345a13a6-ef47-42b5-bd45-c6aa2328d52d"
❯ NF_TUNNELER=345a13a6-ef47-42b5-bd45-c6aa2328d52d
```

### Enroll the Tunneler

`enroll` is a subcommand of `ziti-tunnel` that will generate a permanent cryptographic identity for this install of Tunneler. NetFoundry calls this an "Endpoint". Here is [a helpful article about enrolling Tunneler](https://support.netfoundry.io/hc/en-us/articles/360045177311-How-to-Enroll-Tunneler) if you would like a bit more context.

```bash
❯ ./ziti-tunnel version
0.15.2

❯ http GET https://gateway.production.netfoundry.io/core/v2/endpoints/${NF_TUNNELER} \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" | jq -r '.jwt' > exampleTunneler.jwt

❯ ./ziti-tunnel enroll --jwt exampleTunneler.jwt
INFO[0000] generating P-384 key
enrolled successfully. identity file written to: exampleTunneler.json
```

### Run Tunneler as a Proxy

Tunneler is an app that NetFoundry built with the [Ziti endpoint SDK](https://ziti.dev/). It will tunnel IP packets to the service across your AppWAN and provides a simple proxy mode that will work well for this exercise because it is a portable binary and may be run right where it is downloaded. You could also use any app that you built with a Ziti endpoint SDK, or any of [the client apps here](https://netfoundry.io/resources/support/downloads/networkversion7/#zititunnelers).

{% include ziti-tunneler.md %}

```bash
❯ ./ziti-tunneler version
0.15.2

❯ ./ziti/ziti-tunnel proxy --identity exampleTunneler.json "${NF_SERVICE_NAME}":8080
```

The effect of this command is for Tunneler to bind to localhost:8080 and begin listening for connections. We'll test this by sending a request to that port.

```bash
❯ http -b GET localhost:8080
54.153.103.130
```

Where 54.153.103.130 is the public IPv4 of your edge router that terminates the service. The eth0.me server merely echoes back the IP address from which the request originated. You can double check that you do receive a different result when you query the eth0.me server directly via your own public IP.

```bash
❯ http -b GET eth0.me
69.234.67.56
```
