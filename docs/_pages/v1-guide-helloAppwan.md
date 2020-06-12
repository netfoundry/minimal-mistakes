---
title: "Hello, AppWAN"
permalink: /v1/guides/hello-appwan/
sidebar:
    nav: v1guides
tags:
  - hello-appwan
toc: true
---

## Audience

This is for you if you're ready to create a functioning AppWAN. I'll assume you're acquainted with [the foundational concepts](/help#foundational-concepts) and have an API token from Auth0. You can go back to the [authentication guide](/v1/guides/authentication/) if you need to get that token.

RapidAPI subscribers may take the same steps except you will not need to provision a new network.
{: .notice--success}

## Overview

1. Your workspace
1. Create a network.
2. Create a terminating endpoint.
3. Create a service.
4. Create a bridge gateway.
5. Create a client endpoint.
6. Create an empty AppWAN, and add
    1. the client and gateway endpoints and
    2. the service.

## By Example

The result of these request examples is an AppWAN that allows Tunneler to initiate connections to a service. You could substitute any service, even one that is not public.

### Set up Your Workspace

These examples, like those in the [authentication guide](/v1/guides/authentication/), make use of [HTTPie (command-line HTTP client)](https://httpie.org/) and [`jq` (command-line JSON processor)](https://stedolan.github.io/jq/).

If you have your API authentication token assigned to environment variable `NETFOUNDRY_API_TOKEN` then you're ready to go!

### Create Network

**Request**

```bash
❯ http POST https://gateway.production.netfoundry.io/rest/v1/networks \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" \
  name=exampleNetwork11
```

**Response**

```json
{
  "createdAt": "2020-05-27T15:49:23.000+0000",
  "updatedAt": "2020-05-27T15:49:24.000+0000",
  "name": "exampleNetwork11",
  "caName": "CA_de67d725-b63f-4c2f-8c8c-073390cb3bed",
  "productFamily": "ZITI_ENABLED",
  "productVersion": "6.1.1-58266265",
  "provisionedAt": "2020-05-27T15:49:23.000+0000",
  "o365BreakoutCategory": "NONE",
  "mfaClientId": null,
  "mfaIssuerId": null,
  "status": 200,
  "organizationId": "a97cede7-3d24-4d8b-9f42-2396955875d1",
  "ownerIdentityId": "40deb1ba-d18f-4480-9d63-e2c6e7812caf",
  "networkConfigMetadataId": "5df0ee05-2abd-4996-9261-f2da6c4d5c3a",
  "id": "3716d78d-084a-446c-9ac4-5f63ba7b569d",
  "_links": {
    "self": {
      "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d"
    },
    "organization": {
      "href": "https://gateway.production.netfoundry.io/rest/v1/organizations/a97cede7-3d24-4d8b-9f42-2396955875d1"
    },
    "networkControllerHosts": {
      "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/networkControllerHosts"
    },
    "endpoints": {
      "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints"
    },
    "endpointGroups": {
      "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpointGroups"
    },
    "services": {
      "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/services"
    },
    "appWans": {
      "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans"
    },
    "gatewayClusters": {
      "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/gatewayClusters"
    },
    "cas": {
      "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/cas"
    },
    "virtualWanSites": {
      "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/virtualWanSites"
    },
    "networkConfigMetadata": {
      "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/networkConfigMetadata"
    }
  }
}
```

### Terminating Endpoint

The terminating endpoint is a "gateway" type of endpoint. Traffic flows through gateways from clients to services. For the sake of simplicity; you could use a public, hosted endpoint as shown in this example; or you could use `endpointType=VCPEGW` and self-host your own terminating endpoint with [the virtual machine images](https://netfoundry.io/resources/support/downloads/networkversion6/#gateways) that we provide. If you self-host then you'll need to log in as `nfadmin` and run the registration command on your VM using the one-time key that is an attribute of your terminating endpoint like `sudo nfnreg {one time key}`. Here's [an article in our Support Hub](https://support.netfoundry.io/hc/en-us/articles/360016129312-Create-a-NetFoundry-Gateway-VM-on-Your-Own-Equipment) about self-hosted gateway registration.

First-boot registration is automated for all hosted gateways and for some cloud providers when launching a self-hosted gateway through the web console.
{: .notice--info}

#### Terminating Endpoint Request

We need to tell NetFoundry which region is near the service to optimize for performance. This example extracts the ID of "GENERIC Canada East1", and use that ID in the following request to create the endpoint.

```bash
❯ http GET https://gateway.production.netfoundry.io/rest/v1/geoRegions \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" | jq '._embedded.geoRegions[11].id'
"1d824744-0b38-425a-b1d3-6c1dd69def26"
```

We'll use the ID of the network we created in the request path, and the ID of the region in the request body.

```bash
http POST https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" \
name=kbEndTerm26 \
geoRegionId=1d824744-0b38-425a-b1d3-6c1dd69def26 \
endpointType=GW
```

#### Terminating Endpoint Response

```json
{
    "_links": {
        "appWans": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/
4543075e-22e6-46db-a2e5-b934ea1dec19/appWans"
        },
        "dataCenter": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/dataCenters/c3b7e284-a214-701e-0111-c3a7c2b1e280"
        },
        "endpointGroups": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/
4543075e-22e6-46db-a2e5-b934ea1dec19/endpointGroups"
        },
        "geoRegion": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/geoRegions/1d824744-0b38-425a-b1d3-6c1dd69def26"
        },
        "network": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d"
        },
        "self": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/4543075e-22e6-46db-a2e5-b934ea1dec19"
        },
        "services": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/4543075e-22e6-46db-a2e5-b934ea1dec19/services"
        }
    },
    "clientMfaEnable": "NO",
    "clientType": null,
    "clientVersion": null,
    "componentId": null,
    "countryId": null,
    "createdAt": "2020-05-28T16:57:50.000+0000",
    "currentState": 100,
    "dataCenterId": "c3b7e284-a214-701e-0111-c3a7c2b1e280",
    "endpointProtectionRole": null,
    "endpointType": "GW",
    "gatewayClusterId": null,
    "geoRegionId": "1d824744-0b38-425a-b1d3-6c1dd69def26",
    "haEndpointType": null,
    "id": "4543075e-22e6-46db-a2e5-b934ea1dec19",
    "name": "exampleTerminatingEndpoint",
    "networkId": "3716d78d-084a-446c-9ac4-5f63ba7b569d",
    "o365BreakoutNextHopIp": null,
    "ownerIdentityId": "40deb1ba-d18f-4480-9d63-e2c6e7812caf",
    "registrationAttemptsLeft": 5,
    "registrationKey": "22BA32F64BBF27967C872096BAC08C250E872062",
    "sessionIdentityId": null,
    "source": null,
    "stateLastUpdated": "2020-05-28T16:57:50.000+0000",
    "status": 100,
    "syncId": null,
    "updatedAt": "2020-05-28T16:57:52.000+0000"
}
```

### Create Service

This is to describe the server for which you wish to manage access through an AppWAN. The terminating endpoint must have network access to the server.

#### Create Service Request

```bash
❯ http POST https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/services \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" \
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
  endpointId=4543075e-22e6-46db-a2e5-b934ea1dec19
```

#### Create Service Response

```json
{
  "serviceClass" : "CS",
  "serviceInterceptType" : "IP",
  "serviceType" : "TCP",
  "lowLatency" : "YES",
  "dataInterleaving" : "NO",
  "transparency" : "NO",
  "localNetworkGateway" : null,
  "multicast" : "OFF",
  "dnsOptions" : "NONE",
  "icmpTunnel" : "NO",
  "cryptoLevel" : "STRONG",
  "permanentConnection" : "NO",
  "collectionLocation" : "BOTH",
  "pbrType" : "WAN",
  "rateSmoothing" : "NO",
  "networkIp" : "5.9.243.187",
  "networkNetmask" : null,
  "networkFirstPort" : 80,
  "networkLastPort" : 80,
  "interceptIp" : "5.9.243.187",
  "interceptDnsHostname" : "wttr.in",
  "interceptDnsPort" : 80,
  "interceptFirstPort" : 80,
  "interceptLastPort" : 80,
  "gatewayIp" : null,
  "gatewayCidrBlock" : 0,
  "netflowIndex" : 0,
  "profileIndex" : 0,
  "o365Conflict" : false,
  "status" : 100,
  "protectionGroupId" : null,
  "portInterceptMode" : null,
  "endpointId" : "4543075e-22e6-46db-a2e5-b934ea1dec19",
  "gatewayClusterId" : null,
  "networkId" : null,
  "ownerIdentityId" : "b580cd14-6e70-446d-a3a2-1d752bc02726",
  "interceptIncludePorts" : null,
  "interceptExcludePorts" : null,
  "createdAt" : "2020-05-29T21:24:47.923+0000",
  "updatedAt" : "2020-05-29T21:24:47.923+0000",
  "name" : "kbSvc26",
  "interceptPorts" : {
    "include" : [ ],
    "exclude" : [ ]
  },
  "gatewayNetmask" : "",
  "id" : "e4d8fa7b-a94d-4d4a-9bca-54dfd209729a",
  "_links" : {
    "self" : {
      "href" : "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/services/e4d8fa7b-a94d-4d4a-9bca-54dfd209729a"
    },
    "network" : {
      "href" : "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d"
    },
    "appWans" : {
      "href" : "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/services/e4d8fa7b-a94d-4d4a-9bca-54dfd209729a/appWans"
    },
    "endpoint" : {
      "href" : "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/4543075e-22e6-46db-a2e5-b934ea1dec19"
    }
  }
}
```

### Bridge Gateway Endpoint

Ziti clients require a dedicated bridge gateway for each AppWAN. Later we'll add this to the AppWAN along with the Ziti client.

#### Bridge Gateway Endpoint Request

```bash
❯ http POST https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" \
  name=kbBridgeGw27 \
  endpointType=ZTGW \
  geoRegionId=1d824744-0b38-425a-b1d3-6c1dd69def26
```

#### Bridge Gateway Endpoint Response

```json
{
    "_links": {
        "appWans": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/4728677b-ade6-438d-ae52-144d6adbdc88/appWans"
        },
        "dataCenter": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/dataCenters/c3b7e284-a214-701e-0111-c3a7c2b1e280"
        },
        "endpointGroups": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/4728677b-ade6-438d-ae52-144d6adbdc88/endpointGroups"
        },
        "geoRegion": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/geoRegions/1d824744-0b38-425a-b1d3-6c1dd69def26"
        },
        "network": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d"
        },
        "self": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/4728677b-ade6-438d-ae52-144d6adbdc88"
        },
        "services": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/4728677b-ade6-438d-ae52-144d6adbdc88/services"
        }
    },
    "clientMfaEnable": "NO",
    "clientType": null,
    "clientVersion": null,
    "componentId": null,
    "countryId": null,
    "createdAt": "2020-05-29T22:01:36.000+0000",
    "currentState": 100,
    "dataCenterId": "c3b7e284-a214-701e-0111-c3a7c2b1e280",
    "endpointProtectionRole": null,
    "endpointType": "ZTGW",
    "gatewayClusterId": null,
    "geoRegionId": "1d824744-0b38-425a-b1d3-6c1dd69def26",
    "haEndpointType": null,
    "id": "4728677b-ade6-438d-ae52-144d6adbdc88",
    "name": "kbBridgeGw27",
    "networkId": "3716d78d-084a-446c-9ac4-5f63ba7b569d",
    "o365BreakoutNextHopIp": null,
    "ownerIdentityId": "40deb1ba-d18f-4480-9d63-e2c6e7812caf",
    "registrationAttemptsLeft": 5,
    "registrationKey": "C2CF1D7824FF470C47C1D40E0DDA562B1B1B732D",
    "sessionIdentityId": null,
    "source": null,
    "stateLastUpdated": "2020-05-29T22:01:37.000+0000",
    "status": 100,
    "syncId": null,
    "updatedAt": "2020-05-29T22:01:39.000+0000"
}
```

### Client Endpoint

This is your Ziti client. We'll install Tunneler and enroll it with the one-time key provided in the response.

#### Client Endpoint Request

```bash
❯ http POST https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" \
  name=kbZitiCl27 \
  endpointType=ZTCL \
  geoRegionId=1d824744-0b38-425a-b1d3-6c1dd69def26
```

#### Client Endpoint Response

```json
{
    "_links": {
        "appWans": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/ebeaecae-ce3f-4a68-8cb9-01b7eb87124c/appWans"
        },
        "dataCenter": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/dataCenters/c3b7e284-a214-701e-0111-c3a7c2b1e280"
        },
        "endpointGroups": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/ebeaecae-ce3f-4a68-8cb9-01b7eb87124c/endpointGroups"
        },
        "geoRegion": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/geoRegions/1d824744-0b38-425a-b1d3-6c1dd69def26"
        },
        "network": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d"
        },
        "self": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/ebeaecae-ce3f-4a68-8cb9-01b7eb87124c"
        },
        "services": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/ebeaecae-ce3f-4a68-8cb9-01b7eb87124c/services"
        }
    },
    "clientMfaEnable": "NO",
    "clientType": null,
    "clientVersion": null,
    "componentId": null,
    "countryId": null,
    "createdAt": "2020-05-29T22:04:24.000+0000",
    "currentState": 100,
    "dataCenterId": "c3b7e284-a214-701e-0111-c3a7c2b1e280",
    "endpointProtectionRole": null,
    "endpointType": "ZTCL",
    "gatewayClusterId": null,
    "geoRegionId": "1d824744-0b38-425a-b1d3-6c1dd69def26",
    "haEndpointType": null,
    "id": "ebeaecae-ce3f-4a68-8cb9-01b7eb87124c",
    "name": "kbZitiCl27",
    "networkId": "3716d78d-084a-446c-9ac4-5f63ba7b569d",
    "o365BreakoutNextHopIp": null,
    "ownerIdentityId": "40deb1ba-d18f-4480-9d63-e2c6e7812caf",
    "registrationAttemptsLeft": 5,
    "registrationKey": "8D8EDF01C5BFD855C5839488B7B031778BF1E2CE",
    "sessionIdentityId": null,
    "source": null,
    "stateLastUpdated": "2020-05-29T22:04:25.000+0000",
    "status": 100,
    "syncId": null,
    "updatedAt": "2020-05-29T22:04:26.000+0000"
}
```

### Create AppWAN

Initialize an empty AppWAN

#### Create AppWAN Request

```bash
❯ http POST https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" \
  name=kbAppWan27
```

#### Create AppWAN Response

```json
{
    "_links": {
        "endpointGroups": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2/endpointGroups"
        },
        "endpoints": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2/endpoints"
        },
        "network": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d"
        },
        "self": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2"
        },
        "services": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2/services"
        }
    },
    "createdAt": "2020-05-29T22:09:22.583+0000",
    "id": "1c46ae3a-39cf-4ff3-bbbf-243fde329de2",
    "name": "kbAppWan27",
    "networkId": null,
    "ownerIdentityId": "40deb1ba-d18f-4480-9d63-e2c6e7812caf",
    "status": 100,
    "updatedAt": "2020-05-29T22:09:22.583+0000"
}
```

### Update AppWAN Endpoints

Add the client and bridge gateway to the AppWAN.

#### Update AppWAN Endpoints Request

```bash
❯ http POST https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2/endpoints \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" \
  ids:='["ebeaecae-ce3f-4a68-8cb9-01b7eb87124c","4728677b-ade6-438d-ae52-144d6adbdc88"]'
```

#### Update AppWAN Endpoints Response

```json
{
    "_links": {
        "endpointGroups": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2/endpointGroups"
        },
        "endpoints": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2/endpoints"
        },
        "network": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d"
        },
        "self": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2"
        },
        "services": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2/services"
        }
    },
    "createdAt": "2020-05-29T22:09:22.000+0000",
    "id": "1c46ae3a-39cf-4ff3-bbbf-243fde329de2",
    "name": "kbAppWan27",
    "networkId": "3716d78d-084a-446c-9ac4-5f63ba7b569d",
    "ownerIdentityId": "40deb1ba-d18f-4480-9d63-e2c6e7812caf",
    "status": 600,
    "updatedAt": "2020-05-29T22:09:25.000+0000"
}
```

### Update AppWAN Services

Add the service to the AppWAN.

#### Update AppWAN Services Request

```bash
❯ http POST https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2/services \
  "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}" \
  ids:='["e4d8fa7b-a94d-4d4a-9bca-54dfd209729a"]'
```

#### Update AppWAN Services Response

```json
{
    "_links": {
        "endpointGroups": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2/endpointGroups"
        },
        "endpoints": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2/endpoints"
        },
        "network": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d"
        },
        "self": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2"
        },
        "services": {
            "href": "https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/appWans/1c46ae3a-39cf-4ff3-bbbf-243fde329de2/services"
        }
    },
    "createdAt": "2020-05-29T22:29:38.000+0000",
    "id": "1c46ae3a-39cf-4ff3-bbbf-243fde329de2",
    "name": "kbAppWan27",
    "networkId": "3716d78d-084a-446c-9ac4-5f63ba7b569d",
    "ownerIdentityId": "40deb1ba-d18f-4480-9d63-e2c6e7812caf",
    "status": 600,
    "updatedAt": "2020-05-29T22:49:31.000+0000"
}
```

### Ziti LTS

NetFoundry API v1 works with Ziti long-term support (LTS) enroller, tunneler, and endpoint SDKs. These are Ziti v0.5 ingredients.

For Ziti LTS you will need to run Enroller to generate an identity file from the one-time key that is one of the Tunneler's client endpoint attributes, and then you will provide the path to that identity file when running Tunneler.

The following long-term support download links are copied from [the Ziti documentation](https://openziti.github.io/ziti/downloads/overview.html#previous).

#### Ziti Enroller

This is a utility that will securely generate a unique cryptographic identity for Tunneler. Enroller is a portable binary and may be executed where it is downloaded.

{% include ziti-enroller-lts.md %}

```bash
❯ ./ziti-enroller version
0.5.8-2554

❯ http --download --output kbTunneler25.jwt GET \
    https://gateway.production.netfoundry.io/rest/v1/networks/3716d78d-084a-446c-9ac4-5f63ba7b569d/endpoints/4543075e-22e6-46db-a2e5-b934ea1dec19/downloadRegistrationKey \
    "Authorization: Bearer ${NETFOUNDRY_API_TOKEN}"

❯ ./ziti-enroller --jwt kbTunneler25.jwt
```

The method shown above will create a valid JWT file. The JWT file must be created without a newline at EOF and the JWT is on a single line. In the example below note the absence of a `$` character at EOF denoting the trailing newline that is commonly added by ASCII editors if you were to paste the value from the console in a GUI.

```bash
❯ cat -A kbTunneler25.jwt
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbSI6Im90dCIsImV4cCI6MTU5MTQwNzcwMSwiaXNzIjoiaHR0cHM6Ly81NC4xNTYuMjQzLjI6MTA4MCIsImp0aSI6IjhhMDQxN2VhLWE2MDQtMTFlYS1hYWEwLTAyYzhlMjg4Yjg5NSIsInN1YiI6IjE4ZjJkNzhjLTY2MTItNGUzYi1hNjM2LTk5ZGI1MzM4OGRhOSJ9.h10SpFrEfV1IbYeJUZmJ3IcN5ADyyv_7OMaAyLyk-QcTLBmO0pIFoWNhwzc9lyr9KO35-x2pVU8fVaScKE58WavpuPRqjc25n0FAFj47chzy9_v8K7s94j7th31OK29rF3cbmfpoIKHAktUpI7IzZK7QoN21f36afKc8sFI1mN6FlO934ZjGEU9Gvl1UXkZAVWXm6dzfOwe8TpUgBNey71s15StLoQk35SQ3w2yG6oLAR5M0f_QiCU9gJH0DSySdwsPt-USxURHZRtDQHG26TG6GB3olcIr_iwLwoa9G7tLO3yl_NxNpRag4xhVIjzh29OLNeXM0EfELPFsy1zcCUw
```

You could do this in Vi with the following commands.

```vi
:set paste
(press "i" for insert mode and paste the JWT from your clipboard)
(ESC to return to command mode)
:set binary
:set noeol
:wq
```

#### Ziti Tunneler

This is an app NetFoundry built with an LTS version of the [Ziti endpoint SDK](https://ziti.dev/). It will tunnel IP packets to the service via the AppWAN. You could also use any app that you built with a Ziti endpoint SDK. Tunneler is a portable binary and may be executed where it is downloaded.

Tunneler is typically run in one of three modes.

proxy
:  run-as a normal user and listen for the named AppWAN-Service pair on a TCP port >1024. This is the mode used in the example below.

tproxy
:  run-as root and transparently proxy using iptables

tun
:  run-as root and intercept traffic that arrives on a provided tunnel interface

{% include ziti-tunneler-lts.md %}

```bash
❯ ./ziti-tunneler version
0.5.8-2554

❯ ./ziti-tunnel proxy kbAppWan27-kbSvc26:8080 --identity kbTunneler25.json --verbose
```

The effect of this command is for Tunneler to bind to localhost:8080 and begin listening for connections. We'll test this by sending a request to that port along with a `Host` header so that the responding service will know which web site we're asking for.

```bash
❯ http GET http:localhost:8080 "Host: wttr.in"
```
