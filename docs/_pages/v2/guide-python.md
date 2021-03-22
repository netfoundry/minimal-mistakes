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

### Organizations

An *Organization* contains identities such as users and API accounts. These identities are granted access to Networks in Network Groups by assignment of roles. The default roles are Organization Admin and Network Group Admin. Instances of `class Organization` represent some Organization. The Organization of the caller's identity is the default. Search attribute `Organization.network_groups_by_name` to find Network Groups that are authorized for the Organization. There is typically only one Organization and one Network Group.

```python
# become identity in Organization
identity = 'credentials.json'                                # relative to PWD or in ~/.netfoundry or /netfoundry
organization = netfoundry.Organization(credentials=identity) # use the calling identity's organization
caller_identity = organization.caller                        # Who am I?
group_names = organization.network_groups_by_name            # {'ACMEGROUP': 'e7688733-a3ae-4ce5-821a-055247baa09e'}
```

```bash
# built-in docs
❯ pydoc netfoundry.Organization
```

### Network Groups

A Network is always a member of exactly one *Network Group*. Permissions for a Network are granted at the Network or Network Group level. `class NetworkGroup` is used to select one of the available Network Groups. The default is to use the first, and there is typically only one.

```python
# use Group as Organization
network_group = netfoundry.NetworkGroup(organization, network_group_id=group_names['ACMEGROUP'])
network_name = 'ACME Net'
created_network = network_group.create_network(name=network_name)
```

```bash
# built-in docs
❯ pydoc netfoundry.NetworkGroup
```

### Networks

A NetFoundry *Network* contains the entities and policies that compose your AppWANs. An instance of `class Network` is created to use a particular Network by name or ID. This provides attributes and methods to describe and manage the Network.

```python
# use Network
network = netfoundry.network(network_group, network_id=created_network['id'])
status = network.status           # read the status attribute
endpoints = network.endpoints()   # call a method to get live results
```

```bash
# built-in docs
❯ pydoc netfoundry.Network
```

## Installation

[Python Package Index module](https://pypi.org/project/netfoundry/)
: Python3 interface to the NetFoundry API

```bash
❯ pip install --upgrade --user netfoundry
# or
❯ python3 -m pip install --upgrade --user netfoundry
```

## Demo Script

You may find it helpful to read a Python script that uses the module to create and populate a Network with functioning Services.

[Link to demo.py source file on the web](https://bitbucket.org/netfoundry/python-netfoundry/src/master/netfoundry/demo.py).

```bash
# or find the installed source file for demo.py under FILE heading of the built-in doc
❯ pydoc netfoundry.demo
```

There's [a separate article here](/guides/demo/) all about using `demo.py` which is included with the module.
