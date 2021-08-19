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

You may install our [Ansible Galaxy Collection](https://galaxy.ansible.com/netfoundry/platform). Which includes modules like `netfoundry_info` for creating a session and discovering networks.

## Before You Begin

### Docker Setup

A container image with the latest Ansible colletion already installed: `netfoundry/python:ansible`

### Developer Workstation Setup

Install the latest release of [the NetFoundry Python module](/guides/python).

```bash
# python3 pip3
pip install netfoundry --upgrade
```

Ensure you have the latest release of the collection.

```bash
# you must first delete the collection and then install to effect an "upgrade"
rm -rf ~/.ansible/collections/ansible_collections/netfoundry/platform && \
  ansible-galaxy collection install --force-with-deps netfoundry.platform
```

## Built-in Documentation

Explanation of module parameters with practical examples

```bash
# install collection
ansible-galaxy collection install netfoundry.platform
# read about the info module
ansible-doc netfoundry.platform.netfoundry_info
# read about the network module
ansible-doc netfoundry.platform.netfoundry_network
# read about the endpoint module
ansible-doc netfoundry.platform.netfoundry_endpoint
# read about the simple service module
ansible-doc netfoundry.platform.netfoundry_service_simple
# read about the advanced service module
ansible-doc netfoundry.platform.netfoundry_service_advanced
# read about the AppWAN module
ansible-doc netfoundry.platform.netfoundry_appwan
# read about the router module
ansible-doc netfoundry.platform.netfoundry_router
# read about the router rolicy module
ansible-doc netfoundry.platform.netfoundry_router_policy
```

Here is a simple example. For more examples please see [the playbook included in the collection](https://github.com/netfoundry/developer-tools/blob/master/ansible_collections/netfoundry/platform/playbooks/example_playbook.yml). The default install path for this file is ~/.ansible/collections/ansible_collections/netfoundry/platform/playbooks/example_playbook.yml.

```yaml
{% raw %}
- hosts: localhost
  gather_facts: no
  collections:
    - netfoundry.platform
    - community.general
  vars:
    hosted_edge_routers:
    - name: Oregon
      datacenter: us-west-2
    - name: Ohio
      datacenter: us-east-2
    - name: Virginia
      datacenter: us-east-1

  tasks:
  - name: Establish session
    netfoundry_info:
      credentials: credentials.json # relative to playbook or in ~/.netfoundry/ or /netfoundry/
    register: netfoundry_organization

  - name: Create network
    netfoundry_network:
      network: BibbidiBobbidiBoo
      size: small
      datacenter: ap-south-1
      state: PROVISIONED
      wait: 2400
      network_group: "{{ netfoundry_organization.network_group }}"

  - name: Describe the network
    netfoundry_info:
      network: BibbidiBobbidiBoo
      inventory: True
      session: "{{ netfoundry_organization.session }}"
    register: netfoundry_network

  - name: wait for each public edge router to become REGISTERED
      netfoundry_router:
        name: "{{ item.name }}"
        attributes: 
        - "#defaultRouters"
        datacenter: "{{ item.datacenter  }}"
        state: REGISTERED
        wait: 1200
        network: "{{ netfoundry_network.network }}"
      loop: "{{ hosted_edge_routers }}"

  - name: create endpoints
    netfoundry_endpoint:
      name: "{{ item }}"
      attributes:
      - "#workFromAnywhere"
      - "#defaultRouters"
      dest: /tmp/netfoundry # optionally save one-time enrollment tokens in a directory
      network: "{{ netfoundry_network.network }}"
    loop:
    - Client1
    - Exit1
    register: endpoints

  - name: declare an endpoint-hosted service
    netfoundry_service_simple:
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
      network: "{{ netfoundry_network.network }}"

  - name: Create a public edge router policy
    netfoundry_router_policy:
      name: defaultRouters
      routers:
      - "#defaultRouters"
      endpoints:
      - "#defaultRouters"
      network: "{{ netfoundry_network.network }}"
    register: blanket_policy

  - name: Create an AppWAN
    netfoundry_appwan:
      name: Welcome
      endpoints:
      - "#workFromAnywhere"
      services:
      - "#welcomeWagon"
      network: "{{ netfoundry_network.network }}"

  # lastly, do tasks that depend on an async background task
  - name: declare a router-hosted service
    netfoundry_service_simple:
      name: HTTP Echo 2
      attributes: 
      - "#welcomeWagon"
      clientHostName: echo2.netfoundry
      clientPortRange: 80
      egressRouter: "Oregon"
      serverHostName: eth0.me
      serverPortRange: 80
      serverProtocol: TCP
      network: "{{ netfoundry_network.network }}"
    
{% endraw %}
```
