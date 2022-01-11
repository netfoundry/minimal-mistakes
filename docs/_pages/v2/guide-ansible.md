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

## Video Walkthrough
{% include youtube.html id="OLo-Qi4DbvY" %}

## Before You Begin

### Docker Setup

A container image with the Ansible collection already installed: `netfoundry/ansible`

[A Docker Compose file is provided](https://github.com/netfoundry/ansible-collection/blob/main/docker-compose.yml) to illustrate building and running this container.

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

  tasks:
  - name: Establish session
    netfoundry_info:
      credentials: credentials.json
    register: netfoundry_organization

  - name: Create Network
    netfoundry_network:
      name: BibbidiBobbidiBoo
      size: small
      datacenter: ap-south-1
      state: PROVISIONING
      network_group: "{{ netfoundry_organization.network_group }}"

  # HINT: background tasks are completely optional and may save time by performing other operations in parallel that
  #  do not depend on the background task. You may instead require state=PROVISIONED to block until the task is complete.

  - name: Watch for Network status in the background
    netfoundry_network:
      name: BibbidiBobbidiBoo
      state: PROVISIONED
      wait: 1800
      network_group: "{{ netfoundry_organization.network_group }}"
    register: network_watcher
    async: 1800 # max 30m
    poll: 0     # background
      
  - name: Wait until Network watcher succeeds 
    async_status:
      jid: "{{ network_watcher.ansible_job_id }}"
    retries: 180
    delay: 10
    register: network_async_job_result
    until: "{{ network_async_job_result.finished }}"

  - name: Describe the Network
    netfoundry_info:
      network: BibbidiBobbidiBoo
      inventory: True
      session: "{{ netfoundry_organization.network_group.session }}"
    register: netfoundry_network
    
  - name: block and wait for each hosted Edge Router to have a minimum state of PROVISIONING
    netfoundry_router:
      network: "{{ netfoundry_network.network }}"
      name: "{{ item.name }}"
      attributes: 
      - "#defaultRouters"
      datacenter: "{{ item.datacenter  }}"
      state: PROVISIONING
      wait: 200
    loop: "{{hosted_edge_routers}}"

  - name: wait in the background for each hosted Edge Router to become REGISTERED
    netfoundry_router:
      network: "{{ netfoundry_network.network }}"
      name: "{{ item.name }}"
      attributes: 
      - "#defaultRouters"
      datacenter: "{{ item.datacenter  }}"
      state: REGISTERED
    register: router_results
    async: 1000
    poll: 0
    loop: "{{hosted_edge_routers}}"

  - name: declare Endpoints
    netfoundry_endpoint:
      name: "{{ item }}"
      network: "{{ netfoundry_network.network }}"
      attributes:
      - "#workFromAnywhere"
      dest: /tmp/netfoundry                  # filename is Endpoint name if dest is a directory
      #dest: /tmp/netfoundry/ott-{{item}}.jwt # custom filename if name is like *.jwt
    loop:
    - Client1
    - Exit1
    register: endpoints

  - name: declare an Endpoint-hosted Service
    netfoundry_service_simple:
      network: "{{ netfoundry_network.network }}"
      name: HTTP Echo 1
      endpoints: 
      - Exit1
      attributes: 
      - "#welcomeWagon"
      clientHostName: echo-exit.netfoundry
      clientPortRange: 80
      serverHostName: eth0.me
      serverPort: 80
      serverProtocol: TCP

  - name: host a server port range as an array of Services
    netfoundry_service_simple:
      network: "{{ netfoundry_network.network }}"
      name: "spice-console-{{ item }}"
      attributes: "#spice-consoles"
      clientHostName: 192.168.0.188
      clientPortRange: "{{ item|int }}"
      endpoints: 
      - Exit1
      serverHostName: 192.168.0.188
      serverPort: "{{ item|int }}"
      serverProtocol: TCP
    with_sequence: 5900-5919
    register: spice_loop
    tags: port_range

  - name: declare a blanket Edge Router Policy
    netfoundry_router_policy:
      network: "{{ netfoundry_network.network }}"
      name: defaultRouters
      routers:
      - "#defaultRouters"
      endpoints:
      - "#all"
    register: blanket_policy

  - name: declare an AppWAN
    netfoundry_appwan:
      network: "{{ netfoundry_network.network }}"
      name: Welcome
      endpoints:
      - "#workFromAnywhere"
      services:
      - "#welcomeWagon"

  - name: Block until completion of background tasks
    async_status:
      jid: "{{ item.ansible_job_id }}"
    retries: 100
    delay: 10
    register: async_job_result
    until: "{{ async_job_result.finished }}"
    loop: "{{ router_results.results }}"

  # lastly, do tasks that depend on an async background task
  - name: declare a Router-hosted Service
    netfoundry_service_simple:
      network: "{{ netfoundry_network.network }}"
      name: HTTP Echo 2
      attributes: 
      - "#welcomeWagon"
      clientHostName: echo2.netfoundry
      clientPortRange: 80
      egressRouter: "Oregon {{increment}}"
      serverHostName: eth0.me
      serverPort: 80
      serverProtocol: TCP
    
  vars:
    increment: 12
    hosted_edge_routers:
    - name: Oregon {{increment}}
      datacenter: us-west-2
    - name: Ohio {{increment}}
      datacenter: us-east-2
    - name: Virginia {{increment}}
      datacenter: us-east-1
      


    
{% endraw %}
```
