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

Users and API accounts are identities, and identities are members of an *organization*. Identities are granted permissions on *organizations*, *networks*, and *network groups* by way of *role* assignments. 
<!-- TODO: Identities are managed through methods of `class Organization`. -->

### Roles

Roles are sets of permissions that are granted to *identities* for *organizations*, *networks*, and *network groups*. An example of a role assignment is "Network Admin - ACME Net" which grants permission to manage *network* "ACME Net", but not to delete it nor grant new permissions.

The default roles for new users and API accounts are "organization admin" and "network group admin". Taken together, these default roles grant all permissions for the *organization* and *networks* inside the *network group*. 
<!-- TODO: Roles are managed through methods of `class Organization`. -->

### Organizations

An organization contains identities. An instance of `class Organization` represents a particular organization. There is typically only one organization, and the organization of the caller's identity is used by default.

```python
# become identity in organization
identity = 'credentials.json'                                # relative to PWD or in ~/.netfoundry or /netfoundry
organization = netfoundry.Organization(credentials=identity) # use the calling identity's organization
caller_identity = organization.caller                        # Who am I?
```

```bash
# built-in docs
❯ pydoc netfoundry.Organization
```

### Networks

A NetFoundry network contains the entities and policies that compose your AppWANs. An instance of `class Network` represents a particular network. The network may be selected by name or ID. This provides attributes and methods to describe and manage the network. A network is always a member of exactly one *network group*.

```python
# use a network
network = netfoundry.network(network_group, network_id=created_network['id'])
status = network.status           # read the status attribute
endpoints = network.endpoints()   # call a method to get live results
```

```bash
# built-in docs
❯ pydoc netfoundry.Network
```

### Network Groups

A *network group* organizes networks for billing and administration purposes. *Roles* that grant permissions on a network are granted to an *identity* at the network level or network group level or both. An instance of `class NetworkGroup` represents a particular network group and may be used to find, create, and delete networks in that group. Most users have only the default network group and it is selected automatically when there is only one.

```python
# use group as organization
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

A sample Python script is provided which uses this module to create a network with a functioning service.

[Link to demo.py source file on the web](https://bitbucket.org/netfoundry/python-netfoundry/src/master/netfoundry/demo.py).

```bash
# or find the installed source file for demo.py under FILE heading of the built-in doc
❯ pydoc netfoundry.demo
```

There's [a separate article here](/guides/demo/) all about using `demo.py` which is included with the module.
