---
permalink: /guides/ansible/
redirect_from:
  - /v2/guides/ansible/
title: "Ansible Guide"
sidebar:
    nav: v2guides
toc: false
classes: wide
---

You may install our [Ansible Galaxy Collection](https://galaxy.ansible.com/netfoundry/platform). Which includes a module `netfoundry_endpoint` for creating, updating, or deleting an Endpoint. More soon to come!

```bash
# install collection
ansible-galaxy collection install netfoundry.platform
# read about the info module
ansible-doc netfoundry.platform.netfoundry_info
# read about the Endpoint module
ansible-doc netfoundry.platform.netfoundry_endpoint
```

For more examples please see [the playbook included in the collection](https://github.com/netfoundry/developer-tools/blob/master/ansible_collections/netfoundry/platform/playbooks/network_info.yml). The default install path for this file is ~/.ansible/collections/ansible_collections/netfoundry/platform/playbooks/network_info.yml.
