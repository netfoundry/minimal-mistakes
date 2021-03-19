---
permalink: /guides/python/
redirect_from:
  - /v2/guides/python/
title: "Python Guide"
sidebar:
    nav: v2guides
toc: true
classes: wide
---

## Overview

An Organization is an identity construct, and so permissions pertaining to users and API accounts are granted on an Organization-wide basis. `class Organization` is used to create a reusable session object for some Organization, defaulting to the Organization of the calling identity, and to find Network Groups that are authorized for that Organization. The most common pattern is `organization = netfoundry.Organization(credentials)`.

Network Groups are just what they sound like: groupings of NetFoundry Networks. A Network is always a member of exactly one Group, and permissions pertaining to Networks are granted on a Group-wide or Network-wide basis. `class NetworkGroup` accepts the session object and is used to select one of the available Groups, defaulting to the first Group found. There is typically only one Group, and so the most common pattern is `network_group = netfoundry.NetworkGroup(organization)`.

An instance of `class Network` selects a particular Network by name or ID from the Group, and provides methods to use the Network to manage entities and policies in that Network. There are attributes like `network.endpoints()` that may be called to describe then-current state of a particular type of entity or policy. The most common pattern is `network = netfoundry.network(network_group, name="BibbidiBobbidiBoo")`. 

## Python Module

[Python Package Index module](https://pypi.org/project/netfoundry/)
: Python3 interface to the NetFoundry API

```bash
pip install --upgrade --user netfoundry
# or
python3 -m pip install --upgrade --user netfoundry
```

## Virtualenv

Alternatively, you could install the module in a project directory with `virtualenv`.

```bash
mkdir -p netfoundry-project && cd netfoundry-project
python3 -m pip install --user virtualenv
virtualenv venv
source venv/bin/activate
pip install netfoundry
```

### Documentation

The module works with `pydoc` in the usual ways. For example:

```bash
pydoc netfoundry.Organization
pydoc netfoundry.NetworkGroup
pydoc netfoundry.Network
pydoc netfoundry.demo
pydoc netfoundry
```

### Create a Custom Docker Container with the NetFoundry Python Module

Suppose you have written a Python program named "my-netfoundry-network.py" that imports the NetFoundry module. You could run your program with a Docker container image that has the NetFoundry module pre-installed.

```docker
FROM netfoundry/python
COPY ./my-netfoundry-network.py .
CMD ./my-netfoundry-network.py
```
