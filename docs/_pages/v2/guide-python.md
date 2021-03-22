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

An Organization contains identities, and permissions pertaining to administration of identities, i.e. users and API accounts, are granted on an Organization-wide basis. Instances of `class Organization` represent some Organization, defaulting to the Organization of the callers identity. You may use the methods on that object to find Network Groups that are authorized for that Organization. The most common pattern is this:

```python
identity = 'credentials.json'                                # relative to PWD or in ~/.netfoundry or /netfoundry
organization = netfoundry.Organization(credentials=identity) # use the calling identity's organization
caller_identity = organization.caller                        # Who am I?
group_names = organization.network_groups_by_name            # {'ACMEGROUP': 'e7688733-a3ae-4ce5-821a-055247baa09e'}
```

A Network is always a member of exactly one Network Group, and permissions pertaining to Networks are granted on a Group-wide or Network-wide basis. `class NetworkGroup` requires the Organization object as a parameter and is used to select one of the available Groups, defaulting to the first Group found. There is typically only one Group, and the most common pattern is this:

```python
network_name = 'ACME Net'
network_group = netfoundry.NetworkGroup(organization, network_group_id=group_names['ACMEGROUP'])  # use Group as Organization
created_network = network_group.create_network(name=network_name)
```

An instance of `class Network` selects a particular Network by name or ID from the Network Group, and provides methods to use the Network to manage entities and policies in that Network. There are attributes like `network.endpoints()` that may be called to describe then-current state of a particular type of entity or policy. The most common pattern is this:

```python
network = netfoundry.network(network_group, network_id=created_network['id'])
endpoints = network.endpoints()
```

## Install

[Python Package Index module](https://pypi.org/project/netfoundry/)
: Python3 interface to the NetFoundry API

```bash
pip install --upgrade --user netfoundry
# or
python3 -m pip install --upgrade --user netfoundry
```

### Virtualenv

Alternatively, you could install the module in a project directory with `virtualenv`.

```bash
mkdir -p netfoundry-project && cd netfoundry-project
python3 -m pip install --user virtualenv
virtualenv venv
source venv/bin/activate
pip install netfoundry
```

## Documentation

The module works with `pydoc` in the usual ways. For example:

```bash
pydoc netfoundry.Organization
pydoc netfoundry.NetworkGroup
pydoc netfoundry.Network
pydoc netfoundry.demo
pydoc netfoundry
```

## Docker

Suppose you have written a Python program named "my-netfoundry-network.py" that imports the NetFoundry module. You could run your program with a Docker container image that has the NetFoundry module pre-installed.

```docker
FROM netfoundry/python
COPY ./my-netfoundry-network.py .
CMD ./my-netfoundry-network.py
```
