---
title: Tools
permalink: /v2/tools/
toc: false
---

*Resources for NetFoundry API*

## Demos

Let a demo build you a functioning NetFoundry network and then play with it in [the web console](https://nfconsole.io/login)!

### Before You Begin

These steps apply to both demos.

1. Make sure you have Python3 and `pip3 --version` ([install](https://pip.pypa.io/en/stable/installing/)).
1. Create a working directory like "netfoundry-demo".
1. [Create an API account](/v2/guides/authentication/#get-an-api-account) and save it in the working directory as "credentials.json".
1. In your terminal, change to the working directory e.g. `cd ./netfoundry-demo`.

### Demo 1: Router-hosted Services

[The Python module](https://pypi.org/project/netfoundry/) includes [an executable demo](https://bitbucket.org/netfoundry/python-netfoundry/src/develop/netfoundry/demo.py).

```bash
pip3 install --upgrade netfoundry
python3 -m netfoundry.demo BibbidiBobbidiBoo # choose a name
```

After a few minutes your demo Network will be created and the Services will then become available.

```
WARN: Using the default Network Group: BOOP1256
        waiting for status PROVISIONED or until Tue Nov 17 23:43:05 2020..
    BibbidiBobbidiBoo    :   PROVISIONING    :....................
    BibbidiBobbidiBoo    :    PROVISIONED    :
INFO: Placed Edge Router in Americas (AWS N. Virginia)
INFO: Placed Edge Router in EuropeMiddleEastAfrica (AWS Ireland)
        waiting for status PROVISIONED or until Wed Nov 18 00:19:52 2020..
    AWS Ireland    :    PROVISIONED    :
        waiting for status PROVISIONED or until Wed Nov 18 00:19:52 2020..
  AWS N. Virginia  :    PROVISIONED    :
INFO: created Endpoint dialer1
INFO: created Endpoint dialer2
INFO: created Endpoint dialer3
INFO: created Endpoint exit1
DEBUG: saving OTT for dialer1 in dialer1.jwt
DEBUG: saving OTT for dialer2 in dialer2.jwt
DEBUG: saving OTT for dialer3 in dialer3.jwt
DEBUG: saving OTT for exit1 in exit1.jwt
INFO: created Service Weather Service
INFO: created Service Echo Service
INFO: created AppWAN Welcome
```

* IPv4 echo: [http://echo.netfoundry/](http://echo.netfoundry/) (eth0.me, shows you the real IP from which your HTTP request originated on the internet)
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

You may host private demo servers with Docker on any x86_64 Linux device. Compose will run the `netfoundry/python:demo` container which executes the same Python demo described above. This will create a handful servers that you can access from an enrolled Endpoint.

1. install Compose `pip3 install docker-compose`
1. save this file in your working directory [docker-compose.yml](https://github.com/netfoundry/developer-tools/blob/master/Docker/docker-compose.yml)
1. in a terminal, run `docker-compose up` to create your demo network
1. in the web console, share or scan to enroll additional Endpoints named like "dialerN" to connect to the following demo servers from your laptop, mobile, etc...

After a few minutes your demo Network will be created and these Services will then become available.

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
