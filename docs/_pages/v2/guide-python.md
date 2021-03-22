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

### Organizations, Identities, and Roles

An *Organization* contains identities. Users and API accounts are identities. An instance of `class Organization` represents a particular Organization. There is typically only one Organization, and the Organization of the caller's identity is used by default.

These identities are granted access to Networks in Network Groups when a role is assigned to an identity for some Network or Network Group. An example of a role assignment is "Network Admin - ACME Net" which grants permission to manage Network "ACME Net", but not to delete the Network itself or grant new permissions on the Network. The default roles are Organization Admin and Network Group Admin. Together these default roles grant all permissions for the Organization and Networks inside the Group.

```python
# become identity in Organization
identity = 'credentials.json'                                # relative to PWD or in ~/.netfoundry or /netfoundry
organization = netfoundry.Organization(credentials=identity) # use the calling identity's organization
caller_identity = organization.caller                        # Who am I?
```

```bash
# built-in docs
❯ pydoc netfoundry.Organization
```

### Network Groups

A Network is always a member of exactly one *Network Group*. Permissions to read or manage a Network are granted to a member of an Organization at the Network level or Network Group level or both. An instance of `class NetworkGroup` represents a particular Network Group and may be used to find, create, and delete Networks in that Group. Most users have only the default Network Group and it is selected automatically when there is only one.

```python
# use Group as Organization
network_group = netfoundry.NetworkGroup(organization)
network_name = 'ACME Net'
created_network = network_group.create_network(name=network_name)
```

```bash
# built-in docs
❯ pydoc netfoundry.NetworkGroup
```

### Networks

A NetFoundry *Network* contains the entities and policies that compose your AppWANs. An instance of `class Network` represents a particular Network. The Network may be selected by name or ID. This provides attributes and methods to describe and manage the Network.

```python
# use a Network
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
