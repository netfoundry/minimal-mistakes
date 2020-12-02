---
permalink: /guides/demo/
redirect_from:
  - /v2/guides/demo/
title: "Quickstart Demo"
sidebar:
    nav: v2guides
toc: true
classes: wide
---

Let the demo script build you a complete NetFoundry Network and then play with it in [the web console](https://nfconsole.io/login).

## Before You Begin

1. Create a working directory like "netfoundry-demo".
1. [Create an API account](/guides/authentication/#get-an-api-account) and save it in the working directory as "credentials.json". You only need the JSON file for this exercise.

## Run the Demo

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

You may run the demo with Python or Docker.

### Run the Demo with Python

```bash
cd ./netfoundry-demo

# install
pip3 install --upgrade --user netfoundry

# Run the demo script
python3 -m netfoundry.demo --network BibbidiBobbidiBoo
```

### Run the Demo with Docker

Make sure you have [Docker Engine](https://docs.docker.com/engine/install/).

```bash
cd ./netfoundry-demo

# define a Network name
NETWORK_NAME=BibbidiBobbidiBoo

# Run the demo container (runs the Demo script)
docker run --rm -it -v $PWD:/netfoundry -e NETWORK_NAME netfoundry/python:demo
```

Enroll an Endpoint to access the public demo servers through the invented domain names below. To enroll you laptop you could install the Ziti Desktop Edge app for your OS and add the identity to the app. To enroll your mobile you could visit [the web console](https://nfconsole.io/login) to scan the identity QR code with Ziti Mobile Edge installed from the app store.

* Fireworks: [http://fireworks.netfoundry/](http://fireworks.netfoundry) Touch or click to shoot off some fireworks.
* IPv4 echo: [http://echo.netfoundry/](http://echo.netfoundry/) (eth0.me, shows you the IP from which your HTTP request originated on the internet)

## Do More with Python and Docker Compose

You have access to more parameters when running [the demo script](https://bitbucket.org/netfoundry/python-netfoundry/src/develop/netfoundry/demo.py) directly instead of running the demo container. Make sure you have `pip3` ([install](https://pip.pypa.io/en/stable/installing/)).

```bash
cd ./netfoundry-demo

# install
pip3 install --upgrade --user netfoundry

# explore demo options
python3 -m netfoundry.demo --help
```

### Host Demo Servers with Docker Compose

You may host additional, private demo servers with Docker on any x86_64 Linux device. This will create a handful of servers that you can access via an enrolled Endpoint e.g. Desktop Edge for MacOS.

1. In your terminal, change to the working directory.

    ```bash
    cd ./netfoundry-demo
    ```

1. Create Private Services in your Network

    ```bash
    # Re-run the demo, additionally creating the private Services
    python3 -m netfoundry.demo --network BibbidiBobbidiBoo --create-private
    ```

1. In a terminal, run Compose.

    ```bash
    # install Compose
    pip3 install --user docker-compose

    # download the Compose file with cURL and run Compose
    docker run --rm -v $(pwd):/work -w /work appropriate/curl -L -o docker-compose.yml https://raw.githubusercontent.com/netfoundry/developer-tools/master/docker/docker-compose.yml && docker-compose up --detach
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


### Troubleshooting Docker Compose

If the private Services are unavailable and the dialer log shows "no terminators" the likely cause is that the exit container has not yet started hosting the Services that were just created. The solution is to wait a few minutes or run `docker-compose restart exit`.

You may inspect the logs from the container that is hosting the exit point to the demo Services with `ziti-tunnel`.

```bash
docker-compose logs --follow exit
```

