---
title: Tools
permalink: /tools/
redirect_from:
    - /v2/tools/
toc: false
---

*Resources for NetFoundry API*

## Demos

Let a demo build you a functioning NetFoundry network and then play with it in [the web console](https://nfconsole.io/login)!

### Before You Begin

1. Create a working directory like "netfoundry-demo".
1. [Create an API account](/v2/guides/authentication/#get-an-api-account) and save it in the working directory as "credentials.json". You only need the JSON file for this exercise.

### Demo: A Basic Network with Docker

Make sure you have Docker Engine ([install](https://docs.docker.com/engine/install/)).

```bash
cd ./netfoundry-demo
docker run --rm -it -v $PWD:/netfoundry netfoundry/python:demo
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
INFO: created Service Weather Service
INFO: created Service Echo Service
INFO: created AppWAN Welcome
```

Enroll an Endpoint to demonstrate accessing a public demo server with an invented domain name. You could add the one-time-token .jwt file to Ziti Desktop Edge running on your laptop or you could visit [the web console](https://nfconsole.io/login) to scan the identity QR code with Ziti Mobile Edge.

* Fireworks: [http://fireworks.netfoundry/](http://fireworks.netfoundry) Touch or click to shoot off some fireworks.
* IPv4 echo: [http://echo.netfoundry/](http://echo.netfoundry/) (eth0.me, shows you the IP from which your HTTP request originated on the internet)

#### More Control with Python

You have access to more parameters when running [the demo script](https://bitbucket.org/netfoundry/python-netfoundry/src/develop/netfoundry/demo.py) directly. Make sure you have `pip3 --version` ([install](https://pip.pypa.io/en/stable/installing/)).

```bash
cd ./netfoundry-demo
pip3 install --upgrade netfoundry
python3 -m netfoundry.demo --help
```

### Self-Host Demo Servers and Endpoints

You may host additional, private demo servers with Docker on any x86_64 Linux device. This will create a handful of servers that you can access via an enrolled Endpoint e.g. Desktop Edge for MacOS.

1. In your terminal, change to the working directory.

    ```bash
    cd ./netfoundry-demo
    ```

1. Create Private Services in your Network

    ```bash
    python3 -m netfoundry.demo --network BibbidiBobbidiBoo --create-private
    ```

1. Save this file in your working directory [docker-compose.yml](https://raw.githubusercontent.com/netfoundry/developer-tools/master/docker/docker-compose.yml).
1. In a terminal, run Compose. Install with `pip3 install docker-compose` or [follow instructions](https://docs.docker.com/compose/install/).

    ```bash
    docker-compose up --detach
    ```

1. In [the web console](https://nfconsole.io/login), share or scan to add an Endpoint identity named like "dialerN" to your Mobile Edge or Desktop Edge app and then connect to the demo servers from anywhere!

* Hello, World! Splash: [http://hello.netfoundry/](http://hello.netfoundry/) (netfoundry/railz)
* REST Test: [http://httpbin.netfoundry/](http://httpbin.netfoundry/) (kennethreitz/httpbin)

When finished run `docker-compose down` to destroy the demo containers.

### Run a Linux Endpoint

You may also wish to visit the demo servers on a Linux machine. The first step is to configure DNS to enable accessing the domain names in your Network. Your Linux computer must have 127.0.0.1 as the primary nameserver. [Know more about DNS and `ziti-tunnel`](https://openziti.github.io/ziti/clients/tunneler.html#dns-server).

1. In your terminal, change to the working directory.

    ```bash
    cd ./netfoundry-demo
    ```

1. Create a Linux Dialer

    ```bash
    python3 -m netfoundry.demo --network BibbidiBobbidiBoo --create-dialer
    ```

Within a few seconds the container `dialer` that was created by your earlier `docker-compose up` command  will have enrolled. You may now visit any of the aforementioned demo servers in a web browser or with a terminal command.

```bash
# HTTPie
http GET http://weather.netfoundry "Host: wttr.in"
```

```bash
# cURL
curl http://weather.netfoundry --header "Host: wttr.in"
```

#### Troubleshooting Docker Compose

If the private Services are unavailable and the dialer log shows "no terminators" the likely cause is that the exit container has not yet started hosting the Services that were just created. The solution is to wait a few minutes or run `docker-compose restart exit`.

You may inspect the logs from the container that is hosting the exit point to the demo Services with `ziti-tunnel`.

```bash
docker-compose logs --follow exit
```


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

### Ansible Modules

You may install our [Ansible Galaxy Collection](https://galaxy.ansible.com/search?deprecated=false&keywords=netfoundry). Which includes a module `netfoundry_endpoint` for creating, updating, or deleting an Endpoint. More soon to come!

```bash
# install collection
ansible-galaxy collection install qrkourier.netfoundry
# read about the info module
ansible-doc qrkourier.netfoundry.netfoundry_info
# read about the Endpoint module
ansible-doc qrkourier.netfoundry.netfoundry_endpoint
```

For more examples please see [the playbook included in the collection](https://github.com/netfoundry/developer-tools/blob/master/ansible_collections/qrkourier/netfoundry/playbooks/network_info.yml). The default install path for this file is ~/.ansible/collections/ansible_collections/qrkourier/netfoundry/playbooks/network_info.yml.

## Utilities

* [bulkInviteEndpoints.py](https://raw.githubusercontent.com/netfoundry/developer-tools/master/bulkInviteEndpoints.py)
: create Endpoints and send the enrollment token to a list of email addresses

* [bulkEditRoleAttributes.py](https://raw.githubusercontent.com/netfoundry/developer-tools/master/bulkEditRoleAttributes.py)
: replace the role attributes on all Endpoints, Edge Routers, or Services; optionally limited to those that match a pattern

* [PostMan Service Runner](https://github.com/netfoundry/developer-tools/raw/master/NetFoundryRunners.postman_collection.json)
: create Services in bulk with PostMan
