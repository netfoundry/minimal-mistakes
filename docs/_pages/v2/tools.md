---
title: Tools
permalink: /v2/tools/
toc: false
---

*Resources for NetFoundry API*

## Demo

Docker Compose will run the `netfoundry/python:demo` container which executes `python3 -m netfoundry.demo` which is [an executable demo script](https://bitbucket.org/netfoundry/python-netfoundry/src/develop/netfoundry/demo.py) that is distributed with the Python module. This will create a handful of demo servers that you can connect to from an enrolled Endpoint.

1. create a working directory like "netfoundry-demo"
1. save this file in the directory [docker-compose.yml](https://github.com/netfoundry/developer-tools/blob/master/Docker/docker-compose.yml)
1. create an API account and save it in the same directory named "credentials.json"
1. in a terminal, run `docker-compose up` to create your demo network
1. in the web console, share or scan to enroll additional Endpoints named like "dialerN" to connect to the following demo servers from your laptop, mobile, etc...

    * [http://hello.netfoundry/](http://hello.netfoundry/)
    * [http://speedtest.netfoundry/](http://speedtest.netfoundry/)
    * [http://httpbin.netfoundry/](http://httpbin.netfoundry/)

## Python Module

[Python Package Index module](https://pypi.org/project/netfoundry/)
: Python3 interface to the NetFoundry API

```bash
# if pip is pip3
pip install netfoundry
```

```bash
# else
pip3 install netfoundry
```

## Utilities

* [bulkInviteEndpoints.py](https://github.com/netfoundry/developer-tools/blob/master/bulkInviteEndpoints.py)
: create Endpoints and send the enrollment token to a list of email addresses

* [bulkEditRoleAttributes.py](https://github.com/netfoundry/developer-tools/blob/master/bulkEditRoleAttributes.py)
: replace the role attributes on all Endpoints, Edge Routers, or Services; optionally limited to those that match a pattern
