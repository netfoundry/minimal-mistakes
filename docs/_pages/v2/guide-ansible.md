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

You may install our [Ansible Galaxy Collection](https://galaxy.ansible.com/netfoundry/platform). Which includes modules like `netfoundry_info` for creating a session and discovering Networks.

## Before You Begin

Install [the NetFoundry Python module](/guides/python).

```bash
# for example, to install latest in HOME
pip3 install netfoundry --user --upgrade
```

## Built-in Documentation

Explanation of module parameters with practical examples

```bash
# install collection
ansible-galaxy collection install netfoundry.platform
# read about the Info module
ansible-doc netfoundry.platform.netfoundry_info
# read about the Network module
ansible-doc netfoundry.platform.netfoundry_network
# read about the Endpoint module
ansible-doc netfoundry.platform.netfoundry_endpoint
# read about the Service module
ansible-doc netfoundry.platform.netfoundry_service
# read about the AppWAN module
ansible-doc netfoundry.platform.netfoundry_appwan
# read about the Router module
ansible-doc netfoundry.platform.netfoundry_router
# read about the Router Policy module
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

  - name: Create Network
    netfoundry_network:
      network: BibbidiBobbidiBoo
      size: small
      datacenter: ap-south-1
      state: PROVISIONED
      wait: 2400
      network_group: "{{ netfoundry_organization.network_group }}"

  - name: Describe the Network
    netfoundry_info:
      network: BibbidiBobbidiBoo
      inventory: True
      session: "{{ netfoundry_organization.session }}"
    register: netfoundry_network

  - name: wait for each public Edge Router to become REGISTERED
      netfoundry_router:
        name: "{{ item.name }}"
        attributes: 
        - "#defaultRouters"
        datacenter: "{{ item.datacenter  }}"
        state: REGISTERED
        wait: 1200
        network: "{{ netfoundry_network.network }}"
      loop: "{{ hosted_edge_routers }}"

  - name: create Endpoints
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

  - name: declare an Endpoint-hosted Service
    netfoundry_service:
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

  - name: Create a public Edge Router Policy
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
  - name: declare a Router-hosted Service
    netfoundry_service:
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
