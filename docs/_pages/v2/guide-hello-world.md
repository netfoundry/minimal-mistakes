---
title: "Hello, World!"
permalink: /v2/guides/hello-world/
sidebar:
    nav: v2guides
toc: true
---

## Audience

This is for you if you're ready to create your first AppWAN with version 2 of the NetFoundry API (`/core/v2`). I'll assume you're acquainted with [the foundational concepts](/help#foundational-concepts) and have an API token from Auth0. You can go back to the [authentication guide](/v1/guides/authentication/) if you need to get that token.

<!-- There's a separate guide for [getting started with RapidAPI](/v1/guides/rapidapi/)
{: .notice--success}
 -->

## By Example

The result of these request examples is an AppWAN that allows Tunneler to initiate connections to a service. You could describe any server in your service definition, even one that is not public as long as the edge router is able to reach the server.

### Set up Your Workspace

These examples, like those in the [authentication guide](/v2/guides/authentication/), make use of [HTTPie (command-line HTTP client)](https://httpie.org/) and [`jq` (command-line JSON processor)](https://stedolan.github.io/jq/).

If you have your API authentication token assigned to environment variable `NETFOUNDRY_API_TOKEN` then you're ready to go!

### Discover Network Configuration ID

```bash
❯ http GET https://gateway.sandbox.netfoundry.io/rest/v1/networkConfigMetadata/ \
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

<!-- TODO update organizations to fixed object reference like networkgroups -->
```bash
❯ http GET https://gateway.sandbox.netfoundry.io/rest/v1/network-groups/ \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" | jq '._embedded.organizations[]|select(.name == "MYGROUP")|{name:.name,id:.id}'
{
  "name": "MYGROUP",
  "id": "4d15ef35-cfa0-4963-a667-5c86d16ce77e"
}
❯ NF_NETWORK_GROUP=4d15ef35-cfa0-4963-a667-5c86d16ce77e
```

### Create a Network

```bash
❯ http POST https://gateway.sandbox.netfoundry.io/rest/v2/networks \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" \
  locationCode="us-west-2" \
  name="kbZtNet14b" \
  networkConfigMetadataId="${NF_CONFIG}" \
  networkGroupId="${NF_NETWORK_GROUP}" | jq .id
"3559807e-617d-4c29-a434-9ea15393a582"
❯ NF_NETWORK=3559807e-617d-4c29-a434-9ea15393a582
```

### Discover an AWS Datacenter ID

```bash
❯ http GET https://gateway.sandbox.netfoundry.io/rest/v1/dataCenters \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" | jq '._embedded.dataCenters[]|select(.provider == "AWS")|{location:.locationCode, id:.id}'
{
  "location": "ca-central-1",
  "id": "c3b7e284-a214-701e-0111-c3a7c2b1e280"
}
❯ NF_SERVICE_DC=c3b7e284-a214-701e-0111-c3a7c2b1e280
```

### Create an Edge Router

```bash
❯ http POST https://gateway.sandbox.netfoundry.io/rest/v2/edge-routers \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" <<EOF | jq .id
{
        "networkId": "${NF_NETWORK}",
        "attributes": [
                "#all"
        ],
        "name": "kbEdge14l",
        "dataCenterId": "${NF_SERVICE_DC}",
        "linkListener": true
}
EOF
"38e52f43-bd70-46f7-b5b3-63b135a6ae2f"
❯ NF_EDGE_ROUTER=38e52f43-bd70-46f7-b5b3-63b135a6ae2f
```

### Edge Router Policy

```bash
❯ http POST https://gateway.sandbox.netfoundry.io/rest/v2/edge-router-policies \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" <<EOF | jq .id
{
        "endpointAttributes": [
                "#all"
        ],
        "edgeRouterAttributes": [
                "#all"
        ],
        "networkId": "${NF_NETWORK}",
        "name": "kbPolicy14b"
}
EOF
"e8a534a1-d4bc-4570-86c0-1288fb2ced65"
❯ NF_POLICY=e8a534a1-d4bc-4570-86c0-1288fb2ced65
```

### Define a Service

```bash
❯ http POST https://gateway.sandbox.netfoundry.io/rest/v2/services \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" <<EOF | jq .id
{
        "attributes": [
                "#all"
        ],
        "edgeRouterAttributes": [

        ],
        "networkId": "${NF_NETWORK}",
        "name": "kbSvc14",
        "egressRouterId": "${NF_EDGE_ROUTER}",
        "clientHostName": "eth0.me",
        "clientPortRange": "80",
        "serverHostName": "eth0.me",
        "serverPortRange": "80"
}
EOF
"d1f6ef84-f979-4a2e-8e8f-b46c0fa1664b"
❯ NF_SERVICE_ID=d1f6ef84-f979-4a2e-8e8f-b46c0fa1664b
❯ NF_SERVICE_NAME=kbSvc14
```

### Create an AppWAN

```bash
❯ http POST https://gateway.sandbox.netfoundry.io/rest/v2/app-wans \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" <<EOF | jq .id
{
        "networkId": "${NF_NETWORK}",
        "serviceAttributes": [
                "#all"
        ],
        "endpointAttributes": [
                "#all"
        ],
        "name": "kbAw14b"
}
EOF
"6085ad2f-4adf-470c-a315-23f30b9aacae"
❯ NF_APPWAN=6085ad2f-4adf-470c-a315-23f30b9aacae
```

### Create a Tunneler Endpoint

```bash
❯ http POST https://gateway.sandbox.netfoundry.io/rest/v2/endpoints \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" <<EOF | jq .id
{
        "networkId": "${NF_NETWORK}",
        "attributes": [
                "#all"
        ],
        "enrollmentMethod": {
                "ott": true
        },
        "name": "kbTunneler14b"
}
EOF
"345a13a6-ef47-42b5-bd45-c6aa2328d52d"
❯ NF_TUNNELER=345a13a6-ef47-42b5-bd45-c6aa2328d52d
```

### Enroll the Tunneler

Enroller a utility that will securely generate a unique cryptographic identity for Tunneler. Enroller is a portable binary and may be executed where it is downloaded.

{% include ziti-enroller.md %}

```bash
❯ ./ziti-enroller version
0.14.9

❯ http GET https://gateway.sandbox.netfoundry.io/rest/v2/endpoints/${NF_TUNNELER} \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" | jq -r '.jwt' > kbTunneler14.jwt

❯ ./ziti-enroller --jwt kbTunneler14.jwt
INFO[0000] generating P-384 key
enrolled successfully. identity file written to: ../kbTunneler14.json
```

### Run Tunneler as a Proxy

Tunneler an app NetFoundry built with the [Ziti endpoint SDK](https://ziti.dev/). It will tunnel IP packets to the service via the AppWAN. You could also use any app that you built with a Ziti endpoint SDK. Tunneler is a portable binary and may be executed where it is downloaded.

Tunneler is typically run in one of three modes.

proxy
:  run-as a normal user and listen for the named AppWAN-Service pair on a TCP port >1024. This is the mode used in the example below.

tproxy
:  run-as root and transparently proxy using iptables

tun
:  run-as root and intercept traffic that arrives on a provided tunnel interface

{% include ziti-tunneler.md %}

```bash
❯ ./ziti-tunneler version
0.14.9

❯ ./ziti/ziti-tunnel proxy --identity kbTunneler14.json ${NF_SERVICE_NAME}:8080
```

The effect of this command is for Tunneler to bind to localhost:8080 and begin listening for connections. We'll test this by sending a request to that port.

```bash
❯ http -b GET localhost:8080
54.153.103.130
```

Where 54.153.103.130 is the public IPv4 of your edge router that terminates the service. The eth0.me server merely echoes back the IP address from which the request originated from the service's network perspective. You can double check that you do receive a different result when you query the eth0.me server directly.

```bash
❯ http -b GET eth0.me
69.234.67.56
```
