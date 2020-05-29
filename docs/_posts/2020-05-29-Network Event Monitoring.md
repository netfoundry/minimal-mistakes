---
title: Monitoring Network Events with NetFoundry and Elasticsearch
tags:
    - devops
    - metrics
    - events
    - monitoring
    - elasticsearch
author: Dan
excerpt: There are several types of metrics, events, and alarms. The data is hosted in an Elasticsearch database to which requests may be forwarded via the API.
toc: true
last_updated: July 15, 2019
---

## Monitor for Network Events with the API

There are several types of metrics, events, and alarms backed by an Elasticsearch database to which requests may be forwarded via the NetFoundry API.

Reference the [Elasticsearch API documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search.html)
{: .notice--info}

The relevant section of the API reference is [Metrics and Events](https://gateway.production.netfoundry.io/rest/v1/docs/index.html#overview-metrics-and-events).
{: .notice--info}

Subscribing to events via email is not yet available. [Let us know](/help/) if you're interested in this feature.
{: .notice--warning}

### Endpoint Availability

A NetFoundry Network Administrator may want to observe when client and gateway endpoints' availability changes i.e. online status. To do this the following data returned in the search will be relevant.

The data is retrieved from the underlying Network Transport technology with somewhat different nomenclature. This can be translated.

VTC represents any endpoint in the NetFoundry Network (Endpoint, either Netfoundry Client or Netfoundry Gateway, or Netfoundry Transfer Nodes and Session Controllers).

The commonName or resourceName will help identify the actual named Endpoint as it is assigned in console or API for Endpoint creation.

For online/offline status the following can be searched for after doing a query. Or if specific items are required, the query can utilize one or more of these search criteria.

eventDescription values: VTC Offline, VTC Online

Some items of note that are useful to retrieve for VTC Online, VTC Offline

"eventType": "Status",

"eventDescription": "VTC Offline",

"commonName": "Smith-John-Mac2",  
"resourceName": "Smith-John-Mac2",

An example query of the Network Controller events is shown below. Note: the request is a POST with Authentication via the NetFoundry API bearer token.

The data for network events can be queried based on time (up to 90 days stored on system), type, specific event, endpoint name.

To obtain notification of new endpoints (clients, gateways) coming online or going offline, software can utilized the API to periodically collect the Events filtered for VTC Offline, VTC Online.  Then they can be sent to a notification system (message, email) for processing.

#### Endpoint Status Example

This example requests the return of 10 (note:  "size" : 10, this can be modified to user's choice) Network controller raw events from the last 24 hours (Note: "@timestamp" : {"gte" : "now-24h","lte" : "now",) for the customer network id.  This is provided in the url also {organizationId} should be the UUID of the customer organization.

`POST /rest/v1/elastic/ncentityevent/82d70e3f-deda-469f-be1a-9c40561ede5d/_search/`

```http
"Content-Type": "application/json"
"Authorization": "Bearer ${NETFOUNDRY_API_TOKEN}"
```

```json
{
  "query": {
    "bool": {
      "must": [
        {
          "query_string": {
            "query": "*",
            "analyze_wildcard": true
          }
        },
        {
          "match_phrase": {
            "tags.keyword": {
              "query": "customer"
            }
          }
        },
        {
          "range": {
            "@timestamp": {
              "gte": "now-24h",
              "lte": "now",
              "format": "epoch_millis"
            }
          }
        },
        {
          "match_phrase": {
            "networkId": {
              "query": "c2c2398a-69ae-4247-a5d9-5046ddfd270d"
            }
          }
        }
      ],
      "must_not": [
        {
          "match_phrase": {
            "changeType": {
              "query": "soft"
            }
          }
        }
      ]
    }
  },
  "size": 10,
  "sort": [
    {
      "@timestamp": {
        "order": "desc",
        "unmapped_type": "boolean"
      }
    }
  ],
  "_source": {
    "excludes": [

    ]
  }
}
```

Example response:

```json

```
