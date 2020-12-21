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

You may install our [Ansible Galaxy Collection](https://galaxy.ansible.com/netfoundry/platform). Which includes modules
* `netfoundry_info` for creating a session and discovering Networks
* `netfoundry_endpoint` for creating, updating, or deleting an Endpoint
* `netfoundry_service` for creating, updating, or deleting a Service

```bash
# install collection
ansible-galaxy collection install netfoundry.platform
# read about the info module
ansible-doc netfoundry.platform.netfoundry_info
# read about the Endpoint module
ansible-doc netfoundry.platform.netfoundry_endpoint
# read about the Service module
ansible-doc netfoundry.platform.netfoundry_service
# read about the Router module
ansible-doc netfoundry.platform.netfoundry_router
# read about the Router Policy module
ansible-doc netfoundry.platform.netfoundry_router_policy
```

For more examples please see [the playbook included in the collection](https://github.com/netfoundry/developer-tools/blob/master/ansible_collections/netfoundry/platform/playbooks/example_playbook.yml). The default install path for this file is ~/.ansible/collections/ansible_collections/netfoundry/platform/playbooks/example_playbook.yml.

Create some Services with values from a CSV file

```yaml
{% raw %}
- hosts: localhost
  collections:
  - netfoundry.platform
  - community.general
  tasks:
  - name: Establish session and discover Network
    netfoundry_info:
      network: BibbidiBobbidiBoo
      credentials: credentials.json
    register: netfoundry_info

  - name: declare Endpoints
    netfoundry_endpoint:
        name: "{{ item }}"
        network: "{{ netfoundry_info.network }}"
        attributes:
        - "#workFromAnywhere"
        dest: /tmp/netfoundry
    loop:
    - Client1
    - Exit1
    register: endpoints

  - name: declare an Endpoint-hosted Service
    netfoundry_service:
        network: "{{ netfoundry_info.network }}"
        name: HTTP Echo 1
        endpoints: 
        - Exit1
        attributes: 
        - "#welcomeWagon"
        clientHostName: echo-exit.netfoundry
        clientPortRange: 80
        serverHostName: eth0.me
        serverPortRange: 80
        serverProtocol: TCP

  - name: declare a NetFoundry-datacenter-hosted Edge Router
    netfoundry_router:
        network: "{{ netfoundry_info.network }}"
        name: EU West Router
        attributes: 
        - "#defaultRouters"
        datacenter: westeurope
    register: hosted_router

  - name: declare a Router-hosted Service
    netfoundry_service:
        network: "{{ netfoundry_info.network }}"
        name: HTTP Echo 2
        attributes: 
        - "#welcomeWagon"
        clientHostName: echo2.netfoundry
        clientPortRange: 80
        egressRouter: "{{ hosted_router.message.id }}"
        serverHostName: eth0.me
        serverPortRange: 80
        serverProtocol: TCP

  - name: Read Services from CSV file
    read_csv:
        path: services.csv
    register: services

  # with CSV headings:
  #  serviceName
  #  attribute
  #  ipAddress
  #  port
  #  hostName
  #  edgeRouterName
  - name: declare Services from CSV
    netfoundry_service:
      network: "{{ netfoundry_info.network }}"
      name: "{{ item.serviceName }}"
      attributes:
      - "{{ item.attribute }}"
      clientHostName: "{{ item.hostName }}"
      clientPortRange: "{{ item.port }}"
      egressRouter: "{{ item.edgeRouterId }}"
      serverHostName: "{{ item.ipAddress }}"
      serverPortRange: "{{ item.port }}"
      serverProtocol: TCP
    loop: "{{ services.list }}"

{% endraw %}
```
