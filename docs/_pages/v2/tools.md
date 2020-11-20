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

1. Create a working directory like "netfoundry-demo".
1. [Create an API account](/v2/guides/authentication/#get-an-api-account) and save it in the working directory as "credentials.json". You only need the JSON file for this exercise.

### Demo: Router-hosted Services

[The Python module](https://pypi.org/project/netfoundry/) includes [an executable demo](https://bitbucket.org/netfoundry/python-netfoundry/src/develop/netfoundry/demo.py).

#### Run Demo with Docker

Make sure you have Docker Engine ([install](https://docs.docker.com/engine/install/)).

```bash
cd ./netfoundry-demo
docker run --rm -it -v $PWD:/netfoundry -e NETWORK_NAME=BibbidiBobbidiBoo netfoundry/python:demo
```

#### Run Demo with Python

Make sure you have Python3 and `pip3 --version` ([install](https://pip.pypa.io/en/stable/installing/)).

```bash
cd ./netfoundry-demo
pip3 install --upgrade netfoundry
python3 -m json.tool ./credentials.json                # display the API account credentials
python3 -m netfoundry.demo --network BibbidiBobbidiBoo # choose a name
```

After a few minutes your demo Network will be created and the Services will then become available.

```log
WARN: Using the default Network Group: BOOPTASTIC
        waiting for status PROVISIONED or until Tue Nov 17 23:43:05 2020..
    BibbidiBobbidiBoo    :   PROVISIONING    :....................
    BibbidiBobbidiBoo    :    PROVISIONED    :
INFO: Placed Edge Router in Americas (AWS Oregon)
INFO: Placed Edge Router in EuropeMiddleEastAfrica (AWS Stockholm)
        waiting for status PROVISIONED or until Wed Nov 18 09:25:10 2020..
    AWS Oregon     :        NEW        :.....
    AWS Oregon     :   PROVISIONING    :...........................
    AWS Oregon     :    PROVISIONED    :
        waiting for status PROVISIONED or until Wed Nov 18 09:30:05 2020..
   AWS Stockholm   :        NEW        :..
   AWS Stockholm   :   PROVISIONING    :........................
   AWS Stockholm   :    PROVISIONED    :
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

### Demo: Endpoint-hosted Services

You may host private demo servers with Docker on any x86_64 Linux device. Compose will run the `netfoundry/python:demo` container which executes the same Python demo described above. Additionally, this will create a handful private servers that you can access from an enrolled Endpoint.

#### Run Demo with Docker Compose

1. In your terminal, change to the working directory.

    ```bash
    cd ./netfoundry-demo
    ```

1. Install Compose.

    ```bash
    pip3 install docker-compose
    ```

1. Save this file in your working directory [docker-compose.yml](https://raw.githubusercontent.com/netfoundry/developer-tools/master/Docker/docker-compose.yml).
1. In a terminal, run Compose to create your demo Network.

    ```bash
    NETWORK_NAME=BibbidiBobbidiBoo docker-compose up --detach
    ```

1. Follow the demo's progress in the Compose log.

    ```bash
    docker-compose logs --follow builder
    ```

1. In the web console, share or scan to enroll additional Endpoints named like "dialerN" to connect to the following demo servers from your laptop, mobile, etc...

After a few minutes your demo Network will be created and these Services will then become available.

* Hello, World! Splash: [http://hello.netfoundry/](http://hello.netfoundry/) (netfoundry/railz)
* REST Test: [http://httpbin.netfoundry/](http://httpbin.netfoundry/) (kennethreitz/httpbin)

#### Troubleshooting Docker Compose

If the private Services are unavailable and the dialer log shows "no terminators" the likely cause is that the exit container has not yet started hosting the Services that were just created. The solution is to wait a few minutes or run `docker-compose restart exit`.

## Python Module

[Python Package Index module](https://pypi.org/project/netfoundry/)
: Python3 interface to the NetFoundry API

```bash
pip install netfoundry
```

### Create a Custom Docker Container with the NetFoundry Python Module

```docker
FROM netfoundry/python
COPY ./my-netfoundry-network.py .
CMD ./my-netfoundry-network.py
```

## Utilities

* [bulkInviteEndpoints.py](https://github.com/netfoundry/developer-tools/blob/master/bulkInviteEndpoints.py)
: create Endpoints and send the enrollment token to a list of email addresses

* [bulkEditRoleAttributes.py](https://github.com/netfoundry/developer-tools/blob/master/bulkEditRoleAttributes.py)
: replace the role attributes on all Endpoints, Edge Routers, or Services; optionally limited to those that match a pattern
