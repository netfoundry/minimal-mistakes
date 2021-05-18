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

The demo script will create a complete NetFoundry network that you may then extend for your own purposes. The following will be added to the NetFoundry network that you specify:

* AppWAN: "Welcome"
    * Services #welcomeWagon
        * Fireworks service
        * Echo service
        * Weather service
    * Endpoints #workFromAnywhere
        * Mobile1
        * Desktop1
* edge routers #defaultRouters
    * Americas

## How it Works

You'll access the demo servers by adding the identity of one of the provided Endpoints to a tunneler app e.g. Ziti Mobile Edge for iOS, Desktop Edge for Windows. As soon as the Endpoints are created by the demo you may go ahead and add the identity to your tunneler.

Look in the web console for these Endpoints and click on them to explore installation and enrollment instructions for your device's operating system.

Once the Endpoint identity has been added to your device's tunneler the demo servers will be reachable e.g. http://fireworks.netfoundry.

## Before You Begin

1. Create a working directory like "netfoundry-demo".
1. [Create an API account](/guides/authentication/#get-an-api-account) and save it in the working directory as "credentials.json". You only need the JSON file for this exercise.

You may run the demo in a terminal window as a Docker container or as a Python script.

### Run the Demo with Python

To run the demo with Python you will need to [install Python3](https://www.python.org/downloads/).

```bash
cd ./netfoundry-demo

# install
pip3 install --upgrade --user netfoundry

# Run the demo script to deploy global fabric and a handful of functioning services
python3 -m netfoundry.demo --network BibbidiBobbidiBoo

# Delete the demo network
python3 -m netfoundry.demo delete --network BibbidiBobbidiBoo
```

### Run the Demo with Docker

Make sure you have [Docker Engine](https://docs.docker.com/engine/install/).

```bash
cd ./netfoundry-demo

# define a network name
NETWORK_NAME=BibbidiBobbidiBoo

# Run the demo container (runs the demo script)
docker run --rm -it -v $(pwd):/netfoundry -e NETWORK_NAME netfoundry/python:demo
```

## Use the Demo Servers

Install a tunneler on your device. For example, you could install the Ziti Desktop Edge for MacOS and add the identity for the Endpoint named "Desktop1" in the Desktop Edge app. The easiest way to obtain the Endpoint software and the Endpoint identity is to visit [the web console](https://nfconsole.io/login) and click on one of your Endpoints. There you may scan the identity's QR code with Ziti Mobile Edge installed from the app store or download the identity as a JWT file to add to the Desktop Edge app.

### Fireworks Demo

Touch or click to shoot off some fireworks. This demo shows that you are able to access a web site with an invented domain name that you control through your NetFoundry network.

[http://fireworks.netfoundry/](http://fireworks.netfoundry)

### IP Address Echo Demo

Visit [http://eth0.me](http://eth0.me) and [http://echo.netfoundry/](http://echo.netfoundry/) in two separate web browser tabs. The IP addresses are different and this demonstrates that your HTTP request was sent to the same demo server by two different paths. This is important because your NetFoundry network allows you to control where your traffic exits to the internet. If you visit eth0.me directly then you will see the ISP address where your device connects to the internet without NetFoundry. If you use the NetFoundry service address then your connection occurs via the hosting edge router (an exit point for your network).

## Run Additional Demo Servers

You may host additional, private demo servers with Docker. This will create a handful of servers that you can access with an Endpoint e.g. Desktop Edge for MacOS.

```bash
cd ./netfoundry-demo

# Re-run the demo, additionally creating the private services
python3 -m netfoundry.demo --network BibbidiBobbidiBoo --create-private

# install Compose
pip3 install --user docker-compose

# download the Compose file with cURL and run Compose
docker run --rm -v $(pwd):/work -w /work appropriate/curl -L -o docker-compose.yml https://raw.githubusercontent.com/netfoundry/developer-tools/master/docker/docker-compose.yml && docker-compose up --detach
```

In [the web console](https://nfconsole.io/login), share to an email address or scan to add one of the Endpoints. You could add the Endpoint identity to the Mobile Edge or Desktop Edge app linked in the email and console to then connect to the demo servers from anywhere the app is running.

* Hello, World! Splash: [http://hello.netfoundry/](http://hello.netfoundry/) (netfoundry/railz)
* REST Test: [http://httpbin.netfoundry/](http://httpbin.netfoundry/) (kennethreitz/httpbin)

When finished run `docker-compose down` to destroy the demo containers.

## Run a Linux Client Endpoint

You may also wish to visit the demo servers on a Linux machine. The first step is to configure DNS to enable accessing the domain names in your network. Your Linux computer must have 127.0.0.1 as the primary nameserver. [Know more about the Edge Tunneler CLI](https://support.netfoundry.io/hc/en-us/articles/360045177311).

1. In your terminal, change to the working directory.

    ```bash
    cd ./netfoundry-demo
    ```

1. Create a Linux Client Endpoint

Client Endpoints dial services; hosting Endpoints bind services.

```bash
python3 -m netfoundry.demo --network BibbidiBobbidiBoo --create-client
```

Within a few seconds the container `client` that was created by your earlier `docker-compose up` command  will have enrolled. You may now visit any of the aforementioned demo servers in a web browser or with a terminal command.

```bash
# HTTPie
http http://weather.netfoundry "Host: wttr.in"
```

```bash
# cURL
curl http://weather.netfoundry --header "Host: wttr.in"
```

## More Options

```bash
❯ python3 -m netfoundry.demo --help
DEBUG: running demo script in "python-netfoundry/netfoundry/demo.py"
usage: python -m netfoundry.demo [-h] [-n NETWORK] [-o ORGANIZATION] [-g NETWORK_GROUP] [-s {small,medium,large}] [-v VERSION] [-p] [-c] [--credentials CREDENTIALS] [--provider {AWS,AZURE,GCP,ALICLOUD,NETFOUNDRY,OCP}]
               (--regions {Americas,EuropeMiddleEastAfrica,AsiaPacific} [{Americas,EuropeMiddleEastAfrica,AsiaPacific} ...] | --location-codes LOCATION_CODES [LOCATION_CODES ...]) [--proxy PROXY]
               [{create,delete}]

positional arguments:
  {create,delete}       the command to run

optional arguments:
  -h, --help            show this help message and exit
  -n NETWORK, --network NETWORK
                        The name of your demo network
  -o ORGANIZATION, --organization ORGANIZATION
                        The label of an alternative organization (default is Org of caller)
  -g NETWORK_GROUP, --network-group NETWORK_GROUP
                        The shortname of a network group (default is the first, typically singular, Group known to this Org)
  -s {small,medium,large}, --network-size {small,medium,large}
                        Billable network size to create
  -v VERSION, --network-version VERSION
                        network product version: "default", "latest", or semver
  -p, --create-private  Also create private Endpoint-hosted services for the optional Docker Compose portion of the quickstart
  -c, --create-client   Also create a client Endpoint for the optional Linux portion of the quickstart
  --credentials CREDENTIALS
                        path to API account credentials JSON file overrides NETFOUNDRY_API_ACCOUNT
  --provider {AWS,AZURE,GCP,ALICLOUD,NETFOUNDRY,OCP}
                        cloud provider to host edge routers
  --regions {Americas,EuropeMiddleEastAfrica,AsiaPacific} [{Americas,EuropeMiddleEastAfrica,AsiaPacific} ...]
                        space-separated one or more major geographic regions in which to place edge routers for overlay fabric
  --location-codes LOCATION_CODES [LOCATION_CODES ...]
                        cloud location codes in which to host edge routers
  --proxy PROXY         'http://localhost:8080' 'socks5://localhost:9046'

```

## Troubleshooting

If the private services are unavailable and the client log shows "no terminators" the likely cause is that the exit container has not yet started hosting the services that were just created. The solution is to wait a few minutes or run `docker-compose restart exit`.

You may inspect the logs from the container that is hosting the exit point to the demo services with `ziti-tunnel`.

```bash
# inspect the logs for the hosting Endpoint
docker-compose logs exit

# inspect the logs for the Linux client Endpoint
docker-compose logs client
```
