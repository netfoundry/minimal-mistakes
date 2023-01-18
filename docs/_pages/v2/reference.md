---
title: References
permalink: /reference/
redirect_from:
    - /v2/reference/
toc: true
---

## HTML References

### Network Orchestration Platform API

[Core v2](./core){: .btn .btn--info .btn--x-large}

### Identity API

[Identity v1](https://gateway.production.netfoundry.io/identity/v1/docs/index.html){: .btn .btn--info .btn--x-large}

### Permissions API

[Authorization v1](https://gateway.production.netfoundry.io/auth/v1/docs/index.html){: .btn .btn--info .btn--x-large}

## Concepts

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
## Quick Reference

### Life Cycle Statuses

These symbolic values for `status` appear in many types of resources.

NEW
: The request to create the resource was accepted.

PROVISIONING
: A provisioning workflow is in progress.

PROVISIONED
: A provisioning workflow is complete.

ERROR
: An unexpected error has prevented a workflow from completing.

UPDATING
: The resource has been re-declared by re-sending all attributes in a `PUT` request, and a workflow is in progress.

REPLACING
: A healing workflow is in progress.

DELETING
: The request to delete the resource was accepted.

DELETED
: The deletion workflow is complete.

### Endpoint and Edge Router Enrollment Status

Endpoints and edge routers have an attribute `jwt` which value is the one-time enrollment token prior to enrollment, and `null` after enrollment has succeeded.

### Find the EC2 AMI ID for the NetFoundry Edge Router VM Offer in Any Region

```bash
# look up the latest version of the marketplace offer
❯ aws --region us-east-1 \
    ec2 describe-images \
      --owners aws-marketplace \
      --filters "Name=product-code,Values=eai0ozn6apmy1qwwd5on40ec7" \
      --query 'sort_by(Images, &CreationDate)[-1]'
```

```bash
# or, for all regions!
❯ aws --output text ec2 describe-regions | while read REG ENDPOINT OPTIN REGION; do 
aws --region $REGION \   
    ec2 describe-images \
      --owners aws-marketplace \
      --filters "Name=product-code,Values=eai0ozn6apmy1qwwd5on40ec7" \
      --query 'sort_by(Images, &CreationDate)[-1]' | \
        jq --arg region $REGION '{name: .Name, region: $region, id: .ImageId }'
done
```

```bash
# lookup the current product code by searching for the AMI ID for a particular region after subscribing in AWS Marketplace
❯ aws --region us-east-1 \                                                          
    ec2 describe-images \
      --image-id ami-086671bb16f8f058b|jq -r '.Images[].ProductCodes[].ProductCodeId'
eai0ozn6apmy1qwwd5on40ec7

```
