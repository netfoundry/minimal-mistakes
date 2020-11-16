---
title: Tools
permalink: /v2/tools/
toc: false
---

*Resources for NetFoundry API*

## Unboxing Demo for Docker

1. create a working directory like "netfoundry-demo"
1. save this file in the directory [docker-compose.yml](https://github.com/netfoundry/developer-tools/blob/master/Docker/docker-compose.yml)
1. create an API account and save it in the same directory as credentials.json
1. in a terminal, run `docker-compose up` to create your demo network
1. in the web console, share or scan to enroll additional Endpoints named like "dialerN" to connect to the following demo servers from your laptop, mobile, etc...

    * http://hello.netfoundry/
    * http://speedtest.netfoundry/
    * http://httpbin.netfoundry/


## Scripts

* [bulkInviteEndpoints.py](https://github.com/netfoundry/developer-tools/blob/master/bulkInviteEndpoints.py)
: create Endpoints and send the enrollment token to a list of email addresses

* [bulkEditRoleAttributes.py](https://github.com/netfoundry/developer-tools/blob/master/bulkEditRoleAttributes.py)
: replace the role attributes on all Endpoints, Edge Routers, or Services; optionally limited to those that match a pattern

## Python

[Python Package Index module](https://pypi.org/project/netfoundry/)
: Python3 interface to the NetFoundry API

```bash
pip install netfoundry
```

