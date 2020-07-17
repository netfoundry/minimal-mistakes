---
title: References
permalink: /v2/reference/
toc: true
---

## HTML Reference
[HTTP REST Docs](https://gateway.production.netfoundry.io/core/v2/docs/index.html){: .btn .btn--info .btn--x-large}
<!-- [API v2 Reference](https://gateway.sandbox.netfoundry.io/rest/v2/docs/index.html) -->

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

Endpoints and Edge Routers have an attribute `jwt` which value is the one-time enrollment token prior to enrollment, and `null` after enrollment has succeeded.
