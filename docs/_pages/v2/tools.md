---
title: Tools
permalink: /v2/tools/
toc: false
---

*Resources for NetFoundry API*

## Demos

### Before You Begin

These steps apply to both demos

1. create a working directory like "netfoundry-demo"
1. [create an API account](/v2/guides/authentication/#get-an-api-account) and save it in the working directory as "credentials.json"
1. in your terminal, change directory to the working directory

### Demo 1: Router-hosted Services

[The Python module](https://pypi.org/project/netfoundry/) includes [an executable demo](https://bitbucket.org/netfoundry/python-netfoundry/src/develop/netfoundry/demo.py).

```bash
pip3 install --upgrade netfoundry
python3 -m netfoundry.demo BibbidiBobbidiBoo
```

Public Services

* IPv4 echo: [http://echo.netfoundry/](http://echo.netfoundry/) (eth0.me)
* ASCII Art Weather: [http://weather.netfoundry/](http://weather.netfoundry/) (wttr.in)


```bash
# HTTPie
http GET http://weather.netfoundry "Host: wttr.in"
```

```bash
# cURL
curl http://weather.netfoundry --header "Host: wttr.in"
```

### Demo 2: Endpoint-hosted Services

Alternatively, you may host private demo servers with Docker. Docker Compose will run the `netfoundry/python:demo` container which executes the same Python demo described above and will additionally create a handful of private demo servers that you can connect to from an enrolled Endpoint.

1. save this file in your working directory [docker-compose.yml](https://github.com/netfoundry/developer-tools/blob/master/Docker/docker-compose.yml)
1. in a terminal, run `docker-compose up` to create your demo network
1. in the web console, share or scan to enroll additional Endpoints named like "dialerN" to connect to the following demo servers from your laptop, mobile, etc...

Private Services
* Hello, World! Splash: [http://hello.netfoundry/](http://hello.netfoundry/) (netfoundry/railz)
* OpenSpeedTest: [http://speedtest.netfoundry/](http://speedtest.netfoundry/) (mlabbe/openspeedtest)
* REST: [http://httpbin.netfoundry/](http://httpbin.netfoundry/) (kennethreitz/httpbin)

## Python Module

[Python Package Index module](https://pypi.org/project/netfoundry/)
: Python3 interface to the NetFoundry API

```bash
pip install netfoundry
```

## Utilities

* [bulkInviteEndpoints.py](https://github.com/netfoundry/developer-tools/blob/master/bulkInviteEndpoints.py)
: create Endpoints and send the enrollment token to a list of email addresses

* [bulkEditRoleAttributes.py](https://github.com/netfoundry/developer-tools/blob/master/bulkEditRoleAttributes.py)
: replace the role attributes on all Endpoints, Edge Routers, or Services; optionally limited to those that match a pattern
