---
title: Monitoring Network Events with NetFoundry and Elasticsearch
tags:
    - devops
    - metrics
    - events
    - monitoring
    - elasticsearch
author: Dan
excerpt: There are several types of metrics, events, and alarms backed by an Elasticsearch database to which requests may be forwarded after authentication by the NetFoundry API.
toc: true
last_updated: July 15, 2019
---

## Monitor for Network Events with the API

There are several types of metrics, events, and alarms backed by an Elasticsearch database to which requests may be forwarded after authentication by the NetFoundry API.

Reference [Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search.html) to know more about the request fields.
{: .notice--info}

This post is based on the [Metrics and Events](https://gateway.production.netfoundry.io/rest/v1/docs/index.html#overview-metrics-and-events) section of the API reference.
{: .notice--info}

Subscribing to events via email is not yet available. [Let us know](/help/) if you're interested in this feature.
{: .notice--warning}

### Endpoint Availability

A NetFoundry network operator may want to observe when client and gateway endpoints' availability changes i.e. online status. To do this the following data returned in the search will be relevant.

The data is retrieved from the underlying network transport with somewhat different nomenclature. This can be translated.

**VTC** represents any endpoint in the NetFoundry network, primarily clients and gateways.

The `commonName` or `resourceName` will help identify the endpoint. This is the meaningful label that was assigned when it was created.

For online/offline status the following can queried:

* `eventDescription`
  * *VTC Offline*
  * *VTC Online*

Example

```json
{
  "eventType": "Status",
  "eventDescription": "VTC Offline",
  "commonName": "Smith-John-Mac2",  
  "resourceName": "Smith-John-Mac2"
}
```

An example query of the network Controller events is shown below. The data for network events can be queried based on time (up to 90 days stored on system), type, specific event, endpoint name.

To obtain notification of new endpoints (clients, gateways) coming online or going offline, software can utilized the API to periodically collect the Events filtered for VTC Offline, VTC Online.

#### Endpoint Status Example

This example requests the return of 10 (note:  "size" : 10, this can be modified to user's choice) network controller raw events from the last 24 hours (Note: "@timestamp" : {"gte" : "now-24h","lte" : "now",) for the customer network id.  This is provided in the url also {organizationId} should be the UUID of the customer organization.

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
              "gte": 1590171786368,
              "lte": 1590776586368,
              "format": "epoch_millis"
            }
          }
        },
        {
          "match_phrase": {
            "organizationId": {
              "query": "a97cede7-3d24-4d8b-9f42-2396955875d1"
            }
          }
        },
        {
          "match_phrase": {
            "networkId": {
              "query": "3716d78d-084a-446c-9ac4-5f63ba7b569d"
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
  "size": 500,
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
{
  "took": 1105,
  "timed_out": false,
  "_shards": {
    "total": 928,
    "successful": 928,
    "skipped": 920,
    "failed": 0
  },
  "hits": {
    "total": 28705,
    "max_score": null,
    "hits": [
      {
        "_index": "ncentityevent-2020.05.29",
        "_type": "doc",
        "_id": "EF6rYXIBGKtgYA9wiJ1m",
        "_score": null,
        "_source": {
          "s3index": "ncentityevent",
          "userId": "uJRoGg8Sv8eiYmT27cVgx4S5L1GJmd3a@clients",
          "identityId": "5272a697-efdc-4555-bfc0-a75ac56f4cca",
          "resourceType": "Service",
          "timestamp": 1590776530535,
          "eventSeverity": "Info",
          "@version": "1",
          "tags": [
            "customer",
            "operations",
            "mopevent",
            "_geoip_lookup_failure"
          ],
          "organizationId": "82d70e3f-deda-469f-be1a-9c40561ede5d",
          "commonName": "GATEWAY-CONSOLE-REDIRECT",
          "type": "ncentityevent",
          "Timestamp": "2020-05-29T18:22:10.543Z",
          "environment": "production",
          "eventDescription": "Service successfully provisioned",
          "resourceId": "66e0b9a9-a55b-4c87-a5bb-b7df3fd25684",
          "networkId": "c2c2398a-69ae-4247-a5d9-5046ddfd270d",
          "eventType": "Active",
          "eventSource": "MOP",
          "target_index": "ncentityevent-2020.05.29",
          "traceId": "2de6492dbbfdcce5",
          "@timestamp": "2020-05-29T18:22:10.623Z"
        },
        "sort": [
          1590776530623
        ]
      },
      {
        "_index": "ncentityevent-2020.05.29",
        "_type": "doc",
        "_id": "3hmrYXIBo_5BICeQijzU",
        "_score": null,
        "_source": {
          "type": "ncentityevent",
          "resourceId": "ee025c34-a9dc-4933-9e78-6648de1e082f",
          "eventSeverity": "Info",
          "target_index": "ncentityevent-2020.05.29",
          "eventType": "Active",
          "identityId": "5272a697-efdc-4555-bfc0-a75ac56f4cca",
          "s3index": "ncentityevent",
          "traceId": "bc53c5fab7d82959",
          "Timestamp": "2020-05-29T18:22:09.886Z",
          "resourceType": "Service",
          "@timestamp": "2020-05-29T18:22:09.975Z",
          "commonName": "GATEWAY-CONSOLE-REDIRECT2",
          "@version": "1",
          "userId": "uJRoGg8Sv8eiYmT27cVgx4S5L1GJmd3a@clients",
          "eventSource": "MOP",
          "tags": [
            "customer",
            "operations",
            "mopevent",
            "_geoip_lookup_failure"
          ],
          "timestamp": 1590776529880,
          "environment": "production",
          "networkId": "c2c2398a-69ae-4247-a5d9-5046ddfd270d",
          "organizationId": "82d70e3f-deda-469f-be1a-9c40561ede5d",
          "eventDescription": "Service successfully provisioned"
        },
        "sort": [
          1590776529975
        ]
      }
    ]
  }
}
```
