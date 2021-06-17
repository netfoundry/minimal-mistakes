---
title: References
permalink: /reference/
redirect_from:
    - /v2/reference/
toc: true
---

## HTML References

### Network Orchestration Platform API

[Core v2](https://gateway.production.netfoundry.io/core/v2/docs/index.html){: .btn .btn--info .btn--x-large}

### Identity API

[Identity v1](https://gateway.production.netfoundry.io/identity/v1/docs/index.html){: .btn .btn--info .btn--x-large}

### Permissions API

[Authorization v1](https://gateway.production.netfoundry.io/auth/v1/docs/index.html){: .btn .btn--info .btn--x-large}


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
