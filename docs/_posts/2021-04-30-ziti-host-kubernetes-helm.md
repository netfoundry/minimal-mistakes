---
title: Connect to Kubernetes with NetFoundry
excerpt: Install a Helm Chart for secure access to cluster or pod services.
tags:
    - devops
    - kubernetes
    - helm
author: Ken
toc: false
classes: wide
#last_updated: June 9, 2019
header:
    image: /assets/images/nfkubbiker.jpg
---

This will deploy a Linux endpoint to your Kubernetes cluster. The endpoint may then be assigned in your NetFoundry network to host a NetFoundry service that is reachable inside your Kubernetes cluster. For example, the master API server used by `kubectl` or a Kubernetes dashboard 

In NF console, create an endpoint like "k8s pod identity". Download the enrollment token (key). This will be used to enroll the k8s pod a little later. Create a service like "k8s api server" for https://kubernetes.default.svc:443, hosted by the endpoint you just created. Create a client endpoint like "my laptop". Download the enrollment token .jwt file to your laptop. Create an AppWAN authorizing your laptop to connect to "k8s api server". Create a hosted edge router in any NF datacenter. Create a (blanket) edge router policy configuring #all endpoints to use #all edge routers.

Create a public OKE cluster.

Install the Helm chart: https://netfoundry.github.io/charts/
Use the "k8s pod identity.jwt" file you downloaded, following the example in the charts web page.

Install a Ziti Desktop Edge on your laptop and load the token .jwt you downloaded earlier as an identity in Ziti Desktop Edge.

Create a kubectl cluster definition for the new, private API server URL: https://kubernetes.default.svc:443 with the same certificate authority. Create a new kubectl context pairing the same user with the new, private cluster definition.

Switch kubectl context to the newly-created private context

Verify kubectl get pods works with the private context

In OCI console, disable the public endpoint for the cluster

