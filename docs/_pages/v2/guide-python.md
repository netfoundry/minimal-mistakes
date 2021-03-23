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

This overview defines *italicized* terms and essential concepts and introduces the Python module classes you will use.

### Identities

Users and API accounts are identities, and identities are members of an *Organization*. Identities are granted permissions on *Organizations*, *Networks*, and *Network Groups* by way of *role* assignments. 
<!-- TODO: Identities are managed through methods of `class Organization`. -->

### Roles

Roles are sets of permissions that are granted to *identities* for *Organizations*, *Networks*, and *Network Groups*. An example of a role assignment is "Network Admin - ACME Net" which grants permission to manage *Network* "ACME Net", but not to delete it nor grant new permissions.

The default roles for new users and API accounts are "Organization Admin" and "Network Group Admin". Taken together, these default roles grant all permissions for the *Organization* and *Networks* inside the *Network Group*. 
<!-- TODO: Roles are managed through methods of `class Organization`. -->

### Organizations

An Organization contains identities. An instance of `class Organization` represents a particular Organization. There is typically only one Organization, and the Organization of the caller's identity is used by default.

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

### Networks

A NetFoundry Network contains the entities and policies that compose your AppWANs. An instance of `class Network` represents a particular Network. The Network may be selected by name or ID. This provides attributes and methods to describe and manage the Network. A Network is always a member of exactly one *Network Group*.

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

### Network Groups

A *Network Group* organizes Networks for billing and administration purposes. *Roles* that grant permissions on a Network are granted to an *identity* at the Network level or Network Group level or both. An instance of `class NetworkGroup` represents a particular Network Group and may be used to find, create, and delete Networks in that Group. Most users have only the default Network Group and it is selected automatically when there is only one.

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

## Installation

Installing the Python3 module is easy with `pip`.

[Python Package Index module](https://pypi.org/project/netfoundry/)
: Python3 interface to the NetFoundry API

```bash
❯ pip install netfoundry
```

## Demo Script

A sample Python script is provided which uses this module to create a Network with a functioning Service.

[Link to demo.py source file on the web](https://bitbucket.org/netfoundry/python-netfoundry/src/master/netfoundry/demo.py).

```bash
# or find the installed source file for demo.py under FILE heading of the built-in doc
❯ pydoc netfoundry.demo
```

There's [a separate article here](/guides/demo/) all about using `demo.py` which is included with the module.
